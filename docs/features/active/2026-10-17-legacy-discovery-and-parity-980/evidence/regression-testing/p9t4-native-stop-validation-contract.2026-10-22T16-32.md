# P9-T4 Native stop validation contract

Timestamp: 2026-10-22T16-32
Task: [P9-T4] Validate each specialist's actual required outputs at stop.
Result: PASS

## Surfaces delivered

- `.claude/lib/discovery-validation/DiscoveryStop.psm1` (new, shared): `Find-DiscoveryAgentInvocationForStop` (the started or finalized invocation bound to this host, session, parent, agent type and host-assigned agent id), `Get-DiscoveryReceiptMismatch` (the completion receipt against the invocation, principal, current activation and workspace bytes), `Get-DiscoveryStopVerdict` and `Get-DiscoveryStopDecision` (the continuation rule). `DiscoveryAuthority.psd1` nests and exports it.
- `.claude/hooks/validate-discovery-artifact-gate.ps1` (replaced): keeps its name, its `DISCOVERY_ARTIFACT_GATE_BLOCKED:` prefix, the guarded `subagentstop-envelope.ps1` dot-source, the `Invoke-DiscoveryArtifactGateValidation -InputText` seam, the exit-2 block through `Exit-SubagentStopBlock` and the validator-error interception; it no longer scans the final message for artifact paths or dispatches to `DiscoveryValidation.psm1`, and reads no orchestrator checkpoint.
- `.codex/hooks/validate-discovery-agent-output.ps1` (new): the Codex SubagentStop adapter with the shared dependency guard, published-or-self-hosted module resolution, `Invoke-DiscoveryAgentOutputDecision -PayloadRaw`, the Codex continuation shape (`decision=block`, then `continue=false` once `stop_hook_active`) and stderr exit 2 for an unreadable envelope. `validate-codex-subagent-routing.ps1` gates the four discovery specialist families (`Test-CodexStopDiscoveryAgent`) and requires their SubagentStart attestation to carry `receipt_kind: discovery-invocation`.
- `.github/hooks/discovery-agent-stop.ps1` (new): the Copilot local-harness adapter over camelCase envelopes with its own fail-closed dependency list.

## Decision contract (proven in `LPTEST/DiscoveryStop.Tests.ps1`, `CPTEST/discovery-output.Tests.ps1`, `CPTEST/validate-discovery-artifact-gate.Tests.ps1`, `XPTEST/discovery-output.Tests.ps1`, `tests/scripts/copilot-hooks/discovery-output.Tests.ps1`)

- Every role (legacy-parity-analyst, runtime-characterization-analyst, requirements-reconciler, migration-coverage-reviewer, with `-c1`..`-c4` and `-c3-elevated` variants) has an enforced stop result derived from its protected invocation: the invocation must be `finalized` with a `completion_receipt_ref` (NOT_FINALIZED otherwise), the receipt at `<invocation>/receipts/<ref>.json` must be the gateway-written `validation-receipt` for this invocation (RECEIPT), gate mode `agent-output` (GATE), identity kind `discovery-agent` bound to this host, session, agent, role and invocation (IDENTITY), writer kind `host-gateway` (FORGED), workspace and profile equal to the current activation (BINDING), `activation_sha256` equal to the current activation record text (STALE_ACTIVATION), runtime pins equal to the invocation (RUNTIME), the invocation's required-output manifest (OUTPUTS), `output_valid` true (OUTPUT_INVALID), result `pass` or, for the reviewer only, an output-valid `fail` (RESULT).
- Stale input, profile and evidence: the receipt input manifest is decoded strictly and every entry re-read and re-hashed through the workspace seam (`Compare-DiscoveryInputManifest`); an edited or deleted input, a replaced domain profile or replaced evidence blocks (STALE_INPUTS) with the drift kinds named.
- Absent required path, id or kind: every required-output row must carry its kind, id and path (OUTPUTS) and the path must exist in the workspace (OUTPUT_MISSING); a valid incremental result whose receipt names more outputs than the baseline passes when every output exists.
- Missing or blank final text and forged workspace success: the final message never grants authority. Success prose and filenames without a receipt block on the receipt (RECEIPT); a blank message over a valid receipt, a `PASS` claim over a failing reviewer receipt and prose without an explicit result block (RESULT_TEXT), because the message must state the explicit PASS or FAIL the protected receipt proves. The diagnostic mirror claims a finalized invocation of a forged agent in every fixture store and is never read.
- Wrong session, role or gate, nested specialist, missing activation, missing or ambiguous invocation and an unreadable envelope block with IDENTITY, ROLE, GATE, NESTED, ACTIVATION, NO_INVOCATION, AMBIGUOUS and ENVELOPE; `stop_hook_active` turns a block into a CONTINUED allow so the host does not loop, never for an unreadable envelope.
- Unchanged ordinary and inactive behavior: `atomic-executor`, `epic-planner`, `general-purpose`, `atomic-planner`, `pr-author` and `feature-review` stops are skipped by all three adapters without a store read, whatever their message says; the Claude hook keeps validating when `stop_hook_active` is true; the other SubagentStop validators are untouched.

## Retained guarantees

- U1 and U1-ST: `subagentstop-uncaught-error.Tests.ps1` drives the replaced hook with the envelope helper throwing script- and statement-terminating errors; it exits 2 with the `DISCOVERY_ARTIFACT_GATE_BLOCKED:` prefix and the first error line. U2: the hook still dot-sources `subagentstop-envelope.ps1` in a single-statement guarded try and the inventory matches. B1 and S1 to S6: the hook's six guarded `Join-Path $PSScriptRoot` imports deny with the prefix naming the dependency, and the decision function returns the dependency decision first.
- The legacy `validate-discovery-artifact-gate.Dispatch.Tests.ps1` and `validate-discovery-artifact-gate.ValidatorDispatch.Tests.ps1` suites (validator dispatch no longer exists) are removed; the EpicStateIsolation discovery meta-suite re-enumerates the surface and passes; `claude-settings.Tests.ps1` still finds the hook under its registered name.

## Classification and publication

- Both core pack manifests list `DiscoveryStop.psm1` and the Codex core lists `.codex/hooks/validate-discovery-agent-output.ps1`; the Claude bundle carries the replaced hook, the module and the manifest, the Codex bundle carries the extended routing validator and the new adapter, and `resources/lib/discovery-validation` carries the module and manifest, all byte-identical. The GitHub hook publishes through the `.github/hooks` Copilot push-down root (P8-T9) inside the T3 root classified in P9-T2.

## Gates

- PoshQC format and analyze clean; PSScriptAnalyzer launcher zero findings; MCP Pester 346/0 over discovery-validation and copilot-hooks; launcher runs 148/148 (stop, routing, uncaught-error and provenance suites), 1,776/1,779 framework cases with the two S6 findings fixed in-task and rerun 807/807, the single remaining failure the pre-existing P7-T4 `CodexDiscoveryRouting.psm1` convention defect; Python 126 passed.

## Carried notes

- Event registration (`.codex/config.toml` SubagentStop matcher extension to discovery agent types and the `validate-discovery-agent-output.ps1` command, `.github/hooks/*.json`) is P9-T6; the Claude hook runs under its existing broad SubagentStop matcher, which P9-T6 extends to the four discovery agent names.
- `DiscoveryValidation.psm1` is no longer imported by any hook; its retirement and compatibility entry points are P9-T7.
- `CodexDiscoveryRouting.psm1` convention defect remains recorded for the P11 closing review.
