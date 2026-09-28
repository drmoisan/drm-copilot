# Historical AFTER From Plan Text (P12-T2)

Timestamp: 2026-09-27T17-36
Command: for each slug S with plan-home commit H (P0-T23): poetry run python SCRATCH/historical-plan-after.py S H beae3f021674e64fa6662097fe48a332d8da62b8 <FEATURE>/evidence/other/historical-S-planafter-python.2026-09-27T17-36.json <FEATURE>/evidence/other/historical-S-radii.2026-09-27T15-00.json ; sh SCRATCH/run-ps.sh SCRATCH/historical-plan-after.ps1 -Slug S -PlanHome H -BaseSha beae3f021674e64fa6662097fe48a332d8da62b8 -OutputPath <FEATURE>/evidence/other/historical-S-planafter-powershell.2026-09-27T17-36.json -RadiiPath (same radii JSON) ; poetry run python SCRATCH/historical-compare.py (the two outputs)
EXIT_CODE: 0
Output Summary: Nine commands, every one exit 0; no STOP was printed. Every C4 comparison prints MATCH with empty edge and tolerated-overlap symmetric differences, and the per-item radius sizes are equal across runtimes. Items 660 (epic-655-followups) and 528 (backlog-2026-09-26) are recorded as SPEC-ABSENT with the marker line "- Work Mode: minor-audit". AFTER values from plan text: epic-655-followups edges 0, tolerated 0, cohorts 1, max width 2; backlog-2026-09-26 edges 2, tolerated 0, cohorts 2, max width 3; followups-2026-09-27 edges 15, tolerated 0, cohorts 5, max width 4.

FEATURE is docs/features/active/blast-radius-over-reports-and-zero-overlap-tolerance-722 (written as <FEATURE> in the command line above only as a path abbreviation).

## Pinned commits

| Run | Manifest read at plan-home commit (P0-T23) | Plan and spec text read at BASE_SHA |
| --- | --- | --- |
| epic-655-followups | 76ff7f4809106371bf972f8a3ca77d10fadbe14f | beae3f021674e64fa6662097fe48a332d8da62b8 |
| backlog-2026-09-26 | 141bf50f3530e481559716514bddc2d361549574 | beae3f021674e64fa6662097fe48a332d8da62b8 |
| followups-2026-09-27 | ed9b595935e811be5e6405def9c962c8b901bc8b | beae3f021674e64fa6662097fe48a332d8da62b8 |

Config: the committed self-hosted config/blast-radius.json read with git show at HEAD 6f81b876df5dfb2334cf84c58b2dd408dbba5335 (write_intent_extraction true, so derivation applies rules W1 through W6, including the line-context rules W2 and W3 and the spec-contracts-only rule W5, which the recorded-radii path of P12-T1 cannot exercise). Each radius is derived with derive_blast_radius (Python) and Get-BlastRadius (PowerShell) using the manifest feature_folder and computed_at 2026-09-27T00:00:00Z.

## Stop-condition check

C7 prints STOP and exits 2 when an item's feature folder is absent at BASE_SHA or holds a plan-file count other than one. No run printed STOP: every item's folder exists at BASE_SHA and holds exactly one plan file (listed below). No substitute source was used.

## Stated interpretations

- Bands: contract C7 names no band source. Both C7 scripts take each item's complexity band from the committed P0-T24 radii JSON (kickoff-sourced for backlog-2026-09-26 and followups-2026-09-27; null, meaning default_band, for epic-655-followups), so the benefit term is identical to P12-T1.
- Manifest parsing in PowerShell: PowerShell has no built-in YAML reader, so the PowerShell script reads issue_num and feature_folder from the frontmatter with anchored line patterns; the Python script uses yaml.safe_load. The per-item tables below show both runtimes read the same items and derived radii of the same sizes.

## Per-run command results

| Run | C7 Python exit | C7 PowerShell exit | C4 verdict | C4 exit |
| --- | --- | --- | --- | --- |
| epic-655-followups | 0 | 0 | MATCH | 0 |
| backlog-2026-09-26 | 0 | 0 | MATCH | 0 |
| followups-2026-09-27 | 0 | 0 | MATCH | 0 |

