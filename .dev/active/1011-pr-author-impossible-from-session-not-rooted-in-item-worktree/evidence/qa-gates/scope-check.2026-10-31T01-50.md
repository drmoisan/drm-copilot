# Scope Check Against MERGE_BASE (Issue #1011, AC-09 and AC-18)

Timestamp: 2026-10-31T01-50
Command: sh SCRATCH/issue-1011-scope-check.sh (git fetch; MERGE_BASE = git merge-base origin/main HEAD; git diff --quiet MERGE_BASE per protected path; git diff --name-only MERGE_BASE -- .agents .github with git status --porcelain -- .agents .github; git diff --numstat MERGE_BASE; git diff --name-only MERGE_BASE with git status --porcelain; SCRATCH/issue-1011-function-compare.ps1)
EXIT_CODE: 0
Output Summary: no protected path changed; the only changed paths under `.agents/` and `.github/` are the two brief copies; every changed path is in the write set or the feature folder; FUNCTIONS_UNCHANGED: 2/2.

## git diff --quiet MERGE_BASE -- <path>

| Path | Exit code |
|---|---|
| `.claude/hooks/enforce-pr-author-skill.ps1` | 0 |
| `.claude/hooks/enforce-pr-author-skill.artifact-root.ps1` (holds `Resolve-PrAuthorArtifactRoot`, `Get-PrAuthorBodyPathBindingReason`) | 0 |
| `.claude/hooks/enforce-pr-author-skill.current-branch.ps1` (holds `Resolve-PrAuthorCurrentBranchTarget`) | 0 |
| `.claude/hooks/enforce-pr-author-skill.docs-only.ps1` (holds `Get-PrAuthorDocsOnlyExemption`) | 0 |
| `.claude/hooks/enforce-pr-author-skill.epic-base-branch.ps1` | 0 |
| `.claude/hooks/enforce-epic-merge-gate.ps1` | 0 |
| `.claude/lib/` (holds `Invoke-OrchestratorStatePreflight` and the resolver) | 0 |
| `.codex/` | 0 |
| `.github/agents/` | 0 |
| `.github/instructions/` | 0 |
| `.claude/rules/` | 0 |
| `extensions/drm-copilot/resources/claude-customizations/pack-manifests` | 0 |
| `extensions/drm-copilot/resources/codex-and-agents-customizations/pack-manifests` | 0 |
| `quality-tiers.yml` | 0 |

The two pack-manifests directories are the only ones under `extensions/drm-copilot/resources/` (from `git ls-files`).

## .agents and .github

`git diff --name-only MERGE_BASE -- .agents .github` together with `git status --porcelain -- .agents .github` (empty): `.agents/skills/execution-environment/SKILL.md`, `.github/skills/execution-environment/SKILL.md`.

## Brief copies (git diff --numstat MERGE_BASE)

One added and one deleted line (`1 1`) for each of `.claude/skills/execution-environment/SKILL.md`, `.agents/skills/execution-environment/SKILL.md`, `.github/skills/execution-environment/SKILL.md`, `extensions/drm-copilot/resources/claude-customizations/.claude/skills/execution-environment/SKILL.md`, `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/execution-environment/SKILL.md`, `extensions/drm-copilot/resources/customizations/.github/skills/execution-environment/SKILL.md`.

## Combined changed-file list (git diff --name-only MERGE_BASE plus git status --porcelain)

Write set:
- `.claude/hooks/enforce-pr-author-command-allowlist.ps1` and its BUNDLE copy
- `.claude/hooks/enforce-pr-author-skill-helpers.ps1` and its BUNDLE copy
- `.claude/agents/pr-author.md` and its BUNDLE copy
- `.claude/skills/pr-author/SKILL.md` and its BUNDLE copy
- `.claude/skills/orchestrate/SKILL.md` and its BUNDLE copy
- `tests/scripts/claude-hooks/enforce-pr-author-command-allowlist.Tests.ps1`
- `tests/scripts/claude-hooks/enforce-pr-author-skill.TargetResolution.Tests.ps1`
- `tests/scripts/claude-hooks/enforce-pr-author-skill.CurrentBranch.Tests.ps1`
- `tests/scripts/claude-hooks/enforce-pr-author-skill.WorktreeResolution.Tests.ps1`
- `tests/scripts/claude-runtime/pr-author-coordinator-topology-contract.Tests.ps1`
- the six execution-environment brief copies listed above

Feature folder and promoted record:
- `FEATURE/plan.2026-10-30T08-09.md`, `FEATURE/issue.md`, `FEATURE/spec.md`, `FEATURE/research/research.2026-10-30T12-20.md`, and evidence files under `FEATURE/evidence/` (baseline, other, qa-gates, regression-testing)
- `docs/features/potential/promoted/2026-10-30-pr-author-impossible-from-session-not-rooted-in-item-worktree.md`

No other path is changed.

## Function comparison (PowerShell AST, MERGE_BASE text versus current text of the helpers file)

- `Get-PrAuthorBypassReason`: EQUAL
- `Test-PrAuthorReceiptVerification`: EQUAL

FUNCTIONS_UNCHANGED: 2/2
