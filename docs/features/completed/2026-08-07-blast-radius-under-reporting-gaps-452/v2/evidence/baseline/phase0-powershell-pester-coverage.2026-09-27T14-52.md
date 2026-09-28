# Phase 0 Baseline — PowerShell Pester Repository-Wide Coverage (P0-T27)

Timestamp: 2026-09-27T14-52

Command: sh `<scratchpad>`/run-ps.sh `<scratchpad>`/clear-pester-artifacts.ps1
EXIT_CODE: 0
Output: pester-junit.xml PRESENT_AFTER_CLEAR=False; powershell-coverage.xml PRESENT_AFTER_CLEAR=False

Command: MCP mcp__drm-copilot__run_poshqc_test, workspace_root `<worktree root>`, no scan_folders override
EXIT_CODE: 0
Output: {"ok":true,"tool":"run_poshqc_test","summary":"Ran bundled PoshQC test against '<worktree root>'."}

Command: sh `<scratchpad>`/run-ps.sh `<scratchpad>`/poshqc-test.ps1
EXIT_CODE: 0
Output (tail):

```
Tests completed in 194.01s
Tests Passed: 5453, Failed: 0, Skipped: 9, Inconclusive: 0, NotRun: 0
Processing code coverage result.
Covered 95.28% / 0%. 14,744 analyzed Commands in 114 Files.
```

Command: sh `<scratchpad>`/run-ps.sh `<scratchpad>`/junit-report.ps1
EXIT_CODE: 0
Output:

```
ALL total=5462 pass=5453 fail=0 skip=9
```

Command: sh `<scratchpad>`/run-ps.sh `<scratchpad>`/coverage-line.ps1
EXIT_CODE: 0
Output:

```
LINE covered=10224 missed=422 percent=96.04
```

Output Summary:
- JUnit: total 5462, pass 5453, fail 0, skip 9. No FAILED_ANY lines; the baseline PowerShell failed set is empty.
- The self-hosted run exited 0, consistent with an empty failed set.
- Baseline PowerShell line coverage: 96.04% (10224 covered, 422 missed), read from the repository-runsettings coverage XML.
