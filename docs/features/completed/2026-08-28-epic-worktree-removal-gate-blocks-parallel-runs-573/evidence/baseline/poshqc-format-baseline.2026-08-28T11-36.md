# PowerShell FORMAT Baseline (P0-T2)

Timestamp: 2026-08-28T11-36

Task: [P0-T2]
Issue: #573
Branch: `bug/epic-worktree-removal-gate-blocks-parallel-runs-573-r2`

Command:
1. MCP tool `mcp__drm-copilot__run_poshqc_format` with `workspace_root = C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-a691c7afb3cd3aa84`, no `scan_folders` restriction.
2. Tree observation companion: `git status --porcelain`
3. Per-file observation companion (self-hosted module, see Runner artifact note below):
   `pwsh -NoProfile -File <scratch>/run-format-observe.ps1 -Root C:/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-a691c7afb3cd3aa84 -OutFile <scratch>/format-baseline-lines.txt`
   which imports `scripts/powershell/PoshQC/PoshQC.psd1` and calls `Invoke-PoshQCFormat` with a capturing `-Logger`.

EXIT_CODE: 0

## Runner artifact note (recorded per the plan's MCP-runner caution)

The MCP wrapper `run_poshqc_format` returns only `{"ok":true, ... "summary":"Ran bundled PoshQC format against '<root>'."}`. It does not surface the per-file `Already formatted:` / `Formatted:` lines that `Invoke-PoshQCFormat` emits on its Information stream, and the plan's acceptance condition for this task requires that observation for the two in-scope hook files. The self-hosted PoshQC module was therefore invoked directly to obtain the per-file lines, exactly as the plan's "MCP PoshQC runner caveat" risk entry authorizes. The direct invocation is idempotent with respect to the MCP run: the MCP run had already normalized the tree, so the direct run observed and rewrote nothing.

## Rewritten-file set

REWRITTEN_COUNT = 0 (empty set)

The formatter examined 421 PowerShell files and rewrote none. No restoration to merge-base content was required, and there is no pre-existing formatter drift to carry forward to [P5-T1].

`git status --porcelain` immediately after the MCP format run reported only:

```
 M docs/features/active/2026-08-28-epic-worktree-removal-gate-blocks-parallel-runs-573/plan.2026-08-28T09-30.md
?? docs/features/active/2026-08-28-epic-worktree-removal-gate-blocks-parallel-runs-573/evidence/
```

Both entries are this execution's own artifacts (the [P0-T1] plan check-off and the evidence tree). No PowerShell source file appears, which independently confirms the empty rewritten-file set.

## `Already formatted:` observation for the two in-scope hook files

Verbatim lines 10 and 112 of the captured per-file output:

```
Already formatted: C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-a691c7afb3cd3aa84\.claude\hooks\enforce-epic-worktree-removal-gate.ps1
Already formatted: C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-a691c7afb3cd3aa84\extensions\drm-copilot\resources\claude-customizations\.claude\hooks\enforce-epic-worktree-removal-gate.ps1
```

The two out-of-scope codex copies (lines 84 and 186) also reported `Already formatted:` and are recorded here only to show the search was not path-filtered; they are not in scope and are not edited by this plan.

Output Summary: Clean format baseline. 421 PowerShell files scanned, 0 rewritten (`REWRITTEN_COUNT=0`). Both in-scope hook copies reported `Already formatted:`. `git status --porcelain` shows no PowerShell file modified. There is no pre-existing formatter drift set to carry forward to [P5-T1], so any file rewritten by the final format stage would be attributable to this change.
