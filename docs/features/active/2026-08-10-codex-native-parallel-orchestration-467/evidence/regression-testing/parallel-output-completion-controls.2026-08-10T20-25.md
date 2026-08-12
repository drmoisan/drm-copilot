# P4-T6 Parallel Output and Completion Control Evidence

## Scope

- Task: `[P4-T6]`.
- New SubagentStop validator: `.codex/hooks/validate-parallel-agent-output.ps1`.
- Parallel dispatch owners: `.codex/hooks/validate-codex-subagent-routing.ps1` and `.codex/hooks/enforce-completion-consistency.ps1`.
- Configuration registration remains assigned to `[P4-T8]`; no configuration or permission target changed in this task.

## Production Owners and Static Gates

| File | Physical lines | Parser | PoshQC format | PoshQC analyze |
| --- | ---: | --- | --- | --- |
| `validate-parallel-agent-output.ps1` | 179 | 0 errors | PASS | PASS |
| `validate-codex-subagent-routing.ps1` | 211 | 0 errors | PASS | PASS |
| `enforce-completion-consistency.ps1` | 495 | 0 errors | PASS | PASS |

All three files passed the final combined format and analyze loop and remain within the repository 500-line limit.

## SubagentStop Continuation Contract

- Direct output-validator matrix: 4/4.
  - Valid shared-validator output is a silent allow.
  - Invalid output carries `PARALLEL_AGENT_OUTPUT_BLOCKED`.
  - The first invalid stop returns `decision = block` and one reason.
  - A repeated invalid stop with `stop_hook_active = true` returns `continue = false`, `stopReason`, and `systemMessage` instead of another continuation.
- Actual routing-dispatch matrix: 3/3.
  - A valid attested parallel stop passes routing and output validation.
  - The first invalid output requests one continuation.
  - The repeated invalid output terminates the continuation path.
- Existing provenance and model checks remain before the output dispatch. Legacy ordinary and epic routes do not enter the parallel output validator.

The output validator delegates planner readiness to the public
`parallel-planner-state --require-ready-for-execution` command and orchestrator completion to
`parallel-orchestrator-state --require-complete`. Those shared Python validators retain the
Python/TypeScript/MCP transition and normalized-reason parity established in Phase 3.

## Root Completion Contract

- Focused parallel completion matrix: 3/3.
  - A valid complete parallel checkpoint is allowed.
  - An invalid transition is denied with `PARALLEL_COMPLETION_BLOCKED`.
  - A missing immutable completion receipt is denied.
- The branch recognizes only `artifacts/orchestration/parallel-orchestrator-state.json` and is presence-gated on `next_step = complete`; in-progress parallel writes remain allowed.
- The branch invokes the shared orchestrator `--require-complete` path, which loads guarded launch/status/receipt evidence and applies both transition completion and immutable completion-receipt validation.
- Parallel completion rejection occurs before the legacy `Test-CompletionAsserted` branch. Every legacy path and decision remains unchanged.

## Regression Results

Final combined PoshQC/Pester result: 59 tests, 0 failures, 0 errors.

- `parallel-provenance.Tests.ps1`: 14/14.
- `epic-provenance.Tests.ps1`: 29/29.
- `model-profile-attestation.Tests.ps1`: 7/7.
- `codex-completion-consistency-hook.Tests.ps1`: 9/9.

## Repository Invariants

- `.claude` status entries: 0.
- `.claude` diff entries: 0.
- The completed PowerShell batch receipt named only the three P4-T6 hook files; it was deleted and the resulting empty `.codex/state` directory was removed.
- `.codex/state` exists after cleanup: false.
- `git diff --check`: PASS, exit 0. Git emitted only the existing line-ending advisory for `testResults.xml`; no whitespace error was reported.
- Enforceability ledger row G16 remains `DEGRADED`. The native hook supplies one bounded continuation and root refusal; the separately planned required CI gate remains the hard-rejection backstop.

## Result

`[P4-T6]` acceptance is verified: invalid output can trigger at most one continuation, repeated continuation loops are prevented, and root completion remains denied until the full shared transition and immutable receipt validation passes.
