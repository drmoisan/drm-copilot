# Fail-Before Exception Dossier — Gap 1 (Issue #253, P3-T1)

- Timestamp: 2026-06-26T15-50
- Scope: `.claude/hooks/validate-orchestrator-output.ps1` SubagentStop routing-contract gap.

## WhyFailingRunImpossible

A deterministic failing Pester run cannot be produced before the Gap-1 change is applied. The fail-before assertion would have to invoke the routing-validator seam (`Invoke-RoutingContractValidation`) inside `Invoke-OrchestratorOutputValidation`, but that function and its call site do not yet exist. A test referencing the unwritten seam cannot execute, and a test that only exercises the current hook cannot fail, because the current hook has no routing-contract code path to assert against. The absence of enforcement is therefore proved by code inspection rather than by a red test.

## Absence-of-Enforcement Proof

`Invoke-OrchestratorOutputValidation` in `.claude/hooks/validate-orchestrator-output.ps1` performs, in order: payload parse, agent-output presence, checkpoint file presence, checkpoint JSON parse, required-field presence (`objective`, `completed_steps`, `next_step`, `last_updated`), non-empty `objective`, and the optional `human_interaction` shape check. Its final statement is the unconditional allow:

- Line 215-218: `human_interaction` shape check (`Test-HumanInteractionShape`).
- Line 220: `return @{ Ok = $true; Message = $null }` — the unconditional allow, reached for any structurally valid checkpoint regardless of route validity.

There is no call to any routing-contract validator (no `python -m scripts.dev_tools.validate_orchestration_artifacts orchestrator-state ... --require-complete` invocation and no `Invoke-RoutingContractValidation` function) anywhere between the `human_interaction` check (line 218) and the final allow (line 220). Consequently a structurally valid checkpoint that selects a fabricated route (for example `path_selected: "direct_powershell_engineer_remediation"`) is allowed by the hook before the Gap-1 change.

SearchScope: `.claude/hooks/validate-orchestrator-output.ps1` (full file, lines 1-235).
SearchPatterns: `Invoke-RoutingContractValidation`, `ROUTING_CONTRACT_BLOCKED`, `validate_orchestration_artifacts`, `orchestrator-state`.
SearchResult: none — no routing-contract call present in the pre-change hook.

## Pass-After

P3-T2 adds `Invoke-RoutingContractValidation` with an injectable subprocess seam and inserts the call after the `human_interaction` check and before the final allow, returning `ROUTING_CONTRACT_BLOCKED: <error list>` on validator errors. The P3-T2 Pester contexts assert the fabricated-route checkpoint is blocked (pass-after), satisfying this fail-before requirement under the exception-dossier provision.
