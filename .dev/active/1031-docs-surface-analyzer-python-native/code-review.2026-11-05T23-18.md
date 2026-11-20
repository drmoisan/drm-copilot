# Code Review: Python-native docs surface analyzer (#1031)

**Review Date:** 2026-11-05
**Reviewer:** feature-review agent
**Feature Folder:** `docs/features/active/2026-10-30-docs-surface-analyzer-python-native-1031`
**Base Branch:** `origin/epic/documentation-estate-tooling-integration` (tip `eb3436e62`)
**Head Branch:** `feature/docs-surface-analyzer-python-native-1031-r2` (head `e6e828de9476b6c4a776d3acf79e8bd3e77446a4`, equal to the remote branch; clean worktree; no pull request exists)
**Merge base:** `729ff55ef6b8fcfcf632d9d2220a674bb437bf7e` (`git merge-base origin/epic/documentation-estate-tooling-integration HEAD`)
**Review Type:** Initial full-branch review

---

## Executive Summary

The review covers the full branch diff `git diff 729ff55ef...HEAD` (147 paths, 12065 insertions, 176 deletions, 35 commits). `artifacts/pr_context.summary.txt` and `artifacts/pr_context.appendix.txt` are absent from the worktree and no collector tool is exposed to this agent, so the direct `git diff` against the merge base is the scope source (assumption, recorded in the policy audit).

The branch adds a standard-library Python helper (`.claude/lib/docs/python/run_docs_python_native.py` and the eleven-module package `docs_python_native/`) that parses in-memory sources with `ast.parse` and returns raw facts over a JSON stdin/stdout protocol; a PowerShell adapter (`DocsAnalyzerPythonNative.psm1`) and a pure response validator (`DocsPythonNativeProtocol.psm1`); four `native` rows under the existing `# --- 1031: Python-native analyzers ---` registry anchor; an `-AnalysisMethod auto|native|scanner` option on `inventory`; byte-identical bundle copies of all 17 changed `.claude/lib/docs/` files; pack-manifest entries (python pack for the helper, core pack for the two PowerShell modules); a narrow `.py` carve-out in `.vscodeignore` and `packages/mcp-server/prepack.cjs`; a fifth detection class and a single D3 allowlist entry in the Python-invocation guard; 15 Python test files and 4 new Pester suites.

The reviewer re-ran the helper Pytest suite with per-file coverage (208 passed; per-file figures identical to the executor record), Black, Ruff and Pyright over the helper and its tests (0 findings), the push-down and configuration-pin Pytest modules (189 passed), the two packaging Jest suites (9 and 24 passed), PSScriptAnalyzer and `Invoke-Formatter` over the 22 changed `.ps1`/`.psm1` files, a Pester run of the ten in-scope docs suites plus the guard and module-convention suites (190 of 190), the evidence-location validator (exit 0), SHA-256 parity of the 17 bundle pairs (0 mismatches), and logical line counts. Results are in `policy-audit.2026-11-05T23-18.md` section 6.

**What changed well:**
- The helper never executes analyzed code: `ast.parse` is its only parse entry, there is no `exec`/`eval`/`compile`/`__import__`/`importlib`/`runpy`/`subprocess`/`hashlib` call in `.claude/lib/docs/python/` (reviewer search; the only `importlib` text is a string set in `architecture.py` line 25 that detects dynamic imports in analyzed source).
- Identity and digest have one implementation: every element is built in PowerShell through 1020 `New-DocsSurfaceElement`, and the helper emits no identifier or digest.
- The process seam is narrow and auditable: `Invoke-DocsPythonNativeInterpreter` is the only function that calls `Context.InvokeProcess`, with fixed arguments `-I -B -X utf8 <helper path>`, and the guard allowlist names exactly that function.
- Fallback is fail-safe: any candidate failure is classified into a reason token and the scanner result is used; `-AnalysisMethod native` fails closed with one error finding.
- Packaging carve-outs are narrow and pinned in both directions by `discovery-resources.test.ts` (helper `.py` admitted; every other `.py`, `__pycache__`, `.pyc` and `.pyo` excluded).

