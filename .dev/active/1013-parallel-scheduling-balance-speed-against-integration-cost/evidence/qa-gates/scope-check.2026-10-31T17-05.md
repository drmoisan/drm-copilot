# QA Gate — Scope Check

Timestamp: 2026-10-31T17-05
Command: poetry run python SCRATCH/issue-1013-scope.py (MB = git merge-base origin/main HEAD; git diff --name-status MB HEAD plus git status --porcelain compared with the 76 entries of spec.md `## Complete File List` and its "Files deliberately not written" list; Python symbols compared by AST between MB and the working tree; PowerShell functions compared by text)
EXIT_CODE: 0
Output Summary: zero out-of-scope paths; zero changes to decide_pair, pair_benefit, HARD_REASON_KINDS, Get-BlastRadiusPairDecision, Get-BlastRadiusPairBenefit, and $script:HardReasonKind; the only change inside pair_cost and Get-BlastRadiusPairCost is the D-7 contract term and its documentation.

## Paths

- Declared write set: 76 entries parsed from `spec.md` `## Complete File List`.
- Changed paths (committed diff plus working tree): 127; working-tree entries: 7 (this run's evidence files and the plan check-offs, all under the feature folder).
- Out of scope (neither declared, nor under the feature folder, nor the promoted lifecycle record `docs/features/potential/promoted/2026-10-30-parallel-scheduling-balance-speed-against-integration-cost.md`): none.
- Declared entries not changed: none (all 76 are in the diff).
- "Files deliberately not written" and the not-written classes (`.github/`, `.codex/`, `.agents/`, the execution-environment brief copies, parallel validator modules, `scripts/dev_tools/compute_blast_radius.py`, `scripts/dev_tools/_parallel_drift_scheduling.py`, `scripts/dev_tools/_blast_radius_conflicts.py`, `.claude/hooks/enforce-model-routing-receipt.ps1`, the epic files, `quality-tiers.yml`): none present.

## Symbols

| Symbol | File | Result |
|---|---|---|
| `decide_pair` | `scripts/dev_tools/_blast_radius_scheduling.py` | unchanged |
| `pair_benefit` | `scripts/dev_tools/_blast_radius_scheduling.py` | unchanged |
| `HARD_REASON_KINDS` | `scripts/dev_tools/_blast_radius_scheduling.py` | unchanged |
| `Get-BlastRadiusPairDecision` | `.claude/lib/blast-radius/BlastRadiusScheduling.psm1` | unchanged |
| `Get-BlastRadiusPairBenefit` | `.claude/lib/blast-radius/BlastRadiusScheduling.psm1` | unchanged |
| `$script:HardReasonKind` | `.claude/lib/blast-radius/BlastRadiusScheduling.psm1` | unchanged |
| `pair_cost` | `scripts/dev_tools/_blast_radius_scheduling.py` | docstring return text plus `shared_contracts` and the `weights['contract'] * len(shared_contracts)` term only |
| `Get-BlastRadiusPairCost` | `.claude/lib/blast-radius/BlastRadiusScheduling.psm1` | help text plus the ordinal `HashSet` intersection and the `weights['contract'] * Count` term only |
| `conflicts` | `scripts/dev_tools/_blast_radius_conflicts.py` | file not in the diff |
