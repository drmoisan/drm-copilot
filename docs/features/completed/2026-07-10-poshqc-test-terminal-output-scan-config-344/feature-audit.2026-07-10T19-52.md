# Feature Audit: poshqc-test-terminal-output-scan-config (#344)

**Audit Date:** 2026-07-10
**Feature Folder:** `docs/features/active/2026-07-10-poshqc-test-terminal-output-scan-config-344`
**Base Branch:** `main`
**Head Branch:** `drm-copilot-wt-2026-07-10T16-55` @ `2ed08b193e9adaabd115983f56d0cf2f3992ffad`
**Work Mode:** `full-feature`
**Audit Type:** Initial acceptance review
**Template source note:** Created from the bundled asset source file `extensions/drm-copilot/resources/templates/policy_audit/feature-audit.yyyy-MM-ddTHH-mm.md` (the same content the MCP template resolver serves); the MCP resolver tool could not be invoked in this session.

---

## Scope and Baseline

- **Base branch:** `main` (resolved `origin/main` @ `233f259b`)
- **Head branch/commit:** `drm-copilot-wt-2026-07-10T16-55` (commit `2ed08b193e9adaabd115983f56d0cf2f3992ffad`)
- **Merge base:** `cf036d3f5c1608f900d2ad23e08f809713101fa3`
- **Evidence sources:**
  - Primary: `artifacts/pr_context.summary.txt`
  - Secondary baseline diff: `artifacts/pr_context.appendix.txt` and direct `git diff cf036d3f..HEAD`
  - Feature evidence: `docs/features/active/2026-07-10-poshqc-test-terminal-output-scan-config-344/evidence/**` (baseline, qa-gates, regression-testing)
  - Additional evidence: machine-readable artifacts `artifacts/pester/powershell-coverage.xml`, `artifacts/pester/pester-junit.xml`, `extensions/drm-copilot/coverage/lcov.info`
- **Feature folder used:** `docs/features/active/2026-07-10-poshqc-test-terminal-output-scan-config-344`
- **Requirements source:** `spec.md` and `user-story.md` (shared AC1–AC16 set; spec holds the normative definitions)
- **Work mode resolution note:** `issue.md` carries the explicit marker `- Work Mode: full-feature`, so per the acceptance-criteria-tracking rules the AC sources are `spec.md` and `user-story.md`. The early-draft ACs in `issue.md` are superseded by the spec set (stated in both spec and user-story).
- **Scope note:** Full feature-vs-base audit of the entire branch diff (61 files) across TypeScript, PowerShell, Python, JSON, and documentation. No caller scope narrowing was attempted or accepted.

---

## Acceptance Criteria Inventory

**Authoritative AC source files for this run:**
- `docs/features/active/2026-07-10-poshqc-test-terminal-output-scan-config-344/spec.md` — normative source
- `docs/features/active/2026-07-10-poshqc-test-terminal-output-scan-config-344/user-story.md` — mirrored shared set

### Acceptance criteria

