# Linux single-process Pester baseline (issue 1067)

Timestamp: 2026-11-03T22-49
Command: sh SCRATCH/issue-1067-baseline.sh (fresh PowerShell 7: Invoke-Pester over tests/scripts/dev-tools and tests/scripts/powershell/PoshQC, one process, coverage disabled, JUnit export disabled, PassThru result grouped by file)
EXIT_CODE: 0
Output Summary: TOTAL Tests=921 Passed=823 Failed=89 Skipped=9 NotRun=0. All 89 failures are in the 17 suites listed below; every other suite in both trees passes. tests/scripts/dev-tools/run-actionlint.Tests.ps1 reports no failures. git status --porcelain was empty after the run.

Host: GitHub Codespace, Linux, PowerShell 7.6, Pester 5.9.1. Branch bug/pester-fixtures-platform-independent at the merge base with origin/main plus documentation commits only.

Note: with JUnit export enabled, Pester 5.9.1 throws during result export on this host after the run completes, so the export is disabled and counts come from the PassThru object.

## Per-test failures

```text
TOTAL Tests=921 Passed=823 Failed=89 Skipped=9 NotRun=0
FILE tests/scripts/dev-tools/activate.Tests.ps1 failures=13
  TEST Get-VenvAwarePrompt (prompt decision used by the shim).derives the repo root from the venv parent and renders the at-root prompt (light background)
    MSG Expected strings to be the same, but they were different. | Expected length: 18 | Actual length:   41 | Strings differ at index 16. | Expected: '(mix-calculator)> ' | But was:  '(mix-calculator) C:\repo\mix-calculator> ' |            ----------------^
  TEST Get-VenvAwarePrompt (prompt decision used by the shim).renders a descendant prompt from the venv parent (light background)
    MSG Expected strings to be the same, but they were different. | Expected length: 26 | Actual length:   49 | Strings differ at index 16. | Expected: '(mix-calculator)\.claude> ' | But was:  '(mix-calculator) C:\repo\mix-calculator\.claude> ' |            ----------------^
  TEST Get-VenvAwarePrompt (prompt decision used by the shim).wraps the venv-active form in green when the background is dark
    MSG Expected strings to be the same, but they were different. | Expected length: 27 | Actual length:   50 | Strings differ at index 21. | Expected: '[32m(mix-calculator)> [0m' | But was:  '[32m(mix-calculator) C:\repo\mix-calculator> [0m' |            ---------------------^
  TEST Get-VenvAwarePrompt (prompt decision used by the shim).renders the prompt uncolored when the host background is null (Test Explorer host parity)
    MSG Expected strings to be the same, but they were different. | Expected length: 18 | Actual length:   41 | Strings differ at index 16. | Expected: '(mix-calculator)> ' | But was:  '(mix-calculator) C:\repo\mix-calculator> ' |            ----------------^
  TEST Resolve-RepoRoot (depth-robust ancestor walk).returns the start directory when it directly contains .venv
    MSG Cannot find drive. A drive with the name 'C' does not exist.
  TEST Resolve-RepoRoot (depth-robust ancestor walk).walks up from a two-level-deep start to the ancestor containing .venv
    MSG Cannot find drive. A drive with the name 'C' does not exist.
  TEST Resolve-RepoRoot (depth-robust ancestor walk).walks up from a deeper start regardless of depth
    MSG Cannot find drive. A drive with the name 'C' does not exist.
  TEST Resolve-RepoRoot (depth-robust ancestor walk).returns the nearest qualifying ancestor when multiple ancestors contain .venv
    MSG Cannot find drive. A drive with the name 'C' does not exist.
  TEST Resolve-RepoRoot (depth-robust ancestor walk).returns an empty string when no ancestor contains .venv
    MSG Cannot find drive. A drive with the name 'C' does not exist.
  TEST Invoke-VenvActivation (orchestration; seams mocked).activates the venv and installs the prompt when a .venv ancestor exists
    MSG Cannot find drive. A drive with the name 'C' does not exist.
  TEST Invoke-VenvActivation (orchestration; seams mocked).throws guidance when no .venv ancestor is found
    MSG Expected an exception with message like '*Could not locate a '.venv' directory*' to be thrown, but the message was 'Cannot find drive. A drive with the name 'C' does not exist.'. from <worktree>/scripts/dev-tools/activate.ps1:86 char:22 |     +         $candidate = Join-Path -Path $current -ChildPath '.venv' |     +                      ~~~~~~~~~~~~~~~~~~~~~~
  TEST Invoke-VenvActivation (orchestration; seams mocked).throws when the resolved Activate.ps1 is missing
    MSG Expected an exception with message like '*venv missing at*' to be thrown, but the message was 'Cannot find drive. A drive with the name 'C' does not exist.'. from <worktree>/scripts/dev-tools/activate.ps1:86 char:22 |     +         $candidate = Join-Path -Path $current -ChildPath '.venv' |     +                      ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  TEST Invoke-VenvActivation (orchestration; seams mocked).installs a prompt that delegates to the venv-aware builder
    MSG Cannot find drive. A drive with the name 'C' does not exist.
FILE tests/scripts/dev-tools/Enter-DrmCopilotShell.Tests.ps1 failures=4
  TEST DrmCopilotPromptSupport.ps1.Get-DrmCopilotPromptPath.returns a repo-relative path with a leading backslash for nested folders
    MSG Expected strings to be the same, but they were different. | Expected length: 18 | Actual length:   78 | Strings differ at index 0. | Expected: '\scripts\dev-tools' | But was:  '<process-cwd>/C:\Users\DanMoisan\repos\drm-copilo...' |            ^
  TEST DrmCopilotPromptSupport.ps1.Get-DrmCopilotPromptPath.falls back to the absolute path when the location is outside the repo root
    MSG Expected strings to be the same, but they were different. | Expected length: 18 | Actual length:   42 | Strings differ at index 0. | Expected: 'C:\Users\DanMoisan' | But was:  '<process-cwd>/C:\Users\DanMoisan' |            ^
  TEST DrmCopilotPromptSupport.ps1.Set-DrmCopilotPrompt.renders the requested prompt name with the repo-relative folder
    MSG Expected strings to be the same, but they were different. | Expected length: 21 | Actual length:   81 | Strings differ at index 14. | Expected: '(drm-copilot):\docs> ' | But was:  '(drm-copilot):<process-cwd>/C:\Users\DanMoisan\re...' |            --------------^
  TEST DrmCopilotPromptSupport.ps1.Start-DrmCopilotPromptSession.activates the virtual environment with the requested prompt name and installs the custom prompt
    MSG Cannot find drive. A drive with the name 'C' does not exist.
FILE tests/scripts/dev-tools/HostBootstrap.Invoke.Tests.ps1 failures=16
  TEST Invoke-BootstrapHost.dry run.AC06-BOOTSTRAP-DRYRUN-NOSIDEEFFECTS performs no installs, registry writes, or clones and prints Would lines
    MSG Cannot find drive. A drive with the name 'C' does not exist.
  TEST Invoke-BootstrapHost.dry run.AC06-RUNONCE-NOT-SET-WITHOUT-BOTH does not register RunOnce with only -EnableAutoResumeAfterReboot
    MSG Cannot find drive. A drive with the name 'C' does not exist.
  TEST Invoke-BootstrapHost.failure paths.propagates a terminating error raised by the verify script
    MSG Expected an exception with message like 'verify fixture failure' to be thrown, but the message was 'Cannot find drive. A drive with the name 'C' does not exist.'. from <worktree>/scripts/dev-tools/HostBootstrapWorkspace.psm1:136 char:22 |     + … clonePath = Join-Path -Path $WorkspaceRootPath -ChildPath $targetPath … |     +               ~~~~~~~~~~~~~~~~~~~~
  TEST Invoke-BootstrapHost.RunOnce resume.AC06-RUNONCE-NOT-SET-WITHOUT-BOTH does not register RunOnce with only -Apply
    MSG Cannot find drive. A drive with the name 'C' does not exist.
  TEST Invoke-BootstrapHost.RunOnce resume.AC06-RUNONCE-CLEARED-AFTER-APPLY clears RunOnce after a successful apply
    MSG Cannot find drive. A drive with the name 'C' does not exist.
  TEST Invoke-BootstrapHost.apply.installs packages, modules, Graphite CLI, and clones projects
    MSG Cannot find drive. A drive with the name 'C' does not exist.
  TEST Invoke-BootstrapHost.apply.warns and skips Graphite CLI when npm is missing
    MSG Cannot find drive. A drive with the name 'C' does not exist.
  TEST Invoke-BootstrapHost.apply.AC06-POETRY-PROJECT-INSTALL-WARNS reports a poetry project-install failure as a warning
    MSG Cannot find drive. A drive with the name 'C' does not exist.
  TEST Invoke-BootstrapHost.apply.warns when pyproject.toml is absent
    MSG Cannot find drive. A drive with the name 'C' does not exist.
  TEST Invoke-BootstrapHost.apply.skips the project poetry install by request
    MSG Cannot find drive. A drive with the name 'C' does not exist.
  TEST Invoke-BootstrapHost.apply.warns and skips verification when verify-host.ps1 is absent
    MSG Cannot find drive. A drive with the name 'C' does not exist.
  TEST Invoke-BootstrapHost.apply.AC06-VERIFY-SCRIPT-EXITCODE-IGNORED invokes the sibling verify script by path and ignores its result
    MSG Cannot find drive. A drive with the name 'C' does not exist.
  TEST Invoke-BootstrapHost.poetry tool install.AC930-APPLY-INVOKES-POETRY-INSTALL installs the poetry tool in apply mode
    MSG Cannot find drive. A drive with the name 'C' does not exist.
  TEST Invoke-BootstrapHost.poetry tool install.AC930-DRYRUN-INVOKES-POETRY-INSTALL routes the poetry tool install in dry-run mode
    MSG Cannot find drive. A drive with the name 'C' does not exist.
  TEST Invoke-BootstrapHost.poetry tool install.AC930-POETRY-INSTALL-ORDER installs poetry after the PATH refresh and before the project install
    MSG Cannot find drive. A drive with the name 'C' does not exist.
  TEST Invoke-BootstrapHost.poetry tool install.AC930-SKIP-PROJECT-INSTALL-KEEPS-POETRY-TOOL-INSTALL still installs the poetry tool when the project install is skipped
    MSG Cannot find drive. A drive with the name 'C' does not exist.
FILE tests/scripts/dev-tools/HostBootstrap.Tests.ps1 failures=1
  TEST Install-PoetryWithPip.AC11-PIP-STREAMS installs poetry with -StreamToHost, emits no pip output, adds the poetry directory, and refreshes the session Path
    MSG Cannot find drive. A drive with the name 'C' does not exist.
FILE tests/scripts/dev-tools/HostBootstrapWorkspace.Tests.ps1 failures=8
  TEST Resolve-WorkspaceRoot.returns the full form of an explicit path
    MSG Expected strings to be the same, but they were different. | Expected length: 13 | Actual length:   37 | Strings differ at index 0. | Expected: 'C:\fixture\ws' | But was:  '<process-cwd>/C:\fixture\ws' |            ^
  TEST Sync-ProjectsFromManifest.derives the target path from the url in dry run
    MSG Cannot find drive. A drive with the name 'C' does not exist.
  TEST Sync-ProjectsFromManifest.skips a project that is already present
    MSG Cannot find drive. A drive with the name 'C' does not exist.
  TEST Sync-ProjectsFromManifest.reports the planned clone with an explicit target path in dry run
    MSG Cannot find drive. A drive with the name 'C' does not exist.
  TEST Sync-ProjectsFromManifest.clones the project through the git wrapper in apply mode
    MSG Cannot find drive. A drive with the name 'C' does not exist.
  TEST Resolve-ProjectRepoRoot.returns the full form of an explicit repo root
    MSG Expected strings to be the same, but they were different. | Expected length: 15 | Actual length:   39 | Strings differ at index 0. | Expected: 'C:\fixture\repo' | But was:  '<process-cwd>/C:\fixture\repo' |            ^
  TEST Resolve-ProjectRepoRoot.returns the drm-copilot project target path under the workspace
    MSG Cannot find drive. A drive with the name 'C' does not exist.
  TEST Resolve-ProjectRepoRoot.falls back to the drm-copilot folder name when the project target path is empty
    MSG Cannot find drive. A drive with the name 'C' does not exist.
FILE tests/scripts/dev-tools/HostTooling.Tests.ps1 failures=1
  TEST Read-HostToolsManifest.returns the parsed manifest object when the file exists
    MSG A parameter cannot be found that matches parameter name 'Raw'.
FILE tests/scripts/dev-tools/new-potential-entry.TemplateRoot.Tests.ps1 failures=2
  TEST new-potential-entry.ps1 - template root resolution.uses the supplied template root when the bundled potential template exists
    MSG Cannot find drive. A drive with the name 'C' does not exist.
  TEST new-potential-entry.ps1 - template root resolution.falls back to the workspace template when the supplied template root lacks the potential template
    MSG Cannot find drive. A drive with the name 'C' does not exist.
FILE tests/scripts/dev-tools/post-codex-worktree-session.Tests.ps1 failures=1
  TEST post-codex-worktree-session.ps1 - Resolve-CodexCustomizationSourceRoot.falls back deterministically to the repository root implied by the script path
    MSG Cannot find drive. A drive with the name 'C' does not exist.
FILE tests/scripts/dev-tools/publish-sideloaded-extension.Tests.ps1 failures=16
  TEST publish-sideloaded-extension.ps1 entry point - real orchestrator.AC05-PUBLISH-WHATIF-NOSEAMS makes no state-changing seam call under -WhatIf
    MSG Cannot find drive. A drive with the name 'C' does not exist.
  TEST publish-sideloaded-extension.ps1 entry point - real orchestrator.AC15-PUBLISH-INHERITED-WHATIF-NOSEAMS makes no state-changing seam call under an inherited WhatIfPreference
    MSG Cannot find drive. A drive with the name 'C' does not exist.
  TEST publish-sideloaded-extension.ps1 entry point - parameter forwarding.AC05-PUBLISH-CODECOMMAND-BOUNDEMPTY forwards an explicitly bound empty -CodeCommand
    MSG Cannot find drive. A drive with the name 'C' does not exist.
  TEST publish-sideloaded-extension.ps1 entry point - parameter forwarding.AC05-PUBLISH-CODECOMMAND-UNBOUND forwards no CodeCommand key when -CodeCommand is not supplied
    MSG Cannot find drive. A drive with the name 'C' does not exist.
  TEST publish-sideloaded-extension.ps1 entry point - parameter forwarding.AC05-PUBLISH-CONFIRM-FORWARDED forwards -Confirm:$false
    MSG Cannot find drive. A drive with the name 'C' does not exist.
  TEST publish-sideloaded-extension.ps1 entry point - parameter forwarding.forwards -Verbose and -WarningAction and does not forward -ErrorAction
    MSG Cannot find drive. A drive with the name 'C' does not exist.
  TEST publish-sideloaded-extension.ps1 entry point - parameter forwarding.forwards the switch parameters as passed
    MSG Cannot find drive. A drive with the name 'C' does not exist.
  TEST publish-sideloaded-extension.ps1 entry point - parameter forwarding.AC13-WHATIF-INHERITED forwards WhatIf true when WhatIfPreference is inherited and -WhatIf is unbound
    MSG Cannot find drive. A drive with the name 'C' does not exist.
  TEST publish-sideloaded-extension.ps1 entry point - parameter forwarding.AC13-WHATIF-BOUND-FALSE-WINS forwards WhatIf false when -WhatIf:$false is bound under an inherited true preference
    MSG Cannot find drive. A drive with the name 'C' does not exist.
  TEST publish-sideloaded-extension.ps1 entry point - parameter forwarding.AC13-CONFIRM-NONE forwards Confirm false for an inherited ConfirmPreference of None
    MSG Cannot find drive. A drive with the name 'C' does not exist.
  TEST publish-sideloaded-extension.ps1 entry point - parameter forwarding.AC13-CONFIRM-LOW forwards Confirm true for an inherited ConfirmPreference of Low
    MSG Cannot find drive. A drive with the name 'C' does not exist.
  TEST publish-sideloaded-extension.ps1 entry point - parameter forwarding.AC13-CONFIRM-HIGH adds no Confirm key for an inherited ConfirmPreference of High
    MSG Cannot find drive. A drive with the name 'C' does not exist.
  TEST publish-sideloaded-extension.ps1 entry point - parameter forwarding.AC13-VERBOSE-INHERITED forwards Verbose true for an inherited VerbosePreference of Continue
    MSG Cannot find drive. A drive with the name 'C' does not exist.
  TEST publish-sideloaded-extension.ps1 entry point - parameter forwarding.AC13-DEBUG-INHERITED forwards Debug true for an inherited DebugPreference of Continue
    MSG Cannot find drive. A drive with the name 'C' does not exist.
  TEST publish-sideloaded-extension.ps1 entry point - parameter forwarding.AC13-BOUND-DEBUG-INFO-PROGRESS forwards bound -Debug, -InformationAction, and -ProgressAction
    MSG Cannot find drive. A drive with the name 'C' does not exist.
  TEST publish-sideloaded-extension.ps1 entry point - parameter forwarding.AC13-DEFAULT-NO-WHATIF adds no WhatIf key under default preferences
    MSG Cannot find drive. A drive with the name 'C' does not exist.
FILE tests/scripts/dev-tools/SideloadedExtensionPublish.Invoke.Tests.ps1 failures=12
  TEST Invoke-SideloadedExtensionPublish.with a resolved VS Code CLI.AC06-PUBLISH-STEP-ORDER runs npm ci, compile, vsce package, and install in that order
    MSG Cannot find drive. A drive with the name 'C' does not exist.
  TEST Invoke-SideloadedExtensionPublish.with a resolved VS Code CLI.AC06-PUBLISH-SKIP-SWITCHES suppresses npm ci with -SkipNpmCi
    MSG Cannot find drive. A drive with the name 'C' does not exist.
  TEST Invoke-SideloadedExtensionPublish.with a resolved VS Code CLI.AC06-PUBLISH-SKIP-SWITCHES suppresses compile with -SkipCompile
    MSG Cannot find drive. A drive with the name 'C' does not exist.
  TEST Invoke-SideloadedExtensionPublish.with a resolved VS Code CLI.AC06-PUBLISH-SKIP-SWITCHES suppresses CLI resolution and install with -SkipInstall
    MSG Cannot find drive. A drive with the name 'C' does not exist.
  TEST Invoke-SideloadedExtensionPublish.with a resolved VS Code CLI.AC06-PUBLISH-VSIX-MISSING-THROWS throws when vsce did not create the VSIX
    MSG Expected an exception with message like 'VSIX was not created as expected: *drm-copilot-20260102-030405.vsix' to be thrown, but the message was 'Cannot find drive. A drive with the name 'C' does not exist.'. from <worktree>/scripts/dev-tools/SideloadedExtensionPublish.psm1:395 char:24 |     +     $packageJsonPath = Join-Path $extensionProjectRoot 'package.jso
  TEST Invoke-SideloadedExtensionPublish.with a resolved VS Code CLI.returns the VSIX path named from the -Now clock as its only output
    MSG Cannot find drive. A drive with the name 'C' does not exist.
  TEST Invoke-SideloadedExtensionPublish.with a resolved VS Code CLI.adds --force to the install arguments and requests npm cleanup with -Force
    MSG Cannot find drive. A drive with the name 'C' does not exist.
  TEST Invoke-SideloadedExtensionPublish.with a resolved VS Code CLI.creates the output directory through New-Item when it is absent
    MSG Cannot find drive. A drive with the name 'C' does not exist.
  TEST Invoke-SideloadedExtensionPublish.with a resolved VS Code CLI.throws when the extension package.json is missing
    MSG Expected an exception with message like 'package.json not found at RepoRoot: *package.json' to be thrown, but the message was 'Cannot find drive. A drive with the name 'C' does not exist.'. from <worktree>/scripts/dev-tools/SideloadedExtensionPublish.psm1:395 char:24 |     +     $packageJsonPath = Join-Path $extensionProjectRoot 'package.json' |     +        
  TEST Invoke-SideloadedExtensionPublish.with a resolved VS Code CLI.passes an explicit -CodeCommand to the CLI resolver
    MSG Cannot find drive. A drive with the name 'C' does not exist.
  TEST Invoke-SideloadedExtensionPublish.VS Code CLI resolution failures.AC06-PUBLISH-CODECOMMAND-NOTFOUND-THROWS throws when an explicit -CodeCommand is not on PATH
    MSG Expected an exception with message like 'VS Code CLI command 'code-missing' was explicitly requested but was not found on PATH.' to be thrown, but the message was 'Cannot find drive. A drive with the name 'C' does not exist.'. from <worktree>/scripts/dev-tools/SideloadedExtensionPublish.psm1:395 char:24 |     +     $packageJsonPath = Join-Path $extensionProje
  TEST Invoke-SideloadedExtensionPublish.VS Code CLI resolution failures.throws when no VS Code CLI command is found on PATH
    MSG Expected an exception with message like 'Could not find a VS Code CLI command on PATH (expected 'code' or 'code-insiders').' to be thrown, but the message was 'Cannot find drive. A drive with the name 'C' does not exist.'. from <worktree>/scripts/dev-tools/SideloadedExtensionPublish.psm1:395 char:24 |     +     $packageJsonPath = Join-Path $extensionProjectRo
FILE tests/scripts/dev-tools/SideloadedExtensionPublish.Tests.ps1 failures=4
  TEST Invoke-NpmCiWithRetry.AC06-PUBLISH-FORCE-CLEANUP stops node, removes node_modules, and cleans the npm cache
    MSG Cannot find drive. A drive with the name 'C' does not exist.
  TEST Invoke-ProjectCompile.runs the npm compile script when package.json defines one
    MSG Cannot find drive. A drive with the name 'C' does not exist.
  TEST Invoke-ProjectCompile.runs tsc when only tsconfig.json exists
    MSG Cannot find drive. A drive with the name 'C' does not exist.
  TEST Invoke-ProjectCompile.skips compilation when neither a compile script nor tsconfig.json exists
    MSG Cannot find drive. A drive with the name 'C' does not exist.
FILE tests/scripts/dev-tools/sync-agents-from-instructions.Tests.ps1 failures=3
  TEST sync-agents-from-instructions.ps1.Get-DiscoveredInstructionFile.Get-DiscoveredInstructionFile sorts normalized relative paths ordinally
    MSG Cannot find drive. A drive with the name 'C' does not exist.
  TEST sync-agents-from-instructions.ps1.Get-DiscoveredInstructionFile.Get-DiscoveredInstructionFile preserves deterministic ordering within the general and language-specific groups
    MSG Cannot find drive. A drive with the name 'C' does not exist.
  TEST sync-agents-from-instructions.ps1.Get-AgentContent ordering.emits general instruction files before language-specific instruction files in generated AGENTS.md output
    MSG Cannot find drive. A drive with the name 'C' does not exist.
FILE tests/scripts/dev-tools/Test-DiscoveryHostCapability.Entry.Tests.ps1 failures=4
  TEST Test-DiscoveryHostCapability.ps1 entry point.exits 2 and writes the unsupported document when the workspace has no installed probe
    MSG Expected $null or empty, but got Cannot find drive. A drive with the name 'C' does not exist..
  TEST Test-DiscoveryHostCapability.ps1 entry point.dot-sources the claude-code probe through the default seam and reports a session without observations unsupported
    MSG Expected $null or empty, but got AUTHORITY_PATH_NOT_CANONICAL: Workspace root must be an absolute path: <worktree>.
  TEST Test-DiscoveryHostCapability.ps1 entry point.dot-sources the codex probe through the default seam and reports a session without observations unsupported
    MSG Expected $null or empty, but got AUTHORITY_PATH_NOT_CANONICAL: Workspace root must be an absolute path: <worktree>.
  TEST Test-DiscoveryHostCapability.ps1 entry point.dot-sources the github-copilot probe through the default seam and reports a session without observations unsupported
    MSG Expected $null or empty, but got AUTHORITY_PATH_NOT_CANONICAL: Workspace root must be an absolute path: <worktree>.
FILE tests/scripts/dev-tools/Test-DiscoveryHostCapability.Tests.ps1 failures=1
  TEST Test-DiscoveryHostCapability.ps1.exits 2 with an unsupported document when the host has no installed probe
    MSG Cannot find drive. A drive with the name 'C' does not exist.
FILE tests/scripts/powershell/PoshQC/PoshQC.ScanConfig.Tests.ps1 failures=1
  TEST Get-PoshQCScanConfigFolder.throws an error naming the file for an absolute-path entry
    MSG Expected an exception with message like '*config/poshqc-scan.json*absolute*' to be thrown, but no exception was thrown.
FILE tests/scripts/powershell/PoshQC/PoshQC.ScanFolders.Tests.ps1 failures=1
  TEST Invoke-PoshQCTest scan-folder support.overrides run paths and preserves configured coverage paths when scan folders are supplied
    MSG Access to the path '/repo' is denied.
FILE tests/scripts/powershell/PoshQC/PoshQC.TestingCommands.Tests.ps1 failures=1
  TEST Invoke-PoshQCTest.preserves a custom KoverageOutputPath when ScanFolders narrow Run.Path and preserve coverage paths
    MSG Access to the path '/repo' is denied.
```
