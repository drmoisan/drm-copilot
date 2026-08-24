# Feature Audit: PoshQC Test Terminal Output and Scan Config (#344) — Remediation Cycle 1 Re-Audit

- **Timestamp:** 2026-07-10T20-57
- **Auditor:** feature-review agent (re-audit R4)
- Template note: the MCP tool `resolve_policy_audit_template_asset` could not be invoked in this session; this artifact was instantiated from the bundled asset source file at `extensions/drm-copilot/resources/templates/policy_audit/feature-audit.yyyy-MM-ddTHH-mm.md`.

## Scope and Baseline

- **Resolved base branch:** `main` (supplied by the caller and confirmed by `pr-base-branch-merge-base` data in `artifacts/pr_context.summary.txt`: base resolved `origin/main @ 233f259b`, merge base `cf036d3f5c1608f900d2ad23e08f809713101fa3`).
- **Merge-base SHA:** `cf036d3f5c1608f900d2ad23e08f809713101fa3` (verified `git merge-base main HEAD` in this session).
- **Branch HEAD:** `c01eab76937c368e8c3bdc066c3efba6fae405f5` (verified `git rev-parse HEAD`; matches the caller-supplied value and the refreshed PR-context artifacts).
- **Diff range:** `cf036d3f..c01eab76`, 87 files changed (+13530/-65).
- **Work mode:** `full-feature` (persisted marker `- Work Mode: full-feature` in `issue.md`, line 10). Acceptance-criteria sources: `spec.md` (normative) and `user-story.md` (shared AC set, same IDs AC1-AC16).
- **Re-audit context:** remediation cycle 1 closed findings R1-R3 from the 2026-07-10T19-52 review. This audit re-evaluates all 16 acceptance criteria against the current branch state with fresh evidence; it does not assume prior-cycle conclusions.

## Acceptance Criteria Inventory

Source: `spec.md` `## Acceptance Criteria` (16 items, AC1-AC16, all currently marked `[x]`); mirrored in `user-story.md` (same 16 IDs, all marked `[x]`).

| ID | Capability | Summary |
|---|---|---|
| AC1 | Cap 1 | Command streams sink output into a stable-named integrated terminal, reveals it at start; OutputChannel receives the identical stream |
| AC2 | Cap 2 | Command "Scan entire workspace" and local task discover the same Pester test set; bundled `PoshQC.psd1` and `settings/*.psd1` byte-identical to workspace copies |
| AC3 | Cap 3 | `config/poshqc-scan.json` exists (version 1, seeded folders); `Invoke-PoshQCTest` resolves scan set via `Get-PoshQCScanConfigFolder` |
| AC4 | Cap 4 | "Select folders to scan" opens a `canPickMany` QuickPick seeded from config; accepted selection persisted before the run |
| AC5 | Cap 1 | Non-zero child exit still rejects with `CommandExecutionError` (exitCode, stdout, stderr); `getStderrExcerpt` unchanged |
| AC6 | Cap 1 | MCP `run_poshqc_test` path creates no terminal; buffered sink retained |
| AC7 | Cap 2 | Baseline JUnit/discovered-set diff and `New-PesterConfiguration -Hashtable` empirical result recorded under `evidence/baseline/` |
| AC8 | Cap 3 | Config validation fails fast naming the file for the five malformed-input classes |
| AC9 | Cap 3 | Config-sourced folder skip-with-warning; all-skipped fail-fast; explicit folders keep throw-on-missing |
| AC10 | Cap 3 | Precedence: explicit > config > `Run.Path` defaults |
| AC11 | Cap 3 | Canonical TS config writes; stable read-after-write round-trip |
| AC12 | Cap 3 | MCP tool resolves config-driven default; explicit override kept; description strings updated in both definition files |
| AC13 | Cap 4 | Picker cancel: no config write, no run |
| AC14 | Cap 4 | Empty selection: info message, no write, no run |
| AC15 | Cap 4 | Picker enumerates to depth 2 with exclusions; vanished config folder shown with warning marker |
| AC16 | Cross-cutting | No production file > 500 lines; changed-code line >= 85% / branch >= 75%; coverage evidence (baseline, post-change, comparison) under `evidence/` |

