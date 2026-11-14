# Baseline Line Counts (post-#1006)

Timestamp: 2026-10-31T15-05
Command: poetry run python SCRATCH/issue-1013-lines.py <files> (physical lines, `len(text.splitlines())`)
EXIT_CODE: 0
Output Summary: eleven files measured; facade exports 14 functions; committed tolerance and token-shape count recorded below.

| File | Physical lines |
|---|---|
| `scripts/dev_tools/_blast_radius_scheduling.py` | 495 |
| `.claude/lib/blast-radius/BlastRadiusScheduling.psm1` | 483 |
| `.claude/lib/blast-radius/BlastRadius.psm1` | 479 |
| `tests/scripts/claude-lib/blast-radius/BlastRadius.Tests.ps1` | 492 |
| `tests/scripts/claude-lib/blast-radius/BlastRadiusScheduling.Tests.ps1` | 372 |
| `tests/scripts/claude-hooks/enforce-model-routing-receipt.AuthorAsserted.Tests.ps1` | 267 |
| `tests/scripts/dev_tools/test_blast_radius_scheduling.py` | 428 |
| `tests/scripts/dev_tools/test_validate_parallel_state_tolerated_edge_fields.py` | 99 |
| `tests/scripts/dev_tools/test_blast_radius_config_tolerance_keys.py` | 159 |
| `extensions/drm-copilot/test/lib/validate/parallel-state-tolerated-edge-fields.test.ts` | 195 |
| `extensions/drm-copilot/test/lib/push-down/config-carriage.test-helpers.ts` | 272 |

## Facade export set (`Export-ModuleMember -Function` in `.claude/lib/blast-radius/BlastRadius.psm1`)

Count: 14

`Get-PlanPaths`, `Get-BlastRadius`, `Get-NormalizedDeclaredRadius`, `Get-BlastRadiusFromObservedPaths`, `Test-BlastRadius`, `Test-BlastRadiusConflict`, `Get-BlastRadiusConflictEdge`, `Get-BlastRadiusPairDecision`, `Test-WriteIntentExtractionEnabled`, `Get-ConfigPathRoot`, `Get-WriteIntentPlanPath`, `Get-WriteIntentSpecContract`, `Select-WriteIntentPathEntry`, `Get-PlanPathForConfig`

## `COMMITTED_CONFLICT_TOLERANCE` in `tests/scripts/dev_tools/test_blast_radius_config_tolerance_keys.py`

`tolerance_percent` 100; `weights` `{"same_file": 8, "possible_overlap": 2, "append_only": 1, "module": 2}`; `band_durations` `{"C1": 1, "C2": 2, "C3": 4, "C4": 8}`; `default_band` `"C1"`; `append_only_paths` `["**/CHANGELOG.md", PACK_MANIFEST_REGISTRY, "quality-tiers.yml"]`.

## Token-shape count (`.claude/rules/parallel-orchestration.md`, paragraph under `### Read-by-mandate classification` beginning `The extractor additionally rejects`)

Count: five ("rejects five token shapes").
