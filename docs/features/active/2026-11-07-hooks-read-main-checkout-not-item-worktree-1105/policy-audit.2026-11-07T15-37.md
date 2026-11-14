# Policy Compliance Audit: SubagentStop Hooks Resolve the Item Worktree (Issue #1105)

**Audit Date:** 2026-11-07
**Branch:** `bug/hooks-read-main-checkout-1105` @ `98028900a19973e8467846b5962170488529c5b1`
**Base:** `main`; merge base `bad886e304990d26af56d6bcabc9d543518492e9` (equal to `origin/main` after a fetch, and resolved the same way in `artifacts/pr_context.summary.txt`, generated 2026-11-07 15:28:03 UTC for this head)
**Work Mode:** full-bug (AC source: `spec.md` `## Acceptance Criteria`)
**Review type:** First review. No pull request is open for this branch.
**Code Under Test:**
- New: `.claude/hooks/subagentstop-target-worktree.ps1` (292 logical lines) and `.claude/hooks/validate-feature-review-coverage-freshness.ps1` (145)
- Edited: `validate-task-researcher-output.ps1` (334), `validate-prd-feature-output.ps1`, `validate-required-artifact-output.ps1`, `validate-planner-output.ps1` (469), `validate-executor-output.ps1` (400), `validate-feature-review-coverage.ps1`, `validate-feature-review-coverage-metrics.ps1`, `validate-feature-review-coverage-rules.ps1`, all under `.claude/hooks/`
- Ten byte-identical bundle copies under `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/`, two new `core.json` pack entries, and six byte-identical copies of `execution-environment/SKILL.md`
- Eight new Pester suites under `tests/scripts/claude-hooks/`
- Feature folder documents, evidence, and the promoted lifecycle record

The branch diff is 54 files over 27 commits. This audit covers all of them.

**Coverage Metrics by Language:**

| Language | Files Changed | Tests | Test Result | Baseline Coverage | Post-Change Coverage | New Code Coverage |
|----------|--------------|-------|-------------|-------------------|---------------------|-------------------|
| PowerShell | 10 production, 8 test (plus 10 bundle copies) | 15671 | 0 failed, 0 errors, 10 disabled | 94.01% lines repo-wide | 94.05% lines repo-wide (24217 of 25749) | 100.00% and 97.96% on the two new files; 98.31% to 100.00% on the eight edited hooks |
| Python | 0 files | 16179 passed, 6 skipped | 0 failed | N/A - zero changed Python files | N/A - zero changed Python files | N/A |
| TypeScript | 0 files | N/A | N/A | N/A - zero changed TypeScript files | N/A - zero changed TypeScript files | N/A |
| C# | 0 files | N/A | N/A | N/A - zero changed C# files | N/A - zero changed C# files | N/A |
| Bash | 0 files | N/A | N/A | N/A - zero changed Bash files | N/A - zero changed Bash files | N/A |

PowerShell verdict: PASS. Thresholds: the root `CLAUDE.md` states no coverage figure, so the defaults of 85% line and 75% branch govern. Pester measures no branch figure, so no branch threshold applies to PowerShell. `pack-manifests/core.json` is the only JSON file changed; it has no coverage measure.

### Coverage Evidence Checklist

- TypeScript baseline coverage artifact: N/A - zero changed TypeScript files
- TypeScript post-change coverage artifact: N/A - zero changed TypeScript files
- PowerShell baseline coverage artifact: `evidence/baseline/pester-parallel.2026-11-07T14-41.md` (repo-wide 94.01%, 24046 covered, 1532 not covered)
- PowerShell post-change coverage artifact: `artifacts/pester/powershell-coverage.xml` in the item worktree, parsed by the reviewer (root LINE 24217 covered, 1532 not covered, 94.05%), equal to `evidence/qa-gates/pester-parallel.2026-11-07T15-20.md`
- Python baseline coverage artifact: N/A - zero changed Python files
- Python post-change coverage artifact: N/A - zero changed Python files
- Per-language comparison summary: section 1.2.1 of this audit and `evidence/qa-gates/baseline-comparison.2026-11-07T15-23.md`
- Artifact provenance note: the report was written at 15:20:34 UTC. The newest commit touching a `*.ps1`, `*.psm1`, or `*.psd1` file is at 15:09:01 UTC, and every later commit changes Markdown only, so the report describes this head. The reviewer's own Pester run used plain `Invoke-Pester` without coverage, so it left the report unchanged.
- Main checkout note: the main checkout was not read. Its coverage files belong to another branch and were not judged.

