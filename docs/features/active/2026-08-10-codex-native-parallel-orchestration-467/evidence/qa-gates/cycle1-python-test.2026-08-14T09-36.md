# Cycle 1 Python Test and Coverage Gate

Timestamp: `2026-08-15T00:20:41.9777210-04:00`

Plan task: `[P5-T8]`

Command:

```powershell
poetry run pytest -o addopts= -q --cov --cov-branch --cov-report=term-missing --cov-report=json:docs/features/active/2026-08-10-codex-native-parallel-orchestration-467/evidence/qa-gates/cycle1-python-coverage.2026-08-14T09-36.json
```

- EXIT_CODE: `0`
- Output Summary: `3,971 passed`, `5 skipped`, `0 failed` in `11.88s`.
- Coverage JSON SHA-256: `B8837FD7C02CDC1F3C3D0D6AB4A32197DD63C48FF54DC78D3191ED40D5F91709`.

## Repository thresholds

| Counter | Result | Threshold | Disposition |
|---|---:|---:|:---:|
| Lines | 14,350/15,525 = 92.431562% | >=85% | PASS |
| Branches | 4,894/5,772 = 84.788635% | >=75% | PASS |

## Changed-owner reconciliation

The accepted prior owner values are from `evidence/qa-gates/python-final-test-coverage.2026-08-13T15-38.md`. The current JSON was parsed independently after the full run.

| Owner | Prior lines | Current lines | Prior branches | Current branches | Result |
|---|---:|---:|---:|---:|:---:|
| `scripts/dev_tools/_parallel_orchestrator_state_completion_receipts.py` | 95/102 | 95/102 | 48/56 | 48/56 | PASS |
| `scripts/dev_tools/_parallel_orchestrator_state_mutation_receipts.py` | 136/145 | 136/145 | 59/66 | 59/66 | PASS |
| `scripts/dev_tools/parallel_codex_readiness_filesystem.py` | 163/177 | 163/177 | 43/52 | 43/52 | PASS |
| `scripts/dev_tools/push_down_codex_routing_merge.py` | 100/104 | 100/104 | 32/40 | 32/40 | PASS |
| `scripts/dev_tools/validate_parallel_codex_readiness.py` | 184/202 | 184/202 | 91/110 | 91/110 | PASS |
| `scripts/dev_tools/parallel_kickoff_contract.py` | 109/109 | 109/109 | 38/38 | 38/38 | PASS |
| `scripts/dev_tools/resolve_codex_deployment.py` | 92/92 | 92/92 | 22/22 | 22/22 | PASS |
| `scripts/dev_tools/resolve_codex_topology.py` | 110/110 | 110/110 | 40/40 | 40/40 | PASS |

- Changed owners non-regressing: `8/8`.
- Added owners at or above 90% line coverage: `5/5`.
- Added-owner values: `95/102 = 93.137255%`, `136/145 = 93.793103%`, `163/177 = 92.090395%`, `100/104 = 96.153846%`, and `184/202 = 91.089109%`.
- `scripts/dev_tools/parallel_kickoff_contract.py`: `109/109 = 100%` lines and `38/38 = 100%` branches.

Acceptance result: `PASS`. The full test run exited zero, repository line and branch thresholds passed, all five added owners remained at or above 90% line coverage, all eight changed owners were non-regressing, and the target retained complete line and branch coverage.
