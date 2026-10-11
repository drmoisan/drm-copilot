# P0-T20 Baseline Full PoshQC Test With Coverage

Timestamp: 2026-10-09T22-59
Command: mcp__drm-copilot__run_poshqc_test (workspace_root = worktree root, no scan_folders); then poetry run python -c "import xml.etree.ElementTree as E; r=E.parse('artifacts/pester/pester-junit.xml').getroot(); print('ROOT', r.tag, 'TESTS', r.get('tests'), 'FAILURES', r.get('failures'), 'ERRORS', r.get('errors'), 'DISABLED', r.get('disabled')); [print('FAILED', t.get('classname','').replace(chr(92),'/').rpartition('/')[2]+' :: '+t.get('name','')) for t in r.iter('testcase') if t.find('failure') is not None or t.find('error') is not None]"
EXIT_CODE: 0
Output Summary:
- OPS-1: the plan's `sh artifacts/orchestration/wip824-run/poshqc-test.sh` was replaced by the PoshQC MCP test tool with no scan_folders, per operator substitution 6. The MCP tool returns no numeric exit code; its result reports ok=true, recorded as test exit 0.
- Raw MCP result: {"ok":true,"tool":"run_poshqc_test","workspace_root":"<worktree root>","summary":"Ran bundled PoshQC test against '<worktree root>'."} (absolute host path replaced by <worktree root>)
- Freshness: before the call pester-junit.xml mtime 2026-10-09 22:57:54 and powershell-coverage.xml mtime 2026-10-09 22:57:27 (from the P0-T17 targeted run); after the call 23:05:34 and 23:04:16 respectively. Both fresh.
- G6 one-liner: EXIT 0; "ROOT testsuites TESTS 6752 FAILURES 0 ERRORS 0 DISABLED 10"; no FAILED lines
- BASE_PS_TESTS: 6752
- BASE_PS_FAILURES: 0
- Pre-existing PowerShell failure set: none
- Note: the MCP runner may read installed-extension PoshQC settings rather than the repository copy (known behavior); the scan and coverage population are therefore those the MCP runner applied. The CI coverage job remains the reference if they differ.
- Result: PASS
