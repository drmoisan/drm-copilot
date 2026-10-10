#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSReviewUnusedParameter', '', Justification = 'Injected FolderExistsCheck and RoutingMatrixReader stubs mirror the production scriptblock signatures for testing')]
param()

<#
.SYNOPSIS
    Regression tests for issue #736: the default checkpoint reader of the Codex
    enforce-completion-consistency.ps1 must be exercised against real files.

.DESCRIPTION
    Every row reads a committed fixture under tests/fixtures/worktree-resolution
    through the default reader, addressed by an absolute path built from
    $PSScriptRoot. No row creates a temporary file, reads the working directory,
    or reads the live checkpoint.
#>

Describe 'enforce-completion-consistency.ps1 Codex default reader against committed fixtures (issue #736)' {
    BeforeAll {
        $script:UnderTest = (Resolve-Path "$PSScriptRoot/../../../.codex/hooks/enforce-completion-consistency.ps1").Path
        . $script:UnderTest
        Mock Get-CheckpointFileContent -ParameterFilter { $Path -notlike "$($script:FixturesRoot)*" } -MockWith { $null }

        $script:FixturesRoot = (Resolve-Path (Join-Path $PSScriptRoot '../../fixtures/worktree-resolution')).Path
        $script:NonEmptyFixture = Join-Path $script:FixturesRoot 'pr-author/item-own-not-ready/artifacts/orchestration/orchestrator-state.json'
        $script:EmptyFixture = Join-Path $script:FixturesRoot 'shared/item-own-empty/artifacts/orchestration/orchestrator-state.json'
        $script:InvalidFixture = Join-Path $script:FixturesRoot 'shared/item-own-invalid-json/artifacts/orchestration/orchestrator-state.json'
        $script:MissingFixture = Join-Path $script:FixturesRoot 'shared/item-own-absent/artifacts/orchestration/orchestrator-state.json'

        # Builds a mapped Edit record; replace_all is included only when the
        # caller supplies it.
        function ConvertTo-MappedEditJson {
            param(
                [Parameter(Mandatory)]
                [string] $FilePath,

                [Parameter(Mandatory)]
                [string] $OldString,

                [Parameter(Mandatory)]
                [string] $NewString,

                [object] $ReplaceAll
            )
            $record = [ordered]@{ file_path = $FilePath; old_string = $OldString; new_string = $NewString }
            if ($PSBoundParameters.ContainsKey('ReplaceAll')) {
                $record['replace_all'] = $ReplaceAll
            }
            return ($record | ConvertTo-Json -Compress -Depth 8)
        }

        # Runs the decision with the default reader and hermetic seams.
        function Get-DefaultReaderDecision {
            param(
                [Parameter(Mandatory)]
                [string] $Json
            )
            return Invoke-CompletionConsistencyDecision -ToolInputRaw $Json -FolderExistsCheck { param($p) $true } -RoutingMatrixReader { $null }
        }
    }

    It 'fixture precondition: the committed checkpoint fixtures still contain the expected tokens' {
        # Arrange
        $nonEmpty = [System.IO.File]::ReadAllText($script:NonEmptyFixture)
        $empty = [System.IO.File]::ReadAllText($script:EmptyFixture)
        $invalid = [System.IO.File]::ReadAllText($script:InvalidFixture)

        # Act
        $nextStepCount = [regex]::Matches($nonEmpty, [regex]::Escape('"next_step": "S8_create_pr"')).Count
        $notStartedCount = [regex]::Matches($nonEmpty, [regex]::Escape('"not_started"')).Count

        # Assert: each message names the fixture whose content changed.
        $nextStepCount | Should -Be 1 -Because 'the not-ready fixture must contain the next_step S8_create_pr token once'
        $notStartedCount | Should -Be 2 -Because 'the not-ready fixture must contain the not_started token twice'
        $nonEmpty | Should -Not -BeLike '*ci_gate*' -Because 'the not-ready fixture must not contain ci_gate'
        $empty.Length | Should -Be 0 -Because 'the item-own-empty fixture must stay a zero-byte file'
        $invalid | Should -BeLike '*this is not valid json*' -Because 'the item-own-invalid-json fixture must contain the invalid-JSON token'
    }

    It 'denies an Edit to complete on the non-empty fixture and names ci_gate' {
        # Arrange
        $json = ConvertTo-MappedEditJson -FilePath $script:NonEmptyFixture -OldString '"next_step": "S8_create_pr"' -NewString '"next_step": "complete"'

        # Act
        $result = Get-DefaultReaderDecision -Json $json

        # Assert: the decision names ci_gate, which proves the file was read.
        $result.hookSpecificOutput.permissionDecision | Should -Be 'deny'
        $result.hookSpecificOutput.permissionDecisionReason | Should -BeLike '*ci_gate*'
    }

    It 'allows an Edit to a non-completion value on the non-empty fixture' {
        # Arrange
        $json = ConvertTo-MappedEditJson -FilePath $script:NonEmptyFixture -OldString '"issue-num": "901"' -NewString '"issue-num": "902"'

        # Act
        $result = Get-DefaultReaderDecision -Json $json

        # Assert: the patched content does not assert completion.
        $result.hookSpecificOutput.permissionDecision | Should -Be 'allow'
    }

    It 'denies the not_started to pending Edit as old_string-ambiguous without replace_all and allows it with replace_all true' {
        # Arrange
        $withoutFlag = ConvertTo-MappedEditJson -FilePath $script:NonEmptyFixture -OldString '"not_started"' -NewString '"pending"'
        $withFlag = ConvertTo-MappedEditJson -FilePath $script:NonEmptyFixture -OldString '"not_started"' -NewString '"pending"' -ReplaceAll $true

        # Act
        $without = Get-DefaultReaderDecision -Json $withoutFlag
        $with = Get-DefaultReaderDecision -Json $withFlag

        # Assert: two occurrences need replace_all.
        $without.hookSpecificOutput.permissionDecision | Should -Be 'deny'
        $without.hookSpecificOutput.permissionDecisionReason | Should -BeLike '*old_string-ambiguous*'
        $with.hookSpecificOutput.permissionDecision | Should -Be 'allow'
    }

    It 'denies an Edit on the empty fixture as checkpoint-empty' {
        # Arrange
        $json = ConvertTo-MappedEditJson -FilePath $script:EmptyFixture -OldString 'a' -NewString 'b'

        # Act
        $result = Get-DefaultReaderDecision -Json $json

        # Assert: a zero-byte checkpoint is denied with its cause.
        $result.hookSpecificOutput.permissionDecision | Should -Be 'deny'
        $result.hookSpecificOutput.permissionDecisionReason | Should -BeLike '*checkpoint-empty*'
    }

    It 'denies an Edit on a missing fixture path as checkpoint-missing' {
        # Arrange
        $json = ConvertTo-MappedEditJson -FilePath $script:MissingFixture -OldString 'a' -NewString 'b'

        # Act
        $result = Get-DefaultReaderDecision -Json $json

        # Assert: an absent checkpoint is denied with its cause.
        $result.hookSpecificOutput.permissionDecision | Should -Be 'deny'
        $result.hookSpecificOutput.permissionDecisionReason | Should -BeLike '*checkpoint-missing*'
    }

    It 'denies an Edit on the invalid-JSON fixture whose patched content is not valid JSON as must remain valid JSON' {
        # Arrange
        $json = ConvertTo-MappedEditJson -FilePath $script:InvalidFixture -OldString 'this is not valid json' -NewString 'still not valid json'

        # Act
        $result = Get-DefaultReaderDecision -Json $json

        # Assert: the Codex hook denies content that is not valid JSON.
        $result.hookSpecificOutput.permissionDecision | Should -Be 'deny'
        $result.hookSpecificOutput.permissionDecisionReason | Should -BeLike '*must remain valid JSON*'
    }
}
