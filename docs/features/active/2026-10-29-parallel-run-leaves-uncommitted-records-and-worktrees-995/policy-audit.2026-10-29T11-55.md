# Policy Compliance Audit: Parallel run leaves uncommitted records and worktrees (Issue #995)

---

**Audit Date:** 2026-10-29
**Base Branch:** `main` (resolved `origin/main`, merge base `972e4083c59fefd1d40984929503c9956eed7137`)
**Head:** `bug/parallel-run-leaves-uncommitted-records-and-worktrees-995` at `bed21939d7da24cce0c2100ef619fe3aaa23f19d`
**Scope:** full branch diff `972e4083c59fefd1d40984929503c9956eed7137..bed21939d7da24cce0c2100ef619fe3aaa23f19d` (85 files, 4129 insertions, 169 deletions; 5 commits including one merge of `origin/main`)

**Code Under Test (non-documentation files):**

- PowerShell production (new): `.claude/lib/worktree-resolution/WorktreeRunRecordPath.psm1`.
- PowerShell production (modified): `.claude/lib/worktree-resolution/WorktreeRunResolution.psm1`, `.claude/lib/cleanup-manifest/CleanupWorktreeManifest.psm1`, `.claude/hooks/enforce-parallel-worktree-removal-gate.ps1`, `.claude/hooks/enforce-epic-worktree-removal-gate.ps1`, `.claude/hooks/enforce-epic-worktree-removal-gate-resolution.ps1`, and the six byte-identical bundle copies under `extensions/drm-copilot/resources/claude-customizations/.claude/`.
- PowerShell tests (new): `tests/scripts/claude-lib/worktree-resolution/WorktreeRunRecordPath.Tests.ps1`, `tests/scripts/claude-lib/worktree-resolution/WorktreeRunResolution.RelativeRecord.Tests.ps1`, `tests/scripts/claude-hooks/enforce-parallel-worktree-removal-gate.RelativeRecord.Tests.ps1`, `tests/scripts/claude-hooks/enforce-epic-worktree-removal-gate.RelativeRecord.Tests.ps1`, `tests/scripts/claude-runtime/parallel-orchestrate-run-closing.Tests.ps1`.
- PowerShell tests (modified): 16 pre-existing suites under `tests/scripts/claude-hooks/` and `tests/scripts/claude-lib/` (additive mocks, imports, expected-path entries, and the relative-record matrix rows).
- Python test (modified): `tests/scripts/dev_tools/test_parallel_orchestrator_surface_contracts.py`.
- JSON: `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json`.
- Markdown runtime surfaces: `.claude/skills/parallel-orchestrate/SKILL.md`, `.claude/agents/parallel-orchestrator.md`, `.claude/rules/parallel-orchestration.md`, and their bundle copies.
- Documentation: the feature folder, the run records under `docs/features/parallel/pr-author-and-file-size/`, and three promoted lifecycle records under `docs/features/potential/promoted/`.

**Coverage Metrics by Language:**

| Language | Files Changed | Tests | Test Result | Baseline Coverage | Post-Change Coverage | New Code Coverage |
|----------|--------------|-------|-------------|-------------------|---------------------|-------------------|
| PowerShell | 6 production (+6 mirrors), 21 test | 11994 in full `tests/scripts` run; 332 in reviewer re-run of 9 suites | PASS 11984 pass, 0 fail, 10 skipped; reviewer 332 pass, 0 fail | per-file 92.59%-100.00% lines (five pre-existing files); artifact total at baseline in `evidence/baseline/pester-coverage.2026-10-29T10-45.md` | per-file 92.52%-100.00% lines; artifact total 92.89% (18271 of 19670) | new module 100.00% (33 of 33); all changed lines covered |
| Python | 0 production, 1 test | 7369 full suite (reviewer run) | PASS 7369 pass, 6 skipped | 94.11% lines, 88.78% branches (repo-wide; no Python production file changed since the merge base) | 94.11% lines, 88.78% branches (repo-wide; 16798 of 17849 lines, 5723 of 6446 branches) | 100% of changed production Python lines (0 production Python lines changed) |
| JSON | 1 manifest | push-down contract, completeness, and dependency-closure tests | PASS 52 pass (reviewer run of three modules) | N/A (config) | N/A (config) | N/A |
| TypeScript | 0 | — | — | N/A (no changed files) | N/A | N/A |
| C# | 0 | — | — | N/A (no changed files) | N/A | N/A |

### Coverage Evidence Checklist

