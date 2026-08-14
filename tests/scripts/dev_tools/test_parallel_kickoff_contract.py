"""Structural tests for the parallel kickoff Markdown contract.

Covers `scripts/dev_tools/parallel_kickoff_contract.py` and its extracted
table-primitive helper `scripts/dev_tools/_parallel_kickoff_tables.py`. Every
fixture document is an in-memory string literal; the suite creates no files and
starts no external processes.
"""

from __future__ import annotations

import pytest

from scripts.dev_tools import parallel_kickoff_contract as kickoff_contract
from scripts.dev_tools.parallel_kickoff_contract import (
    ITEM_HEADERS,
    KickoffItem,
    parse_parallel_kickoff,
    validate_parallel_kickoff_text,
)

ITEM_HEADER_ROW = (
    "| issue_num | feature_folder | cohort | complexity | branch | plan-path |"
)
ITEM_SEPARATOR_ROW = "| --- | --- | --- | --- | --- | --- |"
ITEM_ROW_101 = (
    "| 101 | docs/features/active/item-101 | 0 | C3 | feature/item-101 | "
    "docs/features/active/item-101/plan.md |"
)
ITEM_ROW_202 = (
    "| 202 | docs/features/active/item-202 | 1 | C2 | feature/item-202 | "
    "docs/features/active/item-202/plan.md |"
)
HASH_40 = "a" * 40
HASH_64 = "b" * 64


def test_ready_identity_path_seam_covers_slug_inputs() -> None:
    """The identity seam accepts valid slugs and rejects invalid boundaries."""

    resolver = getattr(kickoff_contract, "_ready_identity_paths", None)
    assert callable(resolver), "ready-identity path testability seam must exist"
    assert resolver("sample-run") == (
        "docs/features/parallel/sample-run/parallel.md",
        "parallel/sample-run-plan",
    )
    assert resolver("x") == ("docs/features/parallel/x/parallel.md", "parallel/x-plan")
    with pytest.raises(ValueError):
        resolver("Sample_Run")
    with pytest.raises(ValueError):
        resolver("")


def kickoff(*, rows: tuple[str, ...] = (ITEM_ROW_101,)) -> str:
    """Render a canonical kickoff for ``rows`` without optional integrity data."""

    return "\n".join(
        (
            "# Parallel Kickoff: sample-run",
            "## Invocation Prompt",
            "Run `/parallel-run sample-run` to execute this parallel run.",
            "Use the parallel-orchestrator subagent to execute the prepared run at",
            "docs/features/parallel/sample-run/parallel.md. The plan-home branch",
            "parallel/sample-run-plan already contains every approved atomic plan;",
            "items resume at atomic execution from their committed plan-path on",
            "their own pushed feature branch rather than re-planning.",
            "## Item Summary",
            ITEM_HEADER_ROW,
            ITEM_SEPARATOR_ROW,
            *rows,
        )
    )


def kickoff_with_integrity(
    *,
    rows: tuple[str, ...] = (ITEM_ROW_101,),
    integrity_lines: tuple[str, ...] = (
        f"planning_commit: {'e' * 40}",
        "| plan-path | plan-hash |",
        "| --- | --- |",
        f"| docs/features/active/item-101/plan.md | {HASH_40} |",
    ),
) -> str:
    """Render a kickoff for ``rows`` with supplied ``integrity_lines``."""

    return "\n".join((kickoff(rows=rows), "## Integrity", *integrity_lines))


@pytest.mark.parametrize(
    ("old", "new", "expected"),
    [
        ("| 101 |", "| bad |", "issue_num"),
        ("| 0 |", "| bad |", "cohort"),
        ("| C3 |", "| C9 |", "complexity"),
    ],
)
def test_invalid_item_cells_report_their_owned_error(
    old: str, new: str, expected: str
) -> None:
    """Invalid numeric and enum cells produce row-scoped diagnostics."""

    errors = validate_parallel_kickoff_text(
        kickoff(rows=(ITEM_ROW_101.replace(old, new),))
    )
    assert any(expected in error for error in errors)


def test_item_headers_are_the_six_ordered_parallel_columns() -> None:
    """The item table contract has six ordered columns and no wave column."""

    # Arrange / Act
    headers = ITEM_HEADERS

    # Assert
    assert headers == (
        "issue_num",
        "feature_folder",
        "cohort",
        "complexity",
        "branch",
        "plan-path",
    )


def test_valid_kickoff_with_integrity_validates_without_errors() -> None:
    """A fully valid document with every section produces zero errors."""

    # Arrange
    document = kickoff_with_integrity(rows=(ITEM_ROW_101, ITEM_ROW_202))

    # Act
    errors = validate_parallel_kickoff_text(document)

    # Assert
    assert errors == []


