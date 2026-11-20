# Policy Compliance Audit: policy-file-consistency-mstest-pester6 (#1106)

---

**Audit Date:** 2026-11-07
**Audit Type:** Initial feature review of the full branch diff
**Code Under Test:** Full branch diff of `chore/policy-file-consistency` (head `bd5124f47447099c22731e0ff7d64600eada1e69`) against `origin/main` (merge base `bad886e304990d26af56d6bcabc9d543518492e9`, which equals the fetched `origin/main` tip): 98 paths, of which 26 are in the feature folder. Outside the feature folder: 72 paths (70 modified, 2 added). By extension: 45 Markdown, 17 TOML, 8 Python, 1 PowerShell, 1 JSON. Production code: five Python modules under `scripts/dev_tools/` (argv and emitted-text token edits). The PowerShell file and three of the Python files are tests. The remaining paths are policy text, bundle copies, generated Codex variants, `.vscode/tasks.json`, and `pyproject.toml`.

**Coverage Metrics by Language:**

| Language | Files Changed | Tests | Test Result | Baseline Coverage | Post-Change Coverage | New Code Coverage |
|----------|--------------|-------|-------------|-------------------|---------------------|-------------------|
| Python | 8 files | 16204 tests | ✅ 16198 pass, 0 fail, 6 skipped | 96.68% lines | at least 96.94% lines, at least 92.83% branches | 93.20% lines, 77.78% branches (lowest changed module) |
| PowerShell | 1 file | 15571 tests | ✅ 15561 pass, 0 fail, 10 disabled | 94.01% lines | 94.01% lines | N/A - no production file changed |

Rows for TypeScript, C#, and Bash are deleted because the branch diff holds zero files of those languages.

### Coverage Evidence Checklist

- TypeScript baseline coverage artifact: N/A - zero changed TypeScript files
- TypeScript post-change coverage artifact: N/A - zero changed TypeScript files
- PowerShell baseline coverage artifact: evidence/baseline/pester-gate-baseline.2026-11-07T14-58.md (root LINE counter of the pre-change full-tree run)
- PowerShell post-change coverage artifact: artifacts/pester/powershell-coverage.xml
- Python baseline coverage artifact: merge-base `main` push CI run 42366932636, job 128386926953 (Python 3.13), TOTAL line
- Python post-change coverage artifact: artifacts/python/lcov.info
- Per-language comparison summary: Section 1.2.1 of this audit

**Assumption on template source:** the MCP template resolver was not available to this agent. The structure of this audit follows `docs/features/templates/policy_audit/policy-audit.yyyy-MM-ddTHH-mm.md` on the reviewed branch, with the required headings of `scripts/dev_tools/validate_policy_audit_artifact.py`.

**Assumption on PR context:** `artifacts/pr_context.summary.txt` and `artifacts/pr_context.appendix.txt` do not exist in the worktree, and the PR-context collector is an extension command that is not in this agent's tool set. The scope source is the direct diff `git diff bad886e30 bd5124f47`, with the merge base resolved against the freshly fetched `origin/main`.

---

## Executive Summary

The branch does what the spec describes and no blocking finding was found. Every C# surface names MSTest, every supported-version statement names Pester v6, the stray coverage argument is gone from every approved and emitted command, and other-project example text is neutralized. Each of the 29 changed canonical files that has a bundle copy is byte-identical to it, and the Codex variant generator reports no drift.

- Owner authorization for editing the canonical `.github/instructions` files and their mirrors is recorded in `artifacts/orchestration/orchestrator-state.json` `owner_decisions[0]`, in `spec.md` `## Constraints`, and in `evidence/other/pr-body-notes.2026-11-07T15-26.md`. Those edits are therefore not counted as policy violations in this review.
- Owner rulings hold. No changed line in the diff, outside the feature folder, contains `>= 90%`, `85%`, or `75%`. The only changed lines that hold parallel wording are the two `powershell-di-unit-test-engineer` descriptions (plus their bundle copies), where the word diff shows only `v5` replaced by `v6`.
- The guard test can fail. Its scan function, extracted from the test file and run against the merge-base text of six changed files, reported 8, 1, 1, 2, 2, and 2 forbidden phrases, and 0 for each HEAD version (Section 8).
- Coverage passes for both changed languages. The five changed Python modules range from 93.20% to 100% lines and from 77.78% to 100% branches in the single gate run.
- Two spec criteria depend on the PR body (D3 behavior change and owner authorization). They are pending until pr-author runs and are not findings.
- Non-blocking items are recorded in `code-review.2026-11-07T15-31.md`: one file-size Warning (`test_prompt_builder.py`, 768 lines), the scoped Python gate run, a real-filesystem probe in one new test, and two leftover `lexile` strings outside the D4 surfaces.

