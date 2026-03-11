# Atomic Implementation Plan — expose-commit-script (#74)

## Overview
This plan delivers extension-side commit-context collection for the destination workspace by adding a new scaffold-extension command that executes a bundled Python collector with destination-repo `cwd` semantics and writes `artifacts/commit_context.txt`. The plan is full-mode (`Work Mode: full`) and includes mandatory policy-read evidence, baseline capture, implementation, scenario-based tests, documentation updates, and a restart-aware final QA loop.

### Phase 0 — Context & Inputs
- [x] [P0-T1] Confirm full-mode inputs from feature documents and persist a requirements evidence artifact.
  - Preconditions: `issue.md`, `user-story.md`, `spec.md`, and `research.2026-03-03T20-12.md` exist in the feature folder.
  - Acceptance: `docs/features/active/2026-03-03-expose-commit-script-74/evidence/other/phase0-requirements-read.2026-03-03T21-15.md` exists and contains exact lines for `Timestamp:`, `Work Mode: full`, and the four source file paths.
- [x] [P0-T2] Read mandatory policy files in required order and persist policy-read evidence.
  - Preconditions: policy files are present under `.github/instructions/` and `.github/copilot-instructions.md`.
  - Acceptance: `docs/features/active/2026-03-03-expose-commit-script-74/evidence/baseline/phase0-instructions-read.2026-03-03T21-15.md` exists and contains `Timestamp:`, `Policy Order:`, and an ordered list including: `.github/copilot-instructions.md`, `.github/instructions/general-code-change.instructions.md`, `.github/instructions/general-unit-test.instructions.md`, `.github/instructions/typescript-code-change.instructions.md`, `.github/instructions/typescript-unit-test.instructions.md`, `.github/instructions/typescript-suppressions.instructions.md`.
- [x] [P0-T3] Create canonical feature evidence directories for baseline, regression, QA, and other artifacts.
  - Preconditions: feature folder exists.
  - Acceptance: directories exist at `evidence/baseline/`, `evidence/regression-testing/`, `evidence/qa-gates/`, and `evidence/other/` under `docs/features/active/2026-03-03-expose-commit-script-74/`.
- [x] [P0-T4] Capture extension baseline formatting state using a non-mutating Prettier check command.
  - Preconditions: `npm` dependencies for `extensions/scaffold-extension` are installed.
  - Acceptance: artifact `evidence/baseline/baseline.format-check.2026-03-03T21-15.md` exists with exact fields `Timestamp:`, `Command: npm --prefix extensions/scaffold-extension exec -- prettier --check "src/**/*.ts" "test/**/*.ts" "*.json" "*.cjs"`, `EXIT_CODE: <int>`, and `Output Summary:`.
- [x] [P0-T5] Capture extension baseline lint state.
  - Preconditions: none beyond [P0-T4].
  - Acceptance: artifact `evidence/baseline/baseline.lint.2026-03-03T21-15.md` exists with exact fields `Timestamp:`, `Command: npm --prefix extensions/scaffold-extension run lint`, `EXIT_CODE: <int>`, and `Output Summary:`.
- [x] [P0-T6] Capture extension baseline type-check state.
  - Preconditions: none beyond [P0-T4].
  - Acceptance: artifact `evidence/baseline/baseline.typecheck.2026-03-03T21-15.md` exists with exact fields `Timestamp:`, `Command: npm --prefix extensions/scaffold-extension run typecheck`, `EXIT_CODE: <int>`, and `Output Summary:`.
- [x] [P0-T7] Capture extension baseline test state.
  - Preconditions: none beyond [P0-T4].
  - Acceptance: artifact `evidence/baseline/baseline.test.2026-03-03T21-15.md` exists with exact fields `Timestamp:`, `Command: npm --prefix extensions/scaffold-extension run test`, `EXIT_CODE: <int>`, and `Output Summary:`.

### Phase 1 — Extension Command Surface & Bundled Collector Wiring
- [x] [P1-T1] Add `drmCopilotExtension.collectCommitContext` to extension command contributions in `extensions/scaffold-extension/package.json`.
  - Preconditions: `contributes.commands` currently includes hello commands.
  - Acceptance: `extensions/scaffold-extension/package.json` contains a command object with exact `"command": "drmCopilotExtension.collectCommitContext"` and title `"Scaffold: Collect Commit Context"`.
