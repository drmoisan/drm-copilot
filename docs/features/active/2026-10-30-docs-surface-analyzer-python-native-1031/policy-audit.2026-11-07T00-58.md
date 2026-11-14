# Policy Compliance Audit: Python-native docs surface analyzer (#1031)

**Audit Date:** 2026-11-07
**Reviewer:** feature-review agent
**Audit Type:** Re-audit of remediation cycle 1 (prior review set stamp 2026-11-05T23-18)
**Feature Folder:** `docs/features/active/2026-10-30-docs-surface-analyzer-python-native-1031`
**Base Branch:** `origin/epic/documentation-estate-tooling-integration` (tip `e3e4aa551`, fetched at review time)
**Head Branch:** `feature/docs-surface-analyzer-python-native-1031-r2` (head `94b12db15b96d2e9f883f613bc1f5e5feed20f8b`; clean worktree before this review; no pull request exists)
**Merge base:** `e3e4aa551808a25c436337bf0dbcf298421a34d6`, equal to the base tip. The item diff is `git diff e3e4aa551...HEAD` (236 paths, 18545 insertions, 232 deletions).

**Scope source:** `artifacts/pr_context.summary.txt` and `artifacts/pr_context.appendix.txt` under the worktree, generated 2026-11-07 00:44:45 UTC for head `94b12db15`, with base and merge base equal to the values above.

**Template source assumption:** the template asset tool was not available in this agent's tool set, so the structure follows the repository templates under `docs/features/templates/policy_audit/` and the previous validated audit.

**Code Under Test (branch diff):**

- Python helper (new, 18 files): `.claude/lib/docs/python/run_docs_python_native.py` and `docs_python_native/{__init__,architecture,call_sites,cli,cli_argparse,cli_click,cli_typer,facts,imports,module_names,protocol,public_api,route_model,route_sites,routes,source,walk}.py`, plus byte-identical bundle copies.
- PowerShell production: new `DocsAnalyzerPythonNative.psm1` and `DocsPythonNativeProtocol.psm1`; edited `DocsAnalyzerRegistry.psm1`, `DocsInventory.psm1` and `Invoke-DocsCommand.ps1`, plus bundle copies.
- Configuration and packaging: `pyproject.toml`, `pack-manifests/python.json` and `core.json`, `extensions/drm-copilot/.vscodeignore`, `packages/mcp-server/prepack.cjs`.
- Tests: 21 Python files under `tests/scripts/claude-lib/docs/python/`; Pester suites under `tests/scripts/claude-lib/docs/`; the fixture `python-native-corpus.json`; 3 guard files under `tests/scripts/claude-runtime/`; the TypeScript test `discovery-resources.test.ts`.
- Feature-folder Markdown: spec, user story, plans and evidence files.

**Coverage Metrics by Language:**

| Language | Files Changed | Tests | Test Result | Baseline Coverage | Post-Change Coverage | New Code Coverage |
|----------|--------------|-------|-------------|-------------------|---------------------|-------------------|
| Python | 18 production (+18 bundle copies), 21 test files, `pyproject.toml` | 16350 full suite; 251 helper tests | PASS: reviewer `pytest -n auto` 16350 passed, 6 skipped, 0 failed; reviewer helper run 251 of 251 | 96.82% line, 93.83% branch (`issue-1031-baseline-coverage.json`, merged tree before the cycle) | 96.84% line, 93.88% branch (`issue-1031-final-coverage.json`, 34071 of 35181 lines, 12527 of 13344 branches) | 99.28% line (1801 of 1814), 97.22% branch (805 of 828) over the 18 helper files; minimum per file 97.35% line (`source.py`), 90.00% branch (`walk.py`) |
| PowerShell | 2 new and 3 edited production (+5 bundle copies), Pester suites, 3 guard files | 16542 merged parallel run; 2177 reviewer in-scope run | PASS: `Invoke-PoshQCParallelTest` 16542 tests, 0 failures, 0 errors, 10 skipped; reviewer 2177 of 2177 | 93.77% line (executor P0-T8, full `tests/scripts`, earlier base) | 95.26% line (32369 of 33979, canonical `artifacts/pester/powershell-coverage.xml`) | 100.00% line for both new modules (93 of 93, 132 of 132); edited files 100.00%, 100.00%, 87.82%; 0 changed lines uncovered |
| TypeScript | 1 test file (`discovery-resources.test.ts`); 1 JavaScript build script (`prepack.cjs`) | 9 + 24 reviewer Jest tests; 5333 executor full suite | PASS: reviewer 33 of 33; executor 5333 passed, 0 failed | 97.10% line, 93.76% branch (`baseline-jest-coverage`) | 97.10% line, 93.76% branch (63029 of 64911, 9596 of 10234; `extensions/drm-copilot/coverage/lcov.info`) | N/A - no TypeScript production file in the diff; `prepack.cjs` lies outside `collectCoverageFrom` |