**Top 3 risks:**
1. F1: the twelve helper modules do not meet the repository's Python commenting and docstring policy (`.claude/rules/self-explanatory-code-commenting.md`, canonical `.github/instructions/self-explanatory-code-commenting.instructions.md`). The executor's self-review recorded this as two FAIL rows; the reviewer confirmed it independently and found it larger than recorded (61 helper functions and classes have no docstring at all). Remediation is expected to push `routes.py` (467 logical lines) past the 500-line limit in S21, so a module split is part of the fix.
2. F2: PSScriptAnalyzer with the repository settings reports 10 warnings in the two new production modules (20 including the bundle copies). The executor's "0 findings" came from the PoshQC scan folders (`scripts`, `tests/powershell`, `tests/scripts` in `config/poshqc-scan.json`), which do not include `.claude/lib`, so the new modules were never analyzed.
3. F4: `spec.md` still publishes, as the contract later children must honor, a diagnostic code, a registry row shape, a provider function signature and a digest function that the adopted plan deviations replaced.

**PR readiness recommendation:** **Needs revision.** Four autonomous findings (F1, F2, F3, F4) and one `awaiting_ci` finding (F5) are listed in `remediation-inputs.2026-11-05T23-18.md`.

---

## Findings Table

| Severity | File | Location | Finding | Recommendation | Rationale | Evidence |
|---|---|---|---|---|---|---|
| Major | `.claude/lib/docs/python/docs_python_native/*.py`, `.claude/lib/docs/python/run_docs_python_native.py` (and bundle copies); loops in six test files | every module; examples: `protocol.py` `_reject_duplicates` (line 61), `_object` (74), `run_request` (167, analyzer dispatch chain lines 178-186); `routes.py` `_chains` (353), `_emit` (427), `_collect` (198); `cli_click.py` `_pending` (167) | F1. Commenting and docstring policy not met. Reviewer AST/tokenize count: 0 full-line comments in all twelve helper files; 91 `for`/`while` loops, none with an intent comment directly above; 61 functions and classes with no docstring (cli 5, cli_argparse 8, cli_click 6, cli_typer 6, imports 6, protocol 6, public_api 6, routes 16, source 2); of the 76 docstrings present, none has an `Args:`, `Returns:`, `Raises:` or `Attributes:` section, and 4 span more than one line; `if`/`elif` chains such as the dispatch in `run_request` carry no decision-logic comment. Test files: 13 loops without an intent comment (`test_docs_python_native_corpus.py` 4, `_safety.py` 6, `_determinism.py` 1, `_public_api.py` 1, `_source.py` 1). | Add Google-style docstrings (purpose, `Args:`, `Returns:`, `Raises:`, side effects; `Attributes:` for dataclasses) to every helper function and class including private helpers; add intent comments above every loop and non-trivial comprehension, decision-logic comments on branch chains, and meta-what comments on multi-step blocks; add intent comments above the 13 test loops. Split `routes.py` (and any other module that crosses 500 logical lines) with the matching manifest entry, bundle copy, test module and classification row, then re-run the full toolchain loop and re-record coverage. | `self-explanatory-code-commenting.md` applies to `**/*.py`; its "Mandatory Function and Method Docstrings" section names private helpers explicitly, and its loop section requires an intent comment on every loop. The D3 exception makes this helper the only pushed-down Python, so its maintainability is part of the owner's "narrow and auditable" requirement. | Reviewer script over the 27 Python files (counts per file in policy audit 3A); executor `evidence/qa-gates/self-review.2026-11-05T23-10.md` FAIL rows (the executor's `ruff D100-D107` check passed only because those rules skip `_`-prefixed names) |
| Major | `.claude/lib/docs/DocsAnalyzerPythonNative.psm1`, `.claude/lib/docs/DocsPythonNativeProtocol.psm1` (and bundle copies) | `DocsAnalyzerPythonNative.psm1` lines 187, 199, 211, 223 (`PSReviewUnusedParameter`, `-CapturedInput` of the four analyzer functions), 290 (`PSUseLiteralInitializerForHashtable`); `DocsPythonNativeProtocol.psm1` lines 51, 53 (`PSUseOutputTypeCorrectly`, `Get-DocsPythonNativeKind`), 128, 296, 317 (`PSUseLiteralInitializerForHashtable`) | F2. Reviewer `Invoke-ScriptAnalyzer -Settings scripts/powershell/PoshQC/settings/pssa.settings.psd1` (PSScriptAnalyzer 1.25.0) over the 22 changed `.ps1`/`.psm1` files: 20 Warning findings, 10 per copy, all in the two new modules; the edited `DocsAnalyzerRegistry.psm1`, `DocsInventory.psm1` and `Invoke-DocsCommand.ps1` and all test files report none. `Invoke-Formatter`: 0 differences. | Resolve each finding: for the contract-fixed `-CapturedInput` parameter and the ordinal-comparer hashtables, add scoped `SuppressMessageAttribute` entries with a justification, as the sibling 1022 and 1033 modules do (for example `DocsAnalyzerDotnetApi.psm1`); for `PSUseOutputTypeCorrectly`, correct the `[OutputType()]` declaration or the comma-wrapped return. Mirror the bundle copies, then re-run analysis over `.claude/lib/docs` explicitly (not only the PoshQC scan folders) and record it. | `.claude/rules/powershell.md` requires PSScriptAnalyzer with repository settings and prohibits "Creating PSScriptAnalyzer debt and deferring cleanup". The executor's `qa-poshqc-analyze` gate could not see these files because `config/poshqc-scan.json` does not list `.claude/lib`. | Reviewer PSSA run (policy audit 2.4); `config/poshqc-scan.json` line 4; executor `evidence/qa-gates/qa-poshqc-analyze.2026-11-04T20-01.md` |
| Major | worktree `artifacts/` | `artifacts/python/lcov.info`, `artifacts/pester/powershell-coverage.xml`, `coverage/lcov.info` | F3. The canonical coverage artifacts the review contract reads are absent from the worktree (only `artifacts/orchestration/` exists). The executor's runs were on a Linux Codespace and wrote the JSON to a scratch path; the recorded figures cannot be read from a canonical artifact at this head. | When the F1 and F2 changes are made, run the coverage-producing toolchain inside the worktree so the canonical files exist (`pytest --cov` writes `artifacts/python/lcov.info` through `addopts`; `Invoke-PoshQCTest` writes `artifacts/pester/powershell-coverage.xml`; the extension `test:coverage` script writes `coverage/lcov.info`), and record the figures in `evidence/qa-gates/`. | The review contract makes an absent artifact a FAIL for every language with changed files (Python, PowerShell, TypeScript). The reviewer's re-measurement (policy audit 1.2.1) shows the per-file figures themselves meet the thresholds. | `ls` of the worktree `artifacts/` directory; policy audit 1.2.1 |
| Major | `docs/features/active/2026-10-30-docs-surface-analyzer-python-native-1031/spec.md` | `### Fallback rules` (lines 65-78), `### Native-provider function` (line 161), `## Upstream Dependencies` digest row (line 327), `## Decisions Later Children Must Honor` (lines 336-353) | F4. The spec publishes a non-blocking diagnostic `DOCS_PYTHON_NATIVE_UNAVAILABLE`, a single provider function `Invoke-DocsAnalyzerPythonNative -InvokeInterpreter`, one native-provider row with `Language`/`AnalyzerIds`, and a `Get-DocsDeclarationDigest` function. The code emits diagnostic `PYTHON_NATIVE_UNAVAILABLE` with severity `information` (the finding under `-AnalysisMethod native` keeps `DOCS_PYTHON_NATIVE_UNAVAILABLE`), exports `Get-DocsPythonNativeResult` and `Invoke-DocsPythonNativeInventory`, registers four rows in the 1020 row form, and builds elements with `New-DocsSurfaceElement`. The plan records these as deviations 1 to 5 and states that `spec.md` is not edited. | Amend `spec.md` outside the acceptance-criteria checkboxes so the normative sections and `## Decisions Later Children Must Honor` state the adopted names and shapes (diagnostic code and severity, provider functions, registry row form, element construction, `parent` with `path`), and note the change in the plan. Do not change checkbox state. | Later children (1023 ledger, 900010 onboarding) are told to honor the spec section; a consumer keyed on `DOCS_PYTHON_NATIVE_UNAVAILABLE` in snapshot diagnostics would never match. The same class of divergence was a blocking finding in the #1033 review (F2) and was fixed in the item. | `grep` of `DocsAnalyzerPythonNative.psm1` lines 97 and 101; plan `## Deviations from spec.md` items 1-5 |
| Minor | `tests/scripts/claude-lib/docs/python/test_docs_python_native_*.py` | 190 test functions and classes | No test function or class has a docstring. | Optional: add one-line scenario docstrings where the test name does not state the expected outcome. | `.github/instructions/python-unit-test.instructions.md` section 3 requires a docstring only "where the intent is not obvious from the name alone", and `general-unit-test.md` accepts "a descriptive name and/or a short docstring". The reviewer treats the test-specific rule as governing test functions, so this is not blocking; the loop-comment gap in tests is part of F1. | Reviewer AST count |
| Minor | `.claude/lib/docs/DocsAnalyzerPythonNative.psm1` | line 304 | `$scannerRow = @(... Where-Object ...)[0]` assumes a scanner row exists for every native identifier; a registry without one would pass `$null` to `Invoke-DocsAnalyzer` and fail with a parameter-binding error rather than a docs finding. | Optional: throw a named `DOCS_*` contract error when no scanner row matches. | The committed registry always pairs the rows (registry tests assert membership), so no current input reaches this path. | Source inspection |
| Info | `packages/mcp-server/prepack.cjs` | header comment line 8 | One comment line runs to about 140 characters after the edit. | Optional: rewrap. | Prettier does not reflow comments; no gate fails. | Source inspection |

