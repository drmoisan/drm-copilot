# Feature Audit: Claude resource parity test excludes gitignored local runtime state (#510)

---

**Audit Date:** 2026-10-07
**Feature Folder:** `docs/features/active/2026-08-19-claude-resource-parity-enumerates-gitignored-state-510`
**Base Branch:** `main`
**Head Branch:** `bug/claude-resource-parity-enumerates-gitignored-state-510`
**Work Mode:** `full-bug`
**Audit Type:** Initial acceptance review

---

## Scope and Baseline

- **Base branch:** `main` (resolved `origin/main`, commit `869c4fade2c3f98ee3ec4ca5a59ea0becf28fb0d`)
- **Head branch/commit:** `bug/claude-resource-parity-enumerates-gitignored-state-510` (commit `b0215e91f7e5493b6d4bf318d32c023a4f34b5a0`)
- **Merge base:** `869c4fade2c3f98ee3ec4ca5a59ea0becf28fb0d`
- **Evidence sources:**
  - Primary: `artifacts/pr_context.summary.txt`
  - Secondary baseline diff: `artifacts/pr_context.appendix.txt`
  - Feature evidence: `docs/features/active/2026-08-19-claude-resource-parity-enumerates-gitignored-state-510/evidence/**`
  - Additional evidence: reviewer reruns of `pytest --no-cov` (38 passed), Black check, Ruff check, Pyright on the four Python files, `wc -l`, `git diff --name-only`, grep for removed identifiers, `artifacts/python/lcov.info`
- **Feature folder used:** `docs/features/active/2026-08-19-claude-resource-parity-enumerates-gitignored-state-510`
- **Requirements source:** `spec.md` (only source for `full-bug`)
- **Work mode resolution note:** `issue.md` carries the explicit marker `- Work Mode: full-bug`; `spec.md` carries the same marker. Per the work-mode contract, `spec.md` is the sole acceptance-criteria source; `user-story.md` is not used and does not exist in the folder.
- **Scope note:** The audit covers the full branch diff against `main`, not a plan subset. The PR-context artifacts were refreshed at head `b0215e91` (generated 2026-10-07 15:18 UTC). The spec names `git diff --name-only main...HEAD`; the review used the equivalent explicit merge-base range `869c4fad..HEAD`.

---

## Acceptance Criteria Inventory

**Authoritative AC source files for this run:**
- `docs/features/active/2026-08-19-claude-resource-parity-enumerates-gitignored-state-510/spec.md` — only source (checkbox-backed)

### Acceptance criteria