## Per-run AFTER values (plan text)

| Run | AFTER edge count | Tolerated overlaps | Cohort count | Maximum cohort width | Cohort partition |
| --- | --- | --- | --- | --- | --- |
| epic-655-followups | 0 | 0 | 1 | 2 | [[660, 663]] |
| backlog-2026-09-26 | 2 | 0 | 2 | 3 | [[513, 588, 594], [528, 622]] |
| followups-2026-09-27 | 15 | 0 | 5 | 4 | [[706, 707, 712, 714], [710, 711, 715, 716], [713], [708], [709]] |

## Item sources, member sets, comparisons, and script texts

### Item sources, epic-655-followups

#### epic-655-followups items (plan text at BASE_SHA beae3f021674e64fa6662097fe48a332d8da62b8)

| Item | Plan path | Spec path | Work Mode marker (spec absent) | Band | Python sizes p/m/s/c | PowerShell sizes p/m/s/c |
| --- | --- | --- | --- | --- | --- | --- |
| 660 | docs/features/active/cleanup-worktrees-test-suite-blind-spots-660/plan.2026-09-25T08-25.md | SPEC-ABSENT | - Work Mode: minor-audit | None | 8/0/1/0 | 8/0/1/0 |
| 663 | docs/features/active/enforcement-gates-lack-epic-level-checkpoint-seam-663/plan.2026-09-25T08-25.md | docs/features/active/enforcement-gates-lack-epic-level-checkpoint-seam-663/spec.md |  | None | 139/2/2/3 | 139/2/2/3 |

INFO radius-sizes-equal-across-runtimes=True

### Item sources, backlog-2026-09-26

#### backlog-2026-09-26 items (plan text at BASE_SHA beae3f021674e64fa6662097fe48a332d8da62b8)

| Item | Plan path | Spec path | Work Mode marker (spec absent) | Band | Python sizes p/m/s/c | PowerShell sizes p/m/s/c |
| --- | --- | --- | --- | --- | --- | --- |
| 513 | docs/features/active/2026-08-23-truth-table-non-emptiness-assertions-cannot-fail-513/plan.2026-09-25T22-06.md | docs/features/active/2026-08-23-truth-table-non-emptiness-assertions-cannot-fail-513/spec.md |  | C2 | 4/0/0/0 | 4/0/0/0 |
| 528 | docs/features/active/2026-08-23-readme-misstates-npm-publish-credential-528/plan.2026-09-25T22-06.md | SPEC-ABSENT | - Work Mode: minor-audit | C2 | 34/1/0/0 | 34/1/0/0 |
| 588 | docs/features/active/2026-08-28-pr-context-gh-detection-false-negative-588/plan.2026-09-25T22-06.md | docs/features/active/2026-08-28-pr-context-gh-detection-false-negative-588/spec.md |  | C3 | 82/0/0/2 | 82/0/0/2 |
| 594 | docs/features/active/2026-08-29-cleanup-worktrees-apply-deletes-local-main-594/plan.2026-09-25T22-07.md | docs/features/active/2026-08-29-cleanup-worktrees-apply-deletes-local-main-594/spec.md |  | C3 | 17/0/0/5 | 17/0/0/5 |
| 622 | docs/features/active/collect-pr-context-fabricates-auto-close-issues-622/plan.2026-09-25T23-29.md | docs/features/active/collect-pr-context-fabricates-auto-close-issues-622/spec.md |  | C3 | 120/0/0/0 | 120/0/0/0 |

INFO radius-sizes-equal-across-runtimes=True

### Item sources, followups-2026-09-27

#### followups-2026-09-27 items (plan text at BASE_SHA beae3f021674e64fa6662097fe48a332d8da62b8)

