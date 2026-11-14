# [P6-T18] Forbidden-token scan

Timestamp: 2026-11-05T23-03
Command: grep -i -n -e 'r[g]f' -e 'fore[c]ast' <each file of SCRATCH/issue-1031-scan-files.txt> (run through xargs -0)
EXIT_CODE: 123
Output Summary: zero matches across 146 files. xargs reports 123 because grep exited 1 (no match) in its invocation; no error was printed. A positive control (SCRATCH/issue-1031-control.txt) returns 1 matching line under the same patterns, so the scan can fail.

## File set

- The [P6-T17] union: 144 paths from `git diff --name-only MERGE_BASE`, taken after the [P6-T17] commit, so the plan, `qa-scope` and every evidence file committed so far are included. `git status --porcelain --untracked-files=all` was empty.
- Every file under `FEATURE/evidence/` on disk (75). Two of them predate `MERGE_BASE` and so are outside the diff: `evidence/other/preflight-fixes.2026-10-31T05-21.md` and `evidence/other/preflight-status.2026-10-31T16-43.md`.
- Union after de-duplication: 146 files.

`MERGE_BASE` = `git merge-base origin/epic/documentation-estate-tooling-integration HEAD`. Patterns are quoted only in bracket-class form. The search is a plain filesystem search, so it covers untracked files.
