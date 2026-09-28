# Phase 5 — shell coverage workflow dispatch (CI, cycle 3)

Timestamp: 2026-09-09T02-30
Task: [P5-T8]
Performed by: orchestrator. EA-4 retains this gate: kcov has no local route and exits 127, the
bash toolchain may be denied to a delegated executor, and no uncaptured or assumed figure may be
recorded. The delegated executor has no `gh` and correctly left this task and its two dependents
unchecked rather than substituting a locally-derived value.

Command (dispatch): gh workflow run _shell-coverage.yml --ref bug/cleanup-worktrees-dirt-classifier-632-r2
Command (verification read): gh run view 34255859868 --json status,conclusion,headSha,event,url
Command (log read): gh run view 34255859868 --log
EXIT_CODE: 0

## Run identity, re-read from GitHub rather than restated

RunId: 34255859868
RunUrl: https://github.com/drmoisan/drm-copilot/actions/runs/34255859868
Workflow: Shell Coverage (Bats + kcov) — `.github/workflows/_shell-coverage.yml`
Event: workflow_dispatch
Status: completed
Conclusion: success
headSha: 5ad0ef09088f68ad2818ae01292b8290cdf18d12

## Head SHA equality, as a side-by-side observation

The two values are recorded together rather than compared against any literal written into the
plan, because a literal would go stale on the next commit and the assertion would then pass or
fail for the wrong reason.

- Commit pushed by [P5-T7], read back with `git rev-parse HEAD` immediately after the push
  reported `7b6e13c7..5ad0ef09  HEAD -> bug/cleanup-worktrees-dirt-classifier-632-r2`:
  `5ad0ef09088f68ad2818ae01292b8290cdf18d12`
- `headSha` field of run 34255859868, read from the run itself:
  `5ad0ef09088f68ad2818ae01292b8290cdf18d12`

The two are identical.

## TAP figures from the run log

TapPlan: `1..417`
NotOkCount: 0
FailedSteps: none.

417 matches the local full-suite figure recorded in the Phase 5 local QA evidence, and exceeds
this cycle's Phase 0 baseline of 411 by exactly the six tests this cycle adds.

## Why this dispatch is the verification

A pull request based on the epic integration branch runs essentially no CI: `ci.yml` is gated on
`pull_request: branches: [main, development]`, so a green or empty checks tab on this feature's PR
would be evidence of nothing. That is the recorded defect `EPIC_CHILD_PRS_RUN_NO_REAL_CI`. This
dispatch against the final pushed head SHA, with the figures read from the run log and the run's
own artifact, is the real verification for the S9 gate.

The dispatch was issued against the FINAL head rather than an earlier commit. Cycle 2's run was
green at `7d7a661f` while the head later advanced, which left a gap between the verified commit
and the merged one; that gap is closed here by dispatching last.

Output Summary: CI run 34255859868 concluded `success` at headSha `5ad0ef09`, the exact commit
pushed by P5-T7. TAP plan `1..417` with 0 `not ok` and no failing step.
