# P2 Markdown Line Model - Issue #1021

Timestamp: 2026-11-03T22-25
Task: [P2-T1]
Command: `sh SCRATCH/issue-1021-failnames.sh tests/scripts/claude-lib/docs/DocsPageMarkdown.Tests.ps1 issue-1021-p2-md.txt` (PowerShell 7 `Invoke-Pester` with the repository run settings over the branch-current suite; `Run.PassThru`)
EXIT_CODE: 0
Output Summary: TOTAL=31 PASSED=31 FAILED=0 SKIPPED=0 NOTRUN=0 FAILED_BLOCKS=0 FAILED_CONTAINERS=0. CI: CI-PESTER.

## Scope

- Module `.claude/lib/docs/DocsPageMarkdown.psm1` (no imports): `Split-DocsPageLine`, `Get-DocsPageFenceLine`, `Test-DocsPageFenceClose`, `Get-DocsPageLineModel`; the fence rule is re-implemented, not imported from the mermaid area.
- Suite `tests/scripts/claude-lib/docs/DocsPageMarkdown.Tests.ps1`: CRLF, CR and BOM inputs built in memory; fence length, character, info string, indentation and unclosed fence; HTML comments masked across lines and unclosed to page end; code-span contents masked; ATX (closing run removed) and setext headings; `HasGeneratedStartMarker` true for a start marker and false for an end marker and inside a fence; one page with both markers, another comment holding link- and heading-shaped text, and a fence with a link, heading and ordered list yields `comment` or `fence-*` kinds and empty `Masked` text for those lines.
- One test was corrected during the run: `returns an empty model for an empty line list` wrapped the call in `@()`, which nests the unary-comma return; the test now assigns the result directly (first run 30 of 31, final run 31 of 31).
