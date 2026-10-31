# 2026-10-30-new-claude-worktree-session-commands-concatenated-in-container (Spec)

- **Issue:** #1003
- **Parent (optional):** none
- **Owner:** drmoisan
- **Last Updated:** 2026-10-30
- **Status:** Draft
- **Version:** 0.2

## Context
Running `drm-copilot: New Claude Worktree Session` from a Linux dev container on a destination repo fails with a PowerShell `ParserError`. The extension sends each setup command and the agent launch through the terminal input stream, and the text arrives at the shell as one concatenated line. The session never starts. The Codex worktree session (`drm-copilot: New Codex Worktree Session`) uses the same delivery mechanism and has the same exposure.

Environment:
- OS/version: Linux dev container (PowerShell, workspace `/workspaces/iar-migration`)
- Python version: not applicable
- Command/flags used: command palette `drm-copilot: New Claude Worktree Session`
- Data source or fixture: destination repo `iar-migration`

Impact / Severity:
- [ ] Blocker
- [ ] High
- [x] Medium
- [ ] Low

The command is unusable in this container environment. Local Windows use is unaffected.

## Repro & Evidence
Steps to Reproduce:
1. Open a destination repo in a dev container with the drm-copilot extension.
2. Run `drm-copilot: New Claude Worktree Session`.
3. Read the terminal output.

Expected:
Each command runs in order: create the parent directory, `git worktree add`, `Set-Location`, `poetry install --with dev`, venv activation, the pre-claude hook, then `claude`.

Actual:
The terminal echoes the commands, then receives them joined with no separators:

```
New-Item -ItemType Directory -Force -Path '/workspaces/iar-migration-wt' | Out-Nullgit -C '/workspaces/iar-migration' worktree add ... -b 'iar-migration-wt-2026-10-30T10-27'Set-Location '...'poetry install --with dev& './.venv/Scripts/Activate.ps1'if (Test-Path -LiteralPath '.claude/hooks/pre-claude-session.ps1') { ... }claude --dangerously-skip-permissions
ParserError:
Line |   1 | … 7'poetry install --with dev& './.venv/Scripts/Activate.ps1'if (Test-P …
     |   ~~ Unexpected token 'if' in expression or statement.
```

No worktree is created and Claude does not launch.

Logs / Screenshots:
- [x] Attached minimal logs or screenshot
- Snippet: see Actual Behavior.

## Scope & Non-Goals
- In scope:
  - Replace terminal input-stream delivery (`Terminal.sendText`) of setup commands and the agent launch with a single PowerShell script per session, delivered at process start through `shellArgs`.
  - Apply the change to both `newClaudeWorktreeSession` and `newCodexWorktreeSession`.
  - Replace the hard-coded Windows venv activation path with a runtime probe that works on Windows and Linux layouts, defined once and shared by both builders.
  - Fail-fast setup, per-step progress banners, and an encoded-length guard.
  - Unit tests, per-file coverage gates, README and CHANGELOG updates.
- Out of scope / non-goals:
  - `scripts/dev-tools/activate.ps1` (hard-codes `.venv\Scripts\Activate.ps1`; repository dev tooling, not the extension command path).
  - `scripts/dev-tools/DrmCopilotPromptSupport.ps1` (hard-codes `Scripts\Activate.ps1`; same reason).
  - The `extensions/drm-copilot/resources/templates` PowerShell mirror of `scripts/dev-tools/new-claude-worktree-session.ps1`; no file under `src/` references it.
  - The `package.json` version (managed by release automation). Command IDs and settings do not change.
  - The pre-existing README gap: the `## VS Code Commands` list does not include `drmCopilotExtension.newCodexWorktreeSession`.
- Explicitly excluded systems, integrations, or datasets:
  - Manual dev-container verification is not an acceptance gate. Unit-test proof of the delivered script and terminal options is the acceptance evidence.
  - No `.claude/rules/` file, `quality-tiers.yml` (absent at the repository root), `.github/instructions/` file, or execution-environment brief file is edited.

