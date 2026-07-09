# Baseline CodeCoverage.Path Entries (Pre-Fix)

Timestamp: 2026-07-04T12-00
Source: `scripts/powershell/PoshQC/settings/pester.runsettings.psd1` lines 23-50 (as of pre-fix state)

Verbatim entry order (16 entries):

1. Line 27: `.claude/hooks/validate-bash.ps1`
2. Line 28: `.claude/hooks/check-python-test-purity.ps1`
3. Line 29: `.claude/hooks/check-powershell-test-purity.ps1`
4. Line 30: `.claude/hooks/enforce-python-batch-budget.ps1`
5. Line 31: `.claude/hooks/enforce-powershell-batch-budget.ps1`
6. Line 34: `.claude/hooks/enforce-pr-author-skill.ps1` (under Issue #272 comment)
7. Line 38: `scripts/powershell/Publish-DrmCopilotExtension.ps1`
8. Line 39: `scripts/dev-tools/Invoke-FullRelease.ps1`
9. Line 40: `scripts/dev-tools/Invoke-MarketplacePublish.ps1`
10. Line 41: `scripts/dev-tools/Invoke-ReleaseTagPush.ps1`
11. Line 44: `.claude/hooks/enforce-epic-merge-gate.ps1`
12. Line 45: `.claude/hooks/enforce-epic-wave-barrier.ps1`
13. Line 46: `.claude/hooks/enforce-epic-worktree-removal-gate.ps1`
14. Line 47: `.claude/hooks/enforce-pr-author-skill.ps1` (under Issue #275 comment)
15. Line 48: `.claude/hooks/validate-orchestrator-output.ps1`
16. Line 49: `.claude/hooks/enforce-pr-author-skill.epic-base-branch.ps1`

Duplicate Note: `.claude/hooks/enforce-pr-author-skill.ps1` is a pre-existing literal duplicate appearing twice in the array — once at line 34 (under the Issue #272 comment) and again at line 47 (under the Issue #275 comment). Both occurrences are part of the 16-entry no-drop reference for Phase 1 verification. Neither occurrence is to be deduplicated or removed in this remediation cycle.

Output Summary: 16 pre-existing CodeCoverage.Path entries recorded verbatim in order, including both occurrences of the `.claude/hooks/enforce-pr-author-skill.ps1` duplicate (lines 34 and 47). This is the reference baseline for the Phase 1 no-drop/no-rename verification.
