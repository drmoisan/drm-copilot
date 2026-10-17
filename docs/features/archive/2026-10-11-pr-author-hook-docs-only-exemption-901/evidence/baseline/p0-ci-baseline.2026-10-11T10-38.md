# P0-T9 CI coverage reference for the base

Timestamp: 2026-10-12T18-23
Command: gh run list --workflow ci.yml --branch main --commit 7d9a5c33526d7a98d5577ab4a9ad6f465f3dff3c --json databaseId,conclusion,headSha --limit 1
EXIT_CODE: 0
Output Summary:
- One element returned; headSha equals MERGE_BASE (7d9a5c33526d7a98d5577ab4a9ad6f465f3dff3c).
- conclusion was an empty string at capture time (the run had not completed). The AC-9 comparison reads this run's poshqc-test-results artifact once it completes, or the base-branch run CI reports for the pull request.
- Result: PASS

BASELINE_CI_RUN_ID: 38315946747
BASELINE_CI_CONCLUSION: pending (empty conclusion at capture time)
