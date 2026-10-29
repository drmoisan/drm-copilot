# Policy Compliance Audit: Completion gate rejects adopted feature folder (Issue #992)

---

**Audit Date:** 2026-10-29
**Base Branch:** `main` (merge base `f721222cf4eaacc799aa0c35fe54722868ef7e93`, equal to `origin/main`)
**Head:** `bug/completion-gate-rejects-adopted-feature-folder-992` at `839bfb8242a7ecfb14ab92a3e397f95c0e089f44`
**Scope:** full branch diff `f721222cf4eaacc799aa0c35fe54722868ef7e93..839bfb8242a7ecfb14ab92a3e397f95c0e089f44` (102 files, 5454 insertions, 58 deletions; one commit, `839bfb824 fix(orchestrator-state): waive adopted feature folder with HEAD probe`).

**Code Under Test (non-documentation files):**

- Python production (new): `scripts/dev_tools/_orchestrator_state_feature_folder_record.py`.
- Python production (modified): `scripts/dev_tools/_orchestrator_state_issue_adoption.py`.
- TypeScript production (new): `extensions/drm-copilot/src/lib/validate/orchestrator-state-feature-folder-record.ts`.
- TypeScript production (modified): `extensions/drm-copilot/src/lib/validate/orchestrator-state-issue-adoption.ts`; configuration `extensions/drm-copilot/jest.config.cjs` (one per-file `coverageThreshold` entry).
- PowerShell production (new): `.claude/lib/orchestrator-state/OrchestratorStateFeatureFolderRecord.psm1`, `.claude/hooks/validate-orchestrator-output-feature-folder.ps1`.
- PowerShell production (modified): `.claude/lib/orchestrator-state/OrchestratorStateIssueAdoption.psm1`, `.claude/hooks/validate-orchestrator-output.ps1`; the four byte-identical bundle copies under `extensions/drm-copilot/resources/claude-customizations/.claude/`.
- Tests (new): `tests/scripts/dev_tools/test_orchestrator_state_issue_adoption_feature_folder.py`, `extensions/drm-copilot/test/lib/validate/orchestrator-state-issue-adoption-feature-folder.test.ts`, `tests/scripts/claude-lib/orchestrator-state/OrchestratorStateFeatureFolderRecord.Tests.ps1`, `tests/scripts/claude-hooks/validate-orchestrator-output.FeatureFolder.Tests.ps1`, and 14 corpus fixtures under `tests/fixtures/orchestrator_state_issue_adoption/`.
- Tests (modified): the Python test-support module, the waivers and parity tests in each runtime, `OrchestratorState.Manifest.Tests.ps1`, and the reworked fixture `waives-new-active-feature-folder.json`.
- JSON: `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json`.
- Markdown runtime surfaces: `.claude/rules/orchestrator-state.md`, five skills under `.claude/skills/`, `.agents/skills/feature-promotion-lifecycle/SKILL.md`, and their bundle copies.
- Documentation: the feature folder (issue, spec, plan, research, evidence).

**Coverage Metrics by Language:**

| Language | Files Changed | Tests | Test Result | Baseline Coverage | Post-Change Coverage | New Code Coverage |
|----------|--------------|-------|-------------|-------------------|---------------------|-------------------|
| Python | 2 production, 5 test | 7435 full suite (reviewer run at head) | PASS 7429 passed, 6 skipped, 0 failed | `_orchestrator_state_issue_adoption.py` 100.00% lines (116/116), 100.00% branches (48/48) (`evidence/baseline/python-pytest.2026-10-29T14-16.md`) | repo-wide 94.13% lines (16842/17893), 88.81% branches (5737/6460); changed file 100.00% (118/118) lines, 100.00% (48/48) branches | new module 100.00% lines (42/42), 100.00% branches (14/14) |
| TypeScript | 2 production, 3 test, 1 config | 4172 Jest tests in 282 suites | PASS 0 failed (executor, three seeds) | `orchestrator-state-issue-adoption.ts` 100% lines (324/324), 100% branches (63/63); extension totals 97.41% lines, 92.65% branches | extension totals 97.41% lines (52044/53423), 92.67% branches; changed file 100% (332/332), 100% (66/66) | new module 100% lines (136/136), 100% branches (22/22) |
| PowerShell | 4 production (+4 mirrors), 5 test | 12104 in full single-process `tests/scripts` run | PASS 12094 passed, 0 failed, 10 skipped | repo-wide 92.91% lines (18275/19670); `OrchestratorStateIssueAdoption.psm1` 100.00%; `validate-orchestrator-output.ps1` 99.10% | repo-wide 92.93% lines (18349/19746); changed files 100.00% and 99.16% | new files 100.00% (38/38) and 92.59% (25/27); changed executable lines 12/12 covered |
| JSON | 1 manifest, 48 fixtures (14 new, 1 reworked) | push-down completeness, dependency-closure, and parity suites | PASS | N/A (config and data) | N/A | N/A |
| C# | 0 | — | — | N/A (no changed files) | N/A | N/A |
| Bash | 0 | — | — | N/A (no changed files) | N/A | N/A |

