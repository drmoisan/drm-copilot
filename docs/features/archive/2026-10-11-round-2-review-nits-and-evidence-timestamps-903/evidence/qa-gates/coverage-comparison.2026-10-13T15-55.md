# Coverage comparison (P12-T28 rerun, remediation cycle 1 P6-T2)

Timestamp: 2026-10-13T15-55
Command: comparison of recorded artifacts (no new command): `baseline/py-coverage-totals.2026-10-13T00-14.md` vs `qa-gates/py-coverage-totals.2026-10-13T13-47.md`; `baseline/py-cov-token-shapes.2026-10-13T00-14.md` vs `qa-gates/py-cov-token-shapes.2026-10-13T13-47.md`; `baseline/ts-jest-coverage.2026-10-13T10-42.md` vs `qa-gates/ts-jest-coverage.2026-10-13T13-49.md`; `baseline/ps-coverage-baseline.2026-10-13T11-14.md` vs `qa-gates/ps-coverage.2026-10-13T15-55.md`
EXIT_CODE: 0
Output Summary: Every value is numeric; every line value is at least 85 and every Python/TypeScript branch value at least 75. Python total (93.8 / 88.11) and TypeScript (Lines 97.26 / Branches 92.28) equal their baselines. `_blast_radius_token_shapes` 100.0 / 100.0. PowerShell per-file: all ten at or above 85; three below their P1-T3 baseline (recorded, not blocking). PowerShell changed-line coverage 149/154 (96.75%), all 5 uncovered lines exempt under (a), (c), or (d). P12-T28: PASS.

Remediation scope: the remediation changed no Python or TypeScript file. The P4-T5 name-status listing (`evidence/qa-gates/rem1-scope.2026-10-13T15-32.md`) contains, outside `<FEATURE>/`, only `M tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-targets.Tests.ps1` and `A tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-epic-scope.Decision.Tests.ps1`; Phase 5 and Phase 6 commits change only `<FEATURE>/` paths. The Python and TypeScript values are therefore carried from the existing artifacts (each is the lexicographically greatest file of its name in its folder).

## Python

| Measure | Baseline | Final | Floor | Result |
|---|---|---|---|---|
| Whole-repo total line | 93.8 | 93.8 | 85 | pass, not below baseline |
| Whole-repo total branch | 88.11 | 88.11 | 75 | pass, not below baseline |
| `scripts.dev_tools._blast_radius_token_shapes` line | 100.0 | 100.0 | 85 | pass |
| `scripts.dev_tools._blast_radius_token_shapes` branch | 100.0 | 100.0 | 75 | pass |

## TypeScript (no production TypeScript file changed)

| Measure | Baseline | Final | Floor | Result |
|---|---|---|---|---|
| Lines | 97.26 | 97.26 | 85 | pass, not below baseline |
| Branches | 92.28 | 92.28 | 75 | pass, not below baseline |

## PowerShell (no branch gate)

Per-file line coverage (P1-T3 versus P6-T1):

| File | P1-T3 | P6-T1 | At least 85 | Versus baseline |
|---|---|---|---|---|
| .claude/lib/blast-radius/BlastRadiusTokenShape.psm1 | 100.0 | 100.0 | yes | equal |
| .claude/hooks/enforce-orchestration-preimplementation-gate-modes.ps1 | 98.54 | 98.54 | yes | equal |
| .codex/hooks/enforce-orchestration-preimplementation-gate-modes.ps1 | 90.37 | 90.37 | yes | equal |
| .claude/hooks/feature-folder-resolution.ps1 | 100.0 | 100.0 | yes | equal |
| .codex/hooks/feature-folder-resolution.ps1 | 100.0 | 100.0 | yes | equal |
| .claude/hooks/enforce-completion-consistency.ps1 | 93.84 | 93.96 | yes | higher |
| .claude/hooks/enforce-orchestration-preimplementation-gate-targets.ps1 | 100.0 | 99.39 | yes | lower (recorded, not blocking) |
| .codex/hooks/enforce-orchestration-preimplementation-gate-targets.ps1 | 100.0 | 99.39 | yes | lower (recorded, not blocking) |
| .claude/hooks/enforce-orchestration-preimplementation-gate-epic-scope.ps1 | 98.63 | 98.53 | yes | lower (recorded, not blocking) |
| .codex/hooks/enforce-orchestration-preimplementation-gate-epic-scope.ps1 | 78.33 | 89.09 | yes | higher |

Changed-line coverage (P6-T1): 149 of 154 executable added lines covered (96.75%). Uncovered and exempt: `.claude/hooks/enforce-completion-consistency.ps1:484` (a); both targets copies line 167 (c); `.codex/hooks/enforce-orchestration-preimplementation-gate-epic-scope.ps1:206` and `:207` (d, per `rem1-ri2-exemption.2026-10-13T15-54.md`). Details are in `ps-coverage.2026-10-13T15-55.md`.

## Acceptance

- Every value numeric: PASS.
- No line value below 85 and no Python/TypeScript branch value below 75: PASS.
- Python total and TypeScript Lines/Branches not below baseline: PASS.
- PowerShell per-file below-baseline values recorded and not blocking: recorded (three files).
- PowerShell changed-line coverage follows the P6-T1 rule including its exempt lines: PASS.

P12-T28: PASS
