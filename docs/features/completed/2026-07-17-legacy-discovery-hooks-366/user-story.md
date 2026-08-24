# `2026-07-17-legacy-discovery-hooks` — User Story

- Issue: #366
- Owner: drmoisan
- Status: Draft
- Last Updated: 2026-07-17

## Story Statement

- As the maintainer of a consumer repository running the legacy-discovery-and-parity
  workflow, I want completion-gate hooks that block progression when a required
  discovery artifact is absent, malformed, or non-conforming, so that discovery
  and parity work cannot silently advance on top of invalid data.
- As a Claude Code subagent authoring or editing a discovery artifact
  (domain profile, feature contract, coverage ledger, runtime scenario,
  parity matrix, unspecified-behavior record, product-decision record, or
  evidence reference), I want immediate, specific feedback when my write does
  not conform to the artifact's schema, so that I can correct it before the
  surrounding task or turn completes.

## Problem / Why

The legacy-discovery-and-parity epic delivers a domain-neutral discovery and
parity-definition capability. Consumer repositories produce discovery
artifacts (a domain profile plus seven versioned JSON-schema-governed
artifacts) whose conformance is checked by the deterministic validators
delivered in feature legacy-discovery-validators (#361 / manifest #9003).
Without completion-gate hooks that invoke those validators at the appropriate
Claude Code lifecycle events, no runtime gate blocks progression when a
required discovery artifact is absent, malformed, or non-conforming. This
feature supplies those PowerShell completion-gate hooks.

## Personas & Scenarios

- **Persona: Discovery-workflow subagent (a Claude Code agent authoring
  discovery artifacts, e.g. `task-researcher` or a future #9007 persona).**
  - Who: an agent instance operating inside a consumer repository's discovery
    workspace, writing or editing one of the eight discovery-artifact types.
  - Cares about: producing artifacts that conform to their governing JSON
    schema on the first attempt, and receiving a specific, actionable reason
    when a write is rejected rather than a generic failure.
  - Constraints: has no direct visibility into whether the validator CLI is
    available or how strict a given artifact type's schema is; relies on the
    hook's decision message to convey validator output verbatim.
  - Goals and frustrations: wants to complete its assigned discovery task
    without producing artifacts that later block a SubagentStop gate or a
    downstream analyzer; is frustrated by silent acceptance of invalid data
    that only surfaces as a failure much later.
  - Context and motivations: operates under the epic's domain-neutral
    framework; the domain profile (when present) determines which artifact
    types are required for the current gate.

- **Persona: Repository maintainer / epic integrator (e.g. drmoisan).**
  - Who: the person responsible for the epic's integration branch and for
    consumer repositories (TaskMaster, TMW) adopting the discovery workflow.
  - Cares about: that the discovery-and-parity capability enforces its own
    completion gates automatically, without requiring manual review of every
    artifact write.
  - Constraints: the hooks must remain domain-neutral so the same
    `.claude/` assets are reusable across TaskMaster, TMW, and any future
    consumer repository.
  - Goals and frustrations: wants confidence that a discovery workspace
    cannot silently drift into an invalid state; is concerned about
    premature coupling to unshipped dependencies (#9001 domain profile,
    #9002 schema-versioning convention) blocking this feature's delivery.
  - Context and motivations: this feature is a Wave 2 child of the epic,
    depending only on the validators (#361 / #9003); the domain-profile and
    schema-versioning conventions are explicitly allowed to land later
    behind fail-open seams.

- **Scenario: PreToolUse denial on a non-conforming `Write`.**
  - Who is acting: a discovery-workflow subagent.
  - What triggered the action: the subagent calls the `Write` tool to create
    or overwrite a coverage-ledger artifact file inside the discovery
    workspace.
  - What steps do they take: the subagent supplies `file_path` and `content`
    for the write; the PreToolUse hook `enforce-discovery-artifact-gate.ps1`
    reads `$env:CLAUDE_TOOL_INPUT`, recognizes the path as a coverage-ledger
    artifact, and invokes `Invoke-DiscoveryValidatorExe` with the
    `coverage-ledger` subcommand and the artifact path.
  - What obstacles or decisions occur: the validator returns a non-zero exit
    code with one or more stderr lines describing the schema violation; the
    hook maps this to `permissionDecision = 'deny'` with
    `permissionDecisionReason` set to `DISCOVERY_ARTIFACT_GATE_BLOCKED:`
    followed by the validator's message text.
  - What outcome do they expect: the `Write` tool call is denied before the
    file is modified; the subagent receives the specific validation failure
    and can correct the content before retrying.

- **Scenario: SubagentStop block on a stale non-conforming artifact.**
  - Who is acting: a subagent whose turn is ending after performing several
    tool calls, at least one of which touched a discovery artifact through a
    path other than `Write`/`Edit` (for example a `Bash` command that
    generated a JSON file).
  - What triggered the action: the subagent's turn reaches its terminal
    state and the SubagentStop lifecycle event fires.
  - What steps do they take: `validate-discovery-artifact-gate.ps1` reads
    `$env:CLAUDE_HOOK_INPUT`, inspects the subagent's final output for
    references to discovery-artifact paths, and invokes
    `Invoke-DiscoveryValidatorExe` for each recognized reference.
  - What obstacles or decisions occur: one referenced artifact fails
    validation; the hook writes an error with the
    `DISCOVERY_ARTIFACT_GATE_BLOCKED:`-prefixed validator message and exits
    with a non-zero code.
  - What outcome do they expect: the subagent's termination is blocked, and
    the calling orchestration surfaces the validator's specific failure
    reason so remediation can proceed, rather than allowing an invalid
    artifact to propagate into downstream discovery or parity work.

- **Scenario: fail-open behavior before the domain profile ships.**
  - Who is acting: a discovery-workflow subagent in a consumer repository
    that has not yet authored a domain profile (#9001 not yet adopted).
  - What triggered the action: the subagent writes a file inside what will
    eventually be the discovery workspace.
  - What steps do they take: the PreToolUse hook attempts to resolve the
    required-artifact declaration through its `RequiredArtifactPathsReader`
    seam and finds no domain profile present.
  - What obstacles or decisions occur: per the documented fail-open default,
    the hook allows the write without invoking the validator.
  - What outcome do they expect: the hook is structurally registered and
    functionally inert until the domain profile ships, so registering these
    hooks does not block any workflow in a repository that has not yet
    adopted the discovery-and-parity capability.

## Acceptance Criteria

- [x] One or more PowerShell completion-gate hooks enforce discovery-artifact completion gates by invoking the discovery validators.
- [x] Hooks follow canonical PreToolUse/SubagentStop I/O conventions and the dot-source guard.
- [x] Hooks are registered in `.claude/settings.json` under the appropriate event with the standard command form.
- [x] Hooks are domain-neutral (no domain-specific identifiers in source, comments, or messages).
- [x] Pester tests are mirrored at `tests/scripts/claude-hooks/<name>.Tests.ps1`.

## Non-Goals

- Implementing or designing the discovery validators (legacy-discovery-validators,
  #361 / #9003). Those validators are delivered by a separate, already-prepared
  feature; this feature only invokes them.
- Mirroring the new `.claude/` hook assets into `resources/`. That is deferred
  to the cross-ecosystem publishing feature (legacy-discovery-publishing,
  #9012), which depends on this feature (#9004).
- Building a portable PowerShell fallback that reimplements discovery
  validator logic for consumer repositories that lack `scripts/dev_tools`.
  Any such capability-detection/fallback path is out of scope and, if needed
  later, is a follow-up owned by #9012, not this feature.
- Finalizing the domain-profile configuration contract (#9001) or the
  schema-versioning convention (#9002). Both are separate features; this
  feature isolates its dependency on each behind narrow, documented seams
  (`# TODO(#9001)`, `# TODO(#9002)`) that fail open when the upstream
  convention is not yet present.
- Naming or hardcoding #9007's not-yet-shipped generic agent personas in the
  SubagentStop hook's matcher configuration.
