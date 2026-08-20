# Final QC Loop Ledger [P7-T10]

Timestamp: 2026-08-20T20-42

One row per stage per loop iteration per language. Every stage that was executed carries a **numeric** exit code; `SKIPPED` is not used for any planned command task in this plan.

---

## TypeScript Loop

| Iteration | Stage | Task | Command | EXIT_CODE | Files rewritten | Outcome |
| --- | --- | --- | --- | --- | --- | --- |
| 1 | 1 Format | P7-T1 | `npx prettier --write "src/**/*.ts" "test/**/*.ts" "*.json" "*.cjs"` | 0 | **1** (`potential-to-issue-service-call.ts`) | Rewrote a file → **restart from step 1** |
| 1 | 2–5 | — | — | not reached | — | Loop restarted before lint |
| 2 | 1 Format | P7-T1 | `npx prettier --write ...` | 0 | 0 | Clean; also confirmed by `--check` (exit 0, "All matched files use Prettier code style!") |
| 2 | 2 Lint | P7-T2 | `npx eslint --no-error-on-unmatched-pattern src test` | 0 | 0 | 0 errors, 0 warnings |
| 2 | 3 Type-check | P7-T3 | `npx tsc -p ./ --noEmit` | 0 | 0 | 0 type errors |
| 2 | 4 Architecture | P7-T4 | `find . -name ".dependency-cruiser.cjs" -not -path "*/node_modules/*"` | 0 | 0 | No configuration exists in this repository; executed verification, not a skip |
| 2 | 5 Test + coverage | P7-T5 | `npm run test:coverage` | 0 | 0 | 195/195 suites, 2654/2654 tests; Lines 96.66%, Branches 90.04% |
| 3 | 1 Format | P7-T1 | `npx prettier --write ...` | 0 | 0 | Re-verification pass (see below) |
| 3 | 2 Lint | P7-T2 | `npx eslint ...` | 0 | 0 | 0 errors, 0 warnings |
| 3 | 3 Type-check | P7-T3 | `npx tsc -p ./ --noEmit` | 0 | 0 | 0 type errors |
| 3 | 4 Architecture | P7-T4 | `find . -name ".dependency-cruiser.cjs" ...` | 0 | 0 | Unchanged result |
| 3 | 5 Test + coverage | P7-T5 | `npm run test:coverage` | 0 | 0 | 195/195 suites, 2654/2654 tests; Lines 96.66%, Branches 90.04% — identical to iteration 2 |

**TypeScript final iteration: 3.** Every stage completed with exit code 0 and no file rewrite, in a single consecutive pass.

### Why a TypeScript iteration 3 was run

Iteration 2 was already a clean consecutive pass. Iteration 3 was run because a source file elsewhere in the repository changed **after** iteration 2 finished: the Python loop's remediation copied `.claude/skills/feature-promotion-lifecycle/SKILL.md` into the bundled payload at `extensions/drm-copilot/resources/claude-customizations/.claude/skills/feature-promotion-lifecycle/SKILL.md`.

That file is outside every TypeScript stage's input set — it is Markdown under `resources/`, matched by none of the prettier globs (`src/**/*.ts`, `test/**/*.ts`, `*.json`, `*.cjs`), by neither eslint path (`src`, `test`), nor by the `tsconfig` project — so it could not have affected the result. Iteration 3 was run anyway rather than reasoning the claim through, so that "a single consecutive clean pass" is backed by an execution taken against the final tree instead of an argument about scope. It reproduced iteration 2 exactly.

The Python-only change made in iteration 4 (adding `test_create_minor_audit_folder_copies_promoted_potential` to `tests/scripts/dev_tools/test_new_active_feature_folder_part5.py`) likewise lies outside every TypeScript stage's input set, and no TypeScript-scoped file changed after iteration 3 completed.

---

## Python Loop

