# Policy Compliance Audit: Preimplementation Gate Blocks Post-Fan-In Integration Writes (Issue #1136)

**Audit Date:** 2026-11-08
**Branch:** `bug/preimpl-gate-post-fanin-writes` @ `caa0879c1fa046b154e6c75af6bd2b46ff7160ff`
**Base:** `main`; merge base `a90d522c6ac239bca858d7bc800d52860e823219`, which equals `origin/main` after `git fetch origin`. HEAD `caa0879c1` is a merge of `origin/main` into the branch, so the branch is up to date with `main`. `artifacts/pr_context.summary.txt` was generated at 2026-11-08 17:51 UTC for head `caa0879c1` with range `a90d522c6..caa0879c1`.
**Work Mode:** full-bug (AC source: `spec.md` `## Acceptance Criteria`)
**Review type:** First review of the branch.
**Code Under Test:** merge base `a90d522c6ac239bca858d7bc800d52860e823219` of `main` and reviewed head `caa0879c1fa046b154e6c75af6bd2b46ff7160ff`; the diff between them lists 43 changed files (2887 insertions, 10 deletions). This audit covers all of them.

**Coverage Metrics by Language:**

| Language | Files Changed | Tests | Test Result | Baseline Coverage | Post-Change Coverage | New Code Coverage |
|----------|--------------|-------|-------------|-------------------|---------------------|-------------------|
| PowerShell | 4 production (2 new `hook-epic-fan-in.ps1`, 2 modified epic-scope gates) plus 4 bundle copies; 3 new and 1 modified test files | 20029 | 0 failures, 0 errors, 10 skipped | 95.60% lines repo-wide (35614 of 37254) | 95.62% lines repo-wide (35809 of 37448) | 100.00% (91 of 91) each `hook-epic-fan-in.ps1` copy |
| Python | 1 test-support file, 0 production | 16538 passed | 0 failed, 6 skipped | 97.11% lines (34287 of 35308) | 97.11% lines, 94.37% branches (12645 of 13400) | N/A - no production Python file changed |
| TypeScript | 0 files | N/A | N/A | N/A - zero changed TypeScript files | N/A - zero changed TypeScript files | N/A |
| C# | 0 files | N/A | N/A | N/A - zero changed C# files | N/A - zero changed C# files | N/A |
| Bash | 0 files | N/A | N/A | N/A - zero changed Bash files | N/A - zero changed Bash files | N/A |

PowerShell verdict: PASS. Python verdict: PASS. TypeScript, C#, and Bash have zero changed files on the branch. Thresholds: the root `CLAUDE.md` states no coverage figure, so the defaults of 85% line and 75% branch govern. Pester measures no branch figure, so no branch threshold applies to PowerShell.

### Coverage Evidence Checklist

- PowerShell baseline coverage artifact: `evidence/baseline/pester-baseline.2026-11-08T17-02.md` (one `Invoke-PoshQCParallelTest` run, 19856 tests, 0 failures, 95.6% repo-wide lines; Claude epic-scope gate 97.48%, Codex epic-scope gate 97.83%).
- PowerShell post-change coverage artifact: `artifacts/pester/powershell-coverage.xml` in the item worktree, written 2026-11-08 12:42 local time (17:42Z) by the final gate run recorded in `evidence/qa-gates/pester-final.2026-11-08T17-42.md`. The reviewer parsed the root LINE counter (35809 covered, 1639 missed, 95.62%) and the per-file LINE counters listed in section 1.2.1.
- Python baseline coverage artifact: `evidence/baseline/pytest-baseline.2026-11-08T17-06.md` (16538 passed, 97.11% lines, 94.37% branches).
- Python post-change coverage artifact: `artifacts/python/lcov.info`, written 2026-11-08 12:46 local time (17:46Z) by the final pytest run. The reviewer summed its records: 34287 of 35308 lines (97.11%) and 12645 of 13400 branches (94.37%).
- TypeScript baseline coverage artifact: N/A - no pre-change run; zero changed TypeScript files, so no Jest run is owed.
- TypeScript post-change coverage artifact: N/A - zero changed TypeScript files.
- Per-language comparison summary: section 1.2.1 of this audit.
- Artifact provenance note: both coverage artifacts were written at head `c36255592`, before the merge commit `caa0879c1`. `git diff --name-only c36255592 caa0879c1` lists no file in the dependency chain of the changed hooks (the PowerShell files it changes are the epic merge gates, epic-wave, runbook, and their tests). The 13 branch files that the merge also touched are skill text, the two `core.json` manifests, and the frozen-surface pin; the reviewer re-ran the six Python contract modules that cover them at `caa0879c1` (83 passed) and re-hashed every mirror set (section Executive Summary). The per-file figures of the changed PowerShell production files therefore describe HEAD.

