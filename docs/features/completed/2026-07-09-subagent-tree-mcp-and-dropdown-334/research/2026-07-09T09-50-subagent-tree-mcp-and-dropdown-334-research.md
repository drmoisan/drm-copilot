# Research — Subagent Tree MCP Tool and Dropdown Improvements (#334)

- Issue: #334
- Feature folder: `docs/features/active/2026-07-09-subagent-tree-mcp-and-dropdown-334/`
- Timestamp: 2026-07-09T09-50
- Author: task-researcher
- Scope: research only; no production code modified.

## 1. Current State Analysis

All findings below were verified by reading the named files in this worktree.

### 1.1 Existing command (`extensions/drm-copilot/src/subagent-tree-command.ts`, 179 lines)

- `registerSubagentTreeCommand` registers `drmCopilotExtension.showSubagentTree`. It resolves
  `getWorkspaceRoot()` and `getClaudeProjectsRoot()` (`src/command-runtime.ts`), discovers
  candidates, prompts, then calls `buildSubagentTree`/`formatTree` and writes to a
  `TerminalWriter` (`src/terminal-writer.ts`).
- `discoverRootSessionCandidates` encodes the workspace path (`encodeWorkspacePath`), matches
  on-disk project directories including `-wt-` worktree siblings (`matchEncodedDirectories`),
  globs `**/*.jsonl` under each matching directory, excludes paths containing `/subagents/`,
  and sorts **lexicographically by path** — there is no recency ordering today.
- `selectRootSession` passes raw string paths straight to `vscode.window.showQuickPick`
  (line 166: `showQuickPick([...candidates], ...)`). This is the display defect: long absolute
  paths sharing a common left prefix, no timestamp, no ordering by activity.
- Injectable seams already exist: `createFileSystem?: () => FileSystem` and
  `createTerminalWriter?: () => TerminalWriter`.

### 1.2 Host-neutral library (`src/lib/subagent-tree/`)

Seven files; none imports `vscode` (verified by reading each):

- `index.ts` — `buildSubagentTree(rootSessionPath, { fileSystem })` composes
  `scanTranscripts` (I/O via injected `FileSystem`) + `assembleTree` (pure); re-exports
  `formatTree` and `TreeNode`.
- `types.ts` — interface-only module (`SubagentMeta`, `ScannedTranscript`, `ScannedSubagent`,
  `ScannedSession`, `TreeNode`).
- `transcript-scanner.ts` — the only file touching `FileSystem`; derives the sibling
  `subagents/` directory from `<rootSessionPath minus .jsonl>/subagents`, reads
  `agent-*.meta.json` plus sibling transcripts; tolerant of malformed metas.
- `transcript-parser.ts` — pure line parser: extracts distinct `message.model` values and
  ordered `Agent` tool-use ids.
- `tree-formatter.ts` — pure renderer: one line per node,
  `${indent}${agentType} · [${models}] · ${depth} · ${description}`.
