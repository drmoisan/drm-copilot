# Hook-over-Allow Precedence Verification (AC-21, spec FR-9)

Timestamp: 2026-10-10T08-36
Task: [P5-T7]
Command: (1) grep -c -F "A blocking hook also takes precedence over allow rules." docs/features/active/2026-09-29-issue-763-parallel-skill-cli-port-follow-ups-791/research/research-addendum.2026-10-08T17-10.md; (2) grep -c -F "A hook that blocks by exiting 2 routes the same way as" docs/features/active/2026-09-29-issue-763-parallel-skill-cli-port-follow-ups-791/research/research-addendum.2026-10-08T17-10.md; (3) grep -n -F "'deny'" .claude/hooks/enforce-parallel-abandon-gate.ps1; (4) grep -n -x -F "exit 0" .claude/hooks/enforce-parallel-abandon-gate.ps1
EXIT_CODE: 0, 0, 0, 0

Output Summary:
- Addendum count for "A blocking hook also takes precedence over allow rules.": 2
- Addendum count for "A hook that blocks by exiting 2 routes the same way as": 2
- Hook output line 1: `273:            permissionDecision       = 'deny'`
- Hook output line 2: `353:exit 0`

## Citation 1

Source URL: https://code.claude.com/docs/en/permissions
Section heading: "Extend permissions with hooks"
Fetched: 2026-10-08

Addendum lines 21 and 23, verbatim:

Source: https://code.claude.com/docs/en/permissions — section "Extend permissions with hooks"
> A blocking hook also takes precedence over allow rules. A hook that exits with code 2 stops the tool call before permission rules are evaluated, so the block applies even when an allow rule would otherwise let the call proceed. To run all Bash commands without prompts except for a few you want blocked, add `"Bash"` to your allow list and register a PreToolUse hook that rejects those specific commands. See [Block edits to protected files](/docs/en/hooks-guide#block-edits-to-protected-files) for a hook script you can adapt.

## Citation 6

Source URL: https://code.claude.com/docs/en/hooks
Section heading: "PreToolUse decision control"
Fetched: 2026-10-08

Addendum lines 53, 55, 57, and 59, verbatim:

Source: https://code.claude.com/docs/en/hooks — section "PreToolUse decision control"
> | `permissionDecision` | `"allow"` skips the permission prompt, except for the [actions no mode auto-approves](/docs/en/permission-modes#actions-no-mode-auto-approves) and for `AskUserQuestion` and `ExitPlanMode`, which need [`updatedInput` paired with it](#allow-with-updatedinput). `"deny"` prevents the tool call. `"ask"` prompts the user to confirm. `"defer"` exits gracefully so the tool can be resumed later. [Deny and ask rules](/docs/en/permissions#manage-permissions) are still evaluated regardless of what the hook returns |
> When multiple PreToolUse hooks return different decisions, precedence is `deny` > `defer` > `ask` > `allow`.
> A hook that blocks by exiting 2 routes the same way as `"deny"`: Claude sees the stderr message as the denial reason.

Deny emission: `.claude/hooks/enforce-parallel-abandon-gate.ps1` line 273 (the JSON `permissionDecision` deny value in `Get-ParallelAbandonGateBlockDecision`) and line 353 (the unconditional entrypoint exit); the gate emits a JSON deny and exits 0 (it never exits 2).
Source: research/research-addendum.2026-10-08T17-10.md

Finding: deny overrides allow: yes
Post-write check: 3 3 1
