"""Bounded snapshot reads through injected workspace-relative byte/metadata seams.

Native adapters must anchor each open to the selected workspace, reject links,
and enforce the requested byte limit while reading. This layer checks metadata,
configured authority, complete enumeration, and consistency across the load.
"""

from __future__ import annotations

import heapq
from dataclasses import replace
from pathlib import PurePosixPath, PureWindowsPath
from typing import TYPE_CHECKING, Literal, Protocol, cast

from drm_copilot_discovery.activation_models import ActivationLocator
from drm_copilot_discovery.catalog import ExtensionSchema, SchemaCatalog
from drm_copilot_discovery.models import JsonObject
from drm_copilot_discovery.path_models import (
    PathMetadata,
    PathPolicyError,
    check_path_collisions,
    relative_path,
)
from drm_copilot_discovery.path_policy import PathPolicy
from drm_copilot_discovery.profile_v2 import ProfileError, ProfileV2
from drm_copilot_discovery.schema_validation import validate_document

if TYPE_CHECKING:
    from collections.abc import Callable, Iterable

    from drm_copilot_discovery.path_models import PathMetadataReader
    from drm_copilot_discovery.snapshot import InputCategory


class WorkspaceBytes(Protocol):
    """Read only ordinary local files using non-following, workspace-anchored opens.

    Implementations must bound allocation by limit and raise OSError for read,
    containment or size failures. They may not fetch remote content or follow
    links. The test implementation is an isolated dictionary of immutable bytes.
    """

    def __call__(self, path: str, *, limit: int) -> bytes:
        """Return exact bytes at a relative path, or fail without partial success."""
        ...


