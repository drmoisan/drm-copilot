# Code Review: Python-native docs surface analyzer (#1031)

**Review Date:** 2026-11-07
**Reviewer:** feature-review agent
**Feature Folder:** `docs/features/active/2026-10-30-docs-surface-analyzer-python-native-1031`
**Base Branch:** `origin/epic/documentation-estate-tooling-integration` (tip and merge base `e3e4aa551`)
**Head Branch:** `feature/docs-surface-analyzer-python-native-1031-r2` (head `4aca595d03329a807a2b907bfc859d89384153a3`; no pull request exists)
**Review Type:** Post-remediation re-review (cycle 2; prior set 2026-11-07T00-58)

---

## Executive Summary

The review covers the full branch diff `git diff e3e4aa551...HEAD` (276 paths), using the PR-context artifacts refreshed for this head. F6 is closed, and M1, M2 and M4 are closed. The cycle changed one production script, its bundle copy and one test file, and the change follows the pattern of the other repository members of the command context.

No new blocking defect was found. The review looked for one in two ways that no committed test covers: real-process runs from other directories, including a decoy helper in the caller's location, and an element-by-element comparison of `scanner` and `native` over 366 real Python files.

**What changed well:**
- `Invoke-DocsContextProcess` and the `$invokeProcess` closure pass the root without widening the guard allowlist, and `Invoke-DocsProcess` keeps its signature.
- The file checked by `TestFile` is now the file the interpreter opens; the decoy probe confirms it.
- The new test uses two distinct roots, so a value that happens to equal the current location cannot pass. Three mutants each fail exactly this case.
- `artifacts/python/lcov.info` is now the repo-wide file, so the Python figure no longer needs a side artifact.

**Top 3 risks:**
1. The 3.11 floor and the required CI checks have not run; S10, U10, S22 and U22 are pending-CI.
2. `Invoke-DocsProcess` applying `WorkingDirectory` has no committed test, by rule (no test starts a process). A mutant there would survive the suite; only the recorded probes cover it.
3. A consumer of the MCP tools cannot pin `-AnalysisMethod` (M5, outside this diff).

**PR readiness recommendation:** **Ready for the PR creation gate.** Zero blocking findings.

---

## Findings Table

| Severity | File | Location | Finding | Recommendation | Rationale | Evidence |
|---|---|---|---|---|---|---|
| Minor | `tests/scripts/claude-lib/docs/python/test_docs_python_native_*.py` | test helpers such as `_file`, `_site`, `_codes` | M3 (carried). Test helpers have one-line docstrings with no `Args:` or `Returns:` sections, and 22 test comprehensions have no intent comment. | Add sections to the private helpers and comments to multi-clause comprehensions. | Out of the cycle 2 plan. The unit-test policy accepts short test documentation. | Reviewer AST audit of the previous review; no Python test changed in cycle 2 |
| Info | `extensions/drm-copilot/src/mcp-tool-inputs-docs.ts` | `run_docs_inventory` rows | M5 (carried). The MCP tool has no `AnalysisMethod` input, while spec `## Decisions Later Children Must Honor` says later children forward `-AnalysisMethod`. | Coordinator to decide whether 1036's merged tool needs a row. | The file is outside this branch diff. | Source inspection |
| Minor | `docs/features/active/2026-10-30-docs-surface-analyzer-python-native-1031/user-story.md`, `issue.md` | header lines | M6 (new). M2 refreshed the spec header only. `user-story.md` still reads `Status: Draft (preparation; planning only)` and `Last Updated: 2026-10-30`, and `issue.md` names a folder path without the date prefix. | Refresh these lines in the next edit of these files. Change no criterion text. | Same class as M2, in files M2 did not name. No acceptance criterion or later child depends on these lines. | Source inspection |
| Info | `.claude/lib/docs/DocsAnalyzerPythonApi.psm1` (unchanged, 1022), `.claude/lib/docs/python/docs_python_native/public_api.py` | name listed in `__all__` with a non-ASCII `def` | M7 (new). For a non-ASCII public name, the scanner reports `PYTHON_IDENTIFIER_NON_ASCII` and `PUBLIC_API_NAME_UNRESOLVED` and places the element on the `__all__` line, while native places it on the `def` line. `element_id` is equal; `line_range` and digest differ, so a pin on this one element changes with the method. | No code change is required. State the case in the pinning documentation if it matters to consumers. | The parity rule covers constructs both methods classify, and the scanner marks this construct as unresolved. The spec allows native to improve on a scanner diagnostic. The case did not occur in 366 real files. | Reviewer probe: `src/app/bomfile.py`, scanner `line_range` 1 to 1, native 3 to 3 |
| Info | `docs/features/active/2026-10-30-docs-surface-analyzer-python-native-1031/spec.md` | `## Upstream Dependencies` row `Command-context process member` | M8 (new). The row lists the four `Context.InvokeProcess` arguments. The real member now also has an optional `Operation` parameter, as the other repository members do. | Mention the parameter in the next spec edit, or leave it, since callers pass four arguments. | The in-memory fake and every caller use four arguments, and `Invoke-DocsCommand.Tests.ps1` pins the fifth. | `$invokeProcess` in `New-DocsCommandContext` |

