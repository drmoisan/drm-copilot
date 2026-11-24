# Policy Compliance Audit: documentation-workflow epic-scale routing (#1223)

**Audit Date:** 2026-11-24
**Code Under Test:** merge base `5267cb8294cb933c28ace89647d8283b3ba81404` of `origin/epic/documentation-estate-families-integration` and reviewed head `95a4563de1d33e524a57cc836f8e34ff1b11667e`; the diff between them lists the changed files (11 files outside the feature folder).

**Coverage Metrics by Language:**

| Language | Files Changed | Tests | Test Result | Baseline Coverage | Post-Change Coverage | New Code Coverage |
|----------|--------------|-------|-------------|-------------------|---------------------|-------------------|
| PowerShell | 1 (test file only; no production `.ps1`) | 34 expanded rows (new suite) | PASS: 29966 testcase elements, 0 failures | 96.88% lines (29932 testcases at Phase 0; same production code, see 1.2.1) | 96.88% lines (29966 testcases, +34) | N/A - no production file changed |
| Markdown | 8 skill, standard, and brief files | N/A | PASS: generator and contract checks | N/A (config files) | N/A (config files) | N/A |

### Coverage Evidence Checklist

- TypeScript baseline coverage artifact: N/A - out of scope (zero changed TypeScript files)
- TypeScript post-change coverage artifact: N/A - out of scope (zero changed TypeScript files)
- PowerShell baseline coverage artifact: `.dev/active/1223-docs-epic-scale-routing/evidence/baseline/pester-gate.2026-11-24T12-21.md` (records test counts only; it records no coverage percentage because no production `.ps1` file changed)
- PowerShell post-change coverage artifact: `artifacts/pester/powershell-coverage.xml` (report LINE counter: 47905 covered, 1541 missed, 96.88% lines; INSTRUCTION 84121 covered, 3800 missed) and `.dev/active/1223-docs-epic-scale-routing/evidence/qa-gates/final-qc-pester.2026-11-24T14-33.md`
- Per-language comparison summary: section 1.2.1.

---

## Executive Summary

The branch adds a level-two section `## Epic-Scale Routing` to the `documentation-workflow` skill, qualifies four existing statements, adds behavior `OB-6` and checks `AC-7` and an extended `AC-6` to the standard, lists one new suite in the four execution-environment brief copies, and adds one Pester contract suite. No library, MCP, hook, or Python file changed. The full-branch diff was audited; no caller narrowing was applied.

**Policy documents evaluated:**
- PASS `general-code-change.md`
- PASS `general-unit-test.md`
- PASS `tonality.md`
- PASS `quality-tiers.md` (tier adoption: `quality-tiers.yml` exists at the repository root; the branch adds no project path, so no classification entry is required)

**Language-specific policies evaluated:**
- PASS PowerShell (`powershell.md`): one test file
- N/A Python, TypeScript, C#, Bash: zero changed files

The final-QC static artifact for PowerShell records format, analyzer, and Pester results (format and analyze findings 0, no rewrite). The owner test-scope instruction dated 2026-11-23 (full suites at Phase 0 and final QA only; phase gates targeted with a recorded waiver) is recorded in `phase-gate.P1` and `phase-gate.P2` and is accepted as a waiver, not a finding.

**Temporary artifacts cleanup:**
- PASS: the branch diff adds no scratch script; scratch launchers are referenced from `SCRATCH` and are not in the diff.

## Rejected Scope Narrowing

None. The caller prompt asked for the branch diff from the merge base with the base branch, which is the authoritative scope. The caller statement that the 2026-11-23 owner test-scope instruction is an accepted waiver is not a scope narrowing of the audit; it governs the phase-gate test cadence and is applied as stated.

## Evidence Location Compliance

PASS. The diff lists no path under `artifacts/baselines/`, `artifacts/qa/`, `artifacts/evidence/`, or `artifacts/coverage/` (`git diff --name-only` over `artifacts` returns nothing). All evidence lies under `.dev/active/1223-docs-epic-scale-routing/evidence/<kind>/`. No `EVIDENCE_LOCATION_OVERRIDE_REJECTED` occurred.

