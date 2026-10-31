"""Contract text for issue combination, telemetry, and the contract weight.

Issue #1013 adds planning-time issue combination, the aggregate cost cap,
tolerated-overlap telemetry, and the ``contract`` cost weight. The behavior is
implemented and tested in the blast-radius libraries; this module pins the
documented contract in the rule, skills, agents, and status template with
section-scoped, collapsed-whitespace fragment checks, so line wrapping does not
affect an assertion. It also pins that no runtime script reads the telemetry
(no automatic tuning). Every check reads committed repository text only; no
test creates a file or starts a process.
"""

from __future__ import annotations

import ast
import re
from pathlib import Path

import pytest

from tests.scripts.dev_tools.parallel_orchestrator_surface_test_support import (
    REPO_ROOT,
    collapse_whitespace,
    extract_section,
    read_repo_text,
)
from tests.scripts.dev_tools.test_parallel_issue_adoption_skill_contracts import (
    HOOK_ISSUE_NUMBER_PATTERN,
)

RULE = Path(".claude/rules/parallel-orchestration.md")
PLAN_SKILL = Path(".claude/skills/parallel-plan/SKILL.md")
ORCHESTRATE_SKILL = Path(".claude/skills/parallel-orchestrate/SKILL.md")
ADD_SKILL = Path(".claude/skills/parallel-add/SKILL.md")
PR_AUTHOR_SKILL = Path(".claude/skills/pr-author/SKILL.md")
CHILD_SKILL = Path(".claude/skills/orchestrate/SKILL.md")
PLANNER_AGENT = Path(".claude/agents/parallel-planner.md")
ORCHESTRATOR_AGENT = Path(".claude/agents/parallel-orchestrator.md")
STATUS_TEMPLATE = Path("docs/features/templates/parallel/parallel-status.md")
SCHEDULING_SUBSECTION = "### Integration-cost scheduling (issue #722)"
SCHEDULING_SOURCE = Path("scripts/dev_tools/_blast_radius_scheduling.py")
SCHEDULING_MODULE = Path(".claude/lib/blast-radius/BlastRadiusScheduling.psm1")
TELEMETRY_FIELD = "observed_resolution"
NO_TUNING_ROOTS: tuple[Path, ...] = (
    Path("scripts"),
    Path(".claude/lib"),
    Path("extensions/drm-copilot/resources/claude-customizations/.claude/lib"),
)
NO_TUNING_SUFFIXES: tuple[str, ...] = (".py", ".ps1", ".psm1", ".sh")
COMBINATION_LINE_PATTERN = re.compile(
    r"`((?:Combined issues|Author-asserted autoclose issues):[^`]*)`"
)
EDITED_PROMPT_SURFACES: tuple[Path, ...] = (
    PLAN_SKILL,
    ORCHESTRATE_SKILL,
    PR_AUTHOR_SKILL,
    CHILD_SKILL,
    PLANNER_AGENT,
    ORCHESTRATOR_AGENT,
)


def subsection(relative_path: Path, heading: str) -> str:
    """Return a ``###`` subsection, bounded by the next ``###`` or ``##`` heading."""
    lines = read_repo_text(relative_path).splitlines()
    start = lines.index(heading)
    end = next(
        (
            index
            for index in range(start + 1, len(lines))
            if lines[index].startswith(("## ", "### "))
        ),
        len(lines),
    )
    return collapse_whitespace("\n".join(lines[start + 1 : end]))


def section(relative_path: Path, heading: str) -> str:
    """Return one collapsed ``##`` section of a repository document."""
    return collapse_whitespace(extract_section(read_repo_text(relative_path), heading))


def assert_contains_all(text: str, fragments: tuple[str, ...], label: str) -> None:
    """Assert every fragment occurs in the text, naming the missing ones."""
    missing = [fragment for fragment in fragments if fragment not in text]
    assert missing == [], f"{label} is missing {missing}"


# ----------------------------------------------------- skill and agent (AC-11..17)


def test_issue_combination_section_sits_between_assessment_and_seeding() -> None:
    """``## Issue Combination`` follows the assessment and precedes seeding (AC-11)."""
    lines = read_repo_text(PLAN_SKILL).splitlines()

    position = [
        lines.index(heading)
        for heading in (
            "## Complexity Assessment",
            "## Issue Combination",
            "## Cohort Seeding",
        )
    ]

    assert position == sorted(position), position


def test_issue_combination_section_states_the_planner_duties() -> None:
    """The planner steps of D-5 are stated in the skill section (AC-11)."""
    text = section(PLAN_SKILL, "## Issue Combination")

    assert_contains_all(
        text,
        (
            "Get-BlastRadiusCombination",
            "without operator approval",
            "fewer than two items",
            "on the primary item's pushed branch",
            "`Combined issues: #A #B`",
            "by path from that member's pushed branch ref",
            "a fresh `## Complexity Assessment`",
            "Remove the non-primary members from `items[]`",
            "`combined_issue_nums`",
            "`combinations` list",
            "run the scheduling entry point over the post-combination item set",
            "never checks an item branch out",
        ),
        "parallel-plan ## Issue Combination",
    )


