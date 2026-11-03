# Parity and Guard Suites (Issue #1026, P8-T7) - BLOCKED

Timestamp: 2026-11-03T13-47
Command: sh SCRATCH/issue-1026-ps.sh SCRATCH/issue-1026-pester.txt @SCRATCH/issue-1026-list-p8.txt (Invoke-Pester over the 9 suites below in one process, JUnit to artifacts/pester/pester-junit.xml, coverage disabled)
EXIT_CODE: 1
Output Summary: JUnit testcases 1212, passed 1188, failed 24, skipped 0. All 24 failures are AC-4 rows of tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.Discovery.Tests.ps1, each with the finding "seam Get-CleanupWorktreeManifestContent: Mock of Get-CleanupWorktreeManifestContent missing from outermost BeforeAll" for an existing suite. Every other suite in the set passes. P8-T7 acceptance (zero failures) is not met; the task is left unchecked.

Exit code note: the runner script itself exits 0 because the program prints the JUnit counts and does not propagate the failure count; the recorded EXIT_CODE is 1 because the gate failed.

Suites run:

- `tests/scripts/claude-hooks/hook-cleanup-context.Parity.Tests.ps1` (new; 4 passed)
- `tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1`
- `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-helpers.Parity.Tests.ps1`
- `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-targets.Parity.Tests.ps1`
- `tests/scripts/claude-runtime/hook-dependency-guard-completeness.Tests.ps1`
- `tests/scripts/claude-runtime/enforcement-hooks-no-python-invocation.Tests.ps1`
- `tests/scripts/codex-hooks/codex-epic-runtime-contracts.Tests.ps1`
- `tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.Discovery.Tests.ps1`
- `tests/scripts/claude-runtime/test-name-uniqueness.Tests.ps1`

Existing suites the Discovery guard reports (24):

- Model routing (5): `enforce-model-routing-receipt.AuthorAsserted.Tests.ps1`, `.EpicModeStrict.Tests.ps1`, `.EpicScope.Tests.ps1`, `.Tests.ps1`, `.WorktreeResolution.Tests.ps1`
- PR author (17): `enforce-pr-author-skill.BodyNumber.Tests.ps1`, `.CurrentBranch.Tests.ps1`, `.DocsOnly.Decision.Tests.ps1`, `.DocsOnly.Exemption.Tests.ps1`, `.DocsOnly.Tests.ps1`, `.EpicScope.Tests.ps1`, `.Issue824.Tests.ps1`, `.ItemArtifactRoot.Tests.ps1`, `.OrchestratorStatePreflight.Tests.ps1`, `.Payload.Tests.ps1`, `.TargetResolution.Tests.ps1`, `.Tests.ps1`, `.TriggerScoping.Tests.ps1`, `.WorktreeResolution.Tests.ps1`, `.epic-base-branch.EpicModeStrict.Tests.ps1`, `.epic-base-branch.Tests.ps1`, `.epic-base-branch.TriggerScoping.Tests.ps1`
- Other loaders of those hooks (2): `hook-command-consumers.Issue824.Tests.ps1`, `hook-dependency-failure.SpecialCases.Tests.ps1`

All files are under `tests/scripts/claude-hooks/`.

Cause: P4-T1 (DP4) and P5-T1 add a guarded `Import-Module` of `.claude/lib/cleanup-manifest/CleanupWorktreeManifest.psm1` to `enforce-pr-author-skill.cleanup.ps1` (loaded through `enforce-pr-author-skill.docs-only.ps1`) and to `enforce-model-routing-receipt.ps1`. The guard computes each suite's loaded-source closure from the hook it loads, so every existing suite that loads either hook now has the manifest read seam in its closure and must null-mock it in its outermost `BeforeAll`. The suites still pass when run: outside the cleanup context neither hook reaches the manifest read (the PR-author leg requires a `documentationandmemories` token and the model-routing leg requires the branch label first). The failure comes from the guard's static census.

Conflict: making these suites compliant means adding one baseline mock line to each of the 24 existing test files. P9-T8's acceptance condition allows only two existing test files to be modified (`legacy-codex-hook-contracts.Tests.ps1`, on its `SharedModuleNames` line only, and `EpicStateIsolation.Baseline.Helpers.ps1`). The plan does not name the 24 files, and changing them would be work the plan does not describe.
