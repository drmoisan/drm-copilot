# Code Review: policy-file-consistency-mstest-pester6 (#1106)

---

**Review Date:** 2026-11-07
**Branch:** `chore/policy-file-consistency` (head `bd5124f47447099c22731e0ff7d64600eada1e69`)
**Base:** `origin/main` (merge base `bad886e304990d26af56d6bcabc9d543518492e9`, equal to the fetched tip)
**Scope:** full branch diff, 98 paths (72 outside the feature folder)
**Companion artifacts:** `policy-audit.2026-11-07T15-31.md`, `feature-audit.2026-11-07T15-31.md`

---

## Executive Summary

The change is a consistent, token-level correction of policy text across the canonical sources, the Claude, Codex, and agents packs, the templates, and the bundle copies, plus a small Python argv change and a new contract guard. This review found no Blocker or Major issue.

- Every policy edit was checked by word diff. Each changed line replaces only the named token (xUnit idiom, Pester version, coverage argument, or example name). The `csharp-atomic-executor` commands now match `csharp-unit-test.instructions.md` section 3 verbatim, and `dotnet test` remains only in the modern Claude pack, which matches D1.
- All 29 changed canonical files with a bundle copy are byte-identical to it (`cmp`), and `generate_codex_agent_variants --check` exits 0.
- The new guard can fail. Run on the merge-base text of six changed files, its scan function reports the old phrases, and it reports none on the HEAD text.
- The Python production edits are correct. `QCRunner.FULL_TEST` now targets `--cov=scripts/dev_tools`, the other four sites drop only the stray argument, and the emitted text in `cli_preflight.py` and `prompt_builder.py` stays well-formed. Changed modules meet 85% line and 75% branch coverage in the single gate run.
- Findings: one file-size Warning, three Minor items, and three Info items. None is blocking.

---

## Findings Table

| Severity | File | Location | Finding | Recommendation | Rationale | Evidence |
|---|---|---|---|---|---|---|
| Warning | `tests/scripts/dev_tools/atomic_executor/test_prompt_builder.py` | whole file | 768 logical lines, at or above the 700-line advisory tier. The file grew from 695 lines at the merge base with the new `TestPromptBuilderOptionalSections` class. | Consider moving the new class and future additions into a separate `test_prompt_builder_sections.py`. | `## File Size Limit` advisory tier; the 800-line limit is not reached. | `@(Get-Content -LiteralPath ...).Count` = 768; `config/file-size-baseline.json` unchanged |
| Minor | `docs/features/active/2026-11-07-policy-file-consistency-mstest-pester6-1106/evidence/qa-gates/pytest-gate.2026-11-07T15-18.md` | Command line | The pytest gate measured only the five changed modules (`--cov=<module>` per module), so `artifacts/python/lcov.info` holds five files and gives no repo-wide Python figure. The workflow names `pytest -n auto --cov` for the repo-wide check. | In future plans, run the gate with the repository's full `--cov` scope plus `--cov-branch`, so one artifact serves both the per-file and the repo-wide check. | This review derived the repo-wide figure from the merge-base CI log. The derivation holds because the denominators are unchanged, but an artifact read is the contract. | Policy audit Section 1.2.1; CI run 42366932636 |
| Minor | `tests/scripts/dev_tools/atomic_executor/test_prompt_builder.py` | `test_real_filesystem_reports_missing_directory` | The test calls `RealPromptBuilderFileSystem` against the host path `/issue-1106-missing-directory`. The result depends on that path not existing on the host. | Accept as a thin adapter probe, or point it at a path under the repository that is guaranteed absent. | `general-unit-test.md` asks unit tests to avoid external state. The read is harmless and the path is unlikely to exist, so the risk is low. | Lines 762-768 at head |
| Minor | `tests/scripts/dev_tools/atomic_executor/test_prompt_builder.py` | `test_build_renders_optional_sections_and_task_block` | One test asserts the retry section, the Phase 0 section and its filtering, task-block extraction with blank lines, and the size warning. | Split into focused tests when the file is next touched (this also helps the Warning row). | Isolation principle: a failure should identify one behavior. | Lines 704-760 at head |
| Info | `.vscode/tasks.json`, `scripts/dev_tools/atomic_executor/__init__.py` | line 201; line 2 | Two `lexile` strings remain: the input description `Lexile OpenAI Key` and the module docstring `Atomic task-by-task executor for lexile-corpus-tuner.` | Neutralize them in a later change if desired. | Neither is a coverage path or a D4 surface, and the guard's code row forbids only the coverage argument. Not a spec gap. | `git grep -n -i lexile` at head |
| Info | `tests/scripts/claude-runtime/policy-toolchain-naming.Tests.ps1` | `PTN-HELPER`, line 170 | The test pins the phrase count at 19. Adding a phrase requires editing the count as well. | Keep as a deliberate tripwire, or drop the count assertion. | It is a maintenance coupling, not a defect. | Line 170 |
| Info | `tests/scripts/claude-runtime/policy-toolchain-naming.Tests.ps1` | `Get-PtnFile`, line 145 | Folder roots scan only `.md` and `.toml` files (policy) or `.py` files (code). A forbidden phrase in a `.json`, `.yml`, or `.ps1` under a scanned root would not be reported. | Accept; the policy surfaces are Markdown and TOML. | The spec defines the scanned roots and phrases; the extension filter is consistent with them. | Lines 145-147 |

---

## Implementation Audit

### Python implementation audit

#### What changed well

