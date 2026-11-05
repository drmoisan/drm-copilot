# Codex Preimplementation-Gate Suites (Issue #1026, P3-T4)

Timestamp: 2026-11-03T13-27
Command: sh SCRATCH/issue-1026-ps.sh SCRATCH/issue-1026-pester.txt @SCRATCH/issue-1026-list-p3.txt (Invoke-Pester over the 14 suites listed below in one process, JUnit to artifacts/pester/pester-junit.xml, coverage disabled)
EXIT_CODE: 0
Output Summary: JUnit testcases 490, passed 490, failed 0, skipped 0. The new suite tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-cleanup.Tests.ps1 contributes 34 testcases. The three AC10 names appear in the JUnit testcase names (1 hit each). Discovery-guard compliance of the new suite: 0 findings.

Suites run:

- `tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-cleanup.Tests.ps1` (new)
- every existing Codex `tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-*.Tests.ps1` suite (12 files: `-command-exemption.Selectors`, `-command-exemption`, `-epic-resolution`, `-epic-scope.Decision`, `-epic-scope`, `-epic-scope-targets`, `-mode-resolution.TargetFolder`, `-mode-resolution`, `-mode-routing`, `-operand-bypass`, `-target-worktree`, `-trigger-scoping`)
- `tests/scripts/codex-hooks/codex-preimplementation-gate-absolute-paths.Tests.ps1`

AC10 names confirmed:

- `allows an apply_patch Add File of the manifest with valid content`
- `denies an apply_patch Update, Delete, or Move of the manifest`
- `forwards Write content from the Codex entry tail to the decision`

First run of the same set (2026-11-03T13-26): 489 passed, 1 failed. The failing row was `keeps enforce-orchestration-preimplementation-gate.ps1 byte-identical to its bundle copy` in `enforce-orchestration-preimplementation-gate-epic-scope.Tests.ps1`, which pins the Codex gate to `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-orchestration-preimplementation-gate.ps1`. The plan refreshes that bundle copy in P8-T2; the copy was made at this point instead, as a mechanical action required for this task's zero-failure condition, and P8-T2 re-verifies it. The rerun above is the recorded result.

Line counts: Codex gate 493 (P0-T2 value 491 plus 2; at most 500), Codex gate sibling 421 (byte-identical to the Claude sibling, SHA256 equal), new Codex suite 357.
