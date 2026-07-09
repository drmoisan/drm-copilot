# subagent-tree-mcp-and-dropdown — Spec

- **Issue:** #334
- **Parent (optional):** none
- **Owner:** drmoisan
- **Last Updated:** 2026-07-09
- **Status:** Draft
- **Version:** 1.0
- **Work Mode:** full-feature

## Overview

The extension command `drm-copilot: Show Subagent Tree`
(`drmCopilotExtension.showSubagentTree`) has two usability defects:

1. **Dropdown legibility.** When multiple root-session candidates exist,
   `selectRootSession` passes raw absolute transcript paths to
   `vscode.window.showQuickPick`. The paths are long, share a common left
   prefix, carry no timestamp, and are sorted lexicographically, so the
   operator cannot distinguish sessions or identify the most recent one.
2. **No self-service tree from within a session.** There is no programmatic
   entry point (MCP tool) to render a subagent tree, and no mechanism for a
   running Claude Code session to identify its own session id, so a
   natural-language request such as "Show my agent tree" cannot be satisfied.

This feature delivers two coordinated capabilities:

- **Part 1 — Dropdown display fix.** Each quick-pick entry leads with the root
  session's last-activity timestamp, followed by a right-anchored
  (left-truncated, ellipsis-prefixed) path so the distinguishing tail stays
  visible; entries are ordered most-recent-first. Formatting logic lives in a
  new pure module with unit tests; host wiring stays thin.
- **Part 2 — MCP tool + session self-identification + "Show my agent tree".**
  A new MCP tool `render_subagent_tree` renders the tree for a supplied
  session id by reusing the existing host-neutral
  `buildSubagentTree`/`formatTree` pair; a SessionStart hook persists the
  current session id; two skills (`identify-session-id`,
  `show-my-agent-tree`) let the assistant resolve its session id and print
  its own agent tree in the reply.

Research reference (authoritative current-state analysis and design
rationale):
`docs/features/active/2026-07-09-subagent-tree-mcp-and-dropdown-334/research/2026-07-09T09-50-subagent-tree-mcp-and-dropdown-334-research.md`.

## Scope

### In scope

- Part 1: pure quick-pick formatting module, a narrow `FileTimes` stat seam,
  and thin rewiring of `discoverRootSessionCandidates`/`selectRootSession` in
  `extensions/drm-copilot/src/subagent-tree-command.ts`.
- Part 2: MCP tool `render_subagent_tree` (tool name, definition, input
  resolver, service method, handler, dispatch case, result mapping), a
  host-neutral session-transcript resolver module, the SessionStart hook
  `.claude/hooks/persist-session-id.ps1`, the skills
  `.claude/skills/identify-session-id/SKILL.md` and
  `.claude/skills/show-my-agent-tree/SKILL.md`, and the corresponding
  `.claude/settings.json` hook and allow-list entries.
- Jest unit tests for every new production file, per-file coverage threshold
  entries in `jest.config.cjs`, and a Pester test for the hook.

### Out of scope

- Any change to the tree content itself: `buildSubagentTree`, `formatTree`,
  `transcript-scanner.ts`, `transcript-parser.ts`, and `tree-formatter.ts`
  outputs are unchanged.
- Changing the existing VS Code command's output surface: palette users keep
  the `TerminalWriter`; the skill flow prints in the assistant reply.
- A `transcript_path` input mode for the MCP tool (rejected: dual-mode input
  doubles the validation/test surface; see research §Q3).
- Widening the `FileSystem` interface with a stat method (rejected: touches
  three in-memory fakes for a single consumer; the narrow `FileTimes` seam is
  used instead; see research §Q1).
- Reading the last in-file `timestamp` per candidate instead of mtime
  (rejected: whole-file reads per candidate for equivalent display value; see
  research §Q1).
- Migrating the extension test suite from Jest to Vitest (the extension's
  wired toolchain is Jest; see Design Decisions DD-4).
