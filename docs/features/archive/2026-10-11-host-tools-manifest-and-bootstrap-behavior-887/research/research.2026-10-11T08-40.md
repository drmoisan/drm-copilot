# Research: host tools manifest, bootstrap message, native output streaming, publish preference forwarding (#887, #888)

- Canonical issue: #887 (combined bug item covering #887 and #888)
- Branch: `bug/host-tools-manifest-and-bootstrap-behavior-887`
- Work mode: minor-audit
- Researched: 2026-10-11
- Lifecycle records (unmerged ref, not readable from this worktree; cited by ref and path only): `origin/docs/followups-2026-10-11:docs/features/potential/promoted/2026-10-09-host-tools-manifest-and-bash-bootstrap-missing.md` (#887) and `origin/docs/followups-2026-10-11:docs/features/potential/promoted/2026-10-11-host-bootstrap-output-buffering-and-publish-whatif-forwarding.md` (#888). The un-promoted draft of the #887 record is present on this branch at `docs/features/potential/2026-10-09-host-tools-manifest-and-bash-bootstrap-missing.md` and was read.

## 1. Sources read

| Source | Purpose |
|---|---|
| `scripts/dev-tools/HostTooling.psm1` (198 lines) | manifest path/read seams, `Invoke-HostNativeCommand`, version parsing |
| `scripts/dev-tools/HostBootstrap.psm1` (463 lines) | bootstrap orchestrator, manifest reads, non-Windows message, pip call |
| `scripts/dev-tools/HostBootstrapWorkspace.psm1` (290 lines) | project repositories, native wrappers |
| `scripts/dev-tools/HostVerification.psm1` (392 lines) | verification manifest reads, version comparison |
| `scripts/dev-tools/publish-sideloaded-extension.ps1` (83 lines), `SideloadedExtensionPublish.psm1` (456 lines) | publish forwarding |
| `scripts/dev-tools/bootstrap-host.ps1`, `verify-host.ps1` | entry scripts |
| `tests/scripts/dev-tools/*.Tests.ps1` (11 suites for these modules) | existing assertions |
| #847 artifacts: `docs/features/active/2026-10-08-powershell-aggregate-line-coverage-below-floor-847/code-review.2026-10-10T01-41.md` (lines 38, 63, 92-95), `feature-audit.2026-10-10T01-41.md` (line 87, FA-N2), `spec.md` (DR-1 line 29, scope line 49-55), `plan.2026-10-08T23-43.md` (lines 114, 127, 129), `research/research.2026-10-08T23-50.md` (line 155) | pre-#847 behavior |
| `scripts/powershell/PoshQC/PoshQC.psm1:55-58`, `.github/workflows/_poshqc.yml`, `_quality-checks.yml`, `pyproject.toml:36-41`, `README.md:285-320`, `.devcontainer/verify-container.sh:101`, `.devcontainer/codespaces/Dockerfile:39-46,64,104` | tool inventory grounding |
| `quality-tiers.yml:19-21`, `config/poshqc-coverage.json`, `config/poshqc-scan.json`, `scripts/powershell/PoshQC/settings/pssa.settings.psd1:24-26` | tier, coverage, analyzer settings |
| `github.com/microsoft/winget-pkgs` manifests tree (fetched 2026-10-11) | winget package ID existence |

Tier: `scripts/dev-tools` is T4 (`quality-tiers.yml:19-21`). Uniform gates apply (line coverage >= 85%; PowerShell exempt from the branch threshold). Coverage population: `config/poshqc-coverage.json` roots include `scripts`, so every changed `.ps1`/`.psm1` under `scripts/dev-tools` is in the denominator. Pester discovery: `config/poshqc-scan.json` `scanFolders` = `scripts`, `tests/powershell`, `tests/scripts`, so a new suite at `tests/scripts/host-tools.manifest.Tests.ps1` is discovered. The `.json` manifest itself is not a coverage file.

## 2. Findings — #887

### 2.1 Manifest path and read behavior

- `Get-HostToolsManifestPath` returns `Join-Path $PSScriptRoot '..\host-tools.manifest.json'` (`HostTooling.psm1:24`), that is, `scripts/host-tools.manifest.json` reached through an unnormalized `scripts/dev-tools/../` segment.
- `Read-HostToolsManifest` returns `$null` when `Test-Path` fails, otherwise `Get-Content -Raw | ConvertFrom-Json` (`HostTooling.psm1:39-43`).
- Bootstrap throws `Host tools manifest not found at <path>` (`HostBootstrap.psm1:27-31`); verification raises `Manifest not found at <path>` (`HostVerification.psm1:340-343`). The file is absent on this branch (Glob for `**/host-tools.manifest.json` returned no match).
- Both modules run under `Set-StrictMode -Version Latest` (`HostBootstrap.psm1:12`, `HostVerification.psm1:12`, `HostBootstrapWorkspace.psm1:14`), so reading a missing property on a parsed manifest object raises a terminating error. Every key read must be present.

**Unnormalized path assertions (#847 tests):** the only assertion of the path form is `tests/scripts/dev-tools/HostTooling.Tests.ps1:31-37` (`Should -BeLike '*scripts/dev-tools/../host-tools.manifest.json'`, with the comment at line 35 stating the `..` segment is preserved so error messages keep their form). All other manifest-path references in tests are mocked fixture strings (`HostBootstrap.Tests.ps1:41,50,56`; `HostBootstrap.Invoke.Tests.ps1:49,119`; `HostVerification.Invoke.Tests.ps1:26,63,68`). **Recommendation:** keep the path unnormalized. Restoring the file at `scripts/host-tools.manifest.json` makes the existing path resolve; normalizing it would change the error-message text asserted indirectly and is unnecessary.

### 2.2 Keys, sub-keys and value shapes read by the code

| Key path | Read site | Required shape | Notes |
|---|---|---|---|
| `installPackages.windows.winget` | `HostBootstrap.psm1:200` | non-empty array; throws `No Windows winget packages configured ...` when empty (`:201-203`) | |
| `installPackages.windows.winget[].id` | `HostBootstrap.psm1:361` | non-empty string (winget `--id --exact`, `:66-75`) | |
| `installPackages.windows.winget[].name` | `HostBootstrap.psm1:361` | string; used as `Get-Command $Name` probe (`:53`) so it must be the command name; `"poetry"` enables the pip fallback (`:78-82`) | |
| `powershellModules[].name` | `HostBootstrap.psm1:387,422`; `HostVerification.psm1:267-281` | module name | |
| `powershellModules[].minimumVersion` | `HostBootstrap.psm1:387,422`; `HostVerification.psm1:277,281` | string castable to `[version]`; bootstrap installs **exactly** this version via `Install-Module -RequiredVersion` (`HostBootstrap.psm1:301,387`) | must exist on PSGallery |
| `projectRepositories` | `HostBootstrapWorkspace.psm1:49-53` | optional (absence returns empty); array | see 2.4 for an empty/single-entry defect |
| `projectRepositories[].url` | `HostBootstrapWorkspace.psm1:123-125,134,144-149` | non-empty string, else throws `Each projectRepositories entry must include a non-empty 'url'.` | |
| `projectRepositories[].targetPath` | `HostBootstrapWorkspace.psm1:129-134,184` | optional string (line 184 reads it without a presence check) | |
| `projectRepositories[].name` | `HostBootstrapWorkspace.psm1:182` | read on every entry under StrictMode by `Where-Object { $_.name -eq "drm-copilot" }` | effectively required for non-empty lists |
| `minimumVersions.python/.poetry/.pwsh/.node` | `HostVerification.psm1:149-152` | strings castable to `[version]` (`Test-VersionAtLeast`, `:108`) | only these four sub-keys are read |
| `requiredCommands` | `HostVerification.psm1:126-131` | string array; on Windows `bashdb` and `copilot` are removed (`:127-128`) | |
| `optionalCommands` | `HostVerification.psm1:239` | string array; missing command is a warning only (`:245`) | |
| `pythonTools` | `HostVerification.psm1:309-319` | string array; each run as `poetry run <tool> --version`, pass on exit 0 | |

### 2.3 Version parsing

- Actual versions are parsed by `ConvertTo-HostToolVersion` with regex `(\d+\.\d+(?:\.\d+)?)` then `[version]` (`HostTooling.psm1:160-166`). A `v` prefix is tolerated on the **actual** tool output (`v24.14.0` -> `24.14.0`; test `HostTooling.Tests.ps1:167-169`), and a fourth component is dropped (`2.53.0.windows.1` -> `2.53.0`).
- Minimum strings are cast directly with `[version]$Minimum` (`HostVerification.psm1:108`) and `[version]$moduleSpec.minimumVersion` (`:277`). A `v`-prefixed minimum (`"v24.14.0"`) would throw a cast error. Pinned minimums must therefore be plain dotted numbers. All proposed values (`3.13.12`, `2.3.2`, `7.6.6`, `24.14.0`, `5.6.1`, `1.22.0`) are valid `[version]` strings; 4-part strings would also cast, but none are needed.
- Expected tool outputs and parse results: `python --version` -> `Python 3.13.12` -> `3.13.12`; `poetry --version` -> `Poetry (version 2.3.2)` -> `2.3.2` (`Get-PoetryVersionInfo` via `Get-CommandVersion`, `HostVerification.psm1:26-32`); `pwsh --version` -> `PowerShell 7.6.6` -> `7.6.6`; `node --version` -> `v24.14.0` -> `24.14.0`. Each equals its pinned minimum, so `-ge` passes on the observing machine.

### 2.4 Defect found: empty or single-entry `projectRepositories`

- `Get-ProjectRepositoriesFromManifest` ends with `return @($Manifest.projectRepositories)` (`HostBootstrapWorkspace.psm1:53`) and `return @()` (`:50`). PowerShell unrolls function output, so the caller at `HostBootstrap.psm1:350` (`$projects = Get-ProjectRepositoriesFromManifest ...`) receives `$null` for an empty list and a bare `PSCustomObject` for a single entry. Only lists of two or more stay arrays; the existing orchestrator fixture uses exactly two entries (`HostBootstrap.Invoke.Tests.ps1:58-61`), and the unit tests wrap the call in `@()` (`HostBootstrapWorkspace.Tests.ps1:169,178`), so neither path exercises the unrolled value.
- In apply mode without `-SkipProjectPoetryInstall`, `Resolve-ProjectRepoRoot -Projects $projects` (`HostBootstrap.psm1:397`) binds to `[Parameter(Mandatory = $true)] [object[]]$Projects` (`HostBootstrapWorkspace.psm1:169-170`), which has no `[AllowEmptyCollection()]`. PowerShell rejects a null or empty array for a mandatory parameter, so apply mode fails with a binding error for an empty list.
- `$projects.Count` at `HostBootstrap.psm1:391,426` on `$null` or a scalar under StrictMode Latest: behavior not verified in this session (could not run `pwsh`). The fix below makes it irrelevant.
- A non-empty list naming this repository is hazardous: `Resolve-WorkspaceRoot` defaults to the current location (`HostBootstrapWorkspace.psm1:70-72`), so a `drm-copilot` entry run from the repo root would plan to clone the repository into `<repo>\drm-copilot`.

**Recommendation:** commit `"projectRepositories": []` and make two one-line code changes: `$projects = @(Get-ProjectRepositoriesFromManifest -Manifest $manifest)` at `HostBootstrap.psm1:350`, and add `[AllowEmptyCollection()]` to `Resolve-ProjectRepoRoot -Projects` (`HostBootstrapWorkspace.psm1:169-170`). `Resolve-ProjectRepoRoot` then returns the repo root through its `pyproject.toml` default (`:177-180`). `Sync-ProjectsFromManifest` is not called for an empty list (`HostBootstrap.psm1:391,426`).

### 2.5 Tool inventory grounding

| Tool | Repository evidence |
|---|---|
| git, gh | `link-feature-docs.ps1:92`, `link-parent-child.ps1:115` require `gh`; `.devcontainer/verify-container.sh:101` lists `git`, `gh` |
| python, poetry | `README.md:289-290`; `pyproject.toml:17`; `HostVerification.psm1:149-150` |
| node, npm, npx | `README.md:295-301`; `SideloadedExtensionPublish.psm1:390-391` asserts `npm` and `npx` |
| pwsh | `README.md:306,310-311`; `HostVerification.psm1:151` |
| code | `SideloadedExtensionPublish.psm1:432` resolves `code`/`code-insiders`; `README.md:294` |
| bashdb, copilot | `HostVerification.psm1:128` filters them on Windows; `.devcontainer/verify-container.sh:101` (bashdb); `.devcontainer/codespaces/Dockerfile:39-46` (bashdb), `:104` (copilot); `HostBootstrap.psm1:438-439,457` (copilot manual install) |
| wsl | `HostBootstrap.psm1:163-186` installs it; shell QC on Windows runs bats through WSL |
| gt (Graphite) | `HostBootstrap.psm1:373` installs `@withgraphite/graphite-cli@1.7.14`; `Dockerfile:64` |
| shellcheck, shfmt, bats | `README.md:320`; `_shell-coverage.yml:16-19` |
| dotnet | `README.md:318` (C# per-language toolchain only; no C# project in the repo outside `tests/fixtures`) |
| actionlint | `run-actionlint.ps1:41-60` (downloads a local copy when absent) |
| black, ruff, pyright, pytest | `pyproject.toml:37-41`; `README.md:315`; `_quality-checks.yml:56-81` |
| Pester, PSScriptAnalyzer | `PoshQC.psm1:55-58` pins `PSScriptAnalyzer 1.22.0` and `Pester 5.6.1`; `_poshqc.yml:73` `Import-Module Pester -MinimumVersion 5.6.1` |
| powershell-yaml | installed locally but no repository usage (Grep for `powershell-yaml|ConvertFrom-Yaml` outside `docs/`: no match). Excluded. |

**winget IDs verified** against `github.com/microsoft/winget-pkgs/tree/master/manifests` on 2026-10-11: `Git.Git` (`g/Git/Git`), `Python.Python.3.13` (`p/Python/Python/3/13`), `OpenJS.NodeJS.LTS` (`o/OpenJS/NodeJS/LTS`), `Microsoft.PowerShell` (`m/Microsoft/PowerShell`), `GitHub.cli` (`g/GitHub/cli`), `Microsoft.VisualStudioCode` (`m/Microsoft/VisualStudioCode`). No Poetry package was found at `p/Python/` (subfolders: Launcher, Python, PythonEmbeddablePackage, PythonInstallManager), `p/Poetry` (404) or `p/PythonPoetry` (404). This search was not exhaustive.

**Poetry decision:** do not list a poetry winget entry. Listing an unverified ID only to make winget fail and trigger the pip fallback (`HostBootstrap.psm1:77-82`) would make an error path load-bearing. Residual gap: on a host without poetry, bootstrap does not install it (`Install-PoetryWithPip` is reachable only from the winget catch). Record as a follow-up candidate; it is outside the operator-listed scope.

### 2.6 Observed host versions (orchestrator observation, 2026-10-11)

| Tool | Version | Observation command |
|---|---|---|
| python | 3.13.12 | `python --version` |
| poetry | 2.3.2 | `poetry --version` |
| node | 24.14.0 | `node --version` -> `v24.14.0` |
| npm | 11.9.0 | `npm --version` |
| git | 2.53.0 | `git --version` -> `git version 2.53.0.windows.1` |
| winget | 1.29.380 | `winget --version` -> `v1.29.380` |
| gh | 2.87.3 | `gh --version` |
| dotnet | 10.0.401 | `dotnet --version` |
| VS Code | 1.126.0 | `code --version` |
| pwsh | 7.6.6 | read from `C:/Program Files/PowerShell/7/pwsh.deps.json`, entry `Microsoft.PowerShell.SDK/7.6.6` (direct `pwsh --version` refused by the worktree isolation guard) |
| Pester | 5.6.1 and 5.7.1 | module folders under `C:/Users/DanMoisan/OneDrive/Documents/PowerShell/Modules/Pester` (5.6.1) and `C:/Users/DanMoisan/OneDrive - The Real Good Food Company/Documents/PowerShell/Modules/Pester` (5.7.1) |
| PSScriptAnalyzer | 1.22.0, 1.24.0, 1.25.0 / 1.22.0 | first Documents path / second Documents path |
| powershell-yaml | installed, version folder not listed | not used |

Only `python`, `poetry`, `pwsh`, `node` minimums are read by the code (`HostVerification.psm1:149-152`). The remaining observed versions (npm, git, winget, gh, dotnet, VS Code) are recorded here only; adding unread keys under `minimumVersions` would imply enforcement that does not occur.

**Pester minimum = 5.6.1 (lower observed).** Which Documents path is on the active `PSModulePath` is unknown. `Test-HostPowerShellModule` takes the highest version from `Get-Module -ListAvailable` (`HostVerification.psm1:267-269`), so a 5.6.1 minimum passes whichever path is active, while 5.7.1 would fail if only the 5.6.1 path is active. Bootstrap installs exactly the minimum (`-RequiredVersion`, `HostBootstrap.psm1:301`), and 5.6.1 is the version PoshQC installs (`PoshQC.psm1:57`) and CI requires (`_poshqc.yml:73`). **PSScriptAnalyzer minimum = 1.22.0**: present on both paths and pinned by `PoshQC.psm1:56`.

### 2.7 Proposed manifest (`scripts/host-tools.manifest.json`)

```json
{
  "installPackages": {
    "windows": {
      "winget": [
        { "id": "Git.Git", "name": "git" },
        { "id": "Python.Python.3.13", "name": "python" },
        { "id": "OpenJS.NodeJS.LTS", "name": "node" },
        { "id": "Microsoft.PowerShell", "name": "pwsh" },
        { "id": "GitHub.cli", "name": "gh" },
        { "id": "Microsoft.VisualStudioCode", "name": "code" }
      ]
    }
  },
  "powershellModules": [
    { "name": "Pester", "minimumVersion": "5.6.1" },
    { "name": "PSScriptAnalyzer", "minimumVersion": "1.22.0" }
  ],
  "projectRepositories": [],
  "minimumVersions": {
    "python": "3.13.12",
    "poetry": "2.3.2",
    "pwsh": "7.6.6",
    "node": "24.14.0"
  },
  "requiredCommands": ["git", "gh", "npm", "npx", "code", "bashdb", "copilot"],
  "optionalCommands": ["wsl", "gt", "dotnet", "shellcheck", "shfmt", "bats", "actionlint"],
  "pythonTools": ["black", "ruff", "pyright", "pytest"]
}
```

Justification per value:
- winget `name` values are the command names probed at `HostBootstrap.psm1:53`; IDs verified in 2.5. `npm`/`npx` ship with `OpenJS.NodeJS.LTS`.
- `requiredCommands` omits `python`, `node`, `pwsh`, `poetry` because `Test-HostCoreVersion` already checks them (`HostVerification.psm1:148-190`), and listing `poetry` would fail on hosts where only `python -m poetry` works (the core check accepts that fallback, `:41-60`; the required-command check does not). `bashdb` and `copilot` are kept for non-Windows verify parity with the dev container; they are filtered on Windows (`:127-128`).
- `wsl` is optional rather than required so a non-Windows `verify-host.ps1` run does not fail on it; bootstrap installs it on Windows (`HostBootstrap.psm1:346`).
- `pythonTools` are executables in the Poetry dev group that accept `--version` (`pyproject.toml:37-41`); `pytest-cov` is a plugin, not a command, and is excluded.
- `minimumVersions` and `powershellModules` per 2.6.

## 3. Findings — #887 non-Windows message

- Current text: `This script targets Windows. Use ./scripts/bash/bootstrap-host.sh on Linux/macOS.` (`HostBootstrap.psm1:335`). `scripts/bash/` contains no bootstrap script (Glob: `.gitkeep`, `coverage_demo.sh`, `coverage_lib.sh`, `kcov_trace_env.sh`, `shell-qc.sh`, `shell_qc_lib.sh`).
- Existing Linux/macOS provisioning in the repository is the dev container: `.devcontainer/codespaces/devcontainer.json`, `.devcontainer/local/devcontainer.json`, `.devcontainer/README.md`, with `verify-container.sh` as its verification analogue.
- **Proposed text:** `This script targets Windows. On Linux/macOS, use the dev container defined under .devcontainer/ (see .devcontainer/README.md).`
- **Assertions of the old text (complete list; Grep `bootstrap-host\.sh|targets Windows` over `tests/`):**
  - `tests/scripts/dev-tools/HostBootstrap.Invoke.Tests.ps1:124` (exact message)
  - `tests/scripts/dev-tools/HostBootstrap.Invoke.Tests.ps1:133` (wildcard `This script targets Windows.*`; survives the change unchanged)
  - `tests/scripts/dev-tools/bootstrap-host.Tests.ps1:76` (mock body text) and `:80` (expected message). This suite mocks `Invoke-BootstrapHost`, so updating it is for consistency, not correctness.
- Non-test occurrences of `bootstrap-host.sh` outside `docs/`: only `HostBootstrap.psm1:335`.

## 4. Findings — #888 native output streaming

### 4.1 Current behavior and pre-#847 behavior

- `Invoke-HostNativeCommand` assigns output to `$output` (`HostTooling.psm1:124-129`) and returns `{ Output; ExitCode }` (`:136-139`), so output appears only after the process exits. It reads global `$LASTEXITCODE` without resetting it (`:131-134`; code-review CR-N4).
- Pre-#847, bootstrap invoked natives directly in the output pipeline (code-review line 92, evidence "Base `bootstrap-host.ps1:98`, `:111`, `:121`, `:226`, helpers `:11`"); #847 plan line 129 confirms pip stdout "reached the pipeline". The #847 spec accepted an output-timing change only for `verify-host.ps1` (code-review line 51; spec DR-1 line 29), so the bootstrap change is an undocumented deviation (CR-N1; feature-audit FA-N2, line 87).

### 4.2 Callers (complete; see Numeric Derivation Evidence)

| Call site | Wrapper | Consumes | Required mode |
|---|---|---|---|
| `HostBootstrapWorkspace.psm1:30` | `Invoke-HostBootstrapGit` | emits `.Output` (`:31`), throws on `.ExitCode -ne 0` | stream |
| `HostBootstrapWorkspace.psm1:202` | `Invoke-HostBootstrapWinget` | emits `.Output` (`:203`), throws on nonzero | stream |
| `HostBootstrapWorkspace.psm1:220` | `Invoke-HostBootstrapNpm` | emits `.Output` (`:221`), no exit check | stream |
| `HostBootstrapWorkspace.psm1:235` | `Invoke-HostBootstrapWsl` | emits `.Output` (`:236`), throws on nonzero | stream |
| `HostBootstrapWorkspace.psm1:269` | `Invoke-HostBootstrapPoetry` (poetry) | emits `.Output` (`:270`), throws on nonzero | stream |
| `HostBootstrapWorkspace.psm1:283` | `Invoke-HostBootstrapPoetry` (python -m poetry) | emits `.Output` (`:284`), throws on nonzero | stream |
| `HostBootstrap.psm1:144` | `Install-PoetryWithPip` | emits `.Output` (`:145`), throws on nonzero (`:146-148`) | stream |
| `HostTooling.psm1:193` | `Get-CommandVersion` | parses `.Output` text, `-MergeErrorStream` | capture (unchanged) |
| `HostVerification.psm1:46` | `Get-PoetryVersionInfo` | `.ExitCode`, parses `.Output`, `-MergeErrorStream` | capture (unchanged) |
| `HostVerification.psm1:77` | `Invoke-PoetryCommand` (poetry) | returns result; `.Output` first line used at `:312-314` | capture (unchanged) |
| `HostVerification.psm1:82` | `Invoke-PoetryCommand` (python -m poetry) | same | capture (unchanged) |

`Invoke-HostBootstrapVerifyScript` (`HostBootstrapWorkspace.psm1:253`) runs `& $ScriptPath` uncaptured and already streams.

### 4.3 Recommended design

Add a `Stream` parameter set to the existing single native seam; verification keeps capture mode.

```powershell
function Invoke-HostNativeCommand {
    [CmdletBinding(DefaultParameterSetName = 'Capture')]
    [OutputType([psobject])]
    param(
        [Parameter(Mandatory = $true)]
        [string]$FilePath,

        [Parameter()]
        [string[]]$ArgumentList = @(),

        [Parameter(ParameterSetName = 'Capture')]
        [switch]$MergeErrorStream,

        [Parameter(ParameterSetName = 'Stream')]
        [switch]$StreamToHost
    )

    Set-Variable -Name 'LASTEXITCODE' -Value 0 -Scope Global
    $output = @()
    if ($StreamToHost) {
        & $FilePath @ArgumentList | Out-Host
    }
    elseif ($MergeErrorStream) {
        $output = & $FilePath @ArgumentList 2>&1
    }
    else {
        $output = & $FilePath @ArgumentList
    }
    # existing exit-code read and return shape unchanged: Output = @($output); ExitCode = [int]...
}
```

- Stdout is written to the host line by line as the process produces it; stderr from a native command that is not redirected goes to the console directly. `$LASTEXITCODE` is read after the pipeline completes, so exit-code semantics are unchanged.
- The pre-invocation reset addresses CR-N4 and makes the stream-mode test deterministic. `Set-Variable ... -Scope Global` mirrors the existing `Get-Variable ... -Scope Global` read at `:131`. PSScriptAnalyzer has `PSAvoidGlobalVars` enabled (`pssa.settings.psd1:24`); `bootstrap-host.ps1:30` already assigns `$global:LASTEXITCODE` and passes CI analysis, but `Set-Variable` avoids depending on that rule's automatic-variable exemption.
- `Out-Host` is not flagged by `PSAvoidUsingWriteHost` (`pssa.settings.psd1:26`), which targets `Write-Host`.
- The return shape stays `{ Output; ExitCode }` (Output empty in stream mode), so no caller needs a new result type.
- Wrapper changes: each of the seven bootstrap call sites passes `-StreamToHost` and drops its `$result.Output` / `$pipResult.Output` emission line; the npm wrapper becomes `$null = Invoke-HostNativeCommand -FilePath 'npm' -ArgumentList $NpmArgs -StreamToHost` (avoids an unused-variable warning). Throw messages are unchanged.
- File sizes after change: `HostTooling.psm1` about 205 lines; `HostBootstrapWorkspace.psm1` about 285; `HostBootstrap.psm1` about 462. All stay under 500.

Accepted difference from pre-#847: native stdout goes to the host rather than the function's pipeline, so a caller that captures `bootstrap-host.ps1` output into a variable no longer receives native lines. The only production invocations are interactive and the RunOnce `pwsh -File` command (`HostBootstrap.psm1:263`), both of which render to the console. Whether progress bars that depend on console detection render identically to pre-#847 is not verified; piping a native command redirects its stdout. The acceptance criteria target line-by-line delivery during execution, not progress-bar rendering.

### 4.4 Unit-test approach (no real process)

Existing tests already call the real seam with the in-process cmdlet `Write-Output` (`HostTooling.Tests.ps1:142-160`; policy-audit line 134 accepted this). For stream mode: `Mock -CommandName Out-Host -ModuleName HostTooling -MockWith { }`, set a global `LASTEXITCODE` sentinel (precedent: `bootstrap-host.Tests.ps1:42`), call `Invoke-HostNativeCommand -FilePath 'Write-Output' -ArgumentList @('alpha') -StreamToHost`, and assert: `Out-Host` invoked with `$InputObject -eq 'alpha'`; `.Output` empty; `.ExitCode -eq 0` (sentinel reset). Wrapper tests mock the seam and assert `-ParameterFilter { $StreamToHost }` and that the wrapper emits no fixture lines.

## 5. Findings — #888 publish preference forwarding

### 5.1 Current behavior

- The entry script forwards `WhatIf`, `Confirm`, `Verbose`, `WarningAction` only when bound (`publish-sideloaded-extension.ps1:70-81`).
- `Invoke-SideloadedExtensionPublish` is a script-module function (`SideloadedExtensionPublish.psm1:348-454`). Module functions resolve preference variables through function, module, then global scope, not through the caller's scope (#847 research line 155; code-review CR-N2, line 93). An inherited `$WhatIfPreference = $true`, for example from a parent run with `-WhatIf`, no longer suppresses the ShouldProcess-gated steps (`:401,410,416,421,442`). In the pre-#847 script the functions were script-local, so they inherited by dynamic scope.
- `-Debug`, `-InformationAction` and `-ErrorAction` are not forwarded. The only in-repo caller is `.vscode/tasks.json:219` (`pwsh -File` with explicit arguments).

### 5.2 ErrorAction analysis

The entry script sets `$ErrorActionPreference = "Stop"` at line 54, after binding. A bound `-ErrorAction` sets the script-scope preference at bind time and line 54 then overwrites it, so in the pre-#847 script a caller's `-ErrorAction` had no effect on the script-local functions. Not forwarding it is therefore behavior-equivalent to the base. Forwarding `-ErrorAction SilentlyContinue` would set a local `$ErrorActionPreference` inside the advanced function. Community analyses of PowerShell error handling report that `throw` honors a `SilentlyContinue` preference; this was not verified in this session. The repository already guards against that pattern: `HostBootstrap.psm1:335,339` use `Write-Error -ErrorAction Stop`, and tests at `HostBootstrap.Invoke.Tests.ps1:132-134` and `HostVerification.Invoke.Tests.ps1:56-60` assert termination under `-ErrorAction SilentlyContinue`. Forwarding could therefore let `throw "VSIX was not created as expected"` (`SideloadedExtensionPublish.psm1:426`) be suppressed. **Recommendation:** do not forward `ErrorAction`. Keep the existing assertion and record the rationale in the PR. The operator should confirm this point.

### 5.3 Recommended design (inline in the entry script)

`SideloadedExtensionPublish.psm1` is 456 lines, and a helper there would approach the 500-line limit. The entry script is 83 lines. Replace lines 70-81 with:

```powershell
$forwardedCommonParameterNames = @('WhatIf', 'Confirm', 'Verbose', 'Debug', 'WarningAction', 'InformationAction', 'ProgressAction')
foreach ($name in $forwardedCommonParameterNames) {
    if ($PSBoundParameters.ContainsKey($name)) {
        $invokeParameters[$name] = $PSBoundParameters[$name]
    }
}
if (-not $invokeParameters.ContainsKey('WhatIf') -and $WhatIfPreference) {
    $invokeParameters['WhatIf'] = $true
}
if (-not $invokeParameters.ContainsKey('Confirm')) {
    if ($ConfirmPreference -eq 'None') {
        $invokeParameters['Confirm'] = $false
    }
    elseif ($ConfirmPreference -le 'Medium') {
        $invokeParameters['Confirm'] = $true
    }
}
if (-not $invokeParameters.ContainsKey('Verbose') -and $VerbosePreference -eq 'Continue') {
    $invokeParameters['Verbose'] = $true
}
if (-not $invokeParameters.ContainsKey('Debug') -and $DebugPreference -eq 'Continue') {
    $invokeParameters['Debug'] = $true
}
```

Rules: a bound value wins. Otherwise only non-default inherited preferences are forwarded. `WhatIf` is forwarded when the effective `$WhatIfPreference` is true. `Confirm` maps the inherited `$ConfirmPreference` against the callee's `ConfirmImpact = 'Medium'` (`SideloadedExtensionPublish.psm1:353`): `None` maps to `-Confirm:$false`, `Low` or `Medium` to `-Confirm:$true`, and `High` (the default) adds no key. `ProgressAction` exists only on PowerShell 7.4+, and the `ContainsKey` guard is safe on earlier versions. Because nothing is added under default preferences, the existing assertion `-not $PesterBoundParameters.ContainsKey('WhatIf')` (`publish-sideloaded-extension.Tests.ps1:126`) still holds.

### 5.4 Testing inherited preferences in Pester

Set the preference in a child scriptblock so the change is confined to that scope: `& { $WhatIfPreference = $true; $null = & $script:entryPath -RepoRoot 'C:\fixture\repo' }`. The entry script's scope is a child of that scriptblock scope, so it inherits the value dynamically, while the module function does not. Two kinds of test apply:
1. Forwarding tests (existing Describe `parameter forwarding`, `Invoke-SideloadedExtensionPublish` mocked at test scope): assert `$PesterBoundParameters` keys and values.
2. Real-orchestrator test (existing Describe `real orchestrator`, helpers mocked `-ModuleName SideloadedExtensionPublish`): with inherited `$WhatIfPreference = $true` and no `-WhatIf`, assert zero calls to `New-Item`, `Invoke-NpmCiWithRetry`, `Invoke-ProjectCompile`, `Invoke-ExternalCommand`, `Invoke-SideloadedExtensionProcess`. On the current code the module function sees `$WhatIfPreference = $false`, reaches `New-Item` (`:401-402`, since `Test-Path` returns false for `C:\fixture\vsix`), and hits the throwing default mock (`publish-sideloaded-extension.Tests.ps1:24`). The test therefore fails before the fix and passes after it.

## 6. Test inventory

### 6.1 Existing tests to update

| File:line | Test | Change |
|---|---|---|
| `tests/scripts/dev-tools/HostBootstrap.Invoke.Tests.ps1:124` | `AC06-BOOTSTRAP-PRECONDITION-ERRORS` | expected message to the new text |
| `tests/scripts/dev-tools/bootstrap-host.Tests.ps1:76,80` | `AC05-BOOTSTRAP-NONWINDOWS-EXIT1` | mock text and expected message to the new text |
| `tests/scripts/dev-tools/HostBootstrapWorkspace.Tests.ps1:31-38,48-55,65-72,74-80,84-91,116-126,135-146` | git/winget/npm/wsl/poetry wrapper success cases | assert `$StreamToHost` in the ParameterFilter; assert the wrapper emits no fixture output |
| `tests/scripts/dev-tools/HostBootstrapWorkspace.Tests.ps1:40-44,57-61,93-97,128-133,148-154` | nonzero-exit cases | unchanged messages; optionally add `$StreamToHost` filter |
| `tests/scripts/dev-tools/HostBootstrap.Tests.ps1:140-164` | pip install success | expected output `@('Installing poetry via python -m pip')`; filter adds `$StreamToHost` |
| `tests/scripts/dev-tools/publish-sideloaded-extension.Tests.ps1:109-119` | `forwards -Verbose and -WarningAction and does not forward -ErrorAction` | keep the ErrorAction-not-forwarded assertion (per 5.2); split Debug/InformationAction into a new case |
| `tests/scripts/dev-tools/HostTooling.Tests.ps1:142-160` | `Invoke-HostNativeCommand` capture cases | unchanged (capture mode); optional ExitCode-reset assertion |
| `tests/scripts/dev-tools/HostTooling.Tests.ps1:31-37` | unnormalized path | unchanged (kept) |

### 6.2 New tests (paths mirror source per the `tests/` layout rule)

| Target file | New case |
|---|---|
| `tests/scripts/dev-tools/HostTooling.Tests.ps1` (mirrors `scripts/dev-tools/HostTooling.psm1`) | `Get-HostToolsManifestPath` result exists as a file: `Test-Path -LiteralPath (Get-HostToolsManifestPath) -PathType Leaf` is true (fails today) |
| same | `-StreamToHost` sends output to `Out-Host`, returns empty Output, ExitCode 0 after a stale sentinel |
| same | capture mode resets a stale `LASTEXITCODE` (CR-N4) |
| `tests/scripts/host-tools.manifest.Tests.ps1` (new; mirrors `scripts/host-tools.manifest.json`) | parses the committed file; each top-level key present; `installPackages.windows.winget` non-empty with non-empty `id`/`name`; `powershellModules` entries have `name` and `[version]`-castable `minimumVersion`; `projectRepositories` is an array whose entries (if any) have non-empty `url` and a `name`; `minimumVersions` has `python`/`poetry`/`pwsh`/`node` castable to `[version]` with the pinned values; `requiredCommands`/`optionalCommands`/`pythonTools` are arrays of non-empty strings |
| same | runs `Test-HostCoreVersion`, `Test-HostRequiredCommand`, `Test-HostOptionalCommand`, `Test-HostPowerShellModule`, `Test-HostPoetryTool` against the parsed committed manifest with `Get-Command`, `Get-CommandVersion`, `Get-PoetryVersionInfo`, `Get-Module`, `Invoke-PoetryCommand` mocked `-ModuleName HostVerification`; asserts no StrictMode error and `FailureCount 0` when mocks report the pinned versions |
| `tests/scripts/dev-tools/HostBootstrap.Invoke.Tests.ps1` | dry run with `Read-HostToolsManifest` mocked to return the parsed committed manifest: last line `Dry run complete. Re-run with -Apply to install tools.`, one `Would install` line per winget entry, module preview `Pester 5.6.1, PSScriptAnalyzer 1.22.0` |
| same | apply mode with `projectRepositories = @()` does not throw a binding error and calls `Invoke-HostBootstrapPoetry` (fails today, per 2.4) |
| `tests/scripts/dev-tools/HostBootstrapWorkspace.Tests.ps1` | `Resolve-ProjectRepoRoot -Projects @()` returns the default repo root |
| `tests/scripts/dev-tools/publish-sideloaded-extension.Tests.ps1` | inherited `$WhatIfPreference` forwarded as `WhatIf $true`; bound `-WhatIf:$false` overrides an inherited true; inherited `$ConfirmPreference` `Low` maps to `Confirm $true`, `None` to `Confirm $false`, `High` adds no key; inherited `$VerbosePreference='Continue'` maps to `Verbose $true`; bound `-Debug` and `-InformationAction` forwarded; real orchestrator with inherited `$WhatIfPreference` makes zero seam calls (fails today) |

Repository-file access precedent: suites resolve repository files through `Resolve-Path "$PSScriptRoot/../../../scripts/dev-tools/<file>"` (for example `HostTooling.Tests.ps1:18`), and `publish-sideloaded-extension.Tests.ps1:131-139` reads the committed `extensions/drm-copilot/package.json`. The new manifest suite at `tests/scripts/` would use `$PSScriptRoot/../../scripts/host-tools.manifest.json`. Reading the committed file creates no temporary file, which satisfies the no-temporary-files rule. Parse it once in `BeforeAll` with `Get-Content -Raw | ConvertFrom-Json`.

## 7. Mirror inventory

No mirrors exist. Searches performed (Grep respects `.gitignore` and includes dot-directories such as `.claude`, `.codex`, `.github`, `.devcontainer`, which earlier searches in this session matched):
- `host-tools\.manifest|HostTooling\.psm1|Invoke-SideloadedExtensionPublish|bootstrap-host` excluding `docs/**`: matches only in `scripts/dev-tools/` and `tests/scripts/dev-tools/`.
- `scripts[/\\]dev-tools[/\\](Host|publish-sideloaded|SideloadedExtension|bootstrap-host|verify-host)|host-tools` excluding `docs/**` and `tests/**`: `.vscode/tasks.json` (invocation reference only) and the four modules.
- Glob `**/{HostTooling.psm1,HostBootstrap.psm1,publish-sideloaded-extension.ps1,host-tools.manifest.json,HostVerification.psm1,bootstrap-host.sh}`: only the `scripts/dev-tools/` originals.
- `dev-tools` in `extensions/drm-copilot` (excluding `node_modules`): references in rules, templates, push-down rewrite code and tests, none of which are copies of these files. `config/blast-radius.json:72` maps `scripts/dev-tools/**` as a blast-radius surface (not a mirror).

The #847 spec lists `.vscode/tasks.json` and `extensions/drm-copilot/resources/**` as excluded paths (spec line 55); neither requires a change here.

## 8. Numeric Derivation Evidence

### 8.1 Invoke-HostNativeCommand production call sites

- **Complete Family:** every production invocation of `Invoke-HostNativeCommand` (all argument forms, including splatted or positional).
- **Exhaustive Search Scope:** entire worktree excluding `docs/**` and `tests/**`, including dot-directories.
- **Inclusion Rules:** a line that invokes the function.
- **Exclusion Rules:** the function definition (`HostTooling.psm1:106`) and the `Export-ModuleMember` line (`HostTooling.psm1:198`).
- **Primary Search Strategy:** regex `Invoke-HostNativeCommand\s+-FilePath`.
- **Primary Member Set:** HostVerification.psm1:46, :77, :82; HostTooling.psm1:193; HostBootstrapWorkspace.psm1:30, :202, :220, :235, :269, :283; HostBootstrap.psm1:144.
- **Primary Count:** 11.
- **Cross-check Search Strategy:** bare token `Invoke-HostNativeCommand` (any form), then apply the exclusion rules.
- **Cross-check Member Set:** 13 raw lines minus HostTooling.psm1:106 (definition) and :198 (export), giving HostVerification.psm1:46, :77, :82; HostTooling.psm1:193; HostBootstrapWorkspace.psm1:30, :202, :220, :235, :269, :283; HostBootstrap.psm1:144.
- **Cross-check Count:** 11.
- **Member-set Comparison:** identical normalized sets. Partition: stream mode = HostBootstrapWorkspace.psm1:30, :202, :220, :235, :269, :283 and HostBootstrap.psm1:144 (7); capture mode = HostTooling.psm1:193 and HostVerification.psm1:46, :77, :82 (4).

### 8.2 Manifest top-level keys read

- **Complete Family:** top-level properties of the parsed manifest object read by `HostBootstrap.psm1`, `HostBootstrapWorkspace.psm1` and `HostVerification.psm1`.
- **Exhaustive Search Scope:** `scripts/dev-tools/*.psm1` (the only files that receive the manifest object; entry scripts pass no manifest).
- **Inclusion Rules:** a property access on `$Manifest`/`$manifest`, or a presence check by name.
- **Exclusion Rules:** fixture strings in tests and doc comments.
- **Primary Search Strategy:** regex `\$[Mm]anifest\.[A-Za-z]+` over `Host*.psm1`.
- **Primary Member Set:** requiredCommands (HostVerification:126), minimumVersions (:149-152), optionalCommands (:239), powershellModules (HostVerification:266; HostBootstrap:386, :421), pythonTools (HostVerification:309), projectRepositories (HostBootstrapWorkspace:53), installPackages (HostBootstrap:200).
- **Primary Count:** 7 distinct keys.
- **Cross-check Search Strategy:** literal key-name alternation `installPackages|powershellModules|projectRepositories|minimumVersions|requiredCommands|optionalCommands|pythonTools` over `scripts/dev-tools/*.psm1`, including the `PSObject.Properties.Name.Contains("projectRepositories")` presence check (HostBootstrapWorkspace:49).
- **Cross-check Member Set:** installPackages, powershellModules, projectRepositories, minimumVersions, requiredCommands, optionalCommands, pythonTools.
- **Cross-check Count:** 7.
- **Member-set Comparison:** identical; it also matches the operator-supplied key list.

### 8.3 Manifest sub-keys read

- **Complete Family:** properties read on manifest sub-objects (winget entries, module specs, project entries, minimumVersions).
- **Exhaustive Search Scope:** `scripts/dev-tools/Host*.psm1`.
- **Inclusion Rules:** a property read on a variable holding a manifest sub-object.
- **Exclusion Rules:** string methods (`$_.Trim`, `$_.TrimEnd`) and `PSObject` metadata access.
- **Primary Search Strategy:** regex `\$(moduleSpec|project|pkg|drmProject|_)\.[a-zA-Z]+` (only-matching), plus `minimumVersions\.(python|poetry|pwsh|node)`.
- **Primary Member Set:** winget entry `id`, `name` (HostBootstrap:361); module spec `name`, `minimumVersion` (HostBootstrap:387, :422; HostVerification:267-281); project `url` (HostBootstrapWorkspace:124, :134, :144, :148, :149), `targetPath` (:130, :184), `name` (:182); minimumVersions `python`, `poetry`, `pwsh`, `node` (HostVerification:149-152).
- **Primary Count:** 4 sub-object families; 11 property names (id, name; name, minimumVersion; url, targetPath, name; python, poetry, pwsh, node).
- **Cross-check Search Strategy:** literal alternation `minimumVersion\b|\.url\b|targetPath|\.id\b|\$pkg\.name|\$_\.name|moduleSpec\.name|drmProject` combined with the `minimumVersions` lines from 8.2.
- **Cross-check Member Set:** same reads at the same lines.
- **Cross-check Count:** 11 property names across 4 families.
- **Member-set Comparison:** identical.

### 8.4 Assertions of the old non-Windows message

- **Complete Family:** test lines that assert or emit the text `This script targets Windows` or `bootstrap-host.sh`.
- **Exhaustive Search Scope:** `tests/**`.
- **Primary Search Strategy:** regex `bootstrap-host\.sh|targets Windows`.
- **Primary Member Set:** HostBootstrap.Invoke.Tests.ps1:124, :133; bootstrap-host.Tests.ps1:76, :80.
- **Primary Count:** 4.
- **Cross-check Search Strategy:** literal `scripts/bash/bootstrap-host` plus the `This script targets Windows.*` wildcard form.
- **Cross-check Member Set:** HostBootstrap.Invoke.Tests.ps1:124, bootstrap-host.Tests.ps1:76, :80 (full path), and HostBootstrap.Invoke.Tests.ps1:133 (wildcard only).
- **Cross-check Count:** 4.
- **Member-set Comparison:** identical. Line 133 needs no change because its wildcard matches the proposed text.

## 9. Risks

1. **Pinned minimums are machine-specific.** Developers with older patch versions (for example python 3.13.x below 3.13.12, or node below 24.14.0) will see `verify-host.ps1` failures. This is an operator decision; the PR should state it. CI does not run `verify-host.ps1`.
2. **`Out-Host` mock pipeline semantics in Pester 5.** Whether `Should -Invoke Out-Host -ParameterFilter { $InputObject -eq 'alpha' }` counts one call per pipeline item has not been verified in this session. Assert at least one call (`-Times 1` without `-Exactly`) or confirm during the expect-fail run.
3. **Inherited preferences in Pester scope.** Setting `$WhatIfPreference`, `$ConfirmPreference` or `$VerbosePreference` in a child scriptblock is expected not to affect Pester internals, because module functions do not inherit caller scope. Confirm during the expect-fail run; redirect the verbose stream (`4>$null`) in the Verbose case.
4. **ErrorAction left unforwarded** (5.2). If the operator requires forwarding, add a guard that keeps `throw` paths terminating, and add a test that passes `-ErrorAction SilentlyContinue` and asserts the missing-VSIX error still terminates.
5. **Poetry is not auto-installed** on a fresh host (2.5). Pre-existing gap; candidate follow-up.
6. **`Get-Command python` may resolve the Microsoft Store alias** (`WindowsApps\python.exe`) and report python as installed. This is pre-existing behavior of `Install-WithWinget` (`HostBootstrap.psm1:53`) and is out of scope.
7. **Progress-bar rendering** under `| Out-Host` may differ from pre-#847 direct invocation (4.3). Not covered by the acceptance criteria.
8. **CI is the only coverage source.** PoshQC MCP results carry no counts or percentages; changed-file line coverage must be read from the CI artifact `artifacts/pester/powershell-coverage.xml` (`_poshqc.yml:44-52`).

## 10. Rejected alternatives

- **Add `scripts/bash/bootstrap-host.sh`:** rejected by operator decision; it would be a second implementation that must stay aligned with the PowerShell one.
- **Normalize the manifest path:** unnecessary once the file exists; it would break `HostTooling.Tests.ps1:31-37`.
- **`Start-Process -NoNewWindow -Wait -PassThru` for streaming:** keeps console inheritance, but loses call-operator resolution of `.cmd` shims such as `npm` and PowerShell native argument quoting (for example clone paths with spaces).
- **Pipeline streaming through a second exit-code seam:** preserves pipeline semantics but adds a second seam and couples wrappers to global state; `Out-Host` meets the requirement with one seam.
- **Separate streaming function:** a parameter set on the existing seam keeps the "single native-process seam" contract stated in `HostTooling.psm1:6-9`.
- **Forwarding helper in `SideloadedExtensionPublish.psm1`:** would push the 456-line module toward the 500-line limit; inline entry-script logic is testable through the existing entry suite.
- **`projectRepositories` entry for drm-copilot:** single-entry unrolling (2.4) and the self-clone hazard.

## 11. Proposed Acceptance Criteria (for issue.md)

- [ ] `scripts/host-tools.manifest.json` exists, parses with `ConvertFrom-Json`, and contains the top-level keys `installPackages` (with `windows.winget`), `powershellModules`, `projectRepositories`, `minimumVersions`, `requiredCommands`, `optionalCommands`, `pythonTools`.
- [ ] `minimumVersions` contains `python` `3.13.12`, `poetry` `2.3.2`, `pwsh` `7.6.6`, `node` `24.14.0`, and each value casts to `[version]`.
- [ ] `powershellModules` contains `{ name: Pester, minimumVersion: 5.6.1 }` and `{ name: PSScriptAnalyzer, minimumVersion: 1.22.0 }`.
- [ ] Every `installPackages.windows.winget` entry has a non-empty `id` and `name`, and `projectRepositories` is an array whose entries (if any) have a non-empty `url` and a `name`.
- [ ] `Get-HostToolsManifestPath` still returns the unnormalized `scripts/dev-tools/../host-tools.manifest.json` form (existing assertion at `HostTooling.Tests.ps1:31-37` unchanged), and a new test in `tests/scripts/dev-tools/HostTooling.Tests.ps1` fails if `Test-Path -LiteralPath (Get-HostToolsManifestPath) -PathType Leaf` is false.
- [ ] New suite `tests/scripts/host-tools.manifest.Tests.ps1` reads the committed manifest (no temporary files) and asserts the key and shape criteria above, and runs the five `HostVerification` section functions against it with host seams mocked without a StrictMode property error.
- [ ] `Invoke-BootstrapHost -IsWindowsHost $true` dry run over the parsed committed manifest (host seams mocked) ends with `Dry run complete. Re-run with -Apply to install tools.`
- [ ] `Invoke-BootstrapHost -Apply` with `projectRepositories` empty completes without a parameter-binding error (`HostBootstrap.psm1:350` wraps the result in `@()`; `Resolve-ProjectRepoRoot -Projects` carries `[AllowEmptyCollection()]`), covered by a test.
- [ ] The non-Windows precondition message in `HostBootstrap.psm1` no longer names `scripts/bash/bootstrap-host.sh` and names `.devcontainer/`; `HostBootstrap.Invoke.Tests.ps1:124` and `bootstrap-host.Tests.ps1:76,80` assert the new text; Grep for `bootstrap-host.sh` under `scripts/` and `tests/` returns no match.
- [ ] `Invoke-HostNativeCommand -StreamToHost` sends native output to `Out-Host` as it is produced, returns an empty `Output` and the `ExitCode` from `$LASTEXITCODE`, and resets a stale `$LASTEXITCODE` before invocation; capture mode (with and without `-MergeErrorStream`) is unchanged; covered by tests in `HostTooling.Tests.ps1`.
- [ ] The bootstrap call sites `HostBootstrapWorkspace.psm1` (git, winget, npm, wsl, poetry, python -m poetry) and `HostBootstrap.psm1` (pip) pass `-StreamToHost` and no longer emit captured output; the verification call sites (`HostTooling.psm1` `Get-CommandVersion`, `HostVerification.psm1` `Get-PoetryVersionInfo` and `Invoke-PoetryCommand`) remain in capture mode with `-MergeErrorStream`. Wrapper tests assert `-StreamToHost`, and the nonzero-exit throw messages are unchanged.
- [ ] `publish-sideloaded-extension.ps1` forwards `WhatIf = $true` when `$WhatIfPreference` is inherited true and `-WhatIf` is not bound; a bound `-WhatIf:$false` overrides it; `Confirm` maps from an inherited `$ConfirmPreference` (`None` gives `$false`, `Low`/`Medium` give `$true`, `High` adds no key); an inherited `$VerbosePreference`/`$DebugPreference` of `Continue` forwards `Verbose`/`Debug`; bound `-Debug`, `-InformationAction` and `-ProgressAction` are forwarded; `-ErrorAction` is not forwarded. Each rule is covered by a test in `publish-sideloaded-extension.Tests.ps1`.
- [ ] With an inherited `$WhatIfPreference = $true` and no `-WhatIf`, the real `Invoke-SideloadedExtensionPublish` path makes zero calls to `New-Item`, `Invoke-NpmCiWithRetry`, `Invoke-ProjectCompile`, `Invoke-ExternalCommand`, `Invoke-SideloadedExtensionProcess` (test fails before the fix).
- [ ] PoshQC MCP `run_poshqc_format`, `run_poshqc_analyze`, `run_poshqc_test` complete without failures on the changed files, and the CI `PowerShell QC` job passes.
- [ ] CI `powershell-coverage.xml` shows line coverage >= 85% for each changed `.ps1`/`.psm1` file and no regression on changed lines; no production file is added to a coverage exclusion.
- [ ] No changed or new file exceeds 500 lines.

## 12. Automation Feasibility

No step requires human interaction. All edits are file changes. PowerShell verification runs through the PoshQC MCP tools (`run_poshqc_format`, `run_poshqc_analyze`, `run_poshqc_test`). Coverage figures come from the CI `PowerShell QC` job artifact (`artifacts/pester/powershell-coverage.xml`), because MCP results carry a summary only. No test runs a real native process, writes a file, or depends on the host OS: `-IsWindowsHost` is passed explicitly, and native seams are mocked or exercised with the in-process `Write-Output` cmdlet. The version observations in 2.6 were already collected by the orchestrator, and the manifest test asserts committed values rather than live host versions, so nothing needs to be re-observed manually.
