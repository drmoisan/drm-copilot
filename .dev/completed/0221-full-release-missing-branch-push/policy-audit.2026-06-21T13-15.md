# Policy Compliance Audit: full-release-missing-branch-push (Issue #221)

**Audit Date:** 2026-06-21
**Code Under Test:**
- `scripts/dev-tools/Invoke-FullRelease.ps1` (PowerShell, MODIFIED)
- `tests/scripts/dev-tools/Invoke-FullRelease.Tests.ps1` (PowerShell test, MODIFIED)

**Coverage Metrics by Language:**

| Language | Files Changed | Tests | Test Result | Baseline Coverage | Post-Change Coverage | New Code Coverage |
|----------|--------------|-------|-------------|-------------------|---------------------|-------------------|
| PowerShell | 2 files (1 prod, 1 test) | 22 (Invoke-FullRelease suite); 319 full suite | PASS — 319 pass, 0 fail | 91.67% lines (66/72), 88.54% instr | 92.11% lines (70/76), 89.22% instr | Inserted push step (lines 248-252): 100% covered, 0 missed instructions |

**Note:** Only PowerShell files changed in the branch diff. No Python, TypeScript, C#, Bash, or JSON production files changed. Coverage verdicts for those languages are N/A because they have zero changed files on the branch.

### Coverage Evidence Checklist

- PowerShell baseline coverage artifact: `artifacts/pester/fullrelease-baseline-coverage.xml` (summarized in `evidence/baseline/poshqc-test.2026-06-21T12-06.md`)
- PowerShell post-change coverage artifact: `artifacts/pester/fullrelease-postchange-coverage.xml` (summarized in `evidence/qa-gates/poshqc-test.2026-06-21T12-06.md`)
- PowerShell canonical gate artifact: `artifacts/pester/powershell-coverage.xml` (see Observation O-1 below)
- Per-language comparison summary: `evidence/qa-gates/coverage-delta.2026-06-21T12-06.md`

**Non-negotiable verdict rule:** Numeric baseline (91.67% lines) and post-change (92.11% lines) coverage are present for the only in-scope language (PowerShell), plus changed-line coverage (100% on inserted step).

---

## Executive Summary

This review audits the full branch diff between merge-base `d33687885f1a113a4290d3ab798fc0c0e2e2b379` and HEAD `6f24a420e09827c15ca9e8b1db8b95f3d94cbbb3` for Issue #221. The change adds a missing `git push -u origin <branch>` step to `Invoke-FullReleaseGuarded` between the commit step (Step 4) and PR creation, fixing a release failure where `gh pr create` reported blank head/base SHAs because the release branch was never published.

The diff is scoped to one production PowerShell file (+9 lines), its test file (+32 lines, one new negative-path test), and feature-folder scoping/evidence documents. No workflow, benchmark, or GitHub Actions paths were modified, so the `modified-workflow-needs-green-run` rule does not fire. The implementation follows the established `Invoke-GitExe` wrapper-seam pattern and mirrors the existing Step 4 failure-handling contract. The PowerShell toolchain (format, analyze, test) passed per recorded QA-gate evidence, with 319 tests passing and 0 failures.

**Policy documents evaluated:**
- PASS `general-code-change.md`
- PASS `general-unit-test.md`

**Language-specific policies evaluated:**
- N/A `python.md` / `python-unit-test` — no Python files changed
- PASS `powershell.md` — PowerShell production + test files changed
- N/A `typescript.md` — no TypeScript files changed
- N/A `csharp.md` — no C# files changed

The change is small, well-isolated, fully tested on both decision arms, and consistent with repository design and test policy.

**Temporary artifacts cleanup:**
- PASS No temporary or one-time scripts were created by this change. The diff adds only the production push step and a Pester test.

---

## 1. General Unit Test Policy Compliance

