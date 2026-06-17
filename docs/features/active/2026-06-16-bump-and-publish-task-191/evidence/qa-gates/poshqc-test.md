# Final QC — PoshQC Test (Pester) with Coverage

Timestamp: 2026-06-16T20-35
Command: mcp__drm-copilot__run_poshqc_test (workspace root c:\Users\DanMoisan\repos\drm-copilot)
EXIT_CODE: 0

Output Summary:
- Repo-wide Pester result (artifacts/pester/pester-junit.xml): tests=608, failures=0, errors=0, disabled=9. All tests pass. (Baseline was 601; +7 new tests from Invoke-FullRelease.Tests.ps1.)
- New suite `tests/scripts/dev-tools/Invoke-FullRelease.Tests.ps1`: tests=7, failures=0, errors=0, skipped=0. All pass.
- Repo-wide pinned coverage (artifacts/pester/powershell-coverage.xml): LINE covered=275, missed=9, total=284 -> 96.83%. Unchanged from baseline (the repo-wide coverage Path in pester.runsettings.psd1 is pinned to five hook files and does not include scripts/dev-tools/; no regression).

New-code coverage (scripts/dev-tools/Invoke-FullRelease.ps1):
- Measured via a targeted Pester coverage run (CodeCoverage.Path scoped to the new file). The production test file uses the repo-standard AST `Import-ScriptFunction` import, which does not map coverage back to the original file path; a temporary dot-source harness (since removed) exercised all functions to obtain a numeric line/command coverage figure for the actual file path.
- JaCoCo output (artifacts/pester/fullrelease-coverage.xml): LINE covered=44, missed=6, total=50 -> 88.0% line coverage. INSTRUCTION/command covered=52, missed=7, total=59 -> 88.14%.
- BRANCH counter: not emitted by the Pester/CoverageGutters output format (same as baseline). No branch metric is available from the tooling; consequently there is no branch-coverage regression relative to baseline (neither baseline nor post-change emit a branch metric).
- The 6 uncovered lines are: the dot-source-guard entry-point wiring block (lines 227-229, intentionally skipped by the guard so functions can be imported for test), and the bodies of the two mocked wrapper seams `Write-StderrLine` (line 52) and `Invoke-PublishScript` (lines 102-103), whose single-statement external-call bodies are mocked in unit tests per the wrapper-seam policy.

Loop status: format -> analyze -> test all passed in a single clean pass with no file changes.
