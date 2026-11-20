# PowerShell fail-open, pass-after (Issue #500)

Timestamp: 2026-08-22T00:10:00Z
Issue: #500
Task: [P7-T2]

Pairs with the fail-before artifact
`evidence/regression-testing/powershell-fail-open-repro.2026-08-21T23-12.md`.

EXIT_CODE: 0

## Run 1 — the research `## 5.3` and `## 5.4` pair, byte-identical to the fail-before run

Command: as recorded in the fail-before artifact, including the `BlastRadiusConfig.psm1` import that
exports `Get-ConfigRootSurface`.

Verbatim output:

```
=== research 5.3 : bundled truth table, separator-free root tokens ===
root surfaces  : package-lock.json, poetry.lock, quality-tiers.yml
x paths        : docs/features/active/2026-08-21-item-x/**
conflict       : False
=== research 5.4 : self-hosted positive control ===
conflict = True
  path_overlap : package-lock.json ~ package-lock.json
  shared_surface_overlap : package-lock.json
```

Output Summary for run 1:

- `Get-ConfigRootSurface -Config $bundled` now returns a **non-empty** set of three entries:
  `package-lock.json`, `poetry.lock`, `quality-tiers.yml`. In the fail-before run it returned the
  empty set. The root-token branch of `Get-PathTokenKind` is therefore reachable in a destination
  for the first time.
- `conflict : False` for this particular pair, and that is the CORRECT post-fix result rather than a
  residual defect. Research `## 5.3` cites `Directory.Build.targets` and `coverage.config`, and
  neither is a member of the bundled portable set. Root-surface membership is an exact ordinal match
  against the configured set by design (`Get-PathTokenKind` drops a separator-free token unless it
  is an exact member), so an unconfigured separator-free token is still correctly discarded. The
  fix opens the branch; it does not make every separator-free token a path.
- `conflict = True` for the self-hosted positive control, unchanged.

## Run 2 — the same 5.3 shape against a CONFIGURED separator-free root token

Because research `## 5.3` cites tokens outside the portable set, a second run against the bundled
table with a configured token is what demonstrates the restored behaviour. This is the same command
shape with one operand substituted.

Command:

```powershell
Set-Location 'C:\Users\DanMoisan\repos\drm-copilot-wt\2026-08-21T17-16'
Import-Module ./.claude/lib/blast-radius/BlastRadius.psm1 -Force
Import-Module ./.claude/lib/blast-radius/BlastRadiusConfig.psm1 -Force
$bundled = Get-Content -Raw ./extensions/drm-copilot/resources/claude-customizations/config/blast-radius.json | ConvertFrom-Json -AsHashtable
$plan3 = '- [ ] [P1-T1] Edit `package-lock.json`.'
$m = Get-BlastRadius -PlanText $plan3 -SpecText '' -FeatureFolder '2026-08-21-item-m' -Config $bundled -ComputedAt '2026-08-21T17-16'
$n = Get-BlastRadius -PlanText $plan3 -SpecText '' -FeatureFolder '2026-08-21-item-n' -Config $bundled -ComputedAt '2026-08-21T17-16'
"root surfaces  : $((Get-ConfigRootSurface -Config $bundled) -join ', ')"
"m paths        : $($m['paths'] -join ', ')"
$rm = Test-BlastRadiusConflict -RadiusA $m -RadiusB $n -Config $bundled
"conflict       : $($rm['conflict'])"
$rm['reasons'] | ForEach-Object { "  $($_['kind']) : $($_['detail'])" }
```

Verbatim output:

```
=== 5.3 variant : bundled table, a CONFIGURED separator-free root token ===
root surfaces  : package-lock.json, poetry.lock, quality-tiers.yml
m paths        : docs/features/active/2026-08-21-item-m/**, package-lock.json
conflict       : True
  path_overlap : package-lock.json ~ package-lock.json
  shared_surface_overlap : package-lock.json
```

Output Summary for run 2:

- `Get-ConfigRootSurface` returns the same non-empty three-entry set.
- The derived radius now carries `package-lock.json` as a real path alongside the feature-folder
  glob. In the fail-before run the paths list held the feature-folder glob only.
- `conflict : True` for the separator-free root-token pair, with **both** reasons:
  `path_overlap : package-lock.json ~ package-lock.json` and
  `shared_surface_overlap : package-lock.json`.
- This output is now identical to the research `## 5.4` self-hosted positive control, which is the
  behaviour the bundled table previously could not produce for any token.

## Fail-before / pass-after pairing

| Measurement | Fail-before | Pass-after |
| --- | --- | --- |
| `Get-ConfigRootSurface -Config $bundled` | empty | `package-lock.json, poetry.lock, quality-tiers.yml` |
| Radius paths for a configured root token | feature-folder glob only | feature-folder glob plus `package-lock.json` |
| `conflict` for a configured separator-free pair | `False` | `True` with `path_overlap` and `shared_surface_overlap` |
| Self-hosted positive control | `True` with both reasons | `True` with both reasons, unchanged |
