# pre-claude-session-script - Plan

- **Issue:** #189
- **Parent (optional):** none
- **Owner:** drmoisan
- **Last Updated:** 2026-06-16T13-49
- **Status:** Draft
- **Version:** 0.2
- **Work Mode:** full-feature

## Required References

- General Coding Standards: `.github/instructions/general-code-change.instructions.md`
- General Unit Test Policy: `.github/instructions/general-unit-test.instructions.md`
- TypeScript Code Standards: `.github/instructions/typescript-code-change.instructions.md`
- TypeScript Unit Test Policy: `.github/instructions/typescript-unit-test.instructions.md`
- Repository tone policy: `.github/copilot-instructions.md`

**All work must comply with these policies; do not duplicate their content here.**

## Scope and Authoritative Context

- Acceptance-criteria source: `docs/features/active/2026-06-16-pre-claude-session-script-189/user-story.md` (AC1-AC8).
- Spec: `docs/features/active/2026-06-16-pre-claude-session-script-189/spec.md`.
- In-scope production files (2 production + 1 manifest):
  - `extensions/drm-copilot/src/claude-worktree-session.ts` (pure builder; MUST NOT import `vscode`, `node:child_process`, or `node:fs`).
  - `extensions/drm-copilot/src/extension.ts` (`newClaudeWorktreeSession` handler, lines 104-188).
  - `extensions/drm-copilot/package.json` (`contributes.configuration`).
