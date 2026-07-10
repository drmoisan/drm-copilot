# Research Findings — PoshQC Test Terminal Output, Scan Coverage Reconciliation, and Scan-Folder Configuration (Issue #344)

- Date: 2026-07-10
- Researcher: task-researcher agent
- Scope: `drm-copilot: Run PoshQC Test` command (`drmCopilotExtension.runPoshQCTest`), PoshQC PowerShell module, `.vscode/tasks.json` task `PoshQC: 4 test (Pester)`, MCP tool `run_poshqc_test`.
- All file paths are repository-relative unless stated otherwise. Line numbers reference the working tree at branch `drm-copilot-wt-2026-07-10T16-55` (HEAD `cf036d3f`).

---

## 1. Current State Analysis

### 1.1 Command execution pipeline (verified)

1. `extensions/drm-copilot/src/poshqc-command-registration.ts:100-103` registers `drmCopilotExtension.runPoshQCTest`. The shared handler (`registerPoshQcCommand`, lines 26-78) shows a scope QuickPick with the two string items `"Scan entire workspace"` and `"Select folders to scan"` (lines 48-52) via `promptForChoice` (`extensions/drm-copilot/src/extension-command-helpers.ts:141-153`).
2. `"Select folders to scan"` calls `promptForWorkspaceScanFolders` (`extension-command-helpers.ts:320-337`), which uses `vscode.window.showOpenDialog({ canSelectMany: true, canSelectFolders: true, ... })` — a native OS folder picker returning absolute `fsPath`s. There is no persistence and no pre-seeded selection.
3. The service call chain: `RepoAutomationService.runPoshQCTest` (`extensions/drm-copilot/src/repo-automation-service.ts:376-382`) → `runPoshQcWorkflow` (lines 425-450) → `buildPoshQcWorkflowArguments` (`extensions/drm-copilot/src/repo-automation-args.ts:20-55`; for `run_poshqc_test` scan folders are serialized as a single `-ScanFoldersJson <json>` argument, lines 28-34) → `executeScript` → `executeScriptServiceCall` (`extensions/drm-copilot/src/repo-automation-execute-script.ts:43-71`) → `executeBundledScriptFromExtensionRoot` (`extensions/drm-copilot/src/command-runtime.ts:277-327`).
4. `runCommandWithOutput` (`command-runtime.ts:206-267`) spawns `pwsh -NoLogo -NoProfile -ExecutionPolicy Bypass -File <script> ...` (`extensions/drm-copilot/src/runtime-detection.ts:182-206`) with `stdio: ["ignore", "pipe", "pipe"]`, `shell: false`, `cwd = workspaceRoot`. Both stdout and stderr chunks are trimmed and appended line-by-line to the injected `CommandOutput` sink — in command mode this is the `"drm-copilot"` `OutputChannel` created at `command-runtime.ts:92-94`. Non-zero exit rejects with `CommandExecutionError` (lines 60-85, 255-264) carrying `exitCode`, full `stdout`, and full `stderr`; `getStderrExcerpt` (lines 355-368) extracts up to 8 stderr lines for user-facing failure messages (consumed by `mcp-tools.ts:106`).
5. The executed script is the **bundled** wrapper `extensions/drm-copilot/resources/templates/run-poshqc-test.ps1` (resolved relative to the *installed extension root*, `command-runtime.ts:294-300`). The wrapper (lines 22-32) imports the **bundled** module `resources/powershell/PoshQC/PoshQC.psd1`, decodes `-ScanFoldersJson`, and calls `Invoke-PoshQCTest -Root $WorkspaceRoot -ScanFolders $resolvedScanFolders ...`.

### 1.2 PowerShell scan-folder mechanics (verified)

- `Invoke-PoshQCTest` (`scripts/powershell/PoshQC/PoshQC.Testing.psm1:151-409`):
  - Loads settings from `$script:PesterSettings` (module-relative `settings/pester.runsettings.psd1`, set in `PoshQC.psm1:3`).
  - `ExpandRunPaths` (lines 168-187) joins `Run.Path` entries with `$Root` and appends root-joined `ExcludeDirs` to `Run.ExcludePath`.
  - When `-ScanFolders` is non-empty, `Resolve-PoshQCScanFolder` output **replaces** `Run.Path` entirely (lines 279-284).
  - `EnumerateTests` (lines 235-249) pre-checks for `*.Tests.ps1` under the run paths only to decide the "No Pester test files found" early return (lines 340-344); actual discovery is done by `Invoke-Pester -Configuration $config`.
