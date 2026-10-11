# P0-T2 Base Ref

Timestamp: 2026-10-09T20-00
Command: git rev-parse --abbrev-ref HEAD; git rev-parse HEAD; git rev-parse origin/main; git merge-base HEAD origin/main; git diff --merge-base --name-only origin/main; git status --porcelain (each run as a separate call)
EXIT_CODE: 0
Output Summary: Branch is the bug/...-793 branch. HEAD is ahead of origin/main (merge base equals origin/main). The merge-base diff lists only feature-folder documents and the promoted record. Porcelain lists only the feature-folder evidence directory (untracked).

BRANCH: bug/epic-orchestrator-state-validator-crashes-on-unhashable-merge-status-793
HEAD_SHA: 86641448de24a06ad65833cca4f2521b8e6023b0
ORIGIN_MAIN_SHA: 6874389b303dea9f81dc3e7d1bfcfb9fa1e9ee9b
MERGE_BASE_SHA: 6874389b303dea9f81dc3e7d1bfcfb9fa1e9ee9b

PRE_EXISTING_PREPARATION_PATH: docs/features/potential/promoted/2026-09-30-epic-orchestrator-state-validator-crashes-on-unhashable-merge-status.md

## git diff --merge-base --name-only origin/main

```
docs/features/active/2026-09-30-epic-orchestrator-state-validator-crashes-on-unhashable-merge-status-793/issue.md
docs/features/active/2026-09-30-epic-orchestrator-state-validator-crashes-on-unhashable-merge-status-793/plan.2026-10-08T13-57.md
docs/features/active/2026-09-30-epic-orchestrator-state-validator-crashes-on-unhashable-merge-status-793/research/research.2026-10-08T14-00.md
docs/features/active/2026-09-30-epic-orchestrator-state-validator-crashes-on-unhashable-merge-status-793/spec.md
docs/features/potential/promoted/2026-09-30-epic-orchestrator-state-validator-crashes-on-unhashable-merge-status.md
```

## git status --porcelain

```
?? docs/features/active/2026-09-30-epic-orchestrator-state-validator-crashes-on-unhashable-merge-status-793/evidence/
```
