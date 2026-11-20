# Final gates, coverage delta and scope — re-run after the [P7-T5] fix ([P7-T2], [P7-T3])

Timestamp: 2026-11-18T02-20
Command: sh SCRATCH/issue-1028-final-tests.sh (the launcher `pester` suite, the launcher `pytest` suite with `tests --cov --cov-branch --cov-report=term-missing --cov-report=json:SCRATCH/issue-1028-pytest-final.json`, and `jest-extension --coverage`); sh SCRATCH/issue-1028-run.sh SCRATCH/issue-1028-leakscan.ps1; sh SCRATCH/issue-1028-scope.sh
EXIT_CODE: 0
Output Summary: The figures equal those of the first final run (`pester-parallel.2026-11-18T01-46.md`, `pytest-parallel.2026-11-18T01-46.md`, `jest-coverage.2026-11-18T01-46.md`, `coverage-delta.2026-11-18T01-46.md` and `scope-check.2026-11-18T01-46.md`). The fix changed JSON data files and added schemas only. Zero failures in every gate, the leak scan passes, and every coverage condition of [P7-T2] holds.

## Gates

| Gate | Result |
| --- | --- |
| Pester (8 shards, 722.73 s) | exit 0; 28310 tests, 28292 passed, 0 failures, 0 errors, 18 skipped; repository line coverage 96.73% (46419 of 47989) |
| pytest (`pytest -n auto`, 196.12 s) | exit 0; 17122 passed, 0 failed, 6 skipped; line 98.00% (35359 of 36079), branch 95.46% (13091 of 13714) |
| Jest (`jest-extension --coverage`) | exit 0; 351 of 351 suites, 5895 of 5895 tests; line 97.29% (65685 of 67512), branch 94.31% (10158 of 10771) |
| `Invoke-PoshQCLeakScan` | "Leak scan: 882 files, 79 findings, 77 exempt, 2 allowlisted, 0 failures." |

## Coverage (unchanged from the first final run)

- New PowerShell files (line): every module is at 100.00%: `HarnessGeneration.psm1` (140/140), `HarnessMcpConfig.psm1` (100/100), `HarnessInstructions.psm1` (64/64), `HarnessSkillMirror.psm1` (67/67), `HarnessRuleGeneration.psm1` (93/93) and `HarnessAgentGeneration.psm1` (115/115). `Invoke-HarnessGeneration.ps1` is at 86.67% (13/15); its two uncovered commands are the process `exit` wiring in the dot-source guard. Across the seven files, 592 of 594 commands are covered (99.66%).
- Converter files (line / branch):
  - TypeScript: `mapping.ts` 99.24/95.12, `engine-pipeline.ts` 99.29/90.24, `pipeline.ts` 100/100, `pipeline-render.ts` 100/96.00, `validation.ts` 100/94.23.
  - Python: `mapping.py` 96.43/92.31, `engine.py` 98.97/96.88, `pipeline.py` 98.77/95.00, `validation.py` 98.28/96.88.
  - All are at or above 85/75 and at or above their Phase 0 figures.
- Repository totals: every total is at or above its Phase 0 figure (Pester 96.69%, pytest 97.98/95.39, Jest 97.25/94.20).

## Scope (against `BASE`)

- Name-status: 225 added and 61 modified. The 14 additional added paths since the first record are the four schemas under `config/harness-generation/` and evidence files. Porcelain: empty.
- No added `.py` or `.ts` file, and the same 15 added PowerShell files. The converter production changes are modifications only.
- No changes to the following: `Not edited` paths, `.github/workflows/`, the ledger, `parallel_orchestrator_surface_expectations.py`, or D-14 skill copies.
- Of child 1's files only the matrix upkeep changed, and of child 2's files only one hunk of its `spec.md`. `jest.config.cjs` numstat is `14 0`.
- File size: every file under the file-size policy is within 800 lines (largest `jest.config.cjs`, 624). `config/harness-parity-matrix.json` (11896 lines) is the policy-uncovered data file recorded in `evidence/other/ac-file-size-interpretation.2026-11-18T01-58.md`. The four new schemas are 25 to 64 lines.
