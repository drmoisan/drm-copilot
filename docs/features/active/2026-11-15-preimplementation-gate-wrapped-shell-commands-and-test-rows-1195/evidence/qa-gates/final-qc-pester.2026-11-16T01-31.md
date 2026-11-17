# Final-QC Pester Gate (P3-T2)

Timestamp: 2026-11-16T01-31
Command: sh .claude/skills/test-execution-policy/scripts/run-test-suite.sh pester (one Invoke-PoshQCParallelTest, coverage enabled, integration and golden lanes excluded; launched from SCRATCH/issue-1195-gate.sh with the worktree as cwd); counts and coverage read by SCRATCH/issue-1195-report.ps1; added lines from git diff -U0 MB HEAD of the classify sibling (MB = merge base of origin/main and HEAD)
EXIT_CODE: 0
Output Summary:
- Run: started 2026-11-16T01-20, ended 2026-11-16T01-31; 8 shards, wall-clock 663.51 s, exit code 0; merged JUnit and coverage written.
- artifacts/pester/pester-junit.xml: 27484 tests, 27466 passed, 0 failed, 0 errors, 18 skipped (zero failing tests; Phase 0 baseline had 0 failures, so no new failing test).
- Coverage comparison with the Phase 0 baseline (evidence/baseline/pester-gate.2026-11-15T23-35.md):

| File | Phase 0 baseline | Final | Change |
|---|---|---|---|
| Repo-wide line coverage | 44785/46631, 96.04% | 44855/46701, 96.05% | no drop |
| .claude/hooks/enforce-orchestration-preimplementation-gate-classify.ps1 | 61/61, 100.00% | 96/96, 100.00% | no drop; at or above 85% |
| .codex/hooks/enforce-orchestration-preimplementation-gate-classify.ps1 | 61/61, 100.00% | 96/96, 100.00% | no drop |
| .claude/hooks/enforce-orchestration-preimplementation-gate.ps1 | 169/175, 96.57% | 169/175, 96.57% | no drop |
| .codex/hooks/enforce-orchestration-preimplementation-gate.ps1 | 180/180, 100.00% | 180/180, 100.00% | no drop |

- Added lines of the classify sibling against MB: hunks at new lines 27-38 and 41-43 (comment-based help) and 148-223 (the two new functions). The coverage report lists no zero-hit line for the file, so every added executable line (35 new executable lines: 96 - 61) has a hit count above zero (AC-18).
- The changed supplementalIndex line of each gate is covered (it is not among the Claude gate's six zero-hit lines, which are the same six as in the Phase 0 baseline; the Codex gate has none).
- The bundle copies of the classify sibling and gates are not in the measured population; they are byte-identical to the measured sources.
