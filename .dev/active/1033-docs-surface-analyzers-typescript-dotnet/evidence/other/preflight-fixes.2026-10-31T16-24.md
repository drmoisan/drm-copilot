# Preflight Fixes

Timestamp: 2026-10-31T16-24
Plan: docs/features/active/2026-10-30-docs-surface-analyzers-typescript-dotnet-1033/plan.2026-10-30T18-39.md

Preflight pass: single-pass preflight of plan version 0.4 (owner decision P3 revision) against the current tree, `spec.md` version 0.4, `user-story.md`, epic `docs/features/epics/documentation-estate-tooling/epic.md` (`### Ledger contracts from the PowerShell preparation of 1023 (binding)` and the other cited headings), 1020 `spec.md` version 0.6 (`## Decisions Later Children Must Honor`, `### \`DocsSurface.psm1\` (pure)`, `#### Declaration-lines digest (D5)`, `### \`DocsAnalyzerRegistry.psm1\``), 1020 `plan.2026-10-30T16-08.md` `[P4-T1]`, 1022 `spec.md` `### Inventory command and snapshot builder`, and 1023 `spec.md` `### Scanner precision limits (D3)` and `### #1022 and #1033 (PowerShell scanners) for precision-limit diagnostics`. Earlier fix records in this folder belong to the previous planning cycle and are not repeated.

## Fix 1 — [P6-T3] (meaning of "selected" for `extension-import` in `Context 'bounds'`)

- Defect class: literal-formatting clarification that keeps the assertion's meaning (validator-blind ambiguity).
- Finding: the bounds assertion reads "per analyzer, an oversize selected input yields one blocking `input-over-bound`". For `extension-import`, spec `## Inputs / Outputs` selects a `*.json` input only when its parsed root is an extension-result manifest, so an input whose `text` is `$null` cannot be selected. Without the clarification, an executor could select every oversize `*.json` input by suffix, which contradicts the spec selection table and would turn any large JSON file in a destination repository into a blocking `extension-import` diagnostic.
- Change: added a parenthetical stating that for `extension-import` "selected" follows the spec selection table, which requires a parsed manifest root, so an input whose `text` is `$null` is not selected by it. No task, file set, or other assertion changed; the clause is parallel to the existing empty-file sentence for `extension-import` in the same task.

## Validation

- `mcp__drm-copilot__validate_orchestration_artifacts` (`artifact_type: plan`): ok before and after the fix.
- Branch-current CLI (`scripts.dev_tools.validate_orchestration_artifacts`, `plan` subcommand, Poetry module form): `plan validation passed`, exit 0, no `PLAN GATE WARNING:` line, before and after the fix.
- Restricted-token scan over the feature folder with the two bracket-class patterns (case-insensitive): 0 matches.