def test_valid_kickoff_with_integrity_parses_expected_structure() -> None:
    """A fully valid multi-row document parses into the expected structure."""

    # Arrange
    document = kickoff_with_integrity(rows=(ITEM_ROW_101, ITEM_ROW_202))

    # Act
    parsed, errors = parse_parallel_kickoff(document)

    # Assert
    assert errors == []
    assert parsed is not None
    assert parsed.slug == "sample-run"
    assert parsed.invocation_slug == "sample-run"
    assert parsed.manifest_path == "docs/features/parallel/sample-run/parallel.md"
    assert parsed.plan_home_branch == "parallel/sample-run-plan"
    assert parsed.planning_commit == "e" * 40
    assert parsed.plan_hashes == {
        "docs/features/active/item-101/plan.md": HASH_40,
    }
    assert tuple(item.issue_num for item in parsed.items) == (101, 202)


def test_valid_kickoff_without_integrity_validates_without_errors() -> None:
    """The `## Integrity` section is optional and its absence is not an error."""

    # Arrange
    document = kickoff()

    # Act
    errors = validate_parallel_kickoff_text(document)

    # Assert
    assert errors == []


def test_absent_integrity_section_leaves_commit_and_hashes_empty() -> None:
    """A document without `## Integrity` parses with no commit and no hashes."""

    # Arrange
    document = kickoff()

    # Act
    parsed, _ = parse_parallel_kickoff(document)

    # Assert
    assert parsed is not None
    assert parsed.planning_commit is None
    assert parsed.plan_hashes == {}


def test_each_item_column_round_trips_into_its_kickoff_item_field() -> None:
    """All six declared cells map onto the corresponding `KickoffItem` field."""

    # Arrange
    document = kickoff()

    # Act
    parsed, _ = parse_parallel_kickoff(document)

    # Assert
    assert parsed is not None
    assert parsed.items == (
        KickoffItem(
            issue_num=101,
            feature_folder="docs/features/active/item-101",
            cohort=0,
            complexity="C3",
            branch="feature/item-101",
            plan_path="docs/features/active/item-101/plan.md",
        ),
    )


@pytest.mark.parametrize("band", ["C1", "C2", "C3", "C4"])
def test_every_complexity_band_is_accepted(band: str) -> None:
    """Each of C1 through C4 is a valid complexity cell."""

    # Arrange
    document = kickoff(rows=(ITEM_ROW_101.replace("| C3 |", f"| {band} |"),))

    # Act
    errors = validate_parallel_kickoff_text(document)

    # Assert
    assert errors == []


@pytest.mark.parametrize("plan_hash", [HASH_40, HASH_64])
def test_boundary_length_plan_hashes_are_accepted(plan_hash: str) -> None:
    """Both the 40-hex and the 64-hex boundary hash lengths are accepted."""

    # Arrange
    document = kickoff_with_integrity(
        integrity_lines=(
            "| plan-path | plan-hash |",
            "| --- | --- |",
            f"| docs/features/active/item-101/plan.md | {plan_hash} |",
        )
    )

    # Act
    parsed, errors = parse_parallel_kickoff(document)

    # Assert
    assert errors == []
    assert parsed is not None
    assert parsed.plan_hashes == {
        "docs/features/active/item-101/plan.md": plan_hash,
    }


@pytest.mark.parametrize(
    "hash_header", ["plan-hash", "plan_hash", "git-blob-sha", "git_blob_sha"]
)
def test_every_accepted_integrity_hash_header_is_allowed(hash_header: str) -> None:
    """All four recognised hash-column headers satisfy the integrity contract."""

    # Arrange
    document = kickoff_with_integrity(
        integrity_lines=(
            f"| plan-path | {hash_header} |",
            "| --- | --- |",
            f"| docs/features/active/item-101/plan.md | {HASH_40} |",
        )
    )

    # Act
    errors = validate_parallel_kickoff_text(document)

    # Assert
    assert errors == []


def test_integrity_commit_is_lowercased_and_short_form_is_accepted() -> None:
    """An abbreviated uppercase commit is accepted and normalised to lowercase."""

    # Arrange
    document = kickoff_with_integrity(integrity_lines=("- planning_commit: `ABCDEF1`",))

    # Act
    parsed, errors = parse_parallel_kickoff(document)

    # Assert
    assert errors == []
    assert parsed is not None
    assert parsed.planning_commit == "abcdef1"


def test_blank_lines_inside_the_integrity_section_are_ignored() -> None:
    """Blank integrity lines are skipped rather than reported as invalid."""

    # Arrange
    document = kickoff_with_integrity(
        integrity_lines=("", f"planning_commit: {'f' * 40}", "")
    )

    # Act
    errors = validate_parallel_kickoff_text(document)

    # Assert
    assert errors == []


def test_empty_text_is_rejected_as_empty() -> None:
    """An empty document produces exactly the empty-kickoff error."""

    # Arrange
    document = ""

    # Act
    errors = validate_parallel_kickoff_text(document)

    # Assert
    assert errors == ["Parallel kickoff is empty."]


def test_non_heading_first_line_is_rejected() -> None:
    """A first line that is not the kickoff heading is rejected outright."""

    # Arrange
    document = "not a heading"

    # Act
    errors = validate_parallel_kickoff_text(document)

    # Assert
    assert errors == [
        "Parallel kickoff first line must match '# Parallel Kickoff: <slug>'."
    ]


