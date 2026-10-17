# Baseline: git merge-base and working-tree state ([P0-T4])

Timestamp: 2026-10-09T20-56
Command: git fetch origin main
EXIT_CODE: 0
Output Summary: Fetched origin main ("From https://github.com/drmoisan/drm-copilot * branch main -> FETCH_HEAD").

## Block 2

Command: git rev-parse HEAD
EXIT_CODE: 0
Output Summary: fe8de4c475eb24b1171cf49661ea9c8d90cbe905 (merge commit of origin/main into bug/bug-burndown-2026-09-29-review-nits-846).

## Block 3

Command: git merge-base HEAD origin/main
EXIT_CODE: 0
Output Summary: one 40-character SHA printed: 311dea0548cb2e2fe57259aec6e1e3a06a9bdd2a

Merge-Base: 311dea0548cb2e2fe57259aec6e1e3a06a9bdd2a

Merge-base substitution (plan Conventions and deviation D-3 recorded-value rule): the plan-time SHA was e7d3779b398604af919678c16c877c8539a86cc0. origin/main moved after planning and the branch was merged with origin/main (merge commit fe8de4c47), so the recorded value differs. Every later anchored command in this plan uses 311dea0548cb2e2fe57259aec6e1e3a06a9bdd2a in place of e7d3779b398604af919678c16c877c8539a86cc0, and each affected artifact records the substitution. The orchestrator reported that main brought no changes to any file this plan writes, and that item #844 already split extensions/drm-copilot/test/lib/validate/orchestration-handoff-authority-service.test.ts (now 154 lines); that file remains protected and is not touched.

## Block 4

Command: git status --porcelain --untracked-files=all
EXIT_CODE: 0
Output Summary: two entries, both Phase 0 writes made by this executor before the command ran (the [P0-T1] to [P0-T3] plan check-offs and the [P0-T3] artifact); no other modified or untracked path.

```
 M docs/features/active/2026-10-08-bug-burndown-2026-09-29-review-nits-846/plan.2026-10-08T23-42.md
?? docs/features/active/2026-10-08-bug-burndown-2026-09-29-review-nits-846/evidence/baseline/phase0-instructions-read.md
```

Pre-existing inputs (D-10): the feature folder issue.md, the research file research/research.2026-10-08T23-50.md, and the promoted potential-bug record do not appear in the porcelain output, so they are tracked at HEAD.