### Coverage Evidence Checklist

- TypeScript baseline coverage artifact: `FEATURE/evidence/baseline/ts-jest.2026-10-29T14-18.md`.
- TypeScript post-change coverage artifact: `extensions/drm-copilot/coverage/lcov.info` and `extensions/drm-copilot/coverage/coverage-summary.json` (written 2026-10-29 15:13Z after the last source change; reviewer parse at head); `FEATURE/evidence/qa-gates/ts-jest.2026-10-29T14-54.md`.
- Python baseline coverage artifact: `FEATURE/evidence/baseline/python-pytest.2026-10-29T14-16.md`.
- Python post-change coverage artifact: `artifacts/python/lcov.info` and `artifacts/python/coverage.json`, regenerated by the reviewer from a full-suite run at head (Section 8, Approved Exceptions).
- PowerShell baseline coverage artifact: `FEATURE/evidence/baseline/ps-pester.2026-10-29T14-35.md`.
- PowerShell post-change coverage artifact: `artifacts/pester/powershell-coverage.xml` (executor full single-process `tests/scripts` run, session 739 s, matching `FEATURE/evidence/qa-gates/ps-pester.2026-10-29T15-15.md`); `FEATURE/evidence/qa-gates/coverage-comparison.2026-10-29T15-16.md`.
- Per-language comparison summary: Section 1.2.1.

`FEATURE` denotes `docs/features/active/2026-10-28-completion-gate-rejects-adopted-feature-folder-992`.

---

## Executive Summary

The branch fixes issue #992. The orchestrator completion gate required a successful `new_active_feature_folder` MCP receipt from the finishing run, so an item whose feature folder was created by an earlier session or a planner could not reach DONE. The branch makes four changes:

- It adds `new_active_feature_folder` to the closed `issue_adoption` waivable set in the Python, TypeScript, and PowerShell validators.
- Waiving the tool now requires a new `issue_adoption.feature_folder_record` object, checked by rules 10 and 11a-11e. The error strings are byte-identical across runtimes and are pinned by a shared corpus (48 fixtures, 14 new).
- It adds a bounded `git -C <root> cat-file -t HEAD:<feature-folder>` probe to the Claude `SubagentStop` hook, behind an injectable invoker seam.
- It updates the rule and skill prose, the bundle mirrors, and `core.json`.

Reviewer verification at head:

- Full Python suite with branch coverage: 7429 passed, 6 skipped. Repo-wide coverage is 94.13% lines and 88.81% branches.
- Parse of the Pester coverage XML: repo-wide 92.93%. Per-file figures match the executor's evidence.
- Parse of the Jest coverage summary: the new and changed files are at 100% lines and 100% branches.
- Toolchain checks on the changed files are clean: Black `--check`, Ruff, and Pyright (Python); Prettier `--check`, ESLint, and `tsc` (TypeScript); PSScriptAnalyzer (PowerShell).
- Codex generator `--check` exits 0, and `check_quality_tiers` reports OK.
- `cmp` mirror parity: 11 of 11 identical. The evidence-location validator exits 0.
- Corpus minimums are 48 in all three parity suites, which matches the directory count.
- By logical line count, the largest changed covered file has 497 lines.

No blocking finding was identified.

**Policy documents evaluated:**
- PASS `CLAUDE.md`, `.claude/rules/general-code-change.md`
- PASS `.claude/rules/general-unit-test.md`, `.claude/rules/quality-tiers.md`
- PASS `.claude/rules/orchestrator-state.md` (the changed rule; prose matches the implementation)

**Language-specific policies evaluated:**
- PASS `.claude/rules/python.md` + `.claude/rules/python-suppressions.md` (no suppression added)
- PASS `.claude/rules/typescript.md` + `.claude/rules/typescript-suppressions.md` (no suppression added)
- PASS `.claude/rules/powershell.md`
- PASS `.claude/rules/self-explanatory-code-commenting.md`
- N/A C#, Bash: no changed files

**Temporary artifacts cleanup:**
- PASS No temporary script is committed. Reviewer parsing and launcher scripts are in the session scratchpad.

---

## Rejected Scope Narrowing

No caller instruction attempted to narrow the audit scope. The caller prompt requested the "full feature-review-workflow skill contract end to end" with "No scope narrowing", and the full branch diff against the merge base was reviewed.

