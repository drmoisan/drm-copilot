# Research: Pester profiler-based coverage for the PoshQC Windows job (Issue #953)

- Issue: #953
- Branch: bug/pester-profiler-coverage-953
- Research timestamp (UTC, read from timeapi.io at write time): 2026-10-16T04-28
- Inputs read: `issue.md`, `spec.md`, `plan.2026-10-16T00-16.md` (template only) in this feature folder.

## 0. Tooling limits of this research session

- This session had read, search, and web-fetch tools only. No shell was available, so `pwsh`, `gh`, and Pester could not be executed. Every statement below about local Pester versions, CI step timings, or local run durations is either taken from committed evidence (cited) or marked as not verified.
- No repository file other than this artifact was written. No scratch file was created.

## 1. Every place Pester coverage is configured

### 1.1 Self-hosted module (the CI and reviewer path)

| Location | Current coverage setting |
|---|---|
| `scripts/powershell/PoshQC/settings/pester.runsettings.psd1:17-27` | `CodeCoverage = @{ Enabled = $true; OutputFormat = 'CoverageGutters'; OutputPath = 'artifacts/pester/powershell-coverage.xml'; CoveragePercentTarget = 0 }`. No `Path` (issue #527, comment lines 23-24). No `UseBreakpoints` key, so Pester's default applies: `UseBreakpoints = $true` (breakpoint mode). No `SingleHitBreakpoints` key (default `$true`). |
| `scripts/powershell/PoshQC/settings/pester.runsettings.psd1:2-16` | `Run.Path = @('scripts','tests/powershell','tests/scripts')`, `Run.Exit = $true`, `TestResult` JUnitXml to `artifacts/pester/pester-junit.xml`. |
| `scripts/powershell/PoshQC/PoshQC.psm1:3` | `$script:PesterSettings` points at the runsettings file above. |
| `scripts/powershell/PoshQC/PoshQC.Testing.psm1:154-460` (`Invoke-PoshQCTest`) | Loads the runsettings (`$LoadSettings`, line 171), builds the config with `New-PesterConfiguration -Hashtable` (line 172), expands run and coverage paths (lines 173-243, 313-315), forces `Output.Verbosity = 'Normal'` (332-334) and `Run.PassThru = $true` (336-338), computes `$coverageEnabled` (340-347), replaces `CodeCoverage.Path` with the workspace-derived population (349-364) or disables coverage when that population is empty (358-363), absolutizes `CodeCoverage.OutputPath` (366-378), runs Pester through the global trampoline (264-284, 397), writes the Koverage copy `*.koverage.xml` (399-415), and replays the coverage summary (427-458). It never sets `UseBreakpoints`. |
| `scripts/powershell/PoshQC/PoshQC.Coverage.psm1:246-314` (`Resolve-PoshQCCoveragePopulation`) | Population precedence: caller-supplied settings `CodeCoverage.Path` -> `config/poshqc-coverage.json` -> scan folders -> `Run.Path`. |
| `config/poshqc-coverage.json:1-10` | Coverage roots `.claude/hooks`, `.claude/lib`, `.codex/hooks`, `.codex/scripts`, `scripts`. This is the population source used in CI (`source=config`). |
| `config/poshqc-scan.json:1-6` | Test scan folders `scripts`, `tests/powershell`, `tests/scripts`. |
| `scripts/powershell/PoshQC/PoshQC.psm1:82-133` | Sub-module load via `[Parser]::ParseFile(...).GetScriptBlock()` with an AppDomain cache. The comments (lines 87-106) record two breakpoint-mode workarounds: file association so breakpoints bind (issue #344) and avoiding re-compilation that lost hit credit (issue #392). |
| `scripts/powershell/PoshQC/convert-poshqc-coverage.ps1` | Path-relativizing helper. Not mirrored into the bundle. |

### 1.2 CI workflow (test and coverage steps only)

| Location | Current setting |
|---|---|
| `.github/workflows/_poshqc.yml:16-20` | `Install-PoshQCTools` (installs only when no Pester >= 5.6.1 exists). |
| `.github/workflows/_poshqc.yml:38-42` | `Test PowerShell`: `Invoke-PoshQCTest -Root "${{ github.workspace }}"`. Uses the module defaults above, therefore breakpoint mode. |
| `.github/workflows/_poshqc.yml:44-52` | Uploads `artifacts/pester/pester-junit.xml`, `powershell-coverage.xml`, `powershell-coverage.koverage.xml` as artifact `poshqc-test-results`. No `if: always()`. |
| `.github/workflows/_poshqc.yml:70-82` | Linux hook-suite job: `Import-Module Pester -MinimumVersion 5.6.1`; `CodeCoverage.Enabled = $false`. |

### 1.3 Local runners

| Location | Coverage behavior |
|---|---|
| `scripts/dev-tools/run-pester.ps1:11-14` | Imports the repo module, calls `Invoke-PoshQCTest -Root $Root`. Inherits the module runsettings. |
| `scripts/dev-tools/run-poshqc-suite.ps1:21-24` | Imports the repo module, calls `Invoke-PoshQCSuite`, which calls `Invoke-PoshQCTest` (`PoshQC.Testing.psm1:23`). Inherits the module runsettings. |
| `scripts/dev_tools/fix_all_branches.py:349-350` | Runs `Import-Module './scripts/powershell/PoshQC'; Invoke-PoshQCTest -Root '.'`. Inherits the module runsettings. |
| `extensions/drm-copilot/resources/templates/run-poshqc-test.ps1:22-32` | Imports the bundled module copy relative to itself and calls `Invoke-PoshQCTest -Root $WorkspaceRoot -ScanFolders ...`. Used by the VS Code command and by the MCP tool `run_poshqc_test` (route documented in `docs/features/active/2026-08-23-poshqc-coverage-denominator-not-reproducible-527/research/research.2026-09-29T15-40.md:67-73`). |
| `.claude/`, `.codex/`, `tools/` | No `New-PesterConfiguration`, `Invoke-Pester`, or `CodeCoverage` usage other than two hook regexes that classify `pwsh ... Invoke-Pester` commands (`.claude/hooks/enforce-orchestration-preimplementation-gate.ps1:140`, `.codex/hooks/enforce-orchestration-preimplementation-gate.ps1:164`). |

### 1.4 Bundled mirror and how it is kept in sync

- Mirror directory: `extensions/drm-copilot/resources/powershell/PoshQC/` with `PoshQC.psm1`, `PoshQC.psd1`, five sub-modules, `README.md`, `settings/pester.runsettings.psd1`, `settings/pssa.settings.psd1`. Its runsettings and module files currently match the repo copy (same `CodeCoverage` block at line 17; same pin at `PoshQC.psm1:57`).
- Synchronization is manual. No copy script was found under `extensions/drm-copilot/package.json` or `scripts/`. The MCP package copies `resources/` at pack time (`packages/mcp-server/prepack.cjs`, cited by the #527 research), so the MCP route only sees a change after a package release.
- Parity pin: `tests/scripts/dev_tools/test_poshqc_bundled_parity.py:9-19,64-82` asserts text equality (Python `read_text(encoding="utf-8")`, which normalizes newlines, so it is text parity rather than strict byte parity) for nine files: `PoshQC.psm1`, the five sub-modules, `PoshQC.psd1`, `settings/pester.runsettings.psd1`, `settings/pssa.settings.psd1`. `README.md` is not in the parity list.
- Consequence: any edit to `pester.runsettings.psd1` or `PoshQC.psm1` must be applied to both copies in the same commit, or the pytest parity test fails.

## 2. Pester version pin

### 2.1 Current state

- Local installer pin: `scripts/powershell/PoshQC/PoshQC.psm1:55-58` lists `Pester` `5.6.1`. Line 61 accepts any installed version `>= 5.6.1`, and line 25 installs with `-RequiredVersion` only when none is found. The installer is therefore a floor, not an exact pin.
- `Invoke-PoshQCTest` imports the highest available version (`PoshQC.Testing.psm1:163-169`, `Import-Module $Name -Global`). There is no ceiling.
- CI source of 5.9.0: the Windows runner image ships Pester `3.4.0` and `5.9.0` and PSScriptAnalyzer `1.25.0` (GitHub runner-images `Windows2025-Readme.md`, image `20261004.281.1`, fetched 2026-10-16). Because 5.9.0 satisfies the `>= 5.6.1` floor, `Install-PoshQCTools` installs nothing and the job runs 5.9.0. The Ubuntu image also ships 5.9.0 (recorded in `docs/features/active/2026-09-27-ci-gaps-linux-pester-and-kcov-set-u-743/research/research.2026-09-30T07-20.md:62`). There is no explicit 5.9.0 string in any workflow.
- Local machine version: not verified in this session (no shell). Most recent committed evidence shows `PESTER-VERSION: 5.6.1` on the local machine (`docs/features/active/2026-09-29-hook-preexisting-imports-fail-open-786/evidence/qa-gates/r2-final-ciparity.md:14`, 2026-10-10). The executor must run `pwsh -NoProfile -Command "Get-Module Pester -ListAvailable | Select Version"` and record the output as baseline evidence.
- PSGallery state (fetched 2026-10-16): latest 5.x is 5.9.1 (2026-08-11); 5.9.0 was published 2026-07-07; Pester 6.2.0 is the current stable release. Pester 5.9.0 release notes state that Pester 5 is in maintenance mode and that Windows PowerShell 5.1 and PowerShell 7.4+ remain tested.

### 2.2 Recommendation

Set the minimum to **5.9.0** everywhere that currently says 5.6.1.

- 5.9.0 is the version CI already runs on both images, so CI behavior does not change and no install step runs in CI.
- Profiler coverage has existed since 5.3.0, so 5.9.0 meets the `>= 5.4` requirement.
- 5.9.1 was considered. It would make every CI run install a module from PSGallery (added time and a network dependency) because the image ships 5.9.0.
- Optional hardening, out of minimal scope: add a ceiling below 6.0 so that a future runner image that ships Pester 6 does not silently change the major version. Pester 6 makes profiler coverage the default and has other breaking changes. If adopted, it changes the `EnsureModule` seam in `PoshQC.Testing.psm1:163-169` (both copies) and needs a unit test.

### 2.3 Files that must change for the pin

| File:line | Current | Change |
|---|---|---|
| `scripts/powershell/PoshQC/PoshQC.psm1:57` | `Version = '5.6.1'` | `'5.9.0'` |
| `extensions/drm-copilot/resources/powershell/PoshQC/PoshQC.psm1:57` | same | same (parity test) |
| `scripts/powershell/PoshQC/README.md:16` | `Pester 5.6.1` | `Pester 5.9.0` |
| `extensions/drm-copilot/resources/powershell/PoshQC/README.md:16` | same | same |
| `.github/workflows/_poshqc.yml:73` | `Import-Module Pester -MinimumVersion 5.6.1` | `-MinimumVersion 5.9.0` (job body only; no `on:` change) |
| `scripts/host-tools.manifest.json:15` | `"minimumVersion": "5.6.1"` | `"5.9.0"` (drives `HostBootstrap.psm1:386` `-RequiredVersion`) |
| `tests/scripts/host-tools.manifest.Tests.ps1:71,81,134` | test name, `-BeExactly '5.6.1'`, mocked installed version `5.6.1` | update all three to 5.9.0; line 134 must be raised or `AC06` PowerShell-module test (line 160-161) reports a failure |
| `.devcontainer/post-create.sh:246` | `Version = '5.6.1'` | `'5.9.0'` (consistency; not test-pinned) |
| `.github/codex/codex-web-setup.sh:226` | `Version = "5.6.1"` | `"5.9.0"` (consistency; not test-pinned) |

Not changed: `.devcontainer/local/Dockerfile:86`, `.devcontainer/codespaces/Dockerfile:86`, `.devcontainer/TROUBLESHOOTING.md:85` (they declare a 5.0.0 floor and install the latest); the many `#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }` headers in tests; HostBootstrap/HostVerification test fixtures that already use 5.4.0/5.5.0/5.6.1/5.9.0 as synthetic data.

## 3. Coverage thresholds

### 3.1 Where thresholds are configured or enforced

- Pester-level: `CoveragePercentTarget = 0` (`pester.runsettings.psd1:26`, both copies). Pester never fails a run on coverage.
- CI: no PowerShell coverage-threshold step exists. `_poshqc.yml` only uploads the artifacts. The only CI coverage gate is Python (`.github/workflows/_quality-checks.yml:87-91`).
- Review-time enforcement: the feature-review agent and hooks read `artifacts/pester/powershell-coverage.xml`.
  - `.claude/agents/feature-review.md:110-129`: repo-wide line >= 85%, new and modified files line >= 85%, no regression on changed lines; no branch threshold for PowerShell.
  - `.claude/hooks/validate-feature-review-coverage-metrics.ps1:145-180`: sums `//counter[@type="LINE"]` from the JaCoCo-structured XML (`Get-JacocoRepoCoverage`) to compute the repo-wide PowerShell figure.
- Per-file figures: the CoverageGutters output is JaCoCo-structured XML with per-`sourcefile` `LINE` counters and per-line `<line nr mi ci .../>` elements. `Invoke-PoshQCTest` also replays Pester's text summary up to `Missed commands` (`PoshQC.Testing.psm1:427-458`).
- Most recent CI baseline found in the tree: run `38315946747`, LINE 16232/17969 = 90.33% (`docs/features/active/2026-10-11-pr-author-hook-docs-only-exemption-901/policy-audit.2026-10-13T11-40.md:51`). Issue #847 records an earlier 84.67% under the #527 population change; the later 90.33% figure indicates the floor is currently met, but the executor must re-measure on the branch base.

### 3.2 How profiler mode counts compared with breakpoint mode (verified from source)

Sources: Pester 5.9.0 `src/functions/Coverage.ps1` and `src/csharp/Pester/Tracing/CodeCoverageTracer.cs` (raw GitHub, fetched 2026-10-16); Pester 5.3.0 release notes (https://github.com/pester/Pester/releases/tag/5.3.0); Pester v5 configuration reference (https://pester.dev/docs/v5/usage/configuration).

- Denominator is identical. Both modes build the command list from `Get-CoverageBreakpoints` (`Get-CommandsInFile` plus `IsIgnoredCommand`). `UseBreakpoints` only changes how `HitCount` is obtained. This matches the #527 research conclusion (`research.2026-09-29T15-40.md:59`).
- Hit collection differs:
  - Breakpoint mode: one `Set-PSBreakpoint` per command; `SingleHitBreakpoints` removes each breakpoint after its first hit.
  - Profiler mode: `[Pester.Tracing.Tracer]::Patch(...)` plus `Set-PSDebug -Trace 1`. `CodeCoverageTracer` keys hits by the raw `extent.File` string (`StringComparer.OrdinalIgnoreCase`, no separator or full-path normalization) and by exact `StartLine:StartColumn`. Scriptblocks with no file (`extent.File == null`) are skipped. `ReturnStatementAst` hits are column-adjusted (`StartColumnNumber + 7`).
- Expected per-file shifts: hits can differ where the executing scriptblock's file string does not equal the coverage path string, or where breakpoint binding behaved differently (for example the re-compilation credit loss documented at `PoshQC.psm1:93-106`). Tracer hits do not depend on scriptblock identity, so re-compiled files should not lose credit. The net direction per file is not determinable without measurement.
- Observed data point: one suite measured locally at 66.58% in both modes (`docs/features/potential/promoted/2026-09-29-blast-radius-overlap-perf.md:37`).
- Status: the v5 reference labels `UseBreakpoints = $false` as experimental; the 5.3.0 notes state it was measured "as accurate as the breakpoint based approach". Pester 6 makes the tracer the default.
- Source observation (not a confirmed defect): `Get-CoverageReport` uses `Hashtable.Add` on `BpLine:BpColumn` keys without a duplicate guard. If a profiler-mode run fails in report generation with a duplicate-key error, this is the first place to look.

### 3.3 Risk to each threshold

| Threshold | Risk | Control |
|---|---|---|
| Repo-wide line >= 85% (review-time) | Low. Same denominator; baseline headroom about 5 points. | Compare repo-wide LINE covered/total before and after; the denominator total must be identical. |
| Per-file new/modified >= 85% | Medium for files near 85% if any lose hits. | Per-file LINE diff for every `sourcefile` in the population; investigate every file whose covered count drops. |
| No regression on changed lines | Low (the change touches configuration, not production logic). | Same per-file diff. |
| `CoveragePercentTarget = 0` | None. | Unchanged. |

Constraint carried from the issue: no production file excluded, no threshold lowered, every per-file baseline change documented.

## 4. Tests that pin the Pester configuration or the PoshQC test invocation

| Test | What it pins | Effect of the change |
|---|---|---|
| `tests/scripts/dev_tools/test_poshqc_bundled_parity.py:9-19` | Text parity of runsettings and module files | Passes only if both copies are edited identically. |
| `tests/scripts/workflows/PoshQcWorkflow.Tests.ps1:50-94` | Exactly two job ids `poshqc` and `poshqc-linux-hooks`; `poshqc` on `windows-latest` running `Invoke-PoshQCTest -Root`; artifact `poshqc-test-results`; Linux job `Run.Path`, `Run.Exit`, `CodeCoverage.Enabled = $false`, `Invoke-Pester -Configuration`, JUnit path | Unaffected by the profiler switch and by the `-MinimumVersion` edit. A sharding change (section 6.3) breaks line 51 and probably lines 54-60 and must update them. |
| `tests/scripts/host-tools.manifest.Tests.ps1:71-84,134,160-161` | Manifest Pester minimum `5.6.1` and a mocked installed `5.6.1` | Must change with the pin. |
| `tests/scripts/powershell/PoshQC/PoshQC.Tests.ps1:83-155` (`Install-PoshQCTool`) | Installs `Pester` and `PSScriptAnalyzer`; the error text names `PSScriptAnalyzer 1.22.0` | Does not pin the Pester version string; unaffected. |
| `tests/scripts/powershell/PoshQC/PoshQC.Comprehensive.Tests.ps1:525-761`, `PoshQC.Coverage.Tests.ps1`, `PoshQC.TestingCoveragePruning.Tests.ps1`, `PoshQC.TestingInvokeConfigPaths.Tests.ps1`, `PoshQC.TestingInvokeSummary.Tests.ps1`, `PoshQC.CoverageConfig.Tests.ps1`, `PoshQC.ScanFolders.Tests.ps1`, `PoshQC.TestingSeamDefaults.Tests.ps1` | Inject settings tables and fake configurations through mocks or seams (for example `Comprehensive.Tests.ps1:533-565`, `Coverage.Tests.ps1:70-98`) | None read the shipped runsettings, so a runsettings-only change does not affect them. |

Gap: no test asserts any key of the shipped runsettings. The fix needs a new regression test (section 5 of the design below).

## 5. Item #936 attribution gap

- Search performed: `tests/**` for `#936`, `936`, `UseBreakpoints`, `profiler`, `breakpoint coverage`, `attribution`, `modes.ps1:41`, `206-207`. No test-file header in this tree mentions #936 or attributes a gap to breakpoint coverage. `docs/features/active/hook-coverage-attribution-gaps/` does not exist in this tree. The two headers referenced by the delegation prompt are therefore not present on this branch; they may exist on an unmerged #936 branch. Not verified.
- The gap as recorded (`docs/features/potential/promoted/2026-10-15-hook-coverage-attribution-gaps.md:26-27`):
  1. `.codex/hooks/enforce-orchestration-preimplementation-gate-modes.ps1:41` (catch body) reports 0 hits in CI run 38410234897.
  2. `.codex/hooks/enforce-orchestration-preimplementation-gate-epic-scope.ps1:206-207` report 0 hits in CI run 38423196404, although ES-D1 asserts the deny reason that only line 207 produces.
- The two test files that execute those lines, and their current headers:
  - `tests/scripts/codex-hooks/hook-import-failure-exemptions.FailClosed.Tests.ps1:3-14`: in-process; the decision rows re-dot-source the Codex gate inside the `It` with `Join-Path` mocked to throw for `feature-folder-resolution.ps1`. The gate is loaded through `Join-Path (Resolve-Path ...).Path '.codex/hooks/...'` (line 18-19).
  - `tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-epic-scope.Decision.Tests.ps1:4-16`: in-process; dot-sources the epic-scope file in `BeforeAll` through `Join-Path $script:RepoRoot '.codex/hooks/...'` (line 21), a forward-slash child segment on Windows.
- Both cases execute the code in-process, in files that other suites also load, and in both the file is loaded through a path string built with a forward-slash child segment. Other test headers in this repository document that breakpoint binding depends on the path string (for example `tests/scripts/claude-lib/worktree-resolution/WorktreeTargetResolution.Tests.ps1:22-24`), and `PoshQC.psm1:93-106` documents breakpoint credit loss after re-compilation of the same file.
- Expected effect of profiler mode:
  - If the cause is breakpoint-specific (re-compilation or re-binding when the same file is dot-sourced again by a later suite), profiler mode is expected to fix it, because tracer hits are keyed by file string and position, not by scriptblock instance.
  - If the cause is a path-string mismatch, profiler mode is not expected to fix it, because the tracer also compares the raw `extent.File` string without separator normalization (section 3.2).
  - Code run in a separate runspace or child process is not attributed in either mode. The only `[powershell]::Create()` usage in tests is `tests/scripts/claude-hooks/hook-dependency-failure.SpecialCases.Tests.ps1:102`, which is not one of the two #936 cases.
- Verification is mechanical: after the switch, read `<line nr="41" .../>` in the `enforce-orchestration-preimplementation-gate-modes.ps1` sourcefile and lines 206-207 of the epic-scope sourcefile in the CI `powershell-coverage.xml`, and record `ci` values. Report the outcome to #936; do not change #936's test files in this item.

## 6. CI job structure and sharding option

### 6.1 Current `poshqc` job (`.github/workflows/_poshqc.yml:8-52`)

1. Check out (`actions/checkout@v7`).
2. Install PoshQC tooling (`Install-PoshQCTools`).
3. Format PowerShell (fails on diff).
4. Analyze PowerShell (2.1 min in the baseline run, per the issue).
5. Test PowerShell (`Invoke-PoshQCTest`; 15.5 min in the baseline run, per the issue).
6. Upload `poshqc-test-results` (JUnit, CoverageGutters XML, Koverage copy). Not uploaded on failure because the step has no `if: always()`.

Coverage output is consumed only by humans and by the review-time hooks; nothing in CI parses it. The job is called from `.github/workflows/ci.yml:23-24` (owned by #952, not to be edited). The reported check name is `poshqc / PowerShell QC`.

### 6.2 Recommended primary fix

Set `UseBreakpoints = $false` in the `CodeCoverage` block of both runsettings copies. No workflow change is required for the speedup, because the workflow already uses the module defaults.

Rejected alternatives:
- Set `UseBreakpoints` in code inside `Invoke-PoshQCTest`. This adds logic to a 461-line file, and it would override a caller's explicit `-SettingsPath` choice. The data-only change is simpler, and the shipped settings are already the documented customization point.
- Pass a CI-only settings file from the workflow. This creates a second settings source and leaves local runs in breakpoint mode, so local and CI coverage figures would differ.

### 6.3 Conditional sharding design (only if the trigger fires)

Trigger (mechanical): after the profiler change merges, read the first CI run on the PR head and on `main`:

```text
gh run view <run-id> --json jobs --jq '.jobs[] | select(.name=="poshqc / PowerShell QC") | .steps[] | select(.name=="Test PowerShell") | ((.completedAt|fromdateiso8601) - (.startedAt|fromdateiso8601))'
```

Shard only if the value is greater than 480 seconds on the PR-head run. Record the raw JSON and the computed value as evidence. `gh --jq` uses gh's embedded jq, so no standalone `jq` binary is required.

Design, confined to `_poshqc.yml` job and step bodies plus PoshQC:

- `poshqc-static` job (windows-latest): checkout, install, Format, Analyze.
- `poshqc-shard` job: `strategy: { fail-fast: false, matrix: { shard: [1, 2, 3] } }`, name `PowerShell QC shard ${{ matrix.shard }}`. It runs `Invoke-PoshQCTest -Root ... -ShardIndex ${{ matrix.shard }} -ShardCount 3` and uploads per-shard artifacts named `poshqc-test-results-shard-${{ matrix.shard }}` (artifact names must be unique per run) with `if: always()`.
- `poshqc` job (keeps the job id and the name `PowerShell QC`, so the check name `poshqc / PowerShell QC` is unchanged): `needs: [poshqc-static, poshqc-shard]`. It downloads the shard artifacts, merges them into `artifacts/pester/powershell-coverage.xml`, enforces the line threshold on the merged report, writes the merged Koverage copy, and uploads `poshqc-test-results`.
- Module change: add `-ShardIndex`/`-ShardCount` to `Invoke-PoshQCTest`. Filter the already sorted `$testFiles` (`PoshQC.Testing.psm1:257,391`) by `index % ShardCount == ShardIndex - 1` and set `Run.Path` to the selected files. Every shard measures the full `config` population, so merged denominators are identical. `PoshQC.Testing.psm1` is 461 lines; it must stay under 500, so the selection logic belongs in a new small pure function (in `PoshQC.FileDiscovery.psm1` or a new sub-module). Both copies must change, and the parity list must be extended if a new sub-module is added.
- Merge: a new pure function (new sub-module, for example `PoshQC.CoverageMerge.psm1`, mirrored and added to `POSHQC_PARITY_PATHS` and to the load list at `PoshQC.psm1:113-119`) that unions the JaCoCo-structured XML at line granularity. Per `sourcefile`/`line nr`, a line is covered when `ci > 0` in any shard; set `ci = max(ci)`, `mi = (mi+ci) - max(ci)`, then recompute the `LINE`/`INSTRUCTION` counters bottom-up. LINE results are exact; INSTRUCTION results are a lower bound. That is acceptable because every repository gate reads LINE only (`validate-feature-review-coverage-metrics.ps1:153`).
- Threshold on the merged report: there is no current CI PowerShell threshold. Adding one (85% repo-wide LINE) is a scope expansion that applies only on the sharding path. It should be confirmed with the owner before planning, because it can turn a currently green CI red if a future change drops coverage.
- Completeness guard: the merge job asserts that the sum of shard JUnit `tests` counts equals the unsharded discovery count (or that the union of shard file lists equals the full sorted list) so that no test file is silently dropped.
- Tests to update: `PoshQcWorkflow.Tests.ps1:50-60` (job set and `poshqc` job contents). Add unit tests for the shard selector and the merge function (pure, in-memory XML strings, no temporary files).

## 7. Measuring CI step and job times

- Command: `gh run view <run-id> --json jobs` returns `jobs[].name`, `startedAt`, `completedAt`, and `steps[].name/startedAt/completedAt/conclusion`. Compute durations with `--jq` as in section 6.3; use the same filter without the `.steps` selection for the job.
- Before/after protocol: record the baseline run 38846579572 and at least two post-change runs (PR head and first `main` run after merge), because runner variance on `windows-latest` is not negligible. Store the raw JSON under `<FEATURE>/evidence/baseline/` and `<FEATURE>/evidence/qa-gates/`.
- Baseline figures: not verified in this session (no `gh` available). The values Test PowerShell 15.5 min, Analyze 2.1 min, and job 18.6 min are taken from `issue.md:16,42`. The executor must re-read run 38846579572 with the command above as P0 evidence.
- Test-count note: the issue states about 5,300 tests; local discovery evidence on 2026-10-10 found 5,700 tests in 200 files (`r2-final-ciparity.md:16-17`), and a policy audit cites a 10,322-test full run (`policy-audit.2026-10-13T11-40.md:59`). The executor should record the JUnit `tests` total from the baseline artifact instead of relying on any of these figures.

## 8. Local measurement feasibility

- Not run in this session (no shell).
- A full local run with coverage is likely to exceed the 20-minute budget in breakpoint mode, since CI takes 15.5 min on the hosted runner and local evidence shows a single suite takes 381 s under breakpoints (`blast-radius-overlap-perf.md:37`). A sampled comparison is the practical route.
- Sampled protocol (automatable): write two settings files in the session scratchpad named `issue-953-bp.runsettings.psd1` and `issue-953-prof.runsettings.psd1`, copies of the shipped runsettings that differ only in `UseBreakpoints`. Do not add a `Path` key, so the population still resolves from `config/poshqc-coverage.json` and the full instrumentation cost is present. Then run:
  `Import-Module ./scripts/powershell/PoshQC/PoshQC.psd1 -Force; Measure-Command { Invoke-PoshQCTest -Root . -ScanFolders tests/scripts/powershell,tests/scripts/workflows -SettingsPath <scratch file> -DisableKoverageCopy }`
  for each mode, and record wall time plus the LINE counters of the produced XML. Write outputs to the scratchpad, not to `artifacts/`, or copy the summaries into `<FEATURE>/evidence/`.
- Use the self-hosted module directly. The MCP `run_poshqc_test` route uses the published package's bundled copy and would not reflect the repository edit until a release ships.
- The sample is for the speed ratio only. The authoritative per-file coverage comparison should come from the full CI artifact (baseline run vs PR-head run), because the sampled population hit counts will be low.

## 9. Risks

| Risk | Assessment | Mitigation |
|---|---|---|
| Windows PowerShell 5.1 | The tracer patches by major version; the 5.3.0 notes exclude only PS3. CI uses `pwsh` 7.6.6. Many suites carry `#Requires -Version 7.0`, so a 5.1 full-suite run is not a supported scenario. The PoshQC README claims 5.1 support for the module itself. | No action; note in README. |
| Linux hook job | Coverage disabled (`_poshqc.yml:78`). Only the `-MinimumVersion` string changes. | `PoshQcWorkflow.Tests.ps1:81-87` continues to pass. |
| Experimental flag in Pester 5 | `UseBreakpoints = $false` is labeled experimental in v5 docs; it is the default in v6. | Per-file diff gate; rollback is a one-key revert in two files. |
| Tracer interaction with tests | The tracer uses `Set-PSDebug -Trace 1`. No test or coverage-root script calls `Set-PSDebug`, `Set-PSBreakpoint`, or real nested `Invoke-Pester` (all nested calls are mocked: `Comprehensive.Tests.ps1:627,683,751`; `TestingSeamDefaults.Tests.ps1:49`). | None needed; re-check if the CI run shows tracer errors. |
| Per-file coverage shift | Section 3.2. | Per-file LINE diff of every sourcefile; document every change. |
| Pester 6 drift on a future image | Floor-only install and highest-version import. | Optional ceiling (section 2.2). |
| File-size limit (500 lines) | Primary fix adds one line to each runsettings copy (35 lines). Sharding would push `PoshQC.Testing.psm1` (461 lines) toward the limit, so new logic must go in new or smaller files. | As designed in section 6.3. |
| Concurrent item #952 | It owns `ci.yml` and workflow `on:` blocks. This design edits only `_poshqc.yml` step and job bodies. | Keep `_poshqc.yml:3-5` untouched. |
| Bundle/MCP lag | Consumers of the MCP package keep breakpoint mode until the package is republished. | CHANGELOG entry under `[Unreleased]`. |

## 10. Proposed design and requirement mapping

- R1 (speed): `CodeCoverage.UseBreakpoints = $false` in both runsettings copies. Success: the CI `Test PowerShell` step on the PR head is measurably shorter than 15.5 min, recorded with the section 7 command.
- R2 (no reduction in enforcement): `Enabled`, `OutputFormat`, `OutputPath`, the population source, and `CoveragePercentTarget` are unchanged. The repo-wide LINE total (denominator) is identical before and after, and no file leaves the population.
- R3 (thresholds pass): repo-wide LINE >= 85% from the PR-head CI artifact. Every sourcefile with a changed covered count is listed with before and after values.
- R4 (pin reconciled): 5.9.0 at every site in section 2.3.
- R5 (conditional shard): executed only if the section 6.3 trigger value exceeds 480 s. Otherwise record the value and close the condition as not triggered.
- R6 (#936 observation): record the `ci` values for the three #936 lines from the PR-head artifact.

### Repository files the fix writes (primary path)

1. `scripts/powershell/PoshQC/settings/pester.runsettings.psd1` (add `UseBreakpoints = $false` with a comment citing #953)
2. `extensions/drm-copilot/resources/powershell/PoshQC/settings/pester.runsettings.psd1` (identical)
3. `scripts/powershell/PoshQC/PoshQC.psm1` (line 57 pin)
4. `extensions/drm-copilot/resources/powershell/PoshQC/PoshQC.psm1` (identical)
5. `scripts/powershell/PoshQC/README.md` (pin text and a profiler-mode note in the Pester settings bullet)
6. `extensions/drm-copilot/resources/powershell/PoshQC/README.md` (identical)
7. `.github/workflows/_poshqc.yml` (line 73 only)
8. `scripts/host-tools.manifest.json` (line 15)
9. `tests/scripts/host-tools.manifest.Tests.ps1` (lines 71, 81, 134)
10. `.devcontainer/post-create.sh` (line 246)
11. `.github/codex/codex-web-setup.sh` (line 226)
12. `extensions/drm-copilot/CHANGELOG.md` (`[Unreleased]` entry)
13. New regression test, for example `tests/scripts/powershell/PoshQC/PoshQC.RunSettings.Tests.ps1`: loads the shipped runsettings with `Import-PowerShellDataFile` and asserts `CodeCoverage.UseBreakpoints -eq $false`, `Enabled -eq $true`, `OutputFormat -eq 'CoverageGutters'`. It then builds `New-PesterConfiguration -Hashtable` from that table and asserts `CodeCoverage.UseBreakpoints.Value -eq $false`. A second assertion checks that `Install-PoshQCTool` requests Pester `5.9.0` through the injected `-InstallModule` seam (record the `$Version` argument; no real install). Both must fail before the fix. Reading a checked-in file follows the precedent in `PoshQcWorkflow.Tests.ps1:17-18`.
14. Evidence artifacts under `docs/features/active/2026-10-16-pester-profiler-coverage-953/evidence/` (baseline, qa-gates).

Additional files only if the sharding trigger fires: `.github/workflows/_poshqc.yml` (job bodies), `tests/scripts/workflows/PoshQcWorkflow.Tests.ps1`, one or two new PoshQC sub-modules in both copies, `scripts/powershell/PoshQC/PoshQC.psm1` load list (both copies), `PoshQC.Testing.psm1` (both copies, parameters only), `tests/scripts/dev_tools/test_poshqc_bundled_parity.py` (parity list), and new unit tests for the selector and merge functions.

## 11. Testing implications

- Regression first: the new runsettings test (item 13) fails on the current tree and passes after the edit.
- Existing suites to re-run: all of `tests/scripts/powershell/PoshQC/`, `tests/scripts/workflows/PoshQcWorkflow.Tests.ps1`, `tests/scripts/host-tools.manifest.Tests.ps1`, the HostBootstrap/HostVerification suites, and `pytest tests/scripts/dev_tools/test_poshqc_bundled_parity.py`.
- Integration: the full suite under profiler mode in CI; compare the PR-head `poshqc-test-results` artifact against the baseline artifact per sourcefile.
- Toolchain: PoshQC format, analyze, and test (self-hosted module), Black/Ruff/Pyright/pytest for the parity test (unchanged code), and actionlint for `_poshqc.yml` if available.
- Tests must not create temporary files; scratch settings for the sampled timing are measurement inputs in the session scratchpad, not test fixtures.

## Numeric Derivation Evidence

### N1: Non-test repository sites that pin Pester at 5.6.1

- Complete Family: every non-test, non-documentation-history file location that declares Pester version 5.6.1 as an install, import, manifest, or documentation pin.
- Exhaustive Search Scope: whole worktree excluding `docs/**`, `node_modules/**`, `tests/**`, `**/package-lock.json`, and `tests/fixtures/**`; all file types.
- Inclusion Rules: a line whose Pester version literal is `5.6.1`.
- Exclusion Rules: `#Requires -Modules ... ModuleVersion = '5.0.0'` headers (different value, test files); Dockerfile and TROUBLESHOOTING `-MinimumVersion 5.0.0` lines (different value); test fixtures and test mocks (counted separately under N2).
- Primary Search Strategy or Query Expression: ripgrep `5\.6\.1|5\.9\.0|Pester.{0,40}(Version|version)` over the scope, then filter to lines containing `5.6.1`.
- Primary Member Set: `.github/workflows/_poshqc.yml:73`; `.github/codex/codex-web-setup.sh:226`; `scripts/powershell/PoshQC/README.md:16`; `scripts/powershell/PoshQC/PoshQC.psm1:57`; `scripts/host-tools.manifest.json:15`; `extensions/drm-copilot/resources/powershell/PoshQC/README.md:16`; `extensions/drm-copilot/resources/powershell/PoshQC/PoshQC.psm1:57`; `.devcontainer/post-create.sh:246`.
- Primary Count: 8.
- Cross-check Search Strategy or Query Expression: ripgrep `(Name\s*=\s*['"]Pester['"]|"name":\s*"Pester"|Import-Module Pester|Install-Module -Name Pester|Pester \d+\.\d+\.\d+ \()` over the same scope (matches Pester declarations by shape, independent of the version literal), then apply the exclusion rules. A separate `5\.6\.1` search over `*.py, *.ts, *.bats, *.sh, *.cjs, *.mjs` confirmed the two shell sites.
- Cross-check Member Set: the same 8 locations, plus `.devcontainer/TROUBLESHOOTING.md:85`, `.devcontainer/local/Dockerfile:86`, `.devcontainer/codespaces/Dockerfile:86`, all removed by the 5.0.0 exclusion rule.
- Cross-check Count: 8 after exclusions.
- Member-set Comparison: the normalized sets are identical (8 = 8; same file:line members).

### N2: Test-file lines that pin Pester 5.6.1 and must change with the manifest

- Complete Family: test lines whose assertion or mock would fail once `scripts/host-tools.manifest.json` declares 5.9.0.
- Exhaustive Search Scope: `tests/**` (`*.ps1`, `*.py`).
- Inclusion Rules: a line that asserts the manifest Pester minimum or supplies the installed Pester version against the committed manifest.
- Exclusion Rules: `#Requires` headers; fixtures that build their own synthetic manifest (`HostBootstrap.Invoke.Tests.ps1:57,201`, `HostVerification.Tests.ps1:293`, `verify-host.Tests.ps1:40`), because they do not read the committed manifest.
- Primary Search Strategy or Query Expression: ripgrep `5\.6\.1` over `tests/**` followed by reading each hit's context.
- Primary Member Set: `tests/scripts/host-tools.manifest.Tests.ps1:71`, `:81`, `:134`.
- Primary Count: 3.
- Cross-check Search Strategy or Query Expression: read `tests/scripts/host-tools.manifest.Tests.ps1` lines 65-162 and locate every consumer of `$script:Manifest.powershellModules` or a mocked `Get-Module` version (`Test-HostPowerShellModule` at line 160).
- Cross-check Member Set: lines 71 and 81 (direct assertion), 134 (mock consumed by line 160).
- Cross-check Count: 3.
- Member-set Comparison: identical.

## Automation Feasibility

- Every step is automatable with no human interaction: file edits, the regression test, PoshQC format/analyze/test, pytest parity, `gh run view` timing extraction, artifact download (`gh run download <id> -n poshqc-test-results`), and the per-sourcefile LINE diff (a PowerShell or Python XML comparison).
- Environmental prerequisites rather than human steps: an execution route that permits `pwsh` and `gh` (some agent worktrees deny these command names in text; the executor may need the PowerShell tool route), network access to GitHub, and an authenticated `gh`.
- The trigger decision for sharding is mechanical (step duration > 480 s). The only judgment point is whether to add a new CI coverage threshold on the sharding path (section 6.3); it should be settled in the spec before planning so that execution needs no decision.
- Waiting for CI to finish is a polling step (`gh run watch` or a `gh run view` loop), not a human interaction.
