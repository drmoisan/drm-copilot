# [expect-fail] Pre-Fix Defect Reproduction — Empty Array Rejected (Issue #298)

Timestamp: 2026-07-03T21-37

Command: `pwsh -NoProfile -Command ". scripts/dev-tools/Invoke-FullReleaseFlow.ps1 -ConfirmToken no; ConvertTo-CommandResult -Output @() -ExitCode 0"`

EXIT_CODE: 1

Output Summary: The command terminated with a non-terminating error surfaced to the console and process exit code 1, reproducing the pre-fix defect. Exact error text quoted:

```
ConvertTo-CommandResult: Cannot bind argument to parameter 'Output' because it is an empty array.
```

This confirms the pre-fix defect: `ConvertTo-CommandResult`'s Mandatory `[object[]]$Output` parameter (no `[AllowEmptyCollection()]` attribute) rejects an empty-array argument, matching the exact error text reported in `issue.md`'s "Actual Behavior" section.