Vendored push-down exemptions: no `vendored-coverage-exemptions.json` exists, no `exclude`, `omit`, `coveragePathIgnorePatterns`, or kcov `--exclude-path` entry changed, and `.push-down-manifest.json` is not in the diff. PASS.

Documentation Surface Check: `docs/documentation-estate/docs-profile.json` is absent on the branch head, so the check is not applicable and produces no finding.

---

## 1. General Unit Test Policy Compliance

### 1.1 Core Principles

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Independence** | PASS | Each `It` reads committed files through pure helpers and shares no state; rows are data-driven with `-ForEach`. |
| **Isolation** | PASS | One behavior per `It` (placement, routing, waves, ownership, dispatch, receipt, qualifications, standard, brief). |
| **Fast Execution** | PASS | Reads text only; 34 rows; part of the 798 s full parallel gate. |
| **Determinism** | PASS | No clock, no process, no network, no temp file (suite header and body inspected). |
| **Readability & Maintainability** | PASS | Names state the behavior and the copy path; `-Because` messages name the missing token. |

### 1.2 Coverage and Scenarios

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Baseline Coverage Documented** | PASS | `evidence/baseline/pester-gate.2026-11-24T12-21.md` and `pytest-gate.2026-11-24T12-45.md`. |
| **No Coverage Regression** | PASS | Testcase count 29932 to 29966 (+34, equal to the new suite rows); skipped 18 to 18; no failure. Pytest 17104 to 17104. |
| **Changed Files Meet Thresholds** | PASS | No production file changed. Repo-wide PowerShell lines 96.88% (artifact LINE counter) against the 85% line threshold. |
| **New Code Coverage** | N/A | The only added code is a test file; no production file added or modified. |
| **Comprehensive Coverage** | PASS | Every AC pinned by the contract suite is tested in every copy (see section 5). |
| **Positive Flows** | PASS | Token presence rows for routing, dispatch, receipt, qualification, standard, and brief. |
| **Negative Flows** | PASS | Absence of the six family-record field names; the foundation wave owns no family id; each id appears once. |
| **Edge Cases** | PASS | Wave marker order, id per own segment, heading count equals 1, heading order. |
| **Error Handling** | PASS | Helpers return `$null` for a missing section and each row asserts non-null with a reason. |
| **Concurrency / State Transitions** | N/A | Read-only text checks. |

### 1.2.1 Per-Language Coverage Comparison

- PowerShell: Baseline: 96.88% lines (47905 of 49446 lines). The Phase 0 baseline artifact records 29932 testcase elements and no percentage; the figure shown is the only measurement available, and it applies to the pre-change tree because the branch changes no production `.ps1` file and the new suite executes no production code. -> Post-change: 96.88% lines (same artifact; 29966 testcase elements). Change: +0.00% lines (0 production lines changed; testcase count +34). New/changed-code coverage: N/A - test file only. Disposition: PASS. Evidence: `final-qc-pester.2026-11-24T14-33.md`, `pester-gate.2026-11-24T12-21.md`, `artifacts/pester/powershell-coverage.xml`. The artifact is a local file whose modification time precedes the final QC run, so the baseline equality is by construction and not from a second measured run. This is a non-blocking evidence note.
- Python: N/A - out of scope (zero changed Python files). Pytest full-suite pass count 17104 before and after, recorded in `final-qc-pytest.2026-11-24T14-45.md`.
- Markdown / skill text: N/A for line coverage; generator `-Check` and the harness skill contract cover it.

### 1.3 Test Structure and Diagnostics

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Clear Failure Messages** | PASS | `-Because` strings name the token, id, or copy. |
| **Arrange-Act-Assert Pattern** | PASS | `# Arrange`, `# Act`, `# Assert` comments in the rows. |
| **Document Intent** | PASS | Synopsis and description block; descriptive `It` names. |

### 1.4 External Dependencies and Environment

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Avoid External Dependencies** | PASS | Reads committed repository files only. |
| **Use Mocks/Stubs** | N/A | No mocking needed. |
| **Environment Stability** | PASS | Root resolved from `$PSScriptRoot`; `Join-Path` and forward-slash relative paths; CR count 0 in the file; no temp file. |

### 1.5 Policy Audit Requirement

