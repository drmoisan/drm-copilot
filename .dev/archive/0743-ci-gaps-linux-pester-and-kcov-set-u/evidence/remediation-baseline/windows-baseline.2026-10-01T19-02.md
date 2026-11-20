# Windows Baseline Tests and Coverage (P0-T5)

Timestamp: 2026-10-01T19-02
Baseline run: 36901896617 (head ecba8829); job `poshqc / PowerShell QC` databaseId 110502826187.

Command: gh run view 36901896617 --log --job 110502826187 | grep -F 'Tests Passed:'
EXIT_CODE: 0
Output Summary: `Tests Passed: 6091, Failed: 0, Skipped: 10, Inconclusive: 0, NotRun: 0` (ANSI color codes removed in this record).

Command: gh run download 36901896617 --name poshqc-test-results --dir <session-scratchpad>/windows-baseline-743
EXIT_CODE: 0
Output Summary: pester-junit.xml, powershell-coverage.xml, powershell-coverage.koverage.xml downloaded.

Command: poetry run python <session-scratchpad>/pester_xml_summary.py coverage <session-scratchpad>/windows-baseline-743/powershell-coverage.xml
EXIT_CODE: 0
Output Summary: `PS-LINE-COVERAGE: covered=11236 missed=430 percent=96.31`

B_PS = 96.31 (baseline PowerShell line coverage, used by P4-T9 and P5-T2).

Acceptance: `Failed: 0,` present; coverage line matches. Met.
