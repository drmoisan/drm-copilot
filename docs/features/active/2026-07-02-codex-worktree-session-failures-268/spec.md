# codex-worktree-session-failures (Spec)

- **Issue:** #268
- **Work Mode:** full-bug
- **Parent (optional):** none
- **Owner:** drmoisan
- **Last Updated:** 2026-07-02T13-13
- **Status:** Draft
- **Version:** 0.1

## Context
`drm-copilot: New Codex Worktree Session` currently emits invalid PowerShell for Codex trust setup, later relies on a bare `codex` command that may not exist on `PATH`, and does not ensure new worktrees receive this repository's Codex customizations before Codex starts.

Environment:
- OS/version: Windows / PowerShell
- Python version: Not applicable
- Command/flags used: VS Code command `drm-copilot: New Codex Worktree Session`
- Data source or fixture: Local `drm-copilot` worktree command implementation and tests

Impact / Severity:
- [ ] Blocker
- [x] High
- [ ] Medium
- [ ] Low


## Repro & Evidence
Steps to Reproduce:
1. Run `drm-copilot: New Codex Worktree Session` in a repository that uses the generated Codex trust setup command.
2. Observe the generated trust command fragment containing `if (...) { ... }; elseif (...) { ... }`.
3. Run the command in an environment where `codex` is not available on `PATH`.
4. Start a new Codex worktree where `.codex` and `.agents` are not already present in the destination.

Expected:
The command creates the git worktree, moves into it, configures Codex trust without a PowerShell parse error, installs and activates Poetry when applicable, runs the configured post-Codex script in a first-run-safe way, and starts Codex using a resolved executable path.

Actual:
The trust setup command can fail with `elseif: The term 'elseif' is not recognized as a name of a cmdlet...` because the builder joins fragments with `; ` and emits `; elseif`.

The command can later fail with `codex: The term 'codex' is not recognized...` when `codex` is not available on `PATH`.

The new Codex worktree may start without repo-local `.codex` and `.agents` folders, so hooks, agents, and skills may not load from the worktree.

Logs / Screenshots:
- [x] Attached minimal logs or screenshot
- Snippet:

```text
elseif: The term 'elseif' is not recognized as a name of a cmdlet...
codex: The term 'codex' is not recognized...
```


## Scope & Non-Goals
- In scope:
  - Correct the generated PowerShell trust setup command so the `if`/`elseif` branch is emitted as one syntactic statement and never as `; elseif`.
  - Resolve the Codex CLI before the terminal starts, using a configured executable path when provided and PATH/PATHEXT lookup for the default `codex` command when not configured.
  - Invoke the configured post-Codex script from the source repository root with explicit source and worktree root arguments before Codex starts.
  - Implement this repository's `.codex` and `.agents` copy behavior in `.codex/scripts/post-codex-worktree-session.ps1`.
  - Add focused TypeScript and PowerShell regression coverage for the issue #268 repro paths and expected recovery behavior.
- Out of scope / non-goals:
  - Hardcoding repository-specific `.codex` or `.agents` copy behavior into the generic VS Code extension.
  - Replacing the trust setup with a separate bundled script when the current builder can emit valid PowerShell.
  - Changing unrelated worktree-session behavior, branch naming, issue promotion, or planning artifacts.
  - Adding new runtime dependencies for CLI resolution, path handling, or copy behavior.
- Explicitly excluded systems, integrations, or datasets:
  - External services, remote APIs, and GitHub issue mutation beyond existing local artifacts for issue #268.
  - Non-Codex worktree commands and Claude worktree-session scripts, except as reference patterns for tests.
  - Repository customization sync outside `.codex` and `.agents`.

## Root Cause Analysis
Likely files:

- `extensions/drm-copilot/src/codex-worktree-session.ts`
- `extensions/drm-copilot/src/extension.ts`
- `extensions/drm-copilot/package.json`
- `extensions/drm-copilot/test/codex-worktree-session.test.ts`
- `extensions/drm-copilot/test/codex-worktree-session-command.test.ts`
- `.codex/scripts/post-codex-worktree-session.ps1`
- PowerShell tests for the new script following existing conventions

The extension must remain generic. Repository-specific copy behavior belongs in the configured post-Codex script mechanism, not hardcoded extension logic.


## Proposed Fix

### Design summary (what changes where):
Use a two-boundary fix. The VS Code extension remains generic and handles command generation, configuration, CLI resolution, and post-Codex script invocation. Repository-specific customization copy behavior stays in `.codex/scripts/post-codex-worktree-session.ps1`, which copies `.codex` and `.agents` from the source root into the new worktree before Codex starts.