1. The reported path `.claude/state/python-batch-budget.default.json` is excluded: `poetry run pytest tests/scripts/dev_tools/test_claude_payload_scope_support.py::test_state_file_from_issue_report_is_excluded -q` passes.
2. Nested paths under `.claude/state/` and `.claude/worktrees/` (for example `.claude/state/a/b/c.json`, `.claude/worktrees/x/.claude/rules/y.md`) are excluded: `test_nested_state_paths_are_excluded` and `test_worktrees_paths_are_excluded` in `tests/scripts/dev_tools/test_claude_payload_scope_support.py` pass.
3. `.claude/agent-memory/**` and `.claude/settings.local.json` remain excluded: `test_agent_memory_paths_remain_excluded` and `test_settings_local_json_remains_excluded` in `tests/scripts/dev_tools/test_claude_payload_scope_support.py` pass.
4. Lookalike and tracked paths are retained (`.claude/statement.md`, `.claude/hooks/state/x.ps1`, `.claude/settings.json`, `.claude/rules/python.md`): `test_lookalike_and_tracked_paths_are_retained` (all parametrized cases) passes.
5. A genuinely missing tracked `.claude` file is still reported and the assertion is not weakened: `test_missing_tracked_file_is_still_reported` passes; and in `test_push_down_claude_resource_contracts.py` the `Repo file missing from bundle` assertion and byte-comparison loop are unchanged (verified by `git diff` showing only filter, constant, and docstring edits in that region).
6. `test_bundled_claude_payload_contains_all_repo_runtime_contracts` uses `filter_distributable_claude_paths`, and `_is_agent_memory_path` and `AGENT_MEMORY_RELATIVE_ROOT` no longer exist: `git grep -n "_is_agent_memory_path\|AGENT_MEMORY_RELATIVE_ROOT" -- tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py` returns no match, and the test passes.
7. Drift guard: `EXCLUDED_CLAUDE_SUBDIRS` in `tests/scripts/dev_tools/test_claude_rules_frontmatter.py` is imported from (bound to) `LOCAL_ONLY_CLAUDE_SUBDIRS`, and `tests/scripts/dev_tools/test_claude_payload_scope_support.py::test_subdirs_match_frontmatter_excluded_subdirs` passes.
8. All created and modified test files are at or under 500 lines: `wc -l` (or an equivalent line count) on `tests/scripts/dev_tools/claude_payload_scope_test_support.py`, `tests/scripts/dev_tools/test_claude_payload_scope_support.py`, `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py`, and `tests/scripts/dev_tools/test_claude_rules_frontmatter.py` reports <= 500 for each.
9. `poetry run black --check .`, `poetry run ruff check .`, and `poetry run pyright` report zero errors.
10. The three affected test files pass: `poetry run pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py tests/scripts/dev_tools/test_claude_payload_scope_support.py tests/scripts/dev_tools/test_claude_rules_frontmatter.py -q` exits 0.
11. Coverage of the new helper meets thresholds (line >= 85%, branch >= 75%). Because `pyproject.toml` omits `tests/*`, measurement uses an override rc file stored at `docs/features/active/2026-08-19-claude-resource-parity-enumerates-gitignored-state-510/evidence/coverage/coveragerc-helper.ini` containing `[run]` with `branch = True` and no `omit` entry: `poetry run pytest tests/scripts/dev_tools/test_claude_payload_scope_support.py --cov=tests.scripts.dev_tools.claude_payload_scope_test_support --cov-branch --cov-config=<that rc file> --cov-report=term-missing` reports the helper module line coverage >= 85% and branch coverage >= 75%. The dotted module form is required; a `.py` path form measures nothing.
12. No production file is modified: `git diff --name-only main...HEAD` lists no path under `scripts/`, `src/`, or `extensions/`.
13. The out-of-scope production defect (Python CLI and TS adapter copying `.claude/state` and `.claude/worktrees`) is recorded in "Out of Scope and Follow-up" with its research citations, and a separate follow-up issue is requested in the completion report.

---

## Acceptance Criteria Evaluation

