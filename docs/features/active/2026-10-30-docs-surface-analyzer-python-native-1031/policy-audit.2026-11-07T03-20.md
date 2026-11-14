# Policy Compliance Audit: Python-native docs surface analyzer (#1031)

**Audit Date:** 2026-11-07
**Reviewer:** feature-review agent
**Audit Type:** Re-audit of remediation cycle 2 (prior review set stamp 2026-11-07T00-58)
**Feature Folder:** `docs/features/active/2026-10-30-docs-surface-analyzer-python-native-1031`
**Base Branch:** `origin/epic/documentation-estate-tooling-integration` (tip `e3e4aa551`, fetched at review time)
**Head Branch:** `feature/docs-surface-analyzer-python-native-1031-r2` (head `4aca595d03329a807a2b907bfc859d89384153a3`; clean worktree before this review; no pull request and no workflow run exist for the branch)
**Merge base:** `e3e4aa551808a25c436337bf0dbcf298421a34d6`, equal to the base tip. The item diff is `git diff e3e4aa551...HEAD` (276 paths, 20354 insertions, 266 deletions; 87 paths outside `docs/features/`: 66 added, 21 modified).

**Scope source:** `artifacts/pr_context.summary.txt` and `artifacts/pr_context.appendix.txt` under the worktree, generated 2026-11-07 02:52:25 UTC for head `4aca595d0`, with base and merge base equal to the values above.

**Template source assumption:** the template asset tool was not available in this agent's tool set, so the structure follows the repository templates under `docs/features/templates/policy_audit/` and the previous validated audit.

**Code Under Test (branch diff):**

- Python helper (new, 18 files): `.claude/lib/docs/python/run_docs_python_native.py` and `docs_python_native/{__init__,architecture,call_sites,cli,cli_argparse,cli_click,cli_typer,facts,imports,module_names,protocol,public_api,route_model,route_sites,routes,source,walk}.py`, plus byte-identical bundle copies.
- PowerShell production: new `DocsAnalyzerPythonNative.psm1` and `DocsPythonNativeProtocol.psm1`; edited `DocsAnalyzerRegistry.psm1`, `DocsInventory.psm1` and `Invoke-DocsCommand.ps1`, plus bundle copies.
- Configuration and packaging: `pyproject.toml`, `pack-manifests/python.json` and `core.json`, `extensions/drm-copilot/.vscodeignore`, `packages/mcp-server/prepack.cjs`.
- Tests: 21 Python files under `tests/scripts/claude-lib/docs/python/`; Pester suites under `tests/scripts/claude-lib/docs/`; the fixture `python-native-corpus.json`; 3 guard files under `tests/scripts/claude-runtime/`; the TypeScript test `discovery-resources.test.ts`.
- Feature-folder Markdown: spec, user story, plans and evidence files.

Cycle 2 production and test change (`git diff 94b12db15 HEAD`, outside the feature folder): `.claude/lib/docs/Invoke-DocsCommand.ps1`, its bundle copy, and `tests/scripts/claude-lib/docs/Invoke-DocsCommand.Tests.ps1`.

**Coverage Metrics by Language:**

| Language | Files Changed | Tests | Test Result | Baseline Coverage | Post-Change Coverage | New Code Coverage |
|----------|--------------|-------|-------------|-------------------|---------------------|-------------------|
| Python | 18 production (+18 bundle copies), 21 test files, `pyproject.toml` | 16350 full suite; 251 helper tests | PASS: reviewer `pytest -n auto` 16350 passed, 6 skipped, 0 failed; reviewer helper run 251 of 251 | 96.82% line, 93.83% branch (merged tree before cycle 1) | 96.84% line, 93.88% branch (`artifacts/python/lcov.info`, 384 files, 34071 of 35181 lines, 12527 of 13344 branches) | 99.28% line (1801 of 1814), 97.22% branch (805 of 828) over the 18 helper files; minimum per file 97.35% line (`source.py`), 90.00% branch (`walk.py`) |
| PowerShell | 2 new and 3 edited production (+5 bundle copies), Pester suites, 3 guard files | 16543 merged parallel run; 2178 reviewer in-scope run | PASS: `Invoke-PoshQCParallelTest` 16543 tests, 0 failures, 0 errors, 10 skipped; reviewer 2178 of 2178 | 93.77% line (executor P0-T8, full `tests/scripts`, earlier base) | 95.26% line (32371 of 33981, canonical `artifacts/pester/powershell-coverage.xml`) | 100.00% line for both new modules (93 of 93, 132 of 132); edited files 100.00%, 100.00%, 87.97%; 0 changed lines uncovered |
| TypeScript | 1 test file (`discovery-resources.test.ts`); 1 JavaScript build script (`prepack.cjs`) | 9 + 24 reviewer Jest tests; 5333 executor full suite | PASS: reviewer 33 of 33; executor 5333 passed, 0 failed | 97.10% line, 93.77% branch (`baseline-jest-coverage`) | 97.10% line, 93.77% branch (63029 of 64911, 9596 of 10234; `extensions/drm-copilot/coverage/lcov.info`) | N/A - no TypeScript production file in the diff; `prepack.cjs` lies outside `collectCoverageFrom` |

