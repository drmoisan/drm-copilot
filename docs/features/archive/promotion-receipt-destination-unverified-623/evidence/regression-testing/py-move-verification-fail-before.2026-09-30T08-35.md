# Python Move-Verification Fail-Before (#623)

Timestamp: 2026-09-30T08-35
Command: git diff --quiet 6e6ccd62792e0838bee7459a2b468de83ad5d408 -- "scripts/dev_tools/potential_to_issue.py"; poetry run pytest -v "tests/scripts/dev_tools/test_potential_to_issue_move_verification.py"
EXIT_CODE: 1
ExpectedExitCode: 1
Output Summary: The Python module is unchanged against BASE_SHA (git diff --quiet exit 0). pytest exit 1 with final summary `1 failed, 1 passed in 0.11s`. FAILED node: tests/scripts/dev_tools/test_potential_to_issue_move_verification.py::test_promote_potential_returns_exit_1_when_destination_missing_after_move; assertion shows exit_code 0 where 1 was expected.

## git diff --quiet result

EXIT_CODE: 0 (production file unchanged)

## pytest output (verbatim excerpt; host paths removed)

```
collecting ... collected 2 items

tests/scripts/dev_tools/test_potential_to_issue_move_verification.py::test_promote_potential_returns_exit_1_when_destination_missing_after_move FAILED [ 50%]
tests/scripts/dev_tools/test_potential_to_issue_move_verification.py::test_promote_potential_returns_destination_when_move_succeeds PASSED [100%]

>       assert outcome.exit_code == 1
E       AssertionError: assert 0 == 1
E        +  where 0 = PromotionOutcome(exit_code=0, messages=['Selected mode: full-feature', 'Creating issue: Feature: Feature Title (label: feature)', 'Created: https://example.com/issues/123', 'Updated potential file with issue metadata: \\workspace\\docs\\features\\potential\\sample.md', 'Moved potential file to promoted folder: \\workspace\\docs\\features\\potential\\promoted\\sample.md'], destination=WindowsPath('/workspace/docs/features/potential/promoted/sample.md')).exit_code

tests\scripts\dev_tools\test_potential_to_issue_move_verification.py:262: AssertionError
=========================== short test summary info ===========================
FAILED tests/scripts/dev_tools/test_potential_to_issue_move_verification.py::test_promote_potential_returns_exit_1_when_destination_missing_after_move
========================= 1 failed, 1 passed in 0.11s =========================
```
