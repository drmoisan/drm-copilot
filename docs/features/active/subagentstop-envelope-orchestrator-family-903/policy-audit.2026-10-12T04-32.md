# Policy Compliance Audit: subagentstop-envelope-orchestrator-family (E2, issue #903)

---

**Audit Date:** 2026-10-12
**Code Under Test:** `.claude/hooks/validate-orchestrator-output.ps1` (MODIFIED), `.claude/hooks/validate-orchestrator-output-routing.ps1` (NEW), `.claude/hooks/validate-orchestrator-output-resolution.ps1` (MODIFIED), `.claude/hooks/validate-executor-output.ps1` (MODIFIED), `.claude/hooks/validate-planner-output.ps1` (MODIFIED), `.claude/hooks/validate-required-artifact-output.ps1` (MODIFIED), their six byte-identical bundled mirrors under `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/`, `.claude/agents/prd-feature.md` and its mirror (MODIFIED), `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json` (MODIFIED), 8 new and 11 modified Pester suites under `tests/scripts/claude-hooks/`, plus the feature folder (`spec.md`, `plan.2026-10-11T07-59.md`, 97 evidence files).

**Base branch:** `origin/epic/subagentstop-envelope-integration` @ `77a142830ff3457a827a5b7e224ebd5a8f4e7923`; merge base `ebf4504ae6f881c5b34b91082b3df474c04d13f2`. **Head:** `exec-903-resume2` @ `c92f331b43377ea659403d4a8967dad32193b266` (identical to `origin/bug/subagentstop-envelope-orchestrator-family-exec-903`). Diff range: `git diff origin/epic/subagentstop-envelope-integration...HEAD` (133 files, +6418/-956). The two base commits after the merge base (`a6285d7f4`, `77a142830`) change only `docs/features/epics/subagentstop-envelope/epic-status.md` and do not overlap the branch diff.

**Coverage Metrics by Language:**

| Language | Files Changed | Tests | Test Result | Baseline Coverage | Post-Change Coverage | New Code Coverage |
|----------|--------------|-------|-------------|-------------------|---------------------|-------------------|
| PowerShell | 31 files (6 production hooks, 6 byte-identical mirrors, 19 Pester suites: 8 new, 11 modified) | 5033 in full claude-hooks + claude-runtime run; 288 in the coverage population; 359 in the named-row run | PASS 5033 pass, 0 fail | 89.57% lines aggregate over the 5 pre-existing production files (524/585); per file 69.81% to 98.94% | 99.02% lines aggregate over the 6 production files (606/612); per file 98.32% to 100% | 100% changed-line coverage on every production file (148/148 changed executable lines); new file `validate-orchestrator-output-routing.ps1` 100% (28/28) |
| JSON | 1 file (`pack-manifests/core.json`) | N/A | PASS (manifest completeness: pytest 58 passed, Jest 16 passed) | N/A (config file) | N/A (config file) | N/A |
| TypeScript | 0 files | N/A | N/A | N/A | N/A | N/A |
| Python | 0 files | N/A | N/A | N/A | N/A | N/A |
| C# | 0 files | N/A | N/A | N/A | N/A | N/A |

Languages with zero changed files on the branch: TypeScript, Python, C#, Bash. No coverage verdict is required for them. Python and Jest suites were executed as consumers of the manifest and mirror changes (Section 7); they carry no coverage obligation because no `.py` or `.ts` file changed.

### Coverage Evidence Checklist

- TypeScript baseline coverage artifact: `N/A - out of scope` (no TypeScript file changed)
- TypeScript post-change coverage artifact: `N/A - out of scope` (no TypeScript file changed)
- PowerShell baseline coverage artifact: `docs/features/active/subagentstop-envelope-orchestrator-family-903/evidence/baseline/pester-coverage.2026-10-12T00-02.md` (self-hosted Pester run with `CodeCoverage.Path` set to the five pre-existing production files; per-file HIT and MISSED line lists recorded)
- PowerShell post-change coverage artifact: `docs/features/active/subagentstop-envelope-orchestrator-family-903/evidence/qa-gates/pester-coverage.2026-10-12T04-14.md` and `evidence/qa-gates/coverage-delta.2026-10-12T04-20.md` (per-file HIT and MISSED line lists; changed-line coverage against the integration base)
- Per-language comparison summary: Section 1.2.1 of this audit; `evidence/qa-gates/coverage-delta.2026-10-12T04-20.md`

**Non-negotiable verdict rule:** No policy audit may report PASS unless it includes numeric baseline and post-change coverage metrics for every language in scope, plus changed/new-code coverage when required.

**Fail-closed rule:** If any required baseline artifact, QA artifact, or coverage-comparison artifact is absent, the verdict must be BLOCKED or INCOMPLETE, never PASS.

**Evidence rule:** Audit evidence is not synthesized from memory or inference. Where evidence is incomplete, the gap is listed with its exact path.

---

## Executive Summary

