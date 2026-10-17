# Sharding: No Coverage Threshold Added (P8-T17, D3)

Timestamp: 2026-10-16T13-59
Command: sh "SCRATCH/issue-953-p8-t17.sh" — `@(Select-String -LiteralPath .github/workflows/_poshqc.yml -SimpleMatch -Pattern <t>).Count` for `CoveragePercentTarget`, `-lt 85`, `-ge 85`, `fail-under`; and in `scripts/powershell/PoshQC/PoshQC.CoverageMerge.psm1` the line numbers matching `throw` and `percent` (`Select-String -SimpleMatch`, case-insensitive), counting lines matched by both.
EXIT_CODE: 0

Output Summary:
- `.github/workflows/_poshqc.yml`: CoveragePercentTarget 0, `-lt 85` 0, `-ge 85` 0, `fail-under` 0.
- `PoshQC.CoverageMerge.psm1`: 6 lines contain `throw`, 2 contain `percent`, 0 contain both.
- All counts are 0. Result: PASS (no failing coverage threshold added).
