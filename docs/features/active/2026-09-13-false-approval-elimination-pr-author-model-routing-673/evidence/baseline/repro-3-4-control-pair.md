# Defect 3.4 Control Pair — Issue #673 ([P1-T4])

Timestamp: 2026-09-17T10-42

Command: sh "<HOME>/AppData/Local/Temp/claude/C--Users-<USER>-repos-drm-copilot-wt-2026-09-13T08-30/edea1a9d-6671-4ea6-8e13-6405d6284a83/scratchpad/f673-exec/p1t4.sh"

EXIT_CODE: 0 (both hook runs exited 0; the wrapper script completed without error)

Execution route: **a-prime**, identical to the value recorded on the `ROUTE_SELECTED:` line of
`execution-route.md`. The hook is launched by absolute script path with `-File`, not dot-sourced, so its
entry point executes:
`"<PROGRAM_FILES>/PowerShell/7/pwsh.exe" -NoProfile -File "<WORKTREE_ROOT>/.claude/hooks/enforce-model-routing-receipt.ps1"`.

The session-root fixture checkpoint carries a `model_routing_receipts[]` entry whose `agent` is
`atomic-planner` (recorded in full in `repro-fixture-manifest.md`); the item worktree has no checkpoint.

## Transport

The payload is supplied through the `CLAUDE_TOOL_INPUT` environment variable set in the spawning shell
immediately before the launch. This is the third transport of `Read-ClaudeHookRawPayload` (transport
ordering documented at `.claude/lib/hook-payload/HookPayload.psm1:154-157`) and the one the existing
end-to-end row uses at `tests/scripts/claude-hooks/enforce-pr-author-skill.OrchestratorStatePreflight.Tests.ps1:78-80`.
`CLAUDE_HOOK_INPUT` is unset first, and each launch redirects stdin from `/dev/null`.

Verbatim variable assignment as issued:
```sh
unset CLAUDE_HOOK_INPUT
CLAUDE_TOOL_INPUT='{"tool_name":"Agent","tool_input":{"subagent_type":"atomic-planner","prompt":"docs/features/active/2026-09-13-false-approval-elimination-pr-author-model-routing-673/spec.md"}}'
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
{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"deny","permissionDecisionReason":"MODEL_ROUTING_RECEIPT_BLOCKED: cannot delegate to 'atomic-planner' before a model_routing_receipts entry for it is recorded in the orchestrator checkpoint. Perform Model Selection (record the complexity assessment and routing receipt) before delegating."}}
```

Exit code: `0`

stdout (verbatim):
```
{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"deny","permissionDecisionReason":"MODEL_ROUTING_RECEIPT_BLOCKED: cannot delegate to 'atomic-planner' before a model_routing_receipts entry for it is recorded in the orchestrator checkpoint. Perform Model Selection (record the complexity assessment and routing receipt) before delegating."}}
```

stderr (verbatim):
```
```
(empty)

## Observation

Neither run produced an empty-payload anomaly deny, so the transport worked and the pair is a genuine result
rather than a transport failure. The delegation pertains to item B's feature folder in both runs and the
payload is byte-identical; only the process working directory differs. The session-root run allowed the
delegation on the strength of sibling item A's `atomic-planner` receipt, while the item worktree, which
carries no checkpoint, denied.