C# and Bash: zero changed files on the branch (`git diff --name-only e3e4aa551...HEAD` filtered by `*.cs`, `*.sh`, `*.bats`: no match). JSON data files have no coverage tool.

### Coverage Evidence Checklist

- Python baseline coverage artifact: `evidence/remediation-baseline/baseline-carried-coverage.2026-11-07T01-33.md`; `evidence/qa-gates/coverage-delta.2026-11-07T02-46.md`
- Python post-change coverage artifact: `artifacts/python/lcov.info` (384 files, repo-wide, written 2026-11-07T02-45 UTC; parsed by the reviewer)
- PowerShell baseline coverage artifact: `evidence/baseline/baseline-pester-coverage.2026-11-04T15-53.md`; `evidence/remediation-baseline/baseline-pester-docs-coverage.2026-11-07T01-33.md`
- PowerShell post-change coverage artifact: `artifacts/pester/powershell-coverage.xml` (342 source files, merged parallel run, written 2026-11-07T02-34 UTC; parsed by the reviewer)
- TypeScript baseline coverage artifact: `evidence/remediation-baseline/baseline-jest-coverage.2026-11-06T23-35.md`; `evidence/qa-gates/coverage-delta.2026-11-07T02-46.md`
- TypeScript post-change coverage artifact: `extensions/drm-copilot/coverage/lcov.info` (252 source files)
- Per-language comparison summary: section 1.2.1 of this audit

---

## Executive Summary

Remediation cycle 2 closes finding F6 of the 2026-11-07T00-58 review and the Minor items M1, M2 and M4. `New-DocsCommandContext` now builds `InvokeProcess` as a closure over the repository root, and the new private function `Invoke-DocsContextProcess` passes that root to `Invoke-DocsProcess -WorkingDirectory`.

The fix was verified by execution, not only from the evidence records. A real-process probe on a scratch destination whose path contains a space shows `auto` and `native` exit 0 from another directory, and `native` exit 0 with a relative `-RepositoryRoot`, each with 10 native elements whose identifier set equals the run from the root. A decoy helper planted at the same relative path in the caller's location did not run. Three mutants of the fix each fail exactly the new Pester case, and the unmodified control passes 48 of 48.

The re-audit also ran a parity probe at a scale no committed test reaches: 366 real Python files from this repository, with `scanner` and `native` compared element by element. All 3636 elements agree on `element_id`, digest, `parent_id`, `name` and `line_range`, and the diagnostic counts are equal.

Finding F5 is no longer carried as blocking. `.claude/skills/acceptance-criteria-tracking/SKILL.md` `### CI-Dependent Criteria` states that such a criterion cannot be verified before the pull request exists and is listed as pending-CI, and `.claude/skills/orchestrate/SKILL.md` `## PR Creation Gate` condition 2 accepts that state. Keeping F5 blocking would route the run to the review-time wait branch for a CI result that requires the pull request, which that same blocking finding prevents. S10, U10, S22 and U22 stay unchecked and are listed as pending-CI for S9. The issue 1019 audit `feature-audit.2026-11-06T22-22.md` lists its CI-dependent criterion the same way.

Findings: zero blocking. Overall verdict: PASS.

