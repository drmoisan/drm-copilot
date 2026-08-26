"""Contract tests for the epic surface's always-on footprint and return shape.

These tests pin the F1 and F6 halves of issue #559. F1 removes the standing
read instructions that the Claude Code runtime already satisfies through
`CLAUDE.md` and the path-scoped `.claude/rules/` files, so an epic run does not
re-read policy it has already been given. F6 replaces an unbounded child report
with a fixed eight-field return shape, so a parent orchestrator's context does
not grow with each child it fans in.

Both guarantees are expressed as runtime procedure text in Claude Markdown, so
the repository's text-fragment contract-test convention (see
``test_epic_run_kickoff_discovery_contract.py``) is the applicable verification
surface.

Whitespace normalization is mandatory here, not stylistic. Every prose
assertion joins adjacent lines and collapses whitespace before searching. A
line-oriented search for a multi-word phrase silently returns zero matches once
the target file reflows and the phrase spans two lines, which converts the
assertion into a no-op that can no longer fail.

Every assertion reads committed repository text only. No test creates, writes,
or removes a file, and no test consults an external service.
"""

from __future__ import annotations

import re
from pathlib import Path

REPO_ROOT = Path(__file__).resolve().parents[3]

EPIC_ORCHESTRATOR_AGENT = REPO_ROOT / ".claude" / "agents" / "epic-orchestrator.md"
EPIC_ORCHESTRATE_SKILL = (
    REPO_ROOT / ".claude" / "skills" / "epic-orchestrate" / "SKILL.md"
)
ORCHESTRATE_SKILL = REPO_ROOT / ".claude" / "skills" / "orchestrate" / "SKILL.md"

STARTUP_PROTOCOL_HEADING = "## Startup Protocol"
PREREQUISITES_HEADING = "## Prerequisites"
KICKOFF_HEADING = "## Merge-on-Green Kickoff Parameter"
BOUNDED_RETURN_HEADING = "## Bounded Child Return Contract"
MODEL_SELECTION_HEADING = "## Model Selection"
CHILD_SIDE_HEADING = "## Epic Mode Bounded Return"

# The three retained startup steps after the two read instructions are removed.
EXPECTED_STARTUP_ORDINALS = ("1", "2", "3")

# Fragments whose presence in the startup protocol proves a read instruction the
# runtime already satisfies survived the removal.
PROHIBITED_STARTUP_READ_FRAGMENTS = (
    "Read `CLAUDE.md`",
    "Read applicable `.claude/rules/`",
    "compliance reading order",
)

# The fixed return shape. The first six are the fields issue #559 requires; the
# last two are the inputs to `git worktree remove`, included so the parent does
# not re-parse porcelain output per child.
BOUNDED_RETURN_FIELDS = (
    "issue_num",
    "feature_folder",
    "merge_status",
    "pr_number",
    "merge_commit_sha",
    "blocked_reason",
    "branch_name",
    "worktree_path",
)

# The three commands the cache doctrine names as the authoritative re-derivation
# sources. Naming them is what makes discarding the excess report safe.
REDERIVATION_COMMANDS = (
    "git worktree list --porcelain",
    "git branch",
    "gh pr view --json state,mergedAt,headRefOid",
)

CACHE_DOCTRINE_RULE = ".claude/rules/parallel-orchestration.md"

# The child-side section restates a shape the parent already documents, so it is
# capped: a context-reduction change must not add more text than it removes.
CHILD_SIDE_MAX_BODY_LINES = 10

# The epic-mode kickoff line is a Markdown blockquote whose opening literal is
# stable; the constraint text is appended to the same quote block.
KICKOFF_LINE_MARKER = "Epic mode: true."

ORDINAL_PATTERN = re.compile(r"^\s*(\d+)\.\s", re.MULTILINE)


def read_text(path: Path) -> str:
    """Return the UTF-8 text of a repository file.

    Args:
        path (Path): Absolute path to the file to read.

    Returns:
        str: The file's UTF-8 decoded content.

    Raises:
        OSError: If the file cannot be read.

    Side Effects:
        Reads from disk. Writes nothing.
    """

    return path.read_text(encoding="utf-8")


def normalize_whitespace(text: str) -> str:
    """Collapse every whitespace run, including line breaks, to one space.

    This is the wrap-tolerance primitive the module docstring describes. Callers
    normalize both the haystack and the needle so a phrase that wraps across two
    adjacent lines is still found.

    Args:
        text (str): Raw text, possibly spanning many lines.

    Returns:
        str: The same text with all whitespace runs replaced by single spaces
        and the ends stripped.

    Side Effects:
        None.
    """

    return " ".join(text.split())


def contains_phrase(haystack: str, phrase: str) -> bool:
    """Report whether a phrase appears in text, ignoring line wrapping.

    Args:
        haystack (str): Raw text to search.
        phrase (str): The phrase to find; its own whitespace is normalized too,
            so a caller may write it across source lines.

    Returns:
        bool: ``True`` when the normalized phrase appears in the normalized
        haystack.

    Side Effects:
        None.
    """

    return normalize_whitespace(phrase) in normalize_whitespace(haystack)


