# Issue 1026 reproduction: PR-leg blockers found by research

Timestamp: 2026-11-03T12-12
Command: sh SCRATCH/issue-1026-repro2.sh (dot-sources .claude/hooks/enforce-orchestration-preimplementation-gate.ps1 and .claude/hooks/enforce-model-routing-receipt.ps1 from this branch; calls Invoke-OrchestrationPreimplementationGateDecision with -CheckpointRaw '{}', and Invoke-ModelRoutingReceiptDecision with Get-ModelRoutingTargetCheckpointResolution overridden to name a checkpoint path that does not exist)
EXIT_CODE: 0
Output Summary: both blockers inferred in research/research.2026-11-03T12-06.md (Open Question 1) reproduce: the pr-author receipt Write and the Agent(pr-author) delegation are denied when the consolidation worktree has no checkpoint.

## Results

| Operation | Decision | Hook file and function |
|---|---|---|
| Write `<worktree>/artifacts/pr_body_7.receipt.json` | deny, `PREIMPLEMENTATION_GATE_BLOCKED` | `.claude/hooks/enforce-orchestration-preimplementation-gate.ps1`, `Test-ImplementationPath` (`.json` leg) |
| Write `<worktree>/artifacts/pr_body_7.md` | allow | `.md` is not an implementation extension |
| `Agent(pr-author)` with `branch: documentationandmemories`, resolved worktree without checkpoint | deny, `MODEL_ROUTING_RECEIPT_BLOCKED: cannot delegate to 'pr-author' before a model_routing_receipts entry for it is recorded in the orchestrator checkpoint.` | `.claude/hooks/enforce-model-routing-receipt.ps1`, `Invoke-ModelRoutingReceiptDecision` via `Test-ModelRoutingReceiptPresent` |

## Other facts measured for the spec

- `[System.IO.Path]::GetTempPath()` on the host returns the long-name form of the user temporary directory, while the session scratchpad path supplied to the Write tool uses the 8.3 short-name form of the same directory. A temporary-root comparison must accept both spellings.
- `git ls-files -- .claude/agent-memory` lists zero files: the directory is gitignored in this repository.
