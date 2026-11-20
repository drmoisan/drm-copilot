# Acceptance-Criteria Status Summary (P6-T15)

- Timestamp: 2026-07-10T19-35
- Work mode: full-feature (check-off applied to BOTH `spec.md` and `user-story.md`)

## AC Status Summary

- Source files: `spec.md`, `user-story.md`
- Total acceptance criteria: 16 (AC1–AC16)
- Checked (`[x]`) in `spec.md`: 16
- Checked (`[x]`) in `user-story.md`: 16
- Remaining unchecked: 0

Both source files are consistent (16/16 checked, 0 unchecked).

## Per-AC Verification Evidence

| AC | Cap | Verification evidence |
|---|---|---|
| AC1 | 1 | Jest: `test/poshqc-terminal-output.test.ts` (streaming/reveal/CRLF/tee); `test/extension.run-poshqc-commands.test.ts` (terminal streaming + dual-sink). TS suite 1640 tests pass (`evidence/qa-gates/final-ts-test-coverage.md`). |
| AC2 | 2 | Extended parity pytest pass (`evidence/qa-gates/final-py-parity.md`); discovered-set parity 1103=1103 (`evidence/regression-testing/junit-diff-post-change.md`); bundled `PoshQC.psd1`/`settings/*.psd1` byte-identical, no `RequiredModules`/`ExcludedPath`. |
| AC3 | 3 | `config/poshqc-scan.json` (`version:1`, `test.scanFolders`=["scripts","tests/powershell","tests/scripts"]); Pester `PoshQC.ScanConfig.Tests.ps1` + `Invoke-PoshQCTest` precedence tests pass (`evidence/qa-gates/final-ps-test-coverage.md`). |
| AC4 | 4 | Jest: `test/poshqc-folder-picker.test.ts` (canPickMany, seeded picked, persist round-trip); `test/extension.run-poshqc-commands.test.ts` picker multi-select case. |
| AC5 | 1 | Jest: `test/extension.run-poshqc-commands.test.ts` failure-semantics test — `CommandExecutionError` with `exitCode`/`stdout`/`stderr` and unchanged `getStderrExcerpt` while terminal tee active. |
| AC6 | 1 | Jest: `test/mcp-server.test.ts` — MCP `run_poshqc_test` creates no terminal, uses buffered sink. |
| AC7 | 2 | Baseline evidence recorded: `evidence/baseline/junit-diff-task-vs-command.md`, `evidence/baseline/pester-excludedpath-empirical.md`. |
| AC8 | 3 | Pester `PoshQC.ScanConfig.Tests.ps1` (malformed JSON, wrong version, blank/absolute/`..` entries) + Jest `poshqc-scan-config.test.ts`. |
| AC9 | 3 | Pester `PoshQC.ScanConfig.Tests.ps1` skip-missing-with-warning, all-missing throw; explicit `-ScanFolders` retains throw-on-missing (precedence suite). |
| AC10 | 3 | Pester `PoshQC.ScanFolders.Tests.ps1` scan-config precedence It blocks (explicit override, config over Run.Path, empty falls back to defaults). |
| AC11 | 3 | Jest `poshqc-scan-config.test.ts` — canonical write (relative, forward-slash, deduped, sorted) + read-after-write round-trip. |
| AC12 | 3 | MCP description strings updated in `mcp-tool-definitions.ts` and `mcp-repo-automation-tool-definitions.ts`; `run_poshqc_test` config-driven default; MCP run 1103/0 (`evidence/qa-gates/final-ps-test-coverage.md`). |
| AC13 | 4 | Jest `poshqc-folder-picker.test.ts` cancel (`undefined`) — no write, no run. |
| AC14 | 4 | Jest `poshqc-folder-picker.test.ts` empty selection — info message, no write, no run. |
| AC15 | 4 | Jest `poshqc-folder-picker.test.ts` depth-2 enumeration excluding default-excluded dirs; missing config folder shown with `$(warning)` marker. |
| AC16 | X | `evidence/qa-gates/file-size-check.md` (all files <= 500; `repo-automation-service.ts` no diff); `evidence/qa-gates/coverage-comparison.md` (line >= 85%, branch >= 75% changed code, no regression). |

## Behavioral Finding (does not affect any AC result)

Running the bundled command wrapper (`run-poshqc-test.ps1`) against this development repository
reports 31 failures in PoshQC's own self-mocking test files (`PoshQC.Comprehensive.Tests.ps1`,
`PoshQC.EntryPoints.Tests.ps1`, `PoshQC.ScanFolders.Tests.ps1`) with
`Mock data are not setup for this scope`. This is a module-instance collision caused by the wrapper
pre-importing the bundled `PoshQC` module while Pester also discovers PoshQC's own tests that
re-import and `Mock -ModuleName PoshQC`. It is a direct and expected consequence of FR2.2 (removing
the bundled `RequiredModules` block to achieve byte-identical parity with the workspace manifest).
AC2's stated acceptance is discovered-test-set parity, which holds (1103=1103). The authoritative
task/MCP path passes 0 failures, and production consumer repos do not contain PoshQC's own tests,
so the collision cannot occur there. Full analysis: `evidence/regression-testing/junit-diff-post-change.md`.