## Acceptance Criteria Evaluation

| ID | Verdict | Evidence |
|---|---|---|
| AC1 | PASS | `src/poshqc-terminal-output.ts` (99.29% line coverage) with Jest tests asserting terminal creation/reveal and dual-sink identical forwarding (`poshqc-terminal-output.test.ts`); wiring covered in `extension.run-poshqc-commands.test.ts`. All 1640 Jest tests pass at the remediated state (gate evidence, EXIT_CODE 0). Unchanged since the 19-52 PASS; re-confirmed via clean tsc/eslint/prettier re-runs at HEAD. |
| AC2 | PASS | Eight-pair parity gate re-run in this session (`poetry run pytest tests/scripts/dev_tools/test_poshqc_bundled_parity.py -v`: 1 passed) covering `PoshQC.psd1` and both `settings/*.psd1` plus all four `.psm1` files; direct byte comparison of all eight pairs performed in this session (all identical). Bundled `PoshQC.psd1` has no `RequiredModules`; runsettings have no `CodeCoverage.ExcludedPath` (diff inspection). Post-change JUnit-diff comparison recorded (`evidence/regression-testing/junit-diff-post-change.md`, junit-task-post.xml vs junit-command-post.xml). The AST loader refactor did not regress parity. |
| AC3 | PASS | `config/poshqc-scan.json` inspected this session: `version: 1`, `test.scanFolders` = `["scripts", "tests/powershell", "tests/scripts"]`. Pester seam-injection tests (`PoshQC.ScanConfig.Tests.ps1`, 12 It blocks) pass within the 1103-test gate (JUnit: 0 failures). `Get-PoshQCScanConfigFolder` now measured at 95.65% line coverage. |
| AC4 | PASS | `src/poshqc-folder-picker.ts` (100% line and branch coverage) with Jest picker tests including persistence round-trip (`poshqc-folder-picker.test.ts`); `showOpenDialog` replaced by `canPickMany` QuickPick in this flow (diff inspection of `poshqc-command-registration.ts`). |
| AC5 | PASS | Jest test with mocked process exiting 1 while the terminal tee is active asserts `CommandExecutionError` carries `exitCode`, full `stdout`, `stderr`; `getStderrExcerpt` untouched by the diff (no changes to `repo-automation-service.ts`, verified in the name-status list). |
| AC6 | PASS | Jest test on the MCP dispatch path asserts no terminal creation and buffered-sink behavior (`mcp-server.test.ts` extension). |
| AC7 | PASS | `evidence/baseline/junit-task.xml`, `junit-command.xml`, `junit-diff-task-vs-command.md`, and `pester-excludedpath-empirical.md` all present under the feature `evidence/baseline/` tree (directory listing this session). |
| AC8 | PASS | Five-class validation matrix tested in both Pester (injected `$ReadContent`) and Jest (in-memory `FileSystem`); both suites green at the remediated state (JUnit 0 failures; Jest gate EXIT_CODE 0). |
| AC9 | PASS | Pester tests cover skip-with-warning, all-skipped fail-fast, and explicit-folder throw-on-missing (within `PoshQC.ScanConfig.Tests.ps1` / `PoshQC.ScanFolders.Tests.ps1`, passing). |
| AC10 | PASS | Precedence matrix covered by Pester seam-injection tests on `Invoke-PoshQCTest` (`PoshQC.ScanFolders.Tests.ps1` extension, +99 lines, passing). |
| AC11 | PASS | Jest round-trip tests on the in-memory `FileSystem` assert canonical output (workspace-relative forward-slash, deduplicated, sorted) and stable re-read (`poshqc-scan-config.test.ts`; module at 96.49% line coverage). |
| AC12 | PASS | Both `mcp-tool-definitions.ts` and `mcp-repo-automation-tool-definitions.ts` changed in the diff (description strings); both files at 100% line coverage; MCP dispatch tests extended and passing. No other schema change (diff inspection). |
| AC13 | PASS | Jest cancel-path test: `undefined` QuickPick result performs no config write and no run. |
| AC14 | PASS | Jest empty-selection test: information message, no write, no run. |
| AC15 | PASS | Jest tests cover depth-2 enumeration with the default-excluded directory names and the warning marker for vanished config-listed folders. |
| AC16 | PASS | (Previously PARTIAL; re-evaluated with fresh evidence.) File-size clause: all changed production files measured this session at <= 500 lines; `extension.ts` 488 and `repo-automation-service.ts` 487 explicitly verified. Coverage clause: TypeScript changed modules 94.27%-100% lines / 85.71%-100% branches (lcov parsed this session); PowerShell new module `PoshQC.ScanConfig.psm1` 95.65% lines (coverage XML parsed this session; the Pester coverage tool emits no branch counter — line-based instrument, the accepted evidence convention recorded since the baseline artifact); Python test-only change with repo-wide 86.62% lines. Evidence clause: baseline (`evidence/baseline/`), post-change (`evidence/qa-gates/remediation-*`), and comparison (`evidence/qa-gates/coverage-comparison.md`, Remediation Cycle 1 section) all present under the feature `evidence/` tree. |