**Policy documents evaluated:**
- [✅] `general-code-change.instructions.md`
- [✅] `general-unit-test.instructions.md`

**Language-specific policies evaluated:**
- [✅] `python-code-change.instructions.md` + `python-unit-test.instructions.md`
- [✅] `powershell-code-change.instructions.md` + `powershell-unit-test.instructions.md`
- [N/A] TypeScript: no TypeScript file in the branch diff
- [N/A] C#: no C# source file in the branch diff (C# policy text changed; it is reviewed as text in Sections 2 and 9)

Toolchain state: the executor's final static loop, one `Invoke-PoshQCParallelTest` run, and one `pytest -n auto` run all recorded zero findings and zero failures after the last code commit `f9f4fa658`. This review re-ran ruff, black, and pyright check-only on the eight changed Python files with zero findings. It also ran the three changed pytest files (73 passed) and the guard file (18 passed, Pester 6.2.0) as single-file confirmation runs. Those two runs are debugging only, and no review check rests on them.

**Temporary artifacts cleanup:**
- [✅] All temporary/one-time scripts created during development have been deleted: `git status --short` in the worktree was empty before this review wrote its artifacts, and the branch diff holds no script outside `tests/` and the existing `scripts/dev_tools` modules.
- [✅] Any ongoing tooling scripts are fully tested and compliant with repo policies: no tooling script is added.
- Review probes were written only to the session scratchpad.

---

## Rejected Scope Narrowing

No narrowing was rejected. The caller texts below were evaluated against the Scope Invariant.

> "Two spec ACs depend on the PR body (D3 behavior change and owner authorization in the PR body) and are pending until the PR exists; classify them as pending, not FAIL."

This text sets the status of two criteria that cannot be verified before the PR exists. It does not remove files or languages from the audit. The two criteria are listed as pending in the feature audit, with no finding block, consistent with `acceptance-criteria-tracking` `### CI-Dependent Criteria`.

> "test_prompt_builder.py is 768 lines (advisory tier Warning, not blocking)"

This matches `## File Size Limit` in `.claude/rules/general-code-change.md`: 768 lines is above the 700-line advisory tier and below the 800-line hard limit. The file is reported as a Warning row in the code review.

> "test-comment mentions of Pester v5 were intentionally left (historical)."

This matches the spec invariant on historical and test-comment references. The review confirmed that no policy surface or bundle copy still states Pester v5 as the supported version.

---

## Evidence Location Compliance

`poetry run python scripts/dev_tools/validate_evidence_locations.py --root .` exited 0 from the worktree with no output. The branch diff holds no file under `artifacts/`. Evidence is stored under `<FEATURE>/evidence/baseline/`, `<FEATURE>/evidence/qa-gates/`, and `<FEATURE>/evidence/other/`, all canonical kinds. No violations were found.

---

## Process-Reduction Ledger Compliance

Rule: `feature-review-workflow` `### Process-reduction ledger`. `docs/engineering/process-reductions/` exists, so the rule was evaluated.

| Requirement | Status | Evidence |
|------------|--------|----------|
| **A reduction has an entry** | ✅ PASS | The branch reduces no evidence, plan task, gate, or review step. It corrects framework and version names, removes a coverage argument for a package that does not exist, removes a per-file lint ignore for a file that does not exist, and adds a guard test. The spec `## Risks & Mitigations` states that no ledger entry is needed. |

---

## Owner Authorization Verification

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Recorded in the checkpoint** | ✅ PASS | `artifacts/orchestration/orchestrator-state.json` `owner_decisions[0]`: "Owner authorized editing canonical .github/instructions policy files and mirrors to fix xUnit->MSTest, Pester 5.x->6.x, and the stray lexile coverage path." `owner_decisions[1]` records the three owner rulings. The checkpoint `issue-num` is `1106` and `branch_name` is `chore/policy-file-consistency`. |
| **Recorded in the spec** | ✅ PASS | `spec.md` `## Constraints`, first bullet. |
| **Prepared for the PR body** | ✅ PASS | `evidence/other/pr-body-notes.2026-11-07T15-26.md` `## Owner authorization`. The PR does not exist yet (`gh pr list --head chore/policy-file-consistency` returned `[]`), so presence in the PR body is pending. |
| **Orchestrator decisions D1-D7 recorded** | ✅ PASS | `orchestrator_decisions` holds D1 to D7. The spec records D1 in `### Decision record: one runner per profile (D1)` and cites D2 to D7 in `## Scope`, `## Invariants`, and `## Non-Goals`. |

---

## 1. General Unit Test Policy Compliance

