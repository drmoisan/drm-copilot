# builder-def-search

Timestamp: 2026-10-16T00-41
Command: grep -rn -F -e "def build_valid_epic_state" -e "def build_read_text_stub" tests --include=*.py
EXIT_CODE: 0
Output Summary:
```
tests/scripts/dev_tools/validate_orchestration_artifacts_test_support.py:12:def build_valid_epic_state() -> dict[str, object]:
tests/scripts/dev_tools/validate_orchestration_artifacts_test_support.py:54:def build_read_text_stub(text: str) -> Callable[[Path], str]:
```
Exactly two lines; both name the support module; no line names a test_*.py file.
