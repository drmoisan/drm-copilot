"""Contract tests for the epic-run cross-branch kickoff discovery wording.

These tests pin the fix for the epic-run entry-gate discovery bug: `/epic-run`
must not declare the kickoff artifact missing based on the invoking worktree's
working tree alone, because `epic-plan` commits
`docs/features/epics/<epic-slug>/epic-kickoff.md` only to the integration branch
`epic/<epic-slug>-integration`. The guarantees are expressed as runtime
procedure text in the Claude skill/agent Markdown, so the repository's
text-fragment contract-test convention (see
``test_orchestration_guardrail_contracts.py``) is the applicable verification
surface. The mirror assertion also enforces that the fix reaches the distributed
``extensions/`` payload byte-for-byte.
"""

from __future__ import annotations

from pathlib import Path

REPO_ROOT = Path(__file__).resolve().parents[3]

EPIC_RUN_SKILL_RELATIVE = Path(".claude/skills/epic-run/SKILL.md")
EPIC_ORCHESTRATOR_AGENT_RELATIVE = Path(".claude/agents/epic-orchestrator.md")
BUNDLED_CLAUDE_ROOT = (
    REPO_ROOT / "extensions" / "drm-copilot" / "resources" / "claude-customizations"
)


def read_repo_text(relative_path: Path) -> str:
    """Return UTF-8 text for a repository file addressed relative to the root.

    Args:
        relative_path: Repo-root-relative path to the file to read.

    Returns:
        The file's UTF-8 decoded content.
    """

    return (REPO_ROOT / relative_path).read_text(encoding="utf-8")


def test_epic_run_skill_discovers_kickoff_across_integration_branch() -> None:
    """Require epic-run step 2 to fetch and read the kickoff from the branch.

    Encodes the acceptance criterion that discovery attempts a fetch of the
    integration branch, tests presence on that ref (not only the local working
    tree), reads the artifact via ``git show`` without a checkout, and stops only
    when the artifact is absent in both locations.
    """

    skill_text = read_repo_text(EPIC_RUN_SKILL_RELATIVE)

    # Each fragment pins one required behavior of the fixed discovery step so a
    # regression that reverts to a working-tree-only check fails this test.
    required_fragments = (
        "git fetch origin epic/<epic-slug>-integration",
        "git cat-file -e epic/<epic-slug>-integration:"
        "docs/features/epics/<epic-slug>/epic-kickoff.md",
        "git show <ref>:<path>",
        "absent BOTH locally and on the",
        "must never be checked out onto the integration branch",
    )

    # Assert every required behavior fragment is present in the skill text.
    for fragment in required_fragments:
        assert fragment in skill_text, f"epic-run SKILL.md missing fragment: {fragment}"


def test_epic_run_skill_tolerates_missing_integration_branch() -> None:
    """Require the missing-branch case to remain the genuine not-planned stop.

    A fetch failure because the remote integration branch does not exist must be
    tolerated (continue to the local check), and the skill must still direct the
    user to run ``/epic-plan`` when the artifact is genuinely absent.
    """

    skill_text = read_repo_text(EPIC_RUN_SKILL_RELATIVE)

    assert 'genuine "epic not planned" case' in skill_text
    assert "the user must run\n     `/epic-plan` first" in skill_text


def test_epic_orchestrator_precondition_establishes_kickoff_presence() -> None:
    """Require the Prepared-Epic section to state how kickoff presence is set.

    The precondition must no longer assert bare local presence; it must establish
    presence by fetching the integration branch and reading the kickoff from that
    ref without a worktree checkout.
    """

    agent_text = read_repo_text(EPIC_ORCHESTRATOR_AGENT_RELATIVE)

    # Fragments that pin the fetch-then-read precondition on the integration ref.
    required_fragments = (
        "git fetch origin epic/<epic-slug>-integration",
        "git show origin/epic/<epic-slug>-integration:"
        "docs/features/epics/<epic-slug>/epic-kickoff.md",
        "without checking the integration branch out into the invoking worktree",
    )

    # Assert each precondition fragment is present in the agent text.
    for fragment in required_fragments:
        assert (
            fragment in agent_text
        ), f"epic-orchestrator.md missing fragment: {fragment}"


def test_discovery_fix_is_mirrored_into_bundled_payload() -> None:
    """Require the bundled Claude payload to match the source files byte-for-byte.

    The distributed runtime under ``extensions/`` is the copy end users receive,
    so the discovery fix must be present there identically, matching the mirror
    contract enforced elsewhere for the ``.claude`` payload.
    """

    # Both runtime files must be byte-identical between source and bundle so the
    # fix ships to consumers and the push-down mirror gate stays satisfied.
    for relative_path in (EPIC_RUN_SKILL_RELATIVE, EPIC_ORCHESTRATOR_AGENT_RELATIVE):
        source_text = read_repo_text(relative_path)
        bundled_text = (BUNDLED_CLAUDE_ROOT / relative_path).read_text(encoding="utf-8")
        assert source_text == bundled_text, f"bundled payload drift: {relative_path}"
