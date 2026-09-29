# 2026-08-23-poshqc-coverage-denominator-not-reproducible (Plan)

- **Issue:** #527 (canonical; absorbs item 1 of #623)
- **Branch:** `bug/poshqc-coverage-denominator-not-reproducible-527`
- **Parent (optional):** none
- **Owner:** drmoisan
- **Last Updated:** 2026-09-29T16-40
- **Status:** Draft (pending executor preflight)
- **Version:** 1.0
- **Work Mode:** full-bug
- **Complexity band: C3** (floor signal `cross_module_contract_change`: the bundled runsettings and coverage-population contract under `extensions/drm-copilot/resources/powershell/PoshQC/` is consumed by consumer repositories through the extension and MCP package resources).
- **Requirements sources:** `issue.md`, `spec.md` (18 acceptance criteria under `## Acceptance Criteria`; the only AC source), `research/research.2026-09-29T15-40.md`. `user-story.md` is intentionally absent (full-bug mode).
- **FEATURE:** `docs/features/active/2026-08-23-poshqc-coverage-denominator-not-reproducible-527` (every `<FEATURE>` token below means this folder).

**Fail-closed evidence rule:** Include explicit baseline artifact tasks, final-QA artifact tasks, and coverage-comparison tasks for each in-scope language when policy requires coverage. If any required baseline artifact, QA artifact, or coverage-comparison artifact is missing, the audit verdict must be BLOCKED or INCOMPLETE, never PASS.

**Evidence accounting rule:** Record the expected artifact path in each evidence-producing task. Do not mark evidence-backed work complete without the artifact. Every evidence artifact lives under `<FEATURE>/evidence/<kind>/` (`baseline`, `regression-testing`, `qa-gates`, `other`) and carries `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:`; an artifact whose expected exit code is non-zero also carries `ExpectedExitCode:`. `<ts>` in a file name is the execution timestamp in `yyyy-MM-ddTHH-mm` form. Evidence text must not contain absolute host paths: replace the repository root with `<ROOT>`.

## AC Identifiers (spec.md `## Acceptance Criteria`, in document order)

| ID | spec.md line prefix |
| --- | --- |
| AC-01 | `- [ ] Deterministic derivation:` |
| AC-02 | `- [ ] Route independence:` |
| AC-03 | `- [ ] Derived population contents:` |
| AC-04 | `- [ ] Precedence order:` |
| AC-05 | `- [ ] Observability:` |
| AC-06 | `- [ ] Config validation:` |
| AC-07 | `- [ ] Absolute root:` |
| AC-08 | `- [ ] Allow-list removed:` |
| AC-09 | `- [ ] Parity preserved:` |
| AC-10 | ``- [ ] `config/poshqc-coverage.json` exists with`` |
| AC-11 | `- [ ] Consumer fixture coverage:` |
| AC-12 | `- [ ] Consumer isolation:` |
| AC-13 | `- [ ] Fixture output hygiene:` |
| AC-14 | `- [ ] New code coverage:` |
| AC-15 | `- [ ] Existing suite:` |
| AC-16 | `- [ ] Documentation:` |
| AC-17 | `- [ ] No temporary files in tests:` |
| AC-18 | ``- [ ] `PoshQC.Testing.psm1` and every new production or test file remain`` |

No AC is added to `spec.md`. The IDs above are plan-local labels.

## Design Contract (binding for Phases 1 through 5)

- **D1 — New sub-module.** `scripts/powershell/PoshQC/PoshQC.Coverage.psm1` holds four internal functions. None is added to `Export-ModuleMember` in `PoshQC.psm1` or to `FunctionsToExport` in `PoshQC.psd1`; tests reach them through `InModuleScope PoshQC`. The manifest `PoshQC.psd1` (both copies) is not modified.
  - `Get-PoshQCSettingsList -Settings <object> -Section <string> -Key <string>` returns the non-blank string entries of `Settings[Section][Key]`, or an empty array when `Settings` or the section is not an `IDictionary` or the key is absent. It is used for `CodeCoverage.Path` and `Run.Path`.
  - `Get-PoshQCCoverageConfigRoot -Root <string> [-ConfigRelativePath 'config/poshqc-coverage.json'] [-TestPathExists { param([string] $Path) Test-Path -LiteralPath $Path -PathType Leaf }] [-ReadContent { param([string] $Path) Get-Content -LiteralPath $Path -Raw }]` returns `[pscustomobject]@{ Present = [bool]; Roots = [string[]] }`. An absent file returns `Present = $false`. Every validation failure throws a message containing the literal `config/poshqc-coverage.json`: whitespace-only content, invalid JSON, a `version` other than 1, a missing or non-array `roots`, and a blank, rooted (`[IO.Path]::IsPathRooted`), or `..`-segment entry. An empty `roots` array is valid and yields an empty population.
  - `Get-PoshQCCoverageFileSet -Root <string> -Roots <string[]> [-ExcludeDirs $script:DefaultExcludedDirs] [-TestPathExists { param([string] $Path) Test-Path -LiteralPath $Path -PathType Container }] [-EnumerateFiles { param([string] $Path) Get-ChildItem -LiteralPath $Path -Recurse -File -Force }] [-WarningLogger { param([string] $Message) Write-Warning $Message }]` returns `[pscustomobject]@{ RelativePath; FullPath }` items. A root that is not rooted is joined to `Root`. A nonexistent root emits exactly one warning `Coverage root '<root>' does not exist under '<Root>'; skipping.` and is skipped. Kept files: extension `.ps1` or `.psm1` (case-insensitive), name not matching `*.Tests.ps1`, first root-relative segment not `tests` (case-insensitive), and no root-relative segment in `ExcludeDirs`. Root-relative paths use forward slashes. The result is sorted with `[StringComparer]::Ordinal` on `RelativePath`, then de-duplicated with `[StringComparer]::OrdinalIgnoreCase`, keeping the first (ordinally smallest) variant. `FullPath` is the enumerated `FullName`.
  - `Resolve-PoshQCCoveragePopulation -Root <string> -Settings <object> -SettingsFile <string> -ScanFolderRoots <string[]> [-ExcludeDirs] [-DefaultSettingsFile $script:PesterSettings] [-SettingsPathExists { param([string] $Path) Test-Path $Path }] [-Logger] [-WarningLogger] [-ReadConfig { param([string] $RootPath) Get-PoshQCCoverageConfigRoot -Root $RootPath }] [-GetFileSet { param([string] $RootPath, [string[]] $Roots, [string[]] $Excluded, [scriptblock] $Warn) Get-PoshQCCoverageFileSet -Root $RootPath -Roots $Roots -ExcludeDirs $Excluded -WarningLogger $Warn }]` returns `[pscustomobject]@{ Source = 'settings'|'config'|'fallback'; Paths = [string[]] }`.
