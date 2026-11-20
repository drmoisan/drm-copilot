# Policy Compliance Audit: Automate Full Release Flow (#291)

---

**Audit Date:** 2026-07-03
**Code Under Test:** `.vscode/tasks.json`, `scripts/dev-tools/Invoke-FullReleaseFlow.ps1`, `tests/scripts/dev-tools/Invoke-FullReleaseFlow.Tests.ps1`, and feature evidence under `docs/features/active/2026-07-03-automate-full-release-flow-291/`.

**Coverage Metrics by Language:**

| Language | Files Changed | Tests | Test Result | Baseline Coverage | Post-Change Coverage | New Code Coverage |
|----------|--------------|-------|-------------|-------------------|---------------------|-------------------|
| PowerShell | 2 `.ps1` files | 25 focused tests; 966 final Pester tests | PASS: 966 tests, 0 failures, 0 errors, 9 disabled | 92.92% repo line coverage; baseline run 941 tests, 0 failures | 92.92% repo line coverage from `artifacts/pester/powershell-coverage.xml` | 93.75% line coverage for `scripts/dev-tools/Invoke-FullReleaseFlow.ps1` from feature JaCoCo artifact |
| JSON | 1 `.json` file | JSON schema validation | PASS: `poetry run python -m scripts.dev_tools.validate_json` exit code 0 | N/A | N/A | N/A |
| TypeScript | 0 code files | N/A | N/A | N/A | N/A | N/A |
| Python | 0 code files | N/A | N/A | N/A | N/A | N/A |
| C# | 0 code files | N/A | N/A | N/A | N/A | N/A |

### Coverage Evidence Checklist

- TypeScript baseline coverage artifact: `N/A - zero TypeScript files changed`
- TypeScript post-change coverage artifact: `N/A - zero TypeScript files changed`
- Python baseline coverage artifact: `N/A - zero Python files changed`
- Python post-change coverage artifact: `N/A - zero Python files changed`
- PowerShell baseline coverage artifact: `docs/features/active/2026-07-03-automate-full-release-flow-291/evidence/baseline/poshqc-test.2026-07-03T17-15.md`
- PowerShell post-change coverage artifact: `artifacts/pester/powershell-coverage.xml`
- PowerShell focused new-code coverage artifact: `docs/features/active/2026-07-03-automate-full-release-flow-291/evidence/regression-testing/invoke-full-release-flow-coverage.xml`
- Per-language comparison summary: `docs/features/active/2026-07-03-automate-full-release-flow-291/evidence/qa-gates/powershell-delta-check.2026-07-03T17-15.md`

---

## Executive Summary

PASS. The branch `feature/automate-full-release-flow-291` was reviewed against `main` using merge base `406a0c1f662d0eb6b669ea7d16b57925a0257859`. The audit scope was the full branch diff from that merge base through `HEAD`, not a plan subset.

The review evaluated repository standing policy, general code and unit-test policy, PowerShell policy, JSON validation requirements, evidence-location policy, and minor-audit acceptance criteria for issue #291. The recorded final QA evidence reports passing PowerShell format, PSScriptAnalyzer, Pester, JSON validation, and coverage gates. Additional non-mutating review checks also passed: `git diff --check 406a0c1f662d0eb6b669ea7d16b57925a0257859...HEAD`, `poetry run python -m scripts.dev_tools.validate_json`, and `poetry run python scripts/dev_tools/validate_evidence_locations.py --root .`.

**Policy documents evaluated:**
- PASS: `AGENTS.md`
- PASS: `.agents/skills/policy-compliance-order/SKILL.md`
- PASS: `.agents/skills/evidence-and-timestamp-conventions/SKILL.md`
- PASS: `.agents/skills/feature-review-workflow/SKILL.md`
- PASS: `.agents/skills/acceptance-criteria-tracking/SKILL.md`

**Language-specific policies evaluated:**
- PASS: `.agents/skills/powershell/SKILL.md`
- PASS: JSON validation through repository `scripts.dev_tools.validate_json`
- N/A: Python, TypeScript, and C# code policies because the branch changes no code files in those languages.

