# Policy Compliance Audit: SubagentStop Hooks Resolve the Item Worktree (Issue #1105)

**Audit Date:** 2026-11-07
**Branch:** `bug/hooks-read-main-checkout-1105` @ `5a866484f06e940196f7fe867dce98cc86e461de`
**Base:** `main`; merge base `bad886e304990d26af56d6bcabc9d543518492e9` (equal to the merge base of `origin/main` and `HEAD` after a fetch, and resolved the same way in `artifacts/pr_context.summary.txt`, generated 2026-11-07 17:05:50 UTC for this head)
**Work Mode:** full-bug (AC source: `spec.md` `## Acceptance Criteria`)
**Review type:** Re-audit after remediation cycle 1 (prior review `policy-audit.2026-11-07T15-37.md` at `98028900a`). No pull request is open for this branch.
**Code Under Test:**
- New: `.claude/hooks/subagentstop-target-worktree.ps1` and `.claude/hooks/validate-feature-review-coverage-freshness.ps1`
- Edited: `validate-task-researcher-output.ps1`, `validate-prd-feature-output.ps1`, `validate-required-artifact-output.ps1`, `validate-planner-output.ps1` (473 logical lines, the largest), `validate-executor-output.ps1` (417), `validate-feature-review-coverage.ps1`, `validate-feature-review-coverage-metrics.ps1`, `validate-feature-review-coverage-rules.ps1`, all under `.claude/hooks/`
- Ten byte-identical bundle copies under `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/`, two new `core.json` pack entries, and six byte-identical copies of `execution-environment/SKILL.md`
- Eight new Pester suites and 23 edited Pester suites (baseline-mock registration lines, the ThresholdsGuard module cleanup, and cycle 1 cases)
- Feature folder documents, evidence, and the promoted lifecycle record

The branch diff is 97 files over 43 commits. This audit covers all of them. Cycle 1 (`58fac0b55` to `5a866484f`) changed the helper, the six hooks, their bundle copies, and the test suites.

**Coverage Metrics by Language:**

| Language | Files Changed | Tests | Test Result | Baseline Coverage | Post-Change Coverage | New Code Coverage |
|----------|--------------|-------|-------------|-------------------|---------------------|-------------------|
| PowerShell | 10 production, 31 test (plus 10 bundle copies) | 15759 | 0 failed, 0 errors, 10 disabled | 94.01% lines repo-wide | 94.06% lines repo-wide (24265 of 25797) | 100.00% (92 of 92) and 97.96% (48 of 49) on the two new files; 98.33% to 100.00% on the eight edited hooks |
| Python | 0 files | 16179 passed, 6 skipped | 0 failed | N/A - zero changed Python files | N/A - zero changed Python files | N/A |
| TypeScript | 0 files | N/A | N/A | N/A - zero changed TypeScript files | N/A - zero changed TypeScript files | N/A |
| C# | 0 files | N/A | N/A | N/A - zero changed C# files | N/A - zero changed C# files | N/A |
| Bash | 0 files | N/A | N/A | N/A - zero changed Bash files | N/A - zero changed Bash files | N/A |

PowerShell verdict: PASS. Thresholds: the root `CLAUDE.md` states no coverage figure, so the defaults of 85% line and 75% branch govern. Pester measures no branch figure (the report carries no `BRANCH` counter), so no branch threshold applies to PowerShell. `pack-manifests/core.json` is the only JSON file changed; it has no coverage measure.

### Coverage Evidence Checklist

- TypeScript baseline coverage artifact: N/A - zero changed TypeScript files
- TypeScript post-change coverage artifact: N/A - zero changed TypeScript files
- PowerShell baseline coverage artifact: `evidence/baseline/pester-parallel.2026-11-07T14-41.md` (repo-wide 94.01%)
- PowerShell post-change coverage artifact: `artifacts/pester/powershell-coverage.xml` in the item worktree, parsed by the reviewer (root LINE 24265 covered, 1532 not covered, 94.06%), equal to `evidence/qa-gates/pester-parallel.2026-11-07T17-01.md`
- Python baseline coverage artifact: N/A - zero changed Python files
- Python post-change coverage artifact: N/A - zero changed Python files
- Per-language comparison summary: section 1.2.1 of this audit and `evidence/qa-gates/baseline-comparison.2026-11-07T17-01.md`
- Artifact provenance note: the report was written at 17:00:54 UTC. The newest commit touching `.claude/`, `tests/`, or `extensions/` is `03fc766e0` at 16:50:31 UTC, and every later commit changes Markdown under `docs/` only, so the report describes this head.
- Main checkout note: the main checkout was not read. Its coverage files belong to another branch and were not judged.