class SnapshotIO:
    """Capture one stable local input set, then freeze it in a DiscoverySnapshot.

    Construct a fresh instance per load. Bootstrap reads accept only the explicit
    profile/locator/schema paths supplied by the loader. bind applies the accepted
    PathPolicy to every subsequent read. No method writes or starts a process.
    """

    def __init__(
        self,
        *,
        workspace_root: str,
        metadata: PathMetadataReader,
        read_bytes: WorkspaceBytes,
        max_entries: int = 1000000,
        max_depth: int = 64,
    ) -> None:
        """Bind one trusted workspace and finite enumeration limits."""
        self._root = (
            PureWindowsPath(workspace_root)
            if ":" in workspace_root or workspace_root.startswith("\\\\")
            else PurePosixPath(workspace_root)
        )
        if not self._root.is_absolute() or ".." in self._root.parts:
            raise ValueError("Snapshot reads require an absolute canonical workspace")
        if type(max_entries) is not int or not 1 <= max_entries <= 10000000:
            raise ValueError("max_entries must be between 1 and 10000000")
        if type(max_depth) is not int or not 1 <= max_depth <= 128:
            raise ValueError("max_depth must be between 1 and 128")
        self._metadata = metadata
        self._read_bytes = read_bytes
        self._max_entries = max_entries
        self._max_depth = max_depth
        self._observed: dict[str, PathMetadata] = {}
        self._captured: dict[str, bytes] = {}
        self._limits: dict[str, int] = {}
        self._missing: set[str] = set()
        self._excluded: set[str] = set()
        self._enumerated: set[str] = set()
        self._policy: PathPolicy | None = None

    @property
    def missing_paths(self) -> tuple[str, ...]:
        """Expose observed absence without permitting callers to change it."""
        return tuple(sorted(self._missing))

    @property
    def excluded_paths(self) -> tuple[str, ...]:
        """Expose explicitly excluded scan paths for the snapshot digest."""
        return tuple(sorted(self._excluded))

    @property
    def captured(self) -> tuple[tuple[str, bytes], ...]:
        """Return immutable original bytes in portable ordinal path order."""
        return tuple(sorted(self._captured.items()))

    def _inspect(self, path: str) -> PathMetadata:
        """Retain complete metadata and fail if earlier observations changed."""
        entry = self._metadata(path)
        if entry.kind == "directory":
            # Enumeration order is irrelevant; duplicate and aliased names are not.
            entry = replace(entry, children=check_path_collisions(entry.children))
        prior = self._observed.setdefault(path, entry)
        if entry != prior:
            raise OSError(f"Snapshot metadata changed at {path!r}; reload")
        return entry

    def _bootstrap(self, path: str) -> PathMetadata:
        """Check physical containment before a profile can supply PathPolicy.

        This narrow bootstrap only checks exact ordinary ancestors and names;
        it grants no profile scope. Native byte opens must enforce containment
        themselves to close races between these independent metadata operations.
        """
        parts = relative_path(path).split("/")
        parent: PathMetadata | None = None
        identities: set[str] = set()
        # Inspect root and every ancestor without ever traversing a reported link.
        for length in range(len(parts) + 1):
            current = "/".join(parts[:length]) or "."
            entry = self._inspect(current)
            if entry.kind == "missing":
                if parent is not None and parts[length - 1] in parent.children:
                    raise OSError("Snapshot enumeration disagrees with missing input")
                return entry
            if entry.kind not in {"file", "directory"}:
                raise PathPolicyError("PATH_LINK", current, "Use ordinary local paths.")
            expected = self._root.joinpath(*parts[:length]).as_posix()
            if entry.resolved_path != expected or entry.identity in identities:
                raise PathPolicyError(
                    "PATH_ALIAS", current, "Use exact workspace paths."
                )
            identities.add(str(entry.identity))
            if parent is not None and parts[length - 1] not in parent.children:
                raise OSError("Snapshot enumeration disagrees with existing input")
            if length < len(parts) and entry.kind != "directory":
                raise PathPolicyError("PATH_TYPE", current, "Use directory ancestors.")
            check_path_collisions(entry.children)
            parent = entry
        return cast("PathMetadata", parent)

    def bind(self, profile: ProfileV2) -> None:
        """Apply the validated profile once and check all configured locations."""
        if self._policy is not None:
            raise ValueError("Use one fresh SnapshotIO per profile load")
        self._max_entries = min(self._max_entries, profile.limits.source_files)
        self._max_depth = min(self._max_depth, profile.limits.nesting_depth)
        self._policy = PathPolicy(
            profile,
            workspace_root=self._root.as_posix(),
            metadata=self._inspect,
        )
        # Configuration absence is retained as input state, never silently inferred.
        for location in self._policy.validate_configuration():
            if location.observations[-1].kind == "missing":
                self._missing.add(location.path)
        # Bootstrap bytes must also fit the final configured profile scope.
        for path in self._captured:
            self._policy.resolve_read(path)

    def inspect(self, path: str) -> PathMetadata:
        """Check scope and path policy, recording explicit absence for manifests."""
        if len(relative_path(path).split("/")) > self._max_depth:
            raise OSError("Snapshot path nesting limit exceeded")
        if self._policy is None:
            entry = self._bootstrap(path)
        else:
            resolved = self._policy.resolve_read(path, allow_missing=True)
            entry = (
                self._inspect(path)
                if resolved.observations[-1].kind != "missing"
                else PathMetadata(kind="missing")
            )
        if entry.kind == "missing":
            self._missing.add(path)
        return entry

    def read(self, path: str, *, limit: int, required: bool = True) -> bytes | None:
        """Capture exact bytes once, retaining the strictest requested byte limit."""
        if type(limit) is not int or not 1 <= limit <= 67108864:
            raise ValueError("Snapshot byte limits must be between 1 and 67108864")
        entry = self.inspect(path)
        if entry.kind == "missing":
            if required:
                raise FileNotFoundError(f"Required snapshot input is missing: {path}")
            return None
        if entry.kind != "file":
            raise OSError(f"Expected an ordinary snapshot file: {path}")
        if path not in self._captured:
            if len(self._captured) >= self._max_entries:
                raise OSError("Snapshot file enumeration limit exceeded")
            data = self._read_bytes(path, limit=limit)
            if not isinstance(cast("object", data), bytes):
                raise OSError("Snapshot byte adapter must return immutable bytes")
            self._captured[path] = data
        data = self._captured[path]
        if len(data) > limit:
            raise OSError(f"Snapshot file exceeds its byte limit: {path}")
        self._limits[path] = min(limit, self._limits.get(path, limit))
        self.inspect(path)
        return data

    def enumerate(
        self,
        roots: Iterable[str],
        *,
        exclude: Callable[[str], bool] | None = None,
    ) -> tuple[str, ...]:
        """Enumerate configured trees deterministically with finite depth/count.

        The loader excludes only selected source/test paths. Artifact trees and
        explicitly referenced inputs must never be hidden through exclusions.
        """
        pending = list(check_path_collisions(sorted(set(roots))))
        heapq.heapify(pending)
        visited: set[str] = set()
        files: set[str] = set()
        # A heap keeps traversal and bounded failures independent of input order.
        while pending:
            path = heapq.heappop(pending)
            if path in visited:
                continue
            visited.add(path)
            if exclude is not None and exclude(path):
                self._excluded.add(path)
                continue
            self._enumerated.add(path)
            if len(self._enumerated) > self._max_entries:
                raise OSError("Snapshot entry enumeration limit exceeded")
            entry = self.inspect(path)
            if entry.kind == "file":
                files.add(path)
            elif entry.kind == "directory":
                # Complete immediate child names include hidden and unrecognized files.
                for child in sorted(entry.children):
                    heapq.heappush(pending, f"{path}/{child}")
        return tuple(sorted(files))

    def verify_unchanged(self) -> None:
        """Detect additions/deletions/replacements/edits before returning a snapshot.

        Fresh reads are comparisons only: validators and reported hashes always
        use the original captured bytes. Later mutations must repeat freshness
        checks through the separate compare-and-swap service.
        """
        # Directory observations detect added files, including hidden entries.
        for path in sorted(self._observed):
            self._inspect(path)
        # Check bytes too: stable inode identity alone does not detect an in-place edit.
        for path, original in sorted(self._captured.items()):
            self.inspect(path)
            if self._read_bytes(path, limit=self._limits[path]) != original:
                raise OSError(f"Snapshot bytes changed at {path!r}; reload")
            self.inspect(path)


