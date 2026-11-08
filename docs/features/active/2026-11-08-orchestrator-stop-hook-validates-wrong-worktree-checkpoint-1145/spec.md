# orchestrator-stop-hook-validates-wrong-worktree-checkpoint (Spec)

- **Issue:** #1145
- **Parent (optional):** none
- **Owner:** drmoisan
- **Last Updated:** 2026-11-08T16-00
- **Status:** Draft
- **Version:** 0.2

## Context
The orchestrator SubagentStop hook validates the wrong checkpoint when the orchestrator worked in a different worktree from the one the hook runs in. It reads `artifacts/orchestration/orchestrator-state.json` from the hook's own working directory (the session root or the subagent's isolation worktree), not from the item worktree the orchestrator actually used, so it blocks or passes based on an unrelated checkpoint.

Environment:
- OS/version: Windows 11 Pro, Claude Code CLI
- Python version: n/a (PowerShell hooks)
- Command/flags used: `/epic-run` on the iar-migration three-layer redesign epic (E1/E2), 2026-11-07/08; also coordinator-launched orchestrators working in `.claude/worktrees/<name>`
- Data source or fixture: orchestrator delegation prompt naming the item worktree and branch; item checkpoint inside that worktree

Impact / Severity:
- [ ] Blocker
- [x] High
- [ ] Medium
- [ ] Low


## Repro & Evidence
Steps to Reproduce:
1. From a coordinator session, launch `Agent(orchestrator)` with a prompt that names an item worktree (for example `.claude/worktrees/<name>`, branch `bug/x`) and work only there.
2. The orchestrator writes and updates the checkpoint in that worktree.
3. The orchestrator stops; `validate-orchestrator-output.ps1` (SubagentStop) runs.

Expected:
The stop hook resolves the target worktree the orchestrator worked in (via `Resolve-HookTargetWorktree`, or a worktree path or branch recorded in the delegation prompt or checkpoint) and validates that worktree's checkpoint.

Actual:
The hook validates the checkpoint in its own cwd (main checkout or isolation worktree): it blocks the orchestrator for errors in an unrelated checkpoint, or passes a stop that should have been blocked.

Logs / Screenshots:
- [ ] Attached minimal logs or screenshot
- Snippet: stop-hook block naming a checkpoint path outside the orchestrator's item worktree.


