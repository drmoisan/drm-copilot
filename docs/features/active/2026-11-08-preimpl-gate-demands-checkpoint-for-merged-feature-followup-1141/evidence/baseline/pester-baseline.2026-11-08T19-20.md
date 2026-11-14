# Pester Phase 0 Baseline (issue #1141, [P0-T3])

Timestamp: 2026-11-08T19-20
Command: sh SCRATCH/issue-1141-pester.sh baseline (pwsh 7: Import-Module scripts/powershell/PoshQC/PoshQC.psd1 -Force; $result = Invoke-PoshQCParallelTest -Root <worktree root>; exit $result.ExitCode)
EXIT_CODE: 0
Output Summary:
- Invoke-PoshQCParallelTest returned ExitCode 0; workers=8; wall-clock=583.34s; merged JUnit and coverage written.
- JUnit (artifacts/pester/pester-junit.xml): tests=20271, failures=0, errors=0, disabled=10; passed=20261; failed=0.
- Failing tests: none.
- Repo-wide line coverage (artifacts/pester/powershell-coverage.xml): 95.66% (36229 covered, 1644 missed).
- .claude/hooks/hook-epic-fan-in.ps1: 100.00% (91/91).
- .codex/hooks/hook-epic-fan-in.ps1: 100.00% (91/91).
- .claude/hooks/enforce-orchestration-preimplementation-gate-epic-scope.ps1: 97.60% (122 covered, 3 missed).
- .codex/hooks/enforce-orchestration-preimplementation-gate-epic-scope.ps1: 97.92% (141 covered, 3 missed).
- The merged coverage and JUnit reports were copied to SCRATCH/issue-1141-coverage-baseline.xml and SCRATCH/issue-1141-junit-baseline.xml for [P5-T3].