This audit covers the full branch diff of `exec-903-resume2` (the E2 item branch content) against `origin/epic/subagentstop-envelope-integration`. The change converts four SubagentStop validators (orchestrator with its resolution sibling, executor, planner, required-artifact) from the `CLAUDE_HOOK_INPUT` / root `output` / `exit 1` transport to the E1 helper (`Read-SubagentStopEnvelope`, `Get-SubagentStopEnvelopeAnomalyReason`, `Exit-SubagentStopBlock`), adds the per-condition re-entry policy keyed on `StopHookActive`, splits the orchestrator hook into a new routing sibling, resolves five same-file review notes from #786 and #787, removes the duplicate `-RequiredArtifact` argument from `prd-feature.md`, and updates mirrors, the pack manifest, and the Pester suites.

Evidence sources: `artifacts/pr_context.summary.txt` and `artifacts/pr_context.appendix.txt` (regenerated by this review at head `c92f331b4`; they were absent from the worktree), direct inspection of the diff and the converted files, the feature evidence folders (`evidence/baseline`, `evidence/regression-testing`, `evidence/qa-gates`, `evidence/other`), and independent check-only re-runs performed by this review: the AC-7, AC-8, AC-9, AC-13, AC-14, AC-15, AC-21, and AC-22 searches (all no match, or the single expected match for AC-14); SHA-256 comparison of all seven source/mirror pairs (all equal); `core.json` ordering; line counts of every changed `.ps1` and `.json` file (maximum 461); the AC-20 and AC-23 scope checks; and `validate_evidence_locations.py` (exit 0). The review did not re-run Pester, the formatter, or the analyzer, and did not regenerate coverage.

Outcome: every policy section is PASS. Format (`ChangedCount=0`), analyzer (`DiagnosticCount=0`), and Pester (5033/5033) closed in a single pass (`evidence/qa-gates/final-qc-loop.2026-10-12T04-19.md`, `FINAL_CLEAN_PASS: 1`). Line coverage is 98.32% or higher on every changed production file and changed-line coverage is 100% on every file. Six non-blocking findings are recorded in Section 8.

**Blocking findings: 0. Non-blocking findings: 6.**

**Policy documents evaluated:**
- [x] `general-code-change.instructions.md` (mirrored by `.claude/rules/general-code-change.md`)
- [x] `general-unit-test.instructions.md` (mirrored by `.claude/rules/general-unit-test.md`)
- [x] `.claude/rules/quality-tiers.md` (`.claude/hooks` is classified T3 in `quality-tiers.yml`)
- [x] `.claude/rules/tonality.md`

**Language-specific policies evaluated:**
- N/A `python-code-change.instructions.md` + `python-unit-test.instructions.md` (no Python file changed)
- [x] `powershell-code-change.instructions.md` + `powershell-unit-test.instructions.md` (mirrored by `.claude/rules/powershell.md`)
- N/A TypeScript, C#, Bash (no file of these languages changed)
- [x] JSON: `core.json` entry order and manifest-completeness tests

PowerShell is the only coverage language with changed files. Its coverage verdict is PASS (Section 1.2.1).

**Temporary artifacts cleanup:**
- [x] All temporary/one-time scripts created during development were kept under the session scratchpad and are not in the branch diff (`evidence/qa-gates/scope-boundary.2026-10-12T04-21.md`, `OUT_OF_ALLOWLIST_COUNT: 0`). The review worktree is clean apart from the regenerated, untracked `artifacts/pr_context.*.txt` files.
- [x] Any ongoing tooling scripts are fully tested and compliant with repo policies: the only new non-test script is `validate-orchestrator-output-routing.ps1` (100% line coverage).
- Scripts created during development and disposition: plan Appendix A scratch scripts (`run-ps.sh`, `pester-run.ps1`, `ps-format-check.ps1`, `pssa-count.ps1`, `changed-line-coverage.ps1`, the corpus harness, and the drift-check scripts) were saved under the session scratchpad and never committed (plan Appendix A preamble).

---

## Rejected Scope Narrowing

No scope narrowing was detected. The caller prompt contains classification guidance, recorded verbatim here because it touches finding classification:

> "Known context to account for, not to flag as blocking: the bundled-copy parity pytest fails locally on gitignored state (issue 510) and is verified on PR CI; the evidence file subagentstop-firing-observation.2026-10-12T04-13.md says UNVERIFIED and is superseded by subagentstop-firing-runtime-observation.2026-10-12T08-55.md."

Justification: this instruction does not narrow the audited file set, skip a toolchain or coverage check, or exempt a language. Both items were still evaluated. The bundled-copy parity tests passed locally in this branch's evidence (`evidence/qa-gates/pytest-regression.2026-10-12T04-04.md`, 58 passed), and no PR exists yet, so PR CI confirmation is pending rather than relied upon. The firing observation is assessed in Section 8 (finding PA-NB-5 and PA-NB-6). The audit scope used is the full diff `origin/epic/subagentstop-envelope-integration...HEAD` (133 files).

---

## Evidence Location Compliance

- `poetry run python -I scripts/dev_tools/validate_evidence_locations.py --root .` exit code: 0 (no violations reported).
- Branch diff scan for `artifacts/baselines/`, `artifacts/qa/`, `artifacts/evidence/`, `artifacts/coverage/`: `git diff --name-only origin/epic/subagentstop-envelope-integration...HEAD` lists no path under `artifacts/`. All 97 evidence files are under `docs/features/active/subagentstop-envelope-orchestrator-family-903/evidence/{baseline,regression-testing,qa-gates,other}/`.
- `EVIDENCE_LOCATION_OVERRIDE_REJECTED`: none; no caller instruction supplied a non-canonical evidence path.
- Verdict: PASS.

