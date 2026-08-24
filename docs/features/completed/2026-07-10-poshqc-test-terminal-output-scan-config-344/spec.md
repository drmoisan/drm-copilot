# poshqc-test-terminal-output-scan-config — Spec

- **Issue:** #344
- **Parent (optional):** none
- **Owner:** drmoisan
- **Last Updated:** 2026-07-10
- **Status:** Ready for Planning
- **Version:** 1.0
- **Work Mode:** full-feature
- **Research basis:** `research/research-findings.md` (same folder); file/line citations in this spec reference that document.

## Overview

### Problem Statement

The `drm-copilot: Run PoshQC Test` command (`drmCopilotExtension.runPoshQCTest`) writes its
Pester output to the extension `OutputChannel` rather than the integrated terminal, which is
inconsistent with how the local task `PoshQC: 4 test (Pester)` presents results. The set of
folders scanned by the command's "Scan entire workspace" option can diverge from the folders
covered by the local task: the task imports the workspace PoshQC module, while the command runs
a bundled module snapshot whose `PoshQC.psd1` and `settings/*.psd1` files are not locked by the
existing parity gate (`tests/scripts/dev_tools/test_poshqc_bundled_parity.py` covers only the
four `.psm1` files) and have demonstrably drifted. There is no persisted, user-editable
configuration recording which folders are included in the test scan, and the command's
folder-selection flow uses a native OS folder picker (`showOpenDialog`) with no seeding and no
persistence.

### Goals

1. **G1 — Terminal output.** Process output of the `Run PoshQC Test` command streams into a
   VS Code integrated terminal, in addition to the existing `OutputChannel`, without changing
   exit-code or failure-reporting semantics.
2. **G2 — Coverage reconciliation.** The command's workspace scan discovers the same test set
   as the local task at the same commit, and the drift class that caused divergence is closed
   permanently by extending the bundled-parity gate.
3. **G3 — Persisted scan configuration.** A repo-local JSON file (`config/poshqc-scan.json`)
   is the single source of the test-scan folder set, consumed identically by the local task,
   the extension command, and the MCP tool through the PoshQC module.
4. **G4 — Interactive folder selection.** The command offers a multi-select QuickPick
   (`canPickMany`) for folders and subfolders, seeded from and written back to the persisted
   configuration, replacing the native OS folder dialog in the test-command flow.

### Non-Goals

- Changing the MCP `run_poshqc_test` behavior contract beyond convergence on the shared config
  source (explicit `scan_folders` continues to override; the buffered output sink is unchanged;
  no terminal is created on the MCP path).
- Changing branch-protection required checks or CI required-check configuration.
- Migrating `runPoshQCSuite` (`extension.ts:384+`, repeated `-ScanFolders` args) to the picker
  or config — optional follow-up, planner's call.
- Ctrl+C forwarding from the pseudoterminal to the child process, and ANSI color re-enablement
  (`$PSStyle.OutputRendering = 'Ansi'`) — cosmetic, deferred.
- A "Browse…" escape hatch retaining the native dialog — deferred.
- Workspace-first module resolution in the bundled wrappers (research Option B, section 3.2) —
  optional complement, not required for AC satisfaction.

## Behavior — Functional Requirements

### Capability 1 — Redirect command output to the integrated terminal

Design: research section 2, Option C (recommended). The existing spawn pipeline
(`runCommandWithOutput`, `command-runtime.ts:206-267`) is kept exactly as-is; a tee
`CommandOutput` forwards each `appendLine` both to the existing `OutputChannel` and to a new
streaming (append-mode) pseudoterminal writer that converts `\n` to `\r\n`. The terminal is
revealed at command start.

- **FR1.1** When `drm-copilot: Run PoshQC Test` is invoked from the command palette, every
  output line the sink receives appears in an integrated terminal with a stable name
  (recommended: `drm-copilot: PoshQC`), and the terminal is revealed when the command starts.
- **FR1.2** The `OutputChannel` continues to receive the identical line stream (tee, not
  replacement).
