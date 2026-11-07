# `reduce-feature-cycle-time-with-revertible-ledger` — User Story

- Issue: #1097
- Owner: drmoisan
- Status: Draft
- Last Updated: 2026-11-06T21-23

## Story Statement

- As the repository owner, I want feature delivery to carry less process weight, so that a feature no longer takes 3 to 4 hours of agent time or more.
- As the repository owner, I want every reduction recorded with its prior text, revert steps, and revert signals, so that I can restore any one of them months from now if agents stop behaving well.
- As the repository owner, I want stage timing recorded, so that I can judge each reduction on measured time.
- As an orchestrator agent, I want review and CI to run at the same time, with a guard at merge, so that neither waits on the other and neither can be skipped.
- As a reviewer agent, I want a light remediation path with an explicit threshold, so that a small contained fix does not cost a full plan and preflight.

## Problem / Why

Measurements on Epic #1019 show plans of 37 to 57 tasks and finished items with 26 to 69 evidence files. Most commits on the two measured items are docs-only, and 4 of the 7 merged epic features needed a remediation cycle. Agent time per stage is not recorded, so the saving from any single change is unknown.

The owner approved reductions on one condition: each must be easy to revert, possibly several months later. Baseline capture is not reduced, because the owner considers it critical for testing.

## Personas & Scenarios

- Persona: Repository owner
  - Runs features and epics through agents, and reviews the outcome rather than each step.
  - Cares about elapsed time, trustworthy results, and the ability to undo a process change.
  - Is constrained by in-flight Epic #1019 work, which merged hook changes reach directly.
  - Is frustrated by long runs and by evidence files that repeat what CI already shows.
- Persona: Orchestrator and reviewer agents
  - Follow skills, hooks, and validators as written.
  - Need a checkpoint that records what happened truthfully and still validates.
- Scenario: Reverting a reduction months later
  - The owner sees a revert signal, such as more remediation cycles after a reduction.
  - The owner opens the entry in `docs/engineering/process-reductions/`.
  - The entry's revert steps restore the prior text, mirrors, pinned hashes, and contract-test literals, without `git revert`.
  - The contract tests pass, and the prior behavior is back.
- Scenario: A small review finding
  - A review reports two contained `autonomous` findings and writes `Remediation-Path: light`.
  - The orchestrator writes the mode line and sends the fix directly to execution, with no plan or preflight.
  - If the executor finds the fix is not small, it stops before the first checked task and the cycle moves to the design chain.
  - Re-review follows, and the checkpoint validates truthfully with no preflight record.
- Scenario: Review and CI together
  - The single local parallel run passes, and the orchestrator opens the PR.
  - Review and CI run at the same time.
  - The orchestrator compares the reviewer's claimed results with CI at the join.
  - A code push after the review makes the review stale, and the guard denies merge until a new review passes.

## Acceptance Criteria

The tag on each criterion names the delivery stage that owes it, as defined in `spec.md`, `## Delivery Stages`. A PR owes only criteria tagged with its stage and earlier ones, and the final stage owes all. These criteria match those in `spec.md`.

