# Seven-Stage Toolchain Mapping (issue #1006)

Timestamp: 2026-10-31T08-37
Task: P8-T12
Command: none (mapping record over the artifacts named below)
EXIT_CODE: 0
Output Summary: every stage of the seven-stage loop is satisfied by a recorded artifact.

| Stage | Python | PowerShell | TypeScript |
|---|---|---|---|
| 1 Formatting | qa-gates/python-black | qa-gates/ps-format | qa-gates/ts-prettier |
| 2 Linting | qa-gates/python-ruff | qa-gates/pssa | qa-gates/ts-lint |
| 3 Type checking | qa-gates/python-pyright | not applicable to PowerShell | qa-gates/ts-typecheck |
| 4 Architecture boundaries | no dependency-cruiser or NetArchTest scope covers these files; module-export rows of `BlastRadiusGenericContract.Tests.ps1` (P3-T2) and the push-down dependency-closure test (P7-T2, qa-gates/push-down-contracts) | same | same |
| 5 Unit tests | qa-gates/python-tests | qa-gates/pester-full | qa-gates/ts-jest |
| 6 Contract / schema | corpus parity and constant parity (P5-T6), key-partition coverage (P5-T9), qa-gates/push-down-contracts (P7-T2), qa-gates/codex-generator-check (P7-T3) | Pester parity row and KeyPartition row (P3, P5-T9) | parity corpus test (P5-T6) |
| 7 Integration | in-memory push tests `test_ac04_push_demotes_quality_tiers_with_tolerance_5000` (P5-T7) | not applicable (no PowerShell push-down) | "demotes quality-tiers.yml with tolerance 5000 on push (issue #1006 AC-04)" (P5-T8) |

Artifacts are under FEATURE/evidence/qa-gates/; each consumer selects the lexicographically greatest `<name>.*.md`.
