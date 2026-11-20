# Historical BEFORE Re-derivation, Python and PowerShell (P0-T25, P0-T26, P0-T27)

Timestamp: 2026-09-27T15-10
Command: poetry run python SCRATCH/historical-edges.py before <radii JSON> config/blast-radius.json <python output> ; sh SCRATCH/run-ps.sh SCRATCH/historical-edges.ps1 -Mode before -RadiiPath <radii JSON> -ConfigPath config/blast-radius.json -OutputPath <powershell output> ; poetry run python SCRATCH/historical-compare.py <python output> <powershell output> (three commands per run, nine in total, listed below)
EXIT_CODE: 0
Output Summary: All nine commands exited 0 and every run printed MATCH. BEFORE values (identical in both runtimes): epic-655-followups 1 edge, 2 cohorts, maximum cohort width 1; backlog-2026-09-26 4 edges, 2 cohorts, maximum cohort width 3; followups-2026-09-27 46 edges, 8 cohorts, maximum cohort width 2. The symmetric difference of the (a, b, reason) member sets is empty for every run, and the full reason-kind lists are also equal. Stop condition (MISMATCH) not reached.

## Commit

- HEAD: 395d0ee4a87ad0cd2cb7c1ed8ec0d2afcb7e2603
- BASE_SHA: beae3f021674e64fa6662097fe48a332d8da62b8 (the config was read as config/blast-radius.json at
  BASE_SHA with git show, in both runtimes)

## Plan-home commits (from P0-T23)

| Run | Plan-home commit |
| --- | --- |
| epic-655-followups | 76ff7f4809106371bf972f8a3ca77d10fadbe14f |
| backlog-2026-09-26 | 141bf50f3530e481559716514bddc2d361549574 |
| followups-2026-09-27 | ed9b595935e811be5e6405def9c962c8b901bc8b |

## Commands (each exit 0)

FEATURE denotes docs/features/active/blast-radius-over-reports-and-zero-overlap-tolerance-722; every
path argument was passed repository-relative.

```text
poetry run python SCRATCH/historical-edges.py before FEATURE/evidence/other/historical-epic-655-followups-radii.2026-09-27T15-00.json config/blast-radius.json FEATURE/evidence/other/historical-epic-655-followups-before-python.2026-09-27T15-05.json
poetry run python SCRATCH/historical-edges.py before FEATURE/evidence/other/historical-backlog-2026-09-26-radii.2026-09-27T15-00.json config/blast-radius.json FEATURE/evidence/other/historical-backlog-2026-09-26-before-python.2026-09-27T15-05.json
poetry run python SCRATCH/historical-edges.py before FEATURE/evidence/other/historical-followups-2026-09-27-radii.2026-09-27T15-00.json config/blast-radius.json FEATURE/evidence/other/historical-followups-2026-09-27-before-python.2026-09-27T15-05.json
sh SCRATCH/run-ps.sh SCRATCH/historical-edges.ps1 -Mode before -RadiiPath FEATURE/evidence/other/historical-epic-655-followups-radii.2026-09-27T15-00.json -ConfigPath config/blast-radius.json -OutputPath FEATURE/evidence/other/historical-epic-655-followups-before-powershell.2026-09-27T15-05.json
sh SCRATCH/run-ps.sh SCRATCH/historical-edges.ps1 -Mode before -RadiiPath FEATURE/evidence/other/historical-backlog-2026-09-26-radii.2026-09-27T15-00.json -ConfigPath config/blast-radius.json -OutputPath FEATURE/evidence/other/historical-backlog-2026-09-26-before-powershell.2026-09-27T15-05.json
sh SCRATCH/run-ps.sh SCRATCH/historical-edges.ps1 -Mode before -RadiiPath FEATURE/evidence/other/historical-followups-2026-09-27-radii.2026-09-27T15-00.json -ConfigPath config/blast-radius.json -OutputPath FEATURE/evidence/other/historical-followups-2026-09-27-before-powershell.2026-09-27T15-05.json
poetry run python SCRATCH/historical-compare.py FEATURE/evidence/other/historical-epic-655-followups-before-python.2026-09-27T15-05.json FEATURE/evidence/other/historical-epic-655-followups-before-powershell.2026-09-27T15-05.json
poetry run python SCRATCH/historical-compare.py FEATURE/evidence/other/historical-backlog-2026-09-26-before-python.2026-09-27T15-05.json FEATURE/evidence/other/historical-backlog-2026-09-26-before-powershell.2026-09-27T15-05.json
poetry run python SCRATCH/historical-compare.py FEATURE/evidence/other/historical-followups-2026-09-27-before-python.2026-09-27T15-05.json FEATURE/evidence/other/historical-followups-2026-09-27-before-powershell.2026-09-27T15-05.json
```

