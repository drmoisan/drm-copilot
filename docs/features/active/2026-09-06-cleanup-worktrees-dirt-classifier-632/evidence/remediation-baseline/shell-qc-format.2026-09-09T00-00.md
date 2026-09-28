# Baseline — shell format and check stages

Timestamp: 2026-09-09T00-00

Task: [P0-T3]

Command: `bash scripts/bash/shell-qc.sh format`
EXIT_CODE: 0

Command: `bash scripts/bash/shell-qc.sh check`
EXIT_CODE: 0

Both commands were run from the worktree root
`C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-ac72d35e7980bc69d`, with
stdout and stderr redirected together to a single capture file.

## Why the paired check run is the observation that can fail

`run_format` (`scripts/bash/shell_qc_lib.sh:204-224`) prints nothing on success and returns
`shfmt -w`'s exit code, which is 0 whether or not a file was rewritten. Its exit code
therefore cannot distinguish a clean run from a repairing one. The `check` run in the same
task is the leg that can fail: `run_check` (`:164-202`) runs `shfmt -d` once over the
discovered file list, and `shfmt -d` prints a unified diff and returns non-zero for any
file the write-mode pass left unformatted. `run_check` also returns 127 with a five-line
missing-tool block if either `shfmt` or `shellcheck` fails to resolve, so an exit code of 0
with empty output establishes that both tools resolved and both ran clean rather than that
the stage was skipped.

Tool resolution observed in this environment:

```
shfmt      -> /c/Users/DanMoisan/AppData/Local/Microsoft/WinGet/Packages/mvdan.shfmt_Microsoft.Winget.Source_8wekyb3d8bbwe/shfmt
shellcheck -> /c/Users/DanMoisan/AppData/Local/Microsoft/WinGet/Packages/koalaman.shellcheck_Microsoft.Winget.Source_8wekyb3d8bbwe/shellcheck
```

## Output Summary

`bash scripts/bash/shell-qc.sh format` — combined stdout and stderr, verbatim. The capture
file measured 0 bytes:

```
```

`bash scripts/bash/shell-qc.sh check` — combined stdout and stderr, verbatim. The capture
file measured 0 bytes:

```
```

Both stages passed. The check command's combined output is empty, which under `run_check`'s
contract means `shfmt -d` reported no diff and `shellcheck` reported no finding on any
discovered file.

## StatusBefore

`git status --porcelain --untracked-files=all`, taken immediately before the format run,
verbatim:

```
 M docs/features/active/2026-09-06-cleanup-worktrees-dirt-classifier-632/remediation-plan.2026-09-08T23-30.md
?? docs/features/active/2026-09-06-cleanup-worktrees-dirt-classifier-632/evidence/remediation-baseline/phase0-findings-read.2026-09-09T00-00.md
?? docs/features/active/2026-09-06-cleanup-worktrees-dirt-classifier-632/evidence/remediation-baseline/phase0-instructions-read.2026-09-09T00-00.md
```

## StatusAfter

`git status --porcelain --untracked-files=all`, taken immediately after the format run,
verbatim:

```
 M docs/features/active/2026-09-06-cleanup-worktrees-dirt-classifier-632/remediation-plan.2026-09-08T23-30.md
?? docs/features/active/2026-09-06-cleanup-worktrees-dirt-classifier-632/evidence/remediation-baseline/phase0-findings-read.2026-09-09T00-00.md
?? docs/features/active/2026-09-06-cleanup-worktrees-dirt-classifier-632/evidence/remediation-baseline/phase0-instructions-read.2026-09-09T00-00.md
```

StatusAfter lists **no** path that is absent from StatusBefore. The two outputs are
identical line for line, so the write-mode format pass rewrote no file. The three paths
listed in both are the two Phase 0 evidence artifacts written by [P0-T1] and [P0-T2] and
the remediation plan file, whose checkboxes those two tasks checked off; none is a shell
script and none was touched by `shfmt -w`.

## Tree digest — not attempted

The `discover_shell_scripts`-derived tree digest named in AC-31's text is **not** attempted
in this task. The reason is adjudicated in
`docs/features/active/2026-09-06-cleanup-worktrees-dirt-classifier-632/evidence/other/phase0-blocked-gates.2026-09-08T22-00.md`,
which records that the digest command is denied to every agent in this environment. AC-31
retains the PARTIAL disposition the cycle-2 reaudit assigned. The twofold observation this
plan substitutes — the before-and-after porcelain status recorded above, together with the
paired `check` run whose combined output must be empty — is what stands in its place.
