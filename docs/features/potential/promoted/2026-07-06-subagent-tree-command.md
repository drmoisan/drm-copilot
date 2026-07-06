# subagent-tree-command (Issue #320)

- Date captured: 2026-07-06
- Author: Dan Moisan
- Status: Promoted -> docs/features/active/subagent-tree-command/ (Issue #320)

- Issue: #320
- Issue URL: https://github.com/drmoisan/drm-copilot/issues/320
- Last Updated: 2026-07-06
## Problem / Why

The `drm-copilot` VS Code extension has no way to inspect the subagent call tree of a Claude Code
session. Session transcripts on disk (`.claude/projects/**`) record a root session plus flattened
subagent transcripts with meta files that encode a deterministic parent→child spawn relationship.
Operators need a way to visualize that delegation structure and detect mid-session model switches.

## Proposed Behavior

Add a VS Code command `drmCopilotExtension.showSubagentTree` ("drm-copilot: Show Subagent Tree").
Given a root session (user-picked `.jsonl` under `.claude/projects/**`, or the active session), it
deterministically builds and renders the subagent tree. The parsing/tree logic lives in a pure,
host-neutral module (`buildSubagentTree` + `formatTree`) with full unit tests; a thin host-bound
command file does only the VS Code wiring.

Deterministic algorithm: scan the root and every `subagents/*.jsonl` for `message.model` values and
ordered `Agent` tool-use ids; match each child's `meta.toolUseId` to the exact spawning tool-use id
(1:1, no heuristics); order siblings by spawn line order; render each node as
`agentType · [sorted,comma-joined models] · depth · description`.

## Acceptance Criteria (early draft)

- [ ] Command registered in `package.json` and activated; invoking it renders the tree for a
  selected/active session.
- [ ] Pure builder + renderer unit-tested (positive, empty-subagents, multi-model node, multi-depth
  nesting, orphan/unmatched `toolUseId` handled gracefully).
- [ ] Full TypeScript toolchain passes (format → lint → type-check → tests), coverage >= 85% line /
  >= 75% branch on new files, no production file excluded from coverage.
- [ ] Local feature-review clean of blocking findings.

## Constraints & Risks

- Extension lives at `extensions/drm-copilot/`; tests run on Jest (v8 coverage). No new dependencies
  (fast-check is not installed; property tests not required for this dev-tooling module). Files < 500
  lines.

## Test Conditions to Consider

- [ ] Unit coverage: positive tree, empty subagents, multi-model node, multi-depth nesting, orphan
  `toolUseId`, sibling ordering, blank/malformed transcript lines ignored.
- [ ] Host-wiring: zero-candidate, single-candidate auto-select, multi-candidate quick-pick.

## Next Step

- [ ] Promote to GitHub issue (feature request template)
- [x] `docs/features/active/subagent-tree-command/` folder already exists with the implemented work.

## Implementation Status

Implemented and committed on branch work (commit `ca0797e`); this issue is being opened to track the
change through the standard PR + CI workflow.