def section_body(text: str, heading: str) -> str | None:
    """Return the body of one ATX level-two section.

    Args:
        text (str): The full Markdown document.
        heading (str): The exact heading line, for example ``## Model
            Selection``.

    Returns:
        str | None: Every line after the heading up to the next level-two
        heading, or ``None`` when the heading is absent. The returned text is
        raw; callers normalize it themselves.

    Side Effects:
        None.
    """

    lines = text.splitlines()
    start: int | None = None
    # Locate the heading line, then walk forward to the next level-two heading;
    # the lines between them are the section body.
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


def heading_order(text: str) -> tuple[str, ...]:
    """Return every level-two heading in document order.

    Args:
        text (str): The full Markdown document.

    Returns:
        tuple[str, ...]: The stripped heading lines, in the order they appear.

    Side Effects:
        None.
    """

    return tuple(line.strip() for line in text.splitlines() if line.startswith("## "))


def blockquote_block(text: str, marker: str) -> str | None:
    """Return the contiguous blockquote run that contains a marker.

    The epic-mode kickoff directive is a blockquote. Collecting the whole
    contiguous run rather than one line means the assertion still holds if the
    directive is later wrapped across several quoted lines.

    Args:
        text (str): The full Markdown document.
        marker (str): A literal that identifies the target blockquote.

    Returns:
        str | None: The quoted text with the leading ``>`` markers removed and
        the lines joined by spaces, or ``None`` when no blockquote run carries
        the marker.

    Side Effects:
        None.
    """

    lines = text.splitlines()
    index = 0
    # Walk the document one blockquote run at a time so a marker match returns
    # the whole run rather than a single wrapped fragment of it.
    while index < len(lines):
        if not lines[index].lstrip().startswith(">"):
            index += 1
            continue
        run_start = index
        while index < len(lines) and lines[index].lstrip().startswith(">"):
            index += 1
        quoted = [line.lstrip().lstrip(">").strip() for line in lines[run_start:index]]
        joined = " ".join(quoted)
        if marker in joined:
            return joined
    return None


def test_epic_startup_protocol_has_three_contiguous_steps_without_read_instructions() -> (  # noqa: E501
    None
):
    """Require the startup protocol to be three steps carrying no read orders.

    The runtime already injects `CLAUDE.md` and the path-scoped rule files, so a
    step ordering the agent to read them buys nothing and costs context on every
    turn. Removing them must leave the remaining steps numbered contiguously,
    because a gap in the ordinals reads as a lost step.
    """

    body = section_body(read_text(EPIC_ORCHESTRATOR_AGENT), STARTUP_PROTOCOL_HEADING)
    assert body is not None, (
        f"`{STARTUP_PROTOCOL_HEADING}` is absent from .claude/agents/"
        "epic-orchestrator.md"
    )

    observed_ordinals = tuple(ORDINAL_PATTERN.findall(body))
    assert observed_ordinals == EXPECTED_STARTUP_ORDINALS, (
        "Startup protocol ordinals must be "
        f"{list(EXPECTED_STARTUP_ORDINALS)}, observed {list(observed_ordinals)}"
    )

    # Report every surviving read instruction at once so a partial removal is
    # named in full rather than one fragment per run.
    surviving = [
        fragment
        for fragment in PROHIBITED_STARTUP_READ_FRAGMENTS
        if contains_phrase(body, fragment)
    ]
    assert not surviving, (
        "Startup protocol still orders reads the runtime already satisfies: "
        + "; ".join(surviving)
    )


def test_epic_orchestrate_skill_has_no_prerequisites_heading() -> None:
    """Require the epic skill to carry no `## Prerequisites` block.

    The block restated the same read instructions the startup protocol carried,
    so it duplicated context the runtime already supplies. Its removal is the
    skill-side half of the F1 change.
    """

    headings = heading_order(read_text(EPIC_ORCHESTRATE_SKILL))

    assert PREREQUISITES_HEADING not in headings, (
        f"`{PREREQUISITES_HEADING}` must be removed from "
        ".claude/skills/epic-orchestrate/SKILL.md"
    )


def test_epic_skill_documents_bounded_child_return_contract_section() -> None:
    """Require the bounded-return section to exist in its declared position.

    The section is placed between the kickoff-parameter section that sends the
    constraint to the child and the model-selection section that follows it, so
    a reader meets the constraint and its contract together.
    """

    headings = heading_order(read_text(EPIC_ORCHESTRATE_SKILL))

    assert BOUNDED_RETURN_HEADING in headings, (
        f"`{BOUNDED_RETURN_HEADING}` is absent from "
        ".claude/skills/epic-orchestrate/SKILL.md"
    )
    assert KICKOFF_HEADING in headings, f"`{KICKOFF_HEADING}` is absent"
    assert MODEL_SELECTION_HEADING in headings, f"`{MODEL_SELECTION_HEADING}` is absent"

    kickoff_index = headings.index(KICKOFF_HEADING)
    bounded_index = headings.index(BOUNDED_RETURN_HEADING)
    model_index = headings.index(MODEL_SELECTION_HEADING)

    assert kickoff_index < bounded_index < model_index, (
        f"`{BOUNDED_RETURN_HEADING}` must sit between `{KICKOFF_HEADING}` and "
        f"`{MODEL_SELECTION_HEADING}`; observed order {list(headings)}"
    )


