# Coverage Comparison ([P10-T4], AC-24)

Timestamp: 2026-10-10T05-58
Command: <SCRATCHPAD>/p10t4.ps1. For each W-CHANGED-PROD file it records the [P0-T16] baseline (evidence/baseline/p0-pester-coverage.md), the [P10-T3] post value, the R-CHANGED-LINES counts, and the section 5 no-regression rule (met when post percent >= baseline percent or post missed <= baseline missed).
EXIT_CODE: 0
Output Summary: 57 files, 3 of them new (NO-REGRESSION n/a). 49 present files meet the no-regression rule. Five do not:
- .codex/hooks/enforce-epic-child-worktree-binding.ps1: 95.62 -> 74.70
- .codex/hooks/enforce-epic-merge-gate.ps1: 98.68 -> 98.09 (missed 2 -> 3)
- .codex/hooks/enforce-epic-planning-only.ps1: 95.71 -> 82.25
- .codex/hooks/enforce-orchestration-preimplementation-gate.ps1: 100.00 -> 86.55
- .codex/hooks/validate-bash.ps1: 100.00 -> 80.25

Four POST values are below 85.00 (see p10-coverage-pass2.md). KNOWN-UNCOVERED: none.

ACCEPTANCE-GAP: every POST must be at least 85.00 and every NO-REGRESSION must read met or n/a; neither holds. The regressions are on Codex files whose covering tests pass, and which folder-scoped runs report as covered. The full-run tracer attribution problem is described in p10-coverage-pass2.md and deviations.md ([P10-T3]). [P10-T4] is left unchecked and escalated.

