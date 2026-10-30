# Research: Worktree session commands concatenated in a Linux dev container (Issue #1003)

- Issue: #1003 (bug, work mode full-bug)
- Branch: `bug/new-claude-worktree-session-commands-concatenated-1003`
- Requirements source: `issue.md` and `spec.md` in this feature folder
- Filename stamp note: the task-researcher agent has no clock-reading tool. The `2026-10-30T11-30` stamp in this file's name was chosen to follow the plan stamp (`2026-10-30T06-59` America/New_York, which is 10-59 UTC). It was not read from the host clock. The orchestrator can rename the file if a clock-read stamp is required.
- Environment facts (tool routes, CI shape, coverage gates, preflight defect classes) are defined in `.claude/skills/execution-environment/SKILL.md` and are not repeated here.

## 1. Current State

### 1.1 Command builders

`extensions/drm-copilot/src/claude-worktree-session.ts` is a pure module with no `vscode`, `node:fs`, or `node:child_process` imports.

- `WorktreeSessionCommandInput`: `repoRoot`, `worktreePath`, `branchName`, `usePoetry`, `objective`, `preClaudeScriptPath`.
- `WorktreeSessionCommands`: `ensureParentDirectory`, `git`, `setLocation`, `poetryInstall | undefined`, `activate | undefined`, `preClaude | undefined`, `claude`. The interface doc comment says the handler "must send these as separate `sendText` invocations", and the `ensureParentDirectory` doc says it is sent "via its own `terminal.sendText`".
- `buildWorktreeSessionCommands` builds:
  - `ensureParentDirectory`: `New-Item -ItemType Directory -Force -Path '<group>' | Out-Null`, where `<group>` comes from `deriveWorktreeGroupDirectory`.
  - `git`: `git -C '<repoRoot>' worktree add '<path>' -b '<branch>'`.
  - `setLocation`: `Set-Location '<path>'`.
  - `poetryInstall`: `poetry install --with dev` only when `usePoetry` is true.
  - `activate`: the literal `& './.venv/Scripts/Activate.ps1'` only when `usePoetry` is true. This is the Windows venv layout, and it is the second defect in the issue.
  - `preClaude`: `if (Test-Path -LiteralPath '<p>') { & '<p>' }` only when the trimmed path is non-empty.
  - `claude`: `claude --dangerously-skip-permissions` plus an optional quoted objective.
- `quoteForPwsh` handles single-quote escaping. `buildWorktreeGroupDirectory`, `buildWorktreePath`, `buildBranchName`, and `formatWorktreeTimestamp` are naming helpers. This fix does not affect them.

`extensions/drm-copilot/src/codex-worktree-session.ts` imports `deriveWorktreeGroupDirectory` and `quoteForPwsh` from the Claude module.

- `CodexWorktreeSessionCommands`: `ensureParentDirectory`, `git`, `setLocation`, `trustCodexProject`, `poetryInstall | undefined`, `activate | undefined`, `postCodex | undefined`, `codex`.
- `buildCodexTrustCommand` returns one long statement list joined with `"; "`. It throws on a missing target and on an existing untrusted entry.
- `buildCodexWorktreeSessionCommands` duplicates the same `activate` literal `& './.venv/Scripts/Activate.ps1'`. `postCodex` is `if (Test-Path ...) { & '<p>' -SourceRoot '<repo>' -WorktreeRoot '<path>' }`. `codex` is `& '<codexExecutablePath>'` plus an optional objective.

### 1.2 Dispatch in `extensions/drm-copilot/src/extension.ts`

