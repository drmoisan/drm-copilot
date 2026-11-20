# Baseline — Pester (with coverage)

Timestamp: 2026-08-19T08-58

Command: `mcp__drm-copilot__run_poshqc_test` (workspace_root=repo root) over scan folder `tests/scripts/claude-hooks`, using config `scripts/powershell/PoshQC/settings/pester.runsettings.psd1`. Coverage is enabled by the config and reported per-file under `artifacts/pester/`.

EXIT_CODE: 0

Output Summary:
- Tests: 799 passed, 0 failed, 0 errors (JUnit `artifacts/pester/pester-junit.xml`, `tests="799" errors="0" failures="0"`). The scan folder aggregates all `.claude/hooks` test suites, including `enforce-epic-merge-gate.Tests.ps1`.
- Baseline line coverage for the file under change `.claude/hooks/enforce-epic-merge-gate.ps1` (JaCoCo `artifacts/pester/powershell-coverage.xml`, sourcefile `enforce-epic-merge-gate.ps1`): LINE covered=71, missed=5, total=76 -> **93.42% line coverage**.
- The 5 missed lines correspond to the host-bound entrypoint block (env read, try/catch, `exit`), exercised only by the out-of-process end-to-end subprocess tests that in-process coverage instrumentation does not attribute.
