"""Documentation drift tests for the remediation-loop verdict contract (issue #484).

The remediation-loop validators enforce four review verdicts, five
remediability classes, and the cycle-accounting invariants R5-R11. The
orchestration documents in the ``.agents``, ``.claude``, and ``.codex``
surfaces describe the same contract to the agents that produce checkpoints.
These tests pin the literals those documents must carry so the documented
contract and the enforced contract cannot drift apart silently.

Verdict and class literals are imported from the authoritative Python module
``scripts.dev_tools._orchestrator_state_remediation_loop`` rather than
restated here. Every substring check runs on text whose whitespace runs
(including line breaks) are collapsed to one space, so wrapped Markdown does
not break an assertion. The one exception is the remediation-input prefix
test, which inspects raw lines because its rule is a per-line rule.

Documents are committed files read in place relative to the repository root;
no temporary file is created and no external process is started.
"""

from __future__ import annotations

import re
from pathlib import Path

import pytest

from scripts.dev_tools._orchestrator_state_remediation_loop import (
    REMEDIABILITY_CLASSES,
    REVIEW_VERDICTS,
)

# This file lives at tests/scripts/dev_tools/, three parents below the repo root.
REPO_ROOT = Path(__file__).resolve().parents[3]

FEATURE_REVIEW_SKILL = ".agents/skills/feature-review/SKILL.md"
FEATURE_REVIEW_AGENT = ".claude/agents/feature-review.md"
ORCHESTRATOR_AGENT = ".claude/agents/orchestrator.md"
RULES_DOCUMENT = ".claude/rules/orchestrator-state.md"
ORCHESTRATOR_STATE_SKILL = ".agents/skills/orchestrator-state/SKILL.md"
CLAUDE_ORCHESTRATE_SKILL = ".claude/skills/orchestrate/SKILL.md"
AGENTS_ORCHESTRATE_SKILL = ".agents/skills/orchestrate/SKILL.md"
ORCHESTRATOR_WORKFLOW_SKILL = ".agents/skills/orchestrator-workflow/SKILL.md"
AGENTS_EPIC_ORCHESTRATE_SKILL = ".agents/skills/epic-orchestrate/SKILL.md"
CLAUDE_EPIC_ORCHESTRATE_SKILL = ".claude/skills/epic-orchestrate/SKILL.md"
CLAUDE_PARALLEL_ORCHESTRATE_SKILL = ".claude/skills/parallel-orchestrate/SKILL.md"
CLAUDE_FEATURE_REVIEW_WORKFLOW_SKILL = ".claude/skills/feature-review-workflow/SKILL.md"

REVIEW_OUTCOME_HEADING = "## Invariants (remediation_loop.review_outcomes)"
REMEDIATION_INPUT_PREFIXES = (
    "Review-Verdict:",
    "Remediability:",
    "Remediability-Evidence:",
)
COUNTED_BLOCKING_TOKENS = ("BLOCKING", "Severity: Blocking")
EVIDENCE_TEXT_CONSTRAINT = "including the evidence text"
CODEX_NO_PLAN_LINE = "REMEDIATION_PLAN: NONE"
LOOP_FIELD_NAMES = (
    "review_outcomes",
    "completed_attempts",
    "candidate_applied",
    "opened_by_review",
)
REMOVED_INTRODUCTION_WORDING = (
    "three invariants that must hold for each remediation cycle"
)
HALT_PRECEDENCE_LINE = (
    "Halt precedence: human_decision_required > policy_hold > external_dependency"
)
MCP_CONTRACT_LAG_WORDING = "published MCP runtime that lags the repository contract"
ATTEMPT_COUNT_FIELD = "completed_attempts"
ACTIVE_CYCLE_NUMBER = "completed_attempts + 1"
ATTEMPT_GUARD_WORDING = "three completed attempts"
CLAUDE_COUNTER_EQUALITY = (
    "`remediation_pass` equals `remediation_loop.completed_attempts`"
)
CODEX_COUNTER_EQUALITY = (
    "`remediation-pass` equals `remediation_loop.completed_attempts`"
)

