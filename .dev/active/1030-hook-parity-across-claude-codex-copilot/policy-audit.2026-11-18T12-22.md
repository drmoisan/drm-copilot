# Policy Compliance Audit: Hook parity across Claude Code, Codex and Copilot (Issue #1030)

**Audit Date:** 2026-11-18  
**Code Under Test:** merge base `2d487f5b070b401a6d14271a039b1207a6e0383f` of the base branch `origin/epic/shared-agent-harness-layer-integration` and reviewed head `f9f358e9055db7b2b4ca7ce8d7d33ca1ebf67691`; the diff between them lists 61 changed files (21 outside the feature folder: 9 added, 12 modified)

**Coverage Metrics by Language:**

| Language | Files Changed | Tests | Test Result | Baseline Coverage | Post-Change Coverage | New Code Coverage |
|----------|--------------|-------|-------------|-------------------|---------------------|-------------------|
| PowerShell | 3 production files added (plus 2 byte-identical bundle copies), 5 test files added, 5 test files and helpers modified | 29212 Pester tests (repository) | ✅ 29194 pass, 0 fail, 18 skipped | 96.76% lines (repository, 47042 / 48615) | 96.77% lines (repository, 47184 / 48759) | 142 of 144 lines in the three new production files (98.61%) |
| Python | 0 files | 17122 pytest tests run as regression | ✅ 17122 pass, 0 fail, 6 skipped | 98.00% lines, 95.46% branches | 98.00% lines, 95.46% branches | N/A (no Python file changed) |
| TypeScript | 0 files | Jest run as regression in the phase gate | ✅ 5915 pass (root), 5898 pass (extension) | N/A | N/A | N/A |
| C# | 0 files | N/A | N/A | N/A | N/A | N/A |
| Bash | 0 files | N/A | N/A | N/A | N/A | N/A |

Data and configuration files changed by the branch (not coverage languages): `config/harness-parity-matrix.json`, `pack-manifests/core.json` and `scripts/harness-generation/sources/rules/orchestrator-state.json` (exercised by the Pester repository gates and the pytest manifest contract tests, 0 failures), and `.codex/config.toml` root and bundle (exercised by `legacy-codex-hook-contracts.Tests.ps1` and `codex-bundle-hook-probe.Tests.ps1`, 0 failures). PowerShell coverage verdict: PASS.

### Coverage Evidence Checklist

- TypeScript baseline coverage artifact: N/A - zero changed TypeScript files (Jest ran as regression only in `evidence/qa-gates/phase-gate.P1.2026-11-18T12-00.md`)
- TypeScript post-change coverage artifact: N/A - zero changed TypeScript files; `coverage/lcov.info` is absent and not required
- PowerShell baseline coverage artifact: `evidence/baseline/pester-baseline.2026-11-18T08-34.md`
- PowerShell post-change coverage artifact: `artifacts/pester/powershell-coverage.xml` (JaCoCo; session start 1795003292698 ms, the run recorded in `evidence/regression-testing/pester-gate.2026-11-18T12-14.md`), re-parsed per file by this review
- Python baseline coverage artifact: `evidence/baseline/pytest-baseline.2026-11-18T08-34.md`
- Python post-change coverage artifact: `evidence/regression-testing/pytest-gate.2026-11-18T11-17.md` and `artifacts/python/lcov.info` (regression only; no Python file changed)
- Per-language comparison summary: section 1.2.1 and `evidence/qa-gates/pester-coverage.2026-11-18T11-16.md`

Evidence paths beginning `evidence/` are relative to `docs/features/active/2026-10-30-hook-parity-across-claude-codex-copilot-1030/`.

---

## Executive Summary

The branch records a parity-matrix disposition and parity group for each of the 96 `hook-registration` entries (61 Claude, 31 Codex, 4 Copilot; all `native`, all `provisional` with `decision_ref` `#1030:hook-parity-dispositions.md`), adds the child 5 disposition record, adds the pure rule module `scripts/harness/HarnessHookParity.psm1` with a repository gate (rules H1 to H5 and in-memory negative cases), ports the Claude pr-author SubagentStop validator to Codex with a twin of `subagentstop-envelope.ps1` and one `[[hooks.SubagentStop]]` registration (root and bundle, byte-identical), pins cross-tree helper identity, extends the no-Python scan to `.github/hooks`, and corrects the harness generator source for the orchestrator-state rule (drift inherited from a main sync). The Codex feature-folder-order port is deferred under the recorded decision AD-8.

Coverage was verified by re-parsing `artifacts/pester/powershell-coverage.xml`: the three new production files are at 96.67%, 100% and 100% line coverage, and the repository total rose from 96.76% to 96.77%. No blocking finding was identified. Two spec criteria and two user-story criteria depend on CI on the PR head and are pending-CI.

