# R1 Scope (P4-T6)

Timestamp: 2026-10-16T06-27
Command: git diff --name-only 3cea50483f9708e490d2214a700e38ca5f36b2aa..HEAD; git diff --name-only origin/main...HEAD; git status --porcelain (HEAD 78e5f6d4e)
EXIT_CODE: 0
Output Summary:
- All three commands exited 0.
- Porcelain: only paths under FEATURE (the remediation plan and five new `qa-gates/r1-*` artifacts); no path outside `FEATURE/`.
- Cycle diff (`3cea50483..HEAD`): the seven edited code files of this cycle plus 16 paths under `FEATURE/`.
- Branch diff (`origin/main...HEAD`): the 18 spec Write-Set code paths plus paths under `FEATURE/`. No path begins `.claude/`, `.codex/`, `.github/`, `extensions/`, `scripts/` or `config/`; no AC-6 suite, no `validate-` suite, no `hook-dependency-failure` suite, no `enforce-orchestration-preimplementation-gate-modes` suite, and not `tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-epic-scope.Tests.ps1`.
- Result: acceptance holds.

`FEATURE` = `docs/features/active/2026-10-15-hook-test-isolation-737-remainder-935`.

## git status --porcelain

```
 M FEATURE/remediation-plan.2026-10-16T03-40.md
?? FEATURE/evidence/qa-gates/r1-line-counts.2026-10-16T06-27.md
?? FEATURE/evidence/qa-gates/r1-loop-status.2026-10-16T06-26.md
?? FEATURE/evidence/qa-gates/r1-ps-analyze.2026-10-16T06-11.md
?? FEATURE/evidence/qa-gates/r1-ps-format.2026-10-16T06-10.md
?? FEATURE/evidence/qa-gates/r1-ps-test.2026-10-16T06-26.md
```

## git diff --name-only 3cea50483f9708e490d2214a700e38ca5f36b2aa..HEAD

```
FEATURE/evidence/baseline/r1-branch-state.2026-10-16T04-37.md
FEATURE/evidence/baseline/r1-coverage-baseline.2026-10-16T04-40.md
FEATURE/evidence/baseline/r1-coverage-population.2026-10-16T04-39.md
FEATURE/evidence/baseline/r1-line-counts.2026-10-16T04-38.md
FEATURE/evidence/baseline/r1-phase0-instructions-read.2026-10-16T04-37.md
FEATURE/evidence/baseline/r1-ps-analyze.2026-10-16T04-44.md
FEATURE/evidence/baseline/r1-ps-format.2026-10-16T04-40.md
FEATURE/evidence/baseline/r1-ps-test.2026-10-16T05-11.md
FEATURE/evidence/baseline/r1-token-counts.2026-10-16T04-38.md
FEATURE/evidence/other/r1-dispositions.2026-10-16T05-13.md
FEATURE/evidence/qa-gates/r1-fixture-names.2026-10-16T05-47.md
FEATURE/evidence/qa-gates/r1-p1-ps-test.2026-10-16T05-30.md
FEATURE/evidence/qa-gates/r1-p2-ps-test.2026-10-16T05-46.md
FEATURE/evidence/qa-gates/r1-p3-ps-test.2026-10-16T06-09.md
FEATURE/evidence/regression-testing/r1-cr-n3-fail-before.2026-10-16T05-56.md
FEATURE/remediation-plan.2026-10-16T03-40.md
tests/scripts/claude-hooks/EpicStateIsolation.Discovery.Helpers.ps1
tests/scripts/claude-hooks/EpicStateIsolation.Helpers.ps1
tests/scripts/claude-hooks/EpicStateIsolation.HookReference.Helpers.ps1
tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.Branches.Tests.ps1
tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.HookReference.Tests.ps1
tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.Predicate.Tests.ps1
tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.Tests.ps1
```

## git diff --name-only origin/main...HEAD (code paths; the remaining 59 entries are under FEATURE/)

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