- `TERMINAL_AUTO_ACTIVATION_GRACE_MS = 5000`. The header comment states the rationale: VS Code's Python extension injects venv activation through a deferred `terminal.sendText`, and if `claude` starts first, the injected text lands in claude's TUI.
- The `drmCopilotExtension.newClaudeWorktreeSession` handler (inside `activate`) prompts for the objective, then calls `detectRuntime("powershell")`, which returns `pwsh` or falls back to `powershell` (Windows PowerShell 5.1; see `runtime-detection.ts` `detectRuntime`). It computes the paths, reads `preClaudeScriptPath` (default `.claude/hooks/pre-claude-session.ps1`), and calls `vscode.window.createTerminal({ name, cwd: workspaceRoot, shellPath: runtime.executable, shellArgs: ["-NoLogo"] })` and then `terminal.show()`. It then calls `terminal.sendText(cmd, true)` once each for `ensureParentDirectory`, `git`, `setLocation`, `poetryInstall` (if defined), `activate` (if defined), and `preClaude` (if defined), and finally `setTimeout(() => terminal.sendText(commands.claude, true), TERMINAL_AUTO_ACTIVATION_GRACE_MS)`. It logs a line ending in `claude send deferred by 5000ms`.
- The `drmCopilotExtension.newCodexWorktreeSession` handler has the same shape. It sends `ensureParentDirectory`, `git`, `setLocation`, `trustCodexProject`, `poetryInstall?`, `activate?`, and `postCodex?` synchronously, and sends `codex` through the same deferred `setTimeout`. `postCodexScriptPath` is resolved against the source root by `resolveSourceRootPath`.
- `pyprojectHasPoetry` sets `usePoetry` when `pyproject.toml` contains the substring `poetry`.

## 2. Root Cause

### 2.1 Verified facts

1. `Terminal.sendText` line endings. In `TerminalInstance.sendText` (`src/vs/workbench/contrib/terminal/browser/terminalInstance.ts`, microsoft/vscode `main`, fetched), the code is `text = text.replace(/\r?\n/g, '\r')`, followed by `if (shouldExecute && !text.endsWith('\r')) { text += '\r'; }`. Every send therefore ends in a carriage return (`\r`), not `\n`. Bracketed paste is applied only when `forceBracketedPasteMode` is passed and xterm has the mode enabled. The public extension API does not pass it. `sendText` does not wait for the shell to be ready.
2. Pre-launch queue. `TerminalProcessManager.write` (`terminalProcessManager.ts`, fetched) pushes data to `_preLaunchInputQueue` while the pty is not ready. When the process becomes ready, it sends the whole queue in one write: `newProcess.input(this._preLaunchInputQueue.join(''))`. "Pty ready" means the process has spawned, not that PowerShell or PSReadLine is ready. The six synchronous sends in the Claude handler therefore reach the pty as one byte stream, `cmd1\rcmd2\r...\rcmd6\r`, before the shell has started reading input.
3. .NET key decoding on Unix. `KeyParser.ParseFromSingleChar` (`dotnet/runtime`, `System.Console/src/System/IO/KeyParser.cs`, fetched) maps both `'\r'` and `'\n'` to `ConsoleKey.Enter`. For `'\n'` it also sets Control, with the comment "Ctrl+J is mapped to 10, which also maps to Ctrl+Enter". So `'\r'` arrives as Enter and `'\n'` arrives as Ctrl+Enter.
4. PSReadLine bindings (`PSReadLine/KeyBindings.cs`, fetched). The Windows edit-mode table binds `Enter` to `AcceptLine` and `Ctrl+Enter` to `InsertLineAbove`. The Emacs edit-mode table binds `Enter` to `AcceptLine` and has no `Ctrl+Enter` entry.
5. The reported output (`issue.md`, Actual Behavior) shows the text of all seven commands, including the deferred `claude`, joined with no separator into a single accepted line that then fails with `ParserError`. The worktree path `/workspaces/iar-migration` shows that the extension host computed paths on Linux, so the handler ran in the remote (container) extension host.
6. The extension declares no `extensionKind` in `extensions/drm-copilot/package.json` (it has `main` only). The VS Code remote-extensions guide (fetched) says workspace extensions "run on the remote machine / environment" when connected to a container, SSH, or WSL.

### 2.2 Likely mechanism (consistent with every verified fact, but not reproduced)

