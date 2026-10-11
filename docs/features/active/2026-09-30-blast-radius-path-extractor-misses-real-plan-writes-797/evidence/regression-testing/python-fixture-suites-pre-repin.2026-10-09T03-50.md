# Python Fixture Suites After the Classifier Change, Before Re-Pin (P4-T1)

Timestamp: 2026-10-09T03-50
Command: poetry run pytest tests/scripts/dev_tools/test_blast_radius_historical_runs.py tests/scripts/dev_tools/test_blast_radius_verification_integrity.py tests/scripts/dev_tools/test_blast_radius_parity.py -q
EXIT_CODE: 1
Output Summary: `1 failed, 108 passed in 6.10s`. The single failing node is in the permitted set (test_after_edges_match_pins). No verification-integrity test failed, and both new parity cases for derivation-file-shaped-tokens passed.

## Failing node IDs with assertion messages

```text
FAILED tests/scripts/dev_tools/test_blast_radius_historical_runs.py::test_after_edges_match_pins[backlog-2026-09-26]
  AssertionError: backlog-2026-09-26
  At index 1 diff: {'a': 588, 'b': 622, 'reason': 'path_overlap', 'hard': False, 'cost': 160, 'benefit': 4} != {'a': 588, 'b': 622, 'reason': 'path_overlap', 'hard': False, 'cost': 152, 'benefit': 4}
```