| # | Criterion | Status | Evidence | Verification command(s) | Notes |
|---|-----------|--------|----------|--------------------------|-------|
| 1 | Reported state path excluded | PASS | Test at `test_claude_payload_scope_support.py` lines 26-35 asserts `is_local_runtime_path(Path(".claude/state/python-batch-budget.default.json")) is True`; `evidence/regression-testing/helper-tests-pass.2026-09-29T14-11.md` | `poetry run pytest tests/scripts/dev_tools/test_claude_payload_scope_support.py::test_state_file_from_issue_report_is_excluded -q` (covered by the 38-pass reviewer run) | Fail-before proof: `evidence/regression-testing/fail-before.2026-09-29T14-11.md` (collection error, exit 2). |
| 2 | Nested state and worktrees paths excluded | PASS | Tests at lines 38-59 use `.claude/state/a/b/c.json` and `.claude/worktrees/x/.claude/rules/y.md` | `poetry run pytest -p no:cacheprovider --no-cov -q tests/scripts/dev_tools/test_claude_payload_scope_support.py` | Predicate matches `parts[:2]`, so depth is irrelevant. |
| 3 | `agent-memory` and `settings.local.json` remain excluded | PASS | Tests at lines 62-83; helper constants `LOCAL_ONLY_CLAUDE_SUBDIRS` and `LOCAL_ONLY_CLAUDE_FILES` | Same pytest run as item 2 | Behavior preserved from the removed inline filter. |
| 4 | Lookalike and tracked paths retained | PASS | Parametrized test at lines 86-105 covers five paths including `.claude/statement.md`, `.claude/hooks/state/x.ps1`, `.claude/settings.json`, `.claude/rules/python.md`, `.claude/settings.local.json.bak` | Same pytest run as item 2 | All five cases pass. |
| 5 | Missing tracked file still reported; assertion not weakened | PASS | Test at lines 132-147 passes; the reviewed diff of `test_push_down_claude_resource_contracts.py` shows only the import, docstring, helper removal, and the one-statement enumeration change; the `Repo file missing from bundle` assertion and byte-comparison loop do not appear in any hunk; `evidence/regression-testing/contracts-test-wiring.2026-09-29T14-11.md` | `git diff 869c4fad..HEAD -- tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py` | Hunks: docstring (lines 3-8), import (lines 17-19), removal of lines 85-117, enumeration (lines 90-103). |
| 6 | Contract test uses the helper; removed identifiers gone | PASS | Line 99-100 of the contract test calls `filter_distributable_claude_paths(list_scoped_files(REPO_ROOT))`; the grep tool returned zero matches for `_is_agent_memory_path` and `AGENT_MEMORY_RELATIVE_ROOT` in that file; `evidence/regression-testing/removed-identifiers-grep.2026-09-29T14-11.md` (exit 1 as expected) | `git grep -n -F -e "_is_agent_memory_path" -e "AGENT_MEMORY_RELATIVE_ROOT" -- tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py` (no match); pytest of the contract test passes | The contract test passes in the 38-test reviewer run. |
| 7 | Drift guard binding and test | PASS | `test_claude_rules_frontmatter.py` lines 29-31 import `LOCAL_ONLY_CLAUDE_SUBDIRS as EXCLUDED_CLAUDE_SUBDIRS`; test at lines 150-163 asserts identity and the set `{"agent-memory", "state", "worktrees"}`; `evidence/regression-testing/frontmatter-binding.2026-09-29T14-11.md` | `poetry run pytest -p no:cacheprovider --no-cov -q tests/scripts/dev_tools/test_claude_payload_scope_support.py::test_subdirs_match_frontmatter_excluded_subdirs` | Identity assertion fails if the binding reverts to an independent literal. |
| 8 | Test files at or under 500 lines | PASS | Reviewer `wc -l`: 49, 199, 467, 499 (matches `evidence/qa-gates/final-limits-and-boundary.2026-09-29T14-11.md`) | `wc -l <four files>` | The frontmatter test file is one line under the limit. |
| 9 | Black, Ruff, Pyright report zero errors | PASS | Executor: `evidence/qa-gates/final-black-check.2026-09-29T14-11.md`, `final-ruff...`, `final-pyright...` (each EXIT_CODE 0; PR-context normalized result pass). Reviewer reran on the changed files: Black 4 files unchanged, Ruff all checks passed, Pyright no diagnostics | `poetry run black --check .`; `poetry run ruff check .`; `poetry run pyright` | Repo-wide runs rely on executor evidence; reviewer reruns were scoped to the changed files and `tests/scripts/dev_tools` (check-only). The executor artifacts record inferred exit codes (code review F-04). |
| 10 | Three affected test files pass | PASS | Reviewer run: `38 passed in 0.27s`; executor `evidence/qa-gates/final-pytest.2026-09-29T14-11.md` (38 passed; 22 baseline + 16 new) | `poetry run pytest -p no:cacheprovider --no-cov -q tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py tests/scripts/dev_tools/test_claude_payload_scope_support.py tests/scripts/dev_tools/test_claude_rules_frontmatter.py` | Reviewer used `--no-cov` to avoid regenerating coverage artifacts. |
| 11 | Helper coverage >= 85% line, >= 75% branch | PASS | `artifacts/python/lcov.info`: LF 12, LH 12 (100%), BRF 2, BRH 2 (100%); `evidence/qa-gates/final-helper-coverage.2026-09-29T14-11.md` helper row Stmts 12, Miss 0, Branch 2, BrPart 0, Cover 100%; rc file at `evidence/other/coveragerc-helper.ini` | `poetry run pytest tests/scripts/dev_tools/test_claude_payload_scope_support.py --cov=tests.scripts.dev_tools.claude_payload_scope_test_support --cov-branch --cov-config=docs/features/active/2026-08-19-claude-resource-parity-enumerates-gitignored-state-510/evidence/other/coveragerc-helper.ini --cov-report=term-missing` (executor evidence inspected, not rerun) | The criterion text names `evidence/coverage/` for the rc file; the file is at the canonical `evidence/other/` path, which the evidence conventions require. The coverage result is unaffected. Spec wording drift recorded in code review F-03. |
| 12 | No production file modified | PASS | `git diff --name-only 869c4fad..HEAD -- scripts src extensions .github` returned empty output; changed files are 4 under `tests/scripts/dev_tools/` and 30 under `docs/features/active/.../`; `git status --porcelain` empty | `git diff --name-only 869c4fad..HEAD -- scripts src extensions .github` | Equivalent to `main...HEAD` because the merge base equals the resolved base commit. |
| 13 | Out-of-scope production defect recorded; follow-up requested | PASS | `spec.md` section "Out of Scope and Follow-up" cites `push_down_claude_customizations.py:392`, `push_down_copilot_customizations.py:496`, `:168`, `:172-174`, `push_down_copilot_customizations_filesystem.py:104-107`, `push_down_claude_filesystem.py:431-448`, and the TypeScript `claude-filesystem-adapter.ts:266-270` and `claude-customizations.ts:73-75`; request artifact `evidence/other/follow-up-issue-request.2026-09-29T14-11.md` | `Read` of the spec section and request artifact | The criterion requires that an issue be requested, not filed; no issue number exists yet. The request artifact also lists the two unverified items. |

