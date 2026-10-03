# r2 P8-T4 PowerShell coverage delta (AC-26, AC-33)

Timestamp: 2026-10-03T16-38
Command: & "$Scratch/cov-derive.ps1" -CoveragePath "$Scratch/r2-final-coverage.xml" -BaseSha 'bda1982bcb9048a22efe9ba124a2b53516e9e3c1' -Target @(COV-TARGETS-FINAL, the eight files below) -FailBelow 85; $LASTEXITCODE (step script SCRATCH/steps/r2-p8-t4.ps1)
EXIT_CODE: 0
Output Summary: GATE-FAILED=False; gating exit 0. Every pct is at least 85 and every UNCOVERED-CHANGED line prints NONE.

| File | Baseline (P0-T14) | Post-change | Changed lines uncovered |
|---|---|---|---|
| TOTAL | 85.46 (13612/2316) | 85.52 (13676 covered / 2316 missed) | n/a |
| .claude/hooks/hook-command-raw-invocation.ps1 | 100 | 100 (80/0) | NONE |
| .codex/hooks/hook-command-raw-invocation.ps1 | 100 | 100 (80/0) | NONE |
| .claude/hooks/hook-command-invocation.ps1 | 99.2 | 99.2 (124/1) | NONE |
| .codex/hooks/hook-command-invocation.ps1 | 97.6 | 97.6 (122/3) | NONE |
| .claude/hooks/enforce-epic-worktree-removal-gate.ps1 | 95.54 | 95.5 (106/5) | NONE |
| .claude/hooks/enforce-parallel-worktree-removal-gate.ps1 | 93.64 | 93.58 (102/7) | NONE |
| .codex/hooks/enforce-epic-worktree-removal-gate.ps1 | 98.59 | 98.57 (69/1) | NONE |
| scripts/dev-tools/KcovFunctionCoverageGate.ps1 | N/A - new file | 100 (63/0) | NONE (every line treated as changed) |

New/changed-code coverage: every changed executable line in CLAUDE-RAW, CODEX-RAW, and the three gates is covered; every executable line of GATE is covered; the CLAUDE-INV and CODEX-INV changes are comment lines with no executable line. The small pct decreases on the three gates (one covered line fewer each) come from the removal of the covered NoOperand allow line, not from any uncovered line. Pester measures no branch coverage, so no branch value applies to PowerShell.
Python new-code coverage: N/A - no production file of this language changes.
TypeScript new-code coverage: N/A - no production file of this language changes.