---

## 1. General Unit Test Policy Compliance

### 1.1 Core Principles

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Independence** - Tests run in any order | PASS (with pre-existing exception) | Every entry-tail driver (`Invoke-HookTail` in the Envelope suites, `Invoke-OrchestratorOutputHookProcess` in FailClosed) saves and restores `[Console]::In`, `[Console]::Error`, `CLAUDE_HOOK_INPUT`, and the dependency-failure state in `finally`. A cross-suite module-state interaction makes the two `baseline mock interception probe` rows fail when `hook-import-failure-exemptions.FailClosed.Tests.ps1` runs before the dependency suites in one session; the executor reproduced it with the base versions of all three files (`evidence/regression-testing/phase2-pass-after.2026-10-12T01-20.md`), so it predates this branch. Recorded as PA-NB-4. |
| **Isolation** - Each test targets single behavior | PASS | One `It` per re-entry row (39 rows named O-1 to O-15, X-1 to X-12, P-1 to P-7, R-1 to R-5), one `It` per anomaly code via `-ForEach`, and separate rows for each tail path (block, pass, legacy-source, helper-load failure, guard-load failure). |
| **Fast Execution** - Tests complete quickly | PASS | No row sleeps, waits, or starts a process; stdin and stderr are in-memory `StringReader`/`StringWriter` objects. The full 5033-test run completed in one session (`evidence/qa-gates/pester-full.2026-10-12T04-15.md`). |
| **Determinism** - Consistent results | PASS | No clock reads, randomness, network, or file creation. A search for `TestDrive`, `New-TemporaryFile`, `GetTempPath`, `GetTempFileName`, `Start-Sleep`, `Set-Content`, `Out-File`, `$env:TEMP`, and `Remove-Item` over the 19 changed suites returned no match. Checkpoint and plan reads go through mocked seams (`Get-CheckpointFileContent`, `Get-PlanFileContent`, `Test-ArtifactFile`). |
| **Readability & Maintainability** - Clear structure | PASS | Row IDs lead each `It` name (`E-RA-7 exits 2 naming subagentstop-envelope.ps1 ...`, `O-11 halt response blocks once`); each new suite has a header stating the driver mechanism and the no-file/no-clock constraint; every suite is at or under 461 lines. |

### 1.2 Coverage and Scenarios

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Baseline Coverage Documented** | PASS | **Baseline (pre-development):** `validate-orchestrator-output.ps1` 95.42% (125/131), `validate-orchestrator-output-resolution.ps1` 98.94% (93/94), `validate-executor-output.ps1` 69.91% (79/113), `validate-planner-output.ps1` 97.94% (190/194), `validate-required-artifact-output.ps1` 69.81% (37/53); aggregate 89.57% (524/585). Routing sibling not yet present.<br>**Command:** self-hosted Pester run (`pester-run.ps1 -CoveragePath <5 files>`), launched through `sh` per spec Test Strategy.<br>**Timestamp:** 2026-10-12T00-02 (`evidence/baseline/pester-coverage.2026-10-12T00-02.md`) |
| **No Coverage Regression** | PASS | **Post-change coverage:** 99.09%, 100%, 98.94%, 98.32%, 99.5%, 98.36% for the six files in the order above plus the routing sibling; aggregate 99.02% (606/612).<br>**Change:** executor +28.41 points, required-artifact +28.55 points, orchestrator +3.67 points, planner +1.56 points, resolution unchanged.<br>**Status:** no file regressed; changed-line coverage is 100% on every file (`evidence/qa-gates/coverage-delta.2026-10-12T04-20.md`). This review confirmed that the post-change MISSED line numbers (orchestrator 234, executor 82 and 179, planner 157, resolution 89, required-artifact 95) correspond to the current HEAD file contents (for example, orchestrator line 234 is the `$SessionRoot` default in `Get-OrchestratorOutputBlockDecision`). |
| **New Code Coverage >=90%** | PASS | **New/modified files:** `validate-orchestrator-output-routing.ps1` (new) 100% (28/28); every modified file at least 98.32%.<br>**New code coverage:** 100% of 148 changed executable lines (39+28+5+29+23+24).<br>**Calculation method:** `changed-line-coverage.ps1` intersects the added lines from `git diff origin/epic/subagentstop-envelope-integration` with the HIT/MISSED lists of the final coverage report. |
| **Comprehensive Coverage** | PASS | **All functions tested:** the four pure entries (`Invoke-*OutputValidation`), the four new block-decision functions (`Get-*OutputBlockDecision`), `Test-HumanInteractionShape`, `Get-OrchestratorOutputWaveBarrierDecision`, `Find-OrchestratorOutputRunSignalValue`, the relocated `Test-OrchestratorCheckpointStructure` and `Invoke-RoutingContractValidation`, and every entry tail.<br>**Untested code:** 7 lines in total (parameter defaults and an empty-value return; listed above). |
| **Positive Flows** - Valid inputs | PASS | **All positive scenarios tested:**<br>- E-ORC-3, E-EXE-2, E-PLN-3, E-RA-4: tail exits 0 for a valid message and fixture<br>- Block-once rows return `Ok = $true` on the `stop_hook_active: true` call<br>- S2-13: case-variant checkpoint keys kept (CR-1)<br>- CORPUS-EXE-1, CORPUS-PLN-1: plan arrays with empty lines accepted<br>**Total positive tests:** at least 19 (4 tail pass rows + 15 block-once second calls) plus the existing positive rows in the modified suites |
| **Negative Flows** - Invalid inputs | PASS | **All negative scenarios tested:**<br>- 6 anomaly codes per validator (24 rows: E-ORC-8, E-EXE-7, E-PLN-7, E-RA-9)<br>- `output`-only envelope (E-ORC-5, E-EXE-4, E-PLN-5, E-RA-6)<br>- `CLAUDE_HOOK_INPUT` passing while stdin fails (E-ORC-4, E-EXE-3, E-PLN-4, E-RA-5)<br>- missing `-AgentName` / `-RequiredArtifact` (E-RA-2, E-RA-3, R-1)<br>- every non-S1 block condition in the re-entry table (39 rows)<br>**Total negative tests:** at least 82 |
| **Edge Cases** - Boundary conditions | PASS | **All edge cases tested:**<br>- `stop_hook_active` as the string `"true"` does not release a block-once stop (O-STR)<br>- empty and whitespace `last_assistant_message` (O-2, X-2, P-2, R-3)<br>- wave-barrier message that already carries `Report them to the operator and halt.` is not double-suffixed (O-14)<br>- case-variant `Route_Id` key (S2-13)<br>**Total edge case tests:** at least 7 |
| **Error Handling** - Error paths | PASS | **All error scenarios tested:**<br>- helper load failure with `stop_hook_active: true` exits 2 naming `subagentstop-envelope.ps1` (E-ORC-7, E-EXE-5, E-PLN-6, E-RA-7)<br>- dependency-guard load failure exits 2 (E-EXE-6, E-RA-8)<br>- resolver exception yields `ORCHESTRATOR_CHECKPOINT_UNRESOLVED: ... RESOLVER_FAILED` (S2-14 pure, E-ORC-6 tail)<br>- routing-sibling load failure blocks (B1 dynamic row)<br>- H7/H8 module import failures exit 2<br>**Total error handling tests:** at least 13 |
| **Concurrency** - If applicable | N/A | Each hook is a single synchronous invocation with no shared state across invocations. |
| **State Transitions** - If applicable | PASS | The re-entry policy is a two-state transition (first stop, re-entered stop). Every non-S1 row is driven through both states (AC-22; `evidence/qa-gates/named-rows.2026-10-12T04-19.md`, 39 REENTRY-ROW PASS). |

