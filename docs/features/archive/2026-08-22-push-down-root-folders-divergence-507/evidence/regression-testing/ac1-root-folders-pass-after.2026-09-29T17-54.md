# AC1 Root Folders Pass-After (P5-T7)

Timestamp: 2026-09-29T17-54
Command: poetry run pytest "tests/scripts/dev_tools/test_push_down_claude_customizations.py::test_module_exposes_claude_root_folders_and_artifact_directory" -q
EXIT_CODE: 0

Output Summary:
- Exit code 0; `1 passed in 0.07s`.
- `scripts/dev_tools/push_down_claude_customizations.py` now declares, on a single line: `ROOT_FOLDERS: tuple[Path, ...] = (Path(".claude"), Path("config"))`.
- Fail-before counterpart: evidence/regression-testing/ac1-root-folders-fail-before.2026-09-29T17-28.md (EXIT_CODE 1).
