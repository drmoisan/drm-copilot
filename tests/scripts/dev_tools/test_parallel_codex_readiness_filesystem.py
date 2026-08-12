"""In-memory tests for file-backed parallel Codex readiness evidence."""

from __future__ import annotations

import copy
import json
from pathlib import Path
from typing import cast

import pytest

from scripts.dev_tools.parallel_codex_readiness_filesystem import (
    ParallelReadinessFileContext,
    build_parallel_codex_readiness_evidence,
)
from tests.scripts.dev_tools.test_parallel_kickoff_contract import (
    kickoff,
    kickoff_with_integrity,
)

ROOT = Path("C:/workspace")
COMMIT = "e" * 40
BLOB = "a" * 40
KICKOFF_PATH = "docs/features/parallel/sample-run/parallel-kickoff.md"


def _key(path: Path) -> str:
    """Normalize paths to the POSIX keys used by the memory filesystem."""

    return str(path).replace("\\", "/")


class MemoryFileSystem:
    """Read-only in-memory filesystem that records every attempted read."""

    def __init__(self, files: dict[str, str]) -> None:
        self.files = files
        self.reads: list[str] = []

    def is_file(self, path: Path) -> bool:
        """Return whether the normalized path exists in memory."""

        return _key(path) in self.files

    def read_text(self, path: Path) -> str:
        """Read one in-memory file and record its normalized path."""

        key = _key(path)
        self.reads.append(key)
        return self.files[key]


class MemoryGitRepository:
    """Configurable Git identity fake with no external process calls."""

    def __init__(self, *, commit: str = COMMIT, drift: bool = False) -> None:
        self.commit = commit
        self.drift = drift

    def resolve_commit(self, ref: str) -> str | None:
        """Return the configured plan-home commit."""

        assert ref == "origin/parallel/sample-run-plan"
        return self.commit

    def committed_blob_hash(self, ref: str, path: str) -> str | None:
        """Return the configured committed kickoff blob."""

        assert ref == "origin/parallel/sample-run-plan"
        assert path == KICKOFF_PATH
        return BLOB

    def worktree_blob_hash(self, path: str) -> str | None:
        """Return a matching or deliberately drifted worktree blob."""

        assert path == KICKOFF_PATH
        return "b" * 40 if self.drift else BLOB


def checkpoint(*, second_item: bool = False) -> dict[str, object]:
    """Return the loader-facing checkpoint fields for one or two items."""

    items: list[dict[str, object]] = [
        {
            "launch_receipt_path": "artifacts/orchestration/item-101.launch.json",
            "launch_status_path": "artifacts/orchestration/item-101.status.json",
        }
    ]
    if second_item:
        items.append(
            {
                "launch_receipt_path": ("artifacts/orchestration/item-202.launch.json"),
                "launch_status_path": "artifacts/orchestration/item-202.status.json",
            }
        )
    return {
        "parallel_slug": "sample-run",
        "kickoff_prompt_path": KICKOFF_PATH,
        "items": items,
    }


def launch_record(item_key: int, *, status: str = "PRESERVED") -> dict[str, object]:
    """Return one path-complete launch record with a shared ledger."""

    prefix = f"artifacts/orchestration/item-{item_key}"
    return {
        "launch_receipt_path": f"{prefix}.launch.json",
        "launch_status_path": f"{prefix}.status.json",
        "authority_receipt_path": f"{prefix}.authority.json",
        "delegation_receipt_path": f"{prefix}.delegation.json",
        "topology_receipt_path": f"{prefix}.topology.json",
        "model_routing_receipt_path": f"{prefix}.model-routing.json",
        "enforceability_ledger": [{"gate_id": "G01", "status": status}],
    }


def valid_files(*, second_item: bool = False) -> dict[str, str]:
    """Return all guarded files required by the loader."""

    files = {_key(ROOT / KICKOFF_PATH): kickoff_with_integrity()}
    for item_key in ((101, 202) if second_item else (101,)):
        prefix = f"artifacts/orchestration/item-{item_key}"
        files[_key(ROOT / f"{prefix}.launch.json")] = json.dumps(
            launch_record(item_key)
        )
        files[_key(ROOT / f"{prefix}.status.json")] = json.dumps(
            {
                "state": "completed",
                "launch_receipt_path": f"{prefix}.launch.json",
            }
        )
        for suffix in ("authority", "delegation", "topology", "model-routing"):
            files[_key(ROOT / f"{prefix}.{suffix}.json")] = json.dumps(
                {"receipt": suffix}
            )
    return files