### 1.2.1 Per-Language Coverage Comparison

- PowerShell: Baseline: 89.57% lines aggregate over the 5 pre-existing production files (per file 69.81% to 98.94%) -> Post-change: 99.02% lines aggregate over the 6 production files (per file 98.32% to 100%). Change: +9.45 points aggregate; executor +28.41 points, required-artifact +28.55 points, no file decreased. New/changed-code coverage: 100% of 148 changed executable lines; new routing sibling 100% (28/28). Branch coverage: not measured by Pester; no branch threshold applies to PowerShell per `.claude/rules/powershell.md`. Repo-wide PowerShell line figure: not produced by this branch's evidence (the run was scoped to the six production files per spec AC-18); see PA-NB-1. Disposition: PASS (every changed file >= 85%; new file >= 90%; no regression on changed lines). Evidence: `evidence/baseline/pester-coverage.2026-10-12T00-02.md`, `evidence/qa-gates/pester-coverage.2026-10-12T04-14.md`, `evidence/qa-gates/coverage-delta.2026-10-12T04-20.md`.
- TypeScript: `N/A - out of scope` (zero changed `.ts` files). Disposition: N/A.
- Python: `N/A - out of scope` (zero changed `.py` files). Disposition: N/A.
- C#: `N/A - out of scope` (zero changed `.cs` files). Disposition: N/A.

### 1.3 Test Structure and Diagnostics

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Clear Failure Messages** | PASS | Assertions use `-Because $result.Stderr` / `-Because $result.Message`, so a failure prints the actual stderr or message; `Assert-ReentryRow` labels the first and second calls separately. |
| **Arrange-Act-Assert Pattern** | PASS | Envelope and resolution rows carry explicit `# Arrange`, `# Act`, `# Assert` comments. Re-entry rows follow the same order through `Set-Reentry*` (arrange), two `Invoke-*` calls (act), and `Assert-ReentryRow` (assert) without the comments. |
| **Document Intent** | PASS | Each new suite header names the issue, the driver mechanism, and the constraints; driver helpers carry one-line comments stating what is replaced and restored. |

### 1.4 External Dependencies

| Requirement | Status | Evidence |
|------------|--------|----------|
| **No External Services** | PASS | No network, database, or process launch in any changed suite. |
| **Mocking Used** | PASS | `Mock Import-Module {}`, `Mock Join-Path` with `-ParameterFilter` for load failures, mocked resolution and checkpoint seams, injected `-RoutingInvoker`. |
| **No Temporary Files** | PASS | Search results in Section 1.1 (Determinism). |
| **No Mutable Global State** | PASS | Console streams, `CLAUDE_HOOK_INPUT`, `$global:LASTEXITCODE`, and `$script:HookDependencyFailures` are restored in `finally`. |

