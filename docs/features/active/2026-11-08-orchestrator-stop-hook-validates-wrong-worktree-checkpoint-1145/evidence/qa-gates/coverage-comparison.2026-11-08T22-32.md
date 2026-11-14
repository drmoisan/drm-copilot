# Coverage Comparison (issue #1145, [P4-T5], pass 1)

Timestamp: 2026-11-08T22-32
Command: compare evidence/baseline/pester-parallel.2026-11-08T21-38.md with evidence/qa-gates/pester-parallel.2026-11-08T22-26.md (figures read by SCRATCH/issue-1145-pester-summary.ps1 from artifacts/pester/powershell-coverage.xml of each run)
EXIT_CODE: 1
Output Summary:
- Result: FAIL (one per-file drop). Remediation: add a test row for the uncovered line, then re-run P4-T2 to P4-T5.

| File | Baseline (P0-T2) | Final (P4-T3) | Threshold | Result |
|---|---|---|---|---|
| `.claude/hooks/validate-orchestrator-output-target.ps1` (new) | n/a (new file) | 100% (38/38) | >= 90% | PASS |
| `.claude/hooks/validate-orchestrator-output.ps1` | 99.19% (122/123) | 99.30% (141/142) | no drop, >= 85% | PASS |
| `.claude/hooks/validate-orchestrator-output-resolution.ps1` | 98.94% (93/94) | 97.89% (93/95) | no drop, >= 85% | FAIL |
| `.claude/hooks/subagentstop-target-worktree.ps1` | 100% (92/92) | 100% (92/92) | no drop, >= 85% | PASS |
| Repo-wide | 95.67% (36347/37991) | 95.70% (36655/38300) | no drop | PASS |

- FAIL detail: the new missed line is the `else` call `Resolve-WorktreeOperandTarget -Path '' -SessionRoot $SessionRoot` in the item branch of `Resolve-OrchestratorOutputCheckpointPath`. Every existing path that reaches the item branch now supplies an item target (the hook) or mocks the resolver, so no test calls the function for `orchestrator-state` without `-ItemTarget`.
- Fix: add rows to `tests/scripts/claude-hooks/validate-orchestrator-output-target.Tests.ps1` that call `Resolve-OrchestratorOutputCheckpointPath` with and without `-ItemTarget`.
