# Research: Host Identity Sources for Discovery Controls (Issue #980, Blocking Finding R4)

Date: 2026-10-29. Filename stamp: `2026-10-29T13-16` is the stamp of the review artifact set this research answers. The researcher has no clock tool, so the stamp was not read from the host clock at write time; the file was written after that review set.
Inputs: `code-review.2026-10-29T13-16.md` (Findings Table rows 1-2), `remediation-inputs.2026-10-29T13-16.md` (R3, R4).
User decision (from the delegation prompt): identity comes from each host's own hook payload; fail closed; agent-scoped MCP discovery writes without a verified invocation reference are refused, not run as `local-user`; the capability probe tests a real payload and reports `unsupported` on any host that cannot supply identity.

Legend: **Verified-doc** = quoted from official documentation fetched on 2026-10-29. **Verified-repo** = read in this worktree. **Unverified** = neither source states it.

## 1. Current State (Verified-repo)

| Read site | What it reads | Effect when unset |
|---|---|---|
| `.claude/lib/discovery-validation/DiscoveryPayload.psm1` `$script:EnvironmentKeys`, `Get-DiscoveryTrustedPrincipal`, `Get-DiscoveryHostEnvironmentValueTable` | Six `DRM_DISCOVERY_*` process values; envelope `agent_id`/`agent_type`/`tool_use_id` are already normalized (`$script:EnvelopeKeys`) but not used for the principal | Principal unattributed |
| `DiscoveryAuthorization.psm1` `Get-DiscoveryPreToolDecision` (lines 385-389) | `DRM_DISCOVERY_AGENT_ID`/`_ROLE` | `allow` / `NOT_DISCOVERY_AGENT` for every tool |
| `DiscoveryStart.psm1` (line 285, 288-292) | Agent id from envelope (`$Normalized.AgentId`); parent and session from env; NESTED from env | `IDENTITY` deny |
| `DiscoveryStop.psm1` (line 280) | NESTED check from env | — |
| `DiscoveryCapability.psm1` `Get-DiscoverySentinelEnvironment` (82-103), `Get-DiscoveryCapabilityObservation` (244-250) | A table the probe builds itself | `trusted_attribution` true on any host |
| `extensions/drm-copilot/src/discovery-authority-provider.ts` (57-66, 118-130) | Six keys from `process.env` | `context` empty, `agent` null |
| `mcp-discovery-authorization-gate.ts` `admitControlledToolCall` (132-135) | `service.discoveryRole()` (env role) | Gate bypassed; raw input runs |
| `repo-automation-service-discovery-identity.ts` `invocationOptions` (56-61) | Provider identity | `DISCOVERY_AGENT_IDENTITY_REQUIRED` only when `invocation_ref` present |
| `discovery-capabilities.ts` `missingContextAssessment` (272-283) | Provider host/session | `context-missing` |
| `discovery-invocation.ts` (165-167, 382-443) | Provider host/session/parent for `prepare_discovery_agent` | Refusal |
| `.claude/hooks/{enforce-discovery-artifact-gate,record-discovery-agent-start,validate-discovery-artifact-gate}.ps1`, `.codex/hooks/{enforce-discovery-artifact-gate,discovery-start-attestation,validate-discovery-agent-output}.ps1`, `.github/hooks/{discovery-pre-tool,discovery-agent-start,discovery-agent-stop}.ps1` | Delegate to the modules above | As above |

Two facts in the current design are relevant to the redesign:

- The PreToolUse gate already writes a one-use tool-authorization record under `<session>/invocations/<invocation>/authorizations/` binding host, session, agent id, role, invocation id, tool, operation and `input_sha256` (`DiscoveryAuthorization.psm1` 451-464). The MCP side consumes it with `consumeToolAuthorizationByBinding` (`discovery-authorization.ts` 317-), but locates the directory and checks identity from the provider's env-derived identity (`authorizationsDirectory` uses `identity.session_id`, lines 97-107; `sameIdentity`, line 299).
- The gate never checks that the `invocation_ref` in the tool input names the invocation it found for the agent (`invocation_ref` is not read in `DiscoveryAuthorization.psm1`; only `invocation_id` in `$script:CallerIdentityKeys`).

## 2. Claude Code

### 2.1 Payload identity fields (Verified-doc, `https://code.claude.com/docs/en/hooks`)