No covered file is at or above the 700-line advisory tier. The largest covered files are `tests/scripts/claude-runtime/enforcement-hooks-no-python-invocation.Tests.ps1` at 538 logical lines, `.claude/lib/docs/Invoke-DocsCommand.ps1` at 468, and `routes.py` at 467 (logical-line count equal to `@(Get-Content -LiteralPath <path>).Count`). `config/file-size-baseline.json` is not in the branch diff.

---

## Implementation Audit

### Python implementation audit

#### What changed well

- Standard library only; strict typing passes Pyright with 0 errors; frozen dataclasses for value objects (`Request`, `Fact`, `ParsedModule`).
- Request validation is complete before analysis: closed key sets, version, limits, duplicate keys and non-finite numbers are rejected with messages that never quote source text (`protocol.py` `parse_request`).
- Output is canonical (`json.dumps(..., ensure_ascii=True, sort_keys=True, separators=(",", ":"))`) and facts are sorted, so permutations of the request yield identical bytes (`test_docs_python_native_determinism.py`).
- The entry script checks the 3.11 floor before importing the package and writes a fixed error object, so an older interpreter exits 4 instead of failing on newer syntax.
- `routes.py` `_chains` bounds recursion by `DEPTH_LIMIT` and a cycle stack that is discarded on return, so sibling mounts sharing an ancestor are not misreported as cycles.