- [x] [P1-T2] Add bundled collector script resource for extension-side execution at `extensions/scaffold-extension/resources/templates/collect_commit_context.py`.
  - Preconditions: canonical source exists at `scripts/dev_tools/collect_commit_context.py`.
  - Acceptance: target resource file exists and includes the CLI argument contract line containing `--output` and default `artifacts/commit_context.txt`.
- [x] [P1-T3] Extend `CommandSpec` in `extensions/scaffold-extension/src/extension.ts` to support explicit script arguments for command-specific output contracts.
  - Preconditions: `CommandSpec` currently contains runtime kind, bundled path, and command ID.
  - Acceptance: `CommandSpec` includes a typed readonly args field and TypeScript compile succeeds for `extension.ts` usage sites.
- [x] [P1-T4] Update bundled script execution assembly in `executeBundledScript` to append command-specific script arguments after script path.
  - Preconditions: [P1-T3] complete.
  - Acceptance: the runtime args construction in `extension.ts` builds `[...runtime.argsPrefix, scriptPath, ...specScriptArgs]` semantics and existing hello command handlers still compile.
- [x] [P1-T5] Register the new command handler in `activate` using Python runtime, bundled collector path, and explicit output argument `--output artifacts/commit_context.txt`.
  - Preconditions: [P1-T1], [P1-T2], [P1-T4] complete.
  - Acceptance: `activate` registers `drmCopilotExtension.collectCommitContext` and passes `runtimeKind: "python"`, `bundledRelativePath: "resources/templates/collect_commit_context.py"`, and script args containing exactly `"--output"` and `"artifacts/commit_context.txt"`.

### Phase 2 — Destination Workspace Execution Semantics & Diagnostics
- [x] [P2-T1] Ensure command execution enforces destination-workspace root discovery before runtime probe and returns actionable no-workspace errors.
  - Preconditions: [P1-T5] complete.
  - Acceptance: invoking handler with `vscode.workspace.workspaceFolders` undefined/empty rejects with exact message `No workspace folder is open.` and test assertions can match this string.
- [x] [P2-T2] Ensure subprocess spawn options for commit-context command preserve destination workspace `cwd` and `shell: false`.
  - Preconditions: [P1-T5] complete.
  - Acceptance: spawn call for `drmCopilotExtension.collectCommitContext` includes options where `cwd` equals the selected workspace root path and `shell` is exactly `false`.
- [x] [P2-T3] Add command-scoped output-channel lifecycle lines for start/success/failure diagnostics for the new command path.
  - Preconditions: [P1-T5] complete.
  - Acceptance: output logging includes command-scoped lines with exact prefix `[drmCopilotExtension.collectCommitContext]` for runtime probe start/success/failure and command start/success/failure.

### Phase 3 — Deterministic Test Additions (Scenario-by-Scenario)
- [x] [P3-T1] Add unit test in `extensions/scaffold-extension/test/extension.test.ts` for `activate` registering `drmCopilotExtension.collectCommitContext`.
  - Preconditions: [P1-T1], [P1-T5] complete.
  - Acceptance: test file contains a test case whose assertion checks the command handler map includes key `drmCopilotExtension.collectCommitContext` and `npm --prefix extensions/scaffold-extension run test -- --runInBand extension.test.ts -t "registers collectCommitContext"` exits 0.
- [x] [P3-T2] Add unit test in `extensions/scaffold-extension/test/extension.test.ts` for no-workspace scenario of `collectCommitContext` handler.
  - Preconditions: [P2-T1] complete.
  - Acceptance: targeted test command `npm --prefix extensions/scaffold-extension run test -- --runInBand extension.test.ts -t "collectCommitContext fails when no workspace folder is open"` exits 0 and asserts rejection message `No workspace folder is open.`.
