# Research: subagentstop-envelope-orchestrator-family (E2, #903 / #897)

- Timestamp: 2026-10-11T15-15
- Branch: `bug/subagentstop-envelope-orchestrator-family-903` (base `origin/epic/subagentstop-envelope-integration` at `ac525c4ef`)
- Feature folder: `docs/features/active/subagentstop-envelope-orchestrator-family-903`
- Mode: preparation research only. No production, test, or policy file was changed.

## Method and Tooling Limits

- Evidence was gathered with file reads and ripgrep searches against the current tree of this worktree. Line numbers below were re-derived in this session.
- Line counts are `wc -l` equivalents. They were taken from the Read tool's "file has N lines" report minus one for the trailing newline; for the three files read end to end (`validate-orchestrator-output.ps1`, `validate-orchestrator-output.Tests.ps1`, `hook-import-failure-exemptions.FailClosed.Tests.ps1`) the last content line was confirmed directly. The 466-line figure for `validate-orchestrator-output.ps1` matches the epic's figure.
- No shell tool was available in this session, so `git fetch` and `git show` could not be run. The E1 branch state was checked by reading git refs and the E1 worktree's files instead (see "Upstream Contract").

## Summary

- All five in-scope files still use the legacy transport. Four validators read `$env:CLAUDE_HOOK_INPUT` only at their entry tail and take `output` off the parsed root; the resolution sibling performs no payload read and has no exit path. The line numbers in `issue.md` are still correct.
- E1's spec on the E1 branch is still an unfilled template, and the remote E1 ref points at the integration base (`ac525c4ef`), so no E1 commits have been pushed. E1's live differential evidence exists uncommitted in the E1 worktree. It confirms the epic Shared Design: the envelope arrives as JSON on stdin, the assistant text is in `last_assistant_message`, `output` and `CLAUDE_HOOK_INPUT` are both absent, exit 1 does not block, exit 2 does, and a blocked subagent is re-invoked with `stop_hook_active: true`.
- No Python leg exists in any of the five files or in the modules they load. The orchestrator routing check is already fully in-process (`Test-OrchestratorStateCompletionReadiness` ports `--require-complete --require-model-routing`). The "One subprocess call" text is only a stale comment (CR-7).
- `validate-orchestrator-output.ps1` (466 lines) needs a split. The recommendation is to move `Test-OrchestratorCheckpointStructure` and `Invoke-RoutingContractValidation` into a new sibling, `validate-orchestrator-output-routing.ps1`. The new file must be added to `pack-manifests/core.json`.
- Three of the five #903 / #786 notes assigned to E2 are attributed to the wrong place in `issue.md`. Only the stale-`finally` nit is in `FailClosed.Tests.ps1`. The `SilentlyContinue` nit is in a Codex test file, and the always-true conditional is in three PreToolUse hooks. All three files are outside E2's declared file set.
- Recorded coverage for `validate-executor-output.ps1` (69.91%) and `validate-required-artifact-output.ps1` (69.81%) is below the 85% floor. Changing these files obliges E2 to raise it.

## Upstream Contract (E1, #897)

- `.git/refs/remotes/origin/bug/subagentstop-envelope-core-897` and the local head both read `ac525c4efafd7aebaa6cf6bfd658e16a8c2af395`, the same commit as this branch's base. The ref was last updated by an earlier fetch, not one run in this session. No E1 commit is visible.
- The E1 worktree (registered under `.git/worktrees/agent-a22ac7fe50b3907af`) contains `docs/features/active/subagentstop-envelope-core-897/spec.md`. That file is the unfilled template (`Last Updated: 2026-10-11T07-59`, `Status: Draft`, every section empty). E1's spec is therefore not yet available, and the epic's Shared Design (`docs/features/epics/subagentstop-envelope/epic.md:75-95`) is the interim contract.
- The E1 worktree also holds uncommitted evidence: `docs/features/active/subagentstop-envelope-core-897/evidence/other/subagentstop-live-differential.2026-10-11T12-01.md`. Findings relevant to E2:
  - Lines 7-8: stdin JSON in every invocation; `CLAUDE_HOOK_INPUT` not set; `last_assistant_message` present; no `output` key.
  - Lines 9-10: exit 1 did not block; exit 2 blocked, and the re-invocation carried `stop_hook_active: true`.
  - Lines 61-65 (design consequences): the helper reads stdin and never `CLAUDE_HOOK_INPUT`; `Exit-SubagentStopBlock` exits 2; "the helper should surface [`stop_hook_active`] so validators can decide whether a second refusal is appropriate".
  - Lines 69-70 (limits): only `general-purpose` agents were exercised, so named project agents and frontmatter registration were not measured. Empty, absent, and malformed stdin were not observed.
- The helper file `.claude/hooks/subagentstop-envelope.ps1` does not exist on this branch (glob returned no match).

## Q1. Per-file Inventory

### `.claude/hooks/validate-orchestrator-output.ps1` (466 lines)

