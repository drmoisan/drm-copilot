# Policy Compliance Audit: Agent-payload gates resolve the call's target worktree (#690)

---

**Audit Date:** 2026-09-30
**Audit Type:** Re-audit after remediation pass 1 (prior audit: `policy-audit.2026-09-30T01-45.md`; remediation plan: `remediation-plan.2026-09-30T02-00.md`)
**Code Under Test:** Full branch diff `72d7ebbfda7dc6f1d6c5c321c1d01c00b8e4f8b4...268d635963e1a2d5f4a4eadb32abbc6b4508d969` (272 files; merge base equals the resolved `origin/main`). Production PowerShell (13 files, each mirrored under `extensions/drm-copilot/resources/claude-customizations/`):
- NEW: `.claude/lib/worktree-resolution/WorktreeRunResolution.psm1`, `.claude/hooks/enforce-epic-merge-gate-resolution.ps1`, `.claude/hooks/enforce-epic-worktree-removal-gate-resolution.ps1`
- MODIFIED: `.claude/lib/worktree-resolution/EpicScopeResolution.psm1`, `.claude/lib/worktree-resolution/WorktreeItemResolution.psm1`, `.claude/hooks/enforce-orchestration-preimplementation-gate.ps1`, `.claude/hooks/enforce-orchestration-preimplementation-gate-epic-scope.ps1`, `.claude/hooks/enforce-epic-wave-barrier.ps1`, `.claude/hooks/enforce-parallel-cohort-barrier.ps1`, `.claude/hooks/enforce-epic-merge-gate.ps1`, `.claude/hooks/enforce-epic-worktree-removal-gate.ps1`, `.claude/hooks/enforce-parallel-worktree-removal-gate.ps1`, `.claude/hooks/enforce-parallel-drift-gate.ps1`

PowerShell configuration: both `pester.runsettings.psd1` copies. PowerShell tests: 43 added or modified `*.Tests.ps1` suites and 1 new helper. Python: `tests/scripts/dev_tools/parallel_orchestrator_surface_expectations.py` (test-support constants). JSON: `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json`. Markdown: six `.claude/skills/*/SKILL.md` files and mirrors, feature documents, four potential entries, and evidence records.

Changes since the pass-1 audit (head `c47504ae`): remediation plan and evidence; CR-1 and CR-2 edits to `WorktreeRunResolution.psm1` and its mirror; rows B13 and T4; the potential entry `docs/features/potential/2026-09-30-worktree-run-resolution-review-nits.md`; and merge commit `268d6359`, which brought `origin/main` into the branch. The merge base therefore moved from `91805f15` to `72d7ebbf`.

**Coverage Metrics by Language:**

| Language | Files Changed | Tests | Test Result | Baseline Coverage | Post-Change Coverage | New Code Coverage |
|----------|--------------|-------|-------------|-------------------|---------------------|-------------------|
| PowerShell | 13 production (3 new, 10 modified) + 44 test files + 2 runsettings | 5430 across claude-hooks, claude-lib, claude-runtime, codex-hooks (reviewer, merged head); 5831 in the canonical PoshQC run (executor, pre-merge) | ✅ 5429 pass, 0 fail, 1 skipped (reviewer); 5831 total, 0 failures, 10 disabled (canonical JUnit) | 89.42%-100% lines per modified file (evidence/baseline/coverage-*.2026-09-29T23-11.md) | 96.23% lines repo-wide (10879/11305); 92.86%-100% lines per modified file | New files 100% / 88.89% / 95.65% lines; changed lines in modified files 93.94%-100% |
| Python | 1 file (test-support constants) | 5346 in the executor coverage run; 53 in the reviewer's targeted suites | ⚠️ 5339 pass, 1 fail, 6 skipped (executor); 52 pass, 1 fail (reviewer). The failing node is the pre-existing KL-510 node in both runs | 93.11% lines / 85.92% branches (derived: the branch changes no file in the coverage source; see 1.2.1) | 93.11% lines (15183/16307), 85.92% branches (5090/5924) | N/A - the changed file is test code outside the coverage source (`tests/*` is omitted) |
| JSON | 1 file (`core.json`) | N/A | ✅ registration entries present; manifest tests pass | N/A (config files) | N/A (config files) | N/A |

### Coverage Evidence Checklist

- TypeScript baseline coverage artifact: N/A - zero TypeScript files changed on the branch
- TypeScript post-change coverage artifact: N/A - zero TypeScript files changed on the branch
- PowerShell baseline coverage artifact: `docs/features/active/2026-09-17-agent-payload-gates-resolve-session-root-690/evidence/baseline/coverage-lib.2026-09-29T23-11.md` and the sibling `coverage-{pre,prem,erem,merge,wave,cohort,drift}.2026-09-29T23-11.md` records; remediation baseline `evidence/remediation-baseline/coverage-wrr.2026-09-30T02-05.md`
- PowerShell post-change coverage artifact: `artifacts/pester/powershell-coverage.xml` (generated 2026-09-30 02:22 UTC through the repository PoshQC module and runsettings) and `docs/features/active/2026-09-17-agent-payload-gates-resolve-session-root-690/evidence/qa-gates/powershell-coverage-artifact.2026-09-30T02-23.md`
- Python post-change coverage artifact: `artifacts/python/lcov.info` (generated 2026-09-30 02:07 UTC) and `docs/features/active/2026-09-17-agent-payload-gates-resolve-session-root-690/evidence/qa-gates/python-coverage.2026-09-30T02-07.md`
- Per-language comparison summary: section 1.2.1 below and `docs/features/active/2026-09-17-agent-payload-gates-resolve-session-root-690/evidence/qa-gates/remediation-coverage-comparison.2026-09-30T02-24.md`

---

## Executive Summary

The branch converts the in-scope PreToolUse gates from session-root-relative checkpoint reads to reads beneath a worktree resolved from portable identity, through the new module `WorktreeRunResolution.psm1`. Remediation pass 1 addressed every finding from the pass-1 audit:
- G-1 (the missing Python coverage artifact) is closed. `artifacts/python/lcov.info` exists and reports 93.11% line and 85.92% branch coverage.
- G-2 (the canonical PowerShell artifact omitting the three new files) is closed. The artifact now lists all three, each at or above 85%.
- Code-review items CR-1 and CR-2 were fixed, with fail-before and pass-after test evidence.

