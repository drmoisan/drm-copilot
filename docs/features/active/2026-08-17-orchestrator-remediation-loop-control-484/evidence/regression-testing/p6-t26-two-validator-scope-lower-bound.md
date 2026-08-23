# P6-T26 two-validator scope lower bound

Timestamp: 2026-08-23T07-12

## Checkpoint identity

Command: `poetry run python -c "import hashlib,json; from pathlib import Path; from collections import Counter; from scripts.dev_tools.validate_orchestrator_state import validate_orchestrator_state_text as v; p=Path('artifacts/orchestration/orchestrator-state.json'); b=p.read_bytes(); s=b.decode('utf-8'); d=json.loads(s); t=d['codex_topology_receipts']; m=d['codex_model_routing_receipts']; tk=lambda r:(tuple(r['languages']),r['production_file_count'],r['test_file_count'],r['execution_context'],r['cross_cutting'],r['root_persona']); mk=lambda r:(str(r['logical_agent']),str(r['complexity_band']),str(r['execution_context']),str(r['orchestration_complexity_ceiling'])); print({'validation_errors':v(s),'checkpoint_sha256':hashlib.sha256(b).hexdigest().upper(),'checkpoint_bytes':len(b),'topology_total':len(t),'topology_unique':len(Counter(tk(r) for r in t)),'model_total':len(m),'model_unique':len(Counter(mk(r) for r in m)),'review_status':d.get('review-status')})"`

EXIT_CODE: 0

Output Summary: The checkpoint validates with `[]` at SHA-256
`4CBCA8C23D4A42317DF9B6ACA6B56A1A90541E0A99BD9D006552200D6B5786D8`,
164,349 bytes, 66 topology receipts with 7 unique input keys, and 66 model
routing receipts with 5 unique input keys. `review-status` is
`REMEDIATION_REQUIRED`. The checkpoint was not changed by remediation.

## Exact benchmark failures

Command: `poetry run python -c "from pathlib import Path; from timeit import repeat; from scripts.dev_tools.validate_orchestrator_state import validate_orchestrator_state_text as v; s=Path('artifacts/orchestration/orchestrator-state.json').read_text(encoding='utf-8'); [v(s) for _ in range(100)]; a=sorted(x*1000 for x in repeat(lambda:v(s),number=1,repeat=100)); print({'samples':len(a),'p50_ms':a[49],'p95_ms':a[94]})"`

EXIT_CODE: 0 for each measured candidate. The unchanged comparison baseline is
0.507500022649765 ms, so the maximum accepted p95 is
0.5582500249147415 ms.

| Candidate | p50 ms | p95 ms | Post/baseline ratio | Result |
|---|---:|---:|---:|---|
| Faster accepted two-validator candidate | 0.5461000837385654 | 0.6163000361993909 | 1.214384253583986 | FAIL |
| Rejected second bounded candidate | 0.6042999448254704 | 0.6297999061644077 | 1.2409849813919005 | FAIL |

The rejected second candidate was removed. The faster accepted candidate was
restored before boundary verification.

## Zero-validator lower bound

Command: `poetry run python -c "from pathlib import Path; from timeit import repeat; import scripts.dev_tools.validate_orchestrator_state as m; m.validate_codex_model_routing_receipts=lambda _value:[]; m.codex_topology.validate_codex_topology_receipts=lambda _value:[]; s=Path('artifacts/orchestration/orchestrator-state.json').read_text(encoding='utf-8'); [(lambda a,i:print({'round':i,'samples':len(a),'p50_ms':a[49],'p95_ms':a[94]}))(sorted(x*1000 for x in repeat(lambda:m.validate_orchestrator_state_text(s),number=1,repeat=100)),i) for i in range(1,6) for _ in ([m.validate_orchestrator_state_text(s) for _ in range(100)],)]"`

EXIT_CODE: 0

This read-only diagnostic replaced only the two in-scope receipt validators
with zero-cost functions in process. It did not edit or write any repository
file.

| Round | p50 ms | p95 ms | Gate result |
|---:|---:|---:|---|
| 1 | 0.5117000546306372 | 0.5628999788314104 | FAIL |
| 2 | 0.49949996173381805 | 0.5464999703690410 | PASS |
| 3 | 0.4914000164717436 | 0.5341999931260943 | PASS |
| 4 | 0.49919995944947004 | 0.5469000898301601 | PASS |
| 5 | 0.4930000286549330 | 0.5874999333173037 | FAIL |

Median zero-validator p95 is 0.5469000898301601 ms, ratio
1.0776355968905755. This leaves only 0.011349935084581375 ms of median p95
headroom, and two of five rounds fail even when both in-scope validators cost
zero.

## Current scoped cost and remaining hot paths

