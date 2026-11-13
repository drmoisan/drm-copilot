# Preflight Fixes

Timestamp: 2026-11-09T22-22
Plan: docs/features/active/2026-11-09-hook-session-root-resolution-1163/plan.2026-11-09T16-33.md
Command: env -u VIRTUAL_ENV poetry run python -m scripts.dev_tools.validate_orchestration_artifacts plan docs/features/active/2026-11-09-hook-session-root-resolution-1163/plan.2026-11-09T16-33.md
EXIT_CODE: 0
Output Summary: The branch-current plan validator passed before and after the fixes below. The task count and task order are unchanged. Substantive defects are returned to the planner and are not fixed here.

## Fixes

1. Shared conventions preamble | example operand in plan prose | "POSIX roots such as ..." became a concrete list that adds `/sibling/item-b`, the root [P1-T2] uses.
2. [P0-T2] | nonexistent tool mode | PoshQC has no formatter check mode. The task now runs `Invoke-PoshQCFormat` with a non-writing `WriteFile` seam that records each file it would rewrite and uses that count as the finding count, so the baseline does not repair pre-existing drift.
3. [P1-T2] | imprecise symbol anchor | "the Codex decision entry" became `Invoke-CodexFileSizeLimitDecision` with its `Record` and `Payload` inputs.
4. [P2-T1] | test-route class (parallel-only runs) | the single-process run "with exit enabled" became one `Invoke-PoshQCParallelTest` run, with results read from the per-shard JUnit files under `artifacts/pester/parallel/`, because a failed run writes no merged JUnit. The illustrative "for example" list was removed. The asserted content (non-zero EXIT_CODE and the listed rows) is unchanged.
5. [P3-T2] | ambiguous call shape in an asserted parity condition | the parity rows now state `Policy = FailClosedOnIdentity`. Under the default `SessionFallback`, an unresolved result carries the session root and cannot equal the null root of `Resolve-HookTargetWorktree`.
6. [P4-T2] | inaccurate disposition reason | the non-TargetWorktree suites that serve transcripts are now named, with the reason each keeps its decision: `validate-executor-output.LightRemediation.Tests.ps1` and `validate-executor-output.Preflight.Tests.ps1` (no identity), and `validate-human-exception-runbook-output.Tests.ps1` (resolves a live item root through its in-memory listing).
7. [P5-T1] and [P5-T2] | partial write paths | each named test file now carries its full repository-relative path.
8. [P5-T3] | mechanically required seam forwarding | the Codex outside-root row that the task updates reaches the decision through `Invoke-CodexFileSizeLimitEntryPoint` (via `Invoke-CodexFileSizeHook`). The task now states that the entry point forwards a bound `-WorktreeListInvoker`, as it already forwards `-ReadFileContent`. The task also names both decision functions that gain the parameter.
9. [P6-T2] | glob tokens in plan prose | `enforce-epic-worktree-removal-gate.*.Tests.ps1` and `enforce-parallel-worktree-removal-gate.*.Tests.ps1` became the eleven concrete suite names. The four merge-gate suites that carry `branch_name` (GreenCiRegression, ItemResolution, WorktreeResolution, and ReviewPaths) are now named as unchanged, with the reason: they stub the checkpoint reader or mock the green-CI seam.
10. [P7-T2] | missing disposition for tests that pin the edited section | the task now keeps every other passage of `## Hook Execution Context` and names the pinning tests as unchanged: the two rows of `tests/scripts/claude-hooks/cleanup-merged-worktrees.SkillText.Tests.ps1` and the `MERGE-GUARD` check of `tests/scripts/claude-runtime/planning-contract-wording.Tests.ps1`.