On the reviewer's re-run at the merged head, PowerShell formatting, analysis, tests, file-size limits, mirrors, registration, and coverage satisfy policy, and the Python toolchain is clean on the changed file. One item remains open, and it is not a policy defect. AC-44 names a Python test node that fails on this host only because of the gitignored `.claude/state/current-session-id` (KL-510, issue #510). That node failed identically at baseline, and no PR or CI run exists yet to confirm it.

**Policy documents evaluated:**
- ✅ `general-code-change.instructions.md` (via `.claude/rules/general-code-change.md`)
- ✅ `general-unit-test.instructions.md` (via `.claude/rules/general-unit-test.md`)
- ✅ `.claude/rules/quality-tiers.md` (uniform coverage thresholds)

**Language-specific policies evaluated:**
- ✅ `python-code-change.instructions.md` + `python-unit-test.instructions.md` (via `.claude/rules/python.md`, `.claude/rules/python-suppressions.md`)
- ✅ `powershell-code-change.instructions.md` + `powershell-unit-test.instructions.md` (via `.claude/rules/powershell.md`)
- N/A Bash: no shell files changed on the branch
- ✅ JSON: `core.json` edit inspected; manifest completeness tests pass

Reviewer-run results at head `268d6359`:
- Invoke-Formatter comparison and PSScriptAnalyzer (repository settings) over the 72 added or modified PowerShell files: 0 differences, 0 diagnostics, 0 files over 500 lines.
- Pester over `tests/scripts/claude-hooks`, `claude-lib`, `claude-runtime`, and `codex-hooks`: 5430 total, 5429 passed, 0 failed, 1 skipped, in 217 s.
- black, ruff, and pyright are clean on the changed Python file.
- Targeted Python parity and surface suites: 52 passed, 1 failed (the KL-510 node).
- Mirrors: 19/19 changed `.claude` files hash-equal to their bundle copies.
- `validate_evidence_locations.py --root .` exited 0.

**Template source:** the installed drm-copilot extension asset `resources/templates/policy_audit/policy-audit.yyyy-MM-ddTHH-mm.md`, which is the file the MCP template resolver serves. The MCP resolver was not available in this agent's tool list, so the installed asset was read directly. It differs from the repository copy only in the Bash section commands, which do not apply to this branch and are omitted here. The code-review and feature-audit assets are hash-equal to their repository copies.

**Temporary artifacts cleanup:**
- ✅ All temporary/one-time scripts created during development have been deleted (the executor's scratch scripts lived in the session scratchpad; `git status --porcelain` at the head showed only this review's artifacts)
- ✅ Any ongoing tooling scripts are fully tested and compliant with repo policies (no tooling script was added)
- Reviewer scratch scripts (coverage parse, format/analyze check, Pester runner, Python checks, validator wrapper) were written to the session scratchpad only and are not part of the branch.

### Rejected Scope Narrowing

No scope-narrowing instruction was detected in the caller prompt. The caller described this run as a "re-audit after remediation pass 1" and supplied the base branch, merge base, feature folder, PR context paths, and AC source, all of which match the authoritative sources. The audit covers the full feature-vs-base diff (272 files), not only the remediation commits.

### Evidence Location Compliance

- `poetry run python scripts/dev_tools/validate_evidence_locations.py --root .` exited 0 with no reported paths.
- `git diff --name-only 72d7ebbf...HEAD -- artifacts` returned 0 files. The branch diff contains no file under `artifacts/baselines/`, `artifacts/qa/`, `artifacts/evidence/`, or `artifacts/coverage/`. The remediation evidence is under `<FEATURE>/evidence/{remediation-baseline,qa-gates,regression-testing}/`.
- Verdict: PASS. No `EVIDENCE_LOCATION_OVERRIDE_REJECTED` record was required.

### Rule: modified-workflow-needs-green-run

The branch diff modifies no path under `.github/workflows/**`, `scripts/benchmarks/**`, or `.github/actions/**` (`git diff --name-only 72d7ebbf...HEAD -- .github/workflows .github/actions scripts/benchmarks` returned 0). The rule does not fire. Verdict: N/A.

### Coverage Verification (per language with changed files)

| Language | Changed files on branch | Artifact | Verdict | Reason |
|---|---|---|---|---|
| PowerShell | 13 production, 44 test, 2 config | `artifacts/pester/powershell-coverage.xml` | PASS | Repo-wide 96.23% lines (10879/11305) >= 85%. New files: `WorktreeRunResolution.psm1` 149/149 = 100%, `enforce-epic-merge-gate-resolution.ps1` 32/36 = 88.89%, `enforce-epic-worktree-removal-gate-resolution.ps1` 22/23 = 95.65%, all read from the canonical artifact. Modified files: 92.86%-100%, each at or above its baseline. Changed executable lines in modified files: 93.94%-100%. No branch threshold applies to Pester. |
| Python | 1 (test-support) | `artifacts/python/lcov.info` | PASS | Repo-wide (configured source `src` + `scripts/dev_tools`; `src/` holds no Python) 93.11% lines >= 85% and 85.92% branches >= 75%. The reviewer's independent lcov parse reproduced both figures. The changed file is under `tests/`, which `[tool.coverage.run] omit` excludes, so no per-file threshold applies. |
| TypeScript | 0 | `coverage/lcov.info` | N/A | Zero changed TypeScript files. |
| C# | 0 | `artifacts/csharp/coverage.xml` | N/A | Zero changed C# files. |

Artifact freshness: both coverage artifacts predate merge commit `268d6359` (02:26:58 UTC). The PowerShell artifact was generated at 02:22 UTC, after the last production PowerShell commit `5e783d51` (02:12 UTC); the Python artifact was generated at 02:07 UTC. The merge changed none of the branch's production or test files (verified with `git diff --name-only 973e8bfc 268d6359` restricted to those paths), so the per-file figures above still describe the merged head. The repo-wide figures describe the pre-merge tree. The merge introduced 11 `scripts/dev_tools` Python files and 27 production PowerShell files from `main`; their coverage belongs to `main`'s own review. Per the review contract, coverage was not regenerated.

Threshold note: the review contract's verification procedure cites 90% for new files and 80% repo-wide. Its threshold section and `.claude/rules/quality-tiers.md` (Authoritative Decision #2) set a uniform 85% line / 75% branch threshold. This audit applies the 85% rule, which the repository names as authoritative. Under the older 90% figure, `enforce-epic-merge-gate-resolution.ps1` (88.89%) would not meet the new-file threshold. This discrepancy is carried in section 8 as G-4.

---

## 1. General Unit Test Policy Compliance