- [x] [A] `docs/engineering/process-reductions/` exists with a `README.md` index, and a test fails when the index and the entries disagree.
- [x] [A] A test fails if a ledger entry lacks a required section, covering a complete entry, a missing section, an empty section, and missing prior text, and it also iterates the real entries read-only.
- [x] [A] The structure test accepts a pending merge commit only in the exact form `Merge commit: pending (PR #N)`.
- [x] [A] `Invoke-ProcessReductionRevert` restores `Prior` text in memory, normalizes line endings before comparing, and throws when `Current` is absent.
- [x] [A] The review skill and all its mirrored copies state the standing rule, conditional on the ledger folder existing, and state that one-off waivers are not entries.
- [x] [A] `Invoke-PoshQCParallelTest` and `pytest -n auto` pass with zero failures, under the Testing Rule, at each stage.
- [x] [B] Stage timing is recorded in the checkpoint and in committed evidence, and is reported per stage by `Get-StageTimingReport.ps1`, which labels figures as wall-clock and states that the merge stage is not captured.
- [x] [B] A test proves that `stage_timing` passes each validator and survives portable handoff.
- [x] [C] The merge guard commit precedes the readiness relaxation commit on the branch.
- [x] [C] Under `review_mode: "concurrent"`, merge is denied with review passed and CI pending, and with CI green and review pending, on each guarded path. On the authorization path, which reads no CI result, the required `CI Required Gate` context is the control, and the spec limit in D10 applies.
- [x] [C] The guard denies a stale head after a code change, including a merge of `origin/main`; a git failure; an unresolved head; and a bare command under the key. It allows a predecessor head whose later changes are only feature-folder paths.
- [x] [C] The Claude guard and its Codex twin behave the same on these cases.
- [x] [C] A test proves that a checkpoint without the key makes no `gh` call, receives no new denial, and receives no readiness relaxation.
- [x] [C] `step7_status: pending` stops blocking PR readiness only under the key, and `require_complete` under the key requires the same `PASS` record in the Python, TypeScript, and PowerShell validators.
- [x] [C] The orchestrate skill defaults new runs to concurrent and requires a `CI full run` at the join, the parallel merge-on-green step does not record `ci_green` while the child's review is unresolved, and the concurrent reduction lands as its own commit with its entry.
- [x] [D] A light remediation cycle validates truthfully in the Python, TypeScript, and PowerShell validators with byte-identical strings, and all three land in one commit.
- [x] [D] A cycle with a design-level finding or no `scope` fails on the light path and still requires the full chain, and a full-path cycle with no preflight fails invariant 2.
- [x] [D] Invariant 8 also rejects a light cycle with findings above the threshold, a consecutive light cycle, and a light cycle carrying a `preflight` object.
- [x] [D] The reviewer's `Remediation-Path` choice can be moved only heavier, the skills state the threshold and the Python CLI route of D9, and the light reduction lands as its own commit with its entry.
- [x] [E] An entry for #1094, the parallel-only test gates, exists with the prior text from its pre-merge state.
- [x] [E] The planning skill and all its mirrored copies state the standing rule.
- [x] [E] The smaller-plans text states the design-level target of 15 to 20 tasks and lands as its own commit with its entry.
- [ ] [E] The policy-read task, its artifact requirement, and the hook's policy-read check are removed in one commit with its entry; a plan that keeps the task stays valid; and every baseline requirement string named in research section 3 is present before and after.
- [x] [E] Applying one entry's revert steps to a test copy restores the prior behavior for at least one sample reduction: in memory, the reverted `Get-PlanStructureValidationReport` returns the policy-read error and the live function does not.
- [x] [E] Wording deferred from stages A to D has landed, with each affected ledger entry updated in the same commit.
- [ ] [F] G13 reports at the new guideline of 20 tasks and 250 physical lines in both validators, with parity, at the guideline and one above it, with and without a justification.
- [ ] [F] Parity tests run both sides of `PLAN_GUIDELINE_CUTOFF` and the no-path case, cover each stamp shape in K4, and prove that a plan with absent repository wiring keeps its stamp result.
- [ ] [F] The finding message states the guideline that applied, the rule file's scope section describes the cutoff, and G13 lands as its own commit with its entry.
- [ ] [G] The evidence requirements marked Reduce in research section 4 are removed from the skills and templates, and those marked Keep remain.
- [ ] [G] The reviewer writes `## CI Cross-check`, and a mismatch at the join becomes a synthetic Blocking finding that blocks merge, as in K7.
- [ ] [G] The less-evidence reduction lands as its own commit with its entry.
- [ ] [H] The named design-check pass is in single-pass preflight, adds no delegation, and is pinned by a contract test.
- [ ] [H] All 6 copies of the atomic-plan-contract skill describe the new rules, and contract tests pin them.
- [ ] [I] Layer 1 and layer 2 honor `early_start` only for the named dependency; a dependent at `pr_open` or later requires the dependency merged and a string `synced_at`; and without the key both layers are unchanged.
- [ ] [I] Frozen hashes are re-baselined in the same commit, and the reduction lands as its own commit with its entry.
- [ ] [I] The ledger holds an entry for every reduction made, including #1094; every entry carries the prior text or a patch, revert steps, and revert signals; and the reviewer confirms from the branch log that each reduction is a separate commit.
- [ ] [I] The planning, execution, and review skills, and all mirrored copies, describe the new rules, and contract tests pin them.
- [ ] [I] No baseline task, evidence, or comparison requirement is removed.
- [ ] [I] Older checkpoints and plans still validate: existing fixtures pass unchanged, and no Epic #1019 feature folder or admitted plan is edited.
- [ ] [I] Merge is still impossible without a passing review and green CI, within the limit stated in D10.

## Non-Goals

- Reducing any baseline task, baseline evidence, or baseline comparison.
- Changing the GitHub ruleset, or requiring approvals there.
- Installing an extension release or pushing git tags.
- Editing Epic #1019 feature folders, or any plan already admitted to a run.
- Changing merge behavior for a sequential run.
- Adding a separate design-review agent or delegation.
- Reducing isolation runs under this item. #1094 owns them, and this item only back-fills its ledger entry.
- Recording one-off waivers for a single item in the ledger.
