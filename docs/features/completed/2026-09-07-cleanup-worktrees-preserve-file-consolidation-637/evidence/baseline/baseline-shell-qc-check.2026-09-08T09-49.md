# Baseline — format-drift and lint gate (`shell-qc.sh check`)

Timestamp: 2026-09-08T09-49
Task: [P0-T3]
Command: bash scripts/bash/shell-qc.sh check
EXIT_CODE: 0
ExpectedExitCode: 0

RouteSubstitution:
- Plan command (denied in this worktree):
  `pwsh -NoProfile -Command "wsl -d Ubuntu -- bash -lc 'cd /mnt/c/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-a817693674107cbe5 && bash scripts/bash/shell-qc.sh check'"`
- Substitute actually run (verified by the orchestrator on 2026-09-08 and re-run here):
  `cd C:/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-a817693674107cbe5 && bash scripts/bash/shell-qc.sh check`
- Reason: `pwsh` is refused unconditionally by the harness-level worktree-isolation guard in this
  worktree, including on a bare `pwsh -NoProfile -Command "Write-Output hello"`, so the plan's
  wrapped form cannot execute. `shellcheck` and `shfmt` are both on the Git Bash PATH, so the same
  script runs locally with no `pwsh` and no `wsl` leg. A bare `wsl` form was not attempted; it is
  prohibited by binding execution amendment EA-1.

Output Summary:

The run exited 0 and printed no output at all. Silence is the success signal for this gate and is
not a failure to observe the result: `run_check` at `scripts/bash/shell_qc_lib.sh` lines 164-201
runs `shfmt -d` once over the discovered file list, which prints a unified diff only when a file
differs, then runs `shellcheck` once per file, which prints only when it has findings, and returns
the maximum exit code observed from either. The zero-file skip path prints
`No shell scripts found; skipping.`; that message did not appear, which establishes that a
non-empty file list was actually checked rather than the gate short-circuiting.

The two stages were additionally run separately so each is recorded on its own, as this task
requires:

- Discovered file list: `shfmt -f scripts .claude/lib/bash` reports **22** shell files. `tools/`
  does not exist in this tree and is silently skipped by `discover_shell_scripts`
  (`scripts/bash/shell_qc_lib.sh` lines 85-90).
- **`shfmt -d` stage — diff hunks printed: 0.** `shfmt -d scripts .claude/lib/bash` exited 0 and its
  combined stdout+stderr was **0 lines**. No file carries formatting drift at baseline.
- **`shellcheck` stage — findings printed: 0.** The 22 discovered files were passed to `shellcheck`
  and its combined stdout+stderr was **0 lines**. No lint finding of any severity is outstanding at
  baseline.

Corroboration from CI. The same gate ran on the pre-change tree in CI run 34211209394
(`https://github.com/drmoisan/drm-copilot/actions/runs/34211209394`), ref
`bug/cleanup-worktrees-preserve-file-consolidation-637-r2`, head SHA
`0edc15e030d9a79307e1399e9658e95b2cd6066d`, conclusion `success`. The check step precedes the test
step in that job and the job concluded success, so the gate passed there as well.

Verdict: PASS. Baseline format drift is zero and baseline lint findings are zero.
