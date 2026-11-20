# Preflight Fixes (issue #1145)

Timestamp: 2026-11-08T21-19
Plan: docs/features/active/2026-11-08-orchestrator-stop-hook-validates-wrong-worktree-checkpoint-1145/plan.2026-11-08T15-53.md
Validator: branch-current Python CLI `plan` subcommand passed before and after the fixes (G1 to G13).

Each fix below edits task text or preamble only; no task was added, removed, or reordered, and no asserted value changed.

1. `## Design` (main hook bullet) and `## Pre-Mortem` (Evidence) | citation correction | "PR #1139" replaced with PR #1146 (issue #1139). #1139 is the issue; the pull request is #1146, which merged into `main` during planning.
2. `## Pre-Mortem` (File size) | stale fact | the main hook line count now also states the `main` figure after PR #1146 (413) and the expected size after P2-T4 and P4-T1 (about 435, under 500).
3. [P0-T1] and [P4-T2] | literal clarification | `Invoke-PoshQCFormat` has no check-only switch; the check-only mode is stated as a recording `-WriteFile` seam, so the baseline does not rewrite files and the finding count is the number of files it would rewrite.
4. [P1-T1] H13 | literal clarification | names the mocks the entry-tail row needs (`Import-Module`, `Get-CheckpointFileContent`, `Invoke-RoutingContractValidation`, as in the E-ORC-3 row of `validate-orchestrator-output.Envelope.Tests.ps1`); without the routing mock a minimal checkpoint blocks with `ROUTING_CONTRACT_BLOCKED:`.
5. [P1-T2] | clarification of recorded evidence | states that before the fix the rows that pass `-ReadTranscriptHead` or `-WorktreeListInvoker` fail at parameter binding, and that the artifact records that reason as observed. The acceptance is unchanged.
6. [P3-T1] and [P3-T2] | placement disposition | both edits are stated to lie outside the regions recorded in `docs/engineering/process-reductions/` (revert blocks and stored patch hunks for the orchestrate skill and the brief).
7. [P4-T1] | conflict scope | conflict resolution by keeping both sides now names every file PR #1146 also edited (main hook, orchestrate skill, brief copies, `core.json`), not only the main hook.
8. [P4-T3] | named asserting test | `tests/scripts/dev-tools/ProcessReductionChain.Ledger.Tests.ps1` (including `PRC-LEDGER-NO-EXCEPTIONS`, which holds for the brief) is named in the zero-failure list, because P3-T1 and P3-T2 edit ledgered files.
