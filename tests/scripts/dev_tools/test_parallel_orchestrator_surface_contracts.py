"""Contract tests for the parallel-orchestrator runtime surface (issue #441).

Purpose:
    Pin the structural and textual contract of the four artifacts this feature
    delivers: the ``parallel-orchestrator`` agent persona, the
    ``parallel-orchestrate`` procedure skill, the ``parallel-run`` entry-point
    skill, and the generated ``parallel-status.md`` template. The guarantees are
    expressed as runtime procedure text in Claude Markdown, so the repository's
    text-fragment contract-test convention (see
    ``test_epic_run_kickoff_discovery_contract.py``) is the applicable
    verification surface.

Flow:
    Frontmatter checks, then ordered-heading structure checks, then the
    section-scoped obligation matrix, then three producer/consumer seam checks
    that bind the skill's prescribed ``parallel-status.md`` names to the shipped
    template, then the prescriptive-literal negatives, then content-hash pinning
    of the two frozen epic files.

Invariants and constraints:
    Every section-scoped criterion extracts its section by heading boundary
    before matching, so a fragment that drifted into another section fails. The
    seam checks parse the producer's prescription at run time instead of
    restating it, so they fail when producer and consumer diverge. Pinned
    fragments live in ``parallel_orchestrator_surface_expectations``; parsers
    live in ``parallel_orchestrator_surface_test_support``. All checks are
    deterministic: no temporary file, no external process, no network.
"""

from __future__ import annotations

from pathlib import Path

import pytest

from tests.scripts.dev_tools import parallel_orchestrator_surface_expectations as pinned
from tests.scripts.dev_tools.parallel_orchestrator_surface_test_support import (
    AGENT_RELATIVE,
    BOUNDARIES_HEADING,
    DELIVERED_RUNTIME_FILES,
    KICKOFF_HEADING,
    ORCHESTRATE_SKILL_RELATIVE,
    PRESCRIPTIVE_EPIC_LITERALS,
    RUN_SKILL_RELATIVE,
    STATUS_TEMPLATE_RELATIVE,
    assert_fragments,
    collapse_whitespace,
    extract_section,
    file_sha256,
    markdown_table_header_cells,
    orchestrate_skill_section,
    parse_frontmatter,
    prescribed_cohort_table_columns,
    prescribed_header_fields,
    prescribed_projection_sections,
    read_repo_text,
    split_frontmatter,
    string_sequence,
    subagent_stop_hook_commands,
    top_level_headings,
)


def test_agent_frontmatter_declares_parallel_orchestrator_identity() -> None:
    """Require the agent frontmatter identity fields named by spec R1."""

    # Arrange / Act
    frontmatter = parse_frontmatter(read_repo_text(AGENT_RELATIVE))
    model = frontmatter.get("model")
    skills = string_sequence(frontmatter.get("skills"))

    # Assert
    assert frontmatter.get("name") == "parallel-orchestrator", (
        "agent name must be exactly 'parallel-orchestrator', found "
        f"{frontmatter.get('name')!r}"
    )
    assert isinstance(model, str) and model, "agent frontmatter declares no model"
    assert string_sequence(
        frontmatter.get("tools")
    ), "agent frontmatter declares no tools allowlist"
    assert (
        "parallel-orchestrate" in skills
    ), f"agent skills list must contain parallel-orchestrate, found {skills}"


def test_agent_tools_allowlist_excludes_pr_author_channel() -> None:
    """Require the agent to declare no ``Agent(pr-author)`` delegation channel."""

    # Arrange / Act
    frontmatter = parse_frontmatter(read_repo_text(AGENT_RELATIVE))
    tools = string_sequence(frontmatter.get("tools"))

    # Assert
    assert not [
        entry for entry in tools if "pr-author" in entry
    ], f"agent tools allowlist must not grant a pr-author channel: {tools}"


def test_agent_subagent_stop_hook_targets_parallel_checkpoint() -> None:
    """Require the SubagentStop hook to carry both checkpoint parameters."""

    # Arrange / Act
    frontmatter = parse_frontmatter(read_repo_text(AGENT_RELATIVE))
    commands = subagent_stop_hook_commands(frontmatter)

    # Assert
    assert commands, "agent frontmatter declares no SubagentStop hook command"
    assert_fragments(
        commands[0], pinned.HOOK_COMMAND_FRAGMENTS, "agent SubagentStop hook command"
    )


