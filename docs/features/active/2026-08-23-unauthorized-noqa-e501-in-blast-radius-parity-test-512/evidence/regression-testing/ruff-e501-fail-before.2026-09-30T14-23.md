---
Timestamp: 2026-09-30T14-23
Command: poetry run ruff check tests/scripts/dev_tools/test_blast_radius_config_parity.py
EXIT_CODE: 1
ExpectedExitCode: 1
Output Summary:
  - E501 Line too long (91 > 88)
  - Location: tests\scripts\dev_tools\test_blast_radius_config_parity.py:358:89
  - Found 1 error
---

# Fail-Before Evidence — Ruff E501 Error

Captures the E501 error that occurs when the suppression comment is removed from line 358, before the function is renamed.

## Observed Output

```
E501 Line too long (91 > 88)
   --> tests\scripts\dev_tools\test_blast_radius_config_parity.py:358:89
    |
358 | def test_every_class_two_and_class_three_key_is_consumed_by_its_registered_assertion() -> (
    |                                                                                         ^^^
359 |     None
360 | ):
    |

Found 1 error.
```

**Exit Code: 1 (expected failure)**

The line with the old function name is exactly 91 characters, exceeding the 88-character limit. Ruff correctly reports this E501 error when the suppression comment is removed. The plan's subsequent Phase 2 will rename the function to shorten it below the limit, eliminating the need for any suppression.
