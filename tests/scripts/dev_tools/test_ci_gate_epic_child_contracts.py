"""Regression contract for issues #841 and #795.

Issue #841 pins three rule-text changes. In both copies of the orchestrate
skill, S9 step 3 passes ``-RequireWorkflow CI`` when ``epic_mode`` is true,
every observed check counts on an epic child, and the conclusion is described
over the queried checks (CR-1 wiring and CR-4). In every feature-review-workflow
copy that defines ``modified-workflow-needs-green-run``, the qualifying run has
a satisfiable predecessor-head alternative (PA-N9). Issue #795 pins that each
``.agents``-side copy citing the rule names a file that defines it.

Every fragment search runs over whitespace-normalized text, so a reflowed
sentence is still found. The module reads repository files only: it creates no
file, starts no process, and consults no external service.
"""

from __future__ import annotations

import re
from pathlib import Path

import pytest

# This file lives at tests/scripts/dev_tools/, three parents below the repo root.
REPO_ROOT = Path(__file__).resolve().parents[3]

CLAUDE_BUNDLE = "extensions/drm-copilot/resources/claude-customizations/"
CODEX_BUNDLE = "extensions/drm-copilot/resources/codex-and-agents-customizations/"

CLAUDE_ORCHESTRATE = ".claude/skills/orchestrate/SKILL.md"
CLAUDE_REVIEW = ".claude/skills/feature-review-workflow/SKILL.md"
AGENTS_REVIEW = ".agents/skills/feature-review-workflow/SKILL.md"
AGENTS_CI_WORKFLOWS = ".agents/skills/ci-workflows/SKILL.md"
AGENTS_BENCHMARK_BASELINES = ".agents/skills/benchmark-baselines/SKILL.md"

ORCHESTRATE_COPIES = (CLAUDE_ORCHESTRATE, CLAUDE_BUNDLE + CLAUDE_ORCHESTRATE)
AGENTS_REVIEW_COPIES = (AGENTS_REVIEW, CODEX_BUNDLE + AGENTS_REVIEW)
REVIEW_COPIES = (CLAUDE_REVIEW, CLAUDE_BUNDLE + CLAUDE_REVIEW, *AGENTS_REVIEW_COPIES)
CITING_COPIES = (
    AGENTS_CI_WORKFLOWS,
    AGENTS_BENCHMARK_BASELINES,
    CODEX_BUNDLE + AGENTS_CI_WORKFLOWS,
    CODEX_BUNDLE + AGENTS_BENCHMARK_BASELINES,
)

RULE_NAME = "modified-workflow-needs-green-run"
RULE_HEADING = "### " + RULE_NAME
S9_HEADING = "## Step S9 — CI Green Gate"
SCHEMA_HEADING = "## Checkpoint Schema — CI Gate Fields"
WORK_MODE_HEADING = "### Work-mode acceptance-criteria contract"
POLICY_RULES_HEADING = "## Policy Rules"
ORDERED_PROCEDURE_HEADING = "## Ordered Procedure"
PARSER_COMMAND_START = (
    "`pwsh -NoProfile -File .claude/lib/ci-gate/Invoke-CiGateParser.ps1 -ChecksJson"
)
PARSER_COMMAND_END = "-HeadSha <head-sha>`"

S9_EPIC_CHILD_FRAGMENTS = (
    "-RequireWorkflow CI",
    "Every check returned by the unfiltered query counts",
    "a failing or cancelled non-`CI` check fails the gate",
    "at least one passing `CI` check",
    "`no checks reported`",
    "`-ChecksJson '[]'`",
    "is never treated as green",
    "derives `ci_gate.conclusion` over the queried checks",
)
SCHEMA_FRAGMENTS = ("the PR head SHA that the queried checks were observed against",)
SUPERSEDED_ORCHESTRATE_FRAGMENTS = (
    "derives `ci_gate.conclusion` as `success` when all required checks pass",
    "that the required checks were observed against",
)
QUALIFYING_RUN_FRAGMENTS = (
    "its head SHA equals the current branch head",
    "git merge-base --is-ancestor",
    '":!<feature-folder>"',
    "ci_gate.head_sha",
    "cannot name the SHA of the commit that contains it",
)
SHA_EXACT_DEFINITION = (
    "a workflow run whose head SHA matches the current branch head and whose"
    " conclusion is success"
)
AGENTS_RULE_FRAGMENTS = (
    "`.github/workflows/**`, `scripts/benchmarks/**`, or `.github/actions/**`",
    "A green `workflow_dispatch` run against the branch head also satisfies"
    " the rule",
    "record a Blocking finding classified `awaiting_ci`",
    "CI Green Gate (S9)",
)
CITATION_PATTERN = re.compile(
    "`" + re.escape(RULE_NAME) + r"` \(see `(?P<path>[^`]+)`\)"
)


