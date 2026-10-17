# Phase 4 Gate: Pester Set P4

Timestamp: 2026-10-08T18-15
Command: sh <SCRATCHPAD>/s-pester.sh P4
EXIT_CODE: 0
Output Summary:
PESTER_SET: P4 FILES=9 (set P3 plus T-INV, tests/scripts/claude-hooks/hook-command-invocation.Issue824.Tests.ps1, and T-OPS, tests/scripts/claude-hooks/hook-command-invocation-operands.Tests.ps1)
PESTER_TOTAL: 573
PESTER_PASSED: 573
PESTER_FAILED: 0
PESTER_SKIPPED: 0
PESTER_FAILED_BLOCKS: 0
PESTER_FAILED_CONTAINERS: 0
T-INV rows IV-01..IV-24 (IV-16 tagged NegativeControl) and T-OPS rows OP-01..OP-16 passed for runtime claude and runtime codex (254 executions in total, including data-driven expansions). T-SCAN and T-PAY rows passed. The existing claude and codex hook-command-invocation.Tests.ps1 files (edited by [P4-T4]/[P4-T5]) report zero failures; IV-17 confirms that no *.ps1 under .claude/hooks or .codex/hooks references the removed raw-containment helper or the old checkpoint-only contract sentence.
Failing set: empty, a subset of B_SCOPED.

Run history:
1. First P4 run (2026-10-08T18-10): PESTER_FAILED: 2, both IV-05 DepthLimit (claude, codex). Cause: a test defect. For five nested eval wrappers the first match is a NotProvenInert match on an outer eval payload record and the DepthLimit match follows it; the row asserted on match [0]. The row now asserts that every match is Indeterminate with OperandIndex -1 and exactly one carries the expected reason.
2. Second P4 run: 573 passed.
3. hook-command-invocation.ps1 was then edited to remove two ampersand-invoked local scriptblocks (see mirror-codex-invocation-phase4); this third run follows that edit and the rule 6 re-mirror.

Rule 6 mirror check: hook-command-invocation.ps1 changed after [P4-T3]; the codex-invocation group was re-run at 2026-10-08T18-14 (mirror-codex-invocation-phase4) before this run. No other shared module changed in Phase 4 after its last copy.
