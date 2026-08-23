Timestamp: 2026-08-22T23-35
Command: Read-only SHA-256, byte-size, topology receipt total/unique count, and model-routing receipt total/unique count snapshot of `artifacts/orchestration/orchestrator-state.json` immediately before the performance command.
EXIT_CODE: 0
Command: `poetry run python -c "from pathlib import Path; from timeit import repeat; from scripts.dev_tools.validate_orchestrator_state import validate_orchestrator_state_text as v; s=Path('artifacts/orchestration/orchestrator-state.json').read_text(encoding='utf-8'); [v(s) for _ in range(100)]; a=sorted(x*1000 for x in repeat(lambda:v(s),number=1,repeat=100)); print({'samples':len(a),'p50_ms':a[49],'p95_ms':a[94]})"`
EXIT_CODE: 0
Output Summary:
- Checkpoint SHA-256: `3CAFE78895E04C42176717E442D8A4C246EA98D3D8A19E6968963FF1ADD7176F`.
- Checkpoint byte size: `115045`.
- Topology receipts: `47` total and `3` unique.
- Model-routing receipts: `47` total and `5` unique.
- Warm-up validations: exactly `100`.
- Timed samples: exactly `100`.
- Approved historical baseline p95: `0.507500022649765 ms`.
- Current post-rebase p50: `0.6665000692009926 ms`.
- Current post-rebase p95: `0.8160000434145331 ms`.
- Post/baseline p95 ratio: `1.607881787185002`.
- Acceptance threshold ratio: `1.10` (maximum p95 `0.5582500249147415 ms`).
- Benchmark verdict: EXPECTED FAIL-BEFORE; ratio exceeds `1.10`.
- Remediation execution cannot enter Phase 1 because the required monotonic execution-routing receipt added the third valid topology key while `[P1-T1]` requires topology unique count exactly `2`.
- Required plan revision: change `[P1-T1]` to compare topology/model unique counts against the P0-T3 snapshot or explicitly permit monotonic valid new topology keys while retaining total-count floors and checkpoint-truncation detection.
- No production or test file was edited, staged, or committed.
