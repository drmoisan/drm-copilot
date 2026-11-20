# Policy Compliance Audit: Epic-Child PR Merges Without CI (Issue #1130)

**Audit Date:** 2026-11-08
**Branch:** `bug/epic-child-pr-ci-required` @ `03d222c55e3724bbd1d92db549e0017d02c306be`
**Base:** `main`; merge base `cdcff3871765396183590128e142a929cf78327b`, which equals `origin/main` after `git fetch origin main`. `git merge-tree --write-tree origin/main HEAD` exits 0. `artifacts/pr_context.summary.txt` (generated 2026-11-08 15:23:09 UTC) names head `03d222c55e3724bbd1d92db549e0017d02c306be` and resolves `origin/main @ cdcff3871765396183590128e142a929cf78327b`, so it is current for this head.
**Work Mode:** full-bug (AC source: `spec.md` `## Acceptance Criteria`)
**Review type:** First review of the branch, plan `plan.2026-11-08T08-08.md`.
**Code Under Test:** merge base `cdcff3871765396183590128e142a929cf78327b` of `main` and reviewed head `03d222c55e3724bbd1d92db549e0017d02c306be`; the diff between them lists the changed files (66 files, 2886 insertions, 31 deletions). This audit covers all of them.

**Coverage Metrics by Language:**

| Language | Files Changed | Tests | Test Result | Baseline Coverage | Post-Change Coverage | New Code Coverage |
|----------|--------------|-------|-------------|-------------------|---------------------|-------------------|
| PowerShell | 4 production (2 new helpers, 2 gates) plus 4 bundle copies, 2 new and 12 modified test files | 19762 | 0 failures, 0 errors | 95.56% lines repo-wide (35308 of 36947) | 95.58% lines repo-wide (35482 of 37124) | 100.00% (83 of 83) Claude helper; 97.59% (81 of 83) Codex helper |
| Python | 1 test-support file, 0 production | 16537 passed | 0 failed, 6 skipped | 94.82% lines (Phase 0; 17653 statements, 915 missed) | 94.82% lines, 90.17% branches | N/A - no production Python file changed |
| TypeScript | 0 files | N/A | N/A | N/A - zero changed TypeScript files | N/A - zero changed TypeScript files | N/A |
| C# | 0 files | N/A | N/A | N/A - zero changed C# files | N/A - zero changed C# files | N/A |
| Bash | 0 files | N/A | N/A | N/A - zero changed Bash files | N/A - zero changed Bash files | N/A |

PowerShell verdict: PASS. Python verdict: PASS. TypeScript, C#, and Bash have zero changed files on the branch. Thresholds: the root `CLAUDE.md` states no coverage figure, so the defaults of 85% line and 75% branch govern. Pester measures no branch figure, so no branch threshold applies to PowerShell.

Python branch figures: the Phase 0 evidence records 6418 branches with 431 partial and the pytest combined figure 94%; the gate run records 432 partial and 94%. The Phase 0 run wrote no lcov file, so no lcov-style Phase 0 branch percentage exists; the post-change lcov figure is 90.17% (5787 of 6418), above 75%. No production Python file changed, so the one-partial difference is not attributable to this branch.

### Coverage Evidence Checklist

- PowerShell baseline coverage artifact: `evidence/baseline/pester-baseline.2026-11-08T13-29.md` and `evidence/baseline/pester-per-file-coverage.2026-11-08T13-52.md` (one `Invoke-PoshQCParallelTest` run, 19584 tests, 0 failures, 95.56% repo-wide lines; Claude gate 98.60%, Codex gate 99.40%).
- PowerShell post-change coverage artifact: `artifacts/pester/powershell-coverage.xml` in the item worktree, written 2026-11-08T15:22Z by the post-merge gate run recorded in `evidence/qa-gates/post-merge-gates.2026-11-08T15-22.md`. The reviewer parsed the root LINE counter (35482 covered, 1642 missed, 95.58%) and the per-file counters listed in section 1.2.1.
- Python baseline coverage artifact: `evidence/baseline/pytest-baseline.2026-11-08T13-27.md` (16537 passed, 17653 statements, 915 missed).
- Python post-change coverage artifact: `artifacts/python/lcov.info`, written by the post-merge pytest run. The reviewer summed its records: 16738 of 17653 lines (94.82%) and 5787 of 6418 branches (90.17%).
- TypeScript baseline coverage artifact: N/A - no pre-change run; zero changed TypeScript files, so no Jest run is owed.
- TypeScript post-change coverage artifact: N/A - zero changed TypeScript files.
- Per-language comparison summary: section 1.2.1 of this audit.
- Artifact provenance note: the post-merge gate ran on the tree at head after the origin/main merge recorded in the evidence. `origin/main` equals the merge base, and no commit after the gate run changes a PowerShell or Python file.

