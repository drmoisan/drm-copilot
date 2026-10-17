# Process-Level Contract of the Drift Entry Script and the Python CLI (P3-T21)

Timestamp: 2026-09-29T18-00
Command: commands (a) through (h) of P3-T21, each run as one plain command from the repository root (listed below)
EXIT_CODE: 0
Output Summary:
- (a) exit 2; stderr `parallel drift detection usage error: -ItemKey is required.`; stdout empty (a
  rerun with stderr discarded printed nothing); no prompt text.
- (b) exit 2; stderr `parallel drift detection usage error: unrecognized parameter '-Bogus'.`
- (c) exit 0; stdout one JSON object, `result` `halt_required`, `halted_item_keys` `[445]` (saved to
  SCRATCH/drift-ps.json; contents below).
- (d) exit 1; stderr begins `parallel drift detection failed: ` (full line below, host path
  redacted); stdout empty (confirmed by a rerun with stderr discarded).
- (e) exit 0 (saved to SCRATCH/drift-py.json; contents below).
- (f) `JSON-EQUAL=true`.
- (g) exit 0; `result` `halt_required`, `escaped_paths` `["src/app.py"]`, `computed_at`
  `2026-08-08T10-00` (the omitted -ComputedAt defaults to the resolved -At, and the trailing
  `src/app.py` bound to ChangedPath, not to ComputedAt).
- (h) exit 0; `result` `no_escape`, `escaped_paths` `[]`, `drift_event` `null` (an omitted
  ChangedPath, which pwsh -File leaves null, is normalized to an empty list).

The artifact's EXIT_CODE records that every command produced its expected exit code; the
individual exit codes are 2, 2, 0, 1, 0, 0, 0, 0.

## Commands

(a) sh SCRATCH/run-ps.sh .claude/lib/parallel-drift/Invoke-ParallelDriftDetection.ps1
(b) sh SCRATCH/run-ps.sh .claude/lib/parallel-drift/Invoke-ParallelDriftDetection.ps1 -ItemKey 446 -Bogus value
(c) sh SCRATCH/run-ps.sh .claude/lib/parallel-drift/Invoke-ParallelDriftDetection.ps1 -ItemKey 446 -CheckpointPath tests/fixtures/parallel_drift_cli/checkpoint.json -ConfigPath tests/fixtures/parallel_drift_cli/config.json -At 2026-08-08T10-00 -ComputedAt 2026-08-08T10-05 src/app.py > SCRATCH/drift-ps.json
(d) sh SCRATCH/run-ps.sh .claude/lib/parallel-drift/Invoke-ParallelDriftDetection.ps1 -ItemKey 446 -CheckpointPath tests/fixtures/parallel_drift_cli/absent.json -ConfigPath tests/fixtures/parallel_drift_cli/config.json
(e) poetry run python -m scripts.dev_tools.parallel_drift_detection_cli --item-key 446 --checkpoint tests/fixtures/parallel_drift_cli/checkpoint.json --config tests/fixtures/parallel_drift_cli/config.json --at 2026-08-08T10-00 --computed-at 2026-08-08T10-05 src/app.py > SCRATCH/drift-py.json
(f) poetry run python SCRATCH/json-equal.py SCRATCH/drift-ps.json SCRATCH/drift-py.json
(g) sh SCRATCH/run-ps.sh .claude/lib/parallel-drift/Invoke-ParallelDriftDetection.ps1 -ItemKey 446 -CheckpointPath tests/fixtures/parallel_drift_cli/checkpoint.json -ConfigPath tests/fixtures/parallel_drift_cli/config.json -At 2026-08-08T10-00 src/app.py
(h) sh SCRATCH/run-ps.sh .claude/lib/parallel-drift/Invoke-ParallelDriftDetection.ps1 -ItemKey 446 -CheckpointPath tests/fixtures/parallel_drift_cli/checkpoint.json -ConfigPath tests/fixtures/parallel_drift_cli/config.json -At 2026-08-08T10-00

## (d) stderr (host path redacted to REPO_ROOT)

parallel drift detection failed: Exception calling "ReadAllText" with "2" argument(s): "Could not find file 'REPO_ROOT\tests\fixtures\parallel_drift_cli\absent.json'."

## SCRATCH/drift-ps.json (from c)

```json
{
  "at": "2026-08-08T10-00",
  "computed_at": "2026-08-08T10-05",
  "drift_event": {
    "action": "halted_later_started_item",
    "at": "2026-08-08T10-00",
    "declared": ["scripts/dev_tools/**"],
    "escaped_paths": ["src/app.py"],
    "item_key": 446,
    "observed": ["src/app.py"]
  },
  "escaped_paths": ["src/app.py"],
  "halted_item_keys": [445],
  "item_key": 446,
  "newly_conflicting_pairs": [[445, 446]],
  "observed_radius": {
    "computed_at": "2026-08-08T10-05",
    "contracts": [],
    "modules": [],
    "paths": ["src/app.py"],
    "shared_surfaces": [],
    "source": "observed"
  },
  "result": "halt_required"
}
```

## SCRATCH/drift-py.json (from e)

The Python CLI output carries the same keys and values as SCRATCH/drift-ps.json above (both are
indented two spaces with sorted keys; (f) confirms value equality):

```json
{
  "at": "2026-08-08T10-00",
  "computed_at": "2026-08-08T10-05",
  "drift_event": {
    "action": "halted_later_started_item",
    "at": "2026-08-08T10-00",
    "declared": ["scripts/dev_tools/**"],
    "escaped_paths": ["src/app.py"],
    "item_key": 446,
    "observed": ["src/app.py"]
  },
  "escaped_paths": ["src/app.py"],
  "halted_item_keys": [445],
  "item_key": 446,
  "newly_conflicting_pairs": [[445, 446]],
  "observed_radius": {
    "computed_at": "2026-08-08T10-05",
    "contracts": [],
    "modules": [],
    "paths": ["src/app.py"],
    "shared_surfaces": [],
    "source": "observed"
  },
  "result": "halt_required"
}
```

(The two quoted documents are shown with arrays collapsed onto one line for brevity; the saved files
place each array element on its own line.)

## (g) stdout

Same as (c) except `computed_at` is `2026-08-08T10-00` at the top level and in `observed_radius`.

## (h) stdout

```json
{"at": "2026-08-08T10-00", "computed_at": "2026-08-08T10-00", "drift_event": null, "escaped_paths": [], "halted_item_keys": [], "item_key": 446, "newly_conflicting_pairs": [], "observed_radius": null, "result": "no_escape"}
```
