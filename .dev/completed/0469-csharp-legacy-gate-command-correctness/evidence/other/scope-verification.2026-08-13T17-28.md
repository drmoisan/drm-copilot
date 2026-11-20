# AC13 Diff-Scope Verification (Issue #469)

Timestamp: 2026-08-13T17-28

Command:
```
git diff --name-only fe0413d4aca1e76b2d02d05701fba79a887d5405..HEAD
git status --porcelain
git status --porcelain -- .claude/rules/csharp.md .claude/skills/csharp-qa-gate/SKILL.md \
  .agents/skills/csharp/SKILL.md .agents/skills/csharp-qa-gate/SKILL.md \
  extensions/drm-copilot/resources/claude-customizations/.claude/rules/csharp.md \
  extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/csharp/SKILL.md
```

EXIT_CODE: 0

Output Summary:

`git diff --name-only fe0413d4..HEAD` returned an empty set: `HEAD` is still the Phase 0 baseline commit `fe0413d4aca1e76b2d02d05701fba79a887d5405`, because this executor performs no Git write operation. The complete change set is therefore the working-tree state reported by `git status --porcelain`.

## Changed files (9 modified)

Four `csharp-legacy` variant sources:
1. `extensions/drm-copilot/resources/claude-customizations/.claude-variants/csharp-legacy/rules/csharp.md`
2. `extensions/drm-copilot/resources/claude-customizations/.claude-variants/csharp-legacy/skills/csharp-qa-gate/SKILL.md`
3. `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents-variants/csharp-legacy/skills/csharp/SKILL.md`
4. `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents-variants/csharp-legacy/skills/csharp-qa-gate/SKILL.md`

Documentation:
5. `README.md` (the "Legacy VSTO C# (.NET Framework)" section only)

Four Python test files named in Phases 1 and 3:
6. `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py`
7. `tests/scripts/dev_tools/test_push_down_codex_and_agents_resource_contracts.py`
8. `tests/scripts/dev_tools/test_push_down_claude_pack_end_to_end.py`
9. `tests/scripts/dev_tools/test_push_down_codex_and_agents_customizations.py`

## Untracked paths (2)

- `docs/features/active/2026-08-13-csharp-legacy-gate-command-correctness-469/` — this feature's own docs and evidence (`issue.md`, `spec.md`, the plan, `research/`, `evidence/`).
- `docs/features/potential/2026-08-13-codex-default-csharp-slot-carries-legacy-content.md` — the out-of-scope follow-up record for the pre-existing Codex default-slot defect. It is authored by requirements work for this issue and is referenced by `spec.md` (Scope & Non-Goals, item 3) and by plan tasks [P5-T4] and Normative Content Contract rule 1. It is a documentation record, not a code or resource change.

## Prohibited-path scan

A `git status --porcelain` filter for `packages/mcp-server/resources/`, `.github/`, `parallel`, `.agents/skills/csharp*`, `.claude/rules/csharp.md`, and `.claude/skills/csharp-qa-gate` returned **no matches**. Specifically:

- Nothing under `packages/mcp-server/resources/**` is modified.
- No modern/default C# profile file on either surface is modified (root `.claude/rules/csharp.md`, root `.claude/skills/csharp-qa-gate/SKILL.md`, and their bundle mirrors are all clean).
- No Codex/Agents default-slot file (`.agents/skills/csharp/SKILL.md`, `.agents/skills/csharp-qa-gate/SKILL.md`) is modified.
- No parallel-orchestration resource is modified.
- Nothing under `.github/**` is modified.

Result: the changed set matches the AC13 expectation exactly, with zero out-of-scope paths.
