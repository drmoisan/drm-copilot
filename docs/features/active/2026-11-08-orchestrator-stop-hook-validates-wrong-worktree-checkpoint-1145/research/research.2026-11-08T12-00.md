# Research: orchestrator SubagentStop hook validates the wrong worktree checkpoint (issue #1145)

Branch: `bug/orchestrator-stop-hook-target-worktree`. All findings come from reading the item worktree copies.
Evidence filename note: the timestamp in this filename was not read from a clock (the researcher has no shell tool); the orchestrator may rename it.

## 1. Current behavior and defect path

Registration (`.claude/settings.json`): three SubagentStop entries run `pwsh -NoProfile -File .claude/hooks/validate-orchestrator-output.ps1` for matchers `orchestrator`, `epic-orchestrator`, `parallel-orchestrator`; the epic and parallel entries add `-CheckpointPath` and `-ArtifactType`. The relative script path runs in the hook process cwd.

Payload: `Invoke-OrchestratorOutputValidation` calls `Read-SubagentStopEnvelope` (`subagentstop-envelope.ps1`). The returned object exposes `IsValid`, `Anomaly`, `Envelope` (the parsed JSON object), `AssistantText`, `StopHookActive`, `AgentType`, `HookEventName`. Only `AssistantText` is forwarded (as `AgentOutput`). `Envelope` (which carries `agent_transcript_path`) is never used, and the hook never reads the transcript or the delegation prompt.

Resolution (`Resolve-OrchestratorOutputCheckpointPath`, `validate-orchestrator-output-resolution.ps1`):
- `SessionRoot` defaults to `(Get-Location).Path` in both `Invoke-OrchestratorOutputValidation` and `Get-OrchestratorOutputBlockDecision`; the production entrypoint passes no override.
- For `ArtifactType` `orchestrator-state` (kind `item`), the target is `Resolve-WorktreeOperandTarget -Path '' -SessionRoot $SessionRoot` (`WorktreeRunResolution.psm1`). A blank operand resolves to the enclosing worktree of the session root (`Find-WorktreeResolutionRoot`) with detail "the call names no operand, so it acts on the session worktree". This is the defect: `AgentOutput` and the delegation prompt are not consulted for the item kind.
- For `epic-orchestrator-state` and `parallel-orchestrator-state`, `Find-WorktreeRunIdentitySignal -Text $AgentOutput` reads `integration_branch:` or `parallel_slug:` literals from the agent output and falls back to discovery over live worktree checkpoints (`Find-OrchestratorOutputRunSignalValue`, via `Get-WorktreeItemLiveRoot`). Epic and parallel are therefore already target-aware and are out of scope for this fix.
- The leaf check (`Test-OrchestratorOutputCheckpointLeaf`) only confirms the `-CheckpointPath` leaf composes the canonical path under the resolved root; it does not influence the root.
- `Get-OrchestratorOutputBlockDecision` then reads `$resolution.CheckpointPath` through `Get-CheckpointFileContent`, runs the required-field checks, `Test-HumanInteractionShape` (runbook existence beneath `$resolution.WorktreeRoot`), `Invoke-RoutingContractValidation`, and `Get-OrchestratorOutputFeatureFolderDecision` (git probe at `$resolution.WorktreeRoot`).

Defect scenario: a session whose cwd is the main checkout (or any worktree other than the item worktree) delegates to `orchestrator`, which works in an item worktree and writes its checkpoint there. The hook validates the checkpoint at the session root. A stale or invalid session-root checkpoint blocks a correct run (or a valid session-root checkpoint lets an incomplete item run stop). Every downstream check (routing contract, feature-folder probe, runbook paths) inherits the wrong root because they use `$resolution.WorktreeRoot`.

Documented contrast: the `## Hook Execution Context` section of the execution-environment brief states that the SubagentStop artifact hooks resolve the item worktree through `Resolve-SubagentStopTargetWorktree`; `validate-orchestrator-output.ps1` is not listed there and does not use it.

## 2. Reusable seam

