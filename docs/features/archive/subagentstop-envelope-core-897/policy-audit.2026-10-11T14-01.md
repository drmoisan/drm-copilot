# Policy Compliance Audit: subagentstop-envelope-core (E1, issue #897)

---

**Audit Date:** 2026-10-11  
**Code Under Test:** `.claude/hooks/subagentstop-envelope.ps1` (NEW), `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/subagentstop-envelope.ps1` (NEW, byte-identical mirror), `tests/scripts/claude-hooks/subagentstop-envelope.Tests.ps1` (NEW), `tests/fixtures/claude-hooks/Invoke-SubagentStopBlock.Fixture.ps1` (NEW), `tests/scripts/claude-runtime/claude-settings.Tests.ps1` (MODIFIED), `.claude/settings.json` (MODIFIED), `extensions/drm-copilot/resources/claude-customizations/.claude/settings.json` (MODIFIED), `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json` (MODIFIED), plus 40 Markdown files under `docs/features/active/subagentstop-envelope-core-897/` (plan, spec, evidence).

**Base branch:** `origin/epic/subagentstop-envelope-integration` @ `64642312b5aa83b66d5d9cc0ce131d1308a4182a` (merge base, equal to the base tip). **Head:** `bug/subagentstop-envelope-core-exec-897` @ `806cf067aa28840cf1438a0ff50420cbee0a57d4`. Diff range: `git diff 64642312b5aa83b66d5d9cc0ce131d1308a4182a...HEAD` (48 files, +2191/-107).

**Coverage Metrics by Language:**

| Language | Files Changed | Tests | Test Result | Baseline Coverage | Post-Change Coverage | New Code Coverage |
|----------|--------------|-------|-------------|-------------------|---------------------|-------------------|
| PowerShell | 5 files (2 production: helper + mirror; 3 test: suite, fixture, settings suite) | 9867 total (full run); 82 added (78 helper suite + 4 settings regressions) | PASS 9867 pass, 0 fail, 10 skipped | 89.16% cmds (repo-wide); `.claude/hooks` package 96.19% lines (5226/5433) | 88.67% cmds, 89.84% lines (repo-wide); `.claude/hooks` package 96.23% lines (5286/5493) | 100.00% lines (60/60), 100.00% cmds (73/73) for `.claude/hooks/subagentstop-envelope.ps1` |
| JSON | 3 files | N/A | PASS validation (3/3 parse; canonical and bundled `settings.json` byte-identical) | N/A (config files) | N/A (config files) | N/A |

Languages with zero changed files on the branch: Python, TypeScript, C#, Bash. No coverage verdict is required for them. (Python and Jest parity tests were executed as consumers of the JSON changes; they are reported in Section 7 but carry no coverage obligation because no `.py` or `.ts` file changed.)

### Coverage Evidence Checklist

- TypeScript baseline coverage artifact: `N/A - out of scope` (no TypeScript file changed)
- TypeScript post-change coverage artifact: `N/A - out of scope` (no TypeScript file changed)
- PowerShell baseline coverage artifact: `docs/features/active/subagentstop-envelope-core-897/evidence/baseline/p0-pester-coverage.md` (records the [P0-T9] run; the XML at `artifacts/pester/powershell-coverage.xml` was later overwritten by the final run, so the baseline figures are taken from this record)
- PowerShell post-change coverage artifact: `docs/features/active/subagentstop-envelope-core-897/evidence/qa-gates/final-pester-coverage.md` and `evidence/qa-gates/final-helper-coverage.md`; the underlying JaCoCo XML (`artifacts/pester/powershell-coverage.xml`, report name `Pester (10/11/2026 13:12:11)`, written 2026-10-11 13:12:33 local) was located in the executor worktree and re-parsed by this review (see Section 1.2.1)
- Per-language comparison summary: Section 1.2.1 of this audit; `evidence/qa-gates/coverage-comparison.md`

**Non-negotiable verdict rule:** No policy audit may report PASS unless it includes numeric baseline and post-change coverage metrics for every language in scope, plus changed/new-code coverage when required.

**Fail-closed rule:** If any required baseline artifact, QA artifact, or coverage-comparison artifact is missing, the verdict must be BLOCKED or INCOMPLETE, never PASS.

**Evidence rule:** Do not synthesize or backfill missing audit evidence from memory or inference. If evidence is missing, stop and list the exact missing artifact paths.

---

## Executive Summary

This audit covers the full branch diff of `bug/subagentstop-envelope-core-exec-897` against `origin/epic/subagentstop-envelope-integration` (merge base `64642312b`). The change adds a dot-sourced PowerShell helper (`Read-SubagentStopEnvelope`, `Get-SubagentStopEnvelopeAnomalyReason`, `Exit-SubagentStopBlock`) with a byte-identical bundled mirror and a `core.json` manifest entry, removes the inert inline SubagentStop command from both `settings.json` copies, and adds a 78-test Pester suite, a test-only fixture script, and four settings regression tests.

Evidence sources: `artifacts/pr_context.summary.txt` (primary), `artifacts/pr_context.appendix.txt`, direct inspection of the diff, the feature evidence folders (`evidence/baseline`, `evidence/regression-testing`, `evidence/qa-gates`, `evidence/other`), and an independent re-parse of the executor's coverage XML. The review did not re-run the PowerShell toolchain; it verified the recorded evidence against the current files (the five changed PowerShell/JSON files in the executor worktree are byte-identical to the review head; verified with `cmp`).

Outcome: every policy section evaluated is PASS. Format, analyzer, and Pester gates closed in a single pass (`evidence/qa-gates/final-qc-loop.md`, `FINAL_PASS: 1`). New-code line coverage is 100.00%; repo-wide PowerShell line coverage is 89.84% (threshold 85%). One non-blocking observation is recorded in Section 8: the repo-wide command-coverage total moved from 89.16% to 88.67% between the baseline and final runs, and the arithmetic shows the movement originates outside the changed files (the `.claude/hooks` package gained 60 covered lines and 0 missed lines).

**Policy documents evaluated:**
- [x] `general-code-change.instructions.md` (mirrored by `.claude/rules/general-code-change.md`)
- [x] `general-unit-test.instructions.md` (mirrored by `.claude/rules/general-unit-test.md`)
- [x] `.claude/rules/quality-tiers.md` (`.claude/hooks` is classified T3 in `quality-tiers.yml`)
- [x] `.claude/rules/tonality.md`

**Language-specific policies evaluated:**
- N/A `python-code-change.instructions.md` + `python-unit-test.instructions.md` (no Python file changed)
- [x] `powershell-code-change.instructions.md` + `powershell-unit-test.instructions.md` (mirrored by `.claude/rules/powershell.md`)
- N/A Bash: shfmt + shellcheck + bats (no Bash file changed)
- [x] JSON: strict-JSON parse of the three changed files; byte-identity of the two `settings.json` copies

PowerShell is the only coverage language with changed files. Its coverage verdict is PASS (Section 1.2.1). JSON changes were validated by parsing and by the existing parity tests.

