# P14-T10 Coverage comparison for the Phase 12 population and the catalog correction (repeat after P14-T12)

Timestamp: 2026-10-29T12-45
Task: [P14-T10] Verify coverage deltas for the Phase 12 population and the catalog correction, discharging [P13-T4].
Command: poetry run python SCRATCH/issue-980-p14r2-compare.py (the P14-T10 helper reading the repeated P14-T6 report)
EXIT_CODE: 0
Output Summary: 35 production files (19 Python, 16 TypeScript), 0 failures, with a per-file table identical to `p14-coverage-comparison.2026-10-29T12-18.md`. Every file with executable code is at or above 85% lines and 75% branches; every file Phase 12 added is at or above 90% lines (lowest: service_preparation.py 95.00%); every changed executable line of every pre-existing file is covered, including all 4 changed executable lines of catalog.py (168/168 lines, 82/82 branches). Three TypeScript modules are type-only and carry no executable statements. No coverage exclusion was added and no threshold was lowered. This record supersedes the 12-18 record because the Python loop was repeated after P14-T12 regenerated `_build_manifest.json`.

## Inputs

- Inventory: `git diff --name-status --diff-filter=AMR <revision> HEAD -- '*.py' '*.ts'`, production files only (tests, test support and bundled `resources/` copies excluded). `<revision>` is the Phase 12 plan revision commit, resolved by its subject "add Phases 12 and 13 for the host-principal completion path". The helper verified that this commit descends from the merge base of origin/main and HEAD and is an ancestor of HEAD, so the range holds only branch changes: every Phase 12 file, the P13-T4 test-gap fixes (test files only), and the Phase 14 catalog correction. The working tree was clean when the helper ran (porcelain status empty), so the committed inventory is complete.
- Python final: SCRATCH/issue-980-p14r2-coverage.json (the repeated P14-T6 full run, `p14-python-tests.2026-10-29T12-45.md`). Python baseline: FEATURE/evidence/baseline/python-coverage.2026-10-18T03-51.json (P0-T2).
- TypeScript final: SCRATCH/issue-980-p14-jest-ext/coverage-summary.json and coverage-final.json (P14-T7 extension run, the configuration with the per-file threshold map; no TypeScript file changed after it). TypeScript baseline: FEATURE/evidence/baseline/typescript-extension-coverage-summary.2026-10-18T03-58.json (P0-T3).
- Changed lines: `git diff -U0 <revision> HEAD -- <file>`; a Python changed line is executable when it appears in `executed_lines` or `missing_lines`; a TypeScript changed statement starts on a changed line.

## Floors applied

- Every file: lines at least 85%, branches at least 75%.
- New files (added since the Phase 12 revision and absent at P0): lines at least 90%. Their uncovered lines are listed for transparency; no prior coverage exists for them to regress against.
- Pre-existing files (status M, including catalog.py): no uncovered changed executable line (no regression on changed lines).
- "absent at P0": the file did not exist at the P0 baseline (the discovery runtime package and most host modules were added by Phases 1 to 11), so no P0 delta exists; the regression guard for those files is the changed-line check.

## Per-file results