### 1.1 Core Principles

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Independence** - Tests run in any order | PASS | Each `It` re-establishes mocks in `BeforeEach`/`Context` scope; `$script:`-scoped capture lists are reset in `BeforeEach` (`$script:ghInvokedAfterGitCount = -1`). No cross-test ordering dependency. |
| **Isolation** - Each test targets single behavior | PASS | The new test `returns 1 and does not open a PR when 'git push -u origin <branch>' fails` targets only the push-failure arm; the success-path test asserts push-before-PR ordering. |
| **Fast Execution** - Tests complete quickly | PASS | Pure in-process Pester with mocked seams; no I/O. Full suite of 319 tests recorded as passing (`evidence/qa-gates/poshqc-test.2026-06-21T12-06.md`). |
| **Determinism** - Consistent results | PASS | All external executables mocked via `Invoke-GitExe`/`Invoke-NpmExe`/`Invoke-GhExe` wrapper seams. No network, clock, or random dependencies. |
| **Readability & Maintainability** - Clear structure | PASS | Descriptive `It` names; Arrange-Act-Assert structure; intent comments on the ordering assertion block. |

### 1.2 Coverage and Scenarios

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Baseline Coverage Documented** | PASS | Baseline 91.67% lines (66/72), 88.54% instruction. Artifact: `artifacts/pester/fullrelease-baseline-coverage.xml`. Recorded in `evidence/baseline/poshqc-test.2026-06-21T12-06.md`. |
| **No Coverage Regression** | PASS | Post-change 92.11% lines (70/76), +0.44 pp; instruction +0.68 pp. Inserted push step (lines 248-252): 0 missed instructions on changed lines. Source: `evidence/qa-gates/coverage-delta.2026-06-21T12-06.md`. |
| **New/Changed Code Coverage** | PASS | The inserted push step is fully covered on both arms: success arm (push ExitCode 0) and failure arm (push ExitCode 1). Uniform threshold (line >= 85%) met at 92.11%. |
| **Comprehensive Coverage** | PASS | Both decision arms of the new branch are exercised by dedicated tests. The 11 missed instructions are inside the mocked wrapper-seam bodies (`Invoke-GitExe`/`Invoke-NpmExe`/`Invoke-GhExe`), not in the changed logic. |
| **Positive Flows** - Valid inputs | PASS | Updated success-path test asserts push occurs and PR opens. |
| **Negative Flows** - Invalid inputs | PASS | New test asserts push failure returns 1 and `Invoke-GhExe` is invoked 0 times. |
| **Edge Cases** - Boundary conditions | PASS | Ordering edge (push must precede `gh pr create`) is asserted via recorded git/gh call ordering. |
| **Error Handling** - Error paths | PASS | Push-failure path verified to emit `Failed to push release branch` diagnostic and return 1. |
| **Concurrency** - If applicable | N/A | The script is a sequential CLI workflow; no concurrency. |
| **State Transitions** - If applicable | N/A | No stateful component beyond linear step sequencing, which is covered by ordering assertions. |

### 1.2.1 Per-Language Coverage Comparison

- PowerShell: Baseline 91.67% lines -> Post-change 92.11% lines. Change +0.44 pp lines (+0.68 pp instruction). Changed-code coverage: 100% of inserted push step (0 missed instructions). Disposition: PASS. Evidence: `artifacts/pester/fullrelease-baseline-coverage.xml`, `artifacts/pester/fullrelease-postchange-coverage.xml`, `evidence/qa-gates/coverage-delta.2026-06-21T12-06.md`.

### 1.3 Test Structure and Diagnostics

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Clear Failure Messages** | PASS | Assertions use specific `Should -Match`/`Should -Be`/`Should -Invoke -Times 0 -Exactly`, producing actionable failures. |
| **Arrange-Act-Assert Pattern** | PASS | Mocks (Arrange), `Invoke-FullReleaseGuarded` call (Act), `Should` assertions (Assert). |
| **Document Intent** | PASS | Self-documenting `It` names plus intent comments on the ordering-assertion block. |

### 1.4 External Dependencies and Environment

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Avoid External Dependencies** | PASS | No live `git`/`gh`/`npm`; all isolated behind wrapper seams and mocked. |
| **Use Mocks/Stubs** | PASS | `Invoke-GitExe`, `Invoke-NpmExe`, `Invoke-GhExe` mocked. Mock signatures match production named parameters (`[string[]]$GitArgs` etc.). |
| **Environment Stability** | PASS | No temporary files created; no mutable global/PATH dependency; capture state reset per test. |

### 1.5 Policy Audit Requirement

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Pre-submission Review** | PASS | This audit serves as the required policy review for Issue #221. |

---

## 2. General Code Change Policy Compliance

