"""Static contract tests for feature-review remediation handoff decisions."""

from __future__ import annotations

from pathlib import Path

REPO_ROOT = Path(__file__).resolve().parents[3]

SKILL_PATHS = (
    Path(".agents/skills/feature-review/SKILL.md"),
    Path(".agents/skills/feature-review-workflow/SKILL.md"),
    Path(".agents/skills/remediation-handoff-atomic-planner/SKILL.md"),
)
REVIEWER_PATHS = SKILL_PATHS[:2]

CANONICAL_GRAMMAR = (
    "REVIEW_VERDICT: PASS | BLOCKED\n"
    "REMEDIATION_ACTION: NONE | AUTONOMOUS | NO_CANDIDATE | "
    "EXTERNAL_RUNTIME | AWAITING_CI | HUMAN_DECISION\n"
    "BLOCKER_FINGERPRINT: NONE | sha256:<64-lowercase-hex>\n"
    "REMEDIATION_INPUTS: <feature-local-path> | NONE\n"
    "REMEDIATION_PLAN: <feature-local-path> | NONE"
)

MATRIX_START = (
    "Validate the aggregate result against this exact matrix before creating "
    "remediation artifacts or delegating planning:"
)
MATRIX_END = (
    "Only `BLOCKED` plus `AUTONOMOUS`, with both paths resolving beneath the "
    "active feature folder and an actionable remediable disposition, permits "
    "remediation artifact creation and `atomic-planner` delegation."
)
EXPECTED_MATRIX_ROWS = (
    "| `PASS` | `NONE` | `NONE` | `NONE` |",
    (
        "| `BLOCKED` | `AUTONOMOUS` | `<feature-local-path>` | "
        "`<feature-local-path>` |"
    ),
    "| `BLOCKED` | `NO_CANDIDATE` | `NONE` | `NONE` |",
    "| `BLOCKED` | `EXTERNAL_RUNTIME` | `NONE` | `NONE` |",
    "| `BLOCKED` | `AWAITING_CI` | `NONE` | `NONE` |",
    "| `BLOCKED` | `HUMAN_DECISION` | `NONE` | `NONE` |",
)


def read_skill(relative_path: Path) -> str:
    """Read one canonical skill without invoking external services or processes."""

    return (REPO_ROOT / relative_path).read_text(encoding="utf-8")


def extract_matrix(skill_text: str) -> str:
    """Return the shared decision matrix and its fail-closed boundary."""

    start = skill_text.index(MATRIX_START)
    end = skill_text.index(MATRIX_END, start) + len(MATRIX_END)
    return skill_text[start:end]


def test_reviewers_aggregate_every_known_blocker_before_terminal_output() -> None:
    """Require complete policy, code, and feature aggregation before fingerprinting."""

    for path in REVIEWER_PATHS:
        text = read_skill(path)
        normalized = text.lower()

        assert "aggregate every known blocking" in normalized
        assert "policy audit, code review, and feature audit" in normalized
        assert "partial audit" in normalized
        assert "blocker subset" in normalized
        assert "early-return" in normalized or "early return" in normalized
        assert normalized.index("aggregate every known blocking") < normalized.index(
            "remediation_action: none | autonomous"
        )


def test_all_skills_share_the_exact_review_result_grammar() -> None:
    """Require one five-field verdict, action, fingerprint, and path grammar."""

    for path in SKILL_PATHS:
        text = read_skill(path)

        assert CANONICAL_GRAMMAR in text
        assert "REVIEW_STATUS:" not in text


def test_all_skills_share_one_actionable_autonomous_handoff_matrix() -> None:
    """Permit planner handoff only for actionable BLOCKED/AUTONOMOUS results."""

    matrices = tuple(extract_matrix(read_skill(path)) for path in SKILL_PATHS)

    assert len(set(matrices)) == 1
    for row in EXPECTED_MATRIX_ROWS:
        assert row in matrices[0]
    assert "Every combination not listed in the matrix is invalid" in matrices[0]
    assert "actionable remediable disposition" in matrices[0]


def test_terminal_blocked_actions_have_no_paths_or_planner_delegation() -> None:
    """Keep external, human, CI, non-remediable, and no-delta results terminal."""

    matrix = extract_matrix(read_skill(SKILL_PATHS[0]))
    terminal_expectations = {
        "NO_CANDIDATE": "non-remediable or no-delta disposition",
        "EXTERNAL_RUNTIME": "external-runtime remediation",
        "AWAITING_CI": "CI or other external state",
        "HUMAN_DECISION": "human decision",
    }

    for action, handling in terminal_expectations.items():
        row = next(line for line in matrix.splitlines() if f"`{action}`" in line)
        assert "| `NONE` | `NONE` |" in row
        assert handling in row
        assert "do not delegate `atomic-planner`" in row


def test_no_candidate_review_preserves_zero_count_no_delta_terminal() -> None:
    """Require review-level no-candidate handling before attempt or cycle creation."""

    for path in REVIEWER_PATHS:
        text = read_skill(path)

        assert "emit `BLOCKED` with `NO_CANDIDATE`" in text
        assert "both remediation paths as `NONE`" in text
        assert "terminates before R1" in text
        assert "consumes neither a remediation attempt nor a completed cycle" in text
