# Baseline PowerShell Format State (run to convergence)

Timestamp: 2026-09-08T00-12

Task: [P0-T5]

Command: `mcp__drm-copilot__run_poshqc_format` with
`workspace_root=C:/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-a5a6952a0a1e65c6e` and
no `scan_folders` argument. Invoked twice; `git status --porcelain` captured before the first
invocation and after each invocation.

EXIT_CODE: 0

## Convergence loop

Three porcelain captures were taken, bracketing two formatter invocations. All three are byte
identical, so convergence was reached on the first invocation and the second invocation confirmed it.

Porcelain Before:

```
 M docs/features/active/2026-09-06-cleanup-worktrees-sanctioned-removal-manifest-635/plan.2026-09-06T23-09.md
?? docs/features/active/2026-09-06-cleanup-worktrees-sanctioned-removal-manifest-635/evidence/baseline/
```

Porcelain After:

```
 M docs/features/active/2026-09-06-cleanup-worktrees-sanctioned-removal-manifest-635/plan.2026-09-06T23-09.md
?? docs/features/active/2026-09-06-cleanup-worktrees-sanctioned-removal-manifest-635/evidence/baseline/
```

Third capture, after the second invocation, identical to both of the above:

```
 M docs/features/active/2026-09-06-cleanup-worktrees-sanctioned-removal-manifest-635/plan.2026-09-06T23-09.md
?? docs/features/active/2026-09-06-cleanup-worktrees-sanctioned-removal-manifest-635/evidence/baseline/
```

The two entries present in every capture are this plan's own checkbox edits and this plan's own
evidence folder. Neither is a PowerShell file, so neither was written by the formatter.

## Formatted Lines:

none

## Line Count:

1

## Observability deviation, stated explicitly

`Invoke-PoshQCFormat` prints one line per discovered file, either `Formatted: <full path>` or
`Already formatted: <full path>`, and prints no summary line. The `mcp__drm-copilot__run_poshqc_format`
tool that this task mandates does **not** surface that per-file console output to its caller. It
returns a single JSON result object, and its printed output in both invocations was exactly one line:

```
{"ok":true,"tool":"run_poshqc_format","workspace_root":"C:/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-a5a6952a0a1e65c6e","summary":"Ran bundled PoshQC format against 'C:/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-a5a6952a0a1e65c6e'."}
```

`Line Count: 1` above therefore records the number of lines that invocation actually printed, and
`Formatted Lines: none` records that no line of that output begins with the literal `Formatted: `.
The self-hosted route that would print the per-file inventory is `pwsh`-based and is refused by the
runtime worktree-isolation guard, as recorded in the [P0-T2] artifact in this folder.

The acceptance this task rests on is consequently the **tree observation**, which is the mechanism
`.claude/rules/plan-acceptance-gates.md` records as G7 Class 2: the three porcelain captures above
are byte identical, so no tracked file was rewritten by either invocation, and in particular no
PowerShell file was rewritten.

## Pre-Existing Drift:

none

No path was rewritten by any invocation in this task. The five pinned paths this task guards —
`.claude/hooks/validate-bash.ps1`, `.claude/hooks/enforce-epic-merge-gate.ps1`,
`.claude/lib/hook-payload/HookPayload.psm1`, `.codex/hooks/enforce-epic-worktree-removal-gate.ps1`,
and every file under `scripts/bash/` — are absent from all three porcelain captures, so none of them
was rewritten and no restoration was required. The blocking precondition this task defines was
therefore not triggered and the plan proceeds.

Output Summary: PowerShell format state is clean at baseline. Two `mcp__drm-copilot__run_poshqc_format`
invocations produced three byte-identical `git status --porcelain` captures, so the formatter rewrote
no tracked file and the repository was already format-converged before this task ran. No pinned path
was rewritten; `Pre-Existing Drift:` is `none` and no restoration or halt was required. The per-file
`Formatted: ` line inventory is not observable through the MCP route and the tree observation stands
in its place, as stated above.