Closed since the previous review: F6 (Major), M1, M2 and M4. F5 is now tracked as pending-CI and is not a finding row; see the policy audit `## Executive Summary`.

No covered file is at or above the 700-line advisory tier. The largest covered files are `tests/scripts/claude-runtime/enforcement-hooks-no-python-invocation.Tests.ps1` at 538 logical lines, `tests/scripts/claude-lib/docs/Invoke-DocsCommand.Tests.ps1` at 499, `.claude/lib/docs/Invoke-DocsCommand.ps1` at 485, and `cli_click.py` at 443.

---

## Implementation Audit

### Python implementation audit

#### What changed well

- No Python file changed in cycle 2. Black, Ruff and Pyright stay at 0 findings, and the helper suite passes 251 of 251.
- Real-corpus evidence: over 366 files the helper returned within the 120-second bound and produced results equal to the scanner for all elements, with equal diagnostic counts.

#### Concerns

- None blocking. The entry script's behavior under isolated mode has no committed test, by rule; the reviewer probes exercised it.

### PowerShell implementation audit

#### What changed well

- `InvokeProcess` was the only repository member that was not a closure, and it now matches the others. The script function resolves `Invoke-DocsProcess` at call time, so the existing mock-based tests still reach it.
- Only `DocsAnalyzerPythonNative.psm1` calls `Context.InvokeProcess` under `.claude/lib`, so the working-directory change affects no other caller.
- Help text in the script header, `Invoke-DocsProcess` and `New-DocsCommandContext` was updated; a search for the old "forwards unchanged" wording in `.claude/lib/docs` finds nothing.

#### Concerns

- None blocking. The `Invoke-DocsProcess` default of the current location remains for a direct caller; the help text states that the real context always passes its root.

### TypeScript and JavaScript audit

- No production TypeScript change. `discovery-resources.test.ts` and `prepack.cjs` are unchanged in cycle 2.

### C# audit

- No C# file changed.

---

## Test Quality Audit

### Reviewed test and QA artifacts

- Reviewer runs: `pytest -n auto` 16350 passed, 6 skipped; Pester 2178 of 2178; helper Pytest 251 of 251; contract Pytest 189 of 189; Jest 33 of 33.
- Evidence: `c2-*` records under `evidence/qa-gates/` and `evidence/regression-testing/`, `coverage-delta.2026-11-07T02-46.md`, `self-review.2026-11-07T02-50.md`.

### Quality assessment

- Isolation: seeded Pester orders, the fresh single-process run, reversed Python modules and both parallel runs are recorded, and the reviewer repeated the Python parallel run.
- Discrimination: the new working-directory case fails on all three mutants, and the control passes. `c2-workingdir-fail-before` records the same failure before the fix.
- Pinned parameter list: the `exposes the same member names` case changed to include `Operation`. The change is required by the closure form, and the plan's test disposition table records it.
- Gap: `$info.WorkingDirectory = $WorkingDirectory` in `Invoke-DocsProcess` is not executed by any test. The repository rule forbids a process-starting test, so this is an accepted limit, and the probes cover it.

---

## Security / Correctness Checks

- No secrets in the diff.
- The helper imports and executes no analyzed code; `ast.parse` is the only parse entry (S7 suite).
- The mismatch recorded in the previous review is closed: a decoy helper in the caller's location did not run while `-RepositoryRoot` named another repository.
- `Invoke-DocsProcess` still starts the child without a shell, and a root path containing a space works.
- Input validation at both protocol boundaries is unchanged.

---

## Research Log

- No external research. Sources were repository files, `git` history and reviewer probes.

---

## Verdict

**Ready for the PR creation gate.** Zero blocking findings. M3 and M6 are Minor, and M5, M7 and M8 are Info. The coordinator may take M3 and M6 in the item if it chooses, since they sit in this item's own files.
