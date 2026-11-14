# Preflight fixes — remediation plan main-sync cycle 1 (issue #1159)

Timestamp: 2026-11-14T07-05
Plan: docs/features/active/2026-11-09-hook-dispatcher-process-cost-1159/remediation-plan.2026-11-14T06-51.md
Validator: scripts/dev_tools/validate_orchestration_artifacts.py plan (branch-current) exit 0; MCP validate_orchestration_artifacts plan ok.

## Fixes (task text only; no task added, removed or reordered)

1. [P1-T12] | feature-added files compared with the merge base | The cost-artifact clause compared `hook-process-cost.*.md` and `pr-cost-summary.*.md` against the new merge base. The branch added all of them, so `git diff --name-status` against the merge base lists them as `A` whatever this cycle does, and the condition could not pass. The comparison point is now the branch head at the start of this cycle (the commit whose subject is `docs(1159): record main-sync remediation cycle 1 inputs`). The meaning is unchanged: this cycle does not re-run or modify the cost reports.
2. [P1-T5], [P1-T9] | test-name citation | The parity `It` template was cited as `has parity envelopes for <hook leaf>`. The test declares `has parity envelopes for <Leaf>` in `tests/scripts/claude-hooks/PreToolUseDispatch.Parity.Tests.ps1`. Both occurrences now use the declared template.

## Design check (recorded in the return, no defect)

- F1 (D6): implemented by [P0-T6] and [P1-T1]. The failing test for the rule is `loads each stateless shared module once per call`. The guarded `DocsReceiptRevision.psm1` edge is currently the only arrived `-Force` edge. Only `enforce-model-routing-receipt-docs.ps1` imports it directly, under the Agent matcher. `DocsCompleteGate.psm1` imports it nested, without `-Force`, under the Bash matcher. Because no current envelope loads it twice, the test passes before and after the edit. The removal makes the edge match the D6 text rule.
- F2 (D13): implemented by [P0-T5] and [P1-T2]. The failing test is `registers no hook whose tail passes an entry-point pipeline to exit` in `tests/scripts/claude-runtime/hook-dependency-guard-completeness.Tests.ps1`.
- F3 (D15): implemented by [P0-T3], [P1-T3], [P1-T4], [P1-T5], [P1-T6] and [P1-T9] through [P1-T12]. The failing tests are the single-registration assertions and the parity suite, `has parity envelopes for <Leaf>`, with skipped names listed in the gate evidence.
