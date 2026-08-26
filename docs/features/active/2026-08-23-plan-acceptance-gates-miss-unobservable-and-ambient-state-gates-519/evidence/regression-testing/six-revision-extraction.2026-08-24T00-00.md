# Six-Revision Extraction — [P5-T1]

Timestamp: 2026-08-26T13-16
Task: [P5-T1]
Command: `git show <commit>:docs/features/active/2026-08-21-get-plan-paths-extracts-angle-bracket-placeholders-as-paths-502/plan.2026-08-22T22-57.md`, run once per commit as six plain, separate invocations
Working directory: `C:/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-a2c2e891a6977ab65`
EXIT_CODE: 0

Every invocation was issued as a bare `git` command with an explicit `-C` worktree operand and its exit code captured directly with `echo "EXIT=$?"` immediately after the redirect. No pipe stands between the command and the exit-code capture, so no failure could have been converted into a pass by a pipe's last-stage status.

The repo-relative path is the **active**-tree path as it stood at each of the six commits. The plan file has since been archived to the `docs/features/completed/...` tree, which is why the current path is not used; [P0-T14] records that separation explicitly.

## The six extraction commands and their exit codes

| # | Commit | Command | EXIT_CODE | Extracted line count |
| --- | --- | --- | --- | --- |
| 1 | `e2aa6446` | `git show e2aa6446:docs/features/active/2026-08-21-get-plan-paths-extracts-angle-bracket-placeholders-as-paths-502/plan.2026-08-22T22-57.md` | 0 | 266 |
| 2 | `eff8f196` | `git show eff8f196:docs/features/active/2026-08-21-get-plan-paths-extracts-angle-bracket-placeholders-as-paths-502/plan.2026-08-22T22-57.md` | 0 | 267 |
| 3 | `30414365` | `git show 30414365:docs/features/active/2026-08-21-get-plan-paths-extracts-angle-bracket-placeholders-as-paths-502/plan.2026-08-22T22-57.md` | 0 | 268 |
| 4 | `e913e0a9` | `git show e913e0a9:docs/features/active/2026-08-21-get-plan-paths-extracts-angle-bracket-placeholders-as-paths-502/plan.2026-08-22T22-57.md` | 0 | 293 |
| 5 | `ceacb5a5` | `git show ceacb5a5:docs/features/active/2026-08-21-get-plan-paths-extracts-angle-bracket-placeholders-as-paths-502/plan.2026-08-22T22-57.md` | 0 | 293 |
| 6 | `5a8ede0f` | `git show 5a8ede0f:docs/features/active/2026-08-21-get-plan-paths-extracts-angle-bracket-placeholders-as-paths-502/plan.2026-08-22T22-57.md` | 0 | 297 |

Six extraction commands, six exit codes, six line counts. All six exited 0, so the conditional branch of this task's acceptance — recording a failed extraction with its exact command and output rather than substituting another commit — is not triggered. No extraction failed and no commit was substituted.

## Verbatim `wc -l` output

The line counts above were read from a single `wc -l` invocation over the six extracted texts:

```
   266 .../scratchpad/rev-e2aa6446.md
   267 .../scratchpad/rev-eff8f196.md
   268 .../scratchpad/rev-30414365.md
   293 .../scratchpad/rev-e913e0a9.md
   293 .../scratchpad/rev-ceacb5a5.md
   297 .../scratchpad/rev-5a8ede0f.md
  1684 total
EXIT=0
```

The extracted texts are written to the session scratchpad rather than into the repository, because they are input to the throwaway regression driver of [P5-T2] and are not themselves deliverables. The driver of [P5-T2] does not read those files: it re-runs the same six `git show` commands itself, so the texts it judges are read from git object storage rather than from an intermediate copy that could drift.

## Observation beyond the exit code

`git show` against a path that does not exist at a commit exits non-zero and writes nothing to stdout, so a zero exit paired with a non-zero line count is the observation that distinguishes a real extraction from a silent empty one. All six line counts are non-zero and lie in the range 266 to 297.

The counts are also not all equal, which is the second observation this task supports: the six revisions are genuinely different texts, growing monotonically in size across the authored sequence (266, 267, 268, 293, 293, 297). Revisions 4 and 5 share a line count of 293 but are not thereby identical; [P5-T5] compares acceptance text by content rather than by length.

## Output Summary

All six `git show` extractions of the issue #502 plan succeeded with EXIT_CODE 0. Extracted line counts: `e2aa6446` 266, `eff8f196` 267, `30414365` 268, `e913e0a9` 293, `ceacb5a5` 293, `5a8ede0f` 297; 1684 lines in total. No extraction failed, so no commit was substituted and no shortfall is carried forward.