The caller instruction to "use artifacts/pester/powershell-coverage.xml only if it came from a full single-process tests/scripts run" was followed. The reviewer confirmed this from the artifact's 19746-line denominator, its 739 s session duration, and the 12104-test JUnit total. The caller also instructed the reviewer to "Generate Python and TypeScript coverage artifacts if absent". The Python artifact present came from a two-module run, so the reviewer regenerated it (Section 8). The TypeScript artifact was present and current. These are method notes, not scope narrowing.

---

## Evidence Location Compliance

- `git diff --name-only --diff-filter=AM f721222cf..HEAD` filtered for `^artifacts/(baselines|qa|evidence|coverage)/`: no matches.
- `poetry run python scripts/dev_tools/validate_evidence_locations.py --root .`: exit 0.
- All committed evidence is under `FEATURE/evidence/<kind>/` (`baseline`, `other`, `qa-gates`, `regression-testing`).
- Added-line scan of the diff for host-path patterns (`C:/Users`, `C:\Users`, `/home/`, the user name): no matches.

Verdict: PASS.

---

## 1. General Unit Test Policy Compliance

### 1.1 Core Principles

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Independence** - Tests run in any order | PASS | `FEATURE/evidence/regression-testing/isolation.2026-10-29T15-16.md`: Jest `--randomize` seeds 992, 4242, 20261029 (4172 of 4172 each); Python reversed order (112 passed); Pester shuffled file order, six seeds (202 passed each). The hook suite resets `$global:LASTEXITCODE` in `AfterEach`. |
| **Isolation** - Each test targets single behavior | PASS | One rule or branch per test in each runtime; the hook suite has one `It` per probe outcome. |
| **Fast Execution** - Tests complete quickly | PASS | Pure validators and in-memory JSON; no process start. |
| **Determinism** - Consistent results | PASS | Injected scriptblock invokers; `git` is neither executed nor mocked; worktree root is a POSIX literal; reviewer full Python run and executor full Pester run report 0 failures. |
| **Readability & Maintainability** - Clear structure | PASS | Test names state rule and outcome; Python and Jest builders live in the shared support module. |

### 1.2 Coverage and Scenarios

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Baseline Coverage Documented** | PASS | `FEATURE/evidence/baseline/python-pytest.2026-10-29T14-16.md`, `ts-jest.2026-10-29T14-18.md`, `ps-pester.2026-10-29T14-35.md`. |
| **No Coverage Regression** | PASS | Every changed file at or above baseline (Section 1.2.1); PowerShell changed executable lines 12 of 12 covered (`coverage-comparison.2026-10-29T15-16.md`); Python and TypeScript changed files at 100% lines and branches. |
| **New Code Coverage >= 85% line, >= 75% branch** | PASS | Python new module 100%/100%; TypeScript new module 100%/100%; PowerShell new module 100.00% and hook sibling 92.59% (line only; no Pester branch gate). |
| **Comprehensive Coverage** | PASS | Rules 10 and 11a-11e have positive and negative cases in each runtime; the shared corpus pins ordered error lists in three parity suites. |
| **Positive Flows** - Valid inputs | PASS | `valid-large-waives-feature-folder-with-record.json`, `valid-bug-preparation-waives-feature-folder-with-record.json`; hook allow cases (AC-9). |
| **Negative Flows** - Invalid inputs | PASS | Record absent or not an object, path format, mismatch, absent or non-string `feature-folder`, invalid `verified_via`, blank `verified_at` and `evidence`. |
| **Edge Cases** - Boundary conditions | PASS | Dot segment, trailing slash, drive letter, backslash, leading hyphen; record present but tool not waived; tool waived on the `remediation` route. |
| **Error Handling** - Error paths | PASS | Hook blocks on non-zero exit, empty output, `blob`, exit -1, null exit code, and a throwing invoker; the seam returns `ExitCode -1` without throwing. |
| **Concurrency** - If applicable | N/A | Stateless validation and a single probe call. |
| **State Transitions** - If applicable | N/A | No stateful component changed. |

### 1.2.1 Per-Language Coverage Comparison

