# Phase 4 QA Gate — PoshQC (bundled-copy synchronization)

Timestamp: 2026-06-24T13-09

Files in scope:
- extensions/drm-copilot/resources/claude-customizations/.claude/hooks/validate-task-researcher-output.ps1 (byte-identical copy of root, P4-T1)
- extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-evidence-locations.ps1 (byte-identical copy of root, P4-T2)
- extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-evidence-locations.ps1 (translation-equivalent edit, P4-T3)

Stage 1 — Format
Command: mcp__drm-copilot__run_poshqc_format (scan_folders: [".../claude-customizations/.claude/hooks", ".../codex-and-agents-customizations/.codex/hooks"])
EXIT_CODE: 0
Output Summary: ok:true. Byte-identity of the two Claude mirrors against root reconfirmed after format (diff: IDENTICAL for both).

Stage 2 — Analyze
Command: mcp__drm-copilot__run_poshqc_analyze (same two scan folders)
EXIT_CODE: 0
Output Summary: ok:true. Zero analyzer findings.

Verification:
- diff .claude/hooks/validate-task-researcher-output.ps1 vs bundled mirror: IDENTICAL.
- diff .claude/hooks/enforce-evidence-locations.ps1 vs bundled mirror: IDENTICAL.
- Codex enforce-evidence-locations.ps1: 'artifacts/research/' present in the forbidden-prefix array (line 71) and the forbidden-prefix docstring list (line 23); no permitted reference remains. Codex-specific header ("Converted hook") and the .agents/skills/ SKILL.md path reference are preserved (translation equivalence, not byte-identity).

No dedicated test files target the bundled/Codex copies; the root copies are the tested source. Format and analyze clean for the three files in a single pass.