---

## Executive Summary

The branch adds a byte-identical helper, `enforce-epic-merge-gate-child-ci.ps1`, to `.claude/hooks/` and `.codex/hooks/`, and wires it into the epic-child branch of both `enforce-epic-merge-gate.ps1` gates. An epic child now merges only when the newest run of the workflow named `CI` on the live PR head is a completed, successful `pull_request` run or the `workflow_dispatch` run recorded in `ci_gate.dispatch_run_id`. Skill, rule, brief, bundle, and manifest text carry the S9 dispatch fallback and the `epic/**` trigger guidance.

Reviewer checks at this head:

| Check (reviewer, this head) | Result |
|---|---|
| SHA-256 of the four helper copies (two hook directories, two bundles) | One digest, `372e696c...5013915` |
| `cmp` of both gates against their bundle copies | Identical |
| `git diff --quiet` over both review helpers, the green-CI helper, `.claude/lib/ci-gate`, both epic-orchestrator agent files, `.claude/settings.json`, `.codex/config.toml` | No change |
| Python references in the helper and both gates | One comment line stating that the helper invokes no Python; no invocation |
| Dot-source or module import in the helper | None |
| `Invoke-DocsOnlyGhExe` call sites in the helper | Two, one in each seam |
| Code reading of each stage in `Get-EpicMergeGateChildCiFailureDetail` | Each of the six stages returns a deny detail on failure; an unexpected error is caught and returned as a deny |
| Code reading of both gates | The review guard decision precedes the child branch; a child-CI failure returns a deny immediately, with no path to the epic, parallel, green-CI, standalone, or docs-only branches |
| Real-process probe: helper dot-sourced with `hook-docs-only-diff.ps1`, run against merged PR #1124 with real `gh` | Live head resolved; `gh run list` returned two runs with `createdAt` parsed as `System.DateTime`; selection chose run 42434650380 (`CI`, `pull_request`, `success`); decision `Verified=True` |
| Probe: `ci_gate.dispatch_run_id` of 12345678901 parsed from JSON | `System.Int64`, accepted as a positive integer |
| Push-down manifest coverage of the trigger guidance | `.claude/rules/ci-workflows.md` is in the Claude `core.json`; `.agents/skills/ci-workflows/SKILL.md` is in no Codex pack manifest (finding F1) |

**Policy documents evaluated:**
- ✅ `.claude/rules/general-code-change.md`
- ✅ `.claude/rules/general-unit-test.md`
- ✅ `.claude/rules/quality-tiers.md` (`quality-tiers.yml` exists; `.claude/hooks` and `.codex/hooks` are T3; no tier-dependent gate applies to PowerShell T3 code beyond the uniform gates)
- ✅ `.claude/rules/tonality.md`
- ✅ Enforcement hooks must not invoke Python (owner rule)

**Language-specific policies evaluated:**
- ✅ `.claude/rules/powershell.md`
- ✅ `.claude/rules/python.md` (one test-support file)
- N/A TypeScript, C#, Bash (zero changed files)

**Temporary artifacts cleanup:**
- ✅ `git status` of the item worktree was clean before the review. Reviewer probes ran from scripts in the session scratchpad and wrote nothing to the worktree. After the review, `git status` lists only the four review artifacts and the AC13 check-box change in `spec.md`.

---

## Rejected Scope Narrowing

