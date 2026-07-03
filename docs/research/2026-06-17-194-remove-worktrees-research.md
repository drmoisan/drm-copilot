# Research: Remove All Secondary Git Worktrees — Issue #194

**Date:** 2026-06-17
**Feature:** VS Code command `drmCopilotExtension.removeAllWorktrees`
**Canonical issue number:** 194

---

## 1. `git worktree list --porcelain` Output Format

### Verified field set

`git worktree list --porcelain` emits one block per worktree, blocks separated by a blank line. Each block begins with a `worktree` field and may contain any subset of the following fields:

```
worktree /absolute/path/to/worktree
HEAD <sha1>
branch refs/heads/<branchname>     # present for non-detached
bare                                # present (no value) when this is a bare repo worktree
detached                            # present (no value) when HEAD is detached
locked [reason]                     # present when worktree is locked; optional reason after space
prunable [reason]                   # present when worktree can be pruned (path missing on disk)
```

Key observations:
- The first block **always** describes the main (primary) worktree. There is no explicit `main` marker field; the primary worktree is identified by position (it is always the first block).
- The primary worktree's path matches what `git rev-parse --show-toplevel` returns from within the repo.
- A **bare** worktree (rare in this usage pattern) shows `bare` instead of `branch` or `detached`. The extension's `newClaudeWorktreeSession` creates non-bare worktrees only.
- `locked` means git itself will refuse to remove the worktree without `--force` on the `remove` subcommand.
- `prunable` means the worktree's path does not exist on disk; git would clean up its administrative state via `git worktree prune`.

### Parser design (pure function input)

The raw porcelain output is a single string. The parser splits on `\n\n` (double newline) or `\r\n\r\n` to get per-block strings, then parses each block line-by-line:

- `worktree <path>` — captured as the block's path.
- `bare` — boolean flag (presence only).
- `detached` — boolean flag (presence only).
- `locked` — boolean flag; remainder of line is the lock reason (may be empty).
- `prunable` — boolean flag; remainder of line is the prune reason (may be empty).
- `branch refs/heads/<name>` — branch name parsed after the prefix.
- `HEAD <sha>` — recorded but not decision-critical for removal logic.

The first parsed block is the primary worktree. All subsequent blocks are secondary worktrees subject to removal.

---

## 2. Removal Semantics: Force vs. Non-Force, Prunable, and Locked

### `git worktree remove` behavior

| Condition | `remove` (no flag) | `remove --force` |
|---|---|---|
| Clean working tree, path exists | succeeds | succeeds |
| Dirty working tree (modified tracked files) | fails | succeeds |
| Locked worktree | fails | fails (needs `--force --force` / two `--force` flags) |
| Path does not exist on disk (prunable) | fails | succeeds (removes admin state only) |
| Dirty submodules | fails | succeeds with single `--force` |

`git worktree remove --force` on a **locked** worktree still fails unless a second `--force` is supplied. Using `--force --force` would forcibly remove a locked worktree, which violates the hard requirement that worktrees which "cannot be fully eliminated" are left intact.

### Recommended removal strategy

**Use `git worktree remove` without `--force`.** Rationale:

1. The hard requirement is that any worktree that cannot be fully eliminated must be left intact. A non-force remove fails and leaves the worktree fully intact — exactly the required behavior.
2. Force-remove would bypass dirty-working-tree and prunable checks, which risks data loss (uncommitted changes) or confusion (orphaned branches).
3. The PowerShell draft (`scripts/dev-tools/remove-worktrees.ps1`) uses `--force` but compensates with a Windows file-lock probe that is not available in Node/TS. Without that probe, `--force` on a locked worktree would still fail (double-force needed), so the non-force path is simpler and safer.

### Skip condition matrix for the TS implementation

| Porcelain field on block | Action |
|---|---|
| `locked` present | Skip (report: "locked") — do not call `git worktree remove` at all |
| `prunable` present | Skip (report: "prunable — path missing on disk") — do not call `git worktree remove` |
| Neither | Call `git worktree remove <path>` (no `--force`); if exit code != 0, skip and capture stderr as reason |

