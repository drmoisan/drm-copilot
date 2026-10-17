# P2-T3 Expect-Fail: Hook Pester Suites Against the Unmodified Hook

Timestamp: 2026-10-09T23-24
Command: mcp__drm-copilot__run_poshqc_test (workspace_root = worktree root, scan_folders ["tests/scripts/claude-hooks"]); then poetry run python -c "<G6-derived per-file JUnit reader over artifacts/pester/pester-junit.xml>" (full text below)
EXIT_CODE: 1
ExpectedExitCode: 1
Output Summary:
- OPS-1: pester-files.sh replaced by run_poshqc_test (scan_folders tests/scripts/claude-hooks) + JUnit read. This artifact reuses the single MCP run and JUnit read recorded for P2-T2 (orchestrator decision; freshness check passed). No second MCP run was made.
- JUnit freshness: artifacts/pester/pester-junit.xml mtime before the call 2026-10-09 23:05:34 -0400; after the call 2026-10-09 23:23:43 -0400. Fresh; no JUNIT_STALE.
- Raw MCP result payload: {"ok": false, "tool": "run_poshqc_test", "workspace_root": "<worktree root>", "summary": "Command exited with code 14."} (the absolute host path is replaced by <worktree root>). MCP tool status: ok=false, child exit code 14 = 13 failed testcases + 1 failed block (the resolver suite setup, see P2-T2). Top-level EXIT_CODE 1 records the expected-failure outcome of the run, per the orchestrator decision.
- JUnit totals: "ROOT testsuites TESTS 2209 FAILURES 13 ERRORS 1 DISABLED 0".
- Target files:
  - "FILE validate-feature-review-coverage.Issue824.Tests.ps1 PASSED 15 FAILED 2"
  - "FILE validate-feature-review-coverage.Tests.ps1 PASSED 4 FAILED 0"
  - Combined: PASSED 19 FAILED 2 (expected PASSED 19 FAILED 2).
- Suite-level: "SUITE validate-feature-review-coverage.Issue824.Tests.ps1 TESTS 17 FAILURES 2 ERRORS 0"; "SUITE validate-feature-review-coverage.Tests.ps1 TESTS 4 FAILURES 0 ERRORS 0"; no suite-level failure or error child element.
- FAILED testcases for these files (exactly two):
  - "FAILED validate-feature-review-coverage.Issue824.Tests.ps1 :: validate-feature-review-coverage.ps1 (issue #824).issue #824 - governing coverage thresholds (FU-823-1).F824-1 applies lower line and branch thresholds stated in the root CLAUDE.md"
  - "FAILED validate-feature-review-coverage.Issue824.Tests.ps1 :: validate-feature-review-coverage.ps1 (issue #824).issue #824 - governing coverage thresholds (FU-823-1).F824-3 applies a line-only figure and keeps the default branch floor"
- Failure messages (consistent with the derivation: the hook compares line coverage with the fixed 85.0): F824-1 "Expected $true, because 80 percent line and 65 percent branch meet the stated 70 and 60 percent thresholds, but got $false."; F824-3 "Expected regular expression 'below the 75% branch coverage floor' to match 'feature-review hook: coverage validation failed against branch diff: - Python repo-wide coverage is 80% (below the 85% line coverage floor) ...'".
- Other files in tests/scripts/claude-hooks (94 suites in the report): no failures outside the two P2 target files. No unexpected pre-existing failure.
- Acceptance (orchestrator-amended): combined PASSED 19 FAILED 2 - met; the only failed testcases begin F824-1 and F824-3 - met.
- Reader one-liner (EXIT 0): poetry run python -c "import xml.etree.ElementTree as E; r=E.parse('artifacts/pester/pester-junit.xml').getroot(); tail=lambda s: (s or '').replace(chr(92),'/').rpartition('/')[2]; bad=lambda t: t.find('failure') is not None or t.find('error') is not None; tc=list(r.iter('testcase')); T=('feature-review-coverage-thresholds.Tests.ps1','validate-feature-review-coverage.Issue824.Tests.ps1','validate-feature-review-coverage.Tests.ps1'); print('ROOT', r.tag, 'TESTS', r.get('tests'), 'FAILURES', r.get('failures'), 'ERRORS', r.get('errors'), 'DISABLED', r.get('disabled')); [print('FILE', n, 'PASSED', sum(1 for t in tc if tail(t.get('classname'))==n and not bad(t) and t.find('skipped') is None), 'FAILED', sum(1 for t in tc if tail(t.get('classname'))==n and bad(t))) for n in T]; [print('FAILED', tail(t.get('classname'))+' :: '+t.get('name','')) for t in tc if bad(t)]; [print('SUITE', tail(s.get('name')), 'TESTS', s.get('tests'), 'FAILURES', s.get('failures'), 'ERRORS', s.get('errors'), 'CHILD_FAILURE_OR_ERROR', [c.tag for c in s if c.tag in ('failure','error')]) for s in r.iter('testsuite') if tail(s.get('name')) in T or s.get('failures') not in (None,'0') or s.get('errors') not in (None,'0')]"
- Result: EXPECTED FAILURE CONFIRMED.
