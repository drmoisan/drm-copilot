# Enforcement

Native hooks on each agent host verify protected authority before, during and after a
discovery role runs, and gate implementation planning on discovery. The hooks share one
PowerShell decision library (`.claude/lib/discovery-validation`, published to Codex as
`.codex/lib/discovery-validation`), invoke no Python, parse no artifact and never create
authority: everything they verify was written by the engine or the gateway client into the
protected store described in [`architecture.md`](architecture.md).

## Supported native controls

| Control | Event | Verifies | Denial prefix |
|---|---|---|---|
| Start attestation | Agent start (Claude `SubagentStart`; Codex routing attestation; Copilot `discovery-agent-start.ps1`) | Exactly one `prepared` discovery invocation bound to this host, session, parent and agent type, with matching activation, deployment, agent-profile hash and capability pins; the launcher is not itself a specialist. Records the start attestation and moves the invocation to `started`. The start is observational: no host blocks on its start event, so the hook records what it received and never relies on a deny; the binding of the launched agent to its invocation completes at the specialist's first controlled call, where the tool gate requires the payload `agent_id` to own exactly one `started` invocation. | `DISCOVERY_START_ATTESTATION_BLOCKED:` |
| Tool gate | Every tool call (`PreToolUse`) | A started invocation for the calling specialist; read-only native tools and controlled discovery MCP tools only; shell, exec, evaluation, generic Write/Edit/apply_patch, nested agents, foreign MCP servers, root-only operations and caller-supplied identity fields are denied. An admitted call is recorded as a one-use `tool-authorization` the gateway consumes exactly once. | `DISCOVERY_ARTIFACT_GATE_BLOCKED:` |
| Planning gate | Planner or orchestrator delegation (`PreToolUse` on the Agent tool) | In an active workspace: the activated locator and profile are present with their activated bytes, and the session holds a current, passing, gateway-written `planning`-mode receipt for this host whose inputs are unchanged and whose manifest reflects the profile's `planning_prerequisite`. | `DISCOVERY_PLANNING_GATE_BLOCKED:` |
| Stop validation | Agent stop (`SubagentStop`) | The invocation was finalized through the gateway; the receipt is the `agent-output` validation receipt for this invocation, session, role and gate mode, bound to the current activation and workspace, with every required output present, every input unchanged and `output_valid` true. The coverage reviewer may stop on a valid failing report. | `DISCOVERY_ARTIFACT_GATE_BLOCKED:` |
| Capability probe | Operator or doctor (not an event) | The registered handlers and their current hashes, the configuration hash, and the host observations the tool gate recorded while the `discovery-capability-sentinel` agent ran: an attributed sentinel tool call and an attributed denial of a harmless forbidden command. Produces a `capability-attestation`; `supported` only when every control is observed (see `## Capability probe`). | exit 1 when unsupported |

These are the only controls represented as native. Instruction-only restrictions in a role's
prose are not treated as enforcement, and no host-specific mechanism (for example a Write
grant) substitutes for a control.

## Identity source

Identity comes from the host hook payload only. No environment variable, no tool input
field and no gateway option chosen by a caller supplies the host, session, caller or parent
of a discovery call; the hooks read them from the payload the host delivered, and the MCP
server takes them from the protected records the hooks wrote. The retired
environment-variable identity contract has no read site in any hook, module or client.

| Host | Host name | Session | Caller agent | Root caller | Parent of a specialist |
|---|---|---|---|---|---|
| Claude Code | fixed by the hook file location (`.claude/hooks`) | `session_id` | `agent_id` and `agent_type` on the PreToolUse payload | `agent_id` absent | the session's main thread, recorded as the literal `root` |
| Codex | `.codex/hooks` | `session_id` (the parent session for subagents) | `agent_id` and `agent_type` on the PreToolUse payload, when the host delivers them | `agent_id` absent | `root` |
| Copilot harness | `.github/hooks` | `sessionId` or `session_id` | `agentId` or `agent_id` and `agentType` or `agent_type` | the fields are absent | `parentAgentId` or `parent_agent_id` when present, else `root` |
| VS Code legacy Local harness | none | none | none on PreToolUse | none | `unsupported` |

The role is derived from the payload agent type (`Get-DiscoveryAgentRole`, including the
Codex `-c` deployment variants). A payload whose `agent_id` is present but whose agent type
is not a discovery role is an ordinary agent and is never a specialist. A controlled call
that reaches the server without a host binding fails closed: a request carrying an
`invocation_ref` without the one-use authorization the gate issued for it is refused
`DISCOVERY_HOST_BINDING_REQUIRED`, a `read_discovery_source` call without an
`invocation_ref` is a root call and needs a root grant, and `prepare_discovery_agent`
without a root grant is refused the same way. `run_discovery_doctor` without a root grant
answers `context-missing` and `unsupported` instead of refusing, because doctor must still
report.

