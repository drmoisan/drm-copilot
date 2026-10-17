# Guard constraint scan (P1-T18)

Timestamp: 2026-10-01T20-56
Command: grep -n -E "tempfile|tmp_path|tmpdir|subprocess|urllib|socket" tests/scripts/dev_tools/test_workflow_npm_token_guard.py
EXIT_CODE: 1
ExpectedExitCode: 1
Output Summary: no output (none of the six prohibited tokens appears in the module)
