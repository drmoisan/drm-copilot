# Final QC: PowerShell formatter comparison ([P12-T1])

Timestamp: 2026-10-09T22-00
Command: (PowerShell-tool) $s = Get-Content -Raw -LiteralPath tests/scripts/workflows/PublishMcpNpmWorkflow.Tests.ps1; $f = Invoke-Formatter -ScriptDefinition $s -Settings scripts/powershell/PoshQC/settings/pssa.settings.psd1; $s -ceq $f
EXIT_CODE: 1
Output Summary: PowerShell tool unavailable. The executor's tool set does not include the PowerShell tool, and the delegation forbids routing pwsh, sh, or bash wrapper scripts through the Bash tool, so the command was not executed (EXIT_CODE 1 records the non-execution; no process ran). No `True` or `False` value was produced.
Error: PowerShell tool unavailable
Branch: A7-CI
Outcome: LOCAL-PESTER-UNAVAILABLE

Dependent criterion AC-38 stays unchecked and is listed as pending-CI. The CI job `poshqc / PowerShell QC` on the PR head is authoritative; the orchestrator checks it off at S9.

## Supplementary: PoshQC MCP format run (scan_folders ["tests/scripts/workflows"])

The MCP result payload carries only an `ok` flag and a summary string composed by the server; it does not carry a formatter change list, so it is not a substitute for the A7-LOCAL acceptance literal `True`.

Command: mcp__drm-copilot__run_poshqc_format (workspace_root <worktree>, scan_folders ["tests/scripts/workflows"])
Result (verbatim):

```
{"ok":true,"tool":"run_poshqc_format","workspace_root":"<worktree>","summary":"Ran bundled PoshQC format against '<worktree>' with 1 selected scan folder(s)."}
```

Tree observation: after the format run, `git status --porcelain --untracked-files=all` printed nothing, and `git hash-object tests/scripts/workflows/PublishMcpNpmWorkflow.Tests.ps1` printed 45c0d062e2902624db729b2e282be044c489f5f3, equal to `git rev-parse HEAD:tests/scripts/workflows/PublishMcpNpmWorkflow.Tests.ps1`. The formatter modified no file, so no loop restart was required.
Redaction: absolute worktree path replaced with <worktree> on 2026-10-09T22-23 (policy-audit PA-4); no other content changed.