### 1.1 Core Principles

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Independence** - Tests run in any order | ✅ PASS | Mocks are set in `BeforeAll`/`BeforeEach` or inside the `It`; row T4 restores `[Console]::Error` in `finally`. The four trees passed together (5429/5430, 1 skip). |
| **Isolation** - Each test targets single behavior | ✅ PASS | B13 asserts one resolver outcome; T4 asserts one seam outcome. Pass-1 suites unchanged in structure. |
| **Fast Execution** - Tests complete quickly | ✅ PASS | 5430 rows in 217 s (about 40 ms per row). |
| **Determinism** - Consistent results | ✅ PASS | Synthetic roots; mocked enumeration and read seams; B13 and T4 use no clock, environment, or host worktree state. |
| **Readability & Maintainability** - Clear structure | ✅ PASS | Stable row IDs; B13 and T4 follow the suites' Arrange-Act-Assert comments. Code review CR-10 notes one dense Act line in T4 (Nit). |

### 1.2 Coverage and Scenarios

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Baseline Coverage Documented** | ✅ PASS | **Baseline (pre-development):** WIR 96.23%, ESR 89.42%, PRE 93.42%, PRES 100%, WAVE 98.9%, COH 98.48%, MRG 96.67%, EREM 95.24%, PREM 93.41%, DRIFT 99.04% lines<br>**Remediation baseline:** WRR 100% (`evidence/remediation-baseline/coverage-wrr.2026-09-30T02-05.md`)<br>**Timestamp:** 2026-09-29 23:11 UTC; 2026-09-30 02:05 UTC |
| **No Coverage Regression** | ✅ PASS | **Post-change (canonical artifact):** WIR 99.06%, ESR 92.86%, PRE 96.73%, PRES 100%, WAVE 99.01%, COH 98.68%, MRG 96.8%, EREM 95.41%, PREM 93.46%, DRIFT 99.12%, WRR 100% lines<br>**Status:** every modified file is at or above its baseline. |
| **New Code Coverage >= 85%** | ✅ PASS | **New files (canonical artifact):** WRR 149/149 = 100%; merge-gate resolution sibling 32/36 = 88.89%; removal-gate resolution sibling 22/23 = 95.65%<br>**Changed lines in modified files:** 93.94%-100% (reviewer parse against `git diff -U0 72d7ebbf HEAD`). Uncovered changed lines: `enforce-parallel-worktree-removal-gate.ps1` lines 54 and 105. Remediation changed lines in WRR: 5/5 covered (`remediation-changed-line-coverage.2026-09-30T02-24.md`). |
| **Comprehensive Coverage** | ✅ PASS | Every function of `WorktreeRunResolution.psm1` is exercised (100% lines). Each converted gate has resolution, NoTarget, Ambiguous, and import-failure rows. |
| **Positive Flows** - Valid inputs | ✅ PASS | Other-worktree allow rows per gate; single-match resolver rows. |
| **Negative Flows** - Invalid inputs | ✅ PASS | Missing identity lines; blank, non-digit, and (new) out-of-range `pr_number` values (B13); malformed checkpoints. |
| **Edge Cases** - Boundary conditions | ✅ PASS | 20-digit `pr_number` beyond the 64-bit range (B13); trailing full stop; one-element JSON array; separator variants; stale session-root copy. |
| **Error Handling** - Error paths | ✅ PASS | Import-failure rows per gate; unreadable checkpoint returns `$null` with a stderr diagnostic (T4). |
| **Concurrency** - If applicable | N/A | Hooks run as single-shot processes; no shared mutable state is introduced. |
| **State Transitions** - If applicable | ✅ PASS | Resolver statuses NoTarget, SessionRoot, OtherWorktree, and Ambiguous are each asserted. |

### 1.2.1 Per-Language Coverage Comparison

- PowerShell: Baseline: 89.42%-100% lines per modified file (lowest ESR 89.42%); WRR remediation baseline 100%. Post-change: 92.86%-100% lines per modified file; 96.23% lines repo-wide; WRR 100%. Change: every modified file equal or higher (PRE +3.31 points, ESR +3.44 points); repo-wide 96.21% at pass 1 to 96.23%. New/changed-code coverage: 93.94%-100% changed lines in modified files; new files 100%, 88.89%, 95.65%; remediation changed lines 100%. Disposition: PASS. Evidence: `artifacts/pester/powershell-coverage.xml`; `docs/features/active/2026-09-17-agent-payload-gates-resolve-session-root-690/evidence/qa-gates/powershell-coverage-artifact.2026-09-30T02-23.md`; `docs/features/active/2026-09-17-agent-payload-gates-resolve-session-root-690/evidence/qa-gates/remediation-coverage-comparison.2026-09-30T02-24.md`.
- Python: Baseline: 93.11% lines / 85.92% branches, derived. No pre-change Python coverage run was recorded, but the branch changes no file in the coverage source (`scripts/dev_tools`, `src`), so the measured production code at the pre-merge head is identical to the old merge base `91805f15`. Post-change: 93.11% lines (15183/16307), 85.92% branches (5090/5924). Change: none attributable to the branch (0 production files changed). New/changed-code coverage: N/A (one test-support file changed; `tests/*` is omitted from measurement). Disposition: PASS. Evidence: `artifacts/python/lcov.info`; `docs/features/active/2026-09-17-agent-payload-gates-resolve-session-root-690/evidence/qa-gates/python-coverage.2026-09-30T02-07.md`; `docs/features/active/2026-09-17-agent-payload-gates-resolve-session-root-690/evidence/qa-gates/python-coverage-run.2026-09-30T02-07.md`.

### 1.3 Test Structure and Diagnostics

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Clear Failure Messages** | ✅ PASS | `Should -Invoke ... -Times 0 -Exactly` (B13) and `Should -Match 'WORKTREE_RUN_CHECKPOINT_UNREADABLE'` (T4) name the expected behaviour. |
| **Arrange-Act-Assert Pattern** | ✅ PASS | B13 and T4 carry explicit Arrange, Act, and Assert comments. |
| **Document Intent** | ✅ PASS | Row names state scenario and outcome, for example "B13 resolves NoTarget for a pull request value too large for a 64-bit integer without enumerating live roots". |

