# Baseline: Pester with Coverage — Issue #516

Timestamp: 2026-08-24T09-52

Command: `mcp__drm-copilot__run_poshqc_test` with `workspace_root: C:\Users\DanMoisan\repos\drm-copilot-wt\2026-08-24T09-02`

EXIT_CODE: 0

Output Summary:

Test counts (from `artifacts/pester/pester-junit.xml`, `<testsuites>` attributes):

- Tests: 3408
- Failures: 0
- Errors: 0
- Disabled/skipped: 9
- Wall time: 208.257 s

Line coverage (from `artifacts/pester/powershell-coverage.xml`, JaCoCo report-level counters):

- Report-level LINE counter: missed 255, covered 6407 → total 6662
- Overall baseline line coverage: **96.17%** (6407 / 6662)
- Report-level INSTRUCTION counter: missed 404, covered 8868 → 95.64% command coverage (informational only; no threshold attached per `.claude/rules/powershell.md`)

Per-file line coverage for the hook copies in scope:

| File | LINE missed | LINE covered | Line coverage |
| --- | --- | --- | --- |
| `.claude/hooks/enforce-orchestration-preimplementation-gate.ps1` | 11 | 99 | 90.00% |
| `.codex/hooks/enforce-orchestration-preimplementation-gate.ps1` | 1 | 121 | 99.18% |
| `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-orchestration-preimplementation-gate.ps1` | n/a | n/a | not itemized — outside the coverage scan set |
| `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-orchestration-preimplementation-gate.ps1` | n/a | n/a | not itemized — outside the coverage scan set |

The two bundled mirror copies are not measured because the PoshQC test scan set is `["scripts", "tests/powershell", "tests/scripts"]` (`config/poshqc-scan.json`); the coverage report itemizes only the source files those suites load. Their content is guaranteed identical to the measured copies by the push-down byte-parity relations verified in P5-T3 and P5-T4.