| Item | Plan path | Spec path | Work Mode marker (spec absent) | Band | Python sizes p/m/s/c | PowerShell sizes p/m/s/c |
| --- | --- | --- | --- | --- | --- | --- |
| 706 | docs/features/active/cleanup-report-registration-lost-false-positive-706/plan.2026-09-26T22-56.md | docs/features/active/cleanup-report-registration-lost-false-positive-706/spec.md |  | C3 | 8/0/0/1 | 8/0/0/1 |
| 707 | docs/features/active/codex-gates-4-5-lack-epic-scope-707/plan.2026-09-26T22-55.md | docs/features/active/codex-gates-4-5-lack-epic-scope-707/spec.md |  | C3 | 114/2/1/0 | 114/2/1/0 |
| 708 | docs/features/active/completion-consistency-edit-reads-relative-checkpoint-708/plan.2026-09-26T22-56.md | docs/features/active/completion-consistency-edit-reads-relative-checkpoint-708/spec.md |  | C3 | 24/2/1/6 | 24/2/1/6 |
| 709 | docs/features/active/gate-suites-read-unmocked-local-epic-state-709/plan.2026-09-26T22-55.md | docs/features/active/gate-suites-read-unmocked-local-epic-state-709/spec.md |  | C3 | 22/1/1/1 | 22/1/1/1 |
| 710 | docs/features/active/preimplementation-helpers-backslash-chain-operator-710/plan.2026-09-26T22-56.md | docs/features/active/preimplementation-helpers-backslash-chain-operator-710/spec.md |  | C3 | 64/2/1/2 | 64/2/1/2 |
| 711 | docs/features/active/2026-09-26-remaining-cannot-fail-count-assertions-711/plan.2026-09-26T22-56.md | docs/features/active/2026-09-26-remaining-cannot-fail-count-assertions-711/spec.md |  | C2 | 7/0/0/0 | 7/0/0/0 |
| 712 | docs/features/active/unused-npm-token-secret-712/plan.2026-09-27T00-23.md | docs/features/active/unused-npm-token-secret-712/spec.md |  | C3 | 11/0/0/0 | 11/0/0/0 |
| 713 | docs/features/active/preimplementation-gate-blocks-attribution-trailers-713/plan.2026-09-27T00-23.md | docs/features/active/preimplementation-gate-blocks-attribution-trailers-713/spec.md |  | C3 | 79/2/1/0 | 79/2/1/0 |
| 714 | docs/features/active/collector-core-no-whichgh-branch-untested-714/plan.2026-09-27T00-23.md | docs/features/active/collector-core-no-whichgh-branch-untested-714/spec.md |  | C2 | 8/0/0/0 | 8/0/0/0 |
| 715 | docs/features/active/cleanup-worktrees-bats-vacuous-t9-and-stale-citation-715/plan.2026-09-27T00-23.md | docs/features/active/cleanup-worktrees-bats-vacuous-t9-and-stale-citation-715/spec.md |  | C2 | 9/0/0/0 | 9/0/0/0 |
| 716 | docs/features/active/compare-code-point-helper-duplicated-716/plan.2026-09-27T00-23.md | docs/features/active/compare-code-point-helper-duplicated-716/spec.md |  | C2 | 21/0/2/4 | 21/0/2/4 |

INFO radius-sizes-equal-across-runtimes=True

### Edges and cohorts (Python)

### epic-655-followups (python, after)

- Config: config/blast-radius.json at HEAD 6f81b876df5dfb2334cf84c58b2dd408dbba5335
- Items: [660, 663]
- Edge count: 0
- Tolerated overlap count: 0
- Cohort partition: [[660, 663]]
- Cohort count: 1
- Maximum cohort width: 2

| a | b | reason | hard | cost | benefit |
| --- | --- | --- | --- | --- | --- |

Tolerated overlaps:

| a | b | reasons | cost | benefit |
| --- | --- | --- | --- | --- |

### backlog-2026-09-26 (python, after)

- Config: config/blast-radius.json at HEAD 6f81b876df5dfb2334cf84c58b2dd408dbba5335
- Items: [513, 528, 588, 594, 622]
- Edge count: 2
- Tolerated overlap count: 0
- Cohort partition: [[513, 588, 594], [528, 622]]
- Cohort count: 2
- Maximum cohort width: 3

| a | b | reason | hard | cost | benefit |
| --- | --- | --- | --- | --- | --- |
| 528 | 588 | path_overlap | False | 8 | 2 |
| 588 | 622 | path_overlap | False | 136 | 4 |

Tolerated overlaps:

| a | b | reasons | cost | benefit |
| --- | --- | --- | --- | --- |

### followups-2026-09-27 (python, after)

