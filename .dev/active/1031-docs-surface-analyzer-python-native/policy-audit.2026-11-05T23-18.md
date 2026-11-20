# Policy Compliance Audit: Python-native docs surface analyzer (#1031)

**Audit Date:** 2026-11-05
**Reviewer:** feature-review agent
**Audit Type:** Initial full-branch review
**Feature Folder:** `docs/features/active/2026-10-30-docs-surface-analyzer-python-native-1031`
**Base Branch:** `origin/epic/documentation-estate-tooling-integration` (tip `eb3436e62`, fetched at review time)
**Head Branch:** `feature/docs-surface-analyzer-python-native-1031-r2` (head `e6e828de9476b6c4a776d3acf79e8bd3e77446a4`, equal to the remote branch; clean worktree; no pull request exists)
**Merge base:** `729ff55ef6b8fcfcf632d9d2220a674bb437bf7e` from `git merge-base origin/epic/documentation-estate-tooling-integration HEAD`. The item diff is `git diff 729ff55ef...HEAD` (147 paths, 12065 insertions, 176 deletions; 35 commits including the integration merge `e34dbba74`).

**Scope source assumption:** `artifacts/pr_context.summary.txt` and `artifacts/pr_context.appendix.txt` do not exist in the worktree and no PR-context collector tool is exposed to this agent. The direct merge-base diff above is the scope source.

**Code Under Test (branch diff, 147 paths):**

- Python helper (new, 12 files): `.claude/lib/docs/python/run_docs_python_native.py` and `docs_python_native/{__init__,architecture,cli,cli_argparse,cli_click,cli_typer,imports,protocol,public_api,routes,source}.py`, plus byte-identical bundle copies.
- PowerShell production: new `DocsAnalyzerPythonNative.psm1` and `DocsPythonNativeProtocol.psm1`; edited `DocsAnalyzerRegistry.psm1` (four rows), `DocsInventory.psm1` (`-AnalysisMethod` integration) and `Invoke-DocsCommand.ps1` (one option), plus bundle copies.
- Configuration and packaging: `pyproject.toml` (pytest `pythonpath`, coverage `source`, Pyright `include`/`extraPaths`), `pack-manifests/python.json` and `core.json`, `extensions/drm-copilot/.vscodeignore`, `packages/mcp-server/prepack.cjs` (JavaScript build script).
- Tests: 15 Python files under `tests/scripts/claude-lib/docs/python/`; 4 new and 5 edited Pester suites under `tests/scripts/claude-lib/docs/`; the JSON fixture `python-native-corpus.json`; 3 edited guard files under `tests/scripts/claude-runtime/`; the TypeScript test `discovery-resources.test.ts`.
- Feature-folder Markdown: spec, user story, plan and 77 evidence files.

**Coverage Metrics by Language:**

| Language | Files Changed | Tests | Test Result | Baseline Coverage | Post-Change Coverage | New Code Coverage |
|----------|--------------|-------|-------------|-------------------|---------------------|-------------------|
| Python | 12 production (+12 bundle copies), 15 test files, `pyproject.toml` | 208 helper tests (reviewer); 16269 full suite (executor) | ✅ reviewer 208 of 208; executor full suite 16269 passed, 0 failed | 96.67% line, 93.64% branch (executor P0-T6, full suite) | 96.79% line, 93.82% branch (executor P6-T4; canonical `artifacts/python/lcov.info` absent, F3) | 98.93% line (1756 of 1775), 96.50% branch (799 of 828) over the 12 helper files; minimum per file 96.90% line (`cli_click.py`), 92.31% branch (`source.py`) |
| PowerShell | 2 new and 3 edited production (+5 bundle copies), 9 Pester suites, 3 guard files | 190 in-scope tests (reviewer R1) | ✅ reviewer R1 190 of 190; executor full tree 409 failures equal to the merge-base set (F5) | 93.77% line (executor P0-T8, full `tests/scripts`) | 94.33% line (executor P6-T9; canonical `artifacts/pester/powershell-coverage.xml` absent, F3) | 100.00% line for both new modules (89 of 89, 132 of 132); edited files 100.00%, 100.00%, 87.82% with every changed line covered (executor P6-T9) |
| TypeScript | 1 test file (`discovery-resources.test.ts`); 1 JavaScript build script (`prepack.cjs`) | 9 + 24 Jest tests (reviewer) | ✅ 33 of 33 | N/A - no TypeScript production file changed; canonical `coverage/lcov.info` absent (F3) | N/A - no TypeScript production file changed; canonical `coverage/lcov.info` absent (F3) | N/A - no TypeScript production file in the diff; `prepack.cjs` lies outside `collectCoverageFrom` (`src/**/*.ts`), unchanged by the branch |

