# Locked-File Run - Issue 1034 Remediation Cycle 1 (P2-T4)

Timestamp: 2026-11-07T01-55
Command: sh SCRATCH/issue-1034-r-locked.sh (consumer copy of .claude/hooks and .claude/lib under SCRATCH/consumer; cases a and b run the hook as a real PowerShell 7 process with the envelope for gh pr merge 12 --merge on standard input; cases c and d run SCRATCH/issue-1034-r-driver.ps1 in a real process, replacing only Invoke-DocsOnlyGhExe; locks are FileShare.None held by the parent)
EXIT_CODE: 0
Output Summary: PASS. All four outcomes held: (a) locked profile denies PROFILE_UNREADABLE, exit 0, no allow; (b) no profile allows, exit 0; (c) locked receipt denies RECEIPT_UNREADABLE; (d) no receipt denies RECEIPT_ABSENT. P2-T4 was on the waived list; it ran under the directive's exception, because the F2 verification requires this run and the reported failure occurred only in a real process.

## Decisions

- CASE a locked profile, real hook process | held=True | exit=0 | {"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"deny","permissionDecisionReason":"DOCS_COMPLETE_GATE_BLOCKED: PROFILE_UNREADABLE: The documentation profile exists but could not be read (IOException); the gate fails closed. Make the file readable and retry."}}
- CASE b no profile, real hook process | held=True | exit=0 | {"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"allow"}}
- CASE c locked receipt, real seam in a driver process | held=True | exit=0 | {"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"deny","permissionDecisionReason":"DOCS_COMPLETE_GATE_BLOCKED: RECEIPT_UNREADABLE: The validation receipt exists but could not be read (IOException); the gate fails closed. Make the file readable and retry."}}
- CASE d no receipt, real seam in a driver process | held=True | exit=0 | {"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"deny","permissionDecisionReason":"DOCS_COMPLETE_GATE_BLOCKED: RECEIPT_ABSENT: No validation receipt exists; run Invoke-DocsCommand.ps1 -Command validate -Mode docs-complete with -Revision and -WriteReceipt for the pull request head."}}
