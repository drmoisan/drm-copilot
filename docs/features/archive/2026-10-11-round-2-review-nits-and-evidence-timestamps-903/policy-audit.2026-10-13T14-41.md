# Policy Compliance Audit: Round-2 review nits and evidence timestamps (#903)

---

**Audit Date:** 2026-10-13
**Branch:** `bug/round-2-review-nits-and-evidence-timestamps-903` (HEAD `fcd493fa1`)
**Base:** `origin/main` (`fd81a43b4`; merge base equals `origin/main` tip)
**Work Mode:** `minor-audit`
**Code Under Test:** 189 changed files (6824 insertions, 411 deletions). Non-documentation code: 20 production PowerShell files (10 root copies under `.claude/hooks/`, `.codex/hooks/`, `.claude/lib/blast-radius/` and 10 byte-identical bundle mirrors under `extensions/drm-copilot/resources/`), 15 Pester test or helper files, 1 production Python file (`scripts/dev_tools/_blast_radius_token_shapes.py`), 7 Python test files (2 new), 2 TypeScript test files, 13 skill `SKILL.md` files (6 root, 7 bundle mirrors), plus feature-folder documentation and evidence.

**Total blocking findings: 1** (PA-1, PowerShell changed-line coverage regression in `.codex/hooks/enforce-orchestration-preimplementation-gate-targets.ps1`).

**Coverage Metrics by Language:**

| Language | Files Changed | Tests | Test Result | Baseline Coverage | Post-Change Coverage | New Code Coverage |
|----------|--------------|-------|-------------|-------------------|---------------------|-------------------|
| Python | 8 files (1 production, 7 test) | 7094 tests (full suite) | ✅ 7094 pass, 0 fail, 6 skipped | 93.8% lines, 88.11% branches | 93.8% lines, 88.11% branches | 100% lines and 100% branches (`_blast_radius_token_shapes`) |
| PowerShell | 35 files (20 production incl. mirrors, 15 test) | 10299 Windows testcases, 6212 Linux hook-suite testcases | ✅ 10289 pass, 0 fail, 10 skipped (Windows); 6212 pass (Linux) | 89.52% cmds (repo-wide, CI run 38386628228) | 89.58% cmds (repo-wide, CI run 38410234897) | 95.45% changed lines (147/154); 2 previously covered changed lines now uncovered |
| TypeScript | 2 files (test only) | 4002 tests (270 suites) | ✅ 4002 pass, 0 fail | 97.26% lines, 92.28% branches | 97.26% lines, 92.28% branches | N/A (no production TypeScript changed) |
| C# | 0 files | N/A | N/A | N/A (no changed files) | N/A (no changed files) | N/A |

### Coverage Evidence Checklist

- TypeScript baseline coverage artifact: `docs/features/active/2026-10-11-round-2-review-nits-and-evidence-timestamps-903/evidence/baseline/ts-jest-coverage.2026-10-13T10-42.md`
- TypeScript post-change coverage artifact: `docs/features/active/2026-10-11-round-2-review-nits-and-evidence-timestamps-903/evidence/qa-gates/ts-jest-coverage.2026-10-13T13-49.md` (local lcov at `extensions/drm-copilot/coverage/lcov.info`; the contract path `coverage/lcov.info` at repo root is not produced for extension-only changes)
- PowerShell baseline coverage artifact: `docs/features/active/2026-10-11-round-2-review-nits-and-evidence-timestamps-903/evidence/baseline/ps-coverage-baseline.2026-10-13T11-14.md` (CI run 38386628228 XML)
- PowerShell post-change coverage artifact: `docs/features/active/2026-10-11-round-2-review-nits-and-evidence-timestamps-903/evidence/qa-gates/ps-coverage.2026-10-13T14-28.md` (CI run 38410234897 XML, re-read by this reviewer)
- Per-language comparison summary: section 1.2.1 of this audit and `docs/features/active/2026-10-11-round-2-review-nits-and-evidence-timestamps-903/evidence/qa-gates/coverage-comparison.2026-10-13T14-29.md`

---

## Executive Summary

The branch delivers issue #903 P7 (UTC write-time evidence filename and `Timestamp` conventions in six `evidence-and-timestamp-conventions` and six `atomic-plan-contract` copies) and P8 (fixes or recorded dispositions for round-2 review notes from #793, #797, #845, #846, #565, #736, #732, and #737). #737 F-1/F-2 were withheld under the AC-34/AC-35 withhold branch; #732 CR-3 was retained.

Final CI (workflow_dispatch run 38410234897 on `17a6497e4`) concluded success on all 17 jobs; commits after `17a6497e4` change only the feature folder (`git diff --name-only 17a6497e4 HEAD` lists nine feature-folder paths). No pull request exists yet (`gh pr list --head ...` returned `[]`).

One policy violation is blocking. The uniform gate "no regression on changed lines" (`.claude/rules/quality-tiers.md`) and the rule "Code changes or refactors must not reduce coverage for the lines that were changed" (`.claude/rules/general-unit-test.md`) are not met for `.codex/hooks/enforce-orchestration-preimplementation-gate-targets.ps1` lines 356 and 370: both are CR-4 wraps of statements that had `ci` 1 at baseline (lines 318 and 327) and have `ci` 0 in the final CI coverage XML. This reviewer re-read both XML files directly and confirmed the values.

