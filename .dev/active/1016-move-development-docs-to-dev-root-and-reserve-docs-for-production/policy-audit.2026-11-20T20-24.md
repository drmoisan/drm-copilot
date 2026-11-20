# Policy Compliance Audit: Issue 1016 — migrate_development_docs tool and the .dev move (epic 1018 child 7), re-audit after remediation cycle 1

**Audit Date:** 2026-11-20  
**Code Under Test:** merge base `5f8a76ef9c2dded22bd9128d4f9337fabc6cf6c3` of the base branch `origin/epic/shared-agent-harness-layer-integration` and reviewed head `7322bc6251aca5e9d2beb11e528f847da44b6764`; the diff between them is the full branch scope. The remediation cycle range is `f744ce9e060a98dec1be9d393bba5c644e81ed61..7322bc6251aca5e9d2beb11e528f847da44b6764` (13 commits, 46 files: 6 code or test files, 2 requirement documents, the rest review records and evidence).

**Coverage Metrics by Language:**

| Language | Files Changed | Tests | Test Result | Baseline Coverage | Post-Change Coverage | New Code Coverage |
|----------|--------------|-------|-------------|-------------------|---------------------|-------------------|
| TypeScript | 23 production files (13 added, 10 modified) plus 75 test files; cycle: 2 production, 3 test | 6707 extension, 6724 root (launcher) | ✅ 0 fail | 97.59% lines, 94.95% branches (extension gate, cycle Phase 0) | 97.59% lines, 94.96% branches (extension gate); root launcher run 98.44% lines, 94.64% branches | 100% (cycle: 28 of 28 added lines, 11 of 11 branches); 12 of 13 new files 100% lines, CLI 96.5% |
| Python | 7 production files (2 hand-edited) plus 74 test files; cycle: none | 17104 tests | ✅ 17104 pass, 0 fail | 96.66% lines, 92.53% branches | 96.66% lines, 92.53% branches | 100% (11 new statements, 8 new branches in build_discovery_runtime.py) |
| PowerShell | 16 production files plus 13 bundle copies plus 150 test files; cycle: 1 test file | 29157 tests | ✅ 29157 pass, 0 fail | 96.84% lines (47286/48827) | 96.84% lines (47286/48827) | 100% (13 new lines in ProcessReductionChain.psm1) |
| Bash | 1 production file plus 1 bundle copy plus 1 bats file; cycle: none | 14 tests | ✅ 14 pass, 0 fail | 89.8% lines | 89.8% lines (kcov, report-lane-assertion.sh) | 100% (the changed line is heredoc text in the executed usage block) |
| JSON | 8 files (routing copies, blast-radius, jest coverage map, tasks, fixture); cycle: dry-run report JSON only | N/A | ✅ parse and parity tests pass | N/A (config files) | N/A (config files) | N/A |

### Coverage Evidence Checklist

- TypeScript baseline coverage artifact: `.dev/active/1016-move-development-docs-to-dev-root-and-reserve-docs-for-production/evidence/remediation-baseline/baseline-citation.2026-11-20T19-13.md` (cites `evidence/qa-gates/ts-test-coverage.2026-11-20T18-10.md` and `review-coverage-check.2026-11-20T18-28.md`)
- TypeScript post-change coverage artifact: `coverage/lcov.info` (root launcher run, modified 20:03:59 UTC) and `evidence/qa-gates/ts-test-coverage.2026-11-20T20-13.md`, `evidence/qa-gates/root-jest-coverage.2026-11-20T20-14.md`
- Python baseline coverage artifact: `evidence/remediation-baseline/baseline-citation.2026-11-20T19-13.md`
- Python post-change coverage artifact: `artifacts/python/lcov.info` (modified 20:06 UTC) and `evidence/qa-gates/py-test-coverage.2026-11-20T20-12.md`
- PowerShell baseline coverage artifact: `evidence/remediation-baseline/baseline-citation.2026-11-20T19-13.md`
- PowerShell post-change coverage artifact: `artifacts/pester/powershell-coverage.xml` (modified 20:18 UTC) and `evidence/qa-gates/ps-test-coverage.2026-11-20T20-18.md`
- Per-language comparison summary: section 1.2.1 below and `evidence/qa-gates/coverage-delta.2026-11-20T20-19.md`

The reviewer parsed the three standing coverage artifacts directly: root `coverage/lcov.info` 81575/82866 lines (98.44%), 12706/13426 branches (94.64%), `layout-map.ts` 181/181 lines and 27/27 branches, `migration-plan.ts` 589/589 lines and 145/147 branches; `artifacts/python/lcov.info` 17720/18332 lines (96.66%), 6194/6694 branches (92.53%); `artifacts/pester/powershell-coverage.xml` root LINE counter 47286/48827 (96.84%), and `pester-junit.xml` 29157 tests, 0 failures, with `STR-ENTRY-PRINTS-LABELS-AND-FIXTURE-MEDIANS` Passed. All three artifacts were written after the last code commit `520617870` (19:59:01 UTC); the two later commits change only evidence. The figures equal the executor's gate records.

