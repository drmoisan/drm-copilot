---
name: ci-poll-on-gate-job-not-run-status
description: During Actions degraded performance gh run list reported a ci.yml run completed/success while jobs were still running; poll the terminal job instead
metadata:
  type: feedback
---

Poll a CI proof on the specific terminal job (for example `CI Required Gate` via `gh run view <id> --json jobs`), not on the run-level `status`/`conclusion` from `gh run list`.

**Why:** Issue #1074 Phase 7 (2026-11-04), githubstatus Actions `degraded_performance`: `gh run list` returned `completed success` for run 41864628204 while the jobs API still showed 9 jobs in progress and the gate queued; later the jobs API stayed stale (jobs `in_progress` after the gate, which needs them, completed). The gate job log is the reliable view of `needs` results.

**How to apply:** Also, the executor stop hook blocks ending a turn while plan tasks are unchecked, so a background poll plus "wait for notification" does not work; run short foreground `sh SCRATCH/*.sh` poll windows (about 3 polls at 60 s, under the ~180 s Bash limit) repeatedly. See [[executor-stop-hook-and-item-worktree-runs]].