@pytest.mark.parametrize(
    "relative_path", [ORCHESTRATE_SKILL_RELATIVE, RUN_SKILL_RELATIVE]
)
def test_skill_frontmatter_forks_the_parallel_orchestrator_agent(
    relative_path: Path,
) -> None:
    """Require both delivered skills to fork the parallel-orchestrator agent."""

    # Arrange / Act
    frontmatter = parse_frontmatter(read_repo_text(relative_path))

    # Assert
    assert (
        frontmatter.get("context") == "fork"
    ), f"{relative_path} must declare context: fork"
    assert (
        frontmatter.get("agent") == "parallel-orchestrator"
    ), f"{relative_path} must declare agent: parallel-orchestrator"


def test_orchestrate_skill_argument_hint_accepts_manifest_path_or_slug() -> None:
    """Require the procedure skill to accept a manifest path or a run slug."""

    # Arrange / Act
    frontmatter = parse_frontmatter(read_repo_text(ORCHESTRATE_SKILL_RELATIVE))
    hint = frontmatter.get("argument-hint")

    # Assert
    assert isinstance(hint, str), "parallel-orchestrate declares no argument hint"
    assert "parallel-manifest-path" in hint and "parallel-slug" in hint, (
        "parallel-orchestrate argument hint must accept the parallel manifest "
        f"path or slug, found {hint!r}"
    )


def test_run_skill_argument_hint_is_the_parallel_slug() -> None:
    """Require the entry-point skill to take the parallel slug as its argument."""

    # Arrange / Act
    frontmatter = parse_frontmatter(read_repo_text(RUN_SKILL_RELATIVE))
    hint = frontmatter.get("argument-hint")

    # Assert
    assert (
        hint == "[parallel-slug]"
    ), f"parallel-run argument hint must be '[parallel-slug]', found {hint!r}"


def test_status_template_begins_with_generated_file_banner() -> None:
    """Require the status template to open with a do-not-hand-author banner."""

    # Arrange / Act
    template_text = read_repo_text(STATUS_TEMPLATE_RELATIVE)
    banner = template_text.split("-->", 1)[0]

    # Assert
    assert template_text.startswith(
        "<!--"
    ), "parallel-status.md template must begin with an HTML comment banner"
    assert_fragments(
        banner, pinned.TEMPLATE_BANNER_FRAGMENTS, "parallel-status.md template banner"
    )


def test_agent_body_contains_exactly_the_nine_required_headings() -> None:
    """Require the agent body's section set to be exactly the nine of spec R1."""

    # Arrange / Act
    _, body = split_frontmatter(read_repo_text(AGENT_RELATIVE))
    headings = top_level_headings(body)

    # Assert
    assert headings == pinned.AGENT_HEADINGS, (
        "parallel-orchestrator.md headings must be exactly "
        f"{pinned.AGENT_HEADINGS}, found {headings}"
    )


def test_orchestrate_skill_intro_heading_precedes_prerequisites() -> None:
    """Require the skill's ``#`` intro heading to open the body (R2.1 item 2)."""

    # Arrange / Act
    _, body = split_frontmatter(read_repo_text(ORCHESTRATE_SKILL_RELATIVE))
    level_one = [line.rstrip() for line in body.splitlines() if line.startswith("# ")]

    # Assert
    assert level_one, "parallel-orchestrate/SKILL.md declares no '#' intro heading"
    assert (
        level_one[0] == "# Parallel Orchestrate Skill"
    ), f"intro heading must be '# Parallel Orchestrate Skill', found {level_one[0]!r}"
    assert body.index("# Parallel Orchestrate Skill") < body.index(
        "## Prerequisites"
    ), "the intro heading must precede '## Prerequisites'"


def test_orchestrate_skill_first_thirteen_headings_match_required_layout() -> None:
    """Require the R2.1 section layout and a total of sixteen ``##`` headings."""

    # Arrange / Act
    _, body = split_frontmatter(read_repo_text(ORCHESTRATE_SKILL_RELATIVE))
    headings = top_level_headings(body)

    # Assert
    assert len(headings) == 16, (
        "parallel-orchestrate/SKILL.md must carry exactly sixteen '##' headings, "
        f"found {len(headings)}: {headings}"
    )
    assert headings[:13] == pinned.SKILL_HEADINGS, (
        f"the first thirteen headings must be exactly {pinned.SKILL_HEADINGS}, "
        f"found {headings[:13]}"
    )