**Temporary artifacts cleanup:**
- PASS: No temporary one-time scripts were found in the branch diff.
- PASS: The retained release-flow script has corresponding Pester coverage.

## Evidence Location Compliance

PASS. The branch stores feature evidence under `docs/features/active/2026-07-03-automate-full-release-flow-291/evidence/<kind>/`, which is the canonical path for this feature. The review ran `poetry run python scripts/dev_tools/validate_evidence_locations.py --root .` and it exited with code 0. A direct scan of `artifacts/baselines/`, `artifacts/qa/`, `artifacts/evidence/`, and `artifacts/coverage/` produced no changed evidence files.

No `EVIDENCE_LOCATION_OVERRIDE_REJECTED` event was needed because no caller-supplied non-canonical evidence path was used.

## 1. General Unit Test Policy Compliance

### 1.1 Core Principles

| Requirement | Status | Evidence |
|------------|--------|----------|
| Independence | PASS | `tests/scripts/dev-tools/Invoke-FullReleaseFlow.Tests.ps1` uses `BeforeEach` to reset captured calls and branch counters before each test. |
| Isolation | PASS | The focused test file groups confirmation, success, preflight, post-PR stop cases, helpers, and entry point behavior into separate `Context` and `It` cases. |
| Fast Execution | PASS | Focused Pester evidence reports 25 tests discovered and 25 passed with exit code 0. |
| Determinism | PASS | External `git`, `gh`, and child PowerShell script calls are mocked through wrapper functions. |
| Readability and Maintainability | PASS | Test names state the behavior under test, including dirty worktree, failed checks, merge failure, and confirmation rejection. |

### 1.2 Coverage and Scenarios

| Requirement | Status | Evidence |
|------------|--------|----------|
| Baseline Coverage Documented | PASS | `docs/features/active/2026-07-03-automate-full-release-flow-291/evidence/baseline/poshqc-test.2026-07-03T17-15.md` records baseline Pester and coverage evidence. |
| No Coverage Regression | PASS | `docs/features/active/2026-07-03-automate-full-release-flow-291/evidence/qa-gates/powershell-delta-check.2026-07-03T17-15.md` records no PowerShell QA or coverage regression. |
| New Code Coverage >=90% | PASS | `docs/features/active/2026-07-03-automate-full-release-flow-291/evidence/regression-testing/invoke-full-release-flow-coverage.xml` records 90/96 lines covered, 93.75%, for the new script. |
| Comprehensive Coverage | PASS | Focused tests cover success, confirmation rejection, dirty worktree, non-main branch, stale local main, PR lookup failure, failed checks, blocked merge, checkout failure, pull failure, tag-push failure, helpers, and entry point behavior. |
| Positive Flows | PASS | The successful automated flow test verifies release PR opening, check wait, merge, main pull, and tag-push invocation. |
| Negative Flows | PASS | Tests cover rejected confirmation, dirty worktree, non-main branch, stale main, failed preflight commands, PR lookup failure, failed checks, blocked merge, checkout failure, pull failure, and tag-push failure. |
| Edge Cases | PASS | Tests cover empty PR number, case-sensitive confirmation, and no text returned by `Get-FirstOutputLine`. |
| Error Handling | PASS | Tests verify non-zero return codes and stop-before-next-step behavior for failure paths. |
| Concurrency | N/A | The release flow is sequential and no concurrent behavior is introduced. |
| State Transitions | PASS | Tests verify the ordered flow from main preflight to release branch PR, checks, merge, main checkout, pull, and tag-push. |

### 1.2.1 Per-Language Coverage Comparison

- PowerShell: Baseline: 92.92% repo line coverage -> Post-change: 92.92% repo line coverage. Change: 0.00 percentage points. New/changed-code coverage: 93.75% for `scripts/dev-tools/Invoke-FullReleaseFlow.ps1`. Disposition: PASS. Evidence: `artifacts/pester/powershell-coverage.xml`, `docs/features/active/2026-07-03-automate-full-release-flow-291/evidence/baseline/poshqc-test.2026-07-03T17-15.md`, `docs/features/active/2026-07-03-automate-full-release-flow-291/evidence/qa-gates/poshqc-test.2026-07-03T17-15.md`, and `docs/features/active/2026-07-03-automate-full-release-flow-291/evidence/qa-gates/powershell-delta-check.2026-07-03T17-15.md`.

