"""Contract tests for the parallel-planner runtime surface (spec R9).

The parallel planning surface is delivered as two Claude runtime Markdown files:
the agent persona ``.claude/agents/parallel-planner.md`` and the planning skill
``.claude/skills/parallel-plan/SKILL.md``. Their guarantees are expressed as
procedure text rather than as executable code, so the repository's text-fragment
contract-test convention (see ``test_epic_run_kickoff_discovery_contract.py``)
is the applicable verification surface.

These tests pin three classes of guarantee:

* Positive presence of the required frontmatter declarations and procedure text.
* Negative absence of epic-surface constructs the parallel surface deliberately
  omits (worthiness gate, dependency authoring, integration branch), plus
  content guards proving the protected epic/atomic surfaces were not edited.
* Agreement with the LANDED upstream contracts of F1 (blast radius) and F2
  (cohort scheduler), and with the F4-owned obligations that F3's landed rules
  file assigns to this planner surface.
"""

from __future__ import annotations

from pathlib import Path

REPO_ROOT = Path(__file__).resolve().parents[3]

PARALLEL_PLANNER_AGENT_RELATIVE = Path(".claude/agents/parallel-planner.md")
PARALLEL_PLAN_SKILL_RELATIVE = Path(".claude/skills/parallel-plan/SKILL.md")

ATOMIC_PLAN_CONTRACT_RELATIVE = Path(".claude/skills/atomic-plan-contract/SKILL.md")
EPIC_PLANNER_AGENT_RELATIVE = Path(".claude/agents/epic-planner.md")
EPIC_PLAN_SKILL_RELATIVE = Path(".claude/skills/epic-plan/SKILL.md")

# Stable identifying fragments verified to exist in each protected file's current
# text. They are content guards, not behavior assertions: if this feature were to
# edit a protected surface, the removed or reworded fragment fails the guard.
UNMODIFIED_SURFACE_GUARDS: tuple[tuple[Path, tuple[str, ...]], ...] = (
    (
        ATOMIC_PLAN_CONTRACT_RELATIVE,
        (
            "name: atomic-plan-contract",
            "Shared rules for atomic plan formatting, Phase 0 requirements, "
            "baseline capture, and final QA loops.",
            "## Canonical Plan Format",
        ),
    ),
    (
        EPIC_PLANNER_AGENT_RELATIVE,
        (
            "name: epic-planner",
            '"Write(docs/features/epics/**)"',
            "# Epic Planner Agent",
        ),
    ),
    (
        EPIC_PLAN_SKILL_RELATIVE,
        (
            "name: epic-plan",
            "agent: epic-planner",
            "# Epic Plan Skill",
        ),
    ),
)


def read_repo_text(relative_path: Path) -> str:
    """Return UTF-8 text for a repository file addressed relative to the root.

    Args:
        relative_path: Repo-root-relative path to the file to read.

    Returns:
        The file's UTF-8 decoded content.

    Raises:
        FileNotFoundError: If the addressed file does not exist.
    """

    return (REPO_ROOT / relative_path).read_text(encoding="utf-8")


def read_frontmatter(relative_path: Path) -> str:
    """Return only the YAML frontmatter block of a repository Markdown file.

    Frontmatter-scoped assertions must not be satisfiable by body prose that
    merely mentions a tool name, so the block is isolated before matching.

    Args:
        relative_path: Repo-root-relative path to the Markdown file to read.

    Returns:
        The text between the opening ``---`` delimiter and its closing ``---``,
        excluding both delimiter lines. Returns an empty string when the file
        does not open with a frontmatter delimiter.
    """

    text = read_repo_text(relative_path)
    lines = text.splitlines()

    # A file without the opening delimiter carries no frontmatter at all; return
    # empty so frontmatter assertions fail loudly rather than matching body text.
    if not lines or lines[0].strip() != "---":
        return ""

    # Walk from the line after the opening delimiter to the first closing
    # delimiter; that span is the frontmatter block.
    for index in range(1, len(lines)):
        if lines[index].strip() == "---":
            return "\n".join(lines[1:index])

    return ""


def extract_preparation_kickoff_line(skill_text: str) -> str:
    """Return the literal preparation-mode kickoff line from the skill text.

    The mode-marker absence guarantees are scoped to the emitted delegation
    prompt itself, not to the surrounding prose that explains the omission, so
    the single blockquoted kickoff line is isolated before matching.

    Args:
        skill_text: Full UTF-8 text of the parallel-plan skill document.

    Returns:
        The blockquoted line carrying the ``Preparation mode: true.`` marker.

    Raises:
        AssertionError: If no such blockquoted kickoff line is present.
    """

    # The kickoff line is the one blockquote line bearing the route markers;
    # prose discussing the omissions is not blockquoted and is excluded.
    for line in skill_text.splitlines():
        stripped = line.strip()
        if stripped.startswith(">") and "Preparation mode: true." in stripped:
            return stripped

    raise AssertionError("parallel-plan SKILL.md has no blockquoted kickoff line")


