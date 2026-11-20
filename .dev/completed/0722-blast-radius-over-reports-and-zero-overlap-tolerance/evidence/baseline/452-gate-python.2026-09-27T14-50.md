# #452 Detection Gate, Python Driver (P0-T21)

Timestamp: 2026-09-27T14-50
Command: poetry run pytest -v <the ten node IDs of plan Appendix B block B1, listed below>
EXIT_CODE: 0
Output Summary: pytest exited 0; 10 passed in 0.09s. Ten PASSED lines, one per listed node ID. The fixtures were run unmodified. No sibling-added fixture exists (P0-T20), so none is deferred to P14-T3.

## Node IDs run (block B1)

```text
tests/scripts/dev_tools/test_blast_radius_parity.py::test_conflict_fixture_reproduces_the_expected_verdict[conflict-directory-vs-glob]
tests/scripts/dev_tools/test_blast_radius_parity.py::test_conflict_fixture_reproduces_the_expected_verdict[conflict-directory-vs-file]
tests/scripts/dev_tools/test_blast_radius_parity.py::test_conflict_fixture_reproduces_the_expected_verdict[conflict-sibling-prefix-disjoint]
tests/scripts/dev_tools/test_blast_radius_parity.py::test_conflict_fixture_reproduces_the_expected_reasons[conflict-directory-vs-glob]
tests/scripts/dev_tools/test_blast_radius_parity.py::test_conflict_fixture_reproduces_the_expected_reasons[conflict-directory-vs-file]
tests/scripts/dev_tools/test_blast_radius_parity.py::test_conflict_fixture_reproduces_the_expected_reasons[conflict-sibling-prefix-disjoint]
tests/scripts/dev_tools/test_blast_radius_parity.py::test_derivation_fixture_reproduces_the_expected_radius[derivation-root-surface-reached]
tests/scripts/dev_tools/test_blast_radius_parity.py::test_derivation_fixture_reproduces_the_expected_radius[derivation-root-surface-not-configured]
tests/scripts/dev_tools/test_blast_radius_parity.py::test_derivation_fixture_reproduces_the_expected_findings[derivation-root-surface-reached]
tests/scripts/dev_tools/test_blast_radius_parity.py::test_derivation_fixture_reproduces_the_expected_findings[derivation-root-surface-not-configured]
```

## Result lines (verbatim)

```text
collected 10 items
...test_conflict_fixture_reproduces_the_expected_verdict[conflict-directory-vs-glob] PASSED [ 10%]
...test_conflict_fixture_reproduces_the_expected_verdict[conflict-directory-vs-file] PASSED [ 20%]
...test_conflict_fixture_reproduces_the_expected_verdict[conflict-sibling-prefix-disjoint] PASSED [ 30%]
...test_conflict_fixture_reproduces_the_expected_reasons[conflict-directory-vs-glob] PASSED [ 40%]
...test_conflict_fixture_reproduces_the_expected_reasons[conflict-directory-vs-file] PASSED [ 50%]
...test_conflict_fixture_reproduces_the_expected_reasons[conflict-sibling-prefix-disjoint] PASSED [ 60%]
...test_derivation_fixture_reproduces_the_expected_radius[derivation-root-surface-reached] PASSED [ 70%]
...test_derivation_fixture_reproduces_the_expected_radius[derivation-root-surface-not-configured] PASSED [ 80%]
...test_derivation_fixture_reproduces_the_expected_findings[derivation-root-surface-reached] PASSED [ 90%]
...test_derivation_fixture_reproduces_the_expected_findings[derivation-root-surface-not-configured] PASSED [100%]
============================= 10 passed in 0.09s ==============================
```

The leading "tests/scripts/dev_tools/test_blast_radius_parity.py::" prefix is abbreviated as "..." in
the result lines above; the full node IDs are listed in the preceding block.
