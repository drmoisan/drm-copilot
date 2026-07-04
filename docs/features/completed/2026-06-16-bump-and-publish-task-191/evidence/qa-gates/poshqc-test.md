# Final QC — PoshQC Test (Pester) with Coverage

Timestamp: 2026-06-17T00-18
Command: mcp__drm-copilot__run_poshqc_test (workspace root c:\Users\DanMoisan\repos\drm-copilot)
EXIT_CODE: 0

Output Summary:
- Repo-wide Pester result (artifacts/pester/pester-junit.xml): tests=608, failures=0, errors=0, disabled=9. All tests pass.
- New suite `tests/scripts/dev-tools/Invoke-FullRelease.Tests.ps1`: tests=7, failures=0, errors=0, skipped=0. All pass.
- Repo-wide pinned coverage (artifacts/pester/powershell-coverage.xml): LINE covered=275, missed=9, total=284 -> 96.83%. At or above the baseline value (96.83%); no regression. The repo-wide coverage Path in pester.runsettings.psd1 is pinned to five hook files and does not include scripts/dev-tools/.
- BRANCH counter: count of `type="BRANCH"` counters in artifacts/pester/powershell-coverage.xml = 0 (not emitted by the tooling output format, same condition as baseline).

New-code coverage (scripts/dev-tools/Invoke-FullRelease.ps1):
- Carried from the targeted Pester coverage run recorded in the prior cycle's artifact (artifacts/pester/fullrelease-coverage.xml). This remediation changed no PowerShell production or test code, so the new-code coverage figure is unchanged.
- JaCoCo output: LINE covered=44, missed=6, total=50 -> 88.0% line coverage. INSTRUCTION/command covered=52, missed=7, total=59 -> 88.14%.
- BRANCH counter: not emitted by the Pester/CoverageGutters output format (same as baseline). No branch metric is available from the tooling; consequently there is no branch-coverage regression relative to baseline.
- The 6 uncovered lines are the dot-source-guard entry-point wiring block and the single-statement bodies of the two mocked wrapper seams `Write-StderrLine` and `Invoke-PublishScript`, consistent with the wrapper-seam mocking policy.

Loop status: format -> analyze -> test all passed in a single clean pass with no PowerShell file changes.