def test_slug_outside_the_allowed_pattern_is_rejected() -> None:
    """A slug with uppercase and underscore characters violates the heading pattern."""

    # Arrange
    document = kickoff().replace(
        "# Parallel Kickoff: sample-run", "# Parallel Kickoff: Sample_Run"
    )

    # Act
    errors = validate_parallel_kickoff_text(document)

    # Assert
    assert errors == [
        "Parallel kickoff first line must match '# Parallel Kickoff: <slug>'."
    ]


def test_missing_invocation_prompt_section_is_reported() -> None:
    """Removing the `## Invocation Prompt` heading reports the missing section."""

    # Arrange
    document = kickoff().replace("## Invocation Prompt\n", "")

    # Act
    errors = validate_parallel_kickoff_text(document)

    # Assert
    assert (
        "Parallel kickoff is missing required section: ## Invocation Prompt" in errors
    )


def test_missing_item_summary_section_is_reported() -> None:
    """Removing the `## Item Summary` heading reports the missing section."""

    # Arrange
    document = kickoff().replace("## Item Summary\n", "")

    # Act
    errors = validate_parallel_kickoff_text(document)

    # Assert
    assert "Parallel kickoff is missing required section: ## Item Summary" in errors


def test_duplicate_level_two_heading_is_reported() -> None:
    """A repeated level-two heading is rejected rather than merged."""

    # Arrange
    document = kickoff().replace("## Item Summary", "## Invocation Prompt")

    # Act
    errors = validate_parallel_kickoff_text(document)

    # Assert
    assert "Parallel kickoff contains duplicate section: ## Invocation Prompt" in errors


def test_invocation_without_the_parallel_run_call_is_reported() -> None:
    """An invocation prompt lacking the `/parallel-run` call is rejected."""

    # Arrange
    document = kickoff().replace(
        "Run `/parallel-run sample-run` to execute this parallel run.",
        "Execute this parallel run.",
    )

    # Act
    errors = validate_parallel_kickoff_text(document)

    # Assert
    assert (
        "Parallel kickoff invocation must contain `Run /parallel-run <slug>`." in errors
    )


def test_invocation_without_the_manifest_path_is_reported() -> None:
    """An invocation prompt lacking the run manifest path is rejected."""

    # Arrange
    document = kickoff().replace(
        "docs/features/parallel/sample-run/parallel.md", "the run manifest"
    )

    # Act
    errors = validate_parallel_kickoff_text(document)

    # Assert
    assert (
        "Parallel kickoff invocation must structurally name the manifest, "
        "plan-home branch, and atomic-execution resume boundary." in errors
    )


def test_invocation_without_the_plan_home_branch_is_reported() -> None:
    """An invocation prompt lacking the `parallel/<slug>-plan` branch is rejected."""

    # Arrange
    document = kickoff().replace("parallel/sample-run-plan", "some-other-branch")

    # Act
    errors = validate_parallel_kickoff_text(document)

    # Assert
    assert (
        "Parallel kickoff invocation must structurally name the manifest, "
        "plan-home branch, and atomic-execution resume boundary." in errors
    )


def test_invocation_without_the_resume_boundary_sentence_is_reported() -> None:
    """An invocation prompt lacking the per-item resume boundary is rejected."""

    # Arrange
    document = kickoff().replace(
        "items resume at atomic execution from their committed plan-path on\n"
        "their own pushed feature branch rather than re-planning.",
        "start the run.",
    )

    # Act
    errors = validate_parallel_kickoff_text(document)

    # Assert
    assert (
        "Parallel kickoff invocation must structurally name the manifest, "
        "plan-home branch, and atomic-execution resume boundary." in errors
    )


def test_committed_readiness_accepts_version_one_identity() -> None:
    """The explicit gate accepts consistent committed kickoff provenance."""

    assert not validate_parallel_kickoff_text(
        kickoff_with_integrity(), require_ready_for_execution=True
    )


def test_committed_readiness_requires_planning_commit() -> None:
    """The explicit gate rejects a structurally valid uncommitted kickoff."""

    errors = validate_parallel_kickoff_text(kickoff(), require_ready_for_execution=True)
    assert (
        "Parallel kickoff readiness requires version-1 committed "
        "planning_commit identity." in errors
    )


def test_committed_readiness_rejects_cross_wired_slug() -> None:
    """Heading and invocation identities cannot select different runs."""

    document = kickoff_with_integrity().replace(
        "Run `/parallel-run sample-run`", "Run `/parallel-run other-run`"
    )
    errors = validate_parallel_kickoff_text(document, require_ready_for_execution=True)
    assert any("heading and invocation slugs" in error for error in errors)


def test_committed_readiness_rejects_cross_wired_paths() -> None:
    """Manifest and branch identities must derive from the heading slug."""

    replacements = (
        ("/sample-run/parallel.md", "/other-run/parallel.md", "manifest must be"),
        ("sample-run-plan", "other-run-plan", "plan-home branch must be"),
    )
    for old, new, expected in replacements:
        errors = validate_parallel_kickoff_text(
            kickoff_with_integrity().replace(old, new), require_ready_for_execution=True
        )
        assert any(expected in error for error in errors)
