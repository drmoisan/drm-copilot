# Baseline — Parity and Line Endings (Issue #902)

Timestamp: 2026-10-12T23-26
Command: git ls-files --eol -- .claude/skills/epic-orchestrate/SKILL.md extensions/drm-copilot/resources/claude-customizations/.claude/skills/epic-orchestrate/SKILL.md .agents/skills/epic-orchestrate/SKILL.md extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/epic-orchestrate/SKILL.md; git hash-object <same four paths in the same order>
EXIT_CODE: 0
Output Summary:
- All four `--eol` lines show `i/lf` and `w/lf`.
- Hash 1 (claude skill) = Hash 2 (claude bundle) = `c7d62564e34eceb688997a06676a55e74151fc15`.
- Hash 3 (codex skill) = Hash 4 (codex bundle) = `2bbf7029f7780f7a260fffcdf5228e183edf55c3`.
- Pair parity holds at baseline.

Raw output:

```text
i/lf    w/lf    attr/text=auto eol=lf 	.agents/skills/epic-orchestrate/SKILL.md
i/lf    w/lf    attr/text=auto eol=lf 	.claude/skills/epic-orchestrate/SKILL.md
i/lf    w/lf    attr/text=auto eol=lf 	extensions/drm-copilot/resources/claude-customizations/.claude/skills/epic-orchestrate/SKILL.md
i/lf    w/lf    attr/text=auto eol=lf 	extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/epic-orchestrate/SKILL.md
c7d62564e34eceb688997a06676a55e74151fc15
c7d62564e34eceb688997a06676a55e74151fc15
2bbf7029f7780f7a260fffcdf5228e183edf55c3
2bbf7029f7780f7a260fffcdf5228e183edf55c3
```