## Root Cause Analysis
Verified versus likely status follows the research record (`research/research.2026-10-30T11-30.md`, sections 2.1 and 2.2).

Verified facts:
1. `Terminal.sendText` rewrites line endings to `\r` and appends `\r` when executing. It does not wait for the shell to be ready (VS Code `TerminalInstance.sendText`, fetched).
2. Before the pty is ready, writes are queued and flushed in one write when the process spawns. "Ready" means the process has spawned, not that PowerShell or PSReadLine is reading input. The synchronous sends therefore reach the pty as one byte stream before the shell reads input (`TerminalProcessManager.write`, fetched).
3. On Unix, .NET `KeyParser` decodes `\r` as Enter and `\n` as Ctrl+Enter (`dotnet/runtime`, fetched).
4. PSReadLine binds Enter to `AcceptLine` in both Windows and Emacs tables, and binds Ctrl+Enter to `InsertLineAbove` only in the Windows table (fetched).
5. The reported output shows all command texts, including the deferred `claude`, joined into one accepted line. The path `/workspaces/iar-migration` shows the handler ran in the remote (container) extension host.
6. The extension declares no `extensionKind`, so as a workspace extension it runs on the remote side when connected to a container.

Likely mechanism (consistent with every verified fact; not reproduced):
- The queued bytes reach a Linux pty still in cooked mode (ICANON, ECHO, ICRNL). The kernel echoes them, which matches the report that the commands appear correctly echoed, and ICRNL translates each `\r` to `\n`.
- PSReadLine then reads `\n` as Ctrl+Enter. In the Emacs edit mode (understood, not fetched, to be the non-Windows default) Ctrl+Enter has no binding, so the line is not accepted and the texts accumulate in one buffer.
- The deferred `claude` send arrives after the terminal is in raw mode, so its `\r` is Enter and accepts the concatenated buffer, producing the `ParserError`.
- Windows local terminals use ConPTY with no ICRNL stage, which matches the statement that local Windows use is unaffected.

Consequence for the fix: any input reaching a Linux pty in cooked mode can have its Enter rewritten, including input that arrives while a native child such as `poetry install` runs (likely; not reproduced). A single combined `sendText` therefore does not remove the fault, and the deferred agent `sendText` has the same exposure. A timing-independent fix must not deliver setup or launch text through the terminal input stream.

Second defect (verified from builder source): the activation command is the literal `& './.venv/Scripts/Activate.ps1'`, the Windows venv layout. Linux venvs use `.venv/bin/Activate.ps1`. The literal is duplicated in `claude-worktree-session.ts` and `codex-worktree-session.ts`. `process.platform` and `vscode.env.remoteName` are not reliable inputs for the layout choice (`remoteName` does not identify the OS), so a runtime probe is used.

## Proposed Fix

### Design summary (what changes where):
Adopt research option (d), section 3.1 and section 4.

1. A new pure module `worktree-session-launch.ts` composes one PowerShell script per session from the existing command records, in the existing order, and returns the `shellArgs` for it.
   - Claude order: `ensureParentDirectory`, `git`, `setLocation`, `poetryInstall?`, `activate?`, `preClaude?`, then the `claude` launch.
   - Codex order: `ensureParentDirectory`, `git`, `setLocation`, `trustCodexProject`, `poetryInstall?`, `activate?`, `postCodex?`, then the `codex` launch.
   - Each conditional step keeps its current presence rule.
2. The script is encoded as base64 of UTF-16LE and passed as `shellArgs: ["-NoLogo", "-NoExit", "-EncodedCommand", <encoded>]`. `-NoExit` preserves the current end state of an interactive prompt in the worktree after the agent exits or after a setup failure. Base64 contains no spaces or quotes, so argument quoting cannot alter it.
3. Each handler calls `vscode.window.createTerminal` once with `hideFromUser: true` and then `terminal.show()`. `hideFromUser` terminals are skipped by the Python extension's auto-activation (microsoft/vscode-python `activation.ts`) and by the Python Environments extension (`shouldSkipTerminalActivation`). This removes the source of the injected activation text, so `TERMINAL_AUTO_ACTIVATION_GRACE_MS` and both `setTimeout` calls are deleted, and the agent launch is the last statement of the script.
4. No `sendText` is called for setup or for the agent launch, in either handler.
5. The runtime venv activation probe is defined once in `claude-worktree-session.ts` and imported by `codex-worktree-session.ts`, the same way `quoteForPwsh` is already imported. This also avoids an import cycle with the launch module.

