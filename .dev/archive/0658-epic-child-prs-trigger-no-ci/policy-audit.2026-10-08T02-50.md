# Policy Compliance Audit: ci.yml epic/** pull_request trigger and S9 epic-child rule (Issue #658)

---

**Audit Date:** 2026-10-08 (artifact timestamp `2026-10-08T02-50` supplied by the delegating orchestrator)
**Reviewer:** feature-review agent, pass 1
**Branch:** `bug/epic-child-prs-trigger-no-ci-658`, head `9686d975d85250814aba7e149ee6ac0cfeda562a`
**Base:** `origin/main`, merge-base `08ee030d9584bf15882fbb3654c8e38f34c7c359` (origin/main has since advanced to `6c3649b07322374035df8c11996f4d64a043e138` with PR #835; that delta touches none of the changed paths and `git merge-tree --write-tree --name-only HEAD origin/main` completed without conflicts)
**Template source:** bundled policy-audit asset `extensions/drm-copilot/resources/templates/policy_audit/policy-audit.yyyy-MM-ddTHH-mm.md`, read directly from the worktree because the MCP template tool is outside this agent's tool allowlist.

**Code Under Test (full branch diff, `git diff --stat origin/main...HEAD`, 50 files):**
- `.github/workflows/ci.yml` (MODIFIED, 1 line)
- `.github/workflows/README.md` (MODIFIED, +10 lines)
- `.claude/skills/orchestrate/SKILL.md` (MODIFIED, +3 lines)
- `extensions/drm-copilot/resources/claude-customizations/.claude/skills/orchestrate/SKILL.md` (MODIFIED, +3 lines, byte mirror)
- `tests/scripts/workflows/CiWorkflow.Tests.ps1` (NEW, 174 lines)
- 45 files under `docs/features/active/2026-09-08-epic-child-prs-trigger-no-ci-658/` (issue, plan, research, evidence)

**Coverage Metrics by Language:**

| Language | Files Changed | Tests | Test Result | Baseline Coverage | Post-Change Coverage | New Code Coverage |
|----------|--------------|-------|-------------|-------------------|---------------------|-------------------|
| PowerShell | 1 file (test suite; 0 production files) | 2 new tests; 6521 repo-wide | PASS: 6521 pass, 0 fail, 10 skipped | 84.32% cmds repo-wide (CI run 37645267440) | 84.32% cmds repo-wide (CI run 37717224700) | N/A - no production PowerShell file added or modified |
| YAML (GitHub Actions) | 1 file | N/A (no YAML test runner) | PASS: actionlint 1.7.11, 0 findings | N/A (no coverage tooling for workflow YAML) | N/A (no coverage tooling for workflow YAML) | N/A |
| Markdown | 48 files (3 runtime docs, 45 feature-folder docs) | N/A | PASS: bundle-parity pytest 14 passed | N/A (documentation) | N/A (documentation) | N/A |
| Python | 0 files | 39 contract tests run as consumers | PASS: 39 pass, 0 fail | N/A - zero Python files changed | N/A - zero Python files changed | N/A |
| TypeScript | 0 files | N/A | N/A | N/A - zero TypeScript files changed | N/A - zero TypeScript files changed | N/A |
| C# | 0 files | N/A | N/A | N/A - zero C# files changed | N/A - zero C# files changed | N/A |

### Coverage Evidence Checklist

- TypeScript baseline coverage artifact: N/A - out of scope (zero TypeScript files changed on the branch)
- TypeScript post-change coverage artifact: N/A - out of scope (zero TypeScript files changed on the branch)
- PowerShell baseline coverage artifact: docs/features/active/2026-09-08-epic-child-prs-trigger-no-ci-658/evidence/baseline/baseline-poshqc-test.2026-10-07T21-58.md (CI run 37645267440 coverage headline)
- PowerShell post-change coverage artifact: docs/features/active/2026-09-08-epic-child-prs-trigger-no-ci-658/evidence/qa-gates/final-poshqc-test.2026-10-08T02-30.md (CI run 37717224700 coverage headline)
- Per-language comparison summary: Section 1.2.1 of this audit and docs/features/active/2026-09-08-epic-child-prs-trigger-no-ci-658/evidence/qa-gates/coverage-comparison.2026-10-08T02-30.md

**Coverage verdicts (languages with changed files):**

| Coverage language | Changed files on branch | Verdict | Basis |
|---|---|---|---|
| PowerShell | 1 (test only) | PASS | No production PowerShell file was added or modified, so the new-file and modified-file thresholds have no subject and no changed production line can regress. Repo-wide command coverage is 84.32% in both the baseline and post-change CI runs, with identical denominators (21,894 analyzed commands in 174 files). See finding N-4 for the repo-wide line-coverage figure. |
| TypeScript | 0 | N/A | Zero changed files. |
| Python | 0 | N/A | Zero changed files. |
| C# | 0 | N/A | Zero changed files. |

YAML and Markdown are not coverage languages in the agent contract (the artifact table names TypeScript, Python, PowerShell, and C# only). Their verification is by actionlint and by content and parity checks.

---

## Executive Summary

The branch adds `"epic/**"` to the `ci.yml` `pull_request` branch filter, documents the trigger set in `.github/workflows/README.md`, adds an S9 epic-child rule to the orchestrate skill (with a byte-identical bundle mirror), and adds a two-test Pester regression suite for the trigger invariants. The production change is one YAML line. The only new executable code is the test suite.

Policy compliance is substantively met for code, tests, and documentation. One Blocking finding remains. The `modified-workflow-needs-green-run` rule (`.claude/skills/feature-review-workflow/SKILL.md`) requires a green CI run whose head SHA equals the current branch head. The recorded green run 37717224700 is on `8a1b9b8b`, while the branch head is `9686d975`. The intervening commit is documentation-only, but the rule is SHA-exact. The finding is classified `awaiting_ci` and is resolved by a green CI run on the final PR head. It requires no code change.

All nine named deviations were assessed (Section 8). Eight are acceptable. DEV-AC7-EARLY is not acceptable as a full satisfaction of AC-7 and is the source of the Blocking finding.

**Policy documents evaluated:**
- PASS `CLAUDE.md`, `.claude/rules/general-code-change.md`
- PASS `.claude/rules/general-unit-test.md`, `.claude/rules/quality-tiers.md`
- PASS `.claude/rules/tonality.md`
- PASS `.claude/skills/evidence-and-timestamp-conventions/SKILL.md` (with Non-blocking finding N-2)

**Language-specific policies evaluated:**
- PASS `.claude/rules/powershell.md` (PowerShell code and unit test standards for the new Pester suite)
- PASS `.claude/rules/ci-workflows.md` (no `pwsh` step was added or modified; the rule's enforcement clause defers to `modified-workflow-needs-green-run`, see B-1)
- N/A Python, TypeScript, C# (zero changed files)

Toolchain results:
- actionlint 1.7.11 on `ci.yml`: exit 0 with no output (reproduced by this review).
- Mirror byte identity: `cmp` exit 0 (reproduced by this review).
- Bundle parity and sibling Python contract suites: 39 passed (reproduced by this review).
- PoshQC format, analyze, and Pester: read from CI poshqc job 113116383126 on `8a1b9b8b` under the operator's Option A rule. This review did not run PowerShell locally, in compliance with that rule.

**Temporary artifacts cleanup:**
- PASS No temporary or one-time scripts are present in the branch diff.
- PASS No tooling scripts were added.
- The executor's plan-specified scratchpad `sh` wrapper route was withdrawn (DEV-PWSH-ROUTE), so no wrapper scripts were created.

---

## Rejected Scope Narrowing

None detected. The caller prompt listed the five production and test paths as "Production/test changes under review (git diff origin/main...HEAD)". That list is the complete set of non-documentation paths in the branch diff, so it is a description of scope rather than a narrowing. The caller note that PowerShell gates were satisfied from CI logs does not exclude PowerShell from coverage review. PowerShell received an explicit verdict above.

## Evidence Location Compliance

| Check | Result | Evidence |
|---|---|---|
| Branch diff paths under `artifacts/baselines/`, `artifacts/qa/`, `artifacts/evidence/`, `artifacts/coverage/` | PASS: none | `git diff --name-only origin/main...HEAD` lists only the five production/test paths and paths under the feature folder |
| `validate_evidence_locations.py --root .` | PASS: exit 0 | `poetry run python scripts/dev_tools/validate_evidence_locations.py --root .` |
| Evidence under canonical `<FEATURE>/evidence/<kind>/` | PASS | All 44 evidence files are under `evidence/baseline`, `evidence/other`, `evidence/qa-gates`, or `evidence/regression-testing` |
| Host data in evidence (absolute paths, drive letters, account names) | PASS: none | Search of the feature folder for drive-letter and user-profile patterns matched only `https://github.com/...` URLs |

---

## 1. General Unit Test Policy Compliance

### 1.1 Core Principles

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Independence** | PASS | The two `It` blocks read shared, read-only `$script:triggerLines` populated once in `BeforeAll`. No test mutates state. |
| **Isolation** | PASS | One `It` per trigger invariant: the `pull_request` filter contents (lines 149-162) and the `push` filter exact value (lines 164-173). |
| **Fast Execution** | PASS | CI per-file line `[+] ...CiWorkflow.Tests.ps1 40ms (5ms\|18ms)` (final-poshqc-test.2026-10-08T02-30.md). |
| **Determinism** | PASS | Pure text parsing of a repository file. No clock, randomness, network, or process launch. Hermeticity grep printed `0` (ci-workflow-test-hermeticity.2026-10-07T22-02.md). |
| **Readability & Maintainability** | PASS | Descriptive `It` names, Arrange/Act/Assert comments, a header comment stating purpose and the location rationale, and comment-based help on the helper. |

### 1.2 Coverage and Scenarios

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Baseline Coverage Documented** | PASS | Baseline 84.32% commands repo-wide, CI run 37645267440 on `08ee030d` (baseline-poshqc-test.2026-10-07T21-58.md). The item branch at baseline differed from `08ee030d` only in feature-folder docs; this review confirmed it with `git diff --name-only 08ee030d 97008102`. |
| **No Coverage Regression** | PASS | Post-change 84.32% commands repo-wide, CI run 37717224700 on `8a1b9b8b`. Change: 0.00%, with identical denominators. No production PowerShell line changed. |
| **New Code Coverage** | N/A | No production code was added. The only new executable file is a test suite, and test files are excluded from coverage measurement per `general-unit-test.md`. |
| **Comprehensive Coverage** | PASS | Both invariants named by AC-1 and AC-4 are asserted: the `pull_request` list contains `main`, `development`, and `epic/**`; the `push` list equals `main,development`. |
| **Positive Flows** | PASS | Fixed `ci.yml` yields both tests passing (pass-after-poshqc.2026-10-08T02-30.md). |
| **Negative Flows** | PASS | Pre-fix `ci.yml` yields exactly one failure, on `Should -Contain 'epic/**'` at line 161 (fail-before-direct.2026-10-07T22-30.md). This matches test file line 161. |
| **Edge Cases** | PASS | A non-empty trigger-block assertion guards against a vacuous pass when `on:` is absent. The helper returns an empty array for an absent event or key, so the subsequent `Should -Contain` fails rather than passes. |
| **Error Handling** | N/A | Test-only code with no error paths of its own. `Resolve-Path` fails the suite if `ci.yml` is absent. |
| **Concurrency** | N/A | No concurrent behavior. |
| **State Transitions** | N/A | No stateful component. |

### 1.2.1 Per-Language Coverage Comparison

- PowerShell: Baseline: 84.32% commands repo-wide -> Post-change: 84.32% commands repo-wide. Change: 0.00% (21,894 analyzed commands in 174 files in both runs). New/changed-code coverage: N/A - no production PowerShell file added or modified. Disposition: PASS. Evidence: evidence/baseline/baseline-poshqc-test.2026-10-07T21-58.md, evidence/qa-gates/final-poshqc-test.2026-10-08T02-30.md, evidence/qa-gates/coverage-comparison.2026-10-08T02-30.md

### 1.3 Test Structure and Diagnostics

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Clear Failure Messages** | PASS | Each `Should -Contain` carries `-Because`. The recorded failure reads `Expected 'epic/**' to be found in collection @('main', 'development'), because epic child PRs into epic/<slug>-integration must run CI (issue #658), but it was not found.` |
| **Arrange-Act-Assert Pattern** | PASS | Explicit `# Arrange`, `# Act`, `# Assert` comments in both `It` blocks. |
| **Document Intent** | PASS | Header comment (lines 3-16) and descriptive `Describe`/`It` names. |

### 1.4 External Dependencies and Environment

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Avoid External Dependencies** | PASS | Reads one repository file via `Get-Content -LiteralPath`. No module import, process, or network call. |
| **Use Mocks/Stubs** | N/A | Nothing to mock. The subject under test is the real workflow file. |
| **Environment Stability** | PASS | The path is resolved from `$PSScriptRoot`, so there is no working-directory assumption. No temporary file (hermeticity grep `0`). |

### 1.5 Policy Audit Requirement

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Pre-submission Review** | PASS | This document. Outstanding item: B-1 (awaiting CI on the final head). |

---

## 2. General Code Change Policy Compliance

### 2.1 Before Making Changes

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Clarify the objective** | PASS | `issue.md` Summary and AC-1..AC-7. Research is at `research/2026-09-29T20-50-epic-child-prs-ci-trigger-research.md`. |
| **Read existing change plans** | PASS | `evidence/baseline/phase0-instructions-read.md` lists ten policy files in the required order. |
| **Document the plan** | PASS | `plan.2026-09-29T20-45.md` (minimal-audit, three phases). |

### 2.2 Design Principles

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Simplicity first** | PASS | One-line trigger change. Quoting `"epic/**"` is required because `*` is a YAML alias indicator. |
| **Reusability** | PASS | The test reuses the `on:`-block isolation pattern from `PublishMcpNpmWorkflow.Tests.ps1:19-35`. |
| **Extensibility** | PASS | The `Get-CiTriggerBranchList` helper handles flow and block list forms, so a later reformatting of `ci.yml` does not break the suite. |
| **Separation of concerns** | PASS | Trigger policy lives in YAML, documentation in the README, and process rules in the skill. |

### 2.3 Module & File Structure

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Cohesive modules** | PASS | Each changed file has a single purpose. |
| **Under 500 lines** | PASS | `CiWorkflow.Tests.ps1` 174, `ci.yml` 42, `orchestrate/SKILL.md` 446 (Markdown is exempt). |
| **Public vs internal** | N/A | No public API surface was changed. |
| **No circular dependencies** | N/A | No module dependencies were introduced. |

### 2.4 Naming, Docs, and Comments

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Descriptive names** | PASS | `Get-CiTriggerBranchList`, `$pullRequestBranches`, `$pushBranches`. |
| **Docs/docstrings** | PASS | Comment-based help on the helper (`.SYNOPSIS`, `.DESCRIPTION`, `.PARAMETER`). |
| **Comment why, not what** | PASS | Comments explain why the trigger block is isolated and why `epic/**` is required. |

### 2.5 After Making Changes - Toolchain Execution

| Requirement | Status | Evidence |
|------------|--------|----------|
| **1. Formatting** | PASS | CI format step on `8a1b9b8b`: `Already formatted: ...CiWorkflow.Tests.ps1` (log line 814); no format-step `Formatted:` line. |
| **2. Linting** | PASS | CI analyzer on `8a1b9b8b`: `PSScriptAnalyzer passed: no findings` (log line 823). actionlint on `ci.yml`: 0 findings (this review). |
| **3. Type checking** | N/A | Not applicable to PowerShell, YAML, or Markdown. |
| **4. Architecture-boundary tests** | N/A | No module boundary was affected. |
| **5. Unit tests** | PASS | CI Pester: `Tests Passed: 6521, Failed: 0, Skipped: 10`. Local pytest consumers: 39 passed. |
| **6. Contract / schema checks** | PASS | Bundle-parity contract suite: 14 passed (this review and final-bundle-parity.2026-10-08T02-30.md). |
| **7. Integration tests** | PASS | Full CI run 37717224700, 17 jobs, all `success` (ac7-ci-green-run.2026-10-08T02-30.md). |
| **Full toolchain loop** | PASS | `final-loop-single-pass.2026-10-08T02-30.md`: one pass with no restart; `PrePassStatus` and `PostPassStatus` both empty. |
| **Explicit reporting** | PASS | Each stage is recorded under `evidence/qa-gates/` with run and job IDs. |

### 2.6 Summarize and Document

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Summarize changes** | PASS | Commit `00798863` ("fix(658): run CI for epic child PRs into epic/** integration branches"). |
| **Design choices explained** | PASS | The README `## Triggers` section states the reason for `epic/**`. This satisfies `github-actions.instructions.md`, which requires intentional trigger changes to be documented. |
| **Update supporting documents** | PASS | README and orchestrate skill, with a byte-identical bundle mirror. |
| **Provide next steps** | PASS | B-1 next step: a green CI run on the final PR head. |

---

## 3. Language-Specific Code Change Policy Compliance

### Section 3B: PowerShell Code Change Policy Compliance

#### 3B.1 Tooling & Baseline

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Formatting with Invoke-Formatter** | PASS | CI run 37717224700 job 113116383126 log line 814. The MCP `run_poshqc_format` returned `ok: true` and git porcelain status was unchanged before and after. |
| **Linting with PSScriptAnalyzer** | PASS | CI log line 823 shows `PSScriptAnalyzer passed: no findings`. The first local pass reported 3 findings (unary-comma returns), which were fixed and re-run from format (hermeticity artifact, passes 1-2). |
| **Fix all findings** | PASS | The three analyzer findings were resolved by replacing `return , [string[]]` with `return [string[]]` and wrapping call sites in `@()`. |
| **PowerShell 5.1 & 7.6+ compatible** | PASS | Uses `[List[string]]::new()`, `-match`, `StartsWith`, and `Substring`, all available in 5.1. The CI runner executed on pwsh 7. |

#### 3B.2 PowerShell Design & Safety

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Advanced functions** | PASS | `[CmdletBinding()]` and `[OutputType([string[]])]` on the helper. |
| **Parameter validation** | PASS | `[Parameter(Mandatory)]`, `[AllowEmptyCollection()]`, `[AllowEmptyString()]`, and `[ValidateNotNullOrEmpty()]`. |
| **Avoid global state** | PASS | Script scope is limited to the Pester container. No `$global:` usage. |
| **Error handling** | PASS | `Set-StrictMode -Version Latest`. `Resolve-Path` fails fast on a missing file. |

#### 3B.3 Structure, Naming, and Comments

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Cohesive and under 500 lines** | PASS | 174 lines. |
| **Approved verbs** | PASS | `Get-` |
| **Comment why** | PASS | See Section 2.4. |

#### 3B.4 Running the Toolchain

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Step 1: Format** | PASS | See 3B.1. |
| **Step 2: Analyze** | PASS | See 3B.1. |
| **Step 3: Type check** | N/A | Not applicable for PowerShell. |
| **Step 4: Test** | PASS | CI `Tests Passed: 6521, Failed: 0`. |
| **Rerun loop if needed** | PASS | Two local passes during authoring (analyzer fix). The final loop was a single pass. |

### Section 3E: GitHub Actions Workflow Policy Compliance

| Requirement | Status | Evidence |
|------------|--------|----------|
| **actionlint clean** | PASS | `actionlint .github/workflows/ci.yml`: exit 0, no output (actionlint 1.7.11, run by this review at head `9686d975`). |
| **Trigger change documented** | PASS | README lines 8-16. |
| **`ci-workflows.md` pwsh exit-code pattern** | N/A | No `run:` step was added or modified. |
| **`modified-workflow-needs-green-run`** | FAIL (Blocking, awaiting_ci) | The recorded green run 37717224700 is on `8a1b9b8b`. The branch head is `9686d975`. See B-1. |

---

## 4. Language-Specific Unit Test Policy Compliance

### Section 4B: PowerShell Unit Test Policy Compliance

#### 4B.1 Framework and Scope

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Use Pester v5.x** | PASS | `Describe`, `BeforeAll`, `It`, and `Should -Contain` / `-BeExactly` / `-BeGreaterThan`. |
| **Use PoshQC Configuration** | PASS | The CI poshqc job runs `Invoke-PoshQCTest -Root` with `pester.runsettings.psd1` (`.github/workflows/_poshqc.yml:42`). |
| **PowerShell 5.1 & 7.6+ Compatible** | PASS | See 3B.1. |

#### 4B.2 Test Style and Structure

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Focused Unit Tests** | PASS | Two tests, one invariant each. |
| **Test Behavior Over Implementation** | PASS | Asserts the parsed branch-filter semantics rather than raw line text. |
| **Mocking Used Sparingly** | PASS | No mocks. |
| **Organization** | PASS | Test file: `tests/scripts/workflows/CiWorkflow.Tests.ps1`. Subject: `.github/workflows/ci.yml`. A literal mirror (`tests/.github/workflows/`) is not discovered by the Pester runner. The issue #526 location rule and three precedent suites place workflow tests under `tests/scripts/workflows/`. |

#### 4B.3 Naming and Readability

| Requirement | Status | Evidence |
|------------|--------|----------|
| **File Naming** - *.Tests.ps1 | PASS | `CiWorkflow.Tests.ps1` |
| **Describe/Context/It Structure** | PASS | 1 Describe, 0 Context, 2 It. |
| **Logical Grouping** | PASS | A single Describe for the `ci.yml` trigger block. |
| **Docstrings/Comments** | PASS | See 1.3. |

#### 4B.4 Running the Toolchain

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Use PoshQCTest Command** | PASS | CI step `Invoke-PoshQCTest`. Local runs used MCP `run_poshqc_test` per `.claude/rules/powershell.md:18`. |
| **No Alternative Test Runners** | PASS | Pester only. |

---

## 5. Test Coverage Detail

### ci.yml workflow triggers (2 tests)

| Test Name | Scenario Type | Lines Covered | Status |
|-----------|--------------|---------------|--------|
| lists main, development, and epic/** in the pull_request branch filter | Positive (fixed file) and Negative (pre-fix file fails) | `ci.yml` lines 6-7 | PASS (fails on pre-fix `632fe595`, passes on `8a1b9b8b`) |
| keeps the push branch filter exactly main and development | Positive / regression guard | `ci.yml` lines 4-5 | PASS on both heads |

**Coverage:** Not applicable as a percentage. The subject is a YAML file, and the suite is test code excluded from the coverage denominator.

**Not covered:** The helper's dash-item block-list branch (test file lines 116-124) and its single-quote stripping are not exercised by the current flow-form `ci.yml`. This is test-support code, and the omission is recorded as code-review Nit CR-5.

---

## 6. Test Execution Metrics

| Metric | Value | Status |
|--------|-------|--------|
| Total Tests (CI Pester, repo-wide) | 6531 (6521 passed + 10 skipped) | PASS |
| Tests Passed | 6521 | PASS |
| Tests Failed | 0 | PASS |
| New suite tests | 2 | PASS |
| New suite execution time | 40ms (5ms discovery, 18ms run) | PASS |
| Python consumer suites (this review) | 39 passed in 0.31s | PASS |
| Test File Size | 174 lines | PASS |
| PowerShell command coverage (repo-wide, informational) | 84.32% (baseline and post-change) | PASS (no regression) |

---

## 7. Code Quality Checks

**For PowerShell:**

| Check | Command | Result | Status |
|-------|---------|--------|--------|
| Invoke-Formatter | CI `Invoke-PoshQCFormat -Root` (job 113116383126) | `Already formatted: ...CiWorkflow.Tests.ps1` | PASS |
| PSScriptAnalyzer | CI `Invoke-PoshQCAnalyze -Root` (job 113116383126) | `PSScriptAnalyzer passed: no findings` | PASS |
| Pester Tests | CI `Invoke-PoshQCTest -Root` (job 113116383126) | `Tests Passed: 6521, Failed: 0` | PASS |

**For GitHub Actions YAML:**

| Check | Command | Result | Status |
|-------|---------|--------|--------|
| actionlint | `actionlint .github/workflows/ci.yml` | exit 0, no output | PASS |

**For Python (consumer contract suites; no Python changed):**

| Check | Command | Result | Status |
|-------|---------|--------|--------|
| Pytest | `poetry run pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py tests/scripts/dev_tools/test_epic_bounded_child_return_contract.py tests/scripts/dev_tools/test_claude_rules_frontmatter.py tests/scripts/dev_tools/test_push_down_codex_and_agents_customizations.py -q -p no:cacheprovider` | 39 passed | PASS |

**Notes:**
- PowerShell gates were not run locally by this review. Operator decision 2026-10-01 (Option A, `evidence/other/pwsh-task-classification.2026-10-07T16-15.md`) forbids local PowerShell routes in agent worktrees. CI job 113116383126 is the operative evidence. This review cannot run `gh run view`, so it assessed the CI citations for internal consistency (Section 8).
- The local file `artifacts/pester/powershell-coverage.xml` was generated before `CiWorkflow.Tests.ps1` existed. Its JUnit companion lists 21 tests from three suites, and it reports 0 covered lines from a `tests/scripts/workflows`-scoped run. It is stale for this head and was not used for any verdict.

---

## 8. Gaps and Exceptions

### Identified Gaps

- **B-1 (Blocking, Remediability: awaiting_ci): `modified-workflow-needs-green-run` / AC-7.** The branch modifies `.github/workflows/ci.yml` and `.github/workflows/README.md`. The only recorded green CI run is 37717224700, on `8a1b9b8b66f4bb65ef0a5e3e1d0d883246d739f7` (event `workflow_dispatch`). The current branch head is `9686d975d85250814aba7e149ee6ac0cfeda562a`. `git diff --name-only 8a1b9b8b HEAD` lists only feature-folder documents, so the residual risk is low. However, the rule requires a head-SHA match, and AC-7 requires verification "at PR time". Resolution: a CI run on the final PR head that concludes `success`, recorded with run id, head SHA, and conclusion. A `pull_request` run into `main` or a `workflow_dispatch` run qualifies. AC-7 is already checked in `issue.md` and is evaluated PARTIAL; see the feature audit.
- **N-1 (Non-blocking): S9 epic-child rule is prose-only.** `.claude/lib/ci-gate/Invoke-CiGateParser.ps1` lines 22-23 and 130-133 return `success` for an empty check set. A mechanical S9 run on an epic child with zero checks still produces `ci_gate.conclusion: success`. `issue.md` line 28 excludes parser changes, so this does not block the branch. See code-review CR-1.
- **N-2 (Non-blocking): evidence timestamps are not host-clock capture times.** `evidence-and-timestamp-conventions/SKILL.md` line 49 requires local host-clock time that is never composed. Artifacts stamped `2026-10-07T22-30` through `22-40` are contained in commit `00798863` (committed 22:16 EDT). Artifacts stamped `22-45` and `22-48` are contained in `8a1b9b8b` (committed 22:17 EDT). Both sets postdate the commits that contain them. The Phase 2 artifacts use `2026-10-08T02-30 (UTC)` rather than local time. Run IDs and SHAs remain consistent, so substantive verification is unaffected.
- **N-3 (Non-blocking): plan tasks [P2-T17] and [P2-T18] are checked although their literal acceptance conditions are not met.** The conditions were `Status: deferred-to-pr-time` with the `[ ] AC-7:` count `1`, and `CheckedCount` `6`. Both are consequences of DEV-AC7-EARLY and are resolved together with B-1.
- **N-4 (Non-blocking): PowerShell repo-wide line-coverage figure is absent from the evidence.** The CI headline reports command coverage (84.32%), which `.claude/rules/powershell.md:64` designates as informational. The line counter from the CI JaCoCo report was not cited. The branch adds no production PowerShell, and the analyzed-command counts are identical across runs, so this branch cannot have changed the figure. Future CI-derived coverage evidence should cite the JaCoCo `LINE` counter.
- **N-5 (Non-blocking): the `epic/**` trigger has not yet been exercised by a real `pull_request` event into an `epic/**` branch.** The issue's optional integration scenario was not run. The first epic child PR after merge will exercise it.
- **N-6 (Non-blocking): the branch is behind `origin/main` by PR #835.** The trial merge is clean and no changed path overlaps. Repository practice is to update the branch from `main` before opening the PR.
- **N-7 (Non-blocking): PR-context artifacts `artifacts/pr_context.summary.txt` and `artifacts/pr_context.appendix.txt` are absent.** They were not regenerated because the caller restricted writes to the feature folder. This review read the full branch diff directly with `git diff origin/main...HEAD`.

### Approved Exceptions (deviation register assessment)

| Deviation | Judgment | Classification | Basis |
|---|---|---|---|
| DEV-PWSH-ROUTE | Acceptable | Non-blocking | A binding operator decision (2026-10-01, Option A) withdrew the plan's `sh`-wrapper route. The substitute route runs the same PoshQC functions over a superset scope on the CI runner, and every cited value carries a run id, job id, head SHA, and log line. |
| DEV-CI-BASELINE | Acceptable | Non-blocking | The baseline run 37645267440 is on `08ee030d`. This review confirmed that the branch at Phase 0 (`97008102`) differs from `08ee030d` only in feature-folder documents. The full-repository arithmetic is internally consistent: 6519/0 baseline, 6520/1 fail-before, 6521/0 pass-after. |
| DEV-CI-FAILBEFORE | Acceptable | Non-blocking | Run 37715960709 is on `632fe595`. `git show --stat 632fe595` shows that commit adds the test and does not touch `ci.yml`. The only `[-]` line names the `pull_request` test. The failure location `CiWorkflow.Tests.ps1:161` matches the `Should -Contain 'epic/**'` line. The `push` test pass is derived soundly from the +1 passed and +1 failed delta. |
| DEV-CI-PASSAFTER | Acceptable | Non-blocking | Run 37717224700 is on `8a1b9b8b`, whose parent is fix commit `00798863`. The CI log shows the per-file `[+]` line, zero `[-]` lines, and counts of 6521 = 6519 + 2. At Normal verbosity the CI log prints per-file `[+]` lines, so per-test `[+]` lines are not produced. The substance of the check is met. |
| DEV-CI-FINALQC | Acceptable | Non-blocking | Format, analyze, and test literals come from one CI job on one head. The analyzer prints the checkout root instead of `.`, which differs from the plan literal in form only. |
| DEV-ACTIONLINT-DIRECT | Acceptable | Non-blocking | This review reproduced the direct-binary run at head `9686d975`: actionlint 1.7.11, exit 0, no output. The cited wrapper source lines show the wrapper resolves the same PATH binary and passes arguments through unchanged. The wrapper-only literal `Running actionlint...` remains an optional operator confirmation and does not affect the AC-5 criterion. |
| DEV-NONPS-COPY | Acceptable | Non-blocking | Byte identity is the requirement, and the tool used is incidental. This review reproduced `cmp` exit 0 and the 14-test bundle-parity pass. |
| DEV-MERGE-ADAPT | Acceptable | Non-blocking | The plan located insertion points by content. The paragraph sits at `orchestrate/SKILL.md` line 291, between step 2 (line 289) and step 3 (line 293), as the plan intended. The additional pre-existing suite `PoshQcWorkflow.Tests.ps1` came from `main` (#743). |
| DEV-AC7-EARLY | Not acceptable as full satisfaction | Blocking (B-1, awaiting_ci) | The recorded run is on `8a1b9b8b`, not the current head `9686d975`. AC-7 specifies verification at PR time against the fix branch head, and `modified-workflow-needs-green-run` requires a head-SHA match. Resolution needs only a green CI run on the final head. |

### Removed/Skipped Tests

**None.** Both planned tests were implemented. No test is skipped. The 10 repo-wide skipped tests are pre-existing (the baseline run shows the same count).

---

## 9. Summary of Changes

### Commits in This PR/Branch

1. **b92ce7e4** - docs(658): create active feature folder for epic-child-prs-trigger-no-ci
2. **b1267974** - docs(658): record research for epic child PR CI trigger gap
3. **2869d149** - docs(658): add acceptance criteria to issue.md
4. **043365da** - docs(658): add minimal-audit atomic plan
5. **d157a50b** - docs(658): revise plan per preflight round 1
6. **305ffdfa** - Merge remote-tracking branch 'origin/main' into bug/epic-child-prs-trigger-no-ci-658
7. **91294fae** - docs(658): classify PowerShell plan tasks per operator Option A
8. **97008102** - docs(658): record Phase 0 baseline evidence
9. **632fe595** - test(658): add ci.yml trigger regression suite
10. **00798863** - fix(658): run CI for epic child PRs into epic/** integration branches
11. **8a1b9b8b** - docs(658): record local final-QC evidence
12. **9686d975** - docs(658): record final QC evidence and check off acceptance criteria

### Files Modified

1. **.github/workflows/ci.yml** (MODIFIED) - line 7 now reads `branches: [main, development, "epic/**"]`; line 5 (`push`) is unchanged.
2. **.github/workflows/README.md** (MODIFIED) - new `## Triggers` section (lines 8-16).
3. **.claude/skills/orchestrate/SKILL.md** (MODIFIED) - S9 epic-child rule paragraph at line 291.
4. **extensions/drm-copilot/resources/claude-customizations/.claude/skills/orchestrate/SKILL.md** (MODIFIED) - byte mirror of item 3.
5. **tests/scripts/workflows/CiWorkflow.Tests.ps1** (NEW) - Pester 5 trigger-invariant suite.
6. **docs/features/active/2026-09-08-epic-child-prs-trigger-no-ci-658/** (NEW/MODIFIED) - issue, plan, research, and 44 evidence files.

---

## 10. Compliance Verdict

### Overall Status: PARTIALLY COMPLIANT

Code, test, documentation, toolchain, coverage, and evidence-location requirements are met. One Blocking item remains: B-1, `modified-workflow-needs-green-run`, classified awaiting_ci. It is resolved by a green CI run on the final PR head and needs no code change. Findings N-1 through N-7 are Non-blocking.

---

### Policy-by-Policy Summary

#### General Code Change Policy (Section 2)
- PASS Before Making Changes: plan and policy reading recorded.
- PASS Design Principles: minimal one-line trigger change.
- PASS Module & File Structure: all files within limits.
- PASS Naming, Docs, Comments: descriptive names and rationale comments.
- PASS Toolchain Execution: single-pass final loop via CI evidence.
- PASS Summarize & Document: README trigger documentation added.

#### Language-Specific Code Change Policy (Section 3)

**For PowerShell:**
- PASS Tooling & Baseline
- PASS PowerShell Design & Safety
- PASS Structure & Naming
- PASS Toolchain

**For GitHub Actions:**
- PASS actionlint
- FAIL modified-workflow-needs-green-run at the current head (B-1, awaiting_ci)

#### General Unit Test Policy (Section 1)
- PASS Core Principles
- PASS Coverage & Scenarios (no regression; no production PowerShell changed)
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

- PASS 6521/6521 non-skipped Pester tests passing in CI (0 failed)
- PASS 2/2 new trigger-invariant tests passing on the fixed `ci.yml`; 1/2 failing on the pre-fix `ci.yml`, as designed
- PASS PowerShell command coverage 84.32% to 84.32% (no regression; informational metric)
- PASS 39/39 Python consumer contract tests (this review)
- PASS actionlint 0 findings (this review)
- FAIL green CI run at the current branch head not yet recorded (B-1)

---

### Recommendation

**Blocked (awaiting CI)**

Open or refresh the PR to `main`, optionally after updating the branch from `origin/main` (N-6), and record the CI run whose head SHA equals the final PR head with conclusion `success` (run id, head SHA, conclusion). Once that record exists, B-1 is resolved and AC-7 can be re-evaluated as PASS. File a follow-up issue for N-1, a parser-level non-empty or required-workflow guard.

---

## Appendix A: Test Inventory

### Complete Test List

1. ci.yml workflow triggers > lists main, development, and epic/** in the pull_request branch filter
2. ci.yml workflow triggers > keeps the push branch filter exactly main and development

---

## Appendix B: Toolchain Commands Reference

Commands run by this review (check-only, worktree root):

```bash
git diff --stat origin/main...HEAD
git log --oneline origin/main..HEAD
git diff --name-only 8a1b9b8b HEAD
git diff --name-only 08ee030d 97008102
git log --oneline 08ee030d..origin/main
git diff --stat 08ee030d origin/main -- .github/workflows .claude/skills/orchestrate extensions/drm-copilot/resources/claude-customizations/.claude/skills/orchestrate tests/scripts/workflows
git merge-tree --write-tree --name-only HEAD origin/main
git log --format='%h %ad %cd %s' --date=iso-strict origin/main..HEAD
actionlint .github/workflows/ci.yml
cmp .claude/skills/orchestrate/SKILL.md extensions/drm-copilot/resources/claude-customizations/.claude/skills/orchestrate/SKILL.md
wc -l tests/scripts/workflows/CiWorkflow.Tests.ps1 .claude/skills/orchestrate/SKILL.md
poetry run pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py tests/scripts/dev_tools/test_epic_bounded_child_return_contract.py tests/scripts/dev_tools/test_claude_rules_frontmatter.py tests/scripts/dev_tools/test_push_down_codex_and_agents_customizations.py -q -p no:cacheprovider
poetry run python scripts/dev_tools/validate_evidence_locations.py --root .
```

PowerShell gates (evidence source: CI job 113116383126 on `8a1b9b8b`; not run locally per operator Option A):

```powershell
Import-Module ./scripts/powershell/PoshQC; Invoke-PoshQCFormat -Root .
Import-Module ./scripts/powershell/PoshQC; Invoke-PoshQCAnalyze -Root .
Import-Module ./scripts/powershell/PoshQC; Invoke-PoshQCTest -Root .
```

---

**Audit Completed By:** feature-review agent (pass 1)
**Audit Date:** 2026-10-08
**Policy Version:** Current (as of audit date)