**Temporary artifacts cleanup:**
- [x] All temporary/one-time scripts created during development have been deleted: `git status --porcelain` on the executor worktree printed nothing at [P5-T13] (`evidence/qa-gates/final-scope.md`); the review worktree is clean at `806cf067a`. The probe script used for the live differential is retained as evidence text (`evidence/other/subagentstop-probe.2026-10-11T12-01.ps1.txt`), not as an executable file.
- [x] Any ongoing tooling scripts are fully tested and compliant with repo policies: the only new non-test script is the helper itself (100% line coverage). `tests/fixtures/claude-hooks/Invoke-SubagentStopBlock.Fixture.ps1` is a test-only entry point exercised by the `&`-route test.
- Scripts created during development and disposition: `subagentstop-probe.2026-10-11T12-01.ps1` (research probe; kept as `.txt` evidence, not executable); `Invoke-SubagentStopBlock.Fixture.ps1` (kept; exercised by `subagentstop-envelope.Tests.ps1`).

---

## Rejected Scope Narrowing

None detected. The caller prompt supplied the resolved base branch, the merge-base SHA, the active feature folder, the `full-bug` work mode, and the instruction to treat the PR-body half of AC-29 as pending-PR. None of these narrows the audit scope below the full branch-vs-base diff; the work-mode and AC-29 instructions match `acceptance-criteria-tracking` and `feature-review-workflow`. The audit scope used is the full diff `64642312b...806cf067a` (48 files).

---

## Evidence Location Compliance

- `python -I scripts/dev_tools/validate_evidence_locations.py --root .` exit code: 0 (no violations reported).
- Branch diff scan for `artifacts/baselines/`, `artifacts/qa/`, `artifacts/evidence/`, `artifacts/coverage/`: `git diff --name-status 64642312b...HEAD` lists no path under `artifacts/`. All 40 evidence files are under `docs/features/active/subagentstop-envelope-core-897/evidence/{baseline,regression-testing,qa-gates,other}/`.
- `EVIDENCE_LOCATION_OVERRIDE_REJECTED`: none; no caller instruction supplied a non-canonical evidence path.
- Verdict: PASS.

---

## 1. General Unit Test Policy Compliance

### 1.1 Core Principles

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Independence** - Tests run in any order | PASS | `subagentstop-envelope.Tests.ps1` dot-sources the helper once in `BeforeAll` and every `It` builds its own inline input; the three stdin tests and the `&`-route test save and restore `[Console]::In`, `[Console]::Error`, and `$global:LASTEXITCODE` in `finally` blocks (lines 182-220, 256-267). The settings regressions parse both JSON copies into `$script:SettingsCopies` in `BeforeAll` and only read them. |
| **Isolation** - Each test targets single behavior | PASS | One `It` per contract row via `-TestCases` (22 input rows, 4 `stop_hook_active` rows, 6 name-field rows, 6 anomaly codes, 4 invalid codes); separate `Context` blocks for source constraints, input rows, derived fields, BOM/CRLF, stdin default, anomaly reasons, and `Exit-SubagentStopBlock`. |
| **Fast Execution** - Tests complete quickly | PASS | Targeted run of six containers (862 tests) completed within the [P5-T3] session; the full self-hosted run of 9867 tests completed in 556.11 s (`evidence/qa-gates/final-pester-coverage.md`). No test sleeps or waits. |
| **Determinism** - Consistent results | PASS | No randomness, clock reads, network, file creation, or child processes. stdin is replaced with an in-memory `StringReader`; stderr with a `StringWriter`. The `&`-route test runs the fixture in-process. Fail-before (`evidence/regression-testing/p2-helper-suite-fail-before.md`, exit 1) and pass-after (`p3-helper-suite-pass-after.md`, exit 0) runs are recorded. |
| **Readability & Maintainability** - Clear structure | PASS | Descriptive `It` names with templated `<Name>`/`<Field>`/`<Code>` tokens; a header comment states the contract under test and the no-file/no-process constraint; the test file is 278 lines. |

### 1.2 Coverage and Scenarios

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Baseline Coverage Documented** | PASS | **Baseline (pre-development):** repo-wide 89.16% commands (25,877 analyzed commands in 197 files); `.claude/hooks` package 96.19% lines (covered=5226, missed=207); helper not yet present (`SOURCEFILE_MATCHES: 0`)<br>**Command:** `Import-Module ./scripts/powershell/PoshQC/PoshQC.psd1 -Force; Invoke-PoshQCTest -Root (Get-Location).Path -SettingsPath scripts/powershell/PoshQC/settings/pester.runsettings.psd1`<br>**Timestamp:** 2026-10-11 12:45 (`evidence/baseline/p0-pester-coverage.md`) |
| **No Coverage Regression** | PASS | **Post-change coverage:** repo-wide 88.67% commands / 89.84% lines (16,064/17,881 lines, from the JaCoCo `LINE` counter); `.claude/hooks` package 96.23% lines (covered=5286, missed=207)<br>**Change:** repo-wide commands -0.49 points; `.claude/hooks` package +0.04 points lines (+60 covered, +0 missed)<br>**Status:** No regression on changed lines. The only changed PowerShell production file is the new helper (100.00%). The repo-wide command total moved down 0.49 points, which the package counters show is not attributable to any file in the diff (see Section 8, Identified Gaps, observation 1). Both totals remain above the 85% threshold. |
| **New Code Coverage ≥90%** | PASS | **New/modified files:** `.claude/hooks/subagentstop-envelope.ps1` (new; the mirror under `extensions/` is excluded from the Pester population by configuration and is byte-identical)<br>**New code coverage:** 100.00% lines (60/60), 100.00% commands (73/73), 3/3 methods<br>**Calculation method:** the review re-parsed the executor's `artifacts/pester/powershell-coverage.xml` (report `Pester (10/11/2026 13:12:11)`), selecting the `package` whose name ends with `/.claude/hooks` (not under `extensions/`) and its `sourcefile` named `subagentstop-envelope.ps1`; `SF_MISSED_LINES []`. Matches `evidence/qa-gates/final-helper-coverage.md`. |
| **Comprehensive Coverage** | PASS | **All functions tested:**<br>- `Get-SubagentStopEnvelopeAnomalyReason` (lines 20-52): 11 tests (6 codes, 1 distinctness, 4 invalid)<br>- `Read-SubagentStopEnvelope` (lines 54-169): 61 tests (22 rows x 2 `It` templates, 2 valid-envelope detail tests, 10 derived-field rows, 2 BOM/CRLF, 3 stdin)<br>- `Exit-SubagentStopBlock` (lines 171-191): 2 tests (`&` route; binding rejection)<br>**Untested code:** none (`SF_MISSED_LINES []`). |
| **Positive Flows** - Valid inputs | PASS | **All positive scenarios tested:**<br>- `classifies valid envelope ...`: full envelope with all four root fields -> `IsValid` true, `AssistantText` `plan-path: x`<br>- `returns the root fields of a valid envelope`: `StopHookActive`/`AgentType`/`HookEventName` taken from the root<br>- `keeps an ISO-8601 date-form message as the exact string`: `-DateKind String` behavior<br>- `classifies empty string message`: `""` message is valid<br>- `accepts a BOM-prefixed valid envelope`, `accepts a CRLF-formatted valid envelope`<br>- `reads the envelope from stdin when InputText is not bound`<br>- `returns a non-empty clause for <Code>` (6)<br>- `blocks through the & route with stderr and exit code 2`<br>**Total positive tests:** 15 |
| **Negative Flows** - Invalid inputs | PASS | **All negative scenarios tested:**<br>- `null input`, `empty string input`, `whitespace-only input`, `BOM-only input` -> `EmptyPayload`<br>- `non-JSON text`, `case-duplicate keys` -> `UnparseableJson`<br>- `empty array`, `single-element array`, `multi-element array`, `number root`, `string root`, `boolean root`, `JSON null root` -> `NonObjectEnvelope`<br>- `object without last_assistant_message` -> `MissingAssistantMessage`; `null last_assistant_message` -> `NullAssistantMessage`; number/boolean/object/array message -> `NonStringAssistantMessage`<br>- `throws ArgumentException for <Name>` (unknown, null, empty, case variant)<br>- `rejects an empty or null Message at parameter binding without exiting`<br>**Total negative tests:** 25 (19 rows + 4 invalid codes + 2 binding) |
| **Edge Cases** - Boundary conditions | PASS | **All edge cases tested:**<br>- single-element array (would be unwrapped without `-NoEnumerate`)<br>- ISO-8601 date-form string (would become `[datetime]` without `-DateKind String`)<br>- BOM-only input and BOM-prefixed valid input<br>- string `"true"` for `stop_hook_active` -> `$false`; non-string `5` for `agent_type`/`hook_event_name` -> `''`<br>- bound `-InputText ''` takes precedence over non-empty stdin<br>**Total edge case tests:** 9 |
| **Error Handling** - Error paths | PASS | **All error scenarios tested:**<br>- `treats a stdin read failure as EmptyPayload` (disposed `StringReader` passed to `[Console]::SetIn`)<br>- `ConvertFrom-Json` exception path via non-JSON text and case-duplicate keys<br>- `ArgumentException` from `Get-SubagentStopEnvelopeAnomalyReason` default branch<br>- `ParameterBindingException` from `Exit-SubagentStopBlock -Message ''`/`$null`<br>- result-shape test asserts no exception for all 22 rows (`emits exactly one object with exactly the seven contract properties for <Name>`)<br>**Total error handling tests:** 8 (plus 22 no-throw shape rows) |
| **Concurrency** - If applicable | N/A | The helper is a synchronous, single-invocation reader with no shared state. No concurrency behavior exists to test. |
| **State Transitions** - If applicable | N/A | The helper holds no state across calls. `StopHookActive` is a surfaced field, not a state machine; its four input rows are covered under derived fields. |