PASS. This audit and the author self-review `evidence/qa-gates/self-review.2026-11-24T14-58.md` serve as the review record.

---

## 2. General Code Change Policy Compliance

### 2.1 Before Making Changes

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Clarify the objective** | PASS | Issue #1223 and `spec.md` Overview. |
| **Read existing change plans** | PASS | `plan.2026-11-23T00-39.md` and `evidence/other/preflight-clearance.2026-11-23T07-00.md`. |
| **Document the plan** | PASS | Plan with Phase 0 baselines, fail-before evidence, and phase gates. |

### 2.2 Design Principles

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Simplicity first** | PASS | Text-only change plus one read-only suite following `documentation-workflow.CommitStage.Tests.ps1`. |
| **Reusability** | PASS | Four helper functions shared across all rows; the threshold is one script variable. |
| **Extensibility** | PASS | Copy lists are data rows. |
| **Separation of concerns** | PASS | Skill text cites docs-family-profile-model and docs-family-gate-and-ia and does not restate them. |

### 2.3 Module & File Structure

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Cohesive modules** | PASS | One suite per feature. |
| **At or below the 800-line hard limit** | PASS | Logical line counts: test file 207; `.agents/skills/documentation-workflow/SKILL.md` 122; standard and brief files are far below 700 (brief copies not in the 700-line tier by inspection of the +1 line diff). No Warning rows; no `config/file-size-baseline.json` change. |
| **Public vs internal** | PASS | Helpers are removed in `AfterAll`. |
| **No circular dependencies** | N/A | No code dependency graph. |

### 2.4 Naming, Docs, and Comments

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Descriptive names** | PASS | `Get-EpicRoutingSection`, `Get-EpicRoutingHeadingIndex`, `Get-EpicRoutingHeadingCount`, `Get-EpicRoutingText`; approved verb `Get`. |
| **Docs/docstrings** | PASS | Comment-based help header describes behavior and constraints. |
| **Comment why, not what** | PASS | Inline comments state purpose (pure over committed text). |

### 2.5 After Making Changes - Toolchain Execution

| Requirement | Status | Evidence |
|------------|--------|----------|
| **1. Formatting** | PASS | `final-qc-static-powershell.2026-11-24T14-17.md`: PoshQC format finding count 0, porcelain empty after the run. Read from the artifact; not re-run. |
| **2. Linting** | PASS | Same artifact: direct analyzer TOTAL_FINDINGS=0 over `scripts` and `tests/scripts`, equal to the Phase 0 baseline. |
| **3. Type checking** | N/A | No Python or TypeScript file changed; PowerShell has no type checker. |
| **4. Testing** | PASS | `final-qc-pester.2026-11-24T14-33.md` exit 0; `final-qc-pytest.2026-11-24T14-45.md` exit 0. |
| **Full toolchain loop** | PASS | Final QC ran all stages at the head; phase gates P1 and P2 ran targeted selections under the recorded owner waiver. |
| **Explicit reporting** | PASS | Evidence files carry Timestamp, Command, EXIT_CODE, and Output Summary. |

### 2.6 Summarize and Document

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Summarize changes** | PASS | `self-review.2026-11-24T14-58.md`. |
| **Design choices explained** | PASS | Decisions D1 to D4 in `spec.md`. |
| **Update supporting documents** | PASS | Brief copies list the new suite; AC checkboxes updated with `ac-checkoff.2026-11-24T14-55.md`. |
| **Provide next steps** | PASS | The spec records the open receipt-mechanics risk as owned by preflight and the epic final step. |

---

## 3. Language-Specific Code Change Policy Compliance

### Section 3B: PowerShell

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Formatting / Linting / Fix all findings** | PASS | Findings 0 (static artifact). |
| **PowerShell 7+ compatible** | PASS | `#Requires -Version 7.0`; Pester 5.0.0 minimum module in `#Requires`, repository runs Pester 6.x. |
| **Global state** | PASS | Only `$script:` rows and constants set in `BeforeDiscovery` and `BeforeAll`; helpers removed in `AfterAll`. |
| **Cohesive and below 800 lines** | PASS | 207 lines. |
| **Approved verbs** | PASS | `Get-` only. |
| **Test location** | PASS | `tests/scripts/claude-runtime/documentation-workflow.EpicRouting.Tests.ps1`, sibling of `documentation-workflow.CommitStage.Tests.ps1`. |

