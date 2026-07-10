# poshqc-test-terminal-output-scan-config — Plan

- **Issue:** #344
- **Parent (optional):** none
- **Owner:** drmoisan
- **Last Updated:** 2026-07-10
- **Status:** Ready for Preflight
- **Version:** 1.0
- **Work Mode:** full-feature
- **Plan Path (continuity):** `docs/features/active/2026-07-10-poshqc-test-terminal-output-scan-config-344/plan.md` (update in place across revision loops; do not create sibling plan files)

## Required References

- Spec (normative): `docs/features/active/2026-07-10-poshqc-test-terminal-output-scan-config-344/spec.md`
- User story: `docs/features/active/2026-07-10-poshqc-test-terminal-output-scan-config-344/user-story.md`
- Research: `docs/features/active/2026-07-10-poshqc-test-terminal-output-scan-config-344/research/research-findings.md`
- Issue: `docs/features/active/2026-07-10-poshqc-test-terminal-output-scan-config-344/issue.md`
- Policies: `CLAUDE.md`, `.claude/rules/general-code-change.md`, `.claude/rules/general-unit-test.md`, `.claude/rules/typescript.md`, `.claude/rules/powershell.md`, `.claude/rules/python.md`

All work must comply with these policies; this plan does not duplicate their content.

## Conventions Used in This Plan

- `<FEATURE>` = `docs/features/active/2026-07-10-poshqc-test-terminal-output-scan-config-344`. Evidence artifacts go only to `<FEATURE>/evidence/<kind>/` per `.claude/skills/evidence-and-timestamp-conventions/SKILL.md`. No `artifacts/`-rooted evidence path is permitted.
- Every evidence artifact records `Timestamp:` (ISO-8601 `yyyy-MM-ddTHH-mm`), `Command:`, `EXIT_CODE:`, and `Output Summary:`.
- TypeScript toolchain (run in `extensions/drm-copilot/`): `npm run format` → `npm run lint` → `npm run typecheck` → `npm test` (coverage mode: `npm run test:coverage`). The extension package uses the Jest harness (`run-jest.cjs`, tests in `extensions/drm-copilot/test/*.test.ts`); do not introduce Vitest into this package.
- PowerShell toolchain: `mcp__drm-copilot__run_poshqc_format` → `mcp__drm-copilot__run_poshqc_analyze` → `mcp__drm-copilot__run_poshqc_test` (Pester with repo settings; coverage reported by the tool). Pester tests live under `tests/scripts/powershell/PoshQC/`.
- Python toolchain (parity test only): `poetry run black .` → `poetry run ruff check .` → `poetry run pyright` → `poetry run pytest tests/scripts/dev_tools/test_poshqc_bundled_parity.py -v`.
- Loop rule: if any toolchain stage fails or changes files, restart that language's loop from formatting and repeat until a single clean pass completes.
- Determinism: no temporary files in tests; mock the wrapper seam (harness `child_process.spawn` seam, injectable scriptblocks, in-memory `FileSystem`), never the executable; no wall-clock reads, timers, or sleeps.
- PowerShell change budget: Phase 1 is an explicit batch of exactly 3 production PowerShell files and 2 test files (per-batch cap: 3/3). Bundled-resource mirrors are byte-for-byte mechanical copies mandated by the parity gate; they introduce no independent design surface. Phase 3 bundled `.psd1` resyncs are likewise mechanical copies of workspace-authoritative content.

## Known Residual Limitation (state in PR)

Per spec FR2.5: the *installed* extension converges on the reconciled bundled resources only at the next packaged release; in-repo drift is closed immediately by the extended parity gate. This statement must be carried into the PR description.

## Implementation Plan (Atomic Tasks)

### Phase 0 — Policy Reads and Baseline Capture

- [x] [P0-T1] Read policy files in the required order and record the read evidence.
  - Order: `CLAUDE.md`, `.claude/rules/general-code-change.md`, `.claude/rules/general-unit-test.md`, `.claude/rules/typescript.md`, `.claude/rules/typescript-suppressions.md` (if present), `.claude/rules/powershell.md`, `.claude/rules/python.md`, `.claude/rules/python-suppressions.md` (if present)
  - Artifact: `<FEATURE>/evidence/baseline/phase0-instructions-read.md` with `Timestamp:`, `Policy Order:`, and the explicit list of files read
  - Acceptance: artifact exists with all required fields; list matches the order above
- [x] [P0-T2] Capture TypeScript lint baseline.
  - Command: `npm run lint` in `extensions/drm-copilot/`
  - Artifact: `<FEATURE>/evidence/baseline/baseline-ts-lint.md` (`Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:`)
  - Acceptance: artifact exists with exit code recorded
- [x] [P0-T3] Capture TypeScript type-check baseline.
  - Command: `npm run typecheck` in `extensions/drm-copilot/`
  - Artifact: `<FEATURE>/evidence/baseline/baseline-ts-typecheck.md`
  - Acceptance: artifact exists with exit code recorded
- [x] [P0-T4] Capture TypeScript test + coverage baseline with numeric coverage values.
  - Command: `npm run test:coverage` in `extensions/drm-copilot/`
  - Artifact: `<FEATURE>/evidence/baseline/baseline-ts-test-coverage.md`; `Output Summary:` MUST include numeric baseline line and branch coverage percentages (no placeholders)
  - Acceptance: artifact exists; numeric line and branch coverage recorded
