# Git Baseline (Remediation Cycle 1)

Timestamp: 2026-10-01T16-25
Task: [P0-T3]
Location: worktree root

## 1. Fetch

Command: `git fetch origin epic/orchestrator-state-contract-correctness-integration bug/promotion-gate-lacks-preexisting-issue-branch-exec-509`
EXIT_CODE: 0
Output Summary: both refs fetched (`-> FETCH_HEAD`).

## 2. Local branch name

Command: `git rev-parse --abbrev-ref HEAD`
EXIT_CODE: 0
Output Summary: `worktree-agent-a554484c9146de973` (an accepted local name per the plan).

## 3. Head

Command: `git rev-parse HEAD`
EXIT_CODE: 0
Output Summary: `0da1df8af73ebadc09e5fd5e4bbd93772bc84bf7`, recorded as `RB_HEAD_SHA`.

## 4. Remote branch tip is an ancestor of HEAD

Command: `git merge-base --is-ancestor origin/bug/promotion-gate-lacks-preexisting-issue-branch-exec-509 HEAD`
EXIT_CODE: 0
Output Summary: ancestor (remote tip `0da1df8af73ebadc09e5fd5e4bbd93772bc84bf7` equals HEAD), so pushes are fast-forwards. No `BLOCKED: WRONG BRANCH`.

## 5. Remediation start commit is an ancestor of HEAD

Command: `git merge-base --is-ancestor 0aff3f47802bd57cb41e22a2dd61d8cdf91aa070 HEAD`
EXIT_CODE: 0
Output Summary: ancestor. No `BLOCKED: REMEDIATION BASE NOT AN ANCESTOR`.

## 6. Merged integration commit is an ancestor of HEAD

Command: `git merge-base --is-ancestor bb03e697f57551fa301c564f6984632309c1a0df HEAD`
EXIT_CODE: 0
Output Summary: ancestor.

## 7. Fetched integration tip

Command: `git rev-parse origin/epic/orchestrator-state-contract-correctness-integration`
EXIT_CODE: 0
Output Summary: fetched tip SHA `251c7a640ba37398d98249b88e6902f40e5afabf`.

## 8. Integration advance since bb03e697

Command: `git diff --name-only bb03e697f57551fa301c564f6984632309c1a0df origin/epic/orchestrator-state-contract-correctness-integration`
EXIT_CODE: 0
Output Summary (verbatim):

```text
docs/features/epics/orchestrator-state-contract-correctness/epic-status.md
```

The only listed path is under `docs/features/epics/orchestrator-state-contract-correctness/`, an epic-folder-only advance that this cycle does not merge. No `BLOCKED: INTEGRATION TIP NOT MERGED`.

## 9. Porcelain status

Command: `git status --porcelain`
EXIT_CODE: 0
Output Summary (verbatim):

```text
 M docs/features/active/2026-08-22-promotion-gate-lacks-preexisting-issue-branch-509/remediation-plan.2026-09-30T15-25.md
?? docs/features/active/2026-08-22-promotion-gate-lacks-preexisting-issue-branch-509/evidence/remediation-baseline/
```

Both paths are under the feature folder (plan check-offs and the Phase 0 artifacts written so far). No path outside the feature folder.