### Boundaries and invariants to preserve:
The extension must not hardcode `drm-copilot` repository customization folders beyond invoking the configured post-Codex script. The command sequence must continue to create the worktree, move into it, apply Codex trust, optionally activate Poetry, run post-Codex work, then start Codex. Trust setup must remain idempotent and must keep existing trusted entries intact. The post-Codex script must be first-run safe, tolerate missing optional source folders, and avoid deleting unrelated destination content.

### Dependencies or blocked work:
No new runtime dependency is required. Existing VS Code APIs, Node path/process utilities, PowerShell, Jest, Pester, and repository test helpers are sufficient. The provided research is sufficient to proceed to atomic planning for issue #268.

### Implementation strategy (what changes, not sequencing):
Implement the correction through scoped updates to the command builder, command registration, configuration schema, test harness, repository post-Codex script, and regression tests. Keep behavior explicit through configuration defaults and testable pure helpers where possible.
	
#### Files/modules to change:
- `extensions/drm-copilot/src/codex-worktree-session.ts`
- `extensions/drm-copilot/src/extension.ts`
- `extensions/drm-copilot/src/command-runtime.ts`
- `extensions/drm-copilot/package.json`
- `extensions/drm-copilot/test/codex-worktree-session.test.ts`
- `extensions/drm-copilot/test/codex-worktree-session-command.test.ts`
- `extensions/drm-copilot/test/extension-test-harness.ts`
- `extensions/drm-copilot/test/runtime-test-helpers.ts`
- `.codex/scripts/post-codex-worktree-session.ps1`
- A Pester test file under `tests/scripts/` following the existing script-test conventions.

#### Functions/classes/CLI commands impacted:
- `buildCodexTrustCommand` must emit the trust-entry `if (...) { ... } elseif (...) { ... }` chain as one PowerShell statement.
- `buildCodexWorktreeSessionCommands` must accept and emit a resolved Codex executable command instead of always emitting bare `codex`.
- `newCodexWorktreeSession` must resolve the Codex executable before terminal creation and pass source/worktree context to the post-Codex command builder.
- Runtime executable probing must support resolving `codex` and configured Codex executable values in addition to the existing PowerShell runtime lookup.
- VS Code configuration must add `drmCopilotExtension.newCodexWorktreeSession.codexExecutablePath` with an empty-string default.

#### Data flow and validation changes:
The command handler reads `postCodexScriptPath` and `codexExecutablePath` from VS Code configuration. It resolves the post-Codex script path against the source repository root and resolves the Codex executable from the configured value or PATH/PATHEXT. The builder receives validated values and emits terminal-safe PowerShell commands. The post-Codex script receives `-SourceRoot` and `-WorktreeRoot`, computes `.codex` and `.agents` copy operations from those roots, skips missing source folders, and overwrites matching files without removing unrelated destination files.

#### Error handling and logging updates:
If no configured executable resolves and `codex` is not found on PATH, the command must fail before terminal creation with a clear message: `Codex CLI not found. Configure drmCopilotExtension.newCodexWorktreeSession.codexExecutablePath or install codex on PATH.` Existing PowerShell runtime preflight behavior must remain intact. Post-Codex copy errors must fail explicitly instead of being silently ignored, while missing optional source folders should be treated as non-fatal no-op conditions.

#### Rollback/feature-flag considerations (if applicable):
No feature flag is required. Rollback consists of reverting the issue #268 changes to the command builder, command handler, configuration schema, tests, and post-Codex script. The new `codexExecutablePath` configuration must be backward compatible because its default is empty and existing users can continue relying on PATH-based `codex` resolution.

### Technical specifications (interfaces/contracts):

#### Inputs/outputs and formats:
- Input: VS Code command `drm-copilot: New Codex Worktree Session`.
- Input: `drmCopilotExtension.newCodexWorktreeSession.postCodexScriptPath`, defaulting to `.codex/scripts/post-codex-worktree-session.ps1` and resolved against the source repository root.
- Input: `drmCopilotExtension.newCodexWorktreeSession.codexExecutablePath`, defaulting to `""`; when empty, resolve `codex` from PATH/PATHEXT.
- Input: optional Codex objective text, preserved as the initial Codex prompt argument.
- Output: terminal command sequence that creates the worktree, changes location, configures trust, optionally activates Poetry, invokes the source-root post-Codex script with `-SourceRoot` and `-WorktreeRoot`, and starts Codex through a resolved executable.
- Output: repository post-Codex script copies `.codex` and `.agents` from source root to worktree root before Codex starts.

#### Required configuration keys and defaults:
- Existing: `drmCopilotExtension.newCodexWorktreeSession.postCodexScriptPath`, default `.codex/scripts/post-codex-worktree-session.ps1`.
- New: `drmCopilotExtension.newCodexWorktreeSession.codexExecutablePath`, default `""`.
- The `postCodexScriptPath` package description must state that the path is resolved relative to the source repository root for the first-run worktree session.

