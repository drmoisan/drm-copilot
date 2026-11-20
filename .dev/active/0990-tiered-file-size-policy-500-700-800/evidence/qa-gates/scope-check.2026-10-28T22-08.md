# Scope Check

Timestamp: 2026-10-28T22-08
Command: git diff --name-only origin/main...HEAD; git status --porcelain (all work staged with git add -A)
EXIT_CODE: 0
Output Summary: 8 committed paths (all feature-folder or promotion documents) and 149 staged or modified paths; every path is named by a task in the plan or lies in `<FEATURE>/`. No unexpected path.

## Committed since the merge base (`origin/main...HEAD`)

All eight are planning documents in `<FEATURE>/` (`issue.md`, `spec.md`, `user-story.md`, the plan, `research/research.2026-10-28T13-00.md`, two `evidence/other/preflight-fixes.*.md`) and the promoted potential entry `docs/features/potential/promoted/2026-10-28-tiered-file-size-policy-500-700-800.md` (feature-promotion lifecycle).

## Working tree (staged), mapped to tasks

| Paths | Task |
|---|---|
| `.claude/lib/file-size-policy/FileSizePolicy.psm1`; `tests/scripts/claude-lib/file-size-policy/FileSizePolicy.Cases.ps1`, `FileSizePolicy.Tests.ps1` | [P1-T1] |
| `tests/scripts/claude-lib/file-size-policy/FileSizePolicy.HookDecision.Tests.ps1` | [P1-T2] |
| `quality-tiers.yml` | [P1-T3] |
| `.claude/hooks/enforce-file-size-limit.ps1`; `tests/scripts/claude-hooks/enforce-file-size-limit.Tests.ps1` | [P2-T1] |
| `.claude/settings.json` and bundle twin; bundle copies of the module and hook; `claude-customizations/pack-manifests/core.json`; `FileSizePolicy.Manifest.Tests.ps1` | [P2-T2] |
| `PreToolUseSchema.Contract.Tests.ps1`, `hook-dependency-failure.Claude.Tests.ps1` | [P2-T3] |
| `.codex/hooks/file-size-policy.ps1`; `tests/scripts/codex-hooks/file-size-policy.Tests.ps1` | [P3-T1] |
| `.codex/hooks/enforce-file-size-limit.ps1`; `tests/scripts/codex-hooks/enforce-file-size-limit.Tests.ps1` | [P3-T2] |
| `.codex/config.toml` and bundle twin; bundle copies of the Codex hook and twin; `codex-and-agents-customizations/pack-manifests/core.json` | [P3-T3] |
| `legacy-codex-hook-contracts.Tests.ps1`, `codex-pretooluse-transport.Tests.ps1`, `hook-dependency-failure.Codex.Tests.ps1`, `codex-bundle-hook-probe.Tests.ps1` | [P3-T4] |
| `scripts/ci/FileSizeBaseline.psm1`; `tests/scripts/ci/FileSizeBaseline.Tests.ps1` | [P4-T1] |
| `scripts/ci/New-FileSizeBaseline.ps1`; `tests/scripts/ci/New-FileSizeBaseline.Tests.ps1` | [P4-T2] |
| `config/file-size-baseline.json` | [P4-T3] |
| `tests/scripts/ci/FileSizePolicy.RepoGate.Tests.ps1` | [P4-T4] |
| `ClaudeLibModuleConvention.Tests.ps1` | [P5-T2] |
| `codex-epic-runtime-contracts.Tests.ps1` | [P5-T3] |
| `enforcement-hooks-checkpoint-path-explicit.Tests.ps1`, the targets and helpers `.Parity.Tests.ps1`, `enforce-orchestration-preimplementation-gate-epic-scope.Tests.ps1` | [P5-T4] |
| `.github/instructions/general-code-change.instructions.md` and twin | [P6-T1] |
| `.claude/rules/general-code-change.md` and twin | [P6-T2] |
| `.agents/skills/general-code-change/SKILL.md`, `AGENTS.md`, and twins | [P6-T3] |
| `.github/instructions/powershell-code-change.instructions.md`, `.claude/rules/powershell.md`, `.claude/rules/shell.md`, `.agents/skills/powershell/SKILL.md`, and twins | [P6-T4] |
| `.github/agents/commentary-remediation.agent.md`, `.github/prompts/remediate-comments.prompt.md`, `.claude/skills/cleanup-merged-worktrees/SKILL.md`, twins, bundle-only orchestrator memory files | [P6-T5] |
| `.github/agents/python-typed-engineer.agent.md`, `python-execution-only-typed.agent.md`, `.claude/agents/{python,powershell,csharp}-typed-engineer.md`, twins, bundle-only `.claude-variants/csharp-legacy` agent | [P6-T6] |
| `.codex/agents/{python,powershell,csharp}-typed-engineer*.toml` (bases and generated variants), bundle copies, bundle-only `.codex-variants/csharp-legacy` agent | [P6-T7] |
| Six `execution-environment/SKILL.md` copies | [P6-T8] |
| `.claude/agents/feature-review.md`, `.codex/agents/feature-review.toml`, `.agents/skills/feature-review/SKILL.md`, `.github/skills/feature-review-workflow/SKILL.md`, and twins | [P6-T9] |
| `docs/features/templates/policy_audit/{code-review,policy-audit}.yyyy-MM-ddTHH-mm.md` and twins under `extensions/drm-copilot/resources/templates/policy_audit/` | [P6-T10] |
| `<FEATURE>/evidence/**`, `<FEATURE>/plan.2026-10-28T07-57.md`, `<FEATURE>/spec.md`, `<FEATURE>/user-story.md` | Evidence and check-offs in `<FEATURE>/` |
