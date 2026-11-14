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

    Context 'AC-10 denials with a parallel records sub-code' {
        It 'denies <SubCode> after the unchanged deny text' -ForEach @(
            @{ SubCode = 'PARALLEL_RECORDS_CHECKPOINT_UNREADABLE'; Text = '[1]' }
            @{ SubCode = 'PARALLEL_RECORDS_SLUG_MISMATCH'; Text = 'slug' }
            @{ SubCode = 'PARALLEL_RECORDS_RUN_NOT_CLOSED'; Text = 'open' }
            @{ SubCode = 'PARALLEL_RECORDS_RECEIPT_MISSING'; Text = 'missing' }
            @{ SubCode = 'PARALLEL_RECORDS_RECEIPT_INVALID'; Text = 'invalid' }
        ) {
            # Arrange
            $badReceipt = New-ParallelRecordsReceipt
            $badReceipt['model'] = 'haiku-other'
            $checkpointText = switch ($Text) {
                'slug' { New-ParallelRecordsCheckpointText -Slug 'other-run' }
                'open' { New-ParallelRecordsCheckpointText -Items @([ordered]@{ issue_num = 103; state = 'in_flight'; merge_status = 'pr_open' }) }
                'missing' { New-ParallelRecordsCheckpointText -OmitReceipts }
                'invalid' { New-ParallelRecordsCheckpointText -Receipts @($badReceipt) }
                default { $Text }
            }
            Set-ParallelRecordsGateFixture -CheckpointText $checkpointText

            # Act
            $reason = [string](Get-ParallelRecordsGateDecision -Payload (ConvertTo-ParallelRecordsPayload -FilePath $script:RelativeReceipt)).hookSpecificOutput.permissionDecisionReason

            # Assert
            $reason.StartsWith("$($script:Blocked) Parallel records leg not applied: $($SubCode): ", [System.StringComparison]::Ordinal) | Should -BeTrue -Because "the reason '$reason' must carry $SubCode after the unchanged text and the empty cleanup, bookkeeping, and docs suffixes"
        }
    }

    Context 'AC-11 unchanged behavior' {
        It '(<Case>) keeps the deny text byte-identical with no parallel suffix' -ForEach @(
            @{ Case = 'a an Edit of the receipt path'; Tool = 'Edit'; Path = 'artifacts/pr_body_77.receipt.json' }
            @{ Case = 'b a Write of artifacts/other.json'; Tool = 'Write'; Path = 'artifacts/other.json' }
            @{ Case = 'b a Write of scripts/x.ps1'; Tool = 'Write'; Path = 'scripts/x.ps1' }
            @{ Case = 'b an absolute Write of another implementation path'; Tool = 'Write'; Path = '/synthetic-worktrees/coordinator/artifacts/other.json' }
            @{ Case = 'c a Write whose path differs only in case'; Tool = 'Write'; Path = 'artifacts/PR_BODY_5.receipt.json' }
            @{ Case = 'an absolute receipt Write outside every registered root'; Tool = 'Write'; Path = '/synthetic-worktrees/unlisted/artifacts/pr_body_77.receipt.json' }
        ) {
            # Act
            $decision = Get-ParallelRecordsGateDecision -Payload (ConvertTo-ParallelRecordsPayload -Tool $Tool -FilePath $Path)

            # Assert
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
            [string]$decision.hookSpecificOutput.permissionDecisionReason | Should -BeExactly $script:Blocked
            Should -Invoke Get-WorktreeRunCheckpointText -Times 0 -Exactly -ParameterFilter { ([string]$Path -replace '\\', '/').EndsWith('/parallel-orchestrator-state.json', [System.StringComparison]::Ordinal) }
        }

        It '(d) keeps the deny text byte-identical when the HEAD branch of R is <Head>' -ForEach @(
            @{ Head = 'main' }
            @{ Head = 'parallel/demo-run' }
        ) {
            # Arrange
            Set-ParallelRecordsGateFixture -HeadBranch $Head

            # Act
            $decision = Get-ParallelRecordsGateDecision -Payload (ConvertTo-ParallelRecordsPayload -FilePath $script:RelativeReceipt)

            # Assert
            [string]$decision.hookSpecificOutput.permissionDecisionReason | Should -BeExactly $script:Blocked
        }

        It '(e) keeps the deny text byte-identical when a per-feature checkpoint exists beneath R' {
            # Arrange
            Set-ParallelRecordsGateFixture -ItemCheckpointText '{"issue-num":"5"}'

            # Act
            $decision = Get-ParallelRecordsGateDecision -Payload (ConvertTo-ParallelRecordsPayload -FilePath $script:RelativeReceipt)

            # Assert
            [string]$decision.hookSpecificOutput.permissionDecisionReason | Should -BeExactly $script:Blocked
            Should -Invoke Get-EpicScopeWorktreeHeadBranch -Times 0 -Exactly
        }

        It '(f) never reaches the parallel leg for a command payload' {
            # Act
            $decision = Get-ParallelRecordsGateDecision -Payload (ConvertTo-ParallelRecordsPayload -Tool 'Bash' -Command 'git add -- docs/features/parallel/demo-run/parallel-status.md')

            # Assert
            [string]$decision.hookSpecificOutput.permissionDecisionReason | Should -Not -BeLike '*Parallel records leg*'
            Should -Invoke Get-WorktreeRunCheckpointText -Times 0 -Exactly -ParameterFilter { ([string]$Path -replace '\\', '/').EndsWith('/parallel-orchestrator-state.json', [System.StringComparison]::Ordinal) }
        }

        It '(g) allows the body Write artifacts/pr_body_77.md without reaching the parallel leg' {
            # Act
            $decision = Get-ParallelRecordsGateDecision -Payload (ConvertTo-ParallelRecordsPayload -FilePath 'artifacts/pr_body_77.md')

            # Assert
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'allow'
            Should -Invoke Get-WorktreeRunCheckpointText -Times 0 -Exactly -ParameterFilter { ([string]$Path -replace '\\', '/').EndsWith('/parallel-orchestrator-state.json', [System.StringComparison]::Ordinal) }
            Should -Invoke Get-EpicScopeWorktreeHeadBranch -Times 0 -Exactly
        }
    }

    Context 'AC-12 never throws' {
        It 'declines with an empty suffix and keeps today''s deny text when <Seam> throws' -ForEach @(
            @{ Seam = 'Get-EpicScopeWorktreeHeadBranch' }
            @{ Seam = 'Get-WorktreeRunCheckpointText' }
        ) {
            # Arrange
            Mock $Seam -ParameterFilter { $true } -MockWith { throw [System.IO.IOException]::new('locked') }
            $toolInput = [pscustomobject]@{ file_path = $script:RelativeReceipt; content = '{}' }

            # Act
            $leg = Get-OrchestrationParallelRecordsResult -ToolInput $toolInput -FilePath $script:RelativeReceipt
            $decision = Get-ParallelRecordsGateDecision -Payload (ConvertTo-ParallelRecordsPayload -FilePath $script:RelativeReceipt)

            # Assert
            $leg.Allowed | Should -BeFalse
            $leg.DenySuffix | Should -BeExactly ''
            [string]$decision.hookSpecificOutput.permissionDecisionReason | Should -BeExactly $script:Blocked
        }

        It 'declines with an empty suffix when the worktree listing throws, and the gate keeps its own target-resolution deny' {
            # Arrange: the gate resolves an absolute path's target from the same listing before the
            # deny tail, so today's decision for this payload is that resolver's deny, unchanged.
            Mock Get-OrchestrationGateWorktreeList -ParameterFilter { $true } -MockWith { throw [System.IO.IOException]::new('locked') }
            $toolInput = [pscustomobject]@{ file_path = $script:AbsoluteReceipt; content = '{}' }

            # Act
            $leg = Get-OrchestrationParallelRecordsResult -ToolInput $toolInput -FilePath $script:AbsoluteReceipt
            $decision = Get-ParallelRecordsGateDecision -Payload (ConvertTo-ParallelRecordsPayload -FilePath $script:AbsoluteReceipt)

            # Assert
            $leg.Allowed | Should -BeFalse
            $leg.DenySuffix | Should -BeExactly ''
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
            [string]$decision.hookSpecificOutput.permissionDecisionReason | Should -Not -BeLike '*Parallel records leg*'
        }

        It 'declines with an empty suffix for <Case>' -ForEach @(
            @{ Case = 'a null tool input'; ToolInput = $null; Path = 'artifacts/pr_body_77.receipt.json' }
            @{ Case = 'an empty file path'; ToolInput = [pscustomobject]@{ content = '{}' }; Path = '' }
        ) {
            # Act
            $leg = Get-OrchestrationParallelRecordsResult -ToolInput $ToolInput -FilePath $Path

            # Assert
            $leg.Allowed | Should -BeFalse
            $leg.DenySuffix | Should -BeExactly ''
        }
    }
}
