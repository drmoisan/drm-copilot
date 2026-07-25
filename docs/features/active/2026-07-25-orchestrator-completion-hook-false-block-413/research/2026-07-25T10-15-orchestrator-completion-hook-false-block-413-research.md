# Research: Orchestrator completion hook false-blocks DONE on successful validation (#413)

- Date: 2026-07-25T10-15
- Branch: `bug/orchestrator-completion-hook-false-block-413` (based on `origin/main`)
- Scope: `.claude/hooks/validate-orchestrator-output.ps1` and its test/bundled surfaces only. No change to any Python validator file (hard constraint honored; see Constraint Check below).

## Constraint Check (stated first, per delegation)

The correct fix is in the PowerShell hook, not in the Python validator. `scripts/dev_tools/validate_orchestration_artifacts.py` implements a clean, conventional CLI contract (success line to stdout + exit 0; errors to stderr + exit 1) that four other consumers and the sibling PowerShell preflight function already rely on. No validator change is needed or proposed.

## 1. Validator CLI Output Contract

Source: `scripts/dev_tools/validate_orchestration_artifacts.py`, `main()` (lines 323-356):

```python
errors = _validate_from_args(args)
if errors:
    for error in errors:
        print(error, file=sys.stderr)
    return 1
print(f"{args.artifact_type} validation passed: {args.path}")
return 0
```

- (a) **Success:** exactly one line, `<artifact_type> validation passed: <path>`, printed to **stdout** (line 351); return value 0 → process exit 0 via `raise SystemExit(main())` (line 356). For the hook's invocation the line is `orchestrator-state validation passed: artifacts/orchestration/orchestrator-state.json` (85 characters, matching the caller-verified capture).
- (b) **Failure:** one line per error string, all printed to **stderr** (lines 347-349); nothing is printed to stdout on the failure path.
- (c) **Exit codes:** 0 on success, 1 on validation failure. Two additional non-zero paths exist: argparse rejects bad arguments with usage text on stderr and exit 2, and an unhandled exception (e.g. `OSError` from `_read_text` on a missing file, line 39-59) propagates through `SystemExit(main())` as a traceback on stderr with exit 1. Every abnormal path is non-zero.
- (d) **Success-line format stability:** the exact success line for this CLI is **not pinned by any test**. `tests/scripts/dev_tools/test_validate_orchestration_artifacts_dispatch.py` asserts return codes only (e.g. lines 66-68, 80-82, 116-120). The only test in the repository that pins a "validation passed" line is for a *different* CLI (`tests/scripts/dev_tools/test_validate_discovery_artifacts_dispatch.py:70`, discovery validator). The format is conventional but contractually untested.
- (e) **Can it exit 0 while printing errors, or print nothing on failure?** No. `return 1` is reached if and only if `errors` is non-empty, and error text is printed on exactly that path. `return 0` is reached only after printing the success line. There is no path that exits 0 with error output. Therefore exit-code-only discrimination does **not** weaken the gate against this validator: the exit code is a complete and sufficient failure signal.

Verified root cause (re-confirmed, not re-derived): `.claude/hooks/validate-orchestrator-output.ps1:224`:

```powershell
$hasErrors = ($exitCode -ne 0) -or (-not [string]::IsNullOrWhiteSpace($outputText))
```

The default `$Invoker` (lines 182-209) captures stdout+stderr merged (`2>&1`, line 191), so the 85-character success line makes the second disjunct fire on every clean pass, producing `ROUTING_CONTRACT_BLOCKED: orchestrator-state validation passed: ...` (exit 1). The hook is broken closed whenever `Test-PythonOrchestratorValidatorAvailable` returns true.

## 2. Recommended Fix

### Recommendation: Option A — key `HasErrors` solely on `$exitCode -ne 0`

Change `.claude/hooks/validate-orchestrator-output.ps1:224` to:

```powershell
$hasErrors = ($exitCode -ne 0)
```

keeping `ErrorText = $outputText` unchanged, and update the function's `.DESCRIPTION` (lines 168-170), which currently documents the two-disjunct behavior ("reported a non-zero exit or produced any error text").

