# Handoff Summary

Timestamp: 2026-02-22T14-53

## Implemented Files
- `.vscode/tasks.json`
- `scripts/dev_tools/new_active_feature_folder_flow.py`
- `scripts/dev_tools/new_active_feature_folder.py`
- `tests/scripts/dev_tools/test_new_active_feature_folder.py`
- `docs/features/active/2026-02-22-create-active-folder-bug-43/spec.md`
- `docs/features/active/2026-02-22-create-active-folder-bug-43/issue.md`

## Tests Added
- `tests/scripts/dev_tools/test_new_active_feature_folder.py::test_create_active_folder_auto_resolve_feature_name_from_promoted_active_file`
- `tests/scripts/dev_tools/test_new_active_feature_folder.py::test_create_active_folder_auto_resolve_rejects_non_promoted_or_non_markdown_active_file`
- `tests/scripts/dev_tools/test_new_active_feature_folder.py::test_create_active_folder_full_mode_persists_full_marker_in_issue_md`
- `tests/scripts/dev_tools/test_new_active_feature_folder.py::test_create_active_folder_minor_audit_behavior_unchanged_with_auto_resolve_option_absent`

## Final QA Commands
- `poetry run python -m scripts.dev_tools.format_json`
- `poetry run python -m scripts.dev_tools.validate_json`
- `poetry run black .`
- `poetry run ruff check`
- `poetry run pyright`
- `poetry run pytest --cov=src/lexile_corpus_tuner --cov=scripts/dev_tools --cov-report=term-missing`

## Known Follow-ups
- Remove local temporary `jq` shim setup from shell profile/session once host-level `jq` is available.
- Optional: add a short operator note in `docs/engineering/Feature Playbook.md` for when to use `Dev: 3 Auto Create Folder`.
