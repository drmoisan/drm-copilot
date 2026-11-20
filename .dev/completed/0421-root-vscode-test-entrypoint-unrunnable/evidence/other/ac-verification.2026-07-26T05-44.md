# Acceptance-Criteria Verification (#421)

Timestamp: 2026-07-26T05-44

Task: [P6-T1]

Work Mode: `full-bug`. AC source is `docs/features/active/2026-07-25-root-vscode-test-entrypoint-unrunnable-421/spec.md` **only** (AC1–AC11). `user-story.md` is intentionally absent for `full-bug`; its absence is correct and is not a defect.

All evidence paths below are relative to `docs/features/active/2026-07-25-root-vscode-test-entrypoint-unrunnable-421/`.

## Per-AC Verification Table

| AC | Criterion (abbreviated) | Verifying artifact(s) | Key evidence | Verdict |
|---|---|---|---|---|
| AC1 | Scripts block corrected: `test` == `node run-jest.cjs`, `pretest` == `npm run compile && npm run lint`, `test:integration` and `compile:integration-tests` removed, `.vscode-test.mjs` dropped from `format`/`format:check` | `evidence/qa-gates/scripts-block-verification.2026-07-26T05-16.md` | Six per-condition assertions, each verified programmatically against the committed manifest; diff is one hunk, 4 insertions / 6 deletions, all inside the `scripts` object | **PASS** |
| AC2 | No root npm script value contains `vscode-test` | `evidence/qa-gates/scripts-block-verification.2026-07-26T05-16.md`; guard test `tests/unit/vscode-test-removal.test.ts` | `VSCODE_TEST_VALUE_MATCHES: 0` across all 11 script values; guard test enforces this going forward | **PASS** |
| AC3 | Regression guard present at `tests/unit/vscode-test-removal.test.ts`, asserts both conditions, needs no jest config change | `evidence/qa-gates/guard-test-local-run.2026-07-26T05-22.md`; `evidence/other/prior-art-vscode-test-removal-2f67b888.2026-07-26T05-12.md` | File exists at the exact path; asserts no script value contains `vscode-test` and that all five dead config files are absent; `--listTests` proves auto-discovery under the existing `testMatch`; `git status --porcelain jest.config.cjs run-jest.cjs` empty | **PASS** |
| AC4 | Guard listed as an executed, passing suite locally **and** on CI | Local: `evidence/qa-gates/guard-test-local-run.2026-07-26T05-22.md`, `evidence/qa-gates/final-test-coverage-root.2026-07-26T05-29.md`. CI: `evidence/qa-gates/ci-green-run-root-typescript-tests.2026-07-26T05-40.md` | Local: `Test Suites: 1 passed, 1 total` / `Ran all test suites matching vscode-test-removal.` CI: explicit `PASS tests/unit/vscode-test-removal.test.ts` on **both** ubuntu-latest and windows-latest | **PASS** |
| AC5 | New reusable `_<name>.yml` with both triggers, runs `npm ci` + root `npm test`, referenced from `ci.yml` via `uses:`, listed in the README dispatch table | `evidence/qa-gates/ci-orchestrator-run.2026-07-26T05-41.md`; files `.github/workflows/_root-typescript-tests.yml`, `ci.yml`, `README.md` | Seven-row requirement table all PASS; the `root-typescript-tests` job appears in the `ci.yml` run job list, proving the `uses:` reference resolves end-to-end; README table row added and intro count corrected to eight | **PASS** |
| AC6 | Root `npm test` ends in a defined, passing state, verified on CI; also satisfies `modified-workflow-needs-green-run` | `evidence/qa-gates/ci-green-run-root-typescript-tests.2026-07-26T05-40.md` | Run 30189336124 against head `df874e81`, both OS jobs `success`; log shows `pretest` (compile + lint) then jest with `Test Suites: 170 passed, 170 total` / `Tests: 2038 passed, 2038 total` | **PASS** |
| AC7 | Local path-independent verification recorded | `evidence/qa-gates/guard-test-local-run.2026-07-26T05-22.md`; `evidence/qa-gates/final-test-coverage-root.2026-07-26T05-29.md` | Rootdir-free `node run-jest.cjs --testMatch ... --testMatch ...` exits 0 with 170/170 suites and 2038/2038 tests; CI parity confirms the workaround selects the intended suite set | **PASS** |
| AC8 | No silent coverage reduction, with proof: (a) removed scripts executed zero tests, (b) no CI workflow previously ran the root toolchain, (c) the new workflow now runs it every `ci.yml` trigger | (a) `evidence/regression-testing/fail-before-npm-test.2026-07-26T05-06.md` and `fail-before-npm-test-integration.2026-07-26T05-07.md`; (b) `evidence/baseline/baseline-ci-inventory.2026-07-26T05-11.md`; (c) `evidence/qa-gates/ci-green-run-root-typescript-tests.2026-07-26T05-40.md`; delta: `evidence/qa-gates/coverage-comparison-root.2026-07-26T05-31.md` | (a) Both scripts exit inside `@vscode/test-cli` `loadDefaultConfigFile` before any runner starts — zero tests executed; (b) grep of `.github/workflows/` returned **zero matches**; (c) the root suite now runs on both runner classes; coverage delta 0.00 pp with tests +2 | **PASS** |
| AC9 | Boundaries respected: no change to the six forbidden paths, `devDependencies`, or `package-lock.json` | `evidence/qa-gates/boundary-inventory.2026-07-26T05-33.md` | All six forbidden paths empty from both `git diff --name-only` vs base and `git status --porcelain`; per-key comparison shows `scripts` is the **only** changed top-level `package.json` key | **PASS** |
| AC10 | Full seven-stage toolchain passes in a single pass, with n/a rationale where applicable | `evidence/qa-gates/final-format-check-root.2026-07-26T05-26.md`, `final-lint-root.2026-07-26T05-26.md`, `final-typecheck-root.2026-07-26T05-27.md`, `final-stages-4-6-7-na-root.2026-07-26T05-28.md`, `final-test-coverage-root.2026-07-26T05-29.md`, `final-qa-clean-pass.2026-07-26T05-34.md` | 1 loop iteration, no restart; stages 1/2/3/5 executed with EXIT_CODE 0; stages 4/6/7 n/a with command evidence for the architecture-gate absence; line 97.01% >= 85%, branch 89.07% >= 75% | **PASS** |
| AC11 | Scope decision documented in the spec | `spec.md` `## Scope Decision` section (lines 100–123) | Selected option (a) at line 104; decisive evidence items 1–6 at lines 110–115, including the `git log --all` correction (lines 95, 111) and the `2f67b888` prior art (line 114); rejected option (b) with reasons at line 117; strongest counterargument and why it does not prevail at line 121; devDependency/lockfile exclusion as follow-up at line 67 (Scope & Non-Goals) and line 262 (Rollout & Follow-up) | **PASS** |

