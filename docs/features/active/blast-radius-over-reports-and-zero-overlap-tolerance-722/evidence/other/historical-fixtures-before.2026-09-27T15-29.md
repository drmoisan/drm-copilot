# Historical-Run Fixtures, BEFORE Section (P3-T6, P3-T7, P3-T8)

Timestamp: 2026-09-27T15-29
Command: poetry run python SCRATCH/historical-fixture.py before <slug> FEATURE/evidence/other/historical-<slug>-radii.2026-09-27T15-00.json FEATURE/evidence/other/historical-<slug>-before-python.2026-09-27T15-05.json FEATURE/evidence/other/historical-<slug>-before-powershell.2026-09-27T15-05.json tests/fixtures/blast_radius/historical-runs/<slug>.json (once per run; the exact commands are listed below)
EXIT_CODE: 0
Output Summary: Contract C6 ran in before mode for each of the three runs and exited 0. Each run required the Python and PowerShell BEFORE edge member sets to be identical (MATCH) before writing. The pinned BEFORE values equal the P0-T27 artifact (FEATURE/evidence/baseline/historical-before-rederivation.2026-09-27T15-10.md): followups-2026-09-27 46 edges, 8 cohorts, maximum width 2; backlog-2026-09-26 4 edges, 2 cohorts, maximum width 3; epic-655-followups 1 edge, 2 cohorts, maximum width 1. Each fixture carries every B17 field with the BEFORE section only (no after key), the pre-change truth table as an embedded object read at BASE_SHA, and two additional provenance fields (description, plan_home_commit).

## Commands and printed output

### P3-T6: followups-2026-09-27

```text
$ poetry run python SCRATCH/historical-fixture.py before followups-2026-09-27 docs/features/active/blast-radius-over-reports-and-zero-overlap-tolerance-722/evidence/other/historical-followups-2026-09-27-radii.2026-09-27T15-00.json docs/features/active/blast-radius-over-reports-and-zero-overlap-tolerance-722/evidence/other/historical-followups-2026-09-27-before-python.2026-09-27T15-05.json docs/features/active/blast-radius-over-reports-and-zero-overlap-tolerance-722/evidence/other/historical-followups-2026-09-27-before-powershell.2026-09-27T15-05.json tests/fixtures/blast_radius/historical-runs/followups-2026-09-27.json
FIXTURE run=followups-2026-09-27 items=11 base_commit=beae3f021674e64fa6662097fe48a332d8da62b8 runtimes=MATCH edge_count=46 cohort_count=8 max_cohort_width=2
```

### P3-T7: backlog-2026-09-26

```text
$ poetry run python SCRATCH/historical-fixture.py before backlog-2026-09-26 docs/features/active/blast-radius-over-reports-and-zero-overlap-tolerance-722/evidence/other/historical-backlog-2026-09-26-radii.2026-09-27T15-00.json docs/features/active/blast-radius-over-reports-and-zero-overlap-tolerance-722/evidence/other/historical-backlog-2026-09-26-before-python.2026-09-27T15-05.json docs/features/active/blast-radius-over-reports-and-zero-overlap-tolerance-722/evidence/other/historical-backlog-2026-09-26-before-powershell.2026-09-27T15-05.json tests/fixtures/blast_radius/historical-runs/backlog-2026-09-26.json
FIXTURE run=backlog-2026-09-26 items=5 base_commit=beae3f021674e64fa6662097fe48a332d8da62b8 runtimes=MATCH edge_count=4 cohort_count=2 max_cohort_width=3
```

### P3-T8: epic-655-followups

```text
$ poetry run python SCRATCH/historical-fixture.py before epic-655-followups docs/features/active/blast-radius-over-reports-and-zero-overlap-tolerance-722/evidence/other/historical-epic-655-followups-radii.2026-09-27T15-00.json docs/features/active/blast-radius-over-reports-and-zero-overlap-tolerance-722/evidence/other/historical-epic-655-followups-before-python.2026-09-27T15-05.json docs/features/active/blast-radius-over-reports-and-zero-overlap-tolerance-722/evidence/other/historical-epic-655-followups-before-powershell.2026-09-27T15-05.json tests/fixtures/blast_radius/historical-runs/epic-655-followups.json
FIXTURE run=epic-655-followups items=2 base_commit=beae3f021674e64fa6662097fe48a332d8da62b8 runtimes=MATCH edge_count=1 cohort_count=2 max_cohort_width=1
```