- When the queued bytes arrive, the Linux pty is still in its default cooked mode (ICANON, ECHO, ICRNL), because PowerShell has not yet switched the terminal to raw mode. The kernel echoes the input, which explains the report that "the terminal echoes the commands correctly". ICRNL also translates each `\r` into `\n`.
- Once PowerShell starts, PSReadLine reads the buffered input. Each separator is now `\n`, which decodes as Ctrl+Enter (fact 3). PSReadLine's default edit mode on non-Windows platforms is understood to be Emacs, although this research did not fetch a source that states the default. In the Emacs table, Ctrl+Enter has no binding (fact 4), so it does not accept the line. The command texts accumulate in one buffer.
- Pwsh startup in the container took longer than 5000 ms, or at least until after the deferred `claude` send. That send arrives after the terminal is in raw mode, so its `\r` decodes as Enter and triggers `AcceptLine` on the concatenated buffer. This produces the observed `ParserError`.
- Windows local terminals use ConPTY and have no ICRNL translation stage, so `\r` stays Enter. This matches the issue's statement that local Windows use is unaffected.

### 2.3 Consequences for the fix

- Any input that reaches a Linux pty while it is in cooked mode can have its Enter rewritten. This covers input before PSReadLine starts, and also input while a native child such as `poetry install` runs, because PowerShell restores cooked mode for native children. That part is likely; it was not reproduced.
- One combined `sendText` (option (a) below) therefore does not remove the fault. If the single trailing `\r` arrives early, it becomes `\n`, and the line is likely left at the prompt without running.
- The deferred `claude`/`codex` `sendText` has the same exposure. It can arrive during `poetry install`.
- A fix that does not depend on timing must not send setup or launch text through the terminal's input stream.

Related upstream reports, for context only: microsoft/vscode#285500 (commands sent right after terminal creation, before the shell finishes initializing, get truncated) and microsoft/vscode PR #302526, which used bracketed paste for multi-line executed text and was reverted by PR #304134.

## 3. Fix Options

| Option | Timing-independent | Windows local + Linux remote | Notes |
|---|---|---|---|
| (a) One combined `sendText` (statements joined by `; ` or newline) | No | Partially | Removes the join between commands, but the single trailing Enter is still exposed to cooked-mode translation (2.2). The deferred agent send is still needed or must be merged in. |
| (b) `terminal.shellIntegration.executeCommand(script)` after `window.onDidChangeTerminalShellIntegration` | Only when shell integration activates | Partially | The `vscode.d.ts` docs (fetched) say `shellIntegration` "will always be `undefined` immediately after the terminal is created" and "may remain undefined if shell integration never activates". A fallback (timeout plus `sendText`) puts the timing dependence back. `executeCommand` also "sends ^C as necessary". |
| (c) Write a temporary `.ps1` and invoke it | Only when invoked through shell args | Yes | Adds file I/O on the remote host, plus a cleanup lifecycle and a location policy. If it is invoked through `sendText`, it has the same timing exposure as (a). |
| (d) Pass the combined script at process start: `shellArgs: ["-NoLogo", "-NoExit", "-EncodedCommand", <base64 UTF-16LE>]` | Yes | Yes | No input-stream delivery at all. `about_pwsh` (fetched) documents `-EncodedCommand` ("The Base64 representation must be a UTF-16LE encoded string") and `-NoExit` ("Doesn't exit after running startup commands"). Windows PowerShell 5.1 has the same switches per `about_PowerShell_exe` (not fetched here; the planner should confirm). |

### 3.1 Recommendation: option (d), with the agent launch moved into the script and the Python auto-activation opt-out

1. Compose one PowerShell script per session from the existing command records, in the existing order:
   - Claude: `ensureParentDirectory`, `git`, `setLocation`, `poetryInstall?`, `activate?`, `preClaude?`, then the `claude` launch.
   - Codex: `ensureParentDirectory`, `git`, `setLocation`, `trustCodexProject`, `poetryInstall?`, `activate?`, `postCodex?`, then the `codex` launch.
   Every conditional step keeps its current presence rule (emitted or omitted exactly as today).
