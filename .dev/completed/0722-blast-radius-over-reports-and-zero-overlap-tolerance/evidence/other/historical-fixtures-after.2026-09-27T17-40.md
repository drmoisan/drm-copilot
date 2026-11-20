# Historical Fixtures, AFTER Section (P12-T4)

Timestamp: 2026-09-27T17-40
Command: for each slug S: poetry run python SCRATCH/historical-fixture.py after S <FEATURE>/evidence/other/historical-S-after-python.2026-09-27T17-32.json <FEATURE>/evidence/other/historical-S-after-powershell.2026-09-27T17-32.json tests/fixtures/blast_radius/historical-runs/S.json
EXIT_CODE: 0
Output Summary: Three C6 after-mode runs, each exit 0 and each printing runtimes=MATCH (the Python and PowerShell AFTER edge and tolerated-overlap member sets, including hard, cost, and benefit, are identical). Each fixture's AFTER section equals the P12-T1 values for its run (after-equals-p12t1=True for all three). Each BEFORE section is unchanged: the SHA-256 of its serialized text is identical before and after the rewrite, each fixture re-serialized byte-identically before the rewrite, and git diff --numstat HEAD over the three fixtures reports 0 deleted lines.

FEATURE is docs/features/active/blast-radius-over-reports-and-zero-overlap-tolerance-722 (written as <FEATURE> above only as a path abbreviation). This artifact is not named by the plan; it is recorded so the P12-T4 acceptance has on-disk evidence, following the Phase 3 precedent (historical-fixtures-before).

## C6 after-mode output

```text
FIXTURE-AFTER run=followups-2026-09-27 config_commit=6f81b876df5dfb2334cf84c58b2dd408dbba5335 runtimes=MATCH edge_count=17 tolerated_count=1 cohort_count=5 max_cohort_width=4
FIXTURE-AFTER run=backlog-2026-09-26 config_commit=6f81b876df5dfb2334cf84c58b2dd408dbba5335 runtimes=MATCH edge_count=2 tolerated_count=0 cohort_count=2 max_cohort_width=3
FIXTURE-AFTER run=epic-655-followups config_commit=6f81b876df5dfb2334cf84c58b2dd408dbba5335 runtimes=MATCH edge_count=1 tolerated_count=0 cohort_count=2 max_cohort_width=1
```

## BEFORE-section check, before the rewrite (poetry run python SCRATCH/p12-fixture-check.py reserialize)

```text
CHECK run=followups-2026-09-27 reserialize-identical=True before-sha256=5efb399f7da48bdeb0d9cba1e9b1be07200a806238b11785f536e06ce4a237f3 has-after=False
CHECK run=backlog-2026-09-26 reserialize-identical=True before-sha256=1467d198f9785d6c0528de05026d0b8f0585d99d20f4a14f566ab2640f24bc0f has-after=False
CHECK run=epic-655-followups reserialize-identical=True before-sha256=c0b094b80e2b61d876af7dfd63e6873cc36d65cad9b404ac89fb2c9efdbb2495 has-after=False
```

## AFTER-value and BEFORE-section check, after the rewrite (poetry run python SCRATCH/p12-fixture-check.py after 2026-09-27T17-32)

```text
CHECK run=followups-2026-09-27 after-equals-p12t1=True edge_count=17 tolerated=1 cohort_count=5 max_cohort_width=4 before-sha256=5efb399f7da48bdeb0d9cba1e9b1be07200a806238b11785f536e06ce4a237f3
CHECK run=backlog-2026-09-26 after-equals-p12t1=True edge_count=2 tolerated=0 cohort_count=2 max_cohort_width=3 before-sha256=1467d198f9785d6c0528de05026d0b8f0585d99d20f4a14f566ab2640f24bc0f
CHECK run=epic-655-followups after-equals-p12t1=True edge_count=1 tolerated=0 cohort_count=2 max_cohort_width=1 before-sha256=c0b094b80e2b61d876af7dfd63e6873cc36d65cad9b404ac89fb2c9efdbb2495
```

## git diff --numstat HEAD -- tests/fixtures/blast_radius/historical-runs

```text
140	0	tests/fixtures/blast_radius/historical-runs/backlog-2026-09-26.json
129	0	tests/fixtures/blast_radius/historical-runs/epic-655-followups.json
282	0	tests/fixtures/blast_radius/historical-runs/followups-2026-09-27.json
```

The AFTER config pinned in each fixture is config/blast-radius.json at 6f81b876df5dfb2334cf84c58b2dd408dbba5335, the commit the P12-T1 derivation read.

## Script texts

### C6 historical-fixture.py (Phase 12 version)

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
After mode (Phase 12 extension). Arguments: after, slug, AFTER Python edges JSON (C2 after-mode
output), AFTER PowerShell edges JSON (C3 after-mode output), fixture path (read and rewritten):
  - loads the existing fixture and leaves every key other than "after" unchanged, so the BEFORE
    section keeps its exact serialized text (the fixture is re-serialized with the same
    json.dumps(indent=2) call that wrote it);
  - requires the Python and PowerShell AFTER edge member sets (a, b, reason, hard, cost, benefit)
    and tolerated-overlap member sets (a, b, reasons, cost, benefit) to be identical, and stops with
    exit 2 otherwise;
  - reads the committed config with git show at the commit named in the Python JSON's config field
    and pins it as after.config together with the AFTER edges, tolerated overlaps, edge count,
    cohorts, cohort count, and maximum cohort width from the Python JSON.