**Policy documents evaluated:**
- PASS `.claude/rules/self-explanatory-code-commenting.md` (Minor residual for test helpers, code review item M3)
- PASS `.claude/rules/general-code-change.md`
- PASS `.claude/rules/general-unit-test.md`
- PASS `.claude/rules/quality-tiers.md` (`quality-tiers.yml` exists; reviewer `check_quality_tiers` OK, 30 entries, file unchanged)

**Language-specific policies evaluated:**
- PASS `python-code-change.instructions.md` + `python-unit-test.instructions.md`
- PASS `powershell-code-change.instructions.md` + `powershell-unit-test.instructions.md`
- PASS `typescript-unit-test.instructions.md` (test-only change; Jest passes)
- N/A C# and Bash: no file changed

**Temporary artifacts cleanup:**
- PASS No temporary script is committed; `git status` was clean before this review wrote its artifacts
- PASS Reviewer scripts, scratch destination repositories and the mutant copy live in the session scratchpad. No `__pycache__` was written under the helper or its bundle copy

---

## Rejected Scope Narrowing

No scope narrowing was detected, and none was rejected. The caller prompt names the resolved base branch, the merge base and the full feature-versus-base review.

The owner directive recorded in the previous audit, which waived the single-process, seeded-shuffle and reversed-order runs, is not relied on here. The cycle 2 plan disregarded that waiver and the executor ran the full set: `c2-isolation-pester-shuffled`, `c2-isolation-pester-fresh`, `c2-isolation-python-reversed`, `c2-isolation-pester-parallel`, `c2-isolation-python-parallel` and `c2-isolation-jest`.

---

## 1. General Unit Test Policy Compliance

### 1.1 Core Principles

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Independence** | PASS | Three seeded Pester file orders, a fresh single-process run (16543 tests, 0 failures), reversed Python modules (251 passed), and the two parallel runs. Reviewer `pytest -n auto` 16350 passed. |
| **Isolation** | PASS | The new case tests one behavior of one member. One Pytest module per helper module. |
| **Fast Execution** | PASS | The new case uses a mock and starts no process. Helper suite 251 tests in 1.14 s. |
| **Determinism** | PASS | No process, clock or network in tests; seam scriptblocks are test-local. Roots in the new case derive from the test location. |
| **Readability & Maintainability** | PASS | The new case has a descriptive title and Arrange, Act and Assert comments. Minor residual in code review item M3. |

### 1.2 Coverage and Scenarios

| Requirement | Status | Evidence |
|------------|--------|----------|
| Baseline coverage documented | PASS | `coverage-delta.2026-11-07T02-46.md`; `baseline-pester-docs-coverage`; `baseline-carried-coverage`. |
| Canonical coverage artifacts present | PASS | All three exist. M4 closed: `artifacts/python/lcov.info` is now the repo-wide file (384 `SF:` records). |
| New-file line >= 85% and branch >= 75% (Python) | PASS | All eighteen helper files; minimum 97.35% line, 90.00% branch; the reviewer rerun gives identical totals. |
| New-file line >= 85% (PowerShell) | PASS | Both new modules 100.00%. |
| Modified-file line >= 85% (PowerShell) | PASS | `Invoke-DocsCommand.ps1` 87.97% (139 of 158), up from 87.82%. The 19 missed lines are the `Invoke-DocsProcess` body (214 to 230) and the guarded write body of `Write-DocsFileText` (253 to 255), both documented as not executed by tests. |
| No regression on changed lines | PASS | Reviewer intersection of JaCoCo missed lines with `git diff -U0` changed lines: 0 uncovered changed lines in the five PowerShell files, including all 29 in `Invoke-DocsCommand.ps1`. Python changed lines are in new files. |
| Repo-wide thresholds | PASS | Python 96.84% line, 93.88% branch; PowerShell 95.26% line; TypeScript 97.10% line, 93.77% branch. |
| Coverage exclusions | PASS | `pyproject.toml` adds the helper to `source`; no production path excluded. |
| Positive, negative, edge, error flows | PASS | The root reaches the seam for two distinct contexts. Earlier flows unchanged and passing. |
| Concurrency / state transitions | PASS | No concurrency; candidate fallback order is tested. |

### 1.2.1 Per-Language Coverage Comparison

