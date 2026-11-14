# Self-Review (issue #1163, P8-T8), first walk

Timestamp: 2026-11-13T13-53
Command: walk of docs/features/templates/policy_audit/policy-audit.yyyy-MM-ddTHH-mm.md, code-review.yyyy-MM-ddTHH-mm.md, and feature-audit.yyyy-MM-ddTHH-mm.md against `git diff <merge base of origin/main and HEAD> HEAD` (117 paths) at the head that carries the P8-T7 commit
EXIT_CODE: 1
ExpectedExitCode: 0
Output Summary: First walk. Two FAIL rows, both of one class: a catch block added by this branch discards the error with no context (`Resolve-AgentTargetWorktree` working-directory leg in `.claude/lib/worktree-resolution/AgentTargetWorktree.psm1` and its Codex twin; `Get-DocsCompleteGateReceiptRoot` in `.claude/hooks/enforce-docs-complete-gate.ps1`). Every other checklist row is PASS or N/A, and AC-1 to AC-33 are PASS on the evidence of the 2026-11-12 final QA loop. Per the task text the FAIL rows are fixed (evidence/other/task-check.P8-T8.2026-11-13T13-53.md), the QA loop from P8-T1 is re-run, and a new self-review file is written; this file stays as the record of the walk that found them.

## FAIL rows

| Template | Item | Status | Evidence |
|---|---|---|---|
| policy-audit 3B.2 / code-review Error handling | Error handling (Use Write-Error/throw; no silent catch-alls; `general-code-change.md` Error Handling and Logging) | FAIL | `Resolve-AgentTargetWorktree`, working-directory leg: `catch { $roots = @() }` drops the worktree-list exception, and the result's `Detail` then reports "inside no live registered worktree", which misstates the cause. `Resolve-HookTargetWorktree` records "the worktree list failed: <message>" for the same failure. Same text in `.codex/hooks/agent-target-worktree.ps1`. |
| policy-audit 3B.2 / code-review Error handling | Error handling (same rule) | FAIL | `Get-DocsCompleteGateReceiptRoot`: `catch { return $RepositoryRoot }` drops the resolver exception; the file-size hooks on this branch record the same kind of fallback with `Write-Verbose` and the exception message. The fallback decision is correct (spec D8); only the context is missing. |

The remaining rows of the walk are recorded in full in the self-review file written after the re-run QA loop; at this walk they had the same status as recorded there, except these two rows.
