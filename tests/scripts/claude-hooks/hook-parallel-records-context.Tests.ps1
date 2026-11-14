#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

<#
.SYNOPSIS
    Shared pure predicates of the parallel records legs (issue #1182).

.DESCRIPTION
    Drives Get-ParallelRecordsSlug and Get-ParallelRecordsCheckpointDecision of
    .claude/hooks/hook-parallel-records-context.ps1 with in-memory checkpoint texts. The pr-author
    receipt model is computed in Arrange by Resolve-DelegationModel. No row creates a file, starts a
    process, reads a clock, or reads the process working directory.
#>

BeforeAll {
    $script:HookRoot = (Resolve-Path "$PSScriptRoot/../../../.claude").Path
    Import-Module (Join-Path $script:HookRoot 'lib/orchestrator-state/OrchestratorStateModelReceipts.psm1') -ErrorAction Stop
    Import-Module (Join-Path $script:HookRoot 'lib/model-routing/ModelRouting.psm1') -ErrorAction Stop
    . (Join-Path $script:HookRoot 'hooks/hook-parallel-records-context.ps1')

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
}

AfterAll {
    foreach ($name in @('Get-ParallelRecordsSlug', 'Get-ParallelRecordsProperty', 'Get-ParallelRecordsClosedFailure', 'Get-ParallelRecordsReceiptFailure', 'Get-ParallelRecordsCheckpointDecision')) {
        Remove-Item -LiteralPath ('Function:\' + $name) -ErrorAction SilentlyContinue
    }
}

Describe 'Get-ParallelRecordsSlug (issue #1182)' {
    It 'returns <Expected> for <Branch>' -ForEach @(
        @{ Branch = 'parallel/a-plan'; Expected = 'a' }
        @{ Branch = 'parallel/a.b_c-plan'; Expected = 'a.b_c' }
        @{ Branch = 'parallel/demo-run-plan'; Expected = 'demo-run' }
    ) {
        # Act
        $slug = Get-ParallelRecordsSlug -BranchName $Branch

        # Assert
        $slug | Should -BeExactly $Expected
    }

    It 'returns $null for <Branch>' -ForEach @(
        @{ Branch = 'parallel/-plan' }
        @{ Branch = 'parallel/a' }
        @{ Branch = 'Parallel/a-plan' }
        @{ Branch = 'feature/a-plan' }
        @{ Branch = '' }
    ) {
        # Act
        $slug = Get-ParallelRecordsSlug -BranchName $Branch

        # Assert
        $slug | Should -BeNullOrEmpty
    }
}

Describe 'Get-ParallelRecordsCheckpointDecision (issue #1182)' {
    Context 'allowed checkpoints' {
        It 'allows a closed run whose withdrawn not_started item is ignored and whose pr-author receipt is valid' {
            # Act
            $decision = Get-ParallelRecordsCheckpointDecision -CheckpointText (New-ParallelRecordsCheckpointText) -Slug 'demo-run'

            # Assert
            $decision.Allowed | Should -BeTrue -Because "detail: $($decision.Detail)"
            $decision.SubCode | Should -BeNullOrEmpty
        }

        It 'allows a worktree_removed item and a valid second pr-author receipt after an invalid one' {
            # Arrange
            $items = @([ordered]@{ issue_num = 101; state = 'merged'; merge_status = 'worktree_removed' })
            $bad = New-ParallelRecordsReceipt
            $bad['model'] = 'not-a-model'
            $text = New-ParallelRecordsCheckpointText -Items $items -Receipts @($bad, (New-ParallelRecordsReceipt))

            # Act
            $decision = Get-ParallelRecordsCheckpointDecision -CheckpointText $text -Slug 'demo-run'

            # Assert
            $decision.Allowed | Should -BeTrue -Because "detail: $($decision.Detail)"
        }
    }

    Context 'PARALLEL_RECORDS_CHECKPOINT_UNREADABLE' {
        It 'denies <Case>' -ForEach @(
            @{ Case = 'absent text'; Text = $null }
            @{ Case = 'blank text'; Text = '   ' }
            @{ Case = 'invalid JSON'; Text = '{"route_id":' }
            @{ Case = 'a JSON array'; Text = '[{"route_id":"parallel"}]' }
        ) {
            # Act
            $decision = Get-ParallelRecordsCheckpointDecision -CheckpointText $Text -Slug 'demo-run'

            # Assert
            $decision.Allowed | Should -BeFalse
            $decision.SubCode | Should -BeExactly 'PARALLEL_RECORDS_CHECKPOINT_UNREADABLE'
        }
    }

    Context 'PARALLEL_RECORDS_SLUG_MISMATCH' {
        It 'denies a route_id other than parallel and names the field' {
            # Act
            $decision = Get-ParallelRecordsCheckpointDecision -CheckpointText (New-ParallelRecordsCheckpointText -RouteId 'epic') -Slug 'demo-run'

            # Assert
            $decision.SubCode | Should -BeExactly 'PARALLEL_RECORDS_SLUG_MISMATCH'
            $decision.Detail | Should -BeExactly "route_id records 'epic', not 'parallel'."
        }

        It 'denies a parallel_slug that differs only in case and names the recorded value' {
            # Act
            $decision = Get-ParallelRecordsCheckpointDecision -CheckpointText (New-ParallelRecordsCheckpointText -Slug 'Demo-Run') -Slug 'demo-run'

            # Assert
            $decision.SubCode | Should -BeExactly 'PARALLEL_RECORDS_SLUG_MISMATCH'
            $decision.Detail | Should -BeExactly "parallel_slug records 'Demo-Run', not 'demo-run'."
        }
    }

    Context 'PARALLEL_RECORDS_RUN_NOT_CLOSED' {
        It 'denies <Case>' -ForEach @(
            @{ Case = 'a pr_open item'; Items = @([ordered]@{ issue_num = 101; state = 'merged'; merge_status = 'merged' }, [ordered]@{ issue_num = 103; state = 'in_flight'; merge_status = 'pr_open' }); Detail = "item 103 has merge_status 'pr_open'; every item that is not withdrawn must be merged or worktree_removed." }
            @{ Case = 'a ci_green item'; Items = @([ordered]@{ issue_num = 104; state = 'in_flight'; merge_status = 'ci_green' }); Detail = "item 104 has merge_status 'ci_green'; every item that is not withdrawn must be merged or worktree_removed." }
            @{ Case = 'an item without merge_status'; Items = @([ordered]@{ issue_num = 105; state = 'scheduled' }); Detail = "item 105 has merge_status 'not_started'; every item that is not withdrawn must be merged or worktree_removed." }
            @{ Case = 'an items entry that is not an object'; Items = @(7); Detail = 'an items entry is not an object.' }
        ) {
            # Act
            $decision = Get-ParallelRecordsCheckpointDecision -CheckpointText (New-ParallelRecordsCheckpointText -Items $Items) -Slug 'demo-run'

            # Assert
            $decision.SubCode | Should -BeExactly 'PARALLEL_RECORDS_RUN_NOT_CLOSED'
            $decision.Detail | Should -BeExactly $Detail
        }

        It 'denies an empty items list' {
            # Arrange
            $text = '{"route_id":"parallel","parallel_slug":"demo-run","items":[],"model_routing_receipts":[]}'

            # Act
            $decision = Get-ParallelRecordsCheckpointDecision -CheckpointText $text -Slug 'demo-run'

            # Assert
            $decision.SubCode | Should -BeExactly 'PARALLEL_RECORDS_RUN_NOT_CLOSED'
            $decision.Detail | Should -BeExactly 'items must be a non-empty list.'
        }
    }

    Context 'PARALLEL_RECORDS_RECEIPT_MISSING' {
        It 'denies <Case>' -ForEach @(
            @{ Case = 'an absent model_routing_receipts key'; Omit = $true; Receipts = $null }
            @{ Case = 'receipts with no pr-author entry'; Omit = $false; Receipts = @([ordered]@{ agent = 'atomic-planner'; phase = 'p'; complexity_band = 'C2'; fable_policy = 'disabled'; table_model = 'opus'; clamped_from = $null; model = 'opus' }) }
        ) {
            # Arrange
            $text = if ($Omit) { New-ParallelRecordsCheckpointText -OmitReceipts } else { New-ParallelRecordsCheckpointText -Receipts $Receipts }

            # Act
            $decision = Get-ParallelRecordsCheckpointDecision -CheckpointText $text -Slug 'demo-run'

            # Assert
            $decision.SubCode | Should -BeExactly 'PARALLEL_RECORDS_RECEIPT_MISSING'
        }
    }

    Context 'PARALLEL_RECORDS_RECEIPT_INVALID' {
        It 'denies a model that differs from Resolve-DelegationModel with the first validator error' {
            # Arrange
            $receipt = New-ParallelRecordsReceipt
            $expected = $receipt['model']
            $receipt['model'] = 'haiku-other'

            # Act
            $decision = Get-ParallelRecordsCheckpointDecision -CheckpointText (New-ParallelRecordsCheckpointText -Receipts @($receipt)) -Slug 'demo-run'

            # Assert
            $decision.SubCode | Should -BeExactly 'PARALLEL_RECORDS_RECEIPT_INVALID'
            $decision.Detail | Should -BeExactly "Checkpoint model_routing_receipts #0 model haiku-other does not equal resolve_delegation_model(agent, complexity_band, fable_policy) $expected."
        }

        It 'denies a complexity_band outside C1 to C4' {
            # Arrange
            $receipt = New-ParallelRecordsReceipt
            $receipt['complexity_band'] = 'C9'

            # Act
            $decision = Get-ParallelRecordsCheckpointDecision -CheckpointText (New-ParallelRecordsCheckpointText -Receipts @($receipt)) -Slug 'demo-run'

            # Assert
            $decision.SubCode | Should -BeExactly 'PARALLEL_RECORDS_RECEIPT_INVALID'
            $decision.Detail | Should -BeLike 'Checkpoint model_routing_receipts #0 complexity_band must be one of C1, C2, C3, C4*'
        }

        It 'denies a model_routing_receipts value that is an object rather than a list' {
            # Arrange
            $text = New-ParallelRecordsCheckpointText -Receipts (New-ParallelRecordsReceipt)

            # Act
            $decision = Get-ParallelRecordsCheckpointDecision -CheckpointText $text -Slug 'demo-run'

            # Assert
            $decision.SubCode | Should -BeExactly 'PARALLEL_RECORDS_RECEIPT_INVALID'
            $decision.Detail | Should -BeExactly 'Checkpoint model_routing_receipts must be a list when present.'
        }
    }

    Context 'never throws' {
        It 'answers PARALLEL_RECORDS_CHECKPOINT_UNREADABLE when the receipt validator throws' {
            # Arrange
            Mock Get-OrchestratorStateModelRoutingReceiptError { throw [System.InvalidOperationException]::new('boom') }

            # Act
            $decision = Get-ParallelRecordsCheckpointDecision -CheckpointText (New-ParallelRecordsCheckpointText) -Slug 'demo-run'

            # Assert
            $decision.Allowed | Should -BeFalse
            $decision.SubCode | Should -BeExactly 'PARALLEL_RECORDS_CHECKPOINT_UNREADABLE'
            $decision.Detail | Should -BeExactly 'the parallel checkpoint could not be evaluated.'
        }
    }
}

Describe 'parallel records legs call the shared predicate (issue #1182, AC-13)' {
    It '<File> contains a command call named Get-ParallelRecordsCheckpointDecision' -ForEach @(
        @{ File = 'enforce-model-routing-receipt-parallel.ps1' }
        @{ File = 'enforce-orchestration-preimplementation-gate-parallel-records.ps1' }
    ) {
        # Arrange: parse the committed leg file without executing it.
        $repoRoot = (Resolve-Path "$PSScriptRoot/../../..").Path
        $path = Join-Path $repoRoot ".claude/hooks/$File"
        $tokens = $null
        $parseErrors = $null
        $ast = [System.Management.Automation.Language.Parser]::ParseFile($path, [ref]$tokens, [ref]$parseErrors)

        # Act
        $calls = @($ast.FindAll({
                    param($node)
                    $node -is [System.Management.Automation.Language.CommandAst] -and $node.GetCommandName() -ceq 'Get-ParallelRecordsCheckpointDecision'
                }, $true))

        # Assert
        @($parseErrors).Count | Should -Be 0
        $calls.Count | Should -BeGreaterThan 0 -Because "$File must delegate the checkpoint predicate to the shared helper"
    }
}
