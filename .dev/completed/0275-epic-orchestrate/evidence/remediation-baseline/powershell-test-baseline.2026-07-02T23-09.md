# PowerShell Test Baseline, with Coverage (Remediation Cycle 1)

- **Timestamp:** 2026-07-02T23-09
- **Task:** [P0-T5]
- **Command:** `mcp__drm-copilot__run_poshqc_test` (scan folder: `tests/scripts/claude-hooks`), using
  `scripts/powershell/PoshQC/settings/pester.runsettings.psd1`
- **EXIT_CODE:** 0

## Output Summary

Tool result: `ok: true`. Parsed `artifacts/pester/pester-junit.xml`:
`tests="467" errors="0" failures="0"` — **467/467 passing, 0 failed.**

Per-file line coverage (`artifacts/pester/powershell-coverage.xml`, JaCoCo/CoverageGutters
format) for the 5 pre-existing curated-scope hook files in `CodeCoverage.Path`:

| File | Line coverage |
|---|---|
| `.claude/hooks/check-powershell-test-purity.ps1` | 54/55 = 98.18% |
| `.claude/hooks/check-python-test-purity.ps1` | 60/60 = 100.00% |
| `.claude/hooks/enforce-powershell-batch-budget.ps1` | 78/81 = 96.30% |
| `.claude/hooks/enforce-python-batch-budget.ps1` | 78/81 = 96.30% |
| `.claude/hooks/validate-bash.ps1` | 31/38 = 81.58% |

No `BRANCH` counters are present in this coverage report format (line coverage only).

Confirmed the 5 hook files that are new/modified in this remediation cycle
(`enforce-epic-merge-gate.ps1`, `enforce-epic-wave-barrier.ps1`,
`enforce-epic-worktree-removal-gate.ps1`, `enforce-pr-author-skill.ps1`,
`validate-orchestrator-output.ps1`) are absent from `CodeCoverage.Path` in
`scripts/powershell/PoshQC/settings/pester.runsettings.psd1` at this baseline point — confirmed
by reading the file directly (see [P3-T1] for the fix).