- Python: Baseline: 96.82% (line; branch 93.83%). Post-change: 96.84% (line; branch 93.88%). Change: +0.02 points line, +0.05 points branch. Disposition: PASS. New/changed-code coverage: 99.28% line and 97.22% branch over the eighteen new helper files. Evidence: `artifacts/python/lcov.info`; reviewer helper rerun; `evidence/qa-gates/coverage-delta.2026-11-07T02-46.md`.
- PowerShell: Baseline: 93.77% (line, earlier base). Post-change: 95.26% (line). Change: +1.49 points. Disposition: PASS. New/changed-code coverage: 100.00% line for both new modules, with 0 uncovered changed lines across the five files. Evidence: `artifacts/pester/powershell-coverage.xml`; `evidence/qa-gates/c2-powershell-per-file-coverage.2026-11-07T02-35.md`. No branch threshold applies to PowerShell.
- TypeScript: Baseline: 97.10% (line; branch 93.77%). Post-change: 97.10% (line; branch 93.77%). Change: 0.00 points. Disposition: PASS. New/changed-code coverage: N/A - no TypeScript production file in the diff. Evidence: `extensions/drm-copilot/coverage/lcov.info`; `evidence/qa-gates/coverage-delta.2026-11-07T02-46.md`.

Assumptions:

- A1: the PowerShell artifact was written 2026-11-07T02-34 UTC, after the last PowerShell production commit `4fd8dda72` (2026-11-07T01-41 UTC). The commits after it change only the feature folder, so the artifact describes this head. The merged JUnit file reads 16543 tests, 0 failures, 0 errors.
- A2: the Python artifact was written 2026-11-07T02-45 UTC, and no Python file changed in cycle 2.
- A3: the contract table names `coverage/lcov.info`. The repository's Jest project writes `extensions/drm-copilot/coverage/lcov.info`, and no root TypeScript project exists. No TypeScript source changed after that file was written. The branch figure is 93.77% when rounded (9596 of 10234); evidence records truncate it to 93.76%.

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
| `Invoke-DocsCommand.ps1` (edited) | 139 / 158 | 87.97% | 0 of 29 |

### 1.3 Test Structure and Diagnostics

| Requirement | Status | Evidence |
|------------|--------|----------|
| Arrange-Act-Assert | PASS | The new case has the three labelled sections. |
| Clear failure messages | PASS | `Should -Invoke` with a parameter filter names the expected call; each mutant failed only that case. |
| Clean test output | PASS | Reviewer runs. |

### 1.4 External Dependencies and Environment

| Requirement | Status | Evidence |
|------------|--------|----------|
| No external services | PASS | `c2-test-hygiene.2026-11-07T02-47.md`. |
| No temporary files | PASS | `c2-test-hygiene`; the new case only composes path strings. |
| No mutable global state | PASS | `conftest.py` sets only `sys.dont_write_bytecode`. |

---

## 2. General Code Change Policy Compliance

### 2.1 Design Principles

| Requirement | Status | Evidence |
|------------|--------|----------|
| Simplicity first | PASS | One short function, and the closure form the other repository members already use. |
| Reusability | PASS | Reuses the `Operation` pattern; `Invoke-DocsProcess` keeps its signature. |
| Extensibility | PASS | Registry rows per identifier; `protocol_version`; callers keep the four-argument call shape. |
| Separation of concerns | PASS | Validation and shaping stay in the pure `ConvertTo-DocsProcess*` functions. |

### 2.2 Module and File Structure

| Requirement | Status | Evidence |
|------------|--------|----------|
| At or below the 800-line hard limit | PASS | 82 covered files measured; largest 538 logical lines (`enforcement-hooks-no-python-invocation.Tests.ps1`); largest production file 485 (`Invoke-DocsCommand.ps1`); `config/file-size-baseline.json` not in the diff. |
| 700-line advisory tier | PASS | No covered file at or above 700 lines. |
| Explicit exports / public vs internal | PASS | `Export-ModuleMember` lists; `Invoke-DocsContextProcess` is a private script function. |
| No circular dependencies | PASS | Pyright clean; no import added in cycle 2. |

### 2.3 Error Handling