## Per-run BEFORE values and comparison verdict

PowerShell has no cohort-coloring function. The PowerShell column's partition is computed by applying
the Python cohort-coloring function (compute_cohorts) to the PowerShell edge set, inside contract C4.

| Run | Runtime | Edge count | Cohort partition | Cohort count | Max cohort width | Verdict |
| --- | --- | --- | --- | --- | --- | --- |
| epic-655-followups | Python | 1 | [[660], [663]] | 2 | 1 | MATCH |
| epic-655-followups | PowerShell | 1 | [[660], [663]] | 2 | 1 | MATCH |
| backlog-2026-09-26 | Python | 4 | [[513, 528, 622], [588, 594]] | 2 | 3 | MATCH |
| backlog-2026-09-26 | PowerShell | 4 | [[513, 528, 622], [588, 594]] | 2 | 3 | MATCH |
| followups-2026-09-27 | Python | 46 | [[710], [713], [716], [707, 714], [708], [712], [706, 709], [711, 715]] | 8 | 2 | MATCH |
| followups-2026-09-27 | PowerShell | 46 | [[710], [713], [716], [707, 714], [708], [712], [706, 709], [711, 715]] | 8 | 2 | MATCH |

Consistency note: the followups-2026-09-27 and backlog-2026-09-26 partitions equal the cohort columns
of the recorded kickoff tables for those runs (cohort index by item). This is a consistency check only;
the values above are the independently computed ones.

## C4 output per run (verbatim)

```text
COMPARE slug=epic-655-followups mode=before verdict=MATCH
PYTHON edge_count=1 POWERSHELL edge_count=1
EDGE-SYMMETRIC-DIFFERENCE []
INFO full-reason-kind-lists-equal=True
PYTHON-PARTITION [[660], [663]]
POWERSHELL-PARTITION [[660], [663]]
POWERSHELL cohort_count=2 max_cohort_width=1
MATCH
```

```text
COMPARE slug=backlog-2026-09-26 mode=before verdict=MATCH
PYTHON edge_count=4 POWERSHELL edge_count=4
EDGE-SYMMETRIC-DIFFERENCE []
INFO full-reason-kind-lists-equal=True
PYTHON-PARTITION [[513, 528, 622], [588, 594]]
POWERSHELL-PARTITION [[513, 528, 622], [588, 594]]
POWERSHELL cohort_count=2 max_cohort_width=3
MATCH
```

```text
COMPARE slug=followups-2026-09-27 mode=before verdict=MATCH
PYTHON edge_count=46 POWERSHELL edge_count=46
EDGE-SYMMETRIC-DIFFERENCE []
INFO full-reason-kind-lists-equal=True
PYTHON-PARTITION [[710], [713], [716], [707, 714], [708], [712], [706, 709], [711, 715]]
POWERSHELL-PARTITION [[710], [713], [716], [707, 714], [708], [712], [706, 709], [711, 715]]
POWERSHELL cohort_count=8 max_cohort_width=2
MATCH
```

## Edge member sets, both runtimes (rendered from the six output JSON files)

Each line is "a-b reason=<first canonical reason> kinds=<full reason-kind list>".

#### epic-655-followups / python (1 edges)

```text
660-663 reason=path_overlap kinds=path_overlap,shared_surface_overlap
```

#### epic-655-followups / powershell (1 edges)

```text
660-663 reason=path_overlap kinds=path_overlap,shared_surface_overlap
```

#### backlog-2026-09-26 / python (4 edges)

```text
528-588 reason=path_overlap kinds=path_overlap
528-594 reason=path_overlap kinds=path_overlap
588-622 reason=path_overlap kinds=path_overlap
594-622 reason=path_overlap kinds=path_overlap
```

#### backlog-2026-09-26 / powershell (4 edges)

```text
528-588 reason=path_overlap kinds=path_overlap
528-594 reason=path_overlap kinds=path_overlap
588-622 reason=path_overlap kinds=path_overlap
594-622 reason=path_overlap kinds=path_overlap
```

