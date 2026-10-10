"""Documentation contracts for the issue #744 completion-gate and tooling fixes.

Pins the text that issue #744 adds to the Codex and Claude orchestrate skills,
the parallel-orchestrate skill and agent, the three acceptance-criteria-tracking
skills, the Claude feature-review agent, and the three
evidence-and-timestamp-conventions skills, and asserts that every edited
surface is byte-identical to its bundled extension mirror.

This module reads committed repository files only. It creates no file, spawns
no process, and performs no network access. Every content assertion extracts
the named ``##`` section first, collapses whitespace, and checks each required
fragment as a substring so a failure names the missing fragment.
"""

from __future__ import annotations

from pathlib import Path

import pytest

from scripts.dev_tools._orchestrator_state_routing import PR_GATE_KEYS
from scripts.dev_tools.validate_orchestrator_state import CI_GATE_KEYS
from tests.scripts.dev_tools.parallel_orchestrator_surface_test_support import (
    REPO_ROOT,
    collapse_whitespace,
    extract_section,
    parse_frontmatter,
    read_repo_text,
    string_sequence,
)

CODEX_ORCHESTRATE = Path(".agents/skills/orchestrate/SKILL.md")
CLAUDE_ORCHESTRATE = Path(".claude/skills/orchestrate/SKILL.md")
PARALLEL_ORCHESTRATE = Path(".claude/skills/parallel-orchestrate/SKILL.md")
PARALLEL_ORCHESTRATOR_AGENT = Path(".claude/agents/parallel-orchestrator.md")
FEATURE_REVIEW_AGENT = Path(".claude/agents/feature-review.md")

AC_TRACKING_SKILLS: tuple[tuple[str, Path], ...] = (
    ("claude", Path(".claude/skills/acceptance-criteria-tracking/SKILL.md")),
    ("agents", Path(".agents/skills/acceptance-criteria-tracking/SKILL.md")),
    ("github", Path(".github/skills/acceptance-criteria-tracking/SKILL.md")),
)

EVIDENCE_SKILLS: tuple[tuple[str, Path], ...] = (
    ("claude", Path(".claude/skills/evidence-and-timestamp-conventions/SKILL.md")),
    ("agents", Path(".agents/skills/evidence-and-timestamp-conventions/SKILL.md")),
    ("github", Path(".github/skills/evidence-and-timestamp-conventions/SKILL.md")),
)

_CLAUDE_BUNDLE = Path("extensions/drm-copilot/resources/claude-customizations")
_CODEX_BUNDLE = Path("extensions/drm-copilot/resources/codex-and-agents-customizations")
_GITHUB_BUNDLE = Path("extensions/drm-copilot/resources/customizations")


def _mirror(bundle: Path, source: Path) -> tuple[Path, Path]:
    """Return a source path paired with its mirror path inside a bundle.

    Args:
        bundle: Repo-root-relative bundle directory.
        source: Repo-root-relative source path.

    Returns:
        The ``(source, mirror)`` pair.

    Side Effects:
        None.
    """
    return source, bundle / source


# The eleven edited surfaces and their bundled mirrors, keyed by stable ids.
MIRROR_PAIRS: tuple[tuple[str, tuple[Path, Path]], ...] = (
    ("agents-orchestrate", _mirror(_CODEX_BUNDLE, CODEX_ORCHESTRATE)),
    ("claude-orchestrate", _mirror(_CLAUDE_BUNDLE, CLAUDE_ORCHESTRATE)),
    ("claude-parallel-orchestrate", _mirror(_CLAUDE_BUNDLE, PARALLEL_ORCHESTRATE)),
    (
        "claude-parallel-orchestrator-agent",
        _mirror(_CLAUDE_BUNDLE, PARALLEL_ORCHESTRATOR_AGENT),
    ),
    ("claude-ac-tracking", _mirror(_CLAUDE_BUNDLE, AC_TRACKING_SKILLS[0][1])),
    ("agents-ac-tracking", _mirror(_CODEX_BUNDLE, AC_TRACKING_SKILLS[1][1])),
    ("github-ac-tracking", _mirror(_GITHUB_BUNDLE, AC_TRACKING_SKILLS[2][1])),
    ("claude-feature-review-agent", _mirror(_CLAUDE_BUNDLE, FEATURE_REVIEW_AGENT)),
    ("claude-evidence", _mirror(_CLAUDE_BUNDLE, EVIDENCE_SKILLS[0][1])),
    ("agents-evidence", _mirror(_CODEX_BUNDLE, EVIDENCE_SKILLS[1][1])),
    ("github-evidence", _mirror(_GITHUB_BUNDLE, EVIDENCE_SKILLS[2][1])),
)

