# Preflight Round 2

- Timestamp: 2026-09-30T02-35
- Plan: docs/features/active/2026-09-08-epic-wave-barrier-violations-lack-start-guard-659/plan.2026-09-29T21-21.md (commit 50de1076)
- Reviewer: atomic-executor (DIRECTIVE: PREFLIGHT VALIDATION ONLY)
- Result: PREFLIGHT: REVISIONS REQUIRED
- Convergence: CONVERGENCE: NO FURTHER ROUNDS EXPECTED

## Round 1 Defects

D1 through D7 were verified as resolved.

## Defects Reported

- R2-1 (blocking): [P2-T17] uses `git diff --merge-base --stat origin/main`, whose non-terminal output abbreviates long paths (observed `.../issue.md`), so the path-membership acceptance cannot be evaluated. Replace with `--name-status` and update the acceptance sentence.
- R2-2 (non-blocking): [P2-T13], [P0-T13], and [P2-T8] allow a non-zero exit without recording `ExpectedExitCode:`; add the field for the allowed cases.

## Orchestrator Addition

- R2-3: the [P2-T17] scope check must admit every path under the feature folder (research, preflight records, evidence), because those files are committed on the branch and appear in a merge-base diff.

## Next Action

Revision delegated to atomic-planner; the same plan file is updated in place.
