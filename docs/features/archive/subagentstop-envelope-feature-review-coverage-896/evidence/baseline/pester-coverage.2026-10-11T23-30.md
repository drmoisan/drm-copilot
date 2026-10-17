# Baseline Per-File Coverage (P0-T14; AC-25 baseline half)

Timestamp: 2026-10-11T23-53
Command: CR-COV-FILES (scratchpad route) with <LIST> = LIST-PROD-BASE (.claude/hooks/validate-feature-review-coverage.ps1, .claude/hooks/feature-review-coverage-thresholds.ps1, .codex/hooks/validate-feature-review-coverage.ps1), run immediately after the P0-T13 full run with no Pester run in between; then CR-COV-CHANGED with the same list (observation run)
EXIT_CODE: 0
Output Summary: baseline line coverage on the merged base: .claude/hooks/validate-feature-review-coverage.ps1 pct=98.62 (215/218); .claude/hooks/feature-review-coverage-thresholds.ps1 pct=100.00 (21/21); .codex/hooks/validate-feature-review-coverage.ps1 pct=99.29 (140/141). COVERAGE-BELOW-85: NONE. CR-COV-CHANGED observation: changed=0 for all three files, CHANGED-BELOW-85: NONE.

MeasuredCodexCoverage: .codex/hooks/validate-feature-review-coverage.ps1 pct=99.29 (covered=140, missed=1). A previously cited figure of 7.30% does not match this measurement and is not used.

## CR-COV-FILES output

```
COVERAGE: .claude/hooks/validate-feature-review-coverage.ps1 | covered=215 | missed=3 | pct=98.62
COVERAGE: .claude/hooks/feature-review-coverage-thresholds.ps1 | covered=21 | missed=0 | pct=100.00
COVERAGE: .codex/hooks/validate-feature-review-coverage.ps1 | covered=140 | missed=1 | pct=99.29
COVERAGE-BELOW-85: NONE
EXIT_CODE_COMPUTED: 0
PROCESS_EXIT: 0
```

## CR-COV-CHANGED output (observation run)

```
CHANGED-COVERAGE: .claude/hooks/validate-feature-review-coverage.ps1 | changed=0 | executable=0 | covered=0 | pct=100.00
CHANGED-COVERAGE: .claude/hooks/feature-review-coverage-thresholds.ps1 | changed=0 | executable=0 | covered=0 | pct=100.00
CHANGED-COVERAGE: .codex/hooks/validate-feature-review-coverage.ps1 | changed=0 | executable=0 | covered=0 | pct=100.00
CHANGED-BELOW-85: NONE
EXIT_CODE_COMPUTED: 0
PROCESS_EXIT: 0
```
