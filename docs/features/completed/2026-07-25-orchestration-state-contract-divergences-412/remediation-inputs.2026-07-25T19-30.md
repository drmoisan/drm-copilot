# Remediation Inputs — Issue #412, Cycle 1

- **Timestamp:** 2026-07-25T19-30
- **Issue:** #412
- **Feature folder:** `docs/features/active/2026-07-25-orchestration-state-contract-divergences-412`
- **Branch:** `bug/orchestration-state-contract-divergences-412`
- **Source:** `code-review.2026-07-25T19-14.md` finding CR-1, elevated by the orchestrator
- **Cycle entry reason:** a fail-open path introduced by this branch

## Orchestrator elevation note

`feature-review` recorded zero Blocking findings and returned a Go verdict. Finding CR-1 was classified **Major** on the reasoning that the authoritative Python gate is closed and no spec acceptance criterion covers the PowerShell readiness gate.

The orchestrator elevates CR-1 to **Blocking** for this cycle. The rationale is causation, not severity reclassification: the gap did not exist before this branch. `blocked_remediation_loop_limit` was previously an unwritable value, so the PowerShell readiness gate could never encounter it. This branch made the value plain-valid on `step6_status` without extending the PowerShell gate that mirrors the Python readiness check, so the branch itself opens the fail-open path. Shipping a self-introduced fail-open gate is not acceptable, and the fix is contained within divergence 1's own surface.

## Finding

### F-1 (Blocking) — PowerShell PR-creation readiness gate fails open on `blocked_remediation_loop_limit`

- **Severity: Blocking**
- **File:** `.claude/lib/orchestrator-state/OrchestratorState.psm1`, `Get-OrchestratorStatePrCreationReadinessError`, line 319.
- **Byte mirror also affected:** `extensions/drm-copilot/resources/claude-customizations/.claude/lib/orchestrator-state/OrchestratorState.psm1`.

**Observed:** the readiness loop blocks only two values:

```powershell
if ($field.Present -and ($field.Value -eq 'pending' -or $field.Value -eq 'blocked')) {
```

**Expected:** parity with the Python reference this function documents itself against. `scripts/dev_tools/_orchestrator_state_pr_creation_readiness.py` now blocks `blocked_remediation_loop_limit` in addition to `pending` and `blocked`, because `step6_status` is inside `PR_CREATION_READY_STEP_KEYS` and the value became plain-valid in this branch.

**Impact:** `Test-OrchestratorStatePrCreationReadiness` is the public entry point used by the pushed-down `enforce-pr-author-skill` hook when the authoritative Python validator is not importable. In a consumer repository that receives only the `.claude` tree, a checkpoint recording a halted remediation loop (`step6_status: "blocked_remediation_loop_limit"`) passes the readiness gate and permits PR creation. The Python path correctly refuses. The two paths therefore disagree exactly on the state this branch made representable.

**Function docstring that the code now contradicts** (lines 294-300): "Private readiness check mirroring `validate_orchestrator_state_pr_creation_readiness` in `_orchestrator_state_pr_creation_readiness.py`: steps 5-8 must not be pending/blocked".

## Required remediation

1. Extend the readiness-blocking set in `Get-OrchestratorStatePrCreationReadinessError` so it also blocks `blocked_remediation_loop_limit`, producing the existing message form `Checkpoint PR-creation readiness validation failed: <key> is <value>.` byte-identically to the Python gate's corresponding string.
2. Update the function's `.DESCRIPTION` so it accurately states the blocked set rather than "pending/blocked".
3. Apply the identical change to the byte mirror in the same batch, as `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py` enforces content identity.
4. Add Pester coverage in `tests/scripts/claude-lib/orchestrator-state/OrchestratorState.Tests.ps1` asserting that `step6_status: "blocked_remediation_loop_limit"` is rejected by the readiness gate while remaining accepted by plain base validation, and that `pending` and `blocked` still block.

## Constraints carried forward

- File budget: 2 production PowerShell files (the module and its byte mirror) plus 1 test file. Within the direct-mode cap.
- `.claude/lib/orchestrator-state/OrchestratorState.psm1` is at 498 lines against the 500-line hard limit. The edit must not exceed 500. If it would, extract a helper and report before proceeding; do not raise the limit.
- Message strings must stay byte-identical to the Python reference.
- The shared `$script:VALID_STEP_STATUS` array and the per-key `$script:STEP_SPECIFIC_EXTRA_STATUS` map must not change. `blocked_remediation_loop_limit` must remain plain-valid on `step6_status`; only the readiness gate changes.
- Do not modify: `config/orchestration-routing.json` or its bundled mirror, `.claude/skills/orchestrate/SKILL.md`, `.claude/rules/orchestrator-state.md`, `.claude/hooks/validate-orchestrator-output.ps1`, `.claude/hooks/enforce-epic-merge-gate.ps1`, `.claude/settings.json`, either batch-budget hook, `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py`, `extensions/drm-copilot/jest.config.cjs`, or any Python or TypeScript file.

## Non-blocking items carried into the cycle for disposition

- **CR-2 (Minor):** `OrchestratorState.psm1` at 498/500 lines. The F-1 fix consumes part of the remaining budget. If the edit cannot fit, a helper extraction is the sanctioned response.
- **Info:** case-insensitive `-contains` in the portable module is a pre-existing convention and is out of scope.
- **Info:** the `Jest`-versus-`Vitest` inconsistency in `.claude/rules/typescript.md` is pre-existing and repo-wide. Rule files must not be modified; record as a follow-up only.
- **Info:** the dot-directory Jest `testMatch` limitation is environmental and already recorded in evidence with both invocations.
