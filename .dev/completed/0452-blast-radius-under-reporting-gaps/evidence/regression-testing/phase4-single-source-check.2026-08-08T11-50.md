# Phase 4 — Single-Source Verification (no second hardcoded surface list in PowerShell)

Timestamp: 2026-08-08T11-50
Task: [P4-T7]

Command: `rg -n "poetry\.lock|package-lock\.json|quality-tiers\.yml" .claude/lib/blast-radius/`

EXIT_CODE: 1 (ripgrep exits 1 for "no matches found", which is the required result)

## Raw output

No output. Zero matches across all five `.claude/lib/blast-radius/*.psm1` modules.

## What this proves

None of the three separator-free surface names appears as a literal anywhere in the PowerShell
production tree. The separator-free acceptance set therefore has exactly one source in PowerShell:
`Get-ConfigRootSurface` in `.claude/lib/blast-radius/BlastRadiusConfig.psm1`, which reads
`Get-ConfigStringList -Config $Config -Key $script:ConfigSharedSurfaceKey` (the existing
`'shared_surfaces'` constant) and filters to entries with no `/`. It contains no literal surface
name of its own and does not read `shared_surface_globs`.

This mirrors the Python result recorded at [P3-T8], where the same `rg` pattern over
`scripts/dev_tools/` also returned zero matches. Both languages therefore satisfy the same
single-source constraint through structurally identical readers:

| Language | Reader | Source key | Literal surface names in production |
| --- | --- | --- | ---: |
| Python | `config_root_surfaces(config)` | `config["shared_surfaces"]` | 0 |
| PowerShell | `Get-ConfigRootSurface -Config` | `$script:ConfigSharedSurfaceKey` (`shared_surfaces`) | 0 |

The three strings remain present only in `config/blast-radius.json` (unmodified) and in tests and
fixtures.

Output Summary: `rg` exits 1 with zero matches under `.claude/lib/blast-radius/`. No second
hardcoded surface list was introduced in any PowerShell production module. `Get-ConfigRootSurface`
sources only from the config `shared_surfaces` list and is the sole source of separator-free
acceptance in PowerShell.
