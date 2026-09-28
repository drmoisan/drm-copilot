# Remediation Cycle 1 Host-Data Scan ([P3-T5])

Timestamp: 2026-09-25T21-29
Command: sh <SCRATCHPAD>/rem1/runout.sh p3-host  (fresh PowerShell 7 process; the worktree root, user profile directory, and account name computed at run time; (a) every rem1-* file under the feature evidence folder and the "## Remediation cycle 1" sections of mirror-log.md, batch-budget-resets.md, commits.md, ac-checkoff.md, and follow-ups.md; (b) added lines of git diff -U0 77da1f86 -- <the four cycle test files>; a line matches (?<![A-Za-z])[A-Za-z]:[\\/], [\\/](Users|home)[\\/], or a case-insensitive simple match of a computed value)
EXIT_CODE: 0
Output Summary: Scanned 21 rem1-* files (3237 lines), the cycle-1 sections of the five logs (40, 11, 26, 0, 0 lines), and 92 added test lines. No file has a non-zero count.

## Scan Output (counts only; no matched text)

```
Rem1FilesScanned: 21 (3237 lines)
Log mirror-log.md: remediation-cycle-1 section lines 40
Log batch-budget-resets.md: remediation-cycle-1 section lines 11
Log commits.md: remediation-cycle-1 section lines 26
Log ac-checkoff.md: remediation-cycle-1 section lines 0
Log follow-ups.md: remediation-cycle-1 section lines 0
AddedTestLinesScanned: 92
FilesWithMatches: none
PROCESS_EXIT_CODE: 0
```

Files with a non-zero count: none

Note: this artifact was written after the scan and is not in the scanned set; it quotes the regexes but no host value.
