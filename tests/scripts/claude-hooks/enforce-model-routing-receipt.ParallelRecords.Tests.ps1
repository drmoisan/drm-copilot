#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

<#
.SYNOPSIS
    Parallel records leg of the model-routing receipt gate (issue #1182).

.DESCRIPTION
    Drives Invoke-ModelRoutingReceiptDecision for the Run Closing Agent(pr-author) delegation of a
    parallel run. The resolution seam Resolve-ModelRoutingWorktreeTarget returns the synthetic
    coordinator root /synthetic-worktrees/coordinator, Get-ModelRoutingCheckpoint returns $null (no
    per-feature checkpoint), and the hook-scope mock of Get-WorktreeRunCheckpointText returns the
    in-memory parallel checkpoint for the parallel checkpoint path and $null for any other path. The
    pr-author receipt model is computed in Arrange by Resolve-DelegationModel. No row creates a
    file, starts a process, reads a clock, or reads the process working directory.
#>

BeforeAll {
    $script:HookRoot = (Resolve-Path "$PSScriptRoot/../../../.claude").Path
    . (Join-Path $script:HookRoot 'hooks/enforce-model-routing-receipt.ps1')
    . (Join-Path $PSScriptRoot 'EpicStateIsolation.Baseline.Helpers.ps1')
    Register-EpicStateBaselineMock -Seam 'Get-EpicScopeCheckpointText', 'Get-WorktreeItemCheckpointText', 'Get-WorktreeItemLiveRoot', 'Get-WorktreeRunCheckpointText', 'Get-CleanupWorktreeManifestContent' -Surface 'Claude'
    Mock Find-WorktreeResolutionRoot -ModuleName EpicScopeResolution { '/synthetic-worktrees/main' }
    Mock Get-ModelRoutingCheckpoint { $null }
    Import-Module (Join-Path $script:HookRoot 'lib/model-routing/ModelRouting.psm1') -ErrorAction Stop

    $script:Coordinator = '/synthetic-worktrees/coordinator'
    $script:Slug = 'demo-run'
    $script:Blocked = "MODEL_ROUTING_RECEIPT_BLOCKED: cannot delegate to 'pr-author' before a model_routing_receipts entry for it is recorded in the orchestrator checkpoint. Perform Model Selection (record the complexity assessment and routing receipt) before delegating."
    $script:Prompt = "Open the Run Closing records pull request of the parallel run.`nbranch: parallel/demo-run-plan"

    function New-ParallelRecordsReceipt {
        [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '', Justification = 'Pure in-memory fixture factory in a test file; it changes no system state.')]
        param([string] $Agent = 'pr-author', [string] $Band = 'C2', [string] $FablePolicy = 'disabled')
        $resolved = Resolve-DelegationModel -Agent $Agent -Band $Band -FablePolicy $FablePolicy
        return [ordered]@{ agent = $Agent; phase = 'run_closing_records'; complexity_band = $Band; fable_policy = $FablePolicy; table_model = $resolved['table_model']; clamped_from = $resolved['clamped_from']; model = $resolved['model'] }
    }

    function New-ParallelRecordsCheckpointText {
        [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '', Justification = 'Pure in-memory fixture factory in a test file; it changes no system state.')]
        param(
            [string] $RouteId = 'parallel',
            [string] $Slug = 'demo-run',
            [AllowNull()][object] $Items = $null,
            [AllowNull()][object] $Receipts = $null,
            [switch] $OmitReceipts
        )
        $itemList = if ($null -ne $Items) { $Items } else { @([ordered]@{ issue_num = 101; state = 'merged'; merge_status = 'merged' }, [ordered]@{ issue_num = 102; state = 'withdrawn'; merge_status = 'not_started' }) }
        $checkpoint = [ordered]@{ route_id = $RouteId; parallel_slug = $Slug; items = @($itemList) }
        if (-not $OmitReceipts) {
            # Assigned, not emitted from an if expression, so a one-element list stays a list.
            if ($null -eq $Receipts) { $Receipts = @(New-ParallelRecordsReceipt) }
            $checkpoint['model_routing_receipts'] = $Receipts
        }
        return ($checkpoint | ConvertTo-Json -Depth 8 -Compress)
    }

    function Set-ParallelRecordsRoutingFixture {
        [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '', Justification = 'Registers Pester mocks for one test only; it changes no system state.')]
        param([AllowNull()][object] $CheckpointText = (New-ParallelRecordsCheckpointText), [string] $Status = 'OtherWorktree')
        $target = [pscustomobject]@{ Status = $Status; WorktreeRoot = $script:Coordinator; ReasonCode = $null; Detail = 'synthetic coordinator root' }
        $parallelText = $CheckpointText
        Mock Resolve-ModelRoutingWorktreeTarget { $target }.GetNewClosure()
        Mock Get-ModelRoutingCheckpoint { $null }
        Mock Get-ModelRoutingDocsEstateFileText { $null }
        Mock Get-EpicScopeWorktreeHeadBranch { 'parallel/demo-run-plan' }
        Mock Get-WorktreeRunCheckpointText { $null }
        Mock Get-WorktreeRunCheckpointText -ParameterFilter { ([string]$Path -replace '\\', '/').EndsWith('/parallel-orchestrator-state.json', [System.StringComparison]::Ordinal) } -MockWith ({ $parallelText }.GetNewClosure())
    }

    function New-ParallelRecordsAgentPayload {
        [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '', Justification = 'Pure in-memory payload factory in a test file; it changes no system state.')]
        param([string] $Prompt = $script:Prompt, [string] $Subagent = 'pr-author')
        return (@{ tool_name = 'Agent'; tool_input = @{ subagent_type = $Subagent; prompt = $Prompt } } | ConvertTo-Json -Depth 5 -Compress)
    }

    function Get-ParallelRecordsRoutingDecision {
        param([string] $Prompt = $script:Prompt, [string] $Subagent = 'pr-author')
        return (Invoke-ModelRoutingReceiptDecision -ToolInputRaw (New-ParallelRecordsAgentPayload -Prompt $Prompt -Subagent $Subagent))
    }
}

