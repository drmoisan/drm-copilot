"""One injected, host-independent policy for discovery input/output locations.

Profile roots define maximum scope, never native tool authority. Controlled
writes require an exact kind/ID/path grant and fresh parent metadata. No function
opens a file, follows links, creates a directory, or commits artifact bytes.
"""

from __future__ import annotations

import re
from pathlib import PurePath, PurePosixPath, PureWindowsPath
from typing import TYPE_CHECKING, cast

from drm_copilot_discovery.path_models import (
    PathMetadata,
    PathPolicyError,
    PathStamp,
    ResolvedPath,
    WriteGrant,
    check_path_collisions,
    collision_key,
    path_contains,
    relative_path,
)
from drm_copilot_discovery.profile_v2 import ProfileV2

if TYPE_CHECKING:
    from drm_copilot_discovery.path_models import PathMetadataReader
    from drm_copilot_discovery.profile_models import ArtifactKey
    from drm_copilot_discovery.transport_manifest import TransportRoute

# Canonical native/configuration/framework locations cannot be artifact outputs.
PROTECTED_PATHS = (
    ".git",
    ".github",
    ".claude",
    ".codex",
    ".agents",
    ".vscode",
    "config",
    "schemas",
    "scripts",
    "packages",
    "extensions",
    "AGENTS.md",
    "CLAUDE.md",
    "pyproject.toml",
    "package.json",
)
FILE_KEYS = frozenset(
    {
        "profile",
        "scope",
        "coverage_ledger",
        "unspecified_behaviors",
        "product_decisions",
        "parity_matrix",
    }
)
OUTPUT_LOCATIONS: tuple[tuple[str, ArtifactKey], ...] = (
    ("scope", "scope"),
    ("coverage-ledger", "coverage_ledger"),
    ("unspecified-behavior-collection", "unspecified_behaviors"),
    ("product-decision-collection", "product_decisions"),
    ("parity-matrix", "parity_matrix"),
    ("feature-contract", "feature_contracts"),
    ("runtime-characterization-scenario", "characterization"),
    ("evidence-reference", "evidence"),
    ("evidence-payload", "evidence"),
    ("inventory-snapshot", "inventory"),
    ("extension-result-manifest", "inventory"),
    ("acceptance-specification", "acceptance"),
    ("acceptance-view", "acceptance"),
    ("implementation-record", "implementation_records"),
    ("source-snapshot-manifest", "source_snapshots"),
    ("coverage-report", "reports"),
    ("parity-report", "reports"),
    ("completion-report", "reports"),
    ("validation-report", "reports"),
    ("migration-report", "reports"),
    ("required-output-manifest", "reports"),
)


def _absolute(path: str) -> PurePath:
    """Parse a trusted absolute workspace/metadata path independently of this OS.

    Drive and UNC workspace anchors are permitted; device namespaces and dot
    traversal are not. Returned paths are lexical only, with no filesystem I/O.
    """
    spelling = path.replace("\\", "/")
    # Reject every traversal component before a pure-path parser can collapse it.
    if (
        (path.startswith("\\") and not path.startswith("\\\\"))
        or spelling.startswith(("//?", "//."))
        or any(part in (".", "..") for part in spelling.split("/"))
    ):
        raise PathPolicyError(
            "PATH_ABSOLUTE", path, "Supply a canonical absolute workspace path."
        )
    # An explicit drive or UNC anchor selects Windows semantics on every host.
    if re.match(r"^[a-zA-Z]:", spelling) or spelling.startswith("//"):
        result: PurePath = PureWindowsPath(spelling)
    else:
        result = PurePosixPath(spelling)
    if not result.is_absolute():
        raise PathPolicyError(
            "PATH_ABSOLUTE", path, "The trusted workspace must be absolute."
        )
    # Validate ordinary components without treating the trusted anchor as input.
    for part in result.parts[1:]:
        relative_path(part)
    return result


def _overlaps(left: str, right: str) -> bool:
    """Treat equality and either component-prefix direction as an overlap."""
    return path_contains(left, right) or path_contains(right, left)


