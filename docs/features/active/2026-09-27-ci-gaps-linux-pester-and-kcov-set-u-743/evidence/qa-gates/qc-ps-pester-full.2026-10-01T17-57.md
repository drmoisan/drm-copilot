# QC Step 3: PowerShell Test with Coverage (P7-T3, loop pass 1)

Timestamp: 2026-10-01T17-57
Deviations: D4 (test results from CI), D5 (coverage from the CI artifact), D9 (Python helper), D14 (checked after P7-T19).

Command: mcp__drm-copilot__run_poshqc_test (workspace_root = <REPO_ROOT>)
EXIT_CODE: 0
Output Summary: `ok: true`; summary `Ran bundled PoshQC test against '<REPO_ROOT>'.` (loop pass 1, run after P7-T2). No counts are returned.

Command: gh run view 36901896617 --log --job 110502826187 | grep -F 'Tests Passed:'
EXIT_CODE: 0
Output Summary: `Tests Passed: 6091, Failed: 0, Skipped: 10, Inconclusive: 0, NotRun: 0` (job `poshqc / PowerShell QC`, CI_SHA ecba8829604f6265dc491c74cf42546f9d5aab57).

Command: poetry run python <session-scratchpad>/pester_xml_summary.py junit <session-scratchpad>/windows-final/pester-junit.xml
EXIT_CODE: 0
Output Summary: `JUNIT-ROOT: tests=6101 failures=0 errors=0`; `SUITE: tests/scripts/workflows/PoshQcWorkflow.Tests.ps1 | tests=7 | failures=0 | errors=0 | skipped=0`; the three modified Codex suites `failures=0`, `errors=0`.

Command: poetry run python <session-scratchpad>/pester_xml_summary.py coverage <session-scratchpad>/windows-final/powershell-coverage.xml
EXIT_CODE: 0
Output Summary: `PS-LINE-COVERAGE: covered=11236 missed=430 percent=96.31` (at least 85.00 and equal to the P0-T13 baseline 96.31; AC-21).
