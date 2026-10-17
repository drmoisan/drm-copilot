# 2026-10-16-pester-profiler-coverage (Remediation Plan, Cycle 2)

- **Issue:** #953
- **Branch:** `bug/pester-profiler-coverage-953`
- **Work Mode:** full-bug (acceptance criteria source: `docs/features/active/2026-10-16-pester-profiler-coverage-953/spec.md`; this cycle adds no acceptance criterion and changes no checkbox)
- **Inputs:** `docs/features/active/2026-10-16-pester-profiler-coverage-953/remediation-inputs.2026-10-16T14-11.md` (PA-3 / CR-7), `docs/features/active/2026-10-16-pester-profiler-coverage-953/code-review.2026-10-16T14-11.md` (CR-7 to CR-17), `docs/features/active/2026-10-16-pester-profiler-coverage-953/policy-audit.2026-10-16T14-11.md`, `docs/features/active/2026-10-16-pester-profiler-coverage-953/feature-audit.2026-10-16T14-11.md`; reference plans `docs/features/active/2026-10-16-pester-profiler-coverage-953/plan.2026-10-16T00-16.md` (Phase 8 executed through P8-T18) and `docs/features/active/2026-10-16-pester-profiler-coverage-953/remediation-plan.2026-10-16T10-24.md` (cycle 1).
- **Planning-time head:** `50c4e6ee8`. Every line citation below was re-derived against the working tree at this head.
- **Last Updated:** 2026-10-16
- **Status:** Draft revision 1.2 (preflight delta D1 applied; orchestrator decision D17 drops CR-14; round-2 delta D1 re-derives the P2-T13 `if: always()` line citation against the edited file), pending executor preflight
- **Version:** 1.1

## Scope

Orchestrator decision D16 brings these findings of `code-review.2026-10-16T14-11.md` into this cycle:

- **CR-7 (Blocking, PA-3):** no test asserts the result-check step of the `poshqc` merge job.
- **CR-8:** the merged coverage report keeps METHOD and CLASS figures from shard 1.
- **CR-9:** the CHANGELOG and both README copies do not describe the shard parameters or the six new exports.
- **CR-10:** round-robin assignment by position leaves the shards unbalanced (CI run 38909263798: 214 s, 340 s, 603 s).
- **CR-11:** the shard count is written four times in `_poshqc.yml`.
- **CR-12:** the default `WriteShardFileList` seam body is not executed by any test.
- **CR-13:** an empty shard slice reaches Pester with an empty `Run.Path`.
- **CR-17:** `PoshQC.Testing.psm1` is at 484 of 500 lines.

Orchestrator decision D17 (revision 1.1, from executor preflight observation O1) removes CR-14 from this cycle. The `poshqc` merge job keeps `if: always()` at `.github/workflows/_poshqc.yml:79`. Reason: with `if: ${{ !cancelled() }}`, a cancelled run can leave the required check `poshqc / PowerShell QC` skipped, and GitHub treats a skipped required check as non-blocking; with `if: always()` the job runs the result-check step (`_poshqc.yml:82-90`) and fails the check. Test WF01 is retained as a CR-7 test that asserts the job-level `if: always()` condition, which strengthens the CR-7 coverage.

Out of scope: CR-14 (D17; the job-level condition stays `if: always()`); CR-15 and CR-16 (informational); PA-N1 and PA-N5 (orchestrator, P8-T19); PA-N6; `.github/workflows/ci.yml`; every workflow `on:` block (lines 1-5 of `_poshqc.yml` unchanged); the `poshqc-linux-hooks` job (unchanged). The job id `poshqc` and its name `PowerShell QC` stay. PA-1 and PA-2 (`awaiting_ci`) are resolved by reference-plan tasks P8-T19 and P8-T20 on the PR head that contains this cycle's commits; this plan adds no CI task.

## Files Written

This section is the declared blast radius of this cycle. No other tracked path is written.

Source, workflow, tests, and documentation (14 paths, the CYCLE_FILES set):

1. `scripts/powershell/PoshQC/PoshQC.Shard.psm1`: `Get-PoshQCShardSlice` rewritten (lines 1-36), `New-PoshQCShardManifest` gains `-Weight`, and the internal function `Select-PoshQCShardTestFile` is appended. Edit tool.
2. `extensions/drm-copilot/resources/powershell/PoshQC/PoshQC.Shard.psm1`: identical to item 1, written with `Copy-Item`.
3. `scripts/powershell/PoshQC/PoshQC.CoverageMerge.psm1`: help line 34 and one block inserted before line 89. Edit tool.
4. `extensions/drm-copilot/resources/powershell/PoshQC/PoshQC.CoverageMerge.psm1`: identical to item 3, written with `Copy-Item`.
5. `scripts/powershell/PoshQC/PoshQC.Testing.psm1`: help line 156 and lines 411-419 only. Edit tool.
6. `extensions/drm-copilot/resources/powershell/PoshQC/PoshQC.Testing.psm1`: identical to item 5, written with `Copy-Item`.
7. `.github/workflows/_poshqc.yml`: lines 38-39, 62, 129, and 133, and one line inserted after line 128 (line 79, `    if: always()`, is unchanged under D17). Edit tool.
8. `tests/scripts/workflows/PoshQcWorkflow.Tests.ps1`: line 108, one block inserted after line 47, and one block inserted after line 120.
9. `tests/scripts/powershell/PoshQC/PoshQC.Shard.Tests.ps1`: line 34 and one block inserted after line 57.
10. `tests/scripts/powershell/PoshQC/PoshQC.CoverageMerge.Tests.ps1`: lines 93, 136, and 137, and one block inserted after line 140.
11. `tests/scripts/powershell/PoshQC/PoshQC.TestingShard.Tests.ps1`: one block inserted after line 114.
12. `scripts/powershell/PoshQC/README.md`: one block inserted after line 61 and one after line 76. Edit tool.
13. `extensions/drm-copilot/resources/powershell/PoshQC/README.md`: identical to item 12, written with `Copy-Item`.
14. `extensions/drm-copilot/CHANGELOG.md`: one block inserted after line 28. Edit tool.

Feature folder (planning and evidence):

15. `docs/features/active/2026-10-16-pester-profiler-coverage-953/remediation-plan.2026-10-16T14-19.md` (this plan; checkbox state only during execution).
16. `docs/features/active/2026-10-16-pester-profiler-coverage-953/evidence/remediation-baseline/*.md`
17. `docs/features/active/2026-10-16-pester-profiler-coverage-953/evidence/regression-testing/*.md`
18. `docs/features/active/2026-10-16-pester-profiler-coverage-953/evidence/qa-gates/*.md`
19. `docs/features/active/2026-10-16-pester-profiler-coverage-953/evidence/other/*.md`

Not tracked: `artifacts/pester/*` (git-ignored), `.claude/state/*` (git-ignored), and every scratch file under SCRATCH.

Never written: `.github/workflows/ci.yml`; the `on:` block of any `.github/workflows/*.yml` file; the `poshqc-linux-hooks` job of `.github/workflows/_poshqc.yml`; `scripts/powershell/PoshQC/PoshQC.psm1` and `scripts/powershell/PoshQC/PoshQC.psd1` and their bundled copies (the new function is internal and needs no export change); `tests/scripts/dev_tools/test_poshqc_bundled_parity.py` (the README is not in `POSHQC_PARITY_PATHS`, lines 9-21); `docs/features/active/2026-10-16-pester-profiler-coverage-953/spec.md`; `.claude/rules/**`; `.github/instructions/**`; any `.py`, `.sh`, or `.json` file.

## Fail-Closed Rules

- **Evidence rule.** Every artifact named below is mandatory. An artifact missing any of `Timestamp:`, `Command:`, `EXIT_CODE:`, or `Output Summary:` leaves its task unchecked, and the cycle outcome is BLOCKED, never PASS.
- **Evidence filename timestamps.** Every evidence file is named `<name>.<ts>.md`. `<ts>` is the UTC write time read from the host clock immediately before the write (`Get-Date -AsUTC -Format yyyy-MM-ddTHH-mm`). A consuming task reads the lexicographically greatest file matching `<name>.*.md` in the named folder. Every evidence name in this plan except `phase0-instructions-read` and `fail-before-exception` starts with `r2-`, so it never collides with an earlier artifact.
- **No MCP PoshQC evidence.** No task uses a `run_poshqc_*` MCP tool. All PoshQC evidence comes from the self-hosted module `scripts/powershell/PoshQC/PoshQC.psd1`.
- **Task ownership.** Every task is executor-owned. Before the executor starts, the orchestrator commits this plan to `bug/pester-profiler-coverage-953`, because an executor in an agent-isolated worktree sees only committed files. `remediation-inputs.2026-10-16T14-11.md` and the three review artifacts are already committed at `50c4e6ee8`.
- **Batch budget.** `.claude/hooks/enforce-powershell-batch-budget.ps1` counts distinct production PowerShell paths written with Write or Edit per session and denies the fourth (`:312-319`, cap 3 at `:333`). Test files never count (`:301-305`). When `artifacts/orchestration/orchestrator-state.json` selects a non-terminal `large`, `remediation`, or `preparation` route, nothing is counted (`:16-23`, `:296-299`).
  - This cycle writes exactly three production PowerShell files with the Edit tool: `scripts/powershell/PoshQC/PoshQC.Shard.psm1`, `scripts/powershell/PoshQC/PoshQC.CoverageMerge.psm1`, and `scripts/powershell/PoshQC/PoshQC.Testing.psm1`. Bundled copies are written only with `Copy-Item` through the Tool route, which the hook does not observe.
  - A session whose state already counts a different production path would reach the cap. If the hook denies a write, the executor stops and reports the denial text. The orchestrator then records a non-terminal `remediation` route in the checkpoint and resumes the executor at the denied task. The executor never bypasses the hook.
- **Tool route.** In an agent-isolated worktree, a PreToolUse guard refuses any typed Bash command whose text contains `pwsh`, `bash`, or `wsl`, and atomic-executor has no PowerShell tool. Every PowerShell command of a task, including a single cmdlet in an acceptance check, runs as follows:
  - **Script.** The executor writes the POSIX shell file `SCRATCH/issue-953-r2-<step>.sh` with the Write tool and runs it from the Bash tool as `sh "<SCRATCH absolute path, forward slashes>/issue-953-r2-<step>.sh"`.
  - **Command line.** The path is written literally: no shell variable, and no `;`, `&&`, `|`, or redirection on that command line.
  - **Fixed body.** Line 1 is `export MSYS_NO_PATHCONV=1`. Line 2 is `pwsh -NoProfile -Command '$S = "<SCRATCH absolute path, forward slashes>"; <task PowerShell text>'`. Inside the single-quoted argument every `'` of the task text is written `'\''`. When the task records the exit code of a final native command, the text ends with `; exit $LASTEXITCODE`.
  - **Step names.** `<step>` is the lowercased task ID (for example `issue-953-r2-p2-t4.sh`), with a `-<n>` suffix when a task needs more than one script. The route probe uses `issue-953-r2-probe.sh` with the same fixed body.
  - **Long runs.** A run longer than the Bash tool timeout (FULL_RUN) is started with the Bash tool's background option; the executor waits for the completion notification, with no sleep or polling loop.
  - **Non-PowerShell commands.** `git` and `poetry run ...` run directly from the Bash tool, except where a task places `git` inside a Tool-route script to parse its output.
  - **Evidence.** `Command:` fields record the script body with the literal `SCRATCH` in place of the host path.
- **Never edit a bundled copy.** No Write or Edit tool call targets a file under `extensions/drm-copilot/resources/powershell/PoshQC/`.
- **No temporary files in tests.** Every test added or edited by this plan reads only checked-in files and in-memory values. `PoshQcWorkflow.Tests.ps1` reads the checked-in workflow text; every mutation in WF03 is an in-memory string.
- **Task-ordering rule.** The only deliberately failing state is introduced by Phase 1 (tests written before the fix). P1-T11 is the single `[expect-fail]` run. No other Pester run takes place between P1-T1 and P4-T3, the pass-after run; the only other test between them is the Python parity pytest of P4-T2, which reads no Pester file. Phase 2 and Phase 3 run no test.
- **Restart rule (Phase 5).** If any task from P5-T1 through P5-T12 fails or changes a tracked file, the executor fixes the cause, and when the fix changes a file under `scripts/powershell/PoshQC/` it re-runs P4-T2 (mirror) before restarting at P5-T1. Evidence from an abandoned pass is kept; consumers read the latest file.
- **Stop rule.** A task whose acceptance states "stop BLOCKED" ends execution: the executor reports the recorded values and does not start the next task.

## Definitions (fixed; the executor does not substitute values)

- **FEATURE** = `docs/features/active/2026-10-16-pester-profiler-coverage-953`.
- **SCRATCH** = `<session scratchpad>/issue-953/`, where `<session scratchpad>` is the session scratchpad directory supplied to the executor at run time (outside the repository). Every file created directly under SCRATCH starts with `issue-953-r2-`. In PowerShell text, `$S` holds the absolute SCRATCH path. Evidence records the literal token `SCRATCH`, never a host path.
- **PLAN_HEAD** = `50c4e6ee8` (the head at which every citation was derived).
- **REM_BASE_SHA** = the commit printed by `git rev-parse HEAD` in P0-T10, before any cycle edit.
- **BASE_SHA** = the commit printed by `git merge-base HEAD origin/main` in P0-T10.
- **FULL_RUN(phase)**: the only run whose coverage counts locally. It passes no `-ScanFolders` and no `-SettingsPath`, and runs through the Tool route, in the background when the Bash tool timeout is shorter than the run. Task PowerShell text:

```powershell
New-Item -ItemType Directory -Force -Path artifacts/pester | Out-Null; $start = [datetime]::UtcNow; pwsh -NoProfile -Command "Import-Module ./scripts/powershell/PoshQC/PoshQC.psd1 -Force; Invoke-PoshQCTest -Root (Get-Location).Path" *> (Join-Path $S 'issue-953-r2-<phase>-poshqc.log'); $exit = $LASTEXITCODE; $end = [datetime]::UtcNow; "EXIT_CODE=$exit SECONDS=$([int]($end - $start).TotalSeconds) START_UTC=$($start.ToString('o'))"; Copy-Item artifacts/pester/powershell-coverage.xml (Join-Path $S 'issue-953-r2-<phase>-coverage.xml') -Force; Copy-Item artifacts/pester/pester-junit.xml (Join-Path $S 'issue-953-r2-<phase>-junit.xml') -Force; exit $exit
```

  `<phase>` is `baseline` in P0-T18 and `final` in P5-T3. `Run.Exit = $true` in `scripts/powershell/PoshQC/settings/pester.runsettings.psd1:4`, so the exit code is 0 only when Pester reports no failure.

  FULL_RUN is valid only when all three of these hold:
  - (a) Both `artifacts/pester/powershell-coverage.xml` and `artifacts/pester/pester-junit.xml` have `LastWriteTimeUtc` later than the printed `START_UTC`, parsed with `[datetime]::Parse('<START_UTC>', [cultureinfo]::InvariantCulture, [System.Globalization.DateTimeStyles]::RoundtripKind).ToUniversalTime()`.
  - (b) The log contains exactly one line with the literal `Code coverage population: source=config` (`scripts/powershell/PoshQC/PoshQC.Testing.psm1:370` writes it), counted with `@(Select-String -LiteralPath (Join-Path $S 'issue-953-r2-<phase>-poshqc.log') -SimpleMatch -Pattern 'Code coverage population: source=config').Count`.
  - (c) The command contains no `-ScanFolders` and no `-SettingsPath` argument.
- **TARGETED_RUN(tag, paths)**: no coverage. It runs through the Tool route, and its doubled single quotes become `'\'''\''` under the Tool-route quoting rule. Task PowerShell text:

```powershell
$env:ISSUE953_PATHS = '<paths joined with ;>'; $env:ISSUE953_JUNIT = Join-Path $S 'issue-953-r2-<tag>-junit.xml'; $start = [datetime]::UtcNow; pwsh -NoProfile -Command 'Import-Module Pester -MinimumVersion 5.4.0 -MaximumVersion 5.99.99 -ErrorAction Stop; $c = New-PesterConfiguration; $c.Run.Path = @($env:ISSUE953_PATHS -split '';''); $c.Run.Exit = $true; $c.CodeCoverage.Enabled = $false; $c.TestResult.Enabled = $true; $c.TestResult.OutputFormat = ''JUnitXml''; $c.TestResult.OutputPath = $env:ISSUE953_JUNIT; $c.Output.Verbosity = ''Detailed''; Invoke-Pester -Configuration $c' *> (Join-Path $S 'issue-953-r2-<tag>.log'); "EXIT_CODE=$LASTEXITCODE START_UTC=$($start.ToString('o'))"
```

  Valid only when the JUnit file has `LastWriteTimeUtc` later than the printed `START_UTC`, parsed as for FULL_RUN.
- **JRP (JUnit Reduction Procedure)**, applied to a JUnit file `J` through the Tool route:
  1. `[xml]$j = Get-Content -Raw -LiteralPath J`.
  2. Totals: the integer attributes `tests`, `failures`, and `errors` of the `testsuites` root element.
  3. A `testcase` is failed when it has a `failure` or `error` child, skipped when it has a `skipped` child, and passed otherwise.
  4. Token check for token `K`: `$hits = @($j.SelectNodes("//testcase[contains(@name, 'K')]"))`. PASS if and only if `$hits.Count -ge 1` and every hit is passed. Zero hits is FAIL.
  5. Failure check for token `K` (fail-before only): PASS if and only if `$hits.Count -ge 1` and every hit is failed. The `failure/@message` text is recorded.
- **CRP (Coverage Reduction Procedure)**, applied to a CoverageGutters (JaCoCo-structured) file `X` through the Tool route:
  1. `[xml]$x = Get-Content -Raw -LiteralPath X`.
  2. Aggregate: `$agg = @($x.report.counter | Where-Object { $_.type -eq 'LINE' })`; require `$agg.Count -eq 1`, else FAIL. `LINE_COVERED = [int]$agg[0].covered`, `LINE_MISSED = [int]$agg[0].missed`, `LINE_TOTAL = LINE_COVERED + LINE_MISSED`, and `LINE_PERCENT = [math]::Round(100.0 * LINE_COVERED / LINE_TOTAL, 2)`.
  3. Root prefix: `$anchor = @($x.report.package | Where-Object { ($_.name -replace '[\\]', '/') -like '*/scripts/powershell/PoshQC' -and @($_.sourcefile | Where-Object { $_.name -ceq 'PoshQC.Testing.psm1' }).Count -eq 1 })`; require `$anchor.Count -eq 1`. `ROOTP` is the normalized anchor name without the trailing `/scripts/powershell/PoshQC`.
  4. Per-file map: every package name, normalized, must start with `ROOTP + '/'` (case-insensitive), else FAIL. Key = (normalized package name minus `ROOTP + '/'`) + `/` + sourcefile name, lowercased. Value = the integers `covered` and `missed` of the single `LINE` counter of the sourcefile. A duplicate key is FAIL.
  5. Cross-check: the per-file `covered` sum equals `LINE_COVERED` and the per-file `missed` sum equals `LINE_MISSED`, else FAIL. `SOURCEFILE_COUNT` is the number of keys.
  6. Line lookup `L(key, nr)`: the `line` child of that sourcefile whose `[int]nr` equals `nr`, reported as `ci=<int> mi=<int>`, or `ABSENT` when none exists. `ABSENT` means the line is not an executable line.
  7. Threshold: PASS if and only if `LINE_TOTAL -gt 0` and `100 * LINE_COVERED -ge 85 * LINE_TOTAL` (integer arithmetic). The 85% line default governs because the root `CLAUDE.md` states no coverage threshold (`.claude/rules/general-unit-test.md`, Coverage Requirements). PowerShell has no branch-coverage gate (Pester does not measure branch coverage).
- **CLD (Changed-Line Derivation)** for a repository path `F`, through the Tool route: `$diff = git diff -U0 <REM_BASE_SHA> -- F`. For every line of `$diff` that matches `^@@ -\S+ \+(\d+)(?:,(\d+))? @@`, take the start `s` (group 1) and the count `c` (group 2, or 1 when group 2 is absent); the added line numbers are `s` through `s + c - 1`, and none when `c` is 0. `CLD(F)` is the ascending list of all added line numbers.
- **MOD_KEYS** (the CRP keys of the three production modules this cycle changes): `scripts/powershell/poshqc/poshqc.shard.psm1`, `scripts/powershell/poshqc/poshqc.coveragemerge.psm1`, `scripts/powershell/poshqc/poshqc.testing.psm1`.
- **R2_SET** (the targeted test set, joined with `;` for TARGETED_RUN): `tests/scripts/workflows/PoshQcWorkflow.Tests.ps1`, `tests/scripts/powershell/PoshQC/PoshQC.Shard.Tests.ps1`, `tests/scripts/powershell/PoshQC/PoshQC.CoverageMerge.Tests.ps1`, `tests/scripts/powershell/PoshQC/PoshQC.TestingShard.Tests.ps1`.
- **OLD_TOKENS** (existing test-name tokens in R2_SET): `SH01-SLICE-ROUND-ROBIN`, `SH02-SLICE-INVALID-INDEX-THROWS`, `SH03-MANIFEST-RELATIVE-PATHS`, `SH04-COMPLETENESS-PASS`, `SH05-COMPLETENESS-MISSING-FILE-THROWS`, `SH06-COMPLETENESS-OVERLAP-THROWS`, `SH07-COMPLETENESS-DIVERGENT-ALL-THROWS`, `SH08-TESTCOUNT-MISMATCH-THROWS`, `SH09-TESTCOUNT-MATCH-PASSES`, `CM01-MERGE-MAX-CI`, `CM02-MERGE-RECOMPUTES-LINE-COUNTERS`, `CM03-MERGE-PRESERVES-DENOMINATOR`, `CM04-MERGE-MISMATCHED-LINES-THROWS`, `CM05-MERGE-SINGLE-REPORT-IDENTITY`, `CM06-MERGE-EMPTY-INPUT-THROWS`, `CM07-SUMMARY-REPORT-LINE`, `TS01-SHARD-RUNPATH-SELECTED`, `TS02-SHARD-FILELIST-WRITTEN-VIA-SEAM`, `TS03-NO-SHARD-RUNPATH-UNCHANGED`.
- **NEW_TOKENS** (the twelve test-name tokens Phase 1 adds): `WF01-POSHQC-MERGE-JOB-RUNS-ALWAYS`, `WF02-POSHQC-RESULT-GATE-PRECEDES-MERGE`, `WF03-RESULT-GATE-CHECK-DETECTS-MUTATIONS`, `WF04-SHARD-COUNT-FROM-MATRIX`, `WF05-MERGE-LOOPS-DERIVE-SHARD-COUNT`, `SH10-SLICE-WEIGHTED-LPT`, `SH11-SLICE-EQUAL-WEIGHTS-ORDINAL-PATH-ORDER`, `SH12-SLICE-WEIGHT-COUNT-MISMATCH-THROWS`, `CM08-MERGE-OMITS-CLASS-AND-METHOD-FIGURES`, `TS04-DEFAULT-FILELIST-SEAM-WRITES-UTF8-JSON`, `TS05-EMPTY-SHARD-SLICE-THROWS`, `TS06-SHARD-WEIGHTED-BY-FILE-SIZE`.
- **FAIL_BEFORE_TOKENS** (the nine cases that fail on the pre-fix production tree): `WF04-SHARD-COUNT-FROM-MATRIX`, `WF05-MERGE-LOOPS-DERIVE-SHARD-COUNT`, `SH10-SLICE-WEIGHTED-LPT`, `SH11-SLICE-EQUAL-WEIGHTS-ORDINAL-PATH-ORDER`, `SH12-SLICE-WEIGHT-COUNT-MISMATCH-THROWS`, `CM02-MERGE-RECOMPUTES-LINE-COUNTERS`, `CM08-MERGE-OMITS-CLASS-AND-METHOD-FIGURES`, `TS05-EMPTY-SHARD-SLICE-THROWS`, `TS06-SHARD-WEIGHTED-BY-FILE-SIZE`.
- **RS tokens** (regression guard for cycle 1; test names in `tests/scripts/powershell/PoshQC/PoshQC.RunSettings.Tests.ps1:35,49,61,74,98,127,146,168,198,216`): `RS01-RUNSETTINGS-PROFILER-MODE`, `RS02-PESTER-CONFIG-USEBREAKPOINTS-FALSE`, `RS03-INSTALLER-PESTER-590`, `RS04-BUNDLED-RUNSETTINGS-PROFILER-MODE`, `RS05-INSTALLER-PESTER-CEILING-BELOW-6`, `RS06-TEST-IMPORT-PESTER-MAXIMUM`, `RS07-WORKFLOW-LINUX-PESTER-RANGE`, `RS08-TEST-IMPORT-PESTER-RANGE-BOUNDS`, `RS09-TEST-PESTER-6-ONLY-ACTIONABLE-ERROR`, `RS10-TEST-PESTER-INBOX-ONLY-ACTIONABLE-ERROR`.
- **BUNDLE_PAIRS** (repository file and bundled copy): `PoshQC.Shard.psm1`, `PoshQC.CoverageMerge.psm1`, `PoshQC.Testing.psm1`, and `README.md`, each under `scripts/powershell/PoshQC/` and `extensions/drm-copilot/resources/powershell/PoshQC/`.
- **CYCLE_FILES**: items 1-14 of "Files Written".

## Assumptions and Advisories

- **CR-7 design.** A scriptblock `$script:GetResultGateViolation` in the `BeforeAll` of `tests/scripts/workflows/PoshQcWorkflow.Tests.ps1` returns the reasons a `poshqc` job text fails to gate on the two job results. It splits the job text into steps at lines of six spaces and `- name:`, finds the first step whose body contains both `${{ needs.poshqc-static.result }}` and `${{ needs.poshqc-shard.result }}`, and requires: both assignments, the `-or` comparison with `'success'`, an `exit 1` line, no step-level `if:`, and a position before the steps `Verify shard completeness` and `Merge PowerShell shard coverage` (`.github/workflows/_poshqc.yml:82-90`, `:107`, `:124`).
  - WF02 asserts zero violations on the committed text.
  - WF03 builds four in-memory mutations of the committed job text (step removed, `-or` replaced by `-and`, `exit 1` replaced by `exit 0`, step moved to the end) and asserts that each yields at least one violation. This is the in-memory fail-before evidence that `remediation-inputs.2026-10-16T14-11.md:25` requests for the gate assertion, kept as a permanent test.
  - WF01 asserts that the `poshqc` job carries exactly one job-level `    if: always()` line (`_poshqc.yml:79`) and no `${{ !cancelled() }}` condition, so the gate step runs on every run outcome, including a failed or cancelled shard run. The existing test at `tests/scripts/workflows/PoshQcWorkflow.Tests.ps1:110` asserts only the 8-space step-level `if: always()` of the shard upload step, so no pre-cycle test asserts the job-level condition.
- **D17 (CR-14 removed).** The merge job condition stays `if: always()`; no workflow task edits line 79. WF01 therefore passes on the pre-fix tree, and its fail-before evidence is the exception dossier of P4-T4 (absence-of-test proof: no line of the pre-cycle test file contains `{4}if:`).
- **CR-8 design: omit, do not recompute.** METHOD and CLASS counters and the `class` and `method` elements describe function and file units whose line ranges the report does not record (a `method` element carries only its first line), so they cannot be recomputed from merged line hits. `Merge-PoshQCCoverageReport` therefore removes every `class` element and every `counter` whose `type` is neither `LINE` nor `INSTRUCTION` before it recomputes the counters. LINE figures remain exact, and INSTRUCTION remains the lower bound described by CR-15. No repository consumer reads METHOD or CLASS (`code-review.2026-10-16T14-11.md:27`); `Convert-PoshQCCoverageToRelative` rewrites path text only (`scripts/powershell/PoshQC/PoshQC.Testing.psm1:107-115`). CM02 (line 93) changes from asserting the kept METHOD counter to asserting its absence, CM05 (lines 136-137) compares only `LINE` and `INSTRUCTION` counters, and CM08 covers `class`, `method`, and `CLASS` input.
- **CR-10 design: longest-processing-time greedy by file size, shard count stays 3.**
  - `Get-PoshQCShardSlice` gains an optional `-Weight [long[]]`. Files are ordered heaviest first, equal weights by `[string]::CompareOrdinal` of the path, and each file goes to the shard with the least assigned weight, then the fewest files, then the lowest index. The function returns the shard's files in input order. For this greedy order the final spread between the heaviest and lightest shard is at most the weight of one file.
  - When `-Weight` is omitted every file weighs 1, which reduces to round-robin in ordinal path order. The existing cases SH01 (`f0`..`f9`), SH03, TS01, and TS02 use inputs whose ordinal order equals their input order, so their expected slices are unchanged (verified by hand at planning time: SH03 shard 2 of 2 still selects `b` and `d`).
  - The weight is the file size in bytes, taken from the `Length` property of the `FileInfo` items that the default `EnumerateTests` seam returns (`scripts/powershell/PoshQC/PoshQC.Testing.psm1:259-273`); a plain string, or an object without `Length`, weighs 1. Tests supply in-memory sizes through the injected `EnumerateTests` seam (TS06) or the `-Weight` argument (SH10, SH11); no file is read.
  - Every shard runs on `windows-latest` from the same checkout, so every shard computes the same sizes and the same assignment. If they did not, `Test-PoshQCShardCompleteness` would fail the merge job (overlap or missing file), so the completeness guarantee is unchanged.
  - Justification: in run 38909263798 the slowest shard took 603 s of 1157 s total test-step time, against an even three-way share of about 386 s, which is below the 480 s trigger. File size is a proxy for duration and is not verified to correlate. P4-T5 records the projected byte balance on the local tree for both the old and the new assignment. The authoritative result is the per-shard timing that reference task P8-T19 records on the PR head. Keeping 3 shards leaves the P8-T19 substitutions ("for each n in 1..3") valid and adds no runner. After CR-11 a different count is a one-line matrix change.