C# and Bash: zero changed files on the branch (`git diff --name-only 729ff55ef...HEAD` filtered by `*.cs`, `*.sh`, `*.bats`: no match). JSON data files (fixture and two manifests) have no coverage tool.

### Coverage Evidence Checklist

- Python baseline coverage artifact: `evidence/baseline/baseline-pytest-coverage.2026-11-04T15-11.md` (executor record; the JSON was written to a scratch path)
- Python post-change coverage artifact: reviewer scratch JSON from the helper run (figures identical to `evidence/qa-gates/qa-python-per-file-coverage.2026-11-04T19-59.md`); canonical `artifacts/python/lcov.info` absent (F3)
- PowerShell baseline coverage artifact: `evidence/baseline/baseline-pester-coverage.2026-11-04T15-53.md`
- PowerShell post-change coverage artifact: reviewer scratch JaCoCo from R1 (scoped to the five files); canonical `artifacts/pester/powershell-coverage.xml` absent (F3)
- TypeScript baseline coverage artifact: N/A - no TypeScript production file changed; canonical `coverage/lcov.info` absent (F3)
- TypeScript post-change coverage artifact: N/A - no TypeScript production file changed; canonical `coverage/lcov.info` absent (F3)
- Per-language comparison summary: section 1.2.1 of this audit

---

## Executive Summary

The branch delivers the D3 Python-native analyzer: a standard-library helper that parses in-memory sources with `ast.parse` and returns raw facts over JSON, a PowerShell adapter and pure response validator that start the helper only through the command-context seam and fall back to the 1022 scanner, four native registry rows, an `-AnalysisMethod` option on `inventory`, pack-manifest and packaging carve-outs, and a single D3 allowlist entry in the Python-invocation guard.

The reviewer re-ran at head `e6e828de9`: the helper Pytest suite with per-file coverage (R2), Black, Ruff and Pyright (R3), the push-down and configuration-pin Pytest modules (R4), the two packaging Jest suites (R5), bundle SHA-256 parity and logical line counts (R6), PSScriptAnalyzer and `Invoke-Formatter` over the 22 changed `.ps1`/`.psm1` files (R7), the in-scope Pester suites (R1; a scoped coverage run over the full docs folder was started but had not finished when this audit was written), and the evidence-location validator (R8).

