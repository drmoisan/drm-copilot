"""Capture bounded analyzer inputs without changing strict discovery snapshot loads.

Only supplied metadata and byte readers perform I/O. Excluded frontiers are never
descended; failed reads remain explicit rows with no fabricated file content.
"""

from __future__ import annotations

import heapq
from dataclasses import replace
from fnmatch import fnmatchcase
from typing import TYPE_CHECKING, cast

from drm_copilot_discovery.analyzer.models import InventoryCapture, InventoryInput
from drm_copilot_discovery.models import JsonObject, canonical_json
from drm_copilot_discovery.path_models import check_path_collisions
from drm_copilot_discovery.snapshot import SnapshotFile
from drm_copilot_discovery.snapshot_io import SnapshotIO, within_roots

if TYPE_CHECKING:
    from drm_copilot_discovery.mutation_plan import CapturedWorkspace
    from drm_copilot_discovery.path_models import PathMetadataReader
    from drm_copilot_discovery.profile_v2 import ProfileV2
    from drm_copilot_discovery.repository_reader import RepositoryFile, RepositoryReader
    from drm_copilot_discovery.snapshot import DiscoverySnapshot, InputCategory
    from drm_copilot_discovery.snapshot_io import WorkspaceBytes

MAX_CAPTURE_BYTES = 268435456


def exclusion_rules(profile: ProfileV2) -> tuple[JsonObject, ...]:
    """Return deterministic authored and output exclusions; no paths are read.

    Generated discovery artifacts and evidence payloads cannot become production
    inventory merely because a documentation root contains their output folders.

    profile (ProfileV2) supplies validated selectors and output locations. Returns
    tuple[JsonObject, ...] with deterministic unique exclusion rules. Performs no
    I/O or profile mutation.
    """
    rules = list(profile.excluded_paths + profile.analyzers.ignored_paths)
    outputs = cast("JsonObject", profile.document["artifacts"])
    # Shared output locations require one exclusion regardless of artifact role.
    paths = {cast("str", path) for path in outputs.values()}
    paths.update(profile.evidence_roots)
    # Preserve the configured boundary and reason instead of silently hiding it.
    for path in sorted(paths):
        rules.append(
            JsonObject(
                (
                    ("path_or_glob", path),
                    ("rationale", "Discovery artifact or evidence output."),
                )
            )
        )
    return tuple(sorted(set(rules), key=canonical_json))


def exclusion_reason(path: str, rules: tuple[JsonObject, ...]) -> str | None:
    """Match portable case-sensitive selectors and directory frontiers; pure.

    A trailing /** also excludes the directory itself, so dependency/output trees
    can be pruned before enumeration rather than after their descendants are read.

    path (str) is a portable relative input; rules (tuple[JsonObject, ...]) are
    validated exclusion selectors. Returns str rationale for the first deterministic
    match, or None. Performs no I/O or mutation.
    """
    # Ordered matching makes overlapping authored reasons deterministic.
    for rule in rules:
        pattern = cast("str", rule["path_or_glob"])
        prefix = pattern[:-3] if pattern.endswith("/**") else pattern
        if (
            fnmatchcase(path, pattern)
            or fnmatchcase(path, prefix)
            or (
                not any(char in pattern for char in "*?[")
                and path.startswith(pattern + "/")
            )
        ):
            return cast("str", rule["rationale"])
    return None


def _category(path: str, profile: ProfileV2) -> InputCategory:
    """Preserve selected source/test/documentation roles without inferring behavior.

    path (str) is the selected relative input and profile (ProfileV2) defines root
    ownership. Returns InputCategory for source, test or documentation. Unsafe path
    syntax raises PathPolicyError; performs no I/O.
    """
    # Production/project ownership precedes tests, matching snapshot classification.
    if (
        within_roots(path, profile.production_roots)
        or path in profile.project_entry_points
    ):
        return "source"
    return "test" if within_roots(path, profile.test_roots) else "documentation"


def capture_snapshot(snapshot: DiscoverySnapshot) -> InventoryCapture:
    """Reuse exact accepted snapshot bytes and Git objects without additional reads.

    Artifact/replica payloads retain their own categories and are not inventoried.
    Exclusions must still resolve to current profile rules; unknown omissions fail.

    snapshot (DiscoverySnapshot) supplies captured input categories, bytes and Git
    objects. Returns InventoryCapture. Raises ValueError for unexplained exclusions
    and ProfileError for draft configuration; performs no I/O or mutation.
    """
    rules = exclusion_rules(snapshot.profile)
    # Retain only selected repository inputs; artifact payloads have separate roles.
    inputs = [
        InventoryInput(path=file.path, status="inspected", file=file)
        for file in snapshot.manifest.files
        if file.category in {"source", "test", "documentation"}
    ]
    # Every omitted frontier must remain explainable from the current configuration.
    for path in snapshot.excluded_paths:
        reason = exclusion_reason(path, rules)
        if reason is None:
            raise ValueError(f"Captured exclusion has no configured rationale: {path}")
        inputs.append(InventoryInput(path=path, status="excluded", rationale=reason))
    return InventoryCapture(
        profile=snapshot.profile,
        inputs=tuple(inputs),
        exclusions=rules,
        repository_files=snapshot.repository_files,
    )


