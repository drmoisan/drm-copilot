"""Immutable exact-byte inputs for discovery validation and later freshness checks.

Loading success describes input integrity, not discovery or parity completion.
The manifest hash uses canonical JSON plus explicit runtime/schema/policy versions.
"""

from __future__ import annotations

import hashlib
import json
from dataclasses import dataclass
from typing import TYPE_CHECKING, Literal, TypeAlias, cast

from drm_copilot_discovery.findings import ordered_findings
from drm_copilot_discovery.models import JsonObject
from drm_copilot_discovery.path_models import check_path_collisions, relative_path
from drm_copilot_discovery.repository_reader import RepositoryIdentity

if TYPE_CHECKING:
    from drm_copilot_discovery.catalog import SchemaCatalog
    from drm_copilot_discovery.findings import Finding
    from drm_copilot_discovery.profile_v2 import ProfileV2
    from drm_copilot_discovery.repository_reader import (
        RepositoryFile,
    )

InputCategory: TypeAlias = Literal[
    "profile",
    "activation",
    "scope",
    "inventory",
    "artifact",
    "evidence",
    "source-snapshot",
    "extension-schema",
    "extension-result",
    "source",
    "test",
    "documentation",
]
VERSIONS = (("runtime", "2.0.0"), ("schema", "2.0.0"), ("policy", "2.0.0"))


def _digest(value: object) -> str:
    """Hash portable canonical UTF-8 JSON with an explicit trailing newline."""
    data = json.dumps(value, sort_keys=True, separators=(",", ":"), ensure_ascii=False)
    return hashlib.sha256((data + "\n").encode("utf-8")).hexdigest()


def repository_pins(
    profile: ProfileV2,
) -> tuple[tuple[RepositoryIdentity, ...], tuple[RepositoryIdentity, ...]]:
    """Return configured source/target pins without reading any repository."""
    local = RepositoryIdentity(
        id=profile.repository.id, revision=profile.repository.revision
    )
    sources: list[RepositoryIdentity] = []
    targets: list[RepositoryIdentity] = []
    # Combined ownership deliberately contributes the same pin to both role lists.
    if profile.system.role in {"legacy-source", "combined"}:
        sources.append(local)
    if profile.system.role in {"modernization-target", "combined"}:
        targets.append(local)
    # Related repositories supply pins without neighboring reads.
    for item in profile.repositories:
        identity = RepositoryIdentity(id=item.id, revision=item.revision)
        (sources if item.role == "legacy-source" else targets).append(identity)
    return tuple(sources), tuple(targets)


@dataclass(frozen=True, kw_only=True)
class SnapshotFile:
    """Capture one local input exactly once, retaining bytes and their category."""

    path: str
    content: bytes
    category: InputCategory

    def __post_init__(self) -> None:
        """Reject unsafe names, mutable bytes, and unsupported wire categories."""
        relative_path(self.path)
        if not isinstance(cast("object", self.content), bytes):
            raise ValueError("Snapshot content must be immutable bytes")
        if self.category not in {
            "profile",
            "activation",
            "scope",
            "inventory",
            "artifact",
            "evidence",
            "source-snapshot",
            "extension-schema",
            "extension-result",
            "source",
            "test",
            "documentation",
        }:
            raise ValueError("Unsupported snapshot input category")

    @property
    def sha256(self) -> str:
        """Bind the hash to the same retained content consumed by validators."""
        return hashlib.sha256(self.content).hexdigest()

    def entry(self) -> dict[str, str | int]:
        """Return one wire manifest entry without rereading any external input."""
        return {
            "path": self.path,
            "sha256": self.sha256,
            "size": len(self.content),
            "category": self.category,
        }


@dataclass(frozen=True, kw_only=True)
class ArtifactSnapshot:
    """Bind a parsed artifact to its trusted expected kind and captured file path.

    Imported source identities are retained separately from workspace storage
    names. Schema-invalid documents remain visible with their loading findings.
    """

    path: str
    expected_kind: str
    document: JsonObject | None
    repository: RepositoryIdentity
    origin_path: str | None = None

    def __post_init__(self) -> None:
        """Reject unsafe storage/origin names and empty expected-kind declarations."""
        relative_path(self.path)
        if self.origin_path is not None:
            relative_path(self.origin_path)
        if not self.expected_kind:
            raise ValueError("An artifact requires a trusted expected kind")
        if self.document is not None and not isinstance(
            cast("object", self.document), JsonObject
        ):
            raise ValueError("Artifact documents must use immutable parsed values")


