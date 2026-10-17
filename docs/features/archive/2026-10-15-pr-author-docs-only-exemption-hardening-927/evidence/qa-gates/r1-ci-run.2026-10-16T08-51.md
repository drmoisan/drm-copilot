# R1 CI Run on the Final Code Commit (Issue #927, PA-1)

Timestamp: 2026-10-16T08-51
Command: git rev-parse HEAD
EXIT_CODE: 0
Output Summary: Local HEAD equals the origin branch head 7966e1564635b5e4f60c22eeac47932018ae264a (the head pushed by [P7-T12]). ci.yml was dispatched once on the branch; the newest workflow_dispatch run with that headSha is 38876469175. Run 38855083321 (head 620a2e966) is not used for PA-1.

LOCAL_HEAD: 7966e1564635b5e4f60c22eeac47932018ae264a

Command 2: git rev-parse origin/bug/pr-author-docs-only-exemption-hardening-927
EXIT_CODE_2: 0
ORIGIN_HEAD: 7966e1564635b5e4f60c22eeac47932018ae264a
R1_FINAL_CODE_COMMIT: 7966e1564635b5e4f60c22eeac47932018ae264a

Command 3: gh workflow run ci.yml --ref bug/pr-author-docs-only-exemption-hardening-927
EXIT_CODE_3: 0
DISPATCH_OUTPUT: run URL for run 38876469175

Command 4: gh run list --workflow ci.yml --branch bug/pr-author-docs-only-exemption-hardening-927 --event workflow_dispatch --json databaseId,headSha,status,conclusion,createdAt --limit 10
EXIT_CODE_4: 0
LIST_OUTPUT: [{"conclusion":"","createdAt":"2026-10-16T08:51:19Z","databaseId":38876469175,"headSha":"7966e1564635b5e4f60c22eeac47932018ae264a","status":"queued"},{"conclusion":"success","createdAt":"2026-10-16T05:18:26Z","databaseId":38855083321,"headSha":"620a2e966129dd4b68e8aed9b6397c33bb0080ff","status":"completed"}]
R1_CI_RUN_ID: 38876469175
R1_CI_RUN_HEADSHA: 7966e1564635b5e4f60c22eeac47932018ae264a
