# `2026-09-17-agent-payload-gates-resolve-session-root` — User Story

- Issue: #690
- Owner: drmoisan
- Status: Draft
- Last Updated: 2026-09-29T22-15
- Work Mode: `full-bug`
- Spec: `docs/features/active/2026-09-17-agent-payload-gates-resolve-session-root-690/spec.md`
- Research: `docs/features/active/2026-09-17-agent-payload-gates-resolve-session-root-690/research/2026-09-29T21-55-agent-payload-gates-session-root-research.md`

## Story Statement

- As an epic coordinator launched from a session whose root is not the epic worktree, I want the
  preimplementation gate and the epic wave barrier to evaluate my kickoff against the epic checkpoint
  in the worktree that owns the run, so that a ready epic is admitted and an epic with no checkpoint
  anywhere is denied with a reason I can act on.
- As a coordinating session that edits or delegates into another item's worktree, I want each gate
  to read that worktree's checkpoint, so that governed tools work for cross-worktree work and I am not
  pushed onto ungoverned paths.
- As a parallel or epic coordinator merging PRs and removing worktrees, I want the merge and removal
  gates to find the run checkpoint that records the PR number or worktree path I name, so that a
  correct merge or removal is not denied because the checkpoint sits elsewhere.
- As a maintainer of these hooks, I want an unidentifiable or ambiguous target to deny with
  `TARGET_WORKTREE_NOT_DERIVABLE` or `TARGET_WORKTREE_AMBIGUOUS`, and a failed import of the new
  resolution module to deny rather than pass, so that the change cannot introduce a false approval.
- As a user working in a single worktree, I want every gate decision to stay exactly as it is today.

## Problem / Why

The gates read their checkpoints through paths relative to the hook process directory, which is the
invoking session's root. When the checkpoint that governs a call lives in another worktree, the gate
either denies a correct call or evaluates the call against whatever checkpoint occupies the session
root.

Two observed cases:

