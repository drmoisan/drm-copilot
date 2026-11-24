# Task Check P2-T3 (issue #1231)

Timestamp: 2026-11-24T00-24
Changed files:
- .claude/hooks/enforce-model-routing-receipt-release.ps1 (new, 108 lines)
- extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-model-routing-receipt-release.ps1 (new bundle copy, byte-identical by cmp)
- extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json (entry added)
- tests/scripts/claude-hooks/enforce-model-routing-receipt.Release.Tests.ps1 (new; unit rows)
Selection rule: the mirrored test file of the changed production file.

Command: sh SCRATCH/issue-1231-taskcheck.sh (formatter check mode and Invoke-ScriptAnalyzer with scripts/powershell/PoshQC/settings/pssa.settings.psd1)
EXIT_CODE: 0
Output Summary: formatter-changed-files=0, analyzer-findings=0.

Command: sh .claude/skills/test-execution-policy/scripts/run-test-suite.sh pester -TestPath tests/scripts/claude-hooks/enforce-model-routing-receipt.Release.Tests.ps1
EXIT_CODE: 0
Output Summary: Tests Passed: 14, Failed: 0. Rows: allow (the bounded diff asserted as `diff --name-only -z --no-renames --no-color --no-ext-diff --no-relative <base commit>...HEAD`); absent file and blank root with zero Invoke-DocsOnlyGitExe calls; each of the six RELEASE_DELEGATION_* codes (CONFIG_INVALID for an invalid file and a read failure, LABEL_INVALID for a missing base line and two branch lines, BRANCH_NOT_MATCHED with zero git calls, DIFF_UNREADABLE for an unresolved base, an unresolved HEAD, a failed diff, and unterminated output, DIFF_EMPTY, PATH_NOT_ALLOWED); and the caught error (Write-Debug invoked, empty suffix, Allowed false).
