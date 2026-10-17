# Research: PowerShell aggregate line coverage below floor (Issue #847)

- Issue: #847
- Branch: bug/powershell-aggregate-line-coverage-below-floor-847
- Timestamp: 2026-10-08T23-50
- Scope (operator decision, fixed): refactor `scripts/dev-tools/bootstrap-host.ps1`, `scripts/dev-tools/verify-host.ps1`, and `scripts/dev-tools/publish-sideloaded-extension.ps1` into thin entry points plus host-neutral `.psm1` modules with Pester tests. Preserve external behavior and parameters. No `.codex/scripts` changes. No production coverage exclusions.
- Method: static reading only. No host script was executed; the Pester suite was not run.

## Summary of Findings

1. The three scripts are 0% covered for two different reasons. `bootstrap-host.ps1` and `verify-host.ps1` have no tests at all. `publish-sideloaded-extension.ps1` has tests (`tests/scripts/dev-tools/publish-sideloaded-extension.Tests.ps1`), but they load functions through `Import-ScriptFunction`, which re-parses the function text with `Parser::ParseInput` (`tests/scripts/powershell/Support/TestHelpers.ps1:27-34`). The re-parsed text starts at line 1, so Pester coverage breakpoints on the original file never fire. The repository records this cause at `tests/scripts/dev-tools/new-claude-worktree-session.Tests.ps1:4-7`. The new tests must not use `Import-ScriptFunction`.
2. The aggregate floor needs 53 more covered lines on the current denominator. Under conservative assumptions the refactor raises the aggregate to about 87.1% (margin of about 327 lines). The three scripts alone are enough, so no additional target is needed. The binding constraint is the per-file rule ("every modified or new file >= 85%"), which also applies to the three thin entry scripts. Each entry script therefore needs an in-process invocation test.
3. Placing the new `.psm1` files directly in `scripts/dev-tools/`, with no `.psd1`, means `config/poshqc-coverage.json`, the runsettings, `quality-tiers.yml`, and the bundled PoshQC mirror all stay unchanged.
4. The manifest both host scripts read, `scripts/host-tools.manifest.json` (resolved as `$PSScriptRoot\..\host-tools.manifest.json` at `bootstrap-host.ps1:35` and `verify-host.ps1:13`), does not exist in this working tree. `scripts/bash/bootstrap-host.sh`, which `bootstrap-host.ps1:340` refers to, does not exist either. As checked in, both scripts fail early on every host. Preserving behavior means keeping those failure paths. This is reported here as a separate pre-existing defect, not something to fix in #847.
5. Module functions do not inherit the calling script's `$ErrorActionPreference = "Stop"` or `Set-StrictMode`. Each module must set both at its top level so that existing terminating-error behavior is preserved, including `Write-Error` acting as a terminating error.

## 1. Script Inventory, Side Effects, and Classification

Classification key: **(a)** pure or host-neutral logic that can move to a module and be tested directly; **(b)** host I/O that must sit behind a mockable seam (a wrapper function mocked with `Mock -ModuleName`, or an injected scriptblock).

### 1.1 `scripts/dev-tools/bootstrap-host.ps1` (484 lines; 0/177 executable lines covered)

Parameter surface (`bootstrap-host.ps1:2-18`): `[CmdletBinding()]`; `-Apply` (switch), `-EnableAutoResumeAfterReboot` (switch), `-WorkspaceRoot` (string, no default), `-RepoRoot` (string, no default), `-SkipProjectPoetryInstall` (switch). No `SupportsShouldProcess` at script level. Script scope sets `Set-StrictMode -Version Latest` and `$ErrorActionPreference = "Stop"` (`:20-21`). It dot-sources `bootstrap-host.helpers.ps1` and throws if that file is missing (`:23-28`). The entry guard is `if ($MyInvocation.InvocationName -ne '.')`, which calls `Invoke-BootstrapHost` (`:482-484`).

Output and exit contract:
- All status lines go through `Write-Output` (stdout).
- Precondition failures use `Write-Error` followed by `exit 1` (`:339-347`). Under `$ErrorActionPreference = "Stop"`, `Write-Error` is terminating, so `exit 1` is never reached. The observable contract is an error record on stderr and process exit code 1 under `pwsh -File`.
- `Invoke-VerifyHostScript` runs `verify-host.ps1` through `&` (`:134`). Its `exit` ends only the child script and sets `$LASTEXITCODE`; bootstrap ignores that value.

Functions (15 in the script plus 6 in the dot-sourced helper file):

