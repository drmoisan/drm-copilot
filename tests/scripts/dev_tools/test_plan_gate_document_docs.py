"""Documentation tests for the G11, G12, and G13 plan-gate rules (issue #964).

These tests pin the rule-file text that describes G11 to G13, the corpus
measurement note, the bundled rule copy, and the design-level contract section
of every copy of the `atomic-plan-contract` skill (Claude, Codex `.agents`,
Copilot `.github`, and their bundled copies).
"""

from __future__ import annotations

from pathlib import Path

_REPO_ROOT = Path(__file__).resolve().parents[3]
_RESOURCES = _REPO_ROOT / "extensions" / "drm-copilot" / "resources"
_RULE_FILE = _REPO_ROOT / ".claude" / "rules" / "plan-acceptance-gates.md"
_BUNDLED_RULE_FILE = (
    _RESOURCES / "claude-customizations" / ".claude" / "rules" / "plan-acceptance-gates.md"
)
_CLAUDE_CONTRACT = _REPO_ROOT / ".claude" / "skills" / "atomic-plan-contract" / "SKILL.md"
_CLAUDE_CONTRACT_COPIES = (
    _CLAUDE_CONTRACT,
    _RESOURCES
    / "claude-customizations"
    / ".claude"
    / "skills"
    / "atomic-plan-contract"
    / "SKILL.md",
)
_ALL_CONTRACT_COPIES = (
    *_CLAUDE_CONTRACT_COPIES,
    _REPO_ROOT / ".agents" / "skills" / "atomic-plan-contract" / "SKILL.md",
    _RESOURCES
    / "codex-and-agents-customizations"
    / ".agents"
    / "skills"
    / "atomic-plan-contract"
    / "SKILL.md",
    _REPO_ROOT / ".github" / "skills" / "atomic-plan-contract" / "SKILL.md",
    _RESOURCES
    / "customizations"
    / ".github"
    / "skills"
    / "atomic-plan-contract"
    / "SKILL.md",
)

_G11_HEADING = "### G11 — ships as Blocking by operator-approved scope"
_G12_HEADING = "### G12 — ships as Blocking by operator-approved scope"
_G13_HEADING = "### G13 — ships as Blocking because its exoneration is author-controlled"
_FALSE_POSITIVE_HEADING = "### Known false-positive classes — G11 and G12"
_RULE_TOKENS = (
    "| **G11** |",
    "| **G12** |",
    "| **G13** |",
    "G1 through G13 are the complete shipped set.",
    "`scripts/dev_tools/plan_gate_document.py` evaluates G11, G12, and G13",
    "`PLAN_TASK_GUIDELINE` (40)",
    "`PLAN_LINE_GUIDELINE` (400)",
)
_CORPUS_NOTE = (
    "The corpus measurement informed the false-positive class list and did not "
    "decide the channel."
)
_DESIGN_HEADING = "## Design-Level Plan Contract (Mandatory)"
_SHIPPED_SET = "The complete shipped set is therefore G1 through G13."
_ANCHOR_RULE = "**Anchors are symbols, headings, or test names.**"
_CITATION_FORMAT = "`CITATION: <repository-relative path> | <symbol, heading, or test name>`"
_SELF_REVIEW_LOCATOR = "naming the file and the symbol, heading, or test name"
_STALE_LOCATORS = (
    "naming the file and the line, test, or identifier",
    "`CITATION: <repository-relative path> | <nonblank locator>`",
)


def test_rule_file_states_g11_to_g13_sections() -> None:
    """The rule file carries the G11 to G13 rows and severity sections in order."""

    # Arrange
    text = _RULE_FILE.read_text(encoding="utf-8")

    # Act
    missing = [token for token in _RULE_TOKENS if token not in text]

    # Assert
    assert missing == [], f"rule file lacks {missing}"
    severity = text.index("## Severity Decisions")
    register = text.index("## The Write-Mode Register")
    order = [
        text.index(heading)
        for heading in (_G11_HEADING, _G12_HEADING, _G13_HEADING, _FALSE_POSITIVE_HEADING)
    ]
    assert severity < order[0] < order[1] < order[2] < order[3] < register


def test_rule_file_records_corpus_measurement_note() -> None:
    """The rule file states that the corpus measurement did not decide the channel."""

    # Arrange
    text = _RULE_FILE.read_text(encoding="utf-8")

    # Act / Assert
    assert _CORPUS_NOTE in text, "rule file lacks the corpus measurement note"
    assert "g11-g13-corpus-measurement." in text, "rule file lacks the artifact name"


def test_rule_file_bundle_copy_is_byte_identical_for_g13() -> None:
    """The bundled rule file equals the repository rule file and carries G13."""

    # Arrange / Act
    repository = _RULE_FILE.read_bytes()
    bundled = _BUNDLED_RULE_FILE.read_bytes()

    # Assert
    assert bundled == repository, "bundled plan-acceptance-gates.md differs"
    assert b"| **G13** |" in bundled


def test_plan_contract_copies_carry_design_level_section() -> None:
    """Every atomic-plan-contract copy has the design-level section and G1-G13."""

    # Arrange / Act
    lacking = [
        str(path.relative_to(_REPO_ROOT))
        for path in _ALL_CONTRACT_COPIES
        if not all(
            token in path.read_text(encoding="utf-8")
            for token in (_DESIGN_HEADING, _SHIPPED_SET, _ANCHOR_RULE)
        )
    ]

    # Assert
    assert lacking == [], f"contract copies lack the design-level text: {lacking}"


def test_plan_contract_locators_are_symbol_heading_or_test() -> None:
    """The Claude contract copies use symbol, heading, or test locators only."""

    # Arrange / Act / Assert
    for path in _CLAUDE_CONTRACT_COPIES:
        text = path.read_text(encoding="utf-8")
        assert _CITATION_FORMAT in text, f"{path.name}: CITATION format not updated"
        assert _SELF_REVIEW_LOCATOR in text, f"{path.name}: self-review locator"
        stale = [locator for locator in _STALE_LOCATORS if locator in text]
        assert stale == [], f"{path.name} still states {stale}"