- **CR-11 design.** The shard job passes `-ShardCount ${{ strategy.job-total }}`. The merge step reads `$shardCount` from the `shardCount` field of the shard 1 manifest, which `Test-PoshQCShardCompleteness` has already required to equal the number of manifests in the preceding step, and loops `1..$shardCount` in both places. The matrix list `[1, 2, 3]` is the only place the count is written. WF04 asserts the `strategy.job-total` argument and that the matrix lists exactly `1..N`; WF05 asserts that the merge job contains no literal range of the form `1..<digit>` and that both loops use `1..$shardCount`. The existing test at `tests/scripts/workflows/PoshQcWorkflow.Tests.ps1:108` asserted `-ShardCount 3` and is narrowed to the `-ShardIndex` argument.
- **CR-13 and CR-17 design.** The shard block of `Invoke-PoshQCTest` (`PoshQC.Testing.psm1:411-419`, 9 lines) is replaced by a 4-line call to the new internal function `Select-PoshQCShardTestFile` in `PoshQC.Shard.psm1`, which computes the weights, builds the manifest, throws `Shard <i> of <N> selects no test file` when the slice is empty, and writes the manifest JSON through the `WriteShardFileList` seam. `PoshQC.Testing.psm1` shrinks from 484 to 479 lines. The function is dot-sourced into the module scope by the sub-module loader (`scripts/powershell/PoshQC/PoshQC.psm1:117-139`), so `Invoke-PoshQCTest` can call it without an export, and `PoshQC.psm1` and `PoshQC.psd1` stay unchanged.
- **CR-12 design.** TS04 removes `WriteShardFileList` from the injected seams, mocks `Set-Content` with `-ModuleName PoshQC`, and asserts one call with the manifest path, a UTF-8 encoding, and the JSON `selected` list. The default seam is a scriptblock literal in the parameter block of a module function, so it runs in the PoshQC session state and the module-scoped mock intercepts it. The encoding check `[string] $Encoding -match '(?i)utf-?8'` accepts both a `System.Text.UTF8Encoding` object and the string `utf8`. TS04 passes on the pre-fix tree, because the seam already exists; its fail-before evidence is the exception dossier of P4-T4.
- **AC-08 denominator.** The changed counted lines of `PoshQC.Shard.psm1`, `PoshQC.CoverageMerge.psm1`, and `PoshQC.Testing.psm1` change their per-file LINE totals. Reference task P8-T19 already evaluates `TOTAL_EQUAL` over every key except the four PoshQC keys (`plan.2026-10-16T00-16.md:703`), so no reference-plan change is needed. P5-T4 checks that no other per-file total changes.
- **Local Pester.** Cycle 1 installed Pester 5.9.0 for the CurrentUser scope (`docs/features/active/2026-10-16-pester-profiler-coverage-953/evidence/remediation-baseline/r1-local-pester-precondition.*.md`). P0-T2 confirms an in-range Pester is still present; no task installs a module.
- **Acceptance-criteria re-verification.** This cycle changes files that carry evidence for AC-02, AC-06, AC-07, AC-11, AC-13, AC-14, and AC-15. Phase 5 re-verifies them. The executor does not change any checkbox in `spec.md`. If a re-verification fails and cannot be fixed within the restart rule, the executor records `AC_RECHECK_FAILED: <AC>` in P5-T14 and stops for an orchestrator decision. AC-08 to AC-12 remain CI-dependent (P8-T19, P8-T20).
- **Coverage authority.** Local FULL_RUN values (cycle baseline and final) supply the policy-required baseline, post-change, and changed-line values for this cycle. The CI artifact comparison stays with reference task P8-T19.
- **No evidence location override was supplied.** All evidence paths are canonical `FEATURE/evidence/<kind>/` paths.

## Requirements Traceability

| Item | Implementation tasks | Tests | Evidence tasks |
|---|---|---|---|
| CR-7 | P1-T2, P1-T3 (test-only; the workflow gate step at `_poshqc.yml:82-90` and the job condition at `_poshqc.yml:79` are unchanged) | `WF01-POSHQC-MERGE-JOB-RUNS-ALWAYS`, `WF02-POSHQC-RESULT-GATE-PRECEDES-MERGE`, `WF03-RESULT-GATE-CHECK-DETECTS-MUTATIONS` | P1-T11, P2-T13, P4-T3, P4-T4, P5-T3 |
| CR-8 | P2-T4, P2-T5 | `CM02-MERGE-RECOMPUTES-LINE-COUNTERS`, `CM05-MERGE-SINGLE-REPORT-IDENTITY`, `CM08-MERGE-OMITS-CLASS-AND-METHOD-FIGURES` | P1-T11, P4-T3, P5-T3, P5-T4 |
| CR-9 | P3-T1, P3-T2, P3-T3, P4-T2 | README and CHANGELOG token counts | P5-T11 |
| CR-10 | P2-T1, P2-T2, P2-T3, P2-T8, P2-T10 | `SH10-SLICE-WEIGHTED-LPT`, `SH11-SLICE-EQUAL-WEIGHTS-ORDINAL-PATH-ORDER`, `SH12-SLICE-WEIGHT-COUNT-MISMATCH-THROWS`, `TS06-SHARD-WEIGHTED-BY-FILE-SIZE` | P1-T11, P4-T3, P4-T5, P5-T3 |
| CR-11 | P2-T11, P2-T12 | `WF04-SHARD-COUNT-FROM-MATRIX`, `WF05-MERGE-LOOPS-DERIVE-SHARD-COUNT` | P1-T11, P2-T13, P2-T14, P4-T3, P5-T7 |
| CR-12 | P1-T9 (test) | `TS04-DEFAULT-FILELIST-SEAM-WRITES-UTF8-JSON` | P0-T18, P4-T3, P4-T4, P5-T4 |
| CR-13 | P2-T3, P2-T8 | `TS05-EMPTY-SHARD-SLICE-THROWS` | P1-T11, P4-T3, P5-T3 |
| CR-17 | P2-T8 | line counts | P2-T9, P5-T8 |
| AC-02 | P4-T2 | `tests/scripts/dev_tools/test_poshqc_bundled_parity.py::test_poshqc_bundled_module_files_match_repo_root_sources` | P4-T2, P5-T5, P5-T6 |
| AC-06 | P3-T3 | CHANGELOG token counts | P5-T11 |
| AC-07 | P1-T1 through P3-T3 | full self-hosted suite | P5-T1, P5-T2, P5-T3, P5-T13 |
| AC-11 | P2-T1 through P2-T12 | `PoshQcWorkflow.Tests.ps1`, `PoshQC.Shard.Tests.ps1`, `PoshQC.CoverageMerge.Tests.ps1`, `PoshQC.TestingShard.Tests.ps1` | P5-T3, P5-T9, P5-T10 |
| AC-13 | scope constraint | `on:` block and `ci.yml` comparison | P5-T9 |
| AC-14 | scope constraint | path-prefix check | P5-T12 |
| AC-15 | size constraint | line counts | P1-T10, P2-T6, P2-T9, P5-T8 |

## Implementation Plan

### Phase 0 — Baseline Capture (cycle 2)

All baseline artifacts go to `docs/features/active/2026-10-16-pester-profiler-coverage-953/evidence/remediation-baseline/`.

- [x] [P0-T1] Probe the Tool route. Write `SCRATCH/issue-953-r2-probe.sh` with the fixed body whose task PowerShell text is `$PSVersionTable.PSVersion.ToString()`, and run it from the Bash tool as `sh "<SCRATCH absolute path, forward slashes>/issue-953-r2-probe.sh"`.
  - Acceptance: the script exits 0 and prints a version. Otherwise record `TOOL_ROUTE: DENIED` in the report and stop BLOCKED.
- [x] [P0-T2] Confirm an in-range local Pester and write `docs/features/active/2026-10-16-pester-profiler-coverage-953/evidence/remediation-baseline/r2-local-pester.<ts>.md`.
  - Through the Tool route, print `RANGE=` followed by `(@(Get-Module -ListAvailable -FullyQualifiedName @{ ModuleName = 'Pester'; ModuleVersion = '5.9.0'; MaximumVersion = '5.99.99' } | ForEach-Object { $_.Version.ToString() }) -join ',')`.
  - Fields: `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:` with the printed line.
  - Acceptance: `RANGE` is non-empty. Otherwise stop BLOCKED: the default `EnsureModule` seam that FULL_RUN executes requires Pester 5.9.0 to 5.99.99 (`scripts/powershell/PoshQC/PoshQC.Testing.psm1:320`).
- [x] [P0-T3] Read the repository-root `CLAUDE.md` (standing instructions, policy reading order) and `.github/copilot-instructions.md` (the tone policy it names as authoritative).
- [x] [P0-T4] Read `.claude/rules/general-code-change.md` (toolchain loop, 500-line limit, fail-fast error handling).
- [x] [P0-T5] Read `.claude/rules/general-unit-test.md` (coverage defaults and precedence, Coverage Exclusion Policy, no temporary files, determinism).
- [x] [P0-T6] Read `.claude/rules/quality-tiers.md` and confirm from `quality-tiers.yml:13-14` that `scripts/powershell/PoshQC` is tier T3 (no property-test or mutation obligation).
- [x] [P0-T7] Read `.claude/rules/powershell.md` (PoshQC toolchain order, change budget, seams, Pester standards).
- [x] [P0-T8] Read `.claude/rules/python.md` (toolchain for the bundled-parity pytest at `tests/scripts/dev_tools/test_poshqc_bundled_parity.py`).
- [x] [P0-T9] Read `.claude/rules/ci-workflows.md` and `.github/instructions/github-actions.instructions.md` (workflow `pwsh` step exit-code rules for `.github/workflows/_poshqc.yml`), then write `docs/features/active/2026-10-16-pester-profiler-coverage-953/evidence/remediation-baseline/phase0-instructions-read.<ts>.md`.
  - Fields: `Timestamp:`, `Policy Order:` (CLAUDE.md, copilot-instructions, general-code-change, general-unit-test, quality-tiers, powershell, python, ci-workflows, github-actions), and the explicit list of the ten files read in P0-T3 through P0-T9: `CLAUDE.md`, `.github/copilot-instructions.md`, `.claude/rules/general-code-change.md`, `.claude/rules/general-unit-test.md`, `.claude/rules/quality-tiers.md`, `quality-tiers.yml`, `.claude/rules/powershell.md`, `.claude/rules/python.md`, `.claude/rules/ci-workflows.md`, `.github/instructions/github-actions.instructions.md`.
  - Acceptance: all ten paths are listed in that order.
- [x] [P0-T10] Record the branch state and write `docs/features/active/2026-10-16-pester-profiler-coverage-953/evidence/remediation-baseline/r2-branch-state.<ts>.md`.
  - Run from the Bash tool: `git fetch origin main`, `git merge-base HEAD origin/main`, `git rev-parse HEAD`, `git branch --show-current`, `git merge-base --is-ancestor 50c4e6ee8 HEAD`, `git diff --name-only 50c4e6ee8 HEAD`, and `git status --porcelain --untracked-files=all`.
  - The file contains `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:` (the name-only and porcelain outputs), `REM_BASE_SHA: <40-hex HEAD>`, `BASE_SHA: <40-hex merge base>`, and `BRANCH: bug/pester-profiler-coverage-953`.
  - Acceptance:
    - Every command exits 0, and the branch value equals `bug/pester-profiler-coverage-953`.
    - Every path listed by `git diff --name-only 50c4e6ee8 HEAD` starts with `docs/features/active/2026-10-16-pester-profiler-coverage-953/`, so every citation derived at PLAN_HEAD still holds.
    - Every porcelain line is either an untracked path under the feature folder (it starts with `?? docs/features/active/2026-10-16-pester-profiler-coverage-953/`) or a modification of exactly this plan file (status ` M`, `M `, or `MM`, path `docs/features/active/2026-10-16-pester-profiler-coverage-953/remediation-plan.2026-10-16T14-19.md`).
    - Otherwise stop BLOCKED and record the offending line.
- [x] [P0-T11] Record bundled-copy identity and write `docs/features/active/2026-10-16-pester-profiler-coverage-953/evidence/remediation-baseline/r2-bundle-identity.<ts>.md`.
  - Through the Tool route, compare `(Get-FileHash -Algorithm SHA256 -LiteralPath <path>).Hash` for each of the four BUNDLE_PAIRS.
  - The file contains `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:`, and one `PAIR_EQUAL: <file name> YES|NO` line per pair.
  - Acceptance: all four pairs record `YES`. Otherwise stop BLOCKED: an Edit-tool repair of a bundled copy is prohibited.
