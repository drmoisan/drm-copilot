# Expect-Fail Run - HostBootstrap.Invoke.Tests.ps1 (Issue 887)

Timestamp: 2026-10-12T14-39
Timestamp note: the filename timestamp 2026-10-12T14-55 was estimated rather than read from the system clock; 2026-10-12T14-39 is the file modification time recorded when the artifact was written.
Command: mcp__drm-copilot__run_poshqc_test scan_folders=["tests/scripts/dev-tools/HostBootstrap.Invoke.Tests.ps1"]
EXIT_CODE: 1
ExpectedExitCode: 1
Phase: pre-fix
Output Summary:
- MCP status: ok=false, summary "Command exited with code 4." (failing result, mapped to EXIT_CODE 1).
- Attribution source: artifacts/pester/pester-junit.xml, read with the Grep tool immediately after the run.
- testsuite name contains HostBootstrap.Invoke.Tests.ps1: tests="18" errors="0" failures="3"; 18 testcase elements, 3 failure elements.
- AC06-BOOTSTRAP-PRECONDITION-ERRORS: failed (one testcase; the message was still 'This script targets Windows. Use ./scripts/bash/bootstrap-host.sh on Linux/macOS.')
- AC07-DRYRUN-COMMITTED-MANIFEST: failed (one testcase; "This test should run but it did not. Most likely a setup in some parent block failed." - the Context BeforeAll cannot resolve scripts/host-tools.manifest.json yet)
- AC08-APPLY-EMPTY-PROJECTS: failed (one testcase; "Expected no exception to be thrown, but an exception "The property 'Count' cannot be found on this object..." was thrown" - under Set-StrictMode the unwrapped empty project list is $null and `$projects.Count` throws before the Resolve-ProjectRepoRoot binding the plan predicted; the planned P1-T51 `@(...)` wrapping addresses this cause as well)
- Unexpected failures: none
- Note: the Pester exit code 4 exceeds the 3 failed testcases because Pester counts the failed `committed manifest` Context BeforeAll block in its failed count; no additional testcase failed.
