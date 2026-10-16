# Scope (P6-T6, AC-21, AC-22)

Timestamp: 2026-10-16T03-10
Command: git diff --name-only origin/main...HEAD; git status --porcelain
EXIT_CODE: 0

Output Summary: PASS. HEAD at the time of the check: `4c9d38da0`.
- The diff lists the 18 Write-Set code paths and paths under `FEATURE/` only (evidence artifacts, `issue.md`, the plan, `research/research.2026-10-15T22-03.md`, `spec.md`), all covered by the spec Write Set feature-folder entries.
- No path begins `.claude/`, `.codex/`, `.github/`, `extensions/`, `scripts/` or `config/`.
- None of the seven AC-6 suites, no `validate-` suite, no `hook-dependency-failure` suite, no `enforce-orchestration-preimplementation-gate-modes` suite and not `tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-epic-scope.Tests.ps1` is listed.
- Porcelain lists only paths under `FEATURE/` (the plan file and four uncommitted Phase 6 loop artifacts).

`git diff --name-only origin/main...HEAD` (exit 0):

```
docs/features/active/2026-10-15-hook-test-isolation-737-remainder-935/evidence/baseline/branch-state.2026-10-16T00-26.md
docs/features/active/2026-10-15-hook-test-isolation-737-remainder-935/evidence/baseline/ci-baseline-source.2026-10-16T00-57.md
docs/features/active/2026-10-15-hook-test-isolation-737-remainder-935/evidence/baseline/ci-baseline.2026-10-16T00-11.md
docs/features/active/2026-10-15-hook-test-isolation-737-remainder-935/evidence/baseline/line-counts.2026-10-16T00-26.md
docs/features/active/2026-10-15-hook-test-isolation-737-remainder-935/evidence/baseline/phase0-instructions-read.2026-10-16T00-25.md
docs/features/active/2026-10-15-hook-test-isolation-737-remainder-935/evidence/baseline/ps-analyze.2026-10-16T00-31.md
docs/features/active/2026-10-15-hook-test-isolation-737-remainder-935/evidence/baseline/ps-format.2026-10-16T00-30.md
docs/features/active/2026-10-15-hook-test-isolation-737-remainder-935/evidence/baseline/ps-test.2026-10-16T00-57.md
docs/features/active/2026-10-15-hook-test-isolation-737-remainder-935/evidence/baseline/split-anchors.2026-10-16T00-28.md
docs/features/active/2026-10-15-hook-test-isolation-737-remainder-935/evidence/baseline/withheld-source.2026-10-16T00-29.md
docs/features/active/2026-10-15-hook-test-isolation-737-remainder-935/evidence/qa-gates/i3-consumers-unchanged.2026-10-16T01-01.md
docs/features/active/2026-10-15-hook-test-isolation-737-remainder-935/evidence/qa-gates/p1-ps-test.2026-10-16T01-51.md
docs/features/active/2026-10-15-hook-test-isolation-737-remainder-935/evidence/qa-gates/p2-reapply-state.2026-10-16T01-53.md
docs/features/active/2026-10-15-hook-test-isolation-737-remainder-935/evidence/qa-gates/p3-split.2026-10-16T01-55.md
docs/features/active/2026-10-15-hook-test-isolation-737-remainder-935/evidence/qa-gates/p4-fixture-names.2026-10-16T01-59.md
docs/features/active/2026-10-15-hook-test-isolation-737-remainder-935/evidence/qa-gates/p4-ps-test.2026-10-16T02-18.md
docs/features/active/2026-10-15-hook-test-isolation-737-remainder-935/evidence/qa-gates/p5-ps-test.2026-10-16T02-44.md
docs/features/active/2026-10-15-hook-test-isolation-737-remainder-935/evidence/qa-gates/ps-format.2026-10-16T02-45.md
docs/features/active/2026-10-15-hook-test-isolation-737-remainder-935/evidence/regression-testing/f1-f2-reapply.2026-10-16T01-53.md
docs/features/active/2026-10-15-hook-test-isolation-737-remainder-935/evidence/regression-testing/fail-before-ac1-ac2.2026-10-16T01-54.md
docs/features/active/2026-10-15-hook-test-isolation-737-remainder-935/evidence/regression-testing/fail-before-ac6.2026-10-16T01-54.md
docs/features/active/2026-10-15-hook-test-isolation-737-remainder-935/evidence/regression-testing/fail-before-exception.f3.2026-10-16T02-21.md
docs/features/active/2026-10-15-hook-test-isolation-737-remainder-935/evidence/regression-testing/fail-before-exception.r1-r2.2026-10-16T01-59.md
docs/features/active/2026-10-15-hook-test-isolation-737-remainder-935/issue.md
docs/features/active/2026-10-15-hook-test-isolation-737-remainder-935/plan.2026-10-15T17-44.md
docs/features/active/2026-10-15-hook-test-isolation-737-remainder-935/research/research.2026-10-15T22-03.md
docs/features/active/2026-10-15-hook-test-isolation-737-remainder-935/spec.md
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

`git status --porcelain` (exit 0):

```
 M docs/features/active/2026-10-15-hook-test-isolation-737-remainder-935/plan.2026-10-15T17-44.md
?? docs/features/active/2026-10-15-hook-test-isolation-737-remainder-935/evidence/qa-gates/loop-status.2026-10-16T03-10.md
?? docs/features/active/2026-10-15-hook-test-isolation-737-remainder-935/evidence/qa-gates/ps-analyze.2026-10-16T02-48.md
?? docs/features/active/2026-10-15-hook-test-isolation-737-remainder-935/evidence/qa-gates/ps-format.2026-10-16T02-46.md
?? docs/features/active/2026-10-15-hook-test-isolation-737-remainder-935/evidence/qa-gates/ps-test.2026-10-16T03-10.md
```
