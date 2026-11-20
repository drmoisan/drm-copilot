# Pester Isolation (issue 1024)

Timestamp: 2026-11-04T04-31
Task: [P9-T5]
Command: (1) for seeds 11, 23, 47: SCRATCH/issue-1024-shuffle.ps1 -Seed <seed> (ordinal-sorted list of the touched suites, Fisher-Yates shuffle over [System.Random]::new(<seed>), one Invoke-Pester call per seed in one process, Run.PassThru, no coverage, no strict mode in the runner); (2) fresh single-process Invoke-PoshQCTest -Root <worktree> -ScanFolders tests/scripts with JUnit and coverage written under SCRATCH; (3) the same fresh run in a git archive export of EPIC-BASE under SCRATCH as a same-host reference
EXIT_CODE: 0
Output Summary: Seeds 11, 23 and 47: 390 tests each, 0 failures, 0 failed containers. Fresh single-process tests/scripts run on the branch: 14638 passed, 409 failed, 10 skipped (process exit 255 from the Pester JUnit export, as recorded for this host). No failure is in tests/scripts/claude-lib/docs or in any suite that reads a 1024 file; all 409 belong to the known pre-existing families #1066 and #1067. No order dependence involving the touched suites was found.

## Touched suites (16)

NEW-SUITES (12 `tests/scripts/claude-lib/docs/DocsReference*.Tests.ps1` files), `tests/scripts/claude-lib/docs/Docs.Manifest.Tests.ps1`, `tests/scripts/claude-lib/docs/DocsWriteBoundary.Tests.ps1` (edited by this feature in [P9-T3]), `tests/scripts/claude-lib/ClaudeLibModuleConvention.Tests.ps1`, `tests/scripts/claude-runtime/enforcement-hooks-no-python-invocation.Tests.ps1`. The executed container order equalled the planned order in every seed.

## Seed 11 (total 390, passed 390, failed 0)

1. `DocsReferenceIntegration.Tests.ps1`
2. `DocsReferenceRender.Tests.ps1`
3. `DocsReferenceFrontMatter.Properties.Tests.ps1`
4. `DocsReferenceFrontMatter.Tests.ps1`
5. `DocsWriteBoundary.Tests.ps1`
6. `DocsReferenceWriter.Tests.ps1`
7. `claude-runtime/enforcement-hooks-no-python-invocation.Tests.ps1`
8. `DocsReferenceWriter.Properties.Tests.ps1`
9. `DocsReferencePlan.Tests.ps1`
10. `DocsReferencePlan.Properties.Tests.ps1`
11. `Docs.Manifest.Tests.ps1`
12. `DocsReferenceBoundary.Tests.ps1`
13. `DocsReferenceWriter.Errors.Tests.ps1`
14. `DocsReferenceMarkers.Properties.Tests.ps1`
15. `claude-lib/ClaudeLibModuleConvention.Tests.ps1`
16. `DocsReferenceMarkers.Tests.ps1`

## Seed 23 (total 390, passed 390, failed 0)

1. `DocsReferenceFrontMatter.Tests.ps1`
2. `claude-lib/ClaudeLibModuleConvention.Tests.ps1`
3. `DocsReferenceFrontMatter.Properties.Tests.ps1`
4. `DocsReferenceRender.Tests.ps1`
5. `DocsReferencePlan.Tests.ps1`
6. `Docs.Manifest.Tests.ps1`
7. `DocsReferenceIntegration.Tests.ps1`
8. `DocsReferenceWriter.Properties.Tests.ps1`
9. `DocsWriteBoundary.Tests.ps1`
10. `DocsReferenceBoundary.Tests.ps1`
11. `DocsReferenceWriter.Tests.ps1`
12. `DocsReferenceMarkers.Tests.ps1`
13. `DocsReferenceMarkers.Properties.Tests.ps1`
14. `claude-runtime/enforcement-hooks-no-python-invocation.Tests.ps1`
15. `DocsReferencePlan.Properties.Tests.ps1`
16. `DocsReferenceWriter.Errors.Tests.ps1`

## Seed 47 (total 390, passed 390, failed 0)

