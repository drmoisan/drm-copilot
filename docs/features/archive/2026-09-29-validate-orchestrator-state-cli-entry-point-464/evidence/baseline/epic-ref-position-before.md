# Epic Ref Position Before (Issue #464)

Timestamp: 2026-09-30T08-15
Command: git rev-list --left-right --count origin/epic/orchestrator-state-contract-correctness-integration...HEAD
Command: git merge-base HEAD origin/epic/orchestrator-state-contract-correctness-integration
EXIT_CODE: 0 (both commands)
Output Summary:
- Left/right count: `1	3` (left = 1, right = 3).
- Merge-base SHA: 5b09b53899ac9dad870f855cbcc359098266e213
- The left count is non-zero, so per P0-T2 every later diff task (P3-T5, P8-T9, P8-T10) uses the merge-base SHA above as the ref operand in place of the branch ref.