**Policy documents evaluated:**
- ✅ `.claude/rules/general-code-change.md` (mirror of `general-code-change.instructions.md`)
- ✅ `.claude/rules/general-unit-test.md` (mirror of `general-unit-test.instructions.md`)
- ✅ `.claude/rules/quality-tiers.md`

**Language-specific policies evaluated:**
- ✅ `.claude/rules/python.md` (Python code change and unit test)
- ✅ `.claude/rules/powershell.md` (PowerShell code change and unit test)
- ✅ `.claude/rules/typescript.md` (TypeScript test-only changes)
- N/A C#: no changed files.
- N/A Bash: no changed files.
- N/A JSON: no changed governed JSON files.

**Temporary artifacts cleanup:**
- ✅ No temporary script is committed. Executor helper scripts live under the gitignored `artifacts/scratch-903/` and are not in the branch diff.
- ✅ No ongoing tooling script was added.
- This reviewer ran a targeted pytest with `--cov`, which rewrote the gitignored `artifacts/python/lcov.info` with the same module scope (`scripts.dev_tools._blast_radius_token_shapes`) that the executor's prior file covered; no tracked file changed.

---

## Rejected Scope Narrowing

None detected. The caller prompt fixed the diff base at `origin/main...HEAD`, which matches the resolved merge base; it did not narrow scope to a plan, phase, task, file subset, or language.

## Evidence Location Compliance

- `poetry run python scripts/dev_tools/validate_evidence_locations.py --root .` (run by this reviewer from the item worktree): exit 0.
- `git diff --name-only origin/main...HEAD` lists no path under `artifacts/baselines/`, `artifacts/qa/`, `artifacts/evidence/`, or `artifacts/coverage/`.
- Result: PASS. No EVIDENCE_LOCATION_OVERRIDE_REJECTED entries were needed.

---

## 1. General Unit Test Policy Compliance

### 1.1 Core Principles

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Independence** - Tests run in any order | ✅ PASS | New Pester rows use per-It arrange blocks and Pester mocks scoped to the It (`Mock Read-ClaudeHookRawPayload` in the O-4 default-reader row). New pytest modules read committed files only. |
| **Isolation** - Each test targets single behavior | ✅ PASS | One behavior per row: U11b/U11c/U11d (relocation regex), U24 (missing `git`), U25 (one outcome per data row), M8fe/M8fp, S06 per character. |
| **Fast Execution** - Tests complete quickly | ✅ PASS | Targeted Python run (188 tests) completed in 0.66s locally. CI Pester `[+]` lines for edited files range 85ms to 994ms, except `codex-pretooluse-integration.Tests.ps1` at 51.2s (pre-existing integration suite). |
| **Determinism** - Consistent results | ✅ PASS | No clock, randomness, sleep, or network use in new tests (grep for `tmp_path`, `tempfile`, `TestDrive`, `Start-Sleep`, `time.sleep` over the new and changed test files returned no match). Non-ASCII inputs are built with `chr(...)` and `[char]0x...`. |
| **Readability & Maintainability** - Clear structure | ✅ PASS | Row ids carry the review-note key (U11b, M8fe, O-4) and `-Because` text names the issue. |

### 1.2 Coverage and Scenarios

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Baseline Coverage Documented** | ✅ PASS | **Baseline (pre-development):** Python 93.8% lines / 88.11% branches; TypeScript 97.26% lines / 92.28% branches; PowerShell per-file values for ten production files from CI run 38386628228 on PHASE0 `95d6c9b22`.<br>**Timestamp:** 2026-10-13 00:14 to 11:14 (UTC, per evidence filenames) |
| **No Coverage Regression** | ❌ FAIL | **Post-change coverage:** Python and TypeScript unchanged; PowerShell repo-wide 89.52% -> 89.58%.<br>**Status:** Regression detected on changed lines: `.codex/hooks/enforce-orchestration-preimplementation-gate-targets.ps1:356` and `:370` (`ci` 1 at baseline lines 318/327, `ci` 0 at head). Per-file: Codex targets 100.0% -> 98.16%, Claude targets 100.0% -> 99.39%, Claude epic-scope 98.63% -> 98.53%. Finding PA-1 (Blocking). |
| **New Code Coverage ≥85% (uniform tier rule)** | ✅ PASS | New/modified production files: all ten root PowerShell copies at or above 85% (lowest 89.09%, Codex epic-scope); `_blast_radius_token_shapes.py` 100% line and branch. The agent contract's 90% new-file figure conflicts with the uniform 85% rule in `.claude/rules/quality-tiers.md`; 85% is applied. |
| **Comprehensive Coverage** | ⚠️ PARTIAL | Seven changed executable PowerShell lines have `ci` 0: three are plan-exempt (dot-source tail call at completion-consistency 484; CR-4 `else` fragments at targets 167 on both surfaces), two are the PA-1 regression, and two (`.codex/...-epic-scope.ps1:206-207`) replace statements that were also `ci` 0 at baseline (Non-blocking finding PA-2). |
| **Positive Flows** - Valid inputs | ✅ PASS | U11b (identifier-embedded names resolve), O-4 benign payload allow, U25 allow outcome, S06 trimming. |
| **Negative Flows** - Invalid inputs | ✅ PASS | U11c env-drive relocation deny, U24 `git-command-word-missing`, M8fe/M8fp `target-record` deny, Kelvin and dotted-capital-I rows expecting `False`. |
| **Edge Cases** - Boundary conditions | ✅ PASS | U11d standalone relocation word (fail-closed residual), S06c composite trims, #845 residual rows, `whitespace-only-stderr` QT009 row. |
| **Error Handling** - Error paths | ✅ PASS | O-4 throwing reader converts to `COMPLETION_CONSISTENCY_BLOCKED` deny. |
| **Concurrency** - If applicable | N/A | No concurrent code paths changed. |
| **State Transitions** - If applicable | N/A | No stateful component changed. |

