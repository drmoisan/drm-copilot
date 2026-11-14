# Task Check P2-T2

Timestamp: 2026-11-14T08-27
Command: sh SCRATCH/issue-1173-p0t1.sh issue-1173-static-p2t2.txt (Invoke-Formatter check and PSScriptAnalyzer with pssa.settings.psd1); sh SCRATCH/issue-1173-taskcheck.sh issue-1173-sel-p2t2.txt p2t2-before / p2t2-after (New-PesterConfiguration, Run.Path = selection, Run.Exit = $true)
EXIT_CODE: 0
Output Summary:
- Changed files: .claude/lib/docs/DocsPageLinks.psm1 (Get-DocsPageExternalTarget skips a resolved path that fails Test-DocsRelativePath; DocsSurface.psm1 imported for that predicate, which DocsPageImportIsolation.Tests.ps1 allows; function help and module .DESCRIPTION updated), its bundle copy (cmp: byte-identical; DocsSurface.psm1 already in core.json), tests/scripts/claude-lib/docs/DocsPageLinks.Tests.ps1 (malformed-target case), new tests/scripts/claude-lib/docs/DocsPageCheck.MalformedLink.Tests.ps1 (Invoke-DocsCheckCommand and Invoke-DocsCommandCli over an in-memory context whose TestFile applies the production relative-path check). DocsPageCheck.Tests.ps1 is not edited.
- Selection rule: mirrored test of the changed module plus every test file under tests/ and extensions/drm-copilot/test/ that names DocsPageLinks or Get-DocsPageExternalTarget: DocsPageLinks.Tests.ps1, DocsPageCheck.MalformedLink.Tests.ps1, DocsPageCheck.Tests.ps1, DocsPageCheck.LinkMap.Tests.ps1, DocsPageImportIsolation.Tests.ps1. Dispositions: the first two carry the new cases; the other three unchanged (no case links a malformed target; the import-isolation allowed set contains DocsSurface.psm1).
- Static (4 files): first pass found one PSUseShouldProcessForStateChangingFunctions warning on the new test factory New-TestMalformedPage, suppressed with the justification used by the sibling suites; recorded pass: format drift 0, PSScriptAnalyzer findings 0, exit 0.
- Fail-before (new cases written first, production unchanged): exit 3; 136 passed, 3 failed: the unit case (external targets held 'docs/a|b.md'), the command case (RuntimeException DOCS_CONTEXT_PATH_INVALID: 'docs/a|b.md' is not a repository-relative path), and the CLI case (exit 3, expected 1).
- Pass-after: exit 0; 139 passed, 0 failed, 0 skipped.
