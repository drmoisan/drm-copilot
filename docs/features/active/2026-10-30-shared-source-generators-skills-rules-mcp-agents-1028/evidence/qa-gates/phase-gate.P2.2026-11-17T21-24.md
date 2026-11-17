# Phase 2 Gate ([P2-T4])

Timestamp: 2026-11-17T21-24
Command: sh SCRATCH/issue-1028-gatestatic.sh p2gate (stages 1, 2, 3 and 6); sh .claude/skills/test-execution-policy/scripts/run-test-suite.sh pester; env -u VIRTUAL_ENV sh .claude/skills/test-execution-policy/scripts/run-test-suite.sh pytest tests; sh .claude/skills/test-execution-policy/scripts/run-test-suite.sh jest-extension --coverage; scoped re-checks after the coverage-remediation tests: sh SCRATCH/issue-1028-tsfiles.sh write and sh SCRATCH/issue-1028-pyfiles.sh write
EXIT_CODE: 0
Output Summary: Stages 1 to 6 pass with zero failures in all three parallel gates. The first Jest coverage run showed three TypeScript converter files and three Python converter modules below their Phase 0 per-file figures. The losses were ratio effects of deleting covered standing-guidance branches. Tests were added for the existing uncovered paths, the changed test files were re-checked from stage 1 to a clean pass, and pytest and Jest were re-run. The final unit stage reports pytest 17122 passed and 0 failed, and Jest 5895 of 5895 passed. Every converter file is at or above its Phase 0 figure.

## Stage 1 — Format
- PowerShell (958 files): exit 0, 0 would change. Black `--check scripts tests`: exit 0, "895 files would be left unchanged." Prettier `--check` (extension): exit 0.
- After the remediation tests: Prettier rewrote `engine-pipeline.test.ts` and `pipeline.test.ts`, and the re-check passed. Black rewrote `test_end_to_end.py` twice, and the restarted check printed "36 files would be left unchanged."

## Stage 2 — Lint
- PSScriptAnalyzer (958 files): exit 0, 0 findings, 0 errors (1 same-file retry after the host-level transient `NullReferenceException`). Ruff `check scripts tests`: exit 0. ESLint (`npm run lint`): exit 0, 0 problems.
- After the remediation tests: ESLint exit 0 over the converter test files; Ruff exit 0 over the converter scope. Ruff's TC002 finding on a runtime `pytest` import was fixed by moving the import under `TYPE_CHECKING`.

## Stage 3 — Type check
- Pyright: "0 errors, 0 warnings, 0 informations" (repository run and converter-scope re-run). Two strict-mode findings on an untyped lambda in the new monkeypatch test were fixed with a typed nested function. tsc (both projects): 0 errors.

## Stage 4 — Architecture boundaries
- Not applicable: no `.dependency-cruiser.cjs` or other boundary tool is configured (same search as `phase-gate.P1.2026-11-17T20-01.md`).

## Stage 5 — Unit (parallel gates)
- Pester (8 shards, 887.33 s): exit 0; 28225 tests, 28207 passed, 0 failures, 0 errors, 18 skipped; repo line coverage 96.71%. No PowerShell file changed in Phase 2.
- pytest (`pytest -n auto` over `tests`): exit 0; 17122 passed, 0 failed, 6 skipped. Two runs ended with launcher exit 75 (`TEST_EXECUTION_QUEUE_TIMEOUT`; the machine test-suite lock was held by another worktree's Pester run). Those are queue timeouts, not failures, and were re-run.
- Jest (`jest-extension --coverage`): exit 0; 351 of 351 suites, 5895 of 5895 tests; the new per-file thresholds of `engine-pipeline.ts`, `pipeline.ts` and `validation.ts` hold.

## Converter coverage against the Phase 0 baseline (line / branch)

| File | Phase 0 | Now |
| --- | --- | --- |
| `mapping.ts` | 99.19 / 95.12 | 99.24 / 95.12 |
| `engine-pipeline.ts` | 98.01 / 84.78 | 99.29 / 90.24 |
| `pipeline.ts` | 100.00 / 100.00 | 100.00 / 100.00 |
| `pipeline-render.ts` | 93.80 / 77.78 | 100.00 / 96.00 |
| `validation.ts` | 99.46 / 92.59 | 100.00 / 94.23 |
| `mapping.py` | 96.36 / 92.31 | 96.43 / 92.31 |
| `engine.py` | 97.03 / 91.18 | 98.97 / 96.88 |
| `pipeline.py` | 95.74 / 88.64 | 98.77 / 95.00 |
| `validation.py` | 96.61 / 93.75 | 98.28 / 96.88 |

Python figures come from `pytest -n auto` over `tests/scripts/dev_tools/codex_native_converter` with `--cov=scripts.dev_tools.codex_native_converter --cov-branch` and a JSON report under SCRATCH. They are a lower bound on the full-suite figures, which [P7-T2] reads.

Remediation tests added (existing modules only): `engine-pipeline.test.ts` (emission targets already produced or null, and the empty destination root); `pipeline.test.ts` (MCP-config, approval-rule and launcher wrappers, a subagent or hook without a target, a target without an extension, an empty source root, an unknown section, and topology destinations at different positions); `validation.test.ts` (emissions without a target); `test_validation.py::test_validate_conversion_plan_ignores_emissions_without_target_path`; `test_end_to_end.py` (approval-rule and launcher wrappers, standing guidance rendered without a header, an unknown section, and a review run whose emissions target an already-produced path and a null target).

## Stage 6 — Contract checks
- Codex generator check: exit 0. Quality tiers: "quality-tiers: OK (38 entries, 38 discovered projects)". `-Surface instructions -Check` and `-Surface mcp -Check`: exit 0, "harness-generation: no drift".
