# P8-T19 Coverage comparison (PowerShell line coverage)

Timestamp: 2026-10-09T01-02
Command: derived from the P0-T25 to P0-T29 baseline artifacts (evidence/baseline/coverage-*.md) and the P8-T4 to P8-T9 final artifacts (evidence/qa-gates/coverage-*.2026-10-09T00-5*.md, evidence/qa-gates/changed-line-coverage.2026-10-09T00-55.md)
EXIT_CODE: 0
Output Summary:
  Disposition: PASS (every post-change value and every changed-code value is numeric and at least 85)

Baseline Coverage:
  .claude/hooks/enforce-pr-author-skill.ps1 (PRA): 92
  .claude/hooks/enforce-pr-author-skill-helpers.ps1 (PRAH): 97.39
  .claude/hooks/enforce-pr-author-skill.artifact-root.ps1 (PRAR): new file, no baseline
  .claude/hooks/enforce-epic-merge-gate.ps1 (MRG): 96
  .claude/hooks/enforce-epic-merge-gate-resolution.ps1 (MRGR): 88.89
  .claude/hooks/enforce-epic-worktree-removal-gate.ps1 (EREM): 94.59
  .claude/hooks/enforce-epic-worktree-removal-gate-resolution.ps1 (EREMR): 95.65
  .claude/hooks/enforce-parallel-worktree-removal-gate.ps1 (PREM): 92.66
  .claude/lib/worktree-resolution/WorktreeRunResolution.psm1 (WRR): 100
  .claude/lib/worktree-resolution/WorktreeItemResolution.psm1 (WIR): 96.23

Post-Change Coverage:
  PRA: 91.84
  PRAH: 97.3
  PRAR: 96.55
  MRG: 96.15
  MRGR: 90
  EREM: 94.64
  EREMR: 96.49
  PREM: 92.66
  WRR: 100
  WIR: 96.32

New/Changed-code Coverage (ChangedPercent from P8-T9):
  PRA: 100
  PRAH: 100
  PRAR: 96.55
  MRG: 100
  MRGR: 89.29
  EREM: 100
  EREMR: 97.06
  PREM: 100
  WRR: 100
  WIR: 96.67

Disposition: PASS

Notes:
  PRA (92 to 91.84) and PRAH (97.39 to 97.3) moved by less than one point because the analyzed line set changed (lines removed with the -ContextExists parameter and the body-file root seam); every changed line in both files is covered (ChangedPercent 100).
  No Python or TypeScript file is changed by this plan (P8-T17 "*.py" diff and status are empty), so only PowerShell coverage applies; Pester reports line coverage only.
