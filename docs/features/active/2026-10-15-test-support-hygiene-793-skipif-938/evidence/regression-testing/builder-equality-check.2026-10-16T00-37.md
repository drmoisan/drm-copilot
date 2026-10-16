# builder-equality-check

Timestamp: 2026-10-16T00-37
Command: poetry run python -c "import tests.scripts.dev_tools.test_validate_epic_orchestrator_state as old_epic, tests.scripts.dev_tools.test_validate_orchestration_artifacts as old_stub, tests.scripts.dev_tools.validate_orchestration_artifacts_test_support as new; print(old_epic.build_valid_epic_state() == new.build_valid_epic_state(), old_epic.build_valid_epic_state.__doc__ == new.build_valid_epic_state.__doc__, old_stub.build_read_text_stub('x')(None) == new.build_read_text_stub('x')(None), old_stub.build_read_text_stub.__doc__ == new.build_read_text_stub.__doc__)"
EXIT_CODE: 0
Output Summary:
```
True True True True
```
Run before P1-T4 and P1-T5 removed the originals.
