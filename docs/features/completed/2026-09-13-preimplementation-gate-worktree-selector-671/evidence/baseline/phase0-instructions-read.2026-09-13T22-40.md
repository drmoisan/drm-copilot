# Phase 0 Policy Read Evidence — issue #671

Timestamp: 2026-09-17T07-49
Task: [P0-T1]
Policy Order: CLAUDE.md -> .claude/rules/general-code-change.md -> .claude/rules/general-unit-test.md -> .claude/rules/quality-tiers.md -> .claude/rules/powershell.md -> .claude/rules/plan-acceptance-gates.md

## Files read (in order)

1. `CLAUDE.md`
2. `.claude/rules/general-code-change.md`
3. `.claude/rules/general-unit-test.md`
4. `.claude/rules/quality-tiers.md`
5. `.claude/rules/powershell.md`
6. `.claude/rules/plan-acceptance-gates.md`

## Notes

- Items 2 through 4 were read from the session-loaded copies and confirmed byte-identical to the worktree copies with `cmp` (all three reported identical).
- Item 1, 5, and 6 were read directly from the worktree.
- Key obligations carried forward: 500-line cap per file; format -> analyze -> test loop with restart on change or failure; line coverage >= 85% (no PowerShell branch gate); no temporary files in tests; no policy-file edits.
- Execution-route note: no PowerShell tool is available in this agent session. Direct PowerShell steps in this plan are issued as `pwsh -NoProfile -File <scratchpad .ps1>` from a scratchpad `sh` wrapper, with the working directory set to the worktree root. This route was probed first (pwsh 7.6.6, Pester 5.6.1, PSScriptAnalyzer 1.25.0 available).
