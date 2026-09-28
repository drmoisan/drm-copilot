# Gate — AC-37, the hooks tree carries no diff

Timestamp: 2026-09-08T11-55
Task: `[P9-T2]`
Command: git diff --stat epic/cleanup-merged-worktrees-hardening-integration -- .claude/hooks
EXIT_CODE: 0
ExpectedExitCode: 0
Output Summary: both invocations printed nothing and both exited 0. The `diff --stat` invocation
exited 0 with empty output; the `git status --porcelain -- .claude/hooks` invocation exited 0 with
empty output.

The hooks tree is owned by three sibling children of this epic. Nothing in this work reads or writes
it. The pairing of an anchored diff with a porcelain status is used here for the same reason as in
`[P9-T1]`: each alone is blind in one state, and both being empty covers both.

Verdict: PASS.
