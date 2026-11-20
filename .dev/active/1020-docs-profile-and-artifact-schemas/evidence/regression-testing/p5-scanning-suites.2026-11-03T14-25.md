# Existing Suites That Scan `.claude/lib` ([P5-T6])

Timestamp: 2026-11-03T14-25
Command: sh SCRATCH/issue-1020-test.sh "tests/scripts/claude-lib/ClaudeLibModuleConvention.Tests.ps1;tests/scripts/claude-runtime/enforcement-hooks-no-python-invocation.Tests.ps1;tests/scripts/claude-runtime/enforcement-hooks-checkpoint-path-explicit.Tests.ps1;tests/scripts/ci/FileSizePolicy.RepoGate.Tests.ps1" issue-1020-exec-p5-scanning.log (branch-current `Invoke-PoshQCTest` from `scripts/powershell/PoshQC/PoshQC.psd1`); counts read from `artifacts/pester/pester-junit.xml` by SCRATCH/issue-1020-summary.ps1 and SCRATCH/issue-1020-exec-suites.ps1
EXIT_CODE: 0
Output Summary: tests=52 failures=0 errors=0 skipped=0 over 4 suites. `enforcement-hooks-no-python-invocation.Tests.ps1` (scan roots include `.claude/lib`, per `EnforcementHooksNoPythonInvocation.ScanRoots.Helpers.ps1`) passes, so it reports no `ConstantCommand`, `StartProcess`, `DynamicInvocation`, or `InvokeExpression` finding for any `.claude/lib/docs/` file, including the `InvokeProcess` member and `Invoke-DocsProcess` in `Invoke-DocsCommand.ps1`; the run log contains none of those four finding names.

| Suite | tests | failures | errors | skipped |
|---|---|---|---|---|
| ClaudeLibModuleConvention.Tests.ps1 | 6 | 0 | 0 | 0 |
| enforcement-hooks-no-python-invocation.Tests.ps1 | 33 | 0 | 0 | 0 |
| enforcement-hooks-checkpoint-path-explicit.Tests.ps1 | 8 | 0 | 0 | 0 |
| FileSizePolicy.RepoGate.Tests.ps1 | 5 | 0 | 0 | 0 |

CI: `poshqc / PowerShell QC` (windows-latest).
