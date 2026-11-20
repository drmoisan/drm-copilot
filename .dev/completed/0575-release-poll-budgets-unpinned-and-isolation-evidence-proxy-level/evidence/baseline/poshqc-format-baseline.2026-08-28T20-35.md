Timestamp: 2026-08-28T20-35
Command: Import-Module ./scripts/powershell/PoshQC/PoshQC.psd1 -Force; Invoke-PoshQCFormat -Root (Get-Location).Path -ScanFolders @('scripts/dev-tools','tests/scripts/dev-tools') *>&1
EXIT_CODE: 0
Output Summary: Scanned 22 files under scripts/dev-tools and 28 files under tests/scripts/dev-tools (50 files total). Every file reported the literal per-file line "Already formatted: <path>"; zero lines matched the pattern `^Formatted: ` (no file was rewritten). No pre-existing formatting drift was found in the scoped folders.

Full captured output:

```
Already formatted: C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-a7601c2ef97f9a7e4\scripts\dev-tools\activate.ps1
Already formatted: C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-a7601c2ef97f9a7e4\scripts\dev-tools\bootstrap-host.helpers.ps1
Already formatted: C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-a7601c2ef97f9a7e4\scripts\dev-tools\bootstrap-host.ps1
Already formatted: C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-a7601c2ef97f9a7e4\scripts\dev-tools\DrmCopilotPromptSupport.ps1
Already formatted: C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-a7601c2ef97f9a7e4\scripts\dev-tools\Enter-DrmCopilotShell.ps1
Already formatted: C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-a7601c2ef97f9a7e4\scripts\dev-tools\format-powershell.ps1
Already formatted: C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-a7601c2ef97f9a7e4\scripts\dev-tools\Invoke-FullRelease.ps1
Already formatted: C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-a7601c2ef97f9a7e4\scripts\dev-tools\Invoke-FullReleaseFlow.ps1
Already formatted: C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-a7601c2ef97f9a7e4\scripts\dev-tools\Invoke-MarketplacePublish.ps1
Already formatted: C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-a7601c2ef97f9a7e4\scripts\dev-tools\Invoke-ReleaseReconciliation.ps1
Already formatted: C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-a7601c2ef97f9a7e4\scripts\dev-tools\Invoke-ReleaseTagPush.ps1
Already formatted: C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-a7601c2ef97f9a7e4\scripts\dev-tools\Invoke-ReleaseVerification.ps1
Already formatted: C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-a7601c2ef97f9a7e4\scripts\dev-tools\Invoke-ReleaseVerificationHelpers.ps1
Already formatted: C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-a7601c2ef97f9a7e4\scripts\dev-tools\link-feature-docs.ps1
Already formatted: C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-a7601c2ef97f9a7e4\scripts\dev-tools\link-parent-child.ps1
Already formatted: C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-a7601c2ef97f9a7e4\scripts\dev-tools\load-openai-key.ps1
Already formatted: C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-a7601c2ef97f9a7e4\scripts\dev-tools\new-claude-worktree-session.ps1
Already formatted: C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-a7601c2ef97f9a7e4\scripts\dev-tools\new-potential-entry.ps1
Already formatted: C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-a7601c2ef97f9a7e4\scripts\dev-tools\publish-sideloaded-extension.ps1
Already formatted: C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-a7601c2ef97f9a7e4\scripts\dev-tools\run-actionlint.ps1
Already formatted: C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-a7601c2ef97f9a7e4\scripts\dev-tools\run-pester.ps1
Already formatted: C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-a7601c2ef97f9a7e4\scripts\dev-tools\run-poshqc-suite.ps1
Already formatted: C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-a7601c2ef97f9a7e4\scripts\dev-tools\run-psscriptanalyzer.ps1
Already formatted: C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-a7601c2ef97f9a7e4\scripts\dev-tools\sync-agents-from-instructions.ps1
Already formatted: C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-a7601c2ef97f9a7e4\scripts\dev-tools\tree.ps1
Already formatted: C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-a7601c2ef97f9a7e4\scripts\dev-tools\verify-host.ps1
Already formatted: C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-a7601c2ef97f9a7e4\scripts\dev-tools\vscode-cli.helpers.ps1
Already formatted: C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-a7601c2ef97f9a7e4\tests\scripts\dev-tools\activate.Tests.ps1
Already formatted: C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-a7601c2ef97f9a7e4\tests\scripts\dev-tools\agents-attribution.Tests.ps1
Already formatted: C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-a7601c2ef97f9a7e4\tests\scripts\dev-tools\Enter-DrmCopilotShell.Tests.ps1
Already formatted: C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-a7601c2ef97f9a7e4\tests\scripts\dev-tools\Invoke-FullRelease.Tests.ps1
Already formatted: C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-a7601c2ef97f9a7e4\tests\scripts\dev-tools\Invoke-FullReleaseFlow.AdditionalFailurePaths.Tests.ps1
Already formatted: C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-a7601c2ef97f9a7e4\tests\scripts\dev-tools\Invoke-FullReleaseFlow.ChecksWait.Tests.ps1
Already formatted: C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-a7601c2ef97f9a7e4\tests\scripts\dev-tools\Invoke-FullReleaseFlow.Tests.ps1
Already formatted: C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-a7601c2ef97f9a7e4\tests\scripts\dev-tools\Invoke-MarketplacePublish.Tests.ps1
Already formatted: C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-a7601c2ef97f9a7e4\tests\scripts\dev-tools\Invoke-ReleaseReconciliation.Tests.ps1
Already formatted: C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-a7601c2ef97f9a7e4\tests\scripts\dev-tools\Invoke-ReleaseTagPush.Tests.ps1
Already formatted: C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-a7601c2ef97f9a7e4\tests\scripts\dev-tools\Invoke-ReleaseVerification.Tests.ps1
Already formatted: C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-a7601c2ef97f9a7e4\tests\scripts\dev-tools\Invoke-ReleaseVerificationHelpers.Tests.ps1
Already formatted: C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-a7601c2ef97f9a7e4\tests\scripts\dev-tools\link-feature-docs.Tests.ps1
Already formatted: C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-a7601c2ef97f9a7e4\tests\scripts\dev-tools\link-parent-child.Tests.ps1
Already formatted: C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-a7601c2ef97f9a7e4\tests\scripts\dev-tools\new-claude-worktree-session.Tests.ps1
Already formatted: C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-a7601c2ef97f9a7e4\tests\scripts\dev-tools\new-potential-entry.TemplateRoot.Tests.ps1
Already formatted: C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-a7601c2ef97f9a7e4\tests\scripts\dev-tools\new-potential-entry.Tests.ps1
Already formatted: C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-a7601c2ef97f9a7e4\tests\scripts\dev-tools\post-codex-worktree-session.Tests.ps1
Already formatted: C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-a7601c2ef97f9a7e4\tests\scripts\dev-tools\publish-sideloaded-extension.Tests.ps1
Already formatted: C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-a7601c2ef97f9a7e4\tests\scripts\dev-tools\run-actionlint.Tests.ps1
Already formatted: C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-a7601c2ef97f9a7e4\tests\scripts\dev-tools\sync-agents-from-instructions.Tests.ps1
Already formatted: C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-a7601c2ef97f9a7e4\tests\scripts\dev-tools\tree.Tests.ps1
```