---

## Executive Summary

Remediation cycle 1 closes the three blocking findings of `remediation-inputs.2026-11-20T18-20.md`. F1: `scanRewrites` now keeps a record already at a mapping-table target in the in-tree branch through the new pure predicate `isMappedTargetPath`, two fail-before Jest cases pin the behavior, and the post-apply dry run from a branch build reports 0 moves, 0 renames, 0 outside-tree rewrites and 0 in-tree links-only candidates, with the four Stay-row files excluded. F2: `user-story.md` records the A14 supersession and restates criterion (c) 1; the restated criterion is met by `folder-rename-decisions.2026-11-20T12-24.json` and is checked off by this review. F3: the stage-timing entry test no longer reads the real checkout, the CI failure was reproduced on an emulated clean layout before the fix, and the static and dynamic sweeps found no other real-checkout read of a moved root. No regression was found in the cycle diff. Four toolchain criteria remain pending CI and are not findings. No blocking finding remains.

**Policy documents evaluated:**
- ✅ `.claude/rules/general-code-change.md`
- ✅ `.claude/rules/general-unit-test.md`
- ✅ `.claude/rules/quality-tiers.md` (tier classification not applicable: no `quality-tiers.yml` at the base)
- ✅ `.claude/rules/tonality.md`

**Language-specific policies evaluated:**
- ✅ `.claude/rules/typescript.md` + `.claude/rules/typescript-suppressions.md` + `.claude/rules/architecture-boundaries.md`
- ✅ `.claude/rules/python.md` + `.claude/rules/python-suppressions.md`
- ✅ `.claude/rules/powershell.md`
- ✅ Bash: no bash file changed in the cycle; the branch-level bats and kcov results of the prior review stand
- ✅ JSON: routing parity and blast-radius tests

**Temporary artifacts cleanup:**
- ✅ Executor launchers, derived decision files and staged copies live under the issue scratch directory; the clean-layout relocation target is under that directory and holds only empty directory trees
- ✅ The reviewer's parse script is in the session scratchpad and is not committed

---

## Rejected Scope Narrowing

No narrowing was detected. The caller states that the four CI-dependent toolchain criteria remain pending-CI and are not findings; this matches the treatment of the prior review and `acceptance-criteria-tracking` `### CI-Dependent Criteria`, and it is not a narrowing of the audit scope. The caller also asked not to wait for CI run 44810698464; the review records the jobs that had completed at review time in `## CI Cross-check` and does not depend on the in-progress jobs for any verdict.

## Evidence Location Compliance

`env -u VIRTUAL_ENV poetry -C <worktree> run python scripts/dev_tools/validate_evidence_locations.py --root <worktree>` exited 0 with no reported path. `git diff --name-only 5f8a76ef9..HEAD` lists no file under `artifacts/baselines/`, `artifacts/qa/`, `artifacts/evidence/` or `artifacts/coverage/`. Every cycle artifact is under `<FEATURE>/evidence/<kind>/` (`other`, `qa-gates`, `regression-testing`, `remediation-baseline`). Result: PASS.

## Documentation Surface Check

`docs/documentation-estate/docs-profile.json` is absent on the branch head (`git ls-files docs` lists only `docs/README.md`). The check is not applicable and produces no finding.

## Vendored Coverage Exemptions

No `vendored-coverage-exemptions.json` exists beside a coverage output, no `.push-down-manifest.json` changed, and the cycle changes no coverage configuration (`jest.config.cjs` and `jest.development-docs-migration-coverage.json` are unchanged since the prior review). Result: PASS.

---

## 1. General Unit Test Policy Compliance

### 1.1 Core Principles

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Independence** - Tests run in any order | ✅ PASS | The new Jest cases build their own in-memory fixtures; the Pester mock is declared inside one `It`; all suites pass in parallel full runs (Jest workers, pytest `-n auto`, Pester 8 workers). |
| **Isolation** - Each test targets single behavior | ✅ PASS | One behavior per new case: the predicate rows, the discovery argument, the negative paths, the post-move classification, the second links-only apply, the no-open-choice refusal text, the default-root read. |
| **Fast Execution** - Tests complete quickly | ✅ PASS | The edited Pester case runs in 0.114 s; the development-docs-migration selection runs in under one second. |
| **Determinism** - Consistent results | ✅ PASS | The F3 fix removes the dependence on an untracked directory on disk; no clock or random use in the new cases. |
| **Readability & Maintainability** - Clear structure | ✅ PASS | Arrange-Act-Assert comments and behavior names. |