- Python: Baseline: 100.00% lines, 100.00% branches (`_orchestrator_state_issue_adoption.py`, 116/116 and 48/48) -> Post-change: 100.00% lines, 100.00% branches (118/118 and 48/48); repo-wide 94.13% lines (16842/17893) and 88.81% branches (5737/6460). Change: 0.00 points on the changed file. New/changed-code coverage: 100% (new module `_orchestrator_state_feature_folder_record.py` 42/42 lines and 14/14 branches; every line covered in both files). Thresholds: root `CLAUDE.md` states none, so 85% line and 75% branch defaults govern; met. Disposition: PASS. Evidence: reviewer-regenerated `artifacts/python/coverage.json` and `artifacts/python/lcov.info`; `FEATURE/evidence/baseline/python-pytest.2026-10-29T14-16.md`.
- TypeScript: Baseline: 100% lines, 100% branches (`orchestrator-state-issue-adoption.ts`, 324/324 and 63/63; extension 97.41% lines, 92.65% branches) -> Post-change: 100% lines, 100% branches (332/332 and 66/66; extension 97.41% lines, 92.67% branches). Change: 0.00 points lines, +0.02 points branches extension-wide. New/changed-code coverage: 100% (new module 136/136 lines and 22/22 branches, with a per-file `coverageThreshold` entry). Thresholds 85% line and 75% branch (defaults) met. Disposition: PASS. Evidence: `extensions/drm-copilot/coverage/coverage-summary.json` (reviewer parse); `FEATURE/evidence/baseline/ts-jest.2026-10-29T14-18.md`.
- PowerShell: Baseline: 92.91% lines repo-wide (18275/19670) -> Post-change: 92.93% lines repo-wide (18349/19746). Change: +0.02 points. New/changed-code coverage: 100% (12 of 12 changed executable lines in the two modified files covered). The two new files are at 100.00% (38/38) for `OrchestratorStateFeatureFolderRecord.psm1` and 92.59% (25/27) for `validate-orchestrator-output-feature-folder.ps1`. Modified files: `OrchestratorStateIssueAdoption.psm1` 100.00% -> 100.00% (119/119) and `validate-orchestrator-output.ps1` 99.10% -> 99.16% (118/119). No branch gate applies (Pester). The 85% line default governs and is met. Disposition: PASS. Evidence: reviewer parse of `artifacts/pester/powershell-coverage.xml`; `FEATURE/evidence/qa-gates/coverage-comparison.2026-10-29T15-16.md`.
- C#: no changed files. Disposition: N/A. Evidence: the branch diff contains no `.cs` file.

### 1.3 Test Structure and Diagnostics

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Clear Failure Messages** | PASS | Parity suites compare ordered error lists exactly and name the fixture; hook cases assert the exact block message with `-BeExactly`. |
| **Arrange-Act-Assert Pattern** | PASS | Builders arrange the checkpoint, one call acts, assertions follow. |
| **Document Intent** | PASS | Module docstrings and suite headers state the rule under test and issue #992. |

### 1.4 External Dependencies and Environment

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Avoid External Dependencies** | PASS | No network, no process start, no real git in tests. |
| **Use Mocks/Stubs** | PASS | Recording invokers injected through `-FeatureFolderGitInvoker`; checkpoint read and run resolution mocked in the hook suite. |
| **Environment Stability** | PASS | No `TestDrive`, `New-TemporaryFile`, `tmp_path`, `tempfile`, or `os.tmpdir` in the four new suites (reviewer search). Drive-letter strings appear only as rejected path-pattern inputs. No read of the gitignored `artifacts/` checkpoint. |

### 1.5 Policy Audit Requirement

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Pre-submission Review** | PASS | This document is the required policy audit for the branch head. |

---

## 2. General Code Change Policy Compliance

### 2.1 Before Making Changes

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Clarify the objective** | PASS | `issue.md`, `spec.md`, `research/research.2026-10-29T15-40.md`. |
| **Read existing change plans** | PASS | `FEATURE/evidence/baseline/phase0-instructions-read.2026-10-29T14-14.md`. |
| **Document the plan** | PASS | `plan.2026-10-29T09-53.md`; branch-current plan validation exit 0 (`qa-gates/plan-validation.2026-10-29T15-16.md`). |

### 2.2 Design Principles

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Simplicity first** | PASS | One call added to each resolver; the receipt loops are unchanged because they consume the extended waived set. |
| **Reusability** | PASS | The hook re-uses `Test-OrchestratorStateFeatureFolderPath` from the record module instead of a second pattern copy. |
| **Extensibility** | PASS | `verified_via` is a closed list constant; the hook invoker is an optional parameter. |
| **Separation of concerns** | PASS | Validators are pure (no I/O imports in any record module); git access is isolated in the hook sibling's single seam. |

### 2.3 Module & File Structure

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Cohesive modules** | PASS | Rules 10 and 11 live in one new module per runtime; the hook probe lives in a new sibling file. |
| **File size (tiered policy)** | PASS | Reviewer logical line counts over 27 changed covered files: largest `extensions/drm-copilot/jest.config.cjs` 497, `orchestrator-state-issue-adoption.test.ts` 484. No covered file at or above 700; none above 500. `config/file-size-baseline.json` unchanged. Near-limit files `test_orchestrator_state_issue_adoption.py` and `validate-orchestrator-output.Tests.ps1` unchanged. |
| **Public vs internal** | PASS | PowerShell exports two functions; Python declares `__all__`; TypeScript keeps the field helper unexported. |
| **No circular dependencies** | PASS | Record modules import only the checkpoint-value primitives (PowerShell) or nothing from the adoption module. |

