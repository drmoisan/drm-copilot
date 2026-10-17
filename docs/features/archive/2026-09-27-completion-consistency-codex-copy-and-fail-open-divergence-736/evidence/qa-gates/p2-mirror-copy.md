# Bundled mirrors produced by Copy-Item ([P2-T13])

Timestamp: 2026-10-08T17-53
Command: pwsh -NoProfile -Command 'foreach ($pair in @(<four canonical/mirror pairs>)) { Copy-Item -LiteralPath $pair[0] -Destination $pair[1] -Force; "MIRROR_IDENTICAL=$(<hash equality>) $($pair[1])" }'
EXIT_CODE: 0
Output Summary: four MIRROR_IDENTICAL=True lines.

MIRROR_IDENTICAL=True extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-completion-consistency.ps1
MIRROR_IDENTICAL=True extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-completion-helpers.ps1
MIRROR_IDENTICAL=True extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-completion-consistency.ps1
MIRROR_IDENTICAL=True extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-completion-helpers.ps1