The before-mode statements are unchanged from the Phase 3 text.
"""

import json
import re
import shutil
import subprocess
import sys
from pathlib import Path

sys.path.insert(0, str(Path.cwd()))

from scripts.dev_tools.compute_blast_radius import BlastRadius  # noqa: E402

git = shutil.which("git")
if git is None:
    raise SystemExit("git executable not found")

mode = sys.argv[1]
# After mode is a self-contained branch that exits; before mode continues with the Phase 3 text.
if mode == "after":
    slug, after_python_path, after_powershell_path, fixture_path = sys.argv[2:6]
    after_python = json.loads(Path(after_python_path).read_text(encoding="utf-8"))
    after_powershell = json.loads(Path(after_powershell_path).read_text(encoding="utf-8"))
    fixture = json.loads(Path(fixture_path).read_text(encoding="utf-8"))
    if fixture["run"] != slug or after_python["slug"] != slug or after_python["mode"] != "after":
        print(f"STOP slug or mode mismatch: {slug} vs {fixture['run']} / {after_python['slug']} {after_python['mode']}")
        raise SystemExit(2)

    def full_members(document: dict, field: str, names: tuple[str, ...]) -> set:
        """Return the named fields of every record of one list field, as hashable tuples."""
        return {
            tuple(tuple(entry[name]) if isinstance(entry[name], list) else entry[name] for name in names)
            for entry in document[field]
        }

    edge_names = ("a", "b", "reason", "hard", "cost", "benefit")
    tolerated_names = ("a", "b", "reasons", "cost", "benefit")
    edge_diff = full_members(after_python, "edges", edge_names) ^ full_members(after_powershell, "edges", edge_names)
    tolerated_diff = full_members(after_python, "tolerated_overlaps", tolerated_names) ^ full_members(
        after_powershell, "tolerated_overlaps", tolerated_names
    )
    if edge_diff or tolerated_diff:
        print(f"STOP MISMATCH edges={sorted(edge_diff)} tolerated={sorted(tolerated_diff)}")
        raise SystemExit(2)

    head_match = re.search(r"at HEAD ([0-9a-f]{40})$", after_python["config"])
    if head_match is None:
        print(f"STOP no HEAD commit in config field: {after_python['config']!r}")
        raise SystemExit(2)
    after_config = json.loads(
        subprocess.run(
            [git, "show", f"{head_match.group(1)}:config/blast-radius.json"],
            capture_output=True, text=True, encoding="utf-8", check=True,
        ).stdout
    )
    fixture["after"] = {
        "config": after_config,
        "edges": after_python["edges"],
        "tolerated_overlaps": after_python["tolerated_overlaps"],
        "edge_count": after_python["edge_count"],
        "cohorts": after_python["cohorts"],
        "cohort_count": after_python["cohort_count"],
        "max_cohort_width": after_python["max_cohort_width"],
    }
    Path(fixture_path).write_text(json.dumps(fixture, indent=2) + "\n", encoding="utf-8", newline="\n")
    print(
        f"FIXTURE-AFTER run={slug} config_commit={head_match.group(1)} runtimes=MATCH "
        f"edge_count={after_python['edge_count']} tolerated_count={len(after_python['tolerated_overlaps'])} "
        f"cohort_count={after_python['cohort_count']} max_cohort_width={after_python['max_cohort_width']}"
    )
    raise SystemExit(0)

mode, slug, radii_path, python_path, powershell_path, output_path = sys.argv[1:7]
if mode != "before":
    print(f"STOP mode={mode} is not a contract C6 mode")
    raise SystemExit(2)

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

### p12-fixture-check.py

```python
"""Check historical fixtures: re-serialization identity, BEFORE-section digest, and AFTER values.

Arguments: "reserialize" to check that each fixture's text equals json.dumps(indent=2) of itself, or
"after <timestamp>" to compare each fixture's AFTER section with the P12-T1 Python JSON. Both modes
print the SHA-256 of the BEFORE section's serialized text so runs before and after the rewrite can be
compared.
"""

import hashlib
import json
import sys
from pathlib import Path

FIXTURES = Path("tests/fixtures/blast_radius/historical-runs")
EVIDENCE = Path("docs/features/active/blast-radius-over-reports-and-zero-overlap-tolerance-722/evidence/other")
mode = sys.argv[1]
# Report one line per run: digest of the BEFORE section, then the mode-specific check.
for slug in ("followups-2026-09-27", "backlog-2026-09-26", "epic-655-followups"):
    text = (FIXTURES / f"{slug}.json").read_text(encoding="utf-8")
    fixture = json.loads(text)
    before_digest = hashlib.sha256(json.dumps(fixture["before"], indent=2).encode("utf-8")).hexdigest()
    if mode == "reserialize":
        identical = text == json.dumps(fixture, indent=2) + "\n"
        print(f"CHECK run={slug} reserialize-identical={identical} before-sha256={before_digest} has-after={'after' in fixture}")
    else:
        stamp = sys.argv[2]
        source = json.loads((EVIDENCE / f"historical-{slug}-after-python.{stamp}.json").read_text(encoding="utf-8"))
        after = fixture["after"]
        fields = ("edges", "tolerated_overlaps", "edge_count", "cohorts", "cohort_count", "max_cohort_width")
        equal = all(after[name] == source[name] for name in fields)
        print(
            f"CHECK run={slug} after-equals-p12t1={equal} edge_count={after['edge_count']} "
            f"tolerated={len(after['tolerated_overlaps'])} cohort_count={after['cohort_count']} "
            f"max_cohort_width={after['max_cohort_width']} before-sha256={before_digest}"
        )
```
