# reduce-feature-cycle-time-with-revertible-ledger — Spec

- **Issue:** #1097
- **Parent (optional):** none
- **Owner:** drmoisan
- **Last Updated:** 2026-11-06T21-23
- **Status:** Draft
- **Version:** 0.1

## Overview

A feature takes 3 to 4 hours of agent time or more. This item reduces plan size, evidence volume, remediation weight, and the wait between review and CI, and it records every reduction in a ledger so that each one can be reverted months later without `git revert`.

- Requirements: `docs/features/potential/promoted/2026-11-06-reduce-feature-cycle-time-with-revertible-ledger.md`.
- File inventories, measurements, and rejected alternatives: `research/research.2026-11-06.md`. This spec references that record and does not repeat it.
- Target users: the owner, who judges and reverts reductions, and the orchestrator, planner, executor, and reviewer agents that follow the new rules.
- Expected impact: fewer tasks per plan, fewer evidence files per item, fewer delegations per remediation cycle, and review overlapping CI. Agent time per stage is not recorded today, so the saving is unknown until stage timing has data.

## Owner Conditions

No decision in this spec weakens these conditions.

1. Revertibility is the condition of the whole item. Each reduction is its own commit with its ledger entry in that same commit. The entry holds the prior text or a patch, full revert steps including mirrors and contract tests, and revert signals, and it works months later without relying on `git revert`.
2. No baseline task, baseline evidence, or baseline comparison is reduced. Only the routine "read the policies" task and its artifact are dropped.
3. Merge remains impossible without a passing review and green CI, within the limit stated in D10.
4. Older checkpoints and plans stay valid. Merged hook changes reach in-flight Epic #1019 items, so every new rule is key-gated or cutoff-gated.

## Decisions

