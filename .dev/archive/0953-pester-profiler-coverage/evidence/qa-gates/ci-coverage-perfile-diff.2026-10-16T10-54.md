# CI Coverage Per-File Diff (P7-T8, AC-09)

Timestamp: 2026-10-16T10-54
Command: sh SCRATCH/issue-953-compare.sh SCRATCH/issue-953-baseline-artifact-reselected/powershell-coverage.xml SCRATCH/issue-953-prhead-artifact/powershell-coverage.xml SCRATCH/issue-953-prhead-artifact/pester-junit.xml
EXIT_CODE: 0
Output Summary: 53 files differ in covered LINE count; sum of positive deltas 336; sum of negative deltas -71. Per-file LINE totals are identical for every key, so every difference is in hit attribution (profiler versus breakpoint collection), not in the denominator. The PoshQC.psm1 increase (+13) comes from the new module-coverage tests.

COMPARISON_METHOD: CRP per-file LINE counters keyed by workspace-relative directory plus sourcefile name; baseline run 38885440106 vs PR-head run 38887178530

| key | baseline covered | baseline missed | PR-head covered | PR-head missed | covered delta |
|---|---|---|---|---|---|
| .claude/hooks/enforce-completion-consistency.ps1 | 140 | 9 | 139 | 10 | -1 |
| .claude/hooks/enforce-completion-helpers.ps1 | 65 | 2 | 62 | 5 | -3 |
| .claude/hooks/enforce-epic-wave-barrier.ps1 | 95 | 1 | 94 | 2 | -1 |
| .claude/hooks/enforce-epic-worktree-removal-gate.ps1 | 111 | 4 | 110 | 5 | -1 |
| .claude/hooks/enforce-evidence-locations.ps1 | 42 | 4 | 41 | 5 | -1 |
| .claude/hooks/enforce-feature-folder-order.ps1 | 62 | 4 | 61 | 5 | -1 |
| .claude/hooks/enforce-orchestration-preimplementation-gate.ps1 | 154 | 5 | 153 | 6 | -1 |
| .claude/hooks/enforce-parallel-cohort-barrier.ps1 | 81 | 1 | 80 | 2 | -1 |
| .claude/hooks/enforce-parallel-drift-gate.ps1 | 116 | 1 | 115 | 2 | -1 |
| .claude/hooks/enforce-parallel-worktree-removal-gate.ps1 | 103 | 7 | 102 | 8 | -1 |
| .claude/hooks/enforce-powershell-batch-budget.ps1 | 132 | 6 | 125 | 13 | -7 |
| .claude/hooks/enforce-pr-author-skill.ps1 | 53 | 4 | 52 | 5 | -1 |
| .claude/hooks/enforce-promotion-mcp-only.ps1 | 62 | 4 | 61 | 5 | -1 |
| .claude/hooks/enforce-python-batch-budget.ps1 | 132 | 6 | 125 | 13 | -7 |
| .claude/hooks/validate-orchestrator-output-routing.ps1 | 28 | 0 | 27 | 1 | -1 |
| .claude/hooks/validate-task-researcher-output.ps1 | 101 | 2 | 100 | 3 | -1 |
| .claude/lib/orchestrator-state/orchestratorstate.psm1 | 110 | 0 | 109 | 1 | -1 |
| .claude/lib/worktree-resolution/epicscoperesolution.psm1 | 104 | 8 | 105 | 7 | 1 |
| .claude/lib/worktree-resolution/worktreetargetresolution.psm1 | 102 | 2 | 104 | 0 | 2 |
| .codex/hooks/enforce-checkpoint-monotonic.ps1 | 94 | 16 | 109 | 1 | 15 |
| .codex/hooks/enforce-completion-consistency.ps1 | 100 | 53 | 153 | 0 | 53 |
| .codex/hooks/enforce-completion-helpers.ps1 | 57 | 10 | 56 | 11 | -1 |
| .codex/hooks/enforce-epic-merge-gate.ps1 | 138 | 19 | 155 | 2 | 17 |
| .codex/hooks/enforce-epic-worktree-removal-gate.ps1 | 38 | 40 | 77 | 1 | 39 |
| .codex/hooks/enforce-orchestration-preimplementation-gate-epic-resolution.ps1 | 104 | 43 | 137 | 10 | 33 |
| .codex/hooks/enforce-orchestration-preimplementation-gate-epic-scope.ps1 | 49 | 6 | 55 | 0 | 6 |
| .codex/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1 | 139 | 20 | 156 | 3 | 17 |
| .codex/hooks/enforce-orchestration-preimplementation-gate-modes.ps1 | 122 | 13 | 133 | 2 | 11 |
| .codex/hooks/enforce-orchestration-preimplementation-gate.ps1 | 123 | 48 | 171 | 0 | 48 |
| .codex/hooks/enforce-powershell-batch-budget.ps1 | 104 | 1 | 100 | 5 | -4 |
| .codex/hooks/enforce-promotion-mcp-only.ps1 | 54 | 17 | 71 | 0 | 17 |
| .codex/hooks/enforce-python-batch-budget.ps1 | 104 | 1 | 100 | 5 | -4 |
| .codex/hooks/hook-command-heredoc.ps1 | 36 | 6 | 42 | 0 | 6 |
| .codex/hooks/hook-command-invocation-operands.ps1 | 35 | 5 | 40 | 0 | 5 |
| .codex/hooks/hook-command-invocation.ps1 | 145 | 2 | 147 | 0 | 2 |
| .codex/hooks/hook-command-scanner.ps1 | 144 | 5 | 149 | 0 | 5 |
| .codex/hooks/hook-dependency-guard.ps1 | 11 | 8 | 19 | 0 | 8 |
| .codex/hooks/validate-bash.ps1 | 65 | 16 | 81 | 0 | 16 |
| scripts/dev-tools/drmcopilotpromptsupport.ps1 | 27 | 11 | 28 | 10 | 1 |
| scripts/dev-tools/hostverification.psm1 | 128 | 21 | 149 | 0 | 21 |
| scripts/dev-tools/invoke-fullreleaseflow.ps1 | 131 | 7 | 130 | 8 | -1 |
| scripts/dev-tools/new-potential-entry.ps1 | 72 | 15 | 70 | 17 | -2 |
| scripts/dev-tools/publish-sideloaded-extension.ps1 | 32 | 0 | 30 | 2 | -2 |
| scripts/dev-tools/run-actionlint.ps1 | 6 | 44 | 4 | 46 | -2 |
| scripts/dev-tools/sync-agents-from-instructions.ps1 | 94 | 35 | 93 | 36 | -1 |
| scripts/dev-tools/tree.ps1 | 12 | 7 | 11 | 8 | -1 |
| scripts/dev-tools/vscode-cli.helpers.ps1 | 15 | 12 | 13 | 14 | -2 |
| scripts/powershell/poshqc/poshqc.analyzer.psm1 | 77 | 11 | 74 | 14 | -3 |
| scripts/powershell/poshqc/poshqc.coverage.psm1 | 104 | 5 | 103 | 6 | -1 |
| scripts/powershell/poshqc/poshqc.filediscovery.psm1 | 41 | 8 | 40 | 9 | -1 |
| scripts/powershell/poshqc/poshqc.psm1 | 40 | 20 | 53 | 7 | 13 |
| scripts/powershell/poshqc/poshqc.scanconfig.psm1 | 44 | 2 | 42 | 4 | -2 |
| scripts/powershell/poshqc/poshqc.testing.psm1 | 200 | 0 | 187 | 13 | -13 |