**Rationale for skipping `locked` before attempting `git worktree remove`:**
A locked worktree requires explicit intent to unlock. Pre-checking avoids producing a misleading error message from git. The porcelain field is a first-class signal for this purpose.

**Rationale for skipping `prunable` before attempting `git worktree remove`:**
A prunable worktree's directory does not exist. `git worktree remove` without `--force` would fail on it. The correct action is to call `git worktree prune` rather than `git worktree remove`, but pruning is advisory (cleans administrative state only) and should be a separate, explicitly requested action. The command reports it as skipped so the user knows to prune manually or run a dedicated prune command.

### `git worktree prune` risk assessment

`git worktree prune` removes the `.git/worktrees/<name>` administrative record for any worktree whose path no longer exists on disk. It does not remove files. It is safe to call before listing, but:
- It changes the set of worktrees between parse and removal, so the list result would not include prunable entries.
- The feature requirement says to "never partially delete" — pruning an entry while its path still exists on disk is not possible (prune only acts on missing-path entries), so there is no partial-deletion risk from prune itself.
- **Recommendation:** Do not call `git worktree prune` automatically within this command. Report prunable worktrees as skipped so the user can decide. This preserves the invariant that the command only removes worktrees it can fully account for.

---

## 3. Extension Integration

### Existing command registration pattern (verified)

All VS Code commands are registered in `activate()` in `extensions/drm-copilot/src/extension.ts` (lines 69–291) by calling `vscode.commands.registerCommand(id, asyncHandler)` and pushing the returned disposable into `context.subscriptions`. The pattern is:

```typescript
const disposable = vscode.commands.registerCommand(
  "drmCopilotExtension.<name>",
  async () => { /* handler body */ },
);
context.subscriptions.push(disposable);
```

The `newClaudeWorktreeSession` command (lines 104–205) is the closest peer: it does interactive work, calls `getWorkspaceRoot()`, spawns subprocesses via `runCommandWithOutput`, and logs to the shared output channel.

### The `runCommandWithOutput` reject-on-nonzero constraint

`runCommandWithOutput` (command-runtime.ts, lines 275–336) rejects with a `CommandExecutionError` on any non-zero exit code. For per-worktree aggregation where one failure must not abort the batch, the command handler **must not** call `runCommandWithOutput` directly in a loop. Instead:

**The seam to introduce:** A `GitRunner` interface that runs a single git invocation and returns a `Promise<ProcessExecutionResult>` (resolving for both success and failure) rather than rejecting on nonzero. The git I/O module wraps `child_process.spawn` directly, mirroring `runCommandWithOutput` but capturing exit codes instead of rejecting. Tests inject a fake `GitRunner`.

### Confirmation prompt

Given that this command removes all secondary worktrees (destructive, potentially many items), a confirmation prompt via `vscode.window.showWarningMessage` with "Remove All" / "Cancel" buttons is warranted. The existing `newClaudeWorktreeSession` command uses `showInputBox` for user input; the `registerPoshQcCommands` pattern uses `promptForChoice`. The confirmation prompt is a one-step modal — it should use `vscode.window.showWarningMessage(message, { modal: true }, "Remove All")` and abort if the user does not click "Remove All".

---

## 4. Module Boundaries: Recommended Design

### Pure module: `remove-worktrees.ts`

No imports of `vscode`, `node:child_process`, `node:fs`, or `node:path`. Contains:

**Types:**
```typescript
export interface WorktreeEntry {
  readonly path: string;
  readonly isPrimary: boolean;
  readonly isLocked: boolean;
  readonly lockReason: string;
  readonly isPrunable: boolean;
  readonly pruneReason: string;
}

export interface WorktreeRemovalOutcome {
  readonly path: string;
  readonly removed: boolean;
  readonly skipReason: string | undefined; // undefined when removed
}

export interface WorktreeSummary {
  readonly removed: ReadonlyArray<string>;
  readonly skipped: ReadonlyArray<{ readonly path: string; readonly reason: string }>;
}
```

