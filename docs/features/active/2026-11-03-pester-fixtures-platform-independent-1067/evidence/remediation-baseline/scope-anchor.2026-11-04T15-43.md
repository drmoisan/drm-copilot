# Scope Anchor — Remediation cycle 1 (P0-T2)

Timestamp: 2026-11-04T15-43
Command: sh SCRATCH/issue-1067-scope.sh (git merge-base origin/main HEAD; git status --porcelain --untracked-files=all; git diff --name-only MB HEAD filtered to paths outside docs/)
EXIT_CODE: 0

## State

- MB: 11f188d1b4f3726d854ddc00f8ad4c810138f049
- HEAD: edfad2011ff6d8bb17bfec249a6aae8f6205e7f2 (equal to upstream `origin/bug/pester-fixtures-platform-independent`)

## git status --porcelain (all paths under `<FEATURE>/`)

```
?? <FEATURE>/evidence/other/preflight-fixes.2026-11-04T15-42.md
?? <FEATURE>/evidence/remediation-baseline/phase0-instructions-read.2026-11-04T15-42.md
?? <FEATURE>/remediation-inputs.2026-11-04T15-31.md
?? <FEATURE>/remediation-plan.2026-11-04T15-31.md
```

No change-set test file is modified.

## git diff --name-only MB HEAD, outside docs/ (22 files)

```
extensions/drm-copilot/resources/powershell/PoshQC/PoshQC.ScanConfig.psm1
scripts/dev-tools/DrmCopilotPromptSupport.ps1
scripts/dev-tools/HostBootstrapWorkspace.psm1
scripts/dev-tools/activate.ps1
scripts/powershell/PoshQC/PoshQC.ScanConfig.psm1
tests/scripts/dev-tools/Enter-DrmCopilotShell.Tests.ps1
tests/scripts/dev-tools/HostBootstrap.Invoke.Tests.ps1
tests/scripts/dev-tools/HostBootstrap.Tests.ps1
tests/scripts/dev-tools/HostBootstrapWorkspace.Tests.ps1
tests/scripts/dev-tools/HostTooling.Tests.ps1
tests/scripts/dev-tools/SideloadedExtensionPublish.Invoke.Tests.ps1
tests/scripts/dev-tools/SideloadedExtensionPublish.Tests.ps1
tests/scripts/dev-tools/Test-DiscoveryHostCapability.Entry.Tests.ps1
tests/scripts/dev-tools/Test-DiscoveryHostCapability.Tests.ps1
tests/scripts/dev-tools/activate.Tests.ps1
tests/scripts/dev-tools/new-potential-entry.TemplateRoot.Tests.ps1
tests/scripts/dev-tools/post-codex-worktree-session.Tests.ps1
tests/scripts/dev-tools/publish-sideloaded-extension.Tests.ps1
tests/scripts/dev-tools/sync-agents-from-instructions.Tests.ps1
tests/scripts/powershell/PoshQC/PoshQC.ScanConfig.Tests.ps1
tests/scripts/powershell/PoshQC/PoshQC.ScanFolders.Tests.ps1
tests/scripts/powershell/PoshQC/PoshQC.TestingCommands.Tests.ps1
```

Output Summary: porcelain lists only `<FEATURE>/` paths; 22 files outside docs/ differ from MB; `link-feature-docs.Tests.ps1` and `link-parent-child.Tests.ps1` are not in that list (R1F1-IN-DIFF=0). The three R1-F2/R1-F4 suites are already in the branch diff from the main cycle.
