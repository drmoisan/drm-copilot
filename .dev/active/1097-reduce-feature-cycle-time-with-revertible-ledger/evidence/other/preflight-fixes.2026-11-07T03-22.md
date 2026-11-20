# Preflight Fixes: Issue 1097, Stage A (confirming pass)

Timestamp: 2026-11-07T03-22
Plan: docs/features/active/reduce-feature-cycle-time-with-revertible-ledger-1097/plan.2026-11-06T21-23.md

Each entry is a task-text edit. No task was added, removed, or reordered.

## Fixes

1. [P0-T2] | evidence source omission | The revision gave [P3-T2] the `shard.log` source for a JUnit file that is absent or truncated, and its sibling [P0-T2] did not receive it. [P0-T2] runs once and requires numeric counts, so a truncated shard JUnit file would have left it with no named source. The non-zero `ExitCode` bullet now names `shard.log` in the same words as [P3-T2]. The acceptance condition is unchanged.