def test_bounded_return_shape_names_every_required_field() -> None:
    """Require the bounded-return section to name all eight shape fields.

    A shape that omits a field leaves the parent to re-derive it, which is the
    per-child round trip the fixed shape exists to remove.
    """

    body = section_body(read_text(EPIC_ORCHESTRATE_SKILL), BOUNDED_RETURN_HEADING)
    assert body is not None, (
        f"`{BOUNDED_RETURN_HEADING}` is absent from "
        ".claude/skills/epic-orchestrate/SKILL.md"
    )

    # Search for each field as an inline-code token so a prose word that happens
    # to match a field name cannot satisfy the assertion.
    missing = [field for field in BOUNDED_RETURN_FIELDS if f"`{field}`" not in body]
    assert not missing, "Bounded return shape does not name: " + ", ".join(missing)


def test_bounded_return_section_states_discard_and_rederivation() -> None:
    """Require the section to state the discard rule and its safety argument.

    Discarding a child's excess narrative is only safe because the parent
    re-derives authoritative state from the repository and from GitHub. The
    section must state both halves and cite the cache doctrine that owns the
    argument rather than restating it.
    """

    body = section_body(read_text(EPIC_ORCHESTRATE_SKILL), BOUNDED_RETURN_HEADING)
    assert body is not None, (
        f"`{BOUNDED_RETURN_HEADING}` is absent from "
        ".claude/skills/epic-orchestrate/SKILL.md"
    )

    normalized = normalize_whitespace(body)

    assert "discard" in normalized.lower(), (
        "Bounded return section must state that content beyond the fixed shape "
        "is discarded"
    )

    # Name every missing re-derivation command at once so a partial statement is
    # reported in full.
    missing_commands = [
        command for command in REDERIVATION_COMMANDS if command not in normalized
    ]
    assert (
        not missing_commands
    ), "Bounded return section does not name re-derivation command(s): " + "; ".join(
        missing_commands
    )

    assert CACHE_DOCTRINE_RULE in normalized, (
        "Bounded return section must cite the cache doctrine recorded in "
        f"{CACHE_DOCTRINE_RULE}"
    )


def test_epic_mode_kickoff_line_carries_child_facing_constraint() -> None:
    """Require the kickoff directive to impose the bounded shape on the child.

    The parent documents the contract, but only the kickoff line reaches the
    child. Without the child-facing half the child still returns an unbounded
    report and the context saving is not realized.
    """

    quote = blockquote_block(read_text(EPIC_ORCHESTRATE_SKILL), KICKOFF_LINE_MARKER)
    assert quote is not None, (
        "The epic-mode kickoff blockquote carrying "
        f"`{KICKOFF_LINE_MARKER}` was not found in "
        ".claude/skills/epic-orchestrate/SKILL.md"
    )

    normalized = normalize_whitespace(quote).lower()

    assert "bounded return shape" in normalized, (
        "The epic-mode kickoff line must require the child's final report to be "
        "the bounded return shape"
    )
    assert "discarded" in normalized, (
        "The epic-mode kickoff line must state that additional narrative is "
        "discarded"
    )


def test_orchestrate_skill_carries_matching_child_side_statement() -> None:
    """Require the child skill to restate the same shape, briefly.

    The child reads `orchestrate`, not `epic-orchestrate`, so the constraint
    must also be stated there. The body is capped because a context-reduction
    change must not spend more context than it saves.
    """

    text = read_text(ORCHESTRATE_SKILL)
    body = section_body(text, CHILD_SIDE_HEADING)
    assert (
        body is not None
    ), f"`{CHILD_SIDE_HEADING}` is absent from .claude/skills/orchestrate/SKILL.md"

    missing = [field for field in BOUNDED_RETURN_FIELDS if f"`{field}`" not in body]
    assert (
        not missing
    ), "Child-side bounded return statement does not name: " + ", ".join(missing)

    assert "discard" in normalize_whitespace(body).lower(), (
        "Child-side bounded return statement must state that content beyond the "
        "fixed shape is discarded"
    )

    body_line_count = len([line for line in body.splitlines() if line.strip()])
    assert body_line_count <= CHILD_SIDE_MAX_BODY_LINES, (
        f"`{CHILD_SIDE_HEADING}` body must be {CHILD_SIDE_MAX_BODY_LINES} "
        f"non-blank lines or fewer, observed {body_line_count}"
    )
