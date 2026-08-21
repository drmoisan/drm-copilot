# Baseline — `flow.ts` Line Count [P0-T9]

Timestamp: 2026-08-20T18-54

Command: `pwsh -NoProfile -Command "(Get-Content -LiteralPath 'extensions/drm-copilot/src/lib/new-active-feature-folder/flow.ts').Count"`

Working directory: `C:/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-a2b9a9c0d25db8e3b`

EXIT_CODE: 0

## Raw Output

```
444
```

Output Summary: Pre-change line count of `extensions/drm-copilot/src/lib/new-active-feature-folder/flow.ts` is **444 lines**, matching the expected value stated in the plan and in the corrected `spec.md` INV-5 / AC-10 figures. The `.claude/rules/general-code-change.md` limit is 500 lines, so headroom before the change is **56 lines**. Any addition in Phase 2 must keep the post-change count at or below 500; if a compact disposition helper would exceed that, P2-T1 requires placing the helper in `io.ts` (396 lines) instead. Post-change count is recorded by P2-T7 and re-confirmed by P6-T4.
