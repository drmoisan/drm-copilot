# Phase 1 Execution Order (P1-T1)

Timestamp: 2026-10-12T15-03

- Executor: `atomic-executor` performs P1-T2 through P1-T37 directly, in task-ID order. No task is handed to another agent.
- Order gate: P1-T17 through P1-T25 (source conversions) start only after `FEATURE/evidence/regression-testing/cp-order-red.<ts>.md` exists and records a `Tests:` line containing `14 failed`. If P1-T16 does not meet its pass condition, execution stops with a BLOCKED report and no production edit is made.
- Mutation gate: P1-T34 restores `extensions/drm-copilot/src/lib/codex-native-converter/engine-pipeline.ts:241` to its exact original text and records an empty anchored diff (`git diff --merge-base origin/main -- <file>`) before P1-T35 starts. The mutation is never staged or committed.
- Completion criteria:
  - P1-T16 reports 14 failed before conversion.
  - P1-T26 reports zero argument-less sort matches and 19 converted lines.
  - P1-T27 reports 14 passed.
  - P1-T33 reports 7 passed.
  - P1-T34 reports 1 failed under mutation and 1 passed after restore.
  - Every edited or created file stays at or below 500 lines.