- Config: config/blast-radius.json at HEAD 6f81b876df5dfb2334cf84c58b2dd408dbba5335
- Items: [706, 707, 708, 709, 710, 711, 712, 713, 714, 715, 716]
- Edge count: 15
- Tolerated overlap count: 0
- Cohort partition: [[706, 707, 712, 714], [710, 711, 715, 716], [713], [708], [709]]
- Cohort count: 5
- Maximum cohort width: 4

| a | b | reason | hard | cost | benefit |
| --- | --- | --- | --- | --- | --- |
| 706 | 710 | path_overlap | False | 8 | 4 |
| 706 | 713 | path_overlap | False | 8 | 4 |
| 706 | 715 | path_overlap | False | 16 | 2 |
| 707 | 708 | path_overlap | True | 36 | 4 |
| 707 | 709 | path_overlap | True | 34 | 4 |
| 707 | 710 | path_overlap | True | 132 | 4 |
| 707 | 711 | path_overlap | False | 8 | 2 |
| 707 | 713 | path_overlap | True | 140 | 4 |
| 708 | 709 | path_overlap | True | 26 | 4 |
| 708 | 710 | path_overlap | True | 20 | 4 |
| 708 | 713 | path_overlap | True | 36 | 4 |
| 709 | 710 | path_overlap | True | 58 | 4 |
| 709 | 713 | path_overlap | True | 58 | 4 |
| 710 | 713 | path_overlap | True | 180 | 4 |
| 714 | 716 | path_overlap | False | 8 | 2 |

Tolerated overlaps:

| a | b | reasons | cost | benefit |
| --- | --- | --- | --- | --- |

### Member sets, both runtimes

#### epic-655-followups / python (0 edges, 0 tolerated)

```text
```

#### epic-655-followups / powershell (0 edges, 0 tolerated)

```text
```

#### backlog-2026-09-26 / python (2 edges, 0 tolerated)

```text
edge 528-588 reason=path_overlap hard=False cost=8 benefit=2
edge 588-622 reason=path_overlap hard=False cost=136 benefit=4
```

#### backlog-2026-09-26 / powershell (2 edges, 0 tolerated)

```text
edge 528-588 reason=path_overlap hard=False cost=8 benefit=2
edge 588-622 reason=path_overlap hard=False cost=136 benefit=4
```

#### followups-2026-09-27 / python (15 edges, 0 tolerated)

```text
edge 706-710 reason=path_overlap hard=False cost=8 benefit=4
edge 706-713 reason=path_overlap hard=False cost=8 benefit=4
edge 706-715 reason=path_overlap hard=False cost=16 benefit=2
edge 707-708 reason=path_overlap hard=True cost=36 benefit=4
edge 707-709 reason=path_overlap hard=True cost=34 benefit=4
edge 707-710 reason=path_overlap hard=True cost=132 benefit=4
edge 707-711 reason=path_overlap hard=False cost=8 benefit=2
edge 707-713 reason=path_overlap hard=True cost=140 benefit=4
edge 708-709 reason=path_overlap hard=True cost=26 benefit=4
edge 708-710 reason=path_overlap hard=True cost=20 benefit=4
edge 708-713 reason=path_overlap hard=True cost=36 benefit=4
edge 709-710 reason=path_overlap hard=True cost=58 benefit=4
edge 709-713 reason=path_overlap hard=True cost=58 benefit=4
edge 710-713 reason=path_overlap hard=True cost=180 benefit=4
edge 714-716 reason=path_overlap hard=False cost=8 benefit=2
```

#### followups-2026-09-27 / powershell (15 edges, 0 tolerated)

```text
edge 706-710 reason=path_overlap hard=False cost=8 benefit=4
edge 706-713 reason=path_overlap hard=False cost=8 benefit=4
edge 706-715 reason=path_overlap hard=False cost=16 benefit=2
edge 707-708 reason=path_overlap hard=True cost=36 benefit=4
edge 707-709 reason=path_overlap hard=True cost=34 benefit=4
edge 707-710 reason=path_overlap hard=True cost=132 benefit=4
edge 707-711 reason=path_overlap hard=False cost=8 benefit=2
edge 707-713 reason=path_overlap hard=True cost=140 benefit=4
edge 708-709 reason=path_overlap hard=True cost=26 benefit=4
edge 708-710 reason=path_overlap hard=True cost=20 benefit=4
edge 708-713 reason=path_overlap hard=True cost=36 benefit=4
edge 709-710 reason=path_overlap hard=True cost=58 benefit=4
edge 709-713 reason=path_overlap hard=True cost=58 benefit=4
edge 710-713 reason=path_overlap hard=True cost=180 benefit=4
edge 714-716 reason=path_overlap hard=False cost=8 benefit=2
```

