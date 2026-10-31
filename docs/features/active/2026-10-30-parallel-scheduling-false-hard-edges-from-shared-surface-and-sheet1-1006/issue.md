# parallel-scheduling-false-hard-edges-from-shared-surface-and-sheet1 (Issue #1006)

- Date captured: 2026-10-30
- Author: Dan Moisan
- Status: Promoted -> docs/features/active/parallel-scheduling-false-hard-edges-from-shared-surface-and-sheet1/ (Issue #1006)

> Automation note: Keep the section headings below unchanged; the promotion tooling maps each of them into the GitHub bug issue template.

- Issue: #1006
- Issue URL: https://github.com/drmoisan/drm-copilot/issues/1006
- Last Updated: 2026-10-30
- Work Mode: full-bug

## Summary

Parallel scheduling serializes items on two false hard edges, and destinations cannot relax them durably. A shipped shared surface (`quality-tiers.yml`) and a default Excel worksheet name recorded as a contract (`Sheet1`) each produce a hard edge between items that have no real dependency. A destination fix is overwritten by the next push-down.

## Environment

- OS/version: not recorded
- Python version: not recorded
- Command/flags used: `/parallel-plan` and `/parallel-run`, run `backlog-2026-10`, harness 1.1.23
- Data source or fixture: destination repo Real-Good-Foods/iar-migration

## Steps to Reproduce

1. In a destination repo, plan two items that each append one entry to `quality-tiers.yml` (each adds a module).
2. Give two unrelated specs an Interface/Contract section that names an Excel worksheet `Sheet1`.
3. Recompute the blast radius and conflict edges.

## Expected Behavior

Neither source produces a hard edge. Two radii that share only append-only registry paths, generic worksheet names, and ordinary path or module overlap yield no hard edge. At `tolerance_percent` 0 the output stays identical to strict scheduling.

## Actual Behavior

Items #41 and #42 (and #42 and #44) received a hard `path_overlap` edge from two sources:

1. Shared surface `quality-tiers.yml`. Every item that adds a module appends one entry to it. Listing it in `shared_surfaces` makes any two such items a hard edge at every tolerance (integration-cost scheduling rule 2, issue #722).
2. Contract `Sheet1`. `extract_contract_identifiers` / `Get-ContractIdentifier` recorded the worksheet name as a contract, producing a hard `contract_dependency`.

The destination fixed both locally (iar-migration PR #45, merge 88b193b). Push-down 1.1.23 (PR #46) overwrote the fix within minutes. `config/blast-radius.json` is regenerated, and `config/blast-radius.local.json` cannot remove a shipped shared surface (issue #508 overlay semantics).

## Logs / Screenshots

- [ ] Attached minimal logs or screenshot
- Snippet: none; evidence is the destination run and PRs above.

## Impact / Severity

- [ ] Blocker
- [ ] High
- [x] Medium
- [ ] Low

Items run serially that could run in parallel, and a destination cannot fix it without forking.

## Suspected Cause / Notes

The overlay is union-only for `shared_surfaces`, so a destination cannot demote a shipped entry. Contract extraction has no filter for generic spreadsheet worksheet names.

## Proposed Fix / Validation Ideas

Required changes (upstream, all runtimes in parity):

1. **Contract extraction.** Do not record default spreadsheet worksheet names as contract identifiers: at minimum `^Sheet\d+$` (case-insensitive), and consider a small closed constant set of generic tokens of this class. Apply it at every place that filters contracts:
   - Python authority: the `extract_contract_identifiers` and write-intent spec-contract extractors, and the declared-radius normalization that re-filters recorded contracts.
   - PowerShell: `BlastRadiusNormalization.psm1` `Get-ContractIdentifier`, `BlastRadiusWriteIntent.psm1` `Get-WriteIntentSpecContract`, `BlastRadius.psm1` `Get-NormalizedDeclaredRadius`.
   - The TypeScript port, if it extracts contracts.

   Pin the constant equal across runtimes with a parity test, as for the read-verb and placeholder sets. Document it in `.claude/rules/parallel-orchestration.md` beside the four rejected token shapes.
2. **Append-only shared registries.** Stop treating `quality-tiers.yml` as a hard shared surface by default. Move it from `shared_surfaces` to `conflict_tolerance.append_only_paths` in both committed truth tables (self-hosted and published), and update the read-by-mandate constraint 2 text, which currently says it "stays a shared surface". Keep it in `mandate_reads`.
3. **Destination control.** Let `config/blast-radius.local.json` demote a shipped shared surface to an append-only path, for example an explicit `shared_surfaces_demote` list that the composer removes from `shared_surfaces` and adds to `conflict_tolerance.append_only_paths`. Make the demotion fail closed on unknown entries and keep the forbidden-glob guard.

Acceptance:

- [x] A recompute of two radii that share only append-only registry paths, generic worksheet names, and ordinary path/module overlap yields no hard edge. At `tolerance_percent` 0 the output stays identical to strict scheduling (the strict-identity proof still holds).
- [x] Parity tests: the generic-contract constant and the demotion semantics are equal across Python, PowerShell, and TypeScript (where ported). The key-partition exhaustiveness test covers the new overlay key.
- [x] Contract tests that pin mirrored and bundled files pass. The published truth table carries the same `append_only_paths` change.
- [x] A push-down into a destination whose overlay has `shared_surfaces_demote: ["quality-tiers.yml"]` and `conflict_tolerance.tolerance_percent: 5000` produces a composed `config/blast-radius.json` in which `quality-tiers.yml` is append-only, not shared.

Out of scope: no change to the `conflict_edges[].reason` enum or to the parallel checkpoint schema; no change to drift detection beyond its reuse of the scheduling edge rule.

Interim destination workaround: add `config/blast-radius.local.json` with `tolerance_percent: 5000` and `quality-tiers.yml` in `append_only_paths`. That survives push-downs for those two parts only. The shared-surface and `Sheet1` parts need the upstream fix.

## Next Step

- [x] Promote to GitHub issue (bug-report template)
- [ ] Move to active fix folder / branch
