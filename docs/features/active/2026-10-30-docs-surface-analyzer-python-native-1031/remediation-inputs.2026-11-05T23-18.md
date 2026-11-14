# Remediation Inputs - issue #1031 (review 2026-11-05T23-18)

Review-Verdict: REMEDIATION_REQUIRED
Remediation-Mode: design

Finding classes: F1, F2, F3 and F4 autonomous; F5 awaiting_ci. Orchestrator scope note: the cycle may also take in the two non-blocking Minor items of the code review (scenario docstrings for test functions whose names do not state the outcome, and a named contract error for an absent scanner row at `DocsAnalyzerPythonNative.psm1` line 304), because both sit in files already in the branch diff and change no acceptance criterion or public interface.

Source review artifacts (this folder):

- `policy-audit.2026-11-05T23-18.md`
- `code-review.2026-11-05T23-18.md`
- `feature-audit.2026-11-05T23-18.md`

Branch: `feature/docs-surface-analyzer-python-native-1031-r2`, head `e6e828de9`. Base: `origin/epic/documentation-estate-tooling-integration` (merge base `729ff55ef`).

## Blocking Findings

### F1 - Python helper and test loops do not meet the commenting and docstring policy

- Severity: Blocking
- Remediability: autonomous
- Remediability-Evidence: The rule text is explicit and the change is an in-worktree edit of this branch's own Python files plus a module split that the plan's existing patterns (manifest entry, bundle copy, test module, classification row) already cover; no owner decision, external system or CI result is needed.
- File: `.claude/lib/docs/python/run_docs_python_native.py`, `.claude/lib/docs/python/docs_python_native/{architecture,cli,cli_argparse,cli_click,cli_typer,imports,protocol,public_api,routes,source}.py` and their bundle copies; loop sites in `tests/scripts/claude-lib/docs/python/test_docs_python_native_{corpus,safety,determinism,public_api,source}.py`
- Symbol: examples `protocol.py` `_reject_duplicates`, `_object`, `run_request` (analyzer dispatch chain); `routes.py` `_chains`, `_emit`, `_collect`, `_Route`; `cli_click.py` `_pending`; `source.py` `_block_kind`
- Rule: `.claude/rules/self-explanatory-code-commenting.md` (canonical `.github/instructions/self-explanatory-code-commenting.instructions.md`, `applyTo: **/*.py`): "Mandatory Class Docstrings", "Mandatory Function and Method Docstrings" (including private helpers), "Loops and Comprehensions - Intent Comments Required", "Branching - Decision-Logic Comments Required", "Multi-Step Blocks - Meta-What Comments".
- Evidence: reviewer AST and tokenize count over the 12 helper files: 0 full-line comments; 91 `for`/`while` loops, 0 with an intent comment directly above; 61 of 137 functions and classes with no docstring; 0 of the 76 docstrings carry `Args:`, `Returns:`, `Raises:` or `Attributes:`. Test files: 13 loops without an intent comment. Executor `evidence/qa-gates/self-review.2026-11-05T23-10.md` records the same two FAIL rows (2.4 Docs/docstrings, 2.4 Comment why-not-what).
- Required change: add Google-style docstrings to every helper function and class, intent comments above every loop and non-trivial comprehension, decision-logic comments on branch chains and meta-what comments on multi-step blocks; add intent comments above the 13 test loops. Keep every production file at or below 500 logical lines (spec S21): split `routes.py` (467 now) and any other module that crosses 500, adding the python-pack manifest entry, the byte-identical bundle copy, a mirrored test module and the plan's classification row for each new file. Re-run the full toolchain loop (Black, Ruff, Pyright, Pytest with coverage, push-down contract tests, Pester manifest suite) and record it under `evidence/qa-gates/`.

### F2 - PSScriptAnalyzer warnings in the two new PowerShell modules

- Severity: Blocking
- Remediability: autonomous
- Remediability-Evidence: The findings are reproduced locally with the repository settings file, and the sibling 1022 and 1033 modules show the accepted resolution pattern (scoped, justified suppressions or code changes); the fix is inside this branch.
- File: `.claude/lib/docs/DocsAnalyzerPythonNative.psm1` lines 187, 199, 211, 223, 290; `.claude/lib/docs/DocsPythonNativeProtocol.psm1` lines 51, 53, 128, 296, 317; the same lines in the bundle copies
- Symbol: `Invoke-DocsAnalyzerPythonNativeCli`, `...Http`, `...Api`, `...Architecture` (`PSReviewUnusedParameter` on `-CapturedInput`); `Invoke-DocsPythonNativeInventory` (`PSUseLiteralInitializerForHashtable`); `Get-DocsPythonNativeKind` (`PSUseOutputTypeCorrectly`); three ordinal-comparer hashtables in `DocsPythonNativeProtocol.psm1` (`PSUseLiteralInitializerForHashtable`)
- Rule: `.claude/rules/powershell.md` `## Toolchain` step 2 and `## Prohibited Behaviors` ("Creating PSScriptAnalyzer debt and deferring cleanup").
- Evidence: reviewer `Invoke-ScriptAnalyzer -Path <file> -Settings scripts/powershell/PoshQC/settings/pssa.settings.psd1` (PSScriptAnalyzer 1.25.0) over the 22 changed `.ps1`/`.psm1` files: 20 Warning findings, all in these two modules and their copies. The executor gate `evidence/qa-gates/qa-poshqc-analyze.2026-11-04T20-01.md` scanned `config/poshqc-scan.json` folders (`scripts`, `tests/powershell`, `tests/scripts`), which exclude `.claude/lib`.
- Required change: resolve each finding (justified `SuppressMessageAttribute` for the contract-fixed `-CapturedInput` parameter and the ordinal-comparer hashtables, as in `DocsAnalyzerDotnetApi.psm1`; correct `[OutputType()]` or the return shape for `Get-DocsPythonNativeKind`), copy both modules byte-identically to the bundle, run `Invoke-ScriptAnalyzer` explicitly over `.claude/lib/docs` and the bundle copy, and record the zero-finding result.