- Any esbuild/bundling change (confirmed unnecessary; see research §1.5).
- New runtime dependencies (none required).
- A `.claude/commands/` entry (new user-invocable workflows belong under
  `.claude/skills/` per `.claude/rules/typescript.md`).

## Behavior

### Part 1 — Dropdown display improvement

Happy path:

1. `discoverRootSessionCandidates` discovers root transcript paths as today
   (encoded workspace directory plus `-wt-` worktree siblings, excluding
   `/subagents/`), and additionally reads each candidate's last-modified time
   through an injected `FileTimes` seam, returning
   `{ path, lastActivityMs }[]`. The current lexicographic sort is removed.
2. `selectRootSession` builds display entries via the pure
   `buildRootSessionPickEntries` and shows them with
   `showQuickPick(entries, { matchOnDetail: true, ... })`. The selected
   entry's `path` field is the result.
3. Selecting an entry renders exactly the same tree as before; a single
   candidate still bypasses the prompt.

Entry format:

- `label` = `<timestamp>  <right-anchored truncated path>` — timestamp first.
- `detail` = full absolute path (disambiguates identical tails; preserves
  copyability; `matchOnDetail: true` lets typing filter on the full path).
- `description` unused.

Ordering: last-activity timestamp descending; candidates with an unreadable
mtime (`undefined`) sort last; ties broken by path ascending (deterministic).

Timestamp format: `yyyy-MM-dd HH:mm`, derived from UTC parts of the epoch
value; `undefined` renders as `unknown`. This is a pure transformation of
data read from disk, not a wall-clock read; production code never calls
`Date.now()`.

Truncation: `truncateLeftAnchored(value, maxLength)` returns the value
unchanged when `value.length <= maxLength`; otherwise returns
`"…" + value.slice(value.length - (maxLength - 1))` so total length equals
`maxLength` and the final characters always equal the final characters of the
real path. `maxLength <= 1` degenerates to the last character or `…`. The
module constant `MAX_PATH_LABEL_LENGTH = 60` governs the label.

Error handling: a stat failure on one candidate yields
`lastActivityMs: undefined` for that candidate only; the prompt still renders
and the failed candidate sorts last with timestamp `unknown`.

### Part 2 — MCP tool, hook, and skills

#### MCP tool contract: `render_subagent_tree`

Name: `render_subagent_tree` (verb-first snake_case, consistent with existing
`resolve_*`/`collect_*`/`validate_*` tools). Registered in
`REPO_AUTOMATION_TOOLS` and dispatched through
`dispatchRepoAutomationTool`.

Input schema:

```jsonc
{
  "type": "object",
  "properties": {
    "workspace_root": { /* shared workspaceRootProperty */ },
    "session_id": {
      "type": "string",
      "description": "Root session identifier (transcript filename stem under ~/.claude/projects/<encoded-workspace>/)."
    }
  },
  "required": ["session_id"],
  "additionalProperties": false
}
```

Validation: `session_id` must match `^[0-9A-Za-z-]{8,64}$` (observed ids are
UUIDv4). Validation runs before any filesystem access; a malformed id
(path separators, `..`, empty, over-length, wrong charset) is rejected
without touching the filesystem. Path traversal is therefore blocked by
construction, since the id is interpolated into a filesystem path.

Resolution algorithm (host-neutral resolver
`resolveSessionTranscriptPath(sessionId, workspaceRoot, claudeProjectsRoot,
fileSystem)`):

1. `getClaudeProjectsRoot(process.env)` supplies the projects root
   (env/path-only; safe on the MCP bundle path).
2. `encodeWorkspacePath(workspaceRoot)` encodes the workspace path.
3. `matchEncodedDirectories(listDirectory(projectsRoot))` selects the exact
   match plus `-wt-` worktree siblings, case-insensitive — the same search
   scope as the VS Code command; the tool description states this scope
   explicitly.
4. The first matching directory containing `<dir>/<session_id>.jsonl`
   (checked via `fileSystem.isFile`) wins deterministically.

Output: the standard `RepoAutomationMcpToolResult` shape
(`ok`/`tool`/`workspace_root`/`summary` plus optional fields) extended with
one new optional field:

