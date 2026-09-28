# Defect 3.2 Control Pair — Issue #673 ([P1-T3])

Timestamp: 2026-09-17T10-41

Command: sh "<HOME>/AppData/Local/Temp/claude/C--Users-<USER>-repos-drm-copilot-wt-2026-09-13T08-30/edea1a9d-6671-4ea6-8e13-6405d6284a83/scratchpad/f673-exec/p1t3.sh"

EXIT_CODE: 0 (both hook runs exited 0; the wrapper script completed without error)

Execution route: **a-prime**, identical to the value recorded on the `ROUTE_SELECTED:` line of
`execution-route.md`. The hook is launched by absolute script path with `-File`, not dot-sourced, so its
entry point executes:
`"<PROGRAM_FILES>/PowerShell/7/pwsh.exe" -NoProfile -File "<WORKTREE_ROOT>/.claude/hooks/enforce-pr-author-skill.ps1"`.

## Transport

The payload is supplied through the `CLAUDE_TOOL_INPUT` environment variable set in the spawning shell
immediately before the launch. This is the third transport of `Read-ClaudeHookRawPayload` (transport
ordering documented at `.claude/lib/hook-payload/HookPayload.psm1:154-157`) and the one the existing
end-to-end row uses at `tests/scripts/claude-hooks/enforce-pr-author-skill.OrchestratorStatePreflight.Tests.ps1:78-80`.
`CLAUDE_HOOK_INPUT` is unset first, and each launch redirects stdin from `/dev/null`, so the first two
transports are empty and the variable is the source actually read.

Verbatim variable assignment as issued:
```sh
unset CLAUDE_HOOK_INPUT
CLAUDE_TOOL_INPUT='{"tool_name":"Bash","tool_input":{"command":"cd <HOME>/AppData/Local/Temp/claude/C--Users-<USER>-repos-drm-copilot-wt-2026-09-13T08-30/edea1a9d-6671-4ea6-8e13-6405d6284a83/scratchpad/f673-exec/repro/item-worktree && gh pr create --title \"B\" --body-file artifacts/pr_body_1.md"}}'
export CLAUDE_TOOL_INPUT
```

The identical payload was used for both runs; only the process working directory differed.

## Run 1 — working directory = fixture session-root

Working directory: `<HOME>/AppData/Local/Temp/claude/C--Users-<USER>-repos-drm-copilot-wt-2026-09-13T08-30/edea1a9d-6671-4ea6-8e13-6405d6284a83/scratchpad/f673-exec/repro/session-root`

Decision JSON (verbatim stdout):
```
{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"allow"}}
```

Exit code: `0`

stdout (verbatim):
```
{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"allow"}}
```

stderr (verbatim):
```
```
(empty)

## Run 2 — working directory = fixture item-worktree

Working directory: `<HOME>/AppData/Local/Temp/claude/C--Users-<USER>-repos-drm-copilot-wt-2026-09-13T08-30/edea1a9d-6671-4ea6-8e13-6405d6284a83/scratchpad/f673-exec/repro/item-worktree`

Decision JSON (verbatim stdout):
```
{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"deny","permissionDecisionReason":"PR_CONTEXT_MISSING: `artifacts/pr_context.summary.txt` is absent. Run `mcp__drm-copilot__collect_pr_context` before creating or editing the PR body."}}
```

Exit code: `0`

stdout (verbatim):
```
{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"deny","permissionDecisionReason":"PR_CONTEXT_MISSING: `artifacts/pr_context.summary.txt` is absent. Run `mcp__drm-copilot__collect_pr_context` before creating or editing the PR body."}}
```

stderr (verbatim):
```
```
(empty)

## Observation

Neither run produced an empty-payload anomaly deny, so the transport worked and the pair is a genuine
result rather than a transport failure. The command names the item worktree in both runs and the payload is
byte-identical; only the process working directory differs, and the decision differs with it. The session-root
run allowed a `gh pr create` pertaining to item B on the strength of sibling item A's checkpoint, PR context,
body, and receipt.
