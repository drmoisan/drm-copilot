# Task Check P1-T2 (issue #1231)

Timestamp: 2026-11-24T00-05
Changed files:
- .claude/hooks/enforce-orchestration-preimplementation-gate-release-receipt.ps1 (new, 113 lines)
- extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-orchestration-preimplementation-gate-release-receipt.ps1 (new bundle copy)
- extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json (entry added)
- tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-release-receipt.Tests.ps1 (new; unit rows)
Selection rule: the mirrored test file of the changed production file.

Command: sh SCRATCH/issue-1231-taskcheck.sh (formatter check mode and Invoke-ScriptAnalyzer with scripts/powershell/PoshQC/settings/pssa.settings.psd1 over the hook and test file)
EXIT_CODE: 0
Output Summary: formatter-changed-files=0, analyzer-findings=0.

Command: sh .claude/skills/test-execution-policy/scripts/run-test-suite.sh pester -TestPath tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-release-receipt.Tests.ps1
EXIT_CODE: 0
Output Summary: Tests Passed: 17, Failed: 0. A first run failed 2 rows on fixture defects (a [string] fixture parameter converted $null to '', and a closure-bound directory mock did not see $RelativePath); the fixture was corrected and the selection re-run. Rows cover allow (relative and absolute), RELEASE_RECEIPT_CONFIG_INVALID (read failure, invalid file, directory entry), RELEASE_RECEIPT_CHECKPOINT_PRESENT, RELEASE_RECEIPT_BRANCH_NOT_MATCHED (detached, unmatched), declines for a blank path, a non-numeric <N>, a body file, a path outside artifacts/, a relative nested path, a null root (zero config reads), the absolute <R>/sub/artifacts/pr_body_1.receipt.json remainder (zero config reads), the absent file (one config read and zero further seam calls), and the caught error (Write-Debug invoked, empty suffix, Allowed false).

Command: cmp of the hook file and its bundle copy
EXIT_CODE: 0
Output Summary: byte-identical; 113 lines (below 500).