## AC11 Component Checklist (verified individually)

| Required component | Location in `spec.md` | Present |
|---|---|---|
| Selected option (a) recorded | Line 104, `### Selected: option (a) — remove the dead entry points` | Yes |
| Decisive evidence | Lines 108–115, six numbered items | Yes |
| Orchestrator's `git log --all` correction to the research artifact | Line 95 (Root Cause Analysis, "**Correction to the research artifact:**") and line 111 (Scope Decision item 2) | Yes |
| `2f67b888` prior art cited | Line 95 and line 114 (Scope Decision item 5) | Yes |
| Rejected option (b) with reasons | Line 117, `### Rejected: option (b) — wire a real vscode-test harness at the root`, citing items 3, 4, 6 | Yes |
| Strongest counterargument and why it does not prevail | Line 121, `### Strongest counterargument, and why it does not prevail` | Yes |
| Deliberate exclusion of devDependency/lockfile changes as a follow-up | Line 67 (Out of scope / non-goals) and line 262 (Rollout & Follow-up) | Yes |

## Check-Off Actions Performed in `spec.md`

Each criterion was changed from `- [ ]` to `- [x]` individually, evidence-first, with the criterion text left unmodified:

| AC | Checked off after | Phase |
|---|---|---|
| AC1 | [P1-T6] verification passed | Phase 1 |
| AC2 | [P1-T6] verification passed | Phase 1 |
| AC3 | [P2-T1] and [P2-T2] verification passed | Phase 2 |
| AC7 | [P2-T2] verification passed | Phase 2 |
| AC9 | [P4-T7] verification passed | Phase 4 |
| AC10 | [P4-T8] verification passed | Phase 4 |
| AC4 | [P5-T4] CI evidence recorded (local half already held) | Phase 5 |
| AC5 | [P5-T5] verification passed | Phase 5 |
| AC6 | [P5-T4] verification passed | Phase 5 |
| AC8 | [P4-T6] plus [P5-T4] completed the (c) component | Phase 5 |
| AC11 | [P6-T1] component checklist verified | Phase 6 |

## Unmet Criteria

**None.** All eleven acceptance criteria are verified with cited evidence and checked off in `spec.md`. No gap is documented because no gap exists.

## Recorded Follow-Ups (not AC gaps)

These are documented in the spec's Rollout & Follow-up section as deliberate out-of-scope items, not unmet criteria:

1. Remove the now-unused root devDependencies `@vscode/test-cli`, `@vscode/test-electron`, `@types/mocha` and regenerate `package-lock.json` — owned by the sibling dependency/lockfile orchestration against the same base commit.
2. Optional cleanup of root extension-manifest vestiges (`publisher`, `displayName`, `engines.vscode`, `vscode:prepublish`, `@types/vscode`) and the `.gitignore` `.vscode-test/` entry — same ownership constraint.
3. Post-merge runtime verification of direct `gh workflow run _root-typescript-tests.yml --ref main`, which is unavailable until the workflow lands on the default branch (see [P5-T5]).
4. If the new check should become a required status check, follow the procedure in `.github/workflows/README.md`.

Output Summary: All eleven acceptance criteria (AC1–AC11) were verified individually against named evidence artifacts and all eleven are **PASS**. AC4 required both a local and a CI half; both are satisfied, with CI providing explicit `PASS tests/unit/vscode-test-removal.test.ts` lines on both operating systems. AC11 was verified component-by-component against the spec's Scope Decision section. All eleven checkboxes in `spec.md` are now `- [x]` with criterion text unmodified. No acceptance criterion is unmet; four items are recorded as deliberate, documented follow-ups rather than gaps.
