# Helper and reader function definitions (remediation cycle 1, R1, Phase 1)

Timestamp: 2026-10-16T15-39
Task: [P1-T2]
Command: git grep -n -e "function Get-EpicMergeGateSelectorPrNumber" -e "function ConvertFrom-EpicMergeGateSelector" -e "function Test-EpicMergeGateCommandInScope" -e "function Get-CodexMergeCommandPrNumber" -- .claude .codex extensions tests scripts
EXIT_CODE: 0
Output Summary: DEFINITION_LINES=14 TEST_TREE_DEFINITIONS=0 DEFINITION_SET_MATCHES=true

Output (verbatim):
```text
.claude/hooks/enforce-epic-merge-gate-command.ps1:46:function ConvertFrom-EpicMergeGateSelector {
.claude/hooks/enforce-epic-merge-gate-command.ps1:110:function Test-EpicMergeGateCommandInScope {
.claude/hooks/enforce-epic-merge-gate-command.ps1:136:function Get-EpicMergeGateSelectorPrNumber {
.codex/hooks/enforce-epic-merge-gate-command.ps1:46:function ConvertFrom-EpicMergeGateSelector {
.codex/hooks/enforce-epic-merge-gate-command.ps1:110:function Test-EpicMergeGateCommandInScope {
.codex/hooks/enforce-epic-merge-gate-command.ps1:136:function Get-EpicMergeGateSelectorPrNumber {
.codex/hooks/enforce-epic-merge-gate.ps1:67:function Get-CodexMergeCommandPrNumber {
extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-epic-merge-gate-command.ps1:46:function ConvertFrom-EpicMergeGateSelector {
extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-epic-merge-gate-command.ps1:110:function Test-EpicMergeGateCommandInScope {
extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-epic-merge-gate-command.ps1:136:function Get-EpicMergeGateSelectorPrNumber {
extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-epic-merge-gate-command.ps1:46:function ConvertFrom-EpicMergeGateSelector {
extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-epic-merge-gate-command.ps1:110:function Test-EpicMergeGateCommandInScope {
extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-epic-merge-gate-command.ps1:136:function Get-EpicMergeGateSelectorPrNumber {
extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-epic-merge-gate.ps1:67:function Get-CodexMergeCommandPrNumber {
```

The set equals the expected set: each of the four helper copies at `:46`, `:110`, `:136`, plus the Codex gate and its bundle mirror at `:67`. No line is under `tests/`.