- [x] [P0-T12] Record baseline line counts and write `docs/features/active/2026-10-16-pester-profiler-coverage-953/evidence/remediation-baseline/r2-line-counts.<ts>.md`.
  - Through the Tool route, run `(Get-Content -LiteralPath <path>).Count` for every path in the acceptance list below.
  - The file contains `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:`, and one `LINES: <path> <count>` line per file.
  - Acceptance: the counts are `scripts/powershell/PoshQC/PoshQC.Testing.psm1` 484, `scripts/powershell/PoshQC/PoshQC.Shard.psm1` 165, `scripts/powershell/PoshQC/PoshQC.CoverageMerge.psm1` 156, `scripts/powershell/PoshQC/README.md` 87, `.github/workflows/_poshqc.yml` 185, `extensions/drm-copilot/CHANGELOG.md` 38, `tests/scripts/workflows/PoshQcWorkflow.Tests.ps1` 121, `tests/scripts/powershell/PoshQC/PoshQC.Shard.Tests.ps1` 137, `tests/scripts/powershell/PoshQC/PoshQC.CoverageMerge.Tests.ps1` 171, and `tests/scripts/powershell/PoshQC/PoshQC.TestingShard.Tests.ps1` 115. If any count differs, the planning-time line citations no longer hold: stop BLOCKED.
- [x] [P0-T13] Capture the bundled-parity baseline with `poetry run pytest tests/scripts/dev_tools/test_poshqc_bundled_parity.py -q` and write `docs/features/active/2026-10-16-pester-profiler-coverage-953/evidence/remediation-baseline/r2-parity-pytest.<ts>.md`.
  - Fields: `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:` quoting the summary line. The Output Summary also states that Python coverage is not measured because no Python file is written in this cycle.
  - Acceptance: EXIT_CODE 0 and the summary line contains `1 passed`.
- [x] [P0-T14] Capture the PoshQC format baseline (write-mode tool) and write `docs/features/active/2026-10-16-pester-profiler-coverage-953/evidence/remediation-baseline/r2-poshqc-format.<ts>.md`.
  - Through the Tool route: record `$before = git status --porcelain`, run `pwsh -NoProfile -Command "Import-Module ./scripts/powershell/PoshQC/PoshQC.psd1 -Force; Invoke-PoshQCFormat -Root (Get-Location).Path" *> (Join-Path $S 'issue-953-r2-baseline-format.log')`, record `$LASTEXITCODE`, then record `$after = git status --porcelain`.
  - The Output Summary states the count of log lines that start with `Formatted: ` (case-sensitive; `scripts/powershell/PoshQC/PoshQC.Analyzer.psm1:62`) and whether `$before` equals `$after`. A file that needs no change logs `Already formatted:` instead (`:64`).
  - Acceptance: EXIT_CODE 0, zero `Formatted: ` lines, and `$before` equal to `$after`. If any file was reformatted, record its path as `PRE_EXISTING_FORMAT_DRIFT:`, restore it with `git restore --source=HEAD --worktree -- <path>`, and stop BLOCKED.
- [x] [P0-T15] Capture the PoshQC analyze baseline with `pwsh -NoProfile -Command "Import-Module ./scripts/powershell/PoshQC/PoshQC.psd1 -Force; Invoke-PoshQCAnalyze -Root (Get-Location).Path" *> (Join-Path $S 'issue-953-r2-baseline-analyze.log')` (Tool route) and write `docs/features/active/2026-10-16-pester-profiler-coverage-953/evidence/remediation-baseline/r2-poshqc-analyze.<ts>.md`.
  - Fields: `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:`.
  - Acceptance: EXIT_CODE 0 and the log contains the literal `PSScriptAnalyzer passed: no findings under` (`scripts/powershell/PoshQC/PoshQC.Analyzer.psm1:185`). On a non-zero exit, record the findings and stop BLOCKED.
- [x] [P0-T16] Capture the actionlint baseline through the Tool route with the task text `$cmd = Get-Command actionlint -ErrorAction SilentlyContinue; "GET_COMMAND=$($cmd.Source)"; if ($cmd) { actionlint .github/workflows/_poshqc.yml; exit $LASTEXITCODE } else { 'ACTIONLINT: NOT-AVAILABLE'; exit 1 }` and write `docs/features/active/2026-10-16-pester-profiler-coverage-953/evidence/remediation-baseline/r2-actionlint.<ts>.md`.
  - Fields: `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:` (the `GET_COMMAND` value and any actionlint output).
  - Acceptance: EXIT_CODE 0 with no actionlint output. actionlint resolved on this host in the earlier run recorded in `docs/features/active/2026-10-16-pester-profiler-coverage-953/evidence/qa-gates/final-actionlint.2026-10-16T13-57.md`; if it is not available now, stop BLOCKED.
- [x] [P0-T17] Capture the targeted baseline by running TARGETED_RUN(`baseline-targeted`, R2_SET) and write `docs/features/active/2026-10-16-pester-profiler-coverage-953/evidence/remediation-baseline/r2-targeted-tests.<ts>.md`.
  - Fields: `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:` (the JRP totals and the JRP token check for every OLD_TOKENS entry), and `R2_TARGETED_BASELINE_TESTS: <JRP tests>`.
  - Acceptance: run valid, EXIT_CODE 0, `failures` 0, `errors` 0, and every OLD_TOKENS entry PASS.
- [x] [P0-T18] Capture the full Pester baseline with coverage by running FULL_RUN(baseline) and write `docs/features/active/2026-10-16-pester-profiler-coverage-953/evidence/remediation-baseline/r2-poshqc-test-coverage.<ts>.md`.
  - Fields: `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:`, and `R2_BASELINE_JUNIT_TESTS: <JRP tests>`.
  - The Output Summary contains:
    - The JRP totals (`JUNIT_TESTS`, `JUNIT_FAILURES`, `JUNIT_ERRORS`) and the FULL_RUN wall seconds.
    - The CRP values `LINE_COVERED`, `LINE_MISSED`, `LINE_TOTAL`, `LINE_PERCENT`, and `SOURCEFILE_COUNT`.
    - The per-file `covered` and `missed` values for each MOD_KEYS key.
    - `L('scripts/powershell/poshqc/poshqc.testing.psm1', 174)`: the pre-cycle hit count of the default `WriteShardFileList` seam body (CR-12).
  - Acceptance: FULL_RUN valid, EXIT_CODE 0, `JUNIT_FAILURES` 0, `JUNIT_ERRORS` 0, and every CRP value numeric. If a test fails, record the failed `classname` and `name` values as `PRE_EXISTING_FAILURES:` and stop BLOCKED.

### Phase 1 — Regression Tests (must fail first)

Every edit in this phase uses the Edit tool on a test file (no batch-budget slot). The anchor text quoted in each task is unique in its file at PLAN_HEAD.

- [x] [P1-T1] Edit `tests/scripts/workflows/PoshQcWorkflow.Tests.ps1` line 108: replace `        $job | Should -Match '-ShardIndex \$\{\{ matrix\.shard \}\} -ShardCount 3'` with the line below. No other line changes. WF04 takes over the shard-count assertion.
  - Acceptance: the file contains no `-ShardCount 3` (`@(Select-String -LiteralPath tests/scripts/workflows/PoshQcWorkflow.Tests.ps1 -SimpleMatch -Pattern '-ShardCount 3').Count` is 0, Tool route).

```powershell
        $job | Should -Match '-ShardIndex \$\{\{ matrix\.shard \}\}'
```

- [x] [P1-T2] Edit `tests/scripts/workflows/PoshQcWorkflow.Tests.ps1`: insert the 49 lines below between line 47 (`        }`, closing the `foreach ($jobId in $jobLines.Keys)` loop) and line 48 (`    }`, closing `BeforeAll`), at the indentation shown. Anchor the Edit on lines 44-48 (from `        $script:JobText = @{}` through `    }`). No other line changes.
  - Acceptance: the file contains `$script:GetResultGateViolation = {` (quoted here as the literal this task creates) exactly once.

```powershell

        # Issue #953 (CR-7): returns the reasons a poshqc job text fails to gate on the static and shard job
        # results. An empty result means the gate step reads both results, compares each with 'success' under
        # -or, exits 1, carries no step-level if condition, and precedes the completeness and merge steps.
        $script:GetResultGateViolation = {
            param([string] $JobText)
            $steps = [System.Collections.Generic.List[object]]::new()
            foreach ($line in ($JobText -split "`n")) {
                if ($line -match '^ {6}- name:[ \t]*(?<Name>.+?)[ \t]*$') {
                    $steps.Add([pscustomobject]@{ Name = $Matches['Name']; Body = [System.Collections.Generic.List[string]]::new() })
                } elseif ($steps.Count -gt 0) {
                    $steps[$steps.Count - 1].Body.Add($line)
                }
            }

            $gateIndex = -1
            for ($index = 0; $index -lt $steps.Count; $index++) {
                $body = $steps[$index].Body -join "`n"
                if ($body.Contains('${{ needs.poshqc-static.result }}') -and $body.Contains('${{ needs.poshqc-shard.result }}')) {
                    $gateIndex = $index
                    break
                }
            }
            if ($gateIndex -lt 0) {
                return 'no step reads both needs.poshqc-static.result and needs.poshqc-shard.result'
            }

            $gate = $steps[$gateIndex].Body -join "`n"
            $violations = [System.Collections.Generic.List[string]]::new()
            foreach ($required in @('$staticResult = ''${{ needs.poshqc-static.result }}''', '$shardResult = ''${{ needs.poshqc-shard.result }}''', 'if ($staticResult -ne ''success'' -or $shardResult -ne ''success'') {')) {
                if (-not $gate.Contains($required)) {
                    $violations.Add("the gate step does not contain: $required")
                }
            }
            if ($gate -notmatch '(?m)^ +exit 1[ \t]*$') {
                $violations.Add('the gate step does not exit 1')
            }
            if ($gate -match '(?m)^ {8}if:') {
                $violations.Add('the gate step carries a step-level if condition')
            }
            $names = @($steps | ForEach-Object { $_.Name })
            foreach ($laterStep in @('Verify shard completeness', 'Merge PowerShell shard coverage')) {
                $laterIndex = [array]::IndexOf($names, $laterStep)
                if ($laterIndex -le $gateIndex) {
                    $violations.Add("the gate step does not precede the '$laterStep' step")
                }
            }
            $violations
        }
```

- [x] [P1-T3] Edit `tests/scripts/workflows/PoshQcWorkflow.Tests.ps1`: insert the 47 lines below between the `    }` that closes the case `runs the format and analyze gates in the poshqc-static job (issue #953)` (line 120 at PLAN_HEAD, line 169 after P1-T2) and the final `}` that closes the Describe block. Anchor the Edit on the last three lines of the file (`        $job | Should -Not -Match 'Invoke-PoshQCTest'`, `    }`, `}`) together with the preceding line `        $job | Should -Match 'Invoke-PoshQCAnalyze -Root'`. No other line changes.
  - Acceptance: each of `WF01-POSHQC-MERGE-JOB-RUNS-ALWAYS`, `WF02-POSHQC-RESULT-GATE-PRECEDES-MERGE`, `WF03-RESULT-GATE-CHECK-DETECTS-MUTATIONS`, `WF04-SHARD-COUNT-FROM-MATRIX`, and `WF05-MERGE-LOOPS-DERIVE-SHARD-COUNT` occurs exactly once in the file (counted with `Select-String -SimpleMatch` through the Tool route).

```powershell

    It 'WF01-POSHQC-MERGE-JOB-RUNS-ALWAYS runs the poshqc merge job on every run outcome so a failed or cancelled shard run fails the check (issue #953, CR-7)' {
        $job = $script:JobText['poshqc']
        @([regex]::Matches($job, '(?m)^ {4}if:[ \t]*always\(\)[ \t]*$')).Count | Should -Be 1 -Because 'a skipped required check does not block a merge; always() runs the result gate step'
        $job | Should -Not -Match '(?m)^ {4}if:[ \t]*\$\{\{ !cancelled\(\) \}\}'
    }

    It 'WF02-POSHQC-RESULT-GATE-PRECEDES-MERGE fails the poshqc check unless the static and shard jobs succeeded (issue #953, CR-7)' {
        $violations = @(& $script:GetResultGateViolation $script:JobText['poshqc'])
        ($violations -join '; ') | Should -BeExactly '' -Because 'the gate step is the only link between a failed shard and the poshqc / PowerShell QC check'
    }

    It 'WF03-RESULT-GATE-CHECK-DETECTS-MUTATIONS reports a removed, weakened, non-exiting, or moved gate step (issue #953, CR-7)' {
        # Arrange: every mutation is applied to an in-memory copy of the committed poshqc job text.
        $job = $script:JobText['poshqc']
        $gateBlock = [regex]::Match($job, '(?s) {6}- name:[ \t]*Require the static and shard jobs to succeed\n.*?(?= {6}- name:)').Value
        $gateBlock | Should -Not -BeNullOrEmpty -Because 'the committed poshqc job contains the gate step'
        $mutations = [ordered]@{
            removed  = $job.Replace($gateBlock, '')
            weakened = $job.Replace('-ne ''success'' -or $shardResult', '-ne ''success'' -and $shardResult')
            noExit   = $job.Replace('exit 1', 'exit 0')
            moved    = $job.Replace($gateBlock, '') + "`n" + $gateBlock.TrimEnd("`n")
        }

        # Act / Assert
        foreach ($name in $mutations.Keys) {
            $mutations[$name] | Should -Not -BeExactly $job -Because "the $name mutation changes the job text"
            @(& $script:GetResultGateViolation $mutations[$name]).Count | Should -BeGreaterThan 0 -Because "the $name mutation must be reported"
        }
    }

    It 'WF04-SHARD-COUNT-FROM-MATRIX passes strategy.job-total as the shard count and lists shard indices 1..N (issue #953, CR-11)' {
        $job = $script:JobText['poshqc-shard']
        $job | Should -Match '-ShardIndex \$\{\{ matrix\.shard \}\} -ShardCount \$\{\{ strategy\.job-total \}\}'
        $matrixLines = @($job -split "`n" | Where-Object { $_ -match '^ {8}shard:[ \t]*\[' })
        $matrixLines.Count | Should -Be 1
        $indices = @([regex]::Matches($matrixLines[0], '\d+') | ForEach-Object { [int] $_.Value })
        $indices.Count | Should -BeGreaterThan 1
        ($indices -join ',') | Should -BeExactly ((1..$indices.Count) -join ',') -Because 'shard indices must be 1..N, and strategy.job-total supplies N'
    }

    It 'WF05-MERGE-LOOPS-DERIVE-SHARD-COUNT reads the shard count from the shard 1 manifest instead of a literal (issue #953, CR-11)' {
        $job = $script:JobText['poshqc']
        $job | Should -Not -Match '\b1\.\.\d'
        $job | Should -Match '(?m)^ +\$shardCount = \[int\] \(Get-Content -Raw -LiteralPath artifacts/shards/poshqc-test-results-shard-1/shard-files\.json \| ConvertFrom-Json\)\.shardCount[ \t]*$'
        @([regex]::Matches($job, '1\.\.\$shardCount')).Count | Should -Be 2
    }