```text
FILE: .claude/hooks/check-powershell-test-purity.ps1
  BASELINE: 92.73 (missed=4)
  POST: 93.44 (missed=4)
  CHANGED-LINES: covered=7 | total=7
  NO-REGRESSION: met
FILE: .claude/hooks/check-python-test-purity.ps1
  BASELINE: 93.33 (missed=4)
  POST: 93.94 (missed=4)
  CHANGED-LINES: covered=7 | total=7
  NO-REGRESSION: met
FILE: .claude/hooks/enforce-checkpoint-monotonic.ps1
  BASELINE: 95.74 (missed=4)
  POST: 96.00 (missed=4)
  CHANGED-LINES: covered=7 | total=7
  NO-REGRESSION: met
FILE: .claude/hooks/enforce-completion-consistency.ps1
  BASELINE: 93.62 (missed=9)
  POST: 93.84 (missed=9)
  CHANGED-LINES: covered=8 | total=8
  NO-REGRESSION: met
FILE: .claude/hooks/enforce-discovery-artifact-gate.ps1
  BASELINE: 95.16 (missed=3)
  POST: 95.65 (missed=3)
  CHANGED-LINES: covered=8 | total=8
  NO-REGRESSION: met
FILE: .claude/hooks/enforce-epic-invocation-origin.ps1
  BASELINE: 89.55 (missed=7)
  POST: 90.41 (missed=7)
  CHANGED-LINES: covered=7 | total=7
  NO-REGRESSION: met
FILE: .claude/hooks/enforce-epic-merge-gate-resolution.ps1
  BASELINE: 90.00 (missed=5)
  POST: 95.24 (missed=2)
  CHANGED-LINES: covered=2 | total=2
  NO-REGRESSION: met
FILE: .claude/hooks/enforce-epic-merge-gate.ps1
  BASELINE: 96.15 (missed=5)
  POST: 99.25 (missed=1)
  CHANGED-LINES: covered=12 | total=12
  NO-REGRESSION: met
FILE: .claude/hooks/enforce-epic-wave-barrier.ps1
  BASELINE: 96.70 (missed=3)
  POST: 98.96 (missed=1)
  CHANGED-LINES: covered=8 | total=8
  NO-REGRESSION: met
FILE: .claude/hooks/enforce-epic-worktree-removal-gate-resolution.ps1
  BASELINE: 96.49 (missed=2)
  POST: 98.04 (missed=1)
  CHANGED-LINES: covered=1 | total=1
  NO-REGRESSION: met
FILE: .claude/hooks/enforce-epic-worktree-removal-gate.ps1
  BASELINE: 96.43 (missed=4)
  POST: 96.52 (missed=4)
  CHANGED-LINES: covered=11 | total=11
  NO-REGRESSION: met
FILE: .claude/hooks/enforce-evidence-locations.ps1
  BASELINE: 90.00 (missed=4)
  POST: 91.30 (missed=4)
  CHANGED-LINES: covered=7 | total=7
  NO-REGRESSION: met
FILE: .claude/hooks/enforce-feature-folder-order.ps1
  BASELINE: 91.67 (missed=5)
  POST: 93.94 (missed=4)
  CHANGED-LINES: covered=7 | total=7
  NO-REGRESSION: met
FILE: .claude/hooks/enforce-mermaid-validation.ps1
  BASELINE: 92.41 (missed=6)
  POST: 94.12 (missed=5)
  CHANGED-LINES: covered=7 | total=7
  NO-REGRESSION: met
FILE: .claude/hooks/enforce-model-routing-receipt.ps1
  BASELINE: 95.52 (missed=3)
  POST: 95.89 (missed=3)
  CHANGED-LINES: covered=9 | total=9
  NO-REGRESSION: met
FILE: .claude/hooks/enforce-orchestration-preimplementation-gate-epic-scope.ps1
  BASELINE: 98.72 (missed=1)
  POST: 98.63 (missed=1)
  CHANGED-LINES: covered=4 | total=4
  NO-REGRESSION: met
FILE: .claude/hooks/enforce-orchestration-preimplementation-gate.ps1
  BASELINE: 96.75 (missed=5)
  POST: 96.86 (missed=5)
  CHANGED-LINES: covered=12 | total=12
  NO-REGRESSION: met
FILE: .claude/hooks/enforce-parallel-abandon-gate.ps1
  BASELINE: 93.59 (missed=5)
  POST: 94.05 (missed=5)
  CHANGED-LINES: covered=9 | total=9
  NO-REGRESSION: met
FILE: .claude/hooks/enforce-parallel-cohort-barrier.ps1
  BASELINE: 96.10 (missed=3)
  POST: 98.78 (missed=1)
  CHANGED-LINES: covered=10 | total=10
  NO-REGRESSION: met
FILE: .claude/hooks/enforce-parallel-drift-gate.ps1
  BASELINE: 98.23 (missed=2)
  POST: 99.15 (missed=1)
  CHANGED-LINES: covered=10 | total=10
  NO-REGRESSION: met
FILE: .claude/hooks/enforce-parallel-worktree-removal-gate.ps1
  BASELINE: 92.66 (missed=8)
  POST: 93.64 (missed=7)
  CHANGED-LINES: covered=11 | total=11
  NO-REGRESSION: met
FILE: .claude/hooks/enforce-powershell-batch-budget.ps1
  BASELINE: 95.45 (missed=6)
  POST: 95.65 (missed=6)
  CHANGED-LINES: covered=8 | total=8
  NO-REGRESSION: met
FILE: .claude/hooks/enforce-pr-author-skill.ps1
  BASELINE: 91.84 (missed=4)
  POST: 92.98 (missed=4)
  CHANGED-LINES: covered=12 | total=12
  NO-REGRESSION: met
FILE: .claude/hooks/enforce-prd-feature-before-planner-helpers.ps1
  BASELINE: 94.92 (missed=3)
  POST: 96.61 (missed=2)
  CHANGED-LINES: covered=1 | total=1
  NO-REGRESSION: met
FILE: .claude/hooks/enforce-prd-feature-before-planner.ps1
  BASELINE: 96.77 (missed=3)
  POST: 96.97 (missed=3)
  CHANGED-LINES: covered=10 | total=10
  NO-REGRESSION: met
FILE: .claude/hooks/enforce-promotion-mcp-only.ps1
  BASELINE: 93.33 (missed=4)
  POST: 93.94 (missed=4)
  CHANGED-LINES: covered=9 | total=9
  NO-REGRESSION: met
FILE: .claude/hooks/enforce-python-batch-budget.ps1
  BASELINE: 95.45 (missed=6)
  POST: 95.65 (missed=6)
  CHANGED-LINES: covered=8 | total=8
  NO-REGRESSION: met
FILE: .claude/hooks/hook-dependency-guard.ps1
  BASELINE: new file
  POST: 100.00 (missed=0)
  CHANGED-LINES: covered=19 | total=19
  NO-REGRESSION: n/a
FILE: .claude/hooks/validate-bash.ps1
  BASELINE: 94.62 (missed=5)
  POST: 94.95 (missed=5)
  CHANGED-LINES: covered=9 | total=9
  NO-REGRESSION: met
FILE: .claude/hooks/validate-discovery-artifact-gate.ps1
  BASELINE: 91.80 (missed=5)
  POST: 92.65 (missed=5)
  CHANGED-LINES: covered=7 | total=7
  NO-REGRESSION: met
FILE: .claude/hooks/validate-feature-review-coverage.ps1
  BASELINE: 49.52 (missed=106)
  POST: 97.22 (missed=6)
  CHANGED-LINES: covered=6 | total=6
  NO-REGRESSION: met
FILE: .claude/hooks/validate-orchestrator-output-resolution.ps1
  BASELINE: new file
  POST: 98.94 (missed=1)
  CHANGED-LINES: covered=0 | total=0
  NO-REGRESSION: n/a
FILE: .claude/hooks/validate-orchestrator-output.ps1
  BASELINE: 94.62 (missed=7)
  POST: 95.42 (missed=6)
  CHANGED-LINES: covered=15 | total=15
  NO-REGRESSION: met
FILE: .claude/hooks/validate-planner-output.ps1
  BASELINE: 96.28 (missed=7)
  POST: 97.94 (missed=4)
  CHANGED-LINES: covered=6 | total=6
  NO-REGRESSION: met
FILE: .claude/hooks/validate-pr-author-output.ps1
  BASELINE: 84.85 (missed=5)
  POST: 100.00 (missed=0)
  CHANGED-LINES: covered=6 | total=6
  NO-REGRESSION: met
FILE: .claude/hooks/validate-prd-feature-output.ps1
  BASELINE: 93.75 (missed=3)
  POST: 98.15 (missed=1)
  CHANGED-LINES: covered=6 | total=6
  NO-REGRESSION: met
FILE: .codex/hooks/check-powershell-test-purity.ps1
  BASELINE: 100.00 (missed=0)
  POST: 100.00 (missed=0)
  CHANGED-LINES: covered=7 | total=7
  NO-REGRESSION: met
FILE: .codex/hooks/check-python-test-purity.ps1
  BASELINE: 100.00 (missed=0)
  POST: 100.00 (missed=0)
  CHANGED-LINES: covered=7 | total=7
  NO-REGRESSION: met
FILE: .codex/hooks/codex-epic-child-launch-attestation.ps1
  BASELINE: 77.27 (missed=15)
  POST: 98.48 (missed=1)
  CHANGED-LINES: covered=1 | total=1
  NO-REGRESSION: met
FILE: .codex/hooks/enforce-checkpoint-monotonic.ps1
  BASELINE: 99.04 (missed=1)
  POST: 99.09 (missed=1)
  CHANGED-LINES: covered=7 | total=7
  NO-REGRESSION: met
FILE: .codex/hooks/enforce-codex-model-routing.ps1
  BASELINE: 56.94 (missed=31)
  POST: 100.00 (missed=0)
  CHANGED-LINES: covered=8 | total=8
  NO-REGRESSION: met
FILE: .codex/hooks/enforce-completion-consistency.ps1
  BASELINE: 100.00 (missed=0)
  POST: 100.00 (missed=0)
  CHANGED-LINES: covered=9 | total=9
  NO-REGRESSION: met
FILE: .codex/hooks/enforce-epic-child-worktree-binding.ps1
  BASELINE: 95.62 (missed=7)
  POST: 74.70 (missed=42)
  CHANGED-LINES: covered=7 | total=7
  NO-REGRESSION: not met
FILE: .codex/hooks/enforce-epic-merge-gate.ps1
  BASELINE: 98.68 (missed=2)
  POST: 98.09 (missed=3)
  CHANGED-LINES: covered=8 | total=8
  NO-REGRESSION: not met
FILE: .codex/hooks/enforce-epic-planning-only.ps1
  BASELINE: 95.71 (missed=7)
  POST: 82.25 (missed=30)
  CHANGED-LINES: covered=6 | total=6
  NO-REGRESSION: not met
FILE: .codex/hooks/enforce-epic-root-invocation.ps1
  BASELINE: 40.00 (missed=30)
  POST: 100.00 (missed=0)
  CHANGED-LINES: covered=7 | total=7
  NO-REGRESSION: met
FILE: .codex/hooks/enforce-epic-wave-barrier.ps1
  BASELINE: 65.41 (missed=46)
  POST: 95.68 (missed=6)
  CHANGED-LINES: covered=7 | total=7
  NO-REGRESSION: met
FILE: .codex/hooks/enforce-epic-worktree-removal-gate.ps1
  BASELINE: 98.61 (missed=1)
  POST: 98.72 (missed=1)
  CHANGED-LINES: covered=8 | total=8
  NO-REGRESSION: met
FILE: .codex/hooks/enforce-evidence-locations.ps1
  BASELINE: 100.00 (missed=0)
  POST: 100.00 (missed=0)
  CHANGED-LINES: covered=7 | total=7
  NO-REGRESSION: met
FILE: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1
  BASELINE: 100.00 (missed=0)
  POST: 86.55 (missed=23)
  CHANGED-LINES: covered=9 | total=12
  NO-REGRESSION: not met
FILE: .codex/hooks/enforce-powershell-batch-budget.ps1
  BASELINE: 98.99 (missed=1)
  POST: 99.05 (missed=1)
  CHANGED-LINES: covered=8 | total=8
  NO-REGRESSION: met
FILE: .codex/hooks/enforce-promotion-mcp-only.ps1
  BASELINE: 100.00 (missed=0)
  POST: 100.00 (missed=0)
  CHANGED-LINES: covered=8 | total=8
  NO-REGRESSION: met
FILE: .codex/hooks/enforce-python-batch-budget.ps1
  BASELINE: 98.99 (missed=1)
  POST: 99.05 (missed=1)
  CHANGED-LINES: covered=8 | total=8
  NO-REGRESSION: met
FILE: .codex/hooks/hook-dependency-guard.ps1
  BASELINE: new file
  POST: 57.89 (missed=8)
  CHANGED-LINES: covered=11 | total=19
  NO-REGRESSION: n/a
FILE: .codex/hooks/validate-bash.ps1
  BASELINE: 100.00 (missed=0)
  POST: 80.25 (missed=16)
  CHANGED-LINES: covered=5 | total=8
  NO-REGRESSION: not met
FILE: .codex/hooks/validate-codex-subagent-routing.ps1
  BASELINE: 32.26 (missed=42)
  POST: 100.00 (missed=0)
  CHANGED-LINES: covered=7 | total=7
  NO-REGRESSION: met
FILE: .codex/hooks/validate-feature-review-coverage.ps1
  BASELINE: 7.30 (missed=127)
  POST: 99.29 (missed=1)
  CHANGED-LINES: covered=4 | total=4
  NO-REGRESSION: met
NOT-MET: 5
POST-BELOW-85: 4
KNOWN-UNCOVERED: none
```

```text
EXCLUDE: none-excluded | TESTS: passed=8736 failed=38 failedContainers=0 ; COV validate-bash.ps1 | executed=117 | missed=1 ; COV hook-dependency-guard.ps1 | executed=33 | missed=1 ; COV enforce-orchestration-preimplementation-gate.ps1 | executed=237 | missed=1
EXCLUDE: *.Coverage.Tests.ps1 | TESTS: passed=8614 failed=38 failedContainers=0 ; COV validate-bash.ps1 | executed=117 | missed=1 ; COV hook-dependency-guard.ps1 | executed=33 | missed=1 ; COV enforce-orchestration-preimplementation-gate.ps1 | executed=237 | missed=1
EXCLUDE: hook-dependency-failure.Claude.Tests.ps1 | TESTS: passed=8620 failed=38 failedContainers=0 ; COV validate-bash.ps1 | executed=117 | missed=1 ; COV hook-dependency-guard.ps1 | executed=33 | missed=1 ; COV enforce-orchestration-preimplementation-gate.ps1 | executed=237 | missed=1
```