### 2.4 Naming, Docs, and Comments

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Descriptive names** | PASS | `feature_folder_record_errors`, `featureFolderRecordErrors`, `Get-OrchestratorStateFeatureFolderRecordError`, `Get-OrchestratorOutputFeatureFolderDecision`. |
| **Docs/docstrings** | PASS | Google-style docstrings in Python; TSDoc on exported TypeScript functions; comment-based help on every PowerShell function. |
| **Comment why, not what** | PASS | Comments state why rule 11b is gated on 11a and why the hook re-checks the path before git. |

### 2.5 After Making Changes - Toolchain Execution

| Requirement | Status | Evidence |
|------------|--------|----------|
| **1. Formatting** | PASS | Reviewer: Black `--check` 6 files unchanged; Prettier `--check` clean on 6 files. Executor: PoshQC format (`qa-gates/ps-format.2026-10-29T15-15.md`). |
| **2. Linting** | PASS | Reviewer: Ruff "All checks passed!"; ESLint exit 0; PSScriptAnalyzer 0 findings over 9 changed PowerShell files with `pssa.settings.psd1`. |
| **3. Type checking** | PASS | Reviewer: Pyright 0 errors; `npm run typecheck` exit 0. PowerShell: N/A. |
| **4. Architecture-boundary tests** | PASS | `hook-dependency-guard-completeness.Tests.ps1` and `OrchestratorState.Manifest.Tests.ps1` pass in the full Pester run; `check_quality_tiers` OK. |
| **5. Unit tests** | PASS | Reviewer full Python: 7429 passed, 6 skipped. Executor full Pester: 12094 passed, 0 failed, 10 skipped. Jest: 4172 passed. |
| **6. Contract / schema checks** | PASS | Push-down resource, manifest completeness, dependency closure, and skill-contract suites pass within the reviewer full Python run; Codex generator `--check` exit 0 (reviewer); `qa-gates/contracts.2026-10-29T15-12.md`. |
| **7. Integration tests** | PASS | Hook end to end through `Invoke-OrchestratorOutputValidation` with injected invokers; CLI `--require-complete` run on corpus checkpoints (`other/cli-require-complete.2026-10-29T14-51.md`). |
| **Full toolchain loop** | PASS | Executor QA-gate evidence for each stage; reviewer re-runs clean. |
| **Explicit reporting** | PASS | Appendix B and the evidence folder. |

### 2.6 Summarize and Document

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Summarize changes** | PASS | Commit `839bfb824` describes the waiver and probe. |
| **Design choices explained** | PASS | `spec.md` `## Proposed Fix` records the nine defaults adopted from research section 8. |
| **Update supporting documents** | PASS | Rule prose documents the field, rules 10 and 11a-11e, the fail-closed order, the declaration-only disclosure, and the enforcement bullet. |
| **Provide next steps** | PASS | `spec.md` `## Rollout & Follow-up`; AC-22 at S9. |

---

## 3. Language-Specific Code Change Policy Compliance

### Section 3A: Python Code Change Policy Compliance

#### 3A.1 Tooling & Baseline

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Formatting with Black** | PASS | **Command:** `poetry run black --check <6 changed Python files>`<br>**Result:** 6 files would be left unchanged. |
| **Linting with Ruff** | PASS | **Command:** `poetry run ruff check <same files>`<br>**Result:** All checks passed! No suppression added. |
| **Type checking with Pyright** | PASS | **Command:** `poetry run pyright <same files>`<br>**Result:** 0 errors, 0 warnings, 0 informations. |

#### 3A.2 Python Design & Typing

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Type hints** | PASS | All public and private functions annotated; one `cast` after an `isinstance(dict)` check. |
| **Simple design** | PASS | Two functions; module constants for the pattern, values, and error strings. |
| **Absolute imports** | PASS | `from scripts.dev_tools._orchestrator_state_feature_folder_record import ...`. |

#### 3A.3 Python Error Handling

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Explicit failures** | PASS | Errors are returned as literal strings into the existing ordered list; no exception handling added. |

### Section 3B: PowerShell Code Change Policy Compliance

#### 3B.1 Tooling & Baseline

| Requirement | Status | Evidence |
|------------|--------|----------|
| **PowerShell 7+ compatibility** | PASS | PSScriptAnalyzer with repo settings: 0 findings (reviewer). |
| **Baseline captured** | PASS | `FEATURE/evidence/baseline/ps-format.2026-10-29T14-35.md`, `ps-analyze.2026-10-29T14-35.md`, `ps-pester.2026-10-29T14-35.md`. |

#### 3B.2 PowerShell Design & Safety

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Advanced functions** | PASS | `[CmdletBinding()]` and `[OutputType()]` on every new function. |
| **Parameter validation** | PASS | `[AllowNull()]`, `[AllowEmptyString()]`, `[AllowEmptyCollection()]`, `[ValidateNotNull()]` on the invoker. |
| **Seams** | PASS | `Invoke-FeatureFolderGitExe -GitArgs <string[]> [-GitInvoker <scriptblock>]` is the single git seam, following the wrapper pattern; the parameter is not named `Args`. |
| **Hook dependency guard** | PASS | Both new dependencies load through `try { ... } catch { Add-HookDependencyFailure ... }`, so a missing file blocks rather than failing open. |
| **No state-changing action without ShouldProcess** | N/A | The new functions read and compare only. |

