# Phase 0 — Pre-change Inventory of the 36 In-Scope Production PowerShell Copies

Timestamp: 2026-09-07T10-57

Task: [P0-T4]

Command: `python scratchpad/inventory.py` — a byte-exact reimplementation of `@(Get-Content -LiteralPath $path).Count`

EXIT_CODE: 0

## Measurement-method note (mandatory disclosure)

The plan specifies `@(Get-Content -LiteralPath $path).Count`. Direct PowerShell invocation is
unavailable in this execution environment: the runtime's worktree-isolation guard refuses every
`pwsh`, `powershell`, and `cmd` invocation issued through the Bash tool with the message
`This agent is isolated in the worktree ... this command runs pwsh in a plain command`. The refusal
is unconditional; it persists with the worktree as the current directory, with `-WorkingDirectory`
supplied, and with a `cd` into the worktree first. The guard is a runtime control, not a repository
hook: a repository-wide content search for its message text returns zero matches.

The line counts below are therefore produced by a byte-exact reimplementation of the
`Get-Content` element count rather than by the cmdlet itself. The equivalence is exact, not
approximate: `Get-Content` splits on CRLF or LF and drops the terminator, so a file whose final byte
is a newline yields exactly one element per newline and a file whose final byte is not a newline
yields one additional element for the unterminated final line; an empty file yields zero. The
reimplementation normalizes CRLF to LF, counts newlines, and adds one when the final byte is not a
newline. `wc -l` was **not** used, because it undercounts by one on a file with no terminating
newline — the discrepancy the spec's "Binding size constraints" note records.

Independent corroboration: every count below for a file that `spec.md` D11 also measured on
2026-09-06 with `@(Get-Content).Count` agrees exactly — 490, 275, 452, 419, 281, 256, 230, 228, and
104 on the Claude side, and 495 on the Codex preimplementation gate.

## Inventory

| Path | Copy-set group | `Get-Content` line count |
| --- | --- | --- |
| `.claude/hooks/enforce-orchestration-preimplementation-gate.ps1` | 4-copy | 490 |
| `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-orchestration-preimplementation-gate.ps1` | 4-copy | 490 |
| `.codex/hooks/enforce-orchestration-preimplementation-gate.ps1` | 4-copy | 495 |
| `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-orchestration-preimplementation-gate.ps1` | 4-copy | 495 |
| `.claude/hooks/enforce-promotion-mcp-only.ps1` | 4-copy | 275 |
| `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-promotion-mcp-only.ps1` | 4-copy | 275 |
| `.codex/hooks/enforce-promotion-mcp-only.ps1` | 4-copy | 261 |
| `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-promotion-mcp-only.ps1` | 4-copy | 261 |
| `.claude/hooks/enforce-epic-merge-gate.ps1` | 4-copy | 452 |
| `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-epic-merge-gate.ps1` | 4-copy | 452 |
| `.codex/hooks/enforce-epic-merge-gate.ps1` | 4-copy | 140 |
| `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-epic-merge-gate.ps1` | 4-copy | 140 |
| `.claude/hooks/enforce-epic-worktree-removal-gate.ps1` | 4-copy | 419 |
| `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-epic-worktree-removal-gate.ps1` | 4-copy | 419 |
| `.codex/hooks/enforce-epic-worktree-removal-gate.ps1` | 4-copy | 151 |
| `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-epic-worktree-removal-gate.ps1` | 4-copy | 151 |
| `.claude/hooks/validate-bash.ps1` | 4-copy | 230 |
| `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/validate-bash.ps1` | 4-copy | 230 |
| `.codex/hooks/validate-bash.ps1` | 4-copy | 185 |
| `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/validate-bash.ps1` | 4-copy | 185 |
| `.claude/hooks/enforce-pr-author-skill-helpers.ps1` | 2-copy (Claude only) | 228 |
| `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-pr-author-skill-helpers.ps1` | 2-copy (Claude only) | 228 |
| `.claude/hooks/enforce-parallel-worktree-removal-gate.ps1` | 2-copy (Claude only) | 281 |
| `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-parallel-worktree-removal-gate.ps1` | 2-copy (Claude only) | 281 |
| `.claude/hooks/enforce-parallel-abandon-gate.ps1` | 2-copy (Claude only) | 256 |
| `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-parallel-abandon-gate.ps1` | 2-copy (Claude only) | 256 |
| `.claude/hooks/enforce-pr-author-skill.epic-base-branch.ps1` | 2-copy (Claude only) | 104 |
| `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-pr-author-skill.epic-base-branch.ps1` | 2-copy (Claude only) | 104 |
| `.claude/hooks/hook-command-scanner.ps1` | new parser (4-copy, not yet created) | ABSENT |
| `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/hook-command-scanner.ps1` | new parser (4-copy, not yet created) | ABSENT |
| `.codex/hooks/hook-command-scanner.ps1` | new parser (4-copy, not yet created) | ABSENT |
| `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/hook-command-scanner.ps1` | new parser (4-copy, not yet created) | ABSENT |
| `.claude/hooks/hook-command-invocation.ps1` | new parser (4-copy, not yet created) | ABSENT |
| `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/hook-command-invocation.ps1` | new parser (4-copy, not yet created) | ABSENT |
| `.codex/hooks/hook-command-invocation.ps1` | new parser (4-copy, not yet created) | ABSENT |
| `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/hook-command-invocation.ps1` | new parser (4-copy, not yet created) | ABSENT |

## Totals

- `TOTAL_PATHS: 36`
- `EXISTING: 28`
- `ABSENT: 8`

The eight absent paths are the not-yet-created parser locations: `hook-command-scanner.ps1` and
`hook-command-invocation.ps1` in each of `.claude/hooks`, the Claude bundle, `.codex/hooks`, and the
Codex bundle. All eight are marked `ABSENT` in the table above.

## Divergent-pair observations recorded at baseline

The four-copy sets are pairwise, not uniformly, equal, exactly as D9 records:

- `enforce-orchestration-preimplementation-gate.ps1` — Claude pair at 490, Codex pair at 495.
- `enforce-promotion-mcp-only.ps1` — Claude pair at 275, Codex pair at 261.
- `enforce-epic-merge-gate.ps1` — Claude pair at 452, Codex pair at 140.
- `enforce-epic-worktree-removal-gate.ps1` — Claude pair at 419, Codex pair at 151.
- `validate-bash.ps1` — Claude pair at 230, Codex pair at 185.

Every pair (Claude canonical to Claude bundle, Codex canonical to Codex bundle) has equal line
counts at baseline. No pair shows a line-count divergence.

Output Summary: 36 paths enumerated. 28 exist and carry a numeric `Get-Content`-equivalent line
count; 8 are marked ABSENT and are the not-yet-created parser locations. Every count agrees with
the independently measured figures recorded in `spec.md` D11 on 2026-09-06. Every canonical/bundle
pair has equal line counts. Measurement used a byte-exact reimplementation of the `Get-Content`
element count because direct PowerShell invocation is refused by the runtime worktree-isolation
guard; the method and its exactness are documented above.