TIMESTAMP_SOURCE_BLOCK = (
    "The `Timestamp` value is local time read from the host system clock when the"
    " recorded command runs (for example `Get-Date -Format yyyy-MM-ddTHH-mm`);"
    " the agent never composes or estimates it."
)


def _english_list(keys: tuple[str, ...]) -> str:
    """Render keys as backticked names joined in English list form.

    Args:
        keys: Key names in order.

    Returns:
        For example "`conclusion`, `head_sha`, and `verified_at`".

    Side Effects:
        None.
    """
    quoted = [f"`{key}`" for key in keys]
    if len(quoted) <= 2:
        return " and ".join(quoted)
    return ", ".join(quoted[:-1]) + ", and " + quoted[-1]


def _assert_section_contains(
    relative_path: Path, heading: str, fragments: tuple[str, ...]
) -> None:
    """Assert each fragment appears in the whitespace-collapsed section text.

    Args:
        relative_path: Repo-root-relative document path.
        heading: Exact ``##`` heading line that opens the section.
        fragments: Required verbatim fragments.

    Raises:
        AssertionError: Naming the document, section, and missing fragment.

    Side Effects:
        Reads the document from the filesystem.
    """
    section = collapse_whitespace(
        extract_section(read_repo_text(relative_path), heading)
    )
    for fragment in fragments:
        assert (
            fragment in section
        ), f"{relative_path.as_posix()} {heading} is missing required text: {fragment}"


def test_codex_ci_green_gate_names_ci_gate_keys_from_validator() -> None:
    """The Codex CI Green Gate defines `ci_gate` with the validator's keys."""
    # Arrange
    fragments = (
        "top-level `ci_gate` object with the required keys "
        + _english_list(CI_GATE_KEYS),
        "`verified_at` is the ISO-8601 time at which this gate (S9) recorded the"
        " result",
        "DONE requires `ci_gate.conclusion` equal to `success` and"
        " `ci_gate.head_sha` equal to the current PR head SHA",
        "`CI_GATE_KEYS` in `scripts/dev_tools/validate_orchestrator_state.py`",
    )

    # Act / Assert
    _assert_section_contains(CODEX_ORCHESTRATE, "## CI Green Gate", fragments)


def test_codex_ci_green_gate_names_pr_gate_keys_from_validator() -> None:
    """The Codex CI Green Gate defines `pr_gate` with the validator's keys."""
    # Arrange
    fragments = (
        "top-level `pr_gate` object with the keys " + _english_list(PR_GATE_KEYS),
        "`PR_GATE_KEYS` in `scripts/dev_tools/_orchestrator_state_routing.py`",
    )

    # Act / Assert
    _assert_section_contains(CODEX_ORCHESTRATE, "## CI Green Gate", fragments)


def test_codex_completion_list_includes_ci_gate_and_pr_gate() -> None:
    """The Codex Hard Enforcement Boundary lists `ci_gate` and `pr_gate` items."""
    # Arrange
    lines = extract_section(
        read_repo_text(CODEX_ORCHESTRATE), "## Hard Enforcement Boundary"
    ).splitlines()

    # Act
    ci_lines = [
        line
        for line in lines
        if line.startswith("- `ci_gate`:") and _english_list(CI_GATE_KEYS) in line
    ]
    pr_lines = [
        line
        for line in lines
        if line.startswith("- `pr_gate`:") and _english_list(PR_GATE_KEYS) in line
    ]

    # Assert
    assert ci_lines, "Hard Enforcement Boundary has no `ci_gate` item naming its keys"
    assert pr_lines, "Hard Enforcement Boundary has no `pr_gate` item naming its keys"


def test_codex_orchestrate_states_ci_dependent_checkoff_rule() -> None:
    """The Codex CI Green Gate assigns CI-dependent check-offs to the item's run."""
    # Arrange
    fragments = (
        "The item's own orchestrator run owns their check-off",
        "check off each CI-dependent criterion in the item's own worktree, commit,"
        " push to the PR branch, and re-run this gate against the new head SHA",
        "so that `ci_gate.head_sha` equals the final PR head before DONE",
        "never commits these check-offs from its own root",
    )

    # Act / Assert
    _assert_section_contains(CODEX_ORCHESTRATE, "## CI Green Gate", fragments)


