# [P0-T6] Pester and coverage baseline (issue #1022)

Timestamp: 2026-11-03T22-17
Command: pwsh -NoProfile -File SCRATCH/issue-1022-p0t6-pester-baseline.ps1 -WorktreeRoot <item worktree> (imports scripts/powershell/PoshQC/PoshQC.psd1 and runs Invoke-PoshQCTest -Root <item worktree> -ScanFolders @('tests/scripts') in one PowerShell process with coverage enabled by scripts/powershell/PoshQC/settings/pester.runsettings.psd1; run log kept at SCRATCH/issue-1022-p0t6-run.log; started 2026-11-03T21-53, tests completed in 1143.64 s)
EXIT_CODE: 255
Output Summary: Discovery found 14108 tests in 500 files; coverage population source=config, 269 files. Pester summary: Tests Passed: 13689, Failed: 409, Skipped: 10, Inconclusive: 0, NotRun: 0; BeforeAll \ AfterAll failed: 6. Overall line coverage 92.66% (21914 covered / 23651 lines, JaCoCo LINE counter of artifacts/pester/powershell-coverage.xml; Pester reports 92.08% command coverage over 36,538 commands). .claude/lib/docs/DocsAnalyzerRegistry.psm1: 100% (119/119 lines). .claude/lib/docs/Invoke-DocsCommand.ps1: 87.33% (131/150 lines). No 1022 module exists at baseline (new-code baseline: not present). The non-zero exit code is Run.Exit = $true on a run with pre-existing host-only failures (Linux Codespace; CI runs these suites on windows-latest in `poshqc / PowerShell QC`).

## Counts

| Metric | Value | Source |
|---|---|---|
| Discovered tests | 14108 | run log (`Discovery found 14108 tests in 500 files`) |
| Passed | 13689 | run log Pester summary |
| Failed | 409 | run log Pester summary |
| Skipped | 10 | run log Pester summary |
| Containers failed in `BeforeAll`/`AfterAll` | 6 | run log Pester summary |
| Overall line coverage | 92.66% (21914 / 23651) | `artifacts/pester/powershell-coverage.xml`, root `counter type="LINE"` (JaCoCo) |
| Coverage files measured | 269 | same |
| `.claude/lib/docs/DocsAnalyzerRegistry.psm1` line coverage | 100% (119 / 119) | same, `class` LINE counter |
| `.claude/lib/docs/Invoke-DocsCommand.ps1` line coverage | 87.33% (131 / 150) | same, `class` LINE counter |
| 1022 modules at baseline | none (new-code baseline: not present) | `ls .claude/lib/docs` before any Phase 1 task |

## JUnit file defect (recorded, not a 1022 condition)

`artifacts/pester/pester-junit.xml` is truncated: Pester 5.9.1 `Export-XmlReport` failed with `'', hexadecimal value 0x1B, is an invalid character` while writing a failure message of `tests/scripts/dev-tools/activate.Tests.ps1` (`wraps the venv-active form in green when the background is dark`), so the file ends inside that `<failure>` element and holds 44 `testcase` elements of 14108. The header attributes written before the failure read `tests="14108" errors="6" failures="409" disabled="10"`, which agree with the summary above. Passed, failed and skipped counts and the failing-test list are therefore taken from the Pester summary and the Normal-verbosity run log (ANSI-stripped copy at `SCRATCH/issue-1022-p0t6-run.clean.log`, parsed by `SCRATCH/issue-1022-pester-log-failures.ps1`). The coverage file is complete.

## Failing containers (every test inside counts as failed; host-only)

