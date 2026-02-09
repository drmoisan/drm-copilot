# Code Review: 2026-02-04-extension-tests-fail-in-container-12

**Feature folder selection:**
Selected `docs/features/active/2026-02-04-extension-tests-fail-in-container-12/` because `artifacts/pr_context.summary.txt` identifies this folder as the scoping-doc root for Issue #12.

## Executive Summary

This branch removes the VS Code integration harness and replaces it with Jest-only unit tests, updates test scripts, and adjusts documentation. It also includes a large set of unrelated changes in dev tools, agent docs, and skills that are outside the Issue #12 scope.

**Top risks**
1. **Scope creep**: Unrelated tooling and agent/skill changes increase review and regression risk, and violate the feature’s in-scope list.
2. **Documentation mismatch**: `README.md` still describes GUI-only integration tests while `npm test` now runs Jest unit tests.
3. **PowerShell analyzer stability**: PSScriptAnalyzer reported transient engine errors before passing; ensure CI environment remains stable.

**Go/No-Go recommendation:** **No-Go (Needs revision)** until scope is trimmed (or split into separate PRs) and documentation is aligned.

---

## Findings

| Severity | File | Location | Finding | Recommendation | Rationale | Evidence |
|---|---|---|---|---|---|---|
| **Major** | `artifacts/pr_context.appendix.txt` | Changed files list | Branch includes many unrelated changes (agent docs, skills, dev-tools tests) outside Issue #12 scope. | Split unrelated changes into separate branches/PRs or explicitly expand scope with updated spec/plan. | Scope creep increases regression risk and violates the defined in-scope list in the feature plan. | PR context shows 64 files changed including `.github/skills/*`, `.github/agents/*`, and multiple dev-tools test suites. |
| **Minor** | `README.md` | Testing section | README still states `npm test` runs GUI-dependent integration tests, but scripts now route `npm test` to Jest unit tests. | Update README to match the new Jest-only workflow or restore integration test runner semantics. | Documentation inconsistency can mislead contributors and reviewers. | `README.md` “Integration Tests” section vs. `package.json` scripts (`test` → `test:unit`). |
| **Minor** | `package.json` | `devDependencies` | `@vscode/test-cli` remains in devDependencies even though scripts no longer use VS Code test runner. | Consider removing or documenting why `@vscode/test-cli` is still required. | Reduces dependency surface and avoids confusion. | `package.json` devDependencies list includes `@vscode/test-cli`; no scripts reference it. |

---

## Typed Python Audit

- **Type correctness**: Pyright passed with 0 errors.
- **No broad ignores**: No new `# type: ignore` suppressions observed in changed Python files.
- **`Any` usage**: `tk_dialog_helpers.py` uses `Any` only for dynamic Tk imports with explicit casting and intent comments; acceptable.
- **Error handling**: Exceptions are targeted; no broad catches in library code.
- **Docstrings**: New/edited Python helpers include robust docstrings.

**Verdict:** No typed-Python regressions detected.

---

## Test Quality Audit

- **Jest**: 10 suites / 36 tests pass; new `vscode-test-removal` tests are focused and deterministic.
- **Pytest**: 853 tests pass with 88% coverage overall for `scripts/dev_tools` and related modules.
- **Pester**: Executed via PoshQC (212 passed, 7 skipped).

**Verdict:** Test quality is strong for TypeScript, Python, and PowerShell based on current runs.

---

## Security & Correctness Checks

- **No secrets added**: No credential patterns detected in reviewed changes.
- **No unsafe subprocess patterns**: No new subprocess execution in reviewed TS/PS changes.
- **File-system checks**: Jest tests use `existsSync` for file absence; no temp file creation.

---

## Research Log

No external research performed for this review.