- 2026-09-17/18 (#688): a coordinating session's `Agent(powershell-typed-engineer)` delegation and
  its `Write`/`Edit` calls into the target worktree were denied with `PREIMPLEMENTATION_GATE_BLOCKED`,
  although a validator-passing checkpoint existed there. The work was completed through the
  PowerShell tool, which the gate does not govern. The gate did not prevent the work; it only removed
  the governed path.
- 2026-09-29: an epic run launched from this worktree's session was denied at the preimplementation
  gate with `checkpoint-absent`, because the epic checkpoint was in the epic worktree
  (`2026-09-29T14-15-epic-770`). The wave barrier reads the same relative path and would have denied
  the same call.

The false-approval direction is the more serious one: a stale checkpoint copy at the session root can
satisfy a gate for a run it does not belong to. A copy of the epic-770 checkpoint was observed at this
worktree's root on 2026-09-29, which is why the design rejects any session-root-first shortcut.

## Personas & Scenarios

### Persona 1 — the epic coordinator

- **Who it is.** The `epic-orchestrator` agent, running as a forked skill (`/epic-run`) in the
  invoking session's process. Its hooks run with the session root as their directory.
- **What it cares about.** Launching each wave's child orchestrators when the epic checkpoint says
  they are ready, and nothing else.
- **Its constraints.** It is forbidden to check out the integration branch in the coordinating
  session. Its kickoff line carries `integration_branch:` and `epic_feature_folder:`, but no canonical
  issue-number line and no `branch:` label.
- **Its frustration today.** The run stops at the first kickoff whenever the epic checkpoint is not at
  the session root, with a message that names a relative path the operator cannot fix from the
  session.

### Persona 2 — the cross-worktree implementer

- **Who it is.** An orchestrator or operator session that edits files in, or delegates typed-engineer
  work into, an item worktree other than its own root.
- **What it cares about.** Using the governed tools (`Write`, `Edit`, `Agent`) so the work is checked.
- **Its constraints.** It cannot change the hook process directory per call.
- **Its frustration today.** Correct calls are denied, so it falls back to tools the gate does not
  govern.

### Persona 3 — the hook maintainer

- **Who it is.** The engineer or executor agent implementing and later maintaining these gates.
- **What it cares about.** Fail-closed behaviour, one resolution rule shared by every gate, and a
  rollout that does not lock the implementing session out or open a fail-open window.
- **Its constraints.** The hooks are live in the worktree doing the work; several files are near the
  500-line cap; tests may not use temporary files.

### Scenario A — epic kickoff from a non-epic session root (the reproduction)

1. `W_epic` has `epic/repro-integration` checked out and holds a ready
   `artifacts/orchestration/epic-orchestrator-state.json` with that `integration_branch`.
2. The operator runs `/epic-run` from `W_session`, which holds no epic checkpoint.
3. `epic-orchestrator` issues `Agent(orchestrator)` with
   `Epic mode: true. epic_feature_folder: repro. integration_branch: epic/repro-integration. ...`.
4. The preimplementation gate reads `integration_branch:` from the prompt and calls
   `Resolve-WorktreeEpicTarget`. The only live worktree whose epic checkpoint matches is `W_epic`, so
   the result is `OtherWorktree` at `W_epic`.
5. The gate reads the checkpoint beneath `W_epic` and applies the existing readiness predicate. The
   wave barrier does the same. The delegation is admitted.
6. **Obstacle variant.** If no live worktree holds a matching epic checkpoint, both gates deny with
   `TARGET_WORKTREE_NOT_DERIVABLE` behind their own tokens.
7. **Obstacle variant.** If both `W_session` and `W_epic` hold matching copies, the resolver keeps
   the one with the integration branch checked out (`W_epic`). If that does not narrow to one, the
   gates deny with `TARGET_WORKTREE_AMBIGUOUS`, and the message names moving the stale copy to
   `artifacts/orchestration/handoff/` as the remedy.

### Scenario B — coordinator edits a file in another item's worktree

1. A session rooted at `W_session` issues `Edit` on an absolute path inside `W_item`.
2. The preimplementation gate places the path by ascent, finds `W_item`, and reads
   `W_item/artifacts/orchestration/orchestrator-state.json`.
3. The edit is allowed when that checkpoint is ready and denied when it is absent or not ready. The
   checkpoint at `W_session` is not consulted.

### Scenario C — typed-engineer delegation carries its identity

1. The orchestrator delegates `Agent(powershell-typed-engineer)` for item #N. Per the extended
   `## Issue Number Consistency` contract, the prompt carries the canonical issue-number line and a
   `branch:` label.
2. The preimplementation gate resolves the item with `Resolve-WorktreeItemTarget` and reads that
   item's checkpoint, wherever the item's worktree is.
3. **Obstacle variant.** A prompt without either line resolves `NoTarget` and is denied with
   `TARGET_WORKTREE_NOT_DERIVABLE`. This is the one intended behaviour change for callers that do not
   follow the contract, and the skill text is updated so documented callers are not affected.

### Scenario D — coordinator merges and removes by PR number and path

1. A parallel coordinator at `W_session` runs `gh pr merge --merge 812`. The parallel checkpoint that
   records item PR 812 is in a different live worktree.
2. The merge gate calls `Resolve-WorktreeRunTargetByRecord -Kind parallel -RecordField pr_number
   -Value 812`, finds that worktree, and applies its existing parallel-branch checks there.
3. Later, `git worktree remove <path>` resolves the run checkpoint that records `<path>` under
   `items[].worktree_path` in the same way.
4. A bare `gh pr merge --merge` with no number is still evaluated at the session root, because it
   targets the current branch's PR.

### Scenario E — single worktree, nothing changes

1. An engineer works in one worktree that holds the item's ready checkpoint.
2. Every edit, command, and delegation resolves `SessionRoot`, and each gate reads the same file it
   reads today.
3. Decisions are unchanged.

### Scenario F — rolling the change out from a live session

1. The executor lands `WorktreeRunResolution.psm1` first, with its tests, mirror, and manifest entry.
   No hook imports it, so live behaviour is unchanged.
2. It then rewrites one gate at a time, each in a single complete `Write`, and runs that gate's
   Pester suites before moving on, recording each step under `evidence/qa-gates/`.
3. If a converted gate fails to import the new module, it denies with a message naming the module
   instead of exiting non-zero and being treated as non-blocking.

## Acceptance Criteria

This feature uses work mode `full-bug`. The authoritative, checkbox-tracked acceptance criteria are in
`spec.md` under `## Acceptance Criteria`; they are not duplicated here, so that each criterion is
checked off in one place only. The scenarios above map to the spec sections as follows:

- Scenario A: "Reproduction", "Run-resolution module", "Preimplementation gate", "Epic wave barrier
  and parallel cohort barrier".
- Scenario B: "Preimplementation gate" (path and command legs).
- Scenario C: "Preimplementation gate" (Agent leg) and "Identity contract (documented callers)".
- Scenario D: "Merge gate" and "Worktree-removal gates".
- Scenario E: "Plain single-worktree regression guards".
- Scenario F: "Rollout safety" and "Import failure (fail-closed)".

## Non-Goals

- `validate-orchestrator-output.ps1` (SubagentStop) remains session-relative; recorded as a
  follow-up.
- No change to `.codex/hooks/**` or the Codex bundle (issue #736).
- No change to the wave barrier's feature-folder selection (issue #565).
- No edit to `WorktreeResolution.psm1` or `enforce-orchestration-preimplementation-gate-helpers.ps1`.
- No fail-closed hardening of pre-existing imports and dot-sources, or of hooks this change does not
  convert; recorded as a follow-up.
- No use of the payload `cwd`, a feature-folder path, or a prompt-declared checkpoint path to select
  a worktree.
- No Python, no git subprocess, no temporary files in tests.
