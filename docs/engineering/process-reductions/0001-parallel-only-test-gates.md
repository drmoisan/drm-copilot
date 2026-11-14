# 0001: Parallel-only test gates

## Summary

reduction: 0001
Date: 2026-11-07
Issue: #1094
Merge commit: 278bb7047db986bbb0a8652ca323656ce85f8a08

Removes the repeated test runs that each item performed before review. The Pester, pytest, and Jest gates are now one parallel run each, re-run only after a fix: the local serial and order-varying runs are gone from `## Test Isolation Checks`, plans capture static baselines with no test-suite baseline, and coverage is read from the single gate run against the thresholds, with no earlier figure compared. Test independence remains policy under `.claude/rules/general-unit-test.md`.

The reduction landed across this branch's commits, before the ledger rule reached the branch, so no single commit holds it. This entry's own commit carries the `reduction: 0001` token in its subject.

Rebased over PR #1108 (issue #1106): after `main` merged PR #1108, which renamed the C# test framework to MSTest and the Pester version to Pester v6 and removed another project's example word from the policy-audit instructions, the stored patch sections of the sixteen paths whose reverse check that merge broke were regenerated so that they carry PR #1108's wording; their hunks are unchanged apart from that wording, and every other section is unchanged.

Rebased over #1158: the full-suite pytest commands of `scripts/dev_tools/atomic_executor/qc_runner.py` (`FULL_TEST` and the `full_test` argument of `run_full_loop_with_artifacts`) now start with the test-execution launcher words `TEST_SUITE_LAUNCHER_ARGV` instead of `"poetry",` and `"run",`, and `tests/scripts/dev_tools/atomic_executor/test_qc_runner.py` asserts that argv. The two `qc_runner.py` blocks and the two `test_qc_runner.py` blocks under `### Later Landing: #1096` were regenerated so that their `Current` and `Prior` fences carry the launcher words; the `-n` and `auto` lines they revert are unchanged.

Rebased over #1158 (`fix_all` test steps): the Pester, pytest, Jest, and bats steps of `scripts/dev_tools/fix_all_branches.py` and `scripts/dev_tools/fix_all_branches_extra.py` now run the test-execution launcher suites `pester`, `pytest`, `jest`, and `bats` instead of their direct commands. The Pester-step block of `fix_all_branches.py` was regenerated so that both fences carry the launcher call; its description line still reverts. Two blocks were removed because their text no longer exists in those files: the `Invoke-PoshQCParallelTest` `-Command` block of `fix_all_branches.py` and the `pytest_command` block of `fix_all_branches_extra.py`. Those commands now live in the launcher's `pester` and `pytest` suites (`Invoke-PesterSuite.ps1` calling `Invoke-PoshQCParallelTest`, and `poetry run pytest -n auto` in `Get-TestExecutionPolicyDefault`), so a revert of this entry restores the serial Pester and pytest commands in those suite definitions by hand. The `tests/scripts/dev_tools/test_fix_all_branches.py` block was regenerated to carry the launcher-argv assertions of its three tests.

Rebased over #1158 (preflight QC): the full-suite pytest step of `scripts/dev_tools/atomic_executor/cli_preflight.py` and the `_PYTEST_STEP` constant of `tests/scripts/dev_tools/atomic_executor/test_cli_part3.py` now start with `TEST_SUITE_LAUNCHER_ARGV` instead of `"poetry",` and `"run",`, and `test_preflight_pytest_step_runs_xdist_workers` in `tests/scripts/dev_tools/atomic_executor/test_cli_part2_part2.py` patches the PATH lookup. Those three blocks were regenerated so that both fences carry the new text; the `-n` and `auto` lines and the removed test they revert are unchanged.

## Reason and Evidence

The owner decided on 2026-11-06 that tests run in parallel only. The sequential run existed to detect and fix a leak that has since been fixed, and the overhead of multiple and sequential runs was judged unacceptable.

Measured during Epic #1019, as recorded in the spec's `## Overview`:

- An 8-shard `Invoke-PoshQCParallelTest` run took 448 s.
- Single-process runs over `tests/scripts` took between 899 s and 1,504 s, and one item ran several of them in a single cycle.
- CI repeats the suite on every pull request as 3 shards, so the local single-process run did not match CI.