- Script parameters: `-CheckpointPath` (default `artifacts/orchestration/orchestrator-state.json`) and `-ArtifactType` (default `orchestrator-state`), at lines 39-46.
- `CLAUDE_HOOK_INPUT`: read at line 460 (`-RawPayload $env:CLAUDE_HOOK_INPUT`). The name appears in block messages at 351 and 357 and in `.NOTES` at line 31.
- `.output`: read at lines 360-363 (`$payload.PSObject.Properties.Name -contains 'output'` then `$payload.output`).
- Exit and block paths:
  - Line 456: guard bootstrap failure. `[Console]::Error.WriteLine(...)`; `exit 2`.
  - Lines 457-458: recorded dependency failure. Writes `$dependencyDecision.Reason` to stderr, then `exit $dependencyDecision.ExitCode` (2).
  - Lines 461-463: `Write-Error $result.Message`; `exit 1`. This is the fail-open path. Because `$ErrorActionPreference = 'Stop'` is set at line 60, `Write-Error` terminates the script, and `pwsh -File` reports exit 1.
  - Line 466: `exit 0`.
  - In-function blocks (`Ok = $false`) at 351, 357, 365, 372-373, 378, 382, 388, 402, 406, 418, 437, 439, and 446. Line 348 returns the dependency decision, a `[pscustomobject]` with `ExitCode` and `Reason` rather than `Ok` and `Message`. The function therefore has two return shapes, and the suites assert both (see Q3).
- Functions: `Get-CheckpointFileContent` (62, filesystem seam), `Test-HumanInteractionShape` (87-169), `Test-OrchestratorCheckpointStructure` (171-215), `Invoke-RoutingContractValidation` (217-323, with an injectable `-Invoker`), and the pure entry `Invoke-OrchestratorOutputValidation` (325-450). The entry's parameters are `-RawPayload`, `-CheckpointPath`, `-ArtifactType`, `-SessionRoot` (default `(Get-Location).Path`), and `-RoutingInvoker`.
- Dependencies, each guarded through `Add-HookDependencyFailure`:
  - 47: `hook-dependency-guard.ps1` (dot-source). Failure sets `$script:HookDependencyGuardLoadFailed`.
  - 51: `OrchestratorState.psm1` (`-Force`, no `-Global`). Duplicate of line 59.
  - 53: `validate-orchestrator-output-resolution.ps1` (dot-source).
  - 54: `WorktreeItemResolution.psm1`.
  - 55: `WorktreeRunResolution.psm1`.
  - 56: `OrchestratorStateEpicWaveBarrier.psm1`.
  - 57: `OrchestratorStateCompletion.psm1` (`-Global`).
  - 58: `OrchestratorStateUnconditional.psm1` (`-Global`).
  - 59: `OrchestratorState.psm1` (`-Global`).
  - Lines 277-279: lazy `Import-Module` of `OrchestratorStateCompletion.psm1` inside the default `Invoker`, run only when the function is absent.
- How the #786/#881 helper-based exit-2 path works (H7/H8): every guarded load records into `$script:HookDependencyFailures`. `Get-HookDependencyFailureDecision -HookEvent SubagentStop` (`hook-dependency-guard.ps1:79-114`) returns `[pscustomobject]@{ ExitCode = 2; Reason = ... }`, and the tail writes the reason to stderr and exits with that code (456-458). The decision function repeats the same check at 347-348. H7 and H8 in `FailClosed.Tests.ps1:444-473` prove the tail exits 2 when the resolver or Layer 2 import fails.

### `.claude/hooks/validate-orchestrator-output-resolution.ps1` (309 lines)

- Dot-sourced by the main hook. It has no script parameters, no `CLAUDE_HOOK_INPUT` read, no `.output` read, no `exit`, and no `Write-Error`. It returns result objects only.
- Functions: `ConvertTo-OrchestratorOutputResolution` (40), `Test-OrchestratorOutputCheckpointLeafShape` (69), `Test-OrchestratorOutputCheckpointLeaf` (100), `Find-OrchestratorOutputRunSignalValue` (129-165), `Resolve-OrchestratorOutputCheckpointPath` (167-241), `Resolve-OrchestratorOutputRunbookPath` (243), `Test-OrchestratorOutputRunbookFile` (264, filesystem seam), and `Get-OrchestratorOutputWaveBarrierDecision` (278-309, which catches port exceptions at 295-304).
- It calls exported functions of `WorktreeRunResolution.psm1` and `Get-WorktreeItemLiveRoot` only. The header (line 20) states "Starts no process and invokes no Python."

### `.claude/hooks/validate-executor-output.ps1` (296 lines)

- `param()` is empty (29-30). It has no `hook-dependency-guard.ps1`, no imports, and no dot-sources.
- `CLAUDE_HOOK_INPUT`: line 290. Named in messages at 186 and 193, and in `.NOTES` at 23.
- `.output`: lines 196-199.
- Blocks: `Write-Error` at 292 and `exit 1` at 293. In-function `Ok = $false` returns at 186, 193, 201, 206, 211, 217, 220, 226, 246, 257-258, 262, 268, and 280.
- Pure entry: `Invoke-ExecutorOutputValidation -RawPayload` (178-284). Seam: `Get-PlanFileContent` (35).

### `.claude/hooks/validate-planner-output.ps1` (416 lines)

- `param()` is empty (31-32). The guard is dot-sourced at line 33. There are no other dependencies.
- `CLAUDE_HOOK_INPUT`: line 410. Named in messages at 357 and 364, and in `.NOTES` at 25.
- `.output`: lines 367-370 (`$payload.PSObject.Properties['output']`).
- Blocks: 406 (guard bootstrap failure, `exit 2`); 407-408 (dependency decision, `exit 2`); 412-413 (`Write-Error`, `exit 1`). In-function blocks at 354 (dependency decision object), 357, 364, 372, 376, 381, 386, 392, and 397.
- Pure entry: `Invoke-PlannerOutputValidation -RawPayload` (347-401). Seam: `Get-PlanFileContent` (38).