2. Encode the script as base64 of UTF-16LE (`Buffer.from(script, "utf16le").toString("base64")`; `Buffer` is a Node global, so the module stays free of `vscode`, `fs`, and `child_process`). Pass it as `shellArgs: ["-NoLogo", "-NoExit", "-EncodedCommand", encoded]`. Base64 contains no spaces or quotes, so node-pty argument quoting on Windows cannot alter it. `-NoExit` keeps today's end state: an interactive prompt in the worktree after the agent exits or after a setup failure.
3. Create the terminal with `hideFromUser: true`, then call `terminal.show()` as today.
   - Verified: `TerminalOptions.hideFromUser` "will run the process as normal but not be surfaced to the user until `Terminal.show` is called" (`vscode.d.ts`).
   - Verified: the Python extension's auto-activation returns early for `hideFromUser` terminals (`src/client/terminals/activation.ts` in microsoft/vscode-python: `if ('hideFromUser' in terminal.creationOptions && terminal.creationOptions.hideFromUser) {`).
   - Verified: the Python Environments extension skips them as well (`shouldSkipTerminalActivation` in `src/features/terminal/utils.ts`, microsoft/vscode-python-environments).
   With the injection removed at its source, `TERMINAL_AUTO_ACTIVATION_GRACE_MS` and both `setTimeout` calls can be deleted, and the agent launch can run as the last statement of the script.
4. Fail-fast structure that works on both pwsh 7 and Windows PowerShell 5.1:
   - Do not use `&&`/`||`, which are PowerShell 7 only.
   - Do not use `$IsWindows`, which is undefined in 5.1.
   - Wrap setup in `try { ... } catch { Write-Host "<session> setup failed: $_" -ForegroundColor Red }` inside a `& { ... }` block, so helper variables do not leak into the interactive global scope.
   - After each native step (`git ... worktree add`, `poetry install --with dev`), append `if ($LASTEXITCODE -ne 0) { throw '<step> failed with exit code ' + $LASTEXITCODE }`.
   - Make the cmdlet steps terminating by adding `-ErrorAction Stop` to `New-Item` (in `ensureParentDirectory`) and `Set-Location` (in `setLocation`). A per-cmdlet switch is preferred to setting `$ErrorActionPreference = 'Stop'` for the whole block, because the preference would be inherited by repository-owned pre/post scripts and would change their non-terminating-error behavior.
   - Launch the agent only after the `try` block completes without a caught error (for example, set a flag at the end of `try` and check it).
   - `Set-Location` and the environment and global-function changes made by `Activate.ps1` persist outside the `& { }` block. Location is per-runspace, and `Activate.ps1` defines `global:` functions and `$env:` variables, so the post-session prompt still lands in the activated worktree.
   - Behavior change for the planner to confirm. Today each line runs regardless of earlier failures. For example, a failed `git worktree add` is followed by `Set-Location` failing, then `poetry install` and `claude` running in the source repository. The recommended script stops before the agent launch on any failed step, including a terminating error thrown by the pre-claude or post-codex script or by the Codex trust command (which already uses `throw`). Non-terminating errors written by repository-owned pre/post scripts do not stop the launch, which preserves their current semantics.
5. Length guard. Windows `CreateProcess` limits a command line to 32,767 characters, and base64 of UTF-16LE is about 2.67 characters per source character. The objective is user-supplied text embedded in the script. The launch module should throw a clear `Error` before `createTerminal` when the encoded argument would exceed a fixed bound, which the planner should set (for example 30,000 characters). This keeps the failure explicit. Rejected sub-alternative: passing the objective through `TerminalOptions.env` removes the bound but adds a second transport for one value.
6. Observability. `-EncodedCommand` does not echo the commands. Add `Write-Host` step banners (for example `==> git worktree add ...`) so the user can see each step, as the per-line echo allowed before.
7. Likely side effect (not verified). VS Code's automatic pwsh shell-integration injection probably does not apply when `shellArgs` carry `-EncodedCommand`, so command decorations may be absent in these terminals. The handlers do not depend on shell integration.

Rejected alternatives: (a) is still exposed to the cooked-mode Enter translation on Linux. (b) depends on shell integration activating and needs a timing fallback. (c) adds remote file I/O and cleanup, and gives no benefit over (d) once delivery goes through shell args.

## 4. Platform-Correct venv Activation