| Function | Lines | Side effects | Class |
|---|---|---|---|
| `Get-HostManifest` | 30-41 | Reads `..\host-tools.manifest.json` (Test-Path, Get-Content); throws "Host tools manifest not found at ..." | (b) read seam; parsing is (a) |
| `Install-WithWinget` | 43-89 | `Get-Command $Name`; calls `Invoke-WingetExe`; falls back to `Install-PoetryWithPip` when `$Name -eq "poetry"` | (a) decision logic over (b) seams |
| `Invoke-WingetExe` | 91-102 | Runs `winget`; throws on nonzero `$LASTEXITCODE` | (b) |
| `Invoke-NpmExe` | 104-112 | Runs `npm`; no exit-code check | (b) |
| `Invoke-WslExe` | 114-125 | Runs `wsl`; throws on nonzero | (b) |
| `Invoke-VerifyHostScript` | 127-135 | `& $ScriptPath` | (b) |
| `Invoke-PoetryExe` | 137-163 | Runs `poetry`, or `python -m poetry` as fallback; throws on nonzero | (b) |
| `Get-SessionPathFromMachineAndUser` | 165-176 | Reads Machine/User `Path` environment variables | (b) env read; join is (a) |
| `Add-DirectoryToUserPath` | 178-201 | Test-Path; reads and **writes** the User `Path` variable (`SetEnvironmentVariable`, `:200`) | (a) dedupe logic, (b) env read/write |
| `Install-PoetryWithPip` | 203-241 | Get-Command; `python -m pip install --user poetry`; Get-ChildItem under `$env:APPDATA\Python`; sets `$env:Path` | (a) flow, (b) process/env/fs |
| `Install-WslIfMissing` | 243-262 | Get-Command `wsl`; `Invoke-WslExe --install --no-distribution` | (a) over (b) |
| `Get-WingetPackagesFromManifest` | 264-278 | none; throws when list is empty | (a) |
| `Set-BootstrapResumeRunOnce` | 280-297 | Registry `HKCU:\...\RunOnce`: New-Item, New-ItemProperty; ShouldProcess; uses `$PSScriptRoot` to build the resume command | (a) command-string build, (b) registry |
| `Remove-BootstrapResumeRunOnce` | 299-311 | Registry Test-Path, Remove-ItemProperty; ShouldProcess | (b) |
| `Invoke-BootstrapHost` | 313-480 | Orchestrator: Get-Command winget/npm, `Install-Module` (`:406`), Push/Pop-Location, sets `$env:Path` (`:385`), every seam above | (a) orchestration over (b) seams |

Helper file `scripts/dev-tools/bootstrap-host.helpers.ps1` (149 lines; 0/43 covered; dot-sourced only by `bootstrap-host.ps1`):

| Function | Lines | Side effects | Class |
|---|---|---|---|
| `Invoke-GitExe` | 4-15 | Runs `git`; throws on nonzero | (b) |
| `Get-ProjectRepositoriesFromManifest` | 17-30 | none | (a) |
| `Resolve-WorkspaceRoot` | 32-47 | Get-Location | (a) apart from the cwd read |
| `Initialize-WorkspaceRoot` | 49-71 | Test-Path; New-Item directory | (a) over (b) |
| `Sync-ProjectsFromManifest` | 73-115 | Test-Path; `git clone` | (a) over (b) |
| `Resolve-ProjectRepoRoot` | 117-149 | Test-Path on `pyproject.toml`; uses `$PSScriptRoot\..\..` (`:137`) | (a) over (b) |

### 1.2 `scripts/dev-tools/verify-host.ps1` (325 lines; 0/153 covered)

Parameter surface (`verify-host.ps1:2-3`): `[CmdletBinding()] param()`, with no parameters. Script scope sets StrictMode Latest and EAP Stop (`:5-6`). There is no dot-source guard. Most of the logic (`:178-325`) runs at top level, which is why it cannot be tested today.

Output and exit contract:
- If the manifest is missing: `Write-Error "Manifest not found at ..."` then `exit 1` (`:179-182`). Under EAP Stop this is terminating, so the exit code is 1.
- Status lines go through `Write-Output`, using `[OK]`/`[FAIL]`/`[WARN]` prefixes in five sections: Core versions, Required commands, Optional commands, PowerShell modules, Poetry quality tools.
- Final result: `exit 0` with "[OK] Host verification passed", or `exit 1` with "[WARN] Host verification failed with N issue(s)" and "Run: ./scripts/dev-tools/bootstrap-host.ps1 -Apply" (`:316-325`).
- Side effect: overwrites `$env:Path` from the Machine and User values (`:187-190`).

Functions (7) and top-level blocks:

| Item | Lines | Side effects | Class |
|---|---|---|---|
| `Get-ManifestPath` | 8-14 | none (path join on `$PSScriptRoot`) | (a) |
| `Get-CommandVersion` | 16-48 | Get-Command; runs `& $commandInfo.Source @VersionArgs` | (a) regex parse, (b) process |
| `Get-PoetryVersionInfo` | 50-105 | Get-Command poetry/python; `python -m poetry --version`; reads `$LASTEXITCODE` | (a) parse, (b) process |
| `Get-SessionPathFromMachineAndUser` | 107-118 | env read (identical to `bootstrap-host.ps1:165-176`) | (b) |
| `Invoke-PoetryCommand` | 120-138 | runs poetry or `python -m poetry` | (b) |
| `Test-VersionAtLeast` | 140-157 | none | (a) |
| `Get-RequiredCommandsForHost` | 159-176 | none (`$IsWindows` default) | (a) |
| Top-level: manifest load | 178-185 | Test-Path, Get-Content | (b) |
| Top-level: version checks | 199-241 | Get-Command, process calls | (a) over (b) |
| Top-level: required/optional commands | 243-269 | Get-Command | (a) over (b) |
| Top-level: PowerShell modules | 271-292 | `Get-Module -ListAvailable` | (a) over (b) |
| Top-level: Poetry tools | 294-314 | `poetry run <tool> --version`; reads `$LASTEXITCODE` (`:305`) | (a) over (b) |
| Top-level: summary and exit | 316-325 | `exit` | entry-point only |

### 1.3 `scripts/dev-tools/publish-sideloaded-extension.ps1` (403 lines; 0/138 covered)

Parameter surface (`publish-sideloaded-extension.ps1:23-51`): `[CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = "Medium")]`.

| Parameter | Type | Default |
|---|---|---|
| `-RepoRoot` | string, ValidateNotNullOrEmpty | `(Resolve-Path (Join-Path $PSScriptRoot "..\..")).Path` |
| `-CodeCommand` | string, AllowEmptyString | `""` |
| `-UseInsiders` | switch | n/a |
| `-VsixOutputDir` | string, ValidateNotNullOrEmpty | `(Join-Path $RepoRoot "artifacts\vsix")` |
| `-SkipNpmCi`, `-SkipCompile`, `-SkipInstall`, `-Force` | switch | n/a |

