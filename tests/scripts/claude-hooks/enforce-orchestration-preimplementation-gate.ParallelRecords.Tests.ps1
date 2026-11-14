#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

<#
.SYNOPSIS
    Parallel records leg of the Claude preimplementation gate (issue #1182).

.DESCRIPTION
    Drives Invoke-OrchestrationPreimplementationGateDecision for the pr-author Write of
    artifacts/pr_body_<N>.receipt.json at a parallel coordinator root. No per-feature checkpoint is
    ready, so the call reaches the deny tail, where the cleanup, bookkeeping, docs-estate, and
    parallel records legs are evaluated.

    Seams: the worktree listing Get-OrchestrationGateWorktreeList returns an in-memory porcelain
    text (the session root on main and /synthetic-worktrees/coordinator on the plan branch); the
    per-feature checkpoint reads return the baseline $null; the hook-scope mock of
    Get-WorktreeRunCheckpointText returns the in-memory parallel checkpoint for the parallel
    checkpoint path and $null for any other path; Get-EpicScopeWorktreeHeadBranch returns a per-row
    branch; Test-OrchestrationDocsEstateCheckpointPresent answers $true so the docs-estate leg
    declines without a disk read. The pr-author receipt model is computed in Arrange by
    Resolve-DelegationModel. No row creates a file, starts a process, reads a clock, or reads the
    process working directory.
#>

BeforeAll {
    $script:HookRoot = (Resolve-Path "$PSScriptRoot/../../../.claude").Path
    . (Join-Path $script:HookRoot 'hooks/enforce-orchestration-preimplementation-gate.ps1')
    . (Join-Path $PSScriptRoot 'EpicStateIsolation.Baseline.Helpers.ps1')
    if (Get-Command Get-WorktreeResolutionGitFileText -ErrorAction SilentlyContinue) { Mock Get-WorktreeResolutionGitFileText { $null } }
    Register-EpicStateBaselineMock -Seam 'Get-EpicScopeCheckpointText', 'Get-WorktreeItemCheckpointText', 'Get-WorktreeItemLiveRoot', 'Get-WorktreeRunCheckpointText' -Surface 'Claude'
    Register-EpicStateBaselineMock -Seam 'Get-CheckpointContent', 'Get-EpicCheckpointContent', 'Get-ParallelCheckpointContent' -Surface 'Codex'
    Import-Module (Join-Path $script:HookRoot 'lib/model-routing/ModelRouting.psm1') -ErrorAction Stop

    $script:Blocked = 'PREIMPLEMENTATION_GATE_BLOCKED: Implementation operations require artifacts/orchestration/orchestrator-state.json to contain issue number, feature folder, route metadata, lifecycle readiness, and checkpoint state before implementation begins.'
    $script:Session = ConvertTo-HookTargetWorktreeNormalizedPath -Path (Get-Location).Path
    $script:Coordinator = '/synthetic-worktrees/coordinator'
    $script:Listing = "worktree $($script:Session)`nbranch refs/heads/main`n`nworktree $($script:Coordinator)`nbranch refs/heads/parallel/demo-run-plan`n"
    $script:RelativeReceipt = 'artifacts/pr_body_77.receipt.json'
    $script:AbsoluteReceipt = '/synthetic-worktrees/coordinator/artifacts/pr_body_77.receipt.json'

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

    function Set-ParallelRecordsGateFixture {
        [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '', Justification = 'Registers Pester mocks for one test only; it changes no system state.')]
        param(
            [AllowNull()][object] $CheckpointText = (New-ParallelRecordsCheckpointText),
            [AllowNull()][object] $ItemCheckpointText = $null,
            [AllowNull()][object] $HeadBranch = 'parallel/demo-run-plan'
        )
        $listingText = $script:Listing
        $parallelText = $CheckpointText
        $itemText = $ItemCheckpointText
        $head = $HeadBranch
        Mock Get-OrchestrationGateWorktreeList { $listingText }.GetNewClosure()
        Mock Test-OrchestrationDocsEstateCheckpointPresent { $true }
        Mock Get-EpicScopeWorktreeHeadBranch { $head }.GetNewClosure()
        Mock Get-WorktreeRunCheckpointText { $null }
        Mock Get-WorktreeRunCheckpointText -ParameterFilter { ([string]$Path -replace '\\', '/').EndsWith('/parallel-orchestrator-state.json', [System.StringComparison]::Ordinal) } -MockWith ({ $parallelText }.GetNewClosure())
        Mock Get-WorktreeRunCheckpointText -ParameterFilter { ([string]$Path -replace '\\', '/').EndsWith('/orchestration/orchestrator-state.json', [System.StringComparison]::Ordinal) } -MockWith ({ $itemText }.GetNewClosure())
    }

    function ConvertTo-ParallelRecordsPayload {
        param([string] $Tool = 'Write', [string] $FilePath = '', [string] $Command = '')
        $toolInput = switch ($Tool) {
            'Write' { @{ file_path = $FilePath; content = '{}' } }
            'Edit' { @{ file_path = $FilePath; old_string = '{}'; new_string = '{"a":1}' } }
            default { @{ command = $Command } }
        }
        return (@{ tool_name = $Tool; tool_input = $toolInput } | ConvertTo-Json -Compress -Depth 5)
    }

    function Get-ParallelRecordsGateDecision {
        param([string] $Payload)
        return (Invoke-OrchestrationPreimplementationGateDecision -ToolInputRaw $Payload)
    }
}

