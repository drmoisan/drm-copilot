# P0-T11 — Baseline CI shell coverage (`_shell-coverage.yml`)

Timestamp: 2026-09-27T01-27
Task: [P0-T11]
Working directory: repository worktree root
Branch: `bug/cleanup-worktrees-apply-deletes-local-main-594`
Pushed HEAD: `b5f98be268c8c9e0752027486f6500f0a6fa26ce` (the P0-T1 HEAD SHA; code paths equal effective BASE_SHA `92d78897` per P0-T1)

## Push

Command: `git push -u origin bug/cleanup-worktrees-apply-deletes-local-main-594`
EXIT_CODE: 0
Output: `Everything up-to-date` and `branch 'bug/cleanup-worktrees-apply-deletes-local-main-594' set up to track 'origin/bug/cleanup-worktrees-apply-deletes-local-main-594'.` The orchestrator had already force-pushed this HEAD after the rebase, so no objects were sent.

## Dispatch

Dispatch time (UTC): 2026-09-27T01:20:29Z

Command: `gh workflow run _shell-coverage.yml --ref bug/cleanup-worktrees-apply-deletes-local-main-594`
EXIT_CODE: 0
Output: dispatched run 36285238036.

## Run discovery poll (one poll required)

Command: `gh run list --workflow=_shell-coverage.yml --branch bug/cleanup-worktrees-apply-deletes-local-main-594 --event workflow_dispatch --limit 1 --json databaseId,headSha,status,conclusion,createdAt`
EXIT_CODE: 0
Output: `[{"conclusion":"","createdAt":"2026-09-27T01:20:33Z","databaseId":36285238036,"headSha":"b5f98be268c8c9e0752027486f6500f0a6fa26ce","status":"queued"}]`

`createdAt` 01:20:33Z is later than the dispatch time 01:20:29Z. RUN_ID = 36285238036.

## Run log

Command: `gh run view 36285238036 --log`
EXIT_CODE: 0
Extracted values (log saved outside the repository; 7375 lines):

- TAP plan lines: one, `1..463`.
- `ok` lines: 463.
- `not ok` lines: 0.
- Coverage headline: `Bash coverage (lines): 93.3%`.
- Final run metadata (`gh run view 36285238036 --json ...`): status `completed`, conclusion `success`, headSha `b5f98be268c8c9e0752027486f6500f0a6fa26ce`, createdAt 2026-09-27T01:20:33Z, updatedAt 2026-09-27T01:26:12Z.
- All job steps succeeded, including "Run shell-qc check (shfmt diff + shellcheck)", "Run shell-qc test with coverage", and "Upload shell coverage artifacts". kcov was installed from cache.

## Watch (pass/fail gate)

Command: `gh run watch 36285238036 --exit-status`
EXIT_CODE: 0

Output Summary:
- RUN_ID: 36285238036.
- headSha: `b5f98be268c8c9e0752027486f6500f0a6fa26ce` (equals the P0-T1 HEAD SHA).
- Conclusion: success.
- TAP: `1..463`; 463 ok; 0 not ok.
- Baseline coverage headline: `Bash coverage (lines): 93.3%`.