def test_planner_agent_states_the_combination_duties() -> None:
    """The planner agent carries the same duties in its delegation model (AC-11)."""
    text = section(PLANNER_AGENT, "## Delegation Model")

    assert_contains_all(
        text,
        (
            "Get-BlastRadiusCombination",
            "without operator approval",
            "fewer than two items",
            "`Combined issues: #A #B`",
            "fresh complexity assessment",
            "`combined_issue_nums`",
            "`combinations` list",
            "capped scheduling over the post-combination item set",
        ),
        "parallel-planner ## Delegation Model",
    )


def test_kickoff_element_three_carries_the_combined_issues_line() -> None:
    """A combined item's kickoff and pr-author lines name every member (AC-12)."""
    text = section(ORCHESTRATE_SKILL, "## Parallel-Mode Kickoff Parameter")

    assert_contains_all(
        text,
        (
            "element 3 is followed by the line `Combined issues: #A #B`",
            "`Author-asserted autoclose issues: #A #B`",
            "exactly these five elements",
        ),
        "parallel-orchestrate ## Parallel-Mode Kickoff Parameter",
    )


def test_pr_author_and_orchestrate_name_every_combined_issue() -> None:
    """pr-author reads every number; orchestrate lists every member (AC-12)."""
    pr_author = section(PR_AUTHOR_SKILL, "## Issue/PR Reference Rules")
    handoff = section(CHILD_SKILL, "## PR Authoring (pr-author Handoff)")
    consistency = section(CHILD_SKILL, "## Issue Number Consistency")

    assert "`Author-asserted autoclose issues: #NNN [#NNN ...]`" in pr_author
    assert "Author-asserted autoclose issues: #<issue-num>" in handoff
    assert "every issue named on that `Combined issues:` line" in handoff
    assert "permitted cross-references" in consistency


def test_rule_states_that_no_umbrella_issue_is_created() -> None:
    """The rule text states that combination creates no umbrella issue (AC-12)."""
    text = subsection(RULE, SCHEDULING_SUBSECTION)

    assert "No umbrella issue is created" in text


@pytest.mark.parametrize("relative_path", EDITED_PROMPT_SURFACES, ids=str)
def test_combination_example_lines_are_prompt_shape_safe(relative_path: Path) -> None:
    """Example lines match no hook issue pattern and carry no active path (AC-13)."""
    lines = COMBINATION_LINE_PATTERN.findall(read_repo_text(relative_path))

    for line in lines:
        assert HOOK_ISSUE_NUMBER_PATTERN.search(line) is None, line
        assert "docs/features/active/" not in line, line


def test_combination_example_lines_are_present() -> None:
    """The prompt-shape check observes at least one line of each kind (AC-13)."""
    found = [
        line
        for relative_path in EDITED_PROMPT_SURFACES
        for line in COMBINATION_LINE_PATTERN.findall(read_repo_text(relative_path))
    ]

    assert any(line.startswith("Combined issues:") for line in found), found
    assert any(line.startswith("Author-asserted") for line in found), found


def test_parallel_add_reports_without_combining() -> None:
    """``parallel-add`` step 3 reports a qualifying pair only (AC-15)."""
    text = section(ADD_SKILL, "## Procedure")

    assert_contains_all(
        text,
        (
            "Get-BlastRadiusCombination",
            "`qualifies for combination; not combined (combination applies at "
            "planning time only)`",
            "never combines items",
            "no `mutations[]` change",
            "capped edges",
        ),
        "parallel-add ## Procedure",
    )


def test_combined_item_remediates_as_one_unit() -> None:
    """The skill and the agent state one-unit remediation (AC-16)."""
    skill = section(ORCHESTRATE_SKILL, "## Per-Item Merge-Conflict Handling")
    agent = section(ORCHESTRATOR_AGENT, "## Delegation Model")

    for label, text in (("skill", skill), ("agent", agent)):
        assert_contains_all(
            text,
            (
                "remediates as one unit",
                "one `remediation_loop`",
                "never splits back into separate pull requests",
                "merged, blocked, or removed as a whole",
            ),
            label,
        )


def test_completion_reports_list_each_combination() -> None:
    """The skill report and agent item 7 list the combinations (AC-17)."""
    skill = section(PLAN_SKILL, "## Completion Report")
    agent = section(PLANNER_AGENT, "## Completion Requirements")

    for label, text in (("skill", skill), ("agent", agent)):
        assert_contains_all(
            text,
            (
                "members, primary, qualifying pairs with cost and benefit",
                "`estimated_savings`",
            ),
            label,
        )
        assert "not-combined" in text or "not combined" in text, label


