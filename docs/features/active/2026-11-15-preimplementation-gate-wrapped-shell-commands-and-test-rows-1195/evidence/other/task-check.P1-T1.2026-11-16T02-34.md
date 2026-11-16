# Task Check P1-T1 (remediation cycle 1)

Timestamp: 2026-11-16T02-34
Plan: remediation-plan.2026-11-16T02-21.md
Command: sh SCRATCH/issue-1195-tc.sh C1-P1-T1 (1) PoshQC format with a no-op write seam and PSScriptAnalyzer with scripts/powershell/PoshQC/settings/pssa.settings.psd1 over the changed file; (2) sh .claude/skills/test-execution-policy/scripts/run-test-suite.sh pester -TestPath tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-classify.Tests.ps1 tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-classify.Tests.ps1; per-row results read from artifacts/pester/parallel/shard-1 and shard-2 JUnit files (SCRATCH/issue-1195-shards.sh, SCRATCH/issue-1195-c1-totals.sh)
EXIT_CODE: 1
ExpectedExitCode: 1
Output Summary:
- Changed files: tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-classify.Cases.ps1 (four rows appended to $script:ClassifyWrappedFunctionRows, one Positive row appended to $script:ClassifyWrappedGateRows; no existing row or header edited).
- Selection rule: CASES is test data dot-sourced by the two classify suites, so the selection is those two suites (test files that dot-source the changed file).
- Static: format exit 0, 1 file, would change 0; PSScriptAnalyzer 0 findings.
- Pester (launcher, 2 workers, exit 1, [expect-fail]): 284 tests, 274 passed, 10 failed, 0 skipped. The 10 failures are exactly the five new rows on each surface:
  - Claude and Codex: classifies wrapped Positive row timeout 60 env -u X sh -c "pytest" as $true (got $false)
  - Claude and Codex: W env value option after timeout
  - Claude and Codex: W env long value option after nohup
  - Claude and Codex: W env -S after timeout is declined
  - Claude and Codex: W env value option after xargs injected words
- Every pre-existing row passes on both surfaces.
