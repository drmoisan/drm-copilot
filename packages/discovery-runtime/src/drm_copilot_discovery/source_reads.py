"""Inspect selected local bytes through closed, bounded, read-only operations.

Native metadata/byte adapters must enforce non-following workspace containment
at each open. This module verifies their observations, selection/profile scope,
transport integrity and freshness; it never executes commands or mutates files.
"""

from __future__ import annotations

import heapq
import json
from dataclasses import asdict, replace
from fnmatch import fnmatchcase
from hashlib import sha256
from typing import TYPE_CHECKING, cast

from drm_copilot_discovery.models import canonical_json
from drm_copilot_discovery.path_models import (
    PathMetadata,
    PathPolicyError,
    check_path_collisions,
)
from drm_copilot_discovery.path_policy import PathPolicy
from drm_copilot_discovery.repository_reader import RepositoryFile, RepositoryIdentity
from drm_copilot_discovery.snapshot import SnapshotFile
from drm_copilot_discovery.snapshot_io import within_roots
from drm_copilot_discovery.source_read_models import (
    ReadSelection,
    SourceEvidence,
    SourceItem,
    SourceReadLimits,
    SourceReadRequest,
    SourceReadResult,
    SourceSpan,
    operation_without_cursor,
    source_page,
)
from drm_copilot_discovery.transport_manifest import TransportRoute, bind_transport

DEFAULT_LIMITS = SourceReadLimits()

if TYPE_CHECKING:
    from drm_copilot_discovery.catalog import SchemaCatalog
    from drm_copilot_discovery.path_models import PathMetadataReader
    from drm_copilot_discovery.profile_v2 import ProfileV2
    from drm_copilot_discovery.snapshot_io import WorkspaceBytes
    from drm_copilot_discovery.source_read_models import SelectedManifest


class SourceReader:
    """Bind a configured profile, catalog, host selection and read seams.
    Construct once; inspect creates independent state for each typed request.
    Operations authorize, enumerate, capture, verify and page selected bytes.
    Only injected local readers have effects; no process, network or writes.
    """

    def __init__(
        self,
        profile: ProfileV2,
        *,
        catalog: SchemaCatalog,
        workspace_root: str,
        metadata: PathMetadataReader,
        read_bytes: WorkspaceBytes,
        selection: ReadSelection,
        limits: SourceReadLimits = DEFAULT_LIMITS,
    ) -> None:
        """Retain ProfileV2, SchemaCatalog, ReadSelection and SourceReadLimits.

        workspace_root:str anchors PathMetadataReader and WorkspaceBytes seams.
        Return None; reject draft configuration or malformed typed inputs before
        I/O. Selection must be authenticated by the caller, never from a request.
        """
        profile.require_configured()
        if not isinstance(cast("object", selection), ReadSelection) or not isinstance(
            cast("object", limits), SourceReadLimits
        ):
            raise ValueError("Source reads require typed host selection and limits")
        self.profile, self.selection, self.limits = profile, selection, limits
        self.catalog = catalog
        self.workspace_root, self.metadata, self.read_bytes = (
            workspace_root,
            metadata,
            read_bytes,
        )

    def inspect(self, request: SourceReadRequest) -> SourceReadResult:
        """Return a bounded, freshness-checked page for a typed request.

        Read only injected local seams. Raise ValueError for authority, transport,
        encoding or cursor faults; OSError for I/O, limits or changing inputs.
        No partial content is returned after failure.
        """
        if not isinstance(cast("object", request), SourceReadRequest):
            raise ValueError("Use a typed source inspection request")
        try:
            return _Inspection(self, request).run()
        except PathPolicyError as error:
            # Retain actionable limit/change diagnostics wrapped by path inspection.
            if isinstance(error.__cause__, OSError):
                raise OSError(
                    f"Cannot inspect {error.path!r}: {error.__cause__}"
                ) from error
            raise