---

## Executive Summary

The branch adds a pure, byte-identical hook file `hook-epic-fan-in.ps1` to `.claude/hooks/`, `.codex/hooks/`, and both bundle mirrors, and dot-sources it (guarded) from both surfaces' `enforce-orchestration-preimplementation-gate-epic-scope.ps1`. In `Get-OrchestrationEpicScopeDecision`, a target whose readiness failure is exactly `'merge-in-progress'` is allowed when `Test-EpicFanInComplete` holds and `Get-EpicFanInAllowance` admits the call. The allowlist is a Write or Edit of `artifacts/pr_body_<N>.md` or `artifacts/pr_body_<N>.receipt.json`, and `git add` or `git commit` of the checkpoint's status document, with a pathless commit admitted only when the staged index is exactly the status document. Skill, brief, bundle, manifest, and pin changes follow.

Reviewer checks at this head:

| Check (reviewer, this head) | Result |
|---|---|
| SHA-256 of the four `hook-epic-fan-in.ps1` copies | One digest, `b15ea69a...4784fd9` |
| SHA-256 of each epic-scope gate against its bundle copy | Claude pair `fe69f7c4...`, Codex pair `6afe618a...`; each pair equal |
| SHA-256 of the six execution-environment brief copies | One digest, `2a0e04ce...174ba62` |
| SHA-256 of `.claude/skills/epic-orchestrate/SKILL.md` | `73d5c859...0033ed7e`, equal to the pinned digest; agent digest `f76721ce...` equal to its pin |
| Post-merge Python contract run (`pytest -n auto --no-cov` over surface contracts, both resource contracts, both pack-manifest completeness modules, dependency closure) | 83 passed, 0 failed |
| Real-process probe of `Get-EpicFanInAllowance` (pwsh 7, helpers and `HookTargetWorktree.psm1` loaded) over 24 command and path shapes | All refusals and admissions match the spec; see code review section Adversarial Probe |
| Line counts of the frozen files (`enforce-orchestration-preimplementation-gate.ps1` both surfaces, cleanup file) | Not in the branch diff; unchanged |
| Python references in the new hook file and both edited gates | None |

**Policy documents evaluated:**
- ✅ `.claude/rules/general-code-change.md`
- ✅ `.claude/rules/general-unit-test.md`
- ✅ `.claude/rules/quality-tiers.md` (`quality-tiers.yml` exists; `.claude/hooks` and `.codex/hooks` are T3; no tier-dependent gate applies beyond the uniform gates)
- ✅ `.claude/rules/tonality.md`
- ✅ Enforcement hooks must not invoke Python (owner rule)

**Language-specific policies evaluated:**
- ✅ `.claude/rules/powershell.md`
- ✅ `.claude/rules/python.md` (one test-support file)
- N/A TypeScript, C#, Bash (zero changed files)

**Temporary artifacts cleanup:**
- ✅ `git status --short` of the item worktree was clean before the review. The reviewer's probe script lives in the session scratchpad; the pytest run used `-p no:cacheprovider` and `--no-cov`. After the review, `git status` lists only the three new review artifacts.

---

## Rejected Scope Narrowing

The audit covers the full diff `a90d522c6..caa0879c1`. Caller statements considered:

- "Findings 3 and 9 are out of scope (only an extension seam is expected)." This restates the spec's `## Scope & Non-Goals`; it limits the acceptance criteria, not the audited file range. Not applied as a narrowing of the diff.
- "Coverage reports come from the final gate runs; reviewers do not re-run format, lint or type checks (read the static artifacts)." This matches the evidence model of this review (inspect existing artifacts, do not regenerate coverage). Format, lint, and type-check results were read from `powershell-static.2026-11-08T17-31.md` and `python-static.2026-11-08T17-31.md`, and coverage was verified for both changed languages. No check was skipped.

No statement was applied as a narrowing.

---

## Modified-Workflow Rule

`modified-workflow-needs-green-run` does not fire. The branch diff contains no path under `.github/workflows/`, `scripts/benchmarks/`, or `.github/actions/`.

## Documentation Surface Check

`docs/documentation-estate/docs-profile.json` is absent on the branch head, so the check does not apply and produces no finding.

## Evidence Location Compliance

The branch diff contains no path under `artifacts/`, so none under `artifacts/baselines/`, `artifacts/qa/`, `artifacts/evidence/`, or `artifacts/coverage/`. `validate_evidence_locations.py --root <worktree>` exited 0. Evidence lies under `<FEATURE>/evidence/baseline/`, `other/`, `qa-gates/`, and `regression-testing/`.

---

## 1. General Unit Test Policy Compliance

### 1.1 Core Principles

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Independence** - Tests run in any order | ✅ PASS | Seam mocks are registered per `It` through `Set-EpicScopeSeam` and `Set-StagedIndexSeam`; no shared mutable state; the 8-shard parallel gate passed with 0 failures. |
| **Isolation** - Each test targets single behavior | ✅ PASS | The unit suite has one `Context` per function; each gate row drives one decision. |
| **Fast Execution** - Tests complete quickly | ✅ PASS | No process, network, or wait in the new rows. |
| **Determinism** - Consistent results | ✅ PASS | Synthetic `/synthetic-worktrees/` roots; staged index mocked or injected. |
| **Readability & Maintainability** - Clear structure | ✅ PASS | Data-driven `-ForEach` rows with descriptive `Case` names; Arrange-Act-Assert comments. |

### 1.2 Coverage and Scenarios

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Baseline Coverage Documented** | ✅ PASS | `pester-baseline.2026-11-08T17-02.md`, `pytest-baseline.2026-11-08T17-06.md`. |
| **No Coverage Regression** | ✅ PASS | PowerShell 95.60% to 95.62% repo-wide; Claude epic-scope gate 97.48% to 97.60%; Codex epic-scope gate 97.83% to 97.92%. The three missed lines of each gate are pre-existing and outside the changed hunks. |
| **New Code Coverage** | ✅ PASS | Both measured `hook-epic-fan-in.ps1` copies 91 of 91 lines. |
| **Modified Files** | ✅ PASS | Both epic-scope gates above 85% with no regression on changed lines. |
| **Comprehensive Coverage** | ✅ PASS | Every function in the new file has direct unit rows; the composed condition has gate rows on both surfaces. |
| **Positive Flows** - Valid inputs | ✅ PASS | Claude 7 allow rows plus 2 fail-before rows; Codex 9 allow rows including an `apply_patch` leg. |
| **Negative Flows** - Invalid inputs | ✅ PASS | 15 Claude deny rows with exact deny text, the `epic_manifest_path` exact-failure row, and 3 outside-scope rows; Codex deny rows. |
| **Edge Cases** - Boundary conditions | ✅ PASS | Branch case mismatch, blank branch, climbing and two-segment slugs, backslash `-F`, unterminated quote, absolute paths inside and outside the root, two-entry path legs. |
| **Error Handling** - Error paths | ✅ PASS | Throwing reader (unit and gate rows), non-zero reader exit, null scope. |
| **Concurrency** - If applicable | N/A | The functions hold no shared state. |
| **State Transitions** - If applicable | N/A | Stateless predicates. |

### 1.2.1 Per-Language Coverage Comparison