| Requirement | Status | Evidence |
|------------|--------|----------|
| Fail fast, no silent catch | PASS | `RequestError`; boundary handler in `main`; named `DOCS_PYTHON_NATIVE_SCANNER_ROW_MISSING`. |
| Behavior matches the published contract | PASS | F6 closed: spec `### Interpreter discovery and invocation` states that the working directory is the repository root, and the real-process probe confirms it (section 6). |

### 2.4 Toolchain Execution

| Step | Status | Evidence |
|------|--------|----------|
| 1. Formatting | PASS | Reviewer Black: 39 files unchanged; `Invoke-Formatter` over 23 files: 0 differences. |
| 2. Linting | PASS | Ruff: all checks passed; PSScriptAnalyzer with `pssa.settings.psd1` over 23 files including `.claude/lib`: 0 findings. |
| 3. Type checking | PASS | Reviewer Pyright: 0 errors, 0 warnings, 0 informations. |
| 4. Architecture-boundary tests | PASS | `ClaudeLibModuleConvention.Tests.ps1` and the guard suite in the reviewer Pester run. |
| 5. Unit tests | PASS | Pytest 16350 passed; Pester 2178 of 2178 (reviewer) and 16543 tests with 0 failures (parallel). |
| 6. Contract / schema checks | PASS | Push-down and configuration-pin Pytest 189 of 189; manifest-completeness Jest 24 of 24. |
| 7. Integration tests | PASS | `DocsInventory.PythonNative.Tests.ps1`; reviewer real-process inventory probes. |

---

## 3. Language-Specific Code Change Policy Compliance

### 3A Python

| Requirement | Status | Evidence |
|------------|--------|----------|
| Black / Ruff / Pyright | PASS | Section 2.4. |
| Strong typing, no `Any` | PASS | Pyright strict clean. |
| Dataclasses for value objects | PASS | `RouteSite`, `RouteMount`, `Fact`, `ParsedModule`. |
| Specific exceptions | PASS | `RequestError`; boundary handler only in `main`. |
| Docstrings and comments (commenting rule) | PASS | No Python file changed in cycle 2; the previous audit's AST audit stands. |

### 3B PowerShell

| Requirement | Status | Evidence |
|------------|--------|----------|
| Formatting | PASS | 0 differences. |
| PSScriptAnalyzer | PASS | 0 findings over 23 files. |
| Advanced functions, parameter validation | PASS | `CmdletBinding` and `OutputType` on the new function. Its four process arguments stay untyped so `ConvertTo-DocsProcessRequest` validates them. |
| Approved verbs | PASS | `Invoke`. |
| No global state | PASS | The root travels in the closure; no script-scope state added. |
| ShouldProcess for state-changing actions | PASS | No new function changes system state. |
| Seam pattern | PASS | Interpreter start only through the `[scriptblock]` member, in one function; the guard suite passes with its one allowlist entry. |

### 3C TypeScript / JavaScript

| Requirement | Status | Evidence |
|------------|--------|----------|
| Jest test passes | PASS | 9 of 9 and 24 of 24. |
| Build-script change scoped | PASS | `prepack.cjs` unchanged in cycle 2; the carve-out is prefix-based. |

### 3D JSON

| Requirement | Status | Evidence |
|------------|--------|----------|
| Strict JSON | PASS | Unchanged in cycle 2; parsed by the suites. |
| Manifest completeness | PASS | 18 tracked helper files; the manifest-completeness Pytest and Jest suites pass. |

---

## 4. Language-Specific Unit Test Policy Compliance

### 4A Python Unit Tests

| Requirement | Status | Evidence |
|------------|--------|----------|
| Pytest, location mirrors source | PASS | `tests/scripts/claude-lib/docs/python/test_docs_python_native_<area>.py`. |
| Mocking sparingly | PASS | Failures injected through parameters. |
| Naming | PASS | Descriptive `test_` names. |
| Docstrings and comments | PASS | Unchanged in cycle 2. Minor item M3. |

### 4B PowerShell Unit Tests

| Requirement | Status | Evidence |
|------------|--------|----------|
| Pester v5, `*.Tests.ps1`, mirrored location | PASS | Suites under `tests/scripts/claude-lib/docs/`. |
| Mocking sparingly | PASS | One mock at the process seam, as in the adjacent forward test. |
| PoshQC test command | PASS | Executor coverage through `Invoke-PoshQCParallelTest`; the reviewer used `Invoke-Pester` without coverage so no canonical file was overwritten. |

