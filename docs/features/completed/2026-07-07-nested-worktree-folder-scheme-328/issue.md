# nested-worktree-folder-scheme (Issue #328)

- Date captured: 2026-07-07
- Author: Dan Moisan
- Status: Promoted -> docs/features/active/2026-07-07-nested-worktree-folder-scheme-328/ (Issue #328)
- GitHub issue: #328

- Issue: #328
- Issue URL: https://github.com/drmoisan/drm-copilot/issues/328
- Last Updated: 2026-07-07
- Work Mode: full-feature

## Problem / Why

The `drm-copilot: New Claude Worktree Session` command creates each new worktree as a
sibling directory named `<repo>-wt-yyyy-MM-dd-HH-mm`. Over time this produces a
proliferation of flat sibling folders in the repos directory, which is disorganized and
hard to browse.

## Proposed Behavior

Change the worktree location scheme from `<repo>-wt-yyyy-MM-dd-HH-mm` to the nested
pattern `<repo>-wt/yyyy-MM-ddTHH-mm`:

- A single grouping folder `<repo>-wt` holds every timestamped worktree for that repo.
- The leaf directory is the timestamp `yyyy-MM-ddTHH-mm` (ISO-style `T` separator
  between the date and time components; 24-hour `HH`).
- Any folder in the chain that does not already exist must be created before
  `git worktree add` runs.

## Acceptance Criteria (early draft)

- [ ] New worktrees are created at `<parent>/<repo>-wt/<yyyy-MM-ddTHH-mm>`.
- [ ] The `<repo>-wt` grouping directory is created if it does not exist.
- [ ] The `drm-copilot: Remove Secondary Worktrees` command still discovers and removes
      worktrees created under the nested scheme.
- [ ] The subagent-tree transcript-directory matcher still resolves worktree transcript
      directories under the new scheme.
- [ ] Both the PowerShell script and the TypeScript command builders produce the new
      scheme consistently, and all corresponding tests are updated.

## Constraints & Risks

- Cross-cutting change spanning PowerShell (`scripts/dev-tools`) and TypeScript
  (`extensions/drm-copilot/src`), plus the bundled resource template.
- The worktree naming convention is consumed by `subagent-tree/workspace-encoding.ts`
  (`WORKTREE_INFIX = "-wt-"`); the encoded directory name must continue to match.
- The `Remove Secondary Worktrees` command must not be broken; verify empty
  `<repo>-wt` parent handling.
- Branch-name policy (whether the branch also adopts a nested-style name) must be
  decided during spec.

## Test Conditions to Consider

- [ ] Path/branch builder unit tests (PowerShell Pester + Vitest).
- [ ] Timestamp formatter unit tests for the `T` separator.
- [ ] Parent-directory creation behavior.
- [ ] Remove-worktrees discovery under the nested scheme.
- [ ] workspace-encoding matcher under the encoded nested path.

## Next Step

- [x] Promote to GitHub issue (#328)
- [ ] Create `docs/features/active/` folder from the template