- PowerShell: Baseline: 95.60% repo-wide lines -> Post-change: 95.62% repo-wide lines. Change: +0.02 points. Per file: Claude epic-scope gate 97.48% to 97.60%, Codex epic-scope gate 97.83% to 97.92%. New/changed-code coverage: 100.00% for each measured `hook-epic-fan-in.ps1` copy; every changed gate line covered. Disposition: PASS. Evidence: `artifacts/pester/powershell-coverage.xml`, `evidence/baseline/pester-baseline.2026-11-08T17-02.md`, `evidence/qa-gates/pester-final.2026-11-08T17-42.md`.
- Python: Baseline: 97.11% lines -> Post-change: 97.11% lines; branches 94.37% before and after. Change: 0.00 points. The changed Python file is test data outside the measured denominator, and no Python production file changed. Disposition: PASS. Evidence: `artifacts/python/lcov.info`, `evidence/baseline/pytest-baseline.2026-11-08T17-06.md`, `evidence/qa-gates/pytest-final.2026-11-08T17-47.md`.
- TypeScript: zero changed files; no comparison is owed.
- C#: zero changed files; no comparison is owed.
- Bash: zero changed files; no comparison is owed.

### 1.3 Test Structure and Diagnostics

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Clear Failure Messages** | ✅ PASS | Allow rows carry the observed deny reason in `-Because`; deny rows assert `-BeExactly` the text built by the production outcome function. |
| **Arrange-Act-Assert Pattern** | ✅ PASS | Comment markers in every row. |
| **Document Intent** | ✅ PASS | Suite `.DESCRIPTION` blocks name issue #1136 and the fixture model. |

### 1.4 External Dependencies and Environment

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Avoid External Dependencies** | ✅ PASS | No git, gh, or network in tests; `Get-OrchestrationGateStagedIndex` is mocked at gate level and the reader is injected at unit level. |
| **Use Mocks/Stubs** | ✅ PASS | Named seams only, as `.claude/rules/powershell.md` requires. |
| **Environment Stability** | ✅ PASS | No temporary file; `Invoke-PoshQCLeakScan` 0 failures with the allowlist unchanged. |

### 1.5 Policy Audit Requirement

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Pre-submission Review** | ✅ PASS | This audit, with `code-review.2026-11-08T17-57.md` and `feature-audit.2026-11-08T17-57.md`; executor self-review `self-review.2026-11-08T17-49.md`. |

---

## 2. General Code Change Policy Compliance

### 2.1 Before Making Changes

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Clarify the objective** | ✅ PASS | `spec.md` root cause and design; research record `research.2026-11-08T16-10.md`. |
| **Read existing change plans** | ✅ PASS | `plan.2026-11-08T11-00.md`; preflight fixes recorded in `evidence/other/`. |
| **Document the plan** | ✅ PASS | The plan matches the diff. |

### 2.2 Design Principles

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Simplicity first** | ✅ PASS | One new pure file; each gate gains one guarded dot-source line and one composed condition. |
| **Reusability** | ✅ PASS | Reuses the existing tokenizer, splitter, unresolvable-text check, relative-path helper, and staged-index seam. |
| **Extensibility** | ✅ PASS | `Get-EpicFanInAllowance` takes a resolved scope object and an injected reader, the seam the spec names for findings 3 and 9. |
| **Separation of concerns** | ✅ PASS | The new file performs no I/O; the staged index is read only through the injected reader. |

### 2.3 Module & File Structure

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Cohesive modules** | ✅ PASS | The new file holds only the post-fan-in allowance. |
| **At or below the 800-line hard limit** | ✅ PASS | Logical counts: Claude epic-scope gate 396, Codex epic-scope gate 456, `hook-epic-fan-in.ps1` 345, largest test file 506 (`legacy-codex-hook-contracts.Tests.ps1`), Python pin file 446. No covered file reaches 700. `config/file-size-baseline.json` is not in the diff. |
| **Public vs internal** | ✅ PASS | Five named functions; three private helpers (`Get-EpicFanInPropertyText`, `Get-EpicFanInShapeDetail`, `Test-EpicFanInStagedIndex`). |
| **No circular dependencies** | ✅ PASS | The new file dot-sources nothing. |