def test_orchestrate_pr_creation_gate_condition_two_excludes_ci_dependent_ac() -> None:
    """PR Creation Gate condition 2 lists CI-dependent criteria as pending-CI."""
    # Arrange
    fragments = (
        "condition 2 is satisfied when every other criterion passes and each"
        " CI-dependent criterion is listed as pending-CI in the AC verification"
        " artifact",
        "Pending-CI criteria are checked off under S9 before DONE",
        "This clarifies condition 2 and adds no condition",
    )

    # Act / Assert
    _assert_section_contains(CLAUDE_ORCHESTRATE, "## PR Creation Gate", fragments)


def test_orchestrate_s9_requires_ci_dependent_checkoff_push_and_rerun() -> None:
    """Step S9 requires the check-off commit, a push, and an S9 re-run."""
    # Arrange
    fragments = (
        "the item's own orchestrator run owns their check-off",
        "check off each CI-dependent criterion in the item's own worktree, commit,"
        " push to the PR branch, and re-run S9 from step 1 against the new head SHA",
        "so that `ci_gate.head_sha` equals the final PR head before DONE",
        "A failed re-run enters `## Remediation Loop — CI-Failure Handling` below;"
        " the shared `remediation_loop.completed_attempts` count and its halt after"
        " three completed attempts are unchanged",
    )

    # Act / Assert
    _assert_section_contains(
        CLAUDE_ORCHESTRATE, "## Step S9 — CI Green Gate", fragments
    )


def test_parallel_orchestrate_merge_requires_head_sha_match_and_no_pending_ci_ac() -> (
    None
):
    """The parallel merge procedure checks the reported head and pending criteria."""
    # Arrange
    merge_fragments = (
        "Issue #744 later amended two parts of that child contract",
        "The parent never commits acceptance-criteria check-offs from the"
        " coordinator root",
        "confirm that the `headRefOid` value equals the `ci_gate.head_sha` the child"
        " reported at DONE",
        "the child reported no pending CI-dependent acceptance criteria",
        "do not record `merge_status: ci_green` and do not run `gh pr merge`",
    )
    completion_fragments = (
        "so the head the parent merges already contains the check-off",
    )

    # Act / Assert
    _assert_section_contains(
        PARALLEL_ORCHESTRATE,
        "## Per-Item Merge to Main (Merge-on-Green)",
        merge_fragments,
    )
    _assert_section_contains(
        PARALLEL_ORCHESTRATE, "## Completion Requirements", completion_fragments
    )


def test_parallel_orchestrator_agent_states_child_owns_ci_dependent_checkoffs() -> None:
    """The parallel-orchestrator agent leaves CI-dependent check-offs to the child."""
    # Arrange
    fragments = (
        "is checked off and pushed by the item's own run after its S9 success and"
        " before its DONE",
        "confirm that the `headRefOid` value equals that reported `ci_gate.head_sha`",
        "You never commit acceptance-criteria check-offs from the coordinator root",
    )

    # Act / Assert
    _assert_section_contains(
        PARALLEL_ORCHESTRATOR_AGENT, "## Completion Requirements", fragments
    )


@pytest.mark.parametrize(
    "skill_path",
    [path for _, path in AC_TRACKING_SKILLS],
    ids=[skill_id for skill_id, _ in AC_TRACKING_SKILLS],
)
def test_acceptance_criteria_tracking_skill_defines_ci_dependent_rule(
    skill_path: Path,
) -> None:
    """Each acceptance-criteria-tracking skill defines the CI-dependent rule."""
    # Arrange
    fragments = (
        "A CI-dependent criterion is one whose verification requires the result of"
        " CI on the PR head",
        "Owner: the item's own orchestrator run owns the check-off",
        "Timing: after the CI green gate (S9) records `ci_gate.conclusion` as"
        " `success`, and before the run reports DONE",
        "the CI green gate is re-run against the new head SHA so that"
        " `ci_gate.head_sha` equals the final PR head before DONE",
    )

    # Act / Assert
    _assert_section_contains(skill_path, "## Check-Off Protocol", fragments)


