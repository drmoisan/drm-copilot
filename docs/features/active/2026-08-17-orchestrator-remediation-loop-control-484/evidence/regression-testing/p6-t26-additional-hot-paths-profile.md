# P6-T26 Additional Hot Paths Profile

Timestamp: 2026-08-23T03:41:36-04:00

Command: `poetry run python -c "import cProfile,hashlib,json,pstats; from collections import Counter; from pathlib import Path; from scripts.dev_tools.validate_orchestrator_state import validate_orchestrator_state_text as v; b=Path('artifacts/orchestration/orchestrator-state.json').read_bytes(); s=b.decode('utf-8'); d=json.loads(s); a=d.get('complexity_assessments',[]); k=[tuple(x['signals_present']) for x in a if isinstance(x,dict) and isinstance(x.get('signals_present'),list) and all(isinstance(y,str) for y in x['signals_present'])]; t=d['codex_topology_receipts']; m=d['codex_model_routing_receipts']; tk=lambda r:(tuple(r['languages']),r['production_file_count'],r['test_file_count'],r['execution_context'],r['cross_cutting'],r['root_persona']); mk=lambda r:(str(r['logical_agent']),str(r['complexity_band']),str(r['execution_context']),str(r['orchestration_complexity_ceiling'])); p=cProfile.Profile(); p.enable(); [v(s) for _ in range(1000)]; p.disable(); print({'validation_errors':v(s),'checkpoint_sha256':hashlib.sha256(b).hexdigest().upper(),'checkpoint_bytes':len(b),'complexity_total':len(a),'complexity_unique_valid_signal_tuples':len(set(k)),'topology_total':len(t),'topology_unique':len(Counter(tk(r) for r in t)),'model_total':len(m),'model_unique':len(Counter(mk(r) for r in m))}); pstats.Stats(p).strip_dirs().sort_stats('cumulative').print_stats('_validate_complexity_assessments|compute_complexity_floor|validate_route_membership|load_routing_matrix')"`

EXIT_CODE: 0

Output Summary: The checkpoint validated with an empty error list and remained byte-identical after profiling. Across 1,000 non-strict validations, `_validate_complexity_assessments` ran 1,000 times and `compute_complexity_floor` ran 2,000 times, exactly two calls per validation for the two unique valid ordered signal tuples. `validate_route_membership` and its route-membership `load_routing_matrix` path each recorded zero calls. The profile recorded 3,926,001 total function calls in 1.256 seconds; this task applies no timing assertion.

- Checkpoint SHA-256: `7564F7BDF316BA5BC58C350B63E9799A1323D9248998BA14193CD3140F4DA789`
- Checkpoint byte size: `172408`
- Validation errors: `[]`
- Complexity assessments: `69` total, `2` unique valid ordered signal tuples
- Topology receipts: `69` total, `8` unique; Phase 0 floor was `47` total and `3` unique
- Model-routing receipts: `69` total, `5` unique; Phase 0 floor was `47` total and `5` unique
- `_validate_complexity_assessments`: `1000` calls
- `compute_complexity_floor`: `2000` calls
- `validate_route_membership`: `0` calls
- route-membership `load_routing_matrix`: `0` calls
- Post-command checkpoint SHA-256/bytes: unchanged at `7564F7BDF316BA5BC58C350B63E9799A1323D9248998BA14193CD3140F4DA789` / `172408`
