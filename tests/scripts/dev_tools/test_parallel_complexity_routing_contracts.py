"""Contract tests for the parallel complexity-routing runtime text (issue #532).

The parallel planner must record a per-item complexity band, assessment, and
model routing receipt, and the parallel parent must read them to choose each
child orchestrator's model. These guarantees are procedure text in the Claude
runtime Markdown files, so the repository's text-fragment contract-test
convention applies. Each test reads its target file as UTF-8, extracts the
named section where one is named, collapses whitespace so line wrapping cannot
hide a token, and asserts the required tokens.
"""

from __future__ import annotations

from pathlib import Path

REPO_ROOT = Path(__file__).resolve().parents[3]

PARALLEL_PLAN_SKILL = Path(".claude/skills/parallel-plan/SKILL.md")
PARALLEL_ORCHESTRATE_SKILL = Path(".claude/skills/parallel-orchestrate/SKILL.md")
PARALLEL_ADD_SKILL = Path(".claude/skills/parallel-add/SKILL.md")
PARALLEL_PLANNER_AGENT = Path(".claude/agents/parallel-planner.md")
PARALLEL_ORCHESTRATOR_AGENT = Path(".claude/agents/parallel-orchestrator.md")
PARALLEL_ORCHESTRATION_RULE = Path(".claude/rules/parallel-orchestration.md")
PLANNER_CHECKPOINT = "artifacts/orchestration/parallel-planner-state.json"
ORCHESTRATOR_CHECKPOINT = "artifacts/orchestration/parallel-orchestrator-state.json"
ADMITTED_ITEM_TOKENS = (
    ORCHESTRATOR_CHECKPOINT,
    "/parallel-add",
    "complexity_to_model",
    "clamped to `opus`",
)
SKILL_ADMITTED_TOKENS = (
    *ADMITTED_ITEM_TOKENS,
    "preferred_overlay.agents",
    "rather than spawning without `model`",
)
AGENT_ADMITTED_TOKENS = (*ADMITTED_ITEM_TOKENS, "rather than spawn without `model`")
STEP_TWO_TOKENS = ("parallel-orchestrate", "## Model Selection", "model_routing_receipt")


def read_text(relative_path: Path) -> str:
    """Return the UTF-8 text of a repository file addressed from the root."""

    return (REPO_ROOT / relative_path).read_text(encoding="utf-8")


def collapse(text: str) -> str:
    """Collapse every whitespace run to a single space."""

    return " ".join(text.split())


def section(text: str, heading: str) -> str:
    """Return a ``## `` section from its heading line to the next ``## `` line.

    Args:
        text: The full document text.
        heading: The exact heading line, for example ``## Model Selection``.

    Returns:
        The section text including the heading line.

    Raises:
        AssertionError: If the heading line is absent.
    """

    lines = text.splitlines()
    assert heading in lines, f"missing heading: {heading}"
    start = lines.index(heading)
    end = next(
        (
            index
            for index in range(start + 1, len(lines))
            if lines[index].startswith("## ")
        ),
        len(lines),
    )
    return "\n".join(lines[start:end])


def between(text: str, start_marker: str, end_marker: str) -> str:
    """Return the text from ``start_marker`` up to ``end_marker``."""

    start = text.index(start_marker)
    return text[start : text.index(end_marker, start)]


def test_parallel_plan_has_complexity_assessment_section() -> None:
    """The planning skill defines the assessment and lists P10 as readiness."""

    # Arrange
    text = read_text(PARALLEL_PLAN_SKILL)

    # Act
    collapsed = collapse(text)
    readiness = collapse(between(text, "**Readiness contract.**", "\n\n"))

    # Assert
    assert "## Complexity Assessment" in text.splitlines()
    assert "Get-ComplexityFloor" in collapsed
    assert "Resolve-DelegationModel" in collapsed
    assert "(P10)" in readiness, readiness


def test_parallel_plan_uses_claude_receipt_agent_field() -> None:
    """The planning skill uses the Claude receipt field, not ``logical_agent``."""

    # Arrange
    text = read_text(PARALLEL_PLAN_SKILL)

    # Act
    found = "logical_agent" in text

    # Assert
    assert not found


