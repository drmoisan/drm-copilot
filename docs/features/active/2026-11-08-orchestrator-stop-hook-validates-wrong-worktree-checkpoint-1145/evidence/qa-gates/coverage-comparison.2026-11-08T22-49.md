# Coverage Comparison (issue #1145, [P4-T5], pass 2)

Timestamp: 2026-11-08T22-49
Command: compare evidence/baseline/pester-parallel.2026-11-08T21-38.md with evidence/qa-gates/pester-parallel.2026-11-08T22-44.md (the greatest pester-parallel.*.md of each folder; figures read by SCRATCH/issue-1145-pester-summary.ps1 from artifacts/pester/powershell-coverage.xml of each run)
EXIT_CODE: 0
Output Summary:
- Result: PASS. Every row meets its threshold and no file or the repo total drops. Pass 1 (`coverage-comparison.2026-11-08T22-32.md`) recorded a drop in the resolution sibling; two rows were added to `tests/scripts/claude-hooks/validate-orchestrator-output-target.Tests.ps1`, and P4-T2 to P4-T5 were re-run.

| File | Baseline (P0-T2) | Final (P4-T3 re-run) | Threshold | Result |
|---|---|---|---|---|
| `.claude/hooks/validate-orchestrator-output-target.ps1` (new) | n/a (new file) | 100% (38/38) | >= 90% | PASS |
| `.claude/hooks/validate-orchestrator-output.ps1` | 99.19% (122/123) | 99.30% (141/142) | no drop, >= 85% | PASS |
| `.claude/hooks/validate-orchestrator-output-resolution.ps1` | 98.94% (93/94) | 98.95% (94/95) | no drop, >= 85% | PASS |
| `.claude/hooks/subagentstop-target-worktree.ps1` | 100% (92/92) | 100% (92/92) | no drop, >= 85% | PASS |
| Repo-wide | 95.67% (36347/37991) | 95.71% (36656/38300) | no drop | PASS |

- New and changed code: the new sibling is fully covered; the changed lines of the main hook and the resolution sibling are covered (the one missed line of each file is unchanged code: the main hook's missed line is in `Test-HumanInteractionShape`, as in P0-T2, and the resolution sibling's is in `Test-OrchestratorOutputCheckpointLeafShape`).
- Python: no Python file changed; pytest totals are not below P0-T3 (`pytest-parallel.2026-11-08T22-49.md`).
