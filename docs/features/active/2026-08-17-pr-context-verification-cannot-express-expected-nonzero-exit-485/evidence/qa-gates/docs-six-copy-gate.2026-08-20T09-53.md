# Gate — six-copy documentation fan-out (AC23)

Timestamp: 2026-08-20T09-53

Task: [P6-T7]

Command: git grep -c "ExpectedExitCode" -- "*evidence-and-timestamp-conventions/SKILL.md"
EXIT_CODE: 0

## Result — exactly six files, three matching lines each

```
.agents/skills/evidence-and-timestamp-conventions/SKILL.md:3
.claude/skills/evidence-and-timestamp-conventions/SKILL.md:3
.github/skills/evidence-and-timestamp-conventions/SKILL.md:3
extensions/drm-copilot/resources/claude-customizations/.claude/skills/evidence-and-timestamp-conventions/SKILL.md:3
extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/evidence-and-timestamp-conventions/SKILL.md:3
extensions/drm-copilot/resources/customizations/.github/skills/evidence-and-timestamp-conventions/SKILL.md:3
```

- Files reporting a match: **6** — the three canonical copies (`.claude`, `.github`, `.agents`) and
  the three bundled mirrors under `extensions/drm-copilot/resources/`.
- Matching lines per file: 3, identical across all six, consistent with byte-identical content.

Each file's added block documents all six required points: the exact PascalCase spelling, the integer
value form, the default of `0` when absent, the whole-artifact `unparseable` consequence of a
non-integer value together with the resulting removal of the row from the PR body, the first-wins
duplicate rule, and the per-file limitation with the one-gate-per-artifact guidance.

Output Summary: Exactly six files report a match, three matching lines each — the three canonical
copies and the three bundled mirrors. Exit code 0. The six-copy fan-out is complete and consistent.
