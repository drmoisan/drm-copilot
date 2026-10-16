"""Permission-seam contract for the epic-orchestrator persona (issue #952).

Purpose:
    The ``epic-orchestrate`` procedure prescribes ``pwsh`` invocations of the
    CI-gate parser and the merge-confirmation parser, and the
    ``epic-orchestrator`` persona must hold a ``Bash(...)`` grant for each of
    them. Both sides are parsed from the delivered files at run time by the
    shared seam parsers, so neither the grant set nor the prescribed set is
    restated here.

Invariants and constraints:
    The test carries a cardinality floor so a degenerate parse that returns no
    invocation cannot pass. It reads committed files only: no temporary file,
    no external process, and no network access.
"""

from __future__ import annotations

from pathlib import Path

from tests.scripts.dev_tools.parallel_orchestrator_permission_seam_support import (
    bash_grant_covers,
    persona_bash_grants,
    prescribed_command_invocations,
)

EPIC_ORCHESTRATOR_AGENT = Path(".claude/agents/epic-orchestrator.md")
EPIC_ORCHESTRATE_SKILL = Path(".claude/skills/epic-orchestrate/SKILL.md")

# The procedure prescribes the CI-gate parser and the merge-confirmation parser.
MINIMUM_PRESCRIBED_PWSH_INVOCATIONS = 2


def test_every_prescribed_pwsh_invocation_has_an_epic_persona_bash_grant() -> None:
    """Require an epic persona ``Bash`` grant for every prescribed ``pwsh`` call."""

    # Arrange
    grants = persona_bash_grants(EPIC_ORCHESTRATOR_AGENT)
    invocations = tuple(
        invocation
        for invocation in prescribed_command_invocations(EPIC_ORCHESTRATE_SKILL)
        if invocation.split()[0] == "pwsh"
    )

    # Act
    uncovered = tuple(
        invocation
        for invocation in invocations
        if not any(bash_grant_covers(grant, invocation) for grant in grants)
    )

    # Assert
    assert len(invocations) >= MINIMUM_PRESCRIBED_PWSH_INVOCATIONS, (
        "the epic-orchestrate procedure must prescribe at least "
        f"{MINIMUM_PRESCRIBED_PWSH_INVOCATIONS} pwsh invocations; parsed "
        f"{len(invocations)}: {invocations}"
    )
    assert not uncovered, (
        "the epic-orchestrate procedure prescribes a pwsh invocation no "
        f"epic-orchestrator Bash grant covers: {uncovered}. Declared Bash grants "
        f"are {grants}."
    )
