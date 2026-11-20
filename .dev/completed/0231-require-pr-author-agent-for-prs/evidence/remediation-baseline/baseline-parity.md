# Baseline Parity — pre-fix (F-1 remediation)

Timestamp: 2026-06-24T15-59

Command:
```
sha256sum .claude/hooks/enforce-pr-author-skill.ps1 \
  extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-pr-author-skill.ps1
diff .claude/hooks/enforce-pr-author-skill.ps1 \
  extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-pr-author-skill.ps1
tail -n +4 extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-pr-author-skill.ps1 > codex_noheader.ps1
diff .claude/hooks/enforce-pr-author-skill.ps1 codex_noheader.ps1
```

EXIT_CODE: 0

Output Summary:
- root == bundled: TRUE. Both have SHA-256 `2f986f3df24300153ccc1a57b643c69552b11a6c78d5d9c307c498049ef0f286` (byte-identical, `diff` empty).
- Codex == root minus header: TRUE. Codex carries a 3-line leading header (`# Converted hook`, `# Review the generated hook behavior before enabling it.`, one blank line); the remaining body (lines 4+) is byte-identical to root (`diff` empty after stripping the 3 header lines).
- Line counts: root 331, bundled 331, Codex 334 (= 331 + 3 header lines).

Pre-fix parity state: all three copies in parity. The fix must preserve this exact parity relationship.
