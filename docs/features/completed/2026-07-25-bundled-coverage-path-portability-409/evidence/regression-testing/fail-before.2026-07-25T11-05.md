# Fail-Before Evidence — Coverage-Path Pruning (spec SD3, issue #409)

Timestamp: 2026-07-25T11-05

Command (as stated in plan task [P1-T2]):
`pwsh -NoLogo -NoProfile -Command "Invoke-Pester -Path tests/scripts/powershell/PoshQC/PoshQC.TestingCoveragePruning.Tests.ps1 -Output Detailed"`

Command (exit-code-bearing variant, same test file and same pre-fix code):
`pwsh -NoLogo -NoProfile -Command "$r = Invoke-Pester -Path tests/scripts/powershell/PoshQC/PoshQC.TestingCoveragePruning.Tests.ps1 -PassThru -Output None; 'Passed={0} Failed={1}' -f $r.PassedCount, $r.FailedCount; $r.Failed | ForEach-Object { 'FAILED: ' + $_.ExpandedName }; exit $r.FailedCount"`

EXIT_CODE: 3

Exit-code note (recorded faithfully, not adjusted): the plan's literal command returns process exit code **0** even though 3 tests fail, because `Invoke-Pester` does not set a non-zero process exit code unless `Run.Exit` is enabled in configuration or `-CI` is supplied; the failure signal in that form is the `Failed: 3` line in the summary. The exit-code-bearing variant above runs the identical test file against the identical pre-fix code and propagates the failure count, yielding `EXIT_CODE: 3`. Both results are reported; neither the test file nor any assertion was modified to produce a failure.

Pre-fix production state at time of this run:
- `scripts/powershell/PoshQC/PoshQC.Testing.psm1` — git blob `53756b61a31c0a90b11e51e96f099fb6375c0af4`, 443 lines, no pruning code.
- `extensions/drm-copilot/resources/powershell/PoshQC/PoshQC.Testing.psm1` — same blob hash.

Output Summary:
- Pester v5.6.1. Discovery found 4 tests in 1 file. Result: **Passed 1, Failed 3, Skipped 0**, completed in 988 ms.
- **PASSED (expected):** `passes the full resolved coverage set through and logs no prune lines when every configured path exists`. The all-exist pass-through scenario passes against pre-fix code, which is the required proof that the fix must not alter behavior when every configured path exists.
- **FAILED (expected) — mixed set:** `keeps only the existing paths and logs each pruned path with its resolved value for a mixed set`
  - Assertion at `tests/scripts/powershell/PoshQC/PoshQC.TestingCoveragePruning.Tests.ps1:127`
  - `Expected @('/prune-root/present-a.ps1', '/prune-root/present-c.ps1'), but got @('/prune-root/present-a.ps1', '/prune-root/missing-b.ps1', '/prune-root/present-c.ps1').`
  - This quoted output is the direct proof that pre-fix `Invoke-PoshQCTest` forwards a nonexistent coverage path (`/prune-root/missing-b.ps1`, reported absent by the injected `$TestPathExists` seam) to the injected `$InvokePester` seam.
- **FAILED (expected) — empty surviving set:** `disables coverage at the $InvokePester boundary, logs one explanation, proceeds with the run, and skips the coverage copy when no configured path exists`
  - Assertion at `tests/scripts/powershell/PoshQC/PoshQC.TestingCoveragePruning.Tests.ps1:191`
  - `Expected $false, but got $true.`
  - Pre-fix code leaves `CodeCoverage.Enabled` true at the `$InvokePester` boundary even though both configured paths were reported absent, i.e. coverage is handed to Pester as enabled-but-nonexistent.
- **FAILED (expected) — rooted absolute entry:** `evaluates a rooted absolute entry with the same predicate and never re-joins it to -Root`
  - Assertion at `tests/scripts/powershell/PoshQC/PoshQC.TestingCoveragePruning.Tests.ps1:250`
  - `Expected '/rooted-present.ps1', but got @('/rooted-present.ps1', '/rooted-missing.ps1').`
  - Pre-fix code forwards the nonexistent rooted absolute entry unchanged; no existence predicate is applied to rooted entries.
- Determinism: all four scenarios are seam-injected. No temp files, no filesystem writes (`New-Item` is mocked inside `InModuleScope PoshQC`), no live Pester subprocess for the code under test, and no timing waits.
