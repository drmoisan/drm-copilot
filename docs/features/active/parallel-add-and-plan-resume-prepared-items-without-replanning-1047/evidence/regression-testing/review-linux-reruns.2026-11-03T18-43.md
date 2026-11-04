# Feature Review Re-runs on Linux at the Branch Head (issue 1047)

Timestamp: 2026-11-03T18-43
Task: feature review (check-only re-runs)
Command: bats tests/shell/parallel_abandon_parity.bats tests/shell/parallel_cohorts_parity.bats tests/shell/parallel_lane_assertion_parity.bats tests/shell/parallel_manifest_parity.bats tests/shell/parallel_mutation_remove_parity.bats tests/shell/parallel_mutation_run_parity.bats; pwsh -NoProfile -NonInteractive -Command Invoke-Pester with Run.Path set to tests/scripts/claude-hooks/enforce-parallel-cohort-barrier.Tests.ps1 and tests/scripts/claude-lib/parallel-admission, CodeCoverage.Enabled false, TestResult.Enabled false
EXIT_CODE: 0
Output Summary: Run by the feature-review agent in the item worktree on branch head 793096c82 (Linux Codespace, Pester 5.9.1, bats at /usr/bin/bats). Bats parity: 23 tests (plan line 1..23), 23 ok, 0 not ok, 0 skipped. Pester: 242 tests, 242 passed, 0 failed, 0 skipped, 0 not run. No coverage was generated, and `git status --porcelain` showed no new tracked or untracked path after the runs.

## Pester containers

| Suite | Result | Passed/Total |
| --- | --- | --- |
| tests/scripts/claude-hooks/enforce-parallel-cohort-barrier.Tests.ps1 | Passed | 62/62 |
| tests/scripts/claude-lib/parallel-admission/Invoke-ParallelAdmission.Integration.Tests.ps1 | Passed | 11/11 |
| tests/scripts/claude-lib/parallel-admission/Invoke-ParallelAdmission.Tests.ps1 | Passed | 57/57 |
| tests/scripts/claude-lib/parallel-admission/ParallelAdmission.Manifest.Tests.ps1 | Passed | 5/5 |
| tests/scripts/claude-lib/parallel-admission/ParallelAdmission.Tests.ps1 | Passed | 56/56 |
| tests/scripts/claude-lib/parallel-admission/ParallelAdmissionPrecedence.Tests.ps1 | Passed | 51/51 |

## Scope note

These runs are local Linux evidence. They do not substitute for the CI job `poshqc / PowerShell hook suites (Linux)` that the spec criterion "Precedence rejection and barrier" names; that criterion remains pending CI and is owned by the item orchestrator at S9.