**Pure functions:**
- `parseWorktreePorcelain(raw: string): WorktreeEntry[]` — parses the raw porcelain string into entries; the first entry is marked `isPrimary: true`.
- `selectSecondaryWorktrees(entries: WorktreeEntry[]): WorktreeEntry[]` — returns entries where `!isPrimary`.
- `classifyWorktreeForRemoval(entry: WorktreeEntry): { skip: true; reason: string } | { skip: false }` — returns skip decision based on `isLocked` and `isPrunable`.
- `buildRemovalSummaryMessage(summary: WorktreeSummary): string` — formats the user-facing report string.

### I/O module: `remove-worktrees-runner.ts`

Imports `node:child_process`. Contains:

**Interface (injectable):**
```typescript
export interface GitRunner {
  run(args: ReadonlyArray<string>, cwd: string): Promise<{ exitCode: number; stdout: string; stderr: string }>;
}
```

**Production implementation:**
```typescript
export function createGitRunner(): GitRunner
```

Uses `child_process.spawn` with `shell: false`, resolves (never rejects) with the process result regardless of exit code.

**Orchestration function:**
```typescript
export async function removeAllSecondaryWorktrees(
  workspaceRoot: string,
  git: GitRunner,
  output: CommandOutput,
): Promise<WorktreeSummary>
```

Git invocation sequence:
1. `git worktree list --porcelain` — run via `git.run(["worktree", "list", "--porcelain"], workspaceRoot)`. Parse with `parseWorktreePorcelain`. Exit code must be 0; if not, throw.
2. For each secondary worktree, call `classifyWorktreeForRemoval(entry)`:
   - If `skip: true`, record `WorktreeRemovalOutcome { removed: false, skipReason: reason }` and continue.
   - If `skip: false`, call `git.run(["worktree", "remove", entry.path], workspaceRoot)`:
     - exit code 0 → `WorktreeRemovalOutcome { removed: true }`.
     - exit code nonzero → `WorktreeRemovalOutcome { removed: false, skipReason: stderr.trim() || "git worktree remove failed" }`.
3. Aggregate into `WorktreeSummary`.

### VS Code command handler (in `extension.ts`)

Registered as `drmCopilotExtension.removeAllWorktrees`. Handler:
1. `getWorkspaceRoot()`.
2. `vscode.window.showWarningMessage("Remove all secondary git worktrees?", { modal: true }, "Remove All")` — return if user does not confirm.
3. Run `removeAllSecondaryWorktrees(workspaceRoot, createGitRunner(), output)`.
4. Log summary to output channel. Show an information or warning message in the VS Code notification area with the count summary.

The handler wraps the call in try/catch; if `removeAllSecondaryWorktrees` throws (e.g., `git worktree list` fails), surface error via `vscode.window.showErrorMessage`.

---

## 5. Determinism and Test Seams

### Jest test file location

Per `jest.config.cjs` (line 4), tests match `<rootDir>/test/**/*.test.ts`. The new test file belongs at:

`extensions/drm-copilot/test/remove-worktrees.test.ts`

### Pure module tests (`remove-worktrees.test.ts`)

No mocking required. Tests for `parseWorktreePorcelain`, `selectSecondaryWorktrees`, `classifyWorktreeForRemoval`, and `buildRemovalSummaryMessage` take string inputs and return plain objects. No git spawning, no filesystem access. This mirrors the pattern in `test/claude-worktree-session.test.ts`.

### Orchestration/runner tests

A second test file or section within the same file tests `removeAllSecondaryWorktrees` using a fake `GitRunner`. The fake records calls and returns canned responses:

```typescript
function makeFakeGitRunner(
  responses: ReadonlyArray<{ exitCode: number; stdout: string; stderr: string }>
): { runner: GitRunner; calls: Array<ReadonlyArray<string>> }
```

The fake does not spawn processes; it resolves from the `responses` array in order. No `EventEmitter`, no `process.nextTick`. This differs from the `createMockProcess` helper (which uses `EventEmitter`) — the fake GitRunner is simpler because it returns a plain Promise.

### Command handler tests (extension.test.ts integration pattern)

