# Baseline File Line Counts (Issue #849)

Timestamp: 2026-10-10T09-50
Task: P0-T4
Command: wc -l scripts/dev_tools/_orchestrator_state_issue_adoption.py extensions/drm-copilot/src/lib/validate/orchestrator-state-issue-adoption.ts .claude/lib/orchestrator-state/OrchestratorStateIssueAdoption.psm1 extensions/drm-copilot/resources/claude-customizations/.claude/lib/orchestrator-state/OrchestratorStateIssueAdoption.psm1 tests/scripts/dev_tools/test_orchestrator_state_issue_adoption_waivers.py tests/scripts/dev_tools/test_orchestrator_state_issue_adoption_parity.py extensions/drm-copilot/test/lib/validate/orchestrator-state-issue-adoption-parity.test.ts tests/scripts/claude-lib/orchestrator-state/OrchestratorStateIssueAdoption.Tests.ps1 tests/scripts/claude-lib/orchestrator-state/OrchestratorStateIssueAdoption.Parity.Tests.ps1
EXIT_CODE: 0

## Output (verbatim)

```text
   325 scripts/dev_tools/_orchestrator_state_issue_adoption.py
   295 extensions/drm-copilot/src/lib/validate/orchestrator-state-issue-adoption.ts
   375 .claude/lib/orchestrator-state/OrchestratorStateIssueAdoption.psm1
   375 extensions/drm-copilot/resources/claude-customizations/.claude/lib/orchestrator-state/OrchestratorStateIssueAdoption.psm1
   177 tests/scripts/dev_tools/test_orchestrator_state_issue_adoption_waivers.py
   222 tests/scripts/dev_tools/test_orchestrator_state_issue_adoption_parity.py
   176 extensions/drm-copilot/test/lib/validate/orchestrator-state-issue-adoption-parity.test.ts
   380 tests/scripts/claude-lib/orchestrator-state/OrchestratorStateIssueAdoption.Tests.ps1
   111 tests/scripts/claude-lib/orchestrator-state/OrchestratorStateIssueAdoption.Parity.Tests.ps1
  2436 total
```

Note: `wc -l` counts newline characters, so each value is one lower than the research document's line figures (for example 325 here versus 326 in the research) when the file ends with a final newline.

Output Summary: Nine counts recorded; all nine files are below the 500-line limit (largest: OrchestratorStateIssueAdoption.Tests.ps1 at 380).