def test_token_shape_sentence_states_the_rule_count() -> None:
    """The skill's token-shape count equals the rule paragraph's count (AC-20)."""
    rule = collapse_whitespace(read_repo_text(RULE))
    skill = section(PLAN_SKILL, "## Radius Computation and Validation")

    rule_count = re.search(r"additionally rejects (\w+) token shapes", rule)

    assert rule_count is not None
    assert f"rejects {rule_count.group(1)} token shapes" in skill
    assert "three token shapes" not in skill


# ------------------------------------------------- rule and template (AC-05..29)


def test_rule_declares_the_tolerated_telemetry_fields() -> None:
    """The rule declares the three tolerated-not-validated fields (AC-06)."""
    text = subsection(RULE, SCHEDULING_SUBSECTION)

    assert_contains_all(
        text,
        (
            "`tolerated_overlaps[].observed_resolution`",
            "`items[].combined_issue_nums`",
            "`combinations` list",
            "tolerated and not validated",
            "Attribution is non-exclusive",
            "Drift detection stays pairwise",
        ),
        "rule integration-cost subsection",
    )


def test_rule_narrows_monotonicity_to_the_pairwise_decision() -> None:
    """Monotonicity is narrowed and the five set properties are stated (AC-05)."""
    text = subsection(RULE, SCHEDULING_SUBSECTION)

    assert "Raising tolerance_percent never adds an edge" not in text
    assert_contains_all(
        text,
        (
            "for the pairwise decision only",
            "superset of the pairwise edges and a subset of the detected conflicts",
            "every item is within its cap after the pass",
            "invariant to input order",
            "a second pass changes nothing",
        ),
        "rule integration-cost subsection",
    )


def test_status_template_carries_the_tolerated_overlaps_projection() -> None:
    """The template section and its skill prescription exist (AC-06)."""
    template = read_repo_text(STATUS_TEMPLATE)
    boundaries = section(ORCHESTRATE_SKILL, "## Documentation Maintenance Boundaries")

    assert "## Tolerated Overlaps" in template.splitlines()
    assert (
        "| a | b | reasons | cost | benefit | later_item | conflicted | "
        "resolution_minutes |"
    ) in template
    assert "`## Tolerated Overlaps` heading" in boundaries
    assert "Every write of an `observed_resolution`." in boundaries


def test_rule_documents_the_contract_weight() -> None:
    """Configuration and Cost state the contract weight (AC-28, AC-29)."""
    text = subsection(RULE, SCHEDULING_SUBSECTION)

    assert_contains_all(
        text,
        (
            "module, and contract, each an integer of at least 1",
            "its committed value is 8",
            "`combination_threshold_percent` (integer, at least 0; default 400",
            "the contract weight times the number of distinct shared contract "
            "identifiers",
            "each identifier counted once",
            "`contract_dependency` remains a hard class",
            "at tolerance_percent 0 the edge set equals strict scheduling for any "
            "`contract` weight",
            "the edge set with the contract term equals the edge set without it",
        ),
        "rule integration-cost subsection",
    )
    assert "cannot combine" not in text


# --------------------------------------------------- no automatic tuning (AC-07)


def runtime_script_files() -> list[Path]:
    """List every runtime script under the no-tuning roots."""
    return sorted(
        path
        for root in NO_TUNING_ROOTS
        for path in (REPO_ROOT / root).rglob("*")
        if path.is_file() and path.suffix in NO_TUNING_SUFFIXES
    )


def test_no_runtime_script_reads_the_telemetry() -> None:
    """No runtime script under the three roots names ``observed_resolution``."""
    files = runtime_script_files()

    readers = [
        path.relative_to(REPO_ROOT).as_posix()
        for path in files
        if TELEMETRY_FIELD in path.read_text(encoding="utf-8", errors="replace")
    ]

    assert files, "no runtime script was scanned"
    assert readers == [], readers


def test_python_reader_reads_only_the_config_mapping() -> None:
    """``config_conflict_tolerance`` takes the config mapping as its only input."""
    tree = ast.parse(read_repo_text(SCHEDULING_SOURCE))
    function = next(
        node
        for node in tree.body
        if isinstance(node, ast.FunctionDef)
        and node.name == "config_conflict_tolerance"
    )
    calls = {
        ast.unparse(node.func)
        for node in ast.walk(function)
        if isinstance(node, ast.Call)
    }

    assert [arg.arg for arg in function.args.args] == ["config"]
    assert not {"open", "Path", "read_text", "os.environ.get"} & calls, calls


def test_powershell_reader_reads_only_the_config_mapping() -> None:
    """``Get-ConfigConflictTolerance`` declares only -Config and reads no file."""
    text = read_repo_text(SCHEDULING_MODULE)
    start = text.index("function Get-ConfigConflictTolerance {")
    end = text.index("\nfunction ", start + 1)
    body = text[start:end]

    parameters = re.findall(r"\[object\]\s+\$(\w+)", body)

    assert parameters == ["Config"], parameters
    for token in ("Get-Content", "ReadAllText", "$env:", TELEMETRY_FIELD):
        assert token not in body, token
