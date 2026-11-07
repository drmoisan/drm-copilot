# 0006: Test-suite baseline restored

## Summary

reduction: 0006
Date: 2026-11-07
Issue: #1097
Merge commit: pending (PR #1110)

Partially reverts entry `0001`: the Phase 0 test-suite baseline returns as one run of each parallel gate (one `Invoke-PoshQCParallelTest`, one `pytest -n auto` with coverage, and one Jest coverage run where TypeScript is in scope), the `Phase 0 baseline`, and the final gate is compared with it: no new failing test, no per-file or repo-wide coverage drop, the thresholds still apply, and new behavior is tested. Every parallel-only rule of `0001` stays. A plan written before this rule that captures static baselines only stays valid, and its audit records `N/A - no pre-change run`. Until the pull request exists, the `Merge commit:` line carries the canonical issue number as a stand-in, and the orchestrator replaces it with the pull request number right after PR creation.

## Reason and Evidence

The owner decided on 2026-11-07 to restore the test-suite baseline and the final-gate comparison against it while keeping the parallel-only change of `0001`. The restored parts are B1 to B11 of the stage E2 plan (`docs/features/active/reduce-feature-cycle-time-with-revertible-ledger-1097/plan.2026-11-07T08-41.md`, `## Design`), derived hunk by hunk from `patches/0001-parallel-only-test-gates.patch` in `docs/features/active/reduce-feature-cycle-time-with-revertible-ledger-1097/evidence/other/stage-e2-baseline-inventory.*.md`: the contract's Phase 0 baseline, coverage evidence, and minor-audit gates (B1 to B3), the brief's coverage bullet (B4), the policy-audit template and its instructions (B5, B6), the review rules (B7), the QA gates (B8), the planner, executor, and engineer surfaces (B9), the Copilot family (B10), and the plan templates (B11).

Kept from `0001`: one `Invoke-PoshQCParallelTest` run and one `pytest -n auto` run per gate, Jest through its normal workers, each re-run only after a fix, `## Test Isolation Checks` unchanged, and no serial, single-process, seeded-shuffle, reversed-order, targeted, per-batch, or comparison run. Where a restored sentence named a run shape, it names the one parallel run instead.

Record decision: the partial revert is a new entry rather than a deletion of `0001`, so that reverting this entry re-applies the reduction. `0001` gains a `## Partial Revert` section and its index Status reads `Partially reverted by 0006`. No hook or validator changes: the review hooks keep accepting `N/A - no pre-change run`, which remains the record for a new file and for plans written before this rule. Measured Phase 0 cost of this stage's own baseline runs: `Invoke-PoshQCParallelTest` 429.61 s wall-clock on 8 workers, `pytest -n auto` 174.08 s, Jest about 10 s.

Rebased over PR #1108 (issue #1106): after `main` merged PR #1108, which renamed the C# test framework to MSTest and the Pester version to Pester v6 in twelve of these paths, the patch was regenerated so that it diffs from the 0001-state text carrying PR #1108's wording to the current text. The hunks are unchanged apart from those renames.

## Files Changed

The list covers every path of the stored patch, with rename detection off.

- `.agents/skills/atomic-plan-contract/SKILL.md`: canonical, with revert blocks below
- `.agents/skills/atomic-planner/SKILL.md`: canonical
- `.agents/skills/csharp-qa-gate/SKILL.md`: canonical
- `.agents/skills/evidence-and-timestamp-conventions/SKILL.md`: canonical
- `.agents/skills/execution-environment/SKILL.md`: canonical
- `.agents/skills/feature-review-workflow/SKILL.md`: canonical
- `.agents/skills/invoke-csharp-engineer/SKILL.md`: canonical
- `.agents/skills/invoke-powershell-engineer/SKILL.md`: canonical
- `.agents/skills/invoke-python-engineer/SKILL.md`: canonical
- `.agents/skills/orchestrator-workflow/SKILL.md`: canonical
- `.agents/skills/powershell-qa-gate/SKILL.md`: canonical
- `.agents/skills/python-qa-gate/SKILL.md`: canonical
- `.claude/agents/atomic-executor.md`: canonical
- `.claude/agents/atomic-planner.md`: canonical
- `.claude/agents/csharp-typed-engineer.md`: canonical
- `.claude/agents/feature-review.md`: canonical
- `.claude/agents/powershell-typed-engineer.md`: canonical
- `.claude/agents/python-typed-engineer.md`: canonical
- `.claude/skills/atomic-plan-contract/SKILL.md`: canonical, with revert blocks below
- `.claude/skills/csharp-qa-gate/SKILL.md`: canonical
- `.claude/skills/evidence-and-timestamp-conventions/SKILL.md`: canonical
- `.claude/skills/execution-environment/SKILL.md`: canonical, with revert blocks below
- `.claude/skills/feature-review-workflow/SKILL.md`: canonical
- `.claude/skills/invoke-csharp-engineer/SKILL.md`: canonical
- `.claude/skills/invoke-powershell-engineer/SKILL.md`: canonical
- `.claude/skills/invoke-python-engineer/SKILL.md`: canonical
- `.claude/skills/powershell-qa-gate/SKILL.md`: canonical
- `.claude/skills/python-qa-gate/SKILL.md`: canonical
- `.claude/skills/remediation-handoff-atomic-planner/SKILL.md`: canonical
- `.codex/agents/atomic-executor-c1.toml`: generated variant
- `.codex/agents/atomic-executor-c2.toml`: generated variant
- `.codex/agents/atomic-executor-c3-elevated.toml`: generated variant
- `.codex/agents/atomic-executor-c3.toml`: generated variant
- `.codex/agents/atomic-executor-c4.toml`: generated variant
- `.codex/agents/atomic-executor.toml`: hand-edited Codex agent
- `.codex/agents/atomic-planner-c1.toml`: generated variant
- `.codex/agents/atomic-planner-c2.toml`: generated variant
- `.codex/agents/atomic-planner-c3-elevated.toml`: generated variant
- `.codex/agents/atomic-planner-c3.toml`: generated variant
- `.codex/agents/atomic-planner-c4.toml`: generated variant
- `.codex/agents/atomic-planner.toml`: hand-edited Codex agent
- `.codex/agents/csharp-atomic-executor.toml`: hand-edited Codex agent
- `.codex/agents/csharp-atomic-planning.toml`: hand-edited Codex agent
- `.codex/agents/csharp-orchestrator.toml`: hand-edited Codex agent
- `.codex/agents/csharp-typed-engineer-c1.toml`: generated variant
- `.codex/agents/csharp-typed-engineer-c2.toml`: generated variant
- `.codex/agents/csharp-typed-engineer-c3-elevated.toml`: generated variant
- `.codex/agents/csharp-typed-engineer-c3.toml`: generated variant
- `.codex/agents/csharp-typed-engineer-c4.toml`: generated variant
- `.codex/agents/csharp-typed-engineer.toml`: hand-edited Codex agent
- `.codex/agents/feature-review.toml`: hand-edited Codex agent
- `.codex/agents/powershell-atomic-executor.toml`: hand-edited Codex agent
- `.codex/agents/powershell-atomic-planning.toml`: hand-edited Codex agent
- `.codex/agents/powershell-di-unit-test-engineer.toml`: hand-edited Codex agent
- `.codex/agents/powershell-orchestrator.toml`: hand-edited Codex agent
- `.codex/agents/powershell-typed-engineer-c1.toml`: generated variant
- `.codex/agents/powershell-typed-engineer-c2.toml`: generated variant
- `.codex/agents/powershell-typed-engineer-c3-elevated.toml`: generated variant
- `.codex/agents/powershell-typed-engineer-c3.toml`: generated variant
- `.codex/agents/powershell-typed-engineer-c4.toml`: generated variant
- `.codex/agents/powershell-typed-engineer.toml`: hand-edited Codex agent
- `.codex/agents/python-atomic-executor.toml`: hand-edited Codex agent
- `.codex/agents/python-atomic-planning.toml`: hand-edited Codex agent
- `.codex/agents/python-execution-only-typed.toml`: hand-edited Codex agent
- `.codex/agents/python-orchestrator.toml`: hand-edited Codex agent
- `.codex/agents/python-typed-engineer-c1.toml`: generated variant
- `.codex/agents/python-typed-engineer-c2.toml`: generated variant
- `.codex/agents/python-typed-engineer-c3-elevated.toml`: generated variant
- `.codex/agents/python-typed-engineer-c3.toml`: generated variant
- `.codex/agents/python-typed-engineer-c4.toml`: generated variant
- `.codex/agents/python-typed-engineer.toml`: hand-edited Codex agent
- `.github/agents/Powershell DI Unit Test Engineer.agent.md`: canonical
- `.github/agents/atomic_executor.agent.md`: canonical
- `.github/agents/atomic_planning.agent.md`: canonical
- `.github/agents/csharp-atomic-executor.agent.md`: canonical
- `.github/agents/csharp-atomic-planning.agent.md`: canonical
- `.github/agents/csharp-orchestrator.agent.md`: canonical
- `.github/agents/csharp-typed-engineer.agent.md`: canonical
- `.github/agents/epic-review.agent.md`: canonical
- `.github/agents/orchestrator.agent.md`: canonical
- `.github/agents/powershell-atomic-executor.agent.md`: canonical
- `.github/agents/powershell-atomic-planning.agent.md`: canonical
- `.github/agents/powershell-orchestrator.agent.md`: canonical
- `.github/agents/powershell-typed-engineer.agent.md`: canonical
- `.github/agents/pytest-unit-test-coding.agent.md`: canonical
- `.github/agents/python-atomic-executor.agent.md`: canonical
- `.github/agents/python-atomic-planning.agent.md`: canonical
- `.github/agents/python-execution-only-typed.agent.md`: canonical
- `.github/agents/python-orchestrator.agent.md`: canonical
- `.github/agents/python-typed-engineer.agent.md`: canonical
- `.github/agents/typescript-engineer.agent.md`: canonical
- `.github/codex/execute-hard-lock.prompt.md`: canonical
- `.github/prompts/execute-hard-lock.prompt.md`: canonical
- `.github/prompts/review-feature.prompt.md`: canonical
- `.github/skills/atomic-plan-contract/SKILL.md`: canonical, with revert blocks below
- `.github/skills/evidence-and-timestamp-conventions/SKILL.md`: canonical
- `.github/skills/execution-environment/SKILL.md`: canonical
- `.github/skills/feature-review-workflow/SKILL.md`: canonical
- `docs/engineering/process-reductions/0001-parallel-only-test-gates.md`: earlier entry: `## Partial Revert` section and the step 1 ordering sentence
- `docs/engineering/process-reductions/0005-policy-read-removal.md`: earlier entry: `Current` and `Prior` fences updated to the restored text
- `docs/features/templates/bug/plan.yyyy-MM-ddTHH-mm.md`: canonical
- `docs/features/templates/feature/plan.yyyy-MM-ddTHH-mm.md`: canonical
- `docs/features/templates/policy_audit/AGENTS.md`: canonical
- `docs/features/templates/policy_audit/policy-audit.yyyy-MM-ddTHH-mm.md`: canonical, with revert blocks below
- `docs/features/templates/refactor/plan.yyyy-MM-ddTHH-mm.md`: canonical
- `extensions/drm-copilot/resources/claude-customizations/.claude-variants/csharp-legacy/agents/csharp-typed-engineer.md`: hand-edited `csharp-legacy` bundle variant
- `extensions/drm-copilot/resources/claude-customizations/.claude-variants/csharp-legacy/skills/csharp-qa-gate/SKILL.md`: hand-edited `csharp-legacy` bundle variant
- `extensions/drm-copilot/resources/claude-customizations/.claude-variants/csharp-legacy/skills/invoke-csharp-engineer/SKILL.md`: hand-edited `csharp-legacy` bundle variant
- `extensions/drm-copilot/resources/claude-customizations/.claude/agents/atomic-executor.md`: bundle copy
- `extensions/drm-copilot/resources/claude-customizations/.claude/agents/atomic-planner.md`: bundle copy
- `extensions/drm-copilot/resources/claude-customizations/.claude/agents/csharp-typed-engineer.md`: bundle copy
- `extensions/drm-copilot/resources/claude-customizations/.claude/agents/feature-review.md`: bundle copy
- `extensions/drm-copilot/resources/claude-customizations/.claude/agents/powershell-typed-engineer.md`: bundle copy
- `extensions/drm-copilot/resources/claude-customizations/.claude/agents/python-typed-engineer.md`: bundle copy
- `extensions/drm-copilot/resources/claude-customizations/.claude/skills/atomic-plan-contract/SKILL.md`: bundle copy
- `extensions/drm-copilot/resources/claude-customizations/.claude/skills/csharp-qa-gate/SKILL.md`: bundle copy
- `extensions/drm-copilot/resources/claude-customizations/.claude/skills/evidence-and-timestamp-conventions/SKILL.md`: bundle copy
- `extensions/drm-copilot/resources/claude-customizations/.claude/skills/execution-environment/SKILL.md`: bundle copy
- `extensions/drm-copilot/resources/claude-customizations/.claude/skills/feature-review-workflow/SKILL.md`: bundle copy
- `extensions/drm-copilot/resources/claude-customizations/.claude/skills/invoke-csharp-engineer/SKILL.md`: bundle copy
- `extensions/drm-copilot/resources/claude-customizations/.claude/skills/invoke-powershell-engineer/SKILL.md`: bundle copy
- `extensions/drm-copilot/resources/claude-customizations/.claude/skills/invoke-python-engineer/SKILL.md`: bundle copy
- `extensions/drm-copilot/resources/claude-customizations/.claude/skills/powershell-qa-gate/SKILL.md`: bundle copy
- `extensions/drm-copilot/resources/claude-customizations/.claude/skills/python-qa-gate/SKILL.md`: bundle copy
- `extensions/drm-copilot/resources/claude-customizations/.claude/skills/remediation-handoff-atomic-planner/SKILL.md`: bundle copy
- `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents-variants/csharp-legacy/skills/csharp-qa-gate/SKILL.md`: hand-edited `csharp-legacy` bundle variant
- `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents-variants/csharp-legacy/skills/invoke-csharp-engineer/SKILL.md`: hand-edited `csharp-legacy` bundle variant
- `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/atomic-plan-contract/SKILL.md`: bundle copy
- `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/atomic-planner/SKILL.md`: bundle copy
- `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/csharp-qa-gate/SKILL.md`: bundle copy
- `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/evidence-and-timestamp-conventions/SKILL.md`: bundle copy
- `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/execution-environment/SKILL.md`: bundle copy
- `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/feature-review-workflow/SKILL.md`: bundle copy
- `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/invoke-csharp-engineer/SKILL.md`: bundle copy
- `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/invoke-powershell-engineer/SKILL.md`: bundle copy
- `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/invoke-python-engineer/SKILL.md`: bundle copy
- `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/orchestrator-workflow/SKILL.md`: bundle copy
- `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/powershell-qa-gate/SKILL.md`: bundle copy
- `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/python-qa-gate/SKILL.md`: bundle copy
- `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex-variants/csharp-legacy/agents/csharp-typed-engineer.toml`: hand-edited `csharp-legacy` bundle variant
- `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/atomic-executor-c1.toml`: bundle copy
- `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/atomic-executor-c2.toml`: bundle copy
- `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/atomic-executor-c3-elevated.toml`: bundle copy
- `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/atomic-executor-c3.toml`: bundle copy
- `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/atomic-executor-c4.toml`: bundle copy
- `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/atomic-executor.toml`: bundle copy
- `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/atomic-planner-c1.toml`: bundle copy
- `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/atomic-planner-c2.toml`: bundle copy
- `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/atomic-planner-c3-elevated.toml`: bundle copy
- `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/atomic-planner-c3.toml`: bundle copy
- `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/atomic-planner-c4.toml`: bundle copy
- `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/atomic-planner.toml`: bundle copy
- `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/csharp-atomic-executor.toml`: bundle copy
- `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/csharp-atomic-planning.toml`: bundle copy
- `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/csharp-orchestrator.toml`: bundle copy
- `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/csharp-typed-engineer-c1.toml`: bundle copy
- `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/csharp-typed-engineer-c2.toml`: bundle copy
- `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/csharp-typed-engineer-c3-elevated.toml`: bundle copy
- `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/csharp-typed-engineer-c3.toml`: bundle copy
- `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/csharp-typed-engineer-c4.toml`: bundle copy
- `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/csharp-typed-engineer.toml`: bundle copy
- `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/feature-review.toml`: bundle copy
- `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/powershell-atomic-executor.toml`: bundle copy
- `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/powershell-atomic-planning.toml`: bundle copy
- `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/powershell-di-unit-test-engineer.toml`: bundle copy
- `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/powershell-orchestrator.toml`: bundle copy
- `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/powershell-typed-engineer-c1.toml`: bundle copy
- `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/powershell-typed-engineer-c2.toml`: bundle copy
- `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/powershell-typed-engineer-c3-elevated.toml`: bundle copy
- `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/powershell-typed-engineer-c3.toml`: bundle copy
- `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/powershell-typed-engineer-c4.toml`: bundle copy
- `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/powershell-typed-engineer.toml`: bundle copy
- `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/python-atomic-executor.toml`: bundle copy
- `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/python-atomic-planning.toml`: bundle copy
- `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/python-execution-only-typed.toml`: bundle copy
- `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/python-orchestrator.toml`: bundle copy
- `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/python-typed-engineer-c1.toml`: bundle copy
- `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/python-typed-engineer-c2.toml`: bundle copy
- `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/python-typed-engineer-c3-elevated.toml`: bundle copy
- `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/python-typed-engineer-c3.toml`: bundle copy
- `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/python-typed-engineer-c4.toml`: bundle copy
- `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/python-typed-engineer.toml`: bundle copy
- `extensions/drm-copilot/resources/customizations/.github/agents/Powershell DI Unit Test Engineer.agent.md`: bundle copy
- `extensions/drm-copilot/resources/customizations/.github/agents/atomic_executor.agent.md`: bundle copy
- `extensions/drm-copilot/resources/customizations/.github/agents/atomic_planning.agent.md`: bundle copy
- `extensions/drm-copilot/resources/customizations/.github/agents/csharp-atomic-executor.agent.md`: bundle copy
- `extensions/drm-copilot/resources/customizations/.github/agents/csharp-atomic-planning.agent.md`: bundle copy
- `extensions/drm-copilot/resources/customizations/.github/agents/csharp-orchestrator.agent.md`: bundle copy
- `extensions/drm-copilot/resources/customizations/.github/agents/csharp-typed-engineer.agent.md`: bundle copy
- `extensions/drm-copilot/resources/customizations/.github/agents/epic-review.agent.md`: bundle copy
- `extensions/drm-copilot/resources/customizations/.github/agents/orchestrator.agent.md`: bundle copy
- `extensions/drm-copilot/resources/customizations/.github/agents/powershell-atomic-executor.agent.md`: bundle copy
- `extensions/drm-copilot/resources/customizations/.github/agents/powershell-atomic-planning.agent.md`: bundle copy
- `extensions/drm-copilot/resources/customizations/.github/agents/powershell-orchestrator.agent.md`: bundle copy
- `extensions/drm-copilot/resources/customizations/.github/agents/powershell-typed-engineer.agent.md`: bundle copy
- `extensions/drm-copilot/resources/customizations/.github/agents/pytest-unit-test-coding.agent.md`: bundle copy
- `extensions/drm-copilot/resources/customizations/.github/agents/python-atomic-executor.agent.md`: bundle copy
- `extensions/drm-copilot/resources/customizations/.github/agents/python-atomic-planning.agent.md`: bundle copy
- `extensions/drm-copilot/resources/customizations/.github/agents/python-execution-only-typed.agent.md`: bundle copy
- `extensions/drm-copilot/resources/customizations/.github/agents/python-orchestrator.agent.md`: bundle copy
- `extensions/drm-copilot/resources/customizations/.github/agents/python-typed-engineer.agent.md`: bundle copy
- `extensions/drm-copilot/resources/customizations/.github/agents/typescript-engineer.agent.md`: bundle copy
- `extensions/drm-copilot/resources/customizations/.github/codex/execute-hard-lock.prompt.md`: bundle copy
- `extensions/drm-copilot/resources/customizations/.github/prompts/execute-hard-lock.prompt.md`: bundle copy
- `extensions/drm-copilot/resources/customizations/.github/prompts/review-feature.prompt.md`: bundle copy
- `extensions/drm-copilot/resources/customizations/.github/skills/atomic-plan-contract/SKILL.md`: bundle copy
- `extensions/drm-copilot/resources/customizations/.github/skills/evidence-and-timestamp-conventions/SKILL.md`: bundle copy
- `extensions/drm-copilot/resources/customizations/.github/skills/execution-environment/SKILL.md`: bundle copy
- `extensions/drm-copilot/resources/customizations/.github/skills/feature-review-workflow/SKILL.md`: bundle copy
- `extensions/drm-copilot/resources/feature-templates/bug/plan.yyyy-MM-ddTHH-mm.md`: bundle copy
- `extensions/drm-copilot/resources/feature-templates/feature/plan.yyyy-MM-ddTHH-mm.md`: bundle copy
- `extensions/drm-copilot/resources/feature-templates/refactor/plan.yyyy-MM-ddTHH-mm.md`: bundle copy
- `extensions/drm-copilot/resources/templates/policy_audit/AGENTS.md`: bundle copy
- `extensions/drm-copilot/resources/templates/policy_audit/policy-audit.yyyy-MM-ddTHH-mm.md`: bundle copy
- `tests/scripts/claude-runtime/parallel-gate-wording.Tests.ps1`: contract test
- `tests/scripts/dev_tools/test_codex_orchestration_contracts.py`: contract test
- `tests/scripts/dev_tools/test_execution_environment_brief_contracts.py`: contract test

## Stored Patch

`patches/0006-test-suite-baseline-restored.patch` holds the partial revert as one diff. It was generated as `git diff --binary --no-renames` from the first parent of the partial-revert commit (the commit whose subject carries `reduction: 0006` and adds this entry) over the paths in `## Files Changed`.

Rebased over PR #1108 (issue #1106): after `main` merged PR #1108, which renamed the C# test framework to MSTest and the Pester version to Pester v6 in twelve of these paths, the patch was regenerated so that it diffs from the 0001-state text carrying PR #1108's wording to the current text. The hunks are unchanged apart from those renames.

The check: `git apply -R --check` of the patch succeeds on the working tree. A failed check means the surrounding text has moved, and the `## Prior Text` blocks apply instead.

## Prior Text

Each of the three `atomic-plan-contract` sources, the brief `.claude/skills/execution-environment/SKILL.md`, and the policy-audit template takes one block per changed passage, so that applying every block yields the whole prior text of those five files. Their bundle copies and the five brief mirrors are byte-identical and are re-copied instead. Each `Current` fence holds the restored baseline text and each `Prior` fence holds the `0001` text it replaces.

### Revert Block: .claude/skills/atomic-plan-contract/SKILL.md

````Current
- baseline capture for each language that has explicit baseline command tasks in the plan: static baselines (format, lint, type check, and analyzer findings) and, for each language with mandatory coverage policy, one `Phase 0 baseline` run of its test gate (one `Invoke-PoshQCParallelTest`, one `pytest -n auto` with coverage, one Jest coverage run).
````

````Prior
- static baseline capture (format, lint, type check, and analyzer findings) for each language that has explicit baseline command tasks in the plan; no test suite runs in this block.
````

### Revert Block: .claude/skills/atomic-plan-contract/SKILL.md

````Current
	- each baseline step artifact MUST include: `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:`
	- baseline test-step artifacts for languages with mandatory coverage policy MUST include the pass and fail counts and numeric coverage headline values in `Output Summary:` (repo-wide percent and the percent of each in-scope file), read from the one parallel gate run.

2) Delegated implementation block
````

