# Gate — Python parser test module size and module-scoped coverage

Timestamp: 2026-08-20T09-53

Task: [P3-T11]

Command: pwsh -NoProfile -Command "(Get-Content tests/scripts/dev_tools/pr_context/test_verification_evidence.py).Count" ; poetry run pytest tests/scripts/dev_tools/pr_context/ --cov=scripts.dev_tools.pr_context.verification_evidence --cov-branch --cov-report=term-missing
EXIT_CODE: 0

Both commands are recorded on the single `Command:` line above rather than on two lines, because a
duplicated required key resolves differently in the two parsers (Python last-wins,
TypeScript first-wins) and this artifact is itself inside the corpus the [P7-T4] cross-runtime
comparison reads. One key line per artifact keeps that comparison free of a divergence this change
does not fix.

## File size

- `tests/scripts/dev_tools/pr_context/test_verification_evidence.py` = **408 lines**, within the
  500-line limit with 92 lines of headroom. No split into a sibling module was required.

## Module-scoped coverage (this test selection only)

```
Name                                                    Stmts   Miss Branch BrPart  Cover   Missing
scripts\dev_tools\pr_context\verification_evidence.py      58     10     18      1    75%   90-100, 124
TOTAL                                                      58     10     18      1    75%
============================= 54 passed in 0.18s ==============================
```

Separated figures for the module, derived from the same run's LCOV report
(`LH/LF` for lines, `BRH/BRF` for branches):

- Line coverage of the module under this selection: **82.76% (48/58)**
- Branch coverage of the module under this selection: **50.00% (9/18)**

The dotted-module form `--cov=scripts.dev_tools.pr_context.verification_evidence` was used
deliberately. The file-path form `--cov=<path>.py` collects nothing on this host, so a threshold
asserted against it would pass regardless of test quality.

## Reading of the `Missing` column — no uncovered ADDED or CHANGED line

`Missing` reports `90-100, 124`. Neither region is an added or changed line of this change:

- Lines **90-100** are the body of `discover_canonical_evidence_files`, which this change does not
  touch at all. This test module deliberately does not exercise discovery (discovery is covered by
  the collector-level tests elsewhere in the suite), so those lines are missed under this NARROW
  selection only. The two module-scoped percentages above are therefore a floor for a single test
  file, not the module's suite-wide figure; the suite-wide per-file figure is measured at [P8-T4]
  against the baseline of line 93.62% / branch 81.25% recorded at [P0-T10].
- Line **124** is the pre-existing `continue` for a colon-free line inside the parse loop. It was
  already uncovered at baseline (recorded as `104` in the baseline `Missing` column, before the
  additions shifted line numbers) and is unchanged by this change.

Every line this change added or modified — the optional-field constant (23), the record field (58),
the `normalize_result` helper (61-74), the `elif` accept branch (129-130), the expectation read
(135), the three `expected_exit_code=0` unparseable assignments (145, 158, 174), the new
non-integer-expectation branch (161-175), the normalization call (177-179), and the success-path
expectation (187) — is exercised by the 54 tests in this module and appears nowhere in the `Missing`
column.

Statement and branch counts rose from the baseline 47/16 to 58/18, which is the added branch surface
this change introduces, and only ONE partial branch remains under this selection.

Output Summary: The test module is 408 lines (<= 500). 54 tests pass, exit code 0. Module-scoped
coverage under this selection is line 82.76% (48/58) and branch 50.00% (9/18), measured with the
dotted-module `--cov` form. The `Missing` column reports `90-100, 124`, both of which are untouched
pre-existing regions (the discovery function, which this test module intentionally does not
exercise, and the pre-existing colon-free-line `continue`). No line added or changed by this change
appears in the `Missing` column.