def build(
    state: dict[str, object],
    file_system: MemoryFileSystem,
    *,
    git: MemoryGitRepository | None = None,
):
    """Build evidence through injected in-memory filesystem and Git seams."""

    context = ParallelReadinessFileContext(
        workspace_root=ROOT,
        artifact_path=ROOT / "artifacts/orchestration/parallel-planner-state.json",
        file_system=file_system,
        git=git or MemoryGitRepository(),
    )
    return build_parallel_codex_readiness_evidence(json.dumps(state), context)


def test_loads_guarded_records_ledger_and_committed_kickoff() -> None:
    """Complete guarded evidence produces a bound readiness object."""

    result = build(checkpoint(), MemoryFileSystem(valid_files()))

    assert result.errors == ()
    assert result.evidence is not None
    assert result.evidence.enforceability_ledger == [
        {"gate_id": "G01", "status": "PRESERVED"}
    ]
    assert result.evidence.kickoff_identity is not None
    assert result.evidence.kickoff_identity["planning_commit"] == COMMIT


@pytest.mark.parametrize(
    "unsafe_path", ["../outside.json", "C:/absolute.json", "/absolute.json", "a\\b"]
)
def test_rejects_unsafe_launch_paths_without_outside_reads(unsafe_path: str) -> None:
    """Traversal, absolute, drive, and backslash paths fail before I/O."""

    state = checkpoint()
    items = state["items"]
    assert isinstance(items, list)
    item = cast("object", items[0])
    assert isinstance(item, dict)
    cast("dict[str, object]", item)["launch_receipt_path"] = unsafe_path
    file_system = MemoryFileSystem(valid_files())

    result = build(state, file_system)

    assert any("guarded repository-relative" in error for error in result.errors)
    assert not any(unsafe_path in path for path in file_system.reads)


def test_rejects_missing_and_invalid_referenced_json() -> None:
    """Missing launch data and malformed receipt JSON are reported in order."""

    files = valid_files()
    del files[_key(ROOT / "artifacts/orchestration/item-101.launch.json")]
    missing = build(checkpoint(), MemoryFileSystem(files))
    malformed_files = valid_files()
    malformed_files[_key(ROOT / "artifacts/orchestration/item-101.topology.json")] = "{"
    malformed = build(checkpoint(), MemoryFileSystem(malformed_files))

    assert any("launch record is missing" in error for error in missing.errors)
    assert any("is not valid JSON" in error for error in malformed.errors)


def test_rejects_status_binding_mismatch() -> None:
    """A status document cannot bind to another launch receipt."""

    files = valid_files()
    files[_key(ROOT / "artifacts/orchestration/item-101.status.json")] = json.dumps(
        {"state": "completed", "launch_receipt_path": "other.json"}
    )

    result = build(checkpoint(), MemoryFileSystem(files))

    assert any("status receipt binding is mismatched" in e for e in result.errors)


def test_rejects_ledger_disagreement_and_lost_status() -> None:
    """Items must share one normalized ledger and no row may be LOST."""

    disagreeing = valid_files(second_item=True)
    disagreeing[_key(ROOT / "artifacts/orchestration/item-202.launch.json")] = (
        json.dumps(launch_record(202, status="DEGRADED"))
    )
    disagreement = build(checkpoint(second_item=True), MemoryFileSystem(disagreeing))
    lost_files = valid_files()
    lost_files[_key(ROOT / "artifacts/orchestration/item-101.launch.json")] = (
        json.dumps(launch_record(101, status="LOST"))
    )
    lost = build(checkpoint(), MemoryFileSystem(lost_files))

    assert any("one identical normalized" in e for e in disagreement.errors)
    assert any("status LOST blocks" in e for e in lost.errors)


def test_rejects_kickoff_commit_and_blob_mismatches() -> None:
    """The kickoff must match both the plan-home commit and committed blob."""

    commit = build(
        checkpoint(),
        MemoryFileSystem(valid_files()),
        git=MemoryGitRepository(commit="f" * 40),
    )
    blob = build(
        checkpoint(),
        MemoryFileSystem(valid_files()),
        git=MemoryGitRepository(drift=True),
    )

    assert any("planning_commit must match" in e for e in commit.errors)
    assert any("worktree content must match" in e for e in blob.errors)


def test_requires_kickoff_integrity_without_mutating_inputs() -> None:
    """Missing identity fails closed and source mappings remain unchanged."""

    state = checkpoint()
    files = valid_files()
    files[_key(ROOT / KICKOFF_PATH)] = kickoff()
    state_snapshot = copy.deepcopy(state)
    files_snapshot = copy.deepcopy(files)

    result = build(state, MemoryFileSystem(files))

    assert any("planning_commit is required" in error for error in result.errors)
    assert state == state_snapshot
    assert files == files_snapshot
