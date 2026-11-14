# Preflight fixes: issue 1026 plan

Timestamp: 2026-11-03T12-48
Plan: docs/features/active/cleanup-worktrees-workflow-blocked-by-checkpoint-gates-1026/plan.2026-11-03T06-52.md
Directive: PREFLIGHT VALIDATION ONLY (single pass; task text and preamble only; no task added, removed, or reordered)

## Fixes

1. `## Conventions` (new constraint bullet) | validator-blind defect: repository guard suites not stated | Added the constraints that every new hook suite must meet for `tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.Discovery.Tests.ps1` (closure read seams null-mocked in the outermost `BeforeAll` or through `Register-EpicStateBaselineMock`, plus the `baseline mock interception probe` It when the guard derives a probe seam) and `tests/scripts/claude-runtime/test-name-uniqueness.Tests.ps1`, and the mock-scope rule for direct calls to `Get-CleanupWorktreeManifestContent` and `Get-CleanupWorktreeManifestUtcNow`. These guards scan every suite under the hook directories, and the plan's new suites fall under them; no plan task named them.
2. `[P4-T4]` | validator-blind defect: mock that does not intercept | The task mocked the manifest and clock seams only with `-ModuleName CleanupWorktreeManifest`. Both functions are exported (`Export-ModuleMember` in `.claude/lib/cleanup-manifest/CleanupWorktreeManifest.psm1`), and the new sibling calls them directly from script scope, so a module-scope mock does not intercept the call and the real function reads the gitignored manifest path. Changed the text to script-scope mocks plus the existing module-scope baseline mock. The assertions are unchanged.
3. `[P5-T2]` | validator-blind defect: mock that does not intercept | Same correction as fix 2 for the model-routing cleanup function's direct calls.
4. `[P2-T5]` | test-name citation completeness | "both `enforce-gate-suites.EpicStateIsolation*.Tests.ps1` suites" matched seven files. Replaced it with the three named guard suites: the two that P2-T1 names, plus the Discovery guard that checks the new suites.
5. `[P8-T7]` | test-name citation completeness | Added the Discovery guard and `test-name-uniqueness.Tests.ps1` to the run list. P8-T7 is the first task at which every new suite exists.
6. `[P8-T5]` | existing-test disposition incomplete | Every `$script:StaticCheckNames` assertion iterates the `SharedModuleNames` list, so the update also reaches `keeps the canonical hooks byte-identical to their bundled copies` and `contains no legacy Claude environment-variable dependency in hooks or shared modules`. Added both to the disposition.
7. `[P7-T5]` | existing-test disposition incomplete | `tests/scripts/dev_tools/test_discovery_documentation_contracts.py` asserts byte identity of every committed brief copy, and `tests/scripts/dev_tools/test_single_pass_preflight_contracts.py` reads `.github/skills/execution-environment/SKILL.md`. Added both to the run with disposition "unchanged".
8. `[P2-T3]` | existing-test disposition incomplete | Named the suites that load the Claude gate outside the cited glob: `hook-dependency-failure.Claude.Tests.ps1`, `hook-dependency-guard-completeness.Tests.ps1` (both derive rows from the AST), `hook-import-failure-exemptions.FailClosed.Tests.ps1`, and `PreToolUseSchema.Contract.Tests.ps1`. Disposition: unchanged.
9. `[P3-T2]` | existing-test disposition incomplete | Named `tests/scripts/codex-hooks/codex-pretooluse-transport.Tests.ps1` (builds its own mapped record) and `tests/scripts/codex-hooks/hook-dependency-failure.Codex.Tests.ps1` (derives a row from the AST). Disposition: unchanged.
10. `[P5-T1]` | existing-test disposition incomplete | Named `hook-dependency-failure.Claude.Tests.ps1` and `hook-dependency-guard-completeness.Tests.ps1`, which derive rows for the two new guarded edges. Disposition: unchanged.
11. `[P0-T8]` | precondition for P9-T1 left implicit | P9-T1 re-runs the script unchanged, so the script must already override the two seams the plan adds. Named both seams, `Get-OrchestrationGateTemporaryRoot` and `Get-OrchestrationGateStagedIndex`, and stated that the overrides are defined after the dot-sources.
12. `## AC Interpretation` (AC12 inventory test) | citation incomplete | `.claude/settings.json` registers `enforce-discovery-artifact-gate.ps1` under a combined `PreToolUse` matcher whose alternation includes `Bash`, `Write`, `Edit`, and `Agent`. The inventory description named only the three single-tool matchers, so it now names the combined matcher as well. The test name is unchanged.

## Preconditions checked during preflight (no plan change)

- P0-T2 caps: `.codex/hooks/enforce-orchestration-preimplementation-gate.ps1` has 491 physical lines and `.claude/hooks/enforce-pr-author-skill-helpers.ps1` has 499, so the P3-T2 and P4-T3 budgets hold.
- P0-T3 (DP1): in this session `GetTempPath()` is `long`, and both `TEMP` and `TMP` are `short`. No path value was recorded.
- The item checkpoint selects route `large`, as the Conventions state.

## Validation

Command: poetry run python -m scripts.dev_tools.validate_orchestration_artifacts plan docs/features/active/cleanup-worktrees-workflow-blocked-by-checkpoint-gates-1026/plan.2026-11-03T06-52.md
Result before fixes: plan validation passed (exit 0).
Result after fixes: plan validation passed (exit 0). The installed MCP validator (`artifact_type: plan`) also returned ok.
