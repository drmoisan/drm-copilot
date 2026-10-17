# P0-T9 Baseline bats run over TARGETED-SET (deviated DEV-2; CI-sourced evidence)

Timestamp: 2026-10-02T03-34
Updated: 2026-10-02T03-47 (segment 2; CI results recorded)
Command: CI `.github/workflows/_shell-coverage.yml` step "Run shell-qc test with coverage" (`scripts/bash/shell-qc.sh test --coverage`, which runs bats over tests/shell and tests/bash under kcov), run 36978610292, job "Shell Coverage (Bats + kcov)" 110747827997. The plan command `npx --yes bats --formatter tap tests/shell/test_cleanup_worktrees_report_records.bats tests/shell/test_cleanup_worktrees_scan_helper.bats tests/shell/test_cleanup_worktrees_scan_seam.bats tests/shell/test_cleanup_worktrees_enumeration.bats tests/shell/test_cleanup_worktrees_preserve.bats tests/shell/test_cleanup_worktrees_preserve_failures.bats tests/shell/test_cleanup_worktrees_preserve_eol.bats tests/shell/test_cleanup_worktrees_cli.bats` was not run locally (DEV-2).
EXIT_CODE: 0
Output Summary:
- Deviation DEV-2 (operator decision 2026-10-01, Option A, binding): bats executes bash internally, so a local bats run is a route around the worktree isolation guard and is not performed. Evidence source is CI.
- CI run: https://github.com/drmoisan/drm-copilot/actions/runs/36978610292 ; job https://github.com/drmoisan/drm-copilot/actions/runs/36978610292/job/110747827997 ; conclusion success ; headSha df5eb303129a30289a7d81775fdadaa40631be63 (BASE_SHA) ; completed 2026-10-02T07:33:06Z. EXIT_CODE 0 above is the job conclusion (success).
- Log readout (orchestrator, `gh run view 36978610292 --log`): bats plan line `1..507` over the whole tests/shell + tests/bash set, which contains every TARGETED-SET suite. `not ok` count: 0.
- Baseline failure set: empty (no `not ok` line in any suite, including test_cleanup_worktrees_report_records.bats and test_cleanup_worktrees_scan_helper.bats, so the P0-T9 stop condition is not reached).
- BASELINE_LOCAL_N: not locally observable (DEV-2). Recorded substitutes: CI N = 507 for the full set (BASELINE_CI_N); static TARGETED-SET `@test` count 86 (report_records 10, scan_helper 5, scan_seam 2, enumeration 15, preserve 26, preserve_failures 11, preserve_eol 6, cli 11), equal to the planning-time expectation. P1-T18 / P2-T3 expectations translate to CI N = 507 + 16 - 2 = 521 (16 added by NEW-SUITE, 2 moved out of the scan-helper suite by P1-T9) and TARGETED-SET + NEW-SUITE = 86 + 14 = 100.
- Data supplied by the orchestrator in the segment 2 directive; the executor has no gh access (DEV-3).
