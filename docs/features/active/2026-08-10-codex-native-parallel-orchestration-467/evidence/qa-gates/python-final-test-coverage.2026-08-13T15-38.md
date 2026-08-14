# Final Python Test and Coverage Gate

Timestamp: `2026-08-13T15-38`

Plan task: `[P7-T2]`

Command:

```powershell
$env:COVERAGE_FILE = [IO.Path]::GetFullPath('docs/features/active/2026-08-10-codex-native-parallel-orchestration-467/evidence/qa-gates/.coverage-python-final')
poetry run pytest --cov --cov-branch --cov-report=term-missing --cov-report=json:docs/features/active/2026-08-10-codex-native-parallel-orchestration-467/evidence/qa-gates/python-final-coverage.2026-08-13T15-38.json
```

- Exit code: `0`.
- Collected: `3,976`.
- Passed: `3,971`.
- Skipped: `5` documented manifest-accessor cases.
- Failed: `0`.
- Duration: `16.05` seconds.
- Coverage JSON SHA-256: `619752D8B786E007716D5767221EB682DD05CE776688D7BAE3D9FA8AF7DA6141`.
- Canonical coverage-data SHA-256: `F3613B80DAF732E5260B3E5333F7E6F89EE6CEF4D3C76AF06BF6E057BCAA54C9`.

## Repository thresholds

| Counter | Final result | Threshold | Result |
|---|---:|---:|:---:|
| Lines | 14,350/15,525 = 92.431562% | >=85% | PASS |
| Branches | 4,894/5,772 = 84.788635% | >=75% | PASS |

## Changed-owner reconciliation

| Owner | P3 lines | Final lines | P3 branches | Final branches | Result |
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
- Remediated target line coverage: `109/109 = 100%`.
- Remediated target branch coverage: `38/38 = 100%`.
- Clean consecutive loop: Black `PASS` -> Ruff `PASS` -> Pyright `PASS` -> Pytest/coverage `PASS`.

`P7_T2_TEST_STATUS: PASS`