| Field | Events | Source text |
|---|---|---|
| `session_id`, `transcript_path`, `cwd`, `permission_mode`, `hook_event_name` (also `prompt_id`, `scratchpad_dir`, `effort`) | All (common) | Common input fields table |
| `agent_id` | Common field: "Unique identifier for the subagent or in-process teammate the hook fires in." | Common input fields |
| `agent_type` | "Present when the session uses `--agent` or the hook fires inside a subagent. For subagents, the subagent's type takes precedence over the session's `--agent` value." | Common input fields |
| `tool_name`, `tool_input`, `tool_use_id` | PreToolUse, PostToolUse (PostToolUse adds `tool_response`, `duration_ms`; for MCP tools also `mcp_server`) | PreToolUse/PostToolUse input |
| `agent_id`, `agent_type` | SubagentStart | "SubagentStart hooks receive `agent_id` ... and `agent_type`" |
| `stop_hook_active`, `agent_id`, `agent_type`, `agent_transcript_path`, `last_assistant_message` | SubagentStop | SubagentStop input |
| `stop_hook_active`, `last_assistant_message`, `background_tasks`, `session_crons` | Stop | Stop input (no agent fields listed) |
| `parent_agent_id` or any parent field | none | Not present in any section read |

Tool calls inside a subagent (Verified-doc): "When a subagent calls a tool, tool events such as `PreToolUse` and `PostToolUse` fire the same configured hooks as in the main conversation, and the input carries the `agent_id` and `agent_type` common input fields ... that identify the subagent."

MCP tools (Verified-doc): MCP tools are named `mcp__<server>__<tool>` and matched by regex; the matcher must include `.*` to match a server's tools. PreToolUse is a tool event, so the subagent statement above covers MCP calls by its wording ("tool events"); the docs do not show an MCP-specific PreToolUse payload with `agent_id`. Status: **documented generally, not shown for MCP specifically; confirm with a real payload** (this is what the probe in section 6.4 does).

Consequences:
- Root detection must use the absence of `agent_id`, not of `agent_type`: `agent_type` is present on the main thread under `--agent`. The repo's `enforce-epic-invocation-origin.ps1` (lines 18-20, 178-182) uses `agent_type` absence and therefore misclassifies a `--agent` main thread; this does not affect discovery if the new design keys on `agent_id`.
- There is no parent identifier. The parent of a Claude subagent is the main thread of the same session.
- SubagentStart cannot block (Verified-doc): "SubagentStart hooks can't block subagent creation, but they can inject context into the subagent." The current `record-discovery-agent-start.ps1` deny therefore does not prevent a specialist from running. `enforcement.md` row "Start attestation" and the code-review sentence "the start hook denies every specialist start" describe an effect the host does not provide.
- Agent identity is not passed to MCP servers (Verified-doc, `https://code.claude.com/docs/en/mcp`): the only per-request `_meta` is client capabilities; the only env var documented for a stdio server is `CLAUDE_PROJECT_DIR`. `CLAUDE_ENV_FILE` is available only to SessionStart, Setup, CwdChanged and FileChanged hooks, and not to a hook that runs in PowerShell.
- Subagent frontmatter `mcpServers` (Verified-doc, `https://code.claude.com/docs/en/sub-agents`): inline servers "are connected when the subagent starts ... and disconnected when it finishes. String references share the parent session's connection." Whether inline definitions accept `env` is not stated (Unverified).

### 2.2 Existing repo hooks that read these fields (Verified-repo)

- `enforce-epic-invocation-origin.ps1`: reads top-level `agent_type` on PreToolUse(`Agent`) to identify a subagent caller.
- `subagentstop-envelope.ps1` (149-152): reads `agent_type` from SubagentStop.
- `enforce-model-routing-receipt.ps1`, `enforce-orchestration-preimplementation-gate.ps1`: read `tool_input.subagent_type` (the delegation target), not caller identity.
- `enforce-epic-merge-gate.ps1` (382), `persist-session-id.ps1` (57-58): read `session_id`.
- No `.claude/hooks` file reads `agent_id` or `tool_use_id`, and none emits `updatedInput` (grep over `.claude/hooks` for `agent_id|updatedInput|tool_use_id` returned only `hookSpecificOutput` decision emitters).
- `record-subagent-routing-attestation.ps1` exists only under `.codex/hooks/` (see 3.2), not under `.claude/hooks/`.

