# [P12-T2] Nine-hook copy-set coverage

Timestamp: 2026-09-07T15-46

Command:

```
git diff origin/epic/cleanup-merged-worktrees-hardening-integration --name-status
git status --porcelain
```

EXIT_CODE: 0 (both commands)

TOOLCHAIN_SUBSTITUTION: not applicable. This task derives from the [P12-T1] enumeration and invokes
`git` only. The set comparison between the expected 28-path copy set and the observed enumeration is
performed in Python rather than PowerShell, because `pwsh` is not invocable in this session; the
comparison consumes the verbatim `git` output recorded by [P12-T1] and introduces no other data.

Source enumeration: `evidence/qa-gates/scope-and-size.2026-09-07T15-46.md` ([P12-T1]).

## Output Summary

All 28 hook copy paths across the nine in-scope hooks are present in the name-status enumeration,
each with status `M` (modified). No copy-set member is missing. No file under `.github/instructions/`
and no file under `.claude/rules/` appears anywhere in the enumeration. No hook outside the nine — and
no file in any of the four hook directories other than the nine hooks and the two parser siblings —
appears in groups 1 through 4 of the [P12-T1] enumeration.

| Check | Expected | Observed |
| --- | --- | --- |
| Hook copy paths present and changed | 28 | **28** |
| Hook copy paths missing from the enumeration | 0 | **0** |
| Paths under `.github/instructions/` | 0 | **0** |
| Paths under `.claude/rules/` | 0 | **0** |
| Hook-directory paths outside the nine hooks and the parser pair | 0 | **0** |

## The 28 hook copy paths, with observed status

### The five four-copy hooks (20 paths)

| # | Hook | Copy | Path | Status |
| --- | --- | --- | --- | --- |
| 1 | `enforce-orchestration-preimplementation-gate.ps1` | Claude canonical | `.claude/hooks/enforce-orchestration-preimplementation-gate.ps1` | M |
| 2 | `enforce-orchestration-preimplementation-gate.ps1` | Codex canonical | `.codex/hooks/enforce-orchestration-preimplementation-gate.ps1` | M |
| 3 | `enforce-orchestration-preimplementation-gate.ps1` | Claude bundle | `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-orchestration-preimplementation-gate.ps1` | M |
| 4 | `enforce-orchestration-preimplementation-gate.ps1` | Codex bundle | `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-orchestration-preimplementation-gate.ps1` | M |
| 5 | `enforce-promotion-mcp-only.ps1` | Claude canonical | `.claude/hooks/enforce-promotion-mcp-only.ps1` | M |
| 6 | `enforce-promotion-mcp-only.ps1` | Codex canonical | `.codex/hooks/enforce-promotion-mcp-only.ps1` | M |
| 7 | `enforce-promotion-mcp-only.ps1` | Claude bundle | `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-promotion-mcp-only.ps1` | M |
| 8 | `enforce-promotion-mcp-only.ps1` | Codex bundle | `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-promotion-mcp-only.ps1` | M |
| 9 | `enforce-epic-merge-gate.ps1` | Claude canonical | `.claude/hooks/enforce-epic-merge-gate.ps1` | M |
| 10 | `enforce-epic-merge-gate.ps1` | Codex canonical | `.codex/hooks/enforce-epic-merge-gate.ps1` | M |
| 11 | `enforce-epic-merge-gate.ps1` | Claude bundle | `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-epic-merge-gate.ps1` | M |
| 12 | `enforce-epic-merge-gate.ps1` | Codex bundle | `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-epic-merge-gate.ps1` | M |
| 13 | `enforce-epic-worktree-removal-gate.ps1` | Claude canonical | `.claude/hooks/enforce-epic-worktree-removal-gate.ps1` | M |
| 14 | `enforce-epic-worktree-removal-gate.ps1` | Codex canonical | `.codex/hooks/enforce-epic-worktree-removal-gate.ps1` | M |
| 15 | `enforce-epic-worktree-removal-gate.ps1` | Claude bundle | `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-epic-worktree-removal-gate.ps1` | M |
| 16 | `enforce-epic-worktree-removal-gate.ps1` | Codex bundle | `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-epic-worktree-removal-gate.ps1` | M |
| 17 | `validate-bash.ps1` | Claude canonical | `.claude/hooks/validate-bash.ps1` | M |
| 18 | `validate-bash.ps1` | Codex canonical | `.codex/hooks/validate-bash.ps1` | M |
| 19 | `validate-bash.ps1` | Claude bundle | `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/validate-bash.ps1` | M |
| 20 | `validate-bash.ps1` | Codex bundle | `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/validate-bash.ps1` | M |

### The four two-copy hooks (8 paths)

| # | Hook | Copy | Path | Status |
| --- | --- | --- | --- | --- |
| 21 | `enforce-pr-author-skill-helpers.ps1` | Claude canonical | `.claude/hooks/enforce-pr-author-skill-helpers.ps1` | M |
| 22 | `enforce-pr-author-skill-helpers.ps1` | Claude bundle | `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-pr-author-skill-helpers.ps1` | M |
| 23 | `enforce-parallel-worktree-removal-gate.ps1` | Claude canonical | `.claude/hooks/enforce-parallel-worktree-removal-gate.ps1` | M |
| 24 | `enforce-parallel-worktree-removal-gate.ps1` | Claude bundle | `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-parallel-worktree-removal-gate.ps1` | M |
| 25 | `enforce-parallel-abandon-gate.ps1` | Claude canonical | `.claude/hooks/enforce-parallel-abandon-gate.ps1` | M |
| 26 | `enforce-parallel-abandon-gate.ps1` | Claude bundle | `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-parallel-abandon-gate.ps1` | M |
| 27 | `enforce-pr-author-skill.epic-base-branch.ps1` | Claude canonical | `.claude/hooks/enforce-pr-author-skill.epic-base-branch.ps1` | M |
| 28 | `enforce-pr-author-skill.epic-base-branch.ps1` | Claude bundle | `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-pr-author-skill.epic-base-branch.ps1` | M |

## Nothing outside the nine hooks

Groups 1 through 4 of the [P12-T1] enumeration were scanned for any path that lies in one of the four
hook directories (`.claude/hooks/`, `.codex/hooks/`, and their two bundle mirrors) and is neither one
of the 28 copy paths above nor one of the 8 parser-sibling paths in group 2. The scan returned
**0** such paths.

The same enumeration was scanned for any path beginning `.github/instructions/` or `.claude/rules/`.
That scan returned **0** paths, over the whole union of 137 and not merely over groups 1 through 4,
so the policy-document prohibition holds for the change as a whole.

Group 2 of the enumeration holds exactly the 8 parser-sibling locations, all with status `A` (added).
Those are new files delivered by this change, not hooks outside the nine, and they are the reason the
hook-directory scan above excludes them explicitly rather than silently.

Group 3 holds the five registry files and group 4 holds 21 test files; neither group contains a hook.
Group 5 is the single issue #539 specification annotated by Phase 11. Group 6 holds
feature-lifecycle documents only.