### 1.2.1 Per-Language Coverage Comparison

- PowerShell: Baseline: 89.16% commands (repo-wide); `.claude/hooks` package 96.19% lines -> Post-change: 88.67% commands / 89.84% lines (repo-wide); `.claude/hooks` package 96.23% lines. Change: -0.49 points commands repo-wide (origin outside the changed files; see Section 8); +0.04 points lines in the `.claude/hooks` package. New/changed-code coverage: 100.00% lines for `.claude/hooks/subagentstop-envelope.ps1` (only changed PowerShell production file). Branch coverage: not measured by Pester; no branch threshold applies to PowerShell per `.claude/rules/powershell.md`. Disposition: PASS (repo-wide lines 89.84% >= 85%; new file 100% >= 85%; no regression on changed lines). Evidence: `evidence/baseline/p0-pester-coverage.md`, `evidence/qa-gates/final-pester-coverage.md`, `evidence/qa-gates/final-helper-coverage.md`, `evidence/qa-gates/coverage-comparison.md`; review re-parse of `artifacts/pester/powershell-coverage.xml` (executor worktree, written 2026-10-11 13:12:33).
- TypeScript: `N/A - out of scope` (zero changed `.ts` files). Disposition: N/A.
- Python: `N/A - out of scope` (zero changed `.py` files). Disposition: N/A.
- C#: `N/A - out of scope` (zero changed `.cs` files). Disposition: N/A.

### 1.3 Test Structure and Diagnostics

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Clear Failure Messages** | PASS | `Should -BeExactly`/`-Be`/`-BeOfType` with values, so a failure prints expected and actual; the four settings regressions add `-Because` clauses naming the settings copy and the rule (`claude-settings.Tests.ps1` lines 171, 178, 185, 193). The fail-before record (`p2-helper-suite-fail-before.md`) shows each row failing with `CommandNotFoundException` for the not-yet-existing function, which identifies the missing unit. |
| **Arrange-Act-Assert Pattern** | PASS | Each `It` arranges inline input (or `-TestCases` data), acts with one function call, then asserts. The stdin and `&`-route tests place the act inside `try` and the asserts after `finally`, keeping restoration separate from assertion. |
| **Document Intent** | PASS | File-level comment describes the contract and the no-file/no-process constraint; inline comments explain the `EnvelopeIsNull` convention (line 76) and the fifteen-agent matcher (settings suite line 8). |

### 1.4 External Dependencies and Environment

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Avoid External Dependencies** | PASS | No database, network, API, child process, or temporary file. The helper suite reads two checked-in files (the helper and the fixture) via `$PSScriptRoot`-relative paths; the settings suite reads the two checked-in `settings.json` copies. |
| **Use Mocks/Stubs** | PASS | No Pester `Mock` is used. stdin and stderr are substituted with in-memory `StringReader`/`StringWriter` through `[Console]::SetIn`/`SetError` and restored in `finally`. This is the narrowest seam for a `[Console]`-bound reader and is consistent with the adapter-seam guidance in `.claude/rules/powershell.md`. |
| **Environment Stability** | PASS | No environment variable read in production (AST-asserted by the `reads no environment variable` test) or tests. `$global:LASTEXITCODE` is set to 0 before the `&`-route act and reset in `finally`. No temporary files are created (file-level comment; confirmed by inspection of all 278 lines). |

### 1.5 Policy Audit Requirement

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Pre-submission Review** | PASS | This audit, `code-review.2026-10-11T14-01.md`, and `feature-audit.2026-10-11T14-01.md` constitute the pre-PR review. Outstanding item: AC-29 PR-body half is verified at PR authoring (no PR exists yet). |

---

## 2. General Code Change Policy Compliance

### 2.1 Before Making Changes

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Clarify the objective** | PASS | Issue #897 (`issue.md`), epic #904 child E1; the objective (shared envelope helper, inline command removal) is stated in `spec.md` "Authoritative Helper Contract" and "Scope & Non-Goals". The premise was measured before implementation (`evidence/other/subagentstop-live-differential.2026-10-11T12-01.md`, `p0-premise-decision-gate.md`). |
| **Read existing change plans** | PASS | `evidence/baseline/p0-feature-inputs-read.md` and `phase0-instructions-read.md` record the reads of spec, issue, research, and policy files; the research record `research/research.2026-10-11T12-15.md` is referenced by the spec. |
| **Document the plan** | PASS | `plan.2026-10-11T07-59.md` (61/61 tasks checked; verified by `grep -c '^- \[x\] \[P'` = 61, unchecked = 0); preflight clearance recorded in `evidence/other/preflight-clearance.2026-10-11T13-17.md`. Commit messages follow `<type>(897): <subject>` with `Refs #897`. |

