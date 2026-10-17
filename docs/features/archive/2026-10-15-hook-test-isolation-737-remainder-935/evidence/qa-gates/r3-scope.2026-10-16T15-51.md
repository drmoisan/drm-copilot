# R3 Scope (P4-T9)

Timestamp: 2026-10-16T15-51
Command: git diff --name-only c2106a0ab..HEAD; git diff --name-only origin/main...HEAD; git status --porcelain
EXIT_CODE: 0
Output Summary:
- HEAD at the time of the commands: `3ab81c26f`.
- Porcelain: lists only paths under `FEATURE/` (the plan and eight new `evidence/qa-gates/r3-*` artifacts); no path outside `FEATURE/` and `.claude/agent-memory/`.
- Cycle diff (`c2106a0ab..HEAD`): code paths are only `tests/scripts/claude-hooks/EpicStateIsolation.Discovery.Helpers.ps1` and `tests/scripts/claude-hooks/EpicStateIsolation.HookReference.Helpers.ps1`; every other path is under `FEATURE/`. No kept candidate and no loop-fix paths.
- Branch diff (`origin/main...HEAD`): code paths are exactly the 18 spec Write-Set code paths; every other path is under `FEATURE/`. No path begins `.claude/`, `.codex/`, `.github/`, `extensions/`, `scripts/` or `config/`; none of the seven AC-6 suites, no `validate-` suite, no `hook-dependency-failure` suite, no `enforce-orchestration-preimplementation-gate-modes` suite and not `tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-epic-scope.Tests.ps1`.

## git status --porcelain
```
 M docs/features/active/2026-10-15-hook-test-isolation-737-remainder-935/remediation-plan.2026-10-16T11-25.md
?? docs/features/active/2026-10-15-hook-test-isolation-737-remainder-935/evidence/qa-gates/r3-cov-final-status.2026-10-16T15-50.md
?? docs/features/active/2026-10-15-hook-test-isolation-737-remainder-935/evidence/qa-gates/r3-coverage-delta.2026-10-16T15-50.md
?? docs/features/active/2026-10-15-hook-test-isolation-737-remainder-935/evidence/qa-gates/r3-line-counts.2026-10-16T15-51.md
?? docs/features/active/2026-10-15-hook-test-isolation-737-remainder-935/evidence/qa-gates/r3-loop-status.2026-10-16T15-50.md
?? docs/features/active/2026-10-15-hook-test-isolation-737-remainder-935/evidence/qa-gates/r3-ps-analyze.2026-10-16T15-18.md
?? docs/features/active/2026-10-15-hook-test-isolation-737-remainder-935/evidence/qa-gates/r3-ps-format.2026-10-16T15-17.md
?? docs/features/active/2026-10-15-hook-test-isolation-737-remainder-935/evidence/qa-gates/r3-ps-test-repo.2026-10-16T15-50.md
?? docs/features/active/2026-10-15-hook-test-isolation-737-remainder-935/evidence/qa-gates/r3-ps-test.2026-10-16T15-32.md
```

