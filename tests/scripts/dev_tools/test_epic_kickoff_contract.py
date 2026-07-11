"""Structural tests for the epic kickoff Markdown contract."""

from __future__ import annotations

import pytest

from scripts.dev_tools.epic_kickoff_contract import (
    parse_epic_kickoff,
    validate_epic_kickoff_text,
)


def _kickoff() -> str:
    """Render a canonical single-feature kickoff."""

    return "\n".join(
        (
            "# Epic Kickoff: sample-epic",
            "## Invocation Prompt",
            "Run `/epic-run sample-epic` to execute this epic.",
            "Use the epic-orchestrator subagent to execute the prepared epic at",
            "docs/features/epics/sample-epic/epic.md. "
            "Reuse epic/sample-epic-integration.",
            "Every child resumes at atomic execution from its committed plan-path;",
            "do not repeat planning or preflight.",
            "## Feature Summary",
            "| issue_num | feature_folder | wave | complexity | plan-path |",
            "| --- | --- | --- | --- | --- |",
            "| 101 | docs/features/active/feature-101 | 0 | C3 | "
            "docs/features/active/feature-101/plan.md |",
        )
    )


def test_kickoff_rejects_fragment_only_spoofing() -> None:
    """Require exact sections, invocation grammar, and table rows."""

    spoof = (
        "# Epic Kickoff: sample-epic\n## Invocation Prompt\n"
        "docs/features/epics/ integration branch atomic execution plan-path\n"
        "## Feature Summary\nnot a table"
    )

    errors = validate_epic_kickoff_text(spoof)

    assert any("invocation" in error.lower() for error in errors)
    assert any("table" in error.lower() for error in errors)


def test_kickoff_accepts_merged_claude_invocation_baseline() -> None:
    """Accept the approved Claude wording while extracting the same structure."""

    claude = _kickoff().replace(
        "docs/features/epics/sample-epic/epic.md. "
        "Reuse epic/sample-epic-integration.\n"
        "Every child resumes at atomic execution from its committed plan-path;",
        "docs/features/epics/sample-epic/epic.md. The integration branch\n"
        "epic/sample-epic-integration already contains every prepared feature "
        "folder and approved atomic plan; child features resume at atomic "
        "execution from their committed plan-path rather than re-planning.",
    )

    assert validate_epic_kickoff_text(claude) == []


@pytest.mark.parametrize(
    ("text", "expected"),
    [
        ("", "empty"),
        ("not a heading", "first line"),
        (_kickoff().replace("## Feature Summary", "## Invocation Prompt"), "duplicate"),
        (_kickoff().replace("issue_num", "issue"), "headers"),
        (_kickoff().replace("| --- |", "| bad |", 1), "separator"),
        (_kickoff().replace("| 101 |", "| issue |"), "issue_num"),
        (
            _kickoff().replace(
                "docs/features/active/feature-101 | 0 |",
                "docs/features/active/feature-101 | wave |",
            ),
            "wave",
        ),
        (_kickoff().replace("| C3 |", "| C5 |", 1), "complexity"),
    ],
)
def test_kickoff_rejects_malformed_structures(text: str, expected: str) -> None:
    """Reject malformed headings, sections, tables, and typed feature cells."""

    assert expected in "\n".join(validate_epic_kickoff_text(text)).lower()


def test_kickoff_parses_and_validates_optional_integrity_fields() -> None:
    """Parse valid optional integrity and reject malformed declarations."""

    valid = (
        _kickoff()
        + "\n"
        + "\n".join(
            (
                "## Integrity",
                f"planning_commit: {'a' * 40}",
                "| plan-path | plan-hash |",
                "| --- | --- |",
                f"| docs/features/active/feature-101/plan.md | {'b' * 40} |",
            )
        )
    )

    parsed, errors = parse_epic_kickoff(valid)

    assert errors == []
    assert parsed is not None
    assert parsed.planning_commit == "a" * 40
    assert parsed.plan_hashes == {"docs/features/active/feature-101/plan.md": "b" * 40}

    invalid = valid.replace("## Integrity", "## Integrity\ninvalid field").replace(
        "| plan-path | plan-hash |", "| wrong | hash |"
    )
    assert validate_epic_kickoff_text(invalid)
