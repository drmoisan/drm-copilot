# Pester and Coverage Baseline ([P0-T6])

Timestamp: 2026-11-03T22-10
Command: sh SCRATCH/issue-1023-pester-run.sh (PowerShell 7: Import-Module scripts/powershell/PoshQC/PoshQC.psd1; Invoke-PoshQCTest -Root <worktree root> with no -ScanFolders, so the scan set is resolved from config/poshqc-scan.json: scripts, tests/powershell, tests/scripts; the CI shape, one process, coverage enabled); counts read from the root testsuites attributes of artifacts/pester/pester-junit.xml and from the Pester console summary, failing names from the console log, coverage from artifacts/pester/powershell-coverage.xml by SCRATCH/issue-1023-pester-summary.ps1
EXIT_CODE: 255
Output Summary: tests=14108, passed=13689, failures=409, errors=6, skipped=10 (disabled=10), 488 suites, 1234.94 s. Every failure is pre-existing and Linux-host-only (25 suites outside tests/scripts/claude-lib/docs; none of the 12 docs suites fails). Overall line coverage 92.66% (21914 covered, 1737 missed, 269 files). 1020 per-file line coverage under .claude/lib/docs: DocsAnalyzerRegistry.psm1 100, DocsFinding.psm1 100, DocsJson.psm1 100, DocsProfile.psm1 100, DocsProfileCommands.psm1 97.1, DocsSchema.psm1 100, DocsSchemaWalk.psm1 100, DocsSurface.psm1 100, Invoke-DocsCommand.ps1 87.33. The eight 1023 modules are absent (new-code baseline: not present). The non-zero exit is the pre-existing Pester JUnit export defect described below, after the run and the coverage report completed.

## Counts

Source: the root `<testsuites>` element of `artifacts/pester/pester-junit.xml` (`tests="14108" errors="6" failures="409" disabled="10"`) and the console summary `Tests Passed: 13689, Failed: 409, Skipped: 10, Inconclusive: 0, NotRun: 0`.

- tests: 14108
- passed: 13689
- failed: 409 (409 failures plus 6 errors are counted inside the failed total by the console summary)
- skipped: 10
- suites: 488

JUnit export defect (pre-existing, host-side): Pester's `Export-XmlReport` threw `Exception calling "WriteAttributeString"` on an escape character (U+001B) inside a failure message of the Linux-only failures, so the JUnit file was cut off after its first two suites (the root attributes are complete; the per-suite elements are partial). The console summary and the coverage report were written in full before that step. The same defect is recorded for this host in earlier runs; it does not occur when the docs suites alone run, because they emit no escape character.

## Pre-existing failures (Linux Codespace host; not caused by this feature and not repaired here)

Causes observed in the console log: drive-letter fixtures (`C:\repo\...`) compared against POSIX output, `/repo` permission fixtures (`UnauthorizedAccessException: Access to the path '/repo' is denied`), `pwsh` not resolvable on PATH inside hook subprocess probes (`CommandNotFoundException: The term 'pwsh' is not recognized`), and Windows-only host tooling. Failing suites (25):

