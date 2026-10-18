"""Index trusted snapshot identities and resolve core links without external reads.

Repository/kind namespaces preserve imported ownership. Schema-directed traversal
excludes arbitrary extension and action payloads; revision/hash truth is separate.
"""

from __future__ import annotations

from collections import defaultdict
from dataclasses import dataclass, field, replace
from types import MappingProxyType
from typing import TYPE_CHECKING

from drm_copilot_discovery.catalog import V2_URN
from drm_copilot_discovery.findings import Finding, FindingCollector, child_pointer
from drm_copilot_discovery.models import JsonObject, JsonValue
from drm_copilot_discovery.reference_links import (
    reference_finding,
    schema_references,
    string_value,
    validate_linkage,
)
from drm_copilot_discovery.transport_manifest import replica_aliases

if TYPE_CHECKING:
    from collections.abc import Iterator, Mapping

    from drm_copilot_discovery.snapshot import ArtifactSnapshot, DiscoverySnapshot

_ALIASES = {
    "feature-contract": "feature_id",
    "runtime-characterization-scenario": "scenario_id",
    "acceptance-specification": "scenario_id",
    "evidence-reference": "evidence_id",
    "product-decision": "decision_id",
    "unspecified-behavior": "behavior_id",
}
_COLLECTIONS = {
    "product-decision-collection": "product-decision",
    "unspecified-behavior-collection": "unspecified-behavior",
}
_LOCAL_IDS = {
    "components": "component_id",
    "findings": "finding_id",
    "relationships": "relationship_id",
    "diagnostics": "id",
    "entries": "id",
    "runs": "id",
    "observation_plan": "id",
    "acceptance_criteria": "id",
    "resulting_acceptance_criteria": "id",
    "competing_interpretations": "id",
    "alternatives": "id",
}


@dataclass(frozen=True, kw_only=True)
class ArtifactRecord:
    """Locate one artifact or collection member in its trusted repository."""

    artifact: ArtifactSnapshot
    kind: str
    document: JsonObject
    pointer: str = ""

    @property
    def id(self) -> str:
        """Expose the artifact ID after identity validation has succeeded."""
        return str(self.document["id"])

    @property
    def repository(self) -> str:
        """Use captured ownership rather than a document-selected namespace."""
        return self.artifact.repository.id

    @property
    def path(self) -> str:
        """Resolve foreign references against original repository-relative paths."""
        return self.artifact.origin_path or self.artifact.path


@dataclass(frozen=True, kw_only=True)
class ReferenceResolution:
    """Retain each authored link and either its unique target or blocking finding."""

    source: ArtifactRecord
    pointer: str
    reference: JsonObject
    target: ArtifactRecord | None
    findings: tuple[Finding, ...] = ()