## Field check (poetry run python SCRATCH/historical-fixture-check.py)

```text
FIXTURE-CHECK run=followups-2026-09-27 missing=[] extra=['description', 'plan_home_commit'] has_after=False items=11 item_fields_ok=True before_fields_ok=True config_is_object=True config_has_conflict_tolerance=False edge_count=46 edges_len=46 cohort_count=8 max_cohort_width=2
FIXTURE-CHECK run=backlog-2026-09-26 missing=[] extra=['description', 'plan_home_commit'] has_after=False items=5 item_fields_ok=True before_fields_ok=True config_is_object=True config_has_conflict_tolerance=False edge_count=4 edges_len=4 cohort_count=2 max_cohort_width=3
FIXTURE-CHECK run=epic-655-followups missing=[] extra=['description', 'plan_home_commit'] has_after=False items=2 item_fields_ok=True before_fields_ok=True config_is_object=True config_has_conflict_tolerance=False edge_count=1 edges_len=1 cohort_count=2 max_cohort_width=1
```

The followups-2026-09-27 fixture pins the cohort partition
[[710], [713], [716], [707, 714], [708], [712], [706, 709], [711, 715]], identical to the P0-T27
partition in both runtime columns.

## Field decisions

- source_ref is the plan-home ref name recorded by P0-T23; manifest_blob is the manifest blob SHA;
  base_commit is BASE_SHA, the commit whose truth table (before.config) and relation produced the
  BEFORE values; plan_home_commit additionally records the commit the radii were read at.
- items copy issue_num, complexity_band, band_source, and the recorded radius verbatim.
- expected_radius_sizes is a list of per-item objects (issue_num and the counts of paths, modules,
  shared_surfaces, and contracts after BlastRadius construction).
- before.edges carries a, b, and the recorded reason (the first canonical kind).

## Contract C6 script text (SCRATCH/historical-fixture.py)