- Verified: the Linux venv layout is `.venv/bin/Activate.ps1`. The repository's own `.devcontainer/post-create.sh` profile uses `$env:WORKSPACE_DIR/.venv/bin/Activate.ps1`.
- Verified: `process.platform` in the handler reflects the remote OS in a dev container (section 2.1, facts 5 and 6). `vscode.env.remoteName` is `undefined` for a local workspace (`vscode.d.ts` and the remote-extensions guide) and names the remote kind otherwise. It does not identify the OS.
- Recommendation: a runtime probe inside the generated script instead of host-side platform detection. The probe works for both pwsh 7 and Windows PowerShell 5.1, does not require `$IsWindows`, needs no new builder input, and also covers non-standard layouts (for example an MSYS-style Python on Windows that uses `bin/`). Shape:
  `$venvActivate = @('./.venv/Scripts/Activate.ps1', './.venv/bin/Activate.ps1') | Where-Object { Test-Path -LiteralPath $_ } | Select-Object -First 1; if ($null -eq $venvActivate) { throw 'No virtual environment activation script found under ./.venv' }; & $venvActivate`
  The command is a single statement list, so it remains a valid `activate` value for both builders.
- Placement: define it once in `claude-worktree-session.ts` (for example an exported constant or function `buildVenvActivateCommand`). `codex-worktree-session.ts` imports it the same way it already imports `quoteForPwsh`. This removes the duplicated literal and avoids an import cycle with the new launch module.

## 5. Existing Tests That Assert Current Behavior

Search scope: `extensions/drm-copilot/test/`, `tests/`, and `extensions/drm-copilot/src/`.

- Search 1 (primary): the patterns `Scripts/Activate\.ps1|buildWorktreeSessionCommands|buildCodexWorktreeSessionCommands|newClaudeWorktreeSession|newCodexWorktreeSession|TERMINAL_AUTO_ACTIVATION_GRACE_MS`.
- Search 2 (cross-check): `sendText`.

Both searches converge on the files below. `extension.test.ts` and `runtime-detection.ts` match only the Codex-not-found error string, which is unaffected.

`extensions/drm-copilot/test/claude-worktree-session.test.ts` (`describe("buildWorktreeSessionCommands")`):
- "emits a relative-path activate command for the worktree-local venv when usePoetry is true": update (asserts `& './.venv/Scripts/Activate.ps1'`).
- "emits an idempotent ensureParentDirectory command quoted with quoteForPwsh" and "guards the grouping directory that is the leading segment of the worktree path (no drift)": update if `-ErrorAction Stop` is added to `New-Item`.
- "emits a Set-Location command targeting the worktree path" and "quotes a repo root, worktree path, and branch that contain spaces or apostrophes": update if `-ErrorAction Stop` is added to `Set-Location`.
- All other tests in the file are unchanged.

`extensions/drm-copilot/test/codex-worktree-session.test.ts`:
- "returns poetry commands when the workspace uses poetry": update (activate literal).
- "emits ensureParentDirectory, git, Set-Location, trust, and codex commands": update if `-ErrorAction Stop` is added.
- `buildCodexTrustCommand` tests: unchanged.

`extensions/drm-copilot/test/codex-worktree-session-command.test.ts` (`describe("newCodexWorktreeSession")`):
- Rewrite these tests to assert `createTerminal` options, the decoded `-EncodedCommand` script, `hideFromUser: true`, `show` called once, and `sendText` not called:
  - "sends git, Set-Location, trust, post script, and codex in order"
  - "runs poetry setup before the post script when poetry is configured"
  - "uses the default post-codex script path when the setting is unset"
  - "invokes the post-codex script from the source root before deferred codex startup"
  - "omits the post script and objective when both are blank"
  - "uses the configured codex executable path when present"
  - "launches installed extension package codex through PowerShell call operator"
- Unchanged:
  - "registers the command"
  - "returns early when the objective prompt is cancelled"
  - "surfaces a missing powershell runtime error"
  - "fails before terminal creation when the codex cli cannot be resolved"
  - "fails before terminal creation when installed extension package codex is absent"

