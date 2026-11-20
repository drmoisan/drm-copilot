# Preflight Fixes - Issue #1051

Timestamp: 2026-11-14T16-29
Plan: docs/features/active/2026-10-31-push-down-integration-mcp-tools-and-skill-1051/plan.2026-11-14T10-43.md
Mode: single-pass preflight (DIRECTIVE: PREFLIGHT VALIDATION ONLY); task text edits only, no task added, removed or reordered.

## Fixes

1. `## Terms and Execution Rules` (upstream citation bullet) | citation correction | The bullet attributed every upstream symbol to the upstream `spec.md`. `pushDownHarness`, `PushDownReport`, `WriteIfChangedFileSystem`, `push-down-ecosystem-registry.ts` (#1029) and `findCiWorkflowNameCollisions`, the caller renderer and the D4 pack-to-stem mapping (#1050) are defined in the upstream plan files, not in the upstream specs. The bullet now reads "per #1029 spec and plan" and "per #1050 spec and plan" and names the plan-defined symbols.
2. `[P0-T1]` | citation correction | "per #1029 spec" changed to "per #1029 spec and plan", and "per #1050 spec" changed to "per #1050 spec and plan", for the same reason as fix 1. The confirmed symbol set is unchanged.
3. `[P2-T3]` | stale description | The handler description said the handler builds JSON text, `structuredContent` and `isError`. In the docs-handler pattern (`handleDocsTool` in `EXT/src/mcp-handlers/docs-handlers.ts`), the handler returns a `RepoAutomationMcpToolResult`, and `toCallToolResult` in `EXT/src/mcp-server.ts` builds the JSON text, `structuredContent` and `isError: !result.ok`. The text now states that split. The asserted behavior (S47) is unchanged.
4. `[P3-T3]` | citation correction | The acceptance requires "the four ledger rows", but the task named three. `ProcessReductionChain.Ledger.Tests.ps1` has four ledger rows. The missing row, `PRC-LEDGER-END-STATE-RECORDED`, is now named, so the named rows match the asserted count.

## Re-validation

The branch Python CLI plan validator (`scripts/dev_tools/validate_orchestration_artifacts.py`, `plan` subcommand) was run after the fixes. Its result is recorded in the preflight return.
