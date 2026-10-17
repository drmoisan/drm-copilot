# Feature Audit: Extension test-tree type-check gate (#647)

---

**Audit Date:** 2026-10-02
**Feature Folder:** `docs/features/active/2026-09-07-test-tree-typecheck-not-gated-647`
**Base Branch:** `origin/main`
**Head Branch:** `bug/test-tree-typecheck-not-gated-647`
**Work Mode:** `full-bug`
**Audit Type:** Initial acceptance review

---

## Scope and Baseline

- **Base branch:** `origin/main` (commit `1b1e349f1d0fb8b00eb69a809ef380fcc6eb35b9`)
- **Head branch/commit:** `bug/test-tree-typecheck-not-gated-647` (commit `8a40275c2b43ea88eae0384aea1b873af329f7df`)
- **Merge base:** `1b1e349f1d0fb8b00eb69a809ef380fcc6eb35b9` (`git merge-base HEAD origin/main`; equals the base tip, so `<base>` in spec.md resolves to this SHA)
- **Evidence sources:**
  - Primary: `artifacts/pr_context.summary.txt` (regenerated 2026-10-02 04:06:28 UTC, `Head SHA: 8a40275c...`)
  - Secondary baseline diff: `artifacts/pr_context.appendix.txt` (same generation timestamp and head SHA; pair identity and head binding verified)
  - Feature evidence: `docs/features/active/2026-09-07-test-tree-typecheck-not-gated-647/evidence/{baseline,qa-gates,regression-testing,other}/`
  - Additional evidence: reviewer re-runs at head (tsc, typecheck, lint, Prettier, Jest, actionlint, `gh run list`, `gh pr list`), and `extensions/drm-copilot/coverage/lcov.info`
- **Feature folder used:** `docs/features/active/2026-09-07-test-tree-typecheck-not-gated-647`
- **Requirements source:** `spec.md` (`## Acceptance Criteria`, AC-1..AC-15)
- **Work mode resolution note:** `issue.md` carries `- Work Mode: full-bug`; per the acceptance-criteria tracking contract, `spec.md` is the sole AC source. No `user-story.md` exists, consistent with full-bug.
- **Scope note:** PR context artifacts were absent at review start and were regenerated with `poetry run python -m scripts.dev_tools.pr_context.collector --base origin/main --head HEAD`. AC-15 depends on a PR that does not yet exist; per the caller's instruction it is evaluated as UNVERIFIED-PENDING-CI and is treated as non-blocking for the AC evaluation. The separate policy rule `modified-workflow-needs-green-run` is recorded in the policy audit as PA-2 (`awaiting_ci`).

---

## Acceptance Criteria Inventory

**Authoritative AC source files for this run:**
- `docs/features/active/2026-09-07-test-tree-typecheck-not-gated-647/spec.md` — only source (checkbox-based)

### Acceptance criteria

