Timestamp: 2026-10-17T18:32:44.841395+00:00
Command: compare measured baseline/final coverage and physical files against merge base a6b22dd056b84319c9a486e24fb74bd87dfb298b
EXIT_CODE: 0
Output Summary: PASS: numeric coverage, changed-line comparison and applicable physical-size gates.

| Measured population | Baseline | Final | Delta |
|---|---|---|---|
| Python repository line | 16798/17849 (94.1117%) | 16798/17849 (94.1117%) | +0.0000 pp |
| Python repository branch | 5723/6446 (88.7837%) | 5723/6446 (88.7837%) | +0.0000 pp |
| scripts/dev_tools/resolve_codex_deployment.py line | 83/83 (100.0000%) | 83/83 (100.0000%) | +0.0000 pp |
| scripts/dev_tools/resolve_codex_deployment.py branch | 18/18 (100.0000%) | 18/18 (100.0000%) | +0.0000 pp |
| scripts/dev_tools/generate_codex_agent_variants.py line | 121/128 (94.5312%) | 121/128 (94.5312%) | +0.0000 pp |
| scripts/dev_tools/generate_codex_agent_variants.py branch | 41/46 (89.1304%) | 41/46 (89.1304%) | +0.0000 pp |
| TypeScript total lines | 51900/53279 (97.4117%) | 51900/53279 (97.4117%) | +0.0000 pp |
| TypeScript total branches | 7747/8361 (92.6564%) | 7748/8362 (92.6573%) | +0.0009 pp |
| TypeScript orchestrator-state-codex-model-routing.ts lines | 466/487 (95.6879%) | 466/487 (95.6879%) | +0.0000 pp |
| TypeScript orchestrator-state-codex-model-routing.ts branches | 112/119 (94.1176%) | 113/120 (94.1667%) | +0.0490 pp |
| PowerShell repository line | 17644/19130 (92.2321%) | 17730/19142 (92.6236%) | +0.3915 pp |
| .claude/lib/codex-routing/CodexDeployment.psm1 line | 68/68 (100.0000%) | 68/68 (100.0000%) | +0.0000 pp |
| .codex/hooks/record-subagent-routing-attestation.ps1 line | 103/192 (53.6458%) | 189/204 (92.6471%) | +39.0012 pp |
| extensions/drm-copilot/resources/lib/codex-routing/CodexDeployment.psm1 line | 68/68 (100.0000%) | 68/68 (100.0000%) | +0.0000 pp |
| extensions/drm-copilot/resources/claude-customizations/.claude/lib/codex-routing/CodexDeployment.psm1 line | 68/68 (100.0000%) | 68/68 (100.0000%) | +0.0000 pp |
| extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/record-subagent-routing-attestation.ps1 line | 103/192 (53.6458%) | 189/204 (92.6471%) | +39.0012 pp |
| New command method (source) line | N/A: new method | 36/40 (90.0000%) | N/A |
| New command method (bundle) line | N/A: new method | 36/40 (90.0000%) | N/A |

Changed executable lines use non-equal line ranges from SequenceMatcher between merge-base source and current source. Counts include only instrumented lines; prose/blank lines do not count. Preserved covered lines are mapped through equal ranges. Zero preserved losses and nondecreasing coverage of changed executable ranges establish no changed-line regression. Bundled ranges use their independently instrumented actual files.

| Production file | Baseline changed lines | Final changed lines | Preserved covered-line losses |
|---|---|---|---|
| scripts/dev_tools/resolve_codex_deployment.py | N/A: no changed executable baseline lines | N/A: prose/data-only delta | 0 |
| scripts/dev_tools/generate_codex_agent_variants.py | N/A: no changed executable baseline lines | N/A: prose/data-only delta | 0 |
| extensions/drm-copilot/src/lib/validate/orchestrator-state-codex-model-routing.ts | 7/7 (100.0000%) | 7/7 (100.0000%) | 0 |
| .claude/lib/codex-routing/CodexDeployment.psm1 | 7/7 (100.0000%) | 7/7 (100.0000%) | 0 |
| .codex/hooks/record-subagent-routing-attestation.ps1 | 1/41 (2.4390%) | 41/53 (77.3585%) | 0 |
| extensions/drm-copilot/resources/lib/codex-routing/CodexDeployment.psm1 | 7/7 (100.0000%) | 7/7 (100.0000%) | 0 |
| extensions/drm-copilot/resources/claude-customizations/.claude/lib/codex-routing/CodexDeployment.psm1 | 7/7 (100.0000%) | 7/7 (100.0000%) | 0 |
| extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/record-subagent-routing-attestation.ps1 | 1/41 (2.4390%) | 41/53 (77.3585%) | 0 |

