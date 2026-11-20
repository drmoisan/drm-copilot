# Coverage Comparison: Final Gates vs Phase 0 Baseline (P7-T7)

Timestamp: 2026-11-14T17-11
Command: comparison of evidence/qa-gates/final-qc-pester.2026-11-14T17-11.md, final-qc-pytest.2026-11-14T17-11.md and final-qc-jest.2026-11-14T17-11.md with evidence/baseline/pester-baseline.2026-11-14T07-12.md, pytest-baseline.2026-11-14T07-18.md and jest-baseline.2026-11-14T07-20.md
EXIT_CODE: 0
Output Summary:

## Failing tests

| Gate | Phase 0 baseline | Final | New failing tests |
|---|---|---|---|
| Pester (one parallel run) | 0 failures (JUnit tests=24065) | 0 failures (JUnit tests=24333) | none |
| pytest -n auto | 1 failed (the `__pycache__` payload enumeration, fixed in P1-T3) | 0 failed (16735 passed) | none |
| Jest | 0 failed (5554 tests) | 0 failed (5592 tests) | none |

## Repo-wide coverage

| Language | Baseline | Final | Result |
|---|---|---|---|
| PowerShell line (repo-wide) | 95.94% | 95.99% | no drop |
| TypeScript lines (extension) | 97.17% | 97.18% | no drop |
| TypeScript branches (extension) | 93.94% | 93.98% | no drop |

## PowerShell (85% line each)

| File | Baseline | Final | Result |
|---|---|---|---|
| DocsLedgerCommands.psm1 | 99.67 | 99.69 | PASS |
| Invoke-DocsCommand.ps1 | 90.82 | 90.91 | PASS |
| DocsReferencePlan.psm1 | 100.00 | 100.00 | PASS |
| DocsReferenceWriter.psm1 | 100.00 | 100.00 | PASS |
| DocsProfile.psm1 | 100.00 | 100.00 | PASS |
| DocsProfileCommands.psm1 | 97.33 | 97.75 | PASS |
| DocsPageLinks.psm1 | 100.00 | 100.00 | PASS |
| DocsInventorySnapshot.psm1 | 100.00 | 100.00 | PASS |
| DocsPythonCliArgparse.psm1 | 100.00 | 100.00 | PASS |
| DocsAnalyzerPythonCli.psm1 | 100.00 | 100.00 | PASS |
| DocsJson.psm1 | 100.00 | 100.00 | PASS |
| DocsValidation.psm1 | 98.72 | 98.72 | PASS |
| DocsReceipt.psm1 | 100.00 | 100.00 | PASS |
| DocsLedgerMutation.psm1 | 98.39 | 98.39 | PASS |
| DocsValidateCommands.psm1 | 100.00 | 100.00 | PASS |
| DocsSurfaceDeltaCommands.psm1 | 97.33 | 97.33 | PASS |
| DocsAnalyzerRegistry.psm1 | 100.00 | 100.00 | PASS |
| DocsAnalyzerExtensionImport.psm1 | 100.00 | 100.00 | PASS |
| .claude/hooks/docs-role-contract.ps1 | 100.00 | 100.00 | PASS |
| .claude/hooks/validate-docs-role-output.ps1 | 100.00 | 100.00 | PASS |
| DocsLedgerBatch.psm1 (new) | n/a | 100.00 | PASS (threshold) |
| DocsLedgerBindRefs.psm1 (new) | n/a | 100.00 | PASS (threshold) |
| DocsReferenceSplit.psm1 (new) | n/a | 100.00 | PASS (threshold) |
| DocsProfileSourceRoot.psm1 (new) | n/a | 97.83 | PASS (threshold) |

## Python (85% line, 75% branch)

| Module | Baseline line / branch | Final line / branch | Result |
|---|---|---|---|
| docs_python_native.call_sites | 100.00 / 100.00 | 100.00 / 100.00 | PASS |
| docs_python_native.cli_argparse | 100.00 / 96.51 | 100.00 / 99.12 | PASS |
| docs_python_native.cli | 99.06 / 97.83 | 99.29 / 98.44 | PASS |

## TypeScript (85% line, 75% branch)

| File | Baseline line / branch | Final line / branch | Result |
|---|---|---|---|
| src/mcp-tool-inputs-docs.ts | 99.59 / 98.03 | 99.60 / 98.09 | PASS |
| src/mcp-docs-tool-definitions.ts | 100 / 92.85 | 100 / 93.33 | PASS |
| src/repo-automation-execute-docs.ts | 100 / 100 | 100 / 100 | PASS |
| src/mcp-handlers/docs-handlers.ts | 100 / 100 | 100 / 100 | PASS |
| src/mcp-tool-inputs-docs-ledger-batch.ts (new) | n/a | 100 / 100 | PASS (threshold) |

## Verdict

PASS: every changed PowerShell file is at or above 85% line, every changed Python and TypeScript production file is at or above 85% line and 75% branch, no file and no repo-wide figure dropped, the new files meet the thresholds, and no new failing test exists.
