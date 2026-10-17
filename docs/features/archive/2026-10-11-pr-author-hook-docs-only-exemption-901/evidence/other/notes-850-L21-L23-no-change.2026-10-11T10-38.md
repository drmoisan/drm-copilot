# #850 notes L21, L22, L23 no-change record (AC-7)

Timestamp: 2026-10-12T18-23
Command: grep -n -F 'function Get-EpicWorktreeGateDenyDiagnostics {' .claude/hooks/enforce-epic-worktree-removal-gate-resolution.ps1; grep -n -F "SuppressMessageAttribute('PSUseSingularNouns'" .claude/hooks/enforce-epic-worktree-removal-gate-resolution.ps1; grep -n -F '($value -is [int] -or $value -is [long]) -and $value -gt 0' .claude/lib/worktree-resolution/WorktreeItemResolution.psm1; grep -n -F 'function Test-StandalonePositiveJsonInteger {' .claude/hooks/enforce-epic-merge-gate-authorization.ps1; grep -n -F '[long]::TryParse([string] $payload.pr_gate.pr_number' .claude/lib/worktree-resolution/WorktreeItemResolution.psm1; grep -n -F '[int]::TryParse([string]$Checkpoint.pr_gate.pr_number' .claude/hooks/enforce-epic-merge-gate-resolution.ps1 (each run as a separate call)
EXIT_CODE: 0
Output Summary:
- Each of the six commands printed exactly one line, at lines 179, 197, 424, 86, 417, and 186 (as the plan expected).
- Three notes are recorded with no change in this item; each names a trigger for a later change.
- Result: RECORDED

## L21

NOTE: #850 L21
FILE-LINE: .claude/hooks/enforce-epic-worktree-removal-gate-resolution.ps1:179 function Get-EpicWorktreeGateDenyDiagnostics
FILE-LINE: .claude/hooks/enforce-epic-worktree-removal-gate-resolution.ps1:197 SuppressMessageAttribute('PSUseSingularNouns', ...)
DECISION: NO-CHANGE
RATIONALE: the suppression is localized and justified, PSScriptAnalyzer reports no diagnostic, the review classified it as non-blocking, and a rename would edit four production files (two canonical, two bundle mirrors) and one test outside the pr-author family. Trigger: rename when the removal gate is next edited.

## L22

NOTE: #850 L22
FILE-LINE: .claude/lib/worktree-resolution/WorktreeItemResolution.psm1:424 inline positive-JSON-integer rule in Test-WorktreeItemCheckpointRecordsPr
FILE-LINE: .claude/hooks/enforce-epic-merge-gate-authorization.ps1:86 function Test-StandalonePositiveJsonInteger
DECISION: NO-CHANGE
RATIONALE: the copies are equivalent today; a module cannot depend on a hook-scope function without inverting the dependency direction; a drift produces a deny, not an unbound allow, because the gate re-checks the checkpoint it reads; both files are outside the family. Trigger: consolidate into a shared module when either copy changes.

## L23

NOTE: #850 L23
FILE-LINE: .claude/lib/worktree-resolution/WorktreeItemResolution.psm1:417 [long]::TryParse of pr_gate.pr_number
FILE-LINE: .claude/hooks/enforce-epic-merge-gate-resolution.ps1:186 [int]::TryParse of pr_gate.pr_number
DECISION: NO-CHANGE
RATIONALE: the command PR number is an Int32 in both paths, so the observable result is identical for every input; both files are outside the family. Within the pr-author family, Int32 is used throughout after the L19 fix.
