#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSReviewUnusedParameter', '', Justification = 'Injected FolderExistsCheck and CheckpointReader stubs mirror the production scriptblock signatures for testing')]
param()

<#
.SYNOPSIS
    Regression tests for issue #708: the Edit branch of
    enforce-completion-consistency.ps1 must read the checkpoint at the Edit's
    targeted file_path rather than at a fixed relative literal.

.DESCRIPTION
    Every test supplies an injected path-keyed CheckpointReader scriptblock, so
    the file performs no filesystem access and does not depend on the working
    directory. Fixture paths are pure strings that are never resolved on disk.
#>

Describe 'enforce-completion-consistency.ps1 Edit target path (issue #708)' {
    BeforeAll {
        $script:UnderTest = (Resolve-Path "$PSScriptRoot/../../../.claude/hooks/enforce-completion-consistency.ps1").Path
        . $script:UnderTest

        $script:AbsoluteTarget = '/work/item-worktree/artifacts/orchestration/orchestrator-state.json'
        $script:BackslashTarget = '\work\item-worktree\artifacts\orchestration\orchestrator-state.json'
        $script:RelativeTarget = 'artifacts/orchestration/orchestrator-state.json'
        $script:NonCompletionCheckpoint = '{"objective":"x","next_step":"S5_atomic_execution"}'
        $script:CompletionCheckpoint = '{"objective":"x","next_step":"S5_atomic_execution","step8_status":"completed"}'
        $script:AnchorlessCheckpoint = '{"objective":"x","next_step":"S6_review"}'
        $script:PatchOldString = '"next_step":"S5_atomic_execution"'
        $script:PatchToCompletion = '"next_step":"complete"'
        $script:PatchNotCompletion = '"next_step":"S6_review"'

        # Builds an Edit-shaped PreToolUse envelope. old_string is included only
        # when the caller supplies it.
        function ConvertTo-EditToolInputJson {
            param(
                [Parameter(Mandatory)]
                [string] $FilePath,

                [Parameter(Mandatory)]
                [string] $NewString,

                [string] $OldString
            )
            $toolInput = [ordered]@{ file_path = $FilePath; new_string = $NewString }
            if ($PSBoundParameters.ContainsKey('OldString')) {
                $toolInput['old_string'] = $OldString
            }
            return (@{ tool_name = 'Edit'; tool_input = $toolInput } | ConvertTo-Json -Compress -Depth 8)
        }
    }

    It 'denies a completion-asserting Edit when the checkpoint exists only at the absolute targeted file_path' {
        # Arrange: only the absolute target holds a checkpoint; the patch asserts completion.
        $map = @{ $script:AbsoluteTarget = $script:NonCompletionCheckpoint }
        $reader = { param($Path) $map[$Path] }.GetNewClosure()
        $json = ConvertTo-EditToolInputJson -FilePath $script:AbsoluteTarget -OldString $script:PatchOldString -NewString $script:PatchToCompletion

        # Act
        $result = Invoke-CompletionConsistencyDecision -ToolInputRaw $json -CheckpointReader $reader -FolderExistsCheck { param($p) $false }

        # Assert: the patched content lacks completion evidence, so the Edit is denied.
        $result.hookSpecificOutput.permissionDecision | Should -Be 'deny'
        $result.hookSpecificOutput.permissionDecisionReason | Should -BeLike '*COMPLETION_CONSISTENCY_BLOCKED*'
    }

    It 'derives a deny from the targeted file_path content when the relative literal holds different content' {
        # Arrange: the absolute target already asserts completion; the relative literal does not.
        $map = @{
            $script:AbsoluteTarget = $script:CompletionCheckpoint
            $script:RelativeTarget = $script:NonCompletionCheckpoint
        }
        $reader = { param($Path) $map[$Path] }.GetNewClosure()
        $json = ConvertTo-EditToolInputJson -FilePath $script:AbsoluteTarget -OldString $script:PatchOldString -NewString $script:PatchNotCompletion

        # Act
        $result = Invoke-CompletionConsistencyDecision -ToolInputRaw $json -CheckpointReader $reader -FolderExistsCheck { param($p) $false }

        # Assert: the decision follows the targeted content, which still asserts completion.
        $result.hookSpecificOutput.permissionDecision | Should -Be 'deny'
    }

    It 'derives an allow from the targeted file_path content when the relative literal holds a completion-asserting checkpoint' {
        # Arrange: the absolute target does not assert completion; the relative literal does.
        $map = @{
            $script:AbsoluteTarget = $script:NonCompletionCheckpoint
            $script:RelativeTarget = $script:CompletionCheckpoint
        }
        $reader = { param($Path) $map[$Path] }.GetNewClosure()
        $json = ConvertTo-EditToolInputJson -FilePath $script:AbsoluteTarget -OldString $script:PatchOldString -NewString $script:PatchNotCompletion

        # Act
        $result = Invoke-CompletionConsistencyDecision -ToolInputRaw $json -CheckpointReader $reader -FolderExistsCheck { param($p) $false }

        # Assert: the decision follows the targeted content, which does not assert completion.
        $result.hookSpecificOutput.permissionDecision | Should -Be 'allow'
    }

    It 'passes an absolute POSIX file_path to the reader unchanged' {
        # Arrange: a capturing reader records every path it receives.
        $captured = [System.Collections.Generic.List[string]]::new()
        $reader = { param($Path) $captured.Add($Path); return $null }.GetNewClosure()
        $json = ConvertTo-EditToolInputJson -FilePath $script:AbsoluteTarget -OldString $script:PatchOldString -NewString $script:PatchToCompletion

        # Act
        $null = Invoke-CompletionConsistencyDecision -ToolInputRaw $json -CheckpointReader $reader -FolderExistsCheck { param($p) $false }

        # Assert: exactly one read, at the supplied file_path.
        $captured.Count | Should -Be 1
        $captured[0] | Should -BeExactly $script:AbsoluteTarget
    }

    It 'passes a relative file_path to the reader unchanged' {
        # Arrange: a capturing reader records every path it receives.
        $captured = [System.Collections.Generic.List[string]]::new()
        $reader = { param($Path) $captured.Add($Path); return $null }.GetNewClosure()
        $json = ConvertTo-EditToolInputJson -FilePath $script:RelativeTarget -OldString $script:PatchOldString -NewString $script:PatchToCompletion

        # Act
        $null = Invoke-CompletionConsistencyDecision -ToolInputRaw $json -CheckpointReader $reader -FolderExistsCheck { param($p) $false }

        # Assert: exactly one read, at the supplied file_path.
        $captured.Count | Should -Be 1
        $captured[0] | Should -BeExactly $script:RelativeTarget
    }

    It 'passes a backslash-spelled file_path to the reader unchanged' {
        # Arrange: a capturing reader records every path it receives.
        $captured = [System.Collections.Generic.List[string]]::new()
        $reader = { param($Path) $captured.Add($Path); return $null }.GetNewClosure()
        $json = ConvertTo-EditToolInputJson -FilePath $script:BackslashTarget -OldString $script:PatchOldString -NewString $script:PatchToCompletion

        # Act
        $null = Invoke-CompletionConsistencyDecision -ToolInputRaw $json -CheckpointReader $reader -FolderExistsCheck { param($p) $false }

        # Assert: exactly one read, at the raw (not separator-normalized) file_path.
        $captured.Count | Should -Be 1
        $captured[0] | Should -BeExactly $script:BackslashTarget
    }

    It 'denies an Edit when the reader returns null for the targeted file_path' {
        # Arrange: the reader reports no checkpoint for any path.
        $reader = { param($Path) $null }
        $json = ConvertTo-EditToolInputJson -FilePath $script:AbsoluteTarget -OldString $script:PatchOldString -NewString $script:PatchToCompletion

        # Act
        $result = Invoke-CompletionConsistencyDecision -ToolInputRaw $json -CheckpointReader $reader -FolderExistsCheck { param($p) $false }

        # Assert: an unresolvable patch is denied with the checkpoint-missing cause.
        $result.hookSpecificOutput.permissionDecision | Should -Be 'deny'
        $result.hookSpecificOutput.permissionDecisionReason | Should -BeLike '*checkpoint-missing*'
    }

    It 'denies a completion-asserting Edit with a relative file_path read through that relative path' {
        # Arrange: only the relative target holds a checkpoint; the patch asserts completion.
        $map = @{ $script:RelativeTarget = $script:NonCompletionCheckpoint }
        $reader = { param($Path) $map[$Path] }.GetNewClosure()
        $json = ConvertTo-EditToolInputJson -FilePath $script:RelativeTarget -OldString $script:PatchOldString -NewString $script:PatchToCompletion

        # Act
        $result = Invoke-CompletionConsistencyDecision -ToolInputRaw $json -CheckpointReader $reader -FolderExistsCheck { param($p) $false }

        # Assert: relative-path decisions are unchanged.
        $result.hookSpecificOutput.permissionDecision | Should -Be 'deny'
    }

    It 'denies an Edit whose old_string is absent from the targeted file_path content' {
        # Arrange: the targeted content lacks the patch anchor; the relative literal has it.
        $map = @{
            $script:AbsoluteTarget = $script:AnchorlessCheckpoint
            $script:RelativeTarget = $script:NonCompletionCheckpoint
        }
        $reader = { param($Path) $map[$Path] }.GetNewClosure()
        $json = ConvertTo-EditToolInputJson -FilePath $script:AbsoluteTarget -OldString $script:PatchOldString -NewString $script:PatchToCompletion

        # Act
        $result = Invoke-CompletionConsistencyDecision -ToolInputRaw $json -CheckpointReader $reader -FolderExistsCheck { param($p) $false }

        # Assert: a patch that does not apply to the targeted content is denied with the old_string-not-found cause.
        $result.hookSpecificOutput.permissionDecision | Should -Be 'deny'
        $result.hookSpecificOutput.permissionDecisionReason | Should -BeLike '*old_string-not-found*'
    }

    It 'denies an Edit that supplies no old_string' {
        # Arrange: both paths hold a checkpoint; the Edit carries only new_string.
        $map = @{
            $script:AbsoluteTarget = $script:NonCompletionCheckpoint
            $script:RelativeTarget = $script:NonCompletionCheckpoint
        }
        $reader = { param($Path) $map[$Path] }.GetNewClosure()
        $json = ConvertTo-EditToolInputJson -FilePath $script:AbsoluteTarget -NewString $script:PatchToCompletion

        # Act
        $result = Invoke-CompletionConsistencyDecision -ToolInputRaw $json -CheckpointReader $reader -FolderExistsCheck { param($p) $false }

        # Assert: an Edit without old_string cannot be resolved and is denied with the no-old_string cause.
        $result.hookSpecificOutput.permissionDecision | Should -Be 'deny'
        $result.hookSpecificOutput.permissionDecisionReason | Should -BeLike '*no-old_string*'
    }

    It 'denies an Edit when the targeted file_path content is empty' {
        # Arrange: the targeted content is empty; the relative literal holds a checkpoint.
        $map = @{
            $script:AbsoluteTarget = ''
            $script:RelativeTarget = $script:NonCompletionCheckpoint
        }
        $reader = { param($Path) $map[$Path] }.GetNewClosure()
        $json = ConvertTo-EditToolInputJson -FilePath $script:AbsoluteTarget -OldString $script:PatchOldString -NewString $script:PatchToCompletion

        # Act
        $result = Invoke-CompletionConsistencyDecision -ToolInputRaw $json -CheckpointReader $reader -FolderExistsCheck { param($p) $false }

        # Assert: empty targeted content cannot be patched, so the Edit is denied with the checkpoint-empty cause.
        $result.hookSpecificOutput.permissionDecision | Should -Be 'deny'
        $result.hookSpecificOutput.permissionDecisionReason | Should -BeLike '*checkpoint-empty*'
    }

    It 'declares CheckpointPath as a mandatory parameter of Resolve-EditedCheckpointContent' {
        # Arrange
        $command = Get-Command Resolve-EditedCheckpointContent

        # Act
        $hasParameter = $command.Parameters.ContainsKey('CheckpointPath')

        # Assert: the parameter exists and its ParameterAttribute is mandatory.
        $hasParameter | Should -BeTrue -Because 'Resolve-EditedCheckpointContent must receive the targeted file_path'
        $attribute = @($command.Parameters['CheckpointPath'].Attributes | Where-Object { $_ -is [System.Management.Automation.ParameterAttribute] })[0]
        $attribute.Mandatory | Should -BeTrue
    }
}