````Prior
	- each baseline step artifact MUST include: `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:`

2) Delegated implementation block
````

### Revert Block: .claude/skills/atomic-plan-contract/SKILL.md

````Current
record numeric post-change coverage values from the single gate run in `Output Summary:`, compared with the `Phase 0 baseline` run of the same gate.
````

````Prior
record numeric coverage values from the single gate run in `Output Summary:`.
````

### Revert Block: .claude/skills/atomic-plan-contract/SKILL.md

````Current
Phase 0 must also capture static baselines (format, lint, type check, and analyzer findings) for the languages touched and, for each language in scope with coverage policy, one `Phase 0 baseline` run of its test gate: one `Invoke-PoshQCParallelTest`, one `pytest -n auto` with coverage, and one Jest coverage run where TypeScript is in scope. Each test-suite baseline artifact records the pass and fail counts, the repo-wide coverage, and the coverage of each in-scope file. The final gate's run of the same gate is compared with it: no new failing test, no per-file or repo-wide coverage drop, the thresholds still apply, and new behavior is tested. A new file has no pre-change run and is judged against the thresholds. Baseline artifact conventions (location + required fields) are defined in `evidence-and-timestamp-conventions`.

A plan written before this rule that captures static baselines only stays valid: preflight does not return it as a defect, its final gate reads coverage against the thresholds, and its audit records `N/A - no pre-change run`.
````

