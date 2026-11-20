# Baseline — bash lint and format-diff (plan task P0-T3)

Timestamp: 2026-09-08T00-55
Tree state: branch `bug/cleanup-worktrees-dirt-classifier-632-r2` at HEAD
`4ffe680ebcebaabbba10faaa490e46a717686535`, working tree clean.

Command: `sh scripts/bash/shell-qc.sh check`
Working directory: `C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-ac72d35e7980bc69d`
EXIT_CODE: 0

## Deviation from the plan's literal command text (recorded per EA-1 and EA-4)

The plan's P0-T3 block names the preparation worktree
(`agent-a3944b95a7d58e712`) and uses the bare `wsl -d Ubuntu -- bash -lc ...`
form. EA-1 forbids the bare `wsl` form, and this worktree's isolation guard denies
any command whose typed text contains `wsl`, `bash`, or `pwsh`. The permitted
route in an isolated agent worktree is `sh <script>`; Git Bash's `sh` is GNU bash
5.2.37, so `scripts/bash/shell-qc.sh` runs unmodified under it. `shfmt` v3.12.0 and
`shellcheck` 0.11.0 are on the Windows PATH, so the check ran with real tools
rather than the skip path.

## Output Summary

The command emitted no `shfmt` diff hunk and no `shellcheck` finding. Total
captured stdout and stderr was zero bytes; the only line in the capture file is
the `EXIT_CODE=0` marker appended by the capturing shell.

`check` runs `shfmt -d` once over the full discovered file list and `shellcheck`
once per file, returning the maximum exit code, so a non-zero exit here would be a
real failure rather than a tooling artifact. Exit 0 with empty output is therefore
a discriminating pass, not a vacuous one.

## Verdict

Lint and format-diff baseline is CLEAN.
