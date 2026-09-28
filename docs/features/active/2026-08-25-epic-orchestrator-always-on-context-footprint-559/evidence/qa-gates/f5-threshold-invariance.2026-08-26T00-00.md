# F5 Threshold-and-Stage-Count Invariance Guard

Timestamp: 2026-08-26T00-00

Command:

```
git diff HEAD --exit-code -- .claude/rules/general-unit-test.md .claude/rules/quality-tiers.md .claude/rules/general-code-change.md .claude/rules/python.md .claude/rules/typescript.md .claude/rules/powershell.md .claude/rules/shell.md .claude/skills/feature-review-workflow/SKILL.md .claude/skills/python-qa-gate/SKILL.md .claude/skills/powershell-qa-gate/SKILL.md AGENTS.md .github/instructions/ extensions/drm-copilot/resources/claude-customizations/.claude/rules/general-unit-test.md extensions/drm-copilot/resources/claude-customizations/.claude/rules/quality-tiers.md extensions/drm-copilot/resources/claude-customizations/.claude/rules/general-code-change.md extensions/drm-copilot/resources/claude-customizations/.claude/rules/python.md extensions/drm-copilot/resources/claude-customizations/.claude/rules/typescript.md extensions/drm-copilot/resources/claude-customizations/.claude/rules/powershell.md extensions/drm-copilot/resources/claude-customizations/.claude/rules/shell.md extensions/drm-copilot/resources/claude-customizations/.claude/skills/python-qa-gate/SKILL.md extensions/drm-copilot/resources/claude-customizations/.claude/skills/powershell-qa-gate/SKILL.md
```

EXIT_CODE: 0

ExpectedExitCode: 0

Output Summary: The command produced zero bytes of output and exited 0. No file in the
enumerated set differs from `HEAD`. No coverage threshold value and no toolchain stage count
in the enumerated set was altered by this change. `AGENTS.md` is unmodified and no file under
`.github/instructions/` is modified.

The `HEAD` operand was used deliberately. A bare `git diff` compares the worktree against the
index and reads as falsely clean once a change is staged, which on this guard in particular
would report the F5 reservation intact when it had been violated.

## Pathspec resolution — the guard is not vacuous

`git ls-files` over the same pathspec resolves to 37 tracked files: the 20 named file operands
plus the 17 tracked files under the `.github/instructions/` directory operand.

Named file operands (20, all tracked):

- `.claude/rules/general-unit-test.md`
- `.claude/rules/quality-tiers.md`
- `.claude/rules/general-code-change.md`
- `.claude/rules/python.md`
- `.claude/rules/typescript.md`
- `.claude/rules/powershell.md`
- `.claude/rules/shell.md`
- `.claude/skills/feature-review-workflow/SKILL.md`
- `.claude/skills/python-qa-gate/SKILL.md`
- `.claude/skills/powershell-qa-gate/SKILL.md`
- `AGENTS.md`
- `extensions/drm-copilot/resources/claude-customizations/.claude/rules/general-unit-test.md`
- `extensions/drm-copilot/resources/claude-customizations/.claude/rules/quality-tiers.md`
- `extensions/drm-copilot/resources/claude-customizations/.claude/rules/general-code-change.md`
- `extensions/drm-copilot/resources/claude-customizations/.claude/rules/python.md`
- `extensions/drm-copilot/resources/claude-customizations/.claude/rules/typescript.md`
- `extensions/drm-copilot/resources/claude-customizations/.claude/rules/powershell.md`
- `extensions/drm-copilot/resources/claude-customizations/.claude/rules/shell.md`
- `extensions/drm-copilot/resources/claude-customizations/.claude/skills/python-qa-gate/SKILL.md`
- `extensions/drm-copilot/resources/claude-customizations/.claude/skills/powershell-qa-gate/SKILL.md`

Directory operand `.github/instructions/` resolves to 17 tracked files:
`csharp-code-change`, `csharp-unit-test`, `general-code-change`, `general-unit-test`,
`github-actions-ci-cd-best-practices`, `github-actions`, `mermaid`,
`powershell-code-change`, `powershell-unit-test`, `python-code-change`,
`python-suppressions`, `python-unit-test`, `self-explanatory-code-commenting`, `tonality`,
`typescript-code-change`, `typescript-suppressions`, and `typescript-unit-test`
`.instructions.md` files.

## Scope note

This is an enumeration, not a completeness assertion. No claim is made that the repository
contains no other file stating a coverage threshold or a toolchain stage count. The six
additions beyond the original nine, and their bundled mirrors, are `.claude/rules/python.md`
(lines 16, 88, 89), `.claude/rules/typescript.md` (line 50), `.claude/rules/powershell.md`
(lines 63, 64), `.claude/rules/shell.md` (lines 28, 68),
`.claude/skills/python-qa-gate/SKILL.md` (line 46), and
`.claude/skills/powershell-qa-gate/SKILL.md` (line 45).
