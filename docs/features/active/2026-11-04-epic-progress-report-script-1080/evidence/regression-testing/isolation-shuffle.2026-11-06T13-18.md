# Seeded Shuffled Isolation Runs — Issue 1080 remediation cycle 3

Timestamp: 2026-11-06T13-18
Task: P2-T6
Command: sh SCRATCH/issue-1080-run.sh issue-1080-r3-p2t6-<seed>.log <seed> tests/scripts/dev-tools, for seeds 1080, 2026, and 7 (one fresh PowerShell 7 process per seed; file order shuffled by a System.Random Fisher-Yates pass seeded with the seed)
EXIT_CODE: 0
Output Summary: Seeds 1080, 2026, 7 each: TOTAL Tests=828 Passed=826 Failed=0 Skipped=2, EXIT_CODE=0. Logic suite tests=74 failed=0 and script suite tests=32 failed=0 in every run. No other container has failures.

## Results per seed

| Seed | TOTAL | Logic suite position | Script suite position | Logic suite | Script suite | Other containers with failures |
|---|---|---|---|---|---|---|
| 1080 | Tests=828 Passed=826 Failed=0 Skipped=2 | 1 | 18 | tests=74 failed=0 | tests=32 failed=0 | none |
| 2026 | Tests=828 Passed=826 Failed=0 Skipped=2 | 17 | 30 | tests=74 failed=0 | tests=32 failed=0 | none |
| 7 | Tests=828 Passed=826 Failed=0 Skipped=2 | 5 | 4 | tests=74 failed=0 | tests=32 failed=0 | none |

## File orders

### Seed 1080

```text
SEED 1080
ORDER 1 tests/scripts/dev-tools/Get-EpicProgressReport.Logic.Tests.ps1
ORDER 2 tests/scripts/dev-tools/Invoke-FullReleaseFlow.CheckHelpers.Tests.ps1
ORDER 3 tests/scripts/dev-tools/Invoke-ReleaseVerification.Tests.ps1
ORDER 4 tests/scripts/dev-tools/agents-attribution.Tests.ps1
ORDER 5 tests/scripts/dev-tools/Invoke-ReleaseReconciliation.Tests.ps1
ORDER 6 tests/scripts/dev-tools/Enter-DrmCopilotShell.Tests.ps1
ORDER 7 tests/scripts/dev-tools/run-actionlint.Tests.ps1
ORDER 8 tests/scripts/dev-tools/activate.Tests.ps1
ORDER 9 tests/scripts/dev-tools/Invoke-FullReleaseFlow.MergeWait.Tests.ps1
ORDER 10 tests/scripts/dev-tools/verify-host.Tests.ps1
ORDER 11 tests/scripts/dev-tools/post-codex-worktree-session.Tests.ps1
ORDER 12 tests/scripts/dev-tools/Invoke-ReleaseTagPushCallSiteBudgets.Tests.ps1
ORDER 13 tests/scripts/dev-tools/HostVerification.Invoke.Tests.ps1
ORDER 14 tests/scripts/dev-tools/HostVerification.Tests.ps1
ORDER 15 tests/scripts/dev-tools/HostBootstrap.Tests.ps1
ORDER 16 tests/scripts/dev-tools/SideloadedExtensionPublish.Invoke.Tests.ps1
ORDER 17 tests/scripts/dev-tools/Invoke-FullReleaseFlow.Tests.ps1
ORDER 18 tests/scripts/dev-tools/Get-EpicProgressReport.Tests.ps1
ORDER 19 tests/scripts/dev-tools/new-claude-worktree-session.Tests.ps1
ORDER 20 tests/scripts/dev-tools/publish-sideloaded-extension.Tests.ps1
ORDER 21 tests/scripts/dev-tools/HostBootstrap.Invoke.Tests.ps1
ORDER 22 tests/scripts/dev-tools/HostTooling.Tests.ps1
ORDER 23 tests/scripts/dev-tools/Invoke-ReleaseVerificationHelpers.Tests.ps1
ORDER 24 tests/scripts/dev-tools/Invoke-FullReleaseFlow.AdditionalFailurePaths.Tests.ps1
ORDER 25 tests/scripts/dev-tools/Invoke-ReleaseTagPush.Tests.ps1
ORDER 26 tests/scripts/dev-tools/SideloadedExtensionPublish.Tests.ps1
ORDER 27 tests/scripts/dev-tools/link-feature-docs.Tests.ps1
ORDER 28 tests/scripts/dev-tools/HostBootstrapWorkspace.Tests.ps1
ORDER 29 tests/scripts/dev-tools/Test-DiscoveryHostCapability.Entry.Tests.ps1
ORDER 30 tests/scripts/dev-tools/run-actionlint.EnvironmentIsolation.Tests.ps1
ORDER 31 tests/scripts/dev-tools/sync-agents-from-instructions.Tests.ps1
ORDER 32 tests/scripts/dev-tools/Invoke-FullReleaseFlow.ChecksWait.Tests.ps1
ORDER 33 tests/scripts/dev-tools/Invoke-MarketplacePublish.Tests.ps1
ORDER 34 tests/scripts/dev-tools/HostBootstrap.Versions.Tests.ps1
ORDER 35 tests/scripts/dev-tools/tree.Tests.ps1
ORDER 36 tests/scripts/dev-tools/Invoke-FullRelease.Tests.ps1
ORDER 37 tests/scripts/dev-tools/new-potential-entry.Tests.ps1
ORDER 38 tests/scripts/dev-tools/bootstrap-host.Tests.ps1
ORDER 39 tests/scripts/dev-tools/link-parent-child.Tests.ps1
ORDER 40 tests/scripts/dev-tools/new-potential-entry.TemplateRoot.Tests.ps1
ORDER 41 tests/scripts/dev-tools/Test-DiscoveryHostCapability.Tests.ps1
TOTAL Tests=828 Passed=826 Failed=0 Skipped=2 NotRun=0
EXIT_CODE=0
```

