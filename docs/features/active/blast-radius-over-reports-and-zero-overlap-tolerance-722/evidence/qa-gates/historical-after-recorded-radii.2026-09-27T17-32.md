# Historical AFTER From Recorded Radii (P12-T1)

Timestamp: 2026-09-27T17-32
Command: for each slug S in epic-655-followups, backlog-2026-09-26, followups-2026-09-27: poetry run python SCRATCH/historical-edges.py after <FEATURE>/evidence/other/historical-S-radii.2026-09-27T15-00.json config/blast-radius.json <FEATURE>/evidence/other/historical-S-after-python.2026-09-27T17-32.json ; sh SCRATCH/run-ps.sh SCRATCH/historical-edges.ps1 -Mode after -RadiiPath (same radii JSON) -ConfigPath config/blast-radius.json -OutputPath <FEATURE>/evidence/other/historical-S-after-powershell.2026-09-27T17-32.json ; poetry run python SCRATCH/historical-compare.py (the two outputs)
EXIT_CODE: 0
Output Summary: Nine commands, every one exit 0. Every C4 comparison prints MATCH, with an empty edge symmetric difference and an empty tolerated-overlap symmetric difference; the informational full-record comparison (hard, cost, benefit) is also equal in every run. AFTER values from recorded radii: epic-655-followups edges 1, tolerated 0, cohorts 2, max width 1; backlog-2026-09-26 edges 2, tolerated 0, cohorts 2, max width 3; followups-2026-09-27 edges 17, tolerated 1, cohorts 5, max width 4.

FEATURE is docs/features/active/blast-radius-over-reports-and-zero-overlap-tolerance-722 (written as <FEATURE> in the command line above only as a path abbreviation).

## Inputs

- Radii: the P0-T24 recorded radii JSON of each run (FEATURE/evidence/other/historical-S-radii.2026-09-27T15-00.json), each item carrying its recorded complexity band (kickoff-sourced for backlog-2026-09-26 and followups-2026-09-27; null, meaning default_band, for epic-655-followups).
- Config: the committed self-hosted config config/blast-radius.json read with git show at HEAD 6f81b876df5dfb2334cf84c58b2dd408dbba5335 (write_intent_extraction true, path_roots set, conflict_tolerance at tolerance_percent 100).
- Derivation: each recorded radius passes through normalize_declared_radius (Python) and Get-NormalizedDeclaredRadius (PowerShell) with that config; the scheduling entry point (schedule_conflict_edges; Get-BlastRadiusConflictEdge) produces edges and tolerated overlaps; compute_cohorts colors the edge set. PowerShell has no cohort-coloring function, so C4 colors the PowerShell edge set with the Python compute_cohorts.

## Per-run command results

| Run | C2 (Python) exit | C3 (PowerShell) exit | C4 verdict | C4 exit |
| --- | --- | --- | --- | --- |
| epic-655-followups | 0 | 0 | MATCH | 0 |
| backlog-2026-09-26 | 0 | 0 | MATCH | 0 |
| followups-2026-09-27 | 0 | 0 | MATCH | 0 |

Printed C2 and C3 lines:

```text
EDGES runtime=python mode=after slug=epic-655-followups edge_count=1 tolerated_count=0 cohort_count=2 max_cohort_width=1
COHORTS [[660], [663]]
EDGES runtime=python mode=after slug=backlog-2026-09-26 edge_count=2 tolerated_count=0 cohort_count=2 max_cohort_width=3
COHORTS [[513, 588, 594], [528, 622]]
EDGES runtime=python mode=after slug=followups-2026-09-27 edge_count=17 tolerated_count=1 cohort_count=5 max_cohort_width=4
COHORTS [[707, 712, 714, 715], [706, 709, 711, 716], [708], [710], [713]]
EDGES runtime=powershell mode=after slug=epic-655-followups edge_count=1 tolerated_count=0
EDGES runtime=powershell mode=after slug=backlog-2026-09-26 edge_count=2 tolerated_count=0
EDGES runtime=powershell mode=after slug=followups-2026-09-27 edge_count=17 tolerated_count=1
```

## Per-run AFTER values (recorded radii)

