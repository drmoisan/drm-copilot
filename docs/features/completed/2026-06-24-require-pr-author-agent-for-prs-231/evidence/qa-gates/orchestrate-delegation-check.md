# Orchestrate Skill Mandatory Delegation Check (AC6)

- Timestamp: 2026-06-24T16-45
- Issue: #231

## Root: `.claude/skills/orchestrate/SKILL.md`

The `## PR Creation Delegation` section (line 68) contains the mandatory delegation language:

> The orchestrator MUST NOT call `gh pr create` or `gh pr edit --body*` directly from the main thread; the `enforce-pr-author-skill.ps1` PreToolUse hook blocks those commands unless a valid authorization sentinel issued by the `pr-author` agent is present.

> `Agent(pr-author)` is the mandatory delegate for PR creation and PR body edits. Direct `gh pr create`/`gh pr edit --body*` from the main thread is prohibited and is blocked by the hook.

The mandatory sequence requires first producing the PR-context artifact via `mcp__drm-copilot__collect_pr_context`, then delegating to `Agent(pr-author)`.

## Bundled: `extensions/drm-copilot/resources/claude-customizations/.claude/skills/orchestrate/SKILL.md`

The bundled orchestrate skill is byte-identical to the root copy (sha256 `1e0c39729872ed8f2ec4c43f3779abc910bc127d68ef642621ae7dc9687bb4da`, verified in cross-ecosystem-equality.md), so it contains the same `## PR Creation Delegation` section and the same mandatory delegation language quoted above.

## Conclusion

Both root and bundled orchestrate skills mandate delegation to `Agent(pr-author)` for PR creation and prohibit direct `gh pr create` from the main thread. AC6 satisfied.
