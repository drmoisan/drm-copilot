# Batch A — Canonical/Bundle Parity (scanner pair)

Timestamp: 2026-09-07T21-18
Task: [P1-T6]
Feature: enforcement-hook-trigger-matches-whole-command-text (#545)

Command: cp .claude/hooks/hook-command-scanner.ps1 extensions/drm-copilot/resources/claude-customizations/.claude/hooks/hook-command-scanner.ps1 ; cp .codex/hooks/hook-command-scanner.ps1 extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/hook-command-scanner.ps1 ; cmp -s (per pair) ; sha256sum (all four)
EXIT_CODE: 0

## Mirror commands

```
$ cp .claude/hooks/hook-command-scanner.ps1 extensions/drm-copilot/resources/claude-customizations/.claude/hooks/hook-command-scanner.ps1
EXIT_CODE: 0

$ cp .codex/hooks/hook-command-scanner.ps1 extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/hook-command-scanner.ps1
EXIT_CODE: 0
```

Both mirrors were written with `cp`, which does not pass through the `Write|Edit` PreToolUse matcher
and therefore consumes no batch-budget slot, as standing constraint 7 states.

## `cmp -s` byte comparisons

```
$ cmp -s .claude/hooks/hook-command-scanner.ps1 extensions/drm-copilot/resources/claude-customizations/.claude/hooks/hook-command-scanner.ps1
EXIT_CODE: 0

$ cmp -s .codex/hooks/hook-command-scanner.ps1 extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/hook-command-scanner.ps1
EXIT_CODE: 0
```

Both canonical-against-mirror comparisons exit 0. Byte comparison is a stronger claim than hash
equality and is recorded first for that reason; the hashes below corroborate it.

## SHA-256 of all four copies

| File | SHA-256 |
|---|---|
| `.claude/hooks/hook-command-scanner.ps1` | `d8543cb9c460a3fff80377b63dbcffe97fc89b9da582addc48132960962add0b` |
| `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/hook-command-scanner.ps1` | `d8543cb9c460a3fff80377b63dbcffe97fc89b9da582addc48132960962add0b` |
| `.codex/hooks/hook-command-scanner.ps1` | `d8543cb9c460a3fff80377b63dbcffe97fc89b9da582addc48132960962add0b` |
| `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/hook-command-scanner.ps1` | `d8543cb9c460a3fff80377b63dbcffe97fc89b9da582addc48132960962add0b` |

**The Claude pair is equal to each other and the Codex pair is equal to each other**, which is what
this task's acceptance requires. All four are in fact the same hash, because the two canonical
parser files are byte-identical across runtimes — a property the branch already held at 450 lines
each and continues to hold at 483 lines each after Edit 1.

## Output Summary

Both `cp` mirrors exit 0, both `cmp -s` canonical-against-mirror comparisons exit 0, and all four
scanner copies carry SHA-256 `d8543cb9c460a3fff80377b63dbcffe97fc89b9da582addc48132960962add0b`.
Copy-set parity holds for the scanner pair after Edit 1. The mirrors were written with `cp` and
consumed no batch-budget slot.
