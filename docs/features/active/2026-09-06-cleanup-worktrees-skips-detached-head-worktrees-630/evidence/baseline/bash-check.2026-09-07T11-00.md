# Baseline — Bash Lint and Format State (Issue #630)

Timestamp: 2026-09-07T11-00

Task: [P0-T5]

Command: `scripts/bash/shell-qc.sh check`

EXIT_CODE: 0

Working directory: `C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-adf4f49cbc48904be`

## Command Substitution

The plan's [P0-T5] literal is:

```
wsl -d Ubuntu -- bash -lc 'cd /mnt/c/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-a06652a3fd875c703 && bash scripts/bash/shell-qc.sh check'
```

Two substitutions were applied and are recorded here:

1. **Worktree path.** The plan names the stale worktree `agent-a06652a3fd875c703`. The command was run in this run's worktree, `agent-adf4f49cbc48904be` (WSL form `/mnt/c/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-adf4f49cbc48904be`). The plan's literal path was substituted for this worktree.
2. **Invocation form.** The `wsl -d Ubuntu -- bash -lc '...'` wrapper is refused by the worktree-isolation guard in this environment, as recorded in the [P0-T4] artifact. The wrapper was dropped and the same script was invoked natively as `scripts/bash/shell-qc.sh check` from the worktree root. The script and the arguments are unchanged; only the wrapper and the working-directory change are different.

`check` is read-only. It runs `shfmt -d` once over the discovered file list and then `shellcheck` once per file. It rewrites nothing, so running it as the baseline instrument does not alter the tree the baseline describes. This is the Baseline-Ordering Decision the plan states: the write-mode `format` command is deliberately not run in Phase 0.

## Raw Output

```
```

Neither stdout nor stderr produced any line.

## Corroboration — the discovery set is non-empty

An empty result is only meaningful if the discovery step found files to check. `discover_shell_scripts` returned 19 files:

```
.claude/lib/bash/compute-cohorts.sh
.claude/lib/bash/compute-concurrency-batches.sh
.claude/lib/bash/parallel-cohorts.sh
.claude/lib/bash/parallel-common.sh
.claude/lib/bash/parallel-items-validate.sh
.claude/lib/bash/parallel-lane-assertion.sh
.claude/lib/bash/parallel-manifest-validate.sh
.claude/lib/bash/parallel-yaml-emit.sh
.claude/lib/bash/parallel-yaml-scan.sh
.claude/lib/bash/report-lane-assertion.sh
.claude/lib/bash/validate-parallel-manifest.sh
scripts/bash/cleanup-worktrees.sh
scripts/bash/cleanup_worktrees_actions_lib.sh
scripts/bash/cleanup_worktrees_enumerate_lib.sh
scripts/bash/cleanup_worktrees_lib.sh
scripts/bash/coverage_demo.sh
scripts/bash/coverage_lib.sh
scripts/bash/shell-qc.sh
scripts/bash/shell_qc_lib.sh
```

Output Summary: **stdout and stderr were both empty** and the exit code was 0. This is the clean-run observation the plan's Observation Contract specifies: `shfmt -d` prints a unified diff for any unformatted discovered file and `shellcheck` prints findings only, so empty output with exit 0 is falsifiable positive evidence that the baseline tree carries no formatting drift and no shellcheck finding across all 19 discovered files. The empty result is not a vacuous empty discovery: the discovery step returned 19 files, enumerated above. No diff and no shellcheck finding exists to reproduce.
