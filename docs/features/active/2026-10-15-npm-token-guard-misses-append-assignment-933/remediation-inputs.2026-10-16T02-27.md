# Remediation Inputs — Issue #933 (cycle 2)

- Timestamp: 2026-10-16T02-27
- Issue: #933
- Branch: bug/npm-token-guard-misses-append-assignment-933
- Feature folder: docs/features/active/2026-10-15-npm-token-guard-misses-append-assignment-933
- Work mode: minor-audit
- Opened by: orchestrator, under the run rule that related non-blocking findings (same files, same feature, or wording the item introduced) are fixed inside the item before DONE.
- Source review set: `policy-audit.2026-10-16T02-19.md`, `code-review.2026-10-16T02-19.md`, `feature-audit.2026-10-16T02-19.md` (cycle 1 reaudit; verdict PASS, 0 blocking findings).
- Branch head at cycle entry: 6cb038e9e

## Scope

Only these files may change, plus cycle 2 evidence under the feature folder's `evidence/` tree and the cycle 2 plan:

- `tests/scripts/dev_tools/test_workflow_npm_token_guard.py` (docstring text only)
- `tests/scripts/dev_tools/npm_token_guard_test_support.py` (docstring text only)
- `docs/features/active/2026-10-15-npm-token-guard-misses-append-assignment-933/remediation-plan.2026-10-16T00-56.md` (the "Plan Deviations" revision 1.1 entry text only; no checkbox or task change)

No regex, parametrize row, test id, assertion, or executable line may change (decision D4 stays binding). No file under `.github/`, `src/`, `scripts/`, `extensions/`, `.codex/`, `.claude/`, or `tests/fixtures/` may change. `issue.md` acceptance criteria are not edited; AC-9 stays unchecked (CI-dependent).

## Findings to resolve

### F4 (CR-6, Info, non-blocking, autonomous)

- File: `tests/scripts/dev_tools/test_workflow_npm_token_guard.py`, docstring of `test_find_npm_token_assignments_ignores_non_matching_text` (around lines 259-265).
- Problem: the docstring says "Text that reads but does not assign `NPM_TOKEN` is not reported", but the test also holds `NPM_TOKEN++=x` (not valid shell syntax) and `(( NPM_TOKEN++ ))` (an arithmetic increment), which are not reads.
- Required fix: reword the summary so it covers every row, for example "Text that does not assign a value to ``NPM_TOKEN`` is not reported." Every line stays within 88 characters.

### F5 (CR-6, Info, non-blocking, autonomous)

- File: `tests/scripts/dev_tools/npm_token_guard_test_support.py`, `find_npm_token_assignments` docstring.
- Problem: "an ``+==`` sequence" uses the wrong article.
- Required fix: change it to "a ``+==`` sequence". Every line stays within 88 characters.

### F6 (CR-5 / PA-5, Minor, non-blocking, autonomous)

- File: `docs/features/active/2026-10-15-npm-token-guard-misses-append-assignment-933/remediation-plan.2026-10-16T00-56.md`, "Plan Deviations", revision 1.1 entry.
- Problem: the entry says the one-partial-branch swing "tracks test-file changes only" and is not nondeterminism, but no mechanism is shown: pytest runs serially, `tests/*` is omitted from coverage, the changed tests are pure in-memory calls, and the flipping branch is not identified.
- Required fix: reword so the entry states only what the evidence shows: identical production source produced both values across the four recorded runs (505, 504, 504, 505 partial branches), the responsible branch is not identified, and the D6 floor (post-change equals the item's original pre-change baseline) does not depend on the cause. Remove the claims that the swing tracks test-file changes and that it is not nondeterminism. Keep the field name `SourceIdenticalRunsEvidence:` and every task checkbox unchanged.

## Not in scope (unrelated follow-up)

- Identifying the production branch that flips between 504 and 505 partial branches (a full-suite coverage determinism investigation across files this item does not touch). Listed in the final report as an unrelated follow-up; no issue is created.
- CR-4 / PA-4 (Info): no action. PA-3: AC-9 pending CI, handled at S9.

## Exit condition

Re-run feature review. Exit when the reaudit records 0 blocking findings and F4-F6 are resolved. The Python toolchain loop (black, ruff, pyright on the two test-tree files; the guard module tests) must pass in one pass. Because no executable line changes, the full-suite coverage run is required only to confirm no test failure; coverage must stay at or above the item's original pre-change baseline (line 93.79748270779, branch 88.11243718592965) per decision D6.
