# Non-Blocking Deviation: Merge Base Derivation (AD-7)

Timestamp: 2026-11-19T07-42
Plan: plan.2026-10-30T18-39.md
Deviation: wherever the plan derives MB as the merge base of origin/main and HEAD (P0-T1 anchor re-check, P2-T5 changed lines, P2-T6 stale-reference comparison, P2-T7 added files and ledger commits, P2-T9 self-review diff), this run derives MB as the merge base of origin/epic/shared-agent-harness-layer-integration and HEAD, after git fetch origin epic/shared-agent-harness-layer-integration.
Authority: orchestrator decision AD-7 for epic #1018 child 6. This branch is cut from the integration branch, so a diff from the origin/main merge base would include unrelated epic commits.
Classification: non-blocking.
P0-T1 anchor re-checks read the files at HEAD; at P0-T1, MB equalled HEAD.