---

## 2. General Code Change Policy Compliance

### 2.1 Design Principles

| Principle | Status | Evidence |
|-----------|--------|----------|
| **Simplicity First** | PASS | Each pure entry splits into a thin envelope/re-entry wrapper and a `Get-*OutputBlockDecision` function that keeps the original checks in their original order. |
| **Reusability** | PASS (with observation) | All envelope handling is delegated to the shared E1 helper. The eight-line re-entry decision and the report-and-halt literal are repeated in four files; see code-review CR-1 (non-blocking). |
| **Extensibility** | PASS | Block results carry a `Repairable` flag set at the source, so a new condition declares its own re-entry class without editing the wrapper. |
| **Separation of Concerns** | PASS | I/O stays behind `Get-CheckpointFileContent`, `Get-PlanFileContent`, and `Test-ArtifactFile`; stdin is read only by the helper; exit codes are produced only in the entry tails. |

### 2.2 Classes, Functions, and APIs

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Appropriate Abstractions** | PASS | Standalone functions in dot-sourced scripts, consistent with the existing hook pattern. |
| **Small, Focused Methods** | PASS | The largest new function (`Get-OrchestratorOutputBlockDecision`) is 116 lines and is the relocated original body; the wrappers are 15 to 25 lines. |
| **Interfaces/Protocols Used** | N/A | PowerShell scripts; seams are scriptblocks and mockable functions. |

### 2.3 Error Handling and Logging

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Fail Fast and Explicitly** | PASS | Every block path writes to stderr and exits 2; AC-9 search for `exit 1` and `Write-Error` over the six production files returns no match (re-run by this review). |
| **No Silent Failures** | PASS | Each guarded load records `Add-HookDependencyFailure`; the guard load itself sets `HookDependencyGuardLoadFailed`, which the tail checks first. The CR-3 resolver `catch` returns a block result rather than swallowing the exception. |
| **Appropriate Logging Levels** | PASS | Hooks report through stderr reason lines with stable prefixes (`ORCHESTRATOR_CHECKPOINT_UNRESOLVED:`, `MODEL_ROUTING_BLOCKED:`, `ROUTING_CONTRACT_BLOCKED:`, `validate-planner-output:`, `validate-executor-output:`, `validate-required-artifact-output:`). |
| **Invariants Enforced** | PASS | The dependency decision is evaluated before any `.Ok` read; all guarded loads precede `$ErrorActionPreference = 'Stop'` in every file (verified by reading orchestrator lines 51-64, executor 35-39, planner 37-41, and required-artifact 36-40). |

### 2.4 Naming Conventions

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Descriptive Names** | PASS | `Get-ExecutorOutputBlockDecision`, `SubagentStopReportAndHaltLine`, `resolutionRepairable`. |
| **Language Conventions** | PASS | Approved verbs (PSScriptAnalyzer `DiagnosticCount=0`). |
| **Standard Abbreviations Only** | PASS | No non-standard abbreviations introduced. |

### 2.5 Public APIs and Compatibility

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Keyword Parameters with Defaults** | PASS | Script parameters unchanged (`-CheckpointPath`, `-ArtifactType`, `-AgentName`, `-RequiredArtifact`, empty `param()`); REG-2 confirms every registered argument exists. |
| **Composition over Inheritance** | N/A | No class hierarchy. |
| **No Breaking Changes** | PASS (documented) | `-RawPayload` was replaced by `-InputText` on the four pure entries, and the `CLAUDE_HOOK_INPUT` transport was removed. Both are specified by spec.md ("Backward-compatibility expectations"); all in-repo callers (the Pester suites) were updated. |

### 2.6 File Size Limit

| Requirement | Status | Evidence |
|------------|--------|----------|
| **No file exceeds 500 lines** | PASS | Largest production file 440 lines (`validate-planner-output.ps1`); largest test file 461 lines (`hook-import-failure-exemptions.FailClosed.Tests.ps1`). Re-measured by this review with `wc -l` over every changed `.ps1`/`.json` file. |

### 2.7 Dependencies

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Approved Libraries Only** | PASS | No new dependency; the hooks consume the existing E1 helper and the existing `.claude/lib` modules. |

### 2.8 I/O Boundaries

| Requirement | Status | Evidence |
|------------|--------|----------|
| **I/O Isolated** | PASS | Filesystem reads remain behind the existing seams; stdin is read only inside `Read-SubagentStopEnvelope`. |
| **Core Logic Testable** | PASS | The `-InputText` seam lets every block decision run without stdin. |
| **No Temp Files in Tests** | PASS | See Section 1.1. |

### 2.9 Coverage Exclusion Policy

| Requirement | Status | Evidence |
|------------|--------|----------|
| **No production path excluded** | PASS | The coverage run lists all six production files in `CodeCoverage.Path`; no exclusion entry was added. |

---

## 3. Language-Specific Code Change Policy Compliance

