# Tokenizer Suite on the Fixed Module - Issue 1019

Timestamp: 2026-11-06T18-09
Command: sh SCRATCH/issue-1019-p1-suite.sh (pwsh -NoProfile -File SCRATCH/issue-1019-fullsuite.ps1 -Root <worktree>; counts from the Pester result object)
EXIT_CODE: 0
Output Summary: full suite: passed=56 failed=0 skipped=0 notrun=0 seconds=24.49. The helper printed no `FAILED:` line.

The run started at 2026-11-06T18:07:27Z and ended at 2026-11-06T18:07:53Z. `MODULE` was not edited after the run; its SHA-256 is 6010cf357e5816136cf60b8d0e7dcf52f85555c42c7ec37b7e65883493ab9cbf.

## Required Passed Tests

The helper prints counts and failed names only. The three tests below are in the passed set because their titles are present in `SUITE`, and the run reports failed 0, skipped 0, and not-run 0.

- `passes the whole source to a .NET method only at the restart after a string token`
- `passes no source text variable to a .NET method inside a loop`
- `assigns the lexing window only from a Substring of the source text`

## Added Describes

`Get-DocsPythonToken structural scaling guard` and `Get-DocsPythonToken window boundaries` are appended after the last base describe, so each is separated from both candidate suite hunks by unchanged base lines. The new cases use in-memory strings and `Parser::ParseFile` on the module path, with no sleep, timing threshold, or temporary file.

## Supporting Observations

These runs are additional to the [P1-T4] acceptance and do not replace the Phase 2 gates.

| Observation | Result |
| --- | --- |
| `CONSUMER SUITES`, one process, no coverage, SCRATCH/issue-1019-p1-consumers.ps1 | passed=107 failed=0 skipped=0 notrun=0 seconds=9.6 |
| `Invoke-Formatter` with `scripts/powershell/PoshQC/settings/pssa.settings.psd1`, compared with `MODULE` and `SUITE`, no file written | formatter text equal for both files |
| `Invoke-ScriptAnalyzer` with the same settings on `MODULE` and `SUITE` | finding count 0 for each file |
| Margin mutation: `$script:DocsPythonTokenWindowMargin` set to 0 in a scratch copy under SCRATCH/mut-tree, full `SUITE` run from that copy | passed=34 failed=22, including 20 of the 22 `window boundaries` cases, so those cases detect a loss of the margin. The two that still pass are the long-input property case and the triple-quoted case. Both rebase at a string token before the window end is reached, so neither exercises the margin. |