---

## Executive Summary

The branch makes the SubagentStop artifact hooks (researcher, `prd-feature`, required-artifact, planner, executor) and the feature-review coverage hook resolve advertised artifact paths against the item worktree that produced them. Cycle 1 addressed the three findings of the prior review:

- **F1 (resolved).** `Resolve-SubagentStopTargetWorktree` now reduces the prompt with `Get-SubagentStopIdentityPrompt` to the first branch signal (`Find-WorktreeResolutionBranchSignal`) and the canonical issue lines (`Find-WorktreeItemIssueSignal`), the same readers the model-routing gate uses in `WorktreeItemResolution.psm1`. An identity with no branch is passed with a `CheckpointIssueReader` that defaults to `Get-WorktreeItemCheckpointIssue`. The coverage hook's unresolved-target message no longer advises absolute paths.
- **F2 (resolved).** `Get-ExecutorOutputBlockDecision` reads the transcript head once and hands a closure over those lines to both the resolver and `Test-IsPreflightRun`.
- **F3 (resolved).** `Resolve-SubagentStopArtifactLocation` rejects a relative value with a `..` segment beneath an item root, and every caller blocks with the rejection detail before any probe.

Verification by the reviewer:

- **Gates.** PSScriptAnalyzer and `Invoke-Formatter` over the 42 changed non-bundle PowerShell files: 0 findings, 0 differences. Pester over the 12 target-worktree, helper, freshness, and ThresholdsGuard suites in one process: 232 passed, 0 failed. The six Python contract modules: 126 passed.
- **Mirrors.** The ten bundle hook copies are byte-identical to their sources (`cmp`), and the six brief copies share one MD5.
- **Coverage.** Parsed from the item worktree's report; all figures match the executor's gate evidence.
- **Probes.** A real-process run of the helper over nine identity shapes and nine path shapes, and of the executor hook with a counting transcript reader, confirmed F1, F2, and F3 resolved (section 5).
- **Out-of-plan finding 1 (confirmed, blocking as F4).** In `validate-feature-review-coverage.TargetWorktree.Tests.ps1` line 218, the `-Times 0` assertion reads the unbound `$Root` parameter in its `ParameterFilter`. A reviewer mutant that adds an unrooted summary read fails that assertion under plain `Invoke-Pester`, and passes it when an outer `$Root` is in scope, as in the PoshQC shard host (`Invoke-PoshQCTest -Root`). The assertion cannot fail in the gate host.
- **Out-of-plan finding 2 (confirmed, non-blocking as F5).** `Register-EpicStateBaselineMock` fails with Pester's "Multiple script or manifest modules named 'WorktreeItemResolution'" error when a bundle copy of the module is loaded beside the repository copy (reproduced). The helper is not in the branch diff. The only suite that loads a bundle hook copy in-process is ThresholdsGuard, and its new `AfterAll` removes the bundle modules.

One blocking finding, F4, class `autonomous`. The verdict is `REMEDIATION_REQUIRED`.

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
- ✅ Reviewer probe scripts and the mutated hook and test copies live in the session scratchpad outside the repository. No test or production file in the worktree was modified.

---

## Rejected Scope Narrowing

None. The caller prompt directs a full-branch review against the merge base of `origin/main` and `HEAD`, and every changed file was audited. The instructions to confirm F1 to F3 and to evaluate two executor-reported findings add checks; they remove no language and no check.

---

## Modified-Workflow Rule

`modified-workflow-needs-green-run` does not fire. The branch diff contains no path under `.github/workflows/`, `scripts/benchmarks/`, or `.github/actions/`.

## Evidence Location Compliance

`validate_evidence_locations.py --root <item worktree>` exited 0. A scan of the branch diff found no path under `artifacts/baselines/`, `artifacts/qa/`, `artifacts/evidence/`, or `artifacts/coverage/`. All evidence lies under `<FEATURE>/evidence/baseline/`, `evidence/qa-gates/`, `evidence/regression-testing/`, `evidence/remediation-baseline/`, and `evidence/other/`.

---

## 1. General Unit Test Policy Compliance

