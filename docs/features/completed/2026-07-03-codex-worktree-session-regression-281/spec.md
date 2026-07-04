# codex-worktree-session-regression (Spec)

- **Issue:** #281
- **Parent (optional):** none
- **Owner:** drmoisan
- **Last Updated:** 2026-07-03T09-14
- **Status:** Draft
- **Version:** 0.1

## Context
`drm-copilot: New Codex Worktree Session` still emits a malformed Codex trust command, does not copy the repo-local `.codex` and `.agents` customizations into the created worktree, and starts `codex` through an unresolved bare executable name. The behavior expected from Issue 268 is not present in the merged release state.

Environment:
- OS/version: Windows PowerShell on Windows
- Python version: 3.13 virtual environment created by `poetry install --with dev`
- Command/flags used: VS Code command `drm-copilot: New Codex Worktree Session`
- Data source or fixture: Worktree `C:\Users\DanMoisan\repos\drm-copilot-wt-2026-07-03-08-58` created from `drm-copilot` at `476b110`

Impact / Severity:
- [ ] Blocker
- [ ] High
- [x] Medium
- [ ] Low


## Repro & Evidence
Steps to Reproduce:
1. From `C:\Users\DanMoisan\repos\drm-copilot`, run `drm-copilot: New Codex Worktree Session`.
2. Allow the command to create a new worktree and switch into it.
3. Observe the generated PowerShell command sequence through Codex launch.

Expected:
The command creates the git worktree, changes location to the new worktree, adds Codex trust without a PowerShell parse error, installs or activates Poetry when applicable, runs `.codex/scripts/post-codex-worktree-session.ps1`, copies `.codex` and `.agents` into the new worktree before launch, and starts Codex using extension-level executable resolution.

Actual:
The trust setup command emitted `elseif` at the start of a new prompt statement, which PowerShell treated as a command instead of part of the preceding `if` statement. The post-Codex script path check ran but neither `.codex` nor `.agents` was copied into the worktree. The final launch attempted a bare `codex` command and failed because the executable was not resolved.

Logs / Screenshots:
- [x] Attached minimal logs or screenshot
- Snippet:

```powershell
elseif: The term 'elseif' is not recognized as a name of a cmdlet, function, script file, or executable program.
codex: The term 'codex' is not recognized as a name of a cmdlet, function, script file, or executable program.
```


## Scope & Non-Goals
- In scope:
  - Restore the Issue #281 regression behavior for `drm-copilot: New Codex Worktree Session` so the command produces the expected first-run Codex worktree setup.
  - Ensure the generated command sequence changes location to the new worktree, configures Codex trust without malformed `elseif`, runs the configured post-Codex script, and starts Codex only through a resolved executable.
  - Keep the VS Code extension generic by invoking `drmCopilotExtension.newCodexWorktreeSession.postCodexScriptPath` rather than hardcoding repository-specific `.codex` or `.agents` copy behavior into extension code.
  - Implement repository-specific worktree customization copy behavior in the configured post-worktree script so `.codex` and `.agents` from the source repository are available in the new worktree before Codex launches.
  - Make the post-worktree script rerunnable, deterministic when destination folders already exist, explicit about skipped content, and safe from transient or machine-local file copies.
  - Add regression coverage for trust command serialization, Codex executable resolution, post-Codex script invocation timing, source-root resolution, rerun behavior, and `.codex` / `.agents` copy behavior.
- Out of scope / non-goals:
  - Replacing the generic extension mechanism with repository-specific extension logic.
  - Changing non-Codex worktree commands, branch naming, issue promotion, or orchestration routing behavior.
  - Copying unrelated repository content outside `.codex` and `.agents`.
  - Introducing new runtime dependencies for path resolution, git root detection, executable lookup, or copy behavior.
- Explicitly excluded systems, integrations, or datasets:
  - External services and remote APIs.
  - User-local Codex session history, caches, logs, credentials, virtual environments, or other transient machine-local files.
  - GitHub issue mutation beyond existing Issue #281 references and local active-folder artifacts.

