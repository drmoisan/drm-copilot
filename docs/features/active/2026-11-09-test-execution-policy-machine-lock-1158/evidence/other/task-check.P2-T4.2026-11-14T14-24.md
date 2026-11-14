# Task Check: P2-T4 (remediation cycle 1, C1 execution-environment brief)

Timestamp: 2026-11-14T14-24
Command: sh .claude/skills/test-execution-policy/scripts/run-test-suite.sh pester -TestPath tests/scripts/claude-runtime/test-cadence-wording.Tests.ps1 (red run after the BRIEF row update and before the brief edit); sh SCRATCH/issue-1158-ps-filestatic.sh; sh .claude/skills/test-execution-policy/scripts/run-test-suite.sh pester -TestPath <wording, cadence, ledger suites>; the same with the five other Pester suites that read the brief; sh .claude/skills/test-execution-policy/scripts/run-test-suite.sh pytest <brief, push-down, and brief-reading contract files>
EXIT_CODE: 0
Output Summary: the updated BRIEF rows failed on the pre-edit text: all six TCW-BRIEF rows (130 passed, 6 failed), each reporting "missing '-TestPath' in ## Test Isolation Checks" and "missing '-TestPath' in ## PowerShell Route and PoshQC MCP Limits". After the brief edit: scoped Pester 264 tests, 0 failures (parallel-gate-wording 108 including PGW-BRIEF rows, test-cadence-wording 136, ledger chain 5, ledger index 15); five other brief-reading Pester suites 233 tests, 0 failures; pytest test_execution_environment_brief_contracts.py with the push-down contracts 114 passed, and the three other brief-reading pytest files 50 passed. The six brief copies are byte-identical (SHA256 equal). Format 0 diffs and PSScriptAnalyzer 0 findings on test-cadence-wording.Tests.ps1.

## Changed Files

- .claude/skills/execution-environment/SKILL.md: the task-check bullet of ## PowerShell Route and PoshQC MCP Limits is replaced with the launcher pester -TestPath route; ## Test Isolation Checks gains a bullet at its end. The five byte-identical copies (.agents, .github, three bundle copies) are re-copied.
- tests/scripts/claude-runtime/test-cadence-wording.Tests.ps1: the BRIEF PowerShell Route check requires -TestPath and run-test-suite.sh pester instead of Run.Path and New-PesterConfiguration (updated because the bullet those tokens pinned is replaced by design); the Test Isolation Checks check adds -TestPath.
- docs/engineering/process-reductions/0011-task-check-cadence.md: the block whose Current holds the task-check bullet carries the new bullet; Summary gains a Rebased over #1158 paragraph. The new isolation bullet sits outside every recorded region (P0-T2), so no other record changes.

## Selection and Rule

Contract tests that read the brief or the changed ledger entry: test-cadence-wording.Tests.ps1, parallel-gate-wording.Tests.ps1, cleanup-merged-worktrees.SkillText.Tests.ps1, documentation-workflow.CommitStage.Tests.ps1, NestingDepthContract.Tests.ps1, planning-contract-wording.Tests.ps1, regeneration-path-skill-contract.Tests.ps1, the two ledger suites, test_execution_environment_brief_contracts.py, test_bash_command_shape_surfaces.py, test_discovery_documentation_contracts.py, test_single_pass_preflight_contracts.py, and the push-down resource contract tests.

| Command | EXIT_CODE |
|---|---|
| scoped pester, test-cadence-wording only, before the brief edit (expected red) | 1 |
| format check and PSScriptAnalyzer, test-cadence-wording | 0 |
| scoped pester, wording, cadence, and ledger suites | 0 |
| scoped pester, five brief-reading suites | 0 |
| launcher pytest, brief and push-down contracts | 0 |
| launcher pytest, three brief-reading files | 0 |