```python
"""Contract C6: write a historical-run fixture (block B17) from committed P0 evidence.

Arguments: mode (before or after), slug, radii JSON (C1 output), BEFORE Python edges JSON (C2
output), BEFORE PowerShell edges JSON (C3 output), output path.

Before mode:
  - reads the recorded radii, per-item band, and band source verbatim from the radii JSON;
  - reads BASE_SHA from the BEFORE Python JSON's config field and reads the pre-change truth table
    with git show BASE_SHA:config/blast-radius.json (the config the BEFORE values were derived with);
  - requires the Python and PowerShell edge member sets (pair and reason) to be identical, and stops
    with exit 2 otherwise (no value is pinned until both runtimes agree);
  - pins the per-item radius sizes (counts of the four levels after BlastRadius construction) and the
    BEFORE edges, edge count, cohorts, cohort count, and maximum cohort width from the Python JSON.
After mode is implemented by the Phase 12 version of this contract; this version exits 2 for it.
"""

import json
import re
import shutil
import subprocess
import sys
from pathlib import Path

sys.path.insert(0, str(Path.cwd()))

from scripts.dev_tools.compute_blast_radius import BlastRadius  # noqa: E402

mode, slug, radii_path, python_path, powershell_path, output_path = sys.argv[1:7]
if mode != "before":
    print(f"STOP mode={mode} is not implemented in the Phase 3 version of contract C6")
    raise SystemExit(2)

git = shutil.which("git")
if git is None:
    raise SystemExit("git executable not found")

radii = json.loads(Path(radii_path).read_text(encoding="utf-8"))
before_python = json.loads(Path(python_path).read_text(encoding="utf-8"))
before_powershell = json.loads(Path(powershell_path).read_text(encoding="utf-8"))
if radii["slug"] != slug or before_python["slug"] != slug:
    print(f"STOP slug mismatch: {slug} vs {radii['slug']} / {before_python['slug']}")
    raise SystemExit(2)

match = re.search(r"at BASE_SHA ([0-9a-f]{40})$", before_python["config"])
if match is None:
    print(f"STOP no BASE_SHA in config field: {before_python['config']!r}")
    raise SystemExit(2)
base_sha = match.group(1)
config_text = subprocess.run(
    [git, "show", f"{base_sha}:config/blast-radius.json"],
    capture_output=True, text=True, encoding="utf-8", check=True,
).stdout
config = json.loads(config_text)


def member_set(document: dict) -> set:
    """Return the edge member set (a, b, reason) of a C2 or C3 output."""
    return {(edge["a"], edge["b"], edge["reason"]) for edge in document["edges"]}


python_members = member_set(before_python)
powershell_members = member_set(before_powershell)
if python_members != powershell_members:
    print(f"STOP MISMATCH symmetric_difference={sorted(python_members ^ powershell_members)}")
    raise SystemExit(2)

items = []
sizes = []
# Copy each recorded item verbatim and pin the sizes of its constructed radius.
for record in radii["items"]:
    radius = BlastRadius.from_dict(record["blast_radius"])
    items.append(
        {
            "issue_num": record["issue_num"],
            "complexity_band": record["complexity_band"],
            "band_source": record["band_source"],
            "radius": record["blast_radius"],
        }
    )
    sizes.append(
        {
            "issue_num": record["issue_num"],
            "paths": len(radius.paths),
            "modules": len(radius.modules),
            "shared_surfaces": len(radius.shared_surfaces),
            "contracts": len(radius.contracts),
        }
    )

fixture = {
    "description": (
        f"Historical parallel run {slug} (issue #722). The item radii are copied verbatim from the "
        "run's parallel manifest at its plan-home commit. The BEFORE section pins the edges, cohorts, "
        "cohort count, and maximum cohort width derived with the pre-change truth table (embedded as "
        "before.config) and the unchanged contention relation; the Python and PowerShell runtimes "
        "agreed on the edge member set before these values were pinned."
    ),
    "run": slug,
    "source_ref": radii["ref_name"],
    "plan_home_commit": radii["plan_home_commit"],
    "manifest_blob": radii["manifest_blob"],
    "base_commit": base_sha,
    "items": items,
    "expected_radius_sizes": sizes,
    "before": {
        "config": config,
        "edges": [
            {"a": edge["a"], "b": edge["b"], "reason": edge["reason"]}
            for edge in before_python["edges"]
        ],
        "edge_count": before_python["edge_count"],
        "cohorts": before_python["cohorts"],
        "cohort_count": before_python["cohort_count"],
        "max_cohort_width": before_python["max_cohort_width"],
    },
}
Path(output_path).parent.mkdir(parents=True, exist_ok=True)
Path(output_path).write_text(json.dumps(fixture, indent=2) + "\n", encoding="utf-8", newline="\n")
print(
    f"FIXTURE run={slug} items={len(items)} base_commit={base_sha} runtimes=MATCH "
    f"edge_count={fixture['before']['edge_count']} cohort_count={fixture['before']['cohort_count']} "
    f"max_cohort_width={fixture['before']['max_cohort_width']}"
)
```

## Field-check script text (SCRATCH/historical-fixture-check.py)

```python
"""Check the three historical fixtures carry the B17 fields with the BEFORE section only."""

import json
from pathlib import Path

B17_TOP = {"run", "source_ref", "manifest_blob", "base_commit", "items", "expected_radius_sizes", "before"}
B17_ITEM = {"issue_num", "complexity_band", "band_source", "radius"}
B17_BEFORE = {"config", "edges", "edge_count", "cohorts", "cohort_count", "max_cohort_width"}

for slug in ("followups-2026-09-27", "backlog-2026-09-26", "epic-655-followups"):
    data = json.loads(Path(f"tests/fixtures/blast_radius/historical-runs/{slug}.json").read_text(encoding="utf-8"))
    missing_top = sorted(B17_TOP - set(data))
    extra_top = sorted(set(data) - B17_TOP)
    items_ok = all(B17_ITEM <= set(item) for item in data["items"])
    before_ok = B17_BEFORE == set(data["before"])
    before = data["before"]
    print(
        f"FIXTURE-CHECK run={slug} missing={missing_top} extra={extra_top} has_after={'after' in data} "
        f"items={len(data['items'])} item_fields_ok={items_ok} before_fields_ok={before_ok} "
        f"config_is_object={isinstance(before['config'], dict)} "
        f"config_has_conflict_tolerance={'conflict_tolerance' in before['config']} "
        f"edge_count={before['edge_count']} edges_len={len(before['edges'])} "
        f"cohort_count={before['cohort_count']} max_cohort_width={before['max_cohort_width']}"
    )
```

SCRATCH denotes the executor session scratchpad directory (outside the repository).
FEATURE denotes docs/features/active/blast-radius-over-reports-and-zero-overlap-tolerance-722.