- `Resolve-PoshQCScanFolder` (`scripts/powershell/PoshQC/PoshQC.FileDiscovery.psm1:86-138`): rejects blank values (throw, lines 114-116), resolves relative folders against root, resolves via `Resolve-Path -ErrorAction Stop` (line 95 — **a nonexistent folder throws**), and requires the resolved folder to be inside root (lines 130-132).
- Default excluded dir names: `PoshQC.psm1:5-9` (`.git`, `node_modules`, `dist`, `artifacts`, …).
- `Run.Path` defaults (both settings copies, line 3): `@('scripts', 'tests/powershell', 'tests/scripts')`. All 70 `*.Tests.ps1` files in the repo currently live under `tests/scripts/**`; `tests/powershell` does not exist in this worktree (empty directories are not tracked by git).

### 1.3 Local task (verified)

`.vscode/tasks.json:596-620` — task `PoshQC: 4 test (Pester)` runs:

```
pwsh -NoLogo -NoProfile -ExecutionPolicy Bypass -Command
"& { Import-Module '${workspaceFolder}/scripts/powershell/PoshQC'; Invoke-PoshQCTest -Root '${workspaceFolder}' }"
```

i.e. the **workspace** module and therefore the **workspace** `settings/pester.runsettings.psd1`, with no `-ScanFolders`.

### 1.4 Dual-copy parity status (verified — this is the core structural finding)

The PoshQC module exists twice: `scripts/powershell/PoshQC/` (workspace, used by the task) and `extensions/drm-copilot/resources/powershell/PoshQC/` (bundled, used by the command and MCP). Parity is CI-enforced by `tests/scripts/dev_tools/test_poshqc_bundled_parity.py`, but its file list (lines 9-14) covers **only the four `.psm1` files**. It does **not** cover `PoshQC.psd1` or `settings/*.psd1` — and both have demonstrably drifted:

| File pair | Verified difference |
|---|---|
| `PoshQC.psd1` | Bundled copy (lines 11-14) declares `RequiredModules = @(PSScriptAnalyzer 1.22.0, Pester 5.6.1)`. Workspace copy has **no** `RequiredModules`, and the Pester test `tests/scripts/powershell/PoshQC/PoshQC.EntryPoints.Tests.ps1:32-38` asserts it stays empty ("RequiredModules prevents module import when tools are missing, which blocks the installer entry point"). The bundled manifest therefore violates the workspace's own bootstrap contract: on a host without Pester installed, the bundled import fails at `Import-Module` instead of reaching the friendly `Install-PoshQCTool` guidance. |
| `settings/pester.runsettings.psd1` | Workspace copy (lines 23-80) lists coverage `Path` entries added by issues #298, #301, #305, #312, #328 that the bundled copy (lines 23-51) lacks. The bundled copy additionally contains a `CodeCoverage.ExcludedPath` block (lines 52-68) that the workspace copy does not have — and `ExcludedPath` **is not a documented Pester `CodeCoverage` option** (documented options: `Enabled`, `OutputFormat`, `OutputPath`, `OutputEncoding`, `Path`, `ExcludeTests`, `RecursePaths`, `CoveragePercentTarget`, `UseBreakpoints`, `SingleHitBreakpoints`; verified against pester.dev configuration docs 2026-07-10). Whether `New-PesterConfiguration -Hashtable` throws on or ignores this unknown key must be verified empirically during implementation; either outcome is a defect in the bundled file. |
| `settings/pssa.settings.psd1` | Not diffed in this research; the planner should include it in the parity resync and verification. |

### 1.5 MCP surface (verified)

- Tool `run_poshqc_test` is declared in both `extensions/drm-copilot/src/mcp-tool-definitions.ts:277-296` and `extensions/drm-copilot/src/mcp-repo-automation-tool-definitions.ts:295-315` (duplicated schema, `scan_folders` optional string array), dispatched in `extensions/drm-copilot/src/mcp-tools.ts:206-208`, and executes the same service path with a buffered in-memory sink (`mcp-server.ts:105`, `createBufferedOutput` at `command-runtime.ts:101-114`). There is no terminal in the MCP path.

### 1.6 Existing precedents relevant to the design (verified)

- Terminal seam: `extensions/drm-copilot/src/terminal-writer.ts` defines an injectable `TerminalWriter` interface (lines 14-26) with a `vscode.Pseudoterminal`-backed implementation (lines 42-90) used by the Subagent Tree command; the Jest harness already mocks `vscode.window.createTerminal` (`extensions/drm-copilot/test/extension-test-harness.ts:40,104`).
- Configuration precedent: `extensions/drm-copilot/package.json` `contributes.configuration` (lines 43-62) already carries three `drmCopilotExtension.*` settings; repo-local JSON config precedent exists at `config/orchestration-routing.json`.
- Injectable `FileSystem` seam (`extensions/drm-copilot/src/lib/file-system.ts:25+`) provides `glob`, `exists`, `isDirectory`, directory listing, `readFile`, `writeFile`, `mkdir` — with an in-memory fake used by existing hermetic tests.
- Test harness: extension unit tests live in `extensions/drm-copilot/test/*.test.ts` and run under **Jest** (`package.json:182`, `run-jest.cjs`), including `extension.run-poshqc-commands.test.ts` which already covers the scan-folder argument contract. Note: repo TypeScript rules name Vitest; the extension package's established harness is Jest. Follow the package harness; do not introduce a second framework in this feature.
- File-size headroom (500-line limit): `extension.ts` = 483 lines, `repo-automation-service.ts` = 487 lines — **both are near the limit; avoid adding lines to them**. `extension-command-helpers.ts` = 363, `command-runtime.ts` = 369, `PoshQC.Testing.psm1` = 410 (moderate headroom), `poshqc-command-registration.ts` = 111, `terminal-writer.ts` = 101, `run-poshqc-test.ps1` = 33.

