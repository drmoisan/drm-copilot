# Policy Compliance Audit: orchestrator-completion-hook-false-block (Issue #413)

**Audit Date:** 2026-07-25
**Code Under Test:**
- `.claude/hooks/validate-orchestrator-output.ps1` (PowerShell, modified)
- `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/validate-orchestrator-output.ps1` (PowerShell, modified — byte-identical bundled resync)
- `tests/scripts/claude-hooks/validate-orchestrator-output.Tests.ps1` (PowerShell test, modified)
- Documentation and evidence under `docs/features/active/2026-07-25-orchestrator-completion-hook-false-block-413/` and `docs/features/potential/promoted/` (Markdown/JSON, additive)

**Template source note:** The MCP tool `resolve_policy_audit_template_asset` could not be invoked from this delegated review environment (no MCP tool surface is available to this agent). The template was taken directly from the bundled asset file that the tool resolves, `extensions/drm-copilot/resources/templates/policy_audit/policy-audit.yyyy-MM-ddTHH-mm.md` (verified against `extensions/drm-copilot/src/policy-audit-template-assets.ts`, which maps selector `template` to exactly that path). The template content used is therefore byte-identical to the tool-resolved asset.

**Review scope:** Full branch diff `72126592..60994855` (`bug/orchestrator-completion-hook-false-block-413` vs. base `main`). Languages with changed files: PowerShell only. Python, TypeScript, and C# have zero changed files on this branch.

**Coverage Metrics by Language:**

| Language | Files Changed | Tests | Test Result | Baseline Coverage | Post-Change Coverage | New Code Coverage |
|----------|--------------|-------|-------------|-------------------|---------------------|-------------------|
| PowerShell | 3 files | 1,356 tests | PASS: 1,347 pass, 0 fail, 9 skipped | 89.68% instr, 90.22% lines | 89.68% instr, 90.22% lines | 92.16% lines (changed hook file) |
| Python | 0 files | N/A | N/A (no changed files) | N/A (no changed files) | N/A (no changed files) | N/A |
| TypeScript | 0 files | N/A | N/A (no changed files) | N/A (no changed files) | N/A (no changed files) | N/A |
| C# | 0 files | N/A | N/A (no changed files) | N/A (no changed files) | N/A (no changed files) | N/A |

### Coverage Evidence Checklist

- TypeScript baseline coverage artifact: N/A - out of scope (zero TypeScript files changed on this branch)
- TypeScript post-change coverage artifact: N/A - out of scope (zero TypeScript files changed on this branch)
- PowerShell baseline coverage artifact: docs/features/active/2026-07-25-orchestrator-completion-hook-false-block-413/evidence/baseline/poshqc-test.2026-07-25T17-01.md (values read from artifacts/pester/powershell-coverage.xml)
- PowerShell post-change coverage artifact: artifacts/pester/powershell-coverage.xml (written 2026-07-25T17-29), summarized in docs/features/active/2026-07-25-orchestrator-completion-hook-false-block-413/evidence/qa-gates/final-poshqc-test.2026-07-25T17-24.md and independently re-parsed by this reviewer
- Per-language comparison summary: section 1.2.1 of this audit, backed by docs/features/active/2026-07-25-orchestrator-completion-hook-false-block-413/evidence/qa-gates/coverage-delta.2026-07-25T17-24.md

**Coverage verdicts (explicit, per language with changed files):**

- PowerShell: **PASS**. Repo-wide line coverage 90.22% (>= 85%); repo-wide instruction coverage 89.68% (>= 85%); modified hook per-file line coverage 92.16% (>= 85%); no regression on changed lines (the fixed decision line 232 reports `mi=0 ci=2`; missed-line set `140, 309, 313, 344-347, 350` contains no changed line). Branch coverage is not emitted by the toolchain — see section 8 for the adjudicated exception.
- Python, TypeScript, C#: N/A — zero changed files on this branch (verified from `git diff --name-status 72126592..HEAD`).

---

## Rejected Scope Narrowing

None detected. The caller prompt explicitly delegated scope determination to this reviewer ("Determine review scope yourself from the branch diff against the merge-base. I am not narrowing it"). The audit scope used is the full branch diff against `main` at merge-base `72126592`.

---

## Evidence Location Compliance

- `python scripts/dev_tools/validate_evidence_locations.py --root .` exited **0** (no violations).
- The branch diff contains no files under `artifacts/baselines/`, `artifacts/qa/`, `artifacts/evidence/`, or `artifacts/coverage/`. All 23 evidence artifacts reside under the canonical `docs/features/active/2026-07-25-orchestrator-completion-hook-false-block-413/evidence/<kind>/` scheme (verified from `git diff --name-status 72126592..HEAD`).
- No `EVIDENCE_LOCATION_OVERRIDE_REJECTED` events were required; no caller instruction supplied a non-canonical evidence path.