- TypeScript baseline coverage artifact: N/A (no TypeScript file changed on the branch).
- TypeScript post-change coverage artifact: N/A (no TypeScript file changed on the branch).
- Python baseline coverage artifact: N/A as a separate artifact; no Python production file differs between the merge base and the head, so the head measurement equals the baseline for every production line. The figures match the merge-base measurement recorded in the issue #984 audit (16798 of 17849 lines, 5723 of 6446 branches).
- Python post-change coverage artifact: `artifacts/python/lcov.info` and `artifacts/python/coverage.json`, reviewer-generated at head (see Section 8, Approved Exceptions, for the deviation note).
- PowerShell baseline coverage artifact: `FEATURE/evidence/baseline/pester-coverage.2026-10-29T10-45.md`.
- PowerShell post-change coverage artifact: `artifacts/pester/powershell-coverage.xml` (written 2026-10-29 11:37 UTC, after the last production-file modification at 11:04 UTC); `FEATURE/evidence/qa-gates/pester-coverage.2026-10-29T11-40.md`.
- Per-language comparison summary: Section 1.2.1 and `FEATURE/evidence/qa-gates/coverage-comparison.2026-10-29T11-41.md`.

`FEATURE` denotes `docs/features/active/2026-10-29-parallel-run-leaves-uncommitted-records-and-worktrees-995`.

---

## Executive Summary

The branch fixes issue #995. A completed parallel run left its records uncommitted and its item worktrees in place, because (1) the run checkpoint records `items[].worktree_path` relative to the main checkout while every removal-gate matcher compared it to the absolute command target as a raw string, and (2) the parallel orchestrator had no closing step. The change adds a pure shared matcher module, `WorktreeRunRecordPath.psm1`, and routes all six matcher-family sites through it; adds a `### Run Closing` procedure to the `parallel-orchestrate` skill and the `parallel-orchestrator` agent, with an `Agent(pr-author)` grant scoped to the records pull request; updates the rule text; keeps all nine bundle copies byte-identical; adds the new module to `core.json`; and lands the leftover records of run `pr-author-and-file-size`.

The reviewer parsed `artifacts/pester/powershell-coverage.xml` directly, re-ran nine Pester suites (332 passed), PSScriptAnalyzer over the 26 changed PowerShell files (0 findings), Black, Ruff, and Pyright over the changed Python test, the full Python suite with branch coverage (7369 passed), the push-down contract tests (52 passed), the Codex generator `--check` (exit 0), `check_quality_tiers` (OK), mirror parity (`cmp`, nine of nine identical), the evidence-location validator (exit 0), and logical line counts (largest 495).

No blocking finding was identified. Non-blocking observations are recorded in Section 8 and in the code review.

**Policy documents evaluated:**
- PASS `CLAUDE.md`, `.claude/rules/general-code-change.md`
- PASS `.claude/rules/general-unit-test.md`, `.claude/rules/quality-tiers.md`

**Language-specific policies evaluated:**
- PASS `.claude/rules/powershell.md`
- PASS `.claude/rules/python.md` + `.claude/rules/python-suppressions.md` (one test file; no suppression added)
- PASS JSON: `core.json` parses and is consumed by passing completeness and dependency-closure tests
- N/A TypeScript, C#, Bash: no changed files

**Temporary artifacts cleanup:**
- PASS No temporary script is committed. The executor's `SCRATCH/` scripts are outside the branch diff; the reviewer's parsing scripts are in the session scratchpad.

---

## Rejected Scope Narrowing

No caller instruction attempted to narrow the audit scope. The caller prompt stated "Scope determination is yours." and the full branch diff against the merge base was reviewed.

The plan of record (task P0-T6) states "Python coverage is not measured because no Python production file changes." That is a plan assertion, not a caller instruction, and it was not applied as a scope limit: Python coverage was measured repo-wide at head in this review and receives an explicit verdict in Section 1.2.1.

---

## Evidence Location Compliance

- `git diff --name-only 972e4083c59fefd1d40984929503c9956eed7137..HEAD` filtered for `^artifacts/(baselines|qa|evidence|coverage)/`: no matches.
- `poetry run python scripts/dev_tools/validate_evidence_locations.py --root .`: exit 0.
- All committed evidence is under `FEATURE/evidence/<kind>/` (`baseline`, `other`, `qa-gates`, `regression-testing`).
- Added-line scan of the diff for host paths (`C:/Users`, `C:\Users`, `/home/`, `AppData`): 0 matches.

Verdict: PASS.

---

## 1. General Unit Test Policy Compliance

### 1.1 Core Principles

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Independence** - Tests run in any order | PASS | Three seeded shuffled Pester runs (seeds 995, 4242, 31337) over the 19 touched suites: 474 of 474 each; reversed-order Python run 233 of 233 (`FEATURE/evidence/regression-testing/isolation.2026-10-29T11-44.md`). Mocks are registered in `BeforeEach`/`BeforeAll` per suite. |
| **Isolation** - Each test targets single behavior | PASS | Rows are labelled by unit (M/P/R/X for the module, RR for resolution, RP/RE for the gates, RC/RA for the content checks); each `It` asserts one decision. |
| **Fast Execution** - Tests complete quickly | PASS | The matcher suite is pure string work; the reviewer's nine-suite re-run completed in one process; Python surface contracts run in under 1 s. |
| **Determinism** - Consistent results | PASS | Literal POSIX fixtures (`/synthetic-worktrees/...`); filesystem seams `Get-WorktreeItemLiveRoot` and `Get-WorktreeResolutionGitEntryKind` mocked; `git` is never mocked or invoked; no clock or randomness in the changed code. |
| **Readability & Maintainability** - Clear structure | PASS | Suite `.SYNOPSIS`/`.DESCRIPTION` blocks state scope and issue; Arrange/Act/Assert comments; `-Because` messages on key assertions. |

