# 2026-10-16-pester-profiler-coverage (Remediation Plan, Cycle 3)

- **Issue:** #953
- **Branch:** `bug/pester-profiler-coverage-953`
- **Work Mode:** full-bug (acceptance criteria source: `docs/features/active/2026-10-16-pester-profiler-coverage-953/spec.md`; this cycle adds no acceptance criterion and changes no checkbox)
- **Inputs:** `docs/features/active/2026-10-16-pester-profiler-coverage-953/remediation-inputs.2026-10-16T17-02.md` (PA-3 / CR-21), `docs/features/active/2026-10-16-pester-profiler-coverage-953/code-review.2026-10-16T17-02.md` (CR-18, CR-19, CR-21), `docs/features/active/2026-10-16-pester-profiler-coverage-953/policy-audit.2026-10-16T17-02.md`, `docs/features/active/2026-10-16-pester-profiler-coverage-953/feature-audit.2026-10-16T17-02.md`; reference plans `docs/features/active/2026-10-16-pester-profiler-coverage-953/plan.2026-10-16T00-16.md`, `docs/features/active/2026-10-16-pester-profiler-coverage-953/remediation-plan.2026-10-16T10-24.md` (cycle 1), and `docs/features/active/2026-10-16-pester-profiler-coverage-953/remediation-plan.2026-10-16T14-19.md` (cycle 2; source of the Tool route, FULL_RUN, TARGETED_RUN, JRP, CRP, and CLD definitions restated below).
- **Planning-time head:** `3d60e3f76`. Every line citation below was re-derived against the working tree at this head.
- **Last Updated:** 2026-10-16
- **Status:** Draft revision 1.1, pending executor preflight (revision 1.1 applies executor preflight deltas D1-D4 and adds the second alone-failing suite found by the orchestrator alone sweep; its citations were re-derived at `789843870`, which differs from PLAN_HEAD only under the feature folder)
- **Version:** 1.1
- **Attempt:** cycle 3 of the three-attempt remediation guard (final attempt).

## Scope

Orchestrator decision D19 brings these findings into this cycle:

- **PA-3 / CR-21 (Blocking, `autonomous`):** CI runs 38935591244 and 38936152953 fail `poshqc / PowerShell QC shard 1` on `tests/scripts/claude-hooks/session-root-reads-850.Constraints.Tests.ps1:80` (`issue #850 changed-file constraints.baseline mock interception probe`: "Expected Get-EpicScopeCheckpointText in module EpicScopeResolution to be called 1 times exactly, but was called 0 times"). The suite passes alone and fails when the CI shard 1 file list runs in order up to it in one Pester process.
- **PA-3 / CR-21, second suite (found in executor preflight):** with this cycle's byte changes, `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.EpicScopeTargets.Tests.ps1` moves into a shard 1 that contains no suite importing `WorktreeResolution` into the global scope, and its outermost `BeforeAll` fails (`Could not find Command Get-WorktreeResolutionGitFileText`). The suite also fails alone on PLAN_HEAD. P2-T7 through P2-T10 remove that dependency on the victim side.
- **PA-3 / CR-21, third suite (found by the orchestrator alone sweep):** `SCRATCH/issue-953-alone-sweep.sh` ran each of the 388 `tests/scripts/**/*.Tests.ps1` suites alone in its own `pwsh -NoProfile` process (Pester 5.9.0, no coverage); exactly two fail alone: EST_SUITE (22 of 22 failed, 1 failed container) and `tests/scripts/claude-lib/orchestrator-state/OrchestratorStateIssueAdoption.Tests.ps1` (49 tests, 45 failed). The second suite is in the same class as CR-21: its result depends on what ran before it in the process, and sharding can separate it from the state it depends on. It is not a FILES_936 path. P2-T11 through P2-T15 record its alone failure, diagnose the cause, apply a test-side fix, and record its pass-after; P5-T17 re-runs the alone sweep on the final tree.
- **CR-18 (Info, same files):** `Get-PoshQCShardSlice` documents non-negative weights but does not reject a negative weight.
- **CR-19 (Info, same files):** shard weights are file sizes in bytes on the checked-out tree, so they depend on the checkout's line-ending conversion; the README sentence overstates the determinism.

Declined under D19 and out of scope: CR-20 (duration weighting), CR-15 and CR-16 (informational), and the PA-N items the orchestrator handles. PA-1 and PA-2 (`awaiting_ci`) are resolved by reference-plan tasks P8-T19 and P8-T20 on the PR head that contains this cycle's commits; this plan adds no CI task. Changing shard weights to move a suite, the shard count, or the matrix length is not an acceptable PA-3 fix and no task does it.

