# Remediation Baseline — Cycle 2 Parallel Pester Gate (Phase 0 baseline, Issue 1025)

Timestamp: 2026-11-17T04-48
Plan task: [P0-T2] of `remediation-plan.2026-11-16T06-14.md`
Command: `sh .claude/skills/test-execution-policy/scripts/run-test-suite.sh pester` (from the worktree root, through `sh SCRATCH/issue-1025-c2-gate.sh c2p0`, which re-runs only on exit 75; then `SCRATCH/issue-1025-pester-read.ps1` and `SCRATCH/issue-1025-junit-file.ps1` read the merged files)
EXIT_CODE: 0
Output Summary: Invoke-PoshQCParallelTest workers=8, wall-clock 825.23s, returned ExitCode 0 on attempt 1 (no queue timeout; run ended 2026-11-17T05-02). Merged `artifacts/pester/pester-junit.xml`: tests 27486, passed 27468, failures 0, errors 0, skipped 18. `tests/scripts/harness/HarnessParityMatrix.RepoGate.Tests.ps1`: 7 tests, 7 passed, 0 failed, 0 skipped. Coverage source: merged `artifacts/pester/powershell-coverage.xml` (run ExitCode 0). Repo-wide line coverage 96.07% (45203 covered, 1848 missed). Per-file line coverage: `scripts/harness/HarnessInventory.psm1` 100.00%, `scripts/harness/HarnessParityMatrix.psm1` 99.25%, `scripts/harness/HarnessSkillContract.psm1` 100.00%.

## Fields

| Field | Value |
| --- | --- |
| Tests | 27486 |
| Passed | 27468 |
| Failures | 0 |
| Errors | 0 |
| Skipped | 18 |
| Failing test files | none |
| RepoGate tests / passed / failed / skipped | 7 / 7 / 0 / 0 |
| Repo-wide line coverage | 96.07% |
| `scripts/harness/HarnessInventory.psm1` | 100.00% |
| `scripts/harness/HarnessParityMatrix.psm1` | 99.25% |
| `scripts/harness/HarnessSkillContract.psm1` | 100.00% |

RepoGate Its (all passed): schema declares Draft 2020-12 and the 1.0.0 id; schema enums required fields and conditional rules agree with the module rule set; committed matrix has no violation against the live inventory; every hook-registration permission and subagent-frontmatter-field entry has a parity_group; every shared codex skill has a conforming contract; matrix and schema files are UTF-8 without BOM with LF endings and two-space indentation; committed matrix passes Test-Json on PowerShell 7.4 or later.

Acceptance: numeric values for every field. PASS.
