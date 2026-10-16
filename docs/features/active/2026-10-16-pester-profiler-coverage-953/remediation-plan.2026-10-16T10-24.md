# 2026-10-16-pester-profiler-coverage (Remediation Plan, Cycle 1)

- **Issue:** #953
- **Branch:** `bug/pester-profiler-coverage-953`
- **Work Mode:** full-bug (acceptance criteria source: `docs/features/active/2026-10-16-pester-profiler-coverage-953/spec.md`; this cycle adds no acceptance criterion and changes no checkbox)
- **Inputs:** `docs/features/active/2026-10-16-pester-profiler-coverage-953/remediation-inputs.2026-10-16T10-24.md` (findings CR-1, CR-2, CR-3), `docs/features/active/2026-10-16-pester-profiler-coverage-953/code-review.2026-10-16T10-17.md`, reference plan `docs/features/active/2026-10-16-pester-profiler-coverage-953/plan.2026-10-16T00-16.md` (revision 1.5, executed through Phase 6)
- **Planning-time head:** `2004de667` (the branch contains merge commit `0087d2bc2` of `origin/main`). Every line citation below was re-derived against the working tree at this head.
- **Last Updated:** 2026-10-16
- **Status:** Draft revision 1.1 (preflight findings D1-D3 applied), pending executor preflight
- **Version:** 1.1

## Scope

This cycle fixes three Minor findings that decision D11 brings into the item:

- **CR-1:** the default `$EnsureModule` seam of `Invoke-PoshQCTest` treats any installed Pester as present.
- **CR-2:** the same seam imports Pester with an upper bound only.
- **CR-3:** `Install-PoshQCTool` writes its version-range predicate twice.

PA-1 to PA-3 (`awaiting_ci`) are carried forward unchanged. They are resolved by reference-plan Phase 7 on the PR head that contains this cycle's commits. This plan adds no CI task.

## Files Written

This section is the declared blast radius of this cycle. No other tracked path is written.

Source, tests, and documentation (7 paths):

1. `scripts/powershell/PoshQC/PoshQC.Testing.psm1`: the default `$EnsureModule` seam at lines 163-170 and its call at line 306 only (CR-1, CR-2). Edit tool.
2. `extensions/drm-copilot/resources/powershell/PoshQC/PoshQC.Testing.psm1`: identical to item 1, written with `Copy-Item`.
3. `scripts/powershell/PoshQC/PoshQC.psm1`: lines 61-62 and 75-76 only (CR-3). Edit tool.
4. `extensions/drm-copilot/resources/powershell/PoshQC/PoshQC.psm1`: identical to item 3, written with `Copy-Item`.
5. `tests/scripts/powershell/PoshQC/PoshQC.RunSettings.Tests.ps1`: two lines inserted after line 130 (RS06), and the RS08-RS10 Describe block appended after line 163.
6. `tests/scripts/powershell/PoshQC/PoshQC.TestingSeamDefaults.Tests.ps1`: two lines inserted after line 78.
7. `extensions/drm-copilot/CHANGELOG.md`: line 26 of the `[Unreleased]` entry for issue #953 only.

Feature folder (planning and evidence):

8. `docs/features/active/2026-10-16-pester-profiler-coverage-953/remediation-plan.2026-10-16T10-24.md` (this plan; checkbox state only during execution).
9. `docs/features/active/2026-10-16-pester-profiler-coverage-953/evidence/remediation-baseline/*.md`
10. `docs/features/active/2026-10-16-pester-profiler-coverage-953/evidence/regression-testing/*.md`
11. `docs/features/active/2026-10-16-pester-profiler-coverage-953/evidence/qa-gates/*.md`
12. `docs/features/active/2026-10-16-pester-profiler-coverage-953/evidence/other/*.md`

Conditionally written by the orchestrator only: `docs/features/active/2026-10-16-pester-profiler-coverage-953/spec.md`, and only to uncheck an acceptance criterion whose re-verification in P5-T13 fails. The executor never writes `spec.md`.

Not written, and present before the cycle: `docs/features/active/2026-10-16-pester-profiler-coverage-953/remediation-inputs.2026-10-16T10-24.md`.

Not tracked: `artifacts/pester/*` (git-ignored, `.gitignore:6`), `.claude/state/*` (git-ignored, `.gitignore:70`), and every scratch file under SCRATCH.

Host change outside the repository: P0-T1 can install Pester 5.9.0 into the CurrentUser PowerShell module path. This is an orchestrator-owned task (see "Assumptions and Advisories", Local Pester range).

Never written: `.github/workflows/ci.yml`; the `on:` block of any `.github/workflows/*.yml` file; `.github/workflows/_poshqc.yml`; `.claude/rules/**`; `.github/instructions/**`; `tests/scripts/powershell/PoshQC/PoshQC.Comprehensive.Tests.ps1` (766 lines; an edit would place it in the AC-15 changed-file set); `.devcontainer/post-create.sh` and `.github/codex/codex-web-setup.sh` (their own predicate copies are out of scope per CR-3); any `.py`, `.sh`, `.yml`, or `.json` file.

## Fail-Closed Rules

- **Evidence rule.** Every artifact named below is mandatory. An artifact missing any of `Timestamp:`, `Command:`, `EXIT_CODE:`, or `Output Summary:` leaves its task unchecked, and the cycle outcome is BLOCKED, never PASS.
- **Evidence filename timestamps.** Every evidence file is named `<name>.<ts>.md`. `<ts>` is the UTC write time read from the host clock immediately before the write (`Get-Date -AsUTC -Format yyyy-MM-ddTHH-mm`). A consuming task reads the lexicographically greatest file matching `<name>.*.md` in the named folder. Every evidence name in this plan starts with `r1-`, so it never collides with a reference-plan artifact.
- **No MCP PoshQC evidence.** No task uses a `run_poshqc_*` MCP tool. All PoshQC evidence comes from the self-hosted module `scripts/powershell/PoshQC/PoshQC.psd1`.
- **Task ownership.** P0-T1 is `(owner: orchestrator)` and completes before the executor starts. The orchestrator commits this plan, `remediation-inputs.2026-10-16T10-24.md`, and the P0-T1 evidence file to `bug/pester-profiler-coverage-953` before starting the executor, because an executor in an agent-isolated worktree sees only committed files. Every other task is executor-owned.
- **Batch budget.** The Write and Edit tools touch two production PowerShell files in this cycle: `scripts/powershell/PoshQC/PoshQC.Testing.psm1` and `scripts/powershell/PoshQC/PoshQC.psm1`. Bundled copies are written only with `Copy-Item` through the Tool route. Test files do not consume a slot (`.claude/hooks/enforce-powershell-batch-budget.ps1:302`). If the hook denies a write, the executor stops and reports; it does not bypass the hook.
- **Tool route.** In an agent-isolated worktree, a PreToolUse guard refuses any typed Bash command whose text contains `pwsh`, `bash`, or `wsl`, and atomic-executor has no PowerShell tool. Every PowerShell command of an executor-owned task, including a single cmdlet in an acceptance check, therefore runs as follows:
  - **Script.** The executor writes the POSIX shell file `SCRATCH/issue-953-r1-<step>.sh` with the Write tool and runs it from the Bash tool as `sh "<SCRATCH absolute path, forward slashes>/issue-953-r1-<step>.sh"`.
  - **Command line.** The path is written literally: no shell variable, and no `;`, `&&`, `|`, or redirection on that command line.
  - **Fixed body.** Line 1 is `export MSYS_NO_PATHCONV=1`. Line 2 is `pwsh -NoProfile -Command '$S = "<SCRATCH absolute path, forward slashes>"; <task PowerShell text>'`. Inside the single-quoted argument every `'` of the task text is written `'\''`. When the task records the exit code of a final native command, the text ends with `; exit $LASTEXITCODE`.
  - **Step names.** `<step>` is the lowercased task ID (for example `issue-953-r1-p2-t5.sh`), with a `-<n>` suffix when a task needs more than one script. The route probe uses `issue-953-r1-probe.sh` and the same fixed body; it is not exempt from it.
  - **Long runs.** A run longer than the Bash tool timeout (FULL_RUN) is started with the Bash tool's background option; the executor waits for the completion notification, with no sleep or polling loop.
  - **Non-PowerShell commands.** `git` and `poetry run ...` run directly from the Bash tool.
  - **Evidence.** `Command:` fields record the script body with the literal `SCRATCH` in place of the host path.
- **Never edit a bundled copy.** No Write or Edit tool call targets a file under `extensions/drm-copilot/resources/powershell/PoshQC/`.
- **No temporary files in tests.** Every test added or edited by this plan reads only checked-in files and in-memory values.
- **Task-ordering rule.** The only deliberately failing state is introduced by P1-T1 through P1-T3 (tests RS08-RS10 written before the fix). P1-T5 is the single `[expect-fail]` run. No other test run takes place between P1-T1 and P2-T5, the pass-after run. Between P3-T1 and P3-T2 the file is in an intermediate state; no test runs until P3-T5.
- **Restart rule (Phase 5).** If any task from P5-T1 through P5-T11 fails or changes a tracked file, the executor fixes the cause and restarts at P5-T1. Evidence from an abandoned pass is kept; consumers read the latest file.
- **Stop rule.** A task whose acceptance states "stop BLOCKED" ends execution: the executor reports the recorded values and does not start the next task.

## Definitions (fixed; the executor does not substitute values)

