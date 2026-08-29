"""Focused contract tests for the Claude planning-integrity workflow."""

from pathlib import Path

REPO_ROOT = Path(__file__).resolve().parents[3]


def read(relative_path: str) -> str:
    """Return UTF-8 text for a repository-relative runtime contract."""

    return (REPO_ROOT / relative_path).read_text(encoding="utf-8")


def test_numeric_provenance_contract_requires_full_family_and_cross_check() -> None:
    """Require research and PRD surfaces to reject one-pass numeric assertions."""

    researcher = read(".claude/agents/task-researcher.md")
    research_skill = read(".claude/skills/research-issue/SKILL.md")
    prd_agent = read(".claude/agents/prd-feature.md")
    fill_skill = read(".claude/skills/fill-feature-docs/SKILL.md")
    research_hook = read(".claude/hooks/validate-task-researcher-output.ps1")
    prd_hook = read(".claude/hooks/validate-prd-feature-output.ps1")

    for text in (
        researcher,
        research_skill,
        prd_agent,
        fill_skill,
        research_hook,
        prd_hook,
    ):
        assert "Numeric Derivation Evidence" in text
        assert "Complete Family" in text
        assert "Exhaustive Search Scope" in text
        assert "Inclusion Rules" in text
        assert "Exclusion Rules" in text
        assert "Primary Search Strategy or Query Expression" in text
        assert "Cross-check Search Strategy or Query Expression" in text
        assert "Primary Member Set" in text
        assert "Cross-check Member Set" in text
        assert "Member-set Comparison" in text
        assert "Primary Count" in text
        assert "Cross-check Count" in text

    assert "single grep" in researcher
    assert "narrow named-pattern" in research_hook
    assert "narrow named-pattern" in prd_hook
    assert "repeats the primary search strategy or query expression" in research_hook
    assert "repeats the primary search strategy or query expression" in prd_hook
    assert (
        "count does not match its independently enumerated member set" in research_hook
    )
    assert "count does not match its independently enumerated member set" in prd_hook
    assert "numeric acceptance criterion requires an existing research-path" in prd_hook


def test_planner_review_contract_requires_all_three_dimensions() -> None:
    """Require planner self-review before existing executor preflight."""

    contract = read(".claude/skills/atomic-plan-contract/SKILL.md")
    planner = read(".claude/agents/atomic-planner.md")
    hook = read(".claude/hooks/validate-planner-output.ps1")
    remediation = read(".claude/skills/remediation-handoff-atomic-planner/SKILL.md")

    for text in (contract, planner, hook):
        assert "citation-to-tree" in text
        assert "acceptance-criterion-to-implementation" in text
        assert "scope-boundary" in text
    assert "preflight.iterations > 1" in remediation


def test_generated_document_counter_requires_named_section_boundaries() -> None:
    """Require a pure named-section counter and an outside-box fixture."""
    module = read(".claude/lib/requirements/GeneratedDocumentCounters.psm1")
    tests = read(
        "tests/scripts/claude-lib/requirements/GeneratedDocumentCounters.Tests.ps1"
    )
    assert "Get-NamedSectionCheckboxCount" in module
    assert "Heading" in module and "break" in module
    assert "Outside before" in tests and "Outside after" in tests