## Root Cause Analysis
The bundled post-worktree script currently derives the source root from its own copied `.codex/scripts` path, so a destination worktree copy resolves the destination as both source and destination and returns without copying. The root `.codex/scripts/post-codex-worktree-session.ps1` in the failed worktree is only a strict-mode stub. The extension command builder should also be checked for trust command line-break serialization and Codex executable resolution.


## Proposed Fix

### Design summary (what changes where):
Use a two-boundary fix for Issue #281. The extension remains responsible for generic command construction, configuration lookup, executable resolution, and invoking the configured post-Codex script. Repository-specific `.codex` and `.agents` copy behavior stays in the configured post-worktree script, which must run after `Set-Location` and Codex trust setup, and before Codex launch.

### Boundaries and invariants to preserve:
The extension must not hardcode `drm-copilot` repository customization folders or file-copy rules. It must continue to honor `drmCopilotExtension.newCodexWorktreeSession.postCodexScriptPath`, resolve that configured script from the source repository when needed, and preserve the existing worktree creation flow. The command sequence must not emit malformed `elseif`, must not launch a bare unresolved `codex`, and must not start Codex before the post-worktree script has completed.

The post-worktree script must use strict PowerShell behavior, including strict mode and stop-on-error semantics. It must resolve the source repository robustly, preferring git common-dir or main-worktree information when available, then fall back deterministically when git metadata is unavailable. It must copy only the intended `.codex` and `.agents` customization content, skip transient or machine-local content, and log concise source, destination, copied, and skipped messages.

### Dependencies or blocked work:
No new runtime dependency is required. Existing VS Code extension code, Node path/process utilities, git command output, PowerShell, Jest, PSScriptAnalyzer, and Pester are sufficient. The provided Issue #281 evidence and original behavior requirements are sufficient to proceed without a `user-story.md` for full-bug mode.

### Implementation strategy (what changes, not sequencing):
Repair the regression through scoped updates to the Codex worktree command builder, command runtime/executable resolution path, extension command wiring, repository post-worktree script, and focused regression tests. Keep path and copy decisions isolated so the generic extension remains reusable outside this repository.

#### Files/modules to change:
- `extensions/drm-copilot/src/codex-worktree-session.ts`
- `extensions/drm-copilot/src/extension.ts`
- `extensions/drm-copilot/src/command-runtime.ts`
- `extensions/drm-copilot/package.json`
- `extensions/drm-copilot/test/codex-worktree-session.test.ts`
- `extensions/drm-copilot/test/codex-worktree-session-command.test.ts`
- `extensions/drm-copilot/test/extension-test-harness.ts`
- `extensions/drm-copilot/test/runtime-test-helpers.ts`
- `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/scripts/post-codex-worktree-session.ps1`
- PowerShell regression tests under `tests/scripts/` following existing script-test conventions.

#### Functions/classes/CLI commands impacted:
- `buildCodexTrustCommand` must emit the `if (...) { ... } elseif (...) { ... }` chain as one syntactically valid PowerShell statement.
- `buildCodexWorktreeSessionCommands` must receive and emit a resolved Codex executable command rather than a bare unresolved `codex`.
- `newCodexWorktreeSession` must resolve Codex before launch, invoke the configured post-Codex script after `Set-Location` and trust setup, and ensure the script runs before Codex starts.
- Runtime executable probing must resolve configured Codex paths and default `codex` through PATH/PATHEXT before terminal creation.
- The post-worktree script must expose testable functions or script boundaries for source-root resolution, copy planning, skip filtering, and concise logging.

#### Data flow and validation changes:
- The command handler reads `postCodexScriptPath` and Codex executable configuration before constructing the terminal command sequence.
- The post-Codex script path is resolved against the source repository root when configured as a relative path.
- The Codex executable is resolved from the configured value when present; otherwise, default `codex` is resolved through PATH/PATHEXT.
- The terminal command sequence creates the worktree, runs `Set-Location` for the new worktree, configures Codex trust, performs any existing Poetry setup, invokes the configured post-Codex script, then launches Codex with the resolved executable.
- The post-worktree script resolves source and destination roots, plans `.codex` and `.agents` copies in deterministic order, excludes transient or machine-local content, and applies copy operations in a rerunnable way.

