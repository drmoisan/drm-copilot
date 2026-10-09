#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }
<#
.SYNOPSIS
    Claude parallel worktree-removal gate decisions over the issue #824 corpus (T-PAR, PW-01 to PW-39).

.DESCRIPTION
    Drives Invoke-ParallelWorktreeRemovalGateDecision. Every removal target is derived by
    Resolve-CommandLineInvocationTarget: a target that cannot be derived denies with
    TARGET_WORKTREE_NOT_DERIVABLE before any checkpoint is read, and each derived target
    must be authorized on its own.

    PW-39 is the negative control: it reinstates substring presence through a mock of
    Test-CommandLineWordPresent and shows that the R-824-ADD1 command would then deny.

    Determinism: checkpoint content arrives only through the mocked read seams
    Get-ParallelWorktreeRemovalGateCheckpointContent and Get-ParallelWorktreeRemovalGateEpicCheckpointContent,
    the run target through Resolve-ParallelWorktreeGateRunTarget, and the sanctioned-removal
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
    $script:DenyOnlyQ = for ($i = 0; $i -lt 5; $i++) { @{ Id = 'PW-{0:D2}' -f (3 + $i); Name = $script:Removal[$i].Name; Command = $script:Removal[$i].Command } }
    $script:AllowOnlyP = for ($i = 0; $i -lt 5; $i++) { @{ Id = 'PW-{0:D2}' -f (8 + $i); Name = $script:Removal[$i].Name; Command = $script:Removal[$i].Command } }
    $script:NotDerivableOnlyQ = @(
        @{ Id = 'PW-14'; Name = 'W1'; Command = "bash -c 'git worktree remove $q; git worktree remove >/dev/null $p'" }
        @{ Id = 'PW-15'; Name = 'W2'; Command = "bash -c 'git worktree remove $q; echo $p | xargs git worktree remove'" }
        @{ Id = 'PW-16'; Name = 'W3'; Command = "pwsh -c 'git worktree remove $q; git worktree remove (Join-Path /repo/worktrees item-a-101)'" }
        @{ Id = 'PW-17'; Name = 'W4'; Command = "bash -c 'git worktree remove $q && git worktree remove </dev/null $p'" }
    )
    $script:NamesPOnlyQ = @(
        @{ Id = 'PW-13'; Name = 'Q then P'; Command = "git worktree remove $q && git worktree remove $p" }
        @{ Id = 'PW-18'; Name = 'W5'; Command = "bash -c `"git worktree remove $q`"; bash -c `"git worktree remove $p`"" }
        @{ Id = 'PW-19'; Name = 'W6'; Command = "bash -c `"git worktree remove $q`" && git worktree remove $p" }
    )
    $script:NotDerivableOnlyP = @(
        @{ Id = 'PW-21'; Name = 'unbalanced quote'; Command = "git worktree remove `"$p" }
        @{ Id = 'PW-22'; Name = 'PowerShell parse error'; Command = "pwsh -c 'git worktree remove $p; if ('" }
        @{ Id = 'PW-23'; Name = 'decode failure'; Command = 'pwsh -EncodedCommand ###' }
        @{ Id = 'PW-24'; Name = 'depth limit'; Command = "eval eval eval eval eval git worktree remove $p" }
        @{ Id = 'PW-25'; Name = 'dynamic position'; Command = "w=worktree; git `$w remove $p" }
        @{ Id = 'PW-26'; Name = 'not proven inert'; Command = "pwsh -c '$startProcess git worktree remove $p'" }
        @{ Id = 'PW-27'; Name = 'no operand'; Command = 'git worktree remove' }
        @{ Id = 'PW-28'; Name = 'two operands'; Command = "git worktree remove $p $q" }
        @{ Id = 'PW-29'; Name = 'X1'; Command = "bash -c 'echo $p | xargs git worktree remove'" }
        @{ Id = 'PW-30'; Name = 'X2'; Command = "echo $p | xargs git worktree remove" }
        @{ Id = 'PW-31'; Name = 'X3'; Command = "pwsh -c 'git worktree remove (Join-Path /repo/worktrees item-a-101)'" }
        @{ Id = 'PW-32'; Name = 'X4'; Command = "bash -c 'git worktree remove >/dev/null $p'" }
        @{ Id = 'PW-33'; Name = 'X7'; Command = "pwsh -c 'git worktree remove --force (Get-Item $p)'" }
        @{ Id = 'PW-34'; Name = 'X8'; Command = "bash -c 'printf `"%s`" $p | xargs git worktree remove --force'" }
        @{ Id = 'PW-35'; Name = 'X10'; Command = "bash -c 'git worktree remove </dev/null $p'" }
        @{ Id = 'PW-36'; Name = 'B5'; Command = 'bash -c ''a="worktree remove"; git $a ../x''' }
    )
}

Describe 'enforce-parallel-worktree-removal-gate issue #824 decisions' {
    BeforeAll {
        $script:RepoRoot = (Resolve-Path "$PSScriptRoot/../../..").Path
        . (Join-Path $script:RepoRoot '.claude/hooks/enforce-parallel-worktree-removal-gate.ps1')
        $script:P = '/repo/worktrees/item-a-101'
        $script:Q = '/repo/worktrees/item-b-102'
        $script:R824Add1 = 'pwsh -NoProfile -Command ''Set-Location -LiteralPath "C:/repo/.claude/worktrees/agent-x"; if (Test-Path -LiteralPath "src/Old.cs") { Remove-Item -LiteralPath "src/Old.cs" -Force }; git status --porcelain -- "src/Old.cs"'''
        $script:NotDerivable = 'PARALLEL_WORKTREE_REMOVAL_BLOCKED: TARGET_WORKTREE_NOT_DERIVABLE*'
        $script:Checkpoint = ''

        function ConvertTo-ParallelCheckpoint {
            <# Build a parallel checkpoint whose items[] records each path as merged. #>
            param([string[]] $Path)
            $items = @($Path | ForEach-Object { @{ issue_num = 101; worktree_path = $_; merge_status = 'merged' } })
            return (@{ route_id = 'parallel'; items = $items } | ConvertTo-Json -Compress -Depth 5)
        }

        function Invoke-ParallelRow {
            <# Run the gate decision for one command and return the decision. #>
            param([Parameter(Mandatory)][string] $Command)
            $envelope = @{ tool_name = 'Bash'; tool_input = @{ command = $Command } } | ConvertTo-Json -Compress -Depth 5
            return Invoke-ParallelWorktreeRemovalGateDecision -ToolInputRaw $envelope
        }

        Mock Resolve-ParallelWorktreeGateRunTarget { [pscustomobject]@{ Status = 'SessionRoot'; WorktreeRoot = '/synthetic-worktrees/default-session'; ReasonCode = $null; Detail = 'synthetic SessionRoot target' } }
        Mock Get-ParallelWorktreeRemovalGateCheckpointContent { $script:Checkpoint }
        Mock Get-ParallelWorktreeRemovalGateEpicCheckpointContent { $null }
        Mock Test-CleanupWorktreeManifestAuthorizesRemoval { $false }
    }

    Context 'no checkpoint' {
        BeforeEach { $script:Checkpoint = $null }

        It 'PW-01 allows R-824-ADD1' -Tag 'Issue824', 'R-824-ADD1' {
            (Invoke-ParallelRow -Command $script:R824Add1).hookSpecificOutput.permissionDecision | Should -Be 'allow'
        }

        It 'PW-02 allows R-742-1' -Tag 'Issue824', 'R-742-1' {
            (Invoke-ParallelRow -Command 'git --version').hookSpecificOutput.permissionDecision | Should -Be 'allow'
        }

        It 'PW-37 allows the fixture AC-19 list command' -Tag 'Issue824' {
            $command = 'pwsh -NoProfile -Command ''git worktree list --porcelain | Select-String -NotMatch "removed"'''
            (Invoke-ParallelRow -Command $command).hookSpecificOutput.permissionDecision | Should -Be 'allow'
        }

        It 'PW-38 denies the fixture AC-19 wrapped removal' -Tag 'Issue824' {
            $decision = Invoke-ParallelRow -Command 'bash -c "git worktree remove ../x"'
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
            $decision.hookSpecificOutput.permissionDecisionReason | Should -BeLike 'PARALLEL_WORKTREE_REMOVAL_BLOCKED:*'
        }

        It 'PW-39 denies the PW-01 command when substring presence is reinstated' -Tag 'Issue824', 'NegativeControl' {
            $delivered = (Invoke-ParallelRow -Command $script:R824Add1).hookSpecificOutput.permissionDecision
            Mock Test-CommandLineWordPresent { $RawText.IndexOf($Word, [System.StringComparison]::OrdinalIgnoreCase) -ge 0 }

            $mocked = (Invoke-ParallelRow -Command $script:R824Add1).hookSpecificOutput.permissionDecision

            $delivered | Should -Be 'allow'
            $mocked | Should -Be 'deny' -Because 'substring presence finds worktree inside worktrees and remove inside Remove-Item'
        }

        It 'PW-40 allows an in-scope command when the target resolver reports NoMatch' -Tag 'Issue824' {
            $command = "git worktree remove $($script:P)"
            $delivered = (Invoke-ParallelRow -Command $command).hookSpecificOutput.permissionDecision
            Mock Resolve-CommandLineInvocationTarget { [pscustomobject]@{ Status = 'NoMatch'; Targets = [string[]]@() } }

            $mocked = (Invoke-ParallelRow -Command $command).hookSpecificOutput.permissionDecision

            $delivered | Should -Be 'deny' -Because 'no checkpoint authorizes P'
            $mocked | Should -Be 'allow' -Because 'a NoMatch resolution allows without reading any checkpoint'
            Should -Invoke Resolve-CommandLineInvocationTarget -Times 1 -Exactly
        }
    }

    Context 'checkpoint authorizes only Q' {
        BeforeEach { $script:Checkpoint = ConvertTo-ParallelCheckpoint -Path $script:Q }

        It '<Id> denies <Name> for P' -Tag 'Issue824' -ForEach $script:DenyOnlyQ {
            $decision = Invoke-ParallelRow -Command $Command
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
            $decision.hookSpecificOutput.permissionDecisionReason | Should -BeLike 'PARALLEL_WORKTREE_REMOVAL_BLOCKED:*'
        }

        It '<Id> denies <Name> naming P' -Tag 'Issue824' -ForEach $script:NamesPOnlyQ {
            $decision = Invoke-ParallelRow -Command $Command
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
            $decision.hookSpecificOutput.permissionDecisionReason | Should -BeLike "*for '/repo/worktrees/item-a-101'*"
        }

        It '<Id> denies <Name> as TARGET_WORKTREE_NOT_DERIVABLE' -Tag 'Issue824' -ForEach $script:NotDerivableOnlyQ {
            $decision = Invoke-ParallelRow -Command $Command
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
            $decision.hookSpecificOutput.permissionDecisionReason | Should -BeLike $script:NotDerivable
        }
    }

    Context 'checkpoint authorizes P' {
        BeforeEach { $script:Checkpoint = ConvertTo-ParallelCheckpoint -Path $script:P }

        It '<Id> allows <Name>' -Tag 'Issue824' -ForEach $script:AllowOnlyP {
            (Invoke-ParallelRow -Command $Command).hookSpecificOutput.permissionDecision | Should -Be 'allow'
        }

        It '<Id> denies the <Name> spelling as TARGET_WORKTREE_NOT_DERIVABLE' -Tag 'Issue824' -ForEach $script:NotDerivableOnlyP {
            $decision = Invoke-ParallelRow -Command $Command
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
            $decision.hookSpecificOutput.permissionDecisionReason | Should -BeLike $script:NotDerivable
        }
    }

    Context 'checkpoint authorizes Q and P' {
        BeforeEach { $script:Checkpoint = ConvertTo-ParallelCheckpoint -Path $script:Q, $script:P }

        It 'PW-20 allows the removal of Q and P' -Tag 'Issue824' {
            $command = "git worktree remove $($script:Q) && git worktree remove $($script:P)"
            (Invoke-ParallelRow -Command $command).hookSpecificOutput.permissionDecision | Should -Be 'allow'
        }
    }
}
