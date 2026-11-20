# r2c2 PR #384 Mergeability Check

Timestamp: 2026-07-18T22-58

Command: `gh pr view 384 --json mergeable,mergeStateStatus`

EXIT_CODE: 0

Output Summary:
- Raw output: `{"mergeStateStatus":"UNSTABLE","mergeable":"MERGEABLE"}`
- `mergeable` = MERGEABLE (not CONFLICTING or UNKNOWN). Acceptance satisfied.
- `mergeStateStatus` = UNSTABLE indicates required or non-required status checks were still in progress at query time; it does not indicate a merge conflict. The branch has no conflict with its base.
- Query run after pushing local HEAD `5a3ea0fc` (and, following the final plan-checklist commit, HEAD updated as recorded in the completion report). The bundle push-down commit `245e537e` and evidence commit `5a3ea0fc` are present on the remote branch.
