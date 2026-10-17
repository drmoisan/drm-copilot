"""Contract tests for single-pass preflight and remediation mode (issue #964).

These tests pin the contract text across the Claude, Codex, and Copilot
surfaces: the single-pass preflight rules and line formats, the at-most-one
return rule, the removal of loop mandates, the research and plan pre-mortem,
the final-phase self-review, the pre-feature-review self-review check, the
`Remediation-Mode:` definition, and the Copilot bundle copies. Every search
runs on whitespace-collapsed text so wrapped Markdown does not break it.
"""

from __future__ import annotations

import re
from pathlib import Path

_REPO_ROOT = Path(__file__).resolve().parents[3]
_GB = "extensions/drm-copilot/resources/customizations"
_FT = "extensions/drm-copilot/resources/feature-templates"
_CONTRACTS = (
    ".claude/skills/atomic-plan-contract/SKILL.md",
    ".agents/skills/atomic-plan-contract/SKILL.md",
    ".github/skills/atomic-plan-contract/SKILL.md",
)
_PREFLIGHT_SURFACES = (
    *_CONTRACTS,
    ".claude/agents/atomic-executor.md",
    ".claude/agents/atomic-planner.md",
)
_LINE_FORMATS = (
    "PREFLIGHT-FIX: <task id or heading> | <defect class> | <change made>",
    "PREFLIGHT-DEFECT: <task id or heading> | <defect class> | <required change>",
    "preflight-fix-record: <path>",
)
_DIRECTIVE_SENTENCE = (
    "The preflight directive belongs in the delegation prompt, never in a plan file."
)
_LABELS = (
    "Review checklists",
    "Coverage",
    "Mirror parity",
    "File size",
    "Test isolation",
    "CI-only behavior",
    "Evidence",
)
_RESEARCH_SURFACES = (
    ".claude/agents/task-researcher.md",
    ".claude/skills/research-issue/SKILL.md",
    ".agents/skills/research-issue/SKILL.md",
    ".github/agents/task-researcher.agent.md",
)
_TEMPLATES = ("bug", "feature", "refactor")
_REMEDIATION_SURFACES = (
    ".claude/skills/orchestrate/SKILL.md",
    ".claude/agents/orchestrator.md",
    ".claude/skills/remediation-handoff-atomic-planner/SKILL.md",
    ".agents/skills/remediation-handoff-atomic-planner/SKILL.md",
    ".github/skills/remediation-handoff-atomic-planner/SKILL.md",
    ".codex/prompts/feature-review-remediate.md",
)
_COPILOT_EDITED = (
    ".github/agents/atomic_executor.agent.md",
    ".github/agents/atomic_planning.agent.md",
    ".github/agents/task-researcher.agent.md",
    ".github/agents/orchestrator.agent.md",
    ".github/skills/atomic-plan-contract/SKILL.md",
    ".github/skills/remediation-handoff-atomic-planner/SKILL.md",
    ".github/skills/execution-environment/SKILL.md",
    ".github/prompts/generate-atomic-plan.prompt.md",
)
_LOOP_MANDATES = (
    "validate -> delta -> planner-revise -> validate loop",
    "validate → delta → planner-revise → validate loop",
    "automatically hand off back",
    "Loop requirement:",
)
_WHITESPACE = re.compile(r"\s+")


def _read(relative_path: str) -> str:
    """Return the whitespace-collapsed UTF-8 text of a committed file."""

    text = (_REPO_ROOT / relative_path).read_text(encoding="utf-8")
    return _WHITESPACE.sub(" ", text)


def _lacking(paths: tuple[str, ...], tokens: tuple[str, ...]) -> dict[str, list[str]]:
    """Return, per path, the tokens its text does not contain."""

    result: dict[str, list[str]] = {}
    for path in paths:
        text = _read(path)
        missing = [token for token in tokens if token not in text]
        if missing:
            result[path] = missing
    return result


def test_contract_and_agents_state_single_pass_preflight() -> None:
    """Contracts and Claude agents state the single-pass rules and formats."""

    # Arrange
    tokens = (
        "Review the entire plan in one pass",
        "Trivial defects",
        "Substantive defects",
        *_LINE_FORMATS,
        _DIRECTIVE_SENTENCE,
    )

    # Act
    lacking = _lacking(_PREFLIGHT_SURFACES, tokens)

    # Assert
    assert lacking == {}, f"single-pass preflight text missing: {lacking}"


def test_at_most_one_return_is_stated() -> None:
    """The at-most-one-return rule and its halts are stated where required."""

    # Arrange
    halt = 'blocked_reason: "validator_failed"'

    # Act
    lacking = _lacking(
        (".claude/skills/orchestrate/SKILL.md", ".claude/agents/atomic-planner.md"),
        (halt, "at most once"),
    )
    remediation = _read(".claude/skills/remediation-handoff-atomic-planner/SKILL.md")
    epic_plan = _read(".claude/skills/epic-plan/SKILL.md")

    # Assert
    assert lacking == {}, f"at-most-one-return text missing: {lacking}"
    assert "preflight.iterations > 1" in remediation
    assert "single-pass preflight rule" in epic_plan
    assert "iterating plan revisions until" not in epic_plan


