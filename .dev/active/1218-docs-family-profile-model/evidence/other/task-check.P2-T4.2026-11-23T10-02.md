# Task Check P2-T4 (Issue #1218)

Timestamp: 2026-11-23T10-02
Changed files: tests/scripts/claude-lib/docs/DocsProfile.Tests.ps1 (271 lines), tests/scripts/claude-lib/docs/DocsProfileCommands.Tests.ps1 (375 lines)
Selection rule: the two changed test files.
Command: sh SCRATCH/issue-1218-qc.sh format-check / analyze over both files; sh SCRATCH/issue-1218-check.sh check-p2t4 <both files> (run 1); sh SCRATCH/issue-1218-check.sh check-p2t4b <both files> (run 2: attempts 1-39 exit 75 queue timeouts while other worktrees held the machine lock, attempt 40 ran)
EXIT_CODE: 0
Output Summary:
- Format: 0 changes. PSScriptAnalyzer: 0 findings on both files.
- Run 1: 57 passed, 2 failed. Both failures were in new cases: the AC14 ordering case and the AC16 starter case wrapped the single array that Get-DocsOrderedFinding and Get-DocsDefaultFamilySet return in @(), which nested it. The extra wrapping was removed; no assertion changed.
- Run 2: 59 tests, 59 passed, 0 failed. Not gate evidence.
- Added cases: AC14 `returns a documentation family finding together with existing findings in Get-DocsOrderedFinding order`; `reports a documentation family finding through ConvertFrom-DocsProfileText at its pointer`; AC16 `declares the default documentation families, an empty legacy_exclusions, and the five starter audiences` (ordinal ids and descriptions, root audience_ids maintainers only); AC17 `validates the indented starter text with no finding for <Case>` (default, handbook/user, sample, other-repo); AC18 `seeds the ten documentation families with their template ids in the dry run and -Write profile and writes the unchanged path set`. DocsProfileFamilies added to both Remove-Module lists.
