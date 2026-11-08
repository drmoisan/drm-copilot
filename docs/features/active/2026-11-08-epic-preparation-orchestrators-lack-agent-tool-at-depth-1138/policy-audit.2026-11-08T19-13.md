# Policy Compliance Audit: Epic preparation orchestrators lack the Agent tool at depth (#1138)

**Audit Date:** 2026-11-08
**Code Under Test:** merge base `72e8b299c8ce99adce7db335e936974e8119493b` of `origin/main` and reviewed head `039dc51af81cc31f05f27e189843bd9f4506fcdb`; the diff between them lists the changed files (70 paths). Re-audit after full remediation cycle 2 (prior review `*.2026-11-08T18-49.md`, finding F2). Delta since the prior reviewed head `88cbdb8ea`: `91527f56b` (prior review artifacts), merge commit `1db21f006` (origin/main merged, pin conflict resolved), `039dc51af` (post-merge gate evidence).

**Coverage Metrics by Language:**

| Language | Files Changed | Tests | Test Result | Baseline Coverage | Post-Change Coverage | New Code Coverage |
|----------|--------------|-------|-------------|-------------------|---------------------|-------------------|
| PowerShell | 4 production (2 hooks plus 2 bundle copies), 3 test | 20293 | PASS 0 failures | 95.62% lines | 95.66% lines | 100% (new helper, 19/19), 90.79% (origin hook, 69/76) |
| Python | 0 production, 2 test | 16566 | PASS 16560 pass, 0 fail, 6 skipped | 97.11% lines, 94.37% branches | 97.11% lines, 94.37% branches | N/A - no Python production file changed |
| JSON | 1 file | N/A | PASS pack manifest contract tests | N/A (config files) | N/A (config files) | N/A |

### Coverage Evidence Checklist

- TypeScript baseline coverage artifact: N/A - zero changed TypeScript files
- TypeScript post-change coverage artifact: N/A - zero changed TypeScript files
- PowerShell baseline coverage artifact: `evidence/baseline/pester-baseline.2026-11-08T17-38.md`
- PowerShell post-change coverage artifact: `artifacts/pester/powershell-coverage.xml` (written 2026-11-08 19:11 UTC, after merge commit `1db21f006` at 18:54 UTC; parsed directly: root LINE 36251 covered, 1644 missed; helper 19 covered, 0 missed; origin hook 69 covered, 7 missed)
- Python baseline coverage artifact: `evidence/baseline/pytest-baseline.2026-11-08T17-40.md`
- Python post-change coverage artifact: `artifacts/python/lcov.info` (written 19:01 UTC, after the merge; totals recomputed: 34296 of 35317 lines, 12649 of 13404 branches)
- Per-language comparison summary: section 1.2.1

**Non-negotiable verdict rule:** numeric baseline and post-change metrics are recorded for PowerShell and Python, the two languages with changed files.

---

## Executive Summary

F2 is closed. `git merge-tree --write-tree --name-only origin/main HEAD` exits 0, and its result tree (`db6598fc7…`) equals the head tree, so the branch already contains `origin/main` (`72e8b299c`, which is now the merge base). In `PINNED_FROZEN_SURFACE_HASHES` the `epic-orchestrator.md` digest (`5ff9c66f…`) and the `epic-orchestrate/SKILL.md` digest (`2e67dae3…`) equal the SHA-256 of the head files; the #1136 comment block is kept unchanged and the #1138 block follows it, stating that the skill digest is the merged result of #1129, #1130, #1136, and #1138. The reviewer re-ran `tests/scripts/dev_tools/test_parallel_orchestrator_surface_contracts.py` with `pytest -n auto`: 38 passed.

The merge introduced no regression in the branch's files: for each of the nine files changed by both the branch and main, the branch's added and removed lines relative to its own base equal its added and removed lines relative to the new base. Post-merge gates (`evidence/qa-gates/post-merge-gates.2026-11-08T19-12.md`): pytest 0 failures, Pester 0 failures, coverage at or above baseline. No blocking finding remains.

**Policy documents evaluated:**
- PASS `general-code-change.md`
- PASS `general-unit-test.md`
- PASS `quality-tiers.md` (`.claude/hooks` is classified T3 in `quality-tiers.yml`)

**Language-specific policies evaluated:**
- PASS `powershell.md` (code and unit test)
- PASS `python.md` (test-only edits)
- N/A TypeScript, C#, Bash: zero changed files
- PASS JSON: one `core.json` entry, covered by the pack-manifest contract tests