---

## 5. Test Coverage Detail

See section 1.2.1. Figures were read from the artifacts, not from the evidence tables, and agree with the executor record.

---

## 6. Test Execution Metrics

| Run | Tests | Passed | Failed | Source |
|---|---|---|---|---|
| Reviewer `pytest -n auto`, full tree | 16356 | 16350 (6 skipped) | 0 | this review |
| `Invoke-PoshQCParallelTest`, 8 shards | 16543 | 16533 (10 skipped) | 0 | merged `artifacts/pester/pester-junit.xml` |
| Reviewer Pester, docs folder plus guard and convention suites, coverage off | 2178 | 2178 | 0 | this review |
| Reviewer helper Pytest with coverage | 251 | 251 | 0 | this review |
| Reviewer push-down and configuration-pin Pytest | 189 | 189 | 0 | this review |
| Reviewer Jest `discovery-resources` and `claude-pack-manifest-completeness` | 33 | 33 | 0 | this review |

Reviewer probes at this head, with a real interpreter on a scratch destination at a path containing a space:

- Repository root: `scanner`, `native` and `auto` exit 0 with 10 elements and one identifier set.
- Another directory with an absolute `-RepositoryRoot`: `auto` and `native` exit 0 with 10 native elements and no diagnostic. The previous head gave scanner elements with `exit-nonzero`, and exit 3.
- Another directory with a relative `-RepositoryRoot`: `native` exit 0 with 10 native elements.
- Decoy: a `run_docs_python_native.py` planted at the same relative path in the caller's location did not run. The native result was unchanged and no marker file appeared.
- Pack absent from another directory: `auto` exit 0 with 10 scanner elements and no diagnostic; `native` exit 3 with reason `pack-absent`.
- Reduced `PATH` from another directory: exit 0 with native elements. This appears to be `Process.Start` finding `C:\Windows\py.exe` through the Windows directory search, so the probe did not reach the `interpreter-not-found` branch on this host; that branch rests on its Pester cases.
- Parity at scale: 366 Python files plus the configuration files beside them, from `scripts/dev_tools` and `packages/discovery-runtime`, `scanner` against `native`. 3636 elements each; no element in only one run; 0 differences in `element_id`, `source_sha256`, `parent_id`, `name` or `line_range`; diagnostic counts equal for all eight codes. The native run has 2567 native rows and 1069 `config-files` scanner rows, with no scanner row on a `.py` path, so the helper completed inside its 120-second bound.
- Parse-failure file, BOM file with a non-ASCII name, and CRLF file together: exit 1 under all three methods, from the blocking lexer diagnostics on the parse-failure file, with the same 16 element identifiers. One non-blocking difference is recorded as code review item M7.

Mutants of `Invoke-DocsContextProcess` in a scratch copy (control 48 of 48): dropping `-WorkingDirectory`, passing the current location, and passing a constant path each fail exactly the new case (47 of 48).

---

## 7. Code Quality Checks

- Black: 39 files unchanged. Ruff: all checks passed. Pyright: 0 errors.
- PSScriptAnalyzer: 0 findings over 23 files. Formatter: 0 differences.
- File size: maximum 538 logical lines; no Warning row; no file above 800; no baseline entry added.
- Bundle mirror: 101 of 101 tracked `.claude/lib/docs/` files SHA-256 identical to their copies, including all 23 changed by this branch.
- Bytecode: no `__pycache__` or `.pyc` under the helper or its bundle copy.
- Tier: `quality-tiers.yml` unchanged; `check_quality_tiers` OK (30 entries).
- `modified-workflow-needs-green-run`: not triggered; the diff has no path under `.github/workflows/`, `.github/actions/` or `scripts/benchmarks/`.

---

## Evidence Location Compliance