---

## 2. Capability 1 — Redirect `Run PoshQC Test` output to the integrated terminal

### 2.1 Mechanism today

Output reaches the user only through the `OutputChannel` sink wired at service construction (`extension.ts:437-440` passes the shared `output` into `registerPoshQcCommands`; `DefaultRepoAutomationService` stores it, `repo-automation-service.ts:198-214`; `executeScript` → `runCommandWithOutput` streams into it, `command-runtime.ts:221-237`). Failure semantics: non-zero exit → `CommandExecutionError` with `exitCode/stdout/stderr` → `getStderrExcerpt` for messages.

### 2.2 Options analyzed

**Option A — `vscode.window.createTerminal()` + `sendText(commandLine)`**
The child runs inside the user's shell; VS Code gives no completion event or exit code for a `sendText` command. `Terminal.exitStatus` reports only terminal (shell) exit, not per-command exit. The modern shell-integration API (`terminal.shellIntegration.executeCommand` + `vscode.window.onDidEndTerminalShellExecution`, VS Code >= 1.93) restores an exit code, but only when shell integration is active (not guaranteed; requires fallback), and stdout/stderr are not captured, so `CommandExecutionError.stdout/stderr` and `getStderrExcerpt` are unimplementable. Also introduces command-line quoting/escaping risk on Windows (`-ScanFoldersJson` carries embedded quotes). **Rejected**: breaks the failure-reporting contract.

**Option B — one-off `vscode.Task` with `ProcessExecution`**
`vscode.tasks.executeTask(new vscode.Task({type:"drmCopilot"}, folder, name, source, new vscode.ProcessExecution(executable, args, { cwd })))`; completion and exit code via `vscode.tasks.onDidEndTaskProcess` (`TaskProcessEndEvent.exitCode`). Pros: presentation is identical to the local task (terminal panel, task lifecycle UI); no shell quoting (argv-style); exit code preserved, so a synthetic `CommandExecutionError` can be raised. Cons: output goes to the task terminal and is **not capturable**, so `stdout`/`stderr` on the error are empty and `getStderrExcerpt` degrades to nothing; artifact parsing from stdout is impossible (not currently used by the PoshQC tools, but the seam exists); ad-hoc task definitions without a `contributes.taskDefinitions` entry work but are a gray area; the Jest harness has no `vscode.tasks` mocks (new harness surface). **Viable fallback**, not recommended.

**Option C — keep the existing spawn pipeline; tee the stream into a Pseudoterminal-backed terminal (recommended)**
Keep `runCommandWithOutput` exactly as-is (spawn, piped stdio, `CommandExecutionError`). Introduce a streaming variant of the existing `TerminalWriter` pattern (`terminal-writer.ts:42-90` is replace-mode; the new writer appends lines, converting `\n` → `\r\n`) plus a tee `CommandOutput` that forwards each `appendLine` to both the `OutputChannel` and the terminal writer, and reveals the terminal at command start.

- Exit-code and failure semantics: **unchanged** — the child is still spawned with piped stdio; `CommandExecutionError`, `exitCode`, full `stdout`/`stderr`, and `getStderrExcerpt` all keep working.
- "In addition to the OutputChannel" (permitted by the issue) falls out naturally from the tee.
- MCP path untouched (it constructs its own buffered sink).
- Testable with the existing harness: `createTerminalMock` already exists; the tee is a pure object testable without VS Code.
- Known limitations to record in the plan: the pseudoterminal is display-only (no Ctrl+C forwarding unless `pty.handleInput` is wired to `child.kill()` — optional enhancement); Pester/PowerShell suppress ANSI color when stdio is piped (optionally settable in the wrapper via `$PSStyle.OutputRendering = 'Ansi'`; cosmetic, defer).

### 2.3 Recommended wiring (avoids the two near-limit files)

The service's sink is fixed at construction, and `repo-automation-service.ts` (487 lines) should not grow. Two containment strategies:

1. **Per-command service instance (recommended):** `registerPoshQcCommands` options gain an optional `createService(output: CommandOutput) => RepoAutomationService` factory (default supplied from `extension.ts` in ~3 lines using the existing `createRepoAutomationService`). The registration module builds the tee sink per invocation of the test command and calls the factory. Service code unchanged.
2. Per-call output override threaded through `runPoshQCTest` input → `executeScript` — rejected: touches the 487-line service file and widens the `ScriptExecutionOptions` contract for one caller.

Scope decision for the planner: apply the terminal tee to `runPoshQCTest` only (AC1) or to all four PoshQC commands (consistency). The registration module is shared, so the marginal cost of all-four is near zero; recommend all four PoshQC commands share the terminal, with a stable terminal name (e.g. `"drm-copilot: PoshQC"`), mirroring the reuse policy of `PseudoterminalTerminalWriter`.

### 2.4 Files to change (Capability 1)

| File | Change | Est. size |
|---|---|---|
| `extensions/drm-copilot/src/poshqc-terminal-output.ts` (new) | Streaming (append-mode) pseudoterminal writer + `createTeeOutput(a, b): CommandOutput` | ~100-130 lines |
| `extensions/drm-copilot/src/poshqc-command-registration.ts` | Accept service factory / terminal-writer seam; build tee per invocation; reveal terminal | +25-35 lines (111 → ~145) |
| `extensions/drm-copilot/src/extension.ts` | Pass factory into `registerPoshQcCommands` | +3-6 lines (483 → ~488; **watch the 500 cap — keep the delta minimal or move the whole `registerPoshQcCommands` option block into the registration module**) |
| `extensions/drm-copilot/test/poshqc-terminal-output.test.ts` (new) | Writer + tee unit tests | ~120-160 lines |
| `extensions/drm-copilot/test/extension.run-poshqc-commands.test.ts` | Assert terminal creation/reveal and that OutputChannel still receives lines | +40-60 lines |

---

## 3. Capability 2 — Why the command's "Scan entire workspace" differs from the local task

### 3.1 Root cause (mechanism, grounded)

The two invocations execute the **same parity-locked module logic** but consume **different, independently maintained configuration snapshots**:

- Task: workspace module + workspace `settings/pester.runsettings.psd1` (live, updated per-issue).
- Command: bundled module + bundled `settings/pester.runsettings.psd1` + bundled `PoshQC.psd1`, resolved from the **installed extension root** (`command-runtime.ts:294-300`), i.e. frozen at the packaging time of the installed extension version (currently 1.0.13).

The parity gate (`tests/scripts/dev_tools/test_poshqc_bundled_parity.py:9-14`) locks only the four `.psm1` files. `PoshQC.psd1` and `settings/*.psd1` are unguarded and have drifted (section 1.4). Test discovery is a pure function of `Run.Path` + `Run.ExcludePath` + module exclusion logic + the filesystem; therefore any discovered-set divergence must originate from the unguarded settings/manifest pair (in-repo drift and/or installed-snapshot lag), because the `.psm1` logic cannot diverge while the parity test passes.

**Precise status at HEAD:** the `Run.Path` line is textually identical in both settings copies (`@('scripts','tests/powershell','tests/scripts')`, line 3 in each), so at this exact commit the *discovered test set* should be equal **provided** `New-PesterConfiguration -Hashtable` tolerates the bundled file's undocumented `CodeCoverage.ExcludedPath` key (section 1.4). Three verified failure/divergence vectors remain live regardless:

1. Installed-extension lag: the command runs the snapshot packaged into whatever extension version is installed, not the working tree. Any historical `Run.Path`/module difference in that snapshot fully explains an observed smaller discovered set.
2. `CodeCoverage.ExcludedPath` (bundled only): unknown Pester key — either a construction-time error or a silently ignored block; empirical check required.
3. `RequiredModules` in the bundled psd1: changes import failure behavior on hosts without Pester/PSSA preinstalled.

**Required baseline evidence before implementation:** run both invocations against the same worktree and diff the produced JUnit files (`artifacts/pester/pester-junit.xml`) / replayed count summaries; record the exact delta in `docs/features/active/2026-07-10-poshqc-test-terminal-output-scan-config-344/evidence/baseline/`. This converts the residual uncertainty above into a measured fact.

### 3.2 Design options

**Option A — extend the parity gate + resync (recommended, minimum reconciliation):** add `PoshQC.psd1`, `settings/pester.runsettings.psd1`, and `settings/pssa.settings.psd1` to `POSHQC_PARITY_PATHS`, and resync the bundled copies from the workspace copies (workspace copies are authoritative: the `RequiredModules`-empty contract is test-asserted, and the workspace coverage list is the maintained one; the bogus `ExcludedPath` block disappears in the resync). Deterministic, small, closes the drift class permanently in-repo. Residual limitation: the *installed* extension converges only at the next release — state this in the plan.