#### Backward-compatibility expectations:
Existing users with `codex` on PATH continue to use the default empty `codexExecutablePath` setting. Users with Codex installed outside PATH can set the new executable path. Existing configured post-Codex script paths continue to work when they exist under the source repository root. The extension remains generic and does not require this repository's script for other repositories.

#### Performance constraints (latency/throughput/memory):
Executable resolution and post-Codex path resolution must occur once per command invocation before terminal creation. Copy behavior is limited to `.codex` and `.agents`; it should use deterministic traversal and pass-through file content without caching or background watchers.

## Assumptions, Constraints, Dependencies
- Assumptions (environment, data, access):
  - The command runs on Windows through a PowerShell terminal, matching the issue #268 repro environment.
  - The source repository root is available when the VS Code command is invoked.
  - The configured post-Codex script may not yet exist in the destination worktree, so it must be invoked from the source root.
  - The research source accurately reflects the current implementation and test layout.
- Constraints (budget, performance, compatibility):
  - The extension must remain repository-agnostic.
  - The fix must avoid new runtime dependencies.
  - Tests must avoid ambient machine PATH assumptions by using the existing executable-presence fixtures and injected PowerShell test helpers.
  - Unit tests must not create temporary files.
- External dependencies (services, libraries, releases):
  - No external service dependency is required.
  - Codex CLI must be installed on PATH or configured through `codexExecutablePath` at runtime.
  - Existing repository toolchains for TypeScript and PowerShell remain the validation dependencies.

## Data / API / Config Impact
- User-facing or API changes:
  - Adds optional configuration key `drmCopilotExtension.newCodexWorktreeSession.codexExecutablePath`.
  - Updates the user-facing missing-Codex failure from a terminal shell error to a preflight error before terminal creation.
  - Updates `postCodexScriptPath` semantics to source-root resolution for first-run safety.
- Data or migration considerations:
  - No data migration is required.
  - Existing empty or unset Codex executable configuration falls back to PATH/PATHEXT lookup.
  - Existing post-Codex script paths should be reviewed if users expected worktree-relative resolution.
- Logging/telemetry updates (if any):
  - No telemetry requirement is identified.
  - Error reporting must surface the clear missing-Codex preflight message.
- Compatibility notes (CLI flags, config schemas, versioning):
  - The Codex command must use PowerShell call-operator invocation with the resolved executable and preserve the optional objective argument.
  - Configuration schema documentation in `package.json` must describe the new executable-path setting and updated post-Codex path semantics.

## Test Strategy
Seeded from issue:

- [x] Unit coverage areas
- [x] Integration scenario to retest
- [x] Manual verification notes

Acceptance criteria:

- Running the command no longer emits a PowerShell command containing `; elseif`.
- The trust setup command can run without the `elseif` parse error.
- Missing Codex CLI produces the clear preflight error, or the command uses a resolved executable path.
- `.codex/scripts/post-codex-worktree-session.ps1` exists in this repo.
- A new Codex worktree receives `.codex` and `.agents` before Codex starts.
- The copy behavior is repo-specific through the configured post-Codex script mechanism.
- The extension remains generic.
- Regression tests cover trust command parsing/formatting, Codex CLI resolution, post-Codex script first-run behavior, and copy behavior for `.codex` and `.agents`.
- No unrelated files are changed.
- Applicable TypeScript and PowerShell formatting, lint/typecheck, and test commands pass in the repository-required order.

- Regression tests to add or update:
  - Add a Jest regression that asserts `buildCodexTrustCommand` output does not contain `; elseif` and does contain a valid `} elseif (` chain.
  - Add Jest builder coverage that verifies the Codex command uses the resolved executable with correct PowerShell quoting and preserves objective arguments.
  - Add command-handler tests for missing Codex CLI preflight failure before terminal creation and configured executable success.
  - Add command-handler coverage proving the post-Codex script is invoked from the source root with `-SourceRoot` and `-WorktreeRoot` before deferred Codex startup.
  - Add Pester coverage for `.codex/scripts/post-codex-worktree-session.ps1` copy planning and first-run-safe behavior.
- Unit tests (pytest) for the fixed behavior and boundaries:
  - Not applicable; issue #268 does not touch Python code.
  - Use Jest for TypeScript units and command wiring.
  - Use Pester for PowerShell script behavior.
- Edge cases and negative scenarios (invalid inputs, missing data, boundary values):
  - Missing Codex executable when the setting is blank and PATH lookup fails.
  - Configured Codex executable path with spaces.
  - Blank post-Codex script path remains omitted.
  - Missing source `.codex` or `.agents` folder is a non-fatal no-op.
  - Source and worktree roots resolving to the same location produce a no-op.
  - Existing destination files are overwritten only for copied source files; unrelated destination content remains untouched.
- Error handling and logging verification:
  - Assert the clear missing-Codex preflight message.
  - Assert no terminal is created when preflight fails.
  - Assert post-Codex copy errors are not swallowed when required filesystem operations fail.
