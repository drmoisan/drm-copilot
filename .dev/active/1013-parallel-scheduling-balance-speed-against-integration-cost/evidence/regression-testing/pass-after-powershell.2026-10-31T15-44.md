# Pass-After — PowerShell Implementation (Phase 5 gate)

Timestamp: 2026-10-31T15-44
Command: sh SCRATCH/issue-1013-pester-run.sh p5t10 (branch-current PowerShell 7 Invoke-Pester over tests/scripts/claude-lib/blast-radius and tests/scripts/claude-hooks/enforce-model-routing-receipt.AuthorAsserted.Tests.ps1; counts read from the JUnit file)
EXIT_CODE: 0
Output Summary: JUnit tests=769 failures=2 errors=0 skipped=1. The two failures are the planned pending rows of BlastRadius.Manifest.Tests.ps1 (pending P8-T1 and P8-T2).

## Failing rows (pending P8-T1 and P8-T2)

- `Blast-radius core.json manifest membership.Library coverage.lists every discovered library module in core.json paths` — `BlastRadiusAggregate.psm1` and `BlastRadiusCombination.psm1` have no `core.json` entry until P8-T2.
- `Blast-radius core.json manifest membership.Bundled payload parity.ships a bundled counterpart for every library module` — the two new modules have no bundled copy until P8-T1.

## Passing suites of note

- `BlastRadiusAggregate.Tests.ps1`, `BlastRadiusCombination.Tests.ps1`, and `BlastRadiusScheduling.ContractWeight.Tests.ps1`: zero failures.
- `BlastRadius.Tests.ps1`: `'exports no function beyond the spec-fixed names'` passes with the expected count 15.
- `enforce-model-routing-receipt.AuthorAsserted.Tests.ps1`: AA-01 to AA-14 pass, including the new rows AA-13 (checkpoint number first) and AA-14 (checkpoint number second).

CI shape: the blast-radius suites run in `poshqc / PowerShell QC`, and the AuthorAsserted rows also run in `poshqc / PowerShell hook suites (Linux)`.
