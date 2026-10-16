"""Regression contract for issues #899 and #891.

Issue #899 pins that the CI green gate evaluates every check on the pull-request
head: the Claude S9 query carries no ``--required`` flag, S9 states that a
``no checks reported`` error is never green for any pull request, the parallel
Merge-on-Green step always re-reads every check through the CI gate parser, and
no orchestrator surface in scope restates a required-only check population.
Issue #891 pins that the Codex ``## CI Green Gate`` invokes the same parser,
passes ``-RequireWorkflow CI`` for an epic child, and fails closed when the
parser file is absent.
Issue #931 pins that the release flow script waits on every check on the
pull-request head, with no ``--required`` flag and no required-check wording.

Every fragment search runs over whitespace-collapsed text, so a reflowed
sentence is still found. The module reads repository files only: it creates no
file, starts no process, and consults no external service.
"""

from __future__ import annotations

from pathlib import Path

import pytest

from tests.scripts.dev_tools.parallel_orchestrator_surface_test_support import (
    collapse_whitespace,
    extract_section,
    read_repo_text,
)

CLAUDE_BUNDLE = Path("extensions/drm-copilot/resources/claude-customizations")
CODEX_BUNDLE = Path("extensions/drm-copilot/resources/codex-and-agents-customizations")

CLAUDE_ORCHESTRATE = Path(".claude/skills/orchestrate/SKILL.md")
PARALLEL_ORCHESTRATE = Path(".claude/skills/parallel-orchestrate/SKILL.md")
CODEX_ORCHESTRATE = Path(".agents/skills/orchestrate/SKILL.md")
CLAUDE_ORCHESTRATOR_AGENT = Path(".claude/agents/orchestrator.md")
REMEDIATION_SKILL = Path(".claude/skills/remediation-handoff-atomic-planner/SKILL.md")
CODEX_ORCHESTRATOR_WORKFLOW = Path(".agents/skills/orchestrator-workflow/SKILL.md")
CODEX_ORCHESTRATOR_AGENTS: tuple[Path, ...] = tuple(
    Path(f".codex/agents/orchestrator{suffix}.toml")
    for suffix in ("", "-c1", "-c2", "-c3", "-c3-elevated", "-c4")
)
RELEASE_FLOW_SCRIPT = Path("scripts/dev-tools/Invoke-FullReleaseFlow.ps1")

S9_HEADING = "## Step S9 — CI Green Gate"
MERGE_ON_GREEN_HEADING = "## Per-Item Merge to Main (Merge-on-Green)"
CODEX_GATE_HEADING = "## CI Green Gate"
REQUIRED_FLAG = "--required"

S9_ALL_CHECKS_FRAGMENTS = (
    "Invoke `gh pr checks --json bucket,name,state,link,workflow`",
    "The query covers every check on the head SHA for every PR",
    "over the queried checks (every check on the PR head SHA, for every PR)",
)
S9_NO_CHECKS_FRAGMENTS = (
    "No-checks rule:",
    "fails with a `no checks reported` error, that error is never treated as"
    " green for any PR",
    "The parser is never run with `-ChecksJson '[]'` without `-RequireWorkflow CI`",
)
MERGE_ON_GREEN_FRAGMENTS = (
    "durably confirm pull-request state and check conclusion with"
    " `gh pr view --json state,mergedAt,headRefOid` and an unconditional re-read"
    " of every check",
    "Run `gh pr checks <PR> --json bucket,name,state,link,workflow`",
    "`pwsh -NoProfile -File .claude/lib/ci-gate/Invoke-CiGateParser.ps1"
    " -ChecksJson <checks-json> -HeadSha <headRefOid>`",
    "Record `merge_status: ci_green` only when that parser conclusion is `success`",
    "every check on its head SHA passed or was skipped",
)
MERGE_ON_GREEN_SUPERSEDED = (
    "when the check conclusion must be re-read",
    "its checks are green",
)
CODEX_GATE_FRAGMENTS = (
    "every GitHub check on that head SHA through `gh`",
    "`gh pr view --json headRefOid,baseRefName`",
    "Invoke `gh pr checks --json bucket,name,state,link,workflow`",
    "`pwsh -NoProfile -File .claude/lib/ci-gate/Invoke-CiGateParser.ps1"
    " -ChecksJson <checks-json> -HeadSha <head-sha>`",
    "appending `-RequireWorkflow CI` when the PR base branch is an"
    " `epic/<slug>-integration` branch",
    "Every check returned by the unfiltered query counts",
    "a failing or cancelled non-`CI` check fails the gate",
    "at least one passing `CI` check",
    "fails with a `no checks reported` error, that error is never treated as"
    " green for any PR",
    "`-ChecksJson '[]'` and `-RequireWorkflow CI`",
)
CODEX_PARSER_ABSENT_FRAGMENTS = (
    "Parser-absent rule:",
    "`.claude/lib/ci-gate/Invoke-CiGateParser.ps1` does not exist in the repository",
    "the orchestrator does not derive `success` by hand",
    "stop and persist blocked state",
)
REQUIRED_ONLY_PHRASES = (
    "required ci check",
    "required github check",
    "failed required check",
    "required checks pass",
    "required checks were observed",
    "required checks on a non-epic pr",
)
RELEASE_FLOW_REQUIRED_PHRASES = ("required check",)
RELEASE_FLOW_ALL_CHECKS_FRAGMENTS = (
    "every check on the pull request head",
    "every GitHub check on the pull request head",
    "@('pr', 'checks', $PrNumber, '--json', 'bucket')",
)