### 2.2 Design Principles

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Simplicity first** | PASS | Three small functions; a linear classification chain (BOM strip -> emptiness -> parse -> root type -> message presence/null/type) with one result object. No module, class, or indirection. |
| **Reusability** | PASS | The helper is the single envelope reader that E2, E3, and E4 will dot-source, replacing nine per-validator copies of the `$env:CLAUDE_HOOK_INPUT`/`.output` pattern. `Get-SubagentStopEnvelopeAnomalyReason` centralizes reason text. The settings suite factors `Get-SubagentStopCommand` for both copies. |
| **Extensibility** | PASS | `-InputText` is an optional named parameter with a stdin default; derived fields are returned regardless of validity so consumers can add re-entry policy without changing the reader. Adding an anomaly code is a switch row plus a reason row. |
| **Separation of concerns** | PASS | Parsing/classification (`Read-SubagentStopEnvelope`) is pure given `-InputText`; the only I/O is the stdin read (guarded) and the stderr write in `Exit-SubagentStopBlock`. Exit behavior is isolated in its own function so the reader never exits. |

### 2.3 Module & File Structure

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Cohesive modules** | PASS | One file, one concern (SubagentStop envelope). The fixture is a two-statement test entry point. |
| **Under 500 lines** | PASS | `wc -l` on the review head: helper 191, mirror 191, suite 278, fixture 22, settings suite 197 (`evidence/qa-gates/final-line-counts.md` records the same five counts). |
| **Public vs internal** | PASS | Three public functions, each documented with comment-based help; no script-scope variables; no internal helpers needed. |
| **No circular dependencies** | PASS | The helper imports and dot-sources nothing (AST-asserted). The fixture dot-sources the helper only. Settings copies do not reference the helper (asserted by the `registers no hook command that references subagentstop-envelope.ps1` test). |

### 2.4 Naming, Docs, and Comments

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Descriptive names** | PASS | `Read-SubagentStopEnvelope`, `Get-SubagentStopEnvelopeAnomalyReason`, `Exit-SubagentStopBlock` use approved verbs (Read, Get, Exit) and a shared noun prefix; result fields (`IsValid`, `Anomaly`, `Envelope`, `AssistantText`, `StopHookActive`, `AgentType`, `HookEventName`) match the contract table. |
| **Docs/docstrings** | PASS | File-level and per-function comment-based help (`.SYNOPSIS`, `.DESCRIPTION`, `.PARAMETER`, `.OUTPUTS`) covering the stdin wait behavior, the never-throw guarantee, and the exit-2 semantics. |
| **Comment why, not what** | PASS | Line 122 explains why the full `PSCustomObject` type name is compared rather than the `[pscustomobject]` accelerator; lines 26-29 explain why `[ValidateSet()]` is not used. |

### 2.5 After Making Changes - Toolchain Execution

| Requirement | Status | Evidence |
|------------|--------|----------|
| **1. Formatting** | PASS | **Command:** `Invoke-PoshQCFormat -Root (Get-Location).Path -GetFileList $fileList` over the five QC files (`evidence/qa-gates/final-poshqc-format.md`)<br>**Result:** `Formatted:` 0, `Already formatted:` 5; all five SHA-256 pairs equal before and after. |
| **2. Linting** | PASS | **Command:** `Invoke-PoshQCAnalyze -Root (Get-Location).Path -GetFileList $fileList` (`evidence/qa-gates/final-poshqc-analyze.md`; list includes the fixture, which is outside the configured scan roots)<br>**Result:** `PSScriptAnalyzer passed: no findings under .`; `FINDING_COUNT: 0`. |
| **3. Type checking** | N/A | Not applicable for PowerShell (`.claude/rules/powershell.md`). |
| **4. Testing** | PASS | **Command:** `Invoke-PoshQCTest -Root (Get-Location).Path -SettingsPath scripts/powershell/PoshQC/settings/pester.runsettings.psd1` (`evidence/qa-gates/final-pester-coverage.md`)<br>**Result:** 9867 passed, 0 failed, 10 skipped; JUnit `failures=0 errors=0`. Targeted six-container run: 862 passed, 0 failed (`final-pester-targeted.md`). |
| **Full toolchain loop** | PASS | `evidence/qa-gates/final-qc-loop.md`: `PASS 1: CLEAN`, `FINAL_PASS: 1`; no restart triggered and no QC file changed during the pass. Consumer checks also passed in the same pass: pytest parity 22/22, Jest manifest 16/16. |
| **Explicit reporting** | PASS | Each gate has its own evidence file with `Timestamp`, `Command`, `EXIT_CODE`, and verbatim output lines; `artifacts/pr_context.summary.txt` lists 21 verification-evidence rows, all normalized `pass`. |

### 2.6 Summarize and Document

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Summarize changes** | PASS | Seven commits with typed subjects and `Refs #897` bodies (Section 9); `spec.md` "Proposed Fix" and the per-agent matcher table document the deletion decision. |
| **Design choices explained** | PASS | `spec.md` records the rejected alternative (file-based hook with a narrowed matcher) and why `HookPayload.psm1` was not extended (500-line cap, environment fallback contradicts the contract). `evidence/other/p1-exit-route-decision.md` records that the `-ExitAction` fallback was not needed. |
| **Update supporting documents** | PASS | `spec.md` updated to version 1.1 (contract refinement `-DateKind String` recorded as D5); plan checked through; AC log in `evidence/other/ac-status.md`. No README change is needed: the helper has no consumer until E2-E4. |
| **Provide next steps** | PASS | `spec.md` "Rollout & Follow-up": merge E1 into the integration branch; E2-E4 rebase and consume the helper; epic #904 integration PR closes #897. |

---

## 3. Language-Specific Code Change Policy Compliance

### Section 3B: PowerShell Code Change Policy Compliance

#### 3B.1 Tooling & Baseline

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Formatting with Invoke-Formatter** | PASS | **Command:** `Invoke-PoshQCFormat -Root (Get-Location).Path -GetFileList $fileList`<br>**Result:** 0 files rewritten; baseline format state also captured read-only at [P0-T7] (`evidence/baseline/p0-poshqc-format.md`). |
| **Linting with PSScriptAnalyzer** | PASS | **Command:** `Invoke-PoshQCAnalyze -Root (Get-Location).Path -GetFileList $fileList`<br>**Result:** no findings. |
| **Fix all findings** | PASS | No findings were reported at baseline ([P0-T8]) or final ([P5-T2]); nothing to fix. |
| **PowerShell 5.1 & 7.6+ compatible** | PASS | The repository rule is PowerShell 7+ (`.claude/rules/powershell.md`, "Compatibility"); the 5.1 row in this template is superseded by that rule. The helper uses `ConvertFrom-Json -DateKind String`, which requires PowerShell 7.5 or later; the spec states this requirement ("PowerShell 7.5 or later; hooks run under `pwsh`") and the file-level `.NOTES` repeats it. The local runtime is PowerShell 7.6.5 (issue environment). See `code-review.2026-10-11T14-01.md` finding CR-1 (Minor) for the absence of a `#Requires -Version 7.5` guard. |