# Documents that state the attempt count, the guard, and the active cycle number.
ATTEMPT_COUNT_DOCUMENTS = (
    CLAUDE_ORCHESTRATE_SKILL,
    AGENTS_ORCHESTRATE_SKILL,
    ORCHESTRATOR_WORKFLOW_SKILL,
    CLAUDE_EPIC_ORCHESTRATE_SKILL,
    CLAUDE_PARALLEL_ORCHESTRATE_SKILL,
)
LOOP_DOCUMENTS = (
    CLAUDE_ORCHESTRATE_SKILL,
    AGENTS_ORCHESTRATE_SKILL,
    ORCHESTRATOR_WORKFLOW_SKILL,
    AGENTS_EPIC_ORCHESTRATE_SKILL,
    CLAUDE_EPIC_ORCHESTRATE_SKILL,
    CLAUDE_PARALLEL_ORCHESTRATE_SKILL,
)
ATTEMPT_GUARD_DOCUMENTS = (*ATTEMPT_COUNT_DOCUMENTS, AGENTS_EPIC_ORCHESTRATE_SKILL)
ORCHESTRATE_SKILLS = (CLAUDE_ORCHESTRATE_SKILL, AGENTS_ORCHESTRATE_SKILL)
HALT_AND_WAIT_LITERALS = (
    "HALT_NON_REMEDIABLE",
    "AWAITING_CI",
    HALT_PRECEDENCE_LINE,
    'response: "halt"',
    'blocked_reason: "awaiting_ci"',
    "Remediability: awaiting_ci",
)

_WHITESPACE_RUN = re.compile(r"\s+")


def _read_document(relative_path: str) -> str:
    """Return the text of a committed document read in place."""
    return (REPO_ROOT / relative_path).read_text(encoding="utf-8")


def _collapse_whitespace(text: str) -> str:
    """Collapse every whitespace run, including line breaks, to one space."""
    return _WHITESPACE_RUN.sub(" ", text).strip()


def _collapsed_document(relative_path: str) -> str:
    """Return a document's text with whitespace runs collapsed."""
    return _collapse_whitespace(_read_document(relative_path))


def _section_text(relative_path: str, heading: str) -> str:
    """Return the text from ``heading`` up to the next ``## `` heading.

    The heading line itself is included. An absent heading yields an empty
    string, so callers can assert non-emptiness explicitly.
    """
    lines = _read_document(relative_path).splitlines()
    for start, line in enumerate(lines):
        if line.rstrip() != heading:
            continue
        section = [line]
        for following in lines[start + 1 :]:
            if following.startswith("## "):
                break
            section.append(following)
        return "\n".join(section)
    return ""


def _missing_literals(text: str, literals: tuple[str, ...]) -> list[str]:
    """Return the literals that do not occur in the collapsed ``text``."""
    return [literal for literal in literals if literal not in text]


def test_docs_feature_review_skill_lists_every_literal() -> None:
    """The Codex feature-review skill names every verdict, class, and prefix."""
    # Arrange
    expected = (
        *REVIEW_VERDICTS,
        *REMEDIABILITY_CLASSES,
        CODEX_NO_PLAN_LINE,
        *REMEDIATION_INPUT_PREFIXES,
    )

    # Act
    missing = _missing_literals(_collapsed_document(FEATURE_REVIEW_SKILL), expected)

    # Assert
    assert missing == [], f"{FEATURE_REVIEW_SKILL} is missing literals: {missing}"


def test_docs_orchestrator_agent_lists_every_literal() -> None:
    """The Claude orchestrator agent names every verdict, class, and loop field."""
    # Arrange
    expected = (*REVIEW_VERDICTS, *REMEDIABILITY_CLASSES, *LOOP_FIELD_NAMES)

    # Act
    missing = _missing_literals(_collapsed_document(ORCHESTRATOR_AGENT), expected)

    # Assert
    assert missing == [], f"{ORCHESTRATOR_AGENT} is missing literals: {missing}"


def test_docs_rules_review_outcome_section_lists_every_literal() -> None:
    """The rules document's review-outcome section names every verdict and class."""
    # Arrange
    section = _collapse_whitespace(
        _section_text(RULES_DOCUMENT, REVIEW_OUTCOME_HEADING)
    )

    # Act
    missing = _missing_literals(section, (*REVIEW_VERDICTS, *REMEDIABILITY_CLASSES))

    # Assert
    assert section, f"{RULES_DOCUMENT} has no '{REVIEW_OUTCOME_HEADING}' section"
    assert missing == [], f"{RULES_DOCUMENT} review-outcome section lacks: {missing}"


@pytest.mark.parametrize("relative_path", [RULES_DOCUMENT, ORCHESTRATOR_STATE_SKILL])
def test_docs_rules_introduction_drops_three_invariants_wording(
    relative_path: str,
) -> None:
    """The contract documents no longer claim exactly three remediation invariants."""
    # Act
    text = _collapsed_document(relative_path)

    # Assert
    assert REMOVED_INTRODUCTION_WORDING not in text, (
        f"{relative_path} still contains the superseded wording "
        f"'{REMOVED_INTRODUCTION_WORDING}'"
    )


