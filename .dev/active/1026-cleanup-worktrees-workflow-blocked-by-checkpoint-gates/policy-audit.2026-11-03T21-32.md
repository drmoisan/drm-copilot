# Policy Compliance Audit: Cleanup-Context Legs for the Checkpoint Gates (Issue #1026), Re-Audit After Remediation Cycle 1

---

**Audit Date:** 2026-11-03
**Branch:** `bug/cleanup-worktrees-workflow-blocked-by-checkpoint-gates-1026` at `5dc6b1aefdd0fb8b91d1a659329822364a409b5a`
**Base:** `main` (`origin/main` at `01706c697f3ad4a53b4a771d99d851afc7417ea9`); merge base `01706c697f3ad4a53b4a771d99d851afc7417ea9`
**Scope source:** `git diff 01706c697f3ad4a53b4a771d99d851afc7417ea9 HEAD` (129 files, +10039/-42) and `artifacts/pr_context.summary.txt` / `artifacts/pr_context.appendix.txt` (generated 2026-11-03 21:25:47 UTC at the same head SHA)
**Prior review set:** `policy-audit.2026-11-03T19-05.md`, `code-review.2026-11-03T19-05.md`, `feature-audit.2026-11-03T19-05.md`; cycle inputs `remediation-inputs.2026-11-03T19-13.md` (R1-1, R1-2, R1-3) and `remediation-plan.2026-11-03T19-13.md`
**Code Under Test:**
- New production (PowerShell): `.claude/hooks/hook-cleanup-context.ps1`, `.codex/hooks/hook-cleanup-context.ps1`, `.claude/hooks/enforce-orchestration-preimplementation-gate-cleanup.ps1`, `.codex/hooks/enforce-orchestration-preimplementation-gate-cleanup.ps1`, `.claude/hooks/enforce-pr-author-skill.cleanup.ps1`, and their five byte-identical bundle mirrors under `extensions/drm-copilot/resources/`.
- Modified production (PowerShell): `.claude/hooks/enforce-orchestration-preimplementation-gate.ps1`, `.codex/hooks/enforce-orchestration-preimplementation-gate.ps1`, `.claude/hooks/enforce-pr-author-skill-helpers.ps1`, `.claude/hooks/enforce-pr-author-skill.docs-only.ps1`, `.claude/hooks/enforce-model-routing-receipt.ps1`, and their bundle mirrors.
- Modified Markdown/JSON: `.claude/skills/cleanup-merged-worktrees/SKILL.md`, the six execution-environment brief copies, the cleanup skill bundle mirror, and the two `pack-manifests/core.json` files.
- Tests (PowerShell): 8 new suites and 26 modified suites/helpers under `tests/scripts/claude-hooks/` and `tests/scripts/codex-hooks/`.
- Cycle 1 delta (`904a862ab..HEAD`): `Get-OrchestrationCleanupContextResult` and the `DenySuffix` sub-codes in both gate-cleanup copies, the line-neutral gate call sites, `Get-PrAuthorCleanupPublishedHead` and the `CLEANUP_EXEMPTION_REMOTE_HEAD_MISMATCH` K6 check, one baseline mock block, skill step 4 and brief text, the `issue.md` Status line, tests, and mirrors.

**Coverage Metrics by Language:**

| Language | Files Changed | Tests | Test Result | Baseline Coverage | Post-Change Coverage | New Code Coverage |
|----------|--------------|-------|-------------|-------------------|---------------------|-------------------|
| PowerShell | 54 files (20 production incl. mirrors, 34 test) | 13910 tests | ✅ touched suites 1395/1395 pass (this review); full tree 409 failures, all pre-existing and outside the diff | 92.57% lines repo-wide (cycle baseline, same host) | 92.58% lines repo-wide | 90.32% lowest new file (range 90.32% to 98.44%) |
| JSON | 3 files | N/A | ✅ contract tests pass | N/A (config files) | N/A (config files) | N/A |
| Markdown | 72 files | N/A | ✅ SkillText suite and brief contract tests pass | N/A (documentation) | N/A (documentation) | N/A |
| Python | 0 files | N/A | N/A | N/A - no changed files | N/A - no changed files | N/A |
| TypeScript | 0 files | N/A | N/A | N/A - no changed files | N/A - no changed files | N/A |
| C# | 0 files | N/A | N/A | N/A - no changed files | N/A - no changed files | N/A |
| Bash | 0 files | N/A | N/A | N/A - no changed files | N/A - no changed files | N/A |

### Coverage Evidence Checklist