@dataclass(frozen=True, kw_only=True)
class InputManifest:
    """Describe all local bytes, expected absence, and configured repository pins.

    sha256 hashes {versions, inputs}, where inputs is to_dict without sha256.
    Versions are fixed runtime/schema/policy contracts, not document-controlled.
    """

    files: tuple[SnapshotFile, ...]
    missing_paths: tuple[str, ...] = ()
    source_repositories: tuple[RepositoryIdentity, ...] = ()
    target_repositories: tuple[RepositoryIdentity, ...] = ()

    def __post_init__(self) -> None:
        """Detach and sort values, rejecting collisions and contradictory absence."""
        object.__setattr__(
            self, "files", tuple(sorted(self.files, key=lambda f: f.path))
        )
        paths = check_path_collisions(file.path for file in self.files)
        missing = check_path_collisions(self.missing_paths)
        check_path_collisions(paths + missing)
        object.__setattr__(self, "missing_paths", missing)
        # Role lists are independent: a combined repository may appear in both.
        for field in ("source_repositories", "target_repositories"):
            identities: tuple[RepositoryIdentity, ...] = getattr(self, field)
            if len({item.id for item in identities}) != len(identities):
                raise ValueError("A repository role cannot contain duplicate IDs")
            object.__setattr__(
                self, field, tuple(sorted(identities, key=lambda x: x.id))
            )

    def _inputs(self) -> dict[str, object]:
        """Build detached transport data in deterministic ordinal path/ID order."""
        return {
            "entries": [file.entry() for file in self.files],
            "missing_paths": list(self.missing_paths),
            "source_repositories": [
                item.to_dict() for item in self.source_repositories
            ],
            "target_repositories": [
                item.to_dict() for item in self.target_repositories
            ],
        }

    @property
    def sha256(self) -> str:
        """Bind complete input bytes and pins to explicit implementation versions."""
        return _digest({"versions": dict(VERSIONS), "inputs": self._inputs()})

    def to_dict(self) -> dict[str, object]:
        """Project the closed service-result manifest without exposing mutable state."""
        return {**self._inputs(), "sha256": self.sha256}


@dataclass(frozen=True, kw_only=True)
class DiscoverySnapshot:
    """Keep exact local/Git bytes and parsed artifacts in one immutable value."""

    profile: ProfileV2
    catalog: SchemaCatalog
    manifest: InputManifest
    artifacts: tuple[ArtifactSnapshot, ...] = ()
    repository_files: tuple[RepositoryFile, ...] = ()
    checkout: RepositoryIdentity | None = None
    excluded_paths: tuple[str, ...] = ()
    findings: tuple[Finding, ...] = ()

    def __post_init__(self) -> None:
        """Freeze collections and require every parsed artifact to have raw bytes."""
        artifacts = tuple(sorted(self.artifacts, key=lambda item: item.path))
        check_path_collisions(item.path for item in artifacts)
        captured = {item.path for item in self.manifest.files}
        if any(item.path not in captured for item in artifacts):
            raise ValueError("Every parsed artifact requires captured input bytes")
        object.__setattr__(self, "artifacts", artifacts)
        objects = tuple(
            sorted(
                self.repository_files,
                key=lambda item: (
                    item.repository.id,
                    item.repository.revision or "",
                    item.path,
                ),
            )
        )
        keys = [
            (item.repository.id, item.repository.revision, item.path)
            for item in objects
        ]
        if len(set(keys)) != len(keys):
            raise ValueError("Duplicate pinned Git inputs are ambiguous")
        object.__setattr__(self, "repository_files", objects)
        object.__setattr__(
            self, "excluded_paths", check_path_collisions(self.excluded_paths)
        )
        object.__setattr__(self, "findings", ordered_findings(self.findings))

    @property
    def ok(self) -> bool:
        """Report successful input loading without asserting feature completion."""
        return not any(finding.severity == "error" for finding in self.findings)

    @property
    def sha256(self) -> str:
        """Bind manifest, selected Git objects, checkout and exclusions together."""
        return _digest(
            {
                "manifest": self.manifest.sha256,
                "checkout": None if self.checkout is None else self.checkout.to_dict(),
                "excluded_paths": self.excluded_paths,
                "repository_files": [
                    {
                        "repository": item.repository.to_dict(),
                        "path": item.path,
                        "sha256": item.sha256,
                        "size": len(item.content),
                    }
                    for item in self.repository_files
                ],
            }
        )

    def file(self, path: str) -> SnapshotFile:
        """Return captured content by exact spelling, raising for uncaptured inputs."""
        # Match exact spelling; aliases cannot select another captured file.
        for item in self.manifest.files:
            if item.path == path:
                return item
        raise KeyError(path)
