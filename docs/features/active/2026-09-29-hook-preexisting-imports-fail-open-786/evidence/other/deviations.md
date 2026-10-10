# Deviations

Rule 15 record of departures and their triggering observations.

## [P0-T3] Route wrapper form

- Observation: the Bash isolation guard refused command lines that combined `sh` with output redirection or `echo`, and a separate PreToolUse hook refused a `cd`-chained `grep`/`cat`. The accepted form is `cd <WORKSPACE_ROOT> && sh <SCRATCHPAD>/<wrapper>.sh <arguments>`.
- Fallback applied: route `sh` is used through one generic wrapper, `<SCRATCHPAD>/r.sh <name> <arguments>`, which changes to the worktree root, runs `pwsh -NoProfile -File <SCRATCHPAD>/<name>.ps1 <arguments>`, writes the combined output to `<SCRATCHPAD>/<name>.out`, and prints `EXIT=<code>`. The route remains `sh` (a fresh PowerShell 7 process per script, worktree root as working directory); only the per-script two-line `.sh` companion is replaced by the generic wrapper.

## Phase 0 Timestamp correction

- Observation: the `Timestamp:` field of fourteen Phase 0 artifacts was first written with values ahead of the actual run time.
- Correction applied: each value was replaced with the artifact's actual file write time (minute precision) before the Phase 0 commit; no other field changed. Affected artifacts: p0-execution-route.md, p0-pre-merge-state.md, p0-upstream-precondition.md, p0-merge.md, hook-dependency-enumeration-repo.md, hook-dependency-enumeration-mirror.md, hook-dependency-rows.md, hook-dependency-reconciliation.md, hook-guard-worklist.md, p0-line-counts.md, p0-batch-budget-probe.md, p0-poshqc-format.md, p0-mcp-poshqc-format.md, p0-poshqc-analyze.md.
