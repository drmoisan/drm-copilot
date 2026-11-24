# Coverage Delta (P4-T3)

Timestamp: 2026-11-24T09-38
Command: sh SCRATCH/issue-1234-ps.sh SCRATCH/issue-1234-pester-summary.ps1 over the final artifacts/pester/powershell-coverage.xml (copied to SCRATCH/final-pester/), and SCRATCH/issue-1234-changed-cov.ps1, which maps the added lines of `git diff -U0` from MB (the merge base of origin/main and HEAD) onto the JaCoCo line entries
EXIT_CODE: 0
Output Summary:
- Sources: baseline evidence/baseline/pester.2026-11-24T05-02.md (Phase 0 run, coverage written 2026-11-24T05-00); post-change evidence/qa-gates/pester.2026-11-24T09-35.md (final gate, coverage written 2026-11-24T09-35). Line coverage only; Pester measures no branch coverage.

| File | Baseline | Post-change | Changed-line coverage | Result |
|---|---|---|---|---|
| Repo-wide | 96.85% (47435 of 48976) | 96.87% (47655 of 49197) | n/a | no drop |
| `.claude/hooks/enforce-epic-merge-gate.ps1` | 98.64% (145 of 147) | 98.66% (147 of 149) | 3 of 3 executable added lines covered (4 added lines, one is a comment line) | no drop |
| `.codex/hooks/enforce-epic-merge-gate.ps1` | 99.45% (180 of 181) | 99.45% (182 of 183) | 3 of 3 executable added lines covered (12 added lines, 9 are header comment lines) | no drop |
| `.claude/hooks/hook-release-pull-request-context.ps1` | 100% (27 of 27) | 100% (27 of 27) | 0 executable added lines (the 5 added lines are in the .NOTES comment) | no drop |
| `.claude/hooks/enforce-epic-merge-gate-release.ps1` (new) | no pre-change run | 100% (95 of 95) | 100% | meets 85% |
| `.codex/hooks/enforce-epic-merge-gate-release.ps1` (new) | no pre-change run | 100% (95 of 95) | 100% | meets 85% |
| `.codex/hooks/hook-release-pull-request-context.ps1` (new copy) | no pre-change run | 96.3% (26 of 27) | 96.3% | meets 85% |

- Every new behavior has a named test: steps 1 to 17 and the caught error in enforce-epic-merge-gate-release.Tests.ps1 and enforce-epic-merge-gate-release.Ci.Tests.ps1 (both trees); the gate wiring in enforce-epic-merge-gate.Release.Tests.ps1 and codex-hooks/enforce-epic-merge-gate-release.Tests.ps1; parity in release-merge.Parity.Tests.ps1.
- No value is missing. Outcome: PASS.
