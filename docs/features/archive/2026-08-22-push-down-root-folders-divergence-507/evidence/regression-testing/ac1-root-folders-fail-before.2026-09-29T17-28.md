# AC1 Root Folders Fail-Before (P1-T4) [expect-fail]

Timestamp: 2026-09-29T17-28
Command: poetry run pytest "tests/scripts/dev_tools/test_push_down_claude_customizations.py::test_module_exposes_claude_root_folders_and_artifact_directory" -q
EXIT_CODE: 1
ExpectedExitCode: 1

Output Summary:
- Exit code 1; `1 failed in 0.09s`.
- Assertion line (left side is the pre-fix Python declaration):
  `E       AssertionError: assert (WindowsPath('.claude'),) == (WindowsPath(...ath('config'))`
  `E         Right contains one more item: WindowsPath('config')`
- Failure location: tests\scripts\dev_tools\test_push_down_claude_customizations.py:80
- State at run time: P1-T1 assertion updated; `scripts/dev_tools/push_down_claude_customizations.py` line 101 still declares `(Path(".claude"),)`.
