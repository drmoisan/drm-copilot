# Preflight Fixes (Remediation Cycle 2)

Timestamp: 2026-11-07T04-36
Plan: docs/features/active/2026-11-06-parallel-only-test-gates-and-leak-scan-1094/remediation-plan.2026-11-07T04-20.md

Each fix edits task text only. No task was added, removed, or reordered, and no asserted value changed.

## Fixes

1. [P1-T2], citation correction. The bullet cited `_TEMPLATES` as reading only the `## Pre-Mortem` labels. `test_plan_templates_carry_premortem_skeleton` also compares the template with its bundle copy byte for byte. The bullet now names that test and states that the task's copy keeps it satisfied.
2. [P1-T3], literal clarification. The `python-typed-engineer` bullet did not say what happens to the words after `obligations`. It now names the replaced span and states that the rest of the bullet stays.
3. [P1-T4], stale anchor. The acceptance compared the exclusion table against the merge base, where `tests/scripts/claude-runtime/parallel-gate-wording.Tests.ps1` does not exist, so that diff shows the whole file as added. The acceptance now reads a `git diff HEAD` of the test file taken before the task's commit. The assertion is unchanged: the table does not change.
4. [P2-T4], path correction. `<FEATURE>/evidence/regression-testing/` does not exist on this branch. The task now states that the step skips an absent folder and scans every file in the others.