- [x] [P0-T5] Capture PowerShell analyzer baseline.
  - Command: MCP tool `mcp__drm-copilot__run_poshqc_analyze`
  - Artifact: `<FEATURE>/evidence/baseline/baseline-ps-analyze.md`
  - Acceptance: artifact exists with exit code and finding count recorded
- [x] [P0-T6] Capture PowerShell Pester test + coverage baseline with numeric coverage values.
  - Command: MCP tool `mcp__drm-copilot__run_poshqc_test`
  - Artifact: `<FEATURE>/evidence/baseline/baseline-ps-test-coverage.md`; `Output Summary:` MUST include pass/fail counts and numeric line coverage percentage from the Pester coverage report
  - Acceptance: artifact exists; numeric coverage recorded
- [x] [P0-T7] Capture Python parity-gate baseline.
  - Command: `poetry run pytest tests/scripts/dev_tools/test_poshqc_bundled_parity.py -v`
  - Artifact: `<FEATURE>/evidence/baseline/baseline-py-parity.md`
  - Acceptance: artifact exists with exit code and per-file parity results recorded
- [x] [P0-T8] Capture the baseline task-vs-command JUnit/discovered-set diff (spec FR2.3, AC7).
  - Run A (task path): `pwsh -NoLogo -NoProfile -ExecutionPolicy Bypass -Command "& { Import-Module ./scripts/powershell/PoshQC; Invoke-PoshQCTest -Root (Get-Location).Path }"` from the repo root; preserve the produced `artifacts/pester/pester-junit.xml` by copying it to `<FEATURE>/evidence/baseline/junit-task.xml`
  - Run B (command path, in-repo bundled snapshot): `pwsh -NoLogo -NoProfile -ExecutionPolicy Bypass -File extensions/drm-copilot/resources/templates/run-poshqc-test.ps1 -WorkspaceRoot (Get-Location).Path` (adjust to the wrapper's actual parameter names); copy the produced JUnit to `<FEATURE>/evidence/baseline/junit-command.xml`
  - Diff the two discovered test sets (test names/counts) and record the exact delta
  - Artifact: `<FEATURE>/evidence/baseline/junit-diff-task-vs-command.md` (`Timestamp:`, `Command:` for both runs, `EXIT_CODE:` for both runs, `Output Summary:` with the measured delta)
  - Acceptance: both runs executed against the same worktree; diff artifact records the measured delta (including "identical" if equal)
- [x] [P0-T9] Empirically record `New-PesterConfiguration -Hashtable` behavior for the bundled `CodeCoverage.ExcludedPath` key (spec FR2.3, AC7).
  - Command: `pwsh -NoLogo -NoProfile -Command "& { $h = Import-PowerShellDataFile extensions/drm-copilot/resources/powershell/PoshQC/settings/pester.runsettings.psd1; New-PesterConfiguration -Hashtable $h }"` (capture error vs silent-ignore outcome)
  - Artifact: `<FEATURE>/evidence/baseline/pester-excludedpath-empirical.md` with the verbatim outcome (error text or confirmation the key is ignored)
  - Acceptance: artifact states unambiguously whether the unknown key errors or is ignored
- [x] [P0-T10] Diff workspace vs bundled `pssa.settings.psd1` and record the result (research open item 2).
  - Files compared: `scripts/powershell/PoshQC/settings/pssa.settings.psd1` vs `extensions/drm-copilot/resources/powershell/PoshQC/settings/pssa.settings.psd1`
  - Artifact: `<FEATURE>/evidence/baseline/pssa-settings-diff.md` (`Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:` = identical or the exact hunks)
  - Acceptance: artifact records whether the copies are byte-identical

### Phase 1 — Capability 3: Persisted Scan Config (PowerShell batch)

Batch declaration: 3 production PowerShell files (`PoshQC.ScanConfig.psm1` new, `PoshQC.psm1`, `PoshQC.Testing.psm1`) and 2 test files (`PoshQC.ScanConfig.Tests.ps1` new, `PoshQC.ScanFolders.Tests.ps1` extended) — at the per-batch cap, no overage. Bundled mirrors in P1-T7 are mechanical byte copies.

- [x] [P1-T1] Create `config/poshqc-scan.json` with the seeded behavior-preserving default (spec FR3.1).
  - Content: `{ "version": 1, "test": { "scanFolders": ["scripts", "tests/powershell", "tests/scripts"] } }` (sorted, forward-slash, trailing newline)
  - Acceptance: file exists at `config/poshqc-scan.json`; content matches the schema in spec section "Configuration Schema"; `test.scanFolders` equals the current `Run.Path` set exactly
  - AC: AC3
- [x] [P1-T2] Create `scripts/powershell/PoshQC/PoshQC.ScanConfig.psm1` exporting `Get-PoshQCScanConfigFolder` (spec FR3.2, FR3.5, FR3.6).
  - Signature: `Get-PoshQCScanConfigFolder -Root <root> [-ConfigRelativePath 'config/poshqc-scan.json'] [-TestPathExists <scriptblock>] [-ReadContent <scriptblock>]` (DI style of `Convert-PoshQCCoverageToRelative`, `PoshQC.Testing.psm1:50-69`)
  - Behavior: returns `@()` when the file is absent or `test.scanFolders` is absent/empty; fail-fast errors naming `config/poshqc-scan.json` for malformed JSON, `version` != 1, blank entries, absolute paths, `..` segments; config-sourced folders that do not exist are filtered out with a logged warning (module's existing warning pattern); if all config-sourced folders are filtered, throw a clear error; do not weaken `Resolve-PoshQCScanFolder`
  - Constraints: advanced function with `CmdletBinding()`; file <= 500 lines (~80-110 expected)
  - Acceptance: module parses; exported function implements every behavior above (verified by P1-T5 tests)
  - AC: AC3, AC8, AC9
- [x] [P1-T3] Update `scripts/powershell/PoshQC/PoshQC.psm1` to load `PoshQC.ScanConfig.psm1` and export `Get-PoshQCScanConfigFolder` (delta +2-3 lines; 102 → ~105).
  - Acceptance: `Import-Module ./scripts/powershell/PoshQC` exposes `Get-PoshQCScanConfigFolder`; no other export changes
  - AC: AC3
- [x] [P1-T4] Update `Invoke-PoshQCTest` in `scripts/powershell/PoshQC/PoshQC.Testing.psm1` to consume the config (spec FR3.3, FR3.4).
  - Add optional injectable `[scriptblock] $ResolveScanConfig` parameter defaulting to `Get-PoshQCScanConfigFolder`; consult it only when `-ScanFolders` is not supplied; route config-yielded folders through the existing `Resolve-PoshQCScanFolder` path (lines 279-284); explicit `-ScanFolders` always wins; absent/empty config yields the existing `Run.Path` defaults; no unrelated logic added; file stays <= 500 lines (410 → ~428)
  - Acceptance: precedence contract explicit `-ScanFolders`/`-ScanFoldersJson` > config > `Run.Path` holds (verified by P1-T6 tests); existing parameters unchanged
  - AC: AC3, AC10, AC12
- [x] [P1-T5] Create `tests/scripts/powershell/PoshQC/PoshQC.ScanConfig.Tests.ps1` covering the config reader with injected `$ReadContent`/`$TestPathExists` scriptblocks (no real filesystem, no temp files).
  - Scenarios: absent file → `@()`; absent/empty `test.scanFolders` → `@()`; malformed JSON → error naming `config/poshqc-scan.json`; `version` != 1 → error; blank entry → error; absolute-path entry → error; `..` entry → error; nonexistent folder skipped with warning; all folders nonexistent → clear error
  - Acceptance: all scenarios present as individual `It` blocks; Pester run passes via `mcp__drm-copilot__run_poshqc_test`
  - AC: AC3, AC8, AC9
- [x] [P1-T6] Extend `tests/scripts/powershell/PoshQC/PoshQC.ScanFolders.Tests.ps1` with `Invoke-PoshQCTest` precedence and missing-folder-policy cases using the existing seam-injection style (lines 16-39).
  - Scenarios: explicit `-ScanFolders` bypasses the injected `$ResolveScanConfig` (config seam never invoked); config-yielded folders reach the run paths when `-ScanFolders` is absent; config returning `@()` yields `Run.Path` defaults; explicitly supplied nonexistent folder still throws (existing `Resolve-PoshQCScanFolder` behavior)
  - Acceptance: all scenarios pass via `mcp__drm-copilot__run_poshqc_test`
  - AC: AC9, AC10, AC12
- [x] [P1-T7] Mirror the three changed/new production modules byte-for-byte into the bundled resources (mechanical copies, spec FR3.9).
  - Copies: `scripts/powershell/PoshQC/PoshQC.psm1` → `extensions/drm-copilot/resources/powershell/PoshQC/PoshQC.psm1`; `scripts/powershell/PoshQC/PoshQC.Testing.psm1` → `extensions/drm-copilot/resources/powershell/PoshQC/PoshQC.Testing.psm1`; `scripts/powershell/PoshQC/PoshQC.ScanConfig.psm1` → `extensions/drm-copilot/resources/powershell/PoshQC/PoshQC.ScanConfig.psm1`
  - Acceptance: each bundled file is byte-identical to its workspace source (verified by `git diff --stat` review and P1-T9)
  - AC: AC2, AC12
- [x] [P1-T8] Run the full PowerShell toolchain loop until a single clean pass.
  - Commands in order: `mcp__drm-copilot__run_poshqc_format` → `mcp__drm-copilot__run_poshqc_analyze` → `mcp__drm-copilot__run_poshqc_test`; restart from format if any step fails or changes files; re-copy mirrors (P1-T7) if formatting changed the workspace modules
  - Acceptance: all three stages pass consecutively with exit code 0
  - AC: AC3, AC8, AC9, AC10
- [x] [P1-T9] Verify the existing parity gate still passes with the Phase 1 mirrors in place.
  - Command: `poetry run pytest tests/scripts/dev_tools/test_poshqc_bundled_parity.py -v`
  - Acceptance: exit code 0; the four currently-locked `.psm1` files report parity
  - AC: AC2

### Phase 2 — Capability 3: TypeScript Config Module and MCP Descriptions

- [x] [P2-T1] Create `extensions/drm-copilot/src/poshqc-scan-config.ts` implementing read/validate/write of `config/poshqc-scan.json` through the injectable `FileSystem` seam (`extensions/drm-copilot/src/lib/file-system.ts`) (spec FR3.7).
  - Behavior: validation rules identical to `Get-PoshQCScanConfigFolder` (malformed JSON, `version` != 1, blank entry, absolute path, `..` segment → errors naming the file; absent file or absent/empty `test.scanFolders` → empty result); writes are canonical (workspace-relative forward-slash paths, deduplicated, sorted, stable formatting); no new runtime dependencies; file <= 500 lines (~100-140 expected)
  - Acceptance: module compiles; behaviors verified by P2-T2 tests
  - AC: AC8, AC11
- [x] [P2-T2] Create `extensions/drm-copilot/test/poshqc-scan-config.test.ts` (Jest) against the in-memory `FileSystem` fake (no temp files).
  - Scenarios: absent file → empty result; each validation failure case (malformed JSON, wrong `version`, blank entry, absolute path, `..` segment) errors naming the file; canonical write normalizes (backslashes → forward slashes, dedupe, sort); read-after-write round-trip is byte-stable
  - Command: `npm test` in `extensions/drm-copilot/`
  - Acceptance: all scenarios pass under the Jest harness
  - AC: AC8, AC11
- [x] [P2-T3] Update the `run_poshqc_test` tool description strings to document the config-aware default when `scan_folders` is omitted (spec FR3.8).
  - Files: `extensions/drm-copilot/src/mcp-tool-definitions.ts` (lines ~277-296) and `extensions/drm-copilot/src/mcp-repo-automation-tool-definitions.ts` (lines ~295-315); update `extensions/drm-copilot/test/mcp-repo-automation-tool-definitions.test.ts` and `extensions/drm-copilot/test/mcp-tool-inputs.test.ts` if they assert the description text; no schema or behavior change
  - Acceptance: both description strings state that omitting `scan_folders` resolves folders from `config/poshqc-scan.json` with explicit `scan_folders` overriding; `npm test` passes
  - AC: AC12
- [x] [P2-T4] Run the full TypeScript toolchain loop until a single clean pass.
  - Commands in order (in `extensions/drm-copilot/`): `npm run format` → `npm run lint` → `npm run typecheck` → `npm test`; restart from format if any step fails or changes files
  - Acceptance: all four stages pass consecutively with exit code 0
  - AC: AC8, AC11, AC12

### Phase 3 — Capability 2: Parity-Gate Extension and Bundled Resync

- [x] [P3-T1] Resync `extensions/drm-copilot/resources/powershell/PoshQC/PoshQC.psd1` as a byte-for-byte copy of `scripts/powershell/PoshQC/PoshQC.psd1` (spec FR2.2, FR2.4).
  - Effect: removes the bundled `RequiredModules` block; workspace copy is authoritative (its empty-`RequiredModules` bootstrap contract is asserted by `tests/scripts/powershell/PoshQC/PoshQC.EntryPoints.Tests.ps1:32-38`)
  - Acceptance: `git diff` shows the bundled file now byte-identical to the workspace copy
  - AC: AC2
- [x] [P3-T2] Resync `extensions/drm-copilot/resources/powershell/PoshQC/settings/pester.runsettings.psd1` as a byte-for-byte copy of `scripts/powershell/PoshQC/settings/pester.runsettings.psd1` (spec FR2.2).
  - Effect: removes the undocumented `CodeCoverage.ExcludedPath` block; adopts the workspace coverage `Path` list
  - Acceptance: bundled file byte-identical to the workspace copy
  - AC: AC2
- [x] [P3-T3] Resync or confirm `extensions/drm-copilot/resources/powershell/PoshQC/settings/pssa.settings.psd1` byte-identical to `scripts/powershell/PoshQC/settings/pssa.settings.psd1`, per the P0-T10 diff result.
  - Acceptance: bundled file byte-identical to the workspace copy
  - AC: AC2
- [x] [P3-T4] Extend `POSHQC_PARITY_PATHS` in `tests/scripts/dev_tools/test_poshqc_bundled_parity.py` (lines 9-14) with four entries: `PoshQC.psd1`, `settings/pester.runsettings.psd1`, `settings/pssa.settings.psd1`, `PoshQC.ScanConfig.psm1` (spec FR2.1, FR3.9).
  - Acceptance: the parity test parametrizes over all eight files and passes; removing any one bundled file's parity would fail the gate
  - AC: AC2
- [x] [P3-T5] Run the full Python toolchain loop on the changed test file until a single clean pass.
  - Commands in order: `poetry run black .` → `poetry run ruff check .` → `poetry run pyright` → `poetry run pytest tests/scripts/dev_tools/test_poshqc_bundled_parity.py -v`; restart from format if any step fails or changes files
  - Acceptance: all four stages pass consecutively with exit code 0
  - AC: AC2
- [x] [P3-T6] Record extended-parity-gate evidence.
  - Artifact: `<FEATURE>/evidence/qa-gates/parity-gate-extended.md` (`Timestamp:`, `Command:` = the P3-T5 pytest command, `EXIT_CODE:`, `Output Summary:` listing the eight parity-locked files and noting the FR2.5 residual limitation: installed-extension convergence occurs at the next packaged release)
  - Acceptance: artifact exists with all required fields
  - AC: AC2

### Phase 4 — Capability 1: Terminal Tee for the Command Path

- [x] [P4-T1] Create `extensions/drm-copilot/src/poshqc-terminal-output.ts` with a streaming (append-mode) pseudoterminal writer and a tee `CommandOutput` (spec FR1.1, FR1.2; research section 2.2 Option C).
  - Content: a pseudoterminal-backed writer modeled on the `TerminalWriter` precedent (`extensions/drm-copilot/src/terminal-writer.ts:42-90`) that appends lines converting `\n` → `\r\n`, reuses a terminal with the stable name `drm-copilot: PoshQC`, and exposes reveal; plus `createTeeOutput(a, b): CommandOutput` forwarding every `appendLine` to both sinks; file <= 500 lines (~100-130 expected)
  - Acceptance: module compiles; behaviors verified by P4-T2
  - AC: AC1
- [x] [P4-T2] Create `extensions/drm-copilot/test/poshqc-terminal-output.test.ts` (Jest) using the harness `createTerminal`/EventEmitter mocks (pattern: `extensions/drm-copilot/test/terminal-writer.test.ts`).
  - Scenarios: writer streams appended lines with CRLF conversion; terminal name is stable and the instance is reused; tee forwards every `appendLine` to both sinks in order; no timers or wall-clock use
  - Command: `npm test` in `extensions/drm-copilot/`
  - Acceptance: all scenarios pass
  - AC: AC1
- [x] [P4-T3] Update `extensions/drm-copilot/src/poshqc-command-registration.ts` to build the tee sink per PoshQC command invocation and reveal the terminal at command start (spec FR1.5).
  - Change: add an optional `createService(output: CommandOutput) => RepoAutomationService` factory option to `registerPoshQcCommands`; per invocation, construct the tee (existing `OutputChannel` + terminal writer from P4-T1), call the factory, and reveal the terminal before the run; apply to all four PoshQC commands (spec-recommended scope; AC1 requires the test command); do not modify `extensions/drm-copilot/src/repo-automation-service.ts`
  - Acceptance: registration module compiles; spawn pipeline (`runCommandWithOutput`, `command-runtime.ts:206-267`) untouched; file stays well under 500 lines (111 → ~145)
  - AC: AC1, AC5
- [x] [P4-T4] Update `extensions/drm-copilot/src/extension.ts` with a minimal factory pass-through into `registerPoshQcCommands` using the existing `createRepoAutomationService` (spec FR1.5).
  - Constraint: delta <= 6 lines; if the delta would push `extension.ts` (483 lines) toward the 500-line cap, move the option-block construction into `poshqc-command-registration.ts` instead; `repo-automation-service.ts` must remain unchanged
  - Acceptance: `extension.ts` <= 500 lines after the edit; `git diff --stat` confirms `repo-automation-service.ts` untouched
  - AC: AC1, AC16
- [x] [P4-T5] Extend `extensions/drm-copilot/test/extension.run-poshqc-commands.test.ts` with terminal and failure-semantics cases.
  - Scenarios: invoking `drmCopilotExtension.runPoshQCTest` creates/reveals the `drm-copilot: PoshQC` terminal at command start and the `OutputChannel` receives the identical line stream (AC1); with `createMockProcess(exitCode: 1)` and the tee active, the command rejects with `CommandExecutionError` carrying `exitCode`, full `stdout`, full `stderr`, and `getStderrExcerpt` output is unchanged (AC5); spawn arguments unchanged
  - Command: `npm test` in `extensions/drm-copilot/`
  - Acceptance: all scenarios pass
  - AC: AC1, AC5
- [x] [P4-T6] Extend `extensions/drm-copilot/test/mcp-server.test.ts` (or the existing MCP dispatch test that covers `run_poshqc_test`) to assert the MCP path creates no terminal and uses the buffered sink (spec FR1.4).
  - Scenario: dispatching `run_poshqc_test` via the MCP path (`mcp-tools.ts:206-208`, buffered sink at `mcp-server.ts:105` / `createBufferedOutput`, `command-runtime.ts:101-114`) never calls `vscode.window.createTerminal`
  - Command: `npm test` in `extensions/drm-copilot/`
  - Acceptance: test passes; no MCP schema or behavior change
  - AC: AC6
- [x] [P4-T7] Run the full TypeScript toolchain loop until a single clean pass.
  - Commands in order (in `extensions/drm-copilot/`): `npm run format` → `npm run lint` → `npm run typecheck` → `npm test`; restart from format if any step fails or changes files
  - Acceptance: all four stages pass consecutively with exit code 0
  - AC: AC1, AC5, AC6

### Phase 5 — Capability 4: Interactive Folder Multi-Select

- [x] [P5-T1] Create `extensions/drm-copilot/src/poshqc-folder-picker.ts` (spec FR4.1-FR4.6; research section 5.2).
  - Content: candidate enumeration of workspace directories to bounded depth 2 via the `FileSystem` seam, excluding the directory names from `scripts/powershell/PoshQC/PoshQC.psm1:5-9` mirrored as a TS constant with a comment pointing at the PowerShell source; seeding `picked = true` for items whose workspace-relative path is in `config/poshqc-scan.json` `test.scanFolders` (read via `poshqc-scan-config.ts`); config-listed folders always shown even when not enumerated, with a `$(warning)` description when the folder no longer exists; `vscode.window.showQuickPick(items, { canPickMany: true, ignoreFocusOut: true, title, placeHolder })`; on non-empty accept, persist the selection canonically via `poshqc-scan-config.ts` and return workspace-relative forward-slash paths; on cancel (`undefined`), no persistence and no run signal; on empty accept, show an information message and signal abort without persisting; file <= 500 lines (~140-180 expected)
  - Acceptance: module compiles; behaviors verified by P5-T2
  - AC: AC4, AC13, AC14, AC15
- [x] [P5-T2] Create `extensions/drm-copilot/test/poshqc-folder-picker.test.ts` (Jest) using the in-memory `FileSystem` fake and the harness `showQuickPickMock` (`extension-test-harness.ts:243-247`).
  - Scenarios: enumeration respects depth 2 and the excluded directory names (AC15); seeding sets `picked` for config-listed paths (AC4); a config-listed folder that no longer exists appears with the `$(warning)` description and is not dropped (AC15); accepted non-empty selection is persisted canonically before returning and a read-back round-trip matches (AC4); cancel performs no write (AC13); empty accept shows the information message and performs no write (AC14)
  - Command: `npm test` in `extensions/drm-copilot/`
  - Acceptance: all scenarios pass; no temp files, no timers
  - AC: AC4, AC13, AC14, AC15
- [x] [P5-T3] Update `extensions/drm-copilot/src/poshqc-command-registration.ts` to route the test command's `"Select folders to scan"` choice through the new picker (spec FR4.4, FR4.7).
  - Change: replace the `promptForWorkspaceScanFolders` call in the test-command flow with the picker; leave `extensions/drm-copilot/src/extension-command-helpers.ts` untouched (other callers remain); retain the two-item scope QuickPick; persist the selection to the config before the spawn, then pass the workspace-relative selection as explicit scan folders through the existing `-ScanFoldersJson` argument path (`repo-automation-args.ts:28-34`); cancel and empty-accept abort without running
  - Acceptance: ordering is scope QuickPick → multi-select → config write-back → spawn → terminal reveal + stream; file stays under 500 lines (~160 total)
  - AC: AC4, AC13, AC14
- [x] [P5-T4] Update the interactive-mode cases in `extensions/drm-copilot/test/extension.run-poshqc-commands.test.ts` from `showOpenDialogMock` to multi-select `showQuickPickMock` returns.
  - Scenarios: end-to-end test command with a multi-select return runs with exactly the selected workspace-relative folders serialized via `-ScanFoldersJson`; config file content updated before the mocked spawn is invoked; cancel path performs no run and no write
  - Command: `npm test` in `extensions/drm-copilot/`
  - Acceptance: all updated cases pass
  - AC: AC4, AC13, AC14
- [x] [P5-T5] Run the full TypeScript toolchain loop until a single clean pass.
  - Commands in order (in `extensions/drm-copilot/`): `npm run format` → `npm run lint` → `npm run typecheck` → `npm test`; restart from format if any step fails or changes files
  - Acceptance: all four stages pass consecutively with exit code 0
  - AC: AC4, AC13, AC14, AC15

### Phase 6 — Final QA Loop, Coverage Evidence, and Acceptance Verification

Loop rule for this phase: if any command in P6-T1..P6-T11 fails or changes files, fix, then restart that language's loop from its formatting step and re-record the affected artifacts. No `SKIPPED` outcomes are authorized for any task in this phase.

- [x] [P6-T1] Run TypeScript formatting and record evidence.
  - Command: `npm run format` in `extensions/drm-copilot/`
  - Artifact: `<FEATURE>/evidence/qa-gates/final-ts-format.md` (`Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:`)
  - Acceptance: exit code 0; no file changes on the final pass
- [x] [P6-T2] Run TypeScript linting and record evidence.
  - Command: `npm run lint` in `extensions/drm-copilot/`
  - Artifact: `<FEATURE>/evidence/qa-gates/final-ts-lint.md`
  - Acceptance: exit code 0, zero errors
- [x] [P6-T3] Run TypeScript type-checking and record evidence.
  - Command: `npm run typecheck` in `extensions/drm-copilot/`
  - Artifact: `<FEATURE>/evidence/qa-gates/final-ts-typecheck.md`
  - Acceptance: exit code 0, zero errors
- [x] [P6-T4] Run TypeScript tests in coverage mode and record numeric post-change coverage.
  - Command: `npm run test:coverage` in `extensions/drm-copilot/`
  - Artifact: `<FEATURE>/evidence/qa-gates/final-ts-test-coverage.md`; `Output Summary:` MUST include numeric post-change line and branch coverage and the per-file coverage for the new/changed modules (`poshqc-scan-config.ts`, `poshqc-terminal-output.ts`, `poshqc-folder-picker.ts`, `poshqc-command-registration.ts`)
  - Acceptance: all tests pass; line >= 85% and branch >= 75% for the changed code
  - AC: AC16
- [x] [P6-T5] Run PowerShell formatting via MCP and record evidence.
  - Command: `mcp__drm-copilot__run_poshqc_format`
  - Artifact: `<FEATURE>/evidence/qa-gates/final-ps-format.md`
  - Acceptance: exit code 0; if files changed, re-copy mirrors (P1-T7 file set) and restart the PowerShell loop
- [x] [P6-T6] Run the PowerShell analyzer via MCP and record evidence.
  - Command: `mcp__drm-copilot__run_poshqc_analyze`
  - Artifact: `<FEATURE>/evidence/qa-gates/final-ps-analyze.md`
  - Acceptance: exit code 0, zero findings
- [x] [P6-T7] Run Pester tests via MCP in coverage mode and record numeric post-change coverage.
  - Command: `mcp__drm-copilot__run_poshqc_test`
  - Artifact: `<FEATURE>/evidence/qa-gates/final-ps-test-coverage.md`; `Output Summary:` MUST include pass/fail counts and numeric coverage, including coverage touching `PoshQC.ScanConfig.psm1` and the changed `Invoke-PoshQCTest` lines
  - Acceptance: all tests pass; line >= 85% and branch >= 75% for the changed PowerShell code
  - AC: AC16
- [x] [P6-T8] Run Python formatting and record evidence.
  - Command: `poetry run black .`
  - Artifact: `<FEATURE>/evidence/qa-gates/final-py-format.md`
  - Acceptance: exit code 0; no file changes on the final pass
- [x] [P6-T9] Run Python linting and record evidence.
  - Command: `poetry run ruff check .`
  - Artifact: `<FEATURE>/evidence/qa-gates/final-py-lint.md`
  - Acceptance: exit code 0, zero errors
- [x] [P6-T10] Run Python type-checking and record evidence.
  - Command: `poetry run pyright`
  - Artifact: `<FEATURE>/evidence/qa-gates/final-py-typecheck.md`
  - Acceptance: exit code 0, zero errors
- [x] [P6-T11] Run the extended parity pytest and record evidence.
  - Command: `poetry run pytest tests/scripts/dev_tools/test_poshqc_bundled_parity.py -v`
  - Artifact: `<FEATURE>/evidence/qa-gates/final-py-parity.md`; `Output Summary:` notes that only test code changed in Python (no Python production code in scope, so Python coverage delta is not applicable — state this explicitly)
  - Acceptance: exit code 0; all eight parity files pass
  - AC: AC2
- [x] [P6-T12] Capture the post-change task-vs-command JUnit/discovered-set comparison (AC2 closure).
  - Repeat the two runs from P0-T8 at the post-change worktree state; copy JUnit outputs to `<FEATURE>/evidence/regression-testing/junit-task-post.xml` and `<FEATURE>/evidence/regression-testing/junit-command-post.xml`; diff the discovered test sets
  - Artifact: `<FEATURE>/evidence/regression-testing/junit-diff-post-change.md` (`Timestamp:`, both `Command:` lines, both `EXIT_CODE:` values, `Output Summary:` stating the discovered sets are identical)
  - Acceptance: the two invocations discover the same Pester test set; artifact records the comparison
  - AC: AC2
- [x] [P6-T13] Produce the coverage baseline/post-change/changed-code comparison artifact.
  - Inputs: `<FEATURE>/evidence/baseline/baseline-ts-test-coverage.md`, `<FEATURE>/evidence/baseline/baseline-ps-test-coverage.md`, `<FEATURE>/evidence/qa-gates/final-ts-test-coverage.md`, `<FEATURE>/evidence/qa-gates/final-ps-test-coverage.md`
  - Artifact: `<FEATURE>/evidence/qa-gates/coverage-comparison.md` reporting, per language: baseline coverage, post-change coverage, and new/changed-code coverage, with a no-regression statement for changed lines; numeric values only, no placeholders
  - Acceptance: artifact shows line >= 85% and branch >= 75% for changed code in both languages and no regression on changed lines; if any required value is unavailable, the plan outcome is remediation-required, not PASS
  - AC: AC16
- [x] [P6-T14] Verify the 500-line limit for all touched production files and record evidence.
  - Files checked (line counts): `extensions/drm-copilot/src/extension.ts`, `extensions/drm-copilot/src/repo-automation-service.ts` (must also be unchanged per `git diff`), `extensions/drm-copilot/src/poshqc-command-registration.ts`, `extensions/drm-copilot/src/poshqc-terminal-output.ts`, `extensions/drm-copilot/src/poshqc-scan-config.ts`, `extensions/drm-copilot/src/poshqc-folder-picker.ts`, `extensions/drm-copilot/src/mcp-tool-definitions.ts`, `extensions/drm-copilot/src/mcp-repo-automation-tool-definitions.ts`, `scripts/powershell/PoshQC/PoshQC.psm1`, `scripts/powershell/PoshQC/PoshQC.Testing.psm1`, `scripts/powershell/PoshQC/PoshQC.ScanConfig.psm1`, `tests/scripts/dev_tools/test_poshqc_bundled_parity.py`
  - Artifact: `<FEATURE>/evidence/qa-gates/file-size-check.md` listing each file with its line count
  - Acceptance: every listed file <= 500 lines; `repo-automation-service.ts` shows no diff
  - AC: AC16
- [x] [P6-T15] Check off delivered acceptance criteria in both AC source files per the `acceptance-criteria-tracking` skill (work mode `full-feature` → `spec.md` AND `user-story.md`).
  - Files: `docs/features/active/2026-07-10-poshqc-test-terminal-output-scan-config-344/spec.md` and `docs/features/active/2026-07-10-poshqc-test-terminal-output-scan-config-344/user-story.md`
  - Protocol: one-at-a-time check-off with per-item verification evidence (task/test/artifact reference); change only `- [ ]` to `- [x]`; leave unmet items unchecked and document the gap; produce the required AC Status Summary
  - Artifact: `<FEATURE>/evidence/qa-gates/acceptance-criteria-status.md` containing the AC Status Summary (source files, total, checked, remaining) and the per-AC evidence pointers
  - Acceptance: every AC marked `[x]` has named verification evidence; both source files updated consistently
  - AC: AC1–AC16 (tracking)

## Acceptance-Criteria Mapping

| AC | Satisfied by tasks | Verification |
|---|---|---|
| AC1 | P4-T1, P4-T2, P4-T3, P4-T4, P4-T5, P4-T7 | Jest: terminal creation/reveal + dual-sink forwarding |
| AC2 | P1-T7, P1-T9, P3-T1, P3-T2, P3-T3, P3-T4, P3-T5, P3-T6, P6-T11, P6-T12 | Extended parity gate passing + recorded JUnit-diff comparison |
| AC3 | P1-T1, P1-T2, P1-T3, P1-T4, P1-T5, P1-T8 | Pester seam-injection tests |
| AC4 | P5-T1, P5-T2, P5-T3, P5-T4, P5-T5 | Jest picker tests incl. persistence round-trip |
| AC5 | P4-T3, P4-T5, P4-T7 | Jest mocked-process exit-1 test with tee active |
| AC6 | P4-T6, P4-T7 | Jest MCP dispatch-path test (no terminal, buffered sink) |
| AC7 | P0-T8, P0-T9 | Baseline evidence under `<FEATURE>/evidence/baseline/` |
| AC8 | P1-T2, P1-T5, P2-T1, P2-T2 | Pester (injected `$ReadContent`) + Jest (in-memory `FileSystem`) |
| AC9 | P1-T2, P1-T5, P1-T6 | Pester skip-with-warning / empty-survivor / throw-on-missing tests |
| AC10 | P1-T4, P1-T6 | Pester precedence tests on `Invoke-PoshQCTest` |
| AC11 | P2-T1, P2-T2 | Jest canonical-write and round-trip tests |
| AC12 | P1-T4, P1-T6, P1-T7, P2-T3 | Module precedence tests + description-string updates, no schema change |
| AC13 | P5-T1, P5-T2, P5-T3, P5-T4 | Jest cancel test |
| AC14 | P5-T1, P5-T2, P5-T3, P5-T4 | Jest empty-selection test |
| AC15 | P5-T1, P5-T2 | Jest enumeration/exclusion/warning-marker tests |
| AC16 | P4-T4, P6-T4, P6-T7, P6-T13, P6-T14 | File-size check + numeric coverage evidence + comparison artifact |

Every AC (AC1–AC16) is covered by at least one task; P6-T15 performs the tracked check-off.

## Test Plan

- Unit (Jest, `extensions/drm-copilot/test/`): `poshqc-terminal-output.test.ts` (new), `poshqc-scan-config.test.ts` (new), `poshqc-folder-picker.test.ts` (new), `extension.run-poshqc-commands.test.ts` (extended), `mcp-server.test.ts` (extended), MCP definition tests (extended as needed). Harness: `run-jest.cjs`; in-memory `FileSystem`; mocked `createTerminal` / `showQuickPick` / `child_process.spawn` seams; no temp files; no timers.
- Unit (Pester, `tests/scripts/powershell/PoshQC/`): `PoshQC.ScanConfig.Tests.ps1` (new), `PoshQC.ScanFolders.Tests.ps1` (extended). Injectable scriptblock seams only; no real filesystem.
- Regression (pytest): `tests/scripts/dev_tools/test_poshqc_bundled_parity.py` extended to eight parity-locked files.
- Coverage evidence: baseline at `<FEATURE>/evidence/baseline/baseline-ts-test-coverage.md` and `<FEATURE>/evidence/baseline/baseline-ps-test-coverage.md`; post-change at `<FEATURE>/evidence/qa-gates/final-ts-test-coverage.md` and `<FEATURE>/evidence/qa-gates/final-ps-test-coverage.md`; comparison at `<FEATURE>/evidence/qa-gates/coverage-comparison.md`.

## Open Questions / Notes

- Terminal scope decision (encoded): all four PoshQC commands share the `drm-copilot: PoshQC` terminal per spec FR1.5 recommendation; AC1 requires only the test command.
- Picker scope decision (encoded): the multi-select picker replaces the `promptForWorkspaceScanFolders` call in the test-command flow only; the helper itself remains untouched for other callers, and `runPoshQCSuite` migration stays a non-goal.
- Seeded default decision (encoded): the full three-entry `Run.Path` mirror (`scripts`, `tests/powershell`, `tests/scripts`); the FR3.5 skip-with-warning rule makes the nonexistent `tests/powershell` entry safe.
- fast-check: verify availability in `extensions/drm-copilot/package.json` before writing property-style cases; do not add a dependency (spec constraint). If unavailable, example-based cases in P2-T2 suffice.
- The pre-existing sibling file `plan.2026-07-10T17-06.md` in the feature folder is an unfilled template stub created at folder scaffolding time; this `plan.md` is the authoritative plan per the plan-path continuity contract. No additional sibling plan files may be created during this cycle.
- FR2.5 residual limitation (repeat for PR authoring): the installed extension converges on the reconciled bundled resources only at the next packaged release.
