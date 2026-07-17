# 2026-07-17-legacy-discovery-hooks — Spec

- **Issue:** #366
- **Parent (optional):** legacy-discovery-and-parity (epic; manifest placeholder #9004)
- **Owner:** drmoisan
- **Last Updated:** 2026-07-17
- **Status:** Draft
- **Version:** 0.2

## Overview

The legacy-discovery-and-parity epic delivers a domain-neutral discovery and
parity-definition capability. Consumer repositories produce discovery
artifacts (a domain profile plus seven versioned JSON-schema-governed
artifacts) whose conformance is checked by the deterministic validators
delivered in feature legacy-discovery-validators (#361 / manifest #9003).
Without completion-gate hooks that invoke those validators at the appropriate
Claude Code lifecycle events, no runtime gate blocks progression when a
required discovery artifact is absent, malformed, or non-conforming. This
feature supplies those PowerShell completion-gate hooks.

This feature is a Wave 2 child of the epic (manifest #9004) and depends only
on legacy-discovery-validators (#361 / #9003). It does not depend on the
domain-profile config contract (#9001) or the schema set (#9002) directly;
those dependencies are already validator-internal, and this feature's hooks
depend on the validator CLI surface rather than on #9001/#9002 directly. Where
#9001 or #9002 conventions are not yet finalized in this branch, this spec
records an explicit open seam (see Constraints & Risks) rather than assuming a
shape for either.

## Behavior

Provide PowerShell completion-gate hooks that enforce discovery-artifact
completion gates by invoking the discovery validators (never reimplementing
validation logic). The hooks follow the repository's canonical hook
conventions (PreToolUse and/or SubagentStop I/O, dot-source guard, JSON
decision payloads) and are registered in `.claude/settings.json` under the
appropriate event with the standard
`{"type":"command","command":"pwsh -NoProfile -File .claude/hooks/<name>.ps1"}`
form. Gate behavior is driven by the domain profile; the hooks contain no
TaskMaster/TMW/Outlook/VSTO/email/task-management-specific behavior.

Two hooks are provided, matching the repository's established `enforce-`
(PreToolUse, deny) / `validate-` (SubagentStop, block) naming split:

1. **`enforce-discovery-artifact-gate.ps1`** (PreToolUse, `Write|Edit`
   matcher). Denies a `Write` or `Edit` tool call that would leave a
   recognized discovery artifact non-conforming, per the validator's
   determination. Provides early, per-write feedback at the point of
   authoring.
2. **`validate-discovery-artifact-gate.ps1`** (SubagentStop, existing broad
   generic-agent matcher). Blocks a subagent's termination when the
   subagent's final output references a discovery-artifact path that fails
   validation. Provides the authoritative, defense-in-depth check of final
   workspace state, regardless of which tool produced the artifact.

Both events are registered because each individually is insufficient: a
PreToolUse-only gate cannot catch artifacts written by non-`Write`/`Edit`
tools (for example a `Bash` command writing JSON) or pre-existing
non-conforming state; a SubagentStop-only gate forfeits early, precise
per-write feedback. This mirrors the existing two-layer pattern
(`enforce-completion-consistency.ps1` + `validate-orchestrator-output.ps1`)
and matches the epic mandate's own phrasing, "PreToolUse and/or SubagentStop
hooks" (`objective-source.md`, section 6).

## Inputs / Outputs

### `enforce-discovery-artifact-gate.ps1` (PreToolUse)

- **Input:** `$env:CLAUDE_TOOL_INPUT` — JSON containing `file_path` and either
  `content` (`Write`) or `old_string`/`new_string` (`Edit`).
- **Output (allow or deny decision):** an `[ordered]` hashtable shaped
  `{ hookSpecificOutput: { hookEventName: 'PreToolUse', permissionDecision: 'allow'|'deny', permissionDecisionReason: '<CODE>: ...' } }`,
  serialized with `ConvertTo-Json -Compress -Depth 5` to stdout, then `exit 0`.
  The deny reason uses the prefix `DISCOVERY_ARTIFACT_GATE_BLOCKED:` followed
  by the trimmed validator output, mirroring the
  `COMPLETION_CONSISTENCY_BLOCKED:` / `ROUTING_CONTRACT_BLOCKED:` convention
  used by existing `enforce-*` hooks.
- **Malformed-input output:** `Write-Error $_; exit 1`.
- **No-match output:** when `file_path` does not resolve to a recognized
  discovery-artifact type, or the domain-profile required-artifact
  declaration is absent, the decision is `allow` and the validator is never
  invoked.

### `validate-discovery-artifact-gate.ps1` (SubagentStop)

- **Input:** `$env:CLAUDE_HOOK_INPUT` — JSON containing `.output` (the
  terminating subagent's final text).
- **Output (block or allow decision):** `Write-Error <message>; exit 1` when a
  referenced discovery artifact fails validation; `exit 0` otherwise. The
  block message uses the same `DISCOVERY_ARTIFACT_GATE_BLOCKED:` prefix.
- **Malformed/empty-input output:** `Write-Error "CLAUDE_HOOK_INPUT is empty"` (or
  equivalent malformed-JSON message); `exit 1`.

### Config keys and defaults

- No new config keys are introduced by this feature. The required-artifact
  declaration and discovery-workspace root are read through the
  `# TODO(#9001)` seam (see Constraints & Risks); no key name or file
  location is finalized here.

### Versioning / backward-compatibility constraints

- Both hooks are additive: registering them in `.claude/settings.json` does
  not change behavior for any tool call or subagent that does not touch a
  discovery artifact.
- With no domain profile present in a consumer repository, both hooks are
  structurally registered but functionally inert (always allow), matching the
  epic's staged-capability-rollout pattern.

## API / CLI Surface

### Wrapper function (identical shape in both hook files)

```powershell
function Invoke-DiscoveryValidatorExe {
    [CmdletBinding()]
    [OutputType([hashtable])]
    param(
        [Parameter(Mandatory = $true)]
        [string[]] $ValidatorArgs
    )

    $output = & python -m scripts.dev_tools.validate_discovery_artifacts @ValidatorArgs 2>&1
    return @{ ExitCode = $LASTEXITCODE; Output = ($output | Out-String).Trim() }
}
```

This is the wrapper-function seam (`.claude/rules/powershell.md`, Design
Seams option 1, "preferred"), modeled on `Invoke-GitExe`
(`scripts/dev-tools/bootstrap-host.helpers.ps1`). Pester mocks this function
directly; production tests must never mock `python`.

### Validator invocation form (dependency: legacy-discovery-validators, #361 / #9003)

- Umbrella CLI: `python -m scripts.dev_tools.validate_discovery_artifacts <artifact-type> <path>`
  where `<artifact-type>` is one of
  `profile | feature-contract | coverage-ledger | runtime-scenario | parity-matrix | unspecified-behavior | product-decision | evidence-reference | all`.
  Poetry console-script entries under `dev.discovery.validate-*` expose the
  same subcommands.
- Exit 0, single stdout success line: conforming.
- Exit 1, one stderr error line per finding: non-conforming.
- Pure functions `validate_<artifact>_text(text) -> list[str]` back each
  subcommand (validator-owned; this feature calls the CLI, not the Python
  functions directly).

### Decision functions (thin-entrypoint pattern)

- PreToolUse: `Invoke-DiscoveryArtifactGateDecision` — returns the ordered
  decision hashtable described in Inputs/Outputs; the file's bottom-of-file
  entrypoint block is the only code touching `$env:`, `ConvertTo-Json`, or
  `exit`.
- SubagentStop: `Invoke-DiscoveryArtifactGateValidation` — returns an
  `{ Ok; Message }` hashtable; the entrypoint maps `Ok = $false` to
  `Write-Error $Message; exit 1` and `Ok = $true` to `exit 0`.
- Both files use the dot-source guard
  `if ($MyInvocation.InvocationName -eq '.') { return }` immediately before
  the entrypoint call, so Pester can dot-source the file and exercise the
  decision functions directly without invoking `exit`.

### Example invocations (concise)

- Conforming: `python -m scripts.dev_tools.validate_discovery_artifacts coverage-ledger discovery/coverage-ledger.json` → exit 0, one stdout line.
- Non-conforming: same command → exit 1, one or more stderr lines (each
  captured into `Output` via `2>&1` and surfaced verbatim in the block
  reason).

## Data & State

- **State model:** both hooks are stateless. No `.claude/state/*.<session_id>.json`
  file is read or written. Each invocation is a pure function of
  (tool/hook input JSON, on-disk artifact content, domain-profile
  required-artifact declaration if present) to (allow/deny decision, or
  exit-code plus message).
- **Data transformations and invariants:** no data is transformed or stored by
  this feature; it only routes existing on-disk artifact content to the
  validator CLI and maps the CLI's exit code/output to a hook decision.
- **Caching or persistence:** none.
- **Migration or backfill requirements:** none.

## Constraints & Risks

- **Dependency on legacy-discovery-validators (#361 / #9003).** The hooks
  invoke `dev.discovery.validate-*` / `scripts.dev_tools.validate_discovery_artifacts`
  and do not implement validators. This feature's tests mock
  `Invoke-DiscoveryValidatorExe`; they do not depend on the validator's
  internal behavior beyond the exit-code/stdout/stderr contract stated above.
- **Open seam `# TODO(#9002)` — artifact-type lookup.** `Get-DiscoveryArtifactType -Path <string>`
  maps a normalized file path to one of the eight validator subcommand
  tokens. The exact schema-versioned directory/filename convention this
  mapping depends on is owned by #9002 and is not finalized in this branch.
  The mapping function's body carries an explicit `# TODO(#9002)` comment and
  a narrow, replaceable lookup implementation.
- **Open seam `# TODO(#9001)` — domain-profile-driven required-artifact declaration.**
  The discovery-workspace root and which of the eight artifact types are
  "required" for a given gate are domain-profile runtime configuration owned
  by #9001, which has no shipped parser/schema in this branch. This is
  implemented as a single narrow injectable `RequiredArtifactPathsReader`
  seam (scriptblock or equivalent) with a documented `# TODO(#9001)` comment.
  The seam **fails open (allow)** when the domain profile or the
  required-artifact declaration is absent, matching the repository's
  established backward-compatible, additive pattern (see
  `.claude/rules/orchestrator-state.md` "Scope and Backward Compatibility"
  clauses and the allow-on-no-match default used by every hook in
  `.claude/hooks/`).
- **Domain neutrality is an epic invariant.** No TaskMaster/TMW/Outlook/VSTO/
  email/task-management identifier may appear in hook source, comments, or
  emitted messages (`permissionDecisionReason`, `Write-Error` text). The
  static artifact-type lookup (#9002 seam) names only schema-kind tokens,
  never domain terms.
- **No capability-detection/portable-fallback path.** This feature does not
  build a dual-path capability probe plus a portable PowerShell
  reimplementation of validator logic (the pattern used by
  `validate-orchestrator-output.ps1`'s `Invoke-RoutingContractValidation`).
  Building such a fallback for the discovery validators would require
  reimplementing validation logic in PowerShell, which directly conflicts
  with this feature's scope boundary ("do NOT implement or design the
  validators"). The hooks assume `scripts.dev_tools.validate_discovery_artifacts`
  is importable in the execution context. A standalone-execution fallback for
  consumer repositories without `scripts/dev_tools` is deferred to the
  publishing feature (#9012), not addressed here.
- **Out of scope (explicit).**
  - Implementing or designing the discovery validators (#361 / #9003) — a
    separate, already-prepared feature.
  - Mirroring `.claude/` assets (including these two hook files) into
    `resources/` — deferred to the publishing feature (#9012).
  - Building a portable PowerShell fallback that reimplements validator
    logic for consumer repositories without `scripts/dev_tools`.
  - Naming #9007's not-yet-shipped generic agent personas in the
    SubagentStop matcher; the SubagentStop hook registers under the existing
    broad, already-shipped generic-agent matcher group and decides,
    content-first, whether the terminating agent's output references a
    discovery-artifact path.
- **File-count / change budget.** Two production `.ps1` files
  (`enforce-discovery-artifact-gate.ps1`, `validate-discovery-artifact-gate.ps1`),
  each carrying its own copy of the ~10-line `Invoke-DiscoveryValidatorExe`
  wrapper. This stays within the direct-mode cap of "up to 2 production
  PowerShell files" in `.claude/rules/powershell.md`, avoiding the need for a
  third shared helper file that would otherwise route this work through
  `powershell-change-budget-router`.

## Implementation Strategy

- **Implementation scope (what changes):**
  - Add `.claude/hooks/enforce-discovery-artifact-gate.ps1` (PreToolUse).
  - Add `.claude/hooks/validate-discovery-artifact-gate.ps1` (SubagentStop).
  - Register `enforce-discovery-artifact-gate.ps1` in `.claude/settings.json`
    under the existing `PreToolUse` → `"Write|Edit"` matcher group, alongside
    `enforce-evidence-locations.ps1`, `enforce-completion-consistency.ps1`,
    `enforce-checkpoint-monotonic.ps1`, and `enforce-feature-folder-order.ps1`,
    using the standard command form
    `{"type":"command","command":"pwsh -NoProfile -File .claude/hooks/enforce-discovery-artifact-gate.ps1"}`.
  - Register `validate-discovery-artifact-gate.ps1` in `.claude/settings.json`
    under the existing broad, already-shipped generic-agent `SubagentStop`
    matcher group, using the analogous standard command form.
  - Add mirrored Pester test files
    `tests/scripts/claude-hooks/enforce-discovery-artifact-gate.Tests.ps1` and
    `tests/scripts/claude-hooks/validate-discovery-artifact-gate.Tests.ps1`.
- **New functions to add:**
  - `Invoke-DiscoveryValidatorExe -ValidatorArgs <string[]>` (duplicated in
    both hook files per the change-budget decision above).
  - `Get-DiscoveryArtifactType -Path <string>` (`# TODO(#9002)` seam).
  - A `RequiredArtifactPathsReader`-shaped seam for the domain-profile
    required-artifact declaration (`# TODO(#9001)` seam), defaulting to
    fail-open (allow) when absent.
  - `Invoke-DiscoveryArtifactGateDecision` (PreToolUse decision function).
  - `Invoke-DiscoveryArtifactGateValidation` (SubagentStop decision function).
- **Dependency changes:** none. No new package is added; the feature calls an
  existing (dependency-delivered) Python module via `python -m`.
- **Logging/telemetry additions:** none beyond the existing
  `permissionDecisionReason` / `Write-Error` decision-message convention;
  no new logging destination is introduced.
- **Rollout plan:** additive registration in `.claude/settings.json`. No
  feature flag is introduced; the fail-open default on an absent domain
  profile is the staged-rollout mechanism (see Constraints & Risks). No
  fallback path is required per the "no capability-detection/portable
  fallback" decision above.

## Definition of Done

- [ ] Acceptance criteria documented and mapped to tests or demos
- [ ] Behavior matches acceptance criteria in all documented environments
- [ ] Tests updated/added (unit/integration as applicable)
- [ ] Edge cases and error handling covered by tests
- [ ] Docs updated (README, docs/features/active/... links)
- [ ] Telemetry/logging added or updated (if applicable)
- [ ] Toolchain pass completed (format → lint → test, per `.claude/rules/powershell.md`)

## Acceptance Criteria

Traced 1:1 to `issue.md`'s Acceptance Criteria and mapped to the design
elements above:

- [ ] One or more PowerShell completion-gate hooks enforce discovery-artifact
  completion gates by invoking the discovery validators. — Design:
  `enforce-discovery-artifact-gate.ps1` (PreToolUse) and
  `validate-discovery-artifact-gate.ps1` (SubagentStop), both calling
  `Invoke-DiscoveryValidatorExe` → `python -m scripts.dev_tools.validate_discovery_artifacts <type> <path>`.
- [ ] Hooks follow canonical PreToolUse/SubagentStop I/O conventions and the
  dot-source guard. — Design: Inputs/Outputs section above; dot-source guard
  `if ($MyInvocation.InvocationName -eq '.') { return }`; thin-entrypoint
  decision functions `Invoke-DiscoveryArtifactGateDecision` /
  `Invoke-DiscoveryArtifactGateValidation`.
- [ ] Hooks are registered in `.claude/settings.json` under the appropriate
  event with the standard command form. — Design: Implementation Strategy —
  register under the existing `"Write|Edit"` PreToolUse matcher group and the
  existing broad generic-agent `SubagentStop` matcher group, not a new
  agent-specific matcher.
- [ ] Hooks are domain-neutral (no domain-specific identifiers in source,
  comments, or messages). — Design: Constraints & Risks — static artifact-type
  lookup names only schema-kind tokens; domain-profile seam is a narrow
  injectable reader with a `# TODO(#9001)` marker; domain-neutrality grep test
  (Seeded Test Conditions).
- [ ] Pester tests are mirrored at `tests/scripts/claude-hooks/<name>.Tests.ps1`.
  — Design: `tests/scripts/claude-hooks/enforce-discovery-artifact-gate.Tests.ps1`,
  `tests/scripts/claude-hooks/validate-discovery-artifact-gate.Tests.ps1`.

## Seeded Test Conditions (from potential)

- [ ] Allow when the recognized discovery artifact is present and conforming
  (`Invoke-DiscoveryValidatorExe` returns `ExitCode = 0`).
- [ ] Deny/block when a required discovery artifact is absent or
  non-conforming (`Invoke-DiscoveryValidatorExe` returns a non-zero exit code
  with non-empty `Output`; the validator's text is embedded verbatim in the
  decision message).
- [ ] No-op / allow-without-invoking-the-validator when `file_path` (or
  subagent output) does not match any recognized discovery-artifact type
  (assert the wrapper mock is never called).
- [ ] Fail-open (allow) when the domain profile or the required-artifact
  declaration is absent (dedicated regression test for the `# TODO(#9001)`
  seam's default).
- [ ] Hard failure on malformed `CLAUDE_TOOL_INPUT` / `CLAUDE_HOOK_INPUT` JSON
  (`Write-Error`, `exit 1`), and on an empty/absent env var per each event's
  documented convention (default-allow for PreToolUse; hard failure with an
  explicit "empty" message for SubagentStop).
- [ ] Validator-executable/module-not-found is treated identically to any
  other non-conforming result (deny/block), not silently allowed — a
  dedicated test simulating a module-not-found-style non-zero exit.
- [ ] `Edit`-tool partial-patch input (PreToolUse only): `Edit` calls supply
  only `old_string`/`new_string`, not full file content. The initial
  implementation allows `Edit` calls unconditionally and relies on the
  SubagentStop gate as the authoritative backstop; this design choice is
  covered by an explicit test.
- [ ] Domain-neutrality grep gate: a Pester `It` block reads each new hook's
  own source text and asserts it contains none of the epic's forbidden
  domain tokens (`TaskMaster`, `TMW`, `Outlook`, `VSTO`, task-management-
  specific terms).
