# Phase 0 — Coverage-Bearing Pester Baseline (issue #554)

Timestamp: 2026-08-26T10-18

Command:

```powershell
Import-Module ./scripts/powershell/PoshQC/PoshQC.psd1 -Force
Invoke-PoshQCTest -Root (Get-Location).Path -SettingsPath 'scripts/powershell/PoshQC/settings/pester.runsettings.psd1'
```

EXIT_CODE: 0

Output Summary:

| Metric | Value |
| --- | --- |
| Tests passed | **3673** |
| Tests failed | **0** |
| Tests skipped | 9 |
| Tests inconclusive | 0 |
| Tests not run | 0 |
| Wall time | 194.13 s |

Coverage headline, as printed by the run:

```text
Covered 94.59% / 0%. 10,033 analyzed Commands in 86 Files.
```

The printed 94.59% is Pester's **command (instruction)** coverage. The **line-coverage** headline
percentage required by this task was read from the JaCoCo counters at the report root of the run's
own coverage artifact `artifacts/pester/powershell-coverage.xml`:

| Counter | Covered | Missed | Percentage |
| --- | --- | --- | --- |
| INSTRUCTION | 9490 | 543 | 94.59% |
| **LINE** | **6908** | **368** | **94.94%** |
| METHOD | 594 | 33 | 94.74% |
| CLASS | 86 | 0 | 100.00% |

**Baseline line coverage: 94.94%.** This is comfortably above the 85% uniform threshold in
`.claude/rules/quality-tiers.md`. Pester measures no branch coverage, so no branch-coverage value is
recorded and none is required.

The run also wrote `artifacts/pester/powershell-coverage.koverage.xml` and
`artifacts/pester/pester-junit.xml`. All three are under the gitignored `/artifacts` tree and never
appear in a diff.

The self-hosted invocation was used rather than the MCP PoshQC test runner because the MCP runner
reads its settings from the installed extension. That distinction is not yet material at baseline (no
new `CodeCoverage.Path` entry exists yet) but the same invocation is required at P4-T11 and P6-T4, so
the baseline is captured the same way for a like-for-like comparison.
