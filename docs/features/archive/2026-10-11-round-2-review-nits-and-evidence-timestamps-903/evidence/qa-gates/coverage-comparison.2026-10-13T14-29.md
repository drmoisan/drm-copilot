# Coverage comparison (P12-T28)

Timestamp: 2026-10-13T14-29
Command: comparison of recorded artifacts (no new command): `baseline/py-coverage-totals.2026-10-13T00-14.md` vs `qa-gates/py-coverage-totals.2026-10-13T13-47.md`; `baseline/py-cov-token-shapes.2026-10-13T00-14.md` vs `qa-gates/py-cov-token-shapes.2026-10-13T13-47.md`; `baseline/ts-jest-coverage.2026-10-13T10-42.md` vs `qa-gates/ts-jest-coverage.2026-10-13T13-49.md`; `baseline/ps-coverage-baseline.2026-10-13T11-14.md` vs `qa-gates/ps-coverage.2026-10-13T14-28.md`
EXIT_CODE: 1
Output Summary: Every value is numeric and every line value is at least 85 and every Python/TypeScript branch value at least 75. Python total (93.8 / 88.11) and TypeScript (Lines 97.26 / Branches 92.28) equal their baselines. `_blast_radius_token_shapes` 100.0 / 100.0 with an empty `Missing` column. PowerShell per-file: all ten at or above 85; three below their P1-T3 baseline (recorded, not blocking). PowerShell changed-line coverage 147/154 (95.45%) with 3 exempt and 4 non-exempt uncovered lines, so the P12-T24 rule is not met. Acceptance: FAIL on the PowerShell changed-line clause only; all other clauses PASS.

## Python

| Measure | Baseline (P0-T20 / P0-T21) | Final (P12-T5 / P12-T6) | Floor | Result |
|---|---|---|---|---|
| Whole-repo total line | 93.8 | 93.8 | 85 | pass, not below baseline |
| Whole-repo total branch | 88.11 | 88.11 | 75 | pass, not below baseline |
| `scripts.dev_tools._blast_radius_token_shapes` line | 100.0 (25 stmts, 0 missed) | 100.0 (27 stmts, 0 missed) | 85 | pass |
| `scripts.dev_tools._blast_radius_token_shapes` branch | 100.0 (8 branches) | 100.0 (10 branches) | 75 | pass |

New guard lines of `_blast_radius_token_shapes`: the P12-T6 `Missing` column is empty, so the two added statements and two added branches are covered.

## TypeScript (no production TypeScript file changed)

| Measure | Baseline (P0-T26) | Final (P12-T11) | Floor | Result |
|---|---|---|---|---|
| Lines | 97.26 | 97.26 | 85 | pass, not below baseline |
| Branches | 92.28 | 92.28 | 75 | pass, not below baseline |

## PowerShell (no branch gate)

Per-file line coverage (P1-T3 versus P12-T24):

| File | P1-T3 | P12-T24 | At least 85 | Versus baseline |
|---|---|---|---|---|
| .claude/lib/blast-radius/BlastRadiusTokenShape.psm1 | 100.0 | 100.0 | yes | equal |
| .claude/hooks/enforce-orchestration-preimplementation-gate-modes.ps1 | 98.54 | 98.54 | yes | equal |
| .codex/hooks/enforce-orchestration-preimplementation-gate-modes.ps1 | 90.37 | 90.37 | yes | equal |
| .claude/hooks/feature-folder-resolution.ps1 | 100.0 | 100.0 | yes | equal |
| .codex/hooks/feature-folder-resolution.ps1 | 100.0 | 100.0 | yes | equal |
| .claude/hooks/enforce-completion-consistency.ps1 | 93.84 | 93.96 | yes | higher |
| .claude/hooks/enforce-orchestration-preimplementation-gate-targets.ps1 | 100.0 | 99.39 | yes | lower (recorded, not blocking) |
| .codex/hooks/enforce-orchestration-preimplementation-gate-targets.ps1 | 100.0 | 98.16 | yes | lower (recorded, not blocking) |
| .claude/hooks/enforce-orchestration-preimplementation-gate-epic-scope.ps1 | 98.63 | 98.53 | yes | lower (recorded, not blocking) |
| .codex/hooks/enforce-orchestration-preimplementation-gate-epic-scope.ps1 | 78.33 | 89.09 | yes | higher |

Changed-line coverage (P12-T24): 147 of 154 executable added lines covered (95.45%). Uncovered: 3 exempt (`.claude/hooks/enforce-completion-consistency.ps1:484` rule (a); both targets copies line 167 rule (c)) and 4 non-exempt (`.codex/hooks/enforce-orchestration-preimplementation-gate-epic-scope.ps1:206`, `:207`; `.codex/hooks/enforce-orchestration-preimplementation-gate-targets.ps1:356`, `:370`). Details and reasons are in `ps-coverage.2026-10-13T14-28.md`.

## Acceptance

- Every value numeric: PASS.
- No line value below 85 and no Python/TypeScript branch value below 75: PASS.
- Python total and TypeScript Lines/Branches not below baseline: PASS.
- PowerShell per-file below-baseline values recorded and not blocking: recorded (three files).
- PowerShell changed-line coverage follows the P12-T24 rule: FAIL (four non-exempt uncovered changed lines; blocking finding carried from P12-T24).