| File | Status since Phase 12 revision | P0 baseline lines / branches | Final lines / branches | Delta lines / branches | Changed executable lines / covered | Uncovered changed lines | Floor class | Disposition |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| `extensions/drm-copilot/src/discovery-authority-provider.ts` | M | absent at P0 | 100% (150/150) / 100% (29/29) | n/a (new since P0) | 8 / 8 | - | changed | PASS |
| `extensions/drm-copilot/src/discovery-authorization.ts` | M | absent at P0 | 97.56% (480/492) / 97.87% (92/94) | n/a (new since P0) | 159 / 159 | - | changed | PASS |
| `extensions/drm-copilot/src/discovery-invocation.ts` | M | absent at P0 | 99.33% (447/450) / 96% (48/50) | n/a (new since P0) | 45 / 45 | - | changed | PASS |
| `extensions/drm-copilot/src/discovery-result.ts` | M | absent at P0 | 100% (386/386) / 97.05% (99/102) | n/a (new since P0) | 2 / 2 | - | changed | PASS |
| `extensions/drm-copilot/src/discovery-runtime.ts` | M | absent at P0 | 97.13% (339/349) / 95.38% (62/65) | n/a (new since P0) | 51 / 51 | - | changed | PASS |
| `extensions/drm-copilot/src/discovery-service-types.ts` | M | type-only | type-only (0 executable statements) | n/a | 0 / 0 | - | n/a | N/A (type-only module) |
| `extensions/drm-copilot/src/mcp-discovery-authority-tool-definitions.ts` | M | absent at P0 | 100% (306/306) / 100% (1/1) | n/a (new since P0) | 3 / 3 | - | changed | PASS |
| `extensions/drm-copilot/src/mcp-discovery-authorization-gate.ts` | A | absent at P0 | 98.5% (197/200) / 94.44% (51/54) | n/a (new since P0) | 200 / 197 | [111, 197, 198] | new | PASS |
| `extensions/drm-copilot/src/mcp-handlers/discovery-handlers.ts` | M | 100% / 100% | 100% (168/168) / 100% (27/27) | +0.00 / +0.00 | 52 / 52 | - | changed | PASS |
| `extensions/drm-copilot/src/mcp-tool-inputs-discovery-authority.ts` | M | absent at P0 | 100% (327/327) / 100% (50/50) | n/a (new since P0) | 5 / 5 | - | changed | PASS |
| `extensions/drm-copilot/src/repo-automation-execute-discovery.ts` | M | 97.13% / 83.87% | 100% (446/446) / 100% (49/49) | +2.87 / +16.13 | 18 / 18 | - | changed | PASS |
| `extensions/drm-copilot/src/repo-automation-service-contract.ts` | M | type-only | type-only (0 executable statements) | n/a | 0 / 0 | - | n/a | N/A (type-only module) |
| `extensions/drm-copilot/src/repo-automation-service-discovery-agent.ts` | M | absent at P0 | 100% (253/253) / 94.59% (35/37) | n/a (new since P0) | 53 / 53 | - | changed | PASS |
| `extensions/drm-copilot/src/repo-automation-service-discovery-identity.ts` | A | absent at P0 | 100% (99/99) / 100% (8/8) | n/a (new since P0) | 99 / 99 | - | new | PASS |
| `extensions/drm-copilot/src/repo-automation-service-discovery-types.ts` | M | type-only | type-only (0 executable statements) | n/a | 0 / 0 | - | n/a | N/A (type-only module) |
| `extensions/drm-copilot/src/repo-automation-service-discovery.ts` | M | absent at P0 | 100% (439/439) / 92.72% (51/55) | n/a (new since P0) | 28 / 28 | - | changed | PASS |
| `packages/discovery-runtime/src/drm_copilot_discovery/agent_output.py` | M | absent at P0 | 99.29% (140/141) / 98.53% (67/68) | n/a (new since P0) | 5 / 5 | - | changed | PASS |
| `packages/discovery-runtime/src/drm_copilot_discovery/catalog.py` | M | absent at P0 | 100.00% (168/168) / 100.00% (82/82) | n/a (new since P0) | 4 / 4 | - | changed | PASS |
| `packages/discovery-runtime/src/drm_copilot_discovery/gateway.py` | M | absent at P0 | 99.26% (135/136) / 100.00% (36/36) | n/a (new since P0) | 30 / 30 | - | changed | PASS |
| `packages/discovery-runtime/src/drm_copilot_discovery/gateway_host.py` | A | absent at P0 | 97.76% (131/134) / 92.86% (13/14) | n/a (new since P0) | 134 / 131 | [179, 180, 201] | new | PASS |
| `packages/discovery-runtime/src/drm_copilot_discovery/gateway_host_baseline.py` | A | absent at P0 | 96.30% (78/81) / 90.00% (27/30) | n/a (new since P0) | 81 / 78 | [98, 105, 189] | new | PASS |
| `packages/discovery-runtime/src/drm_copilot_discovery/gateway_host_store.py` | A | absent at P0 | 96.00% (24/25) / 83.33% (5/6) | n/a (new since P0) | 25 / 24 | [52] | new | PASS |
| `packages/discovery-runtime/src/drm_copilot_discovery/gateway_local.py` | M | absent at P0 | 99.32% (146/147) / 97.50% (39/40) | n/a (new since P0) | 23 / 23 | - | changed | PASS |
| `packages/discovery-runtime/src/drm_copilot_discovery/operation_grants.py` | A | absent at P0 | 96.15% (25/26) / 91.67% (11/12) | n/a (new since P0) | 26 / 25 | [75] | new | PASS |
| `packages/discovery-runtime/src/drm_copilot_discovery/operations.py` | M | absent at P0 | 100.00% (153/153) / 100.00% (38/38) | n/a (new since P0) | 4 / 4 | - | changed | PASS |
| `packages/discovery-runtime/src/drm_copilot_discovery/profile_v2.py` | M | absent at P0 | 100.00% (153/153) / 100.00% (36/36) | n/a (new since P0) | 3 / 3 | - | changed | PASS |
| `packages/discovery-runtime/src/drm_copilot_discovery/protected_records.py` | A | absent at P0 | 98.97% (96/97) / 97.83% (45/46) | n/a (new since P0) | 97 / 96 | [107] | new | PASS |
| `packages/discovery-runtime/src/drm_copilot_discovery/service.py` | M | absent at P0 | 99.18% (121/122) / 96.67% (29/30) | n/a (new since P0) | 20 / 20 | - | changed | PASS |
| `packages/discovery-runtime/src/drm_copilot_discovery/service_finalization.py` | A | absent at P0 | 95.45% (42/44) / 87.50% (14/16) | n/a (new since P0) | 44 / 42 | [83, 85] | new | PASS |
| `packages/discovery-runtime/src/drm_copilot_discovery/service_inspection.py` | M | absent at P0 | 99.17% (120/121) / 97.06% (33/34) | n/a (new since P0) | 6 / 6 | - | changed | PASS |
| `packages/discovery-runtime/src/drm_copilot_discovery/service_preparation.py` | A | absent at P0 | 95.00% (57/60) / 95.00% (19/20) | n/a (new since P0) | 60 / 57 | [66, 67, 133] | new | PASS |
| `packages/discovery-runtime/src/drm_copilot_discovery/service_request_rules.py` | M | absent at P0 | 97.33% (73/75) / 96.55% (56/58) | n/a (new since P0) | 1 / 1 | - | changed | PASS |
| `scripts/dev_tools/agentic_sync.py` | M | 87.22% / 62.50% | 98.02% (99/101) / 94.12% (32/34) | +10.80 / +31.62 | 9 / 9 | - | changed | PASS |
| `scripts/dev_tools/agentic_sync_artifacts.py` | A | absent at P0 | 100.00% (58/58) / 100.00% (2/2) | n/a (new since P0) | 58 / 58 | - | new | PASS |
| `scripts/dev_tools/agentic_sync_filesystem.py` | A | absent at P0 | 100.00% (33/33) / 100.00% (6/6) | n/a (new since P0) | 33 / 33 | - | new | PASS |

## Configuration check

`git diff <merge base> HEAD` over `pyproject.toml`, `extensions/drm-copilot/jest.config.cjs` and `extensions/drm-copilot/jest.discovery-coverage.json`: the `[tool.coverage.run]` `omit` list is unchanged and `source` gains `packages/discovery-runtime/src`; five discovery entries move from `jest.config.cjs` (85/75) into `jest.discovery-coverage.json`, which the config spreads into `coverageThreshold` at 90/75; one new 90/75 entry is added. No exclusion is added and no threshold is lowered. Phase 14 changed no coverage configuration.

[P13-T4] is discharged by this task.

Result: PASS