All runtime coverage populations exclude tests. No new production module/class was added. The new command method is measured independently in source and actual bundle; defaulted parameters extend existing methods.

| Changed path | Physical lines | Size gate |
|---|---|---|
| .claude/lib/codex-routing/CodexDeployment.psm1 | 315 | PASS |
| .codex/agents/atomic-executor-c1.toml | 168 | N/A: declarative configuration/data |
| .codex/agents/atomic-executor-c2.toml | 168 | N/A: declarative configuration/data |
| .codex/agents/atomic-executor-c3-elevated.toml | 168 | N/A: declarative configuration/data |
| .codex/agents/atomic-executor-c3.toml | 168 | N/A: declarative configuration/data |
| .codex/agents/atomic-executor-c4.toml | 168 | N/A: declarative configuration/data |
| .codex/agents/atomic-executor.toml | 168 | N/A: declarative configuration/data |
| .codex/agents/atomic-planner-c1.toml | 108 | N/A: declarative configuration/data |
| .codex/agents/atomic-planner-c2.toml | 108 | N/A: declarative configuration/data |
| .codex/agents/atomic-planner-c3-elevated.toml | 108 | N/A: declarative configuration/data |
| .codex/agents/atomic-planner-c3.toml | 108 | N/A: declarative configuration/data |
| .codex/agents/atomic-planner-c4.toml | 108 | N/A: declarative configuration/data |
| .codex/agents/atomic-planner.toml | 108 | N/A: declarative configuration/data |
| .codex/agents/commit-steward-c1.toml | 22 | N/A: declarative configuration/data |
| .codex/agents/commit-steward-c2.toml | 22 | N/A: declarative configuration/data |
| .codex/agents/commit-steward-c3-elevated.toml | 22 | N/A: declarative configuration/data |
| .codex/agents/commit-steward-c3.toml | 22 | N/A: declarative configuration/data |
| .codex/agents/commit-steward-c4.toml | 22 | N/A: declarative configuration/data |
| .codex/agents/commit-steward.toml | 22 | N/A: declarative configuration/data |
| .codex/agents/csharp-typed-engineer-c1.toml | 99 | N/A: declarative configuration/data |
| .codex/agents/csharp-typed-engineer-c2.toml | 99 | N/A: declarative configuration/data |
| .codex/agents/csharp-typed-engineer-c3-elevated.toml | 99 | N/A: declarative configuration/data |
| .codex/agents/csharp-typed-engineer-c3.toml | 99 | N/A: declarative configuration/data |
| .codex/agents/csharp-typed-engineer-c4.toml | 99 | N/A: declarative configuration/data |
| .codex/agents/csharp-typed-engineer.toml | 99 | N/A: declarative configuration/data |
| .codex/agents/epic-orchestrator.toml | 99 | N/A: declarative configuration/data |
| .codex/agents/epic-planner.toml | 97 | N/A: declarative configuration/data |
| .codex/agents/feature-reviewer-c1.toml | 63 | N/A: declarative configuration/data |
| .codex/agents/feature-reviewer-c2.toml | 63 | N/A: declarative configuration/data |
| .codex/agents/feature-reviewer-c3-elevated.toml | 63 | N/A: declarative configuration/data |
| .codex/agents/feature-reviewer-c3.toml | 63 | N/A: declarative configuration/data |
| .codex/agents/feature-reviewer-c4.toml | 63 | N/A: declarative configuration/data |
| .codex/agents/feature-reviewer.toml | 63 | N/A: declarative configuration/data |
| .codex/agents/orchestrator-c1.toml | 214 | N/A: declarative configuration/data |
| .codex/agents/orchestrator-c2.toml | 214 | N/A: declarative configuration/data |
| .codex/agents/orchestrator-c3-elevated.toml | 214 | N/A: declarative configuration/data |
| .codex/agents/orchestrator-c3.toml | 214 | N/A: declarative configuration/data |
| .codex/agents/orchestrator-c4.toml | 214 | N/A: declarative configuration/data |
| .codex/agents/orchestrator.toml | 214 | N/A: declarative configuration/data |
| .codex/agents/powershell-typed-engineer-c1.toml | 109 | N/A: declarative configuration/data |
| .codex/agents/powershell-typed-engineer-c2.toml | 109 | N/A: declarative configuration/data |
| .codex/agents/powershell-typed-engineer-c3-elevated.toml | 109 | N/A: declarative configuration/data |
| .codex/agents/powershell-typed-engineer-c3.toml | 109 | N/A: declarative configuration/data |
| .codex/agents/powershell-typed-engineer-c4.toml | 109 | N/A: declarative configuration/data |
| .codex/agents/powershell-typed-engineer.toml | 109 | N/A: declarative configuration/data |
| .codex/agents/pr-author-c1.toml | 28 | N/A: declarative configuration/data |
| .codex/agents/pr-author-c2.toml | 28 | N/A: declarative configuration/data |
| .codex/agents/pr-author-c3-elevated.toml | 28 | N/A: declarative configuration/data |
| .codex/agents/pr-author-c3.toml | 28 | N/A: declarative configuration/data |
| .codex/agents/pr-author-c4.toml | 28 | N/A: declarative configuration/data |
| .codex/agents/pr-author.toml | 28 | N/A: declarative configuration/data |
| .codex/agents/prd-feature-c1.toml | 55 | N/A: declarative configuration/data |
| .codex/agents/prd-feature-c2.toml | 55 | N/A: declarative configuration/data |
| .codex/agents/prd-feature-c3-elevated.toml | 55 | N/A: declarative configuration/data |
| .codex/agents/prd-feature-c3.toml | 55 | N/A: declarative configuration/data |
| .codex/agents/prd-feature-c4.toml | 55 | N/A: declarative configuration/data |
| .codex/agents/prd-feature.toml | 55 | N/A: declarative configuration/data |
| .codex/agents/python-typed-engineer-c1.toml | 102 | N/A: declarative configuration/data |
| .codex/agents/python-typed-engineer-c2.toml | 102 | N/A: declarative configuration/data |
| .codex/agents/python-typed-engineer-c3-elevated.toml | 102 | N/A: declarative configuration/data |
| .codex/agents/python-typed-engineer-c3.toml | 102 | N/A: declarative configuration/data |
| .codex/agents/python-typed-engineer-c4.toml | 102 | N/A: declarative configuration/data |
| .codex/agents/python-typed-engineer.toml | 102 | N/A: declarative configuration/data |
| .codex/agents/task-researcher-c1.toml | 111 | N/A: declarative configuration/data |
| .codex/agents/task-researcher-c2.toml | 111 | N/A: declarative configuration/data |
| .codex/agents/task-researcher-c3-elevated.toml | 111 | N/A: declarative configuration/data |
| .codex/agents/task-researcher-c3.toml | 111 | N/A: declarative configuration/data |
| .codex/agents/task-researcher-c4.toml | 111 | N/A: declarative configuration/data |
| .codex/agents/task-researcher.toml | 111 | N/A: declarative configuration/data |
| .codex/agents/typescript-engineer-c1.toml | 50 | N/A: declarative configuration/data |
| .codex/agents/typescript-engineer-c2.toml | 50 | N/A: declarative configuration/data |
| .codex/agents/typescript-engineer-c3-elevated.toml | 50 | N/A: declarative configuration/data |
| .codex/agents/typescript-engineer-c3.toml | 50 | N/A: declarative configuration/data |
| .codex/agents/typescript-engineer-c4.toml | 50 | N/A: declarative configuration/data |
| .codex/agents/typescript-engineer.toml | 50 | N/A: declarative configuration/data |
| .codex/hooks/record-subagent-routing-attestation.ps1 | 426 | PASS |
| config/orchestration-routing.json | 356 | N/A: declarative configuration/data |
| extensions/drm-copilot/resources/claude-customizations/.claude/lib/codex-routing/CodexDeployment.psm1 | 315 | PASS |
| extensions/drm-copilot/resources/claude-customizations/config/orchestration-routing.json | 356 | N/A: declarative configuration/data |
| extensions/drm-copilot/resources/codex-and-agents-customizations/.codex-variants/csharp-legacy/agents/csharp-typed-engineer.toml | 99 | N/A: declarative configuration/data |
| extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/atomic-executor-c1.toml | 168 | N/A: declarative configuration/data |
| extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/atomic-executor-c2.toml | 168 | N/A: declarative configuration/data |
| extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/atomic-executor-c3-elevated.toml | 168 | N/A: declarative configuration/data |
| extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/atomic-executor-c3.toml | 168 | N/A: declarative configuration/data |
| extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/atomic-executor-c4.toml | 168 | N/A: declarative configuration/data |
| extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/atomic-executor.toml | 168 | N/A: declarative configuration/data |
| extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/atomic-planner-c1.toml | 108 | N/A: declarative configuration/data |
| extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/atomic-planner-c2.toml | 108 | N/A: declarative configuration/data |
| extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/atomic-planner-c3-elevated.toml | 108 | N/A: declarative configuration/data |
| extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/atomic-planner-c3.toml | 108 | N/A: declarative configuration/data |
| extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/atomic-planner-c4.toml | 108 | N/A: declarative configuration/data |
| extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/atomic-planner.toml | 108 | N/A: declarative configuration/data |
| extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/commit-steward-c1.toml | 22 | N/A: declarative configuration/data |
| extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/commit-steward-c2.toml | 22 | N/A: declarative configuration/data |
| extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/commit-steward-c3-elevated.toml | 22 | N/A: declarative configuration/data |
| extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/commit-steward-c3.toml | 22 | N/A: declarative configuration/data |
| extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/commit-steward-c4.toml | 22 | N/A: declarative configuration/data |
| extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/commit-steward.toml | 22 | N/A: declarative configuration/data |
| extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/csharp-typed-engineer-c1.toml | 99 | N/A: declarative configuration/data |
| extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/csharp-typed-engineer-c2.toml | 99 | N/A: declarative configuration/data |
| extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/csharp-typed-engineer-c3-elevated.toml | 99 | N/A: declarative configuration/data |
| extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/csharp-typed-engineer-c3.toml | 99 | N/A: declarative configuration/data |
| extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/csharp-typed-engineer-c4.toml | 99 | N/A: declarative configuration/data |
| extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/csharp-typed-engineer.toml | 99 | N/A: declarative configuration/data |
| extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/epic-orchestrator.toml | 99 | N/A: declarative configuration/data |
| extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/epic-planner.toml | 97 | N/A: declarative configuration/data |
| extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/feature-reviewer-c1.toml | 63 | N/A: declarative configuration/data |
| extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/feature-reviewer-c2.toml | 63 | N/A: declarative configuration/data |
| extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/feature-reviewer-c3-elevated.toml | 63 | N/A: declarative configuration/data |
| extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/feature-reviewer-c3.toml | 63 | N/A: declarative configuration/data |
| extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/feature-reviewer-c4.toml | 63 | N/A: declarative configuration/data |
| extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/feature-reviewer.toml | 63 | N/A: declarative configuration/data |
| extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/orchestrator-c1.toml | 214 | N/A: declarative configuration/data |
| extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/orchestrator-c2.toml | 214 | N/A: declarative configuration/data |
| extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/orchestrator-c3-elevated.toml | 214 | N/A: declarative configuration/data |
| extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/orchestrator-c3.toml | 214 | N/A: declarative configuration/data |
| extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/orchestrator-c4.toml | 214 | N/A: declarative configuration/data |
| extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/orchestrator.toml | 214 | N/A: declarative configuration/data |
| extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/powershell-typed-engineer-c1.toml | 109 | N/A: declarative configuration/data |
| extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/powershell-typed-engineer-c2.toml | 109 | N/A: declarative configuration/data |
| extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/powershell-typed-engineer-c3-elevated.toml | 109 | N/A: declarative configuration/data |
| extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/powershell-typed-engineer-c3.toml | 109 | N/A: declarative configuration/data |
| extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/powershell-typed-engineer-c4.toml | 109 | N/A: declarative configuration/data |
| extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/powershell-typed-engineer.toml | 109 | N/A: declarative configuration/data |
| extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/pr-author-c1.toml | 28 | N/A: declarative configuration/data |
| extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/pr-author-c2.toml | 28 | N/A: declarative configuration/data |
| extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/pr-author-c3-elevated.toml | 28 | N/A: declarative configuration/data |
| extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/pr-author-c3.toml | 28 | N/A: declarative configuration/data |
| extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/pr-author-c4.toml | 28 | N/A: declarative configuration/data |
| extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/pr-author.toml | 28 | N/A: declarative configuration/data |
| extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/prd-feature-c1.toml | 55 | N/A: declarative configuration/data |
| extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/prd-feature-c2.toml | 55 | N/A: declarative configuration/data |
| extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/prd-feature-c3-elevated.toml | 55 | N/A: declarative configuration/data |
| extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/prd-feature-c3.toml | 55 | N/A: declarative configuration/data |
| extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/prd-feature-c4.toml | 55 | N/A: declarative configuration/data |
| extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/prd-feature.toml | 55 | N/A: declarative configuration/data |
| extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/python-typed-engineer-c1.toml | 102 | N/A: declarative configuration/data |
| extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/python-typed-engineer-c2.toml | 102 | N/A: declarative configuration/data |
| extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/python-typed-engineer-c3-elevated.toml | 102 | N/A: declarative configuration/data |
| extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/python-typed-engineer-c3.toml | 102 | N/A: declarative configuration/data |
| extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/python-typed-engineer-c4.toml | 102 | N/A: declarative configuration/data |
| extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/python-typed-engineer.toml | 102 | N/A: declarative configuration/data |
| extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/task-researcher-c1.toml | 111 | N/A: declarative configuration/data |
| extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/task-researcher-c2.toml | 111 | N/A: declarative configuration/data |
| extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/task-researcher-c3-elevated.toml | 111 | N/A: declarative configuration/data |
| extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/task-researcher-c3.toml | 111 | N/A: declarative configuration/data |
| extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/task-researcher-c4.toml | 111 | N/A: declarative configuration/data |
| extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/task-researcher.toml | 111 | N/A: declarative configuration/data |
| extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/typescript-engineer-c1.toml | 50 | N/A: declarative configuration/data |
| extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/typescript-engineer-c2.toml | 50 | N/A: declarative configuration/data |
| extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/typescript-engineer-c3-elevated.toml | 50 | N/A: declarative configuration/data |
| extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/typescript-engineer-c3.toml | 50 | N/A: declarative configuration/data |
| extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/typescript-engineer-c4.toml | 50 | N/A: declarative configuration/data |
| extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/typescript-engineer.toml | 50 | N/A: declarative configuration/data |
| extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/record-subagent-routing-attestation.ps1 | 426 | PASS |
| extensions/drm-copilot/resources/config/orchestration-routing.json | 356 | N/A: declarative configuration/data |
| extensions/drm-copilot/resources/lib/codex-routing/CodexDeployment.psm1 | 315 | PASS |
| extensions/drm-copilot/src/lib/validate/orchestrator-state-codex-model-routing.ts | 487 | PASS |
| extensions/drm-copilot/test/lib/push-down/codex-bundle-publish.integration.test.ts | 123 | PASS |
| extensions/drm-copilot/test/lib/validate/codex-deployment.test.ts | 196 | PASS |
| extensions/drm-copilot/test/lib/validate/epic-planner-launch-evidence-test-support.ts | 198 | PASS |
| extensions/drm-copilot/test/lib/validate/epic-planner-launch-evidence.test.ts | 263 | PASS |
| extensions/drm-copilot/test/lib/validate/epic-planner-readiness-integrity.test.ts | 495 | PASS |
| extensions/drm-copilot/test/lib/validate/epic-planner-state-core.test.ts | 490 | PASS |
| extensions/drm-copilot/test/lib/validate/epic-planner-state-feature-receipts.test.ts | 199 | PASS |
| extensions/drm-copilot/test/lib/validate/epic-planner-state-launch-binding.test.ts | 343 | PASS |
| extensions/drm-copilot/test/lib/validate/orchestrator-state-codex-model-routing.test.ts | 413 | PASS |
| extensions/drm-copilot/test/lib/validate/orchestrator-state-codex-topology.test.ts | 301 | PASS |
| scripts/dev_tools/generate_codex_agent_variants.py | 295 | PASS |
| scripts/dev_tools/resolve_codex_deployment.py | 255 | PASS |
| tests/fixtures/codex_routing/deployment.json | 140 | N/A: declarative configuration/data |
| tests/scripts/claude-lib/codex-routing/CodexDeployment.Parity.Tests.ps1 | 286 | PASS |
| tests/scripts/claude-lib/orchestrator-state/OrchestratorStateCodexModelReceipts.Tests.ps1 | 270 | PASS |
| tests/scripts/codex-hooks/codex-bundle-hook-probe.Tests.ps1 | 202 | PASS |
| tests/scripts/codex-hooks/codex-epic-runtime-contracts.Tests.ps1 | 205 | PASS |
| tests/scripts/codex-hooks/codex-pretooluse-integration.Tests.ps1 | 268 | PASS |
| tests/scripts/codex-hooks/codex-pretooluse-transport.Tests.ps1 | 450 | PASS |
| tests/scripts/codex-hooks/codex-worktree-binding-hook.Tests.ps1 | 353 | PASS |
| tests/scripts/codex-hooks/epic-child-launch-attestation.Tests.ps1 | 166 | PASS |
| tests/scripts/codex-hooks/epic-child-launch-hardening.Tests.ps1 | 469 | PASS |
| tests/scripts/codex-hooks/epic-child-worktree-launcher.Tests.ps1 | 495 | PASS |
| tests/scripts/codex-hooks/epic-provenance.Tests.ps1 | 402 | PASS |
| tests/scripts/codex-hooks/epic-wave-launch-binding.Tests.ps1 | 160 | PASS |
| tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1 | 497 | PASS |
| tests/scripts/codex-hooks/model-profile-attestation.Tests.ps1 | 241 | PASS |
| tests/scripts/codex-hooks/subagent-attestation-command.Tests.ps1 | 136 | PASS |
| tests/scripts/codex-hooks/subagent-attestation-persistence.Tests.ps1 | 226 | PASS |
| tests/scripts/dev_tools/epic_planner_launch_evidence_test_support.py | 187 | PASS |
| tests/scripts/dev_tools/test_codex_full_migration_inventory.py | 155 | PASS |
| tests/scripts/dev_tools/test_epic_planner_launch_evidence.py | 309 | PASS |
| tests/scripts/dev_tools/test_generate_codex_agent_variants.py | 233 | PASS |
| tests/scripts/dev_tools/test_resolve_codex_deployment.py | 254 | PASS |
| tests/scripts/dev_tools/test_validate_epic_planner_state.py | 429 | PASS |
| tests/scripts/dev_tools/test_validate_orchestrator_state_codex_model_routing.py | 227 | PASS |
| tests/scripts/dev_tools/test_validate_orchestrator_state_codex_topology.py | 274 | PASS |

Source measurements: evidence/baseline/{python,typescript,powershell}-test.*.md and evidence/qa-gates/{python,typescript,powershell}-test.*.md. Actual bundled measurements: evidence/{baseline,qa-gates}/powershell-bundle-coverage.*.md. Raw numeric reports: SCRATCH/issue-977-{baseline,qa-gates}-*.json/xml; no source percentages substitute for bundle measurement.