@pytest.mark.parametrize("relative_path", [FEATURE_REVIEW_AGENT, FEATURE_REVIEW_SKILL])
def test_docs_remediation_input_prefixes_avoid_blocking_tokens(
    relative_path: str,
) -> None:
    """Prefixed remediation-input lines exist and never carry a counted token.

    The orchestrator counts lines containing the blocking tokens, so a prefixed
    line that carried one would change the blocking count. This rule is a
    per-line rule, so the raw lines are inspected without whitespace collapse.
    """
    # Arrange
    lines = _read_document(relative_path).splitlines()

    # Act
    prefixed_lines = [
        line
        for line in lines
        if any(prefix in line for prefix in REMEDIATION_INPUT_PREFIXES)
    ]
    absent_prefixes = [
        prefix
        for prefix in REMEDIATION_INPUT_PREFIXES
        if not any(prefix in line for line in prefixed_lines)
    ]
    offending_lines = [
        line
        for line in prefixed_lines
        if any(token in line for token in COUNTED_BLOCKING_TOKENS)
    ]

    # Assert
    assert absent_prefixes == [], f"{relative_path} lacks prefixes: {absent_prefixes}"
    assert offending_lines == [], (
        f"{relative_path} has prefixed lines carrying a counted blocking token: "
        f"{offending_lines}"
    )


@pytest.mark.parametrize("relative_path", [FEATURE_REVIEW_AGENT, FEATURE_REVIEW_SKILL])
def test_docs_feature_review_agent_states_evidence_text_constraint(
    relative_path: str,
) -> None:
    """Both reviewer documents state the prefixes and the evidence-text constraint."""
    # Arrange
    expected = (*REMEDIATION_INPUT_PREFIXES, EVIDENCE_TEXT_CONSTRAINT)

    # Act
    missing = _missing_literals(_collapsed_document(relative_path), expected)

    # Assert
    assert missing == [], f"{relative_path} is missing literals: {missing}"


def test_docs_loop_documents_state_completed_attempts() -> None:
    """Every loop document states the attempt count, guard, and cycle numbering."""
    # Arrange
    requirements: list[tuple[str, str]] = [
        *((path, ATTEMPT_COUNT_FIELD) for path in ATTEMPT_COUNT_DOCUMENTS),
        *((path, ACTIVE_CYCLE_NUMBER) for path in LOOP_DOCUMENTS),
        *((path, CLAUDE_COUNTER_EQUALITY) for path in ORCHESTRATE_SKILLS),
        (ORCHESTRATOR_WORKFLOW_SKILL, CODEX_COUNTER_EQUALITY),
        *((path, ATTEMPT_GUARD_WORDING) for path in ATTEMPT_GUARD_DOCUMENTS),
    ]

    # Act
    missing = [
        f"{path}: {literal}"
        for path, literal in requirements
        if literal not in _collapsed_document(path)
    ]

    # Assert
    assert missing == [], f"loop documents are missing literals: {missing}"


@pytest.mark.parametrize("relative_path", ORCHESTRATE_SKILLS)
def test_docs_orchestrate_skills_state_halt_and_wait_rules(relative_path: str) -> None:
    """Both orchestrate skills state the halt, wait, and precedence rules."""
    # Act
    missing = _missing_literals(
        _collapsed_document(relative_path), HALT_AND_WAIT_LITERALS
    )

    # Assert
    assert missing == [], f"{relative_path} is missing literals: {missing}"


@pytest.mark.parametrize(
    "relative_path", [FEATURE_REVIEW_SKILL, CLAUDE_FEATURE_REVIEW_WORKFLOW_SKILL]
)
def test_docs_documents_classify_mcp_contract_lag(relative_path: str) -> None:
    """A lagging published MCP runtime is classified as an external dependency."""
    # Act
    missing = _missing_literals(
        _collapsed_document(relative_path),
        (MCP_CONTRACT_LAG_WORDING, "external_dependency"),
    )

    # Assert
    assert missing == [], f"{relative_path} is missing literals: {missing}"


def test_docs_contract_documents_share_review_outcome_section() -> None:
    """The rules document and its `.agents` copy carry one review-outcome section."""
    # Act
    rules_section = _collapse_whitespace(
        _section_text(RULES_DOCUMENT, REVIEW_OUTCOME_HEADING)
    )
    skill_section = _collapse_whitespace(
        _section_text(ORCHESTRATOR_STATE_SKILL, REVIEW_OUTCOME_HEADING)
    )

    # Assert
    assert rules_section, f"{RULES_DOCUMENT} has no '{REVIEW_OUTCOME_HEADING}' section"
    assert (
        skill_section
    ), f"{ORCHESTRATOR_STATE_SKILL} has no '{REVIEW_OUTCOME_HEADING}' section"
    assert rules_section == skill_section, (
        f"the '{REVIEW_OUTCOME_HEADING}' section differs between {RULES_DOCUMENT} "
        f"and {ORCHESTRATOR_STATE_SKILL}"
    )
