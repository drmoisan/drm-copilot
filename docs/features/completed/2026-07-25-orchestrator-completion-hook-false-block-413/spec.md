# Orchestrator Completion Hook False-Block on Successful Validation (Spec)

- **Issue:** #413
- **Parent (optional):** none
- **Owner:** drmoisan
- **Last Updated:** 2026-07-25T17-36
- **Status:** Implemented — awaiting feature review. All 35 plan tasks in `plan.2026-07-25T15-37.md` are complete; 12 of 13 acceptance criteria are checked off (AC11 is blocked only by the toolchain's absent branch-coverage metric — see Outcome below).
- **Version:** 1.0
- **Work Mode:** full-bug (this spec is the sole acceptance-criteria source; no user-story.md exists for this feature)

## Summary

The orchestrator completion hook `.claude/hooks/validate-orchestrator-output.ps1` blocks a DONE claim even when the authoritative Python validator reports success. The hook is broken closed: whenever the Python validator CLI is importable (the live path in this repository), no checkpoint can satisfy the documented DONE gate, because the hook treats the validator's stdout success line as error text. The fix changes the error decision in `Invoke-RoutingContractValidation` to key solely on the subprocess exit code, which the research artifact for this issue established as a complete failure discriminator for both invoker branches. The bundled pushed-down copy of the hook is resynced byte-identically in the same change.

Research basis: `docs/features/active/2026-07-25-orchestrator-completion-hook-false-block-413/research/2026-07-25T10-15-orchestrator-completion-hook-false-block-413-research.md`. The conclusions of that artifact are established inputs to this spec.

## Problem Statement

### Environment

- OS/version: Windows 11 Pro 10.0.26200
- Python: repository `.venv` interpreter resolved by bare `python` (`Test-PythonOrchestratorValidatorAvailable` returns true, so the Python-CLI branch is the live path)
- Command: `pwsh -File .claude/hooks/validate-orchestrator-output.ps1` with a DONE-claiming `CLAUDE_HOOK_INPUT` payload
- Fixture: a fully valid, completion-passing `artifacts/orchestration/orchestrator-state.json`

### Steps to reproduce

1. Produce an `artifacts/orchestration/orchestrator-state.json` that passes `python -m scripts.dev_tools.validate_orchestration_artifacts orchestrator-state <path> --require-complete --require-model-routing` with exit code 0.
2. Set `CLAUDE_HOOK_INPUT` to a well-formed hook payload whose `output` field is a non-empty DONE completion summary.
3. Run `pwsh -File .claude/hooks/validate-orchestrator-output.ps1`.

### Expected behavior

The hook exits 0 and allows termination, because the authoritative validator reported success.

### Observed failure

The hook exits 1 and blocks, quoting the validator's own success message as the block reason:

```text
ROUTING_CONTRACT_BLOCKED: orchestrator-state validation passed: artifacts/orchestration/orchestrator-state.json
```

### Impact / severity

Blocker. The documented completion gate for every orchestration run is unusable as completion evidence. The gate cannot produce a false allow, so the failure direction is safe, but it is unconditionally false-blocking on the live validator path.

## Root Cause

In `Invoke-RoutingContractValidation` (`.claude/hooks/validate-orchestrator-output.ps1`, line 224) the error decision is:

```powershell
$hasErrors = ($exitCode -ne 0) -or (-not [string]::IsNullOrWhiteSpace($outputText))
```

The default `$Invoker` runs the validator CLI with `2>&1` (line 191), which folds stdout into the captured `Output`. On a clean pass, `scripts/dev_tools/validate_orchestration_artifacts.py` `main()` exits 0 but prints `orchestrator-state validation passed: <path>` to stdout. The second disjunct therefore fires on every clean pass, `HasErrors` becomes `$true`, and `Invoke-OrchestratorOutputValidation` blocks with the success line quoted as the error.

The validator CLI contract (research Section 1) makes the second disjunct unnecessary: `main()` prints every error to stderr and returns 1, and prints the success line to stdout and returns 0. There is no path that exits 0 while printing error text, and no failure path that exits 0. The exit code is a complete and sufficient failure discriminator.

## Non-Goals / Out of Scope

The following are explicitly excluded from this change:

- Any change to `scripts/dev_tools/validate_orchestrator_state.py` or `scripts/dev_tools/validate_orchestration_artifacts.py`. The Python validator implements a clean CLI contract relied on by other consumers; the defect is in the PowerShell hook.
- Any change to any complexity-floor implementation (owned by a parallel orchestration).
- The `step9_status: "passed"` documentation/validator divergence (separate concern; not addressed here).
- The repo-wide `npm audit` GHSA-mh99-v99m-4gvg advisory (unrelated to this defect).
- Any change to `.claude/lib/orchestrator-state/OrchestratorStateCompletion.psm1` or `OrchestratorState.psm1` (either the repo copy or the bundled copy). The portable fallback branch was investigated and cleared; see Design.
- Any Codex mirror work: no `validate-orchestrator-output.ps1` exists under `.codex/hooks/` (verified in research Section 4), so there is no Codex copy to update.
- Alternative fix designs rejected in research Section 2 (success-line string matching; stdout/stderr stream separation; extracting the decision into a shared module).

## Design

### Approved fix (Option A)

In `Invoke-RoutingContractValidation`, the error decision becomes:

```powershell
$hasErrors = ($exitCode -ne 0)
```

with `ErrorText = $outputText` retained unchanged. The function's `.DESCRIPTION` docstring (currently lines 167-170), which documents the two-disjunct behavior ("reported a non-zero exit or produced any error text"), is corrected to document exit-code-only discrimination. The inline comment above the decision (lines 222-223) is corrected to match.

### Justification (recorded per research Section 2)

1. **Exit code is a complete failure discriminator for both invoker branches.** `scripts/dev_tools/validate_orchestration_artifacts.py` `main()` prints every error to stderr and returns 1, and prints the success line to stdout and returns 0. It never prints error text with exit 0, and every abnormal path (validation failure, argparse misuse with exit 2, unhandled exception) is non-zero. No defense-in-depth is lost: the only behavior the removed disjunct caught in practice was the validator's own success message — a false positive that inverted the gate.
2. **Established repository precedent.** `Invoke-OrchestratorStatePreflight` in `.claude/lib/orchestrator-state/OrchestratorState.psm1` already uses exactly `HasErrors = ($exitCode -ne 0)`, with a test that locks in that an exit-0 result carrying the literal success line does not block. The bundled Codex `enforce-pr-author-skill.ps1` (`extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-pr-author-skill.ps1`) uses the same shape.
3. **Every downstream contract is preserved** (see seam contract and block-reason discrimination below).

### Retained seam contract

The `$Invoker` scriptblock seam signature (`param($Path, $Type)` returning an object with `ExitCode` and `Output` properties) and the function's `{ HasErrors, ErrorText }` return contract are unchanged. Every existing seam-injecting test continues to compile and run. `ErrorText` continues to carry the captured combined output (`2>&1` capture is unchanged), so on a genuine failure it contains the validator's stderr error lines exactly as before.

### Block-reason discrimination unchanged

The `MODEL_ROUTING_BLOCKED:` versus `ROUTING_CONTRACT_BLOCKED:` discrimination in `Invoke-OrchestratorOutputValidation` (the `model_routing_receipts|complexity_assessments` regex, hook lines 316-326) must keep working unchanged. It is evaluated only when `HasErrors` is true — after the fix, only on non-zero exit, where the captured text is the validator's stderr error lines and the discriminating tokens appear exactly as before.

### Portable fallback branch — investigated and cleared, no change required

The `else` branch of the default `$Invoker` calls `Test-OrchestratorStateCompletionReadiness` in `.claude/lib/orchestrator-state/OrchestratorStateCompletion.psm1`. That function returns literally `@{ ExitCode = 0; Output = '' }` on success and sets `ExitCode = 1` on every error path (load failure, base-presence error, gate error). ExitCode 0 with non-empty Output is structurally impossible, so the portable branch cannot present success text as error text and never false-blocked even under the defective disjunct. After the fix, its fail-closed behavior is preserved because every error path sets `ExitCode = 1`. This branch is verified unchanged as part of acceptance, not merely omitted from scope.

### Bundled copy resync

`extensions/drm-copilot/resources/claude-customizations/.claude/hooks/validate-orchestrator-output.ps1` contains the identical defective line and must be resynced byte-identically in the same change. Byte parity is locked by `test_bundled_claude_payload_contains_all_repo_runtime_contracts` in `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py`. No regeneration script exists; both copies are edited by hand (edit the `.claude/` source, copy it byte-for-byte over the bundled path, run the parity pytest).

### Behavior semantics after fix

- Validator exit 0 (success line on stdout) → `HasErrors = $false` → DONE allowed.
- Validator exit 1 (error lines on stderr, captured into `ErrorText`) → `HasErrors = $true` → blocked; text matching `model_routing_receipts|complexity_assessments` → `MODEL_ROUTING_BLOCKED:`, otherwise `ROUTING_CONTRACT_BLOCKED:`.
- Validator exit 2 (argparse misuse) or crash → non-zero → blocked (fail closed).
- Portable branch: unchanged semantics; `ExitCode` fully discriminates.

## Files In Scope

| # | File | Change |
|---|------|--------|
| 1 | `.claude/hooks/validate-orchestrator-output.ps1` | Line 224: `$hasErrors = ($exitCode -ne 0)`; correct the `.DESCRIPTION` docstring and the inline decision comment to document exit-code-only discrimination. |
| 2 | `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/validate-orchestrator-output.ps1` | Byte-identical resync of file 1, same change (locked by `test_bundled_claude_payload_contains_all_repo_runtime_contracts`). |
| 3 | `tests/scripts/claude-hooks/validate-orchestrator-output.Tests.ps1` | Revise the defect-asserting test at approximately lines 266-276; add the issue-413 regression tests per the Test Strategy below. |

No changes to: `OrchestratorStateCompletion.psm1` (either copy), `OrchestratorState.psm1`, any Python validator, any `.codex/` hook, or `scripts/powershell/PoshQC/settings/pester.runsettings.psd1` (the hook and both portable modules are already listed under `CodeCoverage.Path`).

## Test Strategy

### Test file placement and the 500-line cap

`tests/scripts/claude-hooks/validate-orchestrator-output.Tests.ps1` is currently 449 lines against the hard 500-line file cap. All test changes fit in this existing file: the defect-asserting test at lines 266-276 is replaced in place (net-zero), and the one added end-to-end It block (~20 lines) keeps the file under the cap. No sibling test file is needed. If implementation drift pushes the file past 500 lines, split the new issue-413 regressions into a sibling file under the same `tests/scripts/claude-hooks/` directory rather than exceeding the cap.

### Test changes

All stubs are in-memory scriptblocks injected via the `-Invoker` / `-RoutingInvoker` seams, with `Get-CheckpointFileContent` mocked for checkpoint content. No temporary files and no external processes, per `.claude/rules/general-unit-test.md`.

1. **Revise the defect-asserting test.** `Context 'Invoke-RoutingContractValidation'` → `It 'reports HasErrors when the seam returns error text with exit 0'` (lines 266-276) asserts the defect (exit 0 plus text must block) and models an input the authoritative CLI produces only on success. Replace it with `It 'reports no errors when the seam returns exit 0 with the validator success line (issue #413)'` — stub `ExitCode = 0` with `Output = 'orchestrator-state validation passed: artifacts/orchestration/orchestrator-state.json'`; assert `HasErrors | Should -BeFalse`. This mirrors the precedent test for `Invoke-OrchestratorStatePreflight` in `tests/scripts/claude-lib/orchestrator-state/OrchestratorState.Tests.ps1`.
2. **ALLOW regression (end-to-end DONE claim).** In `Context 'routing-contract validation (Gap 1)'`, add `It 'allows DONE when the validator exits 0 and prints its success line (issue #413)'` — reuse the context's `Get-CheckpointFileContent` mock and a `-RoutingInvoker` stub with `ExitCode = 0` and the success-line `Output`; assert `$result.Ok | Should -BeTrue` and `$result.Message | Should -BeNullOrEmpty`.
3. **BLOCK regression (fail-closed).** The non-zero-exit block path is already locked by the existing unit test (lines 255-264) and the end-to-end `ROUTING_CONTRACT_BLOCKED` test (lines 180-199, `ExitCode = 1` plus error text). These must continue to pass unmodified; no existing blocking assertion is weakened.
4. **Block-reason discrimination.** `tests/scripts/claude-hooks/validate-orchestrator-output.model-routing.Tests.ps1` (`MODEL_ROUTING_BLOCKED` surfacing with `ExitCode = 1` stubs) must continue to pass unmodified.
5. **Portable fallback verification.** `tests/scripts/claude-lib/orchestrator-state/OrchestratorStateCompletion.Tests.ps1` must continue to pass unmodified, confirming the fallback's `ExitCode`-coupled fail-closed behavior is unchanged.

### Toolchain and verification commands

- PowerShell toolchain loop, repeated until all stages pass in a single pass (restart on any failure or auto-fix): PoshQC format → PSScriptAnalyzer analyze → Pester test. Repo-root invocations: `Invoke-PoshQCFormat -Root .`, `Invoke-PoshQCAnalyze -Root .`, `Invoke-PoshQCTest -Root .` (import `./scripts/powershell/PoshQC`). MCP equivalents (`run_poshqc_format` / `run_poshqc_analyze` / `run_poshqc_test`) are acceptable for this change because the edited files are a hook and its Pester tests, which the Pester run reads from the workspace; the direct repo-root invocation is the authoritative path where any doubt exists.
- Coverage gates: line >= 85%, branch >= 75%, no regression on changed lines. The hook and both portable modules are already instrumented in `pester.runsettings.psd1`.
- Bundle parity: `python -m pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py -q`.
- End-to-end integration (primary acceptance evidence): run the hook itself after the fix — `pwsh -File .claude/hooks/validate-orchestrator-output.ps1` with a DONE-claiming `CLAUDE_HOOK_INPUT` against a real completion-passing `artifacts/orchestration/orchestrator-state.json` — and confirm exit code 0.

## Assumptions, Constraints, Dependencies

- Assumptions: bare `python` resolves to the repository `.venv` interpreter and `scripts.dev_tools` is importable, so the Python-CLI branch is the live invoker path (verified in research Section 3).
- Constraints: no production file may exceed 500 lines; no temporary files in tests; the gate must not be weakened — a genuine validator failure must still block.
- Dependencies: none external. The change is self-contained in the hook, its bundled mirror, and its Pester tests.

## Risks & Mitigations

- **Risk:** a future regression in the Python validator that prints errors while exiting 0 would no longer be caught by the hook. **Assessment:** this failure mode does not exist in the current CLI (no code path exits 0 with error output), the Python test suite pins return codes, and exit-code-only discrimination is already the accepted posture of `Invoke-OrchestratorStatePreflight`. The residual risk is accepted (research Section 2).
- **Risk:** the bundled copy drifts from the `.claude/` source. **Mitigation:** `test_bundled_claude_payload_contains_all_repo_runtime_contracts` fails on any byte difference; both edits land in the same change.
- **Rollback:** revert the two hook-file edits and the test revision; no data, config, or schema impact.

## Acceptance Criteria

- [x] The hook ALLOWS a DONE claim when the validator exits 0 and prints its success line: a regression test exists at the `Invoke-RoutingContractValidation` unit level in `tests/scripts/claude-hooks/validate-orchestrator-output.Tests.ps1` stubbing `ExitCode = 0` with `Output = 'orchestrator-state validation passed: artifacts/orchestration/orchestrator-state.json'` and asserting `HasErrors` is `$false`, and it passes.
- [x] The hook ALLOWS a DONE claim end-to-end: a regression test exists in `tests/scripts/claude-hooks/validate-orchestrator-output.Tests.ps1` exercising `Invoke-OrchestratorOutputValidation` with a `-RoutingInvoker` stub returning `ExitCode = 0` and the success-line output, asserting `Ok` is `$true` and `Message` is null or empty, and it passes.
- [x] The hook still BLOCKS when the validator exits non-zero: the existing non-zero-exit regression tests (unit test at approximately lines 255-264 and end-to-end `ROUTING_CONTRACT_BLOCKED` test at approximately lines 180-199 of `tests/scripts/claude-hooks/validate-orchestrator-output.Tests.ps1`) pass unmodified.
- [x] The gate still fails closed with no weakening: no existing test assertion that a genuine validator failure (non-zero exit) blocks DONE is removed or relaxed, and the fixed decision blocks on every non-zero exit code including exit 2 and crash paths.
- [x] The `MODEL_ROUTING_BLOCKED:` block reason still fires for model-routing/complexity errors and `ROUTING_CONTRACT_BLOCKED:` for other failures: `tests/scripts/claude-hooks/validate-orchestrator-output.model-routing.Tests.ps1` passes unmodified, and the `model_routing_receipts|complexity_assessments` discrimination logic in `Invoke-OrchestratorOutputValidation` is unchanged in the diff.
- [x] The existing test `'reports HasErrors when the seam returns error text with exit 0'` (approximately lines 266-276 of `tests/scripts/claude-hooks/validate-orchestrator-output.Tests.ps1`) is revised, because it asserts the defect; the exit-0-with-text-blocks assertion no longer exists in the suite.
- [x] The `{ HasErrors, ErrorText }` return contract and the `$Invoker` seam signature of `Invoke-RoutingContractValidation` are unchanged, `ErrorText` still carries the captured output, and the `.DESCRIPTION` docstring is corrected to document exit-code-only discrimination.
- [x] The bundled pushed-down copy `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/validate-orchestrator-output.ps1` is byte-identical to `.claude/hooks/validate-orchestrator-output.ps1`, and `python -m pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py -q` passes.
- [x] The portable fallback path is verified unchanged and still fails closed: no diff touches `OrchestratorStateCompletion.psm1` (either copy), and `tests/scripts/claude-lib/orchestrator-state/OrchestratorStateCompletion.Tests.ps1` passes unmodified.
- [x] `tests/scripts/claude-hooks/validate-orchestrator-output.Tests.ps1` remains at or under the 500-line cap; if a sibling test file was required, it lives under `tests/scripts/claude-hooks/` per the test-location rule.
- [x] The PowerShell toolchain loop passes cleanly in a single pass: PoshQC format, PSScriptAnalyzer analyze, and Pester test all succeed, with line coverage >= 85% and branch coverage >= 75% and no coverage regression on changed lines.
- [x] Primary acceptance evidence: the hook itself is exercised end-to-end after the fix — `pwsh -File .claude/hooks/validate-orchestrator-output.ps1` with a DONE-claiming `CLAUDE_HOOK_INPUT` against a real completion-passing `artifacts/orchestration/orchestrator-state.json` — and exits 0.
- [x] No unintended changes outside the defined scope: the diff touches only the three files in the Files In Scope table, and no Python validator, complexity-floor, or `.codex/` file is modified.

## Outcome (recorded at implementation handoff, 2026-07-25T17-36)

Implementation is complete and matches the approved design with **no deviations from scope**.
The three files in the Files In Scope table are the only code/test files changed; the
diff-scope audit found no out-of-scope path.

Result: `Invoke-RoutingContractValidation` now decides on the exit code alone
(`$hasErrors = ($exitCode -ne 0)`), with `ErrorText = $outputText` retained, the
`.DESCRIPTION` docstring and the inline decision comment corrected, and the bundled copy
resynced byte-identically (both hash to
`5E4BFA47C748C4E2E44262141E1F543B1ADE1A19ED43005855735AB422D3183B`).

Verification headline:

- Fail-before: 25 passed / **2 failed** — exactly the two issue-413 ALLOW tests.
- Pass-after: **27 passed / 0 failed**.
- Full PowerShell suite: **1,347 passed / 0 failed / 9 skipped**; PoshQC format clean (no files
  changed), PSScriptAnalyzer 0 findings; overall line/instruction coverage **89.68%** (>= 85%).
- End-to-end: the fixed hook exits **0** against a completion-passing checkpoint and still
  exits **1** with `ROUTING_CONTRACT_BLOCKED:` against a genuinely failing one.

Two recorded conditions for the reviewer:

1. **AC11 left unchecked.** Every clause is verified except branch coverage >= 75%, which this
   repository's Pester CoverageGutters/JaCoCo output cannot measure (INSTRUCTION/LINE/METHOD/CLASS
   counters only; no BRANCH counter). Pre-existing tooling limitation with precedent at
   `docs/features/completed/2026-07-02-local-preflight-orchestrator-state-gate-272/evidence/baseline/poshqc-test-baseline.md`;
   not caused by this change. Accepting the clause as not-measurable is a reviewer decision.