### 1.3 Test Structure and Diagnostics

| Requirement | Status | Evidence |
|------------|--------|----------|
| Clear Failure Messages | PASS | Assertions inspect explicit return codes, captured messages, and captured command sequences. |
| Arrange-Act-Assert Pattern | PASS | Tests set mocks and captured state, invoke `Invoke-FullReleaseFlowGuarded`, then assert result and side effects. |
| Document Intent | PASS | `It` names describe the expected behavior and failure boundary. |

### 1.4 External Dependencies and Environment

| Requirement | Status | Evidence |
|------------|--------|----------|
| Avoid External Dependencies | PASS | Tests mock `Invoke-GitExe`, `Invoke-GhExe`, and `Invoke-ChildPowerShellScript`; no live `git`, `gh`, `npm`, or network call is used in the focused tests. |
| Use Mocks/Stubs | PASS | Mocked components are limited to executable boundaries. |
| Environment Stability | PASS | Tests use explicit `RepoRoot` values and avoid mutable machine PATH assumptions for release behavior. |

### 1.5 Policy Audit Requirement

| Requirement | Status | Evidence |
|------------|--------|----------|
| Pre-submission Review | PASS | This artifact records policy review for the full feature branch diff. |

## 2. General Code Change Policy Compliance

### 2.1 Before Making Changes

| Requirement | Status | Evidence |
|------------|--------|----------|
| Clarify the objective | PASS | Issue #291 defines a guarded automated full release flow. |
| Read existing change plans | PASS | `docs/features/active/2026-07-03-automate-full-release-flow-291/plan.2026-07-03T17-15.md` exists and all tasks are checked. |
| Document the plan | PASS | The feature plan and evidence artifacts document implementation and verification. |

### 2.2 Design Principles

| Requirement | Status | Evidence |
|------------|--------|----------|
| Simplicity first | PASS | The implementation adds one wrapper script that composes existing release scripts. |
| Reusability | PASS | Existing `Invoke-FullRelease.ps1` and `Invoke-ReleaseTagPush.ps1` remain authoritative. |
| Extensibility | PASS | External executable boundaries are isolated with narrow wrapper functions for future test coverage. |
| Separation of concerns | PASS | The script separates confirmation, git preflight, PR lookup/check/merge, and tag-push orchestration. |

### 2.3 Module & File Structure

| Requirement | Status | Evidence |
|------------|--------|----------|
| Cohesive modules | PASS | `Invoke-FullReleaseFlow.ps1` contains one release orchestration workflow. |
| Under 500 lines | PASS | `scripts/dev-tools/Invoke-FullReleaseFlow.ps1` has 281 lines; `tests/scripts/dev-tools/Invoke-FullReleaseFlow.Tests.ps1` has 500 lines. |
| Public vs internal | PASS | The script exposes `Invoke-FullReleaseFlowGuarded` and keeps executable wrappers narrow. |
| No circular dependencies | PASS | The script invokes existing release scripts by path and does not add module imports. |

### 2.4 Naming, Docs, and Comments

| Requirement | Status | Evidence |
|------------|--------|----------|
| Descriptive names | PASS | Function names such as `Invoke-GitExe`, `Invoke-GhExe`, and `Invoke-FullReleaseFlowGuarded` describe their responsibilities. |
| Docs/docstrings | PASS | The script includes synopsis, description, parameters, and example usage. |
| Comment why, not what | PASS | Comments are limited and primarily explain test entry-point behavior and release script authority. |

### 2.5 After Making Changes - Toolchain Execution

