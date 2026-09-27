#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

<#
.SYNOPSIS
    Value-contract tests for Get-OrchestratorStateCheckpoint.

.DESCRIPTION
    Holds the Describe block moved verbatim out of OrchestratorState.Tests.ps1 by issue
    #673, which found that file at 509 lines and therefore over the repository's 500-line
    cap. The move is a pure relocation: no assertion, name, or fixture value changed.

    The BeforeAll below reproduces only what these two rows need from the source suite:
    the module import and the two fixture helpers. It deliberately stops short of the
    source's own BeforeAll closing brace, which would have been carried in as an extra
    brace and left this file unparseable.
#>

BeforeAll {
    # Resolve the module four levels up: orchestrator-state -> claude-lib -> scripts
    # -> tests -> repo root, then into .claude/lib/orchestrator-state.
    $script:ModulePath = (Resolve-Path "$PSScriptRoot/../../../../.claude/lib/orchestrator-state/OrchestratorState.psm1").Path
    Import-Module $script:ModulePath -Force
    $script:ModuleName = 'OrchestratorState'

    function script:New-ReadyCheckpoint {
        return [ordered]@{
            objective              = 'deliver portable preflight'
            change_budget_estimate = 'small'
            path_selected          = 'short'
            'promotion-type'       = 'feature'
            'short-name'           = 'portable'
            relativeFile           = 'docs/features/active/portable/issue.md'
            'long-name'            = 'portable orchestrator state preflight'
            'issue-num'            = 'none'
            'feature-folder'       = 'docs/features/active/portable'
            'work-mode'            = 'full-feature'
            'plan-path'            = 'docs/features/active/portable/plan.md'
            completed_steps        = @('step1')
            next_step              = 'complete'
            last_updated           = '2026-07-06T00-00'
            step5_status           = 'verified'
            step6_status           = 'verified'
            step7_status           = 'verified'
            step8_status           = 'verified'
            step9_status           = 'not-applicable'
            step10_status          = 'not-applicable'
            delegation_receipts    = @()
            blocked_reason         = 'none'
        }
    }

    # Register the in-memory checkpoint JSON as the mocked file content for a test.
    function script:Set-CheckpointFixture {
        param([string] $Json, [bool] $Exists = $true)
        $script:FixtureJson = $Json
        $script:FixtureExists = $Exists
        Mock -ModuleName $script:ModuleName -CommandName Test-Path -MockWith { $script:FixtureExists }
        Mock -ModuleName $script:ModuleName -CommandName Get-Content -MockWith { $script:FixtureJson }
    }
}

Describe 'Get-OrchestratorStateCheckpoint value contract' {
    It 'returns an ISO-8601 valued checkpoint key as a DateTime under default date handling' {
        # Arrange: a real parseable instant; the template value 2026-07-06T00-00 is not one and is never coerced.
        $checkpoint = New-ReadyCheckpoint
        $checkpoint.last_updated = '2026-08-29T20:38:00Z'
        Set-CheckpointFixture -Json ($checkpoint | ConvertTo-Json -Depth 5)

        # Act
        $result = Get-OrchestratorStateCheckpoint -CheckpointPath 'x.json'

        # Assert: ConvertFrom-Json coerces the instant; a non-date string key is not.
        $result.Ok | Should -BeTrue
        $result.State.last_updated | Should -BeOfType [System.DateTime]
        $result.State.objective | Should -BeOfType [System.String]
    }

    It 'documents the checkpoint date-coercion contract in its comment-based help' {
        # Arrange / Act: the rendered help, width-pinned so console width cannot wrap the literal.
        $helpText = Get-Help -Name 'Get-OrchestratorStateCheckpoint' -Full | Out-String -Width 500

        # Assert: the documentation obligation is enforced by a test.
        $helpText | Should -BeLike '*date-coerced by ConvertFrom-Json*'
    }
}
