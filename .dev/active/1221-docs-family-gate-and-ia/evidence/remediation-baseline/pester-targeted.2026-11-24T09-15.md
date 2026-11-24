# Remediation Baseline - Targeted Pester Union (cycle 1)

Plan: remediation-plan.2026-11-24T08-32.md
Task: [P0-T2]
Timestamp: 2026-11-24T09-15
Command: sh .claude/skills/test-execution-policy/scripts/run-test-suite.sh pester -TestPath tests/scripts/claude-lib/docs tests/scripts/claude-runtime/docs-authoring-roles.Skills.Tests.ps1 tests/scripts/harness/HarnessInventory.Tests.ps1 tests/scripts/claude-hooks/docs-estate-workflow.EndToEnd.Tests.ps1 tests/scripts/ci/FileSizePolicy.RepoGate.Tests.ps1 (absolute launcher path in the item worktree, run through the retry wrapper SCRATCH/issue-1221-retry.sh)
EXIT_CODE: 0
Output Summary:
- Invoke-PoshQCParallelTest: workers=8; wall-clock=326.97s; exit code=0; all eight shards exited 0; merged JUnit and coverage written.
- Pass/fail (artifacts/pester/pester-junit.xml): 2845 tests, 2845 passed, 0 failed, 0 errors, 0 skipped, 134 test suites.
- Failing tests: none.
- Line coverage (artifacts/pester/powershell-coverage.xml):
  - .claude/lib/docs/DocsFamilyCheck.psm1: 95 covered, 0 missed, 100.00%.
  - .claude/lib/docs/Invoke-DocsCommand.ps1: 190 covered, 19 missed, 90.91%.
  - Repo-wide figure of this targeted run: 12825 covered, 36391 missed, 26.06% (the coverage population is the whole config/poshqc-coverage.json set while only the targeted union ran, so the repo-wide figure is not comparable with a full run).
- Queue timeouts (exit 75, machine test-suite lock busy, re-run after the holder finished): 2026-11-24T08-51 (holder pid 42600), 2026-11-24T09-00 (holder pid 10264), 2026-11-24T09-02 (holder pid 10264), 2026-11-24T09-04 (holder pid 69864). The fifth attempt, started 2026-11-24T09-09, produced this result.

Owner waiver: this is the cycle's `Phase 0 baseline` under the owner instruction dated 2026-11-23: "The full test suite for any destination repo should only be run at the beginning of the orchestration and in the qc run. everything else should be targeted tests." The run is the targeted union named in the plan's Execution Notes, not the full suite.

Saved copies for the final comparison: SCRATCH/issue-1221-baseline-junit.xml and SCRATCH/issue-1221-baseline-coverage.xml.
