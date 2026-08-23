# promotion-gate-matches-tool-name-in-file-content (Issue #517)

- Date captured: 2026-08-23
- Author: Dan Moisan
- Status: Promoted -> docs/features/active/promotion-gate-matches-tool-name-in-file-content/ (Issue #517)

> Automation note: Keep the section headings below unchanged; the promotion tooling maps each of them into the GitHub bug issue template.

- Issue: #517
- Issue URL: https://github.com/drmoisan/drm-copilot/issues/517
- Last Updated: 2026-08-23
## Summary

`enforce-promotion-mcp-only.ps1` searches the entire `Bash` command string for the substring `new_active_feature_folder` (and three sibling tokens) and denies on any occurrence. Because a shell command that writes a file contains that file's content, recording a truthful MCP promotion receipt — which must cite the tool name verbatim to satisfy the routing-contract validator — is blocked as if it were an attempt to execute a promotion script.

## Environment

- OS/version: Windows 11 Pro 10.0.26200
- Python version: n/a — hooks are PowerShell; PowerShell 7.6.5
- Command/flags used: `Bash` with a heredoc writing `artifacts/orchestration/orchestrator-state.json`
- Data source or fixture: `.claude/hooks/enforce-promotion-mcp-only.ps1` at commit `bee15c06`; observed live during an orchestration run on 2026-08-23

## Steps to Reproduce

1. Compose a shell command that writes a JSON file whose content includes the literal `new_active_feature_folder` as a value — for example an orchestrator-state checkpoint recording `{"tool": "new_active_feature_folder", "ok": true}` as a promotion or MCP-call receipt.
2. Invoke it through the `Bash` tool.
3. Observe the hook decision.
4. As a control, run the identical command with that one value replaced by a placeholder, and observe that it is allowed.
5. Grep the hook for its matching strategy: the forbidden-token loop uses `IndexOf(..., OrdinalIgnoreCase)` against the whole command text.

## Expected Behavior

The gate exists to stop agents bypassing the MCP promotion surface by invoking promotion scripts or `gh issue create` directly. Naming a tool inside data is not an invocation. A command that writes a file should be classified on what it *executes*, not on what the file *contains* — otherwise the gate forbids describing the very surface it mandates.

The requirement to name the tool is not incidental. `.claude/skills/orchestrate/SKILL.md` requires `mcp_call_receipts[]` entries whose `tool` field equals a `required_mcp_tools` entry verbatim, and `new_active_feature_folder` is such an entry for the `small`, `large`, and `preparation` routes. The validator counts a receipt only when the name matches. So the checkpoint the orchestrator is required to write is a checkpoint the hook refuses to let it write through the shell.

## Actual Behavior

Step 2 is denied:

```text
PROMOTION_MCP_ONLY_BLOCKED: Direct Bash promotion-script execution is not allowed in
agent sessions. Use the drm-copilot MCP promotion tools instead.
```

Step 4 is allowed. The command executes nothing related to promotion in either case; only the file content differs.

The matching code makes no distinction between an executable token and arbitrary text:

```powershell
$forbiddenTokens = @(
    'new-potential-entry.ps1',
    'new_potential_bug_entry',
    'potential_to_issue',
    'new_active_feature_folder'
)
foreach ($token in $forbiddenTokens) {
    if ($CommandText.IndexOf($token, [System.StringComparison]::OrdinalIgnoreCase) -ge 0) {
        return (Get-PromotionMcpOnlyBlockedReason)
    }
}
```

Three of the four tokens are MCP tool *names*, not script paths. Only the first, `new-potential-entry.ps1`, names an executable. An MCP tool name cannot be invoked from a shell at all, so its presence in a command string is never itself the bypass the gate is guarding against — the bypass would be a direct script call or a `gh issue create`, both of which are matched separately and correctly.

The workaround is worse than the block. The value has to be assembled from fragments so the literal never appears in the command text, which yields an obscure construction whose only purpose is to evade a hook, and which a later reader will not understand:

```text
write the file with a placeholder, then substitute 'new_active' + '_feature_folder'
```

## Logs / Screenshots

- [x] Attached minimal logs or screenshot
- Snippet is inlined under **Actual Behavior** above.
- Note that this document itself contains the token repeatedly, so any future tooling that scans documentation with the same substring strategy will flag this bug report.

## Impact / Severity

- [ ] Blocker
- [ ] High
- [x] Medium
- [ ] Low

Medium. It fails closed, so it is not a safety hole, and the MCP path itself is unaffected. But it obstructs a mandated action — writing a truthful receipt — and pushes the agent toward string-splitting evasion, which is the opposite of the auditability the receipt exists to provide. A receipt assembled to dodge a hook is a receipt a reviewer cannot trust at a glance.

It is Medium rather than High because the block is loud and immediate, and the MCP tools remain fully usable.

## Suspected Cause / Notes

- The token list conflates two categories: one script filename and three MCP tool names. They need different treatment. A script filename is plausibly matched anywhere in a command; a tool name is not an executable and arguably should not be matched at all.
- The narrowest fix is to drop the three MCP tool names from the command-text scan and keep only the executable script matching, since the tool names cannot be invoked from a shell. The gate's real teeth are the `gh issue create` / `gh issue new` patterns and the `gh api ... POST .../issues` pattern, which are precise and should stay.
- If the tool names must stay for defence in depth, match them only in an executable position — the first token of the command or of a pipeline segment — rather than anywhere in the string.
- The same substring-versus-execution confusion should be checked in any other hook that scans `command` text for a bare identifier. `enforce-evidence-locations.ps1` and the batch-budget hooks are the likeliest to share the pattern.
- A related consequence worth checking: because the scan is case-insensitive and unanchored, any commit message, plan document, or audit artifact written through the shell that discusses the promotion surface is also blocked. Writing documentation *about* promotion is a normal activity.

## Proposed Fix / Validation Ideas

- [x] Unit coverage areas — cases asserting a command whose *content* mentions each MCP tool name is allowed, alongside the existing cases asserting a direct script invocation is denied. Both are needed; keeping only the deny cases is what let this through.
- [x] Integration scenario to retest — write an orchestrator-state checkpoint containing a truthful `mcp_call_receipts[]` entry naming the tool verbatim, through the shell, and assert it is allowed; then assert a direct promotion-script invocation and a `gh issue create` are both still denied.
- [x] Manual verification notes — confirm the three `gh` bypass patterns still deny after the change. A fix that loosened those would remove the gate's actual purpose while fixing only its false positive.

## Next Step

- [x] Promote to GitHub issue (bug-report template)
- [ ] Move to active fix folder / branch
