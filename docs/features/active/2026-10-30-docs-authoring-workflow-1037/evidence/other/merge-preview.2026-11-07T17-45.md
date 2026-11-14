# Merge Preview (remediation [P1-T1])

Timestamp: 2026-11-07T17-45
Command: sh SCRATCH/issue-1037-r-preview.sh (`git fetch origin`; `git merge-tree --write-tree --name-only HEAD origin/epic/documentation-estate-tooling-integration`; `git diff --name-only --no-renames BASE HEAD`; `git diff --name-only --no-renames BASE origin/epic/documentation-estate-tooling-integration`; `git status --porcelain --untracked-files=all`; `comm -12` of the two sorted lists; `grep -xF` of each named path in the base-side list)
EXIT_CODE: 0
Output Summary: Fetch exit 0. TIP is the fetched `origin/epic/documentation-estate-tooling-integration` (the expected tip of the delegation, unchanged since the review). HEAD is the Phase 0 commit on `feature/docs-authoring-workflow-1037-r2`. BASE is the merge base of TIP and HEAD (the merge base recorded in the remediation inputs). `git merge-tree` exit 1 with exactly one conflicted path: `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json` (content conflict); `extensions/drm-copilot/resources/codex-and-agents-customizations/pack-manifests/core.json` auto-merges. Branch file list: 194 paths. Base-side file list: 665 paths. Porcelain: empty (the Phase 0 evidence was committed before this task). Intersection of the two committed lists: 2 paths. No unplanned conflict; execution continues to [P1-T2].

## Conflict list

- `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json`

## Porcelain status at run time

Empty. The remediation files under `<FEATURE>/` written in Phase 0 were committed and pushed before this task under the per-phase commit rule of the delegation; no path outside `<FEATURE>/` was modified or untracked.

## Intersection with dispositions

| Path | Disposition | Gate task |
|---|---|---|
| `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json` | content conflict, resolved by keeping both entries | [P1-T2] (resolution checks); [P2-T5] `test_push_down_claude_pack_manifest_completeness.py` and `test_push_down_pack_manifest_dependency_closure.py`; [P2-T6] `claude-pack-manifest-completeness.test.ts` |
| `extensions/drm-copilot/resources/codex-and-agents-customizations/pack-manifests/core.json` | auto-merged | [P2-T3] Codex generator `--check`; [P2-T5] `test_push_down_codex_and_agents_pack_manifest_completeness.py` |

## Named paths checked against the base-side list

| Path | On the branch list | Changed on the base |
|---|---|---|
| `.claude/settings.json` | yes | no (unchanged on the base) |
| `extensions/drm-copilot/resources/claude-customizations/.claude/settings.json` | yes | no (unchanged on the base) |
| `config/orchestration-routing.json` | yes | no (unchanged on the base) |
| `extensions/drm-copilot/resources/config/orchestration-routing.json` | yes | no (unchanged on the base) |
| `extensions/drm-copilot/resources/claude-customizations/config/orchestration-routing.json` | yes | no (unchanged on the base) |
| `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json` | yes | yes (conflict, [P1-T2]) |
| `extensions/drm-copilot/resources/codex-and-agents-customizations/pack-manifests/core.json` | yes | yes (auto-merged, [P2-T3]) |
| Agent and skill mirror paths of main plan `## Artifact Classification` (120 branch paths matching `agents/docs-`, `skills/docs-` or `skills/documentation-workflow`) | yes | none of them (0 base-side matches) |
| `tests/scripts/claude-hooks/hook-dependency-failure.Claude.Tests.ps1` | yes | no (unchanged on the base) |
| `tests/scripts/claude-hooks/subagentstop-uncaught-error.Tests.ps1` | yes | no (unchanged on the base) |
| `tests/scripts/claude-hooks/cleanup-merged-worktrees-workflow.EndToEnd.Tests.ps1` | yes | no (unchanged on the base) |

The branch list (194 paths) is kept as SCRATCH/issue-1037-r-branch-p1t1.txt for the [P3-T1] comparison.
