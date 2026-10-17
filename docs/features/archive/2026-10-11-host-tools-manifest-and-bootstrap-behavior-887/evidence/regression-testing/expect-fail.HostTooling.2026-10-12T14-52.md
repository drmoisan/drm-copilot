# Expect-Fail Run - HostTooling.Tests.ps1 (Issue 887)

Timestamp: 2026-10-12T14-38
Timestamp note: the filename timestamp 2026-10-12T14-52 was estimated rather than read from the system clock; 2026-10-12T14-38 is the file modification time recorded when the artifact was written.
Command: mcp__drm-copilot__run_poshqc_test scan_folders=["tests/scripts/dev-tools/HostTooling.Tests.ps1"]
EXIT_CODE: 1
ExpectedExitCode: 1
Phase: pre-fix
Output Summary:
- MCP status: ok=false, summary "Command exited with code 3." (failing result, mapped to EXIT_CODE 1).
- Attribution source: artifacts/pester/pester-junit.xml, read with the Grep tool immediately after the run.
- testsuite name contains HostTooling.Tests.ps1: tests="22" errors="0" failures="3".
- AC05-MANIFEST-PATH-EXISTS: failed (one testcase; failure "Expected $true, but got $false.")
- AC10-STREAM-OUTHOST-RESETS-EXITCODE: failed (one testcase; failure "ParameterBindingException: A parameter cannot be found that matches parameter name 'StreamToHost'.")
- AC10-CAPTURE-RESETS-STALE-EXITCODE: failed (one testcase; failure "Expected 0, but got 7.")
- Unexpected failures: none
