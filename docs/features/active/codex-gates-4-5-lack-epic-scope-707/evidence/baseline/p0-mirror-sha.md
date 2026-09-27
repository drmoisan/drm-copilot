# Phase 0 Mirror SHA-256 Baseline ([P0-T11])

Timestamp: 2026-09-27T06-39
Command: sh <SCRATCHPAD>/p0-mirror.sh (fresh PowerShell 7 process running Get-FileHash -Algorithm SHA256 over each repository-relative pair)
EXIT_CODE: 0
Output Summary: Four pairs recorded; all four are equal (informational).

| Source | Source SHA-256 | Mirror | Mirror SHA-256 | Mark |
| --- | --- | --- | --- | --- |
| `.codex/hooks/enforce-orchestration-preimplementation-gate.ps1` | 427CA3034A7268EA37EE176DCC990F3DBB113A143D15B3D2E0AF0236D091A9BB | `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-orchestration-preimplementation-gate.ps1` | 427CA3034A7268EA37EE176DCC990F3DBB113A143D15B3D2E0AF0236D091A9BB | equal |
| `.codex/hooks/enforce-completion-consistency.ps1` | CF301A28CA7F159D8E0A60F94F93AC55A57BFA3660F809B0CD8B7230925EBEC3 | `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-completion-consistency.ps1` | CF301A28CA7F159D8E0A60F94F93AC55A57BFA3660F809B0CD8B7230925EBEC3 | equal |
| `.codex/hooks/enforce-completion-helpers.ps1` | F991EEE0A3FEFA7F1367FDBA060C623344EA3C10B3CA09D349D14472478FCFA9 | `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-completion-helpers.ps1` | F991EEE0A3FEFA7F1367FDBA060C623344EA3C10B3CA09D349D14472478FCFA9 | equal |
| `scripts/powershell/PoshQC/settings/pester.runsettings.psd1` | A3A37EA28DECDED53476A580A841B2902503EDEED2B5D1DE231CBD4C596E8312 | `extensions/drm-copilot/resources/powershell/PoshQC/settings/pester.runsettings.psd1` | A3A37EA28DECDED53476A580A841B2902503EDEED2B5D1DE231CBD4C596E8312 | equal |
