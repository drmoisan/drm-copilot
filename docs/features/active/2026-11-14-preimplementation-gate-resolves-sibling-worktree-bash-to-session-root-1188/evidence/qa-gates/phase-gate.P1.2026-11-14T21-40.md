# Phase gate P1 (P1-T4)

Timestamp: 2026-11-14T21-26
Command: sh .claude/skills/test-execution-policy/scripts/run-test-suite.sh pester
EXIT_CODE: 1
ExpectedExitCode: 1
Output Summary: stages 1-6 on the Phase 1 tree. The Pester stage fails only on the named [expect-fail] rows: 256 failures, identical (sorted diff, no difference) to the fail-before set of evidence/regression-testing/fail-before.2026-11-14T21-26.md; every other test passes. pytest stage: 16928 passed, 6 skipped, 0 failed.

## Stages

| Stage | Command | EXIT_CODE | Result |
|---|---|---|---|
| 1 Format (check-only) | SCRATCH/issue-1188-static.ps1 (Invoke-Formatter compare, no write) over the three new test files | 0 | 0 changes (`Already formatted:` x3) |
| 2 Lint | Invoke-ScriptAnalyzer with scripts/powershell/PoshQC/settings/pssa.settings.psd1 (same script) | 0 | 0 findings |
| 2 Leak scan | Invoke-PoshQCLeakScan -Root <worktree> (same script) | 0 | 0 failures (839 files) |
| 3 Type check | not applicable to PowerShell | - | - |
| 4 Architecture boundary | not applicable (no TypeScript or C# in scope) | - | - |
| 5 Unit (Pester) | sh .claude/skills/test-execution-policy/scripts/run-test-suite.sh pester | 1 (expected) | 8 workers, 697.23 s; 26852 test cases in the shard JUnit files, 26516 passed, 256 failed; shards 2 and 4 hold the two new suites |
| 5 Unit (pytest) | env -u VIRTUAL_ENV sh .claude/skills/test-execution-policy/scripts/run-test-suite.sh pytest (via artifacts/scratch-issue-1188/issue-1188-pytest-gate.sh, started 2026-11-14T21-39) | 0 | 16928 passed, 6 skipped |
| 6 Contract | the push-down, pack-manifest, and brief contract suites inside the pytest stage | 0 | all pass |

## Expected failures (by row ID and surface)

Claude surface and Codex surface, identical lists (128 each):

- Gate rows: P1 (poetry -C, --directory, --directory=, -P), P2 (same four), P3 (same four), N1, N2, N4, L1 (sh launcher, env -u sh launcher), L2 (same two), W1 (ready, not ready), W2 (ready, not ready), A1 (ready, not ready), V1, V2, V3, V4, V5, M1, M2, F1, F2, U1, U2, U3, U4, U5.
- G rows: all 89 rows of `Get-OrchestrationGateCommandTargetOperand alone (G rows)`, failing because the sibling file does not exist yet (Context BeforeAll).

Each was confirmed failing in the shard JUnit files (read per container with SCRATCH/issue-1188-junit-cases.ps1). Passing controls on both surfaces: baseline mock interception probe, N3, R1, R2, R3, I1.
