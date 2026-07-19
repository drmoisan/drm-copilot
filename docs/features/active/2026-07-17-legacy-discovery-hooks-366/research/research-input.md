# legacy-discovery-hooks (#366) — Research Input

- Feature folder: `docs/features/active/2026-07-17-legacy-discovery-hooks-366/`
- Epic: `legacy-discovery-and-parity` (manifest placeholder #9004), depends on `legacy-discovery-validators` (#361 / manifest #9003)
- Scope boundary: PowerShell completion-gate hooks that **invoke** the discovery validators. Do not implement or design validators. Core framework must remain domain-neutral (no TaskMaster/TMW/Outlook/VSTO/email/task-management identifiers).
- Author: task-researcher
- Prepared: 2026-07-17

## Note on evidence access

The upstream validator contract lives on sibling branch/worktree
`worktree-agent-a6050de5b405bd1fe` at
`docs/features/active/2026-07-17-legacy-discovery-validators-361/spec.md`. This
agent's tool set for this session does not include a shell/`git` execution
tool, and no local worktree checkout of that branch exists on disk (confirmed:
`Glob` for `**/legacy-discovery-validators-361/**` and for any
`agent-a6050de5b405bd1fe*` worktree directory returned no matches). The
validator-contract facts below are therefore taken as given by the delegation
prompt and cross-checked against two independently authored local artifacts
that restate the same contract: this feature's own `spec.md` and `issue.md`
(both state: "the hooks invoke `dev.discovery.validate-*` /
`scripts.dev_tools.validate_discovery_artifacts` and do not implement
validators") and `docs/features/epics/legacy-discovery-and-parity/epic.md`
("Validator pattern" bullet, lines 111-113: "#9003 and all validators follow
the canonical `validate_<artifact>_text(text, ...) -> list[str]` contract with
an argparse subparser CLI, mirroring `validate_orchestration_artifacts.py`").
No independent byte-for-byte read of the sibling branch's `spec.md` was
possible in this session; a future agent with `git`/Bash access should verify
the exact subcommand list and CLI invocation form directly against that file
before implementation.

## 1. Current State Analysis

### 1.1 Canonical hook I/O conventions (verified by direct read)

- Every `.claude/hooks/*.ps1` file uses the dot-source guard
  `if ($MyInvocation.InvocationName -eq '.') { return }` immediately before
  the process-exit call, so Pester can dot-source the file and call its
  functions without running the entrypoint. Verified at
  `.claude/hooks/enforce-evidence-locations.ps1:176-180`,
  `.claude/hooks/enforce-completion-consistency.ps1:401-416`,
  `.claude/hooks/enforce-orchestration-preimplementation-gate.ps1:213-225`,
  `.claude/hooks/validate-orchestrator-output.ps1:331-342`,
  `.claude/hooks/validate-feature-review-coverage.ps1:449-459`.
- **PreToolUse** hooks read `$env:CLAUDE_TOOL_INPUT` (JSON with `file_path`,
  `content`, `old_string`/`new_string`, or `command`), return an
  `[ordered]` hashtable shaped
  `{ hookSpecificOutput: { hookEventName: 'PreToolUse', permissionDecision: 'allow'|'deny', permissionDecisionReason: '<CODE>: ...' } }`,
  serialize it with `ConvertTo-Json -Compress -Depth 5`, and `exit 0`. Malformed
  JSON input is a hard failure: `Write-Error $_; exit 1`. Verified at
  `.claude/hooks/enforce-evidence-locations.ps1:107-142,163-180` and
  `.claude/hooks/enforce-completion-consistency.ps1:314-416`.
- **SubagentStop** hooks read `$env:CLAUDE_HOOK_INPUT` (JSON with `.output` =
  the agent's final text), return a `{ Ok; Message }` hashtable internally,
  and the thin entrypoint does `if (-not $result.Ok) { Write-Error $result.Message; exit 1 } else { exit 0 }`.
  Verified at `.claude/hooks/validate-orchestrator-output.ps1:228-329,336-342`
  and `.claude/hooks/validate-feature-review-coverage.ps1:334-459`.
- Both event types follow a **thin-entrypoint pattern**: all decision logic
  lives in a testable function (`Invoke-<X>Decision` / `Invoke-<X>Validation`)
  that returns a plain value; the bottom-of-file entrypoint block is the only
  code that touches `$env:`, calls `exit`, or writes to stdout/stderr. This is
  uniform across every hook read in this session.
- `.claude/settings.json` registers hooks by event and matcher (verified,
  `.claude/settings.json:79-243`):
  - `PreToolUse` has three matcher groups: `"Bash"`, `"Write|Edit"`, `"Agent"`
    (lines 90-185). A new discovery-artifact-write gate belongs in the
    `"Write|Edit"` group (lines 120-160) alongside
    `enforce-evidence-locations.ps1`, `enforce-completion-consistency.ps1`,
    `enforce-checkpoint-monotonic.ps1`, `enforce-feature-folder-order.ps1`.
  - `SubagentStop` has per-agent-regex matcher groups (lines 187-241). One
    broad matcher (line 189) already lists a large, generic set of
    already-shipped agents
    (`atomic-planner|atomic-executor|feature-review|task-researcher|prd-feature|staged-review|epic-review|status-updater|python-typed-engineer|powershell-typed-engineer|csharp-typed-engineer|typescript-engineer|orchestrator|epic-orchestrator|epic-planner`)
    and runs a generic inline completion-artifact-path check (lines 190-195).
    Other entries (`feature-review`, `atomic-planner`, `pr-author`,
    `orchestrator`, `epic-orchestrator`) each register one named `.ps1` file
    (lines 197-241). The command form for both events is
    `{"type":"command","command":"pwsh -NoProfile -File .claude/hooks/<name>.ps1"}`,
    matching the feature's mandated form exactly (`validate-orchestrator-output.ps1`
    for `epic-orchestrator` even passes extra CLI parameters after the file
    path, line 238, confirming the form tolerates trailing flags).

### 1.2 Naming convention (verified by direct read)

Every PreToolUse hook that denies/blocks is named `enforce-*`
(`enforce-evidence-locations.ps1`, `enforce-completion-consistency.ps1`,
`enforce-orchestration-preimplementation-gate.ps1`,
`enforce-checkpoint-monotonic.ps1`, `enforce-feature-folder-order.ps1`).
Every SubagentStop hook that blocks termination is named `validate-*`
(`validate-orchestrator-output.ps1`, `validate-feature-review-coverage.ps1`,
`validate-planner-output.ps1`, `validate-pr-author-output.ps1`,
`validate-executor-output.ps1`). This `enforce-` (PreToolUse) /
`validate-` (SubagentStop) split is a consistent, unbroken naming convention
across all eleven hooks read in this session.

### 1.3 Wrapper-seam precedent for invoking an external validator (verified by direct read)

`.claude/hooks/validate-orchestrator-output.ps1:152-226` defines
`Invoke-RoutingContractValidation`, which delegates to an **injectable
scriptblock** parameter `$Invoker` whose default implementation (lines
182-209):

1. Probes capability via `Test-PythonOrchestratorValidatorAvailable`
   (`.claude/lib/orchestrator-state/OrchestratorState.psm1:334-360`), which
   runs `python -c 'import scripts.dev_tools.validate_orchestration_artifacts'`
   and returns `$true` only on exit 0.
2. When available, shells out:
   `& python -m scripts.dev_tools.validate_orchestration_artifacts $Type $Path --require-complete --require-model-routing 2>&1`,
   captures `$LASTEXITCODE` and the combined output text into a
   `[pscustomobject]@{ ExitCode; Output }`.
3. When unavailable, falls back to a portable PowerShell reimplementation
   (`Test-OrchestratorStateCompletionReadiness` /
   `Test-OrchestratorStatePrCreationReadiness`,
   `OrchestratorState.psm1:362-404,406-470`) that performs the equivalent
   check without Python, for consumer repositories that received only the
   pushed-down `.claude` pack.
4. The caller (`Invoke-RoutingContractValidation`, lines 212-226) maps
   `ExitCode != 0 OR non-empty Output` to `HasErrors = $true`, then the
   outer decision function maps `HasErrors` to a `Write-Error` + `exit 1`
   block reason (lines 316-326).

Pester tests never mock `python`; they inject a stub scriptblock via the
`-RoutingInvoker` parameter (verified at
`tests/scripts/claude-hooks/validate-orchestrator-output.Tests.ps1:160,193,207,214-226,246,344,371`),
which is the "injectable delegate / ScriptBlock seam" option from
`.claude/rules/powershell.md:51` ("only when a wrapper is insufficient").

A second, simpler pattern exists for pure external-tool invocation: a named
wrapper function `Invoke-GitExe -GitArgs <string[]>` that splats into the
executable and throws on non-zero exit (verified at
`scripts/dev-tools/bootstrap-host.helpers.ps1:4-15`), matching
`.claude/rules/powershell.md:47-50` option 1 ("wrapper function seam
(preferred)"). `.claude/hooks/check-powershell-test-purity.ps1:104-108`
enforces that Pester tests mock `Invoke-GitExe`/`Invoke-GhExe`/
`Invoke-ActionlintExe`, never `git`/`gh`/`actionlint` directly.

### 1.4 Feature-scope docs already on disk

`spec.md`, `issue.md`, `user-story.md`, and `plan.2026-07-17T14-38.md` under
this feature folder are unfilled templates (Behavior/Acceptance sections
restate the delegation prompt verbatim; Implementation Plan phases are
placeholder text `<Phase Name>` / `<Atomic task with strong verb>`). They
confirm scope and constraints (validators are out of scope; mirroring to
`resources/` is out of scope, deferred to #9012) but supply no additional
design detail beyond what the delegation prompt already states.

### 1.5 Domain-profile dependency (#9001) status

No `legacy-discovery-config-contract` feature folder exists under
`docs/features/active/` in this worktree (`Glob` for
`docs/features/active/**` returned 226 unrelated files; none reference
`legacy-discovery-config-contract`). #9001 is confirmed not present/finalized
in this branch's working tree, consistent with the task's framing.

## 2. Candidate approaches — which lifecycle event(s)

### Approach A — PreToolUse only

Deny a `Write`/`Edit` that would leave a discovery artifact non-conforming.
Advantage: fast, precise feedback at the point of authoring; matches
`enforce-evidence-locations.ps1` and `enforce-completion-consistency.ps1`.
Limitation: only fires for `Write`/`Edit` tool calls. An artifact created by
`Bash` (e.g. a script that writes JSON), or an artifact that already exists
non-conforming before the current session started, is never checked. Cannot
by itself express "the subagent's turn must not end while a required artifact
is missing."

### Approach B — SubagentStop only

Block a subagent's termination unless required discovery artifacts pass
validation. Advantage: authoritative, defense-in-depth check of final
workspace state regardless of which tool produced the artifact; matches
`validate-orchestrator-output.ps1` and `validate-feature-review-coverage.ps1`.
Limitation: feedback arrives only at end-of-turn, after potentially many
malformed writes; no early denial at the point of authoring.

### Approach C — Both events (recommended)

Register one `enforce-*` PreToolUse hook (Write|Edit matcher) for early,
per-write denial, and one `validate-*` SubagentStop hook for the
end-of-turn authoritative gate. This mirrors the two-layer pattern already
present for the orchestrator checkpoint: `enforce-completion-consistency.ps1`
(PreToolUse, denies a specific bad write) plus
`validate-orchestrator-output.ps1` (SubagentStop, blocks termination). The
epic mandate text itself is phrased as "PreToolUse **and/or** SubagentStop
hooks" (`objective-source.md:84-86`) and "PreToolUse/SubagentStop I/O
conventions" (`epic.md:114-116`), i.e. the epic anticipates both being used
together rather than choosing one exclusively.

**Rejected alternatives summary:** Approach A alone is rejected because it
cannot catch artifacts written by non-Write/Edit tools or pre-existing
non-conforming state. Approach B alone is rejected because it forfeits
early, precise per-write feedback that the existing `enforce-*` precedent
provides cheaply. Approach C is recommended.

## 3. Deterministic, unit-testable validator invocation

**Recommendation:** define a small wrapper function
`Invoke-DiscoveryValidatorExe -ValidatorArgs <string[]>` (wrapper-function
seam, `.claude/rules/powershell.md:47-50`, option 1, "preferred") that
splats into the CLI and returns exit code + captured stderr/stdout, rather
than an injectable scriptblock. Justification: unlike
`Invoke-RoutingContractValidation`, this feature's validator call is a single
fixed invocation shape (no dual-path capability-detection/fallback need — see
§ Design decisions below) and the rule states the wrapper-function seam is
tried first; only escalate to the scriptblock-injection option "when a
wrapper is insufficient" (`powershell.md:51`).

Concrete shape, modeled on `Invoke-GitExe`
(`scripts/dev-tools/bootstrap-host.helpers.ps1:4-15`) and the exit-code/output
capture idiom used by `Invoke-OrchestratorStatePreflight`
(`OrchestratorState.psm1:438-451`):

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

Invocation form (per delegation-prompt contract, cross-checked against
`epic.md:111-113`'s validator-pattern bullet):
`python -m scripts.dev_tools.validate_discovery_artifacts <artifact-type> <path>`.
Exit 0 with a single stdout success line means conforming; exit 1 with
stderr error lines (one per line) means non-conforming. A caller-level
decision function interprets the hashtable:

- `ExitCode -ne 0` (or non-empty captured output when a non-zero exit is
  combined with `2>&1`) → non-conforming.
- PreToolUse mapping: non-conforming → `permissionDecision = 'deny'` with
  `permissionDecisionReason` set to a `DISCOVERY_ARTIFACT_GATE_BLOCKED:`
  prefix plus the trimmed validator output (mirrors
  `Get-EvidenceLocationBlockDecision`,
  `enforce-evidence-locations.ps1:84-105`, and the
  `COMPLETION_CONSISTENCY_BLOCKED:` / `ROUTING_CONTRACT_BLOCKED:` /
  `MODEL_ROUTING_BLOCKED:` prefix convention seen at
  `enforce-completion-consistency.ps1:391` and
  `validate-orchestrator-output.ps1:323,325`).
- SubagentStop mapping: non-conforming → `Write-Error <message>; exit 1`;
  conforming → `exit 0` (mirrors `validate-orchestrator-output.ps1:337-342`).

**Testability:** the wrapper function is mocked directly in Pester
(`Mock Invoke-DiscoveryValidatorExe { @{ ExitCode = 0; Output = '' } }`),
never `python` — this is required by
`.claude/rules/powershell.md:80` ("never mock `git`, `gh`, `actionlint`, or
other executables directly. Mock the wrapper function instead") and by
`.claude/hooks/check-powershell-test-purity.ps1`'s enforced pattern list
(lines 104-108), which will need a discovery-validator-specific entry added
alongside the existing git/gh/actionlint entries if this repo's purity check
is to catch a stray `Mock python` in the new tests (a candidate small
follow-up, not required to satisfy this feature's own tests, but worth
flagging to the atomic planner).

## 4. Domain-profile-driven gate definition without hardcoding domain specifics

Two distinct mapping problems exist and must be separated:

1. **Artifact-type vocabulary (fixed, not domain-profile-driven).** The eight
   validator subcommand tokens
   (`profile | feature-contract | coverage-ledger | runtime-scenario | parity-matrix | unspecified-behavior | product-decision | evidence-reference`)
   are fixed by #9002's schema set and #9003's CLI surface; they are not
   domain specificity, they are the framework's own artifact-kind vocabulary.
   A small, static, domain-neutral lookup (e.g. `Get-DiscoveryArtifactType
   -Path <string>`) mapping a normalized file path's schema-versioned
   directory/filename convention to one of these eight tokens is legitimate
   to hardcode in the hook, since it names *what kind of schema artifact
   this is*, not *whose domain it belongs to*. The exact directory/filename
   convention is owned by #9002 ("Schema-versioning convention... directory
   layout, version field", `epic.md:107-109`) and is not yet finalized in
   this branch; the mapping function's body is a `# TODO(#9002)` seam until
   that convention lands.
2. **Discovery-workspace root and which artifacts are "required" (domain-profile-driven).** *Where* the consumer's discovery workspace lives, and *which* of the
   eight artifact types the domain profile declares mandatory for a given
   gate, are runtime configuration owned by #9001 (the domain profile). Since
   #9001 has no shipped parser or schema in this branch (§1.5), the hook must
   isolate this behind a single narrow reader seam — e.g. an injectable
   `RequiredArtifactPathsReader` scriptblock defaulting to reading a fixed,
   documented config key (its exact key name and file location are a
   `# TODO(#9001)` seam) — and must **fail open (allow) when the domain
   profile or the required-artifact declaration is absent**, not fail closed.

   This fail-open-on-absence default is the established backward-compatible
   pattern in this repository: every "Scope and Backward Compatibility"
   clause in `.claude/rules/orchestrator-state.md` states that an absent key
   "is unaffected: it validates exactly as before and produces no new
   errors," and every hook read in this session defaults to `allow`/`exit 0`
   whenever its own trigger condition does not match (e.g.
   `enforce-evidence-locations.ps1:121-123,133-135`,
   `enforce-completion-consistency.ps1:335-336,347-349`). Applying the same
   default here means the discovery-hooks feature is safe to merge and
   register in `.claude/settings.json` before #9001 ships a domain profile
   in any consumer repository: with no domain profile present, both hooks
   are structurally registered but functionally inert (always allow),
   exactly matching the additive, non-breaking pattern the rest of the
   codebase already uses for staged capability rollout.

## 5. Canonical hook I/O confirmation

Confirmed by direct read (§1.1): dot-source guard
`if ($MyInvocation.InvocationName -eq '.') { return }` present, unconditional,
immediately before the exit-triggering entrypoint call in every hook read.
Thin-entrypoint pattern confirmed: a testable `Invoke-<X>Decision` /
`Invoke-<X>Validation` function returns a value (an ordered hashtable for
PreToolUse, an `{ Ok; Message }` hashtable for SubagentStop); the bottom
5-10 lines of the file are the only code touching `$env:`, `ConvertTo-Json`,
`Write-Output`, `Write-Error`, or `exit`. Both new hooks in this feature
must follow this exact shape: `Invoke-DiscoveryArtifactGateDecision` (PreToolUse)
and `Invoke-DiscoveryArtifactGateValidation` (SubagentStop), each returning a
plain value that the entrypoint converts to JSON/exit code.

## 6. Per-session state necessity

**Recommendation: stateless.** No concrete need for
`.claude/state/*.<session_id>.json` was identified. Both hooks are pure
functions of their current-call input (tool-input JSON for PreToolUse,
hook-input JSON plus on-disk artifact content for SubagentStop) and the
domain profile / validator CLI, with no cross-call memory requirement (unlike
`persist-session-id.ps1`, which exists specifically to persist
`CLAUDE_SESSION_ID` across calls because that value is not otherwise
available). Introducing session state here would add a mutable-state
dependency the general code-change policy discourages
(`.claude/rules/general-code-change.md`, "Avoid global state and mutable
script-scoped variables; pass data explicitly") without a corresponding
requirement. If a future requirement emerges (e.g., "do not re-deny the same
artifact twice in one session to reduce noise"), it should be added as a
narrow, separately justified follow-up, not assumed now.

## 7. Pester test edge cases

Both hooks need, at minimum (mirroring the structure of
`enforce-evidence-locations.Tests.ps1` / `validate-orchestrator-output.Tests.ps1`):

- **Allow / pass:** discovery-artifact write (or subagent output referencing
  discovery-artifact paths) where `Invoke-DiscoveryValidatorExe` returns
  `ExitCode = 0` → `permissionDecision = 'allow'` (PreToolUse) / `exit 0`
  (SubagentStop).
- **Deny / block — non-conforming:** `Invoke-DiscoveryValidatorExe` returns
  `ExitCode = 1` with non-empty `Output` → `permissionDecision = 'deny'`
  with the validator's stderr text embedded in
  `permissionDecisionReason` (PreToolUse) / `Write-Error` carrying the same
  text, `exit 1` (SubagentStop).
- **Not a discovery artifact / no match:** `file_path` (or subagent output)
  does not match any recognized artifact-type pattern → allow/exit 0
  without invoking the validator at all (assert the mock was never called;
  mirrors `enforce-completion-consistency.ps1`'s early-return-on-`Test-IsCheckpointPath`-false
  path, tested by never exercising `Get-MissingCompletionEvidence`).
- **Domain profile / required-artifact declaration absent:** gate is inert
  (allow) per §4's fail-open default — a dedicated test asserting the
  behavior does not regress once #9001 ships.
- **Malformed `CLAUDE_TOOL_INPUT` / `CLAUDE_HOOK_INPUT` JSON:** hard failure
  path — `Write-Error`, `exit 1` (mirrors
  `enforce-evidence-locations.ps1:125-130,163-168` and
  `validate-orchestrator-output.ps1:252-256`).
- **Empty/absent env var:** default-allow (PreToolUse, mirrors
  `Invoke-EvidenceLocationDecision:121-123`) / hard failure with an
  explicit "CLAUDE_HOOK_INPUT is empty" message (SubagentStop, mirrors
  `Invoke-OrchestratorOutputValidation:248-249`).
- **Validator executable/module not found:** `Invoke-DiscoveryValidatorExe`
  returns a non-zero exit with `python`/module-not-found text in `Output`
  (e.g. simulate `ModuleNotFoundError`) → treated identically to any other
  non-conforming result (deny/block), not silently allowed; a dedicated test
  should assert this failure mode is not swallowed.
- **Edit-tool partial-patch input (PreToolUse only):** `Edit` calls supply
  only `old_string`/`new_string`, not full file content. Two acceptable
  designs, both requiring an explicit test: (a) allow Edit calls
  unconditionally and rely on the SubagentStop gate as the authoritative
  check (mirrors `enforce-checkpoint-monotonic.ps1`'s documented Edit
  deferral, referenced at `enforce-completion-consistency.ps1:32-36`), or
  (b) apply the read-then-validate pattern
  (`Resolve-EditedCheckpointContent`,
  `enforce-completion-consistency.ps1:260-312`) to reconstruct on-disk
  content before validating. Recommend (a) for the initial implementation —
  simpler, and the SubagentStop gate already provides the authoritative
  backstop — with (b) as a documented future enhancement if per-Edit
  precision proves necessary.
- **Domain-neutrality grep gate on new hook source:** a test (or a
  repo-level lint step) asserting the new `.ps1` source files, comments, and
  literal strings contain none of the epic's forbidden domain tokens
  (`TaskMaster`, `TMW`, `Outlook`, `VSTO`, task-management-specific terms).
  No existing hook implements this grep gate today (`Grep` for
  `domain-neutral|TaskMaster|Outlook|VSTO` under `.claude/hooks/` returned no
  matches); this feature introduces the first instance. Simplest
  implementation: a Pester `It` block that reads the hook's own source text
  and asserts `-notmatch` against a small forbidden-token list, rather than a
  new standalone hook (keeps the file count within budget — see §Design
  decisions).

## Requirements mapping (acceptance criteria → design)

| Acceptance criterion (`issue.md`) | Design element |
|---|---|
| One or more PowerShell completion-gate hooks enforce discovery-artifact completion gates by invoking the discovery validators | Two hooks: `enforce-discovery-artifact-gate.ps1` (PreToolUse) + `validate-discovery-artifact-gate.ps1` (SubagentStop), both calling `Invoke-DiscoveryValidatorExe` → `python -m scripts.dev_tools.validate_discovery_artifacts <type> <path>` |
| Hooks follow canonical PreToolUse/SubagentStop I/O conventions and the dot-source guard | §1.1, §5 — dot-source guard, thin entrypoint, `$env:CLAUDE_TOOL_INPUT`/`$env:CLAUDE_HOOK_INPUT`, `ConvertTo-Json -Compress -Depth 5` |
| Hooks are registered in `.claude/settings.json` under the appropriate event with the standard command form | §7 (file names) below; register under existing `"Write|Edit"` PreToolUse matcher and the existing broad generic-agent `SubagentStop` matcher (line 189) rather than a new agent-specific matcher, per §Design decisions |
| Hooks are domain-neutral (no domain-specific identifiers in source, comments, or messages) | Static artifact-type lookup only names schema-kind tokens (§4 point 1); domain-profile seam is a narrow injectable reader with a `# TODO(#9001)` marker (§4 point 2); domain-neutrality grep test (§7 edge case) |
| Pester tests are mirrored at `tests/scripts/claude-hooks/<name>.Tests.ps1` | `tests/scripts/claude-hooks/enforce-discovery-artifact-gate.Tests.ps1`, `tests/scripts/claude-hooks/validate-discovery-artifact-gate.Tests.ps1` |

**State model:** both hooks are stateless pure functions of
(tool/hook input JSON, on-disk artifact content, domain-profile
required-artifact declaration if present) → (allow/deny decision or
exit-code + message). No transitions beyond the four terminal outcomes
enumerated in §7 (allow, deny/block-non-conforming, allow-not-applicable,
hard-failure-malformed-input).

## Testing implications (strategy)

- Framework: Pester v5.x, files under `tests/scripts/claude-hooks/`, named
  `*.Tests.ps1`, `Describe`/`Context`/`It`, one behavior per `It` — per
  `.claude/rules/powershell.md:54-65` and existing sibling test files in that
  directory.
- Mock only the wrapper function `Invoke-DiscoveryValidatorExe`, never
  `python` directly (`.claude/rules/powershell.md:78-89`); mock signature
  must match the production named parameter exactly (`-ValidatorArgs`).
- No temporary files: use the injectable-scriptblock/mocked-function pattern
  already used throughout (`Get-CheckpointFileContent`,
  `FolderExistsCheck`, `CheckpointReader`) rather than writing artifacts to
  disk during tests.
- Line coverage ≥ 85%, branch coverage ≥ 75%, uniformly (no tier-specific
  floor) per `.claude/rules/quality-tiers.md`; this is a small, well-scoped
  pair of hooks, so both thresholds should be straightforward to clear with
  the edge-case list in §7.
- No property-based, mutation, or golden tests required — hooks are not T1
  classifier-output modules and are not pure-function-dense in the sense
  `quality-tiers.md` requires property tests for; ordinary unit tests
  covering the enumerated scenarios are sufficient.

## Design decisions / open seams

- **`# TODO(#9002)`** — `Get-DiscoveryArtifactType -Path <string>`'s mapping
  from a normalized file path to one of the eight validator subcommand
  tokens depends on #9002's schema-versioning directory/filename convention,
  which is not yet finalized in this branch. Implement with an explicit,
  narrow, replaceable lookup and a code comment pointing at #9002.
- **`# TODO(#9001)`** — the discovery-workspace root and the
  required-artifact-per-gate declaration are domain-profile-driven runtime
  configuration owned by #9001, which has no shipped parser/schema in this
  branch. Implement as a single injectable `RequiredArtifactPathsReader`
  scriptblock (or equivalent) with a safe, fail-open default (§4 point 2, §6).
- **Portable-fallback / capability-detection question left open, and
  deliberately not solved here.** The orchestrator-state hooks
  (`validate-orchestrator-output.ps1`, `enforce-pr-author-skill.ps1`) use a
  capability-detection probe (`Test-PythonOrchestratorValidatorAvailable`)
  plus a portable PowerShell reimplementation of the validator logic for
  consumer repositories that received only the pushed-down `.claude` pack
  without `scripts/dev_tools`. This feature's own scope statement explicitly
  forbids reimplementing validator logic in PowerShell ("Do NOT implement or
  design the validators"), and the epic's mirror contract
  (`epic.md:120-122`) only mirrors `.claude/`, `.github/`, `.codex/`+`.agents/`
  assets into `resources/` — it does not mirror `scripts/dev_tools`. A
  portable PowerShell fallback for the discovery validators would therefore
  require reimplementing validation logic, directly conflicting with this
  feature's scope boundary. Recommendation: **do not build a
  capability-detection/fallback path in this feature.** Assume
  `scripts.dev_tools.validate_discovery_artifacts` is importable (i.e., the
  hooks run in a context that has the drm-copilot Python toolchain, matching
  today's actual usage — the discovery workflow orchestrates from
  drm-copilot against an external consumer-repo path per the epic's
  architectural boundaries, `objective-source.md:135-137`). If a future
  publishing feature (#9012, explicitly out of scope here per this feature's
  own `spec.md`/`issue.md` "Constraints & Risks") needs these hooks to run
  standalone inside a consumer repository without `scripts/dev_tools`, that
  is a #9012-owned follow-up, not a #9004 concern.
- **SubagentStop matcher does not name #9007's not-yet-shipped agent
  personas.** #9004's only declared dependency is #9003 (validators);
  #9007 (generic agent roles) is a sibling Wave-1 feature, not a dependency.
  Hardcoding agent names from #9007 into `.claude/settings.json`'s
  `SubagentStop` matcher would forward-reference an unshipped feature and
  couple this hook to specific domain-neutral persona names prematurely.
  Recommendation: register the new SubagentStop hook under the existing
  broad, already-shipped generic-agent matcher group
  (`.claude/settings.json:189`) and let the hook's own logic decide,
  content-first, whether the terminating agent's output references
  discovery-artifact paths — independent of which agent produced it. When
  #9007 ships new agent personas that also need this gate, extending the
  matcher regex is a one-line follow-up in #9007 or #9012, not a rework of
  this hook's internal logic.
- **File-count / change-budget note for the atomic planner.** Two hook files
  are recommended (`enforce-discovery-artifact-gate.ps1`,
  `validate-discovery-artifact-gate.ps1`). Both need
  `Invoke-DiscoveryValidatorExe`. Two implementation options:
  (a) duplicate the ~10-line wrapper function once, in both files, staying
  within `.claude/rules/powershell.md:39`'s direct-mode cap of "up to 2
  production PowerShell files"; or (b) factor the wrapper into a third
  shared file (e.g. a `.claude/hooks/enforce-discovery-gate-helpers.ps1`
  dot-sourced by both, mirroring `enforce-completion-helpers.ps1`), which
  requires routing through `powershell-change-budget-router` /
  `powershell-orchestrator` since it is a 3rd production file, but still
  fits the stated per-batch cap of "3 production and 3 test files."
  Recommend (a) as the default unless the atomic planner has independent
  reason to route this through the batch-cap workflow.

## Recommended file paths

- `.claude/hooks/enforce-discovery-artifact-gate.ps1` (PreToolUse, `Write|Edit` matcher group in `.claude/settings.json:120-160`)
- `.claude/hooks/validate-discovery-artifact-gate.ps1` (SubagentStop, existing broad generic-agent matcher at `.claude/settings.json:189`)
- `tests/scripts/claude-hooks/enforce-discovery-artifact-gate.Tests.ps1`
- `tests/scripts/claude-hooks/validate-discovery-artifact-gate.Tests.ps1`