`extensions/drm-copilot/test/extension.workflow-commands.test.ts` (`describe("drm-copilot workflow command behavior")`):
- Rewrite these tests. "defers the claude sendText behind a grace period ..." becomes a test that asserts no `sendText` call and `hideFromUser: true`:
  - "newClaudeWorktreeSession without poetry sends git, Set-Location, and claude as separate sendText calls in order"
  - "newClaudeWorktreeSession with a poetry pyproject sends poetry install --with dev and activates before claude"
  - "newClaudeWorktreeSession ignores a pyproject that does not mention poetry"
  - "newClaudeWorktreeSession omits the objective from the claude command when blank"
  - "newClaudeWorktreeSession defers the claude sendText behind a grace period so the Python extension's auto-activation cannot collide with claude's TUI input"
  - "newClaudeWorktreeSession applies the default pre-claude script path when the setting is unset"
  - "newClaudeWorktreeSession sends preClaude immediately after activate and before the deferred claude when poetry is present"
  - "newClaudeWorktreeSession sends preClaude after Set-Location and before the deferred claude when poetry is absent"
  - "newClaudeWorktreeSession sends no extra command when the configured pre-claude path is empty"
- Unchanged: "registers newClaudeWorktreeSession", "newClaudeWorktreeSession returns early when the objective prompt is cancelled", and "newClaudeWorktreeSession surfaces a missing powershell runtime error".
- Required move: this file has 800 logical lines (section 6), so it cannot grow. Move all `newClaudeWorktreeSession` tests into a new `extensions/drm-copilot/test/claude-worktree-session-command.test.ts`, mirroring the Codex command test file.

`extensions/drm-copilot/test/extension-test-harness.ts`: no change is expected. `createTerminalMock` already records its options argument, and the mock terminal exposes `show` and `sendText`. The `vscode` mock has no `env` member, and the recommended runtime probe does not need one.

`tests/scripts/dev-tools/new-claude-worktree-session.Tests.ps1`: unaffected. It tests `scripts/dev-tools/new-claude-worktree-session.ps1`, which the handlers do not call.

Documentation that describes the commands:
- `extensions/drm-copilot/README.md` `## New Claude Worktree Session`. Its "How it works" bullets and the note "no additional command is sent" describe per-command sends: update.
- Root `README.md` (the `newClaudeWorktreeSession` and `newCodexWorktreeSession` bullets): the statements remain accurate. No update is required.
- `extensions/drm-copilot/package.json` setting descriptions ("runs immediately before 'claude'"): remain accurate. No update is required.

No numeric `spec.md` acceptance criterion is proposed in this research. The test names above form an inventory for task scoping, not a count for an acceptance criterion.

## 6. Coverage and File Size

Logical line counts were taken from the Read tool's last numbered non-empty line. The orchestrator should confirm them with `@(Get-Content -LiteralPath <path>).Count`.

| File | Logical lines | Tier position | In `config/file-size-baseline.json` |
|---|---|---|---|
| `extensions/drm-copilot/src/extension.ts` | 496 | 4 below the 500 guidance tier | No |
| `extensions/drm-copilot/src/claude-worktree-session.ts` | 248 | below 500 | No |
| `extensions/drm-copilot/src/codex-worktree-session.ts` | 120 | below 500 | No |
| `extensions/drm-copilot/test/claude-worktree-session.test.ts` | 427 | below 500 | No |
| `extensions/drm-copilot/test/codex-worktree-session.test.ts` | 137 | below 500 | No |
| `extensions/drm-copilot/test/codex-worktree-session-command.test.ts` | 389 | below 500 | No |
| `extensions/drm-copilot/test/extension.workflow-commands.test.ts` | 800 | exactly at the hard limit (passes; 801 is blocked) | No |
| `extensions/drm-copilot/test/extension-test-harness.ts` | 495 | below 500 | No |

The baseline file contains no `extensions/drm-copilot` entry at all.

`coverageThreshold` in `extensions/drm-copilot/jest.config.cjs` has per-file entries only and no `global` key. It currently has no entry for `extension.ts`, `claude-worktree-session.ts`, or `codex-worktree-session.ts`.

Recommendations:
- Put the script composition, encoding, shell-argument construction, and length guard in a new pure module, `extensions/drm-copilot/src/worktree-session-launch.ts`, with its own test file `extensions/drm-copilot/test/worktree-session-launch.test.ts` and a new `coverageThreshold` entry `"./src/worktree-session-launch.ts": { lines: 85, branches: 75 }`. With this placement, `extension.ts` shrinks: each handler's `sendText`/`setTimeout` block is replaced by one `createTerminal` call that uses the module's output.
- Add threshold entries for the two changed builder modules (`./src/claude-worktree-session.ts`, `./src/codex-worktree-session.ts`), following the map's convention of gating changed files. Both are pure and fully exercised by their unit tests.
- For `extension.ts`, which has no entry today: the planner should record its baseline per-file figures from `coverage/lcov.info` before deciding whether to add an entry. Changed lines must not lose coverage in either case.

