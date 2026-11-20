# Phase 0 Instructions Read (Issue #846)

Timestamp: 2026-10-09T20-55
Plan: docs/features/active/2026-10-08-bug-burndown-2026-09-29-review-nits-846/plan.2026-10-08T23-42.md
Tasks: [P0-T1], [P0-T2], [P0-T3]

Policy Order: CLAUDE.md, then general code change, then general unit test, then Python, TypeScript, and PowerShell rules (the .github/instructions canonical sources first, then the .claude/rules mirrors), then tonality and plan-acceptance-gates.

## Files read in [P0-T1] (in order, each opened in full)

1. CLAUDE.md
2. .github/copilot-instructions.md
3. .github/instructions/general-code-change.instructions.md
4. .github/instructions/general-unit-test.instructions.md
5. .github/instructions/python-code-change.instructions.md
6. .github/instructions/python-unit-test.instructions.md
7. .github/instructions/typescript-code-change.instructions.md
8. .github/instructions/typescript-unit-test.instructions.md
9. .github/instructions/powershell-code-change.instructions.md
10. .github/instructions/powershell-unit-test.instructions.md
11. .claude/rules/general-code-change.md
12. .claude/rules/general-unit-test.md
13. .claude/rules/quality-tiers.md
14. .claude/rules/python.md
15. .claude/rules/python-suppressions.md
16. .claude/rules/typescript.md
17. .claude/rules/typescript-suppressions.md
18. .claude/rules/powershell.md
19. .claude/rules/tonality.md
20. .claude/rules/plan-acceptance-gates.md

## Files read in [P0-T2] (in order, each opened in full)

21. docs/features/active/2026-10-08-bug-burndown-2026-09-29-review-nits-846/spec.md
22. docs/features/active/2026-10-08-bug-burndown-2026-09-29-review-nits-846/issue.md
23. docs/features/active/2026-10-08-bug-burndown-2026-09-29-review-nits-846/research/research.2026-10-08T23-50.md
24. .claude/skills/acceptance-criteria-tracking/SKILL.md
25. .claude/skills/evidence-and-timestamp-conventions/SKILL.md
26. .claude/skills/atomic-plan-contract/SKILL.md
27. .claude/hooks/enforce-python-batch-budget.ps1
28. .claude/hooks/enforce-powershell-batch-budget.ps1
29. .claude/hooks/enforce-promotion-mcp-only.ps1

Total files read: 29.

## Rules noted as applicable to this item

- Python: Black, Ruff, Pyright, Pytest; suppressions only per python-suppressions; full type hints; no temp files, subprocess, or sleeps in tests; coverage line >= 85% and branch >= 75%; dotted `--cov=` form with `--cov-report=term-missing`.
- TypeScript: Prettier, ESLint, tsc, Jest; `.test.ts` naming; no `any`; per-file Jest thresholds unchanged; `jest.mock` per test file.
- PowerShell: Invoke-Formatter, PSScriptAnalyzer, Pester 5 through the PoshQC MCP functions; no branch-coverage gate; test-purity rules (no `Start-Sleep` literal, `New-TemporaryFile`, `$env:TEMP`).
- General: 500-line limit per code or test file; seven-stage toolchain loop restarted from formatting on any failure or auto-fix; tests in the mirrored `tests/` tree; AAA structure.
- Tonality: professional, factual, no hyperbole or humor.
- Plan acceptance gates G1 to G9 apply to plan commands; evidence fields `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:`, optional `ExpectedExitCode:` (first occurrence wins).
- Hooks: Python batch budget counts at most 3 distinct production `.py` files in direct mode and never counts test files (enforce-python-batch-budget.ps1 line 302); PowerShell batch budget never counts `tests/**` or `*.Tests.ps1` (enforce-powershell-batch-budget.ps1 line 299); promotion hook denies unquoted `potential_to_issue`, `new_potential_bug_entry`, `new_active_feature_folder` tokens in Bash command text (quoted spans are masked).
- spec.md AC-1 through AC-40 and assumptions A1 through A9 were read.