- **FEATURE** = `docs/features/active/2026-10-16-pester-profiler-coverage-953`.
- **SCRATCH** = `<session scratchpad>/issue-953/`, where `<session scratchpad>` is the session scratchpad directory supplied to the executor at run time (outside the repository). Every file created directly under SCRATCH starts with `issue-953-r1-`. In PowerShell text, `$S` holds the absolute SCRATCH path. Evidence records the literal token `SCRATCH`, never a host path.
- **REM_BASE_SHA** = the commit printed by `git rev-parse HEAD` in P0-T10, before any cycle edit. Every numstat check compares `REM_BASE_SHA` against the working tree, so committed and uncommitted changes are both counted.
- **BASE_SHA** = the commit printed by `git merge-base HEAD origin/main` in P0-T10.
- **FULL_RUN(phase)**: the only run whose coverage counts locally. It passes no `-ScanFolders` and no `-SettingsPath`, and runs through the Tool route, in the background when the Bash tool timeout is shorter than the run. Task PowerShell text:

```powershell
New-Item -ItemType Directory -Force -Path artifacts/pester | Out-Null; $start = [datetime]::UtcNow; pwsh -NoProfile -Command "Import-Module ./scripts/powershell/PoshQC/PoshQC.psd1 -Force; Invoke-PoshQCTest -Root (Get-Location).Path" *> (Join-Path $S 'issue-953-r1-<phase>-poshqc.log'); $exit = $LASTEXITCODE; $end = [datetime]::UtcNow; "EXIT_CODE=$exit SECONDS=$([int]($end - $start).TotalSeconds) START_UTC=$($start.ToString('o'))"; Copy-Item artifacts/pester/powershell-coverage.xml (Join-Path $S 'issue-953-r1-<phase>-coverage.xml') -Force; Copy-Item artifacts/pester/pester-junit.xml (Join-Path $S 'issue-953-r1-<phase>-junit.xml') -Force; exit $exit
```

  `<phase>` is `baseline` in P0-T17 and `final` in P5-T3. `Run.Exit = $true` in `scripts/powershell/PoshQC/settings/pester.runsettings.psd1:4`, so the exit code is 0 only when Pester reports no failure.

  FULL_RUN is valid only when all three of these hold:
  - (a) Both `artifacts/pester/powershell-coverage.xml` and `artifacts/pester/pester-junit.xml` have `LastWriteTimeUtc` later than the printed `START_UTC`. Parse `START_UTC` with `[datetime]::Parse('<START_UTC>', [cultureinfo]::InvariantCulture, [System.Globalization.DateTimeStyles]::RoundtripKind).ToUniversalTime()`.
  - (b) The log contains exactly one line with the literal `Code coverage population: source=config` (`scripts/powershell/PoshQC/PoshQC.Testing.psm1:356` writes it). Count the lines with `@(Select-String -LiteralPath (Join-Path $S 'issue-953-r1-<phase>-poshqc.log') -SimpleMatch -Pattern 'Code coverage population: source=config').Count`.
  - (c) The command contains no `-ScanFolders` and no `-SettingsPath` argument.

  Local Pester precondition: after CR-2, `Invoke-PoshQCTest` requires an installed Pester from 5.9.0 to 5.99.99, which P0-T1 guarantees.
- **TARGETED_RUN(tag, paths)**: no coverage. It runs through the Tool route, and its doubled single quotes become `'\'''\''` under the Tool-route quoting rule. Task PowerShell text:

```powershell
$env:ISSUE953_PATHS = '<paths joined with ;>'; $env:ISSUE953_JUNIT = Join-Path $S 'issue-953-r1-<tag>-junit.xml'; $start = [datetime]::UtcNow; pwsh -NoProfile -Command 'Import-Module Pester -MinimumVersion 5.4.0 -MaximumVersion 5.99.99 -ErrorAction Stop; $c = New-PesterConfiguration; $c.Run.Path = @($env:ISSUE953_PATHS -split '';''); $c.Run.Exit = $true; $c.CodeCoverage.Enabled = $false; $c.TestResult.Enabled = $true; $c.TestResult.OutputFormat = ''JUnitXml''; $c.TestResult.OutputPath = $env:ISSUE953_JUNIT; $c.Output.Verbosity = ''Detailed''; Invoke-Pester -Configuration $c' *> (Join-Path $S 'issue-953-r1-<tag>.log'); "EXIT_CODE=$LASTEXITCODE START_UTC=$($start.ToString('o'))"
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
  2. Aggregate: `$agg = @($x.report.counter | Where-Object { $_.type -eq 'LINE' })`; require `$agg.Count -eq 1`, else FAIL. Derive `LINE_COVERED = [int]$agg[0].covered`, `LINE_MISSED = [int]$agg[0].missed`, `LINE_TOTAL = LINE_COVERED + LINE_MISSED`, and `LINE_PERCENT = [math]::Round(100.0 * LINE_COVERED / LINE_TOTAL, 2)`.
  3. Root prefix: `$anchor = @($x.report.package | Where-Object { ($_.name -replace '[\\]', '/') -like '*/scripts/powershell/PoshQC' -and @($_.sourcefile | Where-Object { $_.name -ceq 'PoshQC.Testing.psm1' }).Count -eq 1 })`; require `$anchor.Count -eq 1`. `ROOTP` is the normalized anchor name without the trailing `/scripts/powershell/PoshQC`.
  4. Per-file map: every package name, normalized, must start with `ROOTP + '/'` (case-insensitive), else FAIL. Key = (normalized package name minus `ROOTP + '/'`) + `/` + sourcefile name, lowercased. Value = the integers `covered` and `missed` of the single `LINE` counter of the sourcefile. A duplicate key is FAIL.
  5. Cross-check: the per-file `covered` sum equals `LINE_COVERED` and the per-file `missed` sum equals `LINE_MISSED`, else FAIL. `SOURCEFILE_COUNT` is the number of keys.
  6. Line lookup `L(key, nr)`: the `line` child of that sourcefile whose `[int]nr` equals `nr`, reported as `ci=<int> mi=<int>`, or `ABSENT` when none exists.
  7. Threshold: PASS if and only if `LINE_TOTAL -gt 0` and `100 * LINE_COVERED -ge 85 * LINE_TOTAL` (integer arithmetic). The 85% line default governs because the root `CLAUDE.md` states no coverage threshold (`.claude/rules/general-unit-test.md`, Coverage Requirements). PowerShell has no branch-coverage gate (Pester does not measure branch coverage).
- **R1_SET** (the targeted test set, joined with `;` for TARGETED_RUN): `tests/scripts/powershell/PoshQC/PoshQC.RunSettings.Tests.ps1`, `tests/scripts/powershell/PoshQC/PoshQC.ModuleCoverage.Tests.ps1`, `tests/scripts/powershell/PoshQC/PoshQC.Tests.ps1`, `tests/scripts/powershell/PoshQC/PoshQC.EntryPoints.Tests.ps1`, `tests/scripts/powershell/PoshQC/PoshQC.TestingSeamDefaults.Tests.ps1`, `tests/scripts/powershell/PoshQC/PoshQC.Comprehensive.Tests.ps1`, `tests/scripts/powershell/PoshQC/PoshQC.TestingCommands.Tests.ps1`. Together these hold every test that reaches the default `$EnsureModule` seam or `Install-PoshQCTool`.
- **RS tokens**: `RS01-RUNSETTINGS-PROFILER-MODE`, `RS02-PESTER-CONFIG-USEBREAKPOINTS-FALSE`, `RS03-INSTALLER-PESTER-590`, `RS04-BUNDLED-RUNSETTINGS-PROFILER-MODE`, `RS05-INSTALLER-PESTER-CEILING-BELOW-6`, `RS06-TEST-IMPORT-PESTER-MAXIMUM`, `RS07-WORKFLOW-LINUX-PESTER-RANGE` (existing), and `RS08-TEST-IMPORT-PESTER-RANGE-BOUNDS`, `RS09-TEST-PESTER-6-ONLY-ACTIONABLE-ERROR`, `RS10-TEST-PESTER-INBOX-ONLY-ACTIONABLE-ERROR` (added by P1-T2).
- **MC tokens** (`tests/scripts/powershell/PoshQC/PoshQC.ModuleCoverage.Tests.ps1:30,43,55,67,87`): `MC01-LOGGER-DEFAULT-WARNING`, `MC02-LOGGER-DEFAULT-VERBOSE`, `MC03-LOGGER-DEFAULT-INFORMATION`, `MC04-INSTALL-POSTCHECK-THROWS`, `MC05-SUBMODULE-CACHE-MISS-IMPORT`.
- **INST tokens** (the existing `Install-PoshQCTool` test names):
  - In `tests/scripts/powershell/PoshQC/PoshQC.Tests.ps1`: `registers PSGallery when absent and installs required modules` (line 84), `logs a warning when PSGallery trust cannot be set` (line 112), `skips installation when required modules are already present` (line 130), and `throws when an injected install operation fails` (line 151).
  - In `tests/scripts/powershell/PoshQC/PoshQC.EntryPoints.Tests.ps1`: `keeps manifest dependency requirements empty to allow bootstrap installs` (line 32) and `reports already-installed modules without external module lookup` (line 40).
- **SEAM tokens** (the existing tests of the `Invoke-PoshQCTest` module seam): `imports the requested module with -Global` (`tests/scripts/powershell/PoshQC/PoshQC.TestingSeamDefaults.Tests.ps1:73`), `throws the supplied error when the module is unavailable` (`tests/scripts/powershell/PoshQC/PoshQC.TestingSeamDefaults.Tests.ps1:90`), and `validates Pester module availability through injected module lookup` (`tests/scripts/powershell/PoshQC/PoshQC.EntryPoints.Tests.ps1:86`).
- **CEIL_R1**: the ceiling sweep after this cycle. Each row gives a file, a literal token searched with `Select-String -SimpleMatch` (case-insensitive, counting matching lines), and the exact expected count. Tokens containing `$` are passed in single quotes.
  - `scripts/powershell/PoshQC/PoshQC.psm1` and `extensions/drm-copilot/resources/powershell/PoshQC/PoshQC.psm1`: `6.0.0` = 1; `[version]$module.UpperBound` = 1 (this was 2 before CR-3); `Where-Object -FilterScript $isSupportedVersion` = 2; `5.6.1` = 0.
  - `scripts/powershell/PoshQC/PoshQC.Testing.psm1` and `extensions/drm-copilot/resources/powershell/PoshQC/PoshQC.Testing.psm1`: `5.99.99` = 1; `-MaximumVersion $MaximumVersion` = 1; `-MinimumVersion $MinimumVersion` = 1; `ModuleVersion = $MinimumVersion` = 1; `MaximumVersion = $MaximumVersion` = 1; `'5.9.0' '5.99.99'` = 1.
  - `.github/workflows/_poshqc.yml`: `-MaximumVersion 5.99.99` = 1.
  - `.devcontainer/post-create.sh` and `.github/codex/codex-web-setup.sh`: `6.0.0` = 1; `[version]$module.UpperBound` = 1.
  - `scripts/powershell/PoshQC/README.md` and `extensions/drm-copilot/resources/powershell/PoshQC/README.md`: `below 6.0` = 1.
- **CYCLE_FILES**: items 1-7 of "Files Written".

## Assumptions and Advisories

- **Local Pester range (CR-2 consequence).** After CR-2, the default seam requires an installed Pester from 5.9.0 to 5.99.99. FULL_RUN runs that seam for real. The local host recorded Pester 5.6.1 and 3.4.0 only (`docs/features/active/2026-10-16-pester-profiler-coverage-953/evidence/baseline/pester-version.2026-10-16T07-46.md`, P0-T17 of the reference plan). On that host the final FULL_RUN would stop at the actionable error before any test runs.
  - CI is not affected: both jobs run `Install-PoshQCTools` first (`.github/workflows/_poshqc.yml:16-20` and `:64-68`), which installs Pester 5.9.0.
  - P0-T1 therefore installs Pester 5.9.0 into the CurrentUser scope when no in-range version is present. It uses the command of the default install seam (`scripts/powershell/PoshQC/PoshQC.psm1:25`).
  - Because the install precedes the cycle baseline, the baseline and final FULL_RUN both use the same Pester.
  - This is a host change outside the repository and is orchestrator-owned. A concurrent run on the same host that imports Pester with `-MaximumVersion 5.99.99` would pick up 5.9.0 from the moment of the install.
- **CR-1 design: range-qualified presence query.** The presence check becomes `Get-Module -ListAvailable -FullyQualifiedName @{ ModuleName = $Name; ModuleVersion = $MinimumVersion; MaximumVersion = $MaximumVersion }`, so PowerShell applies the range.
  - A `Where-Object` filter on `Version` was rejected. `tests/scripts/powershell/PoshQC/PoshQC.Comprehensive.Tests.ps1` mocks `Get-Module` in 9 cases (lines 348, 362, 410, 447, 484, 530, 579, 646, and 703) to return `[PSCustomObject]@{ Name = 'Pester' }`, an object with no `Version`. A version filter would reject those objects and fail all 9 cases.
  - Repairing those fixtures would place that 766-line file in the AC-15 changed-file set (limit 500 lines).
  - Those mocks ignore their parameters, so the chosen design leaves them passing.
  - RS08 asserts the query shape. P2-T7 confirms on the local host that the real `Get-Module` applies the range.
- **CR-2 design.** The seam gains `[string] $MinimumVersion`, placed before `$MaximumVersion`. The call passes `'5.9.0' '5.99.99'`, and the import passes both bounds. These values match `.github/workflows/_poshqc.yml:73` and the installer floor at `scripts/powershell/PoshQC/PoshQC.psm1:58`.
  - The error message gains the range: `Pester is not installed in the supported range (5.9.0 to 5.99.99). Run Install-PoshQCTool (alias Install-PoshQCTools) first.`
  - Every existing assertion on that message uses the wildcard `*Pester is not installed*`, which still matches: `tests/scripts/powershell/PoshQC/PoshQC.TestingSeamDefaults.Tests.ps1:97`, `tests/scripts/powershell/PoshQC/PoshQC.Comprehensive.Tests.ps1:340`, `tests/scripts/powershell/PoshQC/PoshQC.EntryPoints.Tests.ps1:93`, and `tests/scripts/powershell/PoshQC/PoshQC.TestingCommands.Tests.ps1:135`.
  - Injected seams in existing tests declare at most `$Name` and `$ErrorMessage` (`tests/scripts/powershell/PoshQC/PoshQC.EntryPoints.Tests.ps1:89`, `tests/scripts/powershell/PoshQC/PoshQC.TestingCommands.Tests.ps1:134`) or no parameters (`-EnsureModule { }`). The extra positional arguments go to `$args` and do not affect them.
- **Test determinism.** Two existing cases run the default seam against the host's real `Get-Module`: RS06 (`tests/scripts/powershell/PoshQC/PoshQC.RunSettings.Tests.ps1:127-140`) and `imports the requested module with -Global` (`tests/scripts/powershell/PoshQC/PoshQC.TestingSeamDefaults.Tests.ps1:73-88`). After CR-1 they would pass only on a host with an in-range Pester. P1-T1 and P1-T3 add a `Get-Module` mock to each, so their result no longer depends on the host.
- **CR-3 design and the AC-08 denominator.** AC-08 (CI-dependent, unchecked) requires the PR-head repository-wide LINE total to equal the baseline artifact's total. Pester counts one coverage line per source line that starts a command, including the body of a scriptblock literal.
  - A separately defined predicate therefore adds one counted line (the definition line).
  - CR-3 compensates by merging the post-install lookup into the `if` condition (`if (-not (& $FindModule ... | Select-Object -First 1)) {`). That removes the `$post` assignment line, which was counted separately from the `if (-not $post)` line.
  - The net per-file count is unchanged, and the behavior is unchanged: the same lookup with `Select-Object -First 1` feeds the same test.
  - The CR-1 and CR-2 seam keeps exactly two counted lines (the presence `if` line and the import line). Every other inserted line is a comment or a `param` line.
  - P5-T4 verifies equality of the per-file and repository-wide LINE totals against the cycle baseline. If either differs, P5-T4 fails and the executor stops and reports, because AC-08 would then fail on CI.
- **CR-3 scoping.** The shared predicate reads `$module`. `Where-Object -FilterScript` runs a scriptblock of the same session state in the caller's current scope (the scope of `Install-PoshQCTool`), so `$module` resolves to the requirement of the current loop iteration. The inline predicate it replaces resolved `$module` the same way.
- **Line numbers after the edits.**
  - `scripts/powershell/PoshQC/PoshQC.Testing.psm1`: the seam grows from 8 to 10 lines, so the call moves from line 306 to 308. The changed counted lines are 167 (presence `if`), 171 (import), and 308 (call). The file grows from 461 to 463 lines.
  - `scripts/powershell/PoshQC/PoshQC.psm1`: P3-T1 inserts 4 lines before line 61, and P3-T2 merges two lines into one. The changed counted lines are 63 (predicate definition), 66 (present lookup), and 79 (merged post-install `if`). The file grows by 3 lines.
- **Acceptance-criteria re-verification.** This cycle changes files that carry evidence for AC-02, AC-03, AC-04, AC-06, AC-07, AC-13, AC-14, AC-15, and AC-16.
  - Phase 5 re-verifies them, AC-07, AC-15, and AC-16 in particular.
  - The executor does not change any checkbox in `spec.md`. If a re-verification fails and cannot be fixed within the restart rule, the executor records `AC_RECHECK_FAILED: <AC>` in P5-T13 and stops; the orchestrator then decides whether to uncheck the box.
  - AC-08 to AC-12 remain CI-dependent and are verified by reference-plan Phase 7 on the PR head.
- **Coverage authority.** Local FULL_RUN values (cycle baseline and final) supply the policy-required baseline, post-change, and changed-line values for this cycle. The CI artifact comparison stays with reference-plan Phase 7.
- **No evidence location override was supplied.** All evidence paths are canonical `FEATURE/evidence/<kind>/` paths.

## Requirements Traceability

| Item | Implementation tasks | Tests | Evidence tasks |
|---|---|---|---|
| CR-1 | P2-T1, P2-T4 | `RS08-TEST-IMPORT-PESTER-RANGE-BOUNDS` (query shape), `RS09-TEST-PESTER-6-ONLY-ACTIONABLE-ERROR`, `RS10-TEST-PESTER-INBOX-ONLY-ACTIONABLE-ERROR` | P1-T5, P2-T5, P2-T7, P5-T3 |
| CR-2 | P2-T1, P2-T2, P2-T4 | `RS08-TEST-IMPORT-PESTER-RANGE-BOUNDS` (import bounds), `RS10-TEST-PESTER-INBOX-ONLY-ACTIONABLE-ERROR` | P1-T5, P2-T5, P5-T3 |
| CR-3 | P3-T1, P3-T2, P3-T4 | RS03, RS05, MC01-MC05, INST tokens | P0-T16, P3-T5, P5-T3 |
| AC-02 | P2-T4, P3-T4 | `tests/scripts/dev_tools/test_poshqc_bundled_parity.py::test_poshqc_bundled_module_files_match_repo_root_sources` | P3-T6, P5-T5 |
| AC-03 | P1-T1, P1-T2 (RS file changes) | RS02, RS03 | P2-T5, P5-T3 |
| AC-04 | P3-T1 (no pin change) | CEIL_R1 `5.6.1` rows | P5-T7 |
| AC-06 | P4-T1 | `[Unreleased]` token counts | P5-T8 |
| AC-07 | P1-T1 through P4-T1 | full self-hosted suite | P5-T1, P5-T2, P5-T3, P5-T12 |
| AC-13 | scope constraint | `on:` block comparison | P5-T9 |
| AC-14 | scope constraint | path-prefix check | P5-T10 |
| AC-15 | size constraint | line counts | P1-T4, P5-T6 |
| AC-16 | P2-T1, P2-T2, P3-T1, P3-T2 | RS05, RS06, RS07, CEIL_R1 | P2-T5, P5-T3, P5-T7 |

## Implementation Plan

### Phase 0 — Baseline Capture (cycle 1)

Ownership: P0-T1 is `(owner: orchestrator)` and completes before the executor starts. P0-T2 onward is executor-owned. All baseline artifacts go to `docs/features/active/2026-10-16-pester-profiler-coverage-953/evidence/remediation-baseline/`.

- [x] [P0-T1] (owner: orchestrator) Guarantee an in-range local Pester and write `docs/features/active/2026-10-16-pester-profiler-coverage-953/evidence/remediation-baseline/r1-local-pester-precondition.<ts>.md`.
  - Steps:
    1. Run `@(Get-Module Pester -ListAvailable | Sort-Object Version -Descending | ForEach-Object { $_.Version.ToString() }) -join ','` and record the result as `PESTER_VERSIONS_BEFORE:`.
    2. Record `PESTER_IN_RANGE_BEFORE:`: the listed versions `v` with `[version]'5.9.0' -le v -and v -le [version]'5.99.99'`, or `NONE`.
    3. If that value is `NONE` (authorized install branch), run `Install-Module -Name Pester -RequiredVersion 5.9.0 -Scope CurrentUser -AllowClobber -Force` (the default install seam command at `scripts/powershell/PoshQC/PoshQC.psm1:25`).
    4. If that command fails and its error text contains the literal `SkipPublisherCheck` (authorized retry branch), rerun it with `-SkipPublisherCheck` appended. Record every command run as `INSTALL_COMMAND:`, and record `INSTALL_PERFORMED: YES|NO`.
    5. Repeat step 1 as `PESTER_VERSIONS_AFTER:` and step 2 as `PESTER_IN_RANGE_AFTER:`.
  - The file also contains `Timestamp:`, `Command:`, `EXIT_CODE:` (of the last command), `Output Summary:`, and `HOST_CHANGE_SCOPE: CurrentUser PowerShell module path (outside the repository)`.
  - Acceptance: `PESTER_IN_RANGE_AFTER` is not `NONE`, and `PESTER_VERSIONS_AFTER` lists at least one version outside the range (the out-of-range versions are the discrimination input of P2-T7). Otherwise stop BLOCKED.
  - The orchestrator commits this file, this plan, and `docs/features/active/2026-10-16-pester-profiler-coverage-953/remediation-inputs.2026-10-16T10-24.md` before starting the executor.
- [x] [P0-T2] Verify the orchestrator precondition in `docs/features/active/2026-10-16-pester-profiler-coverage-953/evidence/remediation-baseline/` and probe the Tool route.
  - Select the lexicographically greatest `r1-local-pester-precondition.*.md`. Confirm that it contains `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:`, and a `PESTER_IN_RANGE_AFTER:` value other than `NONE`.
  - Write `SCRATCH/issue-953-r1-probe.sh` with the Tool-route fixed body: line 1 `export MSYS_NO_PATHCONV=1`; line 2 `pwsh -NoProfile -Command '$S = "<SCRATCH absolute path, forward slashes>"; $PSVersionTable.PSVersion.ToString()'`. Run it from the Bash tool as `sh "<SCRATCH absolute path, forward slashes>/issue-953-r1-probe.sh"`.
  - Acceptance: the artifact check passes, and the probe exits 0 and prints a version. Otherwise record `TOOL_ROUTE: DENIED` or `PRECONDITION: MISSING` in the report and stop BLOCKED.
- [x] [P0-T3] Read the repository-root `CLAUDE.md` (standing instructions, policy reading order) and `.github/copilot-instructions.md` (the tone policy it names as authoritative).
- [x] [P0-T4] Read `.claude/rules/general-code-change.md` (toolchain loop, 500-line limit, error handling).
- [x] [P0-T5] Read `.claude/rules/general-unit-test.md` (coverage defaults and precedence, Coverage Exclusion Policy, no temporary files, determinism).
- [x] [P0-T6] Read `.claude/rules/quality-tiers.md` and confirm from `quality-tiers.yml:13-14` that `scripts/powershell/PoshQC` is tier T3 (no property-test or mutation obligation).
- [x] [P0-T7] Read `.claude/rules/powershell.md` (PoshQC toolchain order, change budget, seams, Pester standards).
- [x] [P0-T8] Read `.claude/rules/python.md` (toolchain for the bundled-parity pytest at `tests/scripts/dev_tools/test_poshqc_bundled_parity.py`).
- [x] [P0-T9] Write `docs/features/active/2026-10-16-pester-profiler-coverage-953/evidence/remediation-baseline/phase0-instructions-read.<ts>.md`.
  - Fields: `Timestamp:`, `Policy Order:` (CLAUDE.md, copilot-instructions, general-code-change, general-unit-test, quality-tiers, powershell, python), and the explicit list of the eight files read in P0-T3 through P0-T8: `CLAUDE.md`, `.github/copilot-instructions.md`, `.claude/rules/general-code-change.md`, `.claude/rules/general-unit-test.md`, `.claude/rules/quality-tiers.md`, `quality-tiers.yml`, `.claude/rules/powershell.md`, `.claude/rules/python.md`.
  - Acceptance: all eight paths are listed in that order.
- [x] [P0-T10] Record the branch state and write `docs/features/active/2026-10-16-pester-profiler-coverage-953/evidence/remediation-baseline/r1-branch-state.<ts>.md`.
  - Run `git fetch origin main`, `git merge-base HEAD origin/main`, `git rev-parse HEAD`, `git branch --show-current`, and `git status --porcelain --untracked-files=all` from the Bash tool.
  - The file contains `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:` (the porcelain output), `REM_BASE_SHA: <40-hex HEAD>`, `BASE_SHA: <40-hex merge base>`, and `BRANCH: bug/pester-profiler-coverage-953`.
  - Acceptance: every command exits 0; the branch value equals `bug/pester-profiler-coverage-953`; and every porcelain line is one of two permitted forms:
    - an untracked path under the feature folder: the line starts with `?? docs/features/active/2026-10-16-pester-profiler-coverage-953/`;
    - a modification of exactly this plan file (checkbox state from P0-T2 through P0-T9): the two-character status is ` M`, `M `, or `MM`, and the path is exactly `docs/features/active/2026-10-16-pester-profiler-coverage-953/remediation-plan.2026-10-16T10-24.md`.
  - Any other porcelain line, including a modification of any other tracked file, fails the acceptance: no other tracked file is modified before the cycle starts. Stop BLOCKED and record the line.
- [x] [P0-T11] Record bundled-copy identity and write `docs/features/active/2026-10-16-pester-profiler-coverage-953/evidence/remediation-baseline/r1-bundle-identity.<ts>.md`.
  - Compute `(Get-FileHash -Algorithm SHA256 -LiteralPath <path>).Hash` for two pairs:
    1. `scripts/powershell/PoshQC/PoshQC.Testing.psm1` and `extensions/drm-copilot/resources/powershell/PoshQC/PoshQC.Testing.psm1`.
    2. `scripts/powershell/PoshQC/PoshQC.psm1` and `extensions/drm-copilot/resources/powershell/PoshQC/PoshQC.psm1`.
  - The file contains `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:`, `PAIR_1_EQUAL: YES|NO`, and `PAIR_2_EQUAL: YES|NO`.
  - Acceptance: both pairs record `YES`. If either records `NO`, stop BLOCKED: an Edit-tool repair of a bundled copy is prohibited ("Never edit a bundled copy").
- [x] [P0-T12] Record baseline line counts and write `docs/features/active/2026-10-16-pester-profiler-coverage-953/evidence/remediation-baseline/r1-line-counts.<ts>.md`.
  - Run `(Get-Content -LiteralPath <path>).Count` for `scripts/powershell/PoshQC/PoshQC.Testing.psm1`, `scripts/powershell/PoshQC/PoshQC.psm1`, `tests/scripts/powershell/PoshQC/PoshQC.RunSettings.Tests.ps1`, and `tests/scripts/powershell/PoshQC/PoshQC.TestingSeamDefaults.Tests.ps1`.
  - The file contains `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:`, and one line `LINES: <path> <count>` per file.
  - Acceptance: `PoshQC.Testing.psm1` is 461, `PoshQC.RunSettings.Tests.ps1` is 163, `PoshQC.TestingSeamDefaults.Tests.ps1` is 122, and `PoshQC.psm1` records an integer (`PSM1_BASELINE_LINES`). If any of the three fixed counts differs, the planning-time line citations no longer hold: stop BLOCKED.
- [x] [P0-T13] Capture the bundled-parity baseline with `poetry run pytest tests/scripts/dev_tools/test_poshqc_bundled_parity.py -q` and write `docs/features/active/2026-10-16-pester-profiler-coverage-953/evidence/remediation-baseline/r1-parity-pytest.<ts>.md`.
  - Fields: `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:` quoting the summary line. The Output Summary also states that Python coverage is not measured because no Python file is in scope.
  - Acceptance: EXIT_CODE 0 and the summary line contains `1 passed`.
- [x] [P0-T14] Capture the PoshQC format baseline (write-mode tool) and write `docs/features/active/2026-10-16-pester-profiler-coverage-953/evidence/remediation-baseline/r1-poshqc-format.<ts>.md`.
  - Record `$before = git status --porcelain`. Run `pwsh -NoProfile -Command "Import-Module ./scripts/powershell/PoshQC/PoshQC.psd1 -Force; Invoke-PoshQCFormat -Root (Get-Location).Path" *> (Join-Path $S 'issue-953-r1-baseline-format.log')`, record `$LASTEXITCODE`, then record `$after = git status --porcelain`.
  - The Output Summary states the count of log lines that start with `Formatted: ` (case-sensitive; `scripts/powershell/PoshQC/PoshQC.Analyzer.psm1:62`) and whether `$before` equals `$after`. A file that needs no change logs `Already formatted:` instead (`:64`).
  - Acceptance: EXIT_CODE 0, zero `Formatted: ` lines, and `$before` equal to `$after`. If any file was reformatted, record its path as `PRE_EXISTING_FORMAT_DRIFT:`, restore it with `git restore --source=HEAD --worktree -- <path>`, and stop BLOCKED.
- [x] [P0-T15] Capture the PoshQC analyze baseline with `pwsh -NoProfile -Command "Import-Module ./scripts/powershell/PoshQC/PoshQC.psd1 -Force; Invoke-PoshQCAnalyze -Root (Get-Location).Path" *> (Join-Path $S 'issue-953-r1-baseline-analyze.log')` and write `docs/features/active/2026-10-16-pester-profiler-coverage-953/evidence/remediation-baseline/r1-poshqc-analyze.<ts>.md`.
  - Fields: `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:`.
  - Acceptance: EXIT_CODE 0 and the log contains the literal `PSScriptAnalyzer passed: no findings under` (`scripts/powershell/PoshQC/PoshQC.Analyzer.psm1:185`). On a non-zero exit, record the findings and stop BLOCKED.
- [x] [P0-T16] Capture the targeted baseline by running TARGETED_RUN(`baseline-targeted`, R1_SET) and write `docs/features/active/2026-10-16-pester-profiler-coverage-953/evidence/remediation-baseline/r1-targeted-tests.<ts>.md`.
  - Fields: `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:` (the JRP totals `tests`, `failures`, and `errors`, and the JRP token check for RS01-RS07, every MC token, every INST token, and every SEAM token), and `R1_TARGETED_BASELINE_TESTS: <JRP tests>`.
  - Acceptance: run valid, EXIT_CODE 0, `failures` 0, `errors` 0, and every listed token PASS. This is the behavior baseline for CR-3.
- [x] [P0-T17] Capture the full Pester baseline with coverage by running FULL_RUN(baseline) and write `docs/features/active/2026-10-16-pester-profiler-coverage-953/evidence/remediation-baseline/r1-poshqc-test-coverage.<ts>.md`.
  - Fields: `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:`, and `R1_BASELINE_JUNIT_TESTS: <JRP tests>`.
  - The Output Summary contains:
    - The JRP totals (`JUNIT_TESTS`, `JUNIT_FAILURES`, `JUNIT_ERRORS`) and the FULL_RUN wall seconds.
    - The CRP values `LINE_COVERED`, `LINE_MISSED`, `LINE_TOTAL`, `LINE_PERCENT`, and `SOURCEFILE_COUNT`.
    - The per-file `covered` and `missed` values for the keys `scripts/powershell/poshqc/poshqc.psm1` and `scripts/powershell/poshqc/poshqc.testing.psm1`.
    - `L('scripts/powershell/poshqc/poshqc.psm1', nr)` for `nr` in {62, 75, 76}.
    - `L('scripts/powershell/poshqc/poshqc.testing.psm1', nr)` for `nr` in {165, 169, 306}. These are the pre-cycle line numbers of the lines this cycle changes.
  - Acceptance: FULL_RUN valid, EXIT_CODE 0, `JUNIT_FAILURES` 0, `JUNIT_ERRORS` 0, and every CRP value numeric. If a test fails, record the failed `classname` and `name` values as `PRE_EXISTING_FAILURES:` and stop BLOCKED.

### Phase 1 — Regression Tests for CR-1 and CR-2 (must fail first)

- [x] [P1-T1] Edit `tests/scripts/powershell/PoshQC/PoshQC.RunSettings.Tests.ps1` with the Edit tool.
  - Insert the two lines below immediately after line 130 (`            Mock -CommandName Import-Module -MockWith { }`, inside RS06), at the same 12-space indentation.
  - No other line changes. RS06's assertion is unchanged; the mock makes the case independent of the host's installed Pester (see "Assumptions and Advisories", Test determinism).
  - Acceptance: `RS06-TEST-IMPORT-PESTER-MAXIMUM` occurs once in the file, and the file contains `Version = [version]'5.9.5'` (quoted here as the literal this task creates).

```powershell
            # Report a supported Pester so the result does not depend on the modules installed on the host (issue #953, CR-1).
            Mock -CommandName Get-Module -MockWith { [pscustomobject]@{ Name = 'Pester'; Version = [version]'5.9.5' } }
```

- [x] [P1-T2] Edit `tests/scripts/powershell/PoshQC/PoshQC.RunSettings.Tests.ps1` with the Edit tool: append the 68 lines below after the current last line (the closing `}` of the `PoshQC Linux hook job Pester import` Describe block), starting with one blank line and ending with one final newline.
  - The block reads no file, writes no file, installs no module, and mocks `Get-Module` and `Import-Module` only inside `InModuleScope PoshQC`. It follows the precedent of RS06 and `tests/scripts/powershell/PoshQC/PoshQC.TestingSeamDefaults.Tests.ps1:90-99`.
  - The unfiltered `Get-Module` mock models the pre-fix query (`-ListAvailable -Name`). The `-ParameterFilter { $null -ne $FullyQualifiedName }` mock models the range-qualified query by applying the requested bounds to the same version list.
  - How each case fails on the pre-fix tree:
    - RS08: the import carries no `-MinimumVersion`, so the `Import-Module` `Should -Invoke` filter matches 0 calls.
    - RS09 and RS10: the unqualified query returns the out-of-range module, so the seam imports and the run stops at `Settings not found` instead of the install message.
  - Acceptance: each of `RS08-TEST-IMPORT-PESTER-RANGE-BOUNDS`, `RS09-TEST-PESTER-6-ONLY-ACTIONABLE-ERROR`, and `RS10-TEST-PESTER-INBOX-ONLY-ACTIONABLE-ERROR` occurs exactly once in the file (counted with `Select-String -SimpleMatch` through the Tool route).

```powershell

