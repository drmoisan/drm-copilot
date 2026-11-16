#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

<#
.SYNOPSIS
    End-to-end composition of the Run Closing records pull request of a parallel run (issue #1182).

.DESCRIPTION
    One synthetic closed parallel run, demo-run, whose coordinator root (the session root) has
    parallel/demo-run-plan checked out and holds only the
    parallel checkpoint, which records a valid pr-author routing receipt. The four decisions of
    the records pull request are composed in workflow order through the gate entry functions:
    Agent(pr-author) through enforce-model-routing-receipt.ps1, the pr-author receipt Write through
    enforce-orchestration-preimplementation-gate.ps1, gh pr create through
    enforce-pr-author-skill.ps1 (docs-only exemption of issue #901), and gh pr merge through
    enforce-epic-merge-gate.ps1 (docs-only branch of issue #927, because no items[] entry of the
    parallel checkpoint records the records pull request number).

    Every git, gh, and checkpoint read goes through an injected seam. No row creates a file, starts
    a process, reads a clock, or reads the process working directory.
#>

BeforeAll {
    $hookRoot = (Resolve-Path "$PSScriptRoot/../../../.claude/hooks").Path
    . (Join-Path $hookRoot 'enforce-orchestration-preimplementation-gate.ps1')
    . (Join-Path $hookRoot 'enforce-model-routing-receipt.ps1')
    . (Join-Path $hookRoot 'enforce-pr-author-skill.ps1')
    . (Join-Path $hookRoot 'enforce-epic-merge-gate.ps1')
    # Each gate imports OrchestratorStateModelReceipts.psm1 when it starts. Dot-sourcing four gates into
    # one scope lets a later gate's -Force import chain replace that module, so the import a gate
    # performs at its own start is repeated here, after the last dot-source.
    Import-Module (Join-Path $hookRoot '../lib/orchestrator-state/OrchestratorStateModelReceipts.psm1') -ErrorAction Stop
    . (Join-Path $PSScriptRoot 'EpicStateIsolation.Baseline.Helpers.ps1')
    if (Get-Command Get-WorktreeResolutionGitFileText -ErrorAction SilentlyContinue) { Mock Get-WorktreeResolutionGitFileText { $null } }
    Register-EpicStateBaselineMock -Seam 'Get-EpicScopeCheckpointText', 'Get-WorktreeItemCheckpointText', 'Get-WorktreeItemLiveRoot', 'Get-WorktreeRunCheckpointText', 'Get-OrchestratorStateCheckpoint', 'Get-CleanupWorktreeManifestContent' -Surface 'Claude'
    Register-EpicStateBaselineMock -Seam 'Get-CheckpointContent', 'Get-EpicCheckpointContent', 'Get-ParallelCheckpointContent' -Surface 'Codex'
    Mock Find-WorktreeResolutionRoot -ModuleName EpicScopeResolution { '/synthetic-worktrees/main' }
    Mock Get-ModelRoutingCheckpoint { $null }
    Mock Get-PrAuthorCheckpointContent { $null }
    Mock Get-PrAuthorReceiptContent { $null }
    Mock Get-ChildOrchestratorCheckpointContent { $null }
    Mock Get-EpicOrchestratorCheckpointContent { $null }
    Mock Get-ParallelOrchestratorCheckpointContent { $null }
    Import-Module (Join-Path (Split-Path -Parent $hookRoot) 'lib/model-routing/ModelRouting.psm1') -ErrorAction Stop

    # The scenario, defined once.
    # The coordinator root is the session root, as in a real Run Closing; every read beneath it is a seam.
    $script:Coordinator = ConvertTo-HookTargetWorktreeNormalizedPath -Path (Get-Location).Path
    $script:Branch = 'parallel/demo-run-plan'
    $script:RecordsPr = 88
    $script:Head = '0123456789abcdef0123456789abcdef01234567'
    $script:BaseCommit = 'fedcba9876543210fedcba9876543210fedcba98'
    $script:RecordsPaths = "docs/features/parallel/demo-run/parallel-status.md$([char]0)docs/features/parallel/demo-run/parallel.md$([char]0)"
    $resolved = Resolve-DelegationModel -Agent 'pr-author' -Band 'C2' -FablePolicy 'disabled'
    $script:CheckpointText = [ordered]@{
        route_id               = 'parallel'
        parallel_slug          = 'demo-run'
        items                  = @(
            [ordered]@{ issue_num = 101; state = 'merged'; merge_status = 'worktree_removed'; pr_number = 501 }
            [ordered]@{ issue_num = 102; state = 'withdrawn'; merge_status = 'not_started' }
        )
        complexity_assessments = @([ordered]@{ phase = 'run_closing_records'; band = 'C2'; floor = 'C1'; signals_present = @(); rationale = 'Records pull request of generated run documents.'; assessed_at = '2026-11-14T12:00:00Z' })
        model_routing_receipts = @([ordered]@{ agent = 'pr-author'; phase = 'run_closing_records'; complexity_band = 'C2'; fable_policy = 'disabled'; table_model = $resolved['table_model']; clamped_from = $resolved['clamped_from']; model = $resolved['model'] })
    } | ConvertTo-Json -Depth 8 -Compress
    $script:Prompt = "Open the Run Closing records pull request of parallel run demo-run.`nbranch: $($script:Branch)"

    function Set-ParallelRecordsWorkflowScenario {
        <#
        .SYNOPSIS
            Register every seam of the four decisions for the closed run.
        #>
        [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '', Justification = 'Registers Pester mocks for one test only; it changes no system state.')]
        param([string] $CheckpointText = $script:CheckpointText)

        $root = $script:Coordinator
        $parallelText = $CheckpointText
        $listing = "worktree $root`nbranch refs/heads/$($script:Branch)`n`nworktree /synthetic-worktrees/item-101`nbranch refs/heads/feature/item-101`n"
        $branchDiff = [pscustomobject]@{ ExitCode = 0; Output = $script:RecordsPaths }
        $baseResult = [pscustomobject]@{ ExitCode = 0; Output = $script:BaseCommit }
        $headResult = [pscustomobject]@{ ExitCode = 0; Output = $script:Head }
        $prView = [ordered]@{ baseRefName = 'main'; headRefOid = $script:Head } | ConvertTo-Json -Compress
        $branch = $script:Branch

        # Shared reads: the parallel checkpoint beneath the coordinator root, no per-feature checkpoint, and its HEAD branch.
        Mock Get-WorktreeRunCheckpointText { $null }
        Mock Get-WorktreeRunCheckpointText -ParameterFilter { ([string]$Path -replace '\\', '/').EndsWith('/parallel-orchestrator-state.json', [System.StringComparison]::Ordinal) } -MockWith ({ $parallelText }.GetNewClosure())
        Mock Get-EpicScopeWorktreeHeadBranch ({ $branch }.GetNewClosure())
        # Agent(pr-author): the delegation resolves to the coordinator root.
        Mock Resolve-ModelRoutingWorktreeTarget ({ [pscustomobject]@{ Status = 'SessionRoot'; WorktreeRoot = $root; ReasonCode = $null; Detail = 'coordinator session root' } }.GetNewClosure())
        Mock Get-ModelRoutingDocsEstateFileText { $null }
        # Receipt Write: the session listing names the coordinator root; the docs-estate leg sees a checkpoint there.
        Mock Get-OrchestrationGateWorktreeList { $listing }.GetNewClosure()
        Mock Test-OrchestrationDocsEstateCheckpointPresent { $true }
        # gh pr create: no per-feature checkpoint, so the preflight fails and the docs-only exemption decides.
        Mock Resolve-PrAuthorWorktreeTarget ({ [pscustomobject]@{ Status = 'SessionRoot'; WorktreeRoot = $root; ReasonCode = $null; Detail = 'coordinator session root' } }.GetNewClosure())
        Mock Get-PrContextArtifactExistence { $true }
        Mock Invoke-OrchestratorStatePreflight { @{ HasErrors = $true; ErrorText = '' } }
        Mock Test-PrAuthorDocsOnlyCheckpointPresence { $false }
        Mock Invoke-PrAuthorDocsOnlyGitExe -ParameterFilter { $GitArgs[0] -eq 'rev-parse' } -MockWith ({ $baseResult }.GetNewClosure())
        Mock Invoke-PrAuthorDocsOnlyGitExe -ParameterFilter { $GitArgs[0] -eq 'diff' } -MockWith ({ $branchDiff }.GetNewClosure())
        Mock Get-PrBodyFileBytes { , [byte[]] @(0x41) }
        Mock Get-PrAuthorReceiptContent { '{"number":88,"sha256":"559aead08264d5795d3909718cdd05abd49572e84fe55590eef31a88a08fdffd","created_at":"2026-11-14T12:30:00Z"}' }
        Mock Get-PrContextSummaryLastWriteUtc { [DateTime]::Parse('2026-11-14T12:00:00Z').ToUniversalTime() }
        # gh pr merge: no item target and no run checkpoint records the records pull request number.
        Mock Get-EpicMergeGateSessionWorktreeRoot ({ $root }.GetNewClosure())
        Mock Resolve-EpicMergeGateItemTarget { [pscustomobject]@{ Status = 'NoTarget'; WorktreeRoot = $null; ReasonCode = 'TARGET_WORKTREE_NOT_DERIVABLE'; Detail = 'no item records the records pull request' } }
        Mock Resolve-EpicMergeGateRunTarget -MockWith ({
                param([string] $Kind, $PrNumber)
                # The parallel run target resolves only when an items[] entry records the pull request number.
                $recorded = @(@((ConvertFrom-Json -InputObject $parallelText).items) | Where-Object { $_.PSObject.Properties.Name -contains 'pr_number' -and [int]$_.pr_number -eq [int]$PrNumber })
                if ($Kind -eq 'parallel' -and $recorded.Count -gt 0) { return [pscustomobject]@{ Status = 'SessionRoot'; WorktreeRoot = $root; ReasonCode = $null; Detail = 'recorded' } }
                return [pscustomobject]@{ Status = 'NoTarget'; WorktreeRoot = $null; ReasonCode = 'TARGET_WORKTREE_NOT_DERIVABLE'; Detail = 'no run checkpoint records the records pull request' }
            }.GetNewClosure())
        Mock Invoke-DocsOnlyGhExe -MockWith ({ [pscustomobject]@{ ExitCode = 0; Output = $prView } }.GetNewClosure())
        Mock Invoke-DocsOnlyGitExe { [pscustomobject]@{ ExitCode = 128; Output = '' } }
        Mock Invoke-DocsOnlyGitExe -ParameterFilter { $GitArgs[0] -ceq 'rev-parse' -and $GitArgs[-1].StartsWith('refs/remotes/origin/', [System.StringComparison]::Ordinal) } -MockWith ({ $baseResult }.GetNewClosure())
        Mock Invoke-DocsOnlyGitExe -ParameterFilter { $GitArgs[0] -ceq 'rev-parse' -and -not $GitArgs[-1].StartsWith('refs/remotes/origin/', [System.StringComparison]::Ordinal) } -MockWith ({ $headResult }.GetNewClosure())
        Mock Invoke-DocsOnlyGitExe -ParameterFilter { $GitArgs[0] -ceq 'diff' } -MockWith ({ $branchDiff }.GetNewClosure())
    }

    function Invoke-ParallelRecordsWorkflowStep {
        <#
        .SYNOPSIS
            Return @{ Decision; Reason } of one workflow step.
        #>
        param([Parameter(Mandatory)] [ValidateSet('Delegate', 'ReceiptWrite', 'CreatePr', 'Merge')] [string] $Step)
        $decision = switch ($Step) {
            'Delegate' {
                Invoke-ModelRoutingReceiptDecision -ToolInputRaw (@{ tool_name = 'Agent'; tool_input = @{ subagent_type = 'pr-author'; prompt = $script:Prompt } } | ConvertTo-Json -Compress -Depth 5)
            }
            'ReceiptWrite' {
                Invoke-OrchestrationPreimplementationGateDecision -ToolInputRaw (@{ tool_name = 'Write'; tool_input = @{ file_path = 'artifacts/pr_body_88.receipt.json'; content = '{}' } } | ConvertTo-Json -Compress -Depth 5)
            }
            'CreatePr' {
                Invoke-PrAuthorSkillDecision -ToolInputRaw (@{ tool_input = @{ command = "gh pr create --head $($script:Branch) --base main --body-file artifacts/pr_body_88.md" } } | ConvertTo-Json -Compress -Depth 5)
            }
            'Merge' {
                Invoke-EpicMergeGateDecision -ToolInputRaw (@{ session_id = 'session-1182'; tool_name = 'Bash'; tool_input = @{ command = "gh pr merge $($script:RecordsPr) --merge" } } | ConvertTo-Json -Compress -Depth 5)
            }
        }
        return @{ Decision = $decision.hookSpecificOutput.permissionDecision; Reason = [string]$decision.hookSpecificOutput.permissionDecisionReason }
    }
}

AfterAll {
    # Remove the top-level functions of the four dot-sourced gates and of the leg files they load.
    $hookRoot = (Resolve-Path "$PSScriptRoot/../../../.claude/hooks").Path
    $loaded = @('enforce-orchestration-preimplementation-gate.ps1', 'enforce-model-routing-receipt.ps1', 'enforce-pr-author-skill.ps1', 'enforce-epic-merge-gate.ps1', 'enforce-orchestration-preimplementation-gate-parallel-records.ps1', 'enforce-model-routing-receipt-parallel.ps1', 'hook-parallel-records-context.ps1')
    foreach ($file in $loaded | ForEach-Object { Join-Path $hookRoot $_ }) {
        $tokens = $null
        $parseErrors = $null
        $ast = [System.Management.Automation.Language.Parser]::ParseFile($file, [ref]$tokens, [ref]$parseErrors)
        foreach ($definition in $ast.FindAll({ param($node) $node -is [System.Management.Automation.Language.FunctionDefinitionAst] }, $false)) {
            Remove-Item -LiteralPath ('Function:\' + $definition.Name) -ErrorAction SilentlyContinue
        }
    }
}

Describe 'parallel records workflow end to end (issue #1182)' {
    BeforeEach {
        Set-ParallelRecordsWorkflowScenario
    }

    It 'baseline mock interception probe' { Invoke-EpicStateInterceptionProbe -Surface 'Claude' -Seam 'Get-EpicScopeCheckpointText', 'Get-WorktreeItemCheckpointText', 'Get-WorktreeItemLiveRoot', 'Get-WorktreeRunCheckpointText' }

    It 'AC-15 allows the four decisions of the records pull request in sequence' {
        # Act
        $delegate = Invoke-ParallelRecordsWorkflowStep -Step 'Delegate'
        $write = Invoke-ParallelRecordsWorkflowStep -Step 'ReceiptWrite'
        $create = Invoke-ParallelRecordsWorkflowStep -Step 'CreatePr'
        $merge = Invoke-ParallelRecordsWorkflowStep -Step 'Merge'

        # Assert
        $delegate.Decision | Should -Be 'allow' -Because "Agent(pr-author): $($delegate.Reason)"
        $write.Decision | Should -Be 'allow' -Because "receipt Write: $($write.Reason)"
        $create.Decision | Should -Be 'allow' -Because "gh pr create: $($create.Reason)"
        $merge.Decision | Should -Be 'allow' -Because "gh pr merge: $($merge.Reason)"
        Should -Invoke Test-PrAuthorDocsOnlyCheckpointPresence -Times 1 -Exactly -ParameterFilter { ([string]$CheckpointPath -replace '\\', '/').EndsWith('/orchestration/orchestrator-state.json', [System.StringComparison]::Ordinal) }
        Should -Invoke Invoke-DocsOnlyGhExe -Times 1 -Exactly -ParameterFilter { ($GhArgs -join ' ') -ceq 'pr view 88 --json baseRefName,headRefOid' }
    }

    It 'routes the merge to the parallel branch instead when items[] records the records pull request number' {
        # Arrange: recording the number makes the parallel target resolve, so the docs-only branch is not reached.
        Set-ParallelRecordsWorkflowScenario -CheckpointText $script:CheckpointText.Replace('"pr_number":501', '"pr_number":88')

        # Act
        $merge = Invoke-ParallelRecordsWorkflowStep -Step 'Merge'

        # Assert
        $merge.Decision | Should -Be 'deny'
        Should -Invoke Invoke-DocsOnlyGhExe -Times 0 -Exactly
    }
}