````Prior
Phase 0 must also capture static baselines (format, lint, type check, and analyzer findings) for the languages touched, and no test suite runs in it. Baseline artifact conventions (location + required fields) are defined in `evidence-and-timestamp-conventions`.
````

### Revert Block: .claude/skills/atomic-plan-contract/SKILL.md

````Current
- The approved plan MUST include explicit baseline and final-QC coverage capture tasks: the `Phase 0 baseline` run and the final gate run, each one run of the language's parallel gate.
- Baseline and final-QC artifacts MUST record numeric coverage values (not placeholders such as `UNVERIFIED`).
- Where policy requires no-regression and new-code thresholds, the plan MUST include a delta/threshold verification task that reports, with post-change figures from the single gate run:
	- baseline coverage, from the `Phase 0 baseline` artifact,
	- post-change coverage,
	- new/changed-code coverage.
- Each changed file meets the coverage thresholds and shows no drop against the `Phase 0 baseline`; a new file has no pre-change run and is judged against the thresholds. New behavior is tested.
````

````Prior
- The approved plan MUST include an explicit final-QC coverage capture task.
- The final-QC artifact MUST record numeric coverage values (not placeholders such as `UNVERIFIED`).
- The plan MUST include a threshold task that reports each changed file from the single gate run against the coverage thresholds. New behavior is tested. No earlier figure is compared.
````

