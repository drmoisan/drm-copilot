# P6-T26 Exact Benchmark Restart 1

Timestamp: 2026-08-23T03:46:22-04:00

Command: `poetry run python -c "import hashlib,json; from collections import Counter; from pathlib import Path; from scripts.dev_tools.validate_orchestrator_state import validate_orchestrator_state_text as v; b=Path('artifacts/orchestration/orchestrator-state.json').read_bytes(); s=b.decode('utf-8'); d=json.loads(s); t=d['codex_topology_receipts']; m=d['codex_model_routing_receipts']; tk=lambda r:(tuple(r['languages']),r['production_file_count'],r['test_file_count'],r['execution_context'],r['cross_cutting'],r['root_persona']); mk=lambda r:(str(r['logical_agent']),str(r['complexity_band']),str(r['execution_context']),str(r['orchestration_complexity_ceiling'])); print({'validation_errors':v(s),'checkpoint_sha256':hashlib.sha256(b).hexdigest().upper(),'checkpoint_bytes':len(b),'topology_total':len(t),'topology_unique':len(Counter(tk(r) for r in t)),'model_total':len(m),'model_unique':len(Counter(mk(r) for r in m))})"`

EXIT_CODE: 0

Command: `poetry run python -c "from pathlib import Path; from timeit import repeat; from scripts.dev_tools.validate_orchestrator_state import validate_orchestrator_state_text as v; s=Path('artifacts/orchestration/orchestrator-state.json').read_text(encoding='utf-8'); [v(s) for _ in range(100)]; a=sorted(x*1000 for x in repeat(lambda:v(s),number=1,repeat=100)); print({'samples':len(a),'p50_ms':a[49],'p95_ms':a[94]})"`

EXIT_CODE: 0

Output Summary: The checkpoint was valid and unchanged at SHA-256 `7564F7BDF316BA5BC58C350B63E9799A1323D9248998BA14193CD3140F4DA789`, 172,408 bytes, with topology receipts 69 total/8 unique and model-routing receipts 69 total/5 unique. The unchanged benchmark recorded exactly 100 samples after 100 warm-ups, p50 `0.5204000044614077 ms`, p95 `0.5934999790042639 ms`, and ratio `1.1694580345149048` against baseline p95 `0.507500022649765 ms`. The ratio exceeded `1.10`, so P3-T5 was not checked off; Phase 3 was cleared and restarted after a bounded successful-cache lookup correction. No benchmark input, threshold, checkpoint, receipt, assertion, suppression, or dependency changed.
