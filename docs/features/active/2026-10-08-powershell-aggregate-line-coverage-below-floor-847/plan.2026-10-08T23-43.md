# 2026-10-08-powershell-aggregate-line-coverage-below-floor (Plan)

- **Issue:** #847
- **Branch:** `bug/powershell-aggregate-line-coverage-below-floor-847`
- **Parent (optional):** none
- **Owner:** drmoisan
- **Work Mode:** full-bug (acceptance criteria source: `spec.md` AC-01 to AC-15 only)
- **Inputs:** `docs/features/active/2026-10-08-powershell-aggregate-line-coverage-below-floor-847/issue.md`, `docs/features/active/2026-10-08-powershell-aggregate-line-coverage-below-floor-847/spec.md`, `docs/features/active/2026-10-08-powershell-aggregate-line-coverage-below-floor-847/research/research.2026-10-08T23-50.md`
- **Last Updated:** 2026-10-09T01-30
- **Status:** Draft revision 1.1 (preflight round 1 deltas applied; pending plan-validator run and executor preflight round 2)
- **Version:** 1.1

## Fail-Closed Rules

- **Fail-closed evidence rule:** every baseline, QA, and coverage artifact named below is mandatory. If any is missing or lacks `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:`, the audit verdict is BLOCKED or INCOMPLETE, never PASS, and the owning task stays unchecked.
- **Evidence accounting rule:** each evidence-producing task names its artifact path. A task is not checked off until that artifact exists with every required field.
- **No host execution:** no task runs `scripts/dev-tools/bootstrap-host.ps1`, `scripts/dev-tools/verify-host.ps1`, or `scripts/dev-tools/publish-sideloaded-extension.ps1` against the real machine. These scripts run only inside Pester tests with every host seam mocked.
- **No MCP PoshQC evidence:** no task uses a `run_poshqc_*` MCP tool. The MCP test tool reads the installed extension's settings and returns only a pre-composed summary with no exit code, counts, or coverage (spec A-5), so it cannot carry an acceptance condition. All PoshQC evidence comes from the self-hosted commands defined below.
- **Excluded paths (never written):** `.codex/**`, `.claude/rules/**`, `.github/instructions/**`, `.claude/hooks/validate-feature-review-coverage.ps1`, `config/poshqc-coverage.json`, `scripts/powershell/PoshQC/**` (including `scripts/powershell/PoshQC/settings/pester.runsettings.psd1`), `quality-tiers.yml`, `config/blast-radius.json`, `.vscode/tasks.json`, `scripts/dev-tools/vscode-cli.helpers.ps1`, `extensions/drm-copilot/resources/**`. No coverage `exclude` entry is added and no coverage root is narrowed.
- **Coverage-gap stop rule (spec A-4):** if the post-change aggregate in P7-T4 is below 85%, the executor records the gap and stops for re-planning. It does not edit any excluded path and does not add tests for files outside the PROD8 set without a revised plan.
- **Orchestrated path precondition:** this plan writes more than three production PowerShell files, so it runs only on the orchestrated large path (`.claude/rules/powershell.md`, Change Budget). If `.claude/hooks/enforce-powershell-batch-budget.ps1` denies a write, the executor stops and reports; it does not bypass the hook.
- **Tool route:** in the agent worktree, PowerShell commands run through the PowerShell tool, not the Bash tool (spec A-10).
- **Evidence location override:** spec AC-02 and AC-03 name `evidence/coverage/`, which is not in the canonical evidence kind list (`baseline`, `regression-testing`, `qa-gates`, `issue-updates`, `other`, `remediation-baseline`). EVIDENCE_LOCATION_OVERRIDE_REJECTED: `evidence/coverage/` replaced with `docs/features/active/2026-10-08-powershell-aggregate-line-coverage-below-floor-847/evidence/qa-gates/`. Coverage evidence for AC-02 and AC-03 is written to `evidence/qa-gates/`.
- **Fail-before evidence:** no `[expect-fail]` task is planned. The defect is an aggregate coverage shortfall, and its fail-before observation is the P0-T5 baseline aggregate. Tests for modules that do not yet exist cannot be run before the modules are created.

## Assumptions and Advisories

- **PSShouldProcess stop rule may trigger.** P7-T2 may report `PSShouldProcess` on `scripts/dev-tools/publish-sideloaded-extension.ps1`, because the entry keeps `SupportsShouldProcess = $true` while its body no longer calls `$PSCmdlet.ShouldProcess` (the calls move into the module). If that happens, the Design Contract contingency applies: the executor records the finding and stops for re-planning. It does not alter the `CmdletBinding` attribute or add a `ShouldProcess` call to the entry body.
- **Working pwsh route required.** In an isolated agent worktree, a Bash tool command containing `pwsh` may be refused by the worktree isolation guard. The executor runs every PowerShell command in this plan through the PowerShell tool. If no PowerShell route is available, the executor stops and reports the blocked state; it does not mark a command task complete without running it.
- **Targeted-run output directory.** `artifacts/pester/` does not exist in this worktree before execution. FULL_RUN in P0-T5 creates it; the targeted runs in P1-T3, P2-T6, P3-T4, P4-T4, and P5-T8 run after P0-T5 and write into the existing directory.

## Definitions (fixed; the executor does not substitute values)

- **FEATURE** = `docs/features/active/2026-10-08-powershell-aggregate-line-coverage-below-floor-847`.
- **TS** = the execution timestamp in `yyyy-MM-ddTHH-mm` form at the moment an artifact is written. Evidence file names below carry `<ts>` in that position.
- **BASE_SHA** = the commit printed by `git merge-base HEAD origin/main` in P0-T2 and recorded in `docs/features/active/2026-10-08-powershell-aggregate-line-coverage-below-floor-847/evidence/baseline/branch-base.<ts>.md`. Later tasks read BASE_SHA from that artifact.
- **ROOT** = `((Get-Location).Path -replace '\\', '/')` evaluated in the worktree root.
- **BASE5** (existing in-scope files at baseline): `scripts/dev-tools/bootstrap-host.ps1`, `scripts/dev-tools/verify-host.ps1`, `scripts/dev-tools/publish-sideloaded-extension.ps1`, `scripts/dev-tools/bootstrap-host.helpers.ps1`, `tests/scripts/dev-tools/publish-sideloaded-extension.Tests.ps1`.
- **PROD8** (new or modified production files): `scripts/dev-tools/HostTooling.psm1`, `scripts/dev-tools/HostBootstrapWorkspace.psm1`, `scripts/dev-tools/HostBootstrap.psm1`, `scripts/dev-tools/HostVerification.psm1`, `scripts/dev-tools/SideloadedExtensionPublish.psm1`, `scripts/dev-tools/bootstrap-host.ps1`, `scripts/dev-tools/verify-host.ps1`, `scripts/dev-tools/publish-sideloaded-extension.ps1`.
- **TEST11** (new or rewritten test files): `tests/scripts/dev-tools/HostTooling.Tests.ps1`, `tests/scripts/dev-tools/HostBootstrapWorkspace.Tests.ps1`, `tests/scripts/dev-tools/HostBootstrap.Tests.ps1`, `tests/scripts/dev-tools/HostBootstrap.Invoke.Tests.ps1`, `tests/scripts/dev-tools/HostVerification.Tests.ps1`, `tests/scripts/dev-tools/HostVerification.Invoke.Tests.ps1`, `tests/scripts/dev-tools/SideloadedExtensionPublish.Tests.ps1`, `tests/scripts/dev-tools/SideloadedExtensionPublish.Invoke.Tests.ps1`, `tests/scripts/dev-tools/bootstrap-host.Tests.ps1`, `tests/scripts/dev-tools/verify-host.Tests.ps1`, `tests/scripts/dev-tools/publish-sideloaded-extension.Tests.ps1`.
- **CPFS** (changed PowerShell file set, 19 files) = PROD8 followed by TEST11. In commands, `$cpfs` is this literal array:

```powershell
$cpfs = @('scripts/dev-tools/HostTooling.psm1', 'scripts/dev-tools/HostBootstrapWorkspace.psm1', 'scripts/dev-tools/HostBootstrap.psm1', 'scripts/dev-tools/HostVerification.psm1', 'scripts/dev-tools/SideloadedExtensionPublish.psm1', 'scripts/dev-tools/bootstrap-host.ps1', 'scripts/dev-tools/verify-host.ps1', 'scripts/dev-tools/publish-sideloaded-extension.ps1', 'tests/scripts/dev-tools/HostTooling.Tests.ps1', 'tests/scripts/dev-tools/HostBootstrapWorkspace.Tests.ps1', 'tests/scripts/dev-tools/HostBootstrap.Tests.ps1', 'tests/scripts/dev-tools/HostBootstrap.Invoke.Tests.ps1', 'tests/scripts/dev-tools/HostVerification.Tests.ps1', 'tests/scripts/dev-tools/HostVerification.Invoke.Tests.ps1', 'tests/scripts/dev-tools/SideloadedExtensionPublish.Tests.ps1', 'tests/scripts/dev-tools/SideloadedExtensionPublish.Invoke.Tests.ps1', 'tests/scripts/dev-tools/bootstrap-host.Tests.ps1', 'tests/scripts/dev-tools/verify-host.Tests.ps1', 'tests/scripts/dev-tools/publish-sideloaded-extension.Tests.ps1')
```

- **FULL_RUN** (the only command whose coverage counts for AC-01 and AC-02; no `-ScanFolders`, no settings override), executed from the PowerShell tool in the worktree root:

```powershell
New-Item -ItemType Directory -Force -Path artifacts/pester | Out-Null; $start = [datetime]::UtcNow; pwsh -NoProfile -Command "Import-Module ./scripts/powershell/PoshQC/PoshQC.psd1 -Force; Invoke-PoshQCTest -Root (Get-Location).Path" *> artifacts/pester/847-<phase>-poshqc.log; $exit = $LASTEXITCODE; "EXIT_CODE=$exit"
```

  `<phase>` is `baseline` in P0-T5 and `final` in P7-T3. The shipped run settings set `Run.Exit = $true`, so `$exit` is 0 only when Pester reports no failure. FULL_RUN is valid only when all three hold: (a) `artifacts/pester/powershell-coverage.xml` and `artifacts/pester/pester-junit.xml` both have `LastWriteTimeUtc` later than `$start`; (b) the log contains exactly one line matching the literal `Code coverage population: source=config` (count via `Select-String -LiteralPath artifacts/pester/847-<phase>-poshqc.log -SimpleMatch -Pattern 'Code coverage population: source=config'`); (c) the command text contains no `-ScanFolders` and no `-SettingsPath` argument. If any fails, the run is invalid and its task stays unchecked.

- **CRP (Coverage Reduction Procedure)** applied to a CoverageGutters/JaCoCo XML file `X`. The derivation is fixed:
  1. Load: `[xml]$x = Get-Content -Raw -LiteralPath X`.
  2. Aggregate: `$agg = @($x.report.counter | Where-Object { $_.type -eq 'LINE' })`. This selects only the direct `counter` children of `report`. Require `$agg.Count -eq 1`, else FAIL. `covered = [int]$agg[0].covered`, `missed = [int]$agg[0].missed`, `total = covered + missed`.
  3. Per file with directory `D` (repository-relative, forward slashes) and file name `N`: `$pkg = @($x.report.package | Where-Object { $_.name -ieq "$ROOT/$D" })`; require `$pkg.Count -eq 1`; `$sf = @($pkg[0].sourcefile | Where-Object { $_.name -ceq N })`; require `$sf.Count -eq 1`, else FAIL (a missing row is a failure, not a zero). `$lc = @($sf[0].counter | Where-Object { $_.type -eq 'LINE' })`; require `$lc.Count -eq 1`; read `covered` and `missed` as integers. The package name is compared to ROOT plus `D` because the CoverageGutters writer records absolute directory paths (observed in a local `artifacts/pester/powershell-coverage.xml`: `<package name="C:/Users/.../.claude/hooks">`).
  4. Threshold: PASS if and only if `total -gt 0` and `100 * covered -ge 85 * total` (integer arithmetic; no rounding). Reported percentage = `[math]::Round(100.0 * covered / total, 2)`.
  5. Required covered lines for a total `T` = `[math]::Floor((85 * T + 99) / 100)` (integer ceiling of 0.85 x T). Gap = required minus covered, floored at 0.