### 1.2 Coverage and Scenarios

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Baseline Coverage Documented** | ✅ PASS | **Baseline:** TypeScript 97.59% lines, 94.95% branches; Python 96.66% lines, 92.53% branches; PowerShell 96.84% lines<br>**Command:** file reads of the stage B final QA artifacts<br>**Artifact:** `evidence/remediation-baseline/baseline-citation.2026-11-20T19-13.md`<br>**Timestamp:** 2026-11-20 19:13 UTC |
| **No Coverage Regression** | ✅ PASS | **Post-change coverage:** TypeScript 97.59%/94.96%; Python 96.66%/92.53%; PowerShell 96.84%<br>**Change:** +0.00 TypeScript lines, +0.01 branches; Python and PowerShell unchanged<br>**Status:** No regression; no per-file drop on 46 changed production files (`coverage-delta.2026-11-20T20-19.md`). Root launcher lines 98.44% equal the like-for-like [P1-T8] launcher run; the 0.08-point gap to the prior reviewer's direct run is the integration lane, which the launcher excludes (`root-jest-baseline-deviation.2026-11-20T20-14.md`). |
| **Changed Files Meet Thresholds** | ✅ PASS | **Thresholds:** 85% lines, 75% branches (defaults; the root `CLAUDE.md` states none)<br>**Status:** `layout-map.ts` 100% lines and branches; `migration-plan.ts` 100% lines, 98.64% branches; every other changed production file unchanged from the prior review, lowest `mcp-server.ts` 88.37% lines, 82.35% branches. |
| **New Code Coverage ≥90%** | ✅ PASS | **New/modified files:** cycle edits in `layout-map.ts` (25 added lines) and `migration-plan.ts` (3 added lines)<br>**New code coverage:** 28 of 28 added lines and 11 of 11 branches covered<br>**Calculation method:** changed-line mapping of the final lcov onto the cycle diff (`ts-test-coverage.2026-11-20T20-13.md`) |
| **Comprehensive Coverage** | ✅ PASS | `isMappedTargetPath` row-table, discovery-argument and negative cases; post-move dry-run and second-apply cases. |
| **Positive Flows** - Valid inputs | ✅ PASS | Every directory target and the backlog file report true. |
| **Negative Flows** - Invalid inputs | ✅ PASS | `.dev/other/x.md`, `docs/README.md`, `README.md`, `.dev/activex/a.md` report false. |
| **Edge Cases** - Boundary conditions | ✅ PASS | Directory target without trailing slash; prefix-only string match (`.dev/activex`); second links-only apply on a moved record that keeps an old prefix (closes the prior gap). |
| **Error Handling** - Error paths | ✅ PASS | Refusal text with no open choice is pinned by the new `migration-plan.test.ts` case. |
| **Concurrency** - If applicable | N/A | The tool is synchronous. |
| **State Transitions** - If applicable | ✅ PASS | Pre-move to migrated-tree transition under `links-only` is now tested (prior PARTIAL closed). |

### 1.2.1 Per-Language Coverage Comparison

- TypeScript: Baseline: 97.59% lines (94.95% branches) -> Post-change: 97.59% lines (94.96% branches). Change: +0.00% lines, +0.01% branches. New/changed-code coverage: 100% lines on the cycle's added lines. Disposition: PASS. Evidence: `coverage/lcov.info`, `evidence/qa-gates/ts-test-coverage.2026-11-20T20-13.md`, `evidence/qa-gates/coverage-delta.2026-11-20T20-19.md`.
- Python: Baseline: 96.66% lines (92.53% branches) -> Post-change: 96.66% lines (92.53% branches). Change: +0.00% lines, +0.00% branches. New/changed-code coverage: 100%. Disposition: PASS. Evidence: `artifacts/python/lcov.info`, `evidence/qa-gates/py-test-coverage.2026-11-20T20-12.md`.
- PowerShell: Baseline: 96.84% lines -> Post-change: 96.84% lines. Change: +0.00% lines. New/changed-code coverage: 100%. Disposition: PASS. Evidence: `artifacts/pester/powershell-coverage.xml`, `evidence/qa-gates/ps-test-coverage.2026-11-20T20-18.md`.
- Bash: Baseline: 89.8% lines -> Post-change: 89.8% lines. Change: +0.0% lines. New/changed-code coverage: 100%. Disposition: PASS. Evidence: `evidence/qa-gates/review-coverage-check.2026-11-20T18-28.md` (kcov of `report-lane-assertion.sh`; no bash file changed in the cycle).

### 1.3 Test Structure and Diagnostics

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Clear Failure Messages** | ✅ PASS | Exact-value `toEqual` and `toBe` assertions; Pester `Should -Invoke -Times 1 -Exactly` with a root-leaf filter. |
| **Arrange-Act-Assert Pattern** | ✅ PASS | Explicit AAA comments in the new cases. |
| **Document Intent** | ✅ PASS | Each new case and the predicate doc comment cite finding F1 or F3. |

