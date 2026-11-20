# Hash Diff Baseline — Remediation Cycle 3

**Timestamp:** 2026-07-17T18-07

**Command:** `(Get-FileHash -Algorithm SHA256 -LiteralPath '.claude/hooks/validate-planner-output.ps1').Hash` and `(Get-FileHash -Algorithm SHA256 -LiteralPath 'extensions/drm-copilot/resources/claude-customizations/.claude/hooks/validate-planner-output.ps1').Hash`

**EXIT_CODE:** 0

**Output Summary:**
- Canonical `.claude/hooks/validate-planner-output.ps1` SHA256: `614D88A79E7F9DA7E8954FBDCC0F7CE8748AF63DE04E217760EAB1F1E6C3851B`
- Bundled mirror `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/validate-planner-output.ps1` SHA256: `DF3A751966BE04B636B1998287B2EEC69D5C68B6C6374C570F81A251AD383ECC`

The two SHA256 values are unequal, confirming the bundled mirror is not byte-identical to the canonical file prior to the Phase 1 fix.