def test_parallel_planner_surface_files_exist() -> None:
    """Require both runtime deliverables of the parallel planning surface.

    Spec R9 names the agent persona and the planning skill as the two files the
    surface consists of; every later assertion presumes both are present.
    """

    assert (
        REPO_ROOT / PARALLEL_PLANNER_AGENT_RELATIVE
    ).is_file(), "missing .claude/agents/parallel-planner.md"
    assert (
        REPO_ROOT / PARALLEL_PLAN_SKILL_RELATIVE
    ).is_file(), "missing .claude/skills/parallel-plan/SKILL.md"


def test_agent_frontmatter_declares_required_tool_allowlist() -> None:
    """Require the persona frontmatter to grant exactly the needed capabilities.

    Each fragment pins one capability the documented procedure cannot run
    without: delegation to child orchestrators, authoring under the parallel
    docs tree, the import-only upstream library invocation, and MCP validation.
    """

    frontmatter = read_frontmatter(PARALLEL_PLANNER_AGENT_RELATIVE)

    # Each entry is a distinct allowlist grant required by a documented step.
    required_entries = (
        '"Agent(orchestrator)"',
        '"Write(docs/features/parallel/**)"',
        '"Edit(docs/features/parallel/**)"',
        '"Bash(poetry run *)"',
        '"mcp__drm-copilot__validate_orchestration_artifacts"',
    )

    # Assert every required allowlist entry appears in the frontmatter block.
    for entry in required_entries:
        assert (
            entry in frontmatter
        ), f"parallel-planner.md frontmatter missing tool entry: {entry}"


def test_agent_frontmatter_declares_name_and_preloaded_skills() -> None:
    """Require the persona identity and its preloaded skill set.

    The skill list is what binds the persona to the planning procedure and to
    the shared policy/evidence contracts, so its members are pinned by name.
    """

    frontmatter = read_frontmatter(PARALLEL_PLANNER_AGENT_RELATIVE)

    assert "name: parallel-planner" in frontmatter
    assert "memory: project" in frontmatter

    # The five preloaded skills the persona must carry into every invocation.
    required_skills = (
        "policy-compliance-order",
        "parallel-plan",
        "feature-promotion-lifecycle",
        "atomic-plan-contract",
        "evidence-and-timestamp-conventions",
    )

    # Assert each preloaded skill is declared in the frontmatter skill list.
    for skill_name in required_skills:
        assert (
            skill_name in frontmatter
        ), f"parallel-planner.md frontmatter missing skill: {skill_name}"


def test_skill_frontmatter_routes_to_the_parallel_planner_agent() -> None:
    """Require the skill to fork into the parallel-planner persona.

    ``context: fork`` plus ``agent: parallel-planner`` is the wiring that makes
    ``/parallel-plan`` run under the persona rather than in the main session.
    """

    frontmatter = read_frontmatter(PARALLEL_PLAN_SKILL_RELATIVE)

    assert "name: parallel-plan" in frontmatter
    assert "context: fork" in frontmatter
    assert "agent: parallel-planner" in frontmatter


def test_skill_carries_the_preparation_mode_kickoff_markers() -> None:
    """Require the literal route-selection markers in the preparation kickoff.

    Route selection for child orchestrators is marker-driven, so the exact
    marker strings must survive verbatim in the emitted delegation prompt.
    """

    skill_text = read_repo_text(PARALLEL_PLAN_SKILL_RELATIVE)

    assert "Preparation mode: true" in skill_text
    assert "route_id: preparation" in skill_text


def test_skill_branches_preparation_worktrees_from_origin_main() -> None:
    """Require preparation worktrees to be branched from ``origin/main``.

    Items are unrelated and each opens its own pull request against ``main``,
    so every preparation branch must start from the shared upstream tip rather
    than from any run-level or integration branch.
    """

    skill_text = read_repo_text(PARALLEL_PLAN_SKILL_RELATIVE)

    assert "Create each preparation worktree's branch from `origin/main`." in skill_text


def test_skill_names_the_planner_checkpoint_and_manifest_paths() -> None:
    """Require the checkpoint and run-manifest paths to be named literally.

    Downstream features locate these artifacts by exact path, so the skill must
    state them rather than describing them generically.
    """

    skill_text = read_repo_text(PARALLEL_PLAN_SKILL_RELATIVE)

    assert "artifacts/orchestration/parallel-planner-state.json" in skill_text
    assert "docs/features/parallel/<slug>/parallel.md" in skill_text


def test_skill_names_both_kickoff_artifact_paths() -> None:
    """Require both the working and durable kickoff artifact paths.

    The kickoff exists twice by design: a gitignored working copy for the
    planner and a committed durable copy on the run branch for consumers.
    """

    skill_text = read_repo_text(PARALLEL_PLAN_SKILL_RELATIVE)

    assert "artifacts/orchestration/parallel-kickoff-<slug>.md" in skill_text
    assert "docs/features/parallel/<slug>/parallel-kickoff.md" in skill_text


