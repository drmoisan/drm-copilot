# Task Check P2-T2

Timestamp: 2026-11-24T07-23
Command: sh SCRATCH/issue-1234-taskcheck.sh ".claude/hooks/enforce-epic-merge-gate.ps1,tests/scripts/claude-hooks/enforce-epic-merge-gate.Release.Tests.ps1" "<26 test files>" "" (static; launcher `pester -TestPath` selection)
EXIT_CODE: 0
Output Summary:
- Changed files: `.claude/hooks/enforce-epic-merge-gate.ps1` (one guarded dot-source of enforce-epic-merge-gate-release.ps1 after the regeneration dot-source; one call line after the docs-only block; the explicit-number deny now ends `+ $docsOnlySuffix + $greenCi.Suffix + $release.Suffix)`; one header line reworded in place), its byte copy `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-epic-merge-gate.ps1`, and `tests/scripts/claude-hooks/enforce-epic-merge-gate.Release.Tests.ps1` (6 rows added; 233 lines).
- Gate size: 500 lines (P0-T1 size 498; +2; at the 500 cap of session-root-reads-850.Constraints.Tests.ps1).
- Selection rule: the Release suite plus the D8 Claude suites: every tests/scripts/claude-hooks/enforce-epic-merge-gate*.Tests.ps1 file (22 including the three new ones), cleanup-merged-worktrees-workflow.EndToEnd, hook-command-consumers.Issue824, hook-dependency-failure.Claude, hook-dependency-failure.SpecialCases, parallel-records-workflow.EndToEnd, session-root-reads-850.Constraints (26 files).
- Static: formatter 0 `Formatted: ` lines; analyzer 0 findings.
- Pester: exit 0 after 2 queue timeouts (exit 75, re-run); 1281 tests, 0 failures. The D8 suites passed with no edit; the P2-T1 AC-21 rows passed unchanged against the wired gate.
- New rows: AC-01 allow with AC-25 (zero `pr view 5 --json headRefOid`, zero `merge-base`), AC-05 resolved item target, AC-23 after the docs-only suffix and after GREEN_CI_HEAD_STALE (D6), AC-24 docs-only allow with zero leg pr view calls, AC-24 epic-child allow with zero allowance-seam calls.
