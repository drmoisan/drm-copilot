# Code Review: Prettier format check on docs fixtures (#1179)

---

**Review Date:** 2026-11-14
**Reviewer:** feature-review agent
**Feature Folder:** `docs/features/active/2026-11-14-prettier-format-check-fails-on-docs-fixtures-1179`
**Feature Folder Selection Rule:** named by the caller; matches branch `bug/prettier-fixture-format-check` and issue #1179
**Base Branch:** `main` (resolved `origin/main` at `1d9f14e2c595b0065ad42a24188620f320ac514c`, equal to the merge base)
**Head Branch:** `bug/prettier-fixture-format-check` at `7445a846ca2662371f3c177aca33e7a0eaad6755`
**Review Type:** Initial review, concurrent with CI on the same head (PR #1180)

---

## Executive Summary

The review covers the full branch diff from the merge base to the head (27 files, 1203 insertions, 90 deletions). Production-relevant content is three Prettier-formatted JSON fixtures and a three-line workflow step. The reviewer parsed each fixture from `origin/main` and from the head and compared the SHA-256 of the canonical JSON string: all three are equal, so the reformat is semantically neutral. The workflow step sits after `npm ci` and before `npm test`, has no condition, and so runs on both matrix legs. `.prettierignore`, `package.json`, `ci.yml`, and Prettier configuration are untouched.

No blocking finding. CI was pending on the head at review time.

**What changed:**
Three fixtures under `tests/scripts/claude-lib/docs/fixtures/` reformatted (`python-native-corpus.json` accounts for most of the 673-line diff); step "Check root formatting" added to `.github/workflows/_root-typescript-tests.yml`; feature documents, research, plan, and evidence; one promoted lifecycle record.

**Top 3 risks:**
1. The Windows leg has not yet reported; line-ending drift is unlikely because `.gitattributes` sets `eol=lf` for all files except named exceptions (Info).
2. The local docs Pester run was a single scoped process, not the parallel runner; the CI `poshqc` shards on this head are the parallel full-suite gate (Info, disclosed process deviation).
3. The new CI step makes every later unformatted file under the Prettier globs fail the PR; this is the intended guard (Info).

**PR readiness recommendation:** **Ready**, conditional on a green CI run on this head.

---

## Findings Table

| Severity | File | Location | Finding | Recommendation | Rationale | Evidence |
|---|---|---|---|---|---|---|
| Info | `.github/workflows/_root-typescript-tests.yml` | step "Check root formatting" | The step runs before `npm test`, so a format failure stops the job before the jest suite and hides test results in the same run. | No change required. | Fail-fast ordering matches the spec ("after Install root dependencies"); format failures are cheap to fix. | Workflow diff |
| Info | `evidence/qa-gates/final-pester-docs-consumers.2026-11-14T09-37.md` | process note | The local Pester run used one pwsh process scoped to the docs folder because `Invoke-PoshQCParallelTest` cannot be scoped to a folder. | No change required; confirm the CI `poshqc` shards are green on this head. | Disclosed in the evidence and in spec AC 4 verification; the full-suite gate is parallel in CI. | Evidence artifact; `gh pr checks 1180` |

No Blocker, Major, or Minor finding. No covered source file changed, so no file-size Warning applies (JSON and Markdown are exempt, the YAML file is not a covered extension).

---

## Implementation Audit

### Python implementation audit

#### What changed well

- No Python file changed; `test_docs_python_native_corpus.py` passes unchanged (4 passed).

#### Typing and API notes

- Not applicable.

#### Error handling and logging

- Not applicable.

### TypeScript implementation audit

#### What changed well

- No TypeScript file changed. The check that the step runs is the existing `format:check` script, which has the globs `src/**`, `tests/**`, and the named root configs.

#### Type safety and maintainability

- Not applicable.

#### Error handling and logging

- A non-zero Prettier exit fails the step and the job (default step behavior).

### PowerShell implementation audit

#### What changed well

- No PowerShell file changed. The docs consumers (2360 tests) pass unchanged in the executor's scoped run.

#### API and safety notes

- Not applicable.

#### Error handling and logging

- Not applicable.

### Workflow and fixture audit

- The step is a fixed `npm run format:check`; no interpolation of untrusted input.
- The job already runs `npm ci` first, so Prettier is available from root devDependencies.
- All three fixtures end with a newline and contain no carriage return at the head.
- The baseline artifact shows the pre-change check flagged exactly these three files, and the regression artifact shows exit 0 afterward, so no additional file needed formatting.

---

## Test Quality Audit

No test was added. The existing consumers decode the fixtures semantically (per the research record and the executor's contract task checks), and the reviewer's equality probe confirms the decoded values are unchanged.

### Reviewed test and QA artifacts

- `evidence/baseline/fixture-json-hash.2026-11-14T08-55.md` and `evidence/regression-testing/fixture-json-equality.2026-11-14T09-09.md`: three equal hashes, reproduced by the reviewer against `origin/main` blobs.
- `evidence/baseline/format-check.2026-11-14T08-55.md` (exit 1, three files) and `evidence/regression-testing/format-check.2026-11-14T09-10.md` (exit 0).
- `evidence/qa-gates/final-pester-docs-consumers.2026-11-14T09-37.md` and `evidence/qa-gates/final-pytest-docs-native-corpus.2026-11-14T09-27.md`.

### Quality assessment prompts

- **Determinism:** the fixtures are static data.
- **Isolation:** not applicable.
- **Speed:** not applicable.
- **Diagnostics:** not applicable.

---

## Security / Correctness Checks

| Check | Status | Evidence |
|---|---|---|
| No secrets in code | ✅ PASS | No credential or token literal in the diff. |
| No unsafe subprocess or command construction | ✅ PASS | One fixed npm script in a workflow step; no expression interpolation. |
| Input validation at boundaries | N/A | No input handling added. |
| Error handling remains explicit | ✅ PASS | A failing format check fails the step. |
| Configuration / path handling is safe | ✅ PASS | No path handling added; no absolute host path in the feature artifacts. |

---

## Research Log

No external research was required. The repository research record `research/research.2026-11-14T00-00.md` was read for the consumer analysis.

---

## Verdict

The change is a minimal, semantically neutral fixture reformat plus one CI step. The whole-branch diff has no Blocker, Major, or Minor finding. The branch is ready once CI is green on the reviewed head.
