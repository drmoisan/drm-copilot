# Final QC — Committed Bytes, LF, and Parity

Timestamp: 2026-10-13T00-05
Command: git diff --exit-code HEAD -- .claude/skills/epic-orchestrate/SKILL.md; git cat-file blob HEAD:.claude/skills/epic-orchestrate/SKILL.md | sha256sum; git ls-files --eol -- <four Markdown surfaces>; git hash-object <four Markdown surfaces, same order as P1-T8>
EXIT_CODE: 0
Output Summary:
- HEAD at time of check: `e9e35d70a` (pushed).
- `git diff --exit-code HEAD -- .claude/skills/epic-orchestrate/SKILL.md` exited 0.
- `git cat-file blob HEAD:.claude/skills/epic-orchestrate/SKILL.md | sha256sum` = `0b1a629aa81d78673e43c8f2bbd825d1377e0d6ae114e15e8bb65450c5d8b4f2`, equal to the skill digest written in P1-T10.
- All four `--eol` lines show `i/lf` and `w/lf`.
- Hash 1 = Hash 2 = `7a21440358463eabc98f7a6c874e96a87be6d357`; Hash 3 = Hash 4 = `c708d88dd34c984267f19e656c86d2ec1e2ef686`.

Raw output:

```text
DIFF_EXIT=0
0b1a629aa81d78673e43c8f2bbd825d1377e0d6ae114e15e8bb65450c5d8b4f2 *-
i/lf    w/lf    attr/text=auto eol=lf 	.agents/skills/epic-orchestrate/SKILL.md
i/lf    w/lf    attr/text=auto eol=lf 	.claude/skills/epic-orchestrate/SKILL.md
i/lf    w/lf    attr/text=auto eol=lf 	extensions/drm-copilot/resources/claude-customizations/.claude/skills/epic-orchestrate/SKILL.md
i/lf    w/lf    attr/text=auto eol=lf 	extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/epic-orchestrate/SKILL.md
7a21440358463eabc98f7a6c874e96a87be6d357
7a21440358463eabc98f7a6c874e96a87be6d357
c708d88dd34c984267f19e656c86d2ec1e2ef686
c708d88dd34c984267f19e656c86d2ec1e2ef686
```
