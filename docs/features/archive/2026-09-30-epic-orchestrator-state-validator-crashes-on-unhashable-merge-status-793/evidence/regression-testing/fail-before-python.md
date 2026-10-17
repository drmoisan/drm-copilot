# P1-T3 Fail-before: Python merge-status tests (before any production edit)

Timestamp: 2026-10-09T20-14
Command: poetry run pytest tests/scripts/dev_tools/test_validate_epic_orchestrator_state_merge_status.py
EXIT_CODE: 1
ExpectedExitCode: 1
Output Summary: 10 failed, 11 passed in 0.44s. The ten failures are exactly the ten node IDs named in plan section 3.1, each raising TypeError: unhashable type ('list' or 'dict') at the membership test in scripts/dev_tools/validate_epic_orchestrator_state.py line 238 (enum site) or line 321 (completion site). The 11 passing cases are the int/bool enum and completion rows (4) plus the 7 preservation cases. The test-session header and the per-failure tracebacks are omitted here; the collected count was 21 items.

Passing before the fix (11): test_enum_site_reports_non_string_merge_status[int], [bool]; test_completion_site_reports_non_string_merge_status[int], [bool]; test_enum_site_accepts_every_valid_string_status; test_enum_site_reports_invalid_string_status_with_unchanged_text; test_enum_site_skips_none_and_missing_merge_status; test_completion_site_accepts_merged_and_worktree_removed; test_completion_site_reports_invalid_string_none_and_missing[string], [none], [missing].

Representative failure tail (TypeError at the enum site through the CLI path):

```
scripts\dev_tools\validate_epic_orchestrator_state.py:390: in validate_epic_orchestrator_state_text
    errors.extend(_validate_merge_status_enum(features))
>           if merge_status is not None and merge_status not in VALID_MERGE_STATUS:
E           TypeError: unhashable type: 'dict'
scripts\dev_tools\validate_epic_orchestrator_state.py:238: TypeError
```

Short test summary info:

```
FAILED tests/scripts/dev_tools/test_validate_epic_orchestrator_state_merge_status.py::test_enum_site_reports_non_string_merge_status[list]
FAILED tests/scripts/dev_tools/test_validate_epic_orchestrator_state_merge_status.py::test_enum_site_reports_non_string_merge_status[dict]
FAILED tests/scripts/dev_tools/test_validate_epic_orchestrator_state_merge_status.py::test_completion_site_reports_non_string_merge_status[list]
FAILED tests/scripts/dev_tools/test_validate_epic_orchestrator_state_merge_status.py::test_completion_site_reports_non_string_merge_status[dict]
FAILED tests/scripts/dev_tools/test_validate_epic_orchestrator_state_merge_status.py::test_entry_point_reports_invalid_merge_status_without_raising[list]
FAILED tests/scripts/dev_tools/test_validate_epic_orchestrator_state_merge_status.py::test_entry_point_reports_invalid_merge_status_without_raising[dict]
FAILED tests/scripts/dev_tools/test_validate_epic_orchestrator_state_merge_status.py::test_entry_point_require_complete_reports_completion_error_without_raising[list]
FAILED tests/scripts/dev_tools/test_validate_epic_orchestrator_state_merge_status.py::test_entry_point_require_complete_reports_completion_error_without_raising[dict]
FAILED tests/scripts/dev_tools/test_validate_epic_orchestrator_state_merge_status.py::test_cli_returns_exit_code_1_for_non_string_merge_status[list]
FAILED tests/scripts/dev_tools/test_validate_epic_orchestrator_state_merge_status.py::test_cli_returns_exit_code_1_for_non_string_merge_status[dict]
======================== 10 failed, 11 passed in 0.44s ========================
```