Command: `poetry run python -c "import json,timeit; from pathlib import Path; from scripts.dev_tools._orchestrator_state_codex_topology import validate_codex_topology_receipts as t; from scripts.dev_tools._orchestrator_state_codex_model_routing import validate_codex_model_routing_receipts as m; d=json.loads(Path('artifacts/orchestration/orchestrator-state.json').read_text(encoding='utf-8')); print({'topology_us':timeit.timeit(lambda:t(d['codex_topology_receipts']),number=20000)*50,'model_us':timeit.timeit(lambda:m(d['codex_model_routing_receipts']),number=20000)*50})"`

EXIT_CODE: 0

Output Summary: The restored candidate costs 45.74465000187047 microseconds
for topology and 32.17125500086695 microseconds for model routing, or
77.91590500273742 microseconds combined. The seven unique topology resolver
calls plus five unique model resolver calls independently measured about 10.75
microseconds before any required per-receipt validation.

Command: `poetry run python -c "import cProfile,pstats; from pathlib import Path; from scripts.dev_tools.validate_orchestrator_state import validate_orchestrator_state_text as v; s=Path('artifacts/orchestration/orchestrator-state.json').read_text(encoding='utf-8'); p=cProfile.Profile(); p.enable(); [v(s) for _ in range(1000)]; p.disable(); pstats.Stats(p).strip_dirs().sort_stats('cumulative').print_stats(18)"`

EXIT_CODE: 0

Output Summary: 1,000 profiled validations took 1.529 seconds. The largest
remaining out-of-scope costs were:

| Hot path | Calls | Cumulative seconds |
|---|---:|---:|
| `_validate_complexity_assessments` | 1,000 | 0.494 |
| `_validate_one_assessment` | 66,000 | 0.437 |
| `validate_route_membership` | 1,000 | 0.135 |
| `load_routing_matrix` | 1,000 | 0.132 |

The non-strict benchmark currently invokes `validate_route_membership` and
loads the routing matrix even though `strict_route_membership` is false and the
result is discarded. The complexity validator recomputes the same signal-floor
inputs across 66 assessment entries per validation.

## Verified no-mutation boundary

- Exact 17-file Black command: exit 0, all 17 files unchanged.
- Exact 17-file Ruff command: exit 0, zero diagnostics.
- Full `poetry run pyright`: exit 0, 0 errors and 0 warnings.
- Focused validator command: 28 passed, 0 failed in 0.12 seconds.
- The restored candidate's last complete P3-T4 run recorded 4,469 passed, 5
  skipped, and 0 failed; repository line coverage was 91.778389% and branch
  coverage was 83.730887%. Topology coverage was 100.000000% line and
  96.250000% branch; model-routing coverage was 95.833333% line and 87.500000%
  branch. The final policy analyzer verdict was `PASS`, with 39/39 model and
  28/28 topology changed executable lines covered.
- The faster accepted candidate is restored; all P3-T1 through P3-T6 tasks are
  unchecked because the benchmark failure requires a restart after correction.
- `git diff --check` exited 0. The only output was an existing CRLF/LF warning
  for the generated `pack-manifests/core.json` working-copy path.
- Validator/test line counts are 223, 200, 270, and 228 respectively, all below
  the 500-line limit.

Plan-of-record SHA-256 is
`0534CBAF890FE9DB020EF6FA152743C1CE6DCA829C38B1FA8E246EBF192888E5`.
The plan contains 35 tasks: 29 checked and 6 unchecked. The first incomplete
task is `[P3-T1]`. `git diff --cached --name-only` returned no paths; this
executor did not stage, commit, or push any file.

## Terminal disposition and required plan correction

`PLAN_CORRECTION_REQUIRED`

The <=1.10 gate does not have a reliable attainable margin inside the current
two-validator production scope. Do not weaken the threshold, benchmark input,
warm-up/sample counts, assertions, diagnostics, or suppression policy.

The corrected plan must add these bounded outcomes before another complete
Phase 3 restart:

1. Add `scripts/dev_tools/validate_orchestrator_state.py` and
   `tests/scripts/dev_tools/test_validate_orchestrator_state_completion.py` to
   scope. Evaluate `validate_route_membership(state_map)` only inside
   `if strict_route_membership:`. Add a monkeypatch-backed test proving the
   non-strict default does not invoke route membership and retain proof that the
   strict completion path invokes it and preserves the exact diagnostics.
2. Add `scripts/dev_tools/_orchestrator_state_complexity.py` and
   `tests/scripts/dev_tools/test_validate_orchestrator_state_complexity.py` to
   scope. Add a local per-invocation cache for successful
   `compute_complexity_floor` results keyed by the exact tuple of validated
   `signals_present` strings. Preserve every assessment's index-specific band,
   floor, signal-shape, ordering, and rationale diagnostics, and never cache an
   invalid signal shape. Add duplicate-input resolver-count and invalid-input
   diagnostic tests without timing assertions.
3. Split the added files into policy-compliant Python batches, extend all
   focused/full coverage and line-count reconciliation to the four added files,
   and restart the complete ordered P3-T1 through P3-T6 sequence after the plan
   is revised and revalidated.
