# Fail-Before — PowerShell Regression Gate (issue #472)

Timestamp: 2026-08-15T11-08

Command: `mcp__drm-copilot__run_poshqc_test` with `workspace_root: c:\Users\DanMoisan\repos\drm-copilot` and `scan_folders: ["tests/scripts/claude-lib/blast-radius"]`

EXIT_CODE: 2

Output Summary:

MCP result: `{"ok":false,"tool":"run_poshqc_test","summary":"Command exited with code 2."}`.

Pester JUnit report at `artifacts/pester/pester-junit.xml`: `tests="322" errors="0" failures="2" disabled="0" time="5.286"`.

## Failing cases (expected red against the pre-fix committed map)

Both failures are the two cases added by [P1-T4], and both are in
`tests/scripts/claude-lib/blast-radius/BlastRadius.Parity.Tests.ps1`:

| Case | Failure message |
| --- | --- |
| `Committed blast-radius truth table shape.Location-bucket modules.declares no location-bucket module in either committed copy` | `Expected $null or empty, but got @('tests', 'docs', 'docs', 'tests').` |
| `Committed blast-radius truth table shape.Disjoint work items.reports no contention between two items with disjoint paths` | `Expected $false, but got $true.` |

The first failure enumerates the location buckets present in both committed
copies (`tests`, `docs` from the repo-root copy and `docs`, `tests` from the
bundled copy). The second confirms the PowerShell mirror reproduces the same
false contention verdict the Python reference reports.

## Pre-existing cases all still pass

| Suite | Tests | Errors | Failures |
| --- | --- | --- | --- |
| `BlastRadius.Conflict.Tests.ps1` | 27 | 0 | 0 |
| `BlastRadius.Manifest.Tests.ps1` | 4 | 0 | 0 |
| `BlastRadius.Parity.Tests.ps1` | 65 | 0 | **2** |
| `BlastRadius.Tests.ps1` | 35 | 0 | 0 |
| `BlastRadius.Validation.Tests.ps1` | 31 | 0 | 0 |
| `BlastRadiusConfig.Tests.ps1` | 45 | 0 | 0 |
| `BlastRadiusExtraction.Path.Tests.ps1` | 45 | 0 | 0 |
| `BlastRadiusExtraction.Tests.ps1` | 21 | 0 | 0 |
| `BlastRadiusGlob.Tests.ps1` | 49 | 0 | 0 |
| **Total** | **322** | **0** | **2** |

`BlastRadiusConfig.Tests.ps1` reports zero failures, which includes the
fourteen-module count pin at line 434. That pin is still correct at this stage
because the configuration is unchanged; [P2-T3] amends it to twelve after the
[P2-T1] configuration correction.

The parity suite grew from 63 to 65 cases, matching the two additions, and the
folder total grew from the Phase 0 baseline of 320 to 322.

## Fail-before / pass-after pairing

- Fail-before (this artifact): `EXIT_CODE: 2`, two failures.
- Pass-after: `evidence/regression-testing/pass-after-pester.<ISO-8601>.md`, captured at P2-T5.

This red state is planned and evidenced; it is resolved by the Phase 2
configuration correction and the [P2-T3] count-pin amendment.