### 1.2 Coverage and Scenarios

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Baseline Coverage Documented** | PASS | `FEATURE/evidence/baseline/pester-coverage.2026-10-29T10-45.md` (five pre-existing production files); Python repo-wide figures in Section 1.2.1. |
| **No Coverage Regression** | PASS | Two per-file deltas are negative (-0.07 and -0.04 points) because covered inline-normalizer lines were removed from the denominator; the missed-line sets are unchanged and every missed line lies in an unedited function (`FEATURE/evidence/qa-gates/coverage-comparison.2026-10-29T11-41.md`). Every changed executable line is covered. |
| **New Code Coverage >= 85% line** | PASS | `WorktreeRunRecordPath.psm1`: 33 of 33 lines (100.00%), reviewer parse of the coverage XML. |
| **Comprehensive Coverage** | PASS | Relative join to each base root, rooted pass-through, separator and case rules, every unsafe relative form, empty base roots, blank target, main-root selection, and the export list. |
| **Positive Flows** - Valid inputs | PASS | M1, M2, M3, M4, M6, M9; RR1-RR3; RP1 and RE1 (allow on `merged` and `worktree_removed`, both topologies in the epic gate). |
| **Negative Flows** - Invalid inputs | PASS | M5, M7 (eight unsafe forms against six candidate targets including the main root), M8, M10, M11; RR4; RP2 and RE2 (`pr_open`, `worktree_created`, absent status, other agent, `..`, blank). |
| **Edge Cases** - Boundary conditions | PASS | Trailing and backslash separators on record, target, and base root; blank base roots skipped; drive-letter and UNC case variants; empty live-root list. |
| **Error Handling** - Error paths | PASS | Deny reasons keep their prefixes (`PARALLEL_WORKTREE_REMOVAL_BLOCKED`, `EPIC_WORKTREE_REMOVAL_BLOCKED`), asserted in RP2/RE2; RE4 asserts the diagnostics text through the shared matcher. |
| **Concurrency** - If applicable | PASS | RP3, RE3, and RR5: the same record in two live roots resolves `Ambiguous` and denies. |
| **State Transitions** - If applicable | N/A | The changed code is stateless comparison and resolution. |

### 1.2.1 Per-Language Coverage Comparison

- PowerShell: Baseline: 92.59% lines (lowest pre-existing changed file; range 92.59%-100.00%) -> Post-change: 92.52% lines (lowest changed file; range 92.52%-100.00%). Change: -0.07 to +0.37 points per file; the two negative deltas come from removed covered lines, with unchanged missed-line sets. New/changed-code coverage: 100% (every changed executable line is covered; the new file `WorktreeRunRecordPath.psm1` is 33 of 33). Per-file post-change (reviewer parse of `artifacts/pester/powershell-coverage.xml`): `WorktreeRunRecordPath.psm1` 100.00% (33/33), `WorktreeRunResolution.psm1` 100.00% (146/146), `CleanupWorktreeManifest.psm1` 92.52% (99/107), `enforce-parallel-worktree-removal-gate.ps1` 93.10% (108/116), `enforce-epic-worktree-removal-gate.ps1` 95.61% (109/114), `enforce-epic-worktree-removal-gate-resolution.ps1` 98.18% (54/55). Repo-wide artifact total: 92.89% (18271 of 19670). No branch gate applies (Pester). Thresholds: root `CLAUDE.md` states none, so the 85% line default governs. Disposition: PASS. Evidence: `FEATURE/evidence/baseline/pester-coverage.2026-10-29T10-45.md`, `FEATURE/evidence/qa-gates/pester-coverage.2026-10-29T11-40.md`, `FEATURE/evidence/qa-gates/coverage-comparison.2026-10-29T11-41.md`, `artifacts/pester/powershell-coverage.xml`.
- Python: Baseline: 94.11% lines, 88.78% branches -> Post-change: 94.11% lines, 88.78% branches (head, 16798 of 17849 lines, 5723 of 6446 branches). Change: 0.00 points lines, 0.00 points branches. New/changed-code coverage: 100% of changed production Python lines; the branch changes 0 production Python lines (the one changed Python file is a test under `tests/`, which `[tool.coverage.run] omit` excludes). Thresholds 85% line and 75% branch (defaults; root `CLAUDE.md` states none) met. Disposition: PASS. Evidence: `artifacts/python/lcov.info` and `artifacts/python/coverage.json` (reviewer-generated at head).
- TypeScript: no changed files. Disposition: N/A. Evidence: branch diff contains no `.ts`/`.tsx`/`.js` file.
- C#: no changed files. Disposition: N/A. Evidence: branch diff contains no `.cs` file.