- **JRP (JUnit Reduction Procedure)** applied to a JUnit XML file `J`:
  1. Load: `[xml]$j = Get-Content -Raw -LiteralPath J`.
  2. Suite for test file `F` (repository-relative): `$suite = @($j.testsuites.testsuite | Where-Object { ($_.name -replace '\\', '/').EndsWith('/' + F, [System.StringComparison]::OrdinalIgnoreCase) })`; require `$suite.Count -eq 1`.
  3. `$cases = @($suite[0].SelectNodes('.//testcase'))`. Zero cases is FAIL. PASS for the suite if and only if every case has `status` equal to `Passed` (`@($cases | Where-Object { $_.status -ne 'Passed' }).Count -eq 0`).
  4. Token check for token `K`: `$hits = @($j.SelectNodes("//testcase[contains(@name, 'K')]"))`; PASS if and only if `$hits.Count -ge 1` and every hit has `status` equal to `Passed`.
  5. Whole-run totals: `testsuites` attributes `tests`, `failures`, `errors`, and the list of `//testcase[@status='Failed']` as `classname` plus `name`.
- **AC test tokens.** The `It` names below must contain the token verbatim, so each AC-05 and AC-06 scenario is traceable through JRP step 4. Each token is assigned to exactly one test file.

| Token | Test file | Scenario |
|---|---|---|
| `AC05-BOOTSTRAP-DRYRUN-EXIT0` | `tests/scripts/dev-tools/bootstrap-host.Tests.ps1` | dry run returns `$LASTEXITCODE` 0 and forwards parameters |
| `AC05-BOOTSTRAP-NONWINDOWS-EXIT1` | `tests/scripts/dev-tools/bootstrap-host.Tests.ps1` | non-Windows: terminating error rethrown; `$LASTEXITCODE` 1 |
| `AC05-BOOTSTRAP-NOWINGET-EXIT1` | `tests/scripts/dev-tools/bootstrap-host.Tests.ps1` | missing winget: terminating error rethrown; `$LASTEXITCODE` 1 |
| `AC05-VERIFY-PASS-EXIT0` | `tests/scripts/dev-tools/verify-host.Tests.ps1` | zero failures, `$LASTEXITCODE` 0 |
| `AC05-VERIFY-ONEFAIL-EXIT1` | `tests/scripts/dev-tools/verify-host.Tests.ps1` | one failure, `$LASTEXITCODE` 1 |
| `AC05-VERIFY-NOMANIFEST-EXIT1` | `tests/scripts/dev-tools/verify-host.Tests.ps1` | `Manifest not found at`: terminating error rethrown; `$LASTEXITCODE` 1 |
| `AC05-PUBLISH-VSIX-OUTPUT` | `tests/scripts/dev-tools/publish-sideloaded-extension.Tests.ps1` | final pipeline value is the VSIX path; defaults resolved |
| `AC05-PUBLISH-WHATIF-NOSEAMS` | `tests/scripts/dev-tools/publish-sideloaded-extension.Tests.ps1` | `-WhatIf` makes zero state-changing seam calls |
| `AC05-PUBLISH-CODECOMMAND-BOUNDEMPTY` | `tests/scripts/dev-tools/publish-sideloaded-extension.Tests.ps1` | `-CodeCommand ''` forwarded as bound |
| `AC05-PUBLISH-CODECOMMAND-UNBOUND` | `tests/scripts/dev-tools/publish-sideloaded-extension.Tests.ps1` | no `CodeCommand` key forwarded |
| `AC05-PUBLISH-CONFIRM-FORWARDED` | `tests/scripts/dev-tools/publish-sideloaded-extension.Tests.ps1` | `-Confirm:$false` forwarded |
| `AC06-BOOTSTRAP-DRYRUN-NOSIDEEFFECTS` | `tests/scripts/dev-tools/HostBootstrap.Invoke.Tests.ps1` | dry run: zero installs, registry writes, clones; prints `- Would` lines |
| `AC06-BOOTSTRAP-NOMANIFEST-THROWS` | `tests/scripts/dev-tools/HostBootstrap.Invoke.Tests.ps1` | missing manifest throws `Host tools manifest not found at` |
| `AC06-BOOTSTRAP-PRECONDITION-ERRORS` | `tests/scripts/dev-tools/HostBootstrap.Invoke.Tests.ps1` | `-IsWindowsHost:$false` and missing winget raise terminating errors with the original texts |
| `AC06-RUNONCE-SET-APPLY-AND-RESUME` | `tests/scripts/dev-tools/HostBootstrap.Invoke.Tests.ps1` | RunOnce set only with `-Apply` and `-EnableAutoResumeAfterReboot` |
| `AC06-RUNONCE-NOT-SET-WITHOUT-BOTH` | `tests/scripts/dev-tools/HostBootstrap.Invoke.Tests.ps1` | RunOnce not set with only one of the two switches |
| `AC06-RUNONCE-CLEARED-AFTER-APPLY` | `tests/scripts/dev-tools/HostBootstrap.Invoke.Tests.ps1` | RunOnce cleared after a successful apply |
| `AC06-POETRY-PROJECT-INSTALL-WARNS` | `tests/scripts/dev-tools/HostBootstrap.Invoke.Tests.ps1` | poetry project-install failure is a warning line, not an error |
| `AC06-VERIFY-SCRIPT-EXITCODE-IGNORED` | `tests/scripts/dev-tools/HostBootstrap.Invoke.Tests.ps1` | sibling `verify-host.ps1` invoked by path; its result does not fail bootstrap |
| `AC06-POETRY-PIP-FALLBACK` | `tests/scripts/dev-tools/HostBootstrap.Tests.ps1` | winget poetry failure falls back to pip |
| `AC06-NONPOETRY-RETHROW` | `tests/scripts/dev-tools/HostBootstrap.Tests.ps1` | winget failure for another package rethrows |
| `AC06-VERIFY-NOMANIFEST-THROWS` | `tests/scripts/dev-tools/HostVerification.Invoke.Tests.ps1` | missing manifest raises `Manifest not found at <path>` |
| `AC06-VERIFY-SECTION-ORDER` | `tests/scripts/dev-tools/HostVerification.Invoke.Tests.ps1` | five headings and line order unchanged |
| `AC06-VERIFY-EXIT-BOUNDARY` | `tests/scripts/dev-tools/HostVerification.Invoke.Tests.ps1` | ExitCode 0 at zero failures, 1 at one failure |
| `AC06-EPERM-RETRY-LIMIT` | `tests/scripts/dev-tools/SideloadedExtensionPublish.Tests.ps1` | EPERM rethrown after 3 attempts |
| `AC06-EPERM-BACKOFF` | `tests/scripts/dev-tools/SideloadedExtensionPublish.Tests.ps1` | sleep seam receives `DelaySeconds x attempt` |
| `AC06-NONEPERM-RETHROW` | `tests/scripts/dev-tools/SideloadedExtensionPublish.Tests.ps1` | non-EPERM error rethrown with no sleep |
| `AC06-PUBLISH-FORCE-CLEANUP` | `tests/scripts/dev-tools/SideloadedExtensionPublish.Tests.ps1` | `-ForceCleanup` stops node, removes `node_modules`, cleans the npm cache |
| `AC06-PUBLISH-STEP-ORDER` | `tests/scripts/dev-tools/SideloadedExtensionPublish.Invoke.Tests.ps1` | npm ci, compile, vsce package, install, in that order |
| `AC06-PUBLISH-SKIP-SWITCHES` | `tests/scripts/dev-tools/SideloadedExtensionPublish.Invoke.Tests.ps1` | each Skip switch suppresses its step |
| `AC06-PUBLISH-VSIX-MISSING-THROWS` | `tests/scripts/dev-tools/SideloadedExtensionPublish.Invoke.Tests.ps1` | throws `VSIX was not created as expected` |
| `AC06-PUBLISH-CODECOMMAND-NOTFOUND-THROWS` | `tests/scripts/dev-tools/SideloadedExtensionPublish.Invoke.Tests.ps1` | explicit `-CodeCommand` not on PATH throws |

## Design Contract (fixed by spec DR-1/DR-2 and this plan; not executor choices)

### Module layout and placement

All modules live directly in `scripts/dev-tools/`. No `.psd1` file and no subfolder is created. Each module begins with `Set-StrictMode -Version Latest` and `$ErrorActionPreference = 'Stop'` on their own lines at column 0 (module scope), contains no `exit` statement, ends with `Export-ModuleMember -Function` naming its exports, and stays at or below 500 lines. Each function carries a one-line `.SYNOPSIS` comment-based help block (no longer help) to respect the size limit. Code must parse under the `PSUseCompatibleSyntax` targets 5.1 and 7.6 in `scripts/powershell/PoshQC/settings/pssa.settings.psd1` (no ternary, no `??`, no pipeline-chain operators).

`HostBootstrapWorkspace.psm1` is created unconditionally. Rationale (spec "Proposed Fix" size rule): `bootstrap-host.ps1` functions plus the 149-line helper file already exceed 500 lines before help comments, so the spec condition for creating it is met.

| Module | Imports | Exported functions | Non-exported |
|---|---|---|---|
| `scripts/dev-tools/HostTooling.psm1` | none | `Get-HostToolsManifestPath`, `Read-HostToolsManifest`, `Get-HostEnvironmentVariable`, `Set-HostEnvironmentVariable`, `Get-SessionPathFromMachineAndUser`, `Invoke-HostNativeCommand`, `ConvertTo-HostToolVersion`, `Get-CommandVersion` | none |
| `scripts/dev-tools/HostBootstrapWorkspace.psm1` | `HostTooling.psm1` | `Invoke-HostBootstrapGit`, `Get-ProjectRepositoriesFromManifest`, `Resolve-WorkspaceRoot`, `Initialize-WorkspaceRoot`, `Sync-ProjectsFromManifest`, `Resolve-ProjectRepoRoot` | none |
| `scripts/dev-tools/HostBootstrap.psm1` | `HostTooling.psm1`, `HostBootstrapWorkspace.psm1` | `Invoke-BootstrapHost`, `Get-HostManifest`, `Install-WithWinget`, `Install-PoetryWithPip`, `Install-WslIfMissing`, `Add-DirectoryToUserPath`, `Get-WingetPackagesFromManifest`, `Get-BootstrapResumeArgument`, `Set-BootstrapResumeRunOnce`, `Remove-BootstrapResumeRunOnce`, `Install-HostPowerShellModule`, `Invoke-HostBootstrapWinget`, `Invoke-HostBootstrapNpm`, `Invoke-HostBootstrapWsl`, `Invoke-HostBootstrapPoetry`, `Invoke-HostBootstrapVerifyScript` | none |
| `scripts/dev-tools/HostVerification.psm1` | `HostTooling.psm1` | `Invoke-HostVerification`, `Test-HostCoreVersion`, `Test-HostRequiredCommand`, `Test-HostOptionalCommand`, `Test-HostPowerShellModule`, `Test-HostPoetryTool`, `Test-VersionAtLeast`, `Get-RequiredCommandsForHost`, `Get-PoetryVersionInfo`, `Invoke-PoetryCommand` | none |
| `scripts/dev-tools/SideloadedExtensionPublish.psm1` | dot-sources `vscode-cli.helpers.ps1` from `$PSScriptRoot` | `Invoke-SideloadedExtensionPublish`, `Get-PackageManifest`, `Test-IsVsCodeExtensionManifest`, `Resolve-ExtensionProjectRoot`, `Invoke-ExternalCommand`, `Assert-RequiredCommandAvailable`, `Invoke-NpmCiWithRetry`, `Invoke-ProjectCompile` | `Stop-NodeProcess`, `Invoke-SideloadedExtensionProcess`, and the dot-sourced `Test-IsVSCodeInsidersSession` and `Resolve-VSCodeCliCommand` |

Imports inside modules use `Import-Module (Join-Path -Path $PSScriptRoot -ChildPath '<Name>.psm1')`.

