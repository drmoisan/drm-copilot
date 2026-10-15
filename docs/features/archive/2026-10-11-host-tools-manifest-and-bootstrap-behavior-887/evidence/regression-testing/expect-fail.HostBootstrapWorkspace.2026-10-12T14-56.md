# Expect-Fail Run - HostBootstrapWorkspace.Tests.ps1 (Issue 887)

Timestamp: 2026-10-12T14-40
Timestamp note: the filename timestamp 2026-10-12T14-56 was estimated rather than read from the system clock; 2026-10-12T14-40 is the file modification time recorded when the artifact was written.
Command: mcp__drm-copilot__run_poshqc_test scan_folders=["tests/scripts/dev-tools/HostBootstrapWorkspace.Tests.ps1"]
EXIT_CODE: 1
ExpectedExitCode: 1
Phase: pre-fix
Output Summary:
- MCP status: ok=false, summary "Command exited with code 8." (failing result, mapped to EXIT_CODE 1).
- Attribution source: artifacts/pester/pester-junit.xml, read immediately after the run.
- testsuite name contains HostBootstrapWorkspace.Tests.ps1: tests="32" errors="0" failures="8"; 32 testcase elements, 8 failure elements.
- AC08-RESOLVE-EMPTY-PROJECTS: failed ("ParameterBindingValidationException: Cannot bind argument to parameter 'Projects' because it is an empty array.")
- AC11-GIT-STREAMS: failed ("Expected 0, but got 1.")
- AC11-WINGET-STREAMS: failed ("Expected 0, but got 1.")
- AC11-NPM-STREAMS: failed ("Expected 0, but got 1.")
- AC11-NPM-NONZERO-NO-THROW: failed ("Expected 0, but got 1.")
- AC11-WSL-STREAMS: failed ("Expected 0, but got 1.")
- AC11-POETRY-STREAMS: failed ("Expected 0, but got 1.")
- AC11-PYTHON-POETRY-STREAMS: failed ("Expected 0, but got 1.")
- Each named ID matches exactly one testcase element.
- Unexpected failures: none