@dataclass(frozen=True, kw_only=True)
class ReferenceIndex:
    """Provide immutable kind/ID lookups and deterministic graph diagnostics."""

    records: tuple[ArtifactRecord, ...]
    findings: tuple[Finding, ...] = ()
    links: tuple[ReferenceResolution, ...] = ()
    replicas: tuple[tuple[str, ArtifactRecord], ...] = ()
    identities: Mapping[tuple[str, str, str], tuple[ArtifactRecord, ...]] = field(
        init=False, repr=False, compare=False
    )

    def __post_init__(self) -> None:
        """Freeze lookup buckets while preserving duplicates for explicit rejection."""
        buckets: dict[tuple[str, str, str], list[ArtifactRecord]] = defaultdict(list)
        # Artifact IDs and domain IDs are distinct namespaces, even when equal.
        for record in self.records:
            # Preserve both identities without entering the same record twice.
            for name in ("id", _ALIASES.get(record.kind, "id")):
                identifier = string_value(record.document.get(name))
                if identifier is not None:
                    key = record.kind, name, identifier
                    if record not in buckets[key]:
                        buckets[key].append(record)
        object.__setattr__(self, "records", tuple(self.records))
        object.__setattr__(self, "findings", tuple(self.findings))
        object.__setattr__(self, "links", tuple(self.links))
        object.__setattr__(self, "replicas", tuple(self.replicas))
        object.__setattr__(
            self,
            "identities",
            MappingProxyType({key: tuple(value) for key, value in buckets.items()}),
        )

    def candidates(
        self,
        kind: str,
        identifier: str,
        *,
        repository: str | None = None,
        identity_field: str = "id",
    ) -> tuple[ArtifactRecord, ...]:
        """Select an exact case-sensitive namespace without preferring local IDs."""
        # Explicit ownership narrows a namespace; omission preserves ambiguity.
        return tuple(
            item
            for item in self.identities.get((kind, identity_field, identifier), ())
            if repository is None or item.repository == repository
        )

    def resolve(
        self,
        reference: JsonObject,
        *,
        source: ArtifactRecord,
        pointer: str,
        expected_kind: str | None = None,
        repository: str | None = None,
        transport: bool = False,
    ) -> ReferenceResolution:
        """Resolve both common artifact links and immutable source-contract links.

        Pins/hashes remain in the retained reference for later integrity rules.
        An explicit path must agree with the selected ID, kind and repository.
        """
        source_contract = "feature_id" in reference and "artifact_path" in reference
        name = "feature_id" if source_contract else "id"
        kind, identifier = string_value(reference.get("artifact_kind")), string_value(
            reference.get(name)
        )
        owner = (
            string_value(
                reference.get("repository_id" if source_contract else "repository")
            )
            or repository
        )
        path = string_value(
            reference.get("artifact_path" if source_contract else "path")
        )
        candidates = self.candidates(
            kind or "", identifier or "", repository=owner, identity_field=name
        )
        if len(candidates) == 1 and (source_contract or transport):
            candidates = self._replica_targets(
                candidates[0], source=source, transport=transport
            )
        code: str | None = None
        # A typed field cannot select a different kind even when that target exists.
        if kind is None or identifier is None:
            code = "REFERENCE_INVALID"
        elif expected_kind is not None and kind != expected_kind:
            code = "REFERENCE_KIND"
        elif len(candidates) > 1:
            code = "REFERENCE_AMBIGUOUS"
        elif not candidates:
            # Distinguish an existing wrong-kind ID from absent required context.
            wrong_kind = tuple(
                item
                for item in self.records
                if item.document.get(name) == identifier
                and (owner is None or item.repository == owner)
            )
            code = "REFERENCE_KIND" if wrong_kind else "REFERENCE_MISSING"
        elif path is not None and candidates[0].path != path:
            code = "REFERENCE_PATH"
        # Transport entries describe whole files, not a member hidden in a collection.
        elif transport and candidates[0].pointer:
            code = "REFERENCE_PATH"
        findings = (
            ()
            if code is None
            else (
                reference_finding(
                    code,
                    source,
                    pointer,
                    f"Reference {kind}/{identifier} requires one matching artifact "
                    f"in repository {owner or '<unspecified>'}.",
                    candidates,
                ),
            )
        )
        return ReferenceResolution(
            source=source,
            pointer=pointer,
            reference=reference,
            target=next(iter(candidates)) if code is None else None,
            findings=findings,
        )

    def _replica_targets(
        self, target: ArtifactRecord, *, source: ArtifactRecord, transport: bool
    ) -> tuple[ArtifactRecord, ...]:
        """Select physical imported bytes only within a proven equivalence group.

        Ordinary candidates retain local mutation identity. Manifest rows select
        their own physical member; source links use a deterministic proven copy.
        Different bytes, pins or unbound duplicates never enter this group.
        """
        # Only manifest-proven physical aliases justify context-specific selection.
        copies = tuple(
            record
            for representative, record in self.replicas
            if representative == target.artifact.path
            and record.pointer == target.pointer
        )
        if not copies:
            return (target,)
        # An imported representative joins its proven aliases, not a synthetic group.
        if target.artifact.origin_path is not None:
            copies = (*copies, target)
        # A manifest selects its own member; source-contract links select a proven copy.
        if transport and source.kind == "source-snapshot-manifest":
            path = source.artifact.path.rsplit("/", 1)[0] + "/" + target.path
            # Other equivalent exports cannot satisfy this manifest's physical entry.
            return tuple(record for record in copies if record.artifact.path == path)
        return (min(copies, key=lambda record: record.artifact.path),)


def _records(
    artifact: ArtifactSnapshot, collector: FindingCollector, pointer: str = ""
) -> Iterator[ArtifactRecord]:
    """Expand only the two declared collections into ordinary artifact namespaces."""
    document = artifact.document
    if document is None:
        return
    record = ArtifactRecord(
        artifact=artifact,
        kind=artifact.expected_kind,
        document=document,
        pointer=pointer,
    )
    # Identityless derived reports cannot satisfy artifact references.
    if "artifact_kind" not in document and "id" not in document:
        return
    if document.get("artifact_kind") != artifact.expected_kind:
        collector.add(
            reference_finding(
                "ARTIFACT_KIND",
                record,
                child_pointer(pointer, "artifact_kind"),
                "Declared kind differs from the trusted path kind.",
            )
        )
        return
    if not isinstance(document.get("id"), str):
        collector.add(
            reference_finding(
                "ARTIFACT_ID",
                record,
                child_pointer(pointer, "id"),
                "An artifact requires a string ID.",
            )
        )
        return
    yield record
    member_kind = _COLLECTIONS.get(record.kind)
    members = document.get("records")
    if member_kind is not None and isinstance(members, tuple):
        # Members inherit container ownership and the schema-selected record kind.
        for position, member in enumerate(members):
            if isinstance(member, JsonObject):
                # Reuse header validation while retaining the physical container.
                for nested in _records(
                    replace(artifact, expected_kind=member_kind, document=member),
                    collector,
                    f"/records/{position}",
                ):
                    yield replace(nested, artifact=artifact)