**Naming deviation from spec (recorded):** the spec names the verify section functions `Test-HostCoreVersions`, `Test-HostRequiredCommands`, `Test-HostOptionalCommands`, `Test-HostPowerShellModules`, and `Test-HostPoetryTools`. The repository analyzer settings enable all default rules at Warning severity (`IncludeDefaultRules = $true`), which includes `PSUseSingularNouns`, and AC-11 requires zero warnings. The plan therefore uses the singular forms `Test-HostCoreVersion`, `Test-HostRequiredCommand`, `Test-HostOptionalCommand`, `Test-HostPowerShellModule`, and `Test-HostPoetryTool`. Responsibilities and return shapes are unchanged.

### Seams and behavior rules

- `Invoke-HostNativeCommand -FilePath <string> -ArgumentList <string[]> [-MergeErrorStream]` runs `& $FilePath @ArgumentList` (with `2>&1` only when `-MergeErrorStream` is set) and returns `[pscustomobject]@{ Output = <captured objects>; ExitCode = <int> }`, where ExitCode is `$LASTEXITCODE` read immediately after the call, or 0 when it is `$null`. It is the single process seam for HostTooling, HostBootstrapWorkspace, HostBootstrap, and HostVerification. The `Invoke-HostBootstrap*` wrappers stay as thin named functions (the repository wrapper-seam pattern in `.claude/rules/powershell.md`), emit `Output` to the pipeline so stdout content is preserved, and keep the original throw-on-nonzero messages: `winget command failed with exit code N`, `wsl command failed with exit code N`, `git command failed with exit code N`, `poetry command failed with exit code N`, `python -m poetry failed with exit code N`, `python is required to execute poetry`. `Invoke-HostBootstrapNpm` has no exit-code check, as before. `Invoke-HostBootstrapVerifyScript` keeps `& $ScriptPath`.
- `Get-CommandVersion`, `Get-PoetryVersionInfo`, and `Invoke-PoetryCommand` call `Invoke-HostNativeCommand -MergeErrorStream` (the originals used `2>&1`). Version parsing goes through `ConvertTo-HostToolVersion` (regex `(\d+\.\d+(?:\.\d+)?)`; returns `$null` on blank input, no match, or a failed `[version]` cast). `Invoke-PoetryCommand` returns `{ Output; ExitCode }` and still throws `poetry not found` when neither `poetry` nor `python` resolves.
- Environment access goes through `Get-HostEnvironmentVariable -Name -Target` and `Set-HostEnvironmentVariable -Name -Value -Target` (`SupportsShouldProcess`). Every former `$env:Path = $sessionPath` assignment becomes `Set-HostEnvironmentVariable -Name 'Path' -Value $sessionPath -Target 'Process'`. `Add-DirectoryToUserPath` reads and writes the User `Path` through these seams. `Install-PoetryWithPip` reads `APPDATA` through `Get-HostEnvironmentVariable -Name 'APPDATA' -Target 'Process'`.
- Install-PoetryWithPip emits the Output of its Invoke-HostNativeCommand call: the `python -m pip install --user poetry` invocation (formerly the direct call at `bootstrap-host.ps1:226`, whose stdout reached the pipeline) goes through `Invoke-HostNativeCommand`, and `Install-PoetryWithPip` writes that result's `Output` to the pipeline before checking `ExitCode`, so pip's stdout is preserved.
- `Install-Module` is reached only through `Install-HostPowerShellModule -Name -RequiredVersion`, which calls `Install-Module -Name $Name -RequiredVersion $RequiredVersion -Scope CurrentUser -AllowClobber -Force`.
- `Get-HostManifest` calls `Read-HostToolsManifest -Path (Get-HostToolsManifestPath)` and throws `Host tools manifest not found at <path>` when it returns `$null`. `Invoke-HostVerification` raises `Write-Error -Message "Manifest not found at <path>" -ErrorAction Stop` when `Read-HostToolsManifest` returns `$null`. The two `Invoke-BootstrapHost` preconditions keep their original texts and use `Write-Error -Message '<original text>' -ErrorAction Stop`, so they stay terminating even when a caller passes `-ErrorAction`; the former `exit 1` lines are removed from module code.
- `Get-BootstrapResumeArgument -WorkspaceRoot -RepoRoot -SkipProjectPoetryInstall` returns the space-joined string built by `bootstrap-host.ps1:359-373` (`-WorkspaceRoot "<w>"`, `-RepoRoot "<r>"`, `-SkipProjectPoetryInstall`, each only when set; whitespace-only values are omitted).
- `Invoke-HostVerification [-ManifestPath <string> = (Get-HostToolsManifestPath)] [-IsWindowsHost <bool> = $IsWindows]` returns `[pscustomobject]@{ Lines = [string[]]; ExitCode = [int] }`. It adds the banner, the blank-plus-heading lines (`Core versions:`, `Required commands:`, `Optional commands:`, `PowerShell modules:`, `Poetry quality tools:`), and the summary lines. The five `Test-Host*` section functions return only their item lines plus `FailureCount` (`Test-HostOptionalCommand` always returns 0). Line text and order equal `verify-host.ps1:192-325` today.
- `SideloadedExtensionPublish.psm1`: `Invoke-ExternalCommand` builds the same `cmd.exe /c` parameter set as `publish-sideloaded-extension.ps1:172-179` and passes it to the non-exported `Invoke-SideloadedExtensionProcess -ProcessParameters <hashtable>`, whose only statement starts the process with those parameters. `Invoke-NpmCiWithRetry` gains `[scriptblock]$Sleep` whose default sleeps for the given seconds, and calls `& $Sleep ($DelaySeconds * $attempt)`. `Invoke-SideloadedExtensionPublish` gains `[scriptblock]$Now = { Get-Date }` and computes the timestamp with `Get-Date -Date (& $Now) -Format 'yyyyMMdd-HHmmss'`. All other text (messages, ShouldProcess targets and actions, argument lists, `Write-Information` lines) is moved unchanged from `publish-sideloaded-extension.ps1:58-403`. `Invoke-SideloadedExtensionPublish` keeps `$PSBoundParameters.ContainsKey('CodeCommand')` semantics and returns the VSIX path as its only pipeline output.

### Residual entry-point shape (exact)

`scripts/dev-tools/bootstrap-host.ps1`: lines 1-18 (shebang, `[CmdletBinding()]`, `param` block) unchanged. Body after the param block:

```powershell
Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

Import-Module (Join-Path -Path $PSScriptRoot -ChildPath 'HostBootstrap.psm1')

if ($MyInvocation.InvocationName -ne '.') {
    try {
        Invoke-BootstrapHost -Apply:$Apply -EnableAutoResumeAfterReboot:$EnableAutoResumeAfterReboot -WorkspaceRoot $WorkspaceRoot -RepoRoot $RepoRoot -SkipProjectPoetryInstall:$SkipProjectPoetryInstall
    }
    catch {
        $global:LASTEXITCODE = 1
        throw
    }

    exit 0
}
```

The `if ($MyInvocation.InvocationName -ne '.')` guard is the dot-source guard of `bootstrap-host.ps1:482`, retained so that dot-sourcing the entry imports the module without running the orchestrator or executing `exit`.

`scripts/dev-tools/verify-host.ps1`: lines 1-3 unchanged. Body:

```powershell
Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

Import-Module (Join-Path -Path $PSScriptRoot -ChildPath 'HostVerification.psm1')

try {
    $result = Invoke-HostVerification
}
catch {
    $global:LASTEXITCODE = 1
    throw
}

$result.Lines | Write-Output
exit $result.ExitCode
```

`scripts/dev-tools/publish-sideloaded-extension.ps1`: lines 1-51 (help block, `[CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = "Medium")]`, `param` block with both default expressions) unchanged. Body:

```powershell
Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

Import-Module (Join-Path -Path $PSScriptRoot -ChildPath 'SideloadedExtensionPublish.psm1')

$invokeParameters = @{
    RepoRoot      = $RepoRoot
    UseInsiders   = $UseInsiders
    VsixOutputDir = $VsixOutputDir
    SkipNpmCi     = $SkipNpmCi
    SkipCompile   = $SkipCompile
    SkipInstall   = $SkipInstall
    Force         = $Force
}
if ($PSBoundParameters.ContainsKey('CodeCommand')) {
    $invokeParameters['CodeCommand'] = $CodeCommand
}
if ($PSBoundParameters.ContainsKey('WhatIf')) {
    $invokeParameters['WhatIf'] = $PSBoundParameters['WhatIf']
}
if ($PSBoundParameters.ContainsKey('Confirm')) {
    $invokeParameters['Confirm'] = $PSBoundParameters['Confirm']
}
if ($PSBoundParameters.ContainsKey('Verbose')) {
    $invokeParameters['Verbose'] = $PSBoundParameters['Verbose']
}
if ($PSBoundParameters.ContainsKey('WarningAction')) {
    $invokeParameters['WarningAction'] = $PSBoundParameters['WarningAction']
}

Invoke-SideloadedExtensionPublish @invokeParameters
```

Common-parameter forwarding in the publish entry: before this change, `-Verbose` on the script reached the `Write-Verbose` calls at `publish-sideloaded-extension.ps1:162` and `:331`, and `-WarningAction` reached the `Write-Warning` call at `:275`, because those functions were defined in the script scope and inherited its preference variables. Module functions do not inherit the caller's preference variables, so the entry forwards `Verbose` and `WarningAction` when present in `$PSBoundParameters`. `ErrorAction` is not forwarded: the script forces `$ErrorActionPreference = "Stop"` at `:54`, and the module sets the same value at module scope.

Rationale for the catch body (`$global:LASTEXITCODE = 1`, then `throw`) in the bootstrap and verify entries: AC-05 requires `$LASTEXITCODE` 1 for the precondition and missing-manifest paths when the entry is run in-process with `&`, and a terminating error that escapes an in-process script does not set `$LASTEXITCODE`. The catch sets it and rethrows the same error record, so the error stays terminating. Under `pwsh -File` the uncaught error is written and the process exits 1, as before; in-process callers can still catch it. An `exit 1` in the catch is not used because it would change behavior: `verify-host.ps1` raises terminating errors under `Set-StrictMode -Version Latest` on manifest keys that bootstrap never reads (`minimumVersions` at `verify-host.ps1:200-203`, `requiredCommands` at `:170`, `optionalCommands` at `:261`, `pythonTools` at `:303`; a missing property throws under StrictMode Latest), and an empty minimum version throws when cast to `[version]` at `:156`. Today these errors propagate through the `Invoke-VerifyHostScript` call at `bootstrap-host.ps1:464` and make `pwsh -File bootstrap-host.ps1` exit 1. With `exit 1` in the verify entry catch, they would become a non-terminating error plus an exit code, and bootstrap would continue and exit 0. The rethrow preserves the propagation.

PSAvoidGlobalVars fallback (fixed, not an executor choice): if P7-T2 reports `PSAvoidGlobalVars` on the `$global:LASTEXITCODE = 1` line of either entry, that line is replaced in both entries by `Set-Variable -Name LASTEXITCODE -Value 1 -Scope Global` (assignment precedent: `tests/scripts/dev-tools/run-actionlint.Tests.ps1:313`), and the loop restarts at P7-T1. No other change to the entry blocks is permitted.

Stated deviation (recorded): `exit 0` at the end of the bootstrap entry is new. Under `pwsh -File` the process exit code after a successful run is 0 before and after the change. For an in-process caller (`& ./scripts/dev-tools/bootstrap-host.ps1`), `$LASTEXITCODE` after a successful run becomes 0; before the change it kept the value set by the last native command the script ran (for example `npm`, whose exit code `Invoke-NpmExe` does not check). The `exit 0` makes the dry-run exit path assertable in-process.

Contingency (stop, do not improvise): if P7-T2 reports `PSShouldProcess` (or any other Warning) on `scripts/dev-tools/publish-sideloaded-extension.ps1` that can be cleared only by changing its `CmdletBinding` attribute or by adding a `ShouldProcess` call to the entry body, the executor records the finding in the P7-T2 artifact and stops for re-planning, because both remedies conflict with AC-04 or with the preserved `-WhatIf` output.

### Test design rules (all TEST11 files)

