# ORCH-R3 — Coverage comparison on R_final_3 (remediation cycle 2, AC-27 input)

Timestamp: 2026-10-16T21-28
Command: D-COV over powershell-coverage.xml of R_final_3 38967059138 (job poshqc / PowerShell QC); D-CHANGED with git diff -U0 fa27cd5edcb39a5d5f63054c3e38cefef18ab316 11242f03aae9b839a2a7b5d2bca37fb90594850f -- <the nine production paths> (B from ci-baseline.2026-10-16T18-58.md); docs-only baselines by D-COV from SCRATCH/issue-952-ci-38926487064/win/powershell-coverage.xml (R_base 38926487064)
EXIT_CODE: 0
Output Summary:
POWERSHELL: PASS (every file except .codex/hooks/enforce-epic-merge-gate-command.ps1); .codex/hooks/enforce-epic-merge-gate-command.ps1: ATTRIBUTION-LIMITED (issue #936 mechanism), measured 74.07/74.07, evidence codex-helper-coverage-diagnosis.2026-10-16T20-01.md
CODEX_HELPER: ATTRIBUTION-LIMITED (issue #936 mechanism)
CODEX_HELPER_LINE=74.07
CODEX_HELPER_CHANGED=74.07
REPO_PS_LINE=89.90 (covered 16724, missed 1878)
PS_BASE_CLAUDE_DOCSONLY_DIFF=97.60 PS_BASE_CODEX_DOCSONLY_DIFF=97.60
PYTHON: NOT-APPLICABLE (no production Python path in the diff)
COVERAGE_SOURCE=PRESENT

| Production path | Baseline | Post % | Changed exec lines | Covered changed | Changed-line % | Result |
|---|---|---|---|---|---|---|
| .claude/hooks/enforce-epic-merge-gate.ps1 | 99.29 | 100.00 | 4 | 4 | 100.00 | PASS |
| .claude/hooks/enforce-epic-merge-gate-command.ps1 | NEW | 100.00 | 54 | 54 | 100.00 | PASS |
| .codex/hooks/enforce-epic-merge-gate.ps1 | 88.41 | 90.20 | 4 | 4 | 100.00 | PASS |
| .codex/hooks/enforce-epic-merge-gate-command.ps1 | NEW | 74.07 | 54 | 40 | 74.07 | ATTRIBUTION-LIMITED |
| .claude/lib/ci-gate/Invoke-MergeConfirmationParser.ps1 | NEW | 100.00 | 48 | 48 | 100.00 | PASS |
| scripts/dev-tools/Invoke-FullReleaseFlow.ps1 | 94.93 | 95.07 | 5 | 5 | 100.00 | PASS |
| scripts/dev-tools/Invoke-FullReleaseFlow.MergeWait.ps1 | NEW | 100.00 | 23 | 23 | 100.00 | PASS |
| .claude/hooks/hook-docs-only-diff.ps1 | 97.60 (PS_BASE_CLAUDE_DOCSONLY_DIFF) | 97.64 | 2 | 2 | 100.00 | PASS |
| .codex/hooks/hook-docs-only-diff.ps1 | 97.60 (PS_BASE_CODEX_DOCSONLY_DIFF) | 97.64 | 2 | 2 | 100.00 | PASS |

`EXCLUDED` = [`.codex/hooks/enforce-epic-merge-gate-command.ps1`]. The Codex `hook-docs-only-diff.ps1` copy meets the thresholds directly, so it is not excluded and no `CODEX_DOCSONLY_DIFF` attribution disposition applies.

## Codex helper disposition conditions

1. CODEX_HELPER_UNCOVERED_LINES=67,68,72,165,166,171,172,179,182,183,184,185,186,189 — exactly the fourteen lines the diagnosis maps to passing rows: HOLDS.
2. ORCH-R1 recorded MAPPED_ROW_SUITES=PASS: HOLDS.
3. CLAUDE_HELPER_UNCOVERED_LINES is empty: HOLDS.

CODEX_HELPER_COVERED_LINES=23,26,29,32,45,46,47,64,65,66,70,71,86,87,88,89,90,91,93,107,108,109,111,131,132,134,135,137,158,159,160,161,162,163,164,168,169,170,174,177
CLAUDE_HELPER_COVERED_LINES=23,26,29,32,45,46,47,64,65,66,67,68,70,71,72,86,87,88,89,90,91,93,107,108,109,111,131,132,134,135,137,158,159,160,161,162,163,164,165,166,168,169,170,171,172,174,177,179,182,183,184,185,186,189
CLAUDE_HELPER_UNCOVERED_LINES=

## hook-docs-only-diff.ps1 missed sets

- R_base 38926487064 (pre-change numbering): Claude {189, 314, 358}; Codex {189, 217, 314}. CODEX_DOCSONLY_DIFF_BASE_MISSED=189,217,314.
- R_final_3 (post-change numbering): Claude {190, 315, 359}; Codex {190, 218, 315}.
- Line mapping: pre-change lines 1 to 21 keep their numbers, line 22 becomes lines 22-23, lines 23 to 370 shift by 1, the new code lines are 372-374, and lines 371 to 493 shift by 4. Under that mapping each R_final_3 missed line is the image of a baseline missed line (189 to 190, 217 to 218, 314 to 315, 358 to 359), and none of the new lines 372-374 is missed.

## CauseStatement (CR-14)

The R1 diagnosis is recorded in `evidence/regression-testing/codex-helper-coverage-diagnosis.2026-10-16T20-01.md`. Remediation-inputs R1 step 1 (a local scoped Pester coverage run) was not performed under orchestrator decision D1: the worktree-isolation guard refuses every pwsh invocation for both the orchestrator and the executor in this session, and no PowerShell tool is available.

On R_final_3 the Codex helper's credited and uncredited sets are identical to R_final_2: the fourteen uncredited lines are exactly the lines that the earliest Codex-gate loader (`tests/scripts/claude-hooks/hook-command-consumers.Issue824.Tests.ps1`, row CN-09) does not execute inside the functions it first calls. The Codex suites that do execute those lines (command 15, merge-queue 35, trigger-scoping 8; rows (g), (h) and (j) pass) run later in the same coverage run and earn no credit, while the byte-identical Claude helper is credited at 100.00. This is consistent with the issue #936 mechanism (Pester 5 breakpoint-based coverage binds each pending breakpoint to the first compiled instance of a file; a later compiled instance, after the script-block cache clears, carries no bound breakpoints), and the planner's inference that function bodies bind on first execution explains why some uncalled-function lines are credited. The mechanism has not been verified experimentally in this item.

The R_final_2 `hook-docs-only-diff.ps1` observation (byte-identical copies credited differently: Claude missed {189, 314, 358}, Codex missed {189, 217, 314}) shows that byte identity alone does not route hits to the first copy. On R_final_3 both copies keep those same misses under the line mapping above, and the new R2 lines are fully credited in both copies.

The repository-wide operator question (set `CodeCoverage.UseBreakpoints = $false` in `scripts/powershell/PoshQC/settings/pester.runsettings.psd1` and its mirror) is recorded as Record 4 of `policy-followups.md`. The disposition of the Codex helper is left to the re-audit (ORCH-R4).