### 1.1 Core Principles

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Independence** - Tests run in any order | ✅ PASS | The guard reads repository files in place and keeps its helpers inside one `Describe` `BeforeAll`. The new Python tests use `monkeypatch` and in-memory fakes, which pytest restores after each test. All suites ran under parallel workers (8 Pester shards, `pytest -n auto`). |
| **Isolation** - Each test targets single behavior | ✅ PASS | One `PTN-` row per scanned root. `test_build_renders_optional_sections_and_task_block` asserts several prompt sections in one test, which the code review records as a Minor item. |
| **Fast Execution** - Tests complete quickly | ✅ PASS | The three changed pytest files ran in 0.99 s (73 tests). Gate wall-clock: Pester 401.56 s over 15571 tests; pytest 192.22 s over 16204 tests. |
| **Determinism** - Consistent results | ✅ PASS | No clock, network, or randomness in added tests. `test_real_filesystem_reports_missing_directory` depends on the absence of `/issue-1106-missing-directory` on the host; recorded as Minor. |
| **Readability & Maintainability** - Clear structure | ✅ PASS | Descriptive names, docstrings, `-Because` text, and table-driven rows. |

### 1.2 Coverage and Scenarios

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Changed Files Meet Thresholds** | ✅ PASS | From `artifacts/python/lcov.info`, parsed by this review: `cli_preflight.py` 153/153 lines, 77/78 branches; `prompt_builder.py` 124/124, 44/44; `qc_runner.py` 96/103 (93.20%), 14/18 (77.78%); `qc_toolchain.py` 15/15, no branches; `fix_all_branches_extra.py` 85/85, 24/24. Thresholds 85% line, 75% branch. |
| **New Code Threshold** | ✅ PASS | No production file was added. The added argv text in `qc_runner.py` line 86 and the edited strings in `cli_preflight.py` line 377 and `prompt_builder.py` line 303 are executed lines in the gate run. |
| **Comprehensive Tests** | ✅ PASS | `test_qc_runner.py` asserts the new `FULL_TEST` argv. The guard covers the 14 policy roots and the code roots. The added preflight tests cover toolchain resolution, the empty-argv error, unsupported toolchains, collection failures, and the Jest expectation gate. |
| **Positive Flows** - Valid inputs | ✅ PASS | `PTN-HELPER-CLEAN`, the expected-Jest-failure rows, and `test_build_renders_optional_sections_and_task_block`. |
| **Negative Flows** - Invalid inputs | ✅ PASS | `PTN-HELPER` (all 19 phrases detected in upper case), `test_resolve_executable_rejects_empty_argv`, `test_unsupported_toolchain_raises`, and the unexpected-failure rows. |
| **Edge Cases** - Boundary conditions | ✅ PASS | `PTN-HELPER-EXEMPT` (prohibition line and generic CI list); whitespace collapsing for phrases wrapped across lines; a path with spaces (`Powershell DI Unit Test Engineer.agent.md`) is read by the GITHUB-AGENTS row. |
| **Error Handling** - Error paths | ✅ PASS | `ValueError` and `RuntimeError` paths in `cli_preflight` are asserted with `pytest.raises(..., match=...)`. |
| **Concurrency** - If applicable | N/A | The added tests have no concurrent behavior. |
| **State Transitions** - If applicable | ✅ PASS | The preflight step sequence (static steps, collect, test) is exercised through the collect-failure and test-failure rows. |

### 1.2.1 Per-Language Coverage Comparison

- Python: Baseline: 96.68% lines -> Post-change: at least 96.94% lines, at least 92.83% branches. Change: +0.26 percentage points of lines or more. New/changed-code coverage: 93.20% lines and 77.78% branches for the lowest changed module. Disposition: PASS. Evidence: artifacts/python/lcov.info; docs/features/active/2026-11-07-policy-file-consistency-mstest-pester6-1106/evidence/qa-gates/pytest-gate.2026-11-07T15-18.md; merge-base CI run 42366932636.
- PowerShell: Baseline: 94.01% lines -> Post-change: 94.01% lines. Change: +0.00 percentage points. Disposition: PASS. Evidence: artifacts/pester/powershell-coverage.xml; docs/features/active/2026-11-07-policy-file-consistency-mstest-pester6-1106/evidence/qa-gates/pester-gate.2026-11-07T15-25.md.

Thresholds: the root `CLAUDE.md` states none, so the defaults of 85% line and 75% branch govern. Pester reports no branch figure, and no branch threshold applies to PowerShell.

