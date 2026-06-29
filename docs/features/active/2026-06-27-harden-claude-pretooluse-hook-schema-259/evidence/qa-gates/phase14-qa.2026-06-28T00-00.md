# Phase 14 QA — PreToolUse schema contract test (Part 2)

Issue: #259

## Command 1 — PoshQC format

- Timestamp: 2026-06-28T00-00
- Command: `mcp__drm-copilot__run_poshqc_format` (scan folder: `tests/scripts/claude-hooks`)
- EXIT_CODE: 0
- Output Summary: ok:true. Format pass over the claude-hooks test tree including the new `PreToolUseSchema.Contract.Tests.ps1`.

## Command 2 — PSScriptAnalyzer

- Timestamp: 2026-06-28T00-00
- Command: `mcp__drm-copilot__run_poshqc_analyze` (scan folder: `tests/scripts/claude-hooks`); confirmed directly via `Invoke-ScriptAnalyzer` with `pssa.settings.psd1` on the new file.
- EXIT_CODE: 0
- Output Summary: ok:true. ANALYZE_FINDINGS: 0 on `PreToolUseSchema.Contract.Tests.ps1`.

## Command 3 — Pester (full claude-hooks suite incl. contract test)

- Timestamp: 2026-06-28T00-00
- Command: `Invoke-Pester -Path tests/scripts/claude-hooks -Output Normal` (and `mcp__drm-copilot__run_poshqc_test`)
- EXIT_CODE: 0
- Output Summary: Tests Passed: 378, Failed: 0, Skipped: 0. The contract test `PreToolUseSchema.Contract.Tests.ps1` contributes 13 passing assertions — one DENY serialize-then-parse assertion block per PreToolUse hook.

## Contract test design

- File: `tests/scripts/claude-hooks/PreToolUseSchema.Contract.Tests.ps1` (136 lines, <= 500). Under the `tests/scripts` Pester discovery root.
- 13 `It` blocks, one per PreToolUse hook. Each dot-sources its hook inside the `It` block (the dot-sourcing guard prevents entrypoint execution; per-block scope avoids same-named helper collisions such as `ConvertFrom-CheckpointJson` / `Test-IsCheckpointPath`).
- DENY decision source per hook:
  - validate-bash: `Get-BashDenyDecision`
  - enforce-promotion-mcp-only: `Get-PromotionMcpOnlyBlockDecision`
  - enforce-pr-author-skill: `Get-PrAuthorSkillBlockDecision`
  - enforce-orchestration-preimplementation-gate: `Get-OrchestrationPreimplementationGateBlockDecision`
  - check-python-test-purity: `Get-PythonTestPurityBlockDecision`
  - enforce-python-batch-budget: `Get-PythonBatchBudgetBlockDecision`
  - check-powershell-test-purity: `Get-PowerShellTestPurityBlockDecision`
  - enforce-powershell-batch-budget: `Get-PowerShellBatchBudgetBlockDecision`
  - enforce-evidence-locations: `Get-EvidenceLocationBlockDecision`
  - enforce-feature-folder-order: `Invoke-FeatureFolderOrderDecision` (mocked `Get-FeatureFolderFileExistence` -> all siblings missing)
  - enforce-checkpoint-monotonic: `Invoke-CheckpointMonotonicDecision` (advanced step, missing prerequisites)
  - enforce-completion-consistency: `Invoke-CompletionConsistencyDecision` (completion asserted, no evidence)
  - enforce-prd-feature-before-planner: `Invoke-PrdFeatureBeforePlannerDecision` (mocked `Get-PrdFeatureCheckpointFolder` -> $null)
- Each block serializes with `ConvertTo-Json -Depth 5`, re-parses with `ConvertFrom-Json`, and asserts `hookSpecificOutput.hookEventName -eq 'PreToolUse'` and `hookSpecificOutput.permissionDecision -eq 'deny'`.
- No disk/network/temp files; filesystem seams are mocked or bypassed via direct tool-input construction.