- TypeScript baseline coverage artifact: N/A - out of scope (zero changed TypeScript files on the branch)
- TypeScript post-change coverage artifact: N/A - out of scope (zero changed TypeScript files on the branch)
- PowerShell baseline coverage artifact: `docs/features/active/cleanup-worktrees-workflow-blocked-by-checkpoint-gates-1026/evidence/baseline/pester-coverage.2026-11-03T13-17.md` (merge-base figures) and `docs/features/active/cleanup-worktrees-workflow-blocked-by-checkpoint-gates-1026/evidence/remediation-baseline/pester-coverage.2026-11-03T19-56.md` (cycle baseline on the current host)
- PowerShell post-change coverage artifact: `artifacts/pester/powershell-coverage.xml` (JaCoCo, report stamp 2026-11-03 21:09:49 UTC), cross-checked against `artifacts/pester/parallel/shard-1/powershell-coverage.xml` through `shard-8/powershell-coverage.xml` (written 2026-11-03 21:17 to 21:19 UTC) and `docs/features/active/cleanup-worktrees-workflow-blocked-by-checkpoint-gates-1026/evidence/qa-gates/pester-coverage.2026-11-03T21-10.md`
- Per-language comparison summary: Section 1.2.1 below

**Coverage artifact note (assumption, documented):** the canonical file `artifacts/pester/powershell-coverage.xml` is present and was parsed by this review. Its per-file figures equal the figures recorded in `qa-gates/pester-coverage.2026-11-03T21-10.md` for all five cycle files. The only commit after the report stamp (5dc6b1aef) changed `enforce-pr-author-skill.Cleanup.Tests.ps1` and evidence files; the evidence states that this test edit preceded loop pass 2, and the single uncovered line of `enforce-pr-author-skill.cleanup.ps1` (line 72, the empty-array return of the segment-token helper) maps onto the committed HEAD content, while the catch lines that the edit was written to cover are reported covered. The worktree is clean (`git status --porcelain` empty). On this basis the artifact is treated as describing HEAD. The single-process run on this host is affected by a pre-existing PATH leak in `tests/scripts/dev-tools/run-actionlint.Tests.ps1` that breaks later suites starting `pwsh`. This lowers the Codex gate's single-process figure to 95.32% (lines 142, 363, 471-475, 491, 492, all entry-tail lines reached only through child-process integration suites). The shard union at the same tree gives the Codex gate 171/171 = 100%, equal to its merge-base figure, and every changed line of that file (33, 452, 453, 482) is covered in both artifacts.

---

## Executive Summary

The branch adds allow-side cleanup-context legs to three checkpoint gates (preimplementation gate on Claude and Codex, PR-author preflight, model-routing receipt gate) so the `cleanup-merged-worktrees` workflow can run from an agent session without an orchestrator checkpoint. Remediation cycle 1 closed the three carried review items: R1-1 (the PR-author exemption now requires `refs/remotes/origin/documentationandmemories` to equal the consolidation worktree `HEAD`), R1-2 (a consolidation-target denial in the preimplementation gate appends a `Cleanup leg not applied` sub-code), and R1-3 (`issue.md` Status path). Deny text for every non-consolidation target is unchanged.

**Policy documents evaluated:**
- ✅ `CLAUDE.md`, `.claude/rules/general-code-change.md`
- ✅ `.claude/rules/general-unit-test.md`, `.claude/rules/quality-tiers.md` (`quality-tiers.yml` exists on the base branch; every changed production file is under the T3 projects `.claude/hooks`, `.codex/hooks`, or `extensions/drm-copilot`; no new project was added, so no classification change is required)

**Language-specific policies evaluated:**
- N/A `python` rules: zero Python files changed; Python was used only to run existing contract tests and a read-only coverage parser in the session scratchpad.
- ✅ `.claude/rules/powershell.md` (PowerShell production and test files)
- N/A Bash: zero shell files changed on the branch.
- ✅ JSON: two pack manifests, unchanged in this cycle, validated by the push-down pack-manifest contract tests.

Toolchain (re-verified by this review at HEAD): Invoke-Formatter reports 0 of 54 changed PowerShell files would change; PSScriptAnalyzer with `scripts/powershell/PoshQC/settings/pssa.settings.psd1` reports 0 findings in 54 files; no type-check stage for PowerShell; the 38 touched suites run in one process with plain `Invoke-Pester` pass 1395/1395 with 0 failed containers. The recorded cycle evidence adds three seeded shuffles (1346/1346 each), a concurrent-shard run with 0 failures under the hook, runtime, and lib suites, and contract tests with generator exit 0. No blocking policy finding was identified.

**Temporary artifacts cleanup:**
- ✅ No temporary script is committed. The `SCRATCH/` launcher scripts named in evidence live in the session scratchpad outside the repository; `git status --porcelain` in the item worktree is empty.
- ✅ No ongoing tooling script was added.
- Scripts created during development: `SCRATCH/issue-1026-*.sh`, `.ps1`, and `.txt` program files (session scratchpad, not committed).

---

## Rejected Scope Narrowing

No narrowing was attempted. The caller prompt specified the full branch diff against the merge base; this audit uses that scope. The cycle 1 delta was read in detail, and the full branch diff was re-checked for toolchain, coverage, file size, mirror parity, and evidence locations.