Python detail. The executor's gate run measured the five changed modules only (`--cov=<module>` for each, `--cov-branch`), so `artifacts/python/lcov.info` holds those five files: 473 of 480 lines (98.54%) and 173 of 182 branches (95.05%). It does not give a repo-wide figure. The repo-wide figure was taken from the merge-base `main` push CI run 42366932636, job `quality-checks7 / Code Quality & Tests (3.13)`. Its TOTAL line reads 33459 statements, 1111 not run, 12558 branches, 547 partial, 96% combined, and its "Enforce Python coverage thresholds" step (`--min-line 85 --min-branch 75`) succeeded. Baseline line coverage is 32348 of 33459 (96.68%). Because the combined figure is rounded to an integer, covered branches are at least 0.955 x 46017 - 32348 = 11599 (92.36%). The branch leaves the statement and branch denominators of the five modules unchanged (same counts at base and head) and changes no other production Python file. It raises covered lines by 86 (`cli_preflight.py` 99 to 153, `prompt_builder.py` 92 to 124) and covered branches by 59 (36 to 77 and 26 to 44). The head figures in the table are lower bounds derived from these counts. The per-file rows of the CI log for the five modules match the executor's Phase 0 baseline exactly, which confirms that the two sources measure the same code. CI on the PR head will report the exact head figure through the same threshold step.

PowerShell detail. The root LINE counter of `artifacts/pester/powershell-coverage.xml` is 24046 covered and 1532 not run (94.01%). `artifacts/pester/pester-junit.xml` reads 15571 tests, the full-tree count recorded by the gate. The artifact was written at 10:24 local time (15:24 UTC), after the last code commit. No production PowerShell file changed, so the figure equals the pre-change run.

### 1.3 Test Structure and Diagnostics

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Clear Failure Messages** | ✅ PASS | Each `PTN-` violation line has the form `<file>: <phrase>`, and each assertion carries `-Because` text. Python assertions compare full argv lists or tuples. |
| **Arrange-Act-Assert Pattern** | ✅ PASS | Explicit `# Arrange`, `# Act`, and `# Assert` comments in the guard; the Python tests follow the same order. |
| **Document Intent** | ✅ PASS | The guard header states its purpose and that it writes nothing. Each new Python test and helper has a docstring. |

### 1.4 External Dependencies and Environment

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Avoid External Dependencies** | ✅ PASS | No network or child process. `subprocess.run` and `shutil.which` are replaced through `monkeypatch` in the preflight tests. |
| **Use Mocks/Stubs** | ✅ PASS | `InMemoryPromptBuilderFileSystem`, `Mock(detected_qc_toolchains=...)`, and patched parsers. |
| **Environment Stability** | ✅ PASS | The guard derives the repository root from `$PSScriptRoot` and creates no file. No temporary file is created by any added test. |

### 1.5 Policy Audit Requirement

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Pre-submission Review** | ✅ PASS | This document is the required review. The executor's self-review is `evidence/qa-gates/self-review.2026-11-07T15-27.md`. |

---

## 2. General Code Change Policy Compliance

### 2.1 Before Making Changes

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Read policies in order** | ✅ PASS | `evidence/baseline/phase0-instructions-read.2026-11-07T14-48.md`. |
| **Static baselines captured** | ✅ PASS | Five static baseline artifacts under `evidence/baseline/` plus the pytest and Pester baseline runs. |
| **Canonical policy edits authorized** | ✅ PASS | Owner authorization for issue #1106 (see Owner Authorization Verification). |

### 2.2 Design Principles

| Principle | Status | Evidence |
|-----------|--------|----------|
| **Simplicity** | ✅ PASS | Token-level edits; the D3 change deletes one list element or replaces one string per site. |
| **Reusability** | ✅ PASS | The guard reuses the structure of `parallel-gate-wording.Tests.ps1`. The new test helpers `_expectations` and `_patch_qc_run` are shared across rows. |
| **Extensibility** | ✅ PASS | The forbidden-phrase list and the root table are data, so new phrases or roots are one-line additions. |
| **Separation of Concerns** | ✅ PASS | The guard separates matching (`Get-PtnForbiddenHit`), file discovery (`Get-PtnFile`), and reporting (`Get-PtnViolation`). |

### 2.3 Module & File Structure

| Requirement | Status | Evidence |
|------------|--------|----------|
| **File size tiers** | ✅ PASS | Largest covered file in the diff: `test_prompt_builder.py` at 768 logical lines (advisory Warning, non-blocking). Others: `test_cli_part3.py` 677, `test_qc_runner.py` 665, `qc_runner.py` 570, `prompt_builder.py` 434, `cli_preflight.py` 412, `fix_all_branches_extra.py` 358, guard 195, `qc_toolchain.py` 77. No file exceeds 800, and `config/file-size-baseline.json` is unchanged. |
| **Test location** | ✅ PASS | The guard is under `tests/scripts/claude-runtime/`; Python tests stay in `tests/scripts/dev_tools/atomic_executor/`. |
| **Tier classification** | ✅ PASS | `quality-tiers.yml` exists on the base. `poetry run python -m scripts.dev_tools.check_quality_tiers` at head: `quality-tiers: OK (29 entries, 29 discovered projects)`. |

