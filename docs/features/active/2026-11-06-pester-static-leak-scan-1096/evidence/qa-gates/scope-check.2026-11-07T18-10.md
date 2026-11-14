# QA Gate: Scope, History, Scan-Text, and Evidence Check (Remediation Cycle 2)

Timestamp: 2026-11-07T18-10
Command: sh SCRATCH/issue-1096-c2-scope.sh (git fetch origin through -C, then pwsh SCRATCH/issue-1096-c2-scope.ps1 -Root <item worktree>: git diff --name-status --no-renames from the merge base of origin/main and HEAD with git status --porcelain as companion; the poshqc-linux-hooks job text against the merge base; the reduction-commit scan-text rule; the host-path and run-citation scan of <FEATURE>/evidence/; git merge-base --is-ancestor origin/main HEAD; the cycle 2 merge-commit and reduction-token rules; exits 1 on any violation)
EXIT_CODE: 1
Output Summary: FAILED on the history rule only: `origin/main` advanced after the P0-T1 fetch (48 commits, ending with the merge of PR #1113, issue #1105), so `git merge-base --is-ancestor origin/main HEAD` exits 1. Every other rule passed: no added `.py` file and no forbidden path; `poshqc-linux-hooks` job text equal to the merge base; 3 `reduction: 0001` commits on the branch, each with 0 scan-text lines outside the entry and `<FEATURE>/evidence/`; 94 evidence files with no host path and no run citation; the cycle 2 merge commit has 2 parents and no reduction token; 0 cycle 2 commits carry the reduction token. Per P2-T6 (`Ancestry failure`) and the delegation rules, the task stays unchecked and the executor stops for the orchestrator; no second merge was made.

## Scope

- DIFF-ENTRIES=164, PORCELAIN-ENTRIES=0
- No added `.py` file; no path under `.claude/rules/`, `.github/instructions/`, an `atomic-plan-contract` copy, `.claude/agents/epic-orchestrator.md`, `.claude/skills/epic-orchestrate/SKILL.md`, ledger entries 0002 to 0006, an Epic #1019 folder, `.github/workflows/ci.yml`, or `pyproject.toml`
- `addopts` carries no `-n`
- `poshqc-linux-hooks` job text equal to the merge base: True

## Scan-Text Rule (spec AC-29)

| `reduction: 0001` commit (subject) | Added lines outside the entry | Excluded under `<FEATURE>/evidence/` | Scan-text lines in remaining paths |
|---|---|---|---|
| docs(process-reductions): reconcile entry 0001 with the main merge (reduction: 0001) | 104 | 68 | 0 |
| test(atomic-executor): document the reduction test fakes and correct their fences, reduction: 0001 | 6 | 0 | 0 |
| refactor(qc): move the deferred serial test commands to the parallel gates, reduction: 0001 | 190 | 0 | 0 |

## Evidence

- 94 files under `<FEATURE>/evidence/` scanned case-insensitively with tokens assembled at run time: 0 host paths, 0 run citations outside the name fields of failure rows.

## History

- Cycle 2 merge commits: 1; parents 2; reduction token: False
- Cycle 2 commits carrying `reduction: 0001`: 0 (P1-T2 changed no fence)
- `git merge-base --is-ancestor origin/main HEAD`: EXIT 1 (FAIL)

HISTORY-FAIL: origin/main is not an ancestor of HEAD

`origin/main` now ends at the merge of PR #1113 (issue #1105). It holds 48 commits that HEAD lacks. It changed 106 paths since the merge base; 47 are under `docs/features/` (the issue #1105 feature folder and its promoted record), and the other 59 are:

- `M` `.agents/skills/execution-environment/SKILL.md`
- `A` `.claude/hooks/subagentstop-target-worktree.ps1`
- `M` `.claude/hooks/validate-executor-output.ps1`
- `A` `.claude/hooks/validate-feature-review-coverage-freshness.ps1`
- `M` `.claude/hooks/validate-feature-review-coverage-metrics.ps1`
- `M` `.claude/hooks/validate-feature-review-coverage-rules.ps1`
- `M` `.claude/hooks/validate-feature-review-coverage.ps1`
- `M` `.claude/hooks/validate-planner-output.ps1`
- `M` `.claude/hooks/validate-prd-feature-output.ps1`
- `M` `.claude/hooks/validate-required-artifact-output.ps1`
- `M` `.claude/hooks/validate-task-researcher-output.ps1`
- `M` `.claude/skills/execution-environment/SKILL.md`
- `M` `.github/skills/execution-environment/SKILL.md`
- `A` `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/subagentstop-target-worktree.ps1`
- `M` `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/validate-executor-output.ps1`
- `A` `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/validate-feature-review-coverage-freshness.ps1`
- `M` `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/validate-feature-review-coverage-metrics.ps1`
- `M` `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/validate-feature-review-coverage-rules.ps1`
- `M` `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/validate-feature-review-coverage.ps1`
- `M` `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/validate-planner-output.ps1`
- `M` `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/validate-prd-feature-output.ps1`
- `M` `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/validate-required-artifact-output.ps1`
- `M` `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/validate-task-researcher-output.ps1`
- `M` `extensions/drm-copilot/resources/claude-customizations/.claude/skills/execution-environment/SKILL.md`
- `M` `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json`
- `M` `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/execution-environment/SKILL.md`
- `M` `extensions/drm-copilot/resources/customizations/.github/skills/execution-environment/SKILL.md`
- `A` `tests/scripts/claude-hooks/subagentstop-target-worktree.Tests.ps1`
- `M` `tests/scripts/claude-hooks/validate-executor-output.Envelope.Tests.ps1`
- `M` `tests/scripts/claude-hooks/validate-executor-output.LightRemediation.Tests.ps1`
- `M` `tests/scripts/claude-hooks/validate-executor-output.Preflight.Tests.ps1`
- `M` `tests/scripts/claude-hooks/validate-executor-output.Reentry.Tests.ps1`
- `A` `tests/scripts/claude-hooks/validate-executor-output.TargetWorktree.Tests.ps1`
- `M` `tests/scripts/claude-hooks/validate-executor-output.Tests.ps1`
- `A` `tests/scripts/claude-hooks/validate-feature-review-coverage-freshness.Tests.ps1`
- `M` `tests/scripts/claude-hooks/validate-feature-review-coverage.Coverage.Tests.ps1`
- `M` `tests/scripts/claude-hooks/validate-feature-review-coverage.Issue824.Tests.ps1`
- `A` `tests/scripts/claude-hooks/validate-feature-review-coverage.TargetWorktree.Tests.ps1`
- `M` `tests/scripts/claude-hooks/validate-feature-review-coverage.Tests.ps1`
- `M` `tests/scripts/claude-hooks/validate-feature-review-coverage.ThresholdsGuard.Tests.ps1`
- `M` `tests/scripts/claude-hooks/validate-planner-output.Coverage.Tests.ps1`
- `M` `tests/scripts/claude-hooks/validate-planner-output.PreMortem.Tests.ps1`
- `M` `tests/scripts/claude-hooks/validate-planner-output.Reentry.Tests.ps1`
- `A` `tests/scripts/claude-hooks/validate-planner-output.TargetWorktree.Tests.ps1`
- `M` `tests/scripts/claude-hooks/validate-planner-output.Tests.ps1`
- `M` `tests/scripts/claude-hooks/validate-prd-feature-output.Coverage.Tests.ps1`
- `A` `tests/scripts/claude-hooks/validate-prd-feature-output.TargetWorktree.Tests.ps1`
- `M` `tests/scripts/claude-hooks/validate-prd-feature-output.Tests.ps1`
- `M` `tests/scripts/claude-hooks/validate-required-artifact-output.Envelope.Tests.ps1`
- `M` `tests/scripts/claude-hooks/validate-required-artifact-output.Reentry.Tests.ps1`
- `A` `tests/scripts/claude-hooks/validate-required-artifact-output.TargetWorktree.Tests.ps1`
- `M` `tests/scripts/claude-hooks/validate-required-artifact-output.Tests.ps1`
- `M` `tests/scripts/claude-hooks/validate-task-researcher-output.Coverage.Tests.ps1`
- `M` `tests/scripts/claude-hooks/validate-task-researcher-output.PreMortem.Tests.ps1`
- `A` `tests/scripts/claude-hooks/validate-task-researcher-output.TargetWorktree.Tests.ps1`
- `M` `tests/scripts/claude-hooks/validate-task-researcher-output.Tests.ps1`
- `M` `tests/scripts/codex-hooks/feature-review-coverage-floor-parity.Tests.ps1`
- `M` `tests/scripts/codex-hooks/feature-review-coverage-narrowing-parity.Tests.ps1`
- `M` `tests/scripts/codex-hooks/validate-feature-review-coverage.Coverage.Tests.ps1`

## Read-Only Trial Merge (for the orchestrator)

`git merge-tree --write-tree HEAD origin/main` through -C exits 0 and reports no conflicted path. In the trial tree the six `execution-environment` copies share one blob, and the `Invoke-PoshQCLeakScan` bullet is still the last bullet of `## Test Isolation Checks`. The merge would change the six brief copies, which are in this branch's diff, so under P2-T6 the Phase 2 loop restarts from P2-T1 after the orchestrator's merge, before this task re-runs.
