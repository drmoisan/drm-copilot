# [P13-T2] Final PoshQC analyze stage

Timestamp: 2026-09-07T17-05

Command:

```
mcp__drm-copilot__run_poshqc_analyze     # workspace_root: the worktree root, no scan_folders (whole repository)
```

EXIT_CODE: 0

TOOLCHAIN_SUBSTITUTION: `pwsh` is not invocable anywhere in this session, so `Invoke-PoshQCAnalyze`
could not be called directly. The analyzer was run through the `mcp__drm-copilot__run_poshqc_analyze`
MCP function, which executes the bundled PoshQC analyzer over the same workspace root and the same
`PSScriptAnalyzer` settings.

## Raw result

```
{"ok":true,"tool":"run_poshqc_analyze","workspace_root":"C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-a478b73e41951af31","summary":"Ran bundled PoshQC analyze against 'C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-a478b73e41951af31'."}
```

## How the numeric total is derived from `ok: true`

The MCP result carries a summary string rather than a diagnostic table, so the total is read from
the analyzer's control flow, exactly as the [P0-T6] baseline artifact derived it.
`Invoke-PoshQCAnalyze` in `scripts/powershell/PoshQC/PoshQC.Analyzer.psm1` collects every finding
into `$results` and then, at lines 195 to 198:

```powershell
if ($results.Count -gt 0) {
    $results | Format-Table -AutoSize
    throw "PSScriptAnalyzer reported $($results.Count) issue(s)."
}
```

Any finding raises a terminating error. `extensions/drm-copilot/src/mcp-tools.ts` line 123 maps a
thrown error to `ok: false` with the exception message as the summary; only the no-throw path
reaches `ok: true` at line 94. A response of `ok: true` is therefore equivalent to zero findings.

The severities in scope are fixed by the analyzer's own invocation at line 101 of the same module:
`Invoke-ScriptAnalyzer -Path $Path -Settings $Settings -Severity Error, Warning, Information`. All
three severities land in the same `$results` array, so a zero total is a zero at each severity.

## Repository-wide diagnostic totals

| Severity | Count |
|---|---|
| Error | 0 |
| Warning | 0 |
| Information | 0 |
| **Total** | **0** |

## Comparison against the [P0-T6] baseline

| Measure | [P0-T6] baseline | This run | Condition |
|---|---|---|---|
| Repository-wide total diagnostics | 0 | 0 | at or below baseline: **satisfied** (0 is not greater than 0) |
| Error-severity diagnostics on the changed and added paths | 0 | 0 | zero required: **satisfied** |

The baseline artifact is `evidence/baseline/baseline-poshqc-analyze.2026-09-07T10-57.md`.

## Per-file list restricted to the [P12-T1] enumeration

The [P12-T1] enumeration is recorded in `evidence/qa-gates/scope-and-size.2026-09-07T15-46.md`. Its
PowerShell members are the 65 paths below, taken from
`git diff --name-status origin/epic/cleanup-merged-worktrees-hardening-integration` filtered to
`.ps1`, `.psm1`, and `.psd1`. The repository-wide total is 0, so every path in this list carries **0**
diagnostics at every severity by construction; the list is reproduced so the restriction is auditable
rather than asserted.

### Production hook copies and parser files (36)

| Status | Path | Diagnostics |
|---|---|---|
| M | `.claude/hooks/enforce-epic-merge-gate.ps1` | 0 |
| M | `.claude/hooks/enforce-epic-worktree-removal-gate.ps1` | 0 |
| M | `.claude/hooks/enforce-orchestration-preimplementation-gate.ps1` | 0 |
| M | `.claude/hooks/enforce-parallel-abandon-gate.ps1` | 0 |
| M | `.claude/hooks/enforce-parallel-worktree-removal-gate.ps1` | 0 |
| M | `.claude/hooks/enforce-pr-author-skill.epic-base-branch.ps1` | 0 |
| M | `.claude/hooks/enforce-pr-author-skill-helpers.ps1` | 0 |
| M | `.claude/hooks/enforce-promotion-mcp-only.ps1` | 0 |
| A | `.claude/hooks/hook-command-invocation.ps1` | 0 |
| A | `.claude/hooks/hook-command-scanner.ps1` | 0 |
| M | `.claude/hooks/validate-bash.ps1` | 0 |
| M | `.codex/hooks/enforce-epic-merge-gate.ps1` | 0 |
| M | `.codex/hooks/enforce-epic-worktree-removal-gate.ps1` | 0 |
| M | `.codex/hooks/enforce-orchestration-preimplementation-gate.ps1` | 0 |
| M | `.codex/hooks/enforce-promotion-mcp-only.ps1` | 0 |
| A | `.codex/hooks/hook-command-invocation.ps1` | 0 |
| A | `.codex/hooks/hook-command-scanner.ps1` | 0 |
| M | `.codex/hooks/validate-bash.ps1` | 0 |
| M | `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-epic-merge-gate.ps1` | 0 |
| M | `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-epic-worktree-removal-gate.ps1` | 0 |
| M | `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-orchestration-preimplementation-gate.ps1` | 0 |
| M | `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-parallel-abandon-gate.ps1` | 0 |
| M | `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-parallel-worktree-removal-gate.ps1` | 0 |
| M | `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-pr-author-skill.epic-base-branch.ps1` | 0 |
| M | `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-pr-author-skill-helpers.ps1` | 0 |
| M | `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-promotion-mcp-only.ps1` | 0 |
| A | `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/hook-command-invocation.ps1` | 0 |
| A | `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/hook-command-scanner.ps1` | 0 |
| M | `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/validate-bash.ps1` | 0 |
| M | `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-epic-merge-gate.ps1` | 0 |
| M | `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-epic-worktree-removal-gate.ps1` | 0 |
| M | `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-orchestration-preimplementation-gate.ps1` | 0 |
| M | `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-promotion-mcp-only.ps1` | 0 |
| A | `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/hook-command-invocation.ps1` | 0 |
| A | `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/hook-command-scanner.ps1` | 0 |
| M | `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/validate-bash.ps1` | 0 |

