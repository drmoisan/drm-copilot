# Fail-Before Regression Run (Issue #1026) [expect-fail]

Timestamp: 2026-11-03T12-59
Command: sh SCRATCH/issue-1026-regression.sh
EXIT_CODE: 1
ExpectedExitCode: 1
Output Summary: every cleanup call C1-C7 is denied and every control D1-D3 is denied on the unmodified branch hooks, so the script exits 1. Each denial is the final deny of its gate, which shows the failure comes from the missing cleanup legs and not from a resolution error or a script defect.

Setup (in-memory, no file written): the program dot-sources the branch copies of `.claude/hooks/enforce-orchestration-preimplementation-gate.ps1`, `.claude/hooks/enforce-model-routing-receipt.ps1`, and `.claude/hooks/enforce-pr-author-skill.ps1` in separate child scopes, then redefines the seams after the dot-source: `Get-OrchestrationGateWorktreeList` (main worktree at the session root on `main`, `/synthetic-worktrees/documentationandmemories` on `documentationandmemories`, `/synthetic-worktrees/bug-example` on `bug/example`), `Get-CheckpointContent` (empty), `Get-OrchestrationEpicScopeDecision` (`$null`), `Get-OrchestrationGateTemporaryRoot` (`/synthetic-temp/`), `Get-OrchestrationGateStagedIndex` (exit 0, two allowlisted NUL-terminated paths), `Resolve-EpicScopeCheckpoint` (not epic scope), `Resolve-ModelRoutingWorktreeTarget`, `Get-ModelRoutingCheckpoint` (`$null`), `Resolve-PrAuthorWorktreeTarget`, `Get-PrContextArtifactExistence`, `Invoke-OrchestratorStatePreflight` (errors), `Invoke-PrAuthorDocsOnlyGitExe` (commit resolves; diff lists `docs/research/y.md` and `.claude/agent-memory/x/y.md`), the receipt seams (matching hash, number 7, created after the summary), and `Get-CleanupWorktreeManifestContent` / `Get-CleanupWorktreeManifestUtcNow` (fresh valid manifest).

Output:

```
C1 reason: PREIMPLEMENTATION_GATE_BLOCKED: Implementation operations re
C2 reason: PREIMPLEMENTATION_GATE_BLOCKED: Implementation operations re
C3 reason: PREIMPLEMENTATION_GATE_BLOCKED: Implementation operations re
C4 reason: PREIMPLEMENTATION_GATE_BLOCKED: Implementation operations re
C5 reason: PREIMPLEMENTATION_GATE_BLOCKED: Implementation operations re
D1 reason: PREIMPLEMENTATION_GATE_BLOCKED: Implementation operations re
D2 reason: PREIMPLEMENTATION_GATE_BLOCKED: Implementation operations re
C6 reason: MODEL_ROUTING_RECEIPT_BLOCKED: cannot delegate to 'pr-author
D3 reason: MODEL_ROUTING_RECEIPT_BLOCKED: cannot delegate to 'pr-author
C7 reason: ORCHESTRATOR_STATE_PREFLIGHT_FAILED: checkpoint missing at /synthetic-worktrees/documentationandmemories/artifacts/orchestration/orchestrator-state.json (docs-only exemption not applied: DOCS_ONLY_EXEMPTION_NON_DOCS_PATH: '.claude/agent-memory/x/y.md' is outside docs/.)
C1|deny
C2|deny
C3|deny
C4|deny
C5|deny
D1|deny
D2|deny
C6|deny
D3|deny
C7|deny
```

| Call | Description | Result |
|---|---|---|
| C1 | manifest Write at the session root with valid content | deny |
| C2 | scratch `.ps1` Write under the temporary root | deny |
| C3 | `git -C <consolidation root> add -- docs/research/y.md .claude/agent-memory/x/y.md` | deny |
| C4 | `git -C <consolidation root> commit -F <file>` with an allowlisted staged index | deny |
| C5 | receipt Write `<consolidation root>/artifacts/pr_body_7.receipt.json` | deny |
| C6 | `Agent(pr-author)` with `branch: documentationandmemories` | deny |
| C7 | `Get-PrAuthorBypassReason` for `gh pr create --head documentationandmemories --base main --body-file <absolute body>` | deny |
| D1 | the C3 command against the feature worktree | deny |
| D2 | a `.ps1` Write inside the feature worktree | deny |
| D3 | `Agent(pr-author)` with `branch: bug/example` | deny |
