#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSReviewUnusedParameter', '', Justification = 'Injected CheckpointReader and FolderExistsCheck stubs mirror the production scriptblock signatures for testing')]
param()

<#
.SYNOPSIS
    Regression tests for issue #736: the Edit branch of
    enforce-completion-consistency.ps1 must apply exactly one occurrence of
    old_string unless replace_all is true.

.DESCRIPTION
    Covers the pure helpers Get-EditReplaceAllFlag and Invoke-SingleOccurrenceEdit
    and the decision-level behaviour of Invoke-CompletionConsistencyDecision.
    No row creates a temporary file, reads the working directory, or reads the
    live checkpoint: every decision row injects a CheckpointReader, a
    FolderExistsCheck, and a RoutingMatrixReader.
#>

Describe 'enforce-completion-consistency.ps1 edit semantics (issue #736)' {
    BeforeAll {
        $script:UnderTest = (Resolve-Path "$PSScriptRoot/../../../.claude/hooks/enforce-completion-consistency.ps1").Path
        . $script:UnderTest

        $script:AbsoluteTarget = '/work/item-worktree/artifacts/orchestration/orchestrator-state.json'
        $script:NonCompletionCheckpoint = '{"objective":"x","next_step":"S5_atomic_execution"}'
        $script:PatchOldString = '"next_step":"S5_atomic_execution"'
        $script:PatchToCompletion = '"next_step":"complete"'
        $script:AmbiguousText = '{"s8":"pending","s9":"pending","next_step":"S5_atomic_execution"}'
        $script:DuplicateText = '{"note":"S5","next_step":"S5"}'

        # Builds an Edit-shaped PreToolUse envelope. old_string and replace_all are
        # included only when the caller supplies them.
        function ConvertTo-EditEnvelopeJson {
            param(
                [Parameter(Mandatory)]
                [string] $FilePath,

                [Parameter(Mandatory)]
                [string] $NewString,

                [string] $OldString,

                [object] $ReplaceAll
            )
            $toolInput = [ordered]@{ file_path = $FilePath; new_string = $NewString }
            if ($PSBoundParameters.ContainsKey('OldString')) {
                $toolInput['old_string'] = $OldString
            }
            if ($PSBoundParameters.ContainsKey('ReplaceAll')) {
                $toolInput['replace_all'] = $ReplaceAll
            }
            return (@{ tool_name = 'Edit'; tool_input = $toolInput } | ConvertTo-Json -Compress -Depth 8)
        }

        # Evaluates one Edit against an injected checkpoint text.
        function Get-EditDecision {
            param(
                [Parameter(Mandatory)]
                [string] $Json,

                [Parameter(Mandatory)]
                [string] $CheckpointText
            )
            $reader = { param($Path) $CheckpointText }.GetNewClosure()
            return Invoke-CompletionConsistencyDecision -ToolInputRaw $Json -CheckpointReader $reader -FolderExistsCheck { param($p) $false } -RoutingMatrixReader { $null }
        }
    }

    It 'returns <Expected> from Get-EditReplaceAllFlag when replace_all is <Label>' -ForEach @(
        @{ Label = 'absent'; HasFlag = $false; Flag = $null; Expected = $false }
        @{ Label = 'boolean true'; HasFlag = $true; Flag = $true; Expected = $true }
        @{ Label = 'boolean false'; HasFlag = $true; Flag = $false; Expected = $false }
        @{ Label = 'the string true'; HasFlag = $true; Flag = 'true'; Expected = $true }
        @{ Label = 'the padded upper-case string TRUE'; HasFlag = $true; Flag = ' TRUE '; Expected = $true }
        @{ Label = 'the string false'; HasFlag = $true; Flag = 'false'; Expected = $false }
        @{ Label = 'the string yes'; HasFlag = $true; Flag = 'yes'; Expected = $false }
        @{ Label = 'the integer 1'; HasFlag = $true; Flag = 1; Expected = $false }
    ) {
        # Arrange
        $toolInput = [pscustomobject]@{}
        if ($HasFlag) {
            Add-Member -InputObject $toolInput -NotePropertyName 'replace_all' -NotePropertyValue $Flag
        }

        # Act
        $actual = Get-EditReplaceAllFlag -ToolInput $toolInput

        # Assert: the flag is a boolean and follows the documented table.
        $actual | Should -BeOfType [bool]
        $actual | Should -Be $Expected
    }

    It 'resolves <Label> through Get-EditReplaceAllFlag and Invoke-SingleOccurrenceEdit' -ForEach @(
        @{ Label = '0 occurrences without replace_all'; Text = 'alpha beta'; HasFlag = $false; Flag = $null; Content = $null; Failure = 'old_string-not-found' }
        @{ Label = '0 occurrences with replace_all false'; Text = 'alpha beta'; HasFlag = $true; Flag = $false; Content = $null; Failure = 'old_string-not-found' }
        @{ Label = '0 occurrences with replace_all true'; Text = 'alpha beta'; HasFlag = $true; Flag = $true; Content = $null; Failure = 'old_string-not-found' }
        @{ Label = '0 occurrences with replace_all string true'; Text = 'alpha beta'; HasFlag = $true; Flag = 'true'; Content = $null; Failure = 'old_string-not-found' }
        @{ Label = '0 occurrences with replace_all string false'; Text = 'alpha beta'; HasFlag = $true; Flag = 'false'; Content = $null; Failure = 'old_string-not-found' }
        @{ Label = '1 occurrence without replace_all'; Text = 'alpha ONE beta'; HasFlag = $false; Flag = $null; Content = 'alpha X beta'; Failure = $null }
        @{ Label = '1 occurrence with replace_all false'; Text = 'alpha ONE beta'; HasFlag = $true; Flag = $false; Content = 'alpha X beta'; Failure = $null }
        @{ Label = '1 occurrence with replace_all true'; Text = 'alpha ONE beta'; HasFlag = $true; Flag = $true; Content = 'alpha X beta'; Failure = $null }
        @{ Label = '1 occurrence with replace_all string true'; Text = 'alpha ONE beta'; HasFlag = $true; Flag = 'true'; Content = 'alpha X beta'; Failure = $null }
        @{ Label = '1 occurrence with replace_all string false'; Text = 'alpha ONE beta'; HasFlag = $true; Flag = 'false'; Content = 'alpha X beta'; Failure = $null }
        @{ Label = '2 occurrences without replace_all'; Text = 'alpha ONE beta ONE gamma'; HasFlag = $false; Flag = $null; Content = $null; Failure = 'old_string-ambiguous' }
        @{ Label = '2 occurrences with replace_all false'; Text = 'alpha ONE beta ONE gamma'; HasFlag = $true; Flag = $false; Content = $null; Failure = 'old_string-ambiguous' }
        @{ Label = '2 occurrences with replace_all true'; Text = 'alpha ONE beta ONE gamma'; HasFlag = $true; Flag = $true; Content = 'alpha X beta X gamma'; Failure = $null }
        @{ Label = '2 occurrences with replace_all string true'; Text = 'alpha ONE beta ONE gamma'; HasFlag = $true; Flag = 'true'; Content = 'alpha X beta X gamma'; Failure = $null }
        @{ Label = '2 occurrences with replace_all string false'; Text = 'alpha ONE beta ONE gamma'; HasFlag = $true; Flag = 'false'; Content = $null; Failure = 'old_string-ambiguous' }
    ) {
        # Arrange
        $toolInput = [pscustomobject]@{}
        if ($HasFlag) {
            Add-Member -InputObject $toolInput -NotePropertyName 'replace_all' -NotePropertyValue $Flag
        }
        $replaceAll = Get-EditReplaceAllFlag -ToolInput $toolInput

        # Act
        $result = Invoke-SingleOccurrenceEdit -Text $Text -OldString 'ONE' -NewString 'X' -ReplaceAll $replaceAll

        # Assert: content and failure follow the occurrence table.
        $result.Failure | Should -Be $Failure
        $result.Content | Should -Be $Content
    }

    It 'counts overlapping candidates once when replace_all is false' {
        # Arrange: aaa holds one non-overlapping aa.
        # Act
        $result = Invoke-SingleOccurrenceEdit -Text 'aaa' -OldString 'aa' -NewString 'b' -ReplaceAll $false

        # Assert: the single non-overlapping occurrence is replaced.
        $result.Failure | Should -BeNullOrEmpty
        $result.Content | Should -BeExactly 'ba'
    }

    It 'keeps dollar sequences in new_string literal' {
        # Arrange
        # Act
        $result = Invoke-SingleOccurrenceEdit -Text 'x1' -OldString 'x' -NewString '$0$1$&' -ReplaceAll $false

        # Assert: no regex substitution is applied to new_string.
        $result.Content | Should -BeExactly '$0$1$&1'
    }

    It 'keeps regular-expression metacharacters literal' {
        # Arrange
        # Act
        $result = Invoke-SingleOccurrenceEdit -Text 'f(a.b)g' -OldString '(a.b)' -NewString '.*+?[]' -ReplaceAll $false

        # Assert: old_string is matched literally and new_string is inserted literally.
        $result.Content | Should -BeExactly 'f.*+?[]g'
    }

    It 'matches CRLF text with an LF old_string' {
        # Arrange
        $text = "a`r`nb"

        # Act
        $result = Invoke-SingleOccurrenceEdit -Text $text -OldString "a`nb" -NewString 'c' -ReplaceAll $false

        # Assert: line endings are normalized before matching.
        $result.Content | Should -BeExactly 'c'
    }

    It 'emits LF line endings after normalizing CRLF text' {
        # Arrange
        $text = "x`r`ny"

        # Act
        $result = Invoke-SingleOccurrenceEdit -Text $text -OldString 'x' -NewString 'z' -ReplaceAll $false

        # Assert: the output carries LF only.
        $result.Content | Should -BeExactly "z`ny"
    }

    It 'denies an ambiguous patch without replace_all as old_string-ambiguous' {
        # Arrange
        $json = ConvertTo-EditEnvelopeJson -FilePath $script:AbsoluteTarget -OldString '"pending"' -NewString '"waiting"'

        # Act
        $result = Get-EditDecision -Json $json -CheckpointText $script:AmbiguousText

        # Assert: two occurrences without replace_all cannot be resolved.
        $result.hookSpecificOutput.permissionDecision | Should -Be 'deny'
        $result.hookSpecificOutput.permissionDecisionReason | Should -BeLike '*old_string-ambiguous*'
        $result.hookSpecificOutput.permissionDecisionReason | Should -BeLike '*replaced through an unresolved patch*'
    }

    It 'allows the same ambiguous patch when replace_all is boolean true' {
        # Arrange
        $json = ConvertTo-EditEnvelopeJson -FilePath $script:AbsoluteTarget -OldString '"pending"' -NewString '"waiting"' -ReplaceAll $true

        # Act
        $result = Get-EditDecision -Json $json -CheckpointText $script:AmbiguousText

        # Assert: the all-replaced content does not assert completion.
        $result.hookSpecificOutput.permissionDecision | Should -Be 'allow'
    }

    It 'allows the same ambiguous patch when replace_all is the string true' {
        # Arrange
        $json = ConvertTo-EditEnvelopeJson -FilePath $script:AbsoluteTarget -OldString '"pending"' -NewString '"waiting"' -ReplaceAll 'true'

        # Act
        $result = Get-EditDecision -Json $json -CheckpointText $script:AmbiguousText

        # Assert: the string true is honored as replace_all.
        $result.hookSpecificOutput.permissionDecision | Should -Be 'allow'
    }

    It 'denies the same ambiguous patch when replace_all is the string false' {
        # Arrange
        $json = ConvertTo-EditEnvelopeJson -FilePath $script:AbsoluteTarget -OldString '"pending"' -NewString '"waiting"' -ReplaceAll 'false'

        # Act
        $result = Get-EditDecision -Json $json -CheckpointText $script:AmbiguousText

        # Assert: the string false is not truthy.
        $result.hookSpecificOutput.permissionDecision | Should -Be 'deny'
        $result.hookSpecificOutput.permissionDecisionReason | Should -BeLike '*old_string-ambiguous*'
    }

    It 'evaluates a single-occurrence patch on the spliced content' {
        # Arrange
        $json = ConvertTo-EditEnvelopeJson -FilePath $script:AbsoluteTarget -OldString $script:PatchOldString -NewString $script:PatchToCompletion

        # Act
        $result = Get-EditDecision -Json $json -CheckpointText $script:NonCompletionCheckpoint

        # Assert: the spliced content asserts completion without evidence.
        $result.hookSpecificOutput.permissionDecision | Should -Be 'deny'
        $result.hookSpecificOutput.permissionDecisionReason | Should -BeLike '*ci_gate*'
    }

    It 'denies a patch whose old_string is absent as old_string-not-found' {
        # Arrange
        $json = ConvertTo-EditEnvelopeJson -FilePath $script:AbsoluteTarget -OldString 'this-substring-is-absent' -NewString $script:PatchToCompletion

        # Act
        $result = Get-EditDecision -Json $json -CheckpointText $script:NonCompletionCheckpoint

        # Assert: a patch that does not apply is denied with its cause.
        $result.hookSpecificOutput.permissionDecision | Should -Be 'deny'
        $result.hookSpecificOutput.permissionDecisionReason | Should -BeLike '*old_string-not-found*'
    }

    It 'returns a different decision for the same patch with and without replace_all' {
        # Arrange
        $withoutFlag = ConvertTo-EditEnvelopeJson -FilePath $script:AbsoluteTarget -OldString '"pending"' -NewString '"waiting"'
        $withFlag = ConvertTo-EditEnvelopeJson -FilePath $script:AbsoluteTarget -OldString '"pending"' -NewString '"waiting"' -ReplaceAll $true

        # Act
        $without = Get-EditDecision -Json $withoutFlag -CheckpointText $script:AmbiguousText
        $with = Get-EditDecision -Json $withFlag -CheckpointText $script:AmbiguousText

        # Assert: the decision depends on replace_all.
        $without.hookSpecificOutput.permissionDecision | Should -Be 'deny'
        $with.hookSpecificOutput.permissionDecision | Should -Be 'allow'
    }

    It 'evaluates a replace_all patch on the all-replaced content' {
        # Arrange: both occurrences of "S5" become "complete".
        $json = ConvertTo-EditEnvelopeJson -FilePath $script:AbsoluteTarget -OldString '"S5"' -NewString '"complete"' -ReplaceAll $true

        # Act
        $result = Get-EditDecision -Json $json -CheckpointText $script:DuplicateText

        # Assert: the all-replaced content asserts completion without evidence.
        $result.hookSpecificOutput.permissionDecision | Should -Be 'deny'
        $result.hookSpecificOutput.permissionDecisionReason | Should -BeLike '*ci_gate*'
    }
}