### Boundaries and invariants to preserve:
- Builder modules and the launch module stay pure: no `vscode`, `node:fs`, or `node:child_process` imports. `Buffer` is a Node global and is permitted.
- Naming helpers (`buildWorktreeGroupDirectory`, `buildWorktreePath`, `buildBranchName`, `formatWorktreeTimestamp`) are unchanged.
- Command IDs, settings keys, and defaults are unchanged. The cancelled-prompt, missing-runtime, and Codex-resolution-failure paths behave as today.
- Conditional step presence rules are unchanged (`poetryInstall` and `activate` only when `usePoetry`; `preClaude` and `postCodex` only for a non-empty trimmed path).
- The fix must work on pwsh 7 and Windows PowerShell 5.1: no `&&`/`||`, no `$IsWindows`.
- Repository-owned pre/post scripts must not inherit a global `$ErrorActionPreference = 'Stop'`.

### Dependencies or blocked work:
None. Windows PowerShell 5.1 support for `-NoLogo`, `-NoExit`, and `-EncodedCommand` is to be confirmed against `about_PowerShell_exe` during planning (the research cites only the pwsh documentation).

### Implementation strategy (what changes, not sequencing):

#### Files/modules to change:
Production:
- `extensions/drm-copilot/src/worktree-session-launch.ts` (new): script composition, UTF-16LE base64 encoding, `shellArgs` construction, encoded-length guard.
- `extensions/drm-copilot/src/claude-worktree-session.ts`: runtime venv activation probe (single definition), `-ErrorAction Stop` on `New-Item` and `Set-Location`, interface doc comments that no longer prescribe separate `sendText` calls.
- `extensions/drm-copilot/src/codex-worktree-session.ts`: import the shared activation probe, `-ErrorAction Stop`, doc comments.
- `extensions/drm-copilot/src/extension.ts`: both handlers use `createTerminal({ ..., hideFromUser: true, shellArgs })`; remove `sendText` calls, `setTimeout`, and `TERMINAL_AUTO_ACTIVATION_GRACE_MS`; update the output-channel log text.

Tests:
- `extensions/drm-copilot/test/worktree-session-launch.test.ts` (new).
- `extensions/drm-copilot/test/claude-worktree-session-command.test.ts` (new; receives the moved and rewritten Claude handler tests).
- `extensions/drm-copilot/test/extension.workflow-commands.test.ts`: remove the moved `newClaudeWorktreeSession` tests.
- `extensions/drm-copilot/test/claude-worktree-session.test.ts`
- `extensions/drm-copilot/test/codex-worktree-session.test.ts`
- `extensions/drm-copilot/test/codex-worktree-session-command.test.ts`

Config:
- `extensions/drm-copilot/jest.config.cjs`: `coverageThreshold` entries for `./src/worktree-session-launch.ts`, `./src/claude-worktree-session.ts`, and `./src/codex-worktree-session.ts`, plus a conditional `./src/extension.ts` entry decided in planning from baseline `coverage/lcov.info` figures.

Docs:
- `extensions/drm-copilot/README.md`
- `extensions/drm-copilot/CHANGELOG.md`

No `.claude/rules/` file, `quality-tiers.yml`, `.github/instructions/` file, or execution-environment brief file is edited. No CI job, required check, or tool route changes.

#### Functions/classes/CLI commands impacted:
- `buildWorktreeSessionCommands` and `buildCodexWorktreeSessionCommands`: `activate` value, and `-ErrorAction Stop` on `ensureParentDirectory` and `setLocation`.
- New launch-module functions that compose the script and return `shellArgs`.
- Command handlers `drmCopilotExtension.newClaudeWorktreeSession` and `drmCopilotExtension.newCodexWorktreeSession`.

