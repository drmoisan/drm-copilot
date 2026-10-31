#Requires -Version 7.0
<#
.SYNOPSIS
    Pester tests for target-worktree resolution in the enforce-powershell-batch-budget.ps1 Claude Code hook (issue #1009).

.DESCRIPTION
    The hook resolves the worktree that holds the edited file and evaluates the batch
    budget against that worktree: its checkpoint selects the route, and its counter is
    kept in a worktree-keyed state file under the session root. The session root is
    /repo; /repo/.claude/worktrees/item and /repo-wt/sibling are registered linked
    worktrees supplied as in-memory porcelain text through an injected invoker. Every
    checkpoint and state operation runs through in-memory seams, so no test runs git,
    creates a file, or reads gitignored state. Seams compare received paths after
    replacing backslashes with forward slashes, because Join-Path on Windows inserts a
    backslash after a slash-rooted synthetic root.
#>

Set-StrictMode -Version Latest

Describe 'enforce-powershell-batch-budget.ps1 target-worktree resolution (issue #1009)' {
    BeforeAll {
        $script:HookPath = (Resolve-Path (Join-Path -Path $PSScriptRoot -ChildPath '..' -AdditionalChildPath '..', '..', '.claude', 'hooks', 'enforce-powershell-batch-budget.ps1')).Path
        . $script:HookPath

        $script:HookFunction = 'Invoke-PowerShellBatchBudgetHook'
        $script:DenyCode = 'POWERSHELL_LARGE_PATH_REQUIRED'
        $script:StatePrefix = '/repo/.claude/state/powershell-batch-budget.'
        $script:ItemCheckpointPath = '/repo/.claude/worktrees/item/artifacts/orchestration/orchestrator-state.json'
        $script:Porcelain = @(
            'worktree /repo', 'HEAD 1111111111111111111111111111111111111111', 'branch refs/heads/main', '',
            'worktree /repo/.claude/worktrees/item', 'HEAD 2222222222222222222222222222222222222222', 'branch refs/heads/bug/item', '',
            'worktree /repo-wt/sibling', 'HEAD 3333333333333333333333333333333333333333', 'branch refs/heads/bug/sibling', ''
        ) -join "`n"

        function ConvertTo-TargetCheckpointJson {
            param([string] $Route = 'large', [string] $NextStep = 'S5_atomic_execution', [string[]] $Completed = @())
            return ([ordered]@{ route_id = $Route; next_step = $NextStep; completed_steps = @($Completed) } | ConvertTo-Json -Compress)
        }

        function Initialize-TargetStore {
            $script:Store = @{
                Checkpoints     = @{}
                CheckpointReads = [System.Collections.Generic.List[string]]::new()
                States          = @{}
                Writes          = [System.Collections.Generic.List[string]]::new()
                Probes          = [System.Collections.Generic.List[string]]::new()
                InvokerCalls    = 0
            }
        }

        function Get-TargetSeam {
            return @{
                ReadCheckpoint  = {
                    param([string] $Path)
                    $slash = $Path -replace '\\', '/'
                    $script:Store.CheckpointReads.Add($slash)
                    if ($script:Store.Checkpoints.ContainsKey($slash)) { return $script:Store.Checkpoints[$slash] }
                    return ''
                }
                TestPathExists  = {
                    param([string] $Path)
                    $slash = $Path -replace '\\', '/'
                    $script:Store.Probes.Add($slash)
                    return $script:Store.States.ContainsKey($slash)
                }
                EnsureDirectory = { param([string] $Path) [void] $Path }
                ReadState       = { param([string] $Path) return $script:Store.States[($Path -replace '\\', '/')] }
                WriteState      = {
                    param([string] $Path, [System.Collections.IDictionary] $State)
                    $slash = $Path -replace '\\', '/'
                    $script:Store.Writes.Add($slash)
                    $script:Store.States[$slash] = ($State | ConvertTo-Json -Compress -Depth 5)
                }
            }
        }

        function Get-TargetInvoker {
            return {
                param($SessionRoot)
                [void] $SessionRoot
                $script:Store.InvokerCalls++
                return $script:Porcelain
            }
        }

        function Invoke-TargetHook {
            param([Parameter(Mandatory)][string] $FilePath, [string] $SessionId = 'r1', [hashtable] $Extra = @{})
            $toolInput = [ordered]@{ tool_name = 'Write'; tool_input = [ordered]@{ file_path = $FilePath; content = 'body' } } | ConvertTo-Json -Compress -Depth 5
            $seams = Get-TargetSeam
            return (& $script:HookFunction -ToolInputRaw $toolInput -SessionId $SessionId -Root '/repo' @seams @Extra)
        }
    }

    BeforeEach {
        Initialize-TargetStore
    }

    Context 'regression (issue #1009)' {
        It 'R1 item worktree checkpoint large leaves the item uncapped' {
            $PSDefaultParameterValues = @{ "$($script:HookFunction):WorktreeListInvoker" = { Get-TargetInvoker } }
            $script:Store.Checkpoints[$script:ItemCheckpointPath] = ConvertTo-TargetCheckpointJson -Route 'large'

            $decisions = foreach ($leaf in @('a', 'b', 'c', 'd')) {
                Invoke-TargetHook -FilePath "/repo/.claude/worktrees/item/src/$leaf.ps1"
            }

            $denials = @($decisions | Where-Object { $_.hookSpecificOutput.permissionDecision -eq 'deny' } | ForEach-Object { $_.hookSpecificOutput.permissionDecisionReason })
            $denials | Should -BeNullOrEmpty -Because 'the item worktree checkpoint selects large, so its fourth production path is uncapped'
        }

        It 'R2 two worktrees fill independent counters' {
            $PSDefaultParameterValues = @{ "$($script:HookFunction):WorktreeListInvoker" = { Get-TargetInvoker } }
            foreach ($leaf in @('a', 'b', 'c')) {
                $null = Invoke-TargetHook -FilePath "/repo/src/$leaf.ps1" -SessionId 'r2'
            }

            $decision = Invoke-TargetHook -FilePath '/repo/.claude/worktrees/item/src/d.ps1' -SessionId 'r2'

            $decision.hookSpecificOutput.permissionDecision | Should -Be 'allow' -Because "the item worktree has its own counter; reason: $($decision.hookSpecificOutput['permissionDecisionReason'])"
            $script:Store.Writes[-1] | Should -Match ('^' + [regex]::Escape($script:StatePrefix + 'r2.') + 'item-[0-9a-f]{8}\.json$')
        }

        It 'R3 root-level artifacts scratch is not counted' {
            $PSDefaultParameterValues = @{ "$($script:HookFunction):WorktreeListInvoker" = { Get-TargetInvoker } }
            foreach ($leaf in @('a', 'b', 'c')) {
                $null = Invoke-TargetHook -FilePath "/repo/src/$leaf.ps1" -SessionId 'r3'
            }
            $writesBefore = $script:Store.Writes.Count

            $relative = Invoke-TargetHook -FilePath 'artifacts/scratch/issue-1009-x.ps1' -SessionId 'r3'
            $absolute = Invoke-TargetHook -FilePath '/repo/artifacts/scratch/issue-1009-x.ps1' -SessionId 'r3'

            $relative.hookSpecificOutput.permissionDecision | Should -Be 'allow' -Because "a relative artifacts/ path is never counted; reason: $($relative.hookSpecificOutput['permissionDecisionReason'])"
            $absolute.hookSpecificOutput.permissionDecision | Should -Be 'allow' -Because "an absolute root-level artifacts/ path is never counted; reason: $($absolute.hookSpecificOutput['permissionDecisionReason'])"
            $script:Store.Writes.Count | Should -Be $writesBefore -Because 'an artifacts/ path consumes no slot and writes no state'
        }
    }

    Context 'target-worktree evaluation with an explicit invoker' {
        BeforeEach {
            $script:Invoker = @{ WorktreeListInvoker = (Get-TargetInvoker) }
            $script:Leaves = @('a.ps1', 'b.psm1', 'c.psd1', 'd.ps1')
        }

        It 'leaves the item uncapped when its checkpoint selects <_>' -ForEach @('remediation', 'preparation') {
            $script:Store.Checkpoints[$script:ItemCheckpointPath] = ConvertTo-TargetCheckpointJson -Route $_

            $decisions = foreach ($leaf in $script:Leaves) {
                Invoke-TargetHook -FilePath "/repo/.claude/worktrees/item/src/$leaf" -Extra $script:Invoker
            }

            @($decisions | Where-Object { $_.hookSpecificOutput.permissionDecision -eq 'deny' }).Count | Should -Be 0
            @($script:Store.CheckpointReads | Where-Object { $_ -ne $script:ItemCheckpointPath }).Count | Should -Be 0 -Because 'every checkpoint read is under the item worktree root'
            $script:Store.CheckpointReads.Count | Should -Be 4
            $script:Store.Writes.Count | Should -Be 0
        }

        It 'caps the item on the fourth path when <Case>' -ForEach @(
            @{ Case = 'the item has no checkpoint'; Checkpoint = '' }
            @{ Case = 'the item checkpoint is terminal by next_step'; Checkpoint = '{"route_id":"large","next_step":"complete"}' }
            @{ Case = 'the item checkpoint is terminal by S12_complete'; Checkpoint = '{"route_id":"large","next_step":"S9","completed_steps":["S12_complete"]}' }
            @{ Case = 'the item checkpoint selects a non-large route'; Checkpoint = '{"route_id":"small","next_step":"S5"}' }
        ) {
            if ($Checkpoint) { $script:Store.Checkpoints[$script:ItemCheckpointPath] = $Checkpoint }

            $decisions = @(foreach ($leaf in $script:Leaves) {
                    Invoke-TargetHook -FilePath "/repo/.claude/worktrees/item/src/$leaf" -Extra $script:Invoker
                })

            @($decisions[0..2] | Where-Object { $_.hookSpecificOutput.permissionDecision -eq 'deny' }).Count | Should -Be 0
            $decisions[3].hookSpecificOutput.permissionDecision | Should -Be 'deny'
            $decisions[3].hookSpecificOutput.permissionDecisionReason | Should -BeLike "$($script:DenyCode): this change touches more than 3 production PowerShell files*Route the change through /orchestrate.*"
        }

        It 'keeps the unkeyed state-file name for a session-root file' {
            $null = Invoke-TargetHook -FilePath '/repo/src/a.psm1' -SessionId 's1' -Extra $script:Invoker

            @($script:Store.Writes) | Should -Be @($script:StatePrefix + 's1.json')
        }

        It 'writes every state file under the session root state directory' {
            foreach ($path in @('/repo/src/a.ps1', '/repo/.claude/worktrees/item/src/b.psm1', '/repo-wt/sibling/c.psd1', 'src/d.ps1')) {
                $null = Invoke-TargetHook -FilePath $path -SessionId 's2' -Extra $script:Invoker
            }

            $script:Store.Writes.Count | Should -Be 4
            @($script:Store.Writes | Where-Object { -not $_.StartsWith('/repo/.claude/state/') }).Count | Should -Be 0
        }

        It 'still counts a production file under a nested directory named artifacts' {
            foreach ($leaf in @('a.ps1', 'b.psm1', 'c.psd1')) {
                $null = Invoke-TargetHook -FilePath "/repo/src/$leaf" -Extra $script:Invoker
            }

            $decision = Invoke-TargetHook -FilePath '/repo/src/artifacts/x.ps1' -Extra $script:Invoker

            $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
        }

        It 'does not count root-level artifacts .psm1 and .psd1 paths' {
            foreach ($path in @('/repo/.claude/worktrees/item/artifacts/scratch/m.psm1', 'artifacts/scratch/d.psd1')) {
                $decision = Invoke-TargetHook -FilePath $path -Extra $script:Invoker
                $decision.hookSpecificOutput.permissionDecision | Should -Be 'allow'
            }

            $script:Store.Writes.Count | Should -Be 0
            $script:Store.CheckpointReads.Count | Should -Be 0
        }

        It 'discards a path outside every worktree with the session-root checkpoint and state name' {
            $decision = Invoke-TargetHook -FilePath '/elsewhere/src/a.ps1' -SessionId 's3' -Extra $script:Invoker

            $decision.hookSpecificOutput.permissionDecision | Should -Be 'allow'
            @($script:Store.CheckpointReads) | Should -Be @('/repo/artifacts/orchestration/orchestrator-state.json')
            $script:Store.Probes | Should -Contain ($script:StatePrefix + 's3.json')
            $script:Store.Writes.Count | Should -Be 0
        }

        It 'counts a sibling worktree against its own keyed budget' {
            foreach ($leaf in @('a.ps1', 'b.ps1', 'c.ps1')) {
                $null = Invoke-TargetHook -FilePath "/repo/src/$leaf" -SessionId 's4' -Extra $script:Invoker
            }
            $decisions = @(foreach ($leaf in $script:Leaves) {
                    Invoke-TargetHook -FilePath "/repo-wt/sibling/src/$leaf" -SessionId 's4' -Extra $script:Invoker
                })

            @($decisions[0..2] | Where-Object { $_.hookSpecificOutput.permissionDecision -eq 'deny' }).Count | Should -Be 0
            $decisions[3].hookSpecificOutput.permissionDecision | Should -Be 'deny' -Because 'the sibling worktree has its own cap of three production files'
            $script:Store.Writes[-1] | Should -Match ('^' + [regex]::Escape($script:StatePrefix + 's4.') + 'sibling-[0-9a-f]{8}\.json$')
        }

        It 'makes no invoker, checkpoint, or state call for <Case>' -ForEach @(
            @{ Case = 'a missing file_path'; ToolInput = '{"tool_name":"Write","tool_input":{"content":"body"}}' }
            @{ Case = 'a non-PowerShell path'; ToolInput = '{"tool_name":"Write","tool_input":{"file_path":"/repo/.claude/worktrees/item/src/a.ts","content":"body"}}' }
        ) {
            $seams = Get-TargetSeam
            $invoker = $script:Invoker
            $decision = & $script:HookFunction -ToolInputRaw $ToolInput -SessionId 's5' -Root '/repo' @seams @invoker

            $decision.hookSpecificOutput.permissionDecision | Should -Be 'allow'
            $script:Store.InvokerCalls | Should -Be 0
            $script:Store.CheckpointReads.Count | Should -Be 0
            $script:Store.Probes.Count | Should -Be 0
            $script:Store.Writes.Count | Should -Be 0
        }

        It 'denies an in-scope absolute path before any invoker, checkpoint, or state call when the route helper failed to load' {
            try {
                $script:PowerShellBatchBudgetRouteImportFailure = 'enforce-batch-budget-route.ps1'
                $decision = Invoke-TargetHook -FilePath '/repo/.claude/worktrees/item/src/a.psm1' -Extra $script:Invoker
            } finally {
                $script:PowerShellBatchBudgetRouteImportFailure = $null
            }

            $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
            $decision.hookSpecificOutput.permissionDecisionReason | Should -BeLike "$($script:DenyCode): the route helper 'enforce-batch-budget-route.ps1' failed to load*"
            $script:Store.InvokerCalls | Should -Be 0
            $script:Store.CheckpointReads.Count | Should -Be 0
            $script:Store.Probes.Count | Should -Be 0
            $script:Store.Writes.Count | Should -Be 0
        }

        It 'falls back to the session root when the resolver returns <Case>' -ForEach @(
            @{ Case = 'an ambiguous result'; Ambiguous = $true; Code = 'TARGET_WORKTREE_AMBIGUOUS' }
            @{ Case = 'a null root'; Ambiguous = $false; Code = 'TARGET_WORKTREE_NOT_DERIVABLE' }
        ) {
            $script:MockResult = [pscustomobject]@{ WorktreeRoot = $null; Source = 'FilePath'; Ambiguous = $Ambiguous; ReasonCode = $Code; Detail = 'mocked'; Candidates = [string[]] @() }
            Mock Resolve-HookTargetWorktree { $script:MockResult }
            $script:Store.Checkpoints[$script:ItemCheckpointPath] = ConvertTo-TargetCheckpointJson -Route 'large'

            $null = Invoke-TargetHook -FilePath '/repo/.claude/worktrees/item/src/a.psd1' -SessionId 's6' -Extra $script:Invoker

            @($script:Store.CheckpointReads) | Should -Be @('/repo/artifacts/orchestration/orchestrator-state.json')
            @($script:Store.Writes) | Should -Be @($script:StatePrefix + 's6.json')
        }

        It 'drops persisted entries outside the resolved root on rehydrate' {
            $itemState = $script:StatePrefix + 's7.' + (Get-HookTargetWorktreeKey -WorktreeRoot '/repo/.claude/worktrees/item') + '.json'
            $script:Store.States[$itemState] = '{"prodCap":3,"prodFiles":["/repo/src/x.ps1","/repo/src/y.ps1","/repo/src/z.ps1"]}'

            $decision = Invoke-TargetHook -FilePath '/repo/.claude/worktrees/item/src/a.ps1' -SessionId 's7' -Extra $script:Invoker

            $decision.hookSpecificOutput.permissionDecision | Should -Be 'allow'
            @(($script:Store.States[$itemState] | ConvertFrom-Json).prodFiles) | Should -Be @('/repo/.claude/worktrees/item/src/a.ps1')
        }
    }
}
