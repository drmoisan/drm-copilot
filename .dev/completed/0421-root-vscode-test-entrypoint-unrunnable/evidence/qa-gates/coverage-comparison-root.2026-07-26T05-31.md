# Coverage Delta / Threshold Verification (#421)

Timestamp: 2026-07-26T05-31

Task: [P4-T6] — AC8 supporting evidence.

Command:

```
(comparison of [P0-T9] baseline artifact against [P4-T5] post-change artifact)
git diff --name-only fb483b8468204e4385b5583c3b3ec4c0a987eede
```

Sources compared:
- Baseline: `evidence/baseline/baseline-test-coverage-root.2026-07-26T05-10.md`
- Post-change: `evidence/qa-gates/final-test-coverage-root.2026-07-26T05-29.md`

Both runs used the identical command (plus `--coverage`) and the identical `--testMatch` pair, so the two measurements are directly comparable.

EXIT_CODE: 0

## (a) Baseline Coverage — [P0-T9]

| Metric | Value |
|---|---|
| Line coverage | 97.01% |
| Branch coverage | 89.07% |
| Statement coverage | 97.01% |
| Function coverage | 89.29% |
| Test suites | 169 passed / 169 total |
| Tests | 2036 passed / 2036 total |

## (b) Post-Change Coverage — [P4-T5]

| Metric | Value |
|---|---|
| Line coverage | 97.01% |
| Branch coverage | 89.07% |
| Statement coverage | 97.01% |
| Function coverage | 89.29% |
| Test suites | 170 passed / 170 total |
| Tests | 2038 passed / 2038 total |

## Delta

| Metric | Baseline | Post-change | Delta | Verdict |
|---|---|---|---|---|
| Line coverage | 97.01% | 97.01% | 0.00 pp | No regression |
| Branch coverage | 89.07% | 89.07% | 0.00 pp | No regression |
| Statement coverage | 97.01% | 97.01% | 0.00 pp | No regression |
| Function coverage | 89.29% | 89.29% | 0.00 pp | No regression |
| Test suites | 169 | 170 | +1 | Increase (the guard suite) |
| Tests | 2036 | 2038 | +2 | Increase (the guard's two cases) |

Coverage percentages are unchanged to two decimal places, and executed test count increased by two. There is no regression on any metric.

## (c) New / Changed-Code Coverage

**No production source file changed.** The complete change set relative to base `fb483b8468204e4385b5583c3b3ec4c0a987eede` is:

```
$ git diff --name-only fb483b8468204e4385b5583c3b3ec4c0a987eede
.github/workflows/README.md
.github/workflows/ci.yml
docs/features/active/2026-07-25-root-vscode-test-entrypoint-unrunnable-421/... (feature folder: issue.md, spec.md, plan, research, evidence/*)
package.json
tests/unit/vscode-test-removal.test.ts
```

(The listing above additionally includes `.github/workflows/_root-typescript-tests.yml`, which was untracked at the time of this command and is included in the [P4-T7] boundary inventory.)

Classification of every changed path against the coverage denominator:

| Changed path | Kind | In coverage denominator? |
|---|---|---|
| `package.json` | npm manifest — `scripts` block only | No. Not a coverage-instrumented source file. |
| `tests/unit/vscode-test-removal.test.ts` | New test file | No. Test files are excluded from the denominator per `.claude/rules/general-unit-test.md` ("Configure coverage tooling to exclude test files so metrics reflect application code"). It adds executed test code only. |
| `.github/workflows/_root-typescript-tests.yml` | CI workflow YAML | No. Not executable application source. |
| `.github/workflows/ci.yml` | CI workflow YAML | No. Not executable application source. |
| `.github/workflows/README.md` | Markdown documentation | No. |
| `docs/features/active/.../**` | Markdown documentation and evidence | No. |

**The coverage denominator is unchanged.** No line of production code was added, removed, or modified, so there is no new or changed production code whose coverage could be measured. New/changed-code coverage is therefore vacuously satisfied: the set of changed production lines is empty. This is consistent with the identical baseline and post-change percentages, which is the expected result when the denominator does not move and no production line changes state.

The single new *executable* artifact is the guard test itself, and it is fully executed (`Test Suites: 1 passed, 1 total`, `Tests: 2 passed, 2 total` — see [P4-T5] Command 2).

## (d) Threshold Confirmation

| Threshold (`.claude/rules/quality-tiers.md`, uniform T1–T4) | Required | Post-change | Verdict |
|---|---|---|---|
| Line coverage | >= 85% | 97.01% | PASS (margin +12.01 pp) |
| Branch coverage | >= 75% | 89.07% | PASS (margin +14.07 pp) |
| No regression on changed lines | required | no production line changed; percentages unchanged | PASS |

## AC8 Cross-Reference

This artifact supplies the "coverage does not silently decrease" half of AC8. The other components are:
- AC8(a) — removed scripts executed zero tests: `evidence/regression-testing/fail-before-npm-test.2026-07-26T05-06.md` and `fail-before-npm-test-integration.2026-07-26T05-07.md` (both exit inside `@vscode/test-cli` `loadDefaultConfigFile` before any runner starts).
- AC8(b) — no CI workflow previously ran the root TypeScript toolchain: `evidence/baseline/baseline-ci-inventory.2026-07-26T05-11.md` (zero grep matches).
- AC8(c) — the new workflow now runs the root jest suite on every `ci.yml` trigger: established by [P5-T4]/[P5-T5] green-run evidence.

Output Summary: Baseline line/branch coverage **97.01% / 89.07%**; post-change line/branch coverage **97.01% / 89.07%**; delta **0.00 pp on both**, with test suites +1 (169 to 170) and tests +2 (2036 to 2038). New/changed-code coverage: **no production source file changed** — the change set is the `package.json` scripts block, two workflow YAML files, one workflow README, feature-folder documentation, and one new test file, none of which is in the coverage denominator; the denominator is unchanged and the changed-production-line set is empty. Both mandatory thresholds pass (line 97.01% >= 85%, branch 89.07% >= 75%). No regression on any metric.