**Justification.** (1) Exit code is a complete failure discriminator for both invoker branches: the Python CLI never exits 0 with error output (Section 1e), and the portable fallback returns `ExitCode = 1` whenever any error string exists (Section 3). (2) It is the established repository pattern: the sibling function `Invoke-OrchestratorStatePreflight` in `.claude/lib/orchestrator-state/OrchestratorState.psm1:469` already uses exactly `HasErrors = ($exitCode -ne 0)`, and its test (`tests/scripts/claude-lib/orchestrator-state/OrchestratorState.Tests.ps1:241-245`) locks in that an exit-0 result carrying the literal success line `orchestrator-state validation passed: x.json` does not block. The bundled Codex `enforce-pr-author-skill.ps1` uses the same shape (`extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-pr-author-skill.ps1:89`). (3) It preserves every downstream contract: the `MODEL_ROUTING_BLOCKED:` vs `ROUTING_CONTRACT_BLOCKED:` regex in `Invoke-OrchestratorOutputValidation` (line 322) is evaluated only when `HasErrors` is true, i.e. on non-zero exit, where the captured text is the validator's stderr error lines — the tokens `model_routing_receipts` / `complexity_assessments` still appear exactly as before. The `$Invoker` seam signature and the `{HasErrors, ErrorText}` return contract are unchanged, so every existing seam-injecting test continues to compile and run.

**Defense-in-depth assessment for Option A.** The second disjunct nominally defended against a validator that "prints errors but exits 0". Section 1(e) proves that failure mode does not exist in the authoritative CLI, and the portable fallback couples ExitCode to error presence structurally. What the disjunct actually caught in practice was the validator's own success message — a false positive that inverted the gate. The residual theoretical risk (a future validator regression that reports errors with exit 0) is a change to a file owned by a Python test suite that pins return codes; accepting that residual risk is reasonable and is already the accepted posture of `Invoke-OrchestratorStatePreflight`. The loss is acceptable.

### Rejected alternatives (brief)

- **(B) Recognize and discard the success line, keep the two-disjunct decision.** Rejected: couples the hook to an output format that no test pins (Section 1d) — a future wording change silently re-breaks the gate closed; adds string matching where a structural signal (exit code) exists; and diverges from the `Invoke-OrchestratorStatePreflight` precedent.
- **(C) Separate stdout from stderr instead of `2>&1`.** Rejected: PowerShell native-command stream separation inside a scriptblock requires either two capture variables with redirection tricks or `Start-Process` plumbing, materially complicating the injectable seam; the mock stubs return a single `Output` property, so the seam contract would have to change, forcing edits across all existing stub-based tests. The stderr-only text would still be keyed off exit code in practice, so it degenerates to Option A with extra machinery.
- **(D) Move the decision into a shared module.** Out of scope for a bug fix; Option A already converges the hook on the shared module's existing decision shape without moving code.

## 3. Portable Fallback Branch — Verdict: SOUND, no fix required

The `else` branch of the default `$Invoker` (hook lines 196-207) calls `Test-OrchestratorStateCompletionReadiness` from `.claude/lib/orchestrator-state/OrchestratorStateCompletion.psm1`. Trace:

- `Test-OrchestratorStateCompletionReadiness` (OrchestratorStateCompletion.psm1:196-241) returns exactly one of three hashtables:
  - load failure → `@{ ExitCode = 1; Output = $loaded.Error }` (line 227), where `Get-OrchestratorStateCheckpoint` (OrchestratorState.psm1:117-187) always supplies a non-empty `Error` string on failure;
  - any base-presence or gate error → `@{ ExitCode = 1; Output = <newline-joined errors> }` (line 237);
  - success → `@{ ExitCode = 0; Output = '' }` (line 240).
  **ExitCode 0 with non-empty Output is structurally impossible**: the success return is the only ExitCode-0 path and its Output is the literal empty string.