### 2.4 Naming, Docs, and Comments

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Descriptive names** | ✅ PASS | `EpicFanIn` prefix on every function and constant. |
| **Docs/docstrings** | ✅ PASS | Comment-based help on every function and a file header describing each function and its call-time dependencies. |
| **Comment why, not what** | ✅ PASS | Constants carry the reason for each value; the header states why the file sets no StrictMode. |

### 2.5 After Making Changes - Toolchain Execution

| Requirement | Status | Evidence |
|------------|--------|----------|
| **1. Formatting** | ✅ PASS | `powershell-static.2026-11-08T17-31.md`: 0 of 12 PowerShell files differ from `Invoke-Formatter`; `python-static.2026-11-08T17-31.md`: Black leaves the Python file unchanged. Read from the static artifacts, not re-run. |
| **2. Linting** | ✅ PASS | PSScriptAnalyzer 0 findings on 12 files; Ruff all checks passed. |
| **3. Type checking** | ✅ PASS | Pyright 0 errors; PowerShell has no type-check stage. |
| **4. Testing** | ✅ PASS | Pester 20029 tests, 0 failures; pytest 16538 passed, 0 failed. |
| **Full toolchain loop** | ✅ PASS | The static loop made no change, so no restart was needed. |
| **Explicit reporting** | ✅ PASS | Every evidence artifact carries Timestamp, Command, EXIT_CODE, and Output Summary. |

### 2.6 Summarize and Document

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Summarize changes** | ✅ PASS | Section 9. |
| **Design choices explained** | ✅ PASS | Spec `## Proposed Fix`; skill paragraphs on both surfaces. |
| **Update supporting documents** | ✅ PASS | Epic-orchestrate skill (Claude, `.agents`, bundles), six brief copies, both `core.json` manifests, frozen-surface pin. |
| **Provide next steps** | ✅ PASS | Section 10. |

---

## 3. Language-Specific Code Change Policy Compliance

### Section 3A: Python Code Change Policy Compliance

One test-support file changed (`parallel_orchestrator_surface_expectations.py`: skill digest and re-baseline comment). Black, Ruff, and Pyright clean per `python-static.2026-11-08T17-31.md`. The merged digest equals the reviewer's SHA-256 of `.claude/skills/epic-orchestrate/SKILL.md` at HEAD (`73d5c859...0033ed7e`), and the post-merge surface-contract run passed.

### Section 3B: PowerShell Code Change Policy Compliance

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Advanced functions** | ✅ PASS | `CmdletBinding` and `OutputType` on every function; `AllowNull` and `AllowEmpty*` attributes on optional inputs. |
| **Wrapper seam for executables** | ✅ PASS | The new file runs no executable; the gate passes a reader that calls the existing `Get-OrchestrationGateStagedIndex` seam. |
| **Avoid global state** | ✅ PASS | Five script-scoped constants, never reassigned. |
| **Error handling** | ✅ PASS | `Get-EpicFanInAllowance` catches every error and answers not allowed (fail closed); the dot-source is guarded with `Add-HookDependencyFailure`. |
| **PowerShell 7+** | ✅ PASS | Hooks target PowerShell 7. |
| **No Python in hooks** | ✅ PASS | No invocation in the new file or either gate. |

### Section 3C: TypeScript Code Change Policy Compliance

No TypeScript file changed. Not applicable.

---

## 4. Language-Specific Unit Test Policy Compliance

### Section 4A: Python Unit Test Policy Compliance

No Python test logic changed; the pin file is test data. The frozen-surface, manifest-completeness, dependency-closure, and resource-contract tests passed in the gate and in the reviewer's post-merge run.

### Section 4B: PowerShell Unit Test Policy Compliance

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Use Pester v6.x** | ✅ PASS | Run through PoshQC. |
| **Use PoshQC Configuration** | ✅ PASS | `Invoke-PoshQCParallelTest` for baseline, fail-before, and final. |
| **Focused Unit Tests** | ✅ PASS | One behavior per row. |
| **Mock the wrapper, not the executable** | ✅ PASS | Named seams only. |
| **Organization / File Naming** | ✅ PASS | `tests/scripts/claude-hooks/` and `tests/scripts/codex-hooks/` mirror the hook directories. |