1. AC1 (Cap 1): Invoking `drm-copilot: Run PoshQC Test` from the command palette streams every sink output line into an integrated terminal with a stable name, reveals that terminal at command start, and the `OutputChannel` receives the identical line stream. Verified by Jest tests asserting terminal creation/reveal and dual-sink forwarding.
2. AC2 (Cap 2): At the same commit, the command's "Scan entire workspace" path and the local task `PoshQC: 4 test (Pester)` discover the same Pester test set; the bundled `PoshQC.psd1` and `settings/*.psd1` are byte-identical to the workspace copies (no `RequiredModules`, no `CodeCoverage.ExcludedPath`, current coverage list). Verified by the extended parity gate passing and a recorded JUnit-diff comparison.
3. AC3 (Cap 3): `config/poshqc-scan.json` exists with `version: 1` and seeded `test.scanFolders` of `["scripts", "tests/powershell", "tests/scripts"]`, and `Invoke-PoshQCTest` without `-ScanFolders` resolves its scan set from this file via `Get-PoshQCScanConfigFolder`. Verified by Pester seam-injection tests.
4. AC4 (Cap 4): Choosing `"Select folders to scan"` in the test command opens a `canPickMany` QuickPick (replacing `showOpenDialog` in this flow) whose items are workspace-relative paths seeded `picked` from the config, and an accepted non-empty selection is persisted back to the config before the run and passed as the run's scan folders. Verified by Jest picker tests including a persistence round-trip.
5. AC5 (Cap 1): A non-zero child exit on the command path still rejects with `CommandExecutionError` carrying `exitCode`, full `stdout`, and full `stderr`, and `getStderrExcerpt` output is unchanged. Verified by a Jest test with a mocked process exiting 1 while the terminal tee is active.
6. AC6 (Cap 1): The MCP `run_poshqc_test` path creates no terminal and continues to use the buffered output sink. Verified by a Jest test on the MCP dispatch path.
7. AC7 (Cap 2): Baseline evidence — a JUnit/discovered-set diff of task vs command invocations against the same worktree, plus the empirical `New-PesterConfiguration -Hashtable` result for the `CodeCoverage.ExcludedPath` key — is recorded under the feature `evidence/baseline/` tree.
8. AC8 (Cap 3): Config validation fails fast with an error naming the file for: malformed JSON, `version` other than `1`, a blank entry, an absolute-path entry, or an entry containing `..`. Verified in both Pester (injected `$ReadContent`) and Jest (in-memory `FileSystem`) tests.
9. AC9 (Cap 3): A config-sourced folder that does not exist is skipped with a logged warning; if all config-sourced folders are skipped, the run fails fast with a clear error; explicitly supplied scan folders retain throw-on-missing behavior. Verified by Pester tests.
10. AC10 (Cap 3): Scan-folder precedence holds: explicit `-ScanFolders`/`-ScanFoldersJson` overrides the config; the config overrides settings `Run.Path`; absent file or empty `test.scanFolders` yields `Run.Path` defaults. Verified by Pester seam-injection tests on `Invoke-PoshQCTest`.
11. AC11 (Cap 3): The TypeScript config module writes canonical content (workspace-relative forward-slash paths, deduplicated, sorted) and a read-after-write round-trip is stable. Verified by Jest tests against the in-memory `FileSystem`.
12. AC12 (Cap 3): MCP `run_poshqc_test` without `scan_folders` resolves the config-driven set through the module; explicit `scan_folders` still overrides; the tool description strings in both `mcp-tool-definitions.ts` and `mcp-repo-automation-tool-definitions.ts` document the config-aware default. No other MCP schema or behavior change.
13. AC13 (Cap 4): Cancelling the folder QuickPick (`undefined`) performs no config write and no run. Verified by a Jest test.
14. AC14 (Cap 4): Accepting an empty selection shows an information message, performs no config write, and does not run. Verified by a Jest test.
15. AC15 (Cap 4): The picker enumerates workspace subfolders to depth 2 excluding the `PoshQC.psm1` default-excluded directory names, and a config-listed folder that no longer exists is shown with a warning marker rather than dropped. Verified by Jest tests with the in-memory `FileSystem`.
16. AC16 (Cross-cutting): After all changes, no production file exceeds 500 lines (`extension.ts` and `repo-automation-service.ts` explicitly verified), line coverage is >= 85% and branch coverage >= 75% for the changed code, and coverage evidence (baseline, post-change, comparison) is recorded under the feature `evidence/` tree.

---

## Acceptance Criteria Evaluation

