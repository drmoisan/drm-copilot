# Phase Gate P1 — Remediation Cycle 1, P1-T6 (Issue 1162)

Timestamp: 2026-11-14T08-27
Command: sh SCRATCH/issue-1162-psstatic.sh; sh SCRATCH/issue-1162-pystatic.sh; sh SCRATCH/issue-1162-pester-gate.sh; sh SCRATCH/issue-1162-pytest-gate.sh p1; sh SCRATCH/issue-1162-jest.sh ext p1; sh SCRATCH/issue-1162-jest.sh root p1 (each from the item worktree, one suite at a time, at HEAD after the Phase 1 commit)
EXIT_CODE: 0
Output Summary:
- One clean pass. No step failed and no step changed a file, so the loop did not restart.
- PowerShell format: EXIT_CODE 0, 0 files reformatted (1649 already formatted); `git status --porcelain` empty before and after.
- PowerShell analyzer (Invoke-PoshQCAnalyze, pssa.settings.psd1): EXIT_CODE 0, 0 findings.
- Leak scan (Invoke-PoshQCLeakScan): EXIT_CODE 0, 0 findings.
- Black check: EXIT_CODE 0, 1065 files unchanged. Ruff: EXIT_CODE 0, "All checks passed!". Pyright: EXIT_CODE 0, 0 errors, 0 warnings, 0 informations.
- Codex generator `--check`: EXIT_CODE 0, no drift.
- Pester, one Invoke-PoshQCParallelTest (8 workers, 800.23 s, 2026-11-14T08-39-38Z to 08-52-58Z): EXIT_CODE 0, tests=24326, failures=0, errors=0, disabled=10. That is 5 more than the Phase 0 baseline of 24321: the stale-ref adapter test and the four CES-STATUS-MAPPING cases. This run includes PRC-LEDGER-CHAIN-HOLDS, PRC-LEDGER-SUBCHAIN-HOLDS, and codex-epic-runtime-contracts.Tests.ps1. Line coverage 95.97% (40622/42328); EpicCrossDependency.psm1 98.03% (349/356); Invoke-EpicCrossReadiness.ps1 100.00% (5/5).
- pytest, one `pytest -n auto` with `--cov=scripts.dev_tools --cov-branch --cov-report=term-missing`: EXIT_CODE 0, 16815 passed, 0 failed, 6 skipped (188.38 s). This includes test_frozen_epic_surface_matches_pinned_baseline_digest and the push-down resource and pack-manifest contract tests. Line 94.93% (17145/18060), branch 90.48% (5995/6626).
- Jest, extension configuration: EXIT_CODE 0, 343/343 suites and 5624/5624 tests passed. Jest, worktree-root configuration: EXIT_CODE 0, 346/346 suites and 5641/5641 tests passed.
- Expected failures: none. The [expect-fail] tests of P1-T1 and P1-T3 pass after P1-T2 and P1-T4.
- The loop ended at 2026-11-14T08-57.