- tests/scripts/claude-hooks/enforce-parallel-drift-gate-helpers.Tests.ps1
- tests/scripts/codex-hooks/codex-bundle-hook-probe.Tests.ps1
- tests/scripts/codex-hooks/codex-detached-head-transport.Tests.ps1
- tests/scripts/codex-hooks/codex-pretooluse-integration.Tests.ps1
- tests/scripts/codex-hooks/codex-pretooluse-transport.Tests.ps1
- tests/scripts/codex-hooks/epic-execution-gates.Tests.ps1
- tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1
- tests/scripts/codex-scripts/Resolve-CodexRouting.Parity.Tests.ps1
- tests/scripts/dev-tools/Enter-DrmCopilotShell.Tests.ps1
- tests/scripts/dev-tools/HostBootstrap.Invoke.Tests.ps1
- tests/scripts/dev-tools/HostBootstrap.Tests.ps1
- tests/scripts/dev-tools/HostBootstrapWorkspace.Tests.ps1
- tests/scripts/dev-tools/HostTooling.Tests.ps1
- tests/scripts/dev-tools/SideloadedExtensionPublish.Invoke.Tests.ps1
- tests/scripts/dev-tools/SideloadedExtensionPublish.Tests.ps1
- tests/scripts/dev-tools/Test-DiscoveryHostCapability.Entry.Tests.ps1
- tests/scripts/dev-tools/Test-DiscoveryHostCapability.Tests.ps1
- tests/scripts/dev-tools/activate.Tests.ps1
- tests/scripts/dev-tools/new-potential-entry.TemplateRoot.Tests.ps1
- tests/scripts/dev-tools/post-codex-worktree-session.Tests.ps1
- tests/scripts/dev-tools/publish-sideloaded-extension.Tests.ps1
- tests/scripts/dev-tools/sync-agents-from-instructions.Tests.ps1
- tests/scripts/powershell/PoshQC/PoshQC.ScanConfig.Tests.ps1
- tests/scripts/powershell/PoshQC/PoshQC.ScanFolders.Tests.ps1
- tests/scripts/powershell/PoshQC/PoshQC.TestingCommands.Tests.ps1

Failing test names printed by the console (97 individual tests; the remaining failures are block-level failures inside the suites above, which the console reports once per `Describe`):

