# repo-housekeeping-audit (Issue #340)

- Date captured: 2026-07-09
- Author: Dan Moisan
- Status: Promoted -> docs/features/active/repo-housekeeping-audit/ (Issue #340)

- Issue: #340
- Issue URL: https://github.com/drmoisan/drm-copilot/issues/340
- Last Updated: 2026-07-09
## Problem / Why

`docs/features/` had accumulated housekeeping gaps: twelve folders under `docs/features/active/` corresponded to work already merged to `main`, one closed-worthy issue (#116) remained open with its merging PRs not linked via a closing keyword, the root `CLAUDE.md` had been accidentally deleted by an unrelated prior commit, `README.md` had drifted from the current skill/agent/command inventory, and several previously-identified technical-debt items had never been converted into tracked GitHub issues.

## Proposed Behavior

Perform a repository-wide audit and reconciliation pass:
1. Identify `docs/features/active/*` folders whose work is already delivered; relocate them to `docs/features/completed/*` and reconcile GitHub issue/PR linkage for each.
2. Check `docs/features/potential/*` for entries duplicating `active/`, `archive/`, or `completed/`; delete confirmed duplicates.
3. Scan `docs/`, `README.md`, and feature-folder audit artifacts for identified-but-unresolved technical debt; open and promote a tracked GitHub issue for each genuinely outstanding item via the MCP feature-promotion-lifecycle tooling.
4. Refresh `README.md` for accuracy against the current repository state.

## Acceptance Criteria (early draft)

- [x] All `docs/features/active/*` folders confirmed delivered are relocated to `docs/features/completed/*`, with GitHub issues closed and linked to their merging PR.
- [x] `docs/features/potential/*` duplicate entries (if any) are deleted; retained entries are confirmed non-duplicate.
- [x] Genuinely outstanding technical debt is captured as new, promoted GitHub issues.
- [x] `README.md` accuracy is verified against current skills/agents/hooks/commands/MCP tools and corrected where stale.

## Constraints & Risks

- This is a documentation/GitHub-metadata task with no production code diff; the standard per-language toolchain (format/lint/type-check/test) does not apply to any changed file.
- Risk: folder relocation could break relative links inside moved feature-folder artifacts; mitigated by using `git mv` (pure renames, no content edits) and confirming no absolute-path-dependent tooling references the old `active/` location.
- Risk: restoring `CLAUDE.md` from git history could reintroduce stale content; mitigated by verifying every file/path it references still resolves in the current tree before restoring it.

## Test Conditions to Consider

- [x] Integration scenario: `git status` shows the expected renames/additions/modifications with no unintended changes.
- [x] Verification: every path referenced by the restored `CLAUDE.md` and the updated `README.md` resolves in the current working tree.
- [ ] CLI/API examples: not applicable (no CLI/API surface changed).

## Evidence

- `docs/research/2026-07-09-active-features-delivery-status-audit.md`
- `docs/research/2026-07-09-potential-entries-duplicate-audit.md`
- `docs/research/2026-07-09-remaining-technical-debt-audit.md`
- Commit `541efcd` ("docs: complete feature-audit housekeeping and reconcile docs") on branch `drm-copilot-wt-2026-07-09T09-26`.

## Next Step

- [ ] Promote to GitHub issue (feature request template)
- [ ] Create `docs/features/active/repo-housekeeping-audit/` folder from the template