| Requirement | Status | Evidence |
|------------|--------|----------|
| 1. Formatting | PASS | `mcp__drm-copilot__run_poshqc_format workspace_root=C:\Users\DanMoisan\repos\drm-copilot`, exit code 0 in `evidence/qa-gates/poshqc-format.2026-07-03T17-15.md`. |
| 2. Linting | PASS | `mcp__drm-copilot__run_poshqc_analyze workspace_root=C:\Users\DanMoisan\repos\drm-copilot`, exit code 0 in `evidence/qa-gates/poshqc-analyze.2026-07-03T17-15.md`. |
| 3. Type checking | N/A | PowerShell has no separate type-check step in the repository policy. |
| 4. Testing | PASS | `mcp__drm-copilot__run_poshqc_test workspace_root=C:\Users\DanMoisan\repos\drm-copilot`, exit code 0 in `evidence/qa-gates/poshqc-test.2026-07-03T17-15.md`. |
| Full toolchain loop | PASS | Final QA evidence records format, analyze, Pester, JSON validation, and delta check passing. |
| Explicit reporting | PASS | Commands and results are recorded in feature evidence and this audit. |

### 2.6 Summarize and Document

| Requirement | Status | Evidence |
|------------|--------|----------|
| Summarize changes | PASS | PR context summary lists one commit and the changed files. |
| Design choices explained | PASS | Issue and plan describe reuse of existing release scripts and wrapper seams. |
| Update supporting documents | PASS | Feature `issue.md`, plan, QA evidence, and VS Code task entry were updated or added. |
| Provide next steps | PASS | This review records PR readiness. |

## 3. Language-Specific Code Change Policy Compliance

### Section 3B: PowerShell Code Change Policy Compliance

#### 3B.1 Tooling & Baseline

| Requirement | Status | Evidence |
|------------|--------|----------|
| Formatting with Invoke-Formatter | PASS | Final PoshQC format evidence exited 0. |
| Linting with PSScriptAnalyzer | PASS | Final PoshQC analyze evidence exited 0. |
| Fix all findings | PASS | No final analyzer findings were reported. |
| PowerShell 7+ compatible | PASS | PoshQC analyzer completed successfully under repository PowerShell policy. |

#### 3B.2 PowerShell Design & Safety

| Requirement | Status | Evidence |
|------------|--------|----------|
| Advanced functions | PASS | Script functions use `[CmdletBinding()]` and typed parameters. |
| Parameter validation | PASS | `ConfirmToken` is mandatory and checked case-sensitively before release actions. |
| Avoid global state | PASS | Production script passes state through parameters and local variables; test script uses script-scoped captured state only inside tests. |
| Error handling | PASS | Failure paths emit explicit messages and return non-zero exit codes. |

#### 3B.3 Structure, Naming, and Comments

| Requirement | Status | Evidence |
|------------|--------|----------|
| Cohesive and under 500 lines | PASS | Production script is 281 lines; test file is 500 lines. |
| Approved verbs | PASS | `Invoke`, `Get`, `ConvertTo`, and `Write` are approved verbs. |
| Comment why | PASS | Documentation identifies release authority and mock seams. |

#### 3B.4 Running the Toolchain

| Requirement | Status | Evidence |
|------------|--------|----------|
| Step 1: Format | PASS | `evidence/qa-gates/poshqc-format.2026-07-03T17-15.md` |
| Step 2: Analyze | PASS | `evidence/qa-gates/poshqc-analyze.2026-07-03T17-15.md` |
| Step 3: Type check | N/A | Not applicable for PowerShell. |
| Step 4: Test | PASS | `evidence/qa-gates/poshqc-test.2026-07-03T17-15.md` |
| Rerun loop if needed | PASS | Final delta evidence records no PowerShell QA regression. |

### Section 3D: JSON Configuration Policy Compliance

#### 3D.1 JSON Tooling

| Requirement | Status | Evidence |
|------------|--------|----------|
| Formatting with jq | PASS | No JSON formatting failure was reported in the final evidence. |
| Schema validation | PASS | `poetry run python -m scripts.dev_tools.validate_json` exited 0 in feature QA evidence and in the review re-check. |
| Required `$schema` | PASS | `.vscode/tasks.json` includes `$schema`: `./schemas/tasks.schema.json`. |

