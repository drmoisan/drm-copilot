# Pass-after — renderer regressions closed in both runtimes

Timestamp: 2026-08-20T09-53

Command: poetry run pytest tests/scripts/dev_tools/test_collect_pr_context_expected_exit.py tests/scripts/dev_tools/test_collect_pr_context.py tests/scripts/dev_tools/test_collect_pr_context_part4.py
EXIT_CODE: 0

Command: (from `extensions/drm-copilot`) npm run test:unit -- test/lib/pr-context/collector-output.test.ts
EXIT_CODE: 0

Command: poetry run pytest tests/scripts/dev_tools/test_collect_pr_context.py tests/scripts/dev_tools/test_collect_pr_context_part4.py -k "canonical_evidence_paths_in_additional_context_files or verification_evidence_section_is_rendered_with_normalized_fields or reports_unparseable_evidence_without_claiming_completion"
EXIT_CODE: 0

Task: [P5-T7]

## Python renderer regressions

```
tests\scripts\dev_tools\test_collect_pr_context.py .....................  [ 82%]
tests\scripts\dev_tools\test_collect_pr_context_part4.py .....            [100%]

============================= 29 passed in 0.15s ==============================
```

29 passed, 0 failed. The set includes the 3 new cases in the new sibling module
`test_collect_pr_context_expected_exit.py` (which failed at [P1-T6]) plus every pre-existing test in
the two over-limit collector-level modules, neither of which received a changed line ([P5-T6]).

## The three named pre-existing collector-level tests

The three tests `spec.md` names under "Regression tests to add or update" as "unchanged and must stay
green" were run by node-id selection as an explicit check:

```
tests\scripts\dev_tools\test_collect_pr_context.py .                      [ 33%]
tests\scripts\dev_tools\test_collect_pr_context_part4.py ..               [100%]

====================== 3 passed, 23 deselected in 0.09s =======================
```

- `test_collector_includes_canonical_evidence_paths_in_additional_context_files`
- `test_collector_verification_evidence_section_is_rendered_with_normalized_fields`
- `test_collector_reports_unparseable_evidence_without_claiming_completion`

All three pass with no edit to their bodies, which is direct evidence that Invariant A holds for the
rendered section as those fixtures exercise it.

## TypeScript renderer regressions

```
Test Suites: 1 passed, 1 total
Tests:       16 passed, 16 total
```

16 passed, 0 failed — the 4 pre-existing `renderVerificationEvidenceSection` cases plus the 12 other
pre-existing tests in the file plus the 3 new expectation-row runs (one non-zero case and a
two-variant parametrized zero case). The [P1-T8] failure (`indexOf` returning `-1` for the
expectation line) is closed.

Output Summary: Both renderer legs pass with exit code 0 — 29 Python tests and 16 TypeScript tests,
0 failures. The three pre-existing collector-level Python tests named in `spec.md` pass unedited, and
the two over-limit Python test modules received zero changed lines. The Phase 1 renderer fail-before
runs (`py-renderer-fail-before` and `ts-renderer-fail-before`, both EXIT_CODE 1) are closed.
