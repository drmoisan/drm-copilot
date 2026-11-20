# Code Review: Python-native docs surface analyzer (#1031)

**Review Date:** 2026-11-07
**Reviewer:** feature-review agent
**Feature Folder:** `docs/features/active/2026-10-30-docs-surface-analyzer-python-native-1031`
**Base Branch:** `origin/epic/documentation-estate-tooling-integration` (tip and merge base `e3e4aa551`)
**Head Branch:** `feature/docs-surface-analyzer-python-native-1031-r2` (head `94b12db15b96d2e9f883f613bc1f5e5feed20f8b`; no pull request exists)
**Review Type:** Post-remediation re-review (cycle 1; prior set 2026-11-05T23-18)

---

## Executive Summary

The review covers the full branch diff `git diff e3e4aa551...HEAD` (236 paths), using the refreshed PR-context artifacts. Findings F1 to F4 of the previous review are closed. The cycle's module split preserved behavior: a rename-aware AST comparison of the 188 module-level helper symbols between `e6e828de9` and this head found no change beyond the planned renames, and 47 symbols moved file. Documentation was checked for substance as well as presence, because the executor used insertion scripts. Sampled docstrings and comments are specific to their code, and no comment text in the helper repeats more than twice.

One new defect was found by running the shipped path with a real interpreter, which the suite deliberately never does.

**What changed well:**
- Docstrings and intent comments now meet the Python commenting rule across all eighteen helper files.
- PowerShell suppressions are function-scoped and each states why the rule does not apply.
- The named `DOCS_PYTHON_NATIVE_SCANNER_ROW_MISSING` error replaces a parameter-binding failure, and its test fails when the throw is removed (reviewer mutant).
- From the repository root, a real `inventory` run gives 10 native elements whose identifiers and fields equal the scanner's except `analysis_method`.

**Top 3 risks:**
1. F6: `inventory -RepositoryRoot <path>` from another directory cannot start the helper, so the element set and `-AnalysisMethod native` outcome depend on the caller's current location.
2. F5: the 3.11 floor and the required CI checks have not run, because no pull request exists.
3. No committed test covers the real process path, so defects of the F6 class stay invisible to the suite.

**PR readiness recommendation:** **Needs revision.** One autonomous finding (F6) and one `awaiting_ci` finding (F5) are listed in `remediation-inputs.2026-11-07T00-58.md`.

---

## Findings Table

| Severity | File | Location | Finding | Recommendation | Rationale | Evidence |
|---|---|---|---|---|---|---|
| Major | `.claude/lib/docs/Invoke-DocsCommand.ps1`, `.claude/lib/docs/DocsAnalyzerPythonNative.psm1` (and bundle copies) | `Invoke-DocsProcess` line 213 (working directory default), `New-DocsCommandContext` line 369 (`$invokeProcess`), `$script:DocsPythonNativeHelperPath` | F6. The helper path is repository-relative, and the process runs in the current location, while `Context.TestFile` checks under `RepositoryRoot`. With `-RepositoryRoot` from another directory the pack test passes and the interpreter cannot open the helper. | Run the interpreter with the repository root as its working directory, for example by passing the context root to `Invoke-DocsProcess -WorkingDirectory`. Add a test that pins the root reaching the process seam. | Spec `### Interpreter discovery and invocation` states "The working directory is the repository root." `-RepositoryRoot` is a published parameter of the entry script. | Reviewer probe on a scratch repository: from the root, `native` exit 0 with 10 native elements; from another directory, `auto` falls back with reason `exit-nonzero` and `native` exits 3 with `DOCS_PYTHON_NATIVE_UNAVAILABLE`. |
| Minor | `docs/features/active/2026-10-30-docs-surface-analyzer-python-native-1031/spec.md` | `### Helper protocol (protocol version 1)`, helper exit codes line 212-213 | M1. "Every non-zero exit ... is treated by the adapter as `exit-nonzero`" contradicts `### Fallback rules` line 80 and the adapter, which map exit 4 to `version-below-floor`. | Change the sentence to match the fallback rule. | Residual of F4. The authoritative fallback section and `## Decisions Later Children Must Honor` are correct, so no later child is misdirected. | `Get-DocsPythonNativeResult` `ExitCode -eq 4` branch |
| Minor | `docs/features/active/2026-10-30-docs-surface-analyzer-python-native-1031/spec.md` | header lines 8-10, line 34, `## Artifact Classification` | M2. Stale text: status `Draft`, `Last Updated: 2026-10-30`, a statement that the 1022 specification and plan "still describe a withdrawn Python design", a parity-fixture row saying the path is set by 1022, and no rows for `DocsInventory.psm1` or `Invoke-DocsCommand.ps1`. | Refresh these lines in the next spec edit. | The plan's classification is complete, so scope tracking is unaffected. | Source inspection; `r6-scope.2026-11-07T00-41.md` |
| Minor | `tests/scripts/claude-lib/docs/python/test_docs_python_native_*.py` | test helpers such as `_file`, `_site`, `_codes` | M3. Test helpers have one-line docstrings with no `Args:` or `Returns:` sections (61 and 48 by reviewer count, test functions with fixtures included), and 22 test comprehensions have no intent comment. | Add sections to the private helpers and comments to multi-clause comprehensions. | The rule applies to `**/*.py`, but the unit-test policy accepts short test documentation, and the previous review scoped F1 for tests to loops. Most flagged comprehensions are short lookups. | Reviewer AST audit |
| Minor | `artifacts/python/lcov.info` | plan task order [P6-T4], [P6-T5] | M4. The helper-only run followed the full run and overwrote the canonical file, so it holds 18 files and no repo-wide figure. | Run the helper-scoped coverage first, or the full run last, in the next cycle. | The repo-wide figure was still verified from the full-run JSON, and the executor disclosed the overwrite. | `artifacts/python/lcov.info`; `issue-1031-final-coverage.json`; self-review row 8 |
| Info | `extensions/drm-copilot/src/mcp-tool-inputs-docs.ts` | `run_docs_inventory` rows | M5. The MCP tool has no `AnalysisMethod` input, while spec `## Decisions Later Children Must Honor` says later children forward `-AnalysisMethod`. An MCP consumer cannot pin the method. | Coordinator to decide whether 1036's merged tool needs a row. | The file is outside this branch diff. Which child owns the forwarding was not confirmed from the epic text. | Source inspection |

