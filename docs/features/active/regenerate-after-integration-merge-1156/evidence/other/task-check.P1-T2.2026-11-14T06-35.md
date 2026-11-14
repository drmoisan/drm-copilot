# Task Check — remediation cycle 2, [P1-T2]

Timestamp: 2026-11-14T06-35
Command: sh SCRATCH/issue-1156-static.sh (check-only Invoke-Formatter and Invoke-ScriptAnalyzer with scripts/powershell/PoshQC/settings/pssa.settings.psd1); sh SCRATCH/issue-1156-taskcheck.sh (New-PesterConfiguration, Run.Path = the five selected suites, PassThru; the launcher exits with FailedCount); sh SCRATCH/issue-1156-pytest-sel.sh tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py tests/scripts/dev_tools/test_orchestrator_state_remediation_docs.py
EXIT_CODE: 0
Output Summary:
- Changed files: `.claude/skills/orchestrate/SKILL.md`, `.claude/rules/orchestrator-state.md`, their bundle copies under `extensions/drm-copilot/resources/claude-customizations/.claude/`, `docs/features/active/regenerate-after-integration-merge-1156/spec.md`, and `tests/scripts/claude-runtime/regeneration-path-skill-contract.Tests.ps1`.
- Selection rule: contract tests that read the changed Markdown paths: the five suites the plan names, plus `tests/scripts/dev-tools/ProcessReductionChain.Ledger.Tests.ps1`, which reads both Markdown files through the process-reduction ledger.
- The sentence was added as an indented continuation line at the end of item 2 of `## Merge-Conflict Remediation` and as the last line of the `Config rules,` paragraph, with no blank line before it.
- SHA-256 equal: orchestrate skill source and bundle f86eb6fcf87e7c7eda887511977387309d808b923e4cd8daa40d1462e4bc2fcc; orchestrator-state rule source and bundle 051e0b009cc10ef29d66b43d3e3428165d647dfd33f32afcda75ed46a87adcaf.
- spec.md: 539 physical lines before and after; the `command` bullet of `### Config file` now holds the token `batch path` (1 match).
- Static: contract test file 0 formatter differences, 0 analyzer findings (350 lines).
- Pester (exit 0): 266 passed, 0 failed. `regeneration-path-skill-contract.Tests.ps1` direct Describe cases 34 (was 30; the 4 new `states the start-time resolution and batch refusal` rows pass); `concurrent-review-skill-contract.Tests.ps1` 58, `light-remediation-skill-contract.Tests.ps1` 74, `owner-directives-skill-contract.Tests.ps1` 73, `ProcessReductionChain.Ledger.Tests.ps1` 5, each 0 failed.
- pytest (exit 0): 29 passed, 0 failed across `test_push_down_claude_resource_contracts.py` and `test_orchestrator_state_remediation_docs.py`.
