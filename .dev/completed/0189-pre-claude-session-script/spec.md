# pre-claude-session-script — Spec

- **Issue:** #189
- **Parent (optional):** none
- **Owner:** drmoisan
- **Last Updated:** 2026-06-16T13-49
- **Status:** Draft
- **Version:** 0.1

## Overview

The "New Claude Worktree Session" command runs a fixed sequence of pre-`claude` steps (git worktree add, Set-Location, optional poetry install/activate) before starting `claude`. This feature adds a configurable hook: a local PowerShell script, declared in the repository, that runs immediately before `claude` is invoked. This lets repositories carry their own pre-session setup without changes to the extension.

## Behavior

After the worktree is created, navigated into, and (when applicable) the poetry environment is installed and activated, the command runs a configured PowerShell script if it exists in the worktree, then starts `claude`. The script path is resolved from a configuration setting that defaults to a repo-local convention path. A missing script is not an error; the command proceeds to `claude`.

## Inputs / Outputs

- Inputs:
  - Configuration setting `drmCopilotExtension.newClaudeWorktreeSession.preClaudeScriptPath` (string). Default: `.claude/hooks/pre-claude-session.ps1`. Resolved relative to the worktree root.
- Outputs:
  - An additional `preClaude` PowerShell command sent to the integrated terminal between poetry activation and the deferred `claude` command, when a non-empty path is configured.
  - Output channel log line continues to record the session; no script content is logged.
- Config keys and defaults:
  - `drmCopilotExtension.newClaudeWorktreeSession.preClaudeScriptPath` — default `.claude/hooks/pre-claude-session.ps1`.
- Versioning or backward-compatibility constraints:
  - Existing git, Set-Location, poetry, and deferred-`claude` behavior is unchanged. When the setting resolves to empty/whitespace, no new command is emitted.

## API / CLI Surface

- `WorktreeSessionCommandInput` gains `preClaudeScriptPath: string | undefined`.
- `WorktreeSessionCommands` gains `preClaude: string | undefined`.
- Emitted command shape when path is non-empty:
  - `if (Test-Path -LiteralPath '<quoted-path>') { & '<quoted-path>' }`
  - The path is escaped with the existing `quoteForPwsh` helper.
- When path is `undefined`/empty/whitespace: `preClaude === undefined`.

## Data & State

- No persistent state introduced. The script existence check happens at runtime in the new worktree via `Test-Path`.
- Data flow: configuration setting → handler → pure builder → terminal `sendText`.

## Constraints & Risks

- The pure module (`claude-worktree-session.ts`) must remain side-effect free; it must not import `vscode`, `node:child_process`, or `node:fs`. Existence is therefore checked at PowerShell runtime, not in TypeScript.
- The script runs with `--dangerously-skip-permissions` context only insofar as it precedes `claude`; the script itself runs in the user's PowerShell session. This matches existing trust assumptions for the worktree session command.
- File-size limit (500 lines) applies; current `claude-worktree-session.ts` is well under the limit.

## Implementation Strategy

- Implementation scope:
  - `src/claude-worktree-session.ts`: extend `WorktreeSessionCommandInput` and `WorktreeSessionCommands`; build the guarded `preClaude` command in `buildWorktreeSessionCommands`.
  - `src/extension.ts`: read the configuration setting (with default), pass it into the builder, send `commands.preClaude` after activate and before the deferred `claude` send.
  - `package.json`: add `contributes.configuration` declaring the setting (type string, default `.claude/hooks/pre-claude-session.ps1`, description).
- New classes/functions/commands: none beyond the extended interfaces and builder logic.
- Dependency changes: none.
- Logging/telemetry: extend the existing output-channel log line to note whether a pre-`claude` script command was emitted (without logging the path content beyond the configured value, which is non-sensitive).
- Rollout: no feature flag; default convention path makes the hook opt-in by presence of the script file.

## Definition of Done

- [ ] Acceptance criteria documented and mapped to tests (see user-story.md AC1–AC8)
- [ ] Behavior matches acceptance criteria
- [ ] Tests updated/added (unit)
- [ ] Edge cases and error handling covered by tests (empty/whitespace path, path with quotes/spaces, missing script guard)
- [ ] Docs updated (feature folder; README if applicable)
- [ ] Logging updated
- [ ] Toolchain pass completed (format → lint → type-check → test)

## Seeded Test Conditions (from potential)
- [ ] Unit coverage: builder `preClaude` for present/absent/whitespace paths and quote escaping
- [ ] Unit coverage: handler configuration read and command ordering
- [ ] CLI/API examples: emitted PowerShell command shape