- **FR1.3** Exit-code preservation: a non-zero child exit still rejects with
  `CommandExecutionError` carrying `exitCode`, full `stdout`, and full `stderr`;
  `getStderrExcerpt` behavior is unchanged. The child remains spawned with piped stdio.
- **FR1.4** The MCP path is untouched: `run_poshqc_test` invoked via MCP uses its buffered
  in-memory sink and creates no terminal.
- **FR1.5** Wiring must not grow the near-cap files: use a per-command service-factory option
  on `registerPoshQcCommands` (default supplied from `extension.ts` in a minimal delta) so
  `repo-automation-service.ts` is unchanged. Recommended scope: all four PoshQC commands share
  the terminal (marginal cost near zero in the shared registration module); AC1 requires the
  test command only.

### Capability 2 — Reconcile workspace-scan folder coverage with the local task

Design: research section 3, Option A (parity-gate extension + resync) plus Option C (config
convergence via Capability 3). Workspace copies are authoritative.

- **FR2.1** Extend `POSHQC_PARITY_PATHS` in `tests/scripts/dev_tools/test_poshqc_bundled_parity.py`
  to cover `PoshQC.psd1`, `settings/pester.runsettings.psd1`, and `settings/pssa.settings.psd1`
  (and the new `PoshQC.ScanConfig.psm1` from Capability 3).
- **FR2.2** Resync the bundled copies from the workspace copies. This removes the bundled
  `RequiredModules` block (the workspace's empty-`RequiredModules` bootstrap contract is
  test-asserted in `PoshQC.EntryPoints.Tests.ps1:32-38`), removes the undocumented
  `CodeCoverage.ExcludedPath` block, and adopts the workspace coverage `Path` list.
- **FR2.3** Capture baseline evidence before implementation: run the local task and the
  command path against the same worktree, diff the produced JUnit outputs, and record the delta
  under `docs/features/active/2026-07-10-poshqc-test-terminal-output-scan-config-344/evidence/baseline/`.
  Empirically record whether `New-PesterConfiguration -Hashtable` errors on or ignores the
  bundled `CodeCoverage.ExcludedPath` key.
- **FR2.4** Reconciliation must not silently broaden or narrow the local task's behavior: the
  workspace settings and module remain the authoritative content; only the bundled copies
  change to match.
- **FR2.5** Known residual limitation (state in plan and PR): the *installed* extension
  converges only at the next packaged release; in-repo drift is closed immediately by FR2.1.

### Capability 3 — Persisted local scan-folder configuration

Design: research section 4, Option B (repo-local JSON consumed inside the module).

- **FR3.1** A new file `config/poshqc-scan.json` (schema below) is the persisted scan
  configuration. Seeded default: exactly the current effective `Run.Path` set —
  `"scripts"`, `"tests/powershell"`, `"tests/scripts"` — so introducing the file is
  behavior-preserving.
- **FR3.2** A new module `scripts/powershell/PoshQC/PoshQC.ScanConfig.psm1` exports
  `Get-PoshQCScanConfigFolder -Root <root> [-ConfigRelativePath 'config/poshqc-scan.json']`
  with injectable `[scriptblock] $TestPathExists` / `$ReadContent` seams (DI style of
  `Convert-PoshQCCoverageToRelative`). It returns the validated relative folder list, or `@()`
  when the file is absent or `test.scanFolders` is absent/empty.
- **FR3.3** `Invoke-PoshQCTest` consumes the config through a new injectable
  `$ResolveScanConfig` scriptblock parameter (defaulting to `Get-PoshQCScanConfigFolder`) only
  when `-ScanFolders` is not supplied; config-yielded folders route through the existing
  `Resolve-PoshQCScanFolder` path.
- **FR3.4** Precedence (documented contract, all surfaces):
  explicit `-ScanFolders` / `-ScanFoldersJson` / MCP `scan_folders` > `config/poshqc-scan.json`
  `test.scanFolders` > settings `Run.Path` defaults.
