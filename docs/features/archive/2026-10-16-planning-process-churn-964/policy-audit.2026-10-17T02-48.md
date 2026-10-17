# Policy Compliance Audit: Planning-Process Churn (#964)

---

**Audit Date:** 2026-10-17
**Code Under Test:** full branch diff `bug/planning-process-churn-964` against the merge base of `origin/main` and `HEAD` (merge base equals the `origin/main` tip, `b8fcd7790`; head `1f017bd4b`). 260 added or modified files: 171 Markdown, 44 generated Codex TOML plus 4 hand-edited Codex base TOML, 13 Python (4 production, 9 test), 11 TypeScript/CommonJS (3 production, `jest.config.cjs`, 7 test), 15 PowerShell (4 canonical hooks, 4 bundle copies, 7 Pester suites), 2 JSON pack manifests. Production code files: `scripts/dev_tools/plan_gate_document.py` (new), `scripts/dev_tools/plan_gate_discrimination.py`, `scripts/dev_tools/generate_codex_agent_variants.py`, `scripts/dev_tools/codex_native_converter/rewrites.py`, `extensions/drm-copilot/src/lib/validate/plan-gate-document.ts` (new), `extensions/drm-copilot/src/lib/validate/plan-gate-discrimination.ts`, `extensions/drm-copilot/src/lib/codex-native-converter/rewrites-rules.ts`, `extensions/drm-copilot/jest.config.cjs`, `.claude/hooks/premortem-section.ps1` (new), `.claude/hooks/validate-planner-output.ps1`, `.claude/hooks/validate-task-researcher-output.ps1`, `.claude/hooks/validate-executor-output.ps1`, and their bundle copies.

**Coverage Metrics by Language:**

| Language | Files Changed | Tests | Test Result | Baseline Coverage | Post-Change Coverage | New Code Coverage |
|----------|--------------|-------|-------------|-------------------|---------------------|-------------------|
| Python | 13 files (4 production, 9 test) | 7325 tests | ✅ 7325 pass, 0 fail, 6 skipped | 94.04% lines, 88.65% branches | 94.11% lines, 88.78% branches | 100.00% lines, 100.00% branches (`plan_gate_document.py`) |
| TypeScript | 11 files (3 production + `jest.config.cjs`, 7 test) | 4103 tests | ✅ 4103 pass, 0 fail | 97.39% lines, 92.63% branches | 97.41% lines, 92.66% branches | 100.00% lines, 95.08% branches (`plan-gate-document.ts`) |
| PowerShell | 15 files (4 hooks, 4 bundle copies, 7 test suites) | 11055 tests | ✅ 11045 pass, 0 fail, 10 skipped | 92.09% lines | 92.23% lines | 100.00% lines (`premortem-section.ps1`) |
| JSON | 2 files | N/A | ✅ pack-manifest completeness tests pass | N/A (config files) | N/A (config files) | N/A |

Bash: no `.sh` file changed on the branch (N/A). C#: no `.cs` file changed (N/A). TOML and Markdown carry no coverage language.

### Coverage Evidence Checklist

- TypeScript baseline coverage artifact: `docs/features/active/2026-10-16-planning-process-churn-964/evidence/baseline/ts-tests.2026-10-16T23-25.md` (97.39% lines, 92.63% branches)
- TypeScript post-change coverage artifact: `extensions/drm-copilot/coverage/lcov.info` (re-parsed by this review: 97.41% lines, 92.66% branches) and `evidence/qa-gates/toolchain-rerun.2026-10-17T02-28.md`
- PowerShell baseline coverage artifact: `artifacts/pester/powershell-coverage-964-baseline.xml` and `evidence/baseline/ps-tests.2026-10-16T23-48.md` (92.09% lines)
- PowerShell post-change coverage artifact: `artifacts/pester/powershell-coverage.xml` (re-parsed by this review: 92.23% lines) and `evidence/qa-gates/ps-tests.2026-10-17T02-04.md`
- Per-language comparison summary: section 1.2.1 below and `evidence/qa-gates/coverage-delta.2026-10-17T02-04.md`

Python coverage artifacts: baseline `artifacts/python/coverage-964-baseline.json` (94.04% lines, 88.65% branches); post-change `artifacts/python/coverage-964-qa.json` and `artifacts/python/lcov.info` (94.11% lines, 88.78% branches), re-parsed by this review.

---

## Executive Summary

This audit covers the full branch diff from the merge base. The branch adds an execution-environment brief (six byte-identical copies), validator rules G11 to G13 in Python and TypeScript, a shared Pre-Mortem helper for the planner and researcher SubagentStop hooks, transcript-based preflight detection and single-pass preflight rules in the executor hook, and contract text for single-pass preflight, the design-level plan contract, and proportionate remediation across the Claude, Codex (`.agents`, `.codex`) and Copilot (`.github`) surfaces and their bundle copies.

**Policy documents evaluated:**
- ✅ `general-code-change.instructions.md` (via `.claude/rules/general-code-change.md`)
- ✅ `general-unit-test.instructions.md` (via `.claude/rules/general-unit-test.md`)
- ✅ `.claude/rules/quality-tiers.md` (tiers adopted; `quality-tiers.yml` present)
- ✅ `.claude/rules/tonality.md`
- ✅ `.claude/rules/plan-acceptance-gates.md`

**Language-specific policies evaluated:**
- ✅ `python-code-change.instructions.md` + `python-unit-test.instructions.md` (`.claude/rules/python.md`, `python-suppressions.md`)
- ✅ `powershell-code-change.instructions.md` + `powershell-unit-test.instructions.md` (`.claude/rules/powershell.md`)
- ✅ TypeScript (`.claude/rules/typescript.md`, `typescript-suppressions.md`)
- N/A Bash: no shell file changed
- ✅ JSON: two pack manifests, covered by the pack-manifest completeness tests