## Evidence Location Compliance

- `python3 -I scripts/dev_tools/validate_evidence_locations.py --root <item worktree>` exited 0 with no reported paths.
- `git diff --name-only <merge base> HEAD` lists no file under `artifacts/baselines/`, `artifacts/qa/`, `artifacts/evidence/`, or `artifacts/coverage/`. All evidence is under `<FEATURE>/evidence/{baseline,other,qa-gates,regression-testing,remediation-baseline}/`.
- Result: PASS, zero violations.

---

## 1. General Unit Test Policy Compliance

### 1.1 Core Principles

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Independence** - Tests run in any order | ✅ PASS | `evidence/regression-testing/isolation-shuffle.2026-11-03T21-14.md`: seeds 1026, 20261103, 4242 over 36 suites, 1346/1346 passed each, file orders recorded. The concurrent-shard run (`isolation-parallel.2026-11-03T21-20.md`) reports 0 failures under `claude-hooks`, `codex-hooks`, `claude-runtime`, and `claude-lib`. |
| **Isolation** - Each test targets single behavior | ✅ PASS | Each new `It` names one condition (for example `denies a consolidation create when origin/documentationandmemories differs from HEAD with CLEANUP_EXEMPTION_REMOTE_HEAD_MISMATCH`). |
| **Fast Execution** - Tests complete quickly | ✅ PASS | The 38 touched suites (1395 tests) completed in one process in this review; no new test starts a real `git` process. |
| **Determinism** - Consistent results | ✅ PASS | The new seam `Get-PrAuthorCleanupPublishedHead` has a fail-closed baseline mock in `EpicStateIsolation.Baseline.Helpers.ps1` and is mocked per test; its real body is exercised with `Invoke-PrAuthorDocsOnlyGitExe` mocked per ref. No `TestDrive`, temporary file, sleep, or wall-clock read in added test lines. |
| **Readability & Maintainability** - Clear structure | ✅ PASS | Test names restate the sub-code and the condition; fixtures use POSIX roots. |

### 1.2 Coverage and Scenarios

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Baseline Coverage Documented** | ✅ PASS | Merge-base figures in `evidence/baseline/pester-coverage.2026-11-03T13-17.md`; cycle baseline 92.57% repo-wide and per-file figures for the five cycle files in `evidence/remediation-baseline/pester-coverage.2026-11-03T19-56.md`. |
| **No Coverage Regression** | ✅ PASS | Cycle files equal or higher than the cycle baseline: Claude gate 96.27% -> 96.27%; Codex gate 95.32% -> 95.32% single-process (100% in the shard union, equal to merge base); Claude gate-cleanup 97.89% -> 98.06%; Codex gate-cleanup 90.14% -> 90.32%; `enforce-pr-author-skill.cleanup.ps1` 98.08% -> 98.44%. Files not edited in the cycle are unchanged from the prior audit: PR-author helpers 97.73%, docs-only 98.18%, model routing 96.74%. No changed line in a modified file is uncovered. |
| **New Code Coverage >= 85% lines** | ✅ PASS | `hook-cleanup-context.ps1` 95/97 = 97.94% (both runtimes); Claude gate-cleanup 152/155 = 98.06%; Codex gate-cleanup 140/155 = 90.32%; `enforce-pr-author-skill.cleanup.ps1` 63/64 = 98.44%. No branch threshold applies to PowerShell. |
| **Comprehensive Coverage** | ✅ PASS | New cycle functions `Get-OrchestrationCleanupContextResult`, `Get-OrchestrationCleanupConsolidationWriteResult`, `Get-OrchestrationCleanupConsolidationCommandResult`, and `Get-PrAuthorCleanupPublishedHead` execute under test. Uncovered lines: Claude gate-cleanup 230, 260, 315; `enforce-pr-author-skill.cleanup.ps1` 72; `hook-cleanup-context.ps1` 232, 235; Codex gate-cleanup 15 lines (82-85, 88, 108, 226, 230, 260, 297, 315, 395, 456, 457, 480), covered in the byte-identical Claude copy. |
| **Positive Flows** - Valid inputs | ✅ PASS | Equal remote and HEAD allow for `gh pr create`; all prior allow cases unchanged. |
| **Negative Flows** - Invalid inputs | ✅ PASS | Absent remote ref, differing remote ref, throwing seam; non-allowlisted consolidation Write, non-allowlisted staged path, empty and unreadable staged index, each asserting its sub-code. |
| **Edge Cases** - Boundary conditions | ✅ PASS | Seam body: exit 1, throw, and non-commit output each yield an empty value; same Write beneath a non-consolidation worktree keeps the exact deny text. |
| **Error Handling** - Error paths | ✅ PASS | `Get-OrchestrationCleanupContextResult` returns `Allowed $false` with an empty suffix from its catch; K6 wraps the seam call in try/catch and fails closed. |
| **Concurrency** - If applicable | N/A | Hook decisions are single-call evaluations; no shared mutable state. |
| **State Transitions** - If applicable | ✅ PASS | The end-to-end suite walks the ten workflow steps with the published-head seam set equal. |