class _Inspection:
    """Coordinate one request with isolated metadata, byte and transport caches.
    Created by SourceReader.inspect; run bounds every input, verifies freshness
    and returns a page. No state is shared between calls. Only injected metadata
    and byte readers perform I/O; no writes are possible.
    """

    def __init__(self, reader: SourceReader, request: SourceReadRequest) -> None:
        """Bind SourceReader and SourceReadRequest; return None with fresh caches.
        Validate lexical policy and prepare immutable root scopes without I/O.
        """
        self.reader, self.request = reader, request
        self.profile, self.limits = reader.profile, reader.limits
        self.observed: dict[str, PathMetadata] = {}
        self.captured: dict[str, SnapshotFile] = {}
        self.routes: dict[str, TransportRoute] = {}
        self.input_bytes = self.line_count = 0
        self.policy = PathPolicy(
            self.profile, workspace_root=reader.workspace_root, metadata=self._metadata
        )
        self.roots = (
            self.profile.production_roots
            + self.profile.test_roots
            + self.profile.documentation_roots
            + self.profile.evidence_roots
            + (self.profile.artifacts["source_snapshots"],)
        )
        # Snapshot regions take priority even when a broad documentation root matches.
        self.snapshot_roots = (
            (self.profile.artifacts["source_snapshots"],)
            + tuple(
                item.snapshot_manifest.rsplit("/", 1)[0]
                for item in self.profile.repositories
                if item.snapshot_manifest is not None
            )
            + tuple(item.path.rsplit("/", 1)[0] for item in reader.selection.manifests)
        )

    def _metadata(self, path: str) -> PathMetadata:
        """Read PathMetadata for str path under enumeration/depth bounds.
        Return stable metadata or raise OSError for changes/limits; read-only.
        """
        if path != "." and len(path.split("/")) > self.limits.depth:
            raise OSError("Source inspection depth limit exceeded")
        if path not in self.observed and len(self.observed) >= min(
            self.limits.entries, self.profile.limits.source_files
        ):
            raise OSError("Source inspection enumeration limit exceeded")
        entry = self.reader.metadata(path)
        if len(entry.children) > self.limits.entries:
            raise OSError("Source directory child enumeration limit exceeded")
        entry = replace(entry, children=check_path_collisions(entry.children))
        prior = self.observed.setdefault(path, entry)
        if prior != entry:
            raise OSError(f"Source metadata changed at {path!r}; repeat inspection")
        return entry

    def _profile_allows(self, path: str) -> bool:
        """Return bool configured-input scope for portable str path; pure.
        Apply root membership and ancestor exclusions to all integrity reads.
        """
        if not (
            within_roots(path, self.roots) or path in self.profile.project_entry_points
        ):
            return False
        # Exclusion of a parent remains effective when a descendant is requested.
        parents = tuple(
            "/".join(path.split("/")[:size])
            for size in range(1, len(path.split("/")) + 1)
        )
        # Apply each authored exclusion to both the candidate and its ancestors.
        return not any(
            fnmatchcase(parent, cast("str", entry["path_or_glob"]))
            for parent in parents
            for entry in self.profile.excluded_paths
        )

    def _eligible(self, path: str) -> bool:
        """Return bool selection/profile/snapshot intersection for str path.
        Apply ancestor exclusions before snapshot membership; no I/O or mutation.
        """
        if not self.reader.selection.allows(path) or not self._profile_allows(path):
            return False
        if within_roots(path, self.snapshot_roots):
            # Ancestors may lead only toward an explicitly selected manifest region.
            return any(
                within_roots(path, (item.path.rsplit("/", 1)[0],))
                or item.path.startswith(path + "/")
                for item in self.reader.selection.manifests
            )
        return True

    def _read(self, path: str) -> bytes:
        """Return exact bytes for ordinary str path, charging every attempted read.
        Raise OSError/ValueError for bounds, path or I/O faults; never write.
        """
        resolved = self.policy.resolve_read(path)
        if resolved.observations[-1].kind != "file":
            raise OSError(f"Source byte reads require an ordinary file: {path!r}")
        remaining = self.limits.input_bytes - self.input_bytes
        if remaining <= 0:
            raise OSError("Source aggregate input byte limit exceeded")
        limit = min(
            self.limits.file_bytes, self.profile.limits.document_bytes, remaining
        )
        content = self.reader.read_bytes(path, limit=limit)
        if not isinstance(cast("object", content), bytes):
            raise OSError("Source adapter must return immutable bytes")
        self.input_bytes += len(content)
        if len(content) > limit:
            raise OSError(f"Source input byte limit exceeded at {path!r}")
        self.policy.resolve_read(path)
        return content

    def _capture(self, path: str) -> SnapshotFile:
        """Return cached SnapshotFile for str path; first use reads bounded bytes.
        Retain immutable originals; propagate read/path failures without writes.
        """
        if path not in self.captured:
            self.captured[path] = SnapshotFile(
                path=path, content=self._read(path), category="source"
            )
        return self.captured[path]

    def _transport(self, selected: SelectedManifest) -> TransportRoute:
        """Validate SelectedManifest and all members before releasing provenance.

        Read only explicitly selected integrity inputs. Return the reconstructed
        route or raise ValueError/OSError for hash, membership, bounds or I/O faults.
        """
        if selected.path in self.routes:
            return self.routes[selected.path]
        if not self._profile_allows(selected.path):
            raise ValueError("Selected manifest is outside configured read scope")
        header = self._capture(selected.path)
        if header.sha256 != selected.sha256:
            raise ValueError("Selected snapshot manifest hash changed")
        route = bind_transport(
            selected.path,
            header.content,
            catalog=self.reader.catalog,
            limits=self.profile.limits.parse_limits(),
        )
        route.revalidate(
            catalog=self.reader.catalog, limits=self.profile.limits.parse_limits()
        )
        if len(route.members) > self.limits.entries:
            raise OSError("Snapshot member enumeration limit exceeded")
        # Preflight all integrity inputs before any payload bytes are captured.
        for member in route.members:
            if not self._profile_allows(member.grant.path):
                raise ValueError("Snapshot member is outside configured read scope")
            if member.size > self.limits.file_bytes:
                raise OSError("Snapshot member byte limit exceeded")
            self.policy.resolve_read(member.grant.path)
        # The manifest grants integrity reads only; output still requires selection.
        files = tuple(self._capture(member.grant.path) for member in route.members)
        route.check_files(files)
        self.routes[selected.path] = route
        return route

    def _evidence(self, path: str) -> SourceEvidence:
        """Return SourceEvidence for str path after complete transport validation.
        Capture local bytes and preserve imported origins; raise ValueError/OSError
        for integrity/read faults. No writes or configured-pin claims.
        """
        repository = RepositoryIdentity(id=self.profile.repository.id, revision=None)
        origin, provenance, manifest_hash = path, "working-file", None
        if within_roots(path, self.snapshot_roots):
            # Reject ambiguous nested transports instead of selecting one silently.
            selected = tuple(
                item
                for item in self.reader.selection.manifests
                if within_roots(path, (item.path.rsplit("/", 1)[0],))
            )
            if len(selected) != 1:
                raise ValueError("Source snapshot requires one selected manifest")
            route = self._transport(selected[0])
            # Membership precedes target capture, including under broad docs roots.
            member = next(
                (item for item in route.members if item.grant.path == path), None
            )
            if member is None:
                raise ValueError("Requested source is not a declared snapshot member")
            manifest_hash = route.manifest.sha256
            provenance = "snapshot-manifest"
            if member.origin is not None:
                origin, repository, provenance = (
                    member.origin,
                    route.source,
                    "snapshot-member",
                )
                RepositoryFile(
                    repository=repository,
                    path=origin,
                    content=self._capture(path).content,
                )
        captured = self._capture(path)
        return SourceEvidence(
            workspace_path=path,
            path=origin,
            repository=repository,
            sha256=captured.sha256,
            size=len(captured.content),
            provenance=provenance,
            manifest_sha256=manifest_hash,
        )

    def _paths(self) -> tuple[str, ...]:
        """Return sorted tuple[str, ...] in selected/profile scope.
        Bound metadata enumeration; raise ValueError/OSError for scope/path faults.
        Never read target bytes or disclose rejected descendants.
        """
        pending = list(self.request.paths)
        files: set[str] = set()
        scheduled = set(pending)
        heapq.heapify(pending)
        # Complete authorization is checked before traversal or any target byte read.
        for path in pending:
            if not self._eligible(path):
                raise ValueError(
                    f"Source path is not selected and configured: {path!r}"
                )
        # Ordinal traversal makes both returned ordering and bounded failure stable.
        while pending:
            path = heapq.heappop(pending)
            self.policy.resolve_read(path)
            entry = self.observed[path]
            # Exact file grants and project entry points never expand to directories.
            if entry.kind == "directory":
                if not any(
                    grant.directory and grant.allows(path)
                    for grant in self.reader.selection.grants
                ):
                    raise ValueError(
                        "An exact file selection cannot enumerate a directory"
                    )
                if not within_roots(path, self.roots):
                    raise ValueError("A project entry point must be an exact file")
                if self.request.operation == "read":
                    raise ValueError(
                        "Read requires exact files; use list/search for directories"
                    )
                # Rejected child names never enter the observable result or read set.
                for child in entry.children:
                    candidate = path + "/" + child
                    if self._eligible(candidate) and candidate not in scheduled:
                        if len(scheduled) >= min(
                            self.limits.entries, self.profile.limits.source_files
                        ):
                            raise OSError("Source queued enumeration limit exceeded")
                        scheduled.add(candidate)
                        heapq.heappush(pending, candidate)
            else:
                files.add(path)
        return tuple(sorted(files))

    def _items(self, path: str) -> tuple[SourceItem, ...]:
        """Return tuple[SourceItem, ...] of file/line/match rows for str path.
        Read selected bytes; raise ValueError for UTF-8 faults or OSError for bounds.
        Hash originals; omit LF/CRLF endings from reported text.
        """
        evidence = self._evidence(path)
        if self.request.operation == "list":
            return (SourceItem(evidence=evidence),)
        content = self.captured[path].content
        try:
            content.decode("utf-8")
        except UnicodeError as error:
            raise ValueError(f"Source is not strict UTF-8: {path!r}") from error
        if not content:
            return (
                (SourceItem(evidence=evidence, text=""),)
                if self.request.operation == "read"
                else ()
            )
        lines = content.split(b"\n")
        if content.endswith(b"\n"):
            lines.pop()
        self.line_count += len(lines)
        if self.line_count > self.limits.lines:
            raise OSError("Source decoded line limit exceeded")
        items: list[SourceItem] = []
        # Preserve original byte hashing while reporting LF/CRLF lines without endings.
        for number, raw in enumerate(lines, 1):
            terminated = number < len(lines) or content.endswith(b"\n")
            if len(raw) + int(terminated) > self.limits.line_bytes:
                raise OSError("Source individual line byte limit exceeded")
            text = (raw.removesuffix(b"\r") if terminated else raw).decode("utf-8")
            if number < self.request.line_start or (
                self.request.line_end is not None and number > self.request.line_end
            ):
                continue
            # Reads return whole selected lines; searches return literal match spans.
            if self.request.operation == "read":
                items.append(
                    SourceItem(
                        evidence=evidence,
                        text=text,
                        span=SourceSpan(
                            line=number, column_start=1, column_end=len(text) + 1
                        ),
                    )
                )
            else:
                query, start = cast("str", self.request.query), 0
                # Literal find has no regex evaluation and advances beyond each match.
                while (position := text.find(query, start)) >= 0:
                    items.append(
                        SourceItem(
                            evidence=evidence,
                            text=query,
                            span=SourceSpan(
                                line=number,
                                column_start=position + 1,
                                column_end=position + len(query) + 1,
                            ),
                        )
                    )
                    if len(items) > self.limits.matches:
                        raise OSError("Source literal match limit exceeded")
                    start = position + len(query)
        return tuple(items)

    def _identity(self) -> str:
        """Return SHA-256 str binding inputs, selection, request and limits.
        Hash retained bytes deterministically without I/O or changing state.
        """
        # Bind original bytes, including separately selected integrity inputs.
        files = [(path, item.sha256) for path, item in sorted(self.captured.items())]
        value = dict(
            profile=sha256(canonical_json(self.profile.document)).hexdigest(),
            selection=asdict(self.reader.selection),
            limits=asdict(self.limits),
            request=operation_without_cursor(self.request),
            files=files,
        )
        return sha256(
            json.dumps(
                value, sort_keys=True, ensure_ascii=False, separators=(",", ":")
            ).encode("utf-8")
        ).hexdigest()

    def run(self) -> SourceReadResult:
        """Return SourceReadResult after request and freshness validation.
        Read injected seams; raise ValueError/OSError on failed checks, never
        returning partial output or mutating the workspace.
        """
        if (
            self.request.query is not None
            and len(self.request.query.encode("utf-8")) > self.limits.query_bytes
        ):
            raise OSError("Source query byte limit exceeded")
        paths = self._paths()
        items: list[SourceItem] = []
        # Collection bounds apply across files, not independently per requested root.
        for path in paths:
            items.extend(self._items(path))
            if self.request.operation == "search" and len(items) > self.limits.matches:
                raise OSError("Source aggregate literal match limit exceeded")
        # Count revalidation bytes too; stable inode identity alone is not freshness.
        for path, captured in sorted(self.captured.items()):
            if self._read(path) != captured.content:
                raise OSError(f"Source bytes changed at {path!r}; repeat inspection")
        # Directory reinspection detects additions, deletions and substitutions.
        for path in sorted(self.observed):
            self._metadata(path)
        return source_page(
            tuple(items),
            self.request,
            inspection_sha256=self._identity(),
            input_bytes=self.input_bytes,
            entries=len(self.observed),
            output_bytes=self.limits.output_bytes,
        )