C# and Bash: zero changed files on the branch (`git diff --name-only e3e4aa551...HEAD` filtered by `*.cs`, `*.sh`, `*.bats`: no match). JSON data files have no coverage tool.

### Coverage Evidence Checklist

- Python baseline coverage artifact: session scratch `issue-1031/issue-1031-baseline-coverage.json`, read directly by the reviewer; `evidence/qa-gates/coverage-delta.2026-11-07T00-31.md`
- Python post-change coverage artifact: `artifacts/python/lcov.info` (18 helper files, 1801 of 1814 lines, 805 of 828 branches, equal to the reviewer rerun); repo-wide figure from scratch `issue-1031/issue-1031-final-coverage.json`, 384 files, written 2026-11-07T00-07 UTC
- PowerShell baseline coverage artifact: `evidence/baseline/baseline-pester-coverage.2026-11-04T15-53.md`
- PowerShell post-change coverage artifact: `artifacts/pester/powershell-coverage.xml` (342 source files, merged parallel run, written 2026-11-07T00-38 UTC)
- TypeScript baseline coverage artifact: `evidence/qa-gates/coverage-delta.2026-11-07T00-31.md`
- TypeScript post-change coverage artifact: `extensions/drm-copilot/coverage/lcov.info` (252 source files)
- Per-language comparison summary: section 1.2.1 of this audit

---

## Executive Summary

Remediation cycle 1 closes findings F1, F2, F3 and F4 of the 2026-11-05T23-18 review. The helper package is split into eighteen files with complete docstrings and intent comments, the PSScriptAnalyzer findings are cleared with scoped and justified suppressions, the canonical coverage artifacts exist, and the specification now names the adopted contracts. A rename-aware AST comparison of the 188 module-level helper symbols between the previous head `e6e828de9` and this head found no behavioral difference: 187 are equal after the planned renames, and the remaining one, `analyze_http`, differs only by the planned `_collect` to `collect_sites` rename.

The re-audit also found one new defect, F6, by running the shipped path with a real interpreter on a scratch destination repository, which no committed test does. `inventory -RepositoryRoot <path>` run from another directory cannot start the helper, because the helper path is relative and `Invoke-DocsProcess` uses the current location as its working directory. The specification states that the working directory is the repository root. Under `auto` the run falls back to the scanner with reason `exit-nonzero`; under `-AnalysisMethod native` it exits 3 although the pack and interpreter are present. MCP tools are not affected, because they set the process working directory to the workspace root.

Findings: one new autonomous blocking finding (F6) and one carried `awaiting_ci` finding (F5). Overall verdict: REMEDIATION_REQUIRED.

**Policy documents evaluated:**
- ✅ `.claude/rules/self-explanatory-code-commenting.md` (F1 closed; Minor residual for test helpers)
- ✅ `.claude/rules/general-code-change.md`
- ✅ `.claude/rules/general-unit-test.md`
- ✅ `.claude/rules/quality-tiers.md` (`quality-tiers.yml` exists; reviewer `check_quality_tiers` OK, 30 entries, file unchanged)

