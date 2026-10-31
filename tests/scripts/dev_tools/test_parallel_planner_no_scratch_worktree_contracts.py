"""Contract tests: the parallel planner creates no worktree (issue #1002).

The skill and agent are Markdown, so the contract is text fragments read from
committed files, collapsed for whitespace. No test writes a file or reads
gitignored state.
"""

from __future__ import annotations

import re
from pathlib import Path

import pytest

from tests.scripts.dev_tools.parallel_orchestrator_surface_test_support import (
    REPO_ROOT,
    collapse_whitespace,
    extract_section,
    read_repo_text,
)

SKILL_RELATIVE = Path(".claude/skills/parallel-plan/SKILL.md")
AGENT_RELATIVE = Path(".claude/agents/parallel-planner.md")
BUNDLE_ROOT = Path("extensions/drm-copilot/resources/claude-customizations")
BUNDLED_SKILL_RELATIVE = BUNDLE_ROOT / SKILL_RELATIVE
BUNDLED_AGENT_RELATIVE = BUNDLE_ROOT / AGENT_RELATIVE

PROHIBITION = "runs no `git worktree add`"
ARTIFACT_HOME = "## Artifact Home"
NUMBERED_ITEM = re.compile(r"^\d+\.\s")


def paragraph_from_marker(text: str, marker: str) -> str:
    """Return the collapsed paragraph from a bold lead marker to the next blank line.

    Raises:
        AssertionError: If the marker is absent, so a paragraph-scoped assertion
            cannot degrade into a match against an empty string.
    """
    start = text.find(marker)
    if start < 0:
        raise AssertionError(f"paragraph marker not found: {marker}")
    end = text.find("\n\n", start)
    return collapse_whitespace(text[start:] if end < 0 else text[start:end])


def skill_artifact_home() -> str:
    """Return the raw ``## Artifact Home`` section text of the canonical skill."""
    return extract_section(read_repo_text(SKILL_RELATIVE), ARTIFACT_HOME)


def assert_contains_all(text: str, fragments: tuple[str, ...], where: str) -> None:
    """Assert that every fragment occurs in the text, naming the first absentee."""
    for fragment in fragments:
        assert fragment in text, f"{where} lacks required fragment: {fragment}"


def test_skill_artifact_home_states_planner_runs_no_worktree_add() -> None:
    """The No planner worktrees paragraph carries the prohibition fragment."""
    # Arrange
    section = skill_artifact_home()
    # Act
    paragraph = paragraph_from_marker(section, "**No planner worktrees.**")
    # Assert
    assert PROHIBITION in paragraph, f"paragraph lacks the prohibition: {paragraph}"


def test_skill_no_planner_worktrees_names_runtime_as_remover() -> None:
    """The paragraph names the runtime as creator and remover of worktrees."""
    # Arrange
    section = skill_artifact_home()
    fragments = (
        'the preparation children\'s `isolation: "worktree"`',
        "the Claude Code runtime creates and removes them",
        "outside every record the removal gates read",
        "outside the runtime sweep",
    )
    # Act
    paragraph = paragraph_from_marker(section, "**No planner worktrees.**")
    # Assert
    assert_contains_all(paragraph, fragments, "No planner worktrees paragraph")


def test_skill_artifact_home_contains_plan_home_checkout_command() -> None:
    """Artifact Home carries the fetch, create, resume, and push commands."""
    # Arrange
    fragments = (
        "`git fetch origin main`",
        "`git checkout -b parallel/<slug>-plan origin/main`",
        "`git checkout parallel/<slug>-plan`",
        "`git push -u origin parallel/<slug>-plan`",
    )
    # Act
    collapsed = collapse_whitespace(skill_artifact_home())
    # Assert
    assert_contains_all(collapsed, fragments, "Artifact Home")


def test_skill_plan_home_checkout_is_ordered_after_preparation_children() -> None:
    """The Plan-home checkout paragraph places the checkout in the run order."""
    # Arrange
    fragments = (
        "After the last preparation child has terminated",
        "before `## Manifest Authoring`",
    )
    # Act
    paragraph = paragraph_from_marker(skill_artifact_home(), "**Plan-home checkout.**")
    # Assert
    assert_contains_all(paragraph, fragments, "Plan-home checkout paragraph")


def test_skill_plan_home_checkout_stops_on_refusal_without_stash_force_or_reset() -> (
    None
):
    """The Plan-home checkout paragraph stops on refusal and forbids overrides."""
    # Arrange
    fragments = (
        "If the checkout is refused, stop planning and report the refusal",
        "do not stash, force, or reset",
    )
    # Act
    paragraph = paragraph_from_marker(skill_artifact_home(), "**Plan-home checkout.**")
    # Assert
    assert_contains_all(paragraph, fragments, "Plan-home checkout paragraph")


def test_skill_read_access_names_planner_and_git_show() -> None:
    """The Read access paragraph names the planner and the by-ref commands."""
    # Arrange
    fragments = (
        "the planner itself",
        "`git fetch origin <branch>`",
        "`git show origin/<branch>:<path>`",
        "never checks an item branch out",
    )
    # Act
    paragraph = paragraph_from_marker(skill_artifact_home(), "**Read access.**")
    # Assert
    assert_contains_all(paragraph, fragments, "Read access paragraph")


