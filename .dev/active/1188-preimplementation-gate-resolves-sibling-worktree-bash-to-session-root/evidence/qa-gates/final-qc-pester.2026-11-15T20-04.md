# Final QC - Pester gate with coverage (P2-T2, remediation cycle 1)

Timestamp: 2026-11-15T20-03
Command: sh .claude/skills/test-execution-policy/scripts/run-test-suite.sh pester
EXIT_CODE: 0
Output Summary: Invoke-PoshQCParallelTest, 8 workers, wall-clock 706.99 s, ExitCode 0. Merged JUnit (artifacts/pester/pester-junit.xml): 27268 tests, 0 failed, 18 skipped. Repo-wide line coverage 96.05% (44697 covered, 1839 missed) against the Phase 0 baseline 95.96% (26522 tests, 0 failures): no new failing test, no repo-wide drop. Both classify-sibling copies 100% (new files, at least 85%). Every changed executable line of the five named files has `ci` above 0.

Plan: remediation-plan.2026-11-14T23-56.md
Phase 0 baseline: evidence/baseline/pester-gate.2026-11-14T21-02.md (the lexicographically greatest `pester-gate.*.md`).

Run notes: the first five launcher attempts exited 75 (`TEST_EXECUTION_QUEUE_TIMEOUT:`, lock held by other worktrees); they are queue timeouts, not failures. The sixth attempt is the run above. The Phase 1 commit is the tested head (`git status --porcelain` empty apart from evidence written after the run).

## Per-file line coverage (artifacts/pester/powershell-coverage.xml, JaCoCo LINE counters)

| File | Covered/Total | This run | Phase 0 baseline | Verdict |
|---|---|---|---|---|
| `.claude/hooks/enforce-orchestration-preimplementation-gate-classify.ps1` | 51/51 | 100% | N/A - new file | PASS (at least 85%) |
| `.codex/hooks/enforce-orchestration-preimplementation-gate-classify.ps1` | 51/51 | 100% | N/A - new file | PASS (at least 85%) |
| `.claude/hooks/enforce-orchestration-preimplementation-gate-operands.ps1` | 154/154 | 100% | N/A - no pre-change per-file figure | PASS (at least 85%) |
| `.codex/hooks/enforce-orchestration-preimplementation-gate-operands.ps1` | 154/154 | 100% | N/A - no pre-change per-file figure | PASS (at least 85%) |
| `.claude/hooks/enforce-orchestration-preimplementation-gate-epic-scope.ps1` | 133/136 | 97.79% | 97.73% | PASS (no drop) |
| `.codex/hooks/enforce-orchestration-preimplementation-gate-epic-scope.ps1` | 154/157 | 98.09% | 98.01% | PASS (no drop) |
| `.claude/hooks/enforce-orchestration-preimplementation-gate.ps1` | 169/175 | 96.57% | N/A - no pre-change per-file figure | PASS (at least 85%) |
| `.codex/hooks/enforce-orchestration-preimplementation-gate.ps1` | 180/180 | 100% | N/A - no pre-change per-file figure | PASS (at least 85%) |

## Changed-lines condition

New-side line numbers were derived from the `@@` hunk headers of `git diff -U0 <merge-base of origin/main and HEAD> HEAD` per file (helper `artifacts/scratch-issue-1188/changed-lines.ps1`); each number that has a `line` element in this run's coverage XML is listed as `line:ci`.

- `.claude/hooks/enforce-orchestration-preimplementation-gate.ps1`: 3 changed, 3 executable, 0 at zero: `44:3` (classify dot-source), `160:2` (supplement call), `163:6` (extended stage-1 condition).
- `.codex/hooks/enforce-orchestration-preimplementation-gate.ps1`: 3 changed, 3 executable, 0 at zero: `39:3` (classify dot-source), `172:2` (supplement call), `175:6` (extended stage-1 condition). The removed `Get-OrchestrationModeDenyReason` block has no new-side lines.
- `.codex/hooks/enforce-orchestration-preimplementation-gate-epic-scope.ps1`: 25 changed (first cycle plus the moved block), 7 executable, 0 at zero: `52:2 250:4 251:1 252:5 259:2 487:1 488:2`; `487` and `488` are the moved `Get-OrchestrationModeDenyReason` body.
- `.claude/hooks/enforce-orchestration-preimplementation-gate-operands.ps1`: new against the merge base, 296 changed, 154 executable, 0 at zero; the option-value skip line `179:2` is included.
- `.codex/hooks/enforce-orchestration-preimplementation-gate-operands.ps1`: same as the Claude copy (byte-identical), 154 executable, 0 at zero, `179:2` included.

ZERO_TOTAL=0, so no changed executable line is uncovered; the verdict is PASS.
