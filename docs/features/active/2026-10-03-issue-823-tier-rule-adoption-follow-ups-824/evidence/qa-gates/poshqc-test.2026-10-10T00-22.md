# P9-T12 Full PoshQC Test Run Plus JUnit Totals (OPS-1 substitution)

Timestamp: 2026-10-10T00-22
Command: mcp__drm-copilot__run_poshqc_test (workspace_root = worktree root, no scan_folders); poetry run python -c "import xml.etree.ElementTree as E; r=E.parse('artifacts/pester/pester-junit.xml').getroot(); print('ROOT', r.tag, 'TESTS', r.get('tests'), 'FAILURES', r.get('failures'), 'ERRORS', r.get('errors'), 'DISABLED', r.get('disabled')); [print('FAILED', t.get('classname','').replace(chr(92),'/').rpartition('/')[2]+' :: '+t.get('name','')) for t in r.iter('testcase') if t.find('failure') is not None or t.find('error') is not None]"
EXIT_CODE: 0
Output Summary:
- Loop iteration: 1
- OPS-1: the plan's `sh artifacts/orchestration/wip824-run/poshqc-test.sh` is replaced by the MCP test call (operator substitution).
- MCP result (host path replaced by <worktree>): {"ok":true,"tool":"run_poshqc_test","workspace_root":"<worktree>","summary":"Ran bundled PoshQC test against '<worktree>'."}
- Freshness check: artifacts/pester/pester-junit.xml mtime before the call 2026-10-10T00:00:48 (host clock at call start 2026-10-10T00:15:50); mtime after the call 2026-10-10T00:21:58. The file was rewritten by this run. FRESH (not JUNIT_STALE).
- G6 reader (exit 0): "ROOT testsuites TESTS 6780 FAILURES 0 ERRORS 0 DISABLED 10"; no FAILED lines.
- FINAL_PS_TESTS 6780 >= BASE_PS_TESTS 6752 + 28 = 6780. Met.
- FINAL_PS_FAILURES 0 (errors 0). FAILED names: none; subset of the empty P0-T20 pre-existing set; no PESTER-824 case failed. Met.
- No tracked source under .claude, tests, scripts, config, or extensions changed during the run.
- Result: PASS