#### 3B.2 PowerShell Design & Safety

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Advanced functions** | PASS | All three functions declare `[CmdletBinding()]`; `Read-*` and `Get-*` declare `[OutputType()]`. The fixture declares `[CmdletBinding()]` with a mandatory `-Message`. |
| **Parameter validation** | PASS | `Exit-SubagentStopBlock -Message` is `[Parameter(Mandatory)][ValidateNotNullOrEmpty()]` (binding failure asserted by test). `-InputText` and `-Anomaly` use `[AllowNull()][AllowEmptyString()]` deliberately so null/empty inputs reach the classification logic rather than failing binding (contract requirement). |
| **Avoid global state** | PASS | No script- or global-scope variables in the helper; `$PSBoundParameters` is used to distinguish bound from unbound `-InputText`. ShouldProcess is not applicable: the only state change is the process exit in `Exit-SubagentStopBlock`, whose purpose is the exit. |
| **Error handling** | PASS | Two `try`/`catch` blocks each convert a specific failure (stdin read, JSON parse) into an anomaly code by contract; neither swallows an error silently, because the result object carries the anomaly and consumers block on it (fail closed). `Get-SubagentStopEnvelopeAnomalyReason` throws `ArgumentException` naming the rejected value. `-ErrorAction Stop` is set on `ConvertFrom-Json`. |

#### 3B.3 Structure, Naming, and Comments

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Cohesive and under 500 lines** | PASS | 191 / 191 / 278 / 22 / 197 lines (Section 2.3). |
| **Approved verbs** | PASS | `Read`, `Get`, `Exit` are approved verbs; PSScriptAnalyzer `PSUseApprovedVerbs` reported nothing. Fixture file name uses `Invoke-` (script name, not a function). |
| **Comment why** | PASS | See Section 2.4. |

#### 3B.4 Running the Toolchain

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Step 1: Format** | PASS | [P5-T1] clean; see 3B.1. |
| **Step 2: Analyze** | PASS | [P5-T2] clean; see 3B.1. |
| **Step 3: Type check** | N/A | Not applicable for PowerShell. |
| **Step 4: Test** | PASS | [P5-T3] 862/862 targeted; [P5-T4] 9867/9867 full run. |
| **Rerun loop if needed** | PASS | One pass (`FINAL_PASS: 1`). |

### Section 3D: JSON Configuration Policy Compliance

#### 3D.1 JSON Tooling

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Formatting with jq** | PASS | The three changed JSON files were not reformatted; the diff is a four-line object removal in each `settings.json` copy and a one-line array insertion in `core.json`, preserving the surrounding indentation and key order. The review parsed all three with Python `json.load` (`JSON_OK 3`). |
| **Schema validation** | PASS | `claude-settings.Tests.ps1` (9/9) and `test_claude_planning_integrity_contracts.py::test_prd_feature_runtime_registration_is_exact_and_bundle_identical` parse and validate the settings structure; `test_push_down_claude_pack_manifest_completeness.py` (2/2) and the Jest manifest-completeness test (16/16) validate `core.json` against the bundled file set. |
| **Required $schema** | N/A | `.claude/settings.json` and `pack-manifests/core.json` are not governed by the repository `$schema` requirement (neither file carried a `$schema` property on the base branch; the diff adds none). |

#### 3D.2 JSON Structure

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Strict JSON only** | PASS | All three files parse under strict `json.load`; the removal included the separating comma (no trailing comma left behind; the `hooks` array retains one object). |
| **Deterministic key order** | PASS | No key order changed; `core.json` keeps its alphabetical `paths` order (`persist-session-id.ps1` < `subagentstop-envelope.ps1` < `validate-bash.ps1`). |

---

## 4. Language-Specific Unit Test Policy Compliance

### Section 4B: PowerShell Unit Test Policy Compliance

#### 4B.1 Framework and Scope

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Use Pester v5.x** | PASS | `#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }`; `BeforeAll`, `Describe`/`Context`/`It`, `-TestCases`, modern `Should` operators (`-BeExactly`, `-BeOfType`, `-Throw -ExceptionType`). |
| **Use PoshQC Configuration** | PASS | **Command:** `Invoke-PoshQCTest -Root (Get-Location).Path -SettingsPath scripts/powershell/PoshQC/settings/pester.runsettings.psd1`<br>**Config:** `scripts/powershell/PoshQC/settings/pester.runsettings.psd1`; no configuration change (`config/poshqc-coverage.json` roots are directories, so the new helper entered the denominator automatically; confirmed by `SOURCEFILE_MATCHES: 1`). |
| **PowerShell 5.1 & 7.6+ Compatible** | PASS | `#Requires -Version 7.0`; the repository rule is 7+. The suite uses `[Console]::SetIn`/`SetError`, available on 7.x. Verified under the local 7.6.5 runtime. |

#### 4B.2 Test Style and Structure

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Focused Unit Tests** | PASS | 78 tests across 3 functions: 11 anomaly-reason, 61 reader, 2 exit-block, plus 1 surface and 3 source-constraint tests (Section 1.2). |
| **Test Behavior Over Implementation** | PASS | Tests assert the contract's observable result object, stderr text, and exit code. The three source-constraint tests are intentionally structural (AST scans) because the contract itself forbids environment reads, imports, and stream writes; they are required by AC-4. |
| **Mocking Used Sparingly** | PASS | No `Mock`. `[Console]` streams are substituted in-memory and restored. |
| **Organization** | PASS | **Test file:** `tests/scripts/claude-hooks/subagentstop-envelope.Tests.ps1`<br>**Code file:** `.claude/hooks/subagentstop-envelope.ps1`<br>`tests/scripts/claude-hooks/` is the established mirror of `.claude/hooks/` (149 files present at the review head). The fixture lives under `tests/fixtures/claude-hooks/`, inside the test tree. No test file is colocated with production source. |

#### 4B.3 Naming and Readability

| Requirement | Status | Evidence |
|------------|--------|----------|
| **File Naming** - *.Tests.ps1 | PASS | `subagentstop-envelope.Tests.ps1`; `claude-settings.Tests.ps1`. |
| **Describe/Context/It Structure** | PASS | 1 `Describe`, 7 `Context` blocks, 23 `It` declarations expanding to 78 cases. |
| **Logical Grouping** | PASS | Contexts follow the spec's Test Strategy bullets in order: source constraints, input rows, derived fields, BOM/CRLF, stdin default, anomaly reasons, exit block. |
| **Docstrings/Comments** | PASS | File-level comment-based help; `It` names are self-describing with templated parameters. |

#### 4B.4 Running the Toolchain

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Use PoshQCTest Command** | PASS | **Command:** `Invoke-PoshQCTest -Root (Get-Location).Path -SettingsPath scripts/powershell/PoshQC/settings/pester.runsettings.psd1`<br>**Result:** 9867 passed, 0 failed, 10 skipped (pre-existing skips; baseline also 10). |
| **No Alternative Test Runners** | PASS | Pester through PoshQC for the full run; direct `Invoke-Pester -Configuration` (Pester 5) for the targeted six-container run, which is the same runner. |

---

## 5. Test Coverage Detail

### `Get-SubagentStopEnvelopeAnomalyReason` (11 tests)

| Test Name | Scenario Type | Lines Covered | Status |
|-----------|--------------|---------------|--------|
| `returns a non-empty clause for <Code>` (6 cases) | Positive | 43-49 | PASS |
| `returns six pairwise distinct clauses` | Positive | 43-49 | PASS |
| `throws ArgumentException for <Name>` (4 cases) | Negative / Error Handling | 43, 50 | PASS |

**Coverage:** 100% of `Get-SubagentStopEnvelopeAnomalyReason` (lines 20-52)

