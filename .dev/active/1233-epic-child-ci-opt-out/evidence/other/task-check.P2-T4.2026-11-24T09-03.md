# Task check: P2-T4 (re-run after a phase-gate fix)

Timestamp: 2026-11-24T09-03
Command: see the command list below (each run from the item worktree root)
EXIT_CODE: 0
Output Summary: The first Phase 2 gate pass failed one test, `Legacy Codex hooks use native lifecycle contracts.parse-checks each root and bundled hook and keeps every file within 500 lines` in tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1, because .codex/hooks/enforce-completion-consistency.ps1 had grown from 499 to 508 lines. Both completion-consistency hooks were rewritten to a compact form with the same behavior: the ci_gate check line becomes `if (Test-CompletionChildCiIntegrationOnly ...) { local_qc_gate missing } elseif (<unchanged ci_gate condition>) {`, the head comparison carries `-not (Test-CompletionChildCiIntegrationOnly ...)`, and the reason line becomes `$reason = if (<predicate>) { <opt-out reason> } else { <unchanged pre-change reason> }`. The Codex hook now has 500 lines and the Claude hook 509. Format, lint, the bundle copies, the ledger blocks, and the restarted Phase 2 gate (every completion suite, Set H including legacy-codex-hook-contracts.Tests.ps1, and Set L) all pass.

Changed files (this fix):
- .claude/hooks/enforce-completion-consistency.ps1 and .codex/hooks/enforce-completion-consistency.ps1, and both bundle copies (byte-identical).
- .dev/engineering/process-reductions/0014-epic-child-ci-opt-out.md: the blocks of both hooks regenerated from the merge-base diff.

Commands and exit codes:
- sh SCRATCH/issue-1233-compact.sh <each hook> -> 0 (parse errors: 0; lines 500 and 509)
- sh SCRATCH/issue-1233-ps-files.sh check <both hooks> -> 0 (format drift=0 pssa findings=0)
- sh SCRATCH/issue-1233-copy.sh <hook> <bundle copy> (twice) -> 0
- sh SCRATCH/issue-1233-ledger-verify.sh -> 0 (blocks=35 files=14 problems=0)
- The test selection of this task ran inside the restarted Phase 2 gate unit stage (evidence/qa-gates/phase-gate.P2.2026-11-24T09-03.md): 2367 Pester tests, 0 failures.
