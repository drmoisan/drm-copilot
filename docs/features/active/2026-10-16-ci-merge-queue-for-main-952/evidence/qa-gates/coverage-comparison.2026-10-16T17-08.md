# ORCH-R3 — Coverage comparison on R_final_2 (remediation cycle 1, AC-27)

Timestamp: 2026-10-16T17-08
Command: D-COV over powershell-coverage.xml of R_final_2 38933561015 (job poshqc / PowerShell QC); D-CHANGED with git diff -U0 d72ec6a1010223f7036b9c3d15dad102ae262f98 fd1913a0d1d555959edca41289fc38ace1c5d439 -- <the seven production paths> (B from ci-baseline.2026-10-16T16-39.md)
EXIT_CODE: 0
Output Summary:
POWERSHELL: FAIL
Cause: .codex/hooks/enforce-epic-merge-gate-command.ps1 (NEW) post 74.07 < 85.00 and changed-line 74.07 < 85.00; every other file meets the thresholds
REPO_PS_LINE=89.90 (covered 16720, missed 1878)
PYTHON: NOT-APPLICABLE (no production Python path in the diff)
COVERAGE_SOURCE=PRESENT
Routing: remediation cycle 2 (see Cycle-2 input below).

| Production path | Baseline | Post % | Changed exec lines | Covered changed | Changed-line % | Result |
|---|---|---|---|---|---|---|
| .claude/hooks/enforce-epic-merge-gate.ps1 | 99.29 (PS_BASE_CLAUDE_GATE) | 100.00 | 4 | 4 | 100.00 | PASS |
| .claude/hooks/enforce-epic-merge-gate-command.ps1 | NEW | 100.00 | 54 | 54 | 100.00 | PASS |
| .codex/hooks/enforce-epic-merge-gate.ps1 | 88.41 (PS_BASE_CODEX_GATE) | 90.20 | 4 | 4 | 100.00 | PASS |
| .codex/hooks/enforce-epic-merge-gate-command.ps1 | NEW | 74.07 | 54 | 40 | 74.07 | FAIL |
| .claude/lib/ci-gate/Invoke-MergeConfirmationParser.ps1 | NEW | 100.00 | 48 | 48 | 100.00 | PASS |
| scripts/dev-tools/Invoke-FullReleaseFlow.ps1 | 94.93 (PS_BASE_RELEASE) | 95.07 | 5 | 5 | 100.00 | PASS |
| scripts/dev-tools/Invoke-FullReleaseFlow.MergeWait.ps1 | NEW | 100.00 | 23 | 23 | 100.00 | PASS |

## R1 per-line data

CODEX_HELPER_COVERED_LINES=23,26,29,32,45,46,47,64,65,66,70,71,86,87,88,89,90,91,93,107,108,109,111,131,132,134,135,137,158,159,160,161,162,163,164,168,169,170,174,177
CODEX_HELPER_UNCOVERED_LINES=67,68,72,165,166,171,172,179,182,183,184,185,186,189
CLAUDE_HELPER_COVERED_LINES=23,26,29,32,45,46,47,64,65,66,67,68,70,71,72,86,87,88,89,90,91,93,107,108,109,111,131,132,134,135,137,158,159,160,161,162,163,164,165,166,168,169,170,171,172,174,177,179,182,183,184,185,186,189
CLAUDE_HELPER_UNCOVERED_LINES=

Mapping of the thirteen cycle-1 uncovered lines to post-change numbers and their state on R_final_2 (Codex copy): 63 to 67 uncovered; 64 to 68 uncovered; 68 to 72 uncovered; 160 to 165 uncovered; 161 to 166 uncovered; 166 to 171 uncovered, plus new line 172 uncovered; 173 to 179 uncovered; 176-180 to 182-186 uncovered; 183 to 189 uncovered. The Codex covered set is the same set of statements as before this cycle (renumbered), and none of the statements reached only by this cycle's new Codex cases is credited.

## CauseStatement (CR-6)

The cycle-0 statement in `coverage-comparison.2026-10-16T12-40.md` that the Codex suites did not drive the URL selector or the REST reader path is withdrawn. As recorded in `evidence/regression-testing/codex-helper-coverage-diagnosis.*.md`, Codex in-process cases already reached helper lines 63-64 (merge-queue URL rows), 173 (trigger-scoping, authorization and merge-queue rows), 176-180 and 183 (merge-queue REST rows through the Codex gate) before this cycle; only lines 68, 160, 161 and 166 were reached by no Codex case. This cycle added a dedicated in-process Codex suite (`enforce-epic-merge-gate-command.Tests.ps1`, 15 passed) that loads the gate and the helper from fully resolved Codex paths and drives every remaining line, and row (g) confirms that the selector functions are defined by the Codex helper file (`H2=REJECTED`). Despite that, R_final_2 credits no additional Codex helper line, while the byte-identical Claude helper reaches 100.00.

The data therefore show that the gap is not explained by function resolution, by the unresolved `Join-Path` load form, or by missing test paths. The remaining explanation consistent with every observation is that, in the single coverage-enabled Pester run, executions of statements in the Codex helper are attributed to the byte-identical Claude helper, which is loaded first (claude-hooks suites run before codex-hooks suites). Pester's tracer keys hits by the executing statement's extent file (`Pester.psm1` `Start-TraceScript` and `Get-CoverageReport`), so if PowerShell reuses compiled statement data across two files with identical text, every hit lands on the first-compiled copy. This is a hypothesis; it has not been verified directly.

## Cycle-2 input

- The specification does not require the Claude and Codex helpers to be byte-identical to each other: `spec.md` requires byte-identical bundle mirrors (AC-20) and one helper per runtime (Design item 2, AC-5). Twin identity was a plan design decision (main plan `## Scope Recap` item 2).
- A discriminating and remedial change is to make the Codex helper's text differ from the Claude helper's text (for example, a runtime-specific header line) while keeping its executable statements identical, keeping each helper byte-identical to its own bundle mirror, and updating any comment or test that asserts twin identity. If the attribution hypothesis holds, the next dispatched run credits the Codex suites' executions to the Codex copy; if it does not, the per-line data above remain the cycle-3 input.
- Row (g) PASS, row (j) PASS, and the new suite's Passed count 15 are recorded in `ci-rows-windows.2026-10-16T17-08.md`.

AC-1, AC-2, AC-5 to AC-15 and AC-27 stay unchecked until ORCH-R1, ORCH-R2 and ORCH-R3 pass on one run.
