# QC — Pester (with coverage)

Timestamp: 2026-08-19T08-58

Command: `mcp__drm-copilot__run_poshqc_test` (workspace_root=repo root) over scan folder `tests/scripts/claude-hooks`, using config `scripts/powershell/PoshQC/settings/pester.runsettings.psd1`. Coverage reported per-file under `artifacts/pester/`.

EXIT_CODE: 0

Output Summary:
- Total suite: 820 tests passed, 0 failures, 0 errors (JUnit `artifacts/pester/pester-junit.xml`).
- `enforce-epic-merge-gate.Tests.ps1` suite: 51 tests, 0 failures, 0 errors, 0 skipped (up from the pre-change count; the parallel allow/deny, extractor flag-order, parallel read-seam, and `Test-ParallelCheckpointAllowsMerge` branch-coverage `It` blocks were added).
- Post-change line coverage for `.claude/hooks/enforce-epic-merge-gate.ps1` (JaCoCo `artifacts/pester/powershell-coverage.xml`): LINE covered=100, missed=5, total=105 -> **95.24% line coverage**.
- The 5 missed lines remain the host-bound entrypoint block (env read, try/catch, `exit`), unchanged by this feature and exercised only by the out-of-process end-to-end tests.
- No test failed; no loop restart was required.
