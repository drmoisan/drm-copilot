#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSReviewUnusedParameter', '', Justification = 'Injected FolderExistsCheck and CheckpointReader stubs mirror the production scriptblock signatures for testing')]
param()

<#
.SYNOPSIS
    Regression tests for issue #736: the Edit branch of the Codex
    enforce-completion-consistency.ps1 must read the checkpoint at the Edit's
    targeted file_path rather than at a fixed relative literal.

.DESCRIPTION
    Every test supplies an injected path-keyed or capturing CheckpointReader
    scriptblock, so the file performs no filesystem access and does not depend on
    the working directory. Fixture paths are pure strings that are never resolved
    on disk. The resolver rows re-home the rows formerly held by
    codex-pretooluse-transport.Tests.ps1.
#>

Describe 'enforce-completion-consistency.ps1 Codex Edit target path (issue #736)' {
    BeforeAll {
        $script:UnderTest = (Resolve-Path "$PSScriptRoot/../../../.codex/hooks/enforce-completion-consistency.ps1").Path
        . $script:UnderTest
        Mock Get-CheckpointFileContent { $null }

        $script:AbsoluteTarget = '/work/item-worktree/artifacts/orchestration/orchestrator-state.json'
        $script:BackslashTarget = '\work\item-worktree\artifacts\orchestration\orchestrator-state.json'
        $script:RelativeTarget = 'artifacts/orchestration/orchestrator-state.json'
        $script:NonCompletionCheckpoint = '{"objective":"x","next_step":"S5_atomic_execution"}'
        $script:CompletionCheckpoint = '{"objective":"x","next_step":"S5_atomic_execution","step8_status":"completed"}'
        $script:PatchOldString = '"next_step":"S5_atomic_execution"'
        $script:PatchToCompletion = '"next_step":"complete"'
        $script:PatchNotCompletion = '"next_step":"S6_review"'
        $script:AmbiguousText = '{"s8":"pending","s9":"pending","next_step":"S5_atomic_execution"}'

        # Builds a mapped Edit record. old_string is included only when the caller
        # supplies it.
        function ConvertTo-MappedEditJson {
            param(
                [Parameter(Mandatory)]
                [string] $FilePath,

                [Parameter(Mandatory)]
                [string] $NewString,

                [string] $OldString
            )
            $record = [ordered]@{ file_path = $FilePath; new_string = $NewString }
            if ($PSBoundParameters.ContainsKey('OldString')) {
                $record['old_string'] = $OldString
            }
            return ($record | ConvertTo-Json -Compress -Depth 8)
        }
    }

    It 'denies a completion-asserting Edit when the checkpoint exists only at the absolute targeted file_path' {
        # Arrange: only the absolute target holds a checkpoint; the patch asserts completion.
        $map = @{ $script:AbsoluteTarget = $script:NonCompletionCheckpoint }
        $reader = { param($Path) $map[$Path] }.GetNewClosure()
        $json = ConvertTo-MappedEditJson -FilePath $script:AbsoluteTarget -OldString $script:PatchOldString -NewString $script:PatchToCompletion

        # Act
        $result = Invoke-CompletionConsistencyDecision -ToolInputRaw $json -CheckpointReader $reader -FolderExistsCheck { param($p) $false } -RoutingMatrixReader { $null }

        # Assert: the patched content lacks completion evidence, so the Edit is denied.
        $result.hookSpecificOutput.permissionDecision | Should -Be 'deny'
        $result.hookSpecificOutput.permissionDecisionReason | Should -BeLike '*ci_gate*'
    }

    It 'derives a deny from the targeted file_path content when the relative literal holds different content' {
        # Arrange: the absolute target already asserts completion; the relative literal does not.
        $map = @{
            $script:AbsoluteTarget = $script:CompletionCheckpoint
            $script:RelativeTarget = $script:NonCompletionCheckpoint
        }
        $reader = { param($Path) $map[$Path] }.GetNewClosure()
        $json = ConvertTo-MappedEditJson -FilePath $script:AbsoluteTarget -OldString $script:PatchOldString -NewString $script:PatchNotCompletion

        # Act
        $result = Invoke-CompletionConsistencyDecision -ToolInputRaw $json -CheckpointReader $reader -FolderExistsCheck { param($p) $false } -RoutingMatrixReader { $null }

        # Assert: the decision follows the targeted content, which still asserts completion.
        $result.hookSpecificOutput.permissionDecision | Should -Be 'deny'
        $result.hookSpecificOutput.permissionDecisionReason | Should -BeLike '*issue-num*'
    }

    It 'derives an allow from the targeted file_path content when the relative literal holds a completion-asserting checkpoint' {
        # Arrange: the absolute target does not assert completion; the relative literal does.
        $map = @{
            $script:AbsoluteTarget = $script:NonCompletionCheckpoint
            $script:RelativeTarget = $script:CompletionCheckpoint
        }
        $reader = { param($Path) $map[$Path] }.GetNewClosure()
        $json = ConvertTo-MappedEditJson -FilePath $script:AbsoluteTarget -OldString $script:PatchOldString -NewString $script:PatchNotCompletion

        # Act
        $result = Invoke-CompletionConsistencyDecision -ToolInputRaw $json -CheckpointReader $reader -FolderExistsCheck { param($p) $false } -RoutingMatrixReader { $null }

        # Assert: the decision follows the targeted content, which does not assert completion.
        $result.hookSpecificOutput.permissionDecision | Should -Be 'allow'
    }

    It 'passes an absolute POSIX file_path to the reader unchanged' {
        # Arrange: a capturing reader records every path it receives.
        $captured = [System.Collections.Generic.List[string]]::new()
        $reader = { param($Path) $captured.Add($Path); return $null }.GetNewClosure()
        $json = ConvertTo-MappedEditJson -FilePath $script:AbsoluteTarget -OldString $script:PatchOldString -NewString $script:PatchToCompletion

        # Act
        $null = Invoke-CompletionConsistencyDecision -ToolInputRaw $json -CheckpointReader $reader -FolderExistsCheck { param($p) $false } -RoutingMatrixReader { $null }

        # Assert: exactly one read, at the supplied file_path.
        $captured.Count | Should -Be 1
        $captured[0] | Should -BeExactly $script:AbsoluteTarget
    }

    It 'passes a relative file_path to the reader unchanged' {
        # Arrange: a capturing reader records every path it receives.
        $captured = [System.Collections.Generic.List[string]]::new()
        $reader = { param($Path) $captured.Add($Path); return $null }.GetNewClosure()
        $json = ConvertTo-MappedEditJson -FilePath $script:RelativeTarget -OldString $script:PatchOldString -NewString $script:PatchToCompletion

        # Act
        $null = Invoke-CompletionConsistencyDecision -ToolInputRaw $json -CheckpointReader $reader -FolderExistsCheck { param($p) $false } -RoutingMatrixReader { $null }

        # Assert: exactly one read, at the supplied file_path.
        $captured.Count | Should -Be 1
        $captured[0] | Should -BeExactly $script:RelativeTarget
    }

    It 'passes a backslash-spelled file_path to the reader unchanged' {
        # Arrange: a capturing reader records every path it receives.
        $captured = [System.Collections.Generic.List[string]]::new()
        $reader = { param($Path) $captured.Add($Path); return $null }.GetNewClosure()
        $json = ConvertTo-MappedEditJson -FilePath $script:BackslashTarget -OldString $script:PatchOldString -NewString $script:PatchToCompletion

        # Act
        $null = Invoke-CompletionConsistencyDecision -ToolInputRaw $json -CheckpointReader $reader -FolderExistsCheck { param($p) $false } -RoutingMatrixReader { $null }

        # Assert: exactly one read, at the raw (not separator-normalized) file_path.
        $captured.Count | Should -Be 1
        $captured[0] | Should -BeExactly $script:BackslashTarget
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

    It 'returns Failure no-old_string when the tool input carries no old_string' {
        # Arrange
        $toolInput = [pscustomobject]@{ file_path = $script:RelativeTarget }
        $reader = { param($Path) 'ignored' }

        # Act
        $result = Resolve-EditedCheckpointContent -ToolInput $toolInput -CheckpointReader $reader -CheckpointPath $script:RelativeTarget

        # Assert: the failure names the cause and no content is returned.
        $result.Failure | Should -Be 'no-old_string'
        $result.Content | Should -BeNullOrEmpty
    }

    It 'returns Failure checkpoint-empty when the reader returns an empty string' {
        # Arrange
        $toolInput = [pscustomobject]@{ old_string = 'a'; new_string = 'b' }
        $reader = { param($Path) '' }

        # Act
        $result = Resolve-EditedCheckpointContent -ToolInput $toolInput -CheckpointReader $reader -CheckpointPath $script:AbsoluteTarget

        # Assert
        $result.Failure | Should -Be 'checkpoint-empty'
        $result.Content | Should -BeNullOrEmpty
    }

    It 'returns Failure old_string-not-found when old_string is absent from the checkpoint' {
        # Arrange
        $toolInput = [pscustomobject]@{ old_string = 'absent'; new_string = 'b' }
        $reader = { param($Path) '{"next_step":"S07"}' }

        # Act
        $result = Resolve-EditedCheckpointContent -ToolInput $toolInput -CheckpointReader $reader -CheckpointPath $script:AbsoluteTarget

        # Assert
        $result.Failure | Should -Be 'old_string-not-found'
        $result.Content | Should -BeNullOrEmpty
    }

    It 'applies the old_string to new_string replacement in memory and returns Content' {
        # Arrange
        $toolInput = [pscustomobject]@{ old_string = 'S07'; new_string = 'complete' }
        $reader = { param($Path) '{"next_step":"S07"}' }

        # Act
        $result = Resolve-EditedCheckpointContent -ToolInput $toolInput -CheckpointReader $reader -CheckpointPath $script:AbsoluteTarget

        # Assert
        $result.Content | Should -BeExactly '{"next_step":"complete"}'
        $result.Failure | Should -BeNullOrEmpty
    }

    It 'passes the supplied CheckpointPath to the injected reader' {
        # Arrange
        $captured = [System.Collections.Generic.List[string]]::new()
        $reader = { param($Path) $captured.Add($Path); return '{"next_step":"S07"}' }.GetNewClosure()
        $toolInput = [pscustomobject]@{ old_string = 'S07'; new_string = 'complete' }

        # Act
        $null = Resolve-EditedCheckpointContent -ToolInput $toolInput -CheckpointReader $reader -CheckpointPath $script:AbsoluteTarget

        # Assert: exactly one read, at the supplied path.
        $captured.Count | Should -Be 1
        $captured[0] | Should -BeExactly $script:AbsoluteTarget
    }

    It 'returns Failure checkpoint-missing when the reader returns null' {
        # Arrange
        $toolInput = [pscustomobject]@{ old_string = 'a'; new_string = 'b' }
        $reader = { param($Path) $null }

        # Act
        $result = Resolve-EditedCheckpointContent -ToolInput $toolInput -CheckpointReader $reader -CheckpointPath $script:AbsoluteTarget

        # Assert
        $result.Failure | Should -Be 'checkpoint-missing'
        $result.Content | Should -BeNullOrEmpty
    }

    It 'returns Failure checkpoint-unreadable when the reader throws' {
        # Arrange
        $toolInput = [pscustomobject]@{ old_string = 'a'; new_string = 'b' }
        $reader = { param($Path) throw 'simulated unreadable checkpoint' }

        # Act
        $act = { Resolve-EditedCheckpointContent -ToolInput $toolInput -CheckpointReader $reader -CheckpointPath $script:AbsoluteTarget }

        # Assert: the reader exception is converted into a failure.
        $act | Should -Not -Throw
        $result = & $act
        $result.Failure | Should -Be 'checkpoint-unreadable'
        $result.Content | Should -BeNullOrEmpty
    }

    It 'returns Failure old_string-ambiguous for two occurrences without replace_all' {
        # Arrange
        $toolInput = [pscustomobject]@{ old_string = '"pending"'; new_string = '"waiting"' }
        $text = $script:AmbiguousText
        $reader = { param($Path) $text }.GetNewClosure()

        # Act
        $result = Resolve-EditedCheckpointContent -ToolInput $toolInput -CheckpointReader $reader -CheckpointPath $script:AbsoluteTarget

        # Assert
        $result.Failure | Should -Be 'old_string-ambiguous'
        $result.Content | Should -BeNullOrEmpty
    }

    It 'replaces every occurrence when replace_all is true' {
        # Arrange
        $toolInput = [pscustomobject]@{ old_string = '"pending"'; new_string = '"waiting"'; replace_all = $true }
        $text = $script:AmbiguousText
        $reader = { param($Path) $text }.GetNewClosure()

        # Act
        $result = Resolve-EditedCheckpointContent -ToolInput $toolInput -CheckpointReader $reader -CheckpointPath $script:AbsoluteTarget

        # Assert
        $result.Content | Should -BeExactly '{"s8":"waiting","s9":"waiting","next_step":"S5_atomic_execution"}'
        $result.Failure | Should -BeNullOrEmpty
    }
}