### 1.4 External Dependencies and Environment

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Avoid External Dependencies** | ✅ PASS | No git, network, or process calls in tests; enumeration is mocked. |
| **Use Mocks/Stubs** | ✅ PASS | T4 mocks `Test-Path` inside the module so an existing directory reaches `ReadAllText`; no file is created. |
| **Environment Stability** | ✅ PASS | Added test lines contain no `TestDrive`, `New-TemporaryFile`, `Set-Content`, `Out-File`, `New-Item`, `Remove-Item`, `Start-Sleep`, or `$env:`. |

### 1.5 Policy Audit Requirement

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Pre-submission Review** | ✅ PASS | This re-audit is the required review. The one open item (AC-44) depends on a CI run, and no branch change can address it. |

---

## 2. General Code Change Policy Compliance

### 2.1 Before Making Changes

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Clarify the objective** | ✅ PASS | `issue.md`, `spec.md` (63 criteria), `user-story.md`, research record; remediation inputs define RF-1 to RF-4. |
| **Read existing change plans** | ✅ PASS | `remediation-plan.2026-09-30T02-00.md` P0-T1 to P0-T4; `evidence/remediation-baseline/phase0-instructions-read.*`. |
| **Document the plan** | ✅ PASS | Remediation plan with every task checked; eight remediation commits with scoped messages. |

### 2.2 Design Principles

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Simplicity first** | ✅ PASS | CR-1 adds a two-line guard; CR-2 replaces one line with a comment and a two-line try/catch. |
| **Reusability** | ✅ PASS | Unchanged from pass 1; the remediation adds no new helper. |
| **Extensibility** | ✅ PASS | No signature change. |
| **Separation of concerns** | ✅ PASS | The only filesystem read remains in `Get-WorktreeRunCheckpointText`. |

### 2.3 Module & File Structure

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Cohesive modules** | ✅ PASS | Unchanged from pass 1. |
| **Under 500 lines** | ✅ PASS | Reviewer check: 0 of 72 changed PowerShell files exceed 500 lines. The largest are `WorktreeRunResolution.psm1` (497, and its mirror) and `enforce-epic-worktree-removal-gate.Tests.ps1` (497). Code review CR-11 records the 3-line headroom. |
| **Public vs internal** | ✅ PASS | Seven explicit exports, unchanged. |
| **No circular dependencies** | ✅ PASS | Unchanged. |

### 2.4 Naming, Docs, and Comments

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Descriptive names** | ✅ PASS | `$isNumber`, `$parsedNumber`; the token `WORKTREE_RUN_CHECKPOINT_UNREADABLE`. |
| **Docs/docstrings** | ✅ PASS | Synopsis (line 102) and description (line 413) updated to match the new behaviour. |
| **Comment why, not what** | ✅ PASS | Line 116 states why the catch writes to stderr and returns `$null`. |

### 2.5 After Making Changes - Toolchain Execution

| Requirement | Status | Evidence |
|------------|--------|----------|
| **1. Formatting** | ✅ PASS | **Command:** `Invoke-Formatter -Settings scripts/powershell/PoshQC/settings/pssa.settings.psd1` comparison per changed file; `poetry run black --check <py file>`<br>**Result:** 0 of 72 files differ; 1 Python file left unchanged |
| **2. Linting** | ✅ PASS | **Command:** `Invoke-ScriptAnalyzer -Settings scripts/powershell/PoshQC/settings/pssa.settings.psd1`; `poetry run ruff check <py file>`<br>**Result:** 0 diagnostics; All checks passed |
| **3. Type checking** | ✅ PASS | **Command:** `poetry run pyright <py file>`<br>**Result:** 0 errors, 0 warnings, 0 informations. N/A for PowerShell. |
| **4. Testing** | ✅ PASS | **Command:** Pester over four trees; `poetry run pytest` targeted suites<br>**Result:** PowerShell 0 failures; Python 1 failure, the pre-existing KL-510 node recorded in section 8 |
| **Full toolchain loop** | ✅ PASS | Executor remediation loop: `remediation-format.2026-09-30T02-24.md` (ChangedCount=0, hashes equal, clean tree), `remediation-analyze.2026-09-30T02-24.md` (DiagnosticCount=0), `remediation-coverage-wrr.2026-09-30T02-24.md` (254/254). The canonical PoshQC run reported 0 failures. The reviewer reproduced a clean pass at the merged head. |
| **Explicit reporting** | ✅ PASS | Commands and results recorded under `evidence/qa-gates/` and in Appendix B. |

### 2.6 Summarize and Document

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Summarize changes** | ✅ PASS | Commit messages and section 9. |
| **Design choices explained** | ✅ PASS | Remediation plan Appendix B explains why the diagnostic goes to stderr rather than `Write-Warning`. |
| **Update supporting documents** | ✅ PASS | Follow-up potential entry for CR-4 and CR-5. |
| **Provide next steps** | ✅ PASS | Section 10 Recommendation. |

---

## 3. Language-Specific Code Change Policy Compliance

---

### Section 3A: Python Code Change Policy Compliance (if applicable)

#### 3A.1 Tooling & Baseline

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Formatting with Black** | ✅ PASS | **Command:** `poetry run black --check tests/scripts/dev_tools/parallel_orchestrator_surface_expectations.py`<br>**Result:** 1 file would be left unchanged |
| **Linting with Ruff** | ✅ PASS | **Command:** `poetry run ruff check tests/scripts/dev_tools/parallel_orchestrator_surface_expectations.py`<br>**Result:** All checks passed |
| **Type checking with Pyright** | ✅ PASS | **Command:** `poetry run pyright tests/scripts/dev_tools/parallel_orchestrator_surface_expectations.py`<br>**Result:** 0 errors, 0 warnings, 0 informations |
| **Testing with Pytest** | ✅ PASS | **Command:** `poetry run pytest --cov=scripts.dev_tools --cov-branch --cov-report=term-missing` (executor); `poetry run pytest -q -rf --no-cov <four suites>` (reviewer)<br>**Result:** executor 5339 passed, 1 failed, 6 skipped; reviewer 52 passed, 1 failed. The single failure in both runs is `test_bundled_claude_payload_contains_all_repo_runtime_contracts`, caused by the gitignored `.claude/state/current-session-id` and identical at baseline. This is recorded as exception E-1 in section 8, not as a branch defect. |

#### 3A.2 Python Design & Typing

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Strong typing** | ✅ PASS | Data-only change; no annotation change. |
| **Dataclasses for value objects** | N/A | No new types. |
| **Protocols/ABCs for interfaces** | N/A | No new interfaces. |
| **Avoid utility classes** | N/A | No new classes. |

