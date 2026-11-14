# Fail-Before — SkillText Suite Before the Brief Edit (P1-T2, expect-fail)

Timestamp: 2026-11-03T21-51
Command: sh SCRATCH/issue-1026-skilltext.sh failbefore (PowerShell 7 Invoke-Pester over tests/scripts/claude-hooks/cleanup-merged-worktrees.SkillText.Tests.ps1, JUnit to SCRATCH/issue-1026-skilltext-failbefore.xml)
EXIT_CODE: 1
ExpectedExitCode: 1
Output Summary: JUnit tests=12 failures=1 errors=0; Pester total 12, passed 11, failed 1. The single failing test is the updated test; the first new assertion (`only after a cleanup leg has identified the consolidation worktree as the target and a later condition fails`) did not match the unedited Hook Execution Context section.

- Failing test: `cleanup-merged-worktrees skill text (issue #1026).execution-environment brief.states the published-head condition and the consolidation sub-code in Hook Execution Context`
- Every other test in the file (11) passed.
