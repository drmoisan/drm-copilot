# Policy Compliance Audit: Preimplementation Gate Worktree Selector (LACS) — Issue #671

---

**Audit Date:** 2026-09-17
**Code Under Test:**
- `.claude/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1` (MODIFIED)
- `.codex/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1` (MODIFIED)
- `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1` (MODIFIED)
- `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1` (MODIFIED)
- `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.CommandExemption.Tests.ps1` (MODIFIED)
- `tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-command-exemption.Tests.ps1` (MODIFIED)
- `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-helpers.Parity.Tests.ps1` (NEW)
- 37 Markdown files under `docs/features/active/2026-09-13-preimplementation-gate-worktree-selector-671/` (spec, plan, evidence)

**Base branch (resolved):** `origin/epic/worktree-scoped-state-resolution-integration` @ `79fd5a95c00cd99238b69a3195788206ae96f4cd`
**Merge base:** `79fd5a95c00cd99238b69a3195788206ae96f4cd`
**Head:** `feature/2026-09-13-preimplementation-gate-worktree-selector-671` @ `03f4f305765e15745b9275f3a8fd42758f2c6873`
**Scope:** full branch diff `79fd5a95...03f4f305` (44 files, +1849/-75). Languages with changed files: PowerShell (7 files), Markdown (37 files). Python, TypeScript, C#, Bash, JSON: zero changed files.

**Coverage Metrics by Language:**

| Language | Files Changed | Tests | Test Result | Baseline Coverage | Post-Change Coverage | New Code Coverage |
|----------|--------------|-------|-------------|-------------------|---------------------|-------------------|
| PowerShell | 7 files (4 production, 3 test) | 4597 tests (full repo run) | ❌ 4580 pass, 8 fail, 9 disabled (6 failures attributable to this branch) | 95.48% lines (8914/9336); helpers file 94.92% (112/118) | 95.41% lines (8970/9402); helpers file 92.72% (140/151) | 87.88% of instrumented changed lines (29/33) |
| Python | 0 files | N/A | N/A | N/A (no changed files) | N/A (no changed files) | N/A |
| TypeScript | 0 files | N/A | N/A | N/A (no changed files) | N/A (no changed files) | N/A |
| C# | 0 files | N/A | N/A | N/A (no changed files) | N/A (no changed files) | N/A |

### Coverage Evidence Checklist

- TypeScript baseline coverage artifact: N/A - no TypeScript files changed on this branch
- TypeScript post-change coverage artifact: N/A - no TypeScript files changed on this branch
- PowerShell baseline coverage artifact: `docs/features/active/2026-09-13-preimplementation-gate-worktree-selector-671/evidence/baseline/poshqc-test-coverage.2026-09-13T22-40.md`
- PowerShell post-change coverage artifact: `artifacts/pester/powershell-coverage.xml` (LastWriteTime 2026-09-17T08:26:50), summarized in `docs/features/active/2026-09-13-preimplementation-gate-worktree-selector-671/evidence/qa-gates/poshqc-test-coverage.2026-09-14T01-00.md`
- Per-language comparison summary: Section 1.2.1 of this audit and `docs/features/active/2026-09-13-preimplementation-gate-worktree-selector-671/evidence/qa-gates/coverage-comparison.2026-09-14T01-00.md`

**Template source note:** The MCP template tool was unavailable in this reviewer session. The artifact structure was taken from `extensions/drm-copilot/resources/templates/policy_audit/policy-audit.yyyy-MM-ddTHH-mm.md`, which is the bundled asset that the MCP server serves. The overall verdict of this audit is NON-COMPLIANT regardless of this substitution.

---

## Executive Summary

This audit covers the full branch diff for issue #671. The branch implements the Lexical Absolute-Canonical Selector (LACS) rule: `Test-ExemptOrchestrationSegmentToken` now accepts one lexically absolute `git -C <value>` selector between `git` and `add`/`commit`, validated by the new predicate `Test-ExemptOrchestrationSelector`. The change is applied identically to all four surface copies of the helpers module (SHA256 `5C906A2A...13B1` on all four, verified by the reviewer). The branch also adds 24 table-driven rows to each command-exemption suite and a new SHA256 surface-parity suite.

The diff is confined as the spec requires. The four gate files, the four modes files, the shared parser, and the epic-merge gate are byte-unchanged; the reviewer confirmed this with an empty `git diff` against the resolved merge base. The purity contract survives, no Python file is added, and all files are under 500 lines.

The branch is not compliant, for three reasons:

1. **Tests fail.** Six new deny rows fail: `LACS L3a`, `LACS L3b`, and `LACS L8`, in both the Claude and Codex suites. The reviewer confirmed this by parsing `artifacts/pester/pester-junit.xml`: 8 failures in total, 2 of them pre-existing.
2. **Pre-existing empty-token fail-open, confirmed.** A command whose segment contains an empty quoted token fails parameter binding in `Test-ExemptOrchestrationSegmentToken`. Under the default `Continue` preference, the exemption predicate then returns `True`. The reviewer's probe returned `True` for `git add "" -- src/foo.ps1`. The spec's L8 criterion cannot pass until this is closed.
3. **PowerShell coverage regressed on the modified helpers file.** It fell from 94.92% to 92.72%. Changed lines 253, 254, 258, and 259 are unexecuted, and unchanged line 319 lost coverage.

The mandatory toolchain loop therefore did not close in a single pass.

**Policy documents evaluated:**
- ✅ `general-code-change.instructions.md` (`.claude/rules/general-code-change.md`)
- ✅ `general-unit-test.instructions.md` (`.claude/rules/general-unit-test.md`)
- ✅ `.claude/rules/quality-tiers.md`

**Language-specific policies evaluated:**
- N/A `python-code-change.instructions.md` + `python-unit-test.instructions.md` (no Python files changed)
- ✅ `powershell-code-change.instructions.md` + `powershell-unit-test.instructions.md` (`.claude/rules/powershell.md`)
- N/A Bash: shfmt + shellcheck + bats (no Bash files changed)
- N/A JSON: format_json + validate_json (no JSON files changed)

**Toolchain results:** Format: no file changed (hash pairs equal). Analyze: 0 findings on all seven PowerShell paths. Type check: not applicable to PowerShell. Test: FAIL (8 failures, 6 attributable). Contract (Python push-down tests): 16 passed. Coverage: repo-wide 95.41% meets the 85% floor; the modified helpers file regressed (FAIL).

**Temporary artifacts cleanup:**
- ✅ No temporary script was committed. The executor's scratchpad scripts are outside the repository. The reviewer's two probe scripts (`probe671.ps1`, `reports671.ps1`) are in the session scratchpad and are not in the repository.
- ✅ No ongoing tooling script was added.
- The branch diff contains no files under `artifacts/`.

---

## Rejected Scope Narrowing

No narrowing was detected. The caller prompt named the resolved base branch, the merge-base SHA, the active feature folder, and the AC source (`spec.md`, work mode `full-bug`). It did not restrict files, languages, or coverage scope. The instruction to "use plain, non-chained git commands" is a command-style constraint, not a scope narrowing. The audit covers the full branch diff.

---

## Evidence Location Compliance

- Command: `poetry run python scripts/dev_tools/validate_evidence_locations.py --root <worktree root>` — EXIT_CODE 0, no output.
- Command: `git diff --name-only 79fd5a95...HEAD -- artifacts/` — no output. The branch diff contains no file under `artifacts/baselines/`, `artifacts/qa/`, `artifacts/evidence/`, or `artifacts/coverage/`.
- All 29 branch evidence files are under `docs/features/active/2026-09-13-preimplementation-gate-worktree-selector-671/evidence/<kind>/` (`baseline`, `other`, `issue-updates`, `qa-gates`, `regression-testing`).
- Result: PASS. No evidence-location violation.

---

## 1. General Unit Test Policy Compliance

### 1.1 Core Principles

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Independence** - Tests run in any order | ✅ PASS | New rows are `-ForEach` data rows that build a payload and call `Get-ExemptionDecisionForCommand` (Codex: `Get-CodexExemptionDecisionForCommand`) with no shared mutable state. The parity suite only reads four files in `BeforeAll`. |
| **Isolation** - Each test targets single behavior | ✅ PASS | Each row asserts one command's decision. The parity suite has two `It` nodes: hash identity and the line cap. |
| **Fast Execution** - Tests complete quickly | ✅ PASS | In-memory payload construction; no child process. Suite-level timing was not captured separately. |
| **Determinism** - Consistent results | ✅ PASS | Fixed string fixtures, no clock, no RNG. The 6 failures reproduce deterministically across the executor runs at 08:06, 08:10, 08:13, and 08:27. |
| **Readability & Maintainability** - Clear structure | ✅ PASS | Labels such as `issue #671 LACS L5a - parent-directory segment in the selector` name the condition under test. Context comments state the rule. |

