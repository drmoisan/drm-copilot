# Execution Decision: Pre-existing Pester Failure in the Phase 0 Baseline

Timestamp: 2026-11-18T08-22
Command: sh .claude/skills/test-execution-policy/scripts/run-test-suite.sh pester; node SCRATCH/issue-1029-junit.cjs artifacts/pester/parallel/shard-*/pester-junit.xml
EXIT_CODE: 1
Output Summary: The Phase 0 Pester baseline has one failing test, `HarnessGeneration.RepoGate.Tests.ps1` (`reports no drift for any generated target in the working tree`), which reports generation drift in `.claude/rules/orchestrator-state.md` and its bundle copy. The drift was present before this item changed any file.

## Decision

Recommended option, taken under OD-1 and the cost-benefit rule (OD-4): the test is recorded as a pre-existing baseline failure. Phase gates and the final Pester gate are judged by the plan's comparison rule ("no new failing test" against the `Phase 0 baseline`): a gate passes when its only failure is this named test with the same drift message, and every other test passes. Each gate artifact names it.

## Reason

- The repair is a regeneration of `.claude/rules/orchestrator-state.md` and its bundle copy. Files under `.claude/rules/` are policy documents that the policy-compliance hard constraints forbid this executor to modify, and the file is outside this plan's file set and scope.
- The drift comes from upstream merges into the integration branch (the last commits on the file are #1201 and #1156), not from this item.
- No task of this plan reads or writes the drifted files, so the failure cannot mask a regression introduced here.
- Follow-up: the epic orchestrator owns the integration-branch regeneration; this record is the hand-off note.
