# Python Authority Lane on the Parity Corpus (P1-T2, P1-T3)

Timestamp: 2026-10-08T22-36
Command: poetry run pytest -v tests/scripts/dev_tools/test_epic_wave_barrier_parity_corpus.py
EXIT_CODE: 0
Output Summary:
- `collected 30 items`; summary `30 passed in 0.09s`; no FAILED line.
- PASSED: test_corpus_is_non_empty_with_unique_case_names, test_corpus_executes_every_case, and test_corpus_case for all 28 case ids (issue-num-reference-confirmed-before-start through multiple-edges-reported-in-depends-on-order).

P1-T2: PYLANE defines exactly the three test functions named in Appendix C6: `test_corpus_is_non_empty_with_unique_case_names`, `test_corpus_executes_every_case`, `test_corpus_case` (parametrized over the 28 cases with the case names as ids).

D12: not triggered. Every planned expectation in Appendix D matched the authority output on the first run, so no `expected_barrier_errors` value was replaced and no corpus-derivation artifact was written.

Result: PASS.
