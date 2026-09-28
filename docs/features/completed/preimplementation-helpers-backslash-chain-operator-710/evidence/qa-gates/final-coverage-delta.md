# Final QC: Coverage Delta (Issue #710)

Timestamp: 2026-09-27T02-41
Command: comparison of docs/features/active/preimplementation-helpers-backslash-chain-operator-710/evidence/baseline/p0-scoped-coverage.md ([P0-T6]) and docs/features/active/preimplementation-helpers-backslash-chain-operator-710/evidence/qa-gates/final-scoped-coverage.md ([P5-T4], pass 2)
EXIT_CODE: 0
Output Summary: Pass 2. .claude/hooks helpers: baseline 97.04% (164/169) to post 97.08% (166/171), changed-line coverage 100% (2 of 2). .codex/hooks helpers: baseline 97.04% (164/169) to post 97.08% (166/171), changed-line coverage 100% (2 of 2). Both post values are at least 85 and at least baseline. PowerShell has no branch-coverage gate.

Pass: 2

| Canonical copy | Baseline (covered / missed / percent) | Post (covered / missed / percent) | Delta | Changed-line coverage |
| --- | --- | --- | --- | --- |
| `.claude/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1` | 164 / 5 / 97.04 | 166 / 5 / 97.08 | +0.04 | 100 (lines 76 and 78 executed; 2 of 2) |
| `.codex/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1` | 164 / 5 / 97.04 | 166 / 5 / 97.08 | +0.04 | 100 (lines 76 and 78 executed; 2 of 2) |

Changed-line coverage is computed as executed `CHANGED_LINE` entries divided by all `CHANGED_LINE` entries, times 100, per copy.

Missed lines are 357, 406, 412, 464, 481 in both copies at baseline and post. The line numbers are identical before and after because the #710 edit has a net line delta of zero; none of them is a changed line.

Thresholds: each post percent (97.08) is at least 85 and at least its baseline (97.04). Branch coverage: not applicable; Pester does not measure branch coverage (`.claude/rules/powershell.md`, `.claude/rules/quality-tiers.md`).
