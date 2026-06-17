# `pre-claude-session-script` — User Story

- Issue: #189
- Owner: drmoisan
- Status: Draft
- Last Updated: 2026-06-16T13-49

## Story Statement

- As a repository maintainer using the "New Claude Worktree Session" command, I want to point the command at a local PowerShell script that runs immediately before `claude` is invoked, so that repo-specific setup operations are configured in the local repository rather than centrally in the extension.

## Problem / Why

The "New Claude Worktree Session" command (`drmCopilotExtension.newClaudeWorktreeSession`) creates a worktree, navigates into it, optionally installs and activates a poetry environment, then starts `claude`. The pre-`claude` steps are fixed in the extension. Repositories that need additional local setup (for example, copying machine-local configuration, seeding environment variables, or running a repo-specific bootstrap) have no supported way to run those steps. Hard-coding them in the extension would force every consumer to carry them. The setup needs to be declared and maintained in the local repository.

## Personas & Scenarios

- Persona: Repository maintainer
  - Configures developer tooling for a specific repository.
  - Cares about reproducible, repo-local setup that does not require changes to a shared extension.
  - Works on Windows with PowerShell as the configured runtime.
- Scenario: Maintainer adds a bootstrap script
  - The maintainer commits a PowerShell script to the repository (default path `.claude/hooks/pre-claude-session.ps1`).
  - The maintainer optionally overrides the path via the `drmCopilotExtension.newClaudeWorktreeSession.preClaudeScriptPath` setting in the repository's `.vscode/settings.json`.
  - When the maintainer runs "New Claude Worktree Session", the command creates the worktree, navigates into it, performs poetry steps when applicable, runs the configured script, then starts `claude`.
  - If no script is present at the configured path in the worktree, the command proceeds to `claude` without error.

## Acceptance Criteria

- [x] AC1: The pure command builder accepts a configurable pre-`claude` script path and emits a `preClaude` PowerShell command when a non-empty path is supplied.
- [x] AC2: When the supplied script path is `undefined`, empty, or whitespace-only, the builder emits `preClaude` as `undefined` (no command).
- [x] AC3: The emitted `preClaude` command invokes the script only when it exists in the worktree, using a runtime existence guard (`if (Test-Path -LiteralPath '<path>') { & '<path>' }`), so a missing script does not cause an error.
- [x] AC4: The script path is embedded using the existing PowerShell single-quote escaping helper so paths containing spaces or apostrophes are preserved literally.
- [x] AC5: The `newClaudeWorktreeSession` handler reads the script path from the `drmCopilotExtension.newClaudeWorktreeSession.preClaudeScriptPath` configuration setting, which defaults to `.claude/hooks/pre-claude-session.ps1`.
- [x] AC6: The handler sends the `preClaude` command after the poetry activation step (when present) and before the deferred `claude` command, so the script runs immediately before `claude`. When `preClaude` is `undefined`, no additional command is sent.
- [x] AC7: `package.json` declares the new configuration setting under `contributes.configuration` with its type, default value, and description.
- [x] AC8: Unit tests cover the builder behaviors (AC1–AC4) and the handler's configuration read and command ordering (AC5–AC6). The full TypeScript toolchain (format → lint → type-check → test) passes with coverage thresholds met.

## Non-Goals

- Supporting non-PowerShell pre-`claude` scripts (the worktree session command already requires the PowerShell runtime).
- Running multiple pre-`claude` scripts; a single configurable path is in scope.
- Passing the worktree session objective or other arguments into the script.
- Changing the existing git, Set-Location, poetry, or deferred-`claude` behavior.
