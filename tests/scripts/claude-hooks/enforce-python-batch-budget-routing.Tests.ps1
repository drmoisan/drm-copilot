<#
.SYNOPSIS
    Pester tests for large-path routing in the enforce-python-batch-budget.ps1 Claude Code hook.

.DESCRIPTION
    Covers direct-mode counting of distinct production Python paths, the uncapped
    orchestrated large path, test-path exemption, removal of the cap overrides, and the
    ReadCheckpoint seam. Every state and checkpoint operation runs through in-memory
    seams; no file is created or written. The only file reads are the read-only source
    scan in the removed-cap-overrides context.
#>

Set-StrictMode -Version Latest

Describe 'enforce-python-batch-budget.ps1 large-path routing' {
    BeforeAll {
        $script:ScriptPath = Join-Path -Path $PSScriptRoot -ChildPath '..' -AdditionalChildPath '..', '..', '.claude', 'hooks', 'enforce-python-batch-budget.ps1'
        $script:ScriptPath = (Resolve-Path $script:ScriptPath).Path
        . $script:ScriptPath

        $script:ThreeProductionPaths = '{"prodFiles":["src/a.py","scripts/b.py","src/c.py"]}'

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
                Reads           = 0
                Probes          = 0
                CheckpointReads = 0
                CheckpointPath  = ''
            }
        }

        function Get-RoutingStateSeam {
            return @{
                TestPathExists  = {
                    param([string] $Path)
                    [void] $Path
                    $script:RoutingStore.Probes++
                    return ($null -ne $script:RoutingStore.Text)
                }
                EnsureDirectory = { param([string] $Path) [void] $Path; $script:RoutingStore.Ensures++ }
                ReadState       = {
                    param([string] $Path)
                    [void] $Path
                    $script:RoutingStore.Reads++
                    return $script:RoutingStore.Text
                }
                WriteState      = {
                    param([string] $Path, [System.Collections.IDictionary] $State)
                    [void] $Path
                    $script:RoutingStore.Writes++
                    $script:RoutingStore.Text = ($State | ConvertTo-Json -Compress -Depth 5)
                }
            }
        }

        function Get-RoutingCheckpointSeam {
            return {
                param([string] $Path)
                $script:RoutingStore.CheckpointReads++
                $script:RoutingStore.CheckpointPath = $Path
                return $script:RoutingCheckpointText
            }
        }

        function Invoke-RoutedHook {
            param(
                [Parameter(Mandatory)][string] $FilePath,
                [AllowEmptyString()][string] $CheckpointText = ''
            )

            $script:RoutingCheckpointText = $CheckpointText
            $seams = Get-RoutingStateSeam
            return Invoke-PythonBatchBudgetHook `
                -ToolInputRaw (Get-RoutingToolInput -FilePath $FilePath) `
                -SessionId 'routing' `
                -Root '/repo' `
                -ReadCheckpoint (Get-RoutingCheckpointSeam) `
                @seams
        }

        function Get-RoutedDenyReason {
            param([AllowEmptyString()][string] $CheckpointText = '')

            Initialize-RoutingStore
            foreach ($candidate in @('src/a.py', 'scripts/b.py', 'src/c.py')) {
                $null = Invoke-RoutedHook -FilePath $candidate -CheckpointText $CheckpointText
            }
            $decision = Invoke-RoutedHook -FilePath 'src/d.py' -CheckpointText $CheckpointText
            return [string]$decision.hookSpecificOutput.permissionDecisionReason
        }
    }

    BeforeEach {
        Initialize-RoutingStore
        $script:PriorProdBudget = $env:CLAUDE_PYTHON_BUDGET_PROD
        $script:PriorTestBudget = $env:CLAUDE_PYTHON_BUDGET_TEST
    }

    AfterEach {
        $env:CLAUDE_PYTHON_BUDGET_PROD = $script:PriorProdBudget
        $env:CLAUDE_PYTHON_BUDGET_TEST = $script:PriorTestBudget
    }

    Context 'direct mode' {
        It 'allows the first three distinct production paths and denies the 4th with no checkpoint' {
            $decisions = foreach ($candidate in @('src/a.py', 'scripts/b.py', 'src/c.py', 'src/d.py')) {
                Invoke-RoutedHook -FilePath $candidate -CheckpointText ''
            }

            $decisions[0].hookSpecificOutput.permissionDecision | Should -Be 'allow'
            $decisions[1].hookSpecificOutput.permissionDecision | Should -Be 'allow'
            $decisions[2].hookSpecificOutput.permissionDecision | Should -Be 'allow'
            $decisions[3].hookSpecificOutput.permissionDecision | Should -Be 'deny'
        }

        It 'names the routing target, counted paths, requested path, and observed route' {
            $smallReason = Get-RoutedDenyReason -CheckpointText '{"route_id":"small"}'
            $noneReason = Get-RoutedDenyReason -CheckpointText ''

            $smallReason | Should -BeLike 'PYTHON_LARGE_PATH_REQUIRED:*'
            $smallReason | Should -BeLike '*/orchestrate*'
            $smallReason | Should -BeLike '*src/a.py, scripts/b.py, src/c.py*'
            $smallReason | Should -BeLike '*requested: src/d.py*'
            $smallReason | Should -BeLike '*Checkpoint route observed: small.*'
            $noneReason | Should -BeLike '*Checkpoint route observed: none.*'
        }

        It 'omits every prohibited remedy phrase and the state-file path from the deny reason' {
            $reason = Get-RoutedDenyReason -CheckpointText '{"route_id":"small"}'

            $reason | Should -BeLike 'PYTHON_LARGE_PATH_REQUIRED:*'
            foreach ($phrase in @('Split the work', 'new batch', 'raise the cap', 'CLAUDE_PYTHON_BUDGET', 'record an approved cap', 'deleting', 'python-batch-budget.', '.claude/state')) {
                $reason | Should -Not -BeLike "*$phrase*" -Because "the deny reason must not mention '$phrase'"
            }
        }

        It 'allows a repeated production path without a state write' {
            Initialize-RoutingStore -PersistedText '{"prodFiles":["src/a.py"]}'

            $decision = Invoke-RoutedHook -FilePath 'src/a.py' -CheckpointText ''

            $decision.hookSpecificOutput.permissionDecision | Should -Be 'allow'
            $script:RoutingStore.Writes | Should -Be 0
        }

        It '<Name> checkpoint enforces direct mode for the 4th production path' -ForEach @(
            @{ Name = 'route_id small'; Text = '{"route_id":"small"}' }
            @{ Name = 'terminal next_step complete'; Text = '{"route_id":"large","next_step":"complete"}' }
            @{ Name = 'terminal S12_complete'; Text = '{"route_id":"large","completed_steps":["S11_pr_created","S12_complete"]}' }
            @{ Name = 'null route_id with path_selected large'; Text = '{"route_id":null,"path_selected":"large"}' }
            @{ Name = 'blank route_id with path_selected large'; Text = '{"route_id":"   ","path_selected":"large"}' }
            @{ Name = 'unknown route'; Text = '{"route_id":"epic"}' }
            @{ Name = 'malformed'; Text = '{not-json' }
            @{ Name = 'non-object'; Text = '[1,2]' }
            @{ Name = 'empty'; Text = '' }
        ) {
            Initialize-RoutingStore -PersistedText $script:ThreeProductionPaths

            { $script:FallbackDecision = Invoke-RoutedHook -FilePath 'src/d.py' -CheckpointText $Text } | Should -Not -Throw

            $script:FallbackDecision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
            $script:FallbackDecision.hookSpecificOutput.permissionDecisionReason | Should -BeLike 'PYTHON_LARGE_PATH_REQUIRED:*'
        }
    }

    Context 'large path' {
        It '<Route> route allows six distinct production paths without touching state' -ForEach @(
            @{ Route = 'large' }
            @{ Route = 'remediation' }
            @{ Route = 'preparation' }
        ) {
            $checkpointText = '{"route_id":"' + $Route + '"}'

            $decisions = foreach ($candidate in @('src/a.py', 'src/b.py', 'src/c.py', 'src/d.py', 'src/e.py', 'src/f.py')) {
                Invoke-RoutedHook -FilePath $candidate -CheckpointText $checkpointText
            }

            @($decisions | Where-Object { $_.hookSpecificOutput.permissionDecision -eq 'allow' }) | Should -HaveCount 6
            $script:RoutingStore.Writes | Should -Be 0
            $script:RoutingStore.Ensures | Should -Be 0
            $script:RoutingStore.Reads | Should -Be 0
            $script:RoutingStore.Probes | Should -Be 0
        }

        It 'the decision with LargePathRoute allows without recording' {
            $state = Get-PythonBatchBudgetState -ProdCap 1
            $state.prodFiles = @('src/a.py')

            $result = Invoke-PythonBatchBudgetDecision -FilePath 'src/e.py' -State $state -Root '/repo' -LargePathRoute

            $result.hookSpecificOutput.permissionDecision | Should -Be 'allow'
            $result.shouldWriteState | Should -BeFalse
            @($result.state.prodFiles) | Should -HaveCount 1
        }

        It 'a path_selected-only large checkpoint allows the 4th production path' {
            Initialize-RoutingStore -PersistedText $script:ThreeProductionPaths

            $decision = Invoke-RoutedHook -FilePath 'src/d.py' -CheckpointText '{"path_selected":"large"}'

            $decision.hookSpecificOutput.permissionDecision | Should -Be 'allow'
            $script:RoutingStore.Writes | Should -Be 0
        }
    }

    Context 'test paths' {
        It 'allows five distinct tests/ paths in direct mode without recording them' {
            $decisions = foreach ($letter in @('a', 'b', 'c', 'd', 'e')) {
                Invoke-RoutedHook -FilePath "tests/unit/test_$letter.py" -CheckpointText ''
            }

            @($decisions | Where-Object { $_.hookSpecificOutput.permissionDecision -eq 'allow' }) | Should -HaveCount 5
            $script:RoutingStore.Writes | Should -Be 0
        }

        It 'allows a root-level test_ file after three production paths without recording it' {
            Initialize-RoutingStore -PersistedText $script:ThreeProductionPaths

            $decision = Invoke-RoutedHook -FilePath 'test_a.py' -CheckpointText ''

            $decision.hookSpecificOutput.permissionDecision | Should -Be 'allow'
            $script:RoutingStore.Writes | Should -Be 0
        }

        It 'allows both test path forms on the large path without touching state' {
            $decisions = foreach ($candidate in @('tests/unit/test_a.py', 'test_a.py')) {
                Invoke-RoutedHook -FilePath $candidate -CheckpointText '{"route_id":"large"}'
            }

            @($decisions | Where-Object { $_.hookSpecificOutput.permissionDecision -eq 'allow' }) | Should -HaveCount 2
            $script:RoutingStore.Writes | Should -Be 0
            $script:RoutingStore.Ensures | Should -Be 0
        }
    }

    Context 'removed cap overrides' {
        It 'loads a legacy state carrying prodCap, testCap, and testFiles and still denies the 4th production path' {
            Initialize-RoutingStore -PersistedText '{"prodCap":10,"testCap":10,"prodFiles":["src/a.py","scripts/b.py","src/c.py"],"testFiles":["tests/unit/test_x.py"]}'

            { $script:LegacyDecision = Invoke-RoutedHook -FilePath 'src/d.py' -CheckpointText '' } | Should -Not -Throw

            $script:LegacyDecision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
            $script:LegacyDecision.hookSpecificOutput.permissionDecisionReason | Should -BeLike 'PYTHON_LARGE_PATH_REQUIRED:*'
        }

        It 'a persisted prodCap below the default does not lower the threshold' {
            Initialize-RoutingStore -PersistedText '{"prodCap":1,"prodFiles":["src/a.py"]}'

            $decision = Invoke-RoutedHook -FilePath 'scripts/b.py' -CheckpointText ''

            $decision.hookSpecificOutput.permissionDecision | Should -Be 'allow'
            $script:RoutingStore.Writes | Should -Be 1
        }

        It 'ignores CLAUDE_PYTHON_BUDGET_PROD and _TEST set in the test scope' {
            $env:CLAUDE_PYTHON_BUDGET_PROD = '10'
            $env:CLAUDE_PYTHON_BUDGET_TEST = '10'
            Initialize-RoutingStore -PersistedText $script:ThreeProductionPaths

            $decision = Invoke-RoutedHook -FilePath 'src/d.py' -CheckpointText ''

            $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
        }

        It 'the hook and helper sources contain no CLAUDE_PYTHON_BUDGET reference' {
            $hookDirectory = Split-Path -Path $script:ScriptPath -Parent
            $sources = @($script:ScriptPath, (Join-Path -Path $hookDirectory -ChildPath 'enforce-batch-budget-route.ps1'))

            foreach ($source in $sources) {
                (Get-Content -LiteralPath $source -Raw) | Should -Not -BeLike '*CLAUDE_PYTHON_BUDGET*' -Because "$(Split-Path -Path $source -Leaf) must not read the removed override"
            }
        }

        It 'a fresh state carries no test-file keys' {
            $state = Get-PythonBatchBudgetState -ProdCap 3

            $state.Contains('testFiles') | Should -BeFalse
            $state.Contains('testCap') | Should -BeFalse
        }
    }

    Context 'checkpoint seam' {
        It 'the default reader yields direct mode when the checkpoint file is absent' {
            Initialize-RoutingStore -PersistedText $script:ThreeProductionPaths
            $seams = Get-RoutingStateSeam

            $decision = Invoke-PythonBatchBudgetHook `
                -ToolInputRaw (Get-RoutingToolInput -FilePath 'src/d.py') `
                -SessionId 'routing' `
                -Root 'C:/synthetic-absent-root' `
                @seams

            $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
            $decision.hookSpecificOutput.permissionDecisionReason | Should -BeLike 'PYTHON_LARGE_PATH_REQUIRED:*'
        }

        It 'reads the checkpoint from artifacts/orchestration/orchestrator-state.json under the root' {
            $null = Invoke-RoutedHook -FilePath 'src/a.py' -CheckpointText ''

            ($script:RoutingStore.CheckpointPath -replace '\\', '/') | Should -Be '/repo/artifacts/orchestration/orchestrator-state.json'
        }

        It 'treats a throwing checkpoint reader as direct mode without raising' {
            Initialize-RoutingStore -PersistedText $script:ThreeProductionPaths
            $seams = Get-RoutingStateSeam

            {
                $script:ThrowingReaderDecision = Invoke-PythonBatchBudgetHook `
                    -ToolInputRaw (Get-RoutingToolInput -FilePath 'src/d.py') `
                    -SessionId 'routing' `
                    -Root '/repo' `
                    -ReadCheckpoint { param([string] $Path) [void] $Path; throw 'checkpoint unreadable' } `
                    @seams
            } | Should -Not -Throw

            $script:ThrowingReaderDecision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
        }

        It 'still denies an unreadable envelope when the checkpoint route is large' {
            $seams = Get-RoutingStateSeam

            $decision = Invoke-PythonBatchBudgetHook `
                -ToolInputRaw '' `
                -SessionId 'routing' `
                -Root '/repo' `
                -ReadCheckpoint { param([string] $Path) [void] $Path; return '{"route_id":"large"}' } `
                @seams

            $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
            $decision.hookSpecificOutput.permissionDecisionReason | Should -BeLike '*empty payload*'
        }

        It 'does not read the checkpoint for a non-Python path' {
            $decision = Invoke-RoutedHook -FilePath 'README.md' -CheckpointText '{"route_id":"large"}'

            $decision.hookSpecificOutput.permissionDecision | Should -Be 'allow'
            $script:RoutingStore.CheckpointReads | Should -Be 0
        }

        It 'does not read the checkpoint when the envelope carries no file_path' {
            $seams = Get-RoutingStateSeam

            $decision = Invoke-PythonBatchBudgetHook `
                -ToolInputRaw '{"tool_name":"Bash","tool_input":{"command":"echo hi"}}' `
                -SessionId 'routing' `
                -Root '/repo' `
                -ReadCheckpoint (Get-RoutingCheckpointSeam) `
                @seams

            $decision.hookSpecificOutput.permissionDecision | Should -Be 'allow'
            $script:RoutingStore.CheckpointReads | Should -Be 0
        }
    }
}
