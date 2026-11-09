# `regenerate-after-integration-merge` — User Story

- Issue: #1156
- Owner: drmoisan
- Status: Draft
- Last Updated: 2026-11-09T21-35

## Story Statement

- As the epic orchestrator operator, I want a merge whose only overlapping changes are declared generated files to be resolved by re-running the repository's regeneration command, so that each feature does not spend a full remediation cycle (planner, preflight, execution, re-review, CI) and a remediation attempt on regenerating artifacts.
- As the epic orchestrator operator, I want the integration branch regenerated and CI-verified after each feature merges, so that the next feature syncs onto a tip whose generated files are current and whose CI is green.
- As the repository owner, I want the regenerate path to be opt-in, verified, and recorded, so that a repository without a declaration behaves exactly as today and a merge gate can confirm that every regenerate-path merge was confined, idempotent, unit-gated, and delta-checked.

## Problem / Why

Features in one epic often touch the same generated or derived files (counts, inventories, generated code). Each time one feature merges into the integration branch, the others go stale and their next sync conflicts. Today every such conflict becomes a synthetic Blocking finding that runs the full R1-R5 remediation loop and counts toward the three-attempt limit, even when the only work is regenerating outputs on the merged tree. In practice this added a cycle of one to two hours per feature per merge and pushed features toward the attempt limit.

## Personas & Scenarios

- Persona: epic orchestrator operator
  - Runs epics whose features are executed by child orchestrator runs in parallel waves.
  - Cares about elapsed time per wave and about features halting at the remediation limit for reasons unrelated to their code.
  - Constrained by the existing merge gates, the preimplementation gate on the integration branch, and the CI-green merge rule, which must not be weakened.
  - Frustrated when a mechanical regeneration costs a full remediation cycle.
- Persona: repository owner
  - Decides whether a repository declares a regeneration command and which paths it may write.
  - Cares that controls are auditable, that defaults do not change behavior, and that disclosures state what the controls do not prove.

- Scenario: generated-file conflict on fan-in
  - Feature A merges into the integration branch and changes a generated inventory file that feature B also changed.
  - Feature B's child orchestrator merges the integration branch and the merge conflicts.
  - Because the repository declares a regeneration config, the child invokes the regeneration entry point. Every path both sides changed matches a declared pattern, so the classifier returns `regenerate`.
  - The entry point runs the command twice, confirms the output stays inside the declared patterns and the second run changes nothing, confirms every non-generated path equals one already-reviewed parent, and runs the unit gate.
  - The child commits the merge, pushes, records a regeneration event and a delta review outcome at the new head, and re-runs CI. `completed_attempts` is unchanged.
- Scenario: mixed conflict
  - The same merge also conflicts on a hand-written source file outside the declared patterns.
  - The classifier returns `remediation_loop` with reason `unmatched_path` naming that file. The child records a `fell_back` event and runs today's remediation loop, which consumes one attempt as today.
- Scenario: integration tip after a feature merge
  - After feature A's pull request merges into the integration branch, the epic orchestrator runs the regeneration command on the integration tip, commits any diff through the narrow preimplementation allowance, dispatches CI on the integration branch, and waits for a successful run before merging another child or launching another wave.
  - Feature B, about to sync, first confirms the integration tip has a successful CI run.
- Scenario: repository without a declaration
  - This repository, and any destination that has not authored `config/orchestration-regeneration.json`, sees no new git call, no new wait, and no new deny; every conflict follows today's procedure.

## Acceptance Criteria

- [ ] (issue AC1) A repository opts in by committing `config/orchestration-regeneration.json` with `command`, `paths`, and the optional `idempotency_check` and `unit_gate`; an absent file, absent `regeneration` key, or `null` value yields today's behavior, an invalid file yields a `config_invalid` fallback with its errors recorded, and the keys and rules are documented in the orchestrate skill and the rules file.
- [ ] (issue AC2) The operator can rely on a pure classifier that returns `regenerate` only when the config is valid, there is exactly one merge base, the both-sides-changed set is non-empty, and every path in it matches a declared pattern; otherwise it returns `remediation_loop` with one of `no_config`, `config_invalid`, `multiple_merge_bases`, `empty_set`, or `unmatched_path`, covered by unit tests for all-match, partial-match, no config, and empty set.
- [ ] (issue AC3) On the regenerate path the command runs on the merged tree, its output is confined to the declared patterns, a second run leaves no diff, the delta check passes, the local unit gate passes, CI re-runs on the pushed head, and a `regeneration_delta` review outcome and a new evidence file are recorded; any failure aborts the merge and falls back to today's procedure.
- [ ] (issue AC4) A regenerate attempt, whether it succeeds or falls back, writes no remediation cycle and leaves `completed_attempts` unchanged, and the three-attempt limit is otherwise unchanged.
- [ ] (issue AC5) When the integration worktree declares regeneration, the epic orchestrator regenerates the integration tip after each feature merge, commits any diff, dispatches and verifies CI, and does not merge another child or launch another wave until that CI run succeeds; a child with a declaration confirms the tip's successful CI before syncing.
- [ ] (issue AC6) The orchestrate, epic-orchestrate, and parallel-orchestrate skills, the orchestrator and epic-orchestrator agents, the rules file, the checkpoint fixtures, and the merge gates accept the regenerate path's evidence, and a merge gate denies with `REVIEW_GATE_REGENERATION_UNVERIFIED` when a `regeneration_delta` outcome lacks a matching verified event.
- [ ] (issue AC7) For checkpoints without the new keys, the CI-green merge rule, epic-child CI verification, the concurrent review guard, the fan-in and merged-feature follow-up allowances, and the three-attempt limit produce the same decisions as before, shown by regression tests.
- [ ] Codex orchestrators keep today's behavior, the new controls are documented as policy-level controls rather than security controls, and this repository does not declare its own regeneration config in this item.

## Non-Goals

- Declaring a regeneration command for this repository (D11).
- Running the regenerate path in Codex orchestrators or editing `.agents/skills/orchestrate/SKILL.md` or `.agents/skills/epic-orchestrate/SKILL.md`.
- Changing `remediation_path` values, the R7 invariant, or any checkpoint validator code.
- Regenerating on merges that do not conflict, or resolving conflicts in non-generated files without the remediation loop.
- Relaxing any existing merge-gate decision or the CI-green merge rule.