### 1.2.1 Per-Language Coverage Comparison

- PowerShell: Baseline: 92.57% lines repo-wide (cycle baseline on the same host; merge-base figure on the earlier host 93.62%) -> Post-change: 92.58% lines repo-wide. Change: +0.01% lines against the cycle baseline; every cycle file equal or higher, and every changed line in a modified file covered. New/changed-code coverage: 90.32% lowest new file (range 90.32% to 98.44%). Disposition: PASS. Evidence: `artifacts/pester/powershell-coverage.xml`, `artifacts/pester/parallel/shard-{1..8}/powershell-coverage.xml`, `evidence/remediation-baseline/pester-coverage.2026-11-03T19-56.md`, `evidence/qa-gates/pester-coverage.2026-11-03T21-10.md`.

### 1.3 Test Structure and Diagnostics

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Clear Failure Messages** | ✅ PASS | Deny cases assert the exact `PREIMPLEMENTATION_GATE_BLOCKED` text with or without the named suffix, and `ORCHESTRATOR_STATE_PREFLIGHT_FAILED` with the K-check sub-code. |
| **Arrange-Act-Assert Pattern** | ✅ PASS | Seams mocked in fixtures, one decision call, one assertion set. |
| **Document Intent** | ✅ PASS | Test names state the condition and sub-code; suite headers name issue #1026. |

### 1.4 External Dependencies and Environment

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Avoid External Dependencies** | ✅ PASS | No network, no real git process, no filesystem writes in new or changed tests. |
| **Use Mocks/Stubs** | ✅ PASS | Prior seams plus `Get-PrAuthorCleanupPublishedHead` and `Get-OrchestrationCleanupContextResult` (withheld-leg helpers). |
| **Environment Stability** | ✅ PASS | No test reads gitignored `artifacts/` state or `origin/main`. |

### 1.5 Policy Audit Requirement

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Pre-submission Review** | ✅ PASS | This document, with `code-review.2026-11-03T21-32.md` and `feature-audit.2026-11-03T21-32.md`. |

---

## 2. General Code Change Policy Compliance

### 2.1 Before Making Changes

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Clarify the objective** | ✅ PASS | Issue #1026; `spec.md` (full-bug); `remediation-inputs.2026-11-03T19-13.md` for the cycle. |
| **Read existing change plans** | ✅ PASS | `evidence/remediation-baseline/phase0-instructions-read.2026-11-03T19-30.md`; `existing-behavior-search.2026-11-03T19-32.md`. |
| **Document the plan** | ✅ PASS | `remediation-plan.2026-11-03T19-13.md`; 29 of 31 tasks checked. P0-T5 and P5-T3 are unchecked with recorded reasons: 8 suites outside `HOST_FAILURE_SUITES` fail in the single-process run because of the pre-existing PATH leak, identically at the cycle base, and pass 356/356 without the leaker. |

### 2.2 Design Principles

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Simplicity first** | ✅ PASS | The result object adds one field (`DenySuffix`); the Boolean wrapper keeps the old entry point. |
| **Reusability** | ✅ PASS | The published-head seam reuses `Invoke-PrAuthorDocsOnlyGitExe`. |
| **Extensibility** | ✅ PASS | `Test-OrchestrationCleanupContextAllowed` keeps its signature and Boolean return. |
| **Separation of concerns** | ✅ PASS | git I/O stays in named seams; the suffix rule is pure. |

### 2.3 Module & File Structure

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Cohesive modules** | ✅ PASS | Unchanged layout; no file added in the cycle. |
| **At or below the 800-line hard limit** | ✅ PASS | Logical line counts (`@(Get-Content).Count`) over all 54 added or modified covered files: largest `tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1` 506; helpers 499 (cap 500); Codex gate 493; Claude gate-cleanup 481; Claude gate 473. No file at or above 700. `config/file-size-baseline.json` is unchanged. |
| **Public vs internal** | ✅ PASS | Gate entry points unchanged. |
| **No circular dependencies** | ✅ PASS | No dot-source added in the cycle. |

### 2.4 Naming, Docs, and Comments

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Descriptive names** | ✅ PASS | `Get-OrchestrationCleanupContextResult`, `Get-PrAuthorCleanupPublishedHead`, sub-codes `CLEANUP_LEG_*` and `CLEANUP_EXEMPTION_REMOTE_HEAD_MISMATCH`. |
| **Docs/docstrings** | ✅ PASS | Comment-based help on every new or reshaped function; file headers list the sub-codes and the `DenySuffix` rule. |
| **Comment why, not what** | ✅ PASS | The header states why non-consolidation and prefilter rejections keep an empty suffix (byte-identical deny text). |