### 1.1 Core Principles

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Independence** - Tests run in any order | ✅ PASS | The branch's new leak source (the ThresholdsGuard suite dot-sources the bundle coverage hook, which now imports the bundle `worktree-resolution` modules) is cleaned up by the suite's `AfterAll`. The parallel gate ran 8 shards with 0 failures, and the reviewer's single-process run of 12 suites passed. F5 records the remaining helper fragility. |
| **Isolation** - Each test targets single behavior | ✅ PASS | One resolution source, probe case, or freshness rule per `It`. |
| **Fast Execution** - Tests complete quickly | ✅ PASS | The new and cycle 1 cases use in-memory seams; no test starts a process. |
| **Determinism** - Consistent results | ❌ FAIL | F4: one assertion's outcome depends on the host. Line 218 of the coverage target suite passes a regression mutant under the PoshQC shard host and fails it under plain `Invoke-Pester`. `.claude/rules/powershell.md` requires identical results across hosts. |
| **Readability & Maintainability** - Clear structure | ✅ PASS | `It` names state the expected outcome; each suite has a synopsis naming the hook and the issue. |

### 1.2 Coverage and Scenarios

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Baseline Coverage Documented** | ✅ PASS | `evidence/baseline/pester-parallel.2026-11-07T14-41.md` with per-file figures for the eight edited hooks. |
| **No Coverage Regression** | ✅ PASS | Repo-wide 94.01% to 94.06%; no edited hook dropped; 0 changed executable lines uncovered in the edited hooks (`baseline-comparison.2026-11-07T17-01.md`). |
| **New Code Coverage** | ✅ PASS | `subagentstop-target-worktree.ps1` 100.00% (92 of 92); `validate-feature-review-coverage-freshness.ps1` 97.96% (48 of 49). |
| **Modified Files** | ✅ PASS | Eight edited hooks from 98.33% to 100.00%, read by the reviewer from the same report. |
| **Comprehensive Coverage** | ✅ PASS | The one line not run in the freshness file is the default `GitInvoker` value, which runs real `git` and is replaced in every test. |
| **Positive Flows** - Valid inputs | ✅ PASS | Item-only and absolute-inside-item cases in all six hook suites; issue-only and second-`branch:` cases added in cycle 1. |
| **Negative Flows** - Invalid inputs | ✅ PASS | Main-only, absolute-outside-every-worktree, `..` rejection, absent summary, and absent and stale report cases. |
| **Edge Cases** - Boundary conditions | ✅ PASS | Both-checkouts case; root equal to session root by case and trailing slash; report time equal to commit time; a reader that finds no worktree. |
| **Error Handling** - Error paths | ✅ PASS | Transcript reader throws; resolver throws; git non-zero, empty, non-integer, and throwing. |
| **Concurrency** - If applicable | N/A | Hooks are single-invocation processes with no shared mutable state. |
| **State Transitions** - If applicable | N/A | No stateful component is added. |

### 1.2.1 Per-Language Coverage Comparison

- PowerShell: Baseline: 94.01% repo-wide lines -> Post-change: 94.06% repo-wide lines. Change: +0.05% lines. New/changed-code coverage: 100.00% on `subagentstop-target-worktree.ps1` (92 of 92) and 97.96% on `validate-feature-review-coverage-freshness.ps1` (48 of 49); edited hooks 98.33% (researcher), 100.00% (`prd-feature`), 98.73% (required-artifact), 99.55% (planner), 100.00% (executor), 100.00% (coverage), 100.00% (metrics), 98.99% (rules); 0 changed executable lines uncovered in the edited hooks. Disposition: PASS. Evidence: `artifacts/pester/powershell-coverage.xml`, `evidence/baseline/pester-parallel.2026-11-07T14-41.md`, `evidence/qa-gates/pester-parallel.2026-11-07T17-01.md`, `evidence/qa-gates/baseline-comparison.2026-11-07T17-01.md`. Branch figure: Pester measures none, and no branch threshold applies.
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
| **Avoid External Dependencies** | ✅ PASS | The default `CheckpointIssueReader` is exercised through a mock of `Get-WorktreeItemCheckpointIssue`; the artifact-hook suites register the item-resolution baseline mocks, so no checkpoint file is read. |
| **Use Mocks/Stubs** | ✅ PASS | The hooks' own file seams and injected script blocks. |
| **Environment Stability** | ❌ FAIL | F4: the line 218 filter reads a variable name (`$Root`) that the PoshQC shard host defines in an outer scope, so the assertion depends on the runner's variables. Fixture roots remain `/synthetic-worktrees/...` forward-slash paths. |