`-WhatIf` and `-Confirm` come from `SupportsShouldProcess`. The script dot-sources `vscode-cli.helpers.ps1` (`:56`). It has no dot-source guard: the top-level body (`:334-403`) runs on every load.

Output and exit contract:
- Failures are thrown errors (pwsh exit code 1).
- `Write-Information` prints "VSIX created: ..." and, if `-SkipInstall`, "Install skipped ..." (`:397-400`).
- `Write-Output $vsixPath` is the final pipeline value (`:403`); the comment at `:402` identifies it as a consumer contract.
- Native tool output is not captured. `Invoke-ExternalCommand` runs `cmd.exe /c` through `Start-Process -NoNewWindow -Wait -PassThru` (`:172-181`), so the tool writes directly to the console.
- `.vscode/tasks.json:208-225` calls the script with `-Force`.

Functions (7 top-level plus 1 nested) and top-level blocks:

| Item | Lines | Side effects | Class |
|---|---|---|---|
| `Get-PackageManifest` | 58-76 | Test-Path, Get-Content | (a) parse, (b) read |
| `Test-IsVsCodeExtensionManifest` | 78-97 | none | (a) |
| `Resolve-ExtensionProjectRoot` | 99-144 | Test-Path; reads through `Get-PackageManifest` | (a) over (b) |
| `Invoke-ExternalCommand` | 146-190 | `Start-Process cmd.exe`; throws an exception with `Data["ExitCode"]` | (b) |
| `Assert-RequiredCommandAvailable` | 192-217 | Get-Command | (a) over (b) |
| `Invoke-NpmCiWithRetry` | 219-299 | npm ci; EPERM retry; `Start-Sleep` (`:295`); optionally Stop-Process node, Remove-Item node_modules, `npm cache clean` | (a) retry policy, (b) process/fs/sleep |
| nested `Stop-NodeProcess` | 238-252 | Get-Process, Stop-Process | (b) |
| `Invoke-ProjectCompile` | 301-332 | `npm run compile` or `npx tsc` | (a) selection, (b) process |
| Top-level flow | 334-403 | Test-Path, New-Item output dir, `Get-Date` timestamp (`:354`), ShouldProcess gates, `Resolve-VSCodeCliCommand`, `code --install-extension` | (a) orchestration over (b) |

Behavior detail to preserve: `$PSBoundParameters.ContainsKey('CodeCommand')` (`:378`) separates "not supplied" from "supplied as empty string". The entry point must forward `CodeCommand` only when the caller bound it.

### 1.4 Proposed Module Boundaries

The modules go directly in `scripts/dev-tools/`. That keeps `$PSScriptRoot`-relative paths unchanged: `..\host-tools.manifest.json`, `..\..` as repo root, and the sibling `bootstrap-host.ps1` and `verify-host.ps1` references. It also avoids creating a new quality-tiers project (section 4). Each module sets `Set-StrictMode -Version Latest` and `$ErrorActionPreference = 'Stop'` at module scope, ends with `Export-ModuleMember -Function ...`, and stays under 500 lines.

**`scripts/dev-tools/HostTooling.psm1`** (shared by bootstrap and verify; removes the duplicated `Get-SessionPathFromMachineAndUser`)
- `Get-HostToolsManifestPath` -> `[string]` (`$PSScriptRoot\..\host-tools.manifest.json`)
- `Read-HostToolsManifest -Path <string>` -> `[psobject]` or `$null` when the file is absent. Each caller keeps its own message and failure mode.
- `Get-SessionPathFromMachineAndUser` -> `[string]` (unchanged body)
- `Get-HostEnvironmentVariable -Name -Target`, `Set-HostEnvironmentVariable -Name -Value -Target` (SupportsShouldProcess): environment seams
- `Invoke-HostNativeCommand -FilePath <string> -ArgumentList <string[]>` -> `[pscustomobject]@{ Output; ExitCode }`. This is the single process seam. Pattern precedent: `Invoke-GitExe` returning Output/ExitCode in `scripts/dev-tools/Invoke-MarketplacePublish.ps1` (seam docs at `:57-62`).
- `Get-CommandVersion -Command -VersionArgs`, plus a pure `ConvertTo-HostToolVersion -Text <string>` -> `[version]` or `$null` (the regex `(\d+\.\d+(?:\.\d+)?)`, shared by `verify-host.ps1:37` and `:82`)

**`scripts/dev-tools/HostBootstrap.psm1`** (bootstrap logic plus the folded helper file; imports `HostTooling.psm1`)
- Moved unchanged in behavior: `Install-WithWinget`, `Install-PoetryWithPip`, `Install-WslIfMissing`, `Add-DirectoryToUserPath`, `Get-WingetPackagesFromManifest`, `Set-BootstrapResumeRunOnce`, `Remove-BootstrapResumeRunOnce`, `Get-ProjectRepositoriesFromManifest`, `Resolve-WorkspaceRoot`, `Initialize-WorkspaceRoot`, `Sync-ProjectsFromManifest`, `Resolve-ProjectRepoRoot`.
- Process wrappers (`Invoke-WingetExe`, `Invoke-NpmExe`, `Invoke-WslExe`, `Invoke-PoetryExe`, `Invoke-GitExe`, `Invoke-VerifyHostScript`) are kept as thin functions that delegate to `Invoke-HostNativeCommand`, keeping their current throw-on-nonzero semantics. Rename them with a module-unique noun (for example `Invoke-HostBootstrapWinget`) so they do not collide with same-named functions dot-sourced by other test files (`Invoke-GitExe` and `Invoke-NpmExe` also exist in `Invoke-MarketplacePublish.ps1`).
- New pure helper `Get-BootstrapResumeArgument -WorkspaceRoot -RepoRoot -SkipProjectPoetryInstall` -> `[string]` (extracted from `bootstrap-host.ps1:360-373`).
- `Install-Module` (`:406`) goes behind `Install-HostPowerShellModule -Name -RequiredVersion` so tests never touch the PSGallery.
- `Invoke-BootstrapHost` keeps its signature, including `[bool]$IsWindowsHost = $IsWindows`. The two precondition failures stay `Write-Error`, which is terminating under module-scope EAP Stop. `exit 1` must not appear inside the module: `exit` in a module function ends the calling script and would end a Pester container.
- Size: script plus helpers is 633 physical lines today. If `HostBootstrap.psm1` goes over 500 after comment-based help is added, move the workspace/project functions (the former helper file) into `scripts/dev-tools/HostBootstrapWorkspace.psm1`.

