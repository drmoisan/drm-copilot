# Remediation Inputs — Issue #933 (cycle 1)

- Timestamp: 2026-10-16T00-56
- Issue: #933
- Branch: bug/npm-token-guard-misses-append-assignment-933
- Feature folder: docs/features/active/2026-10-15-npm-token-guard-misses-append-assignment-933
- Work mode: minor-audit
- Opened by: orchestrator, under the run rule that related non-blocking findings (same files, same feature) are fixed inside the item before DONE.
- Source review set: `policy-audit.2026-10-16T00-50.md`, `code-review.2026-10-16T00-50.md`, `feature-audit.2026-10-16T00-50.md` (verdict PASS, 0 blocking findings).
- Branch head at cycle entry: 090b24817

## Scope

Only these two files may change, plus cycle evidence under the feature folder's `evidence/` tree and the cycle plan:

- `tests/scripts/dev_tools/npm_token_guard_test_support.py`
- `tests/scripts/dev_tools/test_workflow_npm_token_guard.py`

The regex `_NPM_TOKEN_ASSIGNMENT` must not change in this cycle (decision D4 below). No file under `.github/`, `src/`, `scripts/`, `extensions/`, `.codex/`, `.claude/`, or `tests/fixtures/` may change. The acceptance criteria in `issue.md` are not edited; AC-9 stays unchecked (CI-dependent).

## Findings to resolve

### F1 (CR-1 / PA-1, Minor, non-blocking, autonomous)

- File: `tests/scripts/dev_tools/npm_token_guard_test_support.py`, the `find_npm_token_assignments` docstring (the paragraph rewritten by this branch).
- Problem: the docstring states that a context read such as `env.NPM_TOKEN` and "a longer or prefixed name" are not reported. Alternative B of the pattern begins with `\b`, which matches after `.` and `-`, so `env.NPM_TOKEN += x` and `MY-NPM_TOKEN+=x` are reported (and `env.NPM_TOKEN = x` was already reported before this branch).
- Required fix (decision D4): correct the docstring so it is accurate. It must state that a context read without an assignment operator (`secrets.NPM_TOKEN`, `env.NPM_TOKEN` in an expression) is not reported, that a name extended by a letter, digit, or underscore (`NPM_TOKEN_V2`, `MY_NPM_TOKEN`) is not reported, and that a dot- or hyphen-prefixed assignment (`env.NPM_TOKEN += x`, `MY-NPM_TOKEN+=x`) is reported. Every docstring line stays within 88 characters.
- Required tests: add rows to `test_find_npm_token_assignments_detects_assignment` expecting `[1]` for `env.NPM_TOKEN += x` (id `dot-prefixed-append-reported`) and `MY-NPM_TOKEN+=x` (id `hyphen-prefixed-append-reported`), so the documented behavior is pinned. The planner must confirm, by observing the current pattern's behavior, that each new row passes against the unchanged regex before asserting a pass count.

### F2 (CR-2 / PA-2, Nit, non-blocking, autonomous)

- File: `tests/scripts/dev_tools/test_workflow_npm_token_guard.py`, `test_find_npm_token_assignments_detects_assignment` and `test_find_npm_token_assignments_ignores_non_matching_text`.
- Problem: accepted outcomes of the new `\+?` are not pinned.
- Required tests: add `(( NPM_TOKEN += 1 ))` expecting `[1]` (id `arithmetic-compound-append`) next to the existing rows; add `NPM_TOKEN++=x` (id `double-plus-equals-not-reported`) to the non-matching test. The planner must confirm each outcome against the unchanged regex before asserting counts.

### F3 (CR-3, Nit, non-blocking, autonomous)

- File: `tests/scripts/dev_tools/test_workflow_npm_token_guard.py`, the `test_find_npm_token_assignments_pins_documented_residuals` docstring, final sentence.
- Problem: "These rows characterize existing behavior" is imprecise, because `bash-append-reported` pins behavior introduced by #933.
- Required fix: reword to "These rows pin the current behavior so a change to any outcome is visible." (or equivalent wording that does not say "existing").

## Not in scope

- CR-4 / PA-4 (Info): no action.
- PA-3: AC-9 pending CI; handled at S9 by the orchestrator.

## Decisions

- D4: F1 is resolved by correcting the docstring and pinning the dot- and hyphen-prefixed outcomes as reported, not by replacing `\b` with the alternative-A lookbehind. Replacing `\b` would stop reporting `env.NPM_TOKEN = x`, which narrows the leak guard (fail-open); over-reporting fails closed and is the safer behavior for a secret-leak guard.

## Exit condition

Re-run feature review (policy-audit, code-review, feature-audit). Exit when the reaudit records 0 blocking findings and F1-F3 are resolved. The full Python toolchain loop (black, ruff, pyright, pytest with coverage on the full suite) must pass in one pass, with coverage at or above the values recorded in `evidence/qa-gates/coverage-comparison.2026-10-16T00-36.md`.
