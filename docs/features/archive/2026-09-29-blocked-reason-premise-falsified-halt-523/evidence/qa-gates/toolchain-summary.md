# Seven-Stage Toolchain Summary (P11-T5)

Timestamp: 2026-09-30T15-56
Command: summary of the stage artifacts listed below (no new command run)
EXIT_CODE: 0
Output Summary: Every stage passed without changing a file in final QA loop iteration 2 (Phases 8-10 run 2026-09-30T15-41 to 15-52, after remediation cycle 1). Every listed artifact exists and carries `EXIT_CODE: 0` or an `EXIT_CODE` equal to its declared `ExpectedExitCode` (P10-T4: `EXIT_CODE: 1`, `ExpectedExitCode: 1`, failing set equal to the two pre-existing P0-T26 cases).

Named iteration: **final QA loop iteration 2**. Iteration 1 (2026-09-30T15-04 to 15-18) halted at P10-T4 on the #673 exact-count pin; remediation cycle 1 (`remediation-plan.2026-09-30T15-20.md`, commits df9bddd5, d033ee68, 31453a9d) replaced the pin with the 500-line cap bound, and the loop restarted from P8-T1 under the main plan's restart rule. No step in iteration 2 failed or changed a file.

## Stage map

| Stage | Task | Artifact | Iteration | Result |
|---|---|---|---|---|
| Format | P8-T1 | `evidence/qa-gates/black-final.md` | 2 | EXIT_CODE 0; `539 files would be left unchanged.` |
| Format | P9-T1 | `evidence/qa-gates/prettier-final.md` | 2 | EXIT_CODE 0; `All matched files use Prettier code style!` |
| Format | P10-T1 | `evidence/qa-gates/poshqc-format-final.md` | 2 | EXIT_CODE 0 (call disposition); five hashes unchanged; status empty |
| Lint | P8-T2 | `evidence/qa-gates/ruff-final.md` | 2 | EXIT_CODE 0; `All checks passed!` |
| Lint | P9-T2 | `evidence/qa-gates/eslint-final.md` | 2 | EXIT_CODE 0; no problem lines |
| Lint | P10-T2 | `evidence/qa-gates/poshqc-analyze-final.md` | 2 | EXIT_CODE 0 (`ok:true`) = ExpectedExitCode 0 (P0-T27) |
| Lint | P10-T3 | `evidence/qa-gates/pssa-direct-final.md` | 2 | EXIT_CODE 0; `Findings=0 Errors=0` |
| Type-check | P8-T3 | `evidence/qa-gates/pyright-final.md` | 2 | EXIT_CODE 0; `0 errors, 0 warnings, 0 informations` |
| Type-check | P9-T3 | `evidence/qa-gates/tsc-final.md` | 2 | EXIT_CODE 0; no `error TS` line |
| Type-check | PowerShell | n/a | n/a | not applicable to PowerShell |
| Architecture | P9-T4 | `evidence/qa-gates/architecture-final.md` | 2 | EXIT_CODE 0; no tool configured (authorized by P0-T16) |
| Unit tests | P8-T4 | `evidence/qa-gates/pytest-full-final.md` | 2 | EXIT_CODE 0; 5885 passed, 6 skipped; TOTAL Cover 92% |
| Unit tests | P8-T5 | `evidence/qa-gates/pytest-targeted-coverage-final.md` | 2 | EXIT_CODE 0; 749 passed |
| Unit tests | P9-T5 | `evidence/qa-gates/jest-coverage-final.md` | 2 | EXIT_CODE 0; 3457 passed; Lines 97.04%, Branches 91.21% |
| Unit tests | P10-T4 | `evidence/qa-gates/poshqc-test-final.md` | 2 | EXIT_CODE 1 (`ok:false`) = ExpectedExitCode 1; Tests 6201, Failures 2 (both in P0-T26 set), Errors 0 |
| Unit tests | P10-T5 | `evidence/qa-gates/pester-orchestrator-state-coverage-final.md` | 2 | EXIT_CODE 0; 487 passed; line 110/110 = 100.00% |
| Contract | P7-T10 | `evidence/qa-gates/contract-parity-python.md` | pre-loop (Phase 7) | EXIT_CODE 0; 98 passed |
| Contract | P7-T11 | `evidence/qa-gates/contract-parity-jest.md` | pre-loop (Phase 7) | EXIT_CODE 0; 2 suites, 72 passed |
| Contract | P7-T12 | `evidence/qa-gates/contract-parity-pester.md` | pre-loop (Phase 7) | EXIT_CODE 0; `Passed=64 Failed=0` |
| Integration | P6-T12 | `evidence/qa-gates/bundle-contract-tests-after.md` | pre-loop (Phase 6) | EXIT_CODE 0; 38 passed |
| Integration | P10-T6 | `evidence/qa-gates/pester-manifest-final.md` | 2 | EXIT_CODE 0; `Passed=6 Failed=0`, byte-identity row `1` |

## Pre-loop stage artifacts (contract and integration)

The plan maps the contract stage to P7-T10, P7-T11, P7-T12 and part of the integration stage to P6-T12. Those tasks sit before the Phase 8-10 loop, so the restart rule does not re-run them, and their artifacts were produced before iteration 1. Their validity for iteration 2 rests on this observation: `git diff --name-status 8833118e HEAD -- scripts tests .claude .agents extensions` (8833118e is the commit that recorded the Phase 7 evidence) lists exactly one path, `M tests/scripts/claude-runtime/enforcement-hooks-checkpoint-path-explicit.Tests.ps1`, which none of the P6-T12 or P7-T10..T12 commands executes. The tree those four commands test is therefore unchanged in iteration 2.

## Coverage comparisons (Phase 11)

- Python: `evidence/qa-gates/coverage-comparison-python.md` — `validate_orchestrator_state.py` line 98.82% / branch 97.56% (baseline equal); new module 100.00% / 100.00%; changed-line intersection empty.
- TypeScript: `evidence/qa-gates/coverage-comparison-typescript.md` — core line 98.91% / branch 96.25%; new module 100.00% / 100.00%; no uncovered added line.
- PowerShell: `evidence/qa-gates/coverage-comparison-powershell.md` — 100.00% baseline and post-change; every changed line with a `line` element has `ci` > 0.
