Timestamp: 2026-09-30T12-02
Command: poetry run pytest --cov=src --cov=scripts.dev_tools --cov-branch --cov-report=term-missing
EXIT_CODE: 0
Output Summary:
- Passed count: 5697. Failed count: 0. Skipped count: 6. Run time 105.82s.
- FAILED node IDs: none. No FAILED node ID contains test_blast_radius_config_parity.
- TOTAL row copied verbatim: `TOTAL   16937   1126   6106   584   91%`
  - Stmts 16937, Miss 1126, Branch 6106, BrPart 584, Cover 91%.
- The LCOV reporter printed: `Coverage LCOV written to file artifacts/python/lcov.info`.
- Execution note: the run was piped through `tail -60` to bound output, so the shell pipeline status was not captured. EXIT_CODE 0 is inferred from the pytest final line `5697 passed, 6 skipped` with no failures and no errors.
- Skips (6) are pre-existing: one for the #722 tolerance layer in test_blast_radius_regression_452.py and five manifest_m1_* parity cases in test_parallel_manifest_bash_parity.py.