### 2.5 After Making Changes - Toolchain Execution

| Requirement | Status | Evidence |
|------------|--------|----------|
| **1. Formatting** | ✅ PASS | **Command:** Invoke-Formatter with `pssa.settings.psd1`, no write<br>**Result:** 0 of 54 changed (this review); `evidence/qa-gates/format.2026-11-03T20-44.md` |
| **2. Linting** | ✅ PASS | **Command:** `Invoke-ScriptAnalyzer -Settings scripts/powershell/PoshQC/settings/pssa.settings.psd1`<br>**Result:** 0 findings in 54 files (this review); `evidence/qa-gates/pssa.2026-11-03T20-44.md` |
| **3. Type checking** | N/A | Not applicable for PowerShell. |
| **4. Testing** | ✅ PASS | **Command:** `Invoke-Pester` over the 38 touched suites (this review); `Invoke-PoshQCTest -ScanFolders tests/scripts` (evidence)<br>**Result:** 1395/1395 passed; full tree failures identical per suite to the cycle baseline and outside the diff (`evidence/qa-gates/pester-coverage.2026-11-03T21-10.md`); contract tests pass (`evidence/qa-gates/contract-tests.2026-11-03T21-11.md`) |
| **Full toolchain loop** | ✅ PASS | Loop pass 1 found a coverage dip in `enforce-pr-author-skill.cleanup.ps1`; a test was added and the loop restarted at formatting (20-44); pass 2 met the coverage acceptance. |
| **Explicit reporting** | ✅ PASS | Commands, exit codes, and counts are in each evidence file. |

### 2.6 Summarize and Document

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Summarize changes** | ✅ PASS | Section 9; commit messages per phase. |
| **Design choices explained** | ✅ PASS | `spec.md` D1 to D11; remediation plan DR1 to DR4. |
| **Update supporting documents** | ✅ PASS | Cleanup skill step 4 and the execution-environment brief in all six copies (one SHA-256 across the six, verified in this review). |
| **Provide next steps** | ✅ PASS | Spec `## Rollout & Follow-up` records the post-merge live validation. |

---

## 3. Language-Specific Code Change Policy Compliance

### Section 3B: PowerShell Code Change Policy Compliance

#### 3B.1 Tooling & Baseline

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Formatting with Invoke-Formatter** | ✅ PASS | 0 of 54 files would change. |
| **Linting with PSScriptAnalyzer** | ✅ PASS | 0 findings. |
| **Fix all findings** | ✅ PASS | No findings to fix. |
| **PowerShell 5.1 & 7.6+ compatible** | ✅ PASS | Hooks declare PowerShell 7+ (repository hook convention); executed on PowerShell 7 on Linux; CI runs Windows and Linux hook jobs. |

#### 3B.2 PowerShell Design & Safety

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Advanced functions** | ✅ PASS | New and reshaped functions declare `[CmdletBinding()]` and `[OutputType([pscustomobject])]` or `[OutputType([bool])]`. |
| **Parameter validation** | ✅ PASS | `[AllowNull()][AllowEmptyString()]` on the seam and the result function. |
| **Avoid global state** | ✅ PASS | Only `$script:` literals. |
| **Error handling** | ✅ PASS | Never-throw result function and seam; K6 fails closed on a throw. |

#### 3B.3 Structure, Naming, and Comments

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Cohesive and at or below the 800-line hard limit** | ✅ PASS | Largest production file 499 lines. |
| **Approved verbs** | ✅ PASS | `Get-`, `Test-`, `Find-`, `ConvertTo-`, `ConvertFrom-` only. |
| **Comment why** | ✅ PASS | Headers explain the suffix rule and the push-before-create condition. |

#### 3B.4 Running the Toolchain

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Step 1: Format** | ✅ PASS | `evidence/qa-gates/format.2026-11-03T20-44.md`; re-run in this review |
| **Step 2: Analyze** | ✅ PASS | `evidence/qa-gates/pssa.2026-11-03T20-44.md`; re-run in this review |
| **Step 3: Type check** | N/A | Not applicable for PowerShell. |
| **Step 4: Test** | ✅ PASS | `evidence/qa-gates/pester-coverage.2026-11-03T21-10.md`, `evidence/regression-testing/isolation-shuffle.2026-11-03T21-14.md`; touched suites re-run in this review |
| **Rerun loop if needed** | ✅ PASS | Two loop passes recorded; the second met acceptance for coverage and analysis. |

### Section 3D: JSON Configuration Policy Compliance

#### 3D.1 JSON Tooling

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Formatting with jq** | N/A | Pack manifests follow repository convention; completeness contract tests govern them. |
| **Schema validation** | ✅ PASS | Pack-manifest completeness and dependency-closure contract tests pass; generator `--check` exit 0 (`qa-gates/contract-tests.2026-11-03T21-11.md`). |
| **Required $schema** | N/A | Pack manifests are not schema-governed files. |