#### followups-2026-09-27 / python (46 edges)

```text
706-707 reason=path_overlap kinds=path_overlap
706-708 reason=path_overlap kinds=path_overlap
706-710 reason=path_overlap kinds=path_overlap
706-711 reason=path_overlap kinds=path_overlap
706-712 reason=path_overlap kinds=path_overlap
706-713 reason=path_overlap kinds=path_overlap
706-715 reason=path_overlap kinds=path_overlap
706-716 reason=path_overlap kinds=path_overlap
707-708 reason=path_overlap kinds=path_overlap,module_overlap,shared_surface_overlap
707-709 reason=path_overlap kinds=path_overlap,module_overlap,shared_surface_overlap
707-710 reason=path_overlap kinds=path_overlap,module_overlap,shared_surface_overlap
707-711 reason=path_overlap kinds=path_overlap
707-712 reason=path_overlap kinds=path_overlap
707-713 reason=path_overlap kinds=path_overlap,module_overlap,shared_surface_overlap
707-715 reason=path_overlap kinds=path_overlap
707-716 reason=path_overlap kinds=path_overlap
708-709 reason=path_overlap kinds=path_overlap,module_overlap,shared_surface_overlap
708-710 reason=path_overlap kinds=path_overlap,module_overlap,shared_surface_overlap,contract_dependency
708-711 reason=path_overlap kinds=path_overlap,module_overlap
708-712 reason=path_overlap kinds=path_overlap
708-713 reason=path_overlap kinds=path_overlap,module_overlap,shared_surface_overlap
708-715 reason=path_overlap kinds=path_overlap
708-716 reason=path_overlap kinds=path_overlap
709-710 reason=path_overlap kinds=path_overlap,module_overlap,shared_surface_overlap
709-711 reason=path_overlap kinds=path_overlap
709-712 reason=path_overlap kinds=path_overlap
709-713 reason=path_overlap kinds=path_overlap,module_overlap,shared_surface_overlap
709-715 reason=path_overlap kinds=path_overlap
709-716 reason=path_overlap kinds=path_overlap
710-711 reason=path_overlap kinds=path_overlap
710-712 reason=path_overlap kinds=path_overlap
710-713 reason=path_overlap kinds=path_overlap,module_overlap,shared_surface_overlap
710-714 reason=path_overlap kinds=path_overlap
710-715 reason=path_overlap kinds=path_overlap
710-716 reason=path_overlap kinds=path_overlap
711-712 reason=path_overlap kinds=path_overlap
711-713 reason=path_overlap kinds=path_overlap
711-716 reason=path_overlap kinds=path_overlap
712-713 reason=path_overlap kinds=path_overlap
712-715 reason=path_overlap kinds=path_overlap
712-716 reason=path_overlap kinds=path_overlap
713-714 reason=path_overlap kinds=path_overlap
713-715 reason=path_overlap kinds=path_overlap
713-716 reason=path_overlap kinds=path_overlap
714-716 reason=path_overlap kinds=path_overlap
715-716 reason=path_overlap kinds=path_overlap
```

#### followups-2026-09-27 / powershell (46 edges)

