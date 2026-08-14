# Python Canonical Coverage Comparison

Timestamp: `2026-08-13T15-38`

## Repository thresholds

| Counter | Phase 3 result | Threshold | Result |
|---|---:|---:|:---:|
| Lines | 14,350/15,525 = 92.431561996779% | >=85% | PASS |
| Branches | 4,895/5,772 = 84.805959805960% | >=75% | PASS |

## Changed-owner reconciliation

| Owner | Prior audited lines | Phase 3 lines | Prior audited branches | Phase 3 branches | Result |
|---|---:|---:|---:|---:|:---:|
| `scripts/dev_tools/_parallel_orchestrator_state_completion_receipts.py` | 95/102 | 95/102 | 48/56 | 48/56 | PASS |
| `scripts/dev_tools/_parallel_orchestrator_state_mutation_receipts.py` | 136/145 | 136/145 | 59/66 | 59/66 | PASS |
| `scripts/dev_tools/parallel_codex_readiness_filesystem.py` | 163/177 | 163/177 | 43/52 | 43/52 | PASS |
| `scripts/dev_tools/push_down_codex_routing_merge.py` | 100/104 | 100/104 | 32/40 | 32/40 | PASS |
| `scripts/dev_tools/validate_parallel_codex_readiness.py` | 184/202 | 184/202 | 91/110 | 91/110 | PASS |
| `scripts/dev_tools/parallel_kickoff_contract.py` | 107/109 | 109/109 | 36/38 | 38/38 | PASS |
| `scripts/dev_tools/resolve_codex_deployment.py` | 92/92 | 92/92 | 22/22 | 22/22 | PASS |
| `scripts/dev_tools/resolve_codex_topology.py` | 110/110 | 110/110 | 40/40 | 40/40 | PASS |

No listed changed owner regressed. All five added owners remain above the 90% line threshold. The remediated target now matches its canonical feature-start percentage: baseline 91/91 lines and 26/26 branches = 100%; Phase 3 109/109 lines and 38/38 branches = 100%.

## Evidence integrity

- Canonical baseline SHA-256: `8A406402C30108B4A60927993753518E13CE3B1A13D200839A894B1A42881A7A`.
- Prior audited current-coverage JSON SHA-256: `E3099AEA7CEEE5E58D93108B518BECE7FB88E3A8DCF2B521027F835C5AC957DE`.
- Phase 3 coverage JSON SHA-256: `CF79A46C05591E7F3FDAC70437E5FE8A5D7D7B659D0DBE1FE2BD9995EF8CF263`.
- Modified test owner SHA-256: `CEFD27389CFFD531621D7746A3C8C8131E1010542CC2E2E605497B96395CFC6D`.
- Clean consecutive loop: Black `PASS` -> Ruff `PASS` -> Pyright `PASS` -> Pytest/coverage `PASS`.
- Acceptance result: `PASS`.
