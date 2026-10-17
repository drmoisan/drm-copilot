# Shared Resolver Registration

Timestamp: 2026-10-08T19-31
Command: grep -c 'feature-folder-resolution.ps1' extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json ; grep -c 'feature-folder-resolution.ps1' extensions/drm-copilot/resources/codex-and-agents-customizations/pack-manifests/core.json ; grep -c 'feature-folder-resolution.ps1' tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1
EXIT_CODE: 0
Output Summary: Each count is 1. Both core pack manifests list the shared resolver, and $script:SharedModuleNames in legacy-codex-hook-contracts.Tests.ps1 includes it.

```
1   extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json
1   extensions/drm-copilot/resources/codex-and-agents-customizations/pack-manifests/core.json
1   tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1
```
