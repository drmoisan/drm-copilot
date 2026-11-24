# 0014: Targeted test cadence

## Summary

reduction: 0014
Date: 2026-11-24
Issue: #1228
Merge commit: pending (PR #1228)

Limits the full test suite of each language gate to the `Phase 0 baseline` and the final QA loop of an orchestration; every other test run runs a test selection. `## Test Cadence (Mandatory)` in the `atomic-plan-contract` skill gains a first bullet that states this, and its phase gate keeps stages 1 to 6 (format, lint, type check, architecture-boundary tests, and contract checks across the repository) but runs its unit stage over the union of the test selections of the phase's tasks, through the launcher in parallel, with no coverage, recording "no selected tests" for a language with an empty union. Two bullets are added: a remediation gate (task checks per task, then one remediation gate in phase-gate form over the union of the cycle's task selections, in coverage mode for each changed language, with the remediation plan's Phase 0 citing the orchestration's `Phase 0 baseline` artifact and light cycles unchanged), and a sync check (the local gate after a main sync, an integration sync, an early-start sync, or the regenerate path is the phase-gate form whose unit stage runs the selection of the paths the merge changed). Every surface that restated the earlier cadence sentence now carries reference sentence R1; the orchestrate regenerate path, the QA-gate skills, the typed engineers, the feature-review coverage step, the scoped Pester runs of the test-execution policy, the remediation handoff, the execution-environment brief, the Copilot executor and planner agents, the hard-lock prompts, and the plan templates follow the same rule. Remediation cycle 1 scopes the coverage source: in the QA-gate skills the overall coverage delta binds only the final QA loop and the remediation gate's selection run is its gate run, and the feature-review agent, step 5 of `feature-review-workflow`, and the policy-audit template read repository-wide totals from the final-QC artifact and `## CI Cross-check`, with a local coverage file from a selection run supplying per-file figures only. Remediation cycle 2 adds the run-scope record: after each suite run the test-execution launcher writes `artifacts/test-execution/run-scope.<suite>.json`, and the feature-review coverage hook and its Codex twin grade a coverage report covered by a `selection` record of its suite as per-file evidence, with no repo-wide line or branch floor, while every other report keeps the repo-wide check. The `Merge commit:` line carries pull request number #1228 as the stand-in, as entries `0005` and `0011` did, until the orchestrator back-fills it.

## Reason and Evidence

The owner objective, verbatim: "The full test suite for any destination repo should only be run at the beginning of the orchestration and in the qc run. everything else should be targeted tests. this change should be reflected in every rule that operates otherwise for all orchestrators." The rules before this change ran the full unit suite at every `[phase-gate]` task, and some skills also required it for remediation cycles and post-merge sync checks, so a large destination repository repeated a multi-minute full run many times per orchestration. The design basis is `.dev/active/1228-targeted-test-cadence/research/research.2026-11-23T12-00.md` and the decisions D1 to D10 of `.dev/active/1228-targeted-test-cadence/spec.md`. The measurement basis is the pair of full runs that the reduced cadence keeps: the `Phase 0 baseline` and the final QA loop compare repository-wide coverage and failing tests, and CI on the pull-request head remains the merge gate.