def read_copy(relative_path: str) -> str:
    """Return the UTF-8 text of one committed copy; reads disk, writes nothing."""

    return (REPO_ROOT / relative_path).read_text(encoding="utf-8")


def normalize_whitespace(text: str) -> str:
    """Collapse every whitespace run, including line breaks, to one space."""

    return " ".join(text.split())


def missing_fragments(text: str, fragments: tuple[str, ...]) -> list[str]:
    """Return the fragments absent from ``text`` after whitespace normalization."""

    normalized = normalize_whitespace(text)
    return [item for item in fragments if normalize_whitespace(item) not in normalized]


def section(text: str, heading: str) -> str:
    """Return ``heading`` and the lines after it up to the next ``## `` heading."""

    lines = text.splitlines()
    start = lines.index(heading)
    kept = [lines[start]]
    # Collect lines until the next level-two heading; ``###`` does not end it.
    for line in lines[start + 1 :]:
        if line.startswith("## "):
            break
        kept.append(line)
    return "\n".join(kept)


def cited_rule_paths(citing_text: str) -> list[str]:
    """Return every path cited for the rule in the form ``(see `<path>`)``."""

    normalized = normalize_whitespace(citing_text)
    return [match.group("path") for match in CITATION_PATTERN.finditer(normalized)]


def unresolved_citations(citing_text: str, documents: dict[str, str]) -> list[str]:
    """Return the cited paths whose document lacks the rule heading.

    ``documents`` maps a cited path to that document's text; a cited path that
    is absent from the mapping is reported as unresolved.
    """

    unresolved: list[str] = []
    for cited_path in cited_rule_paths(citing_text):
        document = documents.get(cited_path, "")
        if RULE_HEADING not in document.splitlines():
            unresolved.append(cited_path)
    return unresolved


def bundle_root(relative_path: str) -> str:
    """Return the publishing root that a copy's citations resolve against."""

    return CODEX_BUNDLE if relative_path.startswith(CODEX_BUNDLE) else ""


@pytest.mark.parametrize("relative_path", ORCHESTRATE_COPIES)
def test_orchestrate_s9_states_epic_child_guard(relative_path: str) -> None:
    """S9 states the -RequireWorkflow CI guard and how epic-child checks count."""
    # Arrange
    s9_text = section(read_copy(relative_path), S9_HEADING)

    # Act
    missing = missing_fragments(s9_text, S9_EPIC_CHILD_FRAGMENTS)

    # Assert
    assert missing == [], f"{relative_path} S9 is missing: {missing}"


@pytest.mark.parametrize("relative_path", ORCHESTRATE_COPIES)
def test_orchestrate_schema_head_sha_names_queried_checks(relative_path: str) -> None:
    """The ci_gate.head_sha schema bullet refers to the queried checks."""
    # Arrange
    schema_text = section(read_copy(relative_path), SCHEMA_HEADING)

    # Act
    missing = missing_fragments(schema_text, SCHEMA_FRAGMENTS)

    # Assert
    assert missing == [], f"{relative_path} schema is missing: {missing}"


@pytest.mark.parametrize("relative_path", ORCHESTRATE_COPIES)
def test_orchestrate_drops_required_check_wording(relative_path: str) -> None:
    """The superseded required-check wording of step 3 and the schema is gone."""
    # Arrange
    normalized = normalize_whitespace(read_copy(relative_path))

    # Act
    present = [item for item in SUPERSEDED_ORCHESTRATE_FRAGMENTS if item in normalized]

    # Assert
    assert present == [], f"{relative_path} still carries: {present}"


@pytest.mark.parametrize("relative_path", ORCHESTRATE_COPIES)
def test_orchestrate_parser_command_stays_on_one_line(relative_path: str) -> None:
    """The S9 step 3 parser command keeps its path and -HeadSha on one line."""
    # Arrange
    lines = section(read_copy(relative_path), S9_HEADING).splitlines()

    # Act: keep the lines that carry the whole command span.
    command_lines = [
        line
        for line in lines
        if PARSER_COMMAND_START in line and PARSER_COMMAND_END in line
    ]

    # Assert
    assert len(command_lines) == 1, f"{relative_path} command lines: {command_lines}"


