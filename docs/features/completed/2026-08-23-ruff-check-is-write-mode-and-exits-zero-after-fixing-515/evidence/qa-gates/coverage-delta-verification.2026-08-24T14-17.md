# Final QA Gate — Coverage Delta Verification (P4-T5)

Timestamp: 2026-08-24T14-17

Task: [P4-T5]
Issue: #515

Command: `poetry run python -c "import json;t=json.load(open('artifacts/python/coverage.json'))['totals'];L=100.0*t['covered_lines']/t['num_statements'];B=100.0*t['covered_branches']/t['num_branches'];print('LINE',round(L,4));print('BRANCH',round(B,4));print('DLINE',round(L-92.6067,4));print('DBRANCH',round(B-85.1913,4))"`

EXIT_CODE: 0

Verbatim output:

```text
LINE 92.6067
BRANCH 85.2095
DLINE 0.0
DBRANCH 0.0182
```

The two baseline constants embedded in the command are the P0-T6 figures. Both baseline
and post-change figures are computed by the same formulas from the `totals` block of
`artifacts/python/coverage.json`, so the comparison is like-for-like.

## Coverage comparison

| Metric | Baseline (P0-T6) | Post-change (P4-T4) | Signed delta | Threshold | Verdict |
| --- | --- | --- | --- | --- | --- |
| **Total LINE coverage** | **92.6067 %** | **92.6067 %** | **+0.0000 pp** | >= 85 % | PASS, no regression |
| **Total BRANCH coverage** | **85.1913 %** | **85.2095 %** | **+0.0182 pp** | >= 75 % | PASS, no regression |

Each figure is identified as line or branch and traced to the `totals` fields it was
computed from:

| Figure | `totals` fields used | Baseline operands | Post-change operands |
| --- | --- | --- | --- |
| LINE | `covered_lines` / `num_statements` | 13841 / 14946 | 13841 / 14946 |
| BRANCH | `covered_branches` / `num_branches` | 4677 / 5490 | 4678 / 5490 |

Neither figure is taken from the term report's combined `TOTAL` row, which printed 91 % in
both runs. That row is coverage.py's combined `percent_covered` (90.6146 % at baseline,
90.6195 % post-change) and is neither the line percent nor the branch percent. It is
recorded in both the P0-T6 and P4-T4 artifacts as the labelled combined figure only.

## Reading the two deltas

**Line coverage is bit-for-bit unchanged.** `covered_lines` is 13841 and `num_statements`
is 14946 in both runs, so the delta is exactly zero rather than merely rounding to zero.

**Branch coverage rose by 0.0182 percentage points**, from 4677 to 4678 covered branches
out of an unchanged denominator of 5490. `num_partial_branches` fell from 559 to 558 and
`missing_branches` from 813 to 812 correspondingly. This is a one-branch improvement in the
measured source set, not a regression, so it satisfies the no-regression requirement in the
direction that requirement cares about. Its magnitude is consistent with normal run-to-run
variation in a suite of this size and is not claimed as an effect of this change.

## Changed-code coverage

**The diff adds no line to the measured source set, so there is no changed-code coverage
figure to report and none is required.**

The coverage source set is declared at `pyproject.toml:120` as
`source = ["src", "scripts/dev_tools"]`, and `tests/` is omitted at `pyproject.toml:122-127`.
This plan's diff writes exactly two repository files, and neither is in the measured set:

- `pyproject.toml` — configuration, not Python source. It is not under `src` or
  `scripts/dev_tools` and contains no executable statement that coverage.py measures.
  Its change is a single-line deletion.
- `tests/scripts/dev_tools/test_ruff_config_alignment.py` — test code, explicitly omitted
  from measurement by the `omit` list at `pyproject.toml:122-127` (`tests/*`).

The unchanged denominator confirms this independently: `num_statements` is 14946 and
`num_branches` is 5490 in both the baseline and the post-change run. Had the diff added a
measured line, the statement denominator would have moved. It did not, so no changed line
entered the coverage denominator and there is no changed-line coverage regression possible.

This matches the spec's own analysis at Test Strategy, "Coverage impact and targets":
`pyproject.toml` is configuration, not measured production source, so the change adds no
uncovered production lines and the thresholds are unaffected.

Output Summary: **Baseline line coverage 92.6067 % (13841/14946); post-change line coverage
92.6067 % (13841/14946); signed delta +0.0000 pp. Baseline branch coverage 85.1913 %
(4677/5490); post-change branch coverage 85.2095 % (4678/5490); signed delta +0.0182 pp.**
Each percentage is identified as line or branch and traced to the
`artifacts/python/coverage.json` `totals` fields it was computed from. Changed-code
coverage: the diff adds no line to the measured source set `src` / `scripts/dev_tools`,
because `pyproject.toml` is configuration and `tests/` is omitted at
`pyproject.toml:122-127`; the unchanged statement and branch denominators corroborate this.

**Verdict: total line coverage is 92.6067 %, at or above the 85 percent threshold; total
branch coverage is 85.2095 %, at or above the 75 percent threshold; and neither figure
regressed against baseline — line is unchanged and branch improved by 0.0182 pp.**
