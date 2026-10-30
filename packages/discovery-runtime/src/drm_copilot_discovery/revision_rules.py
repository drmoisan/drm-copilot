"""Check captured bytes and declared pins without guessing remote freshness."""

from __future__ import annotations

import hashlib
from dataclasses import dataclass, field
from types import MappingProxyType
from typing import TYPE_CHECKING, Literal

from drm_copilot_discovery.findings import Finding, FindingCollector
from drm_copilot_discovery.models import JsonObject, JsonValue
from drm_copilot_discovery.reference_links import reference_finding, string_value
from drm_copilot_discovery.references import index_references
from drm_copilot_discovery.repository_reader import full_revision
from drm_copilot_discovery.snapshot import repository_pins

if TYPE_CHECKING:
    from collections.abc import Mapping

    from drm_copilot_discovery.references import ArtifactRecord, ReferenceIndex
    from drm_copilot_discovery.snapshot import DiscoverySnapshot


def is_full_revision(value: JsonValue) -> bool:
    """Recognize literal full Git pins; never interpret revision expressions."""
    if not isinstance(value, str):
        return False
    try:
        full_revision(value)
    except ValueError:
        return False
    return True


@dataclass(frozen=True)
class RevisionInputs:
    """Read only retained local bytes and immutable objects from one snapshot."""

    snapshot: DiscoverySnapshot
    files: Mapping[str, bytes] = field(init=False, repr=False)
    objects: Mapping[tuple[str, str | None, str], bytes] = field(init=False, repr=False)

    def __post_init__(self) -> None:
        """Freeze efficient indexes without rereading or copying payload bytes."""
        # Index the retained byte objects so repeated rule checks perform no reads.
        object.__setattr__(
            self,
            "files",
            MappingProxyType(
                {item.path: item.content for item in self.snapshot.manifest.files}
            ),
        )
        object.__setattr__(
            self,
            "objects",
            MappingProxyType(
                {
                    (
                        item.repository.id,
                        item.repository.revision,
                        item.path,
                    ): item.content
                    for item in self.snapshot.repository_files
                }
            ),
        )

    def content(
        self,
        record: ArtifactRecord,
        *,
        repository: str,
        revision: str | None,
        path: str,
        immutable: bool = False,
    ) -> bytes | None:
        """Select exact captured bytes; absent/mismatched context returns None.

        Imported paths are relative to their own transport root. Local source/test
        proof requires a captured Git object; runtime bytes do not require Git.
        """
        artifact = record.artifact
        # Imported payloads cannot escape into another repository or pin namespace.
        if artifact.origin_path is not None:
            if repository != artifact.repository.id or (
                immutable and revision != artifact.repository.revision
            ):
                return None
            if not artifact.path.endswith("/" + artifact.origin_path):
                return None
            root = artifact.path[: -len(artifact.origin_path)]
            return self.files.get(root + path)
        if repository != self.snapshot.profile.repository.id:
            return None
        if immutable:
            return self.objects.get((repository, revision, path))
        return self.files.get(path)


@dataclass(frozen=True)
class RevisionValidation:
    """Report local integrity separately from unknowable remote branch state."""

    findings: tuple[Finding, ...]

    @property
    def remote_freshness(self) -> Literal["unknown"]:
        """No captured commit can establish the current state of a remote branch."""
        return "unknown"


def _pin(
    record: ArtifactRecord,
    owner: JsonValue,
    revision: JsonValue,
    pointer: str,
    expected: Mapping[str, str | None],
    collector: FindingCollector,
) -> None:
    """Require declared ownership and a full matching configured revision."""
    code = None
    # Unknown identities and malformed pins fail before any equality inference.
    if not isinstance(owner, str) or owner not in expected:
        code = "REVISION_REPOSITORY"
    elif not is_full_revision(revision):
        code = "REVISION_PIN_REQUIRED"
    elif expected[owner] is not None and revision != expected[owner]:
        code = "REVISION_PIN_MISMATCH"
    if code is not None:
        collector.add(
            reference_finding(
                code,
                record,
                pointer,
                "Declared repository/pin disagrees with the required identity.",
            )
        )


def _selected(inputs: RevisionInputs, collector: FindingCollector) -> None:
    """Compare inspected local source/test bytes with their configured immutable pin."""
    snapshot = inputs.snapshot
    local = snapshot.profile.repository
    # Documentation-only HEAD changes preserve matching pinned source bytes.
    for file in snapshot.manifest.files:
        if file.category not in {"source", "test"}:
            continue
        pinned = inputs.objects.get((local.id, local.revision, file.path))
        code = None
        if local.revision is None:
            code = "REVISION_PIN_REQUIRED"
        elif pinned is None:
            code = "REVISION_CONTENT_UNAVAILABLE"
        elif pinned != file.content:
            code = "REVISION_SOURCE_CHANGED"
        if code is not None:
            collector.add(
                Finding(
                    code=code,
                    artifact_path=file.path,
                    message="Inspected source/test bytes differ from pinned bytes.",
                    next_action="Capture bytes at the full pin and revalidate.",
                )
            )
    if snapshot.checkout is not None and snapshot.checkout.id != local.id:
        collector.add(
            Finding(
                code="REVISION_CHECKOUT_IDENTITY",
                message="Captured checkout belongs to a different repository.",
                next_action="Capture the explicitly configured repository.",
            )
        )