- Get-VenvAwarePrompt (prompt decision used by the shim).derives the repo root from the venv parent and renders the at-root prompt (light background)
- Get-VenvAwarePrompt (prompt decision used by the shim).renders a descendant prompt from the venv parent (light background)
- Get-VenvAwarePrompt (prompt decision used by the shim).wraps the venv-active form in green when the background is dark
- Get-VenvAwarePrompt (prompt decision used by the shim).renders the prompt uncolored when the host background is null (Test Explorer host parity)
- Resolve-RepoRoot (depth-robust ancestor walk).returns the start directory when it directly contains .venv
- Resolve-RepoRoot (depth-robust ancestor walk).walks up from a two-level-deep start to the ancestor containing .venv
- Resolve-RepoRoot (depth-robust ancestor walk).walks up from a deeper start regardless of depth
- Resolve-RepoRoot (depth-robust ancestor walk).returns the nearest qualifying ancestor when multiple ancestors contain .venv
- Resolve-RepoRoot (depth-robust ancestor walk).returns an empty string when no ancestor contains .venv
- Invoke-VenvActivation (orchestration; seams mocked).activates the venv and installs the prompt when a .venv ancestor exists
- Invoke-VenvActivation (orchestration; seams mocked).throws guidance when no .venv ancestor is found
- Invoke-VenvActivation (orchestration; seams mocked).throws when the resolved Activate.ps1 is missing
- Invoke-VenvActivation (orchestration; seams mocked).installs a prompt that delegates to the venv-aware builder
- DrmCopilotPromptSupport.ps1.Get-DrmCopilotPromptPath.returns a repo-relative path with a leading backslash for nested folders
- DrmCopilotPromptSupport.ps1.Get-DrmCopilotPromptPath.falls back to the absolute path when the location is outside the repo root
- DrmCopilotPromptSupport.ps1.Set-DrmCopilotPrompt.renders the requested prompt name with the repo-relative folder
- DrmCopilotPromptSupport.ps1.Start-DrmCopilotPromptSession.activates the virtual environment with the requested prompt name and installs the custom prompt
- Invoke-BootstrapHost.dry run.AC06-BOOTSTRAP-DRYRUN-NOSIDEEFFECTS performs no installs, registry writes, or clones and prints Would lines
- Invoke-BootstrapHost.dry run.AC06-RUNONCE-NOT-SET-WITHOUT-BOTH does not register RunOnce with only -EnableAutoResumeAfterReboot
- Invoke-BootstrapHost.failure paths.propagates a terminating error raised by the verify script
- Invoke-BootstrapHost.RunOnce resume.AC06-RUNONCE-NOT-SET-WITHOUT-BOTH does not register RunOnce with only -Apply
- Invoke-BootstrapHost.RunOnce resume.AC06-RUNONCE-CLEARED-AFTER-APPLY clears RunOnce after a successful apply
- Invoke-BootstrapHost.apply.installs packages, modules, Graphite CLI, and clones projects
- Invoke-BootstrapHost.apply.warns and skips Graphite CLI when npm is missing
- Invoke-BootstrapHost.apply.AC06-POETRY-PROJECT-INSTALL-WARNS reports a poetry project-install failure as a warning
- Invoke-BootstrapHost.apply.warns when pyproject.toml is absent
- Invoke-BootstrapHost.apply.skips the project poetry install by request
- Invoke-BootstrapHost.apply.warns and skips verification when verify-host.ps1 is absent
- Invoke-BootstrapHost.apply.AC06-VERIFY-SCRIPT-EXITCODE-IGNORED invokes the sibling verify script by path and ignores its result
- Invoke-BootstrapHost.poetry tool install.AC930-APPLY-INVOKES-POETRY-INSTALL installs the poetry tool in apply mode
- Invoke-BootstrapHost.poetry tool install.AC930-DRYRUN-INVOKES-POETRY-INSTALL routes the poetry tool install in dry-run mode
- Invoke-BootstrapHost.poetry tool install.AC930-POETRY-INSTALL-ORDER installs poetry after the PATH refresh and before the project install
- Invoke-BootstrapHost.poetry tool install.AC930-SKIP-PROJECT-INSTALL-KEEPS-POETRY-TOOL-INSTALL still installs the poetry tool when the project install is skipped
- Install-PoetryWithPip.AC11-PIP-STREAMS installs poetry with -StreamToHost, emits no pip output, adds the poetry directory, and refreshes the session Path
- Resolve-WorkspaceRoot.returns the full form of an explicit path
- Sync-ProjectsFromManifest.derives the target path from the url in dry run
- Sync-ProjectsFromManifest.skips a project that is already present
- Sync-ProjectsFromManifest.reports the planned clone with an explicit target path in dry run
- Sync-ProjectsFromManifest.clones the project through the git wrapper in apply mode
- Resolve-ProjectRepoRoot.returns the full form of an explicit repo root
- Resolve-ProjectRepoRoot.returns the drm-copilot project target path under the workspace
- Resolve-ProjectRepoRoot.falls back to the drm-copilot folder name when the project target path is empty
- Read-HostToolsManifest.returns the parsed manifest object when the file exists
- new-potential-entry.ps1 - template root resolution.uses the supplied template root when the bundled potential template exists
- new-potential-entry.ps1 - template root resolution.falls back to the workspace template when the supplied template root lacks the potential template
- post-codex-worktree-session.ps1 - Resolve-CodexCustomizationSourceRoot.falls back deterministically to the repository root implied by the script path
- publish-sideloaded-extension.ps1 entry point - real orchestrator.AC05-PUBLISH-WHATIF-NOSEAMS makes no state-changing seam call under -WhatIf
- publish-sideloaded-extension.ps1 entry point - real orchestrator.AC15-PUBLISH-INHERITED-WHATIF-NOSEAMS makes no state-changing seam call under an inherited WhatIfPreference
- publish-sideloaded-extension.ps1 entry point - parameter forwarding.AC05-PUBLISH-CODECOMMAND-BOUNDEMPTY forwards an explicitly bound empty -CodeCommand
- publish-sideloaded-extension.ps1 entry point - parameter forwarding.AC05-PUBLISH-CODECOMMAND-UNBOUND forwards no CodeCommand key when -CodeCommand is not supplied
- publish-sideloaded-extension.ps1 entry point - parameter forwarding.AC05-PUBLISH-CONFIRM-FORWARDED forwards -Confirm:$false
- publish-sideloaded-extension.ps1 entry point - parameter forwarding.forwards -Verbose and -WarningAction and does not forward -ErrorAction
- publish-sideloaded-extension.ps1 entry point - parameter forwarding.forwards the switch parameters as passed
- publish-sideloaded-extension.ps1 entry point - parameter forwarding.AC13-WHATIF-INHERITED forwards WhatIf true when WhatIfPreference is inherited and -WhatIf is unbound
- publish-sideloaded-extension.ps1 entry point - parameter forwarding.AC13-WHATIF-BOUND-FALSE-WINS forwards WhatIf false when -WhatIf:$false is bound under an inherited true preference
- publish-sideloaded-extension.ps1 entry point - parameter forwarding.AC13-CONFIRM-NONE forwards Confirm false for an inherited ConfirmPreference of None
- publish-sideloaded-extension.ps1 entry point - parameter forwarding.AC13-CONFIRM-LOW forwards Confirm true for an inherited ConfirmPreference of Low
- publish-sideloaded-extension.ps1 entry point - parameter forwarding.AC13-CONFIRM-HIGH adds no Confirm key for an inherited ConfirmPreference of High
- publish-sideloaded-extension.ps1 entry point - parameter forwarding.AC13-VERBOSE-INHERITED forwards Verbose true for an inherited VerbosePreference of Continue
- publish-sideloaded-extension.ps1 entry point - parameter forwarding.AC13-DEBUG-INHERITED forwards Debug true for an inherited DebugPreference of Continue
- publish-sideloaded-extension.ps1 entry point - parameter forwarding.AC13-BOUND-DEBUG-INFO-PROGRESS forwards bound -Debug, -InformationAction, and -ProgressAction
- publish-sideloaded-extension.ps1 entry point - parameter forwarding.AC13-DEFAULT-NO-WHATIF adds no WhatIf key under default preferences
- Invoke-SideloadedExtensionPublish.with a resolved VS Code CLI.AC06-PUBLISH-STEP-ORDER runs npm ci, compile, vsce package, and install in that order
- Invoke-SideloadedExtensionPublish.with a resolved VS Code CLI.AC06-PUBLISH-SKIP-SWITCHES suppresses npm ci with -SkipNpmCi
- Invoke-SideloadedExtensionPublish.with a resolved VS Code CLI.AC06-PUBLISH-SKIP-SWITCHES suppresses compile with -SkipCompile
- Invoke-SideloadedExtensionPublish.with a resolved VS Code CLI.AC06-PUBLISH-SKIP-SWITCHES suppresses CLI resolution and install with -SkipInstall
- Invoke-SideloadedExtensionPublish.with a resolved VS Code CLI.AC06-PUBLISH-VSIX-MISSING-THROWS throws when vsce did not create the VSIX
- Invoke-SideloadedExtensionPublish.with a resolved VS Code CLI.returns the VSIX path named from the -Now clock as its only output
- Invoke-SideloadedExtensionPublish.with a resolved VS Code CLI.adds --force to the install arguments and requests npm cleanup with -Force
- Invoke-SideloadedExtensionPublish.with a resolved VS Code CLI.creates the output directory through New-Item when it is absent
- Invoke-SideloadedExtensionPublish.with a resolved VS Code CLI.throws when the extension package.json is missing
- Invoke-SideloadedExtensionPublish.with a resolved VS Code CLI.passes an explicit -CodeCommand to the CLI resolver
- Invoke-SideloadedExtensionPublish.VS Code CLI resolution failures.AC06-PUBLISH-CODECOMMAND-NOTFOUND-THROWS throws when an explicit -CodeCommand is not on PATH
- Invoke-SideloadedExtensionPublish.VS Code CLI resolution failures.throws when no VS Code CLI command is found on PATH
- Invoke-NpmCiWithRetry.AC06-PUBLISH-FORCE-CLEANUP stops node, removes node_modules, and cleans the npm cache
- Invoke-ProjectCompile.runs the npm compile script when package.json defines one
- Invoke-ProjectCompile.runs tsc when only tsconfig.json exists
- Invoke-ProjectCompile.skips compilation when neither a compile script nor tsconfig.json exists
- sync-agents-from-instructions.ps1.Get-DiscoveredInstructionFile.Get-DiscoveredInstructionFile sorts normalized relative paths ordinally
- sync-agents-from-instructions.ps1.Get-DiscoveredInstructionFile.Get-DiscoveredInstructionFile preserves deterministic ordering within the general and language-specific groups
- sync-agents-from-instructions.ps1.Get-AgentContent ordering.emits general instruction files before language-specific instruction files in generated AGENTS.md output
- Test-DiscoveryHostCapability.ps1 entry point.exits 2 and writes the unsupported document when the workspace has no installed probe
- Test-DiscoveryHostCapability.ps1 entry point.dot-sources the claude-code probe through the default seam and reports a session without observations unsupported
- Test-DiscoveryHostCapability.ps1 entry point.dot-sources the codex probe through the default seam and reports a session without observations unsupported
- Test-DiscoveryHostCapability.ps1 entry point.dot-sources the github-copilot probe through the default seam and reports a session without observations unsupported
- Test-DiscoveryHostCapability.ps1.exits 2 with an unsupported document when the host has no installed probe
- Describe Codex routing PowerShell wrappers match the Python CLI corpus (issue #697) failed
- Get-PoshQCScanConfigFolder.throws an error naming the file for an absolute-path entry
- Invoke-PoshQCTest scan-folder support.overrides run paths and preserves configured coverage paths when scan folders are supplied
- Invoke-PoshQCTest.preserves a custom KoverageOutputPath when ScanFolders narrow Run.Path and preserve coverage paths
- Describe Bundled Codex PreToolUse hooks run from the bundle location (issue #697) failed
- enforce-epic-child-worktree-binding.ps1 resolves the live branch on a detached HEAD (issue #415 C1).exits 0 with no stdout for a benign Bash payload when the attestation is present
- Describe Every registered Codex PreToolUse handler accepts every tool name its matcher admits failed
- Describe Codex PreToolUse hooks honour the native stdin transport contract failed
- Describe Codex epic preparation, wave, merge, and worktree gates failed
- Describe Legacy Codex hooks use native lifecycle contracts failed
- enforce-parallel-drift-gate-helpers.ps1.cross-runtime binding of the unresolved-drift derivation.binds the PowerShell unresolved-drift decision to the Python unresolved_drift derivation

## Coverage (artifacts/pester/powershell-coverage.xml, LINE counter per file; 269 files)

| File | Covered | Missed | Line coverage |
|---|---|---|---|
| `.claude/lib/docs/DocsAnalyzerRegistry.psm1` | 119 | 0 | 100 |
| `.claude/lib/docs/DocsFinding.psm1` | 88 | 0 | 100 |
| `.claude/lib/docs/DocsJson.psm1` | 102 | 0 | 100 |
| `.claude/lib/docs/DocsProfile.psm1` | 81 | 0 | 100 |
| `.claude/lib/docs/DocsProfileCommands.psm1` | 67 | 2 | 97.1 |
| `.claude/lib/docs/DocsSchema.psm1` | 127 | 0 | 100 |
| `.claude/lib/docs/DocsSchemaWalk.psm1` | 87 | 0 | 100 |
| `.claude/lib/docs/DocsSurface.psm1` | 130 | 0 | 100 |
| `.claude/lib/docs/Invoke-DocsCommand.ps1` | 131 | 19 | 87.33 |
| Total (all 269 files) | 21914 | 1737 | 92.66 |

Console coverage line: `Covered 92.08% / 0%. 36,538 analyzed Commands in 269 Files.` (command coverage; the line figure above is the LINE counter total of the report).

New-code baseline: not present. None of `DocsLedger.psm1`, `DocsParity.psm1`, `DocsEvidencePins.psm1`, `DocsStaleness.psm1`, `DocsReceipt.psm1`, `DocsValidation.psm1`, `DocsLedgerMutation.psm1` or `DocsLedgerCommands.psm1` exists under `.claude/lib/docs/` at baseline.

CI: `poshqc / PowerShell QC` (`windows-latest`), where the Linux-only failures above do not occur.