### 1.5 Policy Audit Requirement

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Pre-submission Review** | ✅ PASS | This audit, with `code-review.2026-11-07T17-13.md` and `feature-audit.2026-11-07T17-13.md`; executor self-review `evidence/qa-gates/self-review.2026-11-07T17-02.md`. |

---

## 2. General Code Change Policy Compliance

### 2.1 Before Making Changes

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Clarify the objective** | ✅ PASS | `spec.md`, `research/research.2026-11-07T13-55.md`, and `remediation-inputs.2026-11-07T15-37.md`. |
| **Read existing change plans** | ✅ PASS | `remediation-plan.2026-11-07T15-37.md`; `evidence/other/preflight-fixes.2026-11-07T16-00.md`; `evidence/remediation-baseline/phase0-instructions-read.2026-11-07T16-01.md`. |
| **Document the plan** | ✅ PASS | The remediation plan, with one commit per task. |

### 2.2 Design Principles

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Simplicity first** | ✅ PASS | The F1 fix adds one pure reducer, `Get-SubagentStopIdentityPrompt`, and one optional parameter. |
| **Reusability** | ✅ PASS | The fix reuses the gate's own signal readers and checkpoint reader; `Resolve-HookTargetWorktree`, `Resolve-WorktreeItemTarget`, and `subagentstop-envelope.ps1` are unchanged. |
| **Extensibility** | ✅ PASS | `CheckpointIssueReader` is an optional script-block seam with a production default. |
| **Separation of concerns** | ✅ PASS | Path rejection lives in `Resolve-SubagentStopArtifactLocation`; callers only format the block. |

### 2.3 Module & File Structure

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Cohesive modules** | ✅ PASS | Helper: resolution and path conversion. Freshness sibling: report freshness only. |
| **At or below the 800-line hard limit** | ✅ PASS | Logical line counts by `@(Get-Content).Count` over every added or modified covered file: largest production file `validate-planner-output.ps1` at 473; largest test file `validate-feature-review-coverage.Coverage.Tests.ps1` at 481. No file reaches 700. `config/file-size-baseline.json` is not in the diff. |
| **Public vs internal** | ✅ PASS | Hooks keep their entry functions; new parameters are optional seams. |
| **No circular dependencies** | ✅ PASS | The helper imports `HookTargetWorktree.psm1`, `WorktreeTargetResolution.psm1`, and `WorktreeItemResolution.psm1`; none of them loads a hook. |

### 2.4 Naming, Docs, and Comments

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Descriptive names** | ✅ PASS | `Get-SubagentStopIdentityPrompt`, `Resolve-SubagentStopArtifactLocation`. |
| **Docs/docstrings** | ✅ PASS | Comment-based help updated for the new parameter and the `Rejected` and `RejectionDetail` keys. |
| **Comment why, not what** | ✅ PASS | Comments name issue #1105 and the finding each change addresses. |

### 2.5 After Making Changes - Toolchain Execution

| Requirement | Status | Evidence |
|------------|--------|----------|
| **1. Formatting** | ✅ PASS | Reviewer `Invoke-Formatter` over 42 changed non-bundle files at this head: 0 differences. |
| **2. Linting** | ✅ PASS | Reviewer PSScriptAnalyzer with `pssa.settings.psd1` over the same 42 files: 0 findings. |
| **3. Type checking** | N/A | Does not apply to PowerShell; no Python or TypeScript changed. |
| **4. Testing** | ✅ PASS | Executor gate: 15759 Pester tests, 0 failed; 16179 pytest passed, 0 failed. Reviewer runs: 232 Pester tests in 12 files, 0 failed; 126 contract pytest tests, 0 failed. |
| **Full toolchain loop** | ✅ PASS | One clean final pass recorded under `evidence/qa-gates/` after the [P3-T4] restart. |
| **Explicit reporting** | ✅ PASS | Each evidence file carries command, exit code, and summary. |