#### 3D.2 JSON Structure

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Strict JSON only** | ✅ PASS | Unchanged in this cycle; string entries only. |
| **Deterministic key order** | ✅ PASS | Entries inserted into existing ordered lists. |

---

## 4. Language-Specific Unit Test Policy Compliance

### Section 4B: PowerShell Unit Test Policy Compliance

#### 4B.1 Framework and Scope

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Use Pester v5.x** | ✅ PASS | Pester 5 configuration objects; `Describe`/`Context`/`It`, `Should -BeExactly`. |
| **Use PoshQC Configuration** | ✅ PASS | `Invoke-PoshQCTest` and `Invoke-PoshQCParallelTest`; `config/poshqc-coverage.json` roots include `.claude/hooks` and `.codex/hooks`. |
| **PowerShell 5.1 & 7.6+ Compatible** | ✅ PASS | Suites run on PowerShell 7; CI matrix covers Windows and Linux. |

#### 4B.2 Test Style and Structure

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Focused Unit Tests** | ✅ PASS | Cycle adds 2 Claude gate, 2 Codex gate, 3 PR-author, and 2 skill-text `It` blocks. |
| **Test Behavior Over Implementation** | ✅ PASS | Assertions on decisions and reason text. |
| **Mocking Used Sparingly** | ✅ PASS | Only I/O seams and the withheld leg are mocked. |
| **Organization** | ✅ PASS | **Test files:** `tests/scripts/claude-hooks/*.Cleanup.Tests.ps1`, `tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-cleanup.Tests.ps1`<br>**Code files:** `.claude/hooks/...`, `.codex/hooks/...` |

#### 4B.3 Naming and Readability

| Requirement | Status | Evidence |
|------------|--------|----------|
| **File Naming** - *.Tests.ps1 | ✅ PASS | No suite added in the cycle; all suites end in `.Tests.ps1`. |
| **Describe/Context/It Structure** | ✅ PASS | `test-name-uniqueness.Tests.ps1` passes. |
| **Logical Grouping** | ✅ PASS | New tests sit beside the leg they extend. |
| **Docstrings/Comments** | ✅ PASS | Suite headers reference issue #1026. |

#### 4B.4 Running the Toolchain

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Use PoshQCTest Command** | ✅ PASS | **Command:** `Invoke-PoshQCTest -Root <item worktree> -ScanFolders tests/scripts`<br>**Result:** 13491 passed; 409 failed, identical per suite to the cycle baseline and outside the diff. |
| **No Alternative Test Runners** | ✅ PASS | Focused runs used `Invoke-Pester`; coverage evidence is from PoshQC. |

---

## 5. Test Coverage Detail

### enforce-orchestration-preimplementation-gate-cleanup.ps1 (32 Claude tests, 26 Codex tests)

| Test Name | Scenario Type | Lines Covered | Status |
|-----------|--------------|---------------|--------|
| `appends CLEANUP_LEG_PATH_NOT_ALLOWLISTED to the deny for a non-allowlisted Write inside the consolidation worktree` | Negative | 235-271 | ✅ |
| `keeps the exact deny text for the same Write beneath a non-consolidation worktree` | Negative/Edge Case | 235-266 | ✅ |
| `denies the commit when the staged index is empty or the staged-index seam fails` (five variants with sub-codes) | Error Handling | 378-395 | ✅ |
| `denies the commit when the staged index holds a non-allowlisted path` | Negative | 396-400 | ✅ |

**Coverage:** Claude 98.06% (152/155); Codex 90.32% (140/155). **Not covered (Claude):** 230, 260, 315.

### enforce-pr-author-skill.cleanup.ps1 (17 tests)

| Test Name | Scenario Type | Lines Covered | Status |
|-----------|--------------|---------------|--------|
| `denies a consolidation create when origin/documentationandmemories is missing with CLEANUP_EXEMPTION_REMOTE_HEAD_MISMATCH` (empty and throwing seam) | Negative/Error Handling | 167-174 | ✅ |
| `denies a consolidation create when origin/documentationandmemories differs from HEAD with CLEANUP_EXEMPTION_REMOTE_HEAD_MISMATCH` | Negative | 176-178 | ✅ |
| `resolves the published consolidation branch and HEAD through the bounded docs-only git seam` | Positive/Error Handling | 95-124 | ✅ |

**Coverage:** 98.44% (63/64). **Not covered:** line 72.

### hook-cleanup-context.ps1 and enforce-model-routing-receipt.ps1

Unchanged in the cycle: 97.94% (95/97) and 96.74% (89/92).

---

## 6. Test Execution Metrics