The audit covers the full diff `cdcff3871765..03d222c55`. Caller statements considered:

- "The CI-dependent result is not a local blocker; the PR does not exist yet." This states how to classify a CI result that cannot exist before the PR. It removes no toolchain or coverage check. CI on the PR head is recorded as pending-CI and is not a finding.
- "Note: no file in this repository writes a destination CI workflow trigger; the push-down obligation is carried by the pushed-down ci-workflows rule/skill text. Judge whether that is stated accurately." This asks for a judgement and is not a narrowing. It was judged; see finding F1.

No statement narrowed the audit, and none was applied as a narrowing.

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
| **Independence** - Tests run in any order | ✅ PASS | New rows register their seam mocks per `It` or in `BeforeAll`; no shared mutable state; the 8-shard parallel gate passed with 0 failures. |
| **Isolation** - Each test targets single behavior | ✅ PASS | One gate row per verification stage, one row per allow case, and direct rows per pure helper and seam. |
| **Fast Execution** - Tests complete quickly | ✅ PASS | No process, network, or wait in the new rows. |
| **Determinism** - Consistent results | ✅ PASS | Fixed object ids and fixed `DateTime` values; `Invoke-DocsOnlyGhExe` and both seams mocked. |
| **Readability & Maintainability** - Clear structure | ✅ PASS | Row names `CHILD-CI-STAGE<N>-<CASE>` and `RGC-CHILD-CI-*`; Arrange-Act-Assert comments. |

### 1.2 Coverage and Scenarios

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Baseline Coverage Documented** | ✅ PASS | `pester-baseline.2026-11-08T13-29.md`, `pester-per-file-coverage.2026-11-08T13-52.md`, `pytest-baseline.2026-11-08T13-27.md`. |
| **No Coverage Regression** | ✅ PASS | PowerShell 95.56% to 95.58% repo-wide; Claude gate 98.60% to 98.63%; Codex gate 99.40% to 99.43%. The uncovered lines of the gates (Claude 295 and 299; Codex 430) are outside the changed hunks, so every changed line is covered. |
| **New Code Coverage** | ✅ PASS | Claude helper 83 of 83 lines; Codex helper 81 of 83 (lines 216 and 251, both exercised through the Claude copy). |
| **Modified Files** | ✅ PASS | Both gates above 85% and no regression on changed lines. |
| **Comprehensive Coverage** | ✅ PASS | Every helper function has gate or direct rows. |
| **Positive Flows** - Valid inputs | ✅ PASS | Allow rows: green `pull_request` run, recorded `workflow_dispatch` run, bare command with a recorded PR, in both suites. |
| **Negative Flows** - Invalid inputs | ✅ PASS | One deny row per stage in both suites; the Claude PR-mismatch row is a direct row because the existing binding predicate rejects it first. |
| **Edge Cases** - Boundary conditions | ✅ PASS | Uppercase and short head, string PR number, unreadable `createdAt`, empty run list, tie on `createdAt`. |
| **Error Handling** - Error paths | ✅ PASS | gh non-zero exit, malformed output, non-array document, a seam that throws. |
| **Concurrency** - If applicable | N/A | The helper holds no shared state. |
| **State Transitions** - If applicable | N/A | No stateful component. |

### 1.2.1 Per-Language Coverage Comparison

- PowerShell: Baseline: 95.56% repo-wide lines -> Post-change: 95.58% repo-wide lines. Change: +0.02 points. Per file: Claude gate 98.60% to 98.63%, Codex gate 99.40% to 99.43%. New/changed-code coverage: 100.00% Claude helper, 97.59% Codex helper; all changed gate lines covered. Disposition: PASS. Evidence: `artifacts/pester/powershell-coverage.xml`, `evidence/baseline/pester-per-file-coverage.2026-11-08T13-52.md`, `evidence/qa-gates/post-merge-gates.2026-11-08T15-22.md`.
- Python: Baseline: 94.82% lines -> Post-change: 94.82% lines; branches 90.17% after the change. Change: 0.00 points on lines. The one changed Python file is test support outside the measured denominator, and no Python production file changed. Disposition: PASS. Evidence: `artifacts/python/lcov.info`, `evidence/baseline/pytest-baseline.2026-11-08T13-27.md`, `evidence/qa-gates/post-merge-gates.2026-11-08T15-22.md`.
- TypeScript: zero changed files; no comparison is owed.
- C#: zero changed files; no comparison is owed.
- Bash: zero changed files; no comparison is owed.

