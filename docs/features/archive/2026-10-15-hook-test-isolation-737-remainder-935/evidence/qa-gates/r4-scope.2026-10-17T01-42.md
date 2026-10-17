# R4 Scope (P5-T9, issue #935; pre-mortem risk 2)

Timestamp: 2026-10-17T01-42
Command: the commands listed below, each with its output (run from the worktree root; scripts under SCRATCH)
EXIT_CODE: 0
(The three plan commands each exited 0, as recorded below. The trailing helper `grep -c` exits 1 when it prints the count 0, which is the expected count.)

Output Summary:
Porcelain lists only paths under FEATURE/ (the P_SELF check-offs and the uncommitted Phase 5 evidence; nothing under .claude/agent-memory/). The cycle diff lists only the eight CODE8 paths, P_SPEC, P_ISSUE, P_MAIN, P_SELF and paths under FEATURE/evidence/; the decision record cov1-decision-option1.2026-10-16T20-38.md is absent from it (count 0). The branch diff lists only the eight CODE8 paths and paths under FEATURE/ (count of other paths 0): no path under .claude/, .codex/, .github/, extensions/, scripts/ or config/, none of the seven AC-6 suites, no validate- suite, no hook-dependency-failure suite, no enforce-orchestration-preimplementation-gate-modes suite and not enforce-orchestration-preimplementation-gate-epic-scope.Tests.ps1. (FEATURE = docs/features/active/2026-10-15-hook-test-isolation-737-remainder-935.)