#### Error handling and logging updates:
- Missing Codex executable resolution must fail before terminal creation with a clear configuration-oriented error.
- PowerShell parse errors from generated `elseif` command shape must be prevented by construction and covered by tests.
- Post-worktree script failures must stop execution and return a non-zero failure rather than silently allowing Codex to start without required customizations.
- Missing optional source folders must be logged as skipped rather than treated as fatal.
- Post-worktree script logs must be concise and include source root, destination root, copied entries, and skipped entries.

#### Rollback/feature-flag considerations (if applicable):
No feature flag is required. Rollback consists of reverting the Issue #281 changes to the command builder, command handler, configuration documentation, tests, and post-worktree script. The extension configuration remains backward compatible because `postCodexScriptPath` continues to be the customization boundary and Codex executable resolution can continue to use PATH when no explicit path is configured.

### Technical specifications (interfaces/contracts):

#### Inputs/outputs and formats:
- Input: VS Code command `drm-copilot: New Codex Worktree Session`.
- Input: `drmCopilotExtension.newCodexWorktreeSession.postCodexScriptPath`, resolved against the source repository root when relative.
- Input: Codex executable setting or default `codex` PATH/PATHEXT resolution.
- Input: source repository root and new worktree root, passed or resolved so the post-worktree script can distinguish source from destination.
- Output: generated PowerShell command sequence with no malformed `; elseif` or prompt-start `elseif`.
- Output: generated Codex launch command using the resolved executable path.
- Output: new worktree containing the intended `.codex` and `.agents` customization content before Codex starts.
- Output: concise post-worktree script log lines for source, destination, copied entries, and skipped entries.

#### Required configuration keys and defaults:
- Existing: `drmCopilotExtension.newCodexWorktreeSession.postCodexScriptPath`, defaulting to `.codex/scripts/post-codex-worktree-session.ps1`.
- Existing or intended Codex executable configuration must support an explicit executable path and default PATH/PATHEXT lookup when unset.
- Configuration documentation must state that repository-specific setup belongs in `postCodexScriptPath`, not in generic extension code.

#### Backward-compatibility expectations:
- Existing users with `codex` on PATH continue to work without setting an explicit executable path.
- Existing repositories without a post-Codex script continue to skip that step according to current configuration semantics.
- Existing configured post-Codex scripts remain supported when they are available from the source repository.
- The extension remains repository-agnostic and does not require `drm-copilot` customization folders for other repositories.

#### Performance constraints (latency/throughput/memory):
- Codex executable resolution and post-Codex path resolution should run once per command invocation before terminal creation.
- Post-worktree copying is limited to `.codex` and `.agents`, with deterministic traversal and no background watchers or caching.
- Copy behavior must avoid scanning unrelated repository content.

## Assumptions, Constraints, Dependencies
- Assumptions (environment, data, access):
  - The observed regression occurred on Windows PowerShell in worktree `C:\Users\DanMoisan\repos\drm-copilot-wt-2026-07-03-08-58`.
  - The source repository contains the `.codex` and `.agents` customizations that must be available in the new worktree.
  - Git metadata is available in normal worktree runs, but the post-worktree script still needs a deterministic fallback for test and degraded environments.
- Constraints (budget, performance, compatibility):
  - Do not move repository-specific copy behavior into the generic extension.
  - Do not copy transient, credential, cache, log, virtual-environment, or user-local runtime files.
  - Do not create new runtime dependencies.
  - Preserve the repository-required format -> lint/analyze -> type-check where applicable -> test validation order.
- External dependencies (services, libraries, releases):
  - No external service dependency is required.
  - Codex CLI must be installed on PATH or configured through the extension executable setting at runtime.
  - Existing TypeScript and PowerShell test toolchains remain the validation dependencies.