| Run | AFTER edge count | Tolerated overlaps | Cohort count | Maximum cohort width | Cohort partition |
| --- | --- | --- | --- | --- | --- |
| epic-655-followups | 1 | 0 | 2 | 1 | [[660], [663]] |
| backlog-2026-09-26 | 2 | 0 | 2 | 3 | [[513, 588, 594], [528, 622]] |
| followups-2026-09-27 | 17 | 1 | 5 | 4 | [[707, 712, 714, 715], [706, 709, 711, 716], [708], [710], [713]] |

### epic-655-followups edges

| a | b | reason | hard | cost | benefit |
| --- | --- | --- | --- | --- | --- |
| 660 | 663 | path_overlap | True | 8 | 1 |

Tolerated overlaps: none.

### backlog-2026-09-26 edges

| a | b | reason | hard | cost | benefit |
| --- | --- | --- | --- | --- | --- |
| 528 | 588 | path_overlap | False | 8 | 2 |
| 588 | 622 | path_overlap | False | 152 | 4 |

Tolerated overlaps: none.

### followups-2026-09-27 edges

| a | b | reason | hard | cost | benefit |
| --- | --- | --- | --- | --- | --- |
| 706 | 707 | path_overlap | False | 16 | 4 |
| 706 | 708 | path_overlap | False | 16 | 4 |
| 706 | 710 | path_overlap | False | 16 | 4 |
| 706 | 713 | path_overlap | False | 16 | 4 |
| 706 | 715 | path_overlap | False | 48 | 2 |
| 707 | 708 | path_overlap | True | 100 | 4 |
| 707 | 709 | path_overlap | True | 50 | 4 |
| 707 | 710 | path_overlap | True | 132 | 4 |
| 707 | 711 | path_overlap | False | 8 | 2 |
| 707 | 713 | path_overlap | True | 148 | 4 |
| 708 | 709 | path_overlap | True | 34 | 4 |
| 708 | 710 | path_overlap | True | 52 | 4 |
| 708 | 713 | path_overlap | True | 76 | 4 |
| 709 | 710 | path_overlap | True | 66 | 4 |
| 709 | 713 | path_overlap | True | 82 | 4 |
| 710 | 713 | path_overlap | True | 196 | 4 |
| 714 | 716 | path_overlap | False | 16 | 2 |

Tolerated overlaps:

| a | b | reasons | cost | benefit |
| --- | --- | --- | --- | --- |
| 708 | 711 | module_overlap | 2 | 2 |

A hard edge whose recorded reason is path_overlap carries shared_surface_overlap or contract_dependency later in its full reason list; the recorded reason is the first canonical kind (rule 6 of the edge rule).

## Script-version note

The Phase 0 texts of C2 and C3 implemented before mode only and exited 2 for after mode. This task extends both with after mode per contracts C2 and C3; the before-mode statements are unchanged. C4 already implemented after mode; one informational line (full-record equality of hard, cost, and benefit) was added, and its MATCH or MISMATCH verdict logic is unchanged. The INFO full-reason-kind-lists-equal line reads a reasons field that after-mode edges do not carry, so it is trivially True in after mode and carries no signal there.

## Script texts and compare outputs

### C2 historical-edges.py

