# Historical Radii Extraction (P0-T24)

Timestamp: 2026-09-27T15-00
Command: poetry run python SCRATCH/historical-extract.py <slug> <plan-home commit> <ref name> <output path> (three runs, listed below)
EXIT_CODE: 0
Output Summary: All three runs exited 0. epic-655-followups: 2 items, both band_source default_band (no kickoff exists; manifest carries no band). backlog-2026-09-26: 5 items, all band_source kickoff. followups-2026-09-27: 11 items, all band_source kickoff. Each JSON lists every manifest item with its blast_radius copied without modification; the total radius list-entry count in each JSON equals the count of radius list lines in the raw manifest text (228, 346, 594).

## Commands (each exit 0)

```text
poetry run python SCRATCH/historical-extract.py epic-655-followups 76ff7f4809106371bf972f8a3ca77d10fadbe14f origin/parallel/epic-655-followups-plan FEATURE/evidence/other/historical-epic-655-followups-radii.2026-09-27T15-00.json
poetry run python SCRATCH/historical-extract.py backlog-2026-09-26 141bf50f3530e481559716514bddc2d361549574 origin/parallel/backlog-2026-09-26-plan FEATURE/evidence/other/historical-backlog-2026-09-26-radii.2026-09-27T15-00.json
poetry run python SCRATCH/historical-extract.py followups-2026-09-27 ed9b595935e811be5e6405def9c962c8b901bc8b origin/parallel/followups-2026-09-27-plan FEATURE/evidence/other/historical-followups-2026-09-27-radii.2026-09-27T15-00.json
```

FEATURE denotes docs/features/active/blast-radius-over-reports-and-zero-overlap-tolerance-722; the
output paths were passed repository-relative.

## Per-run results

### epic-655-followups (2 items; manifest blob 397ac058aed2c65df7217666e3b46f16c6114eed)

| issue_num | complexity_band | band_source | paths |
| --- | --- | --- | --- |
| 660 | null | default_band | 14 |
| 663 | null | default_band | 205 |

### backlog-2026-09-26 (5 items; manifest blob cf4be5ee3c0a9ab61ac98a9a70be73f7643d3f58)

| issue_num | complexity_band | band_source | paths |
| --- | --- | --- | --- |
| 513 | C2 | kickoff | 12 |
| 528 | C2 | kickoff | 39 |
| 588 | C3 | kickoff | 108 |
| 594 | C3 | kickoff | 30 |
| 622 | C3 | kickoff | 147 |

### followups-2026-09-27 (11 items; manifest blob 4d0ae3053a65e070c4e37bfe9a40ff8350393e4d)

| issue_num | complexity_band | band_source | paths |
| --- | --- | --- | --- |
| 706 | C3 | kickoff | 19 |
| 707 | C3 | kickoff | 157 |
| 708 | C3 | kickoff | 36 |
| 709 | C3 | kickoff | 34 |
| 710 | C3 | kickoff | 89 |
| 711 | C2 | kickoff | 14 |
| 712 | C3 | kickoff | 18 |
| 713 | C3 | kickoff | 112 |
| 714 | C2 | kickoff | 17 |
| 715 | C2 | kickoff | 17 |
| 716 | C2 | kickoff | 41 |

## Verbatim-copy cross-check

The radius list entries (paths, modules, shared_surfaces, contracts) in each output JSON were totalled
and compared with an independent count of radius list lines in the raw manifest text
(git grep -c -E "^        - " <plan-home commit> -- <manifest path>):

| Run | Raw manifest list lines | JSON radius entries | Equal |
| --- | --- | --- | --- |
| epic-655-followups | 228 | 228 | yes |
| backlog-2026-09-26 | 346 | 346 | yes |
| followups-2026-09-27 | 594 | 594 | yes |

A search of the three JSON files for host-path markers (drive-letter prefixes, user directories)
returned no match.

## Execution note

The first attempt of each run failed with FileNotFoundError because the evidence/other directory did
not exist yet; one line creating the parent directory was added before the write, and the three runs
were repeated. Only the repeated runs' outputs are recorded.

## Full script text (SCRATCH/historical-extract.py, contract C1)