2. **Primary acceptance evidence used a fixture checkpoint**, as the approved plan's [P5-T2]
   fixture branch directs. The live `artifacts/orchestration/orchestrator-state.json` is owned by
   the enclosing orchestration, is mid-run, and fails the DONE gate for unrelated reasons; it was
   read only and never written.

Key artifacts (all paths relative to this feature folder; all verified to exist):

| Purpose | Artifact |
|---|---|
| Fail-before | `evidence/regression-testing/fail-before.2026-07-25T17-14.md` |
| Pass-after | `evidence/regression-testing/pass-after.2026-07-25T17-17.md` |
| Primary acceptance (hook exit 0) | `evidence/qa-gates/hook-e2e-allow.2026-07-25T17-19.md` |
| Live-checkpoint verification (skip branch + fail-closed proof) | `evidence/qa-gates/hook-e2e-live-checkpoint.2026-07-25T17-36.md` |
| Block-reason discrimination | `evidence/regression-testing/model-routing-discrimination.2026-07-25T17-17.md` |
| Portable fallback unchanged | `evidence/regression-testing/portable-fallback-tests.2026-07-25T17-17.md` |
| Bundle byte parity | `evidence/qa-gates/bundle-byte-parity.2026-07-25T17-16.md` |
| Final QA (format / analyze / test / parity) | `evidence/qa-gates/final-poshqc-format.2026-07-25T17-24.md`, `evidence/qa-gates/final-poshqc-analyze.2026-07-25T17-24.md`, `evidence/qa-gates/final-poshqc-test.2026-07-25T17-24.md`, `evidence/qa-gates/final-parity-pytest.2026-07-25T17-24.md` |
| Coverage delta and verdicts | `evidence/qa-gates/coverage-delta.2026-07-25T17-24.md` |
| Diff-scope audit | `evidence/qa-gates/diff-scope-audit.2026-07-25T17-36.md` |
| AC status summary | `evidence/qa-gates/ac-status-summary.2026-07-25T17-36.md` |

## Rollout & Follow-up

- Release/rollout steps: merge via the standard feature-review and PR flow; the bundled copy ships with the next extension release.
- Post-fix monitoring: none required; the Pester regressions and the bundle parity pytest are the ongoing guards.
- Links: issue #413 (https://github.com/drmoisan/drm-copilot/issues/413); research artifact `docs/features/active/2026-07-25-orchestrator-completion-hook-false-block-413/research/2026-07-25T10-15-orchestrator-completion-hook-false-block-413-research.md`.
