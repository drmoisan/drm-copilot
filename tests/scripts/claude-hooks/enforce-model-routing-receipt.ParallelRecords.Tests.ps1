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

    function Assert-ParallelRecordsRoutingDeny {
        param([Parameter(Mandatory)] $Decision, [Parameter(Mandatory)] [string] $SubCode)
        $reason = [string]$Decision.hookSpecificOutput.permissionDecisionReason
        $Decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
        $reason.StartsWith("MODEL_ROUTING_RECEIPT_BLOCKED: cannot delegate to 'pr-author' before a model_routing_receipts entry", [System.StringComparison]::Ordinal) | Should -BeTrue -Because "the reason '$reason' must start with the unchanged base text"
        $reason.Contains(" Parallel records leg not applied: $($SubCode): ") | Should -BeTrue -Because "the reason '$reason' must carry $SubCode"
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

    Context 'denials with a parallel records sub-code' {
        It 'AC-2 denies PARALLEL_RECORDS_SLUG_MISMATCH when <Field> differs' -ForEach @(
            @{ Field = 'parallel_slug'; RouteId = 'parallel'; Slug = 'other-run' }
            @{ Field = 'route_id'; RouteId = 'epic'; Slug = 'demo-run' }
        ) {
            # Arrange
            Set-ParallelRecordsRoutingFixture -CheckpointText (New-ParallelRecordsCheckpointText -RouteId $RouteId -Slug $Slug)

            # Act and Assert
            Assert-ParallelRecordsRoutingDeny -Decision (Get-ParallelRecordsRoutingDecision) -SubCode 'PARALLEL_RECORDS_SLUG_MISMATCH'
        }

        It 'AC-3 denies PARALLEL_RECORDS_RUN_NOT_CLOSED for <Case>' -ForEach @(
            @{ Case = 'a pr_open item'; Items = @([ordered]@{ issue_num = 101; state = 'merged'; merge_status = 'merged' }, [ordered]@{ issue_num = 103; state = 'in_flight'; merge_status = 'pr_open' }) }
            @{ Case = 'a ci_green item'; Items = @([ordered]@{ issue_num = 104; state = 'in_flight'; merge_status = 'ci_green' }) }
            @{ Case = 'an item without merge_status'; Items = @([ordered]@{ issue_num = 105; state = 'scheduled' }) }
        ) {
            # Arrange
            Set-ParallelRecordsRoutingFixture -CheckpointText (New-ParallelRecordsCheckpointText -Items $Items)

            # Act and Assert
            Assert-ParallelRecordsRoutingDeny -Decision (Get-ParallelRecordsRoutingDecision) -SubCode 'PARALLEL_RECORDS_RUN_NOT_CLOSED'
        }

        It 'AC-3 denies PARALLEL_RECORDS_RUN_NOT_CLOSED for an empty items list' {
            # Arrange
            Set-ParallelRecordsRoutingFixture -CheckpointText '{"route_id":"parallel","parallel_slug":"demo-run","items":[]}'

            # Act and Assert
            Assert-ParallelRecordsRoutingDeny -Decision (Get-ParallelRecordsRoutingDecision) -SubCode 'PARALLEL_RECORDS_RUN_NOT_CLOSED'
        }

        It 'AC-3 allows when the only open item is withdrawn with merge_status not_started' {
            # Arrange
            $items = @([ordered]@{ issue_num = 101; state = 'merged'; merge_status = 'worktree_removed' }, [ordered]@{ issue_num = 102; state = 'withdrawn'; merge_status = 'not_started' })
            Set-ParallelRecordsRoutingFixture -CheckpointText (New-ParallelRecordsCheckpointText -Items $items)

            # Act
            $decision = Get-ParallelRecordsRoutingDecision

            # Assert
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'allow' -Because "reason: $($decision.hookSpecificOutput.permissionDecisionReason)"
        }

        It 'AC-4 denies PARALLEL_RECORDS_RECEIPT_MISSING with the remedy for <Case>' -ForEach @(
            @{ Case = 'an absent model_routing_receipts key'; Omit = $true }
            @{ Case = 'receipts with no pr-author entry'; Omit = $false }
        ) {
            # Arrange
            $text = if ($Omit) { New-ParallelRecordsCheckpointText -OmitReceipts } else { New-ParallelRecordsCheckpointText -Receipts @(New-ParallelRecordsReceipt -Agent 'atomic-planner') }
            Set-ParallelRecordsRoutingFixture -CheckpointText $text

            # Act
            $decision = Get-ParallelRecordsRoutingDecision

            # Assert
            Assert-ParallelRecordsRoutingDeny -Decision $decision -SubCode 'PARALLEL_RECORDS_RECEIPT_MISSING'
            [string]$decision.hookSpecificOutput.permissionDecisionReason | Should -BeLike '*record a pr-author entry in model_routing_receipts of the parallel checkpoint before delegating*'
        }

        It 'AC-5 denies PARALLEL_RECORDS_RECEIPT_INVALID with the first validator error for <Case>' -ForEach @(
            @{ Case = 'a model that differs from Resolve-DelegationModel'; Field = 'model'; Value = 'haiku-other'; Error = 'Checkpoint model_routing_receipts #0 model haiku-other does not equal resolve_delegation_model' }
            @{ Case = 'a complexity_band outside C1 to C4'; Field = 'complexity_band'; Value = 'C9'; Error = 'Checkpoint model_routing_receipts #0 complexity_band must be one of C1, C2, C3, C4' }
        ) {
            # Arrange
            $receipt = New-ParallelRecordsReceipt
            $receipt[$Field] = $Value
            Set-ParallelRecordsRoutingFixture -CheckpointText (New-ParallelRecordsCheckpointText -Receipts @($receipt))

            # Act
            $decision = Get-ParallelRecordsRoutingDecision

            # Assert
            Assert-ParallelRecordsRoutingDeny -Decision $decision -SubCode 'PARALLEL_RECORDS_RECEIPT_INVALID'
            [string]$decision.hookSpecificOutput.permissionDecisionReason | Should -BeLike "*PARALLEL_RECORDS_RECEIPT_INVALID: $Error*"
        }

        It 'AC-5 denies PARALLEL_RECORDS_RECEIPT_INVALID when model_routing_receipts is not a list' {
            # Arrange
            Set-ParallelRecordsRoutingFixture -CheckpointText (New-ParallelRecordsCheckpointText -Receipts (New-ParallelRecordsReceipt))

            # Act
            $decision = Get-ParallelRecordsRoutingDecision

            # Assert
            Assert-ParallelRecordsRoutingDeny -Decision $decision -SubCode 'PARALLEL_RECORDS_RECEIPT_INVALID'
            [string]$decision.hookSpecificOutput.permissionDecisionReason | Should -BeLike '*PARALLEL_RECORDS_RECEIPT_INVALID: Checkpoint model_routing_receipts must be a list when present.'
        }

        It 'AC-6 denies PARALLEL_RECORDS_CHECKPOINT_UNREADABLE for <Case>' -ForEach @(
            @{ Case = 'an absent checkpoint'; Text = $null }
            @{ Case = 'a blank checkpoint'; Text = ' ' }
            @{ Case = 'invalid JSON'; Text = '{"route_id":' }
            @{ Case = 'a JSON array'; Text = '[{"route_id":"parallel"}]' }
        ) {
            # Arrange
            Set-ParallelRecordsRoutingFixture -CheckpointText $Text

            # Act and Assert
            Assert-ParallelRecordsRoutingDeny -Decision (Get-ParallelRecordsRoutingDecision) -SubCode 'PARALLEL_RECORDS_CHECKPOINT_UNREADABLE'
        }
    }

    Context 'AC-7 unchanged behavior' {
        It '(a) decides through the per-feature receipt and never reads the parallel checkpoint' {
            # Arrange
            $checkpoint = [pscustomobject]@{ model_routing_receipts = @([pscustomobject]@{ agent = 'pr-author' }) }
            Mock Get-ModelRoutingCheckpoint { $checkpoint }.GetNewClosure()

            # Act
            $decision = Get-ParallelRecordsRoutingDecision

            # Assert
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'allow'
            Should -Invoke Get-WorktreeRunCheckpointText -Times 0 -Exactly
        }

        It '(b) decides an epic integration-branch label through epic scope' {
            # Arrange
            $epicPath = '/synthetic-worktrees/epic/artifacts/orchestration/epic-state.json'
            Mock Resolve-EpicScopeCheckpoint { [pscustomobject]@{ IsEpicScope = $true; Checkpoint = $null; CheckpointPath = $epicPath } }.GetNewClosure()

            # Act
            $decision = Get-ParallelRecordsRoutingDecision -Prompt "Open the integration pull request.`nbranch: epic/demo-integration"

            # Assert
            [string]$decision.hookSpecificOutput.permissionDecisionReason | Should -BeExactly "MODEL_ROUTING_RECEIPT_BLOCKED: cannot delegate to 'pr-author' in epic scope before a model_routing_receipts entry for it is recorded in $epicPath; the failed readiness predicate is 'model_routing_receipts'."
            Should -Invoke Get-WorktreeRunCheckpointText -Times 0 -Exactly
        }

        It '(<Case>) keeps the deny text byte-identical with no parallel suffix' -ForEach @(
            @{ Case = 'c a non-parallel label'; Prompt = "Open the pull request.`nbranch: feature/x" }
            @{ Case = 'd a parallel label without the -plan suffix'; Prompt = "Open the pull request.`nbranch: parallel/demo-run" }
            @{ Case = 'e two branch lines'; Prompt = "branch: parallel/demo-run-plan`nbranch: parallel/demo-run-plan" }
            @{ Case = 'a --head token that names another branch first'; Prompt = "Use --head feature/other.`nbranch: parallel/demo-run-plan" }
        ) {
            # Act
            $decision = Get-ParallelRecordsRoutingDecision -Prompt $Prompt

            # Assert
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
            [string]$decision.hookSpecificOutput.permissionDecisionReason | Should -BeExactly $script:Blocked
            Should -Invoke Get-WorktreeRunCheckpointText -Times 0 -Exactly
        }

        It '(f) denies atomic-planner with a valid plan label and checkpoint with today''s text' {
            # Act
            $decision = Get-ParallelRecordsRoutingDecision -Subagent 'atomic-planner'

            # Assert
            [string]$decision.hookSpecificOutput.permissionDecisionReason | Should -BeExactly $script:Blocked.Replace("'pr-author'", "'atomic-planner'")
            Should -Invoke Get-WorktreeRunCheckpointText -Times 0 -Exactly
        }

        It '(g) denies a <Status> resolution with the resolver code unchanged' -ForEach @(
            @{ Status = 'NoTarget'; Code = 'SYNTHETIC_NO_TARGET' }
            @{ Status = 'Ambiguous'; Code = 'SYNTHETIC_AMBIGUOUS' }
        ) {
            # Arrange
            $target = [pscustomobject]@{ Status = $Status; WorktreeRoot = $null; ReasonCode = $Code; Detail = 'synthetic detail.' }
            Mock Resolve-ModelRoutingWorktreeTarget { $target }.GetNewClosure()
            $expected = "$($Code): synthetic detail. The model-routing gate will not check this delegation against a checkpoint that may belong to a different item. Put the line 'Canonical issue number for this feature is <N>.' and a 'branch: <item branch>' label in the delegation prompt so the gate can identify the item."

            # Act
            $decision = Get-ParallelRecordsRoutingDecision

            # Assert
            [string]$decision.hookSpecificOutput.permissionDecisionReason | Should -BeExactly $expected
            Should -Invoke Get-WorktreeRunCheckpointText -Times 0 -Exactly
        }

        It '(h) keeps the cleanup delegation allowed' {
            # Arrange
            Mock Test-ModelRoutingCleanupDelegation { $true }

            # Act
            $decision = Get-ParallelRecordsRoutingDecision -Prompt "Open the consolidation pull request.`nbranch: documentationandmemories"

            # Assert
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'allow'
        }

        It '(h) keeps a docs-estate allow when the parallel leg declines' {
            # Arrange
            Set-ParallelRecordsRoutingFixture -CheckpointText $null
            Mock Get-ModelRoutingDocsEstateDecision { [pscustomobject]@{ Allowed = $true; DenySuffix = '' } }

            # Act
            $decision = Get-ParallelRecordsRoutingDecision

            # Assert
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'allow'
        }

        It '(h) places the docs suffix last, after the parallel suffix' {
            # Arrange
            Set-ParallelRecordsRoutingFixture -CheckpointText (New-ParallelRecordsCheckpointText -OmitReceipts)
            Mock Get-ModelRoutingDocsEstateDecision { [pscustomobject]@{ Allowed = $false; DenySuffix = ' Docs-estate delegation leg not applied: DOCS_DELEGATION_PROFILE_INVALID: synthetic.' } }

            # Act
            $reason = [string](Get-ParallelRecordsRoutingDecision).hookSpecificOutput.permissionDecisionReason

            # Assert
            $reason.StartsWith("$($script:Blocked) Parallel records leg not applied: PARALLEL_RECORDS_RECEIPT_MISSING: ", [System.StringComparison]::Ordinal) | Should -BeTrue -Because $reason
            $reason.EndsWith(' Docs-estate delegation leg not applied: DOCS_DELEGATION_PROFILE_INVALID: synthetic.', [System.StringComparison]::Ordinal) | Should -BeTrue -Because $reason
        }
    }

    Context 'AC-8 never throws' {
        It 'declines with an empty suffix and keeps today''s deny text when the checkpoint seam throws' {
            # Arrange
            # A filtered mock defined later is evaluated before the fixture's path-filtered mock.
            Mock Get-WorktreeRunCheckpointText -ParameterFilter { $true } -MockWith { throw [System.IO.IOException]::new('locked') }

            # Act
            $leg = Get-ModelRoutingParallelRecordsDecision -PromptText $script:Prompt -WorktreeRoot $script:Coordinator
            $decision = Get-ParallelRecordsRoutingDecision

            # Assert
            $leg.Allowed | Should -BeFalse
            $leg.DenySuffix | Should -BeExactly ''
            [string]$decision.hookSpecificOutput.permissionDecisionReason | Should -BeExactly $script:Blocked
        }

        It 'declines with an empty suffix for a blank worktree root' {
            # Act
            $leg = Get-ModelRoutingParallelRecordsDecision -PromptText $script:Prompt -WorktreeRoot ''

            # Assert
            $leg.Allowed | Should -BeFalse
            $leg.DenySuffix | Should -BeExactly ''
            Should -Invoke Get-WorktreeRunCheckpointText -Times 0 -Exactly
        }
    }
}