Recorded as unchanged: decision D6, the Python atomic executor CLI under `scripts/dev_tools/atomic_executor/` (a repository-local developer tool that is not pushed down; the brief's description of its "phase-gate QC loop" stays accurate), and decision D10, the standalone Copilot agents and prompts (`staged-review`, `commentary-remediation`, the `remediate-comments` prompt, the three Copilot typed engineers, `pytest-unit-test-coding`, `Powershell DI Unit Test Engineer`, `python-execution-only-typed`), which are not orchestrator steps. Decision D5 also leaves the frozen epic surfaces unchanged; their "re-run the local gate" step is defined by the new `Sync check` bullet. The owner objective authorizes the edits to the rule sources under `scripts/harness-generation/sources/rules/` and their generated `.claude/rules/` and `.github/instructions/` outputs for issue #1228 only. The time saved per orchestration is unknown until stage timing records an orchestration under the new cadence.

## Files Changed

Derivation: the paths of the item's own diff, `git diff --name-only --no-renames <merge base>` of the working tree against the merge base of `origin/main` and `HEAD`, together with the untracked paths of `git status --porcelain`, taken before the orchestrator commit. That merge base is the `origin/main` commit merged into the branch before this entry was written, so the set holds no file that arrived from the main merge. Excluded: the ledger folder (this entry, `patches/0014-targeted-test-cadence.patch`, and the `README.md` index row), the feature folder `.dev/active/1228-targeted-test-cadence/`, which moves at closure, and the promotion record `.dev/potential/promoted/2026-11-23-targeted-test-cadence.md`, a lifecycle record of the item that a revert of this reduction must not delete. The three plan templates and the policy-audit template are recorded under their earlier key `docs/features/templates/`, which the chain reads from `.dev/templates/`, so that this entry names each plan template by the key that entries `0005` and `0011` use and the policy-audit template by the key that entries `0001`, `0006`, and `0009` use.

- `.agents/skills/atomic-executor/SKILL.md`, source
- `.agents/skills/atomic-plan-contract/SKILL.md`, source
- `.agents/skills/atomic-planner/SKILL.md`, source
- `.agents/skills/csharp/SKILL.md`, generated by `scripts/harness-generation/Invoke-HarnessGeneration.ps1` from `scripts/harness-generation/sources/rules/csharp.md`
- `.agents/skills/csharp-qa-gate/SKILL.md`, source
- `.agents/skills/execution-environment/SKILL.md`, source
- `.agents/skills/feature-review-workflow/SKILL.md`, source
- `.agents/skills/general-code-change/SKILL.md`, generated by `scripts/harness-generation/Invoke-HarnessGeneration.ps1` from `scripts/harness-generation/sources/rules/general-code-change.md`
- `.agents/skills/orchestrate/SKILL.md`, source
- `.agents/skills/powershell/SKILL.md`, generated by `scripts/harness-generation/Invoke-HarnessGeneration.ps1` from `scripts/harness-generation/sources/rules/powershell.md`
- `.agents/skills/powershell-qa-gate/SKILL.md`, source
- `.agents/skills/python/SKILL.md`, generated by `scripts/harness-generation/Invoke-HarnessGeneration.ps1` from `scripts/harness-generation/sources/rules/python.md`
- `.agents/skills/python-qa-gate/SKILL.md`, source
- `.agents/skills/remediation-handoff-atomic-planner/SKILL.md`, source
- `.agents/skills/test-execution-policy/SKILL.md`, source
- `.agents/skills/test-execution-policy/scripts/Invoke-TestSuite.ps1`, source
- `.agents/skills/typescript/SKILL.md`, generated by `scripts/harness-generation/Invoke-HarnessGeneration.ps1` from `scripts/harness-generation/sources/rules/typescript.md`
- `.claude/agents/atomic-executor.md`, generated by `scripts/harness-generation/Invoke-HarnessGeneration.ps1` from `scripts/harness-generation/sources/agents/atomic-executor.md`
- `.claude/agents/atomic-planner.md`, generated by `scripts/harness-generation/Invoke-HarnessGeneration.ps1` from `scripts/harness-generation/sources/agents/atomic-planner.md`
- `.claude/agents/csharp-typed-engineer.md`, generated by `scripts/harness-generation/Invoke-HarnessGeneration.ps1` from `scripts/harness-generation/sources/agents/csharp-typed-engineer.md`
- `.claude/agents/feature-review.md`, generated by `scripts/harness-generation/Invoke-HarnessGeneration.ps1` from `scripts/harness-generation/sources/agents/feature-review.md`
- `.claude/agents/powershell-typed-engineer.md`, generated by `scripts/harness-generation/Invoke-HarnessGeneration.ps1` from `scripts/harness-generation/sources/agents/powershell-typed-engineer.md`
- `.claude/agents/python-typed-engineer.md`, generated by `scripts/harness-generation/Invoke-HarnessGeneration.ps1` from `scripts/harness-generation/sources/agents/python-typed-engineer.md`
- `.claude/hooks/validate-feature-review-coverage.ps1`, source
- `.claude/hooks/validate-feature-review-coverage-freshness.ps1`, source
- `.claude/rules/csharp.md`, generated by `scripts/harness-generation/Invoke-HarnessGeneration.ps1` from `scripts/harness-generation/sources/rules/csharp.md`
- `.claude/rules/general-code-change.md`, generated by `scripts/harness-generation/Invoke-HarnessGeneration.ps1` from `scripts/harness-generation/sources/rules/general-code-change.md`
- `.claude/rules/powershell.md`, generated by `scripts/harness-generation/Invoke-HarnessGeneration.ps1` from `scripts/harness-generation/sources/rules/powershell.md`
- `.claude/rules/python.md`, generated by `scripts/harness-generation/Invoke-HarnessGeneration.ps1` from `scripts/harness-generation/sources/rules/python.md`
- `.claude/rules/shell.md`, generated by `scripts/harness-generation/Invoke-HarnessGeneration.ps1` from `scripts/harness-generation/sources/rules/shell.md`
- `.claude/rules/typescript.md`, generated by `scripts/harness-generation/Invoke-HarnessGeneration.ps1` from `scripts/harness-generation/sources/rules/typescript.md`
- `.claude/skills/atomic-plan-contract/SKILL.md`, source
- `.claude/skills/csharp-qa-gate/SKILL.md`, source
- `.claude/skills/execution-environment/SKILL.md`, generated by `scripts/harness-generation/Invoke-HarnessGeneration.ps1` from `.agents/skills/execution-environment/SKILL.md`
- `.claude/skills/feature-review-workflow/SKILL.md`, source
- `.claude/skills/orchestrate/SKILL.md`, source
- `.claude/skills/powershell-qa-gate/SKILL.md`, source
- `.claude/skills/python-qa-gate/SKILL.md`, source
- `.claude/skills/remediation-handoff-atomic-planner/SKILL.md`, generated by `scripts/harness-generation/Invoke-HarnessGeneration.ps1` from `.agents/skills/remediation-handoff-atomic-planner/SKILL.md`
- `.claude/skills/test-execution-policy/SKILL.md`, generated by `scripts/harness-generation/Invoke-HarnessGeneration.ps1` from `.agents/skills/test-execution-policy/SKILL.md`
- `.claude/skills/test-execution-policy/scripts/Invoke-TestSuite.ps1`, generated by `scripts/harness-generation/Invoke-HarnessGeneration.ps1` from `.agents/skills/test-execution-policy/scripts/Invoke-TestSuite.ps1`
- `.codex/agents/atomic-executor.toml`, generated by `scripts/harness-generation/Invoke-HarnessGeneration.ps1` from `scripts/harness-generation/sources/agents/atomic-executor.md`
- `.codex/agents/atomic-executor-c1.toml`, a generated Codex variant
- `.codex/agents/atomic-executor-c2.toml`, a generated Codex variant
- `.codex/agents/atomic-executor-c3.toml`, a generated Codex variant
- `.codex/agents/atomic-executor-c3-elevated.toml`, a generated Codex variant
- `.codex/agents/atomic-executor-c4.toml`, a generated Codex variant
- `.codex/agents/atomic-planner.toml`, generated by `scripts/harness-generation/Invoke-HarnessGeneration.ps1` from `scripts/harness-generation/sources/agents/atomic-planner.md`
- `.codex/agents/atomic-planner-c1.toml`, a generated Codex variant
- `.codex/agents/atomic-planner-c2.toml`, a generated Codex variant
- `.codex/agents/atomic-planner-c3.toml`, a generated Codex variant
- `.codex/agents/atomic-planner-c3-elevated.toml`, a generated Codex variant
- `.codex/agents/atomic-planner-c4.toml`, a generated Codex variant
- `.codex/agents/csharp-typed-engineer.toml`, generated by `scripts/harness-generation/Invoke-HarnessGeneration.ps1` from `scripts/harness-generation/sources/agents/csharp-typed-engineer.md`
- `.codex/agents/csharp-typed-engineer-c1.toml`, a generated Codex variant
- `.codex/agents/csharp-typed-engineer-c2.toml`, a generated Codex variant
- `.codex/agents/csharp-typed-engineer-c3.toml`, a generated Codex variant
- `.codex/agents/csharp-typed-engineer-c3-elevated.toml`, a generated Codex variant
- `.codex/agents/csharp-typed-engineer-c4.toml`, a generated Codex variant
- `.codex/agents/feature-review.toml`, generated by `scripts/harness-generation/Invoke-HarnessGeneration.ps1` from `scripts/harness-generation/sources/agents/feature-review.md`
- `.codex/agents/powershell-typed-engineer.toml`, generated by `scripts/harness-generation/Invoke-HarnessGeneration.ps1` from `scripts/harness-generation/sources/agents/powershell-typed-engineer.md`
- `.codex/agents/powershell-typed-engineer-c1.toml`, a generated Codex variant
- `.codex/agents/powershell-typed-engineer-c2.toml`, a generated Codex variant
- `.codex/agents/powershell-typed-engineer-c3.toml`, a generated Codex variant
- `.codex/agents/powershell-typed-engineer-c3-elevated.toml`, a generated Codex variant
- `.codex/agents/powershell-typed-engineer-c4.toml`, a generated Codex variant
- `.codex/agents/python-typed-engineer.toml`, generated by `scripts/harness-generation/Invoke-HarnessGeneration.ps1` from `scripts/harness-generation/sources/agents/python-typed-engineer.md`
- `.codex/agents/python-typed-engineer-c1.toml`, a generated Codex variant
- `.codex/agents/python-typed-engineer-c2.toml`, a generated Codex variant
- `.codex/agents/python-typed-engineer-c3.toml`, a generated Codex variant
- `.codex/agents/python-typed-engineer-c3-elevated.toml`, a generated Codex variant
- `.codex/agents/python-typed-engineer-c4.toml`, a generated Codex variant
- `.codex/hooks/validate-feature-review-coverage.ps1`, source
- `.codex/hooks/validate-feature-review-coverage-freshness.ps1`, source
- `docs/features/templates/bug/plan.yyyy-MM-ddTHH-mm.md`, source (recorded under its earlier key; the file is at `.dev/templates/bug/plan.yyyy-MM-ddTHH-mm.md`)
- `docs/features/templates/feature/plan.yyyy-MM-ddTHH-mm.md`, source (recorded under its earlier key; the file is at `.dev/templates/feature/plan.yyyy-MM-ddTHH-mm.md`)
- `docs/features/templates/policy_audit/policy-audit.yyyy-MM-ddTHH-mm.md`, source (recorded under its earlier key; the file is at `.dev/templates/policy_audit/policy-audit.yyyy-MM-ddTHH-mm.md`)
- `docs/features/templates/refactor/plan.yyyy-MM-ddTHH-mm.md`, source (recorded under its earlier key; the file is at `.dev/templates/refactor/plan.yyyy-MM-ddTHH-mm.md`)
- `.github/agents/atomic_executor.agent.md`, source
- `.github/agents/atomic_planning.agent.md`, source
- `.github/agents/csharp-atomic-executor.agent.md`, source
- `.github/agents/csharp-atomic-planning.agent.md`, source
- `.github/agents/powershell-atomic-executor.agent.md`, source
- `.github/agents/powershell-atomic-planning.agent.md`, source
- `.github/agents/python-atomic-executor.agent.md`, source
- `.github/agents/python-atomic-planning.agent.md`, source
- `.github/codex/execute-hard-lock.prompt.md`, source
- `.github/codex/resume-hard-lock.prompt.md`, source
- `.github/instructions/general-code-change.instructions.md`, generated by `scripts/harness-generation/Invoke-HarnessGeneration.ps1` from `scripts/harness-generation/sources/rules/general-code-change.md`
- `.github/prompts/execute-hard-lock.prompt.md`, source
- `AGENTS.md`, source
- `extensions/drm-copilot/resources/claude-customizations/.claude/agents/atomic-executor.md`, a byte-identical copy of `.claude/agents/atomic-executor.md`
- `extensions/drm-copilot/resources/claude-customizations/.claude/agents/atomic-planner.md`, a byte-identical copy of `.claude/agents/atomic-planner.md`
- `extensions/drm-copilot/resources/claude-customizations/.claude/agents/csharp-typed-engineer.md`, a byte-identical copy of `.claude/agents/csharp-typed-engineer.md`
- `extensions/drm-copilot/resources/claude-customizations/.claude/agents/feature-review.md`, a byte-identical copy of `.claude/agents/feature-review.md`
- `extensions/drm-copilot/resources/claude-customizations/.claude/agents/powershell-typed-engineer.md`, a byte-identical copy of `.claude/agents/powershell-typed-engineer.md`
- `extensions/drm-copilot/resources/claude-customizations/.claude/agents/python-typed-engineer.md`, a byte-identical copy of `.claude/agents/python-typed-engineer.md`
- `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/validate-feature-review-coverage.ps1`, a byte-identical copy of `.claude/hooks/validate-feature-review-coverage.ps1`
- `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/validate-feature-review-coverage-freshness.ps1`, a byte-identical copy of `.claude/hooks/validate-feature-review-coverage-freshness.ps1`
- `extensions/drm-copilot/resources/claude-customizations/.claude/rules/csharp.md`, a byte-identical copy of `.claude/rules/csharp.md`
- `extensions/drm-copilot/resources/claude-customizations/.claude/rules/general-code-change.md`, a byte-identical copy of `.claude/rules/general-code-change.md`
- `extensions/drm-copilot/resources/claude-customizations/.claude/rules/powershell.md`, a byte-identical copy of `.claude/rules/powershell.md`
- `extensions/drm-copilot/resources/claude-customizations/.claude/rules/python.md`, a byte-identical copy of `.claude/rules/python.md`
- `extensions/drm-copilot/resources/claude-customizations/.claude/rules/shell.md`, a byte-identical copy of `.claude/rules/shell.md`
- `extensions/drm-copilot/resources/claude-customizations/.claude/rules/typescript.md`, a byte-identical copy of `.claude/rules/typescript.md`
- `extensions/drm-copilot/resources/claude-customizations/.claude/skills/atomic-plan-contract/SKILL.md`, a byte-identical copy of `.claude/skills/atomic-plan-contract/SKILL.md`
- `extensions/drm-copilot/resources/claude-customizations/.claude/skills/csharp-qa-gate/SKILL.md`, a byte-identical copy of `.claude/skills/csharp-qa-gate/SKILL.md`
- `extensions/drm-copilot/resources/claude-customizations/.claude/skills/execution-environment/SKILL.md`, a byte-identical copy of `.claude/skills/execution-environment/SKILL.md`
- `extensions/drm-copilot/resources/claude-customizations/.claude/skills/feature-review-workflow/SKILL.md`, a byte-identical copy of `.claude/skills/feature-review-workflow/SKILL.md`
- `extensions/drm-copilot/resources/claude-customizations/.claude/skills/orchestrate/SKILL.md`, a byte-identical copy of `.claude/skills/orchestrate/SKILL.md`
- `extensions/drm-copilot/resources/claude-customizations/.claude/skills/powershell-qa-gate/SKILL.md`, a byte-identical copy of `.claude/skills/powershell-qa-gate/SKILL.md`
- `extensions/drm-copilot/resources/claude-customizations/.claude/skills/python-qa-gate/SKILL.md`, a byte-identical copy of `.claude/skills/python-qa-gate/SKILL.md`
- `extensions/drm-copilot/resources/claude-customizations/.claude/skills/remediation-handoff-atomic-planner/SKILL.md`, a byte-identical copy of `.claude/skills/remediation-handoff-atomic-planner/SKILL.md`
- `extensions/drm-copilot/resources/claude-customizations/.claude/skills/test-execution-policy/SKILL.md`, a byte-identical copy of `.claude/skills/test-execution-policy/SKILL.md`
- `extensions/drm-copilot/resources/claude-customizations/.claude/skills/test-execution-policy/scripts/Invoke-TestSuite.ps1`, a byte-identical copy of `.claude/skills/test-execution-policy/scripts/Invoke-TestSuite.ps1`
- `extensions/drm-copilot/resources/claude-customizations/.claude-variants/csharp-legacy/agents/csharp-typed-engineer.md`, a bundle-only source
- `extensions/drm-copilot/resources/claude-customizations/.claude-variants/csharp-legacy/rules/csharp.md`, a bundle-only source
- `extensions/drm-copilot/resources/claude-customizations/.claude-variants/csharp-legacy/skills/csharp-qa-gate/SKILL.md`, a bundle-only source
- `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/atomic-executor/SKILL.md`, a byte-identical copy of `.agents/skills/atomic-executor/SKILL.md`
- `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/atomic-plan-contract/SKILL.md`, a byte-identical copy of `.agents/skills/atomic-plan-contract/SKILL.md`
- `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/atomic-planner/SKILL.md`, a byte-identical copy of `.agents/skills/atomic-planner/SKILL.md`
- `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/csharp/SKILL.md`, a byte-identical copy of `.agents/skills/csharp/SKILL.md`
- `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/csharp-qa-gate/SKILL.md`, a byte-identical copy of `.agents/skills/csharp-qa-gate/SKILL.md`
- `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/execution-environment/SKILL.md`, a byte-identical copy of `.agents/skills/execution-environment/SKILL.md`
- `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/feature-review-workflow/SKILL.md`, a byte-identical copy of `.agents/skills/feature-review-workflow/SKILL.md`
- `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/general-code-change/SKILL.md`, a byte-identical copy of `.agents/skills/general-code-change/SKILL.md`
- `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/orchestrate/SKILL.md`, a byte-identical copy of `.agents/skills/orchestrate/SKILL.md`
- `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/powershell/SKILL.md`, a byte-identical copy of `.agents/skills/powershell/SKILL.md`
- `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/powershell-qa-gate/SKILL.md`, a byte-identical copy of `.agents/skills/powershell-qa-gate/SKILL.md`
- `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/python/SKILL.md`, a byte-identical copy of `.agents/skills/python/SKILL.md`
- `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/python-qa-gate/SKILL.md`, a byte-identical copy of `.agents/skills/python-qa-gate/SKILL.md`
- `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/remediation-handoff-atomic-planner/SKILL.md`, a byte-identical copy of `.agents/skills/remediation-handoff-atomic-planner/SKILL.md`
- `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/test-execution-policy/SKILL.md`, a byte-identical copy of `.agents/skills/test-execution-policy/SKILL.md`
- `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/test-execution-policy/scripts/Invoke-TestSuite.ps1`, a byte-identical copy of `.agents/skills/test-execution-policy/scripts/Invoke-TestSuite.ps1`
- `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/typescript/SKILL.md`, a byte-identical copy of `.agents/skills/typescript/SKILL.md`
- `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents-variants/csharp-legacy/skills/csharp/SKILL.md`, a bundle-only source
- `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents-variants/csharp-legacy/skills/csharp-qa-gate/SKILL.md`, a bundle-only source
- `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/atomic-executor.toml`, a byte-identical copy of `.codex/agents/atomic-executor.toml`
- `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/atomic-executor-c1.toml`, a byte-identical copy of `.codex/agents/atomic-executor-c1.toml`
- `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/atomic-executor-c2.toml`, a byte-identical copy of `.codex/agents/atomic-executor-c2.toml`
- `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/atomic-executor-c3.toml`, a byte-identical copy of `.codex/agents/atomic-executor-c3.toml`
- `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/atomic-executor-c3-elevated.toml`, a byte-identical copy of `.codex/agents/atomic-executor-c3-elevated.toml`
- `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/atomic-executor-c4.toml`, a byte-identical copy of `.codex/agents/atomic-executor-c4.toml`
- `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/atomic-planner.toml`, a byte-identical copy of `.codex/agents/atomic-planner.toml`
- `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/atomic-planner-c1.toml`, a byte-identical copy of `.codex/agents/atomic-planner-c1.toml`
- `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/atomic-planner-c2.toml`, a byte-identical copy of `.codex/agents/atomic-planner-c2.toml`
- `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/atomic-planner-c3.toml`, a byte-identical copy of `.codex/agents/atomic-planner-c3.toml`
- `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/atomic-planner-c3-elevated.toml`, a byte-identical copy of `.codex/agents/atomic-planner-c3-elevated.toml`
- `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/atomic-planner-c4.toml`, a byte-identical copy of `.codex/agents/atomic-planner-c4.toml`
- `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/csharp-typed-engineer.toml`, a byte-identical copy of `.codex/agents/csharp-typed-engineer.toml`
- `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/csharp-typed-engineer-c1.toml`, a byte-identical copy of `.codex/agents/csharp-typed-engineer-c1.toml`
- `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/csharp-typed-engineer-c2.toml`, a byte-identical copy of `.codex/agents/csharp-typed-engineer-c2.toml`
- `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/csharp-typed-engineer-c3.toml`, a byte-identical copy of `.codex/agents/csharp-typed-engineer-c3.toml`
- `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/csharp-typed-engineer-c3-elevated.toml`, a byte-identical copy of `.codex/agents/csharp-typed-engineer-c3-elevated.toml`
- `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/csharp-typed-engineer-c4.toml`, a byte-identical copy of `.codex/agents/csharp-typed-engineer-c4.toml`
- `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/feature-review.toml`, a byte-identical copy of `.codex/agents/feature-review.toml`
- `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/powershell-typed-engineer.toml`, a byte-identical copy of `.codex/agents/powershell-typed-engineer.toml`
- `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/powershell-typed-engineer-c1.toml`, a byte-identical copy of `.codex/agents/powershell-typed-engineer-c1.toml`
- `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/powershell-typed-engineer-c2.toml`, a byte-identical copy of `.codex/agents/powershell-typed-engineer-c2.toml`
- `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/powershell-typed-engineer-c3.toml`, a byte-identical copy of `.codex/agents/powershell-typed-engineer-c3.toml`
- `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/powershell-typed-engineer-c3-elevated.toml`, a byte-identical copy of `.codex/agents/powershell-typed-engineer-c3-elevated.toml`
- `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/powershell-typed-engineer-c4.toml`, a byte-identical copy of `.codex/agents/powershell-typed-engineer-c4.toml`
- `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/python-typed-engineer.toml`, a byte-identical copy of `.codex/agents/python-typed-engineer.toml`
- `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/python-typed-engineer-c1.toml`, a byte-identical copy of `.codex/agents/python-typed-engineer-c1.toml`
- `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/python-typed-engineer-c2.toml`, a byte-identical copy of `.codex/agents/python-typed-engineer-c2.toml`
- `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/python-typed-engineer-c3.toml`, a byte-identical copy of `.codex/agents/python-typed-engineer-c3.toml`
- `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/python-typed-engineer-c3-elevated.toml`, a byte-identical copy of `.codex/agents/python-typed-engineer-c3-elevated.toml`
- `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/python-typed-engineer-c4.toml`, a byte-identical copy of `.codex/agents/python-typed-engineer-c4.toml`
- `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/validate-feature-review-coverage.ps1`, a byte-identical copy of `.codex/hooks/validate-feature-review-coverage.ps1`
- `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/validate-feature-review-coverage-freshness.ps1`, a byte-identical copy of `.codex/hooks/validate-feature-review-coverage-freshness.ps1`
- `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex-variants/csharp-legacy/agents/csharp-typed-engineer.toml`, a bundle-only source
- `extensions/drm-copilot/resources/codex-and-agents-customizations/AGENTS.md`, a byte-identical copy of `AGENTS.md`
- `extensions/drm-copilot/resources/customizations/.github/agents/atomic_executor.agent.md`, a byte-identical copy of `.github/agents/atomic_executor.agent.md`
- `extensions/drm-copilot/resources/customizations/.github/agents/atomic_planning.agent.md`, a byte-identical copy of `.github/agents/atomic_planning.agent.md`
- `extensions/drm-copilot/resources/customizations/.github/agents/csharp-atomic-executor.agent.md`, a byte-identical copy of `.github/agents/csharp-atomic-executor.agent.md`
- `extensions/drm-copilot/resources/customizations/.github/agents/csharp-atomic-planning.agent.md`, a byte-identical copy of `.github/agents/csharp-atomic-planning.agent.md`
- `extensions/drm-copilot/resources/customizations/.github/agents/powershell-atomic-executor.agent.md`, a byte-identical copy of `.github/agents/powershell-atomic-executor.agent.md`
- `extensions/drm-copilot/resources/customizations/.github/agents/powershell-atomic-planning.agent.md`, a byte-identical copy of `.github/agents/powershell-atomic-planning.agent.md`
- `extensions/drm-copilot/resources/customizations/.github/agents/python-atomic-executor.agent.md`, a byte-identical copy of `.github/agents/python-atomic-executor.agent.md`
- `extensions/drm-copilot/resources/customizations/.github/agents/python-atomic-planning.agent.md`, a byte-identical copy of `.github/agents/python-atomic-planning.agent.md`
- `extensions/drm-copilot/resources/customizations/.github/codex/execute-hard-lock.prompt.md`, a byte-identical copy of `.github/codex/execute-hard-lock.prompt.md`
- `extensions/drm-copilot/resources/customizations/.github/codex/resume-hard-lock.prompt.md`, a byte-identical copy of `.github/codex/resume-hard-lock.prompt.md`
- `extensions/drm-copilot/resources/customizations/.github/instructions/general-code-change.instructions.md`, a byte-identical copy of `.github/instructions/general-code-change.instructions.md`
- `extensions/drm-copilot/resources/customizations/.github/prompts/execute-hard-lock.prompt.md`, a byte-identical copy of `.github/prompts/execute-hard-lock.prompt.md`
- `extensions/drm-copilot/resources/feature-templates/bug/plan.yyyy-MM-ddTHH-mm.md`, a byte-identical copy of `docs/features/templates/bug/plan.yyyy-MM-ddTHH-mm.md` (now at `.dev/templates/bug/plan.yyyy-MM-ddTHH-mm.md`)
- `extensions/drm-copilot/resources/feature-templates/feature/plan.yyyy-MM-ddTHH-mm.md`, a byte-identical copy of `docs/features/templates/feature/plan.yyyy-MM-ddTHH-mm.md` (now at `.dev/templates/feature/plan.yyyy-MM-ddTHH-mm.md`)
- `extensions/drm-copilot/resources/feature-templates/refactor/plan.yyyy-MM-ddTHH-mm.md`, a byte-identical copy of `docs/features/templates/refactor/plan.yyyy-MM-ddTHH-mm.md` (now at `.dev/templates/refactor/plan.yyyy-MM-ddTHH-mm.md`)
- `extensions/drm-copilot/resources/templates/policy_audit/policy-audit.yyyy-MM-ddTHH-mm.md`, a byte-identical copy of `docs/features/templates/policy_audit/policy-audit.yyyy-MM-ddTHH-mm.md` (now at `.dev/templates/policy_audit/policy-audit.yyyy-MM-ddTHH-mm.md`)
- `scripts/harness-generation/sources/agents/atomic-executor.md`, source
- `scripts/harness-generation/sources/agents/atomic-planner.md`, source
- `scripts/harness-generation/sources/agents/csharp-typed-engineer.md`, source
- `scripts/harness-generation/sources/agents/feature-review.md`, source
- `scripts/harness-generation/sources/agents/powershell-typed-engineer.md`, source
- `scripts/harness-generation/sources/agents/python-typed-engineer.md`, source
- `scripts/harness-generation/sources/rules/csharp.md`, source
- `scripts/harness-generation/sources/rules/general-code-change.md`, source
- `scripts/harness-generation/sources/rules/powershell.md`, source
- `scripts/harness-generation/sources/rules/python.md`, source
- `scripts/harness-generation/sources/rules/shell.md`, source
- `scripts/harness-generation/sources/rules/typescript.md`, source
- `tests/scripts/claude-hooks/validate-feature-review-coverage.RunScope.Tests.ps1`, unit test, created
- `tests/scripts/claude-hooks/validate-feature-review-coverage-freshness.Tests.ps1`, unit test, updated
- `tests/scripts/claude-runtime/regeneration-path-skill-contract.Tests.ps1`, contract test, updated
- `tests/scripts/claude-runtime/test-cadence-wording.Tests.ps1`, contract test, updated
- `tests/scripts/claude-skills/test-execution-policy/Invoke-TestSuite.RunScope.Tests.ps1`, unit test, created
- `tests/scripts/claude-skills/test-execution-policy/Invoke-TestSuite.Tests.ps1`, unit test, updated
- `tests/scripts/codex-hooks/validate-feature-review-coverage.Coverage.Tests.ps1`, unit test, updated
- `tests/scripts/codex-hooks/validate-feature-review-coverage-freshness.Tests.ps1`, unit test, updated

## Stored Patch

`patches/0014-targeted-test-cadence.patch` holds the reduction as one diff. It is generated as `git diff --binary --no-renames <merge base>` of the working tree over the paths of `## Files Changed`, against the merge base of `origin/main` and `HEAD`, because part of the change was already committed in the branch's work-in-progress commit when this entry was written; the diff headers of the three plan templates and the policy-audit template carry the key `docs/features/templates/`. It deletes no file. It creates the two unit-test files of remediation cycle 2, `tests/scripts/claude-hooks/validate-feature-review-coverage.RunScope.Tests.ps1` and `tests/scripts/claude-skills/test-execution-policy/Invoke-TestSuite.RunScope.Tests.ps1`: each is untracked when the patch is generated, so its create hunk is appended as `git diff --no-index --binary /dev/null <path>` run at the worktree root. The byte-identical bundle copies, the generated targets, and the generated Codex variants are in the patch, and the chain skips the derived ones.

The check of README `## Revert Order`: `0014` is the highest number, so it is reverted first, against the live tree. Its paths are also named by entries `0012`, `0011`, `0009`, `0008`, `0006`, `0005`, `0004`, `0003`, `0002`, and `0001` (no path is named by `0013`, `0010`, or `0007`), and its edits sit inside their recorded regions: the `0011` blocks whose `Current` holds the earlier cadence sentence on the policy, rule, orchestrate, executor, planner, QA-gate, language, brief, Copilot agent, hard-lock prompt, and plan-template surfaces, and the `## Test Cadence (Mandatory)` blocks of the two `atomic-plan-contract` copies; the `0012` regions on the same surfaces; and hunks of `patches/0001-parallel-only-test-gates.patch`, `patches/0006-test-suite-baseline-restored.patch`, and `patches/0009-less-evidence.patch` on the `atomic-plan-contract`, feature-review, QA-gate, and orchestrate surfaces; and the regions of entries `0001`, `0003`, `0006`, and `0009` on the feature-review agent (`scripts/harness-generation/sources/agents/feature-review.md`, its generated targets, and their bundles) and on the policy-audit template and its bundle, which hold the `## Coverage Verification` and `#### 4A.1 Framework and Scope` text that remediation cycle 1 edits; and the regions of `patches/0001-parallel-only-test-gates.patch` on `.codex/hooks/validate-feature-review-coverage.ps1` and its bundle copy `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/validate-feature-review-coverage.ps1`, which hold the entry loop that remediation cycle 2 edits. Those older blocks and hunks are not regenerated: reverting `0014` first restores each edited region byte-for-byte before the older turns, so their `Current` text and context match again, while regenerating them to carry `0014` text would make them fail once `0014` is reverted. A manual `git apply -R` of the patch first maps the four `docs/features/templates/` sections to `.dev/templates/`, where those files now live.

## Revert Steps

1. Apply the blocks: run `git apply -R` of `patches/0014-targeted-test-cadence.patch` (with the four `docs/features/templates/` sections applied to `.dev/templates/`), which restores every changed path, including both contract-test files; then remove the `0014` row from `README.md` and delete this entry and its patch. Revert this entry before `0012`, `0011`, `0009`, `0008`, `0006`, `0005`, `0004`, `0003`, `0002`, and `0001`: their blocks and hunks on the changed files hold text and context that this entry edits, and reverting `0014` first restores them byte-for-byte.
2. Re-copy mirrors and bundles: copy each source listed in `## Files Changed` to every byte-identical copy listed with it, including `AGENTS.md` to `extensions/drm-copilot/resources/codex-and-agents-customizations/AGENTS.md` the three plan templates under `.dev/templates/` to `extensions/drm-copilot/resources/feature-templates/`, and `.dev/templates/policy_audit/policy-audit.yyyy-MM-ddTHH-mm.md` to `extensions/drm-copilot/resources/templates/policy_audit/policy-audit.yyyy-MM-ddTHH-mm.md`; for remediation cycle 2, also copy `.claude/hooks/validate-feature-review-coverage.ps1` and `.claude/hooks/validate-feature-review-coverage-freshness.ps1` to `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/`, `.codex/hooks/validate-feature-review-coverage.ps1` and `.codex/hooks/validate-feature-review-coverage-freshness.ps1` to `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/`, and `.agents/skills/test-execution-policy/scripts/Invoke-TestSuite.ps1` to `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/test-execution-policy/scripts/Invoke-TestSuite.ps1`.
3. Regenerate Codex variants: run `scripts/harness-generation/Invoke-HarnessGeneration.ps1` (write), which regenerates the rules, the rule skills, the Copilot instruction, the Claude and Codex agents, the three `.claude` skills generated from `.agents` sources, and the `.claude` launcher `.claude/skills/test-execution-policy/scripts/Invoke-TestSuite.ps1` generated from its `.agents` source, with their bundles; run it with `-Check` and with `-Surface instructions -Check`; then run `scripts/dev_tools/generate_codex_agent_variants.py` in module form and with `--check`.
4. Restore pinned hashes: not applicable, because no `PINNED_FROZEN_SURFACE_HASHES` entry covers these files; the frozen epic surfaces are unchanged.
5. Restore contract-test literals: the patch restores `tests/scripts/claude-runtime/test-cadence-wording.Tests.ps1` (the selection tokens, the cadence sweep and its exclusions, the `TCW-QAGATE` literal and its delta and shortcut checks, the `TCW-HANDOFF-*`, `TCW-ENGINEER-*`, `TCW-REVIEW-*`, `TCW-REVIEW-AGENT-*`, `TCW-REVIEW-TEMPLATE-*`, and `TCW-SCOPED-*` rows, and `TCW-COVERAGE-SOURCE-DISCRIMINATES`) and the two `RSC-REGENERATE` literals of `tests/scripts/claude-runtime/regeneration-path-skill-contract.Tests.ps1`; for remediation cycle 2 it also restores the name-list literal of `1114: the Codex twin defines the same function names as the Claude file` in `tests/scripts/codex-hooks/validate-feature-review-coverage-freshness.Tests.ps1` and the `WriteRunScope` seam of `Get-LauncherCase` in `tests/scripts/claude-skills/test-execution-policy/Invoke-TestSuite.Tests.ps1`, removes the `RSCOPE-READ-*` and `RSCOPE-CODEX-*` unit rows, and deletes the two created `RunScope` suites; no other contract test changes.
6. Run the contract tests: run `validate-feature-review-coverage-freshness.Tests.ps1` under `tests/scripts/claude-hooks` and under `tests/scripts/codex-hooks`, `validate-feature-review-coverage.Coverage.Tests.ps1` under `tests/scripts/codex-hooks`, `validate-feature-review-coverage.Tests.ps1` under `tests/scripts/claude-hooks`, `Invoke-TestSuite.Tests.ps1`, `test-cadence-wording.Tests.ps1`, `regeneration-path-skill-contract.Tests.ps1`, `parallel-gate-wording.Tests.ps1`, `planning-contract-wording.Tests.ps1`, `less-evidence-contract.Tests.ps1`, `light-remediation-skill-contract.Tests.ps1`, `HarnessGeneration.RepoGate.Tests.ps1`, `PoshQC.VendoredCoverage.RepoGate.Tests.ps1`, `ProcessReductionChain.Ledger.Tests.ps1`, `ProcessReductionLedger.Index.Tests.ps1`, `test_execution_environment_brief_contracts.py`, `test_push_down_claude_resource_contracts.py`, `test_push_down_codex_and_agents_resource_contracts.py`, and `test_codex_agent_wrapper_contracts.py`, inside one `Invoke-PoshQCParallelTest` run and one `pytest -n auto` run through the test-execution launcher.

## Revert Signals

- A defect that a full-suite phase gate would have caught reaches the final QA loop or CI, for example a failure in a test outside every task selection of the phase.
- The final QA loop of an orchestration fails more often than before the reduction, and the failures trace to changes from earlier phases.
- Remediation cycles or sync checks miss regressions that CI then reports on the pull-request head.
- A full-suite coverage report is graded as per-file evidence: a review passes a report below the repo-wide floor because a run-scope record marked a full run as `selection` or its window covered a full run's report.