- **D1. Ledger.** `docs/engineering/process-reductions/` holds a `README.md` index and `NNNN-<short-name>.md` entries, as in research section 1. Required sections are `## Summary`, `## Reason and Evidence`, `## Files Changed`, `## Prior Text` or `## Stored Patch`, `## Revert Steps`, and `## Revert Signals`. `## Prior Text` holds `### Revert Block: <repository-relative path>` subsections, each with a fenced `Current` and a fenced `Prior` block. Helpers live in `scripts/dev-tools/ProcessReductionLedger.psm1` with Pester tests. One sample is replayed in memory. An entry records the stable commit subject token `reduction: NNNN` and `Merge commit: pending (PR #N)`, which the next stage or a final records commit back-fills. The reviewer checks separate-commit status from the branch log. Reason: a commit cannot name itself or its later merge, CI runs on a shallow checkout and cannot prove commit separation, and tests may not create temporary files.
- **D2. G13.** The task guideline moves from 40 to 20 and the physical-line guideline from 400 to 250, in both validators and in `.claude/rules/plan-acceptance-gates.md`. A plan-file stamp below `PLAN_GUIDELINE_CUTOFF` keeps 40 and 400. A plan with no path uses the new pair. The cutoff value is chosen in the stage F plan: it is the stamp `<day>T00-00`, where `<day>` is the America/New_York calendar day of the G13 commit, because the feature-folder tooling stamps plan files in that time zone. Reason: a cutoff has no author-controlled surface in a new plan, and older plans need no edit, which matters because parallel runs verify `plan-hash`.
- **D3. Light remediation.** A third mode line `Remediation-Mode: light`, a `## Light Fix Tasks` section in the inputs file, `plan_path` naming that file, `remediation_path` on the cycle, an optional `scope` on findings, and a new invariant 8 in the Python, TypeScript, and PowerShell validators in one commit. The threshold is exactly that of research section 5 and is restated under Behavior. The reviewer chooses the path, and the orchestrator may only move it heavier. Reason: the planner delegation and preflight are the saving, and a record of a preflight that never ran would be untruthful.
- **D4. Concurrent CI and review.** `review_mode: "concurrent"` with `head_sha` on `review_outcomes[]`, plus a merge guard sibling for Claude and a Codex twin. The guard lands in a commit before the readiness relaxation. A review is stale after any code change, including a merge of `origin/main`. Only feature-folder paths may follow the reviewed head. New orchestrations default to concurrent through the orchestrate skill. A sequential run keeps today's behavior unchanged. Reason: nothing reads a review result at merge today, so relaxing the ordering before the guard exists would remove the only review control.
- **D5. CI cross-check.** The reviewer writes a `## CI Cross-check` table of claimed results. At the join the orchestrator compares it with `ci_gate` and `gh pr checks`, and any mismatch becomes a synthetic Blocking finding. This is a split of the owner's "a reviewer cross-checks", because `feature-review` has no `gh`. **The split needs owner visibility.** Reason: a concurrent review can finish before CI, and a tool grant still could not read an unfinished run.
- **D6. Design check.** A named pass inside single-pass preflight, with no new delegation, as in research section 7. Reason: preflight already reads the whole plan against the tree, and a separate step would add the delegation this item removes.
- **D7. Early dependent starts.** The `early_start` field, key-gated in both barrier layers, as in research section 8. The sync step is a merge of the integration branch, not a rebase, because the repository denies forced pushes. The owner wrote "rebase"; this decision replaces it, and the replacement is recorded here for that reason.
- **D8. Stage timing.** Top-level `stage_timing` in the checkpoint, the committed `evidence/other/stage-timing.<timestamp>.json`, and `scripts/dev-tools/Get-StageTimingReport.ps1`. Figures are wall-clock, stated as such, and include queueing. Reason: `artifacts/` is gitignored and leaves with the worktree.
- **D9. Installed MCP lags the branch.** Installed is 1.1.22 and the repository is 1.1.26, and this run pushes no tags. Until a release is installed, new validator rules are exercised through the repository's Python CLI route, and the skills say so in the same form used for G11 through G13. The routes are `poetry run python -m scripts.dev_tools.validate_orchestration_artifacts plan <path>` and the `orchestrator-state` subcommand of the same module. Installing a release is an owner action outside this item. Consequence: `atomic-planner` has only the MCP route, so its self-check applies the installed rules, and the new rules first apply at preflight.
- **D10. Limit of the merge control.** The GitHub ruleset requires only `CI Required Gate`, with 0 approvals. No ruleset change is proposed. Green CI is therefore enforced by GitHub, and passing review is enforced only by a hook-level, policy-level control. A same-session writer can edit the checkpoint, a merge outside the Bash hook surface is not gated, and a merge whose item target does not resolve sees no key, which leaves the parallel skill step as the only backstop. A text scan cannot read every merge: a script file performing the merge cannot be read, and neither can encoded or run-time composed text, a `gh` alias or shell function from an earlier call, or an endpoint held in a variable. A merge through a tool other than Bash is not gated: the Claude PowerShell tool and `mcp__*` tools, because the gate is registered on the `Bash` matcher only, and the Codex `shell_command` tool, because the gate is registered under `^Bash$` and returns for any other tool name. An already-queued auto-merge fires with no command, and `gh pr merge <PR> --disable-auto` removes it. A direct push to the base branch is not a pull-request merge, and the gate does not read it. A number-less merge text sees only the session checkpoint, so a key in another worktree is not found. The extra checkpoint read of the shape rule is best-effort: a failed read sees no key and keeps the decision of a run without the key. The extra read covers at most the first 4 numbers of the text, so a key held only by an item named after them is not found. Under the key the rule is fail-closed, so prose containing `pr merge` is denied in any command, including `git commit -m` and `grep`. This trade is accepted because only concurrent runs carry the key and a merge is issued in its own call. Reason: the guard follows the precedent of the authorization record and is not a security control.

## Clarifications

These follow from the conditions and decisions above. They were not separately decided, so a reviewer should confirm them.

