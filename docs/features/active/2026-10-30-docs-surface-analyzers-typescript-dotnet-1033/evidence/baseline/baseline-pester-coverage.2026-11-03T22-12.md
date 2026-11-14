# Pester and coverage baseline ([P0-T8])

Timestamp: 2026-11-03T22-12
Command: pwsh -NoProfile -File SCRATCH/issue-1033-poshqc-test.ps1 -Root <worktree> -ScanFolders tests/scripts (imports scripts/powershell/PoshQC/PoshQC.psd1 and calls `Invoke-PoshQCTest -Root <worktree> -ScanFolders tests/scripts` in one process; Pester 5.9.1, PowerShell 7.6.9, Linux Codespace host); counts read from artifacts/pester/pester-junit.xml and artifacts/pester/powershell-coverage.xml through SCRATCH/issue-1033-coverage-summary.ps1
EXIT_CODE: 255
Output Summary: JUnit header (artifacts/pester/pester-junit.xml, `testsuites` element): tests=14108, failures=409, errors=6, skipped (disabled)=10. Console summary: `Tests Passed: 13689, Failed: 409, Skipped: 10, Inconclusive: 0, NotRun: 0`, `BeforeAll \ AfterAll failed: 6`, run time 1166.44 s. Exit 255 is the pre-existing Linux-host failure shape (Pester's JUnit export aborts on a 0x1B character in an `activate.Tests.ps1` failure message, so pester-junit.xml is written truncated at 14843 bytes after its header; the coverage XML is complete). Every failure is in suites outside `tests/scripts/claude-lib/docs` (host-tools, dev-tools, PoshQC host, Codex hook containers broken by the run-actionlint PATH leak); none is a docs suite. Overall line coverage 92.64% (21910 of 23651 lines). 1020 modules under `.claude/lib/docs`: DocsAnalyzerRegistry 100.00, DocsFinding 100.00, DocsJson 100.00, DocsProfile 100.00, DocsProfileCommands 97.10, DocsSchema 100.00, DocsSchemaWalk 100.00, DocsSurface 100.00, Invoke-DocsCommand 87.33. New-code baseline: not present (no 1033 module exists yet). CI: `poshqc / PowerShell QC` (Windows shards).

## Counts

| Source | tests | failures | errors | skipped |
|---|---|---|---|---|
| `artifacts/pester/pester-junit.xml` header (`testsuites` attributes `tests`, `failures`, `errors`, `disabled`) | 14108 | 409 | 6 | 10 |
| Console summary line | 13689 passed | 409 | 6 container (BeforeAll/AfterAll) failures | 10 |

The JUnit file is truncated after the `host-tools.manifest.Tests.ps1` and part of the `activate.Tests.ps1` suites, so per-test names are taken from the console `[-]` lines (97 named tests) plus the six containers whose `BeforeAll` failed (every test in those containers counts as failed without a per-test line; the remaining failures are those container tests).

## Overall line coverage

92.64% (21910 of 23651 lines) from `artifacts/pester/powershell-coverage.xml` (`/report/counter[@type='LINE']`).

## Per-file line coverage of the 1020 modules under `.claude/lib/docs`

| File | lines | covered | pct |
|---|---|---|---|
| DocsAnalyzerRegistry.psm1 | 119 | 119 | 100.00 |
| DocsFinding.psm1 | 88 | 88 | 100.00 |
| DocsJson.psm1 | 102 | 102 | 100.00 |
| DocsProfile.psm1 | 81 | 81 | 100.00 |
| DocsProfileCommands.psm1 | 69 | 67 | 97.10 |
| DocsSchema.psm1 | 127 | 127 | 100.00 |
| DocsSchemaWalk.psm1 | 87 | 87 | 100.00 |
| DocsSurface.psm1 | 130 | 130 | 100.00 |
| Invoke-DocsCommand.ps1 | 150 | 131 | 87.33 |

New-code baseline: not present.

## Failing containers (BeforeAll failed; every contained test failed)

- Codex routing PowerShell wrappers match the Python CLI corpus (issue #697)
- Bundled Codex PreToolUse hooks run from the bundle location (issue #697)
- Every registered Codex PreToolUse handler accepts every tool name its matcher admits
- Codex PreToolUse hooks honour the native stdin transport contract
- Codex epic preparation, wave, merge, and worktree gates
- Legacy Codex hooks use native lifecycle contracts

## Failing test names (console `[-]` lines, durations stripped)

```
Get-VenvAwarePrompt (prompt decision used by the shim).derives the repo root from the venv parent and renders the at-root prompt (light background)
Get-VenvAwarePrompt (prompt decision used by the shim).renders a descendant prompt from the venv parent (light background)
Get-VenvAwarePrompt (prompt decision used by the shim).wraps the venv-active form in green when the background is dark
Get-VenvAwarePrompt (prompt decision used by the shim).renders the prompt uncolored when the host background is null (Test Explorer host parity)
Resolve-RepoRoot (depth-robust ancestor walk).returns the start directory when it directly contains .venv
Resolve-RepoRoot (depth-robust ancestor walk).walks up from a two-level-deep start to the ancestor containing .venv
Resolve-RepoRoot (depth-robust ancestor walk).walks up from a deeper start regardless of depth
Resolve-RepoRoot (depth-robust ancestor walk).returns the nearest qualifying ancestor when multiple ancestors contain .venv
Resolve-RepoRoot (depth-robust ancestor walk).returns an empty string when no ancestor contains .venv
Invoke-VenvActivation (orchestration; seams mocked).activates the venv and installs the prompt when a .venv ancestor exists
Invoke-VenvActivation (orchestration; seams mocked).throws guidance when no .venv ancestor is found
Invoke-VenvActivation (orchestration; seams mocked).throws when the resolved Activate.ps1 is missing
Invoke-VenvActivation (orchestration; seams mocked).installs a prompt that delegates to the venv-aware builder
DrmCopilotPromptSupport.ps1.Get-DrmCopilotPromptPath.returns a repo-relative path with a leading backslash for nested folders
DrmCopilotPromptSupport.ps1.Get-DrmCopilotPromptPath.falls back to the absolute path when the location is outside the repo root
DrmCopilotPromptSupport.ps1.Set-DrmCopilotPrompt.renders the requested prompt name with the repo-relative folder
DrmCopilotPromptSupport.ps1.Start-DrmCopilotPromptSession.activates the virtual environment with the requested prompt name and installs the custom prompt
Invoke-BootstrapHost.dry run.AC06-BOOTSTRAP-DRYRUN-NOSIDEEFFECTS performs no installs, registry writes, or clones and prints Would lines
Invoke-BootstrapHost.dry run.AC06-RUNONCE-NOT-SET-WITHOUT-BOTH does not register RunOnce with only -EnableAutoResumeAfterReboot
Invoke-BootstrapHost.failure paths.propagates a terminating error raised by the verify script
Invoke-BootstrapHost.RunOnce resume.AC06-RUNONCE-NOT-SET-WITHOUT-BOTH does not register RunOnce with only -Apply
Invoke-BootstrapHost.RunOnce resume.AC06-RUNONCE-CLEARED-AFTER-APPLY clears RunOnce after a successful apply
Invoke-BootstrapHost.apply.installs packages, modules, Graphite CLI, and clones projects
Invoke-BootstrapHost.apply.warns and skips Graphite CLI when npm is missing
Invoke-BootstrapHost.apply.AC06-POETRY-PROJECT-INSTALL-WARNS reports a poetry project-install failure as a warning
Invoke-BootstrapHost.apply.warns when pyproject.toml is absent
Invoke-BootstrapHost.apply.skips the project poetry install by request
Invoke-BootstrapHost.apply.warns and skips verification when verify-host.ps1 is absent
Invoke-BootstrapHost.apply.AC06-VERIFY-SCRIPT-EXITCODE-IGNORED invokes the sibling verify script by path and ignores its result
Invoke-BootstrapHost.poetry tool install.AC930-APPLY-INVOKES-POETRY-INSTALL installs the poetry tool in apply mode
Invoke-BootstrapHost.poetry tool install.AC930-DRYRUN-INVOKES-POETRY-INSTALL routes the poetry tool install in dry-run mode
Invoke-BootstrapHost.poetry tool install.AC930-POETRY-INSTALL-ORDER installs poetry after the PATH refresh and before the project install
Invoke-BootstrapHost.poetry tool install.AC930-SKIP-PROJECT-INSTALL-KEEPS-POETRY-TOOL-INSTALL still installs the poetry tool when the project install is skipped
Install-PoetryWithPip.AC11-PIP-STREAMS installs poetry with -StreamToHost, emits no pip output, adds the poetry directory, and refreshes the session Path
Resolve-WorkspaceRoot.returns the full form of an explicit path
Sync-ProjectsFromManifest.derives the target path from the url in dry run
Sync-ProjectsFromManifest.skips a project that is already present
Sync-ProjectsFromManifest.reports the planned clone with an explicit target path in dry run
Sync-ProjectsFromManifest.clones the project through the git wrapper in apply mode
Resolve-ProjectRepoRoot.returns the full form of an explicit repo root
Resolve-ProjectRepoRoot.returns the drm-copilot project target path under the workspace
Resolve-ProjectRepoRoot.falls back to the drm-copilot folder name when the project target path is empty
Read-HostToolsManifest.returns the parsed manifest object when the file exists
new-potential-entry.ps1 - template root resolution.uses the supplied template root when the bundled potential template exists
new-potential-entry.ps1 - template root resolution.falls back to the workspace template when the supplied template root lacks the potential template
post-codex-worktree-session.ps1 - Resolve-CodexCustomizationSourceRoot.falls back deterministically to the repository root implied by the script path
publish-sideloaded-extension.ps1 entry point - real orchestrator.AC05-PUBLISH-WHATIF-NOSEAMS makes no state-changing seam call under -WhatIf
publish-sideloaded-extension.ps1 entry point - real orchestrator.AC15-PUBLISH-INHERITED-WHATIF-NOSEAMS makes no state-changing seam call under an inherited WhatIfPreference
publish-sideloaded-extension.ps1 entry point - parameter forwarding.AC05-PUBLISH-CODECOMMAND-BOUNDEMPTY forwards an explicitly bound empty -CodeCommand
publish-sideloaded-extension.ps1 entry point - parameter forwarding.AC05-PUBLISH-CODECOMMAND-UNBOUND forwards no CodeCommand key when -CodeCommand is not supplied
publish-sideloaded-extension.ps1 entry point - parameter forwarding.AC05-PUBLISH-CONFIRM-FORWARDED forwards -Confirm:$false
publish-sideloaded-extension.ps1 entry point - parameter forwarding.forwards -Verbose and -WarningAction and does not forward -ErrorAction
publish-sideloaded-extension.ps1 entry point - parameter forwarding.forwards the switch parameters as passed
publish-sideloaded-extension.ps1 entry point - parameter forwarding.AC13-WHATIF-INHERITED forwards WhatIf true when WhatIfPreference is inherited and -WhatIf is unbound
publish-sideloaded-extension.ps1 entry point - parameter forwarding.AC13-WHATIF-BOUND-FALSE-WINS forwards WhatIf false when -WhatIf:$false is bound under an inherited true preference
publish-sideloaded-extension.ps1 entry point - parameter forwarding.AC13-CONFIRM-NONE forwards Confirm false for an inherited ConfirmPreference of None
publish-sideloaded-extension.ps1 entry point - parameter forwarding.AC13-CONFIRM-LOW forwards Confirm true for an inherited ConfirmPreference of Low
publish-sideloaded-extension.ps1 entry point - parameter forwarding.AC13-CONFIRM-HIGH adds no Confirm key for an inherited ConfirmPreference of High
publish-sideloaded-extension.ps1 entry point - parameter forwarding.AC13-VERBOSE-INHERITED forwards Verbose true for an inherited VerbosePreference of Continue
publish-sideloaded-extension.ps1 entry point - parameter forwarding.AC13-DEBUG-INHERITED forwards Debug true for an inherited DebugPreference of Continue
publish-sideloaded-extension.ps1 entry point - parameter forwarding.AC13-BOUND-DEBUG-INFO-PROGRESS forwards bound -Debug, -InformationAction, and -ProgressAction
publish-sideloaded-extension.ps1 entry point - parameter forwarding.AC13-DEFAULT-NO-WHATIF adds no WhatIf key under default preferences
Invoke-SideloadedExtensionPublish.with a resolved VS Code CLI.AC06-PUBLISH-STEP-ORDER runs npm ci, compile, vsce package, and install in that order
Invoke-SideloadedExtensionPublish.with a resolved VS Code CLI.AC06-PUBLISH-SKIP-SWITCHES suppresses npm ci with -SkipNpmCi
Invoke-SideloadedExtensionPublish.with a resolved VS Code CLI.AC06-PUBLISH-SKIP-SWITCHES suppresses compile with -SkipCompile
Invoke-SideloadedExtensionPublish.with a resolved VS Code CLI.AC06-PUBLISH-SKIP-SWITCHES suppresses CLI resolution and install with -SkipInstall
Invoke-SideloadedExtensionPublish.with a resolved VS Code CLI.AC06-PUBLISH-VSIX-MISSING-THROWS throws when vsce did not create the VSIX
Invoke-SideloadedExtensionPublish.with a resolved VS Code CLI.returns the VSIX path named from the -Now clock as its only output
Invoke-SideloadedExtensionPublish.with a resolved VS Code CLI.adds --force to the install arguments and requests npm cleanup with -Force
Invoke-SideloadedExtensionPublish.with a resolved VS Code CLI.creates the output directory through New-Item when it is absent
Invoke-SideloadedExtensionPublish.with a resolved VS Code CLI.throws when the extension package.json is missing
Invoke-SideloadedExtensionPublish.with a resolved VS Code CLI.passes an explicit -CodeCommand to the CLI resolver
Invoke-SideloadedExtensionPublish.VS Code CLI resolution failures.AC06-PUBLISH-CODECOMMAND-NOTFOUND-THROWS throws when an explicit -CodeCommand is not on PATH
Invoke-SideloadedExtensionPublish.VS Code CLI resolution failures.throws when no VS Code CLI command is found on PATH
Invoke-NpmCiWithRetry.AC06-PUBLISH-FORCE-CLEANUP stops node, removes node_modules, and cleans the npm cache
Invoke-ProjectCompile.runs the npm compile script when package.json defines one
Invoke-ProjectCompile.runs tsc when only tsconfig.json exists
Invoke-ProjectCompile.skips compilation when neither a compile script nor tsconfig.json exists
sync-agents-from-instructions.ps1.Get-DiscoveredInstructionFile.Get-DiscoveredInstructionFile sorts normalized relative paths ordinally
sync-agents-from-instructions.ps1.Get-DiscoveredInstructionFile.Get-DiscoveredInstructionFile preserves deterministic ordering within the general and language-specific groups
sync-agents-from-instructions.ps1.Get-AgentContent ordering.emits general instruction files before language-specific instruction files in generated AGENTS.md output
Test-DiscoveryHostCapability.ps1 entry point.exits 2 and writes the unsupported document when the workspace has no installed probe
Test-DiscoveryHostCapability.ps1 entry point.dot-sources the claude-code probe through the default seam and reports a session without observations unsupported
Test-DiscoveryHostCapability.ps1 entry point.dot-sources the codex probe through the default seam and reports a session without observations unsupported
Test-DiscoveryHostCapability.ps1 entry point.dot-sources the github-copilot probe through the default seam and reports a session without observations unsupported
Test-DiscoveryHostCapability.ps1.exits 2 with an unsupported document when the host has no installed probe
Describe Codex routing PowerShell wrappers match the Python CLI corpus (issue #697) failed
Get-PoshQCScanConfigFolder.throws an error naming the file for an absolute-path entry
Invoke-PoshQCTest scan-folder support.overrides run paths and preserves configured coverage paths when scan folders are supplied
Invoke-PoshQCTest.preserves a custom KoverageOutputPath when ScanFolders narrow Run.Path and preserve coverage paths
Describe Bundled Codex PreToolUse hooks run from the bundle location (issue #697) failed
enforce-epic-child-worktree-binding.ps1 resolves the live branch on a detached HEAD (issue #415 C1).exits 0 with no stdout for a benign Bash payload when the attestation is dormant
Describe Every registered Codex PreToolUse handler accepts every tool name its matcher admits failed
Describe Codex PreToolUse hooks honour the native stdin transport contract failed
Describe Codex epic preparation, wave, merge, and worktree gates failed
Describe Legacy Codex hooks use native lifecycle contracts failed
enforce-parallel-drift-gate-helpers.ps1.cross-runtime binding of the unresolved-drift derivation.binds the PowerShell unresolved-drift decision to the Python unresolved_drift_item_keys derivation
```