---

## Summary

**Overall Feature Readiness:** PASS

**Criteria summary:**
- **PASS:** 13 criteria
- **PARTIAL:** 0 criteria
- **UNVERIFIED:** 0 criteria
- **FAIL:** 0 criteria

**Top gaps preventing PASS:**

1. None.

Non-blocking observations (see `code-review.2026-10-07T15-30.md`): the spec cites stale `.gitignore` line numbers and a non-canonical `evidence/coverage/` path (F-03); the end-to-end failure with a real `.claude/state/*.json` file was not reproduced in this review (F-05); the repo-wide Python coverage figure is not in the coverage artifact, although no production file changed (F-02).

**Recommended follow-up verification steps:**

1. Confirm the PR-level CI run passes on head `b0215e91` after the PR is opened (CI status was not available when the PR context was generated).
2. Optionally reproduce locally: allow a batch-budget hook to create `.claude/state/*-batch-budget.*.json`, run `poetry run pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py -q`, and confirm a pass.
3. File the follow-up issue for the production push-down defect described in `spec.md`.

---

## Acceptance Criteria Check-Off

Per the acceptance-criteria tracking rules:
- Criteria evaluated as **PASS** may be checked off in the authoritative source file(s) if they are represented as markdown checkboxes and are not already checked.
- Criteria evaluated as **PARTIAL**, **FAIL**, or **UNVERIFIED** must remain unchecked.
- If the source uses prose or numbered requirements instead of checkbox items, do not rewrite the source file; record status only in this audit.

### AC Status Summary

- Source: `docs/features/active/2026-08-19-claude-resource-parity-enumerates-gitignored-state-510/spec.md`
- Total AC items: 13
- Checked off (delivered): 13
- Remaining (unchecked): 0
- Items remaining: None.

| Source File | Total AC | Checked (PASS) | Unchecked | Notes |
|-------------|----------|----------------|-----------|-------|
| `docs/features/active/2026-08-19-claude-resource-parity-enumerates-gitignored-state-510/spec.md` | 13 | 13 | 0 | Checkbox-backed; authoritative for `full-bug` |

No source-file checkbox change was made in this review: all 13 items were already checked in `spec.md` and each was independently confirmed PASS above. Newly checked-off items: none.
