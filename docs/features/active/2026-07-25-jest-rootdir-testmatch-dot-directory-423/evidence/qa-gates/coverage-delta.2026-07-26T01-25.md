# Coverage Delta / Threshold Verification

Timestamp: 2026-07-26T01-25

Task: [P4-T10]
Feature: 2026-07-25-jest-rootdir-testmatch-dot-directory-423
Issue: #423

---

## (a) Baseline Coverage

Reference artifact: `<FEATURE>/evidence/baseline/baseline-extension-coverage.2026-07-26T00-57.md`
([P0-T5], tagged `[expect-fail]`).

- Command: `npm --prefix extensions/drm-copilot run test:coverage`
- EXIT_CODE: **1**
- Output: `No tests found, exiting with code 1` — 368 files checked, 0 testMatch matches. No coverage
  summary was emitted.

`WhyNumericBaselineUnavailable:` (quoted verbatim from the baseline artifact)

> The defect under repair (issue #423) causes zero test discovery in this dot-prefixed worktree, so
> Jest exits with `No tests found, exiting with code 1` before any test executes and before the
> coverage reporter emits a text-summary. No statements, branches, functions, or lines percentages
> are produced — not zero values, but no values at all. Numeric baseline coverage is therefore
> structurally unobtainable pre-fix, and this expect-fail artifact IS the pre-fix coverage baseline
> of record.

A numeric baseline is not merely missing; it is unobtainable in principle at the base commit, because
the defect being fixed is precisely the failure to discover any test. A numeric-to-numeric delta
therefore cannot be computed, and the verification below is by absolute threshold satisfaction.

---

## (b) Post-Change Numeric Coverage

Source artifact: `<FEATURE>/evidence/qa-gates/final-extension-coverage.2026-07-26T01-24.md`
([P4-T9]).

- Command: `npm --prefix extensions/drm-copilot run test:coverage`
- EXIT_CODE: **0**
- Suites: 169 passed / 169 total. Tests: 2046 passed / 2046 total.

| Metric | Percentage | Covered / Total | Repository threshold | Verdict |
|---|---|---|---|---|
| Statements | **96.34%** | 37690 / 39121 | — | — |
| Branches | **89.22%** | 5206 / 5835 | >= 75% | PASS (+14.22 pts headroom) |
| Functions | **89.51%** | 1101 / 1230 | — | — |
| Lines | **96.34%** | 37690 / 39121 | >= 85% | PASS (+11.34 pts headroom) |

Both uniform repository gates (`.claude/rules/quality-tiers.md`: line >= 85%, branch >= 75% across
T1–T4) are satisfied.

---

## (c) New / Changed-Code Coverage

This feature changed six files. None of them is inside the coverage denominator.

| # | Changed file | Kind | Inside `collectCoverageFrom` (`src/**/*.ts` less `src/**/*.d.ts`)? |
|---|---|---|---|
| 1 | `jest.config.cjs` (root) | Jest configuration scaffolding | No — not under `src/`, and the root package configures no coverage thresholds |
| 2 | `run-jest.cjs` (root) | CLI entry-point scaffolding | No — not under `src/` |
| 3 | `extensions/drm-copilot/jest.config.cjs` | Jest configuration scaffolding | No — not under `src/` |
| 4 | `extensions/drm-copilot/run-jest.cjs` | CLI entry-point scaffolding | No — not under `src/` |
| 5 | `tests/unit/jest-config-resolution.test.ts` | Test file | No — test file, under `tests/` |
| 6 | `extensions/drm-copilot/test/jest-config-resolution.test.ts` | Test file | No — test file, under `test/`, not `src/` |

Consequences:

- **No new per-file `coverageThreshold` obligation exists.** The extension config's threshold block
  enumerates `./src/...` paths only. None of the six changed files is under `src/`, so no new entry
  is required and none was added.
- **The production coverage denominator did not change.** `collectCoverageFrom` is byte-identical to
  base `fb483b84` (verified in `evidence/other/config-diff.2026-07-26T01-03.md`), and no production
  `src/**` file was added, removed, or modified. The set of measured files is exactly what it was at
  base.
- **No coverage exclusion was added or modified**, in compliance with
  `.claude/rules/general-unit-test.md` → "Coverage Exclusion Policy". The diff adds no `exclude`
  entry anywhere.
- **A coverage regression from these edits is mechanically impossible**, since the changed files
  contribute nothing to the numerator or the denominator.

The two new test files add executable test coverage (25 new tests: 14 root + 11 extension) without
adding anything to the measured production surface. Their effect on the metric is neutral-to-positive
by construction.

Regarding the `run-jest.cjs` guard specifically: it is a spawn-and-exit script that is not
unit-tested directly, per the spec's Test Strategy (unit tests must not spawn external processes and
no helper module may be extracted). Its verification is the executed evidence in
`evidence/regression-testing/guard-root.2026-07-26T01-06.md` and
`evidence/regression-testing/guard-extension.2026-07-26T01-07.md` — six invocations, all exit 1 with
the correct message and no Jest spawn. If executable coverage is added later it must be an
integration test.

---

## (d) Verdict

**PASS.**

| Check | Result |
|---|---|
| Post-change coverage run exit code | **0** |
| Every configured per-file `coverageThreshold` entry passed | **Yes** — Jest exits non-zero if any threshold entry is unmet; exit 0 is direct proof all 30 entries passed |
| Any per-file threshold regressed | **No** |
| Uniform line gate (>= 85%) | PASS at 96.34% |
| Uniform branch gate (>= 75%) | PASS at 89.22% |
| Numeric post-change values recorded | **Yes** — statements 96.34%, branches 89.22%, functions 89.51%, lines 96.34% |
| Numeric baseline values recorded | **Not obtainable** — documented and justified in section (a); this is the recorded state of the pre-fix baseline, not a missing artifact |
| Coverage denominator changed by this feature | **No** |
| Coverage exclusion added or modified | **No** |

The verdict is PASS rather than remediation-required because every value that *can* exist has been
captured numerically. The absent baseline number is not an unmeasured value; it is a value that
provably cannot exist at the base commit, recorded with its justification in a schema-valid
expect-fail baseline artifact ([P0-T5]). Verification of no-regression is supplied instead by the
per-file threshold gate, which is a stricter, absolute check: Jest itself fails the run if any of the
30 configured per-file entries drops below `lines: 85, branches: 75`, and it did not.

Output Summary: PASS. Baseline coverage is structurally unobtainable pre-fix (zero test discovery,
documented in [P0-T5]). Post-change coverage is statements 96.34% (37690/39121), branches 89.22%
(5206/5835), functions 89.51% (1101/1230), lines 96.34% (37690/39121), with `test:coverage` exiting
0 — proving all 30 per-file `coverageThreshold` entries passed. The six changed files lie entirely
outside `collectCoverageFrom` (`src/**`), so no new threshold obligation was created and the
production coverage denominator is unchanged. No threshold regressed.