Coverage thresholds: the root `CLAUDE.md` on the branch head states no line or branch threshold, so the defaults govern: 85% line for every coverage language and 75% branch for branch-capable languages; PowerShell is line-only.

**Policy documents evaluated:**
- ✅ `.claude/rules/general-code-change.md`
- ✅ `.claude/rules/general-unit-test.md`
- ✅ `.claude/rules/quality-tiers.md` (`quality-tiers.yml` exists; `.codex/hooks` and `scripts/harness` are classified; no new project)

**Language-specific policies evaluated:**
- ✅ `.claude/rules/powershell.md`
- N/A Python: no Python file changed (regression gate only)
- N/A TypeScript: no TypeScript file changed (regression gate only)
- N/A C#, Bash: no file changed
- ✅ JSON and TOML: data files exercised by repository gates and contract tests

**Temporary artifacts cleanup:**
- ✅ No temporary script is committed; executor launchers stayed under `SCRATCH`, and the working tree was clean at the reviewed head.
- ✅ No committed tooling was added outside `scripts/harness/`.

---

## Rejected Scope Narrowing

No scope narrowing was attempted. The delegation states that the CI-dependent criteria are pending-CI because no PR exists; this review records them as UNVERIFIED (pending-CI) and audits the full branch diff against the resolved base `epic/shared-agent-harness-layer-integration`.

## Evidence Location Compliance

`env -u VIRTUAL_ENV poetry run python scripts/dev_tools/validate_evidence_locations.py --root .` exited 0. The branch diff adds no file under `artifacts/baselines/`, `artifacts/qa/`, `artifacts/evidence/` or `artifacts/coverage/` (`git diff --name-only <MB>..HEAD` filtered for those prefixes returned no path). All feature evidence is under `<FEATURE>/evidence/{baseline,other,qa-gates,regression-testing}/`. Result: PASS.

## Owner Directive Decisions

- `OWNER-DIRECTIVE-DECISION: OD-1 | scheduling | honored | 2026-11-18T12:18:47Z | The review runs to completion without pausing for owner decisions; ambiguities are resolved with the recommended option and recorded in the audit artifacts.`
- `OWNER-DIRECTIVE-DECISION: OD-2 | merge_timing | refused | 2026-11-18T12:18:47Z | Outside the feature-review scope: this reviewer performs no merge; the squash merge after green CI belongs to the item orchestrator.`
- `OWNER-DIRECTIVE-DECISION: OD-3 | merge_timing | refused | 2026-11-18T12:18:47Z | Outside the feature-review scope: this reviewer deletes no branch; post-merge branch deletion belongs to the item orchestrator.`
- `OWNER-DIRECTIVE-DECISION: OD-4 | scheduling | honored | 2026-11-18T12:18:47Z | Findings are classified with the cost-benefit rule: only defects with a concrete correctness or policy impact are blocking; the rest are recorded as non-blocking observations.`

## Documentation Surface Check

`docs/documentation-estate/docs-profile.json` is absent on the branch head; the check is not applicable and produces no finding.

## Additional Policy Rules

- `modified-workflow-needs-green-run`: the branch diff changes no path under `.github/workflows/`, `scripts/benchmarks/` or `.github/actions/` (`git diff --name-only <MB>..HEAD -- .github/workflows scripts/benchmarks .github/actions` is empty). Not triggered.
- Process-reduction ledger: `docs/engineering/process-reductions/` exists; the branch diff changes no path in it and makes no evidence, plan-task, gate or review-process reduction. The AD-8 deferral narrows product scope (a port), not process; it is recorded in `spec.md` `## Decisions`. PASS.
- File size: no covered file in the branch diff is at or above 700 logical lines (largest `tests/scripts/claude-runtime/enforcement-hooks-no-python-invocation.Tests.ps1`, 609); `config/file-size-baseline.json` is unchanged. PASS.
- Tier classification: `quality-tiers.yml` exists on the base; the paths of the new production files (`.codex/hooks`, `scripts/harness`) are already classified. PASS.
- Coverage exclusion: no coverage configuration file changed. PASS.

---

## 1. General Unit Test Policy Compliance

### 1.1 Core Principles

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Independence** - Tests run in any order | ✅ PASS | The eight-shard `Invoke-PoshQCParallelTest` run passed with 0 failures; suites build in-memory payloads and entries per `It`. |
| **Isolation** - Each test targets single behavior | ✅ PASS | One behavior per `It`, for example `fails for a Claude group with no Codex member and no gap class`. |
| **Fast Execution** - Tests complete quickly | ✅ PASS | Repository Pester run 760.85 s across 8 shards; the new suites add 180 tests. |
| **Determinism** - Consistent results | ✅ PASS | No clock, network, sleep or temporary file in the new suites (search for `TestDrive`, `New-TemporaryFile`, `GetTempPath`, `Start-Sleep` returned no match). Child-process cases pass stdin explicitly. |
| **Readability & Maintainability** - Clear structure | ✅ PASS | Header comment per suite; descriptive `It` names. |

