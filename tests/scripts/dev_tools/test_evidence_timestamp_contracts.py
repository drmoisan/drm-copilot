"""Documentation contracts for the issue #903 UTC write-time evidence stamps.

Pins the text that issue #903 adds to the three evidence-and-timestamp-conventions
skills (the UTC ``Timestamp`` source and the ``### Evidence Filename Timestamp``
subsection) and to the three atomic-plan-contract skills (the ``## Evidence
Filename Timestamps in Plans`` section), and asserts that each atomic-plan-contract
copy is byte-identical to its bundled extension mirror.

This module reads committed repository files only. It creates no file, spawns
no process, and performs no network access. Every content assertion extracts
the named ``##`` section first, collapses whitespace, and checks each required
fragment as a substring so a failure names the missing fragment.
"""

from __future__ import annotations

from pathlib import Path

import pytest

from tests.scripts.dev_tools.parallel_orchestrator_surface_test_support import (
    REPO_ROOT,
    collapse_whitespace,
    extract_section,
    read_repo_text,
)

EVIDENCE_SKILLS: tuple[tuple[str, Path], ...] = (
    ("claude", Path(".claude/skills/evidence-and-timestamp-conventions/SKILL.md")),
    ("agents", Path(".agents/skills/evidence-and-timestamp-conventions/SKILL.md")),
    ("github", Path(".github/skills/evidence-and-timestamp-conventions/SKILL.md")),
)

PLAN_CONTRACT_SKILLS: tuple[tuple[str, Path], ...] = (
    ("claude", Path(".claude/skills/atomic-plan-contract/SKILL.md")),
    ("agents", Path(".agents/skills/atomic-plan-contract/SKILL.md")),
    ("github", Path(".github/skills/atomic-plan-contract/SKILL.md")),
)

_CLAUDE_BUNDLE = Path("extensions/drm-copilot/resources/claude-customizations")
_CODEX_BUNDLE = Path("extensions/drm-copilot/resources/codex-and-agents-customizations")
_GITHUB_BUNDLE = Path("extensions/drm-copilot/resources/customizations")

# Each root atomic-plan-contract copy paired with its bundled extension mirror.
PLAN_CONTRACT_MIRROR_PAIRS: tuple[tuple[str, tuple[Path, Path]], ...] = (
    (
        "claude",
        (PLAN_CONTRACT_SKILLS[0][1], _CLAUDE_BUNDLE / PLAN_CONTRACT_SKILLS[0][1]),
    ),
    (
        "agents",
        (PLAN_CONTRACT_SKILLS[1][1], _CODEX_BUNDLE / PLAN_CONTRACT_SKILLS[1][1]),
    ),
    (
        "github",
        (PLAN_CONTRACT_SKILLS[2][1], _GITHUB_BUNDLE / PLAN_CONTRACT_SKILLS[2][1]),
    ),
)

TIMESTAMP_HEADING = "## ISO-8601 Timestamp Format"
PLAN_STAMP_HEADING = "## Evidence Filename Timestamps in Plans"


def _section(relative_path: Path, heading: str) -> str:
    """Return the whitespace-collapsed body of one ``##`` section.

    Args:
        relative_path: Repo-root-relative document path.
        heading: Exact ``##`` heading line that opens the section.

    Returns:
        The section body with every whitespace run collapsed to one space.

    Raises:
        ValueError: If the heading is absent from the document.

    Side Effects:
        Reads the document from the filesystem.
    """
    return collapse_whitespace(extract_section(read_repo_text(relative_path), heading))