### F3 - Canonical coverage artifacts absent for Python, PowerShell and TypeScript

- Severity: Blocking
- Remediability: autonomous
- Remediability-Evidence: The artifacts are produced by the repository's own coverage commands run inside the worktree; the remediation cycle must re-run the coverage toolchain anyway after F1 and F2, so no external input is needed.
- File: `artifacts/python/lcov.info`, `artifacts/pester/powershell-coverage.xml`, `coverage/lcov.info` (worktree root)
- Symbol: not applicable (coverage artifacts)
- Rule: feature-review coverage contract (`## Coverage Verification`: an absent artifact for a language with changed files is a FAIL); `.claude/rules/general-unit-test.md` `## Coverage Requirements`.
- Evidence: the worktree `artifacts/` directory holds only `orchestration/`; no `coverage/` directory exists. Executor runs wrote JSON to scratch paths on a Linux Codespace. The reviewer's scoped re-measurement (policy audit 1.2.1) shows per-file figures at or above the thresholds.
- Required change: after the F1 and F2 changes, run Pytest with coverage over the full suite inside the worktree (producing `artifacts/python/lcov.info`), `Invoke-PoshQCTest` with coverage (producing `artifacts/pester/powershell-coverage.xml`), and the extension `test:coverage` script (producing `coverage/lcov.info`); record repo-wide and per-file figures in `evidence/qa-gates/coverage-delta.<timestamp>.md`.

### F4 - Specification publishes names and shapes the code does not use

- Severity: Blocking
- Remediability: autonomous
- Remediability-Evidence: Every adopted name and shape is already decided and recorded in the plan `## Deviations from spec.md` items 1 to 5; the change is a documentation edit to this item's own `spec.md` and needs no new owner decision.
- File: `docs/features/active/2026-10-30-docs-surface-analyzer-python-native-1031/spec.md` lines 65-78 (`### Fallback rules`), 161 (`### Native-provider function`), 327 (digest row), 336-353 (`## Decisions Later Children Must Honor`)
- Symbol: not applicable (specification text)
- Rule: spec `## Decisions Later Children Must Honor` is binding on later children; `.claude/rules/tonality.md` evidence-first wording (published contracts must match verified behavior).
- Evidence: spec names a non-blocking diagnostic `DOCS_PYTHON_NATIVE_UNAVAILABLE`, `Invoke-DocsAnalyzerPythonNative -InvokeInterpreter`, one provider row with `Language`/`AnalyzerIds`, and `Get-DocsDeclarationDigest`; code emits diagnostic `PYTHON_NATIVE_UNAVAILABLE` (severity `information`) at `DocsAnalyzerPythonNative.psm1` line 97, exports `Get-DocsPythonNativeResult` and `Invoke-DocsPythonNativeInventory`, and registers four 1020-form rows.
- Required change: update the normative sections and `## Decisions Later Children Must Honor` to the adopted names and shapes (diagnostic code and severity versus the exit-3 finding code, provider functions, registry row form under the 1031 anchor, element construction through `New-DocsSurfaceElement`, `parent` carrying `path`). Do not change any acceptance-criteria checkbox. Record the edit in the plan.

### F5 - CI-dependent criteria and the zero-failure Pester gate

- Severity: Blocking
- Remediability: awaiting_ci
- Remediability-Evidence: Awaited workflow `.github/workflows/ci.yml`, checks `poshqc / PowerShell QC` (windows-latest shards with coverage) and `quality-checks7 / Code Quality & Tests` (3.11, 3.12, 3.13) on the PR head; no pull request exists for head `e6e828de9`. The executor's Linux single-process Pester runs (P6-T9, P6-T14) show 409 failures identical to the merge-base reference set and none under the docs or claude-runtime suites; the reviewer's run of the in-scope suites passed 190 of 190 (policy audit section 6).
- File: `spec.md` lines 369 (S10) and 381 (S22); `user-story.md` lines 85 (U10) and 97 (U22); plan tasks P6-T9 and P6-T14
- Symbol: not applicable (CI criteria)
- Rule: `.claude/skills/acceptance-criteria-tracking/SKILL.md` `### CI-Dependent Criteria`.
- Evidence: `gh pr list --head feature/docs-surface-analyzer-python-native-1031-r2` returns no pull request; `evidence/qa-gates/qa-pester-coverage.2026-11-04T20-43.md`; `evidence/regression-testing/isolation-pester-fresh.2026-11-04T21-06.md`.
- Required change: none in a remediation cycle. After F1 to F4 are fixed, open the PR into the epic integration branch (dispatch `ci.yml` manually if no checks start). At S9 the item's own orchestrator run checks off S10, U10, S22 and U22 after green conclusions and re-runs the CI gate on the final head. S9 and U9 are re-verified from the F3 artifacts after the remediation cycle.
