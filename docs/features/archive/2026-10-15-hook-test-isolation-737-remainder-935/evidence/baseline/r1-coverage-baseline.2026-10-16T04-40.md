# R1 Coverage Baseline (P0-T6)

Timestamp: 2026-10-16T04-40
Command: D-COV-FRESH: stat -c %y artifacts/pester/powershell-coverage.xml; grep -n -F -e 'report name="Pester (' artifacts/pester/powershell-coverage.xml. D-COV-READ: grep -c -E -e '^  .counter type="LINE" missed=' artifacts/pester/powershell-coverage.xml; grep -E -e '^  .counter type="LINE" missed=' artifacts/pester/powershell-coverage.xml | awk -F'"' '{ printf "covered=%d missed=%d total=%d pct=%.2f\n", $6, $4, $6 + $4, 100 * $6 / ($6 + $4) }' (run through a helper script under SCRATCH)
EXIT_CODE: 0
Output Summary:
- (a) CI baseline, quoted from `FEATURE/evidence/baseline/ci-baseline.2026-10-16T00-11.md`: covered 16381, missed 1735, total 18116, line coverage 90.42%.
- (b) Current local file `artifacts/pester/powershell-coverage.xml` (observed before any MCP test call of this cycle):
  - last-write time: `2026-10-15 23:08:07.814533300 -0400`
  - report-name line: `3:<report name="Pester (10/15/2026 23:07:35)">`
  - D-COV-READ match count K: 1
  - D-COV-READ output: `covered=8110 missed=4170 total=12280 pct=66.04`
- Comparison with the policy-audit section 1.2 values (`covered=8110 missed=4170 total=12280 pct=66.04`): identical, so neither `LOCAL-FILE-CHANGED-SINCE-REVIEW` nor `LOCAL-FILE-ABSENT` applies.
- Note: the local value is a three-folder run population (12280 lines), not the CI population (18116 lines).