| Suite | Container | Static `It` count |
|---|---|---|
| `tests/scripts/codex-scripts/Resolve-CodexRouting.Parity.Tests.ps1` | Codex routing PowerShell wrappers match the Python CLI corpus (issue #697) | 8 |
| `tests/scripts/codex-hooks/codex-bundle-hook-probe.Tests.ps1` | Bundled Codex PreToolUse hooks run from the bundle location (issue #697) | 3 |
| `tests/scripts/codex-hooks/codex-pretooluse-integration.Tests.ps1` | Every registered Codex PreToolUse handler accepts every tool name its matcher admits | 10 |
| `tests/scripts/codex-hooks/codex-pretooluse-transport.Tests.ps1` | Codex PreToolUse hooks honour the native stdin transport contract | 24 |
| `tests/scripts/codex-hooks/epic-execution-gates.Tests.ps1` | Codex epic preparation, wave, merge, and worktree gates | 24 |
| `tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1` | Legacy Codex hooks use native lifecycle contracts | 34 |

The dominant failure classes are `DriveNotFoundException: Cannot find drive. A drive with the name 'C' does not exist.` (Windows drive-letter fixtures) and host PATH assumptions; none touches `.claude/lib/docs` or `tests/scripts/claude-lib/docs`, whose suites all passed.

## Sorted failing test names (suite file :: Describe.Context.It; 97 lines: 91 individual tests across 19 suites plus the 6 container failures above)

```
tests/scripts/claude-hooks/enforce-parallel-drift-gate-helpers.Tests.ps1 :: enforce-parallel-drift-gate-helpers.ps1.cross-runtime binding of the unresolved-drift derivation.binds the PowerShell unresolved-drift decision to the Python unresolved_drift_item_keys derivation
tests/scripts/codex-hooks/codex-bundle-hook-probe.Tests.ps1 :: Describe Bundled Codex PreToolUse hooks run from the bundle location (issue #697) failed
tests/scripts/codex-hooks/codex-detached-head-transport.Tests.ps1 :: enforce-epic-child-worktree-binding.ps1 resolves the live branch on a detached HEAD (issue #415 C1).exits 0 with no stdout for a benign Bash payload when the attestation is dormant
tests/scripts/codex-hooks/codex-pretooluse-integration.Tests.ps1 :: Describe Every registered Codex PreToolUse handler accepts every tool name its matcher admits failed
tests/scripts/codex-hooks/codex-pretooluse-transport.Tests.ps1 :: Describe Codex PreToolUse hooks honour the native stdin transport contract failed
tests/scripts/codex-hooks/epic-execution-gates.Tests.ps1 :: Describe Codex epic preparation, wave, merge, and worktree gates failed
tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1 :: Describe Legacy Codex hooks use native lifecycle contracts failed
tests/scripts/codex-scripts/Resolve-CodexRouting.Parity.Tests.ps1 :: Describe Codex routing PowerShell wrappers match the Python CLI corpus (issue #697) failed
tests/scripts/dev-tools/activate.Tests.ps1 :: Get-VenvAwarePrompt (prompt decision used by the shim).derives the repo root from the venv parent and renders the at-root prompt (light background)
tests/scripts/dev-tools/activate.Tests.ps1 :: Get-VenvAwarePrompt (prompt decision used by the shim).renders a descendant prompt from the venv parent (light background)
tests/scripts/dev-tools/activate.Tests.ps1 :: Get-VenvAwarePrompt (prompt decision used by the shim).renders the prompt uncolored when the host background is null (Test Explorer host parity)
tests/scripts/dev-tools/activate.Tests.ps1 :: Get-VenvAwarePrompt (prompt decision used by the shim).wraps the venv-active form in green when the background is dark
tests/scripts/dev-tools/activate.Tests.ps1 :: Invoke-VenvActivation (orchestration; seams mocked).activates the venv and installs the prompt when a .venv ancestor exists
tests/scripts/dev-tools/activate.Tests.ps1 :: Invoke-VenvActivation (orchestration; seams mocked).installs a prompt that delegates to the venv-aware builder
tests/scripts/dev-tools/activate.Tests.ps1 :: Invoke-VenvActivation (orchestration; seams mocked).throws guidance when no .venv ancestor is found
tests/scripts/dev-tools/activate.Tests.ps1 :: Invoke-VenvActivation (orchestration; seams mocked).throws when the resolved Activate.ps1 is missing
tests/scripts/dev-tools/activate.Tests.ps1 :: Resolve-RepoRoot (depth-robust ancestor walk).returns an empty string when no ancestor contains .venv
tests/scripts/dev-tools/activate.Tests.ps1 :: Resolve-RepoRoot (depth-robust ancestor walk).returns the nearest qualifying ancestor when multiple ancestors contain .venv
tests/scripts/dev-tools/activate.Tests.ps1 :: Resolve-RepoRoot (depth-robust ancestor walk).returns the start directory when it directly contains .venv
tests/scripts/dev-tools/activate.Tests.ps1 :: Resolve-RepoRoot (depth-robust ancestor walk).walks up from a deeper start regardless of depth
tests/scripts/dev-tools/activate.Tests.ps1 :: Resolve-RepoRoot (depth-robust ancestor walk).walks up from a two-level-deep start to the ancestor containing .venv
tests/scripts/dev-tools/Enter-DrmCopilotShell.Tests.ps1 :: DrmCopilotPromptSupport.ps1.Get-DrmCopilotPromptPath.falls back to the absolute path when the location is outside the repo root
tests/scripts/dev-tools/Enter-DrmCopilotShell.Tests.ps1 :: DrmCopilotPromptSupport.ps1.Get-DrmCopilotPromptPath.returns a repo-relative path with a leading backslash for nested folders
tests/scripts/dev-tools/Enter-DrmCopilotShell.Tests.ps1 :: DrmCopilotPromptSupport.ps1.Set-DrmCopilotPrompt.renders the requested prompt name with the repo-relative folder
tests/scripts/dev-tools/Enter-DrmCopilotShell.Tests.ps1 :: DrmCopilotPromptSupport.ps1.Start-DrmCopilotPromptSession.activates the virtual environment with the requested prompt name and installs the custom prompt
tests/scripts/dev-tools/HostBootstrap.Invoke.Tests.ps1 :: Invoke-BootstrapHost.apply.AC06-POETRY-PROJECT-INSTALL-WARNS reports a poetry project-install failure as a warning
tests/scripts/dev-tools/HostBootstrap.Invoke.Tests.ps1 :: Invoke-BootstrapHost.apply.AC06-VERIFY-SCRIPT-EXITCODE-IGNORED invokes the sibling verify script by path and ignores its result
tests/scripts/dev-tools/HostBootstrap.Invoke.Tests.ps1 :: Invoke-BootstrapHost.apply.installs packages, modules, Graphite CLI, and clones projects
tests/scripts/dev-tools/HostBootstrap.Invoke.Tests.ps1 :: Invoke-BootstrapHost.apply.skips the project poetry install by request
tests/scripts/dev-tools/HostBootstrap.Invoke.Tests.ps1 :: Invoke-BootstrapHost.apply.warns and skips Graphite CLI when npm is missing
tests/scripts/dev-tools/HostBootstrap.Invoke.Tests.ps1 :: Invoke-BootstrapHost.apply.warns and skips verification when verify-host.ps1 is absent
tests/scripts/dev-tools/HostBootstrap.Invoke.Tests.ps1 :: Invoke-BootstrapHost.apply.warns when pyproject.toml is absent
tests/scripts/dev-tools/HostBootstrap.Invoke.Tests.ps1 :: Invoke-BootstrapHost.dry run.AC06-BOOTSTRAP-DRYRUN-NOSIDEEFFECTS performs no installs, registry writes, or clones and prints Would lines
tests/scripts/dev-tools/HostBootstrap.Invoke.Tests.ps1 :: Invoke-BootstrapHost.dry run.AC06-RUNONCE-NOT-SET-WITHOUT-BOTH does not register RunOnce with only -EnableAutoResumeAfterReboot
tests/scripts/dev-tools/HostBootstrap.Invoke.Tests.ps1 :: Invoke-BootstrapHost.failure paths.propagates a terminating error raised by the verify script
tests/scripts/dev-tools/HostBootstrap.Invoke.Tests.ps1 :: Invoke-BootstrapHost.poetry tool install.AC930-APPLY-INVOKES-POETRY-INSTALL installs the poetry tool in apply mode
tests/scripts/dev-tools/HostBootstrap.Invoke.Tests.ps1 :: Invoke-BootstrapHost.poetry tool install.AC930-DRYRUN-INVOKES-POETRY-INSTALL routes the poetry tool install in dry-run mode
tests/scripts/dev-tools/HostBootstrap.Invoke.Tests.ps1 :: Invoke-BootstrapHost.poetry tool install.AC930-POETRY-INSTALL-ORDER installs poetry after the PATH refresh and before the project install
tests/scripts/dev-tools/HostBootstrap.Invoke.Tests.ps1 :: Invoke-BootstrapHost.poetry tool install.AC930-SKIP-PROJECT-INSTALL-KEEPS-POETRY-TOOL-INSTALL still installs the poetry tool when the project install is skipped
tests/scripts/dev-tools/HostBootstrap.Invoke.Tests.ps1 :: Invoke-BootstrapHost.RunOnce resume.AC06-RUNONCE-CLEARED-AFTER-APPLY clears RunOnce after a successful apply
tests/scripts/dev-tools/HostBootstrap.Invoke.Tests.ps1 :: Invoke-BootstrapHost.RunOnce resume.AC06-RUNONCE-NOT-SET-WITHOUT-BOTH does not register RunOnce with only -Apply
tests/scripts/dev-tools/HostBootstrap.Tests.ps1 :: Install-PoetryWithPip.AC11-PIP-STREAMS installs poetry with -StreamToHost, emits no pip output, adds the poetry directory, and refreshes the session Path
tests/scripts/dev-tools/HostBootstrapWorkspace.Tests.ps1 :: Resolve-ProjectRepoRoot.falls back to the drm-copilot folder name when the project target path is empty
tests/scripts/dev-tools/HostBootstrapWorkspace.Tests.ps1 :: Resolve-ProjectRepoRoot.returns the drm-copilot project target path under the workspace
tests/scripts/dev-tools/HostBootstrapWorkspace.Tests.ps1 :: Resolve-ProjectRepoRoot.returns the full form of an explicit repo root
tests/scripts/dev-tools/HostBootstrapWorkspace.Tests.ps1 :: Resolve-WorkspaceRoot.returns the full form of an explicit path
tests/scripts/dev-tools/HostBootstrapWorkspace.Tests.ps1 :: Sync-ProjectsFromManifest.clones the project through the git wrapper in apply mode
tests/scripts/dev-tools/HostBootstrapWorkspace.Tests.ps1 :: Sync-ProjectsFromManifest.derives the target path from the url in dry run
tests/scripts/dev-tools/HostBootstrapWorkspace.Tests.ps1 :: Sync-ProjectsFromManifest.reports the planned clone with an explicit target path in dry run
tests/scripts/dev-tools/HostBootstrapWorkspace.Tests.ps1 :: Sync-ProjectsFromManifest.skips a project that is already present
tests/scripts/dev-tools/HostTooling.Tests.ps1 :: Read-HostToolsManifest.returns the parsed manifest object when the file exists
tests/scripts/dev-tools/new-potential-entry.TemplateRoot.Tests.ps1 :: new-potential-entry.ps1 - template root resolution.falls back to the workspace template when the supplied template root lacks the potential template
tests/scripts/dev-tools/new-potential-entry.TemplateRoot.Tests.ps1 :: new-potential-entry.ps1 - template root resolution.uses the supplied template root when the bundled potential template exists
tests/scripts/dev-tools/post-codex-worktree-session.Tests.ps1 :: post-codex-worktree-session.ps1 - Resolve-CodexCustomizationSourceRoot.falls back deterministically to the repository root implied by the script path
tests/scripts/dev-tools/publish-sideloaded-extension.Tests.ps1 :: publish-sideloaded-extension.ps1 entry point - parameter forwarding.AC05-PUBLISH-CODECOMMAND-BOUNDEMPTY forwards an explicitly bound empty -CodeCommand
tests/scripts/dev-tools/publish-sideloaded-extension.Tests.ps1 :: publish-sideloaded-extension.ps1 entry point - parameter forwarding.AC05-PUBLISH-CODECOMMAND-UNBOUND forwards no CodeCommand key when -CodeCommand is not supplied
tests/scripts/dev-tools/publish-sideloaded-extension.Tests.ps1 :: publish-sideloaded-extension.ps1 entry point - parameter forwarding.AC05-PUBLISH-CONFIRM-FORWARDED forwards -Confirm:$false
tests/scripts/dev-tools/publish-sideloaded-extension.Tests.ps1 :: publish-sideloaded-extension.ps1 entry point - parameter forwarding.AC13-BOUND-DEBUG-INFO-PROGRESS forwards bound -Debug, -InformationAction, and -ProgressAction
tests/scripts/dev-tools/publish-sideloaded-extension.Tests.ps1 :: publish-sideloaded-extension.ps1 entry point - parameter forwarding.AC13-CONFIRM-HIGH adds no Confirm key for an inherited ConfirmPreference of High
tests/scripts/dev-tools/publish-sideloaded-extension.Tests.ps1 :: publish-sideloaded-extension.ps1 entry point - parameter forwarding.AC13-CONFIRM-LOW forwards Confirm true for an inherited ConfirmPreference of Low
tests/scripts/dev-tools/publish-sideloaded-extension.Tests.ps1 :: publish-sideloaded-extension.ps1 entry point - parameter forwarding.AC13-CONFIRM-NONE forwards Confirm false for an inherited ConfirmPreference of None
tests/scripts/dev-tools/publish-sideloaded-extension.Tests.ps1 :: publish-sideloaded-extension.ps1 entry point - parameter forwarding.AC13-DEBUG-INHERITED forwards Debug true for an inherited DebugPreference of Continue
tests/scripts/dev-tools/publish-sideloaded-extension.Tests.ps1 :: publish-sideloaded-extension.ps1 entry point - parameter forwarding.AC13-DEFAULT-NO-WHATIF adds no WhatIf key under default preferences
tests/scripts/dev-tools/publish-sideloaded-extension.Tests.ps1 :: publish-sideloaded-extension.ps1 entry point - parameter forwarding.AC13-VERBOSE-INHERITED forwards Verbose true for an inherited VerbosePreference of Continue
tests/scripts/dev-tools/publish-sideloaded-extension.Tests.ps1 :: publish-sideloaded-extension.ps1 entry point - parameter forwarding.AC13-WHATIF-BOUND-FALSE-WINS forwards WhatIf false when -WhatIf:$false is bound under an inherited true preference
tests/scripts/dev-tools/publish-sideloaded-extension.Tests.ps1 :: publish-sideloaded-extension.ps1 entry point - parameter forwarding.AC13-WHATIF-INHERITED forwards WhatIf true when WhatIfPreference is inherited and -WhatIf is unbound
tests/scripts/dev-tools/publish-sideloaded-extension.Tests.ps1 :: publish-sideloaded-extension.ps1 entry point - parameter forwarding.forwards -Verbose and -WarningAction and does not forward -ErrorAction
tests/scripts/dev-tools/publish-sideloaded-extension.Tests.ps1 :: publish-sideloaded-extension.ps1 entry point - parameter forwarding.forwards the switch parameters as passed
tests/scripts/dev-tools/publish-sideloaded-extension.Tests.ps1 :: publish-sideloaded-extension.ps1 entry point - real orchestrator.AC05-PUBLISH-WHATIF-NOSEAMS makes no state-changing seam call under -WhatIf
tests/scripts/dev-tools/publish-sideloaded-extension.Tests.ps1 :: publish-sideloaded-extension.ps1 entry point - real orchestrator.AC15-PUBLISH-INHERITED-WHATIF-NOSEAMS makes no state-changing seam call under an inherited WhatIfPreference
tests/scripts/dev-tools/SideloadedExtensionPublish.Invoke.Tests.ps1 :: Invoke-SideloadedExtensionPublish.VS Code CLI resolution failures.AC06-PUBLISH-CODECOMMAND-NOTFOUND-THROWS throws when an explicit -CodeCommand is not on PATH
tests/scripts/dev-tools/SideloadedExtensionPublish.Invoke.Tests.ps1 :: Invoke-SideloadedExtensionPublish.VS Code CLI resolution failures.throws when no VS Code CLI command is found on PATH
tests/scripts/dev-tools/SideloadedExtensionPublish.Invoke.Tests.ps1 :: Invoke-SideloadedExtensionPublish.with a resolved VS Code CLI.AC06-PUBLISH-SKIP-SWITCHES suppresses CLI resolution and install with -SkipInstall
tests/scripts/dev-tools/SideloadedExtensionPublish.Invoke.Tests.ps1 :: Invoke-SideloadedExtensionPublish.with a resolved VS Code CLI.AC06-PUBLISH-SKIP-SWITCHES suppresses compile with -SkipCompile
tests/scripts/dev-tools/SideloadedExtensionPublish.Invoke.Tests.ps1 :: Invoke-SideloadedExtensionPublish.with a resolved VS Code CLI.AC06-PUBLISH-SKIP-SWITCHES suppresses npm ci with -SkipNpmCi
tests/scripts/dev-tools/SideloadedExtensionPublish.Invoke.Tests.ps1 :: Invoke-SideloadedExtensionPublish.with a resolved VS Code CLI.AC06-PUBLISH-STEP-ORDER runs npm ci, compile, vsce package, and install in that order
tests/scripts/dev-tools/SideloadedExtensionPublish.Invoke.Tests.ps1 :: Invoke-SideloadedExtensionPublish.with a resolved VS Code CLI.AC06-PUBLISH-VSIX-MISSING-THROWS throws when vsce did not create the VSIX
tests/scripts/dev-tools/SideloadedExtensionPublish.Invoke.Tests.ps1 :: Invoke-SideloadedExtensionPublish.with a resolved VS Code CLI.adds --force to the install arguments and requests npm cleanup with -Force
tests/scripts/dev-tools/SideloadedExtensionPublish.Invoke.Tests.ps1 :: Invoke-SideloadedExtensionPublish.with a resolved VS Code CLI.creates the output directory through New-Item when it is absent
tests/scripts/dev-tools/SideloadedExtensionPublish.Invoke.Tests.ps1 :: Invoke-SideloadedExtensionPublish.with a resolved VS Code CLI.passes an explicit -CodeCommand to the CLI resolver
tests/scripts/dev-tools/SideloadedExtensionPublish.Invoke.Tests.ps1 :: Invoke-SideloadedExtensionPublish.with a resolved VS Code CLI.returns the VSIX path named from the -Now clock as its only output
tests/scripts/dev-tools/SideloadedExtensionPublish.Invoke.Tests.ps1 :: Invoke-SideloadedExtensionPublish.with a resolved VS Code CLI.throws when the extension package.json is missing
tests/scripts/dev-tools/SideloadedExtensionPublish.Tests.ps1 :: Invoke-NpmCiWithRetry.AC06-PUBLISH-FORCE-CLEANUP stops node, removes node_modules, and cleans the npm cache
tests/scripts/dev-tools/SideloadedExtensionPublish.Tests.ps1 :: Invoke-ProjectCompile.runs the npm compile script when package.json defines one
tests/scripts/dev-tools/SideloadedExtensionPublish.Tests.ps1 :: Invoke-ProjectCompile.runs tsc when only tsconfig.json exists
tests/scripts/dev-tools/SideloadedExtensionPublish.Tests.ps1 :: Invoke-ProjectCompile.skips compilation when neither a compile script nor tsconfig.json exists
tests/scripts/dev-tools/sync-agents-from-instructions.Tests.ps1 :: sync-agents-from-instructions.ps1.Get-AgentContent ordering.emits general instruction files before language-specific instruction files in generated AGENTS.md output
tests/scripts/dev-tools/sync-agents-from-instructions.Tests.ps1 :: sync-agents-from-instructions.ps1.Get-DiscoveredInstructionFile.Get-DiscoveredInstructionFile preserves deterministic ordering within the general and language-specific groups
tests/scripts/dev-tools/sync-agents-from-instructions.Tests.ps1 :: sync-agents-from-instructions.ps1.Get-DiscoveredInstructionFile.Get-DiscoveredInstructionFile sorts normalized relative paths ordinally
tests/scripts/dev-tools/Test-DiscoveryHostCapability.Entry.Tests.ps1 :: Test-DiscoveryHostCapability.ps1 entry point.dot-sources the claude-code probe through the default seam and reports a session without observations unsupported
tests/scripts/dev-tools/Test-DiscoveryHostCapability.Entry.Tests.ps1 :: Test-DiscoveryHostCapability.ps1 entry point.dot-sources the codex probe through the default seam and reports a session without observations unsupported
tests/scripts/dev-tools/Test-DiscoveryHostCapability.Entry.Tests.ps1 :: Test-DiscoveryHostCapability.ps1 entry point.dot-sources the github-copilot probe through the default seam and reports a session without observations unsupported
tests/scripts/dev-tools/Test-DiscoveryHostCapability.Entry.Tests.ps1 :: Test-DiscoveryHostCapability.ps1 entry point.exits 2 and writes the unsupported document when the workspace has no installed probe
tests/scripts/dev-tools/Test-DiscoveryHostCapability.Tests.ps1 :: Test-DiscoveryHostCapability.ps1.exits 2 with an unsupported document when the host has no installed probe
tests/scripts/powershell/PoshQC/PoshQC.ScanConfig.Tests.ps1 :: Get-PoshQCScanConfigFolder.throws an error naming the file for an absolute-path entry
tests/scripts/powershell/PoshQC/PoshQC.ScanFolders.Tests.ps1 :: Invoke-PoshQCTest scan-folder support.overrides run paths and preserves configured coverage paths when scan folders are supplied
tests/scripts/powershell/PoshQC/PoshQC.TestingCommands.Tests.ps1 :: Invoke-PoshQCTest.preserves a custom KoverageOutputPath when ScanFolders narrow Run.Path and preserve coverage paths
```