AfterAll {
    # Remove the top-level functions of the dot-sourced gate and of the leg files it loads.
    foreach ($file in @('enforce-model-routing-receipt.ps1', 'enforce-model-routing-receipt-docs.ps1', 'enforce-model-routing-receipt-parallel.ps1', 'hook-parallel-records-context.ps1', 'hook-docs-estate-context.ps1') | ForEach-Object { Join-Path $script:HookRoot "hooks/$_" }) {
        if (-not (Test-Path -LiteralPath $file -PathType Leaf)) { continue }
        $tokens = $null
        $parseErrors = $null
        $ast = [System.Management.Automation.Language.Parser]::ParseFile($file, [ref]$tokens, [ref]$parseErrors)
        foreach ($definition in $ast.FindAll({ param($node) $node -is [System.Management.Automation.Language.FunctionDefinitionAst] }, $false)) {
            Remove-Item -LiteralPath ('Function:\' + $definition.Name) -ErrorAction SilentlyContinue
        }
    }
}

Describe 'model-routing gate parallel records leg (issue #1182)' {
    BeforeEach {
        Set-ParallelRecordsRoutingFixture
    }

    It 'baseline mock interception probe' { Invoke-EpicStateInterceptionProbe -Surface 'Claude' -Seam 'Get-EpicScopeCheckpointText', 'Get-WorktreeItemCheckpointText', 'Get-WorktreeItemLiveRoot', 'Get-WorktreeRunCheckpointText' }

    Context 'allowed delegation' {
        It 'AC-1 allows Agent(pr-author) for a closed parallel run with a valid pr-author receipt' {
            # Act
            $decision = Get-ParallelRecordsRoutingDecision

            # Assert
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'allow' -Because "reason: $($decision.hookSpecificOutput.permissionDecisionReason)"
        }
    }
}
