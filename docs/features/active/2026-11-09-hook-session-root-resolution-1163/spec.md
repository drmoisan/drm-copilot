# hook-session-root-resolution (Spec)

- **Issue:** #1163
- **Parent (optional):** none
- **Owner:** drmoisan
- **Last Updated:** 2026-11-09
- **Status:** Draft
- **Version:** 1.0
- **Work Mode:** full-bug (this file is the sole acceptance-criteria source)
- **Requirements source:** `docs/features/active/2026-11-09-hook-session-root-resolution-1163/issue.md`
- **Research:** `docs/features/active/2026-11-09-hook-session-root-resolution-1163/research/2026-11-09-hook-session-root-resolution-research.md`

## Context

- Several Claude and Codex hooks read a checkpoint, an artifact, a receipt, or a feature folder beneath the hook process directory (the coordinator's checkout) or beneath the root that holds the hook script, instead of beneath the worktree that owns the item. When a coordinator, or a child agent whose identity does not resolve, triggers such a hook, the hook evaluates the coordinator's copy. The resulting false block leads the agent to undo a correct change in its own worktree.
- After a worktree is restored at a different host path, hook resolution matches the stale `prunable` registration, so agents cannot locate their own worktree's checkpoint.
- Observed environment: a multi-feature epic with five features running in parallel on one shared development machine (owner request of 2026-11-09).
- Impact: false negatives in SubagentStop and PreToolUse gates, reverted fixes, and blocked runs after a host move. Every orchestrated run that delegates to worktree-isolated children is exposed.

## Problem

1. Stop and write hooks resolve child-agent checkpoints and outputs under the coordinator's main checkout instead of the child's worktree, which produces false negatives and leads agents to revert their own in-place fixes.
2. Agents cannot reliably locate their own worktree's checkpoint after a session moves between machines.

## Root Cause Analysis

### No hook writes a child's file

The research searched `.claude/hooks/`, `.claude/lib/`, `.codex/hooks/`, and the orchestration validator scripts for file writers and `git checkout`, `restore`, `reset`, and `stash` invocations (research Question 2). The only writers are session-root state files, the session-id writer, the Codex attestation and authority writers, and the discovery start records. No hook rewrites a tracked file, checkpoint, plan, or evidence file. The "validator reverts a fix" behavior is agent behavior driven by a false block.

### The three verified false-block paths

1. **Completion write denied by a session-root existence probe.** A coordinator that writes or edits an item checkpoint by absolute path to assert completion is evaluated by `Get-MissingCompletionEvidence` in `.claude/hooks/enforce-completion-consistency.ps1` (and the Codex copy `.codex/hooks/enforce-completion-consistency.ps1`). It calls `Test-IsValidFeatureFolder` (`.claude/hooks/enforce-completion-helpers.ps1`, `.codex/hooks/enforce-completion-helpers.ps1`) with the default `FolderExistsCheck`, which runs `Test-Path` on the repository-relative feature folder beneath the hook process directory. A new, uncommitted feature folder that exists only in the item worktree is reported invalid, and the deny remedy offers "remove the completion assertion", which the agent applies to its own correct checkpoint.
2. **SubagentStop probe of the coordinator copy.** When a delegation prompt carries an identity that does not resolve (a stale `prunable` registration after a host move, or a branch registered twice), `Resolve-SubagentStopTargetWorktree` in `.claude/hooks/subagentstop-target-worktree.ps1` returns a `$null` root, `Resolve-SubagentStopArtifactLocation` treats it as the session root, and the six SubagentStop artifact hooks probe the coordinator's copy. The child's fixed artifact lives in its worktree; the hook reports a missing file or validates an older copy, and the child edits or reverts its artifact to satisfy the copy that was read.
3. **Orchestrator stop with no identity.** `.claude/hooks/validate-orchestrator-output.ps1` validates the session worktree's checkpoint when the prompt carries no `branch:` or canonical issue line (`ORCHESTRATOR_CHECKPOINT_FALLBACK:`). This path is reachable only when a coordinator delegation omits mandatory identity lines; for an isolated child the session root is the child's own worktree. It stays as designed (D5).

Two further session-root-bound readers were found that do not cause reverts but produce wrong decisions:

- `.claude/hooks/enforce-file-size-limit.ps1` and `.codex/hooks/enforce-file-size-limit.ps1` set `RepositoryRoot` to `(Get-Location).ProviderPath`. An absolute path into an agent worktree under `.claude/worktrees/` is then classified as uncovered, and a path in a sibling worktree outside the root yields no relative path; both are silently allowed.
- `.claude/hooks/validate-docs-role-output.ps1` (`Test-DocsRoleOutputFile`) probes repository-relative paths beneath the hook process directory, and `.claude/hooks/enforce-docs-complete-gate.ps1` (`Get-DocsCompleteGateRepositoryRoot`) reads the validation receipt beneath the root two levels above `$PSScriptRoot`.

### Host-move mechanism (prunable registrations)

- `Resolve-HookTargetWorktree` in `.claude/lib/worktree-resolution/HookTargetWorktree.psm1` (Codex twin `.codex/hooks/hook-target-worktree.ps1`) parses the `prunable` flag through `ConvertFrom-HookTargetWorktreePorcelain` but does not exclude prunable records when matching a branch. After a restore at a new host path, the stale registration still matches the branch and resolves to a directory that no longer exists. If the worktree was also re-added at the new path, the branch matches two records and resolves `TARGET_WORKTREE_AMBIGUOUS`.
- The filesystem-ascent family (`WorktreeResolution.psm1`, `WorktreeItemResolution.psm1`, `WorktreeRunResolution.psm1` and siblings under `.claude/lib/worktree-resolution/`) reads each administrative `gitdir` entry, which points to the old path until `git worktree repair` runs; the live-marker test drops it and identity resolution returns `NoTarget` (fail closed).
- `Test-WorktreeRunRecordedPathMatchesTarget` in `.claude/lib/worktree-resolution/WorktreeRunRecordPath.psm1` compares a recorded absolute `worktree_path` with the live target. After a host move, an absolute record never matches; the removal gates deny, and the green-CI item lookup through `Resolve-WorktreeRunTargetByRecord -RecordField worktree_path` (defined in `.claude/lib/worktree-resolution/WorktreeRunResolution.psm1`, called from `.claude/hooks/enforce-epic-merge-gate-green-ci.ps1`) resolves `NoTarget`. The epic and parallel checkpoint records carry `branch_name` alongside `worktree_path`, which is the portable alternative.

## Scope

### In scope

- A new pure resolver module `.claude/lib/worktree-resolution/AgentTargetWorktree.psm1` and its Codex twin `.codex/hooks/agent-target-worktree.ps1`, composing `Resolve-HookTargetWorktree` without modifying it.
- Adoption of the resolver by the session-root-bound and partial hooks identified in research Question 1: the SubagentStop helper and its six artifact hooks, completion consistency (Claude and Codex), file size (Claude and Codex), docs-role output, and the docs-complete gate.
- The recorded-path branch fallback in `.claude/lib/worktree-resolution/WorktreeRunRecordPath.psm1`, consumed by the removal gates and the green-CI item lookup (D9).
- Tests, bundle mirrors, pack-manifest entries, the execution-environment brief in all six copies, and `.claude/rules/orchestrator-state.md` with its bundle mirror.

### Out of scope

| Item | Reason |
|---|---|
| Codex hooks rooted at `$PSScriptRoot` (`.codex/hooks/enforce-epic-merge-gate.ps1`, `.codex/hooks/enforce-epic-wave-barrier.ps1`, `.codex/hooks/enforce-epic-worktree-removal-gate.ps1`, `.codex/hooks/enforce-epic-planning-only.ps1`, `.codex/hooks/record-subagent-routing-attestation.ps1`, `.codex/hooks/enforce-codex-model-routing.ps1`, `.codex/hooks/validate-codex-subagent-routing.ps1`, `.codex/hooks/codex-epic-child-launch-attestation.ps1`) | They already resolve correctly: `.codex/hooks/enforce-epic-child-worktree-binding.ps1` requires payload `cwd`, the hook repository root, and the expected child worktree to be identical, so the hook root is the child's worktree. Not a scope reduction. |
| Epic and parallel kinds of `.claude/hooks/validate-orchestrator-output.ps1` | They already resolve by `integration_branch:` / `parallel_slug:` identity signals. Not a scope reduction. |
| Item-kind no-identity fallback in `.claude/hooks/validate-orchestrator-output.ps1` | Correct by design (D5); the file is not edited. |
| Hooks already resolving by portable identity (merge, removal-root, barrier, drift, model-routing, PR-author, prd-feature, batch-budget, preimplementation gates) | No defect in their root resolution; the removal gates and green-CI lookup change only through the D9 record comparison. |
| `.claude/lib/worktree-resolution/HookTargetWorktree.psm1`, `.codex/hooks/hook-target-worktree.ps1` | Kept byte-unchanged (D1) to preserve their pinned contracts and to avoid overlap with #1160. |
| Preimplementation gate files (`.claude/hooks/enforce-orchestration-preimplementation-gate.ps1` and its helper scripts, and the `.codex/hooks/` twins) | Owned by sibling #1160. |
| `.claude/lib/cleanup-manifest/CleanupWorktreeManifest.psm1` | Not a removal gate or green-CI lookup; it calls `Test-WorktreeRunRecordedPathMatchesTarget` without the new optional parameters and therefore keeps today's result. |
| Rewriting a rooted `runbook_path` (`Resolve-OrchestratorOutputRunbookPath`) | Recorded as D13. |
| Batch-budget state keyed by absolute root (`Get-HookTargetWorktreeKey`) | Per-session state with no cross-host effect. |
| Running `git worktree repair` automatically | Operator guidance only; documented, not performed. |
| `.claude/settings.json`, `.codex/config.toml` | No registration change; sibling #1159 owns hook dispatch. |

## Design Decisions

- **D1 — New module, not an extension.** Add `.claude/lib/worktree-resolution/AgentTargetWorktree.psm1` and the Codex twin `.codex/hooks/agent-target-worktree.ps1` with byte-identical function text. `.claude/lib/worktree-resolution/HookTargetWorktree.psm1` and `.codex/hooks/hook-target-worktree.ps1` stay byte-unchanged, so the pins in `tests/scripts/claude-lib/worktree-resolution/HookTargetWorktree.Tests.ps1` and `tests/scripts/codex-hooks/hook-target-worktree.Tests.ps1` need no edits. The module exposes `ConvertTo-AgentTargetLiveWorktreeListText` (pure; parses porcelain with `ConvertFrom-HookTargetWorktreePorcelain`, drops `Prunable` records, re-renders porcelain text, and returns the dropped records) and `Resolve-AgentTargetWorktree` (pure; seams `WorktreeListInvoker` and `CheckpointIssueReader`; parameters `SessionRoot`, `FilePath`, `CommandOperandPath`, `CommandBranch`, `DelegationPrompt`, `AgentWorkingDirectory`, `Policy` with values `SessionFallback` and `FailClosedOnIdentity`). It calls `Resolve-HookTargetWorktree` with a wrapped invoker that returns the filtered porcelain. Its result carries the existing result fields plus `Source = 'AgentWorkingDirectory'` as an allowed source value, `Unresolved` (bool), and `StaleRegistration` (dropped prunable roots). The result of `Resolve-HookTargetWorktree` is never altered for existing callers.
- **D2 — Precedence.** Absolute file path, then command operand or command branch, then the delegation `branch:` label (cross-checked with the canonical issue line), then the canonical issue line alone (through `CheckpointIssueReader`), then the agent working directory (its enclosing non-prunable registered worktree), then the session root. The first present source decides; no later source is consulted. An absolute advertised path keeps first place, as in #1105.
- **D3 — Prunable registrations are excluded** from branch, issue, and enclosing-root matching. A branch whose only registration is prunable returns `TARGET_WORKTREE_NOT_DERIVABLE` with a detail that names the stale root and the remedy `git worktree repair`.
- **D4 — SubagentStop artifact hooks fail closed on an unresolved present identity.** `Resolve-SubagentStopTargetWorktree` routes through `Resolve-AgentTargetWorktree` with `Policy = FailClosedOnIdentity` and the payload `cwd` as `AgentWorkingDirectory`. `Resolve-SubagentStopArtifactLocation` gains an optional `-Target` parameter (default `$null` keeps today's behavior); when the target carries a reason code it returns `Rejected` with a detail naming the code. The six hooks `.claude/hooks/validate-task-researcher-output.ps1`, `.claude/hooks/validate-prd-feature-output.ps1`, `.claude/hooks/validate-required-artifact-output.ps1`, `.claude/hooks/validate-planner-output.ps1`, `.claude/hooks/validate-executor-output.ps1`, and `.claude/hooks/validate-human-exception-runbook-output.ps1` pass `-Target`; their existing `Rejected` branches block without probing any root. This is the behavior change the issue authorizes ("never from the coordinator's root").
- **D5 — No identity keeps the session-root fallback** for the SubagentStop hooks and for `.claude/hooks/validate-orchestrator-output.ps1`, after the agent-working-directory source. Parity rows prove unchanged decisions.
- **D6 — Completion consistency roots its feature-folder probe** at the worktree that encloses the checkpoint `file_path` (FilePath source), in `.claude/hooks/enforce-completion-consistency.ps1` and `.codex/hooks/enforce-completion-consistency.ps1`, by supplying a `FolderExistsCheck` rooted at that worktree. A relative path, a path in no registered worktree, or a listing failure keeps the process-relative probe.
- **D7 — The file-size gate measures paths in other worktrees.** In `.claude/hooks/enforce-file-size-limit.ps1` and `.codex/hooks/enforce-file-size-limit.ps1`, `RepositoryRoot` becomes the enclosing non-prunable registered worktree of an absolute `file_path`. This turns a silent allow into the correct decision for files in agent or sibling worktrees; a relative path, a path in no registered worktree, or a listing failure keeps today's decision.
- **D8 — Docs-role output and the docs-complete gate adopt the resolver.** `.claude/hooks/validate-docs-role-output.ps1` resolves through `Resolve-SubagentStopTargetWorktree` and probes `docs-profile`, `docs-snapshot`, and `docs-pages-written` paths beneath the resolved root. `.claude/hooks/enforce-docs-complete-gate.ps1` passes the PR `headRefName` from its existing `gh pr view` lookup as `CommandBranch` and reads the validation receipt beneath the worktree that has that branch checked out when exactly one non-prunable registration matches; zero or several matches keep today's root.
- **D9 — Recorded absolute `worktree_path` falls back to the portable `branch_name` (in scope; revised by the orchestrator, overriding the research).**
  - Location. `Test-WorktreeRunRecordedPathMatchesTarget` in `.claude/lib/worktree-resolution/WorktreeRunRecordPath.psm1` (bundle mirror `extensions/drm-copilot/resources/claude-customizations/.claude/lib/worktree-resolution/WorktreeRunRecordPath.psm1`; no Codex twin exists). `Resolve-WorktreeRunTargetByRecord` is defined in `.claude/lib/worktree-resolution/WorktreeRunResolution.psm1`, not in `WorktreeRunRecordPath.psm1`; it reaches the comparison through its private `Test-WorktreeRunCheckpointRecord`. The direct gate call sites are in `.claude/hooks/enforce-epic-worktree-removal-gate.ps1`, `.claude/hooks/enforce-epic-worktree-removal-gate-resolution.ps1`, and `.claude/hooks/enforce-parallel-worktree-removal-gate.ps1`; the green-CI item lookup is `.claude/hooks/enforce-epic-merge-gate-green-ci.ps1`, which reaches the comparison through `Resolve-WorktreeRunTargetByRecord` and needs no edit.
  - Rule. `Test-WorktreeRunRecordedPathMatchesTarget` gains optional parameters `-RecordedBranch` (default `$null`), `-LiveWorktreeRoot` (the live non-prunable registered roots, default empty), and `-BranchWorktreeResolver` (a script-block seam, default `$null`, whose production value calls `Resolve-AgentTargetWorktree -CommandBranch`). When the record is rooted, matches no entry of `-LiveWorktreeRoot`, and `-RecordedBranch` is non-blank, the function resolves the branch through the seam (non-prunable registrations only) and matches when exactly one worktree resolves and it equals the target under `Test-WorktreeRunPathEqual`. Zero or several resolved worktrees keep today's result (no match, so the gates stay fail-closed). A rooted record that matches a live registration, a relative record, and every call that omits the new parameters keep today's result exactly.
  - Adoption. `Test-WorktreeRunCheckpointRecord` in `.claude/lib/worktree-resolution/WorktreeRunResolution.psm1` and the record loops in the three removal-gate scripts pass each record's `branch_name`, the live root list, and the production seam.
  - Composition with #1161. #1161 may also edit `WorktreeRunRecordPath.psm1` and the removal gates. The plan re-reads these files at execution start, and the change is confined to the no-live-match branch of the comparison and to argument passing at the call sites, so it composes in either merge order.
- **D10 — No configuration knob.** The changed decisions are the defects the issue names; a knob that defaults to today's behavior would leave them in place. Every other decision is pinned by parity rows. Neither `.claude/settings.json` nor `.codex/config.toml` changes.
- **D11 — Adoption order:** (1) module, Codex twin, and their tests; (2) `.claude/hooks/subagentstop-target-worktree.ps1` routes through the module and accepts `-Target`, then the six SubagentStop hooks; (3) completion consistency on Claude and Codex; (4) file size on Claude and Codex; (5) docs-role output; (6) docs-complete gate; (7) the D9 record-path fallback and its call sites; (8) mirrors, manifests, brief, and rule.
- **D12 — Size.** The change set exceeds the direct-mode batch budget and the 20-task plan guideline, so it runs on the orchestrated large path and the plan carries a `## Size Justification` section. Production PowerShell sources: 2 new (`AgentTargetWorktree.psm1`, `agent-target-worktree.ps1`) and the modified files named in D4, D6, D7, D8, and D9, each with its bundle mirror, plus 2 pack manifests and 8 documentation copies.
  - **D12 addendum.** The research option to split the docs-role output and docs-complete gate adoption into a follow-up item is rejected; both remain in this item.
- **D13 — A rooted `runbook_path` is not rewritten.** `Resolve-OrchestratorOutputRunbookPath` keeps returning a rooted `runbook_path` unchanged; an absent file remains a fail-closed signal. Producers are governed by the existing rule against absolute paths in artifacts.

## Proposed Fix

### Design summary

A host-neutral resolver (`Resolve-AgentTargetWorktree`) decides the target worktree from portable identity in the D2 order over non-prunable registrations only. The SubagentStop helper, completion consistency, file size, docs-role output, and docs-complete gate consume it through minimal call-site edits. The run-record comparison adds a branch fallback for absolute records that match no live registration.

### Boundaries and invariants to preserve

- `HookTargetWorktree.psm1` and `hook-target-worktree.ps1` are byte-unchanged; their export list, result-field list, allowed `Source` set, and twin count pins hold.
- Every decision not named in D3, D4, D6, D7, D8, or D9 is unchanged, shown by parity rows.
- No hook writes, restores, or normalizes a tracked file or a checkpoint.
- No absolute path is persisted by any changed code.

### Files to create

- `.claude/lib/worktree-resolution/AgentTargetWorktree.psm1`
- `.codex/hooks/agent-target-worktree.ps1`
- `extensions/drm-copilot/resources/claude-customizations/.claude/lib/worktree-resolution/AgentTargetWorktree.psm1`
- `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/agent-target-worktree.ps1`
- `tests/scripts/claude-lib/worktree-resolution/AgentTargetWorktree.Tests.ps1`
- `tests/scripts/claude-lib/worktree-resolution/AgentTargetWorktree.Rows.Helpers.ps1`
- `tests/scripts/codex-hooks/agent-target-worktree.Tests.ps1`
- `tests/scripts/claude-hooks/enforce-completion-consistency.TargetWorktree.Tests.ps1`
- `tests/scripts/codex-hooks/enforce-completion-consistency-target-worktree.Tests.ps1`
- `tests/scripts/claude-hooks/enforce-file-size-limit.TargetWorktree.Tests.ps1`
- `tests/scripts/codex-hooks/enforce-file-size-limit-target-worktree.Tests.ps1`
- `tests/scripts/claude-hooks/validate-docs-role-output.TargetWorktree.Tests.ps1`

### Files to modify (production, each with its bundle mirror)

- `.claude/hooks/subagentstop-target-worktree.ps1`
- `.claude/hooks/validate-task-researcher-output.ps1`
- `.claude/hooks/validate-prd-feature-output.ps1`
- `.claude/hooks/validate-required-artifact-output.ps1`
- `.claude/hooks/validate-planner-output.ps1`
- `.claude/hooks/validate-executor-output.ps1`
- `.claude/hooks/validate-human-exception-runbook-output.ps1`
- `.claude/hooks/enforce-completion-consistency.ps1`
- `.codex/hooks/enforce-completion-consistency.ps1`
- `.claude/hooks/enforce-file-size-limit.ps1`
- `.codex/hooks/enforce-file-size-limit.ps1`
- `.claude/hooks/validate-docs-role-output.ps1`
- `.claude/hooks/enforce-docs-complete-gate.ps1`
- `.claude/lib/worktree-resolution/WorktreeRunRecordPath.psm1`
- `.claude/lib/worktree-resolution/WorktreeRunResolution.psm1`
- `.claude/hooks/enforce-epic-worktree-removal-gate.ps1`
- `.claude/hooks/enforce-epic-worktree-removal-gate-resolution.ps1`
- `.claude/hooks/enforce-parallel-worktree-removal-gate.ps1`

Bundle mirrors live at the same relative path under `extensions/drm-copilot/resources/claude-customizations/` for `.claude/` sources and under `extensions/drm-copilot/resources/codex-and-agents-customizations/` for `.codex/` sources.

### Files to modify (tests)

- `tests/scripts/claude-hooks/subagentstop-target-worktree.Tests.ps1`
- `tests/scripts/claude-hooks/validate-task-researcher-output.TargetWorktree.Tests.ps1`
- `tests/scripts/claude-hooks/validate-prd-feature-output.TargetWorktree.Tests.ps1`
- `tests/scripts/claude-hooks/validate-required-artifact-output.TargetWorktree.Tests.ps1`
- `tests/scripts/claude-hooks/validate-planner-output.TargetWorktree.Tests.ps1`
- `tests/scripts/claude-hooks/validate-executor-output.TargetWorktree.Tests.ps1`
- `tests/scripts/claude-hooks/validate-human-exception-runbook-output.TargetWorktree.Tests.ps1`
- `tests/scripts/claude-hooks/enforce-docs-complete-gate.Tests.ps1`
- `tests/scripts/claude-lib/worktree-resolution/WorktreeRunRecordPath.Tests.ps1`
- `tests/scripts/claude-lib/worktree-resolution/WorktreeRunResolution.Record.Tests.ps1`
- `tests/scripts/claude-hooks/enforce-epic-worktree-removal-gate.RelativeRecord.Tests.ps1`
- `tests/scripts/claude-hooks/enforce-parallel-worktree-removal-gate.RelativeRecord.Tests.ps1`

### Manifests and documentation to modify

- `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json` (add `AgentTargetWorktree.psm1`)
- `extensions/drm-copilot/resources/codex-and-agents-customizations/pack-manifests/core.json` (add `agent-target-worktree.ps1`)
- Execution-environment brief, `## Hook Execution Context` (and `## Batch Budget` only where it cites prunable behavior), in all six copies: `.claude/skills/execution-environment/SKILL.md`, `.agents/skills/execution-environment/SKILL.md`, `.github/skills/execution-environment/SKILL.md`, `extensions/drm-copilot/resources/claude-customizations/.claude/skills/execution-environment/SKILL.md`, `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/execution-environment/SKILL.md`, `extensions/drm-copilot/resources/customizations/.github/skills/execution-environment/SKILL.md`.
- `.claude/rules/orchestrator-state.md` and `extensions/drm-copilot/resources/claude-customizations/.claude/rules/orchestrator-state.md` (restored-host note directing the operator to run `git worktree repair`).

### Error handling

- An unresolved present identity in a SubagentStop artifact hook blocks with a message naming the reason code (`TARGET_WORKTREE_NOT_DERIVABLE` or `TARGET_WORKTREE_AMBIGUOUS`) and, for a prunable-only registration, the `git worktree repair` remedy. No root is probed.
- A worktree-listing failure in a PreToolUse adopter keeps today's decision for that call.
- No new log channel is added.

### Rollback

- No feature flag (D10). Rollback is a revert of the PR; no data or configuration migration is involved.

## Constraints

- New pushed-down code is PowerShell only. No Python is added, and no changed enforcement hook invokes Python (`tests/scripts/claude-runtime/enforcement-hooks-no-python-invocation.Tests.ps1` stays green).
- Pure logic lives in host-neutral modules with injected seams: worktree-listing invoker (`WorktreeListInvoker`), checkpoint issue reader (`CheckpointIssueReader`), file-existence check (`FolderExistsCheck` and the artifact probe), and transcript reader (`ReadTranscriptHead`). I/O stays in thin adapters: the single default worktree-listing invoker and the hook entry points.
- No temporary files and no wall-clock waits, sleeps, or retries in tests.
- Tests use POSIX-style in-memory roots, forward slashes, exact file-name case, and no gitignored `artifacts/` state, so the Linux hook-suite job passes.
- Test gates are parallel only: one `Invoke-PoshQCParallelTest` run per gate; no serial, single-process, shuffled, or reversed runs.
- Line coverage of at least 85% for each new or changed production PowerShell file, measured from `artifacts/pester/powershell-coverage.xml`. PowerShell has no branch-coverage gate.
- File sizes stay within the tiered policy in `.claude/rules/general-code-change.md`; new logic goes into `AgentTargetWorktree.psm1` and the existing helper so the hooks receive call-site edits only.
- Evidence is append-only under `docs/features/active/2026-11-09-hook-session-root-resolution-1163/evidence/` with UTC write-time stamps; no evidence is back-dated, rewritten, or deleted.
- No absolute paths or host names appear in any artifact, fixture comment, or evidence file.

## Sibling Compatibility

- **#1159 (single hook dispatcher)** starts after this item merges. Every hook changed here stays a standalone hook registered exactly as today. `.claude/settings.json` and `.codex/config.toml` are not edited, and no new hook is registered (the new files are a library module and a Codex helper).
- **#1160 (preimplementation gate false positives)** may share files. This item does not edit the preimplementation gate files, `.claude/lib/worktree-resolution/HookTargetWorktree.psm1`, or `.codex/hooks/hook-target-worktree.ps1`. If #1160 changes `HookTargetWorktree.psm1`, the composition in `AgentTargetWorktree.psm1` still holds because it calls the public function and re-renders porcelain text.
- **#1161 (planner worktree removal)** may share `.claude/lib/worktree-resolution/WorktreeRunRecordPath.psm1` and the removal-gate scripts. The D9 change is confined to the no-live-match branch and call-site argument passing.
- The design works in either merge order. Shared files (`.claude/lib/worktree-resolution/WorktreeRunRecordPath.psm1`, `.claude/lib/worktree-resolution/WorktreeRunResolution.psm1`, the three removal-gate scripts, and the `## Hook Execution Context` section of the execution-environment brief in all six copies) are re-read at execution start, and a text conflict in the brief is resolved by the later merge in all six copies.

## Test Strategy

- Module and twin suites run shared data rows from `AgentTargetWorktree.Rows.Helpers.ps1`, with worktree lists supplied as in-memory porcelain through `WorktreeListInvoker`.
- (a) Coordinator root differs from the agent worktree: a `branch:` prompt resolves the item worktree; no identity with the agent working directory set to the item worktree resolves it with `Source = AgentWorkingDirectory`; no identity with the agent working directory equal to the session root returns the session root.
- (b) Handoff restored on a different host path: a prunable stale record and a live record for the same branch resolve the live root; a prunable-only record returns `TARGET_WORKTREE_NOT_DERIVABLE` naming `git worktree repair`; an issue-only prompt with a `CheckpointIssueReader` keyed by the new root resolves the new root.
- Parity: every row of `Get-HookTargetWorktreeResolverRows` and `Get-HookTargetWorktreeIdentityRows` (`tests/scripts/claude-lib/worktree-resolution/HookTargetWorktree.Rows.Helpers.ps1`) that has no prunable record yields the same `WorktreeRoot`, `ReasonCode`, and `Source` through both resolvers.
- (c) Regression: completion-consistency fail-before and pass-after rows on both surfaces, and SubagentStop fail-closed rows with a `FailIfCalled` probe seam. Existing rows asserting that the session root was probed for an unresolved present identity are updated, with the reason recorded in the test.
- D9 rows in the record-path, run-resolution, and removal-gate suites.
- Gate: one `Invoke-PoshQCParallelTest` run, per-file coverage from `artifacts/pester/powershell-coverage.xml`, and `Invoke-PoshQCLeakScan` clean. Push-down contract tests: `test_push_down_claude_resource_contracts.py`, `test_push_down_codex_and_agents_resource_contracts.py`, `test_push_down_claude_pack_manifest_completeness.py`, `test_push_down_codex_and_agents_pack_manifest_completeness.py`, `test_push_down_pack_manifest_dependency_closure.py`, the `scripts/dev_tools/generate_codex_agent_variants.py --check` run, and `tests/scripts/claude-runtime/hook-dependency-guard-completeness.Tests.ps1`.

## Acceptance Criteria

- [ ] AC-1: `.claude/lib/worktree-resolution/AgentTargetWorktree.psm1` exists and exports `ConvertTo-AgentTargetLiveWorktreeListText` and `Resolve-AgentTargetWorktree`; `Resolve-AgentTargetWorktree` accepts `SessionRoot`, `FilePath`, `CommandOperandPath`, `CommandBranch`, `DelegationPrompt`, `AgentWorkingDirectory`, `Policy` (`SessionFallback`, `FailClosedOnIdentity`), `WorktreeListInvoker`, and `CheckpointIssueReader`, and an AST purity test in `tests/scripts/claude-lib/worktree-resolution/AgentTargetWorktree.Tests.ps1` shows that no process, filesystem, or clock call occurs outside the default `WorktreeListInvoker` body.
- [ ] AC-2: `.codex/hooks/agent-target-worktree.ps1` exists, and `tests/scripts/codex-hooks/agent-target-worktree.Tests.ps1` asserts that its function text is byte-identical to the function text of `AgentTargetWorktree.psm1` and runs the shared rows from `tests/scripts/claude-lib/worktree-resolution/AgentTargetWorktree.Rows.Helpers.ps1`.
- [ ] AC-3: `.claude/lib/worktree-resolution/HookTargetWorktree.psm1` and `.codex/hooks/hook-target-worktree.ps1` are byte-unchanged relative to `main` (verified by `git diff --exit-code main --` on both paths), and `tests/scripts/claude-lib/worktree-resolution/HookTargetWorktree.Tests.ps1` and `tests/scripts/codex-hooks/hook-target-worktree.Tests.ps1` pass unedited.
- [ ] AC-4: Resolver precedence follows D2 (absolute file path, command operand or branch, delegation `branch:` label cross-checked with the canonical issue line, canonical issue line alone, agent working directory, session root), shown by a row per source in which a lower-precedence source is also present and does not decide.
- [ ] AC-5: The coordinator-root row set passes: a `branch:` prompt resolves the item worktree when the session root is the coordinator checkout; no identity with `AgentWorkingDirectory` inside the item worktree resolves it with `Source = AgentWorkingDirectory`; and no identity with `AgentWorkingDirectory` equal to the session root returns the session root.
- [ ] AC-6: The restored-host row set passes: a branch registered once as `prunable` and once live resolves the live root (where `Resolve-HookTargetWorktree` returns `TARGET_WORKTREE_AMBIGUOUS` for the same input); an issue-only prompt with a `CheckpointIssueReader` keyed by the new root resolves the new root; and the result's `StaleRegistration` lists the dropped prunable root.
- [ ] AC-7: Prunable registrations are excluded from branch, issue, and enclosing-root matching, and a branch whose only registration is prunable returns `TARGET_WORKTREE_NOT_DERIVABLE` with a detail that names `git worktree repair`.
- [ ] AC-8: Every row of `Get-HookTargetWorktreeResolverRows` and `Get-HookTargetWorktreeIdentityRows` that contains no prunable record yields the same `WorktreeRoot`, `ReasonCode`, and `Source` through `Resolve-AgentTargetWorktree` as through `Resolve-HookTargetWorktree`.
- [ ] AC-9: `Resolve-SubagentStopTargetWorktree` in `.claude/hooks/subagentstop-target-worktree.ps1` routes through `Resolve-AgentTargetWorktree` with `Policy = FailClosedOnIdentity` and the payload `cwd` as `AgentWorkingDirectory`, and `Resolve-SubagentStopArtifactLocation` accepts an optional `-Target` whose `$null` default reproduces today's result in every existing row of `tests/scripts/claude-hooks/subagentstop-target-worktree.Tests.ps1` that has no unresolved present identity.
- [ ] AC-10: For each of `validate-task-researcher-output.ps1`, `validate-prd-feature-output.ps1`, `validate-required-artifact-output.ps1`, `validate-planner-output.ps1`, `validate-executor-output.ps1`, and `validate-human-exception-runbook-output.ps1`, its `TargetWorktree` suite contains a row in which a present identity resolves to no worktree and a row in which it resolves to several; both block with a message naming the reason code, and the probe seam is a `FailIfCalled` script block that is not invoked.
- [ ] AC-11: For each hook named in AC-10 and for `Resolve-SubagentStopTargetWorktree`, a row with no `branch:` label and no canonical issue line keeps today's session-root fallback decision, and every existing row that asserted a session-root probe for an unresolved present identity is updated with the reason recorded in the test.
- [ ] AC-12: `.claude/hooks/validate-orchestrator-output.ps1` is not modified, and its existing no-identity `ORCHESTRATOR_CHECKPOINT_FALLBACK:` rows in `tests/scripts/claude-hooks/validate-orchestrator-output.TargetWorktree.Tests.ps1` pass unedited.
- [ ] AC-13: In `tests/scripts/claude-hooks/enforce-completion-consistency.TargetWorktree.Tests.ps1`, a completion-asserting Write to an item-worktree checkpoint whose `feature-folder` exists only beneath the item root (injected `FolderExistsCheck` keyed by absolute path) is allowed; the same row is recorded as denied by the unmodified hook (fail-before evidence); and a completion-asserting Write to a session-root checkpoint, a relative `file_path`, and a path in no registered worktree each keep today's decision.
- [ ] AC-14: `tests/scripts/codex-hooks/enforce-completion-consistency-target-worktree.Tests.ps1` carries the same allow, fail-before, and unchanged-decision rows as AC-13 for `.codex/hooks/enforce-completion-consistency.ps1`.
- [ ] AC-15: In `tests/scripts/claude-hooks/enforce-file-size-limit.TargetWorktree.Tests.ps1`, an 801-line Write by absolute path into an agent worktree beneath `.claude/worktrees/` and into a sibling worktree outside the session root are each denied, with fail-before evidence that the unmodified hook allowed them; an 800-line Write to the same paths is allowed; and a relative-path Write keeps today's decision.
- [ ] AC-16: `tests/scripts/codex-hooks/enforce-file-size-limit-target-worktree.Tests.ps1` carries the same deny, allow, fail-before, and unchanged-decision rows as AC-15 for `.codex/hooks/enforce-file-size-limit.ps1`.
- [ ] AC-17: In `tests/scripts/claude-hooks/validate-docs-role-output.TargetWorktree.Tests.ps1`, a docs-role stop whose prompt names an item worktree resolves the `docs-profile`, `docs-snapshot`, and `docs-pages-written` paths beneath that worktree, an unresolved present identity blocks without a probe, and a stop with no identity keeps today's decision.
- [ ] AC-18: In `tests/scripts/claude-hooks/enforce-docs-complete-gate.Tests.ps1`, a merge whose PR `headRefName` is checked out in exactly one non-prunable registered worktree reads the validation receipt beneath that worktree, and zero matches, several matches, and a match only on a prunable registration each read the receipt beneath today's root.
- [ ] AC-19: `Test-WorktreeRunRecordedPathMatchesTarget` in `.claude/lib/worktree-resolution/WorktreeRunRecordPath.psm1` accepts optional `-RecordedBranch`, `-LiveWorktreeRoot`, and `-BranchWorktreeResolver`, and `tests/scripts/claude-lib/worktree-resolution/WorktreeRunRecordPath.Tests.ps1` shows: a rooted record matching no live root with a `branch_name` that resolves to exactly one worktree equal to the target matches; zero or several resolved worktrees do not match; a rooted record matching a live root returns today's result; a relative record returns today's result; and every existing row that omits the new parameters passes unedited.
- [ ] AC-20: `Resolve-WorktreeRunTargetByRecord -RecordField worktree_path` resolves the live worktree whose checkpoint records a stale absolute `worktree_path` and a `branch_name` checked out there (row in `tests/scripts/claude-lib/worktree-resolution/WorktreeRunResolution.Record.Tests.ps1`), and returns `NoTarget` when that branch resolves to zero or several worktrees.
- [ ] AC-21: `.claude/hooks/enforce-epic-worktree-removal-gate.ps1` (with `.claude/hooks/enforce-epic-worktree-removal-gate-resolution.ps1`) and `.claude/hooks/enforce-parallel-worktree-removal-gate.ps1` pass each record's `branch_name` to the comparison; their `RelativeRecord` suites contain a host-moved record row that is allowed through the branch fallback, a row with an unresolvable branch that keeps today's deny, and a row with a live-matching record that keeps today's decision.
- [ ] AC-22: `.claude/lib/cleanup-manifest/CleanupWorktreeManifest.psm1` is not modified and its existing tests pass unedited.
- [ ] AC-23: `Resolve-OrchestratorOutputRunbookPath` returns a rooted `runbook_path` unchanged and a missing runbook file still blocks; no changed code rewrites, normalizes, or persists an absolute path.
- [ ] AC-24: No configuration key is added: `.claude/settings.json` and `.codex/config.toml` are byte-unchanged relative to `main`, every changed hook remains a standalone script registered exactly as today, and no new hook registration exists.
- [ ] AC-25: The only changed gate decisions are those named in D3, D4, D6, D7, D8, and D9, each shown by a fail-before row; every other existing row in the suites of the changed hooks and modules passes, with any edit to an existing row recorded with its reason under AC-11.
- [ ] AC-26: The preimplementation gate files are not modified (`git diff --name-only main` lists no `.claude/hooks/enforce-orchestration-preimplementation-gate` or `.codex/hooks/enforce-orchestration-preimplementation-gate` path).
- [ ] AC-27: Each new or changed production file named in this spec under `.claude/` is byte-identical to its mirror under `extensions/drm-copilot/resources/claude-customizations/`, each new or changed production file under `.codex/` is byte-identical to its mirror under `extensions/drm-copilot/resources/codex-and-agents-customizations/`, `AgentTargetWorktree.psm1` is listed in `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json`, and `agent-target-worktree.ps1` is listed in `extensions/drm-copilot/resources/codex-and-agents-customizations/pack-manifests/core.json`.
- [ ] AC-28: The push-down contract tests `test_push_down_claude_resource_contracts.py`, `test_push_down_codex_and_agents_resource_contracts.py`, `test_push_down_claude_pack_manifest_completeness.py`, `test_push_down_codex_and_agents_pack_manifest_completeness.py`, and `test_push_down_pack_manifest_dependency_closure.py` pass; `scripts/dev_tools/generate_codex_agent_variants.py --check` passes; and `tests/scripts/claude-runtime/hook-dependency-guard-completeness.Tests.ps1` and `tests/scripts/claude-runtime/enforcement-hooks-no-python-invocation.Tests.ps1` pass.
- [ ] AC-29: The `## Hook Execution Context` section of the execution-environment brief describes `Resolve-AgentTargetWorktree` and its precedence, the prunable exclusion and the `git worktree repair` remedy, the SubagentStop fail-closed behavior and unchanged no-identity fallback, the completion-consistency, file-size, docs-role, and docs-complete adoption, the D9 branch fallback, and a corrected statement of which gates resolve by identity; the copies (`.claude/skills/execution-environment/SKILL.md`, `.agents/skills/execution-environment/SKILL.md`, `.github/skills/execution-environment/SKILL.md`, `extensions/drm-copilot/resources/claude-customizations/.claude/skills/execution-environment/SKILL.md`, `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/execution-environment/SKILL.md`, `extensions/drm-copilot/resources/customizations/.github/skills/execution-environment/SKILL.md`) are byte-identical.
- [ ] AC-30: `.claude/rules/orchestrator-state.md` carries the restored-host note directing the operator to run `git worktree repair`, and `extensions/drm-copilot/resources/claude-customizations/.claude/rules/orchestrator-state.md` is byte-identical to it.
- [ ] AC-31: No Python file is added or modified by this item, and no changed hook invokes Python.
- [ ] AC-32: All new and changed tests use in-memory POSIX-style roots, create no temporary files, and contain no sleep, wall-clock wait, or retry; `Invoke-PoshQCLeakScan` reports no leak.
- [ ] AC-33: A single `Invoke-PoshQCParallelTest` run passes with every new and changed suite included, and line coverage in `artifacts/pester/powershell-coverage.xml` is at least 85% for each new or changed production PowerShell file named in this spec; evidence is written append-only under `docs/features/active/2026-11-09-hook-session-root-resolution-1163/evidence/` and contains no absolute path or host name.
- [ ] AC-34 (CI-dependent): CI on the PR head is fully green, including the Linux hook-suite job. This criterion is verified after the PR exists and is checked off at S9 by the item's own orchestrator run.

## Risks and Mitigations

- **Unproven decision changes.** Mitigated by fail-before rows for each changed decision and parity rows for unchanged cases (AC-8, AC-25).
- **Sibling merge conflicts (#1160, #1161).** Mitigated by not editing the preimplementation gate or `HookTargetWorktree.psm1`, by confining D9 to the no-live-match branch, and by re-reading shared files at execution start.
- **Mirror drift.** Mitigated by a dedicated mirror task and the contract tests in AC-28.
- **File size.** `enforce-completion-consistency.ps1` and the larger SubagentStop hooks approach the 500-line guidance tier; logic goes into the module and helper, and physical line counts are checked before and after.
- **CI-only failures.** Mitigated by POSIX-style roots, exact file-name case, and no gitignored state in tests.
- **Branch-changing hooks are not exercised by isolated subagents until merge.** Behavior is proven with Pester evidence; the executor runs in the item worktree whose checkpoint selects the large route.

## Rollout and Follow-up

- Release: ships in the next extension build through the push-down payload; no migration.
- Post-merge: sibling #1159 adopts the changed hooks into the single dispatcher.
- Links: issue #1163; research `docs/features/active/2026-11-09-hook-session-root-resolution-1163/research/2026-11-09-hook-session-root-resolution-research.md`.
