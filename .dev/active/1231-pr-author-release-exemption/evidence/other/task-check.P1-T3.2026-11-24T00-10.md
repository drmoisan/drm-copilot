# Task Check P1-T3 (issue #1231)

Timestamp: 2026-11-24T00-10
Changed files:
- .claude/hooks/enforce-orchestration-preimplementation-gate.ps1 (guarded dot-source of the receipt sibling; one call line after Get-OrchestrationParallelRecordsResult and before Get-OrchestrationReleaseAllowanceResult; `+ $receipt.DenySuffix` immediately before `+ $release.DenySuffix)`); 500 lines by wc -l
- extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-orchestration-preimplementation-gate.ps1 (bundle copy, byte-identical by cmp)
- tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-release-receipt.Tests.ps1 (decision rows added)
Selection rule: the receipt suite; hook-release-allowance-context.Parity.Tests.ps1, which reads the gate copies; and the existing suites that dot-source the gate and are named in the plan's Decisions section (EpicScope, EpicFanIn, -bookkeeping, -release, Cleanup, DocsEstate, ParallelRecords, ReleaseAllowance, and the three *-workflow.EndToEnd suites).

Command: sh SCRATCH/issue-1231-taskcheck.sh (formatter check mode and Invoke-ScriptAnalyzer with scripts/powershell/PoshQC/settings/pssa.settings.psd1 over the gate and the receipt suite)
EXIT_CODE: 0
Output Summary: formatter-changed-files=0, analyzer-findings=0.

Command: sh .claude/skills/test-execution-policy/scripts/run-test-suite.sh pester -TestPath <the 14 files above>
EXIT_CODE: 0
Output Summary: workers=8; shard totals 41, 52, 12, 11, 39, 206, 150, 25 passed (536 total), 0 failed. The decision rows (AC-07 allow, AC-08 one row per RELEASE_RECEIPT_* code keeping PREIMPLEMENTATION_GATE_BLOCKED, AC-10 exact pre-change deny text with the file absent, and a non-receipt Write with zero config reads) pass. hook-release-allowance-context.Parity.Tests.ps1 and every suite named in the Decisions section pass unchanged.
