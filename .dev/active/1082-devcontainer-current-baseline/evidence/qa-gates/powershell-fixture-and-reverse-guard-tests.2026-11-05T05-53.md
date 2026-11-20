Timestamp: 2026-11-05T05-53
Started: 2026-11-05T05:51:39.4795355Z
Command: C:/Program Files/Git/bin/sh.exe C:\Users\DANMOI~1\AppData\Local\Temp/codex-container-baseline/issue-1082/issue-1082-final-pester.sh targetedguard
EXIT_CODE: 0
Output Summary:

```text
REPORT-VARIABLE-LOAD: tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.Probe.Tests.ps1 loads enforce-orchestration-preimplementation-gate-epic-resolution.ps1
REPORT-VARIABLE-LOAD: tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-helpers.ChainEscape.Tests.ps1 loads enforce-orchestration-preimplementation-gate-helpers.ps1
REPORT-VARIABLE-LOAD: tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-helpers.OperandNormalization.Tests.ps1 loads enforce-orchestration-preimplementation-gate-helpers.ps1
REPORT-VARIABLE-LOAD: tests/scripts/claude-hooks/enforce-powershell-batch-budget-routing.Tests.ps1 loads enforce-powershell-batch-budget.ps1
REPORT-VARIABLE-LOAD: tests/scripts/claude-hooks/enforce-powershell-batch-budget.TargetWorktree.Tests.ps1 loads enforce-powershell-batch-budget.ps1
REPORT-VARIABLE-LOAD: tests/scripts/claude-hooks/enforce-powershell-batch-budget.Tests.ps1 loads enforce-powershell-batch-budget.ps1
REPORT-VARIABLE-LOAD: tests/scripts/claude-hooks/enforce-promotion-mcp-only.Issue824.Tests.ps1 loads enforce-promotion-mcp-only.ps1
REPORT-VARIABLE-LOAD: tests/scripts/claude-hooks/enforce-python-batch-budget-routing.Tests.ps1 loads enforce-python-batch-budget.ps1
REPORT-VARIABLE-LOAD: tests/scripts/claude-hooks/enforce-python-batch-budget.TargetWorktree.Tests.ps1 loads enforce-python-batch-budget.ps1
REPORT-VARIABLE-LOAD: tests/scripts/claude-hooks/enforce-python-batch-budget.Tests.ps1 loads enforce-python-batch-budget.ps1
REPORT-VARIABLE-LOAD: tests/scripts/claude-hooks/feature-review-coverage-thresholds.Tests.ps1 loads feature-review-coverage-thresholds.ps1
REPORT-VARIABLE-LOAD: tests/scripts/claude-hooks/hook-command-consumers.Issue824.Tests.ps1 loads validate-bash.ps1, enforce-orchestration-preimplementation-gate.ps1, enforce-epic-merge-gate.ps1
REPORT-VARIABLE-LOAD: tests/scripts/claude-hooks/hook-command-invocation-operands.Tests.ps1 loads hook-command-invocation.ps1
REPORT-VARIABLE-LOAD: tests/scripts/claude-hooks/hook-command-invocation.Issue824.Tests.ps1 loads hook-command-invocation.ps1
REPORT-VARIABLE-LOAD: tests/scripts/claude-hooks/hook-command-invocation.Issue824Regression.Tests.ps1 loads enforce-promotion-mcp-only.ps1, enforce-orchestration-preimplementation-gate.ps1
REPORT-VARIABLE-LOAD: tests/scripts/claude-hooks/hook-command-invocation.Tests.ps1 loads hook-command-invocation.ps1
REPORT-VARIABLE-LOAD: tests/scripts/claude-hooks/hook-command-parser.AcceptanceCases.Tests.ps1 loads enforce-epic-worktree-removal-gate.ps1, enforce-parallel-worktree-removal-gate.ps1, enforce-epic-merge-gate.ps1, enforce-promotion-mcp-only.ps1, enforce-orchestration-preimplementation-gate.ps1
REPORT-VARIABLE-LOAD: tests/scripts/claude-hooks/hook-command-payload.Tests.ps1 loads hook-command-invocation.ps1
REPORT-VARIABLE-LOAD: tests/scripts/claude-hooks/hook-command-scanner.Issue824.Tests.ps1 loads hook-command-scanner.ps1
REPORT-VARIABLE-LOAD: tests/scripts/claude-hooks/hook-command-scanner.Tests.ps1 loads hook-command-scanner.ps1
REPORT-VARIABLE-LOAD: tests/scripts/claude-hooks/persist-session-id.Tests.ps1 loads persist-session-id.ps1
REPORT-VARIABLE-LOAD: tests/scripts/claude-hooks/validate-bash.Tests.ps1 loads validate-bash.ps1
REPORT-VARIABLE-LOAD: tests/scripts/codex-hooks/codex-batch-budget-hooks.Tests.ps1 loads enforce-python-batch-budget.ps1, enforce-powershell-batch-budget.ps1, *(.codex/hooks)
REPORT-VARIABLE-LOAD: tests/scripts/codex-hooks/codex-batch-budget.TargetWorktree.Tests.ps1 loads enforce-python-batch-budget.ps1, enforce-powershell-batch-budget.ps1
REPORT-VARIABLE-LOAD: tests/scripts/codex-hooks/codex-bundle-hook-probe.Tests.ps1 loads *(.codex/hooks)
REPORT-VARIABLE-LOAD: tests/scripts/codex-hooks/codex-evidence-and-checkpoint-hooks.Tests.ps1 loads enforce-evidence-locations.ps1, enforce-checkpoint-monotonic.ps1
REPORT-VARIABLE-LOAD: tests/scripts/codex-hooks/codex-powershell-batch-budget-routing.Tests.ps1 loads enforce-powershell-batch-budget.ps1
REPORT-VARIABLE-LOAD: tests/scripts/codex-hooks/codex-pretooluse-integration.Tests.ps1 loads enforce-epic-wave-barrier.ps1, *(.codex/hooks)
REPORT-VARIABLE-LOAD: tests/scripts/codex-hooks/codex-pretooluse-transport.Tests.ps1 loads enforce-orchestration-preimplementation-gate.ps1, codex-pretooluse-file-mapping.ps1, enforce-completion-consistency.ps1, *(.codex/hooks)
REPORT-VARIABLE-LOAD: tests/scripts/codex-hooks/codex-python-batch-budget-routing.Tests.ps1 loads enforce-python-batch-budget.ps1
REPORT-VARIABLE-LOAD: tests/scripts/codex-hooks/codex-test-purity-hooks.Tests.ps1 loads check-python-test-purity.ps1, check-powershell-test-purity.ps1
REPORT-VARIABLE-LOAD: tests/scripts/codex-hooks/discovery-start.Tests.ps1 loads record-subagent-routing-attestation.ps1, enforce-codex-model-routing.ps1
REPORT-VARIABLE-LOAD: tests/scripts/codex-hooks/epic-execution-gates.Tests.ps1 loads enforce-epic-planning-only.ps1, enforce-epic-wave-barrier.ps1, enforce-epic-merge-gate.ps1, enforce-epic-worktree-removal-gate.ps1
REPORT-VARIABLE-LOAD: tests/scripts/codex-hooks/epic-provenance.Tests.ps1 loads authorize-root-epic-invocation.ps1, record-subagent-routing-attestation.ps1, enforce-epic-root-invocation.ps1, enforce-codex-model-routing.ps1, validate-codex-subagent-routing.ps1
REPORT-VARIABLE-LOAD: tests/scripts/codex-hooks/hook-command-invocation.Tests.ps1 loads hook-command-invocation.ps1
REPORT-VARIABLE-LOAD: tests/scripts/codex-hooks/hook-command-scanner.Tests.ps1 loads hook-command-scanner.ps1
REPORT-VARIABLE-LOAD: tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1 loads enforce-orchestration-preimplementation-gate.ps1, enforce-python-batch-budget.ps1, enforce-powershell-batch-budget.ps1, codex-pretooluse-file-mapping.ps1, validate-feature-review-coverage.ps1, *(.codex/hooks)
REPORT-VARIABLE-LOAD: tests/scripts/codex-hooks/model-profile-attestation.Tests.ps1 loads record-subagent-routing-attestation.ps1, enforce-codex-model-routing.ps1
REPORT-VARIABLE-LOAD: tests/scripts/codex-hooks/subagent-attestation-command.Tests.ps1 loads record-subagent-routing-attestation.ps1
REPORT-VARIABLE-LOAD: tests/scripts/codex-hooks/subagent-attestation-persistence.Tests.ps1 loads record-subagent-routing-attestation.ps1, authorize-root-epic-invocation.ps1
[+] REPO\tests\scripts\claude-hooks\enforce-gate-suites.EpicStateIsolation.Discovery.Tests.ps1 75.7s (439 tests)
[+] REPO\tests\scripts\claude-hooks\session-root-reads-850.Constraints.Tests.ps1 945ms (3 tests)
Tests completed in 120.6s
Tests Passed: 1222, Failed: 0, Skipped: 0, Inconclusive: 0, NotRun: 0
Targeted result: Passed; discovered=1222; passed=1222; failed=0; skipped=0; notrun=0
```

Raw output: SCRATCH/issue-1082-powershell-fixture-and-reverse-guard-tests.log
