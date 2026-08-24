# subagent-tree-mcp-and-dropdown (Issue #334)

- Date captured: 2026-07-09
- Author: Dan Moisan
- Status: Promoted -> docs/features/active/subagent-tree-mcp-and-dropdown/ (Issue #334)

- Issue: #334
- Issue URL: https://github.com/drmoisan/drm-copilot/issues/334
- Last Updated: 2026-07-09
- Work Mode: full-feature

## Problem / Why

The existing extension command `drm-copilot: Show Subagent Tree`
(`drmCopilotExtension.showSubagentTree`) is not practically usable for two
reasons:

1. **Dropdown legibility.** When multiple root-session candidates exist, the
   quick-pick presents raw absolute transcript paths. The paths are long and
   share a common left prefix, so entries are visually indistinguishable. The
   operator cannot tell one session from another and cannot tell which entry is
   the most recent.

2. **No self-service tree from within a session.** There is currently no way
   for a running Claude Code session to render its own agent subtree. The
   command requires a human to open the VS Code command palette and pick a
   session from an unusable list. There is no programmatic entry point (MCP
   tool) and no way for the assistant to identify which session/thread it is
   currently running on, so a natural-language request such as
   "Show my agent tree" cannot be satisfied.

## Proposed Behavior

Two coordinated capabilities:

### 1. Dropdown display improvement

Reformat the quick-pick items in `selectRootSession` so each entry is
identifiable at a glance:

- Lead with the **timestamp of last activity** for that root session (most
  recent first).
- Follow with an **identifier that truncates left characters** as necessary so
  the **end of the path is visible** (right-anchored truncation), because the
  distinguishing information is at the tail of the path.
- Sort candidates by last-activity timestamp, most recent first.

### 2. MCP tool + session self-identification skill + "Show my agent tree" command

- Add a new MCP server tool that renders the subagent tree for a supplied
  session identifier, reusing the existing host-neutral
  `buildSubagentTree`/`formatTree` pair.
- Add a skill that lets the assistant self-identify its current session
  identifier.
- Wire a natural-language command ("Show my agent tree") that resolves the
  current session id via the skill and calls the MCP tool with that id, printing
  the rendered tree to a terminal or the invoking window (implementation choice
  to be decided in research/spec).

## Acceptance Criteria (early draft)

- [ ] Quick-pick entries show last-activity timestamp first, then a
  right-anchored (left-truncated) path so the tail is always visible; entries
  are ordered most-recent-first.
- [ ] A new MCP tool renders the subagent tree for a given session id and
  returns the rendered text, reusing the existing pure builder/renderer.
- [ ] A skill exists that lets the assistant determine its current session
  identifier.
- [ ] A "Show my agent tree" command resolves the current session id and invokes
  the MCP tool, printing the result.
- [ ] Full TypeScript toolchain passes (format -> lint -> type-check -> tests),
  coverage >= 85% line / >= 75% branch on new files; no production file excluded
  from coverage.
- [ ] Local feature-review clean of blocking findings.

## Constraints & Risks

- Extension and MCP server share source under `extensions/drm-copilot/`; the MCP
  server bundles `extensions/drm-copilot/src/mcp-server.ts`. New user-invocable
  workflows belong under `.claude/skills/`.
- No new runtime dependencies without explicit approval. Files < 500 lines.
- **Automation-feasibility risk:** the mechanism by which a running Claude Code
  session can self-identify its session identifier is uncertain and must be
  resolved during research, including an `## Automation Feasibility` assessment.

## Test Conditions to Consider

- [ ] Unit coverage: quick-pick label formatting (timestamp source, left
  truncation preserving the tail, ordering), MCP tool input validation and
  rendering, session-id resolution.
- [ ] Integration scenarios: multi-candidate ordering; MCP tool invoked with a
  valid and an invalid session id.

## Next Step

- [ ] Promote to GitHub issue (feature request template)
- [ ] Create `docs/features/active/subagent-tree-mcp-and-dropdown/` folder from the template