#### Concerns

- F1 (commenting and docstrings). The one broad handler, `except Exception` in `protocol.py` `main`, is the process boundary and maps every internal failure to exit 3 with the exception type name; it does not swallow the failure and is acceptable under `python.md`.

### PowerShell implementation audit

#### What changed well

- Module headers follow the 1020 convention (strict mode, `Stop`, literal sibling imports with `-ErrorAction Stop`, comment-based help, explicit `Export-ModuleMember`). `ClaudeLibModuleConvention.Tests.ps1` passes.
- Script-scope variables are constants (helper path, 120 s timeout, candidate list, start-failure code).
- The three `catch` blocks in `Get-DocsPythonNativeResult` classify a candidate failure into a reason token that surfaces as a diagnostic or finding; none is silent.

#### Concerns

- F2 (PSScriptAnalyzer warnings in both new modules).
- Minor: the scanner-row lookup at line 304 (Findings Table).

### TypeScript and JavaScript audit

- `discovery-resources.test.ts` (test only) asserts the carve-out and the continued exclusions in both distributables; reviewer run 9 of 9.
- `prepack.cjs` `shouldCopy` checks bytecode and `__pycache__` before the `.py` rule, so bytecode under the helper prefix is still excluded; `PYTHON_HELPER_PREFIX` is compared on the resources-relative POSIX path.

