# P8-T9 Changed-line coverage against BASE_SHA

Timestamp: 2026-10-09T00-55
Command: sh SCRATCH/run-ps.sh SCRATCH/changed-line-coverage.ps1 -CoverageReportPath SCRATCH/cov-<group>-final.txt -BaseRef 497cb504ad9a4e5435dc8946333ebc28baea50c4 -File <the group's production files> (run once per group: pra, mrg, erem, prem, lib)
EXIT_CODE: 0
Output Summary:
  CHANGED-COVERAGE file=.claude/hooks/enforce-pr-author-skill.ps1 ChangedLines=29 ChangedAnalyzed=5 ChangedCovered=5 ChangedPercent=100
  CHANGED-COVERAGE file=.claude/hooks/enforce-pr-author-skill-helpers.ps1 ChangedLines=72 ChangedAnalyzed=24 ChangedCovered=24 ChangedPercent=100
  CHANGED-COVERAGE file=.claude/hooks/enforce-pr-author-skill.artifact-root.ps1 ChangedLines=200 ChangedAnalyzed=58 ChangedCovered=56 ChangedPercent=96.55
  CHANGED-COVERAGE file=.claude/hooks/enforce-epic-merge-gate.ps1 ChangedLines=19 ChangedAnalyzed=7 ChangedCovered=7 ChangedPercent=100
  CHANGED-COVERAGE file=.claude/hooks/enforce-epic-merge-gate-resolution.ps1 ChangedLines=88 ChangedAnalyzed=28 ChangedCovered=25 ChangedPercent=89.29
  CHANGED-COVERAGE file=.claude/hooks/enforce-epic-worktree-removal-gate.ps1 ChangedLines=9 ChangedAnalyzed=3 ChangedCovered=3 ChangedPercent=100
  CHANGED-COVERAGE file=.claude/hooks/enforce-epic-worktree-removal-gate-resolution.ps1 ChangedLines=124 ChangedAnalyzed=34 ChangedCovered=33 ChangedPercent=97.06
  CHANGED-COVERAGE file=.claude/hooks/enforce-parallel-worktree-removal-gate.ps1 ChangedLines=2 ChangedAnalyzed=2 ChangedCovered=2 ChangedPercent=100
  CHANGED-COVERAGE file=.claude/lib/worktree-resolution/WorktreeRunResolution.psm1 ChangedLines=3 ChangedAnalyzed=2 ChangedCovered=2 ChangedPercent=100
  CHANGED-COVERAGE file=.claude/lib/worktree-resolution/WorktreeItemResolution.psm1 ChangedLines=79 ChangedAnalyzed=30 ChangedCovered=29 ChangedPercent=96.67
  Ten lines, none MISSING; every ChangedPercent is numeric and at least 85.