#### 3D.2 JSON Structure

| Requirement | Status | Evidence |
|------------|--------|----------|
| Strict JSON only | PASS | Repository validation command exited 0. |
| Deterministic key order | PASS | No JSON validation or formatting failure was reported. |

## 4. Language-Specific Unit Test Policy Compliance

### Section 4B: PowerShell Unit Test Policy Compliance

#### 4B.1 Framework and Scope

| Requirement | Status | Evidence |
|------------|--------|----------|
| Use Pester v5.x | PASS | Tests use `Describe`, `Context`, `It`, `BeforeAll`, `BeforeEach`, `Mock`, and `Should`. |
| Use PoshQC Configuration | PASS | Final PoshQC Pester evidence exited 0. |
| PowerShell 7+ compatible | PASS | PoshQC final test and analyzer evidence exited 0. |

#### 4B.2 Test Style and Structure

| Requirement | Status | Evidence |
|------------|--------|----------|
| Focused Unit Tests | PASS | Tests exercise one release-flow behavior per `It` block. |
| Test Behavior Over Implementation | PASS | Assertions verify command sequencing, stop boundaries, return codes, and user-visible error messages. |
| Mocking Used Sparingly | PASS | Only external executable and child-script boundaries are mocked. |
| Organization | PASS | Test file `tests/scripts/dev-tools/Invoke-FullReleaseFlow.Tests.ps1` mirrors code file `scripts/dev-tools/Invoke-FullReleaseFlow.ps1`. |

#### 4B.3 Naming and Readability

| Requirement | Status | Evidence |
|------------|--------|----------|
| File Naming | PASS | Test file is named `Invoke-FullReleaseFlow.Tests.ps1`. |
| Describe/Context/It Structure | PASS | Tests are grouped by confirmation guard, successful flow, preflight blocks, post-PR stop cases, additional failure paths, helpers, and entry point. |
| Logical Grouping | PASS | Grouping follows the release flow order and failure boundaries. |
| Docstrings/Comments | PASS | Test names are self-descriptive. |

#### 4B.4 Running the Toolchain

| Requirement | Status | Evidence |
|------------|--------|----------|
| Use PoshQCTest Command | PASS | `mcp__drm-copilot__run_poshqc_test workspace_root=C:\Users\DanMoisan\repos\drm-copilot` exited 0. |
| No Alternative Test Runners | PASS | Final repository evidence uses PoshQC/Pester. Focused coverage also uses Pester with an explicit configuration. |

## 5. Test Coverage Detail

### `Invoke-FullReleaseFlowGuarded` and helpers (25 focused tests)

| Test Area | Scenario Type | Lines Covered | Status |
|-----------|--------------|---------------|--------|
| Confirmation guard | Negative | Confirmation rejection and wrapper non-invocation | PASS |
| Successful automated flow | Positive | Preflight, release PR script, PR view, checks, merge, checkout, pull, tag push | PASS |
| Preflight blocks | Negative/Error | Dirty worktree, non-main branch, stale local main, failed git commands | PASS |
| Post-PR stop cases | Negative/Error | PR lookup failure, failed checks, merge failure, checkout failure, pull failure, tag-push failure | PASS |
| Helpers | Edge/Unit | Command result creation and first output line parsing | PASS |
| Entry point | Negative | Direct script invocation with unconfirmed token | PASS |

**Coverage:** 93.75% line coverage for `scripts/dev-tools/Invoke-FullReleaseFlow.ps1` (90/96 lines covered).

**Not covered:** Six focused coverage lines are missed in the JaCoCo artifact. The new-script line coverage remains above the 90% policy threshold.

## 6. Test Execution Metrics

| Metric | Value | Status |
|--------|-------|--------|
| Total Focused Tests | 25 | PASS |
| Focused Tests Passed | 25 (100%) | PASS |
| Focused Tests Failed | 0 | PASS |
| Final Pester Tests | 966 total; 0 failures; 0 errors; 9 disabled | PASS |
| Functions/Classes Tested | Release-flow public entry and helper functions covered by focused tests | PASS |
| Test File Size | 500 lines | PASS |
| PowerShell Repo Coverage | 92.92% lines | PASS |
| New Script Coverage | 93.75% lines | PASS |