### 1.4 External Dependencies and Environment

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Avoid External Dependencies** | ✅ PASS | In-memory fakes; the F3 fix replaces a real-tree read with a Pester mock. No temporary file. |
| **Use Mocks/Stubs** | ✅ PASS | `Mock Read-StageTimingEvidence { @() }` scoped to the case; the planner and rewrite logic run for real in Jest. |
| **Environment Stability** | ✅ PASS | The cycle emulated a clean checkout (`clean-layout.2026-11-20T19-14.md`) before every gate; the four moved-root directories are absent on disk at review time (reviewer `test -e` check). |

### 1.5 Policy Audit Requirement

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Pre-submission Review** | ✅ PASS | This audit, with the code review and feature audit of the same timestamp; the executor's self-review `self-review.2026-11-20T20-19.md`. |

---

## 2. General Code Change Policy Compliance

### 2.1 Before Making Changes

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Clarify the objective** | ✅ PASS | `remediation-inputs.2026-11-20T18-20.md` F1 to F3. |
| **Read existing change plans** | ✅ PASS | `remediation-plan.2026-11-20T18-37.md`, all 20 tasks checked. |
| **Document the plan** | ✅ PASS | One task-check artifact per task under `evidence/other/`. |

### 2.2 Design Principles

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Simplicity first** | ✅ PASS | One pure predicate and one added condition. |
| **Reusability** | ✅ PASS | The predicate derives its targets from `LEGACY_LAYOUT_MAP` and `rowTarget` rather than a second list. |
| **Extensibility** | ✅ PASS | A new mapping row is covered without code change; the row-table test asserts this for every row. |
| **Separation of concerns** | ✅ PASS | Classification stays in the pure planner; no I/O added. |

### 2.3 Module & File Structure

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Cohesive modules** | ✅ PASS | The predicate sits with the mapping table in `layout-map.ts`. |
| **At or below the 800-line hard limit** | ✅ PASS | Cycle files: `migration-plan.ts` 589, `layout-map.ts` 181, `migration-plan.test.ts` 542, `migration-apply.test.ts` 268, `layout-map.test.ts` 185, `Get-StageTimingReport.Tests.ps1` 102 logical lines. Branch-wide largest remains 699 (`Get-EpicProgressReport.Tests.ps1`, unchanged in the cycle). `config/file-size-baseline.json` unchanged. |
| **Public vs internal** | ✅ PASS | One new export, documented. |
| **No circular dependencies** | ✅ PASS | `migration-plan.ts` imports the predicate from `layout-map.ts`, the existing direction. |

### 2.4 Naming, Docs, and Comments

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Descriptive names** | ✅ PASS | `isMappedTargetPath`. |
| **Docs/docstrings** | ✅ PASS | TSDoc with parameters and return. |
| **Comment why, not what** | ✅ PASS | The `scanRewrites` comment states the later-run reason. |

### 2.5 After Making Changes - Toolchain Execution

| Requirement | Status | Evidence |
|------------|--------|----------|
| **1. Formatting** | ✅ PASS | **Command:** Prettier check (extension and root), Black check, PoshQC formatter<br>**Result:** 0 files flagged (`ts-static`, `py-static`, `ps-static` 2026-11-20T20-08) |
| **2. Linting** | ✅ PASS | **Command:** ESLint, Ruff, PSScriptAnalyzer, `Invoke-PoshQCLeakScan`<br>**Result:** 0 findings each |
| **3. Type checking** | ✅ PASS | **Command:** `npm run typecheck` (extension and root), Pyright<br>**Result:** 0 errors; not applicable to PowerShell |
| **4. Testing** | ✅ PASS | **Command:** launcher `jest-extension`, `jest`, `pytest -n auto`, `pester`<br>**Result:** 6707, 6724, 17104 and 29157 passed, 0 failed |
| **Full toolchain loop** | ✅ PASS | Stages 1 to 6 clean in final-loop pass 2 at head `520617870`, after one restart for a branch-coverage variance fixed in commit `520617870`; stage 7 runs in CI and is pending. |
| **Explicit reporting** | ✅ PASS | `phase-gate.P1.2026-11-20T19-55.md`, the 2026-11-20T20-08 to 20-19 gate artifacts, `coverage-delta.2026-11-20T20-19.md`. |

### 2.6 Summarize and Document

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Summarize changes** | ✅ PASS | One commit per task with the task id in the subject. |
| **Design choices explained** | ✅ PASS | The post-apply check `post-apply-dry-run-check.2026-11-20T19-24.md` now states the in-tree classification that the code performs; the prior D-P4T3-1 mismatch is superseded by an append-only successor record. |
| **Update supporting documents** | ✅ PASS | `spec.md` A14 sentence; `user-story.md` supersession note and restated criterion. |
| **Provide next steps** | ✅ PASS | CI at S9 for the four pending-CI criteria. |

---

## 3. Language-Specific Code Change Policy Compliance

### Section 3A: Python Code Change Policy Compliance

