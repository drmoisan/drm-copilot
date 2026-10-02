<#
.SYNOPSIS
    Pester tests for large-path routing in the enforce-powershell-batch-budget.ps1 Claude Code hook.

.DESCRIPTION
    Covers the checkpoint route predicate, the selected-route helper, direct-mode
    counting of distinct production PowerShell paths, the uncapped orchestrated large
    path, test-path exemption, removal of the cap overrides, and the ReadCheckpoint
    seam. Every state and checkpoint operation runs through in-memory seams; no file
    is created or written. The only file read is the read-only source scan in the
    removed-cap-overrides context.
#>

Set-StrictMode -Version Latest

Describe 'enforce-powershell-batch-budget.ps1 large-path routing' {
    BeforeAll {
        $script:ScriptPath = Join-Path -Path $PSScriptRoot -ChildPath '..' -AdditionalChildPath '..', '..', '.claude', 'hooks', 'enforce-powershell-batch-budget.ps1'
        $script:ScriptPath = (Resolve-Path $script:ScriptPath).Path
        . $script:ScriptPath

        $script:ThreeProductionPaths = '{"prodFiles":["scripts/a.ps1","scripts/b.psm1","scripts/c.psd1"]}'

        function Get-RoutingToolInput {
            param([Parameter(Mandatory)][string] $FilePath)

            return ([ordered]@{
                    tool_name  = 'Write'
                    tool_input = [ordered]@{ file_path = $FilePath; content = 'body' }
                } | ConvertTo-Json -Compress -Depth 5)
        }

        function Initialize-RoutingStore {
            param([AllowNull()][object] $PersistedText = $null)

            $script:RoutingStore = @{
                Text            = $PersistedText
                Writes          = 0
                Ensures         = 0
                CheckpointReads = 0
                CheckpointPath  = ''
            }
        }

        function Get-RoutingStateSeam {
            return @{
                TestPathExists  = { param([string] $Path) [void] $Path; return ($null -ne $script:RoutingStore.Text) }
                EnsureDirectory = { param([string] $Path) [void] $Path; $script:RoutingStore.Ensures++ }
                ReadState       = { param([string] $Path) [void] $Path; return $script:RoutingStore.Text }
                WriteState      = {
                    param([string] $Path, [System.Collections.IDictionary] $State)
                    [void] $Path
                    $script:RoutingStore.Writes++
                    $script:RoutingStore.Text = ($State | ConvertTo-Json -Compress -Depth 5)
                }
            }
        }

        function Invoke-RoutedHook {
            param(
                [Parameter(Mandatory)][string] $FilePath,
                [AllowEmptyString()][string] $CheckpointText = ''
            )

            $script:RoutingCheckpointText = $CheckpointText
            $seams = Get-RoutingStateSeam
            return Invoke-PowerShellBatchBudgetHook `
                -ToolInputRaw (Get-RoutingToolInput -FilePath $FilePath) `
                -SessionId 'routing' `
                -Root '/repo' `
                -ReadCheckpoint {
                param([string] $Path)
                $script:RoutingStore.CheckpointReads++
                $script:RoutingStore.CheckpointPath = $Path
                return $script:RoutingCheckpointText
            } `
                @seams
        }

        function Get-RoutedDenyReason {
            param([AllowEmptyString()][string] $CheckpointText = '')

            Initialize-RoutingStore
            foreach ($candidate in @('scripts/a.ps1', 'scripts/b.psm1', 'scripts/c.psd1')) {
                $null = Invoke-RoutedHook -FilePath $candidate -CheckpointText $CheckpointText
            }
            $decision = Invoke-RoutedHook -FilePath 'scripts/d.ps1' -CheckpointText $CheckpointText
            return [string]$decision.hookSpecificOutput.permissionDecisionReason
        }
    }

    BeforeEach {
        Initialize-RoutingStore
    }

    AfterEach {
        $env:CLAUDE_POWERSHELL_BUDGET_PROD = $null
        $env:CLAUDE_POWERSHELL_BUDGET_TEST = $null
    }

    Context 'large-path route predicate' {
        It '<Name>' -ForEach @(
            @{ Name = 'route_id large'; Text = '{"route_id":"large","next_step":"S5_atomic_execution"}'; Expected = $true }
            @{ Name = 'route_id remediation'; Text = '{"route_id":"remediation"}'; Expected = $true }
            @{ Name = 'route_id preparation'; Text = '{"route_id":"preparation"}'; Expected = $true }
            @{ Name = 'route_id small'; Text = '{"route_id":"small"}'; Expected = $false }
            @{ Name = 'route_id blank'; Text = '{"route_id":"   "}'; Expected = $false }
            @{ Name = 'route_id unknown'; Text = '{"route_id":"epic"}'; Expected = $false }
            @{ Name = 'route_id wrong case'; Text = '{"route_id":"LARGE"}'; Expected = $false }
            @{ Name = 'no route keys'; Text = '{"next_step":"S5_atomic_execution"}'; Expected = $false }
            @{ Name = 'route_id null with path_selected large'; Text = '{"route_id":null,"path_selected":"large"}'; Expected = $false }
            @{ Name = 'route_id non-string with path_selected large'; Text = '{"route_id":5,"path_selected":"large"}'; Expected = $false }
            @{ Name = 'route_id small wins over path_selected large'; Text = '{"route_id":"small","path_selected":"large"}'; Expected = $false }
            @{ Name = 'path_selected large without route_id'; Text = '{"path_selected":"large"}'; Expected = $true }
            @{ Name = 'path_selected small without route_id'; Text = '{"path_selected":"small"}'; Expected = $false }
            @{ Name = 'terminal next_step complete'; Text = '{"route_id":"large","next_step":"complete"}'; Expected = $false }
            @{ Name = 'terminal S12_complete'; Text = '{"route_id":"large","completed_steps":["S11_pr_created","S12_complete"]}'; Expected = $false }
            @{ Name = 'non-terminal completed steps'; Text = '{"route_id":"large","next_step":"S5_atomic_execution","completed_steps":["S4_atomic_planning"]}'; Expected = $true }
            @{ Name = 'malformed JSON'; Text = '{not-json'; Expected = $false }
            @{ Name = 'array JSON'; Text = '[1,2]'; Expected = $false }
            @{ Name = 'string JSON'; Text = '"large"'; Expected = $false }
            @{ Name = 'empty text'; Text = ''; Expected = $false }
            @{ Name = 'whitespace text'; Text = '   '; Expected = $false }
        ) {
            Test-BatchBudgetLargePathRoute -CheckpointText $Text | Should -Be $Expected
        }
    }

    Context 'selected route' {
        It 'selects <Expected> from <Text>' -ForEach @(
            @{ Text = '{"route_id":"large","path_selected":"small"}'; Expected = 'large' }
            @{ Text = '{"route_id":null,"path_selected":"large"}'; Expected = '' }
            @{ Text = '{"path_selected":"remediation"}'; Expected = 'remediation' }
            @{ Text = '{not-json'; Expected = '' }
        ) {
            Get-BatchBudgetSelectedRoute -CheckpointText $Text | Should -Be $Expected
        }
    }

    Context 'direct mode' {
        It 'allows the first three distinct production paths and denies the 4th with no checkpoint' {
            $decisions = foreach ($candidate in @('scripts/a.ps1', 'scripts/b.psm1', 'scripts/c.psd1', 'scripts/d.ps1')) {
                Invoke-RoutedHook -FilePath $candidate -CheckpointText ''
            }

            $decisions[0].hookSpecificOutput.permissionDecision | Should -Be 'allow'
            $decisions[1].hookSpecificOutput.permissionDecision | Should -Be 'allow'
            $decisions[2].hookSpecificOutput.permissionDecision | Should -Be 'allow'
            $decisions[3].hookSpecificOutput.permissionDecision | Should -Be 'deny'
        }

        It 'denies the 4th distinct production path when the checkpoint route is small' {
            $decisions = foreach ($candidate in @('scripts/a.ps1', 'scripts/b.psm1', 'scripts/c.psd1', 'scripts/d.ps1')) {
                Invoke-RoutedHook -FilePath $candidate -CheckpointText '{"route_id":"small"}'
            }

            $decisions[2].hookSpecificOutput.permissionDecision | Should -Be 'allow'
            $decisions[3].hookSpecificOutput.permissionDecision | Should -Be 'deny'
        }

        It 'names the routing target, counted paths, requested path, and observed route' {
            $smallReason = Get-RoutedDenyReason -CheckpointText '{"route_id":"small"}'
            $noneReason = Get-RoutedDenyReason -CheckpointText ''

            $smallReason | Should -BeLike 'POWERSHELL_LARGE_PATH_REQUIRED:*'
            $smallReason | Should -BeLike '*/orchestrate*'
            $smallReason | Should -BeLike '*scripts/a.ps1, scripts/b.psm1, scripts/c.psd1*'
            $smallReason | Should -BeLike '*requested: scripts/d.ps1*'
            $smallReason | Should -BeLike '*Checkpoint route observed: small.*'
            $noneReason | Should -BeLike '*Checkpoint route observed: none.*'
        }

        It 'omits every prohibited remedy phrase and the state-file path from the deny reason' {
            $reason = Get-RoutedDenyReason -CheckpointText '{"route_id":"small"}'

            $reason | Should -BeLike 'POWERSHELL_LARGE_PATH_REQUIRED:*'
            foreach ($phrase in @('Split the work', 'new batch', 'raise the cap', 'CLAUDE_POWERSHELL_BUDGET', 'record an approved cap', 'deleting', 'powershell-batch-budget.', '.claude/state')) {
                $reason | Should -Not -BeLike "*$phrase*" -Because "the deny reason must not mention '$phrase'"
            }
        }

        It 'allows a repeated production path without a state write' {
            Initialize-RoutingStore -PersistedText '{"prodFiles":["scripts/a.ps1"]}'

            $decision = Invoke-RoutedHook -FilePath 'scripts/a.ps1' -CheckpointText ''

            $decision.hookSpecificOutput.permissionDecision | Should -Be 'allow'
            $script:RoutingStore.Writes | Should -Be 0
        }

        It 'enforces direct mode for a terminal large-route checkpoint' {
            Initialize-RoutingStore -PersistedText $script:ThreeProductionPaths

            $decision = Invoke-RoutedHook -FilePath 'scripts/d.ps1' -CheckpointText '{"route_id":"large","next_step":"complete"}'

            $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
        }
    }

    Context 'large path' {
        It '<Route> route allows six distinct production paths without a state write' -ForEach @(
            @{ Route = 'large' }
            @{ Route = 'remediation' }
            @{ Route = 'preparation' }
        ) {
            $checkpointText = '{"route_id":"' + $Route + '"}'

            $decisions = foreach ($candidate in @('scripts/a.ps1', 'scripts/b.ps1', 'scripts/c.ps1', 'scripts/d.ps1', 'scripts/e.ps1', 'scripts/f.ps1')) {
                Invoke-RoutedHook -FilePath $candidate -CheckpointText $checkpointText
            }

            @($decisions | Where-Object { $_.hookSpecificOutput.permissionDecision -eq 'allow' }) | Should -HaveCount 6
            $script:RoutingStore.Writes | Should -Be 0
            $script:RoutingStore.Ensures | Should -Be 0
        }

        It 'the decision with LargePathRoute allows without recording' {
            $state = Get-PowerShellBatchBudgetState -ProdCap 1
            $state.prodFiles = @('scripts/a.ps1')

            $result = Invoke-PowerShellBatchBudgetDecision -FilePath 'scripts/e.ps1' -State $state -Root '/repo' -LargePathRoute

            $result.hookSpecificOutput.permissionDecision | Should -Be 'allow'
            $result.shouldWriteState | Should -BeFalse
            @($result.state.prodFiles) | Should -HaveCount 1
        }

        It 'a path_selected-only large checkpoint allows the 4th production path' {
            Initialize-RoutingStore -PersistedText $script:ThreeProductionPaths

            $decision = Invoke-RoutedHook -FilePath 'scripts/d.ps1' -CheckpointText '{"path_selected":"large"}'

            $decision.hookSpecificOutput.permissionDecision | Should -Be 'allow'
            $script:RoutingStore.Writes | Should -Be 0
        }
    }

    Context 'test paths' {
        It 'allows five distinct test paths in direct mode without recording them' {
            $decisions = foreach ($letter in @('a', 'b', 'c', 'd', 'e')) {
                Invoke-RoutedHook -FilePath "tests/scripts/$letter.Tests.ps1" -CheckpointText ''
            }

            @($decisions | Where-Object { $_.hookSpecificOutput.permissionDecision -eq 'allow' }) | Should -HaveCount 5
            $script:RoutingStore.Writes | Should -Be 0
        }

        It 'allows a test path on the large path without a state write' {
            $decision = Invoke-RoutedHook -FilePath 'tests/scripts/a.Tests.ps1' -CheckpointText '{"route_id":"large"}'

            $decision.hookSpecificOutput.permissionDecision | Should -Be 'allow'
            $script:RoutingStore.Writes | Should -Be 0
            $script:RoutingStore.Ensures | Should -Be 0
        }
    }

    Context 'removed cap overrides' {
        It 'loads a legacy state carrying prodCap, testCap, and testFiles and still denies the 4th production path' {
            Initialize-RoutingStore -PersistedText '{"prodCap":10,"testCap":10,"prodFiles":["scripts/a.ps1","scripts/b.ps1","scripts/c.ps1"],"testFiles":["tests/scripts/x.Tests.ps1"]}'

            { $script:LegacyDecision = Invoke-RoutedHook -FilePath 'scripts/d.ps1' -CheckpointText '' } | Should -Not -Throw

            $script:LegacyDecision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
            $script:LegacyDecision.hookSpecificOutput.permissionDecisionReason | Should -BeLike 'POWERSHELL_LARGE_PATH_REQUIRED:*'
        }

        It 'ignores CLAUDE_POWERSHELL_BUDGET_PROD and _TEST set in the test scope' {
            $env:CLAUDE_POWERSHELL_BUDGET_PROD = '10'
            $env:CLAUDE_POWERSHELL_BUDGET_TEST = '10'
            Initialize-RoutingStore -PersistedText $script:ThreeProductionPaths

            $decision = Invoke-RoutedHook -FilePath 'scripts/d.ps1' -CheckpointText ''

            $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
        }

        It 'the hook sources contain no CLAUDE_POWERSHELL_BUDGET reference' {
            $hookDirectory = Split-Path -Path $script:ScriptPath -Parent
            $sources = @(Get-ChildItem -LiteralPath $hookDirectory -Filter 'enforce-powershell-batch-budget*.ps1' -File)

            $sources.Count | Should -BeGreaterOrEqual 1
            foreach ($source in $sources) {
                (Get-Content -LiteralPath $source.FullName -Raw) | Should -Not -BeLike '*CLAUDE_POWERSHELL_BUDGET*' -Because "$($source.Name) must not read the removed override"
            }
        }

        It 'a fresh state carries no test-file keys' {
            $state = Get-PowerShellBatchBudgetState -ProdCap 3

            $state.Contains('testFiles') | Should -BeFalse
            $state.Contains('testCap') | Should -BeFalse
        }
    }

    Context 'checkpoint seam' {
        It 'the default reader yields direct mode when the checkpoint file is absent' {
            $absentRoot = if ($IsWindows) { 'C:/synthetic-absent-root' } else { '/synthetic-absent-root' }
            Initialize-RoutingStore -PersistedText $script:ThreeProductionPaths
            $seams = Get-RoutingStateSeam

            $decision = Invoke-PowerShellBatchBudgetHook `
                -ToolInputRaw (Get-RoutingToolInput -FilePath 'scripts/d.ps1') `
                -SessionId 'routing' `
                -Root $absentRoot `
                @seams

            $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
            $decision.hookSpecificOutput.permissionDecisionReason | Should -BeLike 'POWERSHELL_LARGE_PATH_REQUIRED:*'
        }

        It 'reads the checkpoint from artifacts/orchestration/orchestrator-state.json under the root' {
            $null = Invoke-RoutedHook -FilePath 'scripts/a.ps1' -CheckpointText ''

            ($script:RoutingStore.CheckpointPath -replace '\\', '/') | Should -Be '/repo/artifacts/orchestration/orchestrator-state.json'
        }

        It 'treats a throwing checkpoint reader as direct mode without raising' {
            Initialize-RoutingStore -PersistedText $script:ThreeProductionPaths
            $seams = Get-RoutingStateSeam

            {
                $script:ThrowingReaderDecision = Invoke-PowerShellBatchBudgetHook `
                    -ToolInputRaw (Get-RoutingToolInput -FilePath 'scripts/d.ps1') `
                    -SessionId 'routing' `
                    -Root '/repo' `
                    -ReadCheckpoint { param([string] $Path) [void] $Path; throw 'checkpoint unreadable' } `
                    @seams
            } | Should -Not -Throw

            $script:ThrowingReaderDecision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
        }

        It 'still denies an unreadable envelope when the checkpoint route is large' {
            $seams = Get-RoutingStateSeam

            $decision = Invoke-PowerShellBatchBudgetHook `
                -ToolInputRaw '' `
                -SessionId 'routing' `
                -Root '/repo' `
                -ReadCheckpoint { param([string] $Path) [void] $Path; return '{"route_id":"large"}' } `
                @seams

            $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
            $decision.hookSpecificOutput.permissionDecisionReason | Should -BeLike '*empty payload*'
        }

        It 'does not read the checkpoint for a non-PowerShell path' {
            $decision = Invoke-RoutedHook -FilePath 'README.md' -CheckpointText '{"route_id":"large"}'

            $decision.hookSpecificOutput.permissionDecision | Should -Be 'allow'
            $script:RoutingStore.CheckpointReads | Should -Be 0
        }
    }
}
