# Preflight Fixes — Remediation Cycle 3 Plan (Issue 1160)

Timestamp: 2026-11-13T20-41
Plan: docs/features/active/2026-11-09-preimplementation-gate-false-positives-1160/remediation-plan.2026-11-13T19-53.md
Preflight-Signal: PREFLIGHT: REVISIONS REQUIRED (substantive defects are returned to the planner; the fixes below are trivial and were made in place)

## Fixes

1. [P3-T1] | literal count | "the six files of [P0-T1]" changed to "the five files of [P0-T1]". [P0-T1] names four commands-sibling copies and the Cases file, which is five files; the task still covers every [P0-T1] file plus the new suite.
2. [P3-T4] | ambiguous citation | "the `.claude/hooks` and `.codex/hooks` copies of both siblings" changed to "the `.claude/hooks` and `.codex/hooks` copies of the commands sibling". [P0-T2] records head figures only for the two commands copies, and the Pre-Mortem `Coverage` bullet names only the commands copies; the bookkeeping sibling is not changed by this plan.

No task was added, removed, or reordered, and no acceptance value changed.