### Seed 2026

```text
SEED 2026
ORDER 1 tests/scripts/dev-tools/Invoke-FullReleaseFlow.ChecksWait.Tests.ps1
ORDER 2 tests/scripts/dev-tools/Invoke-ReleaseTagPush.Tests.ps1
ORDER 3 tests/scripts/dev-tools/sync-agents-from-instructions.Tests.ps1
ORDER 4 tests/scripts/dev-tools/Invoke-MarketplacePublish.Tests.ps1
ORDER 5 tests/scripts/dev-tools/Invoke-FullReleaseFlow.CheckHelpers.Tests.ps1
ORDER 6 tests/scripts/dev-tools/link-parent-child.Tests.ps1
ORDER 7 tests/scripts/dev-tools/post-codex-worktree-session.Tests.ps1
ORDER 8 tests/scripts/dev-tools/verify-host.Tests.ps1
ORDER 9 tests/scripts/dev-tools/Invoke-FullRelease.Tests.ps1
ORDER 10 tests/scripts/dev-tools/HostTooling.Tests.ps1
ORDER 11 tests/scripts/dev-tools/agents-attribution.Tests.ps1
ORDER 12 tests/scripts/dev-tools/link-feature-docs.Tests.ps1
ORDER 13 tests/scripts/dev-tools/SideloadedExtensionPublish.Invoke.Tests.ps1
ORDER 14 tests/scripts/dev-tools/run-actionlint.EnvironmentIsolation.Tests.ps1
ORDER 15 tests/scripts/dev-tools/Invoke-ReleaseTagPushCallSiteBudgets.Tests.ps1
ORDER 16 tests/scripts/dev-tools/HostBootstrapWorkspace.Tests.ps1
ORDER 17 tests/scripts/dev-tools/Get-EpicProgressReport.Logic.Tests.ps1
ORDER 18 tests/scripts/dev-tools/new-claude-worktree-session.Tests.ps1
ORDER 19 tests/scripts/dev-tools/HostBootstrap.Tests.ps1
ORDER 20 tests/scripts/dev-tools/Invoke-FullReleaseFlow.Tests.ps1
ORDER 21 tests/scripts/dev-tools/activate.Tests.ps1
ORDER 22 tests/scripts/dev-tools/Invoke-FullReleaseFlow.MergeWait.Tests.ps1
ORDER 23 tests/scripts/dev-tools/Invoke-ReleaseVerificationHelpers.Tests.ps1
ORDER 24 tests/scripts/dev-tools/Test-DiscoveryHostCapability.Tests.ps1
ORDER 25 tests/scripts/dev-tools/HostVerification.Tests.ps1
ORDER 26 tests/scripts/dev-tools/HostBootstrap.Versions.Tests.ps1
ORDER 27 tests/scripts/dev-tools/Enter-DrmCopilotShell.Tests.ps1
ORDER 28 tests/scripts/dev-tools/Invoke-FullReleaseFlow.AdditionalFailurePaths.Tests.ps1
ORDER 29 tests/scripts/dev-tools/publish-sideloaded-extension.Tests.ps1
ORDER 30 tests/scripts/dev-tools/Get-EpicProgressReport.Tests.ps1
ORDER 31 tests/scripts/dev-tools/new-potential-entry.TemplateRoot.Tests.ps1
ORDER 32 tests/scripts/dev-tools/tree.Tests.ps1
ORDER 33 tests/scripts/dev-tools/Invoke-ReleaseReconciliation.Tests.ps1
ORDER 34 tests/scripts/dev-tools/new-potential-entry.Tests.ps1
ORDER 35 tests/scripts/dev-tools/Invoke-ReleaseVerification.Tests.ps1
ORDER 36 tests/scripts/dev-tools/bootstrap-host.Tests.ps1
ORDER 37 tests/scripts/dev-tools/run-actionlint.Tests.ps1
ORDER 38 tests/scripts/dev-tools/Test-DiscoveryHostCapability.Entry.Tests.ps1
ORDER 39 tests/scripts/dev-tools/SideloadedExtensionPublish.Tests.ps1
ORDER 40 tests/scripts/dev-tools/HostVerification.Invoke.Tests.ps1
ORDER 41 tests/scripts/dev-tools/HostBootstrap.Invoke.Tests.ps1
TOTAL Tests=828 Passed=826 Failed=0 Skipped=2 NotRun=0
EXIT_CODE=0
```

