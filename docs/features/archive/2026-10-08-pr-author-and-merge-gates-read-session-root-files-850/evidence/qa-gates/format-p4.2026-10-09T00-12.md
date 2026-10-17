# P4-T7 Format check (read-only) WIR and T-WIR-PR

Timestamp: 2026-10-09T00-12
Command: sh SCRATCH/run-ps.sh SCRATCH/ps-format-check.ps1 .claude/lib/worktree-resolution/WorktreeItemResolution.psm1 tests/scripts/claude-lib/worktree-resolution/WorktreeItemResolution.PrNumber.Tests.ps1
EXIT_CODE: 0
Output Summary:
  FORMAT-SUMMARY ChangedCount=0

## Full output

```text
FORMAT file=.claude/lib/worktree-resolution/WorktreeItemResolution.psm1 Changed=False
FORMAT file=tests/scripts/claude-lib/worktree-resolution/WorktreeItemResolution.PrNumber.Tests.ps1 Changed=False
FORMAT-SUMMARY ChangedCount=0
```

## CMD-GIT-STATUS (git status --porcelain)

```text
 M .claude/lib/worktree-resolution/WorktreeItemResolution.psm1
 M docs/features/active/2026-10-08-pr-author-and-merge-gates-read-session-root-files-850/evidence/qa-gates/gate-wiring-order.md
 M docs/features/active/2026-10-08-pr-author-and-merge-gates-read-session-root-files-850/plan.2026-10-08T13-54.md
 M extensions/drm-copilot/resources/claude-customizations/.claude/lib/worktree-resolution/WorktreeItemResolution.psm1
?? docs/features/active/2026-10-08-pr-author-and-merge-gates-read-session-root-files-850/evidence/qa-gates/analyze-p4.2026-10-09T00-12.md
?? docs/features/active/2026-10-08-pr-author-and-merge-gates-read-session-root-files-850/evidence/qa-gates/format-p4.2026-10-09T00-12.md
?? docs/features/active/2026-10-08-pr-author-and-merge-gates-read-session-root-files-850/evidence/qa-gates/line-counts-p4.2026-10-09T00-12.md
?? docs/features/active/2026-10-08-pr-author-and-merge-gates-read-session-root-files-850/evidence/qa-gates/pester-set-lib-p4.2026-10-09T00-12.md
?? docs/features/active/2026-10-08-pr-author-and-merge-gates-read-session-root-files-850/evidence/regression-testing/wir-prnumber-fail-before.2026-10-09T00-09.md
?? docs/features/active/2026-10-08-pr-author-and-merge-gates-read-session-root-files-850/evidence/regression-testing/wir-prnumber-pass-after.2026-10-09T00-12.md
?? tests/scripts/claude-lib/worktree-resolution/WorktreeItemResolution.PrNumber.Tests.ps1
```

Every status line names WIR, its mirror, T-WIR-PR, WLOG, a FEATURE evidence path, or PLAN.
