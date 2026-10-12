# Expect-Fail Run - host-tools.manifest.Tests.ps1 (Issue 887)

Timestamp: 2026-10-12T14-38
Timestamp note: the filename timestamp 2026-10-12T14-53 was estimated rather than read from the system clock; 2026-10-12T14-38 is the file modification time recorded when the artifact was written.
Command: mcp__drm-copilot__run_poshqc_test scan_folders=["tests/scripts/host-tools.manifest.Tests.ps1"]
EXIT_CODE: 1
ExpectedExitCode: 1
Phase: pre-fix
Output Summary:
- MCP status: ok=false, summary "Command exited with code 10." (failing result, mapped to EXIT_CODE 1).
- Attribution source: artifacts/pester/pester-junit.xml, read with the Grep tool immediately after the run.
- testsuite name contains host-tools.manifest.Tests.ps1: tests="9" errors="0" failures="9".
- Attribution form: per-case
- Each named ID matches exactly one testcase with a failure child (message "This test should run but it did not. Most likely a setup in some parent block failed."; the top-level BeforeAll fails because scripts/host-tools.manifest.json does not exist yet):
  - AC01-MANIFEST-TOP-LEVEL-KEYS: failed
  - AC02-MINIMUM-VERSIONS-PINNED: failed
  - AC03-POWERSHELL-MODULES-PINNED: failed
  - AC04-ENTRY-SHAPES: failed
  - AC06-CORE-VERSION-ZERO-FAILURES: failed
  - AC06-REQUIRED-COMMAND-ZERO-FAILURES: failed
  - AC06-OPTIONAL-COMMAND-ZERO-FAILURES: failed
  - AC06-POWERSHELL-MODULE-ZERO-FAILURES: failed
  - AC06-POETRY-TOOL-ZERO-FAILURES: failed
- The container-form condition also holds (failures 9 > 0, no testcase without a failure child).
- Unexpected failures: none