| # | Criterion | Status | Evidence | Verification command(s) | Notes |
|---|-----------|--------|----------|--------------------------|-------|
| 1 | AC1 terminal streaming + reveal + dual sink | PASS | `poshqc-terminal-output.ts` (stable name `drm-copilot: PoshQC`, reveal, tee); tests in `poshqc-terminal-output.test.ts` and `extension.run-poshqc-commands.test.ts`; TS suite 1640/1640 exit 0 | `npm run test:coverage` (gate log `evidence/qa-gates/final-ts-test-coverage.md`) | Reveal wired at each run path in `poshqc-command-registration.ts`. |
| 2 | AC2 discovered-set parity + byte-identical bundled data files | PASS | 1103 = 1103 zero-difference discovered sets (`evidence/regression-testing/junit-diff-post-change.md`); bundled `PoshQC.psd1` diff removes `RequiredModules`; bundled runsettings diff removes `ExcludedPath`; extended parity gate passes (8 pairs) | `poetry run pytest tests/scripts/dev_tools/test_poshqc_bundled_parity.py -v` | The 31 wrapper-run pass/fail deltas are outside AC2's discovery-parity definition; assessed non-blocking (policy audit section 8). |
| 3 | AC3 config file + module resolution | PASS | `config/poshqc-scan.json` verified in diff (version 1, seeded three folders); `Get-PoshQCScanConfigFolder` exported from `PoshQC.psm1`; 12 It blocks in `PoshQC.ScanConfig.Tests.ps1`; Pester 1103/0 | MCP `run_poshqc_test` (gate log `evidence/qa-gates/final-ps-test-coverage.md`) | `-ScanFolders`-absent path consults `$ResolveScanConfig` (verified in `PoshQC.Testing.psm1` diff). |
| 4 | AC4 canPickMany picker seeded + persist-before-run | PASS | `poshqc-folder-picker.ts` (`canPickMany: true`, seeded `picked`, `writePoshQcScanFolders` before return); persistence round-trip test at `poshqc-folder-picker.test.ts:195`; registration passes selection as explicit scan folders | `npm run test:coverage` | `showOpenDialog` path replaced only in the test-command flow; helper retained for other callers per spec. |
| 5 | AC5 failure semantics under tee | PASS | `extension.run-poshqc-commands.test.ts:228-247` asserts `CommandExecutionError`, `exitCode === 1`, stdout/stderr payloads, unchanged `getStderrExcerpt` | `npm run test:coverage` | Spawn pipeline not in diff (`command-runtime.ts` unchanged). |
| 6 | AC6 MCP path creates no terminal | PASS | `mcp-server.test.ts:362-376` asserts zero `createTerminal` calls on the MCP dispatch path | `npm run test:coverage` | MCP buffered sink unchanged. |
| 7 | AC7 baseline evidence recorded | PASS | `evidence/baseline/junit-diff-task-vs-command.md`, `junit-task.xml`, `junit-command.xml`, `pester-excludedpath-empirical.md` all present in the diff | `ls evidence/baseline/` | Both required elements (JUnit diff and empirical `-Hashtable` result) present. |
| 8 | AC8 fail-fast validation naming the file | PASS | Identical rule set in `poshqc-scan-config.ts` and `PoshQC.ScanConfig.psm1` (verified by code inspection); 5 negative Jest cases + 5 negative Pester It blocks | `npm run test:coverage`; MCP `run_poshqc_test` | Error messages name `config/poshqc-scan.json` in both consumers. |
| 9 | AC9 skip-with-warning / all-missing error / explicit throw retained | PASS | `PoshQC.ScanConfig.psm1:108-124` (skip + warning, hard error on empty survivor set); precedence suite retains explicit-missing throw | MCP `run_poshqc_test` | `Resolve-PoshQCScanFolder` not weakened (not in diff). |
| 10 | AC10 precedence chain | PASS | `PoshQC.Testing.psm1:280-292` precedence block; 4 It blocks in `PoshQC.ScanFolders.Tests.ps1` | MCP `run_poshqc_test` | Empty config result leaves `Run.Path` defaults untouched. |
| 11 | AC11 canonical write + stable round-trip | PASS | `writePoshQcScanFolders` (sorted, deduplicated, forward-slash, trailing newline); byte-stable round-trip test at `poshqc-scan-config.test.ts:209` | `npm run test:coverage` | |
| 12 | AC12 MCP config-aware default + description strings | PASS | Both definition files updated with identical config-awareness sentence (verified in diff); resolution inside the module means zero MCP schema/behavior change; MCP-run gate passed 1103/0 on the config-driven default | `git diff cf036d3f..HEAD -- extensions/drm-copilot/src/mcp-*.ts` | |
| 13 | AC13 cancel: no write, no run | PASS | `poshqc-folder-picker.ts:176-178`; test at `poshqc-folder-picker.test.ts:215` | `npm run test:coverage` | |
| 14 | AC14 empty accept: message, no write, no run | PASS | `poshqc-folder-picker.ts:179-182`; test at `poshqc-folder-picker.test.ts:229` | `npm run test:coverage` | Prevents deselect-all from persisting an empty list (defaults-apply semantics preserved). |
| 15 | AC15 depth-2 enumeration + warning marker | PASS | `enumerateCandidateFolders` (depth cap 2, excluded names mirroring `PoshQC.psm1`); warning-marker branch at `poshqc-folder-picker.ts:135-138`; tests at `poshqc-folder-picker.test.ts:128,177` | `npm run test:coverage` | Excluded-name list carries a sync-pointer comment to the PowerShell source. |
| 16 | AC16 file sizes + changed-code coverage thresholds + evidence recorded | PARTIAL | File sizes independently verified (largest 488; `repo-automation-service.ts` no diff). Coverage evidence recorded under `evidence/`. However the ">= 85% line / >= 75% branch for the changed code" clause is not evidenced at HEAD: the on-disk TS lcov omits the three new modules (stale), and the changed PowerShell modules have zero instrumented lines (outside `CodeCoverage.Path`), with no approved exception | `wc -l <files>`; programmatic lcov/JaCoCo parse | Blocking items R1/R2 (and R3 for Python artifact absence) in `policy-audit.2026-07-10T19-52.md` section 8 and `remediation-inputs.2026-07-10T19-52.md`. |

