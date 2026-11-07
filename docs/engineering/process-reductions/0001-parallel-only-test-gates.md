# 0001: Parallel-only test gates

## Summary

reduction: 0001
Date: 2026-11-07
Issue: #1094
Merge commit: pending (PR #1102)

Removes the repeated test runs that each item performed before review. The Pester, pytest, and Jest gates are now one parallel run each, re-run only after a fix: the local serial and order-varying runs are gone from `## Test Isolation Checks`, plans capture static baselines with no test-suite baseline, and coverage is read from the single gate run against the thresholds, with no earlier figure compared. Test independence remains policy under `.claude/rules/general-unit-test.md`.

The reduction landed across this branch's commits, before the ledger rule reached the branch, so no single commit holds it. This entry's own commit carries the `reduction: 0001` token in its subject.

## Reason and Evidence

The owner decided on 2026-11-06 that tests run in parallel only. The sequential run existed to detect and fix a leak that has since been fixed, and the overhead of multiple and sequential runs was judged unacceptable.

Measured during Epic #1019, as recorded in the spec's `## Overview`:

- An 8-shard `Invoke-PoshQCParallelTest` run took 448 s.
- Single-process runs over `tests/scripts` took between 899 s and 1,504 s, and one item ran several of them in a single cycle.
- CI repeats the suite on every pull request as 3 shards, so the local single-process run did not match CI.

Removing the repeated runs removes the current means of detecting leaks. #1096 adds a static scan for that purpose.

## Files Changed

The list covers every path changed from the merge base of `origin/main` and the branch head, excluding the feature folder, `docs/features/potential/`, and this ledger, with rename detection off.

- `.agents/skills/atomic-plan-contract/SKILL.md`: mirror, a non-identical copy with its own revert block
- `.agents/skills/atomic-planner/SKILL.md`: canonical
- `.agents/skills/csharp-qa-gate/SKILL.md`: mirror
- `.agents/skills/execution-environment/SKILL.md`: mirror
- `.agents/skills/feature-review-workflow/SKILL.md`: mirror
- `.agents/skills/invoke-csharp-engineer/SKILL.md`: mirror
- `.agents/skills/invoke-powershell-engineer/SKILL.md`: mirror
- `.agents/skills/invoke-python-engineer/SKILL.md`: mirror
- `.agents/skills/orchestrator-workflow/SKILL.md`: canonical
- `.agents/skills/powershell-qa-gate/SKILL.md`: mirror
- `.agents/skills/python-qa-gate/SKILL.md`: mirror
- `.agents/skills/repo-automation-adapter/SKILL.md`: canonical
- `.claude/agents/atomic-executor.md`: canonical
- `.claude/agents/atomic-planner.md`: canonical
- `.claude/agents/csharp-typed-engineer.md`: canonical
- `.claude/agents/feature-review.md`: canonical
- `.claude/agents/powershell-typed-engineer.md`: canonical
- `.claude/agents/python-typed-engineer.md`: canonical
- `.claude/hooks/validate-feature-review-coverage-rules.ps1`: canonical; supports the new template record `N/A - no pre-change run`
- `.claude/skills/atomic-plan-contract/SKILL.md`: canonical
- `.claude/skills/csharp-qa-gate/SKILL.md`: canonical
- `.claude/skills/execution-environment/SKILL.md`: canonical
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
- `.codex/agents/atomic-executor.toml`: generated variant
- `.codex/agents/atomic-planner-c1.toml`: generated variant
- `.codex/agents/atomic-planner-c2.toml`: generated variant
- `.codex/agents/atomic-planner-c3-elevated.toml`: generated variant
- `.codex/agents/atomic-planner-c3.toml`: generated variant
- `.codex/agents/atomic-planner-c4.toml`: generated variant
- `.codex/agents/atomic-planner.toml`: generated variant
- `.codex/agents/csharp-atomic-executor.toml`: generated variant
- `.codex/agents/csharp-atomic-planning.toml`: generated variant
- `.codex/agents/csharp-orchestrator.toml`: generated variant
- `.codex/agents/csharp-typed-engineer-c1.toml`: generated variant
- `.codex/agents/csharp-typed-engineer-c2.toml`: generated variant
- `.codex/agents/csharp-typed-engineer-c3-elevated.toml`: generated variant
- `.codex/agents/csharp-typed-engineer-c3.toml`: generated variant
- `.codex/agents/csharp-typed-engineer-c4.toml`: generated variant
- `.codex/agents/csharp-typed-engineer.toml`: generated variant
- `.codex/agents/feature-review.toml`: generated variant
- `.codex/agents/powershell-atomic-executor.toml`: generated variant
- `.codex/agents/powershell-atomic-planning.toml`: generated variant
- `.codex/agents/powershell-di-unit-test-engineer.toml`: generated variant
- `.codex/agents/powershell-orchestrator.toml`: generated variant
- `.codex/agents/powershell-typed-engineer-c1.toml`: generated variant
- `.codex/agents/powershell-typed-engineer-c2.toml`: generated variant
- `.codex/agents/powershell-typed-engineer-c3-elevated.toml`: generated variant
- `.codex/agents/powershell-typed-engineer-c3.toml`: generated variant
- `.codex/agents/powershell-typed-engineer-c4.toml`: generated variant
- `.codex/agents/powershell-typed-engineer.toml`: generated variant
- `.codex/agents/pytest-unit-test-coding.toml`: generated variant
- `.codex/agents/python-atomic-executor.toml`: generated variant
- `.codex/agents/python-atomic-planning.toml`: generated variant
- `.codex/agents/python-execution-only-typed.toml`: generated variant
- `.codex/agents/python-orchestrator.toml`: generated variant
- `.codex/agents/python-typed-engineer-c1.toml`: generated variant
- `.codex/agents/python-typed-engineer-c2.toml`: generated variant
- `.codex/agents/python-typed-engineer-c3-elevated.toml`: generated variant
- `.codex/agents/python-typed-engineer-c3.toml`: generated variant
- `.codex/agents/python-typed-engineer-c4.toml`: generated variant
- `.codex/agents/python-typed-engineer.toml`: generated variant
- `.codex/hooks/validate-feature-review-coverage.ps1`: canonical; supports the new template record `N/A - no pre-change run`
- `.github/agents/5.1-Beast-adjusted.agent.md`: canonical
- `.github/agents/atomic_executor.agent.md`: canonical
- `.github/agents/atomic_planning.agent.md`: canonical
- `.github/agents/commentary-remediation.agent.md`: canonical
- `.github/agents/csharp-atomic-executor.agent.md`: canonical
- `.github/agents/csharp-atomic-planning.agent.md`: canonical
- `.github/agents/csharp-orchestrator.agent.md`: canonical
- `.github/agents/csharp-typed-engineer.agent.md`: canonical
- `.github/agents/epic-review.agent.md`: canonical
- `.github/agents/gpt-5-beast-mode.agent.md`: canonical
- `.github/agents/orchestrator.agent.md`: canonical
- `.github/agents/Powershell DI Unit Test Engineer.agent.md`: canonical
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
- `.github/agents/staged-review.agent.md`: canonical
- `.github/agents/tdd-green.agent.md`: canonical
- `.github/agents/tdd-red.agent.md`: canonical
- `.github/agents/tdd-refactor.agent.md`: canonical
- `.github/agents/typescript-engineer.agent.md`: canonical
- `.github/codex/execute-hard-lock.prompt.md`: canonical
- `.github/prompts/execute-hard-lock.prompt.md`: canonical
- `.github/prompts/remediate-comments.prompt.md`: canonical
- `.github/prompts/review-feature.prompt.md`: canonical
- `.github/skills/atomic-plan-contract/SKILL.md`: mirror, a non-identical copy with its own revert block
- `.github/skills/execution-environment/SKILL.md`: mirror
- `.github/skills/feature-review-workflow/SKILL.md`: mirror
- `docs/features/templates/bug/plan.yyyy-MM-ddTHH-mm.md`: canonical
- `docs/features/templates/feature/plan.yyyy-MM-ddTHH-mm.md`: canonical
- `docs/features/templates/policy_audit/AGENTS.md`: canonical
- `docs/features/templates/policy_audit/policy-audit.yyyy-MM-ddTHH-mm.md`: canonical
- `docs/features/templates/refactor/plan.yyyy-MM-ddTHH-mm.md`: canonical
- `extensions/drm-copilot/resources/claude-customizations/.claude-variants/csharp-legacy/agents/csharp-typed-engineer.md`: bundle copy
- `extensions/drm-copilot/resources/claude-customizations/.claude-variants/csharp-legacy/skills/csharp-qa-gate/SKILL.md`: bundle copy
- `extensions/drm-copilot/resources/claude-customizations/.claude-variants/csharp-legacy/skills/invoke-csharp-engineer/SKILL.md`: bundle copy
- `extensions/drm-copilot/resources/claude-customizations/.claude/agents/atomic-executor.md`: bundle copy
- `extensions/drm-copilot/resources/claude-customizations/.claude/agents/atomic-planner.md`: bundle copy
- `extensions/drm-copilot/resources/claude-customizations/.claude/agents/csharp-typed-engineer.md`: bundle copy
- `extensions/drm-copilot/resources/claude-customizations/.claude/agents/feature-review.md`: bundle copy
- `extensions/drm-copilot/resources/claude-customizations/.claude/agents/powershell-typed-engineer.md`: bundle copy
- `extensions/drm-copilot/resources/claude-customizations/.claude/agents/python-typed-engineer.md`: bundle copy
- `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/validate-feature-review-coverage-rules.ps1`: bundle copy
- `extensions/drm-copilot/resources/claude-customizations/.claude/skills/atomic-plan-contract/SKILL.md`: bundle copy
- `extensions/drm-copilot/resources/claude-customizations/.claude/skills/csharp-qa-gate/SKILL.md`: bundle copy
- `extensions/drm-copilot/resources/claude-customizations/.claude/skills/execution-environment/SKILL.md`: bundle copy
- `extensions/drm-copilot/resources/claude-customizations/.claude/skills/feature-review-workflow/SKILL.md`: bundle copy
- `extensions/drm-copilot/resources/claude-customizations/.claude/skills/invoke-csharp-engineer/SKILL.md`: bundle copy
- `extensions/drm-copilot/resources/claude-customizations/.claude/skills/invoke-powershell-engineer/SKILL.md`: bundle copy
- `extensions/drm-copilot/resources/claude-customizations/.claude/skills/invoke-python-engineer/SKILL.md`: bundle copy
- `extensions/drm-copilot/resources/claude-customizations/.claude/skills/powershell-qa-gate/SKILL.md`: bundle copy
- `extensions/drm-copilot/resources/claude-customizations/.claude/skills/python-qa-gate/SKILL.md`: bundle copy
- `extensions/drm-copilot/resources/claude-customizations/.claude/skills/remediation-handoff-atomic-planner/SKILL.md`: bundle copy
- `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents-variants/csharp-legacy/skills/csharp-qa-gate/SKILL.md`: bundle copy
- `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents-variants/csharp-legacy/skills/invoke-csharp-engineer/SKILL.md`: bundle copy
- `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/atomic-plan-contract/SKILL.md`: bundle copy
- `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/atomic-planner/SKILL.md`: bundle copy
- `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/csharp-qa-gate/SKILL.md`: bundle copy
- `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/execution-environment/SKILL.md`: bundle copy
- `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/feature-review-workflow/SKILL.md`: bundle copy
- `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/invoke-csharp-engineer/SKILL.md`: bundle copy
- `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/invoke-powershell-engineer/SKILL.md`: bundle copy
- `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/invoke-python-engineer/SKILL.md`: bundle copy
- `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/orchestrator-workflow/SKILL.md`: bundle copy
- `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/powershell-qa-gate/SKILL.md`: bundle copy
- `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/python-qa-gate/SKILL.md`: bundle copy
- `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/repo-automation-adapter/SKILL.md`: bundle copy
- `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex-variants/csharp-legacy/agents/csharp-typed-engineer.toml`: bundle copy
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
- `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/pytest-unit-test-coding.toml`: bundle copy
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
- `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/validate-feature-review-coverage.ps1`: bundle copy
- `extensions/drm-copilot/resources/customizations/.github/agents/5.1-Beast-adjusted.agent.md`: bundle copy
- `extensions/drm-copilot/resources/customizations/.github/agents/atomic_executor.agent.md`: bundle copy
- `extensions/drm-copilot/resources/customizations/.github/agents/atomic_planning.agent.md`: bundle copy
- `extensions/drm-copilot/resources/customizations/.github/agents/commentary-remediation.agent.md`: bundle copy
- `extensions/drm-copilot/resources/customizations/.github/agents/csharp-atomic-executor.agent.md`: bundle copy
- `extensions/drm-copilot/resources/customizations/.github/agents/csharp-atomic-planning.agent.md`: bundle copy
- `extensions/drm-copilot/resources/customizations/.github/agents/csharp-orchestrator.agent.md`: bundle copy
- `extensions/drm-copilot/resources/customizations/.github/agents/csharp-typed-engineer.agent.md`: bundle copy
- `extensions/drm-copilot/resources/customizations/.github/agents/epic-review.agent.md`: bundle copy
- `extensions/drm-copilot/resources/customizations/.github/agents/gpt-5-beast-mode.agent.md`: bundle copy
- `extensions/drm-copilot/resources/customizations/.github/agents/orchestrator.agent.md`: bundle copy
- `extensions/drm-copilot/resources/customizations/.github/agents/Powershell DI Unit Test Engineer.agent.md`: bundle copy
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
- `extensions/drm-copilot/resources/customizations/.github/agents/staged-review.agent.md`: bundle copy
- `extensions/drm-copilot/resources/customizations/.github/agents/tdd-green.agent.md`: bundle copy
- `extensions/drm-copilot/resources/customizations/.github/agents/tdd-red.agent.md`: bundle copy
- `extensions/drm-copilot/resources/customizations/.github/agents/tdd-refactor.agent.md`: bundle copy
- `extensions/drm-copilot/resources/customizations/.github/agents/typescript-engineer.agent.md`: bundle copy
- `extensions/drm-copilot/resources/customizations/.github/codex/execute-hard-lock.prompt.md`: bundle copy
- `extensions/drm-copilot/resources/customizations/.github/prompts/execute-hard-lock.prompt.md`: bundle copy
- `extensions/drm-copilot/resources/customizations/.github/prompts/remediate-comments.prompt.md`: bundle copy
- `extensions/drm-copilot/resources/customizations/.github/prompts/review-feature.prompt.md`: bundle copy
- `extensions/drm-copilot/resources/customizations/.github/skills/atomic-plan-contract/SKILL.md`: bundle copy
- `extensions/drm-copilot/resources/customizations/.github/skills/execution-environment/SKILL.md`: bundle copy
- `extensions/drm-copilot/resources/customizations/.github/skills/feature-review-workflow/SKILL.md`: bundle copy
- `extensions/drm-copilot/resources/feature-templates/bug/plan.yyyy-MM-ddTHH-mm.md`: bundle copy
- `extensions/drm-copilot/resources/feature-templates/feature/plan.yyyy-MM-ddTHH-mm.md`: bundle copy
- `extensions/drm-copilot/resources/feature-templates/refactor/plan.yyyy-MM-ddTHH-mm.md`: bundle copy
- `extensions/drm-copilot/resources/templates/policy_audit/AGENTS.md`: bundle copy
- `extensions/drm-copilot/resources/templates/policy_audit/policy-audit.yyyy-MM-ddTHH-mm.md`: bundle copy
- `extensions/drm-copilot/test/lib/validate/policy-audit-artifact.test.ts`: contract test
- `tests/scripts/claude-hooks/validate-feature-review-coverage.Tests.ps1`: contract test
- `tests/scripts/claude-runtime/parallel-gate-wording.Tests.ps1`: contract test
- `tests/scripts/codex-hooks/feature-review-coverage-narrowing-parity.Tests.ps1`: contract test
- `tests/scripts/dev_tools/test_codex_orchestration_contracts.py`: contract test
- `tests/scripts/dev_tools/test_execution_environment_brief_contracts.py`: contract test
- `tests/scripts/dev_tools/test_single_pass_preflight_contracts.py`: contract test
- `tests/scripts/dev_tools/test_validate_policy_audit_artifact.py`: contract test

## Stored Patch

`patches/0001-parallel-only-test-gates.patch` holds the reduction as one diff. It is `git diff --binary --no-renames` from the merge base of `origin/main` and the branch head, limited to the paths in `## Files Changed`.

The check: `git apply -R --check` of the patch succeeds on the working tree. A failed check means the surrounding text has moved, and the `## Prior Text` blocks apply instead.

## Prior Text

The two rules that carry the reduction each have blocks. `.claude/skills/execution-environment/SKILL.md` takes one block for the body of `## Test Isolation Checks`, because its five mirrors are byte-identical. The three `atomic-plan-contract` sources differ from one another, so each takes a block for its `Test isolation` sentence of the Pre-Mortem rule.

### Revert Block: .claude/skills/execution-environment/SKILL.md

````Current
- Tests create no temporary files; file and transcript reads go through injected seams with in-memory content.
- The test gates are parallel:
  - the Pester gate is one `Invoke-PoshQCParallelTest` run;
  - the pytest gate is one `pytest -n auto` run;
  - Jest runs through its normal parallel workers.
- Each gate reaches zero failures and is re-run only after a fix.
- A focused run of one test file to debug a specific failure is debugging only; it is never a gate or evidence.
- Serial tasks remain for debugging one failure and are not gates.
- A leak found by a gate is fixed on both sides: the suite that leaves state behind (globals, functions, environment variables, mocks, imported modules, script-scope state) and the suite that assumes prior state.
- The parallel gates govern where a policy file names a toolchain test command.
````

````Prior
- Tests create no temporary files; file and transcript reads go through injected seams with in-memory content.
- Before review, run each isolation check and record it under `<FEATURE>/evidence/regression-testing/`:
  - a seeded shuffled Jest run (`node run-jest.cjs --randomize --seed=<n>` in `extensions/drm-copilot/`) with the seed recorded;
  - a reversed-order run of the new or changed Python test modules in one process;
  - a seeded shuffled file-order run of the touched Pester suites in one process, with at least three seeds and each seed and its file order recorded;
  - a fresh single-process Pester run over `tests/scripts`, which is the CI shape;
  - in addition to the serial runs, a concurrent-shard Pester run through `Invoke-PoshQCParallelTest` and a `pytest -n auto` run, both with zero failures.
- An order dependence found by any run is fixed on both sides: the suite that leaves state behind (globals, functions, environment variables, mocks, imported modules, script-scope state) and the suite that assumes prior state. Every seed is then re-run.
````

### Revert Block: .claude/skills/atomic-plan-contract/SKILL.md

````Current
The `Test isolation` bullet names the parallel gates the plan uses: one `Invoke-PoshQCParallelTest` run, one `pytest -n auto` run, and Jest through its normal parallel workers, each re-run only after a fix.
````

````Prior
The `Test isolation` bullet names the isolation runs the plan performs: a seeded shuffled Jest run with the seed recorded, a reversed-order run of the new or changed Python test modules, and a seeded shuffled file-order run of the touched Pester suites with at least three seeds, each seed recorded.
````

### Revert Block: .agents/skills/atomic-plan-contract/SKILL.md

````Current
The `Test isolation` bullet names the parallel gates the plan uses: one `Invoke-PoshQCParallelTest` run, one `pytest -n auto` run, and Jest through its normal parallel workers, each re-run only after a fix.
````

````Prior
The `Test isolation` bullet names the isolation runs the plan performs: a seeded shuffled Jest run with the seed recorded, a reversed-order run of the new or changed Python test modules, and a seeded shuffled file-order run of the touched Pester suites with at least three seeds, each seed recorded.
````

### Revert Block: .github/skills/atomic-plan-contract/SKILL.md

````Current
The `Test isolation` bullet names the parallel gates the plan uses: one `Invoke-PoshQCParallelTest` run, one `pytest -n auto` run, and Jest through its normal parallel workers, each re-run only after a fix.
````

````Prior
The `Test isolation` bullet names the isolation runs the plan performs: a seeded shuffled Jest run with the seed recorded, a reversed-order run of the new or changed Python test modules, and a seeded shuffled file-order run of the touched Pester suites with at least three seeds, each seed recorded.
````

## Revert Steps

1. Apply the blocks: run `git apply -R` of the patch when its check passes. Otherwise replace each `Current` with its `Prior`, which restores the core rule, and restore the other paths from the patch text.
2. Re-copy mirrors and bundles: copy `.claude/skills/execution-environment/SKILL.md` to its five copies, `.agents/skills/execution-environment/SKILL.md`, `.github/skills/execution-environment/SKILL.md`, `extensions/drm-copilot/resources/claude-customizations/.claude/skills/execution-environment/SKILL.md`, `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/execution-environment/SKILL.md`, and `extensions/drm-copilot/resources/customizations/.github/skills/execution-environment/SKILL.md`. Copy each `atomic-plan-contract` source to its bundle copy: `extensions/drm-copilot/resources/claude-customizations/.claude/skills/atomic-plan-contract/SKILL.md`, `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/atomic-plan-contract/SKILL.md`, and `extensions/drm-copilot/resources/customizations/.github/skills/atomic-plan-contract/SKILL.md`.
3. Regenerate Codex variants: run `scripts/dev_tools/generate_codex_agent_variants.py` in module form, then run it with `--check`.
4. Restore pinned hashes: not applicable, because `parallel_orchestrator_surface_expectations.py` is outside the reduction path set.
5. Restore contract-test literals: restore the merge-base tests `test_brief_test_isolation_requires_seeded_pester_shuffle` and `test_contract_premortem_test_isolation_requires_seeded_pester_shuffle` in place of `test_brief_test_isolation_states_parallel_gates`, `test_brief_copies_carry_no_removed_run_tokens`, and `test_contract_premortem_test_isolation_states_parallel_gates`. Remove `tests/scripts/claude-runtime/parallel-gate-wording.Tests.ps1`, which the reduction added.
6. Run the contract tests: run `test_execution_environment_brief_contracts.py`, `test_single_pass_preflight_contracts.py`, `test_push_down_claude_resource_contracts.py`, and `test_push_down_codex_and_agents_resource_contracts.py`.

## Revert Signals

- Before #1096 lands, a leak surfaces as a shard-dependent failure.
- Remediation cycles cite order dependence.