```text
706-707 reason=path_overlap kinds=path_overlap
706-708 reason=path_overlap kinds=path_overlap
706-710 reason=path_overlap kinds=path_overlap
706-711 reason=path_overlap kinds=path_overlap
706-712 reason=path_overlap kinds=path_overlap
706-713 reason=path_overlap kinds=path_overlap
706-715 reason=path_overlap kinds=path_overlap
706-716 reason=path_overlap kinds=path_overlap
707-708 reason=path_overlap kinds=path_overlap,module_overlap,shared_surface_overlap
707-709 reason=path_overlap kinds=path_overlap,module_overlap,shared_surface_overlap
707-710 reason=path_overlap kinds=path_overlap,module_overlap,shared_surface_overlap
707-711 reason=path_overlap kinds=path_overlap
707-712 reason=path_overlap kinds=path_overlap
707-713 reason=path_overlap kinds=path_overlap,module_overlap,shared_surface_overlap
707-715 reason=path_overlap kinds=path_overlap
707-716 reason=path_overlap kinds=path_overlap
708-709 reason=path_overlap kinds=path_overlap,module_overlap,shared_surface_overlap
708-710 reason=path_overlap kinds=path_overlap,module_overlap,shared_surface_overlap,contract_dependency
708-711 reason=path_overlap kinds=path_overlap,module_overlap
708-712 reason=path_overlap kinds=path_overlap
708-713 reason=path_overlap kinds=path_overlap,module_overlap,shared_surface_overlap
708-715 reason=path_overlap kinds=path_overlap
708-716 reason=path_overlap kinds=path_overlap
709-710 reason=path_overlap kinds=path_overlap,module_overlap,shared_surface_overlap
709-711 reason=path_overlap kinds=path_overlap
709-712 reason=path_overlap kinds=path_overlap
709-713 reason=path_overlap kinds=path_overlap,module_overlap,shared_surface_overlap
709-715 reason=path_overlap kinds=path_overlap
709-716 reason=path_overlap kinds=path_overlap
710-711 reason=path_overlap kinds=path_overlap
710-712 reason=path_overlap kinds=path_overlap
710-713 reason=path_overlap kinds=path_overlap,module_overlap,shared_surface_overlap
710-714 reason=path_overlap kinds=path_overlap
710-715 reason=path_overlap kinds=path_overlap
710-716 reason=path_overlap kinds=path_overlap
711-712 reason=path_overlap kinds=path_overlap
711-713 reason=path_overlap kinds=path_overlap
711-716 reason=path_overlap kinds=path_overlap
712-713 reason=path_overlap kinds=path_overlap
712-715 reason=path_overlap kinds=path_overlap
712-716 reason=path_overlap kinds=path_overlap
713-714 reason=path_overlap kinds=path_overlap
713-715 reason=path_overlap kinds=path_overlap
713-716 reason=path_overlap kinds=path_overlap
714-716 reason=path_overlap kinds=path_overlap
715-716 reason=path_overlap kinds=path_overlap
```

## Script text: SCRATCH/historical-edges.py (contract C2, before mode)

The after mode of C2 depends on the scheduling entry point that this plan adds later; the Phase 0
text implements before mode only and exits 2 if after mode is requested.

```python
"""Contract C2: historical conflict edges and cohorts, Python runtime.

Arguments: mode (before or after), radii JSON (contract C1 output), config path, output path.

Before mode: the config is read as it stands at BASE_SHA (the merge-base of HEAD and origin/main)
with git show; every unordered item pair runs through the unchanged Python conflicts function; an
edge is a conflicting pair recorded with the first canonical reason. The edge set is colored with
compute_cohorts. After mode needs the scheduling entry point added later by this plan and is not
implemented in this Phase 0 text; it exits 2 if requested.
"""

import json
import shutil
import subprocess
import sys
from itertools import combinations
from pathlib import Path

sys.path.insert(0, str(Path.cwd()))

from scripts.dev_tools._blast_radius_conflicts import conflicts  # noqa: E402
from scripts.dev_tools.compute_blast_radius import BlastRadius  # noqa: E402
from scripts.dev_tools.parallel_cohort_computation import compute_cohorts  # noqa: E402

mode, radii_path, config_path, output_path = sys.argv[1:5]
if mode != "before":
    print(f"STOP mode={mode} is not implemented in the Phase 0 version of contract C2")
    raise SystemExit(2)

git = shutil.which("git")
if git is None:
    raise SystemExit("git executable not found")


def run_git(*args: str) -> str:
    """Run one git command and return its stdout; raise on a non-zero exit."""
    return subprocess.run([git, *args], capture_output=True, text=True, encoding="utf-8", check=True).stdout


base_sha = run_git("merge-base", "HEAD", "origin/main").strip()
config = json.loads(run_git("show", f"{base_sha}:{config_path}"))

radii = json.loads(Path(radii_path).read_text(encoding="utf-8"))
keys = [item["issue_num"] for item in radii["items"]]
radius_by_key = {item["issue_num"]: BlastRadius.from_dict(item["blast_radius"]) for item in radii["items"]}

edges = []
# Evaluate every unordered pair once, in ascending key order, through the unchanged relation.
for a, b in combinations(sorted(keys), 2):
    result = conflicts(radius_by_key[a], radius_by_key[b], config)
    if result.conflict:
        kinds = [reason.kind for reason in result.reasons]
        edges.append({"a": a, "b": b, "reason": kinds[0], "reasons": kinds})

cohorts = compute_cohorts(keys, [(edge["a"], edge["b"]) for edge in edges])
document = {
    "mode": mode,
    "runtime": "python",
    "slug": radii["slug"],
    "config": f"{config_path} at BASE_SHA {base_sha}",
    "items": sorted(keys),
    "edges": edges,
    "edge_count": len(edges),
    "cohorts": cohorts,
    "cohort_count": len(cohorts),
    "max_cohort_width": max((len(cohort) for cohort in cohorts), default=0),
}
Path(output_path).parent.mkdir(parents=True, exist_ok=True)
Path(output_path).write_text(json.dumps(document, indent=2) + "\n", encoding="utf-8")
print(
    f"EDGES runtime=python mode={mode} slug={radii['slug']} edge_count={document['edge_count']} "
    f"cohort_count={document['cohort_count']} max_cohort_width={document['max_cohort_width']}"
)
print(f"COHORTS {json.dumps(cohorts)}")
```

