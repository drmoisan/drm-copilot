# Final QC Loop Record

Timestamp: 2026-10-08T19-15
Command: Record of the P10-T1..P10-T14 iterations (no new command); per-task evidence is cited below.
EXIT_CODE: 0
Output Summary: Three iterations. Iteration 1 failed at P10-T5 (five PSUseOutputTypeCorrectly findings). Iteration 2 failed at P10-T11 (two non-catch uncovered changed lines in enforce-feature-folder-order.ps1). Iteration 3 is the final clean iteration: P10-T1 through P10-T14 all passed, and P10-T3 changed no file.

| Iteration | Failed or changed-file tasks | Remediation before the next iteration |
|---|---|---|
| 1 | P10-T5 failed: Findings=5, PSUseOutputTypeCorrectly on the `return @(Find-FeatureFolderCandidate ...)` delegate line in W02, W03, W04, W05, W06 (qa-gates/analyze-selfhosted.1.2026-10-08T19-50.md). P10-T1..T4 passed, and P10-T3 changed no file. P10-T6..T14 were not run in this iteration. | RESET 4 (other/batch-budget-reset-4.2026-10-08T19-51.md), then edits to W02, W03, W04; RESET 5 (other/batch-budget-reset-5.2026-10-08T19-52.md), then edits to W05, W06 (each delegate returns `[string[]]@(...)`); copy tasks P3-T2, P4-T2, P4-T7, P5-T3, P5-T5 re-run (all MATCH). |
| 2 | P10-T11 failed: enforce-feature-folder-order.ps1 uncovered changed lines 117 (the -RequiredFile default value) and 281 (the script-tail exit line, which counted as changed because of an appended trailing newline) were not catch bodies (qa-gates/coverage-changed-lines.2.2026-10-08T18-53.md). P10-T1..T10 passed (P10-T3 changed no file; P10-T5 Findings=0; P10-T9 failing set unchanged; P10-T10 all at least 85%). P10-T12..T14 were not run in this iteration. | RESET 6 (other/batch-budget-reset-6.2026-10-08T18-54.md); W07 trailing newline removed so the file ending matches the merge base; one test added to W30 for the Get-FeatureFolderMissingFile default; copy task P6-T5 re-run (MATCH). |
| 3 (final clean) | none | none |

Iteration 3 evidence (all passing, no file changed):

- P10-T1: other/batch-budget-reset-final-3.2026-10-08T18-55.md (REMAINING 0)
- P10-T2: qa-gates/format-check.3.2026-10-08T18-55.md (20 FORMAT-CLEAN)
- P10-T3: qa-gates/format-mcp.3.2026-10-08T18-56.md (HASH-LIST identical, 31 lines; RESTORED: none)
- P10-T4: qa-gates/mirror-hashes.3.2026-10-08T18-57.md (10 MATCH)
- P10-T5: qa-gates/analyze-selfhosted.3.2026-10-08T18-57.md (Findings=0)
- P10-T6: qa-gates/analyze-mcp.3.2026-10-08T18-57.md (ok=true)
- P10-T7: qa-gates/pester-mcp.3.2026-10-08T19-06.md (exit 2, same as baseline)
- P10-T8: qa-gates/pester-full-selfhosted.3.2026-10-08T19-13.md (6752 passed, 2 pre-existing failures, Covered 84.6%)
- P10-T9: qa-gates/junit-failing-set.3.2026-10-08T19-13.md (failing set identical to baseline; BlockOrContainerFailures=0)
- P10-T10: qa-gates/coverage-perfile.3.2026-10-08T19-13.md (nine rows, minimum 91.67%)
- P10-T11: qa-gates/coverage-changed-lines.3.2026-10-08T19-13.md (uncovered changed lines are catch bodies only)
- P10-T12: qa-gates/coverage-comparison.3.2026-10-08T19-13.md (nine PASS)
- P10-T13: qa-gates/pytest-bundle-contracts.3.2026-10-08T19-14.md (32 passed)
- P10-T14: qa-gates/size-purity-final.3.2026-10-08T19-15.md (29 rows at most 500; 10 + 1 PURITY-CLEAN)

Timestamp note: the iteration 1 and early iteration 2 artifact labels (19-46 to 19-59) were estimated rather than read from the clock. See other/timestamp-correction.2026-10-08T18-46.md. Every label from 18-46 onward was read from the clock.
