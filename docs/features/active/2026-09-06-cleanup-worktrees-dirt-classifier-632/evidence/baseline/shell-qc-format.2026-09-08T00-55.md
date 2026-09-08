# Baseline — bash formatter (plan task P0-T2)

Timestamp: 2026-09-08T00-55
Tree state: branch `bug/cleanup-worktrees-dirt-classifier-632-r2` at HEAD
`4ffe680ebcebaabbba10faaa490e46a717686535`, working tree clean.

## Deviation from the plan's literal command text (recorded per EA-1 and EA-4)

The plan's P0-T2 block reads:

```
wsl -d Ubuntu -- bash -lc 'cd /mnt/c/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-a3944b95a7d58e712 && bash scripts/bash/shell-qc.sh format'
wsl -d Ubuntu -- bash -lc 'cd /mnt/c/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-a3944b95a7d58e712 && git status --porcelain -- tools scripts .claude/lib/bash'
```

Two facts make that text unusable verbatim in this run:

1. The path names `agent-a3944b95a7d58e712`, which is the epic-planner PREPARATION
   worktree, not the execution worktree this run occupies
   (`agent-ac72d35e7980bc69d`). Running it would have measured a different tree.
2. Execution amendment EA-1 forbids the bare `wsl` form, and this worktree's
   isolation guard denies any command whose text contains `wsl`, `bash`, or `pwsh`
   regardless of semantics.

The write-mode `shell-qc.sh format` was additionally NOT run at baseline time
because an `atomic-executor` delegation was concurrently editing this tree; a
write-mode formatter run would have raced its edits. The write-mode run is
deferred to Phase 7, where the tree is stable. The read-only equivalent below is
what was executed instead, and it carries the same falsifiable observation.

## Command 1 — read-only formatter observation

Command: `shfmt -l scripts .claude/lib/bash`
Working directory: `C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-ac72d35e7980bc69d`
shfmt version: v3.12.0
EXIT_CODE: 0

Output Summary: empty output. `shfmt -l` prints one line per file whose contents
differ from its formatted form, so empty output means no discovered shell file
needs reformatting. This is the observation that can fail; the write-mode
`shfmt -w` prints nothing on either a clean or a repairing run
(`scripts/bash/shell_qc_lib.sh` calls `shfmt -w` and returns its exit code with
no summary line), so its exit code alone could not have failed.

The discovery root `tools` named by `scripts/bash/shell_qc_lib.sh` does not exist
in this repository; `shfmt` errors on an absent path operand, so it was omitted
from the read-only invocation. `scripts` and `.claude/lib/bash` are the two roots
that exist and they hold every discovered shell file.

## Command 2 — porcelain tree observation

Command: `git status --porcelain -- tools scripts .claude/lib/bash`
Working directory: `C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-ac72d35e7980bc69d`
EXIT_CODE: 0

Output Summary: stdout empty (0 lines). No tracked modification and no untracked
file exists under the three formatter discovery roots. A non-empty output here
would mean the tree was already dirty in formatter scope and the baseline was not
clean.

## Verdict

Formatter baseline is CLEAN. Corroborated independently by the P0-T3 `check`
baseline, which runs `shfmt -d` over the same discovered file list and exited 0
with empty output.