### 1.2.1 Per-Language Coverage Comparison

- Python: Baseline: 93.8% lines, 88.11% branches -> Post-change: 93.8% lines, 88.11% branches. Change: +0.0% lines, +0.0% branches. New/changed-code coverage: 100% lines and 100% branches for `scripts.dev_tools._blast_radius_token_shapes` (reviewer rerun: 27 statements, 10 branches, 0 missed). Disposition: PASS. Evidence: evidence/baseline/py-coverage-totals.2026-10-13T00-14.md, evidence/qa-gates/py-coverage-totals.2026-10-13T13-47.md, evidence/qa-gates/py-cov-token-shapes.2026-10-13T13-47.md.
- PowerShell: Baseline: 89.52% commands repo-wide -> Post-change: 89.58% commands repo-wide. Change: +0.06% repo-wide; every changed production file at or above 85%; two changed lines regressed from `ci` 1 to `ci` 0. New/changed-code coverage: 95.45% (147 of 154 executable changed lines). Disposition: FAIL. Evidence: evidence/baseline/ps-coverage-baseline.2026-10-13T11-14.md, evidence/qa-gates/ps-coverage.2026-10-13T14-28.md, CI runs 38386628228 and 38410234897 coverage XML.
- TypeScript: Baseline: 97.26% lines, 92.28% branches -> Post-change: 97.26% lines, 92.28% branches. Change: +0.0% lines, +0.0% branches (test-only changes). New/changed-code coverage: N/A, no production TypeScript changed. Disposition: PASS. Evidence: evidence/baseline/ts-jest-coverage.2026-10-13T10-42.md, evidence/qa-gates/ts-jest-coverage.2026-10-13T13-49.md.

### 1.3 Test Structure and Diagnostics

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Clear Failure Messages** | ✅ PASS | #797 CR-4 adds expected/observed messages to bare asserts; Pester rows carry `-Because`; the #793 parametrization adds per-status messages. |
| **Arrange-Act-Assert Pattern** | ✅ PASS | New Pester rows carry `# Arrange`, `# Act`, `# Assert` markers; #846 CR-5 adds the missing `// Assert` marker in the TypeScript quick-pick test. |
| **Document Intent** | ✅ PASS | New test module docstrings state scope and side effects; Pester row titles name the review key. |

### 1.4 External Dependencies and Environment

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Avoid External Dependencies** | ✅ PASS | New tests read committed repository files only; no network or process spawn. |
| **Use Mocks/Stubs** | ✅ PASS | `Read-ClaudeHookRawPayload` mocked; `ReadPayload` and `ReadinessFailure` script blocks injected. |
| **Environment Stability** | ✅ PASS | No temporary files; #846 CR-6 replaces a host-specific workspace path with a neutral `C:\Users\example\...` value. |

### 1.5 Policy Audit Requirement

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Pre-submission Review** | ⚠️ PARTIAL | This audit is the required review. Outstanding: PA-1 (Blocking) and AC-48 pending PR CI. |

---

## 2. General Code Change Policy Compliance

### 2.1 Before Making Changes

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Clarify the objective** | ✅ PASS | `issue.md` Problem/Why and Implementation Intent; three research inputs under `research/`. |
| **Read existing change plans** | ✅ PASS | `evidence/baseline/phase0-instructions-read.2026-10-13T00-08.md`. |
| **Document the plan** | ✅ PASS | `plan.2026-10-11T10-39.md`, preflight clearance recorded. Plan tasks P12-T24 and P12-T28 remain unchecked because their acceptance failed (PA-1). |

### 2.2 Design Principles

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Simplicity first** | ✅ PASS | Minimal guards (`isascii()`, `NonAsciiPattern`, `IndexOf` -1 guard). |
| **Reusability** | ✅ PASS | #732 CR-3 replaces two duplicated epic-scope tails with `Resolve-OrchestrationEpicTargetOutcome`; #845 CR-1 moves finders to `npm_token_guard_test_support.py`. |
| **Extensibility** | ✅ PASS | Readiness predicate injected as a script block; payload reader injectable through `-ReadPayload`. |
| **Separation of concerns** | ✅ PASS | `Resolve-OrchestrationEpicTargetOutcome` is pure (no I/O); the entry-point wrapper isolates the I/O read from the decision. |

