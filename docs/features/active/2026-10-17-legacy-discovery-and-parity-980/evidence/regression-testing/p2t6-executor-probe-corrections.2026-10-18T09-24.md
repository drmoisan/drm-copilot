# P2-T6 corrected-boundary independent probe

Timestamp: 2026-10-18T09-24

Command: `poetry run python SCRATCH/issue-980-review-p2t6.py`

EXIT_CODE: 0

Output Summary: 46 cases executed. Both consolidated production defects now pass their regression cases. Forty-four exact probe expectations passed; two existing negative cases also produced the newly added, correct COVERAGE_INPUTS diagnostic for deliberately mismatched inventory size/hash. Their expected-code sets were updated in the final assertion-based probe. No new production defect was found.

The diagnostic collector does not assert aggregate success; this command does not accept P2-T6. Source hashes remained stable: coverage_rules.py 843aa872c69f10751b833f0c2d5eb619a9c949225de53b3609821140d0d0fc46 and coverage_scope_rules.py 5a45b4e80f23677e6c4cf55577bc46aba9db930ff95aab3f4bdb18f1c684067d.

Final task verification remains dependent on the specialist's clean ordered gates, frozen path manifest, coverage evidence and independent final-source assertion run. The source helper now retains conservative feature-only input selection and separates imported source origin/pin from current target input accounting.