### `.claude/hooks/validate-required-artifact-output.ps1` (171 lines)

- Script parameters: `-AgentName` and `-RequiredArtifact [string[]]` (24-29). There is no guard and no dependency.
- `CLAUDE_HOOK_INPUT`: line 163. Named in messages at 102 and 109, and in `.NOTES` at 18.
- `.output`: lines 112-115.
- Blocks: 157-160 (missing arguments: `Write-Error` then `exit 1`); 166-168 (`Write-Error`, `exit 1`). `ConvertTo-ArtifactSpec` throws at 55, which is caught at 122-127 and returned as `Ok = $false`.
- Pure entry: `Invoke-RequiredArtifactOutputValidation -RawPayload -AgentName -RequiredArtifact` (92-151). Seam: `Test-ArtifactFile` (34).

## Q2. Registrations

| Hook | `.claude/settings.json` (SubagentStop) | Agent frontmatter (`hooks: SubagentStop`) | Arguments |
|---|---|---|---|
| orchestrator | 262-270, matcher `orchestrator`, line 267 | `.claude/agents/orchestrator.md:38-42` | none |
| orchestrator (epic) | 271-279, matcher `epic-orchestrator`, line 276 | `.claude/agents/epic-orchestrator.md:25-29` | `-CheckpointPath artifacts/orchestration/epic-orchestrator-state.json -ArtifactType epic-orchestrator-state` |
| orchestrator (parallel) | 280-288, matcher `parallel-orchestrator`, line 285 | `.claude/agents/parallel-orchestrator.md:38-42` | `-CheckpointPath artifacts/orchestration/parallel-orchestrator-state.json -ArtifactType parallel-orchestrator-state` |
| planner | 235-243, matcher `atomic-planner`, line 240 | `.claude/agents/atomic-planner.md:19-23` | none |
| executor | not registered | `.claude/agents/atomic-executor.md:32-36` | none |
| required-artifact | not registered | `epic-review.md:14-18`, `prd-feature.md:14-18`, `staged-review.md:15-19`, `status-updater.md:15-19` | `-AgentName <name> -RequiredArtifact '<token|regex|description>'`; `prd-feature.md:18` passes `-RequiredArtifact` twice |

Observations:

- The orchestrator and planner hooks are registered in both settings and frontmatter. Whether Claude Code deduplicates identical commands across the two sources was not verified.
- The frontmatter blocks use the key `SubagentStop`. The Claude Code sub-agents documentation says "All hook events are supported" in frontmatter, and that `Stop` hooks in frontmatter "are automatically converted to `SubagentStop` events". It does not say whether a frontmatter `SubagentStop` key fires on the agent's own stop. E1's capture did not exercise named agents (evidence lines 69-70). The executor and required-artifact hooks are reachable only through frontmatter, so whether their conversion takes effect at runtime depends on this unresolved point.
- `prd-feature.md:18` passes `-RequiredArtifact` twice to `pwsh -File`. PowerShell normally rejects a parameter named more than once ("parameter ... is specified more than once"), which would exit 1 before the script runs. This was not run in this session, so it is a likely pre-existing defect, not a verified one.
- `tests/scripts/dev_tools/parallel_orchestrator_surface_expectations.py:160-169` pins a SHA-256 of `.claude/agents/epic-orchestrator.md`, and lines 171-175 pin the parallel-orchestrator command fragments. Any frontmatter edit to `epic-orchestrator.md` breaks that test. The conversion does not need to change any argument, so the recommendation is to change no registration.

## Q3. Test Suites