---

## Executive Summary

The branch makes the SubagentStop artifact hooks (researcher, `prd-feature`, required-artifact, planner, executor) and the feature-review coverage hook resolve advertised artifact paths against the item worktree that produced them. A new helper, `subagentstop-target-worktree.ps1`, calls the existing `Resolve-HookTargetWorktree` with an absolute advertised path or with the delegation prompt read from the transcript. A new sibling, `validate-feature-review-coverage-freshness.ps1`, blocks a review in an item worktree whose coverage report is absent or older than the newest commit touching that language.

Verification by the reviewer:

- **Gates.** PSScriptAnalyzer and `Invoke-Formatter` over the 18 changed non-bundle PowerShell files: 0 findings, 0 differences. Pester over the 29 suites of the edited hooks and the three guard suites: 1475 tests, 0 failed. The six named Python contract modules: 126 passed.
- **Mirrors.** The ten bundle hook copies are byte-identical to their sources (`cmp`), and the six brief copies share one SHA-256.
- **Coverage.** Parsed from the item worktree's report; all figures match the executor's gate evidence.
- **Probes.** The reviewer ran the helper and the coverage hook in a real process with injected seams across eleven identity and path shapes. Nine behave as the spec states. Two prompt shapes that the model-routing gate admits do not resolve here (finding F1).

One blocking finding, F1, class `autonomous`. The verdict is `REMEDIATION_REQUIRED`.

**Policy documents evaluated:**
- ✅ `.claude/rules/general-code-change.md`
- ✅ `.claude/rules/general-unit-test.md`
- ✅ `.claude/rules/quality-tiers.md` (`quality-tiers.yml` exists; `.claude/hooks` is classified T3)
- ✅ `.claude/rules/tonality.md`

**Language-specific policies evaluated:**
- ✅ `.claude/rules/powershell.md`
- N/A Python, TypeScript, C#, Bash (zero changed files)

**Temporary artifacts cleanup:**
- ✅ `git status --short` at head was empty before the review began.
- ✅ Reviewer probe scripts live in the session scratchpad outside the repository. No test or production file was modified.

---

## Rejected Scope Narrowing

None. The caller prompt directs a full-branch review against the merge base of `origin/main` and `HEAD`, and every changed file was audited. The caller statement "Coverage figures come from the executor's final gate evidence under evidence/qa-gates/ ... not from any file in the main checkout" names an evidence source; it removes no language and no check. The reviewer parsed the item worktree's own report and confirmed the evidence figures.

---

## Modified-Workflow Rule

`modified-workflow-needs-green-run` does not fire. The branch diff contains no path under `.github/workflows/`, `scripts/benchmarks/`, or `.github/actions/`.

## Evidence Location Compliance

`validate_evidence_locations.py --root <item worktree>` exited 0. A scan of the branch diff found no path under `artifacts/`. All evidence lies under `<FEATURE>/evidence/baseline/`, `evidence/qa-gates/`, `evidence/regression-testing/`, and `evidence/other/`.

---

## 1. General Unit Test Policy Compliance