**`scripts/dev-tools/HostVerification.psm1`** (imports `HostTooling.psm1`)
- Moved: `Get-PoetryVersionInfo`, `Invoke-PoetryCommand` (now returning `{ Output; ExitCode }` instead of relying on ambient `$LASTEXITCODE`, which removes the implicit coupling at `verify-host.ps1:305`), `Test-VersionAtLeast`, `Get-RequiredCommandsForHost`.
- New section functions, each returning `[pscustomobject]@{ Lines = [string[]]; FailureCount = [int] }`: `Test-HostCoreVersions -Manifest`, `Test-HostRequiredCommands -Manifest -IsWindowsHost`, `Test-HostOptionalCommands -Manifest` (FailureCount is always 0), `Test-HostPowerShellModules -Manifest`, `Test-HostPoetryTools -Manifest`.
- `Invoke-HostVerification [-ManifestPath]` -> `[pscustomobject]@{ Lines; ExitCode }`. It covers the manifest-absent path, the `$env:Path` refresh, the banner, the sections, and the summary. Status lines are returned rather than streamed so the int exit code does not mix into the output pipeline (precedent for that problem: `.claude/hooks/enforce-parallel-worktree-removal-gate.ps1:466-474`). Line content and order are unchanged. Only timing changes: lines appear when the run finishes instead of progressively, which is acceptable for a short check script and should be listed in the spec's behavior notes. For the manifest-absent path, `Invoke-HostVerification` raises the same terminating `Write-Error "Manifest not found at <path>"`.

**`scripts/dev-tools/SideloadedExtensionPublish.psm1`**
- Moved: `Get-PackageManifest`, `Test-IsVsCodeExtensionManifest`, `Resolve-ExtensionProjectRoot`, `Invoke-ExternalCommand`, `Assert-RequiredCommandAvailable`, `Invoke-NpmCiWithRetry`. `Stop-NodeProcess` becomes a top-level, non-exported function so it can be mocked. `Invoke-ProjectCompile` also moves.
- Seams: `Start-Sleep` and `Get-Date` are called inside the module and mocked with `-ModuleName`. Alternatively, add a `[scriptblock]$Sleep` and `[scriptblock]$Now` parameter to match the repository's clock policy. The scriptblock seam is preferred because it complies directly with the "controllable clock" rule.
- Dot-sources `vscode-cli.helpers.ps1` inside the module (`. (Join-Path $PSScriptRoot 'vscode-cli.helpers.ps1')`). The helper file executes from its own path, so coverage breakpoints still bind and tests of the publish module also raise `vscode-cli.helpers.ps1` coverage (currently 9/27). `new-potential-entry.ps1:7` and the bundled template copy are unaffected.
- `Invoke-SideloadedExtensionPublish` with the same parameters as the script, plus `[CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'Medium')]`. It returns the VSIX path as its only pipeline output and keeps the `Write-Information` lines. `-WhatIf`/`-Confirm` reach the module through splatted `$PSBoundParameters`; module functions do not see the caller's `$WhatIfPreference`, so splatting is required.

### 1.5 Residual Entry-Point Shape

All three entry points keep their current `param` blocks unchanged. They import the module **without `-Force`**: if the module is already loaded, `Import-Module` without `-Force` does nothing, so `-ModuleName` mocks registered by a test survive when the test runs the entry script. Each entry point has no dot-source guard and contains no logic.

| Entry script | Body after `param` | Estimated executable lines |
|---|---|---|
| `bootstrap-host.ps1` | StrictMode; EAP; `Import-Module (Join-Path $PSScriptRoot 'HostBootstrap.psm1')`; `Invoke-BootstrapHost -Apply:$Apply ... -SkipProjectPoetryInstall:$SkipProjectPoetryInstall` | about 4 |
| `verify-host.ps1` | StrictMode; EAP; Import-Module; `$result = Invoke-HostVerification`; `$result.Lines \| Write-Output`; `exit $result.ExitCode` | about 6 |
| `publish-sideloaded-extension.ps1` | the two param default expressions; StrictMode; EAP; Import-Module; build `$invokeParameters` from `$PSBoundParameters` and set `RepoRoot`/`VsixOutputDir` to the resolved values; `Invoke-SideloadedExtensionPublish @invokeParameters` | about 7-8 |

These counts are estimates. The real executable-line counts come from the JaCoCo `LINE` counters after the first targeted run (section 6).

## 2. Callers, Mirrors, and Parity

