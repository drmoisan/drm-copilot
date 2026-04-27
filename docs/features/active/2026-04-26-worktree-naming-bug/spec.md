# Bug Fix Spec — Worktree Naming

## Summary

The `drm-copilot: New Claude Worktree Session` command produces incorrectly named worktrees and branches. Two root causes are identified.

---

## Bug 1 — Hardcoded repo name prefix

### Current behavior
Both the TypeScript helper `buildWorktreePath` and the PowerShell helper `Build-WorktreePath` hardcode `drm-copilot` as the worktree directory prefix. This means every worktree is named `drm-copilot-wt-…` regardless of which repository the user is working in.

### Root cause
- TypeScript (`claude-worktree-session.ts` line 81): `` `${normalizedParent}/drm-copilot-wt-${timestamp}-${shortName}` ``
- PowerShell (`new-claude-worktree-session.ps1` line 62): `"$WorktreeParentPath/drm-copilot-wt-$Timestamp-$ShortName"`
- PowerShell template (`resources/templates/new-claude-worktree-session.ps1` line 62): same as above

### Required behavior
The prefix must be the **destination repo's basename**:
- TypeScript: derive from `path.basename(workspaceRoot)`, passed as a `repoName` parameter to `buildWorktreePath`.
- PowerShell: derive from `Split-Path -Leaf $repoRoot` inside the script body; pass as `$RepoName` to `Build-WorktreePath`.

---

## Bug 2 — Timestamp format and branch naming

### Current behavior
- Timestamp format: `yyyyMMddHHmmss` — no separators, includes seconds.
- Branch name format: `feature/<timestamp>-<shortName>`.
- Worktree name format: `<prefix>-wt-<timestamp>-<shortName>`.

### Required behavior
- Timestamp format: `yyyy-MM-dd-HH-mm` — dash-separated, **no seconds**.
- Worktree directory name: `<repo-name>-wt-<timestamp>` — no ShortName suffix.
- Branch name: identical to the worktree directory name, i.e., `<repo-name>-wt-<timestamp>` — no `feature/` prefix, no ShortName.

### Consequence: ShortName removal
ShortName is no longer part of the naming scheme. The following must be removed:
- The mandatory `$ShortName` parameter from both PowerShell scripts.
- The `shortName` parameter from `buildWorktreePath` and `buildBranchName` in TypeScript.
- The `promptForShortName` call from `extension.ts`.

---

## Affected Files

| File | Role | Changes |
|------|------|---------|
| `extensions/drm-copilot/src/claude-worktree-session.ts` | TypeScript pure helpers | Fix `formatWorktreeTimestamp`, `buildWorktreePath`, `buildBranchName` signatures and output |
| `extensions/drm-copilot/src/extension.ts` | VS Code command handler | Remove `promptForShortName`, derive `repoName`, update helper calls |
| `scripts/dev-tools/new-claude-worktree-session.ps1` | Standalone PowerShell script | Fix `Get-WorktreeTimestamp`, `Build-WorktreePath`, `Build-BranchName`; derive repo name |
| `extensions/drm-copilot/resources/templates/new-claude-worktree-session.ps1` | PowerShell template (sync of above) | Same changes as standalone script |
| `extensions/drm-copilot/test/claude-worktree-session.test.ts` | TypeScript unit tests | Update all fixtures to new format and signatures |
| `tests/scripts/dev-tools/new-claude-worktree-session.Tests.ps1` | Pester tests | Update all fixtures to new format and signatures |

---

## Acceptance Criteria

- [ ] AC1: `formatWorktreeTimestamp` returns a string matching `yyyy-MM-dd-HH-mm` (no seconds, dashes between all fields).
- [ ] AC2: `buildWorktreePath` accepts `repoName` (not `shortName`) and returns `<parent>/<repoName>-wt-<timestamp>`.
- [ ] AC3: `buildBranchName` accepts `repoName` (not `shortName`) and returns `<repoName>-wt-<timestamp>` (no `feature/` prefix).
- [ ] AC4: The TypeScript `extension.ts` command handler no longer prompts for ShortName; it derives `repoName` from `path.basename(workspaceRoot)`.
- [ ] AC5: `Get-WorktreeTimestamp` in both PowerShell scripts returns a string matching `yyyy-MM-dd-HH-mm`.
- [ ] AC6: `Build-WorktreePath` in both PowerShell scripts accepts `$RepoName` (not `$ShortName`) and returns `$WorktreeParentPath/$RepoName-wt-$Timestamp`.
- [ ] AC7: `Build-BranchName` in both PowerShell scripts accepts `$RepoName` (not `$ShortName`) and returns `$RepoName-wt-$Timestamp`.
- [ ] AC8: The `$ShortName` mandatory parameter is removed from both PowerShell scripts.
- [ ] AC9: All TypeScript tests pass with updated fixtures reflecting the new naming scheme.
- [ ] AC10: All Pester tests pass with updated fixtures reflecting the new naming scheme.
- [ ] AC11: Full toolchain passes (Prettier → ESLint → TSC → Jest; PoshQC format → PSScriptAnalyzer → Pester) with zero errors and no coverage regression.
