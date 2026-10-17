# Remediation Inputs — Issue #776 (cycle 1)

- Timestamp: 2026-09-29T20-15
- Branch: bug/blast-radius-overlap-perf-776
- Source: plan task P2-T6 failure during atomic execution of `plan.2026-09-29T18-10.md`
- Plan of record: `plan.2026-09-29T18-10.md` (Phase 0 and Phase 1 complete; Phase 2 stopped at P2-T6)

## Findings

### F-1 — Severity: Blocking — AC-2 timing threshold not met

- Evidence: `evidence/qa-gates/timing-comparison.2026-09-29T19-50.md` records `RATIO=2.60` against the plan's threshold of 4.00.
- Baseline median (P0-T10): 213.12 s (runs 214.04, 213.12, 213.02).
- Post-change median (P2-T5): 82.05 s (runs 82.05, 82.86, 69.8). The threshold requires a median of 53.28 s or less.

### Root cause (confirmed by orchestrator profiling)

The orchestrator timed the largest fixture (`tests/fixtures/blast_radius/historical-runs/followups-2026-09-27.json`) on the post-Phase-1 tree:

| Pass | Time |
| --- | --- |
| Detection only (`Test-BlastRadiusConflict` over 55 pairs) | 8.1 s |
| `Get-BlastRadiusConflictEdge`, tolerance key absent | 19.5 s |
| `Get-BlastRadiusConflictEdge`, AFTER config | 12.2 s |

About 11 s of each scheduling pass is spent in `Get-BlastRadiusPairCost` (`.claude/lib/blast-radius/BlastRadiusScheduling.psm1`). That function still runs the O(|A| x |B|) nested loop, calling the exported advanced function `Test-EntryOverlap` once per path pair and `Get-PathPairWeight` once per overlapping pair. Phase 1 made detection fast but left this loop unchanged, as design decision D1 intended.

## Required remediation (scope expansion: third production file)

1. In `.claude/lib/blast-radius/BlastRadiusConflict.psm1`, add and export one function that returns every overlapping path pair of two path collections. It must reuse the Phase 1 `ConvertTo-PathOverlapRecord` fast path and emit the pairs in the same order as the current nested loop: outer over A in input order, inner over B in input order, each pair carrying the entry from A first and the entry from B second, with no reordering by value.
   - Refactor `Get-SmallestPathOverlap` to reuse the shared enumeration where this keeps its output identical, so there is one overlap-decision implementation.
2. In `.claude/lib/blast-radius/BlastRadiusScheduling.psm1`, change `Get-BlastRadiusPairCost` to sum `Get-PathPairWeight` over the new function's pairs only. Keep the cost value identical for every input. `Get-PathPairWeight` may stay an advanced function, because it is then called only once per overlapping pair.
3. Sync the bundle mirrors of every touched module under `extensions/drm-copilot/resources/claude-customizations/.claude/lib/blast-radius/`.
4. Add Pester tests for the new function (order, empty inputs, all four glob/concrete cases, parity with `Test-EntryOverlap`) and a cost-equivalence test for `Get-BlastRadiusPairCost`. Do not edit any existing test or fixture.
5. AC-4 (existing export signatures unchanged): the export-surface check must compare the 64 baseline signatures, which must be unchanged, and list the single new export as the only addition. A plain whole-surface hash equality check is no longer the right assertion.
6. Keep the AC-2 threshold at 4.00. Then complete the original plan's remaining final-QC work (the P2-T1 through P2-T14 equivalents) on the final tree, including the full Pester suite, coverage delta, line counts, mirror identity, export surface, fixture immutability, bundle parity, and the reduced-audit handoff.

## Constraints

- `BlastRadiusScheduling.psm1` is 486 lines. The 500-line cap applies, so the change must not grow it by more than 14 lines; a net reduction is expected.
- Three production modules (`BlastRadiusGlob.psm1`, `BlastRadiusConflict.psm1`, `BlastRadiusScheduling.psm1`) are within the per-session PowerShell batch budget. Mirror writes go through `Copy-Item` via pwsh.
- The Python port is unchanged, and PowerShell results must stay identical to it.