### C4 output, epic-655-followups

```text
COMPARE slug=epic-655-followups mode=after verdict=MATCH
PYTHON edge_count=0 POWERSHELL edge_count=0
EDGE-SYMMETRIC-DIFFERENCE []
TOLERATED-SYMMETRIC-DIFFERENCE []
INFO full-reason-kind-lists-equal=True
INFO full-edge-records-equal=True full-tolerated-records-equal=True
PYTHON-PARTITION [[660, 663]]
POWERSHELL-PARTITION [[660, 663]]
POWERSHELL cohort_count=1 max_cohort_width=2
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
PYTHON edge_count=15 POWERSHELL edge_count=15
EDGE-SYMMETRIC-DIFFERENCE []
TOLERATED-SYMMETRIC-DIFFERENCE []
INFO full-reason-kind-lists-equal=True
INFO full-edge-records-equal=True full-tolerated-records-equal=True
PYTHON-PARTITION [[706, 707, 712, 714], [710, 711, 715, 716], [713], [708], [709]]
POWERSHELL-PARTITION [[706, 707, 712, 714], [710, 711, 715, 716], [713], [708], [709]]
POWERSHELL cohort_count=5 max_cohort_width=4
MATCH
EXIT=0
```

### C7 historical-plan-after.py

```python
"""Contract C7: historical AFTER from plan text, Python runtime.

Arguments: slug, plan-home commit (the P0-T23 value), BASE_SHA, output path, and the P0-T24 radii
JSON of the run (read only for each item's recorded complexity band; contract C7 names no band
source, and using the P0-recorded band keeps the benefit term identical to P12-T1).

Reads each item's issue_num and feature_folder from the run manifest at the plan-home commit with
git show. Lists the item's feature folder at BASE_SHA with git ls-tree; the plan is the single file
whose name starts with "plan." and ends with ".md", and the spec is spec.md. When the folder is
absent at BASE_SHA, or holds zero or more than one plan file, the script prints STOP with the item
and exits 2; there is no second source and no selection among candidates. When spec.md is absent the
spec text is the empty string, and the spec path is recorded as the literal SPEC-ABSENT together
with the Work Mode marker line read from the item's issue.md at BASE_SHA.

Reads the plan text, and the spec text when present, with git show at BASE_SHA; derives each radius
with derive_blast_radius and the committed config (git show HEAD:config/blast-radius.json, with
write_intent_extraction true); runs schedule_conflict_edges and compute_cohorts; writes the fields of
contract C2 after mode plus the plan path and spec path of every item.
"""

import json
import shutil
import subprocess
import sys
from pathlib import Path

import yaml

sys.path.insert(0, str(Path.cwd()))

from scripts.dev_tools._blast_radius_scheduling import (  # noqa: E402
    SchedulingItem,
    schedule_conflict_edges,
)
from scripts.dev_tools.compute_blast_radius import derive_blast_radius  # noqa: E402
from scripts.dev_tools.parallel_cohort_computation import compute_cohorts  # noqa: E402

COMPUTED_AT = "2026-09-27T00:00:00Z"
slug, plan_home, base_sha, output_path, radii_path = sys.argv[1:6]

git = shutil.which("git")
if git is None:
    raise SystemExit("git executable not found")


def run_git(*args: str) -> subprocess.CompletedProcess[str]:
    """Run one git command and return the completed process (the caller checks the exit code)."""
    return subprocess.run([git, *args], capture_output=True, text=True, encoding="utf-8", check=False)


def git_text(*args: str) -> str:
    """Run one git command and return its stdout; raise on a non-zero exit."""
    completed = run_git(*args)
    if completed.returncode != 0:
        raise SystemExit(f"git {' '.join(args)} failed: {completed.stderr.strip()}")
    return completed.stdout


head_sha = git_text("rev-parse", "HEAD").strip()
config = json.loads(git_text("show", "HEAD:config/blast-radius.json"))
if config.get("write_intent_extraction") is not True:
    print("STOP committed config does not enable write_intent_extraction")
    raise SystemExit(2)

manifest_text = git_text("show", f"{plan_home}:docs/features/parallel/{slug}/parallel.md")
front = yaml.safe_load(manifest_text.split("---", 2)[1])
bands = {item["issue_num"]: item["complexity_band"] for item in json.loads(Path(radii_path).read_text(encoding="utf-8"))["items"]}

records = []
items = []
# Locate each item's plan and spec at BASE_SHA, stop on any ambiguity, and derive its radius.
for entry in front["items"]:
    issue_num = int(entry["issue_num"])
    folder = str(entry["feature_folder"]).rstrip("/")
    listing = run_git("ls-tree", "--name-only", f"{base_sha}:{folder}")
    # A missing folder is a stop: no other location is searched.
    if listing.returncode != 0:
        print(f"STOP item={issue_num} folder={folder} is absent at BASE_SHA")
        raise SystemExit(2)
    names = listing.stdout.split()
    plans = [name for name in names if name.startswith("plan.") and name.endswith(".md")]
    # Exactly one plan file is required; zero or several is a stop, never a selection.
    if len(plans) != 1:
        print(f"STOP item={issue_num} folder={folder} plan_file_count={len(plans)}")
        raise SystemExit(2)
    plan_path = f"{folder}/{plans[0]}"
    plan_text = git_text("show", f"{base_sha}:{plan_path}")
    # A minor-audit item carries no spec: record SPEC-ABSENT and the Work Mode marker instead.
    if "spec.md" in names:
        spec_path = f"{folder}/spec.md"
        spec_text = git_text("show", f"{base_sha}:{spec_path}")
        work_mode = None
    else:
        spec_path = "SPEC-ABSENT"
        spec_text = ""
        issue_text = git_text("show", f"{base_sha}:{folder}/issue.md")
        work_mode = next((line.strip() for line in issue_text.splitlines() if "Work Mode:" in line), "NO-WORK-MODE-LINE")
    radius = derive_blast_radius(plan_text, spec_text, folder, config, computed_at=COMPUTED_AT)
    items.append(SchedulingItem(key=issue_num, radius=radius, band=bands[issue_num]))
    records.append(
        {
            "issue_num": issue_num,
            "feature_folder": folder,
            "plan_path": plan_path,
            "spec_path": spec_path,
            "work_mode_line": work_mode,
            "band": bands[issue_num],
            "radius": radius.to_dict(),
            "radius_sizes": {
                "paths": len(radius.paths),
                "modules": len(radius.modules),
                "shared_surfaces": len(radius.shared_surfaces),
                "contracts": len(radius.contracts),
            },
        }
    )

result = schedule_conflict_edges(items, config)
edges = [edge.to_dict() for edge in result.edges]
tolerated = [overlap.to_dict() for overlap in result.tolerated_overlaps]
keys = [item.key for item in items]
cohorts = compute_cohorts(keys, [(edge["a"], edge["b"]) for edge in edges])
document = {
    "mode": "after",
    "source": "plan-text",
    "runtime": "python",
    "slug": slug,
    "plan_home_commit": plan_home,
    "base_sha": base_sha,
    "config": f"config/blast-radius.json at HEAD {head_sha}",
    "items": sorted(keys),
    "item_records": records,
    "edges": edges,
    "tolerated_overlaps": tolerated,
    "edge_count": len(edges),
    "tolerated_count": len(tolerated),
    "cohorts": cohorts,
    "cohort_count": len(cohorts),
    "max_cohort_width": max((len(cohort) for cohort in cohorts), default=0),
}
Path(output_path).parent.mkdir(parents=True, exist_ok=True)
Path(output_path).write_text(json.dumps(document, indent=2) + "\n", encoding="utf-8", newline="\n")
print(
    f"PLAN-AFTER runtime=python slug={slug} items={len(keys)} edge_count={len(edges)} "
    f"tolerated_count={len(tolerated)} cohort_count={len(cohorts)} max_cohort_width={document['max_cohort_width']}"
)
# One line per item so the artifact records the plan and spec sources.
for record in records:
    print(f"ITEM {record['issue_num']} plan={record['plan_path']} spec={record['spec_path']} work_mode={record['work_mode_line']}")
print(f"COHORTS {json.dumps(cohorts)}")
```

