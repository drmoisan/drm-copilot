# Stage E2 Baseline-Part Inventory of Entry 0001

Timestamp: 2026-11-07T14-46
Command: poetry run python SCRATCH/issue-1097-inventory.py (parses docs/engineering/process-reductions/patches/0001-parallel-only-test-gates.patch, classifies every hunk with a removed line matching baseline|regress|delta|comparison|pre-development|pre-change|earlier figure, case-insensitive) and git apply -R --check of the 0001 patch
EXIT_CODE: 0
Output Summary:
  0001 patch: 238 paths, 689 hunks; every path classified (238 of 238).
  Baseline-class hunks: 527; hunks mapping to no B-row: 0.
  Mapping counts (sources and bundle copies): B1 12, B10 210, B11 12, B2 6, B3 6, B4 6, B5 8, B6 8, B7 20, B8 42, B9 196, TEST (## Test Dispositions) 1.
  Added text at HEAD: changed by 0003,0005 2, changed by 0005 6, present 511, regenerated from base changed by 0005 8.
  git apply -R --check of the 0001 patch: exit 1 (later entries 0002 to 0005 and stage E changed context in several of its paths; the restore is made by hand per hunk).
  Lines carrying a run-class phrase inside mapped hunks: 18 (4 not restored as run shapes; the rest restored with the run phrase replaced by the one parallel gate run). Hunks naming only run shapes: 0 (the minor-audit lines carrying 'targeted verification evidence' are baseline-evidence requirements and map to B3 or B10).

## Classification Rules

- B-row by canonical path (bundle prefix stripped): contract copies B1 (B2 under `## Coverage Evidence Contract`, B3 under `## Mode-Specific Mandatory Plan Gates`); brief B4; policy-audit template B5; `AGENTS.md` B6; review surfaces B7; QA gates B8; Claude and `.agents` planner, executor, engineer, handoff, and orchestrator-workflow files and the Codex `atomic-planner`, `atomic-executor`, and typed-engineer families B9; other `.github/` and Codex Copilot counterparts B10; plan templates B11; tests per `## Test Dispositions`.
- Added text at HEAD: `present` when every non-blank added line of the hunk is a line of the file at `HEAD`; otherwise `changed by NNNN` when the path is in that entry's `## Files Changed`, or `regenerated from base changed by NNNN` for a Codex generated variant whose base is listed there.
- A hunk is not restored when every matching removed line names only a run shape (seeded, shuffled, reversed-order, single-process, targeted, smallest subset, or one of the 12 run-class sweep tokens).

## Codex Files

| Path | Kind |
| --- | --- |
| `.codex/agents/atomic-executor-c1.toml` | generated |
| `.codex/agents/atomic-executor-c2.toml` | generated |
| `.codex/agents/atomic-executor-c3-elevated.toml` | generated |
| `.codex/agents/atomic-executor-c3.toml` | generated |
| `.codex/agents/atomic-executor-c4.toml` | generated |
| `.codex/agents/atomic-executor.toml` | base |
| `.codex/agents/atomic-planner-c1.toml` | generated |
| `.codex/agents/atomic-planner-c2.toml` | generated |
| `.codex/agents/atomic-planner-c3-elevated.toml` | generated |
| `.codex/agents/atomic-planner-c3.toml` | generated |
| `.codex/agents/atomic-planner-c4.toml` | generated |
| `.codex/agents/atomic-planner.toml` | base |
| `.codex/agents/csharp-atomic-executor.toml` | base |
| `.codex/agents/csharp-atomic-planning.toml` | base |
| `.codex/agents/csharp-orchestrator.toml` | base |
| `.codex/agents/csharp-typed-engineer-c1.toml` | generated |
| `.codex/agents/csharp-typed-engineer-c2.toml` | generated |
| `.codex/agents/csharp-typed-engineer-c3-elevated.toml` | generated |
| `.codex/agents/csharp-typed-engineer-c3.toml` | generated |
| `.codex/agents/csharp-typed-engineer-c4.toml` | generated |
| `.codex/agents/csharp-typed-engineer.toml` | base |
| `.codex/agents/feature-review.toml` | base |
| `.codex/agents/powershell-atomic-executor.toml` | base |
| `.codex/agents/powershell-atomic-planning.toml` | base |
| `.codex/agents/powershell-di-unit-test-engineer.toml` | base |
| `.codex/agents/powershell-orchestrator.toml` | base |
| `.codex/agents/powershell-typed-engineer-c1.toml` | generated |
| `.codex/agents/powershell-typed-engineer-c2.toml` | generated |
| `.codex/agents/powershell-typed-engineer-c3-elevated.toml` | generated |
| `.codex/agents/powershell-typed-engineer-c3.toml` | generated |
| `.codex/agents/powershell-typed-engineer-c4.toml` | generated |
| `.codex/agents/powershell-typed-engineer.toml` | base |
| `.codex/agents/pytest-unit-test-coding.toml` | base |
| `.codex/agents/python-atomic-executor.toml` | base |
| `.codex/agents/python-atomic-planning.toml` | base |
| `.codex/agents/python-execution-only-typed.toml` | base |
| `.codex/agents/python-orchestrator.toml` | base |
| `.codex/agents/python-typed-engineer-c1.toml` | generated |
| `.codex/agents/python-typed-engineer-c2.toml` | generated |
| `.codex/agents/python-typed-engineer-c3-elevated.toml` | generated |
| `.codex/agents/python-typed-engineer-c3.toml` | generated |
| `.codex/agents/python-typed-engineer-c4.toml` | generated |
| `.codex/agents/python-typed-engineer.toml` | base |
| `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex-variants/csharp-legacy/agents/csharp-typed-engineer.toml` | base |
| `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/atomic-executor-c1.toml` | generated |
| `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/atomic-executor-c2.toml` | generated |
| `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/atomic-executor-c3-elevated.toml` | generated |
| `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/atomic-executor-c3.toml` | generated |
| `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/atomic-executor-c4.toml` | generated |
| `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/atomic-executor.toml` | base |
| `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/atomic-planner-c1.toml` | generated |
| `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/atomic-planner-c2.toml` | generated |
| `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/atomic-planner-c3-elevated.toml` | generated |
| `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/atomic-planner-c3.toml` | generated |
| `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/atomic-planner-c4.toml` | generated |
| `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/atomic-planner.toml` | base |
| `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/csharp-atomic-executor.toml` | base |
| `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/csharp-atomic-planning.toml` | base |
| `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/csharp-orchestrator.toml` | base |
| `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/csharp-typed-engineer-c1.toml` | generated |
| `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/csharp-typed-engineer-c2.toml` | generated |
| `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/csharp-typed-engineer-c3-elevated.toml` | generated |
| `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/csharp-typed-engineer-c3.toml` | generated |
| `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/csharp-typed-engineer-c4.toml` | generated |
| `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/csharp-typed-engineer.toml` | base |
| `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/feature-review.toml` | base |
| `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/powershell-atomic-executor.toml` | base |
| `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/powershell-atomic-planning.toml` | base |
| `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/powershell-di-unit-test-engineer.toml` | base |
| `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/powershell-orchestrator.toml` | base |
| `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/powershell-typed-engineer-c1.toml` | generated |
| `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/powershell-typed-engineer-c2.toml` | generated |
| `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/powershell-typed-engineer-c3-elevated.toml` | generated |
| `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/powershell-typed-engineer-c3.toml` | generated |
| `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/powershell-typed-engineer-c4.toml` | generated |
| `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/powershell-typed-engineer.toml` | base |
| `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/pytest-unit-test-coding.toml` | base |
| `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/python-atomic-executor.toml` | base |
| `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/python-atomic-planning.toml` | base |
| `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/python-execution-only-typed.toml` | base |
| `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/python-orchestrator.toml` | base |
| `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/python-typed-engineer-c1.toml` | generated |
| `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/python-typed-engineer-c2.toml` | generated |
| `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/python-typed-engineer-c3-elevated.toml` | generated |
| `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/python-typed-engineer-c3.toml` | generated |
| `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/python-typed-engineer-c4.toml` | generated |
| `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/python-typed-engineer.toml` | base |

## Lines Carrying a Run-Class Phrase

- `.agents/skills/atomic-plan-contract/SKILL.md` hunk 2 (restored, run phrase replaced by the one parallel gate run): - baseline test-step artifacts for languages with mandatory coverage policy MUST include numeric coverage headline values in `Output Summary:` (baseline percent and, when applicable, targeted module/new-code percent).
- `.claude/skills/atomic-plan-contract/SKILL.md` hunk 2 (restored, run phrase replaced by the one parallel gate run): - baseline test-step artifacts for languages with mandatory coverage policy MUST include numeric coverage headline values in `Output Summary:` (baseline percent and, when applicable, targeted module/new-code percent).
- `.github/agents/Powershell DI Unit Test Engineer.agent.md` hunk 2 (restored, run phrase replaced by the one parallel gate run): prompt: "Implement ONLY the approved plan. Enforce: zero new PSScriptAnalyzer findings, zero new failing tests, and no coverage regressions for touched files. Run Analyze+targeted tests after each small batch; run full t
- `.github/agents/Powershell DI Unit Test Engineer.agent.md` hunk 5 (restored, run phrase replaced by the one parallel gate run): - Test baseline (targeted): run only the relevant Pester file(s) or tag/filter used by the repo
- `.github/agents/pytest-unit-test-coding.agent.md` hunk 2 (restored, run phrase replaced by the one parallel gate run): prompt: "Implement ONLY the approved plan. Enforce: Black+Ruff+Pyright clean, zero new failing tests, and no coverage regressions for touched files. Run targeted tests after each small batch; run full toolchain at the en
- `.github/agents/python-typed-engineer.agent.md` hunk 2 (restored, run phrase replaced by the one parallel gate run): prompt: "Implement ONLY the approved plan. Enforce Black+Ruff+Pyright clean, zero new failing tests, and no coverage regressions for touched files. Run targeted checks after each batch; run full toolchain at the end."
- `.github/skills/atomic-plan-contract/SKILL.md` hunk 2 (restored, run phrase replaced by the one parallel gate run): - baseline test-step artifacts for languages with mandatory coverage policy MUST include numeric coverage headline values in `Output Summary:` (baseline percent and, when applicable, targeted module/new-code percent).
- `docs/features/templates/bug/plan.yyyy-MM-ddTHH-mm.md` hunk 2 (not restored (run shape)): - [ ] [P2-T2] [expect-fail] Run the regression to confirm it fails and captures the repro
- `docs/features/templates/bug/plan.yyyy-MM-ddTHH-mm.md` hunk 2 (not restored (run shape)): - [ ] [P4-T1] Re-run repro and regression test to confirm expected behavior
- `extensions/drm-copilot/resources/claude-customizations/.claude/skills/atomic-plan-contract/SKILL.md` hunk 2 (restored, run phrase replaced by the one parallel gate run): - baseline test-step artifacts for languages with mandatory coverage policy MUST include numeric coverage headline values in `Output Summary:` (baseline percent and, when applicable, targeted module/new-code percent).
- `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/atomic-plan-contract/SKILL.md` hunk 2 (restored, run phrase replaced by the one parallel gate run): - baseline test-step artifacts for languages with mandatory coverage policy MUST include numeric coverage headline values in `Output Summary:` (baseline percent and, when applicable, targeted module/new-code percent).
- `extensions/drm-copilot/resources/customizations/.github/agents/Powershell DI Unit Test Engineer.agent.md` hunk 2 (restored, run phrase replaced by the one parallel gate run): prompt: "Implement ONLY the approved plan. Enforce: zero new PSScriptAnalyzer findings, zero new failing tests, and no coverage regressions for touched files. Run Analyze+targeted tests after each small batch; run full t
- `extensions/drm-copilot/resources/customizations/.github/agents/Powershell DI Unit Test Engineer.agent.md` hunk 5 (restored, run phrase replaced by the one parallel gate run): - Test baseline (targeted): run only the relevant Pester file(s) or tag/filter used by the repo
- `extensions/drm-copilot/resources/customizations/.github/agents/pytest-unit-test-coding.agent.md` hunk 2 (restored, run phrase replaced by the one parallel gate run): prompt: "Implement ONLY the approved plan. Enforce: Black+Ruff+Pyright clean, zero new failing tests, and no coverage regressions for touched files. Run targeted tests after each small batch; run full toolchain at the en
- `extensions/drm-copilot/resources/customizations/.github/agents/python-typed-engineer.agent.md` hunk 2 (restored, run phrase replaced by the one parallel gate run): prompt: "Implement ONLY the approved plan. Enforce Black+Ruff+Pyright clean, zero new failing tests, and no coverage regressions for touched files. Run targeted checks after each batch; run full toolchain at the end."
- `extensions/drm-copilot/resources/customizations/.github/skills/atomic-plan-contract/SKILL.md` hunk 2 (restored, run phrase replaced by the one parallel gate run): - baseline test-step artifacts for languages with mandatory coverage policy MUST include numeric coverage headline values in `Output Summary:` (baseline percent and, when applicable, targeted module/new-code percent).
- `extensions/drm-copilot/resources/feature-templates/bug/plan.yyyy-MM-ddTHH-mm.md` hunk 2 (not restored (run shape)): - [ ] [P2-T2] [expect-fail] Run the regression to confirm it fails and captures the repro
- `extensions/drm-copilot/resources/feature-templates/bug/plan.yyyy-MM-ddTHH-mm.md` hunk 2 (not restored (run shape)): - [ ] [P4-T1] Re-run repro and regression test to confirm expected behavior

## Hunk Table

| Path | Hunk | Enclosing heading | B-row | Added text at HEAD |
| --- | --- | --- | --- | --- |
| `.agents/skills/atomic-plan-contract/SKILL.md` | 2 | ## Short-Path Minimal Plan Contract | B1 | present |
| `.agents/skills/atomic-plan-contract/SKILL.md` | 4 | ## Phase 0 Requirements | B1 | present |
| `.agents/skills/atomic-plan-contract/SKILL.md` | 5 | ## Coverage Evidence Contract (Mandatory when policy requires coverage) | B2 | present |
| `.agents/skills/atomic-plan-contract/SKILL.md` | 6 | ## Mode-Specific Mandatory Plan Gates | B3 | present |
| `.agents/skills/atomic-planner/SKILL.md` | 1 | ## Plan Requirements | B9 | present |
| `.agents/skills/csharp-qa-gate/SKILL.md` | 1 | (top of file) | B8 | present |
| `.agents/skills/csharp-qa-gate/SKILL.md` | 2 | ## When to Use This Skill | B8 | present |
| `.agents/skills/csharp-qa-gate/SKILL.md` | 3 | ## Gate Requirements (Hard Gate) | B8 | present |
| `.agents/skills/execution-environment/SKILL.md` | 5 | ## Test Runtime | B4 | present |
| `.agents/skills/feature-review-workflow/SKILL.md` | 2 | ## Ordered Procedure | B7 | present |
| `.agents/skills/feature-review-workflow/SKILL.md` | 3 | ## Ordered Procedure | B7 | present |
| `.agents/skills/invoke-csharp-engineer/SKILL.md` | 1 | (top of file) | B9 | present |
| `.agents/skills/invoke-csharp-engineer/SKILL.md` | 2 | ## Output Paths | B9 | present |
| `.agents/skills/invoke-csharp-engineer/SKILL.md` | 3 | ## Required Reporting Block | B9 | present |
| `.agents/skills/invoke-powershell-engineer/SKILL.md` | 1 | (top of file) | B9 | present |
| `.agents/skills/invoke-powershell-engineer/SKILL.md` | 2 | ## Output Paths | B9 | present |
| `.agents/skills/invoke-powershell-engineer/SKILL.md` | 3 | ## Required Reporting Block | B9 | present |
| `.agents/skills/invoke-python-engineer/SKILL.md` | 1 | (top of file) | B9 | present |
| `.agents/skills/invoke-python-engineer/SKILL.md` | 2 | ## Output Paths | B9 | present |
| `.agents/skills/invoke-python-engineer/SKILL.md` | 3 | ## Required Reporting Block | B9 | present |
| `.agents/skills/orchestrator-workflow/SKILL.md` | 1 | ## Large Path | B9 | present |
| `.agents/skills/powershell-qa-gate/SKILL.md` | 1 | (top of file) | B8 | present |
| `.agents/skills/powershell-qa-gate/SKILL.md` | 2 | ## When to Use This Skill | B8 | present |
| `.agents/skills/powershell-qa-gate/SKILL.md` | 3 | ## Toolchain Execution Sequence | B8 | present |
| `.agents/skills/python-qa-gate/SKILL.md` | 1 | (top of file) | B8 | present |
| `.agents/skills/python-qa-gate/SKILL.md` | 2 | ## When to Use This Skill | B8 | present |
| `.agents/skills/python-qa-gate/SKILL.md` | 3 | ## Toolchain Execution Sequence | B8 | present |
| `.claude/agents/atomic-planner.md` | 1 | ## Plan Structure | B9 | changed by 0005 |
| `.claude/agents/atomic-planner.md` | 2 | ## Requirements | B9 | present |
| `.claude/agents/csharp-typed-engineer.md` | 1 | (top of file) | B9 | present |
| `.claude/agents/csharp-typed-engineer.md` | 2 | ## Workflow | B9 | present |
| `.claude/agents/csharp-typed-engineer.md` | 3 | ## Stop Conditions | B9 | present |
| `.claude/agents/feature-review.md` | 1 | ### Coverage Thresholds | B7 | present |
| `.claude/agents/feature-review.md` | 2 | ### Verification Procedure | B7 | present |
| `.claude/agents/powershell-typed-engineer.md` | 1 | (top of file) | B9 | present |
| `.claude/agents/powershell-typed-engineer.md` | 2 | ## Workflow | B9 | present |
| `.claude/agents/powershell-typed-engineer.md` | 3 | ## Stop Conditions | B9 | present |
| `.claude/agents/python-typed-engineer.md` | 1 | (top of file) | B9 | present |
| `.claude/agents/python-typed-engineer.md` | 2 | ## Workflow | B9 | present |
| `.claude/agents/python-typed-engineer.md` | 3 | ## Stop Conditions | B9 | present |
| `.claude/skills/atomic-plan-contract/SKILL.md` | 2 | ## Short-Path Minimal Plan Contract | B1 | present |
| `.claude/skills/atomic-plan-contract/SKILL.md` | 4 | ## Phase 0 Requirements | B1 | present |
| `.claude/skills/atomic-plan-contract/SKILL.md` | 5 | ## Coverage Evidence Contract (Mandatory when policy requires coverage) | B2 | present |
| `.claude/skills/atomic-plan-contract/SKILL.md` | 6 | ## Mode-Specific Mandatory Plan Gates | B3 | present |
| `.claude/skills/csharp-qa-gate/SKILL.md` | 1 | (top of file) | B8 | present |
| `.claude/skills/csharp-qa-gate/SKILL.md` | 2 | ## When to Use This Skill | B8 | present |
| `.claude/skills/csharp-qa-gate/SKILL.md` | 3 | ## Gate Requirements (Hard Gate) | B8 | present |
| `.claude/skills/execution-environment/SKILL.md` | 5 | ## Test Runtime | B4 | present |
| `.claude/skills/feature-review-workflow/SKILL.md` | 2 | ## Ordered Procedure | B7 | present |
| `.claude/skills/feature-review-workflow/SKILL.md` | 3 | ## Ordered Procedure | B7 | present |
| `.claude/skills/invoke-csharp-engineer/SKILL.md` | 1 | (top of file) | B9 | present |
| `.claude/skills/invoke-csharp-engineer/SKILL.md` | 2 | ## Output Paths | B9 | present |
| `.claude/skills/invoke-csharp-engineer/SKILL.md` | 3 | ## Required Reporting Block | B9 | present |
| `.claude/skills/invoke-powershell-engineer/SKILL.md` | 1 | (top of file) | B9 | present |
| `.claude/skills/invoke-powershell-engineer/SKILL.md` | 2 | ## Output Paths | B9 | present |
| `.claude/skills/invoke-powershell-engineer/SKILL.md` | 3 | ## Required Reporting Block | B9 | present |
| `.claude/skills/invoke-python-engineer/SKILL.md` | 1 | (top of file) | B9 | present |
| `.claude/skills/invoke-python-engineer/SKILL.md` | 2 | ## Output Paths | B9 | present |
| `.claude/skills/invoke-python-engineer/SKILL.md` | 3 | ## Required Reporting Block | B9 | present |
| `.claude/skills/powershell-qa-gate/SKILL.md` | 1 | (top of file) | B8 | present |
| `.claude/skills/powershell-qa-gate/SKILL.md` | 2 | ## When to Use This Skill | B8 | present |
| `.claude/skills/powershell-qa-gate/SKILL.md` | 3 | ## Toolchain Execution Sequence | B8 | present |
| `.claude/skills/python-qa-gate/SKILL.md` | 1 | (top of file) | B8 | present |
| `.claude/skills/python-qa-gate/SKILL.md` | 2 | ## When to Use This Skill | B8 | present |
| `.claude/skills/python-qa-gate/SKILL.md` | 3 | ## Toolchain Execution Sequence | B8 | present |
| `.claude/skills/remediation-handoff-atomic-planner/SKILL.md` | 1 | ## Plan Shape | B9 | changed by 0003,0005 |
| `.codex/agents/atomic-planner-c1.toml` | 1 | ## Requirements | B9 | changed by 0005 |
| `.codex/agents/atomic-planner-c2.toml` | 1 | ## Requirements | B9 | regenerated from base changed by 0005 |
| `.codex/agents/atomic-planner-c3-elevated.toml` | 1 | ## Requirements | B9 | regenerated from base changed by 0005 |
| `.codex/agents/atomic-planner-c3.toml` | 1 | ## Requirements | B9 | regenerated from base changed by 0005 |
| `.codex/agents/atomic-planner-c4.toml` | 1 | ## Requirements | B9 | regenerated from base changed by 0005 |
| `.codex/agents/atomic-planner.toml` | 1 | ## Requirements | B9 | changed by 0005 |
| `.codex/agents/csharp-atomic-executor.toml` | 1 | (top of file) | B10 | present |
| `.codex/agents/csharp-atomic-planning.toml` | 1 | (top of file) | B10 | present |
| `.codex/agents/csharp-orchestrator.toml` | 1 | (top of file) | B10 | present |
| `.codex/agents/csharp-typed-engineer-c1.toml` | 1 | (top of file) | B9 | present |
| `.codex/agents/csharp-typed-engineer-c1.toml` | 2 | ## Workflow | B9 | present |
| `.codex/agents/csharp-typed-engineer-c1.toml` | 3 | ## Stop Conditions | B9 | present |
| `.codex/agents/csharp-typed-engineer-c2.toml` | 1 | (top of file) | B9 | present |
| `.codex/agents/csharp-typed-engineer-c2.toml` | 2 | ## Workflow | B9 | present |
| `.codex/agents/csharp-typed-engineer-c2.toml` | 3 | ## Stop Conditions | B9 | present |
| `.codex/agents/csharp-typed-engineer-c3-elevated.toml` | 1 | (top of file) | B9 | present |
| `.codex/agents/csharp-typed-engineer-c3-elevated.toml` | 2 | ## Workflow | B9 | present |
| `.codex/agents/csharp-typed-engineer-c3-elevated.toml` | 3 | ## Stop Conditions | B9 | present |
| `.codex/agents/csharp-typed-engineer-c3.toml` | 1 | (top of file) | B9 | present |
| `.codex/agents/csharp-typed-engineer-c3.toml` | 2 | ## Workflow | B9 | present |
| `.codex/agents/csharp-typed-engineer-c3.toml` | 3 | ## Stop Conditions | B9 | present |
| `.codex/agents/csharp-typed-engineer-c4.toml` | 1 | (top of file) | B9 | present |
| `.codex/agents/csharp-typed-engineer-c4.toml` | 2 | ## Workflow | B9 | present |
| `.codex/agents/csharp-typed-engineer-c4.toml` | 3 | ## Stop Conditions | B9 | present |
| `.codex/agents/csharp-typed-engineer.toml` | 1 | (top of file) | B9 | present |
| `.codex/agents/csharp-typed-engineer.toml` | 2 | ## Workflow | B9 | present |
| `.codex/agents/csharp-typed-engineer.toml` | 3 | ## Stop Conditions | B9 | present |
| `.codex/agents/feature-review.toml` | 1 | ### Coverage Thresholds | B7 | present |
| `.codex/agents/feature-review.toml` | 2 | ### Verification Procedure | B7 | present |
| `.codex/agents/powershell-atomic-executor.toml` | 1 | (top of file) | B10 | present |
| `.codex/agents/powershell-atomic-executor.toml` | 2 | (top of file) | B10 | present |
| `.codex/agents/powershell-atomic-planning.toml` | 1 | (top of file) | B10 | present |
| `.codex/agents/powershell-di-unit-test-engineer.toml` | 1 | (top of file) | B10 | present |
| `.codex/agents/powershell-orchestrator.toml` | 1 | (top of file) | B10 | present |
| `.codex/agents/powershell-typed-engineer-c1.toml` | 1 | (top of file) | B9 | present |
| `.codex/agents/powershell-typed-engineer-c1.toml` | 2 | ## Workflow | B9 | present |
| `.codex/agents/powershell-typed-engineer-c1.toml` | 3 | ## Stop Conditions | B9 | present |
| `.codex/agents/powershell-typed-engineer-c2.toml` | 1 | (top of file) | B9 | present |
| `.codex/agents/powershell-typed-engineer-c2.toml` | 2 | ## Workflow | B9 | present |
| `.codex/agents/powershell-typed-engineer-c2.toml` | 3 | ## Stop Conditions | B9 | present |
| `.codex/agents/powershell-typed-engineer-c3-elevated.toml` | 1 | (top of file) | B9 | present |
| `.codex/agents/powershell-typed-engineer-c3-elevated.toml` | 2 | ## Workflow | B9 | present |
| `.codex/agents/powershell-typed-engineer-c3-elevated.toml` | 3 | ## Stop Conditions | B9 | present |
| `.codex/agents/powershell-typed-engineer-c3.toml` | 1 | (top of file) | B9 | present |
| `.codex/agents/powershell-typed-engineer-c3.toml` | 2 | ## Workflow | B9 | present |
| `.codex/agents/powershell-typed-engineer-c3.toml` | 3 | ## Stop Conditions | B9 | present |
| `.codex/agents/powershell-typed-engineer-c4.toml` | 1 | (top of file) | B9 | present |
| `.codex/agents/powershell-typed-engineer-c4.toml` | 2 | ## Workflow | B9 | present |
| `.codex/agents/powershell-typed-engineer-c4.toml` | 3 | ## Stop Conditions | B9 | present |
| `.codex/agents/powershell-typed-engineer.toml` | 1 | (top of file) | B9 | present |
| `.codex/agents/powershell-typed-engineer.toml` | 2 | ## Workflow | B9 | present |
| `.codex/agents/powershell-typed-engineer.toml` | 3 | ## Stop Conditions | B9 | present |
| `.codex/agents/pytest-unit-test-coding.toml` | 1 | (top of file) | B10 | present |
| `.codex/agents/python-atomic-executor.toml` | 1 | (top of file) | B10 | present |
| `.codex/agents/python-atomic-executor.toml` | 2 | (top of file) | B10 | present |
| `.codex/agents/python-atomic-planning.toml` | 1 | (top of file) | B10 | present |
| `.codex/agents/python-execution-only-typed.toml` | 1 | (top of file) | B10 | present |
| `.codex/agents/python-orchestrator.toml` | 1 | (top of file) | B10 | present |
| `.codex/agents/python-typed-engineer-c1.toml` | 1 | (top of file) | B9 | present |
| `.codex/agents/python-typed-engineer-c1.toml` | 2 | ## Workflow | B9 | present |
| `.codex/agents/python-typed-engineer-c1.toml` | 3 | ## Stop Conditions | B9 | present |
| `.codex/agents/python-typed-engineer-c2.toml` | 1 | (top of file) | B9 | present |
| `.codex/agents/python-typed-engineer-c2.toml` | 2 | ## Workflow | B9 | present |
| `.codex/agents/python-typed-engineer-c2.toml` | 3 | ## Stop Conditions | B9 | present |
| `.codex/agents/python-typed-engineer-c3-elevated.toml` | 1 | (top of file) | B9 | present |
| `.codex/agents/python-typed-engineer-c3-elevated.toml` | 2 | ## Workflow | B9 | present |
| `.codex/agents/python-typed-engineer-c3-elevated.toml` | 3 | ## Stop Conditions | B9 | present |
| `.codex/agents/python-typed-engineer-c3.toml` | 1 | (top of file) | B9 | present |
| `.codex/agents/python-typed-engineer-c3.toml` | 2 | ## Workflow | B9 | present |
| `.codex/agents/python-typed-engineer-c3.toml` | 3 | ## Stop Conditions | B9 | present |
| `.codex/agents/python-typed-engineer-c4.toml` | 1 | (top of file) | B9 | present |
| `.codex/agents/python-typed-engineer-c4.toml` | 2 | ## Workflow | B9 | present |
| `.codex/agents/python-typed-engineer-c4.toml` | 3 | ## Stop Conditions | B9 | present |
| `.codex/agents/python-typed-engineer.toml` | 1 | (top of file) | B9 | present |
| `.codex/agents/python-typed-engineer.toml` | 2 | ## Workflow | B9 | present |
| `.codex/agents/python-typed-engineer.toml` | 3 | ## Stop Conditions | B9 | present |
| `.github/agents/Powershell DI Unit Test Engineer.agent.md` | 1 | (top of file) | B10 | present |
| `.github/agents/Powershell DI Unit Test Engineer.agent.md` | 2 | (top of file) | B10 | present |
| `.github/agents/Powershell DI Unit Test Engineer.agent.md` | 4 | ## 4) Quality gates (hard stop) | B10 | present |
| `.github/agents/Powershell DI Unit Test Engineer.agent.md` | 5 | ### Static baseline runs (required before edits) | B10 | present |
| `.github/agents/Powershell DI Unit Test Engineer.agent.md` | 6 | ## Phase A — Static baseline capture (read-only) | B10 | present |
| `.github/agents/Powershell DI Unit Test Engineer.agent.md` | 7 | ## Phase D — Final QA gate | B10 | present |
| `.github/agents/Powershell DI Unit Test Engineer.agent.md` | 8 | # Reporting requirements (every response) | B10 | present |
| `.github/agents/atomic_executor.agent.md` | 1 | ### 2.0.1 Mode-aware preflight gate (Mandatory) | B10 | present |
| `.github/agents/atomic_executor.agent.md` | 2 | ### 2.2 Validate plan format (must be executable) | B10 | present |
| `.github/agents/atomic_planning.agent.md` | 1 | ## 2. Output Format (Mandatory) | B10 | present |
| `.github/agents/atomic_planning.agent.md` | 2 | ### 2.5.0 Mode source precedence and fail-closed routing (Mandatory) | B10 | present |
| `.github/agents/atomic_planning.agent.md` | 4 | ## 12. Self-Checking Before Responding | B10 | present |
| `.github/agents/csharp-atomic-executor.agent.md` | 1 | ### 2.0.1 Mode-aware preflight gate (Mandatory) | B10 | present |
| `.github/agents/csharp-atomic-executor.agent.md` | 2 | ### 2.2 Validate plan format (must be executable) | B10 | present |
| `.github/agents/csharp-atomic-executor.agent.md` | 3 | ### 7.3 Gate requirements (required) | B10 | present |
| `.github/agents/csharp-atomic-planning.agent.md` | 1 | ## 2. Output Format (Mandatory) | B10 | present |
| `.github/agents/csharp-atomic-planning.agent.md` | 2 | ### 2.5.0 Mode source precedence and fail-closed routing (Mandatory) | B10 | present |
| `.github/agents/csharp-orchestrator.agent.md` | 1 | (top of file) | B10 | present |
| `.github/agents/csharp-orchestrator.agent.md` | 2 | (top of file) | B10 | present |
| `.github/agents/csharp-orchestrator.agent.md` | 3 | ### Step S6 — Delegate constrained small-path development | B10 | present |
| `.github/agents/csharp-orchestrator.agent.md` | 4 | ### Step 5 — Execute approved atomic plan | B10 | present |
| `.github/agents/csharp-typed-engineer.agent.md` | 1 | (top of file) | B10 | present |
| `.github/agents/csharp-typed-engineer.agent.md` | 2 | (top of file) | B10 | present |
| `.github/agents/csharp-typed-engineer.agent.md` | 3 | # Role and objective | B10 | present |
| `.github/agents/csharp-typed-engineer.agent.md` | 4 | ## 5) Quality gates (hard stop) | B10 | present |
| `.github/agents/csharp-typed-engineer.agent.md` | 5 | ## Phase A — Static baseline capture (read-only) | B10 | present |
| `.github/agents/csharp-typed-engineer.agent.md` | 6 | ## Phase C — Implement in small batches | B10 | present |
| `.github/agents/csharp-typed-engineer.agent.md` | 7 | ## Phase D — Final QA gate | B10 | present |
| `.github/agents/csharp-typed-engineer.agent.md` | 8 | # Reporting requirements (every response) | B10 | present |
| `.github/agents/epic-review.agent.md` | 1 | ### Fail-before Exception Dossier (acceptable evidence type) | B10 | present |
| `.github/agents/orchestrator.agent.md` | 1 | (top of file) | B10 | present |
| `.github/agents/orchestrator.agent.md` | 2 | (top of file) | B10 | present |
| `.github/agents/orchestrator.agent.md` | 3 | (top of file) | B10 | present |
| `.github/agents/orchestrator.agent.md` | 4 | ### Step S6 — Delegate constrained small-path development | B10 | present |
| `.github/agents/orchestrator.agent.md` | 5 | ### Step 4 — Build atomic plan and preflight all clear | B10 | present |
| `.github/agents/orchestrator.agent.md` | 6 | ### Step 5 — Execute approved atomic plan | B10 | present |
| `.github/agents/powershell-atomic-executor.agent.md` | 1 | (top of file) | B10 | present |
| `.github/agents/powershell-atomic-executor.agent.md` | 2 | ### 2.0.1 Mode-aware preflight gate (Mandatory) | B10 | present |
| `.github/agents/powershell-atomic-executor.agent.md` | 3 | ### 2.2 Validate plan format (must be executable) | B10 | present |
| `.github/agents/powershell-atomic-executor.agent.md` | 6 | ### 7.3 Gate requirements (required) | B10 | present |
| `.github/agents/powershell-atomic-planning.agent.md` | 1 | ## 2. Output Format (Mandatory) | B10 | present |
| `.github/agents/powershell-atomic-planning.agent.md` | 2 | ### 2.5.0 Mode source precedence and fail-closed routing (Mandatory) | B10 | present |
| `.github/agents/powershell-atomic-planning.agent.md` | 4 | ## 12. Self-Checking Before Responding | B10 | present |
| `.github/agents/powershell-orchestrator.agent.md` | 1 | (top of file) | B10 | present |
| `.github/agents/powershell-orchestrator.agent.md` | 2 | (top of file) | B10 | present |
| `.github/agents/powershell-orchestrator.agent.md` | 3 | ### Step S6 — Delegate constrained small-path development | B10 | present |
| `.github/agents/powershell-orchestrator.agent.md` | 4 | ### Step 4 — Build atomic plan and preflight all clear | B10 | present |
| `.github/agents/powershell-orchestrator.agent.md` | 5 | ### Step 5 — Execute approved atomic plan | B10 | present |
| `.github/agents/powershell-typed-engineer.agent.md` | 1 | (top of file) | B10 | present |
| `.github/agents/powershell-typed-engineer.agent.md` | 2 | (top of file) | B10 | present |
| `.github/agents/powershell-typed-engineer.agent.md` | 3 | # Role and objective | B10 | present |
| `.github/agents/powershell-typed-engineer.agent.md` | 4 | ## 5) Quality gates (hard stop) | B10 | present |
| `.github/agents/powershell-typed-engineer.agent.md` | 5 | ## 6) Toolchain must be executed (no unverified work) | B10 | present |
| `.github/agents/powershell-typed-engineer.agent.md` | 6 | ## Phase C — Implement in small batches | B10 | present |
| `.github/agents/powershell-typed-engineer.agent.md` | 7 | ## Phase D — Final QA gate | B10 | present |
| `.github/agents/powershell-typed-engineer.agent.md` | 8 | # Reporting requirements (every response) | B10 | present |
| `.github/agents/pytest-unit-test-coding.agent.md` | 1 | (top of file) | B10 | present |
| `.github/agents/pytest-unit-test-coding.agent.md` | 2 | (top of file) | B10 | present |
| `.github/agents/pytest-unit-test-coding.agent.md` | 3 | # Role and objective | B10 | present |
| `.github/agents/pytest-unit-test-coding.agent.md` | 4 | ## Phase A — Static baseline capture (read-only) | B10 | present |
| `.github/agents/pytest-unit-test-coding.agent.md` | 5 | ## Phase C — Implement in small batches | B10 | present |
| `.github/agents/pytest-unit-test-coding.agent.md` | 6 | # Reporting requirements (every response) | B10 | present |
| `.github/agents/python-atomic-executor.agent.md` | 1 | (top of file) | B10 | present |
| `.github/agents/python-atomic-executor.agent.md` | 2 | ### 2.0.1 Mode-aware preflight gate (Mandatory) | B10 | present |
| `.github/agents/python-atomic-executor.agent.md` | 3 | ### 2.2 Validate plan format (must be executable) | B10 | present |
| `.github/agents/python-atomic-executor.agent.md` | 5 | ### 7.3 Gate requirements (required) | B10 | present |
| `.github/agents/python-atomic-planning.agent.md` | 1 | ## 2. Output Format (Mandatory) | B10 | present |
| `.github/agents/python-atomic-planning.agent.md` | 2 | ### 2.5.0 Mode source precedence and fail-closed routing (Mandatory) | B10 | present |
| `.github/agents/python-execution-only-typed.agent.md` | 1 | (top of file) | B10 | present |
| `.github/agents/python-execution-only-typed.agent.md` | 2 | ## 4) Quality gates (hard stop) | B10 | present |
| `.github/agents/python-execution-only-typed.agent.md` | 3 | ## Phase A — Static baseline capture (read-only) | B10 | present |
| `.github/agents/python-execution-only-typed.agent.md` | 5 | ## Phase C — Final QA gate | B10 | present |
| `.github/agents/python-execution-only-typed.agent.md` | 6 | # Reporting requirements (every response) | B10 | present |
| `.github/agents/python-orchestrator.agent.md` | 1 | (top of file) | B10 | present |
| `.github/agents/python-orchestrator.agent.md` | 2 | (top of file) | B10 | present |
| `.github/agents/python-orchestrator.agent.md` | 3 | ### Step S6 — Delegate constrained small-path development | B10 | present |
| `.github/agents/python-orchestrator.agent.md` | 4 | ### Step 4 — Build atomic plan and preflight all clear | B10 | present |
| `.github/agents/python-orchestrator.agent.md` | 5 | ### Step 5 — Execute approved atomic plan | B10 | present |
| `.github/agents/python-typed-engineer.agent.md` | 1 | (top of file) | B10 | present |
| `.github/agents/python-typed-engineer.agent.md` | 2 | (top of file) | B10 | present |
| `.github/agents/python-typed-engineer.agent.md` | 3 | ## Mode-aware planning handoff contract (Mandatory) | B10 | present |
| `.github/agents/python-typed-engineer.agent.md` | 4 | ## 4) Quality gates (hard stop) | B10 | present |
| `.github/agents/python-typed-engineer.agent.md` | 5 | ## Phase A — Static baseline capture (read-only) | B10 | present |
| `.github/agents/python-typed-engineer.agent.md` | 7 | ## Phase D — Final QA gate | B10 | present |
| `.github/agents/python-typed-engineer.agent.md` | 8 | # Reporting requirements (every response) | B10 | present |
| `.github/agents/typescript-engineer.agent.md` | 2 | ## Role and objective | B10 | present |
| `.github/agents/typescript-engineer.agent.md` | 3 | ## TDD execution model | B10 | present |
| `.github/codex/execute-hard-lock.prompt.md` | 1 | (top of file) | B10 | present |
| `.github/codex/execute-hard-lock.prompt.md` | 2 | (top of file) | B10 | present |
| `.github/prompts/execute-hard-lock.prompt.md` | 1 | (top of file) | B10 | present |
| `.github/prompts/execute-hard-lock.prompt.md` | 2 | (top of file) | B10 | present |
| `.github/prompts/review-feature.prompt.md` | 1 | ### Required deliverables | B7 | present |
| `.github/skills/atomic-plan-contract/SKILL.md` | 2 | ## Short-Path Minimal Plan Contract | B1 | present |
| `.github/skills/atomic-plan-contract/SKILL.md` | 4 | ## Phase 0 Requirements | B1 | present |
| `.github/skills/atomic-plan-contract/SKILL.md` | 5 | ## Coverage Evidence Contract (Mandatory when policy requires coverage) | B2 | present |
| `.github/skills/atomic-plan-contract/SKILL.md` | 6 | ## Mode-Specific Mandatory Plan Gates | B3 | present |
| `.github/skills/execution-environment/SKILL.md` | 5 | ## Test Runtime | B4 | present |
| `.github/skills/feature-review-workflow/SKILL.md` | 3 | ## Ordered Procedure | B7 | present |
| `docs/features/templates/bug/plan.yyyy-MM-ddTHH-mm.md` | 1 | # <bug-name> (Plan) | B11 | present |
| `docs/features/templates/bug/plan.yyyy-MM-ddTHH-mm.md` | 2 | ## Pre-Mortem | B11 | present |
| `docs/features/templates/feature/plan.yyyy-MM-ddTHH-mm.md` | 1 | ## Implementation Plan (Atomic Tasks) | B11 | present |
| `docs/features/templates/feature/plan.yyyy-MM-ddTHH-mm.md` | 2 | ## Test Plan | B11 | present |
| `docs/features/templates/policy_audit/AGENTS.md` | 1 | ## Behavior: How to run a Policy Audit | B6 | present |
| `docs/features/templates/policy_audit/AGENTS.md` | 2 | ## Behavior: How to run a Policy Audit | B6 | present |
| `docs/features/templates/policy_audit/AGENTS.md` | 3 | ## Behavior: How to run a Policy Audit | B6 | present |
| `docs/features/templates/policy_audit/AGENTS.md` | 4 | ## Behavior: How to run a Policy Audit | B6 | present |
| `docs/features/templates/policy_audit/policy-audit.yyyy-MM-ddTHH-mm.md` | 2 | ### Coverage Evidence Checklist | B5 | present |
| `docs/features/templates/policy_audit/policy-audit.yyyy-MM-ddTHH-mm.md` | 3 | ### 1.2 Coverage and Scenarios | B5 | present |
| `docs/features/templates/policy_audit/policy-audit.yyyy-MM-ddTHH-mm.md` | 4 | ### 1.2.1 Per-Language Coverage Comparison | B5 | present |
| `docs/features/templates/policy_audit/policy-audit.yyyy-MM-ddTHH-mm.md` | 11 | [Provide a brief summary of overall compliance status and any major findings.] | B5 | present |
| `docs/features/templates/refactor/plan.yyyy-MM-ddTHH-mm.md` | 1 | ## Strategy | B11 | present |
| `docs/features/templates/refactor/plan.yyyy-MM-ddTHH-mm.md` | 2 | ## Test Plan | B11 | present |
| `extensions/drm-copilot/resources/claude-customizations/.claude-variants/csharp-legacy/agents/csharp-typed-engineer.md` | 1 | (top of file) | B9 | present |
| `extensions/drm-copilot/resources/claude-customizations/.claude-variants/csharp-legacy/agents/csharp-typed-engineer.md` | 2 | ## Workflow | B9 | present |
| `extensions/drm-copilot/resources/claude-customizations/.claude-variants/csharp-legacy/agents/csharp-typed-engineer.md` | 3 | ## Stop Conditions | B9 | present |
| `extensions/drm-copilot/resources/claude-customizations/.claude-variants/csharp-legacy/skills/csharp-qa-gate/SKILL.md` | 1 | (top of file) | B8 | present |
| `extensions/drm-copilot/resources/claude-customizations/.claude-variants/csharp-legacy/skills/csharp-qa-gate/SKILL.md` | 2 | ## When to Use This Skill | B8 | present |
| `extensions/drm-copilot/resources/claude-customizations/.claude-variants/csharp-legacy/skills/csharp-qa-gate/SKILL.md` | 3 | ## Gate Requirements (Hard Gate) | B8 | present |
| `extensions/drm-copilot/resources/claude-customizations/.claude-variants/csharp-legacy/skills/invoke-csharp-engineer/SKILL.md` | 1 | (top of file) | B9 | present |
| `extensions/drm-copilot/resources/claude-customizations/.claude-variants/csharp-legacy/skills/invoke-csharp-engineer/SKILL.md` | 2 | ## Output Paths | B9 | present |
| `extensions/drm-copilot/resources/claude-customizations/.claude-variants/csharp-legacy/skills/invoke-csharp-engineer/SKILL.md` | 3 | ## Required Reporting Block | B9 | present |
| `extensions/drm-copilot/resources/claude-customizations/.claude/agents/atomic-planner.md` | 1 | ## Plan Structure | B9 | changed by 0005 |
| `extensions/drm-copilot/resources/claude-customizations/.claude/agents/atomic-planner.md` | 2 | ## Requirements | B9 | present |
| `extensions/drm-copilot/resources/claude-customizations/.claude/agents/csharp-typed-engineer.md` | 1 | (top of file) | B9 | present |
| `extensions/drm-copilot/resources/claude-customizations/.claude/agents/csharp-typed-engineer.md` | 2 | ## Workflow | B9 | present |
| `extensions/drm-copilot/resources/claude-customizations/.claude/agents/csharp-typed-engineer.md` | 3 | ## Stop Conditions | B9 | present |
| `extensions/drm-copilot/resources/claude-customizations/.claude/agents/feature-review.md` | 1 | ### Coverage Thresholds | B7 | present |
| `extensions/drm-copilot/resources/claude-customizations/.claude/agents/feature-review.md` | 2 | ### Verification Procedure | B7 | present |
| `extensions/drm-copilot/resources/claude-customizations/.claude/agents/powershell-typed-engineer.md` | 1 | (top of file) | B9 | present |
| `extensions/drm-copilot/resources/claude-customizations/.claude/agents/powershell-typed-engineer.md` | 2 | ## Workflow | B9 | present |
| `extensions/drm-copilot/resources/claude-customizations/.claude/agents/powershell-typed-engineer.md` | 3 | ## Stop Conditions | B9 | present |
| `extensions/drm-copilot/resources/claude-customizations/.claude/agents/python-typed-engineer.md` | 1 | (top of file) | B9 | present |
| `extensions/drm-copilot/resources/claude-customizations/.claude/agents/python-typed-engineer.md` | 2 | ## Workflow | B9 | present |
| `extensions/drm-copilot/resources/claude-customizations/.claude/agents/python-typed-engineer.md` | 3 | ## Stop Conditions | B9 | present |
| `extensions/drm-copilot/resources/claude-customizations/.claude/skills/atomic-plan-contract/SKILL.md` | 2 | ## Short-Path Minimal Plan Contract | B1 | present |
| `extensions/drm-copilot/resources/claude-customizations/.claude/skills/atomic-plan-contract/SKILL.md` | 4 | ## Phase 0 Requirements | B1 | present |
| `extensions/drm-copilot/resources/claude-customizations/.claude/skills/atomic-plan-contract/SKILL.md` | 5 | ## Coverage Evidence Contract (Mandatory when policy requires coverage) | B2 | present |
| `extensions/drm-copilot/resources/claude-customizations/.claude/skills/atomic-plan-contract/SKILL.md` | 6 | ## Mode-Specific Mandatory Plan Gates | B3 | present |
| `extensions/drm-copilot/resources/claude-customizations/.claude/skills/csharp-qa-gate/SKILL.md` | 1 | (top of file) | B8 | present |
| `extensions/drm-copilot/resources/claude-customizations/.claude/skills/csharp-qa-gate/SKILL.md` | 2 | ## When to Use This Skill | B8 | present |
| `extensions/drm-copilot/resources/claude-customizations/.claude/skills/csharp-qa-gate/SKILL.md` | 3 | ## Gate Requirements (Hard Gate) | B8 | present |
| `extensions/drm-copilot/resources/claude-customizations/.claude/skills/execution-environment/SKILL.md` | 5 | ## Test Runtime | B4 | present |
| `extensions/drm-copilot/resources/claude-customizations/.claude/skills/feature-review-workflow/SKILL.md` | 2 | ## Ordered Procedure | B7 | present |
| `extensions/drm-copilot/resources/claude-customizations/.claude/skills/feature-review-workflow/SKILL.md` | 3 | ## Ordered Procedure | B7 | present |
| `extensions/drm-copilot/resources/claude-customizations/.claude/skills/invoke-csharp-engineer/SKILL.md` | 1 | (top of file) | B9 | present |
| `extensions/drm-copilot/resources/claude-customizations/.claude/skills/invoke-csharp-engineer/SKILL.md` | 2 | ## Output Paths | B9 | present |
| `extensions/drm-copilot/resources/claude-customizations/.claude/skills/invoke-csharp-engineer/SKILL.md` | 3 | ## Required Reporting Block | B9 | present |
| `extensions/drm-copilot/resources/claude-customizations/.claude/skills/invoke-powershell-engineer/SKILL.md` | 1 | (top of file) | B9 | present |
| `extensions/drm-copilot/resources/claude-customizations/.claude/skills/invoke-powershell-engineer/SKILL.md` | 2 | ## Output Paths | B9 | present |
| `extensions/drm-copilot/resources/claude-customizations/.claude/skills/invoke-powershell-engineer/SKILL.md` | 3 | ## Required Reporting Block | B9 | present |
| `extensions/drm-copilot/resources/claude-customizations/.claude/skills/invoke-python-engineer/SKILL.md` | 1 | (top of file) | B9 | present |
| `extensions/drm-copilot/resources/claude-customizations/.claude/skills/invoke-python-engineer/SKILL.md` | 2 | ## Output Paths | B9 | present |
| `extensions/drm-copilot/resources/claude-customizations/.claude/skills/invoke-python-engineer/SKILL.md` | 3 | ## Required Reporting Block | B9 | present |
| `extensions/drm-copilot/resources/claude-customizations/.claude/skills/powershell-qa-gate/SKILL.md` | 1 | (top of file) | B8 | present |
| `extensions/drm-copilot/resources/claude-customizations/.claude/skills/powershell-qa-gate/SKILL.md` | 2 | ## When to Use This Skill | B8 | present |
| `extensions/drm-copilot/resources/claude-customizations/.claude/skills/powershell-qa-gate/SKILL.md` | 3 | ## Toolchain Execution Sequence | B8 | present |
| `extensions/drm-copilot/resources/claude-customizations/.claude/skills/python-qa-gate/SKILL.md` | 1 | (top of file) | B8 | present |
| `extensions/drm-copilot/resources/claude-customizations/.claude/skills/python-qa-gate/SKILL.md` | 2 | ## When to Use This Skill | B8 | present |
| `extensions/drm-copilot/resources/claude-customizations/.claude/skills/python-qa-gate/SKILL.md` | 3 | ## Toolchain Execution Sequence | B8 | present |
| `extensions/drm-copilot/resources/claude-customizations/.claude/skills/remediation-handoff-atomic-planner/SKILL.md` | 1 | ## Plan Shape | B9 | changed by 0003,0005 |
| `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents-variants/csharp-legacy/skills/csharp-qa-gate/SKILL.md` | 1 | (top of file) | B8 | present |
| `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents-variants/csharp-legacy/skills/csharp-qa-gate/SKILL.md` | 2 | ## When to Use This Skill | B8 | present |
| `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents-variants/csharp-legacy/skills/csharp-qa-gate/SKILL.md` | 3 | ## Gate Requirements (Hard Gate) | B8 | present |
| `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents-variants/csharp-legacy/skills/invoke-csharp-engineer/SKILL.md` | 1 | (top of file) | B9 | present |
| `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents-variants/csharp-legacy/skills/invoke-csharp-engineer/SKILL.md` | 2 | ## Output Paths | B9 | present |
| `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents-variants/csharp-legacy/skills/invoke-csharp-engineer/SKILL.md` | 3 | ## Required Reporting Block | B9 | present |
| `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/atomic-plan-contract/SKILL.md` | 2 | ## Short-Path Minimal Plan Contract | B1 | present |
| `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/atomic-plan-contract/SKILL.md` | 4 | ## Phase 0 Requirements | B1 | present |
| `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/atomic-plan-contract/SKILL.md` | 5 | ## Coverage Evidence Contract (Mandatory when policy requires coverage) | B2 | present |
| `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/atomic-plan-contract/SKILL.md` | 6 | ## Mode-Specific Mandatory Plan Gates | B3 | present |
| `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/atomic-planner/SKILL.md` | 1 | ## Plan Requirements | B9 | present |
| `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/csharp-qa-gate/SKILL.md` | 1 | (top of file) | B8 | present |
| `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/csharp-qa-gate/SKILL.md` | 2 | ## When to Use This Skill | B8 | present |
| `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/csharp-qa-gate/SKILL.md` | 3 | ## Gate Requirements (Hard Gate) | B8 | present |
| `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/execution-environment/SKILL.md` | 5 | ## Test Runtime | B4 | present |
| `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/feature-review-workflow/SKILL.md` | 2 | ## Ordered Procedure | B7 | present |
| `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/feature-review-workflow/SKILL.md` | 3 | ## Ordered Procedure | B7 | present |
| `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/invoke-csharp-engineer/SKILL.md` | 1 | (top of file) | B9 | present |
| `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/invoke-csharp-engineer/SKILL.md` | 2 | ## Output Paths | B9 | present |
| `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/invoke-csharp-engineer/SKILL.md` | 3 | ## Required Reporting Block | B9 | present |
| `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/invoke-powershell-engineer/SKILL.md` | 1 | (top of file) | B9 | present |
| `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/invoke-powershell-engineer/SKILL.md` | 2 | ## Output Paths | B9 | present |
| `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/invoke-powershell-engineer/SKILL.md` | 3 | ## Required Reporting Block | B9 | present |
| `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/invoke-python-engineer/SKILL.md` | 1 | (top of file) | B9 | present |
| `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/invoke-python-engineer/SKILL.md` | 2 | ## Output Paths | B9 | present |
| `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/invoke-python-engineer/SKILL.md` | 3 | ## Required Reporting Block | B9 | present |
| `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/orchestrator-workflow/SKILL.md` | 1 | ## Large Path | B9 | present |
| `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/powershell-qa-gate/SKILL.md` | 1 | (top of file) | B8 | present |
| `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/powershell-qa-gate/SKILL.md` | 2 | ## When to Use This Skill | B8 | present |
| `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/powershell-qa-gate/SKILL.md` | 3 | ## Toolchain Execution Sequence | B8 | present |
| `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/python-qa-gate/SKILL.md` | 1 | (top of file) | B8 | present |
| `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/python-qa-gate/SKILL.md` | 2 | ## When to Use This Skill | B8 | present |
| `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/python-qa-gate/SKILL.md` | 3 | ## Toolchain Execution Sequence | B8 | present |
| `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex-variants/csharp-legacy/agents/csharp-typed-engineer.toml` | 1 | (top of file) | B9 | present |
| `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex-variants/csharp-legacy/agents/csharp-typed-engineer.toml` | 2 | ## Workflow | B9 | present |
| `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex-variants/csharp-legacy/agents/csharp-typed-engineer.toml` | 3 | ## Stop Conditions | B9 | present |
| `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/atomic-planner-c1.toml` | 1 | ## Requirements | B9 | changed by 0005 |
| `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/atomic-planner-c2.toml` | 1 | ## Requirements | B9 | regenerated from base changed by 0005 |
| `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/atomic-planner-c3-elevated.toml` | 1 | ## Requirements | B9 | regenerated from base changed by 0005 |
| `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/atomic-planner-c3.toml` | 1 | ## Requirements | B9 | regenerated from base changed by 0005 |
| `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/atomic-planner-c4.toml` | 1 | ## Requirements | B9 | regenerated from base changed by 0005 |
| `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/atomic-planner.toml` | 1 | ## Requirements | B9 | changed by 0005 |
| `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/csharp-atomic-executor.toml` | 1 | (top of file) | B10 | present |
| `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/csharp-atomic-planning.toml` | 1 | (top of file) | B10 | present |
| `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/csharp-orchestrator.toml` | 1 | (top of file) | B10 | present |
| `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/csharp-typed-engineer-c1.toml` | 1 | (top of file) | B9 | present |
| `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/csharp-typed-engineer-c1.toml` | 2 | ## Workflow | B9 | present |
| `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/csharp-typed-engineer-c1.toml` | 3 | ## Stop Conditions | B9 | present |
| `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/csharp-typed-engineer-c2.toml` | 1 | (top of file) | B9 | present |
| `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/csharp-typed-engineer-c2.toml` | 2 | ## Workflow | B9 | present |
| `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/csharp-typed-engineer-c2.toml` | 3 | ## Stop Conditions | B9 | present |
| `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/csharp-typed-engineer-c3-elevated.toml` | 1 | (top of file) | B9 | present |
| `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/csharp-typed-engineer-c3-elevated.toml` | 2 | ## Workflow | B9 | present |
| `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/csharp-typed-engineer-c3-elevated.toml` | 3 | ## Stop Conditions | B9 | present |
| `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/csharp-typed-engineer-c3.toml` | 1 | (top of file) | B9 | present |
| `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/csharp-typed-engineer-c3.toml` | 2 | ## Workflow | B9 | present |
| `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/csharp-typed-engineer-c3.toml` | 3 | ## Stop Conditions | B9 | present |
| `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/csharp-typed-engineer-c4.toml` | 1 | (top of file) | B9 | present |
| `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/csharp-typed-engineer-c4.toml` | 2 | ## Workflow | B9 | present |
| `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/csharp-typed-engineer-c4.toml` | 3 | ## Stop Conditions | B9 | present |
| `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/csharp-typed-engineer.toml` | 1 | (top of file) | B9 | present |
| `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/csharp-typed-engineer.toml` | 2 | ## Workflow | B9 | present |
| `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/csharp-typed-engineer.toml` | 3 | ## Stop Conditions | B9 | present |
| `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/feature-review.toml` | 1 | ### Coverage Thresholds | B7 | present |
| `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/feature-review.toml` | 2 | ### Verification Procedure | B7 | present |
| `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/powershell-atomic-executor.toml` | 1 | (top of file) | B10 | present |
| `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/powershell-atomic-executor.toml` | 2 | (top of file) | B10 | present |
| `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/powershell-atomic-planning.toml` | 1 | (top of file) | B10 | present |
| `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/powershell-di-unit-test-engineer.toml` | 1 | (top of file) | B10 | present |
| `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/powershell-orchestrator.toml` | 1 | (top of file) | B10 | present |
| `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/powershell-typed-engineer-c1.toml` | 1 | (top of file) | B9 | present |
| `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/powershell-typed-engineer-c1.toml` | 2 | ## Workflow | B9 | present |
| `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/powershell-typed-engineer-c1.toml` | 3 | ## Stop Conditions | B9 | present |
| `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/powershell-typed-engineer-c2.toml` | 1 | (top of file) | B9 | present |
| `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/powershell-typed-engineer-c2.toml` | 2 | ## Workflow | B9 | present |
| `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/powershell-typed-engineer-c2.toml` | 3 | ## Stop Conditions | B9 | present |
| `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/powershell-typed-engineer-c3-elevated.toml` | 1 | (top of file) | B9 | present |
| `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/powershell-typed-engineer-c3-elevated.toml` | 2 | ## Workflow | B9 | present |
| `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/powershell-typed-engineer-c3-elevated.toml` | 3 | ## Stop Conditions | B9 | present |
| `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/powershell-typed-engineer-c3.toml` | 1 | (top of file) | B9 | present |
| `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/powershell-typed-engineer-c3.toml` | 2 | ## Workflow | B9 | present |
| `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/powershell-typed-engineer-c3.toml` | 3 | ## Stop Conditions | B9 | present |
| `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/powershell-typed-engineer-c4.toml` | 1 | (top of file) | B9 | present |
| `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/powershell-typed-engineer-c4.toml` | 2 | ## Workflow | B9 | present |
| `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/powershell-typed-engineer-c4.toml` | 3 | ## Stop Conditions | B9 | present |
| `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/powershell-typed-engineer.toml` | 1 | (top of file) | B9 | present |
| `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/powershell-typed-engineer.toml` | 2 | ## Workflow | B9 | present |
| `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/powershell-typed-engineer.toml` | 3 | ## Stop Conditions | B9 | present |
| `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/pytest-unit-test-coding.toml` | 1 | (top of file) | B10 | present |
| `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/python-atomic-executor.toml` | 1 | (top of file) | B10 | present |
| `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/python-atomic-executor.toml` | 2 | (top of file) | B10 | present |
| `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/python-atomic-planning.toml` | 1 | (top of file) | B10 | present |
| `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/python-execution-only-typed.toml` | 1 | (top of file) | B10 | present |
| `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/python-orchestrator.toml` | 1 | (top of file) | B10 | present |
| `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/python-typed-engineer-c1.toml` | 1 | (top of file) | B9 | present |
| `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/python-typed-engineer-c1.toml` | 2 | ## Workflow | B9 | present |
| `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/python-typed-engineer-c1.toml` | 3 | ## Stop Conditions | B9 | present |
| `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/python-typed-engineer-c2.toml` | 1 | (top of file) | B9 | present |
| `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/python-typed-engineer-c2.toml` | 2 | ## Workflow | B9 | present |
| `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/python-typed-engineer-c2.toml` | 3 | ## Stop Conditions | B9 | present |
| `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/python-typed-engineer-c3-elevated.toml` | 1 | (top of file) | B9 | present |
| `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/python-typed-engineer-c3-elevated.toml` | 2 | ## Workflow | B9 | present |
| `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/python-typed-engineer-c3-elevated.toml` | 3 | ## Stop Conditions | B9 | present |
| `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/python-typed-engineer-c3.toml` | 1 | (top of file) | B9 | present |
| `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/python-typed-engineer-c3.toml` | 2 | ## Workflow | B9 | present |
| `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/python-typed-engineer-c3.toml` | 3 | ## Stop Conditions | B9 | present |
| `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/python-typed-engineer-c4.toml` | 1 | (top of file) | B9 | present |
| `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/python-typed-engineer-c4.toml` | 2 | ## Workflow | B9 | present |
| `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/python-typed-engineer-c4.toml` | 3 | ## Stop Conditions | B9 | present |
| `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/python-typed-engineer.toml` | 1 | (top of file) | B9 | present |
| `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/python-typed-engineer.toml` | 2 | ## Workflow | B9 | present |
| `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/python-typed-engineer.toml` | 3 | ## Stop Conditions | B9 | present |
| `extensions/drm-copilot/resources/customizations/.github/agents/Powershell DI Unit Test Engineer.agent.md` | 1 | (top of file) | B10 | present |
| `extensions/drm-copilot/resources/customizations/.github/agents/Powershell DI Unit Test Engineer.agent.md` | 2 | (top of file) | B10 | present |
| `extensions/drm-copilot/resources/customizations/.github/agents/Powershell DI Unit Test Engineer.agent.md` | 4 | ## 4) Quality gates (hard stop) | B10 | present |
| `extensions/drm-copilot/resources/customizations/.github/agents/Powershell DI Unit Test Engineer.agent.md` | 5 | ### Static baseline runs (required before edits) | B10 | present |
| `extensions/drm-copilot/resources/customizations/.github/agents/Powershell DI Unit Test Engineer.agent.md` | 6 | ## Phase A — Static baseline capture (read-only) | B10 | present |
| `extensions/drm-copilot/resources/customizations/.github/agents/Powershell DI Unit Test Engineer.agent.md` | 7 | ## Phase D — Final QA gate | B10 | present |
| `extensions/drm-copilot/resources/customizations/.github/agents/Powershell DI Unit Test Engineer.agent.md` | 8 | # Reporting requirements (every response) | B10 | present |
| `extensions/drm-copilot/resources/customizations/.github/agents/atomic_executor.agent.md` | 1 | ### 2.0.1 Mode-aware preflight gate (Mandatory) | B10 | present |
| `extensions/drm-copilot/resources/customizations/.github/agents/atomic_executor.agent.md` | 2 | ### 2.2 Validate plan format (must be executable) | B10 | present |
| `extensions/drm-copilot/resources/customizations/.github/agents/atomic_planning.agent.md` | 1 | ## 2. Output Format (Mandatory) | B10 | present |
| `extensions/drm-copilot/resources/customizations/.github/agents/atomic_planning.agent.md` | 2 | ### 2.5.0 Mode source precedence and fail-closed routing (Mandatory) | B10 | present |
| `extensions/drm-copilot/resources/customizations/.github/agents/atomic_planning.agent.md` | 4 | ## 12. Self-Checking Before Responding | B10 | present |
| `extensions/drm-copilot/resources/customizations/.github/agents/csharp-atomic-executor.agent.md` | 1 | ### 2.0.1 Mode-aware preflight gate (Mandatory) | B10 | present |
| `extensions/drm-copilot/resources/customizations/.github/agents/csharp-atomic-executor.agent.md` | 2 | ### 2.2 Validate plan format (must be executable) | B10 | present |
| `extensions/drm-copilot/resources/customizations/.github/agents/csharp-atomic-executor.agent.md` | 3 | ### 7.3 Gate requirements (required) | B10 | present |
| `extensions/drm-copilot/resources/customizations/.github/agents/csharp-atomic-planning.agent.md` | 1 | ## 2. Output Format (Mandatory) | B10 | present |
| `extensions/drm-copilot/resources/customizations/.github/agents/csharp-atomic-planning.agent.md` | 2 | ### 2.5.0 Mode source precedence and fail-closed routing (Mandatory) | B10 | present |
| `extensions/drm-copilot/resources/customizations/.github/agents/csharp-orchestrator.agent.md` | 1 | (top of file) | B10 | present |
| `extensions/drm-copilot/resources/customizations/.github/agents/csharp-orchestrator.agent.md` | 2 | (top of file) | B10 | present |
| `extensions/drm-copilot/resources/customizations/.github/agents/csharp-orchestrator.agent.md` | 3 | ### Step S6 — Delegate constrained small-path development | B10 | present |
| `extensions/drm-copilot/resources/customizations/.github/agents/csharp-orchestrator.agent.md` | 4 | ### Step 5 — Execute approved atomic plan | B10 | present |
| `extensions/drm-copilot/resources/customizations/.github/agents/csharp-typed-engineer.agent.md` | 1 | (top of file) | B10 | present |
| `extensions/drm-copilot/resources/customizations/.github/agents/csharp-typed-engineer.agent.md` | 2 | (top of file) | B10 | present |
| `extensions/drm-copilot/resources/customizations/.github/agents/csharp-typed-engineer.agent.md` | 3 | # Role and objective | B10 | present |
| `extensions/drm-copilot/resources/customizations/.github/agents/csharp-typed-engineer.agent.md` | 4 | ## 5) Quality gates (hard stop) | B10 | present |
| `extensions/drm-copilot/resources/customizations/.github/agents/csharp-typed-engineer.agent.md` | 5 | ## Phase A — Static baseline capture (read-only) | B10 | present |
| `extensions/drm-copilot/resources/customizations/.github/agents/csharp-typed-engineer.agent.md` | 6 | ## Phase C — Implement in small batches | B10 | present |
| `extensions/drm-copilot/resources/customizations/.github/agents/csharp-typed-engineer.agent.md` | 7 | ## Phase D — Final QA gate | B10 | present |
| `extensions/drm-copilot/resources/customizations/.github/agents/csharp-typed-engineer.agent.md` | 8 | # Reporting requirements (every response) | B10 | present |
| `extensions/drm-copilot/resources/customizations/.github/agents/epic-review.agent.md` | 1 | ### Fail-before Exception Dossier (acceptable evidence type) | B10 | present |
| `extensions/drm-copilot/resources/customizations/.github/agents/orchestrator.agent.md` | 1 | (top of file) | B10 | present |
| `extensions/drm-copilot/resources/customizations/.github/agents/orchestrator.agent.md` | 2 | (top of file) | B10 | present |
| `extensions/drm-copilot/resources/customizations/.github/agents/orchestrator.agent.md` | 3 | (top of file) | B10 | present |
| `extensions/drm-copilot/resources/customizations/.github/agents/orchestrator.agent.md` | 4 | ### Step S6 — Delegate constrained small-path development | B10 | present |
| `extensions/drm-copilot/resources/customizations/.github/agents/orchestrator.agent.md` | 5 | ### Step 4 — Build atomic plan and preflight all clear | B10 | present |
| `extensions/drm-copilot/resources/customizations/.github/agents/orchestrator.agent.md` | 6 | ### Step 5 — Execute approved atomic plan | B10 | present |
| `extensions/drm-copilot/resources/customizations/.github/agents/powershell-atomic-executor.agent.md` | 1 | (top of file) | B10 | present |
| `extensions/drm-copilot/resources/customizations/.github/agents/powershell-atomic-executor.agent.md` | 2 | ### 2.0.1 Mode-aware preflight gate (Mandatory) | B10 | present |
| `extensions/drm-copilot/resources/customizations/.github/agents/powershell-atomic-executor.agent.md` | 3 | ### 2.2 Validate plan format (must be executable) | B10 | present |
| `extensions/drm-copilot/resources/customizations/.github/agents/powershell-atomic-executor.agent.md` | 6 | ### 7.3 Gate requirements (required) | B10 | present |
| `extensions/drm-copilot/resources/customizations/.github/agents/powershell-atomic-planning.agent.md` | 1 | ## 2. Output Format (Mandatory) | B10 | present |
| `extensions/drm-copilot/resources/customizations/.github/agents/powershell-atomic-planning.agent.md` | 2 | ### 2.5.0 Mode source precedence and fail-closed routing (Mandatory) | B10 | present |
| `extensions/drm-copilot/resources/customizations/.github/agents/powershell-atomic-planning.agent.md` | 4 | ## 12. Self-Checking Before Responding | B10 | present |
| `extensions/drm-copilot/resources/customizations/.github/agents/powershell-orchestrator.agent.md` | 1 | (top of file) | B10 | present |
| `extensions/drm-copilot/resources/customizations/.github/agents/powershell-orchestrator.agent.md` | 2 | (top of file) | B10 | present |
| `extensions/drm-copilot/resources/customizations/.github/agents/powershell-orchestrator.agent.md` | 3 | ### Step S6 — Delegate constrained small-path development | B10 | present |
| `extensions/drm-copilot/resources/customizations/.github/agents/powershell-orchestrator.agent.md` | 4 | ### Step 4 — Build atomic plan and preflight all clear | B10 | present |
| `extensions/drm-copilot/resources/customizations/.github/agents/powershell-orchestrator.agent.md` | 5 | ### Step 5 — Execute approved atomic plan | B10 | present |
| `extensions/drm-copilot/resources/customizations/.github/agents/powershell-typed-engineer.agent.md` | 1 | (top of file) | B10 | present |
| `extensions/drm-copilot/resources/customizations/.github/agents/powershell-typed-engineer.agent.md` | 2 | (top of file) | B10 | present |
| `extensions/drm-copilot/resources/customizations/.github/agents/powershell-typed-engineer.agent.md` | 3 | # Role and objective | B10 | present |
| `extensions/drm-copilot/resources/customizations/.github/agents/powershell-typed-engineer.agent.md` | 4 | ## 5) Quality gates (hard stop) | B10 | present |
| `extensions/drm-copilot/resources/customizations/.github/agents/powershell-typed-engineer.agent.md` | 5 | ## 6) Toolchain must be executed (no unverified work) | B10 | present |
| `extensions/drm-copilot/resources/customizations/.github/agents/powershell-typed-engineer.agent.md` | 6 | ## Phase C — Implement in small batches | B10 | present |
| `extensions/drm-copilot/resources/customizations/.github/agents/powershell-typed-engineer.agent.md` | 7 | ## Phase D — Final QA gate | B10 | present |
| `extensions/drm-copilot/resources/customizations/.github/agents/powershell-typed-engineer.agent.md` | 8 | # Reporting requirements (every response) | B10 | present |
| `extensions/drm-copilot/resources/customizations/.github/agents/pytest-unit-test-coding.agent.md` | 1 | (top of file) | B10 | present |
| `extensions/drm-copilot/resources/customizations/.github/agents/pytest-unit-test-coding.agent.md` | 2 | (top of file) | B10 | present |
| `extensions/drm-copilot/resources/customizations/.github/agents/pytest-unit-test-coding.agent.md` | 3 | # Role and objective | B10 | present |
| `extensions/drm-copilot/resources/customizations/.github/agents/pytest-unit-test-coding.agent.md` | 4 | ## Phase A — Static baseline capture (read-only) | B10 | present |
| `extensions/drm-copilot/resources/customizations/.github/agents/pytest-unit-test-coding.agent.md` | 5 | ## Phase C — Implement in small batches | B10 | present |
| `extensions/drm-copilot/resources/customizations/.github/agents/pytest-unit-test-coding.agent.md` | 6 | # Reporting requirements (every response) | B10 | present |
| `extensions/drm-copilot/resources/customizations/.github/agents/python-atomic-executor.agent.md` | 1 | (top of file) | B10 | present |
| `extensions/drm-copilot/resources/customizations/.github/agents/python-atomic-executor.agent.md` | 2 | ### 2.0.1 Mode-aware preflight gate (Mandatory) | B10 | present |
| `extensions/drm-copilot/resources/customizations/.github/agents/python-atomic-executor.agent.md` | 3 | ### 2.2 Validate plan format (must be executable) | B10 | present |
| `extensions/drm-copilot/resources/customizations/.github/agents/python-atomic-executor.agent.md` | 5 | ### 7.3 Gate requirements (required) | B10 | present |
| `extensions/drm-copilot/resources/customizations/.github/agents/python-atomic-planning.agent.md` | 1 | ## 2. Output Format (Mandatory) | B10 | present |
| `extensions/drm-copilot/resources/customizations/.github/agents/python-atomic-planning.agent.md` | 2 | ### 2.5.0 Mode source precedence and fail-closed routing (Mandatory) | B10 | present |
| `extensions/drm-copilot/resources/customizations/.github/agents/python-execution-only-typed.agent.md` | 1 | (top of file) | B10 | present |
| `extensions/drm-copilot/resources/customizations/.github/agents/python-execution-only-typed.agent.md` | 2 | ## 4) Quality gates (hard stop) | B10 | present |
| `extensions/drm-copilot/resources/customizations/.github/agents/python-execution-only-typed.agent.md` | 3 | ## Phase A — Static baseline capture (read-only) | B10 | present |
| `extensions/drm-copilot/resources/customizations/.github/agents/python-execution-only-typed.agent.md` | 5 | ## Phase C — Final QA gate | B10 | present |
| `extensions/drm-copilot/resources/customizations/.github/agents/python-execution-only-typed.agent.md` | 6 | # Reporting requirements (every response) | B10 | present |
| `extensions/drm-copilot/resources/customizations/.github/agents/python-orchestrator.agent.md` | 1 | (top of file) | B10 | present |
| `extensions/drm-copilot/resources/customizations/.github/agents/python-orchestrator.agent.md` | 2 | (top of file) | B10 | present |
| `extensions/drm-copilot/resources/customizations/.github/agents/python-orchestrator.agent.md` | 3 | ### Step S6 — Delegate constrained small-path development | B10 | present |
| `extensions/drm-copilot/resources/customizations/.github/agents/python-orchestrator.agent.md` | 4 | ### Step 4 — Build atomic plan and preflight all clear | B10 | present |
| `extensions/drm-copilot/resources/customizations/.github/agents/python-orchestrator.agent.md` | 5 | ### Step 5 — Execute approved atomic plan | B10 | present |
| `extensions/drm-copilot/resources/customizations/.github/agents/python-typed-engineer.agent.md` | 1 | (top of file) | B10 | present |
| `extensions/drm-copilot/resources/customizations/.github/agents/python-typed-engineer.agent.md` | 2 | (top of file) | B10 | present |
| `extensions/drm-copilot/resources/customizations/.github/agents/python-typed-engineer.agent.md` | 3 | ## Mode-aware planning handoff contract (Mandatory) | B10 | present |
| `extensions/drm-copilot/resources/customizations/.github/agents/python-typed-engineer.agent.md` | 4 | ## 4) Quality gates (hard stop) | B10 | present |
| `extensions/drm-copilot/resources/customizations/.github/agents/python-typed-engineer.agent.md` | 5 | ## Phase A — Static baseline capture (read-only) | B10 | present |
| `extensions/drm-copilot/resources/customizations/.github/agents/python-typed-engineer.agent.md` | 7 | ## Phase D — Final QA gate | B10 | present |
| `extensions/drm-copilot/resources/customizations/.github/agents/python-typed-engineer.agent.md` | 8 | # Reporting requirements (every response) | B10 | present |
| `extensions/drm-copilot/resources/customizations/.github/agents/typescript-engineer.agent.md` | 2 | ## Role and objective | B10 | present |
| `extensions/drm-copilot/resources/customizations/.github/agents/typescript-engineer.agent.md` | 3 | ## TDD execution model | B10 | present |
| `extensions/drm-copilot/resources/customizations/.github/codex/execute-hard-lock.prompt.md` | 1 | (top of file) | B10 | present |
| `extensions/drm-copilot/resources/customizations/.github/codex/execute-hard-lock.prompt.md` | 2 | (top of file) | B10 | present |
| `extensions/drm-copilot/resources/customizations/.github/prompts/execute-hard-lock.prompt.md` | 1 | (top of file) | B10 | present |
| `extensions/drm-copilot/resources/customizations/.github/prompts/execute-hard-lock.prompt.md` | 2 | (top of file) | B10 | present |
| `extensions/drm-copilot/resources/customizations/.github/prompts/review-feature.prompt.md` | 1 | ### Required deliverables | B7 | present |
| `extensions/drm-copilot/resources/customizations/.github/skills/atomic-plan-contract/SKILL.md` | 2 | ## Short-Path Minimal Plan Contract | B1 | present |
| `extensions/drm-copilot/resources/customizations/.github/skills/atomic-plan-contract/SKILL.md` | 4 | ## Phase 0 Requirements | B1 | present |
| `extensions/drm-copilot/resources/customizations/.github/skills/atomic-plan-contract/SKILL.md` | 5 | ## Coverage Evidence Contract (Mandatory when policy requires coverage) | B2 | present |
| `extensions/drm-copilot/resources/customizations/.github/skills/atomic-plan-contract/SKILL.md` | 6 | ## Mode-Specific Mandatory Plan Gates | B3 | present |
| `extensions/drm-copilot/resources/customizations/.github/skills/execution-environment/SKILL.md` | 5 | ## Test Runtime | B4 | present |
| `extensions/drm-copilot/resources/customizations/.github/skills/feature-review-workflow/SKILL.md` | 3 | ## Ordered Procedure | B7 | present |
| `extensions/drm-copilot/resources/feature-templates/bug/plan.yyyy-MM-ddTHH-mm.md` | 1 | # <bug-name> (Plan) | B11 | present |
| `extensions/drm-copilot/resources/feature-templates/bug/plan.yyyy-MM-ddTHH-mm.md` | 2 | ## Pre-Mortem | B11 | present |
| `extensions/drm-copilot/resources/feature-templates/feature/plan.yyyy-MM-ddTHH-mm.md` | 1 | ## Implementation Plan (Atomic Tasks) | B11 | present |
| `extensions/drm-copilot/resources/feature-templates/feature/plan.yyyy-MM-ddTHH-mm.md` | 2 | ## Test Plan | B11 | present |
| `extensions/drm-copilot/resources/feature-templates/refactor/plan.yyyy-MM-ddTHH-mm.md` | 1 | ## Strategy | B11 | present |
| `extensions/drm-copilot/resources/feature-templates/refactor/plan.yyyy-MM-ddTHH-mm.md` | 2 | ## Test Plan | B11 | present |
| `extensions/drm-copilot/resources/templates/policy_audit/AGENTS.md` | 1 | ## Behavior: How to run a Policy Audit | B6 | present |
| `extensions/drm-copilot/resources/templates/policy_audit/AGENTS.md` | 2 | ## Behavior: How to run a Policy Audit | B6 | present |
| `extensions/drm-copilot/resources/templates/policy_audit/AGENTS.md` | 3 | ## Behavior: How to run a Policy Audit | B6 | present |
| `extensions/drm-copilot/resources/templates/policy_audit/AGENTS.md` | 4 | ## Behavior: How to run a Policy Audit | B6 | present |
| `extensions/drm-copilot/resources/templates/policy_audit/policy-audit.yyyy-MM-ddTHH-mm.md` | 2 | ### Coverage Evidence Checklist | B5 | present |
| `extensions/drm-copilot/resources/templates/policy_audit/policy-audit.yyyy-MM-ddTHH-mm.md` | 3 | ### 1.2 Coverage and Scenarios | B5 | present |
| `extensions/drm-copilot/resources/templates/policy_audit/policy-audit.yyyy-MM-ddTHH-mm.md` | 4 | ### 1.2.1 Per-Language Coverage Comparison | B5 | present |
| `extensions/drm-copilot/resources/templates/policy_audit/policy-audit.yyyy-MM-ddTHH-mm.md` | 11 | [Provide a brief summary of overall compliance status and any major findings.] | B5 | present |
| `tests/scripts/dev_tools/test_codex_orchestration_contracts.py` | 1 | (top of file) | TEST (## Test Dispositions) | present |

## git apply -R --check (first lines)

- error: patch failed: extensions/drm-copilot/resources/feature-templates/feature/plan.yyyy-MM-ddTHH-mm.md:23
- error: extensions/drm-copilot/resources/feature-templates/feature/plan.yyyy-MM-ddTHH-mm.md: patch does not apply
- error: patch failed: extensions/drm-copilot/resources/customizations/.github/skills/feature-review-workflow/SKILL.md:132
- error: extensions/drm-copilot/resources/customizations/.github/skills/feature-review-workflow/SKILL.md: patch does not apply
- error: patch failed: extensions/drm-copilot/resources/customizations/.github/skills/execution-environment/SKILL.md:106
- error: extensions/drm-copilot/resources/customizations/.github/skills/execution-environment/SKILL.md: patch does not apply
- error: patch failed: extensions/drm-copilot/resources/customizations/.github/skills/atomic-plan-contract/SKILL.md:32
- error: extensions/drm-copilot/resources/customizations/.github/skills/atomic-plan-contract/SKILL.md: patch does not apply
- error: patch failed: extensions/drm-copilot/resources/customizations/.github/prompts/execute-hard-lock.prompt.md:16
- error: extensions/drm-copilot/resources/customizations/.github/prompts/execute-hard-lock.prompt.md: patch does not apply
- error: patch failed: extensions/drm-copilot/resources/customizations/.github/codex/execute-hard-lock.prompt.md:16
- error: extensions/drm-copilot/resources/customizations/.github/codex/execute-hard-lock.prompt.md: patch does not apply
- error: patch failed: extensions/drm-copilot/resources/customizations/.github/agents/python-atomic-executor.agent.md:143
- error: extensions/drm-copilot/resources/customizations/.github/agents/python-atomic-executor.agent.md: patch does not apply
- error: patch failed: extensions/drm-copilot/resources/customizations/.github/agents/powershell-atomic-executor.agent.md:143
- error: extensions/drm-copilot/resources/customizations/.github/agents/powershell-atomic-executor.agent.md: patch does not apply
- error: patch failed: extensions/drm-copilot/resources/customizations/.github/agents/csharp-atomic-executor.agent.md:143
- error: extensions/drm-copilot/resources/customizations/.github/agents/csharp-atomic-executor.agent.md: patch does not apply
- error: patch failed: extensions/drm-copilot/resources/customizations/.github/agents/atomic_executor.agent.md:148
- error: extensions/drm-copilot/resources/customizations/.github/agents/atomic_executor.agent.md: patch does not apply
- error: patch failed: extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/atomic-planner.toml:58
- error: extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/atomic-planner.toml: patch does not apply
- error: patch failed: extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/atomic-planner-c4.toml:58
- error: extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/atomic-planner-c4.toml: patch does not apply
- error: patch failed: extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/atomic-planner-c3.toml:58
- error: extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/atomic-planner-c3.toml: patch does not apply
- error: patch failed: extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/atomic-planner-c3-elevated.toml:58
- error: extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/atomic-planner-c3-elevated.toml: patch does not apply
- error: patch failed: extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/atomic-planner-c2.toml:58
- error: extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/atomic-planner-c2.toml: patch does not apply
- error: patch failed: extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/atomic-planner-c1.toml:58
- error: extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/atomic-planner-c1.toml: patch does not apply
- error: patch failed: extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/execution-environment/SKILL.md:106
- error: extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/execution-environment/SKILL.md: patch does not apply
- error: patch failed: extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/atomic-plan-contract/SKILL.md:32
- error: extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/atomic-plan-contract/SKILL.md: patch does not apply
- error: patch failed: extensions/drm-copilot/resources/claude-customizations/.claude/skills/remediation-handoff-atomic-planner/SKILL.md:98
- error: extensions/drm-copilot/resources/claude-customizations/.claude/skills/remediation-handoff-atomic-planner/SKILL.md: patch does not apply
- error: patch failed: extensions/drm-copilot/resources/claude-customizations/.claude/skills/execution-environment/SKILL.md:106
- error: extensions/drm-copilot/resources/claude-customizations/.claude/skills/execution-environment/SKILL.md: patch does not apply
