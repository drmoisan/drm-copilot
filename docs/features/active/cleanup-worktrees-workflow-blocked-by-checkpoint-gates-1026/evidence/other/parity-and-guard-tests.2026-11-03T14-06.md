# Parity and Guard Suites (Issue #1026, P8-T8)

Timestamp: 2026-11-03T14-06
Command: sh SCRATCH/issue-1026-ps.sh SCRATCH/issue-1026-pester.txt @SCRATCH/issue-1026-list-p8t8.txt (Invoke-Pester over the 36 suites below in one process, JUnit to artifacts/pester/pester-junit.xml, coverage disabled)
EXIT_CODE: 0
Output Summary: JUnit testcases 1648, passed 1648, failed 0, skipped 0; Pester containers failed 0. Every Discovery guard row `AC-4 <Path> complies with the baseline isolation form for every closure seam` for the 24 suites edited in P8-T7 is present once and Passed (24 of 24). This supersedes the blocked run recorded in parity-and-guard-tests.2026-11-03T13-47.md.

Suites run:

- `tests/scripts/claude-hooks/hook-cleanup-context.Parity.Tests.ps1` (new)
- `tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1`
- `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-helpers.Parity.Tests.ps1`
- `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-targets.Parity.Tests.ps1`
- `tests/scripts/claude-runtime/hook-dependency-guard-completeness.Tests.ps1`
- `tests/scripts/claude-runtime/enforcement-hooks-no-python-invocation.Tests.ps1`
- `tests/scripts/codex-hooks/codex-epic-runtime-contracts.Tests.ps1`
- `tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.Discovery.Tests.ps1`
- `tests/scripts/claude-runtime/test-name-uniqueness.Tests.ps1`
- `tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.Tests.ps1` (unchanged)
- `tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.Branches.Tests.ps1` (unchanged)
- `tests/scripts/claude-hooks/session-root-reads-850.Constraints.Tests.ps1` (unchanged)
- The 24 suites edited in P8-T7 (all under `tests/scripts/claude-hooks/`): `enforce-model-routing-receipt.AuthorAsserted`, `.EpicModeStrict`, `.EpicScope`, `enforce-model-routing-receipt`, `.WorktreeResolution`; `enforce-pr-author-skill.BodyNumber`, `.CurrentBranch`, `.DocsOnly.Decision`, `.DocsOnly.Exemption`, `.DocsOnly`, `.EpicScope`, `.Issue824`, `.ItemArtifactRoot`, `.OrchestratorStatePreflight`, `.Payload`, `.TargetResolution`, `enforce-pr-author-skill`, `.TriggerScoping`, `.WorktreeResolution`, `.epic-base-branch.EpicModeStrict`, `.epic-base-branch`, `.epic-base-branch.TriggerScoping`; `hook-command-consumers.Issue824`; `hook-dependency-failure.SpecialCases` (each `.Tests.ps1`).

P8-T7 static verification (SCRATCH/issue-1026-p8t7-verify.txt): all 24 files parse with zero errors and contain `Get-CleanupWorktreeManifestContent`; 22 files grew by exactly one line (one outermost `BeforeAll` each, helper form) and the two append files are line-neutral; every diff hunk from `MERGE_BASE` lies inside an outermost `BeforeAll`; `Get-EpicStateSuiteCompliance` returns no finding for any of the 24; the five 500-capped suites are at most 470 lines.
