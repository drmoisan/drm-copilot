# Final QC (Remediation Cycle 1, Iteration 1): Coverage Comparison

Timestamp: 2026-10-08T20-47
Command: comparison of P0-T25, P5-T11, P5-T12 outputs
EXIT_CODE: 0
Output Summary: Seven rows, every verdict PASS: post-change line coverage is at least 85.00% for every R-PROD path, Missed is not above the baseline value for any path, and no changed executable line is uncovered. Sources: remediation-baseline/coverage-perfile.2026-10-08T20-19.md, qa-gates/coverage-perfile.rem1-1.2026-10-08T20-47.md, qa-gates/coverage-changed-lines.rem1-1.2026-10-08T20-47.md.

| ID | Path | Baseline (P0-T25) | Post-change (P5-T11) | Missed baseline -> post | Changed lines covered/executable (P5-T12) | Verdict |
|---|---|---|---|---|---|---|
| RW01 | `.claude/hooks/enforce-orchestration-preimplementation-gate-modes.ps1` | 97.79% | 97.81% | 3 -> 3 | 3/3 | PASS |
| RW02 | `.codex/hooks/enforce-orchestration-preimplementation-gate-modes.ps1` | 97.76% | 97.78% | 3 -> 3 | 3/3 | PASS |
| RW03 | `.claude/hooks/enforce-orchestration-preimplementation-gate.ps1` | 96.73% | 96.75% | 5 -> 5 | 4/4 | PASS |
| RW04 | `.codex/hooks/enforce-orchestration-preimplementation-gate.ps1` | 100.00% | 100.00% | 0 -> 0 | 4/4 | PASS |
| RW05 | `.claude/hooks/enforce-epic-wave-barrier.ps1` | 96.70% | 96.70% | 3 -> 3 | 1/1 | PASS |
| RW06 | `.claude/hooks/enforce-parallel-cohort-barrier.ps1` | 96.10% | 96.10% | 3 -> 3 | 1/1 | PASS |
| RW07 | `.claude/hooks/enforce-parallel-drift-gate.ps1` | 98.23% | 98.23% | 2 -> 2 | 1/1 | PASS |
