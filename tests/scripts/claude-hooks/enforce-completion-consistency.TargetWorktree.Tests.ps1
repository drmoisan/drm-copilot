#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSReviewUnusedParameter', '', Justification = 'Injected FolderExistsCheck, RoutingMatrixReader, and WorktreeListInvoker stubs mirror the production scriptblock signatures for testing')]
param()

<#
.SYNOPSIS
    Target-worktree rows for .claude/hooks/enforce-completion-consistency.ps1 (issue #1163).

.DESCRIPTION
    A completion-asserting Write to an item-worktree checkpoint must probe the feature folder
    beneath the worktree that encloses the checkpoint path (D6), not beneath the hook process
    directory. The FolderExistsCheck seam is keyed by absolute path and reports only the
    feature folder beneath /repo/.claude/worktrees/item, so the row that probes the session
    root denies.

    Argument builder: Get-CompletionTargetArgument adds -SessionRoot and -WorktreeListInvoker
    only when Get-Command reports that Invoke-CompletionConsistencyDecision declares them, so
    each row runs unchanged against the unmodified hook (fail-before) and the changed hook
    (pass-after). Worktree lists are in-memory porcelain, the routing matrix is an in-memory
    stub, and paths are /-rooted with forward slashes, so no row reads a file, runs git, or
    depends on the host.
#>

BeforeAll {
    . (Resolve-Path "$PSScriptRoot/../../../.claude/hooks/enforce-completion-consistency.ps1").Path
    Mock Get-CheckpointFileContent { $null }

    $script:FeatureFolder = 'docs/features/active/2026-11-09-sample-1163'
    $script:ItemRoot = '/repo/.claude/worktrees/item'
    $script:ItemFolder = "$script:ItemRoot/$script:FeatureFolder"
    $porcelain = "worktree /repo`nbranch refs/heads/main`n`nworktree /repo/.claude/worktrees/item`nbranch refs/heads/bug/item`n"
    $script:ListInvoker = { param($SessionRoot) $null = $SessionRoot; $porcelain }.GetNewClosure()
    $script:ThrowingInvoker = { param($SessionRoot) $null = $SessionRoot; throw 'synthetic worktree list failure' }
    $itemFolder = $script:ItemFolder
    $script:FolderCheck = { param($p) $p -eq $itemFolder }.GetNewClosure()
    $script:MatrixReader = { $null }
    $completion = [ordered]@{
        'issue-num'      = '1163'
        'feature-folder' = $script:FeatureFolder
        next_step        = 'complete'
        ci_gate          = [ordered]@{ conclusion = 'success'; head_sha = 'abc123def456' }
    }
    $script:CompletionContent = $completion | ConvertTo-Json -Compress -Depth 5
    $script:NonCompletionContent = '{"issue-num":"1163","next_step":"S5_atomic_execution"}'

    function ConvertTo-CompletionWriteJson {
        param([string] $FilePath, [string] $Content)
        return (@{ tool_name = 'Write'; tool_input = @{ file_path = $FilePath; content = $Content } } | ConvertTo-Json -Compress -Depth 8)
    }

    # Builds the decision arguments; the seams this item adds are passed only when declared.
    function Get-CompletionTargetArgument {
        param([string] $FilePath, [string] $Content, [scriptblock] $Invoker)
        $arguments = @{ ToolInputRaw = (ConvertTo-CompletionWriteJson -FilePath $FilePath -Content $Content); FolderExistsCheck = $script:FolderCheck; RoutingMatrixReader = $script:MatrixReader }
        $parameters = (Get-Command -Name Invoke-CompletionConsistencyDecision).Parameters
        if ($parameters.ContainsKey('SessionRoot')) { $arguments['SessionRoot'] = '/repo' }
        if ($parameters.ContainsKey('WorktreeListInvoker')) { $arguments['WorktreeListInvoker'] = $Invoker }
        return $arguments
    }
}

Describe 'enforce-completion-consistency.ps1 item-worktree checkpoint (issue #1163)' {
    It 'allows a completion-asserting Write to an item-worktree checkpoint whose feature folder exists only beneath the item root' {
        # Arrange (fails before: the unmodified hook probes the repository-relative folder and denies)
        $arguments = Get-CompletionTargetArgument -FilePath "$script:ItemRoot/artifacts/orchestration/orchestrator-state.json" -Content $script:CompletionContent -Invoker $script:ListInvoker

        # Act
        $result = Invoke-CompletionConsistencyDecision @arguments

        # Assert
        $result.hookSpecificOutput.permissionDecision | Should -Be 'allow'
    }

    It 'keeps the deny for the same Write to the session-root checkpoint' {
        # Arrange
        $arguments = Get-CompletionTargetArgument -FilePath '/repo/artifacts/orchestration/orchestrator-state.json' -Content $script:CompletionContent -Invoker $script:ListInvoker

        # Act
        $result = Invoke-CompletionConsistencyDecision @arguments

        # Assert
        $result.hookSpecificOutput.permissionDecision | Should -Be 'deny'
        $result.hookSpecificOutput.permissionDecisionReason | Should -BeLike '*feature-folder value*'
    }

    It 'keeps the deny for a relative checkpoint file_path' {
        # Arrange
        $arguments = Get-CompletionTargetArgument -FilePath 'artifacts/orchestration/orchestrator-state.json' -Content $script:CompletionContent -Invoker $script:ListInvoker

        # Act
        $result = Invoke-CompletionConsistencyDecision @arguments

        # Assert
        $result.hookSpecificOutput.permissionDecision | Should -Be 'deny'
    }

    It 'keeps the deny for a checkpoint path in no registered worktree' {
        # Arrange
        $arguments = Get-CompletionTargetArgument -FilePath '/elsewhere/artifacts/orchestration/orchestrator-state.json' -Content $script:CompletionContent -Invoker $script:ListInvoker

        # Act
        $result = Invoke-CompletionConsistencyDecision @arguments

        # Assert
        $result.hookSpecificOutput.permissionDecision | Should -Be 'deny'
    }

    It 'keeps the deny when the worktree listing throws' {
        # Arrange
        $arguments = Get-CompletionTargetArgument -FilePath "$script:ItemRoot/artifacts/orchestration/orchestrator-state.json" -Content $script:CompletionContent -Invoker $script:ThrowingInvoker

        # Act
        $result = Invoke-CompletionConsistencyDecision @arguments

        # Assert
        $result.hookSpecificOutput.permissionDecision | Should -Be 'deny'
    }

    It 'keeps the allow for a Write that asserts no completion without listing worktrees' {
        # Arrange (D6: resolution runs only for an asserted completion)
        $calls = [System.Collections.Generic.List[string]]::new()
        $failIfCalled = { param($SessionRoot) $calls.Add($SessionRoot); throw 'the worktree list invoker must not be called' }.GetNewClosure()
        $arguments = Get-CompletionTargetArgument -FilePath "$script:ItemRoot/artifacts/orchestration/orchestrator-state.json" -Content $script:NonCompletionContent -Invoker $failIfCalled

        # Act
        $result = Invoke-CompletionConsistencyDecision @arguments

        # Assert
        $result.hookSpecificOutput.permissionDecision | Should -Be 'allow'
        $calls.Count | Should -Be 0
    }
}
