Timestamp: 2026-08-22T23-40
Command: `poetry run python -c "import cProfile,hashlib,json,pstats; from collections import Counter; from pathlib import Path; from scripts.dev_tools.validate_orchestrator_state import validate_orchestrator_state_text as v; b=Path('artifacts/orchestration/orchestrator-state.json').read_bytes(); s=b.decode('utf-8'); d=json.loads(s); t=d['codex_topology_receipts']; m=d['codex_model_routing_receipts']; tk=lambda r:(tuple(r['languages']),r['production_file_count'],r['test_file_count'],r['execution_context'],r['cross_cutting'],r['root_persona']); mk=lambda r:(str(r['logical_agent']),str(r['complexity_band']),str(r['execution_context']),str(r['orchestration_complexity_ceiling'])); p=cProfile.Profile(); p.enable(); [v(s) for _ in range(1000)]; p.disable(); print({'checkpoint_sha256':hashlib.sha256(b).hexdigest().upper(),'checkpoint_bytes':len(b),'topology_total':len(t),'topology_unique':len(Counter(tk(r) for r in t)),'model_total':len(m),'model_unique':len(Counter(mk(r) for r in m))}); pstats.Stats(p).strip_dirs().sort_stats('cumulative').print_stats('resolve_codex')"`
EXIT_CODE: 0
Output Summary:
- The checkpoint validated successfully 1,000 times.
- Checkpoint SHA-256: `E401F8AD9AC00D5BE0F728212DBEC463F5335E2800E82F5C01AA9443B079C0AF`.
- Checkpoint byte size: `121896`.
- Topology receipts: `50` total and `3` unique; Phase 0 floor was `47` total and `3` unique.
- Model-routing receipts: `50` total and `5` unique; Phase 0 floor was `47` total and `5` unique.
- Receipt totals and unique counts are monotonic; the changed digest and larger byte size result from structurally valid routing-receipt appends.
- Profile total: 7,037,026 calls in 2.453 seconds.
- `resolve_codex_topology`: 50,000 calls, 0.333 seconds cumulative.
- `resolve_codex_deployment`: 50,000 calls, 0.230 seconds cumulative.
- The repeated resolver paths account for one resolution per receipt per validation despite only three topology keys and five model-routing keys.
