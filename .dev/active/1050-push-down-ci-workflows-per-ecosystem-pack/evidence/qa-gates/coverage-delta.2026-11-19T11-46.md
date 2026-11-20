# Coverage Delta (P3-T2)

Timestamp: 2026-11-19T11-46
Command: comparison of the `Phase 0 baseline` artifacts (`baseline-jest.2026-11-19T08-55.md`, `baseline-pytest.2026-11-19T08-55.md`, `baseline-pester.2026-11-19T08-55.md`) with the loop-pass-2 final gates (`final-jest.2026-11-19T11-31.md`, `final-pytest.2026-11-19T11-34.md`, `final-pester.2026-11-19T11-46.md`); per-file figures from SCRATCH/baseline-lcov.info vs SCRATCH/final2-lcov.info (SCRATCH/issue-1050-lcov.sh), SCRATCH/baseline-coverage.json vs SCRATCH/final2-coverage.json (SCRATCH/issue-1050-covdiff.cjs), and the JaCoCo reports (SCRATCH/issue-1050-pester-read.cjs)
EXIT_CODE: 0
Output Summary: Both new TypeScript files are at or above 85% lines and 75% branches; no edited TypeScript file is below its baseline; `scripts/ci/Set-CiRequiredChecks.ps1` is at 98.08% lines (threshold 85%); repo-wide Jest, pytest, and Pester figures are not below baseline at the reported precision (Pester exact 96.7712% vs 96.7698%; Jest lines and branches up). No value is missing. Result: PASS.

## TypeScript (Jest, lcov.info)

| File | Baseline lines | Final lines | Baseline branches | Final branches | Changed-code note | Verdict |
| --- | --- | --- | --- | --- | --- | --- |
| `src/lib/push-down/push-down-ci-workflows.ts` (new) | n/a (new file) | 100.00% (338/338) | n/a | 97.10% (67/69) | whole file is new code | PASS (>= 85 / 75) |
| `src/lib/push-down/push-down-ci-layer.ts` (new) | n/a (new file) | 100.00% (218/218) | n/a | 96.67% (29/30) | whole file is new code | PASS (>= 85 / 75) |
| `src/lib/push-down/push-down-layer.ts` | 100.00% (126/126) | 100.00% (131/131) | 100.00% (1/1) | 100.00% (1/1) | added lines are an optional interface field | PASS |
| `src/lib/push-down/push-down-pipeline.ts` | 99.21% (504/508) | 99.22% (508/512) | 97.65% (83/85) | 97.75% (87/89) | new protected-path branch covered (4 of 4 added branch arms hit) | PASS |
| `src/lib/push-down/push-down-harness.ts` | 100.00% (225/225) | 100.00% (292/292) | 96.00% (48/50) | 96.92% (63/65) | all added lines covered; the 2 uncovered branches are the pre-existing ones | PASS |
| `src/lib/push-down/push-down-service-call.ts` | 100.00% (202/202) | 100.00% (208/208) | 100.00% (20/20) | 100.00% (22/22) | new forward branch covered both ways | PASS |
| `src/mcp-push-down-schema-properties.ts` | 100.00% (91/91) | 100.00% (100/100) | no branches | no branches | new property object covered | PASS |
| `src/mcp-tool-inputs-push-down.ts` | 100.00% (180/180) | 100.00% (193/193) | 100.00% (51/51) | 100.00% (55/55) | new parse branches covered both ways | PASS |
| `src/repo-automation-service-contract.ts` | 0.00% (0/325) | 0.00% (0/327) | 0.00% (0/1) | 0.00% (0/1) | type declarations only (policy allows 0% for type-only files); unchanged ratio | PASS (no drop) |
| `src/repo-automation-service-push-down.ts` | 100.00% (227/227) | 100.00% (233/233) | 100.00% (20/20) | 100.00% (22/22) | new forward branch covered both ways | PASS |

Repo-wide Jest: lines 97.42% (68431/70241) -> 97.44% (69097/70909); branches 94.63% (10597/11198) -> 94.66% (10720/11324). PASS.

## PowerShell (Pester, JaCoCo)

| File | Baseline | Final | Verdict |
| --- | --- | --- | --- |
| `scripts/ci/Set-CiRequiredChecks.ps1` (new) | n/a (new file) | 98.08% (51/52); the uncovered line is the `-DataFilePath` parameter default | PASS (>= 85) |

Repo-wide Pester line coverage: 96.77% (47184/48759, exact 96.7698%) -> 96.77% (47235/48811, exact 96.7712%). PASS. (Pester measures no branch coverage.)

## Python (pytest, coverage.json)

No Python file is added or changed (S16). Repo-wide: lines 98.00% (35359/36079) -> 98.00% (35359/36079); branches 95.46% (13092/13714) -> 95.46% (13091/13714). The single covered-branch difference is in the untouched `scripts/dev_tools/atomic_executor/cli_copilot_runtime.py` (62 -> 61), which loop pass 1 on the same Python code measured at 62; it is run-to-run variance, recorded in `final-pytest.2026-11-19T11-34.md`. PASS at the reported precision.