```python
"""Contract C1: read a parallel-run manifest verbatim at its plan-home commit.

Arguments: slug, plan-home commit (40 hex), ref name (recorded only), output path.
Writes a JSON object with the slug, ref name, plan-home commit, manifest blob SHA, and one
entry per manifest item carrying issue_num, the blast_radius object copied without change,
complexity_band, and band_source (manifest, kickoff, or default_band). No absolute path is
written to the output.
"""

import json
import re
import shutil
import subprocess
import sys
from pathlib import Path

import yaml

slug, commit, ref_name, output_path = sys.argv[1:5]
if re.fullmatch(r"[0-9a-f]{40}", commit) is None:
    raise SystemExit(f"plan-home commit must be 40 hexadecimal characters: {commit}")

git = shutil.which("git")
if git is None:
    raise SystemExit("git executable not found")

manifest_path = f"docs/features/parallel/{slug}/parallel.md"


def run_git(*args: str) -> str:
    """Run one git command and return its stdout; raise on a non-zero exit."""
    return subprocess.run([git, *args], capture_output=True, text=True, encoding="utf-8", check=True).stdout


manifest_text = run_git("show", f"{commit}:{manifest_path}")
manifest_blob = run_git("rev-parse", f"{commit}:{manifest_path}").strip()

# Frontmatter is the block between the first two '---' fence lines.
lines = manifest_text.splitlines()
if not lines or lines[0].strip() != "---":
    raise SystemExit("manifest does not open with a frontmatter fence")
end = next(index for index in range(1, len(lines)) if lines[index].strip() == "---")
frontmatter = yaml.safe_load("\n".join(lines[1:end]))
items = frontmatter["items"]


def kickoff_bands() -> dict[int, str] | None:
    """Read the kickoff table complexity column from the primary checkout, if readable."""
    listing = run_git("worktree", "list", "--porcelain")
    first = next(line for line in listing.splitlines() if line.startswith("worktree "))
    primary = Path(first[len("worktree "):])
    kickoff = primary / "artifacts" / "orchestration" / f"parallel-kickoff-{slug}.md"
    if not kickoff.is_file():
        return None
    bands: dict[int, str] = {}
    header: list[str] | None = None
    # Walk the markdown table rows; the header row names the issue_num and complexity columns.
    for raw in kickoff.read_text(encoding="utf-8").splitlines():
        if not raw.startswith("|"):
            header = None
            continue
        cells = [cell.strip() for cell in raw.strip().strip("|").split("|")]
        if header is None:
            if "issue_num" in cells and "complexity" in cells:
                header = cells
            continue
        if set(cells[0]) <= {"-", " ", ":"}:
            continue
        row = dict(zip(header, cells))
        if row.get("issue_num", "").isdigit():
            bands[int(row["issue_num"])] = row["complexity"]
    return bands


bands_from_kickoff = None if all("complexity_band" in item for item in items) else kickoff_bands()

records = []
# Band source order per contract C1: manifest, then kickoff table, then default_band.
for item in items:
    issue_num = item["issue_num"]
    if "complexity_band" in item:
        band, source = item["complexity_band"], "manifest"
    elif bands_from_kickoff is not None and issue_num in bands_from_kickoff:
        band, source = bands_from_kickoff[issue_num], "kickoff"
    else:
        band, source = None, "default_band"
    records.append(
        {
            "issue_num": issue_num,
            "blast_radius": item["blast_radius"],
            "complexity_band": band,
            "band_source": source,
        }
    )

document = {
    "slug": slug,
    "ref_name": ref_name,
    "plan_home_commit": commit,
    "manifest_blob": manifest_blob,
    "items": records,
}
Path(output_path).parent.mkdir(parents=True, exist_ok=True)
Path(output_path).write_text(json.dumps(document, indent=2) + "\n", encoding="utf-8")
print(f"EXTRACT slug={slug} items={len(records)} manifest_blob={manifest_blob}")
for record in records:
    print(f"ITEM issue={record['issue_num']} band={record['complexity_band']} band_source={record['band_source']} paths={len(record['blast_radius']['paths'])}")
```