def capture_inputs(
    profile: ProfileV2,
    *,
    workspace_root: str,
    metadata: PathMetadataReader,
    read_bytes: WorkspaceBytes,
    repository_files: tuple[RepositoryFile, ...] = (),
) -> InventoryCapture:
    """Read a configured tree through PathPolicy, keeping bounded failure accounting.

    Missing/unreadable inputs become blocking analyzer rows. Unsafe paths, aliases,
    resource exhaustion and inputs that change during capture fail the whole call.
    Repository objects must already have been captured through the pinned reader.
    This function never writes or launches processes, including during dry runs.

    profile (ProfileV2) supplies scope and limits; workspace_root (str) is the
    absolute trusted root. metadata (PathMetadataReader) and read_bytes
    (WorkspaceBytes) are non-following injected readers. repository_files
    (tuple[RepositoryFile, ...]) supplies retained pinned objects. Returns
    InventoryCapture. Raises PathPolicyError, ProfileError, ValueError or OSError
    for unsafe, incomplete, changed or over-budget state. Effects are bounded reads
    through these seams only.
    """
    profile.require_configured()

    def bounded_read(path: str, *, limit: int) -> bytes:
        """Reject a broken byte adapter before SnapshotIO can retain partial state.

        path (str) identifies the selected file and limit (int) bounds its
        allocation. Returns immutable bytes. Raises OSError for adapter/type/size
        failures; performs one injected read and never writes.
        """
        content = read_bytes(path, limit=limit)
        if not isinstance(cast("object", content), bytes) or len(content) > limit:
            raise OSError("Analyzer input exceeded its immutable-byte contract")
        return content

    # Bind non-following scope before allocating scan state or reading any bytes.
    io = SnapshotIO(
        workspace_root=workspace_root, metadata=metadata, read_bytes=bounded_read
    )
    io.bind(profile)
    roots = (
        profile.production_roots
        + profile.test_roots
        + profile.project_entry_points
        + profile.documentation_roots
    )
    pending = list(check_path_collisions(sorted(set(roots))))
    heapq.heapify(pending)
    visited: set[str] = set()
    inputs: list[InventoryInput] = []
    rules = exclusion_rules(profile)
    total_bytes = 0
    # Bound aggregate allocation even when each selected file fits its own limit.
    byte_budget = min(
        profile.limits.source_files * profile.analyzers.max_file_bytes,
        MAX_CAPTURE_BYTES,
    )
    # Ordinal traversal makes both successful input order and bounded failures stable.
    while pending:
        path = heapq.heappop(pending)
        if path in visited:
            continue
        visited.add(path)
        if len(visited) > profile.limits.source_files:
            raise ValueError("Analyzer entry enumeration limit exceeded")
        reason = exclusion_reason(path, rules)
        # Prune configured frontiers before probing descendants or opening bytes.
        if reason is not None:
            inputs.append(
                InventoryInput(path=path, status="excluded", rationale=reason)
            )
            continue
        entry = io.inspect(path)
        if entry.kind == "directory":
            # Check the complete frontier before allocating or descending another tree.
            if len(entry.children) > profile.limits.source_files:
                raise ValueError("Analyzer directory enumeration limit exceeded")
            # Keep all immediate children, including hidden and unfamiliar filenames.
            for child in entry.children:
                heapq.heappush(pending, f"{path}/{child}")
            continue
        try:
            content = cast(
                "bytes", io.read(path, limit=profile.analyzers.max_file_bytes)
            )
        except OSError:
            inputs.append(
                InventoryInput(
                    path=path,
                    status="unreadable",
                    rationale="Input unavailable within the configured byte limit.",
                )
            )
            continue
        total_bytes += len(content)
        if total_bytes > byte_budget:
            raise ValueError("Analyzer aggregate byte limit exceeded")
        inputs.append(
            InventoryInput(
                path=path,
                status="inspected",
                file=SnapshotFile(
                    path=path, content=content, category=_category(path, profile)
                ),
            )
        )
    io.verify_unchanged()
    return InventoryCapture(
        profile=profile,
        inputs=tuple(inputs),
        exclusions=rules,
        repository_files=repository_files,
    )


def pin_inventory_sources(
    workspace: CapturedWorkspace, repository: RepositoryReader
) -> CapturedWorkspace:
    """Capture missing inventory Git objects using a trusted bounded local reader.

    Apply this same explicit selection to every mutation writer capture, including
    freshness reads before the first inventory exists. Ordinary snapshot loading
    remains unchanged. A missing/mismatched Git object raises before publication;
    working-copy bytes are never substituted for an unavailable repository blob.

    workspace (CapturedWorkspace) supplies the complete baseline and repository
    (RepositoryReader) supplies bounded pinned blobs. Returns a new
    CapturedWorkspace preserving existing objects. Raises ValueError for reader
    mismatch and OSError for inaccessible Git objects; reads only explicit local
    repository paths and never writes.
    """
    snapshot = workspace.snapshot
    capture = capture_snapshot(snapshot)
    identity = repository.identity()
    if (
        identity.id != snapshot.profile.repository.id
        or identity.revision != snapshot.profile.repository.revision
    ):
        raise ValueError(
            "Inventory repository reader differs from the configured local pin"
        )
    objects = list(snapshot.repository_files)
    # Reuse exact existing identities so repeated writer captures remain comparable.
    existing = {(value.repository, value.path) for value in objects}
    # Fetch only missing selected inputs; excluded and unavailable entries have no blob.
    for item in capture.inputs:
        if item.file is None or (identity, item.path) in existing:
            continue
        source = repository.read_file(
            revision=cast("str", identity.revision),
            path=item.path,
            limit=snapshot.profile.analyzers.max_file_bytes,
        )
        if (
            source.repository != identity
            or source.path != item.path
            or len(source.content) > snapshot.profile.analyzers.max_file_bytes
        ):
            raise ValueError(
                "Inventory repository reader returned an unexpected object"
            )
        objects.append(source)
    return replace(
        workspace, snapshot=replace(snapshot, repository_files=tuple(objects))
    )
