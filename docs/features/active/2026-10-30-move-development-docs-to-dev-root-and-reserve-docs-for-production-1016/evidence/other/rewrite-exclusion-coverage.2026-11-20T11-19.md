# Rewrite-exclusion coverage and generator closure ([P1-T4])

Timestamp: 2026-11-20T11-19
Command: git -C <worktree> ls-files; git -C <worktree> grep -l -E 'docs.{1,8}(features|research|engineering|discovery)'; node SCRATCH/issue-1016-p1t4.cjs <FRESH_DRY_RUN dev-docs-migration-dry-run.2026-11-20T11-03.json> <DECISIONS folder-rename-decisions.2026-11-20T09-48.json> <ls-files list> SCRATCH/issue-1016-child2-files.txt config/harness-parity-matrix.json; node key comparison of folder-rename-decisions.2026-11-20T07-55.json (named by decision-file-check.2026-11-20T08-00.md) with DECISIONS
EXIT_CODE: 0
Output Summary: (a) Members 1 to 8, 10, 11 and 12 enumerated from the tree; every file is matched by a DECISIONS glob or a tool built-in except docs/engineering/claude-code-architecture.md (member 8, LEDGER_PINNED through the 0005 block), which lies inside a moved tree under the links-only scope with 0 link rewrites in FRESH_DRY_RUN, so the apply leaves its bytes unchanged (recorded below as covered by the scope decision; the [P1-T6] rehearsal diff confirms it). Package paths re-derived with git ls-files packages/discovery-runtime (member 7). (b) DECISIONS differs from folder-rename-decisions.2026-11-20T07-55.json in rewrite_exclusions only (71 to 339 globs); version, dry_run_report, source_digest, global_decisions and decisions EQUAL. (c) 187 GENERATOR_INVENTORY families (harness families from the generated matrix entries, Codex variant families); 23 families have an excluded member, all CLOSED (0 family members holding a MAPPING_PREFIXES occurrence left unexcluded). (d) 21 families with no excluded member have rewrite-candidate outputs; each has at least one rewrite-candidate source (0 without). The discovery runtime family (member 7, RESOURCE_ROOTS inputs under docs/discovery/templates) is handled by [P3-T7]. No stop.

## Decision recorded

docs/engineering/claude-code-architecture.md is treated as covered: the tool rewrites a file inside a moved tree only through link recomputation under in_tree_rewrite_scope links-only, FRESH_DRY_RUN lists the file with links 0, and its 0005 region holds a template placeholder (docs/features/active/<feature>/plan.md) that the Ledger Decision keeps byte-identical. The intent of member 8 (the region stays byte-identical) therefore holds without a glob. Verification: the [P1-T6] rehearsal diff must show the file as an exact rename (R100); otherwise [P1-T6] lists its glob in an exclusion-amendment stop. Recommended-option decision under OD-1.

## Coverage and closure tables

| Member | Files | Matched | Unmatched |
| --- | --- | --- | --- |
| 1 tests/fixtures | 1865 | 1865 | none |
| 2 evidence and ledger | 30005 | 30005 | none |
| 3 mapping records | 10 | 10 | none |
| 4 fallback-support | 300 | 300 | none |
| 5 A6 policy Stay | 120 | 120 | none |
| 6 brief copies and workflows README | 5 | 5 | none |
| 7 discovery package | 189 | 189 | none |
| 8 ledger, frozen surfaces, LEDGER_PINNED | 31 | 30 | docs/engineering/claude-code-architecture.md |
| 10 HAND_EDIT_SET and A19 STAY | 45 | 45 | none |
| 11 FT_BYTE_PAIRS bundles | 4 | 4 | none |
| 12 stage A tool | 29 | 29 | none |