#### 3A.3 Python Error Handling

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Specific exceptions** | N/A | No executable change. |
| **Logging over print** | N/A | No executable change. |
| **Invariants at construction** | N/A | No executable change. |

---

### Section 3B: PowerShell Code Change Policy Compliance (if applicable)

#### 3B.1 Tooling & Baseline

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Formatting with Invoke-Formatter** | ✅ PASS | **Command:** Invoke-Formatter comparison with `pssa.settings.psd1` over 72 files<br>**Result:** 0 files differ |
| **Linting with PSScriptAnalyzer** | ✅ PASS | **Command:** `Invoke-ScriptAnalyzer -Path <file> -Settings scripts/powershell/PoshQC/settings/pssa.settings.psd1`<br>**Result:** 0 diagnostics |
| **Fix all findings** | ✅ PASS | No findings to fix. |
| **PowerShell 7+ compatible** | ✅ PASS | Repository analyzer settings enforce PowerShell 7+ compatibility; tests ran under PowerShell 7. |

#### 3B.2 PowerShell Design & Safety

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Advanced functions** | ✅ PASS | Unchanged; all functions use `[CmdletBinding()]` and `[OutputType()]`. |
| **Parameter validation** | ✅ PASS | `pr_number` now requires `^\d+$` and a successful `[long]::TryParse` (CR-1). |
| **Avoid global state** | ✅ PASS | No new script-scoped state. T4 changes the process error stream only inside `try`/`finally`. |
| **Error handling** | ✅ PASS | CR-2 closed: the read-seam catch reports on stderr and returns `$null` (fail-closed). |

#### 3B.3 Structure, Naming, and Comments

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Cohesive and under 500 lines** | ✅ PASS | Max 497 lines (reviewer check). |
| **Approved verbs** | ✅ PASS | No new function; PSScriptAnalyzer `PSUseApprovedVerbs` reports none. |
| **Comment why** | ✅ PASS | See section 2.4. |

#### 3B.4 Running the Toolchain

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Step 1: Format** | ✅ PASS | Executor MCP format: hashes unchanged, ChangedCount=0; reviewer comparison: 0 differences. |
| **Step 2: Analyze** | ✅ PASS | Executor MCP analyze: DiagnosticCount=0; reviewer run: 0. |
| **Step 3: Type check** | N/A | Not applicable for PowerShell. |
| **Step 4: Test** | ✅ PASS | Canonical PoshQC run through the repository module: 5831 tests, 0 failures. Reviewer Pester at the merged head: 0 failures. |
| **Rerun loop if needed** | ✅ PASS | The remediation loop (P5-T1 to P5-T5) completed without a restart. |

---

### Section 3D: JSON Configuration Policy Compliance (if applicable)

#### 3D.1 JSON Tooling

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Formatting** | ✅ PASS | Branch entries follow the existing array style. The merge added main's entries alongside them without conflict. `test_push_down_claude_pack_manifest_completeness.py` passes. |
| **Schema validation** | ✅ PASS | Manifest completeness and `WorktreeResolution.Manifest.Tests.ps1` (19/19) pass. |
| **Required $schema** | N/A | `core.json` is a pack manifest not governed by the `$schema` rule. |

#### 3D.2 JSON Structure

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Strict JSON only** | ✅ PASS | Plain string entries; no comments or trailing commas. |
| **Deterministic key order** | N/A | Array entries only. |

---

## 4. Language-Specific Unit Test Policy Compliance

---

### Section 4A: Python Unit Test Policy Compliance (if applicable)

#### 4A.1 Framework and Scope

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Use Pytest** | ✅ PASS | Surface-contract tests consume the pin through Pytest. |
| **Coverage expectation** | ✅ PASS | 93.11% lines and 85.92% branches from `artifacts/python/lcov.info`, reproduced by the reviewer's lcov parse. |

#### 4A.2 Test Style and Structure

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Focused unit tests** | N/A | No Python test logic changed. |
| **Mocking sparingly** | N/A | No Python test logic changed. |
| **Organization** | ✅ PASS | The changed file stays in `tests/scripts/dev_tools/`. |

#### 4A.3 Naming and Readability

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Naming conventions** | N/A | No test added. |
| **Docstrings/comments** | N/A | No test added. |

#### 4A.4 Running the Toolchain

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Use Pytest** | ✅ PASS | **Command:** `poetry run pytest -q -rf --no-cov <four suites>`<br>**Result:** 52 passed, 1 failed (KL-510, exception E-1) |
| **No Alternative Test Runners** | ✅ PASS | Pytest only. |

---

### Section 4B: PowerShell Unit Test Policy Compliance (if applicable)

#### 4B.1 Framework and Scope

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Use Pester v5.x** | ✅ PASS | `BeforeAll`, `Describe`/`It`, `Should -Invoke`, `Mock -ModuleName`. |
| **Use PoshQC Configuration** | ✅ PASS | **Config:** `scripts/powershell/PoshQC/settings/pester.runsettings.psd1` lists the three new production files; the two copies are hash-equal after the merge (`cf9fa2f1...`). |
| **PowerShell 7+ Compatible** | ✅ PASS | Ran under PowerShell 7. |

#### 4B.2 Test Style and Structure

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Focused Unit Tests** | ✅ PASS | B13 and T4 each target one outcome. |
| **Test Behavior Over Implementation** | ✅ PASS | B13 asserts status, reason code, and that enumeration was not reached; T4 asserts the return value and the diagnostic. |
| **Mocking Used Sparingly** | ✅ PASS | T4 adds one module-scoped `Test-Path` mock. |
| **Organization** | ✅ PASS | **Test files:** `tests/scripts/claude-lib/worktree-resolution/WorktreeRunResolution*.Tests.ps1` for `.claude/lib/worktree-resolution/WorktreeRunResolution.psm1`; `tests/scripts/claude-hooks/<hook>.WorktreeResolution.Tests.ps1` for `.claude/hooks/<hook>.ps1`. |

#### 4B.3 Naming and Readability

| Requirement | Status | Evidence |
|------------|--------|----------|
| **File Naming** - *.Tests.ps1 | ✅ PASS | All suites end in `.Tests.ps1`; the helper holds no tests. |
| **Describe/Context/It Structure** | ✅ PASS | B13 sits in `Describe 'Resolve-WorktreeRunTargetByRecord'`; T4 sits in `Describe 'Get-WorktreeRunCheckpointText'`. |
| **Logical Grouping** | ✅ PASS | Unchanged from pass 1. |
| **Docstrings/Comments** | ✅ PASS | Arrange, Act, and Assert comments in both new rows. |