Describe 'Invoke-PoshQCTest Pester presence check and import range (issue #953, CR-1, CR-2)' {
    It 'RS08-TEST-IMPORT-PESTER-RANGE-BOUNDS queries and imports Pester with minimum 5.9.0 and maximum 5.99.99' {
        InModuleScope PoshQC {
            # Arrange: one installed Pester is below, one inside, and one above the supported range. The
            # unqualified lookup returns all three; the range-qualified lookup applies the requested bounds.
            Mock -CommandName Get-Module -MockWith {
                foreach ($version in '3.4.0', '5.9.5', '6.0.0') { [pscustomobject]@{ Name = 'Pester'; Version = [version]$version } }
            }
            Mock -CommandName Get-Module -ParameterFilter { $null -ne $FullyQualifiedName } -MockWith {
                $range = $FullyQualifiedName[0]
                foreach ($version in '3.4.0', '5.9.5', '6.0.0') {
                    if ([version]$version -ge $range.Version -and [version]$version -le [version]$range.MaximumVersion) {
                        [pscustomobject]@{ Name = 'Pester'; Version = [version]$version }
                    }
                }
            }
            Mock -CommandName Import-Module -MockWith { }

            # Act: a nonexistent settings path stops the run right after the seam.
            { Invoke-PoshQCTest -Root '/rs08-root' -SettingsPath '/rs08-missing-settings.psd1' } | Should -Throw '*Settings not found*'

            # Assert: the import carries both bounds, and the presence query carries the same range.
            Should -Invoke -CommandName Import-Module -Times 1 -Exactly -ParameterFilter {
                $Name -eq 'Pester' -and $Global -eq $true -and $MinimumVersion -eq [version]'5.9.0' -and $MaximumVersion -eq '5.99.99'
            }
            Should -Invoke -CommandName Get-Module -Times 1 -Exactly -ParameterFilter {
                $ListAvailable -and $null -ne $FullyQualifiedName -and $FullyQualifiedName[0].Name -eq 'Pester' -and $FullyQualifiedName[0].Version -eq [version]'5.9.0' -and $FullyQualifiedName[0].MaximumVersion -eq '5.99.99'
            }
        }
    }

    It 'RS09-TEST-PESTER-6-ONLY-ACTIONABLE-ERROR throws the install message without importing when only Pester 6.0.0 is installed' {
        InModuleScope PoshQC {
            # Arrange: the only installed Pester is above the ceiling, so the range-qualified lookup returns nothing.
            Mock -CommandName Get-Module -MockWith { [pscustomobject]@{ Name = 'Pester'; Version = [version]'6.0.0' } }
            Mock -CommandName Get-Module -ParameterFilter { $null -ne $FullyQualifiedName } -MockWith {
                $range = $FullyQualifiedName[0]
                if ([version]'6.0.0' -ge $range.Version -and [version]'6.0.0' -le [version]$range.MaximumVersion) {
                    [pscustomobject]@{ Name = 'Pester'; Version = [version]'6.0.0' }
                }
            }
            Mock -CommandName Import-Module -MockWith { }

            # Act / Assert
            { Invoke-PoshQCTest -Root '/rs09-root' -SettingsPath '/rs09-missing-settings.psd1' } | Should -Throw '*Run Install-PoshQCTool*'
            Should -Invoke -CommandName Import-Module -Times 0 -Exactly
        }
    }

    It 'RS10-TEST-PESTER-INBOX-ONLY-ACTIONABLE-ERROR throws the install message without importing when only Pester 3.4.0 is installed' {
        InModuleScope PoshQC {
            # Arrange: the only installed Pester is the inbox 3.4.0 below the minimum, so the range-qualified lookup returns nothing.
            Mock -CommandName Get-Module -MockWith { [pscustomobject]@{ Name = 'Pester'; Version = [version]'3.4.0' } }
            Mock -CommandName Get-Module -ParameterFilter { $null -ne $FullyQualifiedName } -MockWith {
                $range = $FullyQualifiedName[0]
                if ([version]'3.4.0' -ge $range.Version -and [version]'3.4.0' -le [version]$range.MaximumVersion) {
                    [pscustomobject]@{ Name = 'Pester'; Version = [version]'3.4.0' }
                }
            }
            Mock -CommandName Import-Module -MockWith { }

            # Act / Assert
            { Invoke-PoshQCTest -Root '/rs10-root' -SettingsPath '/rs10-missing-settings.psd1' } | Should -Throw '*Run Install-PoshQCTool*'
            Should -Invoke -CommandName Import-Module -Times 0 -Exactly
        }
    }
}
```

- [x] [P1-T3] Edit `tests/scripts/powershell/PoshQC/PoshQC.TestingSeamDefaults.Tests.ps1` with the Edit tool.
  - Insert the two lines below immediately after line 78 (`            Mock -CommandName Import-Module -MockWith { }`, inside the case `imports the requested module with -Global`), at the same 12-space indentation.
  - No other line changes; the assertion at lines 84-86 is unchanged.
  - Acceptance: the file contains `Version = [version]'5.9.5'` exactly once.

```powershell
            # Report a supported Pester so the result does not depend on the modules installed on the host (issue #953, CR-1).
            Mock -CommandName Get-Module -MockWith { [pscustomobject]@{ Name = 'Pester'; Version = [version]'5.9.5' } }
