# Asserting-Test Search (P0-T8)

Timestamp: 2026-11-04T03-58
Command: grep -rnE "Get-RepoRelativePrompt|Resolve-WorkspaceRoot|Resolve-ProjectRepoRoot|Get-DrmCopilotNormalizedPath|Resolve-DrmCopilotActivationScriptPath|Get-PoshQCScanConfigFolder" tests ; grep -rlE "activate\.ps1|HostBootstrapWorkspace|DrmCopilotPromptSupport|PoshQC\.ScanConfig" tests
EXIT_CODE: 0
Output Summary:
Symbol search (matching files, match count):
- tests/scripts/dev-tools/activate.Tests.ps1 (9) - named in the plan section, D1.
- tests/scripts/dev-tools/HostBootstrapWorkspace.Tests.ps1 (10) - named, D2.
- tests/scripts/powershell/PoshQC/PoshQC.ScanConfig.Tests.ps1 (13) - named, D4.

File-name search (matching files):
- tests/scripts/dev-tools/Enter-DrmCopilotShell.Tests.ps1 - named, D3 (reaches the symbols through Get-DrmCopilotPromptPath, Set-DrmCopilotPrompt, Start-DrmCopilotPromptSession).
- tests/scripts/dev-tools/HostBootstrap.Invoke.Tests.ps1 - named, D2 (through Invoke-BootstrapHost).
- tests/scripts/dev-tools/HostBootstrap.Tests.ps1 - named, does not reach D2.
- tests/scripts/dev-tools/HostBootstrapWorkspace.Tests.ps1 - named.
- tests/scripts/dev-tools/activate.Tests.ps1 - named.
- tests/scripts/dev-tools/bootstrap-host.Tests.ps1 - named, unchanged because it mocks Invoke-BootstrapHost.
- tests/scripts/dev_tools/test_poshqc_bundled_parity.py - named, D4 parity.

Every matching file is named in `## Existing Tests That Assert Changed Behavior`. No unlisted asserting test was found.
