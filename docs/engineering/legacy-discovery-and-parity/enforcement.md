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
| Start attestation | Agent start (Claude `SubagentStart`; Codex routing attestation; Copilot `discovery-agent-start.ps1`) | Exactly one `prepared` discovery invocation bound to this host, session, parent and agent type, with matching activation, deployment, agent-profile hash and capability pins; the launcher is not itself a specialist. Records the start attestation and moves the invocation to `started`. | `DISCOVERY_START_ATTESTATION_BLOCKED:` |
| Tool gate | Every tool call (`PreToolUse`) | A started invocation for the calling specialist; read-only native tools and controlled discovery MCP tools only; shell, exec, evaluation, generic Write/Edit/apply_patch, nested agents, foreign MCP servers, root-only operations and caller-supplied identity fields are denied. An admitted call is recorded as a one-use `tool-authorization` the gateway consumes exactly once. | `DISCOVERY_ARTIFACT_GATE_BLOCKED:` |
| Planning gate | Planner or orchestrator delegation (`PreToolUse` on the Agent tool) | In an active workspace: the activated locator and profile are present with their activated bytes, and the session holds a current, passing, gateway-written `planning`-mode receipt for this host whose inputs are unchanged and whose manifest reflects the profile's `planning_prerequisite`. | `DISCOVERY_PLANNING_GATE_BLOCKED:` |
| Stop validation | Agent stop (`SubagentStop`) | The invocation was finalized through the gateway; the receipt is the `agent-output` validation receipt for this invocation, session, role and gate mode, bound to the current activation and workspace, with every required output present, every input unchanged and `output_valid` true. The coverage reviewer may stop on a valid failing report. | `DISCOVERY_ARTIFACT_GATE_BLOCKED:` |
| Capability probe | Operator or doctor (not an event) | The registered handlers and their current hashes, the configuration hash, trusted attribution and a harmless forbidden sentinel the tool gate must deny. Produces a `capability-attestation`; `supported` only when every control is observed. | exit 1 when unsupported |

These are the only controls represented as native. Instruction-only restrictions in a role's
prose are not treated as enforcement, and no host-specific mechanism (for example a Write
grant) substitutes for a control.

## Protected records

The store at the platform state root holds, per workspace:

- `activation.json`: the root-owned activation bound to the workspace, the profile and
  locator digests and `required_runtime_major`; a deactivation is a tombstone.
- `sessions/<sha>/invocations/<sha>/invocation.json`: each `discovery-invocation` with its
  role, skill, operation, gate mode, selected identities and paths, input digests, runtime
  and deployment pins, required outputs and `state` (`prepared`, `started`, `finalized`,
  `revoked`); `start-attestation.json`, `receipts/` and `authorizations/` beside it.
- `sessions/<sha>/receipts/`: the root session's `validation-receipt` records per mode.
- `capability-attestation.json`: the session's host observation with `expires_at`.

Every record carries the digests of what it binds; a hook that finds a changed byte,
a missing record, an ambiguous pair or an expired attestation denies.

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
front of you actually provides these controls; a host that does not is `unsupported`, and
discovery roles must not be launched there.
