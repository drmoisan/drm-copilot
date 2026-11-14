# Task Check P2-T6

Timestamp: 2026-11-14T08-59
Command: sh SCRATCH/issue-1173-p0t1.sh issue-1173-static-p2t6.txt (Invoke-Formatter check and PSScriptAnalyzer with pssa.settings.psd1); sh SCRATCH/issue-1173-taskcheck.sh issue-1173-sel-p2t6.txt p2t6-before / p2t6-after (New-PesterConfiguration, Run.Path = selection, Run.Exit = $true)
EXIT_CODE: 0
Output Summary:
- Changed files: .claude/lib/docs/DocsProfileCommands.psm1 (Invoke-DocsInitCommand adds the line 'ci-workflow <path>' after the action lines for the first template row whose destination starts with .github/workflows/, in dry-run and -Write modes, and the result field ci_workflow holding that path or $null; help and module .DESCRIPTION updated; 270 physical lines), its bundle copy (cmp: byte-identical), tests/scripts/claude-lib/docs/DocsInitTemplate.DocsWorkflow.Tests.ps1.
- Selection rule: same as P2-T5 (every test file that names DocsProfileCommands, the init or validate-profile command, or New-DocsStarterProfile; 15 files).
- Changed-behavior search: tests/ and extensions/drm-copilot/test/ searched for exact init Line sets, init result key lists, planned_writes key assertions and ci_workflow; no existing test asserts the exact init line set or result keys (the one exact Line assertion, in DocsFinding.Tests.ps1, is a New-DocsCommandResult factory case), and no schema constrains the init result; no existing test needed an update.
- Static (3 files): format drift 0, PSScriptAnalyzer findings 0, exit 0.
- Fail-before (new cases written first, production unchanged): exit 3; 3 failed: the dry-run and write rows of the ci-workflow case and the null case.
- Pass-after: exit 0; 395 passed, 0 failed, 0 skipped.