- **FR3.5** Missing-folder policy: a **config-sourced** folder that does not exist is skipped
  with a logged warning (filtered before `Resolve-PoshQCScanFolder`); if the surviving set is
  empty, fail fast with a clear error. **Explicitly supplied** folders (picker/arguments/MCP)
  keep the existing throw-on-missing behavior of `Resolve-PoshQCScanFolder`. Do not weaken
  `Resolve-PoshQCScanFolder`.
- **FR3.6** Validation failures are fail-fast and name the file: malformed JSON, `version` not
  equal to `1`, blank entries, absolute paths, and `..` segments are errors.
- **FR3.7** A new TypeScript module `extensions/drm-copilot/src/poshqc-scan-config.ts` reads,
  validates, and writes the same schema through the injectable `FileSystem` seam (shared with
  Capability 4). Writes are canonical: workspace-relative forward-slash paths, deduplicated,
  sorted for stable diffs.
- **FR3.8** MCP convergence: because resolution lives in the module,
  `mcp__drm-copilot__run_poshqc_test` without `scan_folders` becomes config-aware with zero MCP
  code change. Update the `run_poshqc_test` description strings in both
  `mcp-tool-definitions.ts` and `mcp-repo-automation-tool-definitions.ts` to document this.
- **FR3.9** The bundled mirrors of the changed PowerShell files are mechanical copies, locked
  by the extended parity gate (FR2.1).

### Capability 4 — Interactive folder select/deselect

Design: research section 5. New module `extensions/drm-copilot/src/poshqc-folder-picker.ts`;
the test-command flow replaces the `promptForWorkspaceScanFolders` / `showOpenDialog` call. The
existing helper stays untouched in `extension-command-helpers.ts` for its remaining callers.

- **FR4.1** Choosing `"Select folders to scan"` opens
  `vscode.window.showQuickPick(items, { canPickMany: true, ignoreFocusOut: true, ... })`.
- **FR4.2** Candidate enumeration: workspace directories to a bounded depth of 2 via the
  `FileSystem` seam, excluding the directory names in `PoshQC.psm1:5-9` (mirrored as a TS
  constant with a comment pointing at the PowerShell source).
- **FR4.3** Seeding: `picked = true` for every item whose workspace-relative path is present in
  `config/poshqc-scan.json` `test.scanFolders`. Config-listed folders are always shown even if
  enumeration would not produce them; a config-listed folder that no longer exists is shown
  with a `$(warning)` description, not dropped silently.
- **FR4.4** Accept with a non-empty selection: persist the selection to the config (canonical
  form per FR3.7) **before** the run, then run with the selection as explicit scan folders
  (workspace-relative paths through `-ScanFoldersJson`).
- **FR4.5** Cancel (`undefined`): no persistence, no run — matches existing cancel semantics.
- **FR4.6** Accept with an empty selection: show an information message and abort; do not run
  and do not persist the empty list (an empty `scanFolders` means "defaults apply" downstream
  and must not be created by deselect-all).
- **FR4.7** Scope-choice UX: the two-item scope QuickPick is retained. `"Scan entire
  workspace"` now means "config-driven set, or `Run.Path` defaults when the config is absent"
  per Capability 3.

## Configuration Schema — `config/poshqc-scan.json`

```json
{
  "version": 1,
  "test": {
    "scanFolders": ["scripts", "tests/powershell", "tests/scripts"]
  }
}
```

| Field | Type | Rules |
|---|---|---|
| `version` | integer | Must equal `1`. Any other value is a fail-fast validation error naming the file. Forward-compatibility gate for future schema revisions. |
| `test` | object | Scoping key; leaves room for future `format` / `analyze` sections without a schema break. |
| `test.scanFolders` | string array | Workspace-relative, forward-slash folder paths. Non-blank; no absolute paths; no `..` segments; deduplicated; sorted for stable diffs. |

