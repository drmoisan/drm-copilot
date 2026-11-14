# Preflight Fixes (Stage I)

Timestamp: 2026-11-08T16-16
Plan: docs/features/active/reduce-feature-cycle-time-with-revertible-ledger-1097/plan.2026-11-07T00-56.md
Validator: branch-current Python CLI `plan` subcommand exit 0 before and after the fixes; installed MCP validator `ok: true` before and after.

## Fixes

1. `## Scope` | stale re-derivation statement | The sentence listed stages C to G as merged; stage H merged as PR #1133 before this preflight. Added H and the PR number.
2. `## Design`, procedure step 7 | anchor absent from one copy | `## Merge-Conflict Handling (Fan-In)` exists only in the Claude skill; the `.agents` skill names the section `## Fan-In and Conflict Handling`. Added the `.agents` heading in parentheses.
3. `## Design`, `**Ledger and frozen surfaces.**` | incomplete recorded-region inventory | Entries `0002` and `0003` hold `Revert Block` sections on `extensions/drm-copilot/jest.config.cjs`, which [P1-T2] edits. Added a sentence naming both blocks and stating that the new threshold entry goes outside both `Current` regions, so neither older record is edited (consistent with the plan's out-of-scope rule for entries `0001` to `0009`).
4. [P1-T2] | placement of the new `coverageThreshold` entry | Added that the entry is placed outside the `Current` regions of the `0002` and `0003` revert blocks on that file. The acceptance condition is unchanged.
5. [P1-T3] | wording that misdescribes the parity suite count | `OrchestratorStateEpicWaveBarrier.Parity.Tests.ps1` runs one `It` per corpus file (`P <FileName> runs every case`), not one per case. Reworded "gains the new file's rows" to "gains one `It`, for the new file, which runs all of its cases".
6. [P3-T2] | same count wording in an acceptance condition | Reworded "the parity suite grows by the new corpus rows only" to "the parity suite grows by one `It` only, the one for the new corpus file". The asserted meaning (only the new file adds to the suite) is unchanged.
