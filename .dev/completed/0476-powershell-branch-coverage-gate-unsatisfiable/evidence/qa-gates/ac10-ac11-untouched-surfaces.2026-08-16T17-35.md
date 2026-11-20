# AC10 and AC11 — Coverage Hook and Copilot Surface Unmodified (Issue #476)

Timestamp: 2026-08-16T17-35

Command:
1. `git diff --name-only`
2. `git diff --name-only | grep -i "validate-feature-review-coverage"`
3. `git diff --name-only | grep "^\.github/"`

EXIT_CODE: 0 (check 1); 1 (checks 2 and 3, grep's no-match exit — the required outcome in both cases)

## Full Changed-File List (`git diff --name-only`)

```text
.agents/skills/general-unit-test/SKILL.md
.agents/skills/quality-tiers/SKILL.md
.claude/agents/feature-review.md
.claude/rules/general-unit-test.md
.claude/rules/powershell.md
.claude/rules/quality-tiers.md
.claude/skills/feature-review-workflow/SKILL.md
.claude/skills/powershell-qa-gate/SKILL.md
README.md
extensions/drm-copilot/resources/claude-customizations/.claude/agents/feature-review.md
extensions/drm-copilot/resources/claude-customizations/.claude/rules/general-unit-test.md
extensions/drm-copilot/resources/claude-customizations/.claude/rules/powershell.md
extensions/drm-copilot/resources/claude-customizations/.claude/rules/quality-tiers.md
extensions/drm-copilot/resources/claude-customizations/.claude/skills/feature-review-workflow/SKILL.md
extensions/drm-copilot/resources/claude-customizations/.claude/skills/powershell-qa-gate/SKILL.md
extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/general-unit-test/SKILL.md
extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/quality-tiers/SKILL.md
```

17 entries.

## AC10 — Coverage Hook Unmodified

Filtering the changed-file list for `validate-feature-review-coverage` returns no rows (exit code 1). Neither of the following appears:

- `.claude/hooks/validate-feature-review-coverage.ps1`
- `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/validate-feature-review-coverage.ps1`

The hook's existing behavior — `Get-JacocoBranchCoverage` returning `$null` when a coverage report carries zero `BRANCH` counters, and the 75% floor check being skipped on a null value — is therefore intact and unaltered. This change aligns the prose policy to that behavior rather than modifying it. The hook's Pester suite `tests/scripts/claude-hooks/validate-feature-review-coverage.Tests.ps1` is likewise absent from the changed-file list.

## AC11 — Copilot Surface Unmodified

Filtering the changed-file list for the `^\.github/` prefix returns no rows (exit code 1). No workflow, instruction file, prompt, or other artifact under `.github/**` was modified. This matches the research finding that the Copilot surface never carried a branch-coverage threshold and therefore required no edit.

## Untracked Files

`git status --porcelain` reports a single untracked entry:

```text
?? docs/features/active/2026-08-16-powershell-branch-coverage-gate-unsatisfiable-476/
```

That is this feature's own documentation and evidence folder. It contains no hook, no `.github/**` path, and no file within the closed edit surface.

Output Summary: PASS on both criteria. `.claude/hooks/validate-feature-review-coverage.ps1` and its bundle mirror show zero matches in the changed-file list, and no path under `.github/` shows any match. The 17 changed files are exactly the closed edit surface.
