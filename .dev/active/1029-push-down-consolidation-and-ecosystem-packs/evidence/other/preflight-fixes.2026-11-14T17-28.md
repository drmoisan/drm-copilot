# Preflight Fixes - Issue #1029

Timestamp: 2026-11-14T17-28
Plan: docs/features/active/2026-10-30-push-down-consolidation-and-ecosystem-packs-1029/plan.2026-10-30T18-37.md
Validator: branch Python CLI `scripts.dev_tools.validate_orchestration_artifacts plan` exited 0 before and after the fixes.

## Fixes

1. `## Planning Decisions` D8 | validator-blind class (ledger chain test pins stored hunks) | Added that new manifest entries are appended at the end of the `paths` array, so the stored `0010` ledger hunks in both `pack-manifests/core.json` files (Claude and Codex bundles) keep their context, naming `ProcessReductionChain.Ledger.Tests.ps1`. The chain locates each hunk by exact context lines; an insertion inside a hunk window would fail `PRC-LEDGER-CHAIN-HOLDS`. No assertion changed.
2. `## Existing Test Dispositions` X12 | missing asserting-test disposition | Added `tests/scripts/dev-tools/ProcessReductionChain.Ledger.Tests.ps1` as unchanged, with the reason: the `0010` patch stores hunks in both `core.json` files and in `EXT/jest.config.cjs`, entries are appended at the end of `paths`, and the D9 edit sits in the `require` and spread region away from the stored hunk.
3. `## Spec Rule Traceability` rows "Report shape, sorting, counts" and "Report warnings prefix distinct" | stale task citation | Task column changed from P1-T3 to P1-T2, the task that creates `PD/push-down-report.ts` and its test.
4. [P0-T7] | literal-source defect (merged Pester JUnit and coverage are written only after a fully green run) | Acceptance now reads pass and fail counts from the per-shard JUnit under `artifacts/pester/parallel/shard-<i>/` when no merged file is written, and line coverage from the merged coverage file when the run is green. The recorded values are unchanged.
5. [P2-T3], [P2-T4], [P2-T5] | missing option anchor (rule R1 passes `overwriteUnmanaged: true` to the module entry points) | Each task now adds optional `overwriteUnmanaged` to its module options type (`ClaudePushDownOptions`, `CodexAgentsPushDownOptions`, `PushDownCustomizationsOptions`), which R1 already requires. No assertion changed.
