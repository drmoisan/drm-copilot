"""Load a complete configured workspace without assigning graph-rule outcomes.

The catalog determines expected schemas; profile locations determine file roles.
Unrecognized artifact files remain captured and produce blocking findings.
"""

from __future__ import annotations

from fnmatch import fnmatchcase
from pathlib import PurePosixPath
from typing import TYPE_CHECKING, cast

from drm_copilot_discovery.catalog import load_catalog
from drm_copilot_discovery.findings import Finding, FindingCollector
from drm_copilot_discovery.models import JsonObject
from drm_copilot_discovery.parsing import parse_document
from drm_copilot_discovery.path_models import PathPolicyError, relative_path
from drm_copilot_discovery.path_policy import FILE_KEYS
from drm_copilot_discovery.repository_reader import RepositoryIdentity
from drm_copilot_discovery.schema_validation import validate_document
from drm_copilot_discovery.snapshot import (
    ArtifactSnapshot,
    DiscoverySnapshot,
    InputManifest,
    SnapshotFile,
    repository_pins,
)
from drm_copilot_discovery.snapshot_io import (
    document_format,
    load_profile_inputs,
    within_roots,
)

if TYPE_CHECKING:
    from drm_copilot_discovery.catalog import SchemaCatalog
    from drm_copilot_discovery.profile_models import ArtifactKey
    from drm_copilot_discovery.profile_v2 import ProfileV2
    from drm_copilot_discovery.repository_reader import RepositoryFile, RepositoryReader
    from drm_copilot_discovery.snapshot import InputCategory
    from drm_copilot_discovery.snapshot_io import SnapshotIO

_KINDS: tuple[tuple[ArtifactKey, str], ...] = (
    ("scope", "scope"),
    ("coverage_ledger", "coverage-ledger"),
    ("unspecified_behaviors", "unspecified-behavior-collection"),
    ("product_decisions", "product-decision-collection"),
    ("parity_matrix", "parity-matrix"),
    ("feature_contracts", "feature-contract"),
    ("characterization", "runtime-characterization-scenario"),
    ("evidence", "evidence-reference"),
    ("inventory", "inventory-snapshot"),
    ("acceptance", "acceptance-specification"),
    ("implementation_records", "implementation-record"),
)
_REPORTS = frozenset(
    {"coverage-report", "parity-report", "completion-report", "validation-report"}
)