Sections 3A, 3C, 3D: N/A, zero changed files.

---

## 4. Language-Specific Unit Test Policy Compliance

### Section 4B: PowerShell

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Use Pester** | PASS | `Describe`/`It -ForEach`, modern `Should` syntax. |
| **Use PoshQC configuration** | PASS | Run through the launcher `run-test-suite.sh pester` (one `Invoke-PoshQCParallelTest` run, 8 workers). Parallel-only: no serial, shuffled, or reversed run recorded. |
| **Focused tests** | PASS | One behavior per `It`. |
| **Mocking** | PASS | None. |
| **File naming** | PASS | `*.Tests.ps1`. |
| **No alternative runners** | PASS | Launcher and PoshQC only. |

Policy note on Pester `Describe` blocks: two top-level `Describe` blocks, none nested.

---

## 5. Test Coverage Detail

### documentation-workflow.EpicRouting.Tests.ps1 (34 expanded rows)

| Test | Scenario Type | Rows | Status |
|------|--------------|------|--------|
| places the heading once, after `## Rules`, before the stage heading | Positive, edge | 4 copies | PASS |
| routing condition and threshold tokens | Positive | 4 | PASS |
| wave order and per-segment family ids; foundation owns no id | Positive, negative, edge | 4 | PASS |
| ownership and absence of six field names | Positive, negative | 4 | PASS |
| dispatch rule tokens | Positive | 4 | PASS |
| receipt rule tokens | Positive | 4 | PASS |
| qualifications | Positive | 4 | PASS |
| standard behavior and byte identity | Positive | 2 | PASS |
| brief listing | Positive | 4 | PASS |

Fail-before evidence: `evidence/regression-testing/epic-routing-fail-before.2026-11-24T13-04.md` (EXIT_CODE 1 against the unedited skill). Each row then passes in `phase-gate.P2.2026-11-24T14-03.md`.

---

## 6. Test Execution Metrics

| Metric | Value | Status |
|--------|-------|--------|
| Total Tests (full Pester gate) | 29966 testcase elements | PASS |
| Failed | 0 | PASS |
| Execution Time | 798.18 s wall-clock, 8 workers | PASS |
| New suite rows | 34 | PASS |
| Test File Size | 207 logical lines | PASS (below 500) |
| Pytest | 17104 passed, 0 failed, 6 skipped, 75.24 s | PASS |

---

## 7. Code Quality Checks

| Check | Command | Result | Status |
|-------|---------|--------|--------|
| Invoke-Formatter | PoshQC format (MCP) | 0 findings, no rewrite | PASS |
| PSScriptAnalyzer | PoshQC analyze and direct analyzer | 0 findings | PASS |
| Pester Tests | launcher `pester` | exit 0, 0 failures | PASS |
| Pytest | launcher `pytest` | exit 0 | PASS |
| Generator check | `Invoke-HarnessGeneration.ps1 -Surface skills -Check` | exit 0, no drift | PASS |

Notes: the analyzer prints one parser notice that is not a finding (recorded in the static artifact).

---

## CI Cross-check

CI status at the reviewed head is not available in the PR context (`CI status (HEAD): (not available)`; no PR exists). The rows record local evidence only.

| Check | Claimed outcome | Claimed figure | Head | Source |
|-------|-----------------|----------------|------|--------|
| PowerShell format | pass | 0 findings | 95a4563de | `evidence/qa-gates/final-qc-static-powershell.2026-11-24T14-17.md` |
| PowerShell analyze | pass | 0 findings | 95a4563de | `evidence/qa-gates/final-qc-static-powershell.2026-11-24T14-17.md` |
| Pester suite | pass | 0 failures, 29966 testcases | 95a4563de | `evidence/qa-gates/final-qc-pester.2026-11-24T14-33.md` |
| Pytest suite | pass | 17104 passed | 95a4563de | `evidence/qa-gates/final-qc-pytest.2026-11-24T14-45.md` |
| Harness generator skills check | pass | no drift | 95a4563de | `evidence/qa-gates/final-qc-parity.2026-11-24T14-50.md` |

