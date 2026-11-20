# Expect-Fail Regression Run

Timestamp: 2026-10-29T10-48
Task: [P1-T8]
Command: Invoke-PoshQCTest -Root <repo root> -ScanFolders <the seven test files of [P1-T1] through [P1-T6]> (PowerShell 7 launched by `sh SCRATCH/issue-995-pester-files.sh`); then poetry run pytest --no-cov -q "tests/scripts/dev_tools/test_parallel_orchestrator_surface_contracts.py::test_agent_tools_allowlist_grants_only_the_records_pr_author_channel"
EXIT_CODE: 1
ExpectedExitCode: 1
Output Summary: Pester (artifacts/pester/pester-junit.xml): 213 test cases, 104 passed, 109 failed, 0 skipped. Pytest: 1 failed. Every failure is a case [P1-T1] through [P1-T7] names as failing before the implementation, or a case in a new file whose setup depends on a not-yet-defined command. Every deny case in the two gate RelativeRecord files and every pre-existing It in CleanupWorktreeManifestGateMatrix.Tests.ps1 and CleanupWorktreeManifest.Tests.ps1 passes.

Pester exit code: 110 (number of failed containers and tests reported by Pester); Pytest exit code: 1.

## Failing tests and reasons

### tests/scripts/claude-lib/worktree-resolution/WorktreeRunRecordPath.Tests.ps1 ([P1-T1])

All 31 cases (M1 through M11 with data rows, P1 through P5, R1 through R4, X1) fail: the BeforeAll import of `.claude/lib/worktree-resolution/WorktreeRunRecordPath.psm1` fails because the module is absent ("This test should run but it did not. Most likely a setup in some parent block failed").

### tests/scripts/claude-lib/worktree-resolution/WorktreeRunResolution.RelativeRecord.Tests.ps1 ([P1-T2])

| Test | Reason |
| --- | --- |
| RR1, RR2, RR3 (relative-record resolution cases) | CommandNotFoundException: Get-WorktreeRunMainCheckoutRoot is not defined in the WorktreeRunResolution scope, so the topology mock cannot register; resolution of a relative record is not implemented |
| RR4 (four unsafe-record rows), RR5, RR6, RR7 | Same CommandNotFoundException from the shared topology helper; these rows assert boundaries and pass once [P2-T2] defines the seam |

### tests/scripts/claude-hooks/enforce-parallel-worktree-removal-gate.RelativeRecord.Tests.ps1 ([P1-T3])

| Test | Reason |
| --- | --- |
| RP1 merged | expected allow, got deny |
| RP1 worktree_removed | expected allow, got deny |
| RP4 Find-ParallelWorktreeItemRecord -BaseRoot | ParameterBindingException: no parameter BaseRoot |

Passing as required: RP2 (pr_open, worktree_created, absent merge_status, different agent directory, `..` record, blank record) and RP3 (ambiguous).

### tests/scripts/claude-hooks/enforce-epic-worktree-removal-gate.RelativeRecord.Tests.ps1 ([P1-T4])

| Test | Reason |
| --- | --- |
| RE1 parallel merged | expected allow, got deny |
| RE1 parallel worktree_removed | expected allow, got deny |
| RE1 epic merged | expected allow, got deny |
| RE1 epic worktree_removed | expected allow, got deny |
| RE4 diagnostics | ParameterBindingException: no parameter MainRoot on Get-EpicWorktreeGateDenyDiagnostics |

Passing as required: RE2 (the six parallel-item negatives) and RE3 (ambiguous).

### tests/scripts/claude-hooks/CleanupWorktreeManifestGateMatrix.Tests.ps1 ([P1-T5])

| Test | Reason |
| --- | --- |
| enforce-epic-worktree-removal-gate.ps1 manifest fail-closed matrix: denies when a checkpoint records the target relatively with merge_status pr_open | expected deny, got allow (the manifest branch currently allows) |
| enforce-parallel-worktree-removal-gate.ps1 manifest fail-closed matrix: denies when a checkpoint records the target relatively with merge_status pr_open | expected deny, got allow |

All pre-existing It rows in both Describe blocks pass.

### tests/scripts/claude-lib/cleanup-manifest/CleanupWorktreeManifest.Tests.ps1 ([P1-T5])

| Test | Reason |
| --- | --- |
| reports coverage for a relative checkpoint record joined to a base root (issue #995) | ParameterBindingException: no parameter BaseRoot |
| does not report coverage for an unsafe .. relative checkpoint record (issue #995) | ParameterBindingException: no parameter BaseRoot |

All pre-existing It rows pass.

### tests/scripts/claude-runtime/parallel-orchestrate-run-closing.Tests.ps1 ([P1-T6])

All 56 cases fail for both the repository and bundle copies of the skill (RC1 through RC4) and the agent (RA1 through RA4): no `### Run Closing` section exists, `## Completion Requirements` does not name Run Closing, the section shows no staging command, and the agent `tools:` list does not contain `Agent(pr-author)`.

### tests/scripts/dev_tools/test_parallel_orchestrator_surface_contracts.py ([P1-T7])

| Test | Reason |
| --- | --- |
| test_agent_tools_allowlist_grants_only_the_records_pr_author_channel | AssertionError: the tools list contains no pr-author entry, so the collected list is empty rather than exactly Agent(pr-author) |