The existing harness in `test/extension-test-harness.ts` mocks `node:child_process`. Because `createGitRunner` uses `child_process.spawn`, the existing `childProcessMock.spawn` can be configured to return canned `createMockProcess(exitCode, stdout)` values. The handler test verifies:
- Confirmation prompt cancellation returns without spawning git.
- Happy path: `commandHandlers.get("drmCopilotExtension.removeAllWorktrees")` is registered.
- Error in `git worktree list` produces `showErrorMessage`.

---

## 6. Files Affected

Only extension-local files change. No `.claude/`, `.codex/`, or `.github/` runtime files need synchronization for this feature. The command is VS Code-only (no MCP surface needed unless explicitly requested). Files:

| File | Change |
|---|---|
| `extensions/drm-copilot/src/remove-worktrees.ts` | New pure module |
| `extensions/drm-copilot/src/remove-worktrees-runner.ts` | New I/O module with `GitRunner` and `removeAllSecondaryWorktrees` |
| `extensions/drm-copilot/src/extension.ts` | Register `drmCopilotExtension.removeAllWorktrees` handler |
| `extensions/drm-copilot/package.json` | Add entry under `contributes.commands` |
| `extensions/drm-copilot/README.md` | Add command to command list and prose description |
| `extensions/drm-copilot/test/remove-worktrees.test.ts` | Unit tests for pure module and runner orchestration |

No new runtime dependencies. `node:child_process` is already used by `command-runtime.ts`.

---

## 7. Exact Git Invocations and Their Order

1. **List:** `git worktree list --porcelain` — cwd: `workspaceRoot`. Exit code must be 0. Parses the primary worktree path from block 0.
2. **Per secondary worktree** (only when not locked and not prunable):  
   `git worktree remove <absolutePath>` — no `--force` flag — cwd: `workspaceRoot`. Exit code captured; nonzero = skip with stderr reason.

No `git rev-parse --show-toplevel` call is required — the primary worktree is identified by position in the porcelain output (first block), not by comparing against `--show-toplevel`.

No `git worktree prune` invocation. Prunable entries are reported as skipped.

---

## 8. User-Facing Reporting

### Output channel (logged via `output.appendLine`)

- `[drmCopilotExtension.removeAllWorktrees] listing worktrees`
- Per worktree: `[drmCopilotExtension.removeAllWorktrees] skipping <path>: <reason>` or `removing <path>`
- Per successful remove: `[drmCopilotExtension.removeAllWorktrees] removed <path>`
- Per failed remove: `[drmCopilotExtension.removeAllWorktrees] failed to remove <path>: <stderr>`
- `[drmCopilotExtension.removeAllWorktrees] done: removed <N>, skipped <M>`

### VS Code notification

After completion, one `vscode.window.showInformationMessage` (all removed) or `vscode.window.showWarningMessage` (some skipped):
- All removed: `"Removed N worktree(s)."`
- Some skipped: `"Removed N worktree(s). Skipped M: <comma-separated paths>. See output channel for details."`
- None found: `"No secondary worktrees found."`

---

## Automation Feasibility

This feature is entirely local tooling within the VS Code extension. It touches no third-party UI, no external service, no CI pipeline, and no protected branch. All file changes are in `extensions/drm-copilot/` under TypeScript source and the extension manifest. There are no required human interaction steps. Full autonomous implementation is achievable.

---

## Rejected Alternatives

**Using `git worktree remove --force`:** Rejected because it bypasses dirty-working-tree detection and would remove worktrees with uncommitted changes, violating the "do not eliminate any worktree that cannot be fully eliminated" requirement. The force flag also does not help for locked worktrees (double-force needed there), so it provides no net benefit over non-force while adding data loss risk.

**Bundled PowerShell script approach (like other commands):** Rejected because the PowerShell script's file-lock probe (`System.IO.File::Open`) is Windows-only and not available in Node/TS, and the per-worktree aggregation contract is best expressed in TypeScript where the `GitRunner` seam enables clean Jest testing. The PowerShell approach would also require a new bundled resource path and a runtime dependency on `pwsh`/`powershell`, adding complexity with no benefit for what is a simple two-command git sequence.

**Calling `runCommandWithOutput` directly in a loop:** Rejected because it rejects on nonzero exit, which would abort the batch on the first failed removal and leave remaining worktrees unprocessed.
