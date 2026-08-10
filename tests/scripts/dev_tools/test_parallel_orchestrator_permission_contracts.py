"""Permission-seam contract tests for the parallel-orchestrator surface (#441).

Purpose:
    Close the gap class in which the delivered persona's ``tools`` allowlist and
    the delivered procedure's prescriptions disagree. The persona allowlist is
    the PRODUCER of permissions and the procedure skill is the CONSUMER that
    prescribes actions requiring them. Both sides are parsed from the delivered
    files at run time, so no test restates the grant set and no test restates the
    prescribed-action set.

Flow:
    One test binds every prescribed parent write target to a ``Write(...)``
    grant, one binds every prescribed command invocation to a ``Bash(...)``
    grant, and one regression-locks the manifest-validation gate specifically by
    requiring the section that names the validation library symbol to prescribe
    at least one granted invocation.

Invariants and constraints:
    A one-sided narrowing of the allowlist and a one-sided addition to the
    procedure both change a parsed result and fail here, which independent
    per-side assertions cannot detect. Each test carries a cardinality floor so a
    degenerate parse that returns nothing cannot pass silently. All checks are
    deterministic: no temporary file, no external process, no network.
"""

from __future__ import annotations

from tests.scripts.dev_tools.parallel_orchestrator_permission_seam_support import (
    bash_grant_covers,
    persona_bash_grants,
    persona_write_grants,
    prescribed_command_invocations,
    prescribed_parent_write_targets,
    write_grant_covers,
)
from tests.scripts.dev_tools.parallel_orchestrator_surface_test_support import (
    ORCHESTRATE_SKILL_RELATIVE,
    collapse_whitespace,
    extract_section,
    read_repo_text,
    split_frontmatter,
    top_level_headings,
)

# The manifest-validation gate section is located by the library symbol it names
# rather than by a heading constant copied from the producer, so renaming the
# section does not silently disable the regression lock on that gate.
MANIFEST_VALIDATION_SYMBOL = "validate_parallel_manifest_text"

# Floors that stop a degenerate parse from satisfying a universally-quantified
# assertion over an empty set. The write floor is two because the corrected
# procedure prescribes exactly two parent write destinations; the command floor
# is eight, comfortably below the number of ``git`` and ``gh`` invocations the
# procedure already prescribes.
MINIMUM_PRESCRIBED_WRITE_TARGETS = 2
MINIMUM_PRESCRIBED_COMMAND_INVOCATIONS = 8


def test_every_prescribed_parent_write_target_has_a_persona_write_grant() -> None:
    """Require a ``Write`` grant for every write target the procedure prescribes."""

    # Arrange
    grants = persona_write_grants()
    targets = prescribed_parent_write_targets()

    # Act
    uncovered = tuple(
        target
        for target in targets
        if not any(write_grant_covers(grant, target) for grant in grants)
    )

    # Assert
    assert len(targets) >= MINIMUM_PRESCRIBED_WRITE_TARGETS, (
        "the parallel-orchestrate procedure must prescribe at least "
        f"{MINIMUM_PRESCRIBED_WRITE_TARGETS} parent write targets; parsed "
        f"{len(targets)}: {targets}"
    )
    assert not uncovered, (
        "the parallel-orchestrate procedure prescribes a parent write to a "
        f"target no parallel-orchestrator Write grant covers: {uncovered}. "
        f"Declared Write grants are {grants}. Every parsed target was {targets}."
    )


def test_every_prescribed_command_invocation_has_a_persona_bash_grant() -> None:
    """Require a ``Bash`` grant for every command the procedure prescribes."""

    # Arrange
    grants = persona_bash_grants()
    invocations = prescribed_command_invocations()

    # Act
    uncovered = tuple(
        invocation
        for invocation in invocations
        if not any(bash_grant_covers(grant, invocation) for grant in grants)
    )

    # Assert
    assert len(invocations) >= MINIMUM_PRESCRIBED_COMMAND_INVOCATIONS, (
        "the parallel-orchestrate procedure must prescribe at least "
        f"{MINIMUM_PRESCRIBED_COMMAND_INVOCATIONS} command invocations; parsed "
        f"{len(invocations)}: {invocations}"
    )
    assert not uncovered, (
        "the parallel-orchestrate procedure prescribes a command invocation no "
        f"parallel-orchestrator Bash grant covers: {uncovered}. Declared Bash "
        f"grants are {grants}. Every parsed invocation was {invocations}."
    )


def test_manifest_validation_gate_prescribes_a_granted_command_invocation() -> None:
    """Require the manifest-validation gate to name a mechanism the persona holds.

    The gate makes a malformed manifest a hard rejection before any kickoff, so a
    section that states the obligation without naming an invocation the persona is
    granted leaves the gate documented but unenforceable.
    """

    # Arrange — locate the gate section by the symbol it names, then intersect the
    # procedure's granted invocations with the spans that section carries.
    _, body = split_frontmatter(read_repo_text(ORCHESTRATE_SKILL_RELATIVE))
    naming_sections = [
        extract_section(body, heading)
        for heading in top_level_headings(body)
        if MANIFEST_VALIDATION_SYMBOL in extract_section(body, heading)
    ]
    grants = persona_bash_grants()
    invocations = prescribed_command_invocations()

    # Act
    assert len(naming_sections) == 1, (
        f"exactly one section of {ORCHESTRATE_SKILL_RELATIVE} must name "
        f"{MANIFEST_VALIDATION_SYMBOL}; found {len(naming_sections)}"
    )
    section = collapse_whitespace(naming_sections[0])
    granted_in_section = tuple(
        invocation
        for invocation in invocations
        if f"`{invocation}`" in section
        and any(bash_grant_covers(grant, invocation) for grant in grants)
    )

    # Assert
    assert granted_in_section, (
        f"the {ORCHESTRATE_SKILL_RELATIVE} section that names "
        f"{MANIFEST_VALIDATION_SYMBOL} prescribes no command invocation covered "
        f"by a parallel-orchestrator Bash grant, so the manifest gate it makes a "
        f"precondition of any kickoff has no permitted mechanism. Declared Bash "
        f"grants are {grants}."
    )
