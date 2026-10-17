# Coverage delta (P12-T2)

Timestamp: 2026-10-12T08-38
Command: scratchpad route; CR-COV-CHANGED with <LIST> = LIST-PROD against origin/epic/subagentstop-envelope-integration...HEAD (after the Phase 11 commit b32ea7d75; artifacts/pester/powershell-coverage.xml from the pass 3 P11-T7 run)
EXIT_CODE: 0
Output Summary: six CHANGED-COVERAGE lines, all at or above 98.67; CHANGED-BELOW-85: NONE; no post-change figure below 85.00 (lowest 98.82, H1); Codex hook baseline 99.29 -> post-change 100.00, changed lines 100.00

## Output (e896-covtable)

```
| File | Baseline pct (P0-T14) | Post-change pct (P11-T8) | Changed-line pct (P12-T2) |
|---|---|---|---|
| .claude/hooks/validate-feature-review-coverage.ps1 | 98.62 | 98.82 | 98.67 |
| .claude/hooks/validate-feature-review-coverage-metrics.ps1 | NEW | 100.00 | 100.00 |
| .claude/hooks/validate-feature-review-coverage-rules.ps1 | NEW | 98.88 | 98.88 |
| .claude/hooks/feature-review-coverage-thresholds.ps1 | 100.00 | 100.00 | 100.00 |
| .codex/hooks/validate-feature-review-coverage.ps1 | 99.29 | 100.00 | 100.00 |
| .codex/hooks/feature-review-coverage-thresholds.ps1 | NEW | 100.00 | 100.00 |
```

## Output (e896-covchg)

```
CHANGED-COVERAGE: .claude/hooks/validate-feature-review-coverage.ps1 | changed=124 | executable=75 | covered=74 | pct=98.67
CHANGED-COVERAGE: .claude/hooks/validate-feature-review-coverage-metrics.ps1 | changed=180 | executable=72 | covered=72 | pct=100.00
CHANGED-COVERAGE: .claude/hooks/validate-feature-review-coverage-rules.ps1 | changed=195 | executable=89 | covered=88 | pct=98.88
CHANGED-COVERAGE: .claude/hooks/feature-review-coverage-thresholds.ps1 | changed=17 | executable=1 | covered=1 | pct=100.00
CHANGED-COVERAGE: .codex/hooks/validate-feature-review-coverage.ps1 | changed=20 | executable=9 | covered=9 | pct=100.00
CHANGED-COVERAGE: .codex/hooks/feature-review-coverage-thresholds.ps1 | changed=85 | executable=21 | covered=21 | pct=100.00
CHANGED-BELOW-85: NONE
EXIT_CODE_COMPUTED: 0
PROCESS_EXIT: 0
```