### Section 4C: TypeScript Unit Test Policy Compliance

No TypeScript test changed. Not applicable.

---

## 5. Test Coverage Detail

| Subject | Tests | Scenario Types | Status |
|---------|-------|----------------|--------|
| Regression (fail before, pass after) | Claude `fail-before` context, 2 rows | Receipt Write and pathless commit denied with `'merge-in-progress'` before the fix | ✅ |
| Allow rows | Claude `allows` (7), Codex `allows` (9) | Receipt relative and absolute, body, add, `-C` commit, `-F` with and without pathspec, `apply_patch` | ✅ |
| Deny rows | Claude `denies with unchanged text` (16), Codex `denies` | Fan-in incomplete, empty features, out-of-allowlist paths, staged-index variants, `--amend`, `-a`, slug and status-doc variants | ✅ |
| Outside epic scope | Claude (3), Codex HEAD-mismatch row | Generic single-feature deny unchanged | ✅ |
| Unit rows | `hook-epic-fan-in.Tests.ps1` (125 tests) | Each function, pins, agreement matrix with `Get-EpicPrCreationReadinessFailure`, byte identity | ✅ |

**Discrimination.** The two fail-before rows failed before the production change with an observed deny naming `'merge-in-progress'` (`fail-before.2026-11-08T17-19.md`). Each deny row asserts the exact deny text, so a fall-through to allow or a changed message fails it.

---

## 6. Test Execution Metrics

| Metric | Value | Status |
|--------|-------|--------|
| Pester | 20029 tests, 0 failures (baseline 19856, 0 failures) | ✅ |
| pytest | 16538 passed, 0 failed, 6 skipped (baseline the same) | ✅ |
| Regression rows before the fix | 2 failed with observed deny | ✅ |
| Reviewer post-merge Python contract run | 83 passed | ✅ |

---

## 7. Code Quality Checks

| Check | Command | Result | Status |
|-------|---------|--------|--------|
| PoshQC format (check mode) | `Invoke-Formatter` compared with file text over 12 files | 0 differ (static artifact, not re-run) | ✅ |
| PSScriptAnalyzer | `Invoke-ScriptAnalyzer` with the repo settings | 0 findings (static artifact, not re-run) | ✅ |
| Leak scan | `Invoke-PoshQCLeakScan` | 0 failures, allowlist unchanged (static artifact) | ✅ |
| Evidence locations | `validate_evidence_locations.py --root <worktree>` | Exit 0 (reviewer) | ✅ |

## CI Cross-check

| Check | Claimed outcome | Claimed figure | Head | Source |
|---|---|---|---|---|
| `poshqc / PowerShell QC static` | pass | 0 formatter differences, 0 analyzer findings over 12 PowerShell files | `c36255592` | `evidence/qa-gates/powershell-static.2026-11-08T17-31.md` |
| `poshqc / PowerShell QC shards` | pass | 20029 tests, 0 failures; 95.62% repo-wide lines | `c36255592` | `evidence/qa-gates/pester-final.2026-11-08T17-42.md` |
| `quality-checks7 / Code Quality & Tests (3.13)` | pass | 16538 passed, 0 failed; 97.11% lines, 94.37% branches | `c36255592` | `evidence/qa-gates/pytest-final.2026-11-08T17-47.md` |
| `Enforce Python coverage thresholds` | pass | 97.11% lines and 94.37% branches, above 85% and 75% | `c36255592` | `artifacts/python/lcov.info` (reviewer sum) |
| Python contract subset (reviewer) | pass | 83 passed | `caa0879c1` | Reviewer run in this audit |

The gate rows were recorded at `c36255592`; the merge `caa0879c1` changed no file in the changed hooks' dependency chain, and the reviewer re-ran the Python contract modules that cover the merged skill, manifest, and pin files at `caa0879c1`. No pull request exists for this branch yet, so no CI run exists on this head. These rows are pending-CI and are not findings.

---

## 8. Gaps and Exceptions