- `RepoAutomationExecutionResult` gains `readonly renderedTree?: string`;
  `RepoAutomationMcpToolResult` gains `readonly rendered_tree?: string`;
  `toMcpToolResult` maps it (same pattern as `assetId`/`asset_id`).
- Success: `ok: true`; `summary` =
  `Rendered subagent tree for session <id> (<transcript path>).`;
  `rendered_tree` = `formatTree(buildSubagentTree(path, { fileSystem }))`.

Error behavior:

- Malformed `session_id`: `ok: false` with a summary naming the validation
  rule; no filesystem access occurs.
- Unknown `session_id` (valid charset, not found in any matching directory):
  `ok: false` with a summary naming the searched directories, via the
  existing `toFailureToolResult` path.

`mcp-server.ts` needs no per-tool change (`toCallToolResult` serializes the
structured result). No esbuild change is required: `lib/subagent-tree/*`
imports no `vscode`, and the existing `vscode` shim already covers
`command-runtime.ts` on the MCP bundle path.

#### SessionStart hook: `.claude/hooks/persist-session-id.ps1`

- Trigger: SessionStart hook event; registered in `.claude/settings.json`.
- Input: hook stdin JSON (documented contract carrying `session_id`,
  `transcript_path`, `cwd`, `hook_event_name`); falls back to
  `$env:CLAUDE_HOOK_INPUT` (existing repo precedent in the SubagentStop
  hook).
- Behavior: extract `session_id`; when `$env:CLAUDE_ENV_FILE` is set, append
  `CLAUDE_SESSION_ID=<id>` to that file (the documented persistence channel —
  variables persisted there are exported to subsequent Bash tool commands in
  the session); when `CLAUDE_ENV_FILE` is unset, write the id to
  `.claude/state/current-session-id` instead.
- Exit code: always 0, including on malformed or empty input (no write in
  that case). The hook must never block session start.
- Note: `CLAUDE_SESSION_ID` is not a documented pre-set environment variable;
  this hook is what provisions it (research §Q4).

#### Skill contract: `identify-session-id`

`.claude/skills/identify-session-id/SKILL.md` instructs the assistant to
resolve its current session id using an ordered fallback chain and to report
which source was used:

1. **Primary:** read `CLAUDE_SESSION_ID` from the environment (one pwsh/Bash
   command), populated by the SessionStart hook via `CLAUDE_ENV_FILE`.
2. **Secondary:** read `.claude/state/current-session-id`.
3. **Tertiary:** the newest-mtime root `*.jsonl` filename stem under
   `~/.claude/projects/<encodeWorkspacePath(cwd)>/` (heuristic; can pick the
   wrong sibling only when multiple concurrent sessions share one workspace
   path).

Kept as a separate skill because session self-identification is a named
acceptance criterion and is reusable by future session-aware workflows.

#### Skill contract: `show-my-agent-tree`

`.claude/skills/show-my-agent-tree/SKILL.md` defines the user-facing flow,
triggered by requests such as "Show my agent tree":

1. Resolve the session id via `identify-session-id`.
2. Call `mcp__drm-copilot__render_subagent_tree` with `session_id` and an
   explicit `workspace_root`.
3. Print `rendered_tree` directly in the assistant reply as a fenced code
   block. This works identically in `/btw` side-conversations and normal
   turns and requires no VS Code host API (research §Q5; a terminal surface
   was rejected as strictly more machinery for no functional gain).

Frontmatter follows existing repo precedent (`name`, `description`,
`allowed-tools` listing the MCP tool plus Bash/Read); no `context:` or
`agent:` keys, and no subagent routing.

#### Settings wiring

`.claude/settings.json` gains the SessionStart hook entry and allow-list
additions: `mcp__drm-copilot__render_subagent_tree`,
`Skill(identify-session-id *)`, `Skill(show-my-agent-tree *)`.

## Inputs / Outputs