### 2.1 Before Making Changes

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Clarify the objective** | PASS | Objective documented in `spec.md` and `issue.md` (#221): publish release branch before `gh pr create`. |
| **Read existing change plans** | PASS | `plan.md` and `plan.2026-06-21T12-06.md` present in the feature folder. |
| **Document the plan** | PASS | Plan and spec describe the single-step insertion. |

### 2.2 Design Principles

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Simplicity first** | PASS | A single push step inserted with the minimal exit-code branch; no added abstraction. |
| **Reusability** | PASS | Reuses the existing `Invoke-GitExe` seam rather than introducing a new mechanism. |
| **Extensibility** | PASS | Follows the established stepwise structure; future steps fit the same pattern. |
| **Separation of concerns** | PASS | External executable interaction remains isolated behind the wrapper seam. |

### 2.3 Module & File Structure

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Cohesive modules** | PASS | Change is confined to `Invoke-FullReleaseGuarded`. |
| **Under 500 lines** | PASS | `Invoke-FullRelease.ps1` is 272 lines (per `evidence/qa-gates/poshqc-test.2026-06-21T12-06.md`), under the 500-line limit. |
| **Public vs internal** | PASS | No change to public parameter surface or return-code contract. |
| **No circular dependencies** | PASS | Single-file script; no new imports. |

### 2.4 Naming, Docs, and Comments

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Descriptive names** | PASS | `$push`, `$branchName` are descriptive and consistent with surrounding code. |
| **Docs/docstrings** | PASS | The `.DESCRIPTION` comment block was updated to add Step 5 (push) and renumber the PR step to Step 6. |
| **Comment why, not what** | PASS | Inserted comment explains intent ("publish the release branch so gh pr create has a remote ref"). |

### 2.5 After Making Changes - Toolchain Execution

| Requirement | Status | Evidence |
|------------|--------|----------|
| **1. Formatting** | PASS | `mcp__drm-copilot__run_poshqc_format` ok:true, no reformatting churn (`evidence/qa-gates/poshqc-format.2026-06-21T12-06.md`). |
| **2. Linting** | PASS | `mcp__drm-copilot__run_poshqc_analyze` ok:true, 0 diagnostics (`evidence/qa-gates/poshqc-analyze.2026-06-21T12-06.md`). |
| **3. Type checking** | N/A | Not applicable for PowerShell per `.claude/rules/powershell.md`. |
| **4. Testing** | PASS | `mcp__drm-copilot__run_poshqc_test` ok:true, 319 tests, 0 failures (`evidence/qa-gates/poshqc-test.2026-06-21T12-06.md`). |
| **Full toolchain loop** | PASS | Loop re-run after the comment-only `.DESCRIPTION` edit; format/analyze/test all clean in a single pass. |
| **Explicit reporting** | PASS | Commands and results recorded in the feature-folder QA-gate evidence. |

### 2.6 Summarize and Document

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Summarize changes** | PASS | Summarized in `spec.md` Proposed Fix and this audit Section 9. |
| **Design choices explained** | PASS | Spec documents reuse of the `Invoke-GitExe` seam and the established failure-handling pattern. |
| **Update supporting documents** | PASS | `.DESCRIPTION` updated to match new behavior; spec/issue updated. |
| **Provide next steps** | PASS | Spec lists manual re-run verification of the release task. |

---

## 3. Language-Specific Code Change Policy Compliance

### Section 3B: PowerShell Code Change Policy Compliance

#### 3B.1 Tooling & Baseline

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Formatting with Invoke-Formatter** | PASS | `run_poshqc_format` ok:true. |
| **Linting with PSScriptAnalyzer** | PASS | `run_poshqc_analyze` ok:true, 0 diagnostics. |
| **Fix all findings** | PASS | 0 findings to fix. |
| **PowerShell 7+ compatible** | PASS | No version-specific constructs added; consistent with existing PS7 script. |

#### 3B.2 PowerShell Design & Safety

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Advanced functions** | PASS | `Invoke-FullReleaseGuarded` retains its existing advanced-function form; no regression. |
| **Parameter validation** | PASS | No parameter surface change. |
| **Avoid global state** | PASS | Production change introduces no script/global state. (Test file uses `$script:` capture lists in test scope only, which is acceptable for Pester capture.) |
| **Error handling** | PASS | Non-zero push ExitCode emits `Write-StderrLine` and returns 1, matching the Step 4 add/commit pattern; no silent catch-all. |

#### 3B.3 Structure, Naming, and Comments

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Cohesive and under 500 lines** | PASS | 272 lines. |
| **Approved verbs** | PASS | No new function added; `Invoke-` verb unchanged. |
| **Comment why** | PASS | Inserted comment explains the remote-ref rationale. |

#### 3B.4 Running the Toolchain

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Step 1: Format** | PASS | ok:true. |
| **Step 2: Analyze** | PASS | ok:true, 0 diagnostics. |
| **Step 3: Type check** | N/A | Not applicable for PowerShell. |
| **Step 4: Test** | PASS | ok:true, 319 tests, 0 failures. |
| **Rerun loop if needed** | PASS | Re-run once after the comment-only doc edit; clean. |

---

## 4. Language-Specific Unit Test Policy Compliance

### Section 4B: PowerShell Unit Test Policy Compliance

#### 4B.1 Framework and Scope

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Use Pester v5.x** | PASS | Pester 5.6.1; `Describe`/`Context`/`It`, `BeforeEach`, modern `Should` syntax. |
| **Use PoshQC Configuration** | PASS | Run via `mcp__drm-copilot__run_poshqc_test`; config `scripts/powershell/PoshQC/settings/pester.runsettings.psd1`. |
| **PowerShell 7+ Compatible** | PASS | No incompatible constructs. |

#### 4B.2 Test Style and Structure

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Focused Unit Tests** | PASS | New test focuses solely on the push-failure arm. |
| **Test Behavior Over Implementation** | PASS | Asserts observable behavior (return code, diagnostic text, gh not invoked, call ordering). |
| **Mocking Used Sparingly** | PASS | Only the three external wrapper seams are mocked, per mocking policy. |
| **Organization** | PASS | Test file at `tests/scripts/dev-tools/Invoke-FullRelease.Tests.ps1` mirrors `scripts/dev-tools/Invoke-FullRelease.ps1`. |

#### 4B.3 Naming and Readability

| Requirement | Status | Evidence |
|------------|--------|----------|
| **File Naming** - *.Tests.ps1 | PASS | `Invoke-FullRelease.Tests.ps1`. |
| **Describe/Context/It Structure** | PASS | New test placed in the `git/npm/gh seam failures` context. |
| **Logical Grouping** | PASS | Failure-path test grouped with other seam-failure tests. |
| **Docstrings/Comments** | PASS | Self-documenting test names; intent comments on ordering assertions. |

#### 4B.4 Running the Toolchain

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Use PoshQCTest Command** | PASS | `mcp__drm-copilot__run_poshqc_test` ok:true. |
| **No Alternative Test Runners** | PASS | Only Pester via PoshQC; a supplemental targeted `Invoke-Pester` was used solely for per-file coverage measurement, with the MCP gate authoritative. |

---

## 5. Test Coverage Detail

### Invoke-FullReleaseGuarded — inserted push step (lines 248-252)

| Test Name | Scenario Type | Lines Covered | Status |
|-----------|--------------|---------------|--------|
| bumps both manifests and opens a PR against main (updated) | Positive / ordering | 248-249 (push success arm), then 255-262 (PR) | PASS |
| returns 1 and does not open a PR when 'git push -u origin <branch>' fails | Negative / error handling | 248-252 (push failure arm) | PASS |

**Coverage:** Inserted step 100% covered (0 missed instructions on lines 248-252; line 252 is a closing brace with no instructions).

**Not covered:** The 11 missed instructions repo-file-wide are the mocked external wrapper-seam bodies (lines 69-70, 88-89, 107-108), which carry no decision logic and are intentionally not exercised in unit tests per the wrapper-seam isolation policy. None belong to the changed code.

---

## 6. Test Execution Metrics

| Metric | Value | Status |
|--------|-------|--------|
| Total Tests (full suite) | 319 | PASS |
| Tests Passed | 319 (100%) | PASS |
| Tests Failed | 0 | PASS |
| Invoke-FullRelease suite tests | 22 | PASS |
| Functions/Classes Tested | n/a (script function suite) | PASS |
| Test File Size | within limit | PASS |
| Code Coverage (Invoke-FullRelease.ps1) | 92.11% lines, instruction proxy 89.22% | PASS |

---

## 7. Code Quality Checks

**For PowerShell:**

| Check | Command | Result | Status |
|-------|---------|--------|--------|
| Invoke-Formatter | `mcp__drm-copilot__run_poshqc_format` | ok:true, no churn | PASS |
| PSScriptAnalyzer | `mcp__drm-copilot__run_poshqc_analyze` | ok:true, 0 diagnostics | PASS |
| Pester Tests | `mcp__drm-copilot__run_poshqc_test` | ok:true, 319 pass / 0 fail | PASS |

**Notes:**
No pre-existing failures observed in the recorded evidence.

---

## 8. Gaps and Exceptions

### Identified Gaps

- Branch-coverage counter: The Pester (5.6.1) JaCoCo output does not emit a distinct BRANCH counter. The >= 75% branch-coverage threshold cannot be measured as a distinct counter under this toolchain. Mitigating evidence: instruction coverage 89.22% and explicit coverage of both decision arms of the inserted branch (success and failure). This is a toolchain measurement limitation, not a coverage deficiency on the changed code. Disposition: PASS on all measurable metrics; not a remediation trigger.

### Approved Exceptions

- **None.** No exceptions required.

### Removed/Skipped Tests

- **None.** No tests were removed or skipped; one test was added (full suite 318 -> 319).

---

## 9. Summary of Changes

### Commit range

- Base (merge-base): `d33687885f1a113a4290d3ab798fc0c0e2e2b379`
- Head: `6f24a420e09827c15ca9e8b1db8b95f3d94cbbb3`

### Files Modified

1. **`scripts/dev-tools/Invoke-FullRelease.ps1`** (MODIFIED, +9 net lines)
   - Inserted Step 5: `Invoke-GitExe -GitArgs @('push', '-u', 'origin', $branchName)` with non-zero ExitCode handling that emits a `Write-StderrLine` diagnostic and returns 1.
   - Renumbered the PR step to Step 6.
   - Updated `.DESCRIPTION` to document the new push step.

2. **`tests/scripts/dev-tools/Invoke-FullRelease.Tests.ps1`** (MODIFIED, +32 lines)
   - Added a push-failure negative-path test asserting return 1, the diagnostic message, and that `Invoke-GhExe` is not invoked.
   - Updated the success-path test to assert the push call precedes `gh pr create`.

3. **Feature-folder documents and evidence** (NEW): `issue.md`, `spec.md`, `plan.md`, `plan.2026-06-21T12-06.md`, and `evidence/**` (baseline, qa-gates, regression-testing). These are documentation/evidence, not production code.

---

## 10. Compliance Verdict

### Overall Status: FULLY COMPLIANT

The change adds a single, well-isolated push step that follows the established wrapper-seam and failure-handling patterns. The PowerShell toolchain (format, analyze, test) passed cleanly, both decision arms of the new branch are covered, and line coverage on the changed file increased to 92.11% with 0 missed instructions on the changed lines. No policy violation was identified. No remediation is required.

**Fail-closed check:** All required baseline, QA-gate, and coverage-comparison artifacts are present for the in-scope language (PowerShell).

---

### Policy-by-Policy Summary

#### General Code Change Policy (Section 2)
- PASS Before Making Changes
- PASS Design Principles
- PASS Module & File Structure
- PASS Naming, Docs, Comments
- PASS Toolchain Execution
- PASS Summarize & Document

#### Language-Specific Code Change Policy (Section 3 — PowerShell)
- PASS Tooling & Baseline
- PASS PowerShell Design & Safety
- PASS Structure & Naming
- PASS Toolchain

#### General Unit Test Policy (Section 1)
- PASS Core Principles
- PASS Coverage & Scenarios
- PASS Test Structure
- PASS External Dependencies
- PASS Policy Audit

#### Language-Specific Unit Test Policy (Section 4 — PowerShell)
- PASS Framework & Scope
- PASS Test Style & Structure
- PASS Naming & Readability
- PASS Toolchain

---

### Metrics Summary

- PASS 319/319 tests passing (100%)
- PASS 92.11% line coverage on the changed file (baseline 91.67%; +0.44 pp)
- PASS 0 PSScriptAnalyzer diagnostics
- PASS Inserted push step 100% covered on both arms
- PASS File under 500 lines (272)

---

### Recommendation

**Ready for merge.** No blocking or partial findings. No remediation plan required.

---

## Rejected Scope Narrowing

No caller instruction attempted to narrow the audit scope to a plan, task, phase, or file subset, and no instruction attempted to mark any language's coverage as out of scope or informational only. The caller directed a full branch-diff audit against the resolved merge-base, consistent with the scope invariant. No narrowing was detected; none was rejected.

---

## Evidence Location Compliance

`scripts/dev_tools/validate_evidence_locations.py --root .` was executed and exited 0 (no violations).

A direct scan of the branch diff for files written under `artifacts/baselines/`, `artifacts/qa/`, `artifacts/evidence/`, or `artifacts/coverage/` returned no matches. All feature evidence is written to the canonical `docs/features/active/2026-06-21-full-release-missing-branch-push-221/evidence/<kind>/` location (`baseline/`, `qa-gates/`, `regression-testing/`). No evidence-location violation was found.

No `EVIDENCE_LOCATION_OVERRIDE_REJECTED` events occurred during this review.

---

## Observations

- **O-1 (informational, not a finding):** The canonical PowerShell coverage gate artifact `artifacts/pester/powershell-coverage.xml` reports 0% covered. Inspection shows that report is scoped to `.claude/hooks/**` PowerShell files (instrumented but not exercised by the run that produced it), not to the in-scope `Invoke-FullRelease.ps1`. The authoritative coverage evidence for the changed file is the targeted per-file measurement in `artifacts/pester/fullrelease-postchange-coverage.xml` (92.11% line) and the passing MCP `run_poshqc_test` gate (319 tests). This artifact is not the in-scope coverage source and does not represent a coverage regression on the changed code. Repo-wide PowerShell coverage was not measured by a single aggregate artifact in this run; the in-scope verdict relies on the per-file changed-code coverage, which is the directly relevant metric for this two-file diff.

---

## Appendix A: Test Inventory

Invoke-FullRelease.ps1 - Invoke-FullReleaseGuarded suite (22 tests), relevant entries:

- Describe `Invoke-FullRelease.ps1 - Invoke-FullReleaseGuarded` › Context `happy path` › `bumps both manifests and opens a PR against main` (updated: asserts push precedes `gh pr create`)
- Describe `Invoke-FullRelease.ps1 - Invoke-FullReleaseGuarded` › Context `git/npm/gh seam failures` › `returns 1 and does not open a PR when 'git push -u origin <branch>' fails` (new)
- Remaining suite tests (confirmation guard, missing manifest, dirty tree, commit/PR failures, Get-NpmVersion reader) unchanged.

Full suite: 319 tests, 0 failures.

---

## Appendix B: Toolchain Commands Reference

**For PowerShell (MCP gates — authoritative):**
```
mcp__drm-copilot__run_poshqc_format     # scan: scripts/dev-tools, tests/scripts/dev-tools
mcp__drm-copilot__run_poshqc_analyze    # scan: scripts/dev-tools, tests/scripts/dev-tools
mcp__drm-copilot__run_poshqc_test       # scan: scripts/dev-tools, tests/scripts/dev-tools
```

**Supplemental targeted coverage (non-authoritative, per-file numeric):**
```
Invoke-Pester -Configuration (
  Run.Path = tests/scripts/dev-tools/Invoke-FullRelease.Tests.ps1;
  CodeCoverage.Path = scripts/dev-tools/Invoke-FullRelease.ps1;
  CodeCoverage.OutputFormat = JaCoCo
)
```

**Review-time verification commands:**
```
git diff --name-status d33687885f1a113a4290d3ab798fc0c0e2e2b379 6f24a420e09827c15ca9e8b1db8b95f3d94cbbb3
poetry run python -m scripts.dev_tools.pr_context.collector --base d3368788... --head 6f24a420... --repo-root .
poetry run python scripts/dev_tools/validate_evidence_locations.py --root .
```

---

**Audit Completed By:** feature-review agent (Claude Code)
**Audit Date:** 2026-06-21
**Policy Version:** Current (as of audit date)

**Template resolution note:** The MCP tool `mcp__drm-copilot__resolve_policy_audit_template_asset` was not available in this session's toolset. The bundled-asset source it serves (`extensions/drm-copilot/resources/templates/policy_audit/policy-audit.yyyy-MM-ddTHH-mm.md`) was read directly to drive this artifact's structure, and the canonical major headings were preserved. Likewise, `mcp__drm-copilot__validate_orchestration_artifacts` was not available; structural conformance to the canonical headings was verified by inspection.
