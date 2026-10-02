# Potential: Python push-down divergences left out of scope by issue #507

- Date captured: 2026-09-29
- Author: epic-planner (epic #770, `push-down-payload-correctness`)
- Source: preparation of issue #507. See `docs/features/active/2026-08-22-push-down-root-folders-divergence-507/spec.md` (Rollout & Follow-up) and `research/research.2026-09-29T14-20.md` (Out-of-Scope Divergences Found).
- Status: Draft. Not promoted. Each entry below can be promoted on its own. #507 AC24 requires only that the spec record them. Filing them as issues is a separate decision.

---

## F-507-1: Python push-down does not merge the managed `.gitignore` block

### Problem / Why

After the copy, the TypeScript push-down merges a managed block into the destination `.gitignore`. The code is `deliverDestinationGitignore` in `extensions/drm-copilot/src/lib/push-down/claude-customizations.ts` (lines 320 and 346-361), with `claude-gitignore-merge.ts`. The Python push-down (`scripts/dev_tools/push_down_claude_customizations.py`) has no equivalent. As a result, the two implementations leave the destination in different states. This divergence is independent of the `config` root that #507 adds.

### Proposed Behavior

Port the managed-block merge to the Python push-down so that it runs after the copy, then extend the #507 parity test to cover it.

### Acceptance Criteria (early draft)

- [ ] Running the Python push-down against a destination leaves the same managed `.gitignore` block as the TypeScript push-down.
- [ ] Destination `.gitignore` lines outside the managed block are preserved byte for byte.
- [ ] The Python/TypeScript parity test fails if either side drops the `.gitignore` merge.

### Constraints & Risks

- This could be folded into #621, which also works on destination state. Decide before promoting.

## F-507-2: Python CLI publishes gitignored `.claude` subtrees from a main checkout

### Problem / Why

`RealPushDownFileSystem.list_files` (`scripts/dev_tools/push_down_copilot_customizations_filesystem.py:99-107`) is an unfiltered `root.rglob("*")`, and `EXCLUDED_RELATIVE_PATHS` holds only `settings.local.json`. When the Python CLI runs from a main checkout, it therefore publishes `.claude/worktrees/**` and `.claude/state/**`, both of which are gitignored at `.gitignore:21,68`. The TypeScript push-down reads the curated bundle and never sees these trees.

### Proposed Behavior

The Python source enumeration excludes gitignored runtime trees, either by honoring the repository `.gitignore` or through an explicit exclusion list that matches the bundle contents.

### Acceptance Criteria (early draft)

- [ ] A Python push-down from a checkout containing `.claude/worktrees/` and `.claude/state/` writes neither tree to the destination.
- [ ] The Python and TypeScript published file sets match for the same source revision.

### Constraints & Risks

- `.claude/worktrees/**` can hold complete repository checkouts, so publishing it can write a large volume of files.

## Next Step

- [ ] Decide whether to promote separately or fold into #621.
- [ ] Promote through `mcp__drm-copilot__potential_to_issue`.
