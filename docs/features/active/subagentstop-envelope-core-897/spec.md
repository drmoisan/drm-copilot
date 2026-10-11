# subagentstop-envelope-core (Spec)

- **Issue:** #897
- **Parent (optional):** epic `subagentstop-envelope` (epic issue #904), child E1, wave 0, band C4
- **Owner:** drmoisan
- **Last Updated:** 2026-10-11T13-15
- **Status:** Ready for planning
- **Version:** 1.1

## Authoritative Helper Contract

**NO RENAME was required.** The live differential (`evidence/other/subagentstop-live-differential.2026-10-11T12-01.md`, Claude Code 2.1.296) confirmed the planned contract from the epic Shared Design: the SubagentStop payload arrives as JSON on stdin, the assistant text is the root field `last_assistant_message`, the root carries no `output` key, `CLAUDE_HOOK_INPUT` is not set, exit 1 does not block, and exit 2 blocks with stderr delivered to the subagent and re-entry carrying `stop_hook_active: true`. This section is the authoritative contract that E2, E3 and E4 code against. Where this section and any other document differ, this section governs.

### File

- Path: `.claude/hooks/subagentstop-envelope.ps1`.
- Dot-sourced by consumers. It is NOT registered as a hook in either `settings.json` copy.
- Imports nothing (no `Import-Module`, no `using module`, no dot-source).
- Writes nothing to the success (stdout) or warning streams.
- Reads no environment variable.
- Byte-identical bundled mirror: `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/subagentstop-envelope.ps1`.
- Listed in `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json` as `.claude/hooks/subagentstop-envelope.ps1`.

### `Read-SubagentStopEnvelope [-InputText <string>]`

- `-InputText` is declared `[AllowNull()][AllowEmptyString()][string]`.
- When `-InputText` is bound (`$PSBoundParameters.ContainsKey('InputText')`), including when bound to an empty string or `$null`, the function parses that text and does not read stdin.
- When `-InputText` is not bound, the function reads `[Console]::In.ReadToEnd()` inside `try`/`catch`. A read failure is treated as empty input. There is no `[Console]::IsInputRedirected` probe; a manual run without redirected stdin waits for end-of-input, which the help text states.
- Strips a single leading BOM (U+FEFF) before any other evaluation.
- Never throws and never exits.
- Always returns exactly one `PSCustomObject` with exactly these seven properties:

| Field | Type | Value |
| --- | --- | --- |
| `IsValid` | bool | `$true` only when the root is a JSON object whose `last_assistant_message` is a string |
| `Anomaly` | string or `$null` | One of the six codes below; `$null` when `IsValid` is `$true` |
| `Envelope` | object or `$null` | The parsed root whenever the root is a JSON object (including the `MissingAssistantMessage`, `NullAssistantMessage` and `NonStringAssistantMessage` rows); otherwise `$null` |
| `AssistantText` | string | `last_assistant_message` when `IsValid`; `''` when invalid |
| `StopHookActive` | bool | Root `stop_hook_active` when it is a boolean; otherwise `$false` |
| `AgentType` | string | Root `agent_type` when it is a string; otherwise `''` |
| `HookEventName` | string | Root `hook_event_name` when it is a string; otherwise `''` |

Input-to-result table:

| Input (after BOM strip) | IsValid | Anomaly |
| --- | --- | --- |
| `$null`, empty string, or whitespace only | `$false` | `EmptyPayload` |
| Not parseable as JSON | `$false` | `UnparseableJson` |
| JSON array (any length), scalar (number, string, boolean), or JSON `null` | `$false` | `NonObjectEnvelope` |
| JSON object without a `last_assistant_message` property | `$false` | `MissingAssistantMessage` |
| JSON object whose `last_assistant_message` is `null` | `$false` | `NullAssistantMessage` |
| JSON object whose `last_assistant_message` is a number, boolean, object or array | `$false` | `NonStringAssistantMessage` |
| JSON object whose `last_assistant_message` is `""` | `$true` | `$null` |
| JSON object whose `last_assistant_message` is a non-empty string | `$true` | `$null` |
| JSON object whose `last_assistant_message` is `"2026-10-11T12:00:00Z"` (string in ISO-8601 date form) | `$true` | `$null`; `AssistantText` equals the exact string `2026-10-11T12:00:00Z` |

Parsing uses `ConvertFrom-Json -NoEnumerate -DateKind String` (PowerShell 7.5 or later; hooks run under `pwsh`) so that a single-element JSON array is classified as `NonObjectEnvelope` rather than unwrapped, and so that a string in ISO-8601 date form remains a `[string]`. The `-DateKind String` addition is a parsing refinement made after preflight (finding D5); it is not a rename and does not change any function name, parameter, or the seven-field return shape. Any exception raised by `ConvertFrom-Json` (including duplicate keys that differ only in case) maps to `UnparseableJson`. JSON whitespace including CRLF line endings is accepted by the parser; no separate CRLF normalization step is part of the contract.

### `Get-SubagentStopEnvelopeAnomalyReason -Anomaly <string>`

- Additive helper. Returns one distinct, non-empty clause for each of the six anomaly codes.
- Consumers write `<PREFIX> payload anomaly - <clause>`, where `<PREFIX>` is the validator's own reason prefix.
- Unknown code behavior: for any value that is not one of the six codes (including `$null`, empty string, and case variants that do not match exactly), the function throws `[System.ArgumentException]` whose message names the rejected value. The function does not use `[ValidateSet()]`, so the exception type is `ArgumentException`, not a parameter-binding exception.

### `Exit-SubagentStopBlock -Message <string>`

- `-Message` is `[Parameter(Mandatory)][ValidateNotNullOrEmpty()][string]`.
- Body: `[Console]::Error.WriteLine($Message)` then `exit 2`. No other output.
- A null or empty `-Message` fails parameter binding before the body runs, so no exit occurs.

### Consumer policy for E2, E3 and E4

1. Invalid envelope (`IsValid` is `$false`) blocks through `Exit-SubagentStopBlock` (fail closed), using `Get-SubagentStopEnvelopeAnomalyReason` for the clause.
2. `StopHookActive` is surfaced by the helper; the re-entry policy is decided per validator. Conditions the subagent can repair (a missing path token or file) may block again. Conditions it cannot repair use report-and-halt wording and block once.
3. Validator pure entry points take `-InputText` (passed through to `Read-SubagentStopEnvelope`) instead of `-RawPayload $env:CLAUDE_HOOK_INPUT`.
4. Each validator guards the helper dot-source in its own single-statement `try` whose `catch` calls `Add-HookDependencyFailure -Name 'subagentstop-envelope.ps1' -ErrorRecord $_`.
5. The existing S1 dependency tail (`[Console]::Error.WriteLine(...)`/`exit 2` and `exit $dependencyDecision.ExitCode`) stays inline. `Exit-SubagentStopBlock` replaces only the final validation-failure exit.
6. No validator reads `CLAUDE_HOOK_INPUT` for a SubagentStop decision.

### Issue closure

Child pull requests for E1, E2 and E3 reference the issue with `Refs #897` and MUST NOT use a closing keyword (`Closes`, `Fixes`, `Resolves`, or their variants) for #897. The integration-to-main pull request for epic #904 closes #897.

## Context

- Summary: the SubagentStop completion gates under `.claude/hooks/` read `$env:CLAUDE_HOOK_INPUT`, take `output` off the parsed root, and block with `exit 1`. The real SubagentStop payload arrives on stdin, carries `last_assistant_message`, and has no `output` key; exit 1 does not block. The gates are therefore inert. The inline SubagentStop command at `.claude/settings.json:218` has the same three defects. E1 delivers the shared helper the validators will consume and removes the inline command. Source issue: `issue.md`; source entry: `docs/features/potential/2026-08-21-subagentstop-validators-read-undocumented-envelope.md`.
- Observed environment(s): Windows 11 Pro, PowerShell 7, Claude Code 2.1.296 (headless `-p`).
- Customer impact and severity: High. An inert completion gate allows a subagent (including the orchestrator completion gate in `validate-orchestrator-output.ps1`) to report completion without the artifact that proves it. Every SubagentStop matched by these registrations is affected on every run.
- First observed date and version(s) impacted: raised 2026-08-21 by the #501 investigation; confirmed present on main at `2ef8d361` (2026-10-11); measured by live differential on 2026-10-11.

## Repro & Evidence

- Steps to reproduce: register a SubagentStop probe hook through `claude -p ... --settings <scratch settings>` from an empty scratch directory, run once each with the probe exiting 0, 1 and 2, and record stdin, the environment, and whether the subagent resumed. Full method in `evidence/other/subagentstop-live-differential.2026-10-11T12-01.md`; probe source in `evidence/other/subagentstop-probe.2026-10-11T12-01.ps1.txt`.
- Expected vs actual behavior: expected, a gate that refuses a stop blocks the subagent. Actual, the validators read an unset environment variable and an absent `output` key, and their refusal path exits 1, which does not block.
- Logs/screenshots/error snippets: in 4 of 4 hook invocations `CLAUDE_HOOK_INPUT` was not set and the stdin root had no `output` key; `last_assistant_message` was `"PONG"`. The exit-1 run ended with the parent printing `PONG` (not blocked). The exit-2 run resumed the subagent, which obeyed the stderr instruction; the second invocation received `stop_hook_active: true`.
- Frequency / determinism: deterministic. One run per mode with one agent type (`general-purpose`); named project agents were not exercised. Empty, absent and malformed stdin cannot be produced by a real hook and were not observed; their handling is a design decision recorded in the contract above.

## Scope & Non-Goals

- In scope:
  - New helper `.claude/hooks/subagentstop-envelope.ps1` implementing the Authoritative Helper Contract, its byte-identical bundled mirror, and its `core.json` manifest entry.
  - New Pester suite `tests/scripts/claude-hooks/subagentstop-envelope.Tests.ps1` and a checked-in fixture script under `tests/fixtures/claude-hooks/` for the `Exit-SubagentStopBlock` `&`-route test.
  - Deletion of the inline SubagentStop command object in `.claude/settings.json` and its bundled copy, with the group, its matcher, and the `validate-discovery-artifact-gate.ps1` entry retained.
  - A regression assertion in `tests/scripts/claude-runtime/claude-settings.Tests.ps1`.
- Out of scope / non-goals:
  - Converting the nine validators (`validate-orchestrator-output.ps1` with `validate-orchestrator-output-resolution.ps1`, `validate-executor-output.ps1`, `validate-planner-output.ps1`, `validate-required-artifact-output.ps1`, `validate-discovery-artifact-gate.ps1`, `validate-pr-author-output.ps1`, `validate-prd-feature-output.ps1`, `validate-task-researcher-output.ps1`, `validate-feature-review-coverage.ps1`) and their tests. These belong to E2, E3 and E4.
  - Editing `.claude/agents/epic-orchestrator.md` (SHA-256 pinned in `tests/scripts/dev_tools/parallel_orchestrator_surface_expectations.py`).
  - Any new validation rule; any change to the SubagentStop matcher strings.
  - The pre-existing gap that `validate-pr-author-output.ps1` is in no pack manifest.
  - Deduplicating validators registered in both settings and agent frontmatter (observation recorded for E2-E4).
- Explicitly excluded systems, integrations, or datasets: `.codex/` hooks and their mirrors (no Codex hook dot-sources the helper); `.claude/lib/hook-payload/HookPayload.psm1` (496 lines; adding SubagentStop functions would exceed the 500-line cap, and its environment fallback contradicts the contract); Python enforcement legs (none are added).

## Root Cause Analysis

- Confirmed root cause: the SubagentStop validators and the inline command were written against an undocumented transport and shape (`$env:CLAUDE_HOOK_INPUT`, root `output`) and use `exit 1` to block. The runtime delivers JSON on stdin with `last_assistant_message`, and only exit 2 blocks.
- Signals/evidence supporting it: the live differential (above); the vendor hook documentation quoted in `research/research.2026-10-11T12-15.md` R2; PR #881 (#786), which proved two exit-1 handlers in `validate-orchestrator-output.ps1` fail open.
- Affected components/modules: `.claude/hooks/validate-*.ps1` (nine validators, converted by E2-E4); the inline command at `.claude/settings.json:218` and its bundled copy (fixed by E1).

### Inline SubagentStop command analysis

Command at `.claude/settings.json:218` (JSON-unescaped):

```text
pwsh -NoProfile -Command "$input = $env:CLAUDE_HOOK_INPUT | ConvertFrom-Json; $output = $input.output; if (-not ($output -match '(plan-path|research-path|review-artifact|PREFLIGHT|evidence/)')) { Write-Error 'Subagent stopped without required completion artifact path'; exit 1 }; exit 0"
```

Current runtime effect (inferred from code plus the live capture): `CLAUDE_HOOK_INPUT` is unset, so `$output` is `$null`, the condition is true, and the command exits 1 on every matched stop. Exit 1 does not block, so the gate has never blocked. The regex is also case-insensitive and over-permissive.

The group matcher at `.claude/settings.json:214` lists these agents (exact-name list per the documented matcher semantics; derivation in the research record's Numeric Derivation Evidence):

| # | Agent | Token-correct? | Reason | Recommendation |
| --- | --- | --- | --- | --- |
| 1 | atomic-planner | Yes (`PREFLIGHT`, `plan-path`) | Dedicated `validate-planner-output.ps1` already requires `plan-path`, an exact preflight signal, and an existing plan file | Drop (redundant with a stricter validator) |
| 2 | atomic-executor | Yes (`plan-path`) | Dedicated `validate-executor-output.ps1` already requires `plan-path` | Drop (redundant) |
| 3 | feature-review | No | Contract returns `policy-audit-path:`, `code-review-path:`, `feature-audit-path:`; none contains a pattern token | Drop (pattern would refuse correct returns) |
| 4 | task-researcher | Yes (`research-path`) | Dedicated `validate-task-researcher-output.ps1` already requires `research-path` | Drop (redundant) |
| 5 | prd-feature | No | `research-path:` is present only when numeric acceptance criteria exist | Drop (pattern wrong for the common case) |
| 6 | staged-review | No | Contract returns `staged-review-path:` | Drop |
| 7 | epic-review | No | Contract returns `epic-audit-path:` | Drop |
| 8 | status-updater | No | Contract returns `status-sync-path:` | Drop |
| 9 | python-typed-engineer | No | No final-token contract | Drop |
| 10 | powershell-typed-engineer | No | No final-token contract; stop conditions return without artifacts | Drop |
| 11 | csharp-typed-engineer | No | No final-token contract | Drop |
| 12 | typescript-engineer | No | No final-token contract | Drop |
| 13 | orchestrator | No | Epic-mode eight-field return contains no pattern token | Drop |
| 14 | epic-orchestrator | No | No token requirement; long-running with interim stops | Drop |
| 15 | epic-planner | Only on successful completion | The epic-worthiness early stop and interim stops carry no token | Drop |

Decision: delete the inline command object in both settings copies. Keep the group, its matcher string unchanged, and the `validate-discovery-artifact-gate.ps1` entry unchanged. Rationale: for eleven agents the pattern is wrong or not part of the contract, so an exit-2 gate would refuse correct returns and push subagents to fabricate tokens; for atomic-planner, atomic-executor and task-researcher a stricter dedicated validator already exists; for epic-planner the pattern holds only on success, and a state-aware gate would be a new validation rule, which the epic lists as a non-goal. Keeping the matcher unchanged keeps the existing matcher assertions in `claude-settings.Tests.ps1` and `tests/scripts/dev_tools/test_claude_planning_integrity_contracts.py` green.

Rejected alternative: convert the inline command to a file-based hook that uses the new helper and narrow its matcher to `atomic-planner|atomic-executor|task-researcher|epic-planner`. Rejected because it duplicates three stricter validators, is incorrect for epic-planner's non-success stops, and adds a registered hook that must satisfy guard tests S1-S6 and B1-B4 (including a new reason-prefix entry in `hook-dependency-failure.Claude.Tests.ps1`), a mirror, and a manifest entry, for no enforcement gain.

## Proposed Fix

### Design summary (what changes where):

- Add `.claude/hooks/subagentstop-envelope.ps1` exposing `Read-SubagentStopEnvelope`, `Get-SubagentStopEnvelopeAnomalyReason`, and `Exit-SubagentStopBlock` per the Authoritative Helper Contract; copy it byte-identically to the bundle; add it to `core.json`.
- Delete the inline command object (`.claude/settings.json` lines 216-219, including the separating comma) in the canonical and bundled settings files identically.
- Add the Pester suite, the fixture script, and the settings regression assertion.

### Boundaries and invariants to preserve:

- The helper never exits from `Read-SubagentStopEnvelope` or `Get-SubagentStopEnvelopeAnomalyReason`; only `Exit-SubagentStopBlock` exits.
- The helper reads no environment variable and imports nothing, so it adds no transitive edge for the S4 guard check when E2-E4 dot-source it.
- Canonical and bundled `settings.json` remain byte-identical; canonical and bundled helper remain byte-identical.
- The SubagentStop group matcher string at `.claude/settings.json:214` is unchanged, and the group still contains the `validate-discovery-artifact-gate.ps1` command.
- No validator file, `.claude/agents/epic-orchestrator.md`, `.codex/` file, or `HookPayload.psm1` changes.
- No Python under `.claude/hooks/`. No production or test file over 500 lines.

### Dependencies or blocked work:

- E2 (#903), E3 (#897) and E4 (#896) depend on this contract and must not merge before E1 lands on `epic/subagentstop-envelope-integration`.
- Open epic decision (not blocking E1): E1 and E3 share issue key #897 (`epic.md` Open Decisions).

### Implementation strategy (what changes, not sequencing):

#### Files/modules to change:

| File | Change |
| --- | --- |
| `.claude/hooks/subagentstop-envelope.ps1` | New |
| `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/subagentstop-envelope.ps1` | New, byte-identical copy |
| `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json` | Add one `paths` entry |
| `.claude/settings.json` | Delete inline command object |
| `extensions/drm-copilot/resources/claude-customizations/.claude/settings.json` | Same deletion |
| `tests/scripts/claude-hooks/subagentstop-envelope.Tests.ps1` | New |
| `tests/fixtures/claude-hooks/Invoke-SubagentStopBlock.Fixture.ps1` | New fixture: dot-sources the helper via a path relative to `$PSScriptRoot` and calls `Exit-SubagentStopBlock -Message $Message` |
| `tests/scripts/claude-runtime/claude-settings.Tests.ps1` | Add regression assertions |

#### Functions/classes/CLI commands impacted:

- New: `Read-SubagentStopEnvelope`, `Get-SubagentStopEnvelopeAnomalyReason`, `Exit-SubagentStopBlock`.
- Removed: the inline SubagentStop `pwsh -NoProfile -Command ...` hook command.

#### Data flow and validation changes:

- stdin (or bound `-InputText`) -> BOM strip -> emptiness check -> `ConvertFrom-Json -NoEnumerate -DateKind String` -> root-type check -> `last_assistant_message` presence, null and type checks -> result object. Derived fields (`StopHookActive`, `AgentType`, `HookEventName`) are read from any object root regardless of `IsValid`.

#### Error handling and logging updates:

- `Read-SubagentStopEnvelope` converts all read and parse failures into anomaly codes; it does not write to any stream.
- `Get-SubagentStopEnvelopeAnomalyReason` throws `ArgumentException` for an unknown code (programming error in a consumer, surfaced fail-fast).
- `Exit-SubagentStopBlock` writes only to stderr.

#### Rollback/feature-flag considerations (if applicable):

- No feature flag. Rollback is a revert of the E1 commit; the helper has no consumers until E2-E4 merge, and the deleted inline command never blocked.

### Technical specifications (interfaces/contracts):

#### Inputs/outputs and formats:

- Defined in the Authoritative Helper Contract.

#### Required configuration keys and defaults:

- None. No `settings.json` registration for the helper. No change to `config/poshqc-coverage.json` (its roots are directories, so the new file is in the coverage denominator automatically) or `config/poshqc-scan.json`.

#### Backward-compatibility expectations:

- Additive helper; no existing caller. Removing the inline command removes a hook that exited 1 on every matched stop without blocking, so no observable blocking behavior is lost.

#### Performance constraints (latency/throughput/memory):

- One stdin read and one JSON parse per invocation. No network or file I/O. No explicit latency budget beyond the existing hook timeout.

## Assumptions, Constraints, Dependencies

- Assumptions: the documented SubagentStop envelope remains as captured on Claude Code 2.1.296. `exit` inside a function from a dot-sourced file, called from an `&`-invoked script, ends only that script and sets `$LASTEXITCODE` (to be verified by an early plan task; not executed during research). Agents in this repository do not use `SubagentHandback` (0 references), so `last_assistant_message` carries the report; if that changes, the field may hold only closing text (known limit).
- Constraints: PowerShell only; no Python in hooks; 500-line cap; line coverage >= 85% for the helper (no branch gate for PowerShell); no temporary files and no child processes in unit tests.
- External dependencies: Claude Code hook runtime semantics (vendor documentation, `https://code.claude.com/docs/en/hooks`).

## Data / API / Config Impact

- User-facing or API changes: new dot-sourced helper API (contract above). The inline SubagentStop hook command is removed.
- Data or migration considerations: none.
- Logging/telemetry updates: none. Block reasons go to stderr only.
- Compatibility notes: both `settings.json` copies change identically; `core.json` gains one path, so manifest-scoped push-down delivers the helper with the core pack.

## Test Strategy

- Regression tests to add or update:
  - `tests/scripts/claude-runtime/claude-settings.Tests.ps1`: new assertions that (a) no SubagentStop hook command in either settings copy contains `CLAUDE_HOOK_INPUT`, (b) no SubagentStop hook command in either copy ends with `exit 1`, (c) the group whose matcher is the unchanged fifteen-agent string still exists in both copies and contains the `pwsh -NoProfile -File .claude/hooks/validate-discovery-artifact-gate.ps1` command, and (d) no hook command in either copy references `subagentstop-envelope.ps1`.
- Unit tests (Pester) for the fixed behavior and boundaries, in `tests/scripts/claude-hooks/subagentstop-envelope.Tests.ps1` (dot-source the helper in `BeforeAll`):
  - Surface: the three functions are defined after dot-sourcing.
  - Source constraints (AST scan of the helper): no `$env:` variable reference, no `[Environment]::GetEnvironmentVariable` call, no `Get-ChildItem env:`/`Get-Item env:`; no `Import-Module`, `using module`, or dot-source; no `Write-Output`, `Write-Host`, `Write-Warning` or `Write-Information`.
  - One `It` per row of the input-to-result table, using `-InputText`, asserting `IsValid`, `Anomaly`, `Envelope` null or non-null, and `AssistantText`.
  - A `last_assistant_message` of `2026-10-11T12:00:00Z` yields `IsValid` `$true` and `AssistantText` equal to that exact string (AC-5).
  - Result shape: exactly the seven property names, exactly one object emitted, no exception, for every row.
  - Derived fields: `stop_hook_active` true, false, absent, and string `"true"`; `agent_type` and `hook_event_name` present, absent, and non-string.
  - BOM-prefixed valid envelope; BOM-only input (`EmptyPayload`); CRLF-formatted valid envelope.
  - stdin default: `[Console]::SetIn([System.IO.StringReader]::new(<envelope>))` with the original reader restored in `finally`; read failure via a disposed `StringReader` passed to `SetIn` yields `EmptyPayload`; bound `-InputText ''` takes precedence over non-empty stdin and yields `EmptyPayload`.
  - Anomaly reason map: each of the six codes returns a non-empty clause; the six clauses are pairwise distinct; an unknown code, `$null`, `''`, and a case variant each throw `System.ArgumentException`.
  - `Exit-SubagentStopBlock` through the `&` route: invoke `tests/fixtures/claude-hooks/Invoke-SubagentStopBlock.Fixture.ps1 -Message '<text>'` with `[Console]::SetError([System.IO.StringWriter]::new())` (restored in `finally`); assert stderr equals the message followed by a newline, `$LASTEXITCODE` is 2, and no success-stream output.
  - `Exit-SubagentStopBlock` with `-Message ''` or `$null`: parameter binding error, no exit (callable directly in the test runner because binding fails before the body).
- Edge cases and negative scenarios: single-element array, JSON `null`, scalar string, case-duplicate keys, whitespace-only input, BOM-only input, non-string `last_assistant_message` of each JSON type.
- Error handling and logging verification: no-throw for every input row; `ArgumentException` for unknown anomaly codes; stderr-only output for `Exit-SubagentStopBlock`.
- Coverage impact and targets: line coverage >= 85% for `.claude/hooks/subagentstop-envelope.ps1`, measured with `Invoke-PoshQCTest -Root <repo> -SettingsPath scripts/powershell/PoshQC/settings/pester.runsettings.psd1` and read from `artifacts/pester/powershell-coverage.xml`; record a Phase 0 baseline and the final figure under `evidence/qa-gates/`. The MCP PoshQC wrapper returns no output body, so figures come from the coverage XML or the self-hosted module run.
- Toolchain commands to run: PoshQC format (`Invoke-PoshQCFormat`) -> PSScriptAnalyzer (`Invoke-PoshQCAnalyze`) -> Pester (`Invoke-PoshQCTest`) over the helper, its mirror, the new suite, the fixture, and `claude-settings.Tests.ps1`; restart from format on any failure or auto-fix. Run PSScriptAnalyzer explicitly on the fixture if `tests/fixtures` is outside the configured scan roots. Parity and completeness checks: `poetry run pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py tests/scripts/dev_tools/test_push_down_claude_pack_manifest_completeness.py tests/scripts/dev_tools/test_claude_planning_integrity_contracts.py` and `npx jest test/lib/push-down/claude-pack-manifest-completeness.test.ts` from `extensions/drm-copilot`.
- Early plan task: verify that `exit 2` inside `Exit-SubagentStopBlock`, dot-sourced into an `&`-invoked fixture, ends only the fixture and sets `$LASTEXITCODE` to 2 without terminating the Pester runner.
- Manual validation steps: none required. An optional automatable post-change check is a headless `claude -p --settings` run confirming the deleted inline command no longer produces a hook-error notice.

## Acceptance Criteria

- [x] AC-1: `.claude/hooks/subagentstop-envelope.ps1` exists and, when dot-sourced, defines `Read-SubagentStopEnvelope`, `Get-SubagentStopEnvelopeAnomalyReason` and `Exit-SubagentStopBlock`. Verified by the surface `It` in `tests/scripts/claude-hooks/subagentstop-envelope.Tests.ps1`.
- [x] AC-2: The bundled mirror `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/subagentstop-envelope.ps1` is byte-identical to the source. Verified by `test_bundled_claude_payload_contains_all_repo_runtime_contracts` in `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py` passing.
- [x] AC-3: `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json` lists `.claude/hooks/subagentstop-envelope.ps1`. Verified by `extensions/drm-copilot/test/lib/push-down/claude-pack-manifest-completeness.test.ts` and `tests/scripts/dev_tools/test_push_down_claude_pack_manifest_completeness.py` both passing.
- [x] AC-4: The helper source contains no environment-variable read, no module import or dot-source, and no success-stream, host, information or warning write. Verified by the source-constraints AST `It` blocks in `subagentstop-envelope.Tests.ps1`.
- [x] AC-5: For a valid envelope with a non-empty string `last_assistant_message`, `Read-SubagentStopEnvelope -InputText` returns `IsValid` `$true`, `Anomaly` `$null`, a non-null `Envelope`, `AssistantText` equal to the message, and `StopHookActive`, `AgentType` and `HookEventName` taken from the root; a message in ISO-8601 date form (`2026-10-11T12:00:00Z`) likewise yields `IsValid` `$true` and `AssistantText` equal to that exact string. Verified by the valid-envelope and ISO-date-string `It` blocks in `subagentstop-envelope.Tests.ps1`.
- [x] AC-6: A `last_assistant_message` of `""` yields `IsValid` `$true`, `Anomaly` `$null`, `AssistantText` `''`. Verified by the empty-string-message `It` in `subagentstop-envelope.Tests.ps1`.
- [x] AC-7: `$null`, `''`, whitespace-only and BOM-only `-InputText` each yield `IsValid` `$false`, `Anomaly` `EmptyPayload`, `Envelope` `$null`. Verified by the `EmptyPayload` `It` blocks in `subagentstop-envelope.Tests.ps1`.
- [x] AC-8: Non-JSON input and JSON with case-duplicate keys yield `IsValid` `$false`, `Anomaly` `UnparseableJson`, `Envelope` `$null`. Verified by the `UnparseableJson` `It` blocks in `subagentstop-envelope.Tests.ps1`.
- [x] AC-9: A JSON array (empty, single-element and multi-element), a number, a string, a boolean, and JSON `null` each yield `IsValid` `$false`, `Anomaly` `NonObjectEnvelope`, `Envelope` `$null`. Verified by the `NonObjectEnvelope` `It` blocks in `subagentstop-envelope.Tests.ps1`.
- [x] AC-10: An object without `last_assistant_message` yields `IsValid` `$false`, `Anomaly` `MissingAssistantMessage`, non-null `Envelope`, `AssistantText` `''`. Verified by the `MissingAssistantMessage` `It` in `subagentstop-envelope.Tests.ps1`.
- [x] AC-11: An object whose `last_assistant_message` is `null` yields `IsValid` `$false`, `Anomaly` `NullAssistantMessage`, non-null `Envelope`, `AssistantText` `''`. Verified by the `NullAssistantMessage` `It` in `subagentstop-envelope.Tests.ps1`.
- [x] AC-12: An object whose `last_assistant_message` is a number, a boolean, an object, or an array yields `IsValid` `$false`, `Anomaly` `NonStringAssistantMessage`, non-null `Envelope`, `AssistantText` `''`. Verified by the `NonStringAssistantMessage` `It` blocks in `subagentstop-envelope.Tests.ps1`.
- [x] AC-13: For every input row in AC-5 through AC-12, the function emits exactly one object with exactly the properties `IsValid`, `Anomaly`, `Envelope`, `AssistantText`, `StopHookActive`, `AgentType`, `HookEventName`, and throws no exception. Verified by the result-shape `It` blocks in `subagentstop-envelope.Tests.ps1`.
- [x] AC-14: `StopHookActive` is `$true` only when root `stop_hook_active` is boolean `true` (absent, `false` and string `"true"` yield `$false`); `AgentType` and `HookEventName` are `''` when the root field is absent or not a string. Verified by the derived-field `It` blocks in `subagentstop-envelope.Tests.ps1`.
- [x] AC-15: A BOM-prefixed valid envelope and a CRLF-formatted valid envelope each yield `IsValid` `$true` with the expected `AssistantText`. Verified by the BOM and CRLF `It` blocks in `subagentstop-envelope.Tests.ps1`.
- [x] AC-16: With `-InputText` unbound, the function reads the envelope from `[Console]::In` (set via `[Console]::SetIn` and restored in `finally`); a disposed reader yields `EmptyPayload`; a bound `-InputText ''` takes precedence over non-empty stdin and yields `EmptyPayload`. Verified by the stdin-default `It` blocks in `subagentstop-envelope.Tests.ps1`.
- [x] AC-17: `Get-SubagentStopEnvelopeAnomalyReason` returns a non-empty clause for each of `EmptyPayload`, `UnparseableJson`, `NonObjectEnvelope`, `MissingAssistantMessage`, `NullAssistantMessage` and `NonStringAssistantMessage`, the clauses are pairwise distinct, and an unknown code, `$null`, `''` and a case variant each throw `System.ArgumentException`. Verified by the anomaly-reason `It` blocks in `subagentstop-envelope.Tests.ps1`.
- [x] AC-18: Invoking `tests/fixtures/claude-hooks/Invoke-SubagentStopBlock.Fixture.ps1 -Message '<text>'` through the `&` route with stderr redirected to a `StringWriter` produces stderr equal to the message plus a newline, `$LASTEXITCODE` 2, and no success-stream output; the test runner continues afterward. Verified by the exit-block `It` in `subagentstop-envelope.Tests.ps1`.
- [x] AC-19: `Exit-SubagentStopBlock -Message ''` and `-Message $null` fail parameter binding without exiting. Verified by the exit-block binding `It` in `subagentstop-envelope.Tests.ps1`.
- [x] AC-20: In both `.claude/settings.json` and `extensions/drm-copilot/resources/claude-customizations/.claude/settings.json`, the inline SubagentStop command is absent, and the SubagentStop group with the unchanged matcher `atomic-planner|atomic-executor|feature-review|task-researcher|prd-feature|staged-review|epic-review|status-updater|python-typed-engineer|powershell-typed-engineer|csharp-typed-engineer|typescript-engineer|orchestrator|epic-orchestrator|epic-planner` still exists and contains `pwsh -NoProfile -File .claude/hooks/validate-discovery-artifact-gate.ps1`. Verified by the new group-retention `It` in `tests/scripts/claude-runtime/claude-settings.Tests.ps1`.
- [x] AC-21: No SubagentStop hook command in either settings copy contains `CLAUDE_HOOK_INPUT` or ends with `exit 1`, and no hook command in either copy references `subagentstop-envelope.ps1`. Verified by the new regression `It` blocks in `tests/scripts/claude-runtime/claude-settings.Tests.ps1`.
- [x] AC-22: Canonical and bundled `settings.json` remain byte-identical. Verified by the existing parity `It` in `tests/scripts/claude-runtime/claude-settings.Tests.ps1` and `tests/scripts/dev_tools/test_claude_planning_integrity_contracts.py` passing.
- [x] AC-23: The hook-dependency guard suites pass unchanged: `tests/scripts/claude-runtime/hook-dependency-guard-completeness.Tests.ps1`, `tests/scripts/claude-runtime/hook-imported-modules-no-stdout.Tests.ps1`, `tests/scripts/claude-hooks/hook-dependency-failure.Claude.Tests.ps1`, and `tests/scripts/claude-hooks/hook-dependency-guard.Tests.ps1`. Verified by a Pester run of those files with zero failures.
- [x] AC-24: Line coverage for `.claude/hooks/subagentstop-envelope.ps1` is >= 85%, measured by `Invoke-PoshQCTest` with `scripts/powershell/PoshQC/settings/pester.runsettings.psd1` and recorded with the figure from `artifacts/pester/powershell-coverage.xml` in an artifact under `docs/features/active/subagentstop-envelope-core-897/evidence/qa-gates/`.
- [x] AC-25: The PowerShell toolchain passes in a single loop over all new and changed PowerShell files (helper, mirror, new suite, fixture, `claude-settings.Tests.ps1`): PoshQC format reports no changes, PSScriptAnalyzer reports zero findings, and Pester reports zero failures. Recorded under `evidence/qa-gates/`.
- [x] AC-26: Every new or changed `.ps1` file is at most 500 lines. Verified by `(Get-Content <file>).Count` for each file, recorded under `evidence/qa-gates/`.
- [x] AC-27: The E1 diff touches no file outside the scope list: `git diff --name-only epic/subagentstop-envelope-integration...HEAD` lists no `.claude/hooks/validate-*.ps1`, no file under `tests/scripts/claude-hooks/` other than `subagentstop-envelope.Tests.ps1`, no `.claude/agents/epic-orchestrator.md`, no `.codex/` path, and no `.claude/lib/hook-payload/HookPayload.psm1`.
- [x] AC-28: The E1 diff adds no Python file under `.claude/hooks/` or its bundled mirror. Verified by `git diff --name-only --diff-filter=A epic/subagentstop-envelope-integration...HEAD` listing no `.py` path under those directories.
- [x] AC-29: Every E1 commit message and the E1 pull request body reference the issue as `Refs #897` and contain no closing keyword (`close`, `closes`, `closed`, `fix`, `fixes`, `fixed`, `resolve`, `resolves`, `resolved`) applied to #897. Verified by `git log --format=%B epic/subagentstop-envelope-integration..HEAD` and `gh pr view <pr> --json body` at PR authoring time.

## Risks & Mitigations

- Technical or operational risks:
  - `exit` inside a dot-sourced function under the `&` route could terminate the Pester runner. Mitigation: early plan task verifies the behavior before the suite depends on it; fallback is option (b) from research R5 (an `-ExitAction` scriptblock seam), which would require a contract amendment recorded in this spec.
  - Fail-closed handling of an invalid envelope could loop a subagent. Mitigation: a real hook always receives a well-formed envelope (live capture), and consumers apply report-and-halt wording for unrepairable conditions.
  - `SubagentHandback` adoption would make `last_assistant_message` carry only closing text. Mitigation: recorded as a known limit; no agent uses it today.
  - Deleting the inline command removes the only token check for agents without a dedicated validator. Mitigation: that check never blocked (exit 1), so no enforcement is lost; the per-agent table records why each agent does not need it.
- Mitigations and rollbacks: revert the E1 commit; the helper has no consumer until E2-E4 merge.

## Rollout & Follow-up

- Release/rollout steps: merge E1 into `epic/subagentstop-envelope-integration`; E2, E3 and E4 rebase onto it and consume the helper. The integration-to-main PR for epic #904 closes #897.
- Post-fix monitoring or clean-up tasks: E2-E4 convert the nine validators; consider deduplicating validators registered in both settings and agent frontmatter (out of E1 scope); the `validate-pr-author-output.ps1` manifest gap remains open.
- Links: issue #897 (`issue.md`); epic `docs/features/epics/subagentstop-envelope/epic.md` (#904); research `research/research.2026-10-11T12-15.md`; live differential `evidence/other/subagentstop-live-differential.2026-10-11T12-01.md`; prior PRs #881 (#786) and #856 (#787, #840).
