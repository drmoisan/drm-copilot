# AC14 — Edit Surface Closed at 17 Files (Issue #476)

Timestamp: 2026-08-16T17-39

Command:
1. `git diff --name-only 687380a6` (base `main`)
2. `git diff --name-only 687380a6 | wc -l`
3. `git status --porcelain --untracked-files=all` filtered to exclude this feature's own folder

EXIT_CODE: 0

## Reconciliation Against the Closed 17-File List

`COUNT=17`. Every entry in the spec's enumerated edit surface appears exactly once, and no entry appears that is not enumerated.

| # | Enumerated file | Present in `git diff --name-only 687380a6`? | Category |
| --- | --- | --- | --- |
| 1 | `.claude/rules/powershell.md` | YES | root, Claude surface |
| 2 | `.claude/rules/general-unit-test.md` | YES | root, Claude surface |
| 3 | `.claude/rules/quality-tiers.md` | YES | root, Claude surface |
| 4 | `.claude/skills/feature-review-workflow/SKILL.md` | YES | root, Claude surface |
| 5 | `.claude/agents/feature-review.md` | YES | root, Claude surface |
| 6 | `.claude/skills/powershell-qa-gate/SKILL.md` | YES | root, Claude surface |
| 7 | `.agents/skills/general-unit-test/SKILL.md` | YES | root, Codex surface |
| 8 | `.agents/skills/quality-tiers/SKILL.md` | YES | root, Codex surface |
| 9 | `extensions/.../claude-customizations/.claude/rules/powershell.md` | YES | bundle mirror of 1 |
| 10 | `extensions/.../claude-customizations/.claude/rules/general-unit-test.md` | YES | bundle mirror of 2 |
| 11 | `extensions/.../claude-customizations/.claude/rules/quality-tiers.md` | YES | bundle mirror of 3 |
| 12 | `extensions/.../claude-customizations/.claude/skills/feature-review-workflow/SKILL.md` | YES | bundle mirror of 4 |
| 13 | `extensions/.../claude-customizations/.claude/agents/feature-review.md` | YES | bundle mirror of 5 |
| 14 | `extensions/.../claude-customizations/.claude/skills/powershell-qa-gate/SKILL.md` | YES | bundle mirror of 6 |
| 15 | `extensions/.../codex-and-agents-customizations/.agents/skills/general-unit-test/SKILL.md` | YES | bundle mirror of 7 |
| 16 | `extensions/.../codex-and-agents-customizations/.agents/skills/quality-tiers/SKILL.md` | YES | bundle mirror of 8 |
| 17 | `README.md` | YES | non-shipped consistency edit, no mirror |

**Enumerated files present: 17 of 17. Files present but not enumerated: 0.**

## Category Exclusions Confirmed

Reading the same 17-entry list, none of the following categories is represented:

| Prohibited category | Entries in the changed-file list |
| --- | --- |
| Hook (`.claude/hooks/**` or its mirror) | 0 |
| `.github/**` (workflows, instructions, prompts) | 0 |
| Script (`scripts/**`) | 0 |
| Test (`tests/**`, `extensions/drm-copilot/test/**`) | 0 |
| Configuration (`*.json`, `*.psd1`, `*.yml`, `*.toml`, `*.cjs`) | 0 |
| Extension TypeScript source (`extensions/drm-copilot/src/**`) | 0 |
| Pack manifests | 0 |
| `.claude/rules/shell.md` or its mirror | 0 |
| `.claude/rules/python.md`, `typescript.md`, `csharp.md` or their mirrors | 0 |

Every changed file has the `.md` extension; the change set is Markdown-only, as the plan's Phase 5 preamble asserts.

## Untracked Files

`git status --porcelain --untracked-files=all`, with this feature's own folder filtered out, produces only the 17 ` M ` (modified) rows shown above and no `??` (untracked) row. The single untracked entry in the unfiltered output is:

```text
?? docs/features/active/2026-08-16-powershell-branch-coverage-gate-unsatisfiable-476/
```

That folder holds this feature's `spec.md`, `issue.md`, `plan.2026-08-16T16-36.md`, `research/`, and `evidence/` artifacts. It is feature documentation, expressly permitted alongside the 17-file edit surface.

Build outputs generated during Phase 0 baseline capture — `artifacts/python/lcov.info` from the pytest coverage run and `extensions/drm-copilot/node_modules/` from `npm ci` — do not appear in either listing because both paths are gitignored. Neither is a tracked file and neither is part of the change set.

Output Summary: PASS. `git diff --name-only` against base `main` at `687380a6` returns exactly 17 files, matching the enumerated closed edit surface one-for-one with no additions and no omissions. No hook, script, test, configuration, or `.github/**` file changed. The only untracked path is this feature's own documentation and evidence folder.
