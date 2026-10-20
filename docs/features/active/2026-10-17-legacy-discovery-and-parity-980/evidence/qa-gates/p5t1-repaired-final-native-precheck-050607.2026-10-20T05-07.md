# P5-T1 final native-precheck

Timestamp: 2026-10-20T05-07
Command: `WORKSPACE\.venv\Scripts\python.exe -u SCRATCH\issue-980-p5t1-final-native.py SCRATCH\issue-980-p5t1-repaired-final-050607-native-result.json`
EXIT_CODE: 0
Output Summary: Stage 5; elapsed 36.087 seconds; completed nodes 0; timeout=False.

```text
PASS actual loader retains profile, scope, inventory, ledger and checksummed evidence
PASS materialized complete no-scope graph is structurally valid
PASS confirmed no-scope reports justified discovery completion
PASS empty denominators retain null ratios and explicit zero runtime obligations
PASS producer and authoritative public projection agree exactly
PASS JSON and Markdown render the same detached fields
PASS identical captured input renders deterministically
PASS generation and validation preserve the immutable capture
PASS previous JSON and Markdown outputs do not alter semantic identity or counts
PASS changed authored input invalidates the retained previous report
PASS authored success counts cannot replace recomputation
PASS configured uninventoried input retains actionable failure and unavailable population
PASS malformed scope retains original structural findings and unavailable counts
PASS all read-only operations preserve fixture source, artifacts and Git bytes
{"passed": 14, "elapsed_seconds": 35.0116312999744, "operation_seconds": {"setup_capture": 2.0998184999916703, "setup_report_for_previous_view": 1.854989099985687, "capture_complete_graph": 2.6687425000127405, "structural_validation": 1.8580201999866404, "build_coverage_report": 1.8512264000019059, "public_report_projection": 1.8739479999931064, "repeated_report": 1.864473800000269, "capture_previous_view": 2.591378499986604, "report_with_previous_view": 1.8683327999897301, "capture_changed_authoring": 2.7049608000088483, "validate_stale_report": 1.8990000000048894, "capture_forged_report": 2.574926499975845, "validate_forged_report": 1.8438977000187151, "capture_uninventoried": 0.9551307000219822, "report_uninventoried": 0.378653400024632, "capture_invalid_scope": 2.15506920000189, "report_invalid_scope": 1.5062527999980375}}

```