### Seed 7

```text
SEED 7
ORDER 1 tests/scripts/dev-tools/Invoke-FullReleaseFlow.Tests.ps1
ORDER 2 tests/scripts/dev-tools/HostBootstrapWorkspace.Tests.ps1
ORDER 3 tests/scripts/dev-tools/HostBootstrap.Tests.ps1
ORDER 4 tests/scripts/dev-tools/Get-EpicProgressReport.Tests.ps1
ORDER 5 tests/scripts/dev-tools/Get-EpicProgressReport.Logic.Tests.ps1
ORDER 6 tests/scripts/dev-tools/new-potential-entry.TemplateRoot.Tests.ps1
ORDER 7 tests/scripts/dev-tools/post-codex-worktree-session.Tests.ps1
ORDER 8 tests/scripts/dev-tools/Test-DiscoveryHostCapability.Tests.ps1
ORDER 9 tests/scripts/dev-tools/tree.Tests.ps1
ORDER 10 tests/scripts/dev-tools/bootstrap-host.Tests.ps1
ORDER 11 tests/scripts/dev-tools/Invoke-ReleaseTagPushCallSiteBudgets.Tests.ps1
ORDER 12 tests/scripts/dev-tools/Invoke-FullReleaseFlow.MergeWait.Tests.ps1
ORDER 13 tests/scripts/dev-tools/Invoke-FullReleaseFlow.ChecksWait.Tests.ps1
ORDER 14 tests/scripts/dev-tools/SideloadedExtensionPublish.Tests.ps1
ORDER 15 tests/scripts/dev-tools/Invoke-FullReleaseFlow.AdditionalFailurePaths.Tests.ps1
ORDER 16 tests/scripts/dev-tools/Invoke-ReleaseTagPush.Tests.ps1
ORDER 17 tests/scripts/dev-tools/HostBootstrap.Invoke.Tests.ps1
ORDER 18 tests/scripts/dev-tools/link-parent-child.Tests.ps1
ORDER 19 tests/scripts/dev-tools/new-potential-entry.Tests.ps1
ORDER 20 tests/scripts/dev-tools/HostVerification.Invoke.Tests.ps1
ORDER 21 tests/scripts/dev-tools/verify-host.Tests.ps1
ORDER 22 tests/scripts/dev-tools/activate.Tests.ps1
ORDER 23 tests/scripts/dev-tools/Invoke-MarketplacePublish.Tests.ps1
ORDER 24 tests/scripts/dev-tools/HostBootstrap.Versions.Tests.ps1
ORDER 25 tests/scripts/dev-tools/Invoke-ReleaseReconciliation.Tests.ps1
ORDER 26 tests/scripts/dev-tools/HostTooling.Tests.ps1
ORDER 27 tests/scripts/dev-tools/Invoke-ReleaseVerification.Tests.ps1
ORDER 28 tests/scripts/dev-tools/Enter-DrmCopilotShell.Tests.ps1
ORDER 29 tests/scripts/dev-tools/HostVerification.Tests.ps1
ORDER 30 tests/scripts/dev-tools/publish-sideloaded-extension.Tests.ps1
ORDER 31 tests/scripts/dev-tools/sync-agents-from-instructions.Tests.ps1
ORDER 32 tests/scripts/dev-tools/run-actionlint.Tests.ps1
ORDER 33 tests/scripts/dev-tools/new-claude-worktree-session.Tests.ps1
ORDER 34 tests/scripts/dev-tools/run-actionlint.EnvironmentIsolation.Tests.ps1
ORDER 35 tests/scripts/dev-tools/Test-DiscoveryHostCapability.Entry.Tests.ps1
ORDER 36 tests/scripts/dev-tools/Invoke-ReleaseVerificationHelpers.Tests.ps1
ORDER 37 tests/scripts/dev-tools/Invoke-FullRelease.Tests.ps1
ORDER 38 tests/scripts/dev-tools/agents-attribution.Tests.ps1
ORDER 39 tests/scripts/dev-tools/link-feature-docs.Tests.ps1
ORDER 40 tests/scripts/dev-tools/SideloadedExtensionPublish.Invoke.Tests.ps1
ORDER 41 tests/scripts/dev-tools/Invoke-FullReleaseFlow.CheckHelpers.Tests.ps1
TOTAL Tests=828 Passed=826 Failed=0 Skipped=2 NotRun=0
EXIT_CODE=0
```
