# Task Check P2-T4 (issue #1231)

Timestamp: 2026-11-24T00-28
Changed files:
- .claude/hooks/enforce-model-routing-receipt.ps1 (header paragraph; guarded dot-source of enforce-model-routing-receipt-release.ps1; Get-ModelRoutingReleaseDecision call inside the pr-author null-checkpoint block after Get-ModelRoutingDocsEstateDecision; `$releaseSuffix` appended after `$docsSuffix`); 441 lines
- extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-model-routing-receipt.ps1 (bundle copy, byte-identical, written by SCRATCH/issue-1231-mirror.sh)
- tests/scripts/claude-hooks/enforce-model-routing-receipt.Release.Tests.ps1 (decision rows added)
Selection rule: the Release suite plus the existing model-routing suites that assert the pr-author null-checkpoint deny text (DocsEstate, ParallelRecords, Cleanup, and the base suite).

Command: sh SCRATCH/issue-1231-taskcheck.sh (formatter check mode and Invoke-ScriptAnalyzer with scripts/powershell/PoshQC/settings/pssa.settings.psd1)
EXIT_CODE: 0
Output Summary: formatter-changed-files=0, analyzer-findings=0.

Command: sh .claude/skills/test-execution-policy/scripts/run-test-suite.sh pester -TestPath <the 5 suites above>
EXIT_CODE: 0
Output Summary: workers=5; shard totals 33, 32, 9, 23, 16 passed (113 total); 0 failed. Decision rows: AC-05 allow; AC-06 one row per RELEASE_DELEGATION_* code that keeps MODEL_ROUTING_RECEIPT_BLOCKED with the suffix directly after the unchanged text, and one row asserting that the release suffix follows a non-empty docs-estate suffix; AC-10 exact pre-change deny string with zero Invoke-DocsOnlyGitExe calls. enforce-model-routing-receipt.DocsEstate.Tests.ps1, .ParallelRecords.Tests.ps1, and .Cleanup.Tests.ps1 pass unchanged.