**Verdict: PASS.**

---

## Executive Summary

This audit covers the issue #413 bug fix: `Invoke-RoutingContractValidation` in `.claude/hooks/validate-orchestrator-output.ps1` previously treated the Python validator's stdout success line (captured via `2>&1`) as error text, causing the completion gate to false-block every DONE claim on the live validator path. The fix keys the error decision solely on the subprocess exit code (`$hasErrors = ($exitCode -ne 0)`), carries `ErrorText` through unchanged, corrects the docstring and inline comment, and resyncs the bundled pushed-down copy byte-identically.

The load-bearing safety claim — that the exit code is a complete failure discriminator — was verified by this reviewer directly against `scripts/dev_tools/validate_orchestration_artifacts.py`: `main()` prints every validation error to stderr and returns 1 (lines 347-350), and prints the success line to stdout and returns 0 (lines 351-352). No code path prints error text while exiting 0; argparse misuse exits 2 and unhandled exceptions exit non-zero. The gate is not weakened.

All toolchain stages pass. PSScriptAnalyzer was independently re-run by this reviewer on both changed PowerShell files (0 findings). The three relevant Pester test files were independently re-run (40/40 pass). The bundle-parity pytest was independently re-run (7/7 pass). Byte parity was independently confirmed by SHA-256 (`5e4bfa47…3183b` for both copies). The fixed hook was independently re-executed end-to-end: exit 0 against the completion-passing fixture checkpoint, and exit 1 with `ROUTING_CONTRACT_BLOCKED:` against the genuinely failing live checkpoint (read-only).

**Policy documents evaluated:**
- PASS `.claude/rules/general-code-change.md`
- PASS `.claude/rules/general-unit-test.md`

**Language-specific policies evaluated:**
- PASS `.claude/rules/powershell.md` (PowerShell code change and unit test policy)
- N/A Python / TypeScript / C# policies (zero changed files)

**Temporary artifacts cleanup:**
- PASS — The fixture-generation script noted in `evidence/qa-gates/hook-e2e-allow.2026-07-25T17-19.md` was created in the session scratchpad and deleted after use. `git status` at review start was clean; no stray temporary files appear in the diff.

---

## 1. General Unit Test Policy Compliance

### 1.1 Core Principles

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Independence** - Tests run in any order | PASS | All new/revised tests use in-memory scriptblock stubs injected via the `-Invoker` / `-RoutingInvoker` seams and mocked `Get-CheckpointFileContent`; no shared mutable state. Independently re-run in isolation (40/40 pass across three files). |
| **Isolation** - Each test targets single behavior | PASS | Each new `It` block asserts one decision outcome: unit-level `HasErrors` for exit 0 + success line; end-to-end `Ok`/`Message` for the ALLOW path; `HasErrors` for exit code 2. |
| **Fast Execution** - Tests complete quickly | PASS | Reviewer re-run: 3 files, 40 tests, 2.15s total. Full suite 1,347 tests in 36.88s (executor evidence). |
| **Determinism** - Consistent results | PASS | No wall-clock, RNG, network, or filesystem dependence in the changed tests; checkpoint content injected via mock; validator subprocess replaced by scriptblock stubs. |
| **Readability & Maintainability** - Clear structure | PASS | Test names state scenario and expected outcome, reference issue #413, and use Arrange/Act/Assert comments (diff hunks inspected). |

