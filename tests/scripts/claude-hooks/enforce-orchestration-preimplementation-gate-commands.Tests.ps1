#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }
<#
.SYNOPSIS
    Unit suite for enforce-orchestration-preimplementation-gate-commands.ps1 (issue #1160).

.DESCRIPTION
    Runs against the .claude/hooks and .codex/hooks copies of the commands sibling through
    Describe -ForEach. Each copy is loaded with the shared command-line parser of its own
    surface (hook-command-scanner.ps1 and hook-command-invocation.ps1), which is the only
    dependency of the sibling. Cases:

      - the mention-host table pin (spec AC-5);
      - a named case for every stage-2 fallback (spec AC-4): Unbalanced, DecodeFailure,
        DepthLimit, an opaque NoPayload shell wrapper, an evaluator command word, rg --pre,
        git -O and --open-files-in-pager, ForEach-Object, find, and a PowerShell expression
        with '::' or '.Invoke';
      - mention cases that clear the hit, and the remaining rule branches.

    Two further Describe blocks load each gate and pin spec AC-3: the stage-2 function is
    invoked only after a stage-1 hit. Those blocks use the issue #737 baseline isolation form.
    Pure string inputs only: no file, process, clock, or environment access.
#>

Describe 'enforce-orchestration-preimplementation-gate-commands.ps1 (<Surface> copy)' -ForEach @(
    @{ Surface = 'Claude'; Directory = '.claude/hooks' }
    @{ Surface = 'Codex'; Directory = '.codex/hooks' }
) {
    BeforeAll {
        $hookDirectory = Join-Path (Resolve-Path "$PSScriptRoot/../../..").Path $Directory
        . (Join-Path $hookDirectory 'hook-command-scanner.ps1')
        . (Join-Path $hookDirectory 'hook-command-invocation.ps1')
        . (Join-Path $hookDirectory 'enforce-orchestration-preimplementation-gate-commands.ps1')
    }

    Context 'mention-host table (spec AC-5)' {
        It 'returns exactly the decision D2 groups' {
            $table = Get-OrchestrationGateMentionHostTable

            @($table.Keys) | Should -Be @('Search', 'Process', 'Output', 'ReadAndFilter', 'Lookup', 'Subcommand', 'ExecutingOption', 'NotHost')
            $table.Search | Should -Be @('grep', 'egrep', 'fgrep', 'rg', 'ag', 'ack', 'findstr', 'Select-String', 'sls')
            $table.Process | Should -Be @('ps', 'pgrep', 'pidof', 'pkill', 'kill', 'killall', 'tasklist', 'taskkill', 'Get-Process', 'gps', 'Stop-Process', 'Get-CimInstance', 'gcim', 'Get-WmiObject')
            $table.Output | Should -Be @('echo', 'printf', 'Write-Output', 'Write-Host', 'Write-Verbose')
            $table.ReadAndFilter | Should -Be @('cat', 'Get-Content', 'head', 'tail', 'less', 'more', 'wc', 'sort', 'uniq', 'Where-Object', 'Select-Object', 'Sort-Object', 'Measure-Object', 'Format-Table', 'Format-List', 'Out-String', 'Get-ChildItem', 'Test-Path')
            $table.Lookup | Should -Be @('which', 'where', 'where.exe', 'type', 'Get-Command', 'gcm')
            $table.NotHost | Should -Be @('ForEach-Object', 'find')
        }

        It 'returns exactly the decision D2 subcommand sets' {
            $table = Get-OrchestrationGateMentionHostTable

            @($table.Subcommand.Keys) | Should -Be @('git', 'npm', 'pip', 'pip3', 'poetry')
            $table.Subcommand.git | Should -Be @('grep', 'log', 'show', 'diff', 'blame', 'ls-files', 'status')
            $table.Subcommand.npm | Should -Be @('ls', 'list', 'view', 'info', 'show', 'outdated', 'explain', 'why', 'search', 'help')
            $table.Subcommand.pip | Should -Be @('show', 'list', 'freeze')
            $table.Subcommand.pip3 | Should -Be @('show', 'list', 'freeze')
            $table.Subcommand.poetry | Should -Be @('show', 'search')
        }

        It 'returns exactly the decision D2 executing-option exclusions' {
            $table = Get-OrchestrationGateMentionHostTable

            @($table.ExecutingOption.Keys) | Should -Be @('rg', 'git')
            $table.ExecutingOption.rg | Should -Be @('--pre')
            $table.ExecutingOption.git | Should -Be @('-O', '--open-files-in-pager')
        }

        It 'returns a new table on every call' {
            $first = Get-OrchestrationGateMentionHostTable
            $first.Search = @('changed')

            (Get-OrchestrationGateMentionHostTable).Search[0] | Should -Be 'grep'
        }
    }

    Context 'stage-2 fallbacks confirm the hit (spec AC-4)' {
        It 'confirms an Unbalanced record' {
            Test-OrchestrationGateInvocationConfirmed -CommandText 'echo "pytest' -PatternIndex 1 | Should -BeTrue
        }

        It 'confirms an Opaque DecodeFailure record' {
            Test-OrchestrationGateInvocationConfirmed -CommandText 'pwsh -EncodedCommand !!notbase64!! Invoke-Pester' -PatternIndex 4 | Should -BeTrue
        }

        It 'confirms an Opaque DepthLimit record' {
            Test-OrchestrationGateInvocationConfirmed -CommandText 'eval eval eval eval eval grep pytest' -PatternIndex 1 | Should -BeTrue
        }

        It 'confirms an opaque NoPayload shell wrapper reading stdin' {
            Test-OrchestrationGateInvocationConfirmed -CommandText 'echo pytest | bash' -PatternIndex 1 | Should -BeTrue
        }

        It 'confirms an opaque NoPayload shell wrapper fed a heredoc' {
            Test-OrchestrationGateInvocationConfirmed -CommandText "bash <<'EOF'`npytest`nEOF" -PatternIndex 1 | Should -BeTrue
        }

        It 'confirms an opaque NoPayload pwsh -File wrapper' {
            Test-OrchestrationGateInvocationConfirmed -CommandText 'pwsh -NoProfile -File tests/scripts/run.ps1' -PatternIndex 4 | Should -BeTrue
        }

        It 'confirms a PowerShell evaluator command word' {
            Test-OrchestrationGateInvocationConfirmed -CommandText 'pwsh -c "Invoke-Expression ''Invoke-Pester''"' -PatternIndex 4 | Should -BeTrue
        }

        It 'confirms a POSIX evaluator command word' {
            Test-OrchestrationGateInvocationConfirmed -CommandText 'source run.sh; grep pytest x' -PatternIndex 1 | Should -BeTrue
        }

        It 'confirms rg with a --pre token' {
            Test-OrchestrationGateInvocationConfirmed -CommandText 'rg --pre pytest x' -PatternIndex 1 | Should -BeTrue
        }

        It 'confirms git with -O' {
            Test-OrchestrationGateInvocationConfirmed -CommandText 'git grep -O vim pytest' -PatternIndex 1 | Should -BeTrue
        }

        It 'confirms git with --open-files-in-pager' {
            Test-OrchestrationGateInvocationConfirmed -CommandText 'git grep --open-files-in-pager=vim pytest' -PatternIndex 1 | Should -BeTrue
        }

        It 'confirms ForEach-Object, which is not a host' {
            Test-OrchestrationGateInvocationConfirmed -CommandText 'pwsh -c "Get-ChildItem | ForEach-Object { ''Invoke-Pester'' }"' -PatternIndex 4 | Should -BeTrue
        }

        It 'confirms find, which is not a host' {
            Test-OrchestrationGateInvocationConfirmed -CommandText 'find . -name x -exec pytest {} ;' -PatternIndex 1 | Should -BeTrue
        }

        It 'confirms a PowerShell expression containing ::' {
            Test-OrchestrationGateInvocationConfirmed -CommandText 'pwsh -c "[Diagnostics.Process]::Start(''tests/scripts/run.ps1'')"' -PatternIndex 4 | Should -BeTrue
        }

        It 'confirms a PowerShell expression containing .Invoke' {
            Test-OrchestrationGateInvocationConfirmed -CommandText 'pwsh -c "{ ''Invoke-Pester'' }.Invoke()"' -PatternIndex 4 | Should -BeTrue
        }
    }

    Context 'other rule branches' {
        It 'clears a governed word that only a search host carries' {
            Test-OrchestrationGateInvocationConfirmed -CommandText 'ps aux | grep pytest' -PatternIndex 1 | Should -BeFalse
        }

        It 'clears a staging mention carried by an output host' {
            Test-OrchestrationGateInvocationConfirmed -CommandText 'echo git add docs' -PatternIndex 0 | Should -BeFalse
        }

        It 'clears a subcommand-scoped host' {
            Test-OrchestrationGateInvocationConfirmed -CommandText 'npm ls prettier' -PatternIndex 2 | Should -BeFalse
        }

        It 'clears a PowerShell expression without :: or .Invoke' {
            Test-OrchestrationGateInvocationConfirmed -CommandText 'pwsh -NoProfile -Command "Get-Process | Where-Object { $_.CommandLine -match ''Invoke-Pester'' }"' -PatternIndex 4 | Should -BeFalse
        }

        It 'clears a wrapper whose payload carries the word only under a host' {
            Test-OrchestrationGateInvocationConfirmed -CommandText 'sh -c "ps aux | grep pytest"' -PatternIndex 1 | Should -BeFalse
        }

        It 'clears a Windows executable host name through its leaf' {
            Test-OrchestrationGateInvocationConfirmed -CommandText 'where.exe pytest' -PatternIndex 1 | Should -BeFalse
        }

        It 'confirms a subcommand outside the host set' {
            Test-OrchestrationGateInvocationConfirmed -CommandText 'npm install prettier' -PatternIndex 2 | Should -BeTrue
        }

        It 'confirms a governed word in command position' {
            Test-OrchestrationGateInvocationConfirmed -CommandText 'pytest | tee out.txt' -PatternIndex 1 | Should -BeTrue
        }

        It 'confirms a wrapper whose payload never carries the word' {
            Test-OrchestrationGateInvocationConfirmed -CommandText "bash -c 'echo hi' pytest" -PatternIndex 1 | Should -BeTrue
        }

        It 'confirms when no record carries the governed word as a whole token' {
            Test-OrchestrationGateInvocationConfirmed -CommandText 'pip show pytest-xdist' -PatternIndex 1 | Should -BeTrue
        }

        It 'confirms empty text, which yields no record' {
            Test-OrchestrationGateInvocationConfirmed -CommandText '' -PatternIndex 1 | Should -BeTrue
        }

        It 'confirms the command word after a transparent wrapper' {
            Test-OrchestrationGateInvocationConfirmed -CommandText 'timeout 60 pytest' -PatternIndex 1 | Should -BeTrue
        }

        It 'rejects a pattern index outside the five stage-1 patterns' {
            { Test-OrchestrationGateInvocationConfirmed -CommandText 'pytest' -PatternIndex 5 } | Should -Throw
        }
    }
}

Describe 'Claude gate invokes stage 2 only after a stage-1 hit (spec AC-3)' {
    BeforeAll {
        . (Resolve-Path "$PSScriptRoot/../../../.claude/hooks/enforce-orchestration-preimplementation-gate.ps1").Path
        . (Resolve-Path "$PSScriptRoot/../../../.claude/hooks/enforce-orchestration-preimplementation-gate-commands.ps1").Path
        . (Join-Path $PSScriptRoot 'EpicStateIsolation.Baseline.Helpers.ps1')
        if (Get-Command Get-WorktreeResolutionGitFileText -ErrorAction SilentlyContinue) { Mock Get-WorktreeResolutionGitFileText { $null } }
        Register-EpicStateBaselineMock -Seam 'Get-WorktreeItemCheckpointText', 'Get-WorktreeItemLiveRoot', 'Get-EpicScopeCheckpointText' -Surface 'Claude'
        Register-EpicStateBaselineMock -Seam 'Get-CheckpointContent', 'Get-EpicCheckpointContent', 'Get-ParallelCheckpointContent' -Surface 'Codex'
        Import-Module (Resolve-Path "$PSScriptRoot/../../../.claude/lib/worktree-resolution/EpicScopeResolution.psm1").Path
        Mock Get-EpicScopeCheckpointText -ModuleName EpicScopeResolution { $null }
        Import-Module (Resolve-Path "$PSScriptRoot/../../../.claude/lib/worktree-resolution/WorktreeRunResolution.psm1").Path
        Mock Get-WorktreeRunCheckpointText -ModuleName WorktreeRunResolution { $null }
        Mock Get-WorktreeItemLiveRoot -ModuleName WorktreeRunResolution { , [string[]] @() }
    }

    It 'baseline mock interception probe' { Invoke-EpicStateInterceptionProbe -Surface 'Claude' -Seam 'Get-EpicScopeCheckpointText', 'Get-WorktreeItemCheckpointText', 'Get-WorktreeItemLiveRoot', 'Get-WorktreeRunCheckpointText' }

    It 'does not call stage 2 for a stage-1 miss' {
        Mock Test-OrchestrationGateInvocationConfirmed { $true }

        Test-ImplementationCommand -Command 'npm test' | Should -BeFalse
        Should -Invoke Test-OrchestrationGateInvocationConfirmed -Times 0 -Exactly
    }

    It 'calls stage 2 for a regex-only stage-1 hit' {
        Mock Test-OrchestrationGateInvocationConfirmed { $false }

        Test-ImplementationCommand -Command 'ps aux | grep pytest' | Should -BeFalse
        Should -Invoke Test-OrchestrationGateInvocationConfirmed -Times 1 -Exactly -ParameterFilter { $PatternIndex -eq 1 }
    }

    It 'does not call stage 2 for structural staging' {
        Mock Test-OrchestrationGateInvocationConfirmed { $false }

        Test-ImplementationCommand -Command 'git add src/app.ps1' | Should -BeTrue
        Should -Invoke Test-OrchestrationGateInvocationConfirmed -Times 0 -Exactly
    }
}

Describe 'Codex gate invokes stage 2 only after a stage-1 hit (spec AC-3)' {
    BeforeAll {
        $codexRoot = (Resolve-Path "$PSScriptRoot/../../..").Path
        . (Join-Path $codexRoot '.codex/hooks/enforce-orchestration-preimplementation-gate.ps1')
        . (Join-Path $codexRoot '.codex/hooks/enforce-orchestration-preimplementation-gate-commands.ps1')
        . (Join-Path $PSScriptRoot 'EpicStateIsolation.Baseline.Helpers.ps1')
        Register-EpicStateBaselineMock -Seam 'Get-EpicScopeCheckpointText', 'Get-WorktreeItemCheckpointText', 'Get-WorktreeItemLiveRoot', 'Get-WorktreeRunCheckpointText' -Surface 'Claude'
        Register-EpicStateBaselineMock -Seam 'Get-CheckpointContent', 'Get-EpicCheckpointContent', 'Get-ParallelCheckpointContent', 'Get-WorktreeResolutionGitFileText' -Surface 'Codex'
        Mock Get-EpicScopeCheckpointText { $null }
    }

    It 'baseline mock interception probe' { Invoke-EpicStateInterceptionProbe -Surface 'Codex' -Seam 'Get-EpicScopeCheckpointText' }

    It 'does not call stage 2 for a stage-1 miss' {
        Mock Test-OrchestrationGateInvocationConfirmed { $true }

        Test-ImplementationCommand -Command 'npm test' | Should -BeFalse
        Should -Invoke Test-OrchestrationGateInvocationConfirmed -Times 0 -Exactly
    }

    It 'calls stage 2 for a regex-only stage-1 hit' {
        Mock Test-OrchestrationGateInvocationConfirmed { $false }

        Test-ImplementationCommand -Command 'ps aux | grep pytest' | Should -BeFalse
        Should -Invoke Test-OrchestrationGateInvocationConfirmed -Times 1 -Exactly -ParameterFilter { $PatternIndex -eq 1 }
    }

    It 'does not call stage 2 for structural staging' {
        Mock Test-OrchestrationGateInvocationConfirmed { $false }

        Test-ImplementationCommand -Command 'git add src/app.ps1' | Should -BeTrue
        Should -Invoke Test-OrchestrationGateInvocationConfirmed -Times 0 -Exactly
    }
}