- In-scope test/harness files:
  - `extensions/drm-copilot/test/claude-worktree-session.test.ts`.
  - `extensions/drm-copilot/test/extension.workflow-commands.test.ts`.
  - `extensions/drm-copilot/test/extension-test-harness.ts` (the `vscode` mock currently lacks `workspace.getConfiguration`; it must be extended so the handler's configuration read is testable).
- Language in scope: TypeScript only. Coverage policy applies: line >= 85%, branch >= 75%, no regression on changed lines.
- Toolchain working directory for all commands: `extensions/drm-copilot`.

## Evidence Location Invariant

All evidence artifacts MUST be written under the canonical scheme `docs/features/active/2026-06-16-pre-claude-session-script-189/evidence/<kind>/`. Writing to `artifacts/baselines/`, `artifacts/qa/`, `artifacts/coverage/`, or any other non-canonical path is a policy violation and is rejected. If a caller supplies a non-canonical evidence path, substitute the canonical path and record `EVIDENCE_LOCATION_OVERRIDE_REJECTED: <supplied path> replaced with <canonical path>`.

## Implementation Plan (Atomic Tasks)

### Phase 0 — Baseline Capture and Policy Read

- [x] [P0-T1] Read the repository policy files in required order and record an evidence artifact at `docs/features/active/2026-06-16-pre-claude-session-script-189/evidence/baseline/phase0-instructions-read.md`
  - Policy order: (1) `CLAUDE.md`; (2) `.claude/rules/general-code-change.md`; (3) `.claude/rules/general-unit-test.md`; (4) `.claude/rules/typescript.md` and `.claude/rules/typescript-suppressions.md`; (5) `.claude/rules/architecture-boundaries.md`; (6) `.claude/rules/quality-tiers.md`.
  - Acceptance: artifact contains `Timestamp:`, `Policy Order:`, and the explicit list of files read. One binary outcome: file exists with all three fields populated.

- [x] [P0-T2] Capture baseline format state and write evidence to `docs/features/active/2026-06-16-pre-claude-session-script-189/evidence/baseline/baseline-format.md`
  - Command (run from `extensions/drm-copilot`): `npm run format`
  - Acceptance: artifact contains `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:`. One binary outcome: artifact present with all four fields.

- [x] [P0-T3] Capture baseline lint state and write evidence to `docs/features/active/2026-06-16-pre-claude-session-script-189/evidence/baseline/baseline-lint.md`
  - Command (run from `extensions/drm-copilot`): `npm run lint`
  - Acceptance: artifact contains `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:` (record lint error/warning counts).

- [x] [P0-T4] Capture baseline type-check state and write evidence to `docs/features/active/2026-06-16-pre-claude-session-script-189/evidence/baseline/baseline-typecheck.md`
  - Command (run from `extensions/drm-copilot`): `npm run typecheck`
  - Acceptance: artifact contains `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:`.

- [x] [P0-T5] Capture baseline test-and-coverage state and write evidence to `docs/features/active/2026-06-16-pre-claude-session-script-189/evidence/baseline/baseline-test-coverage.md`
  - Command (run from `extensions/drm-copilot`): `node run-jest.cjs --coverage`
  - Acceptance: artifact contains `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:`. `Output Summary:` MUST record numeric baseline line-coverage and branch-coverage headline values and the passed/total test count. If `--coverage` is not wired into `run-jest.cjs`, record the exact invocation used and the numeric coverage values it reports; the baseline is incomplete without numeric coverage values.

### Phase 1 — Pure Builder: preClaude command (AC1-AC4)

- [x] [P1-T1] Extend `WorktreeSessionCommandInput` with `preClaudeScriptPath` in `extensions/drm-copilot/src/claude-worktree-session.ts`
  - Add `readonly preClaudeScriptPath: string | undefined;` to the `WorktreeSessionCommandInput` interface, with a doc comment describing it as the worktree-relative pre-`claude` script path.
  - Acceptance: interface declares the new field; module still imports none of `vscode`, `node:child_process`, `node:fs`. One binary outcome: type compiles.
  - Maps to: AC1.

- [x] [P1-T2] Extend `WorktreeSessionCommands` with `preClaude` in `extensions/drm-copilot/src/claude-worktree-session.ts`
  - Add `readonly preClaude: string | undefined;` to the `WorktreeSessionCommands` interface, with a doc comment stating it is present only when a non-empty path is supplied and `undefined` otherwise.
  - Acceptance: interface declares the new field. One binary outcome: type compiles.
  - Maps to: AC1, AC2.

- [x] [P1-T3] Implement the guarded `preClaude` command in `buildWorktreeSessionCommands` in `extensions/drm-copilot/src/claude-worktree-session.ts`
  - Compute `const trimmedPreClaudePath = input.preClaudeScriptPath?.trim() ?? "";`. When `trimmedPreClaudePath.length > 0`, set `const quotedPreClaude = quoteForPwsh(trimmedPreClaudePath);` and `preClaude = `if (Test-Path -LiteralPath ${quotedPreClaude}) { & ${quotedPreClaude} }``. When the length is 0, set `preClaude = undefined`.
  - Add `preClaude` to the returned object. Do not change `git`, `setLocation`, `poetryInstall`, `activate`, or `claude`.
  - Acceptance: for a normal path the returned `preClaude` equals `if (Test-Path -LiteralPath '<path>') { & '<path>' }`; for undefined/empty/whitespace `preClaude === undefined`; path quoting uses `quoteForPwsh`. One binary outcome verified by P1-T4 tests.
  - Maps to: AC1, AC2, AC3, AC4.

- [x] [P1-T4] Add builder unit tests in `extensions/drm-copilot/test/claude-worktree-session.test.ts`
  - Add `preClaudeScriptPath: undefined` to the shared `baseInput` (or supply it per-case) so existing cases keep compiling.
  - Add cases asserting: (a) `preClaude` is `undefined` when `preClaudeScriptPath` is `undefined`; (b) `preClaude` is `undefined` for `""`; (c) `preClaude` is `undefined` for whitespace-only `"   "`; (d) for a normal path `".claude/hooks/pre-claude-session.ps1"` the command equals `if (Test-Path -LiteralPath '.claude/hooks/pre-claude-session.ps1') { & '.claude/hooks/pre-claude-session.ps1' }`; (e) for a path with spaces and an apostrophe (for example `"C:/o'connor dir/pre.ps1"`) the quoting doubles the apostrophe and preserves the space inside both the `Test-Path` and `&` positions.
  - Use Arrange-Act-Assert with `@jest/globals` imports already present in the file.
  - Acceptance: the five new cases exist and assert the exact strings above. One binary outcome: tests present and passing after P1-T5.
  - Maps to: AC1, AC2, AC3, AC4, AC8.

- [x] [P1-T5] Run the TypeScript toolchain loop after the Phase 1 source/test changes (from `extensions/drm-copilot`)
  - Run in order: `npm run format` -> `npm run lint` -> `npm run typecheck` -> `node run-jest.cjs`. If any step changes files or fails, restart from `npm run format`.
  - Acceptance: all four commands exit 0 in a single pass and the new builder tests pass. One binary outcome: clean single-pass loop.
  - Maps to: AC8.

### Phase 2 — Handler: configuration read and command ordering (AC5-AC6)

- [x] [P2-T1] Extend the `vscode` mock in `extensions/drm-copilot/test/extension-test-harness.ts` with `workspace.getConfiguration`
  - Add a `getConfigurationMock` (`jest.fn`) returning an object with a typed `get` method, and expose a helper `setPreClaudeScriptPathConfig(value: string | undefined): void` that controls what `get<string>("preClaudeScriptPath")` returns for section `"drmCopilotExtension.newClaudeWorktreeSession"`. Default the helper to `undefined` (unset) and reset it in `resetExtensionHarnessState`.
  - Export the new helper (and the mock if needed by assertions) alongside the existing exports.
  - Acceptance: the handler can call `vscode.workspace.getConfiguration("drmCopilotExtension.newClaudeWorktreeSession").get<string>("preClaudeScriptPath")` under test without throwing, and tests can set/clear the returned value. One binary outcome: helper present, wired into reset, exported.
  - Maps to: AC5, AC8.

- [x] [P2-T2] Read the configuration and pass `preClaudeScriptPath` into the builder in `extensions/drm-copilot/src/extension.ts`
  - In the `newClaudeWorktreeSession` handler, after `usePoetry` is computed and before `buildWorktreeSessionCommands` is called, read `const configuredPreClaudeScriptPath = vscode.workspace.getConfiguration("drmCopilotExtension.newClaudeWorktreeSession").get<string>("preClaudeScriptPath") ?? ".claude/hooks/pre-claude-session.ps1";`.
  - Pass `preClaudeScriptPath: configuredPreClaudeScriptPath` into the `buildWorktreeSessionCommands(...)` input object.
  - Acceptance: the default `.claude/hooks/pre-claude-session.ps1` is applied when the setting is `undefined`; a configured value is passed through verbatim. One binary outcome verified by P2-T5 tests.
  - Maps to: AC5.

- [x] [P2-T3] Send `commands.preClaude` after activate and before the deferred `claude` send in `extensions/drm-copilot/src/extension.ts`
  - After the `if (commands.activate !== undefined) { terminal.sendText(commands.activate, true); }` block and before the `setTimeout(...)` that sends `commands.claude`, add `if (commands.preClaude !== undefined) { terminal.sendText(commands.preClaude, true); }`.
  - Do not alter the deferral of `commands.claude` or the `TERMINAL_AUTO_ACTIVATION_GRACE_MS` timing.
  - Acceptance: when `commands.preClaude` is defined exactly one extra synchronous `sendText` fires after activate and before the deferred claude; when `undefined` no extra `sendText` fires. One binary outcome verified by P2-T5 tests.
  - Maps to: AC6.

- [x] [P2-T4] Extend the output-channel log line to indicate whether a pre-`claude` script command was emitted in `extensions/drm-copilot/src/extension.ts`
  - Add a note to the existing `output.appendLine(...)` call (the one beginning `[${commandId}] opened terminal for branch ...`) indicating whether a pre-`claude` script command was emitted (for example append `, pre-claude script: emitted` or `, pre-claude script: none` based on `commands.preClaude !== undefined`). Do not log script file content beyond the already-configured path value if included.
  - Acceptance: the single existing log line is extended with the pre-`claude` emission state; no new sensitive content is logged. One binary outcome: log line contains the emission indicator.
  - Maps to: AC6 (logging note from spec Implementation Strategy).

- [x] [P2-T5] Add handler unit tests in `extensions/drm-copilot/test/extension.workflow-commands.test.ts`
  - Add cases (using `jest.useFakeTimers()` consistent with existing worktree-session tests):
    - (a) Default applied when unset: with the config helper unset (default `undefined`), assert the `preClaude` `sendText` value equals `if (Test-Path -LiteralPath '.claude/hooks/pre-claude-session.ps1') { & '.claude/hooks/pre-claude-session.ps1' }`.
    - (b) Ordering with poetry: set a poetry pyproject fixture and a configured path; assert `sendText` call order is git, Set-Location, poetry install, activate, preClaude (all synchronous), then after `jest.advanceTimersByTime(5000)` the deferred claude; assert the preClaude call index is immediately after activate and the claude call is last.
    - (c) Ordering without poetry: no pyproject fixture, configured path set; assert synchronous order git, Set-Location, preClaude, then deferred claude after timer advance.
    - (d) No extra send when `preClaude` is undefined: set the config helper to `""` (empty) so the builder yields `preClaude === undefined`; assert the synchronous `sendText` count matches the existing no-poetry baseline (git, Set-Location only) and that after timer advance only the claude send is added (no preClaude send).
  - Acceptance: the four cases exist and assert ordering and presence/absence as described. One binary outcome: tests present and passing after P2-T6.
  - Maps to: AC5, AC6, AC8.

- [x] [P2-T6] Run the TypeScript toolchain loop after the Phase 2 source/test/harness changes (from `extensions/drm-copilot`)
  - Run in order: `npm run format` -> `npm run lint` -> `npm run typecheck` -> `node run-jest.cjs`. If any step changes files or fails, restart from `npm run format`.
  - Acceptance: all four commands exit 0 in a single pass; new handler tests pass. One binary outcome: clean single-pass loop.
  - Maps to: AC8.

### Phase 3 — Manifest Configuration Contribution (AC7)

- [x] [P3-T1] Add the `contributes.configuration` block in `extensions/drm-copilot/package.json`
  - Add a `configuration` key inside the existing `contributes` object (preserving `mcpServerDefinitionProviders` and `commands`). Declare a `properties` entry `drmCopilotExtension.newClaudeWorktreeSession.preClaudeScriptPath` with `"type": "string"`, `"default": ".claude/hooks/pre-claude-session.ps1"`, and a `description` stating it is the worktree-relative path to a PowerShell script run immediately before `claude`, that the path is resolved relative to the worktree root, and that a missing script at that path is not an error.
  - Acceptance: `package.json` remains valid JSON; the new property is present with the exact type, default, and a clear description; existing `contributes` keys are unchanged. One binary outcome: JSON parses and contains the property.
  - Maps to: AC7.

- [x] [P3-T2] Run formatting on the manifest in `extensions/drm-copilot`
  - Command: `npm run format` (the `format` script globs `*.json`).
  - Acceptance: `npm run format` exits 0 and `package.json` is unchanged in semantics. One binary outcome: command exits 0.
  - Maps to: AC7, AC8.

### Phase 4 — Final QA Loop and Coverage Evidence (AC8)

- [x] [P4-T1] Run final format check and write evidence to `docs/features/active/2026-06-16-pre-claude-session-script-189/evidence/qa-gates/final-format.md`
  - Command (from `extensions/drm-copilot`): `npm run format`
  - Acceptance: artifact contains `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:`; `EXIT_CODE` is 0. If this step changes files, restart the loop at this task before proceeding.

- [x] [P4-T2] Run final lint and write evidence to `docs/features/active/2026-06-16-pre-claude-session-script-189/evidence/qa-gates/final-lint.md`
  - Command (from `extensions/drm-copilot`): `npm run lint`
  - Acceptance: artifact contains `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:` (record 0 errors); `EXIT_CODE` is 0.

- [x] [P4-T3] Run final type-check and write evidence to `docs/features/active/2026-06-16-pre-claude-session-script-189/evidence/qa-gates/final-typecheck.md`
  - Command (from `extensions/drm-copilot`): `npm run typecheck`
  - Acceptance: artifact contains `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:`; `EXIT_CODE` is 0.

- [x] [P4-T4] Run final test-with-coverage and write evidence to `docs/features/active/2026-06-16-pre-claude-session-script-189/evidence/qa-gates/final-test-coverage.md`
  - Command (from `extensions/drm-copilot`): `node run-jest.cjs --coverage`
  - Acceptance: artifact contains `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:`; `EXIT_CODE` is 0. `Output Summary:` MUST record numeric post-change line-coverage and branch-coverage values and the passed/total test count.

- [x] [P4-T5] Verify coverage thresholds and no-regression on changed lines; write evidence to `docs/features/active/2026-06-16-pre-claude-session-script-189/evidence/qa-gates/coverage-delta.md`
  - Compare baseline (P0-T5) against post-change (P4-T4): record baseline line/branch coverage, post-change line/branch coverage, and coverage for the changed lines in `claude-worktree-session.ts` and `extension.ts`.
  - Acceptance: artifact records baseline coverage, post-change coverage, and new/changed-code coverage; confirms line >= 85%, branch >= 75%, and no regression on changed lines. If any required coverage value is unavailable, the outcome is remediation-required, not PASS. One binary outcome: thresholds met and recorded, or remediation flagged.
  - Maps to: AC8.

## AC-to-Task Traceability

- AC1: P1-T1, P1-T2, P1-T3, P1-T4.
- AC2: P1-T2, P1-T3, P1-T4.
- AC3: P1-T3, P1-T4.
- AC4: P1-T3, P1-T4.
- AC5: P2-T1, P2-T2, P2-T5.
- AC6: P2-T3, P2-T4, P2-T5.
- AC7: P3-T1, P3-T2.
- AC8: P1-T4, P1-T5, P2-T5, P2-T6, P3-T2, P4-T1, P4-T2, P4-T3, P4-T4, P4-T5.

## Test Plan

- Unit (builder): `extensions/drm-copilot/test/claude-worktree-session.test.ts` — `preClaude` undefined for undefined/empty/whitespace; guarded command for a normal path; quote escaping for spaces and apostrophes.
- Unit (handler): `extensions/drm-copilot/test/extension.workflow-commands.test.ts` — configuration default applied when unset; ordering with and without poetry (preClaude after activate, before deferred claude); no extra send when `preClaude` undefined.
- Harness: `extensions/drm-copilot/test/extension-test-harness.ts` — `workspace.getConfiguration` mock and `setPreClaudeScriptPathConfig` helper.
- Integration: none (no external systems; runtime existence check is a PowerShell `Test-Path` executed by the terminal, not exercised in unit tests).
- Coverage evidence:
  - Baseline: `docs/features/active/2026-06-16-pre-claude-session-script-189/evidence/baseline/baseline-test-coverage.md`.
  - Post-change: `docs/features/active/2026-06-16-pre-claude-session-script-189/evidence/qa-gates/final-test-coverage.md`.
  - Delta/threshold: `docs/features/active/2026-06-16-pre-claude-session-script-189/evidence/qa-gates/coverage-delta.md`.

## Open Questions / Notes

- The pure module `claude-worktree-session.ts` must remain side-effect free; the missing-script guard is implemented as a runtime PowerShell `Test-Path` check, not a TypeScript filesystem call.
- The handler reads configuration via `vscode.workspace.getConfiguration("drmCopilotExtension.newClaudeWorktreeSession").get<string>("preClaudeScriptPath")` with a TypeScript-side default of `.claude/hooks/pre-claude-session.ps1`; `package.json` declares the same default so VS Code returns it when unset. The TypeScript-side `?? "..."` default also covers the test harness path where `getConfiguration` may return `undefined`.
- If `node run-jest.cjs` does not accept `--coverage`, record the actual coverage invocation supported by `run-jest.cjs` in the baseline and final-QC artifacts; numeric coverage values remain mandatory.