### 1.3 Test Structure and Diagnostics

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Clear Failure Messages** | PASS | `-Because` on the matcher and content assertions; RC4 reports each violating span; the Python assertion prints the full tools list. |
| **Arrange-Act-Assert Pattern** | PASS | Arrange/Act/Assert comments throughout the new suites. |
| **Document Intent** | PASS | Each new suite carries a `.SYNOPSIS`/`.DESCRIPTION`; the replaced Python test has a docstring stating the D4 rationale. |

### 1.4 External Dependencies and Environment

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Avoid External Dependencies** | PASS | No network, database, or process start. The content suite reads committed repository files only. |
| **Use Mocks/Stubs** | PASS | `Get-WorktreeRunMainCheckoutRoot`, `Get-WorktreeItemLiveRoot`, `Get-WorktreeResolutionGitEntryKind`, checkpoint-text seams, and `Get-CleanupWorktreeManifestContent` are mocked in module scope. |
| **Environment Stability** | PASS | No `TestDrive`, `New-TemporaryFile`, `Set-Content`, `Out-File`, or `Start-Sleep` in the new tests (reviewer inspection). Pre-existing suites gained `Get-WorktreeRunMainCheckoutRoot { $null }` mocks so no row reads the real repository. |

### 1.5 Policy Audit Requirement

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Pre-submission Review** | PASS | This document is the required policy audit for the branch. |

---

## 2. General Code Change Policy Compliance

### 2.1 Before Making Changes

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Clarify the objective** | PASS | `issue.md` and `spec.md` (Root Cause Analysis, Proposed Fix, AC-1 to AC-20). |
| **Read existing change plans** | PASS | `research/research.2026-10-29T10-07.md`; `FEATURE/evidence/baseline/phase0-instructions-read.2026-10-29T10-28.md`. |
| **Document the plan** | PASS | `plan.2026-10-29T05-58.md`: 52 tasks checked, 0 unchecked. Deviations recorded in `spec.md` `## Implementation Deviations`. |

### 2.2 Design Principles

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Simplicity first** | PASS | One pure matcher (`Test-WorktreeRunRecordedPathMatchesTarget`) and one seam function; each site change is a single call replacement plus an optional `-BaseRoot` parameter. |
| **Reusability** | PASS | Six inline normalise-and-compare copies replaced by one shared function. Two near-identical base-root helpers remain in the two gate files (code review, Minor). |
| **Extensibility** | PASS | `-BaseRoot` is an optional `string[]` with an empty default, so existing callers are unchanged. |
| **Separation of concerns** | PASS | Comparison is pure; filesystem access is confined to `Get-WorktreeRunMainCheckoutRoot` through mocked sibling seams. |

### 2.3 Module & File Structure

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Cohesive modules** | PASS | The new module holds only path comparison and main-root derivation; `Test-WorktreeRunPathEqual` moved into it, keeping `WorktreeRunResolution.psm1` at 487 lines. |
| **File size (tiered policy)** | PASS | Reviewer logical line counts (`@(Get-Content -LiteralPath <path>).Count`): largest `enforce-parallel-worktree-removal-gate.ps1` 495 and `test_parallel_orchestrator_surface_contracts.py` 495; `WorktreeRunResolution.psm1` 487; no covered file at or above 700. `config/file-size-baseline.json` is unchanged. |
| **Public vs internal** | PASS | `Test-WorktreeRunRelativeRecordSafe` is not exported; X1 asserts exactly three exports. |
| **No circular dependencies** | PASS | `WorktreeRunRecordPath.psm1` imports only `WorktreeResolution.psm1` and `WorktreeItemResolution.psm1`; `WorktreeRunResolution.psm1` and `CleanupWorktreeManifest.psm1` import it one-way. |

### 2.4 Naming, Docs, and Comments

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Descriptive names** | PASS | `Test-WorktreeRunRecordedPathMatchesTarget`, `Get-WorktreeRunMainCheckoutRoot`, `Get-ParallelWorktreeGateBaseRoot`. |
| **Docs/docstrings** | PASS | Comment-based help on every new or changed public function, including `.PARAMETER BaseRoot`. |
| **Comment why, not what** | PASS | Site comments state why the main root is derived once and why unsafe relative records match nothing. |

### 2.5 After Making Changes - Toolchain Execution