```python
"""Contract C2: historical conflict edges and cohorts, Python runtime.

Arguments: mode (before or after), radii JSON (contract C1 output), config path, output path.

Before mode: the config is read as it stands at BASE_SHA (the merge-base of HEAD and origin/main)
with git show; every unordered item pair runs through the unchanged Python conflicts function; an
edge is a conflicting pair recorded with the first canonical reason. The edge set is colored with
compute_cohorts.

After mode (Phase 12 extension): the config is the committed self-hosted config, read with git show
at HEAD. Each recorded radius passes through normalize_declared_radius with that config, then the
scheduling entry point schedule_conflict_edges (with each item's recorded complexity band, None
meaning default_band) produces the edges and the tolerated overlaps. The edge set is colored with
compute_cohorts. The before-mode statements are unchanged from the Phase 0 text.
"""

import json
import shutil
import subprocess
import sys
from itertools import combinations
from pathlib import Path

sys.path.insert(0, str(Path.cwd()))

from scripts.dev_tools._blast_radius_conflicts import conflicts  # noqa: E402
from scripts.dev_tools._blast_radius_scheduling import (  # noqa: E402
    SchedulingItem,
    schedule_conflict_edges,
)
from scripts.dev_tools.compute_blast_radius import (  # noqa: E402
    BlastRadius,
    normalize_declared_radius,
)
from scripts.dev_tools.parallel_cohort_computation import compute_cohorts  # noqa: E402

mode, radii_path, config_path, output_path = sys.argv[1:5]
if mode not in ("before", "after"):
    print(f"STOP mode={mode} is not a contract C2 mode")
    raise SystemExit(2)

git = shutil.which("git")
if git is None:
    raise SystemExit("git executable not found")


def run_git(*args: str) -> str:
    """Run one git command and return its stdout; raise on a non-zero exit."""
    return subprocess.run([git, *args], capture_output=True, text=True, encoding="utf-8", check=True).stdout


radii = json.loads(Path(radii_path).read_text(encoding="utf-8"))
keys = [item["issue_num"] for item in radii["items"]]
radius_by_key = {item["issue_num"]: BlastRadius.from_dict(item["blast_radius"]) for item in radii["items"]}
band_by_key = {item["issue_num"]: item["complexity_band"] for item in radii["items"]}

edges = []
tolerated = []
normalized_sizes = []
# Before mode reproduces the Phase 0 derivation; after mode normalizes and schedules.
if mode == "before":
    base_sha = run_git("merge-base", "HEAD", "origin/main").strip()
    config = json.loads(run_git("show", f"{base_sha}:{config_path}"))
    config_label = f"{config_path} at BASE_SHA {base_sha}"
    # Evaluate every unordered pair once, in ascending key order, through the unchanged relation.
    for a, b in combinations(sorted(keys), 2):
        result = conflicts(radius_by_key[a], radius_by_key[b], config)
        if result.conflict:
            kinds = [reason.kind for reason in result.reasons]
            edges.append({"a": a, "b": b, "reason": kinds[0], "reasons": kinds})
else:
    head_sha = run_git("rev-parse", "HEAD").strip()
    config = json.loads(run_git("show", f"HEAD:{config_path}"))
    config_label = f"{config_path} at HEAD {head_sha}"
    items = []
    # Normalize each recorded radius with the committed config and keep its recorded band.
    for key in sorted(keys):
        normalized = normalize_declared_radius(radius_by_key[key], config)
        items.append(SchedulingItem(key=key, radius=normalized, band=band_by_key[key]))
        normalized_sizes.append(
            {
                "issue_num": key,
                "paths": len(normalized.paths),
                "modules": len(normalized.modules),
                "shared_surfaces": len(normalized.shared_surfaces),
                "contracts": len(normalized.contracts),
            }
        )
    result = schedule_conflict_edges(items, config)
    edges = [edge.to_dict() for edge in result.edges]
    tolerated = [overlap.to_dict() for overlap in result.tolerated_overlaps]

cohorts = compute_cohorts(keys, [(edge["a"], edge["b"]) for edge in edges])
document = {
    "mode": mode,
    "runtime": "python",
    "slug": radii["slug"],
    "config": config_label,
    "items": sorted(keys),
    "edges": edges,
    "edge_count": len(edges),
    "cohorts": cohorts,
    "cohort_count": len(cohorts),
    "max_cohort_width": max((len(cohort) for cohort in cohorts), default=0),
}
# The tolerated overlaps and normalized sizes exist only in after mode.
if mode == "after":
    document["tolerated_overlaps"] = tolerated
    document["tolerated_count"] = len(tolerated)
    document["normalized_radius_sizes"] = normalized_sizes
Path(output_path).parent.mkdir(parents=True, exist_ok=True)
Path(output_path).write_text(json.dumps(document, indent=2) + "\n", encoding="utf-8", newline="\n")
print(
    f"EDGES runtime=python mode={mode} slug={radii['slug']} edge_count={document['edge_count']} "
    f"tolerated_count={len(tolerated)} cohort_count={document['cohort_count']} "
    f"max_cohort_width={document['max_cohort_width']}"
)
print(f"COHORTS {json.dumps(cohorts)}")
```

