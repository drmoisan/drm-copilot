# P3-T4 independent nested transition correction

Timestamp: 2026-10-18T15-57
Command: poetry run python SCRATCH/issue-980-p3t4-nested-probes.py
EXIT_CODE: 0
Output Summary: 4/4 assertions passed with both production hashes unchanged. This proves the bounded behavior set, not complete task gates or feature acceptance.

Exact cases and hashes: [probe result](p3t4-executor-nested-final.2026-10-18T15-57.json).

The current proof retains the valid inferred-phase control, rejects nested verified creation, preserves a supplied unresolved link and supplies an omitted unresolved link. In both unknown cases the generated question covers state_transitions. This closes the two failures recorded in p3t4-executor-nested-review.2026-10-18T15-43.md.

Both scripts used accepted memory fixtures, with no native workspace writes or temporary test files. The earlier fixture failure and unfrozen initial probe remain historical. Final worker gates, staged-byte audit and per-unit coverage are still required before P3-T4 checkoff.

## Captured output

```text
{"name": "inferred-positive", "passed": true, "expected_valid": true, "actual_valid": true, "findings": [], "question_dimensions": ["alternate_clients", "cancellation", "environment_constraints", "failure", "inputs", "mobile", "observable_outputs", "offline", "online", "ordering", "preconditions", "security_permissions", "side_effects", "timing", "trigger"]}
{"name": "verified-nested-rejected", "passed": true, "expected_valid": false, "actual_valid": false, "findings": [], "question_dimensions": null}
{"name": "unknown-nested-linked", "passed": true, "expected_valid": true, "actual_valid": true, "findings": [], "question_dimensions": ["alternate_clients", "cancellation", "environment_constraints", "failure", "inputs", "mobile", "observable_outputs", "offline", "online", "ordering", "preconditions", "security_permissions", "side_effects", "state_transitions", "timing", "trigger"]}
{"name": "unknown-nested-empty-links-generated", "passed": true, "expected_valid": true, "actual_valid": true, "findings": [], "question_dimensions": ["alternate_clients", "cancellation", "environment_constraints", "failure", "inputs", "mobile", "observable_outputs", "offline", "online", "ordering", "preconditions", "security_permissions", "side_effects", "state_transitions", "timing", "trigger"]}
{"task": "P3-T4", "source_hashes_before": {"packages/discovery-runtime/src/drm_copilot_discovery/draft_contracts.py": "a317f11b60ccffcb05fe040a28162388dd40d87de06506d4615455260755a00d", "packages/discovery-runtime/src/drm_copilot_discovery/draft_scenarios.py": "0e43b453774fcd10f669dc643ebcf33a11712ad9778a92343d85829d7ae0c1a1"}, "source_hashes_after": {"packages/discovery-runtime/src/drm_copilot_discovery/draft_contracts.py": "a317f11b60ccffcb05fe040a28162388dd40d87de06506d4615455260755a00d", "packages/discovery-runtime/src/drm_copilot_discovery/draft_scenarios.py": "0e43b453774fcd10f669dc643ebcf33a11712ad9778a92343d85829d7ae0c1a1"}, "source_stable": true, "checks": [{"name": "inferred-positive", "passed": true, "expected_valid": true, "actual_valid": true, "findings": [], "question_dimensions": ["alternate_clients", "cancellation", "environment_constraints", "failure", "inputs", "mobile", "observable_outputs", "offline", "online", "ordering", "preconditions", "security_permissions", "side_effects", "timing", "trigger"]}, {"name": "verified-nested-rejected", "passed": true, "expected_valid": false, "actual_valid": false, "findings": [], "question_dimensions": null}, {"name": "unknown-nested-linked", "passed": true, "expected_valid": true, "actual_valid": true, "findings": [], "question_dimensions": ["alternate_clients", "cancellation", "environment_constraints", "failure", "inputs", "mobile", "observable_outputs", "offline", "online", "ordering", "preconditions", "security_permissions", "side_effects", "state_transitions", "timing", "trigger"]}, {"name": "unknown-nested-empty-links-generated", "passed": true, "expected_valid": true, "actual_valid": true, "findings": [], "question_dimensions": ["alternate_clients", "cancellation", "environment_constraints", "failure", "inputs", "mobile", "observable_outputs", "offline", "online", "ordering", "preconditions", "security_permissions", "side_effects", "state_transitions", "timing", "trigger"]}], "passed": 4, "failed": 0}
```
