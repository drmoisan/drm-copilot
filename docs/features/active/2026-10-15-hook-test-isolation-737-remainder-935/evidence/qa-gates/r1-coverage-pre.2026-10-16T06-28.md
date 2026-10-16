# R1 Coverage Pre-Observation (P5-T1)

Timestamp: 2026-10-16T06-28
Command: D-COV-FRESH: stat -c %y artifacts/pester/powershell-coverage.xml; grep -n -F -e 'report name="Pester (' artifacts/pester/powershell-coverage.xml. D-COV-READ: grep -c -E -e '^  .counter type="LINE" missed=' artifacts/pester/powershell-coverage.xml; grep -E -e '^  .counter type="LINE" missed=' artifacts/pester/powershell-coverage.xml | awk -F'"' '{ printf "covered=%d missed=%d total=%d pct=%.2f\n", $6, $4, $6 + $4, 100 * $6 / ($6 + $4) }' (run through a helper script under SCRATCH)
EXIT_CODE: 0
Output Summary:
- last-write time (before): `2026-10-16 02:25:17.045727800 -0400`
- report-name line (before): `3:<report name="Pester (10/16/2026 02:24:53)">`
- D-COV-READ match count K: 1
- D-COV-READ output (before): `covered=8110 missed=4170 total=12280 pct=66.04`
- Source: the P4-T3 three-folder run (`qa-gates/r1-ps-test.2026-10-16T06-26.md`).
