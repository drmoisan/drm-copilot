# Documentation Sweep — workspace_root required (Issue #401, AC-13)

Timestamp: 2026-07-22T20-17

SearchScope:
- `.claude/skills/**`, `.claude/agents/**`, `.claude/rules/**` (Claude runtime surface)
- `.agents/skills/**` (Codex-native runtime surface, repo root)
- Repo-root `README.md` and `extensions/drm-copilot/README.md` (README/docs guides)
- `extensions/drm-copilot/resources/**` bundled skill mirrors (deployed instructional docs)
- Explicitly excluded per plan: `docs/features/completed/**`, `docs/features/active/**` feature artifacts (spec/plan/issue/research/audits/evidence), `docs/research/**` research snapshots.

SearchPatterns:
- `workspace_root` (all mentions)
- `process.cwd` / `Defaults to process.cwd()` / `Omit to default`
- `optional workspace_root` / `workspace_root ... optional` / `workspace_root ... default`

SearchResult (files found to contain the false optional/default claim, before fix):
- `.claude/skills/execute-hard-lock/SKILL.md` (line 37)
- `.agents/skills/execute-hard-lock/SKILL.md` (line 34)
- `extensions/drm-copilot/resources/claude-customizations/.claude/skills/execute-hard-lock/SKILL.md` (line 37)
- `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/execute-hard-lock/SKILL.md` (line 34)
- `README.md` (repo root, lines 195, 223)
- `extensions/drm-copilot/README.md` (lines 120, 147 context, 151-169 tool list, 251 context)

Files edited:
- `.claude/skills/execute-hard-lock/SKILL.md` — `workspace_root` now described as required (P4-T1).
- `.agents/skills/execute-hard-lock/SKILL.md` — `workspace_root` now described as required.
- `extensions/drm-copilot/resources/claude-customizations/.claude/skills/execute-hard-lock/SKILL.md` — bundled mirror updated to required.
- `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/execute-hard-lock/SKILL.md` — bundled mirror updated to required.
- `README.md` (repo root) — line 195 rewritten (required, no process.cwd() default); line 223 rewritten (callers must pass workspace_root explicitly).
- `extensions/drm-copilot/README.md` — MCP Runtime Expectations line rewritten to state required + fail-closed; every "optional `workspace_root`" entry in the MCP Input Summary changed to "required `workspace_root`".

Residual matches (verified NOT false claims):
- README lines listing "required `workspace_root`, optional `scan_folders`/`selected_paths`" — these describe workspace_root as required and OTHER fields as optional; correct.
- All `docs/features/**` and `docs/research/**` matches are historical feature/research artifacts, excluded from the sweep scope by plan.

Verification: targeted grep for `optional \`workspace_root\``, `\`workspace_root\` ... default`, and `Defaults to \`process.cwd\`` against both READMEs returns no matches. No in-scope instructional doc claims a `process.cwd()` default for these tools.
