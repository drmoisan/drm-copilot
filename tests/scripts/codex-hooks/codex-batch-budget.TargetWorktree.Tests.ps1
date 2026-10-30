#Requires -Version 7.0
<#
.SYNOPSIS
    Pester tests for target-worktree resolution in the two Codex batch-budget hooks (issue #1009).

.DESCRIPTION
    Covers .codex/hooks/enforce-python-batch-budget.ps1 and
    .codex/hooks/enforce-powershell-batch-budget.ps1 through one Context-level -ForEach.
    Each hook resolves the worktree that holds the edited file and evaluates the batch
    budget against that worktree: its checkpoint selects the route, and its counter is
    kept in a worktree-keyed state file under the session root .codex/state/. The
    session root is /repo; /repo/.claude/worktrees/item and /repo-wt/sibling are
    registered linked worktrees supplied as in-memory porcelain text through an
    injected invoker. Every checkpoint and state operation runs through in-memory
    seams, so no test runs git, creates a file, or reads gitignored state. Seams
    compare received paths after replacing backslashes with forward slashes.
#>

Set-StrictMode -Version Latest

Describe 'Codex batch-budget hooks target-worktree resolution (issue #1009)' {
    BeforeAll {
        $script:HookRoot = (Resolve-Path (Join-Path $PSScriptRoot '../../../.codex/hooks')).Path
        . (Join-Path $script:HookRoot 'enforce-python-batch-budget.ps1')
        . (Join-Path $script:HookRoot 'enforce-powershell-batch-budget.ps1')

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
                TestPathExists  = { param([string] $Path) return $script:Store.States.ContainsKey(($Path -replace '\\', '/')) }
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
            param([Parameter(Mandatory)][string] $HookFunction, [Parameter(Mandatory)][string] $FilePath, [string] $SessionId = 'r1', [hashtable] $Extra = @{})
            $toolInput = @{ file_path = $FilePath } | ConvertTo-Json -Compress
            $seams = Get-TargetSeam
            return (& $HookFunction -ToolInputRaw $toolInput -SessionId $SessionId -Root '/repo' @seams @Extra)
        }
    }

    BeforeEach {
        Initialize-TargetStore
    }

    Context 'the <Language> hook' -ForEach @(
        @{ Language = 'Python'; HookFunction = 'Invoke-PythonBatchBudgetHook'; EntryPoint = 'Invoke-PythonBatchBudgetCodexEntryPoint'; Ext = 'py'; DenyCode = 'PYTHON_LARGE_PATH_REQUIRED'; StatePrefix = '/repo/.codex/state/python-batch-budget.' }
        @{ Language = 'PowerShell'; HookFunction = 'Invoke-PowerShellBatchBudgetHook'; EntryPoint = 'Invoke-PowerShellBatchBudgetCodexEntryPoint'; Ext = 'ps1'; DenyCode = 'POWERSHELL_LARGE_PATH_REQUIRED'; StatePrefix = '/repo/.codex/state/powershell-batch-budget.' }
    ) {
        Context 'regression (issue #1009)' {
            It 'R1 item worktree checkpoint large leaves the item uncapped' {
                $PSDefaultParameterValues = @{ "$($HookFunction):WorktreeListInvoker" = { Get-TargetInvoker } }
                $script:Store.Checkpoints[$script:ItemCheckpointPath] = ConvertTo-TargetCheckpointJson -Route 'large'

                $decisions = foreach ($leaf in @('a', 'b', 'c', 'd')) {
                    Invoke-TargetHook -HookFunction $HookFunction -FilePath "/repo/.claude/worktrees/item/src/$leaf.$Ext"
                }

                $denials = @($decisions | Where-Object { $_.hookSpecificOutput.permissionDecision -eq 'deny' } | ForEach-Object { $_.hookSpecificOutput.permissionDecisionReason })
                $denials | Should -BeNullOrEmpty -Because 'the item worktree checkpoint selects large, so its fourth production path is uncapped'
            }

            It 'R2 two worktrees fill independent counters' {
                $PSDefaultParameterValues = @{ "$($HookFunction):WorktreeListInvoker" = { Get-TargetInvoker } }
                foreach ($leaf in @('a', 'b', 'c')) {
                    $null = Invoke-TargetHook -HookFunction $HookFunction -FilePath "/repo/src/$leaf.$Ext" -SessionId 'r2'
                }

                $decision = Invoke-TargetHook -HookFunction $HookFunction -FilePath "/repo/.claude/worktrees/item/src/d.$Ext" -SessionId 'r2'

                $decision.hookSpecificOutput.permissionDecision | Should -Be 'allow' -Because "the item worktree has its own counter; reason: $($decision.hookSpecificOutput['permissionDecisionReason'])"
                $script:Store.Writes[-1] | Should -Match ('^' + [regex]::Escape($StatePrefix + 'r2.') + 'item-[0-9a-f]{8}\.json$')
            }

            It 'R3 root-level artifacts scratch is not counted' {
                $PSDefaultParameterValues = @{ "$($HookFunction):WorktreeListInvoker" = { Get-TargetInvoker } }
                foreach ($leaf in @('a', 'b', 'c')) {
                    $null = Invoke-TargetHook -HookFunction $HookFunction -FilePath "/repo/src/$leaf.$Ext" -SessionId 'r3'
                }
                $writesBefore = $script:Store.Writes.Count

                $relative = Invoke-TargetHook -HookFunction $HookFunction -FilePath "artifacts/scratch/issue-1009-x.$Ext" -SessionId 'r3'
                $absolute = Invoke-TargetHook -HookFunction $HookFunction -FilePath "/repo/artifacts/scratch/issue-1009-x.$Ext" -SessionId 'r3'

                $relative.hookSpecificOutput.permissionDecision | Should -Be 'allow' -Because "a relative artifacts/ path is never counted; reason: $($relative.hookSpecificOutput['permissionDecisionReason'])"
                $absolute.hookSpecificOutput.permissionDecision | Should -Be 'allow' -Because "an absolute root-level artifacts/ path is never counted; reason: $($absolute.hookSpecificOutput['permissionDecisionReason'])"
                $script:Store.Writes.Count | Should -Be $writesBefore -Because 'an artifacts/ path consumes no slot and writes no state'
            }
        }

        Context 'target-worktree evaluation with an explicit invoker' {
            BeforeEach {
                $script:Invoker = @{ WorktreeListInvoker = (Get-TargetInvoker) }
            }

            It 'leaves the item uncapped when its checkpoint selects remediation' {
                $script:Store.Checkpoints[$script:ItemCheckpointPath] = ConvertTo-TargetCheckpointJson -Route 'remediation'

                $decisions = foreach ($leaf in @('a', 'b', 'c', 'd')) {
                    Invoke-TargetHook -HookFunction $HookFunction -FilePath "/repo/.claude/worktrees/item/src/$leaf.$Ext" -Extra $script:Invoker
                }

                @($decisions | Where-Object { $_.hookSpecificOutput.permissionDecision -eq 'deny' }).Count | Should -Be 0
                @($script:Store.CheckpointReads | Where-Object { $_ -ne $script:ItemCheckpointPath }).Count | Should -Be 0
                $script:Store.Writes.Count | Should -Be 0
            }

            It 'caps an item worktree without a checkpoint on the fourth path' {
                $decisions = @(foreach ($leaf in @('a', 'b', 'c', 'd')) {
                        Invoke-TargetHook -HookFunction $HookFunction -FilePath "/repo/.claude/worktrees/item/src/$leaf.$Ext" -Extra $script:Invoker
                    })

                @($decisions[0..2] | Where-Object { $_.hookSpecificOutput.permissionDecision -eq 'deny' }).Count | Should -Be 0
                $decisions[3].hookSpecificOutput.permissionDecision | Should -Be 'deny'
                $decisions[3].hookSpecificOutput.permissionDecisionReason | Should -BeLike "$($DenyCode): this change touches more than 3 production*Route the change through .codex/prompts/orchestrate-work.md.*"
            }

            It 'fills independent per-worktree counters with keyed state under the session root' {
                $decisions = foreach ($root in @('/repo', '/repo/.claude/worktrees/item')) {
                    foreach ($leaf in @('a', 'b', 'c')) {
                        Invoke-TargetHook -HookFunction $HookFunction -FilePath "$root/src/$leaf.$Ext" -SessionId 'w1' -Extra $script:Invoker
                    }
                }

                @($decisions | Where-Object { $_.hookSpecificOutput.permissionDecision -eq 'deny' }).Count | Should -Be 0
                @($script:Store.Writes | Where-Object { -not $_.StartsWith('/repo/.codex/state/') }).Count | Should -Be 0
                @($script:Store.Writes | Select-Object -Unique) | Should -Be @(($StatePrefix + 'w1.json'), ($StatePrefix + 'w1.' + (Get-HookTargetWorktreeKey -WorktreeRoot '/repo/.claude/worktrees/item') + '.json'))
            }

            It 'does not count a root-level artifacts path in the item worktree' {
                $decision = Invoke-TargetHook -HookFunction $HookFunction -FilePath "/repo/.claude/worktrees/item/artifacts/scratch/x.$Ext" -Extra $script:Invoker

                $decision.hookSpecificOutput.permissionDecision | Should -Be 'allow'
                $script:Store.Writes.Count | Should -Be 0
                $script:Store.CheckpointReads.Count | Should -Be 0
            }

            It 'keeps the unchanged state-file name for a session-root file' {
                $null = Invoke-TargetHook -HookFunction $HookFunction -FilePath "/repo/src/a.$Ext" -SessionId 's1' -Extra $script:Invoker

                @($script:Store.Writes) | Should -Be @($StatePrefix + 's1.json')
            }

            It 'counts a path outside every registered worktree against the session root as today' {
                $decisions = @(foreach ($leaf in @('a', 'b', 'c', 'd')) {
                        Invoke-TargetHook -HookFunction $HookFunction -FilePath "/elsewhere/src/$leaf.$Ext" -SessionId 'o1' -Extra $script:Invoker
                    })

                @($decisions[0..2] | Where-Object { $_.hookSpecificOutput.permissionDecision -eq 'deny' }).Count | Should -Be 0
                $decisions[3].hookSpecificOutput.permissionDecision | Should -Be 'deny' -Because 'Codex adds no containment filter'
                @($script:Store.CheckpointReads | Select-Object -Unique) | Should -Be @('/repo/artifacts/orchestration/orchestrator-state.json')
                @($script:Store.Writes | Select-Object -Unique) | Should -Be @($StatePrefix + 'o1.json')
            }

            It 'evaluates each side of an apply_patch move against its own worktree' {
                $script:Store.Checkpoints[$script:ItemCheckpointPath] = ConvertTo-TargetCheckpointJson -Route 'large'
                $siblingKey = Get-HookTargetWorktreeKey -WorktreeRoot '/repo-wt/sibling'
                $siblingState = $StatePrefix + 'move.' + $siblingKey + '.json'
                $script:Store.States[$siblingState] = (@{ prodCap = 3; prodFiles = @("/repo-wt/sibling/src/a.$Ext", "/repo-wt/sibling/src/b.$Ext", "/repo-wt/sibling/src/c.$Ext") } | ConvertTo-Json -Compress)
                $patch = "*** Begin Patch`n*** Update File: /repo/.claude/worktrees/item/src/old.$Ext`n*** Move to: /repo-wt/sibling/src/new.$Ext`n@@`n-old`n+new`n*** End Patch"
                $payload = [ordered]@{ session_id = 'move'; hook_event_name = 'PreToolUse'; tool_name = 'apply_patch'; tool_input = @{ command = $patch } } | ConvertTo-Json -Compress -Depth 10
                $seams = (Get-TargetSeam) + $script:Invoker

                $result = @(& $EntryPoint -PayloadRaw $payload -RepositoryRoot '/repo' -HookSeams $seams)

                $result[-1] | Should -Be 0
                $result.Count | Should -Be 2 -Because 'the destination side is denied by its own worktree budget'
                ($result[0] | ConvertFrom-Json).hookSpecificOutput.permissionDecisionReason | Should -BeLike "*requested: /repo-wt/sibling/src/new.$Ext*"
                $script:Store.CheckpointReads | Should -Contain $script:ItemCheckpointPath
                $script:Store.CheckpointReads | Should -Contain '/repo-wt/sibling/artifacts/orchestration/orchestrator-state.json'
                $script:Store.Writes.Count | Should -Be 0 -Because 'the source side is uncapped and the destination side is denied'
            }
        }
    }
}