- **Absence semantics:** absent file, or absent/empty `test.scanFolders`, means current
  behavior (settings `Run.Path` defaults). The seeded default file mirrors the `Run.Path` set
  exactly (`scripts`, `tests/powershell`, `tests/scripts`); `tests/powershell` does not exist
  in this worktree, and the FR3.5 skip-with-warning rule makes the seed safe.
- **PowerShell consumer:** `Get-PoshQCScanConfigFolder` (`PoshQC.ScanConfig.psm1`) parses via
  `ConvertFrom-Json` behind injectable read/exists seams; called from `Invoke-PoshQCTest` when
  `-ScanFolders` is not supplied. The local task inherits it automatically (workspace module),
  and the MCP tool inherits it automatically (bundled module mirror).
- **TypeScript consumer:** `poshqc-scan-config.ts` reads/validates for picker seeding and
  writes canonical selections back, using the injectable `FileSystem` seam (in-memory fake in
  tests). Both consumers enforce the identical validation rules.

## Inputs / Outputs

- **Inputs:** command-palette invocation; scope QuickPick choice; multi-select QuickPick
  selection; `config/poshqc-scan.json`; MCP `scan_folders` argument; `-ScanFolders` /
  `-ScanFoldersJson` script arguments; settings `Run.Path` defaults.
- **Outputs:** integrated-terminal stream + `OutputChannel` log (command path); buffered output
  (MCP path); Pester artifacts as today (e.g. `artifacts/pester/pester-junit.xml`); updated
  `config/poshqc-scan.json` on picker accept; unchanged service summary record.
- **Config keys and defaults:** see Configuration Schema above.
- **Versioning / backward compatibility:** schema `version: 1` gate; absent config preserves
  pre-feature behavior on every surface; MCP request/response schema unchanged.

## API / CLI Surface

- `drmCopilotExtension.runPoshQCTest` (command palette) — UX change only (terminal + picker);
  no new command IDs.
- `Invoke-PoshQCTest` — new optional injectable parameter `$ResolveScanConfig` (scriptblock,
  default `Get-PoshQCScanConfigFolder`). Existing parameters unchanged; explicit `-ScanFolders`
  always wins (FR3.4).
- `Get-PoshQCScanConfigFolder -Root <root> [-ConfigRelativePath <path>] [-TestPathExists <sb>] [-ReadContent <sb>]`
  — new exported function returning a validated relative folder list or `@()`.
- MCP `run_poshqc_test` — schema unchanged; description strings updated to document
  config-awareness when `scan_folders` is omitted.
- Contracts and validation rules: precedence FR3.4; validation FR3.6; missing-folder policy
  FR3.5; empty-selection rule FR4.6.

## Data & State

- **Data flow:** picker selection → canonical write to `config/poshqc-scan.json` →
  `-ScanFoldersJson` argument → module `Resolve-PoshQCScanFolder`; or (no explicit folders)
  module reads config directly.
- **Invariants:** config write-back happens before the process spawn, so a crash mid-run still
  leaves the selection persisted (the selection is user intent, not a run result). Ordering:
  scope QuickPick → optional multi-select → config write-back → spawn → terminal reveal +
  stream → completion.
- **Persistence:** single JSON file at repo root `config/`; no other state stores. No
  migration or backfill: absent config is a valid state meaning defaults.

## Constraints & Risks

- **500-line file limit (all production files).** `extension.ts` is at 483 lines and
  `repo-automation-service.ts` at 487 — both near the cap. Keep the `extension.ts` delta
  minimal (factory pass-through only, or move the option block into the registration module);
  do not modify `repo-automation-service.ts`. `PoshQC.Testing.psm1` grows from 410 to ~428; do
  not add unrelated logic to it.
- **PowerShell change budget.** Capability 3 touches 3 production PowerShell files
  (`PoshQC.ScanConfig.psm1` new, `PoshQC.psm1`, `PoshQC.Testing.psm1`), which is at the
  per-batch cap (≤3) and above the direct-mode budget (≤2) in `.claude/rules/powershell.md`.
  Plan the PowerShell work as an explicit batch (or two). Bundled mirrors are mechanical
  copies.
