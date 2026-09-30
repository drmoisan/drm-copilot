---
Timestamp: 2026-09-30T14-23
Command: grep -rn -F --include=*.py "test_every_class_two_and_three_key_is_consumed_by_its_registered_assertion" tests/
EXIT_CODE: 0
Output Summary: Exactly one match at line 358 in test_blast_radius_config_parity.py
---

# Regression Test — New Name Single Definition

Verifies that the new function name exists in the test suite at exactly one location.

## Observed Output

```
tests/scripts/dev_tools/test_blast_radius_config_parity.py:358:def test_every_class_two_and_three_key_is_consumed_by_its_registered_assertion() -> (
```

**Result:** The new function name `test_every_class_two_and_three_key_is_consumed_by_its_registered_assertion` appears exactly once, at line 358 of the target test file. This confirms the rename was successful and unique.