| Requirement | Status | Evidence |
|------------|--------|----------|
| **1. Formatting** | PASS | PoshQC format: 26 of 26 already formatted (`FEATURE/evidence/qa-gates/poshqc-format.2026-10-29T11-21.md`); Black `--check` on the changed Python test: "1 file would be left unchanged." (reviewer). |
| **2. Linting** | PASS | PSScriptAnalyzer: 0 findings across 26 files (executor `pssa.2026-10-29T11-21.md`; reviewer re-run 26 files, 0 findings); Ruff: "All checks passed!" (reviewer). |
| **3. Type checking** | PASS | Pyright on the changed Python test: 0 errors, 0 warnings, 0 informations (reviewer). PowerShell: N/A. |
| **4. Architecture-boundary tests** | PASS | `hook-dependency-guard-completeness.Tests.ps1` (622 pass), `WorktreeResolution.Manifest.Tests.ps1` (22 pass), `enforce-gate-suites.EpicStateIsolation.Discovery.Tests.ps1` (393 pass), and the disallowed-command check in `WorktreeRunResolution.Record.Tests.ps1`. |
| **5. Unit tests** | PASS | Full Pester `tests/scripts`: 11984 passed, 0 failed, 10 skipped; reviewer re-run of nine suites: 332 passed; full Python suite: 7369 passed, 6 skipped. |
| **6. Contract / schema checks** | PASS | Push-down resource, completeness, and dependency-closure tests: 52 passed (reviewer); `generate_codex_agent_variants --check` exit 0 (reviewer); `check_quality_tiers`: OK. |
| **7. Integration tests** | PASS | End-to-end gate decisions through `Invoke-ParallelWorktreeRemovalGateDecision` and `Invoke-EpicWorktreeRemovalGateDecision` (RP1-RP3, RE1-RE3) with only read seams mocked. |
| **Full toolchain loop** | PASS | Executor recorded three loop passes; pass 2 found four guard-suite failures, fixed in test files, and pass 3 is clean across all stages. |
| **Explicit reporting** | PASS | Appendix B and the evidence folder. |