### 1.2 Coverage and Scenarios

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Baseline Coverage Documented** | ✅ PASS | **Baseline:** Pester 96.76% lines; pytest 98.00% lines, 95.46% branches<br>**Command:** one `Invoke-PoshQCParallelTest`, one `pytest -n auto`<br>**Artifact:** `evidence/baseline/pester-baseline.2026-11-18T08-34.md`, `evidence/baseline/pytest-baseline.2026-11-18T08-34.md`<br>**Timestamp:** 2026-11-18 08:34 UTC |
| **No Coverage Regression** | ✅ PASS | **Post-change coverage:** Pester 96.77%; `.codex/hooks` aggregate 98.07% (unchanged); pytest 98.00% / 95.46%<br>**Change:** +0.01; 0.00; 0.00 / 0.00<br>**Status:** No regression. No existing production file changed, so no changed-line regression applies. |
| **Changed Files Meet Thresholds** | ✅ PASS | **Thresholds:** 85% line (defaults; root `CLAUDE.md` states none; PowerShell line-only).<br>**Status:** All new production files meet the threshold; see 1.2.1. |
| **New Code Coverage ≥90%** | ✅ PASS | **New files:** `.codex/hooks/subagentstop-envelope.ps1` 58/60, `.codex/hooks/validate-pr-author-output.ps1` 41/41, `scripts/harness/HarnessHookParity.psm1` 43/43<br>**New code coverage:** 142/144 = 98.61%<br>**Calculation method:** per-file `LINE` counters of `artifacts/pester/powershell-coverage.xml`, re-parsed by this review. |
| **Comprehensive Coverage** | ✅ PASS | Every function of the three files is exercised; the two uncovered lines are the stdin read and its `catch` in `Read-SubagentStopEnvelope`, which the Codex hook does not take because it reads stdin itself and passes `-InputText`. |
| **Positive Flows** - Valid inputs | ✅ PASS | Allow cases for a PR URL, `PR #<n>`, `gh pr create` and `gh pr edit` with a number; committed matrix has no H1 to H5 violation. |
| **Negative Flows** - Invalid inputs | ✅ PASS | Blank message, no PR reference, empty payload, malformed JSON; H1 and H2 in-memory negative entries. |
| **Edge Cases** - Boundary conditions | ✅ PASS | `gh pr create` without a number; recognized gap prefix with a blank reason returns `INVALID`; names containing `/`. |
| **Error Handling** - Error paths | ✅ PASS | Dependency-load failure and validator exception both fail closed with exit 2 and `PR_AUTHOR_OUTPUT_MISSING:` (`hook-dependency-failure.Codex.Tests.ps1` row added). |
| **Concurrency** - If applicable | N/A | Hooks are single-process and hold no shared state. |
| **State Transitions** - If applicable | ✅ PASS | One-continuation: a failed stop exits 2 when `stop_hook_active` is unset and 0 when it is set. |

### 1.2.1 Per-Language Coverage Comparison

- PowerShell: Baseline: 96.76% lines (from the `Phase 0 baseline` artifact) -> Post-change: 96.77% lines. Change: +0.01% lines. New/changed-code coverage: 98.61% lines. Disposition: PASS. Evidence: `artifacts/pester/powershell-coverage.xml`, `evidence/baseline/pester-baseline.2026-11-18T08-34.md`.
- Python: no changed files; regression gate only. Baseline: 98.00% lines, 95.46% branches -> Post-change: 98.00% lines, 95.46% branches. Change: 0.00. Disposition: N/A (zero changed Python files). Evidence: `evidence/regression-testing/pytest-gate.2026-11-18T11-17.md`.
- TypeScript, C#, Bash: zero changed files. Disposition: N/A.

Per-file detail (line; Pester measures no branch figure):

- `.codex/hooks/subagentstop-envelope.ps1` (new): Baseline: N/A - no pre-change run -> Post-change: 96.67%. Change: N/A. PASS.
- `.codex/hooks/validate-pr-author-output.ps1` (new): Baseline: N/A - no pre-change run -> Post-change: 100.00%. Change: N/A. PASS.
- `scripts/harness/HarnessHookParity.psm1` (new): Baseline: N/A - no pre-change run -> Post-change: 100.00%. Change: N/A. PASS.
- Bundle copies under `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/` are byte-identical to the roots (`cmp` exit 0) and are not separately measured.