**Temporary artifacts cleanup:**
- PASS `git status --porcelain` was empty at the reviewed head before this review wrote its artifacts; reviewer scripts are in the session scratchpad outside the repository.

---

## Rejected Scope Narrowing

Caller text: "Keep it focused on the delta since 88cbdb8ea; prior findings for unchanged files stand." Justification: the audit scope remains the full branch diff against the merge base of `origin/main` and HEAD (70 paths); unchanged files are carried forward from the `2026-11-08T18-49` review on evidence that their content is unchanged since `88cbdb8ea` apart from the merge, and every language with changed files has an explicit coverage verdict below. The instruction not to re-run format, lint, and type checks follows the evidence model and does not narrow scope.

## Evidence Location Compliance

No branch-diff file lies under `artifacts/baselines/`, `artifacts/qa/`, `artifacts/evidence/`, or `artifacts/coverage/`. `scripts/dev_tools/validate_evidence_locations.py --root .` run from the worktree root exited 0. The post-merge evidence is under `<FEATURE>/evidence/qa-gates/`. No EVIDENCE_LOCATION_OVERRIDE_REJECTED event.

---

## 1. General Unit Test Policy Compliance

### 1.1 Core Principles

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Independence** - Tests run in any order | PASS | Unchanged since the prior review; the merge did not change any branch test file |
| **Isolation** - Each test targets single behavior | PASS | Unchanged since the prior review |
| **Fast Execution** - Tests complete quickly | PASS | Surface-contract module: 38 tests in 5.12 s |
| **Determinism** - Consistent results | PASS | Post-merge gates green; the Python branch figure returned to 94.37% |
| **Readability & Maintainability** - Clear structure | PASS | Pin comment blocks state each re-baseline reason |

### 1.2 Coverage and Scenarios

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Baseline Coverage Documented** | PASS | 95.62% lines PowerShell, 97.11% lines and 94.37% branches Python (Phase 0 baseline artifacts) |
| **No Coverage Regression** | PASS | PowerShell 95.62% to 95.66%; Python lines and branches equal to baseline |
| **Changed Files Meet Thresholds** | PASS | Line threshold 85%: helper 100%, origin hook 90.79%; branch threshold not applicable to PowerShell |
| **New Code Coverage >=90%** | PASS | Helper 19 of 19 lines |
| **Comprehensive Coverage** | PASS | All three helper functions |
| **Positive Flows** | PASS | Unchanged since the prior review |
| **Negative Flows** | PASS | Unchanged since the prior review |
| **Edge Cases** | PASS | Unchanged since the prior review |
| **Error Handling** | PASS | Unchanged since the prior review |
| **Concurrency** | N/A | Stateless read-only helper |
| **State Transitions** | N/A | No stateful component |

### 1.2.1 Per-Language Coverage Comparison

- PowerShell: Baseline: 95.62% lines (from the `Phase 0 baseline` artifact) -> Post-change: 95.66% lines. Change: +0.04% lines. New/changed-code coverage: 100% new helper (19 of 19), 90.79% origin hook (69 of 76, baseline 90.41%). Disposition: PASS. Evidence: `evidence/baseline/pester-baseline.2026-11-08T17-38.md`, `evidence/qa-gates/post-merge-gates.2026-11-08T19-12.md`, `artifacts/pester/powershell-coverage.xml`.
- Python: Baseline: 97.11% lines, 94.37% branches -> Post-change: 97.11% lines, 94.37% branches. Change: 0 lines, 0 branches. New/changed-code coverage: No Python production file changed on the branch; the two edited files are test-support and test modules. Disposition: PASS. Evidence: `evidence/baseline/pytest-baseline.2026-11-08T17-40.md`, `evidence/qa-gates/post-merge-gates.2026-11-08T19-12.md`, `artifacts/python/lcov.info`.

### 1.3 Test Structure and Diagnostics

PASS. No test structure changed in the delta.

### 1.4 External Dependencies and Environment

PASS. No test file changed in the delta; the prior leak-scan result stands.

### 1.5 Policy Audit Requirement

PASS. This audit is the artifact.

---

## 2. General Code Change Policy Compliance

### 2.1 Before Making Changes
PASS. Phase 0 baselines under `evidence/baseline/`; post-merge gate evidence under `evidence/qa-gates/`.

### 2.2 Design Principles
PASS. The delta's only code-adjacent change is the merge resolution of the pin module.