#### 3A.1 Tooling & Baseline

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Formatting with Black** | ✅ PASS | **Command:** `poetry run black --check .`<br>**Result:** 1071 files unchanged (`py-static.2026-11-20T20-08.md`) |
| **Linting with Ruff** | ✅ PASS | **Command:** `poetry run ruff check .`<br>**Result:** All checks passed |
| **Type checking with Pyright** | ✅ PASS | **Command:** `poetry run pyright`<br>**Result:** 0 errors |
| **Testing with Pytest** | ✅ PASS | **Command:** launcher `pytest -n auto --cov=scripts --cov-branch`<br>**Result:** 17104 passed, 6 skipped |

#### 3A.2 Python Design & Typing

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Strong typing** | ✅ PASS | No Python change in the cycle; branch-level result of the prior review stands. |
| **Dataclasses for value objects** | N/A | No new value object. |
| **Protocols/ABCs for interfaces** | N/A | No new interface. |
| **Avoid utility classes** | ✅ PASS | Module-level functions. |

#### 3A.3 Python Error Handling

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Specific exceptions** | ✅ PASS | No new exception path. |
| **Logging over print** | ✅ PASS | No print added. |
| **Invariants at construction** | N/A | No new class. |

No new Python file is added on the branch (name-status diff against the merge base; the cycle diff contains no `.py` path).

### Section 3B: PowerShell Code Change Policy Compliance

#### 3B.1 Tooling & Baseline

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Formatting with Invoke-Formatter** | ✅ PASS | **Command:** PoshQC formatter, non-writing seam<br>**Result:** 1866 files, 0 drift (`ps-static.2026-11-20T20-08.md`) |
| **Linting with PSScriptAnalyzer** | ✅ PASS | **Command:** per-file `Invoke-ScriptAnalyzer` with `pssa.settings.psd1`<br>**Result:** 0 findings |
| **Fix all findings** | ✅ PASS | None open. |
| **PowerShell 5.1 & 7.6+ compatible** | ✅ PASS | The cycle adds two lines to a test file (`Mock` and `Should -Invoke`), compatible with both. |

#### 3B.2 PowerShell Design & Safety

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Advanced functions** | ✅ PASS | No production PowerShell change in the cycle. |
| **Parameter validation** | ✅ PASS | Unchanged. |
| **Avoid global state** | ✅ PASS | The mock is case-scoped. |
| **Error handling** | ✅ PASS | `scripts/dev-tools/Get-StageTimingReport.ps1` and `StageTiming.psm1` are unchanged; the missing-root throw still applies to explicit roots (`STR-ENTRY-THROWS-ON-MISSING-ROOT`). |

#### 3B.3 Structure, Naming, and Comments

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Cohesive and at or below the 800-line hard limit** | ✅ PASS | `Get-StageTimingReport.Tests.ps1` 102 lines. |
| **Approved verbs** | ✅ PASS | No new function. |
| **Comment why** | ✅ PASS | The added comment states the clean-checkout reason. |

#### 3B.4 Running the Toolchain

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Step 1: Format** | ✅ PASS | 0 drift. |
| **Step 2: Analyze** | ✅ PASS | 0 findings; leak scan 0. |
| **Step 3: Type check** | N/A | Not applicable for PowerShell. |
| **Step 4: Test** | ✅ PASS | 29157 tests, 0 failures, on the clean layout. |
| **Rerun loop if needed** | ✅ PASS | Final loop pass 2 clean. |

### Section 3C: Bash Script Policy Compliance

#### 3C.1 Tooling & Baseline

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Formatting with shfmt** | ✅ PASS | **Command:** not rerun<br>**Result:** no bash file changed in the cycle; the branch change is heredoc text |
| **Linting with shellcheck** | ✅ PASS | **Command:** not rerun<br>**Result:** same reason |
| **Testing with bats** | ✅ PASS | **Command:** `bats --jobs 4 tests/shell/report_lane_assertion_dispatch.bats` (prior reviewer run, WSL Ubuntu)<br>**Result:** 14 of 14 passed; the cycle's static sweep searched all 55 bats files and found no moved-root token |

#### 3C.2 Bash Script Design

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Portable shebang** | ✅ PASS | Unchanged. |
| **Error handling** | ✅ PASS | Unchanged. |
| **At or below the 800-line hard limit** | ✅ PASS | Well below 700 lines. |

The cycle self-review corrects the earlier statement that no `.sh` or `.bats` file changed and cites the reviewer's bats and kcov figures. The prior non-blocking note is closed.

### Section 3D: JSON Configuration Policy Compliance

#### 3D.1 JSON Tooling

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Formatting with jq** | ✅ PASS | **Command:** no hand-edited JSON in the cycle<br>**Result:** the only added JSON is the tool-written dry-run report |
| **Schema validation** | ✅ PASS | **Command:** routing parity and blast-radius tests in the gate runs<br>**Result:** pass |
| **Required $schema** | ✅ PASS | Routing copies unchanged in the cycle. |

