# Preflight Fixes

Timestamp: 2026-10-30T23-31
Plan: docs/features/active/2026-10-30-docs-surface-analyzers-python-config-1022/plan.2026-10-30T16-46.md
Round: 1 (new planning cycle under owner decision D1)

## Fixes

1. [P0-T3] | validator-blind class: changed existing behavior without a complete test search | Added the five analyzer identifiers and the command name `inventory` to the search tokens, and added "asserts that one of the five analyzer identifiers or `inventory` is unknown or unregistered" to the `MISMATCH` dispositions. Reason: a 1020 test that uses one of these names as its unknown-identifier or unknown-command case fails once the 1022 rows land, and the previous token list (registry and table symbols, `-Help`, `core.json`, anchor text) would not find it.
2. [P4-T5] | AC-to-task wording alignment (assertion meaning unchanged) | The `Context 'through Invoke-DocsCommandCli'` now runs every exit 0, 1, 2 and 3 case listed in the [P4-T4] Tests instead of "each exit path". Reason: spec AC S14 requires each enumerated case to be asserted through `Invoke-DocsCommandCli`; "each exit path" admitted one case per exit code.
3. `## Artifact Classification` (preamble) | count consistency under a permitted module split | Stated that each module split adds one to every stated count of new modules, mirror pairs, `CORE` entries and added `core.json` lines (seventeen, nineteen, 17 and 18). Reason: the plan permits a split at 500 lines, and the fixed counts in [P5-T1], [P5-T2], [P6-T4] and [P6-T11] would otherwise be unsatisfiable after a split.
