# 0012: Local lane exclusion

## Summary

reduction: 0012
Date: 2026-11-14
Issue: #1158
Merge commit: pending (PR #1158)

Local test gates stop running the integration and golden lanes; CI keeps running them. The test-execution launcher and the PoshQC lane parameters exclude the lanes named by `localLanes.exclude` in `config/test-execution-policy.json` (default `integration` and `golden`), and the planning, QA-gate, review, and agent surfaces state the lane statement below once per file. The machine test-suite lock and the launcher requirement remove no gate and no evidence and are not recorded here.

Lane statement: Local test gates exclude the integration and golden lanes: CI integration and golden lanes are evidence, and a step that would run a lane locally records a non-blocking deviation under evidence/other/.

## Reason and Evidence

Several features ran full test suites at the same time on one machine, each with one worker per core and each including the slow integration and golden suites under coverage. Load reached about four to five times the core count, and suite runs that take a few minutes alone took over 100 minutes (spec `## Overview` of `docs/features/active/2026-11-09-test-execution-policy-machine-lock-1158/spec.md`). The lanes keep running in CI, so their results remain evidence: `poshqc / PowerShell QC`, `poshqc / PowerShell hook suites (Linux)` (which runs `tests/scripts/codex-hooks/codex-pretooluse-integration.Tests.ps1`), `quality-checks7 / Code Quality & Tests (3.13)`, and `drm-copilot-extension-tests / drm-copilot Extension Tests (windows-latest)`.

## Files Changed

- `.claude/skills/execution-environment/SKILL.md`, source
- `.claude/skills/atomic-plan-contract/SKILL.md`, source
- `.agents/skills/atomic-plan-contract/SKILL.md`, source
- `.github/skills/atomic-plan-contract/SKILL.md`, source
- `.claude/skills/python-qa-gate/SKILL.md`, source
- `.claude/skills/powershell-qa-gate/SKILL.md`, source
- `.claude/skills/csharp-qa-gate/SKILL.md`, source
- `.claude/skills/invoke-python-engineer/SKILL.md`, source
- `.claude/skills/invoke-powershell-engineer/SKILL.md`, source
- `.claude/skills/invoke-csharp-engineer/SKILL.md`, source
- `.claude/skills/feature-review-workflow/SKILL.md`, source
- `.agents/skills/python-qa-gate/SKILL.md`, source
- `.agents/skills/powershell-qa-gate/SKILL.md`, source
- `.agents/skills/csharp-qa-gate/SKILL.md`, source
- `.agents/skills/invoke-python-engineer/SKILL.md`, source
- `.agents/skills/invoke-powershell-engineer/SKILL.md`, source
- `.agents/skills/invoke-csharp-engineer/SKILL.md`, source
- `.agents/skills/feature-review-workflow/SKILL.md`, source
- `extensions/drm-copilot/resources/claude-customizations/.claude-variants/csharp-legacy/skills/csharp-qa-gate/SKILL.md`, source
- `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents-variants/csharp-legacy/skills/csharp-qa-gate/SKILL.md`, source
- `extensions/drm-copilot/resources/claude-customizations/.claude-variants/csharp-legacy/skills/invoke-csharp-engineer/SKILL.md`, source
- `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents-variants/csharp-legacy/skills/invoke-csharp-engineer/SKILL.md`, source
- `.claude/agents/atomic-planner.md`, source
- `.claude/agents/python-typed-engineer.md`, source
- `.claude/agents/powershell-typed-engineer.md`, source
- `.claude/agents/csharp-typed-engineer.md`, source
- `.claude/agents/typescript-engineer.md`, source
- `extensions/drm-copilot/resources/claude-customizations/.claude-variants/csharp-legacy/agents/csharp-typed-engineer.md`, source
- `.github/agents/atomic_executor.agent.md`, source
- `.github/agents/powershell-atomic-executor.agent.md`, source
- `.github/agents/python-atomic-executor.agent.md`, source
- `.github/agents/csharp-atomic-executor.agent.md`, source
- `.github/agents/python-typed-engineer.agent.md`, source
- `.github/agents/powershell-typed-engineer.agent.md`, source
- `.github/agents/csharp-typed-engineer.agent.md`, source
- `.github/agents/typescript-engineer.agent.md`, source
- `.codex/agents/atomic-executor.toml`, source
- `.codex/agents/atomic-planner.toml`, source
- `.codex/agents/python-typed-engineer.toml`, source
- `.codex/agents/powershell-typed-engineer.toml`, source
- `.codex/agents/csharp-typed-engineer.toml`, source
- `.codex/agents/typescript-engineer.toml`, source
- `.codex/agents/python-atomic-executor.toml`, source
- `.codex/agents/powershell-atomic-executor.toml`, source
- `.codex/agents/csharp-atomic-executor.toml`, source
- `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex-variants/csharp-legacy/agents/csharp-typed-engineer.toml`, source
- `.agents/skills/execution-environment/SKILL.md`, byte-identical mirror of `.claude/skills/execution-environment/SKILL.md`
- `.github/skills/execution-environment/SKILL.md`, byte-identical mirror of `.claude/skills/execution-environment/SKILL.md`
- `extensions/drm-copilot/resources/claude-customizations/.claude/skills/execution-environment/SKILL.md`, bundle copy of `.claude/skills/execution-environment/SKILL.md`
- `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/execution-environment/SKILL.md`, bundle copy of `.claude/skills/execution-environment/SKILL.md`
- `extensions/drm-copilot/resources/customizations/.github/skills/execution-environment/SKILL.md`, bundle copy of `.claude/skills/execution-environment/SKILL.md`
- `extensions/drm-copilot/resources/claude-customizations/.claude/skills/atomic-plan-contract/SKILL.md`, bundle copy of `.claude/skills/atomic-plan-contract/SKILL.md`
- `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/atomic-plan-contract/SKILL.md`, bundle copy of `.agents/skills/atomic-plan-contract/SKILL.md`
- `extensions/drm-copilot/resources/customizations/.github/skills/atomic-plan-contract/SKILL.md`, bundle copy of `.github/skills/atomic-plan-contract/SKILL.md`
- `extensions/drm-copilot/resources/claude-customizations/.claude/skills/python-qa-gate/SKILL.md`, bundle copy of `.claude/skills/python-qa-gate/SKILL.md`
- `extensions/drm-copilot/resources/claude-customizations/.claude/skills/powershell-qa-gate/SKILL.md`, bundle copy of `.claude/skills/powershell-qa-gate/SKILL.md`
- `extensions/drm-copilot/resources/claude-customizations/.claude/skills/csharp-qa-gate/SKILL.md`, bundle copy of `.claude/skills/csharp-qa-gate/SKILL.md`
- `extensions/drm-copilot/resources/claude-customizations/.claude/skills/invoke-python-engineer/SKILL.md`, bundle copy of `.claude/skills/invoke-python-engineer/SKILL.md`
- `extensions/drm-copilot/resources/claude-customizations/.claude/skills/invoke-powershell-engineer/SKILL.md`, bundle copy of `.claude/skills/invoke-powershell-engineer/SKILL.md`
- `extensions/drm-copilot/resources/claude-customizations/.claude/skills/invoke-csharp-engineer/SKILL.md`, bundle copy of `.claude/skills/invoke-csharp-engineer/SKILL.md`
- `extensions/drm-copilot/resources/claude-customizations/.claude/skills/feature-review-workflow/SKILL.md`, bundle copy of `.claude/skills/feature-review-workflow/SKILL.md`
- `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/python-qa-gate/SKILL.md`, bundle copy of `.agents/skills/python-qa-gate/SKILL.md`
- `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/powershell-qa-gate/SKILL.md`, bundle copy of `.agents/skills/powershell-qa-gate/SKILL.md`
- `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/csharp-qa-gate/SKILL.md`, bundle copy of `.agents/skills/csharp-qa-gate/SKILL.md`
- `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/invoke-python-engineer/SKILL.md`, bundle copy of `.agents/skills/invoke-python-engineer/SKILL.md`
- `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/invoke-powershell-engineer/SKILL.md`, bundle copy of `.agents/skills/invoke-powershell-engineer/SKILL.md`
- `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/invoke-csharp-engineer/SKILL.md`, bundle copy of `.agents/skills/invoke-csharp-engineer/SKILL.md`
- `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/feature-review-workflow/SKILL.md`, bundle copy of `.agents/skills/feature-review-workflow/SKILL.md`
- `extensions/drm-copilot/resources/claude-customizations/.claude/agents/atomic-planner.md`, bundle copy of `.claude/agents/atomic-planner.md`
- `extensions/drm-copilot/resources/claude-customizations/.claude/agents/python-typed-engineer.md`, bundle copy of `.claude/agents/python-typed-engineer.md`
- `extensions/drm-copilot/resources/claude-customizations/.claude/agents/powershell-typed-engineer.md`, bundle copy of `.claude/agents/powershell-typed-engineer.md`
- `extensions/drm-copilot/resources/claude-customizations/.claude/agents/csharp-typed-engineer.md`, bundle copy of `.claude/agents/csharp-typed-engineer.md`
- `extensions/drm-copilot/resources/claude-customizations/.claude/agents/typescript-engineer.md`, bundle copy of `.claude/agents/typescript-engineer.md`
- `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/atomic-executor.toml`, bundle copy of `.codex/agents/atomic-executor.toml`
- `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/atomic-planner.toml`, bundle copy of `.codex/agents/atomic-planner.toml`
- `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/python-typed-engineer.toml`, bundle copy of `.codex/agents/python-typed-engineer.toml`
- `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/powershell-typed-engineer.toml`, bundle copy of `.codex/agents/powershell-typed-engineer.toml`
- `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/csharp-typed-engineer.toml`, bundle copy of `.codex/agents/csharp-typed-engineer.toml`
- `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/typescript-engineer.toml`, bundle copy of `.codex/agents/typescript-engineer.toml`
- `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/python-atomic-executor.toml`, bundle copy of `.codex/agents/python-atomic-executor.toml`
- `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/powershell-atomic-executor.toml`, bundle copy of `.codex/agents/powershell-atomic-executor.toml`
- `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/csharp-atomic-executor.toml`, bundle copy of `.codex/agents/csharp-atomic-executor.toml`
- `extensions/drm-copilot/resources/customizations/.github/agents/atomic_executor.agent.md`, bundle copy of `.github/agents/atomic_executor.agent.md`
- `extensions/drm-copilot/resources/customizations/.github/agents/powershell-atomic-executor.agent.md`, bundle copy of `.github/agents/powershell-atomic-executor.agent.md`
- `extensions/drm-copilot/resources/customizations/.github/agents/python-atomic-executor.agent.md`, bundle copy of `.github/agents/python-atomic-executor.agent.md`
- `extensions/drm-copilot/resources/customizations/.github/agents/csharp-atomic-executor.agent.md`, bundle copy of `.github/agents/csharp-atomic-executor.agent.md`
- `extensions/drm-copilot/resources/customizations/.github/agents/python-typed-engineer.agent.md`, bundle copy of `.github/agents/python-typed-engineer.agent.md`
- `extensions/drm-copilot/resources/customizations/.github/agents/powershell-typed-engineer.agent.md`, bundle copy of `.github/agents/powershell-typed-engineer.agent.md`
- `extensions/drm-copilot/resources/customizations/.github/agents/csharp-typed-engineer.agent.md`, bundle copy of `.github/agents/csharp-typed-engineer.agent.md`
- `extensions/drm-copilot/resources/customizations/.github/agents/typescript-engineer.agent.md`, bundle copy of `.github/agents/typescript-engineer.agent.md`
- `.codex/agents/atomic-executor-c1.toml`, generated Codex variant
- `.codex/agents/atomic-executor-c2.toml`, generated Codex variant
- `.codex/agents/atomic-executor-c3-elevated.toml`, generated Codex variant
- `.codex/agents/atomic-executor-c3.toml`, generated Codex variant
- `.codex/agents/atomic-executor-c4.toml`, generated Codex variant
- `.codex/agents/atomic-planner-c1.toml`, generated Codex variant
- `.codex/agents/atomic-planner-c2.toml`, generated Codex variant
- `.codex/agents/atomic-planner-c3-elevated.toml`, generated Codex variant
- `.codex/agents/atomic-planner-c3.toml`, generated Codex variant
- `.codex/agents/atomic-planner-c4.toml`, generated Codex variant
- `.codex/agents/csharp-typed-engineer-c1.toml`, generated Codex variant
- `.codex/agents/csharp-typed-engineer-c2.toml`, generated Codex variant
- `.codex/agents/csharp-typed-engineer-c3-elevated.toml`, generated Codex variant
- `.codex/agents/csharp-typed-engineer-c3.toml`, generated Codex variant
- `.codex/agents/csharp-typed-engineer-c4.toml`, generated Codex variant
- `.codex/agents/powershell-typed-engineer-c1.toml`, generated Codex variant
- `.codex/agents/powershell-typed-engineer-c2.toml`, generated Codex variant
- `.codex/agents/powershell-typed-engineer-c3-elevated.toml`, generated Codex variant
- `.codex/agents/powershell-typed-engineer-c3.toml`, generated Codex variant
- `.codex/agents/powershell-typed-engineer-c4.toml`, generated Codex variant
- `.codex/agents/python-typed-engineer-c1.toml`, generated Codex variant
- `.codex/agents/python-typed-engineer-c2.toml`, generated Codex variant
- `.codex/agents/python-typed-engineer-c3-elevated.toml`, generated Codex variant
- `.codex/agents/python-typed-engineer-c3.toml`, generated Codex variant
- `.codex/agents/python-typed-engineer-c4.toml`, generated Codex variant
- `.codex/agents/typescript-engineer-c1.toml`, generated Codex variant
- `.codex/agents/typescript-engineer-c2.toml`, generated Codex variant
- `.codex/agents/typescript-engineer-c3-elevated.toml`, generated Codex variant
- `.codex/agents/typescript-engineer-c3.toml`, generated Codex variant
- `.codex/agents/typescript-engineer-c4.toml`, generated Codex variant
- `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/atomic-executor-c1.toml`, generated Codex variant
- `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/atomic-executor-c2.toml`, generated Codex variant
- `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/atomic-executor-c3-elevated.toml`, generated Codex variant
- `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/atomic-executor-c3.toml`, generated Codex variant
- `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/atomic-executor-c4.toml`, generated Codex variant
- `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/atomic-planner-c1.toml`, generated Codex variant
- `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/atomic-planner-c2.toml`, generated Codex variant
- `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/atomic-planner-c3-elevated.toml`, generated Codex variant
- `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/atomic-planner-c3.toml`, generated Codex variant
- `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/atomic-planner-c4.toml`, generated Codex variant
- `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/csharp-typed-engineer-c1.toml`, generated Codex variant
- `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/csharp-typed-engineer-c2.toml`, generated Codex variant
- `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/csharp-typed-engineer-c3-elevated.toml`, generated Codex variant
- `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/csharp-typed-engineer-c3.toml`, generated Codex variant
- `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/csharp-typed-engineer-c4.toml`, generated Codex variant
- `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/powershell-typed-engineer-c1.toml`, generated Codex variant
- `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/powershell-typed-engineer-c2.toml`, generated Codex variant
- `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/powershell-typed-engineer-c3-elevated.toml`, generated Codex variant
- `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/powershell-typed-engineer-c3.toml`, generated Codex variant
- `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/powershell-typed-engineer-c4.toml`, generated Codex variant
- `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/python-typed-engineer-c1.toml`, generated Codex variant
- `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/python-typed-engineer-c2.toml`, generated Codex variant
- `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/python-typed-engineer-c3-elevated.toml`, generated Codex variant
- `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/python-typed-engineer-c3.toml`, generated Codex variant
- `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/python-typed-engineer-c4.toml`, generated Codex variant
- `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/typescript-engineer-c1.toml`, generated Codex variant
- `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/typescript-engineer-c2.toml`, generated Codex variant
- `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/typescript-engineer-c3-elevated.toml`, generated Codex variant
- `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/typescript-engineer-c3.toml`, generated Codex variant
- `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/typescript-engineer-c4.toml`, generated Codex variant
- `config/test-execution-policy.json`, source (the `localLanes.exclude` knob of the revert)
- `.claude/hooks/test-execution-policy.ps1` and `.codex/hooks/test-execution-policy.ps1`, byte-identical twins that carry the `localLanes.exclude` default (reverted through the configuration knob, not edited)
- `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/test-execution-policy.ps1` and `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/test-execution-policy.ps1`, bundle copies of the twins
- `tests/scripts/claude-runtime/parallel-gate-wording.Tests.ps1`, contract test (lane tokens)
- `tests/scripts/dev_tools/test_execution_environment_brief_contracts.py`, contract test (lane tokens)

## Prior Text

### Revert Block: config/test-execution-policy.json

````Current
  "version": 1,
````

````Prior
  "version": 1,
  "localLanes": { "exclude": [] },
````

### Revert Block: .claude/skills/execution-environment/SKILL.md

````Current
Local test gates exclude the integration and golden lanes: CI integration and golden lanes are evidence, and a step that would run a lane locally records a non-blocking deviation under evidence/other/.
````

````Prior
````

### Revert Block: .claude/skills/atomic-plan-contract/SKILL.md

````Current
Local test gates exclude the integration and golden lanes: CI integration and golden lanes are evidence, and a step that would run a lane locally records a non-blocking deviation under evidence/other/.
````

````Prior
````

### Revert Block: .agents/skills/atomic-plan-contract/SKILL.md

````Current
Local test gates exclude the integration and golden lanes: CI integration and golden lanes are evidence, and a step that would run a lane locally records a non-blocking deviation under evidence/other/.
````

````Prior
````

### Revert Block: .github/skills/atomic-plan-contract/SKILL.md

````Current
Local test gates exclude the integration and golden lanes: CI integration and golden lanes are evidence, and a step that would run a lane locally records a non-blocking deviation under evidence/other/.
````

````Prior
````

### Revert Block: .claude/skills/python-qa-gate/SKILL.md

````Current
Local test gates exclude the integration and golden lanes: CI integration and golden lanes are evidence, and a step that would run a lane locally records a non-blocking deviation under evidence/other/.
````

````Prior
````

### Revert Block: .claude/skills/powershell-qa-gate/SKILL.md

````Current
Local test gates exclude the integration and golden lanes: CI integration and golden lanes are evidence, and a step that would run a lane locally records a non-blocking deviation under evidence/other/.
````

````Prior
````

### Revert Block: .claude/skills/csharp-qa-gate/SKILL.md

````Current
Local test gates exclude the integration and golden lanes: CI integration and golden lanes are evidence, and a step that would run a lane locally records a non-blocking deviation under evidence/other/.
````

````Prior
````

### Revert Block: .claude/skills/invoke-python-engineer/SKILL.md

````Current
Local test gates exclude the integration and golden lanes: CI integration and golden lanes are evidence, and a step that would run a lane locally records a non-blocking deviation under evidence/other/.
````

````Prior
````

### Revert Block: .claude/skills/invoke-powershell-engineer/SKILL.md

````Current
Local test gates exclude the integration and golden lanes: CI integration and golden lanes are evidence, and a step that would run a lane locally records a non-blocking deviation under evidence/other/.
````

````Prior
````

### Revert Block: .claude/skills/invoke-csharp-engineer/SKILL.md

````Current
Local test gates exclude the integration and golden lanes: CI integration and golden lanes are evidence, and a step that would run a lane locally records a non-blocking deviation under evidence/other/.
````

````Prior
````

### Revert Block: .claude/skills/feature-review-workflow/SKILL.md

````Current
Local test gates exclude the integration and golden lanes: CI integration and golden lanes are evidence, and a step that would run a lane locally records a non-blocking deviation under evidence/other/.
````

````Prior
````

### Revert Block: .agents/skills/python-qa-gate/SKILL.md

````Current
Local test gates exclude the integration and golden lanes: CI integration and golden lanes are evidence, and a step that would run a lane locally records a non-blocking deviation under evidence/other/.
````

````Prior
````

### Revert Block: .agents/skills/powershell-qa-gate/SKILL.md

````Current
Local test gates exclude the integration and golden lanes: CI integration and golden lanes are evidence, and a step that would run a lane locally records a non-blocking deviation under evidence/other/.
````

````Prior
````

### Revert Block: .agents/skills/csharp-qa-gate/SKILL.md

````Current
Local test gates exclude the integration and golden lanes: CI integration and golden lanes are evidence, and a step that would run a lane locally records a non-blocking deviation under evidence/other/.
````

````Prior
````

### Revert Block: .agents/skills/invoke-python-engineer/SKILL.md

````Current
Local test gates exclude the integration and golden lanes: CI integration and golden lanes are evidence, and a step that would run a lane locally records a non-blocking deviation under evidence/other/.
````

````Prior
````

### Revert Block: .agents/skills/invoke-powershell-engineer/SKILL.md

````Current
Local test gates exclude the integration and golden lanes: CI integration and golden lanes are evidence, and a step that would run a lane locally records a non-blocking deviation under evidence/other/.
````

````Prior
````

### Revert Block: .agents/skills/invoke-csharp-engineer/SKILL.md

````Current
Local test gates exclude the integration and golden lanes: CI integration and golden lanes are evidence, and a step that would run a lane locally records a non-blocking deviation under evidence/other/.
````

````Prior
````

### Revert Block: .agents/skills/feature-review-workflow/SKILL.md

````Current
Local test gates exclude the integration and golden lanes: CI integration and golden lanes are evidence, and a step that would run a lane locally records a non-blocking deviation under evidence/other/.
````

````Prior
````

### Revert Block: extensions/drm-copilot/resources/claude-customizations/.claude-variants/csharp-legacy/skills/csharp-qa-gate/SKILL.md

````Current
Local test gates exclude the integration and golden lanes: CI integration and golden lanes are evidence, and a step that would run a lane locally records a non-blocking deviation under evidence/other/.
````

````Prior
````

### Revert Block: extensions/drm-copilot/resources/codex-and-agents-customizations/.agents-variants/csharp-legacy/skills/csharp-qa-gate/SKILL.md

````Current
Local test gates exclude the integration and golden lanes: CI integration and golden lanes are evidence, and a step that would run a lane locally records a non-blocking deviation under evidence/other/.
````

````Prior
````

### Revert Block: extensions/drm-copilot/resources/claude-customizations/.claude-variants/csharp-legacy/skills/invoke-csharp-engineer/SKILL.md

````Current
Local test gates exclude the integration and golden lanes: CI integration and golden lanes are evidence, and a step that would run a lane locally records a non-blocking deviation under evidence/other/.
````

````Prior
````

### Revert Block: extensions/drm-copilot/resources/codex-and-agents-customizations/.agents-variants/csharp-legacy/skills/invoke-csharp-engineer/SKILL.md

````Current
Local test gates exclude the integration and golden lanes: CI integration and golden lanes are evidence, and a step that would run a lane locally records a non-blocking deviation under evidence/other/.
````

````Prior
````

### Revert Block: .claude/agents/atomic-planner.md

````Current
Local test gates exclude the integration and golden lanes: CI integration and golden lanes are evidence, and a step that would run a lane locally records a non-blocking deviation under evidence/other/.
````

````Prior
````

### Revert Block: .claude/agents/python-typed-engineer.md

````Current
Local test gates exclude the integration and golden lanes: CI integration and golden lanes are evidence, and a step that would run a lane locally records a non-blocking deviation under evidence/other/.
````

````Prior
````

### Revert Block: .claude/agents/powershell-typed-engineer.md

````Current
Local test gates exclude the integration and golden lanes: CI integration and golden lanes are evidence, and a step that would run a lane locally records a non-blocking deviation under evidence/other/.
````

````Prior
````

### Revert Block: .claude/agents/csharp-typed-engineer.md

````Current
Local test gates exclude the integration and golden lanes: CI integration and golden lanes are evidence, and a step that would run a lane locally records a non-blocking deviation under evidence/other/.
````

````Prior
````

### Revert Block: .claude/agents/typescript-engineer.md

````Current
Local test gates exclude the integration and golden lanes: CI integration and golden lanes are evidence, and a step that would run a lane locally records a non-blocking deviation under evidence/other/.
````

````Prior
````

### Revert Block: extensions/drm-copilot/resources/claude-customizations/.claude-variants/csharp-legacy/agents/csharp-typed-engineer.md

````Current
Local test gates exclude the integration and golden lanes: CI integration and golden lanes are evidence, and a step that would run a lane locally records a non-blocking deviation under evidence/other/.
````

````Prior
````

### Revert Block: .github/agents/atomic_executor.agent.md

````Current
Local test gates exclude the integration and golden lanes: CI integration and golden lanes are evidence, and a step that would run a lane locally records a non-blocking deviation under evidence/other/.
````

````Prior
````

### Revert Block: .github/agents/powershell-atomic-executor.agent.md

````Current
Local test gates exclude the integration and golden lanes: CI integration and golden lanes are evidence, and a step that would run a lane locally records a non-blocking deviation under evidence/other/.
````

````Prior
````

### Revert Block: .github/agents/python-atomic-executor.agent.md

````Current
Local test gates exclude the integration and golden lanes: CI integration and golden lanes are evidence, and a step that would run a lane locally records a non-blocking deviation under evidence/other/.
````

````Prior
````

### Revert Block: .github/agents/csharp-atomic-executor.agent.md

````Current
Local test gates exclude the integration and golden lanes: CI integration and golden lanes are evidence, and a step that would run a lane locally records a non-blocking deviation under evidence/other/.
````

````Prior
````

### Revert Block: .github/agents/python-typed-engineer.agent.md

````Current
Local test gates exclude the integration and golden lanes: CI integration and golden lanes are evidence, and a step that would run a lane locally records a non-blocking deviation under evidence/other/.
````

````Prior
````

### Revert Block: .github/agents/powershell-typed-engineer.agent.md

````Current
Local test gates exclude the integration and golden lanes: CI integration and golden lanes are evidence, and a step that would run a lane locally records a non-blocking deviation under evidence/other/.
````

````Prior
````

### Revert Block: .github/agents/csharp-typed-engineer.agent.md

````Current
Local test gates exclude the integration and golden lanes: CI integration and golden lanes are evidence, and a step that would run a lane locally records a non-blocking deviation under evidence/other/.
````

````Prior
````

### Revert Block: .github/agents/typescript-engineer.agent.md

````Current
Local test gates exclude the integration and golden lanes: CI integration and golden lanes are evidence, and a step that would run a lane locally records a non-blocking deviation under evidence/other/.
````

````Prior
````

### Revert Block: .codex/agents/atomic-executor.toml

````Current
Local test gates exclude the integration and golden lanes: CI integration and golden lanes are evidence, and a step that would run a lane locally records a non-blocking deviation under evidence/other/.
````

````Prior
````

### Revert Block: .codex/agents/atomic-planner.toml

````Current
Local test gates exclude the integration and golden lanes: CI integration and golden lanes are evidence, and a step that would run a lane locally records a non-blocking deviation under evidence/other/.
````

````Prior
````

### Revert Block: .codex/agents/python-typed-engineer.toml

````Current
Local test gates exclude the integration and golden lanes: CI integration and golden lanes are evidence, and a step that would run a lane locally records a non-blocking deviation under evidence/other/.
````

````Prior
````

### Revert Block: .codex/agents/powershell-typed-engineer.toml

````Current
Local test gates exclude the integration and golden lanes: CI integration and golden lanes are evidence, and a step that would run a lane locally records a non-blocking deviation under evidence/other/.
````

````Prior
````

### Revert Block: .codex/agents/csharp-typed-engineer.toml

````Current
Local test gates exclude the integration and golden lanes: CI integration and golden lanes are evidence, and a step that would run a lane locally records a non-blocking deviation under evidence/other/.
````

````Prior
````

### Revert Block: .codex/agents/typescript-engineer.toml

````Current
Local test gates exclude the integration and golden lanes: CI integration and golden lanes are evidence, and a step that would run a lane locally records a non-blocking deviation under evidence/other/.
````

````Prior
````

### Revert Block: .codex/agents/python-atomic-executor.toml

````Current
Local test gates exclude the integration and golden lanes: CI integration and golden lanes are evidence, and a step that would run a lane locally records a non-blocking deviation under evidence/other/.
````

````Prior
````

### Revert Block: .codex/agents/powershell-atomic-executor.toml

````Current
Local test gates exclude the integration and golden lanes: CI integration and golden lanes are evidence, and a step that would run a lane locally records a non-blocking deviation under evidence/other/.
````

````Prior
````

### Revert Block: .codex/agents/csharp-atomic-executor.toml

````Current
Local test gates exclude the integration and golden lanes: CI integration and golden lanes are evidence, and a step that would run a lane locally records a non-blocking deviation under evidence/other/.
````

````Prior
````

### Revert Block: extensions/drm-copilot/resources/codex-and-agents-customizations/.codex-variants/csharp-legacy/agents/csharp-typed-engineer.toml

````Current
Local test gates exclude the integration and golden lanes: CI integration and golden lanes are evidence, and a step that would run a lane locally records a non-blocking deviation under evidence/other/.
````

````Prior
````

## Revert Steps

1. Apply the blocks: replace each `Current` fence with its `Prior` fence. The configuration block sets `localLanes.exclude` to `[]`, so the launcher, the hook, and the PoshQC templates run the lanes locally again with no code edit; each other block removes the lane statement from its file.
2. Re-copy mirrors and bundles: copy `.claude/skills/execution-environment/SKILL.md` to its five copies, each skill and agent source to the bundle copy listed in `## Files Changed`.
3. Regenerate Codex variants: run `scripts/dev_tools/generate_codex_agent_variants.py` in module form, then with `--check`.
4. Restore pinned hashes: not applicable.
5. Restore contract-test literals: remove the tokens `CI integration and golden lanes are evidence` and `non-blocking deviation` from `_TEST_EXECUTION_TOKENS` in `tests/scripts/dev_tools/test_execution_environment_brief_contracts.py` and from the required-token lists of `tests/scripts/claude-runtime/parallel-gate-wording.Tests.ps1`.
6. Run the contract tests: `tests/scripts/dev-tools/ProcessReductionChain.Ledger.Tests.ps1`, `tests/scripts/dev-tools/ProcessReductionLedger.Index.Tests.ps1`, `tests/scripts/claude-runtime/parallel-gate-wording.Tests.ps1`, `tests/scripts/claude-hooks/test-execution-policy.RepoConfig.Tests.ps1`, `tests/scripts/dev_tools/test_execution_environment_brief_contracts.py`, and the push-down resource contract tests.

## Revert Signals

- An integration or golden failure first seen in CI after a green local gate.
- A remediation cycle whose cause is a lane failure that a local gate would have shown.