```

- [x] [P1-T4] Edit `tests/scripts/powershell/PoshQC/PoshQC.Shard.Tests.ps1` line 34: replace `    It 'SH01-SLICE-ROUND-ROBIN assigns positions i where i % ShardCount equals ShardIndex - 1, in input order' {` with the line below. The token and the case body are unchanged; only the description is corrected for the weighted algorithm.
  - Acceptance: `SH01-SLICE-ROUND-ROBIN` occurs exactly once in the file, and the file contains `assigns equally weighted files round-robin in ordinal path order` (quoted here as the literal this task creates).

```powershell
    It 'SH01-SLICE-ROUND-ROBIN assigns equally weighted files round-robin in ordinal path order and returns them in input order' {
```

- [x] [P1-T5] Edit `tests/scripts/powershell/PoshQC/PoshQC.Shard.Tests.ps1`: insert the 35 lines below between line 57 (`    }`, closing SH02) and line 58 (`}`, closing `Describe 'Get-PoshQCShardSlice'`). Anchor the Edit on line 56 (`        { Get-PoshQCShardSlice -TestFile $files -ShardIndex 1 -ShardCount 0 } | Should -Throw '*ShardCount must be at least 1*'`) and lines 57-58. No other line changes.
  - Acceptance: each of `SH10-SLICE-WEIGHTED-LPT`, `SH11-SLICE-EQUAL-WEIGHTS-ORDINAL-PATH-ORDER`, and `SH12-SLICE-WEIGHT-COUNT-MISMATCH-THROWS` occurs exactly once in the file.

```powershell

    It 'SH10-SLICE-WEIGHTED-LPT assigns the heaviest file first to the shard with the least assigned weight' {
        # Arrange
        $files = @('t1', 't2', 't3', 't4', 't5', 't6')
        $weights = [long[]] @(4, 9, 3, 8, 5, 1)

        # Act
        $shard1 = @(Get-PoshQCShardSlice -TestFile $files -Weight $weights -ShardIndex 1 -ShardCount 3)
        $shard2 = @(Get-PoshQCShardSlice -TestFile $files -Weight $weights -ShardIndex 2 -ShardCount 3)
        $shard3 = @(Get-PoshQCShardSlice -TestFile $files -Weight $weights -ShardIndex 3 -ShardCount 3)

        # Assert: the loads are 9 + 1, 3 + 8, and 4 + 5; assignment by position would load 12, 14, and 4.
        ($shard1 -join ',') | Should -BeExactly 't2,t6'
        ($shard2 -join ',') | Should -BeExactly 't3,t4' -Because 'each slice keeps input order'
        ($shard3 -join ',') | Should -BeExactly 't1,t5'
        (@($shard1 + $shard2 + $shard3 | Sort-Object) -join ',') | Should -BeExactly 't1,t2,t3,t4,t5,t6' -Because 'every file is assigned to exactly one shard'
    }

    It 'SH11-SLICE-EQUAL-WEIGHTS-ORDINAL-PATH-ORDER breaks weight ties by ordinal path order, not culture order' {
        # Arrange: the ordinal order is 'A', 'B', 'a'; a culture-aware sort would place 'a' before 'B'.
        $files = @('B', 'a', 'A')
        $weights = [long[]] @(5, 5, 5)

        # Act
        $shard1 = @(Get-PoshQCShardSlice -TestFile $files -Weight $weights -ShardIndex 1 -ShardCount 2)
        $shard2 = @(Get-PoshQCShardSlice -TestFile $files -Weight $weights -ShardIndex 2 -ShardCount 2)

        # Assert: 'A' goes to shard 1 and 'B' to shard 2; 'a' then goes to shard 1, the lower index among equal loads and file counts.
        ($shard1 -join ',') | Should -BeExactly 'a,A' -Because 'each slice keeps input order'
        ($shard2 -join ',') | Should -BeExactly 'B'
    }

    It 'SH12-SLICE-WEIGHT-COUNT-MISMATCH-THROWS rejects a weight list whose length differs from the file list' {
        { Get-PoshQCShardSlice -TestFile @('a', 'b', 'c') -Weight @(1, 2) -ShardIndex 1 -ShardCount 2 } | Should -Throw '*Weight lists 2 values; TestFile lists 3 files*'
    }
```

- [x] [P1-T6] Edit `tests/scripts/powershell/PoshQC/PoshQC.CoverageMerge.Tests.ps1` line 93 (inside CM02): replace `        & $script:Counter $merged "/report/counter[@type='METHOD']" | Should -BeExactly '1/0' -Because 'counters other than LINE and INSTRUCTION are kept from the first report'` with the line below. No other line changes.
  - Acceptance: the file contains `METHOD figures cannot be recomputed from merged line hits` (quoted here as the literal this task creates) exactly once, and no `are kept from the first report`.

```powershell
        $merged.SelectNodes("//counter[@type='METHOD']").Count | Should -Be 0 -Because 'METHOD figures cannot be recomputed from merged line hits, so the merged report omits them (CR-8)'
```

- [x] [P1-T7] Edit `tests/scripts/powershell/PoshQC/PoshQC.CoverageMerge.Tests.ps1` lines 136-137 (inside CM05): replace `        $before = @($original.SelectNodes('//line | //counter') | ForEach-Object { $_.OuterXml })` and `        $after = @($merged.SelectNodes('//line | //counter') | ForEach-Object { $_.OuterXml })` with the two lines below. No other line changes.
  - Acceptance: the file contains `//line | //counter[@type='LINE' or @type='INSTRUCTION']` on exactly two lines.

```powershell
        $before = @($original.SelectNodes("//line | //counter[@type='LINE' or @type='INSTRUCTION']") | ForEach-Object { $_.OuterXml })
        $after = @($merged.SelectNodes("//line | //counter[@type='LINE' or @type='INSTRUCTION']") | ForEach-Object { $_.OuterXml })
```

- [x] [P1-T8] Edit `tests/scripts/powershell/PoshQC/PoshQC.CoverageMerge.Tests.ps1`: insert the 18 lines below between line 140 (`    }`, closing CM05) and line 141 (blank, before CM06). Anchor the Edit on line 139 (``        ($after -join "`n") | Should -BeExactly ($before -join "`n")``), line 140, line 141, and line 142 (`    It 'CM06-MERGE-EMPTY-INPUT-THROWS when no report is supplied' {`). No other line changes.
  - Acceptance: `CM08-MERGE-OMITS-CLASS-AND-METHOD-FIGURES` occurs exactly once in the file.

```powershell

    It 'CM08-MERGE-OMITS-CLASS-AND-METHOD-FIGURES removes class and method elements and every counter other than LINE and INSTRUCTION' {
        # Arrange: each report also carries a class element with one method and a report-level CLASS counter, as Pester writes them.
        $classXml = '<class name="C:/repo/scripts/a/a" sourcefilename="a.ps1"><method name="Invoke-A" desc="()" line="1"><counter type="LINE" missed="1" covered="0" /><counter type="METHOD" missed="1" covered="0" /></method><counter type="CLASS" missed="1" covered="0" /></class>'
        $reports = foreach ($ci in @(@(0, 1, 3, 0), @(2, 0, 1, 0))) {
            (& $script:NewReport $ci).Replace('<package name="C:/repo/scripts/a">', '<package name="C:/repo/scripts/a">' + $classXml).Replace('</report>', '<counter type="CLASS" missed="1" covered="0" /></report>')
        }

        # Act
        [xml] $merged = Merge-PoshQCCoverageReport -CoverageXml $reports

        # Assert
        $merged.SelectNodes('//class').Count | Should -Be 0
        $merged.SelectNodes('//method').Count | Should -Be 0
        $merged.SelectNodes("//counter[@type!='LINE' and @type!='INSTRUCTION']").Count | Should -Be 0
        $merged.SelectNodes('//sourcefile').Count | Should -Be 2 -Because 'sourcefile elements and their lines are kept'
        & $script:Counter $merged "/report/counter[@type='LINE']" | Should -BeExactly '3/1' -Because 'the LINE counters stay exact'
    }
```

- [x] [P1-T9] Edit `tests/scripts/powershell/PoshQC/PoshQC.TestingShard.Tests.ps1`: insert the 42 lines below between line 114 (`    }`, closing the case `rejects a shard index outside 1..ShardCount before Pester runs`) and line 115 (`}`, closing the Describe block). Anchor the Edit on line 112 (`        { Invoke-PoshQCTest @seams -ShardIndex 4 -ShardCount 3 } | Should -Throw '*ShardIndex must be between 1 and 3*'`) through line 115. No other line changes.
  - Acceptance: each of `TS04-DEFAULT-FILELIST-SEAM-WRITES-UTF8-JSON`, `TS05-EMPTY-SHARD-SLICE-THROWS`, and `TS06-SHARD-WEIGHTED-BY-FILE-SIZE` occurs exactly once in the file.

```powershell

    It 'TS04-DEFAULT-FILELIST-SEAM-WRITES-UTF8-JSON writes the manifest through Set-Content in the default WriteShardFileList seam' {
        # Arrange: Set-Content is mocked in the module scope, so no file is written.
        $capture = @{}
        $seams = & $script:NewSeams $capture $script:TestPaths
        $seams.Remove('WriteShardFileList')
        Mock -CommandName Set-Content -ModuleName PoshQC -MockWith { }

        # Act
        Invoke-PoshQCTest @seams -ShardIndex 2 -ShardCount 2 -ShardFileListPath '/shard-root/artifacts/pester/shard-files.json'

        # Assert
        Should -Invoke -CommandName Set-Content -ModuleName PoshQC -Times 1 -Exactly -ParameterFilter {
            $LiteralPath -eq '/shard-root/artifacts/pester/shard-files.json' -and ([string] $Encoding -match '(?i)utf-?8') -and ((@((($Value -join "`n") | ConvertFrom-Json).selected) -join ',') -eq 'tests/t2.Tests.ps1,tests/t4.Tests.ps1')
        }
        (@($capture['RunPath']) -join ',') | Should -BeExactly '/shard-root/tests/t2.Tests.ps1,/shard-root/tests/t4.Tests.ps1'
    }

    It 'TS05-EMPTY-SHARD-SLICE-THROWS stops before Pester runs when the shard selects no test file' {
        # Arrange: two test files cannot fill three shards, so shard 3 selects none.
        $capture = @{}
        $seams = & $script:NewSeams $capture @($script:TestPaths[0], $script:TestPaths[1])

        # Act / Assert
        { Invoke-PoshQCTest @seams -ShardIndex 3 -ShardCount 3 -ShardFileListPath '/shard-root/artifacts/pester/shard-files.json' } | Should -Throw '*Shard 3 of 3 selects no test file*'
        $capture.ContainsKey('RunPath') | Should -BeFalse -Because 'Pester must not run with an empty Run.Path'
        $capture.ContainsKey('ListJson') | Should -BeFalse -Because 'no manifest is written for an empty shard'
    }

    It 'TS06-SHARD-WEIGHTED-BY-FILE-SIZE assigns the heaviest test files first to the least-loaded shard' {
        # Arrange: the injected EnumerateTests seam supplies in-memory sizes through a Length property, as FileInfo items do.
        $capture = @{}
        $sizes = @(400, 100, 300, 200)
        $enumerated = @(0..3 | ForEach-Object { [pscustomobject]@{ FullName = $script:TestPaths[$_]; Length = [long] $sizes[$_] } })
        $seams = & $script:NewSeams $capture $enumerated

        # Act
        Invoke-PoshQCTest @seams -ShardIndex 1 -ShardCount 2

        # Assert: t1 (400) and t2 (100) total 500, as do t3 (300) and t4 (200); assignment by position would give t1 and t3 (700).
        (@($capture['RunPath']) -join ',') | Should -BeExactly '/shard-root/tests/t1.Tests.ps1,/shard-root/tests/t2.Tests.ps1'
    }
```

- [x] [P1-T10] Verify the test edits and write `docs/features/active/2026-10-16-pester-profiler-coverage-953/evidence/other/r2-test-edits.<ts>.md`.
  - Run `git diff --numstat <REM_BASE_SHA> -- tests/scripts/workflows/PoshQcWorkflow.Tests.ps1 tests/scripts/powershell/PoshQC/PoshQC.Shard.Tests.ps1 tests/scripts/powershell/PoshQC/PoshQC.CoverageMerge.Tests.ps1 tests/scripts/powershell/PoshQC/PoshQC.TestingShard.Tests.ps1` from the Bash tool, and `(Get-Content -LiteralPath <path>).Count` for each of the four files through the Tool route.
  - Fields: `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:` (the four numstat rows and the four counts).
  - Acceptance: the line counts are 217 (`PoshQcWorkflow.Tests.ps1`), 172 (`PoshQC.Shard.Tests.ps1`), 189 (`PoshQC.CoverageMerge.Tests.ps1`), and 157 (`PoshQC.TestingShard.Tests.ps1`), each at most 500 (AC-15); the numstat rows list exactly these four files.
- [x] [P1-T11] [expect-fail] Run TARGETED_RUN(`r2-before`, R2_SET) on the pre-fix production tree and write `docs/features/active/2026-10-16-pester-profiler-coverage-953/evidence/regression-testing/r2-regression-fail-before.<ts>.md`.
  - Fields: `Timestamp:`, `Command:`, `EXIT_CODE:`, `ExpectedExitCode: 9`, and `Output Summary:` with the JRP totals, the JRP failure check (step 5) with the failure message for every FAIL_BEFORE_TOKENS entry, and the JRP token check (step 4) for every OLD_TOKENS entry other than `CM02-MERGE-RECOMPUTES-LINE-COUNTERS` and for `WF01-POSHQC-MERGE-JOB-RUNS-ALWAYS`, `WF02-POSHQC-RESULT-GATE-PRECEDES-MERGE`, `WF03-RESULT-GATE-CHECK-DETECTS-MUTATIONS`, and `TS04-DEFAULT-FILELIST-SEAM-WRITES-UTF8-JSON`.
  - Acceptance:
    - Run valid, EXIT_CODE 9 (Pester exits with the failed-test count when `Run.Exit` is set), JRP `tests` equal to `R2_TARGETED_BASELINE_TESTS` (latest `r2-targeted-tests.*.md` in `docs/features/active/2026-10-16-pester-profiler-coverage-953/evidence/remediation-baseline/`) plus 12, `failures` 9, and `errors` 0.
    - Every FAIL_BEFORE_TOKENS failure check PASS, and every listed token check PASS.
  - If any condition fails, stop and report; do not start Phase 2.

### Phase 2 — Production Changes (CR-8, CR-10, CR-11, CR-13, CR-17)

No test runs in this phase (Task-ordering rule). The Edit tool writes exactly three production PowerShell files in this phase (Batch budget).

- [x] [P2-T1] Edit `scripts/powershell/PoshQC/PoshQC.Shard.psm1`: replace lines 1-36 (from the opening `<#` through the closing `}` of `Get-PoshQCShardSlice`) with the 74 lines below. No other line changes in this task.
  - Acceptance: the file contains `[System.Array]::Sort($order, $heaviestFirst)` and `Weight lists $($Weight.Count) values` (quoted here as literals this task creates), each once.

