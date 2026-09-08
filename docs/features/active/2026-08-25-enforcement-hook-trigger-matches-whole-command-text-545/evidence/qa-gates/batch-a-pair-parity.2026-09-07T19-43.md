# Batch A — Claude Canonical/Bundle Pair Parity ([P1-T5])

Timestamp: 2026-09-07T19-43
Task: [P1-T5]

## Command 1 — mirror

Command: `cp .claude/hooks/validate-bash.ps1 extensions/drm-copilot/resources/claude-customizations/.claude/hooks/validate-bash.ps1`
EXIT_CODE: 0

`cp` does not pass through the PowerShell batch-budget PreToolUse hook, so writing the bundle mirror
consumes no batch slot.

## Command 2 — byte comparison

Command: `cmp .claude/hooks/validate-bash.ps1 extensions/drm-copilot/resources/claude-customizations/.claude/hooks/validate-bash.ps1`
EXIT_CODE: 0
Output: (nothing printed)

`cmp` is used without `-s`, so a difference would print a diagnostic line. Nothing printed with exit
0 is what a byte-identical pair produces.

## SHA-256 of both pair members

| Pair member | SHA-256 |
|---|---|
| `.claude/hooks/validate-bash.ps1` | `6dfcadff76c36737fce9490917d757cd54fed56f8c0e0493ada67684eab0ff78` |
| `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/validate-bash.ps1` | `6dfcadff76c36737fce9490917d757cd54fed56f8c0e0493ada67684eab0ff78` |

The two values are **equal**.

## Line count of both pair members

| Pair member | Lines | At or under 500 |
|---|---|---|
| `.claude/hooks/validate-bash.ps1` | 420 | yes |
| `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/validate-bash.ps1` | 420 | yes |

The two values are **equal**. The `[P0-T8]` baseline for this file was 402 lines; the R-1 edit added
18 lines — a 13-line `.DESCRIPTION` paragraph plus its blank separator, and the 4-line second `if`
in the leg-1 inner loop.

Output Summary: Claude canonical hook mirrored to its bundle copy and re-verified byte-identical.
Both commands exited 0, `cmp` printed nothing, both SHA-256 values equal at
`6dfcadff76c36737fce9490917d757cd54fed56f8c0e0493ada67684eab0ff78`, and both line counts equal at
420, under the 500-line cap.
