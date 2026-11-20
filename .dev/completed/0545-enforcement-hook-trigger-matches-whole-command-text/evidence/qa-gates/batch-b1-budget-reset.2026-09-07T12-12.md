# Batch B1 — PowerShell batch-budget reset and scanner creation

Timestamp: 2026-09-07T12-12

Task: [P2-T1]

## Resolved session id

`Get-PowerShellBatchBudgetSessionId` runs in the hook's child process, which does not receive
`CLAUDE_SESSION_ID`, and `.claude/state/current-session-id` is absent, so resolution falls through to
the `worktree-<leaf>-<shorthash>` form. The resolved id is:

```
worktree-agent-a478b73e41951af31-e3281c7b
```

Cross-check against the file names actually present in `.claude/state/` immediately before the reset,
as the Change budget and batching section requires:

```
powershell-batch-budget.worktree-agent-a478b73e41951af31-e3281c7b.json
```

The composed name and the observed name are byte-identical, so the reset targeted a file that existed
rather than a name that does not.

## Pre-reset counter contents

The state file recorded the two test-file slots consumed by batch B0b and no production slots:

```json
{
  "prodCap": 3,
  "testCap": 3,
  "prodFiles": [],
  "testFiles": [
    ".../tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.CommandExemption.Tests.ps1",
    ".../tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-command-exemption.Tests.ps1"
  ]
}
```

## Reset

Command: `rm -f ".claude/state/powershell-batch-budget.worktree-agent-a478b73e41951af31-e3281c7b.json"`

EXIT_CODE: 0

TOOLCHAIN_SUBSTITUTION: the plan states the reset as
`Remove-Item -LiteralPath (Join-Path '.claude/state' ("powershell-batch-budget." + $sessionId + ".json")) -ErrorAction SilentlyContinue`.
`pwsh`, `powershell`, and `cmd` are not invocable in this session; the runtime worktree-isolation guard
refuses them unconditionally from every context. The `rm -f` form above deletes the identical single
path and its `-f` flag reproduces the `-ErrorAction SilentlyContinue` tolerance for an absent file.
The post-reset listing below is the observation that distinguishes a real deletion from a no-op,
because a delete of a non-existent path exits 0 in both spellings.

Post-reset listing of `.claude/state/`: empty (the directory exists and contains no files).

## Scanner creation

Created `.claude/hooks/hook-command-scanner.ps1` implementing spec D2 Piece 1 and Piece 2 and the D12
signature for `Read-CommandLineSegment`.

Public surface:

- `Read-CommandLineSegment` — advanced function, `[CmdletBinding()]`, `[OutputType([pscustomobject[]])]`,
  single `[Parameter(Mandatory)][AllowEmptyString()][AllowNull()][string] $CommandText`.
- `Get-CommandLineWrapperName` — advanced function, `[CmdletBinding()]`, `[OutputType([string[]])]`,
  exposes the 14-member wrapper carve-out set as the single named script-scope constant.

Internal helpers: `ConvertTo-CommandLineToken`, `Get-CommandLineSegmentCommandWord`,
`ConvertTo-CommandLineSegmentRecord`, `Read-CommandLineHeredocHeader`, `Read-CommandLineHeredocBody`.

Each segment record carries the eight D12 properties: `RawText`, `MaskedText`, `Tokens`,
`CommandWord`, `IsWrapperLed`, `HasLiveSubstitution`, `Unbalanced`, `ScanText`.

Prohibitions verified by search over the file:

| Prohibition | Command | Result |
| --- | --- | --- |
| no stdin read | `grep -c 'Read-Host\|\[Console\]::In\|$input' file` | 0 |
| no `$env:CLAUDE_` reference | `grep -c 'env:CLAUDE_' file` | 0 |
| no Python invocation | `grep -c 'python\|poetry' file` | 0 |
| no `Invoke-Expression` | `grep -c 'Invoke-Expression' file` | 0 |
| functions only | no top-level statement other than two constant assignments | verified by read |

## Parse verification

Command: `mcp__drm-copilot__run_poshqc_analyze` with
`workspace_root=C:/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-a478b73e41951af31` and
`scan_folders=[".claude/hooks"]`

EXIT_CODE: 0

TOOLCHAIN_SUBSTITUTION: the plan names
`[System.Management.Automation.Language.Parser]::ParseFile` for the parse check. That form requires a
`pwsh` process, which is not invocable in this session. PSScriptAnalyzer's own front end is the same
PowerShell language parser, and `Invoke-ScriptAnalyzer` reports a parse failure as an Error-severity
diagnostic rather than skipping the file. `Invoke-PoshQCAnalyze` throws on any finding at any of the
three configured severities and the MCP wrapper maps a throw to `ok: false`, so the `ok: true`
observed above is equivalent to zero diagnostics, which entails zero parse errors. This is a strictly
stronger observation than a bare parse check.

## Analyzer iteration recorded for audit

The first analyze run over `.claude/hooks` returned `ok: false` with
`PSScriptAnalyzer reported 4 issue(s).` The Phase 0 repository-wide baseline is 0 diagnostics, so all
four originated in this new file. The file used the leading-comma return idiom
(`return , $collection`) in exactly four places, which yields `System.Object[]` and therefore
contradicts the declared `[OutputType([string[]])]` and `[OutputType([pscustomobject[]])]`. Replacing
those four returns with the repository's existing idiom — `return $tokens.ToArray()`, as
`ConvertTo-OrchestrationCommandToken` in
`.claude/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1` already spells it — returned
the count to zero. The behavior under the `@(...)` call form used by every caller and test is
unchanged: an empty collection yields an empty array either way.

## Line count

`wc -l .claude/hooks/hook-command-scanner.ps1` = **450**, at the [P2-T5] threshold and under the
500-line cap. The formatter was run over `.claude/hooks` before this measurement and rewrote nothing.

Output Summary: batch-budget state file `powershell-batch-budget.worktree-agent-a478b73e41951af31-e3281c7b.json`
deleted, EXIT_CODE 0, post-reset `.claude/state/` listing empty; resolved session id
`worktree-agent-a478b73e41951af31-e3281c7b` cross-checked byte-identical against the observed file
name. `.claude/hooks/hook-command-scanner.ps1` created at 450 lines exposing `Read-CommandLineSegment`
and `Get-CommandLineWrapperName` as advanced functions with the eight-property D12 record; PoshQC
analyze over `.claude/hooks` returns `ok: true`, equivalent to zero diagnostics and zero parse errors.
