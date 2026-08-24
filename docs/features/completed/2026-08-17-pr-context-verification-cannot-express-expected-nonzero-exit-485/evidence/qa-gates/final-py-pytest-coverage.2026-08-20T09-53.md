# Final QC — Python tests with coverage

Timestamp: 2026-08-20T09-53

Task: [P8-T4]

Command: poetry run pytest --cov --cov-branch --cov-report=term-missing (separate line and branch percentages derived from the same run's LCOV report at `artifacts/python/lcov.info`, summing `LH/LF` for lines and `BRH/BRF` for branches, overall and per file)
EXIT_CODE: 0

## Test outcome

- Passed: **3995**
- Failed: **0**
- Skipped: **5** (the same five pre-existing skips as baseline, all in
  `tests/scripts/dev_tools/test_parallel_manifest_bash_parity.py:231`)

Baseline was 3995 - 3938 = **57 new tests**: 54 in the new parser module
`tests/scripts/dev_tools/pr_context/test_verification_evidence.py` and 3 runs from the 2 new cases in
`tests/scripts/dev_tools/test_collect_pr_context_expected_exit.py`.

## Overall coverage, separated

| Metric | Baseline ([P0-T10]) | Post-change | Delta |
| --- | --- | --- | --- |
| Overall LINE | 92.43% (13527/14635) | **92.45% (13542/14648)** | +0.02 pp |
| Overall BRANCH | 84.90% (4561/5372) | **84.93% (4564/5374)** | +0.03 pp |

Both are above the policy thresholds (line >= 85%, branch >= 75%) and neither regressed.

## Per-file coverage of the two changed Python production files

| File | Baseline line | Post line | Baseline branch | Post branch |
| --- | --- | --- | --- | --- |
| `scripts/dev_tools/pr_context/verification_evidence.py` | 93.62% (44/47) | **98.28% (57/58)** | 81.25% (13/16) | **88.89% (16/18)** |
| `scripts/dev_tools/pr_context/collector.py` | 92.38% (206/223) | **92.44% (208/225)** | 84.88% (73/86) | **84.88% (73/86)** |

Both files improved on line coverage and neither regressed on branch coverage.

## `term-missing` rows and the `Missing` column reading

```
scripts\dev_tools\pr_context\collector.py             225  17  86  13  90%  143-144, 264, 289, 304, 305->300, 339-340, 366-369, 382, 383->377, 395, 441, 474, 535, 557
scripts\dev_tools\pr_context\verification_evidence.py  58   1  18   2  96%  98->97, 124
TOTAL                                               14648 1106 5374 556  90%
```

The `Cover` column (96%, 90%, 90%) is a COMBINED statement-plus-branch metric and is neither the line
nor the branch percentage, which is why the separated figures above are derived from the LCOV report.

`Missing` for `verification_evidence.py` is `98->97, 124`, and **neither entry is a line this change
added or modified** (AC21):

- `98->97` is a partial branch inside `discover_canonical_evidence_files`, a function this change does
  not touch. It was present at baseline as `78->77` before the additions shifted the numbering.
- `124` is the pre-existing `continue` for a colon-free line inside the parse loop, uncovered at
  baseline too (recorded then as `104`).

Every line the change added or modified is covered: the optional-field constant, the record field, the
`normalize_result` helper, the accept branch, the expectation read, the three `expected_exit_code=0`
unparseable assignments, the new non-integer-expectation branch, the normalization call, and the
success-path expectation. The baseline gaps `126-127` (the non-integer-`EXIT_CODE` `except ValueError`
branch) are now covered by the new test module, which is why the file's missed-statement count fell
from 3 to 1.

`collector.py`'s `Missing` entries are all pre-existing regions; its 4 added lines are exercised by the
new collector-level tests.

## Load-bearing flags

`pyproject.toml:116` `addopts` carries no `--cov`, so `--cov --cov-branch` are load-bearing: without
them the run measures nothing. The same `addopts` writes the LCOV report the separated percentages are
derived from.

Output Summary: 3995 passed, 0 failed, 5 skipped; exit code 0. Overall line coverage 92.45%
(13542/14648) and overall branch coverage 84.93% (4564/5374), both above threshold and both improved
against the 92.43% / 84.90% baseline. Per file, `verification_evidence.py` rose to line 98.28% (57/58)
/ branch 88.89% (16/18) from 93.62% / 81.25%, and `collector.py` to line 92.44% (208/225) / branch
84.88% (73/86). The `Missing` column for `verification_evidence.py` is `98->97, 124`, both pre-existing
untouched regions; no line added or changed by this change is uncovered.