#### 3D.2 JSON Structure

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Strict JSON only** | ✅ PASS | The report parses (`node` `require`, reviewer probe). |
| **Deterministic key order** | ✅ PASS | Tool-written in report order. |

---

## 4. Language-Specific Unit Test Policy Compliance

### Section 4A: Python Unit Test Policy Compliance

#### 4A.1 Framework and Scope

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Use Pytest** | ✅ PASS | pytest with xdist. |
| **Coverage expectation** | ✅ PASS | Local repo-wide 96.66% lines, 92.53% branches; CI result recorded in `## CI Cross-check`. |

#### 4A.2 Test Style and Structure

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Focused unit tests** | ✅ PASS | No Python test change in the cycle. |
| **Mocking sparingly** | ✅ PASS | Unchanged. |
| **Organization** | ✅ PASS | Mirrors `scripts/dev_tools/`. |

#### 4A.3 Naming and Readability

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Naming conventions** | ✅ PASS | Unchanged. |
| **Docstrings/comments** | ✅ PASS | Unchanged. |

#### 4A.4 Running the Toolchain

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Use Pytest** | ✅ PASS | **Command:** launcher `pytest -n auto`<br>**Result:** 17104 passed |
| **No Alternative Test Runners** | ✅ PASS | pytest only. |

### Section 4B: PowerShell Unit Test Policy Compliance

#### 4B.1 Framework and Scope

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Use Pester v6.x** | ✅ PASS | Pester 6 through PoshQC. |
| **Use PoshQC Configuration** | ✅ PASS | **Command:** `Invoke-PoshQCParallelTest`<br>**Config:** unchanged. |
| **PowerShell 5.1 & 7.6+ Compatible** | ✅ PASS | Two added lines use standard Pester syntax. |

#### 4B.2 Test Style and Structure

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Focused Unit Tests** | ✅ PASS | The case keeps its label assertions and adds one invocation assertion. |
| **Test Behavior Over Implementation** | ✅ PASS | The assertion checks that the default run reads the resolver-supplied root, which is the behavior A23 requires. |
| **Mocking Used Sparingly** | ✅ PASS | One mock replaces the disk read only. |
| **Organization** | ✅ PASS | **Test file:** `tests/scripts/dev-tools/Get-StageTimingReport.Tests.ps1`<br>**Code file:** `scripts/dev-tools/Get-StageTimingReport.ps1` |

#### 4B.3 Naming and Readability

| Requirement | Status | Evidence |
|------------|--------|----------|
| **File Naming** - *.Tests.ps1 | ✅ PASS | Correct suffix. |
| **Describe/Context/It Structure** | ✅ PASS | Unchanged structure. |
| **Logical Grouping** | ✅ PASS | Unchanged. |
| **Docstrings/Comments** | ✅ PASS | F3 comment added. |

#### 4B.4 Running the Toolchain

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Use PoshQCTest Command** | ✅ PASS | **Command:** `Invoke-PoshQCParallelTest`<br>**Result:** 29157 tests, 0 failures |
| **No Alternative Test Runners** | ✅ PASS | Pester through PoshQC only. |

---

## 5. Test Coverage Detail

### Remediation cycle 1 cases

| Test Name | Scenario Type | Lines Covered | Status |
|-----------|--------------|---------------|--------|
| `layout-map.test.ts` `isMappedTargetPath` row cases (13) and every-row case | Positive | `isMappedTargetPath` directory and file branches | ✅ |
| `layout-map.test.ts` discovery-argument and negative cases | Negative, Edge Case | discovery branch, prefix-only miss | ✅ |
| `migration-plan.test.ts` "classifies a record at a mapped target as in-tree on a post-move dry run" | State Transition | changed `scanRewrites` condition | ✅ (failed before the fix) |
| `migration-apply.test.ts` "yields an empty plan on a second links-only apply when a moved record keeps an old prefix" | Edge Case | `applyMigrationPlan` second run | ✅ (failed before the fix) |
| `migration-plan.test.ts` "names no open choice when only held items require the decision file" | Error Handling | refusal text branch | ✅ |
| `Get-StageTimingReport.Tests.ps1` `STR-ENTRY-PRINTS-LABELS-AND-FIXTURE-MEDIANS` | Positive | default-root path of the entry | ✅ (failed before the fix on the clean layout) |

**Coverage:** `layout-map.ts` 100% lines and branches; `migration-plan.ts` 100% lines, 98.64% branches.

**Not covered:** two branches in `migration-plan.ts` (pre-existing, unchanged by the cycle).

---

## 6. Test Execution Metrics

| Metric | Value | Status |
|--------|-------|--------|
| Total Tests | 6707 Jest extension, 6724 Jest root, 17104 pytest, 29157 Pester | ✅ |
| Tests Passed | all | ✅ |
| Tests Failed | 0 | ✅ |
| Execution Time | pytest 145 s, Pester 691 s | ✅ Fast |
| Average Time per Test | under 30 ms | ✅ Fast |
| Discovery Time | included above | ✅ |
| Functions/Classes Tested | `isMappedTargetPath` and the changed `scanRewrites` branch | ✅ |
| Test File Size | largest cycle test file 542 logical lines | ✅ PASS |
| Code Coverage (if applicable) | TypeScript root 98.44% lines, 94.64% branches | ✅ |

