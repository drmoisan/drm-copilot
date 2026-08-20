# Coverage delta and threshold verification, both languages

Timestamp: 2026-08-20T09-53

Task: [P9-T1]

Command: values read from `evidence/baseline/py-pytest-coverage.2026-08-20T09-53.md`, `evidence/baseline/ts-test-coverage.2026-08-20T09-53.md`, `evidence/qa-gates/final-py-pytest-coverage.2026-08-20T09-53.md`, and `evidence/qa-gates/final-ts-test-coverage.2026-08-20T09-53.md`; new/changed-code coverage computed by intersecting the added-line numbers from `git diff -U0` against the `DA:` records of `artifacts/python/lcov.info` and `extensions/drm-copilot/coverage/lcov.info`
EXIT_CODE: 0

## Overall coverage, baseline versus post-change

| Language | Metric | Baseline | Post-change | Delta | Threshold | Verdict |
| --- | --- | --- | --- | --- | --- | --- |
| Python | LINE | 92.43% (13527/14635) | **92.45% (13542/14648)** | **+0.02 pp** | >= 85% | PASS |
| Python | BRANCH | 84.90% (4561/5372) | **84.93% (4564/5374)** | **+0.03 pp** | >= 75% | PASS |
| TypeScript | LINE | 96.61% (41750/43212) | **96.62% (41810/43272)** | **+0.01 pp** | >= 85% | PASS |
| TypeScript | BRANCH | 89.96% (5902/6560) | **89.98% (5912/6570)** | **+0.02 pp** | >= 75% | PASS |

No metric regressed in either language; all four improved.

## Per-file coverage of the four changed production files

| File | Baseline line | Post line | Baseline branch | Post branch |
| --- | --- | --- | --- | --- |
| `scripts/dev_tools/pr_context/verification_evidence.py` | 93.62% (44/47) | **98.28% (57/58)** | 81.25% (13/16) | **88.89% (16/18)** |
| `scripts/dev_tools/pr_context/collector.py` | 92.38% (206/223) | **92.44% (208/225)** | 84.88% (73/86) | **84.88% (73/86)** |
| `extensions/drm-copilot/src/lib/pr-context/verification-evidence.ts` | 95.56% | **96.36%** | 80.00% | **83.72%** |
| `extensions/drm-copilot/src/lib/pr-context/collector-output.ts` | 97.55% | **97.57%** | 80.51% | **81.01%** |

## New / changed-code coverage — 100% for all four files

Added-line counts come from `git diff --numstat` against the merge-base
`71aebdb9a1e4752b191b3c9d4e677b807ea6fdec`; the covered fraction comes from intersecting the added
line numbers with the `DA:` (line-hit) records of each language's LCOV report from the final QC run.

| File | Added lines | Lines with an LCOV record | Covered | Missed | Covered fraction |
| --- | --- | --- | --- | --- | --- |
| `scripts/dev_tools/pr_context/verification_evidence.py` | 45 (1 deleted) | 12 | 12 | 0 | **100%** |
| `scripts/dev_tools/pr_context/collector.py` | 4 | 2 | 2 | 0 | **100%** |
| `extensions/drm-copilot/src/lib/pr-context/verification-evidence.ts` | 56 (1 deleted) | 56 | 56 | 0 | **100%** |
| `extensions/drm-copilot/src/lib/pr-context/collector-output.ts` | 5 | 5 | 5 | 0 | **100%** |
| **All four** | 110 | **75** | **75** | **0** | **100.00%** |

Reading note on the two denominators: on the PYTHON side `coverage.py` emits a `DA:` record only for
executable statements, so 12 of the 45 added lines are executable (the remainder are docstring,
comment, blank, and multi-line-expression continuation lines) and all 12 are covered. On the
TYPESCRIPT side Istanbul emits a `DA:` record for non-statement lines as well — verified directly, for
example the comment line 26 and the doc-comment line 47 both carry `DA` records with a non-zero hit
count — so the 56-of-56 figure is a SUPERSET check rather than a strict executable-line count. In both
cases the discriminating signal is the same and is satisfied: **no added line in any of the four files
carries a zero hit count.**

The single deleted line in each parser is the pre-change normalization expression, replaced by the
call to the extracted helper, and the helper's body is covered.

## Verdict

- Overall line coverage: Python 92.45% and TypeScript 96.62%, both >= 85%.
- Overall branch coverage: Python 84.93% and TypeScript 89.98%, both >= 75%.
- New/changed-code coverage: 100% for all four production files.
- No metric regressed against baseline; every one improved.
- Every value above is numeric; no placeholder appears.

Output Summary: All four overall metrics improved and all clear their thresholds — Python line 92.43%
to 92.45% and branch 84.90% to 84.93%; TypeScript line 96.61% to 96.62% and branch 89.96% to 89.98%.
New/changed-code coverage is 100% across the four changed production files (75 of 75 added lines with
an LCOV record are covered, 0 missed). The per-file figures for all four files improved or held. No
regression, no placeholder value.
