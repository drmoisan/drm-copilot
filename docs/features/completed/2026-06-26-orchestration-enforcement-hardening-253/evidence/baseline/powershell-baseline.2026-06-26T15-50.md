# PowerShell Baseline — Issue #253

- Timestamp: 2026-06-26T15-50

## Command 1 — PoshQC format (check)

- Timestamp: 2026-06-26T15-50
- Command: `mcp__drm-copilot__run_poshqc_format` (scan_folders: `.claude/hooks`)
- EXIT_CODE: 0
- Output Summary: Format ran successfully over `.claude/hooks`. `git status --short .claude/hooks/` reported no working-tree changes after the run, confirming the hook scripts are already format-clean.

## Command 2 — PoshQC analyze

- Timestamp: 2026-06-26T15-50
- Command: `mcp__drm-copilot__run_poshqc_analyze` (scan_folders: `.claude/hooks`)
- EXIT_CODE: 0
- Output Summary: Analyze ran successfully over `.claude/hooks`. No analyzer-driven file changes; baseline is analyzer-clean for the hook scripts.

## Command 3 — Pester with coverage

- Timestamp: 2026-06-26T15-50
- Command: `mcp__drm-copilot__run_poshqc_test` (scan_folders: `tests/scripts/claude-hooks`)
- EXIT_CODE: 0
- Output Summary: JUnit report `artifacts/pester/pester-junit.xml` reports `tests="306" errors="0" failures="0"`. All claude-hooks Pester tests pass at baseline.

### Per-script coverage for the three hook scripts in scope

The bundled `pester.runsettings.psd1` scopes its `CodeCoverage.Path` to a different set of hook scripts and does not include the three scripts changed by this feature. To record numeric baseline coverage for the in-scope scripts, Pester was run with an explicit `CodeCoverage.Path` limited to the three target hooks against their three test files (JaCoCo output `artifacts/pester/hook-scope-coverage.xml`). PowerShell/Pester JaCoCo coverage is command/line-based and does not emit BRANCH counters.

- `validate-orchestrator-output.ps1`: LINE 89.0% (65/73), INSTRUCTION 90.8% (118/130).
- `enforce-completion-consistency.ps1`: LINE 92.4% (85/92), INSTRUCTION 94.0% (110/117).
- `enforce-orchestration-preimplementation-gate.ps1`: LINE 73.4% (58/79), INSTRUCTION 72.8% (67/92).

Note: `enforce-orchestration-preimplementation-gate.ps1` baseline line coverage (73.4%) is below the 85% threshold. The issue-232-specific dead branches contribute uncovered lines; P5 removes that hardcoding and P5-T2 adds generalized tests to raise coverage above threshold.