## 7. Code Quality Checks

**For PowerShell:**

| Check | Command | Result | Status |
|-------|---------|--------|--------|
| Invoke-Formatter | `mcp__drm-copilot__run_poshqc_format workspace_root=C:\Users\DanMoisan\repos\drm-copilot` | Exit code 0 | PASS |
| PSScriptAnalyzer | `mcp__drm-copilot__run_poshqc_analyze workspace_root=C:\Users\DanMoisan\repos\drm-copilot` | Exit code 0 | PASS |
| Pester Tests | `mcp__drm-copilot__run_poshqc_test workspace_root=C:\Users\DanMoisan\repos\drm-copilot` | 966 tests, 0 failures, 0 errors | PASS |
| Whitespace | `git diff --check 406a0c1f662d0eb6b669ea7d16b57925a0257859...HEAD` | Exit code 0 | PASS |

**For JSON:**

| Check | Command | Result | Status |
|-------|---------|--------|--------|
| JSON validation | `poetry run python -m scripts.dev_tools.validate_json` | Exit code 0 | PASS |

## 8. Gaps and Exceptions

### Identified Gaps

None. All mandatory policy gates reviewed for this branch passed or were not applicable because the language had zero changed code files.

### Approved Exceptions

None.

### Removed/Skipped Tests

None identified in the branch diff.

## 9. Summary of Changes

### Commits in This PR/Branch

1. `6cb1f56` - `feat(release): add guarded full release flow automation`

### Files Modified

1. `.vscode/tasks.json` (MODIFIED)
   - Adds `AutomatedFullReleaseFlowConfirm`.
   - Adds `Release: Automate Full Release Flow`.

2. `scripts/dev-tools/Invoke-FullReleaseFlow.ps1` (NEW)
   - Adds guarded orchestration over full release PR creation, PR checks, PR merge, main update, and release tag push.
   - Uses wrapper seams for `git`, `gh`, and child PowerShell scripts.

3. `tests/scripts/dev-tools/Invoke-FullReleaseFlow.Tests.ps1` (NEW)
   - Adds focused Pester coverage for success and failure paths.

4. `docs/features/active/2026-07-03-automate-full-release-flow-291/**` (NEW)
   - Adds issue, plan, baseline evidence, QA evidence, issue-update mirror, and regression coverage evidence for issue #291.

## 10. Compliance Verdict

### Overall Status: FULLY COMPLIANT

The reviewed branch satisfies the policy requirements applicable to the changed PowerShell, JSON, Markdown, and evidence files. PowerShell coverage is explicitly PASS for the changed language scope: repo-wide coverage is 92.92%, no regression is recorded, and the new script has 93.75% line coverage.

---

### Policy-by-Policy Summary

#### General Code Change Policy (Section 2)
- PASS: Before Making Changes
- PASS: Design Principles
- PASS: Module & File Structure
- PASS: Naming, Docs, Comments
- PASS: Toolchain Execution
- PASS: Summarize & Document

#### Language-Specific Code Change Policy (Section 3)

**For PowerShell:**
- PASS: Tooling & Baseline
- PASS: PowerShell Design & Safety
- PASS: Structure & Naming
- PASS: Toolchain

**For JSON:**
- PASS: Validation

#### General Unit Test Policy (Section 1)
- PASS: Core Principles
- PASS: Coverage & Scenarios
- PASS: Test Structure
- PASS: External Dependencies
- PASS: Policy Audit

#### Language-Specific Unit Test Policy (Section 4)

**For PowerShell:**
- PASS: Framework & Scope
- PASS: Test Style & Structure
- PASS: Naming & Readability
- PASS: Toolchain

---

### Metrics Summary

- PASS: 966/966 final Pester tests passed.
- PASS: 25/25 focused Pester tests passed.
- PASS: 92.92% repo-wide PowerShell line coverage.
- PASS: 93.75% new-script line coverage.
- PASS: `git diff --check` exited 0.
- PASS: `poetry run python -m scripts.dev_tools.validate_json` exited 0.
- PASS: `poetry run python scripts/dev_tools/validate_evidence_locations.py --root .` exited 0.