### 1.3 Test Structure and Diagnostics

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Clear Failure Messages** | ✅ PASS | The repository gate prints every violation message in `-Because`; group-membership cases name the group and ecosystem. |
| **Arrange-Act-Assert Pattern** | ✅ PASS | Payload or entry construction, call, then `Should` in each `It`. |
| **Document Intent** | ✅ PASS | Header comment per suite naming the issue and scope. |

### 1.4 External Dependencies and Environment

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Avoid External Dependencies** | ✅ PASS | Unit suites use in-memory payloads. The repository gates read committed files read-only by design. Child-process cases start the current `pwsh` executable only. |
| **Use Mocks/Stubs** | ✅ PASS | Console stdin and stderr are redirected through `[System.Console]` and restored in `finally`. |
| **Environment Stability** | ✅ PASS | No temporary file and no environment variable read in the new suites. |

### 1.5 Policy Audit Requirement

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Pre-submission Review** | ✅ PASS | This audit; executor self-review `evidence/qa-gates/self-review.2026-11-18T12-15.md` (no FAIL row). |

---

## 2. General Code Change Policy Compliance

### 2.1 Before Making Changes

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Clarify the objective** | ✅ PASS | Issue #1030, `spec.md` v0.4 (AD-1 to AD-6, AD-8), `user-story.md` v0.4. |
| **Read existing change plans** | ✅ PASS | `plan.2026-10-30T18-37.md` v2.1, `remediation-plan.2026-11-18T11-23.md`, preflight records under `evidence/other/`. |
| **Document the plan** | ✅ PASS | All plan tasks checked except `[P3-T5]`, which is orchestrator-owned at S9; all remediation-plan tasks checked. |

### 2.2 Design Principles

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Simplicity first** | ✅ PASS | `HarnessHookParity.psm1` is three exported pure functions over entries; the Codex hook adds one decision function over the twin functions. |
| **Reusability** | ✅ PASS | Twin functions are text-identical to the Claude source and pinned by test; the envelope helper is shared by the Codex hook. |
| **Extensibility** | ✅ PASS | Gap prefixes are a single ordered table; the deferred stem set and decision reference are parameters. |
| **Separation of concerns** | ✅ PASS | The rule module reads no file; the repository gate loads the matrix through child 1's `Import-HarnessParityMatrix`. |

### 2.3 Module & File Structure

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Cohesive modules** | ✅ PASS | One rule module in child 1's `scripts/harness/`; Codex hook files under `.codex/hooks/`. |
| **At or below the 800-line hard limit** | ✅ PASS | Largest covered file 609 logical lines (`enforcement-hooks-no-python-invocation.Tests.ps1`, modified); largest new production file 194 lines. No covered file at or above 700 lines; `config/file-size-baseline.json` unchanged. Codex hooks pinned at the 500-line cap: the new hooks are 194 and 158 lines; no file at or above 490 lines at Phase 0 was edited. |
| **Public vs internal** | ✅ PASS | Explicit `Export-ModuleMember` list; `Get-HarnessHookEntryField` stays internal. |
| **No circular dependencies** | ✅ PASS | The rule module imports nothing; the hook dot-sources two sibling helpers. |

### 2.4 Naming, Docs, and Comments

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Descriptive names** | ✅ PASS | Approved verbs; `Harness`/`Codex` noun prefixes. |
| **Docs/docstrings** | ✅ PASS | Comment-based help on every function; module header lists rules H1 to H5. |
| **Comment why, not what** | ✅ PASS | For example the one-continuation comment in `Get-CodexPrAuthorStopDecision`. |

### 2.5 After Making Changes - Toolchain Execution

| Requirement | Status | Evidence |
|------------|--------|----------|
| **1. Formatting** | ✅ PASS | **Command:** `Invoke-PoshQCFormat` with a non-writing seam and SHA256 lists before and after over the 15 changed PowerShell files<br>**Result:** 0 files would change (`evidence/qa-gates/final-static.2026-11-18T12-01.md`). |
| **2. Linting** | ✅ PASS | **Command:** `Invoke-ScriptAnalyzer -Settings scripts/powershell/PoshQC/settings/pssa.settings.psd1`<br>**Result:** 0 findings. |
| **3. Type checking** | N/A | Not applicable to PowerShell; no Python or TypeScript file changed (repository `pyright` and `tsc` exit 0 in `phase-gate.P1.2026-11-18T12-00.md`). |
| **4. Testing** | ✅ PASS | **Command:** one `Invoke-PoshQCParallelTest`, one `pytest -n auto`, Jest<br>**Result:** 0 failures (`phase-gate.P1.2026-11-18T12-00.md`, `pester-gate.2026-11-18T12-14.md`). |
| **Full toolchain loop** | ✅ PASS | Stages 1 to 6 recorded clean after the generator-source correction; stage 7 (integration lane, including `codex-pretooluse-integration.Tests.ps1`) runs in CI per the recorded deviation `evidence/other/deviation-integration-lane.2026-11-18T09-10.md`. |
| **Explicit reporting** | ✅ PASS | Commands and exit codes recorded in each evidence record. |