Removing the repeated runs removes the current means of detecting leaks. #1096 adds a static scan for that purpose.

## Files Changed

The reduction landed in two parts. The first list covers every path the #1094 branch changed from its merge base with `origin/main`, excluding the feature folder, `docs/features/potential/`, and this ledger, with rename detection off. The second list covers the paths of the later landing for #1096, which moved the serial test commands that #1094 deferred to the parallel gates in one commit whose subject carries `reduction: 0001`.

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

Paths of the #1096 landing. The six `execution-environment` copies listed above also changed in it, in the `## Test Runtime` pytest bullet.

- `.vscode/tasks.json`: canonical, with Revert Blocks
- `scripts/dev_tools/atomic_executor/cli_preflight.py`: canonical, with Revert Blocks
- `scripts/dev_tools/atomic_executor/prompt_builder.py`: canonical, with a Revert Block
- `scripts/dev_tools/atomic_executor/qc_runner.py`: canonical, with Revert Blocks
- `scripts/dev_tools/atomic_executor/qc_toolchain.py`: canonical, with a Revert Block
- `scripts/dev_tools/fix_all_branches.py`: canonical, with a Revert Block (one block removed when #1158 moved its command into the launcher)
- `scripts/dev_tools/fix_all_branches_extra.py`: canonical; its Revert Block was removed when #1158 moved its command into the launcher
- `tests/scripts/dev_tools/atomic_executor/test_cli_part2_part2.py`: contract test, with a Revert Block
- `tests/scripts/dev_tools/atomic_executor/test_cli_part3.py`: contract test, with Revert Blocks
- `tests/scripts/dev_tools/atomic_executor/test_prompt_builder.py`: contract test, with a Revert Block
- `tests/scripts/dev_tools/atomic_executor/test_qc_runner.py`: contract test, with Revert Blocks
- `tests/scripts/dev_tools/test_fix_all_branches.py`: contract test, with a Revert Block
- `tests/scripts/workflows/VsCodeQualityTasks.Tests.ps1`: contract test, with a Revert Block

## Stored Patch

`patches/0001-parallel-only-test-gates.patch` holds the reduction as one diff. It is `git diff --binary --no-renames` from the merge base of `origin/main` and the branch head, limited to the paths in `## Files Changed`.

Rebased for stage R (issue #1097): the sections of `.claude/skills/execution-environment/SKILL.md` and its five copies were regenerated so that both images carry the `planning-contract-wording.Tests.ps1` line, which a stage E commit with no entry of its own added to the brief's contract-test list inside the context of the hunk that adds the `parallel-gate-wording.Tests.ps1` line. Their other hunks are unchanged apart from line numbers.

Rebased over PR #1112 (issue #1096): the six brief sections were regenerated so that both images carry the three `Invoke-PoshQCLeakScan` bullets that PR #1112 added inside their hunks; their other hunks are unchanged apart from line numbers.

The check: `git apply -R --check` of the patch succeeds on the tree after every later entry that touches the patch's paths is reverted, newest-first, as README `## Revert Order` states, and then this entry's later landings are reverted; it is not run on the live tree. A failed check on that tree means the surrounding text has moved, and the `## Prior Text` blocks apply instead.

The patch does not hold the edits of the #1096 landing. Those edits are carried only by their Revert Blocks in `## Prior Text`, under `### Later Landing: #1096`.

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

### Later Landing: #1096

The #1096 landing adds the blocks that follow those four. `Get-ProcessReductionRevertBlock` reads only the first fence of each label in a block, so a file whose landing has separate hunks takes one block per hunk under the same path. A block whose `Prior` fence is empty removes test text that the landing added. Each `Prior` fence holds the text of `main` after PR #1108 (issue #1106), which removed the stale package coverage flag from the same commands, so a revert restores `--cov=scripts/dev_tools` as the only coverage source. The coverage-flag hunks of `.vscode/tasks.json` and `scripts/dev_tools/fix_all_branches_extra.py` match `main` after that change and take no block. The brief copies other than `.claude/skills/execution-environment/SKILL.md` take no block, because step 2 re-copies them.

### Revert Block: .claude/skills/execution-environment/SKILL.md

````Current
- Second, build an expensive immutable fixture once per session and hand each test its own copy wherever a test could mutate it, so test independence is unchanged.
- Parallel workers reduce wall-clock time only: they are capped by the slowest test and leave the cost in the product.
- pytest: pass `-n auto` (pytest-xdist) on the command line of the CI step `Run tests with Pytest`, of the parallel VS Code tasks, of the `fix_all` pytest step, and of the full-suite pytest commands of the atomic executor tool (its preflight QC, its full QC loop, and the commands its prompts state), never in `addopts`, because the VS Code Test Explorer keys results to the wrong file when `addopts` carries it. `-n auto` counts physical cores, so a runner can start fewer workers than it has vCPUs; measure it against an explicit count such as `-n 4` before keeping it. pytest-cov combines the worker coverage into one report.
- Pester: parallel validation uses separate Pester 6 processes: `Invoke-PoshQCTest -ShardIndex -ShardCount` on the CI runners and `Invoke-PoshQCParallelTest` locally. Read the per-file `time` of the JUnit `testsuite` elements before changing the shard count or the weights in `config/poshqc-shard-weights.json`.
- A candidate fix can be measured before the tree is edited by loading a pytest plugin module from `SCRATCH` with `-p <module>` and `PYTHONPATH`.
````

````Prior
- Second, build an expensive immutable fixture once per session and hand each test its own copy wherever a test could mutate it, so test independence is unchanged.
- Parallel workers reduce wall-clock time only: they are capped by the slowest test and leave the cost in the product.
- pytest: pass `-n auto` (pytest-xdist) on the command line of the CI step `Run tests with Pytest` and of the parallel VS Code tasks, never in `addopts`, because the VS Code Test Explorer keys results to the wrong file when `addopts` carries it. `-n auto` counts physical cores, so a runner can start fewer workers than it has vCPUs; measure it against an explicit count such as `-n 4` before keeping it. pytest-cov combines the worker coverage into one report.
- Pester: parallel validation uses separate Pester 6 processes: `Invoke-PoshQCTest -ShardIndex -ShardCount` on the CI runners and `Invoke-PoshQCParallelTest` locally. Read the per-file `time` of the JUnit `testsuite` elements before changing the shard count or the weights in `config/poshqc-shard-weights.json`.
- A candidate fix can be measured before the tree is edited by loading a pytest plugin module from `SCRATCH` with `-p <module>` and `PYTHONPATH`.
````

### Revert Block: .vscode/tasks.json

````Current
			],
			"command": "poetry",
			"group": {
				"isDefault": false,
				"kind": "test"
			},
			"label": "QC: 4 Pytest: run tests",
````

````Prior
			],
			"command": "poetry",
			"group": {
				"isDefault": true,
				"kind": "test"
			},
			"label": "QC: 4 Pytest: run tests",