### 2.3 Modifying an MCP call / other channels to the server

- `updatedInput` (Verified-doc): "Modifies the tool's input parameters before execution. Replaces the entire input object ... Combine with `"allow"` to auto-approve, or `"ask"` ... For `"defer"`, ignored." The docs do not state whether it applies to MCP tools. Status for MCP: **Unverified**.
- `type: "mcp_tool"` hooks (Verified-doc): a hook can call a configured MCP server's tool with `input` strings supporting `${path}` substitution from the hook JSON (example `${tool_input.file_path}`). "If the tool returns `isError: true`, the hook produces a non-blocking error and execution continues." This channel fails open and the target tool is also callable by the model, so it cannot serve as a fail-closed identity channel.
- The server sees no session, agent or `tool_use_id` (Verified-doc absence in the MCP page; JSON-RPC request ids are not documented as equal to `tool_use_id`).
- A hook-written protected record that the server verifies is feasible with no host feature beyond PreToolUse: the gate already writes one keyed by invocation and `input_sha256`; the server already recomputes the digest from the raw input it receives. What is missing is a server-side lookup that does not need the session from env (section 6.2).

## 3. Codex CLI

### 3.1 Payload identity fields (Verified-doc, `https://learn.chatgpt.com/docs/hooks`, redirected from `developers.openai.com/codex/hooks`)

| Field | Events |
|---|---|
| `session_id`, `transcript_path`, `cwd`, `hook_event_name`, `model` | Common. "Subagent hooks use the parent session id." |
| `turn_id`, `tool_name`, `tool_use_id` ("Tool-call id for this invocation"), `tool_input` ("MCP and other local function tools send their arguments") | PreToolUse |
| `turn_id`, `agent_id`, `agent_type`, `permission_mode` | SubagentStart |
| `turn_id`, `agent_id`, `agent_type`, `agent_transcript_path`, `stop_hook_active`, `last_assistant_message` | SubagentStop |
| Parent agent field | none documented |

- PreToolUse fires for MCP tools: "Match the MCP tool name, such as `mcp__filesystem__read_file`."
- PreToolUse can deny (`permissionDecision: "deny"`, legacy `decision: "block"`, exit 2) and can rewrite: "return `permissionDecision: "allow"` with `updatedInput`"; for MCP tools "`updatedInput` is the replacement arguments object." (Verified-doc)
- SubagentStart cannot block: "`continue: false` is parsed for compatibility, but it doesn't stop the subagent from starting." (Verified-doc)
- `agent_id`/`agent_type` on PreToolUse inside a subagent: **not documented** ("The PreToolUse table lists no agent-specific fields"). Whether a subagent's PreToolUse `transcript_path` is the subagent's own transcript is also not documented. Status: **Unverified**.
- Hook process environment: only `PLUGIN_ROOT`, `PLUGIN_DATA`, `CLAUDE_PLUGIN_ROOT`, `CLAUDE_PLUGIN_DATA` for plugin hooks. No identity is documented for MCP servers.

### 3.2 Existing `.codex/hooks` reliance (Verified-repo)

- `record-subagent-routing-attestation.ps1` (SubagentStart): requires `agent_id`, `agent_type`, `model` (line 156-161); reads `session_id`, `turn_id`, `transcript_path`; its synopsis states "The hook cannot prevent startup", consistent with the docs. It keys the attestation by SHA-256 of `transcript_path`, else `agent_id` (`Get-SubagentAttestationKey`, 43-54).
- `enforce-epic-root-invocation.ps1` (PreToolUse, 97-132): looks up the attestation by `transcript_path`, then falls back to `payload.agent_id`. This is a repo reliance on PreToolUse fields that the current Codex documentation does not list. Unverified whether either distinguishes a subagent's tool call on the current Codex release.
- `validate-codex-subagent-routing.ps1` (SubagentStop): matches `agent_id` and `agent_type`.
- No `.codex/hooks` file emits `updatedInput`.

## 4. GitHub Copilot

Three distinct hook surfaces exist; they differ.