#### Data flow and validation changes:
- Before: builder records, then six or seven `sendText` calls, with the agent launch deferred by a timer.
- After: builder records, then one composed script, then one encoded `shellArgs` array, then one `createTerminal` call, then `show()`.
- Script structure (compatible with pwsh 7 and Windows PowerShell 5.1):
  - Setup runs inside `& { try { ... } catch { Write-Host "<session> setup failed: $_" -ForegroundColor Red } }` so helper variables stay out of the interactive global scope. `Set-Location` and the environment and global-function changes from `Activate.ps1` persist after the block.
  - After each native step (`git ... worktree add`, `poetry install --with dev`), `if ($LASTEXITCODE -ne 0) { throw ... }` with the step name and exit code.
  - `-ErrorAction Stop` on `New-Item` and `Set-Location`, rather than a block-wide `$ErrorActionPreference`.
  - The agent launch runs only after the `try` block completes without a caught error (flag set at the end of `try`, checked before launch).
  - Each step is preceded by a `Write-Host` banner.
- Activation probe (single statement list, valid as `activate` for both builders):
  `$venvActivate = @('./.venv/Scripts/Activate.ps1', './.venv/bin/Activate.ps1') | Where-Object { Test-Path -LiteralPath $_ } | Select-Object -First 1; if ($null -eq $venvActivate) { throw 'No virtual environment activation script found under ./.venv' }; & $venvActivate`
- Length guard: the launch module throws a clear `Error` before `createTerminal` when the encoded argument exceeds 30000 characters. The bound exists because Windows `CreateProcess` limits a command line to 32,767 characters and the user-supplied objective is embedded in the script. A length of exactly 30000 passes.

#### Error handling and logging updates:
- Setup failures are reported in the terminal in red with the failing step, and the terminal remains open at an interactive prompt (`-NoExit`).
- Length-guard failure surfaces as a thrown `Error` before terminal creation; the existing handler error reporting applies.
- The output-channel log line no longer says the agent send is deferred.

#### Rollback/feature-flag considerations (if applicable):
None. Rollback is a revert of the change. No feature flag is introduced.

### Intentional behavior changes
Each change below follows from the root cause (the fault is input-stream delivery under cooked-mode Enter translation) and is not incidental.

1. Fail-fast stop. Before, each line ran regardless of earlier failures (for example a failed `git worktree add` was followed by `poetry install` and `claude` in the source repository). Now setup stops at the first failed step and the agent is not launched. Required because a timing-independent single script has to define what a failed step means, and launching the agent in the wrong directory is the worse outcome. Non-terminating errors written by repository-owned pre/post scripts do not stop the launch, which preserves their present semantics. A terminating error thrown by those scripts or by the Codex trust command does stop it.
2. Removed delay. The 5-second grace period and `setTimeout` are deleted. They existed only to avoid the Python extension's injected activation text colliding with the agent TUI; `hideFromUser: true` removes that injection at its source, and a timer cannot guarantee ordering on a slow Linux shell start.
3. No command echo. `-EncodedCommand` does not echo commands. Per-step `Write-Host` banners replace the per-line echo.
4. `hideFromUser: true` followed by `show()`. Required so the Python extension does not inject activation text into the session. The terminal is shown immediately as before.
5. Probable loss of shell-integration decorations. VS Code's automatic pwsh shell-integration injection probably does not apply when `shellArgs` carry `-EncodedCommand` (likely; not verified). The handlers do not depend on shell integration.

### Technical specifications (interfaces/contracts):

#### Inputs/outputs and formats:
- Builder inputs (`WorktreeSessionCommandInput`, Codex equivalent) are unchanged; no new input is added for platform selection.
- The launch module takes the builder command record and the agent identity and returns the `shellArgs` array in the order `-NoLogo`, `-NoExit`, `-EncodedCommand`, `<base64 of UTF-16LE script>`. Decoding uses `Buffer.from(arg, "base64").toString("utf16le")`.