No covered file is at or above the 700-line advisory tier. The largest covered files are `tests/scripts/claude-runtime/enforcement-hooks-no-python-invocation.Tests.ps1` at 538 logical lines, `.claude/lib/docs/Invoke-DocsCommand.ps1` at 468, and `cli_click.py` at 443.

---

## Implementation Audit

### Python implementation audit

#### What changed well

- Eighteen modules, each with one concern and below 500 logical lines.
- 137 of 137 functions and classes documented, with `Args:`, `Returns:` and `Raises:` wherever they apply.
- `protocol.py` dispatch and `routes.py` passes are now explained by decision and meta-what comments.
- The real entry starts under `-I -B -X utf8` and imports the split package.

#### Concerns

- None blocking. The entry script's behavior under isolated mode has no committed test, only the reviewer probe.

### PowerShell implementation audit

#### What changed well

- `Get-DocsPythonNativeResult` matches the amended specification signature and return shape.
- Suppressions cover the contract-fixed `-CapturedInput` parameter and the ordinal-comparer hashtables with stated reasons.

#### Concerns

- F6. The comment on `Invoke-DocsProcess` states that callers run with the repository root as the current location. The entry script's `-RepositoryRoot` parameter breaks that assumption. This feature is the first caller that relies on a relative path through the seam.
- The reported reason `exit-nonzero` does not point to the cause, so a user would look at the interpreter first.

### TypeScript and JavaScript audit

- No production TypeScript change. `discovery-resources.test.ts` and `prepack.cjs` are unchanged since `3090e42fd`, and the prefix carve-out covers the six new modules.

### C# audit

- No C# file changed.

---

## Test Quality Audit

### Reviewed test and QA artifacts

- Reviewer runs: `pytest -n auto` 16350 passed, 6 skipped; Pester 2177 of 2177; helper Pytest 251 of 251; contract Pytest 189 of 189; Jest 33 of 33.
- Evidence: `coverage-delta`, `r6-*` records, `r6-isolation-pester`, `r6-isolation-python`, `self-review.2026-11-07T00-41.md`.

### Quality assessment

- Isolation: required parallel runs pass under the owner directive recorded in the policy audit.
- Discrimination: the new scanner-row test fails on the reverted mutant.
- Gap: every Pester case replaces the process seam, and `Invoke-DocsProcess` is documented as not executed by tests, so working-directory behavior has no coverage. A process-free test can pin the root at the seam boundary.

---

## Security / Correctness Checks

- No secrets in the diff.
- The helper imports and executes no analyzed code; `ast.parse` is the only parse entry (S7 suite).
- With F6, `TestFile` checks the root while the interpreter opens the path relative to the current location, so the file checked and the file started can differ. The fix removes this mismatch.
- A planted executable in the working directory did not start through `ProcessStartInfo` in the reviewer probe; no finding.
- Input validation at both protocol boundaries is unchanged.

---

## Research Log

- No external research. Sources were repository files, `git` history and reviewer probes.

---

## Verdict

**Needs revision.** Fix F6 in a proportionate remediation cycle, and take M1, M2 and M4 in the same cycle if the coordinator agrees. F5 then resolves through CI on the pull request head.