def _assert_fragments_present(
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
    section = _section(relative_path, heading)
    for fragment in fragments:
        assert (
            fragment in section
        ), f"{relative_path.as_posix()} {heading} is missing required text: {fragment}"


@pytest.mark.parametrize(
    "skill_path",
    [path for _, path in EVIDENCE_SKILLS],
    ids=[skill_id for skill_id, _ in EVIDENCE_SKILLS],
)
def test_evidence_skill_states_utc_timestamp_source(skill_path: Path) -> None:
    """Each evidence skill states that `Timestamp` is UTC from the host clock."""
    # Arrange
    fragments = (
        "The `Timestamp` value is UTC read from the host system clock",
        "`Get-Date -AsUTC -Format yyyy-MM-ddTHH-mm`",
        "`(Get-Date).ToUniversalTime().ToString('yyyy-MM-ddTHH-mm')`",
        "`date -u +%Y-%m-%dT%H-%M`",
        "The value is written without a zone suffix.",
    )

    # Act / Assert
    _assert_fragments_present(skill_path, TIMESTAMP_HEADING, fragments)


@pytest.mark.parametrize(
    "skill_path",
    [path for _, path in EVIDENCE_SKILLS],
    ids=[skill_id for skill_id, _ in EVIDENCE_SKILLS],
)
def test_evidence_skill_omits_local_time_wording(skill_path: Path) -> None:
    """Each evidence skill no longer describes `Timestamp` as local time."""
    # Arrange
    forbidden = "local time"

    # Act
    section = _section(skill_path, TIMESTAMP_HEADING)

    # Assert
    assert forbidden not in section, (
        f"{skill_path.as_posix()} {TIMESTAMP_HEADING} still contains forbidden"
        f" text: {forbidden}"
    )


@pytest.mark.parametrize(
    "skill_path",
    [path for _, path in EVIDENCE_SKILLS],
    ids=[skill_id for skill_id, _ in EVIDENCE_SKILLS],
)
def test_evidence_skill_requires_write_time_filename_stamp(skill_path: Path) -> None:
    """Each evidence skill requires a UTC write-time stamp in evidence filenames."""
    # Arrange
    fragments = (
        "### Evidence Filename Timestamp",
        "is the UTC time at which that file is written",
        "It is never a plan-time stamp",
        "Plans name such an artifact `<name>.<timestamp>.md`",
        "selects the lexicographically greatest file matching `<name>.*.md`",
        "Plan files (`plan.<timestamp>.md`, stamped by the feature-folder tooling"
        " in America/New_York)",
        "the review artifact set (`policy-audit`, `code-review`, `feature-audit`,"
        " `remediation-inputs`, which share one stamp) are outside this rule",
        "Existing evidence files whose names carry a plan-time stamp are not"
        " renamed.",
    )

    # Act / Assert
    _assert_fragments_present(skill_path, TIMESTAMP_HEADING, fragments)


@pytest.mark.parametrize(
    "skill_path",
    [path for _, path in PLAN_CONTRACT_SKILLS],
    ids=[skill_id for skill_id, _ in PLAN_CONTRACT_SKILLS],
)
def test_atomic_plan_contract_forbids_plan_time_evidence_stamp(
    skill_path: Path,
) -> None:
    """Each atomic-plan-contract copy forbids plan-time evidence filename stamps."""
    # Arrange
    fragments = (
        "Plans name evidence artifacts `<name>.<timestamp>.md` and never fix a"
        " plan-time stamp in an evidence filename.",
        "identifies a consumed evidence artifact by the derivation in"
        " `evidence-and-timestamp-conventions`",
        "the lexicographically greatest file matching `<name>.*.md`, not a"
        " pre-stamped literal path",
        "asserted search tokens remain concrete",
    )

    # Act / Assert
    _assert_fragments_present(skill_path, PLAN_STAMP_HEADING, fragments)


@pytest.mark.parametrize(
    ("source", "mirror"),
    [pair for _, pair in PLAN_CONTRACT_MIRROR_PAIRS],
    ids=[pair_id for pair_id, _ in PLAN_CONTRACT_MIRROR_PAIRS],
)
def test_atomic_plan_contract_matches_bundled_mirror(
    source: Path, mirror: Path
) -> None:
    """Each atomic-plan-contract copy is byte-identical to its bundled mirror."""
    # Arrange / Act
    source_bytes = (REPO_ROOT / source).read_bytes()
    mirror_bytes = (REPO_ROOT / mirror).read_bytes()

    # Assert
    assert (
        source_bytes == mirror_bytes
    ), f"{source.as_posix()} differs from its mirror {mirror.as_posix()}"