def _references(
    inputs: RevisionInputs,
    index: ReferenceIndex,
    sources: Mapping[str, str | None],
    targets: Mapping[str, str | None],
    collector: FindingCollector,
) -> None:
    """Verify pinned artifact links against captured identities and exact file bytes."""
    expected = {**sources, **targets}
    # Resolved links retain their original pin/hash fields for this independent rule.
    for link in index.links:
        if link.target is None:
            continue
        ref, target = link.reference, link.target
        source_contract = "artifact_path" in ref
        owner = ref.get("repository_id" if source_contract else "repository")
        revision = ref.get("revision")
        digest = ref.get("artifact_sha256" if source_contract else "sha256")
        if owner is None:
            continue
        allowed = (
            sources
            if source_contract
            else targets if target.kind == "implementation-record" else expected
        )
        _pin(link.source, owner, revision, link.pointer, allowed, collector)
        if (
            owner != target.repository
            or revision != target.artifact.repository.revision
        ):
            collector.add(
                reference_finding(
                    "REVISION_ARTIFACT_PIN",
                    link.source,
                    link.pointer,
                    "The captured artifact has a different repository or revision.",
                )
            )
        content = inputs.files[target.artifact.path]
        if digest != hashlib.sha256(content).hexdigest():
            collector.add(
                reference_finding(
                    "REVISION_ARTIFACT_HASH",
                    link.source,
                    link.pointer,
                    "The reference checksum does not match captured artifact bytes.",
                )
            )


def _declarations(
    record: ArtifactRecord,
    expected: Mapping[str, str | None],
    sources: Mapping[str, str | None],
    targets: Mapping[str, str | None],
    collector: FindingCollector,
) -> None:
    """Check declared source/target identities without deriving completion status."""
    document = record.document
    # Imported historical content is evaluated at its own immutable transport pin.
    declared = dict(expected)
    if record.artifact.origin_path is not None:
        declared[record.repository] = record.artifact.repository.revision
    if record.kind in {"inventory-snapshot", "coverage-ledger"}:
        revision = document.get("revision")
        if revision is not None:
            _pin(
                record,
                document.get("repository"),
                revision,
                "/revision",
                declared,
                collector,
            )
    if record.kind in {"scope", "extension-result-manifest"}:
        repository = document.get("repository")
        if (
            isinstance(repository, JsonObject)
            and repository.get("revision") is not None
        ):
            _pin(
                record,
                repository.get("id"),
                repository.get("revision"),
                "/repository",
                declared,
                collector,
            )
    if record.kind == "source-snapshot-manifest":
        repository = document.get("source_repository")
        if isinstance(repository, JsonObject):
            _pin(
                record,
                repository.get("id"),
                repository.get("revision"),
                "/source_repository",
                sources,
                collector,
            )
    if record.kind == "implementation-record":
        repository = document.get("target_repository")
        if isinstance(repository, JsonObject):
            _pin(
                record,
                repository.get("id"),
                repository.get("revision"),
                "/target_repository",
                targets,
                collector,
            )
    if record.kind == "parity-matrix":
        # Source and target role declarations cannot be interchanged by shared IDs.
        for name, allowed in (
            ("source_repositories", sources),
            ("target_repositories", targets),
        ):
            values = document.get(name)
            if isinstance(values, tuple):
                # Null pins remain drafts; present pins must match their role.
                for position, value in enumerate(values):
                    if (
                        isinstance(value, JsonObject)
                        and value.get("revision") is not None
                    ):
                        _pin(
                            record,
                            value.get("id"),
                            value.get("revision"),
                            f"/{name}/{position}",
                            allowed,
                            collector,
                        )
        entries = document.get("entries")
        if isinstance(entries, tuple):
            # Each row may carry a more specific target pin than the matrix header.
            for position, entry in enumerate(entries):
                repository = (
                    entry.get("target_repository")
                    if isinstance(entry, JsonObject)
                    else None
                )
                if isinstance(repository, JsonObject):
                    _pin(
                        record,
                        repository.get("id"),
                        repository.get("revision"),
                        f"/entries/{position}/target_repository",
                        targets,
                        collector,
                    )