### C# audit

N/A: no C# file in the branch diff.

---

## Test Quality Audit

### Reviewed test and QA artifacts

- Python: 15 files under `tests/scripts/claude-lib/docs/python/` (one per helper module plus corpus, determinism, entry and safety suites); `conftest.py` sets `sys.dont_write_bytecode = True`.
- PowerShell: `DocsAnalyzerPythonNative.Tests.ps1`, `DocsAnalyzerPythonNative.Parity.Tests.ps1`, `DocsInventory.PythonNative.Tests.ps1`, `DocsPythonNativeProtocol.Tests.ps1`; edits to the registry, inventory, snapshot and config-files suites and the guard suite.
- Executor evidence under `evidence/regression-testing/` (phase runs, reversed, shuffled and fresh runs) and `evidence/qa-gates/`.

### Quality assessment

| Area | Status | Notes |
|---|---|---|
| Determinism | PASS | No process, clock or network in tests; seam scriptblocks are test-local; seeded shuffles recorded. |
| Isolation | PASS | Pytest drives `main`/`entry` with `io.BytesIO`; no `unittest.mock` or `monkeypatch` use. |
| Speed | PASS | 208 helper tests in 1.07 s (reviewer). |
| Diagnostics | PASS | Assertions compare structured facts; Pester `-Because` texts carry seeds. |
| Temporary files | PASS | Reviewer token search over `tests/scripts/claude-lib/docs/`: no `tempfile`, `New-TemporaryFile`, `TestDrive`, `GetTempPath`, `GetTempFileName` or `$env:TEMP`. |
| Documentation | FAIL | Loop-intent comments absent in six test files (F1); test docstrings absent (Minor). |

---

## Security / Correctness Checks

| Check | Status | Evidence |
|---|---|---|
| No secrets in code | PASS | No credential or token literal in the diff; executor `qa-forbidden-tokens.2026-11-05T23-03.md`. |
| No unsafe subprocess or command construction | PASS | No subprocess in the helper; PowerShell starts the interpreter only through `Context.InvokeProcess` with a constant candidate and fixed argument list; isolated mode `-I` prevents a planted module from shadowing helper imports. |
| No execution of analyzed code | PASS | `ast.parse` only; behavioral test in `test_docs_python_native_safety.py` passes. |
| Input validation at boundaries | PASS | Helper `parse_request`; adapter `Test-DocsPythonNativeResponse` validates every response field and the size bound. |
| Error handling explicit | PASS | Exit codes 2, 3, 4; reason tokens; no empty `catch`. |
| Path handling | PASS | Helper path is a repository-relative literal; packaging carve-out limited to `.claude/lib/docs/python/`. |
| Static analysis clean | FAIL | F2. |

---

## Research Log

No external research was performed. All evidence comes from the repository at head `e6e828de9`, the executor evidence files, and reviewer commands listed in the policy audit Appendix B.

---

## Verdict

**REMEDIATION_REQUIRED.** F1, F2, F3 and F4 are autonomous and are fixed in a remediation cycle; F5 (CI-dependent criteria S10, U10, S22, U22 and the zero-failure Pester gate of P6-T9 and P6-T14) resolves through CI on the PR head at S9.
