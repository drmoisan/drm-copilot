Timestamp: 2026-08-12T09:20:58.5553326-04:00
Command: Import-Module Pester -MinimumVersion 5.0 -Force; $configuration = @{ Run = @{ Path = 'tests/scripts/codex-hooks/parallel-child-worktree-launcher.Tests.ps1'; PassThru = $true }; Filter = @{ FullName = '*completes child outcomes and exercises persistence and worktree boundaries*' }; Output = @{ Verbosity = 'Detailed' } }; $result = Invoke-Pester -Configuration $configuration; exit ([int]($result.FailedCount -gt 0))
EXIT_CODE: 1
Output Summary: Expected-red proof passed. Pester discovered 12 tests, selected 1 focused completion-boundary test, and reported 0 passed, 1 failed, and 11 not run. The selected test failed because Complete-CodexParallelChildProcess did not accept the injected WriteText callback required to test output persistence without filesystem I/O.
Failure: ParameterBindingException: A parameter cannot be found that matches parameter name 'WriteText'.
