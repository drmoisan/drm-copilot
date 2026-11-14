# reduce-feature-cycle-time-with-revertible-ledger (Issue #1097)

- Date captured: 2026-11-06
- Author: Dan Moisan
- Status: Promoted -> docs/features/active/reduce-feature-cycle-time-with-revertible-ledger-1097/ (Issue #1097)

- Issue: #1097
- Issue URL: https://github.com/drmoisan/drm-copilot/issues/1097
- Last Updated: 2026-11-07
- Work Mode: full-feature

## Problem / Why

A feature takes 3 to 4 hours of agent time or more, which the owner considers far too long. Measured on Epic #1019 on 2026-11-07:

- Plans hold 37 to 57 tasks.
- Finished items carry 26 to 69 evidence files.
- Docs-only commits since 2026-11-05 are 96 of 125 on #1034 and 67 of 93 on #1031.
- 4 of the 7 merged epic features needed a remediation cycle, and #1031 and #1034 were in remediation cycles at the time.

Agent time per stage is not recorded, so the saving from any single change is unknown.

The owner approved the reductions below, with one condition: every reduction must be easy to revert, possibly several months from now, if agents stop behaving well.

## Proposed Behavior

### 1. Reduction ledger (deliver first)

Create `docs/engineering/process-reductions/` with a `README.md` index and one file per reduction. Each entry states:

- what was reduced, the date, the issue, and the merge commit;
- the reason and the measured evidence for it;
- every file changed, including mirrored copies;
- the prior text, verbatim, or a stored patch file, so that reverting does not depend on `git revert` applying cleanly months later;
- step-by-step revert instructions, including mirrors, bundles, and contract tests;
- the signals that would justify reverting it.

The change that makes a reduction adds its ledger entry in the same commit. Each reduction is its own commit. A standing rule in the planning and review skills requires a ledger entry for any future reduction of evidence, plan tasks, gates, or review process. One-off waivers for a single item are not ledger entries.

Back-fill an entry for #1094, the parallel-only test gates.

### 2. Smaller plans

- Plans are design-level, with a target of 15 to 20 tasks.
- Lower the G13 task guideline from 40 to 20, in both the Python and TypeScript validators and in `.claude/rules/plan-acceptance-gates.md`. A plan above the guideline still passes with a `## Size Justification` section. Review the physical-line guideline in the same change.
- Remove the routine "read the policies" plan task and any evidence file tied to it. Agents still follow policy; they stop producing a task and artifact to say so.
- **Baseline capture stays.** The owner stated that writing a baseline is critical for testing. No baseline task, baseline evidence, or baseline comparison is reduced by this item.

### 3. Less evidence

Keep only evidence a reviewer cannot get from the diff or CI. A green CI run is the evidence that tests passed, so a local evidence file need not repeat it. Baseline evidence is kept. To guard against weaker auditability, a reviewer cross-checks claimed results against CI results.

### 4. Light remediation path

When a review finds a small number of contained findings with no design change, the fix goes directly to execution and then re-review, with no full plan or preflight. Define the threshold explicitly. Design-level findings keep the full remediation chain. The checkpoint validators must accept a truthful record of a light cycle; invariant 2 of the remediation-cycle rules requires a cleared preflight today, so this needs an explicit contract change across the Python, TypeScript, and PowerShell validators.

### 5. CI and review run at the same time

Open the PR once the single local parallel run passes, and run review while CI runs, instead of review first. Merge still requires both a passing review and green CI.

### 6. Earlier design check

Add a short check of the design against the spec before execution starts, aimed at the kinds of finding that cause remediation cycles today.

### 7. Start dependent work earlier

Allow an epic child to start on its upstream branch once the interface is settled, with a defined rebase step when the upstream merges. Update the wave-barrier rules only as far as this needs.

### 8. Stage timing

Record the start and end of each stage in the checkpoint, with a small report, so that reductions can be judged on measured time and the ledger's revert signals can be read.

## Acceptance Criteria (early draft)

- [ ] `docs/engineering/process-reductions/` exists, with an index and an entry for every reduction made, including #1094.
- [ ] Every entry carries the prior text or a patch, revert steps, and revert signals, and each reduction is a separate commit.
- [ ] A test fails if a ledger entry lacks a required section.
- [ ] Applying one entry's revert steps to a test copy restores the prior behavior for at least one sample reduction.
- [ ] No baseline task, evidence, or comparison requirement is removed.
- [ ] The planning, execution, and review skills, and all mirrored copies, describe the new rules, and contract tests pin them.
- [ ] G13 reports at the new guideline in both validators, with parity.
- [ ] A light remediation cycle validates truthfully in all three validators, and a cycle with design-level findings still requires the full chain.
- [ ] Merge is still impossible without a passing review and green CI.
- [ ] Stage timing is recorded and reported.
- [ ] `Invoke-PoshQCParallelTest` and `pytest -n auto` pass with zero failures.

## Constraints & Risks

- Lighter evidence makes a poor review harder to audit afterwards. The cross-check against CI is the mitigation.
- A light remediation path can let a design problem through as a "small" fix. The threshold must be explicit, and the reviewer decides which path applies.
- Starting on an upstream branch can cause rework if the upstream changes.
- Hooks run from the main checkout, so changes here reach in-flight work when they merge. Changes must not break Epic #1019 items or their existing plans and checkpoints.
- This overlaps with #1094 on the `execution-environment` and `atomic-plan-contract` skills, so its changes to those skills land after #1094 merges.
- Keep each reduction independently revertible; avoid mixing two reductions in one edit.
- New tooling is PowerShell, except where an existing Python or TypeScript validator must change for parity.
- Do not push git tags; record merge commits in the ledger instead.

## Test Conditions to Consider

- [ ] Ledger structure check: complete entry, missing section, missing prior text
- [ ] G13 parity at the guideline and one above it, with and without a justification
- [ ] Light-cycle checkpoints: valid, design-level finding on the light path, preflight absent on the full path
- [ ] Merge gate with review passed and CI pending, and with CI green and review pending
- [ ] Older checkpoints and plans still validate

## Next Step

- [ ] Promote to GitHub issue (feature request template)
- [ ] Create `docs/features/active/reduce-feature-cycle-time-with-revertible-ledger/` folder from the template