### 1.2 Coverage and Scenarios

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Baseline Coverage Documented** | ✅ PASS | **Baseline:** 95.48% lines (8914/9336); helpers file 94.92% (112/118).<br>**Source:** `evidence/baseline/poshqc-test-coverage.2026-09-13T22-40.md` |
| **No Coverage Regression** | ❌ FAIL | **Repo-wide:** 95.48% → 95.41% (-0.07%); remains above 85%.<br>**Modified helpers file:** 94.92% → 92.72% (-2.20%): a regression on a modified file.<br>**Changed lines unexecuted:** 253, 254, 258, 259. Unchanged line 319 was covered at baseline (pre-change line 235) and is now unexecuted.<br>Reviewer re-derived the figures from `artifacts/pester/powershell-coverage.xml`: zero-hit lines `[180,253,254,258,259,299,319,348,354,406,423]`. |
| **New Code Coverage ≥85%** | ⚠️ PARTIAL | No new production file. Instrumented changed lines: 29/33 = 87.88%. The four unexecuted lines are the L3 and L8 rejection branches that the failing rows were meant to reach. |
| **Comprehensive Coverage** | ❌ FAIL | `Test-ExemptOrchestrationSelector` (helpers lines 222–279): all rejection branches are executed except L3 (253–254) and L8 (258–259). `Test-ExemptOrchestrationSegmentToken`: the subcommand rejection after an accepted selector (line 319) has no row. |
| **Positive Flows** - Valid inputs | ✅ PASS | 7 allow rows per suite: drive-letter, POSIX-rooted, backslash, commit with `-m`, chained add+commit, sibling root, directory outside every worktree. All pass. |
| **Negative Flows** - Invalid inputs | ❌ FAIL | 17 deny rows per suite; 14 pass and 3 fail (L3a, L3b, L8). |
| **Edge Cases** - Boundary conditions | ⚠️ PARTIAL | UNC, `.`/`..` segments, wildcard, stray colon, repeated selector, and attached spelling are covered and pass. The empty value (L8) fails. No row covers a selector followed by a non-`add`/`commit` subcommand. |
| **Error Handling** - Error paths | ❌ FAIL | An empty token throws a parameter-binding error that is not handled, and the predicate returns `True` (fail-open). No test pins fail-closed behavior on a binding error. |
| **Concurrency** - If applicable | N/A | Pure string classifier; no concurrency. |
| **State Transitions** - If applicable | N/A | Stateless predicate. |

### 1.2.1 Per-Language Coverage Comparison

- PowerShell: Baseline: 95.48% lines (8914/9336) -> Post-change: 95.41% lines (8970/9402). Change: -0.07% lines repo-wide; modified helpers file 94.92% -> 92.72% (-2.20%). New/changed-code coverage: 87.88% of instrumented changed lines (29/33). Disposition: FAIL (regression on a modified file; changed lines 253, 254, 258, 259 and previously covered line 319 are unexecuted). Evidence: `docs/features/active/2026-09-13-preimplementation-gate-worktree-selector-671/evidence/qa-gates/coverage-comparison.2026-09-14T01-00.md`, `artifacts/pester/powershell-coverage.xml`.
- Python: N/A - zero changed Python files on the branch.
- TypeScript: N/A - zero changed TypeScript files on the branch.
- C#: N/A - zero changed C# files on the branch.

Branch coverage: Pester measures line and command coverage only, so no branch-coverage threshold applies to PowerShell.

### 1.3 Test Structure and Diagnostics

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Clear Failure Messages** | ✅ PASS | Every assertion carries `-Because` text. The parity assertion lists all four paths in its failure message. |
| **Arrange-Act-Assert Pattern** | ✅ PASS | `# Act` / `# Assert` comments in the new rows (Arrange is the `-ForEach` data). The parity suite has explicit `# Arrange`, `# Act`, `# Assert`. |
| **Document Intent** | ✅ PASS | Context-level comments cite LACS and state that debug text is not contractual. |

### 1.4 External Dependencies and Environment

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Avoid External Dependencies** | ✅ PASS | No network or process. The parity suite reads the four committed helpers copies (repository content under test). |
| **Use Mocks/Stubs** | ✅ PASS | Existing not-ready checkpoint helper `ConvertTo-NotReadyCheckpointRaw` isolates the exemption path. |
| **Environment Stability** | ✅ PASS | No temporary file is created. No environment variable is read. |

### 1.5 Policy Audit Requirement

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Pre-submission Review** | ❌ FAIL | This audit is the required review. Outstanding items: 3 blocking findings (see Section 8). |

---

## 2. General Code Change Policy Compliance

