# P9-T2 Native tool and artifact grant enforcement contract

Timestamp: 2026-10-22T15-14
Task: [P9-T2] Enforce tool and exact artifact grants before every analyst action.
Result: PASS

## Adapters delivered

- `.claude/hooks/enforce-discovery-artifact-gate.ps1` (replaced): the Claude Code PreToolUse adapter. It keeps its name, its `DISCOVERY_ARTIFACT_GATE_BLOCKED:` reason prefix, its `Invoke-DiscoveryArtifactGateDecision -ToolInputRaw` seam and the shared dependency guard, imports HookPayload and the four discovery helpers through guarded `Join-Path $PSScriptRoot` edges, and no longer validates artifact content or dispatches to DiscoveryValidation.psm1.
- `.codex/hooks/enforce-discovery-artifact-gate.ps1` (new): the Codex PreToolUse adapter. Helper modules resolve to `.codex/lib/discovery-validation` in a destination and to `.claude/lib/discovery-validation` in this repository (parameter-default `$ScriptRoot = $PSScriptRoot` form). Allow is silent at exit 0, deny writes the PreToolUse decision at exit 0, an unreadable envelope writes the reason to stderr at exit 2.
- `.github/hooks/discovery-pre-tool.ps1` (new, the first tracked GitHub hook): the Copilot local-harness adapter over camelCase envelopes with its own fail-closed dependency list.
- `.claude/lib/discovery-validation/DiscoveryAuthorization.psm1` (new, shared by the three adapters): tool-family routing, operation derivation, `sha256(canonical_json({inputs, operation, tool}))` digests, started-invocation binding, the one-use `tool-authorization` record (19 schema keys) and the decision function. `DiscoveryPayload.psm1` gains the host `tool_use_id` / `toolUseId` member for the request correlation key.

## Decision contract (proven in `LPTEST/DiscoveryAuthorization.Tests.ps1` and the three hook suites)

- A process with no attested DRM_DISCOVERY_AGENT_ID/ROLE is allowed for every tool, so root and ordinary sessions keep their other gates (unrelated inactive behavior unchanged).
- For an attested discovery specialist: shell/terminal/exec/evaluation tools (SHELL), generic Write/Edit/MultiEdit/NotebookEdit/apply_patch/create_file/insert_edit mutations of production, test, config, profile, locator, schema, policy or hook paths (MUTATION), nested agent launches (SPAWN), foreign MCP servers (FOREIGN_MCP), unknown tools including approval tools (UNKNOWN_TOOL), root-only discovery tools and operations such as prepare_discovery_agent, run_discovery_doctor, configure, migrate and init (ROOT_ONLY), caller-supplied identity fields in tool input (CALLER_IDENTITY), underivable operations (OPERATION), an envelope whose session or host differs from the attested context (IDENTITY), a role outside the four discovery roles (ROLE), an inactive or missing activation (ACTIVATION), no single started invocation bound to the agent (NO_INVOCATION), a profile binding that differs from the activation (BINDING) and a record that cannot be stored exclusively (STORE) are all denied before execution.
- Read-only native tools are allowed without a record. A controlled discovery MCP tool with a current activation and a started invocation is allowed after one `tool-authorization` record is written under `<invocation>/authorizations/<authorization_ref>.json` with state `issued`, a five-minute window, the exact input digest, the trusted identity, the invocation, start-attestation and capability references and the handler SHA-256; a second record for the same reference is refused by the exclusive write. The inventory vector from `tests/fixtures/discovery_host/tool-authorizations.json` reproduces its `input_sha256` through the hook end to end.
- Bounded reads (`read_discovery_source`) and controlled draft mutations (`create_discovery_artifact` new-contract) are authorized without any prior completion gate; the installed runtime validates the proposed bytes at the service boundary.

## Dependency-failure contract

- Every helper import of the Claude hook is a guarded edge: `hook-dependency-failure.Claude.Tests.ps1` (B1 rows derived from the hook AST) proves each failing edge denies with the prefix naming the dependency before any payload read; `enforce-discovery-artifact-gate.HelperImportFailure.Tests.ps1` proves the same for the repository copy and the bundle mirror, through the decision seam and the `&` route. The H10 handler exemption for DiscoveryValidation.psm1 is retired from `HookImportFailureExemptions.Helpers.ps1`; `hook-import-failure-exemptions.Guard.Tests.ps1` and `hook-dependency-guard-completeness.Tests.ps1` pass.
- The obsolete `enforce-discovery-artifact-gate.ValidationImportFailure.Tests.ps1` and `enforce-discovery-artifact-gate.ValidatorDispatch.Tests.ps1` suites (validator dispatch no longer exists) are removed; the EpicStateIsolation discovery meta-suite re-enumerates the surface and passes.

## Classification and publication

- `scripts/dev_tools/quality_tiers_contract.py` discovers `.github/hooks` (R5), `quality-tiers.yml` classifies it T3, `config/poshqc-coverage.json` measures it, and the tier tests cover the new root with absent/excluded negatives; no QT007/QT008.
- Claude core.json lists `.claude/lib/discovery-validation/DiscoveryAuthorization.psm1`; Codex core.json lists `.codex/hooks/enforce-discovery-artifact-gate.ps1` and `.codex/lib/discovery-validation/DiscoveryAuthorization.psm1`; the Claude bundle carries the hook and all six helpers byte-identically, the Codex bundle carries the hook, and `resources/lib/discovery-validation` carries the six helpers for the P8-T9 directory mapping. The GitHub hook publishes through the `.github/hooks` Copilot push-down root added in P8-T9.

## Pester results

- Focused run: 273 cases over the six discovery-validation suites, the two Claude gate suites, the Codex and Copilot adapter suites and the Claude library convention suite: 272 pass; the single failure is the pre-existing P7-T4 convention defect in `.claude/lib/codex-routing/CodexDiscoveryRouting.psm1`, outside this task.
- Affected framework suites: 1,246 cases pass across hook-dependency-failure (Claude and Codex), SpecialCases, exemption guard, guard completeness, EpicStateIsolation discovery, Codex bundle hook probe and Codex epic runtime contracts.

## Carried notes

- Event registration (Claude settings matcher, `.codex/config.toml`, `.github/hooks/*.json`) is P9-T6; until then the Claude hook still runs under its existing `Write|Edit` matcher and the Codex and Copilot adapters are published but unregistered.
- The gateway's `consumeToolAuthorization` has no production caller yet in the extension; the record contract written here is the one that consumer validates (P8-T3 fixtures), and wiring the consumption into the service remains with the P9 stop/finalize tasks.
- `CodexDiscoveryRouting.psm1` convention defect remains recorded for the P11 closing review.