## 7. Other Consumers and Mirrors

- No bundled copy of the TypeScript sources exists. `extensions/drm-copilot/resources/templates/new-claude-worktree-session.ps1` mirrors `scripts/dev-tools/new-claude-worktree-session.ps1`, but no file under `extensions/drm-copilot/src/` references it. It is out of scope.
- `extensions/drm-copilot/package.json` contributes both commands (`drmCopilotExtension.newClaudeWorktreeSession`, `drmCopilotExtension.newCodexWorktreeSession`) and three settings. Command IDs and settings do not change.
- `extensions/drm-copilot/CHANGELOG.md` follows Keep a Changelog with an `## [Unreleased]` section that has `### Changed` and `### Fixed`. Add a `### Fixed` bullet for issue #1003. The version in `package.json` (`1.1.23`) is managed by the release automation and should not be bumped in this change.
- `scripts/dev-tools/activate.ps1` (`'.venv\Scripts\Activate.ps1'`) and `scripts/dev-tools/DrmCopilotPromptSupport.ps1` (`"Scripts\Activate.ps1"`) also hard-code the Windows layout. They are repository dev tooling, not the extension command path, and are outside this issue's scope. They are recorded here so they are not mistaken for consumers.
- Pre-existing gap, out of scope: `extensions/drm-copilot/README.md` `## VS Code Commands` does not list `drmCopilotExtension.newCodexWorktreeSession`.

## 8. Candidate File Inventory

Production:
- `extensions/drm-copilot/src/worktree-session-launch.ts` (new): script composition, UTF-16LE base64 encoding, shell-argument construction, and length guard.
- `extensions/drm-copilot/src/claude-worktree-session.ts`: venv activation probe, optional `-ErrorAction Stop` on `New-Item`/`Set-Location`, and interface doc comments that no longer prescribe separate `sendText` calls.
- `extensions/drm-copilot/src/codex-worktree-session.ts`: import the shared activation command, optional `-ErrorAction Stop`, and doc comments.
- `extensions/drm-copilot/src/extension.ts`: both handlers use `createTerminal({ ..., hideFromUser: true, shellArgs })`. Remove the `sendText` calls, `setTimeout`, and `TERMINAL_AUTO_ACTIVATION_GRACE_MS`, and update the output-channel log text.

Tests:
- `extensions/drm-copilot/test/worktree-session-launch.test.ts` (new).
- `extensions/drm-copilot/test/claude-worktree-session-command.test.ts` (new; receives the moved and rewritten Claude handler tests).
- `extensions/drm-copilot/test/extension.workflow-commands.test.ts`: remove the moved `newClaudeWorktreeSession` tests.
- `extensions/drm-copilot/test/claude-worktree-session.test.ts`
- `extensions/drm-copilot/test/codex-worktree-session.test.ts`
- `extensions/drm-copilot/test/codex-worktree-session-command.test.ts`

Config:
- `extensions/drm-copilot/jest.config.cjs`: threshold entries for `./src/worktree-session-launch.ts`, `./src/claude-worktree-session.ts`, `./src/codex-worktree-session.ts`, and conditionally `./src/extension.ts` (section 6).

Docs:
- `extensions/drm-copilot/README.md`
- `extensions/drm-copilot/CHANGELOG.md`

The fix does not need to edit any `.claude/rules/` file, `quality-tiers.yml` (the file is absent at the repository root), any `.github/instructions/` file, or the execution-environment brief. No CI job, required check, tool route, or batch-budget rule changes.

## 9. Test Strategy (no test code)

