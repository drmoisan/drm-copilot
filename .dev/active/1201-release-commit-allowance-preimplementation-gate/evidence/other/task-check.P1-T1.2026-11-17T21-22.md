# Task check - P1-T1

Timestamp: 2026-11-17T21-22
Changed files:
- .claude/hooks/hook-release-allowance-context.ps1 (new), byte-identical copies at .codex/hooks, extensions/drm-copilot/resources/claude-customizations/.claude/hooks, and extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks (one SHA256 across the four copies; prefix 5f7aface7de4dc10)
- tests/scripts/claude-hooks/hook-release-allowance-context.Tests.ps1 (new)
Selection rule: the mirrored test file of the new production file plus the discovery guard that reads every hook suite (`enforce-gate-suites.EpicStateIsolation.Discovery.Tests.ps1`), as the task acceptance names.

Commands:
1. Command: sh SCRATCH/issue-1201-ps-static.sh .claude/hooks/hook-release-allowance-context.ps1 tests/scripts/claude-hooks/hook-release-allowance-context.Tests.ps1 (check-only Invoke-Formatter compare and PSScriptAnalyzer with the repository settings)
   EXIT_CODE: 0
   Output Summary: format drift 0, PSScriptAnalyzer findings 0; production file 447 lines.
2. Command: sh .claude/skills/test-execution-policy/scripts/run-test-suite.sh pester -TestPath tests/scripts/claude-hooks/hook-release-allowance-context.Tests.ps1 tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.Discovery.Tests.ps1 (first run)
   EXIT_CODE: 1
   Output Summary: 16 failures, all "Method invocation failed because [System.Char] does not contain a method named 'StartsWith'" in Get-ReleaseAllowanceSegmentShape for git commit segments with one argument after the subcommand: an if expression unrolled a one-element array into a string. Fixed by assigning the remaining-token array outside the if expression; the four copies were recopied.
3. Command: the same launcher selection (second run, 2 workers, 440.9 s)
   EXIT_CODE: 0
   Output Summary: 924 tests, 924 passed, 0 failed, 0 skipped, both surfaces (Claude and Codex) of the new suite and every discovery-guard row.