### 2.4 Naming, Docs, and Comments

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Descriptive names** | ✅ PASS | `Get-PtnForbiddenHit`, `TestPreflightQCBranches`, `TestPromptBuilderOptionalSections`. |
| **Docs and comments** | ✅ PASS | Comment-based help on all three guard helpers; docstrings with Args and Returns on the Python helpers. |
| **Neutral example names** | ✅ PASS | D4 replacements use `scoring model`, `TextCorpus`, `ScoringModel`, `HttpTextSource`, `compute_readability_score`, `model.pkl`, `query_core`, `my_package`, and `feature_module`. |

### 2.5 After Making Changes - Toolchain Execution

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Format** | ✅ PASS | `final-black` and `final-psformat` artifacts; reviewer `black --check` on 8 files: unchanged. |
| **Lint** | ✅ PASS | `final-ruff` and `final-pssa` (0 findings); reviewer `ruff check` on 8 files: all checks passed. |
| **Type check** | ✅ PASS | `final-pyright` 0 errors; reviewer pyright with `--venvpath` at the main checkout: 0 errors. Without `--venvpath` the worktree has no environment and pyright reports import-resolution errors, which are environmental. |
| **Unit tests** | ✅ PASS | One Pester gate and one pytest gate, 0 failures each. |
| **Contract checks** | ✅ PASS | Q4 contract suites pass in the pytest gate; the generator `--check` exits 0 (re-run by this review). |

### 2.6 Summarize and Document

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Change summary prepared** | ✅ PASS | `evidence/other/pr-body-notes.2026-11-07T15-26.md` states the owner authorization and the D3 behavior change. |

---

## 3. Language-Specific Code Change Policy Compliance

### Section 3A: Python Code Change Policy Compliance

#### 3A.1 Tooling & Baseline

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Black, Ruff, Pyright baselines** | ✅ PASS | `evidence/baseline/static-black`, `static-ruff`, `static-pyright` (all clean). |
| **Final toolchain clean** | ✅ PASS | `evidence/qa-gates/final-black`, `final-ruff`, `final-pyright`, plus reviewer re-runs. |

#### 3A.2 Python Design & Typing

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Type annotations** | ✅ PASS | New helpers carry full annotations; `set[str]()` is used for typed empty sets in parametrize data. |
| **No new untyped escape hatches** | ✅ PASS | `parametrize` rows typed as `object` where the value is deliberately heterogeneous; no `Any` added. |
| **Behavior change stated** | ✅ PASS | The D3 coverage-target change is stated in the spec `## Risks & Mitigations` and in the PR-body notes. |

#### 3A.3 Python Error Handling

| Requirement | Status | Evidence |
|------------|--------|----------|
| **No silent failures introduced** | ✅ PASS | Production edits remove argv elements only; no exception handling changed. |

### Section 3B: PowerShell Code Change Policy Compliance

#### 3B.1 Tooling & Baseline

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Format and analyzer** | ✅ PASS | `evidence/baseline/static-psformat`, `static-pssa`; `evidence/qa-gates/final-psformat`, `final-pssa` (0 findings over `tests/scripts/claude-runtime`). |

#### 3B.2 PowerShell Design & Safety

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Advanced functions** | ✅ PASS | All three guard helpers use `CmdletBinding`, `OutputType`, and mandatory typed parameters. |
| **StrictMode** | ✅ PASS | `Set-StrictMode -Version Latest` at the top of the guard. |
| **ShouldProcess** | ✅ PASS | No helper changes state; the guard only reads files. |

#### 3B.3 Structure, Naming, and Comments

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Approved verbs** | ✅ PASS | `Get-` for all three helpers. |
| **Comment-based help** | ✅ PASS | `.SYNOPSIS`, `.PARAMETER`, and `.OUTPUTS` on each helper. |

#### 3B.4 Running the Toolchain

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Parallel gate** | ✅ PASS | One `Invoke-PoshQCParallelTest` run, ExitCode 0, 15571 tests, 0 failed (`evidence/qa-gates/pester-gate.2026-11-07T15-25.md`). |

---

## 4. Language-Specific Unit Test Policy Compliance

### Section 4A: Python Unit Test Policy Compliance

#### 4A.1 Framework and Scope

| Requirement | Status | Evidence |
|------------|--------|----------|
| **pytest framework** | ✅ PASS | All Python tests use pytest fixtures (`monkeypatch`, `caplog`) and `parametrize`. |
| **Coverage expectation** | ✅ PASS | Changed modules 93.20% to 100% lines and 77.78% to 100% branches; repo-wide at least 96.94% lines and 92.83% branches (Section 1.2.1). |

#### 4A.2 Test Style and Structure

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Mirrored location** | ✅ PASS | Tests sit under `tests/scripts/dev_tools/atomic_executor/`. |
| **One behavior per test** | ⚠️ PARTIAL | `test_build_renders_optional_sections_and_task_block` asserts retry, Phase 0, task-block, and size-warning behavior together. Non-blocking; recorded as Minor in the code review. |

