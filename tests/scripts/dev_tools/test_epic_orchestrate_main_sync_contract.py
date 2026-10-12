"""Contract tests for the epic integration branch pre-wave main-sync step.

These tests pin issue #902. The epic integration branch is created from
``origin/main`` once; without a pre-wave main-sync step it falls behind
``origin/main`` while child waves run. The skill text must instruct
``epic-orchestrator`` to count the commits ``origin/main`` has that the
integration branch lacks and, when the count is non-zero, to run the main-sync
as a dedicated chore child item before the wave launches.

The step is runtime procedure text in Markdown, so the repository's
text-fragment contract-test convention is the applicable verification surface.
Every fragment is matched after whitespace normalization so that reflowing the
target file cannot turn an assertion into a no-op.

Every assertion reads committed repository text only. No test creates, writes,
or removes a file, and no test consults an external service.
"""

from __future__ import annotations

import re
from pathlib import Path

import pytest

REPO_ROOT = Path(__file__).resolve().parents[3]

CLAUDE_HEADING = "## Epic Integration Branch Lifecycle"
CODEX_HEADING = "## Integration Branch and Child Worktrees"

CLAUDE_SKILL_PATH = ".claude/skills/epic-orchestrate/SKILL.md"
CLAUDE_BUNDLE_PATH = (
    "extensions/drm-copilot/resources/claude-customizations/"
    ".claude/skills/epic-orchestrate/SKILL.md"
)
CODEX_SKILL_PATH = ".agents/skills/epic-orchestrate/SKILL.md"
CODEX_BUNDLE_PATH = (
    "extensions/drm-copilot/resources/codex-and-agents-customizations/"
    ".agents/skills/epic-orchestrate/SKILL.md"
)

# The twelve fragments both the Claude step and the Codex paragraph must carry.
MAIN_SYNC_FRAGMENTS: tuple[str, ...] = (
    "`git fetch origin main` and then",
    "`git rev-list --count ",
    "..origin/main`",
    "zero count proceeds directly to the wave",
    "dedicated chore child item",
    "`epic-852-main-sync`",
    "merges `origin/main`",
    "PR into the integration branch",
    "before the wave launches",
    "`features[]`",
    "manifest child's issue number",
    "one main-sync child",
)

SURFACES = (
    pytest.param(CLAUDE_SKILL_PATH, CLAUDE_HEADING, id="claude-skill"),
    pytest.param(CLAUDE_BUNDLE_PATH, CLAUDE_HEADING, id="claude-bundle"),
    pytest.param(CODEX_SKILL_PATH, CODEX_HEADING, id="codex-skill"),
    pytest.param(CODEX_BUNDLE_PATH, CODEX_HEADING, id="codex-bundle"),
)

CLAUDE_SURFACES = (
    pytest.param(CLAUDE_SKILL_PATH, id="claude-skill"),
    pytest.param(CLAUDE_BUNDLE_PATH, id="claude-bundle"),
)

# Baseline steps 1 through 3 of the Claude lifecycle section before issue #902,
# with no main-sync step. The contract must reject this text.
PRE_CHANGE_LIFECYCLE_TEXT = """\
1. Before wave 0's launch, `epic-orchestrator` creates the integration branch off the tip of
   `main`: `git fetch origin main`, `git checkout -b epic/<epic-slug>-integration origin/main`,
   `git push -u origin epic/<epic-slug>-integration`.
2. Before starting each wave, `epic-orchestrator` runs
   `git fetch origin epic/<epic-slug>-integration` so the wave's child worktrees branch off the
   current remote tip, not a stale local ref.
3. Each child feature's worktree/branch (created via
   `Agent(orchestrator, isolation: "worktree", run_in_background: true)`) is branched from
   `origin/<integration_branch>`, not `origin/main`. The child's own `orchestrator` instance
   honors this via the epic-mode kickoff line below.
"""

NUMBERED_STEP_PATTERN = re.compile(r"^(\d+)\. ", re.MULTILINE)


def normalize_whitespace(text: str) -> str:
    """Collapse every whitespace run, including line breaks, to one space.

    Args:
        text (str): Raw text, possibly spanning many lines.

    Returns:
        str: The text with all whitespace runs replaced by single spaces and
        the ends stripped.
    """

    return " ".join(text.split())


def contains_phrase(haystack: str, phrase: str) -> bool:
    """Report whether a phrase appears in text, ignoring line wrapping.

    Args:
        haystack (str): Raw text to search.
        phrase (str): The phrase to find; its whitespace is normalized too.

    Returns:
        bool: ``True`` when the normalized phrase appears in the normalized
        haystack.
    """

    return normalize_whitespace(phrase) in normalize_whitespace(haystack)


def section_body(text: str, heading: str) -> str | None:
    """Return the body of one ATX level-two section.

    Args:
        text (str): The full Markdown document.
        heading (str): The exact heading line.

    Returns:
        str | None: Every line after the heading up to the next level-two
        heading, or ``None`` when the heading is absent.
    """

    lines = text.splitlines()
    start: int | None = None
    for index, line in enumerate(lines):
        if line.strip() == heading:
            start = index + 1
            break
    if start is None:
        return None
    for index in range(start, len(lines)):
        if lines[index].startswith("## "):
            return "\n".join(lines[start:index])
    return "\n".join(lines[start:])


def assert_main_sync_fragments(label: str, body: str) -> None:
    """Assert that every main-sync fragment appears in a section body.

    Args:
        label (str): Surface label used in the failure message.
        body (str): The raw section body to search.

    Raises:
        AssertionError: When any fragment is absent; the message names it.
    """

    for fragment in MAIN_SYNC_FRAGMENTS:
        assert contains_phrase(
            body, fragment
        ), f"{label}: missing main-sync fragment: {fragment}"