```powershell
<#
.SYNOPSIS
Selects the test files assigned to one shard (issue #953).
.DESCRIPTION
Assigns the files in longest-processing-time order (issue #953, CR-10): heaviest file first, equal weights
in ordinal path order, each file to the shard with the least assigned weight, then the fewest files, then
the lowest index, so the shard loads differ by at most the weight of one file. When Weight is omitted every
file weighs 1, which assigns the files round-robin in ordinal path order. Returns this shard's files in
input order. Throws when ShardCount is below 1, ShardIndex is outside 1..ShardCount, or Weight and TestFile
differ in length.
.PARAMETER TestFile
Ordered list of test file paths to distribute.
.PARAMETER ShardIndex
One-based index of the shard to select.
.PARAMETER ShardCount
Total number of shards.
.PARAMETER Weight
Optional non-negative weight of each test file (for example its size in bytes), parallel to TestFile.
#>
function Get-PoshQCShardSlice {
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [Parameter(Mandatory)][AllowEmptyCollection()][string[]] $TestFile,
        [Parameter(Mandatory)][int] $ShardIndex,
        [Parameter(Mandatory)][int] $ShardCount,
        [long[]] $Weight
    )

    if ($ShardCount -lt 1) {
        throw "ShardCount must be at least 1; received $ShardCount."
    }
    if ($ShardIndex -lt 1 -or $ShardIndex -gt $ShardCount) {
        throw "ShardIndex must be between 1 and $ShardCount; received $ShardIndex."
    }
    if ($null -eq $Weight) {
        $Weight = [long[]] (@(1) * $TestFile.Count)
    }
    if ($Weight.Count -ne $TestFile.Count) {
        throw "Weight lists $($Weight.Count) values; TestFile lists $($TestFile.Count) files."
    }

    $order = [int[]] @(for ($position = 0; $position -lt $TestFile.Count; $position++) { $position })
    $heaviestFirst = [System.Comparison[int]] {
        param([int] $Left, [int] $Right)
        $byWeight = $Weight[$Right].CompareTo($Weight[$Left])
        if ($byWeight -ne 0) { return $byWeight }
        [string]::CompareOrdinal($TestFile[$Left], $TestFile[$Right])
    }
    [System.Array]::Sort($order, $heaviestFirst)

    $load = New-Object 'long[]' $ShardCount
    $fileCount = New-Object 'int[]' $ShardCount
    $selected = New-Object 'System.Collections.Generic.HashSet[int]'
    foreach ($position in $order) {
        $target = 0
        for ($shard = 1; $shard -lt $ShardCount; $shard++) {
            if ($load[$shard] -lt $load[$target] -or ($load[$shard] -eq $load[$target] -and $fileCount[$shard] -lt $fileCount[$target])) {
                $target = $shard
            }
        }
        $load[$target] += $Weight[$position]
        $fileCount[$target]++
        if ($target -eq $ShardIndex - 1) {
            [void] $selected.Add($position)
        }
    }

    for ($position = 0; $position -lt $TestFile.Count; $position++) {
        if ($selected.Contains($position)) {
            $TestFile[$position]
        }
    }
}
```

- [x] [P2-T2] Edit `New-PoshQCShardManifest` in `scripts/powershell/PoshQC/PoshQC.Shard.psm1` with two Edit calls and no other line change:
  1. Replace the three lines `.PARAMETER ShardCount`, `Total number of shards.`, `#>` that are immediately followed by `function New-PoshQCShardManifest {` (anchor on all four lines) with the five lines `.PARAMETER ShardCount`, `Total number of shards.`, `.PARAMETER Weight`, `Optional weight of each test file, passed to Get-PoshQCShardSlice.`, `#>`, keeping the function line.
  2. Replace the four lines `        [Parameter(Mandatory)][int] $ShardCount`, `    )`, blank, `    $selected = @(Get-PoshQCShardSlice -TestFile $TestFile -ShardIndex $ShardIndex -ShardCount $ShardCount)` with the nine lines below.
  - Acceptance: the file contains `$sliceArguments['Weight'] = $Weight` (quoted here as the literal this task creates) exactly once and no `-TestFile $TestFile -ShardIndex $ShardIndex -ShardCount $ShardCount)`.

```powershell
        [Parameter(Mandatory)][int] $ShardCount,
        [long[]] $Weight
    )

    $sliceArguments = @{ TestFile = $TestFile; ShardIndex = $ShardIndex; ShardCount = $ShardCount }
    if ($PSBoundParameters.ContainsKey('Weight')) {
        $sliceArguments['Weight'] = $Weight
    }
    $selected = @(Get-PoshQCShardSlice @sliceArguments)
```

- [x] [P2-T3] Edit `scripts/powershell/PoshQC/PoshQC.Shard.psm1`: append the 46 lines below after the final `}` of `Test-PoshQCShardTestCount`. Anchor the Edit on the last six lines of the file (from `    if ($sum -ne $DiscoveryCount) {` through the final `}`). No other line changes.
  - Acceptance: the file contains `function Select-PoshQCShardTestFile {`, `selects no test file; $($paths.Count) test files cannot fill`, and `[OutputType([string[]])]` (quoted here as literals this task creates), each once.

```powershell

<#
.SYNOPSIS
Selects this shard's test files for Invoke-PoshQCTest (issue #953).
.DESCRIPTION
Weights each enumerated test file by its Length property (the size in bytes of the FileInfo items that the
default EnumerateTests seam returns; 1 for a plain path string or an item without a Length property), builds
the manifest with New-PoshQCShardManifest, and throws when the shard selects no test file (CR-13), so Pester
never runs with an empty Run.Path. When ShardFileListPath is set, WriteShardFileList receives the path and
the manifest JSON without selectedFullPath. Returns the full paths of the selected files.
.PARAMETER RootPath
Workspace root that the manifest paths are relative to.
.PARAMETER TestFile
Enumerated test files: FileInfo items, objects with FullName (and optionally Length), or path strings.
.PARAMETER ShardIndex
One-based index of the shard.
.PARAMETER ShardCount
Total number of shards.
.PARAMETER ShardFileListPath
Optional path that receives the shard manifest JSON.
.PARAMETER WriteShardFileList
Seam that writes the manifest JSON; receives the path and the JSON text.
#>
function Select-PoshQCShardTestFile {
    [CmdletBinding()]
    [OutputType([string[]])]
    param(
        [Parameter(Mandatory)][string] $RootPath,
        [Parameter(Mandatory)][AllowEmptyCollection()][object[]] $TestFile,
        [Parameter(Mandatory)][int] $ShardIndex,
        [Parameter(Mandatory)][int] $ShardCount,
        [string] $ShardFileListPath,
        [Parameter(Mandatory)][scriptblock] $WriteShardFileList
    )

    $paths = [string[]] @($TestFile | ForEach-Object { if ($_ -is [string]) { $_ } else { $_.FullName } })
    $weights = [long[]] @($TestFile | ForEach-Object { if ($_ -isnot [string] -and $null -ne $_.PSObject.Properties['Length']) { [long] $_.Length } else { [long] 1 } })
    $manifest = New-PoshQCShardManifest -RootPath $RootPath -TestFile $paths -ShardIndex $ShardIndex -ShardCount $ShardCount -Weight $weights
    if (@($manifest.selected).Count -eq 0) {
        throw "Shard $ShardIndex of $ShardCount selects no test file; $($paths.Count) test files cannot fill $ShardCount shards. Lower the shard count."
    }
    if ($ShardFileListPath) {
        & $WriteShardFileList $ShardFileListPath ($manifest | Select-Object -Property shardIndex, shardCount, all, selected | ConvertTo-Json -Depth 4)
    }
    [string[]] $manifest.selectedFullPath
}
```

- [x] [P2-T4] Edit `scripts/powershell/PoshQC/PoshQC.CoverageMerge.psm1` line 34 (help of `Merge-PoshQCCoverageReport`): replace `No coverage threshold is enforced. Returns the merged XML text.` with the two lines below. No other line changes.
  - Acceptance: the file contains `cannot be recomputed from merged line hits (CR-8)` exactly once, and the count of lines containing both `throw` and `percent` (case-insensitive) is 0.

```text
Class and method elements and every counter other than LINE and INSTRUCTION are removed, because they
cannot be recomputed from merged line hits (CR-8). No coverage threshold is enforced. Returns the merged XML text.
```

- [x] [P2-T5] Edit `scripts/powershell/PoshQC/PoshQC.CoverageMerge.psm1`: insert the six lines below immediately before the line `    $setCounter = {` (line 89 at PLAN_HEAD, line 90 after P2-T4), so the existing blank line before it stays and the inserted block ends with a blank line. Anchor the Edit on `    $setCounter = {`. No other line changes.
  - Acceptance: the file contains `[void] $staleNode.ParentNode.RemoveChild($staleNode)` (quoted here as the literal this task creates) exactly once.

```powershell
    # Issue #953 (CR-8): class and method elements, and counters other than LINE and INSTRUCTION, cannot be
    # recomputed from merged line hits and would keep the figures of report 1, so the merged report omits them.
    foreach ($staleNode in @($merged.SelectNodes("//class | //counter[@type!='LINE' and @type!='INSTRUCTION']"))) {
        [void] $staleNode.ParentNode.RemoveChild($staleNode)
    }

```

- [x] [P2-T6] Verify the two edited modules `scripts/powershell/PoshQC/PoshQC.Shard.psm1` and `scripts/powershell/PoshQC/PoshQC.CoverageMerge.psm1` and write `docs/features/active/2026-10-16-pester-profiler-coverage-953/evidence/other/r2-merge-shard-edit.<ts>.md`.
  - Through the Tool route, for each file run `$errors = $null; [void][System.Management.Automation.Language.Parser]::ParseFile((Resolve-Path <path>).Path, [ref]$null, [ref]$errors); $errors.Count` and `(Get-Content -LiteralPath <path>).Count`, and count the lines that start with `function ` and name `Get-PoshQCShardSlice`, `New-PoshQCShardManifest`, `Test-PoshQCShardCompleteness`, `Test-PoshQCShardTestCount`, and `Select-PoshQCShardTestFile` in `PoshQC.Shard.psm1`.
  - Fields: `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:`.
  - Acceptance: both parse-error counts are 0; the line counts are 256 (`PoshQC.Shard.psm1`: 165 - 36 + 74 after P2-T1, + 2 + 5 after P2-T2, + 46 after P2-T3) and 163 (`PoshQC.CoverageMerge.psm1`); each of the five function names is defined exactly once.
- [x] [P2-T7] Edit `scripts/powershell/PoshQC/PoshQC.Testing.psm1` line 156 (help of `Invoke-PoshQCTest`): replace `Number of shards. When greater than 0, Run.Path is set to this shard's round-robin slice of the test files.` with the line below. No other line changes.
  - Acceptance: the file contains `size-balanced slice of the test files (Select-PoshQCShardTestFile)` (quoted here as the literal this task creates) exactly once. Line 412 still contains `round-robin` until P2-T8.

```text
Number of shards. When greater than 0, Run.Path is set to this shard's size-balanced slice of the test files (Select-PoshQCShardTestFile).
```

- [x] [P2-T8] Edit `scripts/powershell/PoshQC/PoshQC.Testing.psm1`: replace lines 411-419 (from `    if ($ShardCount -gt 0) {` through its closing `    }`, the block that calls `New-PoshQCShardManifest` and `$WriteShardFileList`) with the four lines below. No other line changes. Line 174 (the default `WriteShardFileList` seam) is unchanged.
  - Acceptance: the file contains `Select-PoshQCShardTestFile -RootPath $Root` (quoted here as the literal this task creates) exactly once and no `New-PoshQCShardManifest`.

```powershell
    if ($ShardCount -gt 0) {
        # Issue #953 (FR-09, CR-10, CR-13): run only this shard's size-balanced slice of the enumerated test files.
        $config.Run.Path = [string[]] @(Select-PoshQCShardTestFile -RootPath $Root -TestFile @($testFiles) -ShardIndex $ShardIndex -ShardCount $ShardCount -ShardFileListPath $ShardFileListPath -WriteShardFileList $WriteShardFileList)
    }
```

- [x] [P2-T9] Verify `scripts/powershell/PoshQC/PoshQC.Testing.psm1` and write `docs/features/active/2026-10-16-pester-profiler-coverage-953/evidence/other/r2-testing-psm1-edit.<ts>.md`.
  - Through the Tool route: the `ParseFile` error count, `(Get-Content -LiteralPath scripts/powershell/PoshQC/PoshQC.Testing.psm1).Count`, and `@(Select-String -LiteralPath scripts/powershell/PoshQC/PoshQC.Testing.psm1 -SimpleMatch -Pattern '<token>').Count` for the tokens `5.99.99`, `-MaximumVersion $MaximumVersion`, and `Set-Content -LiteralPath $Path -Value $Json -Encoding utf8` (tokens with `$` in single quotes).
  - Fields: `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:`.
  - Through the Tool route, also count the lines containing `round-robin` (`Select-String -SimpleMatch`).
  - Acceptance: 0 parse errors; 479 lines (CR-17, AC-15); each token count is 1 (the cycle-1 ceiling rows still hold, and the default seam body is intact); the `round-robin` count is 0.
- [x] [P2-T10] Edit `.github/workflows/_poshqc.yml` lines 38-39 (the comment above `poshqc-shard:`): replace `  # Issue #953 (FR-09): the Pester suite runs in three round-robin shards; the poshqc job` and `  # below verifies shard completeness and merges the shard coverage reports.` with the two lines below. No other line changes.
  - Acceptance: the file contains no `round-robin`.

```yaml
  # Issue #953 (FR-09, CR-10, CR-11): the Pester suite runs in size-balanced shards. The matrix below is the
  # only place the shard count is written; the poshqc job verifies shard completeness and merges coverage.
```

