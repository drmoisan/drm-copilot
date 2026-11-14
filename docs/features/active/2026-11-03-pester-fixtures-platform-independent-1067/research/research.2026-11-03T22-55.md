# Research: platform-independent Pester fixtures (issue #1067)

- Issue: #1067
- Branch: `bug/pester-fixtures-platform-independent`
- Inputs read: `evidence/baseline/linux-pester-baseline.2026-11-03T22-49.md`, `spec.md`, the full diff of commit df7cb4f31, the 17 failing suites, the production files they exercise, `.github/workflows/_poshqc.yml`, `config/poshqc-scan.json`, `.claude/skills/execution-environment/SKILL.md`, `.claude/skills/atomic-plan-contract/SKILL.md`, `.claude/rules/powershell.md`, `.claude/rules/general-unit-test.md`, `.github/instructions/powershell-unit-test.instructions.md`.
- Method: static reading only. The researcher cannot run PowerShell, `git`, or `gh`; every mechanism below is derived from the code and the recorded failure messages, and items that need a run are listed under Open Questions.

## Summary of Recommendations

1. Fix all 89 failures with fixture changes in the 17 test files, using one portable root idiom that already exists in the repository: `Join-Path ([System.IO.Path]::GetPathRoot($PSScriptRoot)) '<suite>-root'` (used today by `PoshQC.TestingOutputPath.Tests.ps1`, `PoshQC.ParallelRunner.Tests.ps1`, `PoshQC.ShardWeights.Tests.ps1`). Every expected value is built from that root with `Join-Path`, so it is a fully qualified path on an existing drive on both platforms.
2. Change 3 production files. One change is required for a test's intent to hold on Linux (`scripts/dev-tools/activate.ps1`, hardcoded `\` separator). Two are latent defects that the `<process-cwd>/C:\...` messages exposed: `[System.IO.Path]::GetFullPath` resolves relative input against the process directory instead of the PowerShell location (`scripts/dev-tools/DrmCopilotPromptSupport.ps1`, `scripts/dev-tools/HostBootstrapWorkspace.psm1`). None of the three has a bundle mirror. The total is at the direct-mode cap of 3.
3. Do not add a shared test helper. The root idiom is one expression, and the repository already uses it inline. The Discovery suites use the existing `$script:GateRunningHostEnvironment` from `tests/scripts/claude-lib/discovery-validation/DiscoveryGate.TestSupport.ps1`, so that file does not change.
4. Do not change workflow files in this item. Adding the two trees to the Linux job is one line in `_poshqc.yml`, but it also requires changes to `tests/scripts/workflows/PoshQcWorkflow.Tests.ps1`, the six byte-identical copies of the execution-environment brief, and the six copies of `atomic-plan-contract`. It also carries an unresolved JUnit-export risk on Linux. The orchestrator should record the Linux leg as an open owner decision.
5. Recommend no `-Skip`. Every Windows-specific behavior in scope can be exercised on Linux, either because it is a pure string format or because an injected seam already exists (`-IsWindowsHost`, the Discovery `Platform` value).

## 1. Failure Taxonomy per Suite

Cause classes used below:

- **C1 drive-letter fixture → `Join-Path` / provider resolution.** A `C:\...` or `C:/...` path passed to `Join-Path` (or another provider cmdlet) throws `DriveNotFoundException` on Linux because there is no `C:` PSDrive.
- **C2 drive-letter fixture → `.NET` current-directory resolution.** On Linux, `C:\fixture\ws` is not rooted. `[System.IO.Path]::GetFullPath` combines it with `[Environment]::CurrentDirectory` (the process directory), which produces `<process-cwd>/C:\fixture\ws`. On Windows the same input is rooted, so `GetFullPath` returns it unchanged.
- **C3 drive-letter fixture → Pester dynamic-parameter resolution.** A mock of a cmdlet whose parameter is provider-dynamic (`Get-Content -Raw`) binds that parameter only after the provider for the bound path resolves. With `C:` absent, the provider does not resolve and `-Raw` is reported as unknown. This mechanism is inferred from the message and the code, not observed in a debugger.
- **C4 platform-dependent rootedness.** `[System.IO.Path]::IsPathRooted('C:/x')` is `$true` on Windows and `$false` on Linux.
- **C5 real file-system write outside a mock.** Production code calls a real `New-Item` under the fixture root `/repo`. On Linux this is denied. On Windows it likely succeeds and creates `\repo\artifacts` on the current drive.
- **C6 hardcoded `\` separator in production.** Path-prefix logic uses a literal backslash, and `Split-Path` normalizes separators to `/` on Linux.
- **C7 fixture platform mismatch with a validated host shape.** The fixture declares `Platform = 'windows'` while the workspace root is the real Linux checkout.

Masked second-layer causes are noted where a C1 throw hides a later C2 or expectation mismatch. The fixture conversion removes both layers.

### tests/scripts/dev-tools/activate.Tests.ps1 (13)

| Failing tests | Class | Responsible line | Fix location |
|---|---|---|---|
| `Get-VenvAwarePrompt` ×4 (at-root light, descendant light, venv-active dark, null background) | C6 (with Windows-literal fixtures) | `scripts/dev-tools/activate.ps1` `Get-VenvAwarePrompt` derives `$venvRoot` with `Split-Path -Parent`, which on Linux returns `C:/repo/mix-calculator`. `Get-RepoRelativePrompt` then fails `Equals`/`StartsWith($VenvRoot + '\')` and renders the outside form. | Test file (portable root) **and** production. With portable Linux paths the at-root case passes, but the descendant case still renders the outside form, because `Get-RepoRelativePrompt` tests `StartsWith($VenvRoot + '\')`. |
| `Resolve-RepoRoot` ×5 | C1 | `activate.ps1` `Resolve-RepoRoot`: `Join-Path -Path $current -ChildPath '.venv'` with `C:\repo\...` | Test file |
| `Invoke-VenvActivation` ×4 | C1 (via `Resolve-RepoRoot`); second layer: the ParameterFilter regex `'\.venv\\Scripts\\Activate\.ps1$'` is backslash-only, but on Linux `Join-Path $repoRoot '.venv\Scripts\Activate.ps1'` returns forward slashes | `activate.ps1` `Invoke-VenvActivation`; test `It 'activates the venv and installs the prompt ...'` filter | Test file: portable root, and the regex becomes `'\.venv[\\/]Scripts[\\/]Activate\.ps1$'` |

The `Get-RepoRelativePrompt` pure tests (7) pass on Linux today because they never call `Split-Path`/`Join-Path`. They break once production uses the platform separator, so they must move to the portable root in the same change (see section 3).

### tests/scripts/dev-tools/Enter-DrmCopilotShell.Tests.ps1 (4)

| Failing tests | Class | Responsible line | Fix location |
|---|---|---|---|
| `Get-DrmCopilotPromptPath` nested-folder case; outside-repo case | C2 | `scripts/dev-tools/DrmCopilotPromptSupport.ps1` `Get-DrmCopilotNormalizedPath`: `[System.IO.Path]::GetFullPath($Path)` | Test file (portable root). Production fix for the latent defect: section 3. |
| `Set-DrmCopilotPrompt` renders the prompt name | C2 (same function, through the prompt closure) | as above | Test file |
| `Start-DrmCopilotPromptSession` | C1 | the test's own `-ResolveActivationScriptPath` delegate: `Join-Path -Path $VirtualEnvironmentPath -ChildPath "Scripts\Activate.ps1"` on `C:\...` | Test file. The expected path is built with the same `Join-Path` call. |

The fixtures also embed a personal user-profile path. The repository is public, so the conversion removes it. The root marker `\` and the `\scripts\dev-tools` form are intended on every platform, because production converts with `.Replace('/', '\')` and `README.md` documents the `(drm-copilot):\` prompt. Those backslash literals in expectations stay.

### tests/scripts/dev-tools/HostBootstrap.Invoke.Tests.ps1 (16)

| Failing tests | Class | Responsible line | Fix location |
|---|---|---|---|
| All 16 (dry run ×2, verify-failure propagation, RunOnce ×2, apply ×7, poetry tool install ×4) | C1 | `Describe` `BeforeEach` mocks `Get-Location -ModuleName HostBootstrapWorkspace` to `C:\fixture\ws`. `HostBootstrapWorkspace.psm1` `Sync-ProjectsFromManifest` then runs `Join-Path -Path $WorkspaceRootPath -ChildPath $targetPath`, which throws. Second layer: `-RepoRoot 'C:\fixture\repo'` passes through `Resolve-ProjectRepoRoot` `GetFullPath` (C2), so the `Push-Location` ParameterFilter and the `Installing Python project dependencies via poetry in C:\fixture\repo` expectation would fail next. | Test file. Build `$script:FixtureRoot`, `$ws`, `$repo`, the clone targets, the `Set-BootstrapResumeRunOnce` `$ResumeArguments` expectation, and the manifest path from it. |

Tests that pass today (`AC07`, `AC06-BOOTSTRAP-NOMANIFEST-THROWS`, the precondition cases, `AC06-RUNONCE-SET-APPLY-AND-RESUME`, `AC08`, `AC930-POETRY-INSTALL-FAILURE-PROPAGATES`) either throw before the join, have no projects, or receive an explicit `-WorkspaceRoot` that `GetFullPath` turns into a relative-looking string. They are converted with the rest of the file so the file uses one root.

### tests/scripts/dev-tools/HostBootstrap.Tests.ps1 (1)

| Failing test | Class | Responsible line | Fix location |
|---|---|---|---|
| `Install-PoetryWithPip` `AC11-PIP-STREAMS` | C1 | `scripts/dev-tools/HostBootstrap.psm1` `Install-PoetryWithPip`: `Join-Path -Path $appDataPath -ChildPath "Python"` with the mocked `APPDATA` value `C:\fixture\AppData` | Test file. `APPDATA` is read through the existing `Get-HostEnvironmentVariable` seam, so no environment variable is touched. |

### tests/scripts/dev-tools/HostBootstrapWorkspace.Tests.ps1 (8)

| Failing tests | Class | Responsible line | Fix location |
|---|---|---|---|
| `Resolve-WorkspaceRoot` "returns the full form of an explicit path" | C2 | `HostBootstrapWorkspace.psm1` `Resolve-WorkspaceRoot`: `[System.IO.Path]::GetFullPath($WorkspaceRootPath)` | Test file, plus the production defect fix (section 3) |
| `Sync-ProjectsFromManifest` ×4 | C1 | `Sync-ProjectsFromManifest`: `Join-Path -Path $WorkspaceRootPath -ChildPath $targetPath` | Test file |
| `Resolve-ProjectRepoRoot` explicit root | C2 | `Resolve-ProjectRepoRoot`: `GetFullPath($RepoRootPath)` | Test file, plus the production fix |
| `Resolve-ProjectRepoRoot` drm-copilot target ×2 | C1 | `Resolve-ProjectRepoRoot`: `GetFullPath((Join-Path -Path $WorkspaceRootPath -ChildPath $drmTargetPath))` | Test file |

### tests/scripts/dev-tools/HostTooling.Tests.ps1 (1)

| Failing test | Class | Responsible line | Fix location |
|---|---|---|---|
| `Read-HostToolsManifest` "returns the parsed manifest object when the file exists" | C3 | `scripts/dev-tools/HostTooling.psm1` `Read-HostToolsManifest`: `Get-Content -Path $Path -Raw` against the test's `Mock -CommandName Get-Content -ModuleName HostTooling`, with `-Path 'C:\fixture\host-tools.manifest.json'` | Test file. Use a portable root path. The mock and the production call stay. |

This is the source of "A parameter cannot be found that matches parameter name 'Raw'". It is not a Windows-only cmdlet. `-Raw` is a FileSystem-provider dynamic parameter of `Get-Content`, and the mock cannot bind it when the bound path names a drive that does not exist.

### tests/scripts/dev-tools/new-potential-entry.TemplateRoot.Tests.ps1 (2)

| Failing tests | Class | Responsible line | Fix location |
|---|---|---|---|
| Both `It` blocks | C1 | The test itself: `$bundledTemplatePath = Join-Path $templateRoot "potential/template.md"` with `$templateRoot = "C:\bundled-feature-templates"`. Production `scripts/dev-tools/new-potential-entry.ps1` makes the same join. | Test file. `$templateRoot = Join-Path ([System.IO.Path]::GetPathRoot($PSScriptRoot)) 'bundled-feature-templates'`. The `-like "*bundled-feature-templates*potential*template.md"` filter still matches. |

### tests/scripts/dev-tools/post-codex-worktree-session.Tests.ps1 (1)

| Failing test | Class | Responsible line | Fix location |
|---|---|---|---|
| `Resolve-CodexCustomizationSourceRoot` "falls back deterministically to the repository root implied by the script path" | C1 | `.codex/scripts/post-codex-worktree-session.ps1` `Resolve-CodexCustomizationSourceRoot` fallback: `[System.IO.Path]::GetFullPath((Join-Path -Path $ScriptRoot -ChildPath '../..'))` with `-ScriptRoot "C:/repo/.codex/scripts"` | Test file. Pass `-ScriptRoot` built from the portable root. Compute the expected value with the production normalizer semantics: `(Join-Path $root 'repo').Replace('\', '/').TrimEnd('/')`. |

The other `C:/repo` literals in this file are opaque strings that are never joined, and they pass. They stay unchanged, so the bundle mirror of the production script is not involved.

### tests/scripts/dev-tools/publish-sideloaded-extension.Tests.ps1 (16)

| Failing tests | Class | Responsible line | Fix location |
|---|---|---|---|
| "real orchestrator" ×2 | C1 | `scripts/dev-tools/SideloadedExtensionPublish.psm1` `Invoke-SideloadedExtensionPublish`: `Join-Path $extensionProjectRoot 'package.json'` with the mocked `Resolve-ExtensionProjectRoot` value `C:\fixture\repo\extensions\drm-copilot`; then `Join-Path $VsixOutputDir ...` | Test file |
| "parameter forwarding" ×14 | C1 | `scripts/dev-tools/publish-sideloaded-extension.ps1` param default `[string]$VsixOutputDir = (Join-Path $RepoRoot "artifacts\vsix")` evaluated with `-RepoRoot 'C:\fixture\repo'` | Test file. Build `-RepoRoot`, `$script:fixtureVsixPath`, and the `Test-Path` filter value from the portable root. |

### tests/scripts/dev-tools/SideloadedExtensionPublish.Invoke.Tests.ps1 (12)

| Failing tests | Class | Responsible line | Fix location |
|---|---|---|---|
| All 12 | C1 | `Invoke-SideloadedExtensionPublish`: `Join-Path $extensionProjectRoot 'package.json'` (line 395 in the baseline message); then `Join-Path $VsixOutputDir (...)` | Test file: `$script:publishArgs`, the `Resolve-ExtensionProjectRoot` mock value, and every ParameterFilter (`$WorkingDirectory -eq ...`), plus the expected VSIX message wildcards |

### tests/scripts/dev-tools/SideloadedExtensionPublish.Tests.ps1 (4)

| Failing tests | Class | Responsible line | Fix location |
|---|---|---|---|
| `Invoke-NpmCiWithRetry` `AC06-PUBLISH-FORCE-CLEANUP` | C1 | `Invoke-NpmCiWithRetry`: `Join-Path $WorkingDirectory 'node_modules'` | Test file. The `Remove-Item` filter `'C:/fixture/ext/node_modules'` becomes `(Join-Path $ext 'node_modules')` compared with the same normalization. |
| `Invoke-ProjectCompile` ×3 | C1 | `Invoke-ProjectCompile`: `Join-Path $ProjectRoot 'package.json'` and `'tsconfig.json'` | Test file |

The `Invoke-ExternalCommand` tests ("runs the command line through cmd.exe /c ...") exercise Windows-only production behavior through a mocked process seam. They pass on Linux and need no change.

### tests/scripts/dev-tools/sync-agents-from-instructions.Tests.ps1 (3)

| Failing tests | Class | Responsible line | Fix location |
|---|---|---|---|
| `Get-DiscoveredInstructionFile` ×2; `Get-AgentContent ordering` ×1 | C1 | `scripts/dev-tools/sync-agents-from-instructions.ps1` `Get-DiscoveredInstructionFile`: `Join-Path $RepoRootParam '.github'` with `-RepoRootParam 'C:\repo'`; `Get-AgentContent`: `Join-Path $RepoRootParam ".github/copilot-instructions.md"` | Test file. The rest of this file already uses `Join-Path -Path "/repo"`. Convert the three blocks and the `Get-AgentContent ordering` `BeforeEach` to the portable root. Build the `FullName` values with `Join-Path`, and compute `Substring` lengths from the root rather than from `'C:\repo\'.Length`. |

### tests/scripts/dev-tools/Test-DiscoveryHostCapability.Entry.Tests.ps1 (4)

| Failing tests | Class | Responsible line | Fix location |
|---|---|---|---|
| "exits 2 and writes the unsupported document when the workspace has no installed probe" | C1 | `scripts/dev-tools/Test-DiscoveryHostCapability.ps1` `Invoke-DiscoveryHostCapabilityTest`: `Join-Path $WorkspaceRoot $relative` with `$script:GateWorkspaceRoot = 'C:/Users/Example/Repos/Workspace'` from the shared support file | Test file. Pass a portable nonexistent root and mock `Test-Path` to `$false` for the probe path, so no real path is read. |
| "dot-sources the <HostName> probe ..." ×3 | C7 | Test line `$gateHostEnvironment = $script:GateHostEnvironment` (Platform `windows`) with the real Linux checkout as the workspace root. `.claude/lib/discovery-validation/DiscoveryAuthority.psm1` `ConvertTo-DiscoveryCanonicalPath` then throws `AUTHORITY_PATH_NOT_CANONICAL` because, for `windows`, only `^[A-Za-z]:[\\/]` or UNC roots are accepted. | Test file. Use `$script:GateRunningHostEnvironment`, which `DiscoveryGate.TestSupport.ps1` already defines for "a suite that runs a probe against the real repository root". The production validation is correct for its declared platform. |

### tests/scripts/dev-tools/Test-DiscoveryHostCapability.Tests.ps1 (1)

| Failing test | Class | Responsible line | Fix location |
|---|---|---|---|
| "exits 2 with an unsupported document when the host has no installed probe" | C1 | `Invoke-DiscoveryHostCapabilityTest`: `Join-Path $WorkspaceRoot $relative` with `'C:/Users/Example/Repos/NoHooks'` | Test file: portable nonexistent root, with `Mock Test-Path { $false }` scoped to the `It` |

### tests/scripts/powershell/PoshQC/PoshQC.ScanConfig.Tests.ps1 (1)

| Failing test | Class | Responsible line | Fix location |
|---|---|---|---|
| `Get-PoshQCScanConfigFolder` "throws an error naming the file for an absolute-path entry" | C4 | `scripts/powershell/PoshQC/PoshQC.ScanConfig.psm1` `Get-PoshQCScanConfigFolder`: `[IO.Path]::IsPathRooted($folderText)` with the entry `"C:/absolute/path"` | Test file. Use the entry `"/absolute/path"`, which is rooted on both platforms, so the test asserts the rule rather than a host quirk. See section 3 for the latent production inconsistency and why it is not changed here. |

### tests/scripts/powershell/PoshQC/PoshQC.ScanFolders.Tests.ps1 (1) and PoshQC.TestingCommands.Tests.ps1 (1)

| Failing tests | Class | Responsible line | Fix location |
|---|---|---|---|
| "overrides run paths and preserves configured coverage paths when scan folders are supplied"; "preserves a custom KoverageOutputPath when ScanFolders narrow Run.Path and preserve coverage paths" | C5 | `scripts/powershell/PoshQC/PoshQC.Testing.psm1` `Invoke-PoshQCTest` coverage block: `New-Item -ItemType Directory -Path $resolvedCoverageDir -Force` with `Join-Path $Root 'artifacts'` and `-Root '/repo'`. This block is inline and is not covered by the injected `-ExpandCoveragePaths` seam. | Test files. Add `Mock -CommandName New-Item -ModuleName PoshQC -MockWith { }` (the precedent is `PoshQC.TestingOutputPath.Tests.ps1`, which mocks `New-Item` inside `InModuleScope PoshQC`; `PoshQC.psm1` dot-sources `PoshQC.Testing.psm1`, so `-ModuleName PoshQC` is the right scope) and assert one invocation with the expected directory. Keep `'/repo'`: with `New-Item` mocked, it is rooted on both platforms and no further file-system call depends on it. |

On Windows these two tests likely create a real `\repo\artifacts` directory on the runner's current drive today, which violates the no-real-writes rule without failing. The mock fixes both platforms.

## 2. Portable Pattern per Cause

| Class | Pattern |
|---|---|
| C1, C2, C3 | `$script:FixtureRoot = Join-Path ([System.IO.Path]::GetPathRoot($PSScriptRoot)) '<suite>-root'`, then every fixture and expectation is `Join-Path $script:FixtureRoot ...`. On Linux the root is `/<suite>-root`; on `windows-latest` it is `<checkout drive>:\<suite>-root`. Each is fully qualified (so `GetFullPath` is the identity), lies on an existing drive (so `Join-Path` and Pester dynamic parameters resolve), and does not exist (so an accidental unmocked read finds nothing). Do not use `/repo`-style roots where `GetFullPath` or `IsPathFullyQualified` is applied, because on Windows `GetFullPath('/repo')` becomes `<drive>:\repo` and the identity expectation fails. |
| Expectations containing separators | Build them with `Join-Path` or `[System.IO.Path]::DirectorySeparatorChar` from the same root. When the production code normalizes deliberately (`.Replace('\', '/')` in `post-codex-worktree-session.ps1`, `.Replace('/', '\')` in `DrmCopilotPromptSupport.ps1`), apply the same normalization to the expected value, or keep the literal when the format is intentionally fixed. For ParameterFilters on paths, either compare against a `Join-Path` value or use the existing `($x -replace '\\', '/')` normalization on both sides. |
| C4 | Choose an input whose classification does not depend on the host: `/absolute/path` is rooted on both platforms. |
| C5 | Mock the file-system cmdlet in the module scope (`Mock New-Item -ModuleName PoshQC`) and assert the call. Do not use TestDrive: no suite in `tests/scripts/dev-tools` or `tests/scripts/powershell/PoshQC` uses `TestDrive`, `GetTempPath`, `New-TemporaryFile`, `$env:TEMP`, or `$env:TMP` (grep over both trees returned no matches), and the repository rule prohibits temporary files. |
| C6 | A production fix that uses `[System.IO.Path]::DirectorySeparatorChar`, plus tests whose expectations use the same constant. |
| C7 | Drive the injected platform seam that already exists (`$script:GateRunningHostEnvironment`) instead of asserting a host shape. |
| Windows-only behavior behind a seam | `HostBootstrap` tests already pass `-IsWindowsHost $true`. Keep that, and only make the paths portable. |
| Environment variables | None of the failures reads `USERPROFILE`, `APPDATA`, `LOCALAPPDATA`, or `ComSpec` directly. `APPDATA` in `Install-PoetryWithPip` is read through the mocked `Get-HostEnvironmentVariable` seam. |
| Case sensitivity | No failure is caused by case. `activate.ps1` compares with `OrdinalIgnoreCase` by design, and its case-insensitivity tests remain valid on Linux because the function is pure. |

## 3. Production-Code Defects

### D1 (required) - `scripts/dev-tools/activate.ps1`, `Get-RepoRelativePrompt`

- Defect: descendant detection uses `$CurrentPath.StartsWith($VenvRoot + '\', ...)`. On Linux, `(Get-Location).Path` and the `Split-Path -Parent $env:VIRTUAL_ENV` root use `/`, so a location inside the repository always renders the outside-tree form `(<name>) <absolute path>> `. The Linux failure "renders a descendant prompt from the venv parent" cannot pass with portable fixtures unless this changes.
- Minimal fix: replace the literal with `[System.IO.Path]::DirectorySeparatorChar`. On Windows the constant is `\`, so Windows behavior is unchanged byte for byte. Update the comment-based help ("leading backslash" becomes "leading directory separator").
- Test impact: the `Get-RepoRelativePrompt` pure tests (7), `Get-VenvAwarePrompt` (7), and `Resolve-RepoRoot` (5) move to the portable root. Descendant expectations become `"(mix-calculator)$([System.IO.Path]::DirectorySeparatorChar).claude> "`.
- Not changed: `Invoke-VenvActivation` joins `.venv\Scripts\Activate.ps1`, which is the Windows venv layout (POSIX venvs use `bin`). `activate.ps1` is wired only through `terminal.integrated.profiles.windows` in `.vscode/settings.json`, so the Windows layout is within its supported scope. Changing it would add a platform guard that is not needed for any failing test. The test regex is made separator-agnostic instead. Record this for the owner as a known limitation, not as a defect of this item.

### D2 (latent, recommended in scope) - `scripts/dev-tools/HostBootstrapWorkspace.psm1`, `Resolve-WorkspaceRoot` and `Resolve-ProjectRepoRoot`

- Defect: `[System.IO.Path]::GetFullPath($WorkspaceRootPath)` (in `Resolve-WorkspaceRoot`) and `GetFullPath($RepoRootPath)` / `GetFullPath((Join-Path -Path $WorkspaceRootPath -ChildPath $drmTargetPath))` (in `Resolve-ProjectRepoRoot`) resolve a relative argument against `[Environment]::CurrentDirectory`. `Set-Location` does not update that value, so `bootstrap-host.ps1 -WorkspaceRoot ws` run after a `cd` resolves to the wrong directory on every platform. The path is reachable: `bootstrap-host.ps1` forwards `-WorkspaceRoot` and `-RepoRoot` unchanged to `Invoke-BootstrapHost`, which calls both functions.
- Minimal fix: the repository's existing idiom from `PoshQC.Testing.psm1` `Invoke-PoshQCTest`, `[System.IO.Path]::GetFullPath([System.IO.Path]::Combine($PWD.ProviderPath, $Path))`. `Combine` returns the second argument unchanged when it is rooted, so absolute input is unaffected. `$PWD` is used rather than `Get-Location`, because the suites mock `Get-Location -ModuleName HostBootstrapWorkspace` with an object that has no `ProviderPath` property, and the module runs under `Set-StrictMode -Version Latest`.
- The `$PSScriptRoot`-based default (`GetFullPath((Join-Path -Path $PSScriptRoot -ChildPath "..\.."))`) is already absolute and needs no change.

### D3 (latent, recommended in scope) - `scripts/dev-tools/DrmCopilotPromptSupport.ps1`, `Get-DrmCopilotNormalizedPath` and `Resolve-DrmCopilotActivationScriptPath`

- Defect: the same API choice. `GetFullPath($Path)` in `Get-DrmCopilotNormalizedPath`, and `GetFullPath($activationScriptPath)` in `Resolve-DrmCopilotActivationScriptPath`, where the preceding `Test-Path` resolves relative to the PowerShell location but the returned path resolves relative to the process directory. The path is reachable: `Enter-DrmCopilotShell.ps1 -RepoRootPath <relative>`.
- Minimal fix: the same `Combine($PWD.ProviderPath, ...)` idiom at both call sites.

### Where the `<process-cwd>/C:\...` messages come from

`Get-DrmCopilotNormalizedPath` (Enter-DrmCopilotShell suite, 3 messages), `Resolve-WorkspaceRoot`, and `Resolve-ProjectRepoRoot` (HostBootstrapWorkspace suite, 2 messages). For the tests, the trigger is the fixture: `C:\...` is relative on Linux. The underlying API choice is a production defect whenever input is relative, and it stays invisible in CI because the runner's process directory equals its PowerShell location. Other `GetFullPath` call sites were checked and are not defective: `Enter-DrmCopilotShell.ps1` param defaults and the `post-codex-worktree-session.ps1` fallback operate on `$PSScriptRoot`-derived absolute paths, and `PoshQC.Testing.psm1`, `PoshQC.Coverage.psm1`, and `PoshQC.Parallel.psm1` already combine with `$PWD.ProviderPath`.

### Recorded and not changed - `PoshQC.ScanConfig.psm1` `Get-PoshQCScanConfigFolder`

A drive-qualified `scanFolders` entry is rejected on Windows and accepted on Linux (C4). The required `poshqc / PowerShell QC` shards run on `windows-latest` and would reject such an entry before merge, so there is no reachable CI failure. A fix would add 2 production files (`scripts/powershell/PoshQC/PoshQC.ScanConfig.psm1` and its bundle mirror `extensions/drm-copilot/resources/powershell/PoshQC/PoshQC.ScanConfig.psm1`) and exceed the direct-mode cap. Recommendation: leave it unchanged, and let the orchestrator decide whether to record it.

### Production file count

The plan touches 3 production files: `scripts/dev-tools/activate.ps1`, `scripts/dev-tools/HostBootstrapWorkspace.psm1`, and `scripts/dev-tools/DrmCopilotPromptSupport.ps1`. A glob over `extensions/drm-copilot/resources/**` found no bundle mirror for any of them; mirrors exist only for `post-codex-worktree-session.ps1`, `new-potential-entry.ps1`, `sync-agents-from-instructions.ps1`, and the PoshQC modules, none of which changes. Three files is exactly the direct-mode cap (`.claude/hooks/enforce-powershell-batch-budget.ps1` denies the fourth). If D2 and D3 are deferred, the count is 1.

## 4. Shared Helper Decision

- Option A, a shared helper (for example a `tests/scripts/powershell/Support/` function returning a portable root): one definition, but a new dot-source dependency in 17 suites, import-order coupling, a new file to review, and no reduction in logic. The idiom is a single expression.
- Option B, per-file inline root (recommended): matches three existing PoshQC suites, keeps each suite self-contained, and adds no cross-suite state. The existing shared `DiscoveryGate.TestSupport.ps1` already supplies `$script:GateRunningHostEnvironment` for the Discovery suites, so it needs no edit.
- Decision: Option B. No shared test-support file changes.

## 5. Windows Parity

- The portable root on `windows-latest` is `<checkout drive>:\<suite>-root`, a fully qualified path on a drive that exists, so `Join-Path`, `Split-Path`, `GetFullPath`, and Pester dynamic-parameter binding behave as they do with the current `C:\` literals. Expected values are built with `Join-Path`, so they carry `\` on Windows.
- D1 uses `DirectorySeparatorChar`, which is `\` on Windows, so the Windows prompt output is unchanged. D2 and D3 return the same value for absolute input on Windows, and the same value for relative input whenever the process directory equals the location, which is always true in CI.
- Windows-specific intent, and how each case is handled:
  - `activate.ps1` descendant prompt "leading backslash": platform-parameterized through `DirectorySeparatorChar`. No skip.
  - `DrmCopilotPromptSupport.ps1` `\`-form prompt: intentionally fixed on every platform; the literal stays. No skip.
  - `Get-NotDotSourcedMessage` text `. .\scripts\dev-tools\activate.ps1`: an opaque string that passes on Linux; it stays.
  - `HostBootstrap` Windows-only orchestration: already driven by the injected `-IsWindowsHost $true`. No skip.
  - `Invoke-ExternalCommand` `cmd.exe /c`: exercised through a mocked process seam and passes on Linux; it stays.
  - Discovery `windows` platform shape: the Entry suite uses the running-platform environment. The Windows-shape cases elsewhere (`tests/scripts/claude-lib/discovery-validation/`) keep their fixed `windows` fixtures, which are pure string validation.
- No `-Skip:(-not $IsWindows)` is recommended. Every behavior in scope can be exercised on Linux.

## 6. Linux CI Leg Feasibility

- Current shape: `.github/workflows/_poshqc.yml` job `poshqc-linux-hooks` (check `poshqc / PowerShell hook suites (Linux)`) sets `$config.Run.Path = @('tests/scripts/claude-hooks', 'tests/scripts/codex-hooks')` on `ubuntu-latest`, with coverage disabled and JUnit output to `artifacts/pester/pester-junit-linux-hooks.xml`. `config/poshqc-scan.json` lists `scripts`, `tests/powershell`, and `tests/scripts` for the Windows shards. Both target trees are under `tests/scripts`, so they already run on Windows.
- Minimal edit: add `'tests/scripts/dev-tools'` and `'tests/scripts/powershell/PoshQC'` to that one `Run.Path` line. The job name would then misdescribe the job. Renaming it changes a check context, which is not required by ruleset 15241672, so a rename would not break branch protection, but the brief's Refresh rule then applies.
- Required companion edits:
  - `tests/scripts/workflows/PoshQcWorkflow.Tests.ps1` "limits the poshqc-linux-hooks Run.Path to the two hook-suite folders" asserts exactly `tests/scripts/claude-hooks,tests/scripts/codex-hooks`.
  - The execution-environment brief in six byte-identical copies (`.claude/`, `.agents/`, `.github/skills/execution-environment/SKILL.md`, and three under `extensions/drm-copilot/resources/`), in `## CI Shape and Required Checks` and `## CI-Only Failure Classes`. `tests/scripts/dev_tools/test_execution_environment_brief_contracts.py` pins the job name text.
  - `atomic-plan-contract/SKILL.md`, whose rule "A Pester acceptance criterion may cite `ubuntu-latest` only for suites under `tests/scripts/claude-hooks` or `tests/scripts/codex-hooks`" exists in six copies (`.claude`, `.agents`, `.github`, and three bundle copies).
  - The mirror contract tests listed in the brief.
- Risks that cannot be resolved by reading:
  - The baseline records that Pester 5.9.1 throws during JUnit result export on the Codespace host after this run. The Linux job exports JUnit, so the same throw on `ubuntu-latest` would fail the job, and the cause is not identified.
  - Linux runtime for the 921 tests in the two trees is unrecorded.
  - The baseline was taken on a Codespace with developer tools installed. Suites that pass there have not been run on a bare `ubuntu-latest` image.
- Required contexts: no change. A new or widened job is not in ruleset 15241672 unless added there; the orchestrator should re-confirm with a read-only `gh api repos/drmoisan/drm-copilot/rulesets/15241672` call if a job is added later.
- Recommendation: defer. The edit is not required for the acceptance condition (Linux suites pass, Windows shards pass). It is not small in total (one workflow line, but about 14 companion files across six-copy mirrors and contract tests), and it carries an unresolved export risk. Without a Linux leg, a new Windows-only fixture can reappear unnoticed. Record that as an owner decision rather than resolving it implicitly in this item.

## 7. Exclusion

`tests/scripts/dev-tools/run-actionlint.Tests.ps1` is out of scope. Its `$env:PATH` leak in "Add-DirectoryToPath handles paths with trailing separator" is fixed by sibling issue #1066, which merges first. The baseline records no Linux failure in that file, and this research proposes no change to it.

## 8. Test-Isolation Risks

- `sync-agents-from-instructions.Tests.ps1` sets `$env:POSHQC_SKIP_SCRIPT_EXECUTION = '1'` in `BeforeAll` and never restores it. In a single-process or shuffled run it leaks into every later suite. Recommend saving the prior value and restoring it in `AfterAll`. `link-feature-docs.Tests.ps1` and `link-parent-child.Tests.ps1` set the same variable, so confirm that they set it themselves rather than relying on the leak.
- `Enter-DrmCopilotShell.Tests.ps1` dot-sources `DrmCopilotPromptSupport.ps1`, whose functions are declared `function global:`, so they persist after the suite. `Set-DrmCopilotPrompt` writes `Function:\global:prompt`. The suite's `AfterEach` assigns `$function:prompt = $script:originalPrompt` in its own scope, which likely does not restore the global prompt. Recommend restoring through `Set-Item -Path Function:\global:prompt` and removing the `global:` functions in `AfterAll`.
- `Test-DiscoveryHostCapability.Entry.Tests.ps1` runs the script, which ends in `exit 1` or `exit 2`, so `$global:LASTEXITCODE` is left non-zero after the suite. It also imports the Discovery modules and dot-sources `.github/hooks/discovery-pre-tool.ps1` without cleanup. Recommend resetting `$global:LASTEXITCODE` in `AfterEach`. The module imports are pre-existing and shared with the claude-lib suites; leave them.
- The new D2 and D3 regression tests must change two pieces of process-wide state: `Push-Location $PSScriptRoot` and `[Environment]::CurrentDirectory = [System.IO.Path]::GetPathRoot($PSScriptRoot)`. That combination makes the location and the process directory differ deterministically. Both must be restored in `finally`.
- `activate.Tests.ps1` defines the extracted functions with `Set-Item Function:\` in the file scope, and saves and restores `prompt`, `VIRTUAL_ENV`, and `VIRTUAL_ENV_DISABLE_PROMPT`. No new risk.
- The HostBootstrap, HostTooling, and SideloadedExtensionPublish suites remove their modules in `AfterAll`. The PoshQC suites re-import `PoshQC` with `-Force`, and the module keeps a process-lifetime AppDomain parse cache by design. No new risk.
- Per the brief's `## Test Isolation Checks`: record a seeded shuffled file-order run of the 17 touched suites in one process (three or more seeds, with each order recorded), a fresh single-process run over `tests/scripts`, and a concurrent-shard `Invoke-PoshQCParallelTest` run.

## 9. Language Constraint

All changes are PowerShell, and no helper is added. No Python is introduced.

## 10. File Inventory

| Category | Count | Files |
|---|---|---|
| Test files | 17 | `tests/scripts/dev-tools/activate.Tests.ps1`, `Enter-DrmCopilotShell.Tests.ps1`, `HostBootstrap.Invoke.Tests.ps1`, `HostBootstrap.Tests.ps1`, `HostBootstrapWorkspace.Tests.ps1`, `HostTooling.Tests.ps1`, `new-potential-entry.TemplateRoot.Tests.ps1`, `post-codex-worktree-session.Tests.ps1`, `publish-sideloaded-extension.Tests.ps1`, `SideloadedExtensionPublish.Invoke.Tests.ps1`, `SideloadedExtensionPublish.Tests.ps1`, `sync-agents-from-instructions.Tests.ps1`, `Test-DiscoveryHostCapability.Entry.Tests.ps1`, `Test-DiscoveryHostCapability.Tests.ps1`; `tests/scripts/powershell/PoshQC/PoshQC.ScanConfig.Tests.ps1`, `PoshQC.ScanFolders.Tests.ps1`, `PoshQC.TestingCommands.Tests.ps1`. The D2 and D3 regression tests go into `HostBootstrapWorkspace.Tests.ps1` and `Enter-DrmCopilotShell.Tests.ps1`, which are already counted. |
| Shared test support | 0 | `DiscoveryGate.TestSupport.ps1` is used unchanged |
| Production | 3 | `scripts/dev-tools/activate.ps1`, `scripts/dev-tools/HostBootstrapWorkspace.psm1`, `scripts/dev-tools/DrmCopilotPromptSupport.ps1` |
| Bundle mirrors | 0 | none exist for the three production files |
| Workflow files | 0 | Linux leg deferred |
| Documentation mirrors | 0 | No CI, tool-route, or budget fact changes, so the brief and `atomic-plan-contract` stay unchanged |

File size: the largest touched test file is `activate.Tests.ps1` at 418 lines. The additions are small, and no file approaches the 700-line advisory tier.

## 11. Open Questions and Unconfirmed Facts

1. `spec.md` states "89 failures of 308 tests" and "308 tests, 219 passed". The baseline records 921 tests, 823 passed, 89 failed, and 9 skipped. The failure count agrees; the totals do not, and appear to come from the issue 1026 run scope. The spec should cite the baseline totals.
2. The C3 mechanism (Pester dynamic-parameter binding for `Get-Content -Raw`) is inferred. Confirm by running `HostTooling.Tests.ps1` with the portable root.
3. Whether the Pester 5.9.1 JUnit-export throw reproduces on `ubuntu-latest` is unknown. It is the main blocker for a future Linux leg.
4. Linux wall-clock time for the two trees is unrecorded.
5. That `PoshQC.ScanFolders.Tests.ps1` and `PoshQC.TestingCommands.Tests.ps1` create `\repo\artifacts` on Windows runners today is inferred from the code path, not observed.
6. That `$function:prompt = ...` in the `Enter-DrmCopilotShell.Tests.ps1` `AfterEach` does not restore the global prompt is likely but unverified.
7. Whether sibling #1066 has merged to `main`: orchestrator to confirm with `git`.
8. The 9 skipped tests in the baseline were not attributed to files. The baseline lists failures only.

## Rejected Alternatives

- `/repo`-style roots (the approach of commit df7cb4f31): portable only while every file-system call is mocked and no `GetFullPath` identity is asserted. They cause the C5 write failure on Linux and a silent real write on Windows.
- `-Skip:(-not $IsWindows)` on the failing tests: hides 89 tests on Linux, and every behavior in scope can be exercised there.
- TestDrive-backed real directories: prohibited by the no-temporary-files rule. No suite in either tree uses TestDrive.
- Fixing `activate.ps1` by testing for both `\` and `/` on every platform: it would keep the Windows-literal pure tests passing on Linux, but it treats `\` as a separator on POSIX, where it is a legal file-name character.

## Numeric Derivation Evidence

### Claim N1: 89 failing tests across 17 suites

- Complete Family: every failing Pester test in the baseline single-process run over `tests/scripts/dev-tools` and `tests/scripts/powershell/PoshQC`.
- Exhaustive Search Scope: the whole `## Per-test failures` block of `evidence/baseline/linux-pester-baseline.2026-11-03T22-49.md`.
- Inclusion Rules: a `TEST` line under a `FILE` header; a `FILE` header with `failures=<n>`.
- Exclusion Rules: the `TOTAL` line and `MSG` lines.
- Primary Search Strategy or Query Expression: read each `FILE ... failures=<n>` header and sum `n`.
- Primary Member Set: activate 13, Enter-DrmCopilotShell 4, HostBootstrap.Invoke 16, HostBootstrap 1, HostBootstrapWorkspace 8, HostTooling 1, new-potential-entry.TemplateRoot 2, post-codex-worktree-session 1, publish-sideloaded-extension 16, SideloadedExtensionPublish.Invoke 12, SideloadedExtensionPublish 4, sync-agents-from-instructions 3, Test-DiscoveryHostCapability.Entry 4, Test-DiscoveryHostCapability 1, PoshQC.ScanConfig 1, PoshQC.ScanFolders 1, PoshQC.TestingCommands 1.
- Primary Count: 17 files; 89 failures.
- Cross-check Search Strategy or Query Expression: count the `TEST` lines under each `FILE` header independently of the header value, and compare with `Failed=89` on the `TOTAL` line.
- Cross-check Member Set: TEST-line counts per file 13, 4, 16, 1, 8, 1, 2, 1, 16, 12, 4, 3, 4, 1, 1, 1, 1 in the same file order; `TOTAL ... Failed=89`.
- Cross-check Count: 17 files; 89 TEST lines; TOTAL 89.
- Member-set Comparison: the per-file sets are identical in file names and per-file counts; both sums equal 89 and match the TOTAL line. Both records come from one artifact, so the evidence is internally consistent, but it has no second source. A plan acceptance criterion should be re-derived from the post-change run rather than from this baseline.

### Claim N2: 3 production files

- Complete Family: non-test PowerShell files that this research proposes to edit, including bundle mirrors.
- Exhaustive Search Scope: section 3 defects D1 to D3 and the recorded-but-unchanged item; the `extensions/drm-copilot/resources/**` tree for mirrors.
- Inclusion Rules: a file with a proposed edit.
- Exclusion Rules: files recorded but not changed (`PoshQC.ScanConfig.psm1` and its mirror).
- Primary Search Strategy or Query Expression: enumerate defect entries D1, D2, and D3 and their files.
- Primary Member Set: `scripts/dev-tools/activate.ps1`, `scripts/dev-tools/HostBootstrapWorkspace.psm1`, `scripts/dev-tools/DrmCopilotPromptSupport.ps1`.
- Primary Count: 3.
- Cross-check Search Strategy or Query Expression: a glob under `extensions/drm-copilot/resources/**` for each of the three file names, plus a grep of the file names across that tree.
- Cross-check Member Set: no mirror of any of the three; mirrors found only for `post-codex-worktree-session.ps1`, `new-potential-entry.ps1`, `sync-agents-from-instructions.ps1`, and the PoshQC modules, none of which is edited.
- Cross-check Count: 3 + 0 mirrors = 3.
- Member-set Comparison: identical sets; count 3.

## Pre-Mortem

- Review checklists: a reviewer could flag weakened assertions if expectations are rewritten generically (for example, replacing an exact path with a wildcard). Mitigation: every converted expectation stays exact and is built from the same `Join-Path` root, and every `Should -Invoke` keeps `-Times`/`-Exactly` and its ParameterFilter.
- Coverage: the three production edits need changed-line coverage at the 85% per-file line threshold on the Windows shards. D1 is covered by the descendant prompt tests. D2 and D3 need the new regression tests, which separate the location from the process directory. Mitigation: the plan names those tests, and the executor reads per-file coverage from `artifacts/pester/powershell-coverage.xml`, not from the MCP summary.
- Mirror parity: not applicable for production, because none of the three production files has a bundle mirror and no brief, skill, or workflow fact changes. If the owner later adds the Linux leg, the six-copy execution-environment brief and the six-copy `atomic-plan-contract` must change in the same change.
- File size: not applicable in practice. The largest touched file is `activate.Tests.ps1` at 418 lines, the additions are small, and no file approaches 700 lines.
- Test isolation: the D2 and D3 regression tests change the process directory and the location, and a missed restore would corrupt every later suite in a single-process run. Mitigation: `try`/`finally` restores both. Also restore `POSHQC_SKIP_SCRIPT_EXECUTION`, the global prompt, and `$global:LASTEXITCODE` (section 8), then run the three-seed shuffled single-process run and a concurrent-shard run.
- CI-only behavior: Windows CI hides C2 because the runner's process directory equals its location, and it hides C5 because `\repo` is writable. Mitigation: record the Linux single-process run over both trees as the fail-before/pass-after evidence, and rely on the Windows shards (`poshqc / PowerShell QC`) for Windows parity. No Pester acceptance criterion may cite `ubuntu-latest` for these trees, because the Linux job does not run them.
- Evidence: the baseline counts come from a PassThru object because JUnit export threw on this host, and PoshQC MCP results carry no counts. Mitigation: post-change Linux evidence uses the same PassThru grouping script under `<FEATURE>/evidence/regression-testing/` with `Timestamp`, `Command`, `EXIT_CODE`, and `Output Summary`. Windows evidence comes from the CI shard JUnit artifacts, and no artifact records absolute paths.
