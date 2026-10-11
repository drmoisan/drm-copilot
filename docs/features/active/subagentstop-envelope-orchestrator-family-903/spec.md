# subagentstop-envelope-orchestrator-family (Spec)

- **Issue:** #903 (canonical key); delivers part of #897
- **Parent (optional):** epic subagentstop-envelope (#904), child E2
- **Owner:** drmoisan
- **Last Updated:** 2026-10-11T16-00
- **Status:** Draft
- **Version:** 0.2
- **Work Mode:** full-bug (acceptance criteria live in this file only; no `user-story.md`)
- **Branch:** `bug/subagentstop-envelope-orchestrator-family-903`, targeting `epic/subagentstop-envelope-integration`
- **Upstream dependency:** E1 (#897, branch `bug/subagentstop-envelope-core-897`, folder hint `subagentstop-envelope-core-897`)
- **Research record:** `docs/features/active/subagentstop-envelope-orchestrator-family-903/research/research.2026-10-11T15-15.md` (current-state findings and line citations; line numbers below are taken from it and must be re-derived before editing)

## Context

- Issue #897 records that the SubagentStop completion-gate validators under `.claude/hooks/` read the hook payload from the `CLAUDE_HOOK_INPUT` environment variable, take the assistant text from an `output` property on the parsed root, and block with `Write-Error` followed by `exit 1`. The documented SubagentStop envelope arrives as JSON on stdin, carries the assistant text in `last_assistant_message`, and only exit code 2 blocks. PR #881 (#786) established that `Write-Error` followed by `exit 1` does not block in this family.
- Impact: these validators are completion gates. While they are inert, a subagent can report completion without the artifact that proves it. `validate-orchestrator-output.ps1` is the gate that refuses a DONE lacking model-routing receipts. Severity is High (from #897).
- This child (E2) converts the orchestrator, executor, planner, and required-artifact validators to the shared E1 helper, splits `validate-orchestrator-output.ps1` to stay under the 500-line cap, and resolves the #903 review notes that fall in those same files.
- Issue #903 collects accepted non-blocking review notes from round-2 items; only the notes located in E2's file set are in scope here.
- Observed environment: Claude Code SubagentStop hooks invoked as `pwsh -File` commands, registered in `.claude/settings.json` and in `.claude/agents/*.md` frontmatter.
- First observed: recorded in #897 (update of 2026-10-11, against main at 2ef8d361) and confirmed by E1's live differential evidence.

## Repro & Evidence

- Steps to reproduce:
  1. Invoke any E2 validator (for example `.claude/hooks/validate-planner-output.ps1`) as a SubagentStop hook with a stdin envelope whose `last_assistant_message` lacks the required artifact (for the planner, no `plan-path:` line and no `PREFLIGHT:` signal).
  2. Observe that `CLAUDE_HOOK_INPUT` is unset, so the validator reports `CLAUDE_HOOK_INPUT is empty` through `Write-Error` and exits 1.
  3. Observe that the subagent stop is not blocked.
- Expected: the validator reads the stdin envelope, evaluates `last_assistant_message`, and blocks with exit 2 and a stderr reason when the artifact is missing; it exits 0 when the artifact is present and valid.
- Actual: the validator never sees the envelope, and its block path uses exit 1, which the runtime does not treat as a block.
- Evidence (research Upstream Contract section, citing E1's uncommitted live differential `docs/features/active/subagentstop-envelope-core-897/evidence/other/subagentstop-live-differential.2026-10-11T12-01.md`): stdin JSON present in every invocation; `CLAUDE_HOOK_INPUT` not set; `last_assistant_message` present; no `output` key; exit 1 did not block; exit 2 blocked, and the re-invocation carried `stop_hook_active: true`.
- Current legacy-transport locations (research Q1):

  | File | `.output` read | `CLAUDE_HOOK_INPUT` read | `exit 1` block |
  |---|---|---|---|
  | `.claude/hooks/validate-executor-output.ps1` | 196-199 | 290 | 292-293 |
  | `.claude/hooks/validate-orchestrator-output.ps1` | 360-363 | 460 | 461-463 |
  | `.claude/hooks/validate-planner-output.ps1` | 367-370 | 410 | 412-413 |
  | `.claude/hooks/validate-required-artifact-output.ps1` | 112-115 | 163 | 157-160 (missing arguments) and 166-168 (validation failure) |

  `.claude/hooks/validate-orchestrator-output-resolution.ps1` is dot-sourced by the orchestrator hook and has no payload read and no exit path.
- Frequency: deterministic. Every invocation under the documented transport is affected.

## Scope & Non-Goals

### In scope

1. Convert the following validators to the E1 helper (stdin envelope, assistant text from `last_assistant_message`, exit 2 on every block path):
   - `.claude/hooks/validate-orchestrator-output.ps1` together with `.claude/hooks/validate-orchestrator-output-resolution.ps1`
   - `.claude/hooks/validate-executor-output.ps1`
   - `.claude/hooks/validate-planner-output.ps1`
   - `.claude/hooks/validate-required-artifact-output.ps1`, including both of its current `exit 1` paths (missing `-AgentName`/`-RequiredArtifact` arguments, and validation failure)
2. Split `validate-orchestrator-output.ps1` into the main file and a new sibling `.claude/hooks/validate-orchestrator-output-routing.ps1` (see Proposed Fix).
3. Update the affected Pester suites under `tests/scripts/claude-hooks/` and add the suites named in Test Strategy.
4. Update the bundled mirrors under `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/` so each is byte-identical to its source, add a mirror for the new routing sibling, and add the new file to `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json` in sorted position.
5. Check the `.claude/agents/*.md` frontmatter registrations that pass arguments to these hooks and keep them consistent with the converted scripts' parameters (research Q2). No registration change is planned; the conversion preserves every script parameter.
6. Same-file #903 notes:
   - #787 CR-1: replace `-ccontains` with `-contains` at `validate-orchestrator-output-resolution.ps1:158-159`.
   - #787 CR-3: guard the `Resolve-OrchestratorOutputCheckpointPath` call (`validate-orchestrator-output.ps1:370`) so a resolver exception blocks with the `ORCHESTRATOR_CHECKPOINT_UNRESOLVED:` prefix via exit 2 rather than surfacing as an unhandled error.
   - #787 CR-7: remove or correct the stale "One subprocess call now covers both --require-complete and --require-model-routing" comment (`validate-orchestrator-output.ps1:431-435`).
   - #786 double import: remove the duplicate non-`-Global` import of `OrchestratorState.psm1` at `validate-orchestrator-output.ps1:51`, keeping the `-Global` import at line 59 last in the import sequence.
   - #786 FailClosed nit: remove the stale `finally` resets at `tests/scripts/claude-hooks/hook-import-failure-exemptions.FailClosed.Tests.ps1:453` and `:468` (the variables `$script:OrchestratorOutputResolverImportFailure` and `$script:OrchestratorOutputWaveBarrierImportFailure` exist nowhere else in the repository).

### Out of scope / non-goals

| Item | Reason |
|---|---|
| #786 always-true conditional in the H4-H6 catch blocks | The code is in `.claude/hooks/enforce-epic-wave-barrier.ps1:60-64`, `enforce-parallel-drift-gate.ps1:85-87`, and `enforce-parallel-cohort-barrier.ps1:74-78` (research Q3), not in `FailClosed.Tests.ps1`. These are PreToolUse hooks, which are an epic non-goal. |
| #786 overly broad `-ErrorAction SilentlyContinue` | The code is in `tests/scripts/codex-hooks/hook-dependency-failure.Codex.Tests.ps1:42` (research Q3), a Codex test outside E2's file set. |
| All other #903 notes, including the evidence-filename timestamp defect | They are not located in E2's files (epic Non-Goals). |
| E3-owned validators `validate-discovery-artifact-gate.ps1`, `validate-pr-author-output.ps1`, `validate-prd-feature-output.ps1`, `validate-task-researcher-output.ps1`, and their suites | Owned by sibling child E3; disjoint file set (research Q9). |
| E4-owned `validate-feature-review-coverage.ps1`, `feature-review-coverage-thresholds.ps1`, feature-review skills, Codex files | Owned by sibling child E4. |
| The E1 helper `.claude/hooks/subagentstop-envelope.ps1`, its tests and mirror, and the inline SubagentStop command in `.claude/settings.json` | Owned by E1. E2 consumes the helper and does not edit it. |
| `.claude/agents/prd-feature.md` frontmatter | E3's agent. The likely duplicate `-RequiredArtifact` binding defect at line 18 is recorded as an open question only. |
| Any new validation rule beyond transport, shape, exit code, and the listed notes | Epic Non-Goals. |
| `.codex/hooks/*` | No Codex copy of these validators exists (research Q4). |

### Explicitly excluded systems

- `.claude/settings.json` registrations and matchers (E1).
- The shared dynamic suites `tests/scripts/claude-hooks/hook-dependency-failure.Claude.Tests.ps1` and `hook-dependency-failure.SpecialCases.Tests.ps1`, and the shared helpers `tests/scripts/claude-runtime/HookDependencyGraph.Helpers.ps1` and `tests/scripts/claude-hooks/EpicStateIsolation.Baseline.Helpers.ps1`. They are run as regression and are not edited unless a reason prefix changes, which this spec forbids.

## Root Cause Analysis

- Confirmed root cause: the validators were written against an assumed transport (`CLAUDE_HOOK_INPUT`, root `output` property, `exit 1` as block). The measured transport is stdin JSON with `last_assistant_message`, and only exit 2 blocks.
- Supporting evidence: E1's live differential (cited above); PR #881 (#786) result that `Write-Error` plus `exit 1` does not block; research Q1 inventory showing each validator reads `$env:CLAUDE_HOOK_INPUT` only at its entry tail.
- Contributing factor: the test suites drive the pure entry points with `-RawPayload` strings shaped as `{"output": ...}` and assert messages that name `CLAUDE_HOOK_INPUT` (research Q3), so they pinned the assumed transport instead of the documented one. `validate-planner-output.Coverage.Tests.ps1` and the FailClosed H7/H8 rows set `$env:CLAUDE_HOOK_INPUT` directly.
- Affected components: the five hook files listed in scope, their Pester suites, their bundled mirrors, and `pack-manifests/core.json`.

## Proposed Fix

### Design summary (what changes where)

- Each validator dot-sources `.claude/hooks/subagentstop-envelope.ps1` through a guarded load, calls `Read-SubagentStopEnvelope` only in its entry tail, passes the returned envelope to its pure entry point, and blocks through `Exit-SubagentStopBlock -Message <text>` on every block path.
- The pure entry points (`Invoke-OrchestratorOutputValidation`, `Invoke-ExecutorOutputValidation`, `Invoke-PlannerOutputValidation`, `Invoke-RequiredArtifactOutputValidation`) take the envelope (or the assistant text drawn from it) as a parameter instead of a raw `CLAUDE_HOOK_INPUT` string. The parameter is the test seam; no environment variable is used.
- `validate-orchestrator-output.ps1` moves `Test-OrchestratorCheckpointStructure` (lines 171-215) and `Invoke-RoutingContractValidation` (lines 217-323) into the new `validate-orchestrator-output-routing.ps1`, loaded with the guarded dot-source pattern used for the resolution sibling.

### Boundaries and invariants to preserve

- Existing stderr reason prefixes are preserved: `ORCHESTRATOR_CHECKPOINT_UNRESOLVED:` (orchestrator dependency and resolution failures), `validate-planner-output:` (planner dependency failures), `MODEL_ROUTING_BLOCKED:`, and `ROUTING_CONTRACT_BLOCKED:`. The B1 prefix table in `hook-dependency-failure.Claude.Tests.ps1:71-102` depends on them.
- The dependency-decision path (`[pscustomobject]` with `ExitCode` and `Reason`) continues to be checked before any read of `.Ok`, so the two return shapes of `Invoke-OrchestratorOutputValidation` and `Invoke-PlannerOutputValidation` remain safe under `Set-StrictMode -Version Latest` (research Risk 7). WaveBarrier H12 and resolution S2-12 keep their assertions.
- Every guarded load (guard, E1 helper, routing sibling, modules) is placed before the `$ErrorActionPreference = 'Stop'` assignment in its file, as the orchestrator hook does today (research Risk 5).
- Script parameters are unchanged: `-CheckpointPath` and `-ArtifactType` on the orchestrator hook; `-AgentName` and `-RequiredArtifact [string[]]` on the required-artifact hook; empty `param()` on executor and planner. This keeps every frontmatter registration valid without edits.
- The routing sibling's default `Invoker` continues to resolve `../lib/orchestrator-state/OrchestratorStateCompletion.psm1` relative to `$PSScriptRoot`, which is unchanged for a dot-sourced file in the same directory.
- No validation rule is added, removed, or loosened, apart from the listed notes.

### Dependencies or blocked work

- E2 consumes E1's contract. The authoritative contract is E1's spec, the `spec.md` in E1's active feature folder (folder hint `subagentstop-envelope-core-897`) once E1 merges into `epic/subagentstop-envelope-integration`. At the time of writing, that spec is an unfilled template (research Upstream Contract), so the epic Shared Design (`docs/features/epics/subagentstop-envelope/epic.md`, section "Shared Design") is the interim statement of it:
  - Helper file `.claude/hooks/subagentstop-envelope.ps1`, dot-sourced by each validator, with a bundled mirror.
  - `Read-SubagentStopEnvelope`: reads the hook payload from stdin, parses it as JSON, and returns the parsed envelope with the assistant text taken from `last_assistant_message`. Behavior on empty, absent, or malformed stdin is defined by E1.
  - `Exit-SubagentStopBlock -Message <text>`: writes the reason to stderr and exits with code 2.
  - No reads of `CLAUDE_HOOK_INPUT` for a SubagentStop decision. Any test seam is a parameter on the validator's pure entry point, not an environment variable.
- Where E1's merged spec differs from the interim statement, E1's spec governs.
- **Upstream gate.** Execution begins with an upstream-merge check that confirms:
  1. E1 is merged into `origin/epic/subagentstop-envelope-integration` (after `git fetch origin`).
  2. `.claude/hooks/subagentstop-envelope.ps1` exists on that ref.
  3. That file defines functions named exactly `Read-SubagentStopEnvelope` and `Exit-SubagentStopBlock`.
  4. E1's spec is present on that ref and its contract is reconciled with this spec.
  If any check fails, execution stops and reports the failing check. The executor must not create, copy, stub, or improvise a helper.

### Implementation strategy (what changes, not sequencing)

#### Files/modules to change

Production (under `.claude/hooks/`):

| File | Change |
|---|---|
| `validate-orchestrator-output.ps1` | Guarded E1 helper load; guarded load of the routing sibling next to the resolution sibling load (line 53); delete line 51; envelope-based payload path replacing lines 350-366; CR-3 `try`/`catch` around line 370; CR-7 comment rewrite at 431-435; tail uses `Read-SubagentStopEnvelope` and `Exit-SubagentStopBlock`; update `.NOTES` (30-36) and block messages (351, 357) so none names `CLAUDE_HOOK_INPUT` |
| `validate-orchestrator-output-routing.ps1` (new) | Receives `Test-OrchestratorCheckpointStructure` and `Invoke-RoutingContractValidation` unchanged in behavior, with a header in the style of the resolution sibling |
| `validate-orchestrator-output-resolution.ps1` | CR-1 at 158-159; keep `-cne $route` |
| `validate-executor-output.ps1` | Adopt the `hook-dependency-guard.ps1` pattern (or an equivalent stderr-plus-exit-2 fallback) so a helper load failure blocks with exit 2; envelope path; tail at 290-293; messages at 186, 193; `.NOTES` 22-26 |
| `validate-planner-output.ps1` | Helper load placed before line 36; envelope path; tail at 410-413; messages at 357, 364; `.NOTES` 24-28 |
| `validate-required-artifact-output.ps1` | Guarded helper load with an exit-2 fallback; envelope path; both block paths (157-160 and 166-168) exit 2; messages at 102, 109; `.NOTES` 17-21 |

Tests (under `tests/scripts/claude-hooks/`): see Test Strategy.

Mirrors and manifest:

- `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/` copies of every changed or added production file above.
- `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json`: insert `.claude/hooks/validate-orchestrator-output-routing.ps1` between the `validate-orchestrator-output-resolution.ps1` entry (line 72) and the `validate-orchestrator-output.ps1` entry (line 73).

Agent frontmatter: no change. The registrations in `.claude/agents/orchestrator.md`, `epic-orchestrator.md`, `parallel-orchestrator.md`, `atomic-planner.md`, `atomic-executor.md`, `epic-review.md`, `prd-feature.md`, `staged-review.md`, and `status-updater.md` are checked for parameter consistency only. `epic-orchestrator.md` is hash-pinned by `tests/scripts/dev_tools/parallel_orchestrator_surface_expectations.py:160-169`, so an edit to it would break that test.

#### Functions/classes/CLI commands impacted

- `Invoke-OrchestratorOutputValidation`, `Invoke-ExecutorOutputValidation`, `Invoke-PlannerOutputValidation`, `Invoke-RequiredArtifactOutputValidation`: input parameter changes from `-RawPayload` (raw `CLAUDE_HOOK_INPUT` string) to the envelope or assistant text, per E1's contract.
- `Test-OrchestratorCheckpointStructure`, `Invoke-RoutingContractValidation`: relocated, behavior unchanged.
- `Find-OrchestratorOutputRunSignalValue` (resolution sibling): property-name membership becomes case-insensitive (CR-1).
- Entry tails of all converted hooks.

#### Data flow and validation changes

- Before: `$env:CLAUDE_HOOK_INPUT` -> `ConvertFrom-Json` -> `$payload.output` -> validation -> `Write-Error` + `exit 1` on block.
- After: stdin -> `Read-SubagentStopEnvelope` -> envelope (assistant text from `last_assistant_message`) -> pure entry point -> `Exit-SubagentStopBlock -Message <reason>` (stderr, exit 2) on block, `exit 0` on pass.
- Empty, absent, or malformed stdin is handled as E1's spec defines. Where the pure entry receives an envelope whose assistant text is empty or whitespace, it returns a block decision, as it does today for an empty `output`.

#### Error handling and logging updates

- Every block path writes one reason line to stderr and exits 2. No block path uses `Write-Error` or `exit 1`.
- CR-3: a resolver exception is caught and returned as `Ok = $false` with message `ORCHESTRATOR_CHECKPOINT_UNRESOLVED: <ArtifactType>: NoTarget (RESOLVER_FAILED): <exception message>`, which the tail emits through `Exit-SubagentStopBlock`.
- A failed load of the E1 helper or the routing sibling is recorded through `Add-HookDependencyFailure` where the guard is present and produces exit 2 with the file name in stderr. In hooks without the guard today (executor, required-artifact), the fallback writes the reason to stderr and exits 2 directly.

#### Rollback/feature-flag considerations

- No feature flag. Rollback is a revert of the E2 commits on the integration branch. Because E2 only consumes the E1 helper, reverting E2 leaves E1 intact.

### Technical specifications (interfaces/contracts)

#### Inputs/outputs and formats

- Input: SubagentStop envelope as JSON on stdin, per E1's spec. The assistant text is read from `last_assistant_message`. No field is read from a root `output` property.
- Output: exit 0 to allow the stop; exit 2 with a stderr reason to block.
- Script parameters: unchanged (see invariants).

#### Required configuration keys and defaults

- `-CheckpointPath` default `artifacts/orchestration/orchestrator-state.json`; `-ArtifactType` default `orchestrator-state` (unchanged).
- No new environment variable or configuration key.

#### Backward-compatibility expectations

- The `CLAUDE_HOOK_INPUT` transport is removed for these validators. A caller that sets only `CLAUDE_HOOK_INPUT` no longer reaches validation; the behavior for that case is E1's empty-stdin behavior.
- `stop_hook_active`: E2 validators do not implement their own `stop_hook_active` policy. They follow whatever E1's helper and spec define (for example, if E1's helper allows a second stop when `stop_hook_active` is true, E2 inherits that through the helper). E2 adds no branch on `stop_hook_active`.

#### Performance constraints

- No new process launch. Validation remains in-process.

## Assumptions, Constraints, Dependencies

- Assumptions:
  - E1 merges before E2 executes, and its contract matches or supersedes the interim Shared Design.
  - Frontmatter `SubagentStop` registrations fire for named agents. This is unverified (see Risks); the conversion is still required regardless, because the settings registrations for orchestrator and planner are known to fire.
- Constraints:
  - No production or test file exceeds 500 lines.
  - Line coverage >= 85% for every changed PowerShell production file.
  - Bundled mirrors stay byte-identical to their sources.
  - Enforcement hooks gain no Python legs. Research Q7 found that no Python is invoked by any of the five hook files or by the modules they load (`.claude/lib/orchestrator-state/*.psm1`, `.claude/lib/worktree-resolution/*.psm1`); the only matches are comment text at `validate-orchestrator-output.ps1:176` and `:235` and a regex literal at `validate-executor-output.ps1:265` that inspects agent output. The change must introduce no Python invocation.
  - Tests use no temporary files and no real wall-clock waits.
- External dependencies: E1 helper and spec; Pester and PSScriptAnalyzer as installed for the repository.

## Data / API / Config Impact

- User-facing changes: block reasons are delivered on stderr with exit 2, so a blocked subagent now sees the reason and is re-prompted, instead of the block being ignored.
- Data or migration: none.
- Logging: block messages no longer name `CLAUDE_HOOK_INPUT`; they name the stdin envelope or `last_assistant_message`.
- Compatibility: pack manifest gains one entry; bundled mirrors change.

## Test Strategy

- Regression tests to update (payload shape from `{"output": ...}` / `-RawPayload` to the envelope seam, and messages that name `CLAUDE_HOOK_INPUT`):
  - `validate-orchestrator-output.Tests.ps1` (454 lines; add no new rows here because of cap headroom), `validate-orchestrator-output.model-routing.Tests.ps1`, `validate-orchestrator-output.artifact-type-dispatch.Tests.ps1`, `validate-orchestrator-output.WaveBarrier.Tests.ps1`, `validate-orchestrator-output.WorktreeResolution.Tests.ps1`, `validate-orchestrator-output-resolution.Tests.ps1` (payload helper at 45-48), `validate-executor-output.Tests.ps1`, `validate-planner-output.Tests.ps1`, `validate-required-artifact-output.Tests.ps1`.
  - `validate-planner-output.Coverage.Tests.ps1`: replace the `$env:CLAUDE_HOOK_INPUT` driver with a `[Console]::SetIn` stdin driver and assert exit 2.
  - `hook-import-failure-exemptions.FailClosed.Tests.ps1`: H7/H8 drivers stop setting `CLAUDE_HOOK_INPUT` (lines 424, 430, 438) and supply the envelope on stdin; remove the stale `finally` resets. Net growth must keep the file at or under 500 lines.
- New tests:
  - `tests/scripts/claude-hooks/validate-orchestrator-output.Envelope.Tests.ps1` (new): entry-tail rows for the orchestrator hook driven through stdin, covering block (exit 2) and pass (exit 0), plus a row proving `CLAUDE_HOOK_INPUT` is ignored.
  - New rows in `validate-orchestrator-output-resolution.Tests.ps1`: CR-1 (a checkpoint whose route key is spelled `Route_Id`, or whose field key differs only in case, is kept) and CR-3 (resolver mocked to throw yields the `ORCHESTRATOR_CHECKPOINT_UNRESOLVED:` token and exit 2 at the tail).
  - New rows in `validate-executor-output.Tests.ps1` (or a new `validate-executor-output.Envelope.Tests.ps1` if needed for size): entry tail via stdin, block and pass, helper-load failure exits 2, plus coverage rows for currently untested branches.
  - New rows in `validate-planner-output.Coverage.Tests.ps1`: entry tail via stdin, block and pass.
  - New rows in `validate-required-artifact-output.Tests.ps1` (or a new `validate-required-artifact-output.Envelope.Tests.ps1`): missing-argument path exits 2, validation-failure path exits 2, pass exits 0, helper-load failure exits 2, plus coverage rows.
  - `tests/scripts/claude-hooks/subagentstop-envelope-orchestrator-family.Registration.Tests.ps1` (new): parses the `SubagentStop` frontmatter registrations in `.claude/agents/*.md` that invoke an E2 hook and asserts that every argument name passed exists in the target script's `param()` block.
- Edge cases: empty or whitespace `last_assistant_message`; envelope with an `output` key but no `last_assistant_message` (must block, proving `output` is not read); `CLAUDE_HOOK_INPUT` set to a valid passing payload while stdin carries a failing envelope (must block); empty and malformed stdin (behavior per E1's spec); resolver exception; case-variant checkpoint keys.
- Error handling verification: every block row asserts both exit code 2 and a stderr reason containing the expected prefix or token.
- Coverage: self-hosted Pester coverage run over the changed production files (research Q8: a `New-PesterConfiguration` run with `CodeCoverage.Path` set to the target files, or `Invoke-PoshQCTest` with a caller `-SettingsPath`), launched through `sh <script>` because the worktree isolation guard denies direct `pwsh` text. Re-measure the baseline first: the most recent recorded values are 69.91% for `validate-executor-output.ps1` and 69.81% for `validate-required-artifact-output.ps1`, both below the floor, so added tests are required. The MCP PoshQC runner is not used for coverage figures because it loads the installed-extension module and has omitted new population files.
- Regression suites run unchanged: `hook-dependency-failure.Claude.Tests.ps1`, `hook-dependency-failure.SpecialCases.Tests.ps1`, `tests/scripts/claude-runtime/enforcement-hooks-no-python-invocation.Tests.ps1`, `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py`, `tests/scripts/dev_tools/test_push_down_claude_pack_manifest_completeness.py`, and `extensions/drm-copilot/test/lib/push-down/claude-pack-manifest-completeness.test.ts`.
- Toolchain (PowerShell): `Invoke-Formatter` check -> PSScriptAnalyzer -> Pester. Type checking does not apply to PowerShell. Restart from formatting after any failure or auto-fix.
- Evidence is written under `docs/features/active/subagentstop-envelope-orchestrator-family-903/evidence/<kind>/` (`baseline/`, `qa-gates/`, `regression-testing/`, `other/`).
- Manual validation: none required beyond the automated rows. A live named-agent SubagentStop run is desirable but is not an acceptance criterion because it depends on the unresolved frontmatter question.

## Acceptance Criteria

- [ ] Upstream gate passed before any production or test edit: after `git fetch origin`, `git cat-file -e origin/epic/subagentstop-envelope-integration:.claude/hooks/subagentstop-envelope.ps1` exits 0, `git show origin/epic/subagentstop-envelope-integration:.claude/hooks/subagentstop-envelope.ps1` contains function definitions named `Read-SubagentStopEnvelope` and `Exit-SubagentStopBlock`, E1's spec is present on that ref, and the result is recorded under `evidence/other/`; if any check fails, execution stopped and reported without creating a helper.
- [ ] `validate-orchestrator-output.ps1` blocks with exit 2 and a stderr reason when the stdin envelope's `last_assistant_message` is empty or the required checkpoint cannot be resolved, and exits 0 when `last_assistant_message` carries a completion summary and a valid checkpoint fixture is supplied through the existing seams; verified by rows in `tests/scripts/claude-hooks/validate-orchestrator-output.Envelope.Tests.ps1`.
- [ ] `validate-executor-output.ps1` blocks with exit 2 and a stderr reason when the stdin envelope's `last_assistant_message` lacks a `plan-path:` line, and exits 0 when it advertises a plan whose fixture satisfies the executor checks; verified by named entry-tail rows in `tests/scripts/claude-hooks/validate-executor-output.Tests.ps1` (or `validate-executor-output.Envelope.Tests.ps1`).
- [ ] `validate-planner-output.ps1` blocks with exit 2 and a stderr reason when the stdin envelope's `last_assistant_message` lacks the `PREFLIGHT:` signal or the `plan-path:` line, and exits 0 when both are present with a contract-valid plan fixture; verified by stdin-driven rows in `tests/scripts/claude-hooks/validate-planner-output.Coverage.Tests.ps1`.
- [ ] `validate-required-artifact-output.ps1` blocks with exit 2 and a stderr reason when the stdin envelope's `last_assistant_message` lacks the artifact named by `-RequiredArtifact`, blocks with exit 2 when `-AgentName` or `-RequiredArtifact` is missing, and exits 0 when the artifact is present; verified by named rows in `tests/scripts/claude-hooks/validate-required-artifact-output.Tests.ps1` (or `validate-required-artifact-output.Envelope.Tests.ps1`).
- [ ] For each converted validator, a Pester row supplies a stdin envelope that fails validation while `$env:CLAUDE_HOOK_INPUT` holds a payload that would pass, and asserts exit 2; and a row supplies an envelope carrying only an `output` key and asserts a block, proving neither legacy source is read.
- [ ] `rg -n "CLAUDE_HOOK_INPUT" .claude/hooks/validate-orchestrator-output.ps1 .claude/hooks/validate-orchestrator-output-routing.ps1 .claude/hooks/validate-orchestrator-output-resolution.ps1 .claude/hooks/validate-executor-output.ps1 .claude/hooks/validate-planner-output.ps1 .claude/hooks/validate-required-artifact-output.ps1` returns no match.
- [ ] `rg -n "\$payload\.output|Properties\.Name -contains 'output'|Properties\['output'\]"` over the same production file list returns no match.
- [ ] `rg -n "\bexit 1\b|Write-Error"` over the same production file list returns no match.
- [ ] A failed load of the E1 helper produces exit 2 with the helper file name in stderr for each converted validator; verified by named rows in the suites listed in Test Strategy (the B1 dynamic suite covers orchestrator and planner; explicit rows cover executor and required-artifact).
- [ ] #787 CR-1 fixed: `validate-orchestrator-output-resolution.ps1` uses `-contains` for both property-name checks in `Find-OrchestratorOutputRunSignalValue`, retains `-cne` for the route value, and a new row in `validate-orchestrator-output-resolution.Tests.ps1` shows a checkpoint with a case-variant key (for example `Route_Id`) is kept.
- [ ] #787 CR-3 fixed: a new row in `validate-orchestrator-output-resolution.Tests.ps1` mocks `Resolve-OrchestratorOutputCheckpointPath` to throw and asserts `Ok = $false` with a message starting `ORCHESTRATOR_CHECKPOINT_UNRESOLVED:`, and a row in `validate-orchestrator-output.Envelope.Tests.ps1` asserts the hook exits 2 with that prefix on stderr rather than an unhandled error.
- [ ] #787 CR-7 fixed: `rg -n "One subprocess call" .claude/hooks/validate-orchestrator-output.ps1 .claude/hooks/validate-orchestrator-output-routing.ps1` returns no match, and the replacement comment states that the in-process validation covers the completion and model-routing checks.
- [ ] #786 double import fixed: `rg -n "OrchestratorState\.psm1'\)" .claude/hooks/validate-orchestrator-output.ps1` matches only the import line that carries `-Global`, and `hook-dependency-failure.Claude.Tests.ps1` passes.
- [ ] #786 FailClosed nit fixed: `rg -n "OrchestratorOutputResolverImportFailure|OrchestratorOutputWaveBarrierImportFailure" tests/scripts/claude-hooks/hook-import-failure-exemptions.FailClosed.Tests.ps1` returns no match, and H7 and H8 in that suite pass with exit 2.
- [ ] Split done: `.claude/hooks/validate-orchestrator-output-routing.ps1` defines `Test-OrchestratorCheckpointStructure` and `Invoke-RoutingContractValidation`, `.claude/hooks/validate-orchestrator-output.ps1` no longer defines them and loads the sibling through a guarded dot-source that calls `Add-HookDependencyFailure` on failure, and the existing `validate-orchestrator-output.artifact-type-dispatch.Tests.ps1` and the AST no-Python row in `validate-orchestrator-output.Tests.ps1` pass against the relocated functions.
- [ ] Every production and test file added or changed by E2 is at or under 500 lines, measured with `(Get-Content -LiteralPath <file>).Count` for each path in `git diff --name-only origin/epic/subagentstop-envelope-integration...HEAD`, with results recorded under `evidence/qa-gates/`.
- [ ] Line coverage is >= 85% for each changed or added PowerShell production file (including `validate-executor-output.ps1`, `validate-required-artifact-output.ps1`, and `validate-orchestrator-output-routing.ps1`), measured by a self-hosted Pester coverage run with `CodeCoverage.Path` set to those files and recorded under `evidence/qa-gates/`.
- [ ] Each changed or added production file under `.claude/hooks/` has a byte-identical mirror under `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/` (verified by `Get-FileHash` comparison recorded under `evidence/qa-gates/`), `pack-manifests/core.json` lists `.claude/hooks/validate-orchestrator-output-routing.ps1` in sorted position, and `poetry run pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py tests/scripts/dev_tools/test_push_down_claude_pack_manifest_completeness.py` passes along with `extensions/drm-copilot/test/lib/push-down/claude-pack-manifest-completeness.test.ts`.
- [ ] Frontmatter registrations are consistent: `tests/scripts/claude-hooks/subagentstop-envelope-orchestrator-family.Registration.Tests.ps1` passes, and `git diff --name-only origin/epic/subagentstop-envelope-integration...HEAD -- .claude/agents` returns no path.
- [ ] No Python invocation in E2 files: `tests/scripts/claude-runtime/enforcement-hooks-no-python-invocation.Tests.ps1` passes, the AST no-Python row in `validate-orchestrator-output.Tests.ps1` passes, and `rg -n "(&\s*(python|py|poetry)\b|poetry run|Start-Process|ProcessStartInfo)"` over the E2 production file list returns no match.
- [ ] No E2 validator branches on `stop_hook_active`: `rg -n "stop_hook_active"` over the E2 production file list returns no match, so re-run behavior is inherited from the E1 helper.
- [ ] Out-of-scope files are untouched: `git diff --name-only origin/epic/subagentstop-envelope-integration...HEAD` lists no E3-owned or E4-owned validator or suite, no PreToolUse hook, no `.claude/settings.json`, no `.claude/hooks/subagentstop-envelope.ps1`, and no file under `tests/scripts/codex-hooks/` or `.codex/`.
- [ ] Full PowerShell toolchain is clean in a single pass over the changed PowerShell files: `Invoke-Formatter` reports no change, PSScriptAnalyzer reports zero findings, and Pester passes for every suite under `tests/scripts/claude-hooks/` and `tests/scripts/claude-runtime/`, with output recorded under `evidence/qa-gates/`.

## Risks & Mitigations

| Risk / open question | Impact | Mitigation |
|---|---|---|
| E1 contract not frozen (return shape of `Read-SubagentStopEnvelope`, empty/malformed stdin behavior, `stop_hook_active` exposure) | E2's entry-point parameter shape depends on it | The pure entry takes the envelope or assistant text as a parameter, and only the tail calls the helper; the upstream gate stops execution until E1's spec is merged and reconciled. |
| Unbounded re-run under exit 2 (open question owned by E1) | A subagent that cannot satisfy a gate may be re-invoked repeatedly; the Layer 2 message "Report them to the operator and halt" (`validate-orchestrator-output-resolution.ps1:37`) cannot be acted on while every stop is blocked | E2 implements no `stop_hook_active` policy and inherits E1's. The question is raised to E1; if E1's spec defines no policy, record the gap in E2's review rather than adding one in E2. |
| Frontmatter-only `SubagentStop` registrations are unverified (executor; required-artifact via `epic-review.md`, `prd-feature.md`, `staged-review.md`, `status-updater.md`) | Converting those hooks may have no runtime effect until the registration key is confirmed to fire | Convert them regardless (the scripts are wrong either way). Do not change registrations in E2; record the question for E1's evidence or a follow-up. |
| Duplicate `-RequiredArtifact` at `.claude/agents/prd-feature.md:18` (likely parameter-binding failure; unverified) | The required-artifact hook may never run for prd-feature | Out of scope (E3's agent). Record as an open question in review. |
| `pack-manifests/core.json:66-77` adjacent-line insertions by E1 (near 66), E4 (near 71), and E2 (between 72 and 73) | Likely textual merge conflict at fan-in, not a semantic conflict | Insert in sorted position only; resolve by keeping all entries sorted at fan-in; the manifest-completeness tests confirm the result. |
| `hook-import-failure-exemptions.FailClosed.Tests.ps1` is 474 lines | Little headroom for the H7/H8 driver rewrite | Removing the stale `finally` blocks frees about 8 lines; put any new rows in new suites rather than this file. |
| Guard placement relative to `$ErrorActionPreference = 'Stop'` in `validate-planner-output.ps1` | A failed helper load under `Stop` could terminate with exit 1 | Place all guarded loads before line 36; C8 in `hook-dependency-failure.SpecialCases.Tests.ps1` detects regressions. |
| Executor and required-artifact hooks have no dependency guard and are absent from `.claude/settings.json`, so the B-suite does not cover them | A helper load failure could leave `Exit-SubagentStopBlock` undefined and fail open | Adopt the guard pattern or a direct stderr-plus-exit-2 fallback, with explicit test rows (acceptance criteria above). |
| Local bundle-parity test failures from gitignored state (issue #510) | A local mirror test may fail while CI passes | Confirm mirror byte identity by hash comparison and confirm the parity test in CI. |

## Rollout & Follow-up

- Release: merge into `epic/subagentstop-envelope-integration`; the integration-to-main pull request (epic #904) carries it to main.
- Pull request linkage: the E2 pull request body uses `Refs #903` and `Refs #897`. It does not use a closing keyword, because #903 is delivered only in part and #897 is delivered by E1, E2, and E3 together (epic Issue Closure).
- Follow-up candidates outside E2: the #786 always-true conditional in the three PreToolUse hooks; the #786 `SilentlyContinue` nit in `tests/scripts/codex-hooks/hook-dependency-failure.Codex.Tests.ps1:42`; the frontmatter `SubagentStop` firing question; the `prd-feature.md:18` duplicate parameter.
- Links: #903, #897, epic #904, `docs/features/epics/subagentstop-envelope/epic.md`, research record above, #787 review `docs/features/active/2026-09-29-validate-orchestrator-output-session-relative-read-787/code-review.2026-10-09T00-12.md`, #786 review `docs/features/active/2026-09-29-hook-preexisting-imports-fail-open-786/code-review.2026-10-10T22-23.md`.
