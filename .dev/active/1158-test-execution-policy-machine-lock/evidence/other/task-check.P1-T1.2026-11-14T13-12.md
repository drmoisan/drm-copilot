# Task Check: P1-T1 (remediation cycle 1)

Timestamp: 2026-11-14T13-12
Command: sh SCRATCH/issue-1158-ps-filestatic.sh (Invoke-Formatter check and Invoke-ScriptAnalyzer with pssa.settings.psd1 per changed file); sh .claude/skills/test-execution-policy/scripts/run-test-suite.sh pester -TestPath tests/scripts/powershell/PoshQC tests/scripts/claude-skills/test-execution-policy tests/scripts/claude-hooks/enforce-test-execution-policy.Tests.ps1 tests/scripts/codex-hooks/enforce-test-execution-policy.Tests.ps1 tests/scripts/claude-hooks/test-execution-command-form.Tests.ps1; sh .claude/skills/test-execution-policy/scripts/run-test-suite.sh pytest tests/scripts/dev_tools/test_poshqc_bundled_parity.py (both through SCRATCH/issue-1158-run-suite.sh)
EXIT_CODE: 0
Output Summary: format 0 diffs and PSScriptAnalyzer 0 findings on the changed PowerShell files; the scoped launcher pester run exited 0 with 8 workers over 32 files, 1070 tests, 0 failures, 0 errors, 7 skipped; PoshQC.ParallelScoped.Tests.ps1 12 passed; the bundle parity pytest file 1 passed. Get-FileHash equal for both copy pairs. PoshQC.Parallel.psm1 is 543 lines (under 700).

## Changed Files

- scripts/powershell/PoshQC/PoshQC.Parallel.psm1 (TestPath on Get-PoshQCParallelShardArgument and Invoke-PoshQCParallelTest, ResolveTestFile seam, private Resolve-PoshQCParallelTestFile)
- scripts/powershell/PoshQC/README.md (Scoped runs bullet)
- extensions/drm-copilot/resources/powershell/PoshQC/PoshQC.Parallel.psm1 and README.md (byte-identical copies; SHA256 equal to their sources)
- tests/scripts/powershell/PoshQC/PoshQC.ParallelScoped.Tests.ps1 (new, PS01 to PS12)

## Selection and Rule

Mirrored tests of PoshQC.Parallel.psm1 (the tests/scripts/powershell/PoshQC folder, which holds ParallelScoped, ParallelRunner, ParallelMerge, TestingLaneExclusion, McpTemplateLock, ModuleCoverage, ScanFolders, and TestingCommands) plus every test file that names Invoke-PoshQCParallelTest or the parallel module: the test-execution-policy launcher tests, both enforce-test-execution-policy hook suites, test-execution-command-form.Tests.ps1, and tests/scripts/dev_tools/test_poshqc_bundled_parity.py.

| Command | EXIT_CODE |
|---|---|
| format check and PSScriptAnalyzer, 3 files | 0 |
| launcher pester -TestPath (selection above) | 0 |
| launcher pytest test_poshqc_bundled_parity.py | 0 |

| Test file | Tests | Failures |
|---|---|---|
| PoshQC.ParallelScoped.Tests.ps1 | 12 | 0 |
| PoshQC.ParallelRunner.Tests.ps1 (PR01 to PR11) | 11 | 0 |
| PoshQC.ParallelMerge.Tests.ps1 | 12 | 0 |
| PoshQC.TestingLaneExclusion.Tests.ps1 | 10 | 0 |
| PoshQC.McpTemplateLock.Tests.ps1 | 24 | 0 |
| PoshQC.ModuleCoverage.Tests.ps1 | 5 | 0 |

Note: a first run of the new file failed PS08 to PS12 because a Mock -ModuleName registered from the test scope is not seen when the suite runs inside a PoshQC shard; the mocks were moved inside InModuleScope PoshQC, and the rerun passed. This is a task-check record, not gate evidence.