### 2.6 Summarize and Document

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Summarize changes** | ✅ PASS | Section 9. |
| **Design choices explained** | ✅ PASS | `spec.md` `## Decisions`; `hook-parity-dispositions.md`. |
| **Update supporting documents** | ✅ PASS | Child 5 disposition record (490 lines, one section per parity group); generator source for the orchestrator-state rule. |
| **Provide next steps** | ✅ PASS | CI-dependent criteria at S9; deferred ports owned by child 4 and issue #555. |

---

## 3. Language-Specific Code Change Policy Compliance

### Section 3B: PowerShell Code Change Policy Compliance

#### 3B.1 Tooling & Baseline

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Formatting with Invoke-Formatter** | ✅ PASS | **Command:** `Invoke-PoshQCFormat` over the 15 changed PowerShell files<br>**Result:** digest identical before and after. |
| **Linting with PSScriptAnalyzer** | ✅ PASS | **Command:** `Invoke-ScriptAnalyzer` with `pssa.settings.psd1`<br>**Result:** Error 0, Warning 0, Information 0, ParseError 0. |
| **Fix all findings** | ✅ PASS | No suppression added. |
| **PowerShell 5.1 & 7.6+ compatible** | ✅ PASS | Repository target is PowerShell 7+ per `.claude/rules/powershell.md`; the suites declare `#Requires -Version 7.0`. |

#### 3B.2 PowerShell Design & Safety

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Advanced functions** | ✅ PASS | `[CmdletBinding()]` and `[OutputType()]` on every function. |
| **Parameter validation** | ✅ PASS | `Mandatory`, `AllowNull`, `AllowEmptyString`, `AllowEmptyCollection` where applicable. |
| **Avoid global state** | ✅ PASS | The only script-scoped state is the read-only prefix table and the existing dependency-guard flag pattern. |
| **Error handling** | ✅ PASS | Fail-closed on dependency failure, payload anomaly and validator exception; no silent catch (the guarded loads record the failure). |

#### 3B.3 Structure, Naming, and Comments

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Cohesive and at or below the 800-line hard limit** | ✅ PASS | Largest new PowerShell production file 194 lines. |
| **Approved verbs** | ✅ PASS | PSSA approved-verb rule reports 0. |
| **Comment why** | ✅ PASS | Header comments state the event, fields and enforcement strength. |

#### 3B.4 Running the Toolchain

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Step 1: Format** | ✅ PASS | 0 changes. |
| **Step 2: Analyze** | ✅ PASS | 0 findings. |
| **Step 3: Type check** | N/A | Not applicable for PowerShell. |
| **Step 4: Test** | ✅ PASS | Parallel Pester, 0 failures. |
| **Rerun loop if needed** | ✅ PASS | Re-run after the generator-source correction (remediation plan `[P1-T3]`, `[P2-T1]`, `[P2-T2]`). |

### Section 3D: JSON Configuration Policy Compliance

#### 3D.1 JSON Tooling

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Formatting with jq** | ✅ PASS | **Command:** `env -u VIRTUAL_ENV poetry run python -m scripts.dev_tools.format_json --check <three changed JSON files>` (run by this review)<br>**Result:** `orchestrator-state.json` already formatted; `config/harness-parity-matrix.json` and `pack-manifests/core.json` report `would reformat`, and the same check on their merge-base versions reports `would reformat` too, so the layout is inherited and unchanged by the branch. No CI workflow runs `format_json`. Recorded as a non-blocking Info row in the code review. |
| **Schema validation** | ✅ PASS | `validate_json` could not fetch the remote schema in this environment (`getaddrinfo failed`); schema conformance is instead verified by `HarnessParityMatrix.RepoGate.Tests.ps1` through `Import-HarnessParityMatrix` (0 failures in the gate). |
| **Required $schema** | ✅ PASS | Unchanged `$schema` keys. |

#### 3D.2 JSON Structure

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Strict JSON only** | ✅ PASS | Files parse with `ConvertFrom-Json` (this review and the repository gates). |
| **Deterministic key order** | ✅ PASS | Matrix entries keep child 1's key layout; 96 hook entries, no duplicate `id`. |

