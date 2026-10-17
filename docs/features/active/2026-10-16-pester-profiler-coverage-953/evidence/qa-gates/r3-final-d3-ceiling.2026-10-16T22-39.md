# r3 Final D3 and Pester Ceiling Constraints (P5-T14)

Timestamp: 2026-10-16T22-39
Command: export MSYS_NO_PATHCONV=1; pwsh -NoProfile -Command '$S = "SCRATCH"; $w = ".github/workflows/_poshqc.yml"; Select-String -SimpleMatch (case-insensitive) counts in $w of CoveragePercentTarget, -lt 85, -ge 85, fail-under, Import-Module Pester, and -MaximumVersion 5.99.99; count of lines in scripts/powershell/PoshQC/PoshQC.Shard.psm1 containing both throw and percent (case-insensitive)' (SCRATCH/issue-953-r3-p5-t14.sh)
EXIT_CODE: 0
Output Summary:
- Threshold lines in _poshqc.yml: CoveragePercentTarget 0, -lt 85 0, -ge 85 0, fail-under 0 (any: 0)
- PoshQC.Shard.psm1 lines with both throw and percent: 0 (D3: no failing coverage threshold)
- IMPORT_PESTER_LINES=2, MAXIMUM_VERSION_LINES=2 (equal, both at least 1)
- Result: PASS.
