# Candidate Hunk Identity - Issue 1019

Timestamp: 2026-11-06T18-09
Command: sh SCRATCH/issue-1019-p1-suite.sh (SCRATCH/issue-1019-hunkcheck.ps1 -Patch SCRATCH/issue-1019-candidate.patch, whole-line ordinal comparison including indentation, run on the module with the [P1-T2] window edits in place)
EXIT_CODE: 0
Output Summary: hunk failures 0. Every added line of the CANDIDATE patch is present byte for byte and in patch order, and every removed line is absent, for both paths.

CANDIDATE: 1332ba34f3fee7a6f1ca14534ab8b970dffce559, subject `fix(docs): stop passing the whole source to .NET calls in the Python tokenizer`, derived with `git log -n 1 --format=%H --grep=stop.passing.the.whole.source origin/feature/docs-enforcement-and-ci-1034-r2`.

The patch was taken from the CANDIDATE commit with `git show --format=` limited to `MODULE` and `SUITE`, then applied with `git apply` to the unmodified files. The plan-file hunk under the 1034 feature folder and the bundle hunk were not taken.

| File | Added lines | Missing | Out of order | Removed lines | Still present |
| --- | --- | --- | --- | --- | --- |
| `.claude/lib/docs/DocsPythonTokens.psm1` | 12 | 0 | 0 | 3 | 0 |
| `tests/scripts/claude-lib/docs/DocsPythonTokens.Tests.ps1` | 41 | 0 | 0 | 0 | 0 |

`SUITE` contains the test `passes the whole source to a .NET method only at the restart after a string token` unedited: its lines are among the 41 added lines checked above.

MODULE SHA-256 at this check: 6010cf357e5816136cf60b8d0e7dcf52f85555c42c7ec37b7e65883493ab9cbf
