# QA Gate — Pinned Worktree Assertions Unmodified (Issue #630)

Timestamp: 2026-09-07T14-30

Task: [P7-T9]

Command: `git diff origin/epic/cleanup-merged-worktrees-hardening-integration -- tests/shell/test_cleanup_worktrees_classification.bats tests/shell/test_cleanup_worktrees_cli.bats tests/shell/test_cleanup_worktrees_hard_failures.bats tests/shell/test_cleanup_worktrees_enumeration.bats | awk '/^[-+]/ && /WORKTREE/ {n++} END {print n+0}'`

EXIT_CODE: 0

Working directory: `C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-adf4f49cbc48904be`

## Command Substitution

None for the invocation form. [P7-T9] names no `wsl -d Ubuntu -- bash -lc '...'` wrapper;
the commands run natively. The plan's stale worktree path `agent-a06652a3fd875c703` does not
appear in this task's commands; they ran in the real worktree `agent-adf4f49cbc48904be`.

## Span 1 — The Anchored Diff Counted Through awk

The diff is anchored to the base ref `origin/epic/cleanup-merged-worktrees-hardening-integration`,
so it compares the feature branch against the branch point rather than against ambient index
state. The `awk` stage counts every added or removed line that carries the token `WORKTREE`.

Raw output:

```
0
```

A count of **0** means **no added and no removed line** in any of those four files carries a
`WORKTREE` assertion. The pinned assertions in the pre-existing suites are therefore
unmodified. The four files are not untouched overall — [P4-T5] and [P4-T6] added a `DLIB`
binding and extended two helper source chains in the classification and hard-failures
suites, and [P2-T19] appended one case to the CLI suite — but none of those edits added or
removed a line containing `WORKTREE`. [P2-T19] required the appended CLI case to contain no
occurrence of the literal `WORKTREE`, in code or in a comment, precisely so this count would
remain 0.

## Span 2 — The Enumeration Suite Diff

Command: `git diff origin/epic/cleanup-merged-worktrees-hardening-integration -- tests/shell/test_cleanup_worktrees_enumeration.bats`

EXIT_CODE: 0

```
```

The diff produced **0 lines**, that is an **empty diff against the base ref**.
`tests/shell/test_cleanup_worktrees_enumeration.bats` is byte-for-byte unchanged by this
feature. That is what the plan's Test Contract predicted: the enumeration suite's cases call
`parse_worktree_list` and `compute_protected` directly and never reach `run_report`, so they
needed no helper source-chain update.

Output Summary: The `awk` stage printed **`0`**: no added or removed line in
`test_cleanup_worktrees_classification.bats`, `test_cleanup_worktrees_cli.bats`,
`test_cleanup_worktrees_hard_failures.bats`, or `test_cleanup_worktrees_enumeration.bats`
carries a `WORKTREE` assertion, so every pinned assertion in the pre-existing suites is
unmodified. Additionally, `tests/shell/test_cleanup_worktrees_enumeration.bats` has an
**empty diff against the base ref** and is entirely unchanged. This is the evidence for AC5
and AC6.