TOML (no template section): `.codex/config.toml` root and bundle gain one `[[hooks.SubagentStop]]` table with matcher `pr-author`, `pwsh`-only `command` and `command_windows`, and `timeout = 30`, matching existing entries; 0 lines removed; dispatcher `timeout` unchanged; bundle byte-identical. Result: PASS.

---

## 4. Language-Specific Unit Test Policy Compliance

### Section 4B: PowerShell Unit Test Policy Compliance

#### 4B.1 Framework and Scope

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Use Pester v6.x** | ✅ PASS | `Describe`/`Context`/`It`, `-ForEach` data cases, `Should -BeExactly`. |
| **Use PoshQC Configuration** | ✅ PASS | **Command:** `Invoke-PoshQCParallelTest` through the launcher `pester` suite<br>**Config:** `scripts/powershell/PoshQC/settings/pester.runsettings.psd1` (unchanged). |
| **PowerShell 5.1 & 7.6+ Compatible** | ✅ PASS | PowerShell 7+ target per repository rule. |

#### 4B.2 Test Style and Structure

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Focused Unit Tests** | ✅ PASS | One behavior per `It`. |
| **Test Behavior Over Implementation** | ✅ PASS | Assertions on decisions, exit codes, stderr prefixes and matrix rule results. |
| **Mocking Used Sparingly** | ✅ PASS | No `Mock`; console redirection and in-memory payloads only. |
| **Organization** | ✅ PASS | **Test file:** `tests/scripts/harness/HarnessHookParity.Tests.ps1`, `tests/scripts/codex-hooks/codex-validate-pr-author-output.Tests.ps1`, `codex-subagentstop-envelope.Tests.ps1`<br>**Code file:** `scripts/harness/HarnessHookParity.psm1`, `.codex/hooks/*.ps1`<br>Structure follows the existing `codex-hooks` and `harness` test folders. |

#### 4B.3 Naming and Readability

| Requirement | Status | Evidence |
|------------|--------|----------|
| **File Naming** - *.Tests.ps1 | ✅ PASS | All five new suites. |
| **Describe/Context/It Structure** | ✅ PASS | One `Describe` per suite. |
| **Logical Grouping** | ✅ PASS | Contexts for twin rule, allow, block, continuation, entrypoint and registration. |
| **Docstrings/Comments** | ✅ PASS | Header comment per suite. |

#### 4B.4 Running the Toolchain

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Use PoshQCTest Command** | ✅ PASS | **Command:** `Invoke-PoshQCParallelTest`<br>**Result:** 29194 passed, 0 failed, 18 skipped. |
| **No Alternative Test Runners** | ✅ PASS | Launcher only; parallel-only (AD-6). |

---

## 5. Test Coverage Detail

### New and modified Pester suites

| Test Name | Scenario Type | Lines Covered | Status |
|-----------|--------------|---------------|--------|
| `codex-validate-pr-author-output.Tests.ps1` (twin rule, allow, block, continuation, entrypoint in-process and in child processes, registration in root and bundle) | Positive/Negative/Edge Case/Error Handling/State Transition | 41/41 (`validate-pr-author-output.ps1`) | ✅ |
| `codex-subagentstop-envelope.Tests.ps1` (envelope parsing and anomalies) | Positive/Negative/Edge Case | 58/60 (`subagentstop-envelope.ps1`) | ✅ |
| `cross-tree-helper-identity.Tests.ps1` (byte identity of the Phase 0 helper set) | Positive | n/a (identity pin) | ✅ |
| `HarnessHookParity.Tests.ps1` (stem, gap class, H1 to H5 unit cases) | Positive/Negative/Edge Case | 43/43 (`HarnessHookParity.psm1`) | ✅ |
| `HarnessHookParity.RepoGate.Tests.ps1` (committed matrix, C1/C2, DEFER stems, group membership, divergences, negative cases) | Positive/Negative | gate | ✅ |
| `enforcement-hooks-no-python-invocation.Tests.ps1` (three AC-15 cases for `.github/hooks`) | Positive | gate | ✅ |
| `legacy-codex-hook-contracts.Tests.ps1`, `hook-dependency-failure.Codex.Tests.ps1`, `codex-bundle-hook-probe.Tests.ps1` (expected lists extended) | Positive | gate | ✅ |

**Coverage:** 142 of 144 lines across the three new production files.

**Not covered:** the `[Console]::In.ReadToEnd()` read and its `catch` assignment in `Read-SubagentStopEnvelope`, kept text-identical to the Claude helper under the twin rule and not taken by the Codex hook.

---

## 6. Test Execution Metrics