#### Required configuration keys and defaults:
Unchanged: `preClaudeScriptPath` (default `.claude/hooks/pre-claude-session.ps1`), the post-Codex script path setting, and the Codex executable path setting.

#### Backward-compatibility expectations:
- Windows local usage keeps the same step order and the same end state (interactive prompt in the activated worktree).
- Exported builder interfaces keep their field names; only values and doc comments change. Callers in the repository are updated in the same change.

#### Performance constraints (latency/throughput/memory):
Startup latency decreases because the fixed 5-second delay is removed. No other constraint applies. Script size is bounded by the length guard.

## Assumptions, Constraints, Dependencies
- Assumptions (environment, data, access):
  - The likely mechanism in Root Cause Analysis is not reproduced. The fix does not depend on it being exact, because it removes input-stream delivery altogether.
  - Windows PowerShell 5.1 accepts `-NoLogo`, `-NoExit`, and `-EncodedCommand` (to be confirmed in planning).
- Constraints (budget, performance, compatibility):
  - `extensions/drm-copilot/test/extension.workflow-commands.test.ts` is at 800 logical lines and must not grow. The Claude handler tests move to the new `claude-worktree-session-command.test.ts`.
  - `extensions/drm-copilot/src/extension.ts` is at 496 logical lines and must not grow past 500. New logic goes in `worktree-session-launch.ts`, so `extension.ts` shrinks.
  - File-size tiers: 500 guidance, 700 advisory, above 800 hard block.
  - `coverageThreshold` in `jest.config.cjs` is per-file with no `global` key, so the new module and both changed builders need their own entries (lines 85, branches 75).
  - Tests must not use temporary files, `process.platform` branching beyond the existing Codex executable helper, or wall-clock waits. The `drm-copilot Extension Tests` job runs on `ubuntu-latest` and `windows-latest`.
- External dependencies (services, libraries, releases): none added. `about_PowerShell_exe` and `about_pwsh` document the shell switches.

## Data / API / Config Impact
- User-facing or API changes: terminal behavior described under Intentional behavior changes. No command ID, setting, or contribution changes.
- Data or migration considerations: none.
- Logging/telemetry updates (if any): the output-channel log text no longer mentions a deferred agent send. No telemetry.
- Compatibility notes (CLI flags, config schemas, versioning): `package.json` version is not bumped. `CHANGELOG.md` gets a `### Fixed` bullet under `## [Unreleased]` for issue #1003, and the fail-fast change is recorded there and in the README.

## Test Strategy
Seeded from issue:

- [x] Unit coverage areas: command builder returns a platform-correct activation path; the session launcher emits the commands as one script, or as `;`-separated statements in one `sendText`, instead of many sends.
- [ ] Integration scenario to retest: Linux dev container and Windows host.
- [ ] Manual verification notes

Prefer a single script block per session so the result does not depend on terminal timing. Apply the same change to the Codex worktree session.

Refinement: delivery is through `shellArgs` at process start, not `sendText`. The integration scenario and manual verification are not acceptance gates. They are an optional post-merge check; unit-test proof of the decoded script and terminal options is the acceptance evidence.

- Regression tests to add or update:
  - New: `extensions/drm-copilot/test/worktree-session-launch.test.ts`, `extensions/drm-copilot/test/claude-worktree-session-command.test.ts`.
  - Updated: `claude-worktree-session.test.ts` (activation probe, `-ErrorAction Stop`), `codex-worktree-session.test.ts` (activation probe, `-ErrorAction Stop`), `codex-worktree-session-command.test.ts` (rewritten to assert `createTerminal` options, decoded script, `show` once, no `sendText`), and `extension.workflow-commands.test.ts` (Claude handler tests removed).
  - Fail-before: the handler test asserting no `sendText` and `hideFromUser: true`, and the builder test asserting the probe, fail on the current tree.
- Unit tests for the fixed behavior and boundaries (Jest):
  - Step ordering for each conditional combination (poetry on/off, pre/post script present/absent, objective blank/present).
  - `$LASTEXITCODE` guard after each native step; agent launch only after the guarded `try` block.
  - Base64 UTF-16LE round trip; `shellArgs` order; quotes and apostrophes in paths and objective survive encoding.
  - Length guard: throws above 30000, passes at 30000.