**Not covered:** None

---

### `Read-SubagentStopEnvelope` (61 tests)

| Test Name | Scenario Type | Lines Covered | Status |
|-----------|--------------|---------------|--------|
| `classifies <Name> with the expected IsValid, Anomaly, Envelope and AssistantText` (22 cases) | Positive / Negative / Edge Case | 81-83, 93-168 | PASS |
| `emits exactly one object with exactly the seven contract properties for <Name>` (22 cases) | Error Handling (no-throw, shape) | 160-168 | PASS |
| `returns the root fields of a valid envelope` | Positive | 143-156 | PASS |
| `keeps an ISO-8601 date-form message as the exact string` | Edge Case | 112, 135-137 | PASS |
| `sets StopHookActive from a stop_hook_active value that is <Name>` (4 cases) | Edge Case | 143-146 | PASS |
| `sets <Field> when the root field is <Name>` (6 cases) | Edge Case | 148-156 | PASS |
| `accepts a BOM-prefixed valid envelope` | Edge Case | 93-95 | PASS |
| `accepts a CRLF-formatted valid envelope` | Edge Case | 112 | PASS |
| `reads the envelope from stdin when InputText is not bound` | Positive | 84-87 | PASS |
| `treats a stdin read failure as EmptyPayload` | Error Handling | 88-90, 105-106 | PASS |
| `prefers a bound empty InputText over non-empty stdin` | Edge Case | 81-82, 105-106 | PASS |

**Coverage:** 100% of `Read-SubagentStopEnvelope` (lines 54-169)

**Not covered:** None

---

### `Exit-SubagentStopBlock` (2 tests)

| Test Name | Scenario Type | Lines Covered | Status |
|-----------|--------------|---------------|--------|
| `blocks through the & route with stderr and exit code 2` | Positive | 189-190 (via fixture line 21-22) | PASS |
| `rejects an empty or null Message at parameter binding without exiting` | Negative | 184-186 (binding) | PASS |

**Coverage:** 100% of `Exit-SubagentStopBlock` (lines 171-191)

**Not covered:** None

---

### `claude-settings.Tests.ps1` additions (4 tests; target: both `settings.json` copies)

| Test Name | Scenario Type | Lines Covered | Status |
|-----------|--------------|---------------|--------|
| `removes every SubagentStop command that reads CLAUDE_HOOK_INPUT from both settings copies` | Negative (regression) | n/a (JSON) | PASS |
| `keeps no SubagentStop command that ends with exit 1 in either settings copy` | Negative (regression) | n/a (JSON) | PASS |
| `retains the fifteen-agent SubagentStop group with only the discovery-artifact gate in both settings copies` | Positive (retention) | n/a (JSON) | PASS |
| `registers no hook command that references subagentstop-envelope.ps1 in either settings copy` | Negative (regression) | n/a (JSON) | PASS |

Fail-before: `evidence/regression-testing/p2-claude-settings-fail-before.md` (exit 1, expected 1); pass-after: `p4-claude-settings-pass-after.md` (exit 0).

---

## 6. Test Execution Metrics

| Metric | Value | Status |
|--------|-------|--------|
| Total Tests | 9877 discovered / 9867 executed in the full run; 82 added by this branch (78 + 4) | PASS |
| Tests Passed | 9867 (100% of executed) | PASS |
| Tests Failed | 0 | PASS |
| Execution Time | 556.11 s total (full self-hosted run, 198 files) | PASS Fast for the repository size; the added suite runs in-process with no I/O |
| Average Time per Test | about 56 ms (556.11 s / 9867) | PASS Fast |
| Discovery Time | Not separately recorded in the evidence | Not recorded (no policy threshold) |
| Functions/Classes Tested | 3/3 (100%) | PASS |
| Test File Size | 278 lines (helper suite); 197 lines (settings suite) | PASS Maintainable |
| Code Coverage (if applicable) | Helper: 100.00% lines (60/60); repo-wide PowerShell: 89.84% lines, 88.67% commands; branches: not measured by Pester (no PowerShell branch gate) | PASS |

---

## 7. Code Quality Checks

**For PowerShell:**

| Check | Command | Result | Status |
|-------|---------|--------|--------|
| Invoke-Formatter | `Invoke-PoshQCFormat -Root (Get-Location).Path -GetFileList $fileList` (five QC files) | `Formatted:` 0, `Already formatted:` 5; SHA pairs unchanged | PASS |
| PSScriptAnalyzer | `Invoke-PoshQCAnalyze -Root (Get-Location).Path -GetFileList $fileList` | `PSScriptAnalyzer passed: no findings under .` | PASS |
| Pester Tests | `Invoke-PoshQCTest -Root (Get-Location).Path -SettingsPath scripts/powershell/PoshQC/settings/pester.runsettings.psd1` | 9867 passed, 0 failed, 10 skipped | PASS |

**Consumer checks (JSON changes; no coverage obligation):**

| Check | Command | Result | Status |
|-------|---------|--------|--------|
| Python parity/manifest tests | `poetry run pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py tests/scripts/dev_tools/test_push_down_claude_pack_manifest_completeness.py tests/scripts/dev_tools/test_claude_planning_integrity_contracts.py -v` | 22 passed | PASS |
| Jest manifest completeness | `npx jest test/lib/push-down/claude-pack-manifest-completeness.test.ts` (from `extensions/drm-copilot`) | 16 passed, 16 total | PASS |
| Evidence locations | `python -I scripts/dev_tools/validate_evidence_locations.py --root .` | exit 0 | PASS |
| JSON parse | `python -I -c "import json,sys; [json.load(open(p, encoding='utf-8-sig')) for p in sys.argv[1:]]"` over the three changed JSON files | `JSON_OK 3` | PASS |

**Notes:**
No pre-existing failures: `evidence/other/pre-existing-failures.md` records `PRE_EXISTING_FAILURES: none` from four baseline sources, and no later gate reported a failure. CI status for the head is `(not available)` in the PR context because no PR exists; `ci.yml` triggers on pull requests into `main`/`development`, so the orchestrator's S9 CI gate applies after PR creation. The `modified-workflow-needs-green-run` rule does not fire: the diff touches no path under `.github/workflows/**`, `.github/actions/**`, or `scripts/benchmarks/**`.

---

## 8. Gaps and Exceptions

### Identified Gaps

**None blocking.** All policy requirements are met. Two non-blocking observations are recorded for traceability:

1. Repo-wide command-coverage total moved from 89.16% (baseline, 25,877 commands) to 88.67% (final, 25,950 commands). Arithmetic: baseline covered commands about 23,072; final covered 23,011 (from the XML `INSTRUCTION` counter, 23,011/25,950). The branch added 73 commands, all covered, so about 134 commands outside the changed files were covered at baseline and uncovered in the final run. The `.claude/hooks` package counters (covered 5226 -> 5286, missed 207 -> 207) show none of these are in the hooks package. Both totals remain above the 85% threshold and the baseline XML was overwritten by the final run, so the originating files cannot be identified from the retained evidence. This is recorded as observed, consistent with `evidence/qa-gates/final-pester-coverage.md`; it is not attributable to the diff and is not a changed-line regression. Recommended follow-up (outside this feature): retain the baseline XML under a distinct name in future Phase 0 captures so run-to-run movement can be diffed.
2. The helper requires PowerShell 7.5+ (`ConvertFrom-Json -DateKind`), which the spec mandates, but the file carries no `#Requires -Version 7.5` statement. On an older `pwsh` the parameter-binding error inside the `try` would classify every payload as `UnparseableJson`, which is fail-closed for consumers (they block) but would be opaque. See `code-review.2026-10-11T14-01.md` CR-1 (Minor, non-blocking; GitHub-hosted runner PowerShell version not verified from this environment).