- Import the module under test through `Resolve-Path`, as in `tests/scripts/claude-lib/cleanup-manifest/CleanupWorktreeManifest.Tests.ps1:21-27` (for example `$script:ModulePath = (Resolve-Path "$PSScriptRoot/../../../scripts/dev-tools/HostTooling.psm1").Path; Import-Module $script:ModulePath -Force`). Each file ends with `AfterAll { Remove-Module <every module it imported, outermost first> -ErrorAction SilentlyContinue }`.
- **Fail-closed default mocks:** each file's top-level `BeforeAll` registers `-ModuleName` mocks whose body throws `unmocked host seam: <name>` for every host seam the module under test can reach: `Invoke-HostNativeCommand`, `Set-HostEnvironmentVariable`, `Get-HostEnvironmentVariable`, `New-Item`, `New-ItemProperty`, `Remove-ItemProperty`, `Remove-Item`, `Stop-Process`, `Get-Process`, `Install-Module`, `Push-Location`, `Pop-Location`, `Invoke-SideloadedExtensionProcess`, `Invoke-HostBootstrapVerifyScript` (each only where the module reaches it). Individual tests re-register the seams they exercise with inline literal fixtures (spec A-6). A passing run therefore shows that no unmocked host seam was reached. The only exceptions are the HostTooling tests for `Invoke-HostNativeCommand` (invoked with the in-process cmdlet `Write-Output` as `-FilePath`, which starts no process), `Get-HostEnvironmentVariable` (reads the Process-scope `PATH` only), and `Set-HostEnvironmentVariable` (invoked with `-WhatIf` only, asserting a Process-scope probe variable named `DRM847_UNSET_PROBE` is `$null` before and after).
- No test text may contain the literals `Start-Process`, `Start-Sleep`, `New-TemporaryFile`, `GetTempPath`, `GetTempFileName`, `TestDrive:`, `$env:TEMP`, or `$env:TMP`; `.claude/hooks/check-powershell-test-purity.ps1:105-116` blocks several of them, and AC-07 forbids the rest. No test uses `$global:` variables (the analyzer enables `PSAvoidGlobalVars`). No new or rewritten test calls `Import-ScriptFunction`.
- Mock parameter blocks must match production parameter names; parameters a mock body does not read are consumed with `$null = $Name` so `PSReviewUnusedParameter` reports nothing.
- Call-order assertions inside a module (`AC06-PUBLISH-STEP-ORDER`) record into a module-scope list created with `InModuleScope SideloadedExtensionPublish { $script:callOrder = [System.Collections.Generic.List[string]]::new() }`, appended from the `-ModuleName` mock bodies, and read back with `InModuleScope`.
- Entry-script tests run `& $entryPath <args>` in-process and assert output plus `$LASTEXITCODE` (precedent `tests/scripts/dev-tools/Invoke-MarketplacePublish.Tests.ps1:263-276`). Each AC-05 entry test first sets a sentinel with `Set-Variable -Name LASTEXITCODE -Value 99 -Scope Global` in its Arrange step, so a `$LASTEXITCODE` assertion cannot pass on a value left by an earlier test. The three terminating-error cases (`AC05-BOOTSTRAP-NONWINDOWS-EXIT1`, `AC05-BOOTSTRAP-NOWINGET-EXIT1`, `AC05-VERIFY-NOMANIFEST-EXIT1`) assert `{ & $script:entryPath <args> } | Should -Throw -ExpectedMessage '<original text>*'` and then `$LASTEXITCODE | Should -Be 1`; they do not use `2>&1` capture. `AC05-VERIFY-ONEFAIL-EXIT1` is not a terminating-error path (the entry runs `exit $result.ExitCode`), so it captures the output and asserts the summary line and `$LASTEXITCODE` 1. Bootstrap entry tests mock `Invoke-BootstrapHost` at test scope (spec A-7; precedent `tests/scripts/dev-tools/tree.Tests.ps1:438-445`), because the real orchestrator's `$IsWindows` default would make the outcome host-dependent. Verify entry tests run the real `Invoke-HostVerification` with `-ModuleName HostVerification` mocks of `Read-HostToolsManifest`, `Get-SessionPathFromMachineAndUser`, `Set-HostEnvironmentVariable`, `Get-Command`, `Get-CommandVersion`, `Get-PoetryVersionInfo`, `Get-Module`, and `Invoke-PoetryCommand`, with a manifest fixture whose `requiredCommands` omit `bashdb` and `copilot` so the result is host-independent. Publish entry tests use the real orchestrator with `-ModuleName SideloadedExtensionPublish` mocks for `AC05-PUBLISH-WHATIF-NOSEAMS` and a test-scope mock of `Invoke-SideloadedExtensionPublish` (asserted with `$PesterBoundParameters`) for the forwarding tokens.
- File size: every TEST11 file stays at or below 500 lines. If a test file would exceed 500 lines, the executor stops and reports; it does not create a test file outside TEST11.
- HostBootstrap size contingency: if `scripts/dev-tools/HostBootstrap.psm1` would exceed 500 lines, the five `Invoke-HostBootstrap*` process wrappers other than `Invoke-HostBootstrapGit` (`Invoke-HostBootstrapWinget`, `Invoke-HostBootstrapNpm`, `Invoke-HostBootstrapWsl`, `Invoke-HostBootstrapPoetry`, `Invoke-HostBootstrapVerifyScript`) move to `scripts/dev-tools/HostBootstrapWorkspace.psm1`, and their tests move to `tests/scripts/dev-tools/HostBootstrapWorkspace.Tests.ps1`. No other file is created.

---

### Phase 0 — Policy Reads and Baseline Capture

- [ ] [P0-T1] Write `docs/features/active/2026-10-08-powershell-aggregate-line-coverage-below-floor-847/evidence/baseline/phase0-instructions-read.md` after reading, in this order, `CLAUDE.md`, `.claude/rules/general-code-change.md`, `.claude/rules/general-unit-test.md`, `.claude/rules/quality-tiers.md`, `.claude/rules/powershell.md`, then the inputs `docs/features/active/2026-10-08-powershell-aggregate-line-coverage-below-floor-847/spec.md` and `docs/features/active/2026-10-08-powershell-aggregate-line-coverage-below-floor-847/research/research.2026-10-08T23-50.md`
  - Acceptance: the artifact contains `Timestamp:`, `Policy Order:` listing the five policy files in the order above, the explicit list of every file read, and a `Not-applicable stages:` line naming type checking, architecture-boundary tests, contract/schema checks, and integration tests as not applicable to these PowerShell files (spec Test Strategy).
- [ ] [P0-T2] Write `docs/features/active/2026-10-08-powershell-aggregate-line-coverage-below-floor-847/evidence/baseline/branch-base.<ts>.md` recording HEAD, BASE_SHA, and the pre-change tree state
  - Command: Run `git rev-parse HEAD`, then run `git rev-parse --verify origin/main`, then run `git merge-base HEAD origin/main`. Then run `git diff --name-only BASE_SHA HEAD`, then run `git status --porcelain=v1 --untracked-files=all` (substitute the merge-base output for BASE_SHA).
  - Path derivation (fixed): the diff paths are the diff output lines. For each status line, the path is `$line.Substring(3)`; when that value contains ` -> `, the path is the part after ` -> `. The checks below apply to the union of the diff paths and the status paths. The artifact records the diff path list and the status path list separately.
  - Acceptance: the artifact records `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:`, the HEAD SHA, and BASE_SHA. No path in the union ends with `.ps1`, `.psm1`, or `.psd1`, no path in the union equals `config/poshqc-coverage.json`, and no path in the union starts with `scripts/powershell/PoshQC/`. This shows that no PowerShell file and no coverage configuration differs from BASE_SHA, so P0-T3 to P0-T5 measure the branch base. Other listed paths (for example `docs/features/` documents or `.claude/agent-memory/` notes) are recorded and do not fail the task. If `origin/main` does not resolve or a disqualifying path is listed, the task fails and the executor stops.
- [ ] [P0-T3] Write `docs/features/active/2026-10-08-powershell-aggregate-line-coverage-below-floor-847/evidence/baseline/pwsh-format-baseline.<ts>.md` from a read-only formatter check of the BASE5 files
  - Command (read-only; writes no source file; mirrors the comparison in `scripts/powershell/PoshQC/PoshQC.Analyzer.psm1:56-66`): `$s = 'scripts/powershell/PoshQC/settings/pssa.settings.psd1'; foreach ($f in @('scripts/dev-tools/bootstrap-host.ps1', 'scripts/dev-tools/verify-host.ps1', 'scripts/dev-tools/publish-sideloaded-extension.ps1', 'scripts/dev-tools/bootstrap-host.helpers.ps1', 'tests/scripts/dev-tools/publish-sideloaded-extension.Tests.ps1')) { $n = (Get-Content -Raw -LiteralPath $f) -replace '\r?\n', [string][char]10; $o = Invoke-Formatter -ScriptDefinition $n -Settings $s; if ($o -ne $n) { "FORMAT_DRIFT $f" } else { "FORMAT_CLEAN $f" } }`
  - Acceptance: the artifact has the four schema fields; `EXIT_CODE:` is 0 when the loop completed without a terminating error; `Output Summary:` lists exactly five lines, each beginning `FORMAT_CLEAN` or `FORMAT_DRIFT`. Drift is recorded, not fixed.
- [ ] [P0-T4] Write `docs/features/active/2026-10-08-powershell-aggregate-line-coverage-below-floor-847/evidence/baseline/pwsh-analyze-baseline.<ts>.md` from per-file PSScriptAnalyzer runs on the BASE5 files
  - Command: `foreach ($f in <BASE5 array as in P0-T3>) { $r = @(Invoke-ScriptAnalyzer -Path $f -Settings scripts/powershell/PoshQC/settings/pssa.settings.psd1 -Severity Error,Warning,Information); '{0} errors={1} warnings={2} information={3}' -f $f, @($r | Where-Object { $_.Severity -in 'Error','ParseError' }).Count, @($r | Where-Object { $_.Severity -eq 'Warning' }).Count, @($r | Where-Object { $_.Severity -eq 'Information' }).Count; $r | ForEach-Object { '  {0} {1}:{2} {3}' -f $_.Severity, $_.RuleName, $_.Line, $_.Message } }`
  - Acceptance: the artifact has the four schema fields and one `errors= warnings= information=` line per BASE5 file (five lines). If `Get-Module -ListAvailable PSScriptAnalyzer` returns nothing, the task fails and the executor stops.
- [ ] [P0-T5] Write `docs/features/active/2026-10-08-powershell-aggregate-line-coverage-below-floor-847/evidence/baseline/pwsh-test-coverage-baseline.<ts>.md` from FULL_RUN with `<phase>` = `baseline` (AC-01)
  - Acceptance: FULL_RUN validity conditions (a) to (c) hold. The artifact records `Timestamp:`, `Command:` (the exact FULL_RUN text), `EXIT_CODE:` (the printed `$exit`; a nonzero value is recorded as-is), `Output Summary:` with: the commit measured (HEAD SHA from P0-T2, equal in PowerShell content to BASE_SHA); the population line copied from `artifacts/pester/847-baseline-poshqc.log`; JRP step 5 totals from `artifacts/pester/pester-junit.xml` and the full list of failed testcases (the baseline failure set); the CRP aggregate `covered`, `missed`, `total`, percentage, required covered lines, and gap from `artifacts/pester/powershell-coverage.xml`; and CRP per-file rows (`D` = `scripts/dev-tools`) for `bootstrap-host.ps1`, `verify-host.ps1`, `publish-sideloaded-extension.ps1`, `bootstrap-host.helpers.ps1`, plus `vscode-cli.helpers.ps1` for context. A missing per-file row fails the task.

### Phase 1 — HostTooling Module