### PowerShell

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Formatter clean** | PASS | `FORMAT-SUMMARY ChangedCount=0` over 25 files (`evidence/qa-gates/format-check.2026-10-12T04-14.md`). |
| **PSScriptAnalyzer clean** | PASS | `PSSA-SUMMARY DiagnosticCount=0` with `scripts/powershell/PoshQC/settings/pssa.settings.psd1` (`evidence/qa-gates/pssa.2026-10-12T04-14.md`). |
| **Approved verbs** | PASS | Covered by the analyzer result. |
| **StrictMode** | PASS | `Set-StrictMode -Version Latest` retained in all four hook files. |
| **Smallest seam for mocking** | PASS | `-InputText` pure-entry seam; existing file-read seams retained. |
| **Toolchain via MCP** | PASS (documented deviation) | Tests and coverage ran through self-hosted Pester scripts launched with `sh`, not `mcp__drm-copilot__run_poshqc_test`. spec.md Test Strategy prescribes this because the MCP runner loads the installed-extension module and omits new population files. Recorded as PA-NB-3. |
| **No Python legs in enforcement hooks** | PASS | AC-21 search over the six files returned no match (re-run by this review); `enforcement-hooks-no-python-invocation.Tests.ps1` passed (named-rows). |

### JSON

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Manifest entry in sorted position** | PASS | `core.json` lines 73-75: `validate-orchestrator-output-resolution.ps1`, `validate-orchestrator-output-routing.ps1`, `validate-orchestrator-output.ps1` (re-read by this review). |

---

## 4. Language-Specific Unit Test Policy Compliance

### PowerShell (Pester v5)

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Pester 5 and `*.Tests.ps1` naming** | PASS | `#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }` in each new suite. |
| **Test location mirrors source** | PASS | All suites under `tests/scripts/claude-hooks/`, matching the existing layout for `.claude/hooks/`. |
| **Mock signature parity** | PASS | Routing stubs match the production `param($Path, $Type)` invoker signature (suppression justified in the suite header). |
| **No sleeps or timing hacks** | PASS | Search in Section 1.1. |
| **Line coverage >= 85%** | PASS | Section 1.2.1. |
| **No regression on changed lines** | PASS | 100% changed-line coverage. |
| **Terminal / Test Explorer parity** | PASS (pre-existing exception) | Suites resolve paths from `$PSScriptRoot`. The pre-existing cross-suite order interaction is recorded as PA-NB-4. |

---

## 5. Test Coverage Detail

| File | Baseline | Post-change | Changed lines hit/total | Result |
|------|----------|-------------|-------------------------|--------|
| `.claude/hooks/validate-orchestrator-output.ps1` | 95.42% | 99.09% | 39/39 | PASS |
| `.claude/hooks/validate-orchestrator-output-routing.ps1` | new file | 100% | 28/28 | PASS |
| `.claude/hooks/validate-orchestrator-output-resolution.ps1` | 98.94% | 98.94% | 5/5 | PASS |
| `.claude/hooks/validate-executor-output.ps1` | 69.91% | 98.32% | 29/29 | PASS |
| `.claude/hooks/validate-planner-output.ps1` | 97.94% | 99.5% | 23/23 | PASS |
| `.claude/hooks/validate-required-artifact-output.ps1` | 69.81% | 98.36% | 24/24 | PASS |

Bundled mirrors under `extensions/` are byte-identical copies and are not in the Pester coverage population; they are verified by hash (Section 7).

---

## 6. Test Execution Metrics

| Run | Total | Passed | Failed | Evidence |
|-----|-------|--------|--------|----------|
| Full `tests/scripts/claude-hooks` + `tests/scripts/claude-runtime` (baseline) | 4892 | 4892 | 0 | `evidence/baseline/pester-full.2026-10-12T00-08.md` |
| Full `tests/scripts/claude-hooks` + `tests/scripts/claude-runtime` (final) | 5033 | 5033 | 0 | `evidence/qa-gates/pester-full.2026-10-12T04-15.md` |
| Coverage population (20 suites) | 288 | 288 | 0 | `evidence/qa-gates/pester-coverage.2026-10-12T04-14.md` |
| Named rows (15 suites, 39 re-entry rows) | 359 | 359 | 0 | `evidence/qa-gates/named-rows.2026-10-12T04-19.md` |
| Fail-before (Phase 1) | recorded | n/a | expected failures | `evidence/regression-testing/fail-before.2026-10-12T00-45.md` |
| Python push-down contracts | 58 | 58 | 0 | `evidence/qa-gates/pytest-regression-agents.2026-10-12T04-07.md` |
| Jest manifest completeness | 16 | 16 | 0 | `evidence/qa-gates/jest-manifest.2026-10-12T04-04.md` |

---

## 7. Code Quality Checks