## Scope & Non-Goals
- In scope: the `orchestrator-state` (item) artifact kind of the orchestrator SubagentStop hook; target-worktree resolution from the delegation prompt in the subagent transcript; the routing-contract, runbook, and feature-folder checks that follow from the resolved root; documentation of the resolution order.
- Out of scope / non-goals: the `epic-orchestrator-state` and `parallel-orchestrator-state` kinds (already target-aware); Codex hooks (no orchestrator checkpoint twin exists); changes to `Resolve-SubagentStopTargetWorktree` or `Resolve-HookTargetWorktree`; changes to `.claude/settings.json`; weakening any gate rule.
- Explicitly excluded systems, integrations, or datasets: live subagent runs (isolated subagents execute `main`'s hook copies, so proof is by Pester only).

## Root Cause Analysis
Hooks run with the session's or subagent's cwd and main's scripts; payload cwd does not identify a coordinator's target item. `Resolve-HookTargetWorktree` exists (PRs #1113/#1120 fixed similar resolution for other hooks) but the orchestrator stop hook does not use it, or the delegation prompt's worktree/branch lines are not consulted. Related, already merged: #1140 and #1143 added `hook-epic-fan-in.ps1` with a scope-object seam; #1142 added nesting-depth checks; #1128 added a runbook stop hook with a TargetWorktree test pattern. Never encode absolute paths in committed artifacts; resolve by branch/issue identity or payload data.

Confirmed by research: for the `item` kind, `Resolve-OrchestratorOutputCheckpointPath` calls `Resolve-WorktreeOperandTarget` with an empty path and the session root, which resolves to the session worktree. The parsed envelope (which carries `agent_transcript_path`) is never consulted, so the delegation prompt is never read. Every downstream check (routing contract, runbook, feature-folder probe) inherits the wrong root.

## Proposed Fix

### Design summary (what changes where):
Add a new dot-sourced sibling, `validate-orchestrator-output-target.ps1`, holding a pure function `Resolve-OrchestratorOutputItemTarget` that wraps the existing `Resolve-SubagentStopTargetWorktree` seam. The main hook gains only the guarded load line, forwarded optional seams, and one call-site change. The item kind resolves its root from the delegation prompt (`branch:` label, canonical issue line); the checkpoint is the canonical path beneath that root.

### Boundaries and invariants to preserve:
- Epic and parallel artifact kinds, block/allow rules, re-entry policy (#903), and the `-CheckpointPath` leaf shape check (still run first) are unchanged.
- A failed resolution never falls back to an unrelated checkpoint.
- Reads stay behind `Get-CheckpointFileContent` and existing module seams.

### Dependencies or blocked work:
- `Resolve-SubagentStopTargetWorktree` (#1105) and `Resolve-HookTargetWorktree`; both exist and need no change.
- PR #1139 also edits `validate-orchestrator-output.ps1`; the minimal-edit design keeps the merge trivial. Rebase on `main` before the final gate.

### Implementation strategy (what changes, not sequencing):

#### Files/modules to change:
- `.claude/hooks/validate-orchestrator-output-target.ps1` (new).
- `.claude/hooks/validate-orchestrator-output.ps1` (minimal edit) and `.claude/hooks/validate-orchestrator-output-resolution.ps1` (item-kind call site).
- Bundle mirrors of all changed or new hooks under `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/`; `pack-manifests/core.json` entry for the new sibling.
- Orchestrate skill and the execution-environment brief `## Hook Execution Context` (six byte-identical copies, including the three bundled copies).
- New tests under `tests/scripts/claude-hooks/`.

#### Functions/classes/CLI commands impacted:
- `Invoke-OrchestratorOutputValidation`, `Get-OrchestratorOutputBlockDecision`, `Resolve-OrchestratorOutputCheckpointPath` (item kind only), new `Resolve-OrchestratorOutputItemTarget`.

#### Data flow and validation changes:
Resolution order for `orchestrator-state`:
1. Call `Resolve-SubagentStopTargetWorktree` with the parsed envelope, no advertised path, and the session root.
2. Resolved from the delegation prompt: use that worktree root for the checkpoint and all downstream checks.
3. No identity (source is the session root, including a resolver exception): use the existing session-worktree resolution and add the fallback note.
4. NoTarget (identity present, no registered worktree): read no checkpoint; return an unresolved result with `TARGET_WORKTREE_NOT_DERIVABLE`.
5. Ambiguous (identity matches more than one worktree): read no checkpoint; unresolved result with `TARGET_WORKTREE_AMBIGUOUS`, non-repairable, blocking once under the unchanged re-entry policy.

#### Error handling and logging updates:
- Unresolved results produce the existing `ORCHESTRATOR_CHECKPOINT_UNRESOLVED: orchestrator-state: <Status> (<ReasonCode>): <detail>` block.
- Fallback note text: no target worktree is identifiable from the delegation prompt (no `branch:` label or canonical issue line); the checkpoint of the session worktree is validated. It is appended to every block message and written to stderr (exit 0) when the stop is allowed.

#### Rollback/feature-flag considerations (if applicable):
None. Revert the change set; the new sibling and the call-site edit are isolated.

### Technical specifications (interfaces/contracts):

#### Inputs/outputs and formats:
- `Invoke-OrchestratorOutputValidation` gains optional `-ReadTranscriptHead` and `-WorktreeListInvoker`, forwarded only when bound (same pattern as `RoutingInvoker`).
- `Resolve-OrchestratorOutputItemTarget` takes the envelope, session root, and seams; returns the worktree root, status, reason code, detail, and a fallback flag.

#### Required configuration keys and defaults:
None. Production defaults use the real transcript reader and `git worktree list`.

#### Backward-compatibility expectations:
Existing tests omit `agent_transcript_path` and resolve through the unchanged session-worktree fallback; they pass unchanged. Hook registration and command line are unchanged.

#### Performance constraints (latency/throughput/memory):
At most one transcript head read (first 50 lines) and one worktree enumeration per stop event.

## Assumptions, Constraints, Dependencies
- Assumptions (environment, data, access): the delegation prompt is the first `user` entry of the subagent transcript and carries a `branch:` label or a canonical issue line.
- Constraints (budget, performance, compatibility): PowerShell only, no new Python; no file near the size guidance tier; no absolute paths in committed artifacts (tests use synthetic roots).
- External dependencies (services, libraries, releases): none; push-down refresh is needed for destinations to receive the hook.

## Data / API / Config Impact
- User-facing or API changes: new block reason path for unresolved item targets; fallback note in hook output.
- Data or migration considerations: none.
- Logging/telemetry updates (if any): stderr fallback note on allow.
- Compatibility notes (CLI flags, config schemas, versioning): no CLI flag or schema change; pack manifest gains one file.

## Test Strategy
Seeded from issue:

- [ ] Unit coverage areas: stop hook resolves the item worktree from the transcript/prompt (`branch:` line, worktree path) or payload; validates that checkpoint; falls back to cwd only when no target is identifiable; never validates an unrelated checkpoint.
- [ ] Integration scenario to retest: coordinator-launched orchestrator working in `.claude/worktrees/<name>` stops with a valid item checkpoint while the session root has a different or invalid one.
- [ ] Manual verification notes: document the resolution order in the orchestrate skill and the hook-context brief; destinations need a push-down refresh.

- Regression tests to add or update: new `validate-orchestrator-output.TargetWorktree.Tests.ps1` (hook level) and `validate-orchestrator-output-target.Tests.ps1` (pure function). Hook-level rows: (1) session checkpoint invalid, item valid -> allow, session path never read; (2) session valid, item invalid -> block naming the item path; (3) no identity -> session worktree plus fallback note; (4) NoTarget -> block, zero reads; (5) Ambiguous -> block, zero reads; (6) issue-line-only prompt via the issue reader; (7) resolver exception -> session worktree with failure note; (8) `StopHookActive` re-entry after Ambiguous allowed once.
- Unit tests (Pester, parallel): the above, using only in-memory seams (`-InputText`, `-ReadTranscriptHead`, `-WorktreeListInvoker`, `Get-CheckpointFileContent` mock) and synthetic `/synthetic-worktrees/...` roots; no temporary files.
- Edge cases and negative scenarios (invalid inputs, missing data, boundary values): missing transcript path, empty prompt, branch with no worktree, conflicting branch and issue identities, resolver exception.
- Error handling and logging verification: assert block text contains `ORCHESTRATOR_CHECKPOINT_UNRESOLVED` and the reason code; assert fallback note in block message and on stderr when allowing.
- Coverage impact and targets for changed lines/modules: >= 90% line coverage on the new sibling; no per-file coverage drop versus the Phase 0 baseline; branch coverage not measured for PowerShell.
- Toolchain commands to run (format → lint → type-check → test): PoshQC format and analyze, `Invoke-PoshQCParallelTest`, `Invoke-PoshQCLeakScan`, contract tests via `pytest -n auto`.
- Manual validation steps (if required): none; fail-before evidence is the new test file run against the unmodified hook, recorded under `evidence/regression-testing/`.


## Acceptance Criteria
- [ ] The orchestrator SubagentStop hook (`validate-orchestrator-output.ps1`) resolves the item worktree through `Resolve-SubagentStopTargetWorktree` (which wraps `Resolve-HookTargetWorktree`) from the delegation prompt in the subagent transcript (`branch:` label, canonical issue line) and validates that worktree's `artifacts/orchestration/orchestrator-state.json`; the routing-contract, runbook, and feature-folder checks use the same root.
- [ ] Hook-level Pester tests fail before and pass after the fix: session root holds an invalid or different checkpoint and the item worktree a valid one -> allow; reverse (session root valid, item invalid) -> block. Fail-before evidence is recorded under `evidence/regression-testing/`.
- [ ] With no identifiable target (no prompt identity), the hook falls back to the session worktree and says so: the fallback note appears in the block message, and on stderr when the stop is allowed.
- [ ] When identity is present but unresolvable (NoTarget) or matches more than one worktree (Ambiguous), the hook blocks with `ORCHESTRATOR_CHECKPOINT_UNRESOLVED` and reads no checkpoint; it never validates an unrelated checkpoint.
- [ ] Gate intent is unchanged: every existing validate-orchestrator-output test passes unchanged, and the epic and parallel artifact kinds behave as before.
- [ ] The new logic lives in a separate dot-sourced sibling (`validate-orchestrator-output-target.ps1`) with a minimal edit to the main hook; the bundle mirror under `extensions/drm-copilot/resources` and the pack manifest are updated; the push-down contract tests pass.
- [ ] The orchestrate skill and the execution-environment brief `## Hook Execution Context` are updated in all copies, and the six brief copies remain byte-identical.
- [ ] No new Python is introduced (PowerShell only); line coverage of the new file is >= 90%; no per-file coverage drop versus the Phase 0 baseline; the parallel Pester gate (`Invoke-PoshQCParallelTest`) and `pytest -n auto` are green.
- [ ] No absolute paths are encoded in committed artifacts.

## Risks & Mitigations
- Technical or operational risks: merge conflict with PR #1139 on the main hook; unlisted sibling breaking mirror, manifest, or dependency-closure tests; coverage gaps in fallback and failure branches; test-state leakage across parallel shards; Linux-only CI failures from drive-letter roots.
- Mitigations and rollbacks: keep the main-file diff to roughly ten lines and rebase on `main` before the final gate; copy changed files byte-identically and add the manifest entry in the same change; use the eight-row matrix plus a pure-function test file; reuse the epic-state baseline mock helpers and run the leak scan; use forward-slash synthetic roots and pass `-SessionRoot` explicitly. Rollback is a revert of the change set.

## Rollout & Follow-up
- Release/rollout steps: merge, then push-down refresh so destinations receive the hook and the updated brief.
- Post-fix monitoring or clean-up tasks: watch for `ORCHESTRATOR_CHECKPOINT_UNRESOLVED` blocks in coordinator runs and for fallback notes indicating prompts that lack identity lines.
- Links: issue #1145; related PRs #1105, #1113, #1120, #1128, #1137, #1139, #1140, #1142, #1143; research under `research/` in this folder.
