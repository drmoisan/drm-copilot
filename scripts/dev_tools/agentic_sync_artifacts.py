"""Sync outcome records and the JSON artifact writer for agentic sync.

Purpose:
    Hold the per-file ``SyncAction`` and run-level ``SyncSummary`` records, the
    JSON payload schemas they serialize to, and the functions that place and
    write the sync artifact through the filesystem seam.
"""

from __future__ import annotations

import json
from dataclasses import dataclass
from typing import TYPE_CHECKING, Literal, TypedDict

if TYPE_CHECKING:
    from datetime import datetime
    from pathlib import Path

    from scripts.dev_tools.agentic_sync_filesystem import SyncFileSystem

DecisionType = Literal["equivalent-mtime", "equivalent-content", "synced"]
ForceDirection = Literal["left-to-right", "right-to-left"]


class SyncActionPayload(TypedDict):
    """JSON payload schema for a serialized ``SyncAction`` entry."""

    root: str
    relative_path: str
    left_path: str
    right_path: str
    left_mtime: float
    right_mtime: float
    decision: DecisionType
    source: str | None
    sync_mtime: float | None
    forced: bool


class SyncSummaryPayload(TypedDict):
    """JSON payload schema for a serialized ``SyncSummary`` artifact."""

    repo_left: str
    repo_right: str
    started_at: str
    finished_at: str
    force_direction: ForceDirection | None
    actions: list[SyncActionPayload]


@dataclass(frozen=True, slots=True)
class SyncAction:
    """
    Represents the outcome of syncing a single file pair.

    Purpose:
        Capture the decision made for a matched file and any synchronization
        details needed for auditing and artifact logging.

    Usage:
        Populated by AgenticSyncer during the sync process and serialized to
        an artifact log.

    Invariants / Constraints:
        - root and relative_path identify a unique file within the scoped
          .github folders.
        - decision reflects whether a sync occurred or equivalence was assumed.
        - source is populated only when decision == "synced".

    Side Effects:
        None (pure data container).

    Attributes:
        root (str): Root folder (e.g., ".github/agents").
        relative_path (str): File path relative to root.
        left_path (str): Full path to the left repo file.
        right_path (str): Full path to the right repo file.
        left_mtime (float): Left file modification time before sync.
        right_mtime (float): Right file modification time before sync.
        decision (DecisionType): Sync decision type.
        source (str | None): "left" or "right" when synced.
        sync_mtime (float | None): Applied mtime when synced.
        forced (bool): Whether forced direction influenced the decision.
    """

    root: str
    relative_path: str
    left_path: str
    right_path: str
    left_mtime: float
    right_mtime: float
    decision: DecisionType
    source: str | None
    sync_mtime: float | None
    forced: bool


@dataclass(frozen=True, slots=True)
class SyncSummary:
    """
    Aggregated summary of a sync run.

    Purpose:
        Provide a top-level record of the sync operation for artifact logging,
        including timing and per-file outcomes.

    Usage:
        Returned by AgenticSyncer.sync_repos and serialized to JSON artifacts.

    Invariants / Constraints:
        - started_at and finished_at are timezone-aware UTC datetimes.
        - actions list preserves the order of processing for traceability.

    Side Effects:
        None (pure data container).

    Attributes:
        repo_left (str): Left repository path.
        repo_right (str): Right repository path.
        started_at (datetime): UTC start timestamp.
        finished_at (datetime): UTC finish timestamp.
        force_direction (ForceDirection | None): Forced direction, if any.
        actions (list[SyncAction]): Per-file outcomes.
    """

    repo_left: str
    repo_right: str
    started_at: datetime
    finished_at: datetime
    force_direction: ForceDirection | None
    actions: list[SyncAction]


def build_artifact_path(repo_root: Path, started_at: datetime) -> Path:
    """
    Build the artifact path for a sync run.

    Args:
        repo_root (Path): Repository root to anchor the artifacts folder.
        started_at (datetime): Start time used to name the artifact.

    Returns:
        Path: Artifact file path under artifacts/agentic-sync.
    """
    timestamp = started_at.strftime("%Y%m%dT%H%M%SZ")
    return repo_root / "artifacts" / "agentic-sync" / f"sync-{timestamp}.json"


def render_sync_summary(summary: SyncSummary) -> str:
    """
    Render a sync summary as JSON.

    Purpose:
        Produce a deterministic artifact payload for auditing.

    Args:
        summary (SyncSummary): Summary data to serialize.

    Returns:
        str: JSON string containing the sync summary.
    """

    # Serialize dataclasses into JSON-friendly structures.
    actions_payload: list[SyncActionPayload] = []
    # Serialize actions in order to preserve traceability.
    for action in summary.actions:
        actions_payload.append(
            {
                "root": action.root,
                "relative_path": action.relative_path,
                "left_path": action.left_path,
                "right_path": action.right_path,
                "left_mtime": action.left_mtime,
                "right_mtime": action.right_mtime,
                "decision": action.decision,
                "source": action.source,
                "sync_mtime": action.sync_mtime,
                "forced": action.forced,
            }
        )

    payload: SyncSummaryPayload = {
        "repo_left": summary.repo_left,
        "repo_right": summary.repo_right,
        "started_at": summary.started_at.isoformat(),
        "finished_at": summary.finished_at.isoformat(),
        "force_direction": summary.force_direction,
        "actions": actions_payload,
    }
    return json.dumps(payload, indent=2, sort_keys=True)


def write_sync_artifact(
    fs: SyncFileSystem, repo_root: Path, summary: SyncSummary
) -> Path:
    """
    Write the sync summary artifact to disk.

    Args:
        fs (SyncFileSystem): Filesystem abstraction for I/O.
        repo_root (Path): Root directory to anchor artifacts folder.
        summary (SyncSummary): Summary to serialize and write.

    Returns:
        Path: Path to the written artifact.

    Side Effects:
        Creates the artifacts/agentic-sync directory and writes a JSON file.
    """
    artifact_path = build_artifact_path(repo_root, summary.started_at)
    fs.ensure_dir(artifact_path.parent)
    fs.write_text(artifact_path, render_sync_summary(summary))
    return artifact_path