def _reserved_output(path: str) -> bool:
    """Identify nested policy/native/schema names independently of root spelling."""
    # Native configuration and standing instructions remain protected at any depth.
    return any(
        part.casefold()
        in {
            ".git",
            ".github",
            ".claude",
            ".codex",
            ".agents",
            ".vscode",
            "agents.md",
            "claude.md",
            "skill.md",
        }
        or part.casefold().endswith(".schema.json")
        for part in path.split("/")
    )


class PathPolicy:
    """Apply one validated profile to trusted metadata and exact write grants.

    Construction validates lexical configuration and output separation. Call
    validate_configuration for physical root checks, resolve_read/write for one
    selected path, then revalidate_write immediately before atomic mutation.
    Only the injected reader may perform I/O. It must provide non-following
    metadata and complete child names. Every symlink/reparse entry is rejected,
    including links that currently point inside the workspace.
    """

    def __init__(
        self,
        profile: ProfileV2,
        *,
        workspace_root: str,
        metadata: PathMetadataReader,
        protected_paths: tuple[str, ...] = (),
        transport: TransportRoute | None = None,
    ) -> None:
        """Bind a validated profile and caller-owned protections; never write."""
        if not isinstance(cast("object", profile), ProfileV2):
            raise ValueError("Path policy requires a validated ProfileV2")
        self._profile = profile
        self._workspace = _absolute(workspace_root)
        self._metadata = metadata
        self._transport = transport
        # Only the parent artifact root may contain another configured output.
        self._locations = {
            cast("ArtifactKey", key): cast("str", value)
            for key, value in profile.artifacts.data.items()
        }
        self._input_directories = (
            profile.production_roots
            + profile.test_roots
            + profile.documentation_roots
            + profile.evidence_roots
        )
        self._input_files = profile.project_entry_points + ("config/discovery.json",)
        self._protected = tuple(sorted(set(PROTECTED_PATHS + protected_paths)))
        self._validate_layout()

    def _validate_layout(self) -> None:
        """Reject aliased roots, protected overlaps and sibling output nesting."""
        outputs = tuple(self._locations.items())
        check_path_collisions(self._locations.values())
        # Repeated identical input roots are harmless; alternate spellings are not.
        check_path_collisions(
            sorted(
                set(
                    self._input_directories
                    + self._input_files
                    + tuple(self._locations.values())
                    + self._protected
                )
            )
        )
        forbidden = (
            self._protected
            + self._profile.production_roots
            + self._profile.test_roots
            + self._profile.project_entry_points
        )
        # Protect declared extension schemas even inside a readable documentation root.
        extension_paths = tuple(
            cast("str", cast("dict[str, object]", entry)["path"])
            for entry in self._profile.extension_schemas.values()
        )
        # Each output must be independently separated from implementation/authority.
        for key, path in outputs:
            if _reserved_output(path) or any(
                _overlaps(path, root) for root in forbidden
            ):
                raise PathPolicyError(
                    "PATH_OUTPUT_OVERLAP",
                    path,
                    "Move artifacts outside protected or production/test paths.",
                )
            if any(_overlaps(path, schema) for schema in extension_paths):
                raise PathPolicyError(
                    "PATH_OUTPUT_OVERLAP",
                    path,
                    "Keep extension schemas outside artifact output roots.",
                )
            # Only the declared parent/root hierarchy permits overlapping outputs.
            for other_key, other in outputs:
                if key != other_key and _overlaps(path, other):
                    if key == "root" and path_contains(path, other, strict=True):
                        continue
                    if other_key == "root" and path_contains(other, path, strict=True):
                        continue
                    raise PathPolicyError(
                        "PATH_OUTPUT_OVERLAP",
                        path,
                        f"Separate artifact locations {key!r} and {other_key!r}.",
                    )

    def _inspect(self, path: str) -> PathMetadata:
        """Read one non-following entry, rejecting ambiguity, links and escapes."""
        try:
            entry = self._metadata(path)
        except OSError as error:
            raise PathPolicyError(
                "PATH_METADATA",
                path,
                "Restore readable path metadata before continuing.",
            ) from error
        if not isinstance(cast("object", entry), PathMetadata):
            raise PathPolicyError(
                "PATH_METADATA", path, "The metadata adapter returned an invalid entry."
            )
        if entry.kind in {"symlink", "reparse"}:
            raise PathPolicyError(
                "PATH_LINK",
                path,
                "Use an ordinary path without symlink or reparse ancestors.",
            )
        if entry.kind == "other":
            raise PathPolicyError(
                "PATH_TYPE", path, "Only ordinary files/directories are supported."
            )
        if entry.kind == "missing":
            return entry
        actual = _absolute(cast("str", entry.resolved_path))
        if not actual.is_relative_to(self._workspace):
            raise PathPolicyError(
                "PATH_ESCAPE",
                path,
                "Resolved metadata must remain inside the workspace.",
            )
        expected_parts = () if path == "." else tuple(path.split("/"))
        if actual.relative_to(self._workspace).parts != expected_parts:
            raise PathPolicyError(
                "PATH_ALIAS",
                path,
                "Resolved components must match exact requested spelling.",
            )
        return entry

    def _walk(
        self, path: str, *, allow_missing: bool, grant: WriteGrant | None = None
    ) -> ResolvedPath:
        """Resolve one finite ancestor chain and retain identities for rechecking."""
        relative_path(path)
        parent = self._inspect(".")
        if parent.kind != "directory":
            raise PathPolicyError(
                "PATH_WORKSPACE",
                path,
                "The workspace must be an existing ordinary directory.",
            )
        stamps = [
            PathStamp(
                path=".",
                kind=parent.kind,
                identity=parent.identity,
                resolved_path=parent.resolved_path,
            )
        ]
        identities = {parent.identity}
        parts = path.split("/")
        # Walk exact components; prefixes or platform aliases never grant access.
        for index, part in enumerate(parts):
            current = "/".join(parts[: index + 1])
            if parent.kind not in {"directory", "missing"}:
                raise PathPolicyError(
                    "PATH_TYPE",
                    current,
                    "Every ancestor must be an ordinary directory.",
                )
            # Missing suffixes are projected, never traversed or created by this policy.
            if parent.kind == "missing":
                entry = PathMetadata(kind="missing")
            else:
                check_path_collisions(parent.children)
                # Compare every sibling to detect an alternate requested spelling.
                if part not in parent.children and any(
                    collision_key(part) == collision_key(name)
                    for name in parent.children
                ):
                    raise PathPolicyError(
                        "PATH_ALIAS",
                        current,
                        "Use the exact existing component spelling.",
                    )
                entry = self._inspect(current)
                if (part in parent.children) != (entry.kind != "missing"):
                    raise PathPolicyError(
                        "PATH_METADATA_CHANGED",
                        current,
                        "Directory enumeration and entry inspection disagree; reload.",
                    )
            if entry.identity is not None:
                if entry.identity in identities:
                    raise PathPolicyError(
                        "PATH_CYCLE",
                        current,
                        "An ancestor identity repeats; remove the cyclic alias.",
                    )
                identities.add(entry.identity)
            stamps.append(
                PathStamp(
                    path=current,
                    kind=entry.kind,
                    identity=entry.identity,
                    resolved_path=entry.resolved_path,
                )
            )
            parent = entry
        if parent.kind == "missing" and not allow_missing:
            raise PathPolicyError(
                "PATH_MISSING",
                path,
                "Supply the configured input or record its absence explicitly.",
            )
        return ResolvedPath(
            path=path,
            absolute_path=self._workspace.joinpath(*parts).as_posix(),
            observations=tuple(stamps),
            grant=grant,
        )

    def validate_configuration(self) -> tuple[ResolvedPath, ...]:
        """Inspect configured inputs/outputs, retaining honest missing directories.

        Missing inputs are returned as missing, never inferred elsewhere. Every
        existing configured directory/file must have its declared kind. Pure
        policy invokes only the injected metadata reader and performs no writes.
        """
        expected: dict[str, str] = {}
        # Merge identical directory declarations while retaining each exact path.
        for path in self._input_directories:
            expected[path] = "directory"
        # Exact input files must not alias directory declarations.
        for path in self._input_files:
            if path in expected:
                raise PathPolicyError(
                    "PATH_TYPE", path, "One path cannot be both a file and a directory."
                )
            expected[path] = "file"
        # Artifact declarations contribute their explicit file/directory shapes.
        for key, path in self._locations.items():
            kind = "file" if key in FILE_KEYS else "directory"
            if path in expected and expected[path] != kind:
                raise PathPolicyError(
                    "PATH_TYPE", path, "Conflicting configured path kinds."
                )
            expected[path] = kind
        resolved: list[ResolvedPath] = []
        # Stable ordering keeps root diagnostics independent of input order.
        for path, kind in sorted(expected.items()):
            result = self._walk(path, allow_missing=True)
            if result.observations[-1].kind not in {kind, "missing"}:
                raise PathPolicyError(
                    "PATH_TYPE", path, f"Configure an ordinary {kind} at this location."
                )
            resolved.append(result)
        return tuple(resolved)

    def resolve_read(self, path: str, *, allow_missing: bool = False) -> ResolvedPath:
        """Resolve configured read scope, optionally recording explicit absence."""
        relative_path(path)
        # Directory declarations admit descendants; exact files never do.
        directories = self._input_directories + tuple(
            value for key, value in self._locations.items() if key not in FILE_KEYS
        )
        # Collect only declared single-file artifact/input locations.
        files = self._input_files + tuple(
            value for key, value in self._locations.items() if key in FILE_KEYS
        )
        # Permissions use exact spelling; conservative folded keys only detect aliases.
        if path not in files and not any(
            path == root or path.startswith(root + "/") for root in directories
        ):
            raise PathPolicyError(
                "PATH_READ_DENIED",
                path,
                "Select an explicitly configured input or artifact path.",
            )
        return self._walk(path, allow_missing=allow_missing)

    def resolve_write(self, path: str, *, grant: WriteGrant) -> ResolvedPath:
        """Resolve one exact artifact grant; profile/native/production writes fail."""
        relative_path(path)
        if path != grant.path:
            raise PathPolicyError(
                "PATH_GRANT",
                path,
                "Use the grant's exact path; roots do not grant writes.",
            )
        # Closed kind-to-location routing excludes configuration and authority kinds.
        location = next(
            (key for kind, key in OUTPUT_LOCATIONS if kind == grant.artifact_kind), None
        )
        if location is None and self._transport is None:
            raise PathPolicyError(
                "PATH_GRANT",
                path,
                "This artifact kind has no controlled write location.",
            )
        if self._transport is not None:
            # Only the root-owned mutation route supplies a reconstructed transport.
            allowed = self._transport.allows(
                grant, root=self._locations["source_snapshots"]
            )
        else:
            root = self._locations[cast("ArtifactKey", location)]
            allowed = (
                path == root if location in FILE_KEYS else path.startswith(root + "/")
            )
        if not allowed or _reserved_output(path):
            raise PathPolicyError(
                "PATH_WRITE_DENIED",
                path,
                "Use the artifact kind's exact configured file or child location.",
            )
        result = self._walk(path, allow_missing=True, grant=grant)
        if result.observations[-1].kind == "directory":
            raise PathPolicyError(
                "PATH_TYPE", path, "An artifact write cannot replace a directory."
            )
        return result

    def revalidate_write(self, previous: ResolvedPath) -> ResolvedPath:
        """Reject replaced parents/leaves or new aliases immediately before commit.

        The later I/O layer must combine this check with exclusive creation or
        digest-matched atomic replacement and handle races at the OS boundary.
        Content hashes and native authorization are deliberately not inferred.
        """
        if previous.grant is None:
            raise PathPolicyError(
                "PATH_GRANT", previous.path, "A read result cannot authorize a write."
            )
        current = self.resolve_write(previous.path, grant=previous.grant)
        if current != previous:
            raise PathPolicyError(
                "PATH_CHANGED",
                previous.path,
                "Path identities changed; reload and rebuild the mutation plan.",
            )
        return current