### Identified Gaps

1. **CR1 (Minor, non-blocking):** two commands in `hook-epic-fan-in.ps1` never execute (line 70, the null-object return of `Get-EpicFanInPropertyText`; line 266, the null-result return of `Test-EpicFanInStagedIndex`). Line coverage is 100%; no row drives a reader that returns `$null`.
2. **CR2 (Nit):** `issue.md` `Status:` names `docs/features/active/preimpl-gate-blocks-post-fanin-integration-writes/`; the folder is `2026-11-08-preimpl-gate-blocks-post-fanin-integration-writes-1136`.
3. **CR3 to CR5 (Info):** recorded in the code review.
4. **CI on this head:** no PR yet; pending-CI, not a finding.

### Approved Exceptions

**None.**

### Removed/Skipped Tests

**None removed.** The 10 disabled tests are pre-existing skips outside this change.

---

## 9. Summary of Changes

The branch adds `hook-epic-fan-in.ps1` to both hook directories and both bundles, wires it into `Get-OrchestrationEpicScopeDecision` on both surfaces behind the exact `'merge-in-progress'` failure and the fan-in predicate, documents the allowance in the epic-orchestrate skill (Claude and Codex variants and bundles) and the six execution-environment brief copies, lists the new file in both `core.json` manifests and the Codex shared-module list, re-baselines the frozen-surface pin, and adds three Pester suites. The branch log and the diff from merge base `a90d522c6` to reviewed head `caa0879c1`, named under **Code Under Test**, carry the commits and files.

---

## 10. Compliance Verdict

### Overall Status: ✅ PASS

No blocking finding. CR1 to CR5 are non-blocking.

### Policy-by-Policy Summary

#### General Code Change Policy (Section 2)
- ✅ Design, structure, toolchain loop, supporting documents

#### Language-Specific Code Change Policy (Section 3)
- ✅ PowerShell and Python

#### General Unit Test Policy (Section 1)
- ✅ Core principles, scenario coverage, coverage artifacts, Phase 0 baseline comparison

#### Language-Specific Unit Test Policy (Section 4)
- ✅ PowerShell and Python

### Metrics Summary

- ✅ 0 failures across Pester and pytest
- ✅ PowerShell 95.62% repo-wide lines; new hook file 100.00%
- ✅ Python 97.11% lines, 94.37% branches

### Recommendation

Proceed to PR authoring. Merge once CI on the PR head is green (S9).

---

## Appendix A: Test Inventory

Pester (new): `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.EpicFanIn.Tests.ps1`, `tests/scripts/claude-hooks/hook-epic-fan-in.Tests.ps1`, `tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-epic-fan-in.Tests.ps1`. Pester (modified): `tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1` (one shared-module list entry). Python (modified test data): `tests/scripts/dev_tools/parallel_orchestrator_surface_expectations.py`.

---

## Appendix B: Toolchain Commands Reference

Run by the reviewer against the item worktree:

```sh
git -C <worktree> fetch origin
git -C <worktree> merge-base origin/main HEAD
git -C <worktree> diff --name-status <merge-base> HEAD
git -C <worktree> diff --name-only c36255592 caa0879c1
sha256sum <four hook copies> <gate and bundle pairs> <six brief copies> <skill copies>
python -I <scratch parser of artifacts/pester/powershell-coverage.xml root and per-file LINE counters>
python -I <sum LF, LH, BRF, BRH in artifacts/python/lcov.info>
python <count logical lines of each changed .ps1 and .py file>
poetry run python scripts/dev_tools/validate_evidence_locations.py --root <worktree>
poetry run pytest -n auto -q -p no:cacheprovider --no-cov <six Python contract modules>
pwsh -NoProfile -File <scratch probe of Get-EpicFanInAllowance over 24 shapes>
```

Template note: the bundled template asset was not resolved through MCP in this session, because the resolver tool is not available to this agent. The structure follows the most recent policy audit in this repository, and the MCP validator checked this file.

---

**Audit Completed By:** feature-review agent
**Audit Date:** 2026-11-08
**Policy Version:** Current (as of audit date)
