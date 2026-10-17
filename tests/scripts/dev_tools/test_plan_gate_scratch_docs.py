"""Documentation and frontmatter tests for the G10 plan-gate rule (issue #932).

These tests pin the policy text that describes G10: the rule file and its
bundled copy, the shipped-set sentence in the atomic-plan contract skill and
its bundled copy, the rule file's `paths:` reach, and the discrimination
module docstrings.
"""

from __future__ import annotations

from pathlib import Path

from scripts.dev_tools import plan_gate_discrimination
from tests.scripts.dev_tools.test_claude_rules_frontmatter import (
    assert_rule_paths_reach,
)

_REPO_ROOT = Path(__file__).resolve().parents[3]
_RULE_FILE = _REPO_ROOT / ".claude" / "rules" / "plan-acceptance-gates.md"
_BUNDLE_ROOT = (
    _REPO_ROOT / "extensions" / "drm-copilot" / "resources" / "claude-customizations"
)
_BUNDLED_RULE_FILE = _BUNDLE_ROOT / ".claude" / "rules" / "plan-acceptance-gates.md"
_SKILL_FILE = _REPO_ROOT / ".claude" / "skills" / "atomic-plan-contract" / "SKILL.md"
_BUNDLED_SKILL_FILE = (
    _BUNDLE_ROOT / ".claude" / "skills" / "atomic-plan-contract" / "SKILL.md"
)

ENFORCEMENT_TOKEN = "`scripts/dev_tools/plan_gate_scratch.py` evaluates G10"  # noqa: S105 - test fixture data

_G10_HEADING = "### G10 — ships as Blocking"
_REQUIRED_RULE_TOKENS = (
    "| **G10** |",
    _G10_HEADING,
    "G1 through G13 are the complete shipped set.",
    "G10 exception",
    ENFORCEMENT_TOKEN,
    "### Known false-negative classes — G10",
    "operator-approved scope for issue #932",
    "g10-corpus-measurement.",
)
# Issue #964 added G11 through G13, so the G1-through-G10 sentences moved here.
_SUPERSEDED_RULE_SENTENCES = (
    "G1 through G9 are the complete shipped set.",
    "G1 through G10 are the complete shipped set.",
)
_SKILL_SHIPPED_SET = "The complete shipped set is therefore G1 through G13."
_SKILL_SUPERSEDED = (
    "The complete shipped set is therefore G1 through G9.",
    "The complete shipped set is therefore G1 through G10.",
)

_SCOPE_REQUIRED_PHRASES = (
    "G1 through G9 judge the shell commands the plan states",
    "G1 through G9 are fed by the command extractor",
    "evaluates G1 through G9, calls",
)
_SCOPE_SUPERSEDED_PHRASES = (
    "applies to the shell commands an atomic plan states",
    "both fed by the command extractor",
    "evaluates G1 through G6",
)
_ISSUE_CLASS_BULLET = "**Any issue token after the definition.**"
_G10_LINE_RULE_PHRASES = (
    "an indented heading or task line is absorbed",
    "do not end a physical line",
    _ISSUE_CLASS_BULLET,
)
_G10_FALSE_NEGATIVE_HEADING = "### Known false-negative classes — G10"
_WHITESPACE_ALIGNMENT_PHRASES = (
    "share one explicit whitespace class",
    "`PLAN_WHITESPACE_CLASS`",
    "keeps the command extractor's fence pattern",
)
_SUPERSEDED_RESIDUAL_SENTENCE = "One parity residual remains"
_G6_WHITESPACE_PHRASES = (
    "declared once per runtime",
    "G6 uses the same class",
    "plan-quotation exoneration, which reads the plan text",
)
_SUPERSEDED_DECLARATION_PHRASE = "identical pattern string in each module"


def test_rule_file_documents_g10() -> None:
    """The rule file states G10 in each required section, in order."""

    # Arrange
    text = _RULE_FILE.read_text(encoding="utf-8")

    # Act
    missing = [token for token in _REQUIRED_RULE_TOKENS if token not in text]

    # Assert
    assert missing == [], f"rule file lacks {missing}"
    for sentence in _SUPERSEDED_RULE_SENTENCES:
        assert sentence not in text, f"rule file still states `{sentence}`"
    severity = text.index("## Severity Decisions")
    register = text.index("## The Write-Mode Register")
    assert severity < text.index(_G10_HEADING) < register
    assert text.index("## Enforcement") < text.index(ENFORCEMENT_TOKEN)