@pytest.mark.parametrize("relative_path", REVIEW_COPIES)
def test_review_rule_defines_satisfiable_qualifying_run(relative_path: str) -> None:
    """The rule defines the head-SHA and predecessor-head alternatives (PA-N9)."""
    # Arrange
    rule_text = section(read_copy(relative_path), RULE_HEADING)

    # Act
    missing = missing_fragments(rule_text, QUALIFYING_RUN_FRAGMENTS)

    # Assert
    assert missing == [], f"{relative_path} rule is missing: {missing}"


@pytest.mark.parametrize("relative_path", REVIEW_COPIES)
def test_review_rule_drops_sha_exact_definition(relative_path: str) -> None:
    """No copy keeps the SHA-exact sentence as the qualifying-run definition."""
    # Arrange
    normalized = normalize_whitespace(read_copy(relative_path))

    # Act
    still_sha_exact = SHA_EXACT_DEFINITION in normalized

    # Assert
    assert not still_sha_exact, f"{relative_path} keeps the SHA-exact definition"


@pytest.mark.parametrize("relative_path", AGENTS_REVIEW_COPIES)
def test_agents_review_rule_sits_before_ordered_procedure(relative_path: str) -> None:
    """The .agents rule section sits between the work-mode contract and procedure."""
    # Arrange
    lines = read_copy(relative_path).splitlines()
    headings = (
        WORK_MODE_HEADING,
        POLICY_RULES_HEADING,
        RULE_HEADING,
        ORDERED_PROCEDURE_HEADING,
    )

    # Act: -1 marks a heading that is absent.
    positions = [lines.index(item) if item in lines else -1 for item in headings]

    # Assert
    assert -1 not in positions, f"{relative_path} heading positions: {positions}"
    assert positions == sorted(positions), f"{relative_path} order: {positions}"


@pytest.mark.parametrize("relative_path", AGENTS_REVIEW_COPIES)
def test_agents_review_rule_carries_codex_bullets(relative_path: str) -> None:
    """The .agents rule carries the trigger paths and the Codex gate bullets."""
    # Arrange
    rule_text = section(read_copy(relative_path), RULE_HEADING)

    # Act
    missing = missing_fragments(rule_text, AGENTS_RULE_FRAGMENTS)

    # Assert
    assert missing == [], f"{relative_path} rule is missing: {missing}"


@pytest.mark.parametrize("relative_path", CITING_COPIES)
def test_agents_citing_copy_resolves_rule(relative_path: str) -> None:
    """Each .agents-side citer names a file that defines the rule heading (#795)."""
    # Arrange: citations in a bundle copy resolve against that bundle's root.
    citing_text = read_copy(relative_path)
    root = bundle_root(relative_path)
    cited = cited_rule_paths(citing_text)
    documents = {path: read_copy(root + path) for path in cited}

    # Act
    unresolved = unresolved_citations(citing_text, documents)

    # Assert
    assert cited == [AGENTS_REVIEW], f"{relative_path} cites: {cited}"
    assert unresolved == [], f"{relative_path} cites an undefined rule: {unresolved}"


def test_rule_resolution_reports_missing_heading() -> None:
    """A cited document that lacks the rule heading is reported as unresolved."""
    # Arrange: an in-memory citer and a cited document without the heading.
    citing_text = f"- The rule `{RULE_NAME}` (see `{AGENTS_REVIEW}`) applies."
    documents = {AGENTS_REVIEW: "## Policy Rules\n\n### another-rule\n"}

    # Act
    unresolved = unresolved_citations(citing_text, documents)

    # Assert
    assert unresolved == [AGENTS_REVIEW]


def test_rule_resolution_accepts_defined_heading() -> None:
    """A cited document that defines the rule heading resolves the citation."""
    # Arrange
    citing_text = f"- The rule `{RULE_NAME}` (see `{AGENTS_REVIEW}`) applies."
    documents = {AGENTS_REVIEW: f"## Policy Rules\n\n{RULE_HEADING}\n"}

    # Act
    unresolved = unresolved_citations(citing_text, documents)

    # Assert
    assert cited_rule_paths(citing_text) == [AGENTS_REVIEW]
    assert unresolved == []
