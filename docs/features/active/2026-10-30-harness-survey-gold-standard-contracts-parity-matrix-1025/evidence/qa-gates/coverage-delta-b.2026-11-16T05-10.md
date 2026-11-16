# Coverage Delta, Plan B (P2-T3)

Timestamp: 2026-11-16T05-10
Command: read of evidence/baseline/pester-baseline-b.2026-11-16T04-14.md and evidence/qa-gates/final-pester-b.2026-11-16T05-10.md; git diff --name-only <PlanBStart> filtered to .ps1 and .psm1 files outside tests/ (PlanBStart from evidence/baseline/phase0b-branch-snapshot.2026-11-16T03-56.md)
EXIT_CODE: 0
Output Summary: repo-wide line coverage 96.07% at baseline and 96.07% after; harness modules unchanged at 100.00%, 99.25% and 100.00%, each at or above 85% and not below baseline; no PowerShell production file changed since PlanBStart. Branch coverage is not measured for PowerShell.

| Figure | Phase 0 baseline (pester-baseline-b) | Post-change (final-pester-b) | Delta |
| --- | --- | --- | --- |
| Repo-wide line coverage | 96.07% (45204 covered, 1847 missed) | 96.07% (45204 covered, 1847 missed) | 0.00 |
| scripts/harness/HarnessInventory.psm1 | 100.00% | 100.00% | 0.00 |
| scripts/harness/HarnessParityMatrix.psm1 | 99.25% | 99.25% | 0.00 |
| scripts/harness/HarnessSkillContract.psm1 | 100.00% | 100.00% | 0.00 |

New or changed code coverage: not applicable; plan B changes no production code (JSON and Markdown only).

ChangedProductionFiles: 0
RepoWideNoDrop: true
HarnessModulesNoDrop: true
