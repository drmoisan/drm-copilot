# Model-Routing Gate Suites (Issue #1026, P5-T3)

Timestamp: 2026-11-03T13-34
Command: sh SCRATCH/issue-1026-ps.sh SCRATCH/issue-1026-pester.txt @SCRATCH/issue-1026-list-p5.txt (Invoke-Pester over the 6 suites below in one process, JUnit to artifacts/pester/pester-junit.xml, coverage disabled)
EXIT_CODE: 0
Output Summary: JUnit testcases 75, passed 75, failed 0, skipped 0. The new suite tests/scripts/claude-hooks/enforce-model-routing-receipt.Cleanup.Tests.ps1 contributes 9 testcases. The four AC9 names appear in the JUnit testcase names (1 hit each). Discovery-guard compliance of the new suite: 0 findings (after adding the outermost null mock of Get-ModelRoutingCheckpoint that the guard reported on the first check).

Suites run: `tests/scripts/claude-hooks/enforce-model-routing-receipt.Cleanup.Tests.ps1` (new) and every existing `tests/scripts/claude-hooks/enforce-model-routing-receipt*.Tests.ps1` suite (`.AuthorAsserted`, `.EpicModeStrict`, `.EpicScope`, the base `.Tests.ps1`, `.WorktreeResolution`).

AC9 names confirmed:

- `allows Agent(pr-author) with branch: documentationandmemories when the resolved worktree has no checkpoint and a fresh valid manifest exists`
- `denies the delegation when the manifest is absent or invalid`
- `denies a non-pr-author subagent under the same conditions`
- `denies a different branch label`

Each deny row asserts the unchanged `MODEL_ROUTING_RECEIPT_BLOCKED` text exactly. AC13 pairs: `denies the delegation against a resolved feature worktree with no checkpoint` and `denies the delegation against the session root with no ready checkpoint`.

Line counts: `enforce-model-routing-receipt.ps1` 393 (at most 500); new suite 160.

Finding recorded for escalation (not fixed here): the guarded import of `CleanupWorktreeManifest.psm1` that P4-T1 and P5-T1 add puts the read seam `Get-CleanupWorktreeManifestContent` into the loaded closure of every suite that loads `enforce-pr-author-skill.ps1` or `enforce-model-routing-receipt.ps1`. The Discovery guard (`Get-EpicStateSuiteCompliance`) now reports one finding each for 22 existing suites (17 `enforce-pr-author-skill*` suites and 5 `enforce-model-routing-receipt*` suites): `Mock of Get-CleanupWorktreeManifestContent missing from outermost BeforeAll`. The suites themselves pass; the finding is the static census of `enforce-gate-suites.EpicStateIsolation.Discovery.Tests.ps1`, which P8-T7 runs.