### 1.2 Coverage and Scenarios

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Baseline Coverage Documented** | PASS | Baseline (pre-change): 89.68% instructions / 90.22% lines repo-wide; hook per-file 93.30% instructions / 92.16% lines. Command: `Invoke-PoshQCTest -Root .`. Timestamp: 2026-07-25 17:01. Artifact: `evidence/baseline/poshqc-test.2026-07-25T17-01.md`. |
| **No Coverage Regression** | PASS | Post-change: 89.68% instructions / 90.22% lines repo-wide (0.00 pp change). Hook per-file line coverage unchanged at 92.16% (94/8 covered/missed identical). Per-file instruction ratio moved -0.04 pp solely because the fix removed one covered command from the denominator (179 to 178); missed counts unchanged at 12 instructions / 8 lines. Reviewer independently re-parsed `artifacts/pester/powershell-coverage.xml` and confirmed all values. |
| **New Code Coverage >= thresholds** | PASS | No new files. Changed lines in the modified hook are fully covered: line 232 (`$hasErrors = ($exitCode -ne 0)`) reports `mi=0 ci=2`; no missed line falls in the changed regions (docstring 165-176, comment/decision 228-233). |
| **Comprehensive Coverage** | PASS | `Invoke-RoutingContractValidation` decision paths covered: exit 0 + success line (allow), exit 0 + empty output (allow), non-zero exit (block), exit 2 (block). End-to-end ALLOW and BLOCK paths covered through `Invoke-OrchestratorOutputValidation`. Hook uncovered lines are the entrypoint guard block (344-347, 350) and two rarely-hit defensive branches (140, 309, 313), unchanged from baseline. |
| **Positive Flows** - Valid inputs | PASS | Exit 0 + success line at unit level and end-to-end (2 new tests); exit 0 + empty output (pre-existing). |
| **Negative Flows** - Invalid inputs | PASS | Non-zero exit blocks (pre-existing, unmodified); exit 2 blocks (new); genuine-failure end-to-end `ROUTING_CONTRACT_BLOCKED` (pre-existing, unmodified). |
| **Edge Cases** - Boundary conditions | PASS | Exit code 2 (argparse misuse / crash path) added specifically to pin the fail-closed boundary beyond exit 1. |
| **Error Handling** - Error paths | PASS | `MODEL_ROUTING_BLOCKED` vs `ROUTING_CONTRACT_BLOCKED` discrimination locked by `validate-orchestrator-output.model-routing.Tests.ps1` (unmodified, re-run PASS). Portable fallback fail-closed paths locked by `OrchestratorStateCompletion.Tests.ps1` (unmodified, re-run PASS). |
| **Concurrency** - If applicable | N/A | The hook is a single-shot subprocess with no concurrent behavior. |
| **State Transitions** - If applicable | N/A | The hook is stateless; it reads a checkpoint and returns a decision. |

### 1.2.1 Per-Language Coverage Comparison

- PowerShell: Baseline: 89.68% instruction / 90.22% line repo-wide -> Post-change: 89.68% instruction / 90.22% line repo-wide. Change: 0.00 pp repo-wide; per-file instruction -0.04 pp explained entirely by one covered command removed from the denominator, per-file line unchanged at 92.16%. New/changed-code coverage: 92.16% line for the changed hook with changed line 232 fully covered (mi=0). Disposition: PASS. Evidence: docs/features/active/2026-07-25-orchestrator-completion-hook-false-block-413/evidence/qa-gates/coverage-delta.2026-07-25T17-24.md and artifacts/pester/powershell-coverage.xml (independently re-parsed by this reviewer).

### 1.3 Test Structure and Diagnostics

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Clear Failure Messages** | PASS | Pester `Should -BeTrue` / `-BeFalse` / `-BeNullOrEmpty` assertions produce expected-vs-actual diagnostics; fail-before evidence shows exact actionable failures (`Expected $true, but got $false` at the asserting line). |
| **Arrange-Act-Assert Pattern** | PASS | All new `It` blocks carry explicit `# Arrange`, `# Act`, `# Assert` comments (diff inspected). |
| **Document Intent** | PASS | Test names describe scenario and outcome and cite issue #413; Arrange comments explain why exit-0-with-text is the success shape. |

### 1.4 External Dependencies and Environment

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Avoid External Dependencies** | PASS | No unit test spawns the Python validator; the subprocess seam is stubbed with in-memory scriptblocks. |
| **Use Mocks/Stubs** | PASS | `Get-CheckpointFileContent` mocked for checkpoint content; `-Invoker` / `-RoutingInvoker` scriptblock stubs replace the subprocess. Justification: isolate the decision logic from Python availability. |
| **Environment Stability** | PASS | No temporary files created by tests (policy-prohibited); no environment variables mutated by the changed tests; no global state. |

### 1.5 Policy Audit Requirement

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Pre-submission Review** | PASS | This audit, together with `code-review.2026-07-25T17-54.md` and `feature-audit.2026-07-25T17-54.md`, constitutes the required pre-PR policy review. |

---

## 2. General Code Change Policy Compliance

### 2.1 Before Making Changes

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Clarify the objective** | PASS | Issue #413; `issue.md`, `spec.md` (work mode `full-bug`), and the research artifact define the defect and fix precisely. |
| **Read existing change plans** | PASS | `evidence/baseline/phase0-instructions-read.md` records the policy reading order; the approved plan is `plan.2026-07-25T15-37.md` (35 tasks, all complete). |
| **Document the plan** | PASS | `plan.2026-07-25T15-37.md` with per-task acceptance and evidence paths. |