### Revert Block: .claude/skills/atomic-plan-contract/SKILL.md

````Current
- `minor-audit` plans MUST include baseline evidence tasks (static baselines and the `Phase 0 baseline` test-suite run), targeted verification evidence tasks read from the gate run, and end-state evidence tasks.
````

````Prior
- `minor-audit` plans MUST include static baseline evidence tasks, targeted verification evidence tasks read from the gate run, and end-state evidence tasks.
````

### Revert Block: .agents/skills/atomic-plan-contract/SKILL.md

````Current
- baseline capture for each language that has explicit baseline command tasks in the plan: static baselines (format, lint, type check, and analyzer findings) and, for each language with mandatory coverage policy, one `Phase 0 baseline` run of its test gate (one `Invoke-PoshQCParallelTest`, one `pytest -n auto` with coverage, one Jest coverage run).
````

````Prior
- static baseline capture (format, lint, type check, and analyzer findings) for each language that has explicit baseline command tasks in the plan; no test suite runs in this block.
````

### Revert Block: .agents/skills/atomic-plan-contract/SKILL.md

````Current
	- each baseline step artifact MUST include: `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:`
	- baseline test-step artifacts for languages with mandatory coverage policy MUST include the pass and fail counts and numeric coverage headline values in `Output Summary:` (repo-wide percent and the percent of each in-scope file), read from the one parallel gate run.

