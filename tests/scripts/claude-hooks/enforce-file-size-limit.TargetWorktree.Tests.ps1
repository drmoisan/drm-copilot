#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

<#
.SYNOPSIS
    Target-worktree rows for .claude/hooks/enforce-file-size-limit.ps1 (issue #1163).

.DESCRIPTION
    An absolute file_path inside an agent worktree beneath .claude/worktrees/, or inside a
    sibling worktree outside the repository root, is measured against the enclosing
    registered worktree (D7) instead of being classified as uncovered and allowed.

    Argument builder: Get-FileSizeTargetArgument adds -WorktreeListInvoker only when Get-Command
    reports that Invoke-FileSizeLimitDecision declares it, so each row runs unchanged against the
    unmodified hook (fail-before) and the changed hook (pass-after). File content comes from an
    in-memory ReadFileContent seam that reports every path as absent, worktree lists are
    in-memory porcelain, and roots are /-rooted with forward slashes, so no row reads a file,
    runs git, or depends on the host.
#>

BeforeAll {
    . (Resolve-Path "$PSScriptRoot/../../../.claude/hooks/enforce-file-size-limit.ps1").Path

    $script:Root = '/repo'
    $porcelain = "worktree /repo`nbranch refs/heads/main`n`nworktree /repo/.claude/worktrees/item`nbranch refs/heads/bug/item`n`nworktree /sibling/item-b`nbranch refs/heads/bug/item-b`n"
    $script:ListInvoker = { param($SessionRoot) $null = $SessionRoot; $porcelain }.GetNewClosure()
    $script:ThrowingInvoker = { param($SessionRoot) $null = $SessionRoot; throw 'synthetic worktree list failure' }
    $script:AbsentReader = { param([string] $Path) $null = $Path; $null }

    function Get-FileSizeTargetText {
        param([int] $LineCount)
        return ((1..$LineCount | ForEach-Object { "line $_" }) -join "`n") + "`n"
    }

    # Builds the decision arguments; the seam this item adds is passed only when declared.
    function Get-FileSizeTargetArgument {
        param([string] $FilePath, [int] $LineCount, [scriptblock] $Invoker)
        $envelope = @{ tool_name = 'Write'; tool_input = @{ file_path = $FilePath; content = (Get-FileSizeTargetText -LineCount $LineCount) } } | ConvertTo-Json -Compress -Depth 6
        $arguments = @{ ToolInputRaw = $envelope; RepositoryRoot = $script:Root; ReadFileContent = $script:AbsentReader }
        if ((Get-Command -Name Invoke-FileSizeLimitDecision).Parameters.ContainsKey('WorktreeListInvoker')) { $arguments['WorktreeListInvoker'] = $Invoker }
        return $arguments
    }
}

Describe 'enforce-file-size-limit.ps1 paths in other worktrees (issue #1163)' {
    It 'denies an 801-line Write to <Label>' -ForEach @(
        @{ Label = 'an agent worktree beneath .claude/worktrees/'; Path = '/repo/.claude/worktrees/item/scripts/new.ps1' }
        @{ Label = 'a sibling worktree outside the repository root'; Path = '/sibling/item-b/scripts/new.ps1' }
    ) {
        # Arrange (fails before: the unmodified hook treats the path as uncovered and allows)
        $arguments = Get-FileSizeTargetArgument -FilePath $Path -LineCount 801 -Invoker $script:ListInvoker

        # Act
        $result = Invoke-FileSizeLimitDecision @arguments

        # Assert
        $result.hookSpecificOutput.permissionDecision | Should -Be 'deny'
        $result.hookSpecificOutput.permissionDecisionReason | Should -BeLike '*scripts/new.ps1*'
    }

    It 'allows an 800-line Write to <Label>' -ForEach @(
        @{ Label = 'an agent worktree beneath .claude/worktrees/'; Path = '/repo/.claude/worktrees/item/scripts/new.ps1' }
        @{ Label = 'a sibling worktree outside the repository root'; Path = '/sibling/item-b/scripts/new.ps1' }
    ) {
        # Arrange
        $arguments = Get-FileSizeTargetArgument -FilePath $Path -LineCount 800 -Invoker $script:ListInvoker

        # Act
        $result = Invoke-FileSizeLimitDecision @arguments

        # Assert
        $result.hookSpecificOutput.permissionDecision | Should -Be 'allow'
    }

    It 'keeps the deny for an 801-line relative-path Write' {
        # Arrange
        $arguments = Get-FileSizeTargetArgument -FilePath 'scripts/new.ps1' -LineCount 801 -Invoker $script:ListInvoker

        # Act
        $result = Invoke-FileSizeLimitDecision @arguments

        # Assert
        $result.hookSpecificOutput.permissionDecision | Should -Be 'deny'
    }

    It 'keeps the deny for an 801-line Write inside the repository root without listing worktrees' {
        # Arrange
        $calls = [System.Collections.Generic.List[string]]::new()
        $failIfCalled = { param($SessionRoot) $calls.Add($SessionRoot); throw 'the worktree list invoker must not be called' }.GetNewClosure()
        $arguments = Get-FileSizeTargetArgument -FilePath '/repo/scripts/new.ps1' -LineCount 801 -Invoker $failIfCalled

        # Act
        $result = Invoke-FileSizeLimitDecision @arguments

        # Assert
        $result.hookSpecificOutput.permissionDecision | Should -Be 'deny'
        $calls.Count | Should -Be 0
    }

    It 'keeps the allow for an 801-line Write to a path in no registered worktree' {
        # Arrange
        $arguments = Get-FileSizeTargetArgument -FilePath '/elsewhere/scripts/new.ps1' -LineCount 801 -Invoker $script:ListInvoker

        # Act
        $result = Invoke-FileSizeLimitDecision @arguments

        # Assert
        $result.hookSpecificOutput.permissionDecision | Should -Be 'allow'
    }

    It 'keeps the allow for an 801-line agent-worktree Write when the worktree listing throws' {
        # Arrange
        $arguments = Get-FileSizeTargetArgument -FilePath '/repo/.claude/worktrees/item/scripts/new.ps1' -LineCount 801 -Invoker $script:ThrowingInvoker

        # Act
        $result = Invoke-FileSizeLimitDecision @arguments

        # Assert
        $result.hookSpecificOutput.permissionDecision | Should -Be 'allow'
    }

    It 'keeps the allow for an 801-line agent-worktree Write when the resolver throws' {
        # Arrange (D7: a resolver exception is caught and today's relative path applies)
        Mock Resolve-AgentTargetWorktree { throw 'synthetic resolver failure' }
        $arguments = Get-FileSizeTargetArgument -FilePath '/repo/.claude/worktrees/item/scripts/new.ps1' -LineCount 801 -Invoker $script:ListInvoker

        # Act
        $result = Invoke-FileSizeLimitDecision @arguments

        # Assert
        $result.hookSpecificOutput.permissionDecision | Should -Be 'allow'
        Should -Invoke Resolve-AgentTargetWorktree -Times 1 -Exactly
    }
}
