# Coverage Comparison ([P10-T4], AC-24; re-recorded by remediation [P5-T4])

Timestamp: 2026-10-10T18-20
Pass: 1
Command: <SCRATCHPAD>/r1-p5t4.ps1 -Pass 1 (route sh). Combined-run entries: BASELINE from evidence/baseline/p0-pester-coverage.md (validate-orchestrator-output-resolution.ps1 from the [P0-T10] BASELINE-ROW; new file when git cat-file -e 86e457a003be0c60b65e01156e4cccd6495dfd1a:<path> exits non-zero), POST and CHANGED-LINES from the [P5-T3] run, NO-REGRESSION by the main-plan section 5 rule. PS-SET entries (rule 10): per-surface values from the `## Pass 1 current-tree re-run` section of evidence/qa-gates/r1-ac24-per-surface.md (scope=judged lines), with the combined-run figures as COMBINED-BASELINE and COMBINED-POST.
EXIT_CODE: 0
Output Summary: 57 files; 2 new; 6 PS-SET entries on the per-surface route; every POST at least 85.00 and every NO-REGRESSION met or n/a; PER-SURFACE-RESULT: pass.

PER-SURFACE-PASS: 1
NEW-FILES: .claude/hooks/hook-dependency-guard.ps1, .codex/hooks/hook-dependency-guard.ps1

