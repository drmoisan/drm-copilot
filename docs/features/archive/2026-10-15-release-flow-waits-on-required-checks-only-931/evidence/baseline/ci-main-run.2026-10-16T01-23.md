# Baseline CI Run on main (Issue #931)

Timestamp: 2026-10-16T01-23
Command: gh run list --workflow ci.yml --branch main --event push --status success --limit 1 --json databaseId,headSha,conclusion,url,createdAt
EXIT_CODE: 0
Output Summary: RUN_ID 38730332356, RUN_SHA adb9aa5f02fc0ae84fd7e6060f758a8b0974eb99, conclusion success. The run carries the `poshqc-test-results` artifact (downloaded in P0-T21), so no `--limit 5` re-run was needed. RUN_SHA equals BASE.

Output:

```json
[{"conclusion":"success","createdAt":"2026-10-15T11:51:32Z","databaseId":38730332356,"headSha":"adb9aa5f02fc0ae84fd7e6060f758a8b0974eb99","url":"https://github.com/drmoisan/drm-copilot/actions/runs/38730332356"}]
```

RUN_ID: 38730332356
RUN_SHA: adb9aa5f02fc0ae84fd7e6060f758a8b0974eb99
conclusion: success
url: https://github.com/drmoisan/drm-copilot/actions/runs/38730332356

RUN_SHA equals the merge base `BASE` recorded in `git-base.2026-10-16T00-12.md`.
