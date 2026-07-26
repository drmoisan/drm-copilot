# Final QC — Extension Coverage

Timestamp: 2026-07-26T01-24

Task: [P4-T9]
Feature: 2026-07-25-jest-rootdir-testmatch-dot-directory-423
Issue: #423
QC Loop Pass: 1 (single clean pass; no restart required)

Working directory: `C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-a08c9cf1932159e8f`

Command: `npm --prefix extensions/drm-copilot run test:coverage`
Resolved script: `node run-jest.cjs --coverage --coverageReporters=lcov --coverageReporters=text-summary`
EXIT_CODE: 0

## Full Output

```
> drm-copilot@1.0.19 test:coverage
> node run-jest.cjs --coverage --coverageReporters=lcov --coverageReporters=text-summary


=============================== Coverage summary ===============================
Statements   : 96.34% ( 37690/39121 )
Branches     : 89.22% ( 5206/5835 )
Functions    : 89.51% ( 1101/1230 )
Lines        : 96.34% ( 37690/39121 )
================================================================================

Test Suites: 169 passed, 169 total
Tests:       2046 passed, 2046 total
Snapshots:   0 total
Time:        11.514 s
Ran all test suites.
```

## Numeric Coverage Headline (post-change)

| Metric | Percentage | Covered / Total | Repository threshold | Verdict |
|---|---|---|---|---|
| Statements | **96.34%** | 37690 / 39121 | — | — |
| Branches | **89.22%** | 5206 / 5835 | >= 75% | PASS (+14.22 pts) |
| Functions | **89.51%** | 1101 / 1230 | — | — |
| Lines | **96.34%** | 37690 / 39121 | >= 85% | PASS (+11.34 pts) |

Both uniform repository gates from `.claude/rules/general-unit-test.md` and
`.claude/rules/quality-tiers.md` (line >= 85%, branch >= 75%, applied uniformly across T1–T4) are
satisfied with substantial headroom.

## Per-File coverageThreshold Gate

`extensions/drm-copilot/jest.config.cjs` declares 30 per-file `coverageThreshold` entries, each
requiring `lines: 85, branches: 75`. Jest exits **non-zero** if any configured threshold entry is
unmet. This run exited **0**, which is direct proof that **every configured per-file threshold entry
passed**. No threshold regressed.

The `coverageThreshold` block, `collectCoverageFrom` (`["src/**/*.ts", "!src/**/*.d.ts"]`),
`coverageReporters`, and `coverageDirectory` are byte-identical to base `fb483b84` — see
`evidence/other/config-diff.2026-07-26T01-03.md`. No coverage exclusion was added, removed, or
modified by this feature, in line with `.claude/rules/general-unit-test.md` → "Coverage Exclusion
Policy".

## Relationship to Baseline

There is no numeric pre-fix baseline to compare against: the defect prevented all test discovery, so
`test:coverage` exited 1 before emitting any summary (see
`evidence/baseline/baseline-extension-coverage.2026-07-26T00-57.md`, which records
`WhyNumericBaselineUnavailable:`). Correctness is therefore established by absolute threshold
satisfaction rather than by delta. Full reasoning is recorded in the coverage-delta artifact
([P4-T10]).

Coverage output was written to the gitignored `extensions/drm-copilot/coverage/` directory (lcov
reporter); it does not appear in `git status` and requires no scope exception.

Output Summary: PASS. `npm --prefix extensions/drm-copilot run test:coverage` exits 0. Post-change
coverage: **Statements 96.34% (37690/39121), Branches 89.22% (5206/5835), Functions 89.51%
(1101/1230), Lines 96.34% (37690/39121)**, with 169 suites and 2046 tests all passing. The exit code
of 0 confirms every one of the 30 configured per-file `coverageThreshold` entries passed. Both
uniform repository gates (line >= 85%, branch >= 75%) are met. No loop restart triggered.