### 2.3 Module & File Structure

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Cohesive modules** | ✅ PASS | Changes stay within the existing hook/library boundaries. |
| **Under 500 lines** | ✅ PASS | Reviewer `wc -l` over every changed `.ps1/.psm1/.py/.ts` file: largest are `.claude/hooks/enforce-orchestration-preimplementation-gate-modes.ps1` (496), `.codex/hooks/...-modes.ps1` (493), `.claude/hooks/enforce-completion-consistency.ps1` (488). None exceeds 500. |
| **Public vs internal** | ✅ PASS | Rename `Get-OrchestrationTargetResult` -> `New-OrchestrationTargetResult` updated in all four copies; no residual reference outside `docs/` and the gitignored scratch folder. |
| **No circular dependencies** | ✅ PASS | No new dot-source or import edges beyond existing hook load order. |

### 2.4 Naming, Docs, and Comments

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Descriptive names** | ✅ PASS | `Resolve-OrchestrationEpicTargetOutcome`, `Invoke-CompletionConsistencyEntryPoint`, `OrchestrationTargetRelocationPattern`. |
| **Docs/docstrings** | ✅ PASS | Comment-based help on new functions; Python docstring updated for the ASCII guard. |
| **Comment why, not what** | ✅ PASS | Kelvin-sign rationale in `_blast_radius_token_shapes.py`; relocation-pattern comment cites #732 CR-2. |

### 2.5 After Making Changes - Toolchain Execution

| Requirement | Status | Evidence |
|------------|--------|----------|
| **1. Formatting** | ✅ PASS | **Command:** `poetry run black --check <8 changed .py>` (reviewer rerun: 8 files unchanged); `run_poshqc_format` ok; CI `Format PowerShell` success; `npx prettier --check` pass. |
| **2. Linting** | ✅ PASS | **Command:** `poetry run ruff check <8 changed .py>` (reviewer rerun: All checks passed); CI `PSScriptAnalyzer passed: no findings`; `npx eslint` pass. |
| **3. Type checking** | ✅ PASS | **Command:** `poetry run pyright` (0 errors, evidence/qa-gates/py-pyright.2026-10-13T13-45.md); `npx tsc -p tsconfig.jest.json --noEmit` pass. N/A for PowerShell. |
| **4. Testing** | ✅ PASS | **Command:** `poetry run pytest -q` (7094 passed); CI Pester 10289 passed / 0 failed (Windows), 6212 passed (Linux); Jest 4002 passed. |
| **Full toolchain loop** | ✅ PASS | Two local loop iterations; iteration 2 passed without rewrite (evidence/qa-gates/loop-status.2026-10-13T14-00.md). |
| **Explicit reporting** | ✅ PASS | Every stage has a timestamped evidence artifact. |