- Inputs: MCP tool arguments (`session_id`, optional `workspace_root`);
  SessionStart hook stdin JSON; environment variables `CLAUDE_ENV_FILE`
  (write channel) and `CLAUDE_SESSION_ID` (read channel, provisioned by the
  hook); transcript files under `~/.claude/projects/<encoded-workspace>/`.
- Outputs: quick-pick entries (label/detail); MCP structured result with
  `rendered_tree`; env-file line `CLAUDE_SESSION_ID=<id>` or state file
  `.claude/state/current-session-id`; rendered tree text in the assistant
  reply.
- Config: `MAX_PATH_LABEL_LENGTH = 60` (module constant, tunable).
- Backward compatibility: `rendered_tree`/`renderedTree` are additive
  optional fields; existing tools and results are unchanged. The VS Code
  command's selection payload remains a transcript path.

## Data & State

- New data read: file mtimes via the `FileTimes` seam
  (`getModifiedTimeMs(path): number | undefined`; stat failure returns
  `undefined`). Data-from-disk, not clock generation; tests inject fixed
  epochs.
- New persisted state: the session id line in `$CLAUDE_ENV_FILE` or
  `.claude/state/current-session-id`. No migration or backfill.
- Invariants: truncation preserves the path tail exactly; ordering is total
  and deterministic (mtime desc, `undefined` last, path asc tiebreak);
  malformed session ids never reach the filesystem.

## API / CLI Surface

Example MCP invocation and result (abridged):

```jsonc
// call
{ "name": "render_subagent_tree",
  "arguments": { "session_id": "ef8e8029-7c73-4346-80c7-5b0ad94b33fe" } }
// structured result
{ "ok": true, "tool": "render_subagent_tree",
  "workspace_root": "C:/Users/.../repos/drm-copilot-wt/2026-07-09T09-18",
  "summary": "Rendered subagent tree for session ef8e8029-... (C:/.../ef8e8029-....jsonl).",
  "rendered_tree": "root · [opus] · 0 · ...\n  task-researcher · [sonnet] · 1 · ..." }
```

New pure API (`src/lib/subagent-tree/quick-pick-labels.ts`):

```ts
export function truncateLeftAnchored(value: string, maxLength: number): string;
export function formatLastActivityTimestamp(epochMs: number | undefined): string;
export interface RootSessionPickEntry {
  readonly label: string;   // `${timestamp}  ${truncatedPath}`
  readonly detail: string;  // full absolute path
  readonly path: string;    // selection payload
}
export function buildRootSessionPickEntries(
  candidates: ReadonlyArray<{ readonly path: string; readonly lastActivityMs: number | undefined }>,
  maxPathLength: number,
): RootSessionPickEntry[];
```

## Implementation Strategy

Change order per the research (§3). No production file is modified by this
spec itself; this section scopes the implementation plan.

### Part 1 — Dropdown fix

1. `extensions/drm-copilot/src/lib/subagent-tree/quick-pick-labels.ts` —
   new pure module (API above); `MAX_PATH_LABEL_LENGTH = 60`.
2. `extensions/drm-copilot/src/lib/file-system.ts` — add `FileTimes`
   interface + `RealFileTimes` (`fs.statSync(...).mtimeMs`, try/catch →
   `undefined`; ~30 lines; file stays well under 500).
3. `extensions/drm-copilot/src/subagent-tree-command.ts` — thread `FileTimes`
   through discovery; `selectRootSession` consumes `RootSessionPickEntry[]`
   with `matchOnDetail: true`; new optional `createFileTimes` seam mirroring
   the existing `createFileSystem` seam.
4. `extensions/drm-copilot/test/lib/subagent-tree/quick-pick-labels.test.ts`
   — new.
5. `extensions/drm-copilot/test/subagent-tree-command.test.ts` — extend
   (fake `FileTimes`).
6. `extensions/drm-copilot/jest.config.cjs` — per-file 85/75 threshold
   entries for new production files.

### Part 2 — MCP tool + hook + skills

1. `extensions/drm-copilot/src/lib/subagent-tree/session-transcript-resolver.ts`
   — new host-neutral resolver; session-id validation lives here.
