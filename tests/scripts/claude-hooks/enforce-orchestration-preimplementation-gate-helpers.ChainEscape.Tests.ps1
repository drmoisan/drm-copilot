#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

# Issue #710 - POSIX backslash escapes in the command-chain scanner of the preimplementation
# gate helpers module. Each case calls the pure functions Split-OrchestrationCommandLine and
# Test-ExemptOrchestrationStagingCommand directly, once against the Claude canonical copy and
# once against the Codex canonical copy, each resolved from this file's own directory with
# Join-Path. The cases read the two helper files only and start no child process. The two
# bundled copies are covered by the SHA256 identity case in the helpers parity suite.

Describe 'preimplementation gate helpers chain escapes (<Surface>)' -ForEach @(
    @{ Surface = '.claude/hooks' }
    @{ Surface = '.codex/hooks' }
) {
    BeforeAll {
        $repoRoot = (Resolve-Path (Join-Path $PSScriptRoot '../../..')).Path
        $helpersPath = Join-Path (Join-Path $repoRoot $Surface) 'enforce-orchestration-preimplementation-gate-helpers.ps1'
        . $helpersPath
    }

    It 'treats a mid-line escaped semicolon as literal' {
        # Arrange
        $commandText = 'find . -exec cmd {} \; -print'

        # Act
        $result = Split-OrchestrationCommandLine -CommandText $commandText

        # Assert
        $result.Balanced | Should -BeTrue
        @($result.Segments).Count | Should -Be 1 -Because 'an escaped semicolon is a literal character'
        $result.Segments[0] | Should -BeExactly $commandText
    }

    It 'treats an escaped ampersand as literal' {
        # Arrange
        $commandText = 'a\&b c'

        # Act
        $result = Split-OrchestrationCommandLine -CommandText $commandText

        # Assert
        @($result.Segments).Count | Should -Be 1 -Because 'an escaped ampersand is a literal character'
        $result.Segments[0] | Should -BeExactly $commandText
    }

    It 'treats an escaped pipe as literal' {
        # Arrange
        $commandText = 'a\|b c'

        # Act
        $result = Split-OrchestrationCommandLine -CommandText $commandText

        # Assert
        @($result.Segments).Count | Should -Be 1 -Because 'an escaped pipe is a literal character'
        $result.Segments[0] | Should -BeExactly $commandText
    }

    It 'treats backslash-newline as a line continuation' {
        # Arrange
        $commandText = 'a\' + [char]10 + 'b'

        # Act
        $result = Split-OrchestrationCommandLine -CommandText $commandText

        # Assert
        @($result.Segments).Count | Should -Be 1 -Because 'an escaped newline continues the line'
        $result.Segments[0] | Should -BeExactly $commandText
    }

    It 'still splits on unescaped <Operator>' -ForEach @(
        @{ Operator = ';'; CommandText = 'a; b' }
        @{ Operator = '&&'; CommandText = 'a && b' }
        @{ Operator = '||'; CommandText = 'a || b' }
        @{ Operator = '|'; CommandText = 'a | b' }
        @{ Operator = '&'; CommandText = 'a & b' }
    ) {
        # Act
        $result = Split-OrchestrationCommandLine -CommandText $CommandText

        # Assert
        $result.Balanced | Should -BeTrue
        @($result.Segments).Count | Should -Be 2 -Because "an unescaped $Operator is a chain operator"
    }

    It 'still splits after an escaped backslash' {
        # Arrange
        $commandText = 'a\\; b'

        # Act
        $result = Split-OrchestrationCommandLine -CommandText $commandText

        # Assert
        @($result.Segments).Count | Should -Be 2 -Because 'an escaped backslash leaves the semicolon live'
        $result.Segments[0] | Should -BeExactly 'a\\'
    }

    It 'does not split after an odd run of backslashes' {
        # Arrange
        $commandText = 'a\\\; b'

        # Act
        $result = Split-OrchestrationCommandLine -CommandText $commandText

        # Assert
        @($result.Segments).Count | Should -Be 1 -Because 'the third backslash escapes the semicolon'
    }

    It 'splits on the unescaped ampersand after an escaped one' {
        # Arrange
        $commandText = 'a\&& b'

        # Act
        $result = Split-OrchestrationCommandLine -CommandText $commandText

        # Assert
        @($result.Segments).Count | Should -Be 2 -Because 'only the first ampersand is escaped'
    }

    It 'keeps backslash literal inside single quotes' {
        # Arrange
        $commandText = '''a\''; b'

        # Act
        $result = Split-OrchestrationCommandLine -CommandText $commandText

        # Assert
        $result.Balanced | Should -BeTrue
        @($result.Segments).Count | Should -Be 2 -Because 'a backslash does not escape inside single quotes'
    }

    It 'consumes an escaped double quote inside double quotes' {
        # Arrange
        $commandText = '"a\"; b"'

        # Act
        $result = Split-OrchestrationCommandLine -CommandText $commandText

        # Assert
        $result.Balanced | Should -BeTrue -Because 'the escaped double quote does not close the span'
        @($result.Segments).Count | Should -Be 1
    }

    It 'does not open a quote on an unquoted escaped double quote' {
        # Arrange
        $commandText = 'a\"'

        # Act
        $result = Split-OrchestrationCommandLine -CommandText $commandText

        # Assert
        $result.Balanced | Should -BeTrue -Because 'an escaped double quote is a literal character'
        @($result.Segments).Count | Should -Be 1
    }

    It 'treats a trailing lone backslash as balanced' {
        # Arrange
        $commandText = 'a\'

        # Act
        $result = Split-OrchestrationCommandLine -CommandText $commandText

        # Assert
        $result.Balanced | Should -BeTrue
        @($result.Segments).Count | Should -Be 1
        $result.Segments[0] | Should -BeExactly $commandText
    }

    It 'returns no segments for an empty command' {
        # Act
        $result = Split-OrchestrationCommandLine -CommandText ''

        # Assert
        $result.Balanced | Should -BeTrue
        @($result.Segments).Count | Should -Be 0
    }

    It 'exempts a commit whose message contains an escaped semicolon' {
        # Arrange
        $commandText = 'git commit -m fix\;done -- docs/features/active/x/spec.md'

        # Act
        $isExempt = Test-ExemptOrchestrationStagingCommand -CommandText $commandText

        # Assert
        $isExempt | Should -BeTrue -Because 'the shell runs one git commit whose message is fix;done'
    }

    It 'does not exempt a chained command after an escaped backslash' {
        # Arrange
        $commandText = 'git commit -m fix\\; touch src/x -- docs/features/active/x/spec.md'

        # Act
        $isExempt = Test-ExemptOrchestrationStagingCommand -CommandText $commandText

        # Assert
        $isExempt | Should -BeFalse -Because 'the semicolon after an escaped backslash starts a second command'
    }
}