````

### Revert Block: .vscode/tasks.json

````Current
			"command": "poetry",
			"detail": "Runs the pytest suite in pytest-xdist workers (-n auto on the command line, never in addopts).",
			"group": {
				"isDefault": true,
				"kind": "test"
			},
			"label": "QC: 4 Pytest: run tests (parallel)",
````

````Prior
			"command": "poetry",
			"detail": "Runs the pytest suite in pytest-xdist workers (-n auto on the command line, never in addopts).",
			"group": {
				"isDefault": false,
				"kind": "test"
			},
			"label": "QC: 4 Pytest: run tests (parallel)",
````

### Revert Block: .vscode/tasks.json

````Current
		{
			"dependsOn": [
				"TS: 4 Jest: unit tests with coverage",
				"QC: 4 Pytest: run tests with coverage (parallel)",
				"PoshQC: 4 test (Pester, parallel)"
			],
			"dependsOrder": "sequence",
			"detail": "Runs Jest, Python, and PowerShell tests with coverage to refresh all Koverage sources.",
````

````Prior
		{
			"dependsOn": [
				"TS: 4 Jest: unit tests with coverage",
				"QC: 4 Pytest: run tests with coverage",
				"PoshQC: 4 test (Pester)"
			],
			"dependsOrder": "sequence",
			"detail": "Runs Jest, Python, and PowerShell tests with coverage to refresh all Koverage sources.",
````

### Revert Block: .vscode/tasks.json

````Current
				"QC: 1 Black: format",
				"QC: 2 Ruff: lint",
				"QC: 3 Pyright: type-check",
				"QC: 4 Pytest: run tests with coverage (parallel)",
				"PoshQC: 1 format",
				"PoshQC: 2 analyze",
				"PoshQC: 2c leak scan",
				"PoshQC: 4 test (Pester, parallel)"
			],
			"dependsOrder": "sequence",
			"group": {
````

````Prior
				"QC: 1 Black: format",
				"QC: 2 Ruff: lint",
				"QC: 3 Pyright: type-check",
				"QC: Pytest: run tests with coverage",
				"PoshQC: 1 format",
				"PoshQC: 2 analyze",
				"PoshQC: 2c leak scan",
				"PoshQC: 4 test (Pester)"
			],
			"dependsOrder": "sequence",
			"group": {
````

### Revert Block: scripts/dev_tools/fix_all_branches.py

````Current
    if not run_launcher_test_step(
        step_number=4,
        description="Running PowerShell tests (Pester, parallel shards)...",
        step_name="PoshQC: test",
        success_message="PowerShell tests passed",
        failure_message="PowerShell tests failed. Please review errors above.",
        suite="pester",
````

````Prior
    if not run_launcher_test_step(
        step_number=4,
        description="Running PowerShell tests (Pester)...",
        step_name="PoshQC: test",
        success_message="PowerShell tests passed",
        failure_message="PowerShell tests failed. Please review errors above.",
        suite="pester",
````

### Revert Block: scripts/dev_tools/atomic_executor/cli_preflight.py

````Current
                    *TEST_SUITE_LAUNCHER_ARGV,
                    "pytest",
                    "-n",
                    "auto",
                    "--color=no",
                    "--cov=scripts/dev_tools",
                    "--cov-report=term-missing",
````

````Prior
                    *TEST_SUITE_LAUNCHER_ARGV,
                    "pytest",
                    "--color=no",
                    "--cov=scripts/dev_tools",
                    "--cov-report=term-missing",
````

### Revert Block: scripts/dev_tools/atomic_executor/cli_preflight.py

````Current
                "   - `poetry run ruff check`",
                "   - `poetry run pyright`",
                "   - `poetry run pytest -n auto "
                "--cov=scripts/dev_tools --cov-report=term-missing`",
            ]
````

````Prior
                "   - `poetry run ruff check`",
                "   - `poetry run pyright`",
                "   - `poetry run pytest "
                "--cov=scripts/dev_tools --cov-report=term-missing`",
            ]
````

### Revert Block: scripts/dev_tools/atomic_executor/prompt_builder.py

````Current
  - python -m poetry run ruff check
  - python -m poetry run pyright
  - python -m poetry run pytest -n auto \\
      --cov=scripts/dev_tools \\
      --cov-report=term-missing

````

````Prior
  - python -m poetry run ruff check
  - python -m poetry run pyright
  - python -m poetry run pytest \\
      --cov=scripts/dev_tools \\
      --cov-report=term-missing

````

### Revert Block: scripts/dev_tools/atomic_executor/qc_runner.py

````Current
        *TEST_SUITE_LAUNCHER_ARGV,
        "pytest",
        "-n",
        "auto",
        "--color=no",
        "--cov=scripts/dev_tools",
        "--cov-report=xml",
        "--cov-report=term-missing",
````

````Prior
        *TEST_SUITE_LAUNCHER_ARGV,
        "pytest",
        "--color=no",
        "--cov=scripts/dev_tools",
        "--cov-report=xml",
        "--cov-report=term-missing",
````

### Revert Block: scripts/dev_tools/atomic_executor/qc_runner.py

````Current
                *TEST_SUITE_LAUNCHER_ARGV,
                "pytest",
                "-n",
                "auto",
                "--cov=scripts/dev_tools",
                "--cov-report=term-missing",
````

````Prior
                *TEST_SUITE_LAUNCHER_ARGV,
                "pytest",
                "--cov=scripts/dev_tools",
                "--cov-report=term-missing",
````

### Revert Block: scripts/dev_tools/atomic_executor/qc_toolchain.py

````Current
        "run",
        "pytest",
        "-n",
        "auto",
        "--color=no",
        "--cov=scripts/dev_tools",
        "--cov-report=term-missing",
````

````Prior
        "run",
        "pytest",
        "--color=no",
        "--cov=scripts/dev_tools",
        "--cov-report=term-missing",
````

### Revert Block: tests/scripts/dev_tools/atomic_executor/test_cli_part3.py

````Current
        assert "poetry run pytest -n auto" in prompt
````

````Prior
````

### Revert Block: tests/scripts/dev_tools/atomic_executor/test_cli_part3.py

````Current
_PYTEST_STEP = [
    *TEST_SUITE_LAUNCHER_ARGV,
    "pytest",
    "-n",
    "auto",
    "--color=no",
````

````Prior
_PYTEST_STEP = [
    *TEST_SUITE_LAUNCHER_ARGV,
    "pytest",
    "--color=no",
````

### Revert Block: tests/scripts/dev_tools/atomic_executor/test_cli_part2_part2.py

````Current
        assert len(copilot_calls) == 1


class TestPreflightParallelCommand:
    """Tests that the preflight QC pytest step runs on pytest-xdist workers."""

    def test_preflight_pytest_step_runs_xdist_workers(
        self,
        mem_fs_path: Path,
        monkeypatch: "MonkeyPatch",
    ) -> None:
        """The pytest step of _run_preflight_qc_with_capture passes -n auto."""
        from scripts.dev_tools.atomic_executor.cli import _run_preflight_qc_with_capture

        argvs: list[list[str]] = []

        def mock_run(
            argv: list[str], **kwargs: object
        ) -> subprocess.CompletedProcess[str]:
            """Record each argv and report success for every step."""
            argvs.append(list(argv))
            return subprocess.CompletedProcess(
                args=argv, returncode=0, stdout="OK", stderr=""
            )

        monkeypatch.setattr("subprocess.run", mock_run)
        # Keep argv[0] bare so no case depends on pwsh being on PATH (#1158).
        monkeypatch.setattr(
            "scripts.dev_tools.atomic_executor.cli_preflight.shutil.which",
            lambda name: name,
        )

        _run_preflight_qc_with_capture(mem_fs_path)

        # The first recorded argv that names pytest is the pytest step.
        pytest_argv = next(argv for argv in argvs if "pytest" in argv)
        start = pytest_argv.index("pytest")
        assert pytest_argv[start : start + 3] == ["pytest", "-n", "auto"]
        assert "--cov=src/lexile_corpus_tuner" not in pytest_argv
````

````Prior
        assert len(copilot_calls) == 1
````

### Revert Block: tests/scripts/dev_tools/atomic_executor/test_prompt_builder.py

````Current
        assert "python -m poetry run pytest -n auto" in prompt
````

````Prior
````

### Revert Block: tests/scripts/dev_tools/atomic_executor/test_qc_runner.py

````Current
    def test_full_loop_full_test_runs_xdist_workers(
        self, mem_fs_path: Path, monkeypatch: "MonkeyPatch"
    ) -> None:
        """The full_test command of run_full_loop_with_artifacts() passes -n auto."""
        pytest_argv: list[str] = []

        def fake_run_and_record(*args: object, **kwargs: object) -> QCToolResult:
            """Record the pytest argv and report success for every step."""
            argv = kwargs.get("argv")
            if isinstance(argv, list) and "pytest" in argv:
                pytest_argv.extend(cast("list[str]", argv))
            return QCToolResult(step="tool", returncode=0, output="")

        def fake_diff_signature(
            *args: object, **kwargs: object
        ) -> tuple[tuple[str, str, str], ...]:
            """Report an unchanged tree so the loop ends after one pass."""
            return ()

        runner = QCRunner(mem_fs_path)
        monkeypatch.setattr(runner, "_diff_signature", fake_diff_signature)
        monkeypatch.setattr(runner, "_run_and_record", fake_run_and_record)

        # Map each toolchain step to an in-memory artifact path.
        runner.run_full_loop_with_artifacts(
            artifact_paths={
                step: mem_fs_path / f"artifacts/{step}.txt"
                for step in ("black", "ruff", "pyright", "pytest")
            },
            max_loops=1,
        )

        assert pytest_argv[:8] == [*TEST_SUITE_LAUNCHER_ARGV, "pytest", "-n", "auto"]
        assert "--cov=src/lexile_corpus_tuner" not in pytest_argv

    def test_python_toolchain_pytest_command_runs_xdist_workers(self) -> None:
        """PYTHON_TOOLCHAIN_COMMANDS["pytest"] carries -n auto and no stale flag."""
        from scripts.dev_tools.atomic_executor.qc_toolchain import (
            PYTHON_TOOLCHAIN_COMMANDS,
        )

        command = PYTHON_TOOLCHAIN_COMMANDS["pytest"]
        assert command[:5] == ["poetry", "run", "pytest", "-n", "auto"]
        assert "--cov=src/lexile_corpus_tuner" not in command

````

````Prior
````

### Revert Block: tests/scripts/dev_tools/atomic_executor/test_qc_runner.py

````Current
            *TEST_SUITE_LAUNCHER_ARGV,
            "pytest",
            "-n",
            "auto",
            "--color=no",
            "--cov=scripts/dev_tools",
            "--cov-report=xml",
            "--cov-report=term-missing",
````

````Prior
            *TEST_SUITE_LAUNCHER_ARGV,
            "pytest",
            "--color=no",
            "--cov=scripts/dev_tools",
            "--cov-report=xml",
            "--cov-report=term-missing",
````

### Revert Block: tests/scripts/dev_tools/test_fix_all_branches.py

````Current


def test_powershell_test_step_runs_invoke_poshqc_parallel_test() -> None:
    """PoshQC: test runs the launcher pester suite (Invoke-PoshQCParallelTest)."""
    # Arrange
    factory = FakeRunnerFactory(base_success_responses())

    # Act
    fix_all.run_fix_all(
        max_ruff_retries=1,
        include_coverage=True,
        runner_factory=factory,
        logger=build_logger(),
    )

    # Assert
    commands = dict(factory.runners["powershell"].calls)
    assert commands["PoshQC: test"] == [*TEST_SUITE_LAUNCHER_ARGV, "pester"]
    assert "-Suite" not in commands["PoshQC: test"]


def _python_pytest_command(*, include_coverage: bool) -> list[str]:
    """Run the pipeline and return the argv of the python branch pytest step."""
    factory = FakeRunnerFactory(
        base_success_responses(include_coverage=include_coverage)
    )
    fix_all.run_fix_all(
        max_ruff_retries=1,
        include_coverage=include_coverage,
        runner_factory=factory,
        logger=build_logger(),
    )
    step_name = "Pytest: test with coverage" if include_coverage else "Pytest: test"
    return dict(factory.runners["python"].calls)[step_name]


def test_python_branch_pytest_runs_xdist_workers_with_coverage() -> None:
    """run_python_branch runs the launcher pytest suite (-n auto) with coverage."""
    command = _python_pytest_command(include_coverage=True)
    assert command == [
        *TEST_SUITE_LAUNCHER_ARGV,
        "pytest",
        "--cov=scripts/dev_tools",
        "--cov-report=term-missing",
    ]
    assert "--cov=src/lexile_corpus_tuner" not in command


def test_python_branch_pytest_runs_xdist_workers_without_coverage() -> None:
    """run_python_branch runs the launcher pytest suite (-n auto) alone."""
    command = _python_pytest_command(include_coverage=False)
    assert command == [*TEST_SUITE_LAUNCHER_ARGV, "pytest"]
````

````Prior
````

### Revert Block: tests/scripts/workflows/VsCodeQualityTasks.Tests.ps1

````Current

    It 'VT-AGGREGATES-PARALLEL-ONLY makes <Label> depend on the parallel test tasks and on no serial test task' -ForEach @(
        @{ Label = 'QC: Coverage: All Providers' }
        @{ Label = 'QC: 5 Run All Checks' }
    ) {
        $dependsOn = @($script:TaskByLabel[$Label].dependsOn)
        $dependsOn | Should -Contain 'QC: 4 Pytest: run tests with coverage (parallel)'
        $dependsOn | Should -Contain 'PoshQC: 4 test (Pester, parallel)'
        foreach ($serial in @('QC: 4 Pytest: run tests', 'QC: 4 Pytest: run tests with coverage', 'QC: Pytest: run tests with coverage', 'PoshQC: 4 test (Pester)')) {
            $dependsOn | Should -Not -Contain $serial -Because "'$Label' is a gate aggregate and runs no serial test task"
        }
    }

    It 'VT-DEPENDS-ON-RESOLVES resolves every dependsOn name to a task label' {
        $unresolved = foreach ($task in $script:Tasks) {
            $property = $task.PSObject.Properties['dependsOn']
            if ($null -eq $property) { continue }
            foreach ($name in @($property.Value)) {
                if (-not $script:TaskByLabel.ContainsKey([string] $name)) { "$($task.label) -> $name" }
            }
        }
        @($unresolved) | Should -BeNullOrEmpty
    }

    It 'VT-DEFAULT-TEST-TASK makes QC: 4 Pytest: run tests (parallel) the only default of the test group' {
        $defaults = @($script:Tasks | Where-Object {
                $group = $_.PSObject.Properties['group']
                $null -ne $group -and $group.Value -isnot [string] -and $group.Value.kind -eq 'test' -and $group.Value.isDefault -eq $true
            } | ForEach-Object label)
        $defaults | Should -Be @('QC: 4 Pytest: run tests (parallel)')
    }

    It 'VT-SERIAL-TASKS-REMAIN keeps the serial test tasks available for debugging' {
        foreach ($serial in @('QC: 4 Pytest: run tests', 'QC: 4 Pytest: run tests with coverage', 'PoshQC: 4 test (Pester)')) {
            $script:TaskByLabel.ContainsKey($serial) | Should -BeTrue -Because "'$serial' stays for debugging one failure"
        }
    }
````

````Prior
````

## Revert Steps

1. Apply the blocks: revert every later entry that names any path in `## Files Changed`, newest-first, as README `## Revert Order` states; then revert this entry's later landing under `### Later Landing: #1096` by replacing each of its `Current` texts with its `Prior`, because the patch does not hold it; then run `git apply -R` of the patch when its check passes. Otherwise replace each `Current` above that heading with its `Prior`, which restores the core rule, and restore the other paths from the patch text.
2. Re-copy mirrors and bundles: copy `.claude/skills/execution-environment/SKILL.md` to its five copies, `.agents/skills/execution-environment/SKILL.md`, `.github/skills/execution-environment/SKILL.md`, `extensions/drm-copilot/resources/claude-customizations/.claude/skills/execution-environment/SKILL.md`, `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/execution-environment/SKILL.md`, and `extensions/drm-copilot/resources/customizations/.github/skills/execution-environment/SKILL.md`. Copy each `atomic-plan-contract` source to its bundle copy: `extensions/drm-copilot/resources/claude-customizations/.claude/skills/atomic-plan-contract/SKILL.md`, `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/atomic-plan-contract/SKILL.md`, and `extensions/drm-copilot/resources/customizations/.github/skills/atomic-plan-contract/SKILL.md`.
3. Regenerate Codex variants: run `scripts/dev_tools/generate_codex_agent_variants.py` in module form, then run it with `--check`.
4. Restore pinned hashes: not applicable, because `parallel_orchestrator_surface_expectations.py` is outside the reduction path set.
5. Restore contract-test literals: restore the merge-base tests `test_brief_test_isolation_requires_seeded_pester_shuffle` and `test_contract_premortem_test_isolation_requires_seeded_pester_shuffle` in place of `test_brief_test_isolation_states_parallel_gates`, `test_brief_copies_carry_no_removed_run_tokens`, and `test_contract_premortem_test_isolation_states_parallel_gates`. Remove `tests/scripts/claude-runtime/parallel-gate-wording.Tests.ps1`, which the reduction added. For the #1096 landing, the blocks of step 1 restore `test_run_full_runs_all_tools_on_entire_codebase` in `test_qc_runner.py`, `test_build_includes_toolchain_instructions` in `test_prompt_builder.py`, and `test_build_preflight_qc_fix_prompt_includes_workspace` and the module constant `_PYTEST_STEP` in `test_cli_part3.py`, and they remove the tests that landing added: `test_full_loop_full_test_runs_xdist_workers` and `test_python_toolchain_pytest_command_runs_xdist_workers` in `test_qc_runner.py`, `test_preflight_pytest_step_runs_xdist_workers` with its class `TestPreflightParallelCommand` in `test_cli_part2_part2.py`, `test_powershell_test_step_runs_invoke_poshqc_parallel_test`, `test_python_branch_pytest_runs_xdist_workers_with_coverage`, and `test_python_branch_pytest_runs_xdist_workers_without_coverage` in `test_fix_all_branches.py`, and `VT-AGGREGATES-PARALLEL-ONLY`, `VT-DEPENDS-ON-RESOLVES`, `VT-DEFAULT-TEST-TASK`, and `VT-SERIAL-TASKS-REMAIN` in `tests/scripts/workflows/VsCodeQualityTasks.Tests.ps1`. Also remove the `## Test Runtime` entry of `test_brief_passages_state_parallel_gate_facts` in `test_execution_environment_brief_contracts.py`, which asserts the `fix_all` wording of the pytest bullet that step 1 reverts.
6. Run the contract tests: run `test_execution_environment_brief_contracts.py`, `test_single_pass_preflight_contracts.py`, `test_push_down_claude_resource_contracts.py`, and `test_push_down_codex_and_agents_resource_contracts.py`. For the #1096 landing, also run `tests/scripts/dev_tools/atomic_executor/test_qc_runner.py`, `test_prompt_builder.py`, `test_cli_part3.py`, `test_cli_part2_part2.py`, `tests/scripts/dev_tools/test_fix_all_branches.py`, and `tests/scripts/workflows/VsCodeQualityTasks.Tests.ps1`.

## Revert Signals

- A leak that `Invoke-PoshQCLeakScan` misses surfaces as a shard-dependent failure.
- Remediation cycles cite order dependence.

## Partial Revert

The owner decided on 2026-11-07 to restore the test-suite baseline and to keep every parallel-only rule of this entry. Entry `0006` (`0006-test-suite-baseline-restored.md`) records that partial revert, so reverting `0006` re-applies this entry's baseline removal. `0006` restores these parts of this entry, each as one run of the parallel gate, the `Phase 0 baseline`:

- B1: the Phase 0 test-suite baseline of `## Phase 0 Requirements`, the short-path baseline capture bullet and its baseline test-step artifact bullet, and the final-QC post-change coverage wording in the three `atomic-plan-contract` sources and their bundles.
- B2: the baseline half of `## Coverage Evidence Contract (Mandatory when policy requires coverage)`.
- B3: the minor-audit baseline evidence of `## Mode-Specific Mandatory Plan Gates`.
- B4: the brief's coverage bullet in `## Coverage and File-Size Gates` and the `parallel-gate-wording.Tests.ps1` description, in all six copies.
- B5: the policy-audit template's numeric baseline cells, baseline artifact lines, verdict and fail-closed rules, the `Baseline Coverage Documented` and `No Coverage Regression` rows, the comparison bullet, and the fail-closed reminder.
- B6: the audit instructions' baseline coverage, the comparison with the baseline, the worked example, the verdict and fail-closed lines, and the metrics summary.
- B7: the review rules for modified files (no regression on changed lines), the PowerShell no-regression clause, the blocking clause, and the scope of the `N/A - no pre-change run` record.
- B8: the QA gates' Phase A baseline record and `Delta Requirements`, reporting, and evidence storage.
- B9: the planner, executor, typed engineers, `invoke-*-engineer` skills, remediation handoff, and `orchestrator-workflow` baseline wording, with their Codex bases and generated variants.
- B10: the Copilot executors, planners, orchestrators, typed and test engineers, `execute-hard-lock` prompts, and their Codex counterparts.
- B11: the plan templates' fail-closed rule and coverage-evidence lines.

Not restored: every serial, single-process, seeded-shuffle, reversed-order, targeted, per-batch, or comparison run, the `Invoke-PoshQCTest` and bare `poetry run pytest` commands, and `## Test Isolation Checks`. This entry's `## Prior Text` blocks are unchanged by `0006`.