2) Delegated implementation block
````

````Prior
	- each baseline step artifact MUST include: `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:`

2) Delegated implementation block
````

### Revert Block: .agents/skills/atomic-plan-contract/SKILL.md

````Current
record numeric post-change coverage values from the single gate run in `Output Summary:`, compared with the `Phase 0 baseline` run of the same gate.
````

````Prior
record numeric coverage values from the single gate run in `Output Summary:`.
````

### Revert Block: .agents/skills/atomic-plan-contract/SKILL.md

````Current
Phase 0 must also capture static baselines (format, lint, type check, and analyzer findings) for the languages touched and, for each language in scope with coverage policy, one `Phase 0 baseline` run of its test gate: one `Invoke-PoshQCParallelTest`, one `pytest -n auto` with coverage, and one Jest coverage run where TypeScript is in scope. Each test-suite baseline artifact records the pass and fail counts, the repo-wide coverage, and the coverage of each in-scope file. The final gate's run of the same gate is compared with it: no new failing test, no per-file or repo-wide coverage drop, the thresholds still apply, and new behavior is tested. A new file has no pre-change run and is judged against the thresholds. Baseline artifact conventions (location + required fields) are defined in `evidence-and-timestamp-conventions`.

A plan written before this rule that captures static baselines only stays valid: preflight does not return it as a defect, its final gate reads coverage against the thresholds, and its audit records `N/A - no pre-change run`.
````