---

## 7. Code Quality Checks

**For TypeScript:**

| Check | Command | Result | Status |
|-------|---------|--------|--------|
| Prettier | `npx prettier --check`; root `npm run format:check` | 0 files flagged | ✅ |
| ESLint | `npm run lint` (extension and root) | 0 findings | ✅ |
| TSC | `npm run typecheck` (extension and root) | 0 errors | ✅ |
| Jest | launcher `jest-extension` and `jest` with coverage | 6707 and 6724 passed | ✅ |

**For Python:**

| Check | Command | Result | Status |
|-------|---------|--------|--------|
| Black Formatting | `poetry run black --check .` | unchanged | ✅ |
| Ruff Linting | `poetry run ruff check .` | passed | ✅ |
| Pyright Type Checking | `poetry run pyright` | 0 errors | ✅ |
| Pytest Tests | launcher `pytest -n auto` | 17104 passed | ✅ |

**For PowerShell:**

| Check | Command | Result | Status |
|-------|---------|--------|--------|
| Invoke-Formatter | PoshQC formatter | 0 drift | ✅ |
| PSScriptAnalyzer | per-file analyzer | 0 findings | ✅ |
| Pester Tests | `Invoke-PoshQCParallelTest` | 29157 passed | ✅ |

**Notes:** stage 6 generator checks (`Invoke-HarnessGeneration.ps1 -Check`, Codex variant `--check`, discovery runtime `--check`) exited 0 in the [P1-T8] gate; the cycle after that gate changes one test file and evidence only.

---

## CI Cross-check

CI run 44810698464 (workflow_dispatch, head `7322bc6251aca5e9d2beb11e528f847da44b6764`) was in progress at review time; the caller asked the review not to wait. Rows marked from CI show the completed job conclusions read with `gh run view`; the other rows give the local claimed outcome for the orchestrator to compare at S9.

| Check | Claimed outcome | Claimed figure | Head | Source |
|-------|-----------------|----------------|------|--------|
| root-typescript-tests (ubuntu-latest, windows-latest) | pass | completed success in CI; local 6724 tests, 98.44% lines | 7322bc625 | CI run 44810698464; `root-jest-coverage.2026-11-20T20-14.md` |
| drm-copilot-extension-tests (ubuntu-latest, windows-latest) | pass | completed success in CI; local 6707 tests, 97.59% lines, 94.96% branches | 7322bc625 | CI run 44810698464; `ts-test-coverage.2026-11-20T20-13.md` |
| quality-checks7 / Python 3.13 static | pass | completed success in CI | 7322bc625 | CI run 44810698464 |
| quality-checks7 / Code Quality & Tests and coverage shards | pass | in progress in CI; local 17104 tests, 96.66% lines, 92.53% branches | 7322bc625 | `py-test-coverage.2026-11-20T20-12.md` |
| Enforce Python coverage thresholds | pass | in progress in CI; local 96.66% lines, 92.53% branches | 7322bc625 | `artifacts/python/lcov.info` |
| poshqc / PowerShell QC static and shards 1 to 6 | pass | in progress in CI; local 0 findings, 29157 tests, 96.84% lines, F3 case Passed on the clean layout | 7322bc625 | `ps-static.2026-11-20T20-08.md`, `ps-test-coverage.2026-11-20T20-18.md` |
| shell-coverage / Shell Coverage (Bats + kcov) | pass | in progress in CI; 14 tests, 89.8% lines for the changed file (prior reviewer run) | 7322bc625 | `review-coverage-check.2026-11-20T18-28.md` |
| docs-validation, build-check, security-scan, NPM Audit Gate | pass | completed success in CI | 7322bc625 | CI run 44810698464 |
| CI Required Gate (stage 7 integration) | pass | pending CI at S9 | 7322bc625 | CI at S9 |

---

## 8. Gaps and Exceptions

### Identified Gaps

- No blocking gap remains. F1, F2 and F3 of `remediation-inputs.2026-11-20T18-20.md` are closed with fail-before and pass-after evidence (see the feature audit).
- Pending CI (not findings): spec stage A toolchain criterion, spec stage B toolchain criterion, spec epic criterion "With `development_docs_root` set to `.dev`, the full toolchain passes", and user-story (d) toolchain criterion. Stages 1 to 6 pass locally; stage 7 runs in CI. The item's orchestrator checks them off at S9 under `### CI-Dependent Criteria`.
- Non-blocking: the root Jest line total of the launcher run (98.44%) is 0.08 points below the prior reviewer's direct run (98.52%) because the launcher excludes the integration lane; the like-for-like launcher comparison shows no drop. The executor recorded this as an accepted non-blocking deviation, and the review agrees.