```
== git diff --name-only origin/bug/hook-test-isolation-737-remainder-935-r4 HEAD (cycle diff)
docs/features/active/2026-10-15-hook-test-isolation-737-remainder-935/evidence/baseline/r4-branch-state.2026-10-16T23-39.md
docs/features/active/2026-10-15-hook-test-isolation-737-remainder-935/evidence/baseline/r4-coverage-mode.2026-10-16T23-42.md
docs/features/active/2026-10-15-hook-test-isolation-737-remainder-935/evidence/baseline/r4-phase0-instructions-read.2026-10-16T23-38.md
docs/features/active/2026-10-15-hook-test-isolation-737-remainder-935/evidence/baseline/r4-ps-analyze.2026-10-16T23-43.md
docs/features/active/2026-10-15-hook-test-isolation-737-remainder-935/evidence/baseline/r4-ps-format.2026-10-16T23-42.md
docs/features/active/2026-10-15-hook-test-isolation-737-remainder-935/evidence/baseline/r4-ps-test-repo.2026-10-17T00-12.md
docs/features/active/2026-10-15-hook-test-isolation-737-remainder-935/evidence/baseline/r4-ps-test.2026-10-16T23-57.md
docs/features/active/2026-10-15-hook-test-isolation-737-remainder-935/evidence/baseline/r4-token-counts.2026-10-16T23-41.md
docs/features/active/2026-10-15-hook-test-isolation-737-remainder-935/evidence/other/ac24-checkbox-note.2026-10-17T00-47.md
docs/features/active/2026-10-15-hook-test-isolation-737-remainder-935/evidence/other/r4-perf-cr-n4-supersession.2026-10-17T00-55.md
docs/features/active/2026-10-15-hook-test-isolation-737-remainder-935/evidence/qa-gates/r4-main-plan-validation.2026-10-17T00-49.md
docs/features/active/2026-10-15-hook-test-isolation-737-remainder-935/evidence/qa-gates/r4-p1-ps-test.2026-10-17T00-32.md
docs/features/active/2026-10-15-hook-test-isolation-737-remainder-935/evidence/qa-gates/r4-p2-ps-analyze.2026-10-17T00-35.md
docs/features/active/2026-10-15-hook-test-isolation-737-remainder-935/evidence/qa-gates/r4-p2-ps-test.2026-10-17T00-45.md
docs/features/active/2026-10-15-hook-test-isolation-737-remainder-935/evidence/qa-gates/r4-perf-ps-analyze.2026-10-17T01-00.md
docs/features/active/2026-10-15-hook-test-isolation-737-remainder-935/evidence/qa-gates/r4-perf-ps-test.2026-10-17T01-07.md
docs/features/active/2026-10-15-hook-test-isolation-737-remainder-935/evidence/qa-gates/r4-perf-shuffled-run.2026-10-17T01-10.md
docs/features/active/2026-10-15-hook-test-isolation-737-remainder-935/evidence/qa-gates/r4-perf-status.2026-10-17T01-10.md
docs/features/active/2026-10-15-hook-test-isolation-737-remainder-935/evidence/qa-gates/r4-perf-timing-after.2026-10-17T01-09.md
docs/features/active/2026-10-15-hook-test-isolation-737-remainder-935/evidence/qa-gates/r4-perf-timing-before.2026-10-17T00-54.md
docs/features/active/2026-10-15-hook-test-isolation-737-remainder-935/evidence/regression-testing/r4-cr-f4-fail-before.2026-10-17T00-23.md
docs/features/active/2026-10-15-hook-test-isolation-737-remainder-935/issue.md
docs/features/active/2026-10-15-hook-test-isolation-737-remainder-935/plan.2026-10-15T17-44.md
docs/features/active/2026-10-15-hook-test-isolation-737-remainder-935/remediation-plan.2026-10-16T20-56.md
docs/features/active/2026-10-15-hook-test-isolation-737-remainder-935/spec.md
tests/scripts/claude-hooks/EpicStateIsolation.Compliance.Helpers.ps1
tests/scripts/claude-hooks/EpicStateIsolation.Discovery.Helpers.ps1
tests/scripts/claude-hooks/EpicStateIsolation.Helpers.ps1
tests/scripts/claude-hooks/EpicStateIsolation.HookReference.Helpers.ps1
tests/scripts/claude-hooks/enforce-epic-worktree-removal-gate.ManifestBranch.Tests.ps1
tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.Branches.Tests.ps1
tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.Discovery.Tests.ps1
tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.HookReference.Tests.ps1
exit 0
== git diff --name-only origin/main...HEAD (branch diff)
docs/features/active/2026-10-15-hook-test-isolation-737-remainder-935/code-review.2026-10-16T20-56.md
docs/features/active/2026-10-15-hook-test-isolation-737-remainder-935/evidence/baseline/r4-branch-state.2026-10-16T23-39.md
docs/features/active/2026-10-15-hook-test-isolation-737-remainder-935/evidence/baseline/r4-coverage-mode.2026-10-16T23-42.md
docs/features/active/2026-10-15-hook-test-isolation-737-remainder-935/evidence/baseline/r4-phase0-instructions-read.2026-10-16T23-38.md
docs/features/active/2026-10-15-hook-test-isolation-737-remainder-935/evidence/baseline/r4-ps-analyze.2026-10-16T23-43.md
docs/features/active/2026-10-15-hook-test-isolation-737-remainder-935/evidence/baseline/r4-ps-format.2026-10-16T23-42.md
docs/features/active/2026-10-15-hook-test-isolation-737-remainder-935/evidence/baseline/r4-ps-test-repo.2026-10-17T00-12.md
docs/features/active/2026-10-15-hook-test-isolation-737-remainder-935/evidence/baseline/r4-ps-test.2026-10-16T23-57.md
docs/features/active/2026-10-15-hook-test-isolation-737-remainder-935/evidence/baseline/r4-token-counts.2026-10-16T23-41.md
docs/features/active/2026-10-15-hook-test-isolation-737-remainder-935/evidence/other/ac24-checkbox-note.2026-10-17T00-47.md
docs/features/active/2026-10-15-hook-test-isolation-737-remainder-935/evidence/other/pre-mortem-r4.2026-10-16T21-52.md
docs/features/active/2026-10-15-hook-test-isolation-737-remainder-935/evidence/other/pre-mortem.2026-10-16T20-48.md
docs/features/active/2026-10-15-hook-test-isolation-737-remainder-935/evidence/other/r4-perf-cr-n4-supersession.2026-10-17T00-55.md
docs/features/active/2026-10-15-hook-test-isolation-737-remainder-935/evidence/other/variable-load-report.2026-10-16T21-46.md
docs/features/active/2026-10-15-hook-test-isolation-737-remainder-935/evidence/qa-gates/r4-main-plan-validation.2026-10-17T00-49.md
docs/features/active/2026-10-15-hook-test-isolation-737-remainder-935/evidence/qa-gates/r4-p1-ps-test.2026-10-17T00-32.md
docs/features/active/2026-10-15-hook-test-isolation-737-remainder-935/evidence/qa-gates/r4-p2-ps-analyze.2026-10-17T00-35.md
docs/features/active/2026-10-15-hook-test-isolation-737-remainder-935/evidence/qa-gates/r4-p2-ps-test.2026-10-17T00-45.md
docs/features/active/2026-10-15-hook-test-isolation-737-remainder-935/evidence/qa-gates/r4-perf-ps-analyze.2026-10-17T01-00.md
docs/features/active/2026-10-15-hook-test-isolation-737-remainder-935/evidence/qa-gates/r4-perf-ps-test.2026-10-17T01-07.md
docs/features/active/2026-10-15-hook-test-isolation-737-remainder-935/evidence/qa-gates/r4-perf-shuffled-run.2026-10-17T01-10.md
docs/features/active/2026-10-15-hook-test-isolation-737-remainder-935/evidence/qa-gates/r4-perf-status.2026-10-17T01-10.md
docs/features/active/2026-10-15-hook-test-isolation-737-remainder-935/evidence/qa-gates/r4-perf-timing-after.2026-10-17T01-09.md
docs/features/active/2026-10-15-hook-test-isolation-737-remainder-935/evidence/qa-gates/r4-perf-timing-before.2026-10-17T00-54.md
docs/features/active/2026-10-15-hook-test-isolation-737-remainder-935/evidence/qa-gates/s9-ac-verification.2026-10-16T21-46.md
docs/features/active/2026-10-15-hook-test-isolation-737-remainder-935/evidence/qa-gates/shuffled-suite-run-correction.2026-10-16T22-30.md
docs/features/active/2026-10-15-hook-test-isolation-737-remainder-935/evidence/qa-gates/shuffled-suite-run.2026-10-16T20-48.md
docs/features/active/2026-10-15-hook-test-isolation-737-remainder-935/evidence/regression-testing/r4-cr-f4-fail-before.2026-10-17T00-23.md
docs/features/active/2026-10-15-hook-test-isolation-737-remainder-935/feature-audit.2026-10-16T20-56.md
docs/features/active/2026-10-15-hook-test-isolation-737-remainder-935/issue.md
docs/features/active/2026-10-15-hook-test-isolation-737-remainder-935/plan.2026-10-15T17-44.md
docs/features/active/2026-10-15-hook-test-isolation-737-remainder-935/policy-audit.2026-10-16T20-56.md
docs/features/active/2026-10-15-hook-test-isolation-737-remainder-935/remediation-inputs.2026-10-16T20-56.md
docs/features/active/2026-10-15-hook-test-isolation-737-remainder-935/remediation-plan.2026-10-16T20-56.md
docs/features/active/2026-10-15-hook-test-isolation-737-remainder-935/spec.md
tests/scripts/claude-hooks/EpicStateIsolation.Compliance.Helpers.ps1
tests/scripts/claude-hooks/EpicStateIsolation.Discovery.Helpers.ps1
tests/scripts/claude-hooks/EpicStateIsolation.Helpers.ps1
tests/scripts/claude-hooks/EpicStateIsolation.HookReference.Helpers.ps1
tests/scripts/claude-hooks/enforce-epic-worktree-removal-gate.ManifestBranch.Tests.ps1
tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.Branches.Tests.ps1
tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.Discovery.Tests.ps1
tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.HookReference.Tests.ps1
exit 0
== git status --porcelain
 M docs/features/active/2026-10-15-hook-test-isolation-737-remainder-935/remediation-plan.2026-10-16T20-56.md
?? docs/features/active/2026-10-15-hook-test-isolation-737-remainder-935/evidence/qa-gates/r4-coverage-delta.2026-10-17T01-41.md
?? docs/features/active/2026-10-15-hook-test-isolation-737-remainder-935/evidence/qa-gates/r4-line-counts.2026-10-17T01-41.md
?? docs/features/active/2026-10-15-hook-test-isolation-737-remainder-935/evidence/qa-gates/r4-loop-status.2026-10-17T01-41.md
?? docs/features/active/2026-10-15-hook-test-isolation-737-remainder-935/evidence/qa-gates/r4-order-check.2026-10-17T01-27.md
?? docs/features/active/2026-10-15-hook-test-isolation-737-remainder-935/evidence/qa-gates/r4-ps-analyze.2026-10-17T01-12.md
?? docs/features/active/2026-10-15-hook-test-isolation-737-remainder-935/evidence/qa-gates/r4-ps-format.2026-10-17T01-12.md
?? docs/features/active/2026-10-15-hook-test-isolation-737-remainder-935/evidence/qa-gates/r4-ps-test-repo.2026-10-17T01-40.md
?? docs/features/active/2026-10-15-hook-test-isolation-737-remainder-935/evidence/qa-gates/r4-ps-test.2026-10-17T01-22.md
exit 0
== decision record in cycle diff (count):
0
== branch-diff paths outside FEATURE and the eight CODE8 paths (count):
0
```
