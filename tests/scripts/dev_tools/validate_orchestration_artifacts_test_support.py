"""Shared builders for orchestration-artifact and epic-checkpoint validator tests."""

from __future__ import annotations

from typing import TYPE_CHECKING

if TYPE_CHECKING:
    from collections.abc import Callable
    from pathlib import Path


def build_valid_epic_state() -> dict[str, object]:
    """Return a minimally valid, wave-barrier-clean epic checkpoint payload."""

    return {
        "objective": "deliver epic-orchestrate-275",
        "route_id": "epic",
        "epic_feature_folder": "epic-orchestrate-275",
        "epic_manifest_path": "docs/features/epics/epic-orchestrate-275/epic-plan.md",
        "integration_branch": "epic/epic-orchestrate-275-integration",
        "max_parallel_features": 4,
        "completed_steps": ["epic_manifest_parsed"],
        "next_step": "wave_1_launch",
        "last_updated": "2026-07-02T20-00",
        "current_wave": 1,
        "waves": [
            {"wave_number": 0, "feature_folders": ["2026-07-02-child-a-300"]},
            {"wave_number": 1, "feature_folders": ["2026-07-02-child-b-301"]},
        ],
        "features": [
            {
                "feature_folder": "2026-07-02-child-a-300",
                "issue_num": 300,
                "depends_on": [],
                "wave_number": 0,
                "worktree_path": "/repo/worktrees/child-a",
                "merge_status": "merged",
                "merge_confirmed_at": "2026-07-02T18-00",
                "worktree_created_at": "2026-07-02T17-00",
            },
            {
                "feature_folder": "2026-07-02-child-b-301",
                "issue_num": 301,
                "depends_on": ["2026-07-02-child-a-300"],
                "wave_number": 1,
                "worktree_path": "/repo/worktrees/child-b",
                "merge_status": "not_started",
                "worktree_created_at": "2026-07-02T19-00",
            },
        ],
    }


def build_read_text_stub(text: str) -> Callable[[Path], str]:
    """Return a typed `_read_text` replacement for monkeypatched CLI tests."""

    def _stub(_path: Path) -> str:
        return text

    return _stub
