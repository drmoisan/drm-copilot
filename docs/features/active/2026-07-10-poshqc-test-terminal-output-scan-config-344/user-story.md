# `poshqc-test-terminal-output-scan-config` — User Story

- Issue: #344
- Owner: drmoisan
- Status: Ready for Planning
- Last Updated: 2026-07-10
- Spec: [`spec.md`](spec.md) (normative requirement definitions; AC IDs shared)

## Story Statement

- As a repository developer running PoshQC tests from the VS Code command palette, I want the
  command's Pester output to stream into the integrated terminal, so that the command presents
  results the same way the local `PoshQC: 4 test (Pester)` task does and I can watch progress
  live without opening the OutputChannel.
- As a repository developer, I want the command's "Scan entire workspace" option to discover
  the same test set as the local Pester task, so that a passing command run and a passing task
  run mean the same thing.
- As a repository developer, I want the included test-scan folders recorded in a persisted,
  user-editable configuration file consumed by the task, the command, and the MCP tool alike,
  so that all surfaces share one scan contract that survives restarts and is reviewable in
  diffs.
- As a repository developer, I want to select and deselect scan folders interactively with a
  checkbox-style multi-select seeded from my saved configuration, so that adjusting the scan
  set does not require a native OS dialog or hand-editing JSON.

## Problem / Why

The `drm-copilot: Run PoshQC Test` command writes its Pester output to the extension
OutputChannel window rather than the integrated terminal, which is inconsistent with how
the local `PoshQC: 4 test (Pester)` task presents results. In addition, the set of folders
scanned by the command's "Scan entire workspace" option can diverge from the folders covered by
the local task, which invokes `Invoke-PoshQCTest -Root '${workspaceFolder}'` against the
workspace module while the command runs a bundled module snapshot whose manifest and settings
files are not locked by the parity gate and have drifted. There is currently no persisted,
user-editable configuration that records which folders are included in the test scan, and the
command's folder-selection flow uses a native OS folder picker rather than an interactive
select/deselect experience for folders and subfolders.

## Personas & Scenarios

- Persona: **Repository developer / maintainer (primary)**
  - Works in VS Code on this repository; runs PoshQC quality gates frequently via both the
    command palette and `.vscode/tasks.json` tasks.
  - Cares about consistent results between the command, the task, and the MCP tool, and about
    fast feedback (live-streaming output, correct exit codes).
  - Constraints: relies on `CommandExecutionError` / `getStderrExcerpt` failure surfaces
    downstream; expects config changes to be reviewable in git diffs.
  - Frustrations today: output hidden in the OutputChannel; command scan coverage silently
    differing from the task; folder selection through a native dialog with no memory.
- Persona: **Automation agent via MCP (secondary)**
  - Invokes `run_poshqc_test` through the MCP server with a buffered output sink.
  - Cares about an unchanged request/response contract; benefits from the shared config when
    it omits `scan_folders`.

- Scenario: **Run with terminal output (default scope)**
  - The developer invokes `drm-copilot: Run PoshQC Test`, picks "Scan entire workspace".
  - A terminal named `drm-copilot: PoshQC` is revealed and streams Pester output live; the
    OutputChannel receives the same log. The scan set comes from `config/poshqc-scan.json`
    (or `Run.Path` defaults when the file is absent).
  - On failure, the terminal shows the failing output in place and the command surfaces the
    same error excerpt as before.
- Scenario: **Adjust the scan set interactively**
  - The developer invokes the command, picks "Select folders to scan".
  - A multi-select QuickPick lists workspace folders and subfolders (depth 2, standard
    directories excluded), with folders from the saved config pre-checked; a saved folder that
    no longer exists is shown with a warning marker.
  - The developer unchecks one folder and confirms. The selection is written back to
    `config/poshqc-scan.json` first, then the run starts with exactly the selected folders.
  - If the developer cancels, nothing is persisted and nothing runs. If the developer confirms
    an empty selection, an information message explains why nothing runs and the saved config
    is left untouched.
- Scenario: **Task/command parity**
  - The developer runs the local task `PoshQC: 4 test (Pester)` and then the command's
    workspace scan at the same commit; both discover the same test set, because both resolve
    folders from the same config through the same module logic and the bundled manifest and
    settings copies are parity-locked.

## Acceptance Criteria

Shared AC set with [`spec.md`](spec.md); the spec holds the normative definitions and the
functional-requirement mapping. IDs AC1–AC16 are stable for downstream tracking.

- [x] AC1 (Cap 1): Invoking `drm-copilot: Run PoshQC Test` from the command palette streams
      every sink output line into an integrated terminal with a stable name, reveals that
      terminal at command start, and the `OutputChannel` receives the identical line stream.
      Verified by Jest tests asserting terminal creation/reveal and dual-sink forwarding.
