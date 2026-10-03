#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }
<#
.SYNOPSIS
    Trigger-scoping regression cases for the Codex epic worktree-removal gate (issue #545).

.DESCRIPTION
    The Codex-side sibling of
    tests/scripts/claude-hooks/enforce-epic-worktree-removal-gate.TriggerScoping.Tests.ps1.
    The scenario set and the `It` names are identical; the idiom differs.

    Codex decision-entry idiom: `Invoke-CodexWorktreeRemovalDecision` takes the FULL Codex
    stdin payload (`cwd`, `tool_name`, `tool_input.command`) plus the epic checkpoint text as
    a parameter, and returns `$null` for allow rather than an allow decision object. The
    Claude copy consumes a PreToolUse envelope and returns an explicit allow.

    One case is a preservation pin rather than a regression: the Codex pattern already
    handled the leading `--force` spelling through its optional `(?:\s+--force)?` group,
    which is the divergence AT-7 records against the two Claude extractors. That behaviour
    must survive the move onto the shared parser, so `resolves the operand when --force
    precedes the path` asserts it here for the same reason it asserts a fix on the Claude
    side.

    This file is NEW rather than an extension of
    tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1, which is at 494 of its
    500 permitted lines.

    Determinism: every case drives the pure decision seam or a pure string function with
    literal fixtures, and the checkpoint arrives as a parameter rather than from disk. No
    disk I/O, no child process, no temporary file.
#>

Describe 'Codex enforce-epic-worktree-removal-gate trigger scoping (issue #545)' {
    BeforeAll {
        $script:RepoRoot = (Resolve-Path "$PSScriptRoot/../../..").Path
        $script:UnderTest = Join-Path $script:RepoRoot '.codex/hooks/enforce-epic-worktree-removal-gate.ps1'
        . $script:UnderTest

        $script:TargetPath = Join-Path $script:RepoRoot 'worktrees/item-a-101'
        $script:OtherPath = Join-Path $script:RepoRoot 'worktrees/item-b-102'

        # A checkpoint naming a DIFFERENT worktree, so nothing authorizes removing the target.
        $script:UnrelatedCheckpoint = @{
            features = @(
                @{ worktree_path = $script:OtherPath; merge_status = 'merged' }
            )
        } | ConvertTo-Json -Compress -Depth 4

        function ConvertTo-CodexWorktreeTriggerScopingPayload {
            <#
                Builds the full Codex stdin payload the decision seam consumes. The command
                text is carried verbatim so a fixture can exercise quoting and relocation
                exactly as the shell would present them.
            #>
            param([Parameter(Mandatory)][AllowEmptyString()] [string] $Command)

            return (@{
                    cwd        = $script:RepoRoot
                    tool_name  = 'Bash'
                    tool_input = @{ command = $Command }
                } | ConvertTo-Json -Compress -Depth 5)
        }
    }

    Context 'under-match removal - a relocating spelling is now in scope' {
        It 'denies git -C /repo/main worktree remove against a checkpoint with no authorizing record' {
            $command = 'git -C "' + $script:RepoRoot + '" worktree remove "' + $script:TargetPath + '"'

            $decision = Invoke-CodexWorktreeRemovalDecision `
                -PayloadRaw (ConvertTo-CodexWorktreeTriggerScopingPayload -Command $command) `
                -EpicCheckpointRaw $script:UnrelatedCheckpoint

            $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
            $decision.hookSpecificOutput.permissionDecisionReason |
                Should -Match '^EPIC_WORKTREE_REMOVAL_BLOCKED'
        }
    }

    Context 'operand resolution - the --force flag never becomes the path' {
        It 'resolves the operand when --force precedes the path' {
            # Preservation pin. The previous pattern's optional (?:\s+--force)? group already
            # handled this spelling; the shared parser must not lose it.
            Get-CodexWorktreeRemovalPath -Command ('git worktree remove --force "' + $script:TargetPath + '"') |
                Should -Be $script:TargetPath
        }

        It 'resolves the same operand when --force follows the path' {
            Get-CodexWorktreeRemovalPath -Command ('git worktree remove "' + $script:TargetPath + '" --force') |
                Should -Be $script:TargetPath
        }
    }

    Context 'over-match removal and scope narrowing' {
        It 'allows a command whose quoted text merely mentions the removal phrase' {
            $command = 'echo "git worktree remove ' + $script:TargetPath + '" >> docs/runbook.md'

            Invoke-CodexWorktreeRemovalDecision `
                -PayloadRaw (ConvertTo-CodexWorktreeTriggerScopingPayload -Command $command) `
                -EpicCheckpointRaw $script:UnrelatedCheckpoint |
                Should -BeNullOrEmpty -Because 'the echo segment mentions the phrase and removes nothing'
        }

        It 'keeps git worktree list out of scope' {
            Invoke-CodexWorktreeRemovalDecision `
                -PayloadRaw (ConvertTo-CodexWorktreeTriggerScopingPayload -Command 'git worktree list --porcelain') `
                -EpicCheckpointRaw $script:UnrelatedCheckpoint |
                Should -BeNullOrEmpty -Because 'list is not the remove subcommand'
        }
    }

    Context 'issue #824 - wrapper-led removal classification' {
        It 'A824-WT1 allows a wrapped git worktree list whose filter text carries removed' -Tag 'Issue824' {
            $command = 'pwsh -NoProfile -Command ''git worktree list --porcelain | Select-String -NotMatch "removed"'''

            $decision = Invoke-CodexWorktreeRemovalDecision -PayloadRaw (ConvertTo-CodexWorktreeTriggerScopingPayload -Command $command) -EpicCheckpointRaw $script:UnrelatedCheckpoint

            $decision | Should -BeNullOrEmpty -Because 'the Codex seam returns null for allow, and removed is not the token remove'
        }

        It 'A824-WT2 still denies git worktree remove carried inside a bash -c argument' -Tag 'Issue824' {
            $command = 'bash -c "git worktree remove ../x"'

            $decision = Invoke-CodexWorktreeRemovalDecision -PayloadRaw (ConvertTo-CodexWorktreeTriggerScopingPayload -Command $command) -EpicCheckpointRaw $script:UnrelatedCheckpoint

            $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
            $decision.hookSpecificOutput.permissionDecisionReason |
                Should -Match '^EPIC_WORKTREE_REMOVAL_BLOCKED'
        }
    }

    Context 'issue #824 addendum 1 - no authorizing record' {
        BeforeAll {
            $script:AddendumReproduction = @'
pwsh -NoProfile -Command 'Set-Location -LiteralPath "C:/repo/.claude/worktrees/agent-x"; if (Test-Path -LiteralPath "src/Old.cs") { Remove-Item -LiteralPath "src/Old.cs" -Force }; git status --porcelain -- "src/Old.cs"'
'@
        }

        It 'A824-WT3 allows the addendum reproduction even though raw containment matches it' -Tag 'Issue824' {
            # Arrange
            $command = $script:AddendumReproduction

            # Act
            $containment = Test-CommandLineRawContainment -RawText $command -CommandWord 'git' -SubcommandPath @('worktree', 'remove')
            $decision = Invoke-CodexWorktreeRemovalDecision -PayloadRaw (ConvertTo-CodexWorktreeTriggerScopingPayload -Command $command) -EpicCheckpointRaw $script:UnrelatedCheckpoint

            # Assert
            $containment | Should -BeTrue -Because 'the negative control: containment-based R2 would classify this text'
            $decision | Should -BeNullOrEmpty -Because 'the Codex seam returns null for allow, and no token-bounded git worktree remove sequence occurs'
        }

        It 'A824-WT4-<Id> denies <Label> without an authorizing record' -Tag 'Issue824' -ForEach @(
            @{ Id = 1; Label = 'git worktree remove worktrees/item-a-101'; Command = 'git worktree remove worktrees/item-a-101' }
            @{ Id = 2; Label = 'git worktree remove --force worktrees/item-a-101'; Command = 'git worktree remove --force worktrees/item-a-101' }
            @{ Id = 3; Label = 'git -C /repo/main worktree remove worktrees/item-a-101'; Command = 'git -C /repo/main worktree remove worktrees/item-a-101' }
            @{ Id = 4; Label = 'pwsh -Command ''git worktree remove worktrees/item-a-101'''; Command = 'pwsh -Command ''git worktree remove worktrees/item-a-101''' }
            @{ Id = 5; Label = 'bash -c "git worktree remove worktrees/item-a-101"'; Command = 'bash -c "git worktree remove worktrees/item-a-101"' }
        ) {
            # Arrange: $Command comes from the -ForEach row.

            # Act
            $decision = Invoke-CodexWorktreeRemovalDecision -PayloadRaw (ConvertTo-CodexWorktreeTriggerScopingPayload -Command $Command) -EpicCheckpointRaw $script:UnrelatedCheckpoint

            # Assert
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
            $decision.hookSpecificOutput.permissionDecisionReason |
                Should -Match '^EPIC_WORKTREE_REMOVAL_BLOCKED'
        }

        It 'A824-WT6 denies a wrapped removal that names no operand' -Tag 'Issue824' {
            # Arrange
            $command = 'pwsh -NoProfile -Command ''git worktree remove'''

            # Act
            $decision = Invoke-CodexWorktreeRemovalDecision -PayloadRaw (ConvertTo-CodexWorktreeTriggerScopingPayload -Command $command) -EpicCheckpointRaw $script:UnrelatedCheckpoint

            # Assert
            $decision.hookSpecificOutput.permissionDecision |
                Should -Be 'deny' -Because 'a classified wrapped removal without exactly one literal operand fails closed (cycle 2 design decision 2)'
            $decision.hookSpecificOutput.permissionDecisionReason |
                Should -Match '^EPIC_WORKTREE_REMOVAL_BLOCKED'
        }

        It 'A824-WT9 allows a wrapped Write-Host whose expansion precedes worktree remove' -Tag 'Issue824' {
            # Arrange
            $command = 'pwsh -c ''Write-Host "$path worktree remove"'''

            # Act
            $decision = Invoke-CodexWorktreeRemovalDecision -PayloadRaw (ConvertTo-CodexWorktreeTriggerScopingPayload -Command $command) -EpicCheckpointRaw $script:UnrelatedCheckpoint

            # Assert
            $decision | Should -BeNullOrEmpty -Because 'an expansion in the command position needs a token-bounded git elsewhere in the raw text'
        }
    }

    Context 'issue #824 addendum 1 - authorizing record present' {
        BeforeAll {
            $script:AddendumReproduction = @'
pwsh -NoProfile -Command 'Set-Location -LiteralPath "C:/repo/.claude/worktrees/agent-x"; if (Test-Path -LiteralPath "src/Old.cs") { Remove-Item -LiteralPath "src/Old.cs" -Force }; git status --porcelain -- "src/Old.cs"'
'@
            $script:AuthorizingCheckpoint = @{ features = @(@{ worktree_path = $script:TargetPath; merge_status = 'merged' }) } | ConvertTo-Json -Compress -Depth 4
        }

        It 'A824-WT5-<Id> allows <Label> with an authorizing record' -Tag 'Issue824' -ForEach @(
            @{ Id = 1; Label = 'git worktree remove worktrees/item-a-101'; Command = 'git worktree remove worktrees/item-a-101' }
            @{ Id = 2; Label = 'git worktree remove --force worktrees/item-a-101'; Command = 'git worktree remove --force worktrees/item-a-101' }
            @{ Id = 3; Label = 'git -C /repo/main worktree remove worktrees/item-a-101'; Command = 'git -C /repo/main worktree remove worktrees/item-a-101' }
            @{ Id = 4; Label = 'pwsh -Command ''git worktree remove worktrees/item-a-101'''; Command = 'pwsh -Command ''git worktree remove worktrees/item-a-101''' }
            @{ Id = 5; Label = 'bash -c "git worktree remove worktrees/item-a-101"'; Command = 'bash -c "git worktree remove worktrees/item-a-101"' }
        ) {
            # Arrange: $Command comes from the -ForEach row.

            # Act
            $decision = Invoke-CodexWorktreeRemovalDecision -PayloadRaw (ConvertTo-CodexWorktreeTriggerScopingPayload -Command $Command) -EpicCheckpointRaw $script:AuthorizingCheckpoint

            # Assert
            $decision | Should -BeNullOrEmpty -Because 'the checkpoint carries a merged record for the removed worktree'
        }

        It 'A824-WT7 denies an unbalanced wrapped removal even with an authorizing record' -Tag 'Issue824' {
            # Arrange
            $command = 'bash -c "git worktree remove worktrees/item-a-101'

            # Act
            $decision = Invoke-CodexWorktreeRemovalDecision -PayloadRaw (ConvertTo-CodexWorktreeTriggerScopingPayload -Command $command) -EpicCheckpointRaw $script:AuthorizingCheckpoint

            # Assert
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
            $decision.hookSpecificOutput.permissionDecisionReason |
                Should -Match '^EPIC_WORKTREE_REMOVAL_BLOCKED'
        }

        It 'A824-WT8 denies a removal whose subcommand is carried by an expansion even with an authorizing record' -Tag 'Issue824' {
            # Arrange
            $command = 'bash -c ''a="worktree remove"; git $a worktrees/item-a-101'''

            # Act
            $decision = Invoke-CodexWorktreeRemovalDecision -PayloadRaw (ConvertTo-CodexWorktreeTriggerScopingPayload -Command $command) -EpicCheckpointRaw $script:AuthorizingCheckpoint

            # Assert
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
            $decision.hookSpecificOutput.permissionDecisionReason |
                Should -Match '^EPIC_WORKTREE_REMOVAL_BLOCKED'
        }
    }

    Context 'issue #824 cycle 2 - review pass 2 removal forms without an authorizing record' {
        It 'A824-X<Id> denies <Label> without an authorizing record' -Tag 'Issue824' -ForEach @(
            @{ Id = 1; Label = 'bash -c ''echo /repo/worktrees/item-a-101 | xargs git worktree remove'''; Command = 'bash -c ''echo /repo/worktrees/item-a-101 | xargs git worktree remove''' }
            @{ Id = 2; Label = 'echo /repo/worktrees/item-a-101 | xargs git worktree remove'; Command = 'echo /repo/worktrees/item-a-101 | xargs git worktree remove' }
            @{ Id = 3; Label = 'pwsh -c ''git worktree remove (Join-Path /repo/worktrees item-a-101)'''; Command = 'pwsh -c ''git worktree remove (Join-Path /repo/worktrees item-a-101)''' }
            @{ Id = 4; Label = 'bash -c ''git worktree remove >/dev/null /repo/worktrees/item-a-101'''; Command = 'bash -c ''git worktree remove >/dev/null /repo/worktrees/item-a-101''' }
            @{ Id = 7; Label = 'pwsh -c ''git worktree remove --force (Get-Item /repo/worktrees/item-a-101)'''; Command = 'pwsh -c ''git worktree remove --force (Get-Item /repo/worktrees/item-a-101)''' }
            @{ Id = 8; Label = 'bash -c ''printf "%s" /repo/worktrees/item-a-101 | xargs git worktree remove --force'''; Command = 'bash -c ''printf "%s" /repo/worktrees/item-a-101 | xargs git worktree remove --force''' }
            @{ Id = 10; Label = 'bash -c ''git worktree remove </dev/null /repo/worktrees/item-a-101'''; Command = 'bash -c ''git worktree remove </dev/null /repo/worktrees/item-a-101''' }
        ) {
            # Arrange: $Command comes from the -ForEach row. No literal operand follows the
            # classified removal, so the gate keeps the structural path.

            # Act
            $decision = Invoke-CodexWorktreeRemovalDecision -PayloadRaw (ConvertTo-CodexWorktreeTriggerScopingPayload -Command $Command) -EpicCheckpointRaw $script:UnrelatedCheckpoint

            # Assert
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
            $decision.hookSpecificOutput.permissionDecisionReason |
                Should -Match '^EPIC_WORKTREE_REMOVAL_BLOCKED'
        }

        It 'A824-WT10 denies a wrapped removal whose operand is an expansion without an authorizing record' -Tag 'Issue824' {
            # Arrange
            $command = 'bash -c ''git worktree remove "$target"'''

            # Act
            $decision = Invoke-CodexWorktreeRemovalDecision -PayloadRaw (ConvertTo-CodexWorktreeTriggerScopingPayload -Command $command) -EpicCheckpointRaw $script:UnrelatedCheckpoint

            # Assert
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
            $decision.hookSpecificOutput.permissionDecisionReason |
                Should -Match '^EPIC_WORKTREE_REMOVAL_BLOCKED'
        }
    }

    Context 'issue #824 cycle 2 - non-literal operand outcomes with an authorizing record' {
        BeforeAll {
            $script:AuthorizingCheckpoint = @{ features = @(@{ worktree_path = $script:TargetPath; merge_status = 'merged' }) } | ConvertTo-Json -Compress -Depth 4
        }

        It 'A824-WT11-<Id> denies <Label> even with an authorizing record' -Tag 'Issue824' -ForEach @(
            @{ Id = 1; Label = 'pwsh -NoProfile -Command ''git worktree remove'''; Command = 'pwsh -NoProfile -Command ''git worktree remove''' }
            @{ Id = 2; Label = 'bash -c ''git worktree remove "$target"'''; Command = 'bash -c ''git worktree remove "$target"''' }
        ) {
            # Arrange: $Command comes from the -ForEach row. Neither form yields exactly one
            # literal operand, so the record cannot authorize it.

            # Act
            $decision = Invoke-CodexWorktreeRemovalDecision -PayloadRaw (ConvertTo-CodexWorktreeTriggerScopingPayload -Command $Command) -EpicCheckpointRaw $script:AuthorizingCheckpoint

            # Assert
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
            $decision.hookSpecificOutput.permissionDecisionReason |
                Should -Match '^EPIC_WORKTREE_REMOVAL_BLOCKED'
        }
    }
}
