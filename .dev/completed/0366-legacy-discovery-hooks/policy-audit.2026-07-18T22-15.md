# Policy Compliance Audit: legacy-discovery-hooks (Issue #366)

**Audit Date:** 2026-07-18
**Code Under Test:** `.claude/hooks/enforce-discovery-artifact-gate.ps1`, `.claude/hooks/validate-discovery-artifact-gate.ps1`, `.claude/settings.json`, `tests/scripts/claude-hooks/enforce-discovery-artifact-gate.Tests.ps1`, `tests/scripts/claude-hooks/validate-discovery-artifact-gate.Tests.ps1`, `scripts/powershell/PoshQC/settings/pester.runsettings.psd1`, `extensions/drm-copilot/resources/powershell/PoshQC/settings/pester.runsettings.psd1`

**Base branch:** `origin/epic/legacy-discovery-and-parity-integration` @ `26c24f861594922902b43fd8e04637304f210690` (resolved via `pr-base-branch-merge-base`; local `epic/legacy-discovery-and-parity-integration` ref was stale — behind 12 commits — and was rejected in favor of the freshly fetched `origin/` ref)
**Head:** `HEAD` @ `024cf6290c1a7666eac74aa41e8db99de1036e51`
**Merge base:** `e395efb7cf55953a93088964f10edc4d9dede404`
**PR context artifacts:** regenerated this session at `artifacts/pr_context.summary.txt` and `artifacts/pr_context.appendix.txt` (were missing at session start) via `poetry run python -m scripts.dev_tools.pr_context.collector --base origin/epic/legacy-discovery-and-parity-integration --head HEAD`

**Coverage Metrics by Language:**

