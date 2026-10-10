# Baseline: line counts ([P0-T26])

Timestamp: 2026-10-09T21-06
Command: grep -c "" tests/scripts/dev_tools/test_quality_tiers_contract.py scripts/dev_tools/check_quality_tiers.py tests/scripts/dev_tools/test_check_quality_tiers.py tests/scripts/dev_tools/test_completion_gate_documentation_contracts.py "scripts/dev_tools/potential_to_issue.py" extensions/drm-copilot/test/subagent-tree-command.test.ts tests/scripts/workflows/PublishMcpNpmWorkflow.Tests.ps1
EXIT_CODE: 0
Output Summary: seven `path:count` lines printed; test_quality_tiers_contract.py 495 and subagent-tree-command.test.ts 500, as expected.

## Verbatim output

```
tests/scripts/dev_tools/test_quality_tiers_contract.py:495
scripts/dev_tools/check_quality_tiers.py:193
tests/scripts/dev_tools/test_check_quality_tiers.py:388
tests/scripts/dev_tools/test_completion_gate_documentation_contracts.py:402
scripts/dev_tools/potential_to_issue.py:438
extensions/drm-copilot/test/subagent-tree-command.test.ts:500
tests/scripts/workflows/PublishMcpNpmWorkflow.Tests.ps1:227
```