- **K1. Smaller-plans text is its own reduction.** The stage E smaller-plans text reduces plan tasks, so it takes its own commit and entry, separate from the policy-read removal.
- **K2. Non-identical copies.** `atomic-plan-contract` copies differ per surface, so "re-copy mirrors" cannot revert them. An entry carries one Revert Block per non-identical copy. Byte-identical mirrors are re-copied from the canonical file.
- **K3. Deferred wording.** When wording for a reduction moves to stage E or later, the commit that lands it also updates that reduction's ledger entry, so the entry stays complete.
- **K4. Older plan shapes.** The stamp is read from `plan.<stamp>.md`, `plan.remediation-cycle-N.<stamp>.md`, `remediation-plan.<stamp>.md`, and the folder form `remediation/<stamp>/remediation-plan.md`. The last form exists in `docs/features/active/` and is not in the research list.
- **K5. Plan path independent of the repository seam.** The TypeScript gate context is `undefined` when any wiring field is absent, so the path reaches G13 by its own parameter. Missing wiring must not move an older plan to the new pair.
- **K6. Brief deferral.** The `execution-environment` maintenance rule requires a brief update in the same change, and preflight checks for it. A stage before E that alters a brief fact records the deferral in its `Mirror parity` Pre-Mortem bullet and names stage E as the update. The same applies to the test rule below, because the brief still lists serial isolation runs until #1094 merges.
- **K7. Synthetic findings.** A cross-check mismatch is appended as a new `review_outcomes` entry with an `autonomous` finding and verdict `REMEDIATION_REQUIRED`, so the last entry is no longer `PASS` and the guard denies the merge.
- **K8. Back-fill timing.** A merge-commit back-fill is under `docs/engineering/`, outside the feature folder, so it would stale a review. It is committed before the stage's review starts.

## Behavior

**Ledger.** A commit that reduces evidence, plan tasks, gates, or review process adds its entry in the same commit. The standing rule applies when `docs/engineering/process-reductions/` exists, so a consumer repository without the folder is unaffected. One-off waivers for a single item are not entries. `## Revert Steps` names, in order: apply the blocks, re-copy mirrors and bundles, regenerate Codex variants and run the generator `--check`, restore pinned hashes, restore contract-test literals, and run the contract tests.

**Smaller plans.** Plans are design-level, with a target of 15 to 20 tasks. A plan above the guideline still passes with a `## Size Justification` section. The routine policy-read task and its artifact are removed. Agents still follow policy. A plan that keeps the task stays valid.

**Less evidence.** Evidence is kept only when a reviewer cannot get it from the diff or CI. Research section 4 gives the disposition of each requirement. Final-QC artifacts, repo-wide coverage totals, and scope listings are reduced. Baseline artifacts and comparison, per-changed-file coverage, changed-line regression, and fail-before evidence are kept.

**Light remediation.** All of the following must hold, or the cycle takes the full chain:

- at most 3 blocking findings, every one `autonomous`;
- no change to a spec acceptance criterion, a public interface, or the file inventory beyond the branch diff plus tests and mirrors;
- no change to a validator contract, hook decision, or production logic beyond the finding's named location;
- the cycle is opened by a review, not by a CI failure or a merge conflict;
- the prior cycle was not light.

`feature-review` writes `Remediation-Path: light|full` and, per blocking finding, `Finding-Scope: contained|design`. The orchestrator owns the `Remediation-Mode:` line. The fix goes to execution and then re-review, with no plan or preflight. An executor stop before the first checked task rewrites the mode line and continues on the design chain.

**Concurrent review.** The sequence is: the local parallel run passes, commit, open the PR, run review and CI together, join, merge. At the join the orchestrator requires a passing review at a current head, green CI, and a `CI full run` at the reviewed head or at a predecessor that satisfies the same rule, because a docs-only head reports success without the heavy suites. A reviewed head is current when it equals the live head, or when it is an ancestor of the live head and the diff between them lists only paths under the checkpoint `feature-folder`. A git failure denies. A run that resumes a checkpoint without the key stays sequential.

**Design check.** For each spec rule, parameter, and boundary, preflight names the task and the test that would fail if the rule were broken. A gap is a substantive defect.

**Early dependent starts.** An epic child may start on its upstream branch once the interface is settled. Other dependencies keep the barrier. After the upstream merges, the child merges `origin/<integration_branch>`, runs its local gate, records `synced_at`, and only then opens its PR. If the upstream interface changes after `interface_settled_at`, the child stops and the epic orchestrator re-evaluates.

