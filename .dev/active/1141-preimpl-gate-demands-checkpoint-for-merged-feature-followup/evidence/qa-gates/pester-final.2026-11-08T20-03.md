# Pester Final Gate (issue #1141, [P5-T3])

Timestamp: 2026-11-08T20-03
Command: sh SCRATCH/issue-1141-pester.sh final (pwsh 7: Import-Module scripts/powershell/PoshQC/PoshQC.psd1 -Force; $result = Invoke-PoshQCParallelTest -Root <worktree root>; exit $result.ExitCode)
EXIT_CODE: 0
Output Summary:
- Invoke-PoshQCParallelTest returned ExitCode 0; workers=8; wall-clock=527.08s; merged JUnit and coverage written.
- JUnit (artifacts/pester/pester-junit.xml): tests=20462, failures=0, errors=0, disabled=10; passed=20452; failed=0. Baseline [P0-T3]: tests=20271, passed=20261, failed=0. No new failing test.
- Every [P1-T3] failing row (11 Claude, 7 Codex) now passes; the full run has zero failures, so every #1136 row of the EpicFanIn suites and every #539 row of the CommandExemption suites passes unchanged (AC-10).
- Repo-wide line coverage: 95.67% (36325 covered, 1644 missed); baseline 95.66% (36229 covered, 1644 missed). No drop.
- Changed-line coverage of hook-epic-fan-in.ps1 since the merge base of origin/main and HEAD, read per line from the XML: 54 of 54 instrumented added or changed lines covered (100.00%) in each of the .claude and .codex copies; threshold 90%.

| File | Baseline line coverage | Final line coverage | Changed/added lines covered |
| --- | --- | --- | --- |
| .claude/hooks/hook-epic-fan-in.ps1 | 100.00% (91/91) | 100.00% (136/136) | 54/54 (100.00%) |
| .codex/hooks/hook-epic-fan-in.ps1 | 100.00% (91/91) | 100.00% (136/136) | 54/54 (100.00%) |
| .claude/hooks/enforce-orchestration-preimplementation-gate-epic-scope.ps1 | 97.60% (122/125) | 97.66% (125/128) | 3/3 (100.00%) |
| .codex/hooks/enforce-orchestration-preimplementation-gate-epic-scope.ps1 | 97.92% (141/144) | 97.96% (144/147) | 3/3 (100.00%) |
| Repo-wide | 95.66% | 95.67% | n/a |

Changed-line method: `git diff -U0 <merge base> -- <file>` hunk ranges on the new side intersected with the `<line>` elements of the file's JaCoCo `sourcefile`; a line counts as covered when `ci` > 0. Baseline figures come from SCRATCH/issue-1141-coverage-baseline.xml ([P0-T3]); final figures from SCRATCH/issue-1141-coverage-final.xml (copy of this run's merged report).
