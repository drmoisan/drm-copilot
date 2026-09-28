# Batch B — Codex Canonical/Bundle Pair Parity ([P2-T5])

Timestamp: 2026-09-07T19-52
Task: [P2-T5]

## Command 1 — mirror

Command: `cp .codex/hooks/validate-bash.ps1 extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/validate-bash.ps1`
EXIT_CODE: 0

`cp` does not pass through the PowerShell batch-budget PreToolUse hook, so the bundle mirror
consumes no batch slot.

## Command 2 — byte comparison

Command: `cmp .codex/hooks/validate-bash.ps1 extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/validate-bash.ps1`
EXIT_CODE: 0
Output: (nothing printed)

`cmp` is used without `-s`, so a difference would print a diagnostic line rather than exit silently.

## SHA-256 of both pair members

| Pair member | SHA-256 |
|---|---|
| `.codex/hooks/validate-bash.ps1` | `9aed5b36a2284f3aa78fdd56e2dd2513bb1d96e34c4d95e3281a5a302ee43012` |
| `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/validate-bash.ps1` | `9aed5b36a2284f3aa78fdd56e2dd2513bb1d96e34c4d95e3281a5a302ee43012` |

The two values are **equal**.

## Line count of both pair members

| Pair member | Lines | At or under 500 |
|---|---|---|
| `.codex/hooks/validate-bash.ps1` | 313 | yes |
| `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/validate-bash.ps1` | 313 | yes |

The two values are **equal**. The `[P0-T8]` baseline for this file was 295 lines; the R-1 edit added
18 — a 13-line `.DESCRIPTION` paragraph plus its blank separator, and the 4-line second `if` in the
leg-1 inner loop, exactly as on the Claude side.

Output Summary: Codex canonical hook mirrored to its bundle copy and re-verified byte-identical.
Both commands exited 0, `cmp` printed nothing, both SHA-256 values equal at
`9aed5b36a2284f3aa78fdd56e2dd2513bb1d96e34c4d95e3281a5a302ee43012`, and both line counts equal at
313, under the 500-line cap.