### 2.6 Summarize and Document

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Summarize changes** | ✅ PASS | Section 9. |
| **Design choices explained** | ✅ PASS | Helper comment-based help and `remediation-plan.2026-11-07T15-37.md`. |
| **Update supporting documents** | ✅ PASS | The brief text did not change in cycle 1; the six copies remain byte-identical. |
| **Provide next steps** | ✅ PASS | Section 10 and `remediation-inputs.2026-11-07T17-13.md`. |

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
| **Advanced functions** | ✅ PASS | `CmdletBinding` and `OutputType` on `Get-SubagentStopIdentityPrompt`. |
| **Parameter validation** | ✅ PASS | `AllowNull` and `AllowEmptyString` on the prompt parameter. |
| **Avoid global state** | ✅ PASS | The executor's single read is held in a local closure; no script-scope state. |
| **Error handling** | ✅ PASS | A throwing transcript read counts as no transcript; a `..` value blocks repairably with a named detail. |

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
| **Rerun loop if needed** | ✅ PASS | The executor restarted from [P3-T1] after adding the default-reader case; the final run is recorded. |

### Enforcement-Hook Constraints

| Requirement | Status | Evidence |
|------------|--------|----------|
| **No Python in enforcement hooks** | ✅ PASS | Cycle 1 adds no process call; `enforcement-hooks-no-python-invocation.Tests.ps1` 33 of 33 in the executor gate. |
| **Guarded dependency loading** | ✅ PASS | The two new `Import-Module` lines use the single-statement `try`/`Add-HookDependencyFailure` pattern; `hook-dependency-guard-completeness.Tests.ps1` 671 of 671 and `hook-dependency-failure.Claude.Tests.ps1` 191 of 191 in the executor gate. |
| **Bundle mirrors and pack manifest** | ✅ PASS | Ten `cmp` matches; manifest contract modules passed in the reviewer run. |
| **Compatibility with the delegation-identity contract and public behavior** | ✅ PASS | F1 resolved: the helper uses the gate's readers; reviewer probes in section 5. |

---

## 4. Language-Specific Unit Test Policy Compliance

### Section 4B: PowerShell Unit Test Policy Compliance

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Use Pester v5.x** | ✅ PASS | Pester 6.2.0 with configuration objects, as `.claude/rules/powershell.md` specifies. |
| **Use PoshQC Configuration** | ✅ PASS | Gate evidence from `Invoke-PoshQCParallelTest`. |
| **Focused Unit Tests** | ✅ PASS | One behavior per `It`. |
| **Organization / File Naming** | ✅ PASS | `tests/scripts/claude-hooks/<hook>.TargetWorktree.Tests.ps1` mirrors `.claude/hooks/`. |
| **Use PoshQCTest Command** | ❌ FAIL | F4: under `Invoke-PoshQCTest`, the line 218 assertion cannot fail, so the gate host does not enforce what the case asserts. |

---

## 5. Test Coverage Detail