`Resolve-SubagentStopTargetWorktree` (`.claude/hooks/subagentstop-target-worktree.ps1`) is reusable directly. Adopters: researcher, prd-feature, required-artifact, planner, executor, feature-review coverage hooks (#1105) and `validate-human-exception-runbook-output.ps1` (#1128/#1137).

Inputs: `Envelope` (parsed envelope object, i.e. `$envelope.Envelope`), `AdvertisedPath` (absolute path forces FilePath source; pass `@()` for the orchestrator, which advertises no path), `SessionRoot`, and the injectable `ReadTranscriptHead` (defaults to `Read-TranscriptHead`, first 50 transcript lines), `WorktreeListInvoker` (porcelain text), `CheckpointIssueReader`. With no absolute path it reads `agent_transcript_path` from the envelope, takes the first `user` entry (`Get-TranscriptFirstUserText`), reduces it with `Get-SubagentStopIdentityPrompt` (first `branch:` label via `Find-WorktreeResolutionBranchSignal` plus canonical issue lines via `Find-WorktreeItemIssueSignal`), and calls `Resolve-HookTargetWorktree`. An issue-only identity uses `CheckpointIssueReader` (`Get-WorktreeItemCheckpointIssue`); a branch-bearing identity reads no checkpoint.

Result shape: `WorktreeRoot`, `Source` (`FilePath`, `DelegationPrompt`, or `SessionRoot`), `ReasonCode`, `Detail`.
- Resolved: `WorktreeRoot` set, `ReasonCode` null. With no identity at all, `Source` is `SessionRoot` and `Detail` is "no target source is present; the session root applies" (the root is the unnormalized session root, not the ascended worktree root).
- NoTarget: `ReasonCode` `TARGET_WORKTREE_NOT_DERIVABLE`, `WorktreeRoot` null (a present branch or identity names no registered worktree).
- Ambiguous: `ReasonCode` `TARGET_WORKTREE_AMBIGUOUS`, `WorktreeRoot` null.
- A resolver exception returns the session root with `Source` `SessionRoot` and a "resolution failed" detail.

Existing stop-hook behavior on NoTarget/Ambiguous: the callers treat a null `WorktreeRoot` as "probe the session root" and append `Get-SubagentStopTargetNote` ("Target worktree resolution returned <code> (<detail>); the session root was probed.") to the block message (#1105, runbook hook tests `falls back to the session root with TARGET_WORKTREE_NOT_DERIVABLE`). The feature-review coverage hook instead blocks on not-derivable or ambiguous. That session-root probing on a failed resolution is the behavior the owner rejects for the orchestrator hook ("never validate an unrelated checkpoint").

`Resolve-HookTargetWorktree` (`HookTargetWorktree.psm1`): source precedence FilePath, CommandOperand, DelegationIdentity, SessionRoot; disagreement gives AMBIGUOUS; an identity naming no worktree gives NOT_DERIVABLE and never the session root; worktrees are enumerated via the `WorktreeListInvoker` seam (at most once).

Consequence for the item kind: replace only the `Resolve-WorktreeOperandTarget -Path ''` call. Keep it as the no-identity fallback so a session cwd that is a subdirectory still ascends to its worktree root (the `SessionRoot`-source result of `Resolve-SubagentStopTargetWorktree` does not ascend).

## 3. Prior art and test seams

- #1113/#1120: `Resolve-HookTargetWorktree` adoption in batch-budget hooks; tests `enforce-powershell-batch-budget.TargetWorktree.Tests.ps1`, `enforce-python-batch-budget.TargetWorktree.Tests.ps1` (inject `WorktreeListInvoker`).
- #1105: `subagentstop-target-worktree.Tests.ps1` plus per-hook `*.TargetWorktree.Tests.ps1` files (planner, prd-feature, required-artifact, researcher, executor, feature-review-coverage).
- #1137/#1128: `validate-human-exception-runbook-output.TargetWorktree.Tests.ps1` is the closest template. The decision function takes `-InputText`, `-SessionRoot`, `-ReadTranscriptHead`, `-WorktreeListInvoker` and in-memory file seams; the envelope carries `agent_transcript_path`; the transcript reader returns one JSONL `user` entry; the list invoker returns porcelain text for `/synthetic-worktrees/main` and a `.claude/worktrees/<name>` root with `branch refs/heads/<branch>`. It uses `Register-EpicStateBaselineMock` / `Invoke-EpicStateInterceptionProbe` (`EpicStateIsolation.Baseline.Helpers.ps1`) and asserts the unrelated session root is never read.
- #1140/#1143: `hook-epic-fan-in.ps1` scope-object seam (preimplementation gate); not needed here beyond the pattern of a separate dot-sourced helper with a pure decision function.
- #1142 nesting-depth helper: no bearing on this fix.

Existing orchestrator-output test files (`tests/scripts/claude-hooks/`, logical lines): `validate-orchestrator-output.Tests.ps1` 454, `.WorktreeResolution.Tests.ps1` 366, `.MutationRejection.Tests.ps1` 412, `-resolution.Tests.ps1` 254, `-rejection.Tests.ps1` 251, `.WaveBarrier.Tests.ps1` 250, `.Envelope.Tests.ps1` 211, `.Reentry.Tests.ps1` 210, `.FeatureFolder.Tests.ps1` 192, `.model-routing.Tests.ps1` 161, `.human-interaction.Tests.ps1` 138, `.artifact-type-dispatch.Tests.ps1` 330.
Seams already used by `.WorktreeResolution.Tests.ps1`: `Get-CheckpointFileContent` mock (path-keyed in-memory map via `Set-OutputCheckpointRead`), `Get-WorktreeItemLiveRoot` and `Get-WorktreeRunCheckpointText` mocks (module and script scope, `Set-OutputRunTopology`), `-RoutingInvoker`, `-FeatureFolderGitInvoker`, `-InputText`. `Invoke-OrchestratorOutputValidation` currently has no transcript or worktree-list seam; the fix adds `-ReadTranscriptHead` and `-WorktreeListInvoker` (optional, forwarded only when bound, matching the existing `RoutingInvoker` pattern). Existing tests omit `agent_transcript_path`, so they resolve through the unchanged fallback.

## 4. Codex twin

None. `.codex/hooks/` has no `validate-orchestrator-output*` file. `.codex/config.toml` registers `validate-codex-subagent-routing.ps1` for the `orchestrator` SubagentStop matcher, which is a routing validator and does not read the checkpoint. The Codex review coverage hook already has its own target logic (#1114). The defect is Claude-only; no Codex change is in scope.

## 5. Mirrors, manifests, pinning tests

Files that will change, and their bundle copies (byte-identical, `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/`): `validate-orchestrator-output.ps1`, `validate-orchestrator-output-resolution.ps1`, and any new sibling (for example `validate-orchestrator-output-target.ps1`). `subagentstop-target-worktree.ps1` needs no change.
- Pack manifest: `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json` lists the five existing hook files (and `subagentstop-target-worktree.ps1`); a new sibling must be added there.
- `.claude/settings.json` (and its bundle copy) need no change unless the command line changes (it should not).
- Contract tests to run: `test_push_down_claude_resource_contracts.py` (bundle equality), `test_push_down_claude_pack_manifest_completeness.py` (new file listed), `test_push_down_pack_manifest_dependency_closure.py` (the new sibling is a `$PSScriptRoot` dependency and must be in core), `tests/scripts/claude-runtime/hook-dependency-guard-completeness.Tests.ps1` (guarded dot-source form `try { . (Join-Path $PSScriptRoot '...') } catch { Add-HookDependencyFailure ... }`), `tests/scripts/claude-runtime/claude-architecture-doc.Tests.ps1`. `tests/scripts/dev_tools/parallel_orchestrator_surface_expectations.py` references the hook only as a command-fragment string (`HOOK_COMMAND_FRAGMENTS`); its `PINNED_FROZEN_SURFACE_HASHES` cover only the epic agent and skill, which this fix does not touch.
- Documentation: the `## Hook Execution Context` bullet "SubagentStop artifact paths (#1105)" in the execution-environment brief should gain the orchestrator stop hook. The brief has six byte-identical copies: `.claude/skills/execution-environment/SKILL.md`, `.agents/skills/execution-environment/SKILL.md`, `.github/skills/execution-environment/SKILL.md`, and the three bundled copies under `extensions/drm-copilot/resources/`. If the orchestrate skill or the `.claude/rules/orchestrator-state.md` "Enforcement" wording is changed (both name the hook), mirror those copies and run the wording contract tests named in the brief; this is optional and not required for the behavior fix.

## 6. File-size headroom (logical lines, hard limit 800)

- `validate-orchestrator-output.ps1`: 376 (headroom 424).
- `validate-orchestrator-output-resolution.ps1`: 311 (headroom 489).
- `subagentstop-target-worktree.ps1`: 349 (unchanged).
- `validate-orchestrator-output.WorktreeResolution.Tests.ps1`: 366; `validate-orchestrator-output.Tests.ps1`: 454.
No file is near the 500-line guidance tier. A new test file is preferred over growing existing ones.

## 7. Conflict with PR #1139

PR #1139 (in flight) also edits `validate-orchestrator-output.ps1`. Keep the edit to that file minimal (new parameters forwarded, one call-site change) and put the target-resolution logic in a new dot-sourced sibling `validate-orchestrator-output-target.ps1` (guarded load line added next to the existing sibling loads). The sibling holds a pure function `Resolve-OrchestratorOutputItemTarget` that wraps the seam, so the main file diff stays at about 10 lines.

## 8. Recommended design

Selected approach: reuse `Resolve-SubagentStopTargetWorktree` in a new sibling, applied to the `item` kind only.

Alternatives rejected: (a) calling `Resolve-HookTargetWorktree` directly from the resolution file would duplicate the transcript reading and identity reduction that `Resolve-SubagentStopTargetWorktree` already owns (#1105); (b) scanning `AgentOutput` for a worktree path or branch would depend on model-authored text rather than the delegation prompt and would not match the owner-specified prompt identity.

Resolution order for `orchestrator-state`:
1. Call `Resolve-SubagentStopTargetWorktree -Envelope $envelope.Envelope -AdvertisedPath @() -SessionRoot $SessionRoot` with the forwarded seams.
2. Resolved with a `DelegationPrompt` source: use that `WorktreeRoot`; the checkpoint is the canonical path beneath it (leaf check unchanged). All downstream checks use this root.
3. Source `SessionRoot` (no transcript, no prompt identity, or a resolver exception): fall back to the existing `Resolve-WorktreeOperandTarget -Path ''` result and append a fallback note to the resolution `Detail` and to hook output: `no target worktree is identifiable from the delegation prompt (no branch: label or canonical issue line); the checkpoint of the session worktree is validated`. On the allow path the note goes to stderr with exit 0 (visible in verbose hook logs only); on every block message it is appended so the model sees it. A resolver-exception detail is included in the same note.
4. NoTarget: do not read any checkpoint. Return an unresolved result (`Status` `NoTarget`, `ReasonCode` `TARGET_WORKTREE_NOT_DERIVABLE`) so the existing block `ORCHESTRATOR_CHECKPOINT_UNRESOLVED: orchestrator-state: NoTarget (TARGET_WORKTREE_NOT_DERIVABLE): <detail>` is produced. The gate is not weakened and no unrelated checkpoint is read.
5. Ambiguous: same as NoTarget with `Ambiguous` / `TARGET_WORKTREE_AMBIGUOUS`; the block is non-repairable by the subagent (`Repairable` false for the item kind, as today's unresolved item path), so it blocks once and the re-entry policy (#903) applies unchanged.
6. The `-CheckpointPath` leaf shape check still runs first, before any resolver call, as today.

Behavior constraints: the epic and parallel kinds are unchanged. Reads stay behind `Get-CheckpointFileContent` and the existing module seams; no new file reads in the helper beyond `Read-TranscriptHead` (default seam). The unresolved item path uses the existing `Rejected`/unresolved block text so `Get-OrchestratorOutputRejectionDecision` (parallel-only, #1012) is unaffected. No absolute paths are written to committed artifacts; tests use `/synthetic-worktrees/...`.

Minimal test matrix (new file `validate-orchestrator-output.TargetWorktree.Tests.ps1`, in-memory seams only, modeled on the runbook TargetWorktree test; `Get-CheckpointFileContent` mocked to a path-keyed map and recording reads):
1. Session-root checkpoint invalid, item checkpoint valid, prompt `branch: bug/sample-1145` plus canonical issue line: allow, and the session-root path is never read (fail-before: current code blocks).
2. Session-root checkpoint valid, item checkpoint invalid: block with the item checkpoint path in the message (fail-before: current code allows).
3. No transcript or no identity in the prompt: validate the session worktree checkpoint, and the fallback note is present in the block message and on stderr when allowed.
4. Prompt names a branch with no registered worktree (NoTarget): block with `TARGET_WORKTREE_NOT_DERIVABLE`; zero checkpoint reads.
5. Ambiguous (branch and issue line naming different worktrees via the list invoker and `CheckpointIssueReader`): block with `TARGET_WORKTREE_AMBIGUOUS`; zero reads.
6. Issue-line-only prompt resolved through `CheckpointIssueReader`: item root used.
7. Resolver exception path: session worktree with the failure note.
8. `StopHookActive` re-entry with Ambiguous: allowed after one block (unchanged policy), plus epic/parallel regression rows already in `.WorktreeResolution.Tests.ps1`.
Also add a pure-function test file for the sibling (`validate-orchestrator-output-target.Tests.ps1`). Coverage target 85%+ lines on the new sibling; PowerShell has no branch gate.

## Automation Feasibility

State: fully automatable, no human interaction. Every step is a hook and test edit verified by Pester suites with in-memory seams, the push-down contract tests, and the PoshQC format/analyze/test loop. A live subagent check is not possible for the branch hook (isolated subagents run `main`'s hook copies); proof is by Pester only. No external service, credential, or manual approval is required.

## Pre-Mortem

- Review checklists: the review could fail on missing guarded dot-source form, missing `[CmdletBinding()]`/docstrings on the new sibling, or stale wording in the execution-environment brief. Mitigation: use the existing `try { . ... } catch { Add-HookDependencyFailure ... }` form, document every function, update the brief bullet in all six copies in the same change.
- Coverage: the new sibling's fallback, NoTarget, Ambiguous, and exception branches could leave lines uncovered. Mitigation: the eight-row matrix plus a pure-function test file; check per-file line coverage (>= 85%) from the single parallel Pester run.
- Mirror parity: a new sibling not copied to the bundle or not listed in `pack-manifests/core.json` fails `test_push_down_claude_resource_contracts.py`, manifest completeness, and dependency closure. Mitigation: copy all three changed/new hook files byte-identically and add the manifest entry in the same task.
- File size: no file approaches 500 lines (largest touched hook is 376). Mitigation: put new tests in a new test file, not in the 454-line existing file.
- Test isolation: global `Mock` state or module imports could leak across shards. Mitigation: reuse `Register-EpicStateBaselineMock`, no temp files, no environment or location changes, run `Invoke-PoshQCLeakScan`.
- CI-only behavior: the Linux hook-suite job needs forward-slash `/synthetic-worktrees/...` roots, no drive letters, and case-correct file names; `Get-Location` as default `SessionRoot` must not leak into assertions. Mitigation: pass `-SessionRoot` explicitly in every new test.
- Evidence: a branch hook cannot be exercised by an isolated subagent, and PR #1139 may change the same file. Mitigation: evidence is the Pester fail-before/pass-after run recorded under `evidence/regression-testing/` (fail-before with the new test file against the unmodified hook), and the new logic lives in a separate sibling to keep the merge with #1139 trivial; rebase on `main` before the final gate.