Prior-finding resolution cross-check (drivers of the previous AC16 PARTIAL):

- R1 (stale TS lcov): RESOLVED — regenerated lcov contains all four changed modules; repo-wide 96.78% lines / 88.79% branches, above baseline.
- R2 (unmeasured `PoshQC.ScanConfig.psm1`): RESOLVED — AST loader refactor + `CodeCoverage.Path` addition; 95.65% lines measured; 1103-test gate and parity gate green post-refactor.
- R3 (absent Python coverage artifact): RESOLVED — `artifacts/python/lcov.info` exists; 86.62% lines; full suite re-run this session (1309 passed).

## Summary

- **Verdict distribution:** 16 PASS, 0 PARTIAL, 0 FAIL, 0 UNVERIFIED.
- The single PARTIAL from the 2026-07-10T19-52 audit (AC16) now evaluates PASS: all three underlying coverage-evidence findings were remediated and independently verified from machine-readable artifacts in this session.
- The AST module-loading refactor introduced no regression: the authoritative 1103-test PoshQC gate reports 0 failures (JUnit parsed this session), the eight-pair bundled parity gate passes (re-run this session), and all eight workspace/bundled pairs are byte-identical (direct comparison this session).
- Definition-of-Done support: Jest (1640), Pester (1103, 9 pre-existing skips), and pytest (1309) suites all green; full toolchain clean (policy audit sections 2.5 and 7); MCP tool description strings updated; feature-folder docs complete.
- No remediation is required from this re-audit. Blocking finding count: 0.

### Acceptance Criteria Status

- Source: `docs/features/active/2026-07-10-poshqc-test-terminal-output-scan-config-344/spec.md` and `docs/features/active/2026-07-10-poshqc-test-terminal-output-scan-config-344/user-story.md`
- Total AC items: 16
- Checked off (delivered): 16
- Remaining (unchecked): 0
- Items remaining: none

## Acceptance Criteria Check-off

All 16 acceptance criteria were already marked `[x]` in both `spec.md` and `user-story.md` before this re-audit. Under the check-off protocol, PASS items are checked off if not already checked; since every item now evaluates PASS and every item is already checked, no source-file edit was required. The previously questionable AC16 `[x]` mark (flagged in `remediation-inputs.2026-07-10T19-52.md` as accurate only upon R1/R2 completion) is now accurate: R1-R3 are resolved with verified evidence, so the existing marks stand without modification.

Newly checked-off items in this audit: none (all were previously checked; AC16's mark is now substantiated rather than newly applied).