```text
FILE: .claude/hooks/check-powershell-test-purity.ps1
  CAT-FILE-EXIT-CODE: 0
  BASELINE: 92.73 (missed=4)
  POST: 93.44 (missed=4)
  CHANGED-LINES: covered=7 | total=7
  NO-REGRESSION: met
  KNOWN-UNCOVERED: none
FILE: .claude/hooks/check-python-test-purity.ps1
  CAT-FILE-EXIT-CODE: 0
  BASELINE: 93.33 (missed=4)
  POST: 93.94 (missed=4)
  CHANGED-LINES: covered=7 | total=7
  NO-REGRESSION: met
  KNOWN-UNCOVERED: none
FILE: .claude/hooks/enforce-checkpoint-monotonic.ps1
  CAT-FILE-EXIT-CODE: 0
  BASELINE: 95.74 (missed=4)
  POST: 96.00 (missed=4)
  CHANGED-LINES: covered=7 | total=7
  NO-REGRESSION: met
  KNOWN-UNCOVERED: none
FILE: .claude/hooks/enforce-completion-consistency.ps1
  CAT-FILE-EXIT-CODE: 0
  BASELINE: 93.62 (missed=9)
  POST: 93.84 (missed=9)
  CHANGED-LINES: covered=8 | total=8
  NO-REGRESSION: met
  KNOWN-UNCOVERED: none
FILE: .claude/hooks/enforce-discovery-artifact-gate.ps1
  CAT-FILE-EXIT-CODE: 0
  BASELINE: 95.16 (missed=3)
  POST: 95.65 (missed=3)
  CHANGED-LINES: covered=8 | total=8
  NO-REGRESSION: met
  KNOWN-UNCOVERED: none
FILE: .claude/hooks/enforce-epic-invocation-origin.ps1
  CAT-FILE-EXIT-CODE: 0
  BASELINE: 89.55 (missed=7)
  POST: 90.41 (missed=7)
  CHANGED-LINES: covered=7 | total=7
  NO-REGRESSION: met
  KNOWN-UNCOVERED: none
FILE: .claude/hooks/enforce-epic-merge-gate-resolution.ps1
  CAT-FILE-EXIT-CODE: 0
  BASELINE: 90.00 (missed=5)
  POST: 95.24 (missed=2)
  CHANGED-LINES: covered=2 | total=2
  NO-REGRESSION: met
  KNOWN-UNCOVERED: none
FILE: .claude/hooks/enforce-epic-merge-gate.ps1
  CAT-FILE-EXIT-CODE: 0
  BASELINE: 96.15 (missed=5)
  POST: 99.25 (missed=1)
  CHANGED-LINES: covered=12 | total=12
  NO-REGRESSION: met
  KNOWN-UNCOVERED: none
FILE: .claude/hooks/enforce-epic-wave-barrier.ps1
  CAT-FILE-EXIT-CODE: 0
  BASELINE: 96.70 (missed=3)
  POST: 98.96 (missed=1)
  CHANGED-LINES: covered=8 | total=8
  NO-REGRESSION: met
  KNOWN-UNCOVERED: none
FILE: .claude/hooks/enforce-epic-worktree-removal-gate-resolution.ps1
  CAT-FILE-EXIT-CODE: 0
  BASELINE: 96.49 (missed=2)
  POST: 98.04 (missed=1)
  CHANGED-LINES: covered=1 | total=1
  NO-REGRESSION: met
  KNOWN-UNCOVERED: none
FILE: .claude/hooks/enforce-epic-worktree-removal-gate.ps1
  CAT-FILE-EXIT-CODE: 0
  BASELINE: 96.43 (missed=4)
  POST: 96.52 (missed=4)
  CHANGED-LINES: covered=11 | total=11
  NO-REGRESSION: met
  KNOWN-UNCOVERED: none
FILE: .claude/hooks/enforce-evidence-locations.ps1
  CAT-FILE-EXIT-CODE: 0
  BASELINE: 90.00 (missed=4)
  POST: 91.30 (missed=4)
  CHANGED-LINES: covered=7 | total=7
  NO-REGRESSION: met
  KNOWN-UNCOVERED: none
FILE: .claude/hooks/enforce-feature-folder-order.ps1
  CAT-FILE-EXIT-CODE: 0
  BASELINE: 91.67 (missed=5)
  POST: 93.94 (missed=4)
  CHANGED-LINES: covered=7 | total=7
  NO-REGRESSION: met
  KNOWN-UNCOVERED: none
FILE: .claude/hooks/enforce-mermaid-validation.ps1
  CAT-FILE-EXIT-CODE: 0
  BASELINE: 92.41 (missed=6)
  POST: 94.12 (missed=5)
  CHANGED-LINES: covered=7 | total=7
  NO-REGRESSION: met
  KNOWN-UNCOVERED: none
FILE: .claude/hooks/enforce-model-routing-receipt.ps1
  CAT-FILE-EXIT-CODE: 0
  BASELINE: 95.52 (missed=3)
  POST: 95.89 (missed=3)
  CHANGED-LINES: covered=9 | total=9
  NO-REGRESSION: met
  KNOWN-UNCOVERED: none
FILE: .claude/hooks/enforce-orchestration-preimplementation-gate-epic-scope.ps1
  CAT-FILE-EXIT-CODE: 0
  BASELINE: 98.72 (missed=1)
  POST: 98.63 (missed=1)
  CHANGED-LINES: covered=4 | total=4
  NO-REGRESSION: met
  KNOWN-UNCOVERED: none
FILE: .claude/hooks/enforce-orchestration-preimplementation-gate.ps1
  CAT-FILE-EXIT-CODE: 0
  BASELINE: 96.75 (missed=5)
  POST: 96.86 (missed=5)
  CHANGED-LINES: covered=12 | total=12
  NO-REGRESSION: met
  KNOWN-UNCOVERED: none
FILE: .claude/hooks/enforce-parallel-abandon-gate.ps1
  CAT-FILE-EXIT-CODE: 0
  BASELINE: 93.59 (missed=5)
  POST: 94.05 (missed=5)
  CHANGED-LINES: covered=9 | total=9
  NO-REGRESSION: met
  KNOWN-UNCOVERED: none
FILE: .claude/hooks/enforce-parallel-cohort-barrier.ps1
  CAT-FILE-EXIT-CODE: 0
  BASELINE: 96.10 (missed=3)
  POST: 98.78 (missed=1)
  CHANGED-LINES: covered=10 | total=10
  NO-REGRESSION: met
  KNOWN-UNCOVERED: none
FILE: .claude/hooks/enforce-parallel-drift-gate.ps1
  CAT-FILE-EXIT-CODE: 0
  BASELINE: 98.23 (missed=2)
  POST: 99.15 (missed=1)
  CHANGED-LINES: covered=10 | total=10
  NO-REGRESSION: met
  KNOWN-UNCOVERED: none
FILE: .claude/hooks/enforce-parallel-worktree-removal-gate.ps1
  CAT-FILE-EXIT-CODE: 0
  BASELINE: 92.66 (missed=8)
  POST: 93.64 (missed=7)
  CHANGED-LINES: covered=11 | total=11
  NO-REGRESSION: met
  KNOWN-UNCOVERED: none
FILE: .claude/hooks/enforce-powershell-batch-budget.ps1
  CAT-FILE-EXIT-CODE: 0
  BASELINE: 95.45 (missed=6)
  POST: 95.65 (missed=6)
  CHANGED-LINES: covered=8 | total=8
  NO-REGRESSION: met
  KNOWN-UNCOVERED: none
FILE: .claude/hooks/enforce-pr-author-skill.ps1
  CAT-FILE-EXIT-CODE: 0
  BASELINE: 91.84 (missed=4)
  POST: 92.98 (missed=4)
  CHANGED-LINES: covered=12 | total=12
  NO-REGRESSION: met
  KNOWN-UNCOVERED: none
FILE: .claude/hooks/enforce-prd-feature-before-planner-helpers.ps1
  CAT-FILE-EXIT-CODE: 0
  BASELINE: 94.92 (missed=3)
  POST: 96.61 (missed=2)
  CHANGED-LINES: covered=1 | total=1
  NO-REGRESSION: met
  KNOWN-UNCOVERED: none
FILE: .claude/hooks/enforce-prd-feature-before-planner.ps1
  CAT-FILE-EXIT-CODE: 0
  BASELINE: 96.77 (missed=3)
  POST: 96.97 (missed=3)
  CHANGED-LINES: covered=10 | total=10
  NO-REGRESSION: met
  KNOWN-UNCOVERED: none
FILE: .claude/hooks/enforce-promotion-mcp-only.ps1
  CAT-FILE-EXIT-CODE: 0
  BASELINE: 93.33 (missed=4)
  POST: 93.94 (missed=4)
  CHANGED-LINES: covered=9 | total=9
  NO-REGRESSION: met
  KNOWN-UNCOVERED: none
FILE: .claude/hooks/enforce-python-batch-budget.ps1
  CAT-FILE-EXIT-CODE: 0
  BASELINE: 95.45 (missed=6)
  POST: 95.65 (missed=6)
  CHANGED-LINES: covered=8 | total=8
  NO-REGRESSION: met
  KNOWN-UNCOVERED: none
FILE: .claude/hooks/hook-dependency-guard.ps1
  CAT-FILE-EXIT-CODE: 128
  BASELINE: new file
  POST: 100.00 (missed=0)
  CHANGED-LINES: covered=19 | total=19
  NO-REGRESSION: n/a
  KNOWN-UNCOVERED: none
FILE: .claude/hooks/validate-bash.ps1
  CAT-FILE-EXIT-CODE: 0
  BASELINE: 94.62 (missed=5)
  POST: 94.95 (missed=5)
  CHANGED-LINES: covered=9 | total=9
  NO-REGRESSION: met
  KNOWN-UNCOVERED: none
FILE: .claude/hooks/validate-discovery-artifact-gate.ps1
  CAT-FILE-EXIT-CODE: 0
  BASELINE: 91.80 (missed=5)
  POST: 92.65 (missed=5)
  CHANGED-LINES: covered=7 | total=7
  NO-REGRESSION: met
  KNOWN-UNCOVERED: none
FILE: .claude/hooks/validate-feature-review-coverage.ps1
  CAT-FILE-EXIT-CODE: 0
  BASELINE: 49.52 (missed=106)
  POST: 97.22 (missed=6)
  CHANGED-LINES: covered=6 | total=6
  NO-REGRESSION: met
  KNOWN-UNCOVERED: none
FILE: .claude/hooks/validate-orchestrator-output-resolution.ps1
  CAT-FILE-EXIT-CODE: 0
  BASELINE: 98.96 (missed=1) ([P0-T10] BASELINE-ROW)
  POST: 98.94 (missed=1)
  CHANGED-LINES: covered=0 | total=0
  NO-REGRESSION: met
  KNOWN-UNCOVERED: none
FILE: .claude/hooks/validate-orchestrator-output.ps1
  CAT-FILE-EXIT-CODE: 0
  BASELINE: 94.62 (missed=7)
  POST: 95.42 (missed=6)
  CHANGED-LINES: covered=15 | total=15
  NO-REGRESSION: met
  KNOWN-UNCOVERED: none
FILE: .claude/hooks/validate-planner-output.ps1
  CAT-FILE-EXIT-CODE: 0
  BASELINE: 96.28 (missed=7)
  POST: 97.94 (missed=4)
  CHANGED-LINES: covered=6 | total=6
  NO-REGRESSION: met
  KNOWN-UNCOVERED: none
FILE: .claude/hooks/validate-pr-author-output.ps1
  CAT-FILE-EXIT-CODE: 0
  BASELINE: 84.85 (missed=5)
  POST: 100.00 (missed=0)
  CHANGED-LINES: covered=6 | total=6
  NO-REGRESSION: met
  KNOWN-UNCOVERED: none
FILE: .claude/hooks/validate-prd-feature-output.ps1
  CAT-FILE-EXIT-CODE: 0
  BASELINE: 93.75 (missed=3)
  POST: 98.15 (missed=1)
  CHANGED-LINES: covered=6 | total=6
  NO-REGRESSION: met
  KNOWN-UNCOVERED: none
FILE: .codex/hooks/check-powershell-test-purity.ps1
  CAT-FILE-EXIT-CODE: 0
  BASELINE: 100.00 (missed=0)
  POST: 100.00 (missed=0)
  CHANGED-LINES: covered=7 | total=7
  NO-REGRESSION: met
  KNOWN-UNCOVERED: none
FILE: .codex/hooks/check-python-test-purity.ps1
  CAT-FILE-EXIT-CODE: 0
  BASELINE: 100.00 (missed=0)
  POST: 100.00 (missed=0)
  CHANGED-LINES: covered=7 | total=7
  NO-REGRESSION: met
  KNOWN-UNCOVERED: none
FILE: .codex/hooks/codex-epic-child-launch-attestation.ps1
  CAT-FILE-EXIT-CODE: 0
  BASELINE: 77.27 (missed=15)
  POST: 98.48 (missed=1)
  CHANGED-LINES: covered=1 | total=1
  NO-REGRESSION: met
  KNOWN-UNCOVERED: none
FILE: .codex/hooks/enforce-checkpoint-monotonic.ps1
  CAT-FILE-EXIT-CODE: 0
  BASELINE: 99.04 (missed=1)
  POST: 99.09 (missed=1)
  CHANGED-LINES: covered=7 | total=7
  NO-REGRESSION: met
  KNOWN-UNCOVERED: none
FILE: .codex/hooks/enforce-codex-model-routing.ps1
  CAT-FILE-EXIT-CODE: 0
  BASELINE: 56.94 (missed=31)
  POST: 100.00 (missed=0)
  CHANGED-LINES: covered=8 | total=8
  NO-REGRESSION: met
  KNOWN-UNCOVERED: none
FILE: .codex/hooks/enforce-completion-consistency.ps1
  CAT-FILE-EXIT-CODE: 0
  BASELINE: 100.00 (missed=0)
  POST: 100.00 (missed=0)
  CHANGED-LINES: covered=9 | total=9
  NO-REGRESSION: met
  KNOWN-UNCOVERED: none
FILE: .codex/hooks/enforce-epic-child-worktree-binding.ps1
  CAT-FILE-EXIT-CODE: 0
  BASELINE: 95.62 (missed=7)
  POST: 95.78 (missed=7)
  CHANGED-LINES: covered=7 | total=7
  NO-REGRESSION: met
  KNOWN-UNCOVERED: none
  COMBINED-BASELINE: 95.62 (missed=7)
  COMBINED-POST: 74.70 (missed=42)
  AC-24-ROUTE: per-surface
FILE: .codex/hooks/enforce-epic-merge-gate.ps1
  CAT-FILE-EXIT-CODE: 0
  BASELINE: 98.68 (missed=2)
  POST: 98.73 (missed=2)
  CHANGED-LINES: covered=8 | total=8
  NO-REGRESSION: met
  KNOWN-UNCOVERED: none
  COMBINED-BASELINE: 98.68 (missed=2)
  COMBINED-POST: 98.09 (missed=3)
  AC-24-ROUTE: per-surface
FILE: .codex/hooks/enforce-epic-planning-only.ps1
  CAT-FILE-EXIT-CODE: 0
  BASELINE: 95.71 (missed=7)
  POST: 95.86 (missed=7)
  CHANGED-LINES: covered=6 | total=6
  NO-REGRESSION: met
  KNOWN-UNCOVERED: none
  COMBINED-BASELINE: 95.71 (missed=7)
  COMBINED-POST: 82.25 (missed=30)
  AC-24-ROUTE: per-surface
FILE: .codex/hooks/enforce-epic-root-invocation.ps1
  CAT-FILE-EXIT-CODE: 0
  BASELINE: 40.00 (missed=30)
  POST: 100.00 (missed=0)
  CHANGED-LINES: covered=7 | total=7
  NO-REGRESSION: met
  KNOWN-UNCOVERED: none
FILE: .codex/hooks/enforce-epic-wave-barrier.ps1
  CAT-FILE-EXIT-CODE: 0
  BASELINE: 65.41 (missed=46)
  POST: 95.68 (missed=6)
  CHANGED-LINES: covered=7 | total=7
  NO-REGRESSION: met
  KNOWN-UNCOVERED: none
FILE: .codex/hooks/enforce-epic-worktree-removal-gate.ps1
  CAT-FILE-EXIT-CODE: 0
  BASELINE: 98.61 (missed=1)
  POST: 98.72 (missed=1)
  CHANGED-LINES: covered=8 | total=8
  NO-REGRESSION: met
  KNOWN-UNCOVERED: none
FILE: .codex/hooks/enforce-evidence-locations.ps1
  CAT-FILE-EXIT-CODE: 0
  BASELINE: 100.00 (missed=0)
  POST: 100.00 (missed=0)
  CHANGED-LINES: covered=7 | total=7
  NO-REGRESSION: met
  KNOWN-UNCOVERED: none
FILE: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1
  CAT-FILE-EXIT-CODE: 0
  BASELINE: 100.00 (missed=0)
  POST: 100.00 (missed=0)
  CHANGED-LINES: covered=12 | total=12
  NO-REGRESSION: met
  KNOWN-UNCOVERED: none
  COMBINED-BASELINE: 100.00 (missed=0)
  COMBINED-POST: 86.55 (missed=23)
  AC-24-ROUTE: per-surface
FILE: .codex/hooks/enforce-powershell-batch-budget.ps1
  CAT-FILE-EXIT-CODE: 0
  BASELINE: 98.99 (missed=1)
  POST: 99.05 (missed=1)
  CHANGED-LINES: covered=8 | total=8
  NO-REGRESSION: met
  KNOWN-UNCOVERED: none
FILE: .codex/hooks/enforce-promotion-mcp-only.ps1
  CAT-FILE-EXIT-CODE: 0
  BASELINE: 100.00 (missed=0)
  POST: 100.00 (missed=0)
  CHANGED-LINES: covered=8 | total=8
  NO-REGRESSION: met
  KNOWN-UNCOVERED: none
FILE: .codex/hooks/enforce-python-batch-budget.ps1
  CAT-FILE-EXIT-CODE: 0
  BASELINE: 98.99 (missed=1)
  POST: 99.05 (missed=1)
  CHANGED-LINES: covered=8 | total=8
  NO-REGRESSION: met
  KNOWN-UNCOVERED: none
FILE: .codex/hooks/hook-dependency-guard.ps1
  CAT-FILE-EXIT-CODE: 128
  BASELINE: new file
  POST: 100.00 (missed=0)
  CHANGED-LINES: covered=19 | total=19
  NO-REGRESSION: n/a
  KNOWN-UNCOVERED: none
  COMBINED-BASELINE: new file
  COMBINED-POST: 57.89 (missed=8)
  AC-24-ROUTE: per-surface
FILE: .codex/hooks/validate-bash.ps1
  CAT-FILE-EXIT-CODE: 0
  BASELINE: 100.00 (missed=0)
  POST: 100.00 (missed=0)
  CHANGED-LINES: covered=8 | total=8
  NO-REGRESSION: met
  KNOWN-UNCOVERED: none
  COMBINED-BASELINE: 100.00 (missed=0)
  COMBINED-POST: 80.25 (missed=16)
  AC-24-ROUTE: per-surface
FILE: .codex/hooks/validate-codex-subagent-routing.ps1
  CAT-FILE-EXIT-CODE: 0
  BASELINE: 32.26 (missed=42)
  POST: 100.00 (missed=0)
  CHANGED-LINES: covered=7 | total=7
  NO-REGRESSION: met
  KNOWN-UNCOVERED: none
FILE: .codex/hooks/validate-feature-review-coverage.ps1
  CAT-FILE-EXIT-CODE: 0
  BASELINE: 7.30 (missed=127)
  POST: 99.29 (missed=1)
  CHANGED-LINES: covered=4 | total=4
  NO-REGRESSION: met
  KNOWN-UNCOVERED: none
```

## Acceptance checks

```text
CHECK: post-at-or-above-85 | pass
CHECK: no-regression-met-or-na | pass
CHECK: new-files-exact | pass | .claude/hooks/hook-dependency-guard.ps1, .codex/hooks/hook-dependency-guard.ps1
CHECK: ac24-route-count | pass | 6
CHECK: per-surface-result | pass | PER-SURFACE-RESULT: pass
```
