# Git Attached-Selector Probe (research open question Q1) — issue #671

Timestamp: 2026-09-17T07-54
Task: [P0-T5]
Command: git -Cfoo status
EXIT_CODE: 2
ExpectedExitCode: 2
Status: INCOMPLETE — the invocation was refused by a PreToolUse hook before git ran.

Output Summary:
The command was issued twice through the Bash tool, first as `git -Cfoo status; echo "EXIT=$?"` and then as the single plain command `git -Cfoo status`. Both attempts were refused before git ran, with this verbatim text:

```
PARALLEL_WORKTREE_REMOVAL_BLOCKED: git worktree remove for '' requires a matching parallel checkpoint items[] record with merge_status in {merged, worktree_removed}. The checkpoint was unreadable, no matching record was found, or merge_status was not yet safe for removal.
```

Git did not answer, so this artifact cannot state whether git accepts the attached spelling `-C<dir>`. The value `2` recorded above is the PreToolUse block convention, not a git exit status: the tool surfaced only the refusal text and no process exit status. The refusal appears to come from the parallel-worktree-removal guard misclassifying the `-C`-prefixed git invocation.

Design impact: none. LACS denies the attached spelling in either case; row 10 of the fail-before reproduction (`git -CC:/repo/wt add ...`) returned `False`, and the Pester deny row `issue #671 LACS L1a - attached selector spelling` covers it.