**Language-specific policies evaluated:**
- ✅ `python-code-change.instructions.md` + `python-unit-test.instructions.md`
- ✅ `powershell-code-change.instructions.md` + `powershell-unit-test.instructions.md` (toolchain clean; the F6 behavior defect is recorded in section 2.3)
- ✅ `typescript-unit-test.instructions.md` (test-only change; Jest passes)
- N/A C# and Bash: no file changed

**Temporary artifacts cleanup:**
- ✅ No temporary script is committed; `git status` was clean before this review wrote its artifacts
- ✅ Reviewer scripts, the scratch destination repository and the mutant copy live in the session scratchpad. One reviewer coverage JSON was first written to `C:\c\Users\...` because of a path-form error; it was moved to the scratchpad and its empty folder removed. No `__pycache__` was written under the helper or its bundle copy

---

## Rejected Scope Narrowing

No scope narrowing was detected, and none was rejected. The caller prompt names the full merge-base diff.

The coordinator sent one directive during this review, followed here as written. It changes which isolation evidence is required and does not narrow the audit scope, any language, or any coverage check:

> Owner directive for this review: tests now run in parallel only, effective 2026-11-07. Do not raise a finding for a missing single-process, seeded-shuffle, or reversed-order run, even though `## Test Isolation Checks` in the `execution-environment` skill still lists them. The owner has waived those runs, and the skill will be updated separately. The required evidence is a passing `Invoke-PoshQCParallelTest` run and a passing `pytest -n auto` run. All other review criteria are unchanged.

The reviewer received this directive from the coordinator and did not see the owner's statement directly. Both required runs pass (section 6). The skill text and the spec `## Definition of Done` isolation line still list the waived runs, so the skill update stays open as the directive states.

---

## 1. General Unit Test Policy Compliance

### 1.1 Core Principles

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Independence** | ✅ PASS | Required evidence under the owner directive: `Invoke-PoshQCParallelTest` 8 shards, 16542 tests, 0 failures (merged JUnit read by the reviewer); reviewer `pytest -n auto` 16350 passed, 0 failed. |
| **Isolation** | ✅ PASS | One Pytest module per helper module, including the six new ones. |
| **Fast Execution** | ✅ PASS | Helper suite 251 tests in 1.02 s; full suite under `-n auto` in 83 s. |
| **Determinism** | ✅ PASS | No process, clock or network in tests; seam scriptblocks are test-local. |
| **Readability & Maintainability** | ✅ PASS | All 14 test loops carry an intent comment; every test has a scenario docstring. Minor residual in code review item M3. |

### 1.2 Coverage and Scenarios

| Requirement | Status | Evidence |
|------------|--------|----------|
| Baseline coverage documented | ✅ PASS | `coverage-delta.2026-11-07T00-31.md`; baseline JSON read directly. |
| Canonical coverage artifacts present | ✅ PASS | F3 closed. `artifacts/python/lcov.info` holds the helper files only, because the helper run followed the full run and wrote the same path; the repo-wide figure was read from the full-run JSON (assumption A1). |
| New-file line >= 85% and branch >= 75% (Python) | ✅ PASS | All eighteen helper files; minimum 97.35% line, 90.00% branch; reviewer rerun gives identical totals. |
| New-file line >= 85% (PowerShell) | ✅ PASS | Both new modules 100.00%. |
| No regression on changed lines | ✅ PASS | Reviewer intersection of JaCoCo missed lines with `git diff -U0` changed lines: 0 uncovered changed lines in the five PowerShell files. Python changed lines are in new files. |
| Repo-wide thresholds | ✅ PASS | Python 96.84% line, 93.88% branch; PowerShell 95.26% line; TypeScript 97.10% line, 93.76% branch. |
| Coverage exclusions | ✅ PASS | `pyproject.toml` adds the helper to `source`; no production path excluded. |
| Positive, negative, edge, error flows | ✅ PASS | Corpus round trip, each request and response defect, BOM and CRLF cases, depth limits, exit codes, reason tokens. The real process seam has no test by design, which is why F6 was not seen (section 2.3). |
| Concurrency / state transitions | ✅ PASS | No concurrency; candidate fallback order is tested. |