```

- [x] [P1-T4] Verify the test edits for `tests/scripts/powershell/PoshQC/PoshQC.RunSettings.Tests.ps1` and `tests/scripts/powershell/PoshQC/PoshQC.TestingSeamDefaults.Tests.ps1`.
  - Run `git diff --numstat <REM_BASE_SHA> -- tests/scripts/powershell/PoshQC/PoshQC.RunSettings.Tests.ps1 tests/scripts/powershell/PoshQC/PoshQC.TestingSeamDefaults.Tests.ps1` from the Bash tool, and `(Get-Content -LiteralPath <path>).Count` for each file through the Tool route.
  - Write `docs/features/active/2026-10-16-pester-profiler-coverage-953/evidence/other/r1-test-edits.<ts>.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:` (both numstat rows and both counts).
  - Acceptance:
    - The RunSettings row reads `70` added and `0` deleted, and the TestingSeamDefaults row reads `2` added and `0` deleted.
    - The line counts are 233 and 124 (both at most 500, AC-15).
- [x] [P1-T5] [expect-fail] Run TARGETED_RUN(`cr-before`, `tests/scripts/powershell/PoshQC/PoshQC.RunSettings.Tests.ps1`) on the pre-fix production tree and write `docs/features/active/2026-10-16-pester-profiler-coverage-953/evidence/regression-testing/r1-cr-regression-fail-before.<ts>.md`.
  - Fields: `Timestamp:`, `Command:`, `EXIT_CODE:`, `ExpectedExitCode: 3`, and `Output Summary:` with the JRP totals, the JRP token check (step 4) for RS01-RS07, and the JRP failure check (step 5) with the failure message for RS08, RS09, and RS10.
  - Acceptance:
    - Run valid, EXIT_CODE 3 (Pester exits with the failed-test count when `Run.Exit` is set), JRP `tests` 10, `failures` 3, and `errors` 0.
    - RS01-RS07 token checks PASS, and RS08-RS10 failure checks PASS.
    - The RS08 failure message contains `but was called 0 times` (the import lacked `-MinimumVersion`; the same message form is recorded for RS06 in `docs/features/active/2026-10-16-pester-profiler-coverage-953/evidence/regression-testing/runsettings-regression-fail-before.2026-10-16T08-15.md:22`).
    - The RS09 and RS10 failure messages each contain `Settings not found`, which proves that the presence check accepted the out-of-range version.
  - If any condition fails, stop and report; do not start Phase 2.

### Phase 2 — CR-1 and CR-2 Fix in the Default EnsureModule Seam

- [x] [P2-T1] Edit `scripts/powershell/PoshQC/PoshQC.Testing.psm1` with the Edit tool: replace the default `$EnsureModule` value at lines 163-170 (from `        [scriptblock] $EnsureModule = {` through its closing `        },`) with the ten lines below. No other line changes in this task.
  - Counted coverage lines stay at two: the presence `if` line and the import line. Every other changed or inserted line is a `param` or comment line.
  - Acceptance: the file contains `-FullyQualifiedName @{ ModuleName = $Name; ModuleVersion = $MinimumVersion; MaximumVersion = $MaximumVersion }` and `-MinimumVersion $MinimumVersion -MaximumVersion $MaximumVersion` (quoted here as literals this task creates), each once.

```powershell
        [scriptblock] $EnsureModule = {
            param([string] $Name, [string] $ErrorMessage, [string] $MinimumVersion, [string] $MaximumVersion)
            # Issue #953 (CR-1): only an installed version inside the supported range counts as present, so a host
            # whose only Pester is 6.x or the inbox 3.4.0 receives the actionable message instead of an import error.
            if (-not (Get-Module -ListAvailable -FullyQualifiedName @{ ModuleName = $Name; ModuleVersion = $MinimumVersion; MaximumVersion = $MaximumVersion })) { throw $ErrorMessage }
            # Import globally so Pester's Describe/It/Mock resolve in test containers that the
            # default $InvokePester trampoline now hosts in the global session state (issue #392).
            # Issue #953 (D8, CR-2): -MinimumVersion and -MaximumVersion keep the import inside the supported range.
            Import-Module $Name -Global -MinimumVersion $MinimumVersion -MaximumVersion $MaximumVersion -ErrorAction Stop
        },