1. `DocsReferenceWriter.Properties.Tests.ps1`
2. `Docs.Manifest.Tests.ps1`
3. `DocsReferenceBoundary.Tests.ps1`
4. `DocsReferenceFrontMatter.Properties.Tests.ps1`
5. `DocsReferenceWriter.Tests.ps1`
6. `DocsReferenceWriter.Errors.Tests.ps1`
7. `claude-runtime/enforcement-hooks-no-python-invocation.Tests.ps1`
8. `DocsReferenceRender.Tests.ps1`
9. `claude-lib/ClaudeLibModuleConvention.Tests.ps1`
10. `DocsWriteBoundary.Tests.ps1`
11. `DocsReferenceMarkers.Properties.Tests.ps1`
12. `DocsReferenceIntegration.Tests.ps1`
13. `DocsReferenceMarkers.Tests.ps1`
14. `DocsReferencePlan.Properties.Tests.ps1`
15. `DocsReferencePlan.Tests.ps1`
16. `DocsReferenceFrontMatter.Tests.ps1`

Unprefixed names are under `tests/scripts/claude-lib/docs/`; the other two are under `tests/scripts/`.

## Fresh single-process run over tests/scripts

| Run | Passed | Failed | Skipped | BeforeAll/AfterAll failed | Failing suites |
|---|---|---|---|---|---|
| Branch HEAD (item worktree) | 14638 | 409 | 10 | 6 | 14 |
| EPIC-BASE export (reference) | 14449 | 254 | 10 | 5 | 14 |

Pre-existing classification (not fixed, per the delegation):

- #1066 (`$env:PATH` leak in `tests/scripts/dev-tools/run-actionlint.Tests.ps1`): later suites in the same process cannot resolve `pwsh` or `python`. The branch count of 409 equals the single-process count recorded for this host on 2026-11-03 before this feature's Phase 8 and 9 changes (issue #1026).
- #1067 (platform-dependent fixtures under `tests/scripts/dev-tools` and `tests/scripts/powershell/PoshQC`): `bootstrap-host`, `new-claude-worktree-session`, `new-potential-entry`, `PoshQC.RunSettings`, `PoshQC.ShardWeights`.

Failing suites on the branch: `claude-hooks/enforce-parallel-cohort-barrier.WorktreeResolution`, `codex-hooks/codex-batch-budget.TargetWorktree`, `codex-hooks/codex-completion-consistency-hook`, `codex-hooks/codex-pretooluse-file-mapping`, `codex-hooks/epic-child-worktree-launcher`, `codex-hooks/hook-target-worktree`, `codex-scripts/codex-routing-cli-common`, `dev-tools/bootstrap-host`, `dev-tools/new-claude-worktree-session`, `dev-tools/new-potential-entry`, `dev-tools/run-actionlint`, `host-tools.manifest`, `powershell/PoshQC/PoshQC.RunSettings`, `powershell/PoshQC/PoshQC.ShardWeights`. None is under `tests/scripts/claude-lib/docs`, and none imports a `.claude/lib/docs` module, the push-down bundle copies, or `core.json`.

Comparison of the printed failed-case lines (ANSI codes and durations stripped, byte-order sorted): 83 lines are common to both runs. Branch-only lines: `codex-scripts/codex-routing-cli-common` (1, a Describe-level failure) and `host-tools.manifest` (13). Base-only lines: `codex-scripts/Resolve-CodexRouting.Parity` (13) and `dev-tools/Invoke-FullReleaseFlow.MergeWait` (5). The reference export has no `.git` directory and no `.venv`, which changes how the worktree-, venv- and PATH-dependent suites behave, so the counts are not expected to be equal.

Branch-only suites in isolation: `Invoke-PoshQCTest` over `tests/scripts/host-tools.manifest.Tests.ps1` and `tests/scripts/codex-scripts/codex-routing-cli-common.Tests.ps1` alone on the branch reported 44 tests, 0 failures. Their single-process failures therefore depend on the earlier suites in the process (the #1066 PATH leak), not on this feature, which changes no file that either suite reads.

## Order dependence

No order dependence involving the touched suites was found, so no suite was changed for isolation.