### 2.6 Summarize and Document

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Summarize changes** | PASS | Commit `fix(parallel-cleanup): match relative records and close runs`; Section 9. |
| **Design choices explained** | PASS | `spec.md` decisions D1-D8 and `## Implementation Deviations`. |
| **Update supporting documents** | PASS | `.claude/rules/parallel-orchestration.md` `## Enforcement` bullet names the shared matcher; skill and agent prose updated. |
| **Provide next steps** | PASS | `spec.md` `## Live-Verification Items` (LV1-LV4) and `## Rollout & Follow-up` (D8 tracked as #997). |

---

## 3. Language-Specific Code Change Policy Compliance

### Section 3A: Python Code Change Policy Compliance

#### 3A.1 Tooling & Baseline

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Formatting with Black** | PASS | **Command:** `poetry run black --check tests/scripts/dev_tools/test_parallel_orchestrator_surface_contracts.py`<br>**Result:** 1 file would be left unchanged. |
| **Linting with Ruff** | PASS | **Command:** `poetry run ruff check <same file>`<br>**Result:** All checks passed! No suppression added. |
| **Type checking with Pyright** | PASS | **Command:** `poetry run pyright <same file>`<br>**Result:** 0 errors, 0 warnings, 0 informations (strict mode). |

#### 3A.2 Python Design & Typing

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Type hints** | PASS | Test function annotated `-> None`; list comprehension over `string_sequence(...)`. |
| **Simple design** | PASS | One comprehension and one equality assertion. |

#### 3A.3 Python Error Handling

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Explicit failures** | PASS | Assertion message prints the full tools list. |

### Section 3B: PowerShell Code Change Policy Compliance

#### 3B.1 Tooling & Baseline

| Requirement | Status | Evidence |
|------------|--------|----------|
| **PowerShell 7+ compatibility** | PASS | PSScriptAnalyzer with repo settings (compatibility rules) reports 0 findings. |
| **Baseline captured** | PASS | `FEATURE/evidence/baseline/pssa.2026-10-29T10-30.md`, `line-counts.2026-10-29T10-29.md`, `pester-coverage.2026-10-29T10-45.md`. |

#### 3B.2 PowerShell Design & Safety

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Advanced functions** | PASS | Every new function uses `[CmdletBinding()]` and `[OutputType()]`. |
| **Parameter validation** | PASS | `[AllowNull()]`, `[AllowEmptyString()]`, `[AllowEmptyCollection()]` declared explicitly; mandatory parameters marked. |
| **Seams** | PASS | `Get-WorktreeRunMainCheckoutRoot` reads only through existing sibling seams; no new executable call. |
| **Hook dependency guard** | PASS | Hooks import the new module in the guarded `try { Import-Module ... } catch { Add-HookDependencyFailure ... }` form; library modules use `-ErrorAction Stop` at module scope per their stated convention. |
| **No state-changing action without ShouldProcess** | N/A | The changed functions read and compare only. |

#### 3B.3 Structure, Naming, and Comments

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Approved verbs** | PASS | `Test-`, `Get-`, `Find-`, `Resolve-`; PSScriptAnalyzer `PSUseApprovedVerbs` clean. |
| **Comment-based help** | PASS | `.SYNOPSIS`, `.DESCRIPTION`, `.PARAMETER` on the exported and gate functions. |

#### 3B.4 Running the Toolchain

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Format -> analyze -> test** | PASS | `poshqc-format.2026-10-29T11-21.md` -> `pssa.2026-10-29T11-21.md` -> `pester-coverage.2026-10-29T11-40.md`. |
| **Change budget** | PASS | Six production PowerShell files; the spec routes the change through the orchestrated large path, which has no production-file cap. |

### Section 3C: Bash Script Policy Compliance

#### 3C.1 Tooling & Baseline

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Applicable** | N/A | No `.sh` or `.bats` file changed. |

#### 3C.2 Bash Script Design

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Applicable** | N/A | No shell file changed. The agent gains a `Bash(bash .claude/skills/cleanup-merged-worktrees/scripts/cleanup-worktrees.sh*)` grant for an existing script. |

### Section 3D: JSON Configuration Policy Compliance

#### 3D.1 JSON Tooling

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Valid JSON** | PASS | `core.json` parses; consumed by the completeness and dependency-closure tests (52 passed). |

#### 3D.2 JSON Structure

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Entry placement** | PASS | One entry added among the sibling `worktree-resolution` modules, before its dependent `WorktreeRunResolution.psm1`. |

---

## 4. Language-Specific Unit Test Policy Compliance

### Section 4A: Python Unit Test Policy Compliance

#### 4A.1 Framework and Scope

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Pytest** | PASS | The changed contract test runs under Pytest; 233 passed in the 13-module contract run. |

#### 4A.2 Test Style and Structure

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Arrange-Act-Assert** | PASS | `# Arrange / Act` and `# Assert` comments retained. |

#### 4A.3 Naming and Readability

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Descriptive name** | PASS | `test_agent_tools_allowlist_grants_only_the_records_pr_author_channel`. |
| **Replaced assertion is justified** | PASS | The prior test asserted no `pr-author` grant; decision D4 reverses that behavior. The new test is stricter than "contains": it requires the list of `pr-author` entries to equal exactly `["Agent(pr-author)"]`. Recorded in `spec.md` `## Implementation Deviations`. |

#### 4A.4 Running the Toolchain

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Black, Ruff, Pyright, Pytest** | PASS | Reviewer runs listed in Section 3A.1; full suite 7369 passed. |

### Section 4B: PowerShell Unit Test Policy Compliance

#### 4B.1 Framework and Scope

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Pester 5** | PASS | `#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }` in the new suites. |
| **Location mirrors source** | PASS | `tests/scripts/claude-lib/worktree-resolution/` for the library, `tests/scripts/claude-hooks/` for the hooks, `tests/scripts/claude-runtime/` for the content suite. |

#### 4B.2 Test Style and Structure

| Requirement | Status | Evidence |
|------------|--------|----------|
| **One behavior per `It`** | PASS | Data-driven rows via `-ForEach` with one assertion focus each. |
| **Mocking rules** | PASS | `git` is never mocked; mocks target module-scoped seams with matching parameter names (`param([string] $Path)`). |

#### 4B.3 Naming and Readability

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Descriptive `It` names** | PASS | Names state input and expected outcome; two matrix rows renamed for `test-name-uniqueness.Tests.ps1`. |
| **Platform literals** | PASS | `WorktreeRunRecordPath.Tests.ps1` uses drive-letter and UNC literals; the Pester suite runs only on `windows-latest` shards (`.github/workflows/_poshqc.yml`), and the matcher is pure string logic in any case. |

#### 4B.4 Running the Toolchain

| Requirement | Status | Evidence |
|------------|--------|----------|
| **PoshQC route** | PASS | `Invoke-PoshQCTest -ScanFolders tests/scripts` in one fresh process (`pester-coverage.2026-10-29T11-40.md`). |

---

## 5. Test Coverage Detail

### `WorktreeRunRecordPath.psm1` (31 tests)

| Test | Scenario | Status |
|------|----------|--------|
| M1-M3 | Relative join to main root, second base root only, separator and trailing-slash variants | PASS |
| M4-M6 | Rooted POSIX exact match, POSIX case variant rejected, drive-letter and UNC case variants accepted | PASS |
| M7-M11 | Unsafe relative forms, empty base roots, blank base roots skipped, blank target, other agent | PASS |
| P1-P5 | `Test-WorktreeRunPathEqual` separator, POSIX case, drive-letter case, UNC case, blank side | PASS |
| R1-R4 | Main-root selection, `$null` cases, blank root skip, forward-slash probe | PASS |
| X1 | Exactly three exported functions | PASS |

### Run resolution and gates (RR1-RR7, RP1-RP4, RE1-RE4, manifest matrix rows)

| Test | Scenario | Status |
|------|----------|--------|
| RR1-RR7 | Relative parallel and epic records resolve `OtherWorktree`; unsafe records `NoTarget`; duplicates `Ambiguous`; main-root seam called once per path lookup and never for `pr_number` | PASS |
| RP1-RP4 | Parallel gate allow and deny cases; relative epic `features[]` record | PASS |
| RE1-RE4 | Epic gate allow through both branches; parallel-item deny cases; ambiguity; diagnostics | PASS |
| Matrix "denies the relative-record case when ..." | Manifest entry for a target recorded relatively with an unsafe status stays denied, in both gates | PASS |

### `parallel-orchestrate-run-closing.Tests.ps1` (56 tests)

| Test | Scenario | Status |
|------|----------|--------|
| RC1-RC4 | Skill section exists in both copies, names every closing token, is referenced from Completion Requirements, and stages only literal allowed paths | PASS |
| RA1-RA4 | Agent grants `Agent(pr-author)`, carries the section and tokens, and references it from Completion Requirements | PASS |

---

## 6. Test Execution Metrics

| Metric | Value |
|--------|-------|
| Pester full run (executor, fresh process) | 11994 cases: 11984 passed, 0 failed, 10 skipped |
| Pester reviewer re-run (9 suites) | 332 passed, 0 failed, 0 skipped |
| Pester seeded shuffles (3 seeds, 19 suites) | 474 passed each |
| Python full suite with branch coverage (reviewer) | 7369 passed, 6 skipped |
| Python contract modules (reviewer, 3 modules) | 52 passed |
| PowerShell line coverage (artifact total) | 92.89% |
| Python line / branch coverage (repo-wide) | 94.11% / 88.78% |

---

## 7. Code Quality Checks

| Check | Result | Evidence |
|-------|--------|----------|
| PSScriptAnalyzer | PASS | 0 findings, 26 files (reviewer re-run; one transient analyzer exception on the first attempt, clean on the second, matching the executor's documented retry behavior) |
| PoshQC format | PASS | 26 of 26 already formatted (executor) |
| Black / Ruff / Pyright | PASS | Reviewer runs on the changed Python test |
| Mirror parity | PASS | `cmp` of nine `.claude` files against their bundle copies: all identical (reviewer) |
| Codex generator `--check` | PASS | exit 0 (reviewer) |
| Quality tiers | PASS | `check_quality_tiers`: OK (26 entries, 26 discovered projects); changed libraries and hooks are T3 |
| Forbidden-path scope | PASS | No change under `.codex/`, `.agents/`, `.github/`, or to `enforce-epic-merge-gate*` (reviewer name-status review; `FEATURE/evidence/qa-gates/scope-check.2026-10-29T11-42.md`) |
| Coverage exclusions | PASS | No `exclude` entry added for a production path |

---

## 8. Gaps and Exceptions

### Identified Gaps

- Non-blocking (code review, Minor): `Find-CleanupWorktreeManifestRemovalRecord` still compares manifest `removals[].worktree_path` with PowerShell `-eq` (case-insensitive for every path), while `Test-CleanupManifestCheckpointCoversPath` now compares checkpoint records ordinally for single-slash POSIX paths. Before this change both sides were case-insensitive. On a case-insensitive POSIX filesystem, a checkpoint record that differs from the command target only by case no longer triggers the manifest-exclusion clause. The manifest predicate's own disposition, evidence, verdict, and branch-state conditions still apply.
- Non-blocking (code review, Minor): the Run Closing prose permits `artifacts/orchestration/` pathspecs, but `/artifacts` is ignored by `.gitignore` and the same substep requires the branch diff to list only `docs/` paths.
- Non-blocking (code review, Minor): the epic gate's relative-record deny rows (RE2) exercise the parallel-item branch only; the `features[]` branch is exercised for allow (RE1) and through `Find-ParallelWorktreeItemRecord` (RP4) and resolution (RR2).
- Non-blocking (code review, Minor): `Get-ParallelWorktreeGateBaseRoot` and `Get-EpicWorktreeGateBaseRoot` have identical bodies, and `Resolve-WorktreeRunTargetByRecord` builds the same base-root list inline.
- Live-verification items LV1-LV4 are by design not acceptance facts; they are verified on the next live run.

### Approved Exceptions

- Python coverage artifact generation by the reviewer: `artifacts/python/lcov.info` was absent at review start. Because the review contract requires an explicit PASS or FAIL coverage verdict for every language with changed files, the reviewer ran `poetry run pytest --cov --cov-branch -q -p no:cacheprovider --cov-report=json:artifacts/python/coverage.json` (the `pyproject.toml` `addopts` also writes `artifacts/python/lcov.info`) at head rather than recording an artifact-absent FAIL for a test-only Python change. This follows the precedent of the issue #984 audit. The outputs are gitignored and are not part of the branch diff.

### Removed/Skipped Tests

- `test_agent_tools_allowlist_excludes_pr_author_channel` was replaced by `test_agent_tools_allowlist_grants_only_the_records_pr_author_channel` because decision D4 reverses the asserted behavior. The replacement is stricter about the form of the grant.
- No Pester test was removed or skipped; `FEATURE/evidence/qa-gates/assertion-preservation.2026-10-29T11-42.md` records two removed lines across 15 pre-existing suites, neither containing `Should`.

---

## 9. Summary of Changes

### Commits in This PR/Branch

- `8429490eb` docs(parallel): run manifest for pr-author-and-file-size
- `c635f827a` docs(parallel): kickoff for pr-author-and-file-size
- `afb92499e` Merge remote-tracking branch 'origin/main' into bug/parallel-run-leaves-uncommitted-records-and-worktrees-995
- `a652a0fd1` docs(parallel): land pr-author-and-file-size run records
- `bed21939d` fix(parallel-cleanup): match relative records and close runs

### Files Modified

- Production PowerShell: 1 added, 5 modified (plus 6 bundle copies).
- Tests: 5 PowerShell suites added, 16 PowerShell suites and 1 Python test modified.
- Runtime Markdown: skill, agent, and rule (plus 3 bundle copies); `core.json`.
- Documentation: feature folder (issue, spec, plan, research, evidence), run records, and promoted lifecycle records.

---

## 10. Compliance Verdict

### Overall Status: FULLY COMPLIANT

All applicable policy checks pass. Four Minor observations are recorded as non-blocking.

### Policy-by-Policy Summary

#### General Code Change Policy (Section 2)

- PASS: design, structure, naming, file size, and the seven-stage toolchain.

#### Language-Specific Code Change Policy (Section 3)

- PASS: PowerShell and Python; PASS: JSON; N/A: Bash, TypeScript, C#.

#### General Unit Test Policy (Section 1)

- PASS: principles, coverage (PowerShell PASS, Python PASS), scenarios, and environment.

#### Language-Specific Unit Test Policy (Section 4)

- PASS: Pester and Pytest.

### Metrics Summary

| Metric | Value |
|--------|-------|
| Blocking findings | 0 |
| Non-blocking findings | 4 Minor, 4 Info (code review) |
| PowerShell new-file coverage | 100.00% |
| Lowest changed PowerShell file coverage | 92.52% |
| Largest changed covered file | 495 lines |

### Recommendation

Proceed to the PR creation gate. AC-20 remains pending CI and is checked off by the item's own orchestrator run at S9.

---

## Appendix A: Test Inventory

### Complete Test List

- `tests/scripts/claude-lib/worktree-resolution/WorktreeRunRecordPath.Tests.ps1` (31)
- `tests/scripts/claude-lib/worktree-resolution/WorktreeRunResolution.RelativeRecord.Tests.ps1` (RR1-RR7)
- `tests/scripts/claude-hooks/enforce-parallel-worktree-removal-gate.RelativeRecord.Tests.ps1` (RP1-RP4 and probe)
- `tests/scripts/claude-hooks/enforce-epic-worktree-removal-gate.RelativeRecord.Tests.ps1` (RE1-RE4 and probe)
- `tests/scripts/claude-runtime/parallel-orchestrate-run-closing.Tests.ps1` (56)
- `tests/scripts/claude-hooks/CleanupWorktreeManifestGateMatrix.Tests.ps1` (relative-record rows added)
- `tests/scripts/dev_tools/test_parallel_orchestrator_surface_contracts.py` (one test replaced)

---

## Appendix B: Toolchain Commands Reference

```powershell
# Formatting
Import-Module scripts/powershell/PoshQC/PoshQC.psd1; Invoke-PoshQCFormat -Root <repo root> -GetFileList <26 files>   # executor

# Linting
Invoke-ScriptAnalyzer -Path <file> -Settings scripts/powershell/PoshQC/settings/pssa.settings.psd1   # executor and reviewer, 26 files

# Testing
Invoke-PoshQCTest -Root <repo root> -ScanFolders tests/scripts   # executor, fresh process, with coverage
Invoke-Pester -Configuration <9 named suites, PassThru>           # reviewer re-run
```

```bash
# Formatting
poetry run black --check tests/scripts/dev_tools/test_parallel_orchestrator_surface_contracts.py

# Linting
poetry run ruff check tests/scripts/dev_tools/test_parallel_orchestrator_surface_contracts.py

# Type checking
poetry run pyright tests/scripts/dev_tools/test_parallel_orchestrator_surface_contracts.py

# Testing
poetry run pytest --cov --cov-branch -q -p no:cacheprovider --cov-report=json:artifacts/python/coverage.json
poetry run pytest --no-cov -q tests/scripts/dev_tools/test_parallel_orchestrator_surface_contracts.py tests/scripts/dev_tools/test_push_down_claude_pack_manifest_completeness.py tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py

# Contracts and scope
poetry run python -m scripts.dev_tools.generate_codex_agent_variants --check
poetry run python -m scripts.dev_tools.check_quality_tiers
poetry run python scripts/dev_tools/validate_evidence_locations.py --root .
```
