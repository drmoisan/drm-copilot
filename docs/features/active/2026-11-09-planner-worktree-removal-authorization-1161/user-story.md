# `2026-11-09-planner-worktree-removal-authorization` — User Story

- Issue: #1161
- Owner: drmoisan
- Status: Approved for planning
- Last Updated: 2026-11-09T21-50

## Story Statement

- As an epic-planner operator, I want the planner to record each preparation worktree it uses and the removal gates to allow removing a recorded worktree once its preparation is committed, pushed, and clean, so that I can free the preparation branch without detaching HEAD or using `--force`.
- As a gate maintainer, I want the new allow branch to be a pure, byte-identical helper behind thin adapters, inert unless a planner record names the target, and documented in each gate, so that existing deny behavior, file-size caps, and Claude and Codex parity are preserved.

## Problem / Why

The worktree-removal gates authorize removal only from epic-orchestrator, parallel-orchestrator, or cleanup-manifest records. The epic planner's preparation worktrees appear in none of them, so the planner's fan-in removal step is always denied, and detaching HEAD has been the only way to free the branch. That workaround bypasses the intent of the gates and leaves no audit record.

## Personas & Scenarios

- Persona: Epic-planner operator
  - The `epic-planner` agent on Claude or Codex, and the human who supervises the epic.
  - Cares about completing fan-in without manual git workarounds and without losing unpushed work.
  - Constrained by conjunctive PreToolUse gates that cannot be bypassed and by the rule that no absolute host path is recorded.
  - Goal: remove each fanned-in preparation worktree with a plain `git worktree remove`.
  - Frustration: the current deny offers no sanctioned path, and detaching HEAD hides the state of the branch.
- Persona: Gate maintainer
  - Maintains `.claude/hooks/enforce-epic-worktree-removal-gate.ps1`, `.claude/hooks/enforce-parallel-worktree-removal-gate.ps1`, and `.codex/hooks/enforce-epic-worktree-removal-gate.ps1`.
  - Cares about byte-stable deny text, deterministic tests, the 500-line cap on the Claude gates, and bundle parity.
  - Goal: add the branch with one guarded dot-source and one call per gate and full test coverage of each refusal.
- Scenario: Fan-in removal of a prepared worktree
  - The planner launches a preparation child; the child switches its isolation worktree to `feature/<short-name>-<issue>`.
  - On completion, the planner appends a `planner_worktrees` entry with that branch, `purpose: preparation`, `preparation_status: prepared`, and the feature folder.
  - The planner merges the branch into the integration branch, pushes, and sets `fanned_in`.
  - The planner issues `git worktree remove` for that worktree in its own Bash call. All gates allow because the record is eligible, the worktree is unlocked, clean, and not otherwise in use, and its `HEAD` is on the integration remote-tracking ref.
  - The planner sets `removed`.
- Scenario: Refused removal
  - The planner attempts removal while the worktree has an untracked file. The gates deny and append `Planner worktree: PLANNER_WORKTREE_DIRTY: <detail>.`
  - The planner records the code, leaves the worktree in place, and does not detach HEAD or use `--force`.

## Acceptance Criteria

Epic-planner operator story:

- [x] The epic-planner checkpoint accepts a `planner_worktrees` list whose entries carry `branch`, optional repository-relative `path`, `purpose`, `preparation_status`, `feature_folder`, and optional `recorded_at`, and both the Python and TypeScript validators accept a well-formed list and reject malformed entries with the byte-identical strings defined in `spec.md`.
- [x] `.claude/skills/epic-plan/SKILL.md` and `.agents/skills/epic-plan/SKILL.md` instruct the planner to record each preparation worktree by branch, update its status through `prepared`, `fanned_in`, and `removed`, remove it with a plain `git worktree remove` without `--force`, and never detach HEAD to free a branch.
- [x] `.claude/agents/epic-planner.md` and `.codex/agents/epic-planner.toml` list `planner_worktrees` in their checkpoint key lists.
- [x] A recorded, eligible (`prepared` or `fanned_in`), clean, pushed, not-in-use preparation worktree is allowed by each of the three removal gates.
- [x] A dirty recorded worktree is denied with `PLANNER_WORKTREE_DIRTY`, including when the command carries `--force`.
- [x] A recorded worktree that is in use is denied with `PLANNER_WORKTREE_IN_USE`, with a detail beginning with the condition identifier, for each of U1 (session root or planner-checkpoint root), U2 (main checkout), U3 (git-locked worktree), U4 (preparation checkpoint unparseable or not at `S5_atomic_execution`), and U5 (adopted by an epic-orchestrator checkpoint).
- [x] A recorded worktree whose `HEAD` is on neither remote-tracking ref is denied with `PLANNER_WORKTREE_NOT_PUSHED`; an ineligible record is denied with `PLANNER_WORKTREE_NOT_ELIGIBLE`; an ambiguous record is denied with `PLANNER_WORKTREE_AMBIGUOUS`; a git failure is denied with `PLANNER_WORKTREE_GIT_FAILED`.
- [ ] No recorded value, fixture, or evidence file carries an absolute host path; the validators reject a `path` with a drive, a leading slash, a backslash, a `:`, or a dot segment.

Gate maintainer story:

- [x] An unrecorded worktree is denied with text byte-identical to the pre-change text on all three gates.
- [x] The pure helper `.claude/hooks/hook-planner-worktree-removal.ps1` is byte-identical to `.codex/hooks/hook-planner-worktree-removal.ps1`, performs no I/O, and is pinned in `tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1`; I/O is confined to `.claude/hooks/enforce-worktree-removal-gate-planner.ps1` and the Codex adapter functions through injected seams.
- [x] The `.DESCRIPTION` block of each removal gate documents the planner branch, its cascade position, the refusal codes, and the honest disclosure that the branch is a policy-level control.
- [x] Every existing gate suite passes unchanged, both Claude gates and `.claude/hooks/enforce-epic-worktree-removal-gate-resolution.ps1` stay at or below 500 lines, and `Invoke-PoshQCLeakScan` passes.
- [x] Bundle mirrors are byte-identical, both pack manifests list the new hook files, the push-down contract tests and `scripts/dev_tools/generate_codex_agent_variants.py --check` pass, and `.claude/skills/epic-orchestrate/SKILL.md` and `.claude/agents/epic-orchestrator.md` are unchanged.
- [ ] New PowerShell files reach at least 85% line coverage; the new TypeScript module reaches at least 85% line and 75% branch coverage with its own `coverageThreshold` entry; changed Python lines reach at least 85% line and 75% branch coverage.
- [ ] Gate, Python, and TypeScript test evidence comes from parallel runs only, and new tests use no temporary files, no wall-clock waits, and no live git process.

## Non-Goals

- Extending the parallel planner or adding a hook allow for parallel-planner scratch worktrees (D13).
- Changing the absolute `features[].worktree_path` requirement of the Codex launch binding (D17); it is a pre-existing deviation outside removal authorization.
- Adding a configuration knob (D14), a PowerShell validator for the epic-planner checkpoint, or any change to hook registrations.
