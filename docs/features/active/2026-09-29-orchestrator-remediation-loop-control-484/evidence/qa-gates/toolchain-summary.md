# Seven-Stage Toolchain Summary (P11-T5)

Timestamp: 2026-10-01T23-10
Task: P11-T5
Command: none (summary of the artifacts listed below)
EXIT_CODE: 0

Clean iteration: loop iteration 2 of Phases 8-10. Iteration 1 stopped at P8-T5 with two new failures (deviation D9); the fix was committed in f8d1d136 and the loop restarted from P8-T1. In iteration 2 every stage below passed and no stage changed a file: P8-T1 and P9-T1 ran in check mode with no drift, and P10-T1 recorded identical before and after hashes for all eight files with an empty `git status --porcelain -- .claude tests extensions`.

## Stage-to-artifact map (iteration 2)

| Stage | Python | TypeScript | PowerShell |
|---|---|---|---|
| 1. Format | `black-final.md` (P8-T1) EXIT_CODE 0 | `prettier-final.md` (P9-T1) EXIT_CODE 0 | `poshqc-format-final.md` (P10-T1) EXIT_CODE 0 (call disposition; no rewrite) |
| 2. Lint | `ruff-final.md` (P8-T2) EXIT_CODE 0 | `eslint-final.md` (P9-T2) EXIT_CODE 0 | `poshqc-analyze-final.md` (P10-T2) EXIT_CODE 0 = ExpectedExitCode 0; `pssa-direct-final.md` (P10-T3) EXIT_CODE 0, `Findings=0 Errors=0` |
| 3. Type check | `pyright-final.md` (P8-T3) EXIT_CODE 0 | `tsc-final.md` (P9-T3) EXIT_CODE 0 | not applicable |
| 4. Architecture | `architecture-python-final.md` (P8-T4): no tool configured (P0-T21 skip branch; the recorded `git grep` EXIT_CODE 1 is the no-match result that selects the branch) | `architecture-typescript-final.md` (P9-T4): no tool configured, EXIT_CODE 0 | none configured (P0-T21) |
| 5. Unit tests | `pytest-full-final.md` (P8-T5) EXIT_CODE 0; `pytest-targeted-coverage-final.md` (P8-T6) EXIT_CODE 0 | `jest-coverage-final.md` (P9-T5) EXIT_CODE 0 | `poshqc-test-final.md` (P10-T4) EXIT_CODE 1 = ExpectedExitCode 1; `pester-full-coverage-read.md` (P10-T5) EXIT_CODE 2 = ExpectedExitCode 2; `pester-accounting-coverage-final.md` (P10-T6) EXIT_CODE 38 = ExpectedExitCode 38; `pester-receipts-coverage-final.md` (P10-T7) EXIT_CODE 38 = ExpectedExitCode 38 |
| 6. Contract | `contract-parity-python.md` (P8-T8) EXIT_CODE 0 | `contract-parity-jest.md` (P9-T7) EXIT_CODE 0 | `contract-parity-pester.md` (P10-T8) EXIT_CODE 0 |
| 7. Integration | `integration-python-final.md` (P8-T9) EXIT_CODE 0 | `integration-typescript-final.md` (P9-T8) EXIT_CODE 0 | `pester-manifest-final.md` (P10-T9) EXIT_CODE 0 |

All listed artifacts exist under `evidence/qa-gates/` and record `Loop iteration: 2`.

## Non-zero ExpectedExitCode declarations and their authorizing baselines

| Artifact | ExpectedExitCode | Authorizing baseline | Basis |
|---|---|---|---|
| `poshqc-test-final.md` (P10-T4) | 1 | P0-T32 (`evidence/baseline/poshqc-test-baseline.md`, EXIT_CODE 1) | failing set identical to P0-T32 (two hook tests), errors 0 |
| `pester-full-coverage-read.md` (P10-T5) | 2 | P0-T32 | conditions (a)-(c) of P10-T5 hold |
| `pester-accounting-coverage-final.md` (P10-T6) | 38 | P0-T30 (`evidence/baseline/pester-receipts-coverage-baseline.md`, EXIT_CODE 38) | deviation D10: the 38 pre-existing issue-adoption failures, set unchanged |
| `pester-receipts-coverage-final.md` (P10-T7) | 38 | P0-T30 | deviation D10 |

P10-T6 and P10-T7 are not in the plan's baseline-identity list for this task; they are added here under deviation D10 because P0-T30, the command they re-run, recorded the same 38 failures. P8-T1, P8-T2, P8-T3, P8-T5, P8-T9, P9-T1, P9-T2, and P9-T5 all recorded EXIT_CODE 0, so no baseline authorization was needed for them; P10-T2 declares ExpectedExitCode 0.

## Output Summary:

- Python: format, lint, type, unit, contract, integration pass; architecture not configured.
- TypeScript: format, lint, type, unit, contract, integration pass; architecture not configured.
- PowerShell: format, lint, unit (baseline-identical failure sets only), contract, integration pass; type check not applicable; architecture not configured.
- Clean iteration: 2.
