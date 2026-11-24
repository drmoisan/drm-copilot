# Task Check P1-T1 (issue #1231)

Timestamp: 2026-11-24T00-00
Changed files:
- .claude/hooks/hook-release-pull-request-context.ps1 (new, 116 lines)
- extensions/drm-copilot/resources/claude-customizations/.claude/hooks/hook-release-pull-request-context.ps1 (new bundle copy)
- extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json (entry added)
- tests/scripts/claude-hooks/hook-release-pull-request-context.Tests.ps1 (new)
Selection rule: the mirrored test file of the changed production file (tests/scripts/claude-hooks/hook-release-pull-request-context.Tests.ps1); the bundle copy and core.json are covered by the P1-T4 contract tests.

Command: sh SCRATCH/issue-1231-taskcheck.sh (formatter check mode and Invoke-ScriptAnalyzer with scripts/powershell/PoshQC/settings/pssa.settings.psd1 over the hook and test file)
EXIT_CODE: 0
Output Summary: formatter-changed-files=0, analyzer-findings=0 (a first pass reported 13 PSReviewUnusedParameter findings in the test stubs; the unused param blocks were removed and the check re-run).

Command: sh .claude/skills/test-execution-policy/scripts/run-test-suite.sh pester -TestPath tests/scripts/claude-hooks/hook-release-pull-request-context.Tests.ps1
EXIT_CODE: 0
Output Summary: Tests Passed: 16, Failed: 0, Skipped: 0.

Command: cmp .claude/hooks/hook-release-pull-request-context.ps1 extensions/drm-copilot/resources/claude-customizations/.claude/hooks/hook-release-pull-request-context.ps1
EXIT_CODE: 0
Output Summary: byte-identical. The hook file has 116 lines (below 500).
