# Task Check P2-T3

Timestamp: 2026-11-14T08-39
Command: sh SCRATCH/issue-1173-p0t1.sh issue-1173-static-p2t3.txt (Invoke-Formatter check and PSScriptAnalyzer with pssa.settings.psd1); sh SCRATCH/issue-1173-taskcheck.sh issue-1173-sel-p2t3.txt p2t3-before / p2t3-after (New-PesterConfiguration, Run.Path = selection, Run.Exit = $true); sh SCRATCH/issue-1173-pysel.sh tests/scripts/dev_tools/test_push_down_pack_manifest_dependency_closure.py tests/scripts/dev_tools/test_push_down_claude_pack_manifest_completeness.py tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py (pytest -n auto)
EXIT_CODE: 0
Output Summary:
- Changed files: new .claude/lib/docs/DocsProfileSourceRoot.psm1 (exports Get-DocsProfileSourceRootDefault: src, else the pyproject.toml package directory from [tool.poetry].packages[].include, else [project].name, else [tool.poetry].name with '-' mapped to '_', located with Get-DocsTomlKey and read from the reported span, else src per PC-1; and Get-DocsProfileSourceRootFinding: DOCS_PROFILE_SOURCE_ROOT_MISSING error at /surface_selection/source_roots/<i>; both take the ListFile seam as a scriptblock), its bundle copy (cmp: byte-identical), the core.json entry after DocsProfileCommands.psm1, new tests/scripts/claude-lib/docs/DocsProfileSourceRoot.Tests.ps1.
- Module convention: comment-based help with the CONVENTION sentence, $ErrorActionPreference = 'Stop' after Set-StrictMode -Version Latest, -ErrorAction Stop on each load-time Import-Module; ClaudeLibModuleConvention.Tests.ps1 is in the selection.
- Selection rule: the new mirrored test plus tests/scripts/claude-lib/ClaudeLibModuleConvention.Tests.ps1 (new .claude/lib module); no other test names the new module. Pytest contracts for the manifest and the bundle.
- Static (3 files): first pass found one PSUseShouldProcessForStateChangingFunctions warning on the test factory New-TestListFile, suppressed with the sibling-suite justification; recorded pass: format drift 0, PSScriptAnalyzer findings 0, exit 0.
- Fail-before (tests written first, module absent): exit 15; DocsProfileSourceRoot.Tests.ps1 failed in BeforeAll with FileNotFoundException (module not found); ClaudeLibModuleConvention passed.
- First pass-after run: 9 failed, fixed in the module (ConvertTo-DocsSourceLine uses a comma return, so wrapping it in @() collapsed the lines; the finding function's comma return wrapped its array). Recorded pass-after: exit 0; 20 passed, 0 failed, 0 skipped.
- Pytest contracts: 34 passed (dependency closure, Claude pack-manifest completeness, Claude resource contracts).