### 2.3 Module & File Structure
PASS. Helper 126 lines, origin hook 295 lines, pin module 457 lines. No covered file reaches 700 lines; `config/file-size-baseline.json` is unchanged.

### 2.4 Naming, Docs, and Comments
PASS. Both the #1136 and #1138 comment blocks are present above `PINNED_FROZEN_SURFACE_HASHES`.

### 2.5 After Making Changes - Toolchain Execution
PASS. Post-merge evidence records `ruff check` and `black --check` clean on the resolved file, pytest 0 failures, Pester 0 failures. Format, lint, and type checks were not re-run by the reviewer per the caller's instruction; the prior static artifacts stand for files unchanged by the merge.

### 2.6 Summarize and Document
PASS. The merge commit message names the resolution; the evidence artifact records the gates.

---

## 3. Language-Specific Code Change Policy Compliance

### Section 3A: Python Code Change Policy Compliance

PASS. The delta changes one digest and the comment block in a test-support module.

### Section 3B: PowerShell Code Change Policy Compliance

#### 3B.1 Tooling & Baseline
PASS. No PowerShell file changed in the delta beyond the merged main content.

#### 3B.2 PowerShell Design & Safety
PASS. Unchanged since the prior review.

#### 3B.3 Structure, Naming, and Comments
PASS.

#### 3B.4 Running the Toolchain
PASS. Post-merge `Invoke-PoshQCParallelTest`: ExitCode 0, JUnit tests=20293, failures=0.

### Documentation Surface Check
N/A. `docs/documentation-estate/docs-profile.json` is absent at the head, so the check produces no finding.

### Tier classification
PASS. `quality-tiers.yml` exists; the changed production files are under `.claude/hooks`, classified T3.

---

## 4. Language-Specific Unit Test Policy Compliance

### Section 4A: Python Unit Test Policy Compliance

PASS. `test_frozen_epic_surface_matches_pinned_baseline_digest` and `test_brief_copies_are_byte_identical` passed in the reviewer's `pytest -n auto` run of the surface-contract module (38 passed) and in the post-merge full run.

### Section 4B: PowerShell Unit Test Policy Compliance

#### 4B.1 Framework and Scope
PASS. Pester 6.x through `Invoke-PoshQCParallelTest`.

#### 4B.2 Test Style and Structure
PASS. Unchanged.

#### 4B.3 Naming and Readability
PASS.

#### 4B.4 Running the Toolchain
PASS. Post-merge gate green.

---

## 5. Test Coverage Detail

### Pin module (merge resolution)
Both digests equal `sha256sum` of the head files: `.claude/agents/epic-orchestrator.md` = `5ff9c66f58595fa91a1f568a18a0a5aae5d1736a9dd1b13a9bbbab459df7899c`, `.claude/skills/epic-orchestrate/SKILL.md` = `2e67dae3dd5a015693696125374e341f8c21963f36145bcf5fa8265ff8be924e` (the value the prior review derived from the merge-tree result).

### Hooks
Coverage unchanged in substance: helper 19/19, origin hook 69/76.

---

## 6. Test Execution Metrics

| Metric | Value | Status |
|--------|-------|--------|
| Total Tests | 20293 Pester, 16566 pytest | PASS |
| Tests Passed | Pester 0 failures; 16560 pytest (6 skipped) | PASS |
| Tests Failed | 0 | PASS |
| Execution Time | Not recorded in the post-merge artifact | N/A |
| Average Time per Test | N/A (parallel gate) | N/A |
| Discovery Time | N/A | N/A |
| Functions/Classes Tested | 3/3 helper functions plus the origin decision function | PASS |
| Test File Size | 499 logical lines largest | PASS |
| Code Coverage | 95.66% PowerShell lines; 97.11% Python lines, 94.37% Python branches | PASS |

---

## 7. Code Quality Checks

| Check | Result |
|-------|--------|
| PSScriptAnalyzer | PASS 0 findings (prior artifact; no PowerShell branch file changed in the delta) |
| Invoke-Formatter check | PASS 0 drift (prior artifact) |
| Leak scan | PASS 0 failures (prior artifact) |
| Black, Ruff on the resolved pin module | PASS (post-merge artifact) |
| Mergeability with `origin/main` | PASS `git merge-tree --write-tree --name-only origin/main HEAD` exit 0; result tree equals the head tree |

## CI Cross-check

No pull request and no CI run exist for the branch yet (`gh pr list --head bug/epic-subagent-nesting-depth --state all` returned empty). The rows record the local evidence the review relies on; CI confirmation is pending-CI at S9.