#### 3B.3 Structure, Naming, and Comments

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Approved verbs** | PASS | `Get-`, `Test-`, `Invoke-`; `PSUseApprovedVerbs` clean. |
| **Comment-based help** | PASS | `.SYNOPSIS`, `.DESCRIPTION`, `.PARAMETER`, `.OUTPUTS` on each function. |

#### 3B.4 Running the Toolchain

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Format -> analyze -> test** | PASS | `qa-gates/ps-format.2026-10-29T15-15.md` -> `ps-analyze.2026-10-29T15-15.md` -> `ps-pester.2026-10-29T15-15.md`; reviewer PSScriptAnalyzer re-run. |
| **Change budget** | PASS | Four production PowerShell files on the orchestrated large path, which has no production-file cap. |

### Section 3C: TypeScript Code Change Policy Compliance

#### 3C.1 Tooling & Baseline

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Formatting with Prettier** | PASS | **Command:** `npx prettier --check <6 changed TypeScript and config files>`<br>**Result:** All matched files use Prettier code style! |
| **Linting with ESLint** | PASS | **Command:** `npx eslint <changed source and new test>`<br>**Result:** exit 0. No suppression added. |
| **Type checking with TSC** | PASS | **Command:** `npm run typecheck`<br>**Result:** exit 0. |

#### 3C.2 TypeScript Design & Typing

| Requirement | Status | Evidence |
|------------|--------|----------|
| **No `any`; `unknown` plus narrowing** | PASS | Inputs typed `Record<string, unknown>`; `isPlainObject` and `isFeatureFolderPath` are type guards; no `as` assertion. |
| **ES modules, kebab-case file** | PASS | `orchestrator-state-feature-folder-record.ts`; named exports. |
| **Pure logic** | PASS | No I/O, clock, or randomness. |

### Section 3D: JSON Configuration Policy Compliance

#### 3D.1 JSON Tooling

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Valid JSON** | PASS | `core.json` and all 48 fixtures parse; consumed by passing completeness, dependency-closure, and parity suites. |

#### 3D.2 JSON Structure

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Entry placement** | PASS | Both new `.claude` files listed beside their sibling hook and module entries. |

### Section 3E: Bash Script Policy Compliance

#### 3E.1 Tooling & Baseline

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Applicable** | N/A | No `.sh` or `.bats` file changed. |

---

## 4. Language-Specific Unit Test Policy Compliance

### Section 4A: Python Unit Test Policy Compliance

#### 4A.1 Framework and Scope

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Pytest** | PASS | Reviewer full run 7429 passed; new module `test_orchestrator_state_issue_adoption_feature_folder.py` in `tests/scripts/dev_tools/`. |

#### 4A.2 Test Style and Structure

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Parametrized boundary matrices** | PASS | Path-format rejections and rule cases use `pytest.mark.parametrize`. |

#### 4A.3 Naming and Readability

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Descriptive names** | PASS | Names state the rule and expected outcome. |
| **Changed assertion is justified** | PASS | `test_waiving_new_active_feature_folder_is_rejected` now asserts rule 10, per AC-7 and the spec's intended behavior change. |

#### 4A.4 Running the Toolchain

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Black, Ruff, Pyright, Pytest** | PASS | Reviewer runs in Sections 3A.1 and 4A.1. |

### Section 4B: TypeScript Unit Test Policy Compliance

#### 4B.1 Framework and Scope

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Jest** | PASS | New `orchestrator-state-issue-adoption-feature-folder.test.ts` under `test/lib/validate/`, mirroring `src/lib/validate/`. |

#### 4B.2 Test Style and Structure

| Requirement | Status | Evidence |
|------------|--------|----------|
| **One behavior per test** | PASS | `it.each` tables for path rejections; one rule per case. |

### Section 4C: PowerShell Unit Test Policy Compliance

#### 4C.1 Framework and Scope

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Pester 5** | PASS | Run via `Invoke-PoshQCTest` with the repo run settings. |
| **Location mirrors source** | PASS | `tests/scripts/claude-lib/orchestrator-state/` and `tests/scripts/claude-hooks/`. |

#### 4C.2 Test Style and Structure

| Requirement | Status | Evidence |
|------------|--------|----------|
| **One behavior per `It`** | PASS | `-ForEach` data rows for block outcomes and artifact types. |
| **Mocking rules** | PASS | `git` is never mocked; the probe goes through the wrapper seam with an injected scriptblock. |