| Surface | Source | Hook files read | Agent identity on tool events | Start can block | Input rewrite | MCP coverage |
|---|---|---|---|---|---|---|
| Copilot CLI and cloud agent ("Copilot harness") | `https://docs.github.com/en/copilot/reference/hooks-reference` (Verified-doc) | `.github/hooks/*.json` (both); CLI also `.github/copilot/settings*.json` and repository `.claude/settings*.json` | "Hooks that fire inside a subagent include extra fields in their input": `agentId`, `agentType`, `parentAgentId` (snake_case in the VS Code format). Root inputs unchanged. preToolUse has **no tool-call id** | No ("cannot block creation") | `modifiedArgs` | Not stated; tool-name table lists built-ins only |
| VS Code agent hooks, Copilot harness (Preview) | `https://code.visualstudio.com/docs/copilot/customization/hooks` (Verified-doc) | `.github/hooks/*.json`, repository `.claude/settings*.json` | Defers to the GitHub reference above; not restated | Not stated | Not stated | Not stated |
| VS Code legacy Local harness | `https://code.visualstudio.com/docs/agents/reference/hooks-reference` (Verified-doc) | as above | SubagentStart/SubagentStop carry `agent_id`, `agent_type`; PreToolUse lists only `tool_name`, `tool_input`, `tool_use_id` | No blocking output documented | `updatedInput` ("must match the tool schema") | Not stated |

Further facts:
- subagentStart in the Copilot harness lists `agentName` (and optional display name/description) but **not** `agentId`/`agentType`; subagentStop lists `agentId`, `agentType`, `agentName`. The built-in general-purpose agent emits neither event (Verified-doc).
- Config shape (Verified-doc): `{ "version": 1, "hooks": {...} }`; command entries use `bash` and/or `powershell` keys with `command` as fallback; cloud agent ignores `powershell`; PascalCase event names switch the payload to snake_case. The repo's `.github/hooks/discovery.json` has no `version` key and uses a `windows` key (Verified-repo). Whether the Copilot harness accepts that file unchanged is **Unverified**.
- No identity is passed to MCP servers on any Copilot surface (no statement in any of the three pages).

