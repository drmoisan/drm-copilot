# Expect-Fail Run - HostBootstrap.Tests.ps1 (Issue 887)

Timestamp: 2026-10-12T14-41
Timestamp note: the filename timestamp 2026-10-12T14-57 was estimated rather than read from the system clock; 2026-10-12T14-41 is the file modification time recorded when the artifact was written.
Command: mcp__drm-copilot__run_poshqc_test scan_folders=["tests/scripts/dev-tools/HostBootstrap.Tests.ps1"]
EXIT_CODE: 1
ExpectedExitCode: 1
Phase: pre-fix
Output Summary:
- MCP status: ok=false, summary "Command exited with code 1." (failing result, mapped to EXIT_CODE 1).
- Attribution source: artifacts/pester/pester-junit.xml, read immediately after the run.
- testsuite name contains HostBootstrap.Tests.ps1: tests="28" errors="0" failures="1"; 28 testcase elements, 1 failure element.
- AC11-PIP-STREAMS: failed (one testcase; "Expected 'Installing poetry via python -m pip', but got @('Installing poetry via python -m pip', 'Successfully installed poetry-fixture-1.0').")
- Unexpected failures: none