#### 4C.3 Naming and Readability

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Descriptive `It` names** | PASS | Names state input and decision; `test-name-uniqueness.Tests.ps1` passes in the full run. |

---

## 5. Test Coverage Detail

### Record modules (three runtimes)

| Test | Scenario | Status |
|------|----------|--------|
| Rule 10 | Waived with record absent, `null`, string, array | PASS |
| Rule 11a | Outside prefix, dot segment, trailing slash, backslash, drive letter, leading hyphen, non-string | PASS |
| Rule 11b | Mismatch, absent and non-string `feature-folder` | PASS |
| Rules 11c-11e | Unknown `verified_via`, blank or null `verified_at`, blank or non-string `evidence`, all three in rule order | PASS |
| Record without waiver | Object record validated; non-object record ignored | PASS |

### Shared corpus (Python, Jest, Pester parity)

| Test | Scenario | Status |
|------|----------|--------|
| 48 fixtures | 14 new and 1 reworked case for the feature-folder waiver; 33 pre-existing cases unchanged | PASS |

### Hook probe (`validate-orchestrator-output.FeatureFolder.Tests.ps1`)

| Test | Scenario | Status |
|------|----------|--------|
| AC-9 rows | `tree` with exit 0 allows, directly and through `Invoke-OrchestratorOutputValidation` | PASS |
| AC-10 rows | Exit 128, empty, `blob`, -1, null exit code, throwing invoker; block surfaced end to end | PASS |
| AC-11 rows | Fixed argument list; no call when not waived, for epic and parallel types, for a failing path, or for malformed `issue_adoption` | PASS |
| Seam rows | `Invoke-FeatureFolderGitExe` returns -1 on throw and trims output | PASS |

---

## 6. Test Execution Metrics

| Metric | Value |
|--------|-------|
| Python full suite (reviewer) | 7429 passed, 6 skipped, 0 failed (73.7 s) |
| Pester full single-process run (executor) | 12104 cases: 12094 passed, 0 failed, 10 skipped |
| Jest (executor, three seeds) | 4172 passed each |
| Pester seeded shuffles (executor, six seeds, six suites) | 202 passed each |
| Python line / branch coverage (repo-wide, reviewer) | 94.13% / 88.81% |
| PowerShell line coverage (repo-wide) | 92.93% (18349 of 19746) |
| TypeScript line / branch coverage (extension) | 97.41% / 92.67% |

---

## 7. Code Quality Checks

| Check | Result | Evidence |
|-------|--------|----------|
| PSScriptAnalyzer | PASS | 0 findings, 9 files (reviewer direct run) |
| Black / Ruff / Pyright | PASS | Reviewer runs on 6 changed Python files |
| Prettier / ESLint / TSC | PASS | Reviewer runs |
| Mirror parity | PASS | `cmp`: 10 `.claude` files and 1 `.agents` file identical to their bundle copies |
| Codex generator `--check` | PASS | exit 0 (reviewer) |
| Quality tiers | PASS | `quality-tiers.yml` exists on the base; `check_quality_tiers`: OK (26 entries, 26 discovered projects). Touched projects are T3 (`.claude/hooks`, `.claude/lib/orchestrator-state`, `extensions/drm-copilot`) and T4 (`scripts/dev_tools`), so no property-test or mutation gate applies. |
| Coverage exclusions | PASS | No `exclude`/`omit` change in `jest.config.cjs`, `config/poshqc-coverage.json`, or `pyproject.toml` |
| Stale wording | PASS | The only "can never be waived" sentence lists `new_active_feature_folder` as waivable with a valid record |
| Forbidden-path scope | PASS | No change under `.codex/`, `.github/`, or `.claude/agents/` |

---

## 8. Gaps and Exceptions

### Identified Gaps

- Info (code review): `Invoke-FeatureFolderGitExe` reads `$LASTEXITCODE` after the invoker runs. An injected invoker that does not set it would observe a stale value. The production default always runs git, which sets it, so the risk applies only to future test invokers.
- Info (code review): the two uncovered lines of the hook sibling are the default real-git invoker. Real-git behavior is confirmed only by the one-time manual probe (AC-19), not by an automated test, by design.
- Info: `jest.config.cjs` is at 497 lines, close to the 500-line guidance tier.
- AC-22 is pending CI by design.

### Approved Exceptions

- Python coverage artifact regeneration by the reviewer. The `artifacts/python/lcov.info` present at review start was written by the executor's final run, which used `--cov=` on two modules only. It listed two source files, so it could not support a repo-wide verdict, and `coverage.json` predated the change. The reviewer backed up the executor artifact to the session scratchpad. The reviewer then ran `poetry run pytest --cov --cov-branch -q -p no:cacheprovider --cov-report=json:artifacts/python/coverage.json` at head, and pyproject `addopts` also writes `lcov.info`. Result: 7429 passed, repo-wide 94.13% lines and 88.81% branches. The per-file figures for the two changed modules match the executor's. The output is gitignored and not part of the branch diff.
- TypeScript coverage artifact location. The table path `coverage/lcov.info` resolves to `extensions/drm-copilot/coverage/lcov.info` for this repository, because the Jest project root is the extension. That artifact was present, written after the last source change, and used as is.