- **D2 — Precedence (interpretation of spec precedence 1).** A settings file is "caller-supplied custom" when `SettingsFile` is non-blank and its full path (non-rooted values combined with `$PWD.ProviderPath`, then `[IO.Path]::GetFullPath`) differs, compared with `OrdinalIgnoreCase`, from the full path of `DefaultSettingsFile`. (1) `settings`: a custom settings file with a non-empty `CodeCoverage.Path` is honored; non-rooted entries are joined to `Root`, each entry for which `SettingsPathExists` is false is removed and logged as `Pruned nonexistent code coverage path: <path>`, and the surviving order is preserved. A non-empty `CodeCoverage.Path` in the module-default settings file is not honored; the resolver logs `Ignored CodeCoverage.Path from the module-default settings file; the coverage population is derived from the workspace.` and continues. (2) `config`: `ReadConfig` reports `Present`. (3) `fallback`: `ScanFolderRoots` when non-empty, else settings `Run.Path`. Rationale: the shipped copies carry no list (spec precedence 1), and ignoring a list in the module-default copy is what makes the measured set independent of which module copy was loaded (AC-02). `Invoke-PoshQCSuite` passes the module default and is therefore not "custom".
- **D3 — `Invoke-PoshQCTest` changes (`scripts/powershell/PoshQC/PoshQC.Testing.psm1`).** (a) New parameter appended after `$CopyCoverage`: `[scriptblock] $ResolveCoveragePopulation = { param([string] $RootPath, $Settings, [string] $SettingsFile, [string[]] $ScanFolderRoots, [string[]] $Excluded, [scriptblock] $PathExists, [scriptblock] $Log) Resolve-PoshQCCoveragePopulation -Root $RootPath -Settings $Settings -SettingsFile $SettingsFile -ScanFolderRoots $ScanFolderRoots -ExcludeDirs $Excluded -SettingsPathExists $PathExists -Logger $Log }`, plus a `.PARAMETER ResolveCoveragePopulation` help entry. (b) Immediately after the existing `$Root = $PWD.ProviderPath` default (current lines 290-292): `if (-not [IO.Path]::IsPathRooted($Root)) { $Root = [IO.Path]::GetFullPath([IO.Path]::Combine($PWD.ProviderPath, $Root)) }`. A rooted `-Root` is used unchanged, which keeps the existing seam tests that use `/prune-root`-style roots valid. (c) The inner block at current lines 339-367 (`if ($config.CodeCoverage.Path.Value) { ... }`) is replaced by: `$population = & $ResolveCoveragePopulation $Root $settings $SettingsPath $effectiveScanFolders $ExcludeDirs $TestPathExists $Logger`; `$populationPaths = @($population.Paths | Where-Object { $_ })`; log `Code coverage population: source=<Source>; files=<count>`; a non-empty set is assigned to `$config.CodeCoverage.Path`; an empty set sets `$config.CodeCoverage.Enabled = $false`, `$coverageEnabled = $false`, and logs the existing line `Code coverage disabled for this invocation: no configured coverage path exists under root '<Root>'.` (issue #409 semantics). The output-path block at current lines 369-381 is unchanged. The file must end at or under 500 lines.
- **D4 — Log literals (exact).** `Code coverage population: source=settings; files=<n>` / `source=config` / `source=fallback`; `Pruned nonexistent code coverage path: `; `Code coverage disabled for this invocation`; `Ignored CodeCoverage.Path from the module-default settings file`.
- **D5 — Runsettings.** Both `settings/pester.runsettings.psd1` copies drop the `CodeCoverage.Path` array (current lines 23-325) and its comments. They keep `Enabled = $true`, the `OutputFormat = 'CoverageGutters'` comment and value, `OutputPath = 'artifacts/pester/powershell-coverage.xml'`, and `CoveragePercentTarget = 0`, and gain the two comment lines `# Issue #527: no Path list. Invoke-PoshQCTest derives the coverage population from the` and `# workspace (config/poshqc-coverage.json, else the effective test scan folders); see README.md.` `Run`, `Should`, `Output`, and `TestResult` are unchanged.
- **D6 — Repository coverage config.** `config/poshqc-coverage.json` is exactly the JSON document `{"version": 1, "roots": [".claude/hooks", ".claude/lib", ".codex/hooks", ".codex/scripts", "scripts"]}` written with two-space indentation, one root per line, LF endings, and a trailing newline.
- **D7 — Consumer fixture.** Three files under `tests/fixtures/poshqc-consumer/`, LF endings, no `config/` directory (fallback exercised). The fixture sits outside the repository `Run.Path` (`scripts`, `tests/powershell`, `tests/scripts`) and under `tests/`, so the repository suite never runs it and the repository population never measures it. Fixture acceptance runs pass `-ScanFolders @('scripts','tests/scripts')`, matching the #623 reproduction, which supplied explicit scan folders, and keeping nonexistent folders out of `Run.Path`.
- **D8 — Fixture output hygiene mechanism (AC-13).** Ignore entry: `.gitignore` gains `/tests/fixtures/poshqc-consumer/artifacts/` directly after the existing `/artifacts` line (line 6). Every run (rule FR) first deletes its own previous `powershell-coverage.xml`, `powershell-coverage.koverage.xml`, `pester-junit.xml`, and run log under `<RunRoot>/artifacts/pester/` (all ignored), so no parse reads stale output; other files in that directory, such as the run A copies made by P6-T4, are kept.
- **D9 — Potential entry disposition.** `docs/features/potential/2026-08-19-mcp-poshqc-test-ignores-repo-runsettings-coverage.md` is annotated in place (not moved): its `- Status:` line becomes `- Status: Superseded by #527` and a `## Disposition` section is added. It is not promoted separately.
- **D10 — Toolchain of record.** The spec (Assumptions; Test Strategy) directs that acceptance evidence comes from the self-hosted module. The MCP `run_poshqc_*` tools execute the installed extension's PoshQC copy, which does not contain this change, and return only a pre-composed summary string, so no task in this plan invokes them and no acceptance condition reads a count, percentage, or finding from an MCP result. Every PowerShell command runs in a fresh `pwsh -NoProfile` child process, because `PoshQC.psm1` caches parsed sub-module scriptblocks per process (lines 107-132), so a persistent host would keep pre-edit code. Execute every command in this plan from the PowerShell tool; the `pwsh -NoProfile -Command { ... } -args ...` scriptblock form avoids outer-shell interpolation.
- **D11 — Python scope.** The only Python change is one tuple entry in the test module `tests/scripts/dev_tools/test_poshqc_bundled_parity.py`. No Python production module changes, so Python coverage is not applicable; the Python loop runs Black, Ruff, Pyright, and Pytest on that file.
- **D12 — Mandatory-loop stages 4, 6, and 7.** No architecture-boundary, contract/schema, or integration tooling is configured for the PoshQC module; the consumer fixture run is the integration-style check for this change. This is recorded in the final QA evidence and is not a skipped planned command.
- **D13 — Test design.** No test creates a file: fakes return `[pscustomobject]@{ FullName; Extension; Name }`, JSON text, and path-discriminating existence answers. `TestDrive`, `New-TemporaryFile`, `GetTempFileName`, `GetTempPath`, `$env:TEMP`, and `$env:TMP` do not appear anywhere in the new or edited test files, including comments. Tests R1, R2, and R3 inject the tree only through parameters that exist before the fix (`-EnsureModule { }`, `-TestPathExists`, `-LoadSettings`, `-BuildConfiguration`, `-ExpandCoveragePaths`, `-ResolveScanConfig`, `-ResolveScanFolders`, `-EnumerateTests`, `-InvokePester`, `-CopyCoverage`, `-Logger`) plus `InModuleScope PoshQC` mocks of `Test-Path`, `Get-ChildItem`, `Get-Content`, and `New-Item` whose bodies answer from an in-memory tree rooted at `/cov-root` (paths normalized with `-replace '\\','/'`). They must not pass `-ResolveCoveragePopulation` and must not mock `Resolve-PoshQCCoveragePopulation`, `Get-PoshQCCoverageConfigRoot`, or `Get-PoshQCCoverageFileSet`, so the default seams execute and count toward coverage, and so that before the fix they fail on an assertion rather than on parameter binding.
- **D14 — Existing-test impact (derived from the current tests).** Tests that pass an explicit non-default `-SettingsPath` with a non-empty `CodeCoverage.Path` keep their behavior under D2 (`PoshQC.TestingCoveragePruning.Tests.ps1` lines 31-258, `PoshQC.TestingInvokeConfigPaths.Tests.ps1` lines 115-157, `PoshQC.Tests.ps1` lines 492-578, `PoshQC.ScanFolders.Tests.ps1` lines 214-284). Four tests are predicted to fail after Phase 3 and are adapted in Phase 4: `PoshQC.TestingInvokeSummary.Tests.ps1` 'replays coverage report lines up to the Missed commands marker and stops (lines 410-415, 417-420, 427-428, 437-439)' and 'falls back to the first raw line when the Missed commands marker is the first line seen (lines 423-424, 427-428, 437-439)' (empty settings `Path` now resolves a population, and the new population log line changes the exact log count at line 138); `PoshQC.Comprehensive.Tests.ps1` 'Should generate Koverage copy by default when coverage is enabled' and 'Should use custom KoverageOutputPath when provided' (their `Test-Path` mocks at lines 621-622 and 745-746 answer false for the settings coverage entry, which D2 now prunes; before the fix the default `$ExpandCoveragePaths` unwrapped `Path.Value` and the prune block was skipped). The Comprehensive edit is line-neutral because that file is already over 500 lines.

## Complete Write Set

Every file this plan writes, by explicit repository-relative path. No other tracked file may change.

| # | Path | Action | Task |
| --- | --- | --- | --- |
| 1 | `tests/fixtures/poshqc-consumer/scripts/Sample.psm1` | Create | P1-T2 |
| 2 | `tests/fixtures/poshqc-consumer/tests/scripts/Sample.Tests.ps1` | Create | P1-T3 |
| 3 | `tests/fixtures/poshqc-consumer/.claude/hooks/validate-bash.ps1` | Create | P1-T4 |
| 4 | `.gitignore` | Edit | P1-T6 |
| 5 | `tests/scripts/powershell/PoshQC/PoshQC.Coverage.Tests.ps1` | Create | P2-T2 |
| 6 | `tests/scripts/powershell/PoshQC/PoshQC.CoverageConfig.Tests.ps1` | Create | P2-T3 |
| 7 | `scripts/powershell/PoshQC/PoshQC.Coverage.psm1` | Create | P3-T2 |
| 8 | `scripts/powershell/PoshQC/PoshQC.psm1` | Edit | P3-T3 |
| 9 | `scripts/powershell/PoshQC/PoshQC.Testing.psm1` | Edit | P3-T4 |
| 10 | `scripts/powershell/PoshQC/settings/pester.runsettings.psd1` | Edit | P3-T6 |
| 11 | `config/poshqc-coverage.json` | Create | P3-T7 |
| 12 | `tests/scripts/powershell/PoshQC/PoshQC.TestingInvokeSummary.Tests.ps1` | Edit | P4-T4 |
| 13 | `tests/scripts/powershell/PoshQC/PoshQC.Comprehensive.Tests.ps1` | Edit (line-neutral) | P4-T5 |
| 14 | `scripts/powershell/PoshQC/README.md` | Edit | P5-T1 |
| 15 | `extensions/drm-copilot/resources/powershell/PoshQC/PoshQC.Coverage.psm1` | Create (Copy-Item) | P5-T2 |
| 16 | `extensions/drm-copilot/resources/powershell/PoshQC/PoshQC.Testing.psm1` | Update (Copy-Item) | P5-T3 |
| 17 | `extensions/drm-copilot/resources/powershell/PoshQC/PoshQC.psm1` | Update (Copy-Item) | P5-T4 |
| 18 | `extensions/drm-copilot/resources/powershell/PoshQC/settings/pester.runsettings.psd1` | Update (Copy-Item) | P5-T5 |
| 19 | `extensions/drm-copilot/resources/powershell/PoshQC/README.md` | Update (Copy-Item) | P5-T6 |
| 20 | `tests/scripts/dev_tools/test_poshqc_bundled_parity.py` | Edit | P5-T8 |
| 21 | `docs/features/potential/2026-08-19-mcp-poshqc-test-ignores-repo-runsettings-coverage.md` | Edit (annotate) | P5-T10 |
| 22 | `docs/features/active/2026-08-23-poshqc-coverage-denominator-not-reproducible-527/spec.md` | Edit (AC check-off only) | P6-T31 to P6-T48 |
| 23 | `docs/features/active/2026-08-23-poshqc-coverage-denominator-not-reproducible-527/plan.2026-09-29T15-32.md` | Edit (checkbox state only) | all tasks |
| 24 | `<FEATURE>/evidence/**` | Create (evidence artifacts) | evidence tasks |

Unchanged by design: `scripts/powershell/PoshQC/PoshQC.psd1`, `extensions/drm-copilot/resources/powershell/PoshQC/PoshQC.psd1`, both `settings/pssa.settings.psd1` copies, `PoshQC.FileDiscovery.psm1`, `PoshQC.ScanConfig.psm1`, `PoshQC.Analyzer.psm1` (both copies), `PoshQC.Tests.ps1`, `PoshQC.ScanFolders.Tests.ps1`, `PoshQC.TestingCoveragePruning.Tests.ps1`, `PoshQC.TestingInvokeConfigPaths.Tests.ps1`, `config/poshqc-scan.json`, `extensions/drm-copilot/src/poshqc-scan-config.ts`, and everything under `tests/fixtures/blast_radius/`. Git-ignored run output (`artifacts/pester/**`, `tests/fixtures/poshqc-consumer/artifacts/**`, `.claude/state/**`) is not part of the write set.

`CHANGED_PS` (the PowerShell files formatted and analyzed in Phase 6): write-set rows 1, 2, 3, 5, 6, 7, 8, 9, 10, 12, 13.

## Batch-Budget Protocol

`.claude/hooks/enforce-powershell-batch-budget.ps1` (line 284 classifies `tests/**/*.ps1` and `*.Tests.ps1` as test files; everything else with `.ps1`, `.psm1`, or `.psd1` is production, so `tests/fixtures/poshqc-consumer/scripts/Sample.psm1` counts as production) denies the fourth distinct file of a kind per session (lines 293-297). The hooks run as `pwsh -NoProfile -File .claude/hooks/...` from the worktree (`.claude/settings.json` lines 128-145), so the state file is `.claude/state/powershell-batch-budget.<session_id>.json` in this worktree.

- **Rule BR (reset):** `pwsh -NoProfile -Command { Get-ChildItem -LiteralPath .claude/state -Filter 'powershell-batch-budget.*.json' -ErrorAction SilentlyContinue | Remove-Item -Force -PassThru | ForEach-Object Name }`. Append one line per reset to `<FEATURE>/evidence/other/batch-budget-resets.<ts>.md` (one file for the whole execution, created by the first reset) naming the reset ID, the deleted file names, and the files the next batch will write. If a Write or Edit is still denied, delete the exact state file named in the deny reason, and record that path with the root replaced by `<ROOT>`.
- **Remediation edits:** before any Write or Edit of a PowerShell file that is not already counted in the current batch, if the batch already holds three files of that kind, run Rule BR first and record it.
- **Mirrors:** bundled mirror files are produced only with `Copy-Item` in a `pwsh -NoProfile` child (Phase 5), never with Write or Edit.
- The Python budget hook admits the single Python file in this plan without a reset.

## Evidence Derivation Rules

Each rule is a scriptblock run as `pwsh -NoProfile -Command { <rule body> } -args <arguments>` from the repository root. Tasks cite the rule ID and its arguments. `EXIT_CODE` is `$LASTEXITCODE` after the child exits.

**FR — full self-hosted Pester run** (args: `RunRoot`, `LogName`, `WorkingSubdirectory`, `ScanFolderList`):

```powershell
param([string] $RunRoot, [string] $LogName, [string] $WorkingSubdirectory, [string] $ScanFolderList)
$ErrorActionPreference = 'Stop'
$repoRoot = (Get-Location).Path
$testRoot = if ($RunRoot -eq '.') { $repoRoot } else { (Resolve-Path -LiteralPath (Join-Path $repoRoot $RunRoot)).Path }
$outputDirectory = Join-Path $testRoot 'artifacts/pester'
foreach ($stale in 'powershell-coverage.xml', 'powershell-coverage.koverage.xml', 'pester-junit.xml', $LogName) {
    Remove-Item -LiteralPath (Join-Path $outputDirectory $stale) -Force -ErrorAction SilentlyContinue
}
New-Item -ItemType Directory -Path $outputDirectory -Force | Out-Null
$logPath = Join-Path $outputDirectory $LogName
Import-Module (Join-Path $repoRoot 'scripts/powershell/PoshQC/PoshQC.psd1') -Force
if ($WorkingSubdirectory) { Set-Location -LiteralPath (Join-Path $repoRoot $WorkingSubdirectory) }
$logger = { param([string] $Message) Add-Content -LiteralPath $logPath -Value $Message; Write-Information $Message -InformationAction Continue }.GetNewClosure()
$testParameters = @{ Root = $testRoot; Logger = $logger }
if ($ScanFolderList) { $testParameters.ScanFolders = @($ScanFolderList -split ',') }
Invoke-PoshQCTest @testParameters
```

Pester 5 `Run.Exit` (runsettings line 4) exits the child with the failed-test count when failures occur, after the JUnit and coverage files are written; a clean run exits 0.

**JX — JUnit counts** (args: `RunRoot`). Prints one line `TESTS=<n> FAILURES=<n> ERRORS=<n> DISABLED=<n>` read from the `testsuites` element:

```powershell
param([string] $RunRoot)
$rootPath = (Resolve-Path -LiteralPath $RunRoot).Path
[xml] $junit = Get-Content -LiteralPath (Join-Path $rootPath 'artifacts/pester/pester-junit.xml') -Raw
$suites = $junit.testsuites
"TESTS=$($suites.tests) FAILURES=$($suites.failures) ERRORS=$($suites.errors) DISABLED=$($suites.disabled)"
```

**CX — coverage XML per-file keys and root LINE counter** (args: `RunRoot`, `XmlRelativePath`). A file key is the enclosing `package` element's `name` (backslashes turned into forward slashes, the run root prefix removed case-insensitively) joined by `|` to the `sourcefile` element's `name`. Keys are never taken from the bare `sourcefile` name alone, because `.claude/hooks` and `.codex/hooks` hold same-named files:

```powershell
param([string] $RunRoot, [string] $XmlRelativePath)
$ErrorActionPreference = 'Stop'
$rootPath = (Resolve-Path -LiteralPath $RunRoot).Path
[xml] $report = Get-Content -LiteralPath (Join-Path $rootPath $XmlRelativePath) -Raw
$rootNorm = ($rootPath -replace '\\', '/').TrimEnd('/')
$reportLine = @($report.report.counter | Where-Object { $_.type -eq 'LINE' })[0]
$rows = foreach ($package in @($report.report.package | Where-Object { $_ })) {
    $packageName = $package.name -replace '\\', '/'
    if ($packageName -ieq $rootNorm) { $packageName = '' }
    elseif ($packageName.StartsWith("$rootNorm/", [StringComparison]::OrdinalIgnoreCase)) { $packageName = $packageName.Substring($rootNorm.Length + 1) }
    foreach ($source in @($package.sourcefile | Where-Object { $_ })) {
        $counter = @($source.counter | Where-Object { $_.type -eq 'LINE' })[0]
        [pscustomobject]@{ Key = "$packageName|$($source.name)"; Missed = [int]$counter.missed; Covered = [int]$counter.covered }
    }
}
[string[]] $keys = @($rows | ForEach-Object { $_.Key })
[Array]::Sort($keys, [StringComparer]::Ordinal)
$sha = [Security.Cryptography.SHA256]::Create()
$digest = -join ($sha.ComputeHash([Text.Encoding]::UTF8.GetBytes($keys -join "`n")) | ForEach-Object { $_.ToString('x2') })
$missed = [int]$reportLine.missed; $covered = [int]$reportLine.covered; $total = $missed + $covered
"LINE_MISSED=$missed"; "LINE_COVERED=$covered"; "LINE_TOTAL=$total"
'LINE_PCT={0:F2}' -f $(if ($total -gt 0) { 100.0 * $covered / $total } else { 0 })
"FILES=$($keys.Count)"; "KEYS_SHA256=$digest"
foreach ($row in @($rows | Sort-Object -Property Key)) { "KEY $($row.Key) missed=$($row.Missed) covered=$($row.Covered)" }
```

A file's line percentage is `covered / (missed + covered)` from its `KEY` row. A target file's row is the row whose package part equals, or ends with `/` followed by, the file's repository-relative directory, and whose name part has the file's leaf name.

**CL — changed-line coverage** (args: `RunRoot`, `XmlRelativePath`, `Base`, `RelativeFile`). Added lines come from the hunk headers of the anchored diff; the denominator is the added lines that appear as `<line>` elements (executable lines) in the file's `sourcefile`; covered means `ci` > 0:

```powershell
param([string] $RunRoot, [string] $XmlRelativePath, [string] $Base, [string] $RelativeFile)
$ErrorActionPreference = 'Stop'
$rootPath = (Resolve-Path -LiteralPath $RunRoot).Path
[xml] $report = Get-Content -LiteralPath (Join-Path $rootPath $XmlRelativePath) -Raw
$directory = (Split-Path -Parent $RelativeFile) -replace '\\', '/'
$leaf = Split-Path -Leaf $RelativeFile
$added = [System.Collections.Generic.HashSet[int]]::new()
foreach ($hunk in @(git diff -U0 $Base -- $RelativeFile | Select-String -Pattern '^@@ -\d+(?:,\d+)? \+(\d+)(?:,(\d+))? @@')) {
    $start = [int]$hunk.Matches[0].Groups[1].Value
    $count = if ($hunk.Matches[0].Groups[2].Success) { [int]$hunk.Matches[0].Groups[2].Value } else { 1 }
    for ($number = $start; $number -lt $start + $count; $number++) { [void]$added.Add($number) }
}
$sources = @(foreach ($package in @($report.report.package | Where-Object { $_ })) {
    $packageName = $package.name -replace '\\', '/'
    if ($packageName -ieq $directory -or $packageName.EndsWith("/$directory", [StringComparison]::OrdinalIgnoreCase)) {
        @($package.sourcefile | Where-Object { $_ -and (Split-Path -Leaf $_.name) -eq $leaf })
    }
})
if ($sources.Count -ne 1) { "SOURCEFILE_MATCHES=$($sources.Count)"; exit 2 }
$lines = @($sources[0].line | Where-Object { $_ -and $added.Contains([int]$_.nr) })
$coveredLines = @($lines | Where-Object { [int]$_.ci -gt 0 }).Count
"ADDED_LINES=$($added.Count) CHANGED_EXECUTABLE=$($lines.Count) CHANGED_COVERED=$coveredLines"
'CHANGED_PCT=' + $(if ($lines.Count -gt 0) { '{0:F2}' -f (100.0 * $coveredLines / $lines.Count) } else { 'NA' })
```

**TR — targeted Pester run** (args: `PathList` comma-separated, `RequiredTitleList` separated by `;`, may be empty). Prints `PASSED=<n> FAILED=<n> SKIPPED=<n> MISSING_REQUIRED=<n>` and one `FAILED_TEST <path> :: <message>` line per failure; exits 1 when any test failed or a required title did not pass:

```powershell
param([string] $PathList, [string] $RequiredTitleList)
Import-Module Pester -MinimumVersion 5.6.1
$configuration = New-PesterConfiguration
$configuration.Run.Path = @($PathList -split ',')
$configuration.Run.PassThru = $true
$configuration.Output.Verbosity = 'Normal'
$result = Invoke-Pester -Configuration $configuration
$passedNames = @($result.Passed | ForEach-Object { $_.Name })
$required = @($RequiredTitleList -split ';' | Where-Object { $_ })
$missing = @($required | Where-Object { $_ -notin $passedNames })
"PASSED=$($result.PassedCount) FAILED=$($result.FailedCount) SKIPPED=$($result.SkippedCount) MISSING_REQUIRED=$($missing.Count)"
foreach ($test in $result.Failed) { "FAILED_TEST $($test.ExpandedPath) :: $((@($test.ErrorRecord)[0].Exception.Message) -replace '\s+', ' ')" }
exit ([int]($result.FailedCount -gt 0 -or $missing.Count -gt 0))
```

**FX — fixture coverage check** (args: `RunRoot`). Exits 0 only when `Sample.psm1` is present exactly once with covered LINE > 0:

```powershell
param([string] $RunRoot)
$rootPath = (Resolve-Path -LiteralPath $RunRoot).Path
$rootNorm = ($rootPath -replace '\\', '/').TrimEnd('/')
[xml] $report = Get-Content -LiteralPath (Join-Path $rootPath 'artifacts/pester/powershell-coverage.xml') -Raw
$packages = @($report.report.package | Where-Object { $_ })
$sources = @(foreach ($package in $packages) { @($package.sourcefile | Where-Object { $_ }) })
$sample = @($sources | Where-Object { (Split-Path -Leaf $_.name) -eq 'Sample.psm1' })
$sampleCovered = if ($sample.Count -eq 1) { [int](@($sample[0].counter | Where-Object { $_.type -eq 'LINE' })[0].covered) } else { 0 }
$standIn = @($sources | Where-Object { (Split-Path -Leaf $_.name) -eq 'validate-bash.ps1' })
# Package names are made root-relative before any check, because the fixture root itself can sit
# under a '.claude/worktrees' directory; a name that stays rooted after stripping lies outside the fixture.
$relative = @(foreach ($package in $packages) {
    $name = $package.name -replace '\\', '/'
    if ($name -ieq $rootNorm) { '' }
    elseif ($name.StartsWith("$rootNorm/", [StringComparison]::OrdinalIgnoreCase)) { $name.Substring($rootNorm.Length + 1) }
    else { $name }
})
$claudeKeys = @($relative | Where-Object { $_ -match '(^|/)\.(claude|codex)(/|$)' })
$outside = @($relative | Where-Object { [IO.Path]::IsPathRooted($_) })
"SOURCEFILES=$($sources.Count) SAMPLE_PRESENT=$($sample.Count) SAMPLE_LINE_COVERED=$sampleCovered STANDIN_PRESENT=$($standIn.Count) CLAUDE_KEYS=$($claudeKeys.Count) OUTSIDE_PACKAGES=$($outside.Count)"
exit ([int](-not ($sample.Count -eq 1 -and $sampleCovered -gt 0)))
```

**HS — hash snapshot** (args: `FileList` comma-separated). Prints `<SHA256> <path>` per file: `param([string] $FileList) foreach ($file in @($FileList -split ',')) { '{0} {1}' -f (Get-FileHash -LiteralPath $file -Algorithm SHA256).Hash, $file }`.

**PD — test-purity decision** (args: `FileList`). Prints `CLEAN <path>` or `VIOLATION <path>` using the hook's own decision function (`.claude/hooks/check-powershell-test-purity.ps1` lines 66-134; dot-sourcing is guarded at line 136):

```powershell
param([string] $FileList)
. ./.claude/hooks/check-powershell-test-purity.ps1
foreach ($file in @($FileList -split ',')) {
    $envelope = @{ tool_input = @{ file_path = $file; content = (Get-Content -LiteralPath $file -Raw) } } | ConvertTo-Json -Depth 5 -Compress
    $decision = Invoke-PowerShellTestPurityDecision -ToolInputRaw $envelope
    '{0} {1}' -f $(if ($null -eq $decision) { 'CLEAN' } else { 'VIOLATION' }), $file
}
```

**LL — line count** (args: `FileList`). Prints `<count> <path>` using `(Get-Content -LiteralPath $file).Count`.

**BASE** — the anchor ref for every `git diff` in this plan is the `BASE_SHA:` value recorded by P0-T2, read with `$base = (Select-String -LiteralPath <FEATURE>/evidence/baseline/base-ref.<ts>.md -Pattern '^BASE_SHA: ([0-9a-f]{40})$').Matches[0].Groups[1].Value`. `origin/main` is never used as an anchor.

Observed success-case outputs relied on: the report-level `<counter type="LINE">` and per-`sourcefile` LINE counters, and the `testsuites` attributes `tests`, `failures`, `errors`, and `disabled`, are recorded from real runs in `docs/features/completed/2026-06-16-bump-and-publish-task-191/evidence/baseline/poshqc-test.md` lines 8-12. Package-directory keying follows `docs/features/epics/worktree-scoped-state-resolution/epic.md` lines 311-315. `Invoke-PoshQCFormat` prints `Already formatted: <path>` or `Formatted: <path>` per file (`PoshQC.Analyzer.psm1` lines 60-65). `Invoke-PoshQCAnalyze` prints `PSScriptAnalyzer passed: no findings under <Root>` only on success and otherwise throws `PSScriptAnalyzer reported <n> issue(s).` (lines 181-185). P0-T5 records the package-name shape actually emitted by this machine before any later task relies on it.

### Phase 0 — Policy Reads and Baseline Capture

- [ ] [P0-T1] Read, in this order, `CLAUDE.md`, `.claude/rules/general-code-change.md`, `.claude/rules/general-unit-test.md`, `.claude/rules/quality-tiers.md`, `.claude/rules/powershell.md`, `.claude/rules/python.md`, `.claude/rules/python-suppressions.md`, `.claude/rules/tonality.md`, and `.claude/rules/plan-acceptance-gates.md`, then write `<FEATURE>/evidence/baseline/phase0-instructions-read.<ts>.md` containing `Timestamp:`, `Policy Order:`, and `Files Read:` listing exactly those nine paths.
- [ ] [P0-T2] Record the anchor ref: run `git rev-parse HEAD`, `git rev-parse --abbrev-ref HEAD`, and `git status --porcelain --untracked-files=all`, and write `<FEATURE>/evidence/baseline/base-ref.<ts>.md` with lines `BASE_SHA: <40-hex>`, `BRANCH: <name>`, and the porcelain output. Acceptance: `BRANCH:` equals `bug/poshqc-coverage-denominator-not-reproducible-527` and every porcelain path is under `docs/features/active/2026-08-23-poshqc-coverage-denominator-not-reproducible-527/`; otherwise halt and report.
- [ ] [P0-T3] Run LL with `scripts/powershell/PoshQC/PoshQC.Testing.psm1,scripts/powershell/PoshQC/PoshQC.psm1,tests/scripts/powershell/PoshQC/PoshQC.Comprehensive.Tests.ps1,tests/scripts/powershell/PoshQC/PoshQC.Tests.ps1,tests/scripts/powershell/PoshQC/PoshQC.ScanFolders.Tests.ps1,tests/scripts/powershell/PoshQC/PoshQC.TestingInvokeSummary.Tests.ps1` and write `<FEATURE>/evidence/baseline/line-counts.<ts>.md`. Acceptance: six numeric counts recorded; these values are the baselines P4-T5 and P6-T28 compare against.
- [ ] [P0-T4] Run the baseline full suite with FR args `'.', 'baseline-run.log', '', ''`, then JX args `'.'`, and write `<FEATURE>/evidence/baseline/pwsh-full-suite.<ts>.md` with `Command:` (the FR and JX invocations), `EXIT_CODE:`, and an `Output Summary:` holding the JX line. Acceptance: `EXIT_CODE: 0` and the JX line shows `FAILURES=0 ERRORS=0`; any other result halts execution before Phase 1, because AC-15 would be unsatisfiable for reasons outside this change set.
- [ ] [P0-T5] Run CX args `'.', 'artifacts/pester/powershell-coverage.xml'` against the P0-T4 output and write `<FEATURE>/evidence/baseline/pwsh-coverage-baseline.<ts>.md` containing the full CX output, the raw `name` attribute of the first three `package` elements with the root replaced by `<ROOT>` (package-name shape observation), and in `Output Summary:` the numeric `LINE_PCT`, `LINE_TOTAL`, `FILES`, and the `KEY` row for `scripts/powershell/PoshQC/PoshQC.Testing.psm1`. Acceptance: a numeric `LINE_PCT` and a `FILES` value greater than 0 are recorded (this is the pre-fix allow-list population baseline).
- [ ] [P0-T6] Capture the non-writing format baseline for the five existing `CHANGED_PS` files: `pwsh -NoProfile -Command { $files = @('scripts/powershell/PoshQC/PoshQC.Testing.psm1','scripts/powershell/PoshQC/PoshQC.psm1','scripts/powershell/PoshQC/settings/pester.runsettings.psd1','tests/scripts/powershell/PoshQC/PoshQC.TestingInvokeSummary.Tests.ps1','tests/scripts/powershell/PoshQC/PoshQC.Comprehensive.Tests.ps1'); Import-Module ./scripts/powershell/PoshQC/PoshQC.psd1 -Force; Invoke-PoshQCFormat -Root (Get-Location).Path -GetFileList ({ $files | ForEach-Object { Get-Item -LiteralPath $_ } }.GetNewClosure()) -WriteFile { param([string] $Path, [string] $Content) } *>&1 | ForEach-Object { "$_" } }` and write `<FEATURE>/evidence/baseline/pwsh-format.<ts>.md` recording `WOULD_FORMAT=<count of output lines beginning "Formatted: ">` and those lines with the root replaced by `<ROOT>`. Acceptance: the no-op `-WriteFile` seam guarantees no file changed (HS of the five files before and after is identical and recorded).
- [ ] [P0-T7] Capture the analyzer baseline for `scripts/powershell/PoshQC/PoshQC.Testing.psm1`, `scripts/powershell/PoshQC/PoshQC.psm1`, `tests/scripts/powershell/PoshQC/PoshQC.TestingInvokeSummary.Tests.ps1`, and `tests/scripts/powershell/PoshQC/PoshQC.Comprehensive.Tests.ps1` with `Invoke-PoshQCAnalyze -Root (Get-Location).Path -GetFileList { ... }` (same `-GetFileList` form as P0-T6) in a `pwsh -NoProfile` child, and write `<FEATURE>/evidence/baseline/pwsh-analyze.<ts>.md`. Acceptance: the artifact records either the literal `PSScriptAnalyzer passed: no findings under` or the thrown issue count.
- [ ] [P0-T8] Run TR args `'tests/scripts/powershell/PoshQC', ''` (the ten existing PoshQC test files) and write `<FEATURE>/evidence/baseline/pwsh-poshqc-targeted.<ts>.md`. Acceptance: `EXIT_CODE: 0` and the TR line shows `FAILED=0`.
- [ ] [P0-T9] Run `poetry run black --check tests/scripts/dev_tools/test_poshqc_bundled_parity.py` and write `<FEATURE>/evidence/baseline/python-black.<ts>.md`. Acceptance: exit code and the Black summary line are recorded.
- [ ] [P0-T10] Run `poetry run ruff check tests/scripts/dev_tools/test_poshqc_bundled_parity.py` and write `<FEATURE>/evidence/baseline/python-ruff.<ts>.md`. Acceptance: exit code and summary recorded.
- [ ] [P0-T11] Run `poetry run pyright tests/scripts/dev_tools/test_poshqc_bundled_parity.py` and write `<FEATURE>/evidence/baseline/python-pyright.<ts>.md`. Acceptance: exit code and the `errors, ... warnings` summary line recorded.
- [ ] [P0-T12] Run `poetry run pytest tests/scripts/dev_tools/test_poshqc_bundled_parity.py` and write `<FEATURE>/evidence/baseline/python-pytest-parity.<ts>.md`. Acceptance: exit code and the pytest result line (`1 passed` expected) recorded. Python coverage is not applicable (D11).

### Phase 1 — Consumer Fixture and Ignore Entry

- [ ] [P1-T1] Run Rule BR (reset R1; next batch: production `tests/fixtures/poshqc-consumer/scripts/Sample.psm1`; test `tests/fixtures/poshqc-consumer/tests/scripts/Sample.Tests.ps1`, `tests/fixtures/poshqc-consumer/.claude/hooks/validate-bash.ps1`) and create `<FEATURE>/evidence/other/batch-budget-resets.<ts>.md` with the R1 line.
- [ ] [P1-T2] Create `tests/fixtures/poshqc-consumer/scripts/Sample.psm1` containing a comment-based-help header, one function `Get-SampleGreeting` (`[CmdletBinding()]`, `[OutputType([string])]`, mandatory `[string] $Name`) that returns `"Hello, $Name."`, and `Export-ModuleMember -Function 'Get-SampleGreeting'`. Acceptance: `pwsh -NoProfile -Command { Import-Module ./tests/fixtures/poshqc-consumer/scripts/Sample.psm1 -Force; Get-SampleGreeting -Name 'Ada' }` prints `Hello, Ada.`.
- [ ] [P1-T3] Create `tests/fixtures/poshqc-consumer/tests/scripts/Sample.Tests.ps1` with `BeforeAll { Import-Module (Join-Path $PSScriptRoot '../../scripts/Sample.psm1') -Force }`, `AfterAll { Remove-Module -Name 'Sample' -Force -ErrorAction SilentlyContinue }`, and `Describe 'Get-SampleGreeting'` holding one `It 'returns a greeting for the supplied name'` that asserts `Get-SampleGreeting -Name 'Ada' | Should -Be 'Hello, Ada.'`. Acceptance: TR args `'tests/fixtures/poshqc-consumer/tests/scripts/Sample.Tests.ps1', 'returns a greeting for the supplied name'` prints `PASSED=1 FAILED=0 SKIPPED=0 MISSING_REQUIRED=0`.
- [ ] [P1-T4] Create `tests/fixtures/poshqc-consumer/.claude/hooks/validate-bash.ps1` as a stand-in for a pushed-down drm-copilot hook: a comment-based-help header stating it reproduces the #623 item 1 layout and is never executed by the fixture's tests, and one function `Test-StandInHookPayload` (`[CmdletBinding()]`, `[OutputType([bool])]`, `param()`) returning `$true`, with no top-level statements other than the function definition. Acceptance: `pwsh -NoProfile -Command { . ./tests/fixtures/poshqc-consumer/.claude/hooks/validate-bash.ps1; Test-StandInHookPayload }` prints `True`.
- [ ] [P1-T5] Record the fixture inventory: `pwsh -NoProfile -Command { Get-ChildItem -LiteralPath tests/fixtures/poshqc-consumer -Recurse -File -Force | ForEach-Object { ($_.FullName.Substring((Get-Location).Path.Length + 1)) -replace '\\','/' } | Sort-Object; 'CONFIG_DIR=' + (Test-Path -LiteralPath tests/fixtures/poshqc-consumer/config) }` into `<FEATURE>/evidence/other/fixture-inventory.<ts>.md`, and append the exit code of `git check-ignore -q tests/fixtures/poshqc-consumer/scripts/Sample.psm1 tests/fixtures/poshqc-consumer/tests/scripts/Sample.Tests.ps1 tests/fixtures/poshqc-consumer/.claude/hooks/validate-bash.ps1`. Acceptance: exactly the three paths from P1-T2, P1-T3, P1-T4 are listed, `CONFIG_DIR=False`, and check-ignore exits 1 (none of the three fixture files is ignored, so all three can be committed).
- [ ] [P1-T6] Edit `.gitignore` to insert, directly after line 6 (`/artifacts`), the two lines `# Issue #527: output of the consumer-fixture PoshQC acceptance run.` and `/tests/fixtures/poshqc-consumer/artifacts/`. Acceptance: `git check-ignore -v tests/fixtures/poshqc-consumer/artifacts/pester/pester-junit.xml` exits 0 and prints a line containing `.gitignore:8:/tests/fixtures/poshqc-consumer/artifacts/`; record the command and output in `<FEATURE>/evidence/other/fixture-ignore.<ts>.md`.
- [ ] [P1-T7] Verify LF-only endings for the three fixture files: `pwsh -NoProfile -Command { foreach ($f in 'tests/fixtures/poshqc-consumer/scripts/Sample.psm1','tests/fixtures/poshqc-consumer/tests/scripts/Sample.Tests.ps1','tests/fixtures/poshqc-consumer/.claude/hooks/validate-bash.ps1') { '{0} CR={1}' -f $f, ([IO.File]::ReadAllText((Resolve-Path -LiteralPath $f).Path).Contains("`r")) } }` into `<FEATURE>/evidence/other/fixture-eol.<ts>.md`. Acceptance: all three lines end `CR=False`, so the `* text=auto eol=lf` rule in `.gitattributes` line 1 needs no `-text` exemption.

### Phase 2 — Fail-First Regression Tests

- [ ] [P2-T1] Run Rule BR (reset R2; next batch: test `tests/scripts/powershell/PoshQC/PoshQC.Coverage.Tests.ps1`, `tests/scripts/powershell/PoshQC/PoshQC.CoverageConfig.Tests.ps1`) and append the R2 line to `<FEATURE>/evidence/other/batch-budget-resets.<ts>.md`.
- [ ] [P2-T2] Create `tests/scripts/powershell/PoshQC/PoshQC.Coverage.Tests.ps1` (at most 500 lines; module-collision guard `BeforeAll` copied from `PoshQC.TestingCoveragePruning.Tests.ps1` lines 6-20; D13 rules) with these exact titles:
  - `Describe 'Invoke-PoshQCTest coverage population (issue #527)'`:
    - R1 `It 'measures an identical population for the repository and bundled settings copies over the same workspace'` — default `-SettingsPath` (omitted); injected `-TestPathExists` answers true for any path ending `pester.runsettings.psd1` and otherwise from the fake tree; fake tree files `/cov-root/scripts/a.ps1`, `/cov-root/scripts/b.psm1`, `/cov-root/.claude/hooks/h.ps1`, `/cov-root/config/poshqc-coverage.json` (content `{"version": 1, "roots": ["scripts", ".claude/hooks"]}`); two runs whose `-LoadSettings` tables differ only in `CodeCoverage.Path` (`@('scripts/a.ps1','scripts/b.psm1','.claude/hooks/h.ps1')` versus `@('scripts/a.ps1','.claude/hooks/h.ps1')`), both with `CodeCoverage.Enabled = $true` and `OutputPath = 'artifacts/pester/coverage.xml'`; `-BuildConfiguration` builds the wrapped fake config used by `PoshQC.TestingCoveragePruning.Tests.ps1` lines 54-61; `-ExpandCoveragePaths` is a no-op. Asserts with `Should -Be` that the two captured `CodeCoverage.Path` lists (normalized to forward slashes) are equal, and that the first equals `@('/cov-root/.claude/hooks/h.ps1','/cov-root/scripts/a.ps1','/cov-root/scripts/b.psm1')`.
    - R2 `It 'measures only the consumer production file when a stale bundled allow-list names pushed-down files'` — default `-SettingsPath`; `-LoadSettings` returns `CodeCoverage.Path = @('.claude/hooks/validate-bash.ps1','scripts/dev-tools/run-pester.ps1')` and `Run.Path = @('scripts','tests/powershell','tests/scripts')`; `-ScanFolders @('scripts','tests/scripts')` with `-ResolveScanFolders` joining each folder to the root; fake tree files `/cov-root/scripts/Sample.psm1`, `/cov-root/tests/scripts/Sample.Tests.ps1`, `/cov-root/.claude/hooks/validate-bash.ps1` and no config file. Asserts with `Should -Be` that the captured population is `@('/cov-root/scripts/Sample.psm1')`.
    - R3 `It 'logs the population source and file count before Pester runs'` — the R1 tree and first settings table; the `-InvokePester` seam appends the marker `PESTER-INVOKED` to the captured log list. Asserts the list contains `Code coverage population: source=config; files=3` at an index lower than the marker's index.
    - R4 `It 'resolves a relative Root to an absolute path before building run, coverage, and output paths'` — `Push-Location $PSScriptRoot` in `try`/`finally` with `Pop-Location`; `-Root '.'`; default `-ExpandRunPaths`; `-ResolveCoveragePopulation` returns `Paths = @(Join-Path $RootPath 'scripts/a.ps1')`; `New-Item` mocked. Asserts every captured `Run.Path` entry, every `CodeCoverage.Path` entry, and `CodeCoverage.OutputPath` satisfy `[IO.Path]::IsPathRooted` and start with `$PSScriptRoot` (compared after normalizing separators).
    - R5 `It 'disables coverage, logs once, and still runs Pester when the derived population is empty'` — `-ResolveCoveragePopulation` returns `Source = 'fallback'; Paths = @()`. Asserts captured `CodeCoverage.Enabled` is false, exactly one log line matches `Code coverage disabled for this invocation*`, the `-InvokePester` seam ran, and `-CopyCoverage` did not run.
  - `Describe 'Get-PoshQCCoverageFileSet (issue #527)'`: F1 `It 'returns the same ordinally sorted list for shuffled enumeration order'`; F2 `It 'collapses case-variant duplicates to one entry'`; F3 `It 'collapses files reached through overlapping roots'` (roots `scripts` and `scripts/powershell`); F4 `It 'excludes *.Tests.ps1 files, the root-level tests tree, and default excluded directories'`; F5 `It 'keeps only .ps1 and .psm1 files'`; F6 `It 'skips a nonexistent root with one warning naming the root'`; F7 `It 'returns an empty set when every root is missing'`. Each asserts on the `RelativePath` list with `Should -Be` against a literal expected array.
  - Acceptance: LL on the file prints a count at or under 500, and the file contains the twelve titles above verbatim.
- [ ] [P2-T3] Create `tests/scripts/powershell/PoshQC/PoshQC.CoverageConfig.Tests.ps1` (at most 500 lines; same guard and D13 rules) with these exact titles:
  - `Describe 'Get-PoshQCCoverageConfigRoot (issue #527)'`: C1 `It 'reports the configuration as absent when the file does not exist'`; C2 `It 'returns the validated roots for a version 1 document'`; C3 `It 'fails fast naming config/poshqc-coverage.json for <Case>'` with `-ForEach` over exactly eight cases named `invalid JSON`, `empty content`, `unsupported version`, `missing roots`, `non-array roots`, `blank entry`, `absolute entry`, `parent-traversal entry`, each asserting `Should -Throw -ExpectedMessage '*config/poshqc-coverage.json*'`.
  - `Describe 'Resolve-PoshQCCoveragePopulation precedence (issue #527)'`: P1 `It 'honors a non-empty CodeCoverage.Path from a caller-supplied settings file over the workspace config'`; P2 `It 'prunes and logs each nonexistent caller-supplied settings path'`; P3 `It 'ignores CodeCoverage.Path in the module-default settings file and logs that it was ignored'` (passes `-DefaultSettingsFile` equal to `-SettingsFile`); P4 `It 'uses the workspace config roots over the fallback scan folders'`; P5 `It 'falls back to the scan-folder roots when no workspace config exists'`; P6 `It 'falls back to the settings Run.Path when no scan folders are supplied'`; P7 `It 'returns source config with an empty population when every configured root is missing'`. Each asserts both `Source` and `Paths` with `Should -Be`; seams `-ReadConfig`, `-GetFileSet` (wrapping `Get-PoshQCCoverageFileSet` with fake `-EnumerateFiles` and `-TestPathExists`), `-SettingsPathExists`, `-Logger`, and `-WarningLogger` are injected.
  - Acceptance: LL on the file prints a count at or under 500, and the file contains the eleven titles above verbatim.
- [ ] [P2-T4] [expect-fail] Run TR args `'tests/scripts/powershell/PoshQC/PoshQC.Coverage.Tests.ps1', ''` against the pre-fix code and write `<FEATURE>/evidence/regression-testing/fail-first-coverage-tests.<ts>.md` with `EXIT_CODE: 1`, `ExpectedExitCode: 1`, and every `FAILED_TEST` line. Acceptance: the `FAILED_TEST` lines for R1, R2, and R3 each contain `Expected` and contain neither `CommandNotFoundException` nor `A parameter cannot be found`, which shows the route-independence (AC-02) and consumer (AC-11) tests fail on their assertions and not on missing code.
- [ ] [P2-T5] [expect-fail] Run TR args `'tests/scripts/powershell/PoshQC/PoshQC.CoverageConfig.Tests.ps1', ''` against the pre-fix code and write `<FEATURE>/evidence/regression-testing/fail-first-coverageconfig-tests.<ts>.md` with `EXIT_CODE: 1` and `ExpectedExitCode: 1`. Acceptance: the TR line shows `FAILED=` greater than 0 and `PASSED=0`.
- [ ] [P2-T6] Run the pre-fix consumer fixture with FR args `'tests/fixtures/poshqc-consumer', 'fixture-run.log', '', 'scripts,tests/scripts'`, then JX args `'tests/fixtures/poshqc-consumer'`, and write `<FEATURE>/evidence/regression-testing/fail-first-fixture-run.<ts>.md`. Acceptance: `EXIT_CODE: 0`, the JX line shows `FAILURES=0`, and `tests/fixtures/poshqc-consumer/artifacts/pester/powershell-coverage.xml` exists.
- [ ] [P2-T7] [expect-fail] Run FX args `'tests/fixtures/poshqc-consumer'` against the P2-T6 output and write `<FEATURE>/evidence/regression-testing/fail-first-fixture-check.<ts>.md` with `EXIT_CODE: 1` and `ExpectedExitCode: 1`. Acceptance: the FX line shows `SAMPLE_PRESENT=0` and `STANDIN_PRESENT=1`, reproducing #623 item 1 (the pushed-down stand-in is measured and the consumer's production file is not).

### Phase 3 — Coverage Population Implementation

- [ ] [P3-T1] Run Rule BR (reset R3; next batch: production `scripts/powershell/PoshQC/PoshQC.Coverage.psm1`, `scripts/powershell/PoshQC/PoshQC.psm1`, `scripts/powershell/PoshQC/PoshQC.Testing.psm1`) and append the R3 line to `<FEATURE>/evidence/other/batch-budget-resets.<ts>.md`.
- [ ] [P3-T2] Create `scripts/powershell/PoshQC/PoshQC.Coverage.psm1` implementing the four D1 functions with the D2 precedence and D4 log literals, comment-based help on each function, `[CmdletBinding()]` and `[OutputType()]` attributes, and no top-level statements other than function definitions. Acceptance: `pwsh -NoProfile -Command { $errors = $null; [void][System.Management.Automation.Language.Parser]::ParseFile((Resolve-Path scripts/powershell/PoshQC/PoshQC.Coverage.psm1).Path, [ref]$null, [ref]$errors); "PARSE_ERRORS=$($errors.Count)" }` prints `PARSE_ERRORS=0`.
- [ ] [P3-T3] Edit `scripts/powershell/PoshQC/PoshQC.psm1` to add `'PoshQC.Coverage.psm1',` to the sub-module list at lines 113-118, directly after `'PoshQC.ScanConfig.psm1',`, leaving `Export-ModuleMember` (lines 136-146) unchanged. Acceptance: `@(Select-String -LiteralPath scripts/powershell/PoshQC/PoshQC.psm1 -SimpleMatch -Pattern "'PoshQC.Coverage.psm1',").Count` returns 1.
- [ ] [P3-T4] Edit `scripts/powershell/PoshQC/PoshQC.Testing.psm1` to apply D3 (a), (b), and (c) exactly. Acceptance: LL on the file prints a count at or under 500; `@(Select-String -LiteralPath scripts/powershell/PoshQC/PoshQC.Testing.psm1 -SimpleMatch -Pattern 'ResolveCoveragePopulation').Count` is at least 3; and `@(Select-String -LiteralPath scripts/powershell/PoshQC/PoshQC.Testing.psm1 -SimpleMatch -Pattern 'Code coverage population: source=').Count` returns 1.
- [ ] [P3-T5] Run Rule BR (reset R4; next batch: production `scripts/powershell/PoshQC/settings/pester.runsettings.psd1`) and append the R4 line to `<FEATURE>/evidence/other/batch-budget-resets.<ts>.md`.
- [ ] [P3-T6] Edit `scripts/powershell/PoshQC/settings/pester.runsettings.psd1` to apply D5: delete the `Path = @( ... )` array and its comment lines (current lines 23-325) and add the two D5 comment lines inside `CodeCoverage`. Acceptance: `pwsh -NoProfile -Command { $c = (Import-PowerShellDataFile scripts/powershell/PoshQC/settings/pester.runsettings.psd1).CodeCoverage; 'HAS_PATH=' + $c.ContainsKey('Path'); 'KEYS=' + ((@($c.Keys) | Sort-Object) -join ',') }` prints `HAS_PATH=False` and `KEYS=CoveragePercentTarget,Enabled,OutputFormat,OutputPath`.
- [ ] [P3-T7] Create `config/poshqc-coverage.json` with the exact D6 content. Acceptance: `pwsh -NoProfile -Command { $j = Get-Content -LiteralPath config/poshqc-coverage.json -Raw | ConvertFrom-Json; "VERSION=$($j.version) ROOTS=$(@($j.roots) -join ',')" }` prints `VERSION=1 ROOTS=.claude/hooks,.claude/lib,.codex/hooks,.codex/scripts,scripts`.
- [ ] [P3-T8] Verify the module surface in a fresh process: `pwsh -NoProfile -Command { Import-Module ./scripts/powershell/PoshQC/PoshQC.psd1 -Force; $m = Get-Module PoshQC; $internal = 'Get-PoshQCSettingsList','Get-PoshQCCoverageConfigRoot','Get-PoshQCCoverageFileSet','Resolve-PoshQCCoveragePopulation'; 'EXPORTED=' + @($internal | Where-Object { $_ -in $m.ExportedFunctions.Keys }).Count; 'DEFINED=' + @(& $m { param($names) $names | Where-Object { Get-Command -Name $_ -CommandType Function -ErrorAction SilentlyContinue } } $internal).Count }` and write `<FEATURE>/evidence/other/module-surface.<ts>.md`. Acceptance: output is `EXPORTED=0` and `DEFINED=4`.

### Phase 4 — Existing-Test Adaptation and Targeted Verification

- [ ] [P4-T1] Run TR args `'tests/scripts/powershell/PoshQC/PoshQC.Coverage.Tests.ps1,tests/scripts/powershell/PoshQC/PoshQC.CoverageConfig.Tests.ps1', '<the 23 distinct titles from P2-T2 and P2-T3 joined by ;>'` (the executor substitutes the verbatim titles; the C3 entry is the unexpanded template title) and write `<FEATURE>/evidence/regression-testing/pass-after-new-tests.<ts>.md` with `EXIT_CODE: 0`. Acceptance: the TR line shows `FAILED=0 MISSING_REQUIRED=0` and a `PASSED=` value of at least 29 (12 nodes plus 17 nodes, the C3 row counting eight; tests added later to reach coverage raise the count). Fixes needed to reach this state are made in `scripts/powershell/PoshQC/PoshQC.Coverage.psm1` or `scripts/powershell/PoshQC/PoshQC.Testing.psm1` (implementation defects) or in the two new test files (test defects), following the batch-budget remediation rule; assertions are not weakened.
- [ ] [P4-T2] Run TR args `'tests/scripts/powershell/PoshQC/Get-PoshQCFileList.Excludes.Tests.ps1,tests/scripts/powershell/PoshQC/PoshQC.Comprehensive.Tests.ps1,tests/scripts/powershell/PoshQC/PoshQC.EntryPoints.Tests.ps1,tests/scripts/powershell/PoshQC/PoshQC.ScanConfig.Tests.ps1,tests/scripts/powershell/PoshQC/PoshQC.ScanFolders.Tests.ps1,tests/scripts/powershell/PoshQC/PoshQC.TestingCoveragePruning.Tests.ps1,tests/scripts/powershell/PoshQC/PoshQC.TestingInvokeConfigPaths.Tests.ps1,tests/scripts/powershell/PoshQC/PoshQC.TestingInvokeSummary.Tests.ps1,tests/scripts/powershell/PoshQC/PoshQC.TestingSeamDefaults.Tests.ps1,tests/scripts/powershell/PoshQC/PoshQC.Tests.ps1', ''` before any adaptation and write `<FEATURE>/evidence/other/existing-tests-pre-adaptation.<ts>.md`. Acceptance: every `FAILED_TEST` line names one of the four D14 tests; a failure of any other test halts execution for a plan revision rather than an unplanned test edit.
- [ ] [P4-T3] Run Rule BR (reset R5; next batch: test `tests/scripts/powershell/PoshQC/PoshQC.TestingInvokeSummary.Tests.ps1`, `tests/scripts/powershell/PoshQC/PoshQC.Comprehensive.Tests.ps1`) and append the R5 line to `<FEATURE>/evidence/other/batch-budget-resets.<ts>.md`.
- [ ] [P4-T4] Edit `tests/scripts/powershell/PoshQC/PoshQC.TestingInvokeSummary.Tests.ps1`: in the two D14 tests (lines 60-98 and 100-140) add `-ResolveCoveragePopulation { [pscustomobject]@{ Source = 'config'; Paths = @('/summary-root/scripts/sample.ps1') } }` to the `Invoke-PoshQCTest` call, and in the second test change `$fixedMessageCount = 4` to `$fixedMessageCount = 5` with its comment stating that the four fixed summary lines plus the population line precede the replayed coverage line. Acceptance: TR args `'tests/scripts/powershell/PoshQC/PoshQC.TestingInvokeSummary.Tests.ps1', ''` prints `FAILED=0`.
- [ ] [P4-T5] Edit `tests/scripts/powershell/PoshQC/PoshQC.Comprehensive.Tests.ps1` line-neutrally: replace line 621 and line 745 (`# Run path check`) with `# Run path check; the coverage source entry must also exist (issue #527)` and replace line 622 and line 746 (`if ($Path -eq "$testRoot/tests") {`) with `if ($Path -eq "$testRoot/tests" -or $Path -like '*src*') {`, keeping indentation. Acceptance: LL on the file equals the P0-T3 baseline count, and TR args `'tests/scripts/powershell/PoshQC/PoshQC.Comprehensive.Tests.ps1', 'Should generate Koverage copy by default when coverage is enabled;Should use custom KoverageOutputPath when provided'` prints `FAILED=0 MISSING_REQUIRED=0`.
- [ ] [P4-T6] Run TR args `'tests/scripts/powershell/PoshQC', ''` (all twelve PoshQC test files) and write `<FEATURE>/evidence/regression-testing/pass-after-poshqc-targeted.<ts>.md` with `EXIT_CODE: 0`. Acceptance: the TR line shows `FAILED=0`.

### Phase 5 — Documentation, Bundled Mirror, Parity List, and Potential-Entry Disposition

- [ ] [P5-T1] Edit `scripts/powershell/PoshQC/README.md` `## Configuration` section: replace the stale line 68 (coverage over `scripts/dev-tools/*.ps1`, `scripts/powershell/**/*.psm1`, `src/**/*.ps1`) with text stating that the shipped runsettings carry no `CodeCoverage.Path`, and add a `Coverage population` bullet documenting `config/poshqc-coverage.json` (schema `{"version": 1, "roots": [...]}` and its fail-fast validation), the D2 precedence with the three source names `settings`, `config`, `fallback` (including that a list in the module's own settings file is ignored and logged), the built-in exclusions (`*.Tests.ps1`, a first root-relative segment `tests`, `DefaultExcludedDirs` segments), the fallback order (explicit `-ScanFolders`, else `config/poshqc-scan.json`, else settings `Run.Path`), the empty-population disable, and the `Code coverage population: source=<source>; files=<count>` log line; extend line 80 to say coverage roots are declared in `config/poshqc-coverage.json`. Acceptance: in the file, `Select-String -SimpleMatch` counts are at least 1 for each of `poshqc-coverage.json`, `fallback`, `*.Tests.ps1`, `DefaultExcludedDirs`, `source=`, and 0 for `src/**/*.ps1`.
- [ ] [P5-T2] Create the mirror `extensions/drm-copilot/resources/powershell/PoshQC/PoshQC.Coverage.psm1` with `pwsh -NoProfile -Command { Copy-Item -LiteralPath scripts/powershell/PoshQC/PoshQC.Coverage.psm1 -Destination extensions/drm-copilot/resources/powershell/PoshQC/PoshQC.Coverage.psm1 -Force }`, then run HS on both paths and create `<FEATURE>/evidence/other/mirror-copy.<ts>.md` with the pair. Acceptance: the two SHA256 values are equal.
- [ ] [P5-T3] Update the mirror `extensions/drm-copilot/resources/powershell/PoshQC/PoshQC.Testing.psm1` by `Copy-Item -LiteralPath scripts/powershell/PoshQC/PoshQC.Testing.psm1 -Destination extensions/drm-copilot/resources/powershell/PoshQC/PoshQC.Testing.psm1 -Force` in a `pwsh -NoProfile` child, run HS on both paths, and append the pair to `<FEATURE>/evidence/other/mirror-copy.<ts>.md`. Acceptance: the two SHA256 values are equal.
- [ ] [P5-T4] Update the mirror `extensions/drm-copilot/resources/powershell/PoshQC/PoshQC.psm1` by `Copy-Item -LiteralPath scripts/powershell/PoshQC/PoshQC.psm1 -Destination extensions/drm-copilot/resources/powershell/PoshQC/PoshQC.psm1 -Force` in a `pwsh -NoProfile` child, run HS on both paths, and append the pair to `<FEATURE>/evidence/other/mirror-copy.<ts>.md`. Acceptance: the two SHA256 values are equal.
- [ ] [P5-T5] Update the mirror `extensions/drm-copilot/resources/powershell/PoshQC/settings/pester.runsettings.psd1` by `Copy-Item -LiteralPath scripts/powershell/PoshQC/settings/pester.runsettings.psd1 -Destination extensions/drm-copilot/resources/powershell/PoshQC/settings/pester.runsettings.psd1 -Force` in a `pwsh -NoProfile` child, run HS on both paths, and append the pair to `<FEATURE>/evidence/other/mirror-copy.<ts>.md`. Acceptance: the two SHA256 values are equal.
- [ ] [P5-T6] Update the mirror `extensions/drm-copilot/resources/powershell/PoshQC/README.md` by `Copy-Item -LiteralPath scripts/powershell/PoshQC/README.md -Destination extensions/drm-copilot/resources/powershell/PoshQC/README.md -Force` in a `pwsh -NoProfile` child, run HS on both paths, and append the pair to `<FEATURE>/evidence/other/mirror-copy.<ts>.md`. Acceptance: the two SHA256 values are equal.
- [ ] [P5-T7] Verify both manifests are unchanged: `git diff --exit-code $base -- scripts/powershell/PoshQC/PoshQC.psd1 extensions/drm-copilot/resources/powershell/PoshQC/PoshQC.psd1` (with `$base` per the BASE rule) together with `git status --porcelain -- scripts/powershell/PoshQC/PoshQC.psd1 extensions/drm-copilot/resources/powershell/PoshQC/PoshQC.psd1`, recorded in `<FEATURE>/evidence/other/manifest-unchanged.<ts>.md`. Acceptance: the diff exits 0 and the porcelain output is empty.
- [ ] [P5-T8] Edit `tests/scripts/dev_tools/test_poshqc_bundled_parity.py` to add the tuple entry `"scripts/powershell/PoshQC/PoshQC.Coverage.psm1",` to `POSHQC_PARITY_PATHS` directly after the `PoshQC.ScanConfig.psm1` entry (line 14). Acceptance: `@(Select-String -LiteralPath tests/scripts/dev_tools/test_poshqc_bundled_parity.py -SimpleMatch -Pattern '"scripts/powershell/PoshQC/PoshQC.Coverage.psm1",').Count` returns 1.
- [ ] [P5-T9] Run `poetry run pytest tests/scripts/dev_tools/test_poshqc_bundled_parity.py` and write `<FEATURE>/evidence/regression-testing/parity-after-mirror.<ts>.md`. Acceptance: exit code 0 and the result line `1 passed`.
- [ ] [P5-T10] Edit `docs/features/potential/2026-08-19-mcp-poshqc-test-ignores-repo-runsettings-coverage.md` per D9: change line 5 to `- Status: Superseded by #527` and add a `## Disposition` section stating that issue #527 (`docs/features/active/2026-08-23-poshqc-coverage-denominator-not-reproducible-527/`) makes the coverage population workspace-derived and removes the shipped `CodeCoverage.Path` lists, that the MCP route shows the change after the next extension and MCP package release, and that this entry is not promoted separately. Acceptance: `Select-String -SimpleMatch` counts for `Superseded by #527` and `## Disposition` in the file are each at least 1.

### Phase 6 — Final QA Loop, Acceptance Evidence, and AC Check-off

Loop rule: P6-T1 through P6-T23 form the toolchain loop (format, analyze, test with coverage, Python format, lint, type-check, test). If any of them fails or changes a file, fix the cause (applying the batch-budget remediation rule), re-copy any changed mirror with the matching P5 command, and restart from P6-T1. Runs A, B, and C (P6-T4 to P6-T10) must execute with no file edits between them.

- [ ] [P6-T1] Format `CHANGED_PS` in write mode: record HS over the eleven `CHANGED_PS` paths, run `pwsh -NoProfile -Command { $files = @(<the eleven CHANGED_PS paths>); Import-Module ./scripts/powershell/PoshQC/PoshQC.psd1 -Force; Invoke-PoshQCFormat -Root (Get-Location).Path -GetFileList ({ $files | ForEach-Object { Get-Item -LiteralPath $_ } }.GetNewClosure()) *>&1 | ForEach-Object { "$_" } }`, record HS again, and write `<FEATURE>/evidence/qa-gates/final-pwsh-format.<ts>.md`. Acceptance (clean pass): the output has eleven lines beginning `Already formatted: `, zero lines beginning `Formatted: `, and the two HS listings are identical; a pass that prints any `Formatted: ` line triggers the loop rule.
- [ ] [P6-T2] Run HS on the six mirror pairs (`scripts/powershell/PoshQC/` versus `extensions/drm-copilot/resources/powershell/PoshQC/` for `PoshQC.Coverage.psm1`, `PoshQC.Testing.psm1`, `PoshQC.psm1`, `PoshQC.psd1`, `settings/pester.runsettings.psd1`, `README.md`) and write `<FEATURE>/evidence/qa-gates/final-mirror-parity.<ts>.md`. Acceptance: all six pairs have equal SHA256 values.
- [ ] [P6-T3] Analyze the nine `.ps1`/`.psm1` files of `CHANGED_PS` with `Invoke-PoshQCAnalyze -Root (Get-Location).Path -GetFileList { ... }` (same form as P6-T1) in a `pwsh -NoProfile` child and write `<FEATURE>/evidence/qa-gates/final-pwsh-analyze.<ts>.md`. Acceptance: `EXIT_CODE: 0` and the output contains `PSScriptAnalyzer passed: no findings under`.
- [ ] [P6-T4] Run A: FR args `'.', 'final-run-a.log', '', ''`, then JX args `'.'`, then `Copy-Item -LiteralPath artifacts/pester/powershell-coverage.xml -Destination artifacts/pester/final-run-a-coverage.xml -Force`, and write `<FEATURE>/evidence/qa-gates/final-pwsh-test-run-a.<ts>.md` including the line of `artifacts/pester/final-run-a.log` that begins `Code coverage population:`. Acceptance: `EXIT_CODE: 0` and the JX line shows `FAILURES=0 ERRORS=0` (AC-15).
- [ ] [P6-T5] Run CX args `'.', 'artifacts/pester/final-run-a-coverage.xml'` and write `<FEATURE>/evidence/qa-gates/final-pwsh-coverage-run-a.<ts>.md` with the full CX output. Acceptance: numeric `LINE_PCT`, `LINE_TOTAL`, `FILES`, and `KEYS_SHA256` values are recorded.
- [ ] [P6-T6] Verify the fail-first tests now pass in run A: `pwsh -NoProfile -Command { [xml] $j = Get-Content -LiteralPath artifacts/pester/pester-junit.xml -Raw; foreach ($t in 'measures an identical population for the repository and bundled settings copies over the same workspace','measures only the consumer production file when a stale bundled allow-list names pushed-down files','logs the population source and file count before Pester runs') { $cases = @($j.SelectNodes('//testcase') | Where-Object { $_.name -like "*$t*" }); '{0} CASES={1} FAILED={2}' -f $t, $cases.Count, @($cases | Where-Object { $_.SelectSingleNode('failure') }).Count } }` and write `<FEATURE>/evidence/regression-testing/pass-after-named-tests.<ts>.md`. Acceptance: each of the three lines shows `CASES=1 FAILED=0`.
- [ ] [P6-T7] Run B: FR args `'.', 'final-run-b.log', '', ''`, then JX args `'.'`, and write `<FEATURE>/evidence/qa-gates/final-pwsh-test-run-b.<ts>.md`. Acceptance: `artifacts/pester/powershell-coverage.xml` and `artifacts/pester/pester-junit.xml` exist after the run (FR deletes both first) and the JX line is recorded.
- [ ] [P6-T8] Run CX args `'.', 'artifacts/pester/powershell-coverage.xml'` on run B's output and write `<FEATURE>/evidence/qa-gates/final-pwsh-coverage-run-b.<ts>.md`. Acceptance: numeric `LINE_TOTAL`, `FILES`, and `KEYS_SHA256` values are recorded.
- [ ] [P6-T9] Run C from a different current directory with the same absolute root: FR args `'.', 'final-run-c.log', 'artifacts', ''` (the child sets its location to the git-ignored `artifacts` directory before calling `Invoke-PoshQCTest -Root <repository root>`), then JX args `'.'`, and write `<FEATURE>/evidence/qa-gates/final-pwsh-test-run-c.<ts>.md`. Acceptance: both output XML files exist after the run; `EXIT_CODE` and the JX line are recorded, and any failure in run C is recorded as a follow-up item (tests depending on the current directory) rather than gating AC-15, which run A gates.
- [ ] [P6-T10] Run CX args `'.', 'artifacts/pester/powershell-coverage.xml'` on run C's output and write `<FEATURE>/evidence/qa-gates/final-pwsh-coverage-run-c.<ts>.md`. Acceptance: numeric `LINE_TOTAL`, `FILES`, and `KEYS_SHA256` values are recorded.
- [ ] [P6-T11] Compare runs A, B, and C and write `<FEATURE>/evidence/qa-gates/determinism-comparison.<ts>.md` listing each run's `LINE_TOTAL`, `FILES`, and `KEYS_SHA256` from the P6-T5, P6-T8, and P6-T10 artifacts. Acceptance (AC-01): the three `KEYS_SHA256` values are identical and the three `LINE_TOTAL` values are identical.
- [ ] [P6-T12] Read the population line from `artifacts/pester/final-run-a.log` and `artifacts/pester/final-run-c.log` with `Select-String -SimpleMatch -Pattern 'Code coverage population: source=config; files='` and write `<FEATURE>/evidence/qa-gates/population-source.<ts>.md`. Acceptance (AC-05, AC-10): each log has exactly one matching line.
- [ ] [P6-T13] Compute new and changed code coverage from run A and write `<FEATURE>/evidence/qa-gates/coverage-new-code.<ts>.md`: the `KEY` row for `scripts/powershell/PoshQC/PoshQC.Coverage.psm1` from P6-T5 with its percentage, and CL args `'.', 'artifacts/pester/final-run-a-coverage.xml', $base, 'scripts/powershell/PoshQC/PoshQC.Testing.psm1'` and `'.', 'artifacts/pester/final-run-a-coverage.xml', $base, 'scripts/powershell/PoshQC/PoshQC.psm1'`. Acceptance (AC-14): the `PoshQC.Coverage.psm1` percentage is at least 85.00; each CL run prints `CHANGED_PCT=` at least 85.00, or `CHANGED_PCT=NA` with `CHANGED_EXECUTABLE=0` (no executable changed line).
- [ ] [P6-T14] Record the aggregate and the baseline delta in `<FEATURE>/evidence/qa-gates/coverage-aggregate.<ts>.md`: baseline `LINE_PCT`, `LINE_TOTAL`, `FILES` (P0-T5) versus run A (P6-T5), the baseline and run A percentages of `scripts/powershell/PoshQC/PoshQC.Testing.psm1`, and, when run A `LINE_PCT` is below 85.00, a `Follow-up item:` section listing every run A `KEY` row below 85.00 sorted by `missed` descending. Acceptance: all numeric values are present, and the follow-up section exists exactly when the aggregate is below 85.00 (evidence only, not a gate; no production file is excluded and no root is narrowed).
- [ ] [P6-T15] Before the post-fix fixture run, record `git status --porcelain --untracked-files=all -- . ':(exclude)docs/features/active/2026-08-23-poshqc-coverage-denominator-not-reproducible-527'` in `<FEATURE>/evidence/qa-gates/fixture-hygiene.<ts>.md` under a `Before:` heading. The feature folder is excluded because evidence files and plan checkbox updates are written there between the two snapshots. Acceptance: the snapshot is recorded.
- [ ] [P6-T16] Run the post-fix consumer fixture with FR args `'tests/fixtures/poshqc-consumer', 'fixture-run.log', '', 'scripts,tests/scripts'`, then JX args `'tests/fixtures/poshqc-consumer'`, and write `<FEATURE>/evidence/regression-testing/pass-after-fixture-run.<ts>.md` including the `Code coverage population:` line from `tests/fixtures/poshqc-consumer/artifacts/pester/fixture-run.log`. Acceptance: `EXIT_CODE: 0`, the JX line shows `FAILURES=0`, and the population line is `Code coverage population: source=fallback; files=1`.
- [ ] [P6-T17] Run FX args `'tests/fixtures/poshqc-consumer'` and write `<FEATURE>/evidence/regression-testing/pass-after-fixture-check.<ts>.md`. Acceptance (AC-11): `EXIT_CODE: 0`, and the FX line shows `SAMPLE_PRESENT=1` with `SAMPLE_LINE_COVERED=` greater than 0.
- [ ] [P6-T18] Re-run FX args `'tests/fixtures/poshqc-consumer'` and write `<FEATURE>/evidence/qa-gates/fixture-isolation.<ts>.md`. Acceptance (AC-12): the FX line shows `SOURCEFILES=1`, `STANDIN_PRESENT=0`, `CLAUDE_KEYS=0`, and `OUTSIDE_PACKAGES=0`.
- [ ] [P6-T19] After the fixture run, append the P6-T15 command's output (same pathspec exclusion) under an `After:` heading to `<FEATURE>/evidence/qa-gates/fixture-hygiene.<ts>.md`, together with `git check-ignore -v tests/fixtures/poshqc-consumer/artifacts/pester/powershell-coverage.xml`. Acceptance (AC-13): the `Before:` and `After:` listings are identical, and check-ignore exits 0.
- [ ] [P6-T20] Run `poetry run black tests/scripts/dev_tools/test_poshqc_bundled_parity.py` and write `<FEATURE>/evidence/qa-gates/final-python-black.<ts>.md`. Acceptance: exit code 0 and the output contains `1 file left unchanged.`; output containing `reformatted` triggers the loop rule.
- [ ] [P6-T21] Run `poetry run ruff check tests/scripts/dev_tools/test_poshqc_bundled_parity.py` and write `<FEATURE>/evidence/qa-gates/final-python-ruff.<ts>.md`. Acceptance: exit code 0 and output `All checks passed!`.
- [ ] [P6-T22] Run `poetry run pyright tests/scripts/dev_tools/test_poshqc_bundled_parity.py` and write `<FEATURE>/evidence/qa-gates/final-python-pyright.<ts>.md`. Acceptance: exit code 0 and output containing `0 errors`.
- [ ] [P6-T23] Run `poetry run pytest tests/scripts/dev_tools/test_poshqc_bundled_parity.py` and write `<FEATURE>/evidence/qa-gates/final-python-pytest-parity.<ts>.md`, stating that Python coverage is not applicable (D11) and that mandatory-loop stages 4, 6, and 7 have no configured tooling for this module (D12). Acceptance (AC-09): exit code 0 and the result line `1 passed`.
- [ ] [P6-T24] Verify both runsettings copies with the P3-T6 acceptance command applied to `scripts/powershell/PoshQC/settings/pester.runsettings.psd1` and to `extensions/drm-copilot/resources/powershell/PoshQC/settings/pester.runsettings.psd1`, and write `<FEATURE>/evidence/qa-gates/runsettings-shape.<ts>.md`. Acceptance (AC-08): both print `HAS_PATH=False` and `KEYS=CoveragePercentTarget,Enabled,OutputFormat,OutputPath`.
- [ ] [P6-T25] Re-run the P3-T7 acceptance command on `config/poshqc-coverage.json` and write `<FEATURE>/evidence/qa-gates/coverage-config.<ts>.md`. Acceptance (AC-10): output `VERSION=1 ROOTS=.claude/hooks,.claude/lib,.codex/hooks,.codex/scripts,scripts`.
- [ ] [P6-T26] Re-run the P5-T1 token counts on `scripts/powershell/PoshQC/README.md` and on `extensions/drm-copilot/resources/powershell/PoshQC/README.md` and write `<FEATURE>/evidence/qa-gates/readme-documentation.<ts>.md`. Acceptance (AC-16): for both files, counts are at least 1 for `poshqc-coverage.json`, `fallback`, `*.Tests.ps1`, `DefaultExcludedDirs`, `source=`, and 0 for `src/**/*.ps1`.
- [ ] [P6-T27] Run PD args `'tests/scripts/powershell/PoshQC/PoshQC.Coverage.Tests.ps1,tests/scripts/powershell/PoshQC/PoshQC.CoverageConfig.Tests.ps1,tests/scripts/powershell/PoshQC/PoshQC.TestingInvokeSummary.Tests.ps1,tests/scripts/powershell/PoshQC/PoshQC.Comprehensive.Tests.ps1,tests/fixtures/poshqc-consumer/tests/scripts/Sample.Tests.ps1,tests/fixtures/poshqc-consumer/.claude/hooks/validate-bash.ps1'` and `@(Select-String -LiteralPath <the same six paths> -SimpleMatch -Pattern 'TestDrive','New-TemporaryFile','GetTempFileName','GetTempPath','$env:TEMP','$env:TMP').Count`, and write `<FEATURE>/evidence/qa-gates/test-purity.<ts>.md`. Acceptance (AC-17): six `CLEAN` lines and a match count of 0.
- [ ] [P6-T28] Run LL on `scripts/powershell/PoshQC/PoshQC.Testing.psm1`, `scripts/powershell/PoshQC/PoshQC.Coverage.psm1`, `tests/scripts/powershell/PoshQC/PoshQC.Coverage.Tests.ps1`, `tests/scripts/powershell/PoshQC/PoshQC.CoverageConfig.Tests.ps1`, `tests/scripts/powershell/PoshQC/PoshQC.TestingInvokeSummary.Tests.ps1`, `tests/fixtures/poshqc-consumer/scripts/Sample.psm1`, `tests/fixtures/poshqc-consumer/tests/scripts/Sample.Tests.ps1`, `tests/fixtures/poshqc-consumer/.claude/hooks/validate-bash.ps1`, and `tests/scripts/powershell/PoshQC/PoshQC.Comprehensive.Tests.ps1`, and write `<FEATURE>/evidence/qa-gates/line-limits.<ts>.md`. Acceptance (AC-18): the first eight counts are at most 500 and the Comprehensive count is at most its P0-T3 baseline.
- [ ] [P6-T29] Re-run the P5-T10 token counts on `docs/features/potential/2026-08-19-mcp-poshqc-test-ignores-repo-runsettings-coverage.md` and write `<FEATURE>/evidence/qa-gates/potential-entry-disposition.<ts>.md`. Acceptance: both counts are at least 1.
- [ ] [P6-T30] Verify the change stays inside the write set: run `git diff --name-only $base` and `git status --porcelain --untracked-files=all`, and write `<FEATURE>/evidence/qa-gates/scope-check.<ts>.md` listing the union of paths. Acceptance: every listed path is a row of the Complete Write Set table (evidence files match row 24, files under `<FEATURE>/` other than evidence match rows 22 and 23 or pre-existed per P0-T2); any other path fails the task.
- [ ] [P6-T31] Check off AC-01 in `docs/features/active/2026-08-23-poshqc-coverage-denominator-not-reproducible-527/spec.md` after P6-T11 passes. Acceptance: `@(Select-String -LiteralPath docs/features/active/2026-08-23-poshqc-coverage-denominator-not-reproducible-527/spec.md -SimpleMatch -Pattern '- [x] Deterministic derivation:').Count` returns 1.
- [ ] [P6-T32] Check off AC-02 in `docs/features/active/2026-08-23-poshqc-coverage-denominator-not-reproducible-527/spec.md` after P2-T4, P4-T1, and P6-T6 pass. Acceptance: the `Select-String -SimpleMatch` count of `- [x] Route independence:` in that file returns 1.
- [ ] [P6-T33] Check off AC-03 in `docs/features/active/2026-08-23-poshqc-coverage-denominator-not-reproducible-527/spec.md` after P4-T1 passes (F1 to F7, P4, P5). Acceptance: the count of `- [x] Derived population contents:` in that file returns 1.
- [ ] [P6-T34] Check off AC-04 in `docs/features/active/2026-08-23-poshqc-coverage-denominator-not-reproducible-527/spec.md` after P4-T1 passes (P1 to P6). Acceptance: the count of `- [x] Precedence order:` in that file returns 1.
- [ ] [P6-T35] Check off AC-05 in `docs/features/active/2026-08-23-poshqc-coverage-denominator-not-reproducible-527/spec.md` after P4-T1 (R3) and P6-T12 pass. Acceptance: the count of `- [x] Observability:` in that file returns 1.
- [ ] [P6-T36] Check off AC-06 in `docs/features/active/2026-08-23-poshqc-coverage-denominator-not-reproducible-527/spec.md` after P4-T1 passes (C1 to C3, F6, F7, P7, R5). Acceptance: the count of `- [x] Config validation:` in that file returns 1.
- [ ] [P6-T37] Check off AC-07 in `docs/features/active/2026-08-23-poshqc-coverage-denominator-not-reproducible-527/spec.md` after P4-T1 passes (R4). Acceptance: the count of `- [x] Absolute root:` in that file returns 1.
- [ ] [P6-T38] Check off AC-08 in `docs/features/active/2026-08-23-poshqc-coverage-denominator-not-reproducible-527/spec.md` after P6-T24 passes. Acceptance: the count of `- [x] Allow-list removed:` in that file returns 1.
- [ ] [P6-T39] Check off AC-09 in `docs/features/active/2026-08-23-poshqc-coverage-denominator-not-reproducible-527/spec.md` after P6-T2 and P6-T23 pass. Acceptance: the count of `- [x] Parity preserved:` in that file returns 1.
- [ ] [P6-T40] Check off AC-10 in `docs/features/active/2026-08-23-poshqc-coverage-denominator-not-reproducible-527/spec.md` after P6-T12 and P6-T25 pass. Acceptance: the count of ``- [x] `config/poshqc-coverage.json` exists with`` in that file returns 1.
- [ ] [P6-T41] Check off AC-11 in `docs/features/active/2026-08-23-poshqc-coverage-denominator-not-reproducible-527/spec.md` after P2-T7 and P6-T17 pass. Acceptance: the count of `- [x] Consumer fixture coverage:` in that file returns 1.
- [ ] [P6-T42] Check off AC-12 in `docs/features/active/2026-08-23-poshqc-coverage-denominator-not-reproducible-527/spec.md` after P6-T18 passes. Acceptance: the count of `- [x] Consumer isolation:` in that file returns 1.
- [ ] [P6-T43] Check off AC-13 in `docs/features/active/2026-08-23-poshqc-coverage-denominator-not-reproducible-527/spec.md` after P6-T19 passes. Acceptance: the count of `- [x] Fixture output hygiene:` in that file returns 1.
- [ ] [P6-T44] Check off AC-14 in `docs/features/active/2026-08-23-poshqc-coverage-denominator-not-reproducible-527/spec.md` after P6-T13 and P6-T14 pass. Acceptance: the count of `- [x] New code coverage:` in that file returns 1.
- [ ] [P6-T45] Check off AC-15 in `docs/features/active/2026-08-23-poshqc-coverage-denominator-not-reproducible-527/spec.md` after P6-T1, P6-T3, and P6-T4 pass. Acceptance: the count of `- [x] Existing suite:` in that file returns 1.
- [ ] [P6-T46] Check off AC-16 in `docs/features/active/2026-08-23-poshqc-coverage-denominator-not-reproducible-527/spec.md` after P6-T26 passes. Acceptance: the count of `- [x] Documentation:` in that file returns 1.
- [ ] [P6-T47] Check off AC-17 in `docs/features/active/2026-08-23-poshqc-coverage-denominator-not-reproducible-527/spec.md` after P6-T27 passes. Acceptance: the count of `- [x] No temporary files in tests:` in that file returns 1.
- [ ] [P6-T48] Check off AC-18 in `docs/features/active/2026-08-23-poshqc-coverage-denominator-not-reproducible-527/spec.md` after P6-T28 passes. Acceptance: the count of ``- [x] `PoshQC.Testing.psm1` and every new production or test file remain`` in that file returns 1, and the count of `- [ ] ` lines under `## Acceptance Criteria` is 0.