Toolchain evidence: format, lint, type-check, unit, contract and integration stages recorded under `evidence/qa-gates/` with a single-pass re-run in `toolchain-rerun.2026-10-17T02-28.md`. This review independently re-ran, at head `1f017bd4b`: the Codex generator `--check` (exit 0), 275 Python contract and new-module tests plus 5 pack-manifest and preload tests (all pass), the three new or changed Jest suites (36 tests pass), the tier-classification check (OK, 24 entries), the Python coverage-threshold check against the QA JSON report (exit 0), the branch-current plan validator on the plan (exit 0), the evidence-location validator (exit 0), and a byte-parity check of 82 canonical-to-bundle pairs (0 differences). Pester could not be run from this review agent (the worktree isolation guard refuses `pwsh` command text and no PoshQC tool is available here); PowerShell results are taken from `artifacts/pester/pester-junit.xml` and `artifacts/pester/powershell-coverage.xml`, both written after the last commit touching `.claude/hooks/` or `tests/scripts/claude-hooks/`.

Coverage verdicts: Python PASS, TypeScript PASS, PowerShell PASS. No blocking policy finding. Seven non-blocking findings are recorded in section 8 and in the code review.

**Temporary artifacts cleanup:**
- ✅ All temporary/one-time scripts created during development have been deleted or kept outside the repository (helpers live under the session scratch directory, recorded as the token `SCRATCH`)
- ✅ Any ongoing tooling scripts are fully tested and compliant with repo policies (no new repository script other than `plan_gate_document.py`, which has 100% line and branch coverage)
- No throwaway script is committed; `git status` shows only the orchestrator-owned untracked `evidence/other/replan-962/` folder.

## Rejected Scope Narrowing

