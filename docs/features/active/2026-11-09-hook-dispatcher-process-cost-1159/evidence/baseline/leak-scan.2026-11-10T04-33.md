# Leak scan baseline ([P0-T7])

Timestamp: 2026-11-10T04-33
Command: sh SCRATCH/issue-1159-leak.sh SCRATCH/issue-1159-leak-p0.out (pwsh 7: `Import-Module scripts/powershell/PoshQC/PoshQC.psd1 -Force; Invoke-PoshQCLeakScan -Root <repository root>`)
EXIT_CODE: 0
Output Summary: Leak scan: 743 files, 75 findings, 73 exempt, 2 allowlisted, 0 failures. Warning: the scan folder `tests/powershell` named in `config/poshqc-scan.json` does not exist and was skipped (pre-existing).

Finding list: 0 failing findings. The 75 findings are all exempt (73) or listed in `config/poshqc-leak-allowlist.json` (2); the scan reports no unpaired environment, global, location or process-directory change.

Note: the scanned set includes the two [P0-T8]/[P0-T9] test files authored during Phase 0 (`tests/scripts/dev-tools/HookProcessCost.Tests.ps1`, `tests/scripts/dev-tools/Measure-HookProcessCost.Tests.ps1`) and the fixture `tests/fixtures/dev-tools/hook-process-cost/stdin-exit-hook.ps1`; none of them adds a failing finding.
