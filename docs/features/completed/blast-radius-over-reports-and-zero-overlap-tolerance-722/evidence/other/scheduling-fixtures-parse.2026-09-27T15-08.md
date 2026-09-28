# Scheduling Fixture Parse Check (P1-T2 through P1-T6)

Timestamp: 2026-09-27T15-08
Command: poetry run python SCRATCH/sched-fixture-check.py tests/fixtures/blast_radius/scheduling/scheduling-452-shared-surface-hard.json tests/fixtures/blast_radius/scheduling/scheduling-452-directory-prefix-weighted.json tests/fixtures/blast_radius/scheduling/scheduling-452-negative-controls.json tests/fixtures/blast_radius/scheduling/scheduling-soft-pair-tolerated.json tests/fixtures/blast_radius/scheduling/scheduling-absent-key-strict.json
EXIT_CODE: 0
Output Summary: All five fixtures parse as JSON. Item and case counts match blocks B5-B9 (2/3, 3/3, 4/3, 4/3, 5/1). Every item embeds its radius. The negative-controls fixture has no expected edge and no expected tolerated overlap in any case. The absent-key fixture's embedded config has no conflict_tolerance key; the other four carry it.

## Printed output

```text
PARSED file=scheduling-452-shared-surface-hard.json items=2 cases=3 tolerances=[0, 100, 1000000] expected_edges_total=3 expected_tolerated_total=0 radii_embedded=True has_conflict_tolerance=True tags=['#722', '#452-case']
PARSED file=scheduling-452-directory-prefix-weighted.json items=3 cases=3 tolerances=[0, 100, 1000000] expected_edges_total=6 expected_tolerated_total=3 radii_embedded=True has_conflict_tolerance=True tags=['#722', '#452-case']
PARSED file=scheduling-452-negative-controls.json items=4 cases=3 tolerances=[0, 100, 1000000] expected_edges_total=0 expected_tolerated_total=0 radii_embedded=True has_conflict_tolerance=True tags=['#722', '#452-case']
PARSED file=scheduling-soft-pair-tolerated.json items=4 cases=3 tolerances=[0, 99, 100] expected_edges_total=3 expected_tolerated_total=3 radii_embedded=True has_conflict_tolerance=True tags=['#722']
PARSED file=scheduling-absent-key-strict.json items=5 cases=1 tolerances=[None] expected_edges_total=2 expected_tolerated_total=0 radii_embedded=True has_conflict_tolerance=False tags=['#722']
```

## Script text (SCRATCH/sched-fixture-check.py)

```python
import json
import sys
from pathlib import Path

for name in sys.argv[1:]:
    data = json.loads(Path(name).read_text(encoding="utf-8"))
    items = data["items"]
    cases = data["cases"]
    config = data["config"]
    edges = sum(len(c["expected_edges"]) for c in cases)
    tolerated = sum(len(c["expected_tolerated"]) for c in cases)
    embedded = all(isinstance(i["radius"], dict) and "paths" in i["radius"] for i in items)
    print(
        f"PARSED file={Path(name).name} items={len(items)} cases={len(cases)} "
        f"tolerances={[c['tolerance_percent'] for c in cases]} expected_edges_total={edges} "
        f"expected_tolerated_total={tolerated} radii_embedded={embedded} "
        f"has_conflict_tolerance={'conflict_tolerance' in config} tags={data['tags']}"
    )
```

SCRATCH denotes the executor session scratchpad directory (outside the repository).