### 2.1 Before Making Changes

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Clarify the objective** | ✅ PASS | `spec.md` (issue #671, epic F2) states the objective and the LACS rule. |
| **Read existing change plans** | ✅ PASS | `evidence/baseline/phase0-instructions-read.2026-09-13T22-40.md`, `evidence/other/requirements-sources-read.2026-09-13T22-40.md`. |
| **Document the plan** | ✅ PASS | `plan.2026-09-13T20-46.md`. |

### 2.2 Design Principles

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Simplicity first** | ✅ PASS | One constant, one predicate (57 lines), and a 9-line prologue change. |
| **Reusability** | ✅ PASS | Reuses `$script:PathspecWildcardCharacters` for L6. |
| **Extensibility** | ✅ PASS | The selector name is a named constant, and the predicate is separable. |
| **Separation of concerns** | ✅ PASS | Pure string logic; no I/O added (purity literals verified absent). |

### 2.3 Module & File Structure

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Cohesive modules** | ✅ PASS | The change is confined to the helpers module. |
| **Under 500 lines** | ✅ PASS | Helpers: 433 lines on each of four copies. Claude suite: 350. Codex suite: 357. Parity suite: 54. (`wc -l`) |
| **Public vs internal** | ✅ PASS | `Test-ExemptOrchestrationStagingCommand` signature and `[OutputType([bool])]` are unchanged. |
| **No circular dependencies** | ✅ PASS | No new dot-source or `Import-Module` (Select-String returned no line). |

### 2.4 Naming, Docs, and Comments

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Descriptive names** | ✅ PASS | `Test-ExemptOrchestrationSelector`, `$script:OrchestrationSelectorOptionName`. |
| **Docs/docstrings** | ✅ PASS | Comment-based help maps each L1–L8 condition. |
| **Comment why, not what** | ✅ PASS | The "Accepted widening" block records the rationale and measured exposure. |

### 2.5 After Making Changes - Toolchain Execution

| Requirement | Status | Evidence |
|------------|--------|----------|
| **1. Formatting** | ✅ PASS | **Command:** `mcp__drm-copilot__run_poshqc_format`<br>**Result:** seven before/after hash pairs equal; porcelain identical. |
| **2. Linting** | ✅ PASS | **Command:** `Invoke-ScriptAnalyzer -Settings scripts/powershell/PoshQC/settings/pssa.settings.psd1` per path<br>**Result:** 0 findings on seven paths. |
| **3. Type checking** | N/A | Not applicable to PowerShell. |
| **4. Architecture boundaries** | ✅ PASS | Diff confinement verified: gate, modes, shared-parser, and epic-merge files are byte-unchanged (reviewer `git diff --stat 79fd5a95 HEAD -- <13 paths>` produced no output). |
| **5. Unit tests** | ❌ FAIL | **Command:** `mcp__drm-copilot__run_poshqc_test`<br>**Result:** 8 failed (6 attributable to this branch). |
| **6. Contract checks** | ✅ PASS | `poetry run pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py tests/scripts/dev_tools/test_push_down_claude_pack_manifest_completeness.py` — 16 passed. The first run failed on gitignored batch-budget state (issue #510 pattern) and passed after reset. |
| **7. Integration tests** | ❌ FAIL | Gate-level command-exemption rows are the integration surface; the same 6 failures apply. |
| **Full toolchain loop** | ❌ FAIL | `evidence/qa-gates/toolchain-single-pass.2026-09-14T01-00.md` records INCOMPLETE; the loop did not close. |
| **Explicit reporting** | ✅ PASS | Every stage has a timestamped evidence file. |

### 2.6 Summarize and Document

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Summarize changes** | ✅ PASS | Commit `03f4f305` message and evidence set. |
| **Design choices explained** | ✅ PASS | spec.md Proposed Fix, and the helpers "Accepted widening" comment. |
| **Update supporting documents** | ⚠️ PARTIAL | spec.md AC updated. Plan tasks P0-T5, P3-T3, P3-T5, P3-T7, P4-T4, P5-T10, P6-T3, P6-T7, P6-T8, and P7-T1 remain unchecked, although spec criteria delivered by P3-T7, P4-T4, P5-T10, and P6-T8 are checked. |
| **Provide next steps** | ✅ PASS | `evidence/other/follow-up-candidates.2026-09-14T01-00.md` and the reconciliation artifact name the required spec/plan revision. |

---

## 3. Language-Specific Code Change Policy Compliance

### Section 3B: PowerShell Code Change Policy Compliance

#### 3B.1 Tooling & Baseline

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Formatting with Invoke-Formatter** | ✅ PASS | **Command:** `mcp__drm-copilot__run_poshqc_format`<br>**Result:** no file changed. |
| **Linting with PSScriptAnalyzer** | ✅ PASS | **Command:** `mcp__drm-copilot__run_poshqc_analyze` plus direct `Invoke-ScriptAnalyzer` (PSSA 1.25.0)<br>**Result:** 0 findings. |
| **Fix all findings** | ✅ PASS | No findings to fix. |
| **PowerShell 5.1 & 7.6+ compatible** | ✅ PASS | Only `String.StartsWith`, `Contains`, `IndexOfAny`, `-split`, `-replace`, and `-match` are used; all are available in 5.1. Tests ran under pwsh 7.6.6. |

#### 3B.2 PowerShell Design & Safety

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Advanced functions** | ✅ PASS | `[CmdletBinding()]`, `[OutputType([bool])]` on the new predicate. |
| **Parameter validation** | ❌ FAIL | The new predicate declares `[AllowEmptyString()]`, but its caller `Test-ExemptOrchestrationSegmentToken` (helpers line 296) does not. An empty token therefore throws before the new L8 branch can run. |
| **Avoid global state** | ✅ PASS | Script-scope constants only. |
| **Error handling** | ❌ FAIL | Pre-existing: a statement-terminating binding error inside `if (-not (Test-ExemptOrchestrationSegmentToken ...))` (line 428) is not caught. Execution continues, and the predicate returns `True`. This violates "fail fast and explicitly" and the module's own "every parse ambiguity answers false" contract. The reviewer probe confirmed `git add "" -- src/foo.ps1` → `True`. |

#### 3B.3 Structure, Naming, and Comments

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Cohesive and under 500 lines** | ✅ PASS | 433 lines per helpers copy. |
| **Approved verbs** | ✅ PASS | `Test-` (approved). |
| **Comment why** | ✅ PASS | Rationale comments present. |

#### 3B.4 Running the Toolchain

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Step 1: Format** | ✅ PASS | No change. |
| **Step 2: Analyze** | ✅ PASS | 0 findings. |
| **Step 3: Type check** | N/A | Not applicable for PowerShell. |
| **Step 4: Test** | ❌ FAIL | 8 failures (6 attributable). |
| **Rerun loop if needed** | ❌ FAIL | No restart was attempted because the failures cannot be fixed within the plan's edit boundary. A plan/spec revision is required. |

---

## 4. Language-Specific Unit Test Policy Compliance

### Section 4B: PowerShell Unit Test Policy Compliance

#### 4B.1 Framework and Scope

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Use Pester v5.x** | ✅ PASS | `#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }`; `Describe`/`Context`/`It -ForEach`. |
| **Use PoshQC Configuration** | ✅ PASS | **Command:** `mcp__drm-copilot__run_poshqc_test`<br>**Config:** `scripts/powershell/PoshQC/settings/pester.runsettings.psd1` (unchanged; helpers copies at lines 135 and 229 are already in `CodeCoverage.Path`). |
| **PowerShell 5.1 & 7.6+ Compatible** | ✅ PASS | The test files declare `#Requires -Version 7.0`, consistent with sibling suites. |

#### 4B.2 Test Style and Structure

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Focused Unit Tests** | ⚠️ PARTIAL | All new rows are gate-level. `Test-ExemptOrchestrationSelector` has no direct rows, so branches that the gate trigger cannot reach (L3) are untested. |
| **Test Behavior Over Implementation** | ✅ PASS | Only the decision is asserted; debug tokens are not asserted. |
| **Mocking Used Sparingly** | ✅ PASS | No mocks added. |
| **Organization** | ✅ PASS | **Test files:** `tests/scripts/claude-hooks/...`, `tests/scripts/codex-hooks/...`<br>**Code files:** `.claude/hooks/...`, `.codex/hooks/...`<br>Follows the repository's existing hook-test layout; no colocation. |

#### 4B.3 Naming and Readability

| Requirement | Status | Evidence |
|------------|--------|----------|
| **File Naming** - *.Tests.ps1 | ✅ PASS | `enforce-orchestration-preimplementation-gate-helpers.Parity.Tests.ps1` follows the `*.Parity.Tests.ps1` convention. |
| **Describe/Context/It Structure** | ✅ PASS | 2 new Contexts per command-exemption suite (7 + 17 rows); parity suite: 1 Describe, 2 It. |
| **Logical Grouping** | ✅ PASS | Allow and deny cases are grouped by Context. |
| **Docstrings/Comments** | ✅ PASS | Header comment in the parity suite explains the hash rationale. |

#### 4B.4 Running the Toolchain

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Use PoshQCTest Command** | ❌ FAIL | **Command:** `mcp__drm-copilot__run_poshqc_test`<br>**Result:** exit 8; 8 failures. |
| **No Alternative Test Runners** | ✅ PASS | Only Pester through PoshQC. |

---

## 5. Test Coverage Detail

### Test-ExemptOrchestrationSelector (24 gate-level rows per suite reach it; 0 direct rows)

| Test Name | Scenario Type | Lines Covered | Status |
|-----------|--------------|---------------|--------|
| `allows issue #671 LACS allow 1..7` | Positive | 243–278 success path | ✅ |
| `denies issue #671 LACS L1a` / `L1b` | Negative | 244–246 | ✅ |
| `denies issue #671 LACS L2` | Negative | 248–250 | ✅ |
| `denies issue #671 LACS L3a` / `L3b` | Negative | intended 252–254; not reached (gate trigger does not match) | ❌ |
| `denies issue #671 LACS L4a` / `L4b` | Negative | 264–266 | ✅ |
| `denies issue #671 LACS L5a` / `L5b` | Negative | 269–271 | ✅ |
| `denies issue #671 LACS L6` / `L7` | Negative | 273–276 | ✅ |
| `denies issue #671 LACS L8` | Edge Case | intended 257–259; not reached (binding error at caller) | ❌ |

**Coverage:** helpers file 92.72% (140/151 instrumented lines).

**Not covered:** 253–254 (L3 rejection), 258–259 (L8 rejection), 319 (non-`add`/`commit` subcommand after an accepted selector). Pre-existing unexecuted lines: 180, 299, 348, 354, 406, 423.

### Test-ExemptOrchestrationSegmentToken (prologue absorption)

| Test Name | Scenario Type | Lines Covered | Status |
|-----------|--------------|---------------|--------|
| allow rows 1–7 | Positive | 309–315 | ✅ |
| `denies issue #671 selector with a non-exempt pathspec operand` / `tree-wide all flag` / `absolute pathspec operand` | Negative | 309–315, then operand loop | ✅ |
| (none) | Negative | 319 after selector absorption | ❌ |

### Surface parity (2 tests)

| Test Name | Scenario Type | Lines Covered | Status |
|-----------|--------------|---------------|--------|
| `keeps all four surface copies of the helpers module byte-identical by SHA256 hash` | Positive | n/a (file assertion) | ✅ |
| `keeps every surface copy of the helpers module under the 500-line cap` | Positive | n/a (file assertion) | ✅ |

---

## 6. Test Execution Metrics

| Metric | Value | Status |
|--------|-------|--------|
| Total Tests | 4597 (full repository Pester run) | ✅ |
| Tests Passed | 4580 (99.63%) | ❌ |
| Tests Failed | 8 (6 attributable to this branch; 2 baseline) | ❌ |
| Tests Disabled | 9 (baseline) | ✅ |
| Issue #671 nodes | 50 (44 passed, 6 failed) | ❌ |
| Execution Time | Not recorded per suite in the evidence | ⚠️ |
| Functions Tested | 2/2 changed functions reached through the gate | ⚠️ |
| Test File Size | 350 / 357 / 54 lines | ✅ |
| Code Coverage | 95.41% lines repo-wide; branch coverage not measured by Pester | ✅ |

---

## 7. Code Quality Checks

**For PowerShell:**

| Check | Command | Result | Status |
|-------|---------|--------|--------|
| Invoke-Formatter | `mcp__drm-copilot__run_poshqc_format` | No file changed | ✅ |
| PSScriptAnalyzer | `mcp__drm-copilot__run_poshqc_analyze` + `Invoke-ScriptAnalyzer` | 0 findings on 7 paths | ✅ |
| Pester Tests | `mcp__drm-copilot__run_poshqc_test` | 8 failed (6 attributable) | ❌ |

**For Python (contract checks only; no Python file changed):**

| Check | Command | Result | Status |
|-------|---------|--------|--------|
| Push-down contracts | `poetry run pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py tests/scripts/dev_tools/test_push_down_claude_pack_manifest_completeness.py` | 16 passed | ✅ |

**Notes:**
- Pre-existing failures that do not come from this branch: `enforce-pr-author-skill.ps1.allowed commands.allows gh pr create --body-file artifacts/pr_body_12.md when context exists` and `Every registered Codex PreToolUse handler accepts every tool name its matcher admits...`. Both are present in the baseline run.
- The executor's diff evidence uses `git diff --merge-base main`. The reviewer re-ran the confinement checks against the resolved merge base `79fd5a95` and obtained the same (empty) result.
- `quality-tiers.yml` does not exist at the worktree root (pre-existing; not introduced by this branch). The hook module is treated as T1 (security/enforcement), but coverage thresholds are uniform across tiers.

---

## 8. Gaps and Exceptions

### Identified Gaps

- **BLOCKING PA-1 — Test failures (toolchain stage 5).** Six new deny rows fail in both suites:
  - `LACS L3a` (`git -C C:/repo/wt`) and `LACS L3b` (`git -C C:/repo/wt -- docs/...`) contain no `add`/`commit`, so the gate trigger never classifies them and the gate allows them. This is a spec-table fixture defect.
  - `LACS L8` (`git -C "" add ...`) is allowed because of PA-2.
- **BLOCKING PA-2 — Fail-open on empty tokens (pre-existing, confirmed).** `Test-ExemptOrchestrationSegmentToken` declares `[string[]] $Token` without `[AllowEmptyString()]`. The resulting binding error is not caught, and `Test-ExemptOrchestrationStagingCommand` returns `True`. The reviewer probe returned `True` for `git add "" -- src/foo.ps1` and `git add -- "" scripts/powershell/Sample.ps1`. The executor's gate-level probes returned `allow` for `git commit -m "" -- src/foo.ts`. This bypasses the preimplementation gate for implementation files, and it is the root cause of the L8 failure.
- **BLOCKING PA-3 — PowerShell coverage regression on a modified file.** The helpers file fell from 94.92% to 92.72%. Changed lines 253, 254, 258, and 259 are unexecuted, and line 319 lost coverage. The file remains above 85%, but the no-regression requirement for modified files is not met.
- Toolchain single-pass (stage loop) is not closed. This follows from PA-1 and PA-2.
- Plan bookkeeping: ten plan tasks remain unchecked (non-blocking).

### Approved Exceptions

- **Accepted widening (nested-subdirectory selector):** recorded in the helpers file and in spec.md Risks & Mitigations. The measured exposure is seven Markdown fixtures, which the `file_path` leg already classifies as non-implementation. Approved by the spec.
- **Bundled copies not in `CodeCoverage.Path`:** the spec states the two bundled payload copies are deliberately not measured. They are byte-identical (SHA256) to the measured canonical copies, and the parity suite enforces that. This is a pre-existing configuration, not a new `exclude` entry.

### Removed/Skipped Tests

**None.** No tests were removed or skipped; the test diff is additive only (numstat `54 0` and `55 0`).

---

## 9. Summary of Changes

### Commits in This PR/Branch

1. **03f4f305** - fix(preimplementation-gate): add LACS worktree selector exemption

### Files Modified

1. **`.claude/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1`** (MODIFIED, +87/-3), and the three identical copies under `.codex/hooks/`, `extensions/.../claude-customizations/.claude/hooks/`, and `extensions/.../codex-and-agents-customizations/.codex/hooks/`
   - New constant `$script:OrchestrationSelectorOptionName`, and the "Accepted widening" comment block.
   - New predicate `Test-ExemptOrchestrationSelector` (L1–L8).
   - `Test-ExemptOrchestrationSegmentToken` prologue absorbs one accepted `-C <value>` selector.
2. **`tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.CommandExemption.Tests.ps1`** (MODIFIED, +54/-0) — 7 allow and 17 deny rows.
3. **`tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-command-exemption.Tests.ps1`** (MODIFIED, +55/-0) — the same 24 rows.
4. **`tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-helpers.Parity.Tests.ps1`** (NEW, 54 lines) — SHA256 parity and the 500-line cap.
5. **`docs/features/active/2026-09-13-preimplementation-gate-worktree-selector-671/spec.md`** (MODIFIED) — 21 AC checkboxes changed to `[x]`; no text change.
6. **`docs/features/active/2026-09-13-preimplementation-gate-worktree-selector-671/plan.2026-09-13T20-46.md`** (MODIFIED) — task check-offs.
7. **35 evidence files** (NEW) under `docs/features/active/2026-09-13-preimplementation-gate-worktree-selector-671/evidence/`.

---

## 10. Compliance Verdict

### Overall Status: ❌ NON-COMPLIANT

The implementation is confined to the approved axis and is structurally sound. However, the mandatory test stage fails, coverage regressed on the modified helpers file, and a confirmed fail-open in the same predicate chain blocks one of the spec's deny criteria.

---

### Policy-by-Policy Summary

#### General Code Change Policy (Section 2)
- ✅ Before Making Changes: spec, research, and plan present.
- ✅ Design Principles: single-axis, pure, minimal.
- ✅ Module & File Structure: 433 lines per copy; no new production file.
- ✅ Naming, Docs, Comments: complete.
- ❌ Toolchain Execution: test stage fails; loop not closed.
- ⚠️ Summarize & Document: plan checkboxes are inconsistent with spec check-offs.

#### Language-Specific Code Change Policy (Section 3)

**For PowerShell:**
- ✅ Tooling & Baseline: format and analyze clean.
- ❌ PowerShell Design & Safety: empty-token binding error fails open (PA-2).
- ✅ Structure & Naming: compliant.
- ❌ Toolchain: tests fail.

#### General Unit Test Policy (Section 1)
- ✅ Core Principles: met.
- ❌ Coverage & Scenarios: modified-file regression; three deny scenarios fail.
- ✅ Test Structure: met.
- ✅ External Dependencies: met; no temporary files.
- ❌ Policy Audit: blocking findings outstanding.

#### Language-Specific Unit Test Policy (Section 4)

**For PowerShell:**
- ✅ Framework & Scope: Pester 5 via PoshQC.
- ⚠️ Test Style & Structure: no direct predicate rows.
- ✅ Naming & Readability: compliant.
- ❌ Toolchain: PoshQC test exit 8.

---

### Metrics Summary

- ❌ 4580/4597 tests passing (6 failures attributable to this branch)
- ❌ 44/50 issue #671 nodes passing
- ✅ 95.41% repo-wide PowerShell line coverage (floor 85%)
- ❌ Modified helpers file line coverage 92.72% (baseline 94.92%)
- ✅ Four helpers copies byte-identical (SHA256 `5C906A2AABFB4110FAFC70357E85A5476C5546A1B6D5E1F030518D194A7E13B1`)
- ✅ Format and analyze clean
- ✅ Evidence location compliance

---

### Recommendation

**Blocked**

Blocking findings: 3 (PA-1, PA-2, PA-3). Required before merge:
1. Revise the spec and plan so that the L3a/L3b fixtures are trigger-matching commands that reach helpers line 253.
2. Permit and apply the `[AllowEmptyString()]` fix (and a fail-closed guard) for the empty-token binding error, with regression rows for `git add "" -- src/foo.ps1` and `git commit -m "" -- src/foo.ts`.
3. Add a row that reaches line 319.
4. Re-run the full PoshQC loop to a single clean pass, and confirm the helpers-file coverage is at or above the 94.92% baseline.

See `remediation-inputs.2026-09-17T08-40.md`.

---

## Appendix A: Test Inventory

### Complete Test List (added by this branch)

1. `enforce-orchestration-preimplementation-gate.ps1 command exemption (issue #539)` › `issue #671 worktree selector allow cases` › `allows issue #671 LACS allow 1` through `allow 7` (7 nodes, all Passed)
2. `enforce-orchestration-preimplementation-gate.ps1 command exemption (issue #539)` › `issue #671 worktree selector deny cases` › `denies issue #671 LACS L1a, L1b, L2, L4a, L4b, L5a, L5b, L6, L7` (Passed), `L3a, L3b, L8` (Failed), `selector with a non-exempt pathspec operand`, `selector with the tree-wide all flag`, `selector with an absolute pathspec operand`, `selector with an output redirection`, `cd chain into the target worktree` (Passed)
3. `Codex enforce-orchestration-preimplementation-gate command exemption (issue #539)` › same two Contexts, same 24 labels, same pass/fail pattern
4. `enforce-orchestration-preimplementation-gate-helpers.ps1 surface parity (issue #671)` › `keeps all four surface copies of the helpers module byte-identical by SHA256 hash` (Passed), `keeps every surface copy of the helpers module under the 500-line cap` (Passed)

---

## Appendix B: Toolchain Commands Reference

**Reviewer commands (check-only):**
```bash
git -C <worktree> diff --name-status 79fd5a95c00cd99238b69a3195788206ae96f4cd...HEAD
git -C <worktree> diff 79fd5a95c00cd99238b69a3195788206ae96f4cd...HEAD -- .claude/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1 tests/
git -C <worktree> diff --stat 79fd5a95c00cd99238b69a3195788206ae96f4cd HEAD -- <4 gate files> <4 modes files> <4 hook-command-invocation.ps1 files> .claude/hooks/enforce-epic-merge-gate.ps1
git -C <worktree> diff --name-only 79fd5a95c00cd99238b69a3195788206ae96f4cd...HEAD -- artifacts/
sha256sum <4 helpers copies>
wc -l <4 helpers copies> <3 test files>
poetry run python scripts/dev_tools/validate_evidence_locations.py --root <worktree>
sh <scratchpad>/probe671.sh      # dot-sources the helpers file; calls Test-ExemptOrchestrationStagingCommand on 8 rows
sh <scratchpad>/reports671.sh    # parses artifacts/pester/powershell-coverage.xml and pester-junit.xml
poetry run python scripts/dev_tools/validate_orchestration_artifacts.py policy-audit <this file>
```

**PowerShell toolchain (executor, recorded in evidence):**
```powershell
# Formatting
mcp__drm-copilot__run_poshqc_format
# Linting
mcp__drm-copilot__run_poshqc_analyze
Invoke-ScriptAnalyzer -Path <path> -Settings scripts/powershell/PoshQC/settings/pssa.settings.psd1 -Severity Error,Warning,Information
# Testing with coverage
mcp__drm-copilot__run_poshqc_test
```

**Python contract checks (executor):**
```bash
poetry run pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py tests/scripts/dev_tools/test_push_down_claude_pack_manifest_completeness.py -v -p no:cacheprovider --no-cov
```

---

**Audit Completed By:** feature-review agent
**Audit Date:** 2026-09-17
**Policy Version:** Current (as of audit date)