#### 4A.3 Naming and Readability

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Descriptive names and docstrings** | ✅ PASS | Every new test has a docstring that states the expected outcome. |

#### 4A.4 Running the Toolchain

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Parallel gate** | ✅ PASS | `pytest -n auto`, 16198 passed, 0 failed, 0 errors (`evidence/qa-gates/pytest-gate.2026-11-07T15-18.md`). |

### Section 4B: PowerShell Unit Test Policy Compliance

#### 4B.1 Framework and Scope

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Pester framework** | ✅ PASS | Pester 6.2.0 (reported by the reviewer confirmation run). |
| **Repo-wide line threshold** | ✅ PASS | 94.01% lines against 85%. |

#### 4B.2 Test Style and Structure

| Requirement | Status | Evidence |
|------------|--------|----------|
| **No temporary files** | ✅ PASS | The guard reads files in place with `[System.IO.File]::ReadAllText` and writes nothing. |
| **No leaked state** | ✅ PASS | Helpers are defined in the `Describe` `BeforeAll`; the only script-scoped values (`Resources`, `RepoRoot`, phrase lists) are set within the test container. No `$global:` or environment variable is set. |
| **Describe/It structure** | ✅ PASS | One `Describe` with one data-driven `It` (15 rows) and three helper `It` blocks. |

#### 4B.3 Naming and Readability

| Requirement | Status | Evidence |
|------------|--------|----------|
| **File name** | ✅ PASS | `policy-toolchain-naming.Tests.ps1`. |
| **Row identifiers** | ✅ PASS | `PTN-<Id>` row names identify the scanned root in failure output. |

#### 4B.4 Running the Toolchain

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Parallel gate** | ✅ PASS | All 18 `PTN-` rows and all 56 `PGW-` rows passed in the gate run. |

---

## 5. Test Coverage Detail

### policy-toolchain-naming.Tests.ps1 (18 tests)

| Test | Type | Target | Status |
|------|------|--------|--------|
| `PTN-<Id>` (15 rows) | Contract | 14 policy roots and the code roots | ✅ |
| `PTN-HELPER` | Negative | `Get-PtnForbiddenHit` detects each of 19 phrases | ✅ |
| `PTN-HELPER-CLEAN` | Positive | MSTest and Pester v6 text yields no hit | ✅ |
| `PTN-HELPER-EXEMPT` | Edge Case | The prohibition line and the generic CI list yield no hit | ✅ |

**Coverage:** test code only; no production PowerShell file changed.

**Not covered:** `Get-PtnFile` and `Get-PtnViolation` have no in-memory test; their behavior is exercised by the 15 file rows, and each row asserts that it read at least one file.

### Python tests (19 new tests, 1 updated)

| Test | Type | Target | Status |
|------|------|--------|--------|
| `test_run_full_runs_all_tools_on_entire_codebase` (updated) | Positive | `QCRunner.FULL_TEST` argv | ✅ |
| `TestPreflightQCBranches` (17 cases) | Positive, Negative, Error | `cli_preflight` resolution, errors, collect and test gating | ✅ |
| `TestPromptBuilderOptionalSections` (2 tests) | Positive, Edge Case | `PromptBuilder.build` optional sections; `RealPromptBuilderFileSystem` on an absent directory | ✅ |

**Coverage:** see Section 1.2.1.

**Not covered:** `qc_runner.py` lines 152, 195, 300, 301, 477, 509, and 564 were already uncovered at the base and are not changed lines.

---

## 6. Test Execution Metrics

| Metric | Value | Status |
|--------|-------|--------|
| Total Tests | Pester 15571; pytest 16204 | ✅ |
| Failures | 0 and 0 | ✅ |
| New Tests | 18 Pester, 19 pytest, 1 updated | ✅ |
| Functions/Classes Tested | Three guard helpers; `cli_preflight`, `prompt_builder`, `QCRunner` | ✅ |
| Code Coverage (if applicable) | Python changed modules 93.20% to 100% lines; PowerShell 94.01% lines | ✅ |

---

## 7. Code Quality Checks

**For Python:**
- Black: ✅ PASS (8 files unchanged)
- Ruff: ✅ PASS (all checks passed)
- Pyright: ✅ PASS (0 errors with the project environment)

**For PowerShell:**
- Invoke-Formatter: ✅ PASS (`final-psformat`)
- PSScriptAnalyzer: ✅ PASS (0 findings)

**Other checks:**
- Codex variant generator `--check`: ✅ PASS (exit 0, re-run by this review)
- Bundle parity: ✅ PASS (29 pairs byte-identical by `cmp`, re-run by this review)
- `.vscode/tasks.json`: ✅ PASS (parses after comment and trailing-comma normalization)
- `pyproject.toml`: ✅ PASS (parses with `tomllib`)

