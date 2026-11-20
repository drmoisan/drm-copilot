# PowerShell fail-open reproduction (Issue #500)

Timestamp: 2026-08-21T23:12:20Z
Issue: #500
Task: [P1-T7] — tagged `[expect-fail]`; reproducing the defect is the expected outcome.

Command:

```powershell
Set-Location 'C:\Users\DanMoisan\repos\drm-copilot-wt\2026-08-21T17-16'
Import-Module ./.claude/lib/blast-radius/BlastRadius.psm1 -Force
Import-Module ./.claude/lib/blast-radius/BlastRadiusConfig.psm1 -Force
$bundled = Get-Content -Raw ./extensions/drm-copilot/resources/claude-customizations/config/blast-radius.json | ConvertFrom-Json -AsHashtable
$self = Get-Content -Raw ./config/blast-radius.json | ConvertFrom-Json -AsHashtable

# research ## 5.3 - bundled truth table, separator-free root tokens
$plan = '- [ ] [P1-T1] Edit `Directory.Build.targets` and `coverage.config`.'
$x = Get-BlastRadius -PlanText $plan -SpecText '' -FeatureFolder '2026-08-21-item-x' -Config $bundled -ComputedAt '2026-08-21T17-16'
$y = Get-BlastRadius -PlanText $plan -SpecText '' -FeatureFolder '2026-08-21-item-y' -Config $bundled -ComputedAt '2026-08-21T17-16'
"root surfaces  : $((Get-ConfigRootSurface -Config $bundled) -join ', ')"
"x paths        : $($x['paths'] -join ', ')"
"conflict       : $((Test-BlastRadiusConflict -RadiusA $x -RadiusB $y -Config $bundled)['conflict'])"

# research ## 5.4 - self-hosted positive control
$plan2 = '- [ ] [P1-T1] Edit `package-lock.json`.'
$p = Get-BlastRadius -PlanText $plan2 -SpecText '' -FeatureFolder '2026-08-21-item-p' -Config $self -ComputedAt '2026-08-21T17-16'
$q = Get-BlastRadius -PlanText $plan2 -SpecText '' -FeatureFolder '2026-08-21-item-q' -Config $self -ComputedAt '2026-08-21T17-16'
$rr = Test-BlastRadiusConflict -RadiusA $p -RadiusB $q -Config $self
"conflict = $($rr['conflict'])"
$rr['reasons'] | ForEach-Object { "  $($_['kind']) : $($_['detail'])" }
```

(executed from the worktree root under PowerShell 7.6.5 via `pwsh -NoProfile -File`)

The research artifact's 5.3 listing imports only `BlastRadius.psm1`. `Get-ConfigRootSurface` is
exported by `.claude/lib/blast-radius/BlastRadiusConfig.psm1`, not by `BlastRadius.psm1`, so the
first execution reported `The term 'Get-ConfigRootSurface' is not recognized`. Adding the
`BlastRadiusConfig.psm1` import is a mechanical correction to the reproduction harness only; it
changes no repository file, and the three printed values were identical in both executions.

EXIT_CODE: 0
ExpectedExitCode: 0

The script exits 0 because it prints values rather than asserting them. The defect is visible in the
printed output, not in the exit code.

## Verbatim output

```
=== research 5.3 : bundled truth table, separator-free root tokens ===
root surfaces  : 
x paths        : docs/features/active/2026-08-21-item-x/**
conflict       : False
=== research 5.4 : self-hosted positive control ===
conflict = True
  path_overlap : package-lock.json ~ package-lock.json
  shared_surface_overlap : package-lock.json
```

Output Summary:

- **research 5.3, bundled truth table:** `Get-ConfigRootSurface -Config $bundled` returns an
  **empty** root-surface set, so `Get-PathTokenKind` drops every separator-free token before
  resolution. The radius for item x carries only the unconditionally added feature-folder glob
  `docs/features/active/2026-08-21-item-x/**`; neither `Directory.Build.targets` nor
  `coverage.config` survives. `conflict : False`.
- **research 5.4, self-hosted positive control:** `conflict = True` with both
  `path_overlap : package-lock.json ~ package-lock.json` and
  `shared_surface_overlap : package-lock.json`. `package-lock.json` is a separator-free shared
  surface in `config/blast-radius.json`, so `Get-ConfigRootSurface` admits it and the extractor
  accepts the token.

Both observed results match the research artifact's predictions exactly.

## Attribution

The bundled table declares no separator-free `shared_surfaces` entry, and the separator-free entry
set is the sole gate on whether the extractor accepts a separator-free token at all. The self-hosted
control produces the behaviour the bundled table cannot produce for any token, which is the positive
control for the fix and the acceptance condition for [P1-T7].
