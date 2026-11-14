# Task Check P2-T1

Timestamp: 2026-11-14T08-23
Command: sh SCRATCH/issue-1173-p0t1.sh issue-1173-static-p2t1.txt (Invoke-Formatter check and PSScriptAnalyzer with pssa.settings.psd1); sh SCRATCH/issue-1173-taskcheck.sh issue-1173-sel-p2t1.txt p2t1-before / p2t1-after (New-PesterConfiguration, Run.Path = selection, Run.Exit = $true)
EXIT_CODE: 0
Output Summary:
- Changed files: .claude/lib/docs/DocsInventorySnapshot.psm1 (default exclusion constant held in two script-scope arrays and exported through Get-DocsInventoryDefaultExclusion; private Test-DocsInventoryDefaultExcludedPath applied in Get-DocsInventorySelection after the source-root test and before the profile exclusions; help of the function and the module .DESCRIPTION updated), its bundle copy (cmp: byte-identical), tests/scripts/claude-lib/docs/DocsInventorySnapshot.Tests.ps1.
- Design note: the constant is exported through an accessor function that returns new arrays rather than through Export-ModuleMember -Variable, because an exported variable is placed in the importing session state (global for a test script) and would be shared state between Pester files.
- Selection rule: mirrored test of the changed module plus every test file under tests/ and extensions/drm-copilot/test/ that names DocsInventorySnapshot or Get-DocsInventorySelection: DocsInventory.PythonNative.Tests.ps1, DocsInventory.Tests.ps1, DocsInventoryProperties.Tests.ps1, DocsInventorySnapshot.Tests.ps1. Dispositions: DocsInventorySnapshot.Tests.ps1 gains the B8 cases; the other three unchanged (their input lists hold no default-excluded segment or suffix; re-search of tests/ for those segments and suffixes found only the new cases).
- Static (3 files): first pass found format drift and one PSUseConsistentWhitespace finding in the export line (both copies), fixed; recorded pass: format drift 0, PSScriptAnalyzer findings 0, exit 0.
- Fail-before (new cases written first, production unchanged): exit 16; 44 passed, 16 failed: the constant case, the eleven segment rows, the two suffix rows, the profile-exclusion case (Get-DocsInventoryDefaultExclusion absent / dist path selected), and the .pyc DOCS_INPUT_NOT_UTF8 case. The near-miss case passed before the change, as expected (it asserts retained paths).
- Pass-after: exit 0; 60 passed, 0 failed, 0 skipped.