**Option B — workspace-first module resolution in the bundled wrappers:** `run-poshqc-*.ps1` import `<WorkspaceRoot>/scripts/powershell/PoshQC/PoshQC.psd1` when present, falling back to the bundled copy. Guarantees task parity even across extension-release lag for repos that vend PoshQC (this repo), while consumer repos keep bundled behavior. Trade-offs: the command's behavior becomes workspace-state-dependent (arguably the point of AC2); five wrapper templates to touch; small behavioral risk for consumer repos is nil (fallback). Reasonable **complement** to A, not a substitute — without A the two in-repo copies still drift for consumers.

**Option C — config-driven scan set (Capability 3) makes `Run.Path` defaults moot for the command:** once the persisted scan config exists and is consumed inside `Invoke-PoshQCTest` (section 4), both the task and the command resolve folders from the same workspace file, eliminating the settings-`Run.Path` dependency for this repo. This reconciles behavior but does not fix the psd1/`ExcludedPath` defects — A is still needed.

**Recommendation:** A + C (B optional, planner's call). A is a self-contained early phase; C lands with Capability 3.

### 3.3 Files to change (Capability 2, Option A)

| File | Change | Est. size |
|---|---|---|
| `tests/scripts/dev_tools/test_poshqc_bundled_parity.py` | Add 3 settings/manifest paths (path-mapping already handles the prefix rewrite) | +3-8 lines |
| `extensions/drm-copilot/resources/powershell/PoshQC/PoshQC.psd1` | Content resync from workspace copy (drop `RequiredModules`) | full-file copy (~25 lines) |
| `extensions/drm-copilot/resources/powershell/PoshQC/settings/pester.runsettings.psd1` | Content resync from workspace copy (drop `ExcludedPath`, adopt current coverage list) | full-file copy (~85 lines) |
| `extensions/drm-copilot/resources/powershell/PoshQC/settings/pssa.settings.psd1` | Verify/resync | verify first |

No 500-line risks. Note: the bundled psd1 resync must be validated against `PoshQC.EntryPoints.Tests.ps1`-style expectations (a bundled-manifest twin assertion could be added to the parity test instead of a new Pester file).

---

## 4. Capability 3 — Persisted local scan-folder configuration

### 4.1 Placement decision: VS Code settings vs repo-local JSON

**Option A — `contributes.configuration` key (e.g. `drmCopilotExtension.poshqc.testScanFolders`), persisted to `.vscode/settings.json`:**
Pros: native settings UI/validation; `workspace.getConfiguration().update(..., ConfigurationTarget.Workspace)` handles persistence; harness already mocks `getConfiguration`. Cons (decisive): the value is invisible to the two other consumers of the scan contract — the PowerShell module (would require parsing JSONC `settings.json` from PowerShell, fragile) and the standalone MCP server (runs with a buffered sink outside the extension host's configuration service). The extension would have to forward the value as arguments on every path, and the local task could never share it.

**Option B — repo-local JSON file read by the PowerShell module (recommended):**
A plain-JSON file at `config/poshqc-scan.json` (precedent: `config/orchestration-routing.json`), readable identically by the extension (via the `FileSystem` seam), the PoshQC module (`ConvertFrom-Json`), and — with zero MCP code — the MCP path, because the module itself resolves it. The local task inherits it automatically since the task imports the workspace module. This makes the config the single scan-contract source across all four surfaces.

### 4.2 Proposed schema

```json
{
  "version": 1,
  "test": {
    "scanFolders": ["scripts", "tests/scripts", "tests/powershell"]
  }
}
```

- `version` — integer, must equal `1`; forward-compat gate.
- `test.scanFolders` — array of **workspace-relative, forward-slash** folder paths. Validation rules (enforced identically in TS writer and PS reader): non-blank; no absolute paths; no `..` segments; deduplicated; sorted for stable diffs. The `test` scoping key leaves room for `format`/`analyze` sections later without a schema break.
- Absent file, or absent/empty `test.scanFolders` ⇒ current behavior (settings `Run.Path` defaults). The seeded default file should contain exactly the current effective set (`scripts`, `tests/scripts`, `tests/powershell`) so introducing the file is behavior-preserving.

### 4.3 Consumption point: module, not wrapper

Config resolution must live in the PoshQC **module** (not only in the bundled wrapper): the task calls `Invoke-PoshQCTest` directly, so a wrapper-only read would immediately re-open the task/command divergence whenever the config is present. Design:

- New `scripts/powershell/PoshQC/PoshQC.ScanConfig.psm1` exporting `Get-PoshQCScanConfigFolder -Root <root> [-ConfigRelativePath 'config/poshqc-scan.json']` with injectable `[scriptblock] $TestPathExists` / `$ReadContent` seams (same DI style as `Convert-PoshQCCoverageToRelative`, `PoshQC.Testing.psm1:50-69`). Returns the validated relative folder list or `@()` when absent/empty.
- `Invoke-PoshQCTest`: when `-ScanFolders` is **not** supplied, consult the config seam (new injectable `$ResolveScanConfig` scriptblock parameter defaulting to `Get-PoshQCScanConfigFolder`); when it yields folders, route them through the existing `Resolve-PoshQCScanFolder` path (`PoshQC.Testing.psm1:279-284`). Explicit `-ScanFolders` always wins.
- Precedence (documented contract): explicit `-ScanFolders`/`-ScanFoldersJson` > `config/poshqc-scan.json` > settings `Run.Path` defaults.
- Missing-folder policy: `Resolve-PoshQCScanFolder` throws on nonexistent folders (`FileDiscovery.psm1:95`), which would turn a stale config entry into a hard failure. Recommended behavior for **config-sourced** folders: skip each nonexistent folder with a logged warning; **fail fast with a clear error if the resulting set is empty**. Explicitly user-selected folders (QuickPick / arguments) keep the existing throw-on-missing behavior. This distinction should be implemented in the config-resolution step (filter before calling `Resolve-PoshQCScanFolder`), not by weakening `Resolve-PoshQCScanFolder`.
- `tests/powershell` in the seeded default is nonexistent today — the skip-with-warning rule makes the seed safe; alternatively seed only existing folders (`scripts`, `tests/scripts`) and note the narrowed-but-equivalent set (no tests exist outside `tests/scripts`). Planner decision; recommend seeding the full three-entry set for strict `Run.Path` equivalence.

### 4.4 MCP impact (assessed as requested)

Terminal redirect: command-only; MCP keeps the buffered sink (no change). Scan config: because resolution lives in the module, `mcp__drm-copilot__run_poshqc_test` **without** `scan_folders` becomes config-aware automatically — this is the desired consistency outcome, but it must be documented: update the `run_poshqc_test` description strings in both `mcp-tool-definitions.ts:278-296` and `mcp-repo-automation-tool-definitions.ts:295-315` (+2 lines each). Explicit `scan_folders` continues to override.

### 4.5 Files to change (Capability 3)

| File | Change | Est. size / risk |
|---|---|---|
| `config/poshqc-scan.json` (new) | Seeded default config | ~8 lines |
| `scripts/powershell/PoshQC/PoshQC.ScanConfig.psm1` (new) | Config read + validation + missing-folder filtering | ~80-110 lines |
| `scripts/powershell/PoshQC/PoshQC.psm1` | Dot-source + export new function | +2-3 lines (102 → ~105) |
| `scripts/powershell/PoshQC/PoshQC.Testing.psm1` | Config seam in `Invoke-PoshQCTest` | +12-18 lines (410 → ~428; **500-line headroom OK but shrinking — do not add unrelated logic here**) |
| `extensions/drm-copilot/resources/powershell/PoshQC/` mirrors of the three files above | Content copies | mechanical |
| `tests/scripts/dev_tools/test_poshqc_bundled_parity.py` | Add `PoshQC.ScanConfig.psm1` to the parity list | +1 line |
| `extensions/drm-copilot/src/poshqc-scan-config.ts` (new) | TS read/validate/write of the same JSON via `FileSystem` seam (shared with Capability 4) | ~100-140 lines |
| `tests/scripts/powershell/PoshQC/PoshQC.ScanConfig.Tests.ps1` (new) | Pester coverage | ~120-160 lines |
| `tests/scripts/powershell/PoshQC/PoshQC.Tests.ps1` or `PoshQC.Comprehensive.Tests.ps1` | `Invoke-PoshQCTest` precedence cases | +40-60 lines |
| `extensions/drm-copilot/test/poshqc-scan-config.test.ts` (new) | Jest coverage with in-memory `FileSystem` | ~140-180 lines |
| `extensions/drm-copilot/src/mcp-tool-definitions.ts`, `mcp-repo-automation-tool-definitions.ts` | Description-string updates | +2 lines each |

**PowerShell batch-budget flag for the planner:** this capability touches 3 production PowerShell files (`.psm1` ×3, plus mechanical bundled mirrors). That is at the per-batch cap (≤3 production files) and above the direct-mode budget (≤2) in `.claude/rules/powershell.md` — plan the PowerShell work as an explicit batch (or two) accordingly.

---

## 5. Capability 4 — Interactive folder select/deselect (multi-select QuickPick)

### 5.1 Current vs target

Current: `promptForWorkspaceScanFolders` (`extension-command-helpers.ts:320-337`) opens a native OS dialog — no checkbox semantics, no seeding, no persistence, returns absolute `fsPath`s.

Target: `vscode.window.showQuickPick(items, { canPickMany: true, title, placeHolder, ignoreFocusOut: true })` where `items: vscode.QuickPickItem[]` carry `picked: true` for folders present in the persisted config. `canPickMany` renders checkboxes natively; the resolved value is the array of selected items (or `undefined` on cancel).

### 5.2 Design

- New module `extensions/drm-copilot/src/poshqc-folder-picker.ts`:
  - **Candidate enumeration:** list workspace directories to a bounded depth (recommend depth 2 — matches "folders and subfolders" in the AC) using the `FileSystem` seam, excluding the same directory names as `PoshQC.psm1:5-9` (duplicate the list as a TS constant; note it as a mirrored constant with a comment pointing at the PS source). Always include any config-listed folder even if it would not be enumerated (e.g. depth 3 entry persisted earlier), marking missing ones with a `$(warning)` description rather than dropping them silently.
  - **Seeding:** `picked = config.test.scanFolders.includes(relPath)`.
  - **Write-back:** on accept, persist the selection via `poshqc-scan-config.ts` (stable sort, forward slashes), then return the selection for the run. Cancellation (`undefined`) ⇒ no persistence, no run (matches existing cancel semantics at `poshqc-command-registration.ts:60-62`).
  - **Empty selection accepted by the user:** do not run and do not persist an empty list silently — an empty `scanFolders` array means "full root scan" downstream (`Invoke-PoshQCTest` treats empty as no-override), which would surprise a user who just deselected everything. Show an information message and abort. (Alternative: persist empty ⇒ "config disabled, defaults apply" — must be an explicit, documented decision if chosen.)
  - **Return shape:** workspace-relative paths (config canonical form). `buildPoshQcWorkflowArguments` passes them through `-ScanFoldersJson`; `Resolve-PoshQCScanFolder` accepts relative paths (joins to root, `FileDiscovery.psm1:118`). This is cleaner than the current absolute `fsPath`s and keeps the JSON argument portable.
- `poshqc-command-registration.ts`: for the test command (recommended: all four PoshQC commands, same rationale as Capability 1), replace the `promptForWorkspaceScanFolders` call with the new picker. Keep the old helper untouched in `extension-command-helpers.ts` (363 lines; other commands and the suite command at `extension.ts:384+` still use it — migrating the suite command is optional scope).
- Scope-choice UX: keep the two-item scope QuickPick. `"Scan entire workspace"` now means "config-driven set (or defaults when config absent)" per Capability 3; `"Select folders to scan"` opens the multi-select picker. An optional third item `"Browse…"` can retain the native dialog as an escape hatch — recommend deferring.

### 5.3 Files to change (Capability 4)

| File | Change | Est. size / risk |
|---|---|---|
| `extensions/drm-copilot/src/poshqc-folder-picker.ts` (new) | Enumeration + seeded multi-select QuickPick + persistence handoff | ~140-180 lines |
| `extensions/drm-copilot/src/poshqc-command-registration.ts` | Swap picker call, thread `FileSystem`/config deps | +10-15 lines (on top of Capability 1 growth; 111 → ~160 total — safe) |
| `extensions/drm-copilot/test/poshqc-folder-picker.test.ts` (new) | Seeding, write-back round-trip, empty selection, cancel, missing-folder marking | ~180-220 lines |
| `extensions/drm-copilot/test/extension.run-poshqc-commands.test.ts` | Update interactive-mode cases from `showOpenDialogMock` to `showQuickPickMock` multi-select returns | ~30-50 changed lines |

No 500-line risks. The harness's `showQuickPickMock` (`extension-test-harness.ts:25,100,243-247`) already supports arbitrary resolved values; multi-select tests resolve an array of items.

---

## 6. Behavior Semantics (consolidated)

- **Success:** child exits 0 → terminal shows the streamed Pester output live; OutputChannel retains the same full log; service resolves the unchanged summary record.
- **Failure:** non-zero exit → `CommandExecutionError` unchanged (exit code, full stdout/stderr); `getStderrExcerpt` unchanged; the terminal additionally shows the failure output in place.
- **Ordering:** scope QuickPick → (optional) folder multi-select → config write-back → process spawn → terminal reveal + stream → completion. Config write-back happens before the run so a crash mid-run still leaves the selection persisted (deliberate: the selection is user intent, not a run result).
- **Precedence:** explicit scan folders (picker/arguments/MCP `scan_folders`) > `config/poshqc-scan.json` `test.scanFolders` > settings `Run.Path` defaults.
- **Edge cases:** blank config entry → validation error (mirrors `FileDiscovery.psm1:114-116`); entry outside root → error (mirrors lines 130-132); nonexistent config-sourced folder → skip with warning, error only when the surviving set is empty; malformed JSON / wrong `version` → clear fail-fast error naming the file; no workspace open → existing `getWorkspaceRoot` throw (`command-runtime.ts:122-129`).

## 7. Requirements Mapping

| AC | Design element |
|---|---|
| AC1 (terminal output) | Capability 1, Option C tee (section 2.2-2.3) |
| AC2 (coverage reconciliation) | Capability 2, Option A parity-gate extension + resync, plus Option C config convergence (section 3.2); baseline JUnit diff evidence |
| AC3 (persisted config) | Capability 3, `config/poshqc-scan.json` + module-level resolution (section 4) |
| AC4 (interactive select/deselect) | Capability 4, seeded `canPickMany` QuickPick with write-back (section 5) |

Suggested phase order for the planner: (1) baseline evidence + Capability 2 resync (independent, de-risks everything), (2) Capability 3 PowerShell + TS config modules, (3) Capability 4 picker, (4) Capability 1 terminal tee (independent of 2-3; can also run first). Capabilities 3 and 4 share `poshqc-scan-config.ts` and must be ordered 3 → 4.

## 8. Test Strategy

**TypeScript (Jest, `extensions/drm-copilot/test/`, existing harness):**
- Terminal tee: unit-test the streaming writer against the mocked `createTerminal`/`EventEmitter` surfaces (pattern: `terminal-writer.test.ts`); assert the tee forwards every `appendLine` to both sinks; integration-style command tests via `extension-test-harness` (`createMockProcess(exitCode)`) assert terminal creation + unchanged spawn args + `CommandExecutionError` propagation on exit 1.
- Scan config: exercise read/validate/write purely against the in-memory `FileSystem` fake (no temp files, per policy); property-style cases for path normalization if fast-check is available in the package (verify before planning; do not add a dependency).
- Picker: mock `showQuickPickMock` to resolve item arrays; assert seeding (`picked` flags), write-back content, empty-selection abort, cancel path.
- Determinism: no timers or wall-clock involved; child-process seam already mocked at `child_process.spawn` in the harness (mocking the seam, not the executable).

**Pester (`tests/scripts/powershell/PoshQC/`):**
- `PoshQC.ScanConfig.Tests.ps1`: inject `$ReadContent`/`$TestPathExists` scriptblocks (no real filesystem), covering absent file, malformed JSON, wrong version, blank entry, `..` entry, missing-folder skip-with-warning, empty-survivor error.
- `Invoke-PoshQCTest` precedence: extend the existing seam-injection style (`PoshQC.ScanFolders.Tests.ps1:16-39`) — inject `$ResolveScanConfig` and `$ResolveScanFolders`, assert explicit `-ScanFolders` bypasses config and config folders reach `Run.Path`.
- Parity: the extended `test_poshqc_bundled_parity.py` (pytest) is the regression lock for Capability 2.

**Evidence:** baseline and final QA artifacts go to `docs/features/active/2026-07-10-poshqc-test-terminal-output-scan-config-344/evidence/<kind>/` per the evidence-location invariant (baseline JUnit diff under `evidence/baseline/`).

## 9. Rejected Alternatives (summary)

- `createTerminal` + `sendText` for output redirect — no reliable exit code, no stdout/stderr capture, quoting risk (section 2.2 A).
- VS Code Task/`ProcessExecution` — preserves exit code but loses stderr capture and needs new harness surface; kept as documented fallback (section 2.2 B).
- VS Code `contributes.configuration` as the persisted scan store — invisible to the PowerShell module, the local task, and the standalone MCP server (section 4.1 A).
- Wrapper-only config read — re-opens task/command divergence; module-level read chosen (section 4.3).
- Workspace-first module resolution as the sole reconciliation — does not fix in-repo bundled drift for consumer repos; optional complement only (section 3.2 B).

## 10. Open Items for the Planner

1. Empirically verify `New-PesterConfiguration -Hashtable` behavior with the bundled `CodeCoverage.ExcludedPath` key (error vs ignore) and capture it in the baseline evidence.
2. Diff/resync `settings/pssa.settings.psd1` alongside the pester settings.
3. Decide seeded default (`three-entry Run.Path` mirror vs existing-folders-only) and the terminal/picker scope (test-only vs all four PoshQC commands; recommendation: all four).
4. Decide whether `runPoshQCSuite` (`extension.ts:384+`) adopts the picker/config in this feature or a follow-up (it uses `-ScanFolders` repeated args, not `-ScanFoldersJson`, per `repo-automation-args.ts:35-39`).
5. PowerShell batch planning per the change budget (3 production `.psm1` files at the cap).

## Automation Feasibility

Not applicable: no step in this feature requires third-party UI interaction. All work is local to the extension TypeScript code, the PoshQC PowerShell module, repo configuration files, and repo-local tests.
