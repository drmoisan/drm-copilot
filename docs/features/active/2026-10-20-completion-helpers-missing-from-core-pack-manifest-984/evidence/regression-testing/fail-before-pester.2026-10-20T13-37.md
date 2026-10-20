# Fail-Before Run, Pester (Issue #984)

Timestamp: 2026-10-20T13-37
Command: sh SCRATCH/issue-984-run-files.sh issue-984-p2t5 issue-984-new-suites.txt (one PowerShell 7 process: Invoke-Pester over the four new suites with JUnit output to artifacts/pester/pester-junit.xml, coverage off; the launcher then exits 1 when the JUnit failed count is non-zero)
EXIT_CODE: 1
ExpectedExitCode: 1
Output Summary: against the unchanged hooks, 76 test cases: 26 passed, 50 failed, 0 skipped (JUnit). The failing set is exactly CH1, CH2, CH4, CH6, DV1, DV2, DV3, DV5, BB1, BB2, BB4, CB1, CB2 for every root and hook; CH0, CH3, CH5, DV0, DV4, BB0, BB3, CB0, CB3 pass.

Suites (in run order):

- `tests/scripts/claude-hooks/enforce-completion-consistency.HelperImportFailure.Tests.ps1`
- `tests/scripts/claude-hooks/enforce-discovery-artifact-gate.ValidationImportFailure.Tests.ps1`
- `tests/scripts/claude-hooks/enforce-batch-budget.RouteImportFailure.Tests.ps1`
- `tests/scripts/codex-hooks/codex-batch-budget.RouteImportFailure.Tests.ps1`

## Failing tests (50), per root (repository and mirror)

| Row | Count per root | Failure cause observed |
|---|---|---|
| CH1 (`src/App/App.csproj`, `README.md`) | 2 | `Expected 'enforce-completion-helpers.ps1', because E-CONSTRUCTION, but got $null.` |
| CH2 (Write and Edit; relative, absolute, backslash) | 6 | E-CONSTRUCTION: handler variable is `$null` |
| CH4 | 1 | observed deny on stdout: `COMPLETION_CONSISTENCY_BLOCKED: the dependency 'enforce-completion-helpers.ps1' failed to load (simulated load failure: enforce-completion-helpers.ps1)...` |
| CH6 | 1 | E-CONSTRUCTION: handler variable is `$null` |
| DV1 (`README.md`, `src/app.ts`) | 2 | E-CONSTRUCTION: handler variable is `$null` |
| DV2 | 1 | E-CONSTRUCTION: handler variable is `$null` |
| DV3 | 1 | E-CONSTRUCTION: handler variable is `$null` |
| DV5 | 1 | observed deny on stdout: `DISCOVERY_ARTIFACT_GATE_BLOCKED: the dependency 'DiscoveryValidation.psm1' failed to load...` |
| BB1, BB2 (Python and PowerShell hooks) | 4 | E-CONSTRUCTION: handler variable is `$null` |
| BB4 (Python and PowerShell hooks) | 2 | observed deny on stdout, for example `PYTHON_LARGE_PATH_REQUIRED: the dependency 'enforce-batch-budget-route.ps1' failed to load...` |
| CB1, CB2 (Codex Python and PowerShell hooks) | 4 | E-CONSTRUCTION: handler variable is `$null` |

Totals: Claude completion 10 x 2 roots = 20; discovery 5 x 2 = 10; Claude batch 6 x 2 = 12; Codex batch 4 x 2 = 8; sum 50.

## Passing tests (26)

CH0, CH3, CH5 (3 x 2 roots = 6); DV0, DV4 (2 x 2 = 4); BB0, BB3 for both hooks (4 x 2 = 8); CB0, CB3 for both hooks (4 x 2 = 8). These hold before the fix and must keep holding after it.