### 1.3 Test Structure and Diagnostics

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Clear Failure Messages** | ✅ PASS | `-Because` carries the observed reason in the gate rows. |
| **Arrange-Act-Assert Pattern** | ✅ PASS | Comment markers in the new rows. |
| **Document Intent** | ✅ PASS | Suite `.DESCRIPTION` blocks state scope; each mock added to an existing suite carries a one-line reason naming issue #1130. |

### 1.4 External Dependencies and Environment

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Avoid External Dependencies** | ✅ PASS | No gh, git, or network in tests; synthetic forward-slash roots. |
| **Use Mocks/Stubs** | ✅ PASS | The wrapper `Invoke-DocsOnlyGhExe` and the two named seams are mocked, as `.claude/rules/powershell.md` requires. |
| **Environment Stability** | ✅ PASS | No temporary file; `Invoke-PoshQCLeakScan` 0 failures. |

### 1.5 Policy Audit Requirement

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Pre-submission Review** | ✅ PASS | This audit, with `code-review.2026-11-08T15-30.md` and `feature-audit.2026-11-08T15-30.md`; executor self-review `self-review.2026-11-08T15-04.md`. |

---

## 2. General Code Change Policy Compliance

### 2.1 Before Making Changes

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Clarify the objective** | ✅ PASS | `spec.md` root cause and design; research record `research.2026-11-08T13-40.md`. |
| **Read existing change plans** | ✅ PASS | `plan.2026-11-08T08-08.md`, all tasks checked; preflight fixes recorded. |
| **Document the plan** | ✅ PASS | The plan matches the diff. |

### 2.2 Design Principles

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Simplicity first** | ✅ PASS | One helper with six ordered stages; each gate gains one guarded dot-source line and one call. |
| **Reusability** | ✅ PASS | One byte-identical helper serves both runtimes and reuses the existing gh wrapper. |
| **Extensibility** | ✅ PASS | The entry contract (`Verified`, `Reason`) is stable; the workflow name is one literal. |
| **Separation of concerns** | ✅ PASS | Pure selection and validation helpers are separate from the two gh seams. |

### 2.3 Module & File Structure

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Cohesive modules** | ✅ PASS | The helper holds only child-CI verification. |
| **At or below the 800-line hard limit** | ✅ PASS | Logical counts: Claude gate 500, Codex gate 436, helper 315, largest test file 475. No covered file reaches 700. `config/file-size-baseline.json` is not in the diff. |
| **Public vs internal** | ✅ PASS | Entry `Get-EpicMergeGateChildCiDecision`; the failure-detail function is internal. |
| **No circular dependencies** | ✅ PASS | The helper dot-sources nothing. |

### 2.4 Naming, Docs, and Comments

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Descriptive names** | ✅ PASS | `EpicMergeGateChildCi` prefix on every function. |
| **Docs/docstrings** | ✅ PASS | Comment-based help on every function and a file header listing the six stages. |
| **Comment why, not what** | ✅ PASS | Each catch states why it fails closed. |

### 2.5 After Making Changes - Toolchain Execution

| Requirement | Status | Evidence |
|------------|--------|----------|
| **1. Formatting** | ✅ PASS | `static-final.2026-11-08T14-22.md`: 0 of 22 PowerShell files differ from `Invoke-Formatter`; Black leaves the Python file unchanged. Read from the static artifact, not re-run. |
| **2. Linting** | ✅ PASS | Same artifact: PSScriptAnalyzer 0 findings; Ruff all checks passed. |
| **3. Type checking** | ✅ PASS | Pyright 0 errors on the Python file; PowerShell has no type-check stage. |
| **4. Testing** | ✅ PASS | Pester 19762 tests, 0 failures; pytest 16537 passed, 0 failed (post-merge gate). |
| **Full toolchain loop** | ✅ PASS | The static loop restarted after its fixes; the Pester gate re-ran once after the isolation fix. |
| **Explicit reporting** | ✅ PASS | Every artifact carries timestamp, command, exit code, and summary. |