### 1.1 Core Principles

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Independence** - Tests run in any order | ✅ PASS | Mocks are registered per `It` or per `Describe`; no suite writes state another suite reads. The parallel gate ran them in 8 shards with 0 failures, and the reviewer's single-process run also passed. |
| **Isolation** - Each test targets single behavior | ✅ PASS | One resolution source, probe case, or freshness rule per `It`. |
| **Fast Execution** - Tests complete quickly | ✅ PASS | All 106 new tests use in-memory seams; no test starts a process. |
| **Determinism** - Consistent results | ✅ PASS | Transcript, worktree list, git, report time, and file reads are injected (`ReadTranscriptHead`, `WorktreeListInvoker`, `GitInvoker`, and mocks of the hooks' file seams); commit times are constants. |
| **Readability & Maintainability** - Clear structure | ✅ PASS | `It` names state the expected outcome; each suite has a synopsis naming the hook and the issue. |

### 1.2 Coverage and Scenarios

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Baseline Coverage Documented** | ✅ PASS | `evidence/baseline/pester-parallel.2026-11-07T14-41.md` with per-file figures for the eight edited hooks. |
| **No Coverage Regression** | ✅ PASS | Repo-wide 94.01% to 94.05%; no edited hook dropped; 0 changed executable lines uncovered (`baseline-comparison.2026-11-07T15-23.md`). |
| **New Code Coverage** | ✅ PASS | `subagentstop-target-worktree.ps1` 100.00% (73 of 73); `validate-feature-review-coverage-freshness.ps1` 97.96% (48 of 49). |
| **Modified Files** | ✅ PASS | Eight edited hooks from 98.31% to 100.00%, read by the reviewer from the same report. |
| **Comprehensive Coverage** | ✅ PASS | The one line not run in the freshness file is the default `GitInvoker` value, which runs real `git` and is replaced in every test. |
| **Positive Flows** - Valid inputs | ✅ PASS | Item-only and absolute-inside-item cases in all six hook suites; fresh-report cases in the freshness suite. |
| **Negative Flows** - Invalid inputs | ✅ PASS | Main-only, absolute-outside-every-worktree, absent summary, and absent and stale report cases. |
| **Edge Cases** - Boundary conditions | ✅ PASS | Both-checkouts case; root equal to session root by case and trailing slash; report time equal to commit time. |
| **Error Handling** - Error paths | ✅ PASS | Transcript reader throws; resolver throws; git non-zero, empty, non-integer, and throwing. |
| **Concurrency** - If applicable | N/A | Hooks are single-invocation processes with no shared mutable state. |
| **State Transitions** - If applicable | N/A | No stateful component is added. |

### 1.2.1 Per-Language Coverage Comparison

- PowerShell: Baseline: 94.01% repo-wide lines -> Post-change: 94.05% repo-wide lines. Change: +0.04% lines. New/changed-code coverage: 100.00% on `subagentstop-target-worktree.ps1` (73 of 73) and 97.96% on `validate-feature-review-coverage-freshness.ps1` (48 of 49); edited hooks 98.31% (researcher), 100.00% (`prd-feature`), 98.68% (required-artifact), 99.54% (planner), 100.00% (executor), 100.00% (coverage), 100.00% (metrics), 98.99% (rules); 0 changed executable lines uncovered. Disposition: PASS. Evidence: `artifacts/pester/powershell-coverage.xml`, `evidence/baseline/pester-parallel.2026-11-07T14-41.md`, `evidence/qa-gates/pester-parallel.2026-11-07T15-20.md`, `evidence/qa-gates/baseline-comparison.2026-11-07T15-23.md`. Branch figure: Pester measures none, and no branch threshold applies.
- Python: zero changed files; no comparison is owed. The contract modules ran and passed.
- TypeScript: zero changed files; no comparison is owed.
- C#: zero changed files; no comparison is owed.

Bundle copies under `extensions/drm-copilot/resources/` are byte-identical to their sources (`cmp`), and the sources are measured.

### 1.3 Test Structure and Diagnostics

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Clear Failure Messages** | ✅ PASS | Assertions match exact message stems and probed paths; `Should -Invoke ... -ParameterFilter` names the read location. |
| **Arrange-Act-Assert Pattern** | ✅ PASS | Marked in multi-step tests. |
| **Document Intent** | ✅ PASS | Suite synopses state scope and that no test creates a file. |

### 1.4 External Dependencies and Environment

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Avoid External Dependencies** | ✅ PASS | No new test runs git, reads the real worktree list, or reads `artifacts/`; a search of the new suites for `& git` and `git -C` returned no match. |
| **Use Mocks/Stubs** | ✅ PASS | The hooks' own file seams and injected script blocks. |
| **Environment Stability** | ✅ PASS | A search of the eight new suites for `TestDrive`, `New-TemporaryFile`, `GetTempFileName`, `Set-Content`, `Out-File`, and `New-Item` returned no match. Fixture roots are `/synthetic-worktrees/...` forward-slash paths, safe on the Linux hook-suite job. |

### 1.5 Policy Audit Requirement

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Pre-submission Review** | ✅ PASS | This audit, with `code-review.2026-11-07T15-37.md` and `feature-audit.2026-11-07T15-37.md`; executor self-review `evidence/qa-gates/self-review.2026-11-07T15-25.md`. |

---

## 2. General Code Change Policy Compliance

### 2.1 Before Making Changes

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Clarify the objective** | ✅ PASS | `spec.md` and `research/research.2026-11-07T13-55.md`. |
| **Read existing change plans** | ✅ PASS | `plan.2026-11-07T08-48.md`; `evidence/other/preflight-fixes.2026-11-07T14-27.md`. |
| **Document the plan** | ✅ PASS | The plan, with one commit per task. |

### 2.2 Design Principles

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Simplicity first** | ✅ PASS | One helper shared by six hooks; one freshness sibling. |
| **Reusability** | ✅ PASS | `Resolve-HookTargetWorktree` is reused unchanged; no second resolver. The transcript readers moved without change. |
| **Extensibility** | ✅ PASS | Seams are optional parameters with production defaults. |
| **Separation of concerns** | ✅ PASS | Resolution and conversion live in the helper, freshness in its own sibling, and file reads stay behind named seams. |

### 2.3 Module & File Structure

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Cohesive modules** | ✅ PASS | Helper: resolution and path conversion. Freshness sibling: report freshness only. |
| **At or below the 800-line hard limit** | ✅ PASS | Logical line counts by `@(Get-Content).Count` over every changed covered file: largest `validate-planner-output.ps1` at 469. No file reaches 700. `config/file-size-baseline.json` is not in the diff. |
| **Public vs internal** | ✅ PASS | Hooks keep their entry functions; new parameters are optional seams. |
| **No circular dependencies** | ✅ PASS | Hooks load the helper; the helper imports only `HookTargetWorktree.psm1`; the freshness sibling loads nothing. |

### 2.4 Naming, Docs, and Comments

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Descriptive names** | ✅ PASS | `Resolve-SubagentStopArtifactLocation`, `Get-FeatureReviewCoverageFreshnessDecision`. |
| **Docs/docstrings** | ✅ PASS | Comment-based help on every new function and changed entry function. |
| **Comment why, not what** | ✅ PASS | Comments name issue #1105 and the unchanged session-root case. |

### 2.5 After Making Changes - Toolchain Execution

| Requirement | Status | Evidence |
|------------|--------|----------|
| **1. Formatting** | ✅ PASS | Reviewer `Invoke-Formatter` over 18 changed non-bundle files at this head: 0 differences. |
| **2. Linting** | ✅ PASS | Reviewer PSScriptAnalyzer with `pssa.settings.psd1` over the same 18 files: 0 findings. |
| **3. Type checking** | N/A | Does not apply to PowerShell; no Python or TypeScript changed. |
| **4. Testing** | ✅ PASS | Executor gate: 15671 Pester tests, 0 failed; 16179 pytest passed, 0 failed. Reviewer runs: 1475 Pester tests in 32 files, 0 failed; 126 contract pytest tests, 0 failed. |
| **Full toolchain loop** | ✅ PASS | One clean pass recorded under `evidence/qa-gates/`. |
| **Explicit reporting** | ✅ PASS | Each evidence file carries command, exit code, and summary. |

### 2.6 Summarize and Document

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Summarize changes** | ✅ PASS | Section 9. |
| **Design choices explained** | ✅ PASS | `spec.md` Proposed Fix and the data-flow table. |
| **Update supporting documents** | ✅ PASS | `## Hook Execution Context` updated in all six byte-identical brief copies. |
| **Provide next steps** | ✅ PASS | Section 10 and `remediation-inputs.2026-11-07T15-37.md`. |

---

## 3. Language-Specific Code Change Policy Compliance

### Section 3B: PowerShell Code Change Policy Compliance

#### 3B.1 Tooling & Baseline

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Formatting with Invoke-Formatter** | ✅ PASS | 0 differences, reviewer run. |
| **Linting with PSScriptAnalyzer** | ✅ PASS | 0 findings, reviewer run. |
| **Fix all findings** | ✅ PASS | None open. |
| **PowerShell 5.1 & 7.6+ compatible** | ✅ PASS | The hooks already require PowerShell 7. |

#### 3B.2 PowerShell Design & Safety

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Advanced functions** | ✅ PASS | `CmdletBinding` and `OutputType` on every new function. |
| **Parameter validation** | ✅ PASS | `Mandatory`, `AllowNull`, `AllowEmptyString`, and `AllowEmptyCollection` used as intended. |
| **Avoid global state** | ✅ PASS | Neither new file holds script-scope state. |
| **Error handling** | ✅ PASS | Resolver failures map to the session root with a detail; git failures fail closed; dependency load failures use the guarded path. |

#### 3B.3 Structure, Naming, and Comments

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Cohesive and at or below the 800-line hard limit** | ✅ PASS | See 2.3. |
| **Approved verbs** | ✅ PASS | `Get`, `Read`, `Resolve`, `Test`. |
| **Comment why** | ✅ PASS | See 2.4. |

#### 3B.4 Running the Toolchain

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Step 1: Format** | ✅ PASS | Executor gate and reviewer run. |
| **Step 2: Analyze** | ✅ PASS | Executor gate and reviewer run. |
| **Step 3: Type check** | N/A | Does not apply to this language. |
| **Step 4: Test** | ✅ PASS | Executor `Invoke-PoshQCParallelTest` `ExitCode` 0; reviewer scoped run 0 failed. |
| **Rerun loop if needed** | ✅ PASS | No rerun was needed. |

### Enforcement-Hook Constraints

| Requirement | Status | Evidence |
|------------|--------|----------|
| **No Python in enforcement hooks** | ✅ PASS | Added lines under `.claude/hooks/` mention Python only as a language name and report path; `enforcement-hooks-no-python-invocation.Tests.ps1` 33 of 33 passed in the reviewer run. |
| **Guarded dependency loading** | ✅ PASS | Each hook loads the helper and the freshness sibling with the single-statement `try`/`Add-HookDependencyFailure` pattern; `hook-dependency-guard-completeness.Tests.ps1` 671 of 671 and `hook-dependency-failure.Claude.Tests.ps1` 191 of 191 passed. |
| **Bundle mirrors and pack manifest** | ✅ PASS | Ten `cmp` matches; two `core.json` entries in sorted position; manifest contract modules passed. |
| **Compatibility with the delegation-identity contract and public behavior** | ❌ FAIL | F1: two prompt shapes that the model-routing gate admits do not resolve in the helper, and a main-checkout review with either shape can no longer stop cleanly (see section 8). |

---

## 4. Language-Specific Unit Test Policy Compliance

### Section 4B: PowerShell Unit Test Policy Compliance

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Use Pester v5.x** | ✅ PASS | Pester 5 configuration objects. |
| **Use PoshQC Configuration** | ✅ PASS | Gate evidence from `Invoke-PoshQCParallelTest`. |
| **Focused Unit Tests** | ✅ PASS | One behavior per `It`. |
| **Organization / File Naming** | ✅ PASS | `tests/scripts/claude-hooks/<hook>.TargetWorktree.Tests.ps1` mirrors `.claude/hooks/`. |
| **Use PoshQCTest Command** | ✅ PASS | Gate runs through PoshQC; the reviewer's plain `Invoke-Pester` run is verification only. |

---

## 5. Test Coverage Detail

| Subject | Tests | Scenario Types | Status |
|---------|-------|----------------|--------|
| Helper (`subagentstop-target-worktree.Tests.ps1`) | 28 | FilePath, DelegationPrompt, SessionRoot sources; path conversion; target note | ✅ |
| Freshness (`validate-feature-review-coverage-freshness.Tests.ps1`) | 18 | Absent summary, absent and stale report, fresh report, git failure modes, session-root skip | ✅ |
| Researcher, `prd-feature`, required-artifact, planner suites | 7, 9, 8, 7 | Item-only, main-only, both, absolute, not-derivable and ambiguous | ✅ |
| Executor suite | 14 | Same cases for `plan-path` and `preflight-fix-record` (#1034) | ✅ |
| Coverage hook suite | 15 | Review artifacts (#1031), summary, `CLAUDE.md`, reports, unresolved target (#1097) | ✅ |

**Reviewer probes.** A real-process run of `Resolve-SubagentStopTargetWorktree` and `Invoke-FeatureReviewCoverageValidation`, with an injected worktree list and transcript, over eleven shapes: no identity, branch only (item), branch naming the session root, issue line only, branch with issue line, branch with a later `base branch:` mention, absolute inside the item, absolute outside every worktree, absolute inside the session root, a `..` relative value, and an absolute value equal to the item root. The issue-only and later-mention shapes produce F1.

**Test gaps.** No test covers a prompt with an issue line and no `branch:` label, or a prompt with a second `branch:` token after the item label (F1).

---

## 6. Test Execution Metrics

| Metric | Value | Status |
|--------|-------|--------|
| Total Pester Tests (executor gate) | 15671 | ✅ |
| Pester Failed (executor gate) | 0 failures, 0 errors, 10 disabled | ✅ |
| Pester Wall-clock (executor gate) | 473.88 s, 8 workers | ✅ |
| Reviewer Pester (32 files) | 1475 passed, 0 failed | ✅ |
| Pytest (executor gate) | 16179 passed, 6 skipped, 0 failed | ✅ |
| Reviewer pytest (6 contract modules) | 126 passed | ✅ |
| PowerShell line figure | 94.05% repo-wide | ✅ |

---

## 7. Code Quality Checks

**For PowerShell:**

| Check | Command | Result | Status |
|-------|---------|--------|--------|
| Invoke-Formatter | `Invoke-Formatter -ScriptDefinition <text> -Settings <pssa settings>` per changed file | 0 differences on 18 files (reviewer) | ✅ |
| PSScriptAnalyzer | `Invoke-ScriptAnalyzer -Path <file> -Settings <pssa settings>` | 0 findings on 18 files (reviewer) | ✅ |
| Pester Tests | `Invoke-PoshQCParallelTest -Root <worktree root>` | 15671 tests, 0 failed (executor) | ✅ |

---

## 8. Gaps and Exceptions

### Identified Gaps

1. **F1 (Major, blocking, `autonomous`): the helper's prompt identity reading diverges from the model-routing gate.** `Resolve-SubagentStopTargetWorktree` passes the whole prompt to `Resolve-HookTargetWorktree` without a `CheckpointIssueReader`. The model-routing gate (`Resolve-WorktreeItemTarget`) admits a prompt with only the canonical issue line, and reads only the first `branch:` occurrence, as `.claude/skills/orchestrate/SKILL.md` `## Issue Number Consistency` states. Reviewer probes in a real process show:
   - an issue-line-only prompt returns `TARGET_WORKTREE_NOT_DERIVABLE` ("cannot be placed without a checkpoint issue reader");
   - a prompt with `branch: <item>` followed by `base branch: main` returns `TARGET_WORKTREE_AMBIGUOUS`.

   For the coverage hook both block repairably, and a repairable block re-fires under `stop_hook_active`. In a main-checkout session the advised remedy (absolute paths) resolves to the session root and is then rejected by the unchanged location rule, so the review cannot stop cleanly; before this branch the same review passed. In an item-worktree session, the artifact hooks fall back to the session root for these prompts, which is the original #1105 behavior. Details and the required change are in `code-review.2026-11-07T15-37.md` and `remediation-inputs.2026-11-07T15-37.md`.
2. **F2 (Minor, non-blocking): the executor hook reads the transcript head twice** for a relative `plan-path`, once for resolution and once in `Test-IsPreflightRun`. `spec.md` sets one 50-line read per invocation.
3. **F3 (Nit, non-blocking): `..` segments in a relative value are joined beneath the item root unchanged.** The class pre-dates the branch, and the shape rules were never path-normalizing.
4. **CI on this head.** The CI-dependent criterion is pending CI; S9 owns it.

### Approved Exceptions

**None.** The fail-before runs were replaced by `evidence/regression-testing/fail-before-exception.2026-11-07T15-07.md`, which cites the merge-base code for each new suite under the owner's parallel-only test rule. The reviewer accepts it as alternative proof.

### Removed/Skipped Tests

**None.** No pre-existing test file is in the diff (`--name-status` lists only added suites).

---

## 9. Summary of Changes

### Commits in This PR/Branch

1. `bdafc74b8` to `2303bba5a`: promoted record, research, spec, plan, preflight fixes.
2. `f64780dbc` to `18c2d2b5e`: Phase 0 policy reads and baselines.
3. `a944976a2`, `42fa93f9f`: helper and freshness sibling.
4. `677a9521f` to `2c6903775`: six hook edits, one per hook family.
5. `8991cc797`, `37299134d`, `bcaf30939`: fail-before dossier, bundle mirrors and manifest, brief copies.
6. `ac606f314` to `98028900a`: gates, comparison, CI handoff, self-review, and check-off of AC-01 to AC-15.

### Files Modified

1. Two new and eight edited hooks under `.claude/hooks/`, with ten bundle copies.
2. `pack-manifests/core.json`; six `execution-environment/SKILL.md` copies.
3. Eight new Pester suites; feature folder documents and evidence.

---

## 10. Compliance Verdict

### Overall Status: ❌ FAIL (remediation required)

One blocking finding, F1, class `autonomous`.

### Policy-by-Policy Summary

#### General Code Change Policy (Section 2)
- ❌ Public APIs and compatibility: F1
- ✅ Design, structure, naming, documents, toolchain loop

#### Language-Specific Code Change Policy (Section 3)
- ✅ PowerShell tooling, design, and structure; Python-free and guarded hook loading
- ❌ Compatibility with the delegation-identity contract: F1

#### General Unit Test Policy (Section 1)
- ✅ Core principles, external dependencies, coverage for the one changed language

#### Language-Specific Unit Test Policy (Section 4)
- ✅ PowerShell

### Metrics Summary

- ✅ 15671 Pester tests, 0 failed; 16179 pytest passed, 0 failed
- ✅ 94.05% PowerShell repo-wide lines; new files 100.00% and 97.96%
- ✅ Evidence locations clean; no workflow path changed; mirrors byte-identical

### Recommendation

**Remediate F1 before the pull request.** Read only the first `branch:` label in the helper and resolve an issue-line-only prompt the way the gate does, correct the coverage hook's remedy text for the session root, and add tests for both prompt shapes. F2 and F3 are recommended for the same cycle.

---

## Appendix A: Test Inventory

Pester (new): `subagentstop-target-worktree.Tests.ps1`, `validate-feature-review-coverage-freshness.Tests.ps1`, and `*.TargetWorktree.Tests.ps1` for the researcher, `prd-feature`, required-artifact, planner, executor, and coverage hooks.

Pester (pre-existing, unchanged, rerun by the reviewer): the 21 other suites of the six edited hook families, `hook-dependency-failure.Claude.Tests.ps1`, `hook-dependency-guard-completeness.Tests.ps1`, and `enforcement-hooks-no-python-invocation.Tests.ps1`.

Pytest (contract): `test_push_down_claude_resource_contracts.py`, `test_push_down_claude_pack_manifest_completeness.py`, `test_push_down_pack_manifest_dependency_closure.py`, `test_push_down_issue_824_follow_ups.py`, `test_execution_environment_brief_contracts.py`, `test_push_down_codex_and_agents_resource_contracts.py`.

---

## Appendix B: Toolchain Commands Reference

Run by the reviewer against the item worktree:

```sh
git -C <worktree> fetch origin main
git -C <worktree> merge-base origin/main HEAD
python scripts/dev_tools/validate_evidence_locations.py --root <worktree>
Invoke-ScriptAnalyzer -Path <file> -Settings scripts/powershell/PoshQC/settings/pssa.settings.psd1
Invoke-Formatter -ScriptDefinition <text> -Settings scripts/powershell/PoshQC/settings/pssa.settings.psd1
Invoke-Pester -Configuration <32 suite paths, PassThru>
poetry run pytest <six contract modules>
cmp <source hook> <bundle copy>
sha256sum <six brief copies>
```

Reviewer probes, from scripts in the session scratchpad: the eleven helper and coverage-hook shapes listed in section 5; parsing of `artifacts/pester/powershell-coverage.xml`; the freshness comparison of the report write time with `git log -1 --format=%ct HEAD -- *.ps1 *.psm1 *.psd1`.

Template note: the structure follows the repository template under `docs/features/templates/policy_audit/` as used by `docs/features/active/reduce-feature-cycle-time-with-revertible-ledger-1097/policy-audit.2026-11-07T10-50.md`.

---

**Audit Completed By:** feature-review agent
**Audit Date:** 2026-11-07
**Policy Version:** Current (as of audit date)