````Prior
Phase 0 must also capture static baselines (format, lint, type check, and analyzer findings) for the languages touched, and no test suite runs in it. Baseline artifact conventions (location + required fields) are defined in `evidence-and-timestamp-conventions`.
````

### Revert Block: .agents/skills/atomic-plan-contract/SKILL.md

````Current
- The approved plan MUST include explicit baseline and final-QC coverage capture tasks: the `Phase 0 baseline` run and the final gate run, each one run of the language's parallel gate.
- Baseline and final-QC artifacts MUST record numeric coverage values (not placeholders such as `UNVERIFIED`).
- Where policy requires no-regression and new-code thresholds, the plan MUST include a delta/threshold verification task that reports, with post-change figures from the single gate run:
	- baseline coverage, from the `Phase 0 baseline` artifact,
	- post-change coverage,
	- new/changed-code coverage.
- Each changed file meets the coverage thresholds and shows no drop against the `Phase 0 baseline`; a new file has no pre-change run and is judged against the thresholds. New behavior is tested.
````

````Prior
- The approved plan MUST include an explicit final-QC coverage capture task.
- The final-QC artifact MUST record numeric coverage values (not placeholders such as `UNVERIFIED`).
- The plan MUST include a threshold task that reports each changed file from the single gate run against the coverage thresholds. New behavior is tested. No earlier figure is compared.
````

### Revert Block: .agents/skills/atomic-plan-contract/SKILL.md

````Current
- `minor-audit` plans MUST include baseline evidence tasks (static baselines and the `Phase 0 baseline` test-suite run), targeted verification evidence tasks read from the gate run, and end-state evidence tasks.
````

````Prior
- `minor-audit` plans MUST include static baseline evidence tasks, targeted verification evidence tasks read from the gate run, and end-state evidence tasks.
````

### Revert Block: .github/skills/atomic-plan-contract/SKILL.md

````Current
- baseline capture for each language that has explicit baseline command tasks in the plan: static baselines (format, lint, type check, and analyzer findings) and, for each language with mandatory coverage policy, one `Phase 0 baseline` run of its test gate (one `Invoke-PoshQCParallelTest`, one `pytest -n auto` with coverage, one Jest coverage run).
````

````Prior
- static baseline capture (format, lint, type check, and analyzer findings) for each language that has explicit baseline command tasks in the plan; no test suite runs in this block.
````

### Revert Block: .github/skills/atomic-plan-contract/SKILL.md

````Current
	- each baseline step artifact MUST include: `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:`
	- baseline test-step artifacts for languages with mandatory coverage policy MUST include the pass and fail counts and numeric coverage headline values in `Output Summary:` (repo-wide percent and the percent of each in-scope file), read from the one parallel gate run.

2) Delegated implementation block
````

````Prior
	- each baseline step artifact MUST include: `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:`

2) Delegated implementation block
````

### Revert Block: .github/skills/atomic-plan-contract/SKILL.md

````Current
record numeric post-change coverage values from the single gate run in `Output Summary:`, compared with the `Phase 0 baseline` run of the same gate.
````

````Prior
record numeric coverage values from the single gate run in `Output Summary:`.
````

### Revert Block: .github/skills/atomic-plan-contract/SKILL.md

````Current
Phase 0 must also capture static baselines (format, lint, type check, and analyzer findings) for the languages touched and, for each language in scope with coverage policy, one `Phase 0 baseline` run of its test gate: one `Invoke-PoshQCParallelTest`, one `pytest -n auto` with coverage, and one Jest coverage run where TypeScript is in scope. Each test-suite baseline artifact records the pass and fail counts, the repo-wide coverage, and the coverage of each in-scope file. The final gate's run of the same gate is compared with it: no new failing test, no per-file or repo-wide coverage drop, the thresholds still apply, and new behavior is tested. A new file has no pre-change run and is judged against the thresholds. Baseline artifact conventions (location + required fields) are defined in `evidence-and-timestamp-conventions`.

