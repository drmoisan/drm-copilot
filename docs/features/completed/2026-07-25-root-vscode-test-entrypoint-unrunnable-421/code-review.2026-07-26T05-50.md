# Code Review: Root vscode-test Entry-Point Repair (#421)

---

**Review Date:** 2026-07-26
**Reviewer:** feature-review agent (Claude)
**Feature Folder:** `docs/features/active/2026-07-25-root-vscode-test-entrypoint-unrunnable-421`
**Feature Folder Selection Rule:** Single active folder whose suffix matches the issue number (#421) referenced by the branch and all commits.
**Base Branch:** `origin/main` (merge base `fb483b8468204e4385b5583c3b3ec4c0a987eede`)
**Head Branch:** `bug/vscode-test-integration-entrypoint` @ `852075346e7068435fb2c9d9744e9892fb789260`
**Review Type:** Initial review

---

## Executive Summary

This branch fixes issue #421 (repository-root `npm test` and `npm run test:integration` unconditionally exit 1 inside `@vscode/test-cli` because no `.vscode-test.*` config exists). The implementation delta is small and surgical: the root `package.json` `scripts` block is the only `package.json` key changed (verified by per-key comparison against base); a 78-line jest regression guard is added at `tests/unit/vscode-test-removal.test.ts`; and a 30-line reusable CI workflow `_root-typescript-tests.yml` is added and wired into `ci.yml` (additive job, no renames) with a README dispatch-table update. The remaining 28 changed files are feature-folder docs and canonical evidence.

Evidence reviewed: the full branch diff against `fb483b84`, the regenerated PR-context summary/appendix, the executor's baseline/qa-gates/regression-testing evidence, an independent reviewer re-run of the full root TypeScript toolchain (all stages exit 0, 170 suites / 2038 tests, coverage 97.01% line / 89.07% branch), and an independently dispatched CI run 30189725327 at the current branch head (conclusion `success`, 16/16 jobs, guard suite `PASS` on both OS legs). Implementation quality is high: the guard test is deterministic, typed, suppression-free, and follows established repo conventions; the workflow mirrors the existing `_drm-copilot-extension-tests.yml` model exactly.

**What changed:**
- `package.json`: `"test": "node run-jest.cjs"`; `test:integration` and `compile:integration-tests` deleted; `pretest` trimmed to `npm run compile && npm run lint`; `.vscode-test.mjs` removed from both prettier glob lists. All other keys byte-identical to base.
- `tests/unit/vscode-test-removal.test.ts` (new): two negative-path guards — no script value contains `vscode-test`; none of the five dead config files exists at the root.
- `.github/workflows/_root-typescript-tests.yml` (new): `workflow_call` + `workflow_dispatch`, windows-latest + ubuntu-latest matrix, checkout@v7, setup-node@v7 (node 20, npm cache on root lockfile), `npm ci`, `npm test`.
- `.github/workflows/ci.yml`: one additive `root-typescript-tests` job. `.github/workflows/README.md`: table row + count.

**Top 3 risks:**
1. The in-repo green-run evidence artifact cites run 30189336124 at the prior head `df874e81`; the head-matching run 30189725327 obtained during this review exists on GitHub but is recorded only in the review artifacts, not in `evidence/qa-gates/`. Residual risk is documentation freshness only (Info).
2. Root `test` and `test:unit` are now duplicate definitions of `node run-jest.cjs`; a future edit could change one and silently diverge the other. The guard does not assert their equality (Nit).
3. Local `npm test` remains broken in dot-directory worktrees (#414 Condition 3, pre-existing, out of scope here); developers in such worktrees must use the documented path-independent invocation.

**PR readiness recommendation:** **Go** — all toolchain stages pass on independent re-run, the head-matching CI run is green, and no finding exceeds Info/Nit severity.

---

## Findings Table

| Severity | File | Location | Finding | Recommendation | Rationale | Evidence |
|---|---|---|---|---|---|---|
| Info | `docs/features/active/2026-07-25-root-vscode-test-entrypoint-unrunnable-421/evidence/qa-gates/ci-green-run-root-typescript-tests.2026-07-26T05-40.md` | Run Identification table | The recorded green run (30189336124) is against head `df874e81`, which was superseded by the docs-only evidence commit `85207534`; the strict `modified-workflow-needs-green-run` wording requires a head-matching run. | No code change needed. The reviewer dispatched run 30189725327 at head `85207534` (conclusion `success`, 16/16 jobs, guard `PASS` on both OS legs); it is recorded in `policy-audit.2026-07-26T05-50.md` §3E. The PR author may cite run 30189725327 in the PR description. | This recording pattern is inherently one-commit-behind whenever run evidence is committed to the branch; the head-matching dispatch closes the gap without a remediation cycle. | `gh run view 30189725327 --json status,conclusion,headSha` → `success` @ `852075346e…`; `git diff df874e81..85207534 --name-only` → docs only |
| Nit | `package.json` | `scripts.test`, `scripts.test:unit` | `test` and `test:unit` are duplicate literal definitions of `node run-jest.cjs`; a future edit to one could silently diverge them. | Optional follow-up: define `"test": "npm run test:unit"` (aliasing) or extend the guard to assert equality. Intentional per spec ("test == test:unit"), so acceptable as-is. | Duplicate literals invite drift; low impact because the guard still blocks any `vscode-test` reintroduction. | `package.json` diff vs `fb483b84`; spec.md Technical specifications ("test == test:unit == node run-jest.cjs") |
| Info | `.claude/rules/typescript.md` | Toolchain §4, Testing Standards | Rule file names Vitest as the required test framework, but the repository's actual root harness is jest/ts-jest (all 170 suites, `run-jest.cjs`); the new guard correctly uses `@jest/globals` per repo convention. | Pre-existing repository-wide divergence; file a docs/rules alignment follow-up outside this workstream (rule files are policy documents and forbidden to modify here). | A reviewer applying the rule literally would flag every suite in the repo; the divergence predates this branch. | `.claude/rules/typescript.md` lines 16, 42; `git diff --name-only fb483b84..85207534 -- jest.config.cjs run-jest.cjs` → empty |
| Info | `.claude/skills/feature-review-workflow/SKILL.md` | Policy Rules § `modified-workflow-needs-green-run` | The referenced supporting validator `scripts/feature-review/Test-ModifiedWorkflowNeedsGreenRun.ps1` does not exist in the repository (`scripts/feature-review/` absent); the rule had to be applied manually. | File a tooling follow-up to add the validator or correct the skill reference. Not attributable to this branch. | Missing referenced tooling degrades review determinism for every future workflow-modifying branch. | `find scripts -name "Test-ModifiedWorkflowNeedsGreenRun.ps1"` → no results |

No Blockers or Major findings.

---

## Implementation Audit

### TypeScript implementation audit

#### What changed well

- The guard test models the prior art (`2f67b888:tests/unit/vscode-test-removal.test.ts`) and covers both halves of the defect class: script-value reintroduction and dead-config-file reintroduction (all four `.vscode-test.*` variants plus `tsconfig.vscode-test.json`).
- `repositoryRoot` is derived from `__dirname` rather than `process.cwd()`, making the test invocation-location independent — important given the repo's known dot-directory worktree issues.
- Assertions compare arrays of offending names against `[]`, so failures name the exact offending script or file rather than reporting a bare boolean.
- Auto-discovery under the existing `testMatch` was proven with `--listTests` rather than asserted; zero jest-config changes were needed (and the forbidden files were verifiably untouched).

#### Type safety and maintainability

- Local `PackageJson` structural type; the single `as PackageJson` narrowing of `JSON.parse` output is the idiomatic minimal assertion for JSON ingestion. No `any`, no suppression comments (`eslint-disable`, `@ts-ignore`, `@ts-expect-error`: zero matches in the new file).
- 78 lines, one concern, kebab-case filename, conventional casing throughout.

#### Error handling and logging

- No production error paths changed. In the test, an unreadable or malformed `package.json` fails loudly via the thrown `readFileSync`/`JSON.parse` error, which is the correct fail-fast behavior for a guard.

### GitHub Actions implementation audit

#### What changed well

- `_root-typescript-tests.yml` is a faithful minimal instance of the established reusable pattern: both `workflow_call` and `workflow_dispatch` triggers, same action majors (`checkout@v7`, `setup-node@v7`), node 20, npm cache keyed on the root `package-lock.json` — mirroring `_drm-copilot-extension-tests.yml`.
- `ci.yml` wiring is purely additive; no existing check-run names change, so branch-protection required checks are unaffected.
- Per `.claude/rules/ci-workflows.md`: no `pwsh` steps, no deliberately-failing nested commands; both steps rely on default failure propagation, and the head-matching green run confirms correct exit-code behavior on both runner classes.

#### Error handling and logging

- Failure propagation is default and correct: a failing `npm ci` or `npm test` fails the step, the job, and the `ci.yml` orchestrator run.

### JSON (package.json) audit

- Scripts-block-only edit verified by per-key comparison against `fb483b84` (all nine other top-level keys byte-identical, including `devDependencies`, `dependencies`, `overrides`). The sibling-orchestration ownership boundary (dependencies/lockfile) is respected; `package-lock.json` is untouched.
- The removed `compile:integration-tests` script and the `pretest` trim eliminate the two "silent papering-over" behaviors identified in the root-cause analysis.

---

## Test Quality Audit

Automated evidence is strong and was independently reproduced: the reviewer re-ran format:check, lint, typecheck, and the full jest suite with coverage (all exit 0; 170/170 suites, 2038/2038 tests; 97.01% line / 89.07% branch — identical to the executor's recorded figures), and dispatched a fresh CI run at the current head confirming end-to-end `npm test` behavior on both OS legs. No verification gaps remain.

### Reviewed test and QA artifacts

- `tests/unit/vscode-test-removal.test.ts` — the new guard; deterministic, two focused negative-path invariants; verified passing solo, in the full local suite, and on both CI legs.
- `evidence/regression-testing/fail-before-npm-test.2026-07-26T05-06.md`, `fail-before-npm-test-integration.2026-07-26T05-07.md` — fail-before proof: both removed scripts exited non-zero inside `loadDefaultConfigFile` with the verbatim `@vscode/test-cli` error, establishing that zero tests were ever executed by them (no silent coverage loss).
- `evidence/baseline/baseline-test-coverage-root.2026-07-26T05-10.md` and `evidence/qa-gates/final-test-coverage-root.2026-07-26T05-29.md` — numeric baseline vs post-change coverage (identical; +1 suite, +2 tests); confirmed by reviewer re-run.
- `evidence/qa-gates/guard-test-local-run.2026-07-26T05-22.md` — `--listTests` discovery proof plus name-scoped execution proof; the per-suite `PASS` line limitation in local capture is documented and compensated by the CI logs, which do contain `PASS tests/unit/vscode-test-removal.test.ts` on both OSes.
- `evidence/qa-gates/boundary-inventory.2026-07-26T05-33.md` — forbidden-file and ownership-boundary inventory; reviewer re-verified the filtered diff is empty at the final head.
- `evidence/qa-gates/ci-green-run-root-typescript-tests.2026-07-26T05-40.md`, `ci-orchestrator-run.2026-07-26T05-41.md` — green run 30189336124 at `df874e81` (16/16 jobs); superseded for head-match purposes by reviewer-dispatched run 30189725327 at `85207534` (see Findings Table, Info).

### Quality assessment prompts

- **Determinism:** Guard reads only versioned files; no clock, RNG, network, or temp-file use; reviewer re-run reproduced identical results.
- **Isolation:** One invariant per test; no shared mutable state.
- **Speed:** Guard suite 0.29–0.32 s solo; full suite 6.3 s locally, <20 s per CI leg.
- **Diagnostics:** Failing assertions print the offending script/file names via array-vs-`[]` comparison.

---

## Security / Correctness Checks

| Check | Status | Evidence |
|---|---|---|
| No secrets in code | ✅ PASS | Diff inspection of all five implementation files: no credentials, tokens, or URLs beyond the public run URL in docs. Workflow uses no secrets and declares no elevated permissions. |
| No unsafe subprocess or command construction | ✅ PASS | No new subprocess code; npm scripts invoke fixed, repo-local commands (`node run-jest.cjs`); workflow steps are literal `npm ci` / `npm test` with no interpolated untrusted input. |
| Input validation at boundaries | ✅ PASS | Guard treats a missing `scripts` block as empty (`?? {}`) and fails loudly on unreadable/malformed `package.json`. |
| Error handling remains explicit | ✅ PASS | Removed scripts eliminated a misleading failure mode; `npm run test:integration` now yields npm's explicit missing-script error (honest state per spec). |
| Configuration / path handling is safe | ✅ PASS | `path.resolve(__dirname, "../..")` and `path.join` throughout; no string-concatenated paths; no path input from the environment. |
| Workflow supply-chain posture | ✅ PASS | Actions pinned to the same major tags as the existing model workflow (`@v7`); no new third-party actions introduced. |

---

## Research Log

No external research was required. All conclusions derive from the branch diff, repository policy files, feature-folder artifacts, local command re-runs, and GitHub Actions run metadata retrieved via `gh`.

---

## Verdict

The change is ready for normal PR flow. The implementation matches the spec exactly (scripts-block-only `package.json` edit, prior-art-modeled guard, convention-compliant CI wiring), every toolchain stage passes on independent re-run, coverage is unchanged at 97.01% line / 89.07% branch, forbidden-file and sibling-ownership boundaries are verifiably respected, and a green head-matching CI run (30189725327) satisfies the `modified-workflow-needs-green-run` policy. The four recorded findings are Info/Nit-severity documentation and follow-up items that do not block merge and are consistent with the **Go** recommendation above.
