# Pin Survey 2: `no checks reported` Pins (P0-T7, remediation cycle 2)

Timestamp: 2026-10-12T17-58

Command: git grep -n -F -e "no checks reported" -- tests/scripts/dev_tools

EXIT_CODE: 0

Output Summary: exactly four lines (verbatim):

```
tests/scripts/dev_tools/test_ci_gate_all_checks_contracts.py:5:``no checks reported`` error is never green for any pull request, the parallel
tests/scripts/dev_tools/test_ci_gate_all_checks_contracts.py:55:    "fails with a `no checks reported` error, that error is never treated as"
tests/scripts/dev_tools/test_ci_gate_all_checks_contracts.py:84:    "fails with a `no checks reported` error, that error is never treated as"
tests/scripts/dev_tools/test_ci_gate_epic_child_contracts.py:62:    "`no checks reported`",
```

- Line 5 is the module docstring.
- Line 55 is in `S9_NO_CHECKS_FRAGMENTS` and line 62 (epic-child suite) is in `S9_EPIC_CHILD_FRAGMENTS`; both apply to the orchestrate S9 section (`## Step S9 — CI Green Gate`).
- Line 84 is in `CODEX_GATE_FRAGMENTS` and applies to the Codex gate section (`## CI Green Gate`).
- None applies to the parallel-orchestrate Merge-on-Green section; `MERGE_ON_GREEN_FRAGMENTS` (lines 59-68) does not contain the string.