| Subject | Tests | Scenario Types | Status |
|---------|-------|----------------|--------|
| Helper (`subagentstop-target-worktree.Tests.ps1`) | 40 | FilePath, DelegationPrompt, SessionRoot; issue-only with and without a matching reader; second `branch:`; default reader; `..` rejection | ✅ |
| Freshness (`validate-feature-review-coverage-freshness.Tests.ps1`) | 18 | Absent summary, absent and stale report, fresh report, git failure modes, session-root skip | ✅ |
| Researcher, `prd-feature`, required-artifact, planner suites | 9, 12, 10, 10 | Item-only, main-only, both, absolute, not-derivable and ambiguous, `..` rejection; second `branch:` in the planner suite | ✅ |
| Executor suite | 19 | Same cases for `plan-path` and `preflight-fix-record` (#1034); one transcript read | ✅ |
| Coverage hook suite | 21 | Review artifacts (#1031), summary, `CLAUDE.md`, reports, unresolved target (#1097), gate-admitted shapes under `stop_hook_active` | ⚠️ F4 |

**Reviewer probes (real process, injected worktree list and transcript).**

| Shape | Result |
|---|---|
| Issue line only, reader returns 1105 for the item root | item root, source `DelegationPrompt` |
| Issue line only, reader returns nothing | `TARGET_WORKTREE_NOT_DERIVABLE` |
| `branch: <item>` then `base branch: main` | item root |
| `base branch: main` then `branch: <item>` | session root (the gate's first-signal reader gives the same branch) |
| Branch and issue line | item root |
| No identity | session root, source `SessionRoot` |
| `branch: main` | session root |
| Two different issue lines | `TARGET_WORKTREE_AMBIGUOUS` |
| Absolute path inside the session root | session root, source `FilePath` |
| `docs/features/active/../../x/spec.md`, `../../../etc/passwd`, `docs\features\..\x.md` beneath the item root | rejected, no probe |
| Absolute `<item>/docs/../../../../etc/passwd` | converted, then rejected |
| `docs/features/active/a..b/spec.md` | accepted (not a `..` segment) |
| `docs/../x.md` with the session root | unchanged, not rejected |
| Executor, relative `plan-path`, counting reader | one transcript read |

**Mutation probes (scratch copy).** Adding an unrooted summary read to the coverage hook: the line 218 case fails under plain `Invoke-Pester` and passes when the run is started from a function with a `$Root` parameter, as `Invoke-PoshQCTest -Root` does. With `$PesterBoundParameters['Root']` in place of `$Root` in lines 216 to 218, the original hook passes and the mutant fails in both hosts.

---

## 6. Test Execution Metrics

| Metric | Value | Status |
|--------|-------|--------|
| Total Pester Tests (executor gate) | 15759 | ✅ |
| Pester Failed (executor gate) | 0 failures, 0 errors, 10 disabled | ✅ |
| Pester Wall-clock (executor gate) | 515.91 s, 8 workers | ✅ |
| Reviewer Pester (12 files) | 232 passed, 0 failed | ✅ |
| Pytest (executor gate) | 16179 passed, 6 skipped, 0 failed | ✅ |
| Reviewer pytest (6 contract modules) | 126 passed | ✅ |
| PowerShell line figure | 94.06% repo-wide | ✅ |

---

## 7. Code Quality Checks

**For PowerShell:**

| Check | Command | Result | Status |
|-------|---------|--------|--------|
| Invoke-Formatter | `Invoke-Formatter -ScriptDefinition <text> -Settings <pssa settings>` per changed file | 0 differences on 42 files (reviewer) | ✅ |
| PSScriptAnalyzer | `Invoke-ScriptAnalyzer -Path <file> -Settings <pssa settings>` | 0 findings on 42 files (reviewer) | ✅ |
| Pester Tests | `Invoke-PoshQCParallelTest -Root <worktree root>` | 15759 tests, 0 failed (executor) | ✅ |

---

## 8. Gaps and Exceptions

### Identified Gaps

1. **F4 (Minor, blocking, `autonomous`): a `-Times 0` assertion cannot fail under the gate host.** In `tests/scripts/claude-hooks/validate-feature-review-coverage.TargetWorktree.Tests.ps1`, case "reads the PR context summary, the root CLAUDE.md, and the coverage report only beneath the item root", line 218 asserts zero `Get-ArtifactFileContent` calls with an empty `Root`. The filter reads `$Root`. When the hook calls without `-Root`, Pester does not bind `$Root` in the filter scope, so PowerShell looks it up in an outer scope. Under `Invoke-PoshQCTest -Root <worktree>` that scope holds the worktree path, the filter is false, and the count stays 0 whatever the hook does. Lines 216 and 217 read the same name but assert `-Times 1` and still fail when the read is missing. This assertion is the suite's only pin on the "only beneath the item root" clause of criterion 8, so criterion 8 is graded PARTIAL and unchecked. No other instance exists: the other 65 `ParameterFilter` blocks added on the branch read only parameters the hooks always bind by name.
2. **F5 (Nit, non-blocking): `Register-EpicStateBaselineMock` does not tolerate two loaded modules of the same name.** The helper calls `Mock -ModuleName`, which throws when a bundle copy and a repository copy of `WorktreeItemResolution` are both loaded (reviewer reproduction). The helper pre-dates the branch and is not in the diff. On this branch the only in-process loader of a bundle hook copy is the ThresholdsGuard suite, whose new `AfterAll` removes every module loaded from the bundle path. The error is reported loudly by Pester rather than as a silent order effect.
3. **CI on this head.** Criterion 16 is pending CI; S9 owns it and it is not counted as a blocking finding.

### Approved Exceptions

**None.** The fail-before runs were replaced by `evidence/regression-testing/fail-before-exception.2026-11-07T15-07.md`, which cites the merge-base code for each new suite under the owner's parallel-only test rule. The reviewer accepts it as alternative proof.

### Removed/Skipped Tests

**None.** The edited pre-existing suites gain baseline-mock registration lines, an interception-probe `It`, and, in ThresholdsGuard, an `AfterAll`; no `It` was removed or skipped.

---

## 9. Summary of Changes

### Commits in This PR/Branch

1. `bdafc74b8` to `98028900a`: promoted record, research, spec, plan, Phase 0 baselines, helper, freshness sibling, six hook edits, mirrors, brief copies, gates, and AC check-off (first review scope).
2. `ca30743d0` to `1e83c7f1c`: prior review artifacts, remediation plan, preflight fix, policy reads.
3. `71abd6fba`, `e6b3da2c5`, `bfff44bdb`: F1 fix, coverage hook message, baseline mocks in the hook suites.
4. `2d70b90d1`, `e8098b044`: F2 and F3 fixes.
5. `5796a5d1e` to `5a866484f`: static gates, Pester and pytest gates, default-reader case, comparison, self-review.

### Files Modified

1. Two new and eight edited hooks under `.claude/hooks/`, with ten bundle copies.
2. `pack-manifests/core.json`; six `execution-environment/SKILL.md` copies.
3. Eight new and 23 edited Pester suites; feature folder documents and evidence.

---

## 10. Compliance Verdict

### Overall Status: ❌ FAIL (remediation required)

One blocking finding, F4, class `autonomous`. F1, F2, and F3 are resolved.

### Policy-by-Policy Summary

#### General Code Change Policy (Section 2)
- ✅ Design, structure, naming, documents, toolchain loop, compatibility

#### Language-Specific Code Change Policy (Section 3)
- ✅ PowerShell tooling, design, and structure; Python-free and guarded hook loading; delegation-identity compatibility

#### General Unit Test Policy (Section 1)
- ❌ Determinism and environment stability: F4
- ✅ Independence, coverage for the one changed language

#### Language-Specific Unit Test Policy (Section 4)
- ❌ Gate-host enforcement of one assertion: F4

### Metrics Summary

- ✅ 15759 Pester tests, 0 failed; 16179 pytest passed, 0 failed
- ✅ 94.06% PowerShell repo-wide lines; new files 100.00% and 97.96%
- ✅ Evidence locations clean; no workflow path changed; mirrors byte-identical

### Recommendation

**Remediate F4 before the pull request.** In lines 216 to 218 of the coverage target suite, read the bound value as `$PesterBoundParameters['Root']` instead of `$Root`, run the gate, and re-check criterion 8. F5 needs no change on this branch.

---

## Appendix A: Test Inventory

Pester (new): `subagentstop-target-worktree.Tests.ps1`, `validate-feature-review-coverage-freshness.Tests.ps1`, and `*.TargetWorktree.Tests.ps1` for the researcher, `prd-feature`, required-artifact, planner, executor, and coverage hooks.

Pester (edited): the 21 pre-existing suites of the six edited hook families (baseline-mock lines only, no `ParameterFilter` edits), ThresholdsGuard, and three Codex parity and coverage suites.

Pytest (contract): `test_push_down_claude_resource_contracts.py`, `test_push_down_claude_pack_manifest_completeness.py`, `test_push_down_pack_manifest_dependency_closure.py`, `test_push_down_issue_824_follow_ups.py`, `test_execution_environment_brief_contracts.py`, `test_push_down_codex_and_agents_resource_contracts.py`.

---

## Appendix B: Toolchain Commands Reference

Run by the reviewer against the item worktree:

```sh
git -C <worktree> fetch origin main
git -C <worktree> merge-base origin/main HEAD
poetry -C <worktree> run python scripts/dev_tools/validate_evidence_locations.py --root <worktree>
Invoke-ScriptAnalyzer -Path <file> -Settings scripts/powershell/PoshQC/settings/pssa.settings.psd1
Invoke-Formatter -ScriptDefinition <text> -Settings scripts/powershell/PoshQC/settings/pssa.settings.psd1
Invoke-Pester -Configuration <12 suite paths, PassThru>
poetry -C <worktree> run pytest -n auto <six contract modules>
cmp <source hook> <bundle copy>
md5sum <six brief copies>
```

Reviewer probes, from scripts in the session scratchpad: the helper and executor shapes listed in section 5; the F4 mutation in a scratch copy under both hosts; the F5 duplicate-module reproduction; parsing of `artifacts/pester/powershell-coverage.xml`.

Template note: the structure follows the repository template under `docs/features/templates/policy_audit/`.

---

**Audit Completed By:** feature-review agent
**Audit Date:** 2026-11-07
**Policy Version:** Current (as of audit date)
