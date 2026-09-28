# Batch D — copy-set parity

Task: `[P4-T5]`
Timestamp: 2026-09-07T22-15

## Mirror

Command:
`cp .claude/hooks/validate-bash.ps1 extensions/drm-copilot/resources/claude-customizations/.claude/hooks/validate-bash.ps1`
EXIT_CODE: 0

`cp` does not pass through the `Write|Edit` PreToolUse matcher, so the mirror write consumes no
PowerShell batch-budget slot.

## Byte comparison

Command:
`cmp -s .claude/hooks/validate-bash.ps1 extensions/drm-copilot/resources/claude-customizations/.claude/hooks/validate-bash.ps1`
EXIT_CODE: 0

## SHA-256

Command: `sha256sum` over the canonical and the mirror.
EXIT_CODE: 0

| File | SHA-256 |
|---|---|
| `.claude/hooks/validate-bash.ps1` | `21654b66f67a2796fadd584073e5f19840e6dd6229ec1b242a1c12fe79311676` |
| `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/validate-bash.ps1` | `21654b66f67a2796fadd584073e5f19840e6dd6229ec1b242a1c12fe79311676` |

The two values are equal.

## `.codex/hooks/validate-bash.ps1` was not modified

The Codex runtime carries no `cd`-chain rule and is explicitly out of scope for R-2.d. Two
complementary spans are recorded, because the anchored diff is blind to an untracked path and
porcelain status goes empty once a change is committed.

Command:
`git diff --name-only 26dba29533ba70f6cd80d14ac3c87ac24ca82aca -- .codex/hooks/validate-bash.ps1 extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/validate-bash.ps1`
EXIT_CODE: 0

```
(no output)
```

Command:
`git status --porcelain .codex/hooks/validate-bash.ps1 extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/validate-bash.ps1`
EXIT_CODE: 0

```
(no output)
```

Both outputs are empty. Neither Codex `validate-bash.ps1` copy was modified in this cycle, and
neither is untracked.

## Output Summary

The Claude canonical and its bundle mirror are byte-identical (`cmp -s` exit 0, equal SHA-256
`21654b66…1676`). Both Codex `validate-bash.ps1` copies are unchanged against the cycle-scope anchor
and clean in porcelain status. Copy-set parity holds for batch D.

TOOLCHAIN_SUBSTITUTION: not applicable. This task runs no PowerShell toolchain stage; all commands
are `cp`, `cmp`, `sha256sum`, and `git` run through the Bash tool.