### C7 historical-plan-after.ps1

```powershell
# Contract C7: historical AFTER from plan text, PowerShell runtime.
# Arguments: -Slug, -PlanHome (the P0-T23 plan-home commit), -BaseSha, -OutputPath, and -RadiiPath
# (the P0-T24 radii JSON, read only for each item's recorded complexity band; contract C7 names no
# band source, and using the P0-recorded band keeps the benefit term identical to P12-T1).
# Reads each item's issue_num and feature_folder from the run manifest at the plan-home commit with
# git show. PowerShell has no built-in YAML reader, so the two fields are read from the frontmatter
# with anchored line patterns (an item line "  - issue_num: N" followed by its
# "    feature_folder: ..." line); the Python counterpart parses the same text with yaml.safe_load
# and contract C4 compares the two outputs. Lists the feature folder at BASE_SHA with git ls-tree;
# the plan is the single "plan.*.md" file and the spec is spec.md. A folder absent at BASE_SHA, or
# a plan-file count other than one, prints STOP and exits 2. An absent spec.md makes the spec text
# empty and records SPEC-ABSENT plus the Work Mode marker line of the item's issue.md at BASE_SHA.
# Derives each radius with Get-BlastRadius and the committed config (git show HEAD), then runs
# Get-BlastRadiusConflictEdge, and writes the edges, tolerated overlaps, and per-item sources.
param(
    [Parameter(Mandatory)][string] $Slug,
    [Parameter(Mandatory)][string] $PlanHome,
    [Parameter(Mandatory)][string] $BaseSha,
    [Parameter(Mandatory)][string] $OutputPath,
    [Parameter(Mandatory)][string] $RadiiPath
)
$ErrorActionPreference = 'Stop'
[Console]::OutputEncoding = [System.Text.UTF8Encoding]::new($false)
$computedAt = '2026-09-27T00:00:00Z'

Import-Module (Resolve-Path -LiteralPath '.claude/lib/blast-radius/BlastRadius.psm1').Path -Force

function Get-GitText {
    param([string[]] $GitArgs)
    $output = & git @GitArgs
    if ($LASTEXITCODE -ne 0) { throw "git $($GitArgs -join ' ') failed" }
    return (@($output) -join "`n")
}