---

## Summary

**Overall Feature Readiness:** NEEDS REVISION

**Criteria summary:**
- **PASS:** 15 criteria (AC1–AC15)
- **PARTIAL:** 1 criterion (AC16)
- **UNVERIFIED:** 0 criteria
- **FAIL:** 0 criteria

**Top gaps preventing PASS:**

1. AC16 coverage clause: TypeScript per-file threshold compliance for the three new modules is not corroborated by a machine-readable coverage artifact at branch HEAD (stale `coverage/lcov.info`).
2. AC16 coverage clause: the changed PowerShell production modules are outside the coverage-measurement denominator (zero instrumented lines) with no approved policy exception.
3. Language-level coverage mandate (policy, adjacent to AC16): no Python coverage artifact exists although a Python file changed.

**Recommended follow-up verification steps:**

1. Rerun `npm run test:coverage` at HEAD; confirm per-file line/branch thresholds for `poshqc-scan-config.ts`, `poshqc-terminal-output.ts`, `poshqc-folder-picker.ts`, `poshqc-command-registration.ts` from the regenerated lcov and refresh `evidence/qa-gates/coverage-comparison.md`.
2. Resolve the PowerShell instrumentation gap: refactor `PoshQC.psm1` sub-module loading so Pester breakpoints bind and add the modules to `CodeCoverage.Path`, or record an explicit human-approved exception; then re-verify.
3. Generate and persist the Python coverage artifact (`poetry run pytest --cov` with lcov output) and record repo-wide figures.
4. Open the follow-up issue for the bundled-wrapper module-instance collision (code review finding CR-4, non-blocking).

---

## Acceptance Criteria Check-off

Per the acceptance-criteria tracking rules:
- Criteria evaluated as **PASS** may be checked off in the authoritative source file(s) if not already checked.
- Criteria evaluated as **PARTIAL**, **FAIL**, or **UNVERIFIED** must remain unchecked.

All 16 criteria were already checked (`[x]`) in both `spec.md` and `user-story.md` by the executor before this review (recorded in `evidence/qa-gates/acceptance-criteria-status.md`). No new check-offs were performed by this audit: AC1–AC15 were already checked and are confirmed PASS here. **Discrepancy note:** AC16 is checked in both source files but evaluates PARTIAL in this audit; this review did not modify the source files (the tracking protocol authorizes reviewers to check off PASS items, not to rewrite existing marks), so the checked state of AC16 currently overstates delivery. The remediation cycle must either satisfy the AC16 coverage clause (making the mark accurate) or correct the mark.

### AC Status Summary

- Source: `docs/features/active/2026-07-10-poshqc-test-terminal-output-scan-config-344/spec.md`, `docs/features/active/2026-07-10-poshqc-test-terminal-output-scan-config-344/user-story.md`
- Total AC items: 16
- Checked off (delivered): 16 checked in source files; 15 confirmed PASS by this audit
- Remaining (unchecked): 0 unchecked in source files; 1 item (AC16) evaluates PARTIAL despite being checked
- Items remaining: AC16 coverage clause (see discrepancy note)

| Source File | Total AC | Checked (PASS) | Unchecked | Notes |
|-------------|----------|----------------|-----------|-------|
| `spec.md` | 16 | 16 checked (15 confirmed PASS, 1 PARTIAL) | 0 | Checkbox-backed; AC16 mark overstates delivery pending remediation |
| `user-story.md` | 16 | 16 checked (15 confirmed PASS, 1 PARTIAL) | 0 | Mirrors spec set; same AC16 discrepancy |
