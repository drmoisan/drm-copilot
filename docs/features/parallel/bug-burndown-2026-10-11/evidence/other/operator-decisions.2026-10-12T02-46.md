# Operator Decisions and Run Directives: bug-burndown-2026-10-11

Timestamp: 2026-10-12T02:46Z
Recorded by: parallel-orchestrator (from the /parallel-run invocation and coordinator messages)

## Approvals

- #890: APPROVED adding the `mutate-parallel-run.sh` allow entry to `.claude/settings.json` and its
  bundled copy (#791 precedent).
- #886: APPROVED correcting `.claude/rules/orchestrator-state.md` line 204 and its bundled copy so it
  describes inserting the repository root first.
- #884: the PR must say "Refs #884" and must not close the issue (bash half only).
- #903: this run's #903 item closes #903. Epic E2 references #903 without closing it; the operator
  informs the epic.

## Execution Rules

- One cohort of 16 items. Every derived edge is tolerated under the operator cost-benefit conflict
  policy. When a later item conflicts, it merges origin/main (no rebase), resolves, re-tests, and
  pushes.
- main accepts only up-to-date branches: merge one PR at a time and re-sync the others.
- Green means every check on the PR head passes (positive assertion), not only the required checks.
- Throttling: on THROTTLE DOWN, commit and hold new starts; never stop running work. Treat brief
  errors and credential changes as transient and retry.
- PowerShell and bats verification: Option A (MCP tools plus CI evidence).
- Supply CI run IDs and head SHAs to the children that need them: #884, #887, #895, #899, #901,
  #903.
- Session-root workarounds for PR creation and standalone-merge authorization still apply if a gate
  denies.
- Unique scratch file names per child (prefix with the issue number).
- Commit and push at every phase boundary. Never force-push. Delete nothing.

## Coordinator HOLD (received 2026-10-12T02:4xZ)

- Do not launch any item child until the coordinator sends GO. Only one usable account remains, and
  the epic run holds the single active slot.
- After GO: one item at a time, with at most 3 agents in its subtree. Start the next item only after
  the previous item's PR has merged or is waiting on CI, unless the limit is raised.
- Launch order (smallest first): #892, #543, #885, #886, #898, #894, #884, #895, then the rest
  (#887, #889, #890, #899, #900, #901, #902, #903).

## End-of-Run Follow-Up List (from the planner)

- #887: poetry install follow-up.
- #899: `scripts/dev-tools/Invoke-FullReleaseFlow.ps1` still polls with `--required`.
- #903: npm-token item / #846 CR-6.
- #900: plan-validator check rejecting bare SCRATCH paths (needs a
  `.claude/rules/plan-acceptance-gates.md` edit and operator approval).