### 1.2.1 Per-Language Coverage Comparison

- Python: Baseline: 96.82% (line; branch 93.83%). Post-change: 96.84% (line; branch 93.88%). Change: +0.02 points line, +0.05 points branch. Disposition: PASS. New/changed-code coverage: 99.28% line and 97.22% branch over the eighteen new helper files. Evidence: `artifacts/python/lcov.info`; `issue-1031-final-coverage.json`; reviewer helper rerun; `evidence/qa-gates/coverage-delta.2026-11-07T00-31.md`.
- PowerShell: Baseline: 93.77% (line, earlier base). Post-change: 95.26% (line). Change: +1.49 points. Disposition: PASS. New/changed-code coverage: 100.00% line for both new modules, with 0 uncovered changed lines across the five files. Evidence: `artifacts/pester/powershell-coverage.xml`; `evidence/qa-gates/r6-powershell-per-file-coverage.2026-11-07T00-31.md`. No branch threshold applies to PowerShell.
- TypeScript: Baseline: 97.10% (line; branch 93.76%). Post-change: 97.10% (line; branch 93.76%). Change: 0.00 points. Disposition: PASS. New/changed-code coverage: N/A - no TypeScript production file in the diff. Evidence: `extensions/drm-copilot/coverage/lcov.info`; `evidence/qa-gates/r6-jest-coverage.2026-11-07T00-09.md`.

Assumptions:

- A1: the Python repo-wide figure comes from the executor's full-run JSON, written 2026-11-07T00-07 UTC, after the last Python production commit `95808bb00` (2026-11-06T23-54 UTC). The reviewer read the file directly and reproduced 34071 of 35181 lines and 12527 of 13344 branches. The executor disclosed the lcov overwrite in its self-review. It is non-blocking (code review item M4).
- A2: the PowerShell artifact was written after the last PowerShell production commit `ec14bb3e8`, and the commits after it change no PowerShell file, so it describes this head.
- A3: the contract table names `coverage/lcov.info`. The repository's Jest project writes `extensions/drm-copilot/coverage/lcov.info`, and no root TypeScript project exists. No TypeScript source changed after that file was written.

Per-file Python coverage (from `artifacts/python/lcov.info`, equal to the reviewer rerun):

| File | Line (covered/statements) | Branch (covered/branches) |
|---|---|---|
| `run_docs_python_native.py` | 100.00% (15/15) | 100.00% (4/4) |
| `__init__.py` | 100.00% (0/0) | 100.00% (0/0) |
| `architecture.py` | 100.00% (72/72) | 97.37% (37/38) |
| `call_sites.py` | 100.00% (91/91) | 100.00% (38/38) |
| `cli.py` | 99.06% (105/106) | 97.83% (45/46) |
| `cli_argparse.py` | 100.00% (159/159) | 96.51% (83/86) |
| `cli_click.py` | 98.51% (199/202) | 96.43% (108/112) |
| `cli_typer.py` | 99.48% (192/193) | 95.83% (92/96) |
| `facts.py` | 100.00% (33/33) | 100.00% (2/2) |
| `imports.py` | 100.00% (138/138) | 100.00% (56/56) |
| `module_names.py` | 98.11% (52/53) | 94.44% (34/36) |
| `protocol.py` | 100.00% (150/150) | 100.00% (50/50) |
| `public_api.py` | 98.11% (156/159) | 96.88% (93/96) |
| `route_model.py` | 100.00% (46/46) | 100.00% (0/0) |
| `route_sites.py` | 100.00% (129/129) | 98.44% (63/64) |
| `routes.py` | 100.00% (116/116) | 100.00% (52/52) |
| `source.py` | 97.35% (110/113) | 92.86% (39/42) |
| `walk.py` | 97.44% (38/39) | 90.00% (9/10) |