1. AC-1 `node extensions/drm-copilot/node_modules/typescript/bin/tsc -p extensions/drm-copilot/tsconfig.jest.json --noEmit` exits 0, and its combined output contains no line matching `error TS`. The command, exit code, and output are recorded in `evidence/qa-gates/`.
2. AC-2 `npm --prefix extensions/drm-copilot run typecheck` exits 0, and its output shows that the `typecheck:test` script ran. The command, exit code, and output are recorded in `evidence/qa-gates/`.
3. AC-3 In `extensions/drm-copilot/package.json`, `scripts["typecheck:test"]` equals `tsc -p tsconfig.jest.json --noEmit` and `scripts.typecheck` equals `tsc -p ./ --noEmit && npm run typecheck:test`. Verified by the tests `typecheck script chains typecheck:test` and `typecheck:test script checks tsconfig.jest.json` in `extensions/drm-copilot/test/package-typecheck-script.test.ts`.
4. AC-4 `git diff <base> -- extensions/drm-copilot/package.json` changes no script other than `typecheck` and the added `typecheck:test`. `compile`, `build`, `test`, `test:unit`, and `test:coverage` are byte-identical to `<base>`. Also verified by the test `compile and build do not reference tsconfig.jest.json`.
5. AC-5 `.github/workflows/_drm-copilot-extension-tests.yml` has a step that runs `npm --prefix extensions/drm-copilot run typecheck`, placed after `Install extension dependencies` and before `Run extension unit/integration tests`. Verified by the test `extension tests workflow runs the typecheck script before tests` and by `git diff <base> -- .github/workflows/_drm-copilot-extension-tests.yml`, which shows only the added step.
6. AC-6 `npm --prefix extensions/drm-copilot run test -- test/package-typecheck-script.test.ts` exits 0 and reports all tests in `describe("extension type-check gate wiring")` as passed. A fail-before run from before the `package.json` and workflow edits shows the AC-3 and AC-5 tests failing. Both runs are recorded in `evidence/regression-testing/`.
7. AC-7 `git diff --name-only <base> -- extensions/drm-copilot/src` lists no path other than `extensions/drm-copilot/src/lib/codex-native-converter/models.ts` and `extensions/drm-copilot/src/lib/codex-native-converter/index.ts`. In `git diff -U0 <base> -- extensions/drm-copilot/src`, every removed line has a matching added line that differs only by an inserted `type ` modifier on an export specifier.
8. AC-8 `npm --prefix extensions/drm-copilot run compile` exits 0.
9. AC-9 (#645 R20) In `extensions/drm-copilot/test/lib/validate/orchestration-handoff-materializer-path-boundary.test.ts`, the `TransitionPreparedOrchestrationRequest` literal spreads `INDEPENDENT_CONTEXT` with `expectedWorkspaceRoot` overridden to the scenario's `workspaceRoot`. AC-1 reports no diagnostic for this file. `npm --prefix extensions/drm-copilot run test -- test/lib/validate/orchestration-handoff-materializer-path-boundary.test.ts` exits 0, with the same number of passing tests as the same command at `<base>` and zero failures.
10. AC-10 `npm --prefix extensions/drm-copilot run test` exits 0. The total number of passing tests is at least the number at `<base>` plus the tests added in `package-typecheck-script.test.ts`. `git diff -U0 <base> -- extensions/drm-copilot/test` has no added line matching `\.(skip|only)\(|\bx(it|describe|test)\(`.
11. AC-11 `npm --prefix extensions/drm-copilot run test:coverage` exits 0, so the `jest.config.cjs` `coverageThreshold` (line >= 85%, branch >= 75%) is met. The text-summary output is recorded in `evidence/qa-gates/`, and it shows line and branch percentages no lower than the same command at `<base>`.
12. AC-12 The added lines in `git diff -U0 <base> -- extensions/drm-copilot` (lines starting with `+`, excluding `+++` headers) contain no match for `@ts-ignore|@ts-expect-error|@ts-nocheck|eslint-disable|:\s*any\b|\bas\s+any\b|<any>|\bany\[\]`.
13. AC-13 `git diff --numstat <base> -- extensions/drm-copilot/test/extension.workflow-commands.test.ts` reports an added-line count less than or equal to the deleted-line count. Every other `.ts` file listed by `git diff --name-only --diff-filter=AM <base> -- extensions/drm-copilot` has at most 500 lines at HEAD, measured with `(Get-Content <path>).Count`.
14. AC-14 `npm --prefix extensions/drm-copilot run lint` exits 0. From `extensions/drm-copilot`, `npx prettier --check "src/**/*.ts" "test/**/*.ts" "*.json" "*.cjs"` exits 0.
15. AC-15 The PR's `ci.yml` run at the branch head completes with conclusion `success` for every matrix leg of `drm-copilot-extension-tests`, and each leg includes the step `Type-check extension source and test tree`. Verified with `gh run view <run-id> --json jobs`, and the run ID is recorded in `evidence/qa-gates/`.

---

## Acceptance Criteria Evaluation

| # | Criterion | Status | Evidence | Verification command(s) | Notes |
|---|-----------|--------|----------|--------------------------|-------|
| 1 | AC-1 jest-config tsc exits 0, no `error TS` | PASS | Reviewer re-run: `TSC_EXIT=0`, `grep -c "error TS"` = 0. Executor: `evidence/qa-gates/final-tsc-jest.2026-10-01T23-18.md` and `.log`. | `node extensions/drm-copilot/node_modules/typescript/bin/tsc -p extensions/drm-copilot/tsconfig.jest.json --noEmit` | Baseline 355 diagnostics across 71 files (`evidence/baseline/tsc-jest-baseline.2026-10-01T23-18.md`). |
| 2 | AC-2 `typecheck` exits 0 and runs `typecheck:test` | PASS | Reviewer re-run: exit 0; output contains `> tsc -p tsconfig.jest.json --noEmit` banner. Executor: `evidence/qa-gates/final-typecheck.2026-10-01T23-18.md`. | `npm --prefix extensions/drm-copilot run typecheck` | — |
| 3 | AC-3 script values | PASS | `package.json` lines 209-210 at head match exactly; tests 1 and 2 of `package-typecheck-script.test.ts` pass (`pass-after`). | `git diff 1b1e349f...HEAD -- extensions/drm-copilot/package.json`; Jest run | — |
| 4 | AC-4 no other script changed | PASS | Diff hunk `@@ -206,7 +206,8 @@` changes only `typecheck` and adds `typecheck:test`; `compile`, `build`, `test`, `test:unit`, `test:coverage` lines are context/unchanged. Test 3 passes. Executor: `evidence/qa-gates/ac4-package-json-diff.2026-10-01T23-18.md`. | `git diff 1b1e349f...HEAD -- extensions/drm-copilot/package.json` | — |
| 5 | AC-5 workflow step placement | PASS | Diff hunk `@@ -26,5 +26,8 @@` adds only the named step between install and test. Test 4 passes. actionlint exit 0. | `git diff 1b1e349f...HEAD -- .github/workflows/_drm-copilot-extension-tests.yml`; `actionlint ...` | — |
| 6 | AC-6 regression test pass and fail-before | PASS | `evidence/regression-testing/fail-before.2026-10-01T23-18.md` (exit 1; tests 1, 2, 4 failed; test 3 passed) and `pass-after.2026-10-01T23-18.md` (exit 0; 4 passed). Reviewer full-suite run includes the file. | `npm --prefix extensions/drm-copilot run test -- test/package-typecheck-script.test.ts` | Fail-before shows the AC-3 and AC-5 tests failing as required. |
| 7 | AC-7 src diff limited to `type` modifiers | PASS | `git diff -U0 1b1e349f...HEAD -- extensions/drm-copilot/src`: two files; 9 removed lines, each with a matching added line differing only by `type `. | `git diff --name-only 1b1e349f...HEAD -- extensions/drm-copilot/src`; `git diff -U0 ...` | — |
| 8 | AC-8 compile exits 0 | PASS | `evidence/qa-gates/final-compile.2026-10-01T23-18.md` (exit 0). | `npm --prefix extensions/drm-copilot run compile` | Not re-run by the reviewer; production edits are erased at emit and `tsc -p ./` (the first compile leg) was re-run via `typecheck` with exit 0. |
| 9 | AC-9 R20 request literal | PASS | Head file contains `...INDEPENDENT_CONTEXT,` and `expectedWorkspaceRoot: "C:/workspace",`; 0 diagnostics for the file; 6 passed / 0 failed, equal to base (`evidence/qa-gates/ac9-path-boundary.2026-10-01T23-18.md`, `evidence/baseline/jest-path-boundary.2026-10-01T23-18.md`). | `npm --prefix extensions/drm-copilot run test -- test/lib/validate/orchestration-handoff-materializer-path-boundary.test.ts` | — |
| 10 | AC-10 full suite and no skip/only | PASS | Reviewer re-run: exit 0, 250 suites, 3786 passed = 3782 (base) + 4. Added-line scan: zero matches for skip/only/x-prefixed forms. | `npm --prefix extensions/drm-copilot run test`; added-line grep on `git diff -U0` | The criterion's numeric gate is met. Code review CR-1 records that one retained test lost its scenario; this does not change the AC-10 verdict but blocks readiness. |
| 11 | AC-11 coverage threshold and no regression | PASS | `evidence/qa-gates/final-coverage.2026-10-01T23-18.md`: 97.07% lines, 91.35% branches, exit 0; baseline identical. Reviewer lcov aggregate: 50618/52144 lines, 7391/8090 branches. | `npm --prefix extensions/drm-copilot run test:coverage` (executor); lcov inspection (reviewer) | — |
| 12 | AC-12 no suppressions or `any` in added lines | PASS | Reviewer scan of added lines for the AC pattern plus the bare word `any`: zero matches. | `git diff -U0 1b1e349f...HEAD -- extensions/drm-copilot` piped to `grep -E` | — |
| 13 | AC-13 file-size limits | PASS | `extension.workflow-commands.test.ts` numstat empty (unchanged). All 64 changed/added `.ts` files <= 500 lines (`grep -c ''`); maximum 500 for two files. | `git diff --numstat ...`; `grep -c ''` per file | Two files have zero headroom (code review CR-3). |
| 14 | AC-14 lint and Prettier | PASS | Reviewer re-runs: lint exit 0; Prettier check exit 0 ("All matched files use Prettier code style!"). | `npm --prefix extensions/drm-copilot run lint`; `npx --prefix extensions/drm-copilot prettier --check ...` | Reviewer ran Prettier from the repository root with prefixed globs over the same file set. |
| 15 | AC-15 PR `ci.yml` green on every extension-tests leg | UNVERIFIED | No PR and no workflow run exist for head 8a40275c (`gh pr list` and `gh run list` returned `[]`). | `gh run view <run-id> --json jobs` (after PR opens) | UNVERIFIED-PENDING-CI; non-blocking for this AC evaluation per caller instruction. |

---

## Summary

**Overall Feature Readiness:** NEEDS REVISION

**Criteria summary:**
- **PASS:** 14 criteria
- **PARTIAL:** 0 criteria
- **UNVERIFIED:** 1 criterion (AC-15, pending CI)
- **FAIL:** 0 criteria

**Top gaps preventing PASS:**

1. Code review CR-1 / policy audit PA-1 (blocking, `autonomous`): `test/lib/validate/build-validate-orchestration-service-call-input.test.ts` lines 82-102 no longer exercise the explicit-undefined input that the test title describes. No AC directly covers this, but it is a blocking review finding.
2. AC-15 and policy rule `modified-workflow-needs-green-run` (PA-2, `awaiting_ci`): the PR `ci.yml` run has not occurred.

**Recommended follow-up verification steps:**

1. After CR-1 is fixed, re-run `npm --prefix extensions/drm-copilot run test -- test/lib/validate/build-validate-orchestration-service-call-input.test.ts`, `npm --prefix extensions/drm-copilot run typecheck`, `npm --prefix extensions/drm-copilot run lint`, the Prettier check, and the AC-12 added-line scan; confirm the full suite still reports at least 3786 passing tests.
2. Open the PR, wait for `ci.yml`, run `gh run view <run-id> --json jobs`, confirm both `drm-copilot-extension-tests` legs conclude `success` and list the step `Type-check extension source and test tree`, record the run ID in `evidence/qa-gates/`, and check off AC-15.

---

## Acceptance Criteria Check-off

Per the acceptance-criteria tracking rules:
- Criteria evaluated as **PASS** may be checked off in the authoritative source file(s) if they are represented as markdown checkboxes and are not already checked.
- Criteria evaluated as **PARTIAL**, **FAIL**, or **UNVERIFIED** must remain unchecked.

### AC Status Summary

- Source: `docs/features/active/2026-09-07-test-tree-typecheck-not-gated-647/spec.md`
- Total AC items: 15
- Checked off (delivered): 14
- Remaining (unchecked): 1
- Items remaining: AC-15 The PR's `ci.yml` run at the branch head completes with conclusion `success` for every matrix leg of `drm-copilot-extension-tests`, and each leg includes the step `Type-check extension source and test tree`. Verified with `gh run view <run-id> --json jobs`, and the run ID is recorded in `evidence/qa-gates/`.

| Source File | Total AC | Checked (PASS) | Unchecked | Notes |
|-------------|----------|----------------|-----------|-------|
| `spec.md` | 15 | 14 | 1 | Checkbox-backed. AC-1..AC-14 were already checked by the executor in commit 8a40275c; this review confirms each as PASS. AC-15 remains unchecked (UNVERIFIED-PENDING-CI). |

No source-file checkbox change was made by this review: every PASS item was already checked, and the one non-PASS item is already unchecked.