- Unit tests (`worktree-session-launch.test.ts`):
  - Step ordering for each conditional combination (poetry on/off, pre/post script present/absent, objective blank/present).
  - A `$LASTEXITCODE` guard after each native step.
  - The launch statement appears only after the guarded `try` block.
  - Round trip: decode the base64 with `Buffer.from(arg, "base64").toString("utf16le")` and compare it with the composed script.
  - `shellArgs` order `-NoLogo`, `-NoExit`, `-EncodedCommand`.
  - The length guard throws at the bound + 1 and passes at the bound.
  - Quotes and apostrophes in paths and the objective survive encoding.
- Builder tests: the activation probe text (both candidate paths, the throw message, and the `&` invocation) for both builders.
- Handler tests (both command test files):
  - `createTerminal` is called once with `hideFromUser: true`, `cwd`, `shellPath`, and the expected `shellArgs`.
  - `show` is called once and `sendText` is never called.
  - The decoded script contains the expected steps in order.
  - No timers are needed, so the `jest.useFakeTimers` blocks go away. This also removes a determinism dependency.
  - A length-guard failure throws before `createTerminal`.
  - The cancelled-prompt and missing-runtime paths are unchanged.
- Regression (fail-before): the new handler test asserting `sendText` is not called and `hideFromUser: true`, and the builder test asserting the probe, both fail on the current tree.
- Platform neutrality: assertions must not depend on `process.platform` beyond the existing `expectedPathResolvedCodexExecutable` helper, because `drm-copilot Extension Tests` runs on `ubuntu-latest` and `windows-latest`.

## Pre-Mortem

- Review checklists: A reviewer may flag the behavior changes (removed grace period, fail-fast stop before the agent launch, `hideFromUser`) as out of scope. The plan must state each one as a required consequence of the root cause (sections 2.3 and 3.1), with a test per behavior, and record the fail-fast change in the CHANGELOG and README.
- Coverage: the new `worktree-session-launch.ts` would be ungated without its own `coverageThreshold` entry, because the map has no `global` key. The plan must add entries for the new module and both changed builders, and capture baseline and post-change per-file figures for `extension.ts` from `coverage/lcov.info`.
- Mirror parity: not applicable. No `.claude`, `.github`, `.agents`, `.codex`, or `extensions/drm-copilot/resources/` file changes, and no fact in the execution-environment brief changes.
- File size: `extensions/drm-copilot/test/extension.workflow-commands.test.ts` is at exactly 800 logical lines, so any net growth fails `FileSizePolicy.RepoGate.Tests.ps1` and the PreToolUse hook. `extension.ts` is at 496. The plan must move the Claude handler tests into the new `claude-worktree-session-command.test.ts` and put the new logic in `worktree-session-launch.ts`, so that `extension.ts` shrinks.
- Test isolation: handler tests share module-level mocks in `extension-test-harness.ts`, and removing `jest.useFakeTimers` changes timer state between tests. The plan must keep `resetExtensionHarnessState` in each `beforeEach`, create no temporary files (all base64 decoding happens in memory), and record a seeded shuffled Jest run under `evidence/regression-testing/`.
- CI-only behavior: the existing harness fixtures use `C:/workspace`, which already passes on `ubuntu-latest`. The new assertions must not add `path.isAbsolute` or platform-specific path joins, and must not branch on `process.platform` except through the existing Codex executable helper. Base64 decoding must use `utf16le` explicitly.
- Evidence: manual dev-container verification is not available to an autonomous run. The plan must cite unit-test proof (decoded script content, no `sendText`, `hideFromUser`) as the acceptance evidence for "documented environments", and must record the fail-before run under `evidence/regression-testing/` with `Timestamp`, `Command`, `EXIT_CODE`, and `Output Summary`.

## Automation Feasibility

No step requires human interaction.

- Unit tests replace manual dev-container verification. They prove the property that caused the fault: no terminal input-stream delivery (`sendText` never called), together with the exact script content delivered through `-EncodedCommand`.
- Platform-correct activation is proven by asserting the runtime probe text.
- An optional live check in a Linux dev container and on a Windows host would add confidence but is not required for any acceptance criterion. If the user wants one, it is a post-merge manual check, not a plan task.
- All toolchain stages (Prettier, ESLint, tsc, Jest with coverage through `node run-jest.cjs`) run in CI on `ubuntu-latest` and `windows-latest` without interaction.