### Registry files with a PowerShell extension (2)

| Status | Path | Diagnostics |
|---|---|---|
| M | `extensions/drm-copilot/resources/powershell/PoshQC/settings/pester.runsettings.psd1` | 0 |
| M | `scripts/powershell/PoshQC/settings/pester.runsettings.psd1` | 0 |

The other three registry files named in the plan carry non-PowerShell extensions and are outside the
analyzer's `.ps1`/`.psm1` filter at line 133 of `PoshQC.Analyzer.psm1`.

### Test files (27)

| Status | Path | Diagnostics |
|---|---|---|
| A | `tests/scripts/claude-hooks/enforce-epic-merge-gate.TriggerScoping.Tests.ps1` | 0 |
| A | `tests/scripts/claude-hooks/enforce-epic-worktree-removal-gate.TriggerScoping.Tests.ps1` | 0 |
| M | `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.CommandExemption.Tests.ps1` | 0 |
| A | `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.TriggerScoping.Tests.ps1` | 0 |
| A | `tests/scripts/claude-hooks/enforce-parallel-abandon-gate.TriggerScoping.Tests.ps1` | 0 |
| A | `tests/scripts/claude-hooks/enforce-parallel-worktree-removal-gate.TriggerScoping.Tests.ps1` | 0 |
| A | `tests/scripts/claude-hooks/enforce-pr-author-skill.epic-base-branch.TriggerScoping.Tests.ps1` | 0 |
| A | `tests/scripts/claude-hooks/enforce-pr-author-skill.TriggerScoping.Tests.ps1` | 0 |
| A | `tests/scripts/claude-hooks/enforce-promotion-mcp-only.TriggerScoping.Tests.ps1` | 0 |
| A | `tests/scripts/claude-hooks/hook-command-invocation.Tests.ps1` | 0 |
| A | `tests/scripts/claude-hooks/hook-command-parser.AcceptanceCases.Tests.ps1` | 0 |
| A | `tests/scripts/claude-hooks/hook-command-scanner.Tests.ps1` | 0 |
| A | `tests/scripts/claude-hooks/validate-bash.TriggerScoping.Tests.ps1` | 0 |
| A | `tests/scripts/codex-hooks/enforce-epic-merge-gate-decision-surface.Tests.ps1` | 0 |
| A | `tests/scripts/codex-hooks/enforce-epic-merge-gate-trigger-scoping.Tests.ps1` | 0 |
| A | `tests/scripts/codex-hooks/enforce-epic-worktree-removal-gate-decision-surface.Tests.ps1` | 0 |
| A | `tests/scripts/codex-hooks/enforce-epic-worktree-removal-gate-trigger-scoping.Tests.ps1` | 0 |
| M | `tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-command-exemption.Tests.ps1` | 0 |
| A | `tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-mode-routing.Tests.ps1` | 0 |
| A | `tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-trigger-scoping.Tests.ps1` | 0 |
| A | `tests/scripts/codex-hooks/enforce-promotion-mcp-only-decision-surface.Tests.ps1` | 0 |
| A | `tests/scripts/codex-hooks/enforce-promotion-mcp-only-trigger-scoping.Tests.ps1` | 0 |
| A | `tests/scripts/codex-hooks/hook-command-invocation.Tests.ps1` | 0 |
| A | `tests/scripts/codex-hooks/hook-command-scanner.Tests.ps1` | 0 |
| M | `tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1` | 0 |
| A | `tests/scripts/codex-hooks/validate-bash-decision-surface.Tests.ps1` | 0 |
| A | `tests/scripts/codex-hooks/validate-bash-trigger-scoping.Tests.ps1` | 0 |

36 + 2 + 27 = 65.

## Output Summary

`mcp__drm-copilot__run_poshqc_analyze` returned `ok: true` over the whole repository. Because
`Invoke-PoshQCAnalyze` throws on any finding and the MCP wrapper maps a throw to `ok: false`,
`ok: true` is equivalent to zero findings. Repository-wide total: **0** diagnostics (Error 0,
Warning 0, Information 0). Error-severity diagnostics on the changed and added paths: **0**.
Repository-wide total against the [P0-T6] baseline of 0: **at or below baseline**. Both acceptance
conditions are satisfied, so the loop does not restart at [P13-T1].