$headSha = (Get-GitText -GitArgs @('rev-parse', 'HEAD')).Trim()
$config = Get-GitText -GitArgs @('show', 'HEAD:config/blast-radius.json') | ConvertFrom-Json -AsHashtable
if ($config['write_intent_extraction'] -ne $true) {
    Write-Output 'STOP committed config does not enable write_intent_extraction'
    exit 2
}

$manifest = Get-GitText -GitArgs @('show', "$($PlanHome):docs/features/parallel/$Slug/parallel.md")
$frontmatter = ($manifest -split "(?m)^---\s*$")[1]
$entry = [System.Collections.Generic.List[object]]::new()
$pendingIssue = $null
# Pair each item's issue_num line with the feature_folder line that follows it.
foreach ($line in ($frontmatter -split "`n")) {
    if ($line -match '^  - issue_num:\s*(\d+)\s*$') {
        $pendingIssue = [int]$Matches[1]
    } elseif ($null -ne $pendingIssue -and $line -match '^    feature_folder:\s*"?([^"]+?)"?\s*$') {
        $entry.Add(@{ issue_num = $pendingIssue; feature_folder = $Matches[1].TrimEnd('/') })
        $pendingIssue = $null
    }
}

$radii = Get-Content -Raw -LiteralPath $RadiiPath | ConvertFrom-Json -AsHashtable -DateKind String
$band = @{}
foreach ($item in $radii['items']) { $band[[int]$item['issue_num']] = $item['complexity_band'] }

