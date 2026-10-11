# Remediation Cycle 2 Scoped Baseline of the Affected Suites ([P0-T12])

Timestamp: 2026-10-10T20-30
Command: sh <SCRATCHPAD>/r.sh rscoped -Path <six section 3 files> (R-SCOPED, one run, fresh PowerShell 7 process on the Windows host)
EXIT_CODE: 0
Output Summary: 167 passed, 0 failed (FailedBlocksCount 0, FailedContainersCount 0); six CONTAINER lines, each result=Passed: validate-feature-review-coverage 29, validate-codex-subagent-routing 17, enforce-codex-model-routing 14, enforce-epic-root-invocation 11, enforce-epic-wave-barrier 21, hook-dependency-failure.Codex 75. These passed= values are the per-container references of Phase 2.

PassedCount: 167
FailedCount: 0
FailedBlocksCount: 0
FailedContainersCount: 0

CONTAINER: tests/scripts/codex-hooks/validate-feature-review-coverage.Coverage.Tests.ps1 | result=Passed | passed=29 | failed=0
CONTAINER: tests/scripts/codex-hooks/validate-codex-subagent-routing.Coverage.Tests.ps1 | result=Passed | passed=17 | failed=0
CONTAINER: tests/scripts/codex-hooks/enforce-codex-model-routing.Coverage.Tests.ps1 | result=Passed | passed=14 | failed=0
CONTAINER: tests/scripts/codex-hooks/enforce-epic-root-invocation.Coverage.Tests.ps1 | result=Passed | passed=11 | failed=0
CONTAINER: tests/scripts/codex-hooks/enforce-epic-wave-barrier.Coverage.Tests.ps1 | result=Passed | passed=21 | failed=0
CONTAINER: tests/scripts/codex-hooks/hook-dependency-failure.Codex.Tests.ps1 | result=Passed | passed=75 | failed=0

Console summary: `Tests completed in 7.6s`; `Tests Passed: 167, Failed: 0, Skipped: 0, Inconclusive: 0, NotRun: 0`. The 167 `PASSED:` lines are retained in `<SCRATCHPAD>/rscoped.out` for this run.
