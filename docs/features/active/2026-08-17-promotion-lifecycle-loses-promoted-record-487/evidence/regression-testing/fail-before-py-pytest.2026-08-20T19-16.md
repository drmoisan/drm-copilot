# Fail-Before — Python (Pytest) [P1-T11]

Timestamp: 2026-08-20T19-16

Command: `poetry run pytest tests/scripts/dev_tools/test_new_active_feature_folder.py tests/scripts/dev_tools/test_new_active_feature_folder_part4.py --no-cov`

Working directory: `C:/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-a2b9a9c0d25db8e3b`

EXIT_CODE: 1 (expected non-zero — this is the fail-before capture)

The exit code was captured directly from the command process with no pipe.

## Result Header

```
======================== 2 failed, 23 passed in 0.20s =========================
```

## Output Summary

Two tests fail before the fix — exactly the two whose defect-codifying assertions were inverted.

### P1-T8 — `tests/scripts/dev_tools/test_new_active_feature_folder.py`

Test (renamed from `test_create_feature_folder_moves_potential_and_updates_files`):
`test_create_feature_folder_retains_promoted_potential_and_updates_files`

Failing assertion:

```
>       assert potential_path in fs.files
E       AssertionError: assert WindowsPath('/workspace/docs/features/potential/promoted/2025-12-23-json-quality.md') in {WindowsPath('/workspace/docs/features/active/2025-12-23-json-quality-63/issue.md'): ...}
```

The source is seeded under `docs/features/potential/promoted/`, and `create_active_folder` removed it. The keys shown in the failure include the active-folder `issue.md` but not the promoted source, which is the defect.

### P1-T9 — `tests/scripts/dev_tools/test_new_active_feature_folder_part4.py`

Test: `test_create_active_folder_auto_resolve_feature_name_from_promoted_active_file`

Failing assertion:

```
>       assert active_file in fs.files
E       AssertionError: assert WindowsPath('/workspace/docs/features/potential/promoted/2026-02-22-testing-missing-mock-injections.md') in {WindowsPath('/workspace/docs/features/active/2026-02-22-testing-missing-mock-injections-42/issue.md'): ...}
```

The auto-resolved promoted source was removed by `create_active_folder`.

The remaining 23 tests in the two files pass unchanged. Both failures are reproduced against the unmodified Python production code, confirming the Python cluster carries the same defect as the TypeScript cluster. P4-T8 re-runs the full `_partN` set after the Phase 4 fix and requires exit code 0.