### C3 historical-edges.ps1

```powershell
# Contract C3: historical conflict edges, PowerShell runtime.
# Arguments: -Mode (before or after), -RadiiPath (contract C1 output), -ConfigPath, -OutputPath.
# Before mode reads the config as it stands at BASE_SHA (merge-base of HEAD and origin/main) with
# git show, runs every unordered item pair through the unchanged Test-BlastRadiusConflict, and
# records each conflicting pair with the first reason kind.
# After mode (Phase 12 extension) reads the committed self-hosted config with git show at HEAD,
# passes each recorded radius through Get-NormalizedDeclaredRadius with that config, and runs
# Get-BlastRadiusConflictEdge (each item carrying its recorded complexity band) to produce the
# edges and the tolerated overlaps. The before-mode statements are unchanged from the Phase 0 text.
param(
    [Parameter(Mandatory)][ValidateSet('before', 'after')][string] $Mode,
    [Parameter(Mandatory)][string] $RadiiPath,
    [Parameter(Mandatory)][string] $ConfigPath,
    [Parameter(Mandatory)][string] $OutputPath
)
$ErrorActionPreference = 'Stop'

Import-Module (Resolve-Path -LiteralPath '.claude/lib/blast-radius/BlastRadius.psm1').Path -Force

# -DateKind String keeps computed_at a string; the radius contract requires a string.
$radii = Get-Content -Raw -LiteralPath $RadiiPath | ConvertFrom-Json -AsHashtable -DateKind String
$radiusByKey = @{}
$bandByKey = @{}
foreach ($item in $radii['items']) {
    $radiusByKey[[int]$item['issue_num']] = $item['blast_radius']
    $bandByKey[[int]$item['issue_num']] = $item['complexity_band']
}
$keys = @($radiusByKey.Keys | Sort-Object)

$edges = [System.Collections.Generic.List[object]]::new()
$tolerated = [System.Collections.Generic.List[object]]::new()
if ($Mode -eq 'before') {
    $baseSha = (& git merge-base HEAD origin/main).Trim()
    if ($LASTEXITCODE -ne 0) { throw 'git merge-base failed' }
    $configText = (& git show "$($baseSha):$ConfigPath") -join "`n"
    if ($LASTEXITCODE -ne 0) { throw 'git show of the config failed' }
    $config = $configText | ConvertFrom-Json -AsHashtable
    $configLabel = "$ConfigPath at BASE_SHA $baseSha"
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
} else {
    $headSha = (& git rev-parse HEAD).Trim()
    if ($LASTEXITCODE -ne 0) { throw 'git rev-parse failed' }
    $configText = (& git show "HEAD:$ConfigPath") -join "`n"
    if ($LASTEXITCODE -ne 0) { throw 'git show of the config failed' }
    $config = $configText | ConvertFrom-Json -AsHashtable
    $configLabel = "$ConfigPath at HEAD $headSha"
    # Normalize each recorded radius with the committed config and keep its recorded band.
    $schedulingItem = @(foreach ($key in $keys) {
            $normalized = Get-NormalizedDeclaredRadius -Radius $radiusByKey[$key] -Config $config
            @{ key = [int]$key; radius = $normalized; band = $bandByKey[$key] }
        })
    $result = Get-BlastRadiusConflictEdge -Item $schedulingItem -Config $config
    foreach ($entry in @($result['edges'])) {
        $edges.Add([ordered]@{ a = [int]$entry['a']; b = [int]$entry['b']; reason = $entry['reason']; hard = $entry['hard']; cost = $entry['cost']; benefit = $entry['benefit'] })
    }
    foreach ($entry in @($result['tolerated_overlaps'])) {
        $tolerated.Add([ordered]@{ a = [int]$entry['a']; b = [int]$entry['b']; reasons = @($entry['reasons']); cost = $entry['cost']; benefit = $entry['benefit'] })
    }
}

