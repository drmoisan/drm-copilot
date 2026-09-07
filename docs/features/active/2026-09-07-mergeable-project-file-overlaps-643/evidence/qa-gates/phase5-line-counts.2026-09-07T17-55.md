# Phase 5 QA gate — line counts

Timestamp: 2026-09-07T17-55

Command: `wc -l .claude/lib/project-file-merge/ProjectFileMergeGrammar.psm1 .claude/lib/project-file-merge/ProjectFileMerge.psm1 .claude/lib/project-file-merge/Resolve-MergeableConflict.ps1 extensions/drm-copilot/resources/claude-customizations/.claude/lib/project-file-merge/ProjectFileMergeGrammar.psm1 extensions/drm-copilot/resources/claude-customizations/.claude/lib/project-file-merge/ProjectFileMerge.psm1 extensions/drm-copilot/resources/claude-customizations/.claude/lib/project-file-merge/Resolve-MergeableConflict.ps1 tests/scripts/claude-lib/project-file-merge/ProjectFileMergeGrammar.Tests.ps1 tests/scripts/claude-lib/project-file-merge/ProjectFileMerge.Tests.ps1 tests/scripts/claude-lib/project-file-merge/Resolve-MergeableConflict.Tests.ps1 tests/scripts/claude-lib/project-file-merge/ProjectFileMerge.Manifest.Tests.ps1 scripts/powershell/PoshQC/settings/pester.runsettings.psd1`

EXIT_CODE: 0

Output Summary: All eleven counts are at or below the 500-line ceiling of
`.claude/rules/general-code-change.md`; the highest is 355. The
`Resolve-MergeableConflict.Tests.ps1` count is 232, at or below the 320-line
bound stated by [P5-T10]. Each of the three mirror counts equals its self-hosted
count.

## The eleven counts

| File | Lines |
| --- | --- |
| `.claude/lib/project-file-merge/ProjectFileMergeGrammar.psm1` | 318 |
| `.claude/lib/project-file-merge/ProjectFileMerge.psm1` | 355 |
| `.claude/lib/project-file-merge/Resolve-MergeableConflict.ps1` | 226 |
| `extensions/drm-copilot/resources/claude-customizations/.claude/lib/project-file-merge/ProjectFileMergeGrammar.psm1` | 318 |
| `extensions/drm-copilot/resources/claude-customizations/.claude/lib/project-file-merge/ProjectFileMerge.psm1` | 355 |
| `extensions/drm-copilot/resources/claude-customizations/.claude/lib/project-file-merge/Resolve-MergeableConflict.ps1` | 226 |
| `tests/scripts/claude-lib/project-file-merge/ProjectFileMergeGrammar.Tests.ps1` | 194 |
| `tests/scripts/claude-lib/project-file-merge/ProjectFileMerge.Tests.ps1` | 263 |
| `tests/scripts/claude-lib/project-file-merge/Resolve-MergeableConflict.Tests.ps1` | 232 |
| `tests/scripts/claude-lib/project-file-merge/ProjectFileMerge.Manifest.Tests.ps1` | 81 |
| `scripts/powershell/PoshQC/settings/pester.runsettings.psd1` | 268 |

## Mirror equality

| Pair | Self-hosted | Mirror | Equal |
| --- | --- | --- | --- |
| `ProjectFileMergeGrammar.psm1` | 318 | 318 | yes |
| `ProjectFileMerge.psm1` | 355 | 355 | yes |
| `Resolve-MergeableConflict.ps1` | 226 | 226 | yes |

## Per-task bounds also satisfied

| Bound | Stated in | Observed |
| --- | --- | --- |
| `ProjectFileMergeGrammar.psm1` at most 320 | [P5-T1] | 318 |
| `ProjectFileMerge.psm1` at most 400 | [P5-T2] | 355 |
| `Resolve-MergeableConflict.ps1` at most 260 | [P5-T3] | 226 |
| `ProjectFileMergeGrammar.Tests.ps1` at most 330 | [P5-T8] | 194 |
| `ProjectFileMerge.Tests.ps1` at most 420 | [P5-T9] | 263 |
| `Resolve-MergeableConflict.Tests.ps1` at most 320 | [P5-T10] | 232 |
| `ProjectFileMerge.Manifest.Tests.ps1` at most 110 | [P5-T11] | 81 |
