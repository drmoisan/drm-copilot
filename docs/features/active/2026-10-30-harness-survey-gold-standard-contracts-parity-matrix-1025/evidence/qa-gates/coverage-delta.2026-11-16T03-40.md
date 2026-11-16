# Coverage Delta (P4-T3)

Timestamp: 2026-11-16T03-40
Command: comparison of pester-baseline.2026-11-16T01-17.md (Phase 0 baseline) with final-pester.2026-11-16T03-40.md
EXIT_CODE: 0
Output Summary: repo-wide line coverage 96.04% at the Phase 0 baseline and 96.07% after the change (+0.03 points, no drop); the three new modules have no pre-change run and are judged against the 85% threshold (and the 90% new-code rule): 100.0%, 99.25%, 100.0%.

| Figure | Phase 0 baseline | Final gate |
| --- | --- | --- |
| Repo-wide line coverage | 96.04% (44785 covered, 1846 missed) | 96.07% (45204 covered, 1847 missed) |
| scripts/harness/HarnessInventory.psm1 | absent (new file) | 100.0% |
| scripts/harness/HarnessParityMatrix.psm1 | absent (new file) | 99.25% |
| scripts/harness/HarnessSkillContract.psm1 | absent (new file) | 100.0% |

New and changed code coverage: the three modules are the only new or changed production PowerShell files; their combined line coverage is at or above 99.25% per file. No other production file changed, so no per-file drop is possible elsewhere.

RepoWideAtOrAbove85: true (baseline 96.04%)
NewFilesAtOrAbove85: true
