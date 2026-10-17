# Remediation Cycle 1 Byte-Identical Strings, Validator Pair (P4-T1)

Timestamp: 2026-10-16T04-07
Command: poetry run python -c "import tests.scripts.dev_tools.test_validate_epic_planner_state_feature_indices as m; print(*m.ASSERTED_MESSAGES, sep=chr(10))" > SCRATCH/rc1/py-index-messages.txt; tr -d '\r' < SCRATCH/rc1/py-index-messages.txt > SCRATCH/rc1/py-index-messages.lf.txt; grep -c -e '.' SCRATCH/rc1/py-index-messages.lf.txt; grep -o -F -f SCRATCH/rc1/py-index-messages.lf.txt extensions/drm-copilot/test/lib/validate/epic-planner-state-feature-indices.test.ts > SCRATCH/rc1/ts-index-matches.txt; sort -u SCRATCH/rc1/ts-index-matches.txt > SCRATCH/rc1/ts-index-unique.txt; sort -u SCRATCH/rc1/py-index-messages.lf.txt > SCRATCH/rc1/py-index-sorted.txt; diff SCRATCH/rc1/py-index-sorted.txt SCRATCH/rc1/ts-index-unique.txt; grep -c -F -e 'toContain("' -e 'toEqual(["' extensions/drm-copilot/test/lib/validate/epic-planner-state-feature-indices.test.ts; grep -c -F -e 'assert "' -e '== ["' -e '" in errors' tests/scripts/dev_tools/test_validate_epic_planner_state_feature_indices.py
EXIT_CODE: 0
Output Summary:
- grep -c '.' on the Python message list: 11
- diff of sorted Python values against sorted unique TypeScript matches: no output, exit 0
- Inline-literal assertion fragments in the TypeScript file: 0 (exit 1 by design)
- Inline-literal assertion fragments in the Python file: 0 (exit 1 by design)
- Python values are read from the imported module, so the three two-line Python constants are compared by their concatenated runtime value.

| Constant | Python value (runtime) | TypeScript value |
|---|---|---|
| REPOSITORY_CONTEXT_ERROR | Execution-ready planner validation requires repository context. | Execution-ready planner validation requires repository context. |
| NON_OBJECT_ERROR | Epic planner checkpoint features[0] must be an object. | Epic planner checkpoint features[0] must be an object. |
| SHIFTED_PREPARATION_ERROR | Epic planner checkpoint features[2].preparation_status must be 'prepared'. | Epic planner checkpoint features[2].preparation_status must be 'prepared'. |
| UNSHIFTED_PREPARATION_ERROR | Epic planner checkpoint features[1].preparation_status must be 'prepared'. | Epic planner checkpoint features[1].preparation_status must be 'prepared'. |
| SHIFTED_MODEL_RECEIPT_ERROR | Epic planner checkpoint features[2].model_routing_receipt must be an object. | Epic planner checkpoint features[2].model_routing_receipt must be an object. |
| SHIFTED_TOPOLOGY_RECEIPT_ERROR | Epic planner checkpoint features[2].topology_receipt must be an object. | Epic planner checkpoint features[2].topology_receipt must be an object. |
| DUPLICATE_FOLDER_ERROR | Epic planner checkpoint features[2].feature_folder must be unique: 'docs/features/active/feature-101'. | Epic planner checkpoint features[2].feature_folder must be unique: 'docs/features/active/feature-101'. |
| DUPLICATE_ISSUE_ERROR | Epic planner checkpoint features[2].issue_num must be unique: 101. | Epic planner checkpoint features[2].issue_num must be unique: 101. |
| UNRESOLVED_DEPENDENCY_ERROR | Epic planner checkpoint features[3].depends_on contains unresolved reference: 999. | Epic planner checkpoint features[3].depends_on contains unresolved reference: 999. |
| SHIFTED_WAVE_ERROR | Epic planner checkpoint features[3].wave must be 0 from the dependency graph, found 1. | Epic planner checkpoint features[3].wave must be 0 from the dependency graph, found 1. |
| SHIFTED_LAUNCH_BINDING_ERROR | Epic planner checkpoint features[2] launch binding.branch_name must be a non-empty unique string. | Epic planner checkpoint features[2] launch binding.branch_name must be a non-empty unique string. |