| Check | Result | Evidence |
|-------|--------|----------|
| Format (Invoke-Formatter) | PASS, 0 changes | `evidence/qa-gates/format-check.2026-10-12T04-14.md` |
| Lint (PSScriptAnalyzer) | PASS, 0 diagnostics | `evidence/qa-gates/pssa.2026-10-12T04-14.md` |
| Type check | N/A (PowerShell) | `.claude/rules/powershell.md` |
| Architecture boundary | PASS | Routing sibling loaded through a guarded dot-source; B1 dynamic row passes for the new edge |
| Mirror byte identity | PASS, 7/7 pairs equal | This review: SHA-256 of six hooks and `prd-feature.md` against their mirrors; `evidence/qa-gates/mirror-hashes.2026-10-12T04-03.md`, `agent-mirror-hashes.2026-10-12T04-06.md` |
| Bundled-copy parity / manifest completeness | PASS locally; PR CI pending (no PR exists yet) | `evidence/qa-gates/pytest-regression.2026-10-12T04-04.md`, `jest-manifest.2026-10-12T04-04.md` |
| Static AC searches (AC-7/8/9/13/14/15/21/22) | PASS | Re-run by this review with the Grep tool; no match except the single `-Global` line for AC-14 (line 62) |
| Scope boundary (AC-23) | PASS | This review: no E3/E4 validator, PreToolUse hook, `settings.json`, helper, Codex path in the diff |

---

## 8. Gaps and Exceptions

### Identified Gaps

| ID | Classification | Gap | Impact | Recommended action |
|----|----------------|-----|--------|--------------------|
| PA-NB-1 | Non-blocking | The repository coverage artifact path `artifacts/pester/powershell-coverage.xml` is absent from the worktree, and no repo-wide PowerShell line figure was produced. The coverage run was scoped to the six production files (as spec AC-18 requires) and its raw XML was written to the session scratchpad, which is not retained. This review treated the canonical feature evidence (per-file HIT/MISSED line lists) as the coverage artifact, consistent with the Evidence Location Invariant, and confirmed that the MISSED line numbers match the current HEAD files. | The per-file and changed-line gates are verified; the repo-wide gate is not evaluated for this branch. | For future runs, retain the coverage XML under `evidence/qa-gates/` or record a repo-wide figure. No change to this branch is required. |
| PA-NB-2 | Non-blocking | spec.md line 217 states that no first-stop rule is loosened apart from the listed notes. Two corpus-driven rule changes (executor and planner `[AllowEmptyString()]` on `$Lines`; planner `$insidePhaseSection` predicate) were made under operator Amendment B and carry `SPEC_INVARIANT_EXCEPTION: spec.md:217`, but spec.md `## Amendments` does not yet record them. The plan assigns this to the coordinator ([P7-T10]; `evidence/other/pr-linkage-notes.md`, section "RULE-CHANGE coordinator items"). | The spec text and the delivered behavior disagree until the amendment is written. | Coordinator records both RULE-CHANGE entries in spec.md `## Amendments` before the PR merges. |
| PA-NB-3 | Non-blocking | Pester and coverage ran through self-hosted scripts instead of the MCP `run_poshqc_test` tool named in `.claude/rules/powershell.md`. | None on results; spec Test Strategy prescribes this route because the MCP runner omits new population files. | None. |
| PA-NB-4 | Non-blocking (pre-existing) | Two `baseline mock interception probe` rows fail when `hook-import-failure-exemptions.FailClosed.Tests.ps1` runs before `hook-dependency-failure.Claude.Tests.ps1` / `.SpecialCases.Tests.ps1` in one Pester session. Reproduced with the base versions of the edited files. | Combined-suite gates must order the dependency suites first; the default alphabetical full run passes. | File a follow-up for the module-state leak in FailClosed. |
| PA-NB-5 | Non-blocking | `evidence/other/pr-linkage-notes.md` states that the frontmatter firing question is still open and cites `subagentstop-firing-observation.2026-10-12T04-13.md` (UNVERIFIED). The later `subagentstop-firing-runtime-observation.2026-10-12T08-55.md` records that the `atomic-executor` frontmatter registration fired. | The PR body may carry a stale follow-up statement. | When authoring the PR, cite the runtime observation for `atomic-executor` and keep the question open only for the other frontmatter-only agents (`epic-review`, `prd-feature`, `staged-review`, `status-updater`). |
| PA-NB-6 | Non-blocking | `subagentstop-firing-runtime-observation.2026-10-12T08-55.md` carries a filename and `Timestamp` of 08-55, but it was committed at 04:25 local (08:25 UTC) in `c92f331b4`; neither reading matches the local-clock rule in `evidence-and-timestamp-conventions`. Its content is secondhand ("the orchestrator did not independently capture the hook stderr"). | The observation is not an acceptance criterion (spec Test Strategy, "Manual validation"); no AC depends on it. | Optional: re-record the observation with a host-clock timestamp and captured stderr. |

### Accepted Exceptions