#### 4B.4 Running the Toolchain

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Use PoshQCTest Command** | ✅ PASS | **Command:** `Invoke-PoshQCTest -SettingsPath scripts/powershell/PoshQC/settings/pester.runsettings.psd1` (executor, repository module); reviewer ran Pester 5 directly in check-only mode<br>**Result:** 0 failures in both |
| **No Alternative Test Runners** | ✅ PASS | Pester only. |

---

## 5. Test Coverage Detail

### WorktreeRunResolution.psm1 (67 rows: 65 from pass 1 plus B13 and T4)

| Test Name | Scenario Type | Lines Covered | Status |
|-----------|--------------|---------------|--------|
| Signal S1-S9 and read seam T1-T4 (17 rows) | Positive/Negative/Edge Case/Error Handling | 47-120 | ✅ |
| Resolution E1-E15, R1-R7 (22 rows) | Positive/Negative/Edge Case | 175-340 | ✅ |
| Record B1-B13, X1-X2, C1-C2, U1-U3 (28 rows) | Positive/Negative/Edge Case/Error Handling | 342-488 | ✅ |

**Coverage:** 100% of the module (149/149 analysed lines in the canonical artifact).

**Not covered:** None.

---

### Converted gates (73 rows in new suites)

| Test Name | Scenario Type | Lines Covered | Status |
|-----------|--------------|---------------|--------|
| Preimplementation WorktreeResolution R1-R15 (15) | Positive/Negative/Edge Case | resolution and read glue in the epic-scope sibling | ✅ |
| Preimplementation OperandResolution (10) | Positive/Negative | path and `git -C` legs | ✅ |
| Wave barrier (9), cohort barrier (7), drift gate (6) | Positive/Negative/Error Handling | resolution seam, deny paths, import guard | ✅ |
| Merge gate (10) | Positive/Negative/Error Handling | `enforce-epic-merge-gate-resolution.ps1` and gate changes | ✅ |
| Epic removal (6), parallel removal (6) | Positive/Negative/Error Handling | record resolution by `worktree_path` | ✅ |
| EpicScopeResolution RunTarget (4) | Positive/Negative | `Resolve-EpicScopeCheckpoint` resolution | ✅ |

**Coverage:** modified gate files 92.86%-100% lines; changed executable lines 93.94%-100% (canonical artifact).

**Not covered:** `enforce-parallel-worktree-removal-gate.ps1` lines 54 and 105; `enforce-epic-merge-gate-resolution.ps1` lines 35, 182, 186, 213; `enforce-epic-worktree-removal-gate-resolution.ps1` line 32 (reviewer parse of the canonical artifact).

---

## 6. Test Execution Metrics

| Metric | Value | Status |
|--------|-------|--------|
| Total Tests | 5430 PowerShell (reviewer, four trees, merged head); 5831 PowerShell (canonical PoshQC run, pre-merge); 53 Python targeted; 5346 Python repository (executor) | ✅ |
| Tests Passed | 5429 PowerShell (reviewer); 5831 with 10 disabled (canonical); 52 Python targeted; 5339 Python repository | ✅ |
| Tests Failed | 0 PowerShell; 1 Python (KL-510, exception E-1) | ⚠️ |
| Execution Time | 217 s (reviewer PowerShell); 571.66 s (canonical PoshQC run) | ✅ Fast |
| Average Time per Test | about 40 ms | ✅ Fast |
| Discovery Time | Not separately measured | ✅ |
| Functions/Classes Tested | All functions of `WorktreeRunResolution.psm1` | ✅ |
| Test File Size | Largest changed suite 497 lines | ✅ Maintainable |
| Code Coverage (if applicable) | 96.23% lines PowerShell repo-wide; Python 93.11% lines / 85.92% branches | ✅ |

---

## 7. Code Quality Checks

**For Python:**

| Check | Command | Result | Status |
|-------|---------|--------|--------|
| Black Formatting | `poetry run black --check <changed file>` | unchanged | ✅ |
| Ruff Linting | `poetry run ruff check <changed file>` | All checks passed | ✅ |
| Pyright Type Checking | `poetry run pyright <changed file>` | 0 errors | ✅ |
| Pytest Tests | `poetry run pytest -q -rf --no-cov <four suites>` | 52 passed, 1 failed (E-1) | ⚠️ |
| Coverage | `poetry run pytest --cov=scripts.dev_tools --cov-branch --cov-report=term-missing` (executor) | 93.11% lines, 85.92% branches | ✅ |

**For PowerShell:**

| Check | Command | Result | Status |
|-------|---------|--------|--------|
| Invoke-Formatter | comparison with `pssa.settings.psd1` | 0 of 72 files differ | ✅ |
| PSScriptAnalyzer | `Invoke-ScriptAnalyzer -Settings pssa.settings.psd1` | 0 diagnostics | ✅ |
| Pester Tests | Pester 5 over four trees | 0 failures | ✅ |

**Notes:**
The single Python failure is `test_bundled_claude_payload_contains_all_repo_runtime_contracts`, with the assertion `Repo file missing from bundle: .claude\state\current-session-id`. The path is gitignored host session state. The node failed identically at baseline (`evidence/baseline/python-parity.2026-09-29T23-11.md`) and in every run since. It matches the issue #510 pattern and is expected to pass in CI, where the file does not exist.

---

## 8. Gaps and Exceptions

### Identified Gaps

- **G-1 (closed): Python coverage artifact.** `artifacts/python/lcov.info` exists and reports 93.11% lines and 85.92% branches (`evidence/qa-gates/python-coverage.2026-09-30T02-07.md`); the reviewer reproduced both figures.
- **G-2 (closed): canonical PowerShell artifact omitted three new files.** The artifact was regenerated through the repository PoshQC module and runsettings and now lists all three files (`evidence/qa-gates/powershell-coverage-artifact.2026-09-30T02-23.md`).
- **G-3 (open, pending CI): AC-44.** The mirror half is verified (19/19 hash-equal at the merged head). The bundle contract test cannot pass on this host (E-1). No PR and no CI run exist for the branch yet (`gh run list --branch bug/agent-payload-gates-resolve-session-root-690` returned an empty list). A green CI result on the PR head is required before AC-44 is checked off. No branch change can close this gap, so it is not routed to remediation.
- **G-4 (policy-text discrepancy, informational):** the review contract's verification procedure cites 90% new-file and 80% repo-wide thresholds, while `.claude/rules/quality-tiers.md` sets a uniform 85%. This audit applied 85%. Under 90%, `enforce-epic-merge-gate-resolution.ps1` at 88.89% would not meet the new-file threshold.
- **G-5 (informational): coverage artifacts predate the merge of `origin/main`.** See the Artifact freshness note in the Coverage Verification section. The per-file verdicts for branch files are unaffected.