- [x] [P3-T3] Add unit test in `extensions/scaffold-extension/test/extension.test.ts` verifying runtime resolution failure surfaces for `collectCommitContext` when Python is unavailable.
  - Preconditions: [P1-T5] complete.
  - Acceptance: targeted test command `npm --prefix extensions/scaffold-extension run test -- --runInBand extension.test.ts -t "collectCommitContext fails when python runtime is unavailable"` exits 0 and assertion matches `Python runtime 'python' not found on PATH.`.
- [x] [P3-T4] Add unit test in `extensions/scaffold-extension/test/extension.test.ts` verifying spawn argv includes bundled collector path plus `--output artifacts/commit_context.txt`.
  - Preconditions: [P1-T5] complete.
  - Acceptance: targeted test command `npm --prefix extensions/scaffold-extension run test -- --runInBand extension.test.ts -t "collectCommitContext passes explicit output args to bundled script"` exits 0 and assertion checks exact arg tokens.
- [x] [P3-T5] Add unit test in `extensions/scaffold-extension/test/extension.test.ts` verifying spawn `cwd` equals destination workspace root for `collectCommitContext`.
  - Preconditions: [P2-T2] complete.
  - Acceptance: targeted test command `npm --prefix extensions/scaffold-extension run test -- --runInBand extension.test.ts -t "collectCommitContext runs with workspace cwd"` exits 0 and assertion checks `cwd === "C:/workspace"` in mocked call.
- [x] [P3-T6] Add unit test in `extensions/scaffold-extension/test/extension.test.ts` verifying non-zero collector exit is surfaced as command failure and command-scoped failure log line is emitted.
  - Preconditions: [P2-T3] complete.
  - Acceptance: targeted test command `npm --prefix extensions/scaffold-extension run test -- --runInBand extension.test.ts -t "collectCommitContext logs and throws on non-zero exit"` exits 0 and assertion checks both thrown message `Command exited with code` and appended failure prefix.
- [x] [P3-T7] Add integration-style test in `extensions/scaffold-extension/test/extension.integration.test.ts` verifying bundled-script path resolution targets extension resources (not workspace root) with cross-platform-safe assertions.
  - Preconditions: [P1-T2], [P1-T5] complete.
  - Acceptance: targeted test command `npm --prefix extensions/scaffold-extension run test -- --runInBand extension.integration.test.ts -t "collectCommitContext executes bundled resource without workspace script copy"` exits 0 and assertion normalizes separators before verifying the script argument starts with the extension resource root and ends with `/resources/templates/collect_commit_context.py`, while also asserting it does not start with the workspace root path.
- [x] [P3-T8] Add unit test in `extensions/scaffold-extension/test/extension.test.ts` verifying Git-failure stderr from collector execution is surfaced as command failure context.
  - Preconditions: [P2-T3] complete.
  - Acceptance: targeted test command `npm --prefix extensions/scaffold-extension run test -- --runInBand extension.test.ts -t "collectCommitContext reports git failure details from collector stderr"` exits 0 and assertion checks thrown error or logged failure context includes a git failure marker from mocked stderr.
- [x] [P3-T9] Add integration-style test in `extensions/scaffold-extension/test/extension.integration.test.ts` validating required commit-context artifact sections are present when staged changes exist.
  - Preconditions: [P1-T5] complete.
  - Acceptance: targeted test command `npm --prefix extensions/scaffold-extension run test -- --runInBand extension.integration.test.ts -t "collectCommitContext artifact includes required sections for staged changes"` exits 0 and assertion verifies the generated artifact text contains each required section header exactly once for the staged-changes scenario.
- [x] [P3-T10] Add integration-style test in `extensions/scaffold-extension/test/extension.integration.test.ts` validating explicit `(no staged changes)` marker emission when no staged diff exists.
  - Preconditions: [P1-T5] complete.
  - Acceptance: targeted test command `npm --prefix extensions/scaffold-extension run test -- --runInBand extension.integration.test.ts -t "collectCommitContext artifact marks no staged changes"` exits 0 and assertion verifies artifact text contains the literal marker `(no staged changes)` in the staged-changes section.