def remove_block(text: str, start_prefix: str, stop_prefix: str) -> str:
    """Remove one block of lines from in-memory text.

    The block starts at the first line whose left-stripped text starts with
    ``start_prefix`` and ends before the next line that starts with
    ``stop_prefix``. An empty ``stop_prefix`` stops at the next blank line. When
    no stop line follows, the block runs to the end of the text.

    Args:
        text (str): The text to edit.
        start_prefix (str): Prefix identifying the first removed line.
        stop_prefix (str): Prefix identifying the first retained line, or the
            empty string to stop at the next blank line.

    Returns:
        str: The text without the block.

    Raises:
        ValueError: When no line starts with ``start_prefix``.
    """

    lines = text.splitlines()
    start = next(
        (i for i, line in enumerate(lines) if line.lstrip().startswith(start_prefix)),
        None,
    )
    if start is None:
        raise ValueError(f"start marker not found: {start_prefix}")
    stop = len(lines)
    for index in range(start + 1, len(lines)):
        line = lines[index]
        if (stop_prefix == "" and line.strip() == "") or (
            stop_prefix != "" and line.startswith(stop_prefix)
        ):
            stop = index
            break
    return "\n".join(lines[:start] + lines[stop:])


def read_section(relative_path: str, heading: str) -> str:
    """Read a repository file and return one section body.

    Args:
        relative_path (str): Repository-relative path of the Markdown file.
        heading (str): The exact level-two heading line.

    Returns:
        str: The section body.

    Raises:
        AssertionError: When the heading is absent.
    """

    text = (REPO_ROOT / relative_path).read_text(encoding="utf-8")
    body = section_body(text, heading)
    assert body is not None, f"{relative_path}: missing section {heading}"
    return body


@pytest.mark.parametrize(("relative_path", "heading"), SURFACES)
def test_main_sync_step_present_in_lifecycle_section(
    relative_path: str, heading: str
) -> None:
    """Every parity surface carries all main-sync fragments in its section."""
    # Arrange
    body = read_section(relative_path, heading)
    # Act / Assert
    assert_main_sync_fragments(relative_path, body)


@pytest.mark.parametrize("relative_path", CLAUDE_SURFACES)
def test_main_sync_step_sits_between_integration_fetch_and_child_branching(
    relative_path: str,
) -> None:
    """The main-sync count follows the integration fetch and precedes branching."""
    # Arrange
    body = normalize_whitespace(read_section(relative_path, CLAUDE_HEADING))
    # Act
    fetch_index = body.find("`git fetch origin epic/<epic-slug>-integration`")
    count_index = body.find(normalize_whitespace("`git rev-list --count "))
    branch_index = body.find("`origin/<integration_branch>`")
    # Assert
    assert fetch_index != -1, f"{relative_path}: integration fetch not found"
    assert count_index != -1, f"{relative_path}: rev-list count not found"
    assert branch_index != -1, f"{relative_path}: child branching not found"
    assert (
        fetch_index < count_index < branch_index
    ), f"{relative_path}: main-sync step is out of order"


@pytest.mark.parametrize("relative_path", CLAUDE_SURFACES)
def test_lifecycle_steps_are_numbered_one_through_six(relative_path: str) -> None:
    """The Claude lifecycle section numbers its steps 1 through 6."""
    # Arrange
    body = read_section(relative_path, CLAUDE_HEADING)
    # Act
    numbers = NUMBERED_STEP_PATTERN.findall(body)
    # Assert
    assert numbers == ["1", "2", "3", "4", "5", "6"], f"{relative_path}: {numbers}"


def test_contract_fails_when_claude_main_sync_step_removed() -> None:
    """Removing the Claude main-sync step makes the contract fail."""
    # Arrange
    body = read_section(CLAUDE_SKILL_PATH, CLAUDE_HEADING)
    # Act
    stripped = remove_block(body, "3. Before each wave launches", "4. ")
    # Assert
    with pytest.raises(AssertionError, match="missing main-sync fragment"):
        assert_main_sync_fragments("claude-removed", stripped)


def test_contract_fails_when_codex_main_sync_paragraph_removed() -> None:
    """Removing the Codex main-sync paragraph makes the contract fail."""
    # Arrange
    body = read_section(CODEX_SKILL_PATH, CODEX_HEADING)
    # Act
    stripped = remove_block(body, "Before each wave launches", "")
    # Assert
    with pytest.raises(AssertionError, match="missing main-sync fragment"):
        assert_main_sync_fragments("codex-removed", stripped)


def test_contract_fails_on_pre_change_lifecycle_text() -> None:
    """The pre-change lifecycle text without a main-sync step fails the contract."""
    # Arrange / Act / Assert
    with pytest.raises(AssertionError, match="missing main-sync fragment"):
        assert_main_sync_fragments("pre-change", PRE_CHANGE_LIFECYCLE_TEXT)


def test_remove_block_rejects_missing_start_marker() -> None:
    """remove_block raises ValueError when the start marker is absent."""
    # Arrange / Act / Assert
    with pytest.raises(ValueError, match="gamma"):
        remove_block("alpha\nbeta\n", "gamma", "")


def test_section_body_returns_none_for_absent_heading() -> None:
    """section_body returns None when the requested heading is absent."""
    # Arrange
    text = "# Title\n\n## Other\ntext\n"
    # Act
    result = section_body(text, "## Missing")
    # Assert
    assert result is None
