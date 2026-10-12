# subagentstop-envelope-orchestrator-family (Spec)

- **Issue:** #903 (canonical key); delivers part of #897
- **Parent (optional):** epic subagentstop-envelope (#904), child E2
- **Owner:** drmoisan
- **Last Updated:** 2026-10-11
- **Status:** Draft
- **Version:** 0.4
- **Work Mode:** full-bug (acceptance criteria live in this file only; no `user-story.md`)
- **Branch:** `bug/subagentstop-envelope-orchestrator-family-903`, targeting `epic/subagentstop-envelope-integration`
- **Upstream dependency:** E1 (#897, branch `bug/subagentstop-envelope-core-897`, folder `subagentstop-envelope-core-897`)
- **Upstream contract:** `docs/features/active/subagentstop-envelope-core-897/spec.md`, section "Authoritative Helper Contract", reconciled against blob `bf86505ca3bd6a2bae05fb5c16f053110af9666d` (Version 1.1, commit `82f862d49` on `origin/bug/subagentstop-envelope-core-897`)
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
- Evidence (research Upstream Contract section, citing E1's live differential `docs/features/active/subagentstop-envelope-core-897/evidence/other/subagentstop-live-differential.2026-10-11T12-01.md`, which E1's spec adopts as the basis of its contract): stdin JSON present in every invocation; `CLAUDE_HOOK_INPUT` not set; `last_assistant_message` present; no `output` key; exit 1 did not block; exit 2 blocked, and the re-invocation carried `stop_hook_active: true`.
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

1. Convert the following validators to the E1 helper (stdin envelope, assistant text from the helper's `AssistantText`, exit 2 on every block path, per-condition re-entry policy):
   - `.claude/hooks/validate-orchestrator-output.ps1` together with `.claude/hooks/validate-orchestrator-output-resolution.ps1`
   - `.claude/hooks/validate-executor-output.ps1`
   - `.claude/hooks/validate-planner-output.ps1`
   - `.claude/hooks/validate-required-artifact-output.ps1`, including both of its current `exit 1` paths (missing `-AgentName`/`-RequiredArtifact` arguments, and validation failure)
2. Split `validate-orchestrator-output.ps1` into the main file and a new sibling `.claude/hooks/validate-orchestrator-output-routing.ps1` (see Proposed Fix).
3. Update the affected Pester suites under `tests/scripts/claude-hooks/` and add the suites named in Test Strategy.
4. Update the bundled mirrors under `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/` so each is byte-identical to its source, add a mirror for the new routing sibling, and add the new file to `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json` in sorted position.
5. Check the `.claude/agents/*.md` frontmatter registrations that pass arguments to these hooks and keep them consistent with the converted scripts' parameters (research Q2). The conversion preserves every script parameter, so the only agent-file change in scope is the removal of the second `-RequiredArtifact 'user-story-path|^docs/features/active/.+/user-story\.md$|feature user story artifact'` argument from `.claude/agents/prd-feature.md` and from its byte-identical bundled mirror `extensions/drm-copilot/resources/claude-customizations/.claude/agents/prd-feature.md`, keeping the `spec-path` requirement (Amendment 2026-10-11). All other agent files stay unchanged.
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
| `.claude/agents/*.md` frontmatter, except the single `prd-feature.md` change in scope item 5 | Agent files are otherwise unchanged. The duplicate `-RequiredArtifact` binding defect at `.claude/agents/prd-feature.md:18` is in scope for E2 only as the removal of one argument (Amendment 2026-10-11, coordinator reassignment overriding the earlier E3 ownership). No other `prd-feature.md` frontmatter change is in scope. |
| Any new validation rule beyond transport, shape, exit code, re-entry policy, and the listed notes | Epic Non-Goals. The re-entry policy is required by E1 consumer policy 2 and does not add, remove, or loosen any first-stop check. |
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

- Each validator dot-sources `.claude/hooks/subagentstop-envelope.ps1` in its own single-statement `try` whose `catch` calls `Add-HookDependencyFailure -Name 'subagentstop-envelope.ps1' -ErrorRecord $_` (E1 consumer policy 4).
- Each pure entry point (`Invoke-OrchestratorOutputValidation`, `Invoke-ExecutorOutputValidation`, `Invoke-PlannerOutputValidation`, `Invoke-RequiredArtifactOutputValidation`) replaces `-RawPayload` with `-InputText`, declared `[AllowNull()][AllowEmptyString()][string]`, and passes it through to `Read-SubagentStopEnvelope` (E1 consumer policy 3): when `-InputText` is bound, the entry calls `Read-SubagentStopEnvelope -InputText $InputText`; when it is not bound, the entry calls `Read-SubagentStopEnvelope` with no argument, so the helper reads stdin. `-InputText` is the test seam; no environment variable and no `-AssistantText` parameter is used.
- The entry tail invokes the pure entry point without `-InputText`. The only other call to `Read-SubagentStopEnvelope` is the required-artifact missing-argument path (see "Required-artifact exits").
- `validate-orchestrator-output.ps1` moves `Test-OrchestratorCheckpointStructure` (lines 171-215) and `Invoke-RoutingContractValidation` (lines 217-323) into the new `validate-orchestrator-output-routing.ps1`, loaded with the guarded dot-source pattern used for the resolution sibling.

### Helper result handling

- `Read-SubagentStopEnvelope` never returns `$null` and never throws. It always returns one object with the properties `IsValid`, `Anomaly`, `Envelope`, `AssistantText`, `StopHookActive`, `AgentType`, and `HookEventName`. Validators read the assistant text only from `AssistantText` and the re-entry flag only from `StopHookActive`. No validator reads `last_assistant_message`, `stop_hook_active`, or `output` from `Envelope` or from any other object.
- Invalid envelope (E1 consumer policy 1): when `IsValid` is `$false`, each validator blocks with `<PREFIX> payload anomaly - <clause>`, where `<clause>` is `Get-SubagentStopEnvelopeAnomalyReason -Anomaly <result.Anomaly>`. The per-validator prefixes are:

  | Validator | `<PREFIX>` for the anomaly block |
  |---|---|
  | `validate-orchestrator-output.ps1` | `orchestrator hook:` |
  | `validate-executor-output.ps1` | `atomic-executor hook:` |
  | `validate-planner-output.ps1` | `atomic-planner hook:` |
  | `validate-required-artifact-output.ps1` | `<AgentName> hook:` (the bound `-AgentName` value) |

  The anomaly block is a non-repairable condition (rows O-1, X-1, P-1, R-2 in the re-entry table), so the anomaly message is followed by the report-and-halt line defined below.
- Valid envelope with empty or whitespace `AssistantText`: each validator returns its existing empty-output block, reworded so it names `last_assistant_message` instead of `CLAUDE_HOOK_INPUT`; the existing token `agent output is empty` is retained because existing rows assert it. This is a repairable condition.

### Re-entry policy (`StopHookActive`)

E1 consumer policy 2: "`StopHookActive` is surfaced by the helper; the re-entry policy is decided per validator. Conditions the subagent can repair (a missing path token or file) may block again. Conditions it cannot repair use report-and-halt wording and block once."

Classification rule used below: a condition is **repairable** when the resumed subagent can clear it by producing a new final message or by writing or correcting a file it owns (its checkpoint, plan, runbook, or advertised artifact). A condition is **not repairable** when its cause is the hook registration (script arguments), the runtime envelope, an internal evaluation failure, or a state the agent is not permitted to clear.

- **Block always** (repairable): the validator blocks with exit 2 whether or not `StopHookActive` is `$true`.
- **Block once** (not repairable): the validator blocks with exit 2 when `StopHookActive` is `$false`, and allows the stop (pure entry returns `Ok = $true`, tail exits 0) when `StopHookActive` is `$true`. Every block-once message ends with a line containing `Report it to the operator and halt.`; the wave-barrier violation message keeps its existing sentence `Report them to the operator and halt.`
- **S1 tail** (not repairable, policy 5): the dependency-failure tail stays inline and unchanged. It runs before the envelope is read, and the helper may itself be the failed dependency, so it cannot consult `StopHookActive`. It blocks on every stop. This is the only non-repairable class that does not block once.
- The re-entry decision is applied at one point in each pure entry point, after the block condition is determined. Each internal block result carries a `Repairable` boolean set per the table; the helper functions that produce block results (`Test-HumanInteractionShape`, `Get-OrchestratorOutputWaveBarrierDecision`, and the resolution handling in `Invoke-OrchestratorOutputValidation`) set it. No first-stop check is added, removed, or loosened.

#### Re-entry table

`validate-orchestrator-output.ps1` (with the resolution and routing siblings):

| ID | Block condition (current message or reason code) | Repairable | Re-entry behavior | Basis |
|---|---|---|---|---|
| O-0 | Guard bootstrap failure or recorded dependency failure (any guarded load, including `subagentstop-envelope.ps1` and the routing sibling) | No | Block every stop (S1 tail, policy 5) | Missing hook file; runs before the envelope is read |
| O-1 | Invalid envelope (any of the six anomaly codes) | No | Block once | Envelope is produced by the runtime |
| O-2 | `AssistantText` empty or whitespace | Yes | Block always | Agent writes a completion summary |
| O-3 | Unsupported `-ArtifactType` (`NoTarget`, `TARGET_WORKTREE_NOT_DERIVABLE`, "unsupported artifact type") | No | Block once | Registration argument |
| O-4 | `-CheckpointPath` rejected: blank, rooted, escaping, or not the canonical checkpoint (`Rejected`, `CHECKPOINT_PATH_MISMATCH`) | No | Block once | Registration argument |
| O-5 | Target not derivable or ambiguous (`TARGET_WORKTREE_NOT_DERIVABLE`, `TARGET_WORKTREE_AMBIGUOUS`) for `epic-orchestrator-state` or `parallel-orchestrator-state` | Yes | Block always | Agent names its `integration_branch:` or `parallel_slug:` literal in the new final message |
| O-6 | Target not derivable or ambiguous for `orchestrator-state` | No | Block once | Target is derived from the session worktree, not from the message |
| O-7 | Resolver exception (CR-3, `RESOLVER_FAILED`) | No | Block once | Internal evaluation failure |
| O-8 | Checkpoint file missing, empty, or not valid JSON | Yes | Block always | Agent persists its checkpoint |
| O-9 | Checkpoint missing required fields, or empty `objective` | Yes | Block always | Agent persists its checkpoint |
| O-10 | `human_interaction`: `requirements` missing; a `response` missing or outside the enum; `exception` without `runbook_path`; runbook file missing | Yes | Block always | Agent records a response or writes the runbook |
| O-11 | `human_interaction` requirement with `response` == `halt` | No | Block once | A recorded halt is an operator decision the agent may not clear |
| O-12 | `MODEL_ROUTING_BLOCKED:` | Yes | Block always | Agent records receipts or assessments in its checkpoint |
| O-13 | `ROUTING_CONTRACT_BLOCKED:` (completion readiness, or epic/parallel structural check) | Yes | Block always | Agent completes and persists the remaining work |
| O-14 | Wave-barrier violation (`EPIC_WAVE_BARRIER_VIOLATION:` lines plus "Report them to the operator and halt.") | No | Block once | Existing message states the agent cannot clear it |
| O-15 | `EPIC_WAVE_BARRIER_UNEVALUABLE:` | No | Block once | Internal evaluation failure |

`validate-executor-output.ps1`:

| ID | Block condition | Repairable | Re-entry behavior | Basis |
|---|---|---|---|---|
| X-0 | Guard bootstrap failure or recorded dependency failure (new under policy 4) | No | Block every stop (S1 tail, policy 5) | Missing hook file |
| X-1 | Invalid envelope | No | Block once | Runtime envelope |
| X-2 | `AssistantText` empty or whitespace | Yes | Block always | Message content |
| X-3 | No `plan-path` advertised | Yes | Block always | Message content |
| X-4 | Advertised plan file does not exist | Yes | Block always | Agent corrects the advertised path |
| X-5 | Preflight plan: non-canonical `BLOCKED` text | Yes | Block always | Message content |
| X-6 | Preflight plan: no `PREFLIGHT:` signal | Yes | Block always | Message content |
| X-7 | Non-preflight run reports `BLOCKED` | No | Block once | The agent reports an external blocker; the first block delivers the rule, and re-entry lets the blocker report reach the parent |
| X-8 | Plan file contains no task checkboxes | No | Block once | The plan is planner-authored; the executor may not restructure it |
| X-9 | Plan has unchecked tasks | Yes | Block always | Agent completes and ticks tasks |
| X-10 | No `AC Status Summary` | Yes | Block always | Message content |
| X-11 | No command or PASS/FAIL evidence | Yes | Block always | Message content |
| X-12 | Missing per-language PASS/FAIL lines | Yes | Block always | Message content |

`validate-planner-output.ps1`:

| ID | Block condition | Repairable | Re-entry behavior | Basis |
|---|---|---|---|---|
| P-0 | Guard bootstrap failure or recorded dependency failure | No | Block every stop (S1 tail, policy 5) | Missing hook file |
| P-1 | Invalid envelope | No | Block once | Runtime envelope |
| P-2 | `AssistantText` empty or whitespace | Yes | Block always | Message content |
| P-3 | No `PREFLIGHT:` signal | Yes | Block always | Message content |
| P-4 | No `plan-path` advertised | Yes | Block always | Message content |
| P-5 | Advertised plan file does not exist | Yes | Block always | Agent writes or corrects the plan |
| P-6 | Plan structure violations | Yes | Block always | Agent owns the plan |
| P-7 | Planner internal review record violations | Yes | Block always | Message content |

`validate-required-artifact-output.ps1`:

| ID | Block condition | Repairable | Re-entry behavior | Basis |
|---|---|---|---|---|
| R-0 | Guard bootstrap failure or recorded dependency failure (new under policy 4) | No | Block every stop (S1 tail, policy 5) | Missing hook file |
| R-1 | `-AgentName` blank or `-RequiredArtifact` absent or empty | No | Block once (inline exit, see below) | Registration argument |
| R-2 | Invalid envelope | No | Block once | Runtime envelope |
| R-3 | `AssistantText` empty or whitespace | Yes | Block always | Message content |
| R-4 | A `-RequiredArtifact` spec is not `token|regex|description` | No | Block once | Registration argument |
| R-5 | Artifact token missing, path outside the required location, or advertised file missing | Yes | Block always | Agent reports or writes the artifact |

Row counts: orchestrator 16 (O-0 to O-15), executor 13 (X-0 to X-12), planner 8 (P-0 to P-7), required-artifact 6 (R-0 to R-5); 43 rows in total.

- S1 rows (4): O-0, X-0, P-0, R-0.
- Block-once rows (15): O-1, O-3, O-4, O-6, O-7, O-11, O-14, O-15, X-1, X-7, X-8, P-1, R-1, R-2, R-4.
- Block-always rows (24): O-2, O-5, O-8, O-9, O-10, O-12, O-13, X-2 to X-6, X-9 to X-12, P-2 to P-7, R-3, R-5.
- Non-S1 rows covered by AC-22: the block-once and block-always rows above.

### Required-artifact exits

E1 consumer policy 5: "The existing S1 dependency tail (`[Console]::Error.WriteLine(...)`/`exit 2` and `exit $dependencyDecision.ExitCode`) stays inline. `Exit-SubagentStopBlock` replaces only the final validation-failure exit."

Applied to `validate-required-artifact-output.ps1`:

- The hook adopts `hook-dependency-guard.ps1` and the S1 tail (policy 4 requires `Add-HookDependencyFailure`), with reason prefix `validate-required-artifact-output:`. The S1 tail is inline and runs first.
- The missing-argument path (current lines 157-160) is not the final validation-failure exit, so it does not call `Exit-SubagentStopBlock`. It stays inline in the tail, after the S1 tail: it calls `Read-SubagentStopEnvelope` (unbound, reading stdin); if `StopHookActive` is `$true` it exits 0; otherwise it writes `validate-required-artifact-output hook: AgentName and at least one RequiredArtifact spec are required.` followed by the report-and-halt line to stderr with `[Console]::Error.WriteLine(...)` and exits 2. It never uses `Write-Error` or `exit 1`.
- The final validation-failure exit (current lines 166-168) is replaced by `Exit-SubagentStopBlock -Message $result.Message`.

The same structure applies to the other three validators: the S1 tail is inline, and `Exit-SubagentStopBlock` is called exactly once per file, at the final validation-failure exit of the tail.

### Boundaries and invariants to preserve

- Existing stderr reason prefixes are preserved: `ORCHESTRATOR_CHECKPOINT_UNRESOLVED:` (orchestrator dependency and resolution failures), `validate-planner-output:` (planner dependency failures), `MODEL_ROUTING_BLOCKED:`, and `ROUTING_CONTRACT_BLOCKED:`. The B1 prefix table in `hook-dependency-failure.Claude.Tests.ps1:71-102` depends on them. Appending the report-and-halt line to a block-once message does not change its leading prefix. The new S1 prefixes `validate-executor-output:` and `validate-required-artifact-output:` belong to hooks that are not registered in `.claude/settings.json` and are therefore not in the B1 table.
- The dependency-decision path (`[pscustomobject]` with `ExitCode` and `Reason`) continues to be checked before any read of `.Ok`, so the two return shapes of `Invoke-OrchestratorOutputValidation` and `Invoke-PlannerOutputValidation` remain safe under `Set-StrictMode -Version Latest` (research Risk 7). WaveBarrier H12 and resolution S2-12 keep their assertions.
- Every guarded load (guard, E1 helper, routing sibling, modules) is placed before the `$ErrorActionPreference = 'Stop'` assignment in its file, as the orchestrator hook does today (research Risk 5).
- Script parameters are unchanged: `-CheckpointPath` and `-ArtifactType` on the orchestrator hook; `-AgentName` and `-RequiredArtifact [string[]]` on the required-artifact hook; empty `param()` on executor and planner. This keeps every frontmatter registration valid without edits, apart from the duplicate-argument removal in `.claude/agents/prd-feature.md` (Amendment 2026-10-11).
- The routing sibling's default `Invoker` continues to resolve `../lib/orchestrator-state/OrchestratorStateCompletion.psm1` relative to `$PSScriptRoot`, which is unchanged for a dot-sourced file in the same directory.
- No first-stop validation rule is added, removed, or loosened, apart from the listed notes and except the corpus rule changes recorded in `## Amendments` (2026-10-12). The only behavioral addition is the re-entry policy required by E1 consumer policy 2.

### Dependencies or blocked work

- E2 consumes E1's contract. The authoritative contract is the section "Authoritative Helper Contract" (with its "Consumer policy for E2, E3 and E4") in `docs/features/active/subagentstop-envelope-core-897/spec.md`:
  - Before E1 merges: on `origin/bug/subagentstop-envelope-core-897`, blob `bf86505ca3bd6a2bae05fb5c16f053110af9666d` (Version 1.1, Last Updated 2026-10-11T13-15) at commit `82f862d49`. That blob is the reconciled contract version for this spec.
  - After E1 merges: the same path on `origin/epic/subagentstop-envelope-integration`.
- This revision was reconciled against the E1 spec text read from E1's worktree (Version 1.1, Last Updated 2026-10-11T13-15). The orchestrator verified with git that this version is blob `bf86505ca3bd6a2bae05fb5c16f053110af9666d`. Relative to the earlier blob `20fbd776b5e26a4d81c440bd14ca6d171de42a4a` (Version 1.0), the only differences inside "## Authoritative Helper Contract" are the addition of `-DateKind String` to `ConvertFrom-Json` and one table row for an ISO-8601 date-form `last_assistant_message`; no function name, parameter, return field, or consumer policy changed.
- E1 is still in preparation, so non-semantic edits to its contract text are expected before it merges. For that reason the drift check in the upstream gate targets the three function signatures and the consumer policies, not the whole contract section.
- Contract points E2 depends on: helper path `.claude/hooks/subagentstop-envelope.ps1`; `Read-SubagentStopEnvelope [-InputText <string>]` with its seven-property result and six anomaly codes; `Get-SubagentStopEnvelopeAnomalyReason -Anomaly <string>`; `Exit-SubagentStopBlock -Message <string>` (stderr, exit 2); consumer policies 1-6.
- **Upstream gate.** Execution begins with an upstream-merge check that confirms:
  1. E1 is merged into `origin/epic/subagentstop-envelope-integration` (after `git fetch origin`).
  2. `.claude/hooks/subagentstop-envelope.ps1` exists on that ref.
  3. That file defines functions named exactly `Read-SubagentStopEnvelope`, `Get-SubagentStopEnvelopeAnomalyReason`, and `Exit-SubagentStopBlock`.
  4. Drift check. Extract the E1 spec (`docs/features/active/subagentstop-envelope-core-897/spec.md`) from its active feature folder on the merged integration branch. Execution halts with `E1 CONTRACT DRIFT` when either (a) any of the three function-signature headings inside `## Authoritative Helper Contract` differs from these literals: ``### `Read-SubagentStopEnvelope [-InputText <string>]` ``, ``### `Get-SubagentStopEnvelopeAnomalyReason -Anomaly <string>` ``, ``### `Exit-SubagentStopBlock -Message <string>` ``; or (b) the `### Consumer policy for E2, E3 and E4` subsection (from that heading to the next `### ` heading) differs byte-for-byte from the same subsection in blob `bf86505ca3bd6a2bae05fb5c16f053110af9666d`. Any other difference within the contract section is recorded in the upstream-gate evidence and does not halt.
  If check 4 halts, execution reports `E1 CONTRACT DRIFT` with the differing lines; this spec must be re-reconciled before any edit. If any other check fails, execution stops and reports the failing check. The executor must not create, copy, stub, or improvise a helper.

### Implementation strategy (what changes, not sequencing)

#### Files/modules to change (see also "## Amendments" at the end of this file)

Production (under `.claude/hooks/`):

| File | Change |
|---|---|
| `validate-orchestrator-output.ps1` | Guarded E1 helper load; guarded load of the routing sibling next to the resolution sibling load (line 53); delete line 51; `-RawPayload` replaced by `-InputText` and the envelope path replacing lines 350-366; anomaly block; re-entry decision; CR-3 `try`/`catch` around line 370; CR-7 comment rewrite at 431-435; tail calls the pure entry without `-InputText` and uses `Exit-SubagentStopBlock` for the final validation-failure exit; update `.NOTES` (30-36) and block messages (351, 357) so none names `CLAUDE_HOOK_INPUT` |
| `validate-orchestrator-output-routing.ps1` (new) | Receives `Test-OrchestratorCheckpointStructure` and `Invoke-RoutingContractValidation` unchanged in behavior, with a header in the style of the resolution sibling |
| `validate-orchestrator-output-resolution.ps1` | CR-1 at 158-159; keep `-cne $route`; `Get-OrchestratorOutputWaveBarrierDecision` block results carry `Repairable = $false` |
| `validate-executor-output.ps1` | Adopt `hook-dependency-guard.ps1` and the S1 tail (prefix `validate-executor-output:`); guarded helper load per policy 4; `-InputText` and envelope path; anomaly block; re-entry decision; tail at 290-293; messages at 186, 193; `.NOTES` 22-26 |
| `validate-planner-output.ps1` | Guarded helper load placed before line 36; `-InputText` and envelope path; anomaly block; re-entry decision; tail at 410-413; messages at 357, 364; `.NOTES` 24-28 |
| `validate-required-artifact-output.ps1` | Adopt `hook-dependency-guard.ps1` and the S1 tail (prefix `validate-required-artifact-output:`); guarded helper load per policy 4; `-InputText` and envelope path; anomaly block; re-entry decision; missing-argument path (157-160) inline as described in "Required-artifact exits"; final validation-failure exit (166-168) via `Exit-SubagentStopBlock`; messages at 102, 109; `.NOTES` 17-21 |

Tests (under `tests/scripts/claude-hooks/`): see Test Strategy.

Mirrors and manifest:

- `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/` copies of every changed or added production file above.
- `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json`: insert `.claude/hooks/validate-orchestrator-output-routing.ps1` between the `validate-orchestrator-output-resolution.ps1` entry (line 72) and the `validate-orchestrator-output.ps1` entry (line 73).

Agent frontmatter: the only change is the removal of the second `-RequiredArtifact` argument from `.claude/agents/prd-feature.md` and from its byte-identical bundled mirror `extensions/drm-copilot/resources/claude-customizations/.claude/agents/prd-feature.md` (Amendment 2026-10-11). All other agent files are unchanged. The registrations in `.claude/agents/orchestrator.md`, `epic-orchestrator.md`, `parallel-orchestrator.md`, `atomic-planner.md`, `atomic-executor.md`, `epic-review.md`, `prd-feature.md`, `staged-review.md`, and `status-updater.md` are checked for parameter consistency only. `epic-orchestrator.md` is hash-pinned by `tests/scripts/dev_tools/parallel_orchestrator_surface_expectations.py:160-169`, so an edit to it would break that test.

#### Functions/classes/CLI commands impacted

- `Invoke-OrchestratorOutputValidation`, `Invoke-ExecutorOutputValidation`, `Invoke-PlannerOutputValidation`, `Invoke-RequiredArtifactOutputValidation`: `-RawPayload` is removed and `-InputText` (passed through to `Read-SubagentStopEnvelope -InputText`) is added; each applies the anomaly block and the re-entry decision.
- `Test-HumanInteractionShape`, `Get-OrchestratorOutputWaveBarrierDecision`: block results gain a `Repairable` key; `Ok` and `Message` are unchanged.
- `Test-OrchestratorCheckpointStructure`, `Invoke-RoutingContractValidation`: relocated, behavior unchanged.
- `Find-OrchestratorOutputRunSignalValue` (resolution sibling): property-name membership becomes case-insensitive (CR-1).
- Entry tails of all converted hooks.

#### Data flow and validation changes

- Before: `$env:CLAUDE_HOOK_INPUT` -> `ConvertFrom-Json` -> `$payload.output` -> validation -> `Write-Error` + `exit 1` on block.
- After: S1 tail (inline, exit 2 on dependency failure) -> pure entry -> `Read-SubagentStopEnvelope` (stdin when `-InputText` is unbound) -> if `IsValid` is `$false`, anomaly block -> `AssistantText` -> validation -> block result with `Repairable` -> re-entry decision using `StopHookActive` -> tail: `Exit-SubagentStopBlock -Message <reason>` (stderr, exit 2) on block, `exit 0` on allow.
- Empty, absent, or malformed stdin maps to E1's anomaly codes (`EmptyPayload`, `UnparseableJson`, `NonObjectEnvelope`, `MissingAssistantMessage`, `NullAssistantMessage`, `NonStringAssistantMessage`) and is handled by the anomaly block. A valid envelope with an empty or whitespace `AssistantText` returns the validator's empty-output block.

#### Error handling and logging updates

- Every block path writes its reason to stderr and exits 2. No block path uses `Write-Error` or `exit 1`.
- CR-3: a resolver exception is caught and returned as `Ok = $false`, `Repairable = $false`, with message `ORCHESTRATOR_CHECKPOINT_UNRESOLVED: <ArtifactType>: NoTarget (RESOLVER_FAILED): <exception message>` followed by the report-and-halt line, which the tail emits through `Exit-SubagentStopBlock`.
- A failed load of the E1 helper is recorded through `Add-HookDependencyFailure -Name 'subagentstop-envelope.ps1' -ErrorRecord $_` in every converted validator (policy 4) and produces exit 2 through the S1 tail with `subagentstop-envelope.ps1` in stderr. A failed load of the routing sibling is recorded the same way in the orchestrator hook.

#### Rollback/feature-flag considerations

- No feature flag. Rollback is a revert of the E2 commits on the integration branch. Because E2 only consumes the E1 helper, reverting E2 leaves E1 intact.

### Technical specifications (interfaces/contracts)

#### Inputs/outputs and formats

- Input: SubagentStop envelope as JSON on stdin, read only through `Read-SubagentStopEnvelope`. The assistant text is the result's `AssistantText`; the re-entry flag is the result's `StopHookActive`. No field is read from a root `output` property.
- Output: exit 0 to allow the stop; exit 2 with a stderr reason to block.
- Pure-entry seam: `-InputText [AllowNull()][AllowEmptyString()][string]`, passed through to `Read-SubagentStopEnvelope -InputText` when bound.
- Script parameters: unchanged (see invariants).

#### Required configuration keys and defaults

- `-CheckpointPath` default `artifacts/orchestration/orchestrator-state.json`; `-ArtifactType` default `orchestrator-state` (unchanged).
- No new environment variable or configuration key.

#### Backward-compatibility expectations

- The `CLAUDE_HOOK_INPUT` transport is removed for these validators. A caller that sets only `CLAUDE_HOOK_INPUT` and supplies no stdin reaches the anomaly block (`EmptyPayload`).
- `stop_hook_active`: each E2 validator implements the per-condition re-entry policy in the re-entry table, reading the flag only through the helper's `StopHookActive` property. Repairable conditions block on every stop; non-repairable conditions block once; the S1 tail blocks on every stop.

#### Performance constraints

- No new process launch. Validation remains in-process. One stdin read per invocation.

## Assumptions, Constraints, Dependencies

- Assumptions:
  - E1 merges before E2 executes, and its merged "Authoritative Helper Contract" section keeps the three function-signature headings and the "Consumer policy for E2, E3 and E4" subsection of blob `bf86505ca3bd6a2bae05fb5c16f053110af9666d` unchanged (upstream gate check 4).
  - Frontmatter `SubagentStop` registrations fire for named agents. This is unverified (see Risks); the conversion is still required regardless, because the settings registrations for orchestrator and planner are known to fire.
- Constraints:
  - No production or test file exceeds 500 lines.
  - Line coverage >= 85% for every changed PowerShell production file.
  - Bundled mirrors stay byte-identical to their sources.
  - Enforcement hooks gain no Python legs. Research Q7 found that no Python is invoked by any of the five hook files or by the modules they load (`.claude/lib/orchestrator-state/*.psm1`, `.claude/lib/worktree-resolution/*.psm1`); the only matches are comment text at `validate-orchestrator-output.ps1:176` and `:235` and a regex literal at `validate-executor-output.ps1:265` that inspects agent output. The change must introduce no Python invocation.
  - Tests use no temporary files and no real wall-clock waits.
- External dependencies: E1 helper and spec; Pester and PSScriptAnalyzer as installed for the repository.

## Data / API / Config Impact

- User-facing changes: block reasons are delivered on stderr with exit 2, so a blocked subagent now sees the reason and is re-prompted, instead of the block being ignored. For non-repairable conditions the subagent is blocked once with report-and-halt wording and its next stop is allowed.
- Data or migration: none.
- Logging: block messages no longer name `CLAUDE_HOOK_INPUT`; they name `last_assistant_message` or the anomaly clause.
- Compatibility: pack manifest gains one entry; bundled mirrors change.

## Test Strategy

- Regression tests to update (payload shape from `{"output": ...}` / `-RawPayload` to `-InputText` with a `last_assistant_message` envelope, and messages that name `CLAUDE_HOOK_INPUT`):
  - `validate-orchestrator-output.Tests.ps1` (454 lines; add no new rows here because of cap headroom), `validate-orchestrator-output.model-routing.Tests.ps1`, `validate-orchestrator-output.artifact-type-dispatch.Tests.ps1`, `validate-orchestrator-output.WaveBarrier.Tests.ps1`, `validate-orchestrator-output.WorktreeResolution.Tests.ps1`, `validate-orchestrator-output-resolution.Tests.ps1` (payload helper at 45-48), `validate-executor-output.Tests.ps1`, `validate-planner-output.Tests.ps1`, `validate-required-artifact-output.Tests.ps1`.
  - `validate-planner-output.Coverage.Tests.ps1`: replace the `$env:CLAUDE_HOOK_INPUT` driver with a `[Console]::SetIn` stdin driver (original reader restored in `finally`) and assert exit 2.
  - `hook-import-failure-exemptions.FailClosed.Tests.ps1`: H7/H8 drivers stop setting `CLAUDE_HOOK_INPUT` (lines 424, 430, 438) and supply the envelope on stdin; remove the stale `finally` resets. Net growth must keep the file at or under 500 lines.
- New tests:
  - `tests/scripts/claude-hooks/validate-orchestrator-output.Envelope.Tests.ps1` (new): entry-tail rows for the orchestrator hook driven through stdin, covering block (exit 2) and pass (exit 0), the anomaly block, the legacy-source rows, and the CR-3 tail row.
  - Re-entry suites (new), one per validator: `validate-orchestrator-output.Reentry.Tests.ps1`, `validate-executor-output.Reentry.Tests.ps1`, `validate-planner-output.Reentry.Tests.ps1`, `validate-required-artifact-output.Reentry.Tests.ps1`. Each contains one `It` per non-S1 table row, named with the row ID first (for example `O-11 halt response blocks once`). Each row drives the pure entry with `-InputText` twice, once with `stop_hook_active` absent and once with `"stop_hook_active": true`, and asserts the table behavior. Row R-1 is driven through the entry tail with `[Console]::SetIn`, because the missing-argument path is in the tail. Each suite also contains an AST row asserting that the pure entry reads the `StopHookActive` member of the `Read-SubagentStopEnvelope` result.
  - New rows in `validate-orchestrator-output-resolution.Tests.ps1`: CR-1 (a checkpoint whose route key is spelled `Route_Id`, or whose field key differs only in case, is kept) and CR-3 (resolver mocked to throw yields `Ok = $false` with the `ORCHESTRATOR_CHECKPOINT_UNRESOLVED:` token).
  - New rows in `validate-executor-output.Tests.ps1` (or a new `validate-executor-output.Envelope.Tests.ps1` if needed for size): entry tail via stdin, block and pass, helper-load failure exits 2, plus coverage rows for currently untested branches.
  - New rows in `validate-planner-output.Coverage.Tests.ps1`: entry tail via stdin, block and pass.
  - New rows in `validate-required-artifact-output.Tests.ps1` (or a new `validate-required-artifact-output.Envelope.Tests.ps1`): missing-argument path exits 2 inline, validation-failure path exits 2 through `Exit-SubagentStopBlock`, pass exits 0, helper-load failure exits 2, plus coverage rows.
  - `tests/scripts/claude-hooks/subagentstop-envelope-orchestrator-family.Registration.Tests.ps1` (new): parses the `SubagentStop` frontmatter registrations in `.claude/agents/*.md` that invoke an E2 hook and asserts that every argument name passed exists in the target script's `param()` block. It also contains the AST seam rows for AC-25.
- Edge cases: empty or whitespace `last_assistant_message` (valid envelope, empty-output block); each of the six anomaly codes (anomaly block with the matching clause); envelope with an `output` key but no `last_assistant_message` (`MissingAssistantMessage` anomaly, proving `output` is not read); `CLAUDE_HOOK_INPUT` set to a valid passing payload while stdin carries a failing envelope (must block); resolver exception; case-variant checkpoint keys; `stop_hook_active` as the string `"true"` (helper yields `$false`, so block-once rows still block).
- Error handling verification: every block row asserts both exit code 2 (tail rows) or `Ok = $false` (pure-entry rows) and a reason containing the expected prefix or token.
- Coverage: self-hosted Pester coverage run over the changed production files (research Q8: a `New-PesterConfiguration` run with `CodeCoverage.Path` set to the target files, or `Invoke-PoshQCTest` with a caller `-SettingsPath`), launched through `sh <script>` because the worktree isolation guard denies direct `pwsh` text. Re-measure the baseline first: the most recent recorded values are 69.91% for `validate-executor-output.ps1` and 69.81% for `validate-required-artifact-output.ps1`, both below the floor, so added tests are required. The MCP PoshQC runner is not used for coverage figures because it loads the installed-extension module and has omitted new population files.
- Regression suites run unchanged: `hook-dependency-failure.Claude.Tests.ps1`, `hook-dependency-failure.SpecialCases.Tests.ps1`, `tests/scripts/claude-runtime/enforcement-hooks-no-python-invocation.Tests.ps1`, `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py`, `tests/scripts/dev_tools/test_push_down_claude_pack_manifest_completeness.py`, and `extensions/drm-copilot/test/lib/push-down/claude-pack-manifest-completeness.test.ts`.
- Toolchain (PowerShell): `Invoke-Formatter` check -> PSScriptAnalyzer -> Pester. Type checking does not apply to PowerShell. Restart from formatting after any failure or auto-fix.
- Evidence is written under `docs/features/active/subagentstop-envelope-orchestrator-family-903/evidence/<kind>/` (`baseline/`, `qa-gates/`, `regression-testing/`, `other/`).
- Manual validation: none required beyond the automated rows. A live named-agent SubagentStop run is desirable but is not an acceptance criterion because it depends on the unresolved frontmatter question.

## Acceptance Criteria

- [x] AC-1: Upstream gate passed before any production or test edit: after `git fetch origin`, `git cat-file -e origin/epic/subagentstop-envelope-integration:.claude/hooks/subagentstop-envelope.ps1` exits 0; `git show origin/epic/subagentstop-envelope-integration:.claude/hooks/subagentstop-envelope.ps1` contains function definitions named `Read-SubagentStopEnvelope`, `Get-SubagentStopEnvelopeAnomalyReason`, and `Exit-SubagentStopBlock`; and the drift check (upstream gate check 4) passes against `git show origin/epic/subagentstop-envelope-integration:docs/features/active/subagentstop-envelope-core-897/spec.md`: within its "## Authoritative Helper Contract" section, the three function-signature headings equal the literals ``### `Read-SubagentStopEnvelope [-InputText <string>]` ``, ``### `Get-SubagentStopEnvelopeAnomalyReason -Anomaly <string>` ``, and ``### `Exit-SubagentStopBlock -Message <string>` ``, and the `### Consumer policy for E2, E3 and E4` subsection (from that heading to the next `### ` heading) is byte-for-byte identical to the same subsection of `git show bf86505ca3bd6a2bae05fb5c16f053110af9666d`. The result, including any other non-halting difference within the contract section, is recorded under `evidence/other/`. If a signature heading or the consumer-policy subsection differs, execution halted and reported `E1 CONTRACT DRIFT`; if any other check fails, execution stopped and reported it; in neither case was a helper created.
- [x] AC-2: `validate-orchestrator-output.ps1`, with `stop_hook_active` absent from the stdin envelope, blocks with exit 2 and a stderr reason when `last_assistant_message` is empty or the required checkpoint cannot be resolved, and exits 0 when `last_assistant_message` carries a completion summary and a valid checkpoint fixture is supplied through the existing seams; verified by rows in `tests/scripts/claude-hooks/validate-orchestrator-output.Envelope.Tests.ps1`.
- [x] AC-3: `validate-executor-output.ps1`, with `stop_hook_active` absent from the stdin envelope, blocks with exit 2 and a stderr reason when `last_assistant_message` lacks a `plan-path:` line, and exits 0 when it advertises a plan whose fixture satisfies the executor checks; verified by named entry-tail rows in `tests/scripts/claude-hooks/validate-executor-output.Tests.ps1` (or `validate-executor-output.Envelope.Tests.ps1`).
- [x] AC-4: `validate-planner-output.ps1`, with `stop_hook_active` absent from the stdin envelope, blocks with exit 2 and a stderr reason when `last_assistant_message` lacks the `PREFLIGHT:` signal or the `plan-path:` line, and exits 0 when both are present with a contract-valid plan fixture; verified by stdin-driven rows in `tests/scripts/claude-hooks/validate-planner-output.Coverage.Tests.ps1`.
- [x] AC-5: `validate-required-artifact-output.ps1`, with `stop_hook_active` absent from the stdin envelope, blocks with exit 2 and a stderr reason through `Exit-SubagentStopBlock` when `last_assistant_message` lacks the artifact named by `-RequiredArtifact`; blocks with exit 2 through an inline `[Console]::Error.WriteLine(...)` and `exit 2` (not `Exit-SubagentStopBlock`) when `-AgentName` or `-RequiredArtifact` is missing; and exits 0 when the artifact is present. Verified by named rows in `tests/scripts/claude-hooks/validate-required-artifact-output.Tests.ps1` (or `validate-required-artifact-output.Envelope.Tests.ps1`), and by a row that parses the script AST and asserts `Exit-SubagentStopBlock` is called exactly once, outside the missing-argument `if` block.
- [x] AC-6: For each converted validator, with `stop_hook_active` absent: (a) a Pester row supplies `-InputText` for each anomaly code in E1's input-to-result table and asserts `Ok = $false` with a message that starts with the validator's prefix from the "Helper result handling" table followed by ` payload anomaly - ` and the clause returned by `Get-SubagentStopEnvelopeAnomalyReason` for that code; (b) a row supplies a stdin envelope that fails validation while `$env:CLAUDE_HOOK_INPUT` holds a payload that would pass, and asserts exit 2; (c) a row supplies an envelope carrying only an `output` key and asserts the `MissingAssistantMessage` anomaly block, proving neither legacy source is read.
- [x] AC-7: `rg -n "CLAUDE_HOOK_INPUT" .claude/hooks/validate-orchestrator-output.ps1 .claude/hooks/validate-orchestrator-output-routing.ps1 .claude/hooks/validate-orchestrator-output-resolution.ps1 .claude/hooks/validate-executor-output.ps1 .claude/hooks/validate-planner-output.ps1 .claude/hooks/validate-required-artifact-output.ps1` returns no match.
- [x] AC-8: `rg -n "\$payload\.output|Properties\.Name -contains 'output'|Properties\['output'\]|\.last_assistant_message|\.stop_hook_active"` over the same production file list returns no match, so assistant text is read only through `AssistantText` and the re-entry flag only through `StopHookActive`.
- [x] AC-9: `rg -n "\bexit 1\b|Write-Error"` over the same production file list returns no match.
- [x] AC-10: A failed load of the E1 helper is recorded through `Add-HookDependencyFailure -Name 'subagentstop-envelope.ps1'` and produces exit 2 through the inline S1 tail with `subagentstop-envelope.ps1` in stderr for each converted validator, including when the stdin envelope carries `"stop_hook_active": true` (rows O-0, X-0, P-0, R-0); verified by named rows in the suites listed in Test Strategy (the B1 dynamic suite covers orchestrator and planner; explicit rows cover executor and required-artifact and the `stop_hook_active: true` case for every converted validator).
- [x] AC-11: #787 CR-1 fixed: `validate-orchestrator-output-resolution.ps1` uses `-contains` for both property-name checks in `Find-OrchestratorOutputRunSignalValue`, retains `-cne` for the route value, and a new row in `validate-orchestrator-output-resolution.Tests.ps1` shows a checkpoint with a case-variant key (for example `Route_Id`) is kept.
- [x] AC-12: #787 CR-3 fixed: a new row in `validate-orchestrator-output-resolution.Tests.ps1` mocks `Resolve-OrchestratorOutputCheckpointPath` to throw and asserts `Ok = $false` with a message starting `ORCHESTRATOR_CHECKPOINT_UNRESOLVED:` and containing `RESOLVER_FAILED`, and a row in `validate-orchestrator-output.Envelope.Tests.ps1` asserts the hook exits 2 with that prefix on stderr (with `stop_hook_active` absent) rather than an unhandled error.
- [x] AC-13: #787 CR-7 fixed: `rg -n "One subprocess call" .claude/hooks/validate-orchestrator-output.ps1 .claude/hooks/validate-orchestrator-output-routing.ps1` returns no match, and the replacement comment states that the in-process validation covers the completion and model-routing checks.
- [x] AC-14: #786 double import fixed: `rg -n "OrchestratorState\.psm1'\)" .claude/hooks/validate-orchestrator-output.ps1` matches only the import line that carries `-Global`, and `hook-dependency-failure.Claude.Tests.ps1` passes.
- [x] AC-15: #786 FailClosed nit fixed: `rg -n "OrchestratorOutputResolverImportFailure|OrchestratorOutputWaveBarrierImportFailure" tests/scripts/claude-hooks/hook-import-failure-exemptions.FailClosed.Tests.ps1` returns no match, and H7 and H8 in that suite pass with exit 2.
- [x] AC-16: Split done: `.claude/hooks/validate-orchestrator-output-routing.ps1` defines `Test-OrchestratorCheckpointStructure` and `Invoke-RoutingContractValidation`, `.claude/hooks/validate-orchestrator-output.ps1` no longer defines them and loads the sibling through a guarded dot-source that calls `Add-HookDependencyFailure` on failure, and the existing `validate-orchestrator-output.artifact-type-dispatch.Tests.ps1` and the AST no-Python row in `validate-orchestrator-output.Tests.ps1` pass against the relocated functions.
- [x] AC-17: Every production and test file added or changed by E2 is at or under 500 lines, measured with `(Get-Content -LiteralPath <file>).Count` for each path in `git diff --name-only origin/epic/subagentstop-envelope-integration...HEAD`, with results recorded under `evidence/qa-gates/`.
- [x] AC-18: Line coverage is >= 85% for each changed or added PowerShell production file (including `validate-executor-output.ps1`, `validate-required-artifact-output.ps1`, and `validate-orchestrator-output-routing.ps1`), measured by a self-hosted Pester coverage run with `CodeCoverage.Path` set to those files and recorded under `evidence/qa-gates/`.
- [x] AC-19: Each changed or added production file under `.claude/hooks/` has a byte-identical mirror under `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/` (verified by `Get-FileHash` comparison recorded under `evidence/qa-gates/`), `pack-manifests/core.json` lists `.claude/hooks/validate-orchestrator-output-routing.ps1` in sorted position, and `poetry run pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py tests/scripts/dev_tools/test_push_down_claude_pack_manifest_completeness.py` passes along with `extensions/drm-copilot/test/lib/push-down/claude-pack-manifest-completeness.test.ts`.
- [x] AC-20: Frontmatter registrations are consistent: `tests/scripts/claude-hooks/subagentstop-envelope-orchestrator-family.Registration.Tests.ps1` passes, and `git diff --name-only origin/epic/subagentstop-envelope-integration...HEAD -- .claude/agents` lists at most the single path `.claude/agents/prd-feature.md`, and when that path is listed, line 18 of `.claude/agents/prd-feature.md` passes `-RequiredArtifact` exactly once.
- [x] AC-21: No Python invocation in E2 files: `tests/scripts/claude-runtime/enforcement-hooks-no-python-invocation.Tests.ps1` passes, the AST no-Python row in `validate-orchestrator-output.Tests.ps1` passes, and `rg -n "(&\s*(python|py|poetry)\b|poetry run|Start-Process|ProcessStartInfo)"` over the E2 production file list returns no match.
- [x] AC-22: Re-entry behavior matches the re-entry table. For every non-S1 row (O-1 to O-15, X-1 to X-12, P-1 to P-7, R-1 to R-5), the matching suite among `validate-orchestrator-output.Reentry.Tests.ps1`, `validate-executor-output.Reentry.Tests.ps1`, `validate-planner-output.Reentry.Tests.ps1`, and `validate-required-artifact-output.Reentry.Tests.ps1` contains an `It` whose name begins with the row ID, and that row asserts: with `stop_hook_active` absent, the condition blocks; with `"stop_hook_active": true`, a block-always row still blocks and a block-once row allows (`Ok = $true` for pure-entry rows, exit 0 for the R-1 tail row); and every block-once block message contains `to the operator and halt.` Each suite also passes an AST row asserting that the pure entry point reads the `StopHookActive` member of the `Read-SubagentStopEnvelope` result, and `rg -n "stop_hook_active"` over the E2 production file list returns no match, so the flag is read only through the helper. Those suites pass with zero failures, and the evidence record lists every non-S1 row ID from the re-entry table with its pass status.
- [x] AC-23: Out-of-scope files are untouched: `git diff --name-only origin/epic/subagentstop-envelope-integration...HEAD` lists no E3-owned or E4-owned validator or suite, no PreToolUse hook, no `.claude/settings.json`, no `.claude/hooks/subagentstop-envelope.ps1`, and no file under `tests/scripts/codex-hooks/` or `.codex/`.
- [x] AC-24: Full PowerShell toolchain is clean in a single pass over the changed PowerShell files: `Invoke-Formatter` reports no change, PSScriptAnalyzer reports zero findings, and Pester passes for every suite under `tests/scripts/claude-hooks/` and `tests/scripts/claude-runtime/`, with output recorded under `evidence/qa-gates/`.
- [x] AC-25: Pure-entry seam and exit placement conform to E1 consumer policies 3 and 5: an AST row in `subagentstop-envelope-orchestrator-family.Registration.Tests.ps1` asserts, for each of `Invoke-OrchestratorOutputValidation`, `Invoke-ExecutorOutputValidation`, `Invoke-PlannerOutputValidation`, and `Invoke-RequiredArtifactOutputValidation`, that the function declares an `InputText` parameter with `AllowNull` and `AllowEmptyString` attributes, declares no `RawPayload` or `AssistantText` parameter, and calls `Read-SubagentStopEnvelope`; and a second AST row asserts that each converted hook file calls `Exit-SubagentStopBlock` exactly once, at script scope after the S1 tail, while the S1 tail retains its inline `[Console]::Error.WriteLine` and `exit` statements.

## Risks & Mitigations

| Risk / open question | Impact | Mitigation |
|---|---|---|
| E1 contract changes between blob `bf86505ca3bd6a2bae05fb5c16f053110af9666d` and its merge into the integration branch | E2's seam, anomaly handling, or re-entry design may no longer match | Upstream gate check 4 halts with `E1 CONTRACT DRIFT` when a function-signature heading or the consumer-policy subsection differs; other contract-section differences are recorded in the upstream-gate evidence without halting, because E1 is still in preparation and non-semantic edits are expected (AC-1). |
| Block-once rows allow a second stop without the gate condition cleared | A non-repairable failure (for example a wave-barrier violation or a recorded halt) reaches the parent after one refusal instead of being held indefinitely | Required by E1 policy 2 to avoid unbounded re-invocation. The first block delivers report-and-halt wording, so the subagent's final report names the condition. AC-22 pins each classification so it cannot change silently. |
| Repairable rows can still re-block indefinitely if the agent does not fix the condition | Repeated re-invocation for a subagent that fails to repair a repairable condition | Accepted per E1 policy 2 ("may block again"). The S1 tail has the same property today. Record any observed loop in E2's review as a follow-up candidate. |
| O-5 classification depends on the agent supplying a correct run identity literal | If the live worktree set is itself ambiguous, naming a literal may not resolve it | Classified repairable because the documented resolution order takes the message literal first; record any observed non-convergence in review. |
| Adding a `Repairable` key to `Test-HumanInteractionShape` and `Get-OrchestratorOutputWaveBarrierDecision` results | A suite that asserts an exact key set would fail | Re-derive the affected assertions before editing; update them in the E2-owned suites only. |
| Unbounded re-run under exit 2 on the S1 tail | A missing hook file blocks every stop | Unchanged from #786 behavior and fixed by policy 5; out of E2's authority to change. |
| Frontmatter-only `SubagentStop` registrations are unverified (executor; required-artifact via `epic-review.md`, `prd-feature.md`, `staged-review.md`, `status-updater.md`) | Converting those hooks may have no runtime effect until the registration key is confirmed to fire | Convert them regardless (the scripts are wrong either way). Do not change registrations in E2, except the single `prd-feature.md` argument removal in Amendment 2026-10-11; record the firing question for E1's evidence or a follow-up. |
| Duplicate `-RequiredArtifact` at `.claude/agents/prd-feature.md:18` (verified parameter-binding failure: `pwsh -NoProfile -File` exits 1 with "Cannot bind parameter because parameter 'RequiredArtifact' is specified more than once") | The required-artifact hook has never validated anything for prd-feature | Resolved in scope by Amendment 2026-10-11: remove the second `-RequiredArtifact` argument from `.claude/agents/prd-feature.md` and its bundled mirror, keeping the `spec-path` requirement (AC-20). |
| `pack-manifests/core.json:66-77` adjacent-line insertions by E1 (near 66), E4 (near 71), and E2 (between 72 and 73) | Likely textual merge conflict at fan-in, not a semantic conflict | Insert in sorted position only; resolve by keeping all entries sorted at fan-in; the manifest-completeness tests confirm the result. |
| `hook-import-failure-exemptions.FailClosed.Tests.ps1` is 474 lines | Little headroom for the H7/H8 driver rewrite | Removing the stale `finally` blocks frees about 8 lines; put any new rows in new suites rather than this file. |
| Guard placement relative to `$ErrorActionPreference = 'Stop'` in `validate-planner-output.ps1` | A failed helper load under `Stop` could terminate with exit 1 | Place all guarded loads before line 36; C8 in `hook-dependency-failure.SpecialCases.Tests.ps1` detects regressions. |
| Executor and required-artifact hooks have no dependency guard today and are absent from `.claude/settings.json`, so the B-suite does not cover them | A helper load failure could leave `Exit-SubagentStopBlock` undefined and fail open | Adopt `hook-dependency-guard.ps1` and the S1 tail per E1 policies 4 and 5, with explicit test rows (AC-10). |
| Local bundle-parity test failures from gitignored state (issue #510) | A local mirror test may fail while CI passes | Confirm mirror byte identity by hash comparison and confirm the parity test in CI. |

## Rollout & Follow-up

- Release: merge into `epic/subagentstop-envelope-integration`; the integration-to-main pull request (epic #904) carries it to main.
- Pull request linkage: the E2 pull request body uses `Refs #903` and `Refs #897`. It does not use a closing keyword, because #903 is delivered only in part and #897 is delivered by E1, E2, and E3 together (epic Issue Closure).
- Follow-up candidates outside E2: the #786 always-true conditional in the three PreToolUse hooks; the #786 `SilentlyContinue` nit in `tests/scripts/codex-hooks/hook-dependency-failure.Codex.Tests.ps1:42`; the frontmatter `SubagentStop` firing question; the `prd-feature.md` `user-story-path` requirement for full-feature mode (removed by Amendment 2026-10-11; a mode-aware replacement is a separate item).
- Links: #903, #897, epic #904, `docs/features/epics/subagentstop-envelope/epic.md`, E1 spec `docs/features/active/subagentstop-envelope-core-897/spec.md` (blob `bf86505ca3bd6a2bae05fb5c16f053110af9666d`), research record above, #787 review `docs/features/active/2026-09-29-validate-orchestrator-output-session-relative-read-787/code-review.2026-10-09T00-12.md`, #786 review `docs/features/active/2026-09-29-hook-preexisting-imports-fail-open-786/code-review.2026-10-10T22-23.md`.

## Amendments

### 2026-10-11 - Remove duplicate `-RequiredArtifact` argument from `prd-feature.md` (plan Version 1.3, Amendment A)

- Reassignment: the epic coordinator reassigned this item to E2 (child #903), overriding the earlier exclusion of agent files for this item only.
- Verified fact: the SubagentStop registration at `.claude/agents/prd-feature.md:18` passes `-RequiredArtifact` twice. `pwsh -NoProfile -File` exits 1 with "Cannot bind parameter because parameter 'RequiredArtifact' is specified more than once", so that hook has never validated anything.
- Change: remove the second argument, `-RequiredArtifact 'user-story-path|^docs/features/active/.+/user-story\.md$|feature user story artifact'`, from `.claude/agents/prd-feature.md` and from its byte-identical bundled mirror `extensions/drm-copilot/resources/claude-customizations/.claude/agents/prd-feature.md`. The `spec-path` requirement is kept.
- Rationale: `pwsh -File` cannot pass an array to a `[string[]]` parameter. `spec.md` is required in both full-feature and full-bug mode, while `user-story.md` is absent by design in full-bug mode.
- Consequence for scope: this is the only agent-file change in scope; all other agent files stay unchanged. Scope item 5, the out-of-scope table, "Agent frontmatter" under Implementation strategy, the registration-consistency invariant, the two Risks rows, the follow-up candidates, and AC-20 are updated to match. No acceptance criterion is added, removed, or checked off, and no AC other than AC-20 changes text.

### 2026-10-12 - Corpus rule changes under operator Amendment B (executor and planner validators)

- Source: `evidence/other/corpus-rule-changes.2026-10-12T01-27.md` (`CORPUS_RULE_CHANGE_COUNT: 2`, pinned `CORPUS_REF_SHA: 2ef8d361e978ca8b7733a545d76a87e8418005ce`). Both entries carry `SPEC_INVARIANT_EXCEPTION: spec.md:217 (operator Amendment B)`.
- Authority: both changes were made under operator Amendment B's corpus false-positive gate, which requires zero false positives against the corpus before the validators switch to exit 2.
- RULE-CHANGE 1 (executor, `.claude/hooks/validate-executor-output.ps1`): `Test-IsPreflightPlan` and `Get-TouchedLanguagesFromPlan` now declare `[AllowEmptyString()] [string[]] $Lines`, so a plan line array that contains a blank line binds. No decision rule changes: an empty line matches neither the preflight directive pattern nor the path pattern. Rationale: the first corpus run reported `FALSE_POSITIVES=164` (`CORPUS_TOTAL=307`), every one a `HARNESS-EXCEPTION` for binding an empty string to `Lines`; a thrown exception is not a validation verdict. Covering row: `CORPUS-EXE-1 accepts a plan line array that contains an empty line` in `tests/scripts/claude-hooks/validate-executor-output.Tests.ps1`.
- RULE-CHANGE 2 (planner, `.claude/hooks/validate-planner-output.ps1`, `Get-PlanStructureValidationReport`): change A applies the same `[AllowEmptyString()]` binding fix; change B skips a non-task `- [` line that appears outside a phase section (for example under `## Preflight Checklist` after the final phase) instead of reporting `task line must match`. A canonical task line is still evaluated everywhere, and every `- [` line inside a phase section is still checked against the task pattern. Rationale: the first corpus run reported `FALSE_POSITIVES=115` (`CORPUS_TOTAL=307`) from the same binding exception, and the pre-change predicate rejected non-task checklist lines in document sections that follow the final phase, which the canonical `_plan_structure_errors` validator does not treat as tasks. Exact alignment with that oracle was not applied because it would fail the existing row at `tests/scripts/claude-hooks/validate-planner-output.Tests.ps1:227-239`. Covering row: `CORPUS-PLN-1 ignores a non-task checkbox line under a level-2 heading after the final phase` in `tests/scripts/claude-hooks/validate-planner-output.Tests.ps1`, whose line array includes an empty element and therefore covers both changes.
- Scope: these are the only first-stop rule changes beyond the listed notes. No acceptance criterion is added, removed, or checked off by this amendment.