- Coverage impact and targets for changed lines/modules:
  - New or changed TypeScript helpers and command branches should target at least 90% coverage through focused Jest tests.
  - New PowerShell functions in `.codex/scripts/post-codex-worktree-session.ps1` should target at least 90% coverage through focused Pester tests.
  - Repository-wide line coverage must remain at or above 80%.
- Toolchain commands to run (format → lint → type-check → test):
  - TypeScript: run the repository's Prettier command for the extension, then ESLint, then TSC, then Jest.
  - PowerShell: run PoshQC formatting, then PSScriptAnalyzer, then Pester.
  - Repeat from formatting if any step fails or changes files.
- Manual validation steps (if required):
  - Run `drm-copilot: New Codex Worktree Session` in a Windows PowerShell environment with `codex` available through the configured path or PATH.
  - Confirm the generated trust command does not contain `; elseif`.
  - Confirm `.codex` and `.agents` exist in the new worktree before Codex starts.
  - Confirm a missing Codex CLI reports the preflight message instead of creating a terminal that later fails with `codex: The term 'codex' is not recognized...`.


## Acceptance Criteria
- [x] Running `drm-copilot: New Codex Worktree Session` for issue #268 no longer emits generated PowerShell containing `; elseif`.
- [x] The Codex trust setup command runs without the `elseif: The term 'elseif' is not recognized as a name of a cmdlet...` parse error.
- [x] When `drmCopilotExtension.newCodexWorktreeSession.codexExecutablePath` is set, the Codex start command uses the resolved configured executable path with correct PowerShell quoting.
- [x] When `codexExecutablePath` is blank, the command resolves `codex` through PATH/PATHEXT before terminal creation.
- [x] When no configured executable or PATH fallback resolves, the command fails before terminal creation with the clear missing-Codex preflight error.
- [x] The configured post-Codex script path is resolved from the source repository root, not the new worktree root.
- [x] `.codex/scripts/post-codex-worktree-session.ps1` accepts source/worktree root inputs and is safe to run during the first worktree session.
- [x] A new Codex worktree receives `.codex` and `.agents` from the source repository before Codex starts.
- [x] Repository-specific `.codex` and `.agents` copy behavior is implemented only through the configured post-Codex script mechanism; the extension remains generic.
- [x] Regression tests cover trust command formatting, Codex CLI resolution, missing Codex preflight behavior, post-Codex source-root invocation, first-run script behavior, and `.codex`/`.agents` copy behavior.
- [x] No unrelated files, implementation surfaces, tests, or planning artifacts are changed outside the issue #268 scope.
- [x] Applicable TypeScript and PowerShell toolchain commands pass in required order: format, lint/analyze, type-check where applicable, then tests.
- [x] Extension configuration documentation in `package.json` matches the new `codexExecutablePath` setting and post-Codex source-root resolution behavior.

## Risks & Mitigations
- Technical or operational risks:
  - PATH/PATHEXT executable resolution can differ across shells and Windows installations.
  - Configured executable paths may contain spaces or special PowerShell characters.
  - Changing post-Codex path resolution from worktree-relative to source-root-relative may affect users who configured custom paths expecting the previous behavior.
  - Copying `.codex` and `.agents` can overwrite matching files in the new worktree.
  - PowerShell script tests can become coupled to ambient filesystem state if not isolated through injected helpers.
- Mitigations and rollbacks:
  - Reuse the existing runtime executable-probing pattern and extend test fixtures to cover `codex`.
  - Quote resolved executable and script paths through the existing PowerShell quoting helper.
  - Document the source-root resolution behavior in `package.json` configuration descriptions.
  - Limit copy scope to `.codex` and `.agents`, overwrite matching files with source content, and preserve unrelated destination content.
  - Test PowerShell behavior through AST-imported functions and injected scriptblocks, following existing repository conventions.

## Rollout & Follow-up
- Release/rollout steps:
  - Implement the issue #268 changes through the atomic plan after this spec is approved.
  - Run the TypeScript and PowerShell validation loops in repository-required order.
  - Manually verify the VS Code command in a Windows PowerShell environment.
  - Include issue #268 in commit and PR references.
- Post-fix monitoring or clean-up tasks:
  - Watch for user reports where custom post-Codex paths depended on worktree-relative resolution.
  - Consider documenting the post-Codex script contract in a separate extension reference if additional repositories adopt it.
  - No follow-up issue is required by the current research.
- Links: issue, PRs, related docs
  - Issue: https://github.com/drmoisan/drm-copilot/issues/268
  - Research: `artifacts/research/2026-07-02T13-17-codex-worktree-session-failures-268-research.md`
  - Feature folder: `docs/features/active/2026-07-02-codex-worktree-session-failures-268`
