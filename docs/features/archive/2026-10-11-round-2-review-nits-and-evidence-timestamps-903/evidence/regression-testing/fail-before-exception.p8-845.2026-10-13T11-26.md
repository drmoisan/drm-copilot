# Fail-Before Exception: #845 CR-1, CR-2, CR-3 (P4-T16)

Timestamp: 2026-10-13T11-26

WhyFailingRunImpossible: CR-1 moves the patterns and finder helpers from `tests/scripts/dev_tools/test_workflow_npm_token_guard.py` into `tests/scripts/dev_tools/npm_token_guard_test_support.py` without behavior change (lines 36-179 copied unchanged), and the CR-2/CR-3 rows characterize existing finder behavior, so no assertion can fail before the change.

## Alternative proof

- P4-T14 (`evidence/regression-testing/p8-845-collect-compare.2026-10-13T11-26.md`): every pre-split node id is present after the split; the only additions are the four residual ids.
- P4-T15 (`evidence/regression-testing/p8-845-after.2026-10-13T11-26.md`): 60 passed, 0 failed, equal to the collected count.
- The `+=` gap (`NPM_TOKEN+=x` is not reported) remains Operator Follow-up 1; the `residual-bash-append-not-reported` row pins it.
