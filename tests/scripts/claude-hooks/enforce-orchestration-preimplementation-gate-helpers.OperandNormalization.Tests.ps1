#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

# Issue #732 (with #735) - operand normalization in the preimplementation gate helpers.
# Each case calls the pure function Test-ExemptOrchestrationStagingCommand directly, once
# against the Claude canonical copy and once against the Codex canonical copy, each resolved
# from this file's own directory with Join-Path. The file creates no file and starts no child
# process. An operand is exempt only when it is a plain forward-slash repository-relative path
# under an exempt orchestration tree; every shell-divergent shape (a backslash anywhere, and
# { } , ( ) @ outside quotes) denies because the executing shell is undetermined.

Describe 'preimplementation gate helpers operand normalization (<Surface>)' -ForEach @(
    @{ Surface = '.claude/hooks' }
    @{ Surface = '.codex/hooks' }
) {
    BeforeAll {
        $repoRoot = (Resolve-Path (Join-Path $PSScriptRoot '../../..')).Path
        $helpersPath = Join-Path (Join-Path $repoRoot $Surface) 'enforce-orchestration-preimplementation-gate-helpers.ps1'
        . $helpersPath
    }

    It 'denies <Label>' -ForEach @(
        @{ Label = 'the issue 732 brace-expansion shape'; Command = 'git add docs/features/active/{..,..}/{..,..}/{..,..}/src/prod.ts' }
        @{ Label = 'the issue 732 escaped dot-segment shape'; Command = 'git add docs/features/active/.\./.\./.\./src/x.ps1' }
        @{ Label = 'an escaped semicolon in a message'; Command = 'git commit -m a\;b -- docs/features/active/x/a.md' }
        @{ Label = 'an escaped ampersand in a message'; Command = 'git commit -m a\&b -- docs/features/active/x/a.md' }
        @{ Label = 'an escaped pipe in a message'; Command = 'git commit -m a\|b -- docs/features/active/x/a.md' }
        @{ Label = 'a mixed dot-backslash segment in an operand'; Command = 'git add docs/features/active/x/.\./a.md' }
        @{ Label = 'a backslash-spelled operand'; Command = 'git add docs\features\active\x\a.md' }
        @{ Label = 'a comma brace in an operand'; Command = 'git add docs/features/active/x/{a,b}.md' }
        @{ Label = 'a range brace in an operand'; Command = 'git add docs/features/active/x/{a..b}.md' }
        @{ Label = 'a brace in an unquoted message'; Command = 'git commit -m {a,b} -- docs/features/active/x/a.md' }
        @{ Label = 'an unquoted comma in a message'; Command = 'git commit -m a,b -- docs/features/active/x/a.md' }
        @{ Label = 'an unquoted at-sign name in a message'; Command = 'git commit -m @msg -- docs/features/active/x/a.md' }
        @{ Label = 'an unquoted opening parenthesis in a message'; Command = 'git commit -m a(b -- docs/features/active/x/a.md' }
        @{ Label = 'an unquoted closing parenthesis in a message'; Command = 'git commit -m a)b -- docs/features/active/x/a.md' }
        @{ Label = 'a star glob under an exempt tree'; Command = 'git add docs/features/active/x/*.md' }
        @{ Label = 'a question-mark glob under an exempt tree'; Command = 'git add docs/features/active/x/a?.md' }
        @{ Label = 'a bracket glob under an exempt tree'; Command = 'git add docs/features/active/x/[ab].md' }
        @{ Label = 'a leading slash'; Command = 'git add /docs/features/active/x/a.md' }
        @{ Label = 'a leading double slash'; Command = 'git add //docs/features/active/x/a.md' }
        @{ Label = 'a parent-directory segment'; Command = 'git add docs/features/active/../../src/x.ps1' }
        @{ Label = 'a drive-letter operand'; Command = 'git add C:/docs/features/active/x/a.md' }
        @{ Label = 'a tilde in an operand'; Command = 'git add docs/features/active/x/~a.md' }
        @{ Label = 'a percent sign in an operand'; Command = 'git add docs/features/active/x/%a.md' }
        @{ Label = 'a caret in an operand'; Command = 'git add docs/features/active/x/a^.md' }
        @{ Label = 'an exclamation mark in an operand'; Command = 'git add docs/features/active/x/a!.md' }
        @{ Label = 'an equals sign in an operand'; Command = 'git add docs/features/active/x/a=b.md' }
        @{ Label = 'a plus sign in an operand'; Command = 'git add docs/features/active/x/a+b.md' }
        @{ Label = 'a non-ASCII division-slash look-alike in an operand'; Command = ('git add docs/features/active/x/a' + [char]0x2215 + 'b.md') }
    ) {
        # Arrange
        $commandText = $Command

        # Act
        $isExempt = Test-ExemptOrchestrationStagingCommand -CommandText $commandText

        # Assert
        $isExempt | Should -BeFalse -Because "$Label is not a plain exempt operand (issues #732 and #735)"
    }

    It 'admits <Label>' -ForEach @(
        @{ Label = 'an ordinary operand under the epics tree'; Command = 'git add docs/features/epics/x/epic.md' }
        @{ Label = 'an ordinary operand under the parallel tree'; Command = 'git add docs/features/parallel/x/parallel.md' }
        @{ Label = 'an ordinary operand under the active tree'; Command = 'git add docs/features/active/x/spec.md' }
        @{ Label = 'an ordinary operand under the potential tree'; Command = 'git add docs/features/potential/x.md' }
        @{ Label = 'an ordinary operand under the orchestration artifacts tree'; Command = 'git add artifacts/orchestration/epic-orchestrator-state.json' }
        @{ Label = 'an operand with a dot segment inside an exempt tree'; Command = 'git add docs/features/active/x/./a.md' }
        @{ Label = 'a single-quoted message containing an opening brace'; Command = 'git commit -m ''a{b'' -- docs/features/active/x/a.md' }
        @{ Label = 'a single-quoted message containing a comma'; Command = 'git commit -m ''a,b'' -- docs/features/active/x/a.md' }
        @{ Label = 'a single-quoted message containing an opening parenthesis'; Command = 'git commit -m ''a(b'' -- docs/features/active/x/a.md' }
        @{ Label = 'a single-quoted message containing an at sign'; Command = 'git commit -m ''a@b'' -- docs/features/active/x/a.md' }
    ) {
        # Arrange
        $commandText = $Command

        # Act
        $isExempt = Test-ExemptOrchestrationStagingCommand -CommandText $commandText

        # Assert
        $isExempt | Should -BeTrue -Because "$Label is a plain operand under an exempt orchestration tree"
    }
}
