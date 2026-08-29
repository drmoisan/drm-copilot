"""Focused contract tests for the Claude planning-integrity workflow."""

import json
from pathlib import Path

REPO_ROOT = Path(__file__).resolve().parents[3]


def read(relative_path: str) -> str:
    """Return UTF-8 text for a repository-relative runtime contract."""

    return (REPO_ROOT / relative_path).read_text(encoding="utf-8")


PRD_FEATURE_MATCHER = "prd-feature"
PRD_FEATURE_COMMAND = (
    "pwsh -NoProfile -File .claude/hooks/validate-prd-feature-output.ps1"
)


def prd_feature_registration_error(canonical: str, bundled: str) -> str | None:
    """Return the exact registration violation, if either settings document has one."""

    settings_by_source = {
        "canonical": json.loads(canonical),
        "bundled": json.loads(bundled),
    }
    for source, settings in settings_by_source.items():
        entries = [
            entry
            for entry in settings["hooks"]["SubagentStop"]
            if entry.get("matcher") == PRD_FEATURE_MATCHER
        ]
        if len(entries) != 1:
            return (
                f"Expected exactly one dedicated {PRD_FEATURE_MATCHER} entry "
                f"in {source}."
            )

        hooks = entries[0].get("hooks", [])
        if len(hooks) != 1:
            return f"Expected exactly one hook command in {source}."
        if hooks[0].get("type") != "command":
            return f"Expected the hook type to be command in {source}."
        if hooks[0].get("command") != PRD_FEATURE_COMMAND:
            return f"Expected the exact prd-feature validation command in {source}."

    if canonical != bundled:
        return "Canonical and bundled settings files differ."
    return None


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


def test_prd_feature_runtime_registration_is_exact_and_bundle_identical() -> None:
    """Require one dedicated runtime registration in both published settings copies."""

    canonical = read(".claude/settings.json")
    bundled = read(
        "extensions/drm-copilot/resources/claude-customizations/.claude/settings.json"
    )

    assert prd_feature_registration_error(canonical, bundled) is None


def test_prd_feature_runtime_registration_rejects_invalid_fixtures() -> None:
    """Reject invalid dedicated registration and settings-parity fixtures."""

    canonical = read(".claude/settings.json")
    settings = json.loads(canonical)
    entries = settings["hooks"]["SubagentStop"]
    dedicated = next(
        entry for entry in entries if entry["matcher"] == PRD_FEATURE_MATCHER
    )

    complete_omission = [
        entry for entry in entries if PRD_FEATURE_MATCHER not in entry["matcher"]
    ]
    omission_text = json.dumps({"hooks": {"SubagentStop": complete_omission}})
    assert "exactly one" in (
        prd_feature_registration_error(omission_text, omission_text) or ""
    )

    broad_only_entries = [entry for entry in entries if entry is not dedicated]
    assert any(PRD_FEATURE_MATCHER in entry["matcher"] for entry in broad_only_entries)
    broad_only = json.dumps({"hooks": {"SubagentStop": broad_only_entries}})
    assert "exactly one" in (
        prd_feature_registration_error(broad_only, broad_only) or ""
    )

    duplicate = json.loads(canonical)
    duplicate["hooks"]["SubagentStop"].append(dedicated)
    duplicate_text = json.dumps(duplicate)
    assert "exactly one" in (
        prd_feature_registration_error(duplicate_text, duplicate_text) or ""
    )

    extra_command = json.loads(canonical)
    exact = next(
        entry
        for entry in extra_command["hooks"]["SubagentStop"]
        if entry["matcher"] == PRD_FEATURE_MATCHER
    )
    exact["hooks"].append({"type": "command", "command": "wrong"})
    extra_command_text = json.dumps(extra_command)
    assert "exactly one hook" in (
        prd_feature_registration_error(extra_command_text, extra_command_text) or ""
    )

    wrong_path = json.loads(canonical)
    exact = next(
        entry
        for entry in wrong_path["hooks"]["SubagentStop"]
        if entry["matcher"] == PRD_FEATURE_MATCHER
    )
    exact["hooks"][0]["command"] = "pwsh -NoProfile -File .claude/hooks/wrong.ps1"
    wrong_path_text = json.dumps(wrong_path)
    assert "exact" in (
        prd_feature_registration_error(wrong_path_text, wrong_path_text) or ""
    )

    wrong_type = json.loads(canonical)
    exact = next(
        entry
        for entry in wrong_type["hooks"]["SubagentStop"]
        if entry["matcher"] == PRD_FEATURE_MATCHER
    )
    exact["hooks"][0]["type"] = "prompt"
    wrong_type_text = json.dumps(wrong_type)
    assert "type" in (
        prd_feature_registration_error(wrong_type_text, wrong_type_text) or ""
    )

    wrong_matcher = json.loads(canonical)
    exact = next(
        entry
        for entry in wrong_matcher["hooks"]["SubagentStop"]
        if entry["matcher"] == PRD_FEATURE_MATCHER
    )
    exact["matcher"] = "prd-feature-worker"
    wrong_matcher_text = json.dumps(wrong_matcher)
    assert "exactly one" in (
        prd_feature_registration_error(wrong_matcher_text, wrong_matcher_text) or ""
    )

    assert "differ" in (
        prd_feature_registration_error(canonical, canonical + " ") or ""
    )