## Data / API / Config Impact
- User-facing or API changes:
  - Missing Codex executable should be reported before terminal creation instead of surfacing as a later shell `codex` command failure.
  - The configured post-Codex script must run during the generated command sequence before Codex starts.
- Data or migration considerations:
  - No data migration is required.
  - Existing destination `.codex` and `.agents` folders in a new worktree must be handled deterministically on rerun.
  - Transient or machine-local files must not be copied into the destination worktree.
- Logging/telemetry updates (if any):
  - No telemetry requirement is identified.
  - Post-worktree script logging must be concise and include source, destination, copied, and skipped information.
- Compatibility notes (CLI flags, config schemas, versioning):
  - Codex launch must preserve existing objective/prompt argument behavior while using the resolved executable path.
  - Configuration descriptions should make `postCodexScriptPath` the documented customization hook for repository-specific setup.

## Test Strategy
Seeded from issue:

- [x] Unit coverage areas: trust command serialization, Codex executable resolution, post-worktree copy script source-root resolution, rerun behavior
- [x] Integration scenario to retest: generated terminal command sequence contains the configured post-Codex script and launches resolved Codex executable
- [x] Manual verification notes: simulate a new worktree with `.codex` and `.agents` absent before running the post-Codex script

- Regression tests to add or update:
  - Add or update Jest coverage proving the trust command output contains a valid `} elseif (` chain and does not contain `; elseif`.
  - Add or update Jest command-builder coverage proving the configured post-Codex script runs before Codex launch and after the command has moved into the new worktree.
  - Add or update Jest command-handler coverage proving Codex executable resolution occurs before launch and missing Codex fails before terminal creation.
  - Add or update PowerShell Pester coverage for post-worktree script source-root resolution through git common-dir or main-worktree data when available.
  - Add or update PowerShell Pester coverage for rerunnable `.codex` and `.agents` copy behavior, deterministic existing-destination handling, transient-file skips, and concise log output.
- Unit tests (pytest) for the fixed behavior and boundaries:
  - Not applicable; Issue #281 is scoped to TypeScript extension code and PowerShell script behavior.
- Edge cases and negative scenarios (invalid inputs, missing data, boundary values):
  - Trust command generation must not emit `elseif` as a separate prompt statement.
  - Configured Codex executable path contains spaces.
  - Default `codex` is absent from PATH/PATHEXT.
  - `postCodexScriptPath` is blank or missing.
  - Source `.codex` or `.agents` folder is missing.
  - Source and destination resolve to the same root.
  - Destination `.codex` and `.agents` already exist.
  - Source customization folders contain transient or machine-local files that must be skipped.
- Error handling and logging verification:
  - Assert the missing-Codex preflight message is surfaced before terminal creation.
  - Assert post-worktree script copy failures stop execution.
  - Assert missing optional folders are skipped with concise logs.
  - Assert logs include source, destination, copied, and skipped information without verbose file dumps.
- Coverage impact and targets for changed lines/modules:
  - New or changed TypeScript helpers and command branches should target at least 90% line coverage through focused Jest tests.
  - New or changed PowerShell script functions should target at least 90% line coverage through focused Pester tests.
  - Repository-wide line coverage must remain at or above 80%.
- Toolchain commands to run (format -> lint -> type-check -> test):
  - TypeScript: run the extension formatting command, then lint, then type-check, then tests.
  - PowerShell: run formatting, then PSScriptAnalyzer, then Pester.
  - Restart from formatting if any step fails or modifies files.
- Manual validation steps (if required):
  - Run `drm-copilot: New Codex Worktree Session` on Windows PowerShell for Issue #281.
  - Confirm the generated trust command does not contain malformed `elseif`.
  - Confirm `.codex` and `.agents` exist in the new worktree before Codex starts.
  - Confirm Codex launches through a resolved executable path.
  - Confirm missing Codex produces a clear preflight failure rather than `codex: The term 'codex' is not recognized...`.


