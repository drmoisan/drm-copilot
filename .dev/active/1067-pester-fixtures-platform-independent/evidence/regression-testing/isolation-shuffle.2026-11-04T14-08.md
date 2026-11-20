# Isolation: Seeded Shuffled File-Order Runs of the 17 Suites (P6-T11, restart pass after resume)

Timestamp: 2026-11-04T14-08
Command: sh SCRATCH/issue-1067-shuffle.sh (three runs of SCRATCH/issue-1067-run17.sh with seeds 1067, 2026, and 7; each run is one fresh PowerShell 7 process that shuffles the 17 suites with a [System.Random] Fisher-Yates pass seeded by the given value, coverage and JUnit off, PassThru)
EXIT_CODE: 0
Output Summary:
- Seed 1067: TOTAL Tests=317 Passed=317 Failed=0; CONTAINERS Total=17 Failed=0; probes POSHQC_SKIP_SCRIPT_EXECUTION=absent, GLOBAL_PROMPT_CHANGED=False, LEAKED_GLOBAL_FUNCTIONS=0, LASTEXITCODE=0.
- Seed 2026: TOTAL Tests=317 Passed=317 Failed=0; CONTAINERS Total=17 Failed=0; same probe values.
- Seed 7: TOTAL Tests=317 Passed=317 Failed=0; CONTAINERS Total=17 Failed=0; same probe values.
- All three seeds report Failed=0 (AC8).

## File order, seed 1067

1. tests/scripts/dev-tools/Enter-DrmCopilotShell.Tests.ps1
2. tests/scripts/dev-tools/Test-DiscoveryHostCapability.Tests.ps1
3. tests/scripts/dev-tools/HostBootstrap.Tests.ps1
4. tests/scripts/dev-tools/SideloadedExtensionPublish.Invoke.Tests.ps1
5. tests/scripts/dev-tools/sync-agents-from-instructions.Tests.ps1
6. tests/scripts/dev-tools/new-potential-entry.TemplateRoot.Tests.ps1
7. tests/scripts/powershell/PoshQC/PoshQC.TestingCommands.Tests.ps1
8. tests/scripts/dev-tools/HostTooling.Tests.ps1
9. tests/scripts/powershell/PoshQC/PoshQC.ScanFolders.Tests.ps1
10. tests/scripts/dev-tools/post-codex-worktree-session.Tests.ps1
11. tests/scripts/dev-tools/SideloadedExtensionPublish.Tests.ps1
12. tests/scripts/dev-tools/activate.Tests.ps1
13. tests/scripts/dev-tools/Test-DiscoveryHostCapability.Entry.Tests.ps1
14. tests/scripts/dev-tools/HostBootstrapWorkspace.Tests.ps1
15. tests/scripts/dev-tools/publish-sideloaded-extension.Tests.ps1
16. tests/scripts/powershell/PoshQC/PoshQC.ScanConfig.Tests.ps1
17. tests/scripts/dev-tools/HostBootstrap.Invoke.Tests.ps1

## File order, seed 2026

1. tests/scripts/dev-tools/SideloadedExtensionPublish.Invoke.Tests.ps1
2. tests/scripts/dev-tools/HostBootstrap.Tests.ps1
3. tests/scripts/dev-tools/Test-DiscoveryHostCapability.Entry.Tests.ps1
4. tests/scripts/powershell/PoshQC/PoshQC.ScanFolders.Tests.ps1
5. tests/scripts/dev-tools/SideloadedExtensionPublish.Tests.ps1
6. tests/scripts/dev-tools/Enter-DrmCopilotShell.Tests.ps1
7. tests/scripts/dev-tools/new-potential-entry.TemplateRoot.Tests.ps1
8. tests/scripts/powershell/PoshQC/PoshQC.TestingCommands.Tests.ps1
9. tests/scripts/dev-tools/HostTooling.Tests.ps1
10. tests/scripts/dev-tools/publish-sideloaded-extension.Tests.ps1
11. tests/scripts/dev-tools/post-codex-worktree-session.Tests.ps1
12. tests/scripts/dev-tools/activate.Tests.ps1
13. tests/scripts/dev-tools/sync-agents-from-instructions.Tests.ps1
14. tests/scripts/powershell/PoshQC/PoshQC.ScanConfig.Tests.ps1
15. tests/scripts/dev-tools/Test-DiscoveryHostCapability.Tests.ps1
16. tests/scripts/dev-tools/HostBootstrapWorkspace.Tests.ps1
17. tests/scripts/dev-tools/HostBootstrap.Invoke.Tests.ps1

## File order, seed 7

1. tests/scripts/dev-tools/Enter-DrmCopilotShell.Tests.ps1
2. tests/scripts/dev-tools/sync-agents-from-instructions.Tests.ps1
3. tests/scripts/dev-tools/Test-DiscoveryHostCapability.Entry.Tests.ps1
4. tests/scripts/dev-tools/SideloadedExtensionPublish.Tests.ps1
5. tests/scripts/dev-tools/HostBootstrap.Invoke.Tests.ps1
6. tests/scripts/dev-tools/HostTooling.Tests.ps1
7. tests/scripts/dev-tools/HostBootstrap.Tests.ps1
8. tests/scripts/powershell/PoshQC/PoshQC.TestingCommands.Tests.ps1
9. tests/scripts/dev-tools/post-codex-worktree-session.Tests.ps1
10. tests/scripts/powershell/PoshQC/PoshQC.ScanConfig.Tests.ps1
11. tests/scripts/powershell/PoshQC/PoshQC.ScanFolders.Tests.ps1
12. tests/scripts/dev-tools/publish-sideloaded-extension.Tests.ps1
13. tests/scripts/dev-tools/HostBootstrapWorkspace.Tests.ps1
14. tests/scripts/dev-tools/activate.Tests.ps1
15. tests/scripts/dev-tools/SideloadedExtensionPublish.Invoke.Tests.ps1
16. tests/scripts/dev-tools/Test-DiscoveryHostCapability.Tests.ps1
17. tests/scripts/dev-tools/new-potential-entry.TemplateRoot.Tests.ps1