AfterAll {
    # Remove the top-level functions of the dot-sourced gate and of the leg files it loads.
    foreach ($file in @('enforce-orchestration-preimplementation-gate.ps1', 'enforce-orchestration-preimplementation-gate-docs.ps1', 'enforce-orchestration-preimplementation-gate-parallel-records.ps1', 'hook-parallel-records-context.ps1', 'hook-docs-estate-context.ps1') | ForEach-Object { Join-Path $script:HookRoot "hooks/$_" }) {
        if (-not (Test-Path -LiteralPath $file -PathType Leaf)) { continue }
        $tokens = $null
        $parseErrors = $null
        $ast = [System.Management.Automation.Language.Parser]::ParseFile($file, [ref]$tokens, [ref]$parseErrors)
        foreach ($definition in $ast.FindAll({ param($node) $node -is [System.Management.Automation.Language.FunctionDefinitionAst] }, $false)) {
            Remove-Item -LiteralPath ('Function:\' + $definition.Name) -ErrorAction SilentlyContinue
        }
    }
}

Describe 'Claude preimplementation gate parallel records leg (issue #1182)' {
    BeforeEach {
        Set-ParallelRecordsGateFixture
    }

    It 'baseline mock interception probe' { Invoke-EpicStateInterceptionProbe -Surface 'Claude' -Seam 'Get-EpicScopeCheckpointText', 'Get-WorktreeItemCheckpointText', 'Get-WorktreeItemLiveRoot', 'Get-WorktreeRunCheckpointText' }

    Context 'allowed receipt Write' {
        It 'AC-9 allows the receipt Write by relative path at a closed parallel coordinator root' {
            # Act
            $decision = Get-ParallelRecordsGateDecision -Payload (ConvertTo-ParallelRecordsPayload -FilePath $script:RelativeReceipt)

            # Assert
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'allow' -Because "reason: $($decision.hookSpecificOutput.permissionDecisionReason)"
        }

        It 'AC-9 allows the receipt Write by absolute path at a closed parallel coordinator root' {
            # Act
            $decision = Get-ParallelRecordsGateDecision -Payload (ConvertTo-ParallelRecordsPayload -FilePath $script:AbsoluteReceipt)

            # Assert
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'allow' -Because "reason: $($decision.hookSpecificOutput.permissionDecisionReason)"
        }
    }
}