def _with_mirror(bundle: Path, source: Path) -> tuple[Path, Path]:
    """Return a source path paired with its mirror path inside a bundle."""

    return source, bundle / source


def _posix_id(path: Path) -> str:
    """Return the POSIX form of a path for a readable parametrize id."""

    return path.as_posix()


CLAUDE_ORCHESTRATE_COPIES = _with_mirror(CLAUDE_BUNDLE, CLAUDE_ORCHESTRATE)
PARALLEL_ORCHESTRATE_COPIES = _with_mirror(CLAUDE_BUNDLE, PARALLEL_ORCHESTRATE)
CODEX_ORCHESTRATE_COPIES = _with_mirror(CODEX_BUNDLE, CODEX_ORCHESTRATE)
POPULATION_SURFACES: tuple[Path, ...] = (
    *CLAUDE_ORCHESTRATE_COPIES,
    *_with_mirror(CLAUDE_BUNDLE, CLAUDE_ORCHESTRATOR_AGENT),
    *_with_mirror(CLAUDE_BUNDLE, REMEDIATION_SKILL),
    *CODEX_ORCHESTRATE_COPIES,
    *_with_mirror(CODEX_BUNDLE, CODEX_ORCHESTRATOR_WORKFLOW),
    *(
        path
        for agent in CODEX_ORCHESTRATOR_AGENTS
        for path in _with_mirror(CODEX_BUNDLE, agent)
    ),
)


def section_text(relative_path: Path, heading: str) -> str:
    """Return the whitespace-collapsed body of one ``##`` section of a file."""

    return collapse_whitespace(extract_section(read_repo_text(relative_path), heading))


def missing_fragments(text: str, fragments: tuple[str, ...]) -> list[str]:
    """Return the fragments absent from collapsed ``text``, in declared order."""

    return [item for item in fragments if collapse_whitespace(item) not in text]


def required_only_phrases(text: str) -> list[str]:
    """Return the required-only population phrases present in ``text``.

    The comparison is case-insensitive and runs over whitespace-collapsed text,
    so a phrase split across a line wrap is still reported.
    """

    folded = collapse_whitespace(text).lower()
    return [phrase for phrase in REQUIRED_ONLY_PHRASES if phrase in folded]


@pytest.mark.parametrize("relative_path", CLAUDE_ORCHESTRATE_COPIES, ids=_posix_id)
def test_s9_queries_every_check_without_required_flag(relative_path: Path) -> None:
    """S9 queries every check on the PR head and carries no --required flag."""
    # Arrange
    s9_text = section_text(relative_path, S9_HEADING)

    # Act
    missing = missing_fragments(s9_text, S9_ALL_CHECKS_FRAGMENTS)
    carries_required_flag = REQUIRED_FLAG in s9_text

    # Assert
    assert not carries_required_flag, f"{relative_path.as_posix()} S9 has --required"
    assert missing == [], f"{relative_path.as_posix()} S9 is missing: {missing}"


@pytest.mark.parametrize("relative_path", CLAUDE_ORCHESTRATE_COPIES, ids=_posix_id)
def test_s9_states_no_checks_error_is_never_green(relative_path: Path) -> None:
    """S9 states that a no-checks-reported error is never green for any PR."""
    # Arrange
    s9_text = section_text(relative_path, S9_HEADING)

    # Act
    missing = missing_fragments(s9_text, S9_NO_CHECKS_FRAGMENTS)

    # Assert
    assert missing == [], f"{relative_path.as_posix()} S9 is missing: {missing}"


