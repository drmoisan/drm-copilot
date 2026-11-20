# PowerShell Test Baseline (P0-T4)

- Timestamp: 2026-07-02T19-30
- Command: `mcp__drm-copilot__run_poshqc_test` (Pester with coverage, `scripts/powershell/PoshQC/settings/pester.runsettings.psd1`, scan folder: `tests/scripts/claude-hooks`)
- EXIT_CODE: 0

## Output Summary

`ok: true`. Full suite: 378 tests, 0 failures, 0 errors (`artifacts/pester/pester-junit.xml`).

Baseline coverage (`artifacts/pester/powershell-coverage.xml`, JaCoCo counters over the
`.claude/hooks` scope exercised by `tests/scripts/claude-hooks`):

- LINE coverage: 48.63% (covered 301, missed 318, total 619).
- INSTRUCTION coverage: 51.28% (covered 462, missed 439, total 901) — used as the closest
  decision-path-discriminating proxy metric since Pester's JaCoCo export does not emit a
  distinct BRANCH counter.
- METHOD coverage: 47.37% (covered 27, missed 30, total 57).

This is the pre-change baseline across the full `.claude/hooks` scope (not scoped to the
files this plan will touch); it is recorded for delta comparison in P6-T5, not as a
pass/fail gate at baseline.
