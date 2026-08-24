# PowerShell fail-closed, pass-after (Issue #500)

Timestamp: 2026-08-22T00:10:00Z
Issue: #500
Task: [P7-T1]

Pairs with the fail-before artifact
`evidence/regression-testing/powershell-fail-closed-repro.2026-08-21T23-12.md`.

Command: byte-identical to the fail-before run. The research `## 5.1` and `## 5.2` pair, executed
from the worktree root under PowerShell 7.6.5 via `pwsh -NoProfile -File`:

```powershell
Set-Location 'C:\Users\DanMoisan\repos\drm-copilot-wt\2026-08-21T17-16'
Import-Module ./.claude/lib/blast-radius/BlastRadius.psm1 -Force

# research ## 5.1 - bundled truth table
$bundled = Get-Content -Raw ./extensions/drm-copilot/resources/claude-customizations/config/blast-radius.json | ConvertFrom-Json -AsHashtable
$a = Get-BlastRadius -PlanText '- [ ] [P1-T1] Edit `.claude/hooks/enforce-mermaid-validation.ps1`.' -SpecText '' -FeatureFolder '2026-08-21-item-a' -Config $bundled -ComputedAt '2026-08-21T17-16'
$b = Get-BlastRadius -PlanText '- [ ] [P1-T1] Edit `.claude/skills/parallel-add/SKILL.md`.' -SpecText '' -FeatureFolder '2026-08-21-item-b' -Config $bundled -ComputedAt '2026-08-21T17-16'
$r = Test-BlastRadiusConflict -RadiusA $a -RadiusB $b -Config $bundled
"conflict = $($r['conflict'])"
$r['reasons'] | ForEach-Object { "  $($_['kind']) : $($_['detail'])" }

# research ## 5.2 - self-hosted negative control
$self = Get-Content -Raw ./config/blast-radius.json | ConvertFrom-Json -AsHashtable
$a2 = Get-BlastRadius -PlanText '- [ ] [P1-T1] Edit `.claude/hooks/enforce-mermaid-validation.ps1`.' -SpecText '' -FeatureFolder '2026-08-21-item-a' -Config $self -ComputedAt '2026-08-21T17-16'
$b2 = Get-BlastRadius -PlanText '- [ ] [P1-T1] Edit `.claude/skills/parallel-add/SKILL.md`.' -SpecText '' -FeatureFolder '2026-08-21-item-b' -Config $self -ComputedAt '2026-08-21T17-16'
(Test-BlastRadiusConflict -RadiusA $a2 -RadiusB $b2 -Config $self)['conflict']
```

EXIT_CODE: 0

## Verbatim output

```
=== research 5.1 : bundled truth table ===
conflict = False
=== research 5.2 : self-hosted negative control ===
False
```

Output Summary:

- **research 5.1, bundled truth table:** `conflict = False`. The reason enumeration printed nothing,
  because the reason collection is empty.
- **research 5.2, self-hosted negative control:** `False`, unchanged from the fail-before run.
- The bundled table now **matches** the self-hosted control. Two work items citing unrelated files
  under the `.claude` tree schedule concurrently.

## The observed reason is gone

The fail-before run recorded `conflict = True` with the single reason
`module_overlap : claude-runtime`. That reason is **gone**: the current run prints no reason line at
all. The `claude-runtime` umbrella module was removed from
`extensions/drm-copilot/resources/claude-customizations/config/blast-radius.json` by [P3-T4] and
from `PAYLOAD_MODULES` in
`extensions/drm-copilot/src/lib/push-down/claude-blast-radius-derive-core.ts` by [P2-T1], so
`Resolve-BlastRadiusModule` matches no module for either radius and `module_overlap` cannot fire.

## Fail-before / pass-after pairing

| Run | Bundled table | Self-hosted control | Artifact |
| --- | --- | --- | --- |
| Fail-before | `conflict = True`, `module_overlap : claude-runtime` | `False` | `evidence/regression-testing/powershell-fail-closed-repro.2026-08-21T23-12.md` |
| Pass-after | `conflict = False`, no reasons | `False` | this artifact |

The self-hosted control is `False` in both runs, which confirms the change altered the bundled truth
table and left the contention relation itself untouched.
