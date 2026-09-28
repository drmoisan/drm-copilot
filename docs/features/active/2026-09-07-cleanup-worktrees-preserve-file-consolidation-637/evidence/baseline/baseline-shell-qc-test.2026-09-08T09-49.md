# Baseline — bats suite (`shell-qc.sh test`)

Timestamp: 2026-09-08T09-49
Task: [P0-T4]
Command: gh workflow run _shell-coverage.yml --ref bug/cleanup-worktrees-preserve-file-consolidation-637-r2 (CI run 34211209394; the workflow's test step runs `bash scripts/bash/shell-qc.sh test`)
EXIT_CODE: 0
ExpectedExitCode: 0

RouteSubstitution:
- Plan command (denied in this worktree):
  `pwsh -NoProfile -Command "wsl -d Ubuntu -- bash -lc 'cd /mnt/c/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-a817693674107cbe5 && bash scripts/bash/shell-qc.sh test'"`
- Substitute actually run: the CI route, dispatched by the orchestrator, run
  `34211209394` at `https://github.com/drmoisan/drm-copilot/actions/runs/34211209394`, ref
  `bug/cleanup-worktrees-preserve-file-consolidation-637-r2`, head SHA
  `0edc15e030d9a79307e1399e9658e95b2cd6066d`, conclusion `success`.
- Reason: `pwsh` is refused unconditionally in this worktree and `bats` is not on the Git Bash PATH,
  so neither the plan's wrapped form nor a local substitute can run the suite here. The executor
  holds no `Bash(gh *)` grant, so the dispatch was performed by the orchestrator and its result is
  recorded here.
- Correction to the plan preamble: the preamble asserts the CI route "produces no per-test TAP
  output". That assertion is refuted by this run. `run_test` at `scripts/bash/shell_qc_lib.sh`
  lines 226-256 invokes `bats` with no formatter flag, and `bats` emits TAP when stdout is not a
  TTY, which is the case under GitHub Actions. The run log carries a TAP plan line and one
  `ok N <test name>` line per test.

Output Summary:

- TAP plan line printed: `1..343`
- **Passing tests: 343.** 343 lines of the form `ok N <test name>` were printed.
- **Failing tests: 0.** No `not ok` line appears anywhere in the run log.
- Job conclusion: `success`; the `shell-qc.sh test` step exited 0.

Because the run emits per-test TAP, every targeted `bats` gate named in this plan is satisfiable
from this route: a targeted gate is asserted by locating the named test's `ok N <test name>` line in
the run log and confirming no `not ok` line names it. The plan's three-part assertion shape (plan
line, absence of `not ok`, run conclusion) is preserved.

Verdict: PASS. The pre-change bats suite is fully green at 343 tests.
