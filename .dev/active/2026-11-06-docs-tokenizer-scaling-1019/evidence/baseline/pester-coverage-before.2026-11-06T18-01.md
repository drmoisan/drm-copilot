# Pester Coverage Baseline - Issue 1019

Timestamp: 2026-11-06T18-01
Command: sh SCRATCH/issue-1019-p0-t5.sh (SCRATCH/issue-1019-p0-observe.ps1 -Step T5: Pester 6.2.0 run of tests/scripts/claude-lib/docs/DocsPythonTokens.Tests.ps1 on the unmodified worktree, Filter.FullName listing the 11 kept template paths, CodeCoverage on .claude/lib/docs/DocsPythonTokens.psm1 in JaCoCo format at SCRATCH/issue-1019-coverage-before.xml)
EXIT_CODE: 0
Output Summary: passed=28 failed=0 skipped=0 notrun=1 of 29 tests in 3.71 s. MODULE line coverage 98.44% (126 covered, 2 missed), read from the JaCoCo report. Command coverage 94.88% (241 of 254), informational. git status --porcelain was empty for MODULE and SUITE after the run.

## Stated Exclusion

One test is excluded, and it is the only test not run:

`Get-DocsPythonToken diagnostics.reports PYTHON_TOKEN_LIMIT above 262,144 tokens and accepts exactly 262,144 (built in test code, below 1,048,576 bytes)`

The plan cites this test by the leading part of its title, `reports PYTHON_TOKEN_LIMIT above 262,144 tokens`. It is excluded because the root-cause profile extrapolates it to about 49,530 s on the unfixed module.

`Filter.FullName` holds the template spellings of the other 11 paths from discovery of 12 template paths (29 expanded tests), so the data-driven tests are listed as, for example, `reports <Code> as a blocking error for: <Case>`.

## Coverage Detail

| Metric | Covered | Missed | Percent |
| --- | --- | --- | --- |
| Line (`MODULE`) | 126 | 2 | 98.44 |
| Command (`MODULE`, informational) | 241 | 13 | 94.88 |

The two uncovered lines are the `PYTHON_TOKEN_LIMIT` diagnostic and its `return` in `Get-DocsPythonToken`, which only the excluded test reaches. This baseline therefore understates full-suite line coverage of `MODULE` by those two lines.

## Earlier Attempt

A first attempt ended at its 570 s bound (exit 124) and produced no counts or coverage. Its helper used a `-notlike` pattern with no trailing wildcard, which did not match the longer full title, so the token-limit test remained selected (12 of 12 template paths kept). The helper was corrected and now throws unless exactly one template path is removed. No figure above comes from that attempt, and no leftover process remained.