- `qc_runner.py` line 86: the stray path was the only `--cov` argument in `FULL_TEST`, and it was replaced with `--cov=scripts/dev_tools`, as D3 requires. Line 373 drops only the stray argument.
- `qc_toolchain.py`, `cli_preflight.py` (argv), and `fix_all_branches_extra.py` drop the stray argument and keep `--cov=scripts/dev_tools`.
- `cli_preflight.py` line 377: the implicit string concatenation now renders `poetry run pytest --cov=scripts/dev_tools --cov-report=term-missing` with one space between tokens.
- `prompt_builder.py` line 303: the backslash continuation in the constraints block remains valid.

#### Typing and API notes

- No signature changed. The test helpers are fully annotated. Pyright reports 0 errors on the eight changed files with the project environment.

#### Error handling and logging

- No error-handling path changed in production. The new tests assert the existing `ValueError` and `RuntimeError` messages.

### PowerShell implementation audit

#### What changed well

- The guard uses `Set-StrictMode -Version Latest`, advanced functions with typed mandatory parameters, ordinal case-insensitive matching, and whitespace collapsing so that wrapped phrases are still found.
- Each file row asserts that it read at least one file, so a wrong root cannot pass vacuously.
- The guard writes nothing and derives the repository root from `$PSScriptRoot`.

#### API and safety notes

- `$script:Resources` is set in `BeforeDiscovery` for the `-ForEach` data, and `$script:RepoRoot` in `BeforeAll`. Both are container-scoped; no global or environment state is set.

#### Error handling and logging

- A row reports every `<file>: <phrase>` pair through the `Should -BeNullOrEmpty` failure output.

### Policy text audit

- C# (D1, D2): the modern pack names MSTest with `[TestClass]`/`[TestMethod]`, `[DataRow]`, `[ClassInitialize]`, MSTest `Assert`, `Verify.MSTest`, and the `MSTest` + `Microsoft.NET.Test.Sdk` + `coverlet.collector` package set, while keeping `dotnet test --collect:"XPlat Code Coverage"` and NSubstitute (D5). `tdd-red` names MSTest and `[DataRow]`. `csharp-atomic-executor` (agent and TOML) names `msbuild` and `vstest.console.exe <test-assembly-paths> /EnableCodeCoverage`. `git grep` finds `dotnet test` under `.github`, `.codex`, and `.agents` nowhere.
- Pester: no policy surface or bundle copy contains `Pester (v5`, `Pester v5`, or `Pester 5`.
- D3 and D4: no policy surface, bundle copy, or code root contains `--cov=src/lexile_corpus_tuner`, and no policy surface contains `lexile` or `gutenberg`.
- Owner rulings: no changed line outside the feature folder contains `>= 90%`, `85%`, or `75%`. The only changed lines with parallel wording are the `powershell-di-unit-test-engineer` descriptions (Copilot agent and Codex TOML, with bundles), where only `v5` became `v6`. `parallel-gate-wording.Tests.ps1` is not in the diff.

---

## Test Quality Audit

### Reviewed test and QA artifacts

- `evidence/qa-gates/pester-gate.2026-11-07T15-25.md`: 15571 tests, 0 failed; 18 `PTN-` and 56 `PGW-` rows pass.
- `evidence/qa-gates/pytest-gate.2026-11-07T15-18.md`: 16204 tests, 0 failures, 0 errors; Q4 contract suites pass.
- `evidence/qa-gates/coverage-threshold.2026-11-07T15-25.md`: per-module thresholds and changed-line check.
- `evidence/qa-gates/parity-and-protected-regions.2026-11-07T15-13.md`: 29 pairs equal; protected-token counts equal at the merge base and HEAD.
- `artifacts/python/lcov.info` and `artifacts/pester/powershell-coverage.xml`: parsed by this review; figures match the evidence.

### Quality assessment prompts

- Can the guard fail? Yes. Its scan function, extracted from the AST, reported 8, 1, 1, 2, 2, and 2 hits on the merge-base text of `.claude/rules/csharp.md`, `.claude/rules/powershell.md`, `.codex/agents/powershell-typed-engineer-c1.toml`, `.github/agents/tdd-red.agent.md`, `python-suppressions.instructions.md`, and `python-unit-test.instructions.md`, and 0 on each HEAD version.
- Does `test_qc_runner.py` discriminate? Yes. It compares the full `FULL_TEST` argv list, so reverting line 86 fails the assertion.
- Do the coverage tests test behavior? Yes. They assert `success`, `failed_step`, and output messages for each gating branch, not only execution.

---

## Security / Correctness Checks

| Check | Result | Evidence |
|---|---|---|
| Secrets or credentials added | None | Diff inspection |
| Generated files hand-edited | No | `generate_codex_agent_variants --check` exit 0 |
| Pack manifests changed | No | No `pack-manifests` path in the diff |
| JSON and TOML still parse | Yes | `.vscode/tasks.json` parses after normalization; `pyproject.toml` loads with `tomllib` |
| Evidence locations | Compliant | `validate_evidence_locations.py --root .` exit 0 |
| Branch current with base | Yes | merge base equals the fetched `origin/main` |

---

## Research Log

- Merge-base CI run 42366932636 (Python 3.13 job) for the repo-wide Python baseline and the per-file baseline cross-check.
- `scripts/dev_tools/validate_orchestration_review_artifacts.py` for artifact structure.

---

## Verdict

**PASS.** No blocking finding. The Warning and the Minor and Info rows are advisory.