**Notes:**
- Pyright run without `--venvpath` from the worktree reported 108 errors (`reportMissingImports` and derived unknown-type errors), because the worktree has no local virtual environment. With the main checkout environment it reported 0 errors, matching the executor's recorded command.

---

## 8. Gaps and Exceptions

### Identified Gaps

- Guard discrimination was verified by this review. The `Get-PtnForbiddenHit` function was extracted from the test file's AST and run, with the guard's 19 phrases, against the merge-base and HEAD text of six changed files. Merge-base hits: `.claude/rules/csharp.md` 8, `.claude/rules/powershell.md` 1, `.codex/agents/powershell-typed-engineer-c1.toml` 1, `.github/agents/tdd-red.agent.md` 2, `python-suppressions.instructions.md` 2, `python-unit-test.instructions.md` 2. HEAD hits: 0 for each.
- The Python gate run was scoped to the five changed modules, so the repo-wide Python figure is derived from the merge-base CI run (Section 1.2.1). Non-blocking.
- Two `lexile` strings remain outside the D4 surfaces: the `.vscode/tasks.json` input description `Lexile OpenAI Key` and the `scripts/dev_tools/atomic_executor/__init__.py` docstring. Neither is a coverage path or a named D4 surface. Non-blocking.

### Approved Exceptions

- Canonical policy files under `.github/instructions` and their mirrors were edited under the owner authorization for issue #1106.
- `xUnit` remains in the prohibition `Do not introduce xUnit or NUnit into existing test projects.` and in the generic CI list in `github-actions-ci-cd-best-practices.instructions.md` (D6).
- `clean_devcontainer.py` names and `LEXILE_TK_SCALE` are unchanged (D7).

### Removed/Skipped Tests

- None. The skipped counts (6 pytest, 10 Pester) equal the baseline runs.

---

## 9. Summary of Changes

### Commits in This PR/Branch

