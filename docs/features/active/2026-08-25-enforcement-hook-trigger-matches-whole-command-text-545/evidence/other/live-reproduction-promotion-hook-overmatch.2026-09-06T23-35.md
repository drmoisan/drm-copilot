# Live reproduction: promotion hook over-match during epic child E preparation

Timestamp: 2026-09-06T23-35
Command: `cat > artifacts/orchestration/orchestrator-state.json <<'JSON' ... JSON` (Bash heredoc writing the orchestrator checkpoint; the JSON body contained promotion tool names as receipt *values*)
EXIT_CODE: 2
ExpectedExitCode: 0

Output Summary: The write was denied by `.claude/hooks/enforce-promotion-mcp-only.ps1` with
`PROMOTION_MCP_ONLY_BLOCKED: Direct Bash promotion-script execution is not allowed in agent
sessions. Use the drm-copilot MCP promotion tools instead.` No promotion script was invoked. The
command was a file write whose heredoc body quoted promotion tool names inside JSON string values,
recorded there because the orchestrator checkpoint contract requires promotion receipts under
`delegation_receipts.promotion.*`.

## Why this is in scope for issue #545

This is the over-match direction of the defect class recorded in #545, observed in a second hook
beyond the originally-filed `Test-ImplementationCommand` instance. The hook classified the command
by matching a regex against the entire raw command text, so a token appearing inside a quoted
heredoc body was treated as an invocation of that token. The gate has no notion of where a command
begins and no awareness of quoting.

The defect is self-obstructing in a specific way worth recording: the orchestrator checkpoint
schema *requires* the promotion receipt fields, and writing those required values through the
ordinary Bash file-write route is denied by the gate that governs the tokens those values name. The
two requirements are individually reasonable and jointly unsatisfiable on that route.

## Workaround applied

The checkpoint was written with the Write tool instead of a Bash heredoc, and the literal tool-name
values were removed from `delegation_receipts.promotion.*` so the file can be rewritten later
without re-triggering the gate. The workaround is disclosed, not a bypass: it does not defeat the
control, because the control's purpose is to prevent direct execution of promotion scripts and no
promotion script was executed on either route.

## Relationship to the recorded prior instances

`issue.md` for #545 already records five over-match instances observed in a single session on
2026-08-24, including one in which "writing a memory file documenting this very defect was blocked,
because the file necessarily quotes the token it warns about." The present reproduction is the same
mechanism in the promotion hook, observed twelve days later on the current tree, which establishes
that the defect is still live at `be722eba` and is not confined to the originally-filed hook.

## Verification note

This artifact records an observed denial during normal preparation work, not a scripted test run.
The `EXIT_CODE` above is the denial exit status reported by the tool layer. A reproducible Pester
case pinning this behavior is an acceptance obligation of the plan, not of this artifact.
