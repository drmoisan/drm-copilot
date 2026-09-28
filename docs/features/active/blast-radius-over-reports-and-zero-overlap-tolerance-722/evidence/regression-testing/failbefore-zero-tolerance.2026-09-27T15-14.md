# Fail-before: Zero-tolerance Defect (P0-T29, expect-fail)

Timestamp: 2026-09-27T15-14
Command: poetry run python SCRATCH/failbefore-demo.py scheduling
EXIT_CODE: 1
ExpectedExitCode: 1
Output Summary: The script exited 1 as expected. Under the committed truth table, the two append-only radii of plan block B3 (each naming only CHANGELOG.md) are a detected conflict (path_overlap, detail "CHANGELOG.md ~ CHANGELOG.md"), and the current hand rule records every detected conflict as an edge, so the pair is serialized. The fix must tolerate this pair at the committed tolerance.

## Printed output (verbatim)

```text
B3 radius_a.paths=['CHANGELOG.md'] radius_b.paths=['CHANGELOG.md']
CONFLICT verdict=True reasons=['path_overlap'] details=['CHANGELOG.md ~ CHANGELOG.md']
DEFECT the two append-only CHANGELOG.md radii are a conflict edge under the current hand rule (every detected conflict is recorded as an edge); the fix must tolerate this pair at the committed tolerance
```

## Script text (SCRATCH/failbefore-demo.py, contract C5)

```python
"""Contract C5: fail-before demonstrations for the two defects of issue #722.

Argument: mode (scheduling or extraction). Uses the committed config/blast-radius.json.

Scheduling mode builds the two radii of plan block B3 (both name only CHANGELOG.md, empty modules,
shared surfaces, and contracts), prints the current conflicts verdict, and exits 1 when the pair is a
conflict: the current hand rule records every detected conflict as an edge, so the append-only pair is
serialized. Extraction mode derives the plan block B4 text with the current derive_blast_radius and
exits 1 when the derived paths contain any of the three over-reported tokens.
"""

import json
import sys
from pathlib import Path

sys.path.insert(0, str(Path.cwd()))

from scripts.dev_tools._blast_radius_conflicts import conflicts  # noqa: E402
from scripts.dev_tools.compute_blast_radius import BlastRadius, derive_blast_radius  # noqa: E402

mode = sys.argv[1]
config = json.loads(Path("config/blast-radius.json").read_text(encoding="utf-8"))

if mode == "scheduling":
    # Block B3: two declared radii whose only path is CHANGELOG.md.
    radius_a = BlastRadius(("CHANGELOG.md",), (), (), (), "declared", "2026-09-27T00-00")
    radius_b = BlastRadius(("CHANGELOG.md",), (), (), (), "declared", "2026-09-27T00-00")
    result = conflicts(radius_a, radius_b, config)
    kinds = [reason.kind for reason in result.reasons]
    details = [reason.detail for reason in result.reasons]
    print(f"B3 radius_a.paths={list(radius_a.paths)} radius_b.paths={list(radius_b.paths)}")
    print(f"CONFLICT verdict={result.conflict} reasons={kinds} details={details}")
    if result.conflict:
        print(
            "DEFECT the two append-only CHANGELOG.md radii are a conflict edge under the current hand "
            "rule (every detected conflict is recorded as an edge); the fix must tolerate this pair at "
            "the committed tolerance"
        )
        raise SystemExit(1)
    print("NO-DEFECT the pair is not a conflict")
    raise SystemExit(0)

if mode == "extraction":
    # Block B4, with each TASKLINE marker replaced by the canonical unchecked task prefix.
    task_prefix = "- [ ] "
    plan_text = "\n".join(
        [
            "### Phase 1 — Demonstration",
            "",
            task_prefix + "[P1-T1] Update `src/app.py` and the files matched by `src/**/*.py`; run `git add src/other.py`.",
            task_prefix + "[P1-T2] Read `src/policy.py` in full.",
            "",
        ]
    )
    radius = derive_blast_radius(plan_text, "", "failbefore-demo-722", config, computed_at="2026-09-27T00-00")
    over_reported = ["src/**/*.py", "src/other.py", "src/policy.py"]
    present = [token for token in over_reported if token in radius.paths]
    print("B4 PLAN TEXT")
    print(plan_text)
    print(f"DERIVED paths={list(radius.paths)}")
    print(f"OVER-REPORTED present={present} of {over_reported}")
    if present:
        print(
            "DEFECT the current derivation returns the glob token, the command-span token, and the "
            "read-task token as radius paths" if len(present) == len(over_reported) else
            "DEFECT the current derivation returns some of the over-reported tokens as radius paths"
        )
        raise SystemExit(1)
    print("NO-DEFECT none of the over-reported tokens is a radius path")
    raise SystemExit(0)

raise SystemExit(f"unknown mode {mode}")
```