- [x] [P2-T11] Edit `.github/workflows/_poshqc.yml` line 62: replace `-ShardCount 3` with `-ShardCount ${{ strategy.job-total }}` in the `Invoke-PoshQCTest` line, giving the line below. No other line changes.
  - Acceptance: the file contains `-ShardCount ${{ strategy.job-total }}` exactly once and no `-ShardCount 3`.

```yaml
          Invoke-PoshQCTest -Root "${{ github.workspace }}" -ShardIndex ${{ matrix.shard }} -ShardCount ${{ strategy.job-total }} -ShardFileListPath artifacts/pester/shard-files.json -DisableKoverageCopy
```

- [x] [P2-T12] Edit `.github/workflows/_poshqc.yml` in the step `Merge PowerShell shard coverage`: replace line 129 (`          $coverageXml = @(1..3 | ...`) with the two lines below (the `$shardCount` line, then the `$coverageXml` line), and replace line 133 (`          foreach ($shardNumber in 1..3) {`) with `          foreach ($shardNumber in 1..$shardCount) {`. No other line changes.
  - Acceptance: the file contains no `1..3`, and `1..$shardCount` occurs on exactly two lines.

```yaml
          $shardCount = [int] (Get-Content -Raw -LiteralPath artifacts/shards/poshqc-test-results-shard-1/shard-files.json | ConvertFrom-Json).shardCount
          $coverageXml = @(1..$shardCount | ForEach-Object { Get-Content -Raw -LiteralPath "artifacts/shards/poshqc-test-results-shard-$_/powershell-coverage.xml" })
```

- [x] [P2-T13] Verify `.github/workflows/_poshqc.yml` and write `docs/features/active/2026-10-16-pester-profiler-coverage-953/evidence/other/r2-workflow-edit.<ts>.md`.
  - From the Bash tool, run `git diff --numstat <REM_BASE_SHA> -- .github/workflows/_poshqc.yml` and `git show <REM_BASE_SHA>:.github/workflows/_poshqc.yml` (SHA written literally).
  - Through the Tool route: `(Get-Content -LiteralPath .github/workflows/_poshqc.yml).Count`; `@(Select-String -LiteralPath .github/workflows/_poshqc.yml -SimpleMatch -Pattern 'if: always()').Count`; `@(Select-String -LiteralPath .github/workflows/_poshqc.yml -SimpleMatch -Pattern 'cancelled()').Count`; compare lines 1-5 of the file with lines 1-5 of the `git show` output; and compare the `poshqc-linux-hooks` block of both texts (the line `  poshqc-linux-hooks:` and every following line up to the next line matching `^  [A-Za-z0-9_-]+:\s*$` or the end of the text, trailing blank lines dropped).
  - Fields: `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:`.
  - Acceptance: the numstat row reads `6` added and `5` deleted (lines 38-39, 62, 129, and 133 replaced, plus the `$shardCount` line); the line count is 186; the `if: always()` count is 3 (lines 65, 79, and 181 of the edited file; head lines 65, 79, and 180; the job-level line 79 is kept under D17) and the `cancelled()` count is 0; lines 1-5 are identical; the `poshqc-linux-hooks` blocks are identical.
- [x] [P2-T14] Run actionlint on the edited workflow through the Tool route with the P0-T16 task text and write `docs/features/active/2026-10-16-pester-profiler-coverage-953/evidence/other/r2-actionlint-after-edit.<ts>.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:`.
  - Acceptance: EXIT_CODE 0 with no actionlint output (the `${{ strategy.job-total }}` expression is accepted).

### Phase 3 — Documentation (CR-9)

- [x] [P3-T1] Edit `scripts/powershell/PoshQC/README.md`: insert the six lines below immediately after line 61 (``- `Convert-PoshQCCoverageToRelative`: utility to strip repo-root prefixes and write a `.koverage.xml` copy (used internally by `Invoke-PoshQCTest`).``), anchored on that line. No other line changes.
  - Acceptance: each of the six function names appears at the start of a list item (a line starting with ``- `<name>`:``) exactly once.

```markdown
- `Get-PoshQCShardSlice`: select one shard's test files; with `-Weight` (for example file sizes in bytes) the heaviest files are assigned first to the least-loaded shard.
- `New-PoshQCShardManifest`: build the in-memory shard manifest (`shardIndex`, `shardCount`, `all`, `selected`, `selectedFullPath`).
- `Test-PoshQCShardCompleteness`: throw unless a set of shard manifests selects every test file exactly once.
- `Test-PoshQCShardTestCount`: throw unless the shard test counts sum to a discovery-pass test count.
- `Merge-PoshQCCoverageReport`: merge the CoverageGutters XML texts of the shards at LINE granularity (no file I/O, no threshold).
- `Get-PoshQCCoverageLineSummary`: return covered, missed, total, and percent from a report's LINE counter.
```

- [x] [P3-T2] Edit `scripts/powershell/PoshQC/README.md`: insert the five lines below immediately after the line ``  - Each run logs `Code coverage population: source=<source>; files=<count>` before Pester starts.`` (line 76 at PLAN_HEAD, line 82 after P3-T1), anchored on that line. No other line changes.
  - Acceptance: the file contains `Sharded runs (issue #953)` exactly once and 98 lines in total.

```markdown
- Sharded runs (issue #953): `Invoke-PoshQCTest -ShardIndex <n> -ShardCount <N>` runs only shard n of N.
  - Test files are weighted by size in bytes and assigned heaviest first to the shard with the least assigned weight (ties: fewer files, then the lower shard index; equal sizes are taken in ordinal path order), so every runner that checks out the same tree computes the same assignment.
  - `-ShardFileListPath <path>` writes the shard manifest (`shardIndex`, `shardCount`, `all`, `selected`) as JSON through the `-WriteShardFileList` seam.
  - A shard that selects no test file (more shards than test files) stops with an error before Pester runs.
  - `Merge-PoshQCCoverageReport` merges the shard reports with `ci = max(ci)` per line and recomputes the LINE and INSTRUCTION counters, so the merged LINE figures are exact. It omits `class` and `method` elements and METHOD and CLASS counters, because those cannot be recomputed from line hits.
```

- [x] [P3-T3] Edit `extensions/drm-copilot/CHANGELOG.md`: insert the five lines below immediately after line 28 (``  stops with a message to run `Install-PoshQCTool` instead of loading another version.``) and before the blank line 29, anchored on line 28. No other line changes; lines 1-28 and the `## [0.0.1] - 2026-05-02` section are unchanged.
  - Acceptance: `git diff --numstat <REM_BASE_SHA> -- extensions/drm-copilot/CHANGELOG.md` (Bash tool) reports `5` added and `0` deleted.

```markdown
- PoshQC sharded test runs (issue #953): `Invoke-PoshQCTest` accepts `-ShardIndex`, `-ShardCount`,
  `-ShardFileListPath`, and `-WriteShardFileList`, and assigns test files to shards by size in bytes.
  New exports: `Get-PoshQCShardSlice`, `New-PoshQCShardManifest`, `Test-PoshQCShardCompleteness`,
  `Test-PoshQCShardTestCount`, `Merge-PoshQCCoverageReport`, and `Get-PoshQCCoverageLineSummary`.
  The merged coverage report carries exact LINE counters and omits METHOD and CLASS figures.
```

### Phase 4 — Mirror, Pass-After, and Balance Evidence

- [x] [P4-T1] Run the PoshQC formatter once over the edited tree (write-mode tool) and write `docs/features/active/2026-10-16-pester-profiler-coverage-953/evidence/other/r2-format-prepass.<ts>.md`.
  - Through the Tool route: record `$before = git status --porcelain`, run `pwsh -NoProfile -Command "Import-Module ./scripts/powershell/PoshQC/PoshQC.psd1 -Force; Invoke-PoshQCFormat -Root (Get-Location).Path" *> (Join-Path $S 'issue-953-r2-prepass-format.log')`, record `$LASTEXITCODE`, then record `$after = git status --porcelain`.
  - Fields: `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:` with every log line that starts with `Formatted: ` and whether `$before` equals `$after`.
  - Acceptance: EXIT_CODE 0, and the path of every `Formatted: ` line, normalized to forward slashes, ends with one of the seven PowerShell CYCLE_FILES paths in the repository tree (items 1, 3, 5, 8, 9, 10, 11). Otherwise stop BLOCKED and record the path. This pass may reformat those files; P5-T1 later requires zero `Formatted: ` lines.
- [x] [P4-T2] Mirror and check parity. Through the Tool route, run `Copy-Item -LiteralPath scripts/powershell/PoshQC/<name> -Destination extensions/drm-copilot/resources/powershell/PoshQC/<name> -Force` for each `<name>` in `PoshQC.Shard.psm1`, `PoshQC.CoverageMerge.psm1`, `PoshQC.Testing.psm1`, and `README.md`, then print one `PAIR_EQUAL: <name> True|False` line per BUNDLE_PAIRS pair from `Get-FileHash -Algorithm SHA256`. Then run `poetry run pytest tests/scripts/dev_tools/test_poshqc_bundled_parity.py -q` from the Bash tool. Write `docs/features/active/2026-10-16-pester-profiler-coverage-953/evidence/other/r2-mirror-parity.<ts>.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:` (the four lines and the pytest summary line).
  - Acceptance: all four lines read `True`, and the pytest summary line contains `1 passed` (AC-02).
- [x] [P4-T3] Run TARGETED_RUN(`r2-after`, R2_SET) and write `docs/features/active/2026-10-16-pester-profiler-coverage-953/evidence/regression-testing/r2-regression-pass-after.<ts>.md`.
  - Fields: `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:` with the JRP totals and the JRP token check for every OLD_TOKENS and NEW_TOKENS entry.
  - Acceptance: run valid, EXIT_CODE 0, JRP `tests` equal to `R2_TARGETED_BASELINE_TESTS` plus 12, `failures` 0, `errors` 0, and every token PASS.
- [x] [P4-T4] Write the fail-before exception dossier `docs/features/active/2026-10-16-pester-profiler-coverage-953/evidence/regression-testing/fail-before-exception.<ts>.md` for the four new cases that pass on the pre-fix tree: `WF01-POSHQC-MERGE-JOB-RUNS-ALWAYS`, `WF02-POSHQC-RESULT-GATE-PRECEDES-MERGE`, `WF03-RESULT-GATE-CHECK-DETECTS-MUTATIONS`, and `TS04-DEFAULT-FILELIST-SEAM-WRITES-UTF8-JSON`.
  - Fields: `Timestamp:`, `Command:` (the JRP and CRP reads and the `git show` count below), `EXIT_CODE:`, `Output Summary:`, and `WhyFailingRunImpossible:` stating that WF01 asserts the job-level `if: always()` condition that decision D17 keeps unchanged, that WF02 asserts a gate step that is already committed and must not be removed from the workflow, that WF03 is a check of the WF02 helper, and that TS04 covers an existing seam whose behavior this cycle does not change.
  - Alternative proof section, with values read from evidence on disk or from the pre-cycle commit:
    - WF01: through the Tool route, `@(git show <REM_BASE_SHA>:tests/scripts/workflows/PoshQcWorkflow.Tests.ps1 | Select-String -SimpleMatch -Pattern '{4}if:').Count` (SHA written literally), recorded as `WF01_PRE_CYCLE_JOB_IF_ASSERTIONS: <count>`; 0 is the absence-of-test proof that no pre-cycle test asserts the job-level condition of any job (the only pre-cycle `if:` assertion, line 110, uses `{8}if:`).
    - WF02: the `WF03-RESULT-GATE-CHECK-DETECTS-MUTATIONS` token PASS in the latest `r2-regression-fail-before.*.md` and `r2-regression-pass-after.*.md`, which shows that the WF02 helper reports each of the four in-memory mutations (removed, weakened, no exit, moved).
    - TS04: `L('scripts/powershell/poshqc/poshqc.testing.psm1', 174)` from the latest `r2-poshqc-test-coverage.*.md` in `docs/features/active/2026-10-16-pester-profiler-coverage-953/evidence/remediation-baseline/` (the pre-cycle hit count of the default seam body; absence-of-test proof when `ci=0`).
  - Acceptance: every field is present, both cited evidence values are copied from the named files, the WF03 token reads PASS in both files, and `WF01_PRE_CYCLE_JOB_IF_ASSERTIONS` is 0.
- [x] [P4-T5] Record the projected shard balance on the local tree (CR-10) and write `docs/features/active/2026-10-16-pester-profiler-coverage-953/evidence/other/r2-shard-balance.<ts>.md`.
  - Run through the Tool route this task PowerShell text, which drives the real `Invoke-PoshQCTest` enumeration with only the Pester run and the file-list write injected (no file is written; the injected `InvokePester` does not run Pester):

```powershell
Import-Module ./scripts/powershell/PoshQC/PoshQC.psd1 -Force; $root = (Get-Location).Path; $captured = @{}; foreach ($n in 1..3) { $sink = { param([string] $Path, [string] $Json) $captured[$Path] = $Json }.GetNewClosure(); Invoke-PoshQCTest -Root $root -ShardIndex $n -ShardCount 3 -ShardFileListPath "shard-$n" -WriteShardFileList $sink -InvokePester { param($Config) $null = $Config } -DisableKoverageCopy *> $null }; $manifests = @(1..3 | ForEach-Object { $captured["shard-$_"] | ConvertFrom-Json }); $bytes = @{}; foreach ($relative in $manifests[0].all) { $bytes[$relative] = (Get-Item -LiteralPath (Join-Path $root $relative)).Length }; $all = @($manifests[0].all); $lpt = @($manifests | ForEach-Object { $sum = [long] 0; foreach ($relative in $_.selected) { $sum += $bytes[$relative] }; $sum }); $rr = @(0..2 | ForEach-Object { $sum = [long] 0; for ($i = $_; $i -lt $all.Count; $i += 3) { $sum += $bytes[$all[$i]] }; $sum }); $total = [long] ($bytes.Values | Measure-Object -Sum).Sum; $max = [long] ($bytes.Values | Measure-Object -Maximum).Maximum; "FILE_COUNT=$($all.Count) TOTAL_BYTES=$total MAX_FILE_BYTES=$max"; "RR_BYTES=$($rr -join ',')"; "LPT_BYTES=$($lpt -join ',')"; "LPT_FILES=$(@($manifests | ForEach-Object { @($_.selected).Count }) -join ',')"; "LPT_SPREAD=$(($lpt | Measure-Object -Maximum).Maximum - ($lpt | Measure-Object -Minimum).Minimum)"; "COMPLETE=$(Test-PoshQCShardCompleteness -ShardManifest $manifests)"
```

  - Fields: `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:` with the six printed lines, the CI reference `CI_RUN_38909263798_TEST_STEP_SECONDS: 214,340,603` (`code-review.2026-10-16T14-11.md:29`), and `RR_BYTE_ORDER_MATCHES_CI_ORDER: YES|NO` (YES when the `RR_BYTES` values rank shard 3 above shard 2 above shard 1, the CI duration order). The summary states that byte counts depend on the local line-ending configuration and are a proxy for duration, and that reference task P8-T19 records the authoritative per-shard timings on the PR head.
  - Acceptance: `COMPLETE=True`; every `LPT_FILES` value is at least 1; the sum of `LPT_BYTES` and the sum of `RR_BYTES` both equal `TOTAL_BYTES`; and `LPT_SPREAD` is at most `MAX_FILE_BYTES` (the spread bound of the greedy assignment). `RR_BYTE_ORDER_MATCHES_CI_ORDER` is recorded as an observation and does not gate the task.

