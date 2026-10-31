# Preflight Fixes

Timestamp: 2026-10-30T11-45
Plan: docs/features/active/2026-10-30-parallel-scheduling-false-hard-edges-from-shared-surface-and-sheet1-1006/plan.2026-10-30T06-58.md

## Fix 1: [P1-T2]

- Defect class: validator-blind unsatisfiable acceptance wording; the correction keeps the assertion's meaning.
- Finding: `ConflictEdge` in `scripts/dev_tools/_blast_radius_scheduling.py` carries only the first reason kind in `reason`. `conflicts` in `scripts/dev_tools/_blast_radius_conflicts.py` emits `path_overlap` first, and in the scenario both radii carry `quality-tiers.yml` in `paths`. A failure message built from edge `reason` values would therefore name only `path_overlap`, not the `contract_dependency` or `shared_surface_overlap` kind that the acceptance condition and AC-09 require.
- Change: the failure message now lists, for each hard edge, the reason kinds that `conflicts` reports for that pair. The asserted condition (no edge has `hard` true) is unchanged.

## Fix 2: [P1-T3]

- Defect class: citation correction.
- Finding: `BlastRadiusTokenShape.Tests.ps1` imports only `BlastRadiusExtraction.psm1`, so it does not show how to import the facade. The facade `BlastRadius.psm1` does not export `Get-ContractIdentifier`. `Test-GenericContractToken` is reachable through `BlastRadiusExtraction.psm1` only after P3-T2, but P3-T1's acceptance requires the predicate and parity rows to pass before P3-T2 runs.
- Change: the task now imports the facade first, then `BlastRadiusNormalization.psm1` and `BlastRadiusTokenShape.psm1` directly, following the facade-first order of `BlastRadiusNormalization.Tests.ps1`. The rows and their assertions are unchanged.

## Fix 3: [P1-T4]

- Defect class: validator-blind unsatisfiable acceptance wording; the correction keeps the assertion's meaning.
- Finding: the Pester edge record built by `Get-BlastRadiusConflictEdge` carries `reason = $decision['reason']`, which is the first reason kind, `path_overlap`, in the scenario. The acceptance condition required a `reason` of `contract_dependency` or `shared_surface_overlap`.
- Change: the acceptance now requires a failure on an edge whose `hard` is true, with the failure message listing the `Test-BlastRadiusConflict` reason kinds for that pair, including `contract_dependency` or `shared_surface_overlap`.

## Fix 4: [P8-T17]

- Defect class: validator-blind unsatisfiable scope assertion; the correction keeps the assertion's meaning.
- Finding: the branch already carries the staged issue-promotion record `docs/features/potential/promoted/2026-10-30-parallel-scheduling-false-hard-edges-from-shared-surface-and-sheet1.md`. That file is neither a File Inventory file nor a `FEATURE` document, so the combined listing could never consist only of those.
- Change: the scope check now names that promotion record as the single permitted additional path.