def test_rule_file_bundle_copy_is_byte_identical() -> None:
    """The bundled rule file equals the repository rule file byte for byte."""

    # Arrange / Act
    repository = _RULE_FILE.read_bytes()
    bundled = _BUNDLED_RULE_FILE.read_bytes()

    # Assert
    assert bundled == repository, "bundled plan-acceptance-gates.md differs"


def test_atomic_plan_contract_states_shipped_set_through_g10() -> None:
    """Both skill copies name the shipped set through G13 and are identical."""

    # Arrange
    repository = _SKILL_FILE.read_bytes()
    bundled = _BUNDLED_SKILL_FILE.read_bytes()

    # Act
    texts = (repository.decode("utf-8"), bundled.decode("utf-8"))

    # Assert
    for text in texts:
        assert _SKILL_SHIPPED_SET in text
        for superseded in _SKILL_SUPERSEDED:
            assert superseded not in text, f"skill still states `{superseded}`"
    assert bundled == repository, "bundled atomic-plan-contract SKILL.md differs"


def test_rule_frontmatter_paths_reach_scratch_gate_modules() -> None:
    """The rule file's `paths:` scope reaches both G10 modules."""

    # Arrange
    targets = (
        "scripts/dev_tools/plan_gate_scratch.py",
        "extensions/drm-copilot/src/lib/validate/plan-gate-scratch.ts",
    )

    # Act / Assert
    assert_rule_paths_reach("plan-acceptance-gates.md", targets)


def test_discrimination_docstrings_name_g10() -> None:
    """The discrimination docstrings name G10 through G13 and drop the stale claim."""

    # Arrange
    module_doc = plan_gate_discrimination.__doc__
    entry_doc = plan_gate_discrimination.evaluate_plan_gates.__doc__

    # Act / Assert
    assert module_doc is not None
    assert entry_doc is not None
    assert "G1 through G13" in module_doc
    assert "G1 through G10 against" not in module_doc
    assert "G10" in entry_doc
    assert "pre-change output" not in entry_doc


def test_rule_file_scope_and_enforcement_state_the_shipped_set() -> None:
    """The scope and enforcement text name G1 through G9 plus document-level G10."""

    # Arrange
    text = _RULE_FILE.read_text(encoding="utf-8")

    # Act
    missing = [phrase for phrase in _SCOPE_REQUIRED_PHRASES if phrase not in text]
    stale = [phrase for phrase in _SCOPE_SUPERSEDED_PHRASES if phrase in text]

    # Assert
    assert missing == [], f"rule file lacks {missing}"
    assert stale == [], f"rule file still states {stale}"


def test_rule_file_documents_g10_line_rules_and_issue_token_class() -> None:
    """The rule file states the G10 line rules and the issue-token class."""

    # Arrange
    text = _RULE_FILE.read_text(encoding="utf-8")

    # Act
    missing = [phrase for phrase in _G10_LINE_RULE_PHRASES if phrase not in text]

    # Assert
    assert missing == [], f"rule file lacks {missing}"
    heading = text.index(_G10_FALSE_NEGATIVE_HEADING)
    bullet = text.index(_ISSUE_CLASS_BULLET)
    register = text.index("## The Write-Mode Register")
    assert heading < bullet < register


def test_rule_file_states_g10_whitespace_alignment() -> None:
    """The rule file states the shared G10 whitespace class and the fence residual."""

    # Arrange
    text = _RULE_FILE.read_text(encoding="utf-8")

    # Act
    missing = [phrase for phrase in _WHITESPACE_ALIGNMENT_PHRASES if phrase not in text]
    stale = _SUPERSEDED_RESIDUAL_SENTENCE in text

    # Assert
    assert missing == [], f"rule file lacks {missing}"
    assert not stale, f"rule file still states `{_SUPERSEDED_RESIDUAL_SENTENCE}`"


def test_rule_file_states_g6_whitespace_alignment() -> None:
    """The rule file states that G6 shares the whitespace class and where it lives."""

    # Arrange
    text = _RULE_FILE.read_text(encoding="utf-8")

    # Act
    missing = [phrase for phrase in _G6_WHITESPACE_PHRASES if phrase not in text]
    stale = _SUPERSEDED_DECLARATION_PHRASE in text

    # Assert
    assert missing == [], f"rule file lacks {missing}"
    assert not stale, f"rule file still states `{_SUPERSEDED_DECLARATION_PHRASE}`"
