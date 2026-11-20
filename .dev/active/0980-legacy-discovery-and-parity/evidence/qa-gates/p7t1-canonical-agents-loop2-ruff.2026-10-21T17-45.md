# P7-T1 canonical agents ruff

Timestamp: 2026-10-21T17-45

Command: `WORKSPACE\.venv\Scripts\python.exe -m ruff check tests/scripts/dev_tools/test_discovery_agent_contracts.py`

EXIT_CODE: 1

Output Summary: FAIL or changed bytes; 0.209 seconds.

```text
TC006 [*] Add quotes to type expression in `typing.cast()`
   --> tests\scripts\dev_tools\test_discovery_agent_contracts.py:116:17
    |
114 |     decoded: object = yaml.safe_load(metadata)
115 |     assert isinstance(decoded, dict)
116 |     return cast(dict[str, object], decoded), body
    |                 ^^^^^^^^^^^^^^^^^
    |
help: Add quotes

E501 Line too long (89 > 88)
   --> tests\scripts\dev_tools\test_discovery_agent_contracts.py:437:89
    |
436 | def test_reviewer_can_finalize_valid_failure_without_completion_authority() -> None:
437 |     """With no inputs, separate valid output from success; return None or AssertionError.
    |                                                                                         ^
438 |
439 |     Reads one fixture only; no facts or completion prerequisite can be changed.
    |

Found 2 errors.
[*] 1 fixable with the `--fix` option.

```