### 2.6 Summarize and Document

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Summarize changes** | ✅ PASS | `issue.md` Note Dispositions and Ownership tables. |
| **Design choices explained** | ✅ PASS | Rejected reviewer options recorded (#797 CR-1 option A, #845 CR-1 test-module split). |
| **Update supporting documents** | ✅ PASS | Skills and bundle mirrors updated; byte identity confirmed by reviewer `cmp` over 17 root/mirror pairs. |
| **Provide next steps** | ✅ PASS | Twelve Operator Follow-ups recorded. |

---

## 3. Language-Specific Code Change Policy Compliance

### Section 3A: Python Code Change Policy Compliance

#### 3A.1 Tooling & Baseline

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Formatting with Black** | ✅ PASS | **Command:** `poetry run black --check`<br>**Result:** 8 files would be left unchanged (reviewer rerun). |
| **Linting with Ruff** | ✅ PASS | **Command:** `poetry run ruff check`<br>**Result:** All checks passed (reviewer rerun). |
| **Type checking with Pyright** | ✅ PASS | **Command:** `poetry run pyright`<br>**Result:** 0 errors (executor evidence; CI `quality-checks7` success on 3.10 to 3.13). |
| **Testing with Pytest** | ✅ PASS | **Command:** `poetry run pytest -q`<br>**Result:** 7094 passed, 6 skipped; reviewer targeted rerun 188 passed. |

#### 3A.2 Python Design & Typing

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Strong typing** | ✅ PASS | New test-support module and tests are annotated; no `Any` introduced. |
| **Dataclasses for value objects** | N/A | No value objects introduced. |
| **Protocols/ABCs for interfaces** | N/A | No interfaces introduced. |
| **Avoid utility classes** | ✅ PASS | `npm_token_guard_test_support.py` exposes module-level functions and patterns. |

#### 3A.3 Python Error Handling

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Specific exceptions** | ✅ PASS | No exception handling changed. |
| **Logging over print** | ✅ PASS | No print statements added. |
| **Invariants at construction** | N/A | No constructors changed. |

### Section 3B: PowerShell Code Change Policy Compliance

#### 3B.1 Tooling & Baseline

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Formatting with Invoke-Formatter** | ✅ PASS | **Command:** `run_poshqc_format` (MCP) and CI `Format PowerShell`<br>**Result:** ok; CI step success. |
| **Linting with PSScriptAnalyzer** | ✅ PASS | **Command:** `run_poshqc_analyze` (MCP) and CI `Analyze PowerShell`<br>**Result:** `PSScriptAnalyzer passed: no findings`. |
| **Fix all findings** | ✅ PASS | The `PSUseShouldProcessForStateChangingFunctions` suppression on `New-OrchestrationTargetResult` carries a justification (pure in-memory factory). |
| **PowerShell 5.1 & 7.6+ compatible** | ✅ PASS | No 7-only syntax added to hook code; CI runs on Windows and Linux. |

#### 3B.2 PowerShell Design & Safety

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Advanced functions** | ✅ PASS | New functions use `[CmdletBinding()]` and `[OutputType()]`. |
| **Parameter validation** | ✅ PASS | `Resolve-OrchestrationEpicTargetOutcome` declares both parameters `Mandatory`. |
| **Avoid global state** | ✅ PASS | New script-scope values are constant patterns. |
| **Error handling** | ✅ PASS | `Invoke-CompletionConsistencyEntryPoint` fails closed on any exception and includes the exception message in the deny reason. |

#### 3B.3 Structure, Naming, and Comments

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Cohesive and under 500 lines** | ✅ PASS | Largest changed file 496 lines. |
| **Approved verbs** | ✅ PASS | `New-`, `Resolve-`, `Invoke-`, `Get-`, `Test-`, `Assert-`; analyzer clean. |
| **Comment why** | ✅ PASS | Header comments for #737 F-3/F-6 limits in `EpicStateIsolation.Discovery.Helpers.ps1`. |

#### 3B.4 Running the Toolchain

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Step 1: Format** | ✅ PASS | evidence/qa-gates/ps-format.2026-10-13T13-49.md; CI success. |
| **Step 2: Analyze** | ✅ PASS | evidence/qa-gates/ps-analyze.2026-10-13T13-50.md; CI success. |
| **Step 3: Type check** | N/A | Not applicable for PowerShell. |
| **Step 4: Test** | ✅ PASS | CI run 38410234897: 10289 passed, 0 failed; Linux hook suites 6212 passed. |
| **Rerun loop if needed** | ✅ PASS | Two iterations; F-1/F-2 withheld between them. |

### Section 3E: TypeScript (test-only)

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Prettier / ESLint / tsc / Jest** | ✅ PASS | evidence/qa-gates/ts-prettier-check.2026-10-13T13-48.md, ts-eslint.2026-10-13T13-48.md, ts-tsc-jest.2026-10-13T13-48.md, ts-jest-coverage.2026-10-13T13-49.md; CI extension tests success on Windows and Ubuntu. |

---

## 4. Language-Specific Unit Test Policy Compliance

### Section 4A: Python Unit Test Policy Compliance

#### 4A.1 Framework and Scope

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Use Pytest** | ✅ PASS | Parametrized `pytest.param` rows with ids. |
| **Coverage expectation** | ✅ PASS | Repo-wide 93.8% line / 88.11% branch; changed production module 100% / 100%. |

#### 4A.2 Test Style and Structure

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Focused unit tests** | ✅ PASS | One assertion target per parametrized node. |
| **Mocking sparingly** | ✅ PASS | No new mocks in Python tests. |
| **Organization** | ✅ PASS | Tests under `tests/scripts/dev_tools/` mirror `scripts/dev_tools/`. |

#### 4A.3 Naming and Readability

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Naming conventions** | ✅ PASS | `test_evidence_skill_requires_write_time_filename_stamp`, `test_find_npm_token_assignments_pins_documented_residuals`. |
| **Docstrings/comments** | ✅ PASS | Module and test docstrings cite the #845 spec sections. |

#### 4A.4 Running the Toolchain

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Use Pytest** | ✅ PASS | **Command:** `poetry run pytest -q`<br>**Result:** 7094 passed. |
| **No Alternative Test Runners** | ✅ PASS | Pytest only. |

### Section 4B: PowerShell Unit Test Policy Compliance

#### 4B.1 Framework and Scope

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Use Pester v5.x** | ✅ PASS | `-ForEach` data rows, `BeforeAll`, `Should -Invoke`, `Mock`. |
| **Use PoshQC Configuration** | ✅ PASS | **Command:** `run_poshqc_test` (MCP) and CI `Test PowerShell`<br>**Config:** `scripts/powershell/PoshQC/settings/pester.runsettings.psd1` (unchanged). |
| **PowerShell 5.1 & 7.6+ Compatible** | ✅ PASS | Suites carry `#Requires -Version 7.0` where pre-existing; hook code is unchanged in compatibility profile. |

#### 4B.2 Test Style and Structure

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Focused Unit Tests** | ✅ PASS | One outcome per U25 row; one predicate per M8f row. |
| **Test Behavior Over Implementation** | ✅ PASS | Rows assert decisions and exact reason strings. |
| **Mocking Used Sparingly** | ✅ PASS | Only `Read-ClaudeHookRawPayload` is mocked in new rows. |
| **Organization** | ✅ PASS | **Test file:** `tests/scripts/claude-hooks/*.Tests.ps1`, `tests/scripts/codex-hooks/*.Tests.ps1`<br>**Code file:** `.claude/hooks/*.ps1`, `.codex/hooks/*.ps1`<br>Existing mirrored layout retained. |

#### 4B.3 Naming and Readability

| Requirement | Status | Evidence |
|------------|--------|----------|
| **File Naming** - *.Tests.ps1 | ✅ PASS | No new Pester files; edited files keep `.Tests.ps1` / `.Helpers.ps1`. |
| **Describe/Context/It Structure** | ✅ PASS | New rows added inside existing Describe/Context blocks. |
| **Logical Grouping** | ✅ PASS | U-rows grouped by rule; O-4 rows under `Entrypoint transport`. |
| **Docstrings/Comments** | ✅ PASS | Row titles self-describing. |

#### 4B.4 Running the Toolchain

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Use PoshQCTest Command** | ✅ PASS | **Command:** `run_poshqc_test`<br>**Result:** ok; per-row results read from CI junit (evidence/qa-gates/ps-rows.2026-10-13T14-25.md). |
| **No Alternative Test Runners** | ✅ PASS | Pester through PoshQC only. |

---

## 5. Test Coverage Detail

### `.codex/hooks/enforce-orchestration-preimplementation-gate-targets.ps1` (surface-parameterized targets suite)

| Test Name | Scenario Type | Lines Covered | Status |
|-----------|--------------|---------------|--------|
| U25 `a deny verdict` (target-mixed) | Negative | 360 | ✅ |
| U25 `a failing non-session-root target` (target-not-ready) | Negative | 364 | ✅ |
| (no row) target-ambiguous reason | Negative | 356 | ❌ |
| (no row) unresolvable fall-through reason | Negative | 370 | ❌ |

**Coverage:** 98.16% of file (160 covered, 3 missed); baseline 100.0%.

**Not covered:** lines 356 and 370 (PA-1, regression from baseline `ci` 1); line 167 (`else { $value = '' }` fragment isolated by the CR-4 wrap, plan-exempt rule (c)).

### `.codex/hooks/enforce-orchestration-preimplementation-gate-epic-scope.ps1`

| Test Name | Scenario Type | Lines Covered | Status |
|-----------|--------------|---------------|--------|
| Codex epic-scope rows reaching `Resolve-OrchestrationEpicTargetOutcome` | Positive | 196-204 | ✅ |
| (no attributed row) deny outcome return | Negative | 206-207 | ❌ |

**Coverage:** 89.09% (baseline 78.33%).

**Not covered:** lines 206-207. The replaced baseline statements were also `ci` 0, so this is not a regression (PA-2, Non-blocking). The Codex suite `enforce-orchestration-preimplementation-gate-epic-scope-targets.Tests.ps1` runs in the Windows coverage job and asserts deny decisions through this path in-process, yet the XML attributes no hits to these lines; the attribution cause was not determined.

### `scripts/dev_tools/_blast_radius_token_shapes.py`

| Test Name | Scenario Type | Lines Covered | Status |
|-----------|--------------|---------------|--------|
| `kelvin-sign-extension` | Edge Case | ASCII guard | ✅ |
| `dotted-capital-i-extension` | Edge Case | ASCII guard | ✅ |

**Coverage:** 100% lines, 100% branches (reviewer rerun).

**Not covered:** None.

---

## 6. Test Execution Metrics

| Metric | Value | Status |
|--------|-------|--------|
| Total Tests | Pester 10299 (Windows) + 6212 (Linux); pytest 7100; Jest 4002 | ✅ |
| Tests Passed | Pester 10289 + 6212; pytest 7094; Jest 4002 | ✅ |
| Tests Failed | 0 | ✅ |
| Execution Time | Python full suite 88.55s | ✅ Fast |
| Average Time per Test | Python about 12ms | ✅ Fast |
| Discovery Time | Not separately reported | N/A |
| Functions/Classes Tested | All new functions have direct rows (`Resolve-OrchestrationEpicTargetOutcome`, `Invoke-CompletionConsistencyEntryPoint`, `New-OrchestrationTargetResult`) | ✅ |
| Test File Size | All under 500 lines | ✅ |
| Code Coverage (if applicable) | Python 93.8% lines, 88.11% branches; PowerShell 89.58% commands; TypeScript 97.26% lines, 92.28% branches | ✅ |

---

## 7. Code Quality Checks

**For Python:**

| Check | Command | Result | Status |
|-------|---------|--------|--------|
| Black Formatting | `poetry run black --check <changed>` | 8 files unchanged | ✅ |
| Ruff Linting | `poetry run ruff check <changed>` | All checks passed | ✅ |
| Pyright Type Checking | `poetry run pyright` | 0 errors | ✅ |
| Pytest Tests | `poetry run pytest -q` | 7094 passed | ✅ |

**For PowerShell:**

| Check | Command | Result | Status |
|-------|---------|--------|--------|
| Invoke-Formatter | `run_poshqc_format` / CI | ok / success | ✅ |
| PSScriptAnalyzer | `run_poshqc_analyze` / CI | no findings | ✅ |
| Pester Tests | `run_poshqc_test` / CI | 10289 passed, 0 failed | ✅ |

**Notes:**
CI run 38410234897 is a `workflow_dispatch` run, not a PR CI run; AC-48 names PR CI artifacts and remains pending.

---

## 8. Gaps and Exceptions

### Identified Gaps

- **PA-1 (Blocking):** Changed-line coverage regression. `.codex/hooks/enforce-orchestration-preimplementation-gate-targets.ps1:356` (target-ambiguous reason) and `:370` (unresolvable fall-through reason) are CR-4 wraps of statements with baseline `ci` 1 and now have `ci` 0. Violates "no regression on changed lines" (`.claude/rules/quality-tiers.md`) and `.claude/rules/general-unit-test.md`. Remediation: add surface-parameterized rows to `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-targets.Tests.ps1` (for example extend U25 or add a row) that assert the exact `Get-OrchestrationEpicTargetDenyReason` text for `target-ambiguous` and for an unrecognized code (fall-through). The existing Codex-surface leg of that suite already attributes hits to the Codex copy (lines 360 and 364 are covered that way). Re-run CI and re-read the coverage XML.
- **PA-2 (Non-blocking):** `.codex/hooks/enforce-orchestration-preimplementation-gate-epic-scope.ps1:206-207` uncovered. Not a regression (replaced statements at baseline lines 202-217 were `ci` 0; file rose from 78.33% to 89.09%). The plan's own P12-T24 rule classifies it as blocking; repository policy does not. Recommended: cover in the same remediation or record a plan exemption, and record the coverage-attribution anomaly as a follow-up.
- **PA-3 (Non-blocking):** Per-file percentage decreases on Claude targets (100.0 -> 99.39, plan-exempt line 167) and Claude epic-scope (98.63 -> 98.53, denominator change; the one missed line is pre-existing). No changed-line regression in these files.
- **PA-4 (Non-blocking):** AC-48 pending PR CI; no PR exists.
- **PA-5 (Non-blocking):** Agent-contract threshold text (90% new-file / 80% repo-wide) conflicts with the uniform 85% / 75% rule; the uniform rule is applied.

### Approved Exceptions

- Plan exemptions (a) and (c) for `.claude/hooks/enforce-completion-consistency.ps1:484` and targets line 167 on both surfaces are measurement-granularity cases and are accepted by this reviewer as Non-blocking.

### Removed/Skipped Tests

1. **#737 F-1/F-2 rows in `enforce-gate-suites.EpicStateIsolation.Branches.Tests.ps1`** - Removed by restore in commit `4e8d9f92d`
   - **Reason:** The full-population Discovery guard flagged seven suites with F-2 applied (CI run 38404520141).
   - **Impact:** F-1/F-2 predicate changes are not delivered.
   - **Justification:** AC-34/AC-35 withhold branch; recorded in Note Dispositions and Operator Follow-up 10.

---

## 9. Summary of Changes

### Commits in This PR/Branch

1. **096b5a4ed** - docs(903): scaffold active feature folder
2. **bf1323e11** - docs(903): add P7 and P8 research
3. **f57b00961** - docs(903): author issue.md acceptance criteria and note dispositions
4. **7df536f07 / 3593e7d16 / 90e62f22a / b71e5fb3c** - plan, preflight revisions, preflight clearance
5. **606c1d517** - merge `origin/main`
6. **320cb5ddf / 95d6c9b22 / 72d651f74** - Phase 0 and CI baseline evidence
7. **c739dcdf4 / d8582add1** - P7 fail-first contract tests and UTC evidence-timestamp skill edits
8. **1dd5991ad / 4d203c6bf** - P8 Python and TypeScript review notes, #846 CR-7 correction note
9. **ae0204c6e / bc9cd0c2c** - P8 PowerShell fail-first rows and CI evidence
10. **6a80c4263** - #797 CR-1, #565 CR-8 and CR-2, #736 O-4
11. **528c0906b** - #732 CR-2, CR-4, CR-5, CR-6, CR-9
12. **c2fd0b62f / c307b276a** - #732 CR-3 shared epic-target outcome and evidence
13. **523d1123c / 92e85dd74** - #737 F-1/F-2 predicate and test-support notes
14. **a25519222** - final QC loop evidence (iteration 1)
15. **4e8d9f92d** - revert: withhold #737 F-1 and F-2
16. **17a6497e4 / f140a589e / fcd493fa1** - final QC loop evidence, final CI evidence, dispositions and AC status

### Files Modified

1. **`.claude/hooks/enforce-orchestration-preimplementation-gate-targets.ps1`** (+ `.codex` copy + 2 mirrors) (MODIFIED)
   - #732 CR-2 identifier-boundary relocation regex, CR-4 120-column wraps, CR-5 rename, CR-6 `git` index guard, CR-3 `Resolve-OrchestrationEpicTargetOutcome`.
2. **`.claude/hooks/enforce-orchestration-preimplementation-gate-epic-scope.ps1`** (+ `.codex` copy + 2 mirrors) (MODIFIED)
   - Tail delegates to the shared outcome function.
3. **`.claude/hooks/enforce-orchestration-preimplementation-gate-modes.ps1`** (+ `.codex` copy + 2 mirrors) (MODIFIED)
   - #565 CR-8 keyed-only issue lookup when a cited folder matches no record.
4. **`.claude/hooks/feature-folder-resolution.ps1`** (+ `.codex` copy + 2 mirrors) (MODIFIED)
   - #565 CR-2 extended trim set.
5. **`.claude/hooks/enforce-completion-consistency.ps1`** (+ mirror) (MODIFIED)
   - #736 O-4 fail-closed entry point.
6. **`.claude/lib/blast-radius/BlastRadiusTokenShape.psm1`** (+ mirror) and **`scripts/dev_tools/_blast_radius_token_shapes.py`** (MODIFIED)
   - #797 CR-1 non-ASCII extension rejection.
7. **Skills** (MODIFIED): six `evidence-and-timestamp-conventions`, six `atomic-plan-contract`, `.agents/skills/epic-plan/SKILL.md` + mirror.
8. **Tests** (NEW: `test_evidence_timestamp_contracts.py`, `npm_token_guard_test_support.py`; MODIFIED: 20 other test files).

---

## 10. Compliance Verdict

### Overall Status: ⚠️ PARTIALLY COMPLIANT

All toolchain stages pass, file-size, rules-folder, mirror-parity, and evidence-location checks pass, and per-file coverage is at or above 85% for every changed production file. One blocking violation remains: the changed-line coverage regression on two lines of the Codex targets copy (PA-1).

**Total blocking findings: 1.**

---

### Policy-by-Policy Summary

#### General Code Change Policy (Section 2)
- ✅ Before Making Changes: plan and research present
- ✅ Design Principles: shared outcome function, injected seams
- ✅ Module & File Structure: all files at or under 500 lines
- ✅ Naming, Docs, Comments: compliant
- ✅ Toolchain Execution: all stages pass
- ✅ Summarize & Document: dispositions and follow-ups recorded

#### Language-Specific Code Change Policy (Section 3)

**For Python:**
- ✅ Tooling & Baseline: black, ruff, pyright, pytest pass
- ✅ Python Design & Typing: compliant
- ✅ Error Handling: no change

**For PowerShell:**
- ✅ Tooling & Baseline: format and analyze pass
- ✅ PowerShell Design & Safety: compliant
- ✅ Structure & Naming: compliant
- ✅ Toolchain: CI Pester pass

#### General Unit Test Policy (Section 1)
- ✅ Core Principles: compliant
- ❌ Coverage & Scenarios: changed-line regression (PA-1)
- ✅ Test Structure: compliant
- ✅ External Dependencies: compliant
- ⚠️ Policy Audit: PA-1 open

#### Language-Specific Unit Test Policy (Section 4)

**For Python:**
- ✅ Framework & Scope: compliant
- ✅ Test Style & Structure: compliant
- ✅ Naming & Readability: compliant
- ✅ Toolchain: compliant

**For PowerShell:**
- ✅ Framework & Scope: compliant
- ✅ Test Style & Structure: compliant
- ✅ Naming & Readability: compliant
- ❌ Toolchain: coverage gate on changed lines not met (PA-1)

---

### Metrics Summary

- ✅ Pester 10289/10289 non-skipped passing (Windows), 6212/6212 (Linux)
- ✅ pytest 7094 passed, 0 failed
- ✅ Jest 4002 passed
- ✅ Python 93.8% line / 88.11% branch; PowerShell 89.58% commands; TypeScript 97.26% / 92.28%
- ❌ PowerShell changed-line regression: 2 lines (Codex targets 356, 370)
- ✅ All code quality checks passing

---

### Recommendation

**Needs revision**

Address PA-1 by adding surface-parameterized deny-reason rows for `target-ambiguous` and the unresolvable fall-through, re-run CI, and re-read per-line coverage. Optionally address PA-2 in the same change. Then open the PR and check off AC-48 from PR CI artifacts.

---

## Appendix A: Test Inventory

### Complete Test List (new or changed rows)

1. preimplementation gate targets (<Surface>) › U11b, U11c, U11d, U24, U25 (both surfaces)
2. surface parity › keeps every line of every surface copy at or under 120 characters
3. TargetFolder (Claude, Codex) › M8fe, M8fp
4. feature-folder-resolution (Claude, Codex) › S06 (9 characters), S06c composites
5. enforce-completion-consistency.ps1 payload envelope › Entrypoint transport › three O-4 rows
6. BlastRadiusTokenShape › Predicate cases › kelvin-sign-extension, dotted-capital-i-extension
7. CodexDeployment.GeneratedFamilies.Parity › Assert-FamilySetEqual equality and divergent rows
8. codex-pretooluse-integration › DEV-2 admitted tool names
9. codex-epic-runtime-contracts › one-paragraph multi-message form
10. PublishMcpNpmWorkflow › Get-BraceBlockText block checks, consolidated `exit 1`, inline `if:`

- `tests/scripts/dev_tools/test_evidence_timestamp_contracts.py` (five tests)
- `tests/scripts/dev_tools/test_blast_radius_token_shapes.py::FILE_SHAPE_CASES` (two new rows)
- `tests/scripts/dev_tools/test_workflow_npm_token_guard.py::test_find_npm_token_assignments_pins_documented_residuals`
- `tests/scripts/dev_tools/test_check_quality_tiers.py::test_main_returns_one_with_qt009_when_git_exits_nonzero[empty-stderr|whitespace-only-stderr]`
- `tests/scripts/dev_tools/test_validate_epic_orchestrator_state_merge_status.py` (parametrized status rows, `NON_STRING_ROWS`)

---

## Appendix B: Toolchain Commands Reference

**For Python:**
```bash
poetry run black --check <changed .py files>
poetry run ruff check <changed .py files>
poetry run pyright
poetry run pytest -q
poetry run pytest <targeted modules> --cov=scripts.dev_tools._blast_radius_token_shapes --cov-branch --cov-report=term-missing
poetry run python scripts/dev_tools/validate_evidence_locations.py --root .
```

**For PowerShell:**
```powershell
# Through the PoshQC MCP tools: run_poshqc_format, run_poshqc_analyze, run_poshqc_test
# CI: ci.yml poshqc job (run 38410234897); coverage XML read with awk per line
```

---

**Audit Completed By:** feature-review agent
**Audit Date:** 2026-10-13
**Policy Version:** Current (as of audit date)
