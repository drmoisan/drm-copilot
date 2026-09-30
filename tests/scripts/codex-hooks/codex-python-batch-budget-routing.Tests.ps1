#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

<#
.SYNOPSIS
    Pester tests for large-path routing in the Codex enforce-python-batch-budget.ps1 hook.

.DESCRIPTION
    Covers direct-mode counting of distinct production Python paths, the uncapped
    orchestrated large path, test-path exemption, removal of the persisted cap
    overrides, the ReadCheckpoint seam, and the testable Codex entry-point function.
    Every state and checkpoint operation runs through in-memory seams; no file is
    created or written, no environment variable is read or written, and the
    entry-point cases never reach the real state directory.
#>

Set-StrictMode -Version Latest

Describe 'Codex enforce-python-batch-budget.ps1 large-path routing' {
    BeforeAll {
        $script:HookPath = Join-Path -Path $PSScriptRoot -ChildPath '..' -AdditionalChildPath '..', '..', '.codex', 'hooks', 'enforce-python-batch-budget.ps1'
        $script:HookPath = (Resolve-Path $script:HookPath).Path
        . $script:HookPath

        $script:ThreeProductionPaths = '{"prodFiles":["src/a.py","scripts/b.py","src/c.py"]}'

        function Get-CodexRoutingToolInput {
            param([Parameter(Mandatory)][string] $FilePath)

            return (@{ file_path = $FilePath } | ConvertTo-Json -Compress)
        }

        function Initialize-CodexRoutingStore {
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

        function Get-CodexRoutingSeam {
            param([switch] $IncludeCheckpoint)

            $seams = @{
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
            if ($IncludeCheckpoint) {
                $seams.ReadCheckpoint = {
                    param([string] $Path)
                    $script:RoutingStore.CheckpointReads++
                    $script:RoutingStore.CheckpointPath = $Path
                    return $script:RoutingCheckpointText
                }
            }

            return $seams
        }

        function Invoke-CodexRoutedHook {
            param(
                [Parameter(Mandatory)][string] $FilePath,
                [AllowEmptyString()][string] $CheckpointText = ''
            )

            $script:RoutingCheckpointText = $CheckpointText
            $seams = Get-CodexRoutingSeam -IncludeCheckpoint
            return Invoke-PythonBatchBudgetHook -ToolInputRaw (Get-CodexRoutingToolInput -FilePath $FilePath) -SessionId 'routing' -Root '/repo' @seams
        }

        function Get-CodexRoutingPayload {
            param(
                [Parameter(Mandatory)][string] $FilePath,
                [string] $SessionId = 'routing-entry'
            )

            return ([ordered]@{
                    session_id      = $SessionId
                    hook_event_name = 'PreToolUse'
                    tool_name       = 'Write'
                    tool_input      = [ordered]@{ file_path = $FilePath; content = 'x' }
                } | ConvertTo-Json -Compress -Depth 5)
        }

        function Get-CodexRoutedDenyReason {
            param([AllowEmptyString()][string] $CheckpointText = '')

            Initialize-CodexRoutingStore
            foreach ($candidate in @('src/a.py', 'scripts/b.py', 'src/c.py')) {
                $null = Invoke-CodexRoutedHook -FilePath $candidate -CheckpointText $CheckpointText
            }
            $decision = Invoke-CodexRoutedHook -FilePath 'src/d.py' -CheckpointText $CheckpointText
            return [string]$decision.hookSpecificOutput.permissionDecisionReason
        }
    }

    BeforeEach {
        Initialize-CodexRoutingStore
    }

    Context 'direct mode' {
        It 'allows the first three distinct production paths and denies the 4th with no checkpoint' {
            $decisions = foreach ($candidate in @('src/a.py', 'scripts/b.py', 'src/c.py', 'src/d.py')) {
                Invoke-CodexRoutedHook -FilePath $candidate -CheckpointText ''
            }

            $decisions[0].hookSpecificOutput.permissionDecision | Should -Be 'allow'
            $decisions[1].hookSpecificOutput.permissionDecision | Should -Be 'allow'
            $decisions[2].hookSpecificOutput.permissionDecision | Should -Be 'allow'
            $decisions[3].hookSpecificOutput.permissionDecision | Should -Be 'deny'
        }

        It 'names the routing target, counted paths, requested path, and observed route' {
            $smallReason = Get-CodexRoutedDenyReason -CheckpointText '{"route_id":"small"}'
            $noneReason = Get-CodexRoutedDenyReason -CheckpointText ''

            $smallReason | Should -BeLike 'PYTHON_LARGE_PATH_REQUIRED:*'
            $smallReason | Should -BeLike '*.codex/prompts/orchestrate-work.md*'
            $smallReason | Should -BeLike '*src/a.py, scripts/b.py, src/c.py*'
            $smallReason | Should -BeLike '*requested: src/d.py*'
            $smallReason | Should -BeLike '*Checkpoint route observed: small.*'
            $noneReason | Should -BeLike '*Checkpoint route observed: none.*'
        }

        It 'omits every prohibited remedy phrase and the state-file path from the deny reason' {
            $reason = Get-CodexRoutedDenyReason -CheckpointText '{"route_id":"small"}'

            $reason | Should -BeLike 'PYTHON_LARGE_PATH_REQUIRED:*'
            foreach ($phrase in @('Split the work', 'new batch', 'raise the cap', 'CLAUDE_PYTHON_BUDGET', 'record an approved cap', 'deleting', 'python-batch-budget.', '.codex/state')) {
                $reason | Should -Not -BeLike "*$phrase*" -Because "the deny reason must not mention '$phrase'"
            }
        }

        It 'allows a repeated production path without a state write' {
            Initialize-CodexRoutingStore -PersistedText '{"prodFiles":["src/a.py"]}'

            $decision = Invoke-CodexRoutedHook -FilePath 'src/a.py' -CheckpointText ''

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
            Initialize-CodexRoutingStore -PersistedText $script:ThreeProductionPaths

            { $script:FallbackDecision = Invoke-CodexRoutedHook -FilePath 'src/d.py' -CheckpointText $Text } | Should -Not -Throw

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
                Invoke-CodexRoutedHook -FilePath $candidate -CheckpointText $checkpointText
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

            $result = Invoke-PythonBatchBudgetDecision -FilePath 'src/e.py' -State $state -LargePathRoute

            $result.hookSpecificOutput.permissionDecision | Should -Be 'allow'
            $result.shouldWriteState | Should -BeFalse
            @($result.state.prodFiles) | Should -HaveCount 1
        }

        It 'a path_selected-only large checkpoint allows the 4th production path' {
            Initialize-CodexRoutingStore -PersistedText $script:ThreeProductionPaths

            $decision = Invoke-CodexRoutedHook -FilePath 'src/d.py' -CheckpointText '{"path_selected":"large"}'

            $decision.hookSpecificOutput.permissionDecision | Should -Be 'allow'
            $script:RoutingStore.Writes | Should -Be 0
        }
    }

    Context 'test paths' {
        It 'allows five distinct tests/ paths in direct mode without recording them' {
            $decisions = foreach ($letter in @('a', 'b', 'c', 'd', 'e')) {
                Invoke-CodexRoutedHook -FilePath "tests/unit/test_$letter.py" -CheckpointText ''
            }

            @($decisions | Where-Object { $_.hookSpecificOutput.permissionDecision -eq 'allow' }) | Should -HaveCount 5
            $script:RoutingStore.Writes | Should -Be 0
        }

        It 'allows a root-level test_ file after three production paths without recording it' {
            Initialize-CodexRoutingStore -PersistedText $script:ThreeProductionPaths

            $decision = Invoke-CodexRoutedHook -FilePath 'test_a.py' -CheckpointText ''

            $decision.hookSpecificOutput.permissionDecision | Should -Be 'allow'
            $script:RoutingStore.Writes | Should -Be 0
        }

        It 'allows both test path forms on the large path without touching state' {
            $decisions = foreach ($candidate in @('tests/unit/test_a.py', 'test_a.py')) {
                Invoke-CodexRoutedHook -FilePath $candidate -CheckpointText '{"route_id":"large"}'
            }

            @($decisions | Where-Object { $_.hookSpecificOutput.permissionDecision -eq 'allow' }) | Should -HaveCount 2
            $script:RoutingStore.Writes | Should -Be 0
            $script:RoutingStore.Ensures | Should -Be 0
        }
    }

    Context 'removed cap overrides' {
        It 'loads a legacy state carrying prodCap, testCap, and testFiles and still denies the 4th production path' {
            Initialize-CodexRoutingStore -PersistedText '{"prodCap":10,"testCap":10,"prodFiles":["src/a.py","scripts/b.py","src/c.py"],"testFiles":["tests/unit/test_x.py"]}'

            { $script:LegacyDecision = Invoke-CodexRoutedHook -FilePath 'src/d.py' -CheckpointText '' } | Should -Not -Throw

            $script:LegacyDecision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
            $script:LegacyDecision.hookSpecificOutput.permissionDecisionReason | Should -BeLike 'PYTHON_LARGE_PATH_REQUIRED:*'
        }

        It 'a persisted prodCap below the default does not lower the threshold' {
            Initialize-CodexRoutingStore -PersistedText '{"prodCap":1,"prodFiles":["src/a.py"]}'

            $decision = Invoke-CodexRoutedHook -FilePath 'scripts/b.py' -CheckpointText ''

            $decision.hookSpecificOutput.permissionDecision | Should -Be 'allow'
            $script:RoutingStore.Writes | Should -Be 1
        }

        It 'a fresh state carries no test-file keys' {
            $state = Get-PythonBatchBudgetState -ProdCap 3

            $state.Contains('testFiles') | Should -BeFalse
            $state.Contains('testCap') | Should -BeFalse
        }

        It 'ConvertTo state ignores persisted prodCap, testCap, and testFiles' {
            $loaded = '{"prodCap":10,"testCap":10,"prodFiles":["a.py"],"testFiles":["tests/b.py"]}' | ConvertFrom-Json

            $state = ConvertTo-PythonBatchBudgetState -InputObject $loaded -ProdCap 3

            $state.prodCap | Should -Be 3
            @($state.prodFiles) | Should -Contain 'a.py'
            $state.Contains('testFiles') | Should -BeFalse
        }
    }

    Context 'checkpoint seam' {
        It 'the default reader yields direct mode when the checkpoint file is absent' {
            Initialize-CodexRoutingStore -PersistedText $script:ThreeProductionPaths
            $seams = Get-CodexRoutingSeam

            $decision = Invoke-PythonBatchBudgetHook -ToolInputRaw (Get-CodexRoutingToolInput -FilePath 'src/d.py') -SessionId 'routing' -Root 'C:/synthetic-absent-root' @seams

            $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
            $decision.hookSpecificOutput.permissionDecisionReason | Should -BeLike 'PYTHON_LARGE_PATH_REQUIRED:*'
        }

        It 'reads the checkpoint from artifacts/orchestration/orchestrator-state.json under the root' {
            $null = Invoke-CodexRoutedHook -FilePath 'src/a.py' -CheckpointText ''

            ($script:RoutingStore.CheckpointPath -replace '\\', '/') | Should -Be '/repo/artifacts/orchestration/orchestrator-state.json'
        }

        It 'treats a throwing checkpoint reader as direct mode without raising' {
            Initialize-CodexRoutingStore -PersistedText $script:ThreeProductionPaths
            $seams = Get-CodexRoutingSeam
            $seams.ReadCheckpoint = { param([string] $Path) [void] $Path; throw 'checkpoint unreadable' }

            { $script:ThrowingReaderDecision = Invoke-PythonBatchBudgetHook -ToolInputRaw (Get-CodexRoutingToolInput -FilePath 'src/d.py') -SessionId 'routing' -Root '/repo' @seams } | Should -Not -Throw

            $script:ThrowingReaderDecision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
        }

        It 'still denies malformed tool_input JSON when the checkpoint route is large' {
            $seams = Get-CodexRoutingSeam
            $seams.ReadCheckpoint = { param([string] $Path) [void] $Path; return '{"route_id":"large"}' }

            $decision = Invoke-PythonBatchBudgetHook -ToolInputRaw 'not json' -SessionId 'routing' -Root '/repo' @seams

            $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
            $decision.hookSpecificOutput.permissionDecisionReason | Should -BeLike '*malformed JSON*'
        }

        It 'does not read the checkpoint for a non-Python path' {
            $decision = Invoke-CodexRoutedHook -FilePath 'README.md' -CheckpointText '{"route_id":"large"}'

            $decision.hookSpecificOutput.permissionDecision | Should -Be 'allow'
            $script:RoutingStore.CheckpointReads | Should -Be 0
        }

        It 'does not read the checkpoint when tool_input carries no file_path' {
            $script:RoutingCheckpointText = '{"route_id":"large"}'
            $seams = Get-CodexRoutingSeam -IncludeCheckpoint

            $decision = Invoke-PythonBatchBudgetHook -ToolInputRaw '{"content":"x"}' -SessionId 'routing' -Root '/repo' @seams

            $decision.hookSpecificOutput.permissionDecision | Should -Be 'allow'
            $script:RoutingStore.CheckpointReads | Should -Be 0
        }
    }

    Context 'entry point' {
        It 'allows a Write payload for a production path under a large-route checkpoint without output or state write' {
            $script:RoutingCheckpointText = '{"route_id":"large"}'
            $seams = Get-CodexRoutingSeam -IncludeCheckpoint

            $result = @(Invoke-PythonBatchBudgetCodexEntryPoint -PayloadRaw (Get-CodexRoutingPayload -FilePath 'src/a.py') -RepositoryRoot '/repo' -HookSeams $seams)

            $result | Should -HaveCount 1
            [int]$result[0] | Should -Be 0
            $script:RoutingStore.Writes | Should -Be 0
            $script:RoutingStore.Ensures | Should -Be 0
        }

        It 'emits a deny envelope without a state property for the 4th production path in direct mode' {
            Initialize-CodexRoutingStore -PersistedText $script:ThreeProductionPaths
            $script:RoutingCheckpointText = ''
            $seams = Get-CodexRoutingSeam -IncludeCheckpoint

            $result = @(Invoke-PythonBatchBudgetCodexEntryPoint -PayloadRaw (Get-CodexRoutingPayload -FilePath 'src/d.py') -RepositoryRoot '/repo' -HookSeams $seams)
            $parsed = $result[-2] | ConvertFrom-Json

            [int]$result[-1] | Should -Be 0
            $parsed.hookSpecificOutput.permissionDecision | Should -Be 'deny'
            $parsed.hookSpecificOutput.permissionDecisionReason | Should -BeLike 'PYTHON_LARGE_PATH_REQUIRED:*'
            ($parsed.PSObject.Properties.Name -contains 'state') | Should -BeFalse
        }

        It 'returns exit code 2 and writes stderr for an empty payload' {
            $originalError = [System.Console]::Error
            $errorWriter = [System.IO.StringWriter]::new()
            try {
                [System.Console]::SetError($errorWriter)
                $result = @(Invoke-PythonBatchBudgetCodexEntryPoint -PayloadRaw '' -RepositoryRoot '/repo' -HookSeams (Get-CodexRoutingSeam -IncludeCheckpoint))
            } finally {
                [System.Console]::SetError($originalError)
            }

            [int]$result[-1] | Should -Be 2
            $errorWriter.ToString() | Should -Match 'enforce-python-batch-budget hook input is empty'
        }
    }
}
