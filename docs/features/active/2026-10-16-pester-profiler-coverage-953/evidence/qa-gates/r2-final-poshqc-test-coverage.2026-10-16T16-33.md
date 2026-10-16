# r2 final full Pester run with coverage (P5-T3, loop pass 1, abandoned)

Timestamp: 2026-10-16T16-33
Command: sh "SCRATCH/issue-953-r2-p5-t3.sh" (FULL_RUN(final) task text verbatim), then sh "SCRATCH/issue-953-r2-p5-t3-2.sh" (JRP totals and failed cases)
EXIT_CODE: 1
Output Summary: FAIL. FULL_RUN output: EXIT_CODE=1 SECONDS=1152 START_UTC=2026-10-16T16:11:50.6014601Z. JRP: JUNIT_TESTS=10784 JUNIT_FAILURES=1 JUNIT_ERRORS=0.
  FAILED_CASE: tests/scripts/powershell/PoshQC/PoshQC.TestingShard.Tests.ps1 | Invoke-PoshQCTest shard parameters.TS04-DEFAULT-FILELIST-SEAM-WRITES-UTF8-JSON
  MESSAGE: DirectoryNotFoundException: Could not find a part of the path 'C:\shard-root\artifacts\pester\shard-files.json'. (stack: default WriteShardFileList seam, PoshQC.Testing.psm1:174, called from Select-PoshQCShardTestFile, PoshQC.Shard.psm1:253)
  Cause: in the full-suite run, `Mock -CommandName Set-Content -ModuleName PoshQC` did not intercept the default seam, so the seam attempted a real write. TS04 passed in the targeted run (P4-T3), in a single-file run with PoshQC preloaded from PoshQC.psd1, and in a run over the whole tests/scripts/powershell/PoshQC folder without coverage; the failure appears only in the full-suite context. The likely cause is that TS04 resolved Invoke-PoshQCTest from test scope, which in the full suite can reach a PoshQC instance other than the one that the module-scoped mock patched.
  Restart-rule fix: TS04 now registers the Set-Content mock and calls Invoke-PoshQCTest inside `InModuleScope PoshQC` (the pattern of tests/scripts/powershell/PoshQC/PoshQC.Comprehensive.Tests.ps1:170-206, which mocks Set-Content in full-suite runs). The fix touches a test file only, so P4-T2 is not re-run. The loop restarts at P5-T1.
