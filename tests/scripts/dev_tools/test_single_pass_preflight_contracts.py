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
_COPILOT_BASE_EDITED = (
    ".github/agents/atomic_executor.agent.md",
    ".github/agents/atomic_planning.agent.md",
    ".github/agents/task-researcher.agent.md",
    ".github/agents/orchestrator.agent.md",
    ".github/skills/atomic-plan-contract/SKILL.md",
    ".github/skills/remediation-handoff-atomic-planner/SKILL.md",
    ".github/skills/execution-environment/SKILL.md",
    ".github/prompts/generate-atomic-plan.prompt.md",
)
_COPILOT_LANGUAGE_EXECUTORS = tuple(
    f".github/agents/{lang}-atomic-executor.agent.md"
    for lang in ("csharp", "powershell", "python")
)
_COPILOT_LANGUAGE_AGENTS = (
    *(
        f".github/agents/{lang}-{role}.agent.md"
        for lang in ("csharp", "powershell", "python")
        for role in ("atomic-planning", "orchestrator")
    ),
    ".github/agents/csharp-typed-engineer.agent.md",
    ".github/agents/powershell-typed-engineer.agent.md",
)
_ROUTER_AND_PROMPT_SURFACES = (
    *(
        f"{root}/skills/{lang}-change-budget-router/SKILL.md"
        for root in (".claude", ".agents")
        for lang in ("csharp", "powershell", "python")
    ),
    ".github/skills/csharp-change-budget-router/SKILL.md",
    ".github/skills/powershell-change-budget-router/SKILL.md",
    *(
        f".github/prompts/{name}.prompt.md"
        for name in (
            "orchestrate-work",
            "orchestrate-python-work",
            "orchestrate-powershell-work",
            "orchestrate-csharp-work",
        )
    ),
)
_COPILOT_EDITED = (
    *_COPILOT_BASE_EDITED,
    *_COPILOT_LANGUAGE_EXECUTORS,
    *_COPILOT_LANGUAGE_AGENTS,
)
_LOOP_MANDATES = (
    "validate -> delta -> planner-revise -> validate loop",
    "validate → delta → planner-revise → validate loop",
    "automatically hand off back",
    "Loop requirement:",
    "iterate until final `PREFLIGHT: ALL CLEAR`",
    "preflight validation loop",
    "repeat until `PREFLIGHT: ALL CLEAR`",
    "preflight until `PREFLIGHT: ALL CLEAR`",
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
    """The Codex and Copilot executors carry no loop mandate and state single pass.

    The language-specific Copilot executors, planners, orchestrators, and typed
    engineers are checked too, because they repeated the base loop mandates.
    """

    # Arrange
    paths = (
        ".codex/agents/atomic-executor.toml",
        ".github/agents/atomic_executor.agent.md",
        *_COPILOT_LANGUAGE_EXECUTORS,
    )
    copilot_agents = (
        *paths[1:],
        *_COPILOT_LANGUAGE_AGENTS,
        *_ROUTER_AND_PROMPT_SURFACES,
    )

    # Act
    present = {
        path: [
            mandate
            for mandate in _LOOP_MANDATES
            if mandate.lower() in _read(path).lower()
        ]
        for path in (*paths, *copilot_agents)
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


def test_contract_requires_tests_asserting_changed_existing_behavior() -> None:
    """Every contract copy requires naming tests that assert changed behavior.

    The rule sits inside the design-level section, names the behavior kinds,
    the search, both dispositions, and the self-review obligation.
    """

    # Arrange
    tokens = (
        "**Changed existing behavior names its asserting tests.**",
        "an existing function, script, fixture, or test stub",
        "signature, argv, output, exit status, or the files it writes",
        "searching the test tree for the symbol, the file name, and the asserted "
        "output",
        "unchanged because it is unaffected, or updated, with the reason for the "
        "update",
        "adversarial self-review includes this search",
    )

    # Act
    sections: dict[str, str] = {}
    for path in _CONTRACTS:
        text = _read(path)
        start = text.index("## Design-Level Plan Contract (Mandatory)")
        sections[path] = text[start : text.index(" ## ", start + 1)]
    lacking = {
        path: [token for token in tokens if token not in section]
        for path, section in sections.items()
        if any(token not in section for token in tokens)
    }

    # Assert
    assert lacking == {}, f"changed-behavior rule missing from section: {lacking}"


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


def test_contract_premortem_mirror_parity_requires_brief_update_task() -> None:
    """The contract's Mirror parity label requires a task that updates the brief.

    The obligation sits inside the design-level section of every contract
    copy and names the triggering fact kinds, the six copies, and the bullet.
    """

    # Arrange
    tokens = (
        "The `Mirror parity` bullet also covers the execution-environment brief",
        "adds or renames a CI job, changes a required status context, a tool "
        "route, or a batch-budget rule",
        "includes a task that updates the brief in the same change, in all six "
        "byte-identical copies",
        "the bullet names that task",
    )

    # Act
    lacking: dict[str, list[str]] = {}
    for path in _CONTRACTS:
        text = _read(path)
        start = text.index("## Design-Level Plan Contract (Mandatory)")
        section = text[start : text.index(" ## ", start + 1)]
        missing = [token for token in tokens if token not in section]
        if missing:
            lacking[path] = missing

    # Assert
    assert lacking == {}, f"Mirror parity brief obligation missing: {lacking}"
