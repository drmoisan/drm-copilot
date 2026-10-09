# P3-T9 Format check (read-only) Phase 3 files

Timestamp: 2026-10-09T00-06
Command: sh SCRATCH/run-ps.sh SCRATCH/ps-format-check.ps1 .claude/hooks/enforce-epic-worktree-removal-gate-resolution.ps1 .claude/hooks/enforce-epic-worktree-removal-gate.ps1 tests/scripts/claude-hooks/enforce-epic-worktree-removal-gate.Diagnostics.Tests.ps1 tests/scripts/claude-hooks/enforce-epic-worktree-removal-gate.Tests.ps1
EXIT_CODE: 0
Output Summary:
  FORMAT-SUMMARY ChangedCount=0

## Full output

```text
FORMAT file=.claude/hooks/enforce-epic-worktree-removal-gate-resolution.ps1 Changed=False
FORMAT file=.claude/hooks/enforce-epic-worktree-removal-gate.ps1 Changed=False
FORMAT file=tests/scripts/claude-hooks/enforce-epic-worktree-removal-gate.Diagnostics.Tests.ps1 Changed=False
FORMAT file=tests/scripts/claude-hooks/enforce-epic-worktree-removal-gate.Tests.ps1 Changed=False
FORMAT-SUMMARY ChangedCount=0
```

## CMD-GIT-STATUS (git status --porcelain)

```text
 M .claude/hooks/enforce-epic-worktree-removal-gate-resolution.ps1
 M .claude/hooks/enforce-epic-worktree-removal-gate.ps1
 M docs/features/active/2026-10-08-pr-author-and-merge-gates-read-session-root-files-850/evidence/qa-gates/gate-wiring-order.md
 M docs/features/active/2026-10-08-pr-author-and-merge-gates-read-session-root-files-850/plan.2026-10-08T13-54.md
 M extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-epic-worktree-removal-gate-resolution.ps1
 M extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-epic-worktree-removal-gate.ps1
 M tests/scripts/claude-hooks/enforce-epic-worktree-removal-gate.Tests.ps1
?? docs/features/active/2026-10-08-pr-author-and-merge-gates-read-session-root-files-850/evidence/qa-gates/analyze-p3.2026-10-09T00-06.md
?? docs/features/active/2026-10-08-pr-author-and-merge-gates-read-session-root-files-850/evidence/qa-gates/format-p3.2026-10-09T00-06.md
?? docs/features/active/2026-10-08-pr-author-and-merge-gates-read-session-root-files-850/evidence/qa-gates/pester-set-rem-p3.2026-10-09T00-06.md
?? docs/features/active/2026-10-08-pr-author-and-merge-gates-read-session-root-files-850/evidence/regression-testing/erem-diagnostics-fail-before.2026-10-09T00-02.md
?? docs/features/active/2026-10-08-pr-author-and-merge-gates-read-session-root-files-850/evidence/regression-testing/erem-diagnostics-pass-after.2026-10-09T00-06.md
?? tests/scripts/claude-hooks/enforce-epic-worktree-removal-gate.Diagnostics.Tests.ps1
```

Every status line names a P3 file, its mirror, WLOG, a FEATURE evidence path, or PLAN (T-EREM-DX appears as ??).
