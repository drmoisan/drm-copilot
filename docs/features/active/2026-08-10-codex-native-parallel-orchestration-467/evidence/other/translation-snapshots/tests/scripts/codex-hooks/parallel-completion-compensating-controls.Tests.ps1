#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

Describe 'Parallel G16 completion compensating controls' {
    BeforeAll {
        $script:RepoRoot = (Resolve-Path "$PSScriptRoot/../../..").Path
        $script:HookRoot = Join-Path $script:RepoRoot '.codex/hooks'
        $script:CheckpointPath =
        'artifacts/orchestration/parallel-orchestrator-state.json'
        $script:ReceiptMismatch =
        'parallel-orchestrator checkpoint items[0] completion receipt checks head SHA must match pr_head_sha.'
        $script:FullStateFailure =
        'parallel-orchestrator checkpoint contains incomplete terminal state.'
        $script:LedgerPath = Join-Path $script:RepoRoot (
            'docs/features/active/2026-08-10-codex-native-parallel-orchestration-467/' +
            'evidence/other/translation-plan.2026-08-10T20-25.md'
        )
        $script:CiWorkflowPath = Join-Path $script:RepoRoot '.github/workflows/ci.yml'

        . (Join-Path $script:HookRoot 'enforce-completion-consistency.ps1')

        function Get-G16StopPayload {
            <# Returns one in-memory parallel SubagentStop payload. #>
            param([Parameter(Mandatory)][bool] $AlreadyContinued)

            return [ordered]@{
                hook_event_name  = 'SubagentStop'
                agent_type       = 'parallel-orchestrator'
                agent_id         = 'g16-parallel-orchestrator'
                session_id       = 'g16-session'
                model            = 'gpt-5.6-sol'
                stop_hook_active = $AlreadyContinued
            } | ConvertTo-Json -Compress
        }

        function Invoke-G16OutputDecision {
            <# Applies the public output seam to one injected validator result. #>
            param(
                [Parameter(Mandatory)][bool] $AlreadyContinued,
                [Parameter(Mandatory)][AllowEmptyCollection()][string[]] $Errors
            )

            $injectedErrors = [string[]]$Errors
            $validator = {
                param($AgentType, $RepositoryRoot)
                $null = $AgentType
                $null = $RepositoryRoot
                return $injectedErrors
            }.GetNewClosure()
            return Invoke-CodexParallelAgentOutputDecision `
                -PayloadRaw (Get-G16StopPayload -AlreadyContinued $AlreadyContinued) `
                -WorkspaceRoot $script:RepoRoot `
                -Validator $validator
        }

        function Invoke-G16RootCompletionDecision {
            <# Applies the public root-completion seam to an injected state error. #>
            param([Parameter(Mandatory)][AllowEmptyString()][string] $ValidationError)

            $checkpoint = [ordered]@{
                schema_version = 2
                route_id       = 'parallel'
                next_step      = 'complete'
                items          = @()
            } | ConvertTo-Json -Compress -Depth 10
            $toolInput = [ordered]@{
                file_path = $script:CheckpointPath
                content   = $checkpoint
            } | ConvertTo-Json -Compress -Depth 10
            $injectedError = $ValidationError
            $validator = {
                param($CheckpointContent, $RepositoryRoot)
                $null = $CheckpointContent
                $null = $RepositoryRoot
                if ([string]::IsNullOrWhiteSpace($injectedError)) {
                    return [string[]]@()
                }
                return [string[]]@($injectedError)
            }.GetNewClosure()

            return Invoke-CompletionConsistencyDecision `
                -ToolInputRaw $toolInput `
                -WorkspaceRoot $script:RepoRoot `
                -ParallelCompletionValidator $validator
        }

        function Invoke-G16CiCompletionProbe {
            <# Models the required CI job exit contract over the public root gate. #>
            param(
                [Parameter(Mandatory)][AllowEmptyString()][string] $JobName,
                [Parameter(Mandatory)][bool] $Required,
                [Parameter(Mandatory)][AllowEmptyString()][string] $InvalidStateError
            )

            $decision = Invoke-G16RootCompletionDecision `
                -ValidationError $InvalidStateError
            $denied = $decision.hookSpecificOutput.permissionDecision -eq 'deny'
            return [pscustomobject]@{
                JobName              = $JobName
                Required             = $Required
                InvalidStateExitCode = if ($denied) { 1 } else { 0 }
                DecisionReason       = [string]$decision.hookSpecificOutput.permissionDecisionReason
            }
        }

        function Get-G16LedgerDisposition {
            <# Maps the complete mechanical control set to DEGRADED or LOST. #>
            param(
                [Parameter(Mandatory)][bool] $OneContinuation,
                [Parameter(Mandatory)][bool] $RepeatedStopRefused,
                [Parameter(Mandatory)][bool] $RootStateRefused,
                [Parameter(Mandatory)][bool] $ReceiptMismatchRefused,
                [Parameter(Mandatory)] $CiProbe
            )

            $errors = [System.Collections.Generic.List[string]]::new()
            if (-not $OneContinuation) {
                $errors.Add('one continuation is not enforced')
            }
            if (-not $RepeatedStopRefused) {
                $errors.Add('repeated stop is not refused')
            }
            if (-not $RootStateRefused) {
                $errors.Add('invalid full state is not refused at root completion')
            }
            if (-not $ReceiptMismatchRefused) {
                $errors.Add('immutable completion-receipt mismatch is not refused')
            }
            if ([string]$CiProbe.JobName -cne 'parallel-completion-gate') {
                $errors.Add('required parallel-completion-gate job is missing')
            }
            if ($CiProbe.Required -isnot [bool] -or -not [bool]$CiProbe.Required) {
                $errors.Add('parallel-completion-gate is not required')
            }
            if ([int]$CiProbe.InvalidStateExitCode -eq 0) {
                $errors.Add('parallel-completion-gate accepts invalid final state')
            }

            return [pscustomobject]@{
                RowStatus  = if ($errors.Count -eq 0) { 'DEGRADED' } else { 'LOST' }
                BlocksPlan = $errors.Count -gt 0
                Errors     = $errors.ToArray()
            }
        }
    }

    It 'permits one continuation and refuses repeated stop reuse' {
        $first = Invoke-G16OutputDecision `
            -AlreadyContinued $false `
            -Errors @($script:FullStateFailure)
        $repeated = Invoke-G16OutputDecision `
            -AlreadyContinued $true `
            -Errors @($script:FullStateFailure)
        $valid = Invoke-G16OutputDecision -AlreadyContinued $false -Errors @()

        $first.decision | Should -BeExactly 'block'
        $first.reason | Should -BeExactly (
            "PARALLEL_AGENT_OUTPUT_BLOCKED: $($script:FullStateFailure)"
        )
        $repeated['continue'] | Should -BeFalse
        $repeated.stopReason | Should -BeExactly $first.reason
        $valid | Should -BeNullOrEmpty
    }

    It 'refuses invalid full state and immutable completion-receipt mismatch at root' {
        $stateDecision = Invoke-G16RootCompletionDecision `
            -ValidationError $script:FullStateFailure
        $receiptDecision = Invoke-G16RootCompletionDecision `
            -ValidationError $script:ReceiptMismatch

        $stateDecision.hookSpecificOutput.permissionDecision |
            Should -BeExactly 'deny'
        $stateDecision.hookSpecificOutput.permissionDecisionReason |
            Should -BeExactly "PARALLEL_COMPLETION_BLOCKED: $($script:FullStateFailure)"
        $receiptDecision.hookSpecificOutput.permissionDecision |
            Should -BeExactly 'deny'
        $receiptDecision.hookSpecificOutput.permissionDecisionReason |
            Should -BeExactly "PARALLEL_COMPLETION_BLOCKED: $($script:ReceiptMismatch)"
    }

    It 'keeps G16 DEGRADED only when every compensating control is effective' {
        $first = Invoke-G16OutputDecision `
            -AlreadyContinued $false `
            -Errors @($script:FullStateFailure)
        $repeated = Invoke-G16OutputDecision `
            -AlreadyContinued $true `
            -Errors @($script:FullStateFailure)
        $stateDecision = Invoke-G16RootCompletionDecision `
            -ValidationError $script:FullStateFailure
        $receiptDecision = Invoke-G16RootCompletionDecision `
            -ValidationError $script:ReceiptMismatch
        $ciProbe = Invoke-G16CiCompletionProbe `
            -JobName 'parallel-completion-gate' `
            -Required $true `
            -InvalidStateError $script:FullStateFailure

        $result = Get-G16LedgerDisposition `
            -OneContinuation ($first.decision -eq 'block') `
            -RepeatedStopRefused ($repeated['continue'] -eq $false) `
            -RootStateRefused (
            $stateDecision.hookSpecificOutput.permissionDecision -eq 'deny'
        ) `
            -ReceiptMismatchRefused (
            $receiptDecision.hookSpecificOutput.permissionDecision -eq 'deny'
        ) `
            -CiProbe $ciProbe

        $ciProbe.JobName | Should -BeExactly 'parallel-completion-gate'
        $ciProbe.Required | Should -BeTrue
        $ciProbe.InvalidStateExitCode | Should -Be 1
        $ciProbe.DecisionReason | Should -Match '^PARALLEL_COMPLETION_BLOCKED:'
        $result.RowStatus | Should -BeExactly 'DEGRADED'
        $result.BlocksPlan | Should -BeFalse
        $result.Errors | Should -BeNullOrEmpty
    }

    It 'maps a missing or non-failing required CI path to LOST' -ForEach @(
        @{ Name = 'missing job'; JobName = ''; Required = $true; Error = $script:FullStateFailure }
        @{ Name = 'optional job'; JobName = 'parallel-completion-gate'; Required = $false; Error = $script:FullStateFailure }
        @{ Name = 'non-failing job'; JobName = 'parallel-completion-gate'; Required = $true; Error = '' }
    ) {
        $ciProbe = Invoke-G16CiCompletionProbe `
            -JobName $JobName `
            -Required $Required `
            -InvalidStateError $Error
        $result = Get-G16LedgerDisposition `
            -OneContinuation $true `
            -RepeatedStopRefused $true `
            -RootStateRefused $true `
            -ReceiptMismatchRefused $true `
            -CiProbe $ciProbe

        $result.RowStatus | Should -BeExactly 'LOST' -Because $Name
        $result.BlocksPlan | Should -BeTrue -Because $Name
        $result.Errors | Should -Not -BeNullOrEmpty -Because $Name
    }

    It 'binds the test-only contract to the authoritative G16 ledger row' {
        $ledger = Get-Content -Raw -LiteralPath $script:LedgerPath
        $g16 = [regex]::Match($ledger, '(?m)^\| G16 \|.*\|$')

        $g16.Success | Should -BeTrue
        $g16.Value | Should -Match '\| DEGRADED \|'
        $g16.Value | Should -Match 'One-continuation/repeat-stop tests'
        $g16.Value | Should -Match 'CI contract proving invalid final state fails the required job'
    }

    It 'requires one non-optional root completion gate over the existing PoshQC workflow' {
        $workflow = Get-Content -Raw -LiteralPath $script:CiWorkflowPath
        $jobHeaders = [regex]::Matches(
            $workflow,
            '(?m)^  parallel-completion-gate:\s*$'
        )

        $jobHeaders.Count | Should -Be 1
        $job = [regex]::Match(
            $workflow,
            '(?ms)^  parallel-completion-gate:\s*\r?\n' +
            '(?<body>.*?)(?=^  [A-Za-z0-9_-]+:\s*$|\z)'
        )
        $job.Success | Should -BeTrue
        $job.Groups['body'].Value |
            Should -Match '(?m)^    uses: \./\.github/workflows/_poshqc\.yml\s*$'
        $job.Groups['body'].Value |
            Should -Not -Match '(?m)^    (?:continue-on-error:\s*true|if:)'
    }
}
