#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

<#
.SYNOPSIS
    Target-worktree rows for the Codex twin .codex/hooks/enforce-file-size-limit.ps1 (issue #1163).

.DESCRIPTION
    An absolute file_path inside an agent worktree beneath .claude/worktrees/, or inside a
    sibling worktree outside the repository root, is measured against the enclosing
    registered worktree (D7). The decision rows build each record with
    ConvertTo-CodexFileEditInput from an in-memory Codex payload and call
    Invoke-CodexFileSizeLimitDecision with its Record and Payload inputs; one row drives
    Invoke-CodexFileSizeLimitEntryPoint to show it forwards the worktree-list seam.

    Argument builder: Get-CodexFileSizeTargetArgument adds -WorktreeListInvoker only when
    Get-Command reports that the command under test declares it, so each row runs unchanged
    against the unmodified hook (fail-before) and the changed hook (pass-after). File content
    comes from an in-memory ReadFileContent seam that reports every path as absent, worktree
    lists are in-memory porcelain, and roots are /-rooted with forward slashes.
#>

BeforeAll {
    . (Resolve-Path "$PSScriptRoot/../../../.codex/hooks/enforce-file-size-limit.ps1").Path

    $script:Root = '/repo'
    $porcelain = "worktree /repo`nbranch refs/heads/main`n`nworktree /repo/.claude/worktrees/item`nbranch refs/heads/bug/item`n`nworktree /sibling/item-b`nbranch refs/heads/bug/item-b`n"
    $script:ListInvoker = { param($SessionRoot) $null = $SessionRoot; $porcelain }.GetNewClosure()
    $script:ThrowingInvoker = { param($SessionRoot) $null = $SessionRoot; throw 'synthetic worktree list failure' }
    $script:AbsentReader = { param([string] $Path) $null = $Path; $null }

    function Get-CodexFileSizeTargetPayloadText {
        param([string] $FilePath, [int] $LineCount)
        $content = ((1..$LineCount | ForEach-Object { "line $_" }) -join "`n") + "`n"
        return (@{ session_id = 's'; hook_event_name = 'PreToolUse'; tool_name = 'Write'; tool_input = @{ file_path = $FilePath; content = $content } } | ConvertTo-Json -Compress -Depth 6)
    }

    # Builds the decision arguments; the seam this item adds is passed only when declared.
    function Get-CodexFileSizeTargetArgument {
        param([string] $FilePath, [int] $LineCount, [scriptblock] $Invoker)
        $payload = ConvertFrom-CodexPreToolUsePayload -PayloadRaw (Get-CodexFileSizeTargetPayloadText -FilePath $FilePath -LineCount $LineCount) -HookName 'enforce-file-size-limit'
        $record = @(ConvertTo-CodexFileEditInput -Payload $payload)[0]
        $arguments = @{ Record = $record; Payload = $payload; RepositoryRoot = $script:Root; ReadFileContent = $script:AbsentReader }
        if ((Get-Command -Name Invoke-CodexFileSizeLimitDecision).Parameters.ContainsKey('WorktreeListInvoker')) { $arguments['WorktreeListInvoker'] = $Invoker }
        return $arguments
    }
}

Describe 'Codex enforce-file-size-limit.ps1 paths in other worktrees (issue #1163)' {
    It 'denies an 801-line Write to <Label>' -ForEach @(
        @{ Label = 'an agent worktree beneath .claude/worktrees/'; Path = '/repo/.claude/worktrees/item/scripts/new.ps1' }
        @{ Label = 'a sibling worktree outside the repository root'; Path = '/sibling/item-b/scripts/new.ps1' }
    ) {
        # Arrange (fails before: the unmodified hook treats the path as uncovered and allows)
        $arguments = Get-CodexFileSizeTargetArgument -FilePath $Path -LineCount 801 -Invoker $script:ListInvoker

        # Act
        $result = Invoke-CodexFileSizeLimitDecision @arguments

        # Assert
        $result | Should -Not -BeNullOrEmpty
        $result.hookSpecificOutput.permissionDecision | Should -Be 'deny'
        $result.hookSpecificOutput.permissionDecisionReason | Should -BeLike '*scripts/new.ps1*'
    }

    It 'allows an 800-line Write to <Label>' -ForEach @(
        @{ Label = 'an agent worktree beneath .claude/worktrees/'; Path = '/repo/.claude/worktrees/item/scripts/new.ps1' }
        @{ Label = 'a sibling worktree outside the repository root'; Path = '/sibling/item-b/scripts/new.ps1' }
    ) {
        # Arrange
        $arguments = Get-CodexFileSizeTargetArgument -FilePath $Path -LineCount 800 -Invoker $script:ListInvoker

        # Act
        $result = Invoke-CodexFileSizeLimitDecision @arguments

        # Assert
        $result | Should -BeNullOrEmpty
    }

    It 'keeps the deny for an 801-line relative-path Write' {
        # Arrange
        $arguments = Get-CodexFileSizeTargetArgument -FilePath 'scripts/new.ps1' -LineCount 801 -Invoker $script:ListInvoker

        # Act
        $result = Invoke-CodexFileSizeLimitDecision @arguments

        # Assert
        $result.hookSpecificOutput.permissionDecision | Should -Be 'deny'
    }

    It 'keeps the deny for an 801-line Write inside the repository root without listing worktrees' {
        # Arrange
        $calls = [System.Collections.Generic.List[string]]::new()
        $failIfCalled = { param($SessionRoot) $calls.Add($SessionRoot); throw 'the worktree list invoker must not be called' }.GetNewClosure()
        $arguments = Get-CodexFileSizeTargetArgument -FilePath '/repo/scripts/new.ps1' -LineCount 801 -Invoker $failIfCalled

        # Act
        $result = Invoke-CodexFileSizeLimitDecision @arguments

        # Assert
        $result.hookSpecificOutput.permissionDecision | Should -Be 'deny'
        $calls.Count | Should -Be 0
    }

    It 'keeps the allow for an 801-line Write to a path in no registered worktree' {
        # Arrange
        $arguments = Get-CodexFileSizeTargetArgument -FilePath '/elsewhere/scripts/new.ps1' -LineCount 801 -Invoker $script:ListInvoker

        # Act
        $result = Invoke-CodexFileSizeLimitDecision @arguments

        # Assert
        $result | Should -BeNullOrEmpty
    }

    It 'keeps the allow for an 801-line agent-worktree Write when the worktree listing throws' {
        # Arrange
        $arguments = Get-CodexFileSizeTargetArgument -FilePath '/repo/.claude/worktrees/item/scripts/new.ps1' -LineCount 801 -Invoker $script:ThrowingInvoker

        # Act
        $result = Invoke-CodexFileSizeLimitDecision @arguments

        # Assert
        $result | Should -BeNullOrEmpty
    }

    It 'forwards the worktree-list seam from the entry point to the decision' {
        # Arrange (fails before: the unmodified entry point allows the uncovered agent-worktree path)
        $entryArguments = @{ PayloadRaw = (Get-CodexFileSizeTargetPayloadText -FilePath '/repo/.claude/worktrees/item/scripts/new.ps1' -LineCount 801); RepositoryRoot = $script:Root; ReadFileContent = $script:AbsentReader }
        if ((Get-Command -Name Invoke-CodexFileSizeLimitEntryPoint).Parameters.ContainsKey('WorktreeListInvoker')) { $entryArguments['WorktreeListInvoker'] = $script:ListInvoker }
        $originalOut = [Console]::Out
        $out = [System.IO.StringWriter]::new()

        # Act
        try {
            [Console]::SetOut($out)
            $exitCode = Invoke-CodexFileSizeLimitEntryPoint @entryArguments
        } finally {
            [Console]::SetOut($originalOut)
        }

        # Assert
        $exitCode | Should -Be 0
        $out.ToString() | Should -BeLike '*"permissionDecision":"deny"*'
    }
}
