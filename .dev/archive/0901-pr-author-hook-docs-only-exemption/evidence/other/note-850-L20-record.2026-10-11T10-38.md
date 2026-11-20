# #850 note L20 record (AC-6)

Timestamp: 2026-10-12T18-23
Command: grep -n -F 'function Test-ChildCheckpointPrGateBinding {' .claude/hooks/enforce-epic-merge-gate-resolution.ps1; grep -n -F '[int]::TryParse([string]$Checkpoint.pr_gate.pr_number' .claude/hooks/enforce-epic-merge-gate-resolution.ps1; grep -n -F "Context 'child checkpoint pull request binding'" tests/scripts/claude-hooks/enforce-epic-merge-gate.ItemResolution.Tests.ps1; grep -n -F "It 'returns the pr_gate equality result' -ForEach @(" tests/scripts/claude-hooks/enforce-epic-merge-gate.ItemResolution.Tests.ps1 (each run as a separate call)
EXIT_CODE: 0
Output Summary:
- Each of the four commands printed exactly one line, at lines 151, 186, 238, and 258 (as the plan expected).
- The unparseable pr_gate.pr_number branch is fail-closed; only a covering test row is missing. No file outside the pr-author family is edited in this item.
- Result: RECORDED

NOTE: #850 L20
FILE-LINE: .claude/hooks/enforce-epic-merge-gate-resolution.ps1:151 function Test-ChildCheckpointPrGateBinding
FILE-LINE: .claude/hooks/enforce-epic-merge-gate-resolution.ps1:186 [int]::TryParse of pr_gate.pr_number; the branch that follows returns $false
FILE-LINE: tests/scripts/claude-hooks/enforce-epic-merge-gate.ItemResolution.Tests.ps1:238 Context 'child checkpoint pull request binding'
FILE-LINE: tests/scripts/claude-hooks/enforce-epic-merge-gate.ItemResolution.Tests.ps1:258 It 'returns the pr_gate equality result' -ForEach
COVERING-ROW: add a -ForEach row (or an It) with checkpoint '{"pr_gate":{"pr_number":"abc"}}' and -CommandPrNumber 812, expecting $false
DECISION: NO-CHANGE-IN-THIS-ITEM
RATIONALE: the branch is fail-closed and correct by inspection; only a covering row is missing; the file is outside the pr-author hook family, and the operator excluded it because a concurrent epic may own the merge-gate files.
