# Preflight Fixes

Timestamp: 2026-11-10T02-17
Plan: docs/features/active/2026-11-09-test-execution-policy-machine-lock-1158/plan.2026-11-09T16-31.md

## Fix 1

- Task: `## Execution Constraints` (registration branch B)
- Defect class: stale fact in a citation (registry member shape)
- Finding: the branch B text gave every registry member a `timeout` of 30 in all four `pretooluse-dispatch.json` copies. The #1159 spec and plan on `origin/feature/hook-dispatcher-process-cost-1159` keep `command`, `command_windows`, and `timeout` on Codex registry hooks, use the settings shape `{type, command}` for Claude registry groups, and give the Claude dispatcher no `timeout` key.
- Change made: the member is now described as `command`, `command_windows`, and member `timeout` 30 in the two Codex registry copies, and the settings shape with no member `timeout` in the two Claude registry copies. The Codex timeout-sum assertion and the merged-tree-authoritative clause are unchanged.

## Fix 2

- Task: [P6-T7]
- Defect class: incomplete enumeration against the cited format (README `## Entry Format`, `Test-ProcessReductionIndex`)
- Finding: the README requires `## Files Changed` to list contract tests and bundled copies. The task's list left out the two contract tests that revert step 5 edits and the bundle copies of the `test-execution-policy.ps1` twins. The index row named only the ID and Status cells, but the index-row check requires all five cells to be non-blank.
- Change made: added `tests/scripts/claude-runtime/parallel-gate-wording.Tests.ps1`, `tests/scripts/dev_tools/test_execution_environment_brief_contracts.py`, and the twins' two bundle copies to the `## Files Changed` list. The row now states Title `Local lane exclusion`, Date the UTC write date, and Issue `#1158`. The asserted ledger tests are unchanged.

## Fix 3

- Task: [P6-T8]
- Defect class: ambiguous mechanical instruction (literal clarification within the existing ledger rule)
- Finding: "regenerated to carry the new file text" could be read as the live text. `patches/0006-test-suite-baseline-restored.patch` also holds hunks on `parallel-gate-wording.Tests.ps1`, so the `0001` creation hunk must hold the text that remains after the `0006` hunks are reversed. That is the highest-number-first order that the `## Execution Constraints` ledger rule and spec D29 already require.
- Change made: P6-T8 now names the `0006` patch, regenerates later hunks first, and says that the `0001` creation hunk carries the text after those hunks are reversed, not the live text. The asserted tests are unchanged.
