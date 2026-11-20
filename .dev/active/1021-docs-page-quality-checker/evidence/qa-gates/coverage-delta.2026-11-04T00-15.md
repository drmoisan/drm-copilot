# Coverage Delta - Issue #1021

Timestamp: 2026-11-04T00-15
Task: [P6-T7]
Command: comparison of `baseline-pester-coverage.2026-11-03T22-19.md` ([P0-T8]), `qa-pester-coverage.2026-11-03T23-42.md` ([P6-T3]) and `isolation-single-process.2026-11-04T00-15.md` ([P6-T6]); all figures read from `artifacts/pester/powershell-coverage.xml` of those branch-current `Invoke-PoshQCTest` runs
EXIT_CODE: 0
Output Summary: overall line coverage over `tests/scripts` 92.66% (baseline) to 92.88% (post-change); each of the seven new modules is at 100.00% (floor 85); `Invoke-DocsCommand.ps1` 87.33% to 87.42%, `DocsSchema.psm1` 100.00% to 100.00%, `DocsProfileCommands.psm1` 97.10% to 97.30% (none lower). Result: PASS. No branch figure is recorded (Pester measures no branch coverage).

## Overall (both over `tests/scripts`)

| Measure | Baseline ([P0-T8]) | Post-change ([P6-T6]) | Change |
|---|---|---|---|
| Line coverage | 92.66% (21914 of 23651) | 92.88% (22666 of 24403) | +0.22 points |

## New modules (floor 85%)

| Module | [P6-T3] (`tests/scripts/claude-lib`) | [P6-T6] (`tests/scripts`) | Status |
|---|---|---|---|
| `DocsPageMarkdown.psm1` | 100.00% (102 of 102) | 100.00% (102 of 102) | PASS |
| `DocsPageFrontMatter.psm1` | 100.00% (180 of 180) | 100.00% (180 of 180) | PASS |
| `DocsPageMetadata.psm1` | 100.00% (109 of 109) | 100.00% (109 of 109) | PASS |
| `DocsPageLinks.psm1` | 100.00% (114 of 114) | 100.00% (114 of 114) | PASS |
| `DocsPageDiataxis.psm1` | 100.00% (54 of 54) | 100.00% (54 of 54) | PASS |
| `DocsPageOrphans.psm1` | 100.00% (28 of 28) | 100.00% (28 of 28) | PASS |
| `DocsPageCheck.psm1` | 100.00% (157 of 157) | 100.00% (157 of 157) | PASS |

Baseline for the new modules: not present ([P0-T8] records that no `DocsPage*` module existed).

## Edited 1020 files (post-change not lower)

| File | Baseline ([P0-T8]) | Post-change ([P6-T6]) | Status |
|---|---|---|---|
| `Invoke-DocsCommand.ps1` | 87.33% (131 of 150) | 87.42% (132 of 151) | PASS (the added dispatch row is covered) |
| `DocsSchema.psm1` | 100.00% (127 of 127) | 100.00% (129 of 129) | PASS |
| `DocsProfileCommands.psm1` | 97.10% (67 of 69) | 97.30% (72 of 74) | PASS (the five added rows are covered) |
