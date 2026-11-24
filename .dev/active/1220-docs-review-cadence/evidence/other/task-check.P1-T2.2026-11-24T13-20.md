# Task Check P1-T2

Timestamp: 2026-11-24T13-20
Command: sh SCRATCH/issue-1220-static.sh SCRATCH/issue-1220-p1t2-files.txt write (Invoke-Formatter with pssa.settings.psd1, then PSScriptAnalyzer); sh SCRATCH/issue-1220-retry.sh ... pester -TestPath <13 files listed below>
EXIT_CODE: 0
Output Summary: static pass 1 rewrote DocsPageMetadata.psm1 (hashtable alignment) and reported 1 analyzer finding (PSUseLiteralInitializerForHashtable in the new test, fixed); pass 2: 4 files, 0 would change, 0 findings (exit 0). Pester selection: 661 tests, 661 passed, 0 failed (workers=8, exit 0). DocsPageMetadata.psm1 line coverage in the selection 128/128.

Changed files:
- .claude/lib/docs/DocsPageMetadata.psm1 and its bundle copy (SHA-256 eca4fac5... both): review_due field code, three next actions, private helper Get-DocsPageReviewDateFinding called from Get-DocsPageValueFinding.
- .claude/lib/docs/DocsPageFrontMatter.psm1 and its bundle copy (SHA-256 58843a84... both): docstring of Test-DocsPageFrontMatter only.
- tests/scripts/claude-lib/docs/DocsPageMetadata.ReviewDate.Tests.ps1 (new).
- tests/scripts/claude-lib/docs/DocsPageCheck.Tests.ps1: three codes added to `$script:CatalogCode` inside an existing line; line count unchanged (696).

Selection (rule: tests that import, dot-source, or name a changed module): DocsAuthorPageTemplates.Acceptance, DocsPageCheck.LinkMap, DocsPageCheck.MalformedLink, DocsPageCheck, DocsPageFrontMatter, DocsPageImportIsolation, DocsPageMetadata.ReviewDate, DocsPageMetadata, DocsReferenceFrontMatter, Invoke-DocsCommand (tests/scripts/claude-lib/docs/), docs-authoring-roles.FamilyTemplates and docs-authoring-roles.Templates (tests/scripts/claude-runtime/).

Deviation (non-blocking): tests/scripts/claude-lib/docs/DocsReferenceIntegration.Tests.ps1 also imports a changed module, but its name matches the integration lane suffix; the launcher refused the first selection with exit 2 (`TEST_EXECUTION_POLICY_BLOCKED: local integration lane is CI-only evidence`). The file runs in CI only and was removed from the local selection.