- [ ] [P1-T1] Create `scripts/dev-tools/HostTooling.psm1` with the eight exports and seam behavior defined in the Design Contract
  - Acceptance: the file exists, is at most 500 lines, has `Set-StrictMode -Version Latest` and `$ErrorActionPreference = 'Stop'` at column 0, has no `exit` statement, and its `Export-ModuleMember -Function` names exactly `Get-HostToolsManifestPath`, `Read-HostToolsManifest`, `Get-HostEnvironmentVariable`, `Set-HostEnvironmentVariable`, `Get-SessionPathFromMachineAndUser`, `Invoke-HostNativeCommand`, `ConvertTo-HostToolVersion`, `Get-CommandVersion`. `Get-HostToolsManifestPath` returns exactly `Join-Path -Path $PSScriptRoot -ChildPath '..\host-tools.manifest.json'` with no normalization (no `Resolve-Path`, no `GetFullPath`), matching the path built at `bootstrap-host.ps1:35` and `verify-host.ps1:13`, so the messages `Host tools manifest not found at <path>` (`bootstrap-host.ps1:37`) and `Manifest not found at <path>` (`verify-host.ps1:180`) keep the `dev-tools\..\host-tools.manifest.json` form.
- [ ] [P1-T2] Create `tests/scripts/dev-tools/HostTooling.Tests.ps1` covering every HostTooling function
  - Required cases: the value of `Get-HostToolsManifestPath`, after `-replace '\\', '/'`, ends with `scripts/dev-tools/../host-tools.manifest.json` (unnormalized form preserved); `Read-HostToolsManifest` returns `$null` when `Test-Path` is mocked false (and `Get-Content` is not invoked) and returns the parsed object from an inline JSON fixture; `Get-SessionPathFromMachineAndUser` for both values, Machine only, and neither (empty string); `Get-HostEnvironmentVariable` equals the Process `PATH`; `Set-HostEnvironmentVariable -WhatIf` leaves `DRM847_UNSET_PROBE` `$null`; `Invoke-HostNativeCommand -FilePath 'Write-Output' -ArgumentList @('alpha')` returns Output `alpha` with and without `-MergeErrorStream`; `ConvertTo-HostToolVersion` for `Python 3.12.1`, `v20.11`, text without digits, and empty text; `Get-CommandVersion` for a missing command, a parsed version, blank output, and unparseable output (mocking `Get-Command` and `Invoke-HostNativeCommand` with `-ModuleName HostTooling`).
  - Acceptance: the file exists, is at most 500 lines, follows the Test design rules, and contains none of the forbidden literals listed there.
- [ ] [P1-T3] Write `docs/features/active/2026-10-08-powershell-aggregate-line-coverage-below-floor-847/evidence/qa-gates/targeted-hosttooling.<ts>.md` from a targeted in-process Pester run of `tests/scripts/dev-tools/HostTooling.Tests.ps1`
  - Command: `$c = New-PesterConfiguration; $c.Run.Path = @('tests/scripts/dev-tools/HostTooling.Tests.ps1'); $c.Run.PassThru = $true; $c.CodeCoverage.Enabled = $true; $c.CodeCoverage.Path = @('scripts/dev-tools/HostTooling.psm1'); $c.CodeCoverage.OutputFormat = 'CoverageGutters'; $c.CodeCoverage.OutputPath = 'artifacts/pester/847-targeted-p1.xml'; $c.TestResult.Enabled = $true; $c.TestResult.OutputFormat = 'JUnitXml'; $c.TestResult.OutputPath = 'artifacts/pester/847-targeted-p1-junit.xml'; $r = Invoke-Pester -Configuration $c; "Passed=$($r.PassedCount) Failed=$($r.FailedCount) FailedBlocks=$($r.FailedBlocksCount) FailedContainers=$($r.FailedContainersCount)"`
  - Acceptance: `EXIT_CODE:` is recorded as 0 if and only if `Failed`, `FailedBlocks`, and `FailedContainers` are all 0, else 1. JRP steps 2-3 on `artifacts/pester/847-targeted-p1-junit.xml` pass for the test file. CRP per-file on `artifacts/pester/847-targeted-p1.xml` for `HostTooling.psm1` passes (at least 85%). Any failure is fixed in the P1 files and the run repeated before checking the task.

### Phase 2 — HostBootstrapWorkspace and HostBootstrap Modules

- [ ] [P2-T1] Create `scripts/dev-tools/HostBootstrapWorkspace.psm1` holding the former helper functions plus `Invoke-HostBootstrapGit`
  - Acceptance: the file exists, is at most 500 lines, sets module-scope StrictMode and EAP as defined, has no `exit` statement, imports `HostTooling.psm1`, exports exactly the six functions in the Design Contract table (eleven if the HostBootstrap size contingency is applied in P2-T2), preserves every message string from `scripts/dev-tools/bootstrap-host.helpers.ps1:4-149`, keeps `Resolve-ProjectRepoRoot` resolving `..\..` from `$PSScriptRoot` (`bootstrap-host.helpers.ps1:137`), and contains no occurrence of the token `bootstrap-host.helpers`.
- [ ] [P2-T2] Create `scripts/dev-tools/HostBootstrap.psm1` holding the bootstrap logic from `scripts/dev-tools/bootstrap-host.ps1:30-480` under the Design Contract seams
  - Acceptance: the file exists, is at most 500 lines (otherwise apply the HostBootstrap size contingency), sets module-scope StrictMode and EAP, has no `exit` statement, imports `HostTooling.psm1` and `HostBootstrapWorkspace.psm1`, exports exactly the sixteen functions in the Design Contract table (eleven if the size contingency moves the five process wrappers to `scripts/dev-tools/HostBootstrapWorkspace.psm1`, in which case P2-T1 is revised in the same pass to export them), keeps the `Invoke-BootstrapHost` parameter list of `bootstrap-host.ps1:315-333` including `[bool]$IsWindowsHost = $IsWindows`, preserves every `Write-Output` string in `bootstrap-host.ps1:30-480`, calls no `Install-Module` outside `Install-HostPowerShellModule`, and contains no occurrence of the token `bootstrap-host.helpers`.
- [ ] [P2-T3] Create `tests/scripts/dev-tools/HostBootstrapWorkspace.Tests.ps1` covering every HostBootstrapWorkspace function
  - Required cases: `Invoke-HostBootstrapGit` exit 0 (emits output) and nonzero (throws `git command failed with exit code 128`); `Get-ProjectRepositoriesFromManifest` with and without `projectRepositories`; `Resolve-WorkspaceRoot` blank (mocked `Get-Location`) and explicit path; `Initialize-WorkspaceRoot` existing, dry run (`- Would create workspace root:`), apply (`New-Item` invoked once, `[OK] Created workspace root:`); `Sync-ProjectsFromManifest` missing url (throws), default target path from the url, already present, dry run (`- Would clone`), apply (git wrapper invoked with `clone`); `Resolve-ProjectRepoRoot` explicit path, default root with `pyproject.toml`, `drm-copilot` project with and without `targetPath`, and none (empty string).
  - Acceptance: the file exists, is at most 500 lines, and follows the Test design rules.