@pytest.mark.parametrize(
    "skill_path",
    [path for _, path in AC_TRACKING_SKILLS],
    ids=[skill_id for skill_id, _ in AC_TRACKING_SKILLS],
)
def test_acceptance_criteria_tracking_skill_cross_references_ci_dependent_exception(
    skill_path: Path,
) -> None:
    """The orchestrator check-off rule names the CI-dependent exception."""
    # Arrange
    fragments = (
        "Orchestrators do not directly check off AC items. The one exception is a"
        " CI-dependent criterion",
        "as described in `### CI-Dependent Criteria` above. For every other"
        " criterion, orchestrators instead:",
    )

    # Act / Assert
    _assert_section_contains(skill_path, "## Check-Off Protocol", fragments)


def test_feature_review_agent_grants_mcp_artifact_validator() -> None:
    """The feature-review agent's tools list ends with the MCP artifact validator."""
    # Arrange
    frontmatter = parse_frontmatter(read_repo_text(FEATURE_REVIEW_AGENT))
    expected = (
        "Read",
        "Grep",
        "Glob",
        "Bash(git diff *)",
        "Bash(git log *)",
        "Write(/docs/features/active/**)",
        "mcp__drm-copilot__validate_orchestration_artifacts",
    )

    # Act
    tools = string_sequence(frontmatter.get("tools"))

    # Assert
    assert tools == expected, f"feature-review tools are {tools}, expected {expected}"


def test_feature_review_agent_body_validates_each_review_artifact_type() -> None:
    """Output Reporting requires validating each review artifact by its type."""
    # Arrange
    typed_fragments = tuple(
        f'`artifact_type: "{kind}"` for `{kind}.<timestamp>.md`'
        for kind in ("policy-audit", "code-review", "feature-audit")
    )
    fragments = (
        "`mcp__drm-copilot__validate_orchestration_artifacts`",
        *typed_fragments,
        "fix the artifact in the same review and validate it again",
        "Report an artifact path only after its validation passes",
    )

    # Act / Assert
    _assert_section_contains(FEATURE_REVIEW_AGENT, "## Output Reporting", fragments)


@pytest.mark.parametrize(
    "skill_path",
    [path for _, path in EVIDENCE_SKILLS],
    ids=[skill_id for skill_id, _ in EVIDENCE_SKILLS],
)
def test_evidence_skill_states_first_occurrence_for_all_schema_fields(
    skill_path: Path,
) -> None:
    """Each evidence skill states the first-occurrence rule for every field."""
    # Arrange
    fragments = (
        "The first occurrence of `Timestamp`, `Command`, `EXIT_CODE`, and"
        " `ExpectedExitCode` forms the record in both the Python and the TypeScript"
        " parser",
        "An artifact that records several gates therefore reports its first gate",
        "When the field is duplicated, the FIRST occurrence wins in both the Python"
        " and the TypeScript parser",
    )

    # Act / Assert
    _assert_section_contains(
        skill_path, "## Evidence Artifact Schema (Machine-Checkable)", fragments
    )


@pytest.mark.parametrize(
    "skill_path",
    [path for _, path in EVIDENCE_SKILLS],
    ids=[skill_id for skill_id, _ in EVIDENCE_SKILLS],
)
def test_evidence_skill_states_timestamp_system_clock_source(skill_path: Path) -> None:
    """Each evidence skill states that `Timestamp` is read from the host clock."""
    # Arrange
    fragments = (TIMESTAMP_SOURCE_BLOCK,)

    # Act / Assert
    _assert_section_contains(skill_path, "## ISO-8601 Timestamp Format", fragments)


@pytest.mark.parametrize(
    ("source", "mirror"),
    [pair for _, pair in MIRROR_PAIRS],
    ids=[pair_id for pair_id, _ in MIRROR_PAIRS],
)
def test_edited_surface_matches_bundled_mirror(source: Path, mirror: Path) -> None:
    """Each edited surface is byte-identical to its bundled extension mirror."""
    # Arrange / Act
    source_bytes = (REPO_ROOT / source).read_bytes()
    mirror_bytes = (REPO_ROOT / mirror).read_bytes()

    # Assert
    assert (
        source_bytes == mirror_bytes
    ), f"{source.as_posix()} differs from its mirror {mirror.as_posix()}"