### 2.6 Summarize and Document

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Summarize changes** | ✅ PASS | Section 9. |
| **Design choices explained** | ✅ PASS | Spec `## Proposed Fix`; `.claude/rules/orchestrator-state.md` section `## Epic-child CI verification (issue #1130)`. |
| **Update supporting documents** | ❌ FAIL | Skills, rules, brief copies, and bundles are updated and match. The `.agents/skills/ci-workflows/SKILL.md` text says destinations receive the rule through push-down, but that file is in no Codex pack manifest, so a push-down never delivers it (F1). |
| **Provide next steps** | ✅ PASS | Section 10. |

---

## 3. Language-Specific Code Change Policy Compliance

### Section 3A: Python Code Change Policy Compliance

One test-support file changed (`parallel_orchestrator_surface_expectations.py`: pin digest and comment). Black, Ruff, and Pyright clean per `static-final.2026-11-08T14-22.md`. The new digest equals the reviewer's SHA-256 of `.claude/skills/epic-orchestrate/SKILL.md` (`934a7bca...abcb856`).

### Section 3B: PowerShell Code Change Policy Compliance

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Advanced functions** | ✅ PASS | `CmdletBinding`, `OutputType`, `Mandatory`, `AllowNull` on every helper function. |
| **Wrapper seam for executables** | ✅ PASS | gh runs only through `Invoke-DocsOnlyGhExe -GhArgs <array>`. |
| **Avoid global state** | ✅ PASS | One script-scoped constant (the reason prefix). |
| **Error handling** | ✅ PASS | Every failure returns a deny; no silent catch. |
| **PowerShell 7+** | ✅ PASS | Hooks target PowerShell 7. |
| **No Python in hooks** | ✅ PASS | No invocation in the helper or either gate. |

### Section 3C: TypeScript Code Change Policy Compliance

No TypeScript file changed. Not applicable.

---

## 4. Language-Specific Unit Test Policy Compliance

### Section 4A: Python Unit Test Policy Compliance

No Python test logic changed; the pin file is test data. The frozen-surface, manifest-completeness, dependency-closure, bundle-parity, and `test_ci_gate_epic_child_contracts.py` tests passed in the gate.

### Section 4B: PowerShell Unit Test Policy Compliance

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Use Pester v6.x** | ✅ PASS | Pester 6.2.0 through PoshQC. |
| **Use PoshQC Configuration** | ✅ PASS | `Invoke-PoshQCParallelTest`. |
| **Focused Unit Tests** | ✅ PASS | One behavior per row. |
| **Mock the wrapper, not the executable** | ✅ PASS | `Invoke-DocsOnlyGhExe` and named seams only. |
| **Organization / File Naming** | ✅ PASS | `tests/scripts/claude-hooks/` and `tests/scripts/codex-hooks/` mirror the hook directories. |

### Section 4C: TypeScript Unit Test Policy Compliance

No TypeScript test changed. Not applicable.

---

## 5. Test Coverage Detail

| Subject | Tests | Scenario Types | Status |
|---------|-------|----------------|--------|
| Regression (fail before, pass after) | `CHILD-CI-NO-CI-GATE` | Epic child with no `ci_gate` denied | ✅ |
| Stage 1 to 6 deny rows | `CHILD-CI-STAGE*`, `RGC-CHILD-CI-STAGE*` | Deny detail per stage; Claude rows assert no epic or parallel checkpoint read; Codex rows supply an epic checkpoint that would allow | ✅ |
| Allow rows | `CHILD-CI-ALLOW-*`, `RGC-CHILD-CI-ALLOW-*` | `pull_request`, recorded dispatch, bare command | ✅ |
| Seams | Live-head and run-list rows with the wrapper mocked | Success, non-zero exit, malformed, non-array, empty | ✅ |
| Byte identity | Claude suite `helper twins` row | Copies equal | ✅ |
| Dependency failure | `hook-dependency-failure.SpecialCases` C11 | Claude gate denies naming the helper when it fails to load | ✅ |