### 2.2 Design Principles

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Simplicity first** | PASS | The fix replaces a two-disjunct boolean with a single exit-code test — the simplest correct design. Rejected alternatives (success-line string matching, stream separation, shared-module extraction) are documented in spec Design and research Section 2. |
| **Reusability** | PASS | The fix converges on the established repository pattern (`Invoke-OrchestratorStatePreflight` uses the identical `HasErrors = ($exitCode -ne 0)` shape). |
| **Extensibility** | PASS | The `$Invoker` seam and `{ HasErrors, ErrorText }` return contract are unchanged; every existing caller and test remains valid. |
| **Separation of concerns** | PASS | Routing logic stays in the Python validator; the hook only interprets the exit code. No logic was reimplemented in PowerShell. |

### 2.3 Module & File Structure

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Cohesive modules** | PASS | Change confined to one function in one hook plus its byte-identical bundled mirror and its test file. |
| **Under 500 lines** | PASS | Reviewer-measured: hook 350 lines; test file 486 lines (was 449; cap 500). Bundled copy 350 lines (byte-identical). |
| **Public vs internal** | PASS | No public API change; seam signature and return contract preserved. |
| **No circular dependencies** | PASS | No import graph change in the diff. |

### 2.4 Naming, Docs, and Comments

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Descriptive names** | PASS | No identifiers added or renamed; existing names unchanged. |
| **Docs/docstrings** | PASS | `.DESCRIPTION` corrected to document exit-code-only discrimination, including why output text must not influence the decision (2>&1 folds the stdout success line into the capture). |
| **Comment why, not what** | PASS | The inline comment above the decision explains the rationale (exit code is the complete discriminator) rather than restating the code. |

### 2.5 After Making Changes - Toolchain Execution

| Requirement | Status | Evidence |
|------------|--------|----------|
| **1. Formatting** | PASS | **Command:** `mcp__drm-copilot__run_poshqc_format` / `Invoke-PoshQCFormat -Root .`<br>**Result:** EXIT_CODE 0, no files changed (`evidence/qa-gates/final-poshqc-format.2026-07-25T17-24.md`; clean `git status` corroborates). |
| **2. Linting** | PASS | **Command:** `Invoke-PoshQCAnalyze -Root .`<br>**Result:** 0 findings (`evidence/qa-gates/final-poshqc-analyze.2026-07-25T17-24.md`). Reviewer independently re-ran `Invoke-ScriptAnalyzer` on both changed files: 0 findings. |
| **3. Type checking** | N/A | Not applicable for PowerShell per `.claude/rules/general-code-change.md`. |
| **4. Testing** | PASS | **Command:** `Invoke-PoshQCTest -Root .`<br>**Result:** 1,347 passed / 0 failed / 9 skipped (`evidence/qa-gates/final-poshqc-test.2026-07-25T17-24.md`). Reviewer independently re-ran the three affected test files: 40/40 pass. Bundle-parity pytest independently re-run: 7/7 pass. |
| **Full toolchain loop** | PASS | Single clean pass at [P6-T1]..[P6-T4]; no stage failed or auto-fixed, so no restart was required. |
| **Explicit reporting** | PASS | Every stage has a timestamped evidence artifact with Command / EXIT_CODE / Output Summary fields. |

### 2.6 Summarize and Document

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Summarize changes** | PASS | Spec `## Outcome` section records the delivered change, hashes, and verification headline. |
| **Design choices explained** | PASS | Spec Design and Justification sections; research artifact Section 2. |
| **Update supporting documents** | PASS | `spec.md` status updated; AC check-offs recorded; evidence catalog table in spec Outcome. |
| **Provide next steps** | PASS | Spec Rollout section: standard feature-review and PR flow; bundled copy ships with next extension release. |

---

## 3. Language-Specific Code Change Policy Compliance

### Section 3B: PowerShell Code Change Policy Compliance

#### 3B.1 Tooling & Baseline

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Formatting with Invoke-Formatter** | PASS | **Command:** `Invoke-PoshQCFormat -Root .` — EXIT_CODE 0, no files changed (baseline and final artifacts). |
| **Linting with PSScriptAnalyzer** | PASS | **Command:** `Invoke-PoshQCAnalyze -Root .` — 0 findings; independently confirmed by reviewer on both changed files. |
| **Fix all findings** | PASS | No findings existed to fix. |
| **PowerShell 5.1 & 7.6+ compatible** | PASS | The change uses only `[int]` cast and `-ne` comparison; no version-specific syntax introduced. Suite runs under pwsh 7.x. |

#### 3B.2 PowerShell Design & Safety

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Advanced functions** | PASS | `Invoke-RoutingContractValidation` retains `[CmdletBinding()]` and `[OutputType([hashtable])]`; unchanged by the diff. |
| **Parameter validation** | PASS | Parameter block unchanged; mandatory `CheckpointPath`, typed `[scriptblock] $Invoker` with default. |
| **Avoid global state** | PASS | No global variables introduced; decision uses locals only. |
| **Error handling** | PASS | Fail-closed semantics preserved: every non-zero exit (including 2 and crash paths) blocks; `Set-StrictMode -Version Latest` and `$ErrorActionPreference = 'Stop'` unchanged at script level. |