$document = [ordered]@{
    mode       = $Mode
    runtime    = 'powershell'
    slug       = $radii['slug']
    config     = $configLabel
    items      = $keys
    edges      = @($edges.ToArray())
    edge_count = $edges.Count
}
if ($Mode -eq 'after') {
    $document['tolerated_overlaps'] = @($tolerated.ToArray())
    $document['tolerated_count'] = $tolerated.Count
}
$parent = Split-Path -Parent $OutputPath
if ($parent -and -not (Test-Path -LiteralPath $parent)) { $null = New-Item -ItemType Directory -Path $parent }
($document | ConvertTo-Json -Depth 6) | Set-Content -LiteralPath $OutputPath -Encoding utf8NoBOM
Write-Output "EDGES runtime=powershell mode=$Mode slug=$($radii['slug']) edge_count=$($edges.Count) tolerated_count=$($tolerated.Count)"
```

### C4 historical-compare.py

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
# After mode also carries hard, cost, and benefit; compare the full records for information.
if python_doc["mode"] == "after":

    def full_records(document: dict, field: str, names: tuple[str, ...]) -> set[tuple]:
        """Return the named fields of every record of one list field, as tuples."""
        return {
            tuple(tuple(entry[name]) if isinstance(entry[name], list) else entry[name] for name in names)
            for entry in document.get(field, [])
        }

    edge_names = ("a", "b", "reason", "hard", "cost", "benefit")
    tolerated_names = ("a", "b", "reasons", "cost", "benefit")
    edges_equal = full_records(python_doc, "edges", edge_names) == full_records(powershell_doc, "edges", edge_names)
    tolerated_equal = full_records(python_doc, "tolerated_overlaps", tolerated_names) == full_records(
        powershell_doc, "tolerated_overlaps", tolerated_names
    )
    print(f"INFO full-edge-records-equal={edges_equal} full-tolerated-records-equal={tolerated_equal}")
print(f"PYTHON-PARTITION {json.dumps(python_doc['cohorts'])}")
print(f"POWERSHELL-PARTITION {json.dumps(powershell_cohorts)}")
print(
    f"POWERSHELL cohort_count={len(powershell_cohorts)} "
    f"max_cohort_width={max((len(cohort) for cohort in powershell_cohorts), default=0)}"
)
print(verdict)
raise SystemExit(0 if verdict == "MATCH" else 1)
```

### C4 output, epic-655-followups

```text
COMPARE slug=epic-655-followups mode=after verdict=MATCH
PYTHON edge_count=1 POWERSHELL edge_count=1
EDGE-SYMMETRIC-DIFFERENCE []
TOLERATED-SYMMETRIC-DIFFERENCE []
INFO full-reason-kind-lists-equal=True
INFO full-edge-records-equal=True full-tolerated-records-equal=True
PYTHON-PARTITION [[660], [663]]
POWERSHELL-PARTITION [[660], [663]]
POWERSHELL cohort_count=2 max_cohort_width=1
MATCH
EXIT=0
```

### C4 output, backlog-2026-09-26

```text
COMPARE slug=backlog-2026-09-26 mode=after verdict=MATCH
PYTHON edge_count=2 POWERSHELL edge_count=2
EDGE-SYMMETRIC-DIFFERENCE []
TOLERATED-SYMMETRIC-DIFFERENCE []
INFO full-reason-kind-lists-equal=True
INFO full-edge-records-equal=True full-tolerated-records-equal=True
PYTHON-PARTITION [[513, 588, 594], [528, 622]]
POWERSHELL-PARTITION [[513, 588, 594], [528, 622]]
POWERSHELL cohort_count=2 max_cohort_width=3
MATCH
EXIT=0
```

### C4 output, followups-2026-09-27

```text
COMPARE slug=followups-2026-09-27 mode=after verdict=MATCH
PYTHON edge_count=17 POWERSHELL edge_count=17
EDGE-SYMMETRIC-DIFFERENCE []
TOLERATED-SYMMETRIC-DIFFERENCE []
INFO full-reason-kind-lists-equal=True
INFO full-edge-records-equal=True full-tolerated-records-equal=True
PYTHON-PARTITION [[707, 712, 714, 715], [706, 709, 711, 716], [708], [710], [713]]
POWERSHELL-PARTITION [[707, 712, 714, 715], [706, 709, 711, 716], [708], [710], [713]]
POWERSHELL cohort_count=5 max_cohort_width=4
MATCH
EXIT=0
```
