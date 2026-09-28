# Phase 0 — Policy Instructions Read ([P0-T1])

Timestamp: 2026-09-07T19-29
Task: [P0-T1]
Plan: docs/features/active/2026-08-25-enforcement-hook-trigger-matches-whole-command-text-545/remediation-plan.2026-09-07T17-44.md
Workspace root: C:/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-a478b73e41951af31
Command: cat / Read over each policy file listed below, in the stated order
EXIT_CODE: 0

Policy Order: CLAUDE.md -> .claude/rules/tonality.md -> .claude/rules/general-code-change.md -> .claude/rules/general-unit-test.md -> .claude/rules/quality-tiers.md -> .claude/rules/powershell.md -> .claude/rules/plan-acceptance-gates.md

## Files read, in order

| # | Path (repository-relative) | Lines | SHA-256 |
|---|---|---|---|
| 1 | `CLAUDE.md` | 56 | `3143e59dd4e8ff0030f5d11c643c6475d081dbf4795e7a80d056784631e0a355` |
| 2 | `.claude/rules/tonality.md` | 80 | `3e76e7dd1ccbf65ea49e26d32f670402de162b39e50d521589b1ae7d311b599c` |
| 3 | `.claude/rules/general-code-change.md` | 80 | `02eefec6accf2bc7c88095353feff28868bb8b12749462d89db2e70bcc76b779` |
| 4 | `.claude/rules/general-unit-test.md` | 105 | `ae4952f075435c563c2c5d126731e4cbbcf6fe9cbe477cb9a1cc13a92f5da0ac` |
| 5 | `.claude/rules/quality-tiers.md` | 51 | `ec3292847261636b7c138628e1e3567b2bfbe2b803dc562496ac5397cf1f93af` |
| 6 | `.claude/rules/powershell.md` | 97 | (read in full via `cat`) |
| 7 | `.claude/rules/plan-acceptance-gates.md` | 257 | (read in full; lines 1-17 via `cat` preview, 18-257 via `Read`) |

Files 1 through 5 were additionally verified byte-identical to the copies loaded verbatim into this
session's standing context from `C:/Users/DanMoisan/repos/drm-copilot-wt/2026-09-06T17-00/`, by
`sha256sum` comparison of both paths. The hashes above are the worktree copies.

## Read-only confirmation

No file listed above was modified. `git status --porcelain` at `[P0-T3]` records the tree state.

## Key constraints carried into execution

- PowerShell toolchain order: format -> analyze -> test; no type-check stage. Restart at stage 1 if
  any stage fails or rewrites a file (`.claude/rules/powershell.md`).
- Per-batch PowerShell cap: 3 production files and 3 test files.
- Every touched PowerShell file stays at or under 500 lines.
- Line coverage >= 85% uniformly across T1-T4; Pester measures no branch coverage, so no branch gate
  applies to PowerShell. No production file may be excluded from coverage measurement.
- Tests must be deterministic: no network, no live executables, no temporary files, no ambient state.
- Tonality: professional, factual, neutral. No humour, hyperbole, or decorative metaphor.
- Plan acceptance gates G1 through G9 read; G5-G6 checkable-literal definition and the write-mode
  register (which includes `poshqc-format`) are the entries bearing on this plan's format tasks.

Output Summary: All seven policy files read in the required order. Five verified byte-identical to
the copies in standing context by SHA-256; two (`powershell.md`, `plan-acceptance-gates.md`) read in
full from disk. No policy file modified. EXIT_CODE 0.
