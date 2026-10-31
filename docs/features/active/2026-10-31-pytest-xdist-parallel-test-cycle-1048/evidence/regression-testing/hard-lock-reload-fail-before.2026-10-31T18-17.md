# Fail-before: importlib.reload leak in test_resolve_hard_lock_prompt.py (#1048, P2-T1)

Timestamp: 2026-10-31T18-17
Command: poetry run pytest "tests/scripts/dev_tools/test_resolve_hard_lock_prompt.py::test_clipboard_tests_leave_module_bindings_intact" -q -p no:cacheprovider
EXIT_CODE: 1
ExpectedExitCode: 1
Output Summary:
- 1 failed in 0.20 s.
- Failure: `AssertionError: resolve_prompt was rebound` at `assert module.resolve_prompt is resolve_prompt`; the module object in `sys.modules["scripts.dev_tools.resolve_hard_lock_prompt"]` binds a new `resolve_prompt` function object after the three clipboard tests ran, because each of them calls `importlib.reload(resolve_hard_lock_prompt)` while `pyperclip` is patched.
- The failure names the identity assertion, which is the behavior gap the test targets (a later test in the same process sees a reloaded module, not the module it imported). It is not a structural or collection error.
