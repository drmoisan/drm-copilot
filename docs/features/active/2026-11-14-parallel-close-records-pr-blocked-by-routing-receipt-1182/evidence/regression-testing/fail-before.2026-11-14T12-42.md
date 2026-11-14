# Fail-Before Evidence: Parallel Records Legs (AC-18)

Timestamp: 2026-11-14T12-42
Command: sh SCRATCH/issue-1182-phasegate.sh p1b (one Invoke-PoshQCParallelTest run of the [P1-T2] phase gate, started 2026-11-14T12-18, against the unfixed hooks)
EXIT_CODE: 1
ExpectedExitCode: 1
Output Summary:
- Source: the shard JUnit files under artifacts/pester/parallel/ of the [P1-T2] gate run (copied to SCRATCH/shards-p1b/ right after the run). No production file of Phase 2 had changed when the run started or when this file was written: .claude/hooks/enforce-model-routing-receipt.ps1 and .claude/hooks/enforce-orchestration-preimplementation-gate.ps1 are unchanged from the merge base, and none of the three new hook files exists yet.
- The runner is the parallel test runner (Invoke-PoshQCParallelTest, 8 workers); no serial or single-process run was used.
- tests/scripts/claude-hooks/enforce-model-routing-receipt.ParallelRecords.Tests.ps1 :: "AC-1 allows Agent(pr-author) for a closed parallel run with a valid pr-author receipt" received the generic MODEL_ROUTING_RECEIPT_BLOCKED deny. Failure message: "Expected strings to be the same, because reason: MODEL_ROUTING_RECEIPT_BLOCKED: cannot delegate to 'pr-author' before a model_routing_receipts entry for it is recorded in the orchestrator checkpoint. Perform Model Selection (record the complexity assessment and routing receipt) before delegating., but they were different. Expected: 'allow' But was: 'deny'"
- tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.ParallelRecords.Tests.ps1 :: "AC-9 allows the receipt Write by relative path at a closed parallel coordinator root" received PREIMPLEMENTATION_GATE_BLOCKED. Failure message: "Expected strings to be the same, because reason: PREIMPLEMENTATION_GATE_BLOCKED: Implementation operations require artifacts/orchestration/orchestrator-state.json to contain issue number, feature folder, route metadata, lifecycle readiness, and checkpoint state before implementation begins., but they were different. Expected: 'allow' But was: 'deny'"
- tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.ParallelRecords.Tests.ps1 :: "AC-9 allows the receipt Write by absolute path at a closed parallel coordinator root" received PREIMPLEMENTATION_GATE_BLOCKED with the same failure message as the relative row.
- Both suites' "baseline mock interception probe" rows passed, so the failures are deny decisions and not mock or discovery errors.
- This file is written once and is never rewritten.