Per-file PowerShell coverage (from `artifacts/pester/powershell-coverage.xml`):

| File | Covered / Total | Line % | Changed lines uncovered |
|---|---|---|---|
| `DocsAnalyzerPythonNative.psm1` (new) | 93 / 93 | 100.00% | 0 of 332 |
| `DocsPythonNativeProtocol.psm1` (new) | 132 / 132 | 100.00% | 0 of 341 |
| `DocsAnalyzerRegistry.psm1` (edited) | 135 / 135 | 100.00% | 0 of 4 |
| `DocsInventory.psm1` (edited) | 121 / 121 | 100.00% | 0 of 32 |
| `Invoke-DocsCommand.ps1` (edited) | 137 / 156 | 87.82% | 0 of 1 |

### 1.3 Test Structure and Diagnostics

| Requirement | Status | Evidence |
|------------|--------|----------|
| Arrange-Act-Assert | ✅ PASS | Inputs built in-test, one call, then assertions. |
| Clear failure messages | ✅ PASS | Structured comparisons; the reverted scanner-row mutant failed with a message naming the expected error. |
| Clean test output | ✅ PASS | Reviewer runs. |

### 1.4 External Dependencies and Environment

| Requirement | Status | Evidence |
|------------|--------|----------|
| No external services | ✅ PASS | `r6-test-hygiene.2026-11-07T00-09.md`. |
| No temporary files | ✅ PASS | Reviewer token search over `tests/scripts/claude-lib/docs/`: no match. |
| No mutable global state | ✅ PASS | `conftest.py` sets only `sys.dont_write_bytecode`. |

---

## 2. General Code Change Policy Compliance

### 2.1 Design Principles

| Requirement | Status | Evidence |
|------------|--------|----------|
| Simplicity first | ✅ PASS | Module moves are verbatim per the AST comparison. |
| Reusability | ✅ PASS | `call_sites.py` removes the cross-import of recognizer helpers. |
| Extensibility | ✅ PASS | Registry rows per identifier; `protocol_version`. |
| Separation of concerns | ✅ PASS | Walking, facts, module names, route model and route collection are separate modules. |

### 2.2 Module and File Structure

| Requirement | Status | Evidence |
|------------|--------|----------|
| At or below the 800-line hard limit | ✅ PASS | 81 covered files measured; largest 538 logical lines (`enforcement-hooks-no-python-invocation.Tests.ps1`); largest production file 468; `config/file-size-baseline.json` not in the diff. |
| 700-line advisory tier | ✅ PASS | No covered file at or above 700 lines. |
| Explicit exports / public vs internal | ✅ PASS | `Export-ModuleMember` lists; names that crossed modules are public. |
| No circular dependencies | ✅ PASS | Pyright clean; `imports` reached from `call_sites` under `TYPE_CHECKING` only. |

### 2.3 Error Handling

| Requirement | Status | Evidence |
|------------|--------|----------|
| Fail fast, no silent catch | ✅ PASS | `RequestError`; boundary handler in `main`; named `DOCS_PYTHON_NATIVE_SCANNER_ROW_MISSING`. |
| Behavior matches the published contract | ❌ FAIL | F6: with `-RepositoryRoot` from another directory, the helper cannot start, and the reported reason `exit-nonzero` does not name the cause. |

### 2.4 Toolchain Execution