@pytest.mark.parametrize("relative_path", PARALLEL_ORCHESTRATE_COPIES, ids=_posix_id)
def test_merge_on_green_always_rereads_every_check(relative_path: Path) -> None:
    """The parent re-reads every check through the parser before ci_green."""
    # Arrange
    merge_text = section_text(relative_path, MERGE_ON_GREEN_HEADING)

    # Act
    missing = missing_fragments(merge_text, MERGE_ON_GREEN_FRAGMENTS)
    superseded = [item for item in MERGE_ON_GREEN_SUPERSEDED if item in merge_text]

    # Assert
    assert missing == [], f"{relative_path.as_posix()} merge step is missing: {missing}"
    assert superseded == [], f"{relative_path.as_posix()} still carries: {superseded}"


@pytest.mark.parametrize("relative_path", CODEX_ORCHESTRATE_COPIES, ids=_posix_id)
def test_codex_ci_green_gate_invokes_parser_with_epic_child_guard(
    relative_path: Path,
) -> None:
    """The Codex gate queries every check and parses it with the epic guard."""
    # Arrange
    gate_text = section_text(relative_path, CODEX_GATE_HEADING)

    # Act
    missing = missing_fragments(gate_text, CODEX_GATE_FRAGMENTS)
    carries_required_flag = REQUIRED_FLAG in gate_text

    # Assert
    assert not carries_required_flag, f"{relative_path.as_posix()} gate has --required"
    assert missing == [], f"{relative_path.as_posix()} gate is missing: {missing}"


@pytest.mark.parametrize("relative_path", CODEX_ORCHESTRATE_COPIES, ids=_posix_id)
def test_codex_ci_green_gate_fails_closed_without_parser(relative_path: Path) -> None:
    """The Codex gate persists blocked state when the parser file is absent."""
    # Arrange
    gate_text = section_text(relative_path, CODEX_GATE_HEADING)

    # Act
    missing = missing_fragments(gate_text, CODEX_PARSER_ABSENT_FRAGMENTS)

    # Assert
    assert missing == [], f"{relative_path.as_posix()} gate is missing: {missing}"


@pytest.mark.parametrize("relative_path", POPULATION_SURFACES, ids=_posix_id)
def test_surface_restates_no_required_only_population(relative_path: Path) -> None:
    """No orchestrator surface in scope restates a required-only population."""
    # Arrange
    text = read_repo_text(relative_path)

    # Act
    found = required_only_phrases(text)

    # Assert
    assert found == [], f"{relative_path.as_posix()} restates: {found}"


def test_release_flow_waits_on_every_check_without_required_wording() -> None:
    """The release flow polls every check and never describes required checks."""
    # Arrange
    text = collapse_whitespace(read_repo_text(RELEASE_FLOW_SCRIPT))

    # Act
    carries_required_flag = REQUIRED_FLAG in text
    folded = text.lower()
    required_wording = [
        phrase for phrase in RELEASE_FLOW_REQUIRED_PHRASES if phrase in folded
    ]
    missing = missing_fragments(text, RELEASE_FLOW_ALL_CHECKS_FRAGMENTS)

    # Assert
    assert (
        not carries_required_flag
    ), f"{RELEASE_FLOW_SCRIPT.as_posix()} carries the --required flag"
    assert (
        required_wording == []
    ), f"{RELEASE_FLOW_SCRIPT.as_posix()} describes required checks"
    assert missing == [], f"{RELEASE_FLOW_SCRIPT.as_posix()} lacks fragments {missing}"


def test_required_only_phrases_reports_wrapped_superseded_wording() -> None:
    """The detector reports a required-only phrase split across a line wrap."""
    # Arrange
    text = "A failed required\ncheck is not handled outside the loop."

    # Act
    found = required_only_phrases(text)

    # Assert
    assert found == ["failed required check"]


def test_required_only_phrases_accepts_all_checks_wording() -> None:
    """The detector accepts all-checks wording and the unrelated required keys."""
    # Arrange
    text = (
        "Every GitHub check on the current PR head SHA passed or was skipped;"
        " the object has the required keys `conclusion` and `head_sha`."
    )

    # Act
    found = required_only_phrases(text)

    # Assert
    assert found == []
