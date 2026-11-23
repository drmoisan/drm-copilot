# P4-T2 leak scan

Timestamp: 2026-11-23T10-25
Command: import scripts/powershell/PoshQC/PoshQC.psd1 and call Invoke-PoshQCLeakScan -Root <worktree root>, run from a script under SCRATCH launched with sh
EXIT_CODE: 0
Output Summary: 'Leak scan: 904 files, 80 findings, 78 exempt, 2 allowlisted, 0 failures.' The scan throws on any failure and did not throw. The new test files add no unrestored environment variable, global variable, global function, location or process-directory change; their AfterAll removes the helper functions and imported modules.