### Phase 5 — Final QC Loop

Restart rule: if any task from P5-T1 through P5-T12 fails or changes a tracked file, the executor fixes the cause, re-runs P4-T2 when the fix touched `scripts/powershell/PoshQC/`, and restarts at P5-T1, writing new evidence files. All QC artifacts go to `docs/features/active/2026-10-16-pester-profiler-coverage-953/evidence/qa-gates/`.

- [x] [P5-T1] Run the PoshQC formatter (write-mode tool) and write `docs/features/active/2026-10-16-pester-profiler-coverage-953/evidence/qa-gates/r2-final-poshqc-format.<ts>.md`.
  - Before the formatter runs, compute the SHA256 of every CYCLE_FILES path and record `$before = git status --porcelain` (Tool route).
  - Run `pwsh -NoProfile -Command "Import-Module ./scripts/powershell/PoshQC/PoshQC.psd1 -Force; Invoke-PoshQCFormat -Root (Get-Location).Path" *> (Join-Path $S 'issue-953-r2-final-format.log')`, record `$LASTEXITCODE`, then record `$after = git status --porcelain`.
  - Fields: `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:` (the count of log lines starting with `Formatted: `, the count starting with `Already formatted:`, and whether `$before` equals `$after`), and one `HASH_BEFORE: <path> <SHA256>` line per CYCLE_FILES path.
  - Acceptance: EXIT_CODE 0, zero `Formatted: ` lines, and `$before` equal to `$after` (AC-07: no diff).
- [x] [P5-T2] Run `pwsh -NoProfile -Command "Import-Module ./scripts/powershell/PoshQC/PoshQC.psd1 -Force; Invoke-PoshQCAnalyze -Root (Get-Location).Path" *> (Join-Path $S 'issue-953-r2-final-analyze.log')` (Tool route) and write `docs/features/active/2026-10-16-pester-profiler-coverage-953/evidence/qa-gates/r2-final-poshqc-analyze.<ts>.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:`.
  - Acceptance: EXIT_CODE 0 and the log contains the literal `PSScriptAnalyzer passed: no findings under` (AC-07: zero findings).
- [x] [P5-T3] Run FULL_RUN(final) and write `docs/features/active/2026-10-16-pester-profiler-coverage-953/evidence/qa-gates/r2-final-poshqc-test-coverage.<ts>.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:`.
  - The Output Summary contains the JRP totals, the JRP token check for every OLD_TOKENS, NEW_TOKENS, and RS tokens entry, the FULL_RUN wall seconds, and the CRP values `LINE_COVERED`, `LINE_MISSED`, `LINE_TOTAL`, `LINE_PERCENT`, and `SOURCEFILE_COUNT`.
  - Acceptance:
    - FULL_RUN valid, EXIT_CODE 0, `JUNIT_FAILURES` 0, and `JUNIT_ERRORS` 0 (AC-07: zero failed tests).
    - Every listed token PASS.
    - JRP `tests` equals `R2_BASELINE_JUNIT_TESTS` (latest `r2-poshqc-test-coverage.*.md` in `docs/features/active/2026-10-16-pester-profiler-coverage-953/evidence/remediation-baseline/`) plus 12.
- [x] [P5-T4] Compute the coverage delta from `issue-953-r2-baseline-coverage.xml` and `issue-953-r2-final-coverage.xml` under SCRATCH with CRP, and the changed-line set with CLD, and write `docs/features/active/2026-10-16-pester-profiler-coverage-953/evidence/qa-gates/r2-final-coverage-delta.<ts>.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:`.
  - The Output Summary contains:
    - Baseline and final `LINE_COVERED`, `LINE_TOTAL`, `LINE_PERCENT`, and `SOURCEFILE_COUNT`.
    - Baseline and final per-file `covered` and `missed` for each MOD_KEYS key.
    - For each of `scripts/powershell/PoshQC/PoshQC.Shard.psm1`, `scripts/powershell/PoshQC/PoshQC.CoverageMerge.psm1`, and `scripts/powershell/PoshQC/PoshQC.Testing.psm1`: `CLD` of that path, and for each listed number `nr` the final `L(<its MOD_KEYS key>, nr)`; the counts `CHANGED_LINES`, `EXECUTABLE_CHANGED` (not `ABSENT`), and `UNCOVERED_CHANGED` (`ci=0`), and the list of uncovered numbers.
    - The final `L('scripts/powershell/poshqc/poshqc.testing.psm1', 174)` (CR-12).
  - Acceptance:
    - The final CRP threshold (step 7) PASSES (repository-wide at least 85%).
    - The final key set equals the baseline key set, and for every key outside MOD_KEYS the baseline and final per-file totals (`covered + missed`) are equal.
    - For each MOD_KEYS key, `100 * covered -ge 85 * (covered + missed)` in the final file.
    - `UNCOVERED_CHANGED` is 0 for each of the three files, and `EXECUTABLE_CHANGED` is at least 1 for each.
    - The final `L(..., 174)` has `ci` greater than 0.
  - The Output Summary states that the bundled copies are outside the coverage roots of `config/poshqc-coverage.json:3-9` and are not measured, and that Pester measures no branch coverage.
- [x] [P5-T5] Run `poetry run pytest tests/scripts/dev_tools/test_poshqc_bundled_parity.py -q` and write `docs/features/active/2026-10-16-pester-profiler-coverage-953/evidence/qa-gates/r2-final-parity-pytest.<ts>.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:` quoting the summary line.
  - Acceptance: EXIT_CODE 0 and the summary line contains `1 passed` (AC-02).
- [x] [P5-T6] Verify bundle identity for every BUNDLE_PAIRS pair with `Get-FileHash -Algorithm SHA256` (Tool route) and write `docs/features/active/2026-10-16-pester-profiler-coverage-953/evidence/qa-gates/r2-final-bundle-identity.<ts>.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:`, and one `PAIR_EQUAL: <name> YES|NO` line per pair.
  - Acceptance: all four pairs record `YES` (the README pair is outside the parity pytest).
- [x] [P5-T7] Run actionlint through the Tool route with the P0-T16 task text and write `docs/features/active/2026-10-16-pester-profiler-coverage-953/evidence/qa-gates/r2-final-actionlint.<ts>.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:`.
  - Acceptance: EXIT_CODE 0 with no actionlint output.
- [x] [P5-T8] Verify file sizes (AC-15, CR-17) and write `docs/features/active/2026-10-16-pester-profiler-coverage-953/evidence/qa-gates/r2-final-file-size.<ts>.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:` listing each path and its line count.
  - Build the changed-file set as the union of the paths from `git diff --name-only origin/main...HEAD` and from `git status --porcelain --untracked-files=all` (both from the Bash tool). Keep only paths for which `Test-Path -LiteralPath <path> -PathType Leaf` is true, drop paths ending in `.md`, and record `(Get-Content -LiteralPath <path>).Count` for each remaining path (Tool route).
  - Acceptance:
    - Every count is at most 500.
    - The set includes `scripts/powershell/PoshQC/PoshQC.Testing.psm1`, `scripts/powershell/PoshQC/PoshQC.Shard.psm1`, `scripts/powershell/PoshQC/PoshQC.CoverageMerge.psm1`, `tests/scripts/workflows/PoshQcWorkflow.Tests.ps1`, `tests/scripts/powershell/PoshQC/PoshQC.Shard.Tests.ps1`, `tests/scripts/powershell/PoshQC/PoshQC.CoverageMerge.Tests.ps1`, and `tests/scripts/powershell/PoshQC/PoshQC.TestingShard.Tests.ps1`.
- [x] [P5-T9] Verify AC-13 and the check name, and write `docs/features/active/2026-10-16-pester-profiler-coverage-953/evidence/qa-gates/r2-final-scope-ac13.<ts>.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:`.
  - Run `git diff --name-only origin/main...HEAD` and `git status --porcelain` from the Bash tool.
  - With `$mb = git merge-base origin/main HEAD`, for every file in `Get-ChildItem .github/workflows -Filter *.yml`, extract the `on:` block (from the line matching `^on:` through the line before the next line matching `^\S`) from the worktree file and from `git show "${mb}:.github/workflows/<name>"`, and compare the two (Tool route).
  - In `.github/workflows/_poshqc.yml`, count the lines matching `^  poshqc:\s*$` and the lines matching `^    name: PowerShell QC\s*$` (Tool route, `Select-String` with a regular expression).
  - Acceptance: neither listing contains `.github/workflows/ci.yml`; every `on:` block is identical to the merge-base text; both counts are exactly 1 (job id `poshqc` and name `PowerShell QC` kept, so the check name stays `poshqc / PowerShell QC`).
- [x] [P5-T10] Verify the D3 and ceiling constraints and write `docs/features/active/2026-10-16-pester-profiler-coverage-953/evidence/qa-gates/r2-final-d3-ceiling.<ts>.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:`.
  - Through the Tool route with `Select-String -SimpleMatch` (case-insensitive): in `.github/workflows/_poshqc.yml`, count the lines containing `CoveragePercentTarget`, `-lt 85`, `-ge 85`, or `fail-under`; count the lines containing `Import-Module Pester` and the lines containing `-MaximumVersion 5.99.99`. In `scripts/powershell/PoshQC/PoshQC.CoverageMerge.psm1`, count the lines that contain both `throw` and `percent`.
  - Acceptance: the threshold counts and the `throw`/`percent` count are 0 (D3: no failing coverage threshold); the `Import-Module Pester` count equals the `-MaximumVersion 5.99.99` count, and both are at least 1.
- [x] [P5-T11] Verify the CR-9 documentation and AC-06 and write `docs/features/active/2026-10-16-pester-profiler-coverage-953/evidence/qa-gates/r2-final-docs.<ts>.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:`.
  - Read `extensions/drm-copilot/CHANGELOG.md` and take the lines strictly between the line `## [Unreleased]` and the next line that starts with `## [`. In that section, count the lines containing each of `profiler-based`, `Pester 5.9.0`, `below Pester 6.0`, `-MinimumVersion 5.9.0`, `-ShardIndex`, `-ShardFileListPath`, `-WriteShardFileList`, `Get-PoshQCShardSlice`, `New-PoshQCShardManifest`, `Test-PoshQCShardCompleteness`, `Test-PoshQCShardTestCount`, `Merge-PoshQCCoverageReport`, and `Get-PoshQCCoverageLineSummary`.
  - In `scripts/powershell/PoshQC/README.md`, count the lines containing `Sharded runs (issue #953)` and each of the six export names.
  - Acceptance: every count is at least 1, and the README pair is identical (latest `r2-final-bundle-identity.*.md`).
- [x] [P5-T12] Verify AC-14 and the cycle blast radius, and write `docs/features/active/2026-10-16-pester-profiler-coverage-953/evidence/qa-gates/r2-final-blast-radius.<ts>.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:`, `PYTHON_FILES_CHANGED_THIS_CYCLE: NONE`, and `SHELL_FILES_CHANGED_THIS_CYCLE: NONE`.
  - Build the set as the union of the paths from `git diff --name-only <REM_BASE_SHA>` and from `git status --porcelain --untracked-files=all`, both run from the Bash tool.
  - Acceptance:
    - Every path in the set is a CYCLE_FILES path, this plan file, or a path under `docs/features/active/2026-10-16-pester-profiler-coverage-953/evidence/`.
    - No path ends in `.py`, `.sh`, or `.json`, and the only `.yml` path is `.github/workflows/_poshqc.yml`.
    - No path starts with `.claude/rules/` or `.github/instructions/` (AC-14), and neither `scripts/powershell/PoshQC/PoshQC.psm1` nor `scripts/powershell/PoshQC/PoshQC.psd1` is listed.
- [x] [P5-T13] Record loop closure and write `docs/features/active/2026-10-16-pester-profiler-coverage-953/evidence/qa-gates/r2-final-loop-closure.<ts>.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:`, and `LOOP_CLEAN_PASS: YES|NO`.
  - Recompute the SHA256 of every CYCLE_FILES path and compare each with the `HASH_BEFORE:` lines of the latest `r2-final-poshqc-format.*.md` in `docs/features/active/2026-10-16-pester-profiler-coverage-953/evidence/qa-gates/`.
  - Acceptance: every hash is unchanged, P5-T1 through P5-T12 of this pass passed, and `LOOP_CLEAN_PASS: YES`.
- [x] [P5-T14] Record the re-verification and write `docs/features/active/2026-10-16-pester-profiler-coverage-953/evidence/qa-gates/r2-ac-reverification.<ts>.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:`.
  - The Output Summary has one line per item, `RECHECK: <item> | <evidence tasks> | PASS|FAIL`, for CR-7, CR-8, CR-9, CR-10, CR-11, CR-12, CR-13, CR-17, AC-02, AC-06, AC-07, AC-11, AC-13, AC-14, and AC-15, using the "Requirements Traceability" evidence tasks.
  - Run `git diff --numstat <REM_BASE_SHA> -- docs/features/active/2026-10-16-pester-profiler-coverage-953/spec.md` and `git status --porcelain -- docs/features/active/2026-10-16-pester-profiler-coverage-953/spec.md` from the Bash tool, and record both outputs.
  - Acceptance: every line reads PASS, and both `spec.md` outputs are empty (no checkbox changed and no acceptance criterion added).
  - If any line reads FAIL, record `AC_RECHECK_FAILED: <item>` and stop for an orchestrator decision; the executor does not edit `spec.md`.
