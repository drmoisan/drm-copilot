# Host-Data Scan ([P7-T10], rule 2)

Timestamp: 2026-09-25T19-54
Command: sh <SCRATCHPAD>/i663/run.sh p7-host  (fresh PowerShell 7 process; computes the worktree root, the user profile directory, and the account name at run time; scans (a) every file under the feature evidence folder and (b) the added lines of `git diff -U0 origin/main -- <each of the thirteen section 7 test files>` plus the full text of the five new test files; `git status --porcelain` is also read)
EXIT_CODE: 0
Output Summary: 47 evidence files, 1245 added test lines, and 978 lines of the five new test files scanned; no line matched `(?<![A-Za-z])[A-Za-z]:[\\/]`, `[\\/](Users|home)[\\/]`, or a case-insensitive simple match of any computed value. No file is listed. The five new test files are already committed (Phases 2 to 5), so `git status --porcelain` lists none of them; their full text was read from the worktree.

Matching rule: a line matches on the drive-letter regex, the Users/home regex, or a case-insensitive simple match of the worktree root (both separator forms), the user profile directory (both separator forms), or the account name. `spec.md`, `issue.md`, `research/`, and the plan are outside the scan per the task text.

Discrimination probe (sh <SCRATCHPAD>/i663/run.sh p7-host-probe): the same matcher reported True for a drive-rooted sample, a backslash-separated Users-directory sample, a slash-separated home-directory sample, and the computed worktree root, and False for an `https://` URL and plain text, so a zero count is not caused by a matcher that cannot fire.

## Scanner output (first run)

```
EvidenceFilesScanned: 47
PorcelainLineCount: 10
AddedLinesScanned: 1245
NewTestFileLinesScanned: 978
FilesWithMatches: none
PROCESS_EXIT_CODE: 0
```

## Scanner output (re-run covering this artifact)

The first draft of this artifact described the probe with a literal slash-separated home-directory token, and a re-run listed this file with count 1. The wording was changed to a description without separators, and the re-run then reported:

```
EvidenceFilesScanned: 48
PorcelainLineCount: 11
AddedLinesScanned: 1245
NewTestFileLinesScanned: 978
FilesWithMatches: none
PROCESS_EXIT_CODE: 0
```

Files with a non-zero count: none

Result: PASS
