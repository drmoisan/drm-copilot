# Final QC - Pester Gate (P3-T2)

Timestamp: 2026-11-14T21-05
Command: sh .claude/skills/test-execution-policy/scripts/run-test-suite.sh pester (launched from the item worktree root by SCRATCH/issue-1187-pester-gate.sh; Invoke-PoshQCParallelTest with coverage, 8 shard workers, integration and golden lanes excluded)
EXIT_CODE: 0
Output Summary:
- Run window 2026-11-14T21-05 to 2026-11-14T21-17 (UTC); workers=8; wall-clock=665.58s; exit code=0.
- Counts (merged artifacts/pester/pester-junit.xml): tests=26585, passed=26567, failed=0, errors=0, skipped=18.
- Coverage (artifacts/pester/powershell-coverage.xml): repo-wide 43696/45535 = 95.96%; .claude/hooks/invoke-pretooluse-dispatch.ps1 42/42 = 100.00%; .codex/hooks/invoke-pretooluse-dispatch.ps1 40/40 = 100.00%.

Comparison with the Phase 0 baseline (evidence/baseline/pester.2026-11-14T18-59.md, the greatest pester.*.md):
| Measure | Phase 0 baseline | Final gate | Result |
|---|---|---|---|
| Failed tests | 0 | 0 | no new failing test |
| Passed tests | 26504 | 26567 | +63 (61 new rows plus 2 discovery-guard rows for the new suite file) |
| Repo-wide line coverage | 43686/45525 = 95.96% | 43696/45535 = 95.96% | no drop (+10 covered lines, +10 instrumented lines) |
| .claude/hooks/invoke-pretooluse-dispatch.ps1 | 37/37 = 100.00% | 42/42 = 100.00% | at least 85%, no drop |
| .codex/hooks/invoke-pretooluse-dispatch.ps1 | 35/35 = 100.00% | 40/40 = 100.00% | at least 85%, no drop |

New reader statements: every new line of both readers is covered, including the default OpenStream line, which the row 'opens the process standard input through the default stream seam without reading it' runs (recorded as a micro-action deviation in the P1-T1 and P1-T2 task checks). The bundle copies are outside the coverage roots of config/poshqc-coverage.json.