Answer to the question "does Copilot have any identity channel": yes for the Copilot harness (CLI, cloud agent, and probably VS Code's Copilot harness, Unverified for VS Code), through `agentId`/`agentType`/`parentAgentId` on hooks inside a subagent. Two gaps remain: MCP coverage of preToolUse is undocumented, and subagentStart carries no `agentId`. The legacy Local harness carries no agent identity on PreToolUse and must report `unsupported`.

## 5. Candidate Approaches

1. **Payload identity plus hook-written one-use binding record consumed by input digest (selected).** The PreToolUse hook derives host (from which hook file runs), session, agent id, agent type and parent from the payload, decides, and on allow writes a protected one-use record bound to tool, operation and `input_sha256`. The MCP server recomputes the digest from the raw arguments it received, finds and latches exactly one matching record, and adopts the identity from the record. Needs only PreToolUse on MCP tools plus an agent id on subagent tool events; no input rewrite, no env, no server-side knowledge of the session. Extends the record the gate already writes.
2. **`updatedInput`/`modifiedArgs` injection of a `binding_ref`.** Explicitly documented for MCP only on Codex; unverified for MCP on Claude and Copilot; requires every controlled tool schema to accept the field.

Rejected alternatives (brief): `DRM_DISCOVERY_*` env (status quo; no host sets per-call or per-subagent env; `CLAUDE_ENV_FILE` is SessionStart-family only and excludes PowerShell hooks). Subagent-scoped inline `mcpServers` with env (Claude-only; gives a static role but no runtime `agent_id`; `env` support unverified). `type: "mcp_tool"` hooks (fail open on `isError`; the target tool is model-callable). Approach 2 is kept only as a later hardening option where documented.

## 6. Recommended Binding Design

### 6.1 Identity source per host

| Host | Host name | Session | Caller agent | Root caller | Parent of a specialist |
|---|---|---|---|---|---|
| Claude Code | fixed by the hook file location (`.claude/hooks`) | `session_id` | `agent_id` + `agent_type` on the PreToolUse payload | `agent_id` absent | the session's main thread, recorded as the literal `root` |
| Codex | `.codex/hooks` | `session_id` (parent session for subagents) | `agent_id` + `agent_type` on PreToolUse **only if** a real payload shows them (Unverified) | `agent_id` absent | `root` |
| Copilot harness | `.github/hooks` | `sessionId`/`session_id` | `agentId`/`agent_id` + `agentType`/`agent_type` | fields absent | `parentAgentId`/`parent_agent_id` when present, else `root` |
| VS Code Local harness | — | — | none on PreToolUse | — | `unsupported` |

Role = `Get-DiscoveryAgentRole -AgentType <payload agent type>` (the mapping `DiscoveryStart.psm1` already uses, including Codex `-c` variants). `DRM_DISCOVERY_*` is removed from every read site; nothing in tool input supplies identity (`$script:CallerIdentityKeys` stays).

### 6.2 Tying a specialist's MCP calls to its prepared invocation

1. **Prepare (root).** PreToolUse on `mcp__drm-copilot__prepare_discovery_agent` with no payload `agent_id` writes a one-use *root grant* `{host, session_id, parent_agent_id: "root", tool, operation, input_sha256, tool_use_id, handler_sha256, issued_at, expires_at}` under a workspace-level partition `root-grants/` of the protected store. The server's prepare handler computes `input_sha256`, requires exactly one live matching root grant (zero: `DISCOVERY_HOST_BINDING_REQUIRED`; more than one: `AMBIGUOUS`), latches it, and takes host, session and parent from it. The prepared invocation record is unchanged in shape.
2. **Start (all hosts, observational).** SubagentStart cannot block on any of the three hosts, so the start hook records the attestation (agent id to prepared invocation, state `started`) and never relies on a deny. On Copilot, whose subagentStart has no `agentId`, the binding happens at the specialist's first controlled PreToolUse instead (exactly one `prepared` invocation for that session, parent and agent type, otherwise deny `AMBIGUOUS`/`NO_INVOCATION`).
3. **Tool call (specialist).** PreToolUse with payload `agent_id` and a discovery `agent_type`: family routing as today, then require `tool_input.invocation_ref` to equal the `invocation_id` of the single started invocation bound to this `agent_id` (new check), then write the existing tool-authorization record with the payload identity.
4. **Server consume.** `consumeToolAuthorizationByBinding` stops taking identity from the provider. It resolves the invocation directory from `invocation_ref` alone (scan `sessions/*/invocations/<partitionName(invocation_ref)>`; exactly one match), requires the invocation record state `started`, filters live issued records by tool, operation and digest, requires the record's `identity.agent_id`/`role`/`session_id` to equal the invocation record's started agent, latches, and returns the identity for the host-principal run (`hostInvocationOptions` takes it from the consumed record, not from `authority.agent`).

Threat note: a specialist cannot write the protected store because shell and generic mutation tools are denied to it by the same payload-attributed gate. The root session can still write the store with its own shell; that is the existing trust boundary and is unchanged.

### 6.3 Calls refused when the binding is absent

- Any controlled tool call (`$script:ControlledToolOperations` keys: `read_discovery_source`, `run_discovery_repo_inventory`, `run_discovery_dotnet_analyzer`, `run_discovery_vsto_analyzer`, `create_discovery_artifact`, `update_discovery_artifact`, `link_discovery_evidence`, `run_discovery_scenario_generation`, `run_discovery_report`, `validate_discovery_artifacts`, `finalize_discovery_agent`) that carries `invocation_ref` without exactly one live matching tool authorization: refuse (`AUTHORIZATION_MISSING`/`_IDENTITY`/`_INPUT`/`_CONSUMED`), never `local-user`.
- Any controlled tool call **without** `invocation_ref` that would mutate discovery state (`create_discovery_artifact`, `update_discovery_artifact`, `link_discovery_evidence`, `run_discovery_scenario_generation`, `finalize_discovery_agent`) unless a live root grant for that tool and digest exists, which proves the hook saw a payload with no `agent_id`. Without it, the server cannot tell a root call from a specialist on a hookless host, so it refuses. The hook also denies a specialist's controlled call that omits `invocation_ref`.
- `prepare_discovery_agent` without a root grant (the server has no other source for session and parent).
- `run_discovery_doctor` without a root grant answers `unsupported` / `context-missing` instead of refusing, because doctor must still report.
- Root setup tools (`run_discovery_init`, `configure_discovery_workspace`, `transfer_discovery_snapshot`, `import_discovery_inventory`, `migrate_discovery_artifacts`) keep the `local-user` principal and are not refused. They confer no specialist authority, and without a prepare no specialist invocation can exist. Whether read-only controlled calls without `invocation_ref` (`read_discovery_source`, inventory, `validate_discovery_artifacts`, `run_discovery_report`) also need a root grant is a scope choice; the conservative default is to require it. The user should confirm that default.

### 6.4 Capability probe from a real payload

- Delete `Get-DiscoverySentinelEnvironment`. `trusted_attribution` and `forbidden_tools_denied` are no longer computed in-process.
- The PreToolUse gate writes a *host observation* record for each payload it attributes to a probe sentinel agent: `{host, session_id, agent_id, agent_type, tool_name, tool_use_id present, decision, code, handler_sha256, observed_at}`.
- Add a sentinel agent `discovery-capability-sentinel` (per host, read-only, tools limited to the sentinel MCP tool and `Bash`). The root launches it once per session before discovery. The sentinel (a) calls a new no-op controlled tool `mcp__drm-copilot__discovery_capability_sentinel`, whose server handler must consume a hook-written authorization naming the sentinel's `agent_id`, and (b) attempts a harmless `Bash` command that the hook must deny with `SHELL`.
- `trusted_attribution` is true only when an observation in the current session shows an MCP tool call carrying a non-empty `agent_id` and the sentinel `agent_type`, written by a handler whose SHA-256 equals the registered handler bytes the probe already hashes, and the server consumed the matching record. `forbidden_tools_denied` is true only when a `SHELL` deny observation from the same `agent_id` exists. Missing, stale, or mismatched observation: `unsupported` with `DISCOVERY_ENFORCEMENT_UNAVAILABLE` naming the control (R3).
- This makes Codex and the VS Code Local harness report `unsupported` automatically when their PreToolUse payloads lack an agent id, and Copilot report `unsupported` when preToolUse does not fire for MCP tools. It also tests the actual installed host instead of the documentation.

### 6.5 Files and tests that change (Verified-repo paths)

Production, each with mirrors under `extensions/drm-copilot/resources/` and `packages/mcp-server/resources/` (both `claude-customizations/.claude/lib/...` and `lib/...` copies exist for the PowerShell modules):
- PowerShell: `.claude/lib/discovery-validation/{DiscoveryPayload,DiscoveryAuthorization,DiscoveryStart,DiscoveryStop,DiscoveryCapability}.psm1`; hooks `.claude/hooks/{enforce-discovery-artifact-gate,record-discovery-agent-start,validate-discovery-artifact-gate,discovery-capability-probe}.ps1`; `.codex/hooks/{enforce-discovery-artifact-gate,discovery-start-attestation,validate-discovery-agent-output,discovery-capability-probe}.ps1`; `.github/hooks/{discovery-pre-tool,discovery-agent-start,discovery-agent-stop,discovery-capability-probe}.ps1`; `.github/hooks/discovery.json` (`version: 1`, `powershell`/`bash` keys) after the shape is confirmed.
- TypeScript: `discovery-authority-provider.ts` (drop identity keys; keep `LOCALAPPDATA`/`XDG_STATE_HOME`), `discovery-authorization.ts` (invocation lookup by `invocation_ref`; identity from record), `mcp-discovery-authorization-gate.ts` (gate keyed on `invocation_ref` presence and root grants, not `discoveryRole()`), `repo-automation-service-discovery-identity.ts`, `repo-automation-service-discovery.ts` (`discoveryRole`), `repo-automation-service-discovery-agent.ts`, `discovery-invocation.ts` (prepare context from root grant), `discovery-capabilities.ts` (`missingContextAssessment` source), `mcp-tools.ts` (line 212 role check), plus the new sentinel tool and its `coverageThreshold` entry in `extensions/drm-copilot/jest.config.cjs`.
- Agent definitions: new sentinel agent in `.claude/agents/`, `.codex` and `.github` agent surfaces (Codex variants are generated by `generate_codex_agent_variants.py`); `.claude/settings.json` and `.codex/config.toml` SubagentStart/Stop matchers if the sentinel needs them.
- Docs: `docs/engineering/legacy-discovery-and-parity/enforcement.md` (identity source, start-is-observational, per-host support table); `handoff.md`/`completion-report.md` qualification per R4.

Tests:
- Pester: `tests/scripts/claude-lib/discovery-validation/{DiscoveryPayload,DiscoveryAuthorization,DiscoveryStart,DiscoveryStop,DiscoveryCapability}.Tests.ps1` and `{DiscoveryGate,DiscoveryStart,DiscoveryStop}.TestSupport.ps1` (replace `DRM_DISCOVERY_*` tables with payload fixtures); `tests/scripts/claude-hooks/{enforce-discovery-artifact-gate,discovery-start,discovery-output,discovery-capability,discovery-entrypoints,validate-discovery-artifact-gate}.Tests.ps1`; `tests/scripts/codex-hooks/{discovery-pre-tool,discovery-start,discovery-output,discovery-capability,discovery-entrypoints}.Tests.ps1`; `tests/scripts/copilot-hooks/{discovery-pre-tool,discovery-start,discovery-output,discovery-capability,discovery-entrypoints}.Tests.ps1`; `tests/scripts/dev-tools/Test-DiscoveryHostCapability{,.Entry}.Tests.ps1`.
- Jest: `extensions/drm-copilot/test/{discovery-authority-provider,discovery-authorization,discovery-authorization.binding,mcp-discovery-authorization-gate,repo-automation-service-discovery,repo-automation-service-discovery-identity,repo-automation-service-discovery-agent,discovery-invocation,discovery-invocation.refusals,discovery-capabilities,discovery-capabilities-session}.test.ts`, and `discovery-artifact-commands.test.ts` (`withIdentityEnvironment`).
- Python codex-native-converter fixture `tests/fixtures/codex_native_converter/native_surfaces/.github/hooks/discovery.json` and its tests if `discovery.json` changes shape.
- New cases: root grant absent refuses prepare; specialist call without `invocation_ref` refuses; `invocation_ref` naming another agent's invocation denies at the hook and refuses at the server; the probe with no observation returns `unsupported` naming `trusted_attribution`; a Codex PreToolUse fixture without `agent_id` makes the probe `unsupported`.

## 7. Open Items for the User or Orchestrator

- Confirm, with one real captured payload per host, that PreToolUse on an MCP tool inside a subagent carries `agent_id`/`agent_type` (Claude: documented generally; Codex: undocumented; Copilot harness: documented for "hooks inside a subagent" but MCP coverage undocumented). The probe in 6.4 performs this check, so the design does not depend on the answer; support status does.
- Whether read-only controlled calls without `invocation_ref` also require a root grant (6.3).
- Whether `.github/hooks/discovery.json` without `version` is accepted by the Copilot harness.
- Equality of `agent_id` between SubagentStart and the same subagent's PreToolUse is implied by "unique identifier for the subagent" but not stated explicitly for Claude; the start-to-tool binding needs it.

## Numeric Derivation Evidence

Not applicable: this research proposes no numeric count, enumeration size or population for a `spec.md` acceptance criterion. Lists above (read sites, tool names, test files) are enumerations taken from the cited files for planning and are not proposed as acceptance-criterion counts.

## Pre-Mortem

- Review checklists: a reviewer can flag that `enforcement.md` still claims the start hook prevents a specialist start; the plan must rewrite that row as observational and cite the three host docs in sections 2-4.
- Coverage: the identity change touches more than ten TypeScript files and five PowerShell modules; new TypeScript files (sentinel tool, root-grant store) need their own `coverageThreshold` entries, and the plan must retain `lcov.info` and per-file summaries under `evidence/qa-gates/` (the prior review's coverage blocker).
- Mirror parity: every PowerShell module and hook edited has copies under `extensions/drm-copilot/resources/` and `packages/mcp-server/resources/`; the plan must run the push-down contract tests and the Codex generator `--check` after the sentinel agent is added.
- File size: `DiscoveryAuthorization.psm1`, `DiscoveryCapability.psm1` and `discovery-authorization.ts` already carry the gate logic; root-grant and observation logic must go into new modules rather than grow these files toward the 700/800-line tiers.
- Test isolation: removing env reads removes the `withIdentityEnvironment` and `process.env` save/restore patterns; tests must pass payload fixtures through injected seams with no temporary files, and the seeded shuffle runs (Jest, Pester three seeds, single-process Pester) must be re-recorded.
- CI-only behavior: payload fixtures and the store-path scan by `invocation_ref` must use forward-slash relative paths and no drive letters, because the Linux hook-suite job runs `tests/scripts/claude-hooks` and `codex-hooks` case-sensitively; no test may read gitignored `artifacts/` state.
- Evidence: the installed-host smoke must run inside unmodified Claude Code, Codex and Copilot sessions with no SCRATCH launcher exporting identity; evidence records the captured payload field names (not values that leak host paths) and the probe status per host, and the earlier "observed on ... hosts" statements are qualified as harness-simulated.
