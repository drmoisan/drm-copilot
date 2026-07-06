# Remediation Cycle 1 — R-1 / R-1b / R-2 Closure

Timestamp: 2026-07-06T16-30

## R-1 (Blocking): `.claude/hooks/enforce-pr-author-skill.ps1` exceeds the 500-line hard limit

- **Resolved.** Final line count: 469 lines (was 553 pre-cycle), 31 lines of margin under the 500-line limit. See `evidence/qa-gates/remediation-cycle-1-line-count-verification.md` (P2-T6).
- Achieved by extracting the duplicated `Test-PythonOrchestratorValidatorAvailable` probe (Phase 1) and the `Invoke-OrchestratorStatePreflight` helper (Phase 2) into `.claude/lib/orchestrator-state/OrchestratorState.psm1`, importing it in the hook.
- Sibling files also confirmed under the limit: `.claude/hooks/validate-orchestrator-output.ps1` at 342 lines (P2-T7), `.claude/lib/orchestrator-state/OrchestratorState.psm1` at 477/485 lines (P2-T8; the final count of 485 reflects a subsequent strict-mode fix described below, still 15 lines under the limit).
- Injectable `$Invoker` seam, fail-closed behavior, and the exact block-reason string `ORCHESTRATOR_STATE_PREFLIGHT_FAILED` are unchanged and covered by relocated/retained Pester tests (Phase 3, P3-T5/P3-T7).

## R-1b (Blocking): bundle snapshot not mirrored; push-down still ships the broken/old hooks

- **Resolved.** Phase 0 (P0-T6) confirmed the pre-mirror failing baseline: `poetry run pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py` reported 1 failed, 6 passed (`test_bundled_claude_payload_contains_all_repo_runtime_contracts` failing on `.claude/hooks/enforce-pr-author-skill.ps1`).
- Phase 4 mirrored the final post-fix content of all four in-scope `.claude/**` files (`enforce-pr-author-skill.ps1`, `validate-orchestrator-output.ps1`, `OrchestratorState.psm1`, `OrchestratorStateCompletion.psm1`) byte-for-byte into `extensions/drm-copilot/resources/claude-customizations/.claude/**`, creating the missing `.claude/lib/orchestrator-state/` bundle directory.
- Byte-identity confirmed for all four mirrored pairs via `diff` and MD5 hash comparison (P4-T7, `evidence/other/remediation-cycle-1-bundle-byte-diff.md`).
- The parity test now passes: 7 passed, 0 failed (P4-T9, `evidence/qa-gates/remediation-bundle-parity.md`), reconfirmed at the end of the final QA loop (P5-T5, `evidence/qa-gates/remediation-cycle-1-qa-python-parity.md`).
- The pack manifest `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json` was verified (not edited) to already list both `.claude/lib/orchestrator-state/*.psm1` modules (P4-T8).

## R-2 (Low): duplicated capability probe across both hooks

- **Resolved.** `Test-PythonOrchestratorValidatorAvailable` now exists in exactly one place, `.claude/lib/orchestrator-state/OrchestratorState.psm1`, exported and imported unconditionally by both `.claude/hooks/enforce-pr-author-skill.ps1` and `.claude/hooks/validate-orchestrator-output.ps1` (Phase 1). No test invokes the real `python` executable; every test mocks the probe or the `$Invoker` seam.

## Test and toolchain evidence

- Phase 3 relocated/retained Pester coverage: 114 tests across the six affected test files, 0 failed (P3-T5 through P3-T8).
- Final PowerShell toolchain (Phase 5, full repository): format ok (no reformatted files beyond this cycle's own edits), analyze ok (0 findings), test ok (1063 tests, 0 errors, 0 failures, 9 disabled -- identical to the Phase 0 baseline pass/fail counts).
- Coverage comparison (P5-T4): full-repository INSTRUCTION 92.06% -> 92.59%, LINE 93.24% -> 93.67%; scoped (three touched files) command coverage 92.38% -> 93.47%. No regression on either metric.

## Deviations from the plan discovered and corrected during execution

1. **Strict-mode regression in the relocated `Invoke-OrchestratorStatePreflight`.** `OrchestratorState.psm1` sets `Set-StrictMode -Version Latest` (the hook it was extracted from did not). The original `$result.PSObject.Properties.Name -contains 'ExitCode'` pattern throws under strict mode when `$result` has zero properties (a documented PowerShell strict-mode member-enumeration gotcha), which broke the "defaults ExitCode/Output when the injected $Invoker result carries neither property" test the moment the code moved into the module. Fixed by count-gating the property-name lookup before accessing `.Name` (see `.claude/lib/orchestrator-state/OrchestratorState.psm1`, `Invoke-OrchestratorStatePreflight`). Contract (`{ HasErrors, ErrorText }`) is unchanged; only the internal null/empty-safety changed.
2. **P3-T8's assumption did not hold as written.** The plan asserted the existing `Test-PythonOrchestratorValidatorAvailable` mocks in `validate-orchestrator-output.Tests.ps1` (line 527) and `validate-orchestrator-output.model-routing.Tests.ps1` (lines 116/132) would "continue to work unqualified... without modification" after the probe moved into the module. In practice, `OrchestratorStateCompletion.psm1`'s own internal `Import-Module ... OrchestratorState.psm1 -Force` (a pre-existing, nested import inside that .psm1 file, unrelated to this cycle's changes) removes this test scope's global visibility of the sibling probe once the completion module is (re)imported in the `capability detection` Context's own `BeforeAll`. This was invisible before this cycle because the probe did not yet live in `OrchestratorState.psm1`. Fixed with a minimal, targeted addition: an explicit `Import-Module .../OrchestratorState.psm1 -Force` immediately after the existing completion-module import in both affected `BeforeAll` blocks, restoring visibility so the pre-existing unqualified `Mock` calls resolve correctly; no `-ModuleName` qualifier was needed or used, preserving the plan's literal assertion about the mock style. All 38 tests in both files pass.
3. **Pre-existing, out-of-scope 500-line violation observed (not fixed).** `tests/scripts/claude-hooks/validate-orchestrator-output.Tests.ps1` was already 545 lines at the start of this cycle (confirmed via `git show HEAD:...`), before any edit in this remediation. This predates R-1/R-1b/R-2 and is not named by any finding in `remediation-inputs.2026-07-06T10-56.md`; splitting or trimming this file is an independent outcome outside this plan's scope and was not performed. The minimal fix described in item 2 added 7 lines to this already-over-limit file (545 -> 552); the comment was kept as short as practicable given the fix's own explanatory requirement. This should be flagged for a future, separate remediation cycle.
