# remove-secondary-worktrees-command (Issue #194)

- Date captured: 2026-06-17
- Author: Dan Moisan
- Status: Promoted -> docs/features/active/remove-secondary-worktrees-command/ (Issue #194)

- Issue: #194
- Issue URL: https://github.com/drmoisan/drm-copilot/issues/194
- Last Updated: 2026-06-17
- Work Mode: full-feature

## Problem / Why

The repository workflow creates secondary git worktrees (for example, the `New Claude Worktree Session` command creates `<repo>-wt-<timestamp>` worktrees). These accumulate and must be cleaned up. A draft PowerShell script exists at `scripts/dev-tools/remove-worktrees.ps1`, but it is untested, is not integrated into the extension workflow, and uses a Windows-centric file-lock probe that does not generalize. There is no extension command to remove secondary worktrees safely.

## Proposed Behavior

Add a VS Code command to the drm-copilot extension that removes all secondary worktrees of the current repository. The command must:

- Enumerate worktrees and exclude the primary (main) worktree.
- Attempt to remove each secondary worktree.
- Be robust to errors: a worktree that cannot be fully removed is left intact (not partially deleted), and the command continues with the remaining worktrees.
- Report which worktrees were removed and which were skipped, with reasons.
- Be implemented in TypeScript to avoid runtime dependencies and be fully unit-tested with pure logic separated from the git I/O boundary.

## Acceptance Criteria (early draft)

- [ ] A new extension command removes all secondary worktrees and never removes the primary worktree.
- [ ] A worktree that cannot be fully removed is skipped and left intact; the command continues with remaining worktrees.
- [ ] The command reports removed and skipped worktrees with reasons.
- [ ] Implemented in TypeScript with pure logic separated from git I/O.
- [ ] Unit tests cover positive, negative, and edge cases; coverage meets repository thresholds.
- [ ] The command is registered in `package.json` contributions and `extension.ts`, and documented in the extension README.

## Constraints & Risks

- Cross-platform: the file-lock probe in the draft PowerShell script does not translate to Node/TypeScript. The non-removability determination must rely on `git worktree remove` semantics (non-`--force` failure for dirty/locked worktrees) rather than OS-specific lock probing.
- Destructive operation: must never partially delete a worktree or remove the primary worktree.
- Must follow the extension's established command-runtime and pure-logic/I/O separation patterns.
- Bundled-mirror and toolchain (Prettier/ESLint/TSC/Jest) obligations apply.

## Test Conditions to Consider

- [ ] Parsing of `git worktree list --porcelain`, including the primary-worktree exclusion.
- [ ] Aggregation of per-worktree success/failure outcomes.
- [ ] Skip-on-failure behavior with continuation.
- [ ] No-secondary-worktrees case.
- [ ] Command registration and disposal.

## Next Step

- [ ] Promote to GitHub issue (feature request template)
- [ ] Create `docs/features/active/remove-secondary-worktrees-command/` folder from the template