- Success-stream pollution: none of the callees emit to the pipeline outside their return values. `Get-OrchestratorStateBasePresenceError` (OrchestratorState.psm1:223-275) and `Get-OrchestratorStateModelRoutingGateError` (OrchestratorStateCompletion.psm1:149-194) return `$errors.ToArray()`; `List.AddRange` returns void; `HashSet.Add` is `[void]`-suppressed (lines 89, 101, 141). In the invoker's `else` branch, `Import-Module` is called without `-PassThru` (emits nothing) and `Get-Command` is consumed inside the `if` condition (hook line 200), so the `[pscustomobject]` is the scriptblock's only pipeline output.
- Because the success return carries `Output = ''`, the portable branch never false-blocks **even under the current defective disjunct**; the defect is exclusive to the Python-CLI branch. After the Option A fix the portable branch's fail-closed behavior is preserved because every error path sets `ExitCode = 1`.
- `Test-PythonOrchestratorValidatorAvailable` is defined and exported in `.claude/lib/orchestrator-state/OrchestratorState.psm1` (lines 334-360, export at 479-485), which the hook imports at line 41 (`Import-Module ../lib/orchestrator-state/OrchestratorState.psm1 -Force`). Relevant to the fix: it probes `python -c 'import scripts.dev_tools.validate_orchestration_artifacts'` and returns true in this repository (verified by the caller: bare `python` resolves to `.venv/Scripts/python.exe`), so the Python-CLI branch is the live path in drm-copilot and the false block fires on every DONE claim here.

## 4. Mirrors and Parity Locks

- **Codex variant:** none. `.codex/hooks/` contains 25 hooks; `validate-orchestrator-output.ps1` is not among them (full listing verified). `.codex/hooks/enforce-completion-consistency.ps1` contains no `validate_orchestration_artifacts` invocation, no `2>&1` capture, and no `$LASTEXITCODE` disjunct (grep verified) — it does not duplicate this decision logic.
- **Bundled copy:** `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/validate-orchestrator-output.ps1` contains the identical defective line at its own line 224 (grep verified). `extensions/drm-copilot/resources/claude-customizations/.claude/lib/orchestrator-state/OrchestratorStateCompletion.psm1` also exists in the bundle (no change needed — Section 3).
- **Parity lock:** `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py::test_bundled_claude_payload_contains_all_repo_runtime_contracts` (lines 100-125) enumerates every repo `.claude/**` file (excluding `.claude/settings.local.json` and `.claude/agent-memory/**`) and asserts `read_text(BUNDLED_ROOT, p) == read_text(REPO_ROOT, p)` — text-identical parity for `.claude/hooks/**` and `.claude/lib/**`. **The bundled hook copy must therefore be updated in the same commit** or this pytest fails. `test_poshqc_bundled_parity.py` covers only `scripts/powershell/PoshQC` ↔ `extensions/drm-copilot/resources/powershell/PoshQC` (lines 7, 58) and is unaffected. `test_push_down_claude_pack_manifest_completeness.py` requires bundled hooks to appear in a pack manifest — the hook already does; content-only edits do not affect it. `test_push_down_claude_customizations.py`, `test_push_down_claude_pack_end_to_end.py`, and `test_push_down_claude_pack_selection.py` test publisher logic against in-memory filesystems and are unaffected by a content edit.
- **Regeneration workflow:** there is no script that copies repo `.claude/**` into the bundle. `scripts/dev_tools/push_down_claude_customizations.py` publishes *from* a source root *to a consumer repository* (the bundle is its manifest source, `BUNDLE_ROOT_RELATIVE_DIR`, lines 62-69), not the reverse. Repository practice (e.g. feature `planner-hook-em-dash-mismatch-357`) is to sync the bundled mirror by hand (copy the edited file byte-for-byte) and let the pytest parity gate verify. Correct workflow: edit `.claude/hooks/validate-orchestrator-output.ps1`, copy it over the bundled path, run the parity test.
- **Other instances of the disjunct shape:** a repo-wide grep for `($exitCode -ne 0) -or (-not [string]::IsNullOrWhiteSpace(...)` finds exactly two production instances — the live hook (line 224) and its bundled copy (line 224). All other hits are documentation/research artifacts under `docs/` (historical text; out of scope). A broader grep for `HasErrors` confirms every other production decision point (`OrchestratorState.psm1:469`, Codex bundled `enforce-pr-author-skill.ps1:89`) already uses exit-code-only. **In scope for #413:** the two hook copies. **Out of scope:** none remaining.

