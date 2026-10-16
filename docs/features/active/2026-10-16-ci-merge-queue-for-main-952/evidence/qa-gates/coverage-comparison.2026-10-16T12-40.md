# ORCH-6 — Coverage comparison on R_final (AC-27)

Timestamp: 2026-10-16T12-40
Command: D-COV over powershell-coverage.xml of R_final 38899600487 (job poshqc / PowerShell QC); D-CHANGED with git diff -U0 5bdf22d0f4300d2ee3a0f7e88b21fbeb69fb2dea d039138bad7010475997c09aea1b55b64e0ca9b5 -- <the seven production paths>
EXIT_CODE: 0
Output Summary:
POWERSHELL: FAIL
Cause: .codex/hooks/enforce-epic-merge-gate-command.ps1 (NEW) post 75.47 < 85.00 and changed-line 75.47 < 85.00; uncovered lines 63, 64, 68, 160, 161, 166, 173, 176-180, 183
Every other file meets the thresholds.
PYTHON: NOT-APPLICABLE (P0-T17: the only Python paths are four test-tree files under tests/, which coverage measurement excludes)
Routing: remediation (add Codex-runtime tests for the uncovered helper paths, then a new D-FINAL dispatch and a repeat of ORCH-4 to ORCH-6).

| Production path | Baseline | Post % | Changed exec lines | Covered changed | Changed-line % | Result |
|---|---|---|---|---|---|---|
| .claude/hooks/enforce-epic-merge-gate.ps1 | 99.25 (PS_BASE_CLAUDE_GATE) | 100.00 | 4 | 4 | 100.00 | PASS |
| .claude/hooks/enforce-epic-merge-gate-command.ps1 | NEW | 94.34 | 53 | 50 | 94.34 | PASS |
| .codex/hooks/enforce-epic-merge-gate.ps1 | 87.90 (PS_BASE_CODEX_GATE) | 89.73 | 4 | 4 | 100.00 | PASS |
| .codex/hooks/enforce-epic-merge-gate-command.ps1 | NEW | 75.47 | 53 | 40 | 75.47 | FAIL |
| .claude/lib/ci-gate/Invoke-MergeConfirmationParser.ps1 | NEW | 91.67 | 48 | 44 | 91.67 | PASS |
| scripts/dev-tools/Invoke-FullReleaseFlow.ps1 | 94.93 (PS_BASE_RELEASE) | 95.07 | 5 | 5 | 100.00 | PASS |
| scripts/dev-tools/Invoke-FullReleaseFlow.MergeWait.ps1 | NEW | 100.00 | 23 | 23 | 100.00 | PASS |

Uncovered changed lines (for remediation):
- .claude/hooks/enforce-epic-merge-gate-command.ps1: 68, 160, 161
- .claude/lib/ci-gate/Invoke-MergeConfirmationParser.ps1: 98, 101, 108, 128
- .codex/hooks/enforce-epic-merge-gate-command.ps1: 63, 64, 68, 160, 161, 166, 173, 176, 177, 178, 179, 180, 183 (the byte-identical twin of the Claude helper; the Codex suites do not drive the URL selector form, the `--` terminator, the `--merge=<n>` form, or the REST `pulls/<n>/merge` reader path)

Each production path matched exactly one coverage `sourcefile` entry. AC-1, AC-2, AC-5 to AC-15 and AC-27 stay unchecked until ORCH-4, ORCH-5 and ORCH-6 all pass on one R_final.