## git diff --name-only c2106a0ab..HEAD
```
docs/features/active/2026-10-15-hook-test-isolation-737-remainder-935/evidence/baseline/r3-branch-state.2026-10-16T12-32.md
docs/features/active/2026-10-15-hook-test-isolation-737-remainder-935/evidence/baseline/r3-comparison-tree.2026-10-16T12-32.md
docs/features/active/2026-10-15-hook-test-isolation-737-remainder-935/evidence/baseline/r3-coverage-mode.2026-10-16T12-33.md
docs/features/active/2026-10-15-hook-test-isolation-737-remainder-935/evidence/baseline/r3-phase0-instructions-read.2026-10-16T12-31.md
docs/features/active/2026-10-15-hook-test-isolation-737-remainder-935/evidence/baseline/r3-ps-analyze.2026-10-16T12-35.md
docs/features/active/2026-10-15-hook-test-isolation-737-remainder-935/evidence/baseline/r3-ps-format.2026-10-16T12-34.md
docs/features/active/2026-10-15-hook-test-isolation-737-remainder-935/evidence/baseline/r3-ps-test.2026-10-16T12-48.md
docs/features/active/2026-10-15-hook-test-isolation-737-remainder-935/evidence/baseline/r3-token-counts.2026-10-16T12-33.md
docs/features/active/2026-10-15-hook-test-isolation-737-remainder-935/evidence/other/r3-cov-bisection.2026-10-16T14-13.md
docs/features/active/2026-10-15-hook-test-isolation-737-remainder-935/evidence/other/r3-cov-localisation.2026-10-16T14-15.md
docs/features/active/2026-10-15-hook-test-isolation-737-remainder-935/evidence/other/r3-cov-n0-lib-only.2026-10-16T12-50.md
docs/features/active/2026-10-15-hook-test-isolation-737-remainder-935/evidence/other/r3-cov-n1-head.2026-10-16T13-08.md
docs/features/active/2026-10-15-hook-test-isolation-737-remainder-935/evidence/other/r3-cov-n2-sa.2026-10-16T13-26.md
docs/features/active/2026-10-15-hook-test-isolation-737-remainder-935/evidence/other/r3-cov-n3-sc.2026-10-16T13-42.md
docs/features/active/2026-10-15-hook-test-isolation-737-remainder-935/evidence/other/r3-cov-n4-sb.2026-10-16T13-58.md
docs/features/active/2026-10-15-hook-test-isolation-737-remainder-935/evidence/other/r3-cov-n5-u4.2026-10-16T14-13.md
docs/features/active/2026-10-15-hook-test-isolation-737-remainder-935/evidence/other/r3-ev1-correction.2026-10-16T15-16.md
docs/features/active/2026-10-15-hook-test-isolation-737-remainder-935/evidence/qa-gates/r3-cov-fix-order.2026-10-16T14-25.md
docs/features/active/2026-10-15-hook-test-isolation-737-remainder-935/evidence/qa-gates/r3-cov-fix-trial-1.2026-10-16T14-39.md
docs/features/active/2026-10-15-hook-test-isolation-737-remainder-935/evidence/qa-gates/r3-cov-fix-trial-2.2026-10-16T14-56.md
docs/features/active/2026-10-15-hook-test-isolation-737-remainder-935/evidence/qa-gates/r3-cov-fix-trial-3.2026-10-16T15-15.md
docs/features/active/2026-10-15-hook-test-isolation-737-remainder-935/evidence/qa-gates/r3-cov-status.2026-10-16T15-15.md
docs/features/active/2026-10-15-hook-test-isolation-737-remainder-935/evidence/qa-gates/r3-p2-ps-test.2026-10-16T14-24.md
docs/features/active/2026-10-15-hook-test-isolation-737-remainder-935/remediation-plan.2026-10-16T11-25.md
tests/scripts/claude-hooks/EpicStateIsolation.Discovery.Helpers.ps1
tests/scripts/claude-hooks/EpicStateIsolation.HookReference.Helpers.ps1
```

## git diff --name-only origin/main...HEAD
Code paths (18, all in spec `## Write Set`):
```
tests/scripts/claude-hooks/EpicStateIsolation.Compliance.Helpers.ps1
tests/scripts/claude-hooks/EpicStateIsolation.Discovery.Helpers.ps1
tests/scripts/claude-hooks/EpicStateIsolation.Helpers.ps1
tests/scripts/claude-hooks/EpicStateIsolation.HookReference.Helpers.ps1
tests/scripts/claude-hooks/enforce-epic-worktree-removal-gate.ManifestBranch.Tests.ps1
tests/scripts/claude-hooks/enforce-epic-worktree-removal-gate.Tests.ps1
tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.Branches.Tests.ps1
tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.Discovery.Tests.ps1
tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.HookReference.Tests.ps1
tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.Predicate.Tests.ps1
tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.Tests.ps1
tests/scripts/claude-hooks/enforce-prd-feature-before-planner.CallTarget.Tests.ps1
tests/scripts/claude-hooks/enforce-prd-feature-before-planner.TargetResolution.Tests.ps1
tests/scripts/claude-runtime/EnforcementHooksNoPythonInvocation.Allowlist.Helpers.ps1
tests/scripts/claude-runtime/EnforcementHooksNoPythonInvocation.Helpers.ps1
tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-command-exemption.Helpers.ps1
tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-command-exemption.Selectors.Tests.ps1
tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-command-exemption.Tests.ps1
```
All remaining 133 listed paths (counted with `grep -c -e '^docs/features/active/2026-10-15-hook-test-isolation-737-remainder-935/'`; paths outside FEATURE and `tests/`: 0) begin `docs/features/active/2026-10-15-hook-test-isolation-737-remainder-935/` (feature documents and evidence of cycles 0 to 3).