- [x] AC2 (Cap 2): At the same commit, the command's "Scan entire workspace" path and the
      local task `PoshQC: 4 test (Pester)` discover the same Pester test set; the bundled
      `PoshQC.psd1` and `settings/*.psd1` are byte-identical to the workspace copies (no
      `RequiredModules`, no `CodeCoverage.ExcludedPath`, current coverage list). Verified by
      the extended parity gate passing and a recorded JUnit-diff comparison.
- [x] AC3 (Cap 3): `config/poshqc-scan.json` exists with `version: 1` and seeded
      `test.scanFolders` of `["scripts", "tests/powershell", "tests/scripts"]`, and
      `Invoke-PoshQCTest` without `-ScanFolders` resolves its scan set from this file via
      `Get-PoshQCScanConfigFolder`. Verified by Pester seam-injection tests.
- [x] AC4 (Cap 4): Choosing `"Select folders to scan"` in the test command opens a
      `canPickMany` QuickPick (replacing `showOpenDialog` in this flow) whose items are
      workspace-relative paths seeded `picked` from the config, and an accepted non-empty
      selection is persisted back to the config before the run and passed as the run's scan
      folders. Verified by Jest picker tests including a persistence round-trip.
- [x] AC5 (Cap 1): A non-zero child exit on the command path still rejects with
      `CommandExecutionError` carrying `exitCode`, full `stdout`, and full `stderr`, and
      `getStderrExcerpt` output is unchanged. Verified by a Jest test with a mocked process
      exiting 1 while the terminal tee is active.
- [x] AC6 (Cap 1): The MCP `run_poshqc_test` path creates no terminal and continues to use the
      buffered output sink. Verified by a Jest test on the MCP dispatch path.
- [x] AC7 (Cap 2): Baseline evidence — a JUnit/discovered-set diff of task vs command
      invocations against the same worktree, plus the empirical
      `New-PesterConfiguration -Hashtable` result for the `CodeCoverage.ExcludedPath` key — is
      recorded under
      `docs/features/active/2026-07-10-poshqc-test-terminal-output-scan-config-344/evidence/baseline/`.
- [x] AC8 (Cap 3): Config validation fails fast with an error naming the file for: malformed
      JSON, `version` other than `1`, a blank entry, an absolute-path entry, or an entry
      containing `..`. Verified in both Pester (injected `$ReadContent`) and Jest (in-memory
      `FileSystem`) tests.
- [x] AC9 (Cap 3): A config-sourced folder that does not exist is skipped with a logged
      warning; if all config-sourced folders are skipped, the run fails fast with a clear
      error; explicitly supplied scan folders retain throw-on-missing behavior. Verified by
      Pester tests.
- [x] AC10 (Cap 3): Scan-folder precedence holds: explicit `-ScanFolders`/`-ScanFoldersJson`
      overrides the config; the config overrides settings `Run.Path`; absent file or empty
      `test.scanFolders` yields `Run.Path` defaults. Verified by Pester seam-injection tests
      on `Invoke-PoshQCTest`.
- [x] AC11 (Cap 3): The TypeScript config module writes canonical content (workspace-relative
      forward-slash paths, deduplicated, sorted) and a read-after-write round-trip is stable.
      Verified by Jest tests against the in-memory `FileSystem`.
- [x] AC12 (Cap 3): MCP `run_poshqc_test` without `scan_folders` resolves the config-driven
      set through the module; explicit `scan_folders` still overrides; the tool description
      strings in both `mcp-tool-definitions.ts` and `mcp-repo-automation-tool-definitions.ts`
      document the config-aware default. No other MCP schema or behavior change.
- [x] AC13 (Cap 4): Cancelling the folder QuickPick (`undefined`) performs no config write and
      no run. Verified by a Jest test.
- [x] AC14 (Cap 4): Accepting an empty selection shows an information message, performs no
      config write, and does not run. Verified by a Jest test.
- [x] AC15 (Cap 4): The picker enumerates workspace subfolders to depth 2 excluding the
      `PoshQC.psm1` default-excluded directory names, and a config-listed folder that no
      longer exists is shown with a warning marker rather than dropped. Verified by Jest tests
      with the in-memory `FileSystem`.
- [x] AC16 (Cross-cutting): After all changes, no production file exceeds 500 lines
      (`extension.ts` and `repo-automation-service.ts` explicitly verified), line coverage is
      >= 85% and branch coverage >= 75% for the changed code, and coverage evidence
      (baseline, post-change, comparison) is recorded under the feature `evidence/` tree.

## Non-Goals

- Changing the MCP `run_poshqc_test` behavior contract beyond convergence on the shared config
  source (schema unchanged; buffered sink unchanged; no terminal on the MCP path).
- Changing branch-protection required checks or CI required-check configuration.
- Migrating `runPoshQCSuite` to the picker/config (optional follow-up).
- Ctrl+C forwarding from the pseudoterminal, ANSI color re-enablement, and a "Browse…" native
  dialog escape hatch (deferred).
- Workspace-first module resolution in the bundled wrappers (optional complement, not required).