- `workspace-encoding.ts` — pure: `encodeWorkspacePath` (replaces `\`, `/`, `:` with `-`) and
  `matchEncodedDirectories` (exact match or `<encoded>-wt-` prefix, case-insensitive).

### 1.3 Filesystem seam (`src/lib/file-system.ts`, 325 lines)

`FileSystem` exposes `glob`, `isFile`, `exists`, `isDirectory`, `listDirectory`,
`readTextFile`, `writeTextFile`, `ensureDir`. **It has no mtime/stat accessor.** Three
in-memory fakes implement it in tests (`test/lib/subagent-tree/in-memory-file-system.ts`,
`test/lib/pr-context/tree-file-system.ts`,
`test/lib/codex-native-converter/in-memory-file-system.ts`), so widening the interface with a
required member touches every fake.

### 1.4 MCP plumbing pattern (verified end-to-end)

Adding a tool follows this exact chain (all files read):

1. `src/repo-automation-tool-names.ts` — `REPO_AUTOMATION_TOOLS` const array (20 snake_case
   names) + derived `RepoAutomationToolName` union.
2. `src/mcp-repo-automation-tool-definitions.ts` (453 lines) — `ToolDefinition` entries with
   JSON `inputSchema` (`additionalProperties: false`, shared `workspaceRootProperty`).
3. `src/mcp-tool-inputs.ts` (483 lines) — input resolvers (`asToolArgumentObject`,
   `normalizeRequiredText`, `normalizeWorkspaceRoot`). Push-down resolvers already overflowed
   into a sibling `src/mcp-tool-inputs-push-down.ts`, establishing the split precedent.
4. `src/mcp-handlers/<name>-handler.ts` — thin: resolve input, call one
   `RepoAutomationService` method (every existing handler delegates to a service method).
5. `src/repo-automation-service.ts` (477 lines) — interface + class; methods delegate to
   support modules (e.g. `resolvePolicyAuditTemplateAssetResult`). Constructor takes
   `{ extensionRoot, output, fileSystem?, runner?, pushDownFileSystem? }` — a `FileSystem`
   is already injectable.
6. `src/mcp-tools.ts` (259 lines) — exhaustive `switch` in `dispatchRepoAutomationTool`;
   `toMcpToolResult` maps `RepoAutomationExecutionResult` (camelCase) to
   `RepoAutomationMcpToolResult` (snake_case, `ok`/`tool`/`workspace_root`/`summary` plus
   optional fields).
7. `src/mcp-server.ts` — no per-tool changes needed; `toCallToolResult` JSON-stringifies the
   structured result into the text content and sets `structuredContent`.

### 1.5 esbuild `vscode` shim (confirmed)

`esbuild-mcp-server.cjs` bundles `src/mcp-server.ts` into a standalone Node bundle and shims
`vscode` to `module.exports = {}`. `command-runtime.ts` (which has a top-level `vscode`
import) is already on the MCP bundle path via `mcp-tools.ts`; `getClaudeProjectsRoot(env)`
uses only `node:path` and environment variables, so it is safe to call from the MCP server.
The `lib/subagent-tree/*` modules import no `vscode` at all. **Conclusion: the MCP server can
reuse `buildSubagentTree`/`formatTree` and `getClaudeProjectsRoot` with no build changes.**

### 1.6 Toolchain facts (confirmed against config, not assumed)

- Test framework for the extension is **Jest** (`jest.config.cjs`, `ts-jest`,
  `npm run test` → `node run-jest.cjs`), not Vitest. `.claude/rules/typescript.md` names
  Vitest repo-wide, but the extension's established, wired toolchain is Jest; follow Jest here
  and do not migrate.
- Tests live under `extensions/drm-copilot/test/**` mirroring `src/`
  (`testMatch: <rootDir>/test/**/*.test.ts`); e.g. `test/lib/subagent-tree/…`,
  `test/subagent-tree-command.test.ts`.
- Coverage: `collectCoverageFrom: ["src/**/*.ts", "!src/**/*.d.ts"]` (no production file
  excluded) with **per-file** `coverageThreshold` entries at 85 line / 75 branch. New
  production files must each get a threshold entry. Interface-only files (like
  `types.ts`) are intentionally omitted from the threshold gate but not from measurement.
- No `.dependency-cruiser.cjs` exists anywhere in the repo (glob verified). Architecture
  boundaries (lib stays host-neutral, no `vscode` import under `src/lib/`) are currently
  enforced by convention and review, not by tooling. New lib modules must keep that property.
- No new runtime dependencies are needed for any part of this feature (only
  `@modelcontextprotocol/sdk` is a runtime dependency today; nothing new is required).

### 1.7 On-disk transcript model (verified against live data)

Verified against `C:\Users\DanMoisan\.claude\projects\C--Users-DanMoisan-repos-drm-copilot-wt-2026-07-09T09-18\`:

- Root session transcript filename is `<session-uuid>.jsonl` directly under the encoded
  workspace directory (observed: `ef8e8029-7c73-4346-80c7-5b0ad94b33fe.jsonl`).
- Each transcript line carries `"sessionId":"<uuid>"` (matching the filename) and
  `"timestamp":"2026-07-09T13:26:37.115Z"` (ISO-8601 UTC with milliseconds).
- Subagent transcripts live at `<session-uuid>/subagents/agent-<agentId>.jsonl`, consistent
  with `transcript-scanner.ts`.

## 2. Findings per Research Question

### Q1 — Last-activity timestamp source

**Recommendation: use the transcript file's mtime**, read through a new narrow injected seam
(not by widening `FileSystem`).

Rationale:

- Claude Code appends a JSON line to the root `.jsonl` on every turn, so mtime equals the
  timestamp of the last appended entry to within filesystem precision. Verified that
  transcript entries carry ISO `timestamp` fields, so the two sources agree in practice.
- Cost: reading the last in-file `timestamp` requires reading the whole file per candidate
  (the `FileSystem` seam has only whole-file `readTextFile`; transcripts grow to tens of MB,
  and multi-candidate workspaces would multiply that) just to label a dropdown. A stat call
  is O(1) per candidate.
- Both options require a new seam (`FileSystem` has neither stat nor partial read). The stat
  seam is smaller.
- Known imprecision: file copies/restores can perturb mtime. Acceptable for display ordering;
  the full path remains visible in the item detail.

Seam design: add to `src/lib/file-system.ts` a separate two-member-free interface

```ts
export interface FileTimes {
  /** Epoch ms of last modification, or undefined when stat fails. */
  getModifiedTimeMs(path: string): number | undefined;
}
export class RealFileTimes implements FileTimes { /* fs.statSync(...).mtimeMs, try/catch → undefined */ }
```

A separate interface avoids updating the three existing in-memory `FileSystem` fakes and
keeps the change surface minimal (rejected alternative: adding `getModifiedTimeMs` to
`FileSystem` itself — forces edits to every fake and every `implements FileSystem` site for
one consumer).

Determinism/testability: this is **data read from disk**, not wall-clock generation. The
production code never calls `Date.now()` (banned outside infrastructure allowlists); it only
transforms an epoch number obtained from the injected `FileTimes`. Tests inject a fake
returning fixed epochs. Display formatting uses `new Date(epochMs)` + `toISOString()` (a
deterministic pure transformation of input data — not a clock read) and renders UTC, so test
output is machine-locale-independent.

### Q2 — Right-anchored path truncation and QuickPick shape

New pure module `src/lib/subagent-tree/quick-pick-labels.ts` (no `vscode` import; a
`vscode.QuickPickItem` is a structural type, so plain objects satisfy it):

```ts
/** Left-truncate so the tail stays visible; prefixes "…" when truncated. */
export function truncateLeftAnchored(value: string, maxLength: number): string;
// maxLength <= 1 → last char only / "…"; value.length <= maxLength → value unchanged;
// otherwise "…" + value.slice(value.length - (maxLength - 1)).

/** Epoch ms → "yyyy-MM-dd HH:mm" derived from UTC parts; undefined → "unknown". */
export function formatLastActivityTimestamp(epochMs: number | undefined): string;

export interface RootSessionPickEntry {
  readonly label: string;   // `${timestamp}  ${truncatedPath}`
  readonly detail: string;  // full absolute path
  readonly path: string;    // selection payload
}

/** Sort most-recent-first (undefined mtime sorts last; ties broken by path asc),
 *  then map to entries. */
export function buildRootSessionPickEntries(
  candidates: ReadonlyArray<{ readonly path: string; readonly lastActivityMs: number | undefined }>,
  maxPathLength: number, // recommend a module constant of 60
): RootSessionPickEntry[];
```

QuickPickItem surfacing recommendation:

- `label` = `<timestamp>  <right-anchored truncated path>` — the primary scannable line,
  timestamp first per the requirement.
- `detail` = full absolute path (small second line; disambiguates identical-looking tails and
  preserves copyability).
- `description` unused.
- Call `showQuickPick(entries, { matchOnDetail: true, ... })` so typing filters against the
  full path too; read `selected.path` for the result. `showQuickPick` is generic over
  `T extends QuickPickItem`, so `RootSessionPickEntry` needs no `vscode` types.

Host wiring stays thin: `discoverRootSessionCandidates` gains a `FileTimes` parameter and
returns `{ path, lastActivityMs }[]` (dropping the current lexicographic sort in favor of the
pure module's ordering); `selectRootSession` builds entries via
`buildRootSessionPickEntries`. A new optional seam `createFileTimes?: () => FileTimes` on
`registerSubagentTreeCommand` mirrors the existing `createFileSystem` seam.

### Q3 — MCP tool shape

**Name:** `render_subagent_tree` (verb-first snake_case, consistent with `resolve_*`,
`collect_*`, `validate_*`).

**Input schema — session id only (recommended):**

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

Resolution: `session_id` → `getClaudeProjectsRoot(process.env)` →
`encodeWorkspacePath(workspaceRoot)` → `matchEncodedDirectories(listDirectory(projectsRoot))`
(worktree siblings included, matching the command's semantics) → first directory containing
`<dir>/<session_id>.jsonl` (`fileSystem.isFile`). Failure raises a specific error naming the
searched directories, which surfaces as `ok: false` through the existing
`toFailureToolResult` path.

Input validation: `session_id` must match `^[0-9A-Za-z-]{8,64}$` (observed ids are UUIDv4).
This also blocks path traversal, since the id is interpolated into a filesystem path.
(Rejected alternative: also accepting a raw `transcript_path` — dual-mode input doubles the
validation/test surface; the skill produces a session id, and the id→path mapping is exactly
what the tool exists to encapsulate. A path-based caller can already read the file itself.)

**Output:** standard `RepoAutomationMcpToolResult` plus one new optional field:

- `RepoAutomationExecutionResult` gains `readonly renderedTree?: string`.
- `RepoAutomationMcpToolResult` gains `readonly rendered_tree?: string`; `toMcpToolResult`
  maps it (same pattern as `assetId`/`asset_id`).
- `summary` = `Rendered subagent tree for session <id> (<transcript path>).`
- `rendered_tree` = `formatTree(buildSubagentTree(path, { fileSystem }))` output.

`mcp-server.ts` needs no change (`toCallToolResult` serializes the whole structured result).

**Exact files and change order** — see section 3, Part 2.

**Bundle feasibility (confirmed):** `lib/subagent-tree` has no `vscode` imports;
`getClaudeProjectsRoot` is env/path-only; the `vscode` shim already covers `command-runtime`'s
top-level import on the MCP bundle path. No esbuild change required.

### Q4 — Session self-identification

Verified mechanisms (official Claude Code docs at `code.claude.com/docs/en/hooks`, fetched
2026-07-09, plus repo evidence):

1. **Hook stdin JSON carries the session identity.** Every hook event receives
   `session_id`, `transcript_path`, `cwd`, `hook_event_name` (and more) as JSON on stdin.
   This is documented and authoritative.
2. **`CLAUDE_SESSION_ID` is NOT a documented environment variable.** The documented hook/Bash
   env vars are `CLAUDE_PROJECT_DIR`, `CLAUDE_PLUGIN_ROOT`, `CLAUDE_PLUGIN_DATA`,
   `CLAUDE_CODE_REMOTE`, `CLAUDE_EFFORT`, `CLAUDE_ENV_FILE`, and
   `CLAUDE_CODE_BRIDGE_SESSION_ID`. This repo's batch-budget hooks read
   `$env:CLAUDE_SESSION_ID` but deliberately fall back to `'default'` when unset — consistent
   with it not being reliably present. Do not build on it being pre-set.
3. **`CLAUDE_ENV_FILE` (SessionStart hooks) is the supported persistence channel.** A
   SessionStart hook receives `session_id` on stdin and can append
   `CLAUDE_SESSION_ID=<id>` to the file at `$CLAUDE_ENV_FILE`; variables persisted there are
   exported to subsequent Bash tool commands in that session. This turns the undocumented
   env var into a repo-provisioned, documented-mechanism-backed one.
4. **Transcript naming ties id → path.** The root transcript is
   `<projectsRoot>/<encodeWorkspacePath(cwd)>/<session_id>.jsonl` (verified on disk;
   encoding rule verified in `workspace-encoding.ts`). So a session id plus the workspace
   root fully determines the transcript the MCP tool needs — exactly the resolver in Q3.
5. **Fallback: newest-mtime root transcript.** When the env var is absent (e.g. session
   started before the hook was installed), the most recently modified root `.jsonl` under the
   encoded-cwd directory is almost certainly the current session, because the current
   session's transcript is appended on every turn. Ambiguity exists only when multiple
   concurrent sessions share the same workspace path; this repo's worktree-per-session
   workflow (distinct `…-wt-<timestamp>` cwd per session) makes collisions unlikely.

**How the skill works (recommended design):**

- New SessionStart hook `.claude/hooks/persist-session-id.ps1`: read stdin JSON (fall back to
  `$env:CLAUDE_HOOK_INPUT`, which this repo's SubagentStop hook already uses), extract
  `session_id`, and append `CLAUDE_SESSION_ID=<id>` to `$env:CLAUDE_ENV_FILE`; when
  `CLAUDE_ENV_FILE` is unset, write `.claude/state/current-session-id` instead (the
  `.claude/state/` directory is the repo's established session-state location). Exit 0 always.
- New skill `.claude/skills/identify-session-id/SKILL.md`: instructs the assistant to run
  `pwsh -NoProfile -Command "$env:CLAUDE_SESSION_ID"` (primary), then
  `.claude/state/current-session-id` (secondary), then the newest-mtime root `.jsonl` stem
  under `~/.claude/projects/<encoded cwd>/` (tertiary), and report which source was used.

(Observed but rejected as an identification source: session-specific tool paths such as the
scratchpad directory embed the session UUID, but that is an undocumented implementation
detail of the harness, not a contract.)

### Q5 — "Show my agent tree" command surface

Per `.claude/rules/typescript.md`, "new user-invocable workflows belong under
`.claude/skills/` rather than `.claude/commands/`" — so the "command" is a skill.

**Recommendation: two skills plus one hook.**

- `.claude/skills/identify-session-id/SKILL.md` — the self-identification procedure (Q4).
  Kept separate because the acceptance criteria name it as its own capability and it is
  reusable by future session-aware workflows.
- `.claude/skills/show-my-agent-tree/SKILL.md` — the user-facing flow, triggered by
  "Show my agent tree": (1) resolve the session id via `identify-session-id`; (2) call
  `mcp__drm-copilot__render_subagent_tree` with `session_id` and explicit `workspace_root`;
  (3) print `rendered_tree` **directly in the assistant reply** (fenced code block).
  Frontmatter follows the existing repo precedent (`name`, `description`,
  `allowed-tools:` listing the MCP tool and Bash/Read) — note: no existing skill in this repo
  uses `context:` or `agent:` frontmatter keys; wrapper skills declare routing in a body
  section, and this flow needs no subagent.
- `.claude/settings.json` — add the SessionStart hook entry and allow-list additions
  (`mcp__drm-copilot__render_subagent_tree`, `Skill(show-my-agent-tree *)`,
  `Skill(identify-session-id *)`).

**Output surface decision:** print to the invoking window (the `/btw` reply), not a new
terminal. Justification: the MCP tool already returns the rendered text to the assistant;
echoing it in the reply requires zero additional wiring, works identically in `/btw`
side-conversations and normal turns, and needs no VS Code host API. Opening a terminal would
require either a new extension command taking a session-id argument or shelling out to echo
text — both strictly more machinery for no functional gain. (The existing VS Code command
keeps its terminal writer for palette users; unchanged.)

### Q6 — Constraints and test surface

Confirmed constraints (evidence in §1.6):

- No new runtime dependencies needed (none recommended).
- All new files comfortably under 500 lines; two existing files are near the limit and are
  handled by design: `mcp-tool-inputs.ts` (483 → put the new resolver in a **new**
  `mcp-tool-inputs-subagent-tree.ts`, following the `mcp-tool-inputs-push-down.ts`
  precedent) and `repo-automation-service.ts` (477 → the service method is a ~10-line
  delegation to a lib support function; monitor the count, see Risks).
- Toolchain: Prettier (`npm run format`) → ESLint (`npm run lint`) → tsc
  (`npm run typecheck`) → **Jest** (`npm run test`, coverage via `npm run test:coverage`).
- Coverage: add per-file 85/75 `coverageThreshold` entries in `jest.config.cjs` for every new
  production file; `collectCoverageFrom` already includes all of `src/**` with no production
  exclusions.
- Architecture: no dependency-cruiser config exists; preserve lib purity by convention — new
  `src/lib/**` modules must not import `vscode` or `node:fs` directly (I/O only through
  injected seams; the one exception pattern is `file-system.ts` itself, where `RealFileTimes`
  belongs).
- PowerShell hook: PowerShell 7+, PSScriptAnalyzer via PoshQC, Pester test at
  `tests/scripts/claude-hooks/persist-session-id.Tests.ps1` (mirrors the existing
  batch-budget hook tests).

Unit-test scenarios per new pure module:

`quick-pick-labels.ts` (`test/lib/subagent-tree/quick-pick-labels.test.ts`):
- `truncateLeftAnchored`: shorter than max (unchanged); exactly max (unchanged); longer than
  max (ellipsis + tail, total length == max); max of 1 and 0 (boundary); empty string.
- `formatLastActivityTimestamp`: known epoch → exact UTC string; `undefined` → "unknown";
  epoch 0 boundary.
- `buildRootSessionPickEntries`: most-recent-first ordering; `undefined` mtime sorts last;
  tie on mtime broken by path ascending (determinism); label composition
  (timestamp first, truncated tail); detail equals full path; empty candidate list.

`session-transcript-resolver.ts` (`test/lib/subagent-tree/session-transcript-resolver.test.ts`):
- Resolves id in the exact-match encoded directory; resolves in a `-wt-` sibling directory;
  returns undefined/throws (per chosen contract) when absent in all matches; rejects
  malformed ids (path separators, `..`, empty, over-length); case-insensitive directory
  matching; multiple matching directories — first hit wins deterministically.

MCP layer (Jest, existing patterns in `test/repo-automation-*.test.ts`):
- Input resolver: missing `session_id` → error; invalid charset → error; workspace_root
  fallback behavior.
- Handler/service: valid id → `ok: true` with `rendered_tree` and summary (in-memory
  `FileSystem` fixture with a small transcript + one subagent); unknown id → `ok: false`
  failure result naming the searched location; tool listed in
  `REPO_AUTOMATION_TOOL_DEFINITIONS`; dispatch case reachable via
  `dispatchRepoAutomationTool`.

Command wiring (`test/subagent-tree-command.test.ts`, extend existing):
- Multi-candidate flow shows entries ordered most-recent-first with formatted labels;
  selection maps back to the full path; single candidate still auto-selects (no stat-ordering
  needed); stat failure on one candidate does not break the prompt.

Hook (Pester):
- stdin JSON with `session_id` + `CLAUDE_ENV_FILE` set → line appended; `CLAUDE_ENV_FILE`
  unset → state-file fallback written; malformed/empty input → exit 0, no write.

## 3. Recommended Implementation Approach

### Part 1 — Dropdown fix (change order)

1. `extensions/drm-copilot/src/lib/subagent-tree/quick-pick-labels.ts` — **new** pure module
   (Q2 API). Constant `MAX_PATH_LABEL_LENGTH = 60`.
2. `extensions/drm-copilot/src/lib/file-system.ts` — add `FileTimes` interface +
   `RealFileTimes` class (~30 lines; file stays well under 500).
3. `extensions/drm-copilot/src/subagent-tree-command.ts` — thread `FileTimes` through
   discovery; `selectRootSession` consumes `RootSessionPickEntry[]` with
   `matchOnDetail: true`; new optional `createFileTimes` seam.
4. `extensions/drm-copilot/test/lib/subagent-tree/quick-pick-labels.test.ts` — **new**.
5. `extensions/drm-copilot/test/subagent-tree-command.test.ts` — extend (fake `FileTimes`).
6. `extensions/drm-copilot/jest.config.cjs` — threshold entries for the new file(s).

### Part 2 — MCP tool + skills (change order)

1. `extensions/drm-copilot/src/lib/subagent-tree/session-transcript-resolver.ts` — **new**
   host-neutral resolver: `resolveSessionTranscriptPath(sessionId, workspaceRoot,
   claudeProjectsRoot, fileSystem)`; session-id validation lives here.
2. `extensions/drm-copilot/src/repo-automation-tool-names.ts` — append
   `"render_subagent_tree"` (union forces the dispatch case; tsc fails until step 7).
3. `extensions/drm-copilot/src/mcp-repo-automation-tool-definitions.ts` — add definition
   (Q3 schema).
4. `extensions/drm-copilot/src/mcp-tool-inputs-subagent-tree.ts` — **new**:
   `RenderSubagentTreeToolInput { workspaceRoot; sessionId }` + resolver (reuses
   `normalizeWorkspaceRoot`/`normalizeRequiredText`). Do not grow `mcp-tool-inputs.ts`.
5. `extensions/drm-copilot/src/repo-automation-service.ts` — add `renderedTree?: string` to
   `RepoAutomationExecutionResult`; add interface method + implementation
   `renderSubagentTree(input)` that resolves `getClaudeProjectsRoot(process.env)`, calls the
   resolver, then `buildSubagentTree`/`formatTree` with the injected `this.fileSystem`
   (~12 lines total; delegates any non-trivial logic to the lib resolver).
6. `extensions/drm-copilot/src/mcp-handlers/render-subagent-tree-handler.ts` — **new** thin
   handler (resolve input → `service.renderSubagentTree`).
7. `extensions/drm-copilot/src/mcp-tools.ts` — add `rendered_tree` to
   `RepoAutomationMcpToolResult`, map it in `toMcpToolResult`, add the dispatch `case`.
8. Tests: `test/lib/subagent-tree/session-transcript-resolver.test.ts` (**new**),
   `test/repo-automation-render-subagent-tree.test.ts` (**new**, service + dispatch),
   plus tool-definition/list assertions where existing suites cover them.
9. `extensions/drm-copilot/jest.config.cjs` — threshold entries for new production files.
10. `.claude/hooks/persist-session-id.ps1` — **new** SessionStart hook (Q4) +
    `tests/scripts/claude-hooks/persist-session-id.Tests.ps1`.
11. `.claude/skills/identify-session-id/SKILL.md` — **new** (Q4 procedure).
12. `.claude/skills/show-my-agent-tree/SKILL.md` — **new** (Q5 flow).
13. `.claude/settings.json` — SessionStart hook entry; allow
    `mcp__drm-copilot__render_subagent_tree`, `Skill(identify-session-id *)`,
    `Skill(show-my-agent-tree *)`.

### Rejected alternatives (brief)

- **Last in-file `timestamp` instead of mtime** — requires whole-file reads per candidate or
  a new partial-read seam; higher cost for equivalent display value (§Q1).
- **Widening `FileSystem` with a stat method** — touches three test fakes and all
  implementers for a single consumer; the narrow `FileTimes` seam is smaller (§Q1).
- **Dual `session_id` | `transcript_path` tool input** — doubles validation and test surface;
  the id-only contract matches the skill's output and encapsulates the mapping (§Q3).
- **Printing the tree to a new terminal from the skill flow** — requires a new argumented
  extension command or shell echo plumbing; the assistant reply needs none (§Q5).
- **Relying on a pre-existing `CLAUDE_SESSION_ID` env var** — not documented; provision it
  via the SessionStart hook + `CLAUDE_ENV_FILE` instead (§Q4).

## Automation Feasibility

**Assessment: the "Show my agent tree" flow is fully automatable end-to-end with no human
interaction**, given the one-time repo provisioning that this feature itself ships (the
SessionStart hook and settings entries are committed files, not runtime human steps).

Step-by-step:

1. Session starts → SessionStart hook receives `session_id` on stdin (documented contract)
   and persists `CLAUDE_SESSION_ID` via `CLAUDE_ENV_FILE`. Automated; no human.
2. User types "Show my agent tree" (or `/btw Show my agent tree`) → skill triggers. The
   natural-language utterance is the user's request itself, not an interaction the flow
   requires beyond initiating it.
3. Skill reads `CLAUDE_SESSION_ID` via one Bash/pwsh command. Automated. Fallbacks
   (state file, newest-mtime transcript) are also fully automated.
4. Skill calls `mcp__drm-copilot__render_subagent_tree` with `session_id` +
   `workspace_root`. The tool and skill are allow-listed in `.claude/settings.json`
   (and the repo runs `defaultPermissionMode: bypassPermissions`), so no permission prompt
   interrupts the flow.
5. Skill prints `rendered_tree` in the reply. Automated.

Residual conditions that degrade (but do not humanly block) automation:

- **Session predates hook installation** → step 1 never ran for that session; the flow falls
  back to newest-mtime resolution, which is automated but heuristic. Not a human step.
- **Multiple concurrent sessions in the same workspace path** → the newest-mtime fallback can
  pick the wrong sibling. Only the fallback is affected; the primary env-var path remains
  exact. Not a human step.
- **Old Claude Code version without `CLAUDE_ENV_FILE`** → same fallback applies; the hook's
  state-file write covers this case automatically.

**No step in the flow requires a human.** The single genuinely unautomatable-by-us dependency
is that the Claude Code host, not our code, assigns and exposes the session id; the flow
depends on the documented hook-input contract continuing to carry `session_id`.

## Open Risks

1. **`repo-automation-service.ts` line budget** — 477 lines today; the new method adds ~12,
   landing near 490 of the 500 cap. Mitigation: keep the method a pure delegation; if a later
   change crosses the cap, extract a method group into a support module (precedent:
   `repo-automation-service-workflows.ts`, `repo-automation-service-support.ts`).
2. **`CLAUDE_ENV_FILE` availability** varies by Claude Code version; the hook's state-file
   fallback and the skill's mtime fallback cover absence, but the exact env-file line format
   should be verified against the running CLI version during implementation.
3. **Rules/toolchain divergence** — `.claude/rules/typescript.md` prescribes Vitest and a
   `tests/` tree; the extension's wired reality is Jest and `test/`. This research recommends
   following the extension's established configuration; feature-review should treat that as
   the governing precedent (all 27 existing suites live there).
4. **mtime fidelity** — copied/restored transcript files can misreport last activity in the
   dropdown ordering. Display-only impact; full path remains visible.
5. **Quick-pick fixed-width assumption** — `MAX_PATH_LABEL_LENGTH = 60` is a heuristic; the
   quick-pick is not monospaced and widths vary. Cosmetic; constant is trivially tunable.
6. **Worktree-sibling matching in the MCP resolver** — reusing `matchEncodedDirectories`
   means a session id is found across sibling worktrees of the workspace root. This matches
   the command's discovery semantics and is desirable; noted so the tool description states
   the search scope explicitly.

## Proposed Acceptance-Criteria Refinement

The current `user-story.md` checkboxes are line-wrapped fragments; propose replacing with:

1. Given more than one root-session candidate, the quick-pick shows one entry per candidate
   whose label begins with the candidate's last-activity timestamp (`yyyy-MM-dd HH:mm`, UTC,
   derived from transcript mtime) followed by a right-anchored path label of at most 60
   characters whose final characters always equal the final characters of the real path; the
   entry's detail line shows the full absolute path.
2. Quick-pick entries are ordered by last-activity timestamp descending; candidates with an
   unreadable mtime sort last; equal timestamps order by path ascending.
3. Selecting an entry renders exactly the same tree as before (no change to
   `buildSubagentTree`/`formatTree` output); a single candidate still bypasses the prompt.
4. The MCP server advertises `render_subagent_tree` with required `session_id` and optional
   `workspace_root`; calling it with a valid session id returns `ok: true` and a
   `rendered_tree` field equal to `formatTree(buildSubagentTree(...))` for the resolved
   transcript.
5. Calling `render_subagent_tree` with an unknown or malformed session id returns
   `ok: false` with a summary naming the searched location (unknown) or the validation rule
   (malformed); malformed ids never touch the filesystem.
6. A SessionStart hook persists the current session id so that
   `.claude/skills/identify-session-id` resolves it without human input; the skill documents
   and orders its fallbacks (env var → state file → newest-mtime transcript).
7. `.claude/skills/show-my-agent-tree` resolves the session id via `identify-session-id`,
   invokes `mcp__drm-copilot__render_subagent_tree`, and prints the rendered tree in the
   assistant reply, including under `/btw`.
8. Toolchain passes in order (Prettier → ESLint → tsc → Jest); every new production file has
   a per-file 85% line / 75% branch threshold entry in `jest.config.cjs`; no production file
   is excluded from coverage; all touched files remain under 500 lines.
9. New `src/lib/**` modules import neither `vscode` nor `node:fs` (I/O only via injected
   seams); the MCP bundle builds without esbuild changes.
10. Local feature-review reports no blocking findings.