A plan written before this rule that captures static baselines only stays valid: preflight does not return it as a defect, its final gate reads coverage against the thresholds, and its audit records `N/A - no pre-change run`.
````

````Prior
Phase 0 must also capture static baselines (format, lint, type check, and analyzer findings) for the languages touched, and no test suite runs in it. Baseline artifact conventions (location + required fields) are defined in `evidence-and-timestamp-conventions`.
````

### Revert Block: .github/skills/atomic-plan-contract/SKILL.md

````Current
- The approved plan MUST include explicit baseline and final-QC coverage capture tasks: the `Phase 0 baseline` run and the final gate run, each one run of the language's parallel gate.
- Baseline and final-QC artifacts MUST record numeric coverage values (not placeholders such as `UNVERIFIED`).
- Where policy requires no-regression and new-code thresholds, the plan MUST include a delta/threshold verification task that reports, with post-change figures from the single gate run:
	- baseline coverage, from the `Phase 0 baseline` artifact,
	- post-change coverage,
	- new/changed-code coverage.
- Each changed file meets the coverage thresholds and shows no drop against the `Phase 0 baseline`; a new file has no pre-change run and is judged against the thresholds. New behavior is tested.
````

````Prior
- The approved plan MUST include an explicit final-QC coverage capture task.
- The final-QC artifact MUST record numeric coverage values (not placeholders such as `UNVERIFIED`).
- The plan MUST include a threshold task that reports each changed file from the single gate run against the coverage thresholds. New behavior is tested. No earlier figure is compared.
````

### Revert Block: .github/skills/atomic-plan-contract/SKILL.md

````Current
- `minor-audit` plans MUST include baseline evidence tasks (static baselines and the `Phase 0 baseline` test-suite run), targeted verification evidence tasks read from the gate run, and end-state evidence tasks.
````

````Prior
- `minor-audit` plans MUST include static baseline evidence tasks, targeted verification evidence tasks read from the gate run, and end-state evidence tasks.
````

### Revert Block: .claude/skills/execution-environment/SKILL.md

````Current
and the sweep of those surfaces for removed serial-run wording.
````

````Prior
and the sweep of those surfaces for removed test-suite baseline wording.
````

### Revert Block: .claude/skills/execution-environment/SKILL.md

````Current
- Per-file figures are read from the single gate run and compared with the `Phase 0 baseline` run of the same gate; a new file has no pre-change run and is judged against the thresholds.
````

````Prior
- Per-file figures are read from the single gate run, and no earlier figure is compared.
````

### Revert Block: docs/features/templates/policy_audit/policy-audit.yyyy-MM-ddTHH-mm.md

````Current
| Python | [N] files | [N] tests | [✅/❌] [N] pass, [N] fail | [N]% lines, [N]% funcs | [N]% lines, [N]% funcs | [N]% |
| PowerShell | [N] files | [N] tests | [✅/❌] [N] pass, [N] fail | [N]% cmds, [N]% funcs | [N]% cmds, [N]% funcs | [N]% |
````

````Prior
| Python | [N] files | [N] tests | [✅/❌] [N] pass, [N] fail | N/A - no pre-change run | [N]% lines, [N]% funcs | [N]% |
| PowerShell | [N] files | [N] tests | [✅/❌] [N] pass, [N] fail | N/A - no pre-change run | [N]% cmds, [N]% funcs | [N]% |
````

### Revert Block: docs/features/templates/policy_audit/policy-audit.yyyy-MM-ddTHH-mm.md

````Current
- TypeScript baseline coverage artifact: [path or `N/A - out of scope`]
- TypeScript post-change coverage artifact: [path or `N/A - out of scope`]
- PowerShell baseline coverage artifact: [path or `N/A - out of scope`]
- PowerShell post-change coverage artifact: [path or `N/A - out of scope`]
- Per-language comparison summary: [section reference or artifact path]

Baseline coverage is read from the plan's `Phase 0 baseline` artifact, one run of the language's gate. A baseline cell or field records `N/A - no pre-change run` only for a new file or for a plan written before the `Phase 0 baseline` rule that captured static baselines only.

**Non-negotiable verdict rule:** No policy audit may report PASS unless it includes numeric baseline and post-change coverage metrics for every language in scope (or `N/A - no pre-change run` where that record applies), plus changed/new-code coverage when required.

**Fail-closed rule:** If any required baseline artifact, QA artifact, or coverage-comparison artifact is missing, the verdict must be BLOCKED or INCOMPLETE, never PASS.
````

````Prior
- TypeScript baseline coverage artifact: N/A - no pre-change run
- TypeScript post-change coverage artifact: [path or `N/A - out of scope`]
- PowerShell baseline coverage artifact: N/A - no pre-change run
- PowerShell post-change coverage artifact: [path or `N/A - out of scope`]
- Per-language comparison summary: [section reference or artifact path]

**Non-negotiable verdict rule:** No policy audit may report PASS unless it includes numeric post-change coverage metrics for every language in scope, plus changed/new-code coverage when required.

**Fail-closed rule:** If any required QA artifact or post-change coverage metric is missing, the verdict must be BLOCKED or INCOMPLETE, never PASS.
````

### Revert Block: docs/features/templates/policy_audit/policy-audit.yyyy-MM-ddTHH-mm.md

