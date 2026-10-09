#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSReviewUnusedParameter', '', Justification = 'Injected CheckpointReader and FolderExistsCheck stubs mirror the production scriptblock signatures for testing')]
param()

<#
.SYNOPSIS
    Regression tests for issue #736: the Codex completion-consistency hook must
    fail closed with a named cause when the targeted checkpoint cannot be read or
    an Edit cannot be resolved.

.DESCRIPTION
    Every row calls Invoke-CompletionConsistencyDecision with a mapped record, an
    injected CheckpointReader, FolderExistsCheck, and RoutingMatrixReader. No row
    creates a temporary file, reads the working directory, or reads the live
    checkpoint.
#>

Describe 'enforce-completion-consistency.ps1 Codex fail-closed checkpoint handling (issue #736)' {
    BeforeAll {
        $script:UnderTest = (Resolve-Path "$PSScriptRoot/../../../.codex/hooks/enforce-completion-consistency.ps1").Path
        . $script:UnderTest

        $script:AbsoluteTarget = '/work/item-worktree/artifacts/orchestration/orchestrator-state.json'
        $script:RelativeTarget = 'artifacts/orchestration/orchestrator-state.json'
        $script:NullReader = { param($Path) $null }
        $script:EmptyReader = { param($Path) '' }
        $script:ThrowingReader = { param($Path) throw 'simulated unreadable checkpoint' }
        $script:MustNotRunReader = { param($Path) throw 'reader must not be invoked' }
        $script:NonCompletionReader = { param($Path) '{"objective":"x","next_step":"S5_atomic_execution"}' }

        # Builds a mapped record. Each field is included only when the caller
        # supplies it.
        function ConvertTo-MappedRecordJson {
            param(
                [string] $FilePath,

                [string] $NewString,

                [string] $OldString,

                [string] $Content
            )
            $record = [ordered]@{}
            if ($PSBoundParameters.ContainsKey('FilePath')) {
                $record['file_path'] = $FilePath
            }
            if ($PSBoundParameters.ContainsKey('NewString')) {
                $record['new_string'] = $NewString
            }
            if ($PSBoundParameters.ContainsKey('OldString')) {
                $record['old_string'] = $OldString
            }
            if ($PSBoundParameters.ContainsKey('Content')) {
                $record['content'] = $Content
            }
            return ($record | ConvertTo-Json -Compress -Depth 8)
        }

        function Get-ReaderDecision {
            param(
                [Parameter(Mandatory)]
                [string] $Json,

                [Parameter(Mandatory)]
                [scriptblock] $Reader
            )
            return Invoke-CompletionConsistencyDecision -ToolInputRaw $Json -CheckpointReader $Reader -FolderExistsCheck { param($p) $false } -RoutingMatrixReader { $null }
        }
    }

    It 'denies an Edit as checkpoint-missing when the reader returns null' {
        # Arrange
        $json = ConvertTo-MappedRecordJson -FilePath $script:AbsoluteTarget -OldString 'a' -NewString 'b'

        # Act
        $result = Get-ReaderDecision -Json $json -Reader $script:NullReader

        # Assert: a missing checkpoint is denied with its cause.
        $result.hookSpecificOutput.permissionDecision | Should -Be 'deny'
        $result.hookSpecificOutput.permissionDecisionReason | Should -BeLike 'COMPLETION_CONSISTENCY_BLOCKED:*'
        $result.hookSpecificOutput.permissionDecisionReason | Should -BeLike '*replaced through an unresolved patch*'
        $result.hookSpecificOutput.permissionDecisionReason | Should -BeLike '*checkpoint-missing*'
    }

    It 'denies an Edit as checkpoint-empty when the reader returns an empty string' {
        # Arrange
        $json = ConvertTo-MappedRecordJson -FilePath $script:AbsoluteTarget -OldString 'a' -NewString 'b'

        # Act
        $result = Get-ReaderDecision -Json $json -Reader $script:EmptyReader

        # Assert: an empty checkpoint is denied with its cause.
        $result.hookSpecificOutput.permissionDecision | Should -Be 'deny'
        $result.hookSpecificOutput.permissionDecisionReason | Should -BeLike 'COMPLETION_CONSISTENCY_BLOCKED:*'
        $result.hookSpecificOutput.permissionDecisionReason | Should -BeLike '*replaced through an unresolved patch*'
        $result.hookSpecificOutput.permissionDecisionReason | Should -BeLike '*checkpoint-empty*'
    }

    It 'does not throw when the reader throws for the targeted checkpoint' {
        # Arrange
        $json = ConvertTo-MappedRecordJson -FilePath $script:AbsoluteTarget -OldString 'a' -NewString 'b'
        $reader = $script:ThrowingReader

        # Act
        $act = { Get-ReaderDecision -Json $json -Reader $reader }

        # Assert: the reader exception does not escape the decision.
        $act | Should -Not -Throw
    }

    It 'denies an Edit as checkpoint-unreadable when the reader throws' {
        # Arrange
        $json = ConvertTo-MappedRecordJson -FilePath $script:AbsoluteTarget -OldString 'a' -NewString 'b'

        # Act
        $result = Get-ReaderDecision -Json $json -Reader $script:ThrowingReader

        # Assert: an unreadable checkpoint is denied with its cause.
        $result.hookSpecificOutput.permissionDecision | Should -Be 'deny'
        $result.hookSpecificOutput.permissionDecisionReason | Should -BeLike 'COMPLETION_CONSISTENCY_BLOCKED:*'
        $result.hookSpecificOutput.permissionDecisionReason | Should -BeLike '*replaced through an unresolved patch*'
        $result.hookSpecificOutput.permissionDecisionReason | Should -BeLike '*checkpoint-unreadable*'
    }

    It 'denies an Edit as no-old_string when old_string is absent' {
        # Arrange
        $json = ConvertTo-MappedRecordJson -FilePath $script:AbsoluteTarget -NewString 'b'

        # Act
        $result = Get-ReaderDecision -Json $json -Reader $script:NonCompletionReader

        # Assert: an Edit without old_string is denied with its cause.
        $result.hookSpecificOutput.permissionDecision | Should -Be 'deny'
        $result.hookSpecificOutput.permissionDecisionReason | Should -BeLike 'COMPLETION_CONSISTENCY_BLOCKED:*'
        $result.hookSpecificOutput.permissionDecisionReason | Should -BeLike '*replaced through an unresolved patch*'
        $result.hookSpecificOutput.permissionDecisionReason | Should -BeLike '*no-old_string*'
    }

    It 'denies an Edit as no-old_string when old_string is empty' {
        # Arrange
        $json = ConvertTo-MappedRecordJson -FilePath $script:AbsoluteTarget -OldString '' -NewString 'b'

        # Act
        $result = Get-ReaderDecision -Json $json -Reader $script:NonCompletionReader

        # Assert: an Edit with an empty old_string is denied with its cause.
        $result.hookSpecificOutput.permissionDecision | Should -Be 'deny'
        $result.hookSpecificOutput.permissionDecisionReason | Should -BeLike 'COMPLETION_CONSISTENCY_BLOCKED:*'
        $result.hookSpecificOutput.permissionDecisionReason | Should -BeLike '*replaced through an unresolved patch*'
        $result.hookSpecificOutput.permissionDecisionReason | Should -BeLike '*no-old_string*'
    }

    It 'denies a Write with an empty content property as write-content-empty' {
        # Arrange
        $json = ConvertTo-MappedRecordJson -FilePath $script:RelativeTarget -Content ''

        # Act
        $result = Get-ReaderDecision -Json $json -Reader $script:MustNotRunReader

        # Assert: emptying the checkpoint through a Write is denied with its cause.
        $result.hookSpecificOutput.permissionDecision | Should -Be 'deny'
        $result.hookSpecificOutput.permissionDecisionReason | Should -BeLike 'COMPLETION_CONSISTENCY_BLOCKED:*'
        $result.hookSpecificOutput.permissionDecisionReason | Should -BeLike '*replaced through an unresolved patch*'
        $result.hookSpecificOutput.permissionDecisionReason | Should -BeLike '*write-content-empty*'
    }

    It 'denies an Edit as old_string-not-found when old_string is absent from the checkpoint' {
        # Arrange
        $json = ConvertTo-MappedRecordJson -FilePath $script:AbsoluteTarget -OldString 'this-substring-is-absent' -NewString 'b'

        # Act
        $result = Get-ReaderDecision -Json $json -Reader $script:NonCompletionReader

        # Assert: a patch that does not apply is denied with its cause.
        $result.hookSpecificOutput.permissionDecision | Should -Be 'deny'
        $result.hookSpecificOutput.permissionDecisionReason | Should -BeLike 'COMPLETION_CONSISTENCY_BLOCKED:*'
        $result.hookSpecificOutput.permissionDecisionReason | Should -BeLike '*replaced through an unresolved patch*'
        $result.hookSpecificOutput.permissionDecisionReason | Should -BeLike '*old_string-not-found*'
    }

    It 'allows a non-checkpoint file_path without invoking the reader' {
        # Arrange
        $json = ConvertTo-MappedRecordJson -FilePath 'some/other/file.json' -OldString 'a' -NewString 'b'

        # Act
        $result = Get-ReaderDecision -Json $json -Reader $script:MustNotRunReader

        # Assert: the gate does not apply to other files.
        $result.hookSpecificOutput.permissionDecision | Should -Be 'allow'
    }

    It 'allows a tool_input with no file_path without invoking the reader' {
        # Arrange
        $json = ConvertTo-MappedRecordJson -OldString 'a' -NewString 'b'

        # Act
        $result = Get-ReaderDecision -Json $json -Reader $script:MustNotRunReader

        # Assert: a tool_input without a target is outside the gate.
        $result.hookSpecificOutput.permissionDecision | Should -Be 'allow'
    }

    It 'allows an epic checkpoint file_path without invoking the reader' {
        # Arrange
        $json = ConvertTo-MappedRecordJson -FilePath 'artifacts/orchestration/epic-orchestrator-state.json' -OldString 'a' -NewString 'b'

        # Act
        $result = Get-ReaderDecision -Json $json -Reader $script:MustNotRunReader

        # Assert: the epic checkpoint is not the canonical checkpoint.
        $result.hookSpecificOutput.permissionDecision | Should -Be 'allow'
    }

    It 'denies an Edit whose patched content is not valid JSON as must remain valid JSON' {
        # Arrange: replacing 1 with an opening brace leaves invalid JSON.
        $reader = { param($Path) '{"a":1}' }
        $json = ConvertTo-MappedRecordJson -FilePath $script:AbsoluteTarget -OldString '1' -NewString '{'

        # Act
        $result = Get-ReaderDecision -Json $json -Reader $reader

        # Assert: the Codex hook denies content that is not valid JSON.
        $result.hookSpecificOutput.permissionDecision | Should -Be 'deny'
        $result.hookSpecificOutput.permissionDecisionReason | Should -BeLike '*must remain valid JSON*'
    }

    It 'allows a Write whose content does not assert completion' {
        # Arrange
        $json = ConvertTo-MappedRecordJson -FilePath $script:RelativeTarget -Content '{"next_step":"S5_atomic_execution"}'

        # Act
        $result = Get-ReaderDecision -Json $json -Reader $script:MustNotRunReader

        # Assert: a non-completion Write follows the existing allow path.
        $result.hookSpecificOutput.permissionDecision | Should -Be 'allow'
    }
}
