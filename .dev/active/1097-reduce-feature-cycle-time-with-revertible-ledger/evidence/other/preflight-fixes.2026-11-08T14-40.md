Timestamp: 2026-11-08T14-40
Plan: docs/features/active/reduce-feature-cycle-time-with-revertible-ledger-1097/plan.2026-11-07T22-28.md

Fixes (task text only; no task added, removed, or reordered):

1. Design Summary, quoted bullet: ungrammatical clause "widens the substantive class an acceptance criterion with no implementing task" replaced by "extends the substantive class that already holds an acceptance criterion with no implementing task".
2. P1-T1: placement stated precisely. The Claude copies carry a "Check the fix against its own rule" bullet between the "Return substantive defects only" bullet and "Output format."; the new bullet goes directly after the "Return substantive" bullet in every copy.
3. P1-T5: placement of the new discovery data and It blocks stated, so no line falls inside the two entry 0008 hunks recorded for this file (the PlannerAgent block and the PCW-SIZE-GUIDELINE and PCW-SIZE-AGENT blocks), which the ledger chain test applies in reverse.
4. Existing Tests That Pin Changed Text: added the dispositions of five tests that name the edited files and were missing (less-evidence-contract, light-remediation-skill-contract, test_scratch_location_contracts, test_typescript_toolchain_instruction_contracts, claude-architecture-doc), each unchanged because unaffected.
5. P2-T4: "H1 and H2 of the AC mapping" replaced by "the two [H] criteria of spec.md" (spec.md carries no H1 or H2 labels).

Checks that found no defect: six contract copies (frontmatter search) and three distinct texts; ledger regions (entries 0003, 0008, 0009 hunks and blocks lie outside the insertion points; the chain applies hunks by content, so line offsets are tolerated); plan size 12 tasks and under 250 lines under the Python CLI; Phase 0 restored baseline with one parallel run per gate and final comparison in P2-T2 and P2-T3.
