# Baseline git reference for every diff-based acceptance gate

Timestamp: 2026-08-20T09-53

Task: [P0-T3]

Command: git merge-base HEAD main ; git rev-parse HEAD
EXIT_CODE: 0

## Recorded SHAs

- `git merge-base HEAD main` = `71aebdb9a1e4752b191b3c9d4e677b807ea6fdec`
- `git rev-parse HEAD` = `468dbe1e7241de1bdb8bfd272fd3f8ef8b179ff6`

Branch: `bug/pr-context-verification-cannot-express-expected-nonzero-exit-485`
Worktree: `C:/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-ad8da196d6247bdf4`

`HEAD` is exactly one commit ahead of the merge-base; that single commit added this feature's
documents (`issue.md`, `spec.md`, `research/`, `plan.2026-08-17T15-00.md`) and touched no production
or test file.

## Baseline reference used by the plan's diff gates

`<baseline-ref>` in [P5-T1], [P5-T5], [P5-T6], [P6-T8], [P7-T8], [P7-T12], and [P8-T11] resolves to
the merge-base SHA `71aebdb9a1e4752b191b3c9d4e677b807ea6fdec`. Because that SHA is also the
`origin/main` tip named in the delegation prompt, a diff against the merge-base and a diff against
`main` (the form quoted in `spec.md` AC12, AC13, AC20, AC21, AC25) are equivalent for this branch,
so each gate measures exactly the lines this change adds.

Output Summary: Both SHAs recorded. Merge-base `71aebdb9a1e4752b191b3c9d4e677b807ea6fdec` equals
the `origin/main` tip; `HEAD` is `468dbe1e7241de1bdb8bfd272fd3f8ef8b179ff6`, one documents-only
commit ahead. All later diff gates use the merge-base SHA as `<baseline-ref>`.