| Check | Claimed outcome | Claimed figure | Head | Source |
|-------|-----------------|----------------|------|--------|
| Pester suite | pass | 20293 tests, 0 failed | 1db21f006e0f45ac0c4d45fb79c05ad974dac890 | `evidence/qa-gates/post-merge-gates.2026-11-08T19-12.md` |
| `Enforce Python coverage thresholds` | pass | 97.11% lines, 94.37% branches | 1db21f006e0f45ac0c4d45fb79c05ad974dac890 | `evidence/qa-gates/post-merge-gates.2026-11-08T19-12.md`, `artifacts/python/lcov.info` |
| Surface-contract pytest module (reviewer run) | pass | 38 passed | 039dc51af81cc31f05f27e189843bd9f4506fcdb | reviewer command |
| `poshqc / PowerShell QC static` | pass | 0 findings, 0 leak failures | 88cbdb8eaf22197b1e74ba262affcbeb019e9b12 | `evidence/qa-gates/poshqc-static-final.2026-11-08T18-42.md` |

Head `039dc51af` differs from `1db21f006` only by the evidence Markdown file.

---

## 8. Gaps and Exceptions

### Identified Gaps
- None blocking. AC9 CI confirmation on the PR head is pending-CI and is not a finding.

### Approved Exceptions
- Fail-before exception dossier `evidence/regression-testing/fail-before-exception.2026-11-08T17-25.md`.

### Removed/Skipped Tests
None.

---

## 9. Summary of Changes

Since `88cbdb8ea`: the prior review artifacts, the merge of `origin/main` (PR #1140, issue #1136) with the pin conflict resolved by keeping both comment blocks and setting the skill digest to the merged file's SHA-256, and post-merge gate evidence.

---

## 10. Compliance Verdict

### Overall Status: COMPLIANT

No policy violation was found and no blocking finding remains. Review verdict PASS.

**Fail-closed reminder:** All required baseline, QA, and coverage artifacts were present.

---

### Policy-by-Policy Summary

#### General Code Change Policy (Section 2)
- PASS Before Making Changes
- PASS Design Principles
- PASS Module & File Structure
- PASS Naming, Docs, Comments
- PASS Toolchain Execution
- PASS Summarize & Document

#### Language-Specific Code Change Policy (Section 3)

**For PowerShell:**
- PASS Tooling & Baseline
- PASS PowerShell Design & Safety
- PASS Structure & Naming
- PASS Toolchain

**For Python:**
- PASS Test-only edits, static checks clean

#### General Unit Test Policy (Section 1)
- PASS Core Principles
- PASS Coverage & Scenarios
- PASS Test Structure
- PASS External Dependencies
- PASS Policy Audit

#### Language-Specific Unit Test Policy (Section 4)

**For PowerShell:**
- PASS Framework & Scope
- PASS Test Style & Structure
- PASS Naming & Readability
- PASS Toolchain

---

### Metrics Summary

- PASS Pester 20293 tests, 0 failures; 16560 pytest passing (6 skipped)
- PASS 95.66% PowerShell line coverage; 97.11% Python line coverage
- PASS Proper file organization
- PASS All code quality checks on the branch content

---

### Recommendation

**Proceed to PR authoring; confirm AC9 through CI at S9.**

---

## Appendix A: Test Inventory

- `tests/scripts/claude-hooks/epic-invocation-nesting-depth.Tests.ps1` (new)
- `tests/scripts/claude-runtime/NestingDepthContract.Tests.ps1` (new)
- `tests/scripts/claude-hooks/enforce-epic-invocation-origin.Tests.ps1` (setup-only seam mock)
- `tests/scripts/dev_tools/parallel_orchestrator_surface_expectations.py` (pin re-baseline; merge-resolved in cycle 2)
- `tests/scripts/dev_tools/test_parallel_orchestrator_surface_contracts.py` (heading count 16 to 17)

## Appendix B: Toolchain Commands Reference

Post-merge gates as recorded in `evidence/qa-gates/post-merge-gates.2026-11-08T19-12.md`. Reviewer checks: `git merge-tree --write-tree --name-only origin/main HEAD`, `git diff <merge-tree> HEAD`, `sha256sum` of the pinned files, per-file comparison of branch hunks against the old and new bases, `cmp` of live and bundle copies, `git rev-parse HEAD:<path>` for the six brief copies, direct parsing of the coverage artifacts, and `pytest -n auto` on the surface-contract module.