## Acceptance Criteria
- [x] AC-1: Running `drm-copilot: New Codex Worktree Session` for Issue #281 no longer emits generated PowerShell containing `; elseif` or a prompt-start `elseif` statement.
- [x] AC-2: The Codex trust setup command runs after `Set-Location` without the `elseif: The term 'elseif' is not recognized as a name of a cmdlet...` error.
- [x] AC-3: The generated command invokes the configured `postCodexScriptPath` after `Set-Location` and Codex trust setup, and before Codex launch.
- [x] AC-4: The VS Code extension remains generic: repository-specific `.codex` and `.agents` copy behavior is implemented only through the configured post-Codex script mechanism.
- [x] AC-5: Codex executable resolution occurs before launch, uses an explicitly configured executable when provided, falls back to PATH/PATHEXT lookup for `codex` when unset, and does not emit a bare unresolved `codex` launch command.
- [x] AC-6: Missing Codex executable resolution fails before terminal creation with a clear configuration-oriented error instead of a later shell `codex: The term 'codex' is not recognized...` failure.
- [x] AC-7: The post-worktree script uses strict mode and stop-on-error semantics, resolves the source root robustly through git common-dir or main-worktree information when possible, and has deterministic fallback behavior.
- [x] AC-8: The post-worktree script copies source repository `.codex` and `.agents` content into the destination worktree before Codex starts, is rerunnable, handles existing destination folders deterministically, and skips transient or machine-local files.
- [x] AC-9: Post-worktree script logging is concise and includes source root, destination root, copied entries, and skipped entries.
- [x] AC-10: Regression tests cover trust command serialization, Codex executable resolution, missing-Codex preflight behavior, post-Codex invocation timing, source-root resolution, rerun behavior, destination-existing behavior, transient-file skips, and `.codex` / `.agents` copy behavior.
- [x] AC-11: Manual Windows PowerShell validation for Issue #281 confirms `.codex` and `.agents` are present in the new worktree before Codex starts and confirms neither observed error appears.
- [x] AC-12: Applicable TypeScript and PowerShell toolchain commands pass in repository-required order: format, lint/analyze, type-check where applicable, then test.
- [x] AC-13: Documentation and configuration descriptions match the Issue #281 behavior, including `postCodexScriptPath` as the repository-specific setup hook and resolved Codex executable launch behavior.

## Risks & Mitigations
- Technical or operational risks:
  - Git common-dir and main-worktree metadata can differ between normal repositories, linked worktrees, and test fixtures.
  - Configured executable paths can contain spaces or PowerShell-sensitive characters.
  - Existing destination `.codex` or `.agents` content can differ from the source copy.
  - Broad copy logic could accidentally copy transient user-local state.
  - Moving repository-specific copy behavior into extension code would reduce extension reuse for other repositories.
- Mitigations and rollbacks:
  - Cover git metadata resolution and fallback behavior with focused PowerShell tests.
  - Quote executable and script paths through the existing PowerShell command-quoting path.
  - Use deterministic traversal and explicit skip rules for machine-local content.
  - Limit copy scope to `.codex` and `.agents` and preserve the extension/script boundary.
  - Roll back by reverting the scoped Issue #281 command-builder, runtime, configuration, script, and test changes.

## Rollout & Follow-up
- Release/rollout steps:
  - Implement the Issue #281 changes through the active orchestration plan.
  - Run TypeScript and PowerShell validation loops in repository-required order.
  - Manually verify the VS Code command in a Windows PowerShell environment.
  - Reference Issue #281 in commit and PR artifacts.
- Post-fix monitoring or clean-up tasks:
  - Watch for reports where custom `postCodexScriptPath` values expected worktree-relative behavior.
  - Consider documenting the post-Codex script contract separately if more repositories adopt this setup hook.
- Links: issue, PRs, related docs
  - Issue: https://github.com/drmoisan/drm-copilot/issues/281
  - Feature folder: `docs/features/active/2026-07-03-codex-worktree-session-regression-281`
