# Fail-Before Regression Run (issue #928) [expect-fail]

Timestamp: 2026-10-16T01-51
Command: mcp__drm-copilot__run_poshqc_test (scan_folders ["tests/scripts/claude-hooks"], workspace_root WORKTREE_ROOT); then poetry run python SCRATCH/928/junit_rows.py artifacts/pester/pester-junit.xml subagentstop-uncaught-error.Tests.ps1
MCP_DISPOSITION: error (Command exited with code 9.)
EXIT_CODE: 8
ExpectedExitCode: 8

Output Summary:
- MTIME_UTC 2026-10-16T02-02 (not earlier than Timestamp 2026-10-16T01-51)
- SUITE subagentstop-uncaught-error.Tests.ps1 MATCHED 10 FAILED 8
- The eight FAIL lines are the U1 rows of the eight AC1 validators; each failure message shows the propagated exception `System.Management.Automation.RuntimeException: simulated unhandled error (issue #928).`
- The feature-review U1 row and U2 pass (characterization).
- The MCP exit code 9 counts the 8 new-suite failures plus 1 failure in an existing suite: `discovery guard (both hook surfaces).AC-6 tests/scripts/claude-hooks/subagentstop-uncaught-error.Tests.ps1 calls the interception probe from inside an It` (enforce-gate-suites.EpicStateIsolation.Discovery.Tests.ps1). That failure is recorded as a finding; it is outside this task's acceptance and blocks P6-T3 unless resolved.
- Prior run (before the single test-file correction, Timestamp 2026-10-16T01-37, report MTIME 2026-10-16T01-49) produced the same new-suite shape (MATCHED 10 FAILED 8) and an AC-4 guard failure for nine missing baseline seam mocks; the correction added those mocks.

Per-test lines (prefix `SubagentStop validator unhandled-error block (issue #928).` omitted; failure-message `-Because` clause shortened):

- FAIL U1: .claude/hooks/validate-discovery-artifact-gate.ps1 blocks with exit 2 when the validation call throws | Expected $null or empty ... but got System.Management.Automation.RuntimeException: simulated unhandled error (issue #928).
- FAIL U1: .claude/hooks/validate-executor-output.ps1 blocks with exit 2 when the validation call throws | Expected $null or empty ... but got System.Management.Automation.RuntimeException: simulated unhandled error (issue #928).
- PASS U1: .claude/hooks/validate-feature-review-coverage.ps1 blocks with exit 2 when the validation call throws
- FAIL U1: .claude/hooks/validate-orchestrator-output.ps1 blocks with exit 2 when the validation call throws | Expected $null or empty ... but got System.Management.Automation.RuntimeException: simulated unhandled error (issue #928).
- FAIL U1: .claude/hooks/validate-planner-output.ps1 blocks with exit 2 when the validation call throws | Expected $null or empty ... but got System.Management.Automation.RuntimeException: simulated unhandled error (issue #928).
- FAIL U1: .claude/hooks/validate-pr-author-output.ps1 blocks with exit 2 when the validation call throws | Expected $null or empty ... but got System.Management.Automation.RuntimeException: simulated unhandled error (issue #928).
- FAIL U1: .claude/hooks/validate-prd-feature-output.ps1 blocks with exit 2 when the validation call throws | Expected $null or empty ... but got System.Management.Automation.RuntimeException: simulated unhandled error (issue #928).
- FAIL U1: .claude/hooks/validate-required-artifact-output.ps1 blocks with exit 2 when the validation call throws | Expected $null or empty ... but got System.Management.Automation.RuntimeException: simulated unhandled error (issue #928).
- FAIL U1: .claude/hooks/validate-task-researcher-output.ps1 blocks with exit 2 when the validation call throws | Expected $null or empty ... but got System.Management.Automation.RuntimeException: simulated unhandled error (issue #928).
- PASS U2: has a row for every hook that dot-sources subagentstop-envelope.ps1 and no other
