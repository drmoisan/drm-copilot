# Preflight Fixes — Issue #1029

Timestamp: 2026-10-31T04-32
Plan: docs/features/active/2026-10-30-push-down-consolidation-and-ecosystem-packs-1029/plan.2026-10-30T18-37.md

Each entry is a trivial defect fixed in place in plan text. No task was added, removed, or reordered. The branch plan validator (`scripts/dev_tools/validate_orchestration_artifacts.py plan`, G1-G13) passed after the fixes.

1. `## Pre-Mortem` (CI-only behavior bullet) | stale task citation | `CRLF built in test code (P3-T7)` changed to `(P3-T9)`; P3-T9 is the task that creates `PDT/push-down-pipeline.test-helpers.ts` with CRLF content built in code, and P3-T7 is the ecosystem registry.
2. `## Size Justification` | factual wording | `twelve new production modules each with its own test and coverage entry` changed to `twelve new production modules with their tests and per-file coverage entries`; `push-down-layer.ts` has a coverage entry but no dedicated test file.
3. `## Existing Test Dispositions` (MCP wrapper row) | missing test citation | added `extensions/drm-copilot/test/mcp-tool-inputs.test.ts` (`resolvePushDownCopilotCustomizationsToolInput` and `resolvePushDownClaudeCustomizationsToolInput` describes) with disposition Unchanged; P4-T6 moves the Copilot resolver and re-exports it, and these cases assert `toEqual({ workspaceRoot })`, which holds because new fields are spread only when present.
4. `## Existing Test Dispositions` (decorator and loader row) | missing test citation | added `claude-blast-radius-overlay.test.ts` `does not publish a source-side overlay file`, which runs the Claude adapter through the `publish` helper in `config-carriage.test-helpers.ts`, with disposition Unchanged; its only assertion is that the overlay file is not written.