def test_orchestrate_skill_reserved_wave_four_sections_close_the_file() -> None:
    """Require the three reserved sections to be the final headings, once each."""

    # Arrange / Act
    _, body = split_frontmatter(read_repo_text(ORCHESTRATE_SKILL_RELATIVE))
    headings = top_level_headings(body)

    # Assert
    assert headings[-3:] == pinned.RESERVED_HEADINGS, (
        f"the final three headings must be {pinned.RESERVED_HEADINGS}, "
        f"found {headings[-3:]}"
    )

    # Uniqueness matters because a duplicated placeholder would give a wave-4
    # feature two candidate append points.
    for heading in pinned.RESERVED_HEADINGS:
        assert (
            headings.count(heading) == 1
        ), f"reserved heading must appear exactly once: {heading}"


def test_orchestrate_skill_reserved_sections_carry_one_line_reserved_body() -> None:
    """Require each still-reserved section body to be its reserved sentence.

    A heading listed in ``POPULATED_RESERVED_HEADINGS`` is skipped: its owning
    wave-4 feature has landed its content, so its body is legitimately no longer
    the placeholder. Every other reserved section must still carry the one-line
    statement, which is what keeps one wave-4 feature from writing into another's
    section ahead of that feature.
    """

    # Assert each remaining placeholder body is exactly the one-line reserved
    # statement, so no wave-4 content has been added ahead of its own feature.
    for heading in pinned.RESERVED_HEADINGS:
        if heading in pinned.POPULATED_RESERVED_HEADINGS:
            continue
        feature = heading.rsplit("(", 1)[1].rstrip(")")
        body = collapse_whitespace(orchestrate_skill_section(heading))
        expected = (
            f"Reserved for {feature}; content is appended by that feature "
            "and must not be relocated."
        )
        assert body == expected, f"{heading} body must be {expected!r}, found {body!r}"


@pytest.mark.parametrize(
    ("heading", "fragments"),
    [case[1:] for case in pinned.SECTION_OBLIGATION_CASES],
    ids=[case[0] for case in pinned.SECTION_OBLIGATION_CASES],
)
def test_orchestrate_skill_section_states_its_required_obligations(
    heading: str, fragments: tuple[str, ...]
) -> None:
    """Require one named section to state the obligations of one criterion.

    Each parametrized case is one section-scoped acceptance criterion. The
    section is extracted by heading boundary first, so a fragment that moved to
    another section fails the case that owns it.
    """

    # Arrange / Act
    section = orchestrate_skill_section(heading)

    # Assert
    assert_fragments(section, fragments, heading)


def test_kickoff_section_carries_no_child_merge_instruction() -> None:
    """Require the kickoff section to contain no ``gh pr merge`` occurrence."""

    # Arrange / Act
    section = orchestrate_skill_section(KICKOFF_HEADING)

    # Assert
    assert "gh pr merge" not in section, (
        f"{KICKOFF_HEADING} must not instruct the child to merge its own pull "
        "request, so it must contain no 'gh pr merge' occurrence"
    )


def test_seam_status_template_realises_header_fields_prescribed_by_skill() -> None:
    """Bind the skill-prescribed header fields to the shipped status template.

    The prescribed names are parsed out of the producer section at run time, so
    this check fails when the producer adds, renames, or drops a field without a
    matching template change. Independent per-side assertions cannot detect that.
    """

    # Arrange
    section = orchestrate_skill_section(BOUNDARIES_HEADING)
    prescribed = prescribed_header_fields(section)
    template_text = read_repo_text(STATUS_TEMPLATE_RELATIVE)

    # Act / Assert
    assert len(prescribed) == 6, (
        f"producer {ORCHESTRATE_SKILL_RELATIVE} section {BOUNDARIES_HEADING} must "
        f"prescribe six header fields; parsed {prescribed}"
    )

    # Bind each prescribed name to the consumer template.
    for field_name in prescribed:
        assert f"`{field_name}`" in template_text, (
            f"consumer {STATUS_TEMPLATE_RELATIVE} does not realise header field "
            f"`{field_name}` prescribed by producer {ORCHESTRATE_SKILL_RELATIVE} "
            f"section {BOUNDARIES_HEADING}"
        )


def test_seam_status_template_realises_cohort_columns_prescribed_by_skill() -> None:
    """Bind the skill-prescribed cohort-table columns to the status template.

    The column names are parsed from the producer's ``cohorts[] { ... }``
    projection sentence at run time and must all appear in one table header row
    of the template, so a divergent column set fails here.
    """

    # Arrange
    section = orchestrate_skill_section(BOUNDARIES_HEADING)
    prescribed = prescribed_cohort_table_columns(section)
    header_rows = markdown_table_header_cells(read_repo_text(STATUS_TEMPLATE_RELATIVE))

    # Act / Assert
    assert len(prescribed) >= 3, (
        f"producer {ORCHESTRATE_SKILL_RELATIVE} section {BOUNDARIES_HEADING} must "
        f"prescribe the cohort-table columns; parsed {prescribed}"
    )
    matching = [row for row in header_rows if set(prescribed) <= row]
    assert matching, (
        f"consumer {STATUS_TEMPLATE_RELATIVE} has no cohort table header row "
        f"realising every column {prescribed} prescribed by producer "
        f"{ORCHESTRATE_SKILL_RELATIVE} section {BOUNDARIES_HEADING}; template "
        f"header rows are {[sorted(row) for row in header_rows]}"
    )