2. `extensions/drm-copilot/src/repo-automation-tool-names.ts` — append
   `"render_subagent_tree"`.
3. `extensions/drm-copilot/src/mcp-repo-automation-tool-definitions.ts` —
   add the tool definition (schema above).
4. `extensions/drm-copilot/src/mcp-tool-inputs-subagent-tree.ts` — new input
   resolver module (reuses `normalizeWorkspaceRoot`/`normalizeRequiredText`;
   follows the `mcp-tool-inputs-push-down.ts` split precedent — do not grow
   `mcp-tool-inputs.ts`, currently 483 lines).
5. `extensions/drm-copilot/src/repo-automation-service.ts` — add
   `renderedTree?` to `RepoAutomationExecutionResult`; add
   `renderSubagentTree(input)` as a ~12-line delegation to the lib resolver
   plus `buildSubagentTree`/`formatTree` with the injected `fileSystem`.
6. `extensions/drm-copilot/src/mcp-handlers/render-subagent-tree-handler.ts`
   — new thin handler.
7. `extensions/drm-copilot/src/mcp-tools.ts` — add `rendered_tree` mapping
   and the dispatch `case`.
8. Tests:
   `test/lib/subagent-tree/session-transcript-resolver.test.ts` (new),
   `test/repo-automation-render-subagent-tree.test.ts` (new; service +
   dispatch), plus tool-definition/list assertions where existing suites
   cover them.
9. `extensions/drm-copilot/jest.config.cjs` — threshold entries for new
   production files.
10. `.claude/hooks/persist-session-id.ps1` (new) +
    `tests/scripts/claude-hooks/persist-session-id.Tests.ps1` (Pester).
11. `.claude/skills/identify-session-id/SKILL.md` (new).
12. `.claude/skills/show-my-agent-tree/SKILL.md` (new).
13. `.claude/settings.json` — SessionStart hook entry and allow-list
    additions.

Dependency changes: none (only `@modelcontextprotocol/sdk` is a runtime
dependency today; nothing new is required).

## Automation Feasibility

Per the research `## Automation Feasibility` section: **the "Show my agent
tree" flow is fully automatable end-to-end with no human interaction.** The
SessionStart hook and settings entries are committed files (one-time repo
provisioning shipped by this feature), not runtime human steps; the skill's
fallbacks (state file, newest-mtime transcript) are also fully automated.
Downstream planning must treat the flow as autonomous. The only external
dependency is that the Claude Code host continues to supply `session_id` on
the documented hook-input contract.

## Constraints & Risks

Constraints:

- Extension and MCP server share source under `extensions/drm-copilot/`; the
  MCP server bundles `extensions/drm-copilot/src/mcp-server.ts`. New
  user-invocable workflows belong under `.claude/skills/`.
- No new runtime dependencies. All files < 500 lines.
- New `src/lib/**` modules must import neither `vscode` nor `node:fs`
  directly (I/O only via injected seams); the one exception pattern is
  `file-system.ts` itself, where `RealFileTimes` belongs. No
  dependency-cruiser config exists; host-neutrality is enforced by convention
  and review.
- Extension toolchain: Prettier → ESLint → tsc → **Jest** (confirmed:
  `jest.config.cjs`, `ts-jest`, `npm run test` → `node run-jest.cjs`; not
  Vitest). Tests live under `extensions/drm-copilot/test/**` mirroring
  `src/`. Coverage via per-file `coverageThreshold` entries at 85 line /
  75 branch; `collectCoverageFrom` includes all of `src/**` with no
  production exclusions.
- PowerShell hook: PowerShell 7+, PSScriptAnalyzer via PoshQC, Pester test
  mirroring the existing batch-budget hook tests.

Risks (from research §Open Risks):

1. `repo-automation-service.ts` line budget — 477 today, ~490 after the ~12
   added lines. Mitigation: pure delegation; extract a method group into a
   support module if a later change crosses the cap (existing precedent
   available).
