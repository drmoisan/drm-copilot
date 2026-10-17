# Baseline PowerShell Line Coverage (P0-T13)

Timestamp: 2026-10-01T16-28
Deviation: D5. SP5 was not written or run as PowerShell; the report-level `LINE` counter was read from the CI artifact by the Python helper.

Command: poetry run python <session-scratchpad>/pester_xml_summary.py coverage <session-scratchpad>/poshqc-baseline-743/powershell-coverage.xml
EXIT_CODE: 0
Output Summary: `PS-LINE-COVERAGE: covered=11236 missed=430 percent=96.31`

Source: artifact `poshqc-test-results` of CI run 36890793420 (job `PowerShell QC` 110465608484, head 7282fb31153adb4d3449e5653d64c6b50e09de75).

PowerShell baseline line coverage: 96.31% (covered 11236, missed 430).
