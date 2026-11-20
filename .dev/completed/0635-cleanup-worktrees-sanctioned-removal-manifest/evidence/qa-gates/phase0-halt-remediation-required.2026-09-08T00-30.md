# Phase 0 Halt Record — Superseded And Resolved

Timestamp: 2026-09-08T02-15

Task: [P0-T7]

Command: `mcp__drm-copilot__run_poshqc_test` with
`workspace_root=C:/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-a5a6952a0a1e65c6e`

EXIT_CODE: 2

ExpectedExitCode: 2

The expectation field is declared because
`scripts/dev_tools/pr_context/verification_evidence.py:25` collects `evidence/qa-gates/**/*.md` into
the PR body and defaults a missing expectation to `0`. Without it this artifact would render as a
failed gate on a run whose gates passed. The observed code of 2 is the steady-state local failed
count described below, and it equals the declared expectation, so the gate normalizes to a pass.

## What this artifact recorded, and what superseded it

The version of this file written at 2026-09-08T00-30 recorded a two-failure local baseline as a
blocking precondition, on the reading that later suite gates in the plan demanded an absolute-zero
failed count. Both of those readings are superseded.

The resolution is the **Known-Local-Red Inventory** in the plan's `PowerShell Toolchain Order`
preamble. That preamble now carries a closed, two-member inventory naming both failing nodes, and
every local full-suite gate in the plan is stated against that inventory rather than against an
absolute zero: the observed failing set must be a subset of the two named nodes and no other test
may fail. [P0-T7] declares `ExpectedExitCode: 2` on the same basis, [P1-T8] declares
`ExpectedExitCode: 2`, and [P2-T4] declares `ExpectedExitCode: 4` — the two inventory members plus
the two deliberately failing tests that phase adds.

The resolution was reached by adopting the inventory, not by clearing the two failures. Both nodes
still fail locally on the run recorded in
`evidence/baseline/poshqc-coverage-baseline.2026-09-06T23-09.md`, and the plan's gates are written to
expect exactly that.

## The mechanism behind both failures

Both are produced by this run's own orchestration checkpoint at
`artifacts/orchestration/orchestrator-state.json`, which carries `epic_mode` set true, read by two
hooks through a seam their suites do not mock.

1. `tests/scripts/claude-hooks/enforce-pr-author-skill.Tests.ps1`, node
   `enforce-pr-author-skill.ps1` > `allowed commands` >
   `allows gh pr create --body-file artifacts/pr_body_12.md when context exists`.
   `.claude/hooks/enforce-pr-author-skill.epic-base-branch.ps1:90-111` reads that checkpoint from
   disk, sees `epic_mode` true, and denies with `EPIC_BASE_BRANCH_MISMATCH` because the test's
   command text carries no `--base`. Observed `deny` where the test expects `allow`, at line 145.
2. `tests/scripts/codex-hooks/codex-pretooluse-integration.Tests.ps1`, node
   `Every registered Codex PreToolUse handler accepts every tool name its matcher admits` >
   `allows every registered handler for every tool name its own matcher admits`.
   `.codex/hooks/enforce-epic-wave-barrier.ps1:218-220` and `:259` read the same file, see
   `epic_mode` true, resolve the feature key, and deny with `EPIC_WAVE_BARRIER_BLOCKED` because the
   epic checkpoint in the primary worktree does not record this child's `depends_on` edge as merged
   or worktree-removed. Observed at line 165.

## Why the canonical environment is unaffected

`/artifacts` is gitignored (`.gitignore:6`), so no such checkpoint exists on a CI runner. The
`workflow_dispatch` of `.github/workflows/_poshqc.yml` against head
`d250cf72ee24139735e7f08b07d002ae0e4f1d00`, run id `34186767775`, returned conclusion `success` with
the Format PowerShell, Analyze PowerShell, and Test PowerShell steps all `success`, and its
`pester-junit.xml` root element reports `tests="4363" errors="0" failures="0" disabled="9"` — the same
4363 tests, with zero failures. The baseline is clean in the canonical environment and is perturbed
locally by the mechanism named above.

## Gate-by-gate status under the inventory

- [P1-T8] quotes a requirement written as `EXIT_CODE` equal to 0 in an earlier plan revision. It now
  declares `ExpectedExitCode: 2` and is stated against the inventory, so it is satisfiable.
- [P2-T4] declares `ExpectedExitCode: 4`, derived as the two inventory members plus the two
  deliberately failing tests added by [P2-T2] and [P2-T3]. It is satisfiable.
- [P3-T8] and [P3-T9] read per-suite counts rather than a repository-wide zero and were never
  affected.
- Every other local full-suite gate in the plan is stated against the same inventory.

A third failing node, or any failing node whose name is not one of the two, still fails the
applicable gate. The inventory is closed at exactly two members and admits no third.

Output Summary: **RESOLVED — this halt record is superseded.** The two-failure local baseline that
produced it is now accounted for by the closed two-member Known-Local-Red Inventory in the plan's
toolchain preamble, which every local full-suite gate in the plan is stated against. Both failures
are caused by this run's own `epic_mode` orchestration checkpoint under gitignored `artifacts/`,
read by two hooks through a seam their suites do not mock; the same 4363 tests report zero failures
on CI run `34186767775` at head `d250cf72ee24139735e7f08b07d002ae0e4f1d00`. The observed local exit
code of 2 equals this artifact's declared expectation, so the gate normalizes to a pass. Execution
continues into Phase 1.
