# Linux Run: 17 In-Scope Suites (P6-T6, restart pass after resume)

Timestamp: 2026-11-04T14-01
Command: sh SCRATCH/issue-1067-run17.sh (pwsh -NoProfile -NonInteractive -File SCRATCH/issue-1067-run-pester.ps1 -Root <worktree> -Paths <the 17 suites listed in spec.md Scope, comma-separated>; one fresh PowerShell 7 process, coverage and JUnit off, PassThru, no shuffle)
EXIT_CODE: 0
Output Summary:
- TOTAL Tests=317 Passed=317 Failed=0 Skipped=0 NotRun=0
- CONTAINERS Total=17 Failed=0
- FILE tests/scripts/dev-tools/activate.Tests.ps1 tests=54 failed=0
- FILE tests/scripts/dev-tools/Enter-DrmCopilotShell.Tests.ps1 tests=9 failed=0
- FILE tests/scripts/dev-tools/HostBootstrap.Invoke.Tests.ps1 tests=23 failed=0
- FILE tests/scripts/dev-tools/HostBootstrap.Tests.ps1 tests=28 failed=0
- FILE tests/scripts/dev-tools/HostBootstrapWorkspace.Tests.ps1 tests=34 failed=0
- FILE tests/scripts/dev-tools/HostTooling.Tests.ps1 tests=22 failed=0
- FILE tests/scripts/dev-tools/new-potential-entry.TemplateRoot.Tests.ps1 tests=2 failed=0
- FILE tests/scripts/dev-tools/post-codex-worktree-session.Tests.ps1 tests=13 failed=0
- FILE tests/scripts/dev-tools/publish-sideloaded-extension.Tests.ps1 tests=18 failed=0
- FILE tests/scripts/dev-tools/SideloadedExtensionPublish.Invoke.Tests.ps1 tests=13 failed=0
- FILE tests/scripts/dev-tools/SideloadedExtensionPublish.Tests.ps1 tests=27 failed=0
- FILE tests/scripts/dev-tools/sync-agents-from-instructions.Tests.ps1 tests=20 failed=0
- FILE tests/scripts/dev-tools/Test-DiscoveryHostCapability.Entry.Tests.ps1 tests=4 failed=0
- FILE tests/scripts/dev-tools/Test-DiscoveryHostCapability.Tests.ps1 tests=6 failed=0
- FILE tests/scripts/powershell/PoshQC/PoshQC.ScanConfig.Tests.ps1 tests=14 failed=0
- FILE tests/scripts/powershell/PoshQC/PoshQC.ScanFolders.Tests.ps1 tests=17 failed=0
- FILE tests/scripts/powershell/PoshQC/PoshQC.TestingCommands.Tests.ps1 tests=13 failed=0
- Probes after the run: POSHQC_SKIP_SCRIPT_EXECUTION=absent, GLOBAL_PROMPT_CHANGED=False, LEAKED_GLOBAL_FUNCTIONS=0 (of 7 names), LASTEXITCODE=0 (AC1).
