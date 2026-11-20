# P6-T10 / P6-T11 — Authoritative CI shell coverage (`_shell-coverage.yml`)

Timestamp: 2026-09-27T02-00
Tasks: [P6-T10], [P6-T11]
Working directory: repository worktree root
Branch: `bug/cleanup-worktrees-apply-deletes-local-main-594`
CI_SHA (P6-T8): `e29ad95d70cce6641c1817f3ac36f319d2a10b59`

## P6-T10 — dispatch

Dispatch time (UTC): 2026-09-27T01:58:43Z

Command: `gh workflow run _shell-coverage.yml --ref bug/cleanup-worktrees-apply-deletes-local-main-594`
EXIT_CODE: 0
Output: `https://github.com/drmoisan/drm-copilot/actions/runs/36287146354`

## P6-T10 — run discovery (one poll required)

Command: `gh run list --workflow=_shell-coverage.yml --branch bug/cleanup-worktrees-apply-deletes-local-main-594 --event workflow_dispatch --limit 1 --json databaseId,headSha,status,conclusion,createdAt`
EXIT_CODE: 0
Output: `[{"conclusion":"","createdAt":"2026-09-27T01:58:47Z","databaseId":36287146354,"headSha":"e29ad95d70cce6641c1817f3ac36f319d2a10b59","status":"queued"}]`

`createdAt` 01:58:47Z is later than the dispatch time 01:58:43Z; `headSha` equals CI_SHA. RUN_ID = 36287146354.

## P6-T11 — run log

Command: `gh run view 36287146354 --log`
EXIT_CODE: 0
Extracted values (log saved in the session scratchpad, outside the repository; 7681 lines):

- TAP plan lines: one, `1..473` (only `tests/shell` runs). P0-T11 plan `1..463` plus 10 = 473.
- `ok` lines: 473. `not ok` lines: 0.
- Coverage headline: `Bash coverage (lines): 93.3%`.
- Step results (`gh run view 36287146354 --json status,conclusion,headSha,createdAt,updatedAt,jobs`): job "Shell Coverage (Bats + kcov)" success; "Run shell-qc check (shfmt diff + shellcheck)" success (CI shfmt 3.8.0 diff and shellcheck clean); "Run shell-qc test with coverage" success; "Upload shell coverage artifacts" success; "Build kcov from source" skipped (kcov installed from cache).
- Run metadata: status `completed`, conclusion `success`, headSha `e29ad95d70cce6641c1817f3ac36f319d2a10b59`, createdAt 2026-09-27T01:58:47Z, updatedAt 2026-09-27T02:08:06Z.

T1-T10 lines on ubuntu-latest (verbatim, timestamp prefix removed):

| Test | Line |
|---|---|
| T1 | `ok 353 compute_protected emits protected-branch main when the primary worktree is on another branch` |
| T2 | `ok 354 compute_protected emits protected-branch main under current_exclusion` |
| T3 | `ok 355 compute_protected emits exactly one protected-branch main when the current branch is main` |
| T4 | `ok 207 classify_branch main is PROTECTED_CURRENT when the primary worktree is on another branch` |
| T5 | `ok 208 classify_branch main is PROTECTED_CURRENT when main is checked out in a linked worktree` |
| T6 | `ok 237 run_report classifies main PROTECTED_CURRENT when the primary worktree is on another branch` |
| T7 | `ok 238 run_apply does not delete main when the primary worktree is on another branch` |
| T8 | `ok 239 run_apply neither removes nor deletes main checked out in a linked worktree` |
| T9 | `ok 240 delete_candidate refuses the base branch before re-verification` |
| T10 | `ok 241 delete_candidate refuses the base branch before removing its linked worktree` |

## P6-T11 — watch (pass/fail gate)

Command: `gh run watch 36287146354 --exit-status`
EXIT_CODE: 0

Output Summary:
- RUN_ID: 36287146354; headSha `e29ad95d70cce6641c1817f3ac36f319d2a10b59` (equals CI_SHA); createdAt 01:58:47Z is later than dispatch 01:58:43Z.
- Conclusion: success. shell-qc check step: success. shell-qc test with coverage step: success.
- TAP: `1..473` (P0-T11 `1..463` + 10); 473 ok; 0 not ok.
- Post-change coverage headline: `Bash coverage (lines): 93.3%` (baseline 93.3%).
- T1 through T10 each report `ok` in CI.