### Approved Exceptions

- **E-1:** KL-510 node `test_bundled_claude_payload_contains_all_repo_runtime_contracts` fails locally on gitignored host state (issue #510). It failed identically at baseline, and the remediation inputs prohibit altering `.claude/state/` to force a local pass. It is recorded as a non-attributable local failure pending CI.
- AC-62 amendment (spec Change Log, 2026-09-30): the Python digest-pin re-baseline is permitted by orchestrator decision; the criterion's intent (no Python hook legs) is unchanged.

### Removed/Skipped Tests

**None.** All planned tests implemented. The one skipped row in the four trees is pre-existing and was skipped at baseline.

---

## 9. Summary of Changes

### Commits in This PR/Branch

1. **d6bb5c65** - docs(690): add research, spec, and user story for session-root gate resolution
2. **3ae80aa4** - docs(690): add implementation plan and baseline evidence
3. **d120a539** - feat(690): add the WorktreeRunResolution run-target resolver
4. **0dcb1cf5** - docs(690): extend the delegation identity contract to implementation agents
5. **25069b47** - fix(690): resolve the preimplementation gate checkpoint from the call target
6. **db6a075d** - fix(690): resolve the epic wave barrier checkpoint from integration_branch
7. **83d89c60** - fix(690): resolve the parallel cohort barrier checkpoint from parallel_slug
8. **a696d710** - fix(690): resolve merge gate run checkpoints by pull request number
9. **ad2f8f41** - fix(690): resolve epic worktree-removal checkpoints by worktree path
10. **8f566bfb** - fix(690): resolve parallel worktree-removal checkpoints by worktree path
11. **06e7b653** - fix(690): resolve the parallel drift gate checkpoint from parallel_slug
12. **dd39cef8** - fix(690): resolve the epic-scope checkpoint through the run resolver
13. **166b1de3** - docs(690): record follow-up potential entries
14. **e5549ee1** - test(690): cover the import guards and relocated seams for the final coverage gates
15. **1429d24a** - docs(690): record PowerShell final QA evidence
16. **c50234ae** - docs(690): record Python parity and the dev_tools frozen-surface failure
17. **8ae639e3** - test(690): re-baseline the frozen epic-surface digest pins
18. **0545db17** - docs(690): record final QA evidence
19. **c47504ae** - docs(690): check off acceptance criteria
20. **c127db6d** - docs(690): add feature-review artifacts (pass 1)
21. **465e1ec5** - docs(690): add remediation plan R1 and baseline evidence
22. **85139598** - docs(690): record repository Python coverage evidence (RF-1)
23. **197cacfa** - fix(690): return NoTarget for an out-of-range pull request number (CR-1)
24. **5e783d51** - fix(690): report an unreadable run checkpoint on stderr (CR-2)
25. **9b36fed3** - docs(690): record the canonical PowerShell coverage artifact (RF-3)
26. **fcfb2efb** - docs(690): record remediation QA loop and review-nit follow-up
27. **973e8bfc** - docs(690): record remediation R1 check-off state
28. **268d6359** - Merge origin/main into bug/agent-payload-gates-resolve-session-root-690

### Files Modified

1. **`.claude/lib/worktree-resolution/WorktreeRunResolution.psm1`** (NEW; 497 lines)
   - Epic, parallel, record, and operand resolvers with one read seam; remediation adds the `pr_number` range guard and the stderr diagnostic.
2. **`.claude/hooks/enforce-epic-merge-gate-resolution.ps1`**, **`.claude/hooks/enforce-epic-worktree-removal-gate-resolution.ps1`** (NEW)
   - Read seams, import guards, and resolution seams relocated from the gate files.
3. **Nine gate files and two library modules** (MODIFIED)
   - Relative checkpoint literals replaced by resolution plus absolute-path reads; import guards added.
4. **Six `.claude/skills/*/SKILL.md` files** (MODIFIED)
   - Identity-line contract for implementation-agent and run delegations.
5. **Bundle mirrors, `core.json`, two runsettings copies** (MODIFIED/NEW)
   - Registration and mirror parity; union-merged with `main`.
6. **12 new and 31 modified Pester suites, 1 helper** (NEW/MODIFIED)
   - Resolution rows, default seam mocks, and remediation rows B13 and T4.
7. **`tests/scripts/dev_tools/parallel_orchestrator_surface_expectations.py`** (MODIFIED)
   - One digest pin re-baselined.
8. **Feature documents, evidence, four potential entries** (NEW)

---

## 10. Compliance Verdict

### Overall Status: ✅ FULLY COMPLIANT

Every policy section is met on inspected evidence at head `268d6359`, and every required baseline, QA, coverage, and coverage-comparison artifact is present. The pass-1 FAIL (G-1) and the non-blocking gap (G-2) are closed. The remaining open item is G-3/AC-44. It depends on a CI run of a test node that fails locally only because of gitignored host state (E-1), and no branch change can resolve it.

**Fail-closed reminder:** Do not mark the audit PASS, fully compliant, or ready for merge when any required baseline artifact, QA artifact, coverage metric, or coverage-comparison artifact is missing.

---

### Policy-by-Policy Summary

#### General Code Change Policy (Section 2)
- ✅ Before Making Changes: spec, research, plan, and remediation plan present
- ✅ Design Principles: minimal remediation edits; no new helpers
- ✅ Module & File Structure: all files at or below 500 lines
- ✅ Naming, Docs, Comments: synopsis and description updated
- ✅ Toolchain Execution: clean single pass reproduced by the reviewer at the merged head
- ✅ Summarize & Document: commits, evidence, potential entries

#### Language-Specific Code Change Policy (Section 3)

**For Python:**
- ✅ Tooling & Baseline: black, ruff, pyright clean; pytest failure limited to E-1
- ✅ Python Design & Typing: data-only change
- ✅ Error Handling: not applicable

**For PowerShell:**
- ✅ Tooling & Baseline: 0 format differences, 0 diagnostics
- ✅ PowerShell Design & Safety: CR-1 and CR-2 closed
- ✅ Structure & Naming: approved verbs, under 500 lines
- ✅ Toolchain: remediation loop clean; canonical run 0 failures

#### General Unit Test Policy (Section 1)
- ✅ Core Principles: deterministic, isolated, fast
- ✅ Coverage & Scenarios: PowerShell and Python PASS
- ✅ Test Structure: AAA with behaviour assertions
- ✅ External Dependencies: none
- ✅ Policy Audit: re-audit complete; AC-44 pending CI

#### Language-Specific Unit Test Policy (Section 4)

**For Python:**
- ✅ Framework & Scope: coverage expectation evidenced
- ✅ Test Style & Structure: no test logic changed
- ✅ Naming & Readability: not applicable
- ✅ Toolchain: pytest, with E-1 recorded

**For PowerShell:**
- ✅ Framework & Scope: Pester 5 with PoshQC configuration
- ✅ Test Style & Structure: focused rows, sparse mocks
- ✅ Naming & Readability: ID-prefixed rows
- ✅ Toolchain: all pass

---

### Metrics Summary

- ✅ 5429/5430 PowerShell tests passing across claude-hooks, claude-lib, claude-runtime, codex-hooks (1 pre-existing skip)
- ✅ 96.23% PowerShell line coverage repo-wide; new files 100%, 88.89%, 95.65%; modified files 92.86%-100%
- ✅ 93.11% Python line coverage and 85.92% branch coverage
- ✅ Proper file organization: tests mirror `.claude/lib` and `.claude/hooks` under `tests/scripts/`
- ✅ All code quality checks passing (format, lint, type check)
- ✅ Test execution time: 217 seconds for 5430 rows (fast)

---

### Recommendation

**Ready for merge**

The condition is the normal CI gate: open the PR, confirm that `test_bundled_claude_payload_contains_all_repo_runtime_contracts` passes in CI on the PR head, record that result under `evidence/qa-gates/`, and check off AC-44 in `spec.md`. No further remediation pass is required. CR-4 and CR-5 (Nits) are tracked in `docs/features/potential/2026-09-30-worktree-run-resolution-review-nits.md`.

---

## Appendix A: Test Inventory

### Complete Test List

New suites (all passing in the reviewer's four-tree run):

- `tests/scripts/claude-hooks/enforce-epic-merge-gate.WorktreeResolution.Tests.ps1` (10)
- `tests/scripts/claude-hooks/enforce-epic-wave-barrier.WorktreeResolution.Tests.ps1` (9)
- `tests/scripts/claude-hooks/enforce-epic-worktree-removal-gate.WorktreeResolution.Tests.ps1` (6)
- `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.OperandResolution.Tests.ps1` (10)
- `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.WorktreeResolution.Tests.ps1` (15)
- `tests/scripts/claude-hooks/enforce-parallel-cohort-barrier.WorktreeResolution.Tests.ps1` (7)
- `tests/scripts/claude-hooks/enforce-parallel-drift-gate.WorktreeResolution.Tests.ps1` (6)
- `tests/scripts/claude-hooks/enforce-parallel-worktree-removal-gate.WorktreeResolution.Tests.ps1` (6)
- `tests/scripts/claude-lib/worktree-resolution/EpicScopeResolution.RunTarget.Tests.ps1` (4)
- `tests/scripts/claude-lib/worktree-resolution/WorktreeRunResolution.Record.Tests.ps1` (28, including B13)
- `tests/scripts/claude-lib/worktree-resolution/WorktreeRunResolution.Signal.Tests.ps1` (17, including T4)
- `tests/scripts/claude-lib/worktree-resolution/WorktreeRunResolution.Tests.ps1` (22)

Modified suites receive default seam mocks or guard-list updates and all pass within the four-tree run.

---

## Appendix B: Toolchain Commands Reference

Commands run by this reviewer at head `268d6359` (check-only; reviewer scripts lived in the session scratchpad):

**For Python:**
```bash
poetry run python scripts/dev_tools/validate_evidence_locations.py --root .
poetry run black --check tests/scripts/dev_tools/parallel_orchestrator_surface_expectations.py
poetry run ruff check tests/scripts/dev_tools/parallel_orchestrator_surface_expectations.py
poetry run pyright tests/scripts/dev_tools/parallel_orchestrator_surface_expectations.py
poetry run pytest -q -rf -p no:cacheprovider --no-cov tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py tests/scripts/dev_tools/test_push_down_claude_pack_manifest_completeness.py tests/scripts/dev_tools/test_poshqc_bundled_parity.py tests/scripts/dev_tools/test_parallel_orchestrator_surface_contracts.py
# lcov totals: sum of LF/LH/BRF/BRH over artifacts/python/lcov.info (awk)
poetry run python -m scripts.dev_tools.validate_orchestration_artifacts {policy-audit|code-review|feature-audit} <artifact>
```

**For PowerShell:**
```powershell
# Formatting check (no write): compare Invoke-Formatter output with file text for each of the 72 changed .ps1/.psm1/.psd1 files
Invoke-Formatter -ScriptDefinition $text -Settings scripts/powershell/PoshQC/settings/pssa.settings.psd1

# Linting
Invoke-ScriptAnalyzer -Path <file> -Settings scripts/powershell/PoshQC/settings/pssa.settings.psd1

# Testing (Pester 5, PassThru, no coverage generation, no result file)
Invoke-Pester -Configuration <Run.Path = tests/scripts/claude-hooks, tests/scripts/claude-lib, tests/scripts/claude-runtime, tests/scripts/codex-hooks>
```

**Git, CI, and coverage inspection:**
```bash
git diff --name-status 72d7ebbf...HEAD
git diff --name-only 973e8bfc 268d6359                                   # merge contents and overlap with branch files
git diff -U0 72d7ebbf HEAD -- <production file>                          # changed-line map for the coverage parse
git diff c127db6d 973e8bfc -- .claude/lib/worktree-resolution/WorktreeRunResolution.psm1 tests/scripts/claude-lib/worktree-resolution/
sha256sum <.claude file> <bundle mirror>                                 # 19 pairs; both runsettings copies
gh run list --repo drmoisan/drm-copilot --branch bug/agent-payload-gates-resolve-session-root-690
# JaCoCo parse of artifacts/pester/powershell-coverage.xml (repo LINE counter, per-file LINE counters, per-line ci values)
```

Executor commands are recorded in each `evidence/qa-gates/*.md` and `evidence/remediation-baseline/*.md` file under this feature folder.

---

**Audit Completed By:** feature-review agent
**Audit Date:** 2026-09-30
**Policy Version:** Current (as of audit date)
