# Temporary-Root Spelling (Issue #1026, DP1 precondition)

Timestamp: 2026-11-03T12-55
Command: sh SCRATCH/issue-1026-temp-spelling.sh
EXIT_CODE: 0
Output Summary: GetTempPath=long; TEMP=short; TMP=short. The DP1 precondition holds: GetTempPath() returns the long-name spelling and both TEMP and TMP carry the 8.3 short-name spelling.

Classification rule: `short` when a path segment contains `~` followed by a digit, `long` otherwise, `unset` when empty. No path value is printed or recorded.

| Source | Spelling |
|---|---|
| `[System.IO.Path]::GetTempPath()` | long |
| `$env:TEMP` | short |
| `$env:TMP` | short |
