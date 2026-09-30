# worktree-run-resolution-review-nits (Potential Bug)

- Date captured: 2026-09-30
- Author: Dan Moisan
- Status: Draft
- Related: #690

## Summary

The #690 code review (`docs/features/active/2026-09-17-agent-payload-gates-resolve-session-root-690/code-review.2026-09-30T01-45.md`) recorded two Nits that remediation R1 left unfixed.

- CR-4: `Test-WorktreeRunPathEqual` in `.claude/lib/worktree-resolution/WorktreeRunResolution.psm1` compares case-insensitively only when a side starts with a drive letter, so a UNC root recorded with different casing compares case-sensitively.
- CR-5: the final deny of `.claude/hooks/enforce-parallel-worktree-removal-gate.ps1` repeats the `PARALLEL_WORKTREE_REMOVAL_BLOCKED:` token when both run kinds resolve `NoTarget`.

## Scope

- `.claude/lib/worktree-resolution/WorktreeRunResolution.psm1` (`Test-WorktreeRunPathEqual`) and its record suite.
- `.claude/hooks/enforce-parallel-worktree-removal-gate.ps1` (final deny) and the suites that assert its exact text.
- The bundle mirrors of both files.

## Acceptance Criteria (early draft)

- [ ] A UNC row in `tests/scripts/claude-lib/worktree-resolution/WorktreeRunResolution.Record.Tests.ps1`, and UNC comparison either made case-insensitive or documented as case-sensitive.
- [ ] The parallel removal gate's final deny carries a single leading `PARALLEL_WORKTREE_REMOVAL_BLOCKED:` token, with the existing exact-text rows updated.
- [ ] Every changed primary file is byte-identical to its bundle mirror, and each file stays at or below 500 lines.

## Constraints & Risks

- Changing the deny text changes what callers see; any caller that matches on the full text rather than the leading token must be checked.
- Both files are imported by live PreToolUse hooks; changes follow the single-write procedure with the suites run immediately after.

## Next Step

- [ ] Promote this entry through the MCP promotion tool.
- [ ] Create the active feature folder.