class _Loader:
    """Coordinate one bounded load while keeping mutable state private to the call."""

    def __init__(
        self,
        io: SnapshotIO,
        profile: ProfileV2,
        catalog: SchemaCatalog,
        categories: dict[str, InputCategory],
        repository: RepositoryReader | None,
    ) -> None:
        """Keep one catalog and exact original inputs throughout artifact validation."""
        self.io, self.profile, self.catalog = io, profile, catalog
        self.categories = categories
        self.repository = repository
        self.local = RepositoryIdentity(
            id=profile.repository.id, revision=profile.repository.revision
        )
        self.findings = FindingCollector()
        self.artifacts: dict[str, ArtifactSnapshot] = {}
        self.expected: dict[str, tuple[str, RepositoryIdentity, str | None]] = {}
        self.payloads: set[str] = set()
        self.git_requests: set[tuple[str, str]] = set()
        self.selected_sources: set[str] = set()
        self.valid: set[str] = set()
        self.record_findings: dict[str, tuple[Finding, ...]] = {}

    def _finding(self, code: str, path: str, message: str) -> None:
        """Retain a bounded blocking diagnostic without discarding captured bytes."""
        self.findings.add(
            Finding(
                code=code,
                message=message,
                artifact_path=path,
                next_action="Correct the input and reload the complete snapshot.",
            )
        )

    def _category(self, path: str) -> InputCategory:
        """Classify opaque selected bytes independently of their eventual claims."""
        if (
            within_roots(path, self.profile.production_roots)
            or path in self.profile.project_entry_points
        ):
            return "source"
        if within_roots(path, self.profile.test_roots):
            return "test"
        if within_roots(path, self.profile.evidence_roots):
            return "evidence"
        return "documentation"

    def _read(
        self, path: str, category: InputCategory, *, required: bool = True
    ) -> bytes | None:
        """Read each input through the shared path/byte consistency boundary."""
        limit = (
            self.profile.analyzers.max_file_bytes
            if category in {"source", "test", "evidence"}
            else self.profile.limits.document_bytes
        )
        raw = self.io.read(path, limit=limit, required=required)
        if raw is not None:
            if category in {"source", "test"}:
                self.selected_sources.add(path)
            # A payload role cannot erase selected source/test input identity.
            if self.categories.get(path) not in {"source", "test"}:
                self.categories[path] = category
        return raw

    def _expect(
        self,
        path: str,
        kind: str,
        repository: RepositoryIdentity,
        origin: str | None = None,
    ) -> None:
        """Reject conflicting role declarations instead of picking an input's schema."""
        value = (kind, repository, origin)
        if path in self.expected and self.expected[path] != value:
            self._finding(
                "SNAPSHOT_ROLE_CONFLICT",
                path,
                "One file has conflicting artifact roles.",
            )
        else:
            self.expected[path] = value

    def _classify(self, path: str) -> None:
        """Assign structured expectations from configured locations and fixed names."""
        if path in self.categories:
            return
        suffix = PurePosixPath(path).suffix
        # Explicit containers precede directory roles and opaque documentation.
        if path in self.profile.analyzers.extension_result_manifests:
            self._expect(path, "extension-result-manifest", self.local)
        elif within_roots(path, (self.profile.artifacts["source_snapshots"],)):
            if PurePosixPath(path).name == "manifest.json":
                self._expect(path, "source-snapshot-manifest", self.local)
        elif within_roots(path, (self.profile.artifacts["reports"],)):
            stem = PurePosixPath(path).stem
            if stem in _REPORTS and suffix == ".json":
                self._expect(path, stem, self.local)
            elif stem in _REPORTS and suffix == ".md":
                self.categories[path] = "documentation"
            elif (
                stem in {"migration-report", "required-output-manifest"}
                and suffix == ".json"
            ):
                self._expect(path, stem, self.local)
        else:
            # Configured directories supply kind authority, never document headers.
            for key, kind in _KINDS:
                location = self.profile.artifacts[key]
                if path == location or (
                    key not in FILE_KEYS and within_roots(path, (location,))
                ):
                    if suffix in {".json", ".yaml", ".yml"}:
                        self._expect(path, kind, self.local)
                    elif key == "acceptance" and suffix in {".md", ".feature"}:
                        self.categories[path] = "documentation"
                    return
        if (
            not within_roots(path, (self.profile.artifacts["root"],))
            and path not in self.expected
        ):
            self.categories[path] = self._category(path)

    def _parse(self, path: str) -> None:
        """Validate original bytes against the single trusted kind for this path."""
        kind, repository, origin = self.expected[path]
        categories: dict[str, InputCategory] = {
            "scope": "scope",
            "inventory-snapshot": "inventory",
            "source-snapshot-manifest": "source-snapshot",
            "extension-result-manifest": "extension-result",
        }
        category = categories.get(kind, "artifact")
        raw = cast("bytes", self._read(path, category))
        # Derived reports have pure JSON envelopes; artifact schemas stay closed.
        if kind in _REPORTS:
            parsed = parse_document(
                raw,
                format=document_format(path),
                artifact_path=path,
                limits=self.profile.limits.parse_limits(),
            )
            document, findings, valid = parsed.value, parsed.findings, parsed.ok
        else:
            checked = validate_document(
                raw,
                expected_kind=kind,
                expected_version="2.0.0",
                format=document_format(path),
                artifact_path=path,
                catalog=self.catalog,
                limits=self.profile.limits.parse_limits(),
            )
            document, findings, valid = checked.document, checked.findings, checked.ok
        self.record_findings[path] = findings
        self.artifacts[path] = ArtifactSnapshot(
            path=path,
            expected_kind=kind,
            document=document,
            repository=repository,
            origin_path=origin,
        )
        if valid:
            self.valid.add(path)

    def _manifest(self, artifact: ArtifactSnapshot) -> None:
        """Expand validated local manifest entries within declared roots."""
        document = cast("JsonObject", artifact.document)
        imported = artifact.expected_kind == "source-snapshot-manifest"
        parent = str(PurePosixPath(artifact.path).parent)
        repository = self.local
        if imported:
            source = cast("JsonObject", document["source_repository"])
            repository = RepositoryIdentity(
                id=cast("str", source["id"]), revision=cast("str", source["revision"])
            )
        # Manifest entries are data, never executable adapter/plugin instructions.
        for entry in cast(
            "tuple[JsonObject, ...]",
            document["artifacts" if imported else "result_files"],
        ):
            origin = cast("str", entry["path"])
            path = f"{parent}/{origin}" if imported else origin
            relative_path(path)
            if not imported and not within_roots(
                path, (self.profile.artifacts["inventory"],)
            ):
                self._finding(
                    "SNAPSHOT_INPUT_SCOPE",
                    artifact.path,
                    "Extension results must stay in the configured inventory root.",
                )
                continue
            self._expect(
                path,
                cast("str", entry["artifact_kind"]),
                repository,
                origin if imported else None,
            )
        # Imported payloads stay under their manifest; extension inputs stay local.
        for entry in cast(
            "tuple[JsonObject, ...]",
            document["payloads" if imported else "source_inputs"],
        ):
            path = cast("str", entry["path"])
            if imported:
                self.payloads.add(relative_path(f"{parent}/{path}"))
            elif (
                within_roots(
                    path, self.profile.production_roots + self.profile.test_roots
                )
                or path in self.profile.project_entry_points
            ):
                self._read(path, self._category(path))
            else:
                self._finding(
                    "SNAPSHOT_INPUT_SCOPE",
                    artifact.path,
                    "Extension source inputs must use configured source/test paths.",
                )

    def _evidence(self, artifact: ArtifactSnapshot) -> None:
        """Capture payloads and request only explicitly local Git evidence."""
        document = cast("JsonObject", artifact.document)
        path = document.get("path")
        revision = document.get("revision")
        imported_base = (
            artifact.path[: -len(artifact.origin_path)] if artifact.origin_path else ""
        )
        # Imported bytes stay in transport storage; only local source/test pins use Git.
        if isinstance(path, str):
            if imported_base:
                self.payloads.add(imported_base + path)
            elif document.get("repository") == self.local.id:
                self._read(path, self._category(path), required=False)
                if isinstance(revision, str) and document.get("evidence_type") in {
                    "source",
                    "test",
                }:
                    self.git_requests.add((revision, path))
                elif document.get("evidence_type") not in {"source", "test"}:
                    self.payloads.add(path)
        runtime = document.get("runtime_artifact")
        if isinstance(runtime, JsonObject):
            self.payloads.add(imported_base + cast("str", runtime["path"]))

    def load(self) -> DiscoverySnapshot:
        """Enumerate configured inputs before returning an immutable snapshot."""
        # Imported manifests must stay in the configured transport root before reads.
        for item in self.profile.repositories:
            if item.snapshot_manifest is not None and not within_roots(
                item.snapshot_manifest, (self.profile.artifacts["source_snapshots"],)
            ):
                raise PathPolicyError(
                    "SNAPSHOT_IMPORT_ROOT",
                    item.snapshot_manifest,
                    "Use the configured source snapshot root.",
                )
        roots = (
            self.profile.production_roots
            + self.profile.test_roots
            + self.profile.documentation_roots
            + self.profile.evidence_roots
            + self.profile.project_entry_points
        )
        roots += tuple(
            cast("str", path) for path in self.profile.artifacts.data.values()
        )
        roots += self.profile.analyzers.extension_result_manifests
        roots += tuple(
            item.snapshot_manifest
            for item in self.profile.repositories
            if item.snapshot_manifest is not None
        )
        exclusions = self.profile.excluded_paths + self.profile.analyzers.ignored_paths

        def excluded(path: str) -> bool:
            """Apply explicit exclusions only to source/test scan selection."""
            return within_roots(
                path, self.profile.production_roots + self.profile.test_roots
            ) and any(
                fnmatchcase(path, cast("str", entry["path_or_glob"]))
                for entry in exclusions
            )

        paths = self.io.enumerate(roots, exclude=excluded)
        # Manifest entries bind the transported files' expected kinds.
        for path in paths:
            self._classify(path)
        # Explicit source links may select a non-default local manifest filename.
        for item in self.profile.repositories:
            if item.snapshot_manifest is not None and item.snapshot_manifest in paths:
                self._expect(
                    item.snapshot_manifest, "source-snapshot-manifest", self.local
                )
        # Expand validated containers without trusting nested manifests recursively.
        for path, (kind, _, _) in tuple(sorted(self.expected.items())):
            if kind in {"source-snapshot-manifest", "extension-result-manifest"}:
                self._parse(path)
                if path in self.valid:
                    self._manifest(self.artifacts[path])
        # Evidence records identify opaque payloads before unknown-file diagnostics.
        for path in sorted(self.expected):
            if path not in self.artifacts:
                self._parse(path)
            if path in self.valid and self.expected[path][0] == "evidence-reference":
                self._evidence(self.artifacts[path])
        # Resolve ambiguous JSON/YAML payload roles only after valid claims are known.
        for path in sorted(self.payloads):
            artifact = self.artifacts.get(path)
            if (
                artifact is not None
                and artifact.expected_kind == "evidence-reference"
                and path not in self.valid
                and (
                    artifact.document is None
                    or not ({"artifact_kind", "$schema"} & artifact.document.keys())
                )
            ):
                # Referenced JSON/YAML is opaque unless it claims an artifact role.
                del (
                    self.expected[path],
                    self.artifacts[path],
                    self.record_findings[path],
                )
            if path in self.expected:
                self._finding(
                    "SNAPSHOT_ROLE_CONFLICT",
                    path,
                    "A structured artifact cannot also be an opaque evidence payload.",
                )
            else:
                self._read(path, "evidence")
        # Only genuine structured artifacts contribute deferred schema diagnostics.
        for findings in self.record_findings.values():
            # Preserve each actual artifact diagnostic after opaque payload removal.
            for finding in findings:
                self.findings.add(finding)
        # Capture even unrecognized files; failure cannot erase them from the manifest.
        for path in paths:
            if path not in self.categories:
                self._finding(
                    "SNAPSHOT_UNRECOGNIZED",
                    path,
                    "Unrecognized file in a configured artifact location.",
                )
                self._read(path, "artifact")
            else:
                self._read(path, self.categories[path])
        checkout, objects = self._git()
        self.io.verify_unchanged()
        sources, targets = repository_pins(self.profile)
        return DiscoverySnapshot(
            profile=self.profile,
            catalog=self.catalog,
            manifest=InputManifest(
                files=tuple(
                    SnapshotFile(path=path, content=raw, category=self.categories[path])
                    for path, raw in self.io.captured
                ),
                missing_paths=self.io.missing_paths,
                source_repositories=sources,
                target_repositories=targets,
            ),
            artifacts=tuple(self.artifacts.values()),
            repository_files=objects,
            checkout=checkout,
            excluded_paths=self.io.excluded_paths,
            findings=self.findings.findings,
        )

    def _git(self) -> tuple[RepositoryIdentity | None, tuple[RepositoryFile, ...]]:
        """Capture pinned local objects; later rules assess historical freshness."""
        if self.repository is None:
            return None, ()
        checkout = self.repository.identity()
        if checkout.id != self.local.id:
            raise ValueError(
                "Git reader identity disagrees with the configured local repository"
            )
        if self.local.revision is not None:
            # Selected source/test hashes use the same stored bytes as later analyzers.
            for path in self.selected_sources:
                self.git_requests.add((self.local.revision, path))
        objects: list[RepositoryFile] = []
        # Validate every returned identity against the exact pinned request.
        for revision, path in sorted(self.git_requests):
            item = self.repository.read_file(
                revision=revision,
                path=path,
                limit=self.profile.analyzers.max_file_bytes,
            )
            if (
                item.repository
                != RepositoryIdentity(id=self.local.id, revision=revision)
                or item.path != path
            ):
                raise ValueError(
                    "Git reader returned a different repository, pin, or path"
                )
            objects.append(item)
        if self.repository.identity() != checkout:
            raise OSError("Git checkout changed while loading the snapshot")
        return checkout, tuple(objects)


def load_snapshot(
    *,
    io: SnapshotIO,
    profile_path: str,
    repository: RepositoryReader | None = None,
    catalog: SchemaCatalog | None = None,
) -> DiscoverySnapshot:
    """Load one exact configured workspace; all file/Git operations are injected.

    A trusted unextended catalog may be reused across loads. Each workspace load
    shares one final pinned catalog across all artifact validations. Read/path or
    bootstrap failures raise explicitly; malformed artifacts return findings.
    """
    profile, pinned, categories = load_profile_inputs(
        io, profile_path, catalog or load_catalog()
    )
    return _Loader(io, profile, pinned, categories, repository).load()
