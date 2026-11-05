# Scope Check (P6-T16)

Timestamp: 2026-11-04T15-16
Command: git diff --name-only MB HEAD (MB = git merge-base origin/main HEAD) ; git status --porcelain --untracked-files=all
EXIT_CODE: 0
Output Summary:
- `git diff --name-only MB HEAD` outside `docs/features/`: 22 paths, exactly the change set.
  - Production (5): `scripts/dev-tools/activate.ps1`, `scripts/dev-tools/HostBootstrapWorkspace.psm1`, `scripts/dev-tools/DrmCopilotPromptSupport.ps1`, `scripts/powershell/PoshQC/PoshQC.ScanConfig.psm1`, `extensions/drm-copilot/resources/powershell/PoshQC/PoshQC.ScanConfig.psm1`.
  - Suites (17): `tests/scripts/dev-tools/activate.Tests.ps1`, `Enter-DrmCopilotShell.Tests.ps1`, `HostBootstrap.Invoke.Tests.ps1`, `HostBootstrap.Tests.ps1`, `HostBootstrapWorkspace.Tests.ps1`, `HostTooling.Tests.ps1`, `new-potential-entry.TemplateRoot.Tests.ps1`, `post-codex-worktree-session.Tests.ps1`, `publish-sideloaded-extension.Tests.ps1`, `SideloadedExtensionPublish.Invoke.Tests.ps1`, `SideloadedExtensionPublish.Tests.ps1`, `sync-agents-from-instructions.Tests.ps1`, `Test-DiscoveryHostCapability.Entry.Tests.ps1`, `Test-DiscoveryHostCapability.Tests.ps1` (all under `tests/scripts/dev-tools/`), and `tests/scripts/powershell/PoshQC/PoshQC.ScanConfig.Tests.ps1`, `PoshQC.ScanFolders.Tests.ps1`, `PoshQC.TestingCommands.Tests.ps1`.
- `git status --porcelain`: only `<FEATURE>/plan.2026-11-03T17-43.md` (task check-offs) and `<FEATURE>/evidence/qa-gates/prohibited-constructs.2026-11-04T15-16.md`; nothing outside `docs/features/`.
- Under `docs/features/` the diff also lists `docs/features/potential/promoted/2026-11-03-pester-fixtures-platform-independent.md` (the promotion record of this item) besides the feature folder; both are inside `docs/features/` and outside the scope rule.