## Script text: SCRATCH/historical-edges.ps1 (contract C3, before mode)

```powershell
# Contract C3: historical conflict edges, PowerShell runtime.
# Arguments: -Mode (before or after), -RadiiPath (contract C1 output), -ConfigPath, -OutputPath.
# Before mode reads the config as it stands at BASE_SHA (merge-base of HEAD and origin/main) with
# git show, runs every unordered item pair through the unchanged Test-BlastRadiusConflict, and
# records each conflicting pair with the first reason kind. After mode needs the scheduling function
# added later by this plan and is not implemented in this Phase 0 text; it exits 2 if requested.
param(
    [Parameter(Mandatory)][ValidateSet('before', 'after')][string] $Mode,
    [Parameter(Mandatory)][string] $RadiiPath,
    [Parameter(Mandatory)][string] $ConfigPath,
    [Parameter(Mandatory)][string] $OutputPath
)
$ErrorActionPreference = 'Stop'
if ($Mode -ne 'before') {
    Write-Output "STOP mode=$Mode is not implemented in the Phase 0 version of contract C3"
    exit 2
}

Import-Module (Resolve-Path -LiteralPath '.claude/lib/blast-radius/BlastRadius.psm1').Path -Force

$baseSha = (& git merge-base HEAD origin/main).Trim()
if ($LASTEXITCODE -ne 0) { throw 'git merge-base failed' }
$configText = (& git show "$($baseSha):$ConfigPath") -join "`n"
if ($LASTEXITCODE -ne 0) { throw 'git show of the config failed' }
$config = $configText | ConvertFrom-Json -AsHashtable

# -DateKind String keeps computed_at a string; the radius contract requires a string.
$radii = Get-Content -Raw -LiteralPath $RadiiPath | ConvertFrom-Json -AsHashtable -DateKind String
$radiusByKey = @{}
foreach ($item in $radii['items']) { $radiusByKey[[int]$item['issue_num']] = $item['blast_radius'] }
$keys = @($radiusByKey.Keys | Sort-Object)

$edges = [System.Collections.Generic.List[object]]::new()
# Evaluate every unordered pair once, ascending by key, through the unchanged relation.
for ($i = 0; $i -lt $keys.Count; $i++) {
    for ($j = $i + 1; $j -lt $keys.Count; $j++) {
        $a = $keys[$i]
        $b = $keys[$j]
        $result = Test-BlastRadiusConflict -RadiusA $radiusByKey[$a] -RadiusB $radiusByKey[$b] -Config $config
        if ($result['conflict']) {
            $kinds = @($result['reasons'] | ForEach-Object { $_['kind'] })
            $edges.Add([ordered]@{ a = $a; b = $b; reason = $kinds[0]; reasons = $kinds })
        }
    }
}

$document = [ordered]@{
    mode       = $Mode
    runtime    = 'powershell'
    slug       = $radii['slug']
    config     = "$ConfigPath at BASE_SHA $baseSha"
    items      = $keys
    edges      = @($edges.ToArray())
    edge_count = $edges.Count
}
$parent = Split-Path -Parent $OutputPath
if ($parent -and -not (Test-Path -LiteralPath $parent)) { $null = New-Item -ItemType Directory -Path $parent }
($document | ConvertTo-Json -Depth 6) | Set-Content -LiteralPath $OutputPath -Encoding utf8NoBOM
Write-Output "EDGES runtime=powershell mode=$Mode slug=$($radii['slug']) edge_count=$($edges.Count)"
```

## Script text: SCRATCH/historical-compare.py (contract C4)

```python
"""Contract C4: compare the Python and PowerShell historical edge member sets.

Arguments: Python edges JSON (contract C2 output), PowerShell edges JSON (contract C3 output).
Compares the edge member sets as (a, b, reason) triples and, in after mode, the tolerated-overlap
sets; prints MATCH or MISMATCH with the symmetric difference; colors the PowerShell edge set with
compute_cohorts and prints both partitions. Exits 0 on MATCH and 1 on MISMATCH.
"""