| Step | Status | Evidence |
|------|--------|----------|
| 1. Formatting | ✅ PASS | Reviewer Black: 39 files unchanged; `Invoke-Formatter` over 22 files: 0 differences. |
| 2. Linting | ✅ PASS | Ruff: all checks passed; PSScriptAnalyzer with `pssa.settings.psd1` over 22 files including `.claude/lib`: 0 findings. |
| 3. Type checking | ✅ PASS | Reviewer Pyright: 0 errors, 0 warnings, 0 informations. |
| 4. Architecture-boundary tests | ✅ PASS | `ClaudeLibModuleConvention.Tests.ps1` and the guard suite in the reviewer Pester run. |
| 5. Unit tests | ✅ PASS | Pytest 16350 passed; Pester 2177 of 2177 (reviewer) and 16542 tests with 0 failures (parallel). |
| 6. Contract / schema checks | ✅ PASS | Push-down and configuration-pin Pytest 189 of 189; manifest-completeness Jest 24 of 24. |
| 7. Integration tests | ✅ PASS | `DocsInventory.PythonNative.Tests.ps1`; reviewer real-process inventory probe from the repository root. |

---

## 3. Language-Specific Code Change Policy Compliance

### 3A Python

| Requirement | Status | Evidence |
|------------|--------|----------|
| Black / Ruff / Pyright | ✅ PASS | Section 2.4. |
| Strong typing, no `Any` | ✅ PASS | Pyright strict clean. |
| Dataclasses for value objects | ✅ PASS | `RouteSite`, `RouteMount`, `Fact`, `ParsedModule`. |
| Specific exceptions | ✅ PASS | `RequestError`; boundary handler only in `main`. |
| Docstrings (commenting rule) | ✅ PASS | F1 closed. Reviewer AST audit: 137 of 137 helper functions and classes documented; every function with parameters has `Args:` naming each parameter; every value-returning function has `Returns:`; every function that raises has `Raises:`. |
| Loop, branch and block comments (commenting rule) | ✅ PASS | F1 closed. 91 of 91 helper loops and 15 of 15 non-trivial comprehensions carry an intent comment; 189 full-line comments. Sixteen branch sites flagged by a one-line heuristic were read; the sampled sites carry their decision comment at the head of the chain. No helper comment text repeats more than twice, and no numbered note exists. |

### 3B PowerShell

| Requirement | Status | Evidence |
|------------|--------|----------|
| Formatting | ✅ PASS | 0 differences. |
| PSScriptAnalyzer | ✅ PASS | F2 closed: 0 findings; each suppression is function-scoped and carries a justification. |
| Advanced functions, parameter validation | ✅ PASS | `CmdletBinding` and typed parameters. |
| Approved verbs | ✅ PASS | Unchanged. |
| No global state | ✅ PASS | Constant `$script:` values. |
| ShouldProcess for state-changing actions | ✅ PASS | No new function changes system state. |
| Seam pattern | ✅ PASS | Interpreter start only through the `[scriptblock]` member, in one function. |

### 3C TypeScript / JavaScript

| Requirement | Status | Evidence |
|------------|--------|----------|
| Jest test passes | ✅ PASS | 9 of 9 and 24 of 24. |
| Build-script change scoped | ✅ PASS | `prepack.cjs` unchanged since `3090e42fd`; the carve-out is prefix-based and admits the six new modules. |

### 3D JSON

| Requirement | Status | Evidence |
|------------|--------|----------|
| Strict JSON | ✅ PASS | Manifests parsed by the reviewer script and suites. |
| Manifest completeness | ✅ PASS | 18 of 18 helper files in `python.json` and in no other manifest; `core.json` lists no `.py` and lists both modules. |

---

## 4. Language-Specific Unit Test Policy Compliance

### 4A Python Unit Tests

| Requirement | Status | Evidence |
|------------|--------|----------|
| Pytest, location mirrors source | ✅ PASS | `tests/scripts/claude-lib/docs/python/test_docs_python_native_<area>.py`. |
| Mocking sparingly | ✅ PASS | Failures injected through parameters. |
| Naming | ✅ PASS | Descriptive `test_` names. |
| Docstrings and comments | ✅ PASS | 237 of 237 test functions and classes have a docstring; 14 of 14 loops have an intent comment. Minor item M3. |

