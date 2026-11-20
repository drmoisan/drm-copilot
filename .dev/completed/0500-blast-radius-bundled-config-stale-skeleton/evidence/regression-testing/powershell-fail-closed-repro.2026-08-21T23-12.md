# PowerShell fail-closed reproduction (Issue #500)

Timestamp: 2026-08-21T23:12:20Z
Issue: #500
Task: [P1-T6] — tagged `[expect-fail]`; reproducing the defect is the expected outcome.

Command:

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

(executed from the worktree root under PowerShell 7.6.5 via `pwsh -NoProfile -File`)

EXIT_CODE: 0
ExpectedExitCode: 0

The script exits 0 because it prints a verdict rather than asserting one. The defect is visible in
the printed output, not in the exit code.

## Verbatim output

```
=== research 5.1 : bundled truth table ===
conflict = True
  module_overlap : claude-runtime
=== research 5.2 : self-hosted negative control ===
False
```

Output Summary:

- **research 5.1, bundled truth table:** `conflict = True` with the single reason
  `module_overlap : claude-runtime`. Two work items citing entirely unrelated files under the
  `.claude` tree — a hook and a skill document — are forced to contend.
- **research 5.2, self-hosted negative control:** `False`. The same pair against
  `config/blast-radius.json` does not contend, because the self-hosted map carries no glob covering
  `.claude/**` after issue #489 removed the five umbrella modules.

Both observed results match the research artifact's predictions exactly.

## Attribution

The negative control is what makes this attributable. The contention relation, the extractor, the
normalizer, and the two plan texts are identical across 5.1 and 5.2; the only variable is which
truth table is supplied as `-Config`. The bundled table produces a false contention and the
self-hosted table does not, so the defect is a property of the **truth table** rather than of the
relation. That is the acceptance condition for [P1-T6].