Callers found (repository-wide grep for the five file names, excluding `docs/features/**`):
- `.vscode/tasks.json:215`: task "Publish (Side-load) VSIX" runs `publish-sideloaded-extension.ps1 -Force`. The path and parameters stay the same.
- `scripts/dev-tools/bootstrap-host.ps1:462`: invokes `verify-host.ps1` by sibling path. This stays as script invocation, so the `exit` semantics are unchanged.
- `scripts/dev-tools/verify-host.ps1:324`: a message string naming `bootstrap-host.ps1`. Not an invocation.
- `tests/scripts/dev-tools/publish-sideloaded-extension.Tests.ps1:8,117`: `Import-ScriptFunction` on functions that will move. This file **must be rewritten**; otherwise it fails with "Function ... not found" (`TestHelpers.ps1:23-25`).

No callers in `package.json`, `extensions/drm-copilot/package.json`, `extensions/drm-copilot/src/**`, or `.github/**` (targeted grep returned no matches). `bootstrap-host`/`verify-host` appear in no file outside the two scripts.

Mirrors: no bundled copy of the three scripts or of `bootstrap-host.helpers.ps1` exists under `extensions/drm-copilot/resources/`. The only related bundled file is `extensions/drm-copilot/resources/templates/new-potential-entry.ps1`, which dot-sources its own co-located `vscode-cli.helpers.ps1` (`:7`). This work does not edit `vscode-cli.helpers.ps1`, so no template update is needed. `tests/scripts/dev_tools/test_poshqc_bundled_parity.py:10-18` covers only PoshQC module and settings files, none of which change.

`config/blast-radius.json:72` maps `"powershell-dev-tools": ["scripts/dev-tools/**"]`. The new modules match this existing glob, so no edit is needed.

## 3. Existing Tests and Precedents

- No tests exist for `bootstrap-host.ps1`, `bootstrap-host.helpers.ps1`, or `verify-host.ps1` (`tests/scripts/dev-tools/` listing).
- `publish-sideloaded-extension.Tests.ps1` contains 7 `It` blocks across three `Describe`s. All attribute zero coverage, for the reason given in finding 1. The `scaffold extension package identity` Describe (`:143-152`) reads the checked-in `extensions/drm-copilot/package.json` and is not a temporary-file read; keep it.

Precedents to copy:
1. **Module plus `Mock -ModuleName` plus coverage-safe import:** `tests/scripts/claude-lib/cleanup-manifest/CleanupWorktreeManifest.Tests.ps1:21-40`. It imports through `Resolve-Path` so "Pester coverage breakpoints bind to the path the run settings name" (`:22-26`), and registers read and clock seams with `-ModuleName` (`:36-39`). The comment at `:30-35` notes that `-ModuleName` mock bodies run in module session state, so fixtures must be inline literals. The matching entry/module split is `.claude/hooks/enforce-parallel-worktree-removal-gate.ps1:37-40` (imports) and `:423-474` (entry function returning an exit code plus a thin tail).
2. **In-process entry-point invocation for coverage of the thin tail:** `tests/scripts/dev-tools/Invoke-MarketplacePublish.Tests.ps1:263-276` and `Invoke-ReleaseTagPush.Tests.ps1:479-495` run `& $script:scriptPath ...` and assert `$LASTEXITCODE`. `tests/scripts/dev-tools/tree.Tests.ps1:438-445` registers test-scope `Mock` for commands used by a script run with `&`, which shows that test-scope mocks intercept calls from a script run in a child scope.

## 4. Coverage Population Mechanics

- `config/poshqc-coverage.json:1-10`: `{"version":1,"roots":[".claude/hooks",".claude/lib",".codex/hooks",".codex/scripts","scripts"]}`.
- `Get-PoshQCCoverageFileSet` (`scripts/powershell/PoshQC/PoshQC.Coverage.psm1:154-210`) recursively enumerates each root. It keeps `.ps1`/`.psm1`, drops `*.Tests.ps1`, drops paths whose first segment is `tests`, and drops any path with a directory segment listed in `DefaultExcludedDirs` (`PoshQC.psm1:5-8`: `.git`, `.venv`, `venv`, `node_modules`, `dist`, `build`, `.pytest_cache`, `__pycache__`, `.mypy_cache`, `.ruff_cache`, `.vscode`, `.idea`, `artifacts`, `.vscode-test`). New `scripts/dev-tools/*.psm1` files are therefore included automatically. If the helper file is deleted, it leaves the population automatically.
- Precedence (`PoshQC.Coverage.psm1:246-314`; README `:70-75`): a caller-supplied settings file with `CodeCoverage.Path` gives `settings`; otherwise the presence of the config file gives `config`; otherwise `fallback`. `-ScanFolders` changes only the fallback, so with the config present a narrowed run still measures the full population (`PoshQC.Testing.psm1:319-357`).
- `scripts/powershell/PoshQC/settings/pester.runsettings.psd1:17-27` has no `CodeCoverage.Path`, uses `OutputFormat = 'CoverageGutters'`, and writes `OutputPath = 'artifacts/pester/powershell-coverage.xml'`. **No edit is needed to the runsettings, the config, the PoshQC module, or the bundled mirror.**
- `quality-tiers.yml:19-21` already classifies `scripts/dev-tools` as T4. Discovery rule R3 (`scripts/dev_tools/quality_tiers_contract.py:331-336`) maps any `scripts/<name>/<file>.psm1` to `scripts/dev-tools`. Rule R2 (`:327-330`) creates a new project only for a `.psd1` with a same-stem `.psm1`. **With no `.psd1` and no subfolder, `quality-tiers.yml` needs no edit.** Adding a `.psd1` would trigger QT008 unless an entry is added, so do not add one.

## 5. Coverage Arithmetic

