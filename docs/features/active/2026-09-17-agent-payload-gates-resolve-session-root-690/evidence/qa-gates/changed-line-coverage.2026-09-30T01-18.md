# Changed-Line Coverage Against BASE_SHA (P12-T12)

Timestamp: 2026-09-30T01-18
Command: sh SCRATCH/run-ps.sh SCRATCH/changed-line-coverage.ps1 -CoverageReportPath SCRATCH/cov-<group>-final.txt -BaseRef 91805f15ddc5930759d877cf6147467096ad91fe -File <group production files> (once per coverage group)
EXIT_CODE: 0
Output Summary:
- CHANGED-COVERAGE file=.claude/lib/worktree-resolution/WorktreeRunResolution.psm1 ChangedLines=493 ChangedAnalyzed=146 ChangedCovered=146 ChangedPercent=100
- CHANGED-COVERAGE file=.claude/lib/worktree-resolution/WorktreeItemResolution.psm1 ChangedLines=19 ChangedAnalyzed=0 ChangedCovered=0 ChangedPercent=NA
- CHANGED-COVERAGE file=.claude/lib/worktree-resolution/EpicScopeResolution.psm1 ChangedLines=53 ChangedAnalyzed=19 ChangedCovered=18 ChangedPercent=94.74
- CHANGED-COVERAGE file=.claude/hooks/enforce-orchestration-preimplementation-gate.ps1 ChangedLines=21 ChangedAnalyzed=12 ChangedCovered=12 ChangedPercent=100
- CHANGED-COVERAGE file=.claude/hooks/enforce-orchestration-preimplementation-gate-epic-scope.ps1 ChangedLines=179 ChangedAnalyzed=47 ChangedCovered=47 ChangedPercent=100
- CHANGED-COVERAGE file=.claude/hooks/enforce-epic-wave-barrier.ps1 ChangedLines=58 ChangedAnalyzed=14 ChangedCovered=14 ChangedPercent=100
- CHANGED-COVERAGE file=.claude/hooks/enforce-parallel-cohort-barrier.ps1 ChangedLines=58 ChangedAnalyzed=14 ChangedCovered=14 ChangedPercent=100
- CHANGED-COVERAGE file=.claude/hooks/enforce-epic-merge-gate.ps1 ChangedLines=42 ChangedAnalyzed=22 ChangedCovered=22 ChangedPercent=100
- CHANGED-COVERAGE file=.claude/hooks/enforce-epic-merge-gate-resolution.ps1 ChangedLines=221 ChangedAnalyzed=36 ChangedCovered=32 ChangedPercent=88.89
- CHANGED-COVERAGE file=.claude/hooks/enforce-epic-worktree-removal-gate.ps1 ChangedLines=36 ChangedAnalyzed=15 ChangedCovered=15 ChangedPercent=100
- CHANGED-COVERAGE file=.claude/hooks/enforce-epic-worktree-removal-gate-resolution.ps1 ChangedLines=144 ChangedAnalyzed=23 ChangedCovered=22 ChangedPercent=95.65
- CHANGED-COVERAGE file=.claude/hooks/enforce-parallel-worktree-removal-gate.ps1 ChangedLines=114 ChangedAnalyzed=33 ChangedCovered=31 ChangedPercent=93.94
- CHANGED-COVERAGE file=.claude/hooks/enforce-parallel-drift-gate.ps1 ChangedLines=59 ChangedAnalyzed=15 ChangedCovered=15 ChangedPercent=100
- 13 CHANGED-COVERAGE lines, none MISSING.
- The 12 files other than WIR each have a numeric ChangedPercent of at least 85 (minimum: MRGR 88.89).
- WIR: ChangedAnalyzed=0 ChangedPercent=NA; no executable changed line; the export is verified by T-REC X2 (P1-T12).