def test_codex_and_copilot_executors_drop_loop_mandates() -> None:
    """The Codex and Copilot executors carry no loop mandate and state single pass."""

    # Arrange
    paths = (
        ".codex/agents/atomic-executor.toml",
        ".github/agents/atomic_executor.agent.md",
    )

    # Act
    present = {
        path: [mandate for mandate in _LOOP_MANDATES if mandate in _read(path)]
        for path in paths
    }
    lacking = _lacking(
        paths, ("A plan returns to the planner at most once", "PREFLIGHT-DEFECT:")
    )

    # Assert
    assert all(not found for found in present.values()), f"loop mandates: {present}"
    assert lacking == {}, f"single-pass text missing: {lacking}"


def test_feature_research_requires_premortem() -> None:
    """Every research surface requires the pre-mortem and exempts docs/research/."""

    # Arrange
    tokens = (
        "## Pre-Mortem",
        *(f"`{label}`" for label in _LABELS),
        "One-off research under `docs/research/` is exempt.",
    )

    # Act
    lacking = _lacking(_RESEARCH_SURFACES, tokens)

    # Assert
    assert lacking == {}, f"research pre-mortem text missing: {lacking}"


def test_plan_templates_carry_premortem_skeleton() -> None:
    """Each plan template has the skeleton and equals its bundled copy."""

    # Arrange
    tokens = ("## Pre-Mortem", *(f"- {label}:" for label in _LABELS))
    paths = tuple(
        f"docs/features/templates/{kind}/plan.yyyy-MM-ddTHH-mm.md"
        for kind in _TEMPLATES
    )

    # Act
    lacking = _lacking(paths, tokens)
    differing = [
        kind
        for kind in _TEMPLATES
        if (
            _REPO_ROOT / f"docs/features/templates/{kind}/plan.yyyy-MM-ddTHH-mm.md"
        ).read_bytes()
        != (_REPO_ROOT / f"{_FT}/{kind}/plan.yyyy-MM-ddTHH-mm.md").read_bytes()
    ]

    # Assert
    assert lacking == {}, f"template skeleton missing: {lacking}"
    assert differing == [], f"bundled templates differ: {differing}"


def test_contract_requires_final_phase_self_review() -> None:
    """Every contract copy requires the final-phase self-review artifact."""

    # Arrange / Act
    lacking = _lacking(
        _CONTRACTS,
        (
            "**Final-phase self-review.**",
            "`<FEATURE>/evidence/qa-gates/self-review.<timestamp>.md`",
            "`docs/features/templates/policy_audit/`",
        ),
    )

    # Assert
    assert lacking == {}, f"self-review requirement missing: {lacking}"


def test_pre_feature_review_commit_starts_with_self_review_check() -> None:
    """The pre-feature-review commit section begins with the self-review check."""

    # Arrange
    text = (_REPO_ROOT / ".claude/skills/orchestrate/SKILL.md").read_text(
        encoding="utf-8"
    )
    start = text.index("## Pre-Feature-Review Commit")
    section = text[start : text.index("\n## ", start + 1)]

    # Act
    first_step = section[section.index("\n1. ") :].split("\n2. ")[0]

    # Assert
    assert "Confirm the self-review" in first_step
    assert "`self-review.*.md`" in first_step
    assert "no FAIL row" in first_step
    assert "proportionate correction" in first_step


def test_remediation_surfaces_define_remediation_mode() -> None:
    """Every remediation surface defines both remediation modes and the rule."""

    # Arrange / Act
    lacking = _lacking(
        _REMEDIATION_SURFACES,
        (
            "Remediation-Mode: proportionate",
            "Remediation-Mode: design",
            "a public interface",
            "BLOCKED at preflight (before [P0-T1])",
        ),
    )

    # Assert
    assert lacking == {}, f"remediation mode text missing: {lacking}"


def test_copilot_bundle_copies_match_canonical() -> None:
    """Each edited Copilot file equals its bundled copy byte for byte."""

    # Arrange / Act
    differing = [
        path
        for path in _COPILOT_EDITED
        if (_REPO_ROOT / path).read_bytes() != (_REPO_ROOT / _GB / path).read_bytes()
    ]

    # Assert
    assert differing == [], f"bundled Copilot copies differ: {differing}"


def test_contract_premortem_test_isolation_requires_seeded_pester_shuffle() -> None:
    """The contract's Test isolation label requires seeded Pester shuffles."""

    # Arrange / Act
    lacking = _lacking(
        _CONTRACTS,
        (
            "seeded shuffled Jest run with the seed recorded",
            "reversed-order run of the new or changed Python test modules",
            "seeded shuffled file-order run of the touched Pester suites with at "
            "least three seeds",
        ),
    )

    # Assert
    assert lacking == {}, f"Test isolation definition missing: {lacking}"