2. `CLAUDE_ENV_FILE` availability varies by Claude Code version; the hook's
   state-file fallback and the skill's mtime fallback cover absence. Verify
   the exact env-file line format against the running CLI during
   implementation.
3. Rules/toolchain divergence — `.claude/rules/typescript.md` prescribes
   Vitest and a `tests/` tree; the extension's wired reality is Jest and
   `test/`. Feature-review should treat the extension's established
   configuration as the governing precedent (all 27 existing suites live
   there).
4. mtime fidelity — copied/restored transcripts can misreport last activity.
   Display-only impact; the full path remains visible in `detail`.
5. `MAX_PATH_LABEL_LENGTH = 60` is a heuristic in a non-monospaced
   quick-pick. Cosmetic; trivially tunable constant.
6. Worktree-sibling matching in the MCP resolver finds a session id across
   sibling worktrees. This matches the command's semantics and is desirable;
   the tool description must state the search scope.

## Design Decisions

- **DD-1: mtime via a narrow `FileTimes` seam.** Last-activity timestamps
  come from transcript file mtime (O(1) stat per candidate), read through a
  new two-member-free interface rather than widening `FileSystem` (which
  would force edits to three in-memory fakes for one consumer) or reading the
  last in-file `timestamp` (whole-file reads per candidate).
- **DD-2: session-id-only tool input.** The tool accepts `session_id` (plus
  optional `workspace_root`) and encapsulates the id→path mapping; a
  `transcript_path` mode is rejected because the skill produces an id and a
  path-based caller can already read the file itself.
- **DD-3: reply-surface output for the skill flow.** The MCP tool already
  returns the rendered text; echoing it in the assistant reply needs zero
  additional wiring and works under `/btw`. The VS Code command keeps its
  terminal writer unchanged.
- **DD-4: Jest, not Vitest.** The extension's established, wired test
  framework is Jest; this feature follows it and does not migrate
  (research §1.6).
- **DD-5: provisioned `CLAUDE_SESSION_ID`.** The env var is not documented as
  pre-set; the SessionStart hook provisions it through the documented
  `CLAUDE_ENV_FILE` mechanism, with state-file and newest-mtime fallbacks.

## Acceptance Criteria

- [x] Given more than one root-session candidate, the quick-pick shows one
  entry per candidate whose label begins with the candidate's last-activity
  timestamp (`yyyy-MM-dd HH:mm`, UTC, derived from transcript mtime) followed
  by a right-anchored path label of at most 60 characters whose final
  characters always equal the final characters of the real path; the entry's
  detail line shows the full absolute path.
- [x] Quick-pick entries are ordered by last-activity timestamp descending;
  candidates with an unreadable mtime sort last and render the timestamp as
  `unknown`; equal timestamps order by path ascending.
- [x] Selecting an entry renders exactly the same tree as before (no change
  to `buildSubagentTree`/`formatTree` output); a single candidate still
  bypasses the prompt; a stat failure on one candidate does not break the
  prompt.
- [x] The MCP server advertises `render_subagent_tree` with required
  `session_id` and optional `workspace_root`
  (`additionalProperties: false`); calling it with a valid session id
  returns `ok: true` and a `rendered_tree` field equal to
  `formatTree(buildSubagentTree(...))` for the resolved transcript, with a
  summary naming the session id and transcript path.
- [x] Calling `render_subagent_tree` with an unknown session id returns
  `ok: false` with a summary naming the searched location; calling it with a
  malformed session id (charset outside `^[0-9A-Za-z-]{8,64}$`, path
  separators, `..`, empty, over-length) returns `ok: false` naming the
  validation rule, and malformed ids never touch the filesystem.
- [x] The session-transcript resolver matches the encoded workspace directory
  and its `-wt-` worktree siblings case-insensitively, and the first
  directory containing `<session_id>.jsonl` wins deterministically; the tool
  description states this search scope.
- [x] A SessionStart hook (`.claude/hooks/persist-session-id.ps1`) persists
  the current session id: with `CLAUDE_ENV_FILE` set it appends
  `CLAUDE_SESSION_ID=<id>`; with it unset it writes
  `.claude/state/current-session-id`; on malformed or empty input it exits 0
  without writing; it always exits 0.