````Current
| **Baseline Coverage Documented** | [✅/❌/N/A] [PASS/FAIL/N/A] | **Baseline:** [N]% lines, [N]% functions, read from the `Phase 0 baseline` artifact (or `N/A - no pre-change run`)<br>**Command:** `Invoke-PoshQCParallelTest` or `poetry run pytest -n auto` (one run of the gate)<br>**Artifact:** [path]<br>**Timestamp:** [YYYY-MM-DD HH:MM] |
| **No Coverage Regression** | [✅/❌/N/A] [PASS/FAIL/N/A] | **Post-change coverage:** [N]% lines, [N]% functions, read from the single gate run<br>**Change:** [+/-N]% lines, [+/-N]% functions against the `Phase 0 baseline`<br>**Status:** [No regression / Regression detected: justification]<br>**Example:** "Baseline: 85.2% → Post-change: 87.1% (+1.9%) ✅ PASS" |
| **Changed Files Meet Thresholds** | [✅/❌/N/A] [PASS/FAIL/N/A] | **Post-change coverage:** [N]% lines, [N]% functions, read from the single gate run<br>**Thresholds:** [line and branch thresholds that apply]<br>**Status:** [All changed files meet the thresholds / Files below a threshold: list]<br>**Example:** "Post-change: 87.1% against the 85% line threshold ✅ PASS" |
````

````Prior
| **Changed Files Meet Thresholds** | [✅/❌/N/A] [PASS/FAIL/N/A] | **Post-change coverage:** [N]% lines, [N]% functions, read from the single gate run<br>**Thresholds:** [line and branch thresholds that apply]<br>**Status:** [All changed files meet the thresholds / Files below a threshold: list]<br>**Example:** "Post-change: 87.1% against the 85% line threshold ✅ PASS" |
````

### Revert Block: docs/features/templates/policy_audit/policy-audit.yyyy-MM-ddTHH-mm.md

````Current
- [Language]: Baseline: [N]% [unit] (from the `Phase 0 baseline` artifact, or `N/A - no pre-change run`) -> Post-change: [N]% [unit]. Change: [+/-N]% [unit delta] (or N/A). New/changed-code coverage:
````

````Prior
- [Language]: Baseline: N/A - no pre-change run -> Post-change: [N]% [unit]. Change: N/A. New/changed-code coverage:
````

### Revert Block: docs/features/templates/policy_audit/policy-audit.yyyy-MM-ddTHH-mm.md

````Current
**Fail-closed reminder:** Do not mark the audit PASS, fully compliant, or ready for merge when any required baseline artifact, QA artifact, coverage metric, or coverage-comparison artifact is missing.
````

````Prior
**Fail-closed reminder:** Do not mark the audit PASS, fully compliant, or ready for merge when any required QA artifact or post-change coverage metric is missing.
````

## Revert Steps

1. Apply the blocks: run `git apply -R` of `patches/0006-test-suite-baseline-restored.patch` when its check passes. Otherwise replace each `Current` fence with its `Prior` fence in the named file, and restore the other paths from the patch text. Reset the `0001` row Status in `README.md` to `Active`. Revert this entry before `0001`, because the restored text sits inside hunks of the `0001` patch; reverting this patch also removes the `0001` `## Partial Revert` section and restores the `0005` fences.
2. Re-copy mirrors and bundles: copy `.claude/skills/execution-environment/SKILL.md` to its five copies; copy each `atomic-plan-contract`, `evidence-and-timestamp-conventions`, QA gate, review, planner, engineer, and handoff source, each Copilot agent and prompt, each hand-edited Codex agent without generated variants, and each template to its bundle path under `extensions/drm-copilot/resources/`; the `csharp-legacy` bundle variants are hand-edited and are restored from the patch text.
3. Regenerate Codex variants: applicable, because the bases `.codex/agents/atomic-executor.toml`, `.codex/agents/atomic-planner.toml`, `.codex/agents/csharp-typed-engineer.toml`, `.codex/agents/powershell-typed-engineer.toml`, and `.codex/agents/python-typed-engineer.toml` changed. Run `scripts/dev_tools/generate_codex_agent_variants.py` in module form, then run it with `--check`.
4. Restore pinned hashes: not applicable, because no pinned surface moved.
5. Restore contract-test literals: the patch restores `tests/scripts/claude-runtime/parallel-gate-wording.Tests.ps1` (the 38 sweep tokens and the baseline-class forbidden tokens), `test_brief_passages_state_parallel_gate_facts`, and `test_codex_orchestrator_workflow_requires_large_path_evidence_gates`. Remove `PRL-PARTIAL-REVERT-LINKED` from `tests/scripts/dev-tools/ProcessReductionLedger.Index.Tests.ps1`, which is outside the patch.
6. Run the contract tests: run `parallel-gate-wording.Tests.ps1`, `ProcessReductionLedger.Index.Tests.ps1`, `planning-contract-wording.Tests.ps1`, `test_execution_environment_brief_contracts.py`, `test_codex_orchestration_contracts.py`, `test_push_down_claude_resource_contracts.py`, `test_push_down_codex_and_agents_resource_contracts.py`, and `test_copilot_bundle_copies_match_canonical`, inside the one `Invoke-PoshQCParallelTest` run and the one `pytest -n auto` run.

## Revert Signals

- Phase 0 duration: the baseline run of each gate dominates Phase 0 time across items (this stage measured about 7 minutes for Pester and 3 minutes for pytest).
- Remediation cycles cite no coverage regression against the `Phase 0 baseline`, so the comparison catches nothing the thresholds do not.
