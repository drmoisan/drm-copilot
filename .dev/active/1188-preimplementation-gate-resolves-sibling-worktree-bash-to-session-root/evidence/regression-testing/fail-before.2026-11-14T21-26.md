# Fail-before proof (P1-T3)

Timestamp: 2026-11-14T21-24
Command: sh .claude/skills/test-execution-policy/scripts/run-test-suite.sh pester -TestPath tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-operands.Tests.ps1 tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-operands.Tests.ps1
EXIT_CODE: 1
ExpectedExitCode: 1
Output Summary: run against the unmodified hooks (no sibling file exists and neither epic-scope file is edited). Invoke-PoshQCParallelTest, 2 workers, 107.1 s, exit code 1. Per surface: 128 failed, 6 passed. Per-shard JUnit read with SCRATCH/issue-1188-junit-cases.ps1.

## Rows that pass before the fix (controls, identical on both surfaces)

- `baseline mock interception probe`
- `N3 npx --prefix unclassified control` (stage 1 does not classify `npx --prefix <item> jest`; allow with zero checkpoint reads and zero listing calls)
- `R1 relative npm --prefix`, `R2 relative runner operand`, `R3 lone outside absolute path` (session-root checkpoint decides; the item checkpoint is never read)
- `I1 denies naming enforce-orchestration-preimplementation-gate-operands.ps1 when its dot-source failed`

## Rows that fail before the fix (both surfaces, identical lists)

- AC-1: `P1` (ready allow), `P2` (not ready deny), `P3` (absent deny), each for `poetry -C`, `--directory`, `--directory=`, and `-P`: all 12 fail. Before the fix the command resolves to the session root, so the ready item is denied and the not-ready or absent item is admitted against the ready session-root checkpoint.
- AC-2: `N1`, `N2`, `N4` fail.
- AC-3: `L1` (both launcher forms, ready) and `L2` (both forms, not ready) fail.
- AC-4: `W1` and `W2`, ready and not ready, fail.
- AC-5: `A1` ready and not ready fail.
- AC-6: `V1` to `V5` fail (admitted against the ready session-root checkpoint instead of denied as not derivable).
- AC-7: `M1`, `M2` fail. AC-9: `F1`, `F2` fail. AC-10 and decision rule 3: `U1` to `U5` fail.
- AC-11: all 89 G rows fail on each surface, because their Context BeforeAll dot-sources the missing `enforce-orchestration-preimplementation-gate-operands.ps1` ("This test should run but it did not").

Result: P1 to P3 (AC-1), L1 and L2 (AC-3), and V1 to V5 (AC-6) fail on both surfaces; U5 and every other row of the expected-failure set fail; R1 to R3, N3, and I1 pass. No named row passed before the fix.

Test adjustment made before this run (P1-T1 micro-action): the first task-check run showed `R3` failing only on its worktree-listing count (0 calls before the fix, because no operand reached the resolver). R3 is a control whose decision and read counts are unchanged by the fix, so its `ListingCalls` is recorded as -1 (unasserted) in the Cases table; every other row keeps an exact listing count. The same run exposed a test defect (the local `$decision` overwrote the case-insensitive row variable `$Decision`), fixed by renaming the local to `$gateResult` in both suites.