def _duplicates(index: ReferenceIndex, collector: FindingCollector) -> None:
    """Reject repository/kind duplicates and repeated record IDs within each list."""
    # All identity aliases are checked independently, preserving cross-kind reuse.
    for (_, field_name, identifier), records in index.identities.items():
        repositories = sorted({item.repository for item in records})
        # Reuse of one ID in another repository is legitimate until referenced bare.
        for repository in repositories:
            matches = tuple(item for item in records if item.repository == repository)
            if len(matches) > 1:
                # Report each conflicting declaration with the same candidate set.
                for record in matches:
                    collector.add(
                        reference_finding(
                            "DUPLICATE_ID",
                            record,
                            child_pointer(record.pointer, field_name),
                            f"Duplicate {record.kind}/{field_name} identity "
                            f"{identifier} in {repository}.",
                            matches,
                        )
                    )
    # Nested IDs belong to their containing artifact/list, not to global artifacts.
    for record in index.records:
        _local_duplicates(record.document, record, record.pointer, collector)


def _local_duplicates(
    value: JsonValue, record: ArtifactRecord, pointer: str, collector: FindingCollector
) -> None:
    """Check named record collections while excluding arbitrary extension data."""
    if not isinstance(value, JsonObject):
        return
    # Only core record lists carry local uniqueness obligations.
    for key, children in value.items():
        if key in {"extensions", "value", "records"}:
            continue
        if isinstance(children, tuple):
            seen: set[str] = set()
            # Distinct row content must not conceal repeated stable identities.
            for position, child in enumerate(children):
                location = child_pointer(child_pointer(pointer, key), position)
                if isinstance(child, JsonObject):
                    name = _LOCAL_IDS.get(key)
                    identifier = (
                        string_value(child.get(name)) if name is not None else None
                    )
                    if identifier is not None:
                        if identifier in seen:
                            collector.add(
                                reference_finding(
                                    "DUPLICATE_RECORD_ID",
                                    record,
                                    child_pointer(location, name or "id"),
                                    f"Duplicate record identity {identifier} in {key}.",
                                )
                            )
                        seen.add(identifier)
                    _local_duplicates(child, record, location, collector)
        elif isinstance(children, JsonObject):
            _local_duplicates(children, record, child_pointer(pointer, key), collector)


def index_references(snapshot: DiscoverySnapshot) -> ReferenceIndex:
    """Build a pure immutable graph with bounded diagnostics over all present input."""
    collector = FindingCollector(limit=snapshot.profile.limits.parse_limits().findings)
    # Loading failures remain blockers even when no identities can be extracted.
    for finding in snapshot.findings:
        collector.add(finding)
    # Flatten configured documents and permitted collection members exactly once.
    aliases = replica_aliases(snapshot)
    # Canonical enumeration preserves logical uniqueness without dropping raw inputs.
    records = tuple(
        record
        for artifact in snapshot.artifacts
        if artifact.path not in aliases
        for record in _records(artifact, collector)
    )
    # Retain each proven physical replica for path-keyed outgoing-link checks.
    replicas = tuple(
        (aliases[artifact.path], record)
        for artifact in snapshot.artifacts
        if artifact.path in aliases
        for record in _records(artifact, collector)
    )
    index = ReferenceIndex(records=records, replicas=replicas)
    _duplicates(index, collector)
    schemas = dict(snapshot.catalog.documents)
    links: dict[tuple[str, str], ReferenceResolution] = {}
    # Physical replicas need outgoing links for later path-keyed provenance checks.
    # Their common links retain canonical targets and existing evidence assessments.
    for record in records + tuple(record for _, record in replicas):
        if record.kind in _COLLECTIONS:
            continue
        # Trusted schemas select reference fields, not authored payload key names.
        for pointer, reference, expected, wire_kind in schema_references(
            record.document,
            schemas[V2_URN + record.kind],
            schemas,
            base=V2_URN + record.kind,
            pointer=record.pointer,
        ):
            repository = None
            transport = wire_kind in {
                "source-snapshot-manifest",
                "extension-result-manifest",
            }
            # Manifest rows inherit the repository named by their transport header.
            if transport:
                owner = record.document.get(
                    "source_repository"
                    if wire_kind == "source-snapshot-manifest"
                    else "repository"
                )
                repository = (
                    string_value(owner.get("id"))
                    if isinstance(owner, JsonObject)
                    else None
                )
            resolution = index.resolve(
                reference,
                source=record,
                pointer=pointer,
                expected_kind=expected,
                repository=repository,
                transport=transport,
            )
            links[(record.artifact.path, pointer)] = resolution
            # Bounded collection keeps every emitted blocker deterministically ordered.
            for finding in resolution.findings:
                collector.add(finding)
    index = replace(index, links=tuple(links[key] for key in sorted(links)))
    validate_linkage(index, collector)
    return replace(index, findings=collector.findings)
