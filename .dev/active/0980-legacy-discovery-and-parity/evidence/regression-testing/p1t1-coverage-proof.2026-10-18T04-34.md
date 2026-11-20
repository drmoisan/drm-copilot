# P1-T1 coverage and scope proof

Timestamp: 2026-10-18T04-34
Command: poetry run python SCRATCH/issue-980-p1t1-task-audit.py
EXIT_CODE: 0
Output Summary: 26 staged task paths; 13 measured production files; all coverage deltas nonnegative; maximum 452 physical lines; 0 findings.

| File | Baseline line / branch % | Current line / branch % | Changed executable lines |
| --- | --- | --- | --- |
| `packages/discovery-runtime/src/drm_copilot_discovery/__init__.py` | 100.000000 / 100.000000 | 100.000000 / 100.000000 | 3/3 |
| `packages/discovery-runtime/src/drm_copilot_discovery/domain_profile.py` | 99.470899 / 98.717949 | 99.473684 / 98.717949 | 2/2 |
| `packages/discovery-runtime/src/drm_copilot_discovery/domain_profile_models.py` | 100.000000 / 100.000000 | 100.000000 / 100.000000 | 0/0 |
| `packages/discovery-runtime/src/drm_copilot_discovery/init_models.py` | 100.000000 / 100.000000 | 100.000000 / 100.000000 | 6/6 |
| `packages/discovery-runtime/src/drm_copilot_discovery/io.py` | 100.000000 / 100.000000 | 100.000000 / 100.000000 | 0/0 |
| `packages/discovery-runtime/src/drm_copilot_discovery/rendering.py` | 100.000000 / 100.000000 | 100.000000 / 100.000000 | 6/6 |
| `scripts/dev_tools/discovery/__init__.py` | 100.000000 / 100.000000 | 100.000000 / 100.000000 | 1/1 |
| `scripts/dev_tools/discovery/domain_profile.py` | 99.470899 / 98.717949 | 100.000000 / 100.000000 | 2/2 |
| `scripts/dev_tools/discovery/domain_profile_models.py` | 100.000000 / 100.000000 | 100.000000 / 100.000000 | 2/2 |
| `scripts/dev_tools/discovery/init_models.py` | 100.000000 / 100.000000 | 100.000000 / 100.000000 | 3/3 |
| `scripts/dev_tools/discovery/io.py` | 100.000000 / 100.000000 | 100.000000 / 100.000000 | 2/2 |
| `scripts/dev_tools/discovery/rendering.py` | 100.000000 / 100.000000 | 100.000000 / 100.000000 | 2/2 |
| `scripts/dev_tools/quality_tiers_contract.py` | 100.000000 / 100.000000 | 100.000000 / 100.000000 | 2/2 |

Branch percentages for files with no measured branches are vacuously 100%; numerical denominators are preserved in the metrics JSON. Relocated canonical files compare with their original `scripts/dev_tools/discovery` source. Changed executable lines are insertion/replacement lines from the original source comparison intersected with measured executable statements; this includes import/export declarations and type-boundary edits, not a claim that relocated code is newly authored. Every changed executable statement and branch is covered. No new semantic function or class was introduced in the runtime: existing models, parsers, filesystem boundary, and rendering were relocated. The existing quality-tier discovery condition now recognizes `pyproject.toml`. The only checkout-relative helper remains in the old initializer adapter.

Protocol method docstrings turn the old one-line ellipsis declarations into separately excluded stub lines under the unchanged coverage configuration. This changes the initializer protocol denominator from 12 measured branch arcs to zero; executable filesystem methods remain fully covered. No measurement configuration or exclusion was weakened. Generated copies: 0.

All 25 pre-existing quality-tier rows, including rationale, are unchanged. The only added project is `packages/discovery-runtime` at T2. Lockfile versions for existing packages are unchanged; the sole new package is `drm-copilot-discovery` 2.0.0. Required schema validator dependencies move into runtime dependency closure. Frozen v1 schema/example/fixture paths are unchanged.

This is focused task evidence, not the final repository-wide QA gate. The final plan phase retains full-suite and overall-coverage comparison obligations.

Raw coverage: `docs/features/active/2026-10-17-legacy-discovery-and-parity-980/evidence/regression-testing/p1t1-coverage.2026-10-18T04-34.json`

Metrics and exact path inventory: `docs/features/active/2026-10-17-legacy-discovery-and-parity-980/evidence/regression-testing/p1t1-coverage-metrics.2026-10-18T04-34.json`
