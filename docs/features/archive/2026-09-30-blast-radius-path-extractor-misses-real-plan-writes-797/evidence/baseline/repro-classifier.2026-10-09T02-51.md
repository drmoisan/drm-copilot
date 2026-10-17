# Baseline Reproduction (P0-T5, AC-1)

Timestamp: 2026-10-09T02-51
Command: poetry run python -c "from scripts.dev_tools._blast_radius_extraction import classify_path_token as c; [print(t, c(t)) for t in ['tests/shell/foo.bats','extensions/drm-copilot/jest.config.cjs','tests/out/run.out','.agents/skills/x/refs/foo.bats','.claude/lib/x/.shellcheckrc','Sample.*','tests/fixtures/Sample.*','.agents/skills/x/SKILL.md','tests/Sample.cs']]"
EXIT_CODE: 0
Output Summary: nine lines, identical to FL-5 in order. The five file tokens tests/shell/foo.bats, extensions/drm-copilot/jest.config.cjs, tests/out/run.out, .agents/skills/x/refs/foo.bats, and .claude/lib/x/.shellcheckrc classify as None on the unmodified branch.

## Output (verbatim)

```text
tests/shell/foo.bats None
extensions/drm-copilot/jest.config.cjs None
tests/out/run.out None
.agents/skills/x/refs/foo.bats None
.claude/lib/x/.shellcheckrc None
Sample.* None
tests/fixtures/Sample.* glob
.agents/skills/x/SKILL.md concrete
tests/Sample.cs concrete
```
