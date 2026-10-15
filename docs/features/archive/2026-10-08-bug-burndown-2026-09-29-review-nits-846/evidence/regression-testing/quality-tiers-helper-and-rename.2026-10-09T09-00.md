# Regression: quality-tiers helper extraction and rename ([P2-T5])

Timestamp: 2026-10-09T21-12
Command: grep -n -e "^def _codes" -e "^def _manifest" tests/scripts/dev_tools/test_quality_tiers_contract.py tests/scripts/dev_tools/test_quality_tiers_contract_classification.py tests/scripts/dev_tools/quality_tiers_contract_test_support.py
ExpectedExitCode: 1
EXIT_CODE: 1
Output Summary: no output. No private `_codes` or `_manifest` definition remains in any of the three modules (AC-3 helper half).

## Block 2

Command: grep -n -e "^def qt_codes" -e "^def make_manifest" tests/scripts/dev_tools/quality_tiers_contract_test_support.py
EXIT_CODE: 0
Output Summary: two lines printed.

```
12:def qt_codes(errors: list[QualityTierError]) -> list[str]:
17:def make_manifest(*entries: tuple[str, str]) -> QualityTierManifest:
```

## Block 3

Command: grep -rn --include="*.py" -e "test_find_classification_errors_empty_project_set_reports_qt007_for_every_entry" tests/
EXIT_CODE: 1
Output Summary: no output; the former test name is absent from every `.py` file under tests/.

## Block 4

Command: grep -rn --include="*.py" -F -e "def test_find_classification_errors_empty_projects_reports_qt007() -> None:" tests/
EXIT_CODE: 0
Output Summary: exactly one line printed.

```
tests/scripts/dev_tools/test_quality_tiers_contract_classification.py:138:def test_find_classification_errors_empty_projects_reports_qt007() -> None:
```

## Block 5

Command: poetry run black --check tests/scripts/dev_tools/test_quality_tiers_contract_classification.py
EXIT_CODE: 0
Output Summary: `1 file would be left unchanged.` No `would reformat` line.

## Block 6

Command: poetry run ruff check tests/scripts/dev_tools/test_quality_tiers_contract_classification.py
EXIT_CODE: 0
Output Summary: `All checks passed!`

Acceptance: every block shows the stated result (AC-1 and AC-3 verification). PASS.
