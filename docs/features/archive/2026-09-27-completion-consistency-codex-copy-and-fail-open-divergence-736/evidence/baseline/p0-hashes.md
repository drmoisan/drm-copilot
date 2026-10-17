# Baseline SHA-256 values ([P0-T6])

Timestamp: 2026-10-08T17-31
Command: pwsh -NoProfile -Command 'foreach ($p in @(<8 paths>)) { "SHA256=$((Get-FileHash -Algorithm SHA256 -LiteralPath $p).Hash) $p" }'
EXIT_CODE: 0
Output Summary: eight SHA256 lines; Claude and Codex helpers identical; each hook equals its mirror.

SHA256=F991EEE0A3FEFA7F1367FDBA060C623344EA3C10B3CA09D349D14472478FCFA9 .claude/hooks/enforce-completion-helpers.ps1
SHA256=F991EEE0A3FEFA7F1367FDBA060C623344EA3C10B3CA09D349D14472478FCFA9 .codex/hooks/enforce-completion-helpers.ps1
SHA256=F9CA16BFBD90E0A2223AB2222C0B7B8F0629DC4D835FF18AD319E407F39F07A5 .claude/hooks/enforce-completion-consistency.ps1
SHA256=CF301A28CA7F159D8E0A60F94F93AC55A57BFA3660F809B0CD8B7230925EBEC3 .codex/hooks/enforce-completion-consistency.ps1
SHA256=F991EEE0A3FEFA7F1367FDBA060C623344EA3C10B3CA09D349D14472478FCFA9 extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-completion-helpers.ps1
SHA256=F9CA16BFBD90E0A2223AB2222C0B7B8F0629DC4D835FF18AD319E407F39F07A5 extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-completion-consistency.ps1
SHA256=F991EEE0A3FEFA7F1367FDBA060C623344EA3C10B3CA09D349D14472478FCFA9 extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-completion-helpers.ps1
SHA256=CF301A28CA7F159D8E0A60F94F93AC55A57BFA3660F809B0CD8B7230925EBEC3 extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-completion-consistency.ps1

BASELINE_HELPERS_IDENTICAL: yes
BASELINE_MIRRORS_IDENTICAL: yes
