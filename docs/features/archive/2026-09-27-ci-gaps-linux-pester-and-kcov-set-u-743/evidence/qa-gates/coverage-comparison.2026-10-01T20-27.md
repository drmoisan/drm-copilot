# PowerShell Coverage Comparison (P5-T2)

Timestamp: 2026-10-01T20-27

| Measure | Baseline B_PS (P0-T5, run 36901896617, head ecba8829) | Post-change (P4-T9, run 36918378249, head 42db4491) |
| --- | --- | --- |
| covered | 11236 | 11236 |
| missed | 430 | 430 |
| percent | 96.31 | 96.31 |

Sources: `evidence/remediation-baseline/windows-baseline.2026-10-01T19-02.md`, `evidence/qa-gates/ci-remediation-windows-results.2026-10-01T20-23.md`.

The changed files of this cycle are the five P0-T8 test files (no P4-T11 files):
`tests/scripts/claude-hooks/enforce-parallel-drift-gate.Tests.ps1`, `tests/scripts/claude-hooks/enforce-powershell-batch-budget-routing.Tests.ps1`, `tests/scripts/claude-hooks/enforce-python-batch-budget-routing.Tests.ps1`, `tests/scripts/codex-hooks/codex-powershell-batch-budget-routing.Tests.ps1`, `tests/scripts/codex-hooks/codex-python-batch-budget-routing.Tests.ps1`. They are tests, outside the coverage denominator; no production PowerShell file changed, so the unchanged covered and missed counts are the expected result.

Acceptance: every value numeric; post-change percent 96.31 is at least 85.00 and at least B_PS (96.31). Met.