#### 3B.3 Structure, Naming, and Comments

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Cohesive and under 500 lines** | PASS | Hook 350 lines; test file 486 lines; both under cap (reviewer-measured `wc -l`). |
| **Approved verbs** | PASS | No functions added; existing `Invoke-`, `Get-`, `Test-` verbs unchanged. |
| **Comment why** | PASS | New comment explains the discriminator rationale, not mechanics. |

#### 3B.4 Running the Toolchain

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Step 1: Format** | PASS | EXIT_CODE 0, no changes (final QA artifact). |
| **Step 2: Analyze** | PASS | 0 findings (final QA artifact; reviewer re-run). |
| **Step 3: Type check** | N/A | Not applicable for PowerShell. |
| **Step 4: Test** | PASS | 1,347/0/9 (final QA artifact); targeted reviewer re-run 40/40. |
| **Rerun loop if needed** | PASS | One iteration; no restart triggered. |

---

## 4. Language-Specific Unit Test Policy Compliance

### Section 4B: PowerShell Unit Test Policy Compliance

#### 4B.1 Framework and Scope

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Use Pester v5.x** | PASS | `Describe`/`Context`/`It`, `BeforeAll`, modern `Should` syntax throughout the changed file. |
| **Use PoshQC Configuration** | PASS | **Command:** `Invoke-PoshQCTest -Root .` with `scripts/powershell/PoshQC/settings/pester.runsettings.psd1` (unchanged by this diff; the hook was already instrumented under `CodeCoverage.Path`). |
| **PowerShell 5.1 & 7.6+ Compatible** | PASS | No version-specific constructs in the test changes. |

#### 4B.2 Test Style and Structure

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Focused Unit Tests** | PASS | One behavior per `It`; unit-level and end-to-end concerns kept in separate Contexts. |
| **Test Behavior Over Implementation** | PASS | Assertions target the decision contract (`HasErrors`, `Ok`, `Message`), not internals. |
| **Mocking Used Sparingly** | PASS | Only the filesystem boundary (`Get-CheckpointFileContent`) and the subprocess seam are mocked — both are I/O boundaries. |
| **Organization** | PASS | Test file `tests/scripts/claude-hooks/validate-orchestrator-output.Tests.ps1` mirrors code file `.claude/hooks/validate-orchestrator-output.ps1` per the established repo layout. |

#### 4B.3 Naming and Readability

| Requirement | Status | Evidence |
|------------|--------|----------|
| **File Naming** - *.Tests.ps1 | PASS | `validate-orchestrator-output.Tests.ps1`. |
| **Describe/Context/It Structure** | PASS | New tests placed in the existing `Invoke-RoutingContractValidation` and `routing-contract validation (Gap 1)` Contexts. |
| **Logical Grouping** | PASS | Unit-level decision tests grouped with the seam Context; end-to-end tests with the Gap 1 Context. |
| **Docstrings/Comments** | PASS | Self-documenting names plus Arrange rationale comments. |

#### 4B.4 Running the Toolchain

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Use PoshQCTest Command** | PASS | `Invoke-PoshQCTest -Root .` — 1,347 passed / 0 failed. |
| **No Alternative Test Runners** | PASS | Only Pester through PoshQC; reviewer's targeted verification also used `Invoke-Pester` directly (same framework). |

---

## 5. Test Coverage Detail

### Invoke-RoutingContractValidation (4 direct tests)

