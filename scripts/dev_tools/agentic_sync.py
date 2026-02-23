"""
Synchronize shared .github documents between two local repos.

Purpose:
    Ensures that shared governance documents under .github/agents,
    .github/instructions, .github/prompts, and .github/skills stay aligned
    between two repository workspaces. The newest content is propagated when
    files differ, and timestamps are normalized to match when changes are made.
"""

from __future__ import annotations

import argparse
import json
import logging
import os
from dataclasses import dataclass
from datetime import datetime, timezone
from pathlib import Path
from typing import Literal, Protocol

LOGGER = logging.getLogger(__name__)

ROOT_FOLDERS: tuple[Path, ...] = (
    Path(".github/agents"),
    Path(".github/instructions"),
    Path(".github/prompts"),
    Path(".github/skills"),
)

DecisionType = Literal["equivalent-mtime", "equivalent-content", "synced"]
ForceDirection = Literal["left-to-right", "right-to-left"]


class SyncFileSystem(Protocol):
    """
    Protocol for filesystem operations required by the sync engine.

    Purpose:
        Abstracts file system access so that unit tests can run without touching
        the real filesystem, while production uses a concrete implementation.

    Usage:
        Implement with RealSyncFileSystem for production or an in-memory test
        double for unit tests.

    Invariants / Constraints:
        - Paths passed in are absolute or workspace-relative Path objects.
        - get_mtime raises FileNotFoundError for missing paths.
        - read_text raises FileNotFoundError for missing paths.

    Side Effects:
        Implementations may read/write disk, or mutate in-memory stores.
    """

    def list_files(self, root: Path) -> list[Path]:
        """Return all files under root (recursive)."""
        ...

    def is_file(self, path: Path) -> bool:
        """Return True when path exists and is a file."""
        ...

    def read_text(self, path: Path) -> str:
        """Read UTF-8 text from path."""
        ...

    def write_text(self, path: Path, content: str) -> None:
        """Write UTF-8 text to path."""
        ...

    def get_mtime(self, path: Path) -> float:
        """Return file modification time (seconds since epoch)."""
        ...

    def set_mtime(self, path: Path, mtime: float) -> None:
        """Set file modification time (seconds since epoch)."""
        ...

    def ensure_dir(self, path: Path) -> None:
        """Ensure directory exists (create if missing)."""
        ...


class RealSyncFileSystem:
    """
    Concrete filesystem implementation for sync operations.

    Purpose:
        Uses pathlib and os utilities to read/write files and mutate timestamps
        on the real filesystem.

    Usage:
        Injected into AgenticSyncer for production runs.

    Side Effects:
        Reads and writes files on disk and updates file timestamps.
    """

    def list_files(self, root: Path) -> list[Path]:
        """
        Return all files under root (recursive).

        Purpose:
            Provide a deterministic list of files to sync under a root folder.

        Args:
            root (Path): Directory to scan.

        Returns:
            list[Path]: Sorted list of files under root.

        Raises:
            None.

        Side Effects:
            Reads directory contents from disk.
        """
        if not root.is_dir():
            return []

        files: list[Path] = []
        # Collect file paths to provide a deterministic, sorted list for sync.
        for path in root.rglob("*"):
            if path.is_file():
                files.append(path)
        return sorted(files)

    def is_file(self, path: Path) -> bool:
        """
        Return True when path exists and is a file.

        Purpose:
            Provide a lightweight file existence check for sync logic.

        Args:
            path (Path): File path to check.

        Returns:
            bool: True if path is a file, False otherwise.

        Raises:
            None.

        Side Effects:
            Reads filesystem metadata.
        """
        return path.is_file()

    def read_text(self, path: Path) -> str:
        """
        Read UTF-8 text from path.

        Purpose:
            Load file content for comparison and syncing.

        Args:
            path (Path): File path to read.

        Returns:
            str: File contents.

        Raises:
            FileNotFoundError: When the file is missing.

        Side Effects:
            Reads file content from disk.
        """
        return path.read_text(encoding="utf-8")

    def write_text(self, path: Path, content: str) -> None:
        """
        Write UTF-8 text to path.

        Purpose:
            Persist updated file content to disk during synchronization.

        Args:
            path (Path): File path to write.
            content (str): Content to write.

        Returns:
            None.

        Raises:
            None.

        Side Effects:
            Writes file content to disk and updates modification time.
        """
        path.parent.mkdir(parents=True, exist_ok=True)
        path.write_text(content, encoding="utf-8")

    def get_mtime(self, path: Path) -> float:
        """
        Return file modification time (seconds since epoch).

        Purpose:
            Provide mtime values for timestamp comparisons.

        Args:
            path (Path): File path to inspect.

        Returns:
            float: Modification time in seconds since epoch.

        Raises:
            FileNotFoundError: When the file is missing.

        Side Effects:
            Reads filesystem metadata.
        """
        return path.stat().st_mtime

    def set_mtime(self, path: Path, mtime: float) -> None:
        """
        Set file modification time (seconds since epoch).

        Purpose:
            Normalize timestamps after syncing content.

        Args:
            path (Path): File path to update.
            mtime (float): Target modification time.

        Returns:
            None.

        Raises:
            None.

        Side Effects:
            Updates file timestamps on disk.
        """
        os.utime(path, (mtime, mtime))

    def ensure_dir(self, path: Path) -> None:
        """
        Ensure directory exists (create if missing).

        Purpose:
            Prepare artifact output directories before writing logs.

        Args:
            path (Path): Directory path to create.

        Returns:
            None.

        Raises:
            None.

        Side Effects:
            Creates directories on disk.
        """
        path.mkdir(parents=True, exist_ok=True)


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


