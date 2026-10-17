# Remediation Cycle 3 CR-11 and CR-12 Python Fail-Before (P2-T7, expect-fail)

Timestamp: 2026-10-16T08-31
Command: poetry run pytest --no-cov tests/scripts/dev_tools/test_epic_planner_readiness_relative_paths.py tests/scripts/dev_tools/test_epic_planner_readiness_edges.py -vv > SCRATCH/rc3/py-cr11-cr12-fail-before.txt; grep -e ' passed' -e ' failed' -e 'FAILED' SCRATCH/rc3/py-cr11-cr12-fail-before.txt; grep -c -e 'ImportError' -e 'NameError' -e 'TypeError' -e 'ERROR collecting' SCRATCH/rc3/py-cr11-cr12-fail-before.txt
EXIT_CODE: 1
ExpectedExitCode: 1
Output Summary:
- Run on pre-fix production Python (scripts/dev_tools/epic_planner_git_integrity.py and scripts/dev_tools/epic_planner_readiness.py unchanged at this point).
- ======================== 4 failed, 20 passed in 0.21s =========================
- FAILED test_epic_planner_readiness_relative_paths.py::test_unsafe_feature_folder_is_rejected[drive-letter] - assert 'Epic planner checkpoint features[0].feature_folder must stay within the workspace root.' in [...] (the list instead carries 'Execution readiness requires feature folder: C:/docs/features/active/feature-101', so the drive-qualified value was accepted as a relative path)
- FAILED test_epic_planner_readiness_relative_paths.py::test_unsafe_feature_folder_is_rejected[drive-relative] - assert '...feature_folder must stay within the workspace root.' in [...] (list carries 'Execution readiness requires feature folder: c:docs/features/active/feature-101')
- FAILED test_epic_planner_readiness_edges.py::test_plan_path_must_be_strictly_inside_feature_folder[equal-to-folder] - assert 'Epic planner checkpoint features[0].plan_path must be inside its feature_folder.' in [...] (list carries only the atomic-plan read error for docs/features/active/feature-101)
- FAILED test_epic_planner_readiness_edges.py::test_plan_path_must_be_strictly_inside_feature_folder[dot-prefixed-folder] - assert '...plan_path must be inside its feature_folder.' in [...]
- Each failure is an AssertionError on the membership assertion; collection, import, name, and type error count: 0 (grep exit 1 by design).
- Passing on pre-fix code: every CR-15 test (test_plan_path_inside_feature_folder_is_accepted, test_non_object_feature_entry_keeps_its_index, test_unreadable_required_document_is_reported, test_preflight_evidence_outside_feature_folder_is_rejected, test_unreadable_preflight_evidence_is_skipped, test_kickoff_slug_mismatch_is_reported), [sibling-prefix], the other ten relative-paths cases, and both parity tests (test_asserted_messages_match_typescript_twin in each file).
