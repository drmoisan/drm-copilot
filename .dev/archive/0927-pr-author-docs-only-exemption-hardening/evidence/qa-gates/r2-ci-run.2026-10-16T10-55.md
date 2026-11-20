# R2 CI Run Dispatch (Issue #927)

Timestamp: 2026-10-16T10-55
Command: git rev-parse HEAD
EXIT_CODE: 0
Output Summary: HEAD equals origin (7b43fddd540dcb5243f0b888891c35d315d6c454). Every path changed since R2_FINAL_CODE_COMMIT and every status line is under the #927 feature folder. The ci.yml dispatch exited 0, and the matching workflow_dispatch run is 38890377723.

## Commands

- Command 1: `git rev-parse HEAD`
  - Output: `7b43fddd540dcb5243f0b888891c35d315d6c454`
- Command 2: `git rev-parse origin/bug/pr-author-docs-only-exemption-hardening-927`
  - EXIT_CODE_2: 0
  - Output: `7b43fddd540dcb5243f0b888891c35d315d6c454`
- Command 3: `git diff --name-only bf3c5e310387807ffc6f9689ca567a7b9c87d69b HEAD`
  - EXIT_CODE_3: 0
  - Output: 11 paths, all under `docs/features/active/2026-10-15-pr-author-docs-only-exemption-hardening-927/` (the ten R2 Phase 3 and Phase 4 evidence files and this plan file)
- Command 4: `git status --porcelain`
  - EXIT_CODE_4: 0
  - Output: ` M docs/features/active/2026-10-15-pr-author-docs-only-exemption-hardening-927/remediation-plan.2026-10-16T11-20.md`
- Command 5: `gh workflow run ci.yml --ref bug/pr-author-docs-only-exemption-hardening-927`
  - EXIT_CODE_5: 0
  - Output: run URL for run 38890377723
- Command 6: `gh run list --workflow ci.yml --branch bug/pr-author-docs-only-exemption-hardening-927 --event workflow_dispatch --json databaseId,headSha,status,conclusion,createdAt --limit 10`
  - EXIT_CODE_6: 0
  - Newest row whose headSha equals R2_CI_HEAD: `{"databaseId":38890377723,"headSha":"7b43fddd540dcb5243f0b888891c35d315d6c454","status":"queued","createdAt":"2026-10-16T10:55:12Z"}`

R2_CI_HEAD: 7b43fddd540dcb5243f0b888891c35d315d6c454
R2_CI_RUN_ID: 38890377723