import json
import sys
from pathlib import Path

sys.path.insert(0, str(Path.cwd()))

from scripts.dev_tools.parallel_cohort_computation import compute_cohorts  # noqa: E402

python_doc = json.loads(Path(sys.argv[1]).read_text(encoding="utf-8"))
powershell_doc = json.loads(Path(sys.argv[2]).read_text(encoding="utf-8"))


def member_set(document: dict, field: str, reason_key: str) -> set[tuple]:
    """Return the (a, b, reason) member set of one list field of an edges document."""
    members = set()
    # A missing field is an empty set; before-mode documents carry no tolerated overlaps.
    for entry in document.get(field, []):
        reason = entry[reason_key]
        if isinstance(reason, list):
            reason = tuple(reason)
        members.add((int(entry["a"]), int(entry["b"]), reason))
    return members


def reason_kind_lists(document: dict) -> set[tuple]:
    """Return (a, b, all reason kinds) for every edge, for an informational comparison."""
    kinds = set()
    # PowerShell may render a one-element list as a bare string, so normalize before comparing.
    for entry in document.get("edges", []):
        reasons = entry.get("reasons", [])
        reasons = [reasons] if isinstance(reasons, str) else reasons
        kinds.add((int(entry["a"]), int(entry["b"]), tuple(reasons)))
    return kinds


verdict = "MATCH"
python_edges = member_set(python_doc, "edges", "reason")
powershell_edges = member_set(powershell_doc, "edges", "reason")
edge_difference = sorted(python_edges ^ powershell_edges)
if edge_difference:
    verdict = "MISMATCH"

tolerated_difference: list = []
if python_doc["mode"] == "after":
    python_tolerated = member_set(python_doc, "tolerated_overlaps", "reasons")
    powershell_tolerated = member_set(powershell_doc, "tolerated_overlaps", "reasons")
    tolerated_difference = sorted(python_tolerated ^ powershell_tolerated)
    if tolerated_difference:
        verdict = "MISMATCH"

powershell_items = [int(key) for key in powershell_doc["items"]]
powershell_cohorts = compute_cohorts(powershell_items, [(a, b) for a, b, _ in sorted(powershell_edges)])

print(f"COMPARE slug={python_doc['slug']} mode={python_doc['mode']} verdict={verdict}")
print(f"PYTHON edge_count={len(python_edges)} POWERSHELL edge_count={len(powershell_edges)}")
print(f"EDGE-SYMMETRIC-DIFFERENCE {json.dumps(edge_difference)}")
if python_doc["mode"] == "after":
    print(f"TOLERATED-SYMMETRIC-DIFFERENCE {json.dumps(tolerated_difference)}")
kinds_equal = reason_kind_lists(python_doc) == reason_kind_lists(powershell_doc)
print(f"INFO full-reason-kind-lists-equal={kinds_equal}")
print(f"PYTHON-PARTITION {json.dumps(python_doc['cohorts'])}")
print(f"POWERSHELL-PARTITION {json.dumps(powershell_cohorts)}")
print(
    f"POWERSHELL cohort_count={len(powershell_cohorts)} "
    f"max_cohort_width={max((len(cohort) for cohort in powershell_cohorts), default=0)}"
)
print(verdict)
raise SystemExit(0 if verdict == "MATCH" else 1)
```

## Output files (FEATURE/evidence/other)

- historical-epic-655-followups-before-python.2026-09-27T15-05.json
- historical-epic-655-followups-before-powershell.2026-09-27T15-05.json
- historical-backlog-2026-09-26-before-python.2026-09-27T15-05.json
- historical-backlog-2026-09-26-before-powershell.2026-09-27T15-05.json
- historical-followups-2026-09-27-before-python.2026-09-27T15-05.json
- historical-followups-2026-09-27-before-powershell.2026-09-27T15-05.json
