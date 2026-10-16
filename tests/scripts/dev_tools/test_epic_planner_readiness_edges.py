"""Edge-case tests for epic-planner readiness file and kickoff checks."""

from __future__ import annotations

from pathlib import Path
from typing import Any

import pytest

from scripts.dev_tools.epic_planner_readiness import (
    EpicReadinessContext,
    validate_epic_readiness_integrity,
)
from tests.scripts.dev_tools.epic_planner_launch_evidence_test_support import (
    UnusedGitRepository,
)
from tests.scripts.dev_tools.typescript_twin_test_support import (
    literals_missing_from_twin,
)

ROOT = "C:/workspace"
FOLDER = "docs/features/active/feature-101"
PLAN = "docs/features/active/feature-101/plan.md"
RESEARCH = "artifacts/research/feature-101.md"
EVIDENCE = "docs/features/active/feature-101/evidence/preflight.md"
OTHER_EVIDENCE = "docs/features/active/feature-102/evidence/preflight.md"
MANIFEST = "docs/features/epics/sample-epic/epic.md"
BRANCH = "epic/sample-epic-integration"
KICKOFF = "docs/features/epics/sample-epic/epic-kickoff.md"

PLAN_INSIDE_ERROR = (
    "Epic planner checkpoint features[0].plan_path must be inside its feature_folder."
)
INDEX_ONE_PLAN_INSIDE_ERROR = (
    "Epic planner checkpoint features[1].plan_path must be inside its feature_folder."
)
EVIDENCE_INSIDE_ERROR = (
    "Epic planner checkpoint features[0].preflight_evidence_path "
    "must be inside its feature_folder."
)
PREFLIGHT_REQUIRED_ERROR = (
    "Execution readiness requires preflight evidence containing "
    "'PREFLIGHT: ALL CLEAR' under docs/features/active/feature-101."
)
KICKOFF_SLUG_ERROR = (
    "Committed kickoff slug and /epic-run slug must match state 'sample-epic'."
)
ASSERTED_MESSAGES = (
    PLAN_INSIDE_ERROR,
    INDEX_ONE_PLAN_INSIDE_ERROR,
    EVIDENCE_INSIDE_ERROR,
    PREFLIGHT_REQUIRED_ERROR,
    KICKOFF_SLUG_ERROR,
)
UNREADABLE_ISSUE_ERROR = (
    "Execution readiness could not read Epic planner checkpoint features[0] issue.md "
    "docs/features/active/feature-101/issue.md: denied"
)

KICKOFF_TEXT = "\n".join(
    [
        "# Epic Kickoff: other-epic",
        "## Invocation Prompt",
        "Run `/epic-run sample-epic` to execute this epic.",
        "Use the epic-orchestrator subagent to execute the prepared epic at",
        "docs/features/epics/sample-epic/epic.md. Reuse epic/sample-epic-integration.",
        "Every child resumes at atomic execution from its committed plan-path;",
        "do not repeat planning or preflight.",
        "## Feature Summary",
        "| issue_num | feature_folder | wave | complexity | plan-path |",
        "| --- | --- | --- | --- | --- |",
        f"| 101 | {FOLDER} | 0 | C3 | {PLAN} |",
    ]
)


class EdgeFileSystem:
    """In-memory readiness filesystem with one feature folder and denied reads."""

    def __init__(
        self, files: dict[str, str], unreadable: frozenset[str] = frozenset()
    ) -> None:
        self.files = files
        self.unreadable = unreadable

    def is_file(self, path: Path) -> bool:
        return path.as_posix() in self.files

    def is_dir(self, path: Path) -> bool:
        return path.as_posix() == f"{ROOT}/{FOLDER}"

    def read_text(self, path: Path) -> str:
        if path.as_posix() in self.unreadable:
            raise OSError("denied")
        return self.files[path.as_posix()]

    def read_bytes(self, path: Path) -> bytes:
        return self.read_text(path).encode("utf-8")

    def glob(self, directory: Path, pattern: str) -> list[Path]:
        del directory, pattern
        return []


def _repository_files() -> dict[str, str]:
    """Build an in-memory repository holding every required feature document."""

    return {
        f"{ROOT}/{FOLDER}/issue.md": "# Issue",
        f"{ROOT}/{FOLDER}/spec.md": "# Spec",
        f"{ROOT}/{FOLDER}/user-story.md": "# User story",
        f"{ROOT}/{FOLDER}/plan.md": "# Plan",
        f"{ROOT}/{RESEARCH}": "# Research",
        f"{ROOT}/{EVIDENCE}": "PREFLIGHT: ALL CLEAR",
    }