@pytest.mark.parametrize(
    "document_relative",
    [SKILL_RELATIVE, AGENT_RELATIVE],
    ids=["skill", "agent"],
)
def test_every_git_worktree_add_occurrence_is_inside_prohibition_sentence(
    document_relative: Path,
) -> None:
    """Each ``git worktree add`` occurrence sits inside the prohibition fragment."""
    # Arrange
    collapsed = collapse_whitespace(read_repo_text(document_relative))
    # Act
    prohibition_count = collapsed.count(PROHIBITION)
    occurrence_count = collapsed.count("git worktree add")
    # Assert
    assert prohibition_count >= 1, f"{document_relative} lacks the prohibition"
    assert prohibition_count == occurrence_count, (
        f"{document_relative} holds {occurrence_count} occurrences of "
        f"`git worktree add` but {prohibition_count} prohibition fragments"
    )


def test_agent_delegation_model_points_to_no_worktree_prohibition() -> None:
    """Delegation Model points to the No planner worktrees prohibition."""
    # Arrange
    agent_text = read_repo_text(AGENT_RELATIVE)
    # Act
    section = collapse_whitespace(extract_section(agent_text, "## Delegation Model"))
    # Assert
    assert_contains_all(
        section, ("**No planner worktrees.**", PROHIBITION), "Delegation Model"
    )


# fmt: off
# The plan-mandated test name is longer than the line limit; Black would join the
# backslash continuation, so formatting is off for this one function.
def \
test_agent_completion_requirements_new_item_requires_no_worktree_and_pushed_plan_branch(
) -> None:
    """The final Completion Requirements item requires no worktree and a push."""
    # Arrange
    agent_text = read_repo_text(AGENT_RELATIVE)
    section = extract_section(agent_text, "## Completion Requirements")
    lines = section.splitlines()
    fragments = (
        "The planner created no worktree",
        PROHIBITION,
        "`parallel/<slug>-plan` is checked out in its own session checkout and pushed",
    )
    # Act
    numbered = [index for index, line in enumerate(lines) if NUMBERED_ITEM.match(line)]
    last_item = lines[numbered[-1]] if numbered else ""
    tail = collapse_whitespace("\n".join(lines[numbered[-1] :])) if numbered else ""
    # Assert
    assert last_item.startswith("8. "), f"last numbered item is not 8: {last_item}"
    assert_contains_all(tail, fragments, "Completion Requirements item 8")
    collapsed = collapse_whitespace(section)
    assert_contains_all(collapsed, ("(P10)", "model_routing_receipt"), "item 2")
# fmt: on


def test_skill_contains_no_pinned_word_and_no_forbidden_fragments() -> None:
    """The skill has no pinned word and none of the forbidden fragments."""
    # Arrange
    skill_text = read_repo_text(SKILL_RELATIVE)
    forbidden = (
        "integration branch is created",
        "create the integration branch",
        "Create the integration branch",
        "integration_branch:",
        "epic/<epic-slug>-integration",
        "depends_on:",
        "record `depends_on`",
        "set `depends_on`",
        "conflicts(a, b)",
        "python -m",
        "logical_agent",
    )
    # Act
    present = [fragment for fragment in forbidden if fragment in skill_text]
    # Assert
    assert "pinned" not in skill_text.lower(), "skill contains the word pinned"
    assert not present, f"skill contains forbidden fragments: {present}"


# fmt: off
# Plan-mandated test name; see the note on the item 8 test above.
def \
test_edited_sections_exclude_preparation_fan_out_item_intake_and_kickoff_artifact_changes(
) -> None:
    """The three untouched sections still carry their required fragments."""
    # Arrange
    skill_text = read_repo_text(SKILL_RELATIVE)
    lines = skill_text.splitlines()
    kickoff_start = lines.index("## Kickoff Artifact")
    kickoff_end = lines.index("### Integration Commit Form (issue #539)")
    # Act
    fan_out = collapse_whitespace(extract_section(skill_text, "## Preparation Fan-Out"))
    intake = collapse_whitespace(extract_section(skill_text, "## Item Intake"))
    kickoff = collapse_whitespace("\n".join(lines[kickoff_start:kickoff_end]))
    # Assert
    assert_contains_all(
        fan_out,
        (
            "Create each preparation worktree's branch from `origin/main`.",
            "> `Preparation mode: true. route_id: preparation. parallel_slug: <slug>.",
            "> `Issue adoption:",
        ),
        "Preparation Fan-Out",
    )
    assert_contains_all(
        intake,
        (
            "Issue-number items are adopted, not promoted.",
            "`/parallel-add` is not an initial-intake path.",
        ),
        "Item Intake",
    )
    assert_contains_all(
        kickoff,
        (
            "# Parallel Kickoff: <slug>",
            "## Invocation Prompt",
            "## Item Summary",
            "## Integrity",
            "planning_commit: <hex>",
        ),
        "Kickoff Artifact",
    )
# fmt: on


@pytest.mark.parametrize(
    ("canonical_relative", "bundled_relative"),
    [
        (SKILL_RELATIVE, BUNDLED_SKILL_RELATIVE),
        (AGENT_RELATIVE, BUNDLED_AGENT_RELATIVE),
    ],
    ids=["skill", "agent"],
)
def test_bundled_copies_are_byte_identical_to_canonical(
    canonical_relative: Path, bundled_relative: Path
) -> None:
    """Each bundled copy equals its canonical file byte for byte."""
    # Arrange
    canonical_bytes = (REPO_ROOT / canonical_relative).read_bytes()
    # Act
    bundled_bytes = (REPO_ROOT / bundled_relative).read_bytes()
    # Assert
    assert bundled_bytes == canonical_bytes, f"{bundled_relative} differs from source"