**Discrimination.** The regression row failed before the fix with an observed allow (`child-ci-fail-before.2026-11-08T13-55.md`). The Codex deny rows would read as an allow on any fall-through, because each supplies an epic checkpoint that allows PR 42.

---

## 6. Test Execution Metrics

| Metric | Value | Status |
|--------|-------|--------|
| Pester | 19762 tests, 0 failures (baseline 19584, 0 failures) | ✅ |
| pytest | 16537 passed, 0 failed, 6 skipped (baseline the same) | ✅ |
| Regression row before the fix | 1 failed with observed allow | ✅ |

---

## 7. Code Quality Checks

| Check | Command | Result | Status |
|-------|---------|--------|--------|
| PoshQC format (check mode) | `Invoke-Formatter` compared with file text over 22 files | 0 differ (static artifact, not re-run) | ✅ |
| PSScriptAnalyzer | `Invoke-ScriptAnalyzer` with the repo settings | 0 findings (static artifact, not re-run) | ✅ |
| Evidence locations | `validate_evidence_locations.py --root <worktree>` | Exit 0 (reviewer) | ✅ |

## CI Cross-check

| Check | Claimed outcome | Claimed figure | Head | Source |
|---|---|---|---|---|
| `poshqc / PowerShell QC static` | pass | 0 formatter differences, 0 analyzer findings over 22 PowerShell files | `03d222c55` | `evidence/qa-gates/static-final.2026-11-08T14-22.md` |
| `poshqc / PowerShell QC shard 1` | pass | Part of 19762 tests, 0 failures | `03d222c55` | `evidence/qa-gates/post-merge-gates.2026-11-08T15-22.md` |
| `poshqc / PowerShell QC shard 2` | pass | Part of 19762 tests, 0 failures | `03d222c55` | `evidence/qa-gates/post-merge-gates.2026-11-08T15-22.md` |
| `poshqc / PowerShell QC shard 3` | pass | Part of 19762 tests, 0 failures | `03d222c55` | `evidence/qa-gates/post-merge-gates.2026-11-08T15-22.md` |
| `poshqc / PowerShell hook suites (Linux)` | pass | Both new child-CI suites use forward-slash synthetic roots | `03d222c55` | `evidence/qa-gates/pester-final.2026-11-08T15-01.md` |
| `quality-checks7 / Code Quality & Tests (3.13)` | pass | 16537 passed, 0 failed; 94.82% lines, 90.17% branches | `03d222c55` | `evidence/qa-gates/post-merge-gates.2026-11-08T15-22.md`; `artifacts/python/lcov.info` |

No pull request exists for this branch yet, so no CI run exists on this head. These rows are pending-CI and are not findings.

---

## 8. Gaps and Exceptions

### Identified Gaps

1. **F1 (Major):** the Codex `ci-workflows` skill, which carries the `epic/**` trigger requirement and the push-down refresh statement, is listed in no Codex pack manifest. `compute_published_paths()` publishes only manifest-listed files, so a push-down never delivers it, and its sentence "Destination repositories receive this rule only through push-down" is inaccurate for Codex destinations. The Claude rule is pushed down.
2. **CR2 (Minor, non-blocking):** the Codex gate now denies an explicit-PR merge at stage 1 when a ready epic-child checkpoint at the repository root records a different PR, where the Claude gate falls through. The spec directs this, and it fails closed.
3. **CR3 (Minor, non-blocking):** the spec assumption that `gh pr checks` lists the check runs of a `workflow_dispatch` run on the PR head is still unconfirmed. The S9 dispatch fallback polls through it. If it does not hold, S9 stays pending, which blocks the merge and does not weaken the gate.
4. **CR4 to CR5 (Nit):** recorded in the code review.
5. **CI on this head:** no PR yet; pending-CI, not a finding.

