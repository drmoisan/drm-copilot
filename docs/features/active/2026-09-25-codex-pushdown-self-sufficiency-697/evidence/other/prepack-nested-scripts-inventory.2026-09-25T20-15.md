# Prepack Nested Scripts Inventory (Issue #697, spec Risks)

Timestamp: 2026-09-25T20-15
Command: git ls-files extensions/drm-copilot/resources | Select-String -SimpleMatch '/scripts/'
EXIT_CODE: 0
Output Summary: 7 matched paths; all 7 are nested (newly shipped by the anchored prepack filter); 0 lie under `extensions/drm-copilot/resources/scripts/` (still excluded). The seven `.codex/scripts/*.ps1` files are present.

| Path | Classification |
| --- | --- |
| `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/scripts/epic-child-launch-contract.ps1` | nested (newly shipped) |
| `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/scripts/epic-child-launch-runtime.ps1` | nested (newly shipped) |
| `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/scripts/epic-child-persistence-runtime.ps1` | nested (newly shipped) |
| `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/scripts/epic-child-sandbox-preflight.ps1` | nested (newly shipped) |
| `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/scripts/launch-epic-child-wave.ps1` | nested (newly shipped) |
| `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/scripts/post-codex-worktree-session.ps1` | nested (newly shipped) |
| `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/scripts/resume-epic-child.ps1` | nested (newly shipped) |

Supplementary check: `git ls-files extensions/drm-copilot/resources | grep -c '^extensions/drm-copilot/resources/scripts/'` printed `0`, so no tracked file sits in the resources-root `scripts/` subtree.