## 5. Existing Test Coverage

Seam injection pattern: all hook tests dot-source the hook (`. $hookPath` in `BeforeAll`, guarded by the `$MyInvocation.InvocationName -eq '.'` check at hook line 332), mock `Get-CheckpointFileContent` for checkpoint content (no temp files), and pass a stub scriptblock as `-RoutingInvoker` (end-to-end) or `-Invoker` (direct) returning `[pscustomobject]@{ ExitCode = <n>; Output = <s> }`.

- `tests/scripts/claude-hooks/validate-orchestrator-output.Tests.ps1` (449 lines):
  - **Must be revised:** `Context 'Invoke-RoutingContractValidation'` → `It 'reports HasErrors when the seam returns error text with exit 0'` (lines 266-276). This is the one existing test that asserts non-empty output with exit code 0 blocks — the exact behavior the fix removes. Justification for revision: the asserted behavior is the defect; the stub models an input (`ExitCode 0` + text) that the authoritative CLI produces only on success (Section 1e), so the assertion encodes the false block. It should be replaced by the success-line regression test.
  - Unaffected and still-valid: non-zero-exit blocks (255-264), exit-0-empty-output allows (278-288), ROUTING_CONTRACT_BLOCKED end-to-end (180-199), ArtifactType threading (290-321), capability detection (411-448).
- `tests/scripts/claude-hooks/validate-orchestrator-output.model-routing.Tests.ps1` (155 lines): MODEL_ROUTING_BLOCKED surfacing uses `ExitCode = 1` stubs throughout (lines 42-89) — all remain valid under Option A. No revision needed.
- `tests/scripts/claude-hooks/validate-orchestrator-output.human-interaction.Tests.ps1`: exercises `Test-HumanInteractionShape` only; does not touch the Invoker seam. No revision needed.
- `tests/scripts/claude-lib/orchestrator-state/OrchestratorStateCompletion.Tests.ps1`: exercises the portable module via in-module `Test-Path`/`Get-Content` mocks; no change (portable path sound).
- Precedent test to mirror: `tests/scripts/claude-lib/orchestrator-state/OrchestratorState.Tests.ps1:241-245` ('reports no errors when the injected $Invoker returns exit 0') already stubs the literal success line with exit 0 and asserts `HasErrors | Should -BeFalse`.

### New-test placement (exact)

File: `tests/scripts/claude-hooks/validate-orchestrator-output.Tests.ps1`.

1. **ALLOW regression (unit level)** — in `Describe 'validate-orchestrator-output.ps1'` → `Context 'Invoke-RoutingContractValidation'`, replace the lines-266-276 test with:
   `It 'reports no errors when the seam returns exit 0 with the validator success line (issue #413)'` — stub `{ param($Path) [pscustomobject]@{ ExitCode = 0; Output = 'orchestrator-state validation passed: artifacts/orchestration/orchestrator-state.json' } }`; assert `HasErrors | Should -BeFalse`.
2. **ALLOW regression (end-to-end DONE claim)** — in the same Describe → `Context 'routing-contract validation (Gap 1)'`, add:
   `It 'allows DONE when the validator exits 0 and prints its success line (issue #413)'` — reuse the context's `Get-CheckpointFileContent` mock, `-RoutingInvoker` stub with `ExitCode = 0` and the success-line `Output`; assert `$result.Ok | Should -BeTrue` and `$result.Message | Should -BeNullOrEmpty`.
3. **BLOCK regression** — the non-zero-exit block is already locked by lines 255-264 (unit) and 180-199 (end-to-end, `ExitCode = 1` + error text → `^ROUTING_CONTRACT_BLOCKED:`). If an explicit pairing is wanted, extend the Gap-1 context stub set; no existing assertion weakens.

Line budget: the file is 449 lines; the in-place replacement is net-zero and the one added It block (~20 lines) keeps it under the 500-line cap. Test purity: all stubs are in-memory scriptblocks and `Get-CheckpointFileContent` mocks — no temp files, no external processes, satisfying `.claude/rules/general-unit-test.md` (temporary files strictly prohibited) and the PowerShell mocking rules (mock the seam, never `python`).

