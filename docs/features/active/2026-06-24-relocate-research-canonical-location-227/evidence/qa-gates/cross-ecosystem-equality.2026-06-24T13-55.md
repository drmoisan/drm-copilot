# Cross-Ecosystem Parity Verification (Issue #227 remediation)

Timestamp: 2026-06-24T13-55

## Root vs Claude mirror — byte comparison

- Root: .claude/hooks/enforce-evidence-locations.ps1
- Claude mirror: extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-evidence-locations.ps1
- `cmp -s` result: BYTE-IDENTICAL (no differences).
- md5 (both): 0722c5227ffe8cc4cd4874b247abe516.

Determination: root and Claude mirror are byte-identical. PASS.

## Codex translation parity

- Codex copy: extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-evidence-locations.ps1
- md5: 8509d82009bbd4d0e84a27e0be3d4059 (intentionally differs from root: banner + SKILL.md path).

Parity checks:
- Converted-header banner intact: line 1 `# Converted hook`, line 2
  `# Review the generated hook behavior before enabling it.`
- Contains the `Invoke-EvidenceLocationEntryPoint` function: yes (1 match).
- Contains the thin wiring `exit (Invoke-EvidenceLocationEntryPoint)`: yes (1 match).
- Retains the `.agents/skills/evidence-and-timestamp-conventions/SKILL.md` path in
  the block reason: yes (1 match).
- No `.claude/skills/` path leak from the root copy: confirmed (0 matches).
- The refactored function block plus wiring is character-for-character identical
  between the root and Codex files (diff of the `Invoke-EvidenceLocationEntryPoint`
  ... `exit (Invoke-EvidenceLocationEntryPoint)` span reports no differences).

Determination: Codex copy contains the equivalent dispatch logic (identical
function and wiring) while retaining its translation-specific banner and
`.agents/skills/...` SKILL.md path. PASS.

## Overall determination: PASS

Root and Claude mirror byte-identical; Codex copy has equivalent dispatch logic
with its translation-specific differences intact.
