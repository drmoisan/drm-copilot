# pester-fixtures-platform-independent (Spec)

- **Issue:** #1067
- **Parent (optional):** none
- **Owner:** drmoisan
- **Last Updated:** 2026-11-03T23-30
- **Status:** Draft
- **Version:** 0.2
- **Work Mode:** full-bug
- **Branch:** bug/pester-fixtures-platform-independent

## Context
Seventeen Pester suites under `tests/scripts/dev-tools` and `tests/scripts/powershell/PoshQC` use Windows-specific fixtures and fail on Linux. The Linux baseline (`evidence/baseline/linux-pester-baseline.2026-11-03T22-49.md`) records 921 tests across the two trees: 823 passed, 89 failed, 9 skipped. All 89 failures are in 17 suites; every other suite in both trees passes. The figures "308 tests, 219 passed, 89 failed" that the issue cites are the 17-suite subset from the issue 1026 run, not the totals for the two trees.

Post-merge re-verification: after `main` (including sibling issue #1066, PR #1070) was merged into this branch, the same run (`evidence/baseline/linux-pester-baseline.2026-11-04T03-19.md`) records 925 tests: 827 passed, 89 failed, 9 skipped. The four added tests are the new `tests/scripts/dev-tools/run-actionlint.EnvironmentIsolation.Tests.ps1`, which passes. The 89 failures are in the same 17 suites with the same per-suite counts, and `tests/scripts/dev-tools/run-actionlint.Tests.ps1` still has no failure, so the scope below is unchanged.

The fixtures must be platform independent so that the suites pass on Windows and Linux. Reading the failures also exposed four production defects (D1 to D4 below) that are fixed in this item.

Environment:
- OS/version: Linux Codespace (PowerShell 7.6, Pester 5.9.1). CI runs these suites on `windows-latest` only.
- Python version: not applicable.
- Command/flags used: Invoke-Pester over `tests/scripts/dev-tools` and `tests/scripts/powershell/PoshQC`, single process, coverage disabled, JUnit export disabled (Pester 5.9.1 throws during JUnit export on the Codespace host), counts taken from the PassThru result.
- Data source or fixture: hardcoded `C:\` and `C:/` paths, backslash path expectations, real writes under `/repo`, a fixed `windows` platform shape against the real Linux checkout, and an embedded personal user-profile path.

Impact / Severity:
- [ ] Blocker
- [ ] High
- [x] Medium
- [ ] Low


## Repro & Evidence
Steps to Reproduce:
1. On a Linux host, run Invoke-Pester over `tests/scripts/dev-tools` and `tests/scripts/powershell/PoshQC` in one process with coverage disabled.
2. Observe 921 tests: 823 passed, 89 failed, 9 skipped. All 89 failures are in the 17 suites listed under Scope.
3. Run only the 17 failing suites: 308 tests, 219 passed, 89 failed (the subset recorded by the issue 1026 run). The failure distribution is identical at the merge base of the issue 1026 branch.

Expected:
The suites pass on Linux and Windows without host-specific fixtures, make no real file-system writes outside mocks, and create no temporary files.

Actual:
Representative errors: `DriveNotFoundException: Cannot find drive. A drive with the name 'C' does not exist.`; `Expected: 'C:\fixture\ws'` with `But was: '<process-cwd>/C:\fixture\ws'`; `UnauthorizedAccessException: Access to the path '/repo' is denied.`; `A parameter cannot be found that matches parameter name 'Raw'.`; `AUTHORITY_PATH_NOT_CANONICAL: Workspace root must be an absolute path`; and, for the scan-configuration rule, `Expected an exception ... but no exception was thrown.`

Logs / Screenshots:
- [x] Attached minimal logs or screenshot
- Snippet: `evidence/baseline/linux-pester-baseline.2026-11-03T22-49.md` lists every failing test with its message, grouped by file. The research record `research/research.2026-11-03T22-55.md` section 1 maps each failure to a cause class and a responsible symbol.


## Scope & Non-Goals
- In scope:
  - Fixture changes in the 17 failing suites:
    - `tests/scripts/dev-tools/activate.Tests.ps1`
    - `tests/scripts/dev-tools/Enter-DrmCopilotShell.Tests.ps1`
    - `tests/scripts/dev-tools/HostBootstrap.Invoke.Tests.ps1`
    - `tests/scripts/dev-tools/HostBootstrap.Tests.ps1`
    - `tests/scripts/dev-tools/HostBootstrapWorkspace.Tests.ps1`
    - `tests/scripts/dev-tools/HostTooling.Tests.ps1`
    - `tests/scripts/dev-tools/new-potential-entry.TemplateRoot.Tests.ps1`
    - `tests/scripts/dev-tools/post-codex-worktree-session.Tests.ps1`
    - `tests/scripts/dev-tools/publish-sideloaded-extension.Tests.ps1`
    - `tests/scripts/dev-tools/SideloadedExtensionPublish.Invoke.Tests.ps1`
    - `tests/scripts/dev-tools/SideloadedExtensionPublish.Tests.ps1`
    - `tests/scripts/dev-tools/sync-agents-from-instructions.Tests.ps1`
    - `tests/scripts/dev-tools/Test-DiscoveryHostCapability.Entry.Tests.ps1`
    - `tests/scripts/dev-tools/Test-DiscoveryHostCapability.Tests.ps1`
    - `tests/scripts/powershell/PoshQC/PoshQC.ScanConfig.Tests.ps1`
    - `tests/scripts/powershell/PoshQC/PoshQC.ScanFolders.Tests.ps1`
    - `tests/scripts/powershell/PoshQC/PoshQC.TestingCommands.Tests.ps1`
  - Production fixes D1 to D4 (see Proposed Fix), with regression tests for each.
  - Test-isolation fixes in three of the touched suites (`sync-agents-from-instructions.Tests.ps1`, `Enter-DrmCopilotShell.Tests.ps1`, `Test-DiscoveryHostCapability.Entry.Tests.ps1`).
  - Removal of the personal user-profile path embedded in `Enter-DrmCopilotShell.Tests.ps1`.
- Out of scope / non-goals:
  - `tests/scripts/dev-tools/run-actionlint.Tests.ps1`. Sibling issue #1066 fixes its `$env:PATH` leak and merges to `main` first. This item merges `main` before planning and edits that file only if host-fixture failures appear there after the merge; the baseline records none, and the post-merge baseline confirms none after #1066 merged.
  - A shared test helper or any change to shared test support. `tests/scripts/claude-lib/discovery-validation/DiscoveryGate.TestSupport.ps1` is used unchanged.
  - `-Skip` conditions, TestDrive, and temporary files.
  - The POSIX venv layout in `activate.ps1` `Invoke-VenvActivation` (it joins `.venv\Scripts\Activate.ps1`, the Windows layout; the script is wired only through the Windows terminal profile). This is recorded as a known limitation, not a defect of this item.
- Explicitly excluded systems, integrations, or datasets:
  - Workflow files, including `.github/workflows/_poshqc.yml`. Adding these two trees to the `ubuntu-latest` PowerShell leg is deferred and recorded as an open owner decision (see Rollout & Follow-up).
  - The execution-environment brief and `atomic-plan-contract` mirrors, and `tests/scripts/workflows/PoshQcWorkflow.Tests.ps1`. No fact they state changes in this item.

## Root Cause Analysis
The fixtures were written for a Windows host. On Linux they fail through seven mechanisms (research section 1):

- C1: a `C:\...` or `C:/...` path passed to `Join-Path` or another provider cmdlet throws `DriveNotFoundException`, because no `C:` PSDrive exists.
- C2: on Linux `C:\fixture\ws` is not rooted, so `[System.IO.Path]::GetFullPath` combines it with `[Environment]::CurrentDirectory` and returns `<process-cwd>/C:\fixture\ws`.
- C3: a Pester mock of `Get-Content -Raw` cannot bind the FileSystem dynamic parameter `-Raw` when the bound path names a drive that does not exist (inferred from the message and code; to be confirmed by the post-change run).
- C4: `[IO.Path]::IsPathRooted('C:/x')` is `$true` on Windows and `$false` on Linux.
- C5: `PoshQC.Testing.psm1` `Invoke-PoshQCTest` calls a real `New-Item` under the fixture root `/repo`. Linux denies it; on Windows the call likely creates `\repo\artifacts` on the runner's current drive (inferred, not observed).
- C6: `activate.ps1` `Get-RepoRelativePrompt` tests descendants with a literal `\` separator.
- C7: `Test-DiscoveryHostCapability.Entry.Tests.ps1` declares `Platform = 'windows'` while the workspace root is the real Linux checkout.

Four production defects sit behind these mechanisms:

- D1 (C6): `Get-RepoRelativePrompt` renders the outside-tree prompt for every location inside the repository on a host whose separator is `/`.
- D2 (C2): `HostBootstrapWorkspace.psm1` `Resolve-WorkspaceRoot` and `Resolve-ProjectRepoRoot` resolve relative input against the process directory instead of the PowerShell location. `Set-Location` does not update the process directory, so `bootstrap-host.ps1 -WorkspaceRoot <relative>` after a location change resolves to the wrong directory on every platform. CI does not show this because the runner's process directory equals its location.
- D3 (C2): `DrmCopilotPromptSupport.ps1` `Get-DrmCopilotNormalizedPath` and `Resolve-DrmCopilotActivationScriptPath` have the same defect. In `Resolve-DrmCopilotActivationScriptPath` the preceding `Test-Path` resolves against the location while the returned path resolves against the process directory.
- D4 (C4): `PoshQC.ScanConfig.psm1` `Get-PoshQCScanConfigFolder` rejects absolute `test.scanFolders` entries through `[IO.Path]::IsPathRooted`, so a drive-qualified entry is rejected on Windows and accepted on Linux. The validation rule depends on the host.

Precedent: commit df7cb4f31 (2026-03-11) normalized other suites with Join-Path, `[IO.Path]::DirectorySeparatorChar`, mocks in place of real file-system access, and no temporary files. Its `/repo`-style roots are portable only while every file-system call is mocked and no `GetFullPath` identity is asserted, which is why this item uses a drive-rooted portable root instead.


## Proposed Fix

### Design summary (what changes where):
- Each of the 17 suites defines its own portable root with the expression `Join-Path ([System.IO.Path]::GetPathRoot($PSScriptRoot)) '<suite>-root'`, already used inline by `PoshQC.TestingOutputPath.Tests.ps1`, `PoshQC.ParallelRunner.Tests.ps1`, and `PoshQC.ShardWeights.Tests.ps1`. Every fixture path and every expected value is built from that root with `Join-Path`. On Linux the root is `/<suite>-root`; on `windows-latest` it is `<checkout drive>:\<suite>-root`. The root is fully qualified, lies on an existing drive, and does not exist.
- Real file-system writes are replaced by mocks. In `PoshQC.ScanFolders.Tests.ps1` and `PoshQC.TestingCommands.Tests.ps1`, `New-Item` is mocked in the `PoshQC` module scope and the call is asserted with the expected directory.
- Four production fixes (D1 to D4) remove the host dependence in production code.
- Three test-isolation fixes restore process-wide state that the touched suites leave behind.

### Boundaries and invariants to preserve:
- Windows behavior is unchanged: the D1 prompt output is byte-identical on Windows; D2 and D3 return the same value for absolute input, and for relative input whenever the process directory equals the location; D4 still rejects every entry that Windows rejects today.
- Every converted expectation stays exact. No assertion is replaced by a wildcard or weakened, and every `Should -Invoke` keeps its `-Times`/`-Exactly` and ParameterFilter.
- Intentionally fixed formats keep their literals: the `\`-form prompt produced by `DrmCopilotPromptSupport.ps1` (`(drm-copilot):\...`), the `Get-NotDotSourcedMessage` text, and the `cmd.exe /c` behavior exercised through the mocked process seam in `SideloadedExtensionPublish.Tests.ps1`.
- Windows-only orchestration stays driven by existing seams (`-IsWindowsHost $true` in the HostBootstrap suites; `$script:GateRunningHostEnvironment` in the Discovery entry suite).
- No suite uses `-Skip`, TestDrive, `GetTempPath`, `New-TemporaryFile`, `$env:TEMP`, or `$env:TMP`.
- The `scanFolders` validation error message keeps the configuration file name and the word "absolute", so the existing `*config/poshqc-scan.json*absolute*` expectation remains valid.

### Dependencies or blocked work:
- Sibling issue #1066 merges to `main` first. This branch merges `main` before planning.
- The change touches five production PowerShell files (four sources and one bundle mirror), which exceeds the direct-mode cap in `.claude/rules/powershell.md` `## Change Budget`; the work runs on the orchestrated large path.

### Implementation strategy (what changes, not sequencing):

#### Files/modules to change:
- Production:
  - `scripts/dev-tools/activate.ps1` (D1)
  - `scripts/dev-tools/HostBootstrapWorkspace.psm1` (D2)
  - `scripts/dev-tools/DrmCopilotPromptSupport.ps1` (D3)
  - `scripts/powershell/PoshQC/PoshQC.ScanConfig.psm1` (D4)
  - `extensions/drm-copilot/resources/powershell/PoshQC/PoshQC.ScanConfig.psm1` (D4 bundle mirror, byte-identical to the source; path confirmed present)
- Tests: the 17 suites listed under Scope. The D1 to D4 regression tests are added to `activate.Tests.ps1`, `HostBootstrapWorkspace.Tests.ps1`, `Enter-DrmCopilotShell.Tests.ps1`, and `PoshQC.ScanConfig.Tests.ps1`.
- No shared test-support file, workflow file, brief, or skill changes.

#### Functions/classes/CLI commands impacted:
- D1: `Get-RepoRelativePrompt` replaces the literal `'\'` in its descendant test (`StartsWith($VenvRoot + '\', ...)`) with `[System.IO.Path]::DirectorySeparatorChar`. The comment-based help changes "leading backslash" to "leading directory separator". On Windows the constant is `\`, so output is byte-identical.
- D2: `Resolve-WorkspaceRoot` and `Resolve-ProjectRepoRoot` resolve relative input with the existing repository idiom `[System.IO.Path]::GetFullPath([System.IO.Path]::Combine($PWD.ProviderPath, $Path))`, at each `GetFullPath` call site that receives caller input (the explicit workspace root, the explicit repo root, and the joined drm-copilot target path). `Combine` returns a rooted second argument unchanged, so absolute input is unaffected. `$PWD` is used rather than `Get-Location` because the suites mock `Get-Location -ModuleName HostBootstrapWorkspace` with an object that has no `ProviderPath`, and the module runs under `Set-StrictMode -Version Latest`. The `$PSScriptRoot`-based default is already absolute and does not change.
- D3: `Get-DrmCopilotNormalizedPath` and `Resolve-DrmCopilotActivationScriptPath` use the same idiom at their `GetFullPath` call sites.
- D4: `Get-PoshQCScanConfigFolder` rejects an entry when it is drive-qualified (matches `^[A-Za-z]:`) or rooted (begins with `/` or `\`), on every host, in place of the `[IO.Path]::IsPathRooted($folderText)` check. The resolution of `ConfigRelativePath` itself is unchanged.
- Isolation fixes:
  - `sync-agents-from-instructions.Tests.ps1`: save the prior `$env:POSHQC_SKIP_SCRIPT_EXECUTION` value in `BeforeAll` and restore it (or remove the variable when it was absent) in `AfterAll`.
  - `Enter-DrmCopilotShell.Tests.ps1`: restore the global prompt through `Function:\global:prompt` and remove the `global:` functions defined by `DrmCopilotPromptSupport.ps1` in `AfterAll`.
  - `Test-DiscoveryHostCapability.Entry.Tests.ps1`: reset `$global:LASTEXITCODE` in `AfterEach`.

#### Data flow and validation changes:
- Per-suite fixture conversions (research sections 1 and 2):
  - `activate.Tests.ps1`: the `Get-RepoRelativePrompt (pure logic)`, `Get-VenvAwarePrompt (prompt decision used by the shim)`, and `Resolve-RepoRoot (depth-robust ancestor walk)` blocks move to the portable root; descendant expectations use `[System.IO.Path]::DirectorySeparatorChar`; the `Invoke-VenvActivation` ParameterFilter regex becomes separator-agnostic (`'\.venv[\\/]Scripts[\\/]Activate\.ps1$'`).
  - `Enter-DrmCopilotShell.Tests.ps1`: repository, nested-folder, outside-repo, and virtual-environment paths come from the portable root; the personal user-profile path is removed; the expected activation path is built with the same `Join-Path` call as the delegate.
  - HostBootstrap, HostTooling, SideloadedExtensionPublish, and publish-sideloaded-extension suites: every `C:\fixture\...` value, mocked return value, ParameterFilter comparison, and expected message is built from the portable root.
  - `new-potential-entry.TemplateRoot.Tests.ps1`: the template root is `Join-Path ([System.IO.Path]::GetPathRoot($PSScriptRoot)) 'bundled-feature-templates'`.
  - `post-codex-worktree-session.Tests.ps1`: `-ScriptRoot` is built from the portable root and the expected value applies the production normalization (`.Replace('\', '/')` and trailing-separator trim). Opaque `C:/repo` strings that are never joined stay.
  - `sync-agents-from-instructions.Tests.ps1`: `FullName` values are built with `Join-Path`, and `Substring` lengths are computed from the root.
  - `Test-DiscoveryHostCapability.Entry.Tests.ps1` and `Test-DiscoveryHostCapability.Tests.ps1`: the no-probe cases use a portable nonexistent root with `Test-Path` mocked to `$false`; the probe cases use `$script:GateRunningHostEnvironment`.
  - `PoshQC.ScanConfig.Tests.ps1`: keeps the `C:/absolute/path` case (now host-independent) and adds a `/absolute/path` case and a `\absolute\path` case.
  - `PoshQC.ScanFolders.Tests.ps1` and `PoshQC.TestingCommands.Tests.ps1`: mock `New-Item -ModuleName PoshQC` and assert one invocation with the expected coverage directory.

#### Error handling and logging updates:
- No new error paths. D4 throws the existing workspace-relative-path error for the newly host-independent cases; the message text is unchanged.

#### Rollback/feature-flag considerations (if applicable):
- No feature flag. Each production fix is a small, independent edit that can be reverted with its regression tests.

### Technical specifications (interfaces/contracts):

#### Inputs/outputs and formats:
- D1: for a location below the venv root, `Get-RepoRelativePrompt` returns `(<name>)<DirectorySeparatorChar><relative path>> `; on Windows this is the current `(<name>)\<relative path>> ` form.
- D2, D3: for relative input, the returned path is the input resolved against the PowerShell location; for absolute input, the returned path is unchanged.
- D4: a `test.scanFolders` entry that is drive-qualified or begins with `/` or `\` raises the existing error on every host. Workspace-relative entries are accepted as before.

#### Required configuration keys and defaults:
- None. `config/poshqc-scan.json` is unchanged.

#### Backward-compatibility expectations:
- No public parameter or output type changes. Windows output is unchanged for all current inputs. On Linux, D4 now rejects a drive-qualified or backslash-rooted `scanFolders` entry that was previously accepted; `config/poshqc-scan.json` contains no such entry.

#### Performance constraints (latency/throughput/memory):
- None beyond the existing suite runtime. The fixtures add no file-system access.

## Assumptions, Constraints, Dependencies
- Assumptions (environment, data, access):
  - `$PWD.ProviderPath` is a FileSystem path when D2 and D3 run, as it already is for the same idiom in `PoshQC.Testing.psm1`, `PoshQC.Coverage.psm1`, and `PoshQC.Parallel.psm1`.
  - The four changed source files are measured in `artifacts/pester/powershell-coverage.xml` by the self-hosted PoshQC coverage run; the executor confirms this before relying on the figure.
  - The 9 skipped tests in the baseline are not attributed to files and are not changed by this item.
- Constraints (budget, performance, compatibility):
  - PowerShell 7+ only; no new Python and no new helper modules.
  - Orchestrated large path (five production PowerShell files).
  - No temporary files, TestDrive, or `-Skip`.
- External dependencies (services, libraries, releases):
  - Pester 5.9.x and PSScriptAnalyzer through the self-hosted PoshQC module.
  - Sibling issue #1066 merged to `main` before planning.

## Data / API / Config Impact
- User-facing or API changes: the `activate.ps1` prompt renders the repo-relative form on non-Windows hosts; `bootstrap-host.ps1 -WorkspaceRoot`/`-RepoRoot` and `Enter-DrmCopilotShell.ps1 -RepoRootPath` resolve relative arguments against the PowerShell location; `Get-PoshQCScanConfigFolder` applies one rejection rule on every host.
- Data or migration considerations: none.
- Logging/telemetry updates (if any): none.
- Compatibility notes (CLI flags, config schemas, versioning): no flag or schema change. The PoshQC bundle mirror stays byte-identical to its source.

## Test Strategy
Seeded from issue:

- [x] Unit coverage areas: apply the portable fixture pattern to each of the 17 suites with a per-file root expression (no shared helper).
- [x] Integration scenario to retest: single-process Invoke-Pester over the 17 suites on Linux shows 0 failures; the Windows CI shards pass; the suites become eligible for the `ubuntu-latest` PowerShell leg (the leg itself is an open owner decision).
- [ ] Manual verification notes

- Regression tests to add or update (Pester):
  - D1, `tests/scripts/dev-tools/activate.Tests.ps1`: `Describe 'Get-VenvAwarePrompt (prompt decision used by the shim)'` / `It 'renders a descendant prompt from the venv parent (light background)'` (converted to the portable root), and a new `It` under `Describe 'Get-RepoRelativePrompt (pure logic)'` that asserts the descendant form with `[System.IO.Path]::DirectorySeparatorChar` for a location below the venv root. Both fail on Linux before the change and pass after.
  - D2, `tests/scripts/dev-tools/HostBootstrapWorkspace.Tests.ps1`: new `It` blocks under `Describe 'Resolve-WorkspaceRoot'` and `Describe 'Resolve-ProjectRepoRoot'` that pass a relative path and assert the result equals the path joined to the PowerShell location, not to the process directory. Each test runs `Push-Location $PSScriptRoot`, sets `[Environment]::CurrentDirectory` to `[System.IO.Path]::GetPathRoot($PSScriptRoot)`, and restores both in `finally`. These fail before the change on both hosts.
  - D3, `tests/scripts/dev-tools/Enter-DrmCopilotShell.Tests.ps1`: new `Context` blocks `Get-DrmCopilotNormalizedPath` and `Resolve-DrmCopilotActivationScriptPath` under `Describe "DrmCopilotPromptSupport.ps1"`, with the same location/process-directory separation, restore in `finally`, and `Test-Path` mocked so that no real path is read.
  - D4, `tests/scripts/powershell/PoshQC/PoshQC.ScanConfig.Tests.ps1`: `Describe 'Get-PoshQCScanConfigFolder'` / `It 'throws an error naming the file for an absolute-path entry'` keeps the `C:/absolute/path` entry (fails on Linux before, passes after); new cases for `/absolute/path` and `\absolute\path`.
- Edge cases and negative scenarios (invalid inputs, missing data, boundary values): absolute input to D2/D3 returns unchanged; the outside-repo prompt form is unchanged; a location equal to the venv root renders the at-root form; D4 accepts workspace-relative entries and rejects `..` segments as before.
- Error handling and logging verification: the D4 error message still names the configuration file and contains "absolute".
- Coverage impact and targets for changed lines/modules: per-file line coverage of at least 85% for each changed source file, read from `artifacts/pester/powershell-coverage.xml`; no regression on changed lines. Pester has no branch-coverage gate.
- Toolchain commands to run (format → lint → type-check → test): PoshQC format (`mcp__drm-copilot__run_poshqc_format`), PSScriptAnalyzer with the repository settings (`mcp__drm-copilot__run_poshqc_analyze`), type checking not applicable, Pester (`mcp__drm-copilot__run_poshqc_test`, or the self-hosted PoshQC module for per-file coverage). Then the bundle-mirror contract tests listed in the execution-environment brief `## Contract Tests That Pin Mirrored Files` for the ScanConfig mirror.
- Isolation checks (execution-environment brief `## Test Isolation Checks`): a seeded shuffled single-process file-order run of the touched suites with at least three seeds, each seed and file order recorded; a fresh single-process run over `tests/scripts`; a concurrent-shard `Invoke-PoshQCParallelTest` run. Evidence goes under `evidence/regression-testing/` with `Timestamp`, `Command`, `EXIT_CODE`, and `Output Summary`, and no absolute path.
- Manual validation steps (if required): none.


## Acceptance Criteria
- [ ] A single-process Invoke-Pester run on Linux over the 17 suites listed under Scope reports 0 failures, and a single-process run over the full `tests/scripts/dev-tools` and `tests/scripts/powershell/PoshQC` trees reports 0 failures; both runs are recorded under `evidence/regression-testing/`.
- [ ] The Windows CI shards pass on the final PR head: the required check `poshqc / PowerShell QC` and every shard job `poshqc / PowerShell QC shard <n>` on `windows-latest` report success.
- [x] D1 regression: `activate.Tests.ps1` `Get-VenvAwarePrompt (prompt decision used by the shim)` / `renders a descendant prompt from the venv parent (light background)` and the new descendant-separator `It` under `Get-RepoRelativePrompt (pure logic)` fail on Linux before the `activate.ps1` change and pass after; Windows prompt output is unchanged.
- [x] D2 regression: the new relative-path `It` blocks under `HostBootstrapWorkspace.Tests.ps1` `Resolve-WorkspaceRoot` and `Resolve-ProjectRepoRoot` fail on Linux before the `HostBootstrapWorkspace.psm1` change and pass after; each restores the PowerShell location and `[Environment]::CurrentDirectory` in `finally`.
- [ ] D3 regression: the new relative-path `It` blocks under `Enter-DrmCopilotShell.Tests.ps1` `Get-DrmCopilotNormalizedPath` and `Resolve-DrmCopilotActivationScriptPath` fail on Linux before the `DrmCopilotPromptSupport.ps1` change and pass after; each restores the PowerShell location and `[Environment]::CurrentDirectory` in `finally`.
- [ ] D4 regression: `PoshQC.ScanConfig.Tests.ps1` `Get-PoshQCScanConfigFolder` / `throws an error naming the file for an absolute-path entry` with the `C:/absolute/path` entry fails on Linux before the `PoshQC.ScanConfig.psm1` change and passes after, and the added `/absolute/path` case passes; `extensions/drm-copilot/resources/powershell/PoshQC/PoshQC.ScanConfig.psm1` is byte-identical to `scripts/powershell/PoshQC/PoshQC.ScanConfig.psm1`.
- [ ] No test in the 17 suites writes to the real file system, creates temporary files, uses TestDrive, or uses `-Skip`; `PoshQC.ScanFolders.Tests.ps1` and `PoshQC.TestingCommands.Tests.ps1` assert a mocked `New-Item` with the expected coverage directory.
- [ ] Isolation: a seeded shuffled single-process file-order run of the touched suites with at least three recorded seeds, a fresh single-process run over `tests/scripts`, and a concurrent-shard `Invoke-PoshQCParallelTest` run each report 0 failures attributable to the touched suites; any pre-existing unrelated failure is recorded with its suite. `$env:POSHQC_SKIP_SCRIPT_EXECUTION`, the global prompt and `global:` functions, and `$global:LASTEXITCODE` are restored by `sync-agents-from-instructions.Tests.ps1`, `Enter-DrmCopilotShell.Tests.ps1`, and `Test-DiscoveryHostCapability.Entry.Tests.ps1` respectively.
- [ ] Per-file line coverage of each changed source file (`activate.ps1`, `HostBootstrapWorkspace.psm1`, `DrmCopilotPromptSupport.ps1`, `PoshQC.ScanConfig.psm1`) is at least 85% in `artifacts/pester/powershell-coverage.xml`, with no coverage regression on changed lines.
- [ ] The full PowerShell toolchain is clean in one pass (PoshQC format, PSScriptAnalyzer with the repository settings, Pester), and the bundle-mirror contract tests pass for the ScanConfig mirror.
- [ ] No personal user-profile path, host name, or user name remains in any touched fixture, including `Enter-DrmCopilotShell.Tests.ps1`.
- [ ] The open owner decision on adding `tests/scripts/dev-tools` and `tests/scripts/powershell/PoshQC` to the `ubuntu-latest` PowerShell leg is recorded in this spec under Rollout & Follow-up, with its reasons.

## Risks & Mitigations
- Technical or operational risks:
  - The D2/D3 regression tests change process-wide state (location and process directory); a missed restore corrupts later suites in a single-process run.
  - Rewriting expectations could weaken assertions.
  - The C3 mechanism (`Get-Content -Raw` binding) is inferred; the portable root may not resolve the HostTooling failure if the cause differs.
  - `Enter-DrmCopilotShell.Tests.ps1` global-prompt restore may be incomplete today (likely, unverified), which can mask or create order dependence.
  - Without a Linux CI leg for these trees, a new Windows-only fixture can reappear unnoticed.
  - The edits to `PoshQC.ScanConfig.psm1` must be mirrored exactly, or the push-down contract tests fail.
- Mitigations and rollbacks:
  - `try`/`finally` restore in every D2/D3 test, plus the three-seed shuffled single-process run and the concurrent-shard run.
  - Expectations stay exact and are built from the same `Join-Path` root; every `Should -Invoke` keeps its count and ParameterFilter.
  - The post-change Linux run confirms or refutes C3; if it does not resolve, the HostTooling fixture is revisited within this item.
  - The isolation fixes are part of this item.
  - The Linux leg is recorded as an owner decision.
  - The mirror is written byte-identically and the contract tests run before review. Each production fix can be reverted independently with its tests.

## Rollout & Follow-up
- Release/rollout steps: merge `main` (including #1066) before planning; deliver on `bug/pester-fixtures-platform-independent` through a pull request into `main`; the required `poshqc / PowerShell QC` check on the final PR head gates the merge.
- Post-fix monitoring or clean-up tasks:
  - Open owner decision (Linux leg): after this change, `tests/scripts/dev-tools` and `tests/scripts/powershell/PoshQC` are eligible for the `ubuntu-latest` PowerShell leg (`poshqc / PowerShell hook suites (Linux)` in `_poshqc.yml`). Adding them is deferred because (a) it requires about 14 companion edits: `tests/scripts/workflows/PoshQcWorkflow.Tests.ps1` and the six-copy mirrors of the execution-environment brief and `atomic-plan-contract`, plus the brief contract tests; and (b) Pester 5.9.1 throws during JUnit result export on the Linux Codespace host, the Linux job exports JUnit, and the cause is not identified. The owner decides whether and when to add the leg.
  - Known limitation (not a defect of this item): `activate.ps1` `Invoke-VenvActivation` uses the Windows venv layout.
- Links: issue #1067; sibling issue #1066; research `research/research.2026-11-03T22-55.md`; baseline `evidence/baseline/linux-pester-baseline.2026-11-03T22-49.md`.
