# Task Check P5-T1

Timestamp: 2026-11-14T13-36
Command: sh SCRATCH/issue-1173-taskcheck.sh issue-1173-sel-p5t1a.txt p5t1-before (fail-before); sh SCRATCH/issue-1173-taskcheck.sh issue-1173-sel-p5t1.txt p5t1b (New-PesterConfiguration, Run.Path = selection, Run.Exit = $true); sh SCRATCH/issue-1173-pysel.sh tests/scripts/dev_tools/test_push_down_pack_manifest_dependency_closure.py; sh SCRATCH/issue-1173-pymirror.sh; sh SCRATCH/issue-1173-p0t1.sh issue-1173-static-p5t1.txt
EXIT_CODE: 0
Output Summary:
- Changed files: new .claude/lib/docs/DocsReferenceSplit.psm1 (Get-DocsReferenceSplitPage, Get-DocsReferenceStaleSplitFinding) and its bundle copy (cmp: byte-identical); pack-manifests/core.json gains the module after DocsReferenceFrontMatter.psm1; tests/scripts/claude-lib/docs/DocsReferenceBoundary.Tests.ps1 adds DocsReferenceSplit.psm1 to $script:ModuleName and the three -ForEach lists in ordinal position and changes $pure.Count to 24; new DocsReferenceSplit.Tests.ps1 and DocsReferenceSplit.Properties.Tests.ps1.
- Fail-before: the two new suites with no module: 0 passed, 13 failed (module not found).
- First pass-after run: 45 passed, 1 failed ('splits an oversize group into ordinal parts ...'): the size estimate wrapped the comma-returned block lines in @(), so every element was measured at 15 bytes. Fixed in the module and the test helper by assigning the result to [string[]] before joining; rerun below.
- Pass-after: DocsReferenceSplit.Tests.ps1, DocsReferenceSplit.Properties.Tests.ps1, DocsReferenceBoundary.Tests.ps1 and ClaudeLibModuleConvention.Tests.ps1: 46 passed, 0 failed, 0 skipped.
- test_push_down_pack_manifest_dependency_closure.py: 18 passed. Mirror contract pytest selection: 23 passed.
- Static (4 files): format drift 0, PSScriptAnalyzer findings 0.
