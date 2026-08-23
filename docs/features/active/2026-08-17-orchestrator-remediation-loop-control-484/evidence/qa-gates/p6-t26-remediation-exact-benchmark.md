# P6-T26 Remediation Exact Benchmark

Timestamp: 2026-08-23T04:09:25-04:00

Command: `poetry run python -c "import hashlib,json; from collections import Counter; from pathlib import Path; from scripts.dev_tools.validate_orchestrator_state import validate_orchestrator_state_text as v; b=Path('artifacts/orchestration/orchestrator-state.json').read_bytes(); s=b.decode('utf-8'); d=json.loads(s); t=d['codex_topology_receipts']; m=d['codex_model_routing_receipts']; tk=lambda r:(tuple(r['languages']),r['production_file_count'],r['test_file_count'],r['execution_context'],r['cross_cutting'],r['root_persona']); mk=lambda r:(str(r['logical_agent']),str(r['complexity_band']),str(r['execution_context']),str(r['orchestration_complexity_ceiling'])); print({'validation_errors':v(s),'checkpoint_sha256':hashlib.sha256(b).hexdigest().upper(),'checkpoint_bytes':len(b),'topology_total':len(t),'topology_unique':len(Counter(tk(r) for r in t)),'model_total':len(m),'model_unique':len(Counter(mk(r) for r in m))})"`

EXIT_CODE: 0

Output Summary: The immediate pre-benchmark checkpoint snapshot was structurally valid with zero validation errors. SHA-256 was `7564F7BDF316BA5BC58C350B63E9799A1323D9248998BA14193CD3140F4DA789`, byte size was `172408`, topology receipts were `69` total / `8` unique, and model-routing receipts were `69` total / `5` unique. Counts are monotonic above the P0-T3 unique-count floors of `3` topology keys and `5` model-routing keys.

Command: `poetry run python -c "from pathlib import Path; from timeit import repeat; from scripts.dev_tools.validate_orchestrator_state import validate_orchestrator_state_text as v; s=Path('artifacts/orchestration/orchestrator-state.json').read_text(encoding='utf-8'); [v(s) for _ in range(100)]; a=sorted(x*1000 for x in repeat(lambda:v(s),number=1,repeat=100)); print({'samples':len(a),'p50_ms':a[49],'p95_ms':a[94]})"`

EXIT_CODE: 0

Output Summary: The unchanged exact P6-T26 benchmark completed exactly `100` warm-ups followed by `100` timed samples. Baseline p95 was `0.507500022649765 ms`; post-remediation p50 was `0.4471999127417803 ms`; post-remediation p95 was `0.47690002247691154 ms`; ratio was `0.9397044358479347`. The ratio is below the required `1.10` ceiling.