## Protected records

The store at the platform state root holds, per workspace:

- `activation.json`: the root-owned activation bound to the workspace, the profile and
  locator digests and `required_runtime_major`; a deactivation is a tombstone.
- `sessions/<sha>/invocations/<sha>/invocation.json`: each `discovery-invocation` with its
  role, skill, operation, gate mode, selected identities and paths, input digests, runtime
  and deployment pins, required outputs and `state` (`prepared`, `started`, `finalized`,
  `revoked`). Beside it: `baseline-result.json` (the protected baseline record: the verbatim
  `prepare-agent` result with the pinned input manifest and the planned outputs),
  `required-outputs.json` (the `required-output-manifest`), `model-receipt.json` and
  `topology-receipt.json` (the routing pins), `start-attestation.json` once the start was
  attested, `authorizations/` (one `tool-authorization` per admitted controlled call, its
  `.consumed` latch written by the gateway client when it consumes the grant, and its `.used`
  latch written by the Python host composition when it dispatches the authorized operation,
  so a grant that reaches the engine twice is refused "The authorization was already
  dispatched by the runtime.") and `receipts/` (the invocation's `agent-output` receipt).
- `sessions/<sha>/receipts/`: the root session's `validation-receipt` records per mode.
- `sessions/<sha>/observations/<ref>.json`: one `host-observation` per PreToolUse the gate
  handled for the capability sentinel: the payload identity fields as received (`agent_id`
  and `agent_type` may be null), whether a tool-call identifier was present, the decision
  and its code, and the handler hash. The sentinel tool observation also carries the one-use
  sentinel grant fields (tool, input digest, validity window, state) the MCP server consumes.
  The sentinel tool records its consumption as the exclusive `.consumed` latch beside the
  record (a JSON object naming the `observation_ref` and `consumed_at`) and never rewrites the
  record, whose `state` stays `issued`; the capability probe proves consumption from that latch.
- `root-grants/<grant_ref>.json` and its `.consumed` latch: one short-lived, one-use
  `root-grant` per root call (`prepare_discovery_agent`, `run_discovery_doctor` and a
  controlled tool called with no `agent_id` on the payload), bound to the tool, the derived
  operation and the request digest and carrying the host, session and parent the server
  takes for that call.
- `capability-attestation.json`: the session's host observation with `expires_at`.

Every record carries the digests of what it binds; a hook that finds a changed byte,
a missing record, an ambiguous pair or an expired attestation denies.

## Host-principal path

A discovery specialist never holds authority of its own. The path from the root's prepare to
the accepted stop is a chain of protected records, each written by one component and verified
by the next; every verification failure is a typed refusal and nothing in the chain is
inferred from request JSON.

1. **Root grant and root prepare (`prepare_discovery_agent`, root only).** The tool gate
   sees the root's call with no `agent_id` on the payload and, when the session's protected
   capability attestation is `supported` and unexpired, writes one `root-grant` bound to the
   tool, the operation and the digest of the raw tool input. The MCP server consumes that
   grant by tool, operation and digest (`consumeRootGrant`): no candidate is
   `DISCOVERY_HOST_BINDING_REQUIRED`, a consumed or revoked grant is
   `AUTHORIZATION_CONSUMED`, one outside its window is `AUTHORIZATION_EXPIRED` and several
   current grants are `AUTHORIZATION_AMBIGUOUS`; the one current grant is latched
   (`.consumed`) and its host, session and parent become the identity of the call. The
   gateway client then runs the
   Python `prepare-agent` operation as `local-user` in `structural` mode. The engine pins the
   current configured capture, checks every `expected_outputs` row (unique path, a grant that
   resolves through the path policy, a digest equal to the captured bytes or a null digest
   with an absent path) and returns the baseline result without writing or deriving a grant.
   The gateway client then routes the deployment, verifies the activation envelope and the
   session's capability attestation, and creates the five protected records exclusively
   (`invocation.json`, `baseline-result.json`, `required-outputs.json`, `model-receipt.json`,
   `topology-receipt.json`) plus the diagnostic mirror under
   `artifacts/discovery/invocations/`. Refusals: `INVOCATION_REQUEST_INVALID` (including a
   baseline that is not the ok `prepare-agent` result of the installed runtime),
   `INVOCATION_CAPABILITY_MISSING`, `INVOCATION_CAPABILITY_INVALID`,
   `INVOCATION_CAPABILITY_UNSUPPORTED`, and "Trusted host, session and parent agent identity
   are required." when the process carries no host context. One prepared invocation admits one
   start; preparing the same specialist twice in a session leaves two `prepared` records and
   the start is denied as ambiguous.
2. **Start attestation.** The start hook binds the launched agent type to exactly one
   `prepared` invocation of this host, session and parent (on Codex the agent type is the
   routed deployment variant, for example `legacy-parity-analyst-c1`), writes
   `start-attestation.json` and moves the invocation to `started`.
3. **One-use consumption.** For every admitted controlled call the tool gate reads the
   payload `agent_id` and agent type, requires the request's `invocation_ref` to equal the
   `invocation_id` of the single `started` invocation bound to that agent, and records a
   `tool-authorization` under that invocation's `authorizations/` that binds the host,
   session, agent id, role, tool, operation and the digest of the raw tool input, with a
   validity window. The gateway client consumes it by binding
   (`consumeToolAuthorizationByBinding`): it looks the invocation up server-side by scanning
   the session partitions for the one that holds the request's `invocation_ref`, requires the
   record to be `started` with an `agent_id`, takes the identity from that record, filters
   the live authorizations to those whose identity, tool, operation and input digest equal
   the request, then to those inside their validity window; exactly one must remain and it is
   latched (`.consumed`) before the engine runs. A request that names an `invocation_ref`
   without such an authorization is `DISCOVERY_HOST_BINDING_REQUIRED` and is never run as
   `local-user`. Refusal classes: `AUTHORIZATION_MISSING` (no grant),
   `AUTHORIZATION_CONSUMED` (replay), `AUTHORIZATION_EXPIRED`, `AUTHORIZATION_AMBIGUOUS`
   (more than one current grant), `AUTHORIZATION_IDENTITY`, `AUTHORIZATION_WORKSPACE`,
   `AUTHORIZATION_INPUT`, `AUTHORIZATION_ROOT_ONLY`, `AUTHORIZATION_TOOL_OPERATION`,
   `AUTHORIZATION_OPERATION_UNKNOWN`, `AUTHORIZATION_REQUEST_INVALID`,
   `AUTHORIZATION_INPUT_INVALID` (a malformed tool input), `AUTHORIZATION_RECORD_INVALID`
   (a stored record that fails its schema) and `AUTHORIZATION_IO`.
4. **Host gateway.** The gateway client runs the engine with `--principal host` and the
   trusted identity options `--author-id` (the agent id), `--session-id`, `--host-name` and
   `--agent-role`; the request carries `invocation_ref`, `authorization_ref` and
   `mode: agent-output`. The host composition decodes every protected record through the
   offline catalog and binds it to the activation selection, the trusted identity, the
   installed runtime and its sibling records; any failed binding is `SERVICE_AUTHORITY`
   (exit 3) with a distinct reason. It then replays the pinned baseline: the current capture
   with every required output returned to its prepared state must equal the stored input
   manifest, otherwise `SERVICE_BASELINE` (exit 3, "Prepare the invocation again from the
   current inputs."). Before it dispatches, the composition creates the authorization's
   `.used` latch exclusively; an authorization whose window has closed is refused "The
   authorization expired before dispatch." and one whose latch exists is refused "The
   authorization was already dispatched by the runtime." (both `SERVICE_AUTHORITY`, exit
   3). The service admits a host authority only for a controlled operation in
   `agent-output` mode whose `invocation_ref` names the bound invocation and whose grants are
   derived from the consumed authorization; a `local-user` request that carries an
   invocation or authorization reference, `agent-output` mode or `finalize-agent` is refused
   `SERVICE_AUTHORITY` (exit 3), and `--principal host` without the four identity options is
   refused `SERVICE_REQUEST` (exit 2) before any request is read.
5. **Finalize (`finalize_discovery_agent`, controlled).** Input: `workspace_root`,
   `invocation_ref` and an optional `request_id`; a discovery agent omits `request_id` and
   the consumed authorization reference is recorded instead, because a caller-supplied
   identity field is refused. The engine's `finalize-agent` route requires every
   required-output row to be a grant of the authority (`SERVICE_AUTHORITY`) and the
   `agent-output` mode (`SERVICE_MODE`), reports one artifact row per required output
   (`created`, `updated`, or `conflict` when a pinned prior output is now absent), validates
   the capture in `agent-output` mode against the invocation and exits 0 only when the
   output set is valid and the result is `pass`; it mints nothing and writes nothing. The
   gateway client then checks, in order, the trusted identity against the record
   (`FINALIZATION_INVOCATION_MISSING`, `FINALIZATION_INVOCATION_STATE`,
   `FINALIZATION_IDENTITY`), the gate mode (`FINALIZATION_GATE`), that the result is the
   authoritative `finalize-agent` result (`FINALIZATION_RESULT_FORGED`,
   `FINALIZATION_RUNTIME_DRIFT`), the current activation binding
   (`FINALIZATION_WORKSPACE_CHANGED`), the required outputs against the reported artifacts
   (`FINALIZATION_OUTPUT_MISSING`, `FINALIZATION_OUTPUT_MISMATCH`,
   `FINALIZATION_OUTPUT_UNEXPECTED`), the request shape (`FINALIZATION_REQUEST_INVALID`),
   and the recomputed inputs (`FINALIZATION_RECEIPT_STALE`); only then does it create the
   `agent-output` `validation-receipt` exclusively under the invocation's `receipts/` and
   move the invocation to `finalized`.
6. **Stop.** The stop validation accepts the invocation with that receipt and `output_valid`
   true. An input edited after the receipt is minted blocks the stop with
   `DISCOVERY_ARTIFACT_GATE_BLOCKED: inputs changed after the completion receipt: edited:<path>`.

The stored output manifest is a host-protected record created at prepare time, so an exact
output set is valid without a workspace copy of it; a row that does declare a stored copy is
held to the protected record byte for byte (`OUTPUT_MANIFEST`).

## Capability probe

The probe assumes nothing about what a host places in its hook payloads. A
`discovery-capability-sentinel` agent is launched in the session under test; it calls the
`discovery_capability_sentinel` MCP tool and runs one harmless forbidden shell command. The
tool gate handles both calls as it handles any PreToolUse and records each as a
`host-observation` under the session's `observations/` partition. The sentinel tool consumes
its one-use sentinel grant by writing the exclusive `.consumed` latch beside the observation
and reports whether the host attributed the call to the sentinel agent; the observation record
itself is never rewritten, the probe proves consumption from that latch (present and naming the
same `observation_ref`), and the tool grants nothing and never fails the call.
`discovery-capability-probe.ps1` then
reads the registration and handler hashes and derives the status from the observations:
`supported` requires an attributed sentinel tool observation and an attributed denial of the
forbidden command, each recorded by the current handler hash inside the attestation window;
anything less is `unsupported` with a `DISCOVERY_ENFORCEMENT_UNAVAILABLE` finding. A
session without observations, including the default probe session, is `unsupported`. The
probe makes no in-process sentinel decision and exports no identity.

| Host | Support |
|---|---|
| Claude Code | observed per session: `supported` once the sentinel ran in that session and both observations carry its `agent_id` |
| Copilot harness | observed per session, the same two observations under `.github/hooks` |
| Codex | observed per session; `unsupported` when the PreToolUse payload carries no `agent_id`, because no observation can then be attributed |
| VS Code legacy Local harness | `unsupported`: its PreToolUse carries no agent identity |

## Inactive compatibility

A workspace without an activation, or with a deliberate deactivation, is inactive. Every
discovery hook then allows the call and produces no output, so the host's existing gates
(dangerous-command validation, completion markers, epic and routing attestations) apply
unchanged. Ordinary and epic agents are never discovery specialists, and the planning gate
admits planner and orchestrator launches in inactive workspaces exactly as before. Hook
dependency failures and malformed envelopes deny with the control's prefix; inactivity is
decided only from the protected store.

## The planning prerequisite

`completion_gates.planning_prerequisite` in the profile selects which receipt satisfies the
planning gate: `discovery-complete` (default) requires a passing discovery-complete
validation, `parity-complete` requires the parity gates as well, and `none` admits planning
without a discovery receipt while still requiring the activation to be current. A planning
receipt is produced by `validate-all --mode planning` through the gateway; a structural,
agent-output, completion-mode or version 1 receipt, a failing or stale receipt, and a
missing, disabled or malformed locator or profile all deny. The gate links the discovery
criteria to planning without asserting any implementation passes: a planner may start once
the criteria are current, and the plan's own tests decide implementation outcomes.

## Registration

- Claude Code: `.claude/settings.json` registers the start hook under `SubagentStart` for the
  four roles, the tool gate under `PreToolUse` for `Bash|Write|Edit|MultiEdit|NotebookEdit|
  Agent|Task|WebFetch|WebSearch|mcp__.*`, the planning gate on `Agent`, and the stop
  validation in a dedicated `SubagentStop` group for the four roles.
- Codex: `.codex/config.toml` extends the start and stop matchers with the four role
  families (including the `-c` variants) and registers the tool gate and planning gate on the
  broad and spawn PreToolUse groups.
- GitHub Copilot: `.github/hooks/discovery.json` registers the four handlers for the local
  harness.

`Test-DiscoveryHostCapability.ps1` and `run_discovery_doctor` report whether the host in
front of you actually provides these controls, from the observations of `## Capability
probe`; a host that does not is `unsupported`, and discovery roles must not be launched
there. Doctor itself is a root call: with a root grant it reports the session's capability
from the protected attestation, and without one it answers `context-missing` and
`unsupported` rather than refusing.
