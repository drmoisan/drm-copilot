# Git baseline (P0-T3)

Timestamp: 2026-09-30T07-13

EVIDENCE_LOCATION_OVERRIDE_REJECTED: not applicable (all evidence is under the canonical feature evidence path).

BRANCH_NAME_NOTE: the plan expects branch name `bug/ts-validator-promotion-type-parity-gap-405`. That branch is checked out in another locked worktree, so this execution runs on the local branch `worktree-agent-aabf208274ce507ac` at the integration tip. The work is pushed to remote ref `bug/ts-validator-promotion-type-parity-gap-405` as a fast-forward (`git push origin HEAD:refs/heads/bug/ts-validator-promotion-type-parity-gap-405`). This is an orchestrator-approved substitution, not a failure.

## Command 1
Command: git rev-parse --abbrev-ref HEAD
EXIT_CODE: 0
Output Summary: worktree-agent-aabf208274ce507ac

## Command 2
Command: git rev-parse HEAD
EXIT_CODE: 0
Output Summary: cbb53d7a06fd4a1bbb2b0fe983dd3b3b6f0be1c7

## Command 3
Command: git rev-parse origin/main
EXIT_CODE: 0
Output Summary: ae7c7779a1e9a30c619890074ad6a81896449022

## Command 4
Command: git status --porcelain
EXIT_CODE: 0
Output Summary: the tree was clean at session start (gitStatus snapshot: clean). At the time of this command the only entry was the untracked directory created by this phase:
```
?? docs/features/active/2026-09-29-ts-validator-promotion-type-parity-gap-405/evidence/baseline/
```

## Command 5
Command: git diff --name-only origin/main
EXIT_CODE: 0
Output Summary: pre-existing committed set that P5-T18 allows (29 paths, verbatim, run before any source edit). It includes both epic paths named in Scope-of-the-diff item 10 (`docs/features/epics/orchestrator-state-contract-correctness/epic.md` and `docs/features/potential/promoted/2026-09-29-orchestrator-state-contract-correctness.md`).
```
docs/features/active/2026-08-22-promotion-gate-lacks-preexisting-issue-branch-509/evidence/other/preflight-clearance.2026-09-29T22-55.md
docs/features/active/2026-08-22-promotion-gate-lacks-preexisting-issue-branch-509/issue.md
docs/features/active/2026-08-22-promotion-gate-lacks-preexisting-issue-branch-509/plan.2026-09-29T15-26.md
docs/features/active/2026-08-22-promotion-gate-lacks-preexisting-issue-branch-509/research/research.2026-09-29T15-15.md
docs/features/active/2026-08-22-promotion-gate-lacks-preexisting-issue-branch-509/spec.md
docs/features/active/2026-09-29-blocked-reason-premise-falsified-halt-523/evidence/other/preflight-clearance.2026-09-29T22-55.md
docs/features/active/2026-09-29-blocked-reason-premise-falsified-halt-523/issue.md
docs/features/active/2026-09-29-blocked-reason-premise-falsified-halt-523/plan.2026-09-29T15-52.md
docs/features/active/2026-09-29-blocked-reason-premise-falsified-halt-523/research/2026-09-29T16-00-blocked-reason-halt-representation-research.md
docs/features/active/2026-09-29-blocked-reason-premise-falsified-halt-523/spec.md
docs/features/active/2026-09-29-orchestrator-remediation-loop-control-484/evidence/other/preflight-clearance.2026-09-29T22-55.md
docs/features/active/2026-09-29-orchestrator-remediation-loop-control-484/issue.md
docs/features/active/2026-09-29-orchestrator-remediation-loop-control-484/plan.2026-09-29T17-35.md
docs/features/active/2026-09-29-orchestrator-remediation-loop-control-484/research/2026-09-29T17-50-remediation-loop-verdict-research.md
docs/features/active/2026-09-29-orchestrator-remediation-loop-control-484/spec.md
docs/features/active/2026-09-29-ts-validator-promotion-type-parity-gap-405/evidence/other/preflight-clearance.2026-09-29T22-55.md
docs/features/active/2026-09-29-ts-validator-promotion-type-parity-gap-405/issue.md
docs/features/active/2026-09-29-ts-validator-promotion-type-parity-gap-405/plan.2026-09-29T14-19.md
docs/features/active/2026-09-29-ts-validator-promotion-type-parity-gap-405/research/research.2026-09-29T14-30.md
docs/features/active/2026-09-29-ts-validator-promotion-type-parity-gap-405/spec.md
docs/features/active/2026-09-29-validate-orchestrator-state-cli-entry-point-464/evidence/other/preflight-clearance.2026-09-29T22-55.md
docs/features/active/2026-09-29-validate-orchestrator-state-cli-entry-point-464/issue.md
docs/features/active/2026-09-29-validate-orchestrator-state-cli-entry-point-464/plan.2026-09-29T14-20.md
docs/features/active/2026-09-29-validate-orchestrator-state-cli-entry-point-464/research/2026-09-29T14-35-cli-entry-point-research.md
docs/features/active/2026-09-29-validate-orchestrator-state-cli-entry-point-464/spec.md
docs/features/epics/orchestrator-state-contract-correctness/epic-kickoff.md
docs/features/epics/orchestrator-state-contract-correctness/epic-status.md
docs/features/epics/orchestrator-state-contract-correctness/epic.md
docs/features/potential/promoted/2026-09-29-orchestrator-state-contract-correctness.md
```
