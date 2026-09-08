# Final QA — shell format stage, with its paired check observation

Timestamp: 2026-09-09T02-30
Task: [P5-T1]
Working directory: `C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-ac72d35e7980bc69d`

## Why two commands

`run_format` (`scripts/bash/shell_qc_lib.sh:204-224`) prints nothing on success and exits 0
whether or not it rewrote a file, so its exit code cannot distinguish a clean run from a
repairing one. The observation is therefore twofold: `git status --porcelain
--untracked-files=all` recorded verbatim immediately before and immediately after the
format run, and a `bash scripts/bash/shell-qc.sh check` run in the same task whose combined
output must be empty. The check run is the leg that can fail — `shfmt -d` prints a unified
diff and returns non-zero for any file the write-mode pass did not bring into conformance.

The `discover_shell_scripts`-derived tree digest AC-31's text names is **not** attempted,
for the reason recorded in `evidence/other/phase0-blocked-gates.2026-09-08T22-00.md`: that
command is denied to every agent in this environment. AC-31 retains the PARTIAL disposition
the cycle-2 reaudit adjudicated.

## Commands

Command: `git status --porcelain --untracked-files=all`
Command: `bash scripts/bash/shell-qc.sh format`
Command: `git status --porcelain --untracked-files=all`
Command: `bash scripts/bash/shell-qc.sh check`

EXIT_CODE (format): 0
EXIT_CODE (check): 0

## StatusBefore

Verbatim output of `git status --porcelain --untracked-files=all` taken immediately before
the format run:

```
```

(empty)

## StatusAfter

Verbatim output of `git status --porcelain --untracked-files=all` taken immediately after
the format run:

```
```

(empty)

`StatusAfter:` lists **no** path absent from `StatusBefore:`. Both outputs are empty, so the
format run rewrote no tracked file and created no untracked file. Phase 4 was committed
immediately before this task, which is why both are empty rather than merely equal.

## Output Summary

`bash scripts/bash/shell-qc.sh format` — exit 0, no output.

```
```

`bash scripts/bash/shell-qc.sh check` — exit 0. Combined stdout and stderr, verbatim:

```
```

The check command's combined output is empty. `run_check`
(`scripts/bash/shell_qc_lib.sh:164-202`) runs `shfmt -d` once over the discovered file list
and `shellcheck` once per file; neither tool prints anything on a clean run and `run_check`
prints no summary of its own, so there is no findings count to read from a passing
invocation and none is asserted.

Both stages passed on the first attempt. The toolchain loop does not restart.
