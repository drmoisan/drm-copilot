# Linux tests/scripts Baseline (P0-T3)

Timestamp: 2026-11-04T03-54
Command: pwsh -NoProfile -NonInteractive -File SCRATCH/issue-1067-run-pester.ps1 -Root <worktree> -Paths tests/scripts (one fresh PowerShell 7 process, coverage and JUnit disabled, PassThru, no shuffle; launched through SCRATCH/issue-1067-go.sh)
EXIT_CODE: 1
Output Summary:
- TOTAL Tests=14144 Passed=14049 Failed=85 Skipped=10 NotRun=0
- CONTAINERS Total=503 Failed=0 (no container-level errors)
- Probes after the run: POSHQC_SKIP_SCRIPT_EXECUTION=1 (leaked by a suite), GLOBAL_PROMPT_CHANGED=False, LEAKED_GLOBAL_FUNCTIONS=7, LASTEXITCODE=85 (Invoke-Pester sets the global exit code to the failed count, so this probe reflects Pester's own value after the run).
- Wall time about 11 minutes (start 03-43, end 03-54 UTC).

Per-container failure profile (every FILE line with failed above 0); this is the reference for P6-T12 and P6-T13:

| Container | tests | failed |
|---|---|---|
| tests/scripts/dev-tools/activate.Tests.ps1 | 53 | 11 |
| tests/scripts/dev-tools/Enter-DrmCopilotShell.Tests.ps1 | 5 | 4 |
| tests/scripts/dev-tools/HostBootstrap.Invoke.Tests.ps1 | 23 | 16 |
| tests/scripts/dev-tools/HostBootstrap.Tests.ps1 | 28 | 1 |
| tests/scripts/dev-tools/HostBootstrapWorkspace.Tests.ps1 | 32 | 8 |
| tests/scripts/dev-tools/HostTooling.Tests.ps1 | 22 | 1 |
| tests/scripts/dev-tools/new-potential-entry.TemplateRoot.Tests.ps1 | 2 | 2 |
| tests/scripts/dev-tools/post-codex-worktree-session.Tests.ps1 | 13 | 1 |
| tests/scripts/dev-tools/publish-sideloaded-extension.Tests.ps1 | 18 | 16 |
| tests/scripts/dev-tools/SideloadedExtensionPublish.Invoke.Tests.ps1 | 13 | 12 |
| tests/scripts/dev-tools/SideloadedExtensionPublish.Tests.ps1 | 27 | 4 |
| tests/scripts/dev-tools/sync-agents-from-instructions.Tests.ps1 | 20 | 3 |
| tests/scripts/dev-tools/Test-DiscoveryHostCapability.Entry.Tests.ps1 | 4 | 3 |
| tests/scripts/powershell/PoshQC/PoshQC.ScanConfig.Tests.ps1 | 12 | 1 |
| tests/scripts/powershell/PoshQC/PoshQC.ScanFolders.Tests.ps1 | 17 | 1 |
| tests/scripts/powershell/PoshQC/PoshQC.TestingCommands.Tests.ps1 | 13 | 1 |

Observations:
- Every failing container is one of the 17 in-scope suites. No container outside the 17 suites fails in this single-process shape.
- `tests/scripts/dev-tools/Test-DiscoveryHostCapability.Tests.ps1` passes (6 tests, 0 failed) in this run order, whereas the two-tree baseline (2026-11-04T03-19) records 1 failure for it. The 85 versus 89 difference is distributed: activate 11 versus 13, Test-DiscoveryHostCapability.Entry 3 versus 4, Test-DiscoveryHostCapability 0 versus 1. These outcomes depend on run order or on the tree set on this host; the suites are converted in Phase 5 regardless.
- `git status --porcelain` after the run lists only the feature evidence files and the plan check-offs, so the run wrote no tracked or untracked repository file.