- Edge cases and negative scenarios: blank objective, empty pre/post script path, apostrophes and spaces in paths, over-length objective, cancelled prompt, missing powershell runtime, unresolved Codex executable.
- Error handling and logging verification: length-guard error thrown before `createTerminal`; setup-failure banner text present in the decoded script; log text no longer references a deferred send.
- Coverage impact and targets for changed lines/modules: lines 85 and branches 75 on `worktree-session-launch.ts`, `claude-worktree-session.ts`, and `codex-worktree-session.ts`. Baseline and post-change per-file figures for `extension.ts` are recorded from `coverage/lcov.info`; changed lines must not lose coverage.
- Toolchain commands to run (format, lint, type-check, test): Prettier, ESLint, `tsc`, then Jest with coverage through `node run-jest.cjs`, repeated until a single pass is clean. A seeded shuffled Jest run is recorded under the feature `evidence/regression-testing/` folder.
- Manual validation steps (if required): none required. An optional post-merge check in a Linux dev container and on a Windows host.

## Acceptance Criteria
- [ ] Neither `newClaudeWorktreeSession` nor `newCodexWorktreeSession` calls `Terminal.sendText` for setup or for the agent launch; a handler test asserts `sendText` is never called for each.
- [ ] Each handler calls `vscode.window.createTerminal` exactly once, with `hideFromUser: true`, the expected `cwd` and `shellPath`, and `shellArgs` equal to `-NoLogo`, `-NoExit`, `-EncodedCommand`, followed by one encoded argument, in that order; `terminal.show()` is called once after creation.
- [ ] The encoded argument decodes (base64, UTF-16LE) to a single script that contains the Claude steps in the order `ensureParentDirectory`, `git`, `setLocation`, `poetryInstall`, `activate`, `preClaude`, then the `claude` launch, with `poetryInstall` and `activate` present only when the workspace uses poetry, `preClaude` present only for a non-empty configured path, and the objective present only when non-blank.
- [ ] The Codex script decodes to the steps in the order `ensureParentDirectory`, `git`, `setLocation`, `trustCodexProject`, `poetryInstall`, `activate`, `postCodex`, then the `codex` launch, with each conditional step present or absent under the same rules as before the change.
- [x] The composed script checks `$LASTEXITCODE` and throws after the `git worktree add` step and after the `poetry install --with dev` step, and `New-Item` and `Set-Location` carry `-ErrorAction Stop`.
- [x] The composed script launches the agent only after the setup `try` block completes without a caught error, and a setup failure writes a red step-failure message instead of launching the agent; a test asserts the launch statement is positioned after the guarded block.
- [x] The composed script contains a `Write-Host` banner for each emitted step.
- [x] The script avoids `&&`, `||`, and `$IsWindows`, and does not set a block-wide `$ErrorActionPreference`, so it is valid on pwsh 7 and Windows PowerShell 5.1.
- [x] The venv activation probe text (both candidate paths `./.venv/Scripts/Activate.ps1` and `./.venv/bin/Activate.ps1`, the `throw` message, and the `&` invocation) appears in the `activate` value returned by both the Claude and Codex builders, and is defined once in `claude-worktree-session.ts` and imported by `codex-worktree-session.ts`.
- [ ] The length guard throws an `Error` before `createTerminal` when the encoded argument is longer than 30000 characters, and does not throw when it is exactly 30000 characters; a handler test asserts `createTerminal` is not called when the guard throws.
- [x] Paths and objectives that contain spaces, double quotes, and apostrophes survive encoding and decode to correctly quoted script text.
- [ ] `TERMINAL_AUTO_ACTIVATION_GRACE_MS` and both `setTimeout` calls are removed from `extension.ts`, no handler test uses fake timers for the agent launch, and the output-channel log text no longer mentions a deferred send.
- [ ] The cancelled-prompt, missing-powershell-runtime, and unresolved-Codex-executable paths behave as before and still do not create a terminal.
- [ ] `worktree-session-launch.ts`, `claude-worktree-session.ts`, and `codex-worktree-session.ts` contain no `vscode`, `node:fs`, or `node:child_process` imports.
- [ ] `extensions/drm-copilot/jest.config.cjs` has `coverageThreshold` entries with lines 85 and branches 75 for `./src/worktree-session-launch.ts`, `./src/claude-worktree-session.ts`, and `./src/codex-worktree-session.ts`, and Jest with coverage meets them.
- [ ] Coverage of the changed lines in `extension.ts` is not lower than the recorded baseline, with baseline and post-change figures recorded from `coverage/lcov.info`.
- [ ] Test-suite results are stable: a seeded shuffled Jest run passes, and the new tests create no temporary files and do not branch on `process.platform` except through the existing Codex executable helper.
- [ ] `extension.workflow-commands.test.ts` has no more than 800 logical lines, `extension.ts` has no more than 500 logical lines, and no other changed or new file exceeds 800 lines.
- [ ] The Claude handler tests are located in `claude-worktree-session-command.test.ts`, and the moved tests are no longer present in `extension.workflow-commands.test.ts`.
- [ ] A fail-before record shows that the no-`sendText` and `hideFromUser: true` handler test and the activation-probe builder test fail on the pre-change tree and pass after the change.
- [ ] `extensions/drm-copilot/README.md` `## New Claude Worktree Session` describes single-script delivery, `hideFromUser`, fail-fast behavior, and per-step banners, and no longer says commands are sent individually.
- [ ] `extensions/drm-copilot/CHANGELOG.md` has a `### Fixed` bullet under `## [Unreleased]` for issue #1003 that records the fail-fast behavior change; `package.json` version is unchanged.
- [ ] No file in `scripts/dev-tools/activate.ps1`, `scripts/dev-tools/DrmCopilotPromptSupport.ps1`, the `resources/templates` mirror, `.claude/rules/`, `.github/instructions/`, or the execution-environment brief is modified, and `quality-tiers.yml` is not created.
- [ ] The full TypeScript toolchain (Prettier, ESLint, `tsc`, and Jest with coverage through `node run-jest.cjs`) passes in a single pass with no errors.

