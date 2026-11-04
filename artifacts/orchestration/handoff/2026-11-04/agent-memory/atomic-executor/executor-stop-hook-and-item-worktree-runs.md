---
name: executor-stop-hook-and-item-worktree-runs
description: validate-executor-output stop hook needs an absolute plan-path for item worktrees and blocks stopping while any task is unchecked; worktree .venv may be empty; long Pester runs need tool-call polling
metadata:
  type: project
---

Observed 2026-11-03 on issue 1021 (item worktree under /workspaces/drm-copilot-wt/, phase-limited delegation).

- `.claude/hooks/validate-executor-output.ps1` resolves a relative `plan-path:` against the main checkout, so a plan that exists only in an item worktree must be advertised by absolute path. It also refuses to let the run stop while any `- [ ]` task remains, even when the delegation covers only some phases, so a mid-run idle turn is not possible: keep working through tool calls (for example `timeout 170 tail --pid=<pid> -f /dev/null` waits, since foreground commands move to the background after 180 s).
- A fresh item worktree's `.venv` can hold only pip (`pytest_cov` missing, pytest exit 4); `poetry -C <worktree> install --no-interaction --no-root` fixes it without touching tracked files.
- `Invoke-PoshQCTest` over `tests/scripts` on the Linux Codespace exits 255 (Run.Exit with 409 failures) and truncates `pester-junit.xml`; totals are on the `testsuites` root element, and failing names need a supplemental `Invoke-Pester` PassThru pass (see [[linux-codespace-pester-host-failures]]).

- Seen again on issue 1066 (2026-11-04): ending a turn to wait for a background notification trips the hook twice (first for a missing `plan-path:` line, then for unchecked tasks). Wait with a script that polls a log for a completion marker and exits within 160 s (`issue-1066-wait-short.sh` pattern), and call it again as needed. Also read `date -u` before naming every evidence file; two stamps written from memory had to be renamed.

**Why:** each cost a retry loop in the 1021 run.
**How to apply:** advertise absolute plan paths from item worktrees, keep phase-limited runs busy with real tool work, and plan the supplemental name pass into the baseline step.
