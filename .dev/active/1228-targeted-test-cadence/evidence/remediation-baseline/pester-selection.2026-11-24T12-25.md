# Pre-Change Pester Selection Coverage - Remediation Cycle 2 ([P0-T3], RD5)

Timestamp: 2026-11-24T12-25
Plan: remediation-plan.2026-11-24T10-50.md
Command: `sh SCRATCH/issue-1228-sel.sh c2p0t3 SCRATCH/issue-1228-c2-p0t3.txt`, which runs `sh <item worktree>/.claude/skills/test-execution-policy/scripts/run-test-suite.sh pester -TestPath <the 20 files below>` at the item worktree root (launcher `pester` suite, `Invoke-PoshQCParallelTest` with coverage, parallel workers) and re-runs on exit 75; figures read by `pwsh -NoProfile -File SCRATCH/issue-1228-c2-perfile.ps1` from `artifacts/pester/pester-junit.xml` and `artifacts/pester/powershell-coverage.xml`
EXIT_CODE: 0
Output Summary:
- Run before any edit of this cycle. Attempts 1 to 12 (2026-11-24T12-01-38 to 12-19-56) exited 75 (queue timeout: the machine test-suite lock was held by suites of other worktrees); attempt 13 exited 0 (`Invoke-PoshQCParallelTest: workers=8; wall-clock=198.91s; exit code=0`). The exit-75 attempts are recorded as queue timeouts, not failures.
- JUnit (`artifacts/pester/pester-junit.xml`): 20 test suites, 1480 tests, 0 failures, 0 errors, 0 skipped.
- Coverage report written 2026-11-24T12:24:14Z. Per-file line coverage from the `<sourcefile>` LINE counters of `artifacts/pester/powershell-coverage.xml`:
  - `.claude/hooks/validate-feature-review-coverage.ps1`: 125 covered, 0 missed = 100.00%.
  - `.claude/hooks/validate-feature-review-coverage-freshness.ps1`: 48 covered, 1 missed = 97.96%.
  - `.codex/hooks/validate-feature-review-coverage.ps1`: 178 covered, 0 missed = 100.00%.
  - `.codex/hooks/validate-feature-review-coverage-freshness.ps1`: 48 covered, 1 missed = 97.96%.
  - `.claude/skills/test-execution-policy/scripts/Invoke-TestSuite.ps1`: 92 covered, 7 missed = 92.93%.
- These figures come from a selection run and are per-file evidence only; the report's LINE total (6035 covered, 43162 missed) covers the 20-file selection and is not a repository-wide figure. Repository-wide figures remain those of the `Phase 0 baseline` (`evidence/baseline/pester.2026-11-23T13-26.md`) and the main plan's final-QC artifacts.
- Report copies kept as SCRATCH/issue-1228-c2-p0t3-junit.xml and SCRATCH/issue-1228-c2-p0t3-coverage.xml for the [P1-T8] comparison.

## Selection and rule

Every existing test file under `tests/` whose text names `validate-feature-review-coverage` or `Invoke-TestSuite` (`git grep -l -e validate-feature-review-coverage -e Invoke-TestSuite -- 'tests/*.Tests.ps1'`), which covers every file that dot-sources or names one of the five files; the Python and bats files that name them (`tests/scripts/dev_tools/atomic_executor/test_qc_runner_expectations.py`, `tests/scripts/dev_tools/test_push_down_issue_824_follow_ups.py`, `tests/shell/test_run_test_suite.bats`) are not Pester files. The helper `validate-feature-review-coverage.E4.Helpers.ps1` is consumed only by `validate-feature-review-coverage.Coverage.Tests.ps1`, which is in the list.

- `tests/scripts/claude-hooks/enforce-test-execution-policy.Tests.ps1`
- `tests/scripts/claude-hooks/hook-dependency-failure.Claude.Tests.ps1`
- `tests/scripts/claude-hooks/hook-dependency-failure.SpecialCases.Tests.ps1`
- `tests/scripts/claude-hooks/subagentstop-uncaught-error.Tests.ps1`
- `tests/scripts/claude-hooks/test-execution-command-form.Tests.ps1`
- `tests/scripts/claude-hooks/validate-feature-review-coverage.Coverage.Tests.ps1`
- `tests/scripts/claude-hooks/validate-feature-review-coverage.Issue824.Tests.ps1`
- `tests/scripts/claude-hooks/validate-feature-review-coverage.TargetWorktree.Tests.ps1`
- `tests/scripts/claude-hooks/validate-feature-review-coverage.Tests.ps1`
- `tests/scripts/claude-hooks/validate-feature-review-coverage.ThresholdsGuard.Tests.ps1`
- `tests/scripts/claude-hooks/validate-feature-review-coverage-freshness.Tests.ps1`
- `tests/scripts/claude-skills/test-execution-policy/Invoke-TestSuite.Tests.ps1`
- `tests/scripts/codex-hooks/enforce-test-execution-policy.Tests.ps1`
- `tests/scripts/codex-hooks/feature-review-coverage-floor-parity.Tests.ps1`
- `tests/scripts/codex-hooks/feature-review-coverage-narrowing-parity.Tests.ps1`
- `tests/scripts/codex-hooks/hook-dependency-failure.Codex.Tests.ps1`
- `tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1`
- `tests/scripts/codex-hooks/validate-feature-review-coverage.Coverage.Tests.ps1`
- `tests/scripts/codex-hooks/validate-feature-review-coverage-freshness.Tests.ps1`
- `tests/scripts/workflows/VsCodeQualityTasks.Tests.ps1`
