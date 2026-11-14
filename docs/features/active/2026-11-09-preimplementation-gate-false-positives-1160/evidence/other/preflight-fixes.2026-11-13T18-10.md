# Preflight Fixes — Remediation Plan, Cycle 1 (Issue 1160)

Timestamp: 2026-11-13T18-10
Plan: docs/features/active/2026-11-09-preimplementation-gate-false-positives-1160/remediation-plan.2026-11-13T17-44.md
Signal: PREFLIGHT: REVISIONS REQUIRED (substantive defects are returned to the planner; the fixes below are trivial and were made in task and preamble text only)

## Fix 1 — `## Execution Constraints (owner rules, binding)`, batch-budget bullet

- Defect class: stale fact (validator-blind; meaning kept).
- Before: the bullet said the item runs on the orchestrated remediation route.
- After: the bullet says the item worktree's checkpoint selects a non-terminal orchestrated route (`large` or `remediation`), which the brief's `## Batch Budget` section exempts.
- Reason: the item worktree checkpoint records `route_id` `large`; both routes are exempt, so the exemption claim is unchanged.

## Fix 2 — `## Existing Tests Asserting Changed Behavior`, brief readers

- Defect class: incomplete test disposition list for a changed file (validator-blind; no task, file set, or assertion changes).
- Added one bullet naming the remaining test files that read `execution-environment/SKILL.md`, each with disposition unchanged: `test_discovery_documentation_contracts.py`, `test_bash_command_shape_surfaces.py`, `test_single_pass_preflight_contracts.py`, `NestingDepthContract.Tests.ps1`, `cleanup-merged-worktrees.SkillText.Tests.ps1`, and `ProcessReductionChain.Ledger.Tests.ps1`.
- Verification: none asserts the #1160 bullet; the ledger entries under `docs/engineering/process-reductions/` record brief hunks only in `## Command-Text Restrictions`, `## Contract Tests That Pin Mirrored Files`, and `## Preflight Defect Classes the Validator Cannot See`, not in `## Hook Execution Context`.

## Fix 3 — [P3-T6] remediation file-set observation

- Defect class: acceptance observation that depends on commit state (validator-blind; the asserted file set is unchanged).
- Before: the remediation diff from the start ref to `HEAD`, with `git status --porcelain` empty.
- After: the union of the name-only diff from the start ref to `HEAD`, the name-only diff from the start ref to the working tree, and the untracked entries of `git status --porcelain`.
- Reason: the plan has no commit task, so an empty porcelain status at [P3-T6] depended on an unplanned commit; the union form observes the same file set whether or not the remediation is committed.