| Test Name | Scenario Type | Lines Covered | Status |
|-----------|--------------|---------------|--------|
| reports HasErrors when the seam returns a non-zero exit code | Negative | 218-233 | PASS |
| reports HasErrors when the seam returns exit code 2 (argparse misuse / crash path stays fail-closed) | Edge Case | 218-233 | PASS |
| reports no errors when the seam returns exit 0 with the validator success line (issue #413) | Positive | 218-233 | PASS |
| reports no errors when the seam returns exit 0 and empty output | Positive | 218-233 | PASS |

**Coverage:** decision function fully covered; changed line 232 reports `mi=0 ci=2` in `artifacts/pester/powershell-coverage.xml`.

### Invoke-OrchestratorOutputValidation (end-to-end paths touched by this change)

| Test Name | Scenario Type | Lines Covered | Status |
|-----------|--------------|---------------|--------|
| allows DONE when the validator exits 0 and prints its success line (issue #413) | Positive | 319-336 | PASS |
| blocks DONE with ROUTING_CONTRACT_BLOCKED when the validator reports errors | Error Handling | 319-333 | PASS |
| MODEL_ROUTING_BLOCKED discrimination cases (model-routing.Tests.ps1, 6 tests, unmodified) | Error Handling | 324-333 | PASS |

**Not covered:** hook entrypoint lines 344-347, 350 (script-invocation guard, executed only as a process; exercised instead by the end-to-end evidence runs) and defensive branches at 140, 309, 313 — all unchanged from baseline.

---

## 6. Test Execution Metrics

| Metric | Value | Status |
|--------|-------|--------|
| Total Tests (full PowerShell suite) | 1,356 discovered | PASS |
| Tests Passed | 1,347 (100% of non-skipped) | PASS |
| Tests Failed | 0 | PASS |
| Skipped | 9 (unchanged from baseline) | PASS |
| Execution Time | 36.88s full suite; 2.15s reviewer targeted re-run (40 tests) | PASS Fast |
| Test File Size | 486 lines (cap 500) | PASS Maintainable |
| Code Coverage | 90.22% lines / 89.68% instructions repo-wide; branch metric not emitted by toolchain (see section 8) | PASS |

---

## 7. Code Quality Checks

**For PowerShell:**

| Check | Command | Result | Status |
|-------|---------|--------|--------|
| Invoke-Formatter | `Invoke-PoshQCFormat -Root .` | EXIT_CODE 0, no files changed | PASS |
| PSScriptAnalyzer | `Invoke-PoshQCAnalyze -Root .` | 0 findings (reviewer re-run on changed files: 0 findings) | PASS |
| Pester Tests | `Invoke-PoshQCTest -Root .` | 1,347 passed / 0 failed / 9 skipped | PASS |

**Cross-cutting:**

| Check | Command | Result | Status |
|-------|---------|--------|--------|
| Bundle byte parity | `sha256sum` both hook copies; `poetry run python -m pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py -q` | Identical hash `5e4bfa47…3183b`; 7/7 pytest pass (reviewer re-run) | PASS |
| Evidence locations | `python scripts/dev_tools/validate_evidence_locations.py --root .` | EXIT_CODE 0 | PASS |
| End-to-end ALLOW | `CLAUDE_HOOK_INPUT='{"output":"DONE…"}' pwsh -File .claude/hooks/validate-orchestrator-output.ps1 -CheckpointPath <fixture>` | EXIT_CODE 0 (reviewer re-run) | PASS |
| End-to-end BLOCK (fail-closed) | same command with `-CheckpointPath artifacts/orchestration/orchestrator-state.json` (read-only) | EXIT_CODE 1 with `ROUTING_CONTRACT_BLOCKED:` carrying validator stderr (reviewer re-run) | PASS |

**Notes:**
The `modified-workflow-needs-green-run` policy rule does not fire: the diff contains no path under `.github/workflows/**`, `scripts/benchmarks/**`, or `.github/actions/**`.

---

## 8. Gaps and Exceptions

### Identified Gaps

**None.** All measurable policy requirements are met.

### Approved Exceptions

1. **Branch-coverage gate (>= 75%) not measurable for PowerShell — adjudicated and accepted by this reviewer.** The claim was verified independently, not taken from the executor's record: `grep` over `artifacts/pester/powershell-coverage.xml` finds counter types INSTRUCTION (265), LINE (265), METHOD (265), and CLASS (70) only — zero `BRANCH` counters at report, package, or sourcefile level. Per-line `mb`/`cb` attributes exist but are uniformly zero, confirming Pester's `CoverageGutters` (JaCoCo) writer does not populate branch data in this toolchain. Repository precedent: `docs/features/completed/2026-07-02-local-preflight-orchestrator-state-gate-272/evidence/baseline/poshqc-test-baseline.md` (a completed, merged feature) records the same limitation. Ruling: the branch-coverage clause is genuinely not measurable for PowerShell in this repository; treating an unmeasurable metric as a permanent FAIL would block every PowerShell change and contradicts accepted repository practice. The exception is scoped to the PowerShell toolchain's absent BRANCH counter and does not lower any measurable threshold. Recommended follow-up (non-blocking): file a tooling issue to evaluate a branch-capable PowerShell coverage path.

2. **AC12 fixture substitution — adjudicated and accepted by this reviewer.** The primary acceptance evidence used the fixture checkpoint `evidence/other/completion-passing-checkpoint.2026-07-25T17-19.json` rather than the live `artifacts/orchestration/orchestrator-state.json`, per the approved plan's [P5-T2] fixture branch. The live checkpoint is owned by the enclosing orchestration, was mid-run (validator precheck exit 1 for reasons unrelated to this change), and could not be brought to a passing state without writing to a file this execution was forbidden to modify. The criterion's substance is met: the hook was exercised end-to-end through its real default `$Invoker` (genuine Python subprocess, `2>&1` capture, no mock) against a checkpoint independently proven to pass `--require-complete --require-model-routing` at exit 0. This reviewer re-executed both the ALLOW run (exit 0) and the fail-closed run against the live checkpoint (exit 1, `ROUTING_CONTRACT_BLOCKED:`). The path substitution does not change the code path exercised.

### Removed/Skipped Tests

1. **"reports HasErrors when the seam returns error text with exit 0"** — replaced in place (commit `60994855`).
   - **Reason:** The test asserted the defect itself: it required exit-0-plus-text to block, which is exactly the false-block behavior issue #413 removes. The input it modeled (exit 0 with text) is produced by the authoritative CLI only on success.
   - **Impact:** The exit-0-with-text scenario is still covered — by the new test asserting the corrected (allow) behavior. The `ErrorText`-content assertion it carried is preserved on the genuine-failure path by the pre-existing non-zero-exit tests and the live fail-closed evidence.
   - **Justification:** Required by spec AC6; keeping the old assertion would contradict the fix.

---

## 9. Summary of Changes

### Commits in This PR/Branch

1. **a587c0c6** - docs(413): add research, spec, and atomic plan for orchestrator-completion-hook-false-block
2. **60994855** - fix(orchestrator-hook): key routing-contract validation on exit code only

### Files Modified

1. **`.claude/hooks/validate-orchestrator-output.ps1`** (MODIFIED, +14/-6)
   - Error decision in `Invoke-RoutingContractValidation` changed to `$hasErrors = ($exitCode -ne 0)`; `ErrorText` carried through unchanged; `.DESCRIPTION` and inline comment corrected to document exit-code-only discrimination.
2. **`extensions/drm-copilot/resources/claude-customizations/.claude/hooks/validate-orchestrator-output.ps1`** (MODIFIED, +14/-6)
   - Byte-identical resync of the repo hook (SHA-256 verified identical).
3. **`tests/scripts/claude-hooks/validate-orchestrator-output.Tests.ps1`** (MODIFIED, +40/-3)
   - Defect-asserting test replaced with exit-2 fail-closed test; new unit-level exit-0-success-line ALLOW test; new end-to-end ALLOW test. 449 -> 486 lines.
4. **Documentation/evidence** (ADDED)
   - Feature folder `docs/features/active/2026-07-25-orchestrator-completion-hook-false-block-413/` (issue, spec, plan, research, 23 evidence artifacts) and promotion record `docs/features/potential/promoted/2026-07-25-orchestrator-completion-hook-false-block.md`.

---

## 10. Compliance Verdict

### Overall Status: FULLY COMPLIANT

All toolchain stages pass in a single clean pass; repo-wide and per-file coverage meet the uniform thresholds for every measurable metric; no coverage regression on changed lines; both changed-file line counts are under the 500-line cap; evidence locations are canonical; the gate's fail-closed property is preserved and was independently re-verified end-to-end. Two adjudicated exceptions are recorded in section 8 (unmeasurable PowerShell branch metric; plan-sanctioned AC12 fixture substitution); neither is a compliance gap in this change.

---

### Policy-by-Policy Summary

#### General Code Change Policy (Section 2)
- PASS Before Making Changes: objective, plan, and policy order documented.
- PASS Design Principles: minimal fix converging on established repository pattern.
- PASS Module & File Structure: 350 / 486 lines, both under cap.
- PASS Naming, Docs, Comments: docstring and rationale comment corrected.
- PASS Toolchain Execution: single clean pass, all stages evidenced.
- PASS Summarize & Document: spec Outcome section complete.

#### Language-Specific Code Change Policy (Section 3)

**For PowerShell:**
- PASS Tooling & Baseline: format clean, 0 analyzer findings.
- PASS PowerShell Design & Safety: contracts and fail-closed semantics preserved.
- PASS Structure & Naming: unchanged surface, compliant sizes.
- PASS Toolchain: one iteration, no restart.

#### General Unit Test Policy (Section 1)
- PASS Core Principles: independent, isolated, fast, deterministic tests.
- PASS Coverage & Scenarios: positive, negative, edge, and error paths covered; no regression.
- PASS Test Structure: AAA with clear diagnostics.
- PASS External Dependencies: seams mocked; no temp files.
- PASS Policy Audit: this document.

#### Language-Specific Unit Test Policy (Section 4)

**For PowerShell:**
- PASS Framework & Scope: Pester v5 through PoshQC.
- PASS Test Style & Structure: behavior-focused, mirrored location.
- PASS Naming & Readability: compliant naming and grouping.
- PASS Toolchain: PoshQC test run green.

---

### Metrics Summary

- 1,347/1,347 non-skipped tests passing (100%)
- 90.22% line / 89.68% instruction coverage repo-wide (thresholds 85%)
- 92.16% line coverage on the changed hook; changed line fully covered
- All code quality checks passing (format, analyze, test, parity, evidence locations)
- Targeted reviewer re-verification: 40/40 tests, 7/7 parity pytest, both end-to-end hook runs reproduce the executor's results

---

### Recommendation

**Ready for merge.**

No remediation is required. The change is minimal, converges on the established repository pattern, preserves the completion gate's fail-closed property (independently re-verified), and removes an unconditional false-block from the documented DONE gate.

---

## Appendix A: Test Inventory

### Changed/added tests in this branch

1. validate-orchestrator-output.ps1 › routing-contract validation (Gap 1) › allows DONE when the validator exits 0 and prints its success line (issue #413) [NEW]
2. validate-orchestrator-output.ps1 › Invoke-RoutingContractValidation › reports no errors when the seam returns exit 0 with the validator success line (issue #413) [NEW, replaces defect-asserting test]
3. validate-orchestrator-output.ps1 › Invoke-RoutingContractValidation › reports HasErrors when the seam returns exit code 2 (argparse misuse / crash path stays fail-closed) [NEW]

### Pre-existing tests relied on as regression locks (all unmodified, all passing)

4. validate-orchestrator-output.ps1 › Invoke-RoutingContractValidation › reports HasErrors when the seam returns a non-zero exit code
5. validate-orchestrator-output.ps1 › Invoke-RoutingContractValidation › reports no errors when the seam returns exit 0 and empty output
6. validate-orchestrator-output.ps1 › routing-contract validation (Gap 1) › blocks DONE with ROUTING_CONTRACT_BLOCKED when the validator reports errors
7. validate-orchestrator-output.ps1 › routing-contract validation (Gap 1) › is mockable without invoking Python (the injected scriptblock is used)
8. validate-orchestrator-output.model-routing.Tests.ps1 › 6 tests covering MODEL_ROUTING_BLOCKED / ROUTING_CONTRACT_BLOCKED discrimination
9. OrchestratorStateCompletion.Tests.ps1 › 7 tests covering the portable fallback including three fail-closed condition tests

Reviewer re-run of files containing tests 1-9: 40 passed, 0 failed (2.15s).

---

## Appendix B: Toolchain Commands Reference

**For PowerShell:**
```powershell
# Formatting
Import-Module ./scripts/powershell/PoshQC; Invoke-PoshQCFormat -Root .

# Linting
Import-Module ./scripts/powershell/PoshQC; Invoke-PoshQCAnalyze -Root .

# Testing with coverage
Import-Module ./scripts/powershell/PoshQC; Invoke-PoshQCTest -Root .
```

**Cross-cutting verification (as run by this reviewer):**
```bash
# Branch diff scope
git diff --name-status 72126592..HEAD

# Bundle byte parity
sha256sum .claude/hooks/validate-orchestrator-output.ps1 extensions/drm-copilot/resources/claude-customizations/.claude/hooks/validate-orchestrator-output.ps1

# Bundle parity contract
poetry run python -m pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py -q

# Evidence locations
python scripts/dev_tools/validate_evidence_locations.py --root .

# Targeted Pester re-run
pwsh -NoLogo -NoProfile -Command "Invoke-Pester -Path tests/scripts/claude-hooks/validate-orchestrator-output.Tests.ps1, tests/scripts/claude-hooks/validate-orchestrator-output.model-routing.Tests.ps1, tests/scripts/claude-lib/orchestrator-state/OrchestratorStateCompletion.Tests.ps1"

# End-to-end ALLOW (fixture) and BLOCK (live checkpoint, read-only)
CLAUDE_HOOK_INPUT='{"output":"DONE: reviewer verification run (issue #413)."}' pwsh -NoLogo -NoProfile -File .claude/hooks/validate-orchestrator-output.ps1 -CheckpointPath docs/features/active/2026-07-25-orchestrator-completion-hook-false-block-413/evidence/other/completion-passing-checkpoint.2026-07-25T17-19.json
CLAUDE_HOOK_INPUT='{"output":"DONE: reviewer fail-closed verification (issue #413)."}' pwsh -NoLogo -NoProfile -File .claude/hooks/validate-orchestrator-output.ps1 -CheckpointPath artifacts/orchestration/orchestrator-state.json
```

---

**Audit Completed By:** feature-review agent (Claude)
**Audit Date:** 2026-07-25
**Policy Version:** Current (as of audit date)