- **Coverage thresholds.** Line coverage >= 85% and branch coverage >= 75% apply to all
  changed code (TypeScript and PowerShell). Baseline, post-change, and comparison coverage
  evidence go to the feature `evidence/` tree.
- **Determinism.** No timers or wall-clock reads; child-process, terminal, QuickPick, and
  filesystem interactions are exercised through existing mocked seams (`extension-test-harness`,
  in-memory `FileSystem`, injectable scriptblocks). Temporary files in tests are prohibited.
- **Test harness.** Extension unit tests use the package's **Jest** harness
  (`extensions/drm-copilot/test/*.test.ts`, `run-jest.cjs`), not Vitest. Do not introduce a
  second framework. Verify fast-check availability before planning property-style cases; do
  not add a dependency.
- **Terminal redirection risk.** Must preserve exit-code and failure-reporting semantics
  (FR1.3); mitigated by keeping the spawn pipeline unchanged and teeing display only.
- **Reconciliation risk.** Must not silently broaden or narrow the local task's behavior
  (FR2.4); mitigated by workspace-copy authority and baseline JUnit diff evidence (FR2.3).
- **Cross-module contract risk.** The config schema is shared between the extension command
  layer, the PoshQC module, and the MCP surface; mitigated by identical validation rules in
  both consumers and the extended parity gate.

## Implementation Strategy

- **Scope (what changes):** new `poshqc-terminal-output.ts`, `poshqc-scan-config.ts`,
  `poshqc-folder-picker.ts`, `PoshQC.ScanConfig.psm1`, `config/poshqc-scan.json`; edits to
  `poshqc-command-registration.ts`, `extension.ts` (minimal), `PoshQC.psm1`,
  `PoshQC.Testing.psm1`, `test_poshqc_bundled_parity.py`, MCP description strings; bundled
  resync of `PoshQC.psd1` and `settings/*.psd1`; corresponding Jest and Pester tests. File
  tables with size estimates: research sections 2.4, 3.3, 4.5, 5.3.
- **Suggested phase order:** (1) baseline evidence + Capability 2 resync (independent,
  de-risks everything), (2) Capability 3 PowerShell + TS config modules, (3) Capability 4
  picker (depends on 3 via `poshqc-scan-config.ts`), (4) Capability 1 terminal tee
  (independent; may also run first).
- **Dependencies:** none added or removed.
- **Logging:** skip-with-warning messages for missing config-sourced folders use the module's
  existing warning pattern; fail-fast validation errors name `config/poshqc-scan.json`.
- **Rollout / fallback:** absent config file preserves pre-feature behavior on all surfaces;
  no feature flags required.

## Acceptance Criteria

These criteria supersede the early-draft ACs in `issue.md`. AC1–AC4 preserve the semantic
mapping of the issue's draft AC1–AC4; AC5+ add individually verifiable detail. IDs are stable
for downstream acceptance-criteria tracking. Capability mapping is noted per item.

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

## Definition of Done

- [ ] Acceptance criteria AC1–AC16 checked off with per-item verification evidence
- [ ] Behavior matches acceptance criteria in all documented environments
- [ ] Jest, Pester, and pytest (parity) suites updated and passing
- [ ] Edge cases and error handling covered by tests (AC5, AC8, AC9, AC13–AC15)
- [ ] Docs updated (feature-folder artifacts; MCP tool description strings)
- [ ] Logging additions in place for config warnings and validation failures
- [ ] Full toolchain pass completed (format → lint → type-check → arch → unit → contract →
      integration) per `.claude/rules/general-code-change.md`

## Seeded Test Conditions (from potential)

- [ ] Unit coverage for terminal-output routing and folder-selection persistence in TypeScript.
- [ ] Pester coverage for scan-folder discovery parity.
- [ ] Interactive select/deselect edge cases (empty selection, nested subfolders, persistence round-trip).