def within_roots(path: str, roots: tuple[str, ...]) -> bool:
    """Authorize exact spelling and component boundaries, never textual prefixes."""
    relative_path(path)
    return any(path == root or path.startswith(root + "/") for root in roots)


def document_format(path: str) -> Literal["json", "yaml"]:
    """Select syntax from a supported filename, never content-directed dispatch."""
    return "json" if path.endswith(".json") else "yaml"


def load_profile_inputs(
    io: SnapshotIO,
    path: str,
    core: SchemaCatalog,
) -> tuple[ProfileV2, SchemaCatalog, dict[str, InputCategory]]:
    """Load core shape, restrict extension roots, then construct the pinned profile."""
    if core.extensions:
        raise ValueError("Bootstrap requires an unextended trusted core catalog")
    raw = io.read(path, limit=16777216)
    result = validate_document(
        cast("bytes", raw),
        expected_kind="domain-profile",
        expected_version="2.0.0",
        format=document_format(path),
        artifact_path=path,
        catalog=core,
    )
    if not result.ok or result.document is None:
        raise ProfileError(result.findings)
    document = result.document
    roots = cast("tuple[str, ...]", document["documentation_roots"])
    declarations = cast("JsonObject", document.get("extension_schemas", JsonObject(())))
    categories: dict[str, InputCategory] = {path: "profile"}
    extensions: list[ExtensionSchema] = []
    # Check every declaration before opening any local extension schema bytes.
    for declaration in declarations.values():
        schema_path = cast("str", cast("JsonObject", declaration)["path"])
        if not within_roots(schema_path, roots):
            raise PathPolicyError(
                "EXTENSION_SCHEMA_ROOT",
                schema_path,
                "Extension schemas must be inside documentation roots.",
            )
    # The catalog can only see pinned bytes after the schema-specific root check.
    for namespace, declaration in declarations.items():
        entry = cast("JsonObject", declaration)
        schema_path = cast("str", entry["path"])
        extensions.append(
            ExtensionSchema(
                namespace=namespace,
                path=schema_path,
                sha256=cast("str", entry["sha256"]),
                content=cast("bytes", io.read(schema_path, limit=16777216)),
            )
        )
        categories[schema_path] = "extension-schema"
    catalog = (
        SchemaCatalog(documents=core.documents, extensions=tuple(extensions))
        if extensions
        else core
    )
    profile = ProfileV2(
        cast("bytes", raw), format=document_format(path), catalog=catalog
    )
    if profile.artifacts["profile"] != path:
        raise ValueError(
            "Selected profile path disagrees with profile artifact location"
        )
    io.bind(profile)
    locator = io.read(
        "config/discovery.json", limit=profile.limits.document_bytes, required=False
    )
    if locator is not None:
        ActivationLocator(locator, catalog=catalog).require_profile_path(path)
        categories["config/discovery.json"] = "activation"
    return profile, catalog, categories