`validate_evidence_locations.py --root .` in the worktree exited 0 with no output. The branch diff contains no path under `artifacts/baselines/`, `artifacts/qa/`, `artifacts/evidence/` or `artifacts/coverage/`. Spec criterion S9 names `<FEATURE>/evidence/coverage/`; the plan's `## Deviations from spec.md` item 10 records `EVIDENCE_LOCATION_OVERRIDE_REJECTED: <FEATURE>/evidence/coverage/ replaced with <FEATURE>/evidence/qa-gates/`, and the coverage records are in `evidence/qa-gates/`. No violation.

---

## 8. Gaps and Exceptions

1. **Closed in cycle 2:** F6, M1, M2 and M4. F1 to F4 stay closed.
2. **Pending-CI, non-blocking:** S10, U10, S22 and U22 (previously F5). Local Black, Ruff, Pyright and configuration pins pass; the 3.11 floor and the named checks need CI on the pull request head. The item's own orchestrator run checks them off at S9.
3. **Reclassification disclosed:** the two previous reviews carried F5 as a finding with class `awaiting_ci`. This review lists it as pending-CI instead, for the reasons in the Executive Summary. `modified-workflow-needs-green-run`, the rule that defines a review-time `awaiting_ci` finding, is not triggered.
4. **Warnings.** None.
5. **Minor and Info items.** M3, M5, M6, M7 and M8 in the code review. None is blocking.

The change to the S4, U4, S13 and U13 criterion texts is backed by owner decision `1031-ac-text-s4-s13` option (a), recorded in `docs/features/epics/documentation-estate-tooling/epic-status.md`. No policy exception is claimed. Tier classification applies and is satisfied.

---

## 9. Summary of Changes

Cycle 2 commits (`git log 94b12db15..HEAD`): re-audit record `67a4a0639`; plan `1a3733742`; baseline `8d44c215b`; working-directory fix with test and bundle copy `4fd8dda72`; specification corrections `7176a121d`; QA loop and self-review `7a9c4423f`; plan check-off `4aca595d0`.

---

## 10. Compliance Verdict

**PASS.** Zero blocking findings. The branch may advance to the PR creation gate, with S10, U10, S22 and U22 listed as pending-CI for S9.

---

## Appendix A: Test Inventory

Reviewer Pester run at head `4aca595d0` (`Invoke-Pester`, coverage off, one process, 5 min 42 s): `tests/scripts/claude-lib/docs` plus `enforcement-hooks-no-python-invocation.Tests.ps1` and `ClaudeLibModuleConvention.Tests.ps1`, 2178 tests, all passed.

Python: 20 test modules plus `conftest.py`, 251 helper tests, all passed.

## Appendix B: Toolchain Commands Reference

All Python commands ran in the worktree with `.venv/Scripts/python.exe` (Python 3.13.17) through scratch `.sh` launchers.

- Pytest parallel: `python -B -m pytest -c pyproject.toml -o addopts="" -p no:cacheprovider -n auto -q`
- Helper Pytest: the same flags over `tests/scripts/claude-lib/docs/python` with `--cov=docs_python_native --cov=run_docs_python_native --cov-branch --cov-report=json:<scratch>`
- Contract Pytest: the three `test_push_down_*` modules, `test_pyright_config_alignment.py`, `test_ruff_config_alignment.py`, `tests/discovery_runtime/test_package_contract.py`
- Static: `python -m black --check`, `python -m ruff check --no-cache`, `python -m pyright` over the helper and its tests
- PowerShell static: per-file `Invoke-ScriptAnalyzer` and `Invoke-Formatter` with `scripts/powershell/PoshQC/settings/pssa.settings.psd1` over the 23 changed files
- Pester: `Invoke-Pester` with coverage and result files disabled
- Jest: `npx jest test/packaging/discovery-resources.test.ts claude-pack-manifest-completeness --coverage=false` in `extensions/drm-copilot`
- Evidence and tiers: `python scripts/dev_tools/validate_evidence_locations.py --root .`; `python -m scripts.dev_tools.check_quality_tiers`
- Real-process probe: `pwsh -NoProfile -File .claude/lib/docs/Invoke-DocsCommand.ps1 -Command inventory -Json [-AnalysisMethod <m>] [-RepositoryRoot <path>]` on scratch repositories holding a copy of `.claude/lib`
- Reviewer scripts: JaCoCo and changed-line intersection, LCOV totals, SHA-256 mirror check with `sha256sum`, logical line count, element-by-element method comparison, mutant runner