| Metric | Value | Status |
|--------|-------|--------|
| Total Tests | Pester 29212, pytest 17128, Jest 5915 + 5898 | ✅ |
| Tests Passed | Pester 29194, pytest 17122, Jest 5915 + 5898 | ✅ |
| Tests Failed | 0 in every gate | ✅ |
| Execution Time | Pester 760.85 s (8 shards), pytest 169.25 s | ✅ Fast |
| Average Time per Test | not recorded per test | N/A |
| Discovery Time | not recorded | N/A |
| Functions/Classes Tested | all functions of the three new production files | ✅ |
| Test File Size | largest new suite 294 logical lines | ✅ PASS |
| Code Coverage (if applicable) | see 1.2.1 | ✅ |

---

## 7. Code Quality Checks

**For PowerShell:**

| Check | Command | Result | Status |
|-------|---------|--------|--------|
| Invoke-Formatter | `Invoke-PoshQCFormat` (non-writing seam, 15 files) | 0 would change | ✅ |
| PSScriptAnalyzer | `Invoke-ScriptAnalyzer` (PoshQC settings) | 0 findings | ✅ |
| Leak scan | `Invoke-PoshQCLeakScan` | 896 files, 0 failures | ✅ |
| Pester Tests | `Invoke-PoshQCParallelTest` | 29194 passed, 0 failed | ✅ |
| Codex agent variants generator | `poetry run python -m scripts.dev_tools.generate_codex_agent_variants --check` | exit 0 | ✅ |
| Harness generator | `Invoke-HarnessGeneration.ps1 -Surface all -Check` | exit 0, no drift | ✅ |

**For Python (regression only; no file changed):**

| Check | Command | Result | Status |
|-------|---------|--------|--------|
| Black Formatting | `poetry run black --check .` | 1071 files unchanged | ✅ |
| Ruff Linting | `poetry run ruff check .` | exit 0 | ✅ |
| Pyright Type Checking | `poetry run pyright` | 0 errors | ✅ |
| Pytest Tests | `poetry run pytest -n auto` | 17122 passed, 0 failed | ✅ |

**Notes:**
The 18 Pester skips equal the Phase 0 baseline. `git diff --check <MB>..HEAD` reports no whitespace error.

---

## CI Cross-check

No pull request exists for the branch at review time, so no CI run exists at the reviewed head; the outcomes below are claimed from local evidence for the orchestrator's comparison at S9.

| Check | Claimed outcome | Claimed figure | Head | Source |
|-------|-----------------|----------------|------|--------|
| poshqc / PowerShell QC (format, analyze, Pester) | pass | 0 format changes, 0 PSSA findings; 29194 passed, 0 failed; 96.77% lines | f9f358e9055db7b2b4ca7ce8d7d33ca1ebf67691 | `evidence/qa-gates/final-static.2026-11-18T12-01.md`, `evidence/regression-testing/pester-gate.2026-11-18T12-14.md` |
| poshqc / PowerShell hook suites (Linux) | pass | new `tests/scripts/codex-hooks` suites pass locally on Windows; Linux run pending CI (S-16, U-10) | f9f358e9055db7b2b4ca7ce8d7d33ca1ebf67691 | `evidence/regression-testing/pester-gate.2026-11-18T12-14.md` |
| quality-checks7 / Code Quality & Tests (3.13) (Enforce Python coverage thresholds) | pass | 98.00% lines, 95.46% branches (no Python file changed) | f9f358e9055db7b2b4ca7ce8d7d33ca1ebf67691 | `evidence/regression-testing/pytest-gate.2026-11-18T11-17.md` |
| Python format, lint, type (Black, Ruff, Pyright) | pass | 0 findings | f9f358e9055db7b2b4ca7ce8d7d33ca1ebf67691 | `evidence/qa-gates/phase-gate.P1.2026-11-18T12-00.md` |
| TypeScript format, lint, typecheck, Jest | pass | 0 findings; 5915 + 5898 passed | f9f358e9055db7b2b4ca7ce8d7d33ca1ebf67691 | `evidence/qa-gates/phase-gate.P1.2026-11-18T12-00.md` |
| CI Required Gate | pass | pending CI (S9) | f9f358e9055db7b2b4ca7ce8d7d33ca1ebf67691 | local gates above; CI-dependent criteria S-12, S-16, U-08, U-10 |

---

## 8. Gaps and Exceptions

### Identified Gaps
- None blocking. Non-blocking observations are listed in the code review (manifest entry placement, inherited JSON layout, a spacing nit, double envelope parse).
- CI-dependent criteria (S-12, S-16, U-08, U-10) are pending-CI; `codex-pretooluse-integration.Tests.ps1` is CI-only under the launcher policy.

### Approved Exceptions
- Integration lane (`evidence/other/deviation-integration-lane.2026-11-18T09-10.md`): the launcher refuses a local integration-lane run; CI provides that evidence. Accepted.
- AD-8 deferral of the Codex `enforce-feature-folder-order` port: a recorded spec decision, verified by rules H1 and H5 of the repository gate.