- [x] `.claude/skills/identify-session-id/SKILL.md` resolves the current
  session id without human input and documents the ordered fallbacks
  (env var → state file → newest-mtime transcript), reporting which source
  was used.
- [x] `.claude/skills/show-my-agent-tree/SKILL.md` resolves the session id
  via `identify-session-id`, invokes
  `mcp__drm-copilot__render_subagent_tree` with `session_id` and explicit
  `workspace_root`, and prints the rendered tree in the assistant reply
  (fenced code block), including under `/btw`; `.claude/settings.json`
  carries the SessionStart hook entry and the tool/skill allow-list
  additions.
- [x] The extension toolchain passes in order (Prettier → ESLint → tsc →
  Jest); every new production file has a per-file 85% line / 75% branch
  `coverageThreshold` entry in `jest.config.cjs`; no production file is
  excluded from coverage; the PowerShell hook passes PoshQC and its Pester
  suite.
- [x] All touched files remain under 500 lines; no new runtime dependency is
  added.
- [x] New `src/lib/**` modules import neither `vscode` nor `node:fs` (I/O
  only via injected seams, with `RealFileTimes` living in `file-system.ts`);
  the MCP bundle builds without esbuild changes.
- [ ] Local feature-review reports no blocking findings.

## Test Conditions

`quick-pick-labels.ts`
(`test/lib/subagent-tree/quick-pick-labels.test.ts`):

- `truncateLeftAnchored`: shorter than max (unchanged); exactly max
  (unchanged); longer than max (ellipsis + tail, total length == max); max of
  1 and 0 (boundary); empty string.
- `formatLastActivityTimestamp`: known epoch → exact UTC string; `undefined`
  → `unknown`; epoch 0 boundary.
- `buildRootSessionPickEntries`: most-recent-first ordering; `undefined`
  mtime sorts last; mtime tie broken by path ascending; label composition
  (timestamp first, truncated tail); detail equals full path; empty candidate
  list.

`session-transcript-resolver.ts`
(`test/lib/subagent-tree/session-transcript-resolver.test.ts`):

- Resolves id in the exact-match encoded directory; resolves in a `-wt-`
  sibling; not found in any match (per chosen error contract); rejects
  malformed ids (path separators, `..`, empty, over-length);
  case-insensitive directory matching; multiple matching directories — first
  hit wins deterministically.

MCP layer (`test/repo-automation-render-subagent-tree.test.ts` and existing
pattern suites):

- Input resolver: missing `session_id` → error; invalid charset → error;
  `workspace_root` fallback behavior.
- Handler/service: valid id → `ok: true` with `rendered_tree` and summary
  (in-memory `FileSystem` fixture with a small transcript plus one
  subagent); unknown id → `ok: false` naming the searched location; tool
  listed in the tool definitions; dispatch case reachable.

Command wiring (`test/subagent-tree-command.test.ts`, extended):

- Multi-candidate flow shows entries ordered most-recent-first with formatted
  labels; selection maps back to the full path; single candidate still
  auto-selects; stat failure on one candidate does not break the prompt.

Hook (`tests/scripts/claude-hooks/persist-session-id.Tests.ps1`):

- stdin JSON with `session_id` + `CLAUDE_ENV_FILE` set → line appended;
  `CLAUDE_ENV_FILE` unset → state-file fallback written; malformed/empty
  input → exit 0, no write.

## Definition of Done

- [x] Acceptance criteria above documented and mapped to tests.
- [x] Behavior matches acceptance criteria.
- [x] Unit tests added for every new production module; edge and error cases
  covered per Test Conditions.
- [x] Pester test added for the SessionStart hook.
- [x] Skills and settings wiring in place and allow-listed.
- [x] Extension toolchain (Prettier → ESLint → tsc → Jest with coverage) and
  PowerShell toolchain (PoshQC, Pester) pass in a single clean run.
- [x] Docs updated (feature folder artifacts current).