### Approved Exceptions

**None.** No exceptions needed. The PowerShell branch-coverage threshold is not an exception; it is inapplicable by rule (`.claude/rules/powershell.md`: Pester measures command and line coverage only).

### Removed/Skipped Tests

**None.** All planned tests implemented. The 10 skipped tests in the full run are pre-existing (baseline also reports 10 skipped) and are outside the diff.

---

## 9. Summary of Changes

### Commits in This PR/Branch

Range `64642312b..806cf067a` (7 commits; every body contains `Refs #897` and no closing keyword applied to #897):

1. **466f212c8** - docs(897): record Phase 0 baseline evidence for SubagentStop envelope helper
2. **7bb19a8bc** - feat(897): add Exit-SubagentStopBlock and its exit-route test entry script
3. **b4f24a098** - test(897): add SubagentStop envelope helper and settings regression tests
4. **82a4e5248** - feat(897): implement Read-SubagentStopEnvelope and anomaly reasons with bundled mirror and core manifest entry
5. **9c69282de** - chore(897): remove the inline SubagentStop command from both settings copies
6. **60027886e** - test(897): record final QA and coverage evidence for the SubagentStop envelope helper
7. **806cf067a** - docs(897): record scope, commit-message, and acceptance status evidence

### Files Modified

1. **.claude/hooks/subagentstop-envelope.ps1** (NEW, 191 lines)
   - Three functions implementing the Authoritative Helper Contract; no imports, no environment reads, stderr-only output.
2. **extensions/drm-copilot/resources/claude-customizations/.claude/hooks/subagentstop-envelope.ps1** (NEW)
   - Byte-identical mirror (`cmp` exit 0 at the review head).
3. **extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json** (MODIFIED)
   - One `paths` entry added: `.claude/hooks/subagentstop-envelope.ps1`.
4. **.claude/settings.json** and **extensions/drm-copilot/resources/claude-customizations/.claude/settings.json** (MODIFIED, -4 lines each)
   - Inline `pwsh -NoProfile -Command ... exit 1` SubagentStop command object removed; fifteen-agent matcher and the `validate-discovery-artifact-gate.ps1` command retained; copies remain byte-identical.
5. **tests/scripts/claude-hooks/subagentstop-envelope.Tests.ps1** (NEW, 278 lines)
   - 78 Pester cases covering surface, source constraints, all contract rows, derived fields, BOM/CRLF, stdin default, anomaly reasons, and the exit route.
6. **tests/fixtures/claude-hooks/Invoke-SubagentStopBlock.Fixture.ps1** (NEW, 22 lines)
   - Test-only entry point for the `&`-route exit test.
7. **tests/scripts/claude-runtime/claude-settings.Tests.ps1** (MODIFIED, +42 lines)
   - Four regression/retention assertions over both settings copies.
8. **docs/features/active/subagentstop-envelope-core-897/** (40 files NEW/MODIFIED)
   - `spec.md` (v1.1, 28/29 AC checked), `plan.2026-10-11T07-59.md` (61/61), and evidence under `evidence/{baseline,regression-testing,qa-gates,other}/`.

---

## 10. Compliance Verdict

### Overall Status: FULLY COMPLIANT

All evaluated policy sections are PASS. Baseline and post-change coverage figures are recorded numerically for PowerShell, the only coverage language with changed files; the new file is at 100.00% line coverage; repo-wide line coverage is 89.84%; the toolchain closed in one pass with zero format changes, zero analyzer findings, and zero test failures. Evidence locations are canonical. No scope narrowing was attempted. The only open acceptance item is the PR-body half of AC-29, which cannot be evaluated before a PR exists and is not a policy finding.

**Fail-closed reminder:** Do not mark the audit PASS, fully compliant, or ready for merge when any required baseline artifact, QA artifact, coverage metric, or coverage-comparison artifact is missing. All required artifacts listed in the Coverage Evidence Checklist are present.

---

### Policy-by-Policy Summary

#### General Code Change Policy (Section 2)
- PASS Before Making Changes: objective, plan, and premise measurement recorded
- PASS Design Principles: minimal three-function helper; pure classification separated from I/O
- PASS Module & File Structure: all files under 500 lines; no circular dependencies
- PASS Naming, Docs, Comments: approved verbs, comment-based help, rationale comments
- PASS Toolchain Execution: single clean pass (`FINAL_PASS: 1`)
- PASS Summarize & Document: spec v1.1, plan complete, typed commits

#### Language-Specific Code Change Policy (Section 3)

**For PowerShell:**
- PASS Tooling & Baseline: format 0 changes, analyzer 0 findings
- PASS PowerShell Design & Safety: advanced functions, validated parameters, no global state
- PASS Structure & Naming: 191/278/22/197 lines; approved verbs
- PASS Toolchain: format -> analyze -> test, one pass

**For JSON:**
- PASS Strict JSON, key order preserved, copies byte-identical, parity tests green

#### General Unit Test Policy (Section 1)
- PASS Core Principles: independent, isolated, fast, deterministic, readable
- PASS Coverage & Scenarios: new code 100.00%; repo-wide 89.84% lines; positive, negative, edge, and error paths covered
- PASS Test Structure: AAA, clear diagnostics, `-Because` on regressions
- PASS External Dependencies: none; in-memory stream substitution; no temporary files
- PASS Policy Audit: this document

#### Language-Specific Unit Test Policy (Section 4)

**For PowerShell:**
- PASS Framework & Scope: Pester 5 through PoshQC configuration
- PASS Test Style & Structure: behavior-focused, no mocks, mirrored location
- PASS Naming & Readability: `*.Tests.ps1`, Describe/Context/It, templated names
- PASS Toolchain: PoshQC test runner only

---

### Metrics Summary

- PASS 9867/9867 executed tests passing (100%); 82 added by the branch
- PASS 3/3 functions tested (100%)
- PASS 100.00% line coverage on the new helper; 89.84% repo-wide PowerShell line coverage (threshold 85%)
- PASS Proper file organization: `tests/scripts/claude-hooks/` mirrors `.claude/hooks/`; fixture under `tests/fixtures/`
- PASS All code quality checks passing (format, analyzer, Pester, pytest parity, Jest manifest, evidence locations)
- PASS Test execution time: 556.11 s full run (fast for 9867 tests; added suite is in-process)

---

### Recommendation

**Ready for merge** (into `epic/subagentstop-envelope-integration`, after PR authoring and the S9 CI gate).

Next steps: author the PR with `Refs #897` and no closing keyword (completes AC-29); the orchestrator's S9 gate confirms `ci_gate.conclusion == "success"` with `ci_gate.head_sha` equal to the final PR head. Optional follow-up (non-blocking): consider a `#Requires -Version 7.5` statement in the helper when E2-E4 wire consumers (CR-1 in the code review).

---

## Appendix A: Test Inventory

### Complete Test List

`tests/scripts/claude-hooks/subagentstop-envelope.Tests.ps1` (78 cases):

1. subagentstop-envelope helper > defines Read-SubagentStopEnvelope, Get-SubagentStopEnvelopeAnomalyReason and Exit-SubagentStopBlock
2. subagentstop-envelope helper > source constraints > reads no environment variable
3. subagentstop-envelope helper > source constraints > imports and dot-sources nothing
4. subagentstop-envelope helper > source constraints > writes nothing to the success, host, information or warning streams
5. subagentstop-envelope helper > input-to-result rows > classifies <Name> with the expected IsValid, Anomaly, Envelope and AssistantText (22 cases: valid envelope; ISO-date string message; empty string message; null input; empty string input; whitespace-only input; BOM-only input; non-JSON text; case-duplicate keys; empty array; single-element array; multi-element array; number root; string root; boolean root; JSON null root; object without last_assistant_message; null last_assistant_message; number/boolean/object/array last_assistant_message)
6. subagentstop-envelope helper > input-to-result rows > returns the root fields of a valid envelope
7. subagentstop-envelope helper > input-to-result rows > keeps an ISO-8601 date-form message as the exact string
8. subagentstop-envelope helper > input-to-result rows > emits exactly one object with exactly the seven contract properties for <Name> (22 cases, same rows)
9. subagentstop-envelope helper > derived fields > sets StopHookActive from a stop_hook_active value that is <Name> (4 cases: boolean true; boolean false; absent; string "true")
10. subagentstop-envelope helper > derived fields > sets <Field> when the root field is <Name> (6 cases: AgentType and HookEventName x present as a string / absent / the non-string 5)
11. subagentstop-envelope helper > BOM and CRLF input > accepts a BOM-prefixed valid envelope
12. subagentstop-envelope helper > BOM and CRLF input > accepts a CRLF-formatted valid envelope
13. subagentstop-envelope helper > stdin default > reads the envelope from stdin when InputText is not bound
14. subagentstop-envelope helper > stdin default > treats a stdin read failure as EmptyPayload
15. subagentstop-envelope helper > stdin default > prefers a bound empty InputText over non-empty stdin
16. subagentstop-envelope helper > anomaly reasons > returns a non-empty clause for <Code> (6 cases)
17. subagentstop-envelope helper > anomaly reasons > returns six pairwise distinct clauses
18. subagentstop-envelope helper > anomaly reasons > throws ArgumentException for <Name> (4 cases: an unknown code; null; an empty string; a case variant)
19. subagentstop-envelope helper > Exit-SubagentStopBlock > blocks through the & route with stderr and exit code 2
20. subagentstop-envelope helper > Exit-SubagentStopBlock > rejects an empty or null Message at parameter binding without exiting

`tests/scripts/claude-runtime/claude-settings.Tests.ps1` (4 added cases; 9 total in the container):

21. claude-settings > removes every SubagentStop command that reads CLAUDE_HOOK_INPUT from both settings copies
22. claude-settings > keeps no SubagentStop command that ends with exit 1 in either settings copy
23. claude-settings > retains the fifteen-agent SubagentStop group with only the discovery-artifact gate in both settings copies
24. claude-settings > registers no hook command that references subagentstop-envelope.ps1 in either settings copy

Guard suites run unchanged for AC-23 (598 + 25 + 140 + 12 = 775 cases, all passed): `hook-dependency-guard-completeness.Tests.ps1`, `hook-imported-modules-no-stdout.Tests.ps1`, `hook-dependency-failure.Claude.Tests.ps1`, `hook-dependency-guard.Tests.ps1`.

---

## Appendix B: Toolchain Commands Reference

**For PowerShell (as executed by the executor and recorded under `evidence/qa-gates/`):**
```powershell
# Formatting (five QC files; write-mode formatter, 0 rewrites)
Import-Module ./scripts/powershell/PoshQC/PoshQC.psd1 -Force
$files = @('.claude/hooks/subagentstop-envelope.ps1', 'extensions/drm-copilot/resources/claude-customizations/.claude/hooks/subagentstop-envelope.ps1', 'tests/scripts/claude-hooks/subagentstop-envelope.Tests.ps1', 'tests/fixtures/claude-hooks/Invoke-SubagentStopBlock.Fixture.ps1', 'tests/scripts/claude-runtime/claude-settings.Tests.ps1')
$fileList = { param($RootPath, $ScanFoldersPath, $Excluded) $files | ForEach-Object { Get-Item -LiteralPath (Join-Path $RootPath $_) } }.GetNewClosure()
Invoke-PoshQCFormat -Root (Get-Location).Path -GetFileList $fileList

# Linting
Invoke-PoshQCAnalyze -Root (Get-Location).Path -GetFileList $fileList

# Testing (full run with coverage; writes artifacts/pester/powershell-coverage.xml)
Invoke-PoshQCTest -Root (Get-Location).Path -SettingsPath scripts/powershell/PoshQC/settings/pester.runsettings.psd1

# Targeted suites (Pester 5 direct)
Import-Module Pester -MinimumVersion 5.0 -Force
$cfg = New-PesterConfiguration
$cfg.Run.Path = @('tests/scripts/claude-hooks/subagentstop-envelope.Tests.ps1', 'tests/scripts/claude-runtime/claude-settings.Tests.ps1', 'tests/scripts/claude-runtime/hook-dependency-guard-completeness.Tests.ps1', 'tests/scripts/claude-runtime/hook-imported-modules-no-stdout.Tests.ps1', 'tests/scripts/claude-hooks/hook-dependency-failure.Claude.Tests.ps1', 'tests/scripts/claude-hooks/hook-dependency-guard.Tests.ps1')
$cfg.Run.PassThru = $true; $cfg.Run.Exit = $false
Invoke-Pester -Configuration $cfg
```

**Consumer and review-side checks:**
```bash
# Python parity and manifest tests
poetry run pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py tests/scripts/dev_tools/test_push_down_claude_pack_manifest_completeness.py tests/scripts/dev_tools/test_claude_planning_integrity_contracts.py -v

# Jest manifest completeness (from extensions/drm-copilot)
npx jest test/lib/push-down/claude-pack-manifest-completeness.test.ts

# Evidence-location scan
python -I scripts/dev_tools/validate_evidence_locations.py --root .

# Branch diff and commit messages
git diff --name-status 64642312b5aa83b66d5d9cc0ce131d1308a4182a...HEAD
git log --format='%h %s%n%b' 64642312b5aa83b66d5d9cc0ce131d1308a4182a..HEAD

# Mirror parity
cmp .claude/hooks/subagentstop-envelope.ps1 extensions/drm-copilot/resources/claude-customizations/.claude/hooks/subagentstop-envelope.ps1
cmp .claude/settings.json extensions/drm-copilot/resources/claude-customizations/.claude/settings.json

# Coverage XML re-parse (review-side, read-only; JaCoCo LINE/INSTRUCTION counters for the report, the .claude/hooks package, and the helper sourcefile)
python -I <scratch>/cov897.py artifacts/pester/powershell-coverage.xml
```

---

**Audit Completed By:** feature-review agent (Claude Code)  
**Audit Date:** 2026-10-11  
**Policy Version:** Current (as of audit date)