| Iteration | Stage | Task | Command | EXIT_CODE | Files rewritten | Outcome |
| --- | --- | --- | --- | --- | --- | --- |
| 1 | 1 Format | P7-T6 | `poetry run black .` | 0 | **1** (`test_new_active_feature_folder_part5.py`) | Reformatted a file → **restart from step 1** |
| 1 | 2–4 | — | — | not reached | — | Loop restarted before lint |
| 2 | 1 Format | P7-T6 | `poetry run black .` | 0 | 0 | Clean (438 files left unchanged) |
| 2 | 2 Lint | P7-T7 | `poetry run ruff check .` | 0 | 0 | 0 violations |
| 2 | 3 Type-check | P7-T8 | `poetry run pyright` | 0 | 0 | 0 errors, 0 warnings, 0 informations |
| 2 | 4 Test + coverage | P7-T9 | `poetry run pytest --cov --cov-branch --cov-report=term-missing` | **1** | 0 | **FAIL** — 1 failed, 4060 passed. Bundle-mirror contract broken by the P5-T4 skill edit → remediation → **restart from step 1** |
| 3 | 1 Format | P7-T6 | `poetry run black .` | 0 | 0 | Clean |
| 3 | 2 Lint | P7-T7 | `poetry run ruff check .` | 0 | 0 | 0 violations |
| 3 | 3 Type-check | P7-T8 | `poetry run pyright` | 0 | 0 | 0 errors |
| 3 | 4 Test + coverage | P7-T9 | `poetry run pytest --cov --cov-branch --cov-report=term-missing` | 0 | 0 | Passed (4061), but **changed-line coverage regression**: 2 newly added statements uncovered → remediation → **restart from step 1** |
| 4 | 1 Format | P7-T6 | `poetry run black .` | 0 | 0 | Clean (438 files left unchanged) |
| 4 | 2 Lint | P7-T7 | `poetry run ruff check .` | 0 | 0 | 0 violations |
| 4 | 3 Type-check | P7-T8 | `poetry run pyright` | 0 | 0 | 0 errors, 0 warnings, 0 informations |
| 4 | 4 Test + coverage | P7-T9 | `poetry run pytest --cov --cov-branch --cov-report=term-missing` | 0 | 0 | **PASS** — 4062 passed, 0 failed, 5 skipped; Lines 92.60%, Branches 89.81% |

**Python final iteration: 4.** Every stage completed with exit code 0 and no file rewrite, in a single consecutive pass.

### Restart causes in detail

**Iteration 1 → 2 (formatting).** Black collapsed a multi-line path-join expression in the newly created `test_new_active_feature_folder_part5.py`. Purely cosmetic.

**Iteration 2 → 3 (test failure).** `test_push_down_claude_resource_contracts.py::test_bundled_claude_payload_contains_all_repo_runtime_contracts` failed with `Bundle content differs from repo for: .claude\skills\feature-promotion-lifecycle\SKILL.md`. The repository enforces a byte-identical mirror between each repo `.claude/**` file and its bundled copy under `extensions/drm-copilot/resources/claude-customizations/.claude/**`, and P5-T4 had edited only the repo copy. Remediation: copied the edited file to its bundled path; `diff` between the two now exits 0. This was a genuine defect introduced by this change — the baseline run was green at 4059 passed / 0 failed.

**Iteration 3 → 4 (changed-line coverage regression).** The stage exited 0, but two newly added statements in `scripts/dev_tools/new_active_feature_folder_flow.py` were uncovered: `:236` (`filesystem.copy_file(...)`, minor-audit branch) and `:298` (the minor-audit `Copied potential file to ...` emission). The Python minor-audit COPY arm had no test. `.claude/rules/general-unit-test.md` forbids reducing coverage on changed lines and `.claude/rules/python.md` makes it a blocking finding, so a zero exit code alone did not close the loop. Remediation: added `test_create_minor_audit_folder_copies_promoted_potential`. The per-file missing and partial counts returned to their baseline values of 12 and 6.

---

## Final-Iteration Confirmation

| Language | Final iteration | Stages completed consecutively, all clean | Evidence artifact |
| --- | --- | --- | --- |
| TypeScript | 3 | Format (0) → Lint (0) → Type-check (0) → Architecture (0) → Test+coverage (0) | `final-ts-prettier.2026-08-20T20-20.md`, `final-ts-eslint.2026-08-20T20-22.md`, `final-ts-tsc.2026-08-20T20-23.md`, `final-ts-architecture.2026-08-20T20-23.md`, `final-ts-jest-coverage.2026-08-20T20-24.md` |
| Python | 4 | Format (0) → Lint (0) → Type-check (0) → Test+coverage (0) | `final-py-black.2026-08-20T20-39.md`, `final-py-ruff.2026-08-20T20-40.md`, `final-py-pyright.2026-08-20T20-40.md`, `final-py-pytest-coverage.2026-08-20T20-41.md` |

Both languages completed every stage of their loop in a single consecutive clean pass, as `.claude/rules/general-code-change.md` requires.

Stages 6 (contract/schema compatibility) and 7 (integration tests) of the seven-stage loop have no configured tooling for this change's scope and are not named as tasks in the approved plan; the plan's TypeScript and Python loops are format → lint → type-check → (architecture) → test. Stage 4 for TypeScript was executed as a real search with a real exit code and is recorded at P7-T4 rather than skipped.

No stage in this ledger carries `SKIPPED`. Every executed command's exit code was captured directly from its process, never through a pipe, so no failure could be masked by a downstream command's status.
