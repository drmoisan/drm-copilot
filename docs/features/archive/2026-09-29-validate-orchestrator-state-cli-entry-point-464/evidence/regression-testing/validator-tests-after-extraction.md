# Validator Tests After Extraction (Issue #464)

Timestamp: 2026-09-30T08-48
Command: poetry run pytest tests/scripts/dev_tools -k "validate_orchestrator_state and not cli" -q -p no:cacheprovider --no-cov
EXIT_CODE: 0
Output Summary: `189 passed, 5447 deselected`; 0 failed. The passed count (189) equals the baseline N = 189 recorded in `evidence/baseline/validator-tests-before.md`. The deselected count rose from 5426 to 5447 because the 21 new CLI tests are collected but excluded by `not cli`.
Additional checks (P3-T2 and P3-T5):
- `git grep -c -F "def _validate_remediation" -- scripts/dev_tools/validate_orchestrator_state.py` printed nothing and exited 1 (it printed a count of 2 before the edit).
- `git diff --name-only 5b09b53899ac9dad870f855cbcc359098266e213 -- tests/scripts/dev_tools/test_validate_orchestrator_state_remediation_loop.py` printed nothing, and `git status --porcelain` on the same path printed nothing (the remediation-loop test file was not edited). The ref operand is the merge-base SHA recorded in `evidence/baseline/epic-ref-position-before.md` because the recorded left count was non-zero.