- E1 helper "imports nothing" literal search matched help text (`evidence/other/e1-contract-reconciliation.2026-10-11T23-50.md`, DEVIATION); the AST check found no import. This is not an AC-1 condition and is accepted.
- Bundled-copy parity (issue #510): passed locally in this branch's evidence; PR CI confirmation is pending because no PR exists yet.

---

## 9. Summary of Changes

- Four validators read the SubagentStop envelope from stdin through `Read-SubagentStopEnvelope`, use only `AssistantText` and `StopHookActive`, and block only through `Exit-SubagentStopBlock` (exit 2) or the inline S1 tail.
- Executor and required-artifact hooks adopt `hook-dependency-guard.ps1` and the S1 tail.
- Re-entry policy: 15 block-once rows append the report-and-halt line and allow the re-entered stop; 24 block-always rows block on every stop.
- `validate-orchestrator-output.ps1` reduced from 466 to 344 lines; `Test-OrchestratorCheckpointStructure` and `Invoke-RoutingContractValidation` moved to `validate-orchestrator-output-routing.ps1`.
- #787 CR-1 (`-contains`), CR-3 (resolver `try`/`catch`), CR-7 (comment); #786 double import and FailClosed stale `finally` resets.
- `prd-feature.md` passes `-RequiredArtifact` once.
- Corpus-driven fixes: `[AllowEmptyString()]` on plan line parameters (executor, planner); planner skips non-task checkbox lines outside phase sections.

---

## 10. Compliance Verdict

| Area | Verdict |
|------|---------|
| General unit test policy | PASS |
| General code change policy | PASS |
| PowerShell code change policy | PASS |
| PowerShell unit test policy | PASS |
| PowerShell coverage (only coverage language with changed files) | PASS |
| Evidence location compliance | PASS |
| Tonality | PASS |

**Overall: PASS. Blocking findings: 0. Non-blocking findings: 6 (PA-NB-1 to PA-NB-6).** No remediation inputs are required.

---

## Appendix A: Test Inventory

New suites (8):
- `tests/scripts/claude-hooks/validate-orchestrator-output.Envelope.Tests.ps1` (E-ORC-1 to E-ORC-8)
- `tests/scripts/claude-hooks/validate-executor-output.Envelope.Tests.ps1` (E-EXE-1 to E-EXE-7)
- `tests/scripts/claude-hooks/validate-required-artifact-output.Envelope.Tests.ps1` (E-RA-1 to E-RA-10)
- `tests/scripts/claude-hooks/validate-orchestrator-output.Reentry.Tests.ps1` (O-1 to O-15, O-STR, O-AST)
- `tests/scripts/claude-hooks/validate-executor-output.Reentry.Tests.ps1` (X-1 to X-12, X-AST)
- `tests/scripts/claude-hooks/validate-planner-output.Reentry.Tests.ps1` (P-1 to P-7, P-AST)
- `tests/scripts/claude-hooks/validate-required-artifact-output.Reentry.Tests.ps1` (R-1 to R-5, R-AST)
- `tests/scripts/claude-hooks/subagentstop-envelope-orchestrator-family.Registration.Tests.ps1` (REG-1 to REG-5)

Modified suites (11): `validate-orchestrator-output.Tests.ps1`, `.model-routing`, `.artifact-type-dispatch`, `.WaveBarrier`, `.WorktreeResolution`, `validate-orchestrator-output-resolution.Tests.ps1` (S2-13, S2-14), `validate-executor-output.Tests.ps1` (CORPUS-EXE-1 and coverage rows), `validate-planner-output.Tests.ps1` (CORPUS-PLN-1), `validate-planner-output.Coverage.Tests.ps1` (E-PLN-1 to E-PLN-7), `validate-required-artifact-output.Tests.ps1`, `hook-import-failure-exemptions.FailClosed.Tests.ps1` (H7/H8 stdin drivers).

Regression suites run unchanged: `hook-dependency-failure.Claude.Tests.ps1`, `hook-dependency-failure.SpecialCases.Tests.ps1`, `enforcement-hooks-no-python-invocation.Tests.ps1`, `test_push_down_claude_resource_contracts.py`, `test_push_down_claude_pack_manifest_completeness.py`, `claude-pack-manifest-completeness.test.ts`.

## Appendix B: Toolchain Commands Reference

- Format: `sh <SCRATCHPAD>/run-ps.sh <SCRATCHPAD>/ps-format-check.ps1 <25 files>` (read-only `Invoke-Formatter` comparison)
- Analyzer: `sh <SCRATCHPAD>/run-ps.sh <SCRATCHPAD>/pssa-count.ps1 <25 files>` with `scripts/powershell/PoshQC/settings/pssa.settings.psd1`
- Pester with coverage: `sh <SCRATCHPAD>/run-ps.sh <SCRATCHPAD>/pester-run.ps1 -TestPath <20 suites> -CoveragePath <6 production files>`
- Full Pester: `sh <SCRATCHPAD>/run-ps.sh <SCRATCHPAD>/pester-run.ps1 -TestPath tests/scripts/claude-hooks,tests/scripts/claude-runtime`
- Changed-line coverage: `sh <SCRATCHPAD>/run-ps.sh <SCRATCHPAD>/changed-line-coverage.ps1 -BaseRef origin/epic/subagentstop-envelope-integration -Path <6 files>`
- Python: `poetry run pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py tests/scripts/dev_tools/test_push_down_claude_pack_manifest_completeness.py tests/scripts/dev_tools/test_claude_planning_integrity_contracts.py tests/scripts/dev_tools/test_parallel_orchestrator_surface_contracts.py`
- Jest: `npm --prefix extensions/drm-copilot test -- test/lib/push-down/claude-pack-manifest-completeness.test.ts`
- Review-side checks: `poetry run python -m scripts.dev_tools.pr_context.collector --base origin/epic/subagentstop-envelope-integration`; `poetry run python -I scripts/dev_tools/validate_evidence_locations.py --root .`; Grep-tool searches for AC-7/8/9/13/14/15/21/22; `sha256sum` source/mirror comparison; `wc -l` line counts.