Baseline (`docs/features/active/2026-08-23-poshqc-coverage-denominator-not-reproducible-527/evidence/qa-gates/coverage-aggregate.2026-10-02T08-45.md:10-15`): C = 13325 covered, T = 15738 total, 84.67%.

Floor formula: required C >= ceil(0.85 x T). For T = 15738, 0.85 x 15738 = 13377.3, so required C = 13378. Shortfall = 13378 - 13325 = **53 lines**.

Projection. Pester's LINE counter counts only executable lines (the 177/153/138/43 figures are LINE counters from the evidence file `:25-36`). Moving code into modules roughly conserves executable lines; an overhead allowance is added for new seams.

| Scenario | Removed from T | Entry lines (covered) | Module lines (covered) | New T | New C | Line % | Required C | Margin |
|---|---|---|---|---|---|---|---|---|
| A: three scripts only, helper file kept at 0/43, entries 0%, modules at 85% | 468 | 21 (0) | 484 (411) | 15775 | 13736 | 87.07 | 13409 | 327 |
| B: helper folded, entries 0%, modules at 85% | 511 | 21 (0) | 530 (450) | 15778 | 13775 | 87.30 | 13412 | 363 |
| C (recommended target): helper folded, entries 100%, modules at 90% | 511 | 21 (21) | 530 (477) | 15778 | 13823 | 87.61 | 13412 | 411 |

Break-even for scenario A: (13325 + X) / 15775 >= 0.85 gives X >= 84 covered module lines, about 17% of the module code. **The three scripts are sufficient with a margin of about 2.1 to 2.6 percentage points (327 to 411 lines). No additional target is required.** The binding constraint is the per-file 85% rule, which makes the entry scripts subject to the rule as modified files. A 4-6 line entry script can miss at most 0 lines; a 7-8 line script can miss at most 1. Each entry script therefore needs at least one in-process invocation test (section 3, precedent 2).