def test_seam_status_template_realises_projections_prescribed_by_skill() -> None:
    """Bind the skill-prescribed read-only projection sections to the template.

    The section names are parsed from the producer text at run time, so renaming
    a projection section on one side only fails this check.
    """

    # Arrange
    section = orchestrate_skill_section(BOUNDARIES_HEADING)
    prescribed = prescribed_projection_sections(section)
    template_headings = top_level_headings(read_repo_text(STATUS_TEMPLATE_RELATIVE))

    # Act / Assert
    assert len(prescribed) == 3, (
        f"producer {ORCHESTRATE_SKILL_RELATIVE} section {BOUNDARIES_HEADING} must "
        f"prescribe three read-only projection sections; parsed {prescribed}"
    )

    # Bind each prescribed section heading to the consumer template.
    for heading in prescribed:
        assert heading in template_headings, (
            f"consumer {STATUS_TEMPLATE_RELATIVE} does not realise projection "
            f"section {heading!r} prescribed by producer "
            f"{ORCHESTRATE_SKILL_RELATIVE} section {BOUNDARIES_HEADING}; "
            f"template headings are {template_headings}"
        )


def test_checkpoint_section_states_the_four_arrays_never_written() -> None:
    """Require the never-written list that keeps F6 and F8 fields untouched."""

    # Arrange / Act
    section = collapse_whitespace(orchestrate_skill_section(pinned.CHECKPOINT_HEADING))
    never_written = section.split("Never written by this feature:", 1)

    # Assert
    assert (
        len(never_written) == 2
    ), f"{pinned.CHECKPOINT_HEADING} states no never-written list"
    assert_fragments(
        never_written[1],
        pinned.NEVER_WRITTEN_FRAGMENTS,
        f"{pinned.CHECKPOINT_HEADING} never-written list",
    )


def test_skill_names_both_f7_dependency_block_reasons() -> None:
    """Require the skill to name the two epic gates that block execution."""

    # Arrange / Act
    skill_text = read_repo_text(ORCHESTRATE_SKILL_RELATIVE)

    # Assert
    assert_fragments(
        skill_text, pinned.F7_BLOCK_REASON_FRAGMENTS, str(ORCHESTRATE_SKILL_RELATIVE)
    )


def test_run_skill_stop_path_names_parallel_plan_and_plan_path_resume() -> None:
    """Require the STOP branch, its ``/parallel-plan`` guidance, and the resume rule."""

    # Arrange / Act
    _, body = split_frontmatter(read_repo_text(RUN_SKILL_RELATIVE))
    section = extract_section(body, pinned.PROCEDURE_HEADING)

    # Assert
    assert_fragments(
        section,
        pinned.RUN_PROCEDURE_FRAGMENTS,
        f"parallel-run/SKILL.md {pinned.PROCEDURE_HEADING}",
    )


@pytest.mark.parametrize("relative_path", list(DELIVERED_RUNTIME_FILES))
def test_delivered_runtime_files_carry_no_prescriptive_epic_literal(
    relative_path: Path,
) -> None:
    """Require the delivered files to carry none of the epic-surface literals."""

    # Arrange / Act
    file_text = read_repo_text(relative_path)

    # Assert each forbidden literal individually so the failure names the one
    # that leaked into the parallel surface.
    for literal in PRESCRIPTIVE_EPIC_LITERALS:
        assert (
            literal not in file_text
        ), f"{relative_path} must not contain the epic literal: {literal}"


@pytest.mark.parametrize(
    ("relative_path", "expected_digest"), pinned.PINNED_FROZEN_SURFACE_HASHES
)
def test_frozen_epic_surface_matches_pinned_baseline_digest(
    relative_path: str, expected_digest: str
) -> None:
    """Require the frozen epic files to match their pre-feature content digests."""

    # Arrange / Act
    actual_digest = file_sha256(Path(relative_path))

    # Assert
    assert actual_digest == expected_digest, (
        f"{relative_path} must be byte-identical to its pre-feature state; "
        f"expected SHA-256 {expected_digest}, found {actual_digest}"
    )
