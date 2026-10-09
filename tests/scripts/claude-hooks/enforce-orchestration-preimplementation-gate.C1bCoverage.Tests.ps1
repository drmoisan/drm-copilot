#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

# Issue #732 (C1b, with #738) - coverage remediation rows for the preimplementation gate targets
# module. Each row drives a line that the section-5.7 suite leaves unexecuted through the module's
# public functions, once against the Claude copy and once against the Codex copy, with the C1a
# scanner and matcher dot-sourced from the same surface. The file creates no file and starts no
# child process.

Describe 'preimplementation gate targets coverage remediation (<Surface>)' -ForEach @(
    @{ Surface = '.claude/hooks' }
    @{ Surface = '.codex/hooks' }
) {
    BeforeAll {
        $repoRoot = (Resolve-Path (Join-Path $PSScriptRoot '../../..')).Path
        $surfaceRoot = Join-Path $repoRoot $Surface
        . (Join-Path $surfaceRoot 'hook-command-scanner.ps1')
        . (Join-Path $surfaceRoot 'hook-command-invocation.ps1')
        . (Join-Path $surfaceRoot 'enforce-orchestration-preimplementation-gate-targets.ps1')
    }

    It 'removes one trailing slash from <Label>' -ForEach @(
        @{ Label = 'a rooted path'; Path = '/synthetic-worktrees/session/'; Expected = '/synthetic-worktrees/session' }
        @{ Label = 'a backslash-spelled drive path'; Path = 'C:\wt\'; Expected = 'C:/wt' }
    ) {
        # Arrange
        $path = $Path

        # Act
        $normalized = ConvertTo-OrchestrationTargetPath -Path $path

        # Assert
        $normalized | Should -BeExactly $Expected -Because "$Label keeps no trailing separator after normalization"
    }

    It 'keeps <Label> unchanged' -ForEach @(
        @{ Label = 'the bare POSIX root'; Path = '/' }
        @{ Label = 'a bare drive root'; Path = 'C:/' }
    ) {
        # Arrange
        $path = $Path

        # Act
        $normalized = ConvertTo-OrchestrationTargetPath -Path $path

        # Assert
        $normalized | Should -BeExactly $Path -Because "$Label is a root whose separator is significant"
    }

    It 'resolves a segment without -C to a session root given with a trailing slash' {
        # Arrange
        $sessionRoot = '/synthetic-worktrees/session/'

        # Act
        $result = Get-OrchestrationCommandTarget -Command 'git add a.ps1' -SessionRoot $sessionRoot

        # Assert
        $result.Resolved | Should -BeTrue -Because 'a trailing slash does not make the session root unresolvable'
        $result.Targets | Should -Be @('/synthetic-worktrees/session') -Because 'the session root target carries no trailing slash'
    }
}