Caveat: the baseline is CI run 36983551836 (2026-10-02). `main` has merged further changes since then (for example #802/#803 at `a24a1ce3`). The plan should record a fresh baseline aggregate from a current-`main` CI artifact before claiming the post-change delta. Module and entry line counts above are estimates and must be replaced with measured LINE counters.

## 6. Local Test and Coverage Execution

- Per operator memory, the MCP `run_poshqc_test` path reads the installed extension's settings and returns no output. Do not use it as evidence.
- Self-hosted full run (CI-equivalent, `.github/workflows/_poshqc.yml:38-42`): `Import-Module ./scripts/powershell/PoshQC/PoshQC.psd1 -Force; Invoke-PoshQCTest -Root .`. Coverage goes to `artifacts/pester/powershell-coverage.xml` (Pester CoverageGutters format, JaCoCo XML schema) and `artifacts/pester/powershell-coverage.koverage.xml`. The log line `Code coverage population: source=config; files=<n>` confirms the population (`PoshQC.Testing.psm1:355`). `scripts/dev-tools/run-pester.ps1:11-14` wraps the same call.
- Narrowed run: `Invoke-PoshQCTest -Root . -ScanFolders @('tests/scripts/dev-tools')` runs only the dev-tools tests but still measures the full config population. Per-file rows for the new modules and entry scripts are valid. The aggregate from such a run is **not** valid.
- Targeted direct Pester (viable for per-file verification): `$c = New-PesterConfiguration; $c.Run.Path = @(<new test files>); $c.CodeCoverage.Enabled = $true; $c.CodeCoverage.Path = @(<new .psm1 files>, <three entry scripts>, 'scripts/dev-tools/vscode-cli.helpers.ps1'); $c.CodeCoverage.OutputFormat = 'JaCoCo'; $c.CodeCoverage.OutputPath = 'artifacts/pester/847-targeted-coverage.xml'; Invoke-Pester -Configuration $c`. Raw XML goes under `artifacts/pester/`. The evidence summary goes to `docs/features/active/2026-10-08-powershell-aggregate-line-coverage-below-floor-847/evidence/<kind>/`.
- Reading the XML: per file, `report/package[@name='scripts/dev-tools']/sourcefile[@name='<file>']/counter[@type='LINE']` gives `missed`/`covered`, and rate = covered / (missed + covered). The aggregate is the report-level `counter[@type='LINE']`. The #527 evidence uses the same `package|sourcefile` key shape (`coverage-aggregate...md:23-64`).
- Tooling note (operator memory): in agent worktrees a text guard denies Bash commands containing `pwsh`. Use the PowerShell tool for these invocations.

## 7. Overlap with #824

`.claude/hooks/validate-feature-review-coverage.ps1` (104/210) is not one of the three targets, and the arithmetic in section 5 does not depend on it. **This work does not need to write it.** The same applies to `.codex/hooks/validate-feature-review-coverage.ps1` and every `.codex/scripts` file.

## Recommended Approach

Use four modules (`HostTooling`, `HostBootstrap` with the helper file folded in and deleted, `HostVerification`, `SideloadedExtensionPublish`) directly in `scripts/dev-tools/`, plus thin entry scripts with unchanged `param` blocks. In tests, import each module through `Resolve-Path`, mock all host I/O with `Mock -ModuleName`, and run each entry script in-process with `&` once per exit path. Folding the helper file removes a 0/43 file and replaces it with tested code; its only consumer is `bootstrap-host.ps1`, so no external behavior changes.

Rejected alternatives:
- **Keep the scripts and test them by dot-sourcing** (as in `new-claude-worktree-session.Tests.ps1`). `verify-host.ps1` and `publish-sideloaded-extension.ps1` have no dot-source guard and run top-level side effects. Adding guards still leaves the top-level logic untestable, and this conflicts with the operator decision.
- **Injected scriptblock parameters on every function** (as in `PoshQC.Coverage.psm1`). This works but spreads seams through every signature. `Mock -ModuleName` over a small set of wrapper functions is simpler here. Scriptblock seams are kept only for clock and sleep, which policy names explicitly.
- **One module per script with duplicated env/process helpers.** Rejected on the reusability principle; `Get-SessionPathFromMachineAndUser` is already duplicated today.

## Behavior Semantics to Preserve

- Same parameter names, types, defaults, and switch semantics on all three entry scripts. `.vscode/tasks.json` invocation unchanged.
- bootstrap: dry run (no `-Apply`) performs no installs, registry writes, or clones, and prints "- Would ..." lines. A non-Windows host or missing `winget` gives an error and exit code 1. RunOnce is set only when both `-Apply` and `-EnableAutoResumeAfterReboot` are given, and is cleared after a successful apply. A poetry winget failure falls back to pip. A poetry project-install failure produces a warning, not a failure.
- verify: same five section headings and per-line text. Exit 0 if and only if the failure count is 0. Exit 1 on a missing manifest with the same message.
- publish: same order (npm ci, then compile, then vsce package, then install). Each step is gated by ShouldProcess and the Skip switches. The EPERM retry uses up to 3 attempts with backoff `DelaySeconds x attempt`. It throws when the VSIX is missing. The final pipeline output is the VSIX path. An explicit `-CodeCommand` that is not found throws.
- The missing `scripts/host-tools.manifest.json` and the stale `scripts/bash/bootstrap-host.sh` reference are preserved, not fixed. Recommend a separate follow-up issue.

## Testing Implications

- Test files mirror the module paths: `tests/scripts/dev-tools/HostTooling.Tests.ps1`, `HostBootstrap.Tests.ps1` (split into `HostBootstrap.Workspace.Tests.ps1` if needed to stay under 500 lines), `HostVerification.Tests.ps1`, `SideloadedExtensionPublish.Tests.ps1`; plus entry tests `bootstrap-host.Tests.ps1`, `verify-host.Tests.ps1`, and the rewritten `publish-sideloaded-extension.Tests.ps1`.
- No temporary files. Supply manifests as inline `[pscustomobject]` literals inside `-ModuleName` mock bodies. Mock Test-Path, Get-Content, New-Item, New-ItemProperty, Remove-ItemProperty, Get-Command, Get-Module, Install-Module (or its wrapper), Push-Location/Pop-Location, Get-ChildItem, and every native-process wrapper. No real `winget`/`npm`/`wsl`/`git`/`code`/`cmd.exe`.
- Required scenarios: dry-run vs apply branches; already-installed short-circuit; the winget-failure poetry fallback and the non-poetry rethrow; missing python; User PATH deduplication (case and trailing-backslash); resume-argument composition; manifest missing or empty winget list; each verify section's OK/FAIL/WARN outcome and the exit-code boundary (0 vs 1 failure); poetry via `python -m poetry`; EPERM retry exhaustion and non-EPERM immediate rethrow; `-Force` cleanup path; compile selection (script, tsconfig, neither); `CodeCommand` bound-empty vs unbound; `-WhatIf` performs no seam calls; VSIX-missing throw.
- Entry tests: import the module in `BeforeAll`, register `-ModuleName` mocks (or a test-scope mock of the single orchestrator function), then `& $entryPath <args>` and assert output and `$LASTEXITCODE`. Add `AfterAll { Remove-Module <name> -ErrorAction SilentlyContinue }` so exported names do not leak into later containers.
- All tests must pass on the `windows-latest` PoshQC job. Registry and `$IsWindows` behavior is reached only through mocks or the `-IsWindowsHost` parameter.

## Risks

1. **Lost mocks through `-Force` re-import.** If an entry script uses `Import-Module -Force`, the module is re-imported while a test runs it, `-ModuleName` mocks are discarded, and real host commands could run. Mitigation: no `-Force` in entry scripts. Entry tests should also mock the orchestrator function at test scope as a second layer.
2. **Preference-variable isolation.** Modules do not inherit the caller's EAP or StrictMode. Missing module-scope settings would turn `Write-Error` precondition failures into non-terminating errors, so the scripts would exit 0. Mitigation: set both at module scope and test the exit code 1 paths.
3. **Name collisions between tests.** Exported wrappers named like `Invoke-GitExe`/`Invoke-NpmExe` collide with functions dot-sourced by the release tests. Mitigation: module-unique names plus `Remove-Module` in `AfterAll`.
4. **Output timing change in verify-host** (returned lines instead of streamed). Content and order are unchanged; record it in the spec as an accepted non-functional change.
5. **Stale baseline.** Re-baseline from a current-`main` CI artifact before stating the delta.
6. **Single-line coverage attribution.** Avoid placing a guard condition and its body on one line in entry scripts so that each statement has its own LINE entry.

## Automation Feasibility

Result: **automatable; no human interaction required.** All behavior can be tested with mocks and in-memory fixtures, and no step requires elevation, a reboot, network access, interactive prompts, or a VS Code instance. Verification uses the self-hosted PoshQC invocation and the CI `poshqc` job on `windows-latest`. The only operator-dependent item is outside this scope: the decision about the missing `scripts/host-tools.manifest.json` (follow-up issue).

## Files the Implementation Would Write

Production (new):
- `scripts/dev-tools/HostTooling.psm1`
- `scripts/dev-tools/HostBootstrap.psm1`
- `scripts/dev-tools/HostBootstrapWorkspace.psm1` (only if needed to stay under 500 lines)
- `scripts/dev-tools/HostVerification.psm1`
- `scripts/dev-tools/SideloadedExtensionPublish.psm1`

Production (modified):
- `scripts/dev-tools/bootstrap-host.ps1`
- `scripts/dev-tools/verify-host.ps1`
- `scripts/dev-tools/publish-sideloaded-extension.ps1`

Production (deleted):
- `scripts/dev-tools/bootstrap-host.helpers.ps1` (folded into `HostBootstrap.psm1`)

Tests (new):
- `tests/scripts/dev-tools/HostTooling.Tests.ps1`
- `tests/scripts/dev-tools/HostBootstrap.Tests.ps1`
- `tests/scripts/dev-tools/HostBootstrap.Workspace.Tests.ps1` (or `HostBootstrapWorkspace.Tests.ps1` if that module is created)
- `tests/scripts/dev-tools/HostVerification.Tests.ps1`
- `tests/scripts/dev-tools/SideloadedExtensionPublish.Tests.ps1`
- `tests/scripts/dev-tools/bootstrap-host.Tests.ps1`
- `tests/scripts/dev-tools/verify-host.Tests.ps1`

Tests (modified):
- `tests/scripts/dev-tools/publish-sideloaded-extension.Tests.ps1` (replace `Import-ScriptFunction` usage with entry-point tests; keep the package-identity Describe)

Feature documentation and evidence:
- `docs/features/active/2026-10-08-powershell-aggregate-line-coverage-below-floor-847/spec.md`, `plan.*.md`
- `docs/features/active/2026-10-08-powershell-aggregate-line-coverage-below-floor-847/evidence/<kind>/*.md` (baseline, qa-gates, coverage)

Explicitly not written: `config/poshqc-coverage.json`, `scripts/powershell/PoshQC/**`, `extensions/drm-copilot/resources/**`, `quality-tiers.yml`, `config/blast-radius.json`, `.vscode/tasks.json`, `scripts/dev-tools/vscode-cli.helpers.ps1`, `.claude/hooks/validate-feature-review-coverage.ps1`, `.codex/**`.

## Numeric Derivation Evidence

### N1: Functions defined in the in-scope files (36 total: bootstrap 15, helpers 6, verify 7, publish 8 including nested)

- Complete Family: every `function` definition (top-level and nested) in `scripts/dev-tools/bootstrap-host.ps1`, `bootstrap-host.helpers.ps1`, `verify-host.ps1`, `publish-sideloaded-extension.ps1`.
- Exhaustive Search Scope: the full text of all four files.
- Inclusion Rules: any `function <Name>` definition at any nesting depth.
- Exclusion Rules: scriptblock literals (for example `$joinProjectPath` at `publish-sideloaded-extension.ps1:111`) are not functions.
- Primary Search Strategy: full sequential read of each file with the Read tool.
- Primary Member Set: bootstrap: Get-HostManifest, Install-WithWinget, Invoke-WingetExe, Invoke-NpmExe, Invoke-WslExe, Invoke-VerifyHostScript, Invoke-PoetryExe, Get-SessionPathFromMachineAndUser, Add-DirectoryToUserPath, Install-PoetryWithPip, Install-WslIfMissing, Get-WingetPackagesFromManifest, Set-BootstrapResumeRunOnce, Remove-BootstrapResumeRunOnce, Invoke-BootstrapHost. helpers: Invoke-GitExe, Get-ProjectRepositoriesFromManifest, Resolve-WorkspaceRoot, Initialize-WorkspaceRoot, Sync-ProjectsFromManifest, Resolve-ProjectRepoRoot. verify: Get-ManifestPath, Get-CommandVersion, Get-PoetryVersionInfo, Get-SessionPathFromMachineAndUser, Invoke-PoetryCommand, Test-VersionAtLeast, Get-RequiredCommandsForHost. publish: Get-PackageManifest, Test-IsVsCodeExtensionManifest, Resolve-ExtensionProjectRoot, Invoke-ExternalCommand, Assert-RequiredCommandAvailable, Invoke-NpmCiWithRetry, Stop-NodeProcess (nested), Invoke-ProjectCompile.
- Primary Count: 36.
- Cross-check Search Strategy: ripgrep `^\s*function\s+[\w-]+` over `scripts/dev-tools` restricted by glob to the four files.
- Cross-check Member Set: the same 36 names at bootstrap `:30,43,91,104,114,127,137,165,178,203,243,264,280,299,313`; helpers `:4,17,32,49,73,117`; verify `:8,16,50,107,120,140,159`; publish `:58,78,99,146,192,219,238,301`.
- Cross-check Count: 36.
- Member-set Comparison: the normalized sets are identical (36 = 36, no differences).

### N2: Aggregate floor (required covered lines 13378; shortfall 53)

- Complete Family: the repository PowerShell coverage population in CI run A (174 files).
- Exhaustive Search Scope: report-level LINE totals recorded in `coverage-aggregate.2026-10-02T08-45.md:10-15`.
- Inclusion Rules: all files in the `source=config` population.
- Exclusion Rules: none.
- Primary Search Strategy: computation ceil(0.85 x 15738) = ceil(13377.3) = 13378; 13378 - 13325 = 53.
- Primary Member Set: {T = 15738, C = 13325}.
- Primary Count: 53.
- Cross-check Search Strategy: LINE_MISSED + LINE_COVERED = 2413 + 13325 = 15738 (confirms T from a separate recorded field); then 13378 / 15738 = 0.85004 >= 0.85 and 13377 / 15738 = 0.84998 < 0.85.
- Cross-check Member Set: {T = 15738, C = 13325}.
- Cross-check Count: 53.
- Member-set Comparison: identical inputs and identical result. The projected scenario figures in section 5 are estimates and must not be used as spec acceptance-criterion counts until replaced with measured counters.
