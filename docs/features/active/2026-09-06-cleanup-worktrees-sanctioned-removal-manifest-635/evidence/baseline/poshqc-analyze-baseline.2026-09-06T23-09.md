# Baseline PowerShell Analyze State

Timestamp: 2026-09-08T00-14

Task: [P0-T6]

Command: `mcp__drm-copilot__run_poshqc_analyze` with
`workspace_root=C:/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-a5a6952a0a1e65c6e` and
no `scan_folders` argument.

EXIT_CODE: 0

## Result text, verbatim

The invocation's complete printed output was one line:

```
{"ok":true,"tool":"run_poshqc_analyze","workspace_root":"C:/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-a5a6952a0a1e65c6e","summary":"Ran bundled PoshQC analyze against 'C:/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-a5a6952a0a1e65c6e'."}
```

## Which of the two `Invoke-PoshQCAnalyze` shapes occurred

`Invoke-PoshQCAnalyze` prints `PSScriptAnalyzer passed: no findings under <Root>` on a clean run and
**throws** `PSScriptAnalyzer reported N issue(s).` when findings exist; the finding count appears
only on the failing path. The MCP wrapper surfaces the outcome through its `ok` field rather than by
relaying the module's console text: a throw inside the module propagates as a non-`ok` result
carrying the thrown message.

The observed result is `"ok":true` with no error field and no `issue(s)` text, which is the
**clean-run** shape. **Finding count recorded: 0.**

Deviation note: the module's clean-run sentence beginning `PSScriptAnalyzer passed: no findings
under` is not relayed verbatim by the MCP tool, so the verbatim transcription above is of the MCP
tool's own result text rather than of the module's console line. The self-hosted route that would
print the module's sentence is `pwsh`-based and is refused by the runtime worktree-isolation guard,
as recorded in the [P0-T2] artifact in this folder. The failing shape is distinguishable from the
clean shape through the MCP route without that sentence, because a throw cannot produce `"ok":true`.

Output Summary: PSScriptAnalyzer is clean at baseline. `mcp__drm-copilot__run_poshqc_analyze`
returned `"ok":true` with no thrown message, which is the clean-run shape; baseline finding count is
**0**. The module's own clean-run sentence is not relayed by the MCP tool and the tool's result text
is transcribed verbatim above in its place.