### Phase 4 — Documentation & Feature Evidence Updates
- [x] [P4-T1] Update `extensions/scaffold-extension/README.md` with the new Command Palette action, destination output artifact contract, and workspace requirement.
  - Preconditions: [P1-T5], [P2-T1] complete.
  - Acceptance: README contains command ID `drmCopilotExtension.collectCommitContext`, path `artifacts/commit_context.txt`, and explicit statement that command requires an open workspace.
- [x] [P4-T2] Update feature docs checklists (`issue.md` and/or `spec.md`) to reflect implemented command/test coverage evidence links.
  - Preconditions: implementation and test tasks complete.
  - Acceptance: updated feature markdown includes links to at least one baseline artifact and one QA artifact under `evidence/` and marks corresponding acceptance/DoD items complete.

### Phase 5 — Final QC Loop (Format → Lint → Type-Check → Test)
- [x] [P5-T1] Execute formatting command for scaffold-extension and capture QA artifact for pass attempt 1.
  - Preconditions: Phases 1–4 complete.
  - Acceptance: `evidence/qa-gates/final-qc.pass1.format.2026-03-03T21-15.md` exists with `Timestamp:`, `Command: npm --prefix extensions/scaffold-extension run format`, `EXIT_CODE: <int>`, `Output Summary:`, and `FILES_CHANGED: yes|no`.
- [x] [P5-T2] Execute lint command for scaffold-extension and capture QA artifact for pass attempt 1.
  - Preconditions: [P5-T1] complete.
  - Acceptance: `evidence/qa-gates/final-qc.pass1.lint.2026-03-03T21-15.md` exists with `Timestamp:`, `Command: npm --prefix extensions/scaffold-extension run lint`, `EXIT_CODE: <int>`, and `Output Summary:`.
- [x] [P5-T3] Execute type-check command for scaffold-extension and capture QA artifact for pass attempt 1.
  - Preconditions: [P5-T2] complete.
  - Acceptance: `evidence/qa-gates/final-qc.pass1.typecheck.2026-03-03T21-15.md` exists with `Timestamp:`, `Command: npm --prefix extensions/scaffold-extension run typecheck`, `EXIT_CODE: <int>`, and `Output Summary:`.
- [x] [P5-T4] Execute test command for scaffold-extension and capture QA artifact for pass attempt 1.
  - Preconditions: [P5-T3] complete.
  - Acceptance: `evidence/qa-gates/final-qc.pass1.test.2026-03-03T21-15.md` exists with `Timestamp:`, `Command: npm --prefix extensions/scaffold-extension run test`, `EXIT_CODE: <int>`, and `Output Summary:`.
- [x] [P5-T5] Enforce restart semantics by repeating [P5-T1] through [P5-T4] with incremented pass numbers until a clean quartet exists.
  - Preconditions: [P5-T1]–[P5-T4] complete for at least one pass.
  - Acceptance: `evidence/qa-gates/final-qc.summary.2026-03-03T21-15.md` exists and contains `Final Passing Pass: <N>`, a machine-checkable line `No SKIPPED Steps: true`, and a machine-checkable statement that in pass `<N>` each command artifact records integer `EXIT_CODE: 0` and the format artifact records `FILES_CHANGED: no`; if pass 1 is not clean, summary lists additional pass artifact filenames.

### Phase 6 — Completion Handoff
- [x] [P6-T1] Produce implementation handoff note in feature evidence with completed-task mapping and unresolved risks.
  - Preconditions: [P5-T5] complete.
  - Acceptance: `evidence/other/implementation-handoff.2026-03-03T21-15.md` exists and contains sections `Completed Tasks:`, `QA Gate Result:`, and `Open Risks:`.
- [x] [P6-T2] Record executor preflight validation outcome for this revised plan and persist any required revision delta artifact.
  - Preconditions: revised plan file exists.
  - Acceptance: preflight outcome evidence exists at `evidence/other/preflight.outcome.2026-03-03T21-15.md` with exact line `PREFLIGHT: ALL CLEAR`; if outcome is `PREFLIGHT: REVISIONS REQUIRED`, file includes `Required Deltas:` and references `evidence/other/preflight-revisions.2026-03-03T21-15.md`.
