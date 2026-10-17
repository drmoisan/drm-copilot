# P2-T2 Expect-Fail: Resolver Pester Suite Before the Helper Exists

Timestamp: 2026-10-09T23-21
Command: ls .claude/hooks/feature-review-coverage-thresholds.ps1; mcp__drm-copilot__run_poshqc_test (workspace_root = worktree root, scan_folders ["tests/scripts/claude-hooks"]); then poetry run python -c "<G6-derived per-file JUnit reader over artifacts/pester/pester-junit.xml>" (full text below)
EXIT_CODE: 1
ExpectedExitCode: 1
Output Summary:
- OPS-1: pester-files.sh replaced by run_poshqc_test (scan_folders tests/scripts/claude-hooks) + JUnit read. One MCP run serves both P2-T2 and P2-T3 (orchestrator decision); the same JUnit read is recorded in both artifacts.
- Command 1 (ls): EXIT 2; "No such file or directory". The helper is absent, as required.
- JUnit freshness: artifacts/pester/pester-junit.xml mtime before the call 2026-10-09 23:05:34 -0400; after the call 2026-10-09 23:23:43 -0400. Fresh; no JUNIT_STALE.
- Raw MCP result payload: {"ok": false, "tool": "run_poshqc_test", "workspace_root": "<worktree root>", "summary": "Command exited with code 14."} (the absolute host path is replaced by <worktree root>). MCP tool status: ok=false, child exit code 14 = 13 failed testcases + 1 failed block. Top-level EXIT_CODE 1 records the expected-failure outcome of the run, per the orchestrator decision.
- JUnit totals: "ROOT testsuites TESTS 2209 FAILURES 13 ERRORS 1 DISABLED 0".
- Target file: "FILE feature-review-coverage-thresholds.Tests.ps1 PASSED 0 FAILED 11".
- Suite-level: "SUITE feature-review-coverage-thresholds.Tests.ps1 TESTS 11 FAILURES 11 ERRORS 0"; no failure or error child element on any testsuite, and no `error` element anywhere in the report. The root ERRORS 1 is Pester's aggregate failed-block count.
- Failure message on all 11 resolver testcases: "This test should run but it did not. Most likely a setup in some parent block failed." This is the container/setup failure from the BeforeAll dot-source of the absent helper.
- FAILED testcases for this file (11, data-driven template name): "FAILED feature-review-coverage-thresholds.Tests.ps1 :: feature-review-coverage-thresholds (issue #824).T824-<Id> resolves <Label>" x 11.
- Other files in tests/scripts/claude-hooks (94 suites in the report): no failures outside the two P2 target files (feature-review-coverage-thresholds.Tests.ps1 and validate-feature-review-coverage.Issue824.Tests.ps1). No unexpected pre-existing failure.
- Acceptance (orchestrator-amended): ls exits non-zero - met; zero passed testcases and 11 failed testcases plus a recorded setup failure - met; no passed testcase from this file.
- Reader one-liner (EXIT 0): poetry run python -c "import xml.etree.ElementTree as E; r=E.parse('artifacts/pester/pester-junit.xml').getroot(); tail=lambda s: (s or '').replace(chr(92),'/').rpartition('/')[2]; bad=lambda t: t.find('failure') is not None or t.find('error') is not None; tc=list(r.iter('testcase')); T=('feature-review-coverage-thresholds.Tests.ps1','validate-feature-review-coverage.Issue824.Tests.ps1','validate-feature-review-coverage.Tests.ps1'); print('ROOT', r.tag, 'TESTS', r.get('tests'), 'FAILURES', r.get('failures'), 'ERRORS', r.get('errors'), 'DISABLED', r.get('disabled')); [print('FILE', n, 'PASSED', sum(1 for t in tc if tail(t.get('classname'))==n and not bad(t) and t.find('skipped') is None), 'FAILED', sum(1 for t in tc if tail(t.get('classname'))==n and bad(t))) for n in T]; [print('FAILED', tail(t.get('classname'))+' :: '+t.get('name','')) for t in tc if bad(t)]; [print('SUITE', tail(s.get('name')), 'TESTS', s.get('tests'), 'FAILURES', s.get('failures'), 'ERRORS', s.get('errors'), 'CHILD_FAILURE_OR_ERROR', [c.tag for c in s if c.tag in ('failure','error')]) for s in r.iter('testsuite') if tail(s.get('name')) in T or s.get('failures') not in (None,'0') or s.get('errors') not in (None,'0')]"
- Supplementary reads (EXIT 0 each): a scan for `error` elements and suites with non-zero `errors` (none found; 94 suites); a distinct-failure-message read (host paths masked).
- Result: EXPECTED FAILURE CONFIRMED.