None detected. The caller instruction to classify AC-33 (orchestrator-owned #962 re-plan) and AC-34 (CI on the final PR head) as pending rather than FAIL concerns acceptance-criterion ownership, which the acceptance-criteria-tracking skill defines for CI-dependent and orchestrator-owned criteria; it does not narrow the audited diff or exempt any language or toolchain stage. The audit scope is the full branch diff from the merge base.

## Evidence Location Compliance

- `poetry run python -m scripts.dev_tools.validate_evidence_locations --root .` exited 0 with no reported path.
- The branch diff contains no file under `artifacts/baselines/`, `artifacts/qa/`, `artifacts/evidence/`, or `artifacts/coverage/`. All 61 evidence files are under `docs/features/active/2026-10-16-planning-process-churn-964/evidence/{baseline,qa-gates,regression-testing,other}/`.
- No `EVIDENCE_LOCATION_OVERRIDE_REJECTED` event occurred in this review.
- No evidence artifact records an absolute path, a host name, or a scratchpad path (scanned by this review).

---

## 1. General Unit Test Policy Compliance

### 1.1 Core Principles

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Independence** - Tests run in any order | ✅ PASS | Seeded randomized Jest (seeds 964964, 20261016, 31337) 4103/4103 each; reversed-order Python run of the nine new or changed modules 88 passed; seeded shuffled Pester file order (seeds 964, 20261016, 31337) 897 passed each; fresh single-process Pester over `tests/scripts` 11055 tests, 0 failures (`evidence/regression-testing/isolation-final.2026-10-17T02-04.md`). An order dependence found in `extension.test.ts` was fixed on both the leaker side (`jest.isolateModulesAsync` with `mockPosixPathResolve`) and the victim side (`extension-test-harness.ts` keeps the primary module). |
| **Isolation** - Each test targets single behavior | ✅ PASS | `test_plan_gate_document.py` and `plan-gate-document.test.ts` carry one case per rule form; `premortem-section.Tests.ps1` has one `It` per label; `validate-executor-output.Preflight.Tests.ps1` has one `It` per rule and fallback. |
| **Fast Execution** - Tests complete quickly | ✅ PASS | This review's run of 275 Python contract and new-module tests took 1.57 s; the three Jest suites 0.58 s. |
| **Determinism** - Consistent results | ✅ PASS | No clock, randomness, or network in the new tests; transcript text is injected through the `ReadTranscriptHead` seam; fix-record existence through a `Test-PreflightFixRecord` mock. |
| **Readability & Maintainability** - Clear structure | ✅ PASS | Behavior-named tests with Arrange/Act/Assert comments and docstrings; TypeScript `it` titles equal the Python test names. |

### 1.2 Coverage and Scenarios

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Baseline Coverage Documented** | ✅ PASS | **Baseline:** Python 94.04% lines / 88.65% branches; TypeScript 97.39% / 92.63%; PowerShell 92.09% lines.<br>**Artifacts:** `evidence/baseline/python-tests.2026-10-16T23-25.md`, `ts-tests.2026-10-16T23-25.md`, `ps-tests.2026-10-16T23-48.md`, written before production edits. |
| **No Coverage Regression** | ✅ PASS | Python 94.11% / 88.78% (+0.07 / +0.13); TypeScript 97.41% / 92.66% (+0.02 / +0.03); PowerShell 92.23% (+0.14). Every modified production file is at or above its baseline (section 1.2.1). |
| **New Code Coverage at or above the governing thresholds** | ✅ PASS | Root `CLAUDE.md` states no coverage threshold, so the defaults govern (85% line, 75% branch for Python and TypeScript; 85% line for PowerShell). `plan_gate_document.py` 100.00% / 100.00% (156 statements); `plan-gate-document.ts` 100.00% / 95.08%; `premortem-section.ps1` 100.00% (45/45 lines). |
| **Comprehensive Coverage** | ✅ PASS | All public functions of `plan_gate_document.py` (`unfenced_lines`, `line_citations`, `sha_citations`, `has_size_justification`, `plan_size`, three message builders, `evaluate_document_gates`) are exercised; the four Pre-Mortem helper functions and the executor-hook helpers (`Get-JsonPropertyValue`, `Get-TranscriptPathFromEnvelope`, `Get-TranscriptFirstUserText`, `Test-IsPreflightRun`, `Test-PreflightFixRecord`, `Get-PreflightRunBlockDecision`) have direct tests. Remaining uncovered lines in changed production files are pre-existing and outside the changed hunks (planner hook one line, researcher hook two lines). |
| **Positive Flows** - Valid inputs | ✅ PASS | Plans at both G13 guidelines; non-empty size justification; valid Pre-Mortem sections (including case-insensitive labels and "not applicable" with a reason); `PREFLIGHT: ALL CLEAR` with an existing fix record; combined-run preflight block with no checked task. |
| **Negative Flows** - Invalid inputs | ✅ PASS | Line, path and anchor citations; full and abbreviated SHAs; oversized plans; missing heading and each missing label; line-reference `CITATION:` locators; zero or two preflight signals; `ALL CLEAR` with a defect line; `REVISIONS REQUIRED` without one; fix line without an existing record. |
| **Edge Cases** - Boundary conditions | ✅ PASS | Exactly 40 tasks and 400 lines; empty justification; fenced blocks; UUID segments; SHA-256 digests; `-`/`_`-joined suffixes; URL with a port; lowercase "blocked" prose; tilde expansion of the transcript path. |
| **Error Handling** - Error paths | ✅ PASS | Absent, unparseable, throwing, and empty transcript readers fall back to the plan-file or single-signal check; guarded dependency load covered by `hook-dependency-guard-completeness.Tests.ps1` (598 tests, 0 failures). |
| **Concurrency** - If applicable | N/A | Validators and hooks are single-invocation and hold no shared state. |
| **State Transitions** - If applicable | ✅ PASS | Preflight versus execution classification, and the combined-run BLOCKED allowance before and after a task is checked, are each tested on both sides. |

### 1.2.1 Per-Language Coverage Comparison

- Python: Baseline: 94.04% lines, 88.65% branches -> Post-change: 94.11% lines, 88.78% branches. Change: +0.07% lines, +0.13% branches. New/changed-code coverage: 100.00% lines and 100.00% branches for `plan_gate_document.py`; `plan_gate_discrimination.py` 99.26% / 98.08% (baseline 99.25% / 98.08%); `generate_codex_agent_variants.py` 94.53% / 89.13% (baseline 90.62% / 82.61%); `codex_native_converter/rewrites.py` 91.30% / 85.71% (unchanged). Disposition: PASS. Evidence: `artifacts/python/coverage-964-qa.json`, `artifacts/python/coverage-964-baseline.json`, `evidence/qa-gates/coverage-delta.2026-10-17T02-04.md`.
- TypeScript: Baseline: 97.39% lines, 92.63% branches -> Post-change: 97.41% lines, 92.66% branches. Change: +0.02% lines, +0.03% branches. New/changed-code coverage: 100.00% lines and 95.08% branches for `plan-gate-document.ts`; `plan-gate-discrimination.ts` 100.00% / 98.28%; `rewrites-rules.ts` 100.00% / 100.00%. Disposition: PASS. Evidence: `extensions/drm-copilot/coverage/lcov.info`, `evidence/baseline/ts-tests.2026-10-16T23-25.md`, `evidence/qa-gates/coverage-delta.2026-10-17T02-04.md`.
- PowerShell: Baseline: 92.09% lines -> Post-change: 92.23% lines. Change: +0.14% lines. New/changed-code coverage: 100.00% lines for `premortem-section.ps1` and `validate-executor-output.ps1` (baseline 98.33%), 99.52% for `validate-planner-output.ps1` (baseline 99.50%), 98.17% for `validate-task-researcher-output.ps1` (baseline 97.09%); no branch figure applies to Pester. Disposition: PASS. Evidence: `artifacts/pester/powershell-coverage.xml`, `artifacts/pester/powershell-coverage-964-baseline.xml`, `evidence/qa-gates/ps-tests.2026-10-17T02-04.md`.

### 1.3 Test Structure and Diagnostics

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Clear Failure Messages** | ✅ PASS | Python assertions carry f-string messages naming the observed findings; contract tests report missing tokens per path. |
| **Arrange-Act-Assert Pattern** | ✅ PASS | Marked with comments in every new Python and TypeScript test; Pester `It` blocks follow the same order. One parity test loops five rows inside one test (code-review finding CR-6). |
| **Document Intent** | ✅ PASS | Module and test docstrings state scenario and expected outcome. |

### 1.4 External Dependencies and Environment

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Avoid External Dependencies** | ✅ PASS | No network, database, or process dependency. Contract tests read committed repository files only. |
| **Use Mocks/Stubs** | ✅ PASS | Pester mocks only the plan-content, research-content, fix-record and `Test-Path` seams; the generator write-mode test replaces `_write_text_preserving_newlines` with an in-memory recorder. |
| **Environment Stability** | ✅ PASS | A scan of every new or changed test for `tmp_path`, `TemporaryDirectory`, `mkdtemp`, `New-TemporaryFile`, `TestDrive`, `GetTempPath`, `os.tmpdir`, `writeFileSync`, `Set-Content`, and `Out-File` found no match. No test reads gitignored `artifacts/` state or diffs against `origin/main`. |

### 1.5 Policy Audit Requirement

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Pre-submission Review** | ✅ PASS | This audit is the feature-review policy audit; the executor's self-review is `evidence/qa-gates/self-review.2026-10-17T02-30.md` (no FAIL row). |

---

## 2. General Code Change Policy Compliance

### 2.1 Before Making Changes

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Clarify the objective** | ✅ PASS | Issue #964; `spec.md` Root Cause and Design sections. |
| **Read existing change plans** | ✅ PASS | `evidence/baseline/phase0-instructions-read.2026-10-16T23-19.md`; research `research/research.2026-10-16T22-36.md`. |
| **Document the plan** | ✅ PASS | `plan.2026-10-16T18-10.md` (all executor tasks checked; passes the branch-current validator with no G11 to G13 finding). |

### 2.2 Design Principles

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Simplicity first** | ✅ PASS | G11 to G13 are three small predicates over unfenced lines; regexes avoid lookbehind so both runtimes agree. |
| **Reusability** | ✅ PASS | One Pre-Mortem helper is dot-sourced by two hooks; the new validator modules reuse `split_plan_lines`/`splitPlanLines`, `PLAN_WHITESPACE_CLASS`, and the G10 fence pattern. |
| **Extensibility** | ✅ PASS | Severities are single constants per runtime; guideline numbers are named constants. |
| **Separation of concerns** | ✅ PASS | Validator modules are pure; hook file and transcript reads sit behind seams (`Get-ResearchFileContent`, `ReadTranscriptHead`, `Test-PreflightFixRecord`). |

### 2.3 Module & File Structure

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Cohesive modules** | ✅ PASS | New logic is in new modules (`plan_gate_document.py`, `plan-gate-document.ts`, `premortem-section.ps1`); near-limit files gained only call sites. |
| **Under 500 lines** | ✅ PASS | Largest changed non-Markdown files: `repo-automation-dispatch.test.ts` 500 (trailing newline present; at the limit, see CR-7), `extension-test-harness.ts` 495, `jest.config.cjs` 493, `rewrites.py` 489, `validate-planner-output.ps1` 454, `validate-executor-output.ps1` 449, `plan_gate_discrimination.py` 411. All at or below 500 (`evidence/qa-gates/file-sizes.2026-10-17T01-41.md`, re-measured by this review). |
| **Public vs internal** | ✅ PASS | Private helpers are underscore-prefixed (Python) or unexported (TypeScript). |
| **No circular dependencies** | ✅ PASS | `plan_gate_document.py` imports `PlanGateReport` under `TYPE_CHECKING` only; TypeScript imports type-only from `plan-gate-rules.ts`. |

### 2.4 Naming, Docs, and Comments

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Descriptive names** | ✅ PASS | `line_citations`, `sha_citations`, `has_size_justification`, `Test-IsPreflightRun`, `Get-PreflightRunBlockDecision`. |
| **Docs/docstrings** | ✅ PASS | Module docstrings state purpose, invariants and side effects; PowerShell functions carry comment-based help or a one-line purpose comment. |
| **Comment why, not what** | ✅ PASS | Comments explain the case-sensitive BLOCKED match, the canonical phrase stripping, and the registry-reset finding. |

### 2.5 After Making Changes - Toolchain Execution

| Requirement | Status | Evidence |
|------------|--------|----------|
| **1. Formatting** | ✅ PASS | **Command:** `black --check .`, Prettier check, PoshQC format.<br>**Result:** 620 files unchanged; Prettier clean; PoshQC rewrote no file (`toolchain-rerun.2026-10-17T02-28.md`). |
| **2. Linting** | ✅ PASS | **Command:** `ruff check`, ESLint, direct `Invoke-PoshQCAnalyze`.<br>**Result:** all clean; "PSScriptAnalyzer passed: no findings". |
| **3. Type checking** | ✅ PASS | **Command:** `pyright`, `tsc` (source and test projects).<br>**Result:** 0 errors, 0 diagnostics. |
| **4. Testing** | ✅ PASS | **Command:** Pytest with branch coverage, Jest with coverage, Pester over `tests/scripts`.<br>**Result:** 7325 passed / 0 failed; 4103 passed / 0 failed; 11055 tests / 0 failures. |
| **Full toolchain loop** | ✅ PASS | One pass recorded in `toolchain-rerun.2026-10-17T02-28.md`. The two later commits changed Markdown only; this review re-ran the contract suites at head (pass). |
| **Explicit reporting** | ✅ PASS | Every command-step artifact carries `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:`. |

### 2.6 Summarize and Document

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Summarize changes** | ✅ PASS | Commit messages follow the conventional form with the `964` scope. |
| **Design choices explained** | ✅ PASS | Research decisions D1 to D15; rule file records severity rationale for G11 to G13. |
| **Update supporting documents** | ✅ PASS | `docs/engineering/claude-code-architecture.md` mirror-table row; plan templates gained a `## Pre-Mortem` skeleton. |
| **Provide next steps** | ✅ PASS | AC-33 (orchestrator-owned re-plan) and AC-34 (CI at S9) remain; non-blocking findings in section 8. |

---

## 3. Language-Specific Code Change Policy Compliance

### Section 3A: Python Code Change Policy Compliance

#### 3A.1 Tooling & Baseline

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Formatting with Black** | ✅ PASS | **Command:** `poetry run black --check .`<br>**Result:** 620 files unchanged. |
| **Linting with Ruff** | ✅ PASS | **Command:** `poetry run ruff check`<br>**Result:** All checks passed. |
| **Type checking with Pyright** | ✅ PASS | **Command:** `poetry run pyright`<br>**Result:** 0 errors, 0 warnings. |
| **Testing with Pytest** | ✅ PASS | **Command:** `poetry run pytest` with `--cov-branch` and JSON report<br>**Result:** 7325 passed, 6 skipped; threshold check exit 0. |

#### 3A.2 Python Design & Typing

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Strong typing** | ✅ PASS | All functions annotated; no `Any`; no `type: ignore` or `noqa` added. |
| **Dataclasses for value objects** | N/A | No new value object; results are tuples and the existing `PlanGateReport`. |
| **Protocols/ABCs for interfaces** | N/A | No new interface. |
| **Avoid utility classes** | ✅ PASS | Module-level functions only. |

#### 3A.3 Python Error Handling

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Specific exceptions** | ✅ PASS | The validator module raises nothing; no broad catch added. |
| **Logging over print** | ✅ PASS | No print statements added. |
| **Invariants at construction** | N/A | No new class. |

### Section 3B: PowerShell Code Change Policy Compliance

#### 3B.1 Tooling & Baseline

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Formatting with Invoke-Formatter** | ✅ PASS | **Command:** PoshQC MCP format plus `git status` observation<br>**Result:** no PowerShell file rewritten (`ps-format.2026-10-17T02-04.md`). |
| **Linting with PSScriptAnalyzer** | ✅ PASS | **Command:** direct `Invoke-PoshQCAnalyze -Root <worktree root>`<br>**Result:** "PSScriptAnalyzer passed: no findings" (`ps-analyze.2026-10-17T02-04.md`). |
| **Fix all findings** | ✅ PASS | Zero findings. One test-helper suppression of `PSUseShouldProcessForStateChangingFunctions` with a justification, following the existing pattern in `validate-planner-output.Coverage.Tests.ps1`. |
| **PowerShell 5.1 & 7.6+ compatible** | ✅ PASS | Hooks use no 7-only syntax (`??=` not used in hooks); suites declare `#Requires -Version 7.0` as the existing hook suites do. Linux hook-suite job runs `tests/scripts/claude-hooks` on PowerShell 7. |

#### 3B.2 PowerShell Design & Safety

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Advanced functions** | ✅ PASS | New functions declare `[CmdletBinding()]`; `Get-JsonPropertyValue` lacks `[OutputType]` (CR-5, Nit). |
| **Parameter validation** | ✅ PASS | `Mandatory`, `AllowEmptyString`, `AllowEmptyCollection`, `AllowNull` used where inputs may be empty. |
| **Avoid global state** | ✅ PASS | The helper keeps no script-scope state. |
| **Error handling** | ✅ PASS | Transcript read failures are caught and degrade to the documented fallback; research read failure blocks with a reason. |

#### 3B.3 Structure, Naming, and Comments

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Cohesive and under 500 lines** | ✅ PASS | `premortem-section.ps1` 149; hooks 454, 449, 310. |
| **Approved verbs** | ✅ PASS | `Get-`, `Test-` only. |
| **Comment why** | ✅ PASS | Case-sensitivity and canonical-phrase comments explain rationale. |

#### 3B.4 Running the Toolchain

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Step 1: Format** | ✅ PASS | No file rewritten. |
| **Step 2: Analyze** | ✅ PASS | Zero findings from the direct run. |
| **Step 3: Type check** | N/A | Not applicable for PowerShell. |
| **Step 4: Test** | ✅ PASS | `artifacts/pester/pester-junit.xml`: 11055 tests, 0 failures, 0 errors, 10 disabled. |
| **Rerun loop if needed** | ✅ PASS | Final pass recorded in `toolchain-rerun.2026-10-17T02-28.md`. |

### Section 3C: TypeScript Code Change Policy Compliance

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Formatting with Prettier** | ✅ PASS | Prettier check clean (`ts-format.2026-10-17T02-04.md`, re-run in `toolchain-rerun`). |
| **Linting with ESLint** | ✅ PASS | 0 problems. |
| **Type checking with tsc** | ✅ PASS | Source and `tsconfig.jest.json` projects: 0 diagnostics. |
| **No new suppressions or `any`** | ✅ PASS | Added lines carry no `eslint-disable`, `ts-ignore`, `ts-expect-error`, or `any`. |
| **Per-file coverage threshold for new production file** | ✅ PASS | `jest.config.cjs` gains `"./src/lib/validate/plan-gate-document.ts": { lines: 85, branches: 75 }`; no production path is excluded. |

---

## 4. Language-Specific Unit Test Policy Compliance

### Section 4A: Python Unit Test Policy Compliance

#### 4A.1 Framework and Scope

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Use Pytest** | ✅ PASS | Plain Pytest functions with `monkeypatch` where needed. |
| **Coverage expectation** | ✅ PASS | New module 100.00% / 100.00%; repo-wide 94.11% / 88.78%. |

#### 4A.2 Test Style and Structure

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Focused unit tests** | ✅ PASS | One behavior per test except the row loop noted in CR-6. |
| **Mocking sparingly** | ✅ PASS | One `monkeypatch` of the generator write helper. |
| **Organization** | ✅ PASS | Tests live under `tests/scripts/dev_tools/` mirroring `scripts/dev_tools/`. |

#### 4A.3 Naming and Readability

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Naming conventions** | ✅ PASS | `test_g13_empty_justification_does_not_exonerate`, `test_brief_batch_budget_section_states_cap_codes_and_exemptions`. |
| **Docstrings/comments** | ✅ PASS | Every test has a docstring. |

#### 4A.4 Running the Toolchain

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Use Pytest** | ✅ PASS | **Command:** `poetry run pytest`<br>**Result:** 7325 passed, 6 skipped. |
| **No Alternative Test Runners** | ✅ PASS | Pytest only. |

### Section 4B: PowerShell Unit Test Policy Compliance

#### 4B.1 Framework and Scope

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Use Pester v5.x** | ✅ PASS | `BeforeAll`, `Describe`/`It`, `-ForEach`, `Should -Be`, `Mock`. |
| **Use PoshQC Configuration** | ✅ PASS | **Command:** `Invoke-PoshQCTest` through the self-hosted module.<br>**Config:** `scripts/powershell/PoshQC/settings/pester.runsettings.psd1` (unchanged). |
| **PowerShell 5.1 & 7.6+ Compatible** | ✅ PASS | Suites target PowerShell 7 as the existing hook suites do; no drive-letter or backslash fixture, so the Linux hook-suite job applies. |

#### 4B.2 Test Style and Structure

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Focused Unit Tests** | ✅ PASS | Preflight suite 29 tests; Pre-Mortem helper 17; planner Pre-Mortem 12; researcher Pre-Mortem 8. |
| **Test Behavior Over Implementation** | ✅ PASS | Tests assert block decisions and messages, not internal call order. |
| **Mocking Used Sparingly** | ✅ PASS | Mocks only file and transcript seams. |
| **Organization** | ✅ PASS | **Test file:** `tests/scripts/claude-hooks/premortem-section.Tests.ps1`<br>**Code file:** `.claude/hooks/premortem-section.ps1`<br>Follows the existing `tests/scripts/claude-hooks/` layout for `.claude/hooks/`. |

#### 4B.3 Naming and Readability

| Requirement | Status | Evidence |
|------------|--------|----------|
| **File Naming** - *.Tests.ps1 | ✅ PASS | All seven suites use `.Tests.ps1`. |
| **Describe/Context/It Structure** | ✅ PASS | Describe per function or rule group; `It` per scenario. |
| **Logical Grouping** | ✅ PASS | Classification, envelope path, block decision, helpers, wiring. |
| **Docstrings/Comments** | ✅ PASS | Suite `.SYNOPSIS`/`.DESCRIPTION` state that no test touches a file. |

#### 4B.4 Running the Toolchain

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Use PoshQCTest Command** | ✅ PASS | **Command:** `Invoke-PoshQCTest` over `tests/scripts`<br>**Result:** 11055 tests, 0 failures. |
| **No Alternative Test Runners** | ✅ PASS | Pester through PoshQC only. |

---

## 5. Test Coverage Detail

### `scripts/dev_tools/plan_gate_document.py` (11 unit tests, 4 parity tests)

| Test Name | Scenario Type | Lines Covered | Status |
|-----------|--------------|---------------|--------|
| `test_g11_reports_prose_path_and_anchor_forms` | Positive | `line_citations`, `_enclosing_token` | ✅ |
| `test_g11_ignores_count_phrases_inline_code_prose_url_ports_and_fences` | Edge Case | `_mask_inline_code`, `://` skip, fence skip | ✅ |
| `test_g12_reports_full_and_abbreviated_shas_in_prose_and_inline_code` | Positive | `sha_citations` | ✅ |
| `test_g12_ignores_ids_words_uuids_suffixes_digests_and_fences` | Negative / Edge Case | `_is_sha_candidate` all branches | ✅ |
| `test_g13_*` (five cases) | Positive / Edge Case | `plan_size`, `has_size_justification` | ✅ |
| `test_evaluate_plan_gates_reports_document_gates_after_g10` | Positive | ordering after G10 | ✅ |
| `test_document_gates_run_without_context` | Positive | context-free path | ✅ |

**Coverage:** 100.00% lines, 100.00% branches.

**Not covered:** None.

### `extensions/drm-copilot/src/lib/validate/plan-gate-document.ts` (11 unit tests, parity suite)

Same eleven case names in `it` titles plus `it.each` parity rows, the apostrophe row, and the severity case. **Coverage:** 100.00% lines, 95.08% branches. **Not covered:** a small number of defensive branch arms (for example `isWhitespace(undefined)`); above the 75% threshold.

### `.claude/hooks/premortem-section.ps1` (17 tests)

Missing heading, each missing label (seven cases), case-insensitive labels, bold labels, "not applicable" with and without a reason, labels outside the section, label order. **Coverage:** 100.00% (45/45 lines).

### `.claude/hooks/validate-executor-output.ps1` (29 new tests plus 24 existing)

Transcript classification (directive, text blocks, no directive with a stale plan directive, absent, unparseable, throwing, single signal), envelope path, single-pass rules, combined-run allowance, helpers, wiring. **Coverage:** 100.00% (166/166 lines).

### `.claude/hooks/validate-planner-output.ps1` and `validate-task-researcher-output.ps1`

Planner: 12 Pre-Mortem and locator tests plus 46 existing; 99.52% (206/207; uncovered line is pre-existing). Researcher: 8 Pre-Mortem tests; 98.17% (107/109; both uncovered lines pre-existing).

---

## 6. Test Execution Metrics

| Metric | Value | Status |
|--------|-------|--------|
| Total Tests | Python 7331 collected; Jest 4103; Pester 11055 | ✅ |
| Tests Passed | Python 7325 (6 skipped); Jest 4103 (100%); Pester 11045 (10 disabled) | ✅ |
| Tests Failed | 0 in every runtime | ✅ |
| Execution Time | Pester full run 910.6 s; Jest full run about 14 s; reviewer contract subset 1.57 s | ✅ Fast for unit scope |
| Functions/Classes Tested | All new functions have direct tests | ✅ |
| Test File Size | Largest new test file 396 lines | ✅ Maintainable |
| Code Coverage (if applicable) | Python 94.11% lines, 88.78% branches; TypeScript 97.41% lines, 92.66% branches; PowerShell 92.23% lines | ✅ |

---

## 7. Code Quality Checks

**For Python:**

| Check | Command | Result | Status |
|-------|---------|--------|--------|
| Black Formatting | `poetry run black --check .` | 620 files unchanged | ✅ |
| Ruff Linting | `poetry run ruff check` | All checks passed | ✅ |
| Pyright Type Checking | `poetry run pyright` | 0 errors | ✅ |
| Pytest Tests | `poetry run pytest --cov --cov-branch` | 7325 passed, 6 skipped | ✅ |

**For PowerShell:**

| Check | Command | Result | Status |
|-------|---------|--------|--------|
| Invoke-Formatter | `Invoke-PoshQCFormat -Root .` | No file rewritten | ✅ |
| PSScriptAnalyzer | `Invoke-PoshQCAnalyze -Root .` | No findings | ✅ |
| Pester Tests | `Invoke-PoshQCTest -Root .` | 11055 tests, 0 failures | ✅ |

**For TypeScript:**

| Check | Command | Result | Status |
|-------|---------|--------|--------|
| Prettier | `npx prettier --check .` | Clean | ✅ |
| ESLint | `npx eslint .` | 0 problems | ✅ |
| tsc | `npx tsc --noEmit` (source and jest projects) | 0 diagnostics | ✅ |
| Jest | `node run-jest.cjs --coverage` | 281 suites, 4103 tests passed | ✅ |

**Notes:** Pester could not be executed by this review agent; Pester results come from the on-disk JUnit and coverage XML files, which post-date the last hook or hook-test commit. The `toolchain-rerun` artifact reports a later Pester run over `tests` (11056 tests) whose JUnit file is not on disk (CR-4).

---

## 8. Gaps and Exceptions

### Identified Gaps

No blocking gap. Non-blocking findings (detail, location and fix in the code review):

- CR-1 (Minor): residual multi-round wording "every/all preflight revision iteration(s)" in planner surfaces and in the Codex native-converter rewrite, inconsistent with the at-most-one-return rule.
- CR-2 (Minor): `atomic-plan-contract` rule "Name the runner and job for a Pester acceptance criterion" states that `poshqc / PowerShell QC` runs every suite, which no longer matches the sharded job shape the brief documents.
- CR-3 (Minor): G11 path form reports a scheme-less `host.tld:port` token; the class is neither listed under the rule's known false-positive classes nor pinned by a test.
- CR-4 (Minor): `toolchain-rerun.2026-10-17T02-28.md` Pester counts are not traceable to an on-disk JUnit file.
- CR-5 (Nit): dense one-line PowerShell helpers and a missing `[OutputType]` on `Get-JsonPropertyValue`; case-sensitive BLOCKED matching is a behavior change not stated in the hook header or the executor's Blocking Protocol.
- CR-6 (Nit): `test_document_gate_messages_match_expected_rows` loops five rows in one test.
- CR-7 (Info): `repo-automation-dispatch.test.ts` is at exactly 500 lines.

### Approved Exceptions

**None.** No exceptions needed. Tier classification: `quality-tiers.yml` exists and `check_quality_tiers` reports OK (24 entries, 24 projects).

### Removed/Skipped Tests

**None.** All planned tests implemented. One planned Python test name was shortened in both runtimes to satisfy the Ruff line-length rule (recorded in the plan's executor note).

---

## 9. Summary of Changes

### Commits in This PR/Branch

1. **5897346f4** - docs(964): adopt issue and create active feature folder
2. **cb2fd34f2** - docs(964): add research for planning-process churn
3. **e39822128** - docs(964): write spec for planning-process churn
4. **214cc83e8** - docs(964): add design-level atomic plan
5. **25d1b8920** - docs(964): apply single-pass preflight fixes to plan
6. **9cb5106e4** - Merge remote-tracking branch 'origin/main'
7. **0c353f90a** - feat(964): add plan validator rules G11 to G13
8. **74403aaee** - docs(964): add execution-environment brief and single-pass preflight contract
9. **1bfd600af** - feat(964): enforce Pre-Mortem and single-pass preflight in SubagentStop hooks
10. **88e0fd4bc** - chore(964): sync bundled mirrors, pack manifests and Codex variants
11. **12c28910c** - fix(964): close test-order and preflight-block gaps found in final QA
12. **376d5f4a5** - Merge remote-tracking branch 'origin/main'
13. **3e3ed2ece** - fix(964): apply single-pass preflight to language-specific surfaces
14. **4f56c8473** - docs(964): refresh brief CI shape and document the mask false-positive class
15. **1f017bd4b** - docs(964): record final QA, pre-mortem and self-review evidence

### Files Modified

1. **`scripts/dev_tools/plan_gate_document.py`** and **`extensions/drm-copilot/src/lib/validate/plan-gate-document.ts`** (NEW) - G11, G12, G13 with verbatim message parity.
2. **`scripts/dev_tools/plan_gate_discrimination.py`**, **`plan-gate-discrimination.ts`** (MODIFIED) - call document gates after G10; re-export severities.
3. **`.claude/hooks/premortem-section.ps1`** (NEW), **`validate-planner-output.ps1`**, **`validate-task-researcher-output.ps1`**, **`validate-executor-output.ps1`** (MODIFIED) and bundle copies - Pre-Mortem enforcement, line-locator rejection, transcript-based preflight detection, single-pass rules, combined-run allowance.
4. **`.claude/skills/execution-environment/SKILL.md`** (NEW) and five copies - the brief.
5. Contract and agent text across `.claude`, `.agents`, `.codex`, `.github` and bundles; 44 regenerated Codex variants; plan templates; pack manifests; `docs/engineering/claude-code-architecture.md`.
6. Related fixes: Codex native-converter rewrite text (Python and TypeScript), generator manifest newline handling, Jest registry-reset order dependence.
7. Tests: 11 new and 11 modified test files; 61 evidence files.

---

## 10. Compliance Verdict

### Overall Status: ✅ FULLY COMPLIANT

All policy requirements are met with numeric baseline and post-change coverage for Python, TypeScript and PowerShell. No blocking finding. Seven non-blocking findings are listed in section 8 for correction in the same pass.

**Fail-closed reminder:** Required baseline, QA and coverage-comparison artifacts are all present; PowerShell figures were read from on-disk XML rather than re-run by this review.

---

### Policy-by-Policy Summary

#### General Code Change Policy (Section 2)
- ✅ Before Making Changes: issue, research, spec and plan present
- ✅ Design Principles: pure validators, seams for I/O
- ✅ Module & File Structure: all files at or below 500 lines
- ✅ Naming, Docs, Comments: compliant
- ✅ Toolchain Execution: single-pass loop recorded
- ✅ Summarize & Document: compliant

#### Language-Specific Code Change Policy (Section 3)

**For Python:**
- ✅ Tooling & Baseline: clean
- ✅ Python Design & Typing: fully typed
- ✅ Error Handling: no broad catches

**For PowerShell:**
- ✅ Tooling & Baseline: no analyzer findings
- ✅ PowerShell Design & Safety: seams and guarded loads
- ✅ Structure & Naming: approved verbs
- ✅ Toolchain: 0 Pester failures

#### General Unit Test Policy (Section 1)
- ✅ Core Principles: seeded shuffles pass in all three runtimes
- ✅ Coverage & Scenarios: no regression; new files at 100% lines
- ✅ Test Structure: AAA throughout
- ✅ External Dependencies: none; no temporary files
- ✅ Policy Audit: this document

#### Language-Specific Unit Test Policy (Section 4)

**For Python:**
- ✅ Framework & Scope: Pytest
- ✅ Test Style & Structure: focused
- ✅ Naming & Readability: descriptive
- ✅ Toolchain: Pytest only

**For PowerShell:**
- ✅ Framework & Scope: Pester 5
- ✅ Test Style & Structure: seam mocks only
- ✅ Naming & Readability: `.Tests.ps1`
- ✅ Toolchain: PoshQC

---

### Metrics Summary

- ✅ 7325/7325 Python, 4103/4103 Jest, 11045/11045 executed Pester tests passing
- ✅ All new functions tested
- ✅ 94.11% / 97.41% / 92.23% line coverage (Python / TypeScript / PowerShell)
- ✅ Tests mirror source layout
- ✅ All code quality checks passing
- ✅ Isolation runs pass with recorded seeds

---

### Recommendation

**Ready for merge**, subject to the orchestrator-owned AC-33 and the CI-dependent AC-34. Apply the seven non-blocking findings in the same pass where practical (CR-1 to CR-3 are contract-text consistency fixes in surfaces this item already edits).

---

## Appendix A: Test Inventory

### Complete Test List

- `tests/scripts/dev_tools/test_plan_gate_document.py` (11 tests)
- `tests/scripts/dev_tools/test_plan_gate_document_parity.py` (4 tests)
- `tests/scripts/dev_tools/test_plan_gate_document_docs.py` (5 tests)
- `tests/scripts/dev_tools/test_execution_environment_brief_contracts.py` (16 tests)
- `tests/scripts/dev_tools/test_single_pass_preflight_contracts.py` (10 tests)
- `tests/scripts/dev_tools/test_plan_gate_scratch_docs.py`, `test_codex_agent_wrapper_contracts.py`, `test_generate_codex_agent_variants.py`, `codex_native_converter/test_rewrites.py` (modified)
- `extensions/drm-copilot/test/lib/validate/plan-gate-document.test.ts` (11 tests), `plan-gate-document-parity.test.ts` (7 tests), `test/lib/codex-native-converter/rewrites.test.ts` (modified)
- `tests/scripts/claude-hooks/premortem-section.Tests.ps1` (17), `validate-executor-output.Preflight.Tests.ps1` (29), `validate-planner-output.PreMortem.Tests.ps1` (12), `validate-task-researcher-output.PreMortem.Tests.ps1` (8), `validate-planner-output.Tests.ps1` (25), `.Coverage.Tests.ps1` (12), `.Reentry.Tests.ps1` (9)

---

## Appendix B: Toolchain Commands Reference

**For Python:**
```bash
poetry run black --check .
poetry run ruff check
poetry run pyright
poetry run pytest --cov --cov-branch --cov-report=json:artifacts/python/coverage.json --cov-report=term-missing
poetry run python -m scripts.dev_tools.check_python_coverage_thresholds --report artifacts/python/coverage-964-qa.json --min-line 85 --min-branch 75
poetry run python -m scripts.dev_tools.generate_codex_agent_variants --check
poetry run python -m scripts.dev_tools.check_quality_tiers
poetry run python -m scripts.dev_tools.validate_evidence_locations --root .
poetry run python -m scripts.dev_tools.validate_orchestration_artifacts plan docs/features/active/2026-10-16-planning-process-churn-964/plan.2026-10-16T18-10.md
```

**For PowerShell:**
```powershell
Import-Module ./scripts/powershell/PoshQC; Invoke-PoshQCFormat -Root .
Import-Module ./scripts/powershell/PoshQC; Invoke-PoshQCAnalyze -Root .
Import-Module ./scripts/powershell/PoshQC; Invoke-PoshQCTest -Root .
```

**For TypeScript (in `extensions/drm-copilot/`):**
```bash
npx prettier --check .
npx eslint .
npx tsc --noEmit -p tsconfig.json
npx tsc --noEmit -p tsconfig.jest.json
node run-jest.cjs --coverage
node run-jest.cjs --randomize --seed=964964
```

---

**Audit Completed By:** feature-review agent
**Audit Date:** 2026-10-17
**Policy Version:** Current (as of audit date)
