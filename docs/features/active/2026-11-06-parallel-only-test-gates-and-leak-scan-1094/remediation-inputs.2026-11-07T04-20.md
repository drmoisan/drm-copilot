# Remediation Inputs: parallel-only-test-gates-and-leak-scan (#1094)

Review-Verdict: REMEDIATION_REQUIRED
Remediation-Mode: design

Timestamp: 2026-11-07T04-20
Branch: `feature/parallel-only-test-gates-and-leak-scan-1094`, head `2c5c12a0885f2ff1e45e78a18919e5a179c4584a`
Base for diffs: `9a19be8e72ea479212e2e43c3ad766afb270fae6` (merge base with `origin/main`)

Mode note: the cycle is design because the two files below are outside the branch diff. No acceptance criterion or public interface changes.

Audit artifacts:

- `docs/features/active/2026-11-06-parallel-only-test-gates-and-leak-scan-1094/policy-audit.2026-11-07T04-20.md`
- `docs/features/active/2026-11-06-parallel-only-test-gates-and-leak-scan-1094/code-review.2026-11-07T04-20.md`
- `docs/features/active/2026-11-06-parallel-only-test-gates-and-leak-scan-1094/feature-audit.2026-11-07T04-20.md`

RF-1 to RF-4 from `remediation-inputs.2026-11-07T03-22.md` are closed.

## RF-5: a review agent requires a subset run and records it as evidence

Severity: Blocking
Remediability: autonomous
Remediability-Evidence: A text edit to one agent and its bundle copy, plus one sweep token; no owner input or external system is involved.

Criterion affected: 1.

Files:

- `.github/agents/staged-review.agent.md`: Phase D, step `4) Tests`, and the `Rules:` list below it.
- `extensions/drm-copilot/resources/customizations/.github/agents/staged-review.agent.md`: the same text.
- `tests/scripts/claude-runtime/parallel-gate-wording.Tests.ps1`: `$script:SweepToken` and `PGW-SWEEP-HELPER`.

Current text:

- `Run the smallest applicable subset covering staged changes first (repo-specific)`
- `Then run the repo-required full test suite if policy requires it or if failures were found`
- `Capture outputs and reference them in PolicyAudit.md evidence fields.`

Expected behavior: step 4 states the parallel gates, one `Invoke-PoshQCParallelTest` run and one `pytest -n auto` run, for the languages in scope, each re-run only after a fix. It carries the debugging statement: `A focused run of one test file to debug a specific failure is debugging only.` The two copies stay equal. Steps 1 to 3 and the `Rules:` list stay; the evidence rule then applies to the gates.

Add the token `smallest applicable subset` to `$script:SweepToken`, and change the `PGW-SWEEP-HELPER` count and its `-Because` text from 33 to 34. Leave `$script:SweepExclusion` unchanged.

## Optional in the Same Edit

These are Minor in the code review and are not counted. Apply them only if the plan stays small.

- `.github/agents/tdd-green.agent.md` and `.github/agents/tdd-red.agent.md`, with bundle copies: add the debugging statement beside `Run the failing test` and `Run the test to confirm it fails`.
- `docs/features/templates/bug/plan.yyyy-MM-ddTHH-mm.md`, with its bundle copy: limit `[P4-T1]` to the repro, and leave the test result to `[P4-T2]`.

## Verification

- One `Invoke-PoshQCParallelTest` run and one `pytest -n auto` run after the fix, so that both gates describe the final head. Set `PYTHONPATH` to the worktree `packages/discovery-runtime/src`, as in the previous cycle, and record the totals in new `evidence/qa-gates/` files.
- `staged-review.agent.md` is not in `_COPILOT_EDITED`, so `test_copilot_bundle_copies_match_canonical` does not compare it. Confirm that the two copies are equal in the task that edits them.
- Coverage artifacts stay at or above the thresholds, read from those runs. The Jest gate need not re-run unless a TypeScript file changes; if `coverage/lcov.info` is absent at reaudit, run it once.
- Text search for `smallest applicable subset` across the sweep roots returns no hit outside the test file.
- Re-check criterion 1 after reaudit. It stayed unchecked in `spec.md` and `user-story.md`.

## Do Not

- Do not edit `.claude/rules/`, `.github/instructions/`, their bundle copies, `.agents/skills/powershell`, or `.agents/skills/python`.
- Do not change the policy-audit validators, CI workflows, `scripts/powershell/PoshQC/`, `.vscode/tasks.json`, or the Python tools deferred to #1096.
- Do not add a leak scan or a serial, shuffled, reversed-order, comparison, or pre-change run.
- Do not remove tool-permission entries.
