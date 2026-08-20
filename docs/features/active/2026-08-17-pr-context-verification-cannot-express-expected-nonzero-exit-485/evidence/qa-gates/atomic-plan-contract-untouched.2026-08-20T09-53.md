# Gate — atomic-plan-contract skill and its fan-out are unmodified

Timestamp: 2026-08-20T09-53

Task: [P6-T8]

Command: git diff --numstat 71aebdb9a1e4752b191b3c9d4e677b807ea6fdec -- "*atomic-plan-contract/SKILL.md"
EXIT_CODE: 0

## Result — no output, therefore zero changed files

The numstat command produced NO output. Because a numstat run emits one row per changed path and
never emits a row for an unchanged path, empty output means zero of the matched files changed. The
command itself exits `0` whether or not it finds changes, so the discriminating signal here is the
absence of rows, not the exit code.

The six paths the pathspec matches, enumerated from the index so the gate's scope is auditable rather
than assumed:

1. `.agents/skills/atomic-plan-contract/SKILL.md`
2. `.claude/skills/atomic-plan-contract/SKILL.md`
3. `.github/skills/atomic-plan-contract/SKILL.md`
4. `extensions/drm-copilot/resources/claude-customizations/.claude/skills/atomic-plan-contract/SKILL.md`
5. `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/atomic-plan-contract/SKILL.md`
6. `extensions/drm-copilot/resources/customizations/.github/skills/atomic-plan-contract/SKILL.md`

None of the six appears in the diff. This is the expected outcome: the new evidence key is OPTIONAL,
so the "MUST include" required-field lists in that skill (`spec.md` cites lines 34, 45, 87, 102) do
not change, and its own six-copy fan-out is untouched. The literal `EXIT_CODE: SKIPPED` constraint
that skill states is likewise preserved in behavior, verified separately by the Invariant F tests
(`test_skipped_exit_code_remains_unparseable` and its TypeScript counterpart).

Output Summary: Zero changed files across all six copies of `atomic-plan-contract/SKILL.md`. The
numstat command produced empty output, which is how an unchanged pathspec is represented; the six
matched paths are enumerated above so the absence claim is auditable.
