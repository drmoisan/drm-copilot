#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

<#
.SYNOPSIS
    Pester tests for large-path routing in the Codex enforce-powershell-batch-budget.ps1 hook.

.DESCRIPTION
    Covers the checkpoint route predicate, the selected-route helper, direct-mode
    counting of distinct production PowerShell paths, the uncapped orchestrated large
    path, test-path exemption, removal of the persisted cap overrides, the
    ReadCheckpoint seam, and the testable Codex entry-point function. Every state and
    checkpoint operation runs through in-memory seams; no file is created or written,
    and the entry-point cases never reach the real state directory.
#>

Set-StrictMode -Version Latest

Describe 'Codex enforce-powershell-batch-budget.ps1 large-path routing' {
    BeforeAll {
        $script:HookPath = Join-Path -Path $PSScriptRoot -ChildPath '..' -AdditionalChildPath '..', '..', '.codex', 'hooks', 'enforce-powershell-batch-budget.ps1'
        $script:HookPath = (Resolve-Path $script:HookPath).Path
        . $script:HookPath

        $script:ThreeProductionPaths = '{"prodFiles":["scripts/a.ps1","scripts/b.psm1","scripts/c.psd1"]}'

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
                CheckpointReads = 0
                CheckpointPath  = ''
            }
        }

        function Get-CodexRoutingSeam {
            param([switch] $IncludeCheckpoint)

            $seams = @{
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
            return Invoke-PowerShellBatchBudgetHook -ToolInputRaw (Get-CodexRoutingToolInput -FilePath $FilePath) -SessionId 'routing' -Root '/repo' @seams
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
            foreach ($candidate in @('scripts/a.ps1', 'scripts/b.psm1', 'scripts/c.psd1')) {
                $null = Invoke-CodexRoutedHook -FilePath $candidate -CheckpointText $CheckpointText
            }
            $decision = Invoke-CodexRoutedHook -FilePath 'scripts/d.ps1' -CheckpointText $CheckpointText
            return [string]$decision.hookSpecificOutput.permissionDecisionReason
        }
    }

    BeforeEach {
        Initialize-CodexRoutingStore
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
                Invoke-CodexRoutedHook -FilePath $candidate -CheckpointText ''
            }

            $decisions[0].hookSpecificOutput.permissionDecision | Should -Be 'allow'
            $decisions[1].hookSpecificOutput.permissionDecision | Should -Be 'allow'
            $decisions[2].hookSpecificOutput.permissionDecision | Should -Be 'allow'
            $decisions[3].hookSpecificOutput.permissionDecision | Should -Be 'deny'
        }

        It 'denies the 4th distinct production path when the checkpoint route is small' {
            $decisions = foreach ($candidate in @('scripts/a.ps1', 'scripts/b.psm1', 'scripts/c.psd1', 'scripts/d.ps1')) {
                Invoke-CodexRoutedHook -FilePath $candidate -CheckpointText '{"route_id":"small"}'
            }

            $decisions[2].hookSpecificOutput.permissionDecision | Should -Be 'allow'
            $decisions[3].hookSpecificOutput.permissionDecision | Should -Be 'deny'
        }

        It 'names the routing target, counted paths, requested path, and observed route' {
            $smallReason = Get-CodexRoutedDenyReason -CheckpointText '{"route_id":"small"}'
            $noneReason = Get-CodexRoutedDenyReason -CheckpointText ''

            $smallReason | Should -BeLike 'POWERSHELL_LARGE_PATH_REQUIRED:*'
            $smallReason | Should -BeLike '*.codex/prompts/orchestrate-work.md*'
            $smallReason | Should -BeLike '*scripts/a.ps1, scripts/b.psm1, scripts/c.psd1*'
            $smallReason | Should -BeLike '*requested: scripts/d.ps1*'
            $smallReason | Should -BeLike '*Checkpoint route observed: small.*'
            $noneReason | Should -BeLike '*Checkpoint route observed: none.*'
        }

        It 'omits every prohibited remedy phrase and the state-file path from the deny reason' {
            $reason = Get-CodexRoutedDenyReason -CheckpointText '{"route_id":"small"}'

            $reason | Should -BeLike 'POWERSHELL_LARGE_PATH_REQUIRED:*'
            foreach ($phrase in @('Split the work', 'new batch', 'raise the cap', 'CLAUDE_POWERSHELL_BUDGET', 'record an approved cap', 'deleting', 'powershell-batch-budget.', '.codex/state')) {
                $reason | Should -Not -BeLike "*$phrase*" -Because "the deny reason must not mention '$phrase'"
            }
        }

        It 'allows a repeated production path without a state write' {
            Initialize-CodexRoutingStore -PersistedText '{"prodFiles":["scripts/a.ps1"]}'

            $decision = Invoke-CodexRoutedHook -FilePath 'scripts/a.ps1' -CheckpointText ''

            $decision.hookSpecificOutput.permissionDecision | Should -Be 'allow'
            $script:RoutingStore.Writes | Should -Be 0
        }

        It 'enforces direct mode for a terminal large-route checkpoint' {
            Initialize-CodexRoutingStore -PersistedText $script:ThreeProductionPaths

            $decision = Invoke-CodexRoutedHook -FilePath 'scripts/d.ps1' -CheckpointText '{"route_id":"large","next_step":"complete"}'

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
                Invoke-CodexRoutedHook -FilePath $candidate -CheckpointText $checkpointText
            }

            @($decisions | Where-Object { $_.hookSpecificOutput.permissionDecision -eq 'allow' }) | Should -HaveCount 6
            $script:RoutingStore.Writes | Should -Be 0
            $script:RoutingStore.Ensures | Should -Be 0
        }

        It 'the decision with LargePathRoute allows without recording' {
            $state = Get-PowerShellBatchBudgetState -ProdCap 1
            $state.prodFiles = @('scripts/a.ps1')

            $result = Invoke-PowerShellBatchBudgetDecision -FilePath 'scripts/e.ps1' -State $state -LargePathRoute

            $result.hookSpecificOutput.permissionDecision | Should -Be 'allow'
            $result.shouldWriteState | Should -BeFalse
            @($result.state.prodFiles) | Should -HaveCount 1
        }

        It 'a path_selected-only large checkpoint allows the 4th production path' {
            Initialize-CodexRoutingStore -PersistedText $script:ThreeProductionPaths

            $decision = Invoke-CodexRoutedHook -FilePath 'scripts/d.ps1' -CheckpointText '{"path_selected":"large"}'

            $decision.hookSpecificOutput.permissionDecision | Should -Be 'allow'
            $script:RoutingStore.Writes | Should -Be 0
        }
    }

    Context 'test paths' {
        It 'allows five distinct test paths in direct mode without recording them' {
            $decisions = foreach ($letter in @('a', 'b', 'c', 'd', 'e')) {
                Invoke-CodexRoutedHook -FilePath "tests/scripts/$letter.Tests.ps1" -CheckpointText ''
            }

            @($decisions | Where-Object { $_.hookSpecificOutput.permissionDecision -eq 'allow' }) | Should -HaveCount 5
            $script:RoutingStore.Writes | Should -Be 0
        }

        It 'allows a test path on the large path without a state write' {
            $decision = Invoke-CodexRoutedHook -FilePath 'tests/scripts/a.Tests.ps1' -CheckpointText '{"route_id":"large"}'

            $decision.hookSpecificOutput.permissionDecision | Should -Be 'allow'
            $script:RoutingStore.Writes | Should -Be 0
            $script:RoutingStore.Ensures | Should -Be 0
        }
    }

    Context 'removed cap overrides' {
        It 'loads a legacy state carrying prodCap, testCap, and testFiles and still denies the 4th production path' {
            Initialize-CodexRoutingStore -PersistedText '{"prodCap":10,"testCap":10,"prodFiles":["scripts/a.ps1","scripts/b.ps1","scripts/c.ps1"],"testFiles":["tests/scripts/x.Tests.ps1"]}'

            { $script:LegacyDecision = Invoke-CodexRoutedHook -FilePath 'scripts/d.ps1' -CheckpointText '' } | Should -Not -Throw

            $script:LegacyDecision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
            $script:LegacyDecision.hookSpecificOutput.permissionDecisionReason | Should -BeLike 'POWERSHELL_LARGE_PATH_REQUIRED:*'
        }

        It 'a fresh state carries no test-file keys' {
            $state = Get-PowerShellBatchBudgetState -ProdCap 3

            $state.Contains('testFiles') | Should -BeFalse
            $state.Contains('testCap') | Should -BeFalse
        }

        It 'ConvertTo state ignores persisted prodCap, testCap, and testFiles' {
            $loaded = '{"prodCap":10,"testCap":10,"prodFiles":["a.ps1"],"testFiles":["b.Tests.ps1"]}' | ConvertFrom-Json

            $state = ConvertTo-PowerShellBatchBudgetState -InputObject $loaded -ProdCap 3

            $state.prodCap | Should -Be 3
            @($state.prodFiles) | Should -Contain 'a.ps1'
            $state.Contains('testFiles') | Should -BeFalse
        }
    }

    Context 'checkpoint seam' {
        It 'the default reader yields direct mode when the checkpoint file is absent' {
            Initialize-CodexRoutingStore -PersistedText $script:ThreeProductionPaths
            $seams = Get-CodexRoutingSeam

            $decision = Invoke-PowerShellBatchBudgetHook -ToolInputRaw (Get-CodexRoutingToolInput -FilePath 'scripts/d.ps1') -SessionId 'routing' -Root 'C:/synthetic-absent-root' @seams

            $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
            $decision.hookSpecificOutput.permissionDecisionReason | Should -BeLike 'POWERSHELL_LARGE_PATH_REQUIRED:*'
        }

        It 'reads the checkpoint from artifacts/orchestration/orchestrator-state.json under the root' {
            $null = Invoke-CodexRoutedHook -FilePath 'scripts/a.ps1' -CheckpointText ''

            ($script:RoutingStore.CheckpointPath -replace '\\', '/') | Should -Be '/repo/artifacts/orchestration/orchestrator-state.json'
        }

        It 'treats a throwing checkpoint reader as direct mode without raising' {
            Initialize-CodexRoutingStore -PersistedText $script:ThreeProductionPaths
            $seams = Get-CodexRoutingSeam
            $seams.ReadCheckpoint = { param([string] $Path) [void] $Path; throw 'checkpoint unreadable' }

            { $script:ThrowingReaderDecision = Invoke-PowerShellBatchBudgetHook -ToolInputRaw (Get-CodexRoutingToolInput -FilePath 'scripts/d.ps1') -SessionId 'routing' -Root '/repo' @seams } | Should -Not -Throw

            $script:ThrowingReaderDecision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
        }

        It 'still denies malformed tool_input JSON when the checkpoint route is large' {
            $seams = Get-CodexRoutingSeam
            $seams.ReadCheckpoint = { param([string] $Path) [void] $Path; return '{"route_id":"large"}' }

            $decision = Invoke-PowerShellBatchBudgetHook -ToolInputRaw 'not json' -SessionId 'routing' -Root '/repo' @seams

            $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
            $decision.hookSpecificOutput.permissionDecisionReason | Should -BeLike '*malformed JSON*'
        }

        It 'does not read the checkpoint for a non-PowerShell path' {
            $decision = Invoke-CodexRoutedHook -FilePath 'README.md' -CheckpointText '{"route_id":"large"}'

            $decision.hookSpecificOutput.permissionDecision | Should -Be 'allow'
            $script:RoutingStore.CheckpointReads | Should -Be 0
        }
    }

    Context 'entry point' {
        It 'allows a Write payload for a production path under a large-route checkpoint without output or state write' {
            $script:RoutingCheckpointText = '{"route_id":"large"}'
            $seams = Get-CodexRoutingSeam -IncludeCheckpoint

            $result = @(Invoke-PowerShellBatchBudgetCodexEntryPoint -PayloadRaw (Get-CodexRoutingPayload -FilePath 'scripts/a.ps1') -RepositoryRoot '/repo' -HookSeams $seams)

            $result | Should -HaveCount 1
            [int]$result[0] | Should -Be 0
            $script:RoutingStore.Writes | Should -Be 0
            $script:RoutingStore.Ensures | Should -Be 0
        }

        It 'emits a deny envelope without a state property for the 4th production path in direct mode' {
            Initialize-CodexRoutingStore -PersistedText $script:ThreeProductionPaths
            $script:RoutingCheckpointText = ''
            $seams = Get-CodexRoutingSeam -IncludeCheckpoint

            $result = @(Invoke-PowerShellBatchBudgetCodexEntryPoint -PayloadRaw (Get-CodexRoutingPayload -FilePath 'scripts/d.ps1') -RepositoryRoot '/repo' -HookSeams $seams)
            $parsed = $result[-2] | ConvertFrom-Json

            [int]$result[-1] | Should -Be 0
            $parsed.hookSpecificOutput.permissionDecision | Should -Be 'deny'
            $parsed.hookSpecificOutput.permissionDecisionReason | Should -BeLike 'POWERSHELL_LARGE_PATH_REQUIRED:*'
            ($parsed.PSObject.Properties.Name -contains 'state') | Should -BeFalse
        }

        It 'returns exit code 2 and writes stderr for an empty payload' {
            $originalError = [System.Console]::Error
            $errorWriter = [System.IO.StringWriter]::new()
            try {
                [System.Console]::SetError($errorWriter)
                $result = @(Invoke-PowerShellBatchBudgetCodexEntryPoint -PayloadRaw '' -RepositoryRoot '/repo' -HookSeams (Get-CodexRoutingSeam -IncludeCheckpoint))
            } finally {
                [System.Console]::SetError($originalError)
            }

            [int]$result[-1] | Should -Be 2
            $errorWriter.ToString() | Should -Match 'enforce-powershell-batch-budget hook input is empty'
        }
    }
}
