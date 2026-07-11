"""In-memory launcher evidence fixtures for epic-planner readiness tests."""

from __future__ import annotations

import hashlib
import json
from pathlib import Path
from typing import Any, cast

from scripts.dev_tools.epic_planner_readiness import EpicReadinessContext


def _binding(feature: dict[str, Any]) -> dict[str, object]:
    """Build the launch fields shared by the feature, spec, and receipt."""

    delegation = cast("dict[str, object]", feature["delegation_receipt"])
    model = cast("dict[str, object]", feature["model_routing_receipt"])
    return {
        "issue_num": feature["issue_num"],
        "feature_folder": feature["feature_folder"],
        "delegation_id": delegation["delegation_id"],
        "deployment_agent": model["deployment_agent"],
        "model": model["model"],
        "model_reasoning_effort": model["model_reasoning_effort"],
        "execution_context": "epic_preparation_child",
        "branch_name": feature["branch_name"],
        "worktree_path": feature["worktree_path"],
    }


def add_launch_evidence(
    files: dict[str, str], state: dict[str, Any], *, root: str = "C:/workspace"
) -> None:
    """Add one sealed shared preparation wave to an in-memory repository."""

    features = cast("list[dict[str, Any]]", state["features"])
    artifact = "artifacts/orchestration/epic-child-launches/preparation"
    absolute_artifact = f"{root}/{artifact}"
    spec_path = f"{absolute_artifact}/launch-spec.json"
    launches: list[dict[str, object]] = []
    for feature in features:
        launch_id = f"feature-{feature['issue_num']}"
        launches.append({"launch_id": launch_id, **_binding(feature)})
    spec_text = json.dumps(
        {"wave_id": "preparation", "launches": launches}, separators=(",", ":")
    )
    files[spec_path] = spec_text
    spec_sha256 = hashlib.sha256(spec_text.encode("utf-8")).hexdigest()
    status_launches: dict[str, object] = {}
    for feature in features:
        launch_id = f"feature-{feature['issue_num']}"
        session_id = f"session-{feature['issue_num']}"
        receipt_path = f"{absolute_artifact}/{launch_id}.receipt.json"
        receipt = {
            "schema_version": 2,
            "state": "completed",
            "exit_code": 0,
            "launch_id": launch_id,
            "wave_id": "preparation",
            **_binding(feature),
            "spec_path": spec_path,
            "spec_sha256": spec_sha256,
            "receipt_path": receipt_path,
            "status_path": f"{absolute_artifact}/wave.preparation.status.json",
            "codex_session_id": session_id,
            "session_bound_at": "2026-07-10T09:00:00+00:00",
            "completed_at": "2026-07-10T09:30:00+00:00",
        }
        files[receipt_path] = json.dumps(receipt)
        status_launches[launch_id] = {
            "state": "completed",
            "exit_code": 0,
            "receipt_path": receipt_path,
            "codex_session_id": session_id,
            "completed_at": "2026-07-10T09:30:00+00:00",
        }
    status_path = f"{absolute_artifact}/wave.preparation.status.json"
    files[status_path] = json.dumps(
        {
            "schema_version": 2,
            "wave_id": "preparation",
            "state": "completed",
            "failure": "",
            "launches": status_launches,
        }
    )


class LaunchEvidenceMemoryFileSystem:
    """Minimal in-memory filesystem for direct launch-evidence validation."""

    def __init__(self, files: dict[str, str]) -> None:
        self.files = files

    def is_file(self, path: Path) -> bool:
        return path.as_posix() in self.files

    def is_dir(self, path: Path) -> bool:
        del path
        return False

    def read_text(self, path: Path) -> str:
        return self.files[path.as_posix()]

    def read_bytes(self, path: Path) -> bytes:
        return self.files[path.as_posix()].encode("utf-8")

    def glob(self, directory: Path, pattern: str) -> list[Path]:
        del directory, pattern
        return []


class UnusedGitRepository:
    """Readiness Git seam that is not consulted by direct evidence tests."""

    def ref_exists(self, ref: str) -> bool:
        del ref
        return False

    def commit_exists(self, commit: str) -> bool:
        del commit
        return False

    def is_ancestor(self, commit: str, ref: str) -> bool:
        del commit, ref
        return False

    def last_commit(self, path: str) -> str | None:
        del path
        return None

    def committed_blob_hash(self, ref: str, path: str) -> str | None:
        del ref, path
        return None

    def worktree_blob_hash(self, path: str) -> str | None:
        del path
        return None


def _minimal_feature(issue_num: int) -> dict[str, Any]:
    """Build one preparation-child identity for evidence tests."""

    folder = f"docs/features/active/feature-{issue_num}"
    delegation_id = f"prepare-{issue_num}"
    launch_root = "artifacts/orchestration/epic-child-launches/preparation"
    return {
        "issue_num": issue_num,
        "feature_folder": folder,
        "branch_name": f"feature/feature-{issue_num}",
        "worktree_path": f"/repo/worktrees/feature-{issue_num}",
        "delegation_receipt": {
            "delegation_id": delegation_id,
            "feature_folder": folder,
            "issue_num": issue_num,
            "agent_name": "orchestrator-c3-elevated",
        },
        "model_routing_receipt": {
            "delegation_id": delegation_id,
            "deployment_agent": "orchestrator-c3-elevated",
            "model": "gpt-5.6-sol",
            "model_reasoning_effort": "high",
            "execution_context": "epic_preparation_child",
        },
        "launch_receipt_path": f"{launch_root}/feature-{issue_num}.receipt.json",
        "launch_status_path": f"{launch_root}/wave.preparation.status.json",
    }


def launch_evidence_fixture() -> (
    tuple[dict[str, Any], EpicReadinessContext, LaunchEvidenceMemoryFileSystem]
):
    """Build a minimal repository fixture for direct evidence validation."""

    state: dict[str, Any] = {"features": [_minimal_feature(101), _minimal_feature(102)]}
    files: dict[str, str] = {}
    add_launch_evidence(files, state)
    file_system = LaunchEvidenceMemoryFileSystem(files)
    context = EpicReadinessContext(
        workspace_root=Path("C:/workspace"),
        artifact_path=Path(
            "C:/workspace/artifacts/orchestration/epic-planner-state.json"
        ),
        file_system=file_system,
        git=UnusedGitRepository(),
    )
    return state, context, file_system
