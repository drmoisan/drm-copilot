# p3t6-gap-inspection

Timestamp: 2026-10-18T18-20
Command: poetry run python SCRATCH/issue-980-p3t6-gap-read.py
EXIT_CODE: 0
Output Summary: {"name": "plan_snapshot_export", "start": 370, "end": 385, "covered": 3, "lines": 3, "percent": 100.0, "missing": []}; {"name": "plan_snapshot_import", "start": 388, "end": 403, "covered": 3, "lines": 3, "percent": 100.0, "missing": []}; {"name": "export_snapshot", "start": 406, "end": 420, "covered": 2, "lines": 2, "percent": 100.0, "missing": []}; {"name": "import_snapshot", "start": 423, "end": 437, "covered": 2, "lines": 2, "percent": 100.0, "missing": []}

Working directory: .
Started: 2026-10-18T18:20:53.223680+00:00
Duration seconds: 0.909
Phase: P3-T6 immutable source snapshot transport; focused task verification.

## Captured output

```text
{"path": "packages\\discovery-runtime\\src\\drm_copilot_discovery\\source_snapshots.py", "summary": {"covered_lines": 143, "num_statements": 152, "percent_covered": 91.66666666666667, "percent_covered_display": "92", "missing_lines": 9, "excluded_lines": 7, "percent_statements_covered": 94.07894736842105, "percent_statements_covered_display": "94", "num_branches": 52, "num_partial_branches": 6, "covered_branches": 44, "missing_branches": 8, "percent_branches_covered": 84.61538461538461, "percent_branches_covered_display": "85"}, "missing_lines": [155, 202, 220, 307, 334, 341, 342, 349, 352], "missing_arcs": [[154, 155], [201, 202], [219, 220], [306, 307], [333, 334], [340, 341], [342, 349], [342, 352]]}
{"name": "SnapshotExport", "start": 39, "end": 45, "covered": 5, "lines": 5, "percent": 100.0, "missing": []}
{"name": "SnapshotImport", "start": 49, "end": 55, "covered": 5, "lines": 5, "percent": 100.0, "missing": []}
{"name": "SnapshotProposal", "start": 59, "end": 63, "covered": 3, "lines": 3, "percent": 100.0, "missing": []}
{"name": "_closure", "start": 66, "end": 122, "covered": 28, "lines": 28, "percent": 100.0, "missing": []}
{"name": "_payloads", "start": 125, "end": 160, "covered": 19, "lines": 20, "percent": 95.0, "missing": [155]}
{"name": "_proposal", "start": 163, "end": 188, "covered": 11, "lines": 11, "percent": 100.0, "missing": []}
{"name": "prepare_snapshot_export", "start": 191, "end": 272, "covered": 17, "lines": 19, "percent": 89.47368421052632, "missing": [202, 220]}
{"name": "_captured_transport", "start": 275, "end": 293, "covered": 7, "lines": 7, "percent": 100.0, "missing": []}
{"name": "prepare_snapshot_import", "start": 296, "end": 367, "covered": 21, "lines": 27, "percent": 77.77777777777777, "missing": [307, 334, 341, 342, 349, 352]}
{"name": "plan_snapshot_export", "start": 370, "end": 385, "covered": 3, "lines": 3, "percent": 100.0, "missing": []}
{"name": "plan_snapshot_import", "start": 388, "end": 403, "covered": 3, "lines": 3, "percent": 100.0, "missing": []}
{"name": "export_snapshot", "start": 406, "end": 420, "covered": 2, "lines": 2, "percent": 100.0, "missing": []}
{"name": "import_snapshot", "start": 423, "end": 437, "covered": 2, "lines": 2, "percent": 100.0, "missing": []}
```
