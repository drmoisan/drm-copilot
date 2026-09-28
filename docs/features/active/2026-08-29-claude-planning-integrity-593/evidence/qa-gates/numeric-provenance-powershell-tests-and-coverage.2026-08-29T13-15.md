Timestamp: 2026-08-29T13-54
Command: `$configuration = New-PesterConfiguration; $configuration.Run.Path = @('tests/scripts/claude-hooks/validate-task-researcher-output.Tests.ps1','tests/scripts/claude-hooks/validate-prd-feature-output.Tests.ps1'); $configuration.CodeCoverage.Enabled = $true; $configuration.CodeCoverage.Path = @('.claude/hooks/validate-task-researcher-output.ps1','.claude/hooks/validate-prd-feature-output.ps1'); $configuration.CodeCoverage.OutputFormat = 'JaCoCo'; $configuration.CodeCoverage.OutputPath = 'docs/features/active/2026-08-29-claude-planning-integrity-593/evidence/qa-gates/numeric-provenance-pester-post.2026-08-29T13-15.xml'; $configuration.Run.PassThru = $true; Invoke-Pester -Configuration $configuration`
EXIT_CODE: 0
Output Summary: 47 passed, 0 failed. JaCoCo line coverage retained or exceeded both P0-T3 per-file baselines and each changed hook exceeded the 85% production line-coverage threshold.

| Hook | P0-T3 eligible | P0-T3 covered | P0-T3 missed | P0-T3 | P4-T3 eligible | P4-T3 covered | P4-T3 missed | P4-T3 | Verdict |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | --- |
| `.claude/hooks/validate-task-researcher-output.ps1` | 80 | 71 | 9 | 88.75% | 100 | 90 | 10 | 90.00% | Pass: no regression; >=85% |
| `.claude/hooks/validate-prd-feature-output.ps1` | 32 | 29 | 3 | 90.62% | 48 | 45 | 3 | 93.75% | Pass: no regression; >=85% |

JaCoCo XML: `docs/features/active/2026-08-29-claude-planning-integrity-593/evidence/qa-gates/numeric-provenance-pester-post.2026-08-29T13-15.xml`

## PRD hook new-production coverage

Reviewed head: `4c87251f2783c0e4383fe33545fd8b8df5eded53`.

`git diff --unified=0 4c87251f2783c0e4383fe33545fd8b8df5eded53 -- .claude/hooks/validate-prd-feature-output.ps1` identifies new source lines 29-39, 41-48, and 50-57. JaCoCo reports lines 31-34 as declaration-only and therefore non-instrumented; they are not eligible line-coverage locations. The eligible new-production line set is 29, 30, 35-39, 41-48, and 50-57. JaCoCo recorded at least one covered instruction for every eligible line.

| New-production eligible lines | Covered | Missed | Line coverage | Verdict |
| ---: | ---: | ---: | ---: | --- |
| 23 | 23 | 0 | 100.00% | Pass: >=90%; every new validation path is covered |
