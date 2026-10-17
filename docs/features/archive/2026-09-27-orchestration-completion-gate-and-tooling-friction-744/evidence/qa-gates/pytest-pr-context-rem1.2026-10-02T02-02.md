Timestamp: 2026-10-02T02-47
Command: poetry run pytest tests/scripts/dev_tools/pr_context -q -p no:cacheprovider
EXIT_CODE: 0
Output Summary: 165 passed in 0.21s; equals PYTEST_BEFORE (165). No failed or error count.

# PR-Context Parser Tests (Remediation Cycle 1, task P4-T1)

Loop iteration: 1

Result line (verbatim):

  165 passed in 0.21s

## Recorded values

- PYTEST_BEFORE: 165 (P0-T8)
- Passed count now: 165

## Acceptance check

- exit 0; result line contains `passed`, contains neither `failed` nor `error`; passed count equals PYTEST_BEFORE.
- The collection includes tests/scripts/dev_tools/pr_context/test_verification_evidence_first_occurrence.py, which pins the first-occurrence rule the correction relies on.