### 4B PowerShell Unit Tests

| Requirement | Status | Evidence |
|------------|--------|----------|
| Pester v5, `*.Tests.ps1`, mirrored location | ✅ PASS | Suites under `tests/scripts/claude-lib/docs/`. |
| Mocking sparingly | ✅ PASS | Test-local seam scriptblocks. |
| PoshQC test command | ✅ PASS | Executor coverage through `Invoke-PoshQCParallelTest`; the reviewer used `Invoke-Pester` without coverage so no canonical file was overwritten. |

---

## 5. Test Coverage Detail

See section 1.2.1. Figures were read from the artifacts, not from the evidence tables, and agree with the executor record.

---

## 6. Test Execution Metrics

| Run | Tests | Passed | Failed | Source |
|---|---|---|---|---|
| Reviewer `pytest -n auto`, full tree (required evidence) | 16356 | 16350 (6 skipped) | 0 | this review |
| `Invoke-PoshQCParallelTest`, 8 shards (required evidence) | 16542 | 16532 (10 skipped) | 0 | merged `artifacts/pester/pester-junit.xml` |
| Reviewer Pester, docs folder plus guard and convention suites, coverage off | 2177 | 2177 | 0 | this review |
| Reviewer helper Pytest with coverage | 251 | 251 | 0 | this review |
| Reviewer push-down and configuration-pin Pytest | 189 | 189 | 0 | this review |
| Reviewer Jest `discovery-resources` and `claude-pack-manifest-completeness` | 33 | 33 | 0 | this review |
| Executor Jest full suite with coverage | 5333 | 5333 | 0 | `r6-jest-coverage.2026-11-07T00-09.md` |

Reviewer probes at this head:

- Mutant: removing the `DOCS_PYTHON_NATIVE_SCANNER_ROW_MISSING` throw from a scratch copy makes the new test fail (1 failed), so that test discriminates.
- Real-process inventory on a scratch repository, Python 3.13, from the repository root: `auto` and `native` exit 0 with 10 native elements; `scanner` exit 0 with the same 10 element identifiers and no field difference other than `analysis_method`.
- Pack absent: `auto` exit 0 with no diagnostic; `native` exit 3 with reason `pack-absent`.
- From another directory with `-RepositoryRoot`: `auto` exit 0 with scanner elements and reason `exit-nonzero`; `native` exit 3 with reason `exit-nonzero` (F6).
- A planted executable in the working directory did not start through `ProcessStartInfo`, so no finding is recorded for that concern.

---

## 7. Code Quality Checks

- Black: 39 files unchanged. Ruff: all checks passed. Pyright: 0 errors.
- PSScriptAnalyzer: 0 findings over 22 files. Formatter: 0 differences.
- File size: maximum 538 logical lines; no Warning row; no file above 800; no baseline entry added.
- Bundle mirror: 23 of 23 `.claude/lib/docs/` pairs SHA-256 identical.
- Bytecode: no `__pycache__` or `.pyc` under the helper or its bundle copy.
- Tier: `quality-tiers.yml` unchanged; `check_quality_tiers` OK (30 entries).
- `modified-workflow-needs-green-run`: not triggered; the diff has no path under `.github/workflows/`, `.github/actions/` or `scripts/benchmarks/`.

---

## Evidence Location Compliance

`validate_evidence_locations.py --root .` in the worktree exited 0 with no output. The branch diff contains no path under `artifacts/baselines/`, `artifacts/qa/`, `artifacts/evidence/` or `artifacts/coverage/`. Spec criterion S9 names `<FEATURE>/evidence/coverage/`; the plan's `## Deviations from spec.md` item 10 records `EVIDENCE_LOCATION_OVERRIDE_REJECTED: <FEATURE>/evidence/coverage/ replaced with <FEATURE>/evidence/qa-gates/`, and the coverage records are in `evidence/qa-gates/`. No violation.

---