---

### Recommendation

Ready for normal PR flow. No remediation is required by the policy audit.

---

## Appendix A: Test Inventory

1. `Invoke-FullReleaseFlow.ps1 - Invoke-FullReleaseFlowGuarded` > `confirmation guard` > returns 2 and invokes no wrapper when `ConfirmToken` is `no`
2. `Invoke-FullReleaseFlow.ps1 - Invoke-FullReleaseFlowGuarded` > `confirmation guard` > is case-sensitive: `ConfirmToken` `YES` is rejected with code 2
3. `Invoke-FullReleaseFlow.ps1 - Invoke-FullReleaseFlowGuarded` > `successful automated flow` > opens the release PR, waits for checks, merges, pulls main, and invokes tag push
4. `Invoke-FullReleaseFlow.ps1 - Invoke-FullReleaseFlowGuarded` > `preflight blocks` > blocks dirty worktrees before opening the release PR
5. `Invoke-FullReleaseFlow.ps1 - Invoke-FullReleaseFlowGuarded` > `preflight blocks` > blocks when the current branch is not main
6. `Invoke-FullReleaseFlow.ps1 - Invoke-FullReleaseFlowGuarded` > `preflight blocks` > blocks when local main is not up to date with origin/main
7. `Invoke-FullReleaseFlow.ps1 - Invoke-FullReleaseFlowGuarded` > `post-PR stop cases` > returns 1 when PR lookup fails after the full release script runs
8. `Invoke-FullReleaseFlow.ps1 - Invoke-FullReleaseFlowGuarded` > `post-PR stop cases` > stops before merge, pull, and tag push when checks fail
9. `Invoke-FullReleaseFlow.ps1 - Invoke-FullReleaseFlowGuarded` > `post-PR stop cases` > stops before checkout, pull, and tag push when merge fails
10. `Invoke-FullReleaseFlow.ps1 - Invoke-FullReleaseFlowGuarded` > `post-PR stop cases` > stops before tag push when checkout main fails after merge
11. `Invoke-FullReleaseFlow.ps1 - Invoke-FullReleaseFlowGuarded` > `additional failure paths` > returns 1 when preflight command fails
12. `Invoke-FullReleaseFlow.ps1 - Invoke-FullReleaseFlowGuarded` > `additional failure paths` > returns 1 and stops correctly for post-PR scenarios
13. `Invoke-FullReleaseFlow.ps1 - Invoke-FullReleaseFlowGuarded` > `helpers` > creates command result objects with output and exit code
14. `Invoke-FullReleaseFlow.ps1 - Invoke-FullReleaseFlowGuarded` > `helpers` > returns the first non-empty output line
15. `Invoke-FullReleaseFlow.ps1 - Invoke-FullReleaseFlowGuarded` > `helpers` > returns an empty string when no output line contains text
16. `Invoke-FullReleaseFlow.ps1 - Invoke-FullReleaseFlowGuarded` > `entry point` > returns exit code 2 when invoked with an unconfirmed token

Parameterized Pester rows account for the 25 focused tests reported in the evidence.

---

## Appendix B: Toolchain Commands Reference

```powershell
mcp__drm-copilot__run_poshqc_format workspace_root=C:\Users\DanMoisan\repos\drm-copilot
mcp__drm-copilot__run_poshqc_analyze workspace_root=C:\Users\DanMoisan\repos\drm-copilot
mcp__drm-copilot__run_poshqc_test workspace_root=C:\Users\DanMoisan\repos\drm-copilot
poetry run python -m scripts.dev_tools.validate_json
poetry run python scripts/dev_tools/validate_evidence_locations.py --root .
git diff --check 406a0c1f662d0eb6b669ea7d16b57925a0257859...HEAD
```

---

**Audit Completed By:** Codex feature-review workflow
**Audit Date:** 2026-07-03
**Policy Version:** Current as of audit date
