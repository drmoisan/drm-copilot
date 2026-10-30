"""Reconstruct the pre-invocation baseline the root pinned for a host invocation.

The host gateway replays the current configured capture with every required
output returned to its prepared state (the stored content, or absence) and
refuses when any other input drifted from the stored input manifest. Nothing
here reads the host; the capture and the verified records are supplied.
"""

from __future__ import annotations

from dataclasses import replace
from hashlib import sha256
from typing import TYPE_CHECKING, cast

from drm_copilot_discovery.catalog import SchemaCatalog
from drm_copilot_discovery.findings import Finding
from drm_copilot_discovery.models import JsonObject
from drm_copilot_discovery.mutation_plan import (
    CapturedWorkspace,
    MutationChange,
    project_snapshot,
)
from drm_copilot_discovery.operations import OperationFailure
from drm_copilot_discovery.path_models import PathMetadata
from drm_copilot_discovery.protected_records import refusal
from drm_copilot_discovery.snapshot_io import SnapshotIO
from drm_copilot_discovery.snapshot_loading import load_snapshot

if TYPE_CHECKING:
    from drm_copilot_discovery.repository_reader import RepositoryReader
    from drm_copilot_discovery.snapshot import DiscoverySnapshot


def _drift(path: str | None, message: str) -> OperationFailure:
    """Return the exit-3 baseline failure for path (str | None) with message (str)."""
    return OperationFailure(
        "SERVICE_BASELINE",
        exit_code=3,
        findings=(
            Finding(
                code="SERVICE_BASELINE",
                artifact_path=path,
                pointer="/inputs",
                message=message,
                next_action="Prepare the invocation again from the current inputs.",
            ),
        ),
    )


def _rows(value: object) -> tuple[JsonObject, ...]:
    """Return value as a tuple of JsonObject rows; refuse any other shape."""
    if not isinstance(value, tuple):
        raise refusal("A protected record row list is malformed.")
    rows = cast("tuple[object, ...]", value)
    if any(type(row) is not JsonObject for row in rows):
        raise refusal("A protected record row list is malformed.")
    return cast("tuple[JsonObject, ...]", rows)


def required_rows(invocation: JsonObject) -> tuple[JsonObject, ...]:
    """Return the required-output rows of the verified invocation record."""
    manifest = invocation.get("required_outputs")
    if type(manifest) is not JsonObject:
        raise refusal("The invocation carries no required-output manifest.")
    return _rows(manifest.get("outputs"))


class _HiddenPaths:
    """Replay a capture with the named paths absent, without consulting the host.

    The loader sees the capture's metadata and bytes except for the hidden
    paths, which report absence and vanish from their parent's child names.
    """

    def __init__(self, capture: CapturedWorkspace, hidden: frozenset[str]) -> None:
        """Index capture's metadata and bytes with hidden (frozenset[str]) removed."""
        self.hidden, self.capture = hidden, capture
        self.files = {
            item.path: item.content
            for item in capture.snapshot.manifest.files
            if item.path not in hidden
        }
        self.entries: dict[str, PathMetadata] = {}
        # Drop hidden entries and their names from the parent listings only.
        for path, entry in capture.metadata:
            if path in hidden:
                continue
            prefix = "" if path == "." else path + "/"
            children = tuple(
                name for name in entry.children if prefix + name not in hidden
            )
            self.entries[path] = replace(entry, children=children)

    def inspect(self, path: str) -> PathMetadata:
        """Return hidden absence or the captured metadata for path (str)."""
        if path in self.hidden:
            return PathMetadata(kind="missing")
        return self.entries.get(path) or self.capture.inspect(path)

    def read(self, path: str, *, limit: int) -> bytes:
        """Return captured bytes for path within limit; hidden paths raise OSError."""
        content = self.files.get(path)
        if content is None or len(content) > limit:
            raise OSError("Input is hidden, uncaptured or exceeds its byte limit")
        return content


