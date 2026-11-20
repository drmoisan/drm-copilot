# Coverage Baseline - Issue 1034 Remediation Cycle 3 (P0-T4)

Timestamp: 2026-11-07T04-47
Command: git log --diff-filter=A to find the commit that added each coverage artifact, then git diff --name-only <that commit> HEAD -- <file>
EXIT_CODE: 0
Output Summary: Each file shows an empty diff since its source artifact, so the recorded figures are carried and no Pester run was needed. `HOOK` 93.90% (77 covered, 5 missed). `HELPER` 100.00% (129 covered, 0 missed). `CLI` 89.44% (161 covered, 19 missed).

| File | Source artifact | Line coverage | Covered | Missed | Diff since the artifact |
|---|---|---|---|---|---|
| `.claude/hooks/enforce-docs-complete-gate.ps1` | `evidence/qa-gates/coverage-delta.2026-11-07T03-57.md` | 93.90% | 77 | 5 | empty |
| `.claude/hooks/enforce-docs-complete-gate-target.ps1` | `evidence/qa-gates/coverage-delta.2026-11-07T03-57.md` | 100.00% | 129 | 0 | empty |
| `.claude/lib/docs/Invoke-DocsCommand.ps1` | `evidence/qa-gates/coverage-delta.2026-11-06T12-22.md` | 89.44% | 161 | 19 | empty |
