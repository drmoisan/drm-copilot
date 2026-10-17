# Host tools manifest, bootstrap message, native output streaming, and publish preference forwarding

- Work Mode: minor-audit
- Issue: #887
- Also resolves: #888
- Branch: bug/host-tools-manifest-and-bootstrap-behavior-887
- Lifecycle records: origin/docs/followups-2026-10-11:docs/features/potential/promoted/2026-10-09-host-tools-manifest-and-bash-bootstrap-missing.md (#887); origin/docs/followups-2026-10-11:docs/features/potential/promoted/2026-10-11-host-bootstrap-output-buffering-and-publish-whatif-forwarding.md (#888)
- Research: docs/features/active/2026-10-11-host-tools-manifest-and-bootstrap-behavior-887/research/research.2026-10-11T08-40.md

## Problem / Why

Issue #887:

- `scripts/host-tools.manifest.json` does not exist. `Get-HostToolsManifestPath` resolves to `scripts/dev-tools/../host-tools.manifest.json` (`scripts/dev-tools/HostTooling.psm1:24`), so `bootstrap-host.ps1` throws `Host tools manifest not found at <path>` (`HostBootstrap.psm1:27-31`) and `verify-host.ps1` raises `Manifest not found at <path>` (`HostVerification.psm1:340-343`). Neither script can run on any host.
- The non-Windows precondition message (`HostBootstrap.psm1:335`) directs users to `./scripts/bash/bootstrap-host.sh`, which does not exist. The supported Linux/macOS provisioning path is the dev container under `.devcontainer/`.
- `Get-ProjectRepositoriesFromManifest` output is unrolled by PowerShell, so an empty `projectRepositories` list reaches `Resolve-ProjectRepoRoot -Projects` (mandatory `[object[]]`, no `[AllowEmptyCollection()]`) as `$null`, and apply mode fails with a parameter-binding error (research 2.4).

Issue #888 (regressions introduced by #847):

- `Invoke-HostNativeCommand` captures native output into a variable and returns it after the process exits (`HostTooling.psm1:124-139`). Bootstrap operations (git clone, winget, npm, wsl, poetry, pip) therefore show no output until each process finishes. Pre-#847 bootstrap streamed native output; the #847 spec accepted an output-timing change only for `verify-host.ps1` (CR-N1, FA-N2). The seam also reads `$LASTEXITCODE` without resetting it first (CR-N4).
- `publish-sideloaded-extension.ps1` forwards common parameters to the script-module function `Invoke-SideloadedExtensionPublish` only when they are bound. Module functions do not inherit the caller's preference variables, so an inherited `$WhatIfPreference = $true` (for example from a parent run with `-WhatIf`) no longer suppresses ShouldProcess-gated steps. `-Debug`, `-InformationAction`, and `-ProgressAction` are not forwarded (CR-N2).

## Implementation Intent

1. Commit `scripts/host-tools.manifest.json` with the content in research section 2.7: seven top-level keys (`installPackages`, `powershellModules`, `projectRepositories`, `minimumVersions`, `requiredCommands`, `optionalCommands`, `pythonTools`); winget entries `Git.Git`/`git`, `Python.Python.3.13`/`python`, `OpenJS.NodeJS.LTS`/`node`, `Microsoft.PowerShell`/`pwsh`, `GitHub.cli`/`gh`, `Microsoft.VisualStudioCode`/`code`; no poetry winget entry; `"projectRepositories": []`. Keep `Get-HostToolsManifestPath` unnormalized.
2. Pin `powershellModules` minimums at Pester `5.6.1` and PSScriptAnalyzer `1.22.0` (OD-4). These match the versions PoshQC installs (`PoshQC.psm1:56-57`) and CI requires (`_poshqc.yml:73`).
3. Pin `minimumVersions` to the versions observed on the development machine on 2026-10-11 (see subsection below). Values are plain dotted numbers because `HostVerification.psm1:108` casts them directly to `[version]`.
4. Fix empty `projectRepositories` binding (OD-2): wrap the call at `HostBootstrap.psm1:350` as `$projects = @(Get-ProjectRepositoriesFromManifest -Manifest $manifest)`, and add `[AllowEmptyCollection()]` to the `Projects` parameter of `Resolve-ProjectRepoRoot` (`HostBootstrapWorkspace.psm1:169-170`).
5. Replace the non-Windows message at `HostBootstrap.psm1:335` with `This script targets Windows. On Linux/macOS, use the dev container defined under .devcontainer/ (see .devcontainer/README.md).` No bash bootstrap script is added.
6. Add a `Stream` parameter set (`-StreamToHost`) to `Invoke-HostNativeCommand` that pipes native output to `Out-Host` as it is produced and returns `{ Output = @(); ExitCode }`. Reset `$LASTEXITCODE` to 0 with `Set-Variable -Scope Global` before every invocation (both modes). Capture mode, including `-MergeErrorStream`, keeps its current behavior and return shape.
7. Switch the bootstrap call sites to `-StreamToHost` and remove their captured-output emission lines: `HostBootstrapWorkspace.psm1` git (`:30`), winget (`:202`), npm (`:220`), wsl (`:235`), poetry (`:269`), python -m poetry (`:283`), and `HostBootstrap.psm1` pip (`:144`). Verification call sites stay in capture mode: `HostTooling.psm1:193` (`Get-CommandVersion`) and `HostVerification.psm1:46` (`Get-PoetryVersionInfo`), `:77`, `:82` (`Invoke-PoetryCommand`). Throw messages are unchanged.
8. Replace the forwarding block in `publish-sideloaded-extension.ps1` (lines 70-81) with the inline logic in research 5.3: forward bound `WhatIf`, `Confirm`, `Verbose`, `Debug`, `WarningAction`, `InformationAction`, `ProgressAction`; when not bound, forward `WhatIf = $true` if `$WhatIfPreference` is true, map `$ConfirmPreference` (`None` to `Confirm = $false`, `Low`/`Medium` to `Confirm = $true`, `High` adds no key), and forward `Verbose`/`Debug = $true` when the corresponding preference is `Continue`. The logic stays in the entry script because `SideloadedExtensionPublish.psm1` is 456 lines.
9. `-ErrorAction` is not forwarded (OD-1). The entry script sets `$ErrorActionPreference = "Stop"` at line 54 after binding, so a caller's `-ErrorAction` had no effect pre-#847; not forwarding it is behavior-equivalent. Forwarding `-ErrorAction SilentlyContinue` could allow `throw "VSIX was not created as expected"` (`SideloadedExtensionPublish.psm1:426`) to be suppressed (research 5.2). The existing not-forwarded assertion is kept and the rationale is recorded in the PR description.

### Observed host versions used as manifest minimums (2026-10-11)

| Manifest key | Observed version | Observation command |
|---|---|---|
| `minimumVersions.python` | 3.13.12 | `python --version` (output `Python 3.13.12`) |
| `minimumVersions.poetry` | 2.3.2 | `poetry --version` (output `Poetry (version 2.3.2)`) |
| `minimumVersions.pwsh` | 7.6.6 | read from `C:/Program Files/PowerShell/7/pwsh.deps.json`, entry `Microsoft.PowerShell.SDK/7.6.6` (direct `pwsh --version` was refused by the worktree isolation guard) |
| `minimumVersions.node` | 24.14.0 | `node --version` (output `v24.14.0`) |

Only these four `minimumVersions` sub-keys are read by the code (`HostVerification.psm1:149-152`). The other observed versions (npm, git, winget, gh, dotnet, VS Code, and the Pester/PSScriptAnalyzer module folders) are recorded in research section 2.6 only and are not added to the manifest.

## Acceptance Criteria

- [x] AC-1: `scripts/host-tools.manifest.json` exists, parses with `ConvertFrom-Json`, and contains the top-level keys `installPackages` (with `windows.winget`), `powershellModules`, `projectRepositories`, `minimumVersions`, `requiredCommands`, `optionalCommands`, and `pythonTools`.
- [x] AC-2: `minimumVersions` in `scripts/host-tools.manifest.json` contains `python` = `3.13.12`, `poetry` = `2.3.2`, `pwsh` = `7.6.6`, and `node` = `24.14.0`, and each value casts to `[version]` without error.
- [x] AC-3: `powershellModules` in `scripts/host-tools.manifest.json` contains an entry with `name` = `Pester` and `minimumVersion` = `5.6.1`, and an entry with `name` = `PSScriptAnalyzer` and `minimumVersion` = `1.22.0`.
- [x] AC-4: Every `installPackages.windows.winget` entry in `scripts/host-tools.manifest.json` has a non-empty `id` and a non-empty `name`; `projectRepositories` is an empty JSON array (`[]`); `requiredCommands`, `optionalCommands`, and `pythonTools` are arrays of non-empty strings.
- [x] AC-5: `Get-HostToolsManifestPath` still returns the unnormalized `scripts/dev-tools/../host-tools.manifest.json` form, with the existing assertion at `tests/scripts/dev-tools/HostTooling.Tests.ps1:31-37` unchanged, and a new test in `tests/scripts/dev-tools/HostTooling.Tests.ps1` asserts that `Test-Path -LiteralPath (Get-HostToolsManifestPath) -PathType Leaf` returns `$true`.
- [x] AC-6: A new suite `tests/scripts/host-tools.manifest.Tests.ps1` reads the committed `scripts/host-tools.manifest.json` (no temporary files are created), asserts AC-1 through AC-4, and runs `Test-HostCoreVersion`, `Test-HostRequiredCommand`, `Test-HostOptionalCommand`, `Test-HostPowerShellModule`, and `Test-HostPoetryTool` against the parsed manifest with `Get-Command`, `Get-CommandVersion`, `Get-PoetryVersionInfo`, `Get-Module`, and `Invoke-PoetryCommand` mocked `-ModuleName HostVerification`, asserting that no StrictMode property error is raised and that each function reports zero failures when the mocks return the pinned versions.
- [x] AC-7: A test in `tests/scripts/dev-tools/HostBootstrap.Invoke.Tests.ps1` runs `Invoke-BootstrapHost -IsWindowsHost $true` in dry-run mode with `Read-HostToolsManifest` mocked to return the parsed committed manifest and host seams mocked, and asserts that the output contains one `Would install` line per winget entry, contains the module preview `Pester 5.6.1, PSScriptAnalyzer 1.22.0`, and ends with `Dry run complete. Re-run with -Apply to install tools.`
- [x] AC-8: `HostBootstrap.psm1` wraps the `Get-ProjectRepositoriesFromManifest` call in `@()`, and the `Projects` parameter of `Resolve-ProjectRepoRoot` in `HostBootstrapWorkspace.psm1` carries `[AllowEmptyCollection()]`; a test in `tests/scripts/dev-tools/HostBootstrap.Invoke.Tests.ps1` runs `Invoke-BootstrapHost -Apply -IsWindowsHost $true` with an empty `projectRepositories` and asserts no parameter-binding error is raised and `Invoke-HostBootstrapPoetry` is invoked; a test in `tests/scripts/dev-tools/HostBootstrapWorkspace.Tests.ps1` asserts `Resolve-ProjectRepoRoot -Projects @()` returns the default repository root.
- [x] AC-9: The non-Windows precondition message in `scripts/dev-tools/HostBootstrap.psm1` is `This script targets Windows. On Linux/macOS, use the dev container defined under .devcontainer/ (see .devcontainer/README.md).`; `tests/scripts/dev-tools/HostBootstrap.Invoke.Tests.ps1` (line 124 case) and `tests/scripts/dev-tools/bootstrap-host.Tests.ps1` (lines 76 and 80) assert the new text; a search for `bootstrap-host.sh` under `scripts/` and `tests/` returns no match.
- [x] AC-10: Tests in `tests/scripts/dev-tools/HostTooling.Tests.ps1` assert that `Invoke-HostNativeCommand -StreamToHost` sends output to `Out-Host`, returns an empty `Output`, and returns `ExitCode` 0 after a stale non-zero global `$LASTEXITCODE` sentinel was set before the call; that capture mode also resets a stale `$LASTEXITCODE` before invocation; and that the existing capture-mode cases (with and without `-MergeErrorStream`) pass unchanged.
- [x] AC-11: The bootstrap call sites in `scripts/dev-tools/HostBootstrapWorkspace.psm1` (`Invoke-HostBootstrapGit`, `Invoke-HostBootstrapWinget`, `Invoke-HostBootstrapNpm`, `Invoke-HostBootstrapWsl`, and both `Invoke-HostBootstrapPoetry` branches) and `scripts/dev-tools/HostBootstrap.psm1` (`Install-PoetryWithPip`) pass `-StreamToHost` and no longer emit captured native output; tests in `tests/scripts/dev-tools/HostBootstrapWorkspace.Tests.ps1` and `tests/scripts/dev-tools/HostBootstrap.Tests.ps1` assert `-StreamToHost` through a `ParameterFilter`, assert the wrapper emits no fixture output lines, and assert the nonzero-exit throw messages are unchanged.
- [x] AC-12: The verification call sites `Get-CommandVersion` (`scripts/dev-tools/HostTooling.psm1`), `Get-PoetryVersionInfo`, and `Invoke-PoetryCommand` (`scripts/dev-tools/HostVerification.psm1`) do not pass `-StreamToHost`, and `Get-CommandVersion` and `Get-PoetryVersionInfo` still pass `-MergeErrorStream`.
- [x] AC-13: Tests in `tests/scripts/dev-tools/publish-sideloaded-extension.Tests.ps1` assert each of these forwarding rules for `publish-sideloaded-extension.ps1`: an inherited `$WhatIfPreference = $true` with `-WhatIf` unbound forwards `WhatIf = $true`; a bound `-WhatIf:$false` with inherited `$WhatIfPreference = $true` forwards `WhatIf = $false`; an inherited `$ConfirmPreference` of `None` forwards `Confirm = $false`, of `Low` forwards `Confirm = $true`, and of `High` adds no `Confirm` key; an inherited `$VerbosePreference = 'Continue'` forwards `Verbose = $true`; an inherited `$DebugPreference = 'Continue'` forwards `Debug = $true`; bound `-Debug`, `-InformationAction`, and `-ProgressAction` are forwarded; under default preferences no `WhatIf` key is added.
- [x] AC-14: `publish-sideloaded-extension.ps1` does not forward `-ErrorAction`, and the existing not-forwarded assertion in `tests/scripts/dev-tools/publish-sideloaded-extension.Tests.ps1` is retained and passes.
- [x] AC-15: A test in `tests/scripts/dev-tools/publish-sideloaded-extension.Tests.ps1` runs the real `Invoke-SideloadedExtensionPublish` path with an inherited `$WhatIfPreference = $true` and `-WhatIf` unbound, and asserts zero calls to `New-Item`, `Invoke-NpmCiWithRetry`, `Invoke-ProjectCompile`, `Invoke-ExternalCommand`, and `Invoke-SideloadedExtensionProcess`; the test fails on the pre-fix entry script and passes after the fix.
- [x] AC-16: PoshQC MCP `run_poshqc_format`, `run_poshqc_analyze`, and `run_poshqc_test` each report a passing summary for the changed PowerShell files, and the CI `PowerShell QC` job on the PR passes.
- [x] AC-17: The CI `PowerShell QC` job coverage artifact (`artifacts/pester/powershell-coverage.xml`) shows line coverage >= 85% for each changed `.ps1`/`.psm1` file under `scripts/dev-tools/`, with no coverage regression on changed lines, and no production file is added to a coverage exclusion.
- [x] AC-18: No changed or new file exceeds 500 lines.

## Dependencies / Risks

- Pinned minimums are machine-specific. Hosts with older patch versions (for example python below 3.13.12 or node below 24.14.0) will fail `verify-host.ps1`. CI does not run `verify-host.ps1`. The PR description states this.
- Fresh-machine poetry install gap (OD-3, out of scope): no poetry winget entry is listed because no package ID was verified, and `Install-PoetryWithPip` is reachable only from the winget failure path, so bootstrap does not install poetry on a host that lacks it. Recorded as a follow-up candidate; no new issue is filed.
- `-ErrorAction` is intentionally not forwarded (OD-1). If forwarding is required later, a guard that keeps `throw` paths terminating and a test asserting termination under `-ErrorAction SilentlyContinue` are needed.
- Native stdout in stream mode goes to the host rather than the function pipeline, so a caller that captures `bootstrap-host.ps1` output into a variable no longer receives native lines. Production invocations render to the console. Progress-bar rendering under `| Out-Host` is not verified and is not covered by the acceptance criteria.
- Pester 5 `Out-Host` mock call counting per pipeline item is unverified; tests assert at least one call unless the expect-fail run confirms exact counts.
- Setting preference variables in a child scriptblock is expected not to affect Pester internals; confirm during the expect-fail run and redirect the verbose stream (`4>$null`) in the Verbose case.
- `Get-Command python` may resolve the Microsoft Store alias; pre-existing behavior, out of scope.
- Coverage figures are available only from the CI artifact; PoshQC MCP results carry a pass/fail summary only.
- Dependency: the lifecycle records live on the unmerged ref `origin/docs/followups-2026-10-11` and are cited by ref and path only.

## Verification Steps

1. Run PoshQC MCP `run_poshqc_format` on the changed `.ps1`/`.psm1` files and new test files; confirm a passing summary.
2. Run PoshQC MCP `run_poshqc_analyze` on the same files; confirm a passing summary.
3. Run PoshQC MCP `run_poshqc_test` for `tests/scripts/host-tools.manifest.Tests.ps1`, `tests/scripts/dev-tools/HostTooling.Tests.ps1`, `tests/scripts/dev-tools/HostBootstrap.Tests.ps1`, `tests/scripts/dev-tools/HostBootstrap.Invoke.Tests.ps1`, `tests/scripts/dev-tools/HostBootstrapWorkspace.Tests.ps1`, `tests/scripts/dev-tools/bootstrap-host.Tests.ps1`, `tests/scripts/dev-tools/HostVerification.Invoke.Tests.ps1`, and `tests/scripts/dev-tools/publish-sideloaded-extension.Tests.ps1`; confirm a passing summary. Before the fix, confirm the new AC-5, AC-8, and AC-15 tests report failure (expect-fail run).
4. Search `scripts/` and `tests/` for `bootstrap-host.sh`; confirm no match.
5. Confirm line counts of every changed or new file are at most 500.
6. On the PR, confirm the CI `PowerShell QC` job passes, and read `artifacts/pester/powershell-coverage.xml` from that job to confirm line coverage >= 85% for each changed file under `scripts/dev-tools/`.

## Evidence Checklist
- [ ] baseline
- [ ] targeted verification
- [ ] end-state
