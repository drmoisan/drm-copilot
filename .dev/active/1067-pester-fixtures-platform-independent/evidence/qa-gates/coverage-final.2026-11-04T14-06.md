# Final QA: Per-File Line Coverage (P6-T8, restart pass after resume)

Timestamp: 2026-11-04T14-06
Command: sh SCRATCH/issue-1067-coverage.sh (pwsh -NoProfile -NonInteractive -File SCRATCH/issue-1067-coverage.ps1; same route as P0-T6: Invoke-PoshQCTest from the self-hosted module scripts/powershell/PoshQC/PoshQC.psd1, -ScanFolders tests/scripts/dev-tools tests/scripts/powershell/PoshQC, -DisableKoverageCopy, InvokePester seam with TestResult off, Run.Exit off, Run.PassThru on; per-file LINE counters read from artifacts/pester/powershell-coverage.xml, written 2026-11-04T14-05)
EXIT_CODE: 0
Output Summary:
- Route: Invoke-PoshQCTest (self-hosted module), unchanged from P0-T6.
- Pester counts in the coverage run: Tests=934 Passed=925 Failed=0 Skipped=9.
- COVERAGE scripts/dev-tools/activate.ps1 98.11 (covered=52 missed=1)
- COVERAGE scripts/dev-tools/HostBootstrapWorkspace.psm1 100 (covered=64 missed=0)
- COVERAGE scripts/dev-tools/DrmCopilotPromptSupport.ps1 86.84 (covered=33 missed=5)
- COVERAGE scripts/powershell/PoshQC/PoshQC.ScanConfig.psm1 91.3 (covered=42 missed=4)
- All four values are at or above 85. Pester measures no branch coverage, so no branch gate applies.
