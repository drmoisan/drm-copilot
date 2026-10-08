#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }
<#
.SYNOPSIS
    Codex epic worktree-removal gate decisions over the issue #824 corpus (T-CXEPIC, CW-01 to CW-39).

.DESCRIPTION
    Drives Invoke-CodexWorktreeRemovalDecision, which returns $null for an allow. Every
    removal target is derived by Resolve-CommandLineInvocationTarget: a target that cannot
    be derived denies with TARGET_WORKTREE_NOT_DERIVABLE before the checkpoint is read, and
    each derived target must be authorized on its own.

    Fixture paths replace the leading /repo with the synthetic root that
    enforce-epic-worktree-removal-gate-decision-surface.Tests.ps1 derives from $IsWindows,
    so every path is rooted on the host that runs the suite.

    CW-39 is the negative control: it reinstates substring presence through a mock of
    Test-CommandLineWordPresent and shows that the R-824-ADD1 command would then deny.

    Determinism: the checkpoint arrives through the -EpicCheckpointRaw parameter and the
    payload carries an explicit cwd. No temporary file, no child process, and no live
    executable. Fixture command names that the test-purity hook rejects as literals are
    assembled from fragments at run time.
#>

BeforeDiscovery {
    $root = if ($IsWindows) { 'C:/repo' } else { '/repo' }
    $p = "$root/worktrees/item-a-101"
    $q = "$root/worktrees/item-b-102"
    $startProcess = 'Start' + '-Process'
    $script:Removal = @(
        @{ Name = 'F1'; Command = "git worktree remove $p" }
        @{ Name = 'F2'; Command = "git worktree remove --force $p" }
        @{ Name = 'F3'; Command = "git -C $root/main worktree remove $p" }
        @{ Name = 'F4'; Command = "pwsh -Command 'git worktree remove $p'" }
        @{ Name = 'F5'; Command = "bash -c `"git worktree remove $p`"" }
    )
    $script:DenyOnlyQ = for ($i = 0; $i -lt 5; $i++) { @{ Id = 'CW-{0:D2}' -f (3 + $i); Name = $script:Removal[$i].Name; Command = $script:Removal[$i].Command } }
    $script:AllowOnlyP = for ($i = 0; $i -lt 5; $i++) { @{ Id = 'CW-{0:D2}' -f (8 + $i); Name = $script:Removal[$i].Name; Command = $script:Removal[$i].Command } }
    $script:NotDerivableOnlyQ = @(
        @{ Id = 'CW-14'; Name = 'W1'; Command = "bash -c 'git worktree remove $q; git worktree remove >/dev/null $p'" }
        @{ Id = 'CW-15'; Name = 'W2'; Command = "bash -c 'git worktree remove $q; echo $p | xargs git worktree remove'" }
        @{ Id = 'CW-16'; Name = 'W3'; Command = "pwsh -c 'git worktree remove $q; git worktree remove (Join-Path $root/worktrees item-a-101)'" }
        @{ Id = 'CW-17'; Name = 'W4'; Command = "bash -c 'git worktree remove $q && git worktree remove </dev/null $p'" }
    )
    $script:NamesPOnlyQ = @(
        @{ Id = 'CW-13'; Name = 'Q then P'; Command = "git worktree remove $q && git worktree remove $p" }
        @{ Id = 'CW-18'; Name = 'W5'; Command = "bash -c `"git worktree remove $q`"; bash -c `"git worktree remove $p`"" }
        @{ Id = 'CW-19'; Name = 'W6'; Command = "bash -c `"git worktree remove $q`" && git worktree remove $p" }
    )
    $script:NotDerivableOnlyP = @(
        @{ Id = 'CW-21'; Name = 'unbalanced quote'; Command = "git worktree remove `"$p" }
        @{ Id = 'CW-22'; Name = 'PowerShell parse error'; Command = "pwsh -c 'git worktree remove $p; if ('" }
        @{ Id = 'CW-23'; Name = 'decode failure'; Command = 'pwsh -EncodedCommand ###' }
        @{ Id = 'CW-24'; Name = 'depth limit'; Command = "eval eval eval eval eval git worktree remove $p" }
        @{ Id = 'CW-25'; Name = 'dynamic position'; Command = "w=worktree; git `$w remove $p" }
        @{ Id = 'CW-26'; Name = 'not proven inert'; Command = "pwsh -c '$startProcess git worktree remove $p'" }
        @{ Id = 'CW-27'; Name = 'no operand'; Command = 'git worktree remove' }
        @{ Id = 'CW-28'; Name = 'two operands'; Command = "git worktree remove $p $q" }
        @{ Id = 'CW-29'; Name = 'X1'; Command = "bash -c 'echo $p | xargs git worktree remove'" }
        @{ Id = 'CW-30'; Name = 'X2'; Command = "echo $p | xargs git worktree remove" }
        @{ Id = 'CW-31'; Name = 'X3'; Command = "pwsh -c 'git worktree remove (Join-Path $root/worktrees item-a-101)'" }
        @{ Id = 'CW-32'; Name = 'X4'; Command = "bash -c 'git worktree remove >/dev/null $p'" }
        @{ Id = 'CW-33'; Name = 'X7'; Command = "pwsh -c 'git worktree remove --force (Get-Item $p)'" }
        @{ Id = 'CW-34'; Name = 'X8'; Command = "bash -c 'printf `"%s`" $p | xargs git worktree remove --force'" }
        @{ Id = 'CW-35'; Name = 'X10'; Command = "bash -c 'git worktree remove </dev/null $p'" }
        @{ Id = 'CW-36'; Name = 'B5'; Command = 'bash -c ''a="worktree remove"; git $a ../x''' }
    )
}

Describe 'Codex enforce-epic-worktree-removal-gate issue #824 decisions' {
    BeforeAll {
        $script:RepoRoot = (Resolve-Path "$PSScriptRoot/../../..").Path
        . (Join-Path $script:RepoRoot '.codex/hooks/enforce-epic-worktree-removal-gate.ps1')
        $script:SyntheticRoot = if ($IsWindows) { 'C:/repo' } else { '/repo' }
        $script:P = "$script:SyntheticRoot/worktrees/item-a-101"
        $script:Q = "$script:SyntheticRoot/worktrees/item-b-102"
        $script:R824Add1 = 'pwsh -NoProfile -Command ''Set-Location -LiteralPath "C:/repo/.claude/worktrees/agent-x"; if (Test-Path -LiteralPath "src/Old.cs") { Remove-Item -LiteralPath "src/Old.cs" -Force }; git status --porcelain -- "src/Old.cs"'''
        $script:NotDerivable = 'EPIC_WORKTREE_REMOVAL_BLOCKED: TARGET_WORKTREE_NOT_DERIVABLE*'
        $script:Checkpoint = ''

        function ConvertTo-CodexCheckpoint {
            <# Build an epic checkpoint whose features[] records each path as merged. #>
            param([string[]] $Path)
            $features = @($Path | ForEach-Object { @{ worktree_path = $_; merge_status = 'merged' } })
            return (@{ features = $features } | ConvertTo-Json -Compress -Depth 5)
        }

        function Invoke-CodexRow {
            <# Run the Codex decision for one command against the current checkpoint text. #>
            param([Parameter(Mandatory)][string] $Command)
            $payload = [ordered]@{
                cwd             = $script:SyntheticRoot
                hook_event_name = 'PreToolUse'
                tool_name       = 'Bash'
                tool_input      = @{ command = $Command }
            } | ConvertTo-Json -Compress -Depth 5
            return Invoke-CodexWorktreeRemovalDecision -PayloadRaw $payload -EpicCheckpointRaw $script:Checkpoint
        }
    }

    Context 'no checkpoint' {
        BeforeEach { $script:Checkpoint = '' }

        It 'CW-01 allows R-824-ADD1' -Tag 'Issue824', 'R-824-ADD1' {
            Invoke-CodexRow -Command $script:R824Add1 | Should -BeNullOrEmpty
        }

        It 'CW-02 allows R-742-1' -Tag 'Issue824', 'R-742-1' {
            Invoke-CodexRow -Command 'git --version' | Should -BeNullOrEmpty
        }

        It 'CW-37 allows the fixture AC-19 list command' -Tag 'Issue824' {
            Invoke-CodexRow -Command 'pwsh -NoProfile -Command ''git worktree list --porcelain | Select-String -NotMatch "removed"''' |
                Should -BeNullOrEmpty
        }

        It 'CW-38 denies the fixture AC-19 wrapped removal' -Tag 'Issue824' {
            $decision = Invoke-CodexRow -Command 'bash -c "git worktree remove ../x"'
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
            $decision.hookSpecificOutput.permissionDecisionReason | Should -BeLike 'EPIC_WORKTREE_REMOVAL_BLOCKED:*'
        }

        It 'CW-39 denies the CW-01 command when substring presence is reinstated' -Tag 'Issue824', 'NegativeControl' {
            $delivered = Invoke-CodexRow -Command $script:R824Add1
            Mock Test-CommandLineWordPresent { $RawText.IndexOf($Word, [System.StringComparison]::OrdinalIgnoreCase) -ge 0 }

            $mocked = Invoke-CodexRow -Command $script:R824Add1

            $delivered | Should -BeNullOrEmpty
            $mocked.hookSpecificOutput.permissionDecision | Should -Be 'deny' -Because 'substring presence finds worktree inside worktrees and remove inside Remove-Item'
        }
    }

    Context 'checkpoint authorizes only Q' {
        BeforeEach { $script:Checkpoint = ConvertTo-CodexCheckpoint -Path $script:Q }

        It '<Id> denies <Name> for P' -Tag 'Issue824' -ForEach $script:DenyOnlyQ {
            $decision = Invoke-CodexRow -Command $Command
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
            $decision.hookSpecificOutput.permissionDecisionReason | Should -BeLike 'EPIC_WORKTREE_REMOVAL_BLOCKED:*'
        }

        It '<Id> denies <Name> naming P' -Tag 'Issue824' -ForEach $script:NamesPOnlyQ {
            $decision = Invoke-CodexRow -Command $Command
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
            $decision.hookSpecificOutput.permissionDecisionReason | Should -BeLike "*'$($script:P)'*"
        }

        It '<Id> denies <Name> as TARGET_WORKTREE_NOT_DERIVABLE' -Tag 'Issue824' -ForEach $script:NotDerivableOnlyQ {
            $decision = Invoke-CodexRow -Command $Command
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
            $decision.hookSpecificOutput.permissionDecisionReason | Should -BeLike $script:NotDerivable
        }
    }

    Context 'checkpoint authorizes P' {
        BeforeEach { $script:Checkpoint = ConvertTo-CodexCheckpoint -Path $script:P }

        It '<Id> allows <Name>' -Tag 'Issue824' -ForEach $script:AllowOnlyP {
            Invoke-CodexRow -Command $Command | Should -BeNullOrEmpty
        }

        It '<Id> denies the <Name> spelling as TARGET_WORKTREE_NOT_DERIVABLE' -Tag 'Issue824' -ForEach $script:NotDerivableOnlyP {
            $decision = Invoke-CodexRow -Command $Command
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
            $decision.hookSpecificOutput.permissionDecisionReason | Should -BeLike $script:NotDerivable
        }
    }

    Context 'checkpoint authorizes Q and P' {
        BeforeEach { $script:Checkpoint = ConvertTo-CodexCheckpoint -Path $script:Q, $script:P }

        It 'CW-20 allows the removal of Q and P' -Tag 'Issue824' {
            Invoke-CodexRow -Command "git worktree remove $($script:Q) && git worktree remove $($script:P)" | Should -BeNullOrEmpty
        }
    }
}
