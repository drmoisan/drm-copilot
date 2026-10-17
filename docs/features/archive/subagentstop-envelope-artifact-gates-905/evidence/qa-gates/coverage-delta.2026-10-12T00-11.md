# Coverage delta (plan [P12-T9], AC-25, issue #905)

Timestamp: 2026-10-12T00-11
Command: comparison of `evidence/baseline/baseline-coverage-per-file.2026-10-11T15-01.md` ([P0-T25]), `evidence/qa-gates/final-coverage-per-file.2026-10-12T00-10.md` ([P12-T7]), and `evidence/qa-gates/final-changed-line-coverage.2026-10-12T00-10.md` ([P12-T8])
EXIT_CODE: 0
Output Summary: four PASS rows; every post-change and changed-line value is at least 85.00, and no file regressed from its baseline.

| File | Baseline % ([P0-T25]) | Post-change % ([P12-T7]) | Changed lines covered/total ([P12-T8]) | Changed-line % | Result |
|---|---|---|---|---|---|
| `.claude/hooks/validate-discovery-artifact-gate.ps1` | 92.65 | 100.00 | 12/12 | 100.00 | PASS |
| `.claude/hooks/validate-pr-author-output.ps1` | 100.00 | 100.00 | 10/10 | 100.00 | PASS |
| `.claude/hooks/validate-prd-feature-output.ps1` | 98.15 | 100.00 | 23/23 | 100.00 | PASS |
| `.claude/hooks/validate-task-researcher-output.ps1` | 90.00 | 98.06 | 16/16 | 100.00 | PASS |