### Approved Exceptions

**None.** No exceptions needed.

### Removed/Skipped Tests

**None.** No test was removed or skipped in the cycle.

---

## 9. Summary of Changes

The branch adds the TypeScript `migrate_development_docs` MCP tool and CLI subcommand and uses it to move this repository's development records from `docs/` to `.dev/`. Remediation cycle 1 adds `isMappedTargetPath` so that records at a mapping-table target stay under the chosen in-tree rewrite scope on later runs, regenerates the post-apply dry run, records the A14 supersession of user-story criterion (c) 1, and removes the stage-timing entry test's dependence on a `docs/features` directory on disk.

---

## 10. Compliance Verdict

### Overall Status: ✅ COMPLIANT

All evaluated policies are met at the reviewed head. Four CI-dependent criteria are pending CI and are not findings.

### Policy-by-Policy Summary

#### General Code Change Policy (Section 2)
- ✅ Before Making Changes: remediation plan read
- ✅ Design Principles: one pure predicate derived from the mapping table
- ✅ Module & File Structure: no file at or above 700 lines
- ✅ Naming, Docs, Comments: compliant
- ✅ Toolchain Execution: stages 1 to 6 clean; stage 7 pending CI
- ✅ Summarize & Document: post-apply record matches the code

#### Language-Specific Code Change Policy (Section 3)

**For Python:**
- ✅ Tooling & Baseline: clean
- ✅ Python Design & Typing: compliant
- ✅ Error Handling: compliant

**For PowerShell:**
- ✅ Tooling & Baseline: clean
- ✅ PowerShell Design & Safety: compliant
- ✅ Structure & Naming: compliant
- ✅ Toolchain: clean

#### General Unit Test Policy (Section 1)
- ✅ Core Principles: compliant
- ✅ Coverage & Scenarios: thresholds met; migrated-tree `links-only` scenario now tested
- ✅ Test Structure: compliant
- ✅ External Dependencies: in-memory fakes and one scoped mock
- ✅ Policy Audit: this document

#### Language-Specific Unit Test Policy (Section 4)

**For Python:**
- ✅ Framework & Scope: pytest
- ✅ Test Style & Structure: compliant
- ✅ Naming & Readability: compliant
- ✅ Toolchain: clean

**For PowerShell:**
- ✅ Framework & Scope: Pester 6
- ✅ Test Style & Structure: compliant
- ✅ Naming & Readability: compliant
- ✅ Toolchain: clean

### Metrics Summary

- ✅ 6707 Jest extension, 6724 Jest root, 17104 pytest and 29157 Pester tests passing
- ✅ TypeScript 97.59% lines (extension), 98.44% (root); Python 96.66%; PowerShell 96.84%
- ✅ No changed covered file at or above 700 lines
- ✅ Static stages clean in each language

### Recommendation

**Ready for the PR gate**

No blocking finding remains. The orchestrator checks off the four CI-dependent criteria at S9 after CI run 44810698464 or its successor concludes `success` on the final head.

---

## Appendix A: Test Inventory

### Complete Test List

- `extensions/drm-copilot/test/lib/development-docs-migration/layout-map.test.ts` (cycle: `isMappedTargetPath (finding F1)` block)
- `extensions/drm-copilot/test/lib/development-docs-migration/migration-plan.test.ts` (cycle: post-move dry-run case, no-open-choice refusal case)
- `extensions/drm-copilot/test/lib/development-docs-migration/migration-apply.test.ts` (cycle: second links-only apply case)
- `tests/scripts/dev-tools/Get-StageTimingReport.Tests.ps1` (cycle: `STR-ENTRY-PRINTS-LABELS-AND-FIXTURE-MEDIANS`)
- branch-level suites listed in `policy-audit.2026-11-20T18-20.md` Appendix A, unchanged by the cycle

---

## Appendix B: Toolchain Commands Reference

**For TypeScript:**
```bash
sh .claude/skills/test-execution-policy/scripts/run-test-suite.sh jest-extension --coverage
sh .claude/skills/test-execution-policy/scripts/run-test-suite.sh jest --coverage
npm --prefix extensions/drm-copilot run lint
npm --prefix extensions/drm-copilot run typecheck
```

**For Python:**
```bash
poetry run black --check .
poetry run ruff check .
poetry run pyright
sh .claude/skills/test-execution-policy/scripts/run-test-suite.sh pytest -n auto --cov=scripts --cov-branch
```

**For PowerShell:**
```powershell
Import-Module ./scripts/powershell/PoshQC; Invoke-PoshQCFormat -Root .
Import-Module ./scripts/powershell/PoshQC; Invoke-PoshQCAnalyze -Root .
sh .claude/skills/test-execution-policy/scripts/run-test-suite.sh pester
```

---

**Audit Completed By:** feature-review agent  
**Audit Date:** 2026-11-20  
**Policy Version:** Current (as of audit date)