## 6. Toolchain and Coverage

- **Coverage instrumentation confirmed:** `scripts/powershell/PoshQC/settings/pester.runsettings.psd1` lists `.claude/hooks/validate-orchestrator-output.ps1` (line 48) and both portable modules `.claude/lib/orchestrator-state/OrchestratorState.psm1` / `OrchestratorStateCompletion.psm1` (lines 70-71) under `CodeCoverage.Path`. Coverage gates: line >= 85%, branch >= 75% (uniform, `.claude/rules/quality-tiers.md`); no changed-line regression.
- **Toolchain loop (format → analyze → test; restart on any failure/auto-fix):**
  - MCP forms (pass `workspaceRoot = C:/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-a0fcdf306557436df`):
    - `mcp__drm-copilot__run_poshqc_format`
    - `mcp__drm-copilot__run_poshqc_analyze`
    - `mcp__drm-copilot__run_poshqc_test`
  - Direct repo-root invocations:
    - `pwsh -NoLogo -NoProfile -Command "Import-Module ./scripts/powershell/PoshQC; Invoke-PoshQCFormat -Root ."`
    - `pwsh -NoLogo -NoProfile -Command "Import-Module ./scripts/powershell/PoshQC; Invoke-PoshQCAnalyze -Root ."`
    - `pwsh -NoLogo -NoProfile -Command "Import-Module ./scripts/powershell/PoshQC; Invoke-PoshQCTest -Root ."`
- **Environment fact (verified):** `.mcp.json` registers the server as `npx -y @danmoisan/drm-copilot-mcp` — the MCP tools execute the published npm bundle, whose PoshQC *engine* modules are the npx-cached copies, not the working tree's `scripts/powershell/PoshQC`. For this fix the edited files are a hook and its Pester tests, which the Pester run reads from the workspace, so the MCP test tool does exercise the edits; the caution applies when bundled PoshQC modules themselves are edited. Where any doubt exists, the direct repo-root invocation above is the authoritative execution path.
- Python side (parity pytest): `python -m pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py -q` verifies the bundle resync.

## 7. Automation Feasibility

No step of this fix requires human interaction. The change set is two byte-identical PowerShell file edits, one Pester test-file revision plus one added test, and local toolchain runs (PoshQC format/analyze/test and one pytest parity file). There is no third-party UI, no credential entry, no external service, and no CI-only verification required before merge (the modified file is a hook script, not a workflow). The fix is fully automatable end-to-end; the orchestrator can file the automation assessment with zero unautomatable requirements.

## Definitive Change List

| # | File | Change |
|---|------|--------|
| 1 | `.claude/hooks/validate-orchestrator-output.ps1` | Line 224: `$hasErrors = ($exitCode -ne 0)`; update `.DESCRIPTION` at lines 168-170 to document exit-code-only discrimination. |
| 2 | `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/validate-orchestrator-output.ps1` | Byte-identical resync of file 1, same commit (locked by `test_bundled_claude_payload_contains_all_repo_runtime_contracts`). |
| 3 | `tests/scripts/claude-hooks/validate-orchestrator-output.Tests.ps1` | Revise the lines-266-276 test (exit-0-with-text must no longer block); add the two issue-413 regression tests per Section 5 placement. |

No changes to: `OrchestratorStateCompletion.psm1` (either copy), `OrchestratorState.psm1`, any Python validator, any `.codex/` hook, `pester.runsettings.psd1` (files already instrumented).

## Behavior Semantics After Fix

- Validator exit 0 (success line on stdout) → `HasErrors = $false` → DONE allowed. 
- Validator exit 1 (error lines on stderr, captured via `2>&1` into `ErrorText`) → `HasErrors = $true` → blocked; text matching `model_routing_receipts|complexity_assessments` → `MODEL_ROUTING_BLOCKED:`, otherwise `ROUTING_CONTRACT_BLOCKED:` (hook lines 316-326, unchanged).
- Validator exit 2 (argparse misuse) or crash → non-zero → blocked (fail closed).
- Portable branch: unchanged semantics; ExitCode fully discriminates (Section 3).