### Removed/Skipped Tests
**None.** No test removed or skipped by this branch; the 18 skips equal the baseline.

---

## 9. Summary of Changes

The branch records function-parity dispositions for every hook registration in the three ecosystems, enforces them with a Pester repository gate, adds the Codex pr-author SubagentStop validator with its envelope twin and registration, pins cross-tree helper identity, extends the no-Python scan to Copilot hooks, and repairs generator-source drift on the orchestrator-state rule.

---

## 10. Compliance Verdict

### Overall Status: ✅ FULLY COMPLIANT

All policy checks pass on local evidence; the CI-dependent criteria are pending S9.

---

### Policy-by-Policy Summary

#### General Code Change Policy (Section 2)
- ✅ Before Making Changes: plan, remediation plan and decisions recorded
- ✅ Design Principles: pure rule module, twin functions
- ✅ Module & File Structure: largest covered file 609 lines
- ✅ Naming, Docs, Comments: comment-based help throughout
- ✅ Toolchain Execution: zero findings, zero failures
- ✅ Summarize & Document: disposition record written

#### Language-Specific Code Change Policy (Section 3)

**For PowerShell:**
- ✅ Tooling & Baseline: clean
- ✅ PowerShell Design & Safety: fail-closed paths, advanced functions
- ✅ Structure & Naming: approved verbs
- ✅ Toolchain: clean

#### General Unit Test Policy (Section 1)
- ✅ Core Principles: parallel-safe
- ✅ Coverage & Scenarios: thresholds met, no regression
- ✅ Test Structure: AAA
- ✅ External Dependencies: in-memory payloads
- ✅ Policy Audit: this record

#### Language-Specific Unit Test Policy (Section 4)

**For PowerShell:**
- ✅ Framework & Scope: Pester through the launcher
- ✅ Test Style & Structure: focused
- ✅ Naming & Readability: descriptive
- ✅ Toolchain: launcher, parallel-only

---

### Metrics Summary

- ✅ 58129 of 58129 non-skipped tests passing across Pester, pytest and Jest
- ✅ 142 of 144 new PowerShell lines covered (98.61%)
- ✅ Repository totals at or above Phase 0 in every gate
- ✅ Test files follow the repository test layout
- ✅ All code quality checks passing
- ✅ Pester 760.85 s across 8 shards

---

### Recommendation

**Ready for merge** once the CI-dependent criteria pass at S9.

---

## Appendix A: Test Inventory

- `tests/scripts/harness/HarnessHookParity.Tests.ps1` (new)
- `tests/scripts/harness/HarnessHookParity.RepoGate.Tests.ps1` (new)
- `tests/scripts/codex-hooks/codex-validate-pr-author-output.Tests.ps1` (new)
- `tests/scripts/codex-hooks/codex-subagentstop-envelope.Tests.ps1` (new)
- `tests/scripts/codex-hooks/cross-tree-helper-identity.Tests.ps1` (new)
- `tests/scripts/claude-runtime/enforcement-hooks-no-python-invocation.Tests.ps1` (modified)
- `tests/scripts/claude-runtime/EnforcementHooksNoPythonInvocation.ScanRoots.Helpers.ps1` (modified)
- `tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1` (modified)
- `tests/scripts/codex-hooks/hook-dependency-failure.Codex.Tests.ps1` (modified)
- `tests/scripts/codex-hooks/codex-bundle-hook-probe.Tests.ps1` (modified)

---

## Appendix B: Toolchain Commands Reference

```powershell
Import-Module ./scripts/powershell/PoshQC; Invoke-PoshQCFormat -Root .
Import-Module ./scripts/powershell/PoshQC; Invoke-PoshQCAnalyze -Root .
Import-Module ./scripts/powershell/PoshQC; Invoke-PoshQCParallelTest -Root .
pwsh -NoProfile -File scripts/harness-generation/Invoke-HarnessGeneration.ps1 -Surface all -Check
```

```bash
sh .claude/skills/test-execution-policy/scripts/run-test-suite.sh pester
env -u VIRTUAL_ENV sh .claude/skills/test-execution-policy/scripts/run-test-suite.sh pytest
env -u VIRTUAL_ENV poetry run python scripts/dev_tools/validate_evidence_locations.py --root .
env -u VIRTUAL_ENV poetry run python -m scripts.dev_tools.format_json --check config/harness-parity-matrix.json
git diff --name-status 2d487f5b070b401a6d14271a039b1207a6e0383f..HEAD
```

---

**Audit Completed By:** feature-review agent  
**Audit Date:** 2026-11-18  
**Policy Version:** Current (as of audit date)
