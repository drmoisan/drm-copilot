# Coverage Delta Comparison (issue #472, AC17)

Timestamp: 2026-08-15T12-36

Command: comparison of the Phase 0 baseline artifacts against the Phase 7 final artifacts (no new command executed; values are read from the recorded artifacts named below).

EXIT_CODE: 0

Sources compared:

| Language | Baseline artifact | Final artifact |
| --- | --- | --- |
| TypeScript | `evidence/baseline/phase0-ts-test-coverage.md` | `evidence/qa-gates/final-ts-test-coverage.2026-08-15T12-23.md` |
| Python | `evidence/baseline/phase0-py-pytest-coverage.md` | `evidence/qa-gates/final-py-pytest-coverage.2026-08-15T12-29.md` |

---

## TypeScript headline coverage

| Metric | Baseline | Post-change | Delta |
| --- | --- | --- | --- |
| Lines | 96.57% (40958/42412) | **96.61% (41738/43200)** | **+0.04 pp** |
| Branches | 89.90% (5822/6476) | **89.96% (5901/6559)** | **+0.06 pp** |
| Statements | 96.57% (40958/42412) | 96.61% (41738/43200) | +0.04 pp |
| Functions | 90.15% (1191/1321) | 90.11% (1221/1355) | -0.04 pp |
| Tests | 2495 passed / 2495 | 2552 passed / 2552 | +57 |
| Suites | 183 passed / 183 | 185 passed / 185 | +2 |

No regression on the two gated metrics: both line and branch coverage rose. The
function-coverage figure moved by -0.04 pp, which is not a gated metric under
`.claude/rules/quality-tiers.md` (the uniform gates are line >= 85% and branch
>= 75%) and reflects the 34 new functions the two derive modules and their test
helpers introduced into the denominator.

## TypeScript new-module coverage (the gated requirement)

The >= 85% line / >= 75% branch new-module requirement applies to the two new
TypeScript production modules.

| New module | Line coverage | >= 85%? | Branch coverage | >= 75%? |
| --- | --- | --- | --- | --- |
| `extensions/drm-copilot/src/lib/push-down/claude-blast-radius-derive-core.ts` | **100%** | PASS | **95.83%** | PASS |
| `extensions/drm-copilot/src/lib/push-down/claude-blast-radius-derive.ts` | **97.38%** | PASS | **93.93%** | PASS |

Changed-module coverage for the one modified production module:

| Changed module | Line coverage | >= 85%? | Branch coverage | >= 75%? |
| --- | --- | --- | --- | --- |
| `extensions/drm-copilot/src/lib/push-down/claude-customizations.ts` | **100%** | PASS | **93.93%** | PASS |

`extensions/drm-copilot/src/lib/push-down/claude-routing-merge.ts` changed by a
doc comment only ([P3-T4]); it contains no changed executable line, so it has no
changed-line coverage obligation.

All per-file values are read from the Jest `text` reporter table captured in
`final-ts-test-coverage.2026-08-15T12-23.md`.

## Python headline coverage

| Metric | Baseline | Post-change | Delta |
| --- | --- | --- | --- |
| Combined TOTAL (coverage.py) | 90% | **90%** | **0.00 pp** |
| Line (statement) coverage | 92.30% (14396-1108 / 14396) | **92.30% (14396-1108 / 14396)** | **0.00 pp** |
| Branch coverage | 89.46% (5286-557 / 5286) | **89.46% (5286-557 / 5286)** | **0.00 pp** |
| Tests | 3781 passed, 5 skipped | 3785 passed, 5 skipped | +4 passed |

The TOTAL row is numerically identical (`14396 1108 5286 557 90%`), so there is
no regression.

## Python new/changed-module coverage

**N/A — no Python production module changed in this item.**

This recorded `N/A` is the defined correct value for this field per the plan's
[P7-T12] text, not a missing or unverified value, and it does not trigger the
fail-closed clause. The item's only Python change is the test file
`tests/scripts/dev_tools/test_blast_radius_config.py`, which is excluded from
coverage measurement by policy. The two other changed files
(`config/blast-radius.json` and
`extensions/drm-copilot/resources/claude-customizations/config/blast-radius.json`)
are JSON configuration and carry no executable Python.

## Verdict

- No coverage regression in either language's headline numbers. TypeScript line and branch coverage both increased; Python line and branch coverage are unchanged.
- Both new TypeScript modules clear the >= 85% line and >= 75% branch floor with margin.
- Every reported value is numeric except the Python new-module field, whose `N/A` is the plan-defined correct value.
- No `UNVERIFIED` placeholder appears in this comparison.

**AC17 result: PASS.**
