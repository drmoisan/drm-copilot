# Expect-Fail Run - publish-sideloaded-extension.Tests.ps1 (Issue 887)

Timestamp: 2026-10-12T14-41
Timestamp note: the filename timestamp 2026-10-12T14-58 was estimated rather than read from the system clock; 2026-10-12T14-41 is the file modification time recorded when the artifact was written.
Command: mcp__drm-copilot__run_poshqc_test scan_folders=["tests/scripts/dev-tools/publish-sideloaded-extension.Tests.ps1"]
EXIT_CODE: 1
ExpectedExitCode: 1
Phase: pre-fix
Output Summary:
- MCP status: ok=false, summary "Command exited with code 7." (failing result, mapped to EXIT_CODE 1).
- Attribution source: artifacts/pester/pester-junit.xml, read immediately after the run.
- testsuite name contains publish-sideloaded-extension.Tests.ps1: tests="18" errors="0" failures="7"; 18 testcase elements, 7 failure elements.
- AC15-PUBLISH-INHERITED-WHATIF-NOSEAMS: failed ("RuntimeException: unmocked host seam: New-Item")
- AC13-WHATIF-INHERITED: failed (Invoke-SideloadedExtensionPublish filter matched 0 calls)
- AC13-CONFIRM-NONE: failed (filter matched 0 calls)
- AC13-CONFIRM-LOW: failed (filter matched 0 calls)
- AC13-VERBOSE-INHERITED: failed (filter matched 0 calls)
- AC13-DEBUG-INHERITED: failed (filter matched 0 calls)
- AC13-BOUND-DEBUG-INFO-PROGRESS: failed (filter matched 0 calls)
- Expected to pass pre-fix, observed: AC13-WHATIF-BOUND-FALSE-WINS passed; AC13-CONFIRM-HIGH passed; AC13-DEFAULT-NO-WHATIF passed.
- Each ID matches exactly one testcase element.
- Unexpected failures: none
