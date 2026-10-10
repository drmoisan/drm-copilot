# Final QC: file line counts ([P13-T1], AC-39)

Timestamp: 2026-10-09T22-01
Command: grep -c "" tests/scripts/dev_tools/test_quality_tiers_contract.py tests/scripts/dev_tools/test_quality_tiers_contract_classification.py tests/scripts/dev_tools/quality_tiers_contract_test_support.py scripts/dev_tools/check_quality_tiers.py tests/scripts/dev_tools/test_check_quality_tiers.py tests/scripts/dev_tools/test_completion_gate_documentation_contracts.py "scripts/dev_tools/potential_to_issue.py" extensions/drm-copilot/test/subagent-tree-command.test.ts extensions/drm-copilot/test/subagent-tree-command.quick-pick.test.ts extensions/drm-copilot/test/subagent-tree-command-test-support.ts tests/scripts/workflows/PublishMcpNpmWorkflow.Tests.ps1
EXIT_CODE: 0
Output Summary: eleven `path:count` lines; every count is at most 500 (maximum 449). AC-39 satisfied. Baseline [P0-T26]: test_quality_tiers_contract.py 495 -> 322; subagent-tree-command.test.ts 500 -> 335.

## Verbatim output

```
tests/scripts/dev_tools/test_quality_tiers_contract.py:322
tests/scripts/dev_tools/test_quality_tiers_contract_classification.py:199
tests/scripts/dev_tools/quality_tiers_contract_test_support.py:20
scripts/dev_tools/check_quality_tiers.py:204
tests/scripts/dev_tools/test_check_quality_tiers.py:449
tests/scripts/dev_tools/test_completion_gate_documentation_contracts.py:423
scripts/dev_tools/potential_to_issue.py:443
extensions/drm-copilot/test/subagent-tree-command.test.ts:335
extensions/drm-copilot/test/subagent-tree-command.quick-pick.test.ts:221
extensions/drm-copilot/test/subagent-tree-command-test-support.ts:70
tests/scripts/workflows/PublishMcpNpmWorkflow.Tests.ps1:247
```