| Family | Kind | Result |
| --- | --- | --- |
| scripts/harness-generation/sources/agents/epic-orchestrator.json | has excluded member | CLOSED |
| scripts/harness-generation/sources/agents/epic-planner.json | no excluded member | candidate outputs: .claude/agents/epic-planner.md, extensions/drm-copilot/resources/claude-customizations/.claude/agents/epic-planner.md; candidate sources: scripts/harness-generation/sources/agents/epic-planner.md |
| scripts/harness-generation/sources/agents/epic-review.json | no excluded member | candidate outputs: .claude/agents/epic-review.md, extensions/drm-copilot/resources/claude-customizations/.claude/agents/epic-review.md, .codex/agents/epic-review.toml, extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/epic-review.toml; candidate sources: scripts/harness-generation/sources/agents/epic-review.md |
| scripts/harness-generation/sources/agents/feature-review.json | no excluded member | candidate outputs: .claude/agents/feature-review.md, extensions/drm-copilot/resources/claude-customizations/.claude/agents/feature-review.md, .codex/agents/feature-review.toml, extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/feature-review.toml; candidate sources: scripts/harness-generation/sources/agents/feature-review.json, scripts/harness-generation/sources/agents/feature-review.md |
| scripts/harness-generation/sources/agents/orchestrator.json | no excluded member | candidate outputs: .claude/agents/orchestrator.md, extensions/drm-copilot/resources/claude-customizations/.claude/agents/orchestrator.md, .codex/agents/orchestrator.toml, extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/orchestrator.toml; candidate sources: scripts/harness-generation/sources/agents/orchestrator.md |
| scripts/harness-generation/sources/agents/prd-feature.json | no excluded member | candidate outputs: .claude/agents/prd-feature.md, extensions/drm-copilot/resources/claude-customizations/.claude/agents/prd-feature.md, .codex/agents/prd-feature.toml, extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/prd-feature.toml; candidate sources: scripts/harness-generation/sources/agents/prd-feature.md |
| scripts/harness-generation/sources/agents/task-researcher.json | no excluded member | candidate outputs: .claude/agents/task-researcher.md, extensions/drm-copilot/resources/claude-customizations/.claude/agents/task-researcher.md; candidate sources: scripts/harness-generation/sources/agents/task-researcher.json, scripts/harness-generation/sources/agents/task-researcher.md |
| scripts/harness-generation/sources/rules/architecture-boundaries.json | has excluded member | CLOSED |
| scripts/harness-generation/sources/rules/bash-command-shape.json | has excluded member | CLOSED |
| scripts/harness-generation/sources/rules/benchmark-baselines.json | has excluded member | CLOSED |
| scripts/harness-generation/sources/rules/ci-workflows.json | has excluded member | CLOSED |
| scripts/harness-generation/sources/rules/csharp.json | has excluded member | CLOSED |
| scripts/harness-generation/sources/rules/general-code-change.json | has excluded member | CLOSED |
| scripts/harness-generation/sources/rules/general-unit-test.json | has excluded member | CLOSED |
| scripts/harness-generation/sources/rules/mermaid.json | has excluded member | CLOSED |
| scripts/harness-generation/sources/rules/orchestrator-state.json | has excluded member | CLOSED |
| scripts/harness-generation/sources/rules/parallel-orchestration.json | has excluded member | CLOSED |
| scripts/harness-generation/sources/rules/plan-acceptance-gates.json | has excluded member | CLOSED |
| scripts/harness-generation/sources/rules/powershell.json | has excluded member | CLOSED |
| scripts/harness-generation/sources/rules/python.json | has excluded member | CLOSED |
| scripts/harness-generation/sources/rules/python-suppressions.json | has excluded member | CLOSED |
| scripts/harness-generation/sources/rules/quality-tiers.json | has excluded member | CLOSED |
| scripts/harness-generation/sources/rules/self-explanatory-code-commenting.json | has excluded member | CLOSED |
| scripts/harness-generation/sources/rules/shell.json | has excluded member | CLOSED |
| scripts/harness-generation/sources/rules/tonality.json | has excluded member | CLOSED |
| scripts/harness-generation/sources/rules/typescript.json | has excluded member | CLOSED |
| scripts/harness-generation/sources/rules/typescript-suppressions.json | has excluded member | CLOSED |
| .agents/skills/epic-plan/SKILL.md | no excluded member | candidate outputs: extensions/drm-copilot/resources/claude-customizations/.claude/skills/epic-plan/SKILL.md; candidate sources: .agents/skills/epic-plan/SKILL.md, .claude/skills/epic-plan/SKILL.md |
| .agents/skills/execution-environment/SKILL.md | has excluded member | CLOSED |
| .agents/skills/feature-promotion-lifecycle/SKILL.md | no excluded member | candidate outputs: extensions/drm-copilot/resources/claude-customizations/.claude/skills/feature-promotion-lifecycle/SKILL.md; candidate sources: .claude/skills/feature-promotion-lifecycle/SKILL.md |
| .agents/skills/fill-feature-docs/SKILL.md | no excluded member | candidate outputs: extensions/drm-copilot/resources/claude-customizations/.claude/skills/fill-feature-docs/SKILL.md; candidate sources: .agents/skills/fill-feature-docs/SKILL.md, .claude/skills/fill-feature-docs/SKILL.md |
| .agents/skills/remediation-handoff-atomic-planner/SKILL.md | no excluded member | candidate outputs: extensions/drm-copilot/resources/claude-customizations/.claude/skills/remediation-handoff-atomic-planner/SKILL.md; candidate sources: .agents/skills/remediation-handoff-atomic-planner/SKILL.md, .claude/skills/remediation-handoff-atomic-planner/SKILL.md |
| .agents/skills/research-issue/SKILL.md | no excluded member | candidate outputs: extensions/drm-copilot/resources/claude-customizations/.claude/skills/research-issue/SKILL.md; candidate sources: .agents/skills/research-issue/SKILL.md, .claude/skills/research-issue/SKILL.md |
| .agents/skills/review-epic/SKILL.md | no excluded member | candidate outputs: extensions/drm-copilot/resources/claude-customizations/.claude/skills/review-epic/SKILL.md; candidate sources: .agents/skills/review-epic/SKILL.md, .claude/skills/review-epic/SKILL.md |
| .agents/skills/review-feature/SKILL.md | no excluded member | candidate outputs: extensions/drm-copilot/resources/claude-customizations/.claude/skills/review-feature/SKILL.md; candidate sources: .agents/skills/review-feature/SKILL.md, .claude/skills/review-feature/SKILL.md |
| .codex/agents/orchestrator.toml | no excluded member | candidate outputs: .codex/agents/orchestrator-c1.toml, extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/orchestrator-c1.toml, .codex/agents/orchestrator-c2.toml, extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/orchestrator-c2.toml, .codex/agents/orchestrator-c3.toml, extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/orchestrator-c3.toml, .codex/agents/orchestrator-c3-elevated.toml, extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/orchestrator-c3-elevated.toml, .codex/agents/orchestrator-c4.toml, extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/orchestrator-c4.toml; candidate sources: .codex/agents/orchestrator.toml |
| .codex/agents/prd-feature.toml | no excluded member | candidate outputs: .codex/agents/prd-feature-c1.toml, extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/prd-feature-c1.toml, .codex/agents/prd-feature-c2.toml, extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/prd-feature-c2.toml, .codex/agents/prd-feature-c3.toml, extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/prd-feature-c3.toml, .codex/agents/prd-feature-c3-elevated.toml, extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/prd-feature-c3-elevated.toml, .codex/agents/prd-feature-c4.toml, extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/prd-feature-c4.toml; candidate sources: .codex/agents/prd-feature.toml |
| codex-variants:.codex/agents/epic-orchestrator.toml | has excluded member | CLOSED |
| codex-variants:.codex/agents/epic-review.toml | no excluded member | candidate outputs: extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/epic-review.toml; candidate sources: .codex/agents/epic-review.toml |
| codex-variants:.codex/agents/feature-review.toml | no excluded member | candidate outputs: extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/feature-review.toml; candidate sources: .codex/agents/feature-review.toml |
| codex-variants:.codex/agents/orchestrator-c3-elevated.toml | no excluded member | candidate outputs: extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/orchestrator-c3-elevated.toml; candidate sources: .codex/agents/orchestrator-c3-elevated.toml |
| codex-variants:.codex/agents/orchestrator.toml | no excluded member | candidate outputs: extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/orchestrator.toml, .codex/agents/orchestrator-c1.toml, extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/orchestrator-c1.toml, .codex/agents/orchestrator-c2.toml, extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/orchestrator-c2.toml, .codex/agents/orchestrator-c3.toml, extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/orchestrator-c3.toml, .codex/agents/orchestrator-c4.toml, extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/orchestrator-c4.toml; candidate sources: .codex/agents/orchestrator.toml |
| codex-variants:.codex/agents/prd-feature-c3-elevated.toml | no excluded member | candidate outputs: extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/prd-feature-c3-elevated.toml; candidate sources: .codex/agents/prd-feature-c3-elevated.toml |
| codex-variants:.codex/agents/prd-feature.toml | no excluded member | candidate outputs: extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/prd-feature.toml, .codex/agents/prd-feature-c1.toml, extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/prd-feature-c1.toml, .codex/agents/prd-feature-c2.toml, extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/prd-feature-c2.toml, .codex/agents/prd-feature-c3.toml, extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/prd-feature-c3.toml, .codex/agents/prd-feature-c4.toml, extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/prd-feature-c4.toml; candidate sources: .codex/agents/prd-feature.toml |