### Removed/Skipped Tests

- No test was removed. Three existing assertions that `new_active_feature_folder` cannot be waived were rewritten to assert rule 10 (AC-7). The 10 Pester and 6 Python skips are pre-existing and outside the branch's suites.

---

## 9. Summary of Changes

### Commits in This PR/Branch

- `839bfb824` fix(orchestrator-state): waive adopted feature folder with HEAD probe

### Files Modified

- Production: 3 new modules (Python, TypeScript, PowerShell) and 1 new hook sibling; 4 modified production files; 4 bundle copies.
- Tests: 4 new suites, 14 new fixtures, 7 modified test or support files, 1 reworked fixture.
- Runtime Markdown: 1 rule and 6 skills, plus their bundle copies; `core.json`; `jest.config.cjs`.
- Documentation: feature folder (issue, spec, plan, research, evidence).

---

## 10. Compliance Verdict

### Overall Status: FULLY COMPLIANT

All applicable policy checks pass. Observations are Info only.

### Policy-by-Policy Summary

#### General Code Change Policy (Section 2)

- PASS: design, structure, naming, file size, and the seven-stage toolchain.

#### Language-Specific Code Change Policy (Section 3)

- PASS: Python, PowerShell, TypeScript, JSON; N/A: Bash, C#.

#### General Unit Test Policy (Section 1)

- PASS: principles, coverage (Python PASS, TypeScript PASS, PowerShell PASS), scenarios, and environment.

#### Language-Specific Unit Test Policy (Section 4)

- PASS: Pytest, Jest, and Pester.

### Metrics Summary

| Metric | Value |
|--------|-------|
| Blocking findings | 0 |
| Non-blocking findings | 0 Minor, 5 Info (code review) |
| New-module coverage (lines) | Python 100%, TypeScript 100%, PowerShell 100.00% and 92.59% |
| Largest changed covered file | 497 lines |

### Recommendation

Proceed to the PR creation gate. AC-22 remains pending CI and is checked off by the item's own orchestrator run at S9.

---

## Appendix A: Test Inventory

### Complete Test List

- `tests/scripts/dev_tools/test_orchestrator_state_issue_adoption_feature_folder.py` (new)
- `tests/scripts/dev_tools/test_orchestrator_state_issue_adoption_waivers.py` (rule-10 rewrite)
- `tests/scripts/dev_tools/test_orchestrator_state_issue_adoption_parity.py` (minimum 48)
- `extensions/drm-copilot/test/lib/validate/orchestrator-state-issue-adoption-feature-folder.test.ts` (new)
- `extensions/drm-copilot/test/lib/validate/orchestrator-state-issue-adoption.test.ts` (rule-10 rewrite)
- `extensions/drm-copilot/test/lib/validate/orchestrator-state-issue-adoption-parity.test.ts` (minimum 48)
- `tests/scripts/claude-lib/orchestrator-state/OrchestratorStateFeatureFolderRecord.Tests.ps1` (new)
- `tests/scripts/claude-lib/orchestrator-state/OrchestratorStateIssueAdoption.Tests.ps1` (rule-10 rewrite)
- `tests/scripts/claude-lib/orchestrator-state/OrchestratorStateIssueAdoption.Parity.Tests.ps1` (minimum 48)
- `tests/scripts/claude-lib/orchestrator-state/OrchestratorState.Manifest.Tests.ps1` (new module path)
- `tests/scripts/claude-hooks/validate-orchestrator-output.FeatureFolder.Tests.ps1` (new)

---

## Appendix B: Toolchain Commands Reference

```powershell
# Linting (reviewer, 9 changed PowerShell files)
Invoke-ScriptAnalyzer -Path <file> -Settings scripts/powershell/PoshQC/settings/pssa.settings.psd1 -Severity Error, Warning, Information
```

```bash
# Python
poetry run black --check <changed Python files>
poetry run ruff check <changed Python files>
poetry run pyright <changed Python files>
poetry run pytest --cov --cov-branch -q -p no:cacheprovider --cov-report=json:artifacts/python/coverage.json

# TypeScript (in extensions/drm-copilot)
npx prettier --check <changed files>
npx eslint <changed files>
npm run typecheck

# Contracts and scope
poetry run python -m scripts.dev_tools.generate_codex_agent_variants --check
poetry run python -m scripts.dev_tools.check_quality_tiers
poetry run python scripts/dev_tools/validate_evidence_locations.py --root .
```
