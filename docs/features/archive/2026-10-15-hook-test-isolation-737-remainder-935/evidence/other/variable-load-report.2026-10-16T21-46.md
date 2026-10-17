# AC-5b Variable-Built Hook-Load Report (issue #935, P7-T7)

Timestamp: 2026-10-16T21-46
Command: gh run view 38963921545 --log --job 117185556598 (job `poshqc / PowerShell hook suites (Linux)`, head 048d76cd8939319c08a9531015733dc53371795e); extract every distinct substring starting `REPORT-VARIABLE-LOAD: `
EXIT_CODE: 0
Output Summary: 37 distinct lines; 23 with prefix `tests/scripts/claude-hooks/`, 14 with prefix `tests/scripts/codex-hooks/`. Report-only output (AC-12); the measured input for the deferred F-3 closure-enforcement follow-up (spec D3). Known report false positives named in spec D3 (`check-powershell-test-purity.Tests.ps1`, `enforce-promotion-mcp-only.Issue824.Tests.ps1`) appear below as expected.

## Lines

```
REPORT-VARIABLE-LOAD: tests/scripts/claude-hooks/check-powershell-test-purity.Tests.ps1 loads check-powershell-test-purity.ps1
REPORT-VARIABLE-LOAD: tests/scripts/claude-hooks/check-python-test-purity.Tests.ps1 loads check-python-test-purity.ps1
REPORT-VARIABLE-LOAD: tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.Probe.Tests.ps1 loads enforce-orchestration-preimplementation-gate-epic-resolution.ps1
REPORT-VARIABLE-LOAD: tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-helpers.ChainEscape.Tests.ps1 loads enforce-orchestration-preimplementation-gate-helpers.ps1
REPORT-VARIABLE-LOAD: tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-helpers.OperandNormalization.Tests.ps1 loads enforce-orchestration-preimplementation-gate-helpers.ps1
REPORT-VARIABLE-LOAD: tests/scripts/claude-hooks/enforce-powershell-batch-budget.Tests.ps1 loads enforce-powershell-batch-budget.ps1
REPORT-VARIABLE-LOAD: tests/scripts/claude-hooks/enforce-powershell-batch-budget-routing.Tests.ps1 loads enforce-powershell-batch-budget.ps1
REPORT-VARIABLE-LOAD: tests/scripts/claude-hooks/enforce-promotion-mcp-only.Issue824.Tests.ps1 loads enforce-promotion-mcp-only.ps1
REPORT-VARIABLE-LOAD: tests/scripts/claude-hooks/enforce-python-batch-budget.Tests.ps1 loads enforce-python-batch-budget.ps1
REPORT-VARIABLE-LOAD: tests/scripts/claude-hooks/enforce-python-batch-budget-routing.Tests.ps1 loads enforce-python-batch-budget.ps1
REPORT-VARIABLE-LOAD: tests/scripts/claude-hooks/feature-review-coverage-thresholds.Tests.ps1 loads feature-review-coverage-thresholds.ps1
REPORT-VARIABLE-LOAD: tests/scripts/claude-hooks/hook-command-consumers.Issue824.Tests.ps1 loads validate-bash.ps1, enforce-orchestration-preimplementation-gate.ps1, enforce-epic-merge-gate.ps1
REPORT-VARIABLE-LOAD: tests/scripts/claude-hooks/hook-command-invocation.Issue824.Tests.ps1 loads hook-command-invocation.ps1
REPORT-VARIABLE-LOAD: tests/scripts/claude-hooks/hook-command-invocation.Issue824Regression.Tests.ps1 loads enforce-promotion-mcp-only.ps1, enforce-orchestration-preimplementation-gate.ps1
REPORT-VARIABLE-LOAD: tests/scripts/claude-hooks/hook-command-invocation.Tests.ps1 loads hook-command-invocation.ps1
REPORT-VARIABLE-LOAD: tests/scripts/claude-hooks/hook-command-invocation-operands.Tests.ps1 loads hook-command-invocation.ps1
REPORT-VARIABLE-LOAD: tests/scripts/claude-hooks/hook-command-parser.AcceptanceCases.Tests.ps1 loads enforce-epic-worktree-removal-gate.ps1, enforce-parallel-worktree-removal-gate.ps1, enforce-epic-merge-gate.ps1, enforce-promotion-mcp-only.ps1, enforce-orchestration-preimplementation-gate.ps1
REPORT-VARIABLE-LOAD: tests/scripts/claude-hooks/hook-command-payload.Tests.ps1 loads hook-command-invocation.ps1
REPORT-VARIABLE-LOAD: tests/scripts/claude-hooks/hook-command-scanner.Issue824.Tests.ps1 loads hook-command-scanner.ps1
REPORT-VARIABLE-LOAD: tests/scripts/claude-hooks/hook-command-scanner.Tests.ps1 loads hook-command-scanner.ps1
REPORT-VARIABLE-LOAD: tests/scripts/claude-hooks/persist-session-id.Tests.ps1 loads persist-session-id.ps1
REPORT-VARIABLE-LOAD: tests/scripts/claude-hooks/PreToolUseSchema.Contract.Tests.ps1 loads validate-bash.ps1, enforce-promotion-mcp-only.ps1, enforce-pr-author-skill.ps1, enforce-orchestration-preimplementation-gate.ps1, check-python-test-purity.ps1, enforce-python-batch-budget.ps1, check-powershell-test-purity.ps1, enforce-powershell-batch-budget.ps1, enforce-evidence-locations.ps1, enforce-feature-folder-order.ps1, enforce-checkpoint-monotonic.ps1, enforce-completion-consistency.ps1, enforce-prd-feature-before-planner.ps1, enforce-epic-invocation-origin.ps1, enforce-mermaid-validation.ps1
REPORT-VARIABLE-LOAD: tests/scripts/claude-hooks/validate-bash.Tests.ps1 loads validate-bash.ps1
REPORT-VARIABLE-LOAD: tests/scripts/codex-hooks/codex-batch-budget-hooks.Tests.ps1 loads enforce-python-batch-budget.ps1, enforce-powershell-batch-budget.ps1, *(.codex/hooks)
REPORT-VARIABLE-LOAD: tests/scripts/codex-hooks/codex-bundle-hook-probe.Tests.ps1 loads *(.codex/hooks)
REPORT-VARIABLE-LOAD: tests/scripts/codex-hooks/codex-evidence-and-checkpoint-hooks.Tests.ps1 loads enforce-evidence-locations.ps1, enforce-checkpoint-monotonic.ps1
REPORT-VARIABLE-LOAD: tests/scripts/codex-hooks/codex-powershell-batch-budget-routing.Tests.ps1 loads enforce-powershell-batch-budget.ps1
REPORT-VARIABLE-LOAD: tests/scripts/codex-hooks/codex-pretooluse-integration.Tests.ps1 loads enforce-epic-wave-barrier.ps1, *(.codex/hooks)
REPORT-VARIABLE-LOAD: tests/scripts/codex-hooks/codex-pretooluse-transport.Tests.ps1 loads enforce-orchestration-preimplementation-gate.ps1, codex-pretooluse-file-mapping.ps1, enforce-completion-consistency.ps1, *(.codex/hooks)
REPORT-VARIABLE-LOAD: tests/scripts/codex-hooks/codex-python-batch-budget-routing.Tests.ps1 loads enforce-python-batch-budget.ps1
REPORT-VARIABLE-LOAD: tests/scripts/codex-hooks/codex-test-purity-hooks.Tests.ps1 loads check-python-test-purity.ps1, check-powershell-test-purity.ps1
REPORT-VARIABLE-LOAD: tests/scripts/codex-hooks/epic-execution-gates.Tests.ps1 loads enforce-epic-planning-only.ps1, enforce-epic-wave-barrier.ps1, enforce-epic-merge-gate.ps1, enforce-epic-worktree-removal-gate.ps1
REPORT-VARIABLE-LOAD: tests/scripts/codex-hooks/epic-provenance.Tests.ps1 loads authorize-root-epic-invocation.ps1, record-subagent-routing-attestation.ps1, enforce-epic-root-invocation.ps1, enforce-codex-model-routing.ps1, validate-codex-subagent-routing.ps1
REPORT-VARIABLE-LOAD: tests/scripts/codex-hooks/hook-command-invocation.Tests.ps1 loads hook-command-invocation.ps1
REPORT-VARIABLE-LOAD: tests/scripts/codex-hooks/hook-command-scanner.Tests.ps1 loads hook-command-scanner.ps1
REPORT-VARIABLE-LOAD: tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1 loads enforce-orchestration-preimplementation-gate.ps1, enforce-python-batch-budget.ps1, enforce-powershell-batch-budget.ps1, codex-pretooluse-file-mapping.ps1, validate-feature-review-coverage.ps1, *(.codex/hooks)
REPORT-VARIABLE-LOAD: tests/scripts/codex-hooks/model-profile-attestation.Tests.ps1 loads record-subagent-routing-attestation.ps1, enforce-codex-model-routing.ps1
```
