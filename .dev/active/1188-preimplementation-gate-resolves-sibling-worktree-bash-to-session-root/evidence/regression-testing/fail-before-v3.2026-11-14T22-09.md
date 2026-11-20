# Fail-before proof for the revised V3 row (P2-T3 micro-action)

Timestamp: 2026-11-14T22-07
Command: sh SCRATCH/archive-p1/.claude/skills/test-execution-policy/scripts/run-test-suite.sh pester -TestPath SCRATCH/archive-p1/tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-operands.Tests.ps1 SCRATCH/archive-p1/tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-operands.Tests.ps1
EXIT_CODE: 1
ExpectedExitCode: 1
Output Summary: SCRATCH/archive-p1 is a git archive of the Phase 1 commit (unmodified hooks, no operands sibling) with the revised Cases table copied in. On both surfaces the revised row `V3 npm --prefix quoted substitution` (`npm --prefix "$(pwd)" run lint`, ready session-root checkpoint) fails: expected deny, observed allow. The new control `V3 npm --prefix unquoted substitution is unclassified control` passes before the fix, as it does after.

## Why the V3 row changed

The P2-T3 task check showed the original V3 command `npm --prefix $(pwd) run lint` allowed after the fix. A probe showed that both gates' `Test-ImplementationCommand` return False for it: stage 1 matches, and stage 2 (`Test-OrchestrationGateInvocationConfirmed`) drops the hit, so the command is unclassified and never reaches target resolution. Classification is a non-goal of this item (spec `## Scope & Non-Goals`), so the unquoted form cannot deny without changing classification. The V3 gate row therefore uses the classified quoted form `npm --prefix "$(pwd)" run lint`, which carries the same intent (a substitution selector denies `TARGET_WORKTREE_NOT_DERIVABLE` with no checkpoint read and no listing call). A control row pins the unquoted form as unclassified (allow, zero reads, zero listing calls), and G rows cover both forms (each Unresolved). The original fail-before run (fail-before.2026-11-14T21-26.md) recorded V3 failing for the unquoted form; that failure came from the expected deny, not from target resolution.

Finding for follow-up (outside this item's scope): stage 2 drops the stage-1 hit for `npm --prefix $(pwd) run lint`, an ordinary invocation whose script word sits after an unquoted command substitution.