$record = [System.Collections.Generic.List[object]]::new()
$schedulingItem = [System.Collections.Generic.List[object]]::new()
# Locate each item's plan and spec at BASE_SHA, stop on any ambiguity, and derive its radius.
foreach ($item in $entry) {
    $issue = $item['issue_num']
    $folder = $item['feature_folder']
    $listing = & git ls-tree --name-only "$($BaseSha):$folder"
    if ($LASTEXITCODE -ne 0) {
        Write-Output "STOP item=$issue folder=$folder is absent at BASE_SHA"
        exit 2
    }
    $names = @($listing)
    $plans = @($names | Where-Object { $_.StartsWith('plan.') -and $_.EndsWith('.md') })
    if ($plans.Count -ne 1) {
        Write-Output "STOP item=$issue folder=$folder plan_file_count=$($plans.Count)"
        exit 2
    }
    $planPath = "$folder/$($plans[0])"
    $planText = Get-GitText -GitArgs @('show', "$($BaseSha):$planPath")
    if ($names -contains 'spec.md') {
        $specPath = "$folder/spec.md"
        $specText = Get-GitText -GitArgs @('show', "$($BaseSha):$specPath")
        $workMode = $null
    } else {
        $specPath = 'SPEC-ABSENT'
        $specText = ''
        $issueText = Get-GitText -GitArgs @('show', "$($BaseSha):$folder/issue.md")
        $workMode = @($issueText -split "`n" | Where-Object { $_ -like '*Work Mode:*' } | ForEach-Object { $_.Trim() })[0]
    }
    $radius = Get-BlastRadius -PlanText $planText -SpecText $specText -FeatureFolder $folder -Config $config -ComputedAt $computedAt
    $schedulingItem.Add(@{ key = [int]$issue; radius = $radius; band = $band[[int]$issue] })
    $record.Add([ordered]@{
            issue_num      = $issue
            feature_folder = $folder
            plan_path      = $planPath
            spec_path      = $specPath
            work_mode_line = $workMode
            band           = $band[[int]$issue]
            radius_sizes   = [ordered]@{
                paths           = @($radius['paths']).Count
                modules         = @($radius['modules']).Count
                shared_surfaces = @($radius['shared_surfaces']).Count
                contracts       = @($radius['contracts']).Count
            }
        })
}

$result = Get-BlastRadiusConflictEdge -Item @($schedulingItem.ToArray()) -Config $config
$edges = @(foreach ($e in @($result['edges'])) {
        [ordered]@{ a = [int]$e['a']; b = [int]$e['b']; reason = $e['reason']; hard = $e['hard']; cost = $e['cost']; benefit = $e['benefit'] }
    })
$tolerated = @(foreach ($t in @($result['tolerated_overlaps'])) {
        [ordered]@{ a = [int]$t['a']; b = [int]$t['b']; reasons = @($t['reasons']); cost = $t['cost']; benefit = $t['benefit'] }
    })
$keys = @($schedulingItem | ForEach-Object { $_['key'] } | Sort-Object)

$document = [ordered]@{
    mode               = 'after'
    source             = 'plan-text'
    runtime            = 'powershell'
    slug               = $Slug
    plan_home_commit   = $PlanHome
    base_sha           = $BaseSha
    config             = "config/blast-radius.json at HEAD $headSha"
    items              = $keys
    item_records       = @($record.ToArray())
    edges              = $edges
    tolerated_overlaps = $tolerated
    edge_count         = $edges.Count
    tolerated_count    = $tolerated.Count
}
$parent = Split-Path -Parent $OutputPath
if ($parent -and -not (Test-Path -LiteralPath $parent)) { $null = New-Item -ItemType Directory -Path $parent }
($document | ConvertTo-Json -Depth 8) | Set-Content -LiteralPath $OutputPath -Encoding utf8NoBOM
Write-Output "PLAN-AFTER runtime=powershell slug=$Slug items=$($keys.Count) edge_count=$($edges.Count) tolerated_count=$($tolerated.Count)"
foreach ($r in $record) { Write-Output "ITEM $($r['issue_num']) plan=$($r['plan_path']) spec=$($r['spec_path']) work_mode=$($r['work_mode_line'])" }
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
