# Preflight Fixes — Issue #1221

Timestamp: 2026-11-23T06-19
Plan: .dev/active/1221-docs-family-gate-and-ia/plan.2026-11-23T00-39.md
Signal: PREFLIGHT: REVISIONS REQUIRED (substantive defects returned separately to the planner)

## Fixes applied in place (task text only; no task added, removed, or reordered)

1. [P0-T4] | stale anchor (launcher suite name) | The launcher `jest` suite is the built-in suite that runs `node run-jest.cjs` in the repository root (`.claude/skills/test-execution-policy/SKILL.md`); the extension tests and the per-file thresholds of `jest.docs-coverage.json` belong to the configured `jest-extension` suite in `config/test-execution-policy.json` (working directory `extensions/drm-copilot`). The task now names the `jest-extension` suite. The asserted values (pass and fail counts, line and branch coverage of `mcp-docs-tool-definitions.ts` and `docs-handlers.ts`) are unchanged.
2. [P3-T3] | stale anchor (launcher suite name) | "through the launcher" now names the `jest-extension` suite, for the same reason as fix 1. The acceptance condition is unchanged.
3. [P1-T4] | citation correction (disposition reason) | The reason for leaving `DocsReceipt.Tests.ps1` and `DocsReceipt.Properties.Tests.ps1` unchanged stated that their profiles come from `New-DocsLedgerTestProfile`; neither file references that helper. Both call `New-DocsValidationReceipt` directly with no profile and no `Invoke-DocsValidation` call. The disposition (unchanged) is unchanged; only the reason text was corrected.

## Self-check

Each fix was re-read against the tonality rule and the design-level plan contract: no line-number or commit citation was introduced, no asserted value changed, and no task identifier moved.
