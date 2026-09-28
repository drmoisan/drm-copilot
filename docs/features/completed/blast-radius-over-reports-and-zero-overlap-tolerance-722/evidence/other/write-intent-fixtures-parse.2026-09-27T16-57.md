# Write-Intent Fixtures Parse Check (P8-T2)

Timestamp: 2026-09-27T16-57
Command: poetry run python SCRATCH/wi-fixture-check.py
EXIT_CODE: 0
Output Summary: All eight block B31 fixtures under tests/fixtures/blast_radius/write-intent parse as JSON (FIXTURE-COUNT 8). Each carries the B31 shared config (write_intent_extraction true, path_roots src, config, docs, tests, .claude), the items with plan and spec text, and one or more cases with expected radii. The expected values follow B31: glob-mention, command-span, and placeholder-stem expect {FG, src/app.py}; read-task expects {FG, src/app.py, src/fixme.py}; root-anchoring has a shared-path-roots case {FG, src/app.py} and an empty-path-roots case with all four paths; spec-contracts-only expects {FG, src/app.py} and contracts {computeWidget}; shared-surface-read-citation expects A and D with no shared surface, B and C with config/blast-radius.json, and one hard edge (2, 3) at tolerance 100; flag-absent-matches-current has flag-absent and flag-false cases expecting {FG, src/**/*.py, src/app.py, src/other.py}, an unchanged normalization, and no V1 or V2 finding.

## Fixture schema (shared by all eight files)

- description, tags (["#722"]), config (the B31 shared config).
- items: key, feature_folder, plan_text, spec_text.
- cases: name, config_overrides (top-level keys replaced), remove_keys (top-level keys removed),
  expected_radii (key, paths, modules, shared_surfaces, contracts), and optionally expected_edges and
  expected_tolerated (scheduling at the case config), normalization (paths and expected_paths), and
  expected_findings (V1 and V2 findings of the derived radius against its own plan).
- The shared-surface-read-citation case supplies the tolerance through config_overrides with the
  committed conflict_tolerance member of block B2 (tolerance_percent 100), because the B31 shared
  config carries no conflict_tolerance key.

## Printed output

```text
PARSED write-intent-command-span.json items=1 cases=1 write_intent_extraction=True path_roots=['src', 'config', 'docs', 'tests', '.claude'] case_names=['write-intent']
PARSED write-intent-flag-absent-matches-current.json items=1 cases=2 write_intent_extraction=True path_roots=['src', 'config', 'docs', 'tests', '.claude'] case_names=['flag-absent', 'flag-false']
PARSED write-intent-glob-mention.json items=1 cases=1 write_intent_extraction=True path_roots=['src', 'config', 'docs', 'tests', '.claude'] case_names=['write-intent']
PARSED write-intent-placeholder-stem.json items=1 cases=1 write_intent_extraction=True path_roots=['src', 'config', 'docs', 'tests', '.claude'] case_names=['write-intent']
PARSED write-intent-read-task.json items=1 cases=1 write_intent_extraction=True path_roots=['src', 'config', 'docs', 'tests', '.claude'] case_names=['write-intent']
PARSED write-intent-root-anchoring.json items=1 cases=2 write_intent_extraction=True path_roots=['src', 'config', 'docs', 'tests', '.claude'] case_names=['shared-path-roots', 'empty-path-roots']
PARSED write-intent-shared-surface-read-citation.json items=4 cases=1 write_intent_extraction=True path_roots=['src', 'config', 'docs', 'tests', '.claude'] case_names=['tolerance-100']
PARSED write-intent-spec-contracts-only.json items=1 cases=1 write_intent_extraction=True path_roots=['src', 'config', 'docs', 'tests', '.claude'] case_names=['write-intent']
FIXTURE-COUNT 8
```

## Script text (SCRATCH/wi-fixture-check.py)

```python
import json
from pathlib import Path

base = Path("tests/fixtures/blast_radius/write-intent")
for path in sorted(base.glob("*.json")):
    data = json.loads(path.read_text(encoding="utf-8"))
    config = data["config"]
    cases = data["cases"]
    print(
        f"PARSED {path.name} items={len(data['items'])} cases={len(cases)}"
        f" write_intent_extraction={config.get('write_intent_extraction')}"
        f" path_roots={config.get('path_roots')}"
        f" case_names={[case['name'] for case in cases]}"
    )
print(f"FIXTURE-COUNT {len(list(base.glob('*.json')))}")
```

SCRATCH denotes the executor session scratchpad directory (outside the repository). FG denotes the
feature-folder glob of the item.
