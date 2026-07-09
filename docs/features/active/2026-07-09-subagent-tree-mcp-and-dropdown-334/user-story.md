# `subagent-tree-mcp-and-dropdown` — User Story

- Issue: #334
- Owner: drmoisan
- Status: Draft
- Last Updated: 2026-07-09
- Work Mode: full-feature

## Story Statement

- As a VS Code operator running multiple Claude Code sessions in worktree
  siblings, I want the `Show Subagent Tree` quick-pick to lead each entry
  with the session's last-activity timestamp and a right-anchored path whose
  tail stays visible, ordered most-recent-first, so that I can identify and
  select the session I mean at a glance instead of comparing long,
  identical-prefix absolute paths.
- As a Claude Code assistant serving a user request such as "Show my agent
  tree", I want a skill that resolves my current session id and an MCP tool
  that renders the subagent tree for that id, so that I can print my own
  agent tree in the reply without any human opening the command palette or
  picking from a list.
- As a repository maintainer, I want the new formatting and resolution logic
  in pure, host-neutral modules with unit tests and per-file coverage gates,
  so that the behavior is verifiable in isolation and the host wiring stays
  thin.

## Problem / Why

The extension command `drm-copilot: Show Subagent Tree`
(`drmCopilotExtension.showSubagentTree`) is not practically usable for two
reasons:

1. **Dropdown legibility.** When multiple root-session candidates exist, the
   quick-pick presents raw absolute transcript paths. The paths are long and
   share a common left prefix, so entries are visually indistinguishable, and
   the current lexicographic ordering hides which entry is the most recent.
2. **No self-service tree from within a session.** There is no programmatic
   entry point (MCP tool) to render a subagent tree and no way for the
   assistant to identify which session it is currently running on, so a
   natural-language request such as "Show my agent tree" cannot be
   satisfied.

## Personas & Scenarios

- **Persona: Multi-session VS Code operator.**
  - Who: an engineer running several concurrent Claude Code sessions across
    `-wt-<timestamp>` worktree siblings of one repository.
  - What they care about: quickly finding the session they just worked in;
    trusting that the top entry is the most recent.
  - Constraints: transcript paths differ only in their tails; the quick-pick
    is not monospaced; some transcripts may fail to stat.
  - Goals and frustrations: today every entry looks identical and ordering is
    alphabetical, so selection is guesswork.
  - Context: invokes the command from the palette; expects the same rendered
    tree output as today once a session is picked.

- **Persona: Claude Code assistant (session-aware workflow).**
  - Who: the assistant executing a user's natural-language request inside a
    running session.
  - What they care about: deterministic resolution of its own session id and
    a single tool call that returns the rendered tree text.
  - Constraints: `CLAUDE_SESSION_ID` is not a documented pre-set environment
    variable; sessions may predate hook installation; permission prompts must
    not interrupt the flow.
  - Goals: answer "Show my agent tree" fully autonomously, including under
    `/btw`.

- **Scenario: Picking the right session from the dropdown.**
  - Who is acting: the multi-session operator.
  - Trigger: runs `drm-copilot: Show Subagent Tree` with three candidate
    root transcripts across worktree siblings.
  - Steps: the quick-pick opens with three entries, each labeled
    `<yyyy-MM-dd HH:mm>  …<path tail>`, ordered most-recent-first; one
    candidate's mtime is unreadable and appears last with timestamp
    `unknown`; the operator confirms the full path on the entry's detail line
    and selects the top entry.
  - Obstacles/decisions: two tails look similar; the detail line
    (full absolute path, also searchable via `matchOnDetail`) disambiguates.
  - Expected outcome: the same tree as today renders to the terminal for the
    selected session; a single-candidate invocation still bypasses the
    prompt.

- **Scenario: "Show my agent tree" end-to-end, no human steps.**
  - Who is acting: the assistant.
  - Trigger: the user types "Show my agent tree".
  - Steps: the `show-my-agent-tree` skill triggers; it resolves the session
    id via `identify-session-id` (env var `CLAUDE_SESSION_ID`, persisted at
    session start by the `persist-session-id.ps1` hook through
    `CLAUDE_ENV_FILE`); it calls
    `mcp__drm-copilot__render_subagent_tree` with the id and explicit
    `workspace_root`; it prints `rendered_tree` in the reply as a fenced
    code block.
  - Obstacles/decisions: if the session predates the hook, the skill falls
    back to the state file, then to the newest-mtime transcript stem —
    automated fallbacks, not human steps.
  - Expected outcome: the rendered tree appears in the assistant reply;
    per the research `## Automation Feasibility` assessment the flow is
    fully automatable with no human interaction.

- **Scenario: Invalid session id is rejected safely.**
  - Who is acting: any MCP client.
  - Trigger: calls `render_subagent_tree` with
    `session_id: "../../etc/passwd"`.
  - Steps: input validation (`^[0-9A-Za-z-]{8,64}$`) rejects the id before
    any filesystem access; the tool returns `ok: false` naming the
    validation rule. A well-formed but unknown id returns `ok: false` naming
    the searched directories.
  - Expected outcome: path traversal is blocked by construction; failures
    are specific and actionable.

## Acceptance Criteria

- [x] Quick-pick entries lead with the candidate's last-activity timestamp
  (`yyyy-MM-dd HH:mm`, UTC, from transcript mtime) followed by a
  right-anchored path label of at most 60 characters whose final characters
  always equal the final characters of the real path; the detail line shows
  the full absolute path.
- [x] Entries are ordered most-recent-first; unreadable mtimes sort last and
  render as `unknown`; equal timestamps order by path ascending; a stat
  failure on one candidate does not break the prompt.
- [x] Selecting an entry renders exactly the same tree as before; a single
  candidate still bypasses the prompt.
- [x] The MCP tool `render_subagent_tree` (required `session_id`, optional
  `workspace_root`) returns `ok: true` with `rendered_tree` equal to
  `formatTree(buildSubagentTree(...))` for a valid session id, reusing the
  existing pure builder/renderer.
- [x] Unknown session ids return `ok: false` naming the searched location;
  malformed session ids return `ok: false` naming the validation rule and
  never touch the filesystem.
- [x] The `identify-session-id` skill lets the assistant determine its
  current session id without human input, backed by the
  `persist-session-id.ps1` SessionStart hook, with documented ordered
  fallbacks (env var → state file → newest-mtime transcript).
- [x] The `show-my-agent-tree` skill resolves the current session id,
  invokes `mcp__drm-copilot__render_subagent_tree`, and prints the rendered
  tree in the assistant reply, including under `/btw`.
- [x] Full extension toolchain passes (Prettier → ESLint → tsc → Jest);
  coverage >= 85% line / >= 75% branch on every new production file via
  per-file `jest.config.cjs` thresholds; no production file excluded from
  coverage; all touched files under 500 lines; no new runtime dependencies;
  new `src/lib/**` modules remain host-neutral (no `vscode`/`node:fs`
  imports).
- [x] Local feature-review clean of blocking findings.

## Non-Goals

- No change to tree content: `buildSubagentTree`/`formatTree` and the
  scanner/parser/formatter modules produce identical output.
- The VS Code command keeps its terminal writer; the skill flow prints in
  the assistant reply, and no new terminal surface is added.
- No `transcript_path` input mode on the MCP tool (session-id-only
  contract).
- No widening of the `FileSystem` interface; mtime access uses the narrow
  `FileTimes` seam.
- No Jest-to-Vitest migration and no relocation of the extension's `test/`
  tree.
- No esbuild/bundling changes and no new runtime dependencies.
- No `.claude/commands/` entry; user-invocable workflows ship as skills.