def test_parallel_orchestrate_names_planner_checkpoint_band_source() -> None:
    """Model Selection names the planner checkpoint and the kickoff fallback."""

    # Arrange
    text = read_text(PARALLEL_ORCHESTRATE_SKILL)

    # Act
    model_selection = collapse(section(text, "## Model Selection"))

    # Assert
    for token in (
        PLANNER_CHECKPOINT,
        "model_routing_receipt",
        "complexity_band",
        "## Item Summary",
        "`complexity` column",
    ):
        assert token in model_selection, token


def test_parallel_orchestrator_agent_names_planner_checkpoint_band_source() -> None:
    """The orchestrator agent's Delegation Model names the same band source."""

    # Arrange
    text = read_text(PARALLEL_ORCHESTRATOR_AGENT)

    # Act
    delegation = collapse(section(text, "## Delegation Model"))

    # Assert
    for token in (PLANNER_CHECKPOINT, "model_routing_receipt", "`complexity` column"):
        assert token in delegation, token


def test_parallel_add_requires_complexity_assessment() -> None:
    """Admission step 2 requires the assessment; Constraints name the field."""

    # Arrange
    text = read_text(PARALLEL_ADD_SKILL)

    # Act
    step_two = collapse(
        between(text, "2. **Prepare the item.**", "3. **Compute conflict edges")
    )
    constraints = collapse(section(text, "## Constraints"))

    # Assert
    assert "## Complexity Assessment" in step_two
    assert "complexity_band" in step_two
    assert "complexity_band" in constraints
    assert "existing scheduling field" in constraints


def test_parallel_planner_agent_requires_routing_record() -> None:
    """The planner agent persists the assessment and requires P10 at completion."""

    # Arrange
    text = read_text(PARALLEL_PLANNER_AGENT)

    # Act
    persistence = collapse(section(text, "## Checkpoint Persistence"))
    completion = collapse(section(text, "## Completion Requirements"))

    # Assert
    assert "complexity_assessment" in persistence
    assert "(P10)" in completion
    assert "model_routing_receipt" in completion


def test_parallel_orchestration_rule_defines_p10() -> None:
    """The rule defines P10, names the helper, and records the TS divergence."""

    # Arrange
    text = collapse(read_text(PARALLEL_ORCHESTRATION_RULE))

    # Act
    tokens = (
        "P10 — Ready gate, routing record.",
        "_parallel_planner_state_routing.py",
        "structural subset",
    )

    # Assert
    for token in tokens:
        assert token in text, token


def test_parallel_orchestrate_kickoff_band_source_names_admitted_item_source() -> None:
    """The kickoff band-source paragraph names the admitted-item band source."""

    # Arrange
    text = read_text(PARALLEL_ORCHESTRATE_SKILL)

    # Act
    paragraph = collapse(between(text, "**Band and receipt source.**", "\n\n"))

    # Assert
    for token in SKILL_ADMITTED_TOKENS:
        assert token in paragraph, token


def test_parallel_orchestrate_model_selection_names_admitted_item_source() -> None:
    """Model Selection names the admitted-item band source and resolution."""

    # Arrange
    text = read_text(PARALLEL_ORCHESTRATE_SKILL)

    # Act
    model_selection = collapse(section(text, "## Model Selection"))

    # Assert
    for token in SKILL_ADMITTED_TOKENS:
        assert token in model_selection, token


def test_parallel_orchestrator_agent_names_admitted_item_source() -> None:
    """The agent's Delegation Model names the admitted-item band source."""

    # Arrange
    text = read_text(PARALLEL_ORCHESTRATOR_AGENT)

    # Act
    delegation = collapse(section(text, "## Delegation Model"))

    # Assert
    for token in AGENT_ADMITTED_TOKENS:
        assert token in delegation, token


def test_parallel_add_step_two_defers_model_to_parallel_orchestrate() -> None:
    """Admission step 2 defers model resolution to parallel-orchestrate."""

    # Arrange
    text = read_text(PARALLEL_ADD_SKILL)

    # Act
    step_two = collapse(
        between(text, "2. **Prepare the item.**", "3. **Compute conflict edges")
    )

    # Assert
    for token in STEP_TWO_TOKENS:
        assert token in step_two, token