def _feature(**overrides: object) -> dict[str, object]:
    """Build one keyless feature entry with the given overrides."""

    return {
        "feature_folder": FOLDER,
        "plan_path": PLAN,
        "research_path": RESEARCH,
        **overrides,
    }


def _errors(
    features: list[object],
    *,
    files: dict[str, str] | None = None,
    unreadable: frozenset[str] = frozenset(),
) -> list[str]:
    """Validate readiness for the given features against an in-memory repository."""

    state: dict[str, Any] = {
        "epic_feature_folder": "sample-epic",
        "epic_manifest_path": MANIFEST,
        "integration_branch": BRANCH,
        "features": features,
    }
    context = EpicReadinessContext(
        workspace_root=Path(ROOT),
        artifact_path=Path(f"{ROOT}/artifacts/orchestration/epic-planner-state.json"),
        file_system=EdgeFileSystem(
            _repository_files() if files is None else files, unreadable
        ),
        git=UnusedGitRepository(),
    )
    return validate_epic_readiness_integrity(
        state, "{}", context, require_launch_paths=True
    )


@pytest.mark.parametrize(
    "plan_path",
    [FOLDER, f"./{FOLDER}", "docs/features/active/feature-1010/plan.md"],
    ids=["equal-to-folder", "dot-prefixed-folder", "sibling-prefix"],
)
def test_plan_path_must_be_strictly_inside_feature_folder(plan_path: str) -> None:
    """Reject a plan_path that equals or merely prefixes its feature_folder."""

    features: list[object] = [_feature(plan_path=plan_path)]

    errors = _errors(features)

    assert PLAN_INSIDE_ERROR in errors


def test_plan_path_inside_feature_folder_is_accepted() -> None:
    """Accept a plan_path that lies inside its feature_folder."""

    features: list[object] = [_feature()]

    errors = _errors(features)

    assert PLAN_INSIDE_ERROR not in errors


def test_non_object_feature_entry_keeps_its_index() -> None:
    """Skip a non-object feature entry without shifting later indices."""

    features: list[object] = [
        "not-a-feature",
        _feature(plan_path="docs/features/active/feature-1010/plan.md"),
    ]

    errors = _errors(features)

    assert INDEX_ONE_PLAN_INSIDE_ERROR in errors


def test_unreadable_required_document_is_reported() -> None:
    """Report a required feature document whose read raises an OS error."""

    features: list[object] = [_feature()]
    unreadable = frozenset({f"{ROOT}/{FOLDER}/issue.md"})

    errors = _errors(features, unreadable=unreadable)

    assert UNREADABLE_ISSUE_ERROR in errors


def test_preflight_evidence_outside_feature_folder_is_rejected() -> None:
    """Reject explicit preflight evidence that lies outside the feature_folder."""

    features: list[object] = [_feature(preflight_evidence_path=OTHER_EVIDENCE)]

    errors = _errors(features)

    assert EVIDENCE_INSIDE_ERROR in errors
    assert PREFLIGHT_REQUIRED_ERROR in errors


def test_unreadable_preflight_evidence_is_skipped() -> None:
    """Skip unreadable preflight evidence and require readable evidence instead."""

    features: list[object] = [_feature(preflight_evidence_path=EVIDENCE)]
    unreadable = frozenset({f"{ROOT}/{EVIDENCE}"})

    errors = _errors(features, unreadable=unreadable)

    assert PREFLIGHT_REQUIRED_ERROR in errors
    assert EVIDENCE_INSIDE_ERROR not in errors


def test_kickoff_slug_mismatch_is_reported() -> None:
    """Report a committed kickoff whose heading slug differs from the state."""

    features: list[object] = [_feature()]
    files = _repository_files()
    files[f"{ROOT}/{KICKOFF}"] = KICKOFF_TEXT

    errors = _errors(features, files=files)

    assert KICKOFF_SLUG_ERROR in errors


def test_asserted_messages_match_typescript_twin() -> None:
    """Keep every asserted message identical to its TypeScript twin literal."""

    missing = literals_missing_from_twin(
        ASSERTED_MESSAGES, "lib/validate/epic-planner-readiness-edges.test.ts"
    )

    assert missing == []
