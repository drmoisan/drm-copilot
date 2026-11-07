#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

<#
.SYNOPSIS
    Checkpoint rules of review_mode concurrent in the PowerShell validators (issue #1097).

.DESCRIPTION
    The committed corpus tests/fixtures/orchestrator_state_concurrent_review pins
    Get-OrchestratorStateCompletionConcurrentReviewError to its Python and TypeScript
    ports. The remaining rows prove that the readiness gate relaxes only the pair
    step7_status and pending under the exact key, and that the completion entry point
    reports the review error only under the key. Checkpoints are built in memory and the
    filesystem boundary (Test-Path and Get-Content) is mocked inside the shared
    OrchestratorState module scope, so no file is written and no process is started.
#>

BeforeDiscovery {
    $corpusDirectory = (Resolve-Path "$PSScriptRoot/../../../../tests/fixtures/orchestrator_state_concurrent_review").Path
    $script:CorpusCase = @(Get-ChildItem -Path $corpusDirectory -Filter '*.json' -File | Sort-Object -Property Name | ForEach-Object { @{ FixtureName = $_.BaseName; FixturePath = $_.FullName } })
    $script:CorpusFloor = @(@{ DiscoveredCount = $script:CorpusCase.Count; MinimumCount = 12 })
}

BeforeAll {
    $script:LibDir = (Resolve-Path "$PSScriptRoot/../../../../.claude/lib/orchestrator-state").Path
    $script:SharedModuleName = 'OrchestratorState'
    $script:ReviewError = 'Checkpoint completion validation failed: review_mode concurrent requires a last review_outcomes entry with verdict PASS.'

    function Get-ReviewCheckpointJson {
        <#
        .SYNOPSIS
            Return a PR-creation-ready checkpoint as JSON text, with top-level changes.
        .PARAMETER Change
            Top-level keys to set or replace.
        #>
        [CmdletBinding()]
        [OutputType([string])]
        param([hashtable] $Change = @{})

        $checkpoint = [ordered]@{
            objective              = 'deliver concurrent review'
            change_budget_estimate = 'small'
            path_selected          = 'short'
            'promotion-type'       = 'feature'
            'short-name'           = 'review'
            relativeFile           = 'docs/features/active/review/issue.md'
            'long-name'            = 'concurrent review'
            'issue-num'            = 'none'
            'feature-folder'       = 'docs/features/active/review'
            'work-mode'            = 'full-feature'
            'plan-path'            = 'docs/features/active/review/plan.md'
            completed_steps        = @('step1')
            next_step              = 'complete'
            last_updated           = '2026-11-06T00-00'
            step5_status           = 'verified'
            step6_status           = 'verified'
            step7_status           = 'verified'
            step8_status           = 'verified'
            step9_status           = 'not-applicable'
            step10_status          = 'not-applicable'
            delegation_receipts    = @()
            blocked_reason         = 'none'
        }
        foreach ($key in $Change.Keys) { $checkpoint[$key] = $Change[$key] }
        return ($checkpoint | ConvertTo-Json -Depth 5)
    }

    function Register-ReviewCheckpointFixture {
        <#
        .SYNOPSIS
            Register in-memory checkpoint text as the mocked file content.
        .PARAMETER Json
            The checkpoint text.
        #>
        [CmdletBinding()]
        param([Parameter(Mandatory)][string] $Json)

        $text = $Json
        Mock -ModuleName $script:SharedModuleName -CommandName Test-Path -MockWith { $true }
        Mock -ModuleName $script:SharedModuleName -CommandName Get-Content -MockWith ({ $text }.GetNewClosure())
    }

    function Get-ReviewCompletionLine {
        <#
        .SYNOPSIS
            Return the error lines of the completion entry point for one checkpoint.
        .PARAMETER Json
            The checkpoint text.
        #>
        [CmdletBinding()]
        [OutputType([string[]])]
        param([Parameter(Mandatory)][string] $Json)

        Register-ReviewCheckpointFixture -Json $Json
        $result = Test-OrchestratorStateCompletionReadiness -CheckpointPath 'x.json'
        return [string[]]@(([string]$result.Output) -split [System.Environment]::NewLine)
    }
}

Describe 'review_mode concurrent corpus (issue #1097)' {
    BeforeAll {
        Import-Module (Join-Path $script:LibDir 'OrchestratorStateCompletionChecks.psm1') -Force
    }

    It 'OCR-CORPUS-FLOOR discovers at least <MinimumCount> fixture files' -ForEach $script:CorpusFloor {
        $DiscoveredCount | Should -BeGreaterOrEqual $MinimumCount
    }

    It 'OCR-CORPUS-<FixtureName>' -ForEach $script:CorpusCase {
        # Arrange
        $fixture = Get-Content -Path $FixturePath -Raw | ConvertFrom-Json
        $expected = @($fixture.expected_errors) -join "`n"

        # Act
        $actual = @(Get-OrchestratorStateCompletionConcurrentReviewError -State $fixture.checkpoint) -join "`n"

        # Assert
        $fixture.name | Should -BeExactly $FixtureName
        $actual | Should -BeExactly $expected
    }
}

Describe 'review_mode concurrent readiness (issue #1097)' {
    BeforeAll {
        # A fresh instance, so the mocks and the readiness functions share one module scope.
        Import-Module (Join-Path $script:LibDir 'OrchestratorState.psm1') -Force
    }

    It 'OCR-READINESS-ALLOWS-PENDING-STEP7-UNDER-KEY' {
        Register-ReviewCheckpointFixture -Json (Get-ReviewCheckpointJson -Change @{ step7_status = 'pending'; review_mode = 'concurrent' })

        $result = Test-OrchestratorStatePrCreationReadiness -CheckpointPath 'x.json'

        $result.ExitCode | Should -Be 0 -Because $result.Output
    }

    It 'OCR-READINESS-BLOCKS-WITHOUT-KEY' {
        Register-ReviewCheckpointFixture -Json (Get-ReviewCheckpointJson -Change @{ step7_status = 'pending' })

        $result = Test-OrchestratorStatePrCreationReadiness -CheckpointPath 'x.json'

        $result.ExitCode | Should -Be 1
        $result.Output | Should -Match 'step7_status is pending'
    }

    It 'OCR-READINESS-BLOCKS-CASE-VARIANT' {
        Register-ReviewCheckpointFixture -Json (Get-ReviewCheckpointJson -Change @{ step7_status = 'pending'; review_mode = 'Concurrent' })

        $result = Test-OrchestratorStatePrCreationReadiness -CheckpointPath 'x.json'

        $result.ExitCode | Should -Be 1
        $result.Output | Should -Match 'step7_status is pending'
    }

    It 'OCR-READINESS-BLOCKS-KEY-NAME-CASE-VARIANT' {
        Register-ReviewCheckpointFixture -Json (Get-ReviewCheckpointJson -Change @{ step7_status = 'pending'; Review_Mode = 'concurrent' })

        $result = Test-OrchestratorStatePrCreationReadiness -CheckpointPath 'x.json'

        $result.ExitCode | Should -Be 1
        $result.Output | Should -Match 'step7_status is pending'
    }

    It 'OCR-READINESS-BLOCKS-BLOCKED-STEP7-UNDER-KEY' {
        Register-ReviewCheckpointFixture -Json (Get-ReviewCheckpointJson -Change @{ step7_status = 'blocked'; review_mode = 'concurrent' })

        $result = Test-OrchestratorStatePrCreationReadiness -CheckpointPath 'x.json'

        $result.ExitCode | Should -Be 1
        $result.Output | Should -Match 'step7_status is blocked'
    }

    It 'OCR-READINESS-BLOCKS-OTHER-PENDING-STEPS-UNDER-KEY (<StepKey>)' -ForEach @(
        @{ StepKey = 'step5_status' }
        @{ StepKey = 'step6_status' }
        @{ StepKey = 'step8_status' }
    ) {
        Register-ReviewCheckpointFixture -Json (Get-ReviewCheckpointJson -Change @{ $StepKey = 'pending'; review_mode = 'concurrent' })

        $result = Test-OrchestratorStatePrCreationReadiness -CheckpointPath 'x.json'

        $result.ExitCode | Should -Be 1
        $result.Output | Should -Match "$StepKey is pending"
    }

    It 'OCR-PREFLIGHT-ALLOWS-PENDING-STEP7-UNDER-KEY' {
        # The default invoker runs the unconditional block and the readiness gate in process.
        Register-ReviewCheckpointFixture -Json (Get-ReviewCheckpointJson -Change @{ step7_status = 'pending'; review_mode = 'concurrent' })

        $result = Invoke-OrchestratorStatePreflight -CheckpointPath 'x.json'

        $result.HasErrors | Should -BeFalse -Because $result.ErrorText
    }
}

Describe 'review_mode concurrent completion (issue #1097)' {
    BeforeAll {
        # The completion module re-imports the shared module, which the mocks then target.
        Import-Module (Join-Path $script:LibDir 'OrchestratorState.psm1') -Force
        Import-Module (Join-Path $script:LibDir 'OrchestratorStateCompletion.psm1') -Force
    }

    It 'OCR-COMPLETION-REPORTS-REVIEW-ERROR-UNDER-KEY' {
        # Arrange: the same checkpoint with and without the key.
        $without = Get-ReviewCompletionLine -Json (Get-ReviewCheckpointJson)

        # Act
        $with = Get-ReviewCompletionLine -Json (Get-ReviewCheckpointJson -Change @{ review_mode = 'concurrent' })

        # Assert: the key adds exactly the review error and changes no other line.
        @($with | Where-Object { $_ -ceq $script:ReviewError }).Count | Should -Be 1
        (@($with | Where-Object { $_ -cne $script:ReviewError }) -join "`n") | Should -BeExactly ($without -join "`n")
    }

    It 'OCR-COMPLETION-UNCHANGED-WITHOUT-KEY' {
        # Arrange
        $without = Get-ReviewCompletionLine -Json (Get-ReviewCheckpointJson)

        # Act
        $sequential = Get-ReviewCompletionLine -Json (Get-ReviewCheckpointJson -Change @{ review_mode = 'sequential' })

        # Assert
        ($sequential -join "`n") | Should -BeExactly ($without -join "`n")
    }

    It 'OCR-COMPLETION-UNCHANGED-FOR-KEY-NAME-CASE-VARIANT' {
        # Arrange
        $without = Get-ReviewCompletionLine -Json (Get-ReviewCheckpointJson)

        # Act
        $variant = Get-ReviewCompletionLine -Json (Get-ReviewCheckpointJson -Change @{ Review_Mode = 'concurrent' })

        # Assert: only the exact key name activates the check.
        ($variant -join "`n") | Should -BeExactly ($without -join "`n")
    }
}