- [ ] [P2-T4] Create `tests/scripts/dev-tools/HostBootstrap.Tests.ps1` covering every HostBootstrap function except `Invoke-BootstrapHost`
  - Required cases: each `Invoke-HostBootstrap*` wrapper for exit 0 and nonzero (npm has no nonzero throw); `Invoke-HostBootstrapPoetry` through `poetry`, through `python -m poetry`, and with neither (throws `python is required to execute poetry`); `Get-HostManifest` present and absent; `Install-WithWinget` already installed, dry run, apply success, `AC06-POETRY-PIP-FALLBACK`, `AC06-NONPOETRY-RETHROW`; `Install-PoetryWithPip` already installed, dry run, missing python (throws), pip nonzero (throws `Poetry fallback install failed with exit code`), success (the `Invoke-HostNativeCommand` mock returns `Output = @('Successfully installed poetry-fixture-1.0')` and `ExitCode = 0`; asserts that the line `Successfully installed poetry-fixture-1.0` appears in the function's output, that the poetry directory is added, and that the Process `Path` is set); `Install-WslIfMissing` three paths; `Add-DirectoryToUserPath` missing directory (no write), duplicate differing only by case and trailing backslash (no write), new directory (one write of the joined value to the User target); `Get-WingetPackagesFromManifest` empty (throws) and populated; `Get-BootstrapResumeArgument` all three values, none, whitespace-only workspace; `Set-BootstrapResumeRunOnce` creates the key when absent and writes a command containing `-Apply -EnableAutoResumeAfterReboot`, and `-WhatIf` performs no `New-ItemProperty`; `Remove-BootstrapResumeRunOnce` absent key (no call) and present key; `Install-HostPowerShellModule` passes `-RequiredVersion`, `-Scope CurrentUser`, `-AllowClobber`, `-Force`.
  - Acceptance: the file exists, is at most 500 lines, follows the Test design rules, and contains the two AC tokens assigned to it.
- [ ] [P2-T5] Create `tests/scripts/dev-tools/HostBootstrap.Invoke.Tests.ps1` covering `Invoke-BootstrapHost` paths
  - Required cases: the eight tokens assigned to this file; npm missing (`[WARN] npm not found; Graphite CLI install skipped`); npm present with apply (Graphite install via `Invoke-HostBootstrapNpm`); pyproject absent (`[WARN] pyproject.toml not found; skipping poetry project install`); `-SkipProjectPoetryInstall` (`[INFO] Skipping project poetry install by request`); verify script absent (`[WARN] verify-host.ps1 not found beside bootstrap-host.ps1; verification skipped`); verify script error propagation (no new token: with `-Apply`, when `Invoke-HostBootstrapVerifyScript` is mocked to throw `verify fixture failure`, `Invoke-BootstrapHost` throws `verify fixture failure`). Every case passes `-IsWindowsHost` explicitly.
  - Acceptance: the file exists, is at most 500 lines, follows the Test design rules, and contains the eight AC tokens assigned to it.
- [ ] [P2-T6] Write `docs/features/active/2026-10-08-powershell-aggregate-line-coverage-below-floor-847/evidence/qa-gates/targeted-hostbootstrap.<ts>.md` from a targeted in-process Pester run of the three Phase 2 test files
  - Command: the P1-T3 command with `Run.Path` = `@('tests/scripts/dev-tools/HostBootstrapWorkspace.Tests.ps1', 'tests/scripts/dev-tools/HostBootstrap.Tests.ps1', 'tests/scripts/dev-tools/HostBootstrap.Invoke.Tests.ps1')`, `CodeCoverage.Path` = `@('scripts/dev-tools/HostTooling.psm1', 'scripts/dev-tools/HostBootstrapWorkspace.psm1', 'scripts/dev-tools/HostBootstrap.psm1')`, and output paths `artifacts/pester/847-targeted-p2.xml` and `artifacts/pester/847-targeted-p2-junit.xml`.
  - Acceptance: `EXIT_CODE:` derived as in P1-T3 is 0; JRP steps 2-3 pass for all three files; JRP step 4 passes for the ten Phase 2 tokens; CRP per-file passes for `HostBootstrapWorkspace.psm1` and `HostBootstrap.psm1`.

### Phase 3 — HostVerification Module

- [ ] [P3-T1] Create `scripts/dev-tools/HostVerification.psm1` holding the verification logic from `scripts/dev-tools/verify-host.ps1:16-325` under the Design Contract seams
  - Acceptance: the file exists, is at most 500 lines, sets module-scope StrictMode and EAP, has no `exit` statement, imports `HostTooling.psm1`, exports exactly the ten functions in the Design Contract table (singular `Test-Host*` names), preserves every status line string from `verify-host.ps1:192-324`, and no longer reads `$LASTEXITCODE` after `Invoke-PoetryCommand` (the coupling at `verify-host.ps1:304-305` is replaced by the returned `ExitCode`).
- [ ] [P3-T2] Create `tests/scripts/dev-tools/HostVerification.Tests.ps1` covering every HostVerification function except `Invoke-HostVerification`
  - Required cases: `Test-VersionAtLeast` null, equal, lower; `Get-RequiredCommandsForHost` Windows filter of `bashdb` and `copilot` and non-Windows passthrough; `Get-PoetryVersionInfo` via poetry, via `python -m poetry`, no python, nonzero exit, unparseable output; `Invoke-PoetryCommand` via poetry, via python, neither (throws `poetry not found`); each section function for its OK, FAIL, and WARN outcomes, including the poetry branches of `Test-HostCoreVersion`, module below minimum in `Test-HostPowerShellModule`, and the first non-blank output line in `Test-HostPoetryTool`.
  - Acceptance: the file exists, is at most 500 lines, and follows the Test design rules.
- [ ] [P3-T3] Create `tests/scripts/dev-tools/HostVerification.Invoke.Tests.ps1` covering `Invoke-HostVerification`
  - Required cases: the three tokens assigned to this file; the session `Path` refresh calls `Set-HostEnvironmentVariable` with `-Name 'Path'` and `-Target 'Process'`; the failure summary lines `[WARN] Host verification failed with 1 issue(s)` and `Run: ./scripts/dev-tools/bootstrap-host.ps1 -Apply`.
  - Acceptance: the file exists, is at most 500 lines, follows the Test design rules, and contains the three AC tokens assigned to it.
- [ ] [P3-T4] Write `docs/features/active/2026-10-08-powershell-aggregate-line-coverage-below-floor-847/evidence/qa-gates/targeted-hostverification.<ts>.md` from a targeted in-process Pester run of the two Phase 3 test files
  - Command: the P1-T3 command with `Run.Path` = `@('tests/scripts/dev-tools/HostVerification.Tests.ps1', 'tests/scripts/dev-tools/HostVerification.Invoke.Tests.ps1')`, `CodeCoverage.Path` = `@('scripts/dev-tools/HostTooling.psm1', 'scripts/dev-tools/HostVerification.psm1')`, and output paths `artifacts/pester/847-targeted-p3.xml` and `artifacts/pester/847-targeted-p3-junit.xml`.
  - Acceptance: derived `EXIT_CODE:` 0; JRP steps 2-3 pass for both files; JRP step 4 passes for the three Phase 3 tokens; CRP per-file passes for `HostVerification.psm1`.

### Phase 4 — SideloadedExtensionPublish Module

- [ ] [P4-T1] Create `scripts/dev-tools/SideloadedExtensionPublish.psm1` holding the publish logic from `scripts/dev-tools/publish-sideloaded-extension.ps1:58-403` under the Design Contract seams
  - Acceptance: the file exists, is at most 500 lines, sets module-scope StrictMode and EAP, has no `exit` statement, dot-sources `vscode-cli.helpers.ps1` from `$PSScriptRoot`, exports exactly the eight functions in the Design Contract table, defines `Stop-NodeProcess` and `Invoke-SideloadedExtensionProcess` as top-level non-exported functions, declares `[CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'Medium')]` on `Invoke-SideloadedExtensionPublish`, and preserves the ShouldProcess targets and actions, EPERM detection (`-4048`, `EPERM`, `operation not permitted`), retry limit, and messages of `publish-sideloaded-extension.ps1:219-403`.
- [ ] [P4-T2] Create `tests/scripts/dev-tools/SideloadedExtensionPublish.Tests.ps1` covering every publish helper function
  - Required cases: the four `Resolve-ExtensionProjectRoot` and `Test-IsVsCodeExtensionManifest` cases now in `tests/scripts/dev-tools/publish-sideloaded-extension.Tests.ps1:17-112`, moved to `-ModuleName SideloadedExtensionPublish` mocks; the two `Assert-RequiredCommandAvailable` cases from `:124-140`; `Get-PackageManifest` missing file and parse failure; `Test-IsVsCodeExtensionManifest` blank `vscode` engine; `Invoke-ExternalCommand` exit 0, nonzero (exception `Data["ExitCode"]` set), and empty argument list; `Invoke-NpmCiWithRetry` first-attempt success, EPERM then success, exit code `-4048`, and the four tokens assigned to this file (with `-Sleep` recording its argument in a module-scope list); `Stop-NodeProcess` with no node processes and with two processes; `Invoke-ProjectCompile` compile script, tsconfig only, neither.
  - Acceptance: the file exists, is at most 500 lines, follows the Test design rules, and contains the four AC tokens assigned to it.
- [ ] [P4-T3] Create `tests/scripts/dev-tools/SideloadedExtensionPublish.Invoke.Tests.ps1` covering `Invoke-SideloadedExtensionPublish`
  - Required cases: the four tokens assigned to this file; RepoRoot missing (throws `RepoRoot does not exist:`); extension `package.json` missing (throws `package.json not found at RepoRoot:`); output directory created through `New-Item` when absent; `-Now` fixture `[datetime]::new(2026, 1, 2, 3, 4, 5)` yields a final output ending `drm-copilot-20260102-030405.vsix`; `-Force` adds `--force` to the install arguments and passes `-ForceCleanup` to `Invoke-NpmCiWithRetry`; `-SkipInstall` skips CLI resolution and install; no VS Code CLI found (throws `Could not find a VS Code CLI command on PATH`).
  - Acceptance: the file exists, is at most 500 lines, follows the Test design rules, and contains the four AC tokens assigned to it.
- [ ] [P4-T4] Write `docs/features/active/2026-10-08-powershell-aggregate-line-coverage-below-floor-847/evidence/qa-gates/targeted-publish.<ts>.md` from a targeted in-process Pester run of the two Phase 4 test files
  - Command: the P1-T3 command with `Run.Path` = `@('tests/scripts/dev-tools/SideloadedExtensionPublish.Tests.ps1', 'tests/scripts/dev-tools/SideloadedExtensionPublish.Invoke.Tests.ps1')`, `CodeCoverage.Path` = `@('scripts/dev-tools/SideloadedExtensionPublish.psm1', 'scripts/dev-tools/vscode-cli.helpers.ps1')`, and output paths `artifacts/pester/847-targeted-p4.xml` and `artifacts/pester/847-targeted-p4-junit.xml`.
  - Acceptance: derived `EXIT_CODE:` 0; JRP steps 2-3 pass for both files; JRP step 4 passes for the eight Phase 4 tokens; CRP per-file passes for `SideloadedExtensionPublish.psm1`. The `vscode-cli.helpers.ps1` row is recorded for information only.

### Phase 5 — Entry Scripts, Helper Removal, and Entry Tests

- [ ] [P5-T1] Replace the body of `scripts/dev-tools/bootstrap-host.ps1` after line 18 with the exact residual entry shape in the Design Contract
  - Acceptance: lines 1-18 are identical line by line to BASE_SHA (verified later by P7-T13 `PREFIX_DIFFERENCES=0`); the body equals the Design Contract block (or its PSAvoidGlobalVars fallback variant, if that fallback was applied); the dot-source guard of bootstrap-host.ps1:482 is retained (the `try`/`catch` and `exit 0` sit inside `if ($MyInvocation.InvocationName -ne '.')`); no function definition and no reference to `bootstrap-host.helpers` remains in the file.
- [ ] [P5-T2] Replace the body of `scripts/dev-tools/verify-host.ps1` after line 3 with the exact residual entry shape in the Design Contract
  - Acceptance: lines 1-3 are unchanged (verified later by P7-T13 `PREFIX_DIFFERENCES=0`); the body equals the Design Contract block (or its PSAvoidGlobalVars fallback variant, if that fallback was applied); no function definition remains in the file.
- [ ] [P5-T3] Replace the body of `scripts/dev-tools/publish-sideloaded-extension.ps1` after line 51 with the exact residual entry shape in the Design Contract
  - Acceptance: lines 1-51 are unchanged, including the help block at `:1-21` and both default-value expressions at `:27` and `:38` (verified later by P7-T13 `PREFIX_DIFFERENCES=0`); the body equals the Design Contract block, including the `Verbose` and `WarningAction` forwarding and no `ErrorAction` forwarding; the dot-source of `vscode-cli.helpers.ps1` formerly at `:56` is removed from the entry (it now lives in the module); no function definition remains in the file.
- [ ] [P5-T4] Replace `scripts/dev-tools/bootstrap-host.helpers.ps1` with `scripts/dev-tools/HostBootstrapWorkspace.psm1` by deleting the helper file
  - Acceptance: `Test-Path -LiteralPath scripts/dev-tools/bootstrap-host.helpers.ps1` returns `False`, and `git status --porcelain -- scripts/dev-tools/bootstrap-host.helpers.ps1` prints one line beginning with ` D` or `D `.
- [ ] [P5-T5] Create `tests/scripts/dev-tools/bootstrap-host.Tests.ps1` with the three bootstrap entry exit-path tests
  - Required cases: `AC05-BOOTSTRAP-DRYRUN-EXIT0` (test-scope mock of `Invoke-BootstrapHost` emits `Dry run complete. Re-run with -Apply to install tools.`; asserts that line in the output, `$LASTEXITCODE` 0, and that the mock received `-WorkspaceRoot`, `-RepoRoot`, and the three switches as passed); `AC05-BOOTSTRAP-NONWINDOWS-EXIT1` and `AC05-BOOTSTRAP-NOWINGET-EXIT1` (the mock raises `Write-Error -ErrorAction Stop` with the original texts `This script targets Windows. Use ./scripts/bash/bootstrap-host.sh on Linux/macOS.` and `winget is required on Windows. Install App Installer from Microsoft Store and rerun.`; each case asserts `{ & $script:entryPath } | Should -Throw -ExpectedMessage '<original text>*'` with the original text substituted, then `$LASTEXITCODE | Should -Be 1`; no `2>&1` capture). Every case sets the `$LASTEXITCODE` sentinel 99 in Arrange per the Test design rules.
  - Acceptance: the file exists, is at most 500 lines, follows the Test design rules, and contains the three AC tokens assigned to it.
- [ ] [P5-T6] Create `tests/scripts/dev-tools/verify-host.Tests.ps1` with the three verify entry exit-path tests
  - Required cases: the three `AC05-VERIFY-*` tokens, running the real `Invoke-HostVerification` with the mocks listed in the Test design rules; the pass case asserts the last output line `[OK] Host verification passed` and `$LASTEXITCODE` 0; the one-failure case asserts `[WARN] Host verification failed with 1 issue(s)` and `$LASTEXITCODE` 1; the missing-manifest case asserts `{ & $script:entryPath } | Should -Throw -ExpectedMessage 'Manifest not found at*'`, then `$LASTEXITCODE | Should -Be 1` (no `2>&1` capture). Every case sets the `$LASTEXITCODE` sentinel 99 in Arrange per the Test design rules.
  - Acceptance: the file exists, is at most 500 lines, follows the Test design rules, and contains the three AC tokens assigned to it.
- [ ] [P5-T7] Replace `tests/scripts/dev-tools/publish-sideloaded-extension.Tests.ps1` with an entry-point test file that drops `Import-ScriptFunction` and keeps the `scaffold extension package identity` Describe
  - Required content: remove the TestHelpers dot-source at `:4` and both `Import-ScriptFunction` Describes (`:6-141`; their cases move to P4-T2); add the five `AC05-PUBLISH-*` token tests per the Test design rules (`AC05-PUBLISH-VSIX-OUTPUT` runs without `-RepoRoot` so both default expressions execute, with a test-scope orchestrator mock, and asserts the last output element and the resolved `RepoRoot` and `VsixOutputDir` arguments); add one common-parameter forwarding case (no new token): run the entry with `-Verbose -WarningAction SilentlyContinue -ErrorAction Stop` against the test-scope orchestrator mock and assert that `$PesterBoundParameters` contains the key `Verbose` with value `$true`, contains the key `WarningAction` with value `SilentlyContinue`, and does not contain the key `ErrorAction`; keep the Describe at `:143-152` with its single `It` unchanged.
  - Acceptance: the file exists, is at most 500 lines, follows the Test design rules, contains the five AC tokens assigned to it, contains the literal `scaffold extension package identity` exactly once, and contains no occurrence of `Import-ScriptFunction`.
- [ ] [P5-T8] Write `docs/features/active/2026-10-08-powershell-aggregate-line-coverage-below-floor-847/evidence/qa-gates/targeted-all.<ts>.md` from a targeted in-process Pester run of all TEST11 files with coverage over PROD8
  - Command: the P1-T3 command with `Run.Path` = the TEST11 array, `CodeCoverage.Path` = the PROD8 array plus `'scripts/dev-tools/vscode-cli.helpers.ps1'`, and output paths `artifacts/pester/847-targeted-p5.xml` and `artifacts/pester/847-targeted-p5-junit.xml`.
  - Acceptance: derived `EXIT_CODE:` 0; JRP steps 2-3 pass for all eleven files; JRP step 4 passes for all 32 tokens in the AC test token table; CRP per-file passes for each of the eight PROD8 files. This is a development gate; AC-03 is decided by P7-T5.

### Phase 6 — Follow-up Record

- [ ] [P6-T1] Create `docs/features/potential/2026-10-09-host-tools-manifest-and-bash-bootstrap-missing.md` from `docs/features/potential/template.md` recording the pre-existing missing-file defect (AC-14)
  - Required content: `Date captured: 2026-10-09`; origin issue #847; Problem stating that `scripts/host-tools.manifest.json` is read by `bootstrap-host.ps1` (now through `HostBootstrap.psm1`) and `verify-host.ps1` (now through `HostVerification.psm1`) but does not exist, so both scripts fail early on every host, and that the bootstrap non-Windows error message refers to `scripts/bash/bootstrap-host.sh`, which does not exist; Proposed Behavior (restore or relocate the manifest and either add the bash script or correct the message); draft acceptance criteria; Next Step checkboxes.
  - Acceptance: the file exists; `Select-String -LiteralPath docs/features/potential/2026-10-09-host-tools-manifest-and-bash-bootstrap-missing.md -SimpleMatch -Pattern 'host-tools.manifest.json'` returns at least one match; the same command with the pattern `bootstrap-host.sh` returns at least one match; the file contains `#847`.

### Phase 7 — Final QA Loop and Acceptance Evidence

Loop rule: P7-T1, P7-T2, and P7-T3 form the PowerShell toolchain loop (format, then analyze, then test; type checking is not applicable). If P7-T1 rewrites any file, or P7-T2 reports any error or warning, or P7-T3 fails, the executor fixes the cause and restarts at P7-T1. P7-T4 onward run only after one pass in which P7-T1 to P7-T3 all pass with no file changed.

- [ ] [P7-T1] Write `docs/features/active/2026-10-08-powershell-aggregate-line-coverage-below-floor-847/evidence/qa-gates/pwsh-format.<ts>.md` from the PoshQC formatter run in write mode over the CPFS files only
  - Command: `$before = $cpfs | ForEach-Object { (Get-FileHash -Algorithm SHA256 -LiteralPath $_).Hash }; Import-Module ./scripts/powershell/PoshQC/PoshQC.psd1 -Force; $log = Invoke-PoshQCFormat -Root (Get-Location).Path -GetFileList { param($RootPath, $ScanFoldersPath, $Excluded) $cpfs | ForEach-Object { Get-Item -LiteralPath $_ } } 6>&1 | ForEach-Object { "$_" }; $after = $cpfs | ForEach-Object { (Get-FileHash -Algorithm SHA256 -LiteralPath $_).Hash }; $log; "UNCHANGED_HASHES=$(@(0..18 | Where-Object { $before[$_] -eq $after[$_] }).Count)"`
  - Success-case observation beyond the exit code: the formatter logs `Already formatted: <path>` for a file it did not change and `Formatted: <path>` for a file it rewrote (`scripts/powershell/PoshQC/PoshQC.Analyzer.psm1:60-65`). Acceptance: exactly 19 log lines begin with `Already formatted: `, zero log lines begin with `Formatted: `, and `UNCHANGED_HASHES=19` (SHA256 of every CPFS file identical before and after). Any other result means the formatter rewrote files: record it, and restart the loop at P7-T1.
- [ ] [P7-T2] Write `docs/features/active/2026-10-08-powershell-aggregate-line-coverage-below-floor-847/evidence/qa-gates/pwsh-analyze.<ts>.md` from per-file PSScriptAnalyzer runs on the CPFS files
  - Command: the P0-T4 command with `$cpfs` in place of the BASE5 array.
  - Acceptance: 19 summary lines, each with `errors=0` and `warnings=0` (`ParseError` counted as an error); Information findings are listed and not gated. Any error or warning restarts the loop at P7-T1 after the fix, subject to the `PSShouldProcess` contingency in the Design Contract.
- [ ] [P7-T3] Write `docs/features/active/2026-10-08-powershell-aggregate-line-coverage-below-floor-847/evidence/qa-gates/pwsh-test-full.<ts>.md` from FULL_RUN with `<phase>` = `final` (AC-11 test stage)
  - Acceptance: FULL_RUN validity conditions (a) to (c) hold; `EXIT_CODE:` is 0; JRP step 5 on `artifacts/pester/pester-junit.xml` reports `failures="0"`, `errors="0"`, and zero `Failed` testcases. If failures remain and every failing testcase also appears in the P0-T5 baseline failure set, the artifact records them as `PRE-EXISTING FAILURES`, the task stays unchecked, and the executor stops for re-planning instead of editing unrelated files.
- [ ] [P7-T4] Write `docs/features/active/2026-10-08-powershell-aggregate-line-coverage-below-floor-847/evidence/qa-gates/coverage-aggregate.<ts>.md` applying CRP to the P7-T3 `artifacts/pester/powershell-coverage.xml` (AC-02)
  - Acceptance: the artifact records the four schema fields and, in `Output Summary:`, the baseline aggregate from P0-T5, the post-change aggregate (`covered`, `missed`, `total`, percentage, required covered lines), the delta in covered lines and percentage points, and the new/changed-code coverage computed as the sum of covered over the sum of total across the eight PROD8 rows. PASS if and only if the CRP threshold holds for the aggregate. If it does not, the artifact also records the gap per CRP step 5 and the task stays unchecked; the executor stops for re-planning (Coverage-gap stop rule).
- [ ] [P7-T5] Write `docs/features/active/2026-10-08-powershell-aggregate-line-coverage-below-floor-847/evidence/qa-gates/coverage-per-file.<ts>.md` applying CRP per-file with `D` = `scripts/dev-tools` to the P7-T3 coverage XML (AC-03)
  - Acceptance: one row per PROD8 file name (`HostTooling.psm1`, `HostBootstrapWorkspace.psm1`, `HostBootstrap.psm1`, `HostVerification.psm1`, `SideloadedExtensionPublish.psm1`, `bootstrap-host.ps1`, `verify-host.ps1`, `publish-sideloaded-extension.ps1`) with `covered`, `missed`, percentage, and PASS/FAIL; every row PASS; a lookup for `bootstrap-host.helpers.ps1` returns zero sourcefile rows (the file left the population); the `vscode-cli.helpers.ps1` row is recorded for information.
- [ ] [P7-T6] Write `docs/features/active/2026-10-08-powershell-aggregate-line-coverage-below-floor-847/evidence/qa-gates/pester-suite-results.<ts>.md` applying JRP to the P7-T3 `artifacts/pester/pester-junit.xml` for TEST11 and all AC tokens (AC-05, AC-06)
  - Acceptance: for each of the eleven TEST11 files, JRP steps 2-3 pass and the testcase count is recorded; for each of the 32 tokens in the AC test token table, JRP step 4 passes and the matching testcase names are listed.
- [ ] [P7-T7] Write `docs/features/active/2026-10-08-powershell-aggregate-line-coverage-below-floor-847/evidence/qa-gates/test-isolation-search.<ts>.md` from a search of TEST11 for temporary-file usage (AC-07)
  - Command: `git grep --untracked -n -F -e 'TestDrive:' -e 'New-TemporaryFile' -e 'GetTempPath' -e '$env:TEMP' -e '$env:TMP' -- <the eleven TEST11 paths>; "EXIT_CODE=$LASTEXITCODE"`
  - Acceptance: no match lines are printed and `EXIT_CODE=1` (git grep exits 1 when nothing matches); the artifact also cites the P7-T6 artifact as the record that all TEST11 suites passed with the fail-closed default mocks in place.
- [ ] [P7-T8] Write `docs/features/active/2026-10-08-powershell-aggregate-line-coverage-below-floor-847/evidence/qa-gates/import-scriptfunction-search.<ts>.md` from a search of TEST11 for `Import-ScriptFunction` and for the retained Describe (AC-08)
  - Command: `git grep --untracked -n -F -e 'Import-ScriptFunction' -- <the eleven TEST11 paths>; "EXIT_CODE=$LASTEXITCODE"; @(Select-String -LiteralPath tests/scripts/dev-tools/publish-sideloaded-extension.Tests.ps1 -SimpleMatch -Pattern 'scaffold extension package identity').Count`
  - Acceptance: the git grep prints no match lines with `EXIT_CODE=1`, and the Select-String count is exactly 1.
- [ ] [P7-T9] Write `docs/features/active/2026-10-08-powershell-aggregate-line-coverage-below-floor-847/evidence/qa-gates/module-preference-and-exit-check.<ts>.md` from an AST and line check of the five new modules and three entry scripts (AC-09)
  - Command: `foreach ($m in @('scripts/dev-tools/HostTooling.psm1', 'scripts/dev-tools/HostBootstrapWorkspace.psm1', 'scripts/dev-tools/HostBootstrap.psm1', 'scripts/dev-tools/HostVerification.psm1', 'scripts/dev-tools/SideloadedExtensionPublish.psm1')) { $a = [System.Management.Automation.Language.Parser]::ParseFile((Resolve-Path $m).Path, [ref]$null, [ref]$null); '{0} strict={1} eap={2} exit={3}' -f $m, @(Select-String -LiteralPath $m -CaseSensitive -Pattern '^Set-StrictMode -Version Latest\s*$').Count, @(Select-String -LiteralPath $m -CaseSensitive -Pattern '^\$ErrorActionPreference = ''Stop''\s*$').Count, @($a.FindAll({ param($n) $n -is [System.Management.Automation.Language.ExitStatementAst] }, $true)).Count }; foreach ($e in @('scripts/dev-tools/bootstrap-host.ps1', 'scripts/dev-tools/verify-host.ps1', 'scripts/dev-tools/publish-sideloaded-extension.ps1')) { $a = [System.Management.Automation.Language.Parser]::ParseFile((Resolve-Path $e).Path, [ref]$null, [ref]$null); $imports = @($a.FindAll({ param($n) $n -is [System.Management.Automation.Language.CommandAst] -and $n.GetCommandName() -eq 'Import-Module' }, $true)); '{0} imports={1} forced={2}' -f $e, $imports.Count, @($imports | Where-Object { @($_.CommandElements | Where-Object { $_ -is [System.Management.Automation.Language.CommandParameterAst] -and $_.ParameterName -eq 'Force' }).Count -gt 0 }).Count }`
  - Acceptance: each module line reads `strict=1 eap=1 exit=0`; each entry line reads `imports=1 forced=0`.
- [ ] [P7-T10] Write `docs/features/active/2026-10-08-powershell-aggregate-line-coverage-below-floor-847/evidence/qa-gates/helper-reference-search.<ts>.md` confirming `scripts/dev-tools/bootstrap-host.helpers.ps1` is gone and unreferenced outside `docs/features/` (AC-10)
  - Command: `Test-Path -LiteralPath scripts/dev-tools/bootstrap-host.helpers.ps1; git grep --untracked -n -F -e 'bootstrap-host.helpers' -- . ':(exclude)docs/features'; "EXIT_CODE=$LASTEXITCODE"`
  - Acceptance: `Test-Path` prints `False`; git grep prints no match lines and `EXIT_CODE=1`. Before this change the token `bootstrap-host.helpers` appears outside `docs/features/` only in `scripts/dev-tools/bootstrap-host.ps1:23`, so the search can fail if the entry rewrite or a new module reintroduces it.
- [ ] [P7-T11] Write `docs/features/active/2026-10-08-powershell-aggregate-line-coverage-below-floor-847/evidence/qa-gates/file-size-check.<ts>.md` recording the line count of every CPFS file (AC-12)
  - Command: `foreach ($f in $cpfs) { '{0} lines={1}' -f $f, @(Get-Content -LiteralPath $f).Count }`
  - Acceptance: 19 lines, every `lines=` value at most 500. No evidence `.ps1` or `.psm1` file is created by this plan.
- [ ] [P7-T12] Write `docs/features/active/2026-10-08-powershell-aggregate-line-coverage-below-floor-847/evidence/qa-gates/scope-boundary-check.<ts>.md` from an anchored diff plus porcelain status against BASE_SHA (AC-13)
  - Command: Run `git diff --name-only BASE_SHA`, then run `git status --porcelain=v1 --untracked-files=all` (BASE_SHA read from the P0-T2 artifact). The anchored diff lists tracked changes, including committed ones; the porcelain status lists untracked files the diff cannot see, each as its own path because `--untracked-files=all` does not collapse untracked directories.
  - Path derivation (fixed): the diff paths are the diff output lines. For each status line, the path is `$line.Substring(3)`; when that value contains ` -> `, the path is the part after ` -> `. The checks below apply to the union of the diff paths and the status paths. The artifact records the diff path list and the status path list separately.
  - Acceptance: no path in the union starts with `.codex/`, `.claude/rules/`, `.github/instructions/`, `scripts/powershell/PoshQC/`, or `extensions/drm-copilot/resources/`; no path in the union equals `.claude/hooks/validate-feature-review-coverage.ps1`, `config/poshqc-coverage.json`, `quality-tiers.yml`, `config/blast-radius.json`, `.vscode/tasks.json`, or `scripts/dev-tools/vscode-cli.helpers.ps1`; no path in the union ends with `.psd1`. Any path in the union that is neither in the "Files Written by This Plan" list nor under FEATURE is recorded in the artifact as `UNPLANNED: <path>` and reported to the caller; it fails AC-13 only if it matches one of the forbidden entries above.
- [ ] [P7-T13] Write `docs/features/active/2026-10-08-powershell-aggregate-line-coverage-below-floor-847/evidence/qa-gates/entry-param-block-parity.<ts>.md` comparing the AST param blocks and the unchanged leading lines of the three entry scripts at BASE_SHA and in the worktree (AC-04)
  - Derivation (fixed): for each of `scripts/dev-tools/bootstrap-host.ps1`, `scripts/dev-tools/verify-host.ps1`, `scripts/dev-tools/publish-sideloaded-extension.ps1`, parse the base text `(git show "BASE_SHA:<path>") -join [string][char]10` with `[System.Management.Automation.Language.Parser]::ParseInput` and the worktree file with `ParseFile`. From each `ParamBlock` build the ordered list: one entry per `ParamBlock.Attributes` element (its `Extent.Text`, which carries the `CmdletBinding` arguments), then one entry per parameter of the form `Name=<VariablePath.UserPath>;Type=<StaticType.FullName>;Default=<DefaultValue.Extent.Text or <none>>;Attributes=<attribute Extent.Text values joined by |>`. Compare the base and worktree lists element by element.
  - Prefix derivation (fixed): for each script with N = 18 (`scripts/dev-tools/bootstrap-host.ps1`), N = 3 (`scripts/dev-tools/verify-host.ps1`), and N = 51 (`scripts/dev-tools/publish-sideloaded-extension.ps1`), the base side is `@(git show "BASE_SHA:<path>")[0..(N-1)] -replace "\r$", ''` and the worktree side is `@(Get-Content -LiteralPath <path> -TotalCount N)`. Require both sides to have N elements, then compare element by element with `-cne`; each differing index counts as one difference.
  - Acceptance: the artifact records the four schema fields, both param-block lists for each script, `DIFFERENCES=0` for each of the three scripts, and `PREFIX_DIFFERENCES=0` for each of the three scripts.
- [ ] [P7-T14] Write `docs/features/active/2026-10-08-powershell-aggregate-line-coverage-below-floor-847/evidence/qa-gates/toolchain-loop-closure.<ts>.md` confirming the format, analyze, and test stages passed in one pass over the CPFS files (AC-11)
  - Acceptance: the artifact cites the P7-T1, P7-T2, and P7-T3 artifacts from the same pass; records that the CPFS SHA256 list captured at the start of P7-T1 equals the list captured after P7-T3 (`UNCHANGED_HASHES=19` recomputed after P7-T3); records the number of loop iterations; and lists type checking, architecture-boundary tests, contract/schema checks, and integration tests as not applicable with the reason from spec Test Strategy.

## Files Written by This Plan

Production (new): `scripts/dev-tools/HostTooling.psm1`, `scripts/dev-tools/HostBootstrapWorkspace.psm1`, `scripts/dev-tools/HostBootstrap.psm1`, `scripts/dev-tools/HostVerification.psm1`, `scripts/dev-tools/SideloadedExtensionPublish.psm1`.

Production (modified): `scripts/dev-tools/bootstrap-host.ps1`, `scripts/dev-tools/verify-host.ps1`, `scripts/dev-tools/publish-sideloaded-extension.ps1`.

Production (deleted): `scripts/dev-tools/bootstrap-host.helpers.ps1`.

Tests (new): `tests/scripts/dev-tools/HostTooling.Tests.ps1`, `tests/scripts/dev-tools/HostBootstrapWorkspace.Tests.ps1`, `tests/scripts/dev-tools/HostBootstrap.Tests.ps1`, `tests/scripts/dev-tools/HostBootstrap.Invoke.Tests.ps1`, `tests/scripts/dev-tools/HostVerification.Tests.ps1`, `tests/scripts/dev-tools/HostVerification.Invoke.Tests.ps1`, `tests/scripts/dev-tools/SideloadedExtensionPublish.Tests.ps1`, `tests/scripts/dev-tools/SideloadedExtensionPublish.Invoke.Tests.ps1`, `tests/scripts/dev-tools/bootstrap-host.Tests.ps1`, `tests/scripts/dev-tools/verify-host.Tests.ps1`.

Tests (rewritten): `tests/scripts/dev-tools/publish-sideloaded-extension.Tests.ps1`.

Follow-up record (new): `docs/features/potential/2026-10-09-host-tools-manifest-and-bash-bootstrap-missing.md`.

Feature documentation and evidence (feature-folder private): this plan file `docs/features/active/2026-10-08-powershell-aggregate-line-coverage-below-floor-847/plan.2026-10-08T23-43.md`; evidence artifacts under `docs/features/active/2026-10-08-powershell-aggregate-line-coverage-below-floor-847/evidence/baseline/` (`phase0-instructions-read.md`, `branch-base.<ts>.md`, `pwsh-format-baseline.<ts>.md`, `pwsh-analyze-baseline.<ts>.md`, `pwsh-test-coverage-baseline.<ts>.md`) and `docs/features/active/2026-10-08-powershell-aggregate-line-coverage-below-floor-847/evidence/qa-gates/` (`targeted-hosttooling.<ts>.md`, `targeted-hostbootstrap.<ts>.md`, `targeted-hostverification.<ts>.md`, `targeted-publish.<ts>.md`, `targeted-all.<ts>.md`, `pwsh-format.<ts>.md`, `pwsh-analyze.<ts>.md`, `pwsh-test-full.<ts>.md`, `coverage-aggregate.<ts>.md`, `coverage-per-file.<ts>.md`, `pester-suite-results.<ts>.md`, `test-isolation-search.<ts>.md`, `import-scriptfunction-search.<ts>.md`, `module-preference-and-exit-check.<ts>.md`, `helper-reference-search.<ts>.md`, `file-size-check.<ts>.md`, `scope-boundary-check.<ts>.md`, `entry-param-block-parity.<ts>.md`, `toolchain-loop-closure.<ts>.md`).

Generated, git-ignored, not committed (`/artifacts` is ignored): the directory `artifacts/pester/` (created by FULL_RUN in P0-T5), `artifacts/pester/powershell-coverage.xml`, `artifacts/pester/powershell-coverage.koverage.xml`, `artifacts/pester/pester-junit.xml`, `artifacts/pester/847-baseline-poshqc.log`, `artifacts/pester/847-final-poshqc.log`, and `artifacts/pester/847-targeted-p1.xml` to `artifacts/pester/847-targeted-p5-junit.xml`.

## Files Explicitly Not Written

- `config/poshqc-coverage.json`, `scripts/powershell/PoshQC/settings/pester.runsettings.psd1`, and `quality-tiers.yml` are unchanged: new `.psm1` files directly under `scripts/dev-tools/` are discovered by the existing `scripts` coverage root and belong to the existing T4 `scripts/dev-tools` project (research section 4). No bundled mirror under `extensions/drm-copilot/resources/` changes, because no mirrored file is edited.
- `.claude/hooks/validate-feature-review-coverage.ps1` is not written (shared with #824).
- `config/blast-radius.json`, `.vscode/tasks.json`, `scripts/dev-tools/vscode-cli.helpers.ps1`, `.codex/**`, `.claude/rules/**`, `.github/instructions/**`, and `scripts/powershell/PoshQC/**` are not written.

## AC Traceability

| AC | Implementation | Tests | Evidence |
|---|---|---|---|
| AC-01 | P0-T2, P0-T5 | FULL_RUN baseline | `evidence/baseline/pwsh-test-coverage-baseline.<ts>.md` |
| AC-02 | P1 to P5 | FULL_RUN final (P7-T3) | `evidence/qa-gates/coverage-aggregate.<ts>.md` |
| AC-03 | P1-T1, P2-T1, P2-T2, P3-T1, P4-T1, P5-T1 to P5-T3 | TEST11 | `evidence/qa-gates/coverage-per-file.<ts>.md` |
| AC-04 | P5-T1 to P5-T3 | AST comparison | `evidence/qa-gates/entry-param-block-parity.<ts>.md` |
| AC-05 | P5-T1 to P5-T3 | P5-T5, P5-T6, P5-T7 tokens | `evidence/qa-gates/pester-suite-results.<ts>.md` |
| AC-06 | P2-T2, P3-T1, P4-T1 | P2-T4, P2-T5, P3-T3, P4-T2, P4-T3 tokens | `evidence/qa-gates/pester-suite-results.<ts>.md` |
| AC-07 | Test design rules | P7-T7 search plus P7-T6 | `evidence/qa-gates/test-isolation-search.<ts>.md` |
| AC-08 | P5-T7 | P7-T8 search | `evidence/qa-gates/import-scriptfunction-search.<ts>.md` |
| AC-09 | P1-T1, P2-T1, P2-T2, P3-T1, P4-T1, P5-T1 to P5-T3 | P7-T9 AST check | `evidence/qa-gates/module-preference-and-exit-check.<ts>.md` |
| AC-10 | P5-T4 | P7-T10 search | `evidence/qa-gates/helper-reference-search.<ts>.md` |
| AC-11 | P7 loop | P7-T1 to P7-T3 | `evidence/qa-gates/pwsh-format.<ts>.md`, `pwsh-analyze.<ts>.md`, `pwsh-test-full.<ts>.md`, `toolchain-loop-closure.<ts>.md` |
| AC-12 | all CPFS writes | P7-T11 | `evidence/qa-gates/file-size-check.<ts>.md` |
| AC-13 | Excluded-path rule | P7-T12 | `evidence/qa-gates/scope-boundary-check.<ts>.md` |
| AC-14 | P6-T1 (entry file); PR-description reference is performed by the later PR-authoring stage of the parallel orchestration, outside this plan | P6-T1 Select-String checks | `docs/features/potential/2026-10-09-host-tools-manifest-and-bash-bootstrap-missing.md`; PR body (later stage) |
| AC-15 | Later CI stage of the parallel orchestration, outside this plan (CI-dependent) | CI `poshqc` job on the PR head; local proxy P7-T3 | PR checks (later stage) |

PR authoring, CI monitoring, and feature review are excluded from this plan and run in the later orchestration stages.

## Revision Log

- 1.0 (2026-10-09): replaced the generic bug template with the atomic plan.
- 1.1 (2026-10-09): applied preflight round 1 deltas 1-9. Bootstrap and verify entry catch bodies set `$LASTEXITCODE` 1 and rethrow (with a fixed PSAvoidGlobalVars fallback); the bootstrap entry keeps the dot-source guard; the publish entry forwards `Verbose` and `WarningAction`; `Get-HostToolsManifestPath` keeps the unnormalized path; FULL_RUN creates `artifacts/pester/`; P0-T2 and P7-T12 use split spans, `--untracked-files=all`, and a fixed path derivation; P7-T13 adds the leading-line prefix comparison; P5-T4 names `scripts/dev-tools/HostBootstrapWorkspace.psm1`; `Install-PoetryWithPip` preserves pip output. Added the Assumptions and Advisories section and a `$LASTEXITCODE` sentinel in AC-05 entry tests.