## 8. Gaps and Exceptions

1. **F6 Helper start depends on the current location (blocking, autonomous, new).** Details in `remediation-inputs.2026-11-07T00-58.md`.
2. **F5 CI-dependent items (blocking, awaiting_ci, carried).** S10, U10, S22 and U22. The local zero-failure Pester part is now met on Windows; CI on the PR head remains outstanding.
3. **Closed:** F1, F2, F3 and F4. F4 leaves one contradictory sentence and some stale text, recorded as Minor (code review items M1 and M2).
4. **Waived by owner directive:** single-process, seeded-shuffle and reversed-order runs (see `## Rejected Scope Narrowing`).
5. **Warnings.** None.

The change to the S4, U4, S13 and U13 criterion texts is backed by owner decision `1031-ac-text-s4-s13` option (a), recorded in `docs/features/epics/documentation-estate-tooling/epic-status.md` and the orchestrator checkpoint. Checkbox states did not change in that edit. No policy exception is claimed. Tier classification applies and is satisfied.

---

## 9. Summary of Changes

Cycle commits (`git log e6e828de9..HEAD`): integration merge `65587b232`; analyzer clearance and the named scanner-row error `ec14bb3e8`; helper split `e5216457b`; helper and test documentation `e40ffa6da`; bundle mirror and manifest `4617528f0`; specification reconciliation `efc3fcbc7`; comment additions `95808bb00`; final QA evidence `a2b19d942`, `ad2e35840`, `94b12db15`.

---

## 10. Compliance Verdict

**REMEDIATION_REQUIRED.** F6 is autonomous and is fixed in a remediation cycle. F5 resolves through CI on the PR head at S9.

---

## Appendix A: Test Inventory

Reviewer Pester run at head `94b12db15` (`Invoke-Pester`, coverage off, one process, 5 min 30 s): `tests/scripts/claude-lib/docs` plus `enforcement-hooks-no-python-invocation.Tests.ps1` and `ClaudeLibModuleConvention.Tests.ps1`, 2177 tests, all passed.

Python: 20 test modules plus `conftest.py`, 251 helper tests, all passed.

## Appendix B: Toolchain Commands Reference

All commands ran in the worktree with `.venv/Scripts/python.exe` (Python 3.13.17) through scratch `.sh` launchers.

- Pytest parallel: `python -B -m pytest -c pyproject.toml -o addopts="" -p no:cacheprovider -n auto -q`
- Helper Pytest: the same flags over `tests/scripts/claude-lib/docs/python` with `--cov=docs_python_native --cov=run_docs_python_native --cov-branch --cov-report=json:<scratch>`
- Contract Pytest: the three `test_push_down_*` modules, `test_pyright_config_alignment.py`, `test_ruff_config_alignment.py`, `tests/discovery_runtime/test_package_contract.py`
- Static: `python -m black --check`, `python -m ruff check --no-cache`, `python -m pyright` over the helper and its tests
- PowerShell static: per-file `Invoke-ScriptAnalyzer` and `Invoke-Formatter` with `scripts/powershell/PoshQC/settings/pssa.settings.psd1` over the 22 changed files
- Pester: `Invoke-Pester` with coverage and result files disabled
- Jest: `npx jest test/packaging/discovery-resources.test.ts` and `npx jest claude-pack-manifest-completeness` in `extensions/drm-copilot`
- Evidence and tiers: `python scripts/dev_tools/validate_evidence_locations.py --root .`; `python -m scripts.dev_tools.check_quality_tiers`
- Real-process probe: `pwsh -NoProfile -File .claude/lib/docs/Invoke-DocsCommand.ps1 -Command inventory -Json [-AnalysisMethod <m>] [-RepositoryRoot <path>]` on a scratch repository holding a copy of `.claude/lib`
- Reviewer scripts: rename-aware AST comparison, AST and tokenize comment audit, JaCoCo and changed-line intersection, SHA-256 mirror check, logical line count