## Risks & Mitigations
- Technical or operational risks:
  - The cooked-mode mechanism is likely but not reproduced. Mitigation: the fix removes input-stream delivery entirely, so its correctness does not depend on the exact mechanism.
  - Fail-fast, removed delay, and `hideFromUser` are behavior changes a reviewer could read as out of scope. Mitigation: each is stated above as a consequence of the root cause, tested, and recorded in the README and CHANGELOG.
  - Shell-integration decorations may be absent in these terminals (likely; not verified). Mitigation: the handlers do not depend on shell integration; recorded in the README.
  - A very long objective can exceed the Windows command-line limit. Mitigation: the 30000-character guard fails explicitly before terminal creation.
  - Windows PowerShell 5.1 switch support is cited from pwsh documentation only. Mitigation: confirm in planning against `about_PowerShell_exe`.
  - `extension.workflow-commands.test.ts` at exactly 800 lines and `extension.ts` at 496 lines leave no growth room. Mitigation: move the Claude handler tests and place new logic in `worktree-session-launch.ts`.
- Mitigations and rollbacks: revert the change; no data or configuration migration is involved.

## Rollout & Follow-up
- Release/rollout steps: ships with the next extension release through the existing release automation; no version bump in this change.
- Post-fix monitoring or clean-up tasks:
  - Optional post-merge check in a Linux dev container and on a Windows host.
  - `scripts/dev-tools/activate.ps1`, `scripts/dev-tools/DrmCopilotPromptSupport.ps1`, and the README `## VS Code Commands` gap are recorded as out of scope and are not addressed here.
- Links: issue https://github.com/drmoisan/drm-copilot/issues/1003; research `research/research.2026-10-30T11-30.md`; plan `plan.2026-10-30T06-59.md`.
