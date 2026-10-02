# P0-T9 Baseline local bats run over TARGETED-SET (deviated; evidence deferred to CI)

Timestamp: 2026-10-02T03-38
Command: none (plan command `npx --yes bats --formatter tap tests/shell/test_cleanup_worktrees_report_records.bats tests/shell/test_cleanup_worktrees_scan_helper.bats tests/shell/test_cleanup_worktrees_scan_seam.bats tests/shell/test_cleanup_worktrees_enumeration.bats tests/shell/test_cleanup_worktrees_preserve.bats tests/shell/test_cleanup_worktrees_preserve_failures.bats tests/shell/test_cleanup_worktrees_preserve_eol.bats tests/shell/test_cleanup_worktrees_cli.bats` not run; task deviated under DEV-2)
EXIT_CODE: n/a-deviated
Output Summary:
- Deviation DEV-2 (operator decision 2026-10-01, Option A, binding): bats executes bash internally, so a local bats run is a route around the worktree isolation guard. The local run is not performed.
- Deferred evidence source: CI shell-coverage run 36978610292 (https://github.com/drmoisan/drm-copilot/actions/runs/36978610292), workflow `_shell-coverage.yml`, dispatched on BRANCH at headSha df5eb303129a30289a7d81775fdadaa40631be63 (BASE_SHA). The orchestrator supplies its plan line, `not ok` lines, and conclusion in segment 2; BASELINE_LOCAL_N is to be taken from that run's TARGETED-SET results.
- Static reference (no execution): `grep -c "^@test "` over the eight TARGETED-SET files prints report_records 10, scan_helper 5, scan_seam 2, enumeration 15, preserve 26, preserve_failures 11, preserve_eol 6, cli 11; total 86, equal to the planning-time expectation. This count is not a substitute for the run result.
- Task status: left unchecked in the plan until the orchestrator records the CI results in segment 2.