**Stage timing.** The orchestrator main session records stage start and end at the transitions where it already rewrites `last_updated`, reading the clock. The merge stage is not captured, and the report says so.

## Inputs / Outputs

- Inputs: checkpoint keys below, plan paths, `remediation-inputs.<timestamp>.md`, and committed stage-timing evidence.
- Outputs: ledger files, deny codes `REVIEW_GATE_NOT_PASSED`, `REVIEW_GATE_HEAD_STALE`, and `REVIEW_GATE_HEAD_UNRESOLVED`, new `EPIC_WAVE_BARRIER_VIOLATION` text, the G13 message stating the guideline that applied, and a report of per-stage median and total per issue.
- Compatibility: every rule below is absent-key or cutoff neutral.

## API / CLI Surface

- `Get-ProcessReductionSection`, `Test-ProcessReductionEntry`, `Test-ProcessReductionIndex`, `Get-ProcessReductionRevertBlock`, and `Invoke-ProcessReductionRevert`, which throws when `Current` is absent.
- `scripts/dev-tools/Get-StageTimingReport.ps1`, with pure logic in `scripts/dev-tools/StageTiming.psm1`.
- `PLAN_GUIDELINE_CUTOFF` in `scripts/dev_tools/plan_gate_document.py` and `extensions/drm-copilot/src/lib/validate/plan-gate-document.ts`.
- `.claude/hooks/enforce-epic-merge-gate-review.ps1` and its Codex twin.
- The merge guard makes one bounded `gh` call, only under the key.

## Data & State

All additions are optional keys. Absent keys leave every existing rule byte-identical. Shapes are in research sections 5, 6, 8, and 9.

| Key | Location | Rule |
| --- | --- | --- |
| `review_mode` | checkpoint top level | Absent means sequential. |
| `head_sha` | `remediation_loop.review_outcomes[]` | Required by the guard under the key. |
| `remediation_path` | remediation cycle | `light` or `full`. Absent keeps invariant 2 unchanged. |
| `scope` | `review_outcomes[].findings[]` | `contained` or `design`. |
| `stage_timing` | checkpoint top level | Tolerated; not validated. |
| `early_start` | dependent epic feature | Absent keeps both barrier layers unchanged. |

Invariant 8 requires that `remediation_path` is `light` or `full`; a `light` cycle carries no `preflight` object and a valid `opened_by_review`; the referenced outcome has at most 3 findings, each `autonomous` with `scope` exactly `contained`; and the prior cycle is not `light`. Invariant 2 applies to every non-light cycle. Error strings are byte-identical across the three runtimes.

## Constraints & Risks

- Lighter evidence makes a poor review harder to audit. The CI cross-check is the mitigation.
- A light path can admit a design problem as a small fix. The explicit threshold, the reviewer's choice, and invariant 8 are the mitigations.
- Starting on an upstream branch can cause rework. The risk is accepted in the requirements.
- `validate-orchestrator-output.ps1` uses the PowerShell module from main, so a merged change applies to every in-flight stop at once. Hook behavior on a branch is proven by Pester only.
- Under D9, installed MCP rejects a truthful light cycle until a release is installed. `validate_orchestration_artifacts` is a required route tool that cannot be waived, so the stage D plan must confirm that a light cycle can complete under the installed release. If it cannot, the skill text states that the light path is unavailable until the release.
- The policy-audit template is served from installed assets, so stage G template edits lag until a release.
- `PINNED_FROZEN_SURFACE_HASHES` fails CI on an epic-surface edit without a re-baseline.
- Any edit to an admitted plan stops its child with `premise_falsified`. Nothing here may require editing in-flight plans or Epic #1019 feature folders.
- New tooling is PowerShell, except where an existing Python or TypeScript validator must change for parity. No git tags are pushed.

## Implementation Strategy

- Scope and file inventories: research sections 1 through 9. Bundled copies count as production files, so multi-mirror stages take the orchestrated large route.
- `enforce-epic-merge-gate.ps1` is near the 500-line guidance, so guard logic goes in the sibling, which needs its dependency guard and pack-manifest entries.
- A new TypeScript file needs its own `coverageThreshold` entry.
- Dependencies: none added.
- Rollout: staged by the PRs below. Each reduction is reverted through its ledger entry.