def test_agent_frontmatter_declares_no_epic_docs_scope() -> None:
    """Forbid any epic-tree write or edit grant on the parallel persona.

    The parallel surface owns ``docs/features/parallel/**`` only. An epic-tree
    grant would let this persona edit the epic surface it must leave alone.
    """

    frontmatter = read_frontmatter(PARALLEL_PLANNER_AGENT_RELATIVE)

    assert (
        "docs/features/epics" not in frontmatter
    ), "parallel-planner.md frontmatter must not scope the epic docs tree"
    assert (
        "docs/features/active" not in frontmatter
    ), "parallel-planner.md frontmatter must not scope the active docs tree"


def test_preparation_kickoff_line_carries_neither_mode_marker() -> None:
    """Forbid both mode markers inside the emitted preparation kickoff line.

    ``Epic mode: true`` would subject preparation to the epic wave-barrier hook
    and ``Parallel mode: true`` would subject it to F7's future cohort-barrier
    hook. Preparation is deliberately gated by neither.
    """

    kickoff_line = extract_preparation_kickoff_line(
        read_repo_text(PARALLEL_PLAN_SKILL_RELATIVE)
    )

    assert "Epic mode: true" not in kickoff_line
    assert "Parallel mode: true" not in kickoff_line


def test_skill_omission_of_mode_markers_is_stated_deliberately() -> None:
    """Require the marker omission to be recorded as intentional.

    An undocumented omission invites a later editor to "fix" it by adding a
    marker, so the skill states that both omissions must be preserved.
    """

    skill_text = read_repo_text(PARALLEL_PLAN_SKILL_RELATIVE)

    assert "Both omissions are intentional" in skill_text
    assert "must be preserved verbatim when the line is emitted" in skill_text


def test_skill_contains_no_dependency_authoring_instruction() -> None:
    """Forbid instructions that would author dependency edges.

    Ordering on the parallel surface is derived from blast-radius contention.
    Every ``depends_on`` mention must be a prohibition, never an instruction to
    record or solicit one.
    """

    skill_text = read_repo_text(PARALLEL_PLAN_SKILL_RELATIVE)

    # Phrasings that would direct the planner to author or solicit an edge.
    forbidden_fragments = (
        "record `depends_on`",
        "Record `depends_on`",
        "set `depends_on`",
        "ask the operator for `depends_on`",
        "depends_on:",
    )

    # Assert no authoring phrasing appears anywhere in the skill text.
    for fragment in forbidden_fragments:
        assert (
            fragment not in skill_text
        ), f"parallel-plan SKILL.md must not author dependencies: {fragment}"

    # The prohibition itself must be stated positively so the absence is pinned.
    assert "carries no `depends_on` field at any level" in skill_text
    assert "The operator is never asked for ordering edges" in skill_text


def test_skill_contains_no_integration_branch_creation_instruction() -> None:
    """Forbid creating an integration branch for a parallel run.

    Each parallel item opens its own pull request against ``main``; the
    ``parallel/<slug>-plan`` run branch is explicitly not an integration branch.
    """

    skill_text = read_repo_text(PARALLEL_PLAN_SKILL_RELATIVE)

    # Phrasings that would direct creation of, or a merge into, an integration
    # branch. The parallel surface has no fan-in step at all.
    forbidden_fragments = (
        "integration branch is created",
        "create the integration branch",
        "Create the integration branch",
        "integration_branch:",
        "epic/<epic-slug>-integration",
    )

    # Assert no integration-branch creation phrasing appears in the skill text.
    for fragment in forbidden_fragments:
        assert (
            fragment not in skill_text
        ), f"parallel-plan SKILL.md must not create an integration branch: {fragment}"

    # The not-an-integration-branch statement pins the intended contract.
    assert "explicitly not an integration branch" in skill_text
    assert "There is no fan-in merge step" in skill_text


def test_skill_contains_no_worthiness_gate() -> None:
    """Forbid an epic-worthiness gate analogue on the parallel surface.

    Scale assessment happens before parallel planning is invoked, so the skill
    renders no worthiness verdict and carries no such section.
    """

    skill_text = read_repo_text(PARALLEL_PLAN_SKILL_RELATIVE)

    assert "worthiness verdict" in skill_text, "the deliberate absence must be stated"
    assert "## Epic Worthiness" not in skill_text
    assert "NON_EPIC_RECOMMENDED" not in skill_text


def test_protected_surfaces_retain_their_identifying_content() -> None:
    """Require the three protected files to still carry known content.

    This feature must not modify the atomic-plan contract, the epic planner
    persona, or the epic planning skill. Each guard fragment was verified to
    exist in the file's current text, so its removal signals an edit.
    """

    # Walk each protected file and confirm every identifying fragment survives.
    for relative_path, fragments in UNMODIFIED_SURFACE_GUARDS:
        guarded_text = read_repo_text(relative_path)
        for fragment in fragments:
            assert (
                fragment in guarded_text
            ), f"protected surface {relative_path} lost fragment: {fragment}"