| Metric | Value | Status |
|--------|-------|--------|
| Total Tests | 13910 (single-process run); 1395 touched-suite tests re-run in this review | ✅ |
| Tests Passed | 1395/1395 touched; 13491 full tree | ✅ |
| Tests Failed | 0 touched; 409 full tree, pre-existing and outside the diff | ✅ |
| Execution Time | 1019.39s full tree | ✅ Acceptable for the full repository suite |
| Average Time per Test | about 73ms | ✅ Fast |
| Discovery Time | Not reported separately by the evidence | N/A |
| Functions/Classes Tested | 4/4 new cycle functions | ✅ |
| Test File Size | 483 logical lines largest edited suite | ✅ PASS |
| Code Coverage (if applicable) | 92.58% lines repo-wide; no branch metric for PowerShell | ✅ |

---

## 7. Code Quality Checks

**For PowerShell:**

| Check | Command | Result | Status |
|-------|---------|--------|--------|
| Invoke-Formatter | Invoke-Formatter, no write | 0 of 54 changed | ✅ |
| PSScriptAnalyzer | `Invoke-ScriptAnalyzer -Settings pssa.settings.psd1` | 0 findings | ✅ |
| Pester Tests | `Invoke-Pester` over 38 touched suites | 1395 passed, 0 failed | ✅ |

**Notes:** The full single-process run on this Linux host reports 409 failed tests: 89 in the 17 `HOST_FAILURE_SUITES` (Windows-specific fixtures) and the rest in 8 suites outside that set that are victims of the PATH leak in `tests/scripts/dev-tools/run-actionlint.Tests.ps1` (test `Add-DirectoryToPath handles paths with trailing separator`). None of those 25 suites or the leaker is in the branch diff, and the per-suite counts are identical at the cycle base. The concurrent-shard run, in which the leaker does not share a process with the victims, reports only the 89 host failures.

---

## 8. Gaps and Exceptions

### Identified Gaps
- Remediation-plan tasks P0-T5 and P5-T3 are unchecked because their acceptance requires zero failures outside `HOST_FAILURE_SUITES` in the single-process run, which the pre-existing PATH leak prevents. This is not a policy failure of the branch diff; it is recorded as a non-blocking Info finding in the code review with a recommendation to file the leak as a separate issue.
- The Windows CI shard jobs (`poshqc / PowerShell QC`) remain the full-scan confirmation at the CI gate.

### Approved Exceptions
**None.** No exceptions needed.

### Removed/Skipped Tests
**None.** All planned tests implemented. The 10 skipped tests in the full run are pre-existing platform skips outside the branch diff.

---

## 9. Summary of Changes

### Commits in This PR/Branch

1. **84fd40906** through **164e87e90** - promotion, reproduction, research, issue, spec, plan, preflight, phase 0 baselines
2. **c40e2e8a8**, **d9547f883**, **19aca847d**, **348b051ca**, **e482a3fd5** - shared predicates and the gate legs
3. **4d5bab186**, **b32225ecf**, **d4c7355b7**, **c65432ce9**, **a6277ccd9** - end-to-end suite, skill text, mirrors, plan revision, baseline mock
4. **ea62446b9**, **79244e2c4**, **0cc5fa237**, **29d98ff43** (merge of `origin/main`), **b12f4b25a**, **904a862ab** - evidence, QA, first review set
5. **c63581c7e** - fix(hooks): cleanup sub-code for consolidation-target preimplementation denials (R1-2)
6. **b91752230** - fix(hooks): published consolidation branch must equal HEAD for the PR-author exemption (R1-1)
7. **039bdc096** - docs(skills): published-head condition and the cleanup sub-code
8. **eb02e33ff** - chore(extension): bundle mirrors of the cycle changes
9. **5dc6b1aef** - test(hooks): throwing-seam coverage and the cycle 1 final QA records

### Files Modified

1. **`.claude/hooks/enforce-orchestration-preimplementation-gate-cleanup.ps1`** (NEW, plus three byte-identical copies) - result function with `DenySuffix`; Boolean wrapper retained.
2. **`.claude/hooks/enforce-pr-author-skill.cleanup.ps1`** (NEW, plus bundle copy) - K1 to K6 exemption with the published-head check.
3. **`.claude/hooks/hook-cleanup-context.ps1`** (NEW, plus three copies) - pure predicates (unchanged in the cycle).
4. **Gate files** (MODIFIED) - one guarded dot-source and one line-neutral call each; the reason concatenates the suffix.
5. **`.claude/hooks/enforce-model-routing-receipt.ps1`**, PR-author helpers, docs-only (MODIFIED) - unchanged in the cycle.
6. **Skill, brief, manifests, issue.md** (MODIFIED) - step 4 push-before-create text, brief sub-code sentence, Status path.
7. **Tests** (NEW/MODIFIED) - new sub-code and published-head tests; baseline mock block.

---

## 10. Compliance Verdict