### Approved Exceptions

**None.**

### Removed/Skipped Tests

**None removed.** The 10 disabled tests are pre-existing skips outside this change.

---

## 9. Summary of Changes

The branch adds the epic-child CI verification helper to both hook directories and their bundles, wires it into both merge gates without fall-through, documents the S9 dispatch fallback and `ci_gate.dispatch_run_id`, adds the `epic/**` trigger guidance to the `ci-workflows` rule and skill, updates the six execution-environment brief copies, both `core.json` manifests, and the frozen-surface pin, and adds two Pester suites plus seam mocks in twelve existing test files. The branch log and the diff from merge base `cdcff3871765` to reviewed head `03d222c55`, named under **Code Under Test**, carry the commits and files.

---

## 10. Compliance Verdict

### Overall Status: ❌ REMEDIATION REQUIRED

One blocking finding, F1, which the branch can fix without an external dependency.

### Policy-by-Policy Summary

#### General Code Change Policy (Section 2)
- ✅ Design, structure, toolchain loop
- ❌ Supporting documents: F1

#### Language-Specific Code Change Policy (Section 3)
- ✅ PowerShell and Python

#### General Unit Test Policy (Section 1)
- ✅ Core principles, scenario coverage, coverage artifacts, Phase 0 baseline comparison

#### Language-Specific Unit Test Policy (Section 4)
- ✅ PowerShell and Python

### Metrics Summary

- ✅ 0 failures across Pester and pytest
- ✅ PowerShell 95.58% repo-wide lines; new helpers 100.00% and 97.59%
- ✅ Python 94.82% lines, 90.17% branches

### Recommendation

Fix F1 in a light cycle: register `.agents/skills/ci-workflows/SKILL.md` in the Codex `core.json` and remove it from `PRE_EXISTING_UNRELATED_SKILL_EXCEPTIONS`, then re-run the pytest gate. After that, merge once CI is green.

---

## Appendix A: Test Inventory

Pester (new): `tests/scripts/claude-hooks/enforce-epic-merge-gate.ChildCi.Tests.ps1`, `tests/scripts/codex-hooks/enforce-epic-merge-gate-child-ci.Tests.ps1`. Pester (modified): `EpicMergeGateReview.Cases.Helpers.ps1`, `enforce-epic-merge-gate.Tests.ps1`, `.EpicModeStrict`, `.GreenCiRegression`, `.ReviewGuard`, `.ReviewPaths`, `.WorktreeResolution`, `hook-dependency-failure.SpecialCases.Tests.ps1`, Codex `codex-epic-runtime-contracts`, `enforce-epic-merge-gate-authorization`, `enforce-epic-merge-gate-review`, `epic-execution-gates`. Python (modified test data): `tests/scripts/dev_tools/parallel_orchestrator_surface_expectations.py`.

---

## Appendix B: Toolchain Commands Reference

Run by the reviewer against the item worktree:

```sh
git -C <worktree> fetch origin main
git -C <worktree> merge-base origin/main HEAD
git -C <worktree> merge-tree --write-tree origin/main HEAD
git -C <worktree> diff --stat <merge-base>..HEAD
sha256sum <four helper copies> <skill, rule, brief copies>
cmp <gate> <bundle gate>
git -C <worktree> diff --quiet <merge-base>..HEAD -- <unchanged surfaces>
python scripts/dev_tools/validate_evidence_locations.py --root <worktree>
pwsh -NoProfile -Command <dot-source hook-docs-only-diff.ps1 and the helper; run the seams and decision against PR 1124>
pwsh -NoProfile -Command <parse artifacts/pester/powershell-coverage.xml root and per-file LINE counters>
awk <sum LF, LH, BRF, BRH in artifacts/python/lcov.info>
```

Template note: the bundled template asset was not resolved through MCP in this session, because the resolver tool is not available to this agent. The structure follows the most recent policy audit in this repository, and the MCP validator checked this file.

---

**Audit Completed By:** feature-review agent
**Audit Date:** 2026-11-08
**Policy Version:** Current (as of audit date)