Out of scope and never written: `.github/workflows/**` (no workflow change in this cycle), `.github/workflows/ci.yml`, every workflow `on:` block, `.claude/rules/**`, `.github/instructions/**`, `tests/scripts/codex-hooks/hook-import-failure-exemptions.FailClosed.Tests.ps1` and `tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-epic-scope.Decision.Tests.ps1` (#936-owned, spec D4), `tests/scripts/claude-hooks/EpicStateIsolation.Baseline.Helpers.ps1`, every predecessor suite that bisection names, `scripts/powershell/PoshQC/PoshQC.Testing.psm1`, `scripts/powershell/PoshQC/PoshQC.CoverageMerge.psm1`, `scripts/powershell/PoshQC/PoshQC.psm1`, `scripts/powershell/PoshQC/PoshQC.psd1`, `extensions/drm-copilot/CHANGELOG.md`, and `docs/features/active/2026-10-16-pester-profiler-coverage-953/spec.md`.

## Files Written

This section is the declared blast radius of this cycle. No other tracked path is written.

Tests, source, and documentation (8 paths, the CYCLE_FILES set):

1. `tests/scripts/claude-hooks/session-root-reads-850.Constraints.Tests.ps1`: four lines inserted after line 21. Edit tool (test file; no batch-budget slot).
2. `scripts/powershell/PoshQC/PoshQC.Shard.psm1`: lines 9-10, 216-217, and 247 replaced; five lines inserted after line 41; 35 lines appended after line 256. Edit tool (the only production PowerShell file this cycle writes).
3. `extensions/drm-copilot/resources/powershell/PoshQC/PoshQC.Shard.psm1`: identical to item 2, written with `Copy-Item`.
4. `tests/scripts/powershell/PoshQC/PoshQC.Shard.Tests.ps1`: five lines inserted after line 92 and 46 lines appended after line 172. Edit tool.
5. `scripts/powershell/PoshQC/README.md`: lines 62 and 84 replaced. Edit tool.
6. `extensions/drm-copilot/resources/powershell/PoshQC/README.md`: identical to item 5, written with `Copy-Item`.
7. `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.EpicScopeTargets.Tests.ps1`: three lines inserted after line 24. Edit tool (test file; no batch-budget slot).
8. `tests/scripts/claude-lib/orchestrator-state/OrchestratorStateIssueAdoption.Tests.ps1`: lines 29-30 replaced by five lines. Edit tool (test file; no batch-budget slot).

Feature folder (planning and evidence):

9. `docs/features/active/2026-10-16-pester-profiler-coverage-953/remediation-plan.2026-10-16T17-24.md` (this plan; checkbox state only during execution).
10. `docs/features/active/2026-10-16-pester-profiler-coverage-953/evidence/remediation-baseline/*.md`
11. `docs/features/active/2026-10-16-pester-profiler-coverage-953/evidence/regression-testing/*.md`
12. `docs/features/active/2026-10-16-pester-profiler-coverage-953/evidence/qa-gates/*.md`
13. `docs/features/active/2026-10-16-pester-profiler-coverage-953/evidence/other/*.md`

Not tracked: `artifacts/pester/*` (git-ignored), `.claude/state/*` (git-ignored), and every scratch file under SCRATCH.

## Fail-Closed Rules

- **Evidence rule.** Every artifact named below is mandatory. An artifact missing any of `Timestamp:`, `Command:`, `EXIT_CODE:`, or `Output Summary:` leaves its task unchecked, and the cycle outcome is BLOCKED, never PASS.
- **Evidence filename timestamps.** Every evidence file is named `<name>.<ts>.md`. `<ts>` is the UTC write time read from the host clock immediately before the write (`Get-Date -AsUTC -Format yyyy-MM-ddTHH-mm`). A consuming task reads the lexicographically greatest file matching `<name>.*.md` in the named folder. Every evidence name in this plan except `phase0-instructions-read` starts with `r3-`, so it never collides with an earlier artifact.
- **No MCP PoshQC evidence.** No task uses a `run_poshqc_*` MCP tool. All PoshQC evidence comes from the self-hosted module `scripts/powershell/PoshQC/PoshQC.psd1`.
- **Task ownership.** Every task is executor-owned. Before the executor starts, the orchestrator commits this plan to `bug/pester-profiler-coverage-953`, because an executor in an agent-isolated worktree sees only committed files. The review artifacts of 2026-10-16T17-02 are already committed at `3d60e3f76`.
- **Batch budget.** `.claude/hooks/enforce-powershell-batch-budget.ps1` counts distinct production PowerShell paths written with Write or Edit per session and denies the fourth (`:312-319`, cap 3 at `:333`). Test files never count (`:301-305`). A path outside the repository root is discarded without counting (`:291-294`). When `artifacts/orchestration/orchestrator-state.json` selects a non-terminal `large`, `remediation`, or `preparation` route, nothing is counted (`:16-23`, `:296-299`).
  - This cycle writes exactly one production PowerShell file with the Edit tool: `scripts/powershell/PoshQC/PoshQC.Shard.psm1`. The bundled copy is written only with `Copy-Item` through the Tool route, which the hook does not observe. The two helper scripts of Phase 1 are written under SCRATCH, outside the repository root.
  - If the hook denies a write, the executor stops and reports the denial text. The orchestrator then records a non-terminal `remediation` route in the checkpoint and resumes the executor at the denied task. The executor never bypasses the hook.
- **Tool route.** In an agent-isolated worktree, a PreToolUse guard refuses any typed Bash command whose text contains `pwsh`, `bash`, or `wsl`, and atomic-executor has no PowerShell tool. Every PowerShell command of a task, including a single cmdlet in an acceptance check, runs as follows:
  - **Script.** The executor writes the POSIX shell file `SCRATCH/issue-953-r3-<step>.sh` with the Write tool and runs it from the Bash tool as `sh "<SCRATCH absolute path, forward slashes>/issue-953-r3-<step>.sh"`.
  - **Command line.** The path is written literally: no shell variable, and no `;`, `&&`, `|`, or redirection on that command line.
  - **Fixed body.** Line 1 is `export MSYS_NO_PATHCONV=1`. Line 2 is `pwsh -NoProfile -Command '$S = "<SCRATCH absolute path, forward slashes>"; <task PowerShell text>'`. Inside the single-quoted argument every `'` of the task text is written `'\''`. When the task records the exit code of a final command, the text ends with `; exit $LASTEXITCODE`.
  - **Working directory.** The Bash tool runs from the worktree root, so every relative path in task text is repository-relative. Both helper scripts throw when `scripts/powershell/PoshQC/PoshQC.psd1` is not found relative to the current directory.
  - **Step names.** `<step>` is the lowercased task ID (for example `issue-953-r3-p2-t3.sh`), with a `-<n>` suffix when a task needs more than one script. The route probe uses `issue-953-r3-probe.sh`.
  - **Long runs.** A run longer than the Bash tool timeout (FULL_RUN, SHARD_RUN, the bisection, and the HELPER_SET runs) is started with the Bash tool's background option; the executor waits for the completion notification, with no sleep or polling loop.
  - **Non-PowerShell commands.** `git` and `poetry run ...` run directly from the Bash tool, except where a task places `git` inside a Tool-route script to parse its output.
  - **Evidence.** `Command:` fields record the script body with the literal `SCRATCH` in place of the host path.
- **Fresh process per run.** `scripts/powershell/PoshQC/PoshQC.psm1:111-139` caches the parsed sub-module scriptblocks in an AppDomain slot keyed by path, so an edited sub-module is re-parsed only in a new process. Every Tool-route script starts a new `pwsh` process, and no task re-imports PoshQC after an edit within one process.
- **Never edit a bundled copy.** No Write or Edit tool call targets a file under `extensions/drm-copilot/resources/powershell/PoshQC/`.
- **Never edit a predecessor or #936 file.** No Write or Edit tool call targets `tests/scripts/claude-hooks/EpicStateIsolation.Baseline.Helpers.ps1`, a file listed in `MINIMAL_SET`, or either #936-owned file named in Scope.
- **No temporary files in tests.** Every test added or edited by this plan reads only checked-in files and in-memory values. SH14 constructs `System.IO.FileInfo` objects for paths that are never opened; SH15 reads two checked-in module files and writes nothing.
- **Task-ordering rule.** Four deliberately failing states exist. (1) The pre-fix 850 suite: P1-T4 (`[expect-fail]` repro) and P1-T5 (bisection) run before P2-T1 edits the suite. (2) The CR-18/CR-19 tests: P3-T4 (`[expect-fail]`) runs after P3-T1 and P3-T2 add them and before P4-T1 edits production code. (3) The pre-fix EST_SUITE: P2-T7 (`[expect-fail]`, EST_SUITE alone) runs before P2-T8 edits it. (4) The pre-fix OIA_SUITE: P2-T11 (`[expect-fail]`, OIA_SUITE alone) and P2-T12 (diagnosis) run before P2-T13 edits it. No Pester run takes place between P3-T1 and P4-T8, the pass-after run, other than P3-T4; the only other test between them is the Python parity pytest of P4-T7, which reads no Pester file.
- **Restart rule (Phase 5).** If any task from P5-T1 through P5-T4 or P5-T9 through P5-T17 fails or changes a tracked file, the executor fixes the cause, re-runs P4-T7 (mirror) when the fix changes a file under `scripts/powershell/PoshQC/`, and restarts at P5-T1, writing new evidence files. Evidence from an abandoned pass is kept; consumers read the latest file. A P5-T17 failure is repaired inside the loop only when every `FAIL_ALONE:` path is a CYCLE_FILES path; a `FAIL_ALONE:` path outside CYCLE_FILES lies outside the declared blast radius, so the executor records it and stops BLOCKED for an orchestrator decision.
- **Shard-failure stop rule (Phase 5).** A failure in P5-T5, P5-T6, P5-T7, or P5-T8 is not repaired inside the loop: the executor completes the diagnostics stated in that task and stops BLOCKED for an orchestrator decision.
- **Stop rule.** A task whose acceptance states "stop BLOCKED" ends execution: the executor reports the recorded values and does not start the next task.

## Definitions (fixed; the executor does not substitute values)

- **FEATURE** = `docs/features/active/2026-10-16-pester-profiler-coverage-953`.
- **SCRATCH** = `<session scratchpad>/issue-953/`, where `<session scratchpad>` is the session scratchpad directory supplied to the executor at run time (outside the repository). Every file this cycle creates directly under SCRATCH starts with `issue-953-r3-`. In PowerShell text, `$S` holds the absolute SCRATCH path. Evidence records the literal token `SCRATCH`, never a host path.
- **CI_MANIFEST** = `SCRATCH/issue-953-ci3-shard1/shard-files.json`, the shard 1 manifest downloaded by the orchestrator from CI run 38936152953 (head `44fb40097`). It is an input; no task writes it.
- **TARGET_SUITE** = `tests/scripts/claude-hooks/session-root-reads-850.Constraints.Tests.ps1`.
- **EST_SUITE** = `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.EpicScopeTargets.Tests.ps1`.
- **EST_TOKEN** = `enforce-orchestration-preimplementation-gate.ps1 epic-scope targets (issue #738).baseline mock interception probe` (the JUnit `testcase/@name` of the EST_SUITE probe; the shorter `epic-scope targets (issue #738).baseline mock interception probe` also matches the Codex twin in `tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-epic-scope-targets.Tests.ps1`).
- **OIA_SUITE** = `tests/scripts/claude-lib/orchestrator-state/OrchestratorStateIssueAdoption.Tests.ps1` (434 lines at PLAN_HEAD; 41 `It` blocks, four of them `-ForEach` over three cases each, so 49 tests).
- **OIA_DIRECT_TOKEN** = `Issue adoption accepts valid records (AC-6).` (matches the 10 testcases of the first `Describe` of OIA_SUITE, OIA_SUITE:117-160, which call `Get-OrchestratorStateIssueAdoptionResult` directly through `Invoke-Adoption`, OIA_SUITE:85-93).
- **OIA_WIRING_TOKEN** = `Routing contract wiring for issue adoption.` (matches the 4 testcases of the `Describe` at OIA_SUITE:355, which call only `Get-OrchestratorStateRoutingContractError`).
- **ALONE_SWEEP(tag)**: the orchestrator sweep `SCRATCH/issue-953-alone-sweep.sh`, restated in Tool-route form. Every `*.Tests.ps1` under `tests/scripts`, sorted, runs alone in its own `pwsh -NoProfile` process with Pester 5.9.0 to 5.99.99, the default Pester configuration (coverage off), and `Run.PassThru`; a suite counts as failing alone unless it reports `RESULT <total> 0 0 0`. Runs through the Tool route in the background. Task PowerShell text:

```powershell
$files = @(Get-ChildItem -Recurse -File -Filter *.Tests.ps1 -Path tests/scripts | ForEach-Object { [IO.Path]::GetRelativePath((Get-Location).Path, $_.FullName) -replace "\\","/" } | Sort-Object); $inner = "Import-Module Pester -MinimumVersion 5.9.0 -MaximumVersion 5.99.99; `$c = New-PesterConfiguration; `$c.Run.Path = @(`$env:ISSUE953_ONE); `$c.Run.PassThru = `$true; `$r = Invoke-Pester -Configuration `$c; Write-Output (`"RESULT `" + `$r.TotalCount + `" `" + `$r.FailedCount + `" `" + `$r.FailedBlocksCount + `" `" + `$r.FailedContainersCount)"; $fail = 0; $out = [System.Collections.Generic.List[string]]::new(); $out.Add("FILES=$($files.Count)"); foreach ($f in $files) { $env:ISSUE953_ONE = $f; $o = @(pwsh -NoProfile -Command $inner 2>&1 | ForEach-Object { "$_" } | Where-Object { $_ -like "RESULT *" }); $line = if ($o.Count -gt 0) { $o[-1] } else { "NO_RESULT" }; if ($line -notmatch "^RESULT \d+ 0 0 0$") { $fail++; $out.Add("FAIL_ALONE: $f :: $line") } }; $out.Add("FAILED_ALONE_COUNT=$fail"); $out.Add("TRACKED_TEST_FILES=$(@(git ls-files -- 'tests/scripts/*.Tests.ps1').Count)"); Set-Content -LiteralPath (Join-Path $S 'issue-953-r3-<tag>-alone-sweep.txt') -Value $out -Encoding utf8; $out; exit $fail
```

  The git pathspec `tests/scripts/*.Tests.ps1` has no glob magic, so `*` also matches `/` and the count covers every tracked suite under `tests/scripts`. This cycle adds no test file, so `TRACKED_TEST_FILES` is expected to equal the orchestrator sweep's `FILES=388`.
- **WATCH_TEST** = `issue #850 changed-file constraints.baseline mock interception probe` (the Pester `ExpandedPath` and the JUnit `testcase/@name` of the failing case; observed in the CI shard 1 JUnit artifact of run 38936152953).
- **PLAN_HEAD** = `3d60e3f76` (the head at which every citation was derived).
- **REM_BASE_SHA** = the commit printed by `git rev-parse HEAD` in P0-T10, before any cycle edit.
- **BASE_SHA** = the commit printed by `git merge-base HEAD origin/main` in P0-T10.
- **RUN_SET script** = `SCRATCH/issue-953-r3-run-set.ps1`, written verbatim by P1-T1. Called with `-ListPath <file of repository-relative test paths, one per line>` and optional `-WatchTest`, it runs one Pester 5.9.0 invocation in the current process with coverage disabled, prints exactly one line `RESULT=<compressed JSON>` with the fields `files`, `total`, `failed`, `failedBlocks`, `failedContainers`, `watch` (`Passed`, `Failed`, another Pester result, or `MISSING:<count>`), `watchMessage`, `epicInstances`, `runInstances`, `staleRunInstance` (`YES`, `NO`, `NA`, or `ERROR`), and `failedTests`, and exits with `failed + failedBlocks + failedContainers`.
- **RUN_SET(tag, list)**: Tool-route task PowerShell text, where `<list>` is a file name under SCRATCH:

```powershell
& (Join-Path $S 'issue-953-r3-run-set.ps1') -ListPath (Join-Path $S '<list>') *> (Join-Path $S 'issue-953-r3-<tag>.log'); $code = $LASTEXITCODE; @(Get-Content -LiteralPath (Join-Path $S 'issue-953-r3-<tag>.log') | Where-Object { $_.StartsWith('RESULT=') }); "EXIT_CODE=$code"; exit $code
```

  Valid only when the output contains exactly one `RESULT=` line.
- **BISECT script** = `SCRATCH/issue-953-r3-bisect.ps1`, written verbatim by P1-T2. It runs every candidate set through RUN_SET script in a new `pwsh` process, and prints one `RUN <n> | <label> | ...` line per run followed by the summary lines `REPRO_FAILS`, `TARGET_ALONE`, `BOUNDARY_INDEX`, `BOUNDARY_FILE`, `BOUNDARY_FAILS`, `BELOW_BOUNDARY`, `MINIMAL_SET`, `MINIMAL_SET_WITH_TARGET`, `MINIMAL_SET_MESSAGE`, `MECHANISM_STALE_RUN_INSTANCE`, `MECHANISM_INSTANCES`, and `RUNS`. It writes the minimal polluting set (without the target) to `<WorkPrefix>-minimal.txt`.
- **MINIMAL_SET** = the paths in `SCRATCH/issue-953-r3-bisect-minimal.txt` written by P1-T5. It is derived mechanically by the BISECT script; the executor does not choose it.
- **HELPER_SET** = every `*.Tests.ps1` file under `tests/` whose text contains the literal `EpicStateIsolation.Baseline.Helpers.ps1`, as repository-relative forward-slash paths sorted with `[System.StringComparer]::Ordinal`, written by P1-T6 to `SCRATCH/issue-953-r3-helper-set.txt`.
- **FULL_RUN(phase)**: the only run whose coverage counts locally. It passes no `-ScanFolders` and no `-SettingsPath`, and runs through the Tool route in the background. Task PowerShell text:

```powershell
New-Item -ItemType Directory -Force -Path artifacts/pester | Out-Null; $start = [datetime]::UtcNow; pwsh -NoProfile -Command "Import-Module ./scripts/powershell/PoshQC/PoshQC.psd1 -Force; Invoke-PoshQCTest -Root (Get-Location).Path" *> (Join-Path $S 'issue-953-r3-<phase>-poshqc.log'); $exit = $LASTEXITCODE; $end = [datetime]::UtcNow; "EXIT_CODE=$exit SECONDS=$([int]($end - $start).TotalSeconds) START_UTC=$($start.ToString('o'))"; Copy-Item artifacts/pester/powershell-coverage.xml (Join-Path $S 'issue-953-r3-<phase>-coverage.xml') -Force; Copy-Item artifacts/pester/pester-junit.xml (Join-Path $S 'issue-953-r3-<phase>-junit.xml') -Force; exit $exit
```

  `<phase>` is `baseline` in P0-T20 and `final` in P5-T3. `Run.Exit = $true` in `scripts/powershell/PoshQC/settings/pester.runsettings.psd1:4`, so the exit code is 0 only when Pester reports no failure. FULL_RUN is valid only when all three of these hold:
  - (a) Both `artifacts/pester/powershell-coverage.xml` and `artifacts/pester/pester-junit.xml` have `LastWriteTimeUtc` later than the printed `START_UTC`, parsed with `[datetime]::Parse('<START_UTC>', [cultureinfo]::InvariantCulture, [System.Globalization.DateTimeStyles]::RoundtripKind).ToUniversalTime()`.
  - (b) The log contains exactly one line with the literal `Code coverage population: source=config` (`scripts/powershell/PoshQC/PoshQC.Testing.psm1:370` writes it), counted with `@(Select-String -LiteralPath (Join-Path $S 'issue-953-r3-<phase>-poshqc.log') -SimpleMatch -Pattern 'Code coverage population: source=config').Count`.
  - (c) The command contains no `-ScanFolders` and no `-SettingsPath` argument.
- **SHARD_RUN(tag, n)**: the module's own shard selection and the module's own Pester entry path, with coverage disabled and the JUnit file redirected to SCRATCH; only the `BuildConfiguration` seam is injected (`scripts/powershell/PoshQC/PoshQC.Testing.psm1:187`, consumed at `:327`; coverage is then off by `:355-362`). Runs through the Tool route in the background. Task PowerShell text:

```powershell
$env:ISSUE953_SHARD = '<n>'; $env:ISSUE953_JUNIT = Join-Path $S 'issue-953-r3-<tag>-shard-<n>-junit.xml'; $env:ISSUE953_LIST = Join-Path $S 'issue-953-r3-<tag>-shard-<n>.json'; $start = [datetime]::UtcNow; pwsh -NoProfile -Command 'Import-Module ./scripts/powershell/PoshQC/PoshQC.psd1 -Force; $build = { param($Settings) $c = New-PesterConfiguration -Hashtable $Settings; $c.CodeCoverage.Enabled = $false; $c.TestResult.OutputPath = $env:ISSUE953_JUNIT; $c }; Invoke-PoshQCTest -Root (Get-Location).Path -ShardIndex ([int] $env:ISSUE953_SHARD) -ShardCount 3 -ShardFileListPath $env:ISSUE953_LIST -BuildConfiguration $build -DisableKoverageCopy' *> (Join-Path $S 'issue-953-r3-<tag>-shard-<n>.log'); $code = $LASTEXITCODE; $end = [datetime]::UtcNow; "EXIT_CODE=$code SECONDS=$([int]($end - $start).TotalSeconds) START_UTC=$($start.ToString('o'))"
```

  Valid only when the JUnit file and the manifest JSON both have `LastWriteTimeUtc` later than the printed `START_UTC` (parsed as for FULL_RUN) and the log contains no line with the literal `Code coverage population: source=config` (coverage stayed off; PoshQC unit tests that inject a settings file print `source=settings` lines, which do not count).
- **TARGETED_RUN(tag, paths)**: no coverage. It runs through the Tool route, and its doubled single quotes become `'\'''\''` under the Tool-route quoting rule. Task PowerShell text:

```powershell
$env:ISSUE953_PATHS = '<paths joined with ;>'; $env:ISSUE953_JUNIT = Join-Path $S 'issue-953-r3-<tag>-junit.xml'; $start = [datetime]::UtcNow; pwsh -NoProfile -Command 'Import-Module Pester -MinimumVersion 5.4.0 -MaximumVersion 5.99.99 -ErrorAction Stop; $c = New-PesterConfiguration; $c.Run.Path = @($env:ISSUE953_PATHS -split '';''); $c.Run.Exit = $true; $c.CodeCoverage.Enabled = $false; $c.TestResult.Enabled = $true; $c.TestResult.OutputFormat = ''JUnitXml''; $c.TestResult.OutputPath = $env:ISSUE953_JUNIT; $c.Output.Verbosity = ''Detailed''; Invoke-Pester -Configuration $c' *> (Join-Path $S 'issue-953-r3-<tag>.log'); "EXIT_CODE=$LASTEXITCODE START_UTC=$($start.ToString('o'))"
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
- **MOD_KEY** = `scripts/powershell/poshqc/poshqc.shard.psm1` (the CRP key of the only production module this cycle changes).
- **R3_SHARD_SET** (joined with `;` for TARGETED_RUN): `tests/scripts/powershell/PoshQC/PoshQC.Shard.Tests.ps1`, `tests/scripts/powershell/PoshQC/PoshQC.TestingShard.Tests.ps1`.
- **GUARD_SET** (joined with `;` for TARGETED_RUN; TARGET_SUITE first so it runs in a clean process): `tests/scripts/claude-hooks/session-root-reads-850.Constraints.Tests.ps1`, `tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.Discovery.Tests.ps1`, `tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.Predicate.Tests.ps1`, `tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.Probe.Tests.ps1`, `tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.Tests.ps1`.
- **R3_SHARD_OLD_TOKENS**: `SH01-SLICE-ROUND-ROBIN`, `SH02-SLICE-INVALID-INDEX-THROWS`, `SH03-MANIFEST-RELATIVE-PATHS`, `SH04-COMPLETENESS-PASS`, `SH05-COMPLETENESS-MISSING-FILE-THROWS`, `SH06-COMPLETENESS-OVERLAP-THROWS`, `SH07-COMPLETENESS-DIVERGENT-ALL-THROWS`, `SH08-TESTCOUNT-MISMATCH-THROWS`, `SH09-TESTCOUNT-MATCH-PASSES`, `SH10-SLICE-WEIGHTED-LPT`, `SH11-SLICE-EQUAL-WEIGHTS-ORDINAL-PATH-ORDER`, `SH12-SLICE-WEIGHT-COUNT-MISMATCH-THROWS`, `TS01-SHARD-RUNPATH-SELECTED`, `TS02-SHARD-FILELIST-WRITTEN-VIA-SEAM`, `TS03-NO-SHARD-RUNPATH-UNCHANGED`, `TS04-DEFAULT-FILELIST-SEAM-WRITES-UTF8-JSON`, `TS05-EMPTY-SHARD-SLICE-THROWS`, `TS06-SHARD-WEIGHTED-BY-FILE-SIZE`.
- **R3_NEW_TOKENS** (the three cases Phase 3 adds; all fail on the pre-fix production tree): `SH13-SLICE-NEGATIVE-WEIGHT-THROWS`, `SH14-WEIGHT-IGNORES-LINE-ENDINGS`, `SH15-SELECT-WEIGHS-CHECKED-IN-FILES-BY-NORMALIZED-TEXT`.
- **GUARD_TOKENS**: `issue #850 changed-file constraints.baseline mock interception probe`, `session-root-reads-850.Constraints.Tests.ps1 complies with the baseline isolation form`, `session-root-reads-850.Constraints.Tests.ps1 calls the interception probe`, `AC-6 helper imports without Force`. The second and third names were observed as passing test names in `docs/features/active/subagentstop-envelope-artifact-gates-905/evidence/other/isolation-compliance-final.2026-10-11T23-37.md:152,305`.
- **CYCLE2_TOKENS** (regression guard for the earlier cycles): `CM01-MERGE-MAX-CI`, `CM02-MERGE-RECOMPUTES-LINE-COUNTERS`, `CM03-MERGE-PRESERVES-DENOMINATOR`, `CM04-MERGE-MISMATCHED-LINES-THROWS`, `CM05-MERGE-SINGLE-REPORT-IDENTITY`, `CM06-MERGE-EMPTY-INPUT-THROWS`, `CM07-SUMMARY-REPORT-LINE`, `CM08-MERGE-OMITS-CLASS-AND-METHOD-FIGURES`, `WF01-POSHQC-MERGE-JOB-RUNS-ALWAYS`, `WF02-POSHQC-RESULT-GATE-PRECEDES-MERGE`, `WF03-RESULT-GATE-CHECK-DETECTS-MUTATIONS`, `WF04-SHARD-COUNT-FROM-MATRIX`, `WF05-MERGE-LOOPS-DERIVE-SHARD-COUNT`, `RS01-RUNSETTINGS-PROFILER-MODE`, `RS02-PESTER-CONFIG-USEBREAKPOINTS-FALSE`, `RS03-INSTALLER-PESTER-590`, `RS04-BUNDLED-RUNSETTINGS-PROFILER-MODE`, `RS05-INSTALLER-PESTER-CEILING-BELOW-6`, `RS06-TEST-IMPORT-PESTER-MAXIMUM`, `RS07-WORKFLOW-LINUX-PESTER-RANGE`, `RS08-TEST-IMPORT-PESTER-RANGE-BOUNDS`, `RS09-TEST-PESTER-6-ONLY-ACTIONABLE-ERROR`, `RS10-TEST-PESTER-INBOX-ONLY-ACTIONABLE-ERROR`.
- **BUNDLE_PAIRS** (repository file and bundled copy): `PoshQC.Shard.psm1`, `PoshQC.CoverageMerge.psm1`, `PoshQC.Testing.psm1`, and `README.md`, each under `scripts/powershell/PoshQC/` and `extensions/drm-copilot/resources/powershell/PoshQC/`.
- **FILES_936**: `tests/scripts/codex-hooks/hook-import-failure-exemptions.FailClosed.Tests.ps1`, `tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-epic-scope.Decision.Tests.ps1`.
- **CYCLE_FILES**: items 1-8 of "Files Written". **PS_CYCLE_FILES**: items 1, 2, 4, 7, and 8.

## Assumptions and Advisories

### PA-3 root-cause hypothesis (H1; confirmed or refuted by P1-T5)

- The probe call path is `Resolve-EpicScopeCheckpoint` (EpicScopeResolution, called by name from the suite) to `Resolve-WorktreeEpicTarget` (`.claude/lib/worktree-resolution/EpicScopeResolution.psm1:353`), which EpicScopeResolution reaches through its nested import of WorktreeRunResolution (`EpicScopeResolution.psm1:42`, no `-Force`, so the nested import reuses whatever WorktreeRunResolution instance is loaded when EpicScopeResolution loads).
- The probe registers its setup mocks `Get-WorktreeItemLiveRoot` and `Get-WorktreeRunCheckpointText` with `-ModuleName WorktreeRunResolution` (`tests/scripts/claude-hooks/EpicStateIsolation.Baseline.Helpers.ps1:124-125`). Pester binds `-ModuleName` to the instance `Get-Module` returns, which is the most recently imported one.
- Hooks dot-sourced by earlier suites import WorktreeRunResolution with `-Force` without re-importing EpicScopeResolution (for example `.claude/hooks/enforce-parallel-worktree-removal-gate.ps1:49`; only `.claude/hooks/enforce-orchestration-preimplementation-gate-epic-scope.ps1:44-46`, `.claude/hooks/enforce-model-routing-receipt.ps1:56`, and `.claude/hooks/enforce-pr-author-skill-helpers.ps1:53` import EpicScopeResolution). After such a sequence the loaded EpicScopeResolution still calls a replaced WorktreeRunResolution instance, the setup mocks are not seen, `Resolve-WorktreeEpicTarget` returns `NoTarget`, and `Resolve-EpicScopeCheckpoint` returns reason `epic-checkpoint-absent-or-unparseable` at `EpicScopeResolution.psm1:354-356` without calling `Get-EpicScopeCheckpointText`. That matches the CI failure exactly: the reason assertion (`EpicStateIsolation.Baseline.Helpers.ps1:131`) passes and the invocation assertion (`:132`) reports 0 calls.
- The helper imports without `-Force` (`EpicStateIsolation.Baseline.Helpers.ps1:51` and `:63`), so it cannot repair a stale nested binding that a predecessor left behind.
- The repository already documents this mechanism and its remedy twice: `tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.Probe.Tests.ps1:28-31` and `tests/scripts/codex-hooks/hook-dependency-failure.Codex.Tests.ps1:40-42` unload the worktree-resolution family before registering the baseline mocks, in suites that load no hook.
- The `EpicScopeResolution.RunTarget.Tests.ps1` lead in `code-review.2026-10-16T17-02.md:32` is not a predecessor of TARGET_SUITE in the CI shard 1 order: CI_MANIFEST lists `tests/scripts/claude-hooks/*` files before `tests/scripts/claude-lib/*`, and TARGET_SUITE is index 40 of 130. The predecessor set is indices 0-39.
- P1-T5 records `MECHANISM_STALE_RUN_INSTANCE` for MINIMAL_SET run without the target: `YES` confirms H1 (the WorktreeRunResolution instance that EpicScopeResolution calls is not the instance Pester's `-ModuleName WorktreeRunResolution` binds to). Any other value is recorded as `MECHANISM_HYPOTHESIS: NOT CONFIRMED`; the fix is still applied, and the Phase 2 pass-after gates decide.

### PA-3 design decision (D-R3-1): victim-side family reset in the 850 suite

- **Change.** In the outermost `BeforeAll` of TARGET_SUITE, between the helper dot-source (line 21) and `Register-EpicStateBaselineMock` (line 22), insert the same `Remove-Module -Name 'EpicScopeResolution', 'WorktreeRunResolution', 'WorktreeItemResolution', 'WorktreeResolution', 'WorktreeTargetResolution', 'EpicScopeReadiness' -Force -ErrorAction SilentlyContinue` statement that `hook-dependency-failure.Codex.Tests.ps1:42` carries, with a three-line comment. The helper's imports then load one coherent set of instances (EpicScopeResolution first, which loads its siblings, `EpicScopeResolution.psm1:40-42`; then the helper's later imports reuse them), so the mocks and the call path bind to the same instances whatever ran earlier in the process. The family list is complete: every `Import-Module` in `.claude/lib/worktree-resolution/*.psm1` names a member of it.
- **Why the 850 suite may unload the family.** TARGET_SUITE loads no hook (its `BeforeAll`, lines 20-76, dot-sources only the helper), so no hook function in its scope depends on a module instance that the reset would orphan. A later suite that loads a hook re-imports the family through the hook's own `-Force` imports.
- **What the probe still asserts.** The probe is unchanged (`EpicStateIsolation.Baseline.Helpers.ps1:111-134`): it still calls the exported resolver by name and still requires one invocation of the baseline mock and zero hostile reads.
- **Rejected alternatives.**
  - Import the seam modules with `-Force` inside the helper: violates the tested contract `AC-6 helper imports without Force` (`enforce-gate-suites.EpicStateIsolation.Probe.Tests.ps1:59-68`), and in a hook suite it would bind the baseline mocks to a new instance after the hook had loaded its own, which is the failure the probe exists to detect (`:85-92`).
  - Fix the predecessor: the predecessors are hook suites whose hooks import with `-Force` by design (issue #690 import guards), MINIMAL_SET may include a #936-owned file, and any later suite with the same import pattern would reintroduce the failure. The victim-side reset removes the dependency on predecessor behavior.
  - Weaken the probe, or change shard weights, the shard count, or the matrix: prohibited by D19 and `remediation-inputs.2026-10-16T17-02.md:28`.
- **Files touched for PA-3:** one test file. No production file, no helper, no predecessor.

### OIA_SUITE root-cause hypothesis (H2; confirmed or refuted by P2-T12)

- The planner could not execute commands in this revision; H2 is derived from the source text and the sweep counts, and P2-T12 decides it mechanically before any edit.
- OIA_SUITE's `BeforeAll` imports `OrchestratorStateIssueAdoption.psm1` with `-Force` (OIA_SUITE:29) and then `OrchestratorStateRoutingContract.psm1` with `-Force` (OIA_SUITE:30). The routing-contract module imports its sibling `OrchestratorStateIssueAdoption.psm1` again with `-Force` at module scope (`.claude/lib/orchestrator-state/OrchestratorStateRoutingContract.psm1:61`). H2: that nested forced import unloads the instance the suite imported at line 29, so `Get-OrchestratorStateIssueAdoptionResult` is no longer visible to the suite, and every test that calls it through `Invoke-Adoption` (OIA_SUITE:85-93) fails, while the 4 tests of the `Describe` at OIA_SUITE:355 pass because they reach the adoption function only through the routing contract's own nested instance.
- The sweep counts match H2 exactly: 49 tests minus the 4 wiring tests is 45 failed, with 0 failed blocks and 0 failed containers (the `BeforeAll` itself succeeds).
- In a full or sharded run, a predecessor suite (for example `tests/scripts/claude-lib/orchestrator-state/OrchestratorStateIssueAdoption.Parity.Tests.ps1:50`, which sorts before OIA_SUITE and imports the routing contract with `-Force`) leaves module state under which the function stays visible. P2-T12 records whether that predecessor state makes the function visible, as an observation.
- The module is not judged defective under H2: importing siblings with `-Force -ErrorAction Stop` at module scope is the documented convention of the routing contract (`OrchestratorStateRoutingContract.psm1:50`), and every assertion that calls it passes alone.

### OIA_SUITE design decision (D-R3-4): import the routing contract first, then the adoption module without -Force

- **Change.** Replace OIA_SUITE:29-30 with a three-line comment, the routing-contract import with `-Force`, and the adoption-module import without `-Force`. The routing contract's nested forced import then runs first, and the later unforced import makes the already-loaded adoption module visible in the suite's scope without unloading anything, whatever ran earlier in the process.
- **What stays the same.** No `It`, `Describe`, helper function, fixture, or assertion changes; the count of lines containing `Should -` is unchanged (P2-T14). Both modules are still loaded from the working tree in this process: the forced routing-contract import re-runs its nested forced adoption import.
- **Rejected alternatives.** Changing `OrchestratorStateRoutingContract.psm1:61` (a production change the diagnosis does not justify, and a convention shared by its sibling imports at `:59-60`); module-qualifying the calls (the module would still be unloaded); adding `-Global` imports (leaks state to later suites).
- **Files touched:** one test file. If P2-T12 does not confirm H2, no edit is made and execution stops BLOCKED.

### CR-18 design decision (D-R3-2)

- `Get-PoshQCShardSlice` throws `Weight must not be negative; '<file>' has weight <w>.` after the existing length check (`scripts/powershell/PoshQC/PoshQC.Shard.psm1:39-41`), so the failing position always has a file name. A zero weight stays valid. The help sentence at lines 9-10 names the new condition. `New-PoshQCShardManifest` passes `-Weight` through (`:106-110`), so the check covers both public entry points.

### CR-19 design decision (D-R3-3): weight by line-ending-normalized text size

- A new internal function `Get-PoshQCShardTestFileWeight` in `PoshQC.Shard.psm1` returns one weight per enumerated item: a `System.IO.FileInfo` item weighs `[System.Text.Encoding]::UTF8.GetByteCount($text.Replace("`r`n", "`n"))`, where `$text` comes from an injectable `-ReadTestFileText` seam (default `[System.IO.File]::ReadAllText`); another object weighs its `Length` property when it has one; a plain path string, or an object without `Length`, weighs 1. A CRLF checkout and an LF checkout of the same tree therefore compute the same weights and the same assignment.
- `Select-PoshQCShardTestFile` (`PoshQC.Shard.psm1:247`) calls it instead of reading `Length`. The default `EnumerateTests` seam returns `FileInfo` items (`scripts/powershell/PoshQC/PoshQC.Testing.psm1:259-273`), so CI and local sharded runs use the normalized weight. Injected `pscustomobject` items keep the `Length` rule, so TS01, TS02, TS04, TS05, and TS06 (`tests/scripts/powershell/PoshQC/PoshQC.TestingShard.Tests.ps1:60-161`) are unchanged.
- The function is internal (not in `Export-ModuleMember`, `scripts/powershell/PoshQC/PoshQC.psm1:143-154`), reachable from `Select-PoshQCShardTestFile` because the sub-module loader dot-sources every sub-module into the module scope (`:117-139`). `PoshQC.psm1`, `PoshQC.psd1`, and `PoshQC.Testing.psm1` are unchanged; the `Invoke-PoshQCTest` help at `PoshQC.Testing.psm1:156` ("size-balanced slice ... (Select-PoshQCShardTestFile)") stays accurate.
- Tests: SH14 is a deterministic in-memory test (two `FileInfo` objects for unopened paths, LF and CRLF reader seams; raw CRLF sizes 30 and 26 would reverse the order of the normalized sizes 20 and 25). SH15 reads two checked-in module files through the default reader and checks that the default weights equal the weights of an in-memory CRLF copy, and that `Select-PoshQCShardTestFile` gives shard 1 the heavier file; it also executes the default reader so its line is covered.
- README lines 62 and 84 are rewritten to state the non-negative rule and the normalization. `extensions/drm-copilot/CHANGELOG.md` ("assigns test files to shards by size in bytes") remains accurate and is not changed.
- The new weights reshuffle the CI shard composition. Phase 5 therefore runs all three shard lists exactly as `Invoke-PoshQCTest -ShardIndex <n> -ShardCount 3` computes them on the final tree (SHARD_RUN), which is the composition CI will run.

### Other advisories

- **Local Pester.** Cycle 1 installed Pester 5.9.0 for the CurrentUser scope; `docs/features/active/2026-10-16-pester-profiler-coverage-953/evidence/remediation-baseline/r2-local-pester.2026-10-16T15-32.md:6` recorded `RANGE=5.9.0`. P0-T2 confirms it; no task installs a module.
- **Reproduction fidelity.** P1-T4 runs `selected[0..40]` of CI_MANIFEST, which is the same file list and order as the orchestrator's `SCRATCH/issue-953-repro-shard1.sh`. It does not recompute shard 1 locally, because the pre-fix local weights depend on the local checkout's line endings (CR-19). P0-T17 records whether the local computation matches CI_MANIFEST as an observation.
- **Linux hook job.** `poshqc / PowerShell hook suites (Linux)` runs `tests/scripts/claude-hooks` and `tests/scripts/codex-hooks` on `ubuntu-latest` with coverage disabled; the TARGET_SUITE and EST_SUITE changes use only cross-platform cmdlets. OIA_SUITE is under `tests/scripts/claude-lib` and runs only in `poshqc / PowerShell QC`. No acceptance criterion in this plan cites `ubuntu-latest`.
- **Coverage authority.** Local FULL_RUN values (cycle baseline and final) supply the policy-required baseline, post-change, and changed-line values. The CI artifact comparison stays with reference task P8-T19. Only `PoshQC.Shard.psm1` changes among coverage-measured files, so every other per-file LINE total must be unchanged.
- **Acceptance-criteria re-verification.** This cycle changes files that carry evidence for AC-02, AC-07, AC-11, AC-12 (the "no #936-owned test file is modified" clause), AC-13, AC-14, and AC-15. Phase 5 re-verifies them. The executor does not change any checkbox in `spec.md`.
- **Validator.** The planner has no access to `mcp__drm-copilot__validate_orchestration_artifacts`; the caller runs it with `artifact_type: "plan"` before treating this plan as approved.
- **No evidence location override was supplied.** All evidence paths are canonical `FEATURE/evidence/<kind>/` paths.

## Requirements Traceability

| Item | Implementation tasks | Tests | Evidence tasks |
|---|---|---|---|
| CR-21 (PA-3) | P2-T1, P2-T8, P2-T13 | TARGET_SUITE `baseline mock interception probe`; GUARD_SET; HELPER_SET; MINIMAL_SET pair; EST_SUITE alone (EST_TOKEN); OIA_SUITE alone (OIA_DIRECT_TOKEN, OIA_WIRING_TOKEN); ALONE_SWEEP | P1-T4, P1-T5, P1-T6, P2-T2, P2-T3, P2-T4, P2-T5, P2-T6, P2-T7, P2-T9, P2-T10, P2-T11, P2-T12, P2-T14, P2-T15, P5-T3, P5-T5, P5-T6, P5-T7, P5-T8, P5-T17 |
| CR-18 | P4-T1 | `SH13-SLICE-NEGATIVE-WEIGHT-THROWS` | P3-T4, P4-T8, P5-T3, P5-T4 |
| CR-19 | P4-T2, P4-T3, P4-T5, P4-T7 | `SH14-WEIGHT-IGNORES-LINE-ENDINGS`, `SH15-SELECT-WEIGHS-CHECKED-IN-FILES-BY-NORMALIZED-TEXT`, `TS06-SHARD-WEIGHTED-BY-FILE-SIZE` | P3-T4, P4-T8, P5-T3, P5-T4, P5-T8, P5-T15 |
| AC-02 | P4-T7 | `tests/scripts/dev_tools/test_poshqc_bundled_parity.py::test_poshqc_bundled_module_files_match_repo_root_sources` | P4-T7, P5-T9, P5-T10 |
| AC-07 | P2-T1 through P4-T5 | full self-hosted suite | P5-T1, P5-T2, P5-T3, P5-T18 |
| AC-11 | scope constraint (check name, completeness guard, no threshold) | `Test-PoshQCShardCompleteness` over the three final manifests | P5-T8, P5-T13, P5-T14 |
| AC-12 | scope constraint (no #936-owned test file modified) | path check | P5-T16 |
| AC-13 | scope constraint | `on:` block and `ci.yml` comparison | P5-T13 |
| AC-14 | scope constraint | path-prefix check | P5-T16 |
| AC-15 | size constraint | line counts | P2-T2, P2-T9, P2-T14, P3-T3, P4-T4, P5-T12 |

## Implementation Plan

### Phase 0 — Baseline Capture (cycle 3)

All baseline artifacts go to `docs/features/active/2026-10-16-pester-profiler-coverage-953/evidence/remediation-baseline/`.

- [x] [P0-T1] Probe the Tool route. Write `SCRATCH/issue-953-r3-probe.sh` with the fixed body whose task PowerShell text is `$PSVersionTable.PSVersion.ToString()`, and run it from the Bash tool as `sh "<SCRATCH absolute path, forward slashes>/issue-953-r3-probe.sh"`.
  - Acceptance: the script exits 0 and prints a version. Otherwise record `TOOL_ROUTE: DENIED` in the report and stop BLOCKED.
- [x] [P0-T2] Confirm the local Pester and write `docs/features/active/2026-10-16-pester-profiler-coverage-953/evidence/remediation-baseline/r3-local-pester.<ts>.md`.
  - Through the Tool route, print `RANGE=` followed by `(@(Get-Module -ListAvailable -FullyQualifiedName @{ ModuleName = 'Pester'; ModuleVersion = '5.9.0'; MaximumVersion = '5.99.99' } | ForEach-Object { $_.Version.ToString() }) -join ',')`.
  - Fields: `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:` with the printed line.
  - Acceptance: the `RANGE` list contains `5.9.0`. Otherwise stop BLOCKED: RUN_SET imports Pester 5.9.0 exactly, and the default `EnsureModule` seam requires 5.9.0 to 5.99.99 (`scripts/powershell/PoshQC/PoshQC.Testing.psm1:320`).
- [x] [P0-T3] Read the repository-root `CLAUDE.md` (standing instructions, policy reading order) and `.github/copilot-instructions.md` (the tone policy it names as authoritative).
- [x] [P0-T4] Read `.claude/rules/general-code-change.md` (toolchain loop, 500-line limit, fail-fast error handling, I/O isolation).
- [x] [P0-T5] Read `.claude/rules/general-unit-test.md` (independence, coverage defaults and precedence, Coverage Exclusion Policy, no temporary files, determinism).
- [x] [P0-T6] Read `.claude/rules/quality-tiers.md` and confirm from `quality-tiers.yml:13-14` that `scripts/powershell/PoshQC` is tier T3 (no property-test or mutation obligation).
- [x] [P0-T7] Read `.claude/rules/powershell.md` (PoshQC toolchain order, change budget, seams, Pester standards).
- [x] [P0-T8] Read `.claude/rules/python.md` (toolchain for the bundled-parity pytest at `tests/scripts/dev_tools/test_poshqc_bundled_parity.py`).
- [x] [P0-T9] Read `.claude/rules/ci-workflows.md` and `.github/instructions/github-actions.instructions.md` (workflow rules behind the unchanged-workflow and actionlint gates), then write `docs/features/active/2026-10-16-pester-profiler-coverage-953/evidence/remediation-baseline/phase0-instructions-read.<ts>.md`.
  - Fields: `Timestamp:`, `Policy Order:` (CLAUDE.md, copilot-instructions, general-code-change, general-unit-test, quality-tiers, powershell, python, ci-workflows, github-actions), and the explicit list of the ten files read in P0-T3 through P0-T9: `CLAUDE.md`, `.github/copilot-instructions.md`, `.claude/rules/general-code-change.md`, `.claude/rules/general-unit-test.md`, `.claude/rules/quality-tiers.md`, `quality-tiers.yml`, `.claude/rules/powershell.md`, `.claude/rules/python.md`, `.claude/rules/ci-workflows.md`, `.github/instructions/github-actions.instructions.md`.
  - Acceptance: all ten paths are listed in that order.
- [x] [P0-T10] Record the branch state and write `docs/features/active/2026-10-16-pester-profiler-coverage-953/evidence/remediation-baseline/r3-branch-state.<ts>.md`.
  - Run from the Bash tool: `git fetch origin main`, `git merge-base HEAD origin/main`, `git rev-parse HEAD`, `git branch --show-current`, `git merge-base --is-ancestor 3d60e3f76 HEAD`, `git diff --name-only 3d60e3f76 HEAD`, and `git status --porcelain --untracked-files=all`.
  - The file contains `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:` (the name-only and porcelain outputs), `REM_BASE_SHA: <40-hex HEAD>`, `BASE_SHA: <40-hex merge base>`, and `BRANCH: bug/pester-profiler-coverage-953`.
  - Acceptance:
    - Every command exits 0, and the branch value equals `bug/pester-profiler-coverage-953`.
    - Every path listed by `git diff --name-only 3d60e3f76 HEAD` starts with `docs/features/active/2026-10-16-pester-profiler-coverage-953/`, so every citation derived at PLAN_HEAD still holds.
    - Every porcelain line is either an untracked path under the feature folder (it starts with `?? docs/features/active/2026-10-16-pester-profiler-coverage-953/`) or a modification of exactly this plan file (status ` M`, `M `, or `MM`, path `docs/features/active/2026-10-16-pester-profiler-coverage-953/remediation-plan.2026-10-16T17-24.md`).
    - Otherwise stop BLOCKED and record the offending line.
- [x] [P0-T11] Record bundled-copy identity and write `docs/features/active/2026-10-16-pester-profiler-coverage-953/evidence/remediation-baseline/r3-bundle-identity.<ts>.md`.
  - Through the Tool route, compare `(Get-FileHash -Algorithm SHA256 -LiteralPath <path>).Hash` for each of the four BUNDLE_PAIRS.
  - The file contains `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:`, and one `PAIR_EQUAL: <file name> YES|NO` line per pair.
  - Acceptance: all four pairs record `YES`. Otherwise stop BLOCKED: an Edit-tool repair of a bundled copy is prohibited.
- [x] [P0-T12] Record baseline line counts and write `docs/features/active/2026-10-16-pester-profiler-coverage-953/evidence/remediation-baseline/r3-line-counts.<ts>.md`.
  - Through the Tool route, run `(Get-Content -LiteralPath <path>).Count` for every path in the acceptance list below.
  - The file contains `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:`, and one `LINES: <path> <count>` line per file.
  - Acceptance: the counts are `scripts/powershell/PoshQC/PoshQC.Shard.psm1` 256, `scripts/powershell/PoshQC/PoshQC.Testing.psm1` 479, `scripts/powershell/PoshQC/README.md` 98, `tests/scripts/powershell/PoshQC/PoshQC.Shard.Tests.ps1` 172, `tests/scripts/powershell/PoshQC/PoshQC.TestingShard.Tests.ps1` 162, `tests/scripts/claude-hooks/session-root-reads-850.Constraints.Tests.ps1` 114, `tests/scripts/claude-hooks/EpicStateIsolation.Baseline.Helpers.ps1` 179, `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.EpicScopeTargets.Tests.ps1` 203, and `tests/scripts/claude-lib/orchestrator-state/OrchestratorStateIssueAdoption.Tests.ps1` 434. If any count differs, the planning-time line citations no longer hold: stop BLOCKED.
- [x] [P0-T13] Capture the bundled-parity baseline with `poetry run pytest tests/scripts/dev_tools/test_poshqc_bundled_parity.py -q` and write `docs/features/active/2026-10-16-pester-profiler-coverage-953/evidence/remediation-baseline/r3-parity-pytest.<ts>.md`.
  - Fields: `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:` quoting the summary line. The Output Summary also states that Python coverage is not measured because no Python file is written in this cycle.
  - Acceptance: EXIT_CODE 0 and the summary line contains `1 passed`.
- [x] [P0-T14] Capture the PoshQC format baseline (write-mode tool) and write `docs/features/active/2026-10-16-pester-profiler-coverage-953/evidence/remediation-baseline/r3-poshqc-format.<ts>.md`.
  - Through the Tool route: record `$before = git status --porcelain`, run `pwsh -NoProfile -Command "Import-Module ./scripts/powershell/PoshQC/PoshQC.psd1 -Force; Invoke-PoshQCFormat -Root (Get-Location).Path" *> (Join-Path $S 'issue-953-r3-baseline-format.log')`, record `$LASTEXITCODE`, then record `$after = git status --porcelain`.
  - The Output Summary states the count of log lines that start with `Formatted: ` (case-sensitive; `scripts/powershell/PoshQC/PoshQC.Analyzer.psm1:62`) and whether `$before` equals `$after`. A file that needs no change logs `Already formatted:` instead (`:64`).
  - Acceptance: EXIT_CODE 0, zero `Formatted: ` lines, and `$before` equal to `$after`. If any file was reformatted, record its path as `PRE_EXISTING_FORMAT_DRIFT:`, restore it with `git restore --source=HEAD --worktree -- <path>`, and stop BLOCKED.
- [x] [P0-T15] Capture the PoshQC analyze baseline with `pwsh -NoProfile -Command "Import-Module ./scripts/powershell/PoshQC/PoshQC.psd1 -Force; Invoke-PoshQCAnalyze -Root (Get-Location).Path" *> (Join-Path $S 'issue-953-r3-baseline-analyze.log')` (Tool route) and write `docs/features/active/2026-10-16-pester-profiler-coverage-953/evidence/remediation-baseline/r3-poshqc-analyze.<ts>.md`.
  - Fields: `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:`.
  - Acceptance: EXIT_CODE 0 and the log contains the literal `PSScriptAnalyzer passed: no findings under` (`scripts/powershell/PoshQC/PoshQC.Analyzer.psm1:185`). On a non-zero exit, record the findings and stop BLOCKED.
- [x] [P0-T16] Capture the actionlint baseline through the Tool route with the task text `$cmd = Get-Command actionlint -ErrorAction SilentlyContinue; "GET_COMMAND=$($cmd.Source)"; if ($cmd) { actionlint .github/workflows/_poshqc.yml; exit $LASTEXITCODE } else { 'ACTIONLINT: NOT-AVAILABLE'; exit 1 }` and write `docs/features/active/2026-10-16-pester-profiler-coverage-953/evidence/remediation-baseline/r3-actionlint.<ts>.md`.
  - Fields: `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:` (the `GET_COMMAND` value and any actionlint output).
  - Acceptance: EXIT_CODE 0 with no actionlint output. actionlint resolved on this host in `docs/features/active/2026-10-16-pester-profiler-coverage-953/evidence/qa-gates/r2-final-actionlint.2026-10-16T16-52.md`; if it is not available now, stop BLOCKED.
- [x] [P0-T17] Validate the CI_MANIFEST input and write `docs/features/active/2026-10-16-pester-profiler-coverage-953/evidence/remediation-baseline/r3-ci-manifest.<ts>.md`.
  - Through the Tool route, run this task PowerShell text (the second statement drives the real `Invoke-PoshQCTest` enumeration with only the Pester run and the file-list write injected; no file is written and Pester does not run):

```powershell
$m = Get-Content -Raw -LiteralPath (Join-Path $S 'issue-953-ci3-shard1/shard-files.json') | ConvertFrom-Json; $sel = @($m.selected | ForEach-Object { [string] $_ }); "SHARD=$($m.shardIndex)/$($m.shardCount) SELECTED=$($sel.Count) INDEX_850=$([array]::IndexOf($sel, 'tests/scripts/claude-hooks/session-root-reads-850.Constraints.Tests.ps1'))"; "MISSING_IN_PREFIX=$(@($sel[0..40] | Where-Object { -not (Test-Path -LiteralPath $_ -PathType Leaf) }).Count)"; Import-Module ./scripts/powershell/PoshQC/PoshQC.psd1 -Force; $captured = @{}; $sink = { param([string] $Path, [string] $Json) $captured[$Path] = $Json }.GetNewClosure(); Invoke-PoshQCTest -Root (Get-Location).Path -ShardIndex 1 -ShardCount 3 -ShardFileListPath 'shard-1' -WriteShardFileList $sink -InvokePester { param($Config) $null = $Config } -DisableKoverageCopy *> $null; $local = @(($captured['shard-1'] | ConvertFrom-Json).selected | ForEach-Object { [string] $_ }); "LOCAL_SHARD1_EQUALS_CI=$((($local -join [char]10) -ceq ($sel -join [char]10)))"
```

  - Fields: `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:` with the three printed lines.
  - Acceptance: `SHARD=1/3`, `SELECTED=130`, `INDEX_850=40`, and `MISSING_IN_PREFIX=0`. `LOCAL_SHARD1_EQUALS_CI` is recorded as an observation (it reflects CR-19) and does not gate the task. Otherwise stop BLOCKED.
- [x] [P0-T18] Capture the shard-suite baseline by running TARGETED_RUN(`baseline-shard`, R3_SHARD_SET) and write `docs/features/active/2026-10-16-pester-profiler-coverage-953/evidence/remediation-baseline/r3-targeted-tests.<ts>.md`.
  - Fields: `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:` (the JRP totals and the JRP token check for every R3_SHARD_OLD_TOKENS entry), and `R3_TARGETED_BASELINE_TESTS: <JRP tests>`.
  - Acceptance: run valid, EXIT_CODE 0, `failures` 0, `errors` 0, and every R3_SHARD_OLD_TOKENS entry PASS.
- [x] [P0-T19] Capture the guard-suite baseline by running TARGETED_RUN(`baseline-guard`, GUARD_SET) and write `docs/features/active/2026-10-16-pester-profiler-coverage-953/evidence/remediation-baseline/r3-guard-tests.<ts>.md`.
  - Fields: `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:` (the JRP totals and the JRP token check for every GUARD_TOKENS entry), and `R3_GUARD_BASELINE_TESTS: <JRP tests>`.
  - Acceptance: run valid, EXIT_CODE 0, `failures` 0, `errors` 0, and every GUARD_TOKENS entry PASS (TARGET_SUITE passes when it runs first in a clean process).
- [x] [P0-T20] Capture the full Pester baseline with coverage by running FULL_RUN(baseline) and write `docs/features/active/2026-10-16-pester-profiler-coverage-953/evidence/remediation-baseline/r3-poshqc-test-coverage.<ts>.md`.
  - Fields: `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:`, and `R3_BASELINE_JUNIT_TESTS: <JRP tests>`.
  - The Output Summary contains the JRP totals (`JUNIT_TESTS`, `JUNIT_FAILURES`, `JUNIT_ERRORS`), the FULL_RUN wall seconds, the CRP values `LINE_COVERED`, `LINE_MISSED`, `LINE_TOTAL`, `LINE_PERCENT`, and `SOURCEFILE_COUNT`, and the per-file `covered` and `missed` values for MOD_KEY.
  - Acceptance: FULL_RUN valid, EXIT_CODE 0, `JUNIT_FAILURES` 0, `JUNIT_ERRORS` 0, and every CRP value numeric. If a test fails, record the failed `classname` and `name` values as `PRE_EXISTING_FAILURES:` and stop BLOCKED.

### Phase 1 — PA-3 Investigation and Fail-Before

The two scripts below are written with the Write tool under SCRATCH (outside the repository; not tracked, not counted by the batch-budget hook). If the Write tool is denied for either path, stop and report the denial text; do not work around it.

- [ ] [P1-T1] Write `SCRATCH/issue-953-r3-run-set.ps1` with exactly the content below.
  - Acceptance: the file exists and its content equals the block below (verified in P1-T3).

```powershell
param(
    [Parameter(Mandatory)][string] $ListPath,
    [string] $WatchTest = 'issue #850 changed-file constraints.baseline mock interception probe'
)
# Issue #953 cycle 3 (PA-3): runs one Pester 5.9.0 invocation over the listed test files, in list order, with
# coverage disabled, then reports the watched test and whether the loaded EpicScopeResolution instance calls the
# WorktreeRunResolution instance that a -ModuleName mock binds to.
$ErrorActionPreference = 'Stop'
if (-not (Test-Path -LiteralPath 'scripts/powershell/PoshQC/PoshQC.psd1')) { throw 'Run this script from the repository root.' }
Import-Module Pester -RequiredVersion 5.9.0 -ErrorAction Stop
$paths = @(Get-Content -LiteralPath $ListPath | Where-Object { $_ -ne '' })
foreach ($path in $paths) {
    if (-not (Test-Path -LiteralPath $path -PathType Leaf)) { throw "Listed test file not found: $path" }
}
$configuration = New-PesterConfiguration
$configuration.Run.Path = [string[]] $paths
$configuration.Run.PassThru = $true
$configuration.CodeCoverage.Enabled = $false
$configuration.Output.Verbosity = 'None'
$run = Invoke-Pester -Configuration $configuration
$allTests = @(@($run.Passed) + @($run.Failed) + @($run.Skipped) + @($run.NotRun) | Where-Object { $null -ne $_ })
$watched = @($allTests | Where-Object { $_.ExpandedPath -ceq $WatchTest })
$watchResult = if ($watched.Count -eq 1) { [string] $watched[0].Result } else { "MISSING:$($watched.Count)" }
$watchMessage = ''
if ($watched.Count -eq 1 -and @($watched[0].ErrorRecord).Count -gt 0) { $watchMessage = [string] @($watched[0].ErrorRecord)[0].Exception.Message }
$epic = @(Get-Module -Name EpicScopeResolution -All | Where-Object { $_.ModuleType -eq 'Script' })
$runModule = @(Get-Module -Name WorktreeRunResolution -All | Where-Object { $_.ModuleType -eq 'Script' })
$stale = 'NA'
if ($epic.Count -eq 1 -and $runModule.Count -eq 1) {
    try {
        $boundInstance = $runModule[0]
        $epicInstance = $epic[0]
        & $boundInstance { $script:Issue953InstanceMarker = 'bound' }
        $seen = & $epicInstance { $nested = (Get-Command -Name Resolve-WorktreeEpicTarget -CommandType Function).Module; & $nested { $ExecutionContext.SessionState.PSVariable.GetValue('Issue953InstanceMarker') } }
        $stale = if ($seen -ceq 'bound') { 'NO' } else { 'YES' }
    } catch {
        $stale = 'ERROR'
    }
}
$summary = [ordered]@{
    files            = $paths.Count
    total            = $run.TotalCount
    failed           = $run.FailedCount
    failedBlocks     = $run.FailedBlocksCount
    failedContainers = $run.FailedContainersCount
    watch            = $watchResult
    watchMessage     = $watchMessage
    epicInstances    = $epic.Count
    runInstances     = $runModule.Count
    staleRunInstance = $stale
    failedTests      = @($run.Failed | ForEach-Object { [string] $_.ExpandedPath })
}
'RESULT=' + ($summary | ConvertTo-Json -Compress -Depth 3)
exit ([int] ($run.FailedCount + $run.FailedBlocksCount + $run.FailedContainersCount))
```

- [ ] [P1-T2] Write `SCRATCH/issue-953-r3-bisect.ps1` with exactly the content below.
  - Acceptance: the file exists and its content equals the block below (verified in P1-T3).

```powershell
param(
    [Parameter(Mandatory)][string] $ManifestPath,
    [Parameter(Mandatory)][string] $Target,
    [Parameter(Mandatory)][string] $WatchTest,
    [Parameter(Mandatory)][string] $WorkPrefix
)
# Issue #953 cycle 3 (PA-3): finds the last predecessor whose inclusion makes the watched test fail (binary search
# over prefixes, verified, with a linear fallback), then the smallest pair or single file that still makes it fail,
# and records the module-instance diagnostic for that set. Every candidate set runs in a new pwsh process.
$ErrorActionPreference = 'Stop'
if (-not (Test-Path -LiteralPath 'scripts/powershell/PoshQC/PoshQC.psd1')) { throw 'Run this script from the repository root.' }
$runSet = Join-Path $PSScriptRoot 'issue-953-r3-run-set.ps1'
$selected = @((Get-Content -Raw -LiteralPath $ManifestPath | ConvertFrom-Json).selected | ForEach-Object { [string] $_ })
$targetIndex = [array]::IndexOf($selected, $Target)
if ($targetIndex -lt 1) { throw "Target '$Target' has no predecessor in the manifest (index $targetIndex)." }
$predecessors = @($selected[0..($targetIndex - 1)])
$script:RunNumber = 0
$script:Log = [System.Collections.Generic.List[string]]::new()

function Invoke-IsolatedSet {
    param([string[]] $File, [string] $Label)
    $script:RunNumber++
    $listPath = "$WorkPrefix-$($script:RunNumber).txt"
    Set-Content -LiteralPath $listPath -Value $File -Encoding utf8
    $output = @(pwsh -NoProfile -File $runSet -ListPath $listPath -WatchTest $WatchTest)
    $lines = @($output | Where-Object { "$_".StartsWith('RESULT=') })
    if ($lines.Count -ne 1) { throw "Run $($script:RunNumber) ($Label) printed $($lines.Count) RESULT lines." }
    $result = $lines[0].Substring(7) | ConvertFrom-Json
    $script:Log.Add("RUN $($script:RunNumber) | $Label | FILES=$($File.Count) | WATCH=$($result.watch) | FAILED=$($result.failed) | STALE_RUN_INSTANCE=$($result.staleRunInstance)")
    return $result
}

$full = Invoke-IsolatedSet -File (@($predecessors) + $Target) -Label 'full-prefix'
if ($full.watch -ne 'Failed') { $script:Log; 'REPRO_FAILS=NO'; exit 3 }
$alone = Invoke-IsolatedSet -File @($Target) -Label 'target-alone'
if ($alone.watch -ne 'Passed') { $script:Log; "TARGET_ALONE=$($alone.watch)"; exit 4 }

$low = 0
$high = $predecessors.Count - 1
while ($low -lt $high) {
    $middle = [int] [math]::Floor(($low + $high) / 2)
    $probe = Invoke-IsolatedSet -File (@($predecessors[0..$middle]) + $Target) -Label "prefix-0..$middle"
    if ($probe.watch -eq 'Failed') { $high = $middle } else { $low = $middle + 1 }
}
$boundary = $low
$atBoundary = Invoke-IsolatedSet -File (@($predecessors[0..$boundary]) + $Target) -Label "boundary-0..$boundary"
$belowBoundary = $alone
if ($boundary -gt 0) { $belowBoundary = Invoke-IsolatedSet -File (@($predecessors[0..($boundary - 1)]) + $Target) -Label "below-0..$($boundary - 1)" }
if ($atBoundary.watch -ne 'Failed' -or $belowBoundary.watch -ne 'Passed') {
    $script:Log.Add('BINARY_SEARCH_NOT_MONOTONIC: linear prefix scan')
    $boundary = -1
    $belowBoundary = $alone
    for ($k = 0; $k -lt $predecessors.Count; $k++) {
        $scan = Invoke-IsolatedSet -File (@($predecessors[0..$k]) + $Target) -Label "scan-0..$k"
        if ($scan.watch -eq 'Failed') { $boundary = $k; $atBoundary = $scan; break }
        $belowBoundary = $scan
    }
    if ($boundary -lt 0) { $script:Log; 'REPRO_FAILS=NOT_REPRODUCIBLE_BY_PREFIX'; exit 5 }
}

$last = $predecessors[$boundary]
$pair = Invoke-IsolatedSet -File @($last, $Target) -Label 'last-with-target'
if ($pair.watch -eq 'Failed') {
    $minimal = @($last)
} else {
    $partners = [System.Collections.Generic.List[string]]::new()
    for ($j = 0; $j -lt $boundary; $j++) {
        $triple = Invoke-IsolatedSet -File @($predecessors[$j], $last, $Target) -Label "partner-$j"
        if ($triple.watch -eq 'Failed') { $partners.Add($predecessors[$j]) }
    }
    if ($partners.Count -gt 0) {
        $minimal = @($partners[0], $last)
        $script:Log.Add("PARTNER_CANDIDATES=$($partners -join '|')")
    } else {
        $minimal = @($predecessors[0..$boundary])
        $script:Log.Add('NO_PAIR_REPRODUCES: MINIMAL_SET is the failing prefix')
    }
}
$confirm = Invoke-IsolatedSet -File (@($minimal) + $Target) -Label 'minimal-with-target'
$mechanism = Invoke-IsolatedSet -File @($minimal) -Label 'minimal-without-target'
Set-Content -LiteralPath "$WorkPrefix-minimal.txt" -Value $minimal -Encoding utf8

$script:Log
'REPRO_FAILS=YES'
"TARGET_ALONE=$($alone.watch)"
"BOUNDARY_INDEX=$boundary"
"BOUNDARY_FILE=$last"
"BOUNDARY_FAILS=$($atBoundary.watch)"
"BELOW_BOUNDARY=$($belowBoundary.watch)"
"MINIMAL_SET=$($minimal -join '|')"
"MINIMAL_SET_WITH_TARGET=$($confirm.watch)"
"MINIMAL_SET_MESSAGE=$($confirm.watchMessage)"
"MECHANISM_STALE_RUN_INSTANCE=$($mechanism.staleRunInstance)"
"MECHANISM_INSTANCES=epic:$($mechanism.epicInstances) run:$($mechanism.runInstances)"
"RUNS=$($script:RunNumber)"
exit 0
```

- [ ] [P1-T3] Verify both scripts and write `docs/features/active/2026-10-16-pester-profiler-coverage-953/evidence/other/r3-scripts-written.<ts>.md`.
  - Through the Tool route, for each of `issue-953-r3-run-set.ps1` and `issue-953-r3-bisect.ps1` under SCRATCH: `$errors = $null; [void][System.Management.Automation.Language.Parser]::ParseFile((Join-Path $S '<name>'), [ref]$null, [ref]$errors); "PARSE_ERRORS=<name> $($errors.Count)"`, `"LINES=<name> $((Get-Content -LiteralPath (Join-Path $S '<name>')).Count)"`, and `"SHA256=<name> $((Get-FileHash -Algorithm SHA256 -LiteralPath (Join-Path $S '<name>')).Hash)"`.
  - Fields: `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:` with the six printed lines.
  - Acceptance: both parse-error counts are 0; the line counts are 54 (`issue-953-r3-run-set.ps1`) and 96 (`issue-953-r3-bisect.ps1`), the line counts of the two blocks above. Otherwise rewrite the file from the block and repeat this task.
- [ ] [P1-T4] [expect-fail] Reproduce the CI failure on the pre-fix tree and write `docs/features/active/2026-10-16-pester-profiler-coverage-953/evidence/regression-testing/r3-pa3-repro-fail-before.<ts>.md`.
  - Through the Tool route, first build the repro list: `$m = Get-Content -Raw -LiteralPath (Join-Path $S 'issue-953-ci3-shard1/shard-files.json') | ConvertFrom-Json; Set-Content -LiteralPath (Join-Path $S 'issue-953-r3-repro.txt') -Value @(@($m.selected)[0..40]) -Encoding utf8; "REPRO_FILES=$(@(Get-Content -LiteralPath (Join-Path $S 'issue-953-r3-repro.txt')).Count)"`. This is `selected[0..40]` of CI_MANIFEST, the same list and order that `SCRATCH/issue-953-repro-shard1.sh` runs.
  - Then run RUN_SET(`repro-before`, `issue-953-r3-repro.txt`) in a second Tool-route script.
  - Fields: `Timestamp:`, `Command:`, `EXIT_CODE:`, `ExpectedExitCode: 1`, and `Output Summary:` with `REPRO_FILES`, the `RESULT=` line, and its fields `total`, `failed`, `failedBlocks`, `failedContainers`, `watch`, `watchMessage`, `staleRunInstance`, and `failedTests`.
  - Acceptance: `REPRO_FILES=41`; RUN_SET valid; EXIT_CODE 1; `failed` 1, `failedBlocks` 0, `failedContainers` 0; `watch` is `Failed`; `failedTests` contains exactly WATCH_TEST; `watchMessage` contains both `Get-EpicScopeCheckpointText` and `but was called 0 times`.
  - If `watch` is `Passed`, the failure does not reproduce on this host: record `REPRO: NOT REPRODUCED`, write the artifact, and stop BLOCKED (a fix cannot be proven without a failing run). Any other deviation: record it and stop BLOCKED.
- [ ] [P1-T5] Bisect the 40 predecessors and write `docs/features/active/2026-10-16-pester-profiler-coverage-953/evidence/regression-testing/r3-pa3-bisect.<ts>.md`.
  - Through the Tool route, in the background: `& (Join-Path $S 'issue-953-r3-bisect.ps1') -ManifestPath (Join-Path $S 'issue-953-ci3-shard1/shard-files.json') -Target 'tests/scripts/claude-hooks/session-root-reads-850.Constraints.Tests.ps1' -WatchTest 'issue #850 changed-file constraints.baseline mock interception probe' -WorkPrefix (Join-Path $S 'issue-953-r3-bisect') *> (Join-Path $S 'issue-953-r3-bisect.log'); $code = $LASTEXITCODE; Get-Content -LiteralPath (Join-Path $S 'issue-953-r3-bisect.log'); "EXIT_CODE=$code"; exit $code`.
  - Fields: `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:` with every `RUN` line and every summary line, `MINIMAL_SET: <paths joined with |>`, and `MECHANISM: <one of the two statements below>`.
  - Mechanism statement: when `MECHANISM_STALE_RUN_INSTANCE=YES`, write `MECHANISM: H1 CONFIRMED - after MINIMAL_SET runs, the WorktreeRunResolution instance that EpicScopeResolution calls is not the instance that Mock -ModuleName WorktreeRunResolution binds to`. Otherwise write `MECHANISM_HYPOTHESIS: NOT CONFIRMED (MECHANISM_STALE_RUN_INSTANCE=<value>)`.
  - Acceptance: EXIT_CODE 0; `REPRO_FAILS=YES`; `TARGET_ALONE=Passed`; `BOUNDARY_FAILS=Failed`; `BELOW_BOUNDARY=Passed`; `MINIMAL_SET_WITH_TARGET=Failed`; `MINIMAL_SET_MESSAGE` contains `Get-EpicScopeCheckpointText`; `SCRATCH/issue-953-r3-bisect-minimal.txt` exists and lists the `MINIMAL_SET` paths. The mechanism value is recorded and does not gate this task. On exit code 3, 4, or 5, or any other failed condition, record the output and stop BLOCKED.
- [ ] [P1-T6] Derive HELPER_SET, run it on the pre-fix tree, and write `docs/features/active/2026-10-16-pester-profiler-coverage-953/evidence/remediation-baseline/r3-helper-set-baseline.<ts>.md`.
  - Through the Tool route: `$root = (Get-Location).Path; [string[]] $set = @(Get-ChildItem -LiteralPath tests -Recurse -File -Filter *.Tests.ps1 | Where-Object { Select-String -LiteralPath $_.FullName -SimpleMatch -Pattern 'EpicStateIsolation.Baseline.Helpers.ps1' -Quiet } | ForEach-Object { [System.IO.Path]::GetRelativePath($root, $_.FullName) -replace '\\', '/' }); [System.Array]::Sort($set, [System.StringComparer]::Ordinal); Set-Content -LiteralPath (Join-Path $S 'issue-953-r3-helper-set.txt') -Value $set -Encoding utf8; "HELPER_SET_COUNT=$($set.Count) CONTAINS_850=$($set -contains 'tests/scripts/claude-hooks/session-root-reads-850.Constraints.Tests.ps1') HELPER_SET_SHA256=$((Get-FileHash -Algorithm SHA256 -LiteralPath (Join-Path $S 'issue-953-r3-helper-set.txt')).Hash)"`.
  - Then run RUN_SET(`helper-set-before`, `issue-953-r3-helper-set.txt`) in the background in a second Tool-route script.
  - Fields: `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:` with the printed line, the `RESULT=` line, and its `total`, `failed`, `failedBlocks`, `failedContainers`, `watch`, and `failedTests` fields as `R3_HELPER_SET_BASELINE_FAILED_TESTS: <failedTests joined with |, or NONE>`.
  - Acceptance: `HELPER_SET_COUNT` is at least 1, `CONTAINS_850=True`, and RUN_SET is valid. The pass or fail outcome is recorded as the pre-fix state and does not gate this task.

### Phase 2 — PA-3 Fix and Pass-After

- [ ] [P2-T1] Edit `tests/scripts/claude-hooks/session-root-reads-850.Constraints.Tests.ps1`: insert the four lines below immediately after line 21 (`    . (Join-Path $PSScriptRoot 'EpicStateIsolation.Baseline.Helpers.ps1')`) and before line 22 (`    Register-EpicStateBaselineMock -Seam 'Get-CleanupWorktreeManifestContent', ...`). Anchor the Edit on line 21, which is unique in the file. No other line changes.
  - Acceptance: the file contains `Remove-Module -Name 'EpicScopeResolution', 'WorktreeRunResolution'` (quoted here as the literal this task creates) exactly once, on the line directly before the first `Register-EpicStateBaselineMock` line.

```powershell
    # Issue #953 (CR-21): a suite that ran earlier in the same Pester process can leave EpicScopeResolution bound to a
    # replaced instance of a sibling module. This suite loads no hook, so unloading the family first makes the
    # registration below build one coherent set of instances (the pattern of the #737 probe harness).
    Remove-Module -Name 'EpicScopeResolution', 'WorktreeRunResolution', 'WorktreeItemResolution', 'WorktreeResolution', 'WorktreeTargetResolution', 'EpicScopeReadiness' -Force -ErrorAction SilentlyContinue
```

- [ ] [P2-T2] Verify the suite edit and write `docs/features/active/2026-10-16-pester-profiler-coverage-953/evidence/other/r3-pa3-suite-edit.<ts>.md`.
  - Run `git diff --numstat <REM_BASE_SHA> -- tests/scripts/claude-hooks/session-root-reads-850.Constraints.Tests.ps1` from the Bash tool (SHA written literally). Through the Tool route: the `ParseFile` error count of the file, `(Get-Content -LiteralPath tests/scripts/claude-hooks/session-root-reads-850.Constraints.Tests.ps1).Count`, the 1-based line numbers of the lines containing `Remove-Module -Name` and of the first line containing `Register-EpicStateBaselineMock -Seam` (`Select-String -SimpleMatch`), and `@(Select-String -LiteralPath tests/scripts/claude-hooks/session-root-reads-850.Constraints.Tests.ps1 -SimpleMatch -Pattern 'Invoke-EpicStateInterceptionProbe -Surface').Count`.
  - Fields: `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:`.
  - Acceptance: numstat `4` added and `0` deleted; 0 parse errors; 118 lines (AC-15); the `Remove-Module -Name` line is line 25 and the first `Register-EpicStateBaselineMock -Seam` line is line 26; the probe-call count is 1 (the probe call is unchanged).
- [ ] [P2-T3] Run RUN_SET(`repro-after`, `issue-953-r3-repro.txt`) on the fixed tree and write `docs/features/active/2026-10-16-pester-profiler-coverage-953/evidence/regression-testing/r3-pa3-repro-pass-after.<ts>.md`.
  - Fields: `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:` with the `RESULT=` line and the `total`, `failed`, `failedBlocks`, `failedContainers`, `watch`, and `staleRunInstance` fields, and the `total` of the latest `r3-pa3-repro-fail-before.*.md` in `docs/features/active/2026-10-16-pester-profiler-coverage-953/evidence/regression-testing/`.
  - Acceptance: RUN_SET valid; EXIT_CODE 0; `failed` 0, `failedBlocks` 0, `failedContainers` 0; `watch` is `Passed`; `total` equals the fail-before `total`.
  - If `watch` is still `Failed`, record the `watchMessage`, and stop BLOCKED: the reset does not cure the mechanism on this host, and an orchestrator decision is required.
- [ ] [P2-T4] Run the minimal polluter pair against the fixed suite and write `docs/features/active/2026-10-16-pester-profiler-coverage-953/evidence/regression-testing/r3-pa3-minimal-pair-pass-after.<ts>.md`.
  - Through the Tool route: `$list = @(Get-Content -LiteralPath (Join-Path $S 'issue-953-r3-bisect-minimal.txt') | Where-Object { $_ -ne '' }) + 'tests/scripts/claude-hooks/session-root-reads-850.Constraints.Tests.ps1'; Set-Content -LiteralPath (Join-Path $S 'issue-953-r3-pair.txt') -Value $list -Encoding utf8; "PAIR_FILES=$($list -join '|')"`, then RUN_SET(`pair-after`, `issue-953-r3-pair.txt`) in a second Tool-route script.
  - Fields: `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:` with `PAIR_FILES`, the `RESULT=` line, and the `MINIMAL_SET_WITH_TARGET` value of the latest `r3-pa3-bisect.*.md` (the same set failed before the fix).
  - Acceptance: RUN_SET valid; EXIT_CODE 0; `failed` 0, `failedBlocks` 0, `failedContainers` 0; `watch` is `Passed`; the recorded `MINIMAL_SET_WITH_TARGET` is `Failed`.
- [ ] [P2-T5] Run TARGETED_RUN(`guard-after`, GUARD_SET) and write `docs/features/active/2026-10-16-pester-profiler-coverage-953/evidence/regression-testing/r3-pa3-guard-pass-after.<ts>.md`.
  - Fields: `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:` with the JRP totals and the JRP token check for every GUARD_TOKENS entry.
  - Acceptance: run valid, EXIT_CODE 0, `failures` 0, `errors` 0, JRP `tests` equal to `R3_GUARD_BASELINE_TESTS` (latest `r3-guard-tests.*.md` in `docs/features/active/2026-10-16-pester-profiler-coverage-953/evidence/remediation-baseline/`), and every GUARD_TOKENS entry PASS. This shows that the discovery guard still accepts the edited suite (AC-4 and AC-6 rows) and that the helper still imports without `-Force`.
- [ ] [P2-T6] Run RUN_SET(`helper-set-after`, `issue-953-r3-helper-set.txt`) in the background and write `docs/features/active/2026-10-16-pester-profiler-coverage-953/evidence/regression-testing/r3-pa3-helper-set-pass-after.<ts>.md`.
  - Before the run, through the Tool route, print `HELPER_SET_SHA256=` with the SHA256 of `SCRATCH/issue-953-r3-helper-set.txt`.
  - Fields: `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:` with the hash line, the `RESULT=` line, and the latest `R3_HELPER_SET_BASELINE_FAILED_TESTS` value from `r3-helper-set-baseline.*.md`.
  - Acceptance: the hash equals the `HELPER_SET_SHA256` of the latest `r3-helper-set-baseline.*.md`; RUN_SET valid; EXIT_CODE 0; `failed` 0, `failedBlocks` 0, `failedContainers` 0; `watch` is `Passed`.
  - If `failed` is greater than 0, every failed test also appears in `R3_HELPER_SET_BASELINE_FAILED_TESTS`, and none is WATCH_TEST, record `PRE_EXISTING_HELPER_SET_FAILURE: <names>` and stop BLOCKED for an orchestrator decision. Any other failure: record it and stop BLOCKED.
- [ ] [P2-T7] [expect-fail] Run TARGETED_RUN(`est-before`, EST_SUITE) on the pre-fix tree and write `docs/features/active/2026-10-16-pester-profiler-coverage-953/evidence/regression-testing/r3-est-fail-before.<ts>.md`.
  - Fields: `Timestamp:`, `Command:`, `EXIT_CODE:`, `ExpectedExitCode: 23`, and `Output Summary:` with the JRP totals and the first log line that contains `Could not find Command`.
  - Acceptance: run valid; EXIT_CODE 23; JRP `tests` 22, `failures` 22, `errors` 1; the log `SCRATCH/issue-953-r3-est-before.log` contains `Could not find Command Get-WorktreeResolutionGitFileText`. Any other outcome: record it and stop BLOCKED.
- [ ] [P2-T8] Edit `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.EpicScopeTargets.Tests.ps1`: insert the three lines below immediately after line 24 (`    Register-EpicStateBaselineMock -Seam 'Get-EpicScopeCheckpointText', 'Get-WorktreeItemCheckpointText', 'Get-WorktreeItemLiveRoot' -Surface 'Claude'`, unique in the file) and before line 25 (the `-Surface 'Codex'` registration). Anchor the Edit on line 24. No other line changes.
  - Acceptance: the file contains `lib/worktree-resolution/WorktreeResolution.psm1` (quoted here as the literal this task creates) exactly once.

```powershell
    # Issue #953 (CR-21): the Codex-surface registration below mocks Get-WorktreeResolutionGitFileText at script
    # scope; importing its module here keeps the suite independent of the suites that ran earlier in the process.
    Import-Module (Join-Path $script:HookRoot 'lib/worktree-resolution/WorktreeResolution.psm1')
```

- [ ] [P2-T9] Verify the EST_SUITE edit and write `docs/features/active/2026-10-16-pester-profiler-coverage-953/evidence/other/r3-est-suite-edit.<ts>.md`.
  - Run `git diff --numstat <REM_BASE_SHA> -- tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.EpicScopeTargets.Tests.ps1` from the Bash tool. Through the Tool route: the `ParseFile` error count of the file and `(Get-Content -LiteralPath tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.EpicScopeTargets.Tests.ps1).Count`.
  - Fields: `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:`.
  - Acceptance: numstat `3` added and `0` deleted; 0 parse errors; 206 lines (AC-15).
- [ ] [P2-T10] Run TARGETED_RUN(`est-after`, EST_SUITE) and TARGETED_RUN(`guard-est-after`, GUARD_SET), and write `docs/features/active/2026-10-16-pester-profiler-coverage-953/evidence/regression-testing/r3-est-pass-after.<ts>.md`.
  - Fields: `Timestamp:`, `Command:`, `EXIT_CODE:` (the `est-after` exit code), and `Output Summary:` with both printed lines, both sets of JRP totals, the JRP token check for EST_TOKEN on the `est-after` JUnit file, and the JRP token check for every GUARD_TOKENS entry on the `guard-est-after` JUnit file.
  - Acceptance: both runs valid with EXIT_CODE 0; `est-after` JRP `tests` 22, `failures` 0, `errors` 0, and EST_TOKEN PASS; `guard-est-after` JRP `failures` 0, `errors` 0, `tests` equal to `R3_GUARD_BASELINE_TESTS`, and every GUARD_TOKENS entry PASS (the discovery guard still accepts the edited suites).
- [ ] [P2-T11] [expect-fail] Run TARGETED_RUN(`oia-before`, OIA_SUITE) on the pre-fix tree and write `docs/features/active/2026-10-16-pester-profiler-coverage-953/evidence/regression-testing/r3-oia-fail-before.<ts>.md`.
  - Fields: `Timestamp:`, `Command:`, `EXIT_CODE:`, `ExpectedExitCode: 45`, and `Output Summary:` with the printed line, the JRP totals, the JRP failure check (step 5) for OIA_DIRECT_TOKEN, the JRP token check (step 4) for OIA_WIRING_TOKEN with its hit count, and `OIA_FIRST_FAILURE_MESSAGE: <failure/@message of the first failed testcase in document order>`.
  - Acceptance: run valid; EXIT_CODE 45 (Pester exits with the failed-test count when `Run.Exit` is set); JRP `tests` 49, `failures` 45, `errors` 0; the OIA_DIRECT_TOKEN failure check PASS; the OIA_WIRING_TOKEN token check PASS with exactly 4 hits. These are the counts of the orchestrator sweep line `RESULT 49 45 0 0`. Any other outcome: record it and stop BLOCKED.
- [ ] [P2-T12] Diagnose the OIA_SUITE alone failure (H2) and write `docs/features/active/2026-10-16-pester-profiler-coverage-953/evidence/other/r3-oia-diagnosis.<ts>.md`. Three Tool-route scripts, each its own new `pwsh` process, run no test and write no file:
  - Script `-1` (suite import order, OIA_SUITE:28-30): `$lib = (Resolve-Path '.claude/lib/orchestrator-state').Path; Import-Module (Join-Path $lib 'OrchestratorStateIssueAdoption.psm1') -Force; "AFTER_ADOPTION_IMPORT=$([bool](Get-Command -Name Get-OrchestratorStateIssueAdoptionResult -ErrorAction SilentlyContinue))"; Import-Module (Join-Path $lib 'OrchestratorStateRoutingContract.psm1') -Force; "AFTER_ROUTING_IMPORT=$([bool](Get-Command -Name Get-OrchestratorStateIssueAdoptionResult -ErrorAction SilentlyContinue))"; "ROUTING_FN=$([bool](Get-Command -Name Get-OrchestratorStateRoutingContractError -ErrorAction SilentlyContinue))"`.
  - Script `-2` (D-R3-4 order): `$lib = (Resolve-Path '.claude/lib/orchestrator-state').Path; Import-Module (Join-Path $lib 'OrchestratorStateRoutingContract.psm1') -Force; Import-Module (Join-Path $lib 'OrchestratorStateIssueAdoption.psm1'); $visible = Get-Command -Name Get-OrchestratorStateIssueAdoptionResult -ErrorAction SilentlyContinue; "FIXED_ORDER_HAS_FN=$([bool]$visible)"; "FIXED_ORDER_ROUTING_FN=$([bool](Get-Command -Name Get-OrchestratorStateRoutingContractError -ErrorAction SilentlyContinue))"; $nested = & (Get-Module -Name OrchestratorStateRoutingContract) { (Get-Command -Name Get-OrchestratorStateIssueAdoptionResult -ErrorAction SilentlyContinue).Module }; "FIXED_ORDER_SAME_INSTANCE=$([object]::ReferenceEquals($visible.Module, $nested))"`.
  - Script `-3` (predecessor state; `OrchestratorStateIssueAdoption.Parity.Tests.ps1:50` imports the routing contract with `-Force` before OIA_SUITE runs in the same process): `$lib = (Resolve-Path '.claude/lib/orchestrator-state').Path; Import-Module (Join-Path $lib 'OrchestratorStateRoutingContract.psm1') -Force; Import-Module (Join-Path $lib 'OrchestratorStateIssueAdoption.psm1') -Force; Import-Module (Join-Path $lib 'OrchestratorStateRoutingContract.psm1') -Force; "PREDECESSOR_STATE_HAS_FN=$([bool](Get-Command -Name Get-OrchestratorStateIssueAdoptionResult -ErrorAction SilentlyContinue))"`.
  - Fields: `Timestamp:`, `Command:` (the three script bodies), `EXIT_CODE:`, `Output Summary:` with every printed line and the `OIA_FIRST_FAILURE_MESSAGE` of the latest `r3-oia-fail-before.*.md`, and `MECHANISM_OIA: <statement>`.
  - Mechanism statement: when `AFTER_ADOPTION_IMPORT=True`, `AFTER_ROUTING_IMPORT=False`, `ROUTING_FN=True`, and `OIA_FIRST_FAILURE_MESSAGE` contains `Get-OrchestratorStateIssueAdoptionResult`, write `MECHANISM_OIA: H2 CONFIRMED - the forced nested import at OrchestratorStateRoutingContract.psm1:61 unloads the adoption module that OIA_SUITE:29 imported, so the suite relies on a predecessor's module state to see Get-OrchestratorStateIssueAdoptionResult`. Otherwise write `MECHANISM_OIA: NOT CONFIRMED` with the observed values.
  - Acceptance: every script exits 0; `MECHANISM_OIA: H2 CONFIRMED`; `FIXED_ORDER_HAS_FN=True` and `FIXED_ORDER_ROUTING_FN=True`. `FIXED_ORDER_SAME_INSTANCE` and `PREDECESSOR_STATE_HAS_FN` are recorded as observations and do not gate this task.
  - On `MECHANISM_OIA: NOT CONFIRMED` or `FIXED_ORDER_HAS_FN=False`: do not edit OIA_SUITE; record the values and stop BLOCKED. If the observed values show that `OrchestratorStateIssueAdoption.psm1` or `OrchestratorStateRoutingContract.psm1` itself fails (for example a module-scope error on import), record `OIA_MODULE_DEFECT_SUSPECTED:` with the evidence and stop BLOCKED; no production file is changed in this cycle.
- [ ] [P2-T13] Edit `tests/scripts/claude-lib/orchestrator-state/OrchestratorStateIssueAdoption.Tests.ps1`: replace lines 29-30 (`    Import-Module (Join-Path $libDir 'OrchestratorStateIssueAdoption.psm1') -Force` and `    Import-Module (Join-Path $libDir 'OrchestratorStateRoutingContract.psm1') -Force`, each unique in the file) with the five lines below in one Edit call anchored on those two lines. No other line changes.
  - Acceptance: no line of the file contains `'OrchestratorStateIssueAdoption.psm1') -Force`, and the file contains `Import-Module (Join-Path $libDir 'OrchestratorStateIssueAdoption.psm1')` (quoted here as the literal this task creates) exactly once (verified in P2-T14).

```powershell
    # Issue #953 (CR-21): OrchestratorStateRoutingContract.psm1 imports OrchestratorStateIssueAdoption.psm1 with
    # -Force, which unloads an instance imported here first. Importing the routing contract first and the adoption
    # module second, without -Force, keeps both visible whatever ran earlier in the Pester process.
    Import-Module (Join-Path $libDir 'OrchestratorStateRoutingContract.psm1') -Force
    Import-Module (Join-Path $libDir 'OrchestratorStateIssueAdoption.psm1')
```

- [ ] [P2-T14] Verify the OIA_SUITE edit and write `docs/features/active/2026-10-16-pester-profiler-coverage-953/evidence/other/r3-oia-suite-edit.<ts>.md`.
  - Run `git diff --numstat <REM_BASE_SHA> -- tests/scripts/claude-lib/orchestrator-state/OrchestratorStateIssueAdoption.Tests.ps1` from the Bash tool (SHA written literally).
  - Through the Tool route: the `ParseFile` error count of the file; `(Get-Content -LiteralPath tests/scripts/claude-lib/orchestrator-state/OrchestratorStateIssueAdoption.Tests.ps1).Count`; the 1-based line numbers of the lines containing `'OrchestratorStateRoutingContract.psm1') -Force` and `'OrchestratorStateIssueAdoption.psm1')` (`Select-String -SimpleMatch`); the count of lines containing `'OrchestratorStateIssueAdoption.psm1') -Force`; and `SHOULD_BEFORE=` and `SHOULD_AFTER=`, the counts of lines containing `Should -` in `git show <REM_BASE_SHA>:tests/scripts/claude-lib/orchestrator-state/OrchestratorStateIssueAdoption.Tests.ps1` and in the working-tree file.
  - Fields: `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:`.
  - Acceptance: numstat `4` added and `1` deleted; 0 parse errors; 437 lines (434 - 2 + 5; AC-15); the routing-contract import is line 32 and the adoption-module import is line 33, each found exactly once; the forced adoption-import count is 0; `SHOULD_BEFORE` equals `SHOULD_AFTER` (no assertion removed).
- [ ] [P2-T15] Run TARGETED_RUN(`oia-after`, OIA_SUITE) and TARGETED_RUN(`oia-dir-after`, `tests/scripts/claude-lib/orchestrator-state`), and write `docs/features/active/2026-10-16-pester-profiler-coverage-953/evidence/regression-testing/r3-oia-pass-after.<ts>.md`.
  - Fields: `Timestamp:`, `Command:`, `EXIT_CODE:` (the `oia-after` exit code), and `Output Summary:` with both printed lines, both sets of JRP totals, the JRP token check for OIA_DIRECT_TOKEN and OIA_WIRING_TOKEN on both JUnit files, and the `tests` value of the latest `r3-oia-fail-before.*.md`.
  - Acceptance: both runs valid with EXIT_CODE 0; `oia-after` JRP `tests` 49 (equal to the fail-before `tests`), `failures` 0, `errors` 0; `oia-dir-after` JRP `failures` 0 and `errors` 0 (the sibling suites of the directory still pass in one process after the edited suite); OIA_DIRECT_TOKEN and OIA_WIRING_TOKEN PASS on both files.
  - If `oia-after` still fails, record the failed testcases and stop BLOCKED for an orchestrator decision.

### Phase 3 — CR-18 and CR-19 Regression Tests (must fail first)

Every edit in this phase uses the Edit tool on a test file (no batch-budget slot). The anchor text quoted in each task is unique in its file at PLAN_HEAD.

- [ ] [P3-T1] Edit `tests/scripts/powershell/PoshQC/PoshQC.Shard.Tests.ps1`: insert the five lines below between line 92 (`    }`, closing SH12) and line 93 (`}`, closing `Describe 'Get-PoshQCShardSlice'`). Anchor the Edit on line 91 (`        { Get-PoshQCShardSlice -TestFile @('a', 'b', 'c') -Weight @(1, 2) -ShardIndex 1 -ShardCount 2 } | Should -Throw '*Weight lists 2 values; TestFile lists 3 files*'`) and lines 92-93. No other line changes.
  - Acceptance: `SH13-SLICE-NEGATIVE-WEIGHT-THROWS` occurs exactly once in the file.

```powershell

    It 'SH13-SLICE-NEGATIVE-WEIGHT-THROWS rejects a negative weight and names the file (CR-18)' {
        { Get-PoshQCShardSlice -TestFile @('a', 'b', 'c') -Weight @(2, -1, 3) -ShardIndex 1 -ShardCount 2 } | Should -Throw "*Weight must not be negative; 'b' has weight -1*"
        (@(Get-PoshQCShardSlice -TestFile @('a', 'b') -Weight @(0, 0) -ShardIndex 1 -ShardCount 2) -join ',') | Should -BeExactly 'a' -Because 'a zero weight is valid'
    }
```

- [ ] [P3-T2] Edit `tests/scripts/powershell/PoshQC/PoshQC.Shard.Tests.ps1`: append the 46 lines below after the final `}` of the file (the `}` that closes `Describe 'Test-PoshQCShardTestCount'`, line 177 after P3-T1). Anchor the Edit on the last four lines of the file (`        Test-PoshQCShardTestCount -ShardTestCount @(10, 20, 30) -DiscoveryCount 60 | Should -BeTrue`, `        Test-PoshQCShardTestCount -ShardTestCount @() -DiscoveryCount 0 | Should -BeTrue`, `    }`, `}`). No other line changes.
  - Acceptance: each of `SH14-WEIGHT-IGNORES-LINE-ENDINGS` and `SH15-SELECT-WEIGHS-CHECKED-IN-FILES-BY-NORMALIZED-TEXT` occurs exactly once in the file.

```powershell

Describe 'Get-PoshQCShardTestFileWeight and Select-PoshQCShardTestFile weights' {
    It 'SH14-WEIGHT-IGNORES-LINE-ENDINGS weights a FileInfo item by the UTF-8 size of its text with CRLF counted as LF (CR-19)' {
        # Arrange: in-memory texts only; the FileInfo items name paths that are never opened.
        $texts = @{ 'a.Tests.ps1' = ("x`n" * 10); 'b.Tests.ps1' = (('y' * 24) + "`n") }
        $readLf = { param([string] $Path) $texts[[System.IO.Path]::GetFileName($Path)] }.GetNewClosure()
        $readCrLf = { param([string] $Path) $texts[[System.IO.Path]::GetFileName($Path)].Replace("`n", "`r`n") }.GetNewClosure()

        InModuleScope PoshQC -Parameters @{ LfReader = $readLf; CrLfReader = $readCrLf } {
            param([scriptblock] $LfReader, [scriptblock] $CrLfReader)
            $items = @([System.IO.FileInfo]::new('/shard-root/tests/a.Tests.ps1'), [System.IO.FileInfo]::new('/shard-root/tests/b.Tests.ps1'))

            # Act
            $lfWeights = @(Get-PoshQCShardTestFileWeight -TestFile $items -ReadTestFileText $LfReader)
            $crLfWeights = @(Get-PoshQCShardTestFileWeight -TestFile $items -ReadTestFileText $CrLfReader)
            $otherWeights = @(Get-PoshQCShardTestFileWeight -TestFile @('/shard-root/tests/c.Tests.ps1', [pscustomobject]@{ FullName = '/shard-root/tests/d.Tests.ps1'; Length = [long] 7 }))

            # Assert: raw CRLF sizes (30 and 26) would make a heavier than b; the normalized sizes keep b heavier.
            ($lfWeights -join ',') | Should -BeExactly '20,25'
            ($crLfWeights -join ',') | Should -BeExactly '20,25' -Because 'a CRLF checkout must compute the same weights as an LF checkout'
            ($otherWeights -join ',') | Should -BeExactly '1,7' -Because 'a path string weighs 1 and another object weighs its Length property'
        }
    }

    It 'SH15-SELECT-WEIGHS-CHECKED-IN-FILES-BY-NORMALIZED-TEXT reads FileInfo items through the default reader and gives shard 1 the heavier file (CR-19)' {
        # Arrange: two checked-in module files are read; nothing is written.
        $moduleRoot = Join-Path $PSScriptRoot '../../../../scripts/powershell/PoshQC'
        $items = @(Get-Item -LiteralPath (Join-Path $moduleRoot 'PoshQC.Shard.psm1'), (Join-Path $moduleRoot 'PoshQC.CoverageMerge.psm1'))

        InModuleScope PoshQC -Parameters @{ Items = $items } {
            param([object[]] $Items)
            $readCrLf = { param([string] $Path) [System.IO.File]::ReadAllText($Path) -replace "`r?`n", "`r`n" }

            # Act
            $defaultWeights = @(Get-PoshQCShardTestFileWeight -TestFile $Items)
            $crLfWeights = @(Get-PoshQCShardTestFileWeight -TestFile $Items -ReadTestFileText $readCrLf)
            $selected = @(Select-PoshQCShardTestFile -RootPath '/shard-root' -TestFile $Items -ShardIndex 1 -ShardCount 2 -WriteShardFileList { })

            # Assert
            ($defaultWeights -join ',') | Should -BeExactly ($crLfWeights -join ',') -Because 'the default reader and a CRLF copy of the same text give equal weights'
            $defaultWeights[0] | Should -Not -Be $defaultWeights[1] -Because 'the two module files differ in size'
            $heavier = if ($defaultWeights[0] -gt $defaultWeights[1]) { $Items[0].FullName } else { $Items[1].FullName }
            ($selected -join ',') | Should -BeExactly $heavier -Because 'shard 1 receives the heaviest file first'
        }
    }
}
```

- [ ] [P3-T3] Verify the test edits and write `docs/features/active/2026-10-16-pester-profiler-coverage-953/evidence/other/r3-shard-test-edits.<ts>.md`.
  - Run `git diff --numstat <REM_BASE_SHA> -- tests/scripts/powershell/PoshQC/PoshQC.Shard.Tests.ps1` from the Bash tool, and through the Tool route the `ParseFile` error count and `(Get-Content -LiteralPath tests/scripts/powershell/PoshQC/PoshQC.Shard.Tests.ps1).Count`.
  - Fields: `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:`.
  - Acceptance: numstat `51` added and `0` deleted; 0 parse errors; 223 lines (172 + 5 + 46; AC-15).
- [ ] [P3-T4] [expect-fail] Run TARGETED_RUN(`shard-before`, R3_SHARD_SET) on the pre-fix production tree and write `docs/features/active/2026-10-16-pester-profiler-coverage-953/evidence/regression-testing/r3-shard-fail-before.<ts>.md`.
  - Fields: `Timestamp:`, `Command:`, `EXIT_CODE:`, `ExpectedExitCode: 3`, and `Output Summary:` with the JRP totals, the JRP failure check (step 5) with the failure message for every R3_NEW_TOKENS entry, and the JRP token check (step 4) for every R3_SHARD_OLD_TOKENS entry.
  - Acceptance:
    - Run valid, EXIT_CODE 3 (Pester exits with the failed-test count when `Run.Exit` is set), JRP `tests` equal to `R3_TARGETED_BASELINE_TESTS` (latest `r3-targeted-tests.*.md` in `docs/features/active/2026-10-16-pester-profiler-coverage-953/evidence/remediation-baseline/`) plus 3, `failures` 3, and `errors` 0.
    - Every R3_NEW_TOKENS failure check PASS, and every R3_SHARD_OLD_TOKENS token check PASS.
  - If any condition fails, stop and report; do not start Phase 4.

### Phase 4 — CR-18 and CR-19 Production Changes, Documentation, Mirror, and Pass-After

No test runs in this phase before P4-T7 and P4-T8 (Task-ordering rule). The Edit tool writes exactly one production PowerShell file in this phase (Batch budget).

- [ ] [P4-T1] Edit `scripts/powershell/PoshQC/PoshQC.Shard.psm1` (CR-18) with two Edit calls and no other line change:
  1. Replace lines 9-10 (`input order. Throws when ShardCount is below 1, ShardIndex is outside 1..ShardCount, or Weight and TestFile` and `differ in length.`) with the two lines in the first block below.
  2. Insert the five lines of the second block immediately after line 41 (the `    }` that closes the `if ($Weight.Count -ne $TestFile.Count)` block), so the existing blank line 42 stays before `$order`. Anchor the Edit on line 40 (`        throw "Weight lists $($Weight.Count) values; TestFile lists $($TestFile.Count) files."`) and line 41.
  - Acceptance: the file contains `Weight must not be negative;` and `or a weight is negative (CR-18).` (quoted here as literals this task creates), each exactly once.

```text
input order. Throws when ShardCount is below 1, ShardIndex is outside 1..ShardCount, Weight and TestFile
differ in length, or a weight is negative (CR-18).
```

```powershell
    for ($position = 0; $position -lt $Weight.Count; $position++) {
        if ($Weight[$position] -lt 0) {
            throw "Weight must not be negative; '$($TestFile[$position])' has weight $($Weight[$position])."
        }
    }
```

- [ ] [P4-T2] Edit `Select-PoshQCShardTestFile` in `scripts/powershell/PoshQC/PoshQC.Shard.psm1` (CR-19) with two Edit calls and no other line change:
  1. Replace the help lines `Weights each enumerated test file by its Length property (the size in bytes of the FileInfo items that the` and `default EnumerateTests seam returns; 1 for a plain path string or an item without a Length property), builds` (lines 216-217 at PLAN_HEAD, 221-222 after P4-T1) with the two lines in the first block below.
  2. Replace the line `    $weights = [long[]] @($TestFile | ForEach-Object { if ($_ -isnot [string] -and $null -ne $_.PSObject.Properties['Length']) { [long] $_.Length } else { [long] 1 } })` (line 247 at PLAN_HEAD, 252 after P4-T1) with the line in the second block below.
  - Acceptance: the file contains `$weights = [long[]] @(Get-PoshQCShardTestFileWeight -TestFile $TestFile)` (quoted here as the literal this task creates) exactly once, and no line contains `[long] $_.Length`.

```text
Weights each enumerated test file with Get-PoshQCShardTestFileWeight (a FileInfo item, as the default
EnumerateTests seam returns, weighs the UTF-8 size of its text with CRLF counted as LF; CR-19), builds
```

```powershell
    $weights = [long[]] @(Get-PoshQCShardTestFileWeight -TestFile $TestFile)
```

- [ ] [P4-T3] Edit `scripts/powershell/PoshQC/PoshQC.Shard.psm1`: append the 35 lines below after the final `}` of the file (the `}` that closes `Select-PoshQCShardTestFile`). Anchor the Edit on the last five lines of the file (from `    if ($ShardFileListPath) {` through the final `}`). No other line changes.
  - Acceptance: the file contains `function Get-PoshQCShardTestFileWeight {` and `$weights.Add([System.Text.Encoding]::UTF8.GetByteCount($text.Replace(` (quoted here as literals this task creates), each exactly once.

```powershell

<#
.SYNOPSIS
Returns the shard weight of each enumerated test file (issue #953, CR-19).
.DESCRIPTION
A FileInfo item weighs the UTF-8 byte count of its text after every CRLF pair is replaced by LF, so a checkout
with CRLF line endings computes the same weights, and therefore the same shard assignment, as a checkout with
LF line endings. Another object weighs its Length property when it has one; a plain path string, or an object
without a Length property, weighs 1. Returns one weight per item, in input order.
.PARAMETER TestFile
Enumerated test files: FileInfo items, objects with FullName (and optionally Length), or path strings.
.PARAMETER ReadTestFileText
Seam that returns the text of a test file from its full path. Defaults to [System.IO.File]::ReadAllText.
#>
function Get-PoshQCShardTestFileWeight {
    [CmdletBinding()]
    [OutputType([long[]])]
    param(
        [Parameter(Mandatory)][AllowEmptyCollection()][object[]] $TestFile,
        [scriptblock] $ReadTestFileText = { param([string] $Path) [System.IO.File]::ReadAllText($Path) }
    )

    $weights = New-Object 'System.Collections.Generic.List[long]'
    foreach ($item in $TestFile) {
        if ($item -is [System.IO.FileInfo]) {
            $text = [string] (& $ReadTestFileText $item.FullName)
            $weights.Add([System.Text.Encoding]::UTF8.GetByteCount($text.Replace("`r`n", "`n")))
        } elseif ($item -isnot [string] -and $null -ne $item.PSObject.Properties['Length']) {
            $weights.Add([long] $item.Length)
        } else {
            $weights.Add(1)
        }
    }
    [long[]] $weights.ToArray()
}
```

- [ ] [P4-T4] Verify `scripts/powershell/PoshQC/PoshQC.Shard.psm1` and write `docs/features/active/2026-10-16-pester-profiler-coverage-953/evidence/other/r3-shard-psm1-edit.<ts>.md`.
  - Run `git diff --numstat <REM_BASE_SHA> -- scripts/powershell/PoshQC/PoshQC.Shard.psm1` from the Bash tool. Through the Tool route: the `ParseFile` error count, `(Get-Content -LiteralPath scripts/powershell/PoshQC/PoshQC.Shard.psm1).Count`, and the count of lines that start with `function ` and name each of `Get-PoshQCShardSlice`, `New-PoshQCShardManifest`, `Test-PoshQCShardCompleteness`, `Test-PoshQCShardTestCount`, `Select-PoshQCShardTestFile`, and `Get-PoshQCShardTestFileWeight`.
  - Fields: `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:`.
  - Acceptance: numstat `45` added and `5` deleted; 0 parse errors; 296 lines (256 + 5 + 35; AC-15); each of the six function names is defined exactly once.
- [ ] [P4-T5] Edit `scripts/powershell/PoshQC/README.md` with two Edit calls and no other line change:
  1. Replace line 62 (``- `Get-PoshQCShardSlice`: select one shard's test files; with `-Weight` (for example file sizes in bytes) the heaviest files are assigned first to the least-loaded shard.``) with the first line below.
  2. Replace line 84 (the line that starts `  - Test files are weighted by size in bytes and assigned heaviest first`) with the second line below.
  - Acceptance: the file contains `a negative weight is rejected` and `CRLF line endings counted as LF` (quoted here as literals this task creates), each exactly once; it contains no line with `every runner that checks out the same tree`; it has 98 lines.

```markdown
- `Get-PoshQCShardSlice`: select one shard's test files; with `-Weight` (non-negative values, for example text sizes in bytes) the heaviest files are assigned first to the least-loaded shard, and a negative weight is rejected.
  - Test files are weighted by the UTF-8 size in bytes of their text with CRLF line endings counted as LF, and assigned heaviest first to the shard with the least assigned weight (ties: fewer files, then the lower shard index; equal sizes are taken in ordinal path order), so runners whose checkouts differ only in line-ending conversion compute the same assignment.
```

- [ ] [P4-T6] Run the PoshQC formatter once over the edited tree (write-mode tool) and write `docs/features/active/2026-10-16-pester-profiler-coverage-953/evidence/other/r3-format-prepass.<ts>.md`.
  - Through the Tool route: record `$before = git status --porcelain`, run `pwsh -NoProfile -Command "Import-Module ./scripts/powershell/PoshQC/PoshQC.psd1 -Force; Invoke-PoshQCFormat -Root (Get-Location).Path" *> (Join-Path $S 'issue-953-r3-prepass-format.log')`, record `$LASTEXITCODE`, then record `$after = git status --porcelain`.
  - Fields: `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:` with every log line that starts with `Formatted: ` and whether `$before` equals `$after`.
  - Acceptance: EXIT_CODE 0, and the path of every `Formatted: ` line, normalized to forward slashes, ends with one of the five PS_CYCLE_FILES paths. Otherwise stop BLOCKED and record the path. This pass may reformat those files; P5-T1 later requires zero `Formatted: ` lines.
- [ ] [P4-T7] Mirror and check parity. Through the Tool route, run `Copy-Item -LiteralPath scripts/powershell/PoshQC/<name> -Destination extensions/drm-copilot/resources/powershell/PoshQC/<name> -Force` for `<name>` in `PoshQC.Shard.psm1` and `README.md`, then print one `PAIR_EQUAL: <name> True|False` line per BUNDLE_PAIRS pair from `Get-FileHash -Algorithm SHA256`. Then run `poetry run pytest tests/scripts/dev_tools/test_poshqc_bundled_parity.py -q` from the Bash tool. Write `docs/features/active/2026-10-16-pester-profiler-coverage-953/evidence/other/r3-mirror-parity.<ts>.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:` (the four lines and the pytest summary line).
  - Acceptance: all four lines read `True`, and the pytest summary line contains `1 passed` (AC-02; `PoshQC.Shard.psm1` is in `POSHQC_PARITY_PATHS`, `tests/scripts/dev_tools/test_poshqc_bundled_parity.py:16`).
- [ ] [P4-T8] Run TARGETED_RUN(`shard-after`, R3_SHARD_SET) and write `docs/features/active/2026-10-16-pester-profiler-coverage-953/evidence/regression-testing/r3-shard-pass-after.<ts>.md`.
  - Fields: `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:` with the JRP totals and the JRP token check for every R3_SHARD_OLD_TOKENS and R3_NEW_TOKENS entry.
  - Acceptance: run valid, EXIT_CODE 0, JRP `tests` equal to `R3_TARGETED_BASELINE_TESTS` plus 3, `failures` 0, `errors` 0, and every token PASS.

### Phase 5 — Final QC Loop

Restart rule and shard-failure stop rule: see Fail-Closed Rules. All QC artifacts go to `docs/features/active/2026-10-16-pester-profiler-coverage-953/evidence/qa-gates/`.

- [ ] [P5-T1] Run the PoshQC formatter (write-mode tool) and write `docs/features/active/2026-10-16-pester-profiler-coverage-953/evidence/qa-gates/r3-final-poshqc-format.<ts>.md`.
  - Before the formatter runs, compute the SHA256 of every CYCLE_FILES path and record `$before = git status --porcelain` (Tool route).
  - Run `pwsh -NoProfile -Command "Import-Module ./scripts/powershell/PoshQC/PoshQC.psd1 -Force; Invoke-PoshQCFormat -Root (Get-Location).Path" *> (Join-Path $S 'issue-953-r3-final-format.log')`, record `$LASTEXITCODE`, then record `$after = git status --porcelain`.
  - Fields: `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:` (the count of log lines starting with `Formatted: `, the count starting with `Already formatted:`, and whether `$before` equals `$after`), and one `HASH_BEFORE: <path> <SHA256>` line per CYCLE_FILES path.
  - Acceptance: EXIT_CODE 0, zero `Formatted: ` lines, and `$before` equal to `$after` (AC-07: no diff).
- [ ] [P5-T2] Run `pwsh -NoProfile -Command "Import-Module ./scripts/powershell/PoshQC/PoshQC.psd1 -Force; Invoke-PoshQCAnalyze -Root (Get-Location).Path" *> (Join-Path $S 'issue-953-r3-final-analyze.log')` (Tool route) and write `docs/features/active/2026-10-16-pester-profiler-coverage-953/evidence/qa-gates/r3-final-poshqc-analyze.<ts>.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:`.
  - Acceptance: EXIT_CODE 0 and the log contains the literal `PSScriptAnalyzer passed: no findings under` (AC-07: zero findings).
- [ ] [P5-T3] Run FULL_RUN(final) and write `docs/features/active/2026-10-16-pester-profiler-coverage-953/evidence/qa-gates/r3-final-poshqc-test-coverage.<ts>.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:`, and `R3_FINAL_JUNIT_TESTS: <JRP tests>`.
  - The Output Summary contains the JRP totals, the JRP token check for every R3_SHARD_OLD_TOKENS, R3_NEW_TOKENS, GUARD_TOKENS, and CYCLE2_TOKENS entry, the FULL_RUN wall seconds, and the CRP values `LINE_COVERED`, `LINE_MISSED`, `LINE_TOTAL`, `LINE_PERCENT`, and `SOURCEFILE_COUNT`.
  - Acceptance:
    - FULL_RUN valid, EXIT_CODE 0, `JUNIT_FAILURES` 0, and `JUNIT_ERRORS` 0 (AC-07: zero failed tests).
    - Every listed token PASS.
    - JRP `tests` equals `R3_BASELINE_JUNIT_TESTS` (latest `r3-poshqc-test-coverage.*.md` in `docs/features/active/2026-10-16-pester-profiler-coverage-953/evidence/remediation-baseline/`) plus 3.
- [ ] [P5-T4] Compute the coverage delta from `issue-953-r3-baseline-coverage.xml` and `issue-953-r3-final-coverage.xml` under SCRATCH with CRP, and the changed-line set with CLD, and write `docs/features/active/2026-10-16-pester-profiler-coverage-953/evidence/qa-gates/r3-final-coverage-delta.<ts>.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:`.
  - The Output Summary contains:
    - Baseline and final `LINE_COVERED`, `LINE_TOTAL`, `LINE_PERCENT`, and `SOURCEFILE_COUNT`.
    - Baseline and final per-file `covered` and `missed` for MOD_KEY.
    - `CLD(scripts/powershell/PoshQC/PoshQC.Shard.psm1)`, and for each listed number `nr` the final `L(MOD_KEY, nr)`; the counts `CHANGED_LINES`, `EXECUTABLE_CHANGED` (not `ABSENT`), and `UNCOVERED_CHANGED` (`ci=0`), and the list of uncovered numbers.
  - Acceptance:
    - The final CRP threshold (step 7) PASSES (repository-wide LINE coverage at least 85%).
    - The final key set equals the baseline key set, and for every key other than MOD_KEY the baseline and final per-file totals (`covered + missed`) are equal.
    - For MOD_KEY, `100 * covered -ge 85 * (covered + missed)` in the final file.
    - `UNCOVERED_CHANGED` is 0 and `EXECUTABLE_CHANGED` is at least 1.
  - The Output Summary states that the bundled copies are outside the coverage roots of `config/poshqc-coverage.json` and are not measured, that test files are not in the coverage population, and that Pester measures no branch coverage.
- [ ] [P5-T5] Run SHARD_RUN(`final`, 1) and write `docs/features/active/2026-10-16-pester-profiler-coverage-953/evidence/qa-gates/r3-final-shard-1.<ts>.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:` (the printed line, the selected-file count from `SCRATCH/issue-953-r3-final-shard-1.json`, the JRP totals of `SCRATCH/issue-953-r3-final-shard-1-junit.xml`, and the wall seconds).
  - Acceptance: run valid, EXIT_CODE 0, JRP `failures` 0 and `errors` 0, and JRP `tests` greater than 0.
  - On any failure (shard-failure stop rule): record every failed testcase as `<classname> | <name>`; take the first failed testcase, set `<target>` to its `classname` converted to a repository-relative forward-slash path (strip the repository-root prefix and replace each backslash with `/`) and `<watch>` to its `name`; run `& (Join-Path $S 'issue-953-r3-bisect.ps1') -ManifestPath (Join-Path $S 'issue-953-r3-final-shard-1.json') -Target '<target>' -WatchTest '<watch>' -WorkPrefix (Join-Path $S 'issue-953-r3-final-shard-1-bisect')` through the Tool route in the background; record its output as `SHARD_FAILURE_BISECT:`; and stop BLOCKED for an orchestrator decision.
- [ ] [P5-T6] Run SHARD_RUN(`final`, 2) and write `docs/features/active/2026-10-16-pester-profiler-coverage-953/evidence/qa-gates/r3-final-shard-2.<ts>.md` with the same fields as P5-T5 for shard 2 (`issue-953-r3-final-shard-2.json`, `issue-953-r3-final-shard-2-junit.xml`).
  - Acceptance and failure handling: as P5-T5, with shard 2 file names and the work prefix `issue-953-r3-final-shard-2-bisect`.
- [ ] [P5-T7] Run SHARD_RUN(`final`, 3) and write `docs/features/active/2026-10-16-pester-profiler-coverage-953/evidence/qa-gates/r3-final-shard-3.<ts>.md` with the same fields as P5-T5 for shard 3 (`issue-953-r3-final-shard-3.json`, `issue-953-r3-final-shard-3-junit.xml`).
  - Acceptance and failure handling: as P5-T5, with shard 3 file names and the work prefix `issue-953-r3-final-shard-3-bisect`.
- [ ] [P5-T8] Verify the three final shards together and write `docs/features/active/2026-10-16-pester-profiler-coverage-953/evidence/qa-gates/r3-final-shard-completeness.<ts>.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:`.
  - Through the Tool route: `Import-Module ./scripts/powershell/PoshQC/PoshQC.psd1 -Force; $manifests = @(1..3 | ForEach-Object { Get-Content -Raw -LiteralPath (Join-Path $S "issue-953-r3-final-shard-$_.json") | ConvertFrom-Json }); "COMPLETE=$(Test-PoshQCShardCompleteness -ShardManifest $manifests)"; "SHARD_FILES=$(@($manifests | ForEach-Object { @($_.selected).Count }) -join ',')"; "SHARD_OF_850=$(@(1..3 | Where-Object { @($manifests[$_ - 1].selected) -contains 'tests/scripts/claude-hooks/session-root-reads-850.Constraints.Tests.ps1' }) -join ',')"`. Then apply JRP to the three shard JUnit files: record each `tests` value and `SHARD_TEST_SUM`, and count the hits of each of WATCH_TEST and EST_TOKEN across the three files with their results.
  - The Output Summary also records the three wall-second values from the latest `r3-final-shard-1.*.md`, `r3-final-shard-2.*.md`, and `r3-final-shard-3.*.md`, and `R3_FINAL_JUNIT_TESTS` from the latest `r3-final-poshqc-test-coverage.*.md`.
  - Acceptance: `COMPLETE=True`; every `SHARD_FILES` value is at least 1; `SHARD_OF_850` names exactly one shard; `SHARD_TEST_SUM` equals `R3_FINAL_JUNIT_TESTS`; each of WATCH_TEST and EST_TOKEN has exactly one hit across the three files, and that hit is passed (CR-21 holds in the composition CI will run; AC-11 completeness guard).
  - On any failed condition, record the values and stop BLOCKED (shard-failure stop rule).
- [ ] [P5-T9] Run `poetry run pytest tests/scripts/dev_tools/test_poshqc_bundled_parity.py -q` and write `docs/features/active/2026-10-16-pester-profiler-coverage-953/evidence/qa-gates/r3-final-parity-pytest.<ts>.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:` quoting the summary line.
  - Acceptance: EXIT_CODE 0 and the summary line contains `1 passed` (AC-02).
- [ ] [P5-T10] Verify bundle identity for every BUNDLE_PAIRS pair with `Get-FileHash -Algorithm SHA256` (Tool route) and write `docs/features/active/2026-10-16-pester-profiler-coverage-953/evidence/qa-gates/r3-final-bundle-identity.<ts>.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:`, and one `PAIR_EQUAL: <name> YES|NO` line per pair.
  - Acceptance: all four pairs record `YES` (the README pair is outside the parity pytest).
- [ ] [P5-T11] Run actionlint through the Tool route with the P0-T16 task text and write `docs/features/active/2026-10-16-pester-profiler-coverage-953/evidence/qa-gates/r3-final-actionlint.<ts>.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:`.
  - Acceptance: EXIT_CODE 0 with no actionlint output.
- [ ] [P5-T12] Verify file sizes (AC-15) and write `docs/features/active/2026-10-16-pester-profiler-coverage-953/evidence/qa-gates/r3-final-file-size.<ts>.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:` listing each path and its line count.
  - Build the changed-file set as the union of the paths from `git diff --name-only origin/main...HEAD` and from `git status --porcelain --untracked-files=all` (both from the Bash tool). Keep only paths for which `Test-Path -LiteralPath <path> -PathType Leaf` is true, drop paths ending in `.md`, and record `(Get-Content -LiteralPath <path>).Count` for each remaining path (Tool route).
  - Acceptance:
    - Every count is at most 500.
    - The set includes `scripts/powershell/PoshQC/PoshQC.Shard.psm1`, `tests/scripts/powershell/PoshQC/PoshQC.Shard.Tests.ps1`, `tests/scripts/claude-hooks/session-root-reads-850.Constraints.Tests.ps1`, `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.EpicScopeTargets.Tests.ps1`, and `tests/scripts/claude-lib/orchestrator-state/OrchestratorStateIssueAdoption.Tests.ps1`.
- [ ] [P5-T13] Verify AC-13 and the check name, and write `docs/features/active/2026-10-16-pester-profiler-coverage-953/evidence/qa-gates/r3-final-scope-ac13.<ts>.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:`.
  - Run `git diff --name-only origin/main...HEAD` and `git status --porcelain` from the Bash tool.
  - With `$mb = git merge-base origin/main HEAD`, for every file in `Get-ChildItem .github/workflows -Filter *.yml`, extract the `on:` block (from the line matching `^on:` through the line before the next line matching `^\S`) from the worktree file and from `git show "${mb}:.github/workflows/<name>"`, and compare the two (Tool route).
  - Run `git diff --numstat <REM_BASE_SHA> -- .github/workflows` from the Bash tool.
  - In `.github/workflows/_poshqc.yml`, count the lines matching `^  poshqc:\s*$` and the lines matching `^    name: PowerShell QC\s*$` (Tool route, `Select-String` with a regular expression).
  - Acceptance: neither listing contains `.github/workflows/ci.yml`; every `on:` block is identical to the merge-base text; the `.github/workflows` numstat output is empty (no workflow change in this cycle); both counts are exactly 1 (the check name stays `poshqc / PowerShell QC`).
- [ ] [P5-T14] Verify the D3 and ceiling constraints and write `docs/features/active/2026-10-16-pester-profiler-coverage-953/evidence/qa-gates/r3-final-d3-ceiling.<ts>.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:`.
  - Through the Tool route with `Select-String -SimpleMatch` (case-insensitive): in `.github/workflows/_poshqc.yml`, count the lines containing `CoveragePercentTarget`, `-lt 85`, `-ge 85`, or `fail-under`; count the lines containing `Import-Module Pester` and the lines containing `-MaximumVersion 5.99.99`. In `scripts/powershell/PoshQC/PoshQC.Shard.psm1`, count the lines that contain both `throw` and `percent`.
  - Acceptance: the threshold counts and the `throw`/`percent` count are 0 (D3: no failing coverage threshold); the `Import-Module Pester` count equals the `-MaximumVersion 5.99.99` count, and both are at least 1.
- [ ] [P5-T15] Verify the CR-18 and CR-19 documentation and write `docs/features/active/2026-10-16-pester-profiler-coverage-953/evidence/qa-gates/r3-final-docs.<ts>.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:`.
  - Through the Tool route with `Select-String -SimpleMatch`, in `scripts/powershell/PoshQC/README.md` count the lines containing each of `a negative weight is rejected`, `CRLF line endings counted as LF`, `Sharded runs (issue #953)`, and `every runner that checks out the same tree`; in `scripts/powershell/PoshQC/PoshQC.Shard.psm1` count the lines containing `or a weight is negative (CR-18).` and `weighs the UTF-8 size of its text with CRLF counted as LF`.
  - Acceptance: the first three README counts are exactly 1, the fourth is 0; both module counts are exactly 1; and the README pair is identical (latest `r3-final-bundle-identity.*.md`).
- [ ] [P5-T16] Verify AC-12 (#936 files), AC-14, and the cycle blast radius, and write `docs/features/active/2026-10-16-pester-profiler-coverage-953/evidence/qa-gates/r3-final-blast-radius.<ts>.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:`, `PYTHON_FILES_CHANGED_THIS_CYCLE: NONE`, and `SHELL_FILES_CHANGED_THIS_CYCLE: NONE`.
  - Build the cycle set as the union of the paths from `git diff --name-only <REM_BASE_SHA>` and from `git status --porcelain --untracked-files=all`, both run from the Bash tool. Build the branch set from `git diff --name-only origin/main...HEAD` (Bash tool).
  - Acceptance:
    - Every path in the cycle set is a CYCLE_FILES path, this plan file, or a path under `docs/features/active/2026-10-16-pester-profiler-coverage-953/evidence/`.
    - No path in the cycle set ends in `.py`, `.sh`, `.json`, or `.yml`.
    - No path in either set starts with `.claude/rules/` or `.github/instructions/` (AC-14).
    - Neither set contains a FILES_936 path (AC-12: no #936-owned test file is modified), `tests/scripts/claude-hooks/EpicStateIsolation.Baseline.Helpers.ps1`, or any path listed in `SCRATCH/issue-953-r3-bisect-minimal.txt`.
- [ ] [P5-T17] Run ALONE_SWEEP(`final`) on the final tree through the Tool route in the background and write `docs/features/active/2026-10-16-pester-profiler-coverage-953/evidence/qa-gates/r3-final-alone-sweep.<ts>.md`.
  - The sweep writes `SCRATCH/issue-953-r3-final-alone-sweep.txt` and prints the same lines.
  - Fields: `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:` with the `FILES=`, `FAILED_ALONE_COUNT=`, and `TRACKED_TEST_FILES=` lines and every `FAIL_ALONE:` line.
  - Acceptance: EXIT_CODE 0; the output contains exactly one `FAILED_ALONE_COUNT=` line and it reads `FAILED_ALONE_COUNT=0`; no `FAIL_ALONE:` line is present; the `FILES=` value equals the `TRACKED_TEST_FILES=` value (the count of `*.Tests.ps1` under `tests/scripts`). The orchestrator sweep on `789843870` recorded `FILES=388` and `FAILED_ALONE_COUNT=2` (EST_SUITE and OIA_SUITE); this task shows that P2-T8 and P2-T13 removed both and that no other suite fails alone.
  - On failure: restart rule (Phase 5), including its BLOCKED condition for a `FAIL_ALONE:` path outside CYCLE_FILES.
- [ ] [P5-T18] Record loop closure and write `docs/features/active/2026-10-16-pester-profiler-coverage-953/evidence/qa-gates/r3-final-loop-closure.<ts>.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:`, and `LOOP_CLEAN_PASS: YES|NO`.
  - Recompute the SHA256 of every CYCLE_FILES path and compare each with the `HASH_BEFORE:` lines of the latest `r3-final-poshqc-format.*.md` in `docs/features/active/2026-10-16-pester-profiler-coverage-953/evidence/qa-gates/`.
  - Acceptance: every hash is unchanged, P5-T1 through P5-T17 of this pass passed, and `LOOP_CLEAN_PASS: YES`.
- [ ] [P5-T19] Record the re-verification and write `docs/features/active/2026-10-16-pester-profiler-coverage-953/evidence/qa-gates/r3-ac-reverification.<ts>.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:`.
  - The Output Summary has one line per item, `RECHECK: <item> | <evidence tasks> | PASS|FAIL`, for CR-21, CR-18, CR-19, AC-02, AC-07, AC-11, AC-12, AC-13, AC-14, and AC-15, using the "Requirements Traceability" evidence tasks.
  - Run `git diff --numstat <REM_BASE_SHA> -- docs/features/active/2026-10-16-pester-profiler-coverage-953/spec.md` and `git status --porcelain -- docs/features/active/2026-10-16-pester-profiler-coverage-953/spec.md` from the Bash tool, and record both outputs.
  - Acceptance: every line reads PASS, and both `spec.md` outputs are empty (no checkbox changed and no acceptance criterion added).
  - If any line reads FAIL, record `AC_RECHECK_FAILED: <item>` and stop for an orchestrator decision; the executor does not edit `spec.md`.