| Suite | Lines | Input route | Exit-code / shape assertions | `CLAUDE_HOOK_INPUT` / exit-1 coupling |
|---|---|---|---|---|
| `tests/scripts/claude-hooks/validate-orchestrator-output.Tests.ps1` | 454 | `-RawPayload` on the pure entry, with `{"output":...}` literals | `Ok` / `Message` | Asserts `'CLAUDE_HOOK_INPUT is empty'` (44) and `'failed to parse CLAUDE_HOOK_INPUT as JSON'` (56); `output` key at 59-80 and throughout. The no-Python AST test is at 432-452. |
| `validate-orchestrator-output.human-interaction.Tests.ps1` | 138 | calls `Test-HumanInteractionShape` directly | `Ok` / `Message` | none |
| `validate-orchestrator-output.model-routing.Tests.ps1` | 161 | `-RawPayload` with `output` | `Ok` / `Message` | `output` key |
| `validate-orchestrator-output.artifact-type-dispatch.Tests.ps1` | 330 | `-RawPayload` with `output`, plus direct `Invoke-RoutingContractValidation` | `HasErrors`, `Ok` | `output` key |
| `validate-orchestrator-output.WaveBarrier.Tests.ps1` | 250 | `-RawPayload $script:Payload` | `Ok` / `Message`; H12 at 246-248 asserts `ExitCode = 2` and `Reason` from the in-function dependency decision | `output` key |
| `validate-orchestrator-output.WorktreeResolution.Tests.ps1` | 366 | `-RawPayload` with `output` | `Ok` / `Message` | `output` key |
| `validate-orchestrator-output-resolution.Tests.ps1` | 235 | `ConvertTo-ResolutionPayload` builds `@{ output = ... }` (45-48) | S2-12 at 230-233 asserts `ExitCode = 2` | `output` key; no row pins the property-name case of `route_id` (S2-10 at 184-201 pins only value case) |
| `validate-executor-output.Tests.ps1` | 193 | `-RawPayload` | `Ok` / `Message` | Asserts `'CLAUDE_HOOK_INPUT is empty'` (14-18) |
| `validate-planner-output.Tests.ps1` | 382 | `-RawPayload` | `Ok` / `Message` | Asserts `'CLAUDE_HOOK_INPUT is empty'` (31-35); invalid JSON at 48 |
| `validate-planner-output.Coverage.Tests.ps1` | 46 | `& $script:Hook` with `$env:CLAUDE_HOOK_INPUT` set (20-32) | Asserts `Thrown` matches `'CLAUDE_HOOK_INPUT is empty'` (43-44), which pins the `Write-Error` + `exit 1` tail | Sets `CLAUDE_HOOK_INPUT`; must be rewritten |
| `validate-required-artifact-output.Tests.ps1` | 43 | `-RawPayload` (`@{ output = ... }`) | `Ok` / `Message` | `output` key; only three rows |
| `hook-import-failure-exemptions.FailClosed.Tests.ps1` | 474 | H7/H8: `& hook` with `[Console]::SetIn('')` and `$env:CLAUDE_HOOK_INPUT = '{"output":"Final summary."}'` (418-441) | `ExitCode = 2` (457, 471) | Sets `CLAUDE_HOOK_INPUT`. The stale resets are at 453 and 468. |
| `hook-dependency-failure.Claude.Tests.ps1` | 196 | `& hook` with stdin `{"session_id":"b-786","hook_event_name":"SubagentStop"}` (104-124) | B1 asserts exit 2 plus the stderr prefix (159-163); B3 asserts exit 2 (183-190) | Rows are discovered from `.claude/settings.json` only (`HookDependencyGraph.Helpers.ps1:64-84`). Orchestrator and planner are covered; executor and required-artifact are not. Prefix table at 71-102. |
| `hook-dependency-failure.SpecialCases.Tests.ps1` | 236 | `[powershell]::Create()` runspace with stdin set (82-114) | C8 asserts exit 2 (228-235) | C8 rows: hooks that assign `$ErrorActionPreference = 'Stop'` at top level and have at least one non-guard edge (27-33) |

No suite asserts `$LASTEXITCODE | Should -Be 1` for these five files. The only exit-1 coupling is the planner Coverage suite's `Thrown` assertion.

`FailClosed.Tests.ps1` nits, re-derived:

- Lines 453 and 468: `$script:OrchestratorOutputResolverImportFailure = $null` and `$script:OrchestratorOutputWaveBarrierImportFailure = $null`. A repository-wide search over `*.ps*1` finds both names only in this test file, so the variables no longer exist. The fix is to delete both `finally` bodies, or the `try`/`finally` wrappers. The guard state those tests set lives in the hook's own script scope, which `& hook` discards.
- The `-ErrorAction SilentlyContinue` nit (#786 review, `code-review.2026-10-10T22-23.md:44`) is in `tests/scripts/codex-hooks/hook-dependency-failure.Codex.Tests.ps1:42` (`Remove-Module ... -Force -ErrorAction SilentlyContinue`), not in `FailClosed.Tests.ps1`. The `if (Get-Command X -ErrorAction SilentlyContinue)` probes in `FailClosed.Tests.ps1` (for example 25-35 and 406-416) are a different, conventional pattern that the review did not flag.
- The always-true-conditional nit (review line 45) is in the H4-H6 production catch blocks of `.claude/hooks/enforce-epic-wave-barrier.ps1:60-64`, `enforce-parallel-drift-gate.ps1:85-87`, and `enforce-parallel-cohort-barrier.ps1:74-78`. Each is `if (-not $script:...ImportFailure) { ... = 'feature-folder-resolution.ps1' }`, set immediately after the variable is initialized to `$null` (53, 78, 67). These are PreToolUse hooks, which `issue.md` lists as a non-goal.

## Q4. Bundled Mirrors

- Hook mirrors exist at `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/` for all five files. No test file is mirrored, and no `.codex/hooks` copy of these validators exists.
- Enforcement:
  - `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py:89-110` requires every distributable `.claude/**` file to exist in the bundle with identical UTF-8 text. This covers any new split file and the E1 helper.
  - Lines 113-123 of the same file require byte identity for `.claude/hooks/validate-planner-output.ps1` and `.claude/agents/atomic-planner.md`.
  - `tests/scripts/dev_tools/test_push_down_claude_pack_manifest_completeness.py:139` requires every bundled `.claude` hook to appear in a pack manifest. A TypeScript counterpart is at `extensions/drm-copilot/test/lib/push-down/claude-pack-manifest-completeness.test.ts`.
- Manifest: `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json:66-77` lists the hooks in sorted order (`hook-dependency-guard.ps1` 66, `validate-executor-output.ps1` 70, `validate-orchestrator-output-resolution.ps1` 72, `validate-orchestrator-output.ps1` 73, `validate-planner-output.ps1` 74, `validate-required-artifact-output.ps1` 76). A new split file must be inserted in sorted position. For `validate-orchestrator-output-routing.ps1` that is between lines 72 and 73.

## Q5. #903 Same-file Notes

| Note | Review location | Current location | Minimal fix |
|---|---|---|---|
| CR-1 (`-ccontains` case) | resolution `:150-162` | `validate-orchestrator-output-resolution.ps1:158-159` | Replace `-ccontains 'route_id'` and `-ccontains $field` with `-contains`, matching WRR's case-insensitive `-notcontains` (`WorktreeRunResolution.psm1:173`). Keep `-cne $route` (WRR also uses `-cne`, line 190). WRR still exports no enumerator (`:490-497`), so the follow-up option of consuming one would mean editing WRR, which is outside E2. Add a resolution row: a checkpoint whose only key is `Route_Id` (or `Integration_Branch`) is kept. PowerShell 7 `ConvertFrom-Json` rejects keys that differ only in case, so the parsed object never carries both spellings. |
| CR-3 (unguarded resolver exception) | main `:476-480` | `validate-orchestrator-output.ps1:368-374` | Wrap the line-370 `Resolve-OrchestratorOutputCheckpointPath` call in `try`/`catch`. The catch returns `@{ Ok = $false; Message = ('ORCHESTRATOR_CHECKPOINT_UNRESOLVED: {0}: NoTarget (RESOLVER_FAILED): {1}' -f $ArtifactType, $_.Exception.Message) }`, keeping the existing lead token and message format. Add a row that mocks the resolver to throw and asserts the token. |
| CR-7 (stale comment) | main `:450-451` | `validate-orchestrator-output.ps1:431-435` | Reword "One subprocess call now covers both --require-complete and --require-model-routing" to state that the in-process validation (issue #475) covers both the completion and model-routing checks. Comment-only change. |
| #786 double import | main `:51,59` | `validate-orchestrator-output.ps1:51` and `:59` | Delete line 51, the non-`-Global` import, as the review recommends. Keep line 59 last, because `OrchestratorStateCompletion.psm1` re-imports `OrchestratorState.psm1` internally (comment at `validate-orchestrator-output-resolution.Tests.ps1:34-35`). This also removes a duplicate B1 row for the same dependency. |
| FailClosed `finally` | `:453,468` | same | Remove the stale resets (see Q3). |
| FailClosed `SilentlyContinue` | stated in `issue.md` | actually `tests/scripts/codex-hooks/hook-dependency-failure.Codex.Tests.ps1:42` | Outside the E2 file set. Needs a scope decision (see Risks). |
| H4-H6 always-true conditional | stated in `issue.md` | actually three PreToolUse hooks (see Q3) | Outside E2 (PreToolUse non-goal). Needs a scope decision. |

## Q6. File Split

Current state:

- `validate-orchestrator-output.ps1` is 466 lines, 34 under the cap.
- The conversion adds a guarded E1 helper dot-source, an envelope-based payload path, a CR-3 `try`/`catch` (about 5 lines), and a new tail using `Exit-SubagentStopBlock`. It removes line 51 and the `output` parse (about 17 lines become an envelope read). The net change is likely positive and would leave the file close to the cap.

Existing pattern:

- Siblings of the form `<hook>-<role>.ps1`, dot-sourced through a guarded `try { . (Join-Path $PSScriptRoot '<sibling>.ps1') } catch { Add-HookDependencyFailure ... }`. Examples: `validate-orchestrator-output-resolution.ps1` (main line 53), `enforce-parallel-drift-gate-helpers.ps1` (`enforce-parallel-drift-gate.ps1:91`), and `enforce-orchestration-preimplementation-gate-modes.ps1`.

Recommended split:

- New file `.claude/hooks/validate-orchestrator-output-routing.ps1`. It receives `Test-OrchestratorCheckpointStructure` (lines 171-215, 45 lines) and `Invoke-RoutingContractValidation` (lines 217-323, 107 lines), plus a header in the style of the resolution sibling. Estimated size is about 170 lines.
- The main file keeps `Get-CheckpointFileContent`, `Test-HumanInteractionShape`, `Invoke-OrchestratorOutputValidation`, and the tail. It is estimated at about 320-330 lines after conversion.
- Load the new file next to line 53: `try { . (Join-Path $PSScriptRoot 'validate-orchestrator-output-routing.ps1') } catch { Add-HookDependencyFailure -Name 'validate-orchestrator-output-routing.ps1' -ErrorRecord $_ }`.
- Rationale:
  - The two functions form the routing-contract dispatch, which is one concern.
  - The default `Invoker` uses `$PSScriptRoot`. In a dot-sourced file that resolves to the same `.claude/hooks` directory, so `'../lib/orchestrator-state/OrchestratorStateCompletion.psm1'` (line 278) still resolves.
  - Test callers dot-source the main hook and therefore still receive the functions.
  - The AST test at `validate-orchestrator-output.Tests.ps1:437` reads `${function:Invoke-RoutingContractValidation}.Ast`, which still works.
- Rejected alternative: move `Test-HumanInteractionShape` (83 lines) to `validate-orchestrator-output-human-interaction.ps1`. It is viable but frees less headroom.
- Effects on the dynamic suites:
  - B1 (`hook-dependency-failure.Claude.Tests.ps1:134`) will generate a row for the new dot-source edge automatically and requires exit 2 with the `ORCHESTRATOR_CHECKPOINT_UNRESOLVED:` prefix. The guarded pattern above satisfies it.
  - C8 already includes this hook.
  - The new file must be added to `core.json` and mirrored.

Other in-scope files within 40 lines of 500:

- `tests/scripts/claude-hooks/hook-import-failure-exemptions.FailClosed.Tests.ps1` is 474 lines. The H7/H8 rewrite must not grow it by more than 25 lines. Removing the stale `finally` blocks frees about 8 lines.
- `validate-orchestrator-output.Tests.ps1` (454 lines, 46 under) is outside the 40-line band but close. New rows (CR-1, CR-3, entry-point exit 2) should go in the resolution suite (235 lines) or a new suite rather than this file.

## Q7. Python Legs

- A search of the five hook files for `poetry`, `python`, `py`, and `Start-Process` finds only:
  - comment text at `validate-orchestrator-output.ps1:176` and `:235`, which describe the Python reference;
  - a regex literal at `validate-executor-output.ps1:265` (`'(?i)(Commands Run|Command[s]?:|poetry run |npx |pwsh |git |mcp__drm-copilot__)'`), which inspects agent output text and runs nothing.
- Searches of `.claude/lib/orchestrator-state/*.psm1` and `.claude/lib/worktree-resolution/*.psm1` for invocations (`& python`, `& poetry`, `poetry run`, `Start-Process`, `ProcessStartInfo`) return no match. Other matches are comments. `Get-WorktreeItemLiveRoot` (`WorktreeItemResolution.psm1:180-214`) uses filesystem markers, not a process.
- `Invoke-RoutingContractValidation`'s header (217-259) states that since #475 the default `Invoker` "names no interpreter and starts no subprocess". `OrchestratorStateCompletion.psm1:9` and `:364` show that `Test-OrchestratorStateCompletionReadiness` ports `orchestrator-state --require-complete --require-model-routing`.
- Existing guards: the AST assertion at `validate-orchestrator-output.Tests.ps1:432-452` and the repository-wide `tests/scripts/claude-runtime/enforcement-hooks-no-python-invocation.Tests.ps1`.
- Conclusion: there is no Python call to remove, so removing one is not in E2 scope. CR-7 is the only related item, and it is a comment fix. The enforcement-hooks-must-not-use-Python rule (epic NFR and `issue.md:51`) is already met by these files.

## Q8. Coverage Tooling

- Population: `config/poshqc-coverage.json` declares roots including `.claude/hooks` and `.claude/lib`. Any new file under `.claude/hooks` enters the denominator automatically, and no per-file entry is needed. Runsettings are in `scripts/powershell/PoshQC/settings/pester.runsettings.psd1:17-27`, output to `artifacts/pester/powershell-coverage.xml`. Population precedence is described in `scripts/powershell/PoshQC/README.md:70-75`.
- The MCP PoshQC runner loads the installed-extension module. The #787 review (CR-6, `code-review.2026-10-09T00-12.md:39`) recorded that its coverage artifact omitted about 60 population files, including new files. The established workaround is a self-hosted run:
  - A per-file Pester run like the `#787` plan's `pester-coverage.ps1` (`docs/features/active/2026-09-29-validate-orchestrator-output-session-relative-read-787/plan.2026-10-08T13-54.md:926-960`): `New-PesterConfiguration`, `CodeCoverage.Enabled = $true`, `CodeCoverage.Path = <changed files>`, `Invoke-Pester`, then summing `CommandsExecuted` and `CommandsMissed` per file.
  - Or `Import-Module scripts/powershell/PoshQC/PoshQC.psd1 -Force; Invoke-PoshQCTest -Root .` with a caller `-SettingsPath` whose `CodeCoverage.Path` lists the target files (precedence 1).
  - Either run should be launched through `sh <script>` with `pwsh -NoProfile -NonInteractive -File`, because the worktree isolation guard denies direct `pwsh` text.
- Most recent recorded values:
  - `validate-orchestrator-output.ps1`: 95.42% (125/131).
  - `validate-orchestrator-output-resolution.ps1`: 98.94% (93/94).
  - `validate-planner-output.ps1`: 97.94% (190/194).
  - These three are from `docs/features/active/2026-09-29-hook-preexisting-imports-fail-open-786/evidence/qa-gates/r2-final-pester-coverage.md:164-169`, dated 2026-10-10.
  - `validate-executor-output.ps1`: 69.91% (79/113).
  - `validate-required-artifact-output.ps1`: 69.81% (37/53).
  - These two are from `docs/features/active/2026-08-23-poshqc-coverage-denominator-not-reproducible-527/evidence/qa-gates/coverage-aggregate.2026-10-02T08-45.md:40,50`, dated 2026-10-02.
- The executor and required-artifact values are below the 85% floor. E2 changes both files, so E2 must raise them. Their entry tails are currently untested, and the required-artifact suite has three rows. Re-measure at baseline, because these values predate this branch.

## Q9. Conflict Boundary with E3 and E4

- Production files: E3 owns `validate-discovery-artifact-gate.ps1`, `validate-pr-author-output.ps1`, `validate-prd-feature-output.ps1`, and `validate-task-researcher-output.ps1`. E4 owns `validate-feature-review-coverage.ps1` (plus `feature-review-coverage-thresholds.ps1` and Codex files). None of these is in E2's set, so the production files are disjoint.
- Test files: the E3/E4 suites (`validate-discovery-artifact-gate*.Tests.ps1`, `validate-pr-author-output*.Tests.ps1`, `validate-prd-feature-output*.Tests.ps1`, `validate-task-researcher-output.Tests.ps1`, `validate-feature-review-coverage*.Tests.ps1`, `feature-review-coverage-thresholds.Tests.ps1`, `tests/scripts/codex-hooks/validate-feature-review-coverage.Coverage.Tests.ps1`) do not reference any E2 file. The search for E2 hook names under `tests/` matched none of them.
- Shared surfaces that more than one child may touch:
  - `pack-manifests/core.json:66-77`. E1 adds `subagentstop-envelope.ps1` near line 66, E2 adds a split file near 72-73, and E4's split for the 477-line `validate-feature-review-coverage.ps1` would land near line 71. These adjacent insertions in one JSON array are a likely textual merge conflict at fan-in, even though they are not semantic conflicts.
  - `hook-dependency-failure.Claude.Tests.ps1` (prefix table 71-102) and `hook-dependency-failure.SpecialCases.Tests.ps1` (`StopPrefix` 53-58) contain E2, E3, and E4 entries. Rows are discovered dynamically, so no edit is needed unless a child changes a hook's reason prefix or registers a new hook in `.claude/settings.json`.
  - `.claude/agents/prd-feature.md` carries both E2's `validate-required-artifact-output.ps1` (line 18) and E3's `validate-prd-feature-output.ps1` (line 20). Neither needs a registration change if arguments are preserved.
  - `tests/scripts/claude-hooks/EpicStateIsolation.Baseline.Helpers.ps1` and `tests/scripts/claude-runtime/HookDependencyGraph.Helpers.ps1` are shared helpers that no child is expected to edit.

## Numeric Derivation Evidence

Claim: the E2 bundled hook-mirror family has five members.

- Complete Family: bundled mirrors of the five E2 hook files under `extensions/drm-copilot/resources/`.
- Exhaustive Search Scope: every path under `extensions/drm-copilot/resources/**`, plus the pack manifest `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json`.
- Inclusion Rules: a file whose basename is one of `validate-orchestrator-output.ps1`, `validate-orchestrator-output-resolution.ps1`, `validate-executor-output.ps1`, `validate-planner-output.ps1`, or `validate-required-artifact-output.ps1`.
- Exclusion Rules: test files, agent and skill markdown that only mention a hook name, and E3/E4 hooks.
- Primary Search Strategy or Query Expression: glob `extensions/drm-copilot/resources/**/validate-{orchestrator-output,orchestrator-output-resolution,executor-output,planner-output,required-artifact-output}*`.
- Primary Member Set: `.claude/hooks/validate-executor-output.ps1`, `.claude/hooks/validate-orchestrator-output-resolution.ps1`, `.claude/hooks/validate-orchestrator-output.ps1`, `.claude/hooks/validate-planner-output.ps1`, `.claude/hooks/validate-required-artifact-output.ps1` (all under `claude-customizations/`).
- Primary Count: 5.
- Cross-check Search Strategy or Query Expression: regex `validate-(orchestrator-output|executor-output|planner-output|required-artifact-output)|hook-dependency-guard|subagentstop` over `core.json`, keeping only E2 members.
- Cross-check Member Set: `core.json:70` executor, `:72` orchestrator-resolution, `:73` orchestrator, `:74` planner, `:76` required-artifact.
- Cross-check Count: 5.
- Member-set Comparison: after normalizing to `.claude/hooks/<basename>`, both sets are identical. No member is missing, duplicated, or extra.

No other numeric acceptance-criterion claim is proposed. The per-file occurrence counts of the `output` key in Q3 are informational and are not intended for acceptance-criterion use.

## Risks and Open Questions

1. **E1 contract not frozen.** E1's spec is a template. The return shape of `Read-SubagentStopEnvelope`, its behavior on empty or malformed stdin, and whether it exposes `stop_hook_active` are undefined. E2's entry-point signature depends on all three. The recommendation is that the pure entry take the parsed envelope, or the assistant text, as a parameter, and that only the tail call `Read-SubagentStopEnvelope`. Confirm this against E1's spec at the wave-2 upstream-merge check.
2. **`stop_hook_active` re-entry policy.** With exit 2, a subagent that cannot satisfy a gate is re-invoked indefinitely. The Layer 2 message instructs the agent to "Report them to the operator and halt" (`validate-orchestrator-output-resolution.ps1:37`), which exit 2 prevents. A policy is needed, for example blocking once and then allowing on `stop_hook_active: true` for specific reasons, or always blocking. It must be stated in E1's or E2's spec.
3. **Frontmatter `SubagentStop` key.** The executor and all four required-artifact registrations exist only in frontmatter under the `SubagentStop` key. Whether that fires is unmeasured (see Q2). If it does not, converting those two hooks has no runtime effect until the registration key is changed. Changing the key would touch agent files and mirrors, and the `epic-orchestrator.md` pinned hash if applied there.
4. **Duplicate `-RequiredArtifact` in `prd-feature.md:18`.** This likely fails parameter binding (unverified). If confirmed, it is a pre-existing defect in an E2 hook's registration. Fixing it requires a frontmatter change in a file E3 also reads.
5. **Guard placement relative to `$ErrorActionPreference = 'Stop'`.** In `validate-planner-output.ps1`, `Stop` is set at line 36. A guarded dot-source of the E1 helper placed after it would run its `catch` (which calls `Add-HookDependencyFailure`) under `Stop`. When the guard also failed to load, that catch hits an undefined command. Per PowerShell semantics this may become script-terminating and exit 1. C8 (`SpecialCases.Tests.ps1:228-235`) would detect it. Place every guarded load before the `Stop` assignment, as the orchestrator hook does (lines 51-60).
6. **Executor and required-artifact have no dependency guard.** If they dot-source the E1 helper, a load failure leaves `Exit-SubagentStopBlock` undefined. Adopt the `hook-dependency-guard.ps1` pattern, or write stderr and `exit 2` directly. The B-suite does not cover these hooks because they are absent from `.claude/settings.json`, so E2 must add explicit tests.
7. **Two return shapes from `Invoke-OrchestratorOutputValidation` and `Invoke-PlannerOutputValidation`** (`Ok`/`Message` versus `ExitCode`/`Reason`). Under `Set-StrictMode -Version Latest`, reading `.Ok` on the dependency-decision object would throw. Today the tail pre-empts that path. Normalizing to one shape would require editing WaveBarrier H12 and resolution S2-12. Keeping both is acceptable if the tail continues to check the dependency decision first.
8. **Scope discrepancy in `issue.md`.** The `SilentlyContinue` nit (Codex test) and the H4-H6 conditional (three PreToolUse hooks) are outside E2's file set. Decide to exclude them and record that in the spec, or extend scope to `tests/scripts/codex-hooks/hook-dependency-failure.Codex.Tests.ps1` and the three PreToolUse hooks with their mirrors. Extending to the PreToolUse hooks conflicts with the stated non-goal.
9. **Coverage below floor** for executor (69.91%) and required-artifact (69.81%). The plan must budget tests for both to reach at least 85%.
10. **`core.json` fan-in merge conflict** with E1 and E4 (see Q9).
11. **No git access in this session.** The E1 branch state is inferred from refs as of the last fetch and from uncommitted files in the E1 worktree. Re-check after E1 pushes.

## Recommended Plan Inputs

Production (all under `.claude/hooks/`):

| File | Lines | Change |
|---|---|---|
| `validate-orchestrator-output.ps1` | 466 | Envelope read through the E1 helper; tail uses `Exit-SubagentStopBlock`; delete line 51; CR-3 try/catch at 370; CR-7 comment at 431-435; dot-source the new routing sibling; update `.NOTES` (30-36) and messages (351, 357) |
| `validate-orchestrator-output-routing.ps1` | new, about 170 | Receives lines 171-323 |
| `validate-orchestrator-output-resolution.ps1` | 309 | CR-1: `-ccontains` to `-contains` at 158-159 |
| `validate-executor-output.ps1` | 296 | Guard plus helper; envelope; exit 2 at 290-293; messages 186, 193; `.NOTES` 22-26 |
| `validate-planner-output.ps1` | 416 | Helper dot-source before line 36; envelope; exit 2 at 410-413; messages 357, 364; `.NOTES` 24-28 |
| `validate-required-artifact-output.ps1` | 171 | Guard plus helper; envelope; exit 2 for both blocks (157-160, 166-168); messages 102, 109; `.NOTES` 17-21 |

Tests (under `tests/scripts/claude-hooks/` unless stated):

| File | Lines | Change |
|---|---|---|
| `validate-orchestrator-output.Tests.ps1` | 454 | Payload key `output` to `last_assistant_message` (or envelope parameter); messages at 44, 56; add no new rows here (cap headroom) |
| `validate-orchestrator-output.model-routing.Tests.ps1` | 161 | Payload shape |
| `validate-orchestrator-output.artifact-type-dispatch.Tests.ps1` | 330 | Payload shape |
| `validate-orchestrator-output.WaveBarrier.Tests.ps1` | 250 | Payload shape |
| `validate-orchestrator-output.WorktreeResolution.Tests.ps1` | 366 | Payload shape |
| `validate-orchestrator-output-resolution.Tests.ps1` | 235 | Payload helper at 45-48; add CR-1 and CR-3 rows |
| `validate-orchestrator-output.human-interaction.Tests.ps1` | 138 | Likely unchanged |
| `validate-executor-output.Tests.ps1` | 193 | Payload shape; message at 18; add entry-point exit-2 rows and coverage rows |
| `validate-planner-output.Tests.ps1` | 382 | Payload shape; messages at 35, 48 |
| `validate-planner-output.Coverage.Tests.ps1` | 46 | Replace the `CLAUDE_HOOK_INPUT` driver with `[Console]::SetIn`; assert exit 2 |
| `validate-required-artifact-output.Tests.ps1` | 43 | Payload shape; add rows for coverage, argument validation (exit 2), and entry tail |
| `hook-import-failure-exemptions.FailClosed.Tests.ps1` | 474 | H7/H8 driver: drop the `CLAUDE_HOOK_INPUT` set (424, 430, 438); remove the stale `finally` (453, 468) |
| New: `validate-orchestrator-output.Envelope.Tests.ps1` (or similar) | new | Entry-point rows: stdin envelope, exit 2 on block, exit 0 on pass, no `CLAUDE_HOOK_INPUT` read |
| `hook-dependency-failure.Claude.Tests.ps1` / `.SpecialCases.Tests.ps1` | 196 / 236 | Expected unchanged (dynamic rows); run as regression |
| `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py`, `test_push_down_claude_pack_manifest_completeness.py` | n/a | Run as regression (mirror and manifest) |

Mirrors and manifest:

- `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/` copies of all six production files, five existing and one new.
- `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json`: insert `.claude/hooks/validate-orchestrator-output-routing.ps1` between lines 72 and 73.

No change recommended:

- `.claude/settings.json` (E1 owns the inline command).
- `.claude/agents/*.md` frontmatter, unless Risk 3 or Risk 4 is resolved toward a change.
- `.codex/hooks/*`.