Findings: four autonomous blocking findings, F1 (Python commenting and docstring policy, confirmed independently from the executor's self-review), F2 (PSScriptAnalyzer warnings in the two new modules), F3 (canonical coverage artifacts absent), F4 (spec text diverges from adopted names and shapes), and one `awaiting_ci` finding, F5 (CI-dependent criteria and the zero-failure Pester gate). No file-size Warning. Overall verdict: REMEDIATION_REQUIRED.

**Policy documents evaluated:**
- ❌ `.claude/rules/self-explanatory-code-commenting.md` / `.github/instructions/self-explanatory-code-commenting.instructions.md` (F1)
- ✅ `.claude/rules/general-code-change.md` / `general-code-change.instructions.md`
- ✅ `.claude/rules/general-unit-test.md` / `general-unit-test.instructions.md`
- ✅ `.claude/rules/quality-tiers.md` (`quality-tiers.yml` exists; executor `check_quality_tiers` OK, file unchanged)

**Language-specific policies evaluated:**
- ❌ `python-code-change.instructions.md` + `python-unit-test.instructions.md` (toolchain clean; documentation rules F1)
- ❌ `powershell-code-change.instructions.md` + `powershell-unit-test.instructions.md` (PSScriptAnalyzer F2)
- ✅ `typescript-unit-test.instructions.md` (test-only change; Jest passes)
- N/A C# and Bash: no file changed

**Temporary artifacts cleanup:**
- ✅ No temporary script is committed; executor helpers are referenced as `SCRATCH/...` outside the repository
- ✅ Reviewer scripts and outputs live in the session scratchpad; the reviewer added only this review's four artifacts to the worktree; no `__pycache__` was written (`-B`, `-p no:cacheprovider`)

---

## Rejected Scope Narrowing

No scope narrowing was detected in the caller prompt. The prompt names the full merge-base diff against `origin/epic/documentation-estate-tooling-integration`. Its instruction to classify P6-T9, P6-T14, S10, U10, S22 and U22 as `awaiting_ci` matches the acceptance-criteria tracking rule for CI-dependent criteria and does not narrow the coverage audit, which is performed for Python, PowerShell and TypeScript in section 1.2.1.

---

## 1. General Unit Test Policy Compliance

### 1.1 Core Principles

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Independence** | ✅ PASS | Reversed-order Python run 208 of 208 (`isolation-python-reversed.2026-11-04T20-44.md`); three seeded shuffled Pester runs, 177 of 177 each (`isolation-pester-shuffled.2026-11-04T20-49.md`); seeded Jest run (`isolation-jest.2026-11-04T20-44.md`). |
| **Isolation** | ✅ PASS | One Pytest module per helper module; Pester suites per module (protocol, adapter, parity, inventory). |
| **Fast Execution** | ✅ PASS | Reviewer helper run 208 tests in 1.07 s. |
| **Determinism** | ✅ PASS | No process, clock or network in tests; seam scriptblocks are test-local; seeds recorded. |
| **Readability & Maintainability** | ❌ FAIL | Descriptive names, but 13 test loops lack the intent comment the Python commenting rule requires (F1). |

### 1.2 Coverage and Scenarios

| Requirement | Status | Evidence |
|------------|--------|----------|
| Baseline coverage documented | ✅ PASS | `baseline-pytest-coverage.2026-11-04T15-11.md`, `baseline-pester-coverage.2026-11-04T15-53.md`. |
| Canonical coverage artifacts present | ❌ FAIL | `artifacts/python/lcov.info`, `artifacts/pester/powershell-coverage.xml` and `coverage/lcov.info` absent (F3). |
| New-file line >= 85% and branch >= 75% (Python) | ✅ PASS | Reviewer R2: all twelve helper files, minimum 96.90% line and 92.31% branch. |
| New-file line >= 85% (PowerShell) | ✅ PASS | Per-file figures in 1.2.1. |
| No regression on changed lines | ✅ PASS | Per-file figures in 1.2.1; Python changed lines are all in new files. |
| Repo-wide thresholds | ❌ FAIL | Executor figures (Python 96.79% / 93.82%, PowerShell 94.33%) exceed the thresholds but cannot be read from a canonical artifact at this head (F3); the CI reports on the PR head are the next source (F5). |
| Coverage exclusions | ✅ PASS | `pyproject.toml` `[tool.coverage.run] source` gains `.claude/lib/docs/python`; `omit` unchanged; `config/poshqc-coverage.json` not in the diff and measures `.claude/lib`. |
| Positive, negative, edge, error flows | ✅ PASS | Corpus round trip per identifier; each request defect and response defect; BOM, CRLF/CR, U+2028, form feed; depth and cycle limits; exit 2/3/4; each reason token. |
| Concurrency / state transitions | ✅ PASS | No concurrency; candidate fallback order with later-success use is tested (`p4-interpreter`). |

### 1.2.1 Per-Language Coverage Comparison

- Python: Baseline: 96.67% (executor P0-T6 full suite, line; branch 93.64%). Post-change: 96.79% (executor P6-T4 full suite, line; branch 93.82%). Change: +0.12 points line, +0.18 points branch. Disposition: FAIL. New/changed-code coverage: 98.93% line and 96.50% branch over the twelve new helper files (reviewer R2, per file 96.90% to 100% line and 92.31% to 100% branch, identical to the executor record). Evidence: reviewer R2 JSON; `evidence/qa-gates/qa-pytest-coverage.2026-11-04T19-59.md`; `evidence/qa-gates/coverage-delta.2026-11-04T20-43.md`. The FAIL is F3 (canonical `artifacts/python/lcov.info` absent at this head); every measured figure meets the thresholds.
- PowerShell: Baseline: 93.77% (executor P0-T8, full `tests/scripts`). Post-change: 94.33% (executor P6-T9). Change: +0.56 points. Disposition: FAIL. New/changed-code coverage: 100.00% line for both new modules and every changed line of the three edited files covered (executor P6-T9 per-file figures; production files unchanged since that run). Evidence: reviewer R1 JaCoCo; `evidence/qa-gates/qa-pester-coverage.2026-11-04T20-43.md`. The FAIL is F3 (canonical `artifacts/pester/powershell-coverage.xml` absent at this head); no branch threshold applies to PowerShell.
- TypeScript: N/A - no TypeScript production file changed (one Jest test file only); the canonical `coverage/lcov.info` is absent and is regenerated under F3.

Per-file Python coverage (reviewer R2):

| File | Line (covered/statements) | Branch (covered/branches) |
|---|---|---|
| `run_docs_python_native.py` | 100.00% (15/15) | 100.00% (4/4) |
| `docs_python_native/__init__.py` | 100.00% (0/0) | 100.00% (0/0) |
| `architecture.py` | 100.00% (69/69) | 97.37% (37/38) |
| `cli.py` | 99.04% (103/104) | 97.83% (45/46) |
| `cli_argparse.py` | 99.07% (214/216) | 95.28% (101/106) |
| `cli_click.py` | 96.90% (219/226) | 93.85% (122/130) |
| `cli_typer.py` | 99.48% (190/191) | 95.83% (92/96) |
| `imports.py` | 99.54% (218/219) | 97.87% (92/94) |
| `protocol.py` | 100.00% (150/150) | 100.00% (50/50) |
| `public_api.py` | 98.08% (153/156) | 96.88% (93/96) |
| `routes.py` | 100.00% (281/281) | 99.14% (115/116) |
| `source.py` | 97.30% (144/148) | 92.31% (48/52) |

Per-file PowerShell coverage (reviewer R1, coverage scoped to these files):

| File | Covered / Total | Line % | Source |
|---|---|---|---|
| `.claude/lib/docs/DocsAnalyzerPythonNative.psm1` (new) | 89 / 89 | 100.00% | executor P6-T9 |
| `.claude/lib/docs/DocsPythonNativeProtocol.psm1` (new) | 132 / 132 | 100.00% | executor P6-T9 |
| `.claude/lib/docs/DocsAnalyzerRegistry.psm1` (edited) | 135 / 135 | 100.00% (baseline 100.00%) | executor P6-T9 |
| `.claude/lib/docs/DocsInventory.psm1` (edited) | 121 / 121 | 100.00% (baseline 100.00%) | executor P6-T9 |
| `.claude/lib/docs/Invoke-DocsCommand.ps1` (edited, one line) | 137 / 156 | 87.82% (baseline 87.74%); changed line 60 covered | executor P6-T9 |

The reviewer's scoped coverage run (`rv1031_pester.ps1`, full docs folder with JaCoCo over these five files) had not finished when this audit was written, so the per-file figures above are the executor's P6-T9 record. The reviewer confirmed that no production line of these five files changed after that run (the commits after `f58880e79` touch only the feature folder), and that every suite exercising them passes at this head (R1, 190 of 190).

### 1.3 Test Structure and Diagnostics

| Requirement | Status | Evidence |
|------------|--------|----------|
| Arrange-Act-Assert | ✅ PASS | Inputs built in-test, one call to `main`/`entry` or the function, then assertions. |
| Clear failure messages | ✅ PASS | Structured fact comparisons; Pester `-Because` with seeds. |
| Clean test output | ✅ PASS | Reviewer R1. |

### 1.4 External Dependencies and Environment

| Requirement | Status | Evidence |
|------------|--------|----------|
| No external services | ✅ PASS | No process, network or file access in tests; `qa-test-hygiene.2026-11-05T23-01.md`. |
| No temporary files | ✅ PASS | Reviewer token search over `tests/scripts/claude-lib/docs/`: no `tempfile`, `New-TemporaryFile`, `TestDrive`, `GetTempPath`, `GetTempFileName`, `$env:TEMP`. |
| No mutable global state | ✅ PASS | `conftest.py` sets only `sys.dont_write_bytecode`; PowerShell modules hold constant `$script:` values. |

---

## 2. General Code Change Policy Compliance

### 2.1 Design Principles

| Requirement | Status | Evidence |
|------------|--------|----------|
| Simplicity first | ✅ PASS | Standard-library `ast` walk; thin adapter reusing 1020/1022 functions. |
| Reusability | ✅ PASS | Elements via `New-DocsSurfaceElement`, diagnostics via `New-DocsDiagnostic`, JSON via `DocsJson.psm1`; one identity and digest implementation. |
| Extensibility | ✅ PASS | Registry rows per identifier; `protocol_version` in the protocol; keyword parameters with defaults in `main`. |
| Separation of concerns | ✅ PASS | Pure validator module separate from the seam module; helper `protocol.py` separate from analyzers; I/O confined to `main` streams and the context seam. |

### 2.2 Module and File Structure

| Requirement | Status | Evidence |
|------------|--------|----------|
| At or below the 800-line hard limit | ✅ PASS | Largest covered file 538 logical lines (`enforcement-hooks-no-python-invocation.Tests.ps1`); largest production file 468 (`Invoke-DocsCommand.ps1`); `config/file-size-baseline.json` not in the diff. |
| 700-line advisory tier | ✅ PASS | No covered file at or above 700 lines. |
| Explicit exports / public vs internal | ✅ PASS | `Export-ModuleMember` lists; Python internals `_`-prefixed. |
| No circular dependencies | ✅ PASS | Helper imports flow `protocol` to analyzers to `imports`/`source`; Pyright clean. |

### 2.3 Error Handling

| Requirement | Status | Evidence |
|------------|--------|----------|
| Fail fast, no silent catch | ✅ PASS | `RequestError` for invalid requests; the single `except Exception` in `protocol.py` `main` is the process boundary and maps to exit 3; PowerShell `catch` blocks classify into reason tokens. |

### 2.4 Toolchain Execution

| Step | Status | Evidence |
|------|--------|----------|
| 1. Formatting | ✅ PASS | Reviewer Black: 27 files unchanged; reviewer `Invoke-Formatter` over 22 files: 0 differences. |
| 2. Linting | ❌ FAIL | Ruff: all checks passed (reviewer). PSScriptAnalyzer with `pssa.settings.psd1`: 20 Warning findings in the two new modules and their copies (F2). |
| 3. Type checking | ✅ PASS | Reviewer Pyright over the helper and its tests: 0 errors, 0 warnings, 0 informations. |
| 4. Architecture-boundary tests | ✅ PASS | `ClaudeLibModuleConvention.Tests.ps1` and `enforcement-hooks-no-python-invocation.Tests.ps1` in R1. |
| 5. Unit tests | ✅ PASS | Pytest R2 208 of 208; Pester R1. Full-tree zero-failure Pester gate is `awaiting_ci` (F5). |
| 6. Contract / schema checks | ✅ PASS | Push-down and configuration-pin Pytest 189 of 189 (R4); manifest-completeness Jest 24 of 24 (R5); `Docs.Manifest.Tests.ps1` in R1. |
| 7. Integration tests | ✅ PASS | `DocsInventory.PythonNative.Tests.ps1` (command integration through the mocked seam) in R1. |

---

## 3. Language-Specific Code Change Policy Compliance

### 3A Python

| Requirement | Status | Evidence |
|------------|--------|----------|
| Black / Ruff / Pyright | ✅ PASS | R3. |
| Strong typing, no `Any` | ✅ PASS | Pyright strict clean. |
| Dataclasses for value objects | ✅ PASS | Frozen dataclasses (`Request`, `Fact`, `ParsedModule`). |
| Specific exceptions | ✅ PASS | `RequestError(ValueError)`; boundary handler only in `main`. |
| Docstrings (commenting rule) | ❌ FAIL | F1: 61 of 137 helper functions and classes have no docstring; 0 of 76 docstrings carry `Args:`/`Returns:`/`Raises:`/`Attributes:` sections. |
| Loop, branch and block comments (commenting rule) | ❌ FAIL | F1: 0 full-line comments in the twelve helper files; 91 of 91 loops without an intent comment. |

Reviewer per-file count (helper; loops without intent comment / functions and classes without docstring): `architecture.py` 7/0, `cli.py` 8/5, `cli_argparse.py` 7/8, `cli_click.py` 16/6, `cli_typer.py` 6/6, `imports.py` 3/6, `protocol.py` 8/6, `public_api.py` 11/6, `routes.py` 17/16, `source.py` 8/2, `run_docs_python_native.py` 0/0, `__init__.py` 0/0. Test loops without intent comment: `corpus` 4, `safety` 6, `determinism` 1, `public_api` 1, `source` 1.

### 3B PowerShell

| Requirement | Status | Evidence |
|------------|--------|----------|
| Formatting | ✅ PASS | R7: 0 differences. |
| PSScriptAnalyzer | ❌ FAIL | F2: `PSReviewUnusedParameter` (4), `PSUseLiteralInitializerForHashtable` (4), `PSUseOutputTypeCorrectly` (2) per copy. |
| Advanced functions, parameter validation | ✅ PASS | `CmdletBinding` and typed, `Mandatory` parameters throughout. |
| Approved verbs | ✅ PASS | `ConvertFrom`, `Get`, `Invoke`, `New`, `Select`, `Test`. |
| No global state | ✅ PASS | Constant `$script:` values only. |
| ShouldProcess for state-changing actions | ✅ PASS | Inspected by hand: no new function writes files or changes system state; `New-DocsPythonNativeUnavailable` carries a justified suppression as a pure factory. |
| Seam pattern | ✅ PASS | Interpreter start only through the `[scriptblock]` context member, in one function. |

### 3C TypeScript / JavaScript

| Requirement | Status | Evidence |
|------------|--------|----------|
| Jest test passes | ✅ PASS | R5 9 of 9 and 24 of 24. |
| Build-script change scoped | ✅ PASS | `prepack.cjs` `shouldCopy` adds a bytecode rule and the helper-prefix carve-out; exercised by `discovery-resources.test.ts`. |

### 3D JSON

| Requirement | Status | Evidence |
|------------|--------|----------|
| Strict JSON | ✅ PASS | Manifests parsed by the manifest suites and push-down Pytest; fixture parsed by the corpus tests. |
| Manifest completeness | ✅ PASS | 12 helper entries in `python.json` only; 2 module entries in `core.json`; Codex manifests unchanged. |

---

## 4. Language-Specific Unit Test Policy Compliance

### 4A Python Unit Tests

| Requirement | Status | Evidence |
|------------|--------|----------|
| Pytest, location mirrors source | ✅ PASS | `tests/scripts/claude-lib/docs/python/test_docs_python_native_<area>.py`. |
| Mocking sparingly | ✅ PASS | No `unittest.mock` or `monkeypatch`; failures injected through the `run` parameter of `main`. |
| Naming | ✅ PASS | Descriptive `test_` names. |
| Docstrings and comments | ❌ FAIL | Loop-intent comments absent (F1); test docstrings absent (Minor, non-blocking under `python-unit-test.instructions.md` section 3). |

### 4B PowerShell Unit Tests

| Requirement | Status | Evidence |
|------------|--------|----------|
| Pester v5, `*.Tests.ps1`, mirrored location | ✅ PASS | Four new suites under `tests/scripts/claude-lib/docs/`. |
| Mocking sparingly | ✅ PASS | Test-local seam scriptblocks; no `Mock` in the four new suites. |
| PoshQC test command | ✅ PASS | Executor coverage runs used `Invoke-PoshQCTest`; the reviewer used `Invoke-Pester` with coverage written to the scratchpad so no canonical file was overwritten. |

---

## 5. Test Coverage Detail

See section 1.2.1. Python figures were re-measured by the reviewer and match the executor exactly. The repository-wide figures and the canonical artifacts are F3; the CI-dependent criteria are F5.

---

## 6. Test Execution Metrics

| Run | Tests | Passed | Failed | Source |
|---|---|---|---|---|
| R1 Reviewer Pester, 10 docs suites plus guard and convention suites (Windows, PowerShell 7, coverage off) | 190 | 190 | 0 | this review |
| R2 Reviewer helper Pytest with coverage (Python 3.13, Windows) | 208 | 208 | 0 | this review |
| R4 Reviewer push-down and configuration-pin Pytest | 189 | 189 | 0 | this review |
| R5 Reviewer Jest `discovery-resources` and `claude-pack-manifest-completeness` | 33 | 33 | 0 | this review |
| Executor full Pytest with coverage (P6-T4) | 16275 | 16269 (6 skipped) | 0 | `qa-pytest-coverage.2026-11-04T19-59.md` |
| Executor single-process Pester `tests/scripts` (P6-T9, Linux) | 15825 | 15406 (10 skipped) | 409, equal to the merge-base reference set; none under docs or claude-runtime | `qa-pester-coverage.2026-11-04T20-43.md` |

---

## 7. Code Quality Checks

- Black: 27 files unchanged. Ruff: all checks passed. Pyright: 0 errors (reviewer).
- PSScriptAnalyzer: 20 Warning findings (F2). Formatter: 0 differences.
- File size: maximum 538 logical lines; no Warning row; no file above 800; no baseline entry added.
- Bundle mirror: 17 of 17 `.claude/lib/docs/` pairs SHA-256 identical (R6).
- Bytecode: no `__pycache__` or `.pyc` under the helper or its bundle copy after R2.
- Tier: `quality-tiers.yml` unchanged; executor `check_quality_tiers` OK (29 entries).

---

## Evidence Location Compliance

`python scripts/dev_tools/validate_evidence_locations.py --root .` in the worktree exited 0 with no output (R8). The branch diff contains no path under `artifacts/baselines/`, `artifacts/qa/`, `artifacts/evidence/` or `artifacts/coverage/`. All evidence is under `<FEATURE>/evidence/{baseline,other,qa-gates,regression-testing}/`. Spec criterion S9 names `<FEATURE>/evidence/coverage/`; the plan's `## Deviations from spec.md` item 10 records `EVIDENCE_LOCATION_OVERRIDE_REJECTED: <FEATURE>/evidence/coverage/ replaced with <FEATURE>/evidence/qa-gates/`, and the coverage records are in `evidence/qa-gates/`. No violation.

---

## 8. Gaps and Exceptions

1. **F1 Python commenting and docstring policy not met (blocking, autonomous).** Confirmed independently; the executor's `ruff D100-D107` check passed only because those rules skip `_`-prefixed names, so the gap is larger than its self-review recorded (61 undocumented functions and classes). The fix must keep S21 true by splitting `routes.py`.
2. **F2 PSScriptAnalyzer warnings in the two new modules (blocking, autonomous).** Not seen by the executor because the PoshQC scan folders exclude `.claude/lib`.
3. **F3 Canonical coverage artifacts absent (blocking, autonomous).** Python, PowerShell and TypeScript; measured figures meet thresholds.
4. **F4 Spec text diverges from adopted names and shapes (blocking, autonomous).** Plan deviations 1 to 5 are not reflected in `spec.md`.
5. **F5 CI-dependent items (blocking, awaiting_ci).** S10, U10, S22, U22 and the zero-failure Pester gate of P6-T9 and P6-T14.
6. **Warnings.** None.

No approved policy exception is claimed. Tier classification applies (the repository has `quality-tiers.yml`) and is satisfied.

---

## 9. Summary of Changes

Item commits (`git log 729ff55ef..HEAD`): Phase 0 preconditions and owner-decision preflight (`969424118` to `cd83c4393`); helper source and import layer (`83c4d8d09`); CLI, HTTP, API and architecture analyzers (`99f781e48`); protocol, entry and corpus tests (`bd8aa11b6`); adapter and inventory option (`dbf4772ff`); python-pack bundling (`3090e42fd`); helper renames and WIP QA evidence (`bbef268db`, `c83bdf64c`); integration merge `e34dbba74`; Phase 6 evidence `6a1cae0a6` to `e6e828de9`.

---

## 10. Compliance Verdict

**REMEDIATION_REQUIRED.** F1, F2, F3 and F4 are autonomous and are fixed in a remediation cycle; F5 resolves through CI on the PR head at S9.

---

## Appendix A: Test Inventory

Reviewer R1 at head `e6e828de9` (`Invoke-Pester`, coverage off, one process, 71 s):

| Suite | Tests |
|---|---|
| `DocsPythonNativeProtocol.Tests.ps1` (new) | 26 |
| `DocsAnalyzerPythonNative.Tests.ps1` (new) | 20 |
| `DocsAnalyzerPythonNative.Parity.Tests.ps1` (new) | 6 |
| `DocsInventory.PythonNative.Tests.ps1` (new) | 11 |
| `DocsAnalyzerRegistry.Tests.ps1` (edited) | 31 |
| `DocsAnalyzerConfigFiles.Tests.ps1` (edited) | 16 |
| `DocsInventorySnapshot.Tests.ps1` (edited) | 11 |
| `DocsInventory.Tests.ps1` (edited) | 13 |
| `DocsInventoryProperties.Tests.ps1` (edited) | 8 |
| `Docs.Manifest.Tests.ps1` | 7 |
| `enforcement-hooks-no-python-invocation.Tests.ps1` (edited) | 35 |
| `ClaudeLibModuleConvention.Tests.ps1` | 6 |
| Total | 190 |

Python (R2): 15 test files, 208 tests, all passed.

## Appendix B: Toolchain Commands Reference

- R1: `pwsh -NoProfile -File <scratch>/rv1031_pester_small.ps1 -Root <worktree>` (`Invoke-Pester`, coverage off, over the ten docs suites listed in Appendix A plus the guard and module-convention suites)
- Coverage attempt: `pwsh -NoProfile -File <scratch>/rv1031_pester.ps1 -Root <worktree>` (full docs folder with JaCoCo over the five files, output to the scratchpad); not finished when the audit was written
- R2: `python -B -m pytest -c pyproject.toml -o addopts="" -p no:cacheprovider tests/scripts/claude-lib/docs/python --cov=docs_python_native --cov=run_docs_python_native --cov-branch --cov-report=json:<scratch>`
- R3: `python -m black --check`, `python -m ruff check --no-cache`, `python -m pyright` over `.claude/lib/docs/python` and `tests/scripts/claude-lib/docs/python`
- R4: `python -B -m pytest -o addopts="" tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py tests/scripts/dev_tools/test_push_down_claude_pack_manifest_completeness.py tests/scripts/dev_tools/test_push_down_pack_manifest_dependency_closure.py tests/scripts/dev_tools/test_pyright_config_alignment.py tests/scripts/dev_tools/test_ruff_config_alignment.py tests/discovery_runtime/test_package_contract.py`
- R5: `npx jest test/packaging/discovery-resources.test.ts` and `npx jest claude-pack-manifest-completeness` in `extensions/drm-copilot`
- R6: reviewer Python script computing SHA-256 of each `.claude/lib/docs/` path and its bundle copy, and logical line counts (`splitlines`, equal to `@(Get-Content).Count`)
- R7: `pwsh -NoProfile -File <scratch>/rv1031_pssa.ps1 -Root <worktree>` (per-file `Invoke-ScriptAnalyzer` and `Invoke-Formatter` with `scripts/powershell/PoshQC/settings/pssa.settings.psd1`)
- R8: `python scripts/dev_tools/validate_evidence_locations.py --root .`
- Commenting count: reviewer `ast`/`tokenize` script over the 27 Python files (loops, full-line comments, docstrings and their sections)