def _transport(
    inputs: RevisionInputs, record: ArtifactRecord, collector: FindingCollector
) -> None:
    """Check every transported artifact/payload hash and size against captured bytes."""
    imported = record.kind == "source-snapshot-manifest"
    root = record.artifact.path.rsplit("/", 1)[0] + "/" if imported else ""
    fields = (
        ("artifacts", "payloads") if imported else ("result_files", "source_inputs")
    )
    # Manifest entries authorize no extra reads: only retained bytes can verify them.
    for name in fields:
        values = record.document.get(name)
        if not isinstance(values, tuple):
            continue
        # Check every declared entry, including unreferenced payloads.
        for position, value in enumerate(values):
            if not isinstance(value, JsonObject):
                continue
            path = string_value(value.get("path"))
            content = inputs.files.get(root + path) if path is not None else None
            if (
                content is None
                or value.get("sha256") != hashlib.sha256(content).hexdigest()
                or value.get("size") != len(content)
            ):
                collector.add(
                    reference_finding(
                        "REVISION_TRANSPORT_BYTES",
                        record,
                        f"/{name}/{position}",
                        "Transported bytes are absent or differ in hash/size.",
                    )
                )


def _source_bytes(
    inputs: RevisionInputs,
    record: ArtifactRecord,
    expected: Mapping[str, str | None],
    collector: FindingCollector,
) -> None:
    """Bind inspected inventory/implementation source rows to their pinned bytes."""
    groups = {
        "inventory-snapshot": (
            ("files", ""),
            ("components", "source"),
            ("findings", "source"),
            ("relationships", "source"),
        ),
        "coverage-ledger": (("components", ""),),
        "implementation-record": (
            ("implementation_paths", ""),
            ("test_references", "source"),
        ),
        "acceptance-specification": (("implementation_test_refs", ""),),
    }.get(record.kind, ())
    document = record.document
    owner = document.get("target_repository", document.get("repository"))
    declared_owner = owner.get("id") if isinstance(owner, JsonObject) else owner
    allowed = dict(expected)
    if record.artifact.origin_path is not None:
        allowed[record.repository] = record.artifact.repository.revision
    if isinstance(declared_owner, str) and declared_owner in allowed:
        allowed = {declared_owner: allowed[declared_owner]}
    # Explicit core source groups exclude arbitrary extension and report content.
    for name, child in groups:
        values = document.get(name)
        if not isinstance(values, tuple):
            continue
        # Excluded inventory rows make no inspected-byte claim.
        for position, value in enumerate(values):
            if not isinstance(value, JsonObject) or (
                name == "files" and value.get("status") != "inspected"
            ):
                continue
            source = value.get(child) if child else value
            if not isinstance(source, JsonObject):
                continue
            pointer = f"/{name}/{position}" + (f"/{child}" if child else "")
            repository = source.get("repository", declared_owner)
            revision = source.get("revision", document.get("revision"))
            path = string_value(source.get("path"))
            _pin(record, repository, revision, pointer, allowed, collector)
            content = inputs.content(
                record,
                repository=string_value(repository) or "",
                revision=string_value(revision),
                path=path or "",
                immutable=True,
            )
            digest = source.get(
                "source_sha256" if record.kind == "coverage-ledger" else "sha256"
            )
            if (
                content is None
                or digest != hashlib.sha256(content).hexdigest()
                or ("size" in source and source["size"] != len(content))
            ):
                collector.add(
                    reference_finding(
                        "REVISION_SOURCE_HASH",
                        record,
                        pointer,
                        "Inspected source hash/size differs from immutable bytes.",
                    )
                )


def validate_revisions(
    snapshot: DiscoverySnapshot, *, index: ReferenceIndex | None = None
) -> RevisionValidation:
    """Validate supplied snapshot integrity with no I/O or remote freshness claim.

    Reuse a caller's typed index when available. Findings describe present claims;
    empty draft collections do not invent a completion or a current remote pin.
    """
    index = index or index_references(snapshot)
    collector = FindingCollector(limit=snapshot.profile.limits.parse_limits().findings)
    inputs = RevisionInputs(snapshot)
    source_pins, target_pins = repository_pins(snapshot.profile)
    # Preserve role membership even when a combined repository appears in both maps.
    sources = {item.id: item.revision for item in source_pins}
    targets = {item.id: item.revision for item in target_pins}
    _selected(inputs, collector)
    _references(inputs, index, sources, targets, collector)
    # Every captured structured declaration is checked, including unreferenced imports.
    for record in index.records:
        _declarations(record, {**sources, **targets}, sources, targets, collector)
        _source_bytes(inputs, record, {**sources, **targets}, collector)
        if record.kind in {"source-snapshot-manifest", "extension-result-manifest"}:
            _transport(inputs, record, collector)
    return RevisionValidation(collector.findings)