class AgenticSyncer:
    """
    Synchronize matching .github files between two repositories.

    Purpose:
        Implements the comparison rules for shared .github documents, including
        timestamp equivalence logic, content comparison, and bidirectional sync.

    Usage:
        syncer = AgenticSyncer(RealSyncFileSystem())
        summary = syncer.sync_repos(left_repo, right_repo)

    Flow:
        1. Enumerate files under the scoped .github roots for each repo.
        2. Match files by relative path within each root.
        3. Apply timestamp/content comparison rules to determine equivalence.
        4. Sync content from the newer (or forced) file when differences exist.
        5. Normalize timestamps when writes occur.

    Invariants / Constraints:
        - Only files present in both repos are considered.
        - Timestamp equivalence threshold defaults to 180 seconds.
        - Forced direction bypasses timestamp-equivalence short-circuiting.

    Side Effects:
        Reads and writes files via the injected filesystem.
    """

    def __init__(
        self,
        fs: SyncFileSystem,
        *,
        threshold_seconds: int = 180,
        force_direction: ForceDirection | None = None,
    ) -> None:
        """
        Initialize the sync engine.

        Args:
            fs (SyncFileSystem): Filesystem abstraction for I/O.
            threshold_seconds (int): Threshold in seconds for mtime equivalence.
            force_direction (ForceDirection | None): Optional forced direction.
            clock (callable): Clock returning epoch seconds for timestamps.

        Raises:
            ValueError: If threshold_seconds is negative.
        """
        if threshold_seconds < 0:
            raise ValueError("threshold_seconds must be non-negative")
        self._fs = fs
        self._threshold_seconds = threshold_seconds
        self._force_direction: ForceDirection | None = force_direction

    def sync_repos(self, left_repo: Path, right_repo: Path) -> SyncSummary:
        """
        Synchronize matching .github files between two repos.

        Purpose:
            Applies the sync rules across all scoped .github roots and returns
            a detailed summary of actions.

        Args:
            left_repo (Path): Left repository workspace.
            right_repo (Path): Right repository workspace.

        Returns:
            SyncSummary: Summary of per-file decisions and timing.
        """
        started = datetime.now(timezone.utc)
        actions: list[SyncAction] = []

        # Process each governance root separately to avoid cross-category matches.
        for root in ROOT_FOLDERS:
            left_root = left_repo / root
            right_root = right_repo / root
            left_map = self._collect_files(left_root)
            right_map = self._collect_files(right_root)

            # Compare only files present in both repos to avoid one-way copies.
            shared_relatives = sorted(set(left_map) & set(right_map))
            for relative_path in shared_relatives:
                action = self._sync_pair(
                    root=root.as_posix(),
                    relative_path=relative_path,
                    left_path=left_map[relative_path],
                    right_path=right_map[relative_path],
                )
                actions.append(action)

        finished = datetime.now(timezone.utc)
        return SyncSummary(
            repo_left=str(left_repo),
            repo_right=str(right_repo),
            started_at=started,
            finished_at=finished,
            force_direction=self._force_direction,
            actions=actions,
        )

    def _collect_files(self, root: Path) -> dict[str, Path]:
        """
        Collect files under a root directory keyed by relative path.

        Purpose:
            Builds a mapping to support matching by relative file paths.

        Args:
            root (Path): Root directory to scan.

        Returns:
            dict[str, Path]: Mapping of relative POSIX paths to full paths.

        Raises:
            None.

        Side Effects:
            Reads directory contents via the filesystem abstraction.
        """
        files: dict[str, Path] = {}

        # Gather files under root so matching uses consistent relative keys.
        for path in self._fs.list_files(root):
            if not self._fs.is_file(path):
                continue
            relative = path.relative_to(root).as_posix()
            files[relative] = path
        return files

    def _sync_pair(
        self,
        *,
        root: str,
        relative_path: str,
        left_path: Path,
        right_path: Path,
    ) -> SyncAction:
        """
        Apply sync rules to a single file pair.

        Purpose:
            Implements the timestamp equivalence logic, content comparison, and
            bidirectional sync behavior for a matched file pair.

        Args:
            root (str): Root folder name (e.g., ".github/agents").
            relative_path (str): File path relative to root.
            left_path (Path): Full path to the left repo file.
            right_path (Path): Full path to the right repo file.

        Returns:
            SyncAction: Recorded outcome for this file pair.
        """
        left_mtime = self._fs.get_mtime(left_path)
        right_mtime = self._fs.get_mtime(right_path)

        # Decision tree: when not forced, short-circuit on near-equal mtimes.
        if self._force_direction is None:
            if self._mtimes_equivalent(left_mtime, right_mtime):
                return SyncAction(
                    root=root,
                    relative_path=relative_path,
                    left_path=left_path.as_posix(),
                    right_path=right_path.as_posix(),
                    left_mtime=left_mtime,
                    right_mtime=right_mtime,
                    decision="equivalent-mtime",
                    source=None,
                    sync_mtime=None,
                    forced=False,
                )

        left_content = self._fs.read_text(left_path)
        right_content = self._fs.read_text(right_path)

        # Branch by content equality: only sync when content differs.
        if left_content == right_content:
            return SyncAction(
                root=root,
                relative_path=relative_path,
                left_path=left_path.as_posix(),
                right_path=right_path.as_posix(),
                left_mtime=left_mtime,
                right_mtime=right_mtime,
                decision="equivalent-content",
                source=None,
                sync_mtime=None,
                forced=False,
            )

        source_label, source_content, source_mtime = self._select_source(
            left_content=left_content,
            right_content=right_content,
            left_mtime=left_mtime,
            right_mtime=right_mtime,
        )

        # Sync both files to the chosen content and normalize timestamps.
        self._fs.write_text(left_path, source_content)
        self._fs.write_text(right_path, source_content)
        self._fs.set_mtime(left_path, source_mtime)
        self._fs.set_mtime(right_path, source_mtime)

        return SyncAction(
            root=root,
            relative_path=relative_path,
            left_path=left_path.as_posix(),
            right_path=right_path.as_posix(),
            left_mtime=left_mtime,
            right_mtime=right_mtime,
            decision="synced",
            source=source_label,
            sync_mtime=source_mtime,
            forced=self._force_direction is not None,
        )

    def _mtimes_equivalent(self, left_mtime: float, right_mtime: float) -> bool:
        """
        Determine whether two mtimes are within the equivalence threshold.

        Purpose:
            Treat near-equal timestamps as equivalent to avoid redundant syncs.

        Args:
            left_mtime (float): Left file mtime.
            right_mtime (float): Right file mtime.

        Returns:
            bool: True if mtimes are within threshold, False otherwise.

        Raises:
            None.

        Side Effects:
            None.
        """
        return abs(left_mtime - right_mtime) <= self._threshold_seconds

    def _select_source(
        self,
        *,
        left_content: str,
        right_content: str,
        left_mtime: float,
        right_mtime: float,
    ) -> tuple[str, str, float]:
        """
        Select the source content and mtime for syncing.

        Purpose:
            Choose the content to propagate based on forced direction or
            modification timestamps when no force is applied.

        Args:
            left_content (str): Left file content.
            right_content (str): Right file content.
            left_mtime (float): Left file mtime.
            right_mtime (float): Right file mtime.

        Returns:
            tuple[str, str, float]: (source_label, content, mtime)

        Raises:
            None.

        Side Effects:
            None.
        """
        # Forced direction overrides timestamp comparison to ensure one-way sync.
        if self._force_direction == "left-to-right":
            return "left", left_content, left_mtime
        if self._force_direction == "right-to-left":
            return "right", right_content, right_mtime

        # Branch by mtime to select the newer file; ties default to left.
        if left_mtime > right_mtime:
            return "left", left_content, left_mtime
        if right_mtime > left_mtime:
            return "right", right_content, right_mtime
        return "left", left_content, left_mtime


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
    actions_payload: list[dict[str, object]] = []
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

    payload = {
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


def parse_args(argv: list[str] | None = None) -> argparse.Namespace:
    """
    Parse command-line arguments.

    Args:
        argv (list[str] | None): Optional argv override for testing.

    Returns:
        argparse.Namespace: Parsed arguments.
    """
    parser = argparse.ArgumentParser(
        description="Sync shared .github documents between two repos."
    )
    parser.add_argument(
        "left_repo",
        help="Path to the left repository workspace.",
    )
    parser.add_argument(
        "right_repo",
        help="Path to the right repository workspace.",
    )
    group = parser.add_mutually_exclusive_group()
    group.add_argument(
        "--force-left-to-right",
        action="store_true",
        help="Force sync from left repo to right repo.",
    )
    group.add_argument(
        "--force-right-to-left",
        action="store_true",
        help="Force sync from right repo to left repo.",
    )
    parser.add_argument(
        "--threshold-seconds",
        type=int,
        default=180,
        help="Seconds for mtime equivalence (default: 180).",
    )
    return parser.parse_args(argv)


def main(argv: list[str] | None = None) -> int:
    """
    CLI entry point for agentic sync.

    Purpose:
        Runs the sync process and writes a JSON artifact summarizing the run.

    Args:
        argv (list[str] | None): Optional argv override.

    Returns:
        int: Exit code (0 for success).

    Raises:
        ValueError: When repo paths are invalid.
    """
    args = parse_args(argv)
    left_repo = Path(args.left_repo).expanduser().resolve()
    right_repo = Path(args.right_repo).expanduser().resolve()

    # Validate repository paths before sync to avoid silent no-ops.
    if not left_repo.is_dir():
        raise ValueError(f"Left repo is not a directory: {left_repo}")
    if not right_repo.is_dir():
        raise ValueError(f"Right repo is not a directory: {right_repo}")

    force_direction: ForceDirection | None = None
    # Choose forced direction flag if specified by the user.
    if args.force_left_to_right:
        force_direction = "left-to-right"
    elif args.force_right_to_left:
        force_direction = "right-to-left"

    syncer = AgenticSyncer(
        RealSyncFileSystem(),
        threshold_seconds=args.threshold_seconds,
        force_direction=force_direction,
    )
    summary = syncer.sync_repos(left_repo, right_repo)

    artifact_path = write_sync_artifact(RealSyncFileSystem(), Path.cwd(), summary)
    LOGGER.info("Wrote sync artifact to %s", artifact_path.as_posix())
    print(f"Wrote sync artifact to: {artifact_path}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