def _check_drift(
    capture: CapturedWorkspace, stored: JsonObject, required: frozenset[str]
) -> None:
    """Refuse when any non-output input differs from the stored baseline manifest."""
    manifest = stored.get("input_manifest")
    if type(manifest) is not JsonObject:
        raise _drift(None, "The baseline result carries no input manifest.")
    digests = {
        cast("str", entry["path"]): cast("str", entry["sha256"])
        for entry in _rows(manifest.get("entries"))
    }
    current = {item.path: item.sha256 for item in capture.snapshot.manifest.files}
    # Every non-output input must be byte-identical to the pinned baseline.
    for path, digest in current.items():
        if path not in required and digests.get(path) != digest:
            raise _drift(path, "An input changed after the invocation was prepared.")
    for path in digests:
        if path not in required and path not in current:
            raise _drift(
                path, "An input was removed after the invocation was prepared."
            )


def _pinned_content(path: str, pinned: JsonObject) -> bytes:
    """Return the stored output bytes of pinned (JsonObject) or raise the drift."""
    text = pinned.get("content")
    if type(text) is not str:
        raise _drift(path, "The baseline row carries no text content.")
    content = text.encode("utf-8")
    if sha256(content).hexdigest() != pinned.get("sha256"):
        raise _drift(path, "The baseline row digest differs from its content.")
    return content


def reconstruct_baseline(
    capture: CapturedWorkspace,
    invocation: JsonObject,
    stored: JsonObject,
    *,
    repository: RepositoryReader | None,
) -> DiscoverySnapshot:
    """Rebuild the pre-invocation snapshot from capture and the stored baseline.

    capture (CapturedWorkspace) is the current configured capture; invocation
    (JsonObject) is the verified record; stored (JsonObject) is the verified
    `prepare-agent` result. Every required-output path is replaced by the stored
    content or removed when the stored row is absent; every other captured path
    must match the stored input manifest digest, and every other stored path must
    still exist, or OperationFailure("SERVICE_BASELINE", exit_code=3) is raised.
    repository (RepositoryReader | None) repeats the capture's source pins.
    Returns the reconstructed DiscoverySnapshot; performs no host I/O.
    """
    rows = {cast("str", row["path"]): row for row in required_rows(invocation)}
    _check_drift(capture, stored, frozenset(rows))
    stored_rows = {
        cast("str", row["path"]): row
        for row in _rows(stored.get("artifacts"))
        if row.get("path") in rows
    }
    # Outputs return to their prepared state: stored content, or absence.
    hidden = frozenset(path for path in rows if path not in stored_rows)
    overlay = _HiddenPaths(capture, hidden)
    profile = capture.snapshot.profile
    base = load_snapshot(
        io=SnapshotIO(
            workspace_root=capture.workspace_root,
            metadata=overlay.inspect,
            read_bytes=overlay.read,
            max_entries=profile.limits.source_files,
            max_depth=profile.limits.nesting_depth,
        ),
        profile_path=profile.artifacts["profile"],
        repository=repository,
        catalog=(
            SchemaCatalog(documents=capture.snapshot.catalog.documents)
            if capture.snapshot.catalog.extensions
            else capture.snapshot.catalog
        ),
    )
    if not stored_rows:
        return base
    digests = {item.path: item.sha256 for item in base.manifest.files}
    # Pinned content replays over the current digest so projection accepts it.
    changes = tuple(
        MutationChange(
            artifact_kind=cast("str", rows[path]["artifact_kind"]),
            artifact_id=cast("str", rows[path]["id"]),
            path=path,
            content=_pinned_content(path, pinned),
            expected_sha256=digests.get(path),
        )
        for path, pinned in sorted(stored_rows.items())
    )
    rebuilt = CapturedWorkspace(
        workspace_root=capture.workspace_root,
        snapshot=base,
        metadata=tuple(overlay.entries.items()),
    )
    return project_snapshot(rebuilt, changes)