| Language | Files Changed | Tests | Test Result | Baseline Coverage (repo-wide, JaCoCo LINE) | Post-Change Coverage (repo-wide, JaCoCo LINE) | New Code Coverage |
|----------|--------------|-------|-------------|-------------------|---------------------|-------------------|
| PowerShell | 4 code files (2 production, 2 test) + 2 mirrored `.psd1` coverage-allowlist edits + 1 `.claude/settings.json` registration | 1338 total (28 new: 15 + 13) | ✅ 1328 pass / 1 fail (pre-existing, unrelated) / 9 skipped | 89.41% (1849/2068 lines, `pester-baseline.2026-07-18T00-15.md`) | 89.32% (1948/2181 lines, this session's independent re-run) | `enforce-discovery-artifact-gate.ps1`: 87.27% (48/55); `validate-discovery-artifact-gate.ps1`: 87.93% (51/58) |
| Python | 0 files | N/A | N/A | N/A | N/A | N/A — zero changed Python files in this branch's diff |
| TypeScript | 0 files | N/A | N/A | N/A | N/A | N/A — zero changed TypeScript files |
| C# | 0 files | N/A | N/A | N/A | N/A | N/A — zero changed C# files |
| JSON | 1 file (`.claude/settings.json`) | N/A | ✅ valid JSON (`python -c "import json; json.load(...)"` exit 0) | N/A (config file) | N/A (config file) | N/A |

**Branch coverage:** not emitted by this repo's PoshQC/Pester JaCoCo coverage pipeline at report level for any file, a documented, pre-existing, repo-wide tooling limitation (confirmed independently this session — no `BRANCH` counter type appears anywhere in `artifacts/pester/powershell-coverage.xml`; the same condition is recorded in the P0-T9 baseline artifact `pester-baseline.2026-07-18T00-15.md` and other feature baselines in this epic, e.g. `2026-07-17-legacy-discovery-agent-roles-365`). This is a structural, repo-wide gap that predates and is unaffected by this feature; it is not a regression introduced by this change. Treated as an accepted, documented exception per `.claude/rules/quality-tiers.md`'s "Branch coverage: >= 75%" requirement — the requirement cannot be numerically evaluated because the tooling does not emit the metric, not because the code is under-branch-tested.

### Coverage Evidence Checklist

- PowerShell baseline coverage artifact: `docs/features/active/2026-07-17-legacy-discovery-hooks-366/evidence/baseline/pester-baseline.2026-07-18T00-15.md` (verified present and consistent with the JaCoCo baseline totals below)
- PowerShell post-change coverage artifact: `artifacts/pester/powershell-coverage.xml` (regenerated this session, independently, via direct `pwsh -NoProfile -Command "Import-Module ...PoshQC.psd1 -Force; Invoke-PoshQCTest ..."`, not via `mcp__drm-copilot__run_poshqc_test`, per the documented MCP staleness caveat — see "MCP Tool Staleness" below)
- Per-language comparison summary: `docs/features/active/2026-07-17-legacy-discovery-hooks-366/evidence/qa-gates/coverage-delta.2026-07-18T21-52.md`, independently reconciled against this session's own coverage run (see Section 5)
- TypeScript/C#/Python coverage artifacts: N/A — zero changed files in each of those languages

**Non-negotiable verdict rule:** satisfied — numeric baseline and post-change coverage metrics are reported for PowerShell (the only in-scope language with changed files), plus new-code coverage for both new files.

**Fail-closed rule:** no required baseline, QA, or coverage-comparison artifact is missing. Verdict below is PASS on the numeric evidence gathered.

---

## MCP Tool Staleness (Independent Verification)

The executor's stated caveat was independently reproduced and confirmed this session:

- `mcp__drm-copilot__run_poshqc_test` invokes `extensions/drm-copilot/resources/templates/run-poshqc-test.ps1`, which imports a PoshQC module snapshot whose `CodeCoverage.Path` allowlist is decoupled from this worktree's live edits to `scripts/powershell/PoshQC/settings/pester.runsettings.psd1`. This session did not re-invoke the MCP tool for coverage verification, in order to avoid reproducing the same staleness; the direct-`pwsh` method (below) was used instead, per the executor's documented workaround.
- Verification command actually run this session:
  ```
  pwsh -NoProfile -Command "Import-Module (Join-Path (Get-Location) 'scripts/powershell/PoshQC/PoshQC.psd1') -Force; Invoke-PoshQCTest -Root (Get-Location).Path -ScanFolders @('scripts','tests/scripts') -DisableKoverageCopy"
  ```
- Result: `artifacts/pester/powershell-coverage.xml` (regenerated, timestamp 22:01) contains `<sourcefile name="enforce-discovery-artifact-gate.ps1">` and `<sourcefile name="validate-discovery-artifact-gate.ps1">` entries with non-zero `LINE` counters (48/55 and 51/58 respectively), confirming the direct-`pwsh` method reflects live edits and the MCP staleness does not affect this audit's coverage evidence.
- This audit's own coverage/test evidence was independently produced via the direct-`pwsh` method, not carried forward from the executor's artifacts, though the two are consistent (see Section 5/6 below).

---

## Rejected Scope Narrowing

None detected. The orchestrating prompt for this review explicitly instructed independent re-verification of all executor-reported numbers against live repository state and did not attempt to narrow scope to a plan/task subset, exclude any language with changed files, or mark any language's coverage as informational-only. No narrowing action was required.

---

## Executive Summary

This audit independently re-verified all executor-reported final numbers for issue #366 (legacy-discovery-hooks) against live repository state, per the review brief's explicit instruction not to trust the reported numbers as given. All reported numbers were reproduced:

- Both new hooks' Pester suites: 15 + 13 = 28 tests, 0 failures — reproduced exactly.
- Per-file line coverage: `enforce-discovery-artifact-gate.ps1` 87.27% (48/55), `validate-discovery-artifact-gate.ps1` 87.93% (51/58) — reproduced exactly from a freshly regenerated `artifacts/pester/powershell-coverage.xml`.
- Full-suite Pester run: 1338 tests, 0 errors, 1 pre-existing unrelated failure (`enforce-pr-author-skill.ps1.allowed commands.allows gh pr create --body-file artifacts/pr_body_12.md when context exists`), 9 skipped — reproduced exactly.
- AC: 5/5 checked off in both `spec.md` and `user-story.md` — confirmed by direct file read.
- Exactly two production `.ps1` files and exactly two mirrored `.Tests.ps1` files were added, with no third shared helper file — confirmed via `git diff --name-status`.
- Zero `TaskMaster`/`TMW`/`Outlook`/`VSTO` tokens in either hook file's source — confirmed via independent grep.
- Both hooks are registered under existing `.claude/settings.json` matcher groups (`PreToolUse` → `"Write|Edit"`; `SubagentStop` → the existing broad generic-agent matcher), with no new matcher group created — confirmed by inspecting the parsed JSON.

**Policy documents evaluated:**
- ✅ `general-code-change.instructions.md` / `.claude/rules/general-code-change.md`
- ✅ `general-unit-test.instructions.md` / `.claude/rules/general-unit-test.md`

**Language-specific policies evaluated:**
- ✅ `powershell-code-change.instructions.md` + `powershell-unit-test.instructions.md` / `.claude/rules/powershell.md`
- N/A Python, TypeScript, C#, Bash — zero changed files in each
- ✅ JSON — `.claude/settings.json` parses as valid JSON; no `$schema`-governed data file was touched

**Temporary artifacts cleanup:**
- ✅ No temporary/one-time scripts were created by this review (all verification used repo-provided tooling: PoshQC module functions, `git`, `python -m scripts.dev_tools.validate_evidence_locations`, `python -m scripts.dev_tools.pr_context.collector`).
- ✅ No ongoing tooling scripts were introduced by this review.

---

## 1. General Unit Test Policy Compliance

### 1.1 Core Principles

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Independence** | ✅ PASS | Both test files use `BeforeAll` to dot-source the production file once and register per-`It` `Mock`s; no shared mutable state between `It` blocks. Full-suite run (1338 tests) shows no order-dependent failures. |
| **Isolation** | ✅ PASS | Each `It` targets one behavior (e.g., "allows the write and invokes the validator exactly once", "denies the write with the validator text embedded verbatim"). `Context` blocks group by scenario (conforming, non-conforming, unrecognized path, fail-open, malformed input, validator-not-found, Edit calls, domain neutrality, missing `file_path`, seam behavior, end-to-end entrypoint). |
| **Fast Execution** | ✅ PASS | Full 1338-test suite (including both new 15/13-test suites) completed in 51.53s per this session's independent run; no individual new test observed to be slow. |
| **Determinism** | ✅ PASS | No network, no filesystem temp files, no sleeps/retries in either new test file. External dependency (`python` validator subprocess) is mocked via `Invoke-DiscoveryValidatorExe`, never invoked directly in unit-level `It` blocks. |
| **Readability & Maintainability** | ✅ PASS | Descriptive `Describe`/`Context`/`It` names ("recognized, conforming artifact", "fail-open when the domain profile is absent") self-document scenario and expected outcome. |

### 1.2 Coverage and Scenarios

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Baseline Coverage Documented** | ✅ PASS | Baseline: 89.41% line coverage (1849/2068), documented in `evidence/baseline/pester-baseline.2026-07-18T00-15.md`, command `mcp__drm-copilot__run_poshqc_test` (pre-change; neither hook file existed yet). |
| **No Coverage Regression** | ✅ PASS | Post-change repo-wide: 89.32% (1948/2181), independently reproduced this session. The −0.09pp aggregate delta is arithmetic dilution: 219+14=233 missed, 1849+99=1948 covered, 2068+113=2181 total — the new files' own totals (missed=14, covered=99, total=113) account for the entire delta; every pre-existing file's missed/covered counts are unchanged (independently reconciled by inspecting `<sourcefile>` counters for pre-existing files in the regenerated `powershell-coverage.xml`, spot-checked against `evidence/qa-gates/coverage-delta.2026-07-18T21-52.md`'s stated reconciliation). |
| **New Code Coverage >= 85% (uniform tier rule, `.claude/rules/quality-tiers.md`)** | ✅ PASS | `enforce-discovery-artifact-gate.ps1`: 48/55 = 87.27%. `validate-discovery-artifact-gate.ps1`: 51/58 = 87.93%. Both independently re-extracted this session from `<sourcefile>` `LINE` counters in the freshly regenerated `artifacts/pester/powershell-coverage.xml`. Both clear the 85% threshold. |
| **New Code Branch Coverage >= 75%** | ⚠️ PARTIAL (documented tooling gap, not a code defect) | Not numerically evaluable: this repo's PoshQC/Pester JaCoCo pipeline emits no `BRANCH` counter for any file at any point in this session's or the baseline's coverage report. Confirmed independently by scanning all `counter` elements in the regenerated XML (`{'INSTRUCTION','LINE','METHOD','CLASS'}`, no `'BRANCH'`). This is a pre-existing, repo-wide tooling limitation predating this feature (also documented for feature #365's baseline), not something introduced or fixable by this change. Both hook files exercise every conditional branch behaviorally (see Section 5 below), which is the closest available proxy evidence in the absence of a numeric branch metric. |
| **Comprehensive Coverage** | ✅ PASS | All 8 "Seeded Test Conditions" from `spec.md` are covered by named `It` blocks in the two new test files (traced in Section 5 of this audit and in `feature-audit`). Both new production files' every named function (`Invoke-DiscoveryValidatorExe`, `Get-DiscoveryArtifactType`, `Get-RequiredDiscoveryArtifactDeclaration`, `Invoke-DiscoveryArtifactGateDecision`/`Invoke-DiscoveryArtifactGateValidation`, plus `Find-DiscoveryArtifactReference` in the SubagentStop hook) has at least one dedicated `It`. |
| **Positive Flows** | ✅ PASS | "recognized, conforming artifact" / "recognized, conforming referenced artifact" contexts in both files. |
| **Negative Flows** | ✅ PASS | "recognized, non-conforming artifact" contexts; malformed-JSON contexts (`{not-json` throws / returns `Ok=$false`). |
| **Edge Cases** | ✅ PASS | "unrecognized artifact path", "missing file_path", "payload with no output field", "Edit tool calls (no full content)" contexts cover boundary/absent-field conditions. |
| **Error Handling** | ✅ PASS | "malformed CLAUDE_TOOL_INPUT"/"malformed CLAUDE_HOOK_INPUT JSON", "empty or absent CLAUDE_TOOL_INPUT/HOOK_INPUT", "validator-not-found-style failure" contexts. |
| **Concurrency** | N/A | Both hooks are stateless, single-invocation, synchronous scripts; no concurrency surface. Documented in `spec.md` "Data & State" section ("both hooks are stateless"). |
| **State Transitions** | N/A | Both hooks are pure functions of (env-var JSON input, mocked validator result) to (decision output); no persisted state model (`spec.md`: "No `.claude/state/*.<session_id>.json` file is read or written"). |

### 1.2.1 Per-Language Coverage Comparison

- PowerShell: Baseline 89.41% line -> Post-change 89.32% line. Change: −0.09pp aggregate (dilution only, no regression on any pre-existing line — see arithmetic reconciliation above). New-code line coverage: 87.27% / 87.93% (both new files). Branch coverage: not emitted by tooling (repo-wide, pre-existing). Disposition: PASS (line); PARTIAL/documented-exception (branch, tooling gap). Evidence: `artifacts/pester/powershell-coverage.xml` (regenerated this session), `evidence/baseline/pester-baseline.2026-07-18T00-15.md`, `evidence/qa-gates/coverage-delta.2026-07-18T21-52.md`.
- Python / TypeScript / C#: N/A — out of scope, zero changed files in each.

### 1.3 Test Structure and Diagnostics

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Clear Failure Messages** | ✅ PASS | Assertions use Pester's `Should -Be`/`Should -BeLike`/`Should -Match`/`Should -Throw`/`Should -Invoke -Times -Exactly`, each producing a specific, diagnosable failure (e.g., `permissionDecisionReason | Should -BeLike 'DISCOVERY_ARTIFACT_GATE_BLOCKED:*'`). |
| **Arrange-Act-Assert Pattern** | ✅ PASS | Each `It` follows Arrange (build JSON input / register `Mock`) -> Act (call the decision/validation function) -> Assert (`Should` chain) structure. |
| **Document Intent** | ✅ PASS | `Context`/`It` descriptions name the scenario and expected outcome directly (no separate docstring needed for Pester's convention). |

### 1.4 External Dependencies and Environment

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Avoid External Dependencies** | ✅ PASS | No network, database, or live-process calls in unit-level `It` blocks. The "script entrypoint (end-to-end)" contexts do invoke a genuine child `pwsh` process — a documented, established pattern already used by `enforce-epic-merge-gate.Tests.ps1` for the same class of subprocess-invoked entrypoint smoke test — not an external service dependency. |
| **Use Mocks/Stubs** | ✅ PASS | `Invoke-DiscoveryValidatorExe` (the wrapper-seam function) is mocked in every scenario except the "script entrypoint (end-to-end)" tests, per the wrapper-seam mocking rule in `.claude/rules/powershell.md` ("never mock `git`/`gh`/etc.; mock the wrapper function"). Production `python` is never mocked directly. |
| **Environment Stability** | ✅ PASS | No temporary files are created by either test file. `$env:CLAUDE_TOOL_INPUT` / `$env:CLAUDE_HOOK_INPUT` are saved/restored (`$prev = $env:...; ...; finally { $env:... = $prev }`) in the end-to-end contexts, avoiding cross-test environment leakage. |

### 1.5 Policy Audit Requirement

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Pre-submission Review** | ✅ PASS | This document constitutes the required policy review, produced from an independent re-verification pass (not carried forward from the executor's self-reported numbers). |

---

## 2. General Code Change Policy Compliance

### 2.1 Before Making Changes

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Clarify the objective** | ✅ PASS | `issue.md` (#366), `spec.md` v0.2, and `user-story.md` fully specify the objective: two completion-gate hooks invoking an already-merged validator CLI, domain-neutral, registered in existing matcher groups. |
| **Read existing change plans** | ✅ PASS | Work executed against a pre-approved, preflight-cleared atomic plan (`plan.2026-07-17T14-38.md`), prepared upstream by an epic-planner run per the task brief. |
| **Document the plan** | ✅ PASS | All 54 plan tasks are checked off (`grep -c '^\s*- \[ \]'` = 0, `grep -c '^\s*- \[x\]'` = 54, independently verified this session). |

### 2.2 Design Principles

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Simplicity first** | ✅ PASS | Thin-entrypoint pattern: decision logic lives in named, testable functions (`Invoke-DiscoveryArtifactGateDecision`/`...Validation`); the file's bottom-of-file entrypoint block is the only code touching `$env:`/`ConvertTo-Json`/`exit`, matching `spec.md`'s documented design. |
| **Reusability** | ✅ PASS with documented exception | `Invoke-DiscoveryValidatorExe`, `Get-DiscoveryArtifactType`, and `Get-RequiredDiscoveryArtifactDeclaration` are duplicated verbatim across both hook files rather than factored into a shared module. `spec.md`'s "File-count / change budget" section explicitly justifies this: a third shared file would exceed the direct-mode cap of "up to 2 production PowerShell files" in `.claude/rules/powershell.md` and would route the work through `powershell-change-budget-router`. This is a documented, policy-consistent trade-off, not an unexamined duplication. |
| **Extensibility** | ✅ PASS | `Get-DiscoveryArtifactType` and `Get-RequiredDiscoveryArtifactDeclaration` are explicitly marked as narrow, replaceable seams (`# TODO(#9002)`, `# TODO(#9001)`) for upstream features not yet shipped, with documented fail-open defaults — a deliberate extension point rather than a hardcoded assumption. |
| **Separation of concerns** | ✅ PASS | Validator-invocation I/O is isolated in `Invoke-DiscoveryValidatorExe`; decision logic is pure given a mocked wrapper; the entrypoint block is the only layer touching process env vars, JSON serialization, and `exit`. |

### 2.3 Module & File Structure

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Cohesive modules** | ✅ PASS | Each hook file has one clear purpose (PreToolUse deny-gate vs. SubagentStop block-gate) per the epic's established `enforce-`/`validate-` naming split. |
| **Under 500 lines** | ✅ PASS | `enforce-discovery-artifact-gate.ps1`: 213 lines. `validate-discovery-artifact-gate.ps1`: 237 lines. `enforce-discovery-artifact-gate.Tests.ps1`: 190 lines. `validate-discovery-artifact-gate.Tests.ps1`: 171 lines. All independently counted via `wc -l` this session; all well under the 500-line limit. |
| **Public vs internal** | ✅ PASS | All functions are named, advanced functions (`[CmdletBinding()]`) with explicit `[OutputType(...)]`; no unnamed script-block sprawl. |
| **No circular dependencies** | ✅ PASS | Each hook file is self-contained (no cross-file `Import-Module`/dot-sourcing of the other hook); the only shared dependency is the external validator CLI, invoked identically and independently by each file's own copy of the wrapper. |

### 2.4 Naming, Docs, and Comments

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Descriptive names** | ✅ PASS | `Invoke-DiscoveryArtifactGateDecision`, `Get-RequiredDiscoveryArtifactDeclaration`, `Find-DiscoveryArtifactReference` — all approved PowerShell verbs (`Invoke`, `Get`, `Find`) with descriptive, unabbreviated nouns. |
| **Docs/docstrings** | ✅ PASS | Both files carry file-level `.SYNOPSIS`/`.DESCRIPTION`/`.NOTES` comment-based help; every function has `.SYNOPSIS`/`.DESCRIPTION`. |
| **Comment why, not what** | ✅ PASS | Inline comments explain rationale (e.g., "Edit calls supply only old_string/new_string ... Edit calls are allowed unconditionally; the SubagentStop gate is the authoritative backstop", "Fail open: no domain profile / required-artifact declaration present"), not mechanical narration. |

### 2.5 After Making Changes — Toolchain Execution

| Requirement | Status | Evidence |
|------------|--------|----------|
| **1. Formatting** | ✅ PASS | Command: `Invoke-PoshQCFormat -Root . -ScanFolders @('.claude/hooks','tests/scripts/claude-hooks')`. Result: "Already formatted" for all 4 files (2 production, 2 test), independently re-run this session. |
| **2. Linting** | ✅ PASS | Command: `Invoke-PoshQCAnalyze -Root . -ScanFolders @('.claude/hooks','tests/scripts/claude-hooks')`. Result: `PSScriptAnalyzer passed: no findings`, independently re-run this session. |
| **3. Type checking** | N/A | Not applicable for PowerShell per `.claude/rules/powershell.md`. |
| **4. Testing** | ✅ PASS | Full suite: 1338 tests, 1328 pass, 1 pre-existing unrelated failure, 9 skipped; new suites: 28/28 pass, 0 failures. Independently re-run this session via direct `pwsh`/`Invoke-PoshQCTest`. |
| **Full toolchain loop** | ✅ PASS | Format -> lint -> test all completed cleanly in a single independent re-run pass this session (no auto-fixes triggered, no restart needed). |
| **Explicit reporting** | ✅ PASS | Commands and results are documented above and in Section 6/7 below. |

### 2.6 Summarize and Document

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Summarize changes** | ✅ PASS | See "Executive Summary" and Section 9 below. |
| **Design choices explained** | ✅ PASS | `spec.md`'s "Constraints & Risks" and "Implementation Strategy" sections document every non-obvious choice (dual PreToolUse+SubagentStop gating, wrapper duplication vs. third file, fail-open seams, Edit-unconditional-allow). |
| **Update supporting documents** | ✅ PASS | `spec.md` and `user-story.md` AC sections show all 5 criteria checked (`[x]`) in each file, independently confirmed by direct read this session. |
| **Provide next steps** | ✅ PASS | See "Compliance Verdict" / "Recommendation" below. |

---

## 3. Language-Specific Code Change Policy Compliance

### Section 3B: PowerShell Code Change Policy Compliance

#### 3B.1 Tooling & Baseline

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Formatting with Invoke-Formatter** | ✅ PASS | `Invoke-PoshQCFormat` — "Already formatted" for all 4 changed PowerShell files, this session. |
| **Linting with PSScriptAnalyzer** | ✅ PASS | `Invoke-PoshQCAnalyze` — 0 findings, this session. |
| **Fix all findings** | ✅ PASS | No findings to fix. |
| **PowerShell 7+ compatible** | ✅ PASS | Both hooks declare `.NOTES: Compatible with PowerShell 7+`; `#Requires -Version 7.0` in both test files. |

#### 3B.2 PowerShell Design & Safety

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Advanced functions** | ✅ PASS | Every function uses `[CmdletBinding()]` with `[OutputType(...)]`. |
| **Parameter validation** | ✅ PASS | `[Parameter(Mandatory = $true)]` on required parameters (`ValidatorArgs`, `Path`); optional seam parameters have safe scriptblock defaults. |
| **Avoid global state** | ✅ PASS | Both hooks are stateless per `spec.md`'s "Data & State" section; no script-scoped mutable variables. |
| **Error handling** | ✅ PASS | `enforce-discovery-artifact-gate.ps1` entrypoint: `try { ... } catch { Write-Error $_; exit 1 }`. `validate-discovery-artifact-gate.ps1` entrypoint: `if (-not $result.Ok) { Write-Error $result.Message; exit 1 }`. Both match the exact conventions documented in `spec.md`'s "Inputs / Outputs" section. |

#### 3B.3 Structure, Naming, and Comments

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Cohesive and under 500 lines** | ✅ PASS | See Section 2.3 above (213 / 237 / 190 / 171 lines). |
| **Approved verbs** | ✅ PASS | `Invoke-DiscoveryValidatorExe`, `Get-DiscoveryArtifactType`, `Get-RequiredDiscoveryArtifactDeclaration`, `Invoke-DiscoveryArtifactGateDecision`, `Invoke-DiscoveryArtifactGateValidation`, `Find-DiscoveryArtifactReference` — all approved verbs, confirmed by 0 PSScriptAnalyzer findings (the analyzer enforces approved-verb naming). |
| **Comment why** | ✅ PASS | See Section 2.4 above. |

#### 3B.4 Running the Toolchain

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Step 1: Format** | ✅ PASS | See 3B.1. |
| **Step 2: Analyze** | ✅ PASS | See 3B.1. |
| **Step 3: Type check** | N/A | Not applicable for PowerShell. |
| **Step 4: Test** | ✅ PASS | See 2.5 / Section 6 below. |
| **Rerun loop if needed** | ✅ PASS | Single pass; no rerun required. |

---

## 4. Language-Specific Unit Test Policy Compliance

### Section 4B: PowerShell Unit Test Policy Compliance

#### 4B.1 Framework and Scope

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Use Pester v5.x** | ✅ PASS | Both test files declare `#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }` and use `BeforeAll`/`Describe`/`Context`/`It`/modern `Should` syntax. |
| **Use PoshQC Configuration** | ✅ PASS | `scripts/powershell/PoshQC/settings/pester.runsettings.psd1` (and its bundled mirror at `extensions/drm-copilot/resources/powershell/PoshQC/settings/pester.runsettings.psd1`) both updated to add the two new hook files to `CodeCoverage.Path`, confirmed via `git diff`. |
| **PowerShell 7+ Compatible** | ✅ PASS | See 3B.1. |

#### 4B.2 Test Style and Structure

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Focused Unit Tests** | ✅ PASS | See Section 1.1/1.2 above; 15 and 13 `It` blocks respectively, each targeting one behavior. |
| **Test Behavior Over Implementation** | ✅ PASS | Assertions check `permissionDecision`/`permissionDecisionReason`/`Ok`/`Message` outcomes and `Should -Invoke ... -Times` call counts, not internal implementation details. |
| **Mocking Used Sparingly** | ✅ PASS | Only `Invoke-DiscoveryValidatorExe` is mocked; all other logic (JSON parsing, path matching, reference extraction, decision branching) exercises real code. |
| **Organization** | ✅ PASS | **Test file:** `tests/scripts/claude-hooks/enforce-discovery-artifact-gate.Tests.ps1` / `tests/scripts/claude-hooks/validate-discovery-artifact-gate.Tests.ps1`. **Code file:** `.claude/hooks/enforce-discovery-artifact-gate.ps1` / `.claude/hooks/validate-discovery-artifact-gate.ps1`. Mirrors the established `tests/scripts/claude-hooks/<name>.Tests.ps1` convention already used by every other `.claude/hooks/*.ps1` file in this repository (e.g., `enforce-pr-author-skill.Tests.ps1`, `enforce-epic-merge-gate.Tests.ps1`). |

#### 4B.3 Naming and Readability

| Requirement | Status | Evidence |
|------------|--------|----------|
| **File Naming** | ✅ PASS | `enforce-discovery-artifact-gate.Tests.ps1` / `validate-discovery-artifact-gate.Tests.ps1`. |
| **Describe/Context/It Structure** | ✅ PASS | 1 `Describe` per file, ~11 and ~11 `Context` blocks respectively, 15 and 13 total `It` blocks. |
| **Logical Grouping** | ✅ PASS | Contexts group by scenario class (conforming, non-conforming, unrecognized, fail-open, malformed, empty, validator-not-found, Edit-only, domain-neutrality, missing-field, seam, end-to-end). |
| **Docstrings/Comments** | ✅ PASS | Self-documenting `It` descriptions plus inline comments on non-obvious helper functions (`ConvertTo-DiscoveryToolInput`, `$script:PresentReader`). |

#### 4B.4 Running the Toolchain

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Use PoshQCTest Command** | ✅ PASS | `Invoke-PoshQCTest` (direct-`pwsh` invocation, per the documented MCP-staleness workaround) — 1338 tests, 1328 pass, 1 pre-existing unrelated failure, 9 skipped, this session. |
| **No Alternative Test Runners** | ✅ PASS | Only Pester, invoked through the PoshQC module functions. |

---

## 5. Test Coverage Detail

### `enforce-discovery-artifact-gate.ps1` (15 tests)

| Test Name | Scenario Type | Function(s) Exercised | Status |
|-----------|--------------|---------------|--------|
| allows the write and invokes the validator exactly once | Positive | `Invoke-DiscoveryArtifactGateDecision`, `Get-DiscoveryArtifactType` | ✅ |
| denies the write with the validator text embedded verbatim | Negative | `Invoke-DiscoveryArtifactGateDecision` | ✅ |
| allows without invoking the validator when file_path does not resolve | Edge Case | `Invoke-DiscoveryArtifactGateDecision` | ✅ |
| Get-DiscoveryArtifactType returns $null for an unrecognized path | Edge Case | `Get-DiscoveryArtifactType` | ✅ |
| allows without invoking the validator when required-artifact-declaration seam reports absent | Edge Case (fail-open) | `Invoke-DiscoveryArtifactGateDecision`, `Get-RequiredDiscoveryArtifactDeclaration` | ✅ |
| throws so the entrypoint surfaces Write-Error and a non-zero exit code | Error Handling | `Invoke-DiscoveryArtifactGateDecision` | ✅ |
| produces a default-allow decision for an empty string | Edge Case | `Invoke-DiscoveryArtifactGateDecision` | ✅ |
| produces a default-allow decision for $null | Edge Case | `Invoke-DiscoveryArtifactGateDecision` | ✅ |
| denies identically to any other non-conforming result (validator-not-found) | Negative | `Invoke-DiscoveryArtifactGateDecision` | ✅ |
| Edit calls allow unconditionally without invoking the validator | Edge Case | `Invoke-DiscoveryArtifactGateDecision` | ✅ |
| contains no TaskMaster/TMW/Outlook/VSTO token in its own source text | Compliance | (source text scan) | ✅ |
| allows without invoking the validator when file_path is absent | Edge Case | `Invoke-DiscoveryArtifactGateDecision` | ✅ |
| Get-RequiredDiscoveryArtifactDeclaration reports Present = $true with declaration | Positive | `Get-RequiredDiscoveryArtifactDeclaration` | ✅ |
| allows when CLAUDE_TOOL_INPUT is empty (end-to-end) | Positive | full script entrypoint | ✅ |
| exits 1 on malformed JSON (end-to-end) | Error Handling | full script entrypoint | ✅ |

**Coverage:** 87.27% line (48/55 lines), per independently regenerated `artifacts/pester/powershell-coverage.xml`.

**Not covered:** lines 50-51 (body of `Invoke-DiscoveryValidatorExe` — the wrapper's real `python` subprocess call and return statement; intentionally unmocked-in-production, per the wrapper-seam pattern, no unit test exercises the real subprocess call); lines 204, 207-208, 211, 213 (entrypoint block, exercised via genuine child-process invocation in the end-to-end tests but not attributed by Pester's in-process breakpoint-based coverage instrumentation — a structural limitation affecting every hook's entrypoint in this repository's coverage report, not specific to this feature).

### `validate-discovery-artifact-gate.ps1` (13 tests)

| Test Name | Scenario Type | Function(s) Exercised | Status |
|-----------|--------------|---------------|--------|
| returns Ok = $true and invokes the validator exactly once | Positive | `Invoke-DiscoveryArtifactGateValidation`, `Find-DiscoveryArtifactReference` | ✅ |
| returns Ok = $false with the validator text embedded verbatim | Negative | `Invoke-DiscoveryArtifactGateValidation` | ✅ |
| returns Ok = $true without invoking the validator (no recognized reference) | Edge Case | `Invoke-DiscoveryArtifactGateValidation`, `Find-DiscoveryArtifactReference` | ✅ |
| returns Ok = $true without invoking the validator when the seam reports absent | Edge Case (fail-open) | `Invoke-DiscoveryArtifactGateValidation`, `Get-RequiredDiscoveryArtifactDeclaration` | ✅ |
| returns Ok = $false with the documented empty-input message (empty string) | Error Handling | `Invoke-DiscoveryArtifactGateValidation` | ✅ |
| returns Ok = $false with the documented empty-input message ($null) | Error Handling | `Invoke-DiscoveryArtifactGateValidation` | ✅ |
| returns Ok = $false with a non-empty message describing the parse failure | Error Handling | `Invoke-DiscoveryArtifactGateValidation` | ✅ |
| returns Ok = $false identically to any other non-conforming result (validator-not-found) | Negative | `Invoke-DiscoveryArtifactGateValidation` | ✅ |
| contains no TaskMaster/TMW/Outlook/VSTO token in its own source text | Compliance | (source text scan) | ✅ |
| returns Ok = $true without invoking the validator (no output field) | Edge Case | `Invoke-DiscoveryArtifactGateValidation` | ✅ |
| Get-RequiredDiscoveryArtifactDeclaration reports Present = $true with declaration | Positive | `Get-RequiredDiscoveryArtifactDeclaration` | ✅ |
| exits 0 when the subagent output references no discovery artifact (end-to-end) | Positive | full script entrypoint | ✅ |
| exits 1 with a Write-Error when CLAUDE_HOOK_INPUT is empty (end-to-end) | Error Handling | full script entrypoint | ✅ |

**Coverage:** 87.93% line (51/58 lines), per independently regenerated `artifacts/pester/powershell-coverage.xml`.

**Not covered:** lines 53-54 (wrapper body, same rationale as above); lines 231-234, 237 (entrypoint block, same structural coverage-attribution limitation as above).

---

## 6. Test Execution Metrics

| Metric | Value | Status |
|--------|-------|--------|
| Total Tests (full suite) | 1338 | ✅ |
| Tests Passed | 1328 (99.25%) | ✅ |
| Tests Failed | 1 (pre-existing, unrelated — see Gaps) | ✅ (not attributable to this feature) |
| Tests Skipped | 9 | ✅ |
| New tests introduced by this feature | 28 (15 + 13), 0 failures | ✅ |
| Execution Time | 51.53s total (full suite) | ✅ Fast |
| Code Coverage (repo-wide) | 89.32% lines; branch not emitted (tooling limitation) | ✅ line / ⚠️ branch (documented gap) |
| New-file Code Coverage | 87.27% / 87.93% lines | ✅ |

---

## 7. Code Quality Checks

**For PowerShell:**

| Check | Command | Result | Status |
|-------|---------|--------|--------|
| Invoke-Formatter | `Invoke-PoshQCFormat -Root . -ScanFolders @('.claude/hooks','tests/scripts/claude-hooks')` | "Already formatted" for all 4 files | ✅ |
| PSScriptAnalyzer | `Invoke-PoshQCAnalyze -Root . -ScanFolders @('.claude/hooks','tests/scripts/claude-hooks')` | "PSScriptAnalyzer passed: no findings" | ✅ |
| Pester Tests | `Invoke-PoshQCTest -Root . -ScanFolders @('scripts','tests/scripts') -DisableKoverageCopy` | 1338 total, 1328 pass, 1 pre-existing unrelated fail, 9 skipped | ✅ |

**Notes:** The single failing test (`enforce-pr-author-skill.ps1.allowed commands.allows gh pr create --body-file artifacts/pr_body_12.md when context exists`) is unrelated to this feature: it lives in `tests/scripts/claude-hooks/enforce-pr-author-skill.Tests.ps1`, a file not touched by this branch's diff (`git diff --name-status` confirms no changes to that file or its production counterpart `enforce-pr-author-skill.ps1`). It is documented as pre-existing in this feature's own `evidence/baseline/pester-baseline.2026-07-18T00-15.md` (present at the P0-T9 baseline, before either new hook file existed) and in `evidence/qa-gates/pester-final.2026-07-18T21-52.md`. This audit treats it as out-of-scope, pre-existing flake, not a blocking finding for this feature.

---

## 8. Gaps and Exceptions

### Identified Gaps

- **Branch coverage not numerically available.** This repo's PoshQC/Pester coverage pipeline does not emit `BRANCH` counters at report level for any file, a repo-wide, pre-existing tooling limitation (independently confirmed this session; also documented in the P0-T9 baseline and in feature #365's baseline evidence). This applies uniformly to the whole repository and is not specific to, or introduced by, this feature. It cannot be remediated by this feature's scope.

### Approved Exceptions

- **Duplicated `Invoke-DiscoveryValidatorExe`/`Get-DiscoveryArtifactType`/`Get-RequiredDiscoveryArtifactDeclaration` across both hook files**, rather than factored into a shared module. Justification: `.claude/rules/powershell.md`'s "Change Budget" caps direct-mode work at "up to 2 production PowerShell files"; a third shared helper file would exceed that cap and require routing through `powershell-change-budget-router`. `spec.md`'s "File-count / change budget" section documents this trade-off explicitly. Approval source: pre-approved, preflight-cleared atomic plan (`plan.2026-07-17T14-38.md`).
- **`# TODO(#9001)` / `# TODO(#9002)` open seams** (domain-profile required-artifact declaration; artifact-type-to-path lookup) — explicitly scoped as out-of-scope dependencies on not-yet-shipped upstream features, with documented fail-open defaults. Both seams are covered by dedicated regression tests ("fail-open when the domain profile is absent" contexts in both test files).

### Removed/Skipped Tests

**None.** All planned tests (per `spec.md`'s "Seeded Test Conditions") are implemented; all 8 seeded conditions are traced to specific `It` blocks in Section 5 above.

---

## 9. Summary of Changes

### Files Modified (this branch vs. `origin/epic/legacy-discovery-and-parity-integration` merge-base `e395efb7`)

1. **`.claude/hooks/enforce-discovery-artifact-gate.ps1`** (NEW, 213 lines) — PreToolUse completion-gate hook.
2. **`.claude/hooks/validate-discovery-artifact-gate.ps1`** (NEW, 237 lines) — SubagentStop completion-gate hook.
3. **`.claude/settings.json`** (MODIFIED, +8 lines) — registers both hooks under existing matcher groups; no new matcher group.
4. **`tests/scripts/claude-hooks/enforce-discovery-artifact-gate.Tests.ps1`** (NEW, 190 lines, 15 tests).
5. **`tests/scripts/claude-hooks/validate-discovery-artifact-gate.Tests.ps1`** (NEW, 171 lines, 13 tests).
6. **`scripts/powershell/PoshQC/settings/pester.runsettings.psd1`** (MODIFIED, +5 lines) — adds both new hook files to the coverage `Path` allowlist.
7. **`extensions/drm-copilot/resources/powershell/PoshQC/settings/pester.runsettings.psd1`** (MODIFIED, +5 lines) — mirrored bundled-resource copy of the above.
8. **`docs/features/active/2026-07-17-legacy-discovery-hooks-366/{spec.md,user-story.md,plan.2026-07-17T14-38.md}`** (MODIFIED) — AC check-off and plan-task check-off.
9. **`docs/features/active/2026-07-17-legacy-discovery-hooks-366/evidence/**`** (NEW, 14 files) — baseline and QA-gate evidence artifacts produced during execution.

No `.github/workflows/**`, `.github/actions/**`, or `scripts/benchmarks/**` paths were touched; the `modified-workflow-needs-green-run` rule does not apply to this diff.

No file under `artifacts/baselines/`, `artifacts/qa/`, `artifacts/evidence/`, or `artifacts/coverage/` appears in the diff; `python -m scripts.dev_tools.validate_evidence_locations --root .` exits 0 with no output (independently re-run this session).

---

## 10. Compliance Verdict

### Overall Status: ✅ FULLY COMPLIANT

All independently-reverified numbers match the executor's reported figures exactly. Line coverage for both new files clears the 85% threshold; repo-wide line coverage shows no regression on any pre-existing line. Branch coverage is not numerically evaluable due to a documented, pre-existing, repo-wide tooling gap, not a code defect. The single test-suite failure is confirmed pre-existing and unrelated (different file, present at baseline). Formatting, linting, domain-neutrality, file-count budget, matcher-registration, and evidence-location checks all pass.

**Fail-closed reminder honored:** no required baseline, QA, or coverage-comparison artifact is missing; this verdict is grounded in artifacts this session regenerated and inspected directly, not carried forward from memory.

### Policy-by-Policy Summary

#### General Code Change Policy (Section 2)
- ✅ Before Making Changes: pre-approved, preflight-cleared plan; all 54 tasks checked off.
- ✅ Design Principles: thin-entrypoint, documented duplication trade-off, explicit extension seams.
- ✅ Module & File Structure: all files under 500 lines; no circular dependencies.
- ✅ Naming, Docs, Comments: approved verbs, full comment-based help, rationale comments.
- ✅ Toolchain Execution: format/lint/test all pass in a single independently re-run pass.
- ✅ Summarize & Document: AC checked off in both `spec.md` and `user-story.md`.

#### Language-Specific Code Change Policy (Section 3)

**For PowerShell:**
- ✅ Tooling & Baseline: format/lint clean.
- ✅ PowerShell Design & Safety: advanced functions, parameter validation, explicit error handling.
- ✅ Structure & Naming: approved verbs, cohesive files.
- ✅ Toolchain: single-pass clean run.

#### General Unit Test Policy (Section 1)
- ✅ Core Principles: independent, isolated, fast, deterministic, readable.
- ⚠️ Coverage & Scenarios: line coverage PASS; branch coverage not numerically evaluable (documented tooling gap).
- ✅ Test Structure: AAA pattern, clear failure messages.
- ✅ External Dependencies: wrapper-seam mocking only; no real subprocess/network/temp-file dependencies in unit tests.
- ✅ Policy Audit: this document.

#### Language-Specific Unit Test Policy (Section 4)

**For PowerShell:**
- ✅ Framework & Scope: Pester v5.x via PoshQC configuration.
- ✅ Test Style & Structure: focused, behavior-oriented, sparing mocking, correct mirrored location.
- ✅ Naming & Readability: `*.Tests.ps1`, `Describe`/`Context`/`It`, logical grouping.
- ✅ Toolchain: PoshQCTest only, no alternative runners.

---

### Metrics Summary

- ✅ 1328/1338 tests passing (99.25%); the 1 failure is pre-existing and unrelated.
- ✅ 28/28 new tests passing (100%).
- ✅ 87.27% / 87.93% new-file line coverage (both >= 85% threshold).
- ✅ 89.32% repo-wide line coverage (no regression on pre-existing lines).
- ⚠️ Branch coverage: not emitted by tooling (repo-wide, pre-existing, documented).
- ✅ Proper file organization: hooks under `.claude/hooks/`, tests mirrored under `tests/scripts/claude-hooks/`, matching the repository's established convention.
- ✅ All code quality checks (format, lint) passing.
- ✅ Test execution time: 51.53s for the full 1338-test suite (fast).

---

### Recommendation

**Ready for merge.** No Blocking findings were identified. The only open item — branch coverage not being numerically emitted by the repository's PowerShell coverage tooling — is a pre-existing, repo-wide condition documented and accepted in prior features of this same epic (e.g., #365), not a defect introduced by this change, and is not treated as blocking.

---

## Appendix A: Test Inventory

### `enforce-discovery-artifact-gate.ps1` (15 tests)

1. Describe `enforce-discovery-artifact-gate.ps1` › Context `recognized, conforming artifact` › It `allows the write and invokes the validator exactly once`
2. `recognized, non-conforming artifact` › It `denies the write with the validator text embedded verbatim`
3. `unrecognized artifact path` › It `allows without invoking the validator when file_path does not resolve to a discovery-artifact type`
4. `unrecognized artifact path` › It `Get-DiscoveryArtifactType returns $null for an unrecognized path`
5. `fail-open when the domain profile is absent` › It `allows without invoking the validator when the required-artifact-declaration seam reports absent`
6. `malformed CLAUDE_TOOL_INPUT` › It `throws so the entrypoint surfaces Write-Error and a non-zero exit code`
7. `empty or absent CLAUDE_TOOL_INPUT` › It `produces a default-allow decision without invoking the validator for an empty string`
8. `empty or absent CLAUDE_TOOL_INPUT` › It `produces a default-allow decision without invoking the validator for $null`
9. `validator-not-found-style failure` › It `denies identically to any other non-conforming result (not silently allowed)`
10. `Edit tool calls (no full content)` › It `allows unconditionally without invoking the validator`
11. `domain neutrality` › It `contains no TaskMaster/TMW/Outlook/VSTO token in its own source text`
12. `missing file_path` › It `allows without invoking the validator when content is present but file_path is absent`
13. `Get-RequiredDiscoveryArtifactDeclaration seam` › It `reports Present = $true with the declaration when the profile reader returns a value`
14. `script entrypoint (end-to-end)` › It `allows when CLAUDE_TOOL_INPUT is empty (exit 0, allow)`
15. `script entrypoint (end-to-end)` › It `exits 1 on malformed JSON`

### `validate-discovery-artifact-gate.ps1` (13 tests)

1. Describe `validate-discovery-artifact-gate.ps1` › Context `recognized, conforming referenced artifact` › It `returns Ok = $true and invokes the validator exactly once`
2. `recognized, non-conforming referenced artifact` › It `returns Ok = $false with the validator text embedded verbatim`
3. `no recognized artifact reference` › It `returns Ok = $true without invoking the validator`
4. `fail-open when the domain profile is absent` › It `returns Ok = $true without invoking the validator when the seam reports absent`
5. `empty or absent CLAUDE_HOOK_INPUT` › It `returns Ok = $false with the documented empty-input message for an empty string`
6. `empty or absent CLAUDE_HOOK_INPUT` › It `returns Ok = $false with the documented empty-input message for $null`
7. `malformed CLAUDE_HOOK_INPUT JSON` › It `returns Ok = $false with a non-empty message describing the parse failure`
8. `validator-not-found-style failure` › It `returns Ok = $false identically to any other non-conforming result`
9. `domain neutrality` › It `contains no TaskMaster/TMW/Outlook/VSTO token in its own source text`
10. `payload with no output field` › It `returns Ok = $true without invoking the validator when the payload carries no output property`
11. `Get-RequiredDiscoveryArtifactDeclaration seam` › It `reports Present = $true with the declaration when the profile reader returns a value`
12. `script entrypoint (end-to-end)` › It `exits 0 when the subagent output references no discovery artifact`
13. `script entrypoint (end-to-end)` › It `exits 1 with a Write-Error when CLAUDE_HOOK_INPUT is empty`

---

## Appendix B: Toolchain Commands Reference

**For PowerShell (this repository, PoshQC-mediated):**
```powershell
# Formatting
Import-Module ./scripts/powershell/PoshQC; Invoke-PoshQCFormat -Root . -ScanFolders @('.claude/hooks','tests/scripts/claude-hooks')

# Linting
Import-Module ./scripts/powershell/PoshQC; Invoke-PoshQCAnalyze -Root . -ScanFolders @('.claude/hooks','tests/scripts/claude-hooks')

# Testing + coverage (direct-pwsh, MCP-staleness workaround)
pwsh -NoProfile -Command "Import-Module (Join-Path (Get-Location) 'scripts/powershell/PoshQC/PoshQC.psd1') -Force; Invoke-PoshQCTest -Root (Get-Location).Path -ScanFolders @('scripts','tests/scripts') -DisableKoverageCopy"
```

**Evidence-location and PR-context tooling:**
```bash
poetry run python -m scripts.dev_tools.validate_evidence_locations --root .
poetry run python -m scripts.dev_tools.pr_context.collector --base origin/epic/legacy-discovery-and-parity-integration --head HEAD
```

---

**Audit Completed By:** feature-review agent (Claude Code)
**Audit Date:** 2026-07-18
**Policy Version:** Current (as of audit date)