---

## 8. Gaps and Exceptions

### Identified Gaps

None blocking. Non-blocking observations are in `code-review.2026-11-24T14-51.md`.

### Approved Exceptions

- Phase-gate test scope: owner instruction dated 2026-11-23 (full suites at Phase 0 and final QA only; phase gates targeted with a recorded waiver) is recorded in `phase-gate.P1.2026-11-24T13-16.md`, `phase-gate.P2.2026-11-24T14-03.md`, and `self-review.2026-11-24T14-58.md`. Accepted as a waiver, not a finding.

### Removed/Skipped Tests

None. All planned tests implemented.

---

## 9. Summary of Changes

Adds the `## Epic-Scale Routing` section, four qualifications, and standard behavior `OB-6` to the `documentation-workflow` skill in all copies, lists the new suite in the execution-environment brief copies, and adds a parallel Pester contract suite that pins them.

---

## 10. Compliance Verdict

### Overall Status: FULLY COMPLIANT

All applicable policies pass on the full branch diff. Tonality: the added skill text, standard text, and suite comments use neutral, literal wording with no humor, hyperbole, or metaphor.

### Policy-by-Policy Summary

- PASS General Code Change: design, file size, naming, toolchain evidence.
- PASS General Unit Test: independence, determinism, no temporary files, test location.
- PASS PowerShell code change and unit test policy.
- PASS Parity: the `.claude` copy equals generator output (the only differences from `.agents` are the pre-existing substitutions); the Claude bundle copy is byte-equal to `.claude`; the Codex bundle copies are byte-equal to `.agents` (SHA-256 pairs equal for `SKILL.md`, `references/standard.md`, and the execution-environment brief).
- PASS Scope guard: no Python, library, MCP, hook, `epic-orchestrator`, `epic-orchestrate`, `docs-plan-ia`, or substitutions-file change.

### Metrics Summary

- PASS 29966 Pester testcases, 0 failures; 34 new rows.
- PASS 17104 pytest tests, 0 failures.
- PASS 96.88% repo-wide PowerShell line coverage (artifact), no production file changed.
- PASS Test file 207 lines; skill file 122 lines.

### Recommendation

**Ready for merge** into the integration branch, subject to CI on the pull request.

---

## Appendix A: Test Inventory

### Complete Test List

1. documentation-workflow epic-scale routing (issue #1223) > places `## Epic-Scale Routing` once, after `## Rules` and before the stage heading (4 copies)
2. documentation-workflow epic-scale routing (issue #1223) > states the routing condition and the page threshold (4 copies)
3. documentation-workflow epic-scale routing (issue #1223) > lists the waves in order with each family id in its own wave segment (4 copies)
4. documentation-workflow epic-scale routing (issue #1223) > states ownership and omits family-record field names (4 copies)
5. documentation-workflow epic-scale routing (issue #1223) > states the dispatch rule (4 copies)
6. documentation-workflow epic-scale routing (issue #1223) > states the receipt rule (4 copies)
7. documentation-workflow epic-scale routing (issue #1223) > qualifies the single-run statements (4 copies)
8. documentation-workflow epic-scale routing (issue #1223) > states the epic standard behavior (2 copies)
9. execution-environment brief listing of the epic routing suite (issue #1223) > lists this suite in `## Contract Tests That Pin Mirrored Files` (4 copies)

---

## Appendix B: Toolchain Commands Reference

```powershell
# Static checks (read from the final-QC artifact, not re-run in review)
# mcp__drm-copilot__run_poshqc_format ; mcp__drm-copilot__run_poshqc_analyze

# Tests (launcher, parallel only)
sh .claude/skills/test-execution-policy/scripts/run-test-suite.sh pester
env -u VIRTUAL_ENV sh .claude/skills/test-execution-policy/scripts/run-test-suite.sh pytest

# Generator check
pwsh -NoProfile -File scripts/harness-generation/Invoke-HarnessGeneration.ps1 -Surface skills -Check
```

---

**Audit Completed By:** feature-review agent
**Audit Date:** 2026-11-24
**Policy Version:** Current (as of audit date)
