# Phase 1 — Preimplementation-Gate Cleanup Sub-Code Tests

Timestamp: 2026-11-03T20-12
Command: sh SCRATCH/issue-1026-suites.sh p1t7r issue-1026-p1t7.txt (one fresh PowerShell 7 process: Invoke-Pester with JUnit output over the 12 suites below)
EXIT_CODE: 0

Suites: tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.Cleanup.Tests.ps1, tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-cleanup.Tests.ps1, tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.EpicScope.Tests.ps1, tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.EpicScopeTargets.Tests.ps1, tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-epic-scope.Tests.ps1, tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-epic-scope-targets.Tests.ps1, tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1, tests/scripts/claude-hooks/hook-cleanup-context.Parity.Tests.ps1, tests/scripts/claude-hooks/hook-dependency-failure.Claude.Tests.ps1, tests/scripts/codex-hooks/hook-dependency-failure.Codex.Tests.ps1, tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.Discovery.Tests.ps1, tests/scripts/claude-runtime/test-name-uniqueness.Tests.ps1.

JUnit `testsuites`: tests=964, failures=0, errors=0, disabled=0. Pester result: 964 passed, 0 failed, 0 failed containers.

New test names in the JUnit `testcase` names (status Passed on each surface):

| Test | Claude suite | Codex suite |
|---|---|---|
| appends CLEANUP_LEG_PATH_NOT_ALLOWLISTED to the deny for a non-allowlisted Write inside the consolidation worktree | Passed | Passed |
| keeps the exact deny text for the same Write beneath a non-consolidation worktree | Passed | Passed |

Deviation 1, run order: the first run of the same set (label p1t7) reported 962 passed and 2 failed. The two failures were `keeps enforce-orchestration-preimplementation-gate.ps1 byte-identical to its bundle copy` (Codex epic-scope suite) and `keeps the canonical hooks byte-identical to their bundled copies` (legacy Codex contracts). They failed because the plan copies the edited gates to `extensions/drm-copilot/resources/` in P4-T1, after this task. To meet this task's zero-failure condition, both edited gates were copied to their bundle paths before the re-run, as a mechanical micro-action. P4-T1 repeats and verifies that copy.

Deviation 2, JUnit location: the JUnit file of this targeted run was written under SCRATCH rather than `artifacts/pester/pester-junit.xml`, so the full-scan file is not overwritten.

Output Summary: 964 passed, 0 failed; both new test names pass on the Claude and the Codex surface.
