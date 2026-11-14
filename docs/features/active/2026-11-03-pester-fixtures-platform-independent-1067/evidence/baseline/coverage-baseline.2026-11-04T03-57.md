# Coverage Baseline (P0-T6)

Timestamp: 2026-11-04T03-57
Command: pwsh -NoProfile -NonInteractive -File SCRATCH/issue-1067-coverage.ps1 (imports scripts/powershell/PoshQC/PoshQC.psd1 and calls Invoke-PoshQCTest -ScanFolders tests/scripts/dev-tools tests/scripts/powershell/PoshQC -DisableKoverageCopy with an -InvokePester seam that sets TestResult.Enabled false, Run.Exit false, Run.PassThru true, then reads the LINE counters of artifacts/pester/powershell-coverage.xml)
EXIT_CODE: 85
Output Summary:
- Route: Invoke-PoshQCTest (self-hosted module). The XML was written, so the direct Invoke-Pester fallback was not needed. P6-T8 uses the same route.
- Coverage population: source=config, 269 files (config/poshqc-coverage.json).
- Pester counts: Tests=925 Passed=831 Failed=85 Skipped=9. The exit code 85 is the global LASTEXITCODE that Invoke-Pester sets to the failed count; the failures are the pre-existing Linux fixture failures in scope for this item.
- COVERAGE scripts/dev-tools/activate.ps1 92.45 (covered=49 missed=4)
- COVERAGE scripts/dev-tools/HostBootstrapWorkspace.psm1 96.88 (covered=62 missed=2)
- COVERAGE scripts/dev-tools/DrmCopilotPromptSupport.ps1 65.79 (covered=25 missed=13)
- COVERAGE scripts/powershell/PoshQC/PoshQC.ScanConfig.psm1 89.13 (covered=41 missed=5)
- The baseline figures are measured on Linux while 85 tests fail, so failing tests leave lines uncovered (DrmCopilotPromptSupport.ps1 in particular). A copy of the baseline XML is kept under SCRATCH for the P6-T9 delta.
