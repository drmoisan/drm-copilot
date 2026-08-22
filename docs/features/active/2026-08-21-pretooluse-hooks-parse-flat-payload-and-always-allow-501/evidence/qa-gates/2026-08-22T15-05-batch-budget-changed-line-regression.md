Timestamp: 2026-08-22T15-05
Command: git diff -U0 fb30a9a5..HEAD -- .claude/hooks/enforce-powershell-batch-budget.ps1 .claude/hooks/enforce-python-batch-budget.ps1
EXIT_CODE: 0
Output Summary:

This command diffs the two named commits only; it does not include this cycle's uncommitted Phase 1 working-tree edits. The changed (added, "+") line-number set it reports is therefore expressed in the committed (pre-remediation) file's own line numbering, which is identical to the current working-tree file's numbering for every line above the entry-point tail (this cycle's edit only replaced the tail, from the dot-source guard through the former `exit 0`; nothing above it moved).

Changed-line set (added-line numbers from the diff hunks):
- `enforce-powershell-batch-budget.ps1`: {40, 41, 170, 171, 172, 173, 174, 175, 178, 235}
- `enforce-python-batch-budget.ps1`: {37, 38, 167, 168, 169, 170, 171, 172, 175, 232}

P2-T1 missed-line set (from `artifacts/pester/powershell-coverage.xml`, current working tree, post-fix):
- `enforce-powershell-batch-budget.ps1`: {279, 280, 281, 284}
- `enforce-python-batch-budget.ps1`: {276, 277, 278, 281}

Intersection:
- `enforce-powershell-batch-budget.ps1`: {40,41,170-175,178,235} ∩ {279,280,281,284} = EMPTY
- `enforce-python-batch-budget.ps1`: {37,38,167-172,175,232} ∩ {276,277,278,281} = EMPTY

Both intersections are empty. Note on line 235 / 232: these are the single previously-committed lines the Blocking finding traced the regression to (`$decision = Invoke-...Hook -ToolInputRaw (Read-ClaudeHookRawPayload) ...`). That exact statement no longer exists at a fixed top-level position in the current working tree — Phase 1 (P1-T2/P1-T3) moved the equivalent statement inside the new `Invoke-<Name>BatchBudgetEntryPoint` function body, where it is exercised by the seam-driven tests added in P1-T5/P1-T6 (confirmed covered: the function's class-level LINE counter for `enforce-powershell-batch-budget.ps1` is missed=0, covered=17; for `enforce-python-batch-budget.ps1` is missed=0, covered=17). The 4 lines still missed in each file (279-284 / 276-281) are the un-dot-sourced top-level wiring block only, matching the same structural gap already present and accepted in the ten precedent hooks.