26 commits from `3d5e6264e` to `bd5124f47`. Code and policy commits: `b432aab09` (P1-T1 modern C# pack and README), `3c083f58d` (P1-T2 tdd-red), `f2a1dcd1d` (P1-T3 csharp-atomic-executor), `18d566777` (P2-T1 Pester v6), `d17882047` (P2-T2 Codex variants), `04f930dd8` (P3-T1 stray coverage path in instructions), `3b21425f6` (P3-T2 Python argv), `6eea4c6bd` (P3-T3 neutral examples), `13b674f99` (P4-T1 guard), `f9f4fa658` (coverage tests). The other 16 commits add feature documents and evidence.

### Files Modified

1. **C# surfaces (D1, D2)**
   - `.claude/rules/csharp.md`, `.claude/agents/csharp-typed-engineer.md`, `.claude/skills/csharp-qa-gate/SKILL.md`, `.claude/skills/invoke-csharp-engineer/SKILL.md`, `README.md`: xUnit idioms replaced by MSTest idioms; modern runner unchanged.
   - `.github/agents/tdd-red.agent.md`: MSTest with `[DataRow]` data-driven tests.
   - `.github/agents/csharp-atomic-executor.agent.md`, `.codex/agents/csharp-atomic-executor.toml`: `msbuild` and `vstest.console.exe` commands, verbatim from `csharp-unit-test.instructions.md` section 3.
2. **Pester version**
   - Rule, `.agents` skill, instruction file, five agents, seven Codex TOML files (six generated), README, and the policy-audit template: v5 replaced by v6.
3. **Stray coverage path (D3)**
   - `python-unit-test.instructions.md`, `.vscode/tasks.json`, four `atomic_executor` modules, `fix_all_branches_extra.py`, `pyproject.toml`.
4. **Neutral examples (D4)**
   - Three instruction files, `commit-steward.agent.md`, two prompts, two policy-audit template files.
5. **Tests**
   - New guard; `test_qc_runner.py` argv; coverage tests in `test_cli_part3.py` and `test_prompt_builder.py`.
6. **Bundles**
   - 29 bundle copies under `extensions/drm-copilot/resources/`, each byte-identical to its source. `docs/features/templates/policy_audit/README.md` has no bundle copy at the base, and none was added (no manifest change).

---

## 10. Compliance Verdict

### Overall Status: ✅ COMPLIANT

All policy requirements evaluated are met, coverage passes for Python and PowerShell, and no blocking finding exists. Two acceptance criteria are pending the PR body.

**Fail-closed reminder:** numeric post-change coverage is recorded for every changed language, and changed-module coverage is recorded for the five changed production files.

---

### Policy-by-Policy Summary

#### General Code Change Policy (Section 2)

- ✅ Design, structure, naming, and toolchain requirements met; file-size Warning only.

#### Language-Specific Code Change Policy (Section 3)

**For Python:**
- ✅ Token-only production edits, typed tests, toolchain clean.

**For PowerShell:**
- ✅ Advanced functions, StrictMode, comment-based help, 0 analyzer findings.

#### General Unit Test Policy (Section 1)

- ✅ Coverage & Scenarios: both changed languages above the thresholds; changed lines executed.
- ✅ Determinism and isolation, with two Minor notes in the code review.

#### Language-Specific Unit Test Policy (Section 4)

**For Python:**
- ⚠️ One multi-behavior test (non-blocking).

**For PowerShell:**
- ✅ No temporary files, no leaked state, and the guard is shown to fail on the old wording.

---

### Metrics Summary

| Metric | Value |
|--------|-------|
| Paths in diff | 98 (72 outside the feature folder) |
| Bundle pairs byte-identical | 29 of 29 |
| Pester tests | 15571, 0 failed |
| pytest tests | 16204, 0 failed |
| Python changed-module lines | 93.20% to 100% |
| PowerShell repo-wide lines | 94.01% |
| Blocking findings | 0 |

---

### Recommendation

**Ready for PR.** The PR body must carry the owner authorization and the D3 behavior change from `evidence/other/pr-body-notes.2026-11-07T15-26.md`.

---

## Appendix A: Test Inventory

### Complete Test List

- `tests/scripts/claude-runtime/policy-toolchain-naming.Tests.ps1`: `PTN-CLAUDE-RULES`, `PTN-CLAUDE-AGENTS`, `PTN-CLAUDE-SKILLS`, `PTN-AGENTS-SKILLS`, `PTN-GITHUB-INSTRUCTIONS`, `PTN-GITHUB-AGENTS`, `PTN-GITHUB-PROMPTS`, `PTN-CODEX-AGENTS`, `PTN-TEMPLATES`, `PTN-README`, `PTN-CLAUDE-BUNDLE`, `PTN-GITHUB-BUNDLE`, `PTN-CODEX-AGENTS-BUNDLE`, `PTN-TEMPLATES-BUNDLE`, `PTN-CODE`, `PTN-HELPER`, `PTN-HELPER-CLEAN`, `PTN-HELPER-EXEMPT`.
- `tests/scripts/dev_tools/atomic_executor/test_qc_runner.py`: `TestQCRunnerRunFull::test_run_full_runs_all_tools_on_entire_codebase` (updated).
- `tests/scripts/dev_tools/atomic_executor/test_cli_part3.py` `TestPreflightQCBranches`: `test_resolve_preflight_toolchains_defaults_and_orders` (4 cases), `test_resolve_executable_rejects_empty_argv`, `test_unsupported_toolchain_raises`, `test_collect_step_missing_executable_fails`, `test_collect_step_nonzero_exit_fails`, `test_pytest_failures_outside_expectations_fail` (2 cases), `test_jest_failures_are_gated_by_expectations` (7 cases).
- `tests/scripts/dev_tools/atomic_executor/test_prompt_builder.py` `TestPromptBuilderOptionalSections`: `test_build_renders_optional_sections_and_task_block`, `test_real_filesystem_reports_missing_directory`.

---

## Appendix B: Toolchain Commands Reference

**For Python:**
```
# Reviewer runs at head, check-only, over the eight changed Python files
poetry run ruff check <files>
poetry run black --check <files>
poetry run pyright --venvpath <main checkout> <files>
poetry run python -m pytest -q -n 4 <three changed test files>   # debugging only
poetry run python -m scripts.dev_tools.generate_codex_agent_variants --check
poetry run python -m scripts.dev_tools.check_quality_tiers
poetry run python scripts/dev_tools/validate_evidence_locations.py --root .
# Gate, per evidence/qa-gates/pytest-gate.2026-11-07T15-18.md
python -m pytest -n auto --cov=<five modules> --cov-branch --cov-report=json
# Baseline repo-wide figure
gh run view -R drmoisan/drm-copilot --job 128386926953 --log
```

**For PowerShell:**
```
# Gate, per evidence/qa-gates/pester-gate.2026-11-07T15-25.md
Import-Module ./scripts/powershell/PoshQC/PoshQC.psd1 -Force; Invoke-PoshQCParallelTest -Root <worktree>
# Reviewer confirmation run (debugging only)
Invoke-Pester -Path tests/scripts/claude-runtime/policy-toolchain-naming.Tests.ps1 -PassThru -Output None
# Reviewer discrimination probe: Get-PtnForbiddenHit extracted from the test AST, run on merge-base and HEAD file text
```

No coverage run was made by this review. Coverage figures were parsed from the existing artifacts and the merge-base CI log.

---

**Audit Completed By:** feature-review agent
**Audit Date:** 2026-11-07
**Policy Version:** Current (as of audit date)
