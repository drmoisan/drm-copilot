# Git Baseline (Issue #849)

Timestamp: 2026-10-10T09-50
Task: P0-T2
Command: git rev-parse --abbrev-ref HEAD; git rev-parse HEAD; git rev-parse origin/main; git merge-base HEAD origin/main; git diff --name-status --merge-base origin/main; git status --porcelain
EXIT_CODE: 0

Each command was run separately from the worktree root; every command exited 0.

## Values

- Branch: bug/parallel-items-fail-completion-on-promotion-receipts-849
- HEAD: 3412e7f5a11bf6729f789e54a45e529514eff8dc
- origin/main tip: 793731a12e0aafb5f6eb645fffa072d941797de1
- BASE_SHA (git merge-base HEAD origin/main): 793731a12e0aafb5f6eb645fffa072d941797de1

## BASE_DIFF (git diff --name-status --merge-base origin/main, verbatim)

```text
A	docs/features/active/2026-10-08-parallel-items-fail-completion-on-promotion-receipts-849/issue.md
A	docs/features/active/2026-10-08-parallel-items-fail-completion-on-promotion-receipts-849/plan.2026-10-09T01-33.md
A	docs/features/active/2026-10-08-parallel-items-fail-completion-on-promotion-receipts-849/research/research.2026-10-09T05-40.md
A	docs/features/active/2026-10-08-parallel-items-fail-completion-on-promotion-receipts-849/spec.md
A	docs/features/potential/promoted/2026-10-08-parallel-items-fail-completion-on-promotion-receipts.md
```

## BASE_PORCELAIN (git status --porcelain, verbatim)

```text
 M docs/features/active/2026-10-08-parallel-items-fail-completion-on-promotion-receipts-849/plan.2026-10-09T01-33.md
?? docs/features/active/2026-10-08-parallel-items-fail-completion-on-promotion-receipts-849/evidence/
```

The two porcelain entries are this run's own P0-T1 outputs (the plan check-off and the evidence folder holding the P0-T1 artifact); the worktree was clean at the start of the run.

Output Summary: Branch matches bug/parallel-items-fail-completion-on-promotion-receipts-849. BASE_SHA = 793731a12e0aafb5f6eb645fffa072d941797de1 (equals the origin/main tip; HEAD 3412e7f5a is the merge of origin/main into the branch). BASE_DIFF lists 5 added documentation files and no source, test, or fixture change. BASE_PORCELAIN lists only P0-T1 outputs.