### Overall Status: ✅ FULLY COMPLIANT

All policy requirements evaluated for the PowerShell, JSON, and Markdown changes pass. The gaps in Section 8 are pre-existing, outside the branch diff, and recorded with evidence.

---

### Policy-by-Policy Summary

#### General Code Change Policy (Section 2)
- ✅ Before Making Changes: spec, remediation inputs, and plan present
- ✅ Design Principles: result object with a Boolean wrapper
- ✅ Module & File Structure: all files at or below 506 lines
- ✅ Naming, Docs, Comments: help on every new function
- ✅ Toolchain Execution: format, analyze, test clean
- ✅ Summarize & Document: commits and evidence complete

#### Language-Specific Code Change Policy (Section 3)

**For PowerShell:**
- ✅ Tooling & Baseline: clean
- ✅ PowerShell Design & Safety: never-throw seams, fail-closed K6
- ✅ Structure & Naming: approved verbs
- ✅ Toolchain: two recorded passes, second clean

#### General Unit Test Policy (Section 1)
- ✅ Core Principles: shuffled and sharded runs clean for touched suites
- ✅ Coverage & Scenarios: all new files at or above 90.32%
- ✅ Test Structure: exact-text assertions
- ✅ External Dependencies: seams mocked, no temp files
- ✅ Policy Audit: this document

#### Language-Specific Unit Test Policy (Section 4)

**For PowerShell:**
- ✅ Framework & Scope: Pester 5 through PoshQC
- ✅ Test Style & Structure: focused cases
- ✅ Naming & Readability: names state sub-codes
- ✅ Toolchain: PoshQC

---

### Metrics Summary

- ✅ 1395/1395 touched-suite tests passing in this review
- ✅ 4/4 new cycle functions tested
- ✅ 92.58% line coverage repo-wide (PowerShell); new files 90.32% to 98.44%
- ✅ Test files under `tests/scripts/claude-hooks` and `tests/scripts/codex-hooks`
- ✅ Format, analysis, and contract checks passing
- ✅ Mirror parity: one SHA-256 per shared file group, verified in this review

---

### Recommendation

**Ready for merge** after the standard CI gate. File the `run-actionlint.Tests.ps1` PATH leak as a separate issue; it is unrelated to this diff.

---

## Appendix A: Test Inventory

New suites (from the initial implementation; counts at HEAD):

1. `tests/scripts/claude-hooks/hook-cleanup-context.Tests.ps1`
2. `tests/scripts/claude-hooks/hook-cleanup-context.Parity.Tests.ps1`
3. `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.Cleanup.Tests.ps1` (32 `It`)
4. `tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-cleanup.Tests.ps1` (26 `It`)
5. `tests/scripts/claude-hooks/enforce-pr-author-skill.Cleanup.Tests.ps1` (17 `It`)
6. `tests/scripts/claude-hooks/enforce-model-routing-receipt.Cleanup.Tests.ps1`
7. `tests/scripts/claude-hooks/cleanup-merged-worktrees-workflow.EndToEnd.Tests.ps1`
8. `tests/scripts/claude-hooks/cleanup-merged-worktrees.SkillText.Tests.ps1` (12 `It`)

Modified: 24 PR-author and model-routing suites (one manifest-seam line in the outermost `BeforeAll`), `EpicStateIsolation.Baseline.Helpers.ps1` (three seam mocks), `legacy-codex-hook-contracts.Tests.ps1` (`SharedModuleNames`), and two hook-consumer constant lists.

---

## Appendix B: Toolchain Commands Reference

**For PowerShell:**
```powershell
Import-Module ./scripts/powershell/PoshQC/PoshQC.psd1
Invoke-Formatter -ScriptDefinition <content> -Settings scripts/powershell/PoshQC/settings/pssa.settings.psd1
Invoke-ScriptAnalyzer -Path <file> -Settings scripts/powershell/PoshQC/settings/pssa.settings.psd1
Invoke-PoshQCTest -Root <item worktree> -ScanFolders tests/scripts
Invoke-PoshQCParallelTest -Root <item worktree>
```

**Reviewer commands (read-only):**
```text
git -C <item worktree> diff --stat 01706c697f3ad4a53b4a771d99d851afc7417ea9 HEAD
git -C <item worktree> diff 904a862ab HEAD -- .claude/hooks .codex/hooks
python3 -I scripts/dev_tools/validate_evidence_locations.py --root <item worktree>
per-file JaCoCo LINE parse of artifacts/pester/powershell-coverage.xml and union over shard files (scratchpad scripts)
logical line count, SHA-256 mirror parity, PSSA, and Invoke-Formatter over changed files (scratchpad script)
Invoke-Pester over the 38 touched suites, no coverage (scratchpad script)
```

---

**Audit Completed By:** feature-review agent
**Audit Date:** 2026-11-03
**Policy Version:** Current (as of audit date)