## Testing Rule

Tests run in parallel only: one `Invoke-PoshQCParallelTest` run and one `pytest -n auto` run per gate, re-run only after a fix, with no single-process, seeded-shuffle, reversed-order, or comparison runs.

## Delivery Stages

Each stage is one small PR into main from `feature/reduce-feature-cycle-time`, one after the other. The issue stays open until the last. Between stages the branch merges `origin/main`. A PR owes only criteria tagged with its stage and earlier ones, and earlier criteria must still hold. The final stage owes all.

| Stage | Content | Depends on | PR |
| --- | --- | --- | --- |
| A | Ledger, helpers, tests, review-side standing rule | None | PR A |
| B | Stage timing. Reduces nothing, so no ledger entry | None | PR B |
| C | Merge guard commit, then concurrent review reduction commit with entry. Includes the skill text and the parallel merge-on-green step | A | PR C |
| D | Light remediation reduction commit with entry | A | PR D |
| E | #1094 back-fill entry, planning-side standing rule, smaller-plans text, policy-read removal with its hook edit (own commit and entry), and wording deferred from earlier stages | A, #1094 merged | PR E |
| F | G13 and the cutoff (own commit and entry) | A, #1094 merged | PR F |
| G | Less evidence and the CI cross-check (own commit and entry) | C, E | PR G |
| H | Design check. Adds a check, so no ledger entry | #1094 merged | PR H |
| I | Early dependent starts, including re-baselined frozen hashes (own commit and entry) | A | PR I |

The column lists content dependencies. PRs still merge in letter order, one after the other.

Stages A to D and I do not touch `execution-environment` or `atomic-plan-contract`, except as named. Any wording in those two skills moves to stage E or later. If a stage alters a fact the `execution-environment` brief states, that brief edit waits for #1094 too (K6).

Unsafe orderings are listed in research section 10. The guard precedes the readiness relaxation; the policy-read contract text and hook edit share a commit; the three light-cycle validators share a commit; G13 lands with its cutoff.

## Acceptance Criteria

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
- [ ] [D] A light remediation cycle validates truthfully in the Python, TypeScript, and PowerShell validators with byte-identical strings, and all three land in one commit.
- [ ] [D] A cycle with a design-level finding or no `scope` fails on the light path and still requires the full chain, and a full-path cycle with no preflight fails invariant 2.
- [ ] [D] Invariant 8 also rejects a light cycle with findings above the threshold, a consecutive light cycle, and a light cycle carrying a `preflight` object.
- [ ] [D] The reviewer's `Remediation-Path` choice can be moved only heavier, the skills state the threshold and the Python CLI route of D9, and the light reduction lands as its own commit with its entry.
- [ ] [E] An entry for #1094, the parallel-only test gates, exists with the prior text from its pre-merge state.
- [ ] [E] The planning skill and all its mirrored copies state the standing rule.
- [ ] [E] The smaller-plans text states the design-level target of 15 to 20 tasks and lands as its own commit with its entry.
- [ ] [E] The policy-read task, its artifact requirement, and the hook's policy-read check are removed in one commit with its entry; a plan that keeps the task stays valid; and every baseline requirement string named in research section 3 is present before and after.
- [ ] [E] Applying one entry's revert steps to a test copy restores the prior behavior for at least one sample reduction: in memory, the reverted `Get-PlanStructureValidationReport` returns the policy-read error and the live function does not.
- [ ] [E] Wording deferred from stages A to D has landed, with each affected ledger entry updated in the same commit.
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

## Definition of Done

- [ ] Acceptance criteria documented and mapped to tests or demos
- [ ] Behavior matches acceptance criteria in all documented environments
- [ ] Tests updated/added (unit/integration as applicable)
- [ ] Edge cases and error handling covered by tests
- [ ] Docs updated (README, docs/features/active/... links)
- [ ] Telemetry/logging added or updated (if applicable)
- [ ] Toolchain pass completed (format → lint → type-check → test)