```

- [x] [P2-T2] Edit `scripts/powershell/PoshQC/PoshQC.Testing.psm1` with the Edit tool: replace the call line (line 306 before P2-T1, line 308 after it), `    & $EnsureModule 'Pester' "Pester is not installed. Run Install-PoshQCTool (alias Install-PoshQCTools) first." '5.99.99'`, with the single line below. No other line changes.
  - Acceptance: the file contains `'5.9.0' '5.99.99'` (quoted here as the literal this task creates) exactly once.

```powershell
    & $EnsureModule 'Pester' "Pester is not installed in the supported range (5.9.0 to 5.99.99). Run Install-PoshQCTool (alias Install-PoshQCTools) first." '5.9.0' '5.99.99'
```

- [x] [P2-T3] Verify the `scripts/powershell/PoshQC/PoshQC.Testing.psm1` edit.
  - Run `git diff --numstat <REM_BASE_SHA> -- scripts/powershell/PoshQC/PoshQC.Testing.psm1` from the Bash tool.
  - Through the Tool route, run `(Get-Content -LiteralPath scripts/powershell/PoshQC/PoshQC.Testing.psm1).Count` and `@(Select-String -LiteralPath scripts/powershell/PoshQC/PoshQC.Testing.psm1 -SimpleMatch -Pattern '<token>').Count` for each CEIL_R1 token of the `PoshQC.Testing.psm1` row.
  - Write `docs/features/active/2026-10-16-pester-profiler-coverage-953/evidence/other/r1-testing-psm1-edit.<ts>.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:`.
  - Acceptance: the numstat row reads `7` added and `5` deleted; the line count is 463; and every CEIL_R1 count for that file equals its expected value.
- [x] [P2-T4] Mirror the file through the Tool route with `Copy-Item -LiteralPath scripts/powershell/PoshQC/PoshQC.Testing.psm1 -Destination extensions/drm-copilot/resources/powershell/PoshQC/PoshQC.Testing.psm1 -Force`, then print `(Get-FileHash -Algorithm SHA256 -LiteralPath scripts/powershell/PoshQC/PoshQC.Testing.psm1).Hash -eq (Get-FileHash -Algorithm SHA256 -LiteralPath extensions/drm-copilot/resources/powershell/PoshQC/PoshQC.Testing.psm1).Hash`.
  - Acceptance: the printed value is `True`.
- [x] [P2-T5] Run TARGETED_RUN(`cr-after`, `tests/scripts/powershell/PoshQC/PoshQC.RunSettings.Tests.ps1`) and write `docs/features/active/2026-10-16-pester-profiler-coverage-953/evidence/regression-testing/r1-cr-regression-pass-after.<ts>.md`.
  - Fields: `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:` with the JRP totals and the JRP token check for RS01-RS10.
  - Acceptance: run valid, EXIT_CODE 0, `tests` 10, `failures` 0, `errors` 0, and all ten RS tokens PASS.
- [x] [P2-T6] Run TARGETED_RUN(`seam-after`, R1_SET) and write `docs/features/active/2026-10-16-pester-profiler-coverage-953/evidence/qa-gates/r1-seam-consumers-after.<ts>.md`.
  - Fields: `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:` with the JRP totals and the token check for every RS, SEAM, and INST token.
  - Acceptance:
    - Run valid, EXIT_CODE 0, `failures` 0, and `errors` 0.
    - JRP `tests` equals `R1_TARGETED_BASELINE_TESTS` (latest `r1-targeted-tests.*.md` in `docs/features/active/2026-10-16-pester-profiler-coverage-953/evidence/remediation-baseline/`) plus 3.
    - Every listed token PASS. This confirms that the 9 `Get-Module` mocks of `tests/scripts/powershell/PoshQC/PoshQC.Comprehensive.Tests.ps1` still pass unedited.
- [x] [P2-T7] Verify on the local host the real range query that `scripts/powershell/PoshQC/PoshQC.Testing.psm1` line 167 now issues. Through the Tool route, print one line built from:
  - `RANGE=` followed by `(@(Get-Module -ListAvailable -FullyQualifiedName @{ ModuleName = 'Pester'; ModuleVersion = '5.9.0'; MaximumVersion = '5.99.99' } | ForEach-Object { $_.Version.ToString() }) -join ',')`.
  - ` ALL=` followed by `(@(Get-Module -ListAvailable -Name Pester | ForEach-Object { $_.Version.ToString() }) -join ',')`.

  Write `docs/features/active/2026-10-16-pester-profiler-coverage-953/evidence/other/r1-host-pester-range-query.<ts>.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:` (the printed line, and the `ALL` versions outside the range).

  Acceptance:
  - `RANGE` is non-empty, and every `RANGE` version `v` satisfies `[version]'5.9.0' -le v -and v -le [version]'5.99.99'`.
  - `ALL` contains at least one version outside that range, and no such version appears in `RANGE`.

  This is the host-side evidence that the CR-1 query excludes out-of-range versions such as the inbox 3.4.0.

### Phase 3 — CR-3 Single Version-Range Predicate in Install-PoshQCTool

No test runs between P3-T1 and P3-T5 (Task-ordering rule).

- [x] [P3-T1] Edit `scripts/powershell/PoshQC/PoshQC.psm1` with the Edit tool: replace lines 61-62 (the `foreach ($module in $requiredModules) {` line and the `$installed = & $FindModule ...` line that follows it) with the six lines below. No other line changes in this task; line 60 (blank) stays in place.
  - Acceptance: the file contains `$isSupportedVersion = {` (quoted here as the literal this task creates) exactly once.

```powershell
    # Issue #953 (CR-3): one version-range predicate serves the present check and the post-install check.
    # Where-Object runs it in this function's scope, so $module is the requirement of the current iteration.
    $isSupportedVersion = { $_.Version -ge [version]$module.Version -and (-not $module.ContainsKey('UpperBound') -or $_.Version -lt [version]$module.UpperBound) }

    foreach ($module in $requiredModules) {
        $installed = & $FindModule $module.Name | Where-Object -FilterScript $isSupportedVersion | Select-Object -First 1
```

- [x] [P3-T2] Edit `scripts/powershell/PoshQC/PoshQC.psm1` with the Edit tool: replace the two lines `        $post = & $FindModule $module.Name | Where-Object { $_.Version -ge [version]$module.Version -and (-not $module.ContainsKey('UpperBound') -or $_.Version -lt [version]$module.UpperBound) } | Select-Object -First 1` and `        if (-not $post) {` (lines 75-76 before P3-T1, lines 79-80 after it) with the single line below. The `throw` line and the closing brace that follow are unchanged.
  - Acceptance: the file contains no `$post` (`@(Select-String -LiteralPath scripts/powershell/PoshQC/PoshQC.psm1 -SimpleMatch -Pattern '$post').Count` is 0, with the token in single quotes).

```powershell
        if (-not (& $FindModule $module.Name | Where-Object -FilterScript $isSupportedVersion | Select-Object -First 1)) {
```

- [x] [P3-T3] Verify the `scripts/powershell/PoshQC/PoshQC.psm1` edit.
  - Run `git diff --numstat <REM_BASE_SHA> -- scripts/powershell/PoshQC/PoshQC.psm1` from the Bash tool.
  - Through the Tool route, run `(Get-Content -LiteralPath scripts/powershell/PoshQC/PoshQC.psm1).Count` and the CEIL_R1 counts of the `PoshQC.psm1` row.
  - Write `docs/features/active/2026-10-16-pester-profiler-coverage-953/evidence/other/r1-psm1-edit.<ts>.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:`.
  - Acceptance: the numstat row reads `6` added and `3` deleted; the line count equals `PSM1_BASELINE_LINES` (from the latest `r1-line-counts.*.md` in `docs/features/active/2026-10-16-pester-profiler-coverage-953/evidence/remediation-baseline/`) plus 3; and every CEIL_R1 count for that file equals its expected value.
- [x] [P3-T4] Mirror the file through the Tool route with `Copy-Item -LiteralPath scripts/powershell/PoshQC/PoshQC.psm1 -Destination extensions/drm-copilot/resources/powershell/PoshQC/PoshQC.psm1 -Force`, then print `(Get-FileHash -Algorithm SHA256 -LiteralPath scripts/powershell/PoshQC/PoshQC.psm1).Hash -eq (Get-FileHash -Algorithm SHA256 -LiteralPath extensions/drm-copilot/resources/powershell/PoshQC/PoshQC.psm1).Hash`.
  - Acceptance: the printed value is `True`.
- [x] [P3-T5] Prove CR-3 leaves behavior unchanged. Run TARGETED_RUN(`cr3-after`, R1_SET) and write `docs/features/active/2026-10-16-pester-profiler-coverage-953/evidence/qa-gates/r1-cr3-installer-tests-after.<ts>.md`.
  - Fields: `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:` with the JRP totals and the token check for every RS, MC, INST, and SEAM token.
  - Acceptance:
    - Run valid, EXIT_CODE 0, `failures` 0, and `errors` 0.
    - JRP `tests` equals `R1_TARGETED_BASELINE_TESTS` plus 3.
    - RS03, RS05, MC01-MC05, and every INST token PASS (the same cases that passed in P0-T16 before the refactor), as do all other listed tokens.
- [x] [P3-T6] Run `poetry run pytest tests/scripts/dev_tools/test_poshqc_bundled_parity.py -q` and write `docs/features/active/2026-10-16-pester-profiler-coverage-953/evidence/other/r1-parity-after-mirror.<ts>.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:` quoting the summary line.
  - Acceptance: EXIT_CODE 0 and the summary line contains `1 passed`.

### Phase 4 — CHANGELOG Accuracy

- [x] [P4-T1] Edit `extensions/drm-copilot/CHANGELOG.md` with the Edit tool: replace line 26 (``  installed Pester 6.x, and `Invoke-PoshQCTest` imports Pester with `-MaximumVersion 5.99.99`.``) with the three lines below. No other line changes; lines 20-25 and the `## [0.0.1] - 2026-05-02` section are unchanged.
  - Acceptance: `git diff --numstat <REM_BASE_SHA> -- extensions/drm-copilot/CHANGELOG.md` reports `3` added and `1` deleted.

```markdown
  installed Pester 6.x, and `Invoke-PoshQCTest` imports Pester with `-MinimumVersion 5.9.0`
  and `-MaximumVersion 5.99.99`. When no installed Pester is in that range, `Invoke-PoshQCTest`
  stops with a message to run `Install-PoshQCTool` instead of loading another version.
```

### Phase 5 — Final QC Loop

Restart rule: if any task from P5-T1 through P5-T11 fails or changes a tracked file, the executor fixes the cause and restarts at P5-T1, writing new evidence files. All QC artifacts go to `docs/features/active/2026-10-16-pester-profiler-coverage-953/evidence/qa-gates/`.

- [x] [P5-T1] Run the PoshQC formatter (write-mode tool) and write `docs/features/active/2026-10-16-pester-profiler-coverage-953/evidence/qa-gates/r1-final-poshqc-format.<ts>.md`.
  - Before the formatter runs, compute the SHA256 of every CYCLE_FILES path and record `$before = git status --porcelain`.
  - Run `pwsh -NoProfile -Command "Import-Module ./scripts/powershell/PoshQC/PoshQC.psd1 -Force; Invoke-PoshQCFormat -Root (Get-Location).Path" *> (Join-Path $S 'issue-953-r1-final-format.log')`, record `$LASTEXITCODE`, then record `$after = git status --porcelain`.
  - Fields: `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:` (the count of log lines starting with `Formatted: `, the count starting with `Already formatted:`, and whether `$before` equals `$after`), and one `HASH_BEFORE: <path> <SHA256>` line per CYCLE_FILES path.
  - Acceptance: EXIT_CODE 0, zero `Formatted: ` lines, and `$before` equal to `$after` (AC-07: no diff).
- [x] [P5-T2] Run `pwsh -NoProfile -Command "Import-Module ./scripts/powershell/PoshQC/PoshQC.psd1 -Force; Invoke-PoshQCAnalyze -Root (Get-Location).Path" *> (Join-Path $S 'issue-953-r1-final-analyze.log')` and write `docs/features/active/2026-10-16-pester-profiler-coverage-953/evidence/qa-gates/r1-final-poshqc-analyze.<ts>.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:`.
  - Acceptance: EXIT_CODE 0 and the log contains the literal `PSScriptAnalyzer passed: no findings under` (AC-07: zero findings).
- [x] [P5-T3] Run FULL_RUN(final) and write `docs/features/active/2026-10-16-pester-profiler-coverage-953/evidence/qa-gates/r1-final-poshqc-test-coverage.<ts>.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:`.
  - The Output Summary contains:
    - The JRP totals, and the JRP token check for every RS, MC, INST, and SEAM token.
    - The FULL_RUN wall seconds.
    - The CRP values `LINE_COVERED`, `LINE_MISSED`, `LINE_TOTAL`, `LINE_PERCENT`, and `SOURCEFILE_COUNT`.
  - The outer `Invoke-PoshQCTest` call of FULL_RUN runs the fixed default seam against the real host modules, so a valid run also shows that the CR-1 query and the CR-2 import accept the in-range Pester recorded by P0-T1.
  - Acceptance:
    - FULL_RUN valid, EXIT_CODE 0, `JUNIT_FAILURES` 0, and `JUNIT_ERRORS` 0 (AC-07: zero failed tests).
    - Every listed token PASS.
    - JRP `tests` equals `R1_BASELINE_JUNIT_TESTS` (latest `r1-poshqc-test-coverage.*.md` in `docs/features/active/2026-10-16-pester-profiler-coverage-953/evidence/remediation-baseline/`) plus 3.
- [x] [P5-T4] Compute the coverage delta from `issue-953-r1-baseline-coverage.xml` and `issue-953-r1-final-coverage.xml` under SCRATCH with CRP, and write `docs/features/active/2026-10-16-pester-profiler-coverage-953/evidence/qa-gates/r1-final-coverage-delta.<ts>.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:`.
  - The Output Summary contains:
    - Baseline and final `LINE_COVERED`, `LINE_TOTAL`, and `LINE_PERCENT`.
    - Baseline and final per-file `covered` and `missed` for the keys `scripts/powershell/poshqc/poshqc.psm1` and `scripts/powershell/poshqc/poshqc.testing.psm1`.
    - From the final file, `L('scripts/powershell/poshqc/poshqc.psm1', nr)` for `nr` in {63, 66, 79} and `L('scripts/powershell/poshqc/poshqc.testing.psm1', nr)` for `nr` in {167, 171, 308}. These are the post-cycle line numbers of every changed counted line.
  - Acceptance:
    - Baseline `LINE_TOTAL` equals final `LINE_TOTAL`, and for each of the two keys the baseline per-file total (`covered + missed`) equals the final per-file total. These checks guard the AC-08 denominator; if either differs, stop and report.
    - The final CRP threshold (step 7) PASSES (repository-wide at least 85%).
    - For each of the two keys, the final per-file values satisfy `100 * covered -ge 85 * (covered + missed)`.
    - Each of the six listed lines is present with `ci` greater than 0 (every changed line covered).
  - The Output Summary states that the bundled copies are outside the coverage roots of `config/poshqc-coverage.json:3-9` and are not measured.
- [x] [P5-T5] Run `poetry run pytest tests/scripts/dev_tools/test_poshqc_bundled_parity.py -q` and write `docs/features/active/2026-10-16-pester-profiler-coverage-953/evidence/qa-gates/r1-final-parity-pytest.<ts>.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:` quoting the summary line.
  - Acceptance: EXIT_CODE 0 and the summary line contains `1 passed` (AC-02).
- [x] [P5-T6] Verify file sizes (AC-15) and write `docs/features/active/2026-10-16-pester-profiler-coverage-953/evidence/qa-gates/r1-final-file-size.<ts>.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:` listing each path and its line count.
  - Build the changed-file set as the union of the paths from `git diff --name-only origin/main...HEAD` and from `git status --porcelain --untracked-files=all` (both from the Bash tool).
  - Keep only paths for which `Test-Path -LiteralPath <path> -PathType Leaf` is true, drop paths ending in `.md`, and record `(Get-Content -LiteralPath <path>).Count` for each remaining path.
  - Acceptance:
    - Every count is at most 500.
    - The set includes `scripts/powershell/PoshQC/PoshQC.Testing.psm1` (463), `scripts/powershell/PoshQC/PoshQC.psm1` (`PSM1_BASELINE_LINES` plus 3), `tests/scripts/powershell/PoshQC/PoshQC.RunSettings.Tests.ps1` (233), and `tests/scripts/powershell/PoshQC/PoshQC.TestingSeamDefaults.Tests.ps1` (124).
    - The set does not include `tests/scripts/powershell/PoshQC/PoshQC.Comprehensive.Tests.ps1`.
- [x] [P5-T7] Run the ceiling and pin sweep (AC-04, AC-16): for every CEIL_R1 row and file, run `@(Select-String -LiteralPath <path> -SimpleMatch -Pattern '<token>').Count` through the Tool route, and write `docs/features/active/2026-10-16-pester-profiler-coverage-953/evidence/qa-gates/r1-final-ceiling-sweep.<ts>.md`.
  - Fields: `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:` with one `CEIL: <path> | <token> | <count>` line per row and file.
  - Acceptance:
    - Every count equals its CEIL_R1 expected value.
    - P5-T3 recorded `RS03-INSTALLER-PESTER-590`, `RS05-INSTALLER-PESTER-CEILING-BELOW-6`, `RS06-TEST-IMPORT-PESTER-MAXIMUM`, and `RS07-WORKFLOW-LINUX-PESTER-RANGE` as PASS.
- [x] [P5-T8] Verify the CHANGELOG (AC-06) and write `docs/features/active/2026-10-16-pester-profiler-coverage-953/evidence/qa-gates/r1-final-changelog.<ts>.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:` with the four counts.
  - Read `extensions/drm-copilot/CHANGELOG.md`. Take the lines strictly between the line `## [Unreleased]` and the next line that starts with `## [`.
  - Count the lines containing `profiler-based`, `Pester 5.9.0`, `below Pester 6.0`, and `-MinimumVersion 5.9.0`.
  - Acceptance: each of the four counts is at least 1.
- [x] [P5-T9] Verify AC-13 and write `docs/features/active/2026-10-16-pester-profiler-coverage-953/evidence/qa-gates/r1-final-scope-ac13.<ts>.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:`.
  - Run `git diff --name-only origin/main...HEAD` and `git status --porcelain`.
  - With `$mb = git merge-base origin/main HEAD`, for every file in `Get-ChildItem .github/workflows -Filter *.yml`, extract the `on:` block (from the line matching `^on:` through the line before the next line matching `^\S`) from the worktree file and from `git show "${mb}:.github/workflows/<name>"`, and compare the two.
  - Acceptance: neither listing contains `.github/workflows/ci.yml`, and every `on:` block is identical to the merge-base text.
- [x] [P5-T10] Verify AC-14: run `git diff --name-only origin/main...HEAD` and `git status --porcelain`, and write `docs/features/active/2026-10-16-pester-profiler-coverage-953/evidence/qa-gates/r1-final-scope-ac14.<ts>.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:`.
  - Acceptance: neither listing contains a path starting with `.claude/rules/` or `.github/instructions/`.
- [x] [P5-T11] Verify the cycle blast radius and write `docs/features/active/2026-10-16-pester-profiler-coverage-953/evidence/qa-gates/r1-final-blast-radius.<ts>.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:`, `PYTHON_FILES_CHANGED_THIS_CYCLE: NONE`, `SHELL_FILES_CHANGED_THIS_CYCLE: NONE`, and `WORKFLOW_FILES_CHANGED_THIS_CYCLE: NONE`.
  - Build the set as the union of the paths from `git diff --name-only <REM_BASE_SHA>` (`REM_BASE_SHA` against the working tree, covering committed and uncommitted tracked changes) and from `git status --porcelain --untracked-files=all` (covering untracked files), both run from the Bash tool.
  - Acceptance: every path in the set is one of these:
    - A CYCLE_FILES path.
    - `docs/features/active/2026-10-16-pester-profiler-coverage-953/remediation-plan.2026-10-16T10-24.md` (this plan; it appears in both listings as a modified tracked file because the executor ticks its checkboxes, and that modification is permitted).
    - `docs/features/active/2026-10-16-pester-profiler-coverage-953/remediation-inputs.2026-10-16T10-24.md`.
    - A path under `docs/features/active/2026-10-16-pester-profiler-coverage-953/evidence/`.
  - Acceptance also requires that no path in the set ends in `.py`, `.sh`, `.yml`, or `.json`. The Python, shell, and workflow toolchains are therefore not applicable to this cycle, and the three `NONE` lines record that.
- [x] [P5-T12] Record loop closure and write `docs/features/active/2026-10-16-pester-profiler-coverage-953/evidence/qa-gates/r1-final-loop-closure.<ts>.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:`, and `LOOP_CLEAN_PASS: YES|NO`.
  - Recompute the SHA256 of every CYCLE_FILES path and compare each with the `HASH_BEFORE:` lines of the latest `r1-final-poshqc-format.*.md` in `docs/features/active/2026-10-16-pester-profiler-coverage-953/evidence/qa-gates/`.
  - Acceptance: every hash is unchanged, P5-T1 through P5-T11 of this pass passed, and `LOOP_CLEAN_PASS: YES`.
- [x] [P5-T13] Record the acceptance-criteria re-verification and write `docs/features/active/2026-10-16-pester-profiler-coverage-953/evidence/qa-gates/r1-ac-reverification.<ts>.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:`.
  - The Output Summary has one line per item, `RECHECK: <item> | <evidence tasks> | PASS|FAIL`, for CR-1, CR-2, CR-3, AC-02, AC-03, AC-04, AC-06, AC-07, AC-13, AC-14, AC-15, and AC-16, using the "Requirements Traceability" evidence tasks.
  - Run `git diff --numstat <REM_BASE_SHA> -- docs/features/active/2026-10-16-pester-profiler-coverage-953/spec.md` and `git status --porcelain -- docs/features/active/2026-10-16-pester-profiler-coverage-953/spec.md` from the Bash tool, and record both outputs.
  - Acceptance:
    - Every line reads PASS.
    - Both `spec.md` outputs are empty, so this cycle changed no checkbox and added no acceptance criterion.
  - If any line reads FAIL, record `AC_RECHECK_FAILED: <item>` and stop for an orchestrator decision; the executor does not edit `spec.md`.
