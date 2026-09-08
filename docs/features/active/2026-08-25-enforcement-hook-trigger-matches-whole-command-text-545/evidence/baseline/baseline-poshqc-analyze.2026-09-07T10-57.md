# Phase 0 — Baseline PoshQC Analyze

Timestamp: 2026-09-07T10-57

Task: [P0-T6]

Command: `mcp__drm-copilot__run_poshqc_analyze` with `workspace_root=C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-a478b73e41951af31` and no `scan_folders` argument, so the whole repository root is analyzed

EXIT_CODE: 0

## Raw result

```
{"ok":true,"tool":"run_poshqc_analyze","workspace_root":"C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-a478b73e41951af31","summary":"Ran bundled PoshQC analyze against 'C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-a478b73e41951af31'."}
```

## How the numeric total is derived from `ok: true`

The MCP result carries a summary string rather than a diagnostic table, so the total is read from the
analyzer's own control flow rather than from the response text. `Invoke-PoshQCAnalyze` in
`scripts/powershell/PoshQC/PoshQC.Analyzer.psm1` collects every finding into `$results` and then, at
lines 195 to 198:

```powershell
if ($results.Count -gt 0) {
    $results | Format-Table -AutoSize
    throw "PSScriptAnalyzer reported $($results.Count) issue(s)."
}
```

Any finding at all therefore raises a terminating error. `extensions/drm-copilot/src/mcp-tools.ts`
line 123 maps a thrown error to `ok: false` with the exception message as the summary; only the
no-throw path reaches `ok: true` at line 94. A response of `ok: true` is consequently equivalent to
`$results.Count -eq 0`.

The severities in scope are fixed by the analyzer's own invocation at line 101 of the same module:
`Invoke-ScriptAnalyzer -Path $Path -Settings $Settings -Severity Error, Warning, Information`. All
three severities are collected into the same `$results` array, so a zero total is a zero for each of
the three.

## Repository-wide diagnostic totals

| Severity | Count |
| --- | --- |
| Error | 0 |
| Warning | 0 |
| Information | 0 |
| **Total** | **0** |

## Analyzer scope confirmation

`$script:DefaultExcludedDirs` in `scripts/powershell/PoshQC/PoshQC.psm1` lines 5 to 9 is
`.git`, `.venv`, `venv`, `node_modules`, `dist`, `build`, `.pytest_cache`, `__pycache__`,
`.mypy_cache`, `.ruff_cache`, `.vscode`, `.idea`, `artifacts`, `.vscode-test`. Neither `.claude`,
`.codex`, `extensions`, nor `resources` appears in that list, so all 28 in-scope production copies
are inside the analyzed set. `Invoke-PoshQCAnalyze` filters the discovered list to `.ps1` and `.psm1`
(line 133), and an independent enumeration of the worktree under the same exclusion set counts
**423** `.ps1`/`.psm1` files.

This worktree's own `.claude/` directory contains `agent-memory`, `agents`, `hooks`, `lib`, `rules`,
`settings.json`, `settings.local.json`, `skills`, and `state`. It contains no nested `worktrees`
directory, so no sibling worktree was drawn into the analyzed set.

## Per-file diagnostic list for the 28 in-scope production copies at baseline

The repository-wide total is 0, so the per-file list is empty by construction. Each of the 28 files
below carries **0** diagnostics at every severity.

Four-copy sets:

- `.claude/hooks/enforce-orchestration-preimplementation-gate.ps1` — 0
- `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-orchestration-preimplementation-gate.ps1` — 0
- `.codex/hooks/enforce-orchestration-preimplementation-gate.ps1` — 0
- `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-orchestration-preimplementation-gate.ps1` — 0
- `.claude/hooks/enforce-promotion-mcp-only.ps1` — 0
- `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-promotion-mcp-only.ps1` — 0
- `.codex/hooks/enforce-promotion-mcp-only.ps1` — 0
- `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-promotion-mcp-only.ps1` — 0
- `.claude/hooks/enforce-epic-merge-gate.ps1` — 0
- `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-epic-merge-gate.ps1` — 0
- `.codex/hooks/enforce-epic-merge-gate.ps1` — 0
- `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-epic-merge-gate.ps1` — 0
- `.claude/hooks/enforce-epic-worktree-removal-gate.ps1` — 0
- `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-epic-worktree-removal-gate.ps1` — 0
- `.codex/hooks/enforce-epic-worktree-removal-gate.ps1` — 0
- `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-epic-worktree-removal-gate.ps1` — 0
- `.claude/hooks/validate-bash.ps1` — 0
- `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/validate-bash.ps1` — 0
- `.codex/hooks/validate-bash.ps1` — 0
- `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/validate-bash.ps1` — 0

Two-copy sets (Claude only):

- `.claude/hooks/enforce-pr-author-skill-helpers.ps1` — 0
- `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-pr-author-skill-helpers.ps1` — 0
- `.claude/hooks/enforce-parallel-worktree-removal-gate.ps1` — 0
- `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-parallel-worktree-removal-gate.ps1` — 0
- `.claude/hooks/enforce-parallel-abandon-gate.ps1` — 0
- `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-parallel-abandon-gate.ps1` — 0
- `.claude/hooks/enforce-pr-author-skill.epic-base-branch.ps1` — 0
- `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-pr-author-skill.epic-base-branch.ps1` — 0

## Baseline total for the batch toolchain gate

Batch toolchain gate stage 2 requires a repository-wide total at or below the baseline total. The
baseline total recorded here is **0**, so every later batch must also report **0**.

Output Summary: `mcp__drm-copilot__run_poshqc_analyze` returned `ok: true` over the whole repository.
Because `Invoke-PoshQCAnalyze` throws on any finding and the MCP wrapper maps a throw to `ok: false`,
`ok: true` is equivalent to zero findings. Repository-wide total: **0** diagnostics (Error 0,
Warning 0, Information 0) across 423 analyzed `.ps1`/`.psm1` files. Per-file list for the 28 in-scope
production copies: all zero. Baseline total for the BTG stage-2 comparison is 0.
