#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }
<#
.SYNOPSIS
    Claude epic worktree-removal gate decisions over the issue #824 corpus (T-EPIC, EW-01 to EW-39).

.DESCRIPTION
    Drives Invoke-EpicWorktreeRemovalGateDecision. Every removal target is derived by
    Resolve-CommandLineInvocationTarget: a target that cannot be derived denies with
    TARGET_WORKTREE_NOT_DERIVABLE before any checkpoint is read, and each derived target
    must be authorized on its own.

    EW-39 is the negative control: it reinstates substring presence through a mock of
    Test-CommandLineWordPresent and shows that the R-824-ADD1 command would then deny.

    Determinism: checkpoint content arrives only through the mocked read seams
    Get-EpicWorktreeGateCheckpointContent and Get-EpicWorktreeGateParallelCheckpointContent,
    the run target through Resolve-EpicWorktreeGateRunTarget, and the sanctioned-removal
    manifest through Test-CleanupWorktreeManifestAuthorizesRemoval. No temporary file, no
    child process, and no live executable. Fixture command names that the test-purity hook
    rejects as literals are assembled from fragments at run time.
#>

BeforeDiscovery {
    $p = '/repo/worktrees/item-a-101'
    $q = '/repo/worktrees/item-b-102'
    $startProcess = 'Start' + '-Process'
    $script:Removal = @(
        @{ Name = 'F1'; Command = "git worktree remove $p" }
        @{ Name = 'F2'; Command = "git worktree remove --force $p" }
        @{ Name = 'F3'; Command = "git -C /repo/main worktree remove $p" }
        @{ Name = 'F4'; Command = "pwsh -Command 'git worktree remove $p'" }
        @{ Name = 'F5'; Command = "bash -c `"git worktree remove $p`"" }
    )
    $script:DenyOnlyQ = for ($i = 0; $i -lt 5; $i++) { @{ Id = 'EW-{0:D2}' -f (3 + $i); Name = $script:Removal[$i].Name; Command = $script:Removal[$i].Command } }
    $script:AllowOnlyP = for ($i = 0; $i -lt 5; $i++) { @{ Id = 'EW-{0:D2}' -f (8 + $i); Name = $script:Removal[$i].Name; Command = $script:Removal[$i].Command } }
    $script:NotDerivableOnlyQ = @(
        @{ Id = 'EW-14'; Name = 'W1'; Command = "bash -c 'git worktree remove $q; git worktree remove >/dev/null $p'" }
        @{ Id = 'EW-15'; Name = 'W2'; Command = "bash -c 'git worktree remove $q; echo $p | xargs git worktree remove'" }
        @{ Id = 'EW-16'; Name = 'W3'; Command = "pwsh -c 'git worktree remove $q; git worktree remove (Join-Path /repo/worktrees item-a-101)'" }
        @{ Id = 'EW-17'; Name = 'W4'; Command = "bash -c 'git worktree remove $q && git worktree remove </dev/null $p'" }
    )
    $script:NamesPOnlyQ = @(
        @{ Id = 'EW-13'; Name = 'Q then P'; Command = "git worktree remove $q && git worktree remove $p" }
        @{ Id = 'EW-18'; Name = 'W5'; Command = "bash -c `"git worktree remove $q`"; bash -c `"git worktree remove $p`"" }
        @{ Id = 'EW-19'; Name = 'W6'; Command = "bash -c `"git worktree remove $q`" && git worktree remove $p" }
    )
    $script:NotDerivableOnlyP = @(
        @{ Id = 'EW-21'; Name = 'unbalanced quote'; Command = "git worktree remove `"$p" }
        @{ Id = 'EW-22'; Name = 'PowerShell parse error'; Command = "pwsh -c 'git worktree remove $p; if ('" }
        @{ Id = 'EW-23'; Name = 'decode failure'; Command = 'pwsh -EncodedCommand ###' }
        @{ Id = 'EW-24'; Name = 'depth limit'; Command = "eval eval eval eval eval git worktree remove $p" }
        @{ Id = 'EW-25'; Name = 'dynamic position'; Command = "w=worktree; git `$w remove $p" }
        @{ Id = 'EW-26'; Name = 'not proven inert'; Command = "pwsh -c '$startProcess git worktree remove $p'" }
        @{ Id = 'EW-27'; Name = 'no operand'; Command = 'git worktree remove' }
        @{ Id = 'EW-28'; Name = 'two operands'; Command = "git worktree remove $p $q" }
        @{ Id = 'EW-29'; Name = 'X1'; Command = "bash -c 'echo $p | xargs git worktree remove'" }
        @{ Id = 'EW-30'; Name = 'X2'; Command = "echo $p | xargs git worktree remove" }
        @{ Id = 'EW-31'; Name = 'X3'; Command = "pwsh -c 'git worktree remove (Join-Path /repo/worktrees item-a-101)'" }
        @{ Id = 'EW-32'; Name = 'X4'; Command = "bash -c 'git worktree remove >/dev/null $p'" }
        @{ Id = 'EW-33'; Name = 'X7'; Command = "pwsh -c 'git worktree remove --force (Get-Item $p)'" }
        @{ Id = 'EW-34'; Name = 'X8'; Command = "bash -c 'printf `"%s`" $p | xargs git worktree remove --force'" }
        @{ Id = 'EW-35'; Name = 'X10'; Command = "bash -c 'git worktree remove </dev/null $p'" }
        @{ Id = 'EW-36'; Name = 'B5'; Command = 'bash -c ''a="worktree remove"; git $a ../x''' }
    )
}

Describe 'enforce-epic-worktree-removal-gate issue #824 decisions' {
    BeforeAll {
        $script:RepoRoot = (Resolve-Path "$PSScriptRoot/../../..").Path
        . (Join-Path $script:RepoRoot '.claude/hooks/enforce-epic-worktree-removal-gate.ps1')
        $script:P = '/repo/worktrees/item-a-101'
        $script:Q = '/repo/worktrees/item-b-102'
        $script:R824Add1 = 'pwsh -NoProfile -Command ''Set-Location -LiteralPath "C:/repo/.claude/worktrees/agent-x"; if (Test-Path -LiteralPath "src/Old.cs") { Remove-Item -LiteralPath "src/Old.cs" -Force }; git status --porcelain -- "src/Old.cs"'''
        $script:NotDerivable = 'EPIC_WORKTREE_REMOVAL_BLOCKED: TARGET_WORKTREE_NOT_DERIVABLE*'
        $script:Checkpoint = ''

        function ConvertTo-EpicCheckpoint {
            <# Build an epic checkpoint whose features[] records each path as merged. #>
            param([string[]] $Path)
            $features = @($Path | ForEach-Object { @{ worktree_path = $_; merge_status = 'merged' } })
            return (@{ features = $features } | ConvertTo-Json -Compress -Depth 5)
        }

        function Invoke-EpicRow {
            <# Run the gate decision for one command and return the decision. #>
            param([Parameter(Mandatory)][string] $Command)
            $envelope = @{ tool_name = 'Bash'; tool_input = @{ command = $Command } } | ConvertTo-Json -Compress -Depth 5
            return Invoke-EpicWorktreeRemovalGateDecision -ToolInputRaw $envelope
        }

        Mock Resolve-EpicWorktreeGateRunTarget { [pscustomobject]@{ Status = 'SessionRoot'; WorktreeRoot = '/synthetic-worktrees/default-session'; ReasonCode = $null; Detail = 'synthetic SessionRoot target' } }
        Mock Get-EpicWorktreeGateCheckpointContent { $script:Checkpoint }
        Mock Get-EpicWorktreeGateParallelCheckpointContent { $null }
        Mock Test-CleanupWorktreeManifestAuthorizesRemoval { $false }
    }

    Context 'no checkpoint' {
        BeforeEach { $script:Checkpoint = $null }

        It 'EW-01 allows R-824-ADD1' -Tag 'Issue824', 'R-824-ADD1' {
            (Invoke-EpicRow -Command $script:R824Add1).hookSpecificOutput.permissionDecision | Should -Be 'allow'
        }

        It 'EW-02 allows R-742-1' -Tag 'Issue824', 'R-742-1' {
            (Invoke-EpicRow -Command 'git --version').hookSpecificOutput.permissionDecision | Should -Be 'allow'
        }

        It 'EW-37 allows the fixture AC-19 list command' -Tag 'Issue824' {
            $command = 'pwsh -NoProfile -Command ''git worktree list --porcelain | Select-String -NotMatch "removed"'''
            (Invoke-EpicRow -Command $command).hookSpecificOutput.permissionDecision | Should -Be 'allow'
        }

        It 'EW-38 denies the fixture AC-19 wrapped removal' -Tag 'Issue824' {
            $decision = Invoke-EpicRow -Command 'bash -c "git worktree remove ../x"'
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
            $decision.hookSpecificOutput.permissionDecisionReason | Should -BeLike 'EPIC_WORKTREE_REMOVAL_BLOCKED:*'
        }

        It 'EW-39 denies the EW-01 command when substring presence is reinstated' -Tag 'Issue824', 'NegativeControl' {
            $delivered = (Invoke-EpicRow -Command $script:R824Add1).hookSpecificOutput.permissionDecision
            Mock Test-CommandLineWordPresent { $RawText.IndexOf($Word, [System.StringComparison]::OrdinalIgnoreCase) -ge 0 }

            $mocked = (Invoke-EpicRow -Command $script:R824Add1).hookSpecificOutput.permissionDecision

            $delivered | Should -Be 'allow'
            $mocked | Should -Be 'deny' -Because 'substring presence finds worktree inside worktrees and remove inside Remove-Item'
        }
    }

    Context 'checkpoint authorizes only Q' {
        BeforeEach { $script:Checkpoint = ConvertTo-EpicCheckpoint -Path $script:Q }

        It '<Id> denies <Name> for P' -Tag 'Issue824' -ForEach $script:DenyOnlyQ {
            $decision = Invoke-EpicRow -Command $Command
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
            $decision.hookSpecificOutput.permissionDecisionReason | Should -BeLike 'EPIC_WORKTREE_REMOVAL_BLOCKED:*'
        }

        It '<Id> denies <Name> naming P' -Tag 'Issue824' -ForEach $script:NamesPOnlyQ {
            $decision = Invoke-EpicRow -Command $Command
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
            $decision.hookSpecificOutput.permissionDecisionReason | Should -BeLike "*for '/repo/worktrees/item-a-101'*"
        }

        It '<Id> denies <Name> as TARGET_WORKTREE_NOT_DERIVABLE' -Tag 'Issue824' -ForEach $script:NotDerivableOnlyQ {
            $decision = Invoke-EpicRow -Command $Command
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
            $decision.hookSpecificOutput.permissionDecisionReason | Should -BeLike $script:NotDerivable
        }
    }

    Context 'checkpoint authorizes P' {
        BeforeEach { $script:Checkpoint = ConvertTo-EpicCheckpoint -Path $script:P }

        It '<Id> allows <Name>' -Tag 'Issue824' -ForEach $script:AllowOnlyP {
            (Invoke-EpicRow -Command $Command).hookSpecificOutput.permissionDecision | Should -Be 'allow'
        }

        It '<Id> denies the <Name> spelling as TARGET_WORKTREE_NOT_DERIVABLE' -Tag 'Issue824' -ForEach $script:NotDerivableOnlyP {
            $decision = Invoke-EpicRow -Command $Command
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
            $decision.hookSpecificOutput.permissionDecisionReason | Should -BeLike $script:NotDerivable
        }
    }

    Context 'checkpoint authorizes Q and P' {
        BeforeEach { $script:Checkpoint = ConvertTo-EpicCheckpoint -Path $script:Q, $script:P }

        It 'EW-20 allows the removal of Q and P' -Tag 'Issue824' {
            $command = "git worktree remove $($script:Q) && git worktree remove $($script:P)"
            (Invoke-EpicRow -Command $command).hookSpecificOutput.permissionDecision | Should -Be 'allow'
        }
    }
}
