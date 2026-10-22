# P9-T5 Native planning gate contract

Timestamp: 2026-10-22T16-56
Task: [P9-T5] Gate implementation planning on current configured discovery authority.
Result: PASS

## Surfaces delivered

- `.claude/lib/discovery-validation/DiscoveryPlanning.psm1` (new, shared): `Get-DiscoveryPlanningTarget` (an Agent, Task, spawn_agent or other spawn-family launch whose `subagent_type`, `agent_type` or `agent` names atomic-planner or orchestrator, with the `-c1`..`-c4`/`-c3-elevated` variants), `Get-DiscoveryPlanningPrerequisite` (the profile's `planning_prerequisite` scalar in YAML or JSON, default discovery-complete), `Get-DiscoveryPlanningReceiptMismatch`, `Get-DiscoveryPlanningDecision` and `ConvertTo-DiscoveryPlanningHookOutput`. `DiscoveryAuthority.psd1` nests and exports it.
- `.claude/hooks/enforce-discovery-planning-gate.ps1` (new): the Claude Code PreToolUse adapter with the shared dependency guard, guarded `Join-Path $PSScriptRoot` imports and `Invoke-DiscoveryPlanningGateDecision -ToolInputRaw`; prefix `DISCOVERY_PLANNING_GATE_BLOCKED:`.
- `.codex/hooks/enforce-discovery-planning-gate.ps1` (new): the Codex PreToolUse adapter with published-or-self-hosted module resolution; allow is silent, deny writes the PreToolUse decision at exit 0, an unreadable envelope writes to stderr at exit 2.
- `.github/hooks/discovery-planning.ps1` (new): the Copilot local-harness adapter over camelCase envelopes with its own fail-closed dependency list.

## Decision contract (proven in `LPTEST/DiscoveryPlanning.Tests.ps1`, `CPTEST/discovery-planning-gate.Tests.ps1`, `XPTEST/discovery-planning-gate.Tests.ps1`, `tests/scripts/copilot-hooks/discovery-planning.Tests.ps1`)

- Planning entry: only a planner or orchestrator launch is gated; a Read, Write, shell or executor delegation is allowed without a store read (NOT_PLANNING).
- Inactive repositories follow existing behavior: a workspace with no protected activation or with a deliberate deactivation allows (NOT_ACTIVE); an unreadable activation record denies (ACTIVATION).
- Active workspace configuration: the locator `config/discovery.json` and the activated domain profile must still exist with the activated bytes (`locator_sha256`, `profile_sha256` of the activation record) and decode as UTF-8; a deleted file denies (LOCATOR_MISSING, PROFILE_MISSING), a disabled or edited file denies (LOCATOR_CHANGED, PROFILE_CHANGED), a locator that is not an enabled object naming the activated profile or a profile without `schema_version` or with invalid bytes denies (LOCATOR_MALFORMED, PROFILE_MALFORMED).
- Settings: the prerequisite is read from the profile (`none`, `discovery-complete`, `parity-complete`, default discovery-complete) and governs what the planning receipt must have validated: `none` requires the passing planning receipt only, `discovery-complete` additionally at least one source repository in the receipt's input manifest and `parity-complete` additionally at least one target repository (PREREQUISITE otherwise).
- Receipts: the session's protected `receipts/` are examined newest first; the authorizing receipt is a receipt-version 2.0.0 `validation-receipt` of mode `planning` issued to the native-root principal of this host and session, written by the host gateway, bound to the current activation and workspace, with `activation_sha256` equal to the current activation text, `validation_result` pass, a strictly valid input manifest and every input unchanged when re-read and re-hashed (PLANNING_AUTHORIZED). A structural, discovery-complete, parity-complete or agent-output receipt (WRONG_MODE), a version-1 or foreign-kind receipt or an invalid manifest (RECEIPT_VERSION), another session or host (IDENTITY), a non-gateway writer (FORGED), another workspace or profile (BINDING), a changed activation (STALE_ACTIVATION), a failing result (RESULT) and drifted inputs (STALE_INPUTS) deny; a session without any receipt denies naming the prerequisite and the `validate_discovery_artifacts` mode planning step (NO_RECEIPT). The newest planning-mode candidate explains a refusal; an older stale receipt does not shadow a current one and unreadable neighbours are skipped.
- The hooks only verify authority: no Python interpreter or validation run is invoked (the Claude planning suite asserts the hook source and the enforcement-hooks-no-python-invocation guard passes over the module).

## Classification and publication

- Both core pack manifests list `DiscoveryPlanning.psm1`; the Claude core lists `.claude/hooks/enforce-discovery-planning-gate.ps1` and the Codex core lists `.codex/hooks/enforce-discovery-planning-gate.ps1`; the Claude bundle, the Codex bundle and `resources/lib/discovery-validation` are byte-identical. The GitHub hook publishes through the `.github/hooks` Copilot push-down root (P8-T9) inside the T3 root classified in P9-T2.

## Gates

- PoshQC format and analyze clean; PSScriptAnalyzer launcher zero findings; MCP Pester 393/0 over discovery-validation and copilot-hooks; launcher runs 66/66 (planning suites) and 1,875/1,876 framework and discovery cases (the single failure is the pre-existing P7-T4 `CodexDiscoveryRouting.psm1` convention defect); Python 126 passed.

## Carried notes

- Root planning receipts are read from `<session>/receipts/<receipt_ref>.json` in the protected store, the same partition shape the gateway uses for invocation receipts; the gateway's root-mode (`mode=planning`) receipt writer is not part of this hook task and the root `validate_discovery_artifacts` path must write there for the gate to admit planning (P9 stop/finalize and P11 review follow-ups).
- Event registration (Claude `Agent` matcher group, `.codex/config.toml`, `.github/hooks/*.json`) is P9-T6.
- `CodexDiscoveryRouting.psm1` convention defect remains recorded for the P11 closing review.